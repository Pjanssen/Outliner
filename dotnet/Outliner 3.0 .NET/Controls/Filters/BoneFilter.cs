using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class BoneFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is OutlinerObject))
                return FilterResult.Show;

            OutlinerObject o = (OutlinerObject)n;

            if (o.SuperClass != MaxTypes.Geometry)
                return FilterResult.Show;

            if (o.Class == MaxTypes.Bone || o.Class == MaxTypes.Biped) //TODO check CAT bone type
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }
}
