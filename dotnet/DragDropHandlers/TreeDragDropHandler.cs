using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner.DragDropHandlers
{
    public class TreeDragDropHandler : DragDropHandler
    {
        public TreeDragDropHandler(Outliner.TreeView tree, OutlinerScene data) : base(tree, null) 
        {
            Data = data;
        }
        new protected OutlinerScene Data { get; private set; }


        protected override bool IsDroppableNode(OutlinerNode o)
        {
            if (Tree.ListMode == OutlinerListMode.Hierarchy || Tree.ListMode == OutlinerListMode.Material)
                return (o is OutlinerObject);
            else if (Tree.ListMode == OutlinerListMode.Layer)
                return (o is OutlinerLayer);
            else
                return false;
        }

        public override bool IsValidDropTarget(IDataObject dragData)
        {
            if (Tree == null)
                return false;
            else
                return base.IsValidDropTarget(dragData);
        }


        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
                return DragDropEffects.Move;
            else
                return Outliner.TreeView.DragDropEffectsNone;
        }


        public override bool ItemDropped(IDataObject dragData)
        {
            if (!IsValidDropTarget(dragData))
                return false;
            
            OutlinerNode[] droppedNodes = GetNodesFromDataObject(dragData);
            Int32[] droppedNodeHandles = new Int32[droppedNodes.Length];

            Tree.BeginTimedUpdate();
            Tree.BeginTimedSort();
            
            // Hierarchy mode.
            if (Tree.ListMode == OutlinerListMode.Hierarchy)
            {
                Boolean dispatchUngroupEvent = false;
                Int32 i = 0;
                foreach (OutlinerNode n in droppedNodes)
                {
                    if (((OutlinerObject)n).IsGroupMember)
                        dispatchUngroupEvent = true;

                    Tree.LinkObject((OutlinerObject)n, OutlinerScene.RootHandle, ((OutlinerObject)n).IsGroupMember, false);

                    droppedNodeHandles[i] = n.Handle;
                    i++;
                }

                if (dispatchUngroupEvent)
                {
                    Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(droppedNodeHandles, OutlinerScene.RootHandle, false, true));
                    Int32[] childHandles = getChildHandles(droppedNodes);
                    if (childHandles.Length > 0)
                        Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(childHandles, OutlinerScene.RootHandle, false, false));
                }
                else
                    Tree.RaiseObjectLinkedEvent(new NodeLinkedEventArgs(droppedNodeHandles, OutlinerScene.RootHandle));
            }
            
            // Layer mode.
            else if (Tree.ListMode == OutlinerListMode.Layer)
            {
                Int32 i = 0;
                foreach (OutlinerNode n in droppedNodes)
                {
                    Tree.SetLayerParent((OutlinerLayer)n, OutlinerScene.RootHandle);
                    droppedNodeHandles[i] = n.Handle;
                    i++;
                }
                Tree.RaiseLayerLinkedEvent(new NodeLinkedEventArgs(droppedNodeHandles, OutlinerScene.RootHandle));
            }
            
            // Material mode.
            else if (Tree.ListMode == OutlinerListMode.Material)
            {
                Int32 i = 0;
                foreach (OutlinerNode n in droppedNodes)
                {
                    Tree.SetObjectMaterial((OutlinerObject)n, OutlinerScene.UnassignedHandle);

                    droppedNodeHandles[i] = n.Handle;
                    i++;
                }

                Tree.RaiseObjectMaterialChangedEvent(new NodePropertyChangedEventArgs(droppedNodeHandles, "material", OutlinerScene.UnassignedHandle));

            }

            return true;
        }
    }
}
