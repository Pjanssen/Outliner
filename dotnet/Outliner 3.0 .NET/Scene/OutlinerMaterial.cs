using System;

namespace Outliner.Scene
{
public class OutlinerMaterial : OutlinerNode
{
    public const String UnassignedMaterialDisplayName = "-Unassigned-";
    public OutlinerMaterial(Int32 handle, Int32 parentHandle, String name, String type)
        : base(handle, parentHandle, name)
    {
        this.Type = type;
    }

    public String Type { get; private set; }
    public Boolean IsUnassigned { get { return this.Handle == OutlinerScene.MaterialUnassignedHandle; } }

    public override bool IsRootNode { get { return this.ParentHandle == OutlinerScene.MaterialRootHandle; } }

    public override OutlinerNode Parent 
    {
        get { return base.Parent; }
        set
        {
            if (value == null)
                this.ParentHandle = OutlinerScene.MaterialRootHandle;
            else
                this.ParentHandle = value.Handle;
        }
    }
    public override OutlinerNode Layer 
    {
        get { return null; }
        set { }
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
            if (IsUnassigned) return OutlinerMaterial.UnassignedMaterialDisplayName;
            if (Type == MaxTypes.XrefMaterial)
                return "{ " + base.DisplayName + " }";
            return base.DisplayName;
        }
    }
    public override bool CanEditName { get { return !IsUnassigned; } }
    public override bool CanBeDeleted { get { return false; } }

    public override bool CanAddNode(OutlinerNode n) 
    {
        if (n is OutlinerObject)
            return n.MaterialHandle != this.Handle;

        return false;
    }
}
}
