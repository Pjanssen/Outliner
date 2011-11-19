using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.Windows.Forms;

namespace Outliner
{

    /// <summary>
    /// Collection of selected nodes.
    /// </summary>
    public class NodesCollection : CollectionBase
    {
        #region Events

        /// <summary>
        /// Event fired when a tree node has been added to the collection.
        /// </summary>
        internal event TreeNodeEventHandler TreeNodeAdded;

        /// <summary>
        /// Event fired when a tree node has been removed to the collection.
        /// </summary>
        internal event TreeNodeEventHandler TreeNodeRemoved;

        /// <summary>
        /// Event fired when a tree node has been inserted to the collection.
        /// </summary>
        internal event TreeNodeEventHandler TreeNodeInserted;

        /// <summary>
        /// Event fired the collection has been cleared.
        /// </summary>
        internal event EventHandler SelectedNodesCleared;

        #endregion

        #region CollectionBase members

        /// <summary>
        /// Gets tree node at specified index.
        /// </summary>
        public TreeNode this[int index]
        {
            get { return ((TreeNode)List[index]); }
        }

        /// <summary>
        /// Adds a tree node to the collection.
        /// </summary>
        /// <param name="treeNode">Tree node to add.</param>
        /// <returns>The position into which the new element was inserted.</returns>
        public int Add(TreeNode treeNode)
        {
            if (TreeNodeAdded != null)
                TreeNodeAdded(treeNode);

            return List.Add(treeNode);
        }

        /// <summary>
        /// Inserts a tree node at specified index.
        /// </summary>
        /// <param name="index">The position into which the new element has to be inserted.</param>
        /// <param name="treeNode">Tree node to insert.</param>
        public void Insert(int index, TreeNode treeNode)
        {
            if (TreeNodeInserted != null)
                TreeNodeInserted(treeNode);

            List.Add(treeNode);
        }

        /// <summary>
        /// Removed a tree node from the collection.
        /// </summary>
        /// <param name="treeNode">Tree node to remove.</param>
        public void Remove(TreeNode treeNode)
        {
            if (TreeNodeRemoved != null)
                TreeNodeRemoved(treeNode);

            List.Remove(treeNode);
        }

        /// <summary>
        /// Determines whether treenode belongs to the collection.
        /// </summary>
        /// <param name="treeNode">Tree node to check.</param>
        /// <returns>True if tree node belongs to the collection, false if not.</returns>
        public bool Contains(TreeNode treeNode)
        {
            return List.Contains(treeNode);
        }

        /// <summary>
        /// Gets index of tree node in the collection.
        /// </summary>
        /// <param name="treeNode">Tree node to get index of.</param>
        /// <returns>Index of tree node in the collection.</returns>
        public int IndexOf(TreeNode treeNode)
        {
            return List.IndexOf(treeNode);
        }

        #endregion

        #region OnClear

        /// <summary>
        /// Occurs when collection is being cleared.
        /// </summary>
        protected override void OnClear()
        {
            if (SelectedNodesCleared != null)
                SelectedNodesCleared(this, EventArgs.Empty);

            base.OnClear();
        }
        #endregion


        public bool containsChild(TreeNode treeNode)
        {
            foreach (TreeNode n in this.List)
            {
                if (containsChildRec(n, treeNode)) return true;
            }
            return false;
        }


        protected bool containsChildRec(TreeNode node, TreeNode t)
        {
            if (node.Nodes.Contains(t)) return true;
            bool hasChild = false;
            foreach (TreeNode n in node.Nodes)
            {
                if (this.containsChildRec(n, t)) hasChild = true;
            }
            return hasChild;
        }


        public bool isParentOfNodeInSel(TreeNode node)
        {
            foreach (TreeNode n in this.List)
            {
                if (n.Parent == node)
                {
                    return true;
                }
            }
            return false;
        }

    }

}
