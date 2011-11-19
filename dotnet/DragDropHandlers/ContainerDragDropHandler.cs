using System;
using System.Collections.Generic;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;

namespace Outliner.DragDropHandlers
{
    public class ContainerDragDropHandler : ObjectDragDropHandler
    {
        public ContainerDragDropHandler(Outliner.TreeView tree, OutlinerObject data) : base(tree, data) { }


        public override bool IsValidDropTarget(IDataObject dragData)
        {
            if (Tree == null || Tree.ListMode != OutlinerListMode.Hierarchy)
                return false;
            else if (Data.ChildNodes.Count == 0)
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
                Int32[] droppedNodeHandles = new Int32[droppedNodes.Length];

                Tree.BeginTimedUpdate();
                Tree.BeginTimedSort();

                Int32 i = 0;
                foreach (OutlinerNode n in droppedNodes)
                {
                    //Tree.LinkObject((OutlinerObject)n, Data.Handle, false, false);

                    droppedNodeHandles[i] = ((OutlinerObject)n).Handle;
                    i++;
                }

                //Tree.RaiseObjectLinkedEvent(new NodeLinkedEventArgs(droppedNodeHandles, Data.Handle));
                Tree.RaiseObjectAddedToContainerEvent(new NodeGroupedEventArgs(droppedNodeHandles, Data.Handle, true, false));

                return true;
            }
            return false;
        }
    }
}