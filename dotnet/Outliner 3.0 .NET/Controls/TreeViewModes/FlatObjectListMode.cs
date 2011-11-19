using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;
using Outliner.Controls.Filters;

namespace Outliner.Controls.TreeViewModes
{
public class FlatObjectListMode : TreeViewMode
{
    public override void SwitchToMode(TreeView tree)
    {
        tree.Filters = new FlatListNodeFilterCollection(tree.Filters);

        base.SwitchToMode(tree);
    }

    protected override bool addChildNodesToTree(OutlinerNode n)
    {
        return false;
    }

    public override void FillTree(TreeView tree, OutlinerScene scene)
    {
        if (tree == null)
            return;

        tree.BeginUpdate();

        tree.Clear();

        this.addNodesToTreeSorted(tree, scene.Nodes.Where(node => (node is OutlinerObject)).ToList<OutlinerNode>(), tree.Nodes);

        tree.EndUpdate();
    }
    public override void AddNodeToTree(TreeView tree, OutlinerNode node) 
    {
        if (tree == null || node == null || !(node is OutlinerObject))
            return;

        TreeNodeCollection parentNodeCollection = tree.Nodes;

        TreeNode tn = tree.CreateTreeNode(node);
        parentNodeCollection.Add(tn);

        tree.AddToSortQueue(parentNodeCollection);
    }
    public override void NodeParentChanged(TreeView tree, OutlinerNode node) 
    {
        //Changing node parent has no effect in this mode.
    }
    public override void NodeLayerChanged(TreeView tree, OutlinerNode node) 
    {
        //Changing node layer has no effect in this mode.
    }
    public override void NodeMaterialChanged(TreeView tree, OutlinerNode node) 
    {
        //Changing node material has no effect in this mode.
    }
    public override void SelectionSetNodeAdded(TreeView tree, SelectionSet s, OutlinerNode n) 
    {
        //Adding to selectionset has no effect in this mode.
    }
    public override void SelectionSetNodeRemoved(TreeView tree, SelectionSet s, OutlinerNode n) 
    {
        //Removing from selectionset has no effect in this mode.
    }

    public override OutlinerContextMenu ShowContextMenu(TreeView tree, System.Drawing.Point location)
    {
        OutlinerContextMenu contextMenu = new OutlinerContextMenu();
        if (tree.SelectedNodes.Count == 0)
            contextMenu.HideContextMenuSection();
        else
        {
            contextMenu.HideLayerItems();
            contextMenu.HideMaterialItems();
        }

        contextMenu.Show(tree, location);

        return contextMenu;
    }
}
}
