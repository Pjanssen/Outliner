using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using Outliner.Controls;

namespace Outliner.Controls.NodeSorters
{
    public abstract class OutlinerNodeSorter : IComparer<System.Windows.Forms.TreeNode>
    {
        protected TreeView _treeView;

        public OutlinerNodeSorter(TreeView treeView)
        {
            _treeView = treeView;
        }

        public abstract int Compare(System.Windows.Forms.TreeNode x, System.Windows.Forms.TreeNode y);

    }
}
