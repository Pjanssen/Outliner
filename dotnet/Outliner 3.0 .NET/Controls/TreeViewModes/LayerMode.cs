﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;
using Outliner.Controls.Filters;

namespace Outliner.Controls.TreeViewModes
{
public class LayerMode : TreeViewMode
{
    public override void SwitchToMode(TreeView tree)
    {
        tree.Filters = new FlatListNodeFilterCollection(tree.Filters);

        base.SwitchToMode(tree);
    }


    protected override bool addChildNodesToTree(OutlinerNode n) 
    {
        return (n is OutlinerLayer && n.ChildNodesCount > 0);
    }
    
    public override void FillTree(TreeView tree, OutlinerScene scene) 
    {
        if (tree == null)
            return;

        tree.BeginUpdate();

        tree.Clear();

        this.addNodesToTreeSorted(tree, scene.RootLayers, tree.Nodes);

        tree.EndUpdate();
    }
    public override void AddNodeToTree(TreeView tree, OutlinerNode node) 
    {
        if (tree == null || node == null || !(node is OutlinerObject || node is OutlinerLayer))
            return;

        TreeNodeCollection parentNodeCollection = null;
        if (node is OutlinerLayer)
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
            TreeNode parentNode = this.GetTreeNode(node.Layer);
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
    public override void NodeParentChanged(TreeView tree, OutlinerNode node) { }
    public override void NodeLayerChanged(TreeView tree, OutlinerNode node) 
    {
        if (tree == null || node == null)
            return;

        TreeNode tn = this.GetTreeNode(node);

        TreeNodeCollection parentNodeCollection = null;
        if (node.LayerHandle == OutlinerScene.LayerRootHandle)
            parentNodeCollection = tree.Nodes;
        else
        {
            TreeNode parentNode = this.GetTreeNode(node.LayerHandle);
            if (parentNode != null)
                parentNodeCollection = parentNode.Nodes;
        }


        if (tn == null || parentNodeCollection == null)
            return;

        tn.Remove();
        parentNodeCollection.Add(tn);

        tree.AddToSortQueue(parentNodeCollection);
    }
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
            contextMenu.HideMaterialItems();

        contextMenu.Show(tree, location);

        return contextMenu;
    }
}
}
