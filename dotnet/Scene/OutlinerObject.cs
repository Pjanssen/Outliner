using System;
using System.Collections.Generic;
using System.Text;
using Outliner.DragDropHandlers;
using System.Drawing;

namespace Outliner.Scene
{
    public class OutlinerObject : OutlinerNode, IDisplayable
    {
        public OutlinerObject(OutlinerScene scene, Int32 objectNr, Int32 handle, Int32 parentHandle, Int32 layerHandle, Int32 materialHandle,
                            String name, String objClass, String objSuperClass, 
                            Boolean isGroupHead, Boolean isGroupMember,
                            Boolean isHidden, Boolean isFrozen, Boolean boxMode)
        {
            Scene = scene;
            ObjectNr = objectNr;

            Handle = handle;
            ParentHandle = parentHandle;
            LayerHandle = layerHandle;
            MaterialHandle = materialHandle;

            Name = name;
            Class = objClass;
            SuperClass = objSuperClass;

            IsGroupHead = isGroupHead;
            IsGroupMember = isGroupMember;

            IsHidden = isHidden;
            IsFrozen = isFrozen;
            BoxMode = boxMode;
        }

        override public OutlinerNode Parent
        {
            get 
            {
                if (ParentHandle == OutlinerScene.RootHandle)
                    return null;
                else
                    return Scene.GetObjectByHandle(ParentHandle); 
            }
        }

        public override int ChildNodesCount
        {
            get { return Scene.GetObjectChildNodesCount(Handle); }
        }
        override public List<OutlinerNode> ChildNodes
        {
            get
            {
                return Scene.GetObjectsByParentHandle(Handle);
            }
        }

        public Int32 LayerHandle { get; set; }
        public OutlinerLayer Layer
        {
            get
            {
                return Scene.GetLayerByHandle(LayerHandle);
            }
        }

        public Int32 MaterialHandle { get; set; }
        public OutlinerMaterial Material
        {
            get
            {
                return Scene.GetMaterialByHandle(MaterialHandle);
            }
        }


        override public String DisplayName
        {
            get
            {
                String n = (this.Name != String.Empty) ? this.Name : "-unnamed-";
                if (Class == OutlinerScene.XrefObjectType && (IsGroupMember || IsGroupHead)) return "{[ " + n + " ]}";
                if (Class == OutlinerScene.XrefObjectType) return "{ " + n + " }";
                if (IsGroupMember || IsGroupHead) return "[ " + n + " ]";
                return n;
            }
        }
        override public Boolean CanEditName { get { return true; } }



        public override bool CanBeDeleted
        {
            get { return true; }
        }

        public Int32 ObjectNr { get; private set; }

        public String Class { get; set; }
        public String SuperClass { get; set; }

        public Boolean IsGroupHead { get; set; }
        public Boolean IsGroupMember { get; set; }




        public void SetIsGroupMemberRec(Boolean isGroupMember)
        {
            SetIsGroupMemberRec(this, isGroupMember);
        }
        private void SetIsGroupMemberRec(OutlinerObject o, Boolean isGroupMember)
        {
            o.IsGroupMember = isGroupMember;
            foreach (OutlinerNode c in o.ChildNodes)
            {
                if (c is OutlinerObject)
                    SetIsGroupMemberRec((OutlinerObject)c, isGroupMember);
            }
        }

        #region IDisplayable Members

        public Boolean IsHidden { get; set; }
        public Boolean IsFrozen { get; set; }
        public Boolean BoxMode { get; set; }

        #endregion
    }
}
