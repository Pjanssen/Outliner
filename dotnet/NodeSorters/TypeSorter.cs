using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.NodeSorters
{
    public class TypeSorter : IComparer
    {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public int Compare(object x, object y)
        {
            if ((x is TreeNode) && (y is TreeNode))
            {
                Object xTag = ((TreeNode)x).Tag;
                Object yTag = ((TreeNode)y).Tag;

                if ((xTag is OutlinerObject) && (yTag is OutlinerObject))
                {
                    OutlinerObject nodeX = (OutlinerObject)xTag;
                    OutlinerObject nodeY = (OutlinerObject)yTag;

                    if (nodeX.SuperClass != nodeY.SuperClass)
                        return StrCmpLogicalW(nodeX.SuperClass, nodeY.SuperClass);
                    else if (nodeX.Class != nodeY.Class)
                        return StrCmpLogicalW(nodeX.Class, nodeY.Class);
                    else
                        return StrCmpLogicalW(nodeX.Name, nodeY.Name);
                }
                else if ((xTag is OutlinerNode) && (yTag is OutlinerNode))
                    return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
                
            }

            return 0;
        }
    }
}
