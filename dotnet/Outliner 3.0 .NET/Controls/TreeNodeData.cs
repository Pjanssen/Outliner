using Outliner.Scene;
using Outliner.Controls.Filters;
using Outliner.Controls.DragDropHandlers;
using System.Windows.Forms;

namespace Outliner.Controls
{
    public class TreeNodeData
    {
        public TreeNode TreeNode { get; set; }
        public OutlinerNode OutlinerNode { get; private set; }
        public DragDropHandler DragDropHandler { get; set; }
        public FilterResult FilterResult { get; set; }

        public TreeNodeData(OutlinerNode outlinerNode, DragDropHandler dragDropHandler, FilterResult filterResult)
        {
            this.OutlinerNode = outlinerNode;
            this.DragDropHandler = dragDropHandler;
            this.FilterResult = filterResult;
        }

        public static TreeNodeData GetTreeNodeData(TreeNode tn) 
        {
            if (tn == null)
                return null;

            return tn.Tag as TreeNodeData;
        }
        public static OutlinerNode GetOutlinerNode(TreeNode tn) 
        {
            if (tn == null || !(tn.Tag is TreeNodeData))
                return null;

            return ((TreeNodeData)tn.Tag).OutlinerNode;
        }
        public static DragDropHandler GetDragDropHandler(TreeNode tn) 
        {
            if (tn == null || !(tn.Tag is TreeNodeData))
                return null;

            return ((TreeNodeData)tn.Tag).DragDropHandler;
        }
        public static FilterResult GetFilterResult(TreeNode tn) 
        {
            if (tn.Tag == null || !(tn.Tag is TreeNodeData))
                return FilterResult.Hide;

            return ((TreeNodeData)tn.Tag).FilterResult;
        }
    }
}
