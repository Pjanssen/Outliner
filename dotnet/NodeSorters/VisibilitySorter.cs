using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.NodeSorters
{
    public class VisibilitySorter : IComparer
    {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public int Compare(object x, object y)
        {
            if ((x is TreeNode) && (y is TreeNode))
            {
                Object xTag = ((TreeNode)x).Tag;
                Object yTag = ((TreeNode)y).Tag;

                if ((xTag is IHidable) && (yTag is IHidable))
                {
                    Boolean xHidden = ((IHidable)xTag).IsHidden;
                    Boolean yHidden = ((IHidable)yTag).IsHidden;

                    if (!xHidden && yHidden)
                        return -1;
                    else if (xHidden && !yHidden)
                        return 1;
                    else if ((xTag is OutlinerNode) && (yTag is OutlinerNode))
                        return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
                }
                else if ((xTag is OutlinerNode) && (yTag is OutlinerNode))
                    return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
            }

            return 0;
        }
    }
}
