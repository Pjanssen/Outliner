using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;

namespace Outliner.Controls
{
    public delegate void NodePropertyChangedEventHandler(object sender, NodePropertyChangedEventArgs e);

    public class NodePropertyChangedEventArgs : EventArgs
    {
        public Int32[] Handles { get; private set; }
        public Object NewValue { get; private set; }

        public NodePropertyChangedEventArgs(Int32[] handles, Object newValue)
        {
            this.Handles = handles;
            this.NewValue = newValue;
        }
    }
}
