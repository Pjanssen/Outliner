using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
public class OutlinerObject : OutlinerNode, IDisplayable
{
    internal override bool IndexByLayer { get { return true; } }
    internal override bool IndexByMaterial { get { return true; } }

    public OutlinerObject(Int32 handle, Int32 parentHandle, String name, Int32 layerHandle, Int32 materialHandle,
                            String objClass, String objSuperClass,
                            Boolean isGroupHead, Boolean isGroupMember,
                            Boolean isHidden, Boolean isFrozen, Boolean boxMode)
        : base(handle, parentHandle, name, layerHandle, materialHandle)
    {
        this.Class = objClass;
        this.SuperClass = objSuperClass;
        this.IsGroupHead = isGroupHead;
        this.IsGroupMember = isGroupMember;
        this.IsHidden = isHidden;
        this.IsFrozen = isFrozen;
        this.BoxMode = boxMode;
    }

    private String _class;
    private String _superClass;
    public String Class 
    {
        get { return _class; }
        set
        {
            if (value != _class)
            {
                _class = value;
                this.OnClassChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
            }
        }
    }
    public String SuperClass 
    {
        get { return _superClass; }
        set
        {
            if (value != _superClass)
            {
                _superClass = value;
                this.OnSuperClassChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
            }
        }
    }

    private Boolean _isGroupHead;
    private Boolean _isGroupMember;
    public Boolean IsGroupHead 
    {
        get { return _isGroupHead; }
        set
        {
            if (value != _isGroupHead)
            {
                _isGroupHead = value;
                this.OnIsGroupHeadChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
            }
        }
    }
    public Boolean IsGroupMember 
    {
        get { return _isGroupMember; }
        set
        {
            if (value != _isGroupMember)
            {
                _isGroupMember = value;
                this.OnIsGroupMemberChanged(new OutlinerNodeChangedEventArgs(this.NodeChangeSource));
            }
        }
    }

    public override bool IsRootNode { get { return this.ParentHandle == OutlinerScene.ObjectRootHandle; } }
    public override OutlinerNode Parent 
    {
        get { return base.Parent; }
        set
        {
            if (value == null)
                this.ParentHandle = OutlinerScene.ObjectRootHandle;
            else
                this.ParentHandle = value.Handle;
        }
    }
    public override string DisplayName 
    {
        get
        {
            if (this.Class == MaxTypes.XrefObject)
            {
                if (this.IsGroupMember || this.IsGroupHead) 
                    return "{[ " + base.DisplayName + " ]}";
                
                return "{ " + base.DisplayName + " }";
            }
            if (this.IsGroupMember || this.IsGroupHead) 
                return "[ " + base.DisplayName + " ]";
            
            return base.DisplayName;
        }
    }

    public override bool CanAddNode(OutlinerNode n) 
    {
        if (n is OutlinerObject)
            return n.ParentHandle != this.Handle && n.Handle != this.Handle;

        return false;
    }


    public event OutlinerObjectChangedEventHandler ClassChanged;
    protected virtual void OnClassChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.ClassChanged != null)
            this.ClassChanged(this, args);
    }
    public event OutlinerObjectChangedEventHandler SuperClassChanged;
    protected virtual void OnSuperClassChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.SuperClassChanged != null)
            this.SuperClassChanged(this, args);
    }

    public event OutlinerObjectChangedEventHandler IsGroupHeadChanged;
    protected virtual void OnIsGroupHeadChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.IsGroupHeadChanged != null)
            this.IsGroupHeadChanged(this, args);
    }
    public event OutlinerObjectChangedEventHandler IsGroupMemberChanged;
    protected virtual void OnIsGroupMemberChanged(OutlinerNodeChangedEventArgs args) 
    {
        if (this.IsGroupMemberChanged != null)
            this.IsGroupMemberChanged(this, args);
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
