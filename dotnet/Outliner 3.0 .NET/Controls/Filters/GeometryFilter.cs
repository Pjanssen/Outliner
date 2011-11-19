using Outliner.Scene;

namespace Outliner.Controls.Filters
{
public class GeometryFilter : NodeFilter
{
    override public FilterResult ShowNode(OutlinerNode n)
    {
        if (!(n is OutlinerObject))
            return FilterResult.Show;

        OutlinerObject o = (OutlinerObject)n;

        if (o.SuperClass != MaxTypes.Geometry)
            return FilterResult.Show;

        if (o.Class == MaxTypes.Bone || o.Class == MaxTypes.Biped || o.Class == MaxTypes.PfSource || 
            o.Class == MaxTypes.PCloud || o.Class == MaxTypes.PArray || o.Class == MaxTypes.PBlizzard ||
            o.Class == MaxTypes.PSpray || o.Class == MaxTypes.PSuperSpray || o.Class == MaxTypes.PSnow)
        {
            return FilterResult.Show;
        }
        else
            return FilterResult.Hide;
    }
}
}
