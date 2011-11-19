using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class HiddenFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is IDisplayable))
                return FilterResult.Show;

            IDisplayable layer = n.Layer as IDisplayable;

            if (((IDisplayable)n).IsHidden || (layer != null && layer.IsHidden))
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}