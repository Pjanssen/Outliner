using System;
using System.Collections.Generic;

namespace Outliner.Scene
{
public abstract class OutlinerNode
{
    public const String UnnamedNodeDisplayName = "-Unnamed Node-";

    public OutlinerNode(Int32 handle, Int32 parentHandle, String name)
        : this(handle, parentHandle, name, OutlinerScene.ObjectRootHandle, OutlinerScene.MaterialUnassignedHandle)
    { }

    public OutlinerNode(Int32 handle, Int32 parentHandle, String name, Int32 layerHandle, Int32 materialHandle) 
    {
        this.Handle = handle;
        this.ParentHandle = parentHandle;
        this.Name = name;
        this.LayerHandle = layerHandle;
        this.MaterialHandle = materialHandle;

        this.NodeChangeSource = NodeChangeSource.Outliner;
    }


    public NodeChangeSource NodeChangeSource { get; set; }

    public virtual OutlinerScene Scene { get; internal set; }

    internal virtual Boolean IndexByParent { get { return true; } }
    internal virtual Boolean IndexByLayer { get { return false; } }
    internal virtual Boolean IndexByMaterial { get { return false; } }

    protected Int32 _parentHandle;
    protected Int32 _layerHandle;
    protected Int32 _materialHandle;
    public virtual Int32 Handle { get; protected set; }
    public virtual Int32 ParentHandle 
    {
        get { return _parentHandle; }
        set
        {
            if (value == this.Handle)
                return;

            NodeHandleChangedEventArgs evtArgs = new NodeHandleChangedEventArgs(this.NodeChangeSource, this.ParentHandle, value);

            _parentHandle = value;

            this.OnParentChanged(evtArgs);
        }
    }
    public virtual Int32 LayerHandle 
    {
        get { return _layerHandle; }
        set
        {
            if (value == this.Handle)
                return;

            NodeHandleChangedEventArgs evtArgs = new NodeHandleChangedEventArgs(this.NodeChangeSource, this.LayerHandle, value);

            _layerHandle = value;

            this.OnLayerChanged(evtArgs);
        }
    }
    public virtual Int32 MaterialHandle 
    {
        get { return _materialHandle; }
        set
        {
            if (value == this.Handle)
                return;

            NodeHandleChangedEventArgs evtArgs = new NodeHandleChangedEventArgs(this.NodeChangeSource, this.MaterialHandle, value);

            _materialHandle = value;

            this.OnMaterialChanged(evtArgs);
        }
    }

    public virtual OutlinerNode Parent 
    {
        get
        {
            if (this.Scene == null || this.IsRootNode)
                return null;

            return Scene.GetNodeByHandle(this.ParentHandle);
        }
        set
        {
            if (value != null)
                this.ParentHandle = value.Handle;
        }
    }
    public virtual OutlinerNode Layer 
    {
        get
        {
            if (this.Scene == null || this.LayerHandle == OutlinerScene.LayerRootHandle)
                return null;

            return Scene.GetNodeByHandle(this.LayerHandle);
        }
        set
        {
            if (value == null)
                this.LayerHandle = OutlinerScene.LayerRootHandle;
            else
                this.LayerHandle = value.Handle;
        }
    }
    public virtual OutlinerNode Material 
    {
        get
        {
            if (this.Scene == null || this.MaterialHandle == OutlinerScene.MaterialRootHandle)
                return null;

            return Scene.GetNodeByHandle(this.MaterialHandle);
        }
        set
        {
            if (value == null)
                this.MaterialHandle = OutlinerScene.MaterialUnassignedHandle;
            else
                this.MaterialHandle = value.Handle;
        }
    }
    public virtual Boolean IsRootNode { get { return false; } }

    protected String _name;
    public virtual String Name 
    {
        get { return _name; }
        set 
        {
            if (value == null)
                _name = String.Empty;
            else
                _name = value;

            this.OnNameChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
        }
    }
    public virtual String DisplayName 
    {
        get 
        {
            if (this.Name == String.Empty)
                return OutlinerNode.UnnamedNodeDisplayName;
            else
                return this.Name; 
        }
    }
    public virtual Boolean CanEditName { get { return true; } }
    public virtual Boolean CanBeDeleted { get { return true; } }

    public virtual Boolean CanAddNode(OutlinerNode n) { return false; }
    public virtual Boolean CanAddNodes(List<OutlinerNode> nodes) 
    {
        foreach (OutlinerNode n in nodes)
        {
            if (!this.CanAddNode(n))
                return false;
        }
        return true;
    }
    
    public virtual List<OutlinerNode> ChildNodes 
    {
        get
        {
            if (this.Scene == null)
                return new List<OutlinerNode>();

            return Scene.GetChildNodes(this.Handle);
        }
    }
    public virtual Int32 ChildNodesCount 
    {
        get
        {
            if (this.Scene == null)
                return 0;
            else
                return Scene.GetChildNodesCount(this.Handle);
        }
    }



    public event OutlinerNodeChangedEventHandler NameChanged;
    protected virtual void OnNameChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.NameChanged != null)
            this.NameChanged(this, args);
    }
    public event NodeHandleChangedEventHandler ParentChanged;
    protected virtual void OnParentChanged(NodeHandleChangedEventArgs args) 
    {
        if (this.ParentChanged != null)
            this.ParentChanged(this, args);
    }
    public event NodeHandleChangedEventHandler LayerChanged;
    protected virtual void OnLayerChanged(NodeHandleChangedEventArgs args) 
    {
        if (this.LayerChanged != null)
            this.LayerChanged(this, args);
    }
    public event NodeHandleChangedEventHandler MaterialChanged;
    protected virtual void OnMaterialChanged(NodeHandleChangedEventArgs args) 
    {
        if (this.MaterialChanged != null)
            this.MaterialChanged(this, args);
    }
}
}
