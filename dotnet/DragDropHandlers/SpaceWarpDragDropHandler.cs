using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;

namespace Outliner.DragDropHandlers
{
    public class SpaceWarpDragDropHandler : ObjectDragDropHandler
    {
        public SpaceWarpDragDropHandler(Outliner.TreeView tree, OutlinerObject data) : base(tree, data) { }


        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
            {
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
                if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                    return base.ItemDropped(dragData);
                else
                {
                    OutlinerNode[] draggedNodes = GetNodesFromDataObject(dragData);
                    Int32[] draggedNodeHandles = new Int32[draggedNodes.Length];
                    for (int i = 0; i < draggedNodes.Length; i++)
                        draggedNodeHandles[i] = ((OutlinerObject)draggedNodes[i]).Handle;

                    Tree.RaiseSpaceWarpBoundEvent(new NodeLinkedEventArgs(draggedNodeHandles, Data.Handle));
                    return false; //Nodes haven't been moved -> return false;
                }
            }
            return false;
        }
    }
}
