using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner.Controls.TreeViewModes;
using Outliner.Scene;

namespace Outliner.Controls.DragDropHandlers
{
    public class TreeDragDropHandler : DragDropHandler
    {
        public TreeDragDropHandler(TreeView tree) : base(tree, null) { }

        public override bool AllowDrag { get { return false; } }

        public override bool IsValidDropTarget(System.Windows.Forms.IDataObject dragData)
        {
            List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
            if (nodeData == null)
                return false;

            foreach (TreeNodeData tnData in nodeData)
            {
                if (this.Tree.Mode is HierarchyMode || this.Tree.Mode is MaterialMode)
                {
                    if (!(tnData.OutlinerNode is OutlinerObject)) 
                        return false;
                }
                else if (this.Tree.Mode is LayerMode)
                {
                    if (!(tnData.OutlinerNode is OutlinerLayer)) 
                        return false;
                }
                else 
                    return false;
            }
            return true;
        }

        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (this.IsValidDropTarget(dragData))
                return DragDropEffects.Move;
            else
                return TreeView.DragDropEffectsNone;
        }

        public override void HandleDrop(System.Windows.Forms.IDataObject dragData)
        {
        }
    }
}
