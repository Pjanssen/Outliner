using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner.DragDropHandlers
{
    public class ObjectDragDropHandler : DragDropHandler
    {
        public ObjectDragDropHandler(Outliner.TreeView tree, OutlinerObject data) : base(tree, null)
        {
            Data = data;
        }

        new protected OutlinerObject Data { get; set; }


        override public Boolean AllowDrag { get { return true; } }


        protected override Boolean IsDroppableNode(OutlinerNode o)
        {
            return (o is OutlinerObject);
        }

        public override bool  IsValidDropTarget(IDataObject dragData)
        {
            if (Tree == null || Tree.ListMode != OutlinerListMode.Hierarchy)
                return false;
            else
 	            return base.IsValidDropTarget(dragData);
        }


        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
                return DragDropEffects.Link;
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

            Boolean dispatchUngroupEvent = false;
            Int32 i = 0;
            foreach(OutlinerNode n in droppedNodes)
            {
                if (((OutlinerObject)n).IsGroupMember)
                    dispatchUngroupEvent = true;

                Tree.LinkObject((OutlinerObject)n, Data.Handle, ((OutlinerObject)n).IsGroupMember, false);

                droppedNodeHandles[i] = ((OutlinerObject)n).Handle;
                i++;
            }

            if (dispatchUngroupEvent)
            {
                Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(droppedNodeHandles, Data.Handle, false, true));
                Int32[] childHandles = getChildHandles(droppedNodes);
                if (childHandles.Length > 0)
                    Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(childHandles, Data.Handle, false, false));
            }
            else
                Tree.RaiseObjectLinkedEvent(new NodeLinkedEventArgs(droppedNodeHandles, Data.Handle));


            return true;
        }
    }
}
