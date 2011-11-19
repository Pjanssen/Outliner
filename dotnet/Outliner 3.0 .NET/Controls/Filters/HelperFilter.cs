using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class HelperFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is OutlinerObject))
                return FilterResult.Show;

            if (((OutlinerObject)n).SuperClass == MaxTypes.Helper)
                return FilterResult.Hide;
            else if (((OutlinerObject)n).Class == MaxTypes.Target) //Target objects are GeometryClass objects curiously enough.
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}
