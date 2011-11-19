using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;
using Outliner.Controls.Filters;

namespace Outliner.Controls.TreeViewModes
{
public class MaterialMode : TreeViewMode
{
    public override void SwitchFromMode(TreeView tree) 
    {
        if (tree.Filters != null)
            tree.Filters.Remove(typeof(UnassignedMaterialFilter));

        base.SwitchFromMode(tree);
    }
    public override void SwitchToMode(TreeView tree) 
    {
        if (tree.Filters != null)
        {
            tree.Filters = new FlatListNodeFilterCollection(tree.Filters);
            if (!tree.Filters.Contains(typeof(UnassignedMaterialFilter)))
                tree.Filters.Add(new UnassignedMaterialFilter());
        }

        base.SwitchToMode(tree);
    }


    protected override bool addChildNodesToTree(OutlinerNode n) 
    {
        return n is OutlinerMaterial && n.ChildNodesCount > 0;
    }

    public override void FillTree(TreeView tree, OutlinerScene scene) 
    {
        if (tree == null)
            return;

        tree.BeginUpdate();

        tree.Clear();

        this.addNodesToTreeSorted(tree, scene.RootMaterials, tree.Nodes);

        tree.EndUpdate();
    }
    public override void AddNodeToTree(TreeView tree, OutlinerNode node) 
    {
        if (tree == null || node == null || !(node is OutlinerObject || node is OutlinerMaterial))
            return;

        TreeNodeCollection parentNodeCollection = null;
        if (node is OutlinerMaterial)
        {
            if (node.IsRootNode)
                parentNodeCollection = tree.Nodes;
            else
            {
                TreeNode parentNode = this.GetTreeNode(node.Parent);
                if (parentNode != null)
                    parentNodeCollection = parentNode.Nodes;
            }
        }
        else if (node is OutlinerObject)
        {
            TreeNode parentNode = this.GetTreeNode(node.Material);
            if (parentNode != null)
                parentNodeCollection = parentNode.Nodes;
        }

        if (parentNodeCollection != null)
        {
            TreeNode tn = tree.CreateTreeNode(node);
            parentNodeCollection.Add(tn);
            if (this.addChildNodesToTree(node))
            {
                foreach (OutlinerNode cn in node.ChildNodes)
                    this.AddNodeToTree(tree, cn);
            }
            tree.AddToSortQueue(parentNodeCollection);
        }
    }
    public override void NodeParentChanged(TreeView tree, OutlinerNode node) 
    {
        if (!(node is OutlinerMaterial))
            return;
    }
    public override void NodeLayerChanged(TreeView tree, OutlinerNode node) { }
    public override void NodeMaterialChanged(TreeView tree, OutlinerNode node) { }
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
            contextMenu.HideLayerItems();

        contextMenu.Show(tree, location);

        return contextMenu;
    }
}
}
