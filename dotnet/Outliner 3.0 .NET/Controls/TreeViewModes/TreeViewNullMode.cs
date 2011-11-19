using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;

namespace Outliner.Controls.TreeViewModes
{
internal class TreeViewNullMode : TreeViewMode
{
    public override void FillTree(TreeView tree, OutlinerScene scene) { }
    public override void AddNodeToTree(TreeView tree, OutlinerNode node) { }
    public override void NodeParentChanged(TreeView tree, OutlinerNode node) { }
    public override void NodeLayerChanged(TreeView tree, OutlinerNode node) { }
    public override void NodeMaterialChanged(TreeView tree, OutlinerNode node) { }
    public override void SelectionSetNodeAdded(TreeView tree, SelectionSet s, OutlinerNode n) { }
    public override void SelectionSetNodeRemoved(TreeView tree, SelectionSet s, OutlinerNode n) { }

    public override OutlinerContextMenu ShowContextMenu(TreeView tree, System.Drawing.Point location) { return null; }
}
}
