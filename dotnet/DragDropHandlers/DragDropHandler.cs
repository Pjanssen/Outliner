using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Collections;
using Outliner.Scene;

namespace Outliner.DragDropHandlers
{
    public class DragDropHandler
    {
        public DragDropHandler(Outliner.TreeView tree, OutlinerNode data)
        {
            Tree = tree;
            Data = data;
        }

        protected OutlinerNode Data { get; set; }
        protected Outliner.TreeView Tree { get; set; }


        // Determines whether the node can be dragged.
        public virtual Boolean AllowDrag { get { return false; } }


        // Called by the dragover event, to check whether the node is a valid drop target for the nodes being dragged.
        public virtual Boolean IsValidDropTarget(IDataObject dragData)
        {
            OutlinerNode[] draggedNodes = GetNodesFromDataObject(dragData);
            if (draggedNodes != null)
            {
                foreach (OutlinerNode n in draggedNodes)
                {
                    if (!IsDroppableNode(n)) return false;
                }
                return true;
            }
            else
                return false;
        }

        protected virtual Boolean IsDroppableNode(OutlinerNode o)
        {
            return false;
        }



        // Returns the DragDropEffect for this node as a drop-target.
        public virtual DragDropEffects GetDragDropEffect(IDataObject dragData)
        {
            return Outliner.TreeView.DragDropEffectsNone;
        }



        // Called when a selection of nodes is dropped onto this node.
        public virtual Boolean ItemDropped(IDataObject dragData)
        {
            return false;
        }




        protected Int32[] getChildHandles(OutlinerNode[] nodes)
        {
            List<Int32> handles = new List<Int32>();
            foreach (OutlinerNode n in nodes)
            {
                getChildHandles_intern(n, nodes, ref handles);
            }
            return handles.ToArray();
        }

        private void getChildHandles_intern(OutlinerNode n, OutlinerNode[] nodes, ref List<Int32> handles)
        {
            foreach (OutlinerNode cn in n.ChildNodes)
            {
                if (cn is OutlinerObject && !arrayContains(nodes, cn))
                    handles.Add(((OutlinerObject)cn).Handle);
                getChildHandles_intern(cn, nodes, ref handles);
            }
        }

        private Boolean arrayContains(OutlinerNode[] nodes, OutlinerNode n)
        {
            EqualityComparer<OutlinerNode> comparer = EqualityComparer<OutlinerNode>.Default;
            for (int i = 0; i < nodes.Length; i++)
            {
                if (comparer.Equals(nodes[i], n))
                {
                    return true;
                }
            }
            return false;

        }




        public static OutlinerNode[] GetNodesFromDataObject(IDataObject dragData)
        {
            if (dragData.GetDataPresent(typeof(OutlinerNode[])))
                return (OutlinerNode[])dragData.GetData(typeof(OutlinerNode[]));
            else
                return null;
        }

        public static DragDropHandler GetDragDropHandlerForNode(Outliner.TreeView tree, OutlinerNode node)
        {
            if (node is OutlinerObject)
            {
                OutlinerObject obj = (OutlinerObject)node;
                if (obj.IsGroupHead || obj.IsGroupMember) return new GroupDragDropHandler(tree, obj);
                if (obj.Class == OutlinerScene.ContainerType) return new ContainerDragDropHandler(tree, obj);
                if (obj.SuperClass == OutlinerScene.SpacewarpType) return new SpaceWarpDragDropHandler(tree, obj);
                
                return new ObjectDragDropHandler(tree, obj);
            }
            else if (node is OutlinerMaterial)
                return new MaterialDragDropHandler(tree, (OutlinerMaterial)node);
            else if (node is OutlinerLayer) 
                return new LayerDragDropHandler(tree, (OutlinerLayer)node);

            return new DragDropHandler(tree, node);
        }
    }
}
