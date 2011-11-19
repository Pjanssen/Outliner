using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.Controls.NodeSorters
{
    public class TypeSorter : OutlinerNodeSorter
    {
        public TypeSorter(Outliner.Controls.TreeView treeView) : base(treeView) { }

        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public override int Compare(TreeNode x, TreeNode y)
        {
            OutlinerNode nX = TreeNodeData.GetOutlinerNode(x);
            OutlinerNode nY = TreeNodeData.GetOutlinerNode(y);

            if (nX == null || nY == null)
                return 0;

            if (nX is OutlinerObject && nY is OutlinerObject)
            {
                OutlinerObject oX = (OutlinerObject)nX;
                OutlinerObject oY = (OutlinerObject)nY;

                if (oX.SuperClass != oY.SuperClass)
                    return StrCmpLogicalW(oX.SuperClass, oY.SuperClass);
                else if (oX.Class != oY.Class)
                    return StrCmpLogicalW(oX.Class, oY.Class);
            }

            return StrCmpLogicalW(nX.Name, nY.Name);
        }
    }
}
