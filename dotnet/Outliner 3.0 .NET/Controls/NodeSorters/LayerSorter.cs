using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
    public class LayerSorter : OutlinerNodeSorter
    {
        public LayerSorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public override int Compare(TreeNode x, TreeNode y)
        {
            OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
            OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

            if (nX == null || nY == null)
                return 0;

            OutlinerNode layerX = nX.Layer;
            OutlinerNode layerY = nY.Layer;

            if (layerX != null && layerY != null && layerX != layerY)
                return StrCmpLogicalW(layerX.Name, layerY.Name);

            return StrCmpLogicalW(nX.Name, nY.Name);
        }
    }
}
