using System;

namespace Outliner.Scene
{
public class OutlinerLayer : OutlinerNode, IDisplayable
{
    public OutlinerLayer(Int32 handle, Int32 parentLayerHandle, String name, Boolean isActive, 
                        Boolean isHidden, Boolean isFrozen, Boolean boxMode) 
        : base(handle, 0, name, parentLayerHandle, 0)
    {
        this.IsActive = isActive;
        this.IsHidden = isHidden;
        this.IsFrozen = isFrozen;
        this.BoxMode = boxMode;
    }

    internal override bool IndexByParent { get { return false; } }
    internal override bool IndexByLayer { get { return true; } }

    private Boolean _isActive;
    public Boolean IsActive
    {
        get { return _isActive; }
        set
        {
            if (value != _isActive)
            {
                _isActive = value;

                if (value && this.Scene != null)
                    this.Scene.ActiveLayer = this;

                this.OnIsActiveChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
            }
        }
    }
    public Boolean IsDefaultLayer { get { return Name == "0"; } }

    public override bool IsRootNode { get { return this.LayerHandle == OutlinerScene.LayerRootHandle; } }

    public override OutlinerNode Parent 
    {
        get { return null; }
        set { }
    }
    public override OutlinerNode Layer 
    {
        get { return base.Layer; }
        set
        {
            if (value == null)
                this.LayerHandle = OutlinerScene.LayerRootHandle;
            else
                this.LayerHandle = value.ParentHandle;
        }
    }
    public override OutlinerNode Material 
    {
        get { return null; }
        set { }
    }
    
    public override string DisplayName 
    {
        get
        {
            if (this.IsDefaultLayer) return "0 (default)";
            return base.DisplayName;
        }
    }
    public override bool CanEditName { get { return !this.IsDefaultLayer; } }
    public override bool CanBeDeleted { get { return !this.IsDefaultLayer; } }

    public override bool CanAddNode(OutlinerNode n) 
    {
        if (n is OutlinerObject || n is OutlinerLayer)
            return n.LayerHandle != this.Handle && n.Handle != this.Handle;

        return false;
    }


    public event OutlinerLayerChangedEventHandler IsActiveChanged;
    protected virtual void OnIsActiveChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.IsActiveChanged != null)
            this.IsActiveChanged(this, args);
    }

    #region IDisplayable Members

    private Boolean _isHidden = false;
    public bool IsHidden
    {
        get { return _isHidden; }
        set
        {
            _isHidden = value;
            this.OnHiddenChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
        }
    }
    public event IDisplayableChangedEventHandler HiddenChanged;
    protected virtual void OnHiddenChanged(OutlinerNodeChangedEventArgs e)
    {
        if (this.HiddenChanged != null)
            this.HiddenChanged(this, e);
    }

    private Boolean _isFrozen = false;
    public bool IsFrozen
    {
        get { return _isFrozen; }
        set
        {
            _isFrozen = value;
            this.OnFrozenChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
        }
    }
    public event IDisplayableChangedEventHandler FrozenChanged;
    protected virtual void OnFrozenChanged(OutlinerNodeChangedEventArgs e)
    {
        if (this.FrozenChanged != null)
            this.FrozenChanged(this, e);
    }

    private Boolean _boxMode = false;
    public bool BoxMode
    {
        get { return _boxMode; }
        set
        {
            _boxMode = value;
            this.OnBoxModeChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
        }
    }
    public event IDisplayableChangedEventHandler BoxModeChanged;
    protected virtual void OnBoxModeChanged(OutlinerNodeChangedEventArgs e)
    {
        if (this.BoxModeChanged != null)
            this.BoxModeChanged(this, e);
    }

    #endregion
}
}
