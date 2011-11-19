using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.NodeSorters
{
    public class LayerSorter : IComparer
    {
        [DllImport("shlwapi.dll", CharSet = CharSet.Unicode, ExactSpelling = true)]
        static extern int StrCmpLogicalW(String x, String y);

        public int Compare(object x, object y)
        {
            if (!(x is TreeNode) || !(y is TreeNode))
                return 0;

            Object xTag = ((TreeNode)x).Tag;
            Object yTag = ((TreeNode)y).Tag;

            if (!(xTag is OutlinerNode) || !(yTag is OutlinerNode))
                return 0;

            if ((xTag is OutlinerObject) && (yTag is OutlinerObject))
            {
                OutlinerLayer layerX = ((OutlinerObject)xTag).Layer;
                OutlinerLayer layerY = ((OutlinerObject)yTag).Layer;

                if (layerX != null && layerY != null && layerX != layerY)
                {
                    return StrCmpLogicalW(layerX.Name, layerY.Name);
                }
                else
                    return StrCmpLogicalW(((OutlinerObject)xTag).Name, ((OutlinerObject)yTag).Name);
            }
            else
                return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
        }
    }
}
