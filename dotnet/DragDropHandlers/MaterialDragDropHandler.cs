using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;

namespace Outliner.DragDropHandlers
{
    public class MaterialDragDropHandler : DragDropHandler
    {
        public MaterialDragDropHandler(Outliner.TreeView tree, OutlinerMaterial data) : base(tree, null)
        {
            Data = data;
        }

        new protected OutlinerMaterial Data { get; set; }

        public override bool AllowDrag { get { return true; } }


        protected override bool IsDroppableNode(OutlinerNode o)
        {
            return o is OutlinerObject && ((OutlinerObject)o).MaterialHandle != Data.Handle;
        }

        public override bool IsValidDropTarget(IDataObject dragData)
        {
            if (Tree == null || Tree.ListMode != OutlinerListMode.Material)
                return false;
            else
                return base.IsValidDropTarget(dragData);
        }


        public override DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            if (IsValidDropTarget(dragData))
                return DragDropEffects.Link;
            else
                return Outliner.TreeView.DragDropEffectsNone;
        }


        public override bool ItemDropped(IDataObject dragData)
        {
            if (!IsValidDropTarget(dragData))
                return false;

            OutlinerNode[] droppedNodes = GetNodesFromDataObject(dragData);
            Int32[] droppedNodeHandles = new Int32[droppedNodes.Length];

            Tree.BeginTimedUpdate();
            Tree.BeginTimedSort();

            Int32 i = 0;
            foreach (OutlinerNode n in droppedNodes)
            {
                Tree.SetObjectMaterial((OutlinerObject)n, Data.Handle);

                droppedNodeHandles[i] = ((OutlinerObject)n).Handle;
                i++;
            }

            Tree.RaiseObjectMaterialChangedEvent(new NodePropertyChangedEventArgs(droppedNodeHandles, "material", Data.Handle));

            return true;
        }
    }
}
