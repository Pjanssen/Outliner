using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class UnassignedMaterialFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is OutlinerMaterial))
                return FilterResult.Show;

            if (((OutlinerMaterial)n).IsUnassigned && ((OutlinerMaterial)n).ChildNodesCount == 0)
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}