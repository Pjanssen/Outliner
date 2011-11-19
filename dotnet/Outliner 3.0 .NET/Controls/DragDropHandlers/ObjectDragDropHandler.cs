using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;
using Outliner.Controls.TreeViewModes;

namespace Outliner.Controls.DragDropHandlers
{
public class ObjectDragDropHandler : DragDropHandler
{
    public ObjectDragDropHandler(TreeView tree, OutlinerNode n) : base(tree, n) { }

    public override bool AllowDrag { get { return true; } }

    public override bool IsValidDropTarget(IDataObject dragData) 
    {
        if (!(this.Tree.Mode is HierarchyMode))
            return false;

        List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
        if (nodeData == null)
            return false;

        foreach (TreeNodeData tnData in nodeData)
        {
            if (!(tnData.OutlinerNode is OutlinerObject))
                return false;

            if (tnData.OutlinerNode == this.Data)
                return false;
        }

        return true;
    }

    public override DragDropEffects GetDragDropEffect(IDataObject dragData) 
    {
        if (this.IsValidDropTarget(dragData))
            return DragDropEffects.Link;
        else
            return TreeView.DragDropEffectsNone;
    }

    public override void HandleDrop(IDataObject dragData) 
    {
        if (!this.IsValidDropTarget(dragData))
            return;

        List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
        if (nodeData == null)
            return;

        this.Tree.Scene.BeginUpdate();

        foreach (TreeNodeData tnData in nodeData)
        {
            if (tnData.OutlinerNode != null)
                tnData.OutlinerNode.Parent = this.Data;
        }

        this.Tree.Scene.EndUpdate();
    }
}
}
