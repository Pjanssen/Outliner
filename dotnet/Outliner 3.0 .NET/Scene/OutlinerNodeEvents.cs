using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
    public enum NodeChangeSource : byte
    {
        Max = 1,
        Outliner = 2
    }

    public delegate void OutlinerNodeChangedEventHandler(OutlinerNode sender, OutlinerNodeChangedEventArgs args);
    public delegate void OutlinerObjectChangedEventHandler(OutlinerObject sender, OutlinerNodeChangedEventArgs args);
    public delegate void OutlinerLayerChangedEventHandler(OutlinerLayer sender, OutlinerNodeChangedEventArgs args);
    public delegate void IDisplayableChangedEventHandler(IDisplayable sender, OutlinerNodeChangedEventArgs args);

    public class OutlinerNodeChangedEventArgs : EventArgs
    {
        public NodeChangeSource Source { get; private set; }

        public OutlinerNodeChangedEventArgs(NodeChangeSource source)
        {
            this.Source = source;
        }
    }

    public delegate void NodeHandleChangedEventHandler(OutlinerNode sender, NodeHandleChangedEventArgs args);
    public class NodeHandleChangedEventArgs : OutlinerNodeChangedEventArgs
    {
        public Int32 OldHandle { get; private set; }
        public Int32 NewHandle { get; private set; }
        
        public NodeHandleChangedEventArgs(NodeChangeSource source, Int32 oldHandle, Int32 newHandle) : base(source)
        {
            this.OldHandle = oldHandle;
            this.NewHandle = newHandle;
        }
    }

    public delegate void NodeAddedEventHandler(OutlinerNode sender, NodeAddedEventArgs args);
    public class NodeAddedEventArgs : OutlinerNodeChangedEventArgs
    {
        public OutlinerNode AddedNode { get; private set; }

        public NodeAddedEventArgs(NodeChangeSource source, OutlinerNode addedNode)
            : base(source)
        {
            this.AddedNode = addedNode;
        }
    }

    public delegate void NodeRemovedEventHandler(OutlinerNode sender, NodeRemovedEventArgs args);
    public class NodeRemovedEventArgs : OutlinerNodeChangedEventArgs
    {
        public OutlinerNode RemovedNode { get; private set; }

        public NodeRemovedEventArgs(NodeChangeSource source, OutlinerNode removedNode)
            : base(source)
        {
            this.RemovedNode = removedNode;
        }
    }
}
