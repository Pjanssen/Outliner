using System;
using System.Collections.Generic;
using System.Text;
using Outliner.Scene;
using System.Windows.Forms;

namespace Outliner
{
    public delegate void SelectionChangedEventHandler(object sender, SelectionChangedEventArgs e);
    public class SelectionChangedEventArgs : EventArgs
    {
        public Int32[] SelectedObjectHandles { get; private set; }
        public Int32[] SelectedLayerHandles { get; private set; }
        public Int32[] SelectedMaterialHandles { get; private set; }

        public SelectionChangedEventArgs(Int32[] selectedObjectHandles, Int32[] selectedLayerHandles, Int32[] selectedMaterialHandles)
        {
            SelectedObjectHandles = selectedObjectHandles;
            SelectedLayerHandles = selectedLayerHandles;
            SelectedMaterialHandles = selectedMaterialHandles;
        }
    }


    public delegate void NodePropertyChangedEventHandler(object sender, NodePropertyChangedEventArgs e);
    public class NodePropertyChangedEventArgs : EventArgs
    {
        public Int32[] Handles { get; private set; }
        public String PropName { get; private set; }
        public Object NewValue { get; private set; }

        public NodePropertyChangedEventArgs(Int32[] handles, String propName, Object newValue)
        {
            Handles = handles;
            PropName = propName;
            NewValue = newValue;
        }
    }


    public delegate void NodeRenamedEventHandler(object sender, NodeRenamedEventArgs e);
    public class NodeRenamedEventArgs : EventArgs
    {
        public Int32 Handle { get; private set; }
        public String Name { get; private set; }

        public NodeRenamedEventArgs(Int32 handle, String name)
        {
            Handle = handle;
            this.Name = name;
        }
    }


    public delegate void NodeLinkedEventHandler(object sender, NodeLinkedEventArgs e);
    public class NodeLinkedEventArgs : EventArgs
    {
        public Int32[] Handles { get; private set; }
        public Int32 TargetHandle { get; private set; }

        public NodeLinkedEventArgs(Int32[] handles, Int32 targetHandle)
        {
            this.Handles = handles;
            this.TargetHandle = targetHandle;
        }
    }


    public delegate void NodeGroupedEventHandler(object sender, NodeGroupedEventArgs e);
    public class NodeGroupedEventArgs : NodeLinkedEventArgs
    {
        public Boolean IsGroupMember { get; private set; }
        public Boolean Linked { get; private set; }

        public NodeGroupedEventArgs(Int32[] nodeHandles, Int32 targetHandle, Boolean isGroupMember, Boolean linked) : base (nodeHandles, targetHandle)
        {
            IsGroupMember = isGroupMember;
            Linked = linked;
        }
    }




    public delegate void ContextMenuItemClickedEventHandler(object sender, ContextMenuItemClickedEventArgs e);
    public class ContextMenuItemClickedEventArgs : EventArgs
    {
        public ContextMenuStrip Menu { get; private set; }
        public ToolStripItem ClickedItem { get; private set; }

        public ContextMenuItemClickedEventArgs(ContextMenuStrip menu, ToolStripItem clickedItem)
        {
            Menu = menu;
            ClickedItem = clickedItem;
        }
    }



    public delegate void DebugEventHandler(object sender, DebugEventArgs e);
    public class DebugEventArgs : EventArgs
    {
        public String Text1 { get; private set; }
        public String Text2 { get; private set; }
        public String Text3 { get; private set; }

        public DebugEventArgs(String text)
        {
            Text1 = text;
        }
        public DebugEventArgs(String text, String text2)
            : this(text)
        {
            Text2 = text2;
        }
        public DebugEventArgs(String text, String text2, String text3)
            : this(text, text2)
        {
            Text3 = text3;
        }
    }
}
