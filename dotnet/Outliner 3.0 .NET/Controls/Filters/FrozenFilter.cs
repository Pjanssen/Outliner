using Outliner.Scene;
using System;

namespace Outliner.Controls.Filters
{
    public class FrozenFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is IDisplayable))
                return FilterResult.Show;

            IDisplayable layer = n.Layer as IDisplayable;

            if (((IDisplayable)n).IsFrozen || (layer != null && layer.IsFrozen))
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}