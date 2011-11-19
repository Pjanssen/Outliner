using Outliner.Scene;
using System;

namespace Outliner.Controls.Filters
{
    public class XRefFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (n is OutlinerObject && ((OutlinerObject)n).Class == MaxTypes.XrefObject)
                return FilterResult.Hide;
            else if (n is OutlinerMaterial && ((OutlinerMaterial)n).Type == MaxTypes.XrefMaterial)
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}
