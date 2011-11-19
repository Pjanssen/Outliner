using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;

namespace Outliner.Controls.DragDropHandlers
{
    public abstract class DragDropHandler
    {
        public DragDropHandler(TreeView tree, OutlinerNode n)
        {
            this.Tree = tree;
            this.Data = n;
        }

        public virtual TreeView Tree { get; protected set; }
        public virtual OutlinerNode Data { get; protected set; }

        /// <summary>
        /// Determines whether the node can be dragged.
        /// </summary>
        public abstract Boolean AllowDrag { get; }

        /// <summary>
        /// Returns true if the dragged data can be dropped onto this handler.
        /// </summary>
        public abstract Boolean IsValidDropTarget(IDataObject dragData);

        /// <summary>
        /// Returns the DragDropEffect for this node as a drop-target.
        /// </summary>
        public abstract DragDropEffects GetDragDropEffect(IDataObject dragData);

        /// <summary>
        /// Called when a selection of nodes is dropped onto this node.
        /// </summary>
        public abstract void HandleDrop(IDataObject dragData);



        protected List<TreeNodeData> GetNodesFromDataObject(IDataObject dragData)
        {
            if (dragData.GetDataPresent(typeof(List<TreeNodeData>)))
                return dragData.GetData(typeof(List<TreeNodeData>)) as List<TreeNodeData>;
            else
                return null;
        }


        public static DragDropHandler GetDragDropHandler(TreeView tree, OutlinerNode n) 
        {
            if (n is OutlinerObject)
                return new ObjectDragDropHandler(tree, n);
            else if (n is OutlinerLayer)
                return new LayerDragDropHandler(tree, (OutlinerLayer)n);
            else if (n is SelectionSet)
                return new SelectionSetDragDropHandler(tree, (SelectionSet)n);

            return new NullDragDropHandler();
        }
    }
}
