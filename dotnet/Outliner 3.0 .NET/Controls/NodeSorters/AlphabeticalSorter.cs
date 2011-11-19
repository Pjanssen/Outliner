using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
    public class AlphabeticalSorter : OutlinerNodeSorter
    {
        public AlphabeticalSorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public override int Compare(TreeNode x, TreeNode y)
        {
            OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
            OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

            if (nX == null || nY == null)
                return 0;

            if ((nX is OutlinerLayer) == (nY is OutlinerLayer))
                return StrCmpLogicalW(nX.Name, nY.Name);
            else if (!(nX is OutlinerLayer))
                return 1;
            else
                return -1;
        }
    }
}
