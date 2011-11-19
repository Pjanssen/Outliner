using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner.Scene;
using Outliner.Controls.TreeViewModes;

namespace Outliner.Controls.DragDropHandlers
{
public class SelectionSetDragDropHandler : DragDropHandler
{
    public SelectionSetDragDropHandler(TreeView tree, SelectionSet selSet)
        : base(tree, null)
    {
        this.Data = selSet;
    }

    public new SelectionSet Data { get; protected set; }

    public override bool AllowDrag { get { return false; } }

    public override bool IsValidDropTarget(IDataObject dragData) 
    {
        if (!(this.Tree.Mode is SelectionSetMode))
            return false;

        List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
        if (nodeData == null)
            return false;

        foreach (TreeNodeData tnData in nodeData)
        {
            if (this.Data.CanAddNode(tnData.OutlinerNode))
                return true;
        }

        return false;
    }

    public override DragDropEffects GetDragDropEffect(IDataObject dragData) 
    {
        if (this.IsValidDropTarget(dragData))
        {
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                return DragDropEffects.Copy;
            else
                return DragDropEffects.Move;
        }
        else
            return TreeView.DragDropEffectsNone;
    }

    public override void HandleDrop(IDataObject dragData)
    {
        if (!this.IsValidDropTarget(dragData))
            return;

        this.Tree.BeginUpdate();

        List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
        if (nodeData == null)
            return;

        foreach (TreeNodeData tnData in nodeData)
        {
            if ((Control.ModifierKeys & Keys.Control) != Keys.Control)
            {
                if (tnData.TreeNode != null && tnData.TreeNode.Parent != null && tnData.TreeNode.Parent.Tag is TreeNodeData)
                {
                    TreeNodeData parentData = (TreeNodeData)tnData.TreeNode.Parent.Tag;
                    if (parentData.OutlinerNode is SelectionSet)
                        ((SelectionSet)parentData.OutlinerNode).RemoveNode(tnData.OutlinerNode);
                }
            }

            this.Data.AddNode(tnData.OutlinerNode);
        }

        this.Tree.EndUpdate();
    }
}
}
