using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using Outliner.Controls.Filters;
using System.Windows.Forms;
using System.Drawing;
using Outliner.Controls.DragDropHandlers;

namespace Outliner.Controls.TreeViewModes
{
    public abstract class TreeViewMode
    {
        protected Dictionary<Int32, TreeNode> _treeNodes;

        public TreeViewMode() 
        {
            _treeNodes = new Dictionary<Int32, TreeNode>();
        }


        protected virtual TreeNode createTreeNode(TreeView tree, OutlinerNode n, TreeNodeData tnData) 
        {
            if (tree == null || n == null || tnData == null)
                return null;

            TreeNode tn = tree.CreateTreeNode(n, tnData);
            _treeNodes.Add(n.Handle, tn);
            
            return tn;
        }
        public virtual TreeNode GetTreeNode(OutlinerNode n) 
        {
            if (n == null)
                return null;

            TreeNode tn;
            _treeNodes.TryGetValue(n.Handle, out tn);
            return tn;
        }
        public virtual TreeNode GetTreeNode(Int32 handle) 
        {
            TreeNode tn;
            _treeNodes.TryGetValue(handle, out tn);
            return tn;
        }
        

        protected virtual Boolean addChildNodesToTree(OutlinerNode n) 
        {
            return n.ChildNodesCount > 0;
        }

        protected virtual void addNodesToTreeSorted(TreeView tree, List<OutlinerNode> nodes, TreeNodeCollection parentCollection) 
        {
            if (tree == null || nodes == null || parentCollection == null)
                return;

            List<TreeNode> treeNodes = new List<TreeNode>(nodes.Count);

            foreach (OutlinerNode n in nodes)
            {
                TreeNodeData tnData = new TreeNodeData(n, DragDropHandler.GetDragDropHandler(tree, n), tree.Filters.ShowNode(n));
                TreeNode tn = this.createTreeNode(tree, n, tnData);
                tnData.TreeNode = tn;

                if ((tnData.FilterResult & FilterResult.Hide) != FilterResult.Hide)
                {
                    if (this.addChildNodesToTree(n))
                        this.addNodesToTreeSorted(tree, n.ChildNodes, tn.Nodes);

                    treeNodes.Add(tn);
                }
                else
                    this._filteredTreeNodes.Add(tn);
            }
            treeNodes.Sort(tree.NodeSorter);
            parentCollection.AddRange(treeNodes.ToArray());
        }
        
        /*
         protected OutlinerNode getHighestParentNodeToAdd(OutlinerNode o) 
        {
            if (ListMode == OutlinerListMode.Layer)
                return o;
            else
            {
                OutlinerNode parentNode = o;
                while (parentNode != null && !parentNode.IsRootNode && !_treeNodes.ContainsKey(parentNode))
                {
                    parentNode = parentNode.Parent;
                }

                return parentNode;
            }
        }
         */

        public virtual void SwitchFromMode(TreeView tree) { }
        public virtual void SwitchToMode(TreeView tree) 
        {
            if (tree.Scene != null)
            {
                tree.BeginUpdate();

                tree.Clear();
                this.FillTree(tree, tree.Scene);
                
                tree.EndUpdate();
            }
        }

        public virtual void Clear() 
        {
            _treeNodes.Clear();
        }

        public abstract void FillTree(TreeView tree, OutlinerScene scene);
        public abstract void AddNodeToTree(TreeView tree, OutlinerNode node);
        public abstract void NodeParentChanged(TreeView tree, OutlinerNode node);
        public abstract void NodeLayerChanged(TreeView tree, OutlinerNode node);
        public abstract void NodeMaterialChanged(TreeView tree, OutlinerNode node);
        public virtual void NodeHiddenChanged(TreeView tree, OutlinerNode node)
        {
            if (tree == null)
                return;

            TreeNode tn = this.GetTreeNode(node);
            if (tn == null)
                return;

            tree.SetNodeColorAuto(tn);
            tree.InvalidateTreeNode(tn);
        }
        public virtual void NodeFrozenChanged(TreeView tree, OutlinerNode node) 
        {
            if (tree == null)
                return;

            TreeNode tn = this.GetTreeNode(node);
            if (tn == null)
                return;

            tree.SetNodeColorAuto(tn);
            tree.InvalidateTreeNode(tn);
        }
        public virtual void NodeBoxModeChanged(TreeView tree, OutlinerNode node) 
        {
            if (tree == null)
                return;

            TreeNode tn = this.GetTreeNode(node);
            if (tn == null)
                return;

            tree.InvalidateTreeNode(tn);
        }
        public virtual void NodeNameChanged(TreeView tree, OutlinerNode node) 
        {
            TreeNode tn = this.GetTreeNode(node);
            if (tn == null)
                return;

            tree.BeginUpdate();

            tn.Text = node.DisplayName;

            tree.AddToSortQueue(tn);

            tree.EndUpdate();
        }
        public abstract void SelectionSetNodeAdded(TreeView tree, SelectionSet s, OutlinerNode n);
        public abstract void SelectionSetNodeRemoved(TreeView tree, SelectionSet s, OutlinerNode n);

