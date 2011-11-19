using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
    public abstract class OutlinerNode
    {
        public virtual OutlinerScene Scene { get; protected set; }

        public virtual Outliner.DragDropHandlers.DragDropHandler DragDropHandler { get; set; }

        public virtual Int32 Handle { get; protected set; }
        public virtual Int32 ParentHandle { get; set; }

        public virtual Boolean IsRootNode { get { return ParentHandle == OutlinerScene.RootHandle; } }

        public virtual String Name { get; set; }
        public abstract String DisplayName { get; }
        public abstract Boolean CanEditName { get; }

        public abstract Boolean CanBeDeleted { get; }

        public virtual OutlinerNode Parent { get { return null; } }
        public abstract Int32 ChildNodesCount { get; }
        public abstract List<OutlinerNode> ChildNodes { get; }

        public virtual Boolean Filtered { get; set; }
        private Boolean _markedForDelete;
        public virtual Boolean MarkedForDelete {
            get { return _markedForDelete; }
            set 
            {
                _markedForDelete = value;
                if (!value)
                {
                    foreach (OutlinerNode n in ChildNodes)
                        n.MarkedForDelete = value;
                }
            }
        }
    }
}
