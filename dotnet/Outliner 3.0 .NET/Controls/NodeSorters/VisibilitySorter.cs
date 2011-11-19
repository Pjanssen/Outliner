using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
public class VisibilitySorter : OutlinerNodeSorter
{
    public VisibilitySorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

    [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
    static extern int StrCmpLogicalW(String x, String y);

    public override int Compare(TreeNode x, TreeNode y)
    {
        OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
        OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

        if (nX == null || nY == null)
            return 0;

        if (nX is IDisplayable && nY is IDisplayable)
        {
            if (((IDisplayable)nX).IsHidden != ((IDisplayable)nY).IsHidden)
            {
                if (!((IDisplayable)nX).IsHidden)
                    return -1;
                else
                    return 1;
            }
        }

        return StrCmpLogicalW(nX.Name, nY.Name);
    }
}
}
