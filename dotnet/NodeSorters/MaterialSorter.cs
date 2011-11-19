using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using Outliner.Scene;

namespace Outliner.NodeSorters
{
    public class MaterialSorter : IComparer
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
                    {
                        OutlinerObject objX = (OutlinerObject)xTag;
                        OutlinerObject objY = (OutlinerObject)yTag;

                        if (objX.MaterialHandle == objY.MaterialHandle)
                            return StrCmpLogicalW(objX.Name, objY.Name);
                        else
                        {
                            OutlinerMaterial matX = ((OutlinerObject)xTag).Material;
                            OutlinerMaterial matY = ((OutlinerObject)yTag).Material;

                            if (matX != null && matY != null)
                                return StrCmpLogicalW(matX.Name, matY.Name);
                        }
                    }

                    return StrCmpLogicalW(((OutlinerNode)xTag).Name, ((OutlinerNode)yTag).Name);
                }
            }

            return 0;
        }
    }
}
