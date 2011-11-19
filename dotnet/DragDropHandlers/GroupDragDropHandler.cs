using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner.DragDropHandlers
{
    public class GroupDragDropHandler : ObjectDragDropHandler
    {
        public GroupDragDropHandler(Outliner.TreeView tree, OutlinerObject data) : base(tree, data) { }


        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
            {
                // TODO Check issue with Control.ModifierKeys not updating when key is being pressed during drag on group.
                if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                    return DragDropEffects.Link;
                else
                    return DragDropEffects.Copy;
            }
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

                Boolean group = (Control.ModifierKeys & Keys.Control) != Keys.Control;
                Int32 i = 0;
                foreach (OutlinerNode n in droppedNodes)
                {
                    Tree.LinkObject((OutlinerObject)n, Data.Handle, group, true);

                    droppedNodeHandles[i] = ((OutlinerObject)n).Handle;
                    i++;
                }

                if (group)
                {
                    Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(droppedNodeHandles, Data.Handle, true, true));
                    Int32[] childHandles = getChildHandles(droppedNodes);
                    if (childHandles.Length > 0)
                        Tree.RaiseObjectGroupedEvent(new NodeGroupedEventArgs(childHandles, Data.Handle, true, false));
                }
                else
                    Tree.RaiseObjectLinkedEvent(new NodeLinkedEventArgs(droppedNodeHandles, Data.Handle));

                return true;
            }
            return false;
        }
    }
}