using System;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
    public class MaterialSorter : OutlinerNodeSorter
    {
        public MaterialSorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public override int Compare(TreeNode x, TreeNode y)
        {
            OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
            OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

            if (nX == null || nY == null)
                return 0;

            if (nX.MaterialHandle == nY.MaterialHandle)
                return StrCmpLogicalW(nX.Name, nY.Name);
            else
            {
                OutlinerNode matX = nX.Material;
                OutlinerNode matY = nY.Material;

                if (matX != null && matY != null)
                    return StrCmpLogicalW(matX.Name, matY.Name);
                else
                    return StrCmpLogicalW(nX.Name, nY.Name);
            }
        }
    }
}
