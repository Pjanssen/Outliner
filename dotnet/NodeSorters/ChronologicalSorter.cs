using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Windows.Forms;
using Outliner.Scene;
using System.Runtime.InteropServices;

namespace Outliner.NodeSorters
{
    public class ChronologicalSorter : IComparer
    {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public int Compare(object x, object y)
        {
            if ((x is TreeNode) && (y is TreeNode))
            {
                Object xTag = ((TreeNode)x).Tag;
                Object yTag = ((TreeNode)y).Tag;

                if ((xTag is OutlinerNode) && (yTag is OutlinerNode))
                {
                    if ((xTag is OutlinerObject) && (yTag is OutlinerObject))
                        return ((OutlinerObject)xTag).ObjectNr - ((OutlinerObject)yTag).ObjectNr;
                    else
                        return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
                }
            }

            return 0;
        }
    }
}
