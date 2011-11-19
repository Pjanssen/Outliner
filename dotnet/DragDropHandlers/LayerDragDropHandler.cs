using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using Outliner.Scene;

namespace Outliner.DragDropHandlers
{
    public class LayerDragDropHandler : DragDropHandler
    {
        public LayerDragDropHandler(Outliner.TreeView tree, OutlinerLayer data) : base(tree, null) 
        {
            Data = data;
        }
        new protected OutlinerLayer Data { get; private set; }

        public override bool AllowDrag
        {
            get
            {
                return (!Data.IsDefaultLayer);
            }
        }

        protected override bool IsDroppableNode(OutlinerNode o)
        {
            return (o is OutlinerObject || o is OutlinerLayer);
        }

        public override bool IsValidDropTarget(IDataObject dragData)
        {
            if (Tree == null || Tree.ListMode != OutlinerListMode.Layer)
                return false;
            else
                return base.IsValidDropTarget(dragData);
        }
        

        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
                return DragDropEffects.Copy;
            else
                return Outliner.TreeView.DragDropEffectsNone;
        }


        public override bool ItemDropped(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
            {
                OutlinerNode[] droppedNodes = GetNodesFromDataObject(dragData);
                List<Int32> droppedNodeHandles = new List<Int32>();
                List<Int32> droppedLayerHandles = new List<Int32>();

                Tree.BeginTimedUpdate();
                Tree.BeginTimedSort();

                foreach (OutlinerNode n in droppedNodes)
                {
                    if (n is OutlinerObject)
                    {
                        Tree.SetObjectLayer((OutlinerObject)n, Data.Handle);
                        droppedNodeHandles.Add(n.Handle);
                        if (((OutlinerObject)n).IsGroupHead && Tree.HideGroupMembersLayerMode)
                        {
                            setObjectLayerRecursive((OutlinerObject)n);
                            droppedNodeHandles.AddRange(getChildHandles(new OutlinerNode[] { n }));
                        }
                    }
                    else if (n is OutlinerLayer)
                    {
                        Tree.SetLayerParent((OutlinerLayer)n, Data.Handle);
                        droppedLayerHandles.Add(n.Handle);
                    }
                }

                if (droppedNodeHandles.Count > 0)
                    Tree.RaiseObjectLayerChangedEvent(new NodeLinkedEventArgs(droppedNodeHandles.ToArray(), Data.Handle));

                if (droppedLayerHandles.Count > 0)
                    Tree.RaiseLayerLinkedEvent(new NodeLinkedEventArgs(droppedLayerHandles.ToArray(), Data.Handle));

                return true;
            }
            return false;
        }

        private void setObjectLayerRecursive(OutlinerObject obj)
        {
            Tree.Scene.SetObjectLayerHandle(obj, Data.Handle);
            foreach(OutlinerNode cn in obj.ChildNodes)
                setObjectLayerRecursive((OutlinerObject)cn);
        }
    }
}
