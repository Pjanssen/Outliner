using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class ParticleFilter : NodeFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            if (!(n is OutlinerObject))
                return FilterResult.Show;

            OutlinerObject o = (OutlinerObject)n;

            if (o.SuperClass != MaxTypes.Geometry && o.SuperClass != MaxTypes.Helper)
                return FilterResult.Show;

            if (o.Class == MaxTypes.PfSource || o.Class == MaxTypes.PCloud || o.Class == MaxTypes.PArray || 
                o.Class == MaxTypes.PBlizzard || o.Class == MaxTypes.PSpray || o.Class == MaxTypes.PSuperSpray || 
                o.Class == MaxTypes.PSnow || o.Class == MaxTypes.PBirthTexture || o.Class == MaxTypes.PSpeedByIcon ||
                o.Class == MaxTypes.PGroupSelection || o.Class == MaxTypes.PFindTarget || 
                o.Class == MaxTypes.PInitialState || o.Class == MaxTypes.ParticlePaint)
            {
                return FilterResult.Hide;
            }
            else
                return FilterResult.Show;
        }
    }
}
