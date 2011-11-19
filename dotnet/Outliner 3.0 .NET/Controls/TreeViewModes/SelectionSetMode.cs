using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Controls.Filters;
using Outliner.Scene;
using System.Windows.Forms;
using Outliner.Controls.DragDropHandlers;

namespace Outliner.Controls.TreeViewModes
{
    public class SelectionSetMode : TreeViewMode
    {
        new protected Dictionary<OutlinerNode, List<TreeNode>> _treeNodes;

        public SelectionSetMode()
        {
            _treeNodes = new Dictionary<OutlinerNode, List<TreeNode>>();
        }

        public override void SwitchToMode(TreeView tree) 
        {
            tree.Filters = new FlatListNodeFilterCollection(tree.Filters);

            base.SwitchToMode(tree);
        }

        override protected TreeNode createTreeNode(TreeView tree, OutlinerNode n, TreeNodeData tnData)
        {
            if (tree == null || n == null || tnData == null)
                return null;

            TreeNode tn = tree.CreateTreeNode(n, tnData);

            List<TreeNode> tNodes;
            if (!_treeNodes.ContainsKey(n))
            {
                tNodes = new List<TreeNode>();
                _treeNodes.Add(n, tNodes);
            }
            else
                tNodes = _treeNodes[n];
            
            tNodes.Add(tn);

            return tn;
        }
        override public TreeNode GetTreeNode(OutlinerNode n) 
        {
            if (n == null)
                return null;

            List<TreeNode> tNodes;
            _treeNodes.TryGetValue(n, out tNodes);

            if (tNodes != null && tNodes.Count != 0)
                return tNodes[0];
            else
                return null;
        }
        /*
        override public TreeNode GetTreeNode(Int32 handle) 
        {
            OutlinerNode n = 
            List<TreeNode> tNodes;
            _treeNodes.TryGetValue(handle, out tNodes);

            if (tNodes != null && tNodes.Count != 0)
                return tNodes[0];
            else
                return null;
        }
        */
        public List<TreeNode> GetTreeNodes(OutlinerNode n)
        {
            if (n == null)
                return null;

            List<TreeNode> tNodes = null;
            _treeNodes.TryGetValue(n, out tNodes);

            return tNodes;
        }
        public List<TreeNode> GetTreeNodes(TreeView tree, Int32 handle) 
        {
            if (tree.Scene == null)
                return null;

            OutlinerNode n = tree.Scene.GetNodeByHandle(handle);
            return this.GetTreeNodes(n);
        }
    

        protected override bool addChildNodesToTree(OutlinerNode n) 
        {
            return n is SelectionSet;
        }

        public override void FillTree(TreeView tree, OutlinerScene scene)
        {
            if (tree == null)
                return;

            tree.BeginUpdate();

            tree.Clear();

            this.addNodesToTreeSorted(tree, scene.SelectionSets.OfType<OutlinerNode>().ToList(), tree.Nodes);

            tree.EndUpdate();
        }
        public override void AddNodeToTree(TreeView tree, OutlinerNode node)
        {
            //throw new NotImplementedException();
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
            TreeNode selSetTn = this.GetTreeNode(s);
            if (selSetTn == null)
                return;

            TreeNode tn = this.createTreeNode(tree, n, new TreeNodeData(n, DragDropHandler.GetDragDropHandler(tree, n), FilterResult.Show));

            selSetTn.Nodes.Add(tn);
            tree.AddToSortQueue(tn);
        }
        public override void SelectionSetNodeRemoved(TreeView tree, SelectionSet s, OutlinerNode n) 
        {
            TreeNode tn = this.GetTreeNode(n);
            if (tn == null)
                return;

            tn.Remove();
        }

        public override void SetSelection(TreeView tree, int[] selHandles) 
        {
            tree.SelectAllNodes(false);
            foreach (Int32 handle in selHandles)
            {
                List<TreeNode> tNodes = this.GetTreeNodes(tree, handle);
                if (tNodes == null)
                    continue;

                foreach (TreeNode tn in tNodes)
                    tree.SelectNode(tn, true);
            }
        }
        public override void SetSelection(TreeView tree, List<OutlinerNode> selNodes) 
        {
            tree.SelectAllNodes(false);
            foreach (OutlinerNode n in selNodes)
            {
                List<TreeNode> tNodes = this.GetTreeNodes(n);
                if (tNodes == null)
                    continue;

                foreach (TreeNode tn in tNodes)
                    tree.SelectNode(tn, true);
            }
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
