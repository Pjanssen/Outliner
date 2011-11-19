using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner.Scene;
using Outliner.Controls.TreeViewModes;

namespace Outliner.Controls.DragDropHandlers
{
public class LayerDragDropHandler : DragDropHandler
{
    public LayerDragDropHandler(TreeView tree, OutlinerLayer layer)
        : base(tree, null)
    {
        this.Data = layer;
    }

    public new OutlinerLayer Data { get; protected set; }

    public override bool AllowDrag { get { return !this.Data.IsDefaultLayer; } }

    public override bool IsValidDropTarget(IDataObject dragData) 
    {
        if (!(this.Tree.Mode is LayerMode))
            return false;

        List<TreeNodeData> nodeData = this.GetNodesFromDataObject(dragData);
        if (nodeData == null)
            return false;

        foreach (TreeNodeData tnData in nodeData)
        {
            if (!(tnData.OutlinerNode is OutlinerObject) && !(tnData.OutlinerNode is OutlinerLayer))
                return false;

            if (tnData.OutlinerNode == this.Data)
                return false;
        }

        return true;
    }

    public override DragDropEffects GetDragDropEffect(IDataObject dragData) 
    {
        if (this.IsValidDropTarget(dragData))
            return DragDropEffects.Copy;
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

        foreach (TreeNodeData tnData in nodeData)
        {
            if (tnData.OutlinerNode != null)
                tnData.OutlinerNode.Layer = this.Data;
        }
    }
}
}
