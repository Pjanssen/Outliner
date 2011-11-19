using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
    public class OutlinerMaterial : OutlinerNode
    {
        public OutlinerMaterial(OutlinerScene scene, Int32 handle, Int32 parentHandle, String name, String type)
        {
            Scene = scene;
            Handle = handle;
            ParentHandle = parentHandle;
            Name = name;
            Type = type;
        }

        public override OutlinerNode Parent
        {
            get
            {
                if (ParentHandle == OutlinerScene.RootHandle)
                    return null;
                else
                    return Scene.GetMaterialByHandle(ParentHandle);
            }
        }


        public override int ChildNodesCount
        {
            get { return Scene.GetMaterialChildNodesCount(Handle); }
        }

        public override List<OutlinerNode> ChildNodes
        {
            get
            {
                List<OutlinerNode> childMaterials = ChildMaterials;
                List<OutlinerNode> childObjects = ChildObjects;
                if (childMaterials.Count == 0)
                    return childObjects;
                else
                {
                    childMaterials.AddRange(childObjects);
                    return childMaterials;
                }
            }
        }

        public List<OutlinerNode> ChildMaterials
        {
            get
            {
                if (IsUnassigned)
                    return new List<OutlinerNode>(0);
                else
                    return Scene.GetMaterialsByParentHandle(Handle);
            }
        }

        public List<OutlinerNode> ChildObjects
        {
            get
            {
                return Scene.GetObjectsByMaterialHandle(Handle);
            }
        }

        public override string DisplayName
        {
            get
            {
                if (IsUnassigned) return "-Unassigned-";
                if (Type == OutlinerScene.XrefMaterialType)
                    return "{ " + Name + " }";
                return Name;
            }
        }

        public override bool CanEditName
        {
            get { return !IsUnassigned; }
        }

        public override bool CanBeDeleted
        {
            get { return false; }// return !IsUnassigned; }
        }

        public String Type { get; private set; }


        public Boolean IsUnassigned
        {
            get
            {
                return Handle == OutlinerScene.UnassignedHandle;
            }
        }
    }
}
