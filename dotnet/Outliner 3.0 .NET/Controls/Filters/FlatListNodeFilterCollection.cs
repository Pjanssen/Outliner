using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public class FlatListNodeFilterCollection : NodeFilterCollection
    {
        public FlatListNodeFilterCollection() : base() { }
        public FlatListNodeFilterCollection(NodeFilterCollection collection) : base(collection) { }

        protected override FilterResult ShowChildNodes(OutlinerNode n)
        {
            if (n is OutlinerObject)
                return FilterResult.Hide;
            else
                return base.ShowChildNodes(n);
        }
    }
}