        public abstract OutlinerContextMenu ShowContextMenu(TreeView tree, Point location);

        public virtual void SetSelection(TreeView tree, Int32[] selHandles)
        {
            tree.SelectAllNodes(false);

            foreach (Int32 handle in selHandles)
            {
                TreeNode tn = this.GetTreeNode(handle);
                if (tn != null)
                    tree.SelectNode(tn, true);
            }
        }
        public virtual void SetSelection(TreeView tree, List<OutlinerNode> selNodes)
        {
            tree.SelectAllNodes(false);

            foreach (OutlinerNode n in selNodes)
            {
                TreeNode tn = this.GetTreeNode(n);
                if (tn != null)
                    tree.SelectNode(tn, true);
            }
        }


        public virtual void FiltersEnabled(TreeView tree) 
        {

        }
        public virtual void FiltersCleared(TreeView tree) 
        {
            if (!tree.Filters.Enabled)
                return;
        }
        public virtual void FilterAdded(TreeView tree, NodeFilter filter) 
        {
            if (tree == null || tree.Filters == null || !tree.Filters.Enabled || tree.Scene == null)
                return;

            tree.BeginUpdate();

            tree.Clear();
            this.FillTree(tree, tree.Scene);
            //this.FilterNodes(tree, tree.Nodes, filter);
            
            tree.EndUpdate();
        }
        public virtual void FilterRemoved(TreeView tree, NodeFilter filter) 
        {
            if (!tree.Filters.Enabled && !tree.Filters.HasPermanentFilters)
                return;

            tree.BeginUpdate();

            List<TreeNode> nodesToAdd = new List<TreeNode>();

            foreach (TreeNode tn in _filteredTreeNodes)
            {
                OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
                if (n == null)
                    continue;
                
                if ((tree.Filters.ShowNode(n) & FilterResult.Hide) != FilterResult.Hide)
                {
                    nodesToAdd.Add(tn);
                }
            }

            foreach (TreeNode tn in nodesToAdd)
            {
                OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
                if (n == null)
                    continue;

                TreeNodeCollection parentNodeCollection = null;
                if (n.IsRootNode)
                    parentNodeCollection = tree.Nodes;
                else
                {
                    TreeNode parentNode = this.GetTreeNode(n.Parent);
                    if (parentNode != null)
                        parentNodeCollection = parentNode.Nodes;
                }

                if (parentNodeCollection != null)
                {
                    parentNodeCollection.Add(tn);
                    tree.AddToSortQueue(parentNodeCollection);
                    _filteredTreeNodes.Remove(tn);
                }
            }

            nodesToAdd.Clear();

            tree.EndUpdate();
        }
        public virtual void FilterChanged(TreeView tree, NodeFilter filter) 
        {
            if (!tree.Filters.Enabled)
                return;

            tree.BeginUpdate();

            tree.Clear();
            tree.FillTree(tree.Scene);

            tree.EndUpdate();
        }

        protected List<TreeNode> _filteredTreeNodes = new List<TreeNode>();
        protected void FilterNodes(TreeView tree, TreeNodeCollection nodes, NodeFilter filter)
        {
            List<TreeNode> nodesToRemove = new List<TreeNode>();

            this.AddNodesToRemove(ref nodesToRemove, tree, nodes, filter);

            foreach (TreeNode tn in nodesToRemove)
            {
                tn.Remove();
                _filteredTreeNodes.Add(tn);
            }

            nodesToRemove.Clear();
        }

        protected void AddNodesToRemove(ref List<TreeNode> nodesToRemove, TreeView tree, TreeNodeCollection nodes, NodeFilter filter)
        {
            foreach (TreeNode tn in nodes)
            {
                TreeNodeData tnData = TreeNodeData.GetTreeNodeData(tn);
                if (tnData == null || tnData.OutlinerNode == null)
                    continue;

                FilterResult filterResult = tree.Filters.ShowNode(tn, tnData, filter);

                if ((filterResult & FilterResult.Hide) == FilterResult.Hide)
                {
                    nodesToRemove.Add(tn);
                    tnData.FilterResult = FilterResult.Hide;
                }
                else
                    this.FilterNodes(tree, tn.Nodes, filter);
            }
        }
    }
}
