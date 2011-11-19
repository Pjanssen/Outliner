using System;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
    public class ChronologicalSorter : OutlinerNodeSorter
    {
        public ChronologicalSorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public override int Compare(TreeNode x, TreeNode y)
        {
            OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
            OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

            if (nX == null || nY == null)
                return 0;

            return nX.Handle - nY.Handle;
        }
    }
}
