using Outliner.Scene;
using System;

namespace Outliner.Controls.Filters
{
    public abstract class SuperClassFilter : NodeFilter
    {
        protected FilterResult ShowNode(OutlinerNode n, String superClass)
        {
            if (!(n is OutlinerObject))
                return FilterResult.Show;

            if (((OutlinerObject)n).SuperClass == superClass)
                return FilterResult.Hide;
            else
                return FilterResult.Show;
        }
    }

    public class ShapeFilter : SuperClassFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            return base.ShowNode(n, MaxTypes.Shape);
        }
    }
    
    public class CameraFilter : SuperClassFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            return base.ShowNode(n, MaxTypes.Camera);
        }
    }

    public class LightFilter : SuperClassFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            return base.ShowNode(n, MaxTypes.Light);
        }
    }

    public class SpacewarpFilter : SuperClassFilter
    {
        override public FilterResult ShowNode(OutlinerNode n)
        {
            return base.ShowNode(n, MaxTypes.Spacewarp);
        }
    }
}
