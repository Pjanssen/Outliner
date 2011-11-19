using System;
using System.Collections.Generic;
using System.Text;

namespace Outliner.Scene
{
    public class OutlinerScene
    {
        #region Type string constants

        public const String ObjectType          = "Object";
        public const String XrefObjectType      = "ReferenceTarget";//getClassname for xrefobject returns referencetarget?? "XRefObject";
        public const String LayerType           = "Layer";
        public const String MaterialType        = "Material";
        public const String XrefMaterialType    = "XRef";

        public const String BipedType           = "";//getClassName for biped returns empty string?? "Biped_Object";
        public const String BoneType            = "Bone";
        public const String CameraType          = "camera";
        public const String ContainerType       = "Container";
        public const String GeometryType        = "GeometryClass";
        public const String HelperType          = "helper";
        public const String LightType           = "light";
        public const String NurbsPtSurfType     = "Point Surf";
        public const String NurbsCvSurfType     = "CV Surf";
        public const String PatchEditableType   = "PatchObject";
        public const String PatchQuadType       = "QuadPatchObject";
        public const String PatchTriType        = "TriPatchObject";
        public const String PArrayType          = "PArray";
        public const String PBlizzardType       = "Blizzard";
        public const String PCloudType          = "PCloud";
        public const String PfSourceType        = "PF Source";
        public const String PSnowType           = "Snow";
        public const String PSprayType          = "Spray";
        public const String PSuperSprayType     = "SuperSpray";
        public const String PBirthTextureType   = "Birth Texture";
        public const String PSpeedByIconType    = "SpeedByIcon";
        public const String PGroupSelectionType = "Group Select";
        public const String PFindTargetType     = "Find Target";
        public const String PInitialStateType   = "Initial State";
        public const String ParticlePaintType   = "Particle Paint";
        public const String ShapeType           = "shape";
        public const String SpacewarpType       = "SpacewarpObject";
        public const String TargetType          = "Target";
        public const String PowerNurbsPrefixType = "Pwr_";

        private readonly HashSet<String> hidden_particle_classes = new HashSet<String>() 
        { 
            "Age Test", "Birth", "Birth Paint", "Birth Script", "Cache", "Collision", "Collision Spawn", 
            "DeleteParticles", "DisplayParticles", "Event", "Force", "Go To Rotation", "Group Operator", 
            "Keep Apart", "Lock/Bond", "Mapping", "Material Dynamic", "Material Frequency", "Mapping Object", 
            "Material Static", "Notes", "Particle_Bitmap", "Particle View", "ParticleGroup", "PFArrow", "PFEngine",
            "PFActionListPool", "Placement Paint", "Position Icon", "Position Object", "PView_Manager", "Rotation", "RenderParticles",
            "ScaleParticles", "Scale Test", "Script Operator", "Script Test", "Send Out", "Shape Facing", "Shape Instance", 
            "ShapeLibrary", "Shape Mark", "shapeStandard", "Spawn", "Speed", "Speed By Surface", "Speed Test", "Spin", 
            "Split Amount", "Split Group", "Split Selected", "Split Source"
        };

        #endregion

        public const Int32 RootHandle = -1;
        public const Int32 UnassignedHandle = -1;

        protected Int32 objectCounter;

        protected Dictionary<Int32, OutlinerObject> objects;
        protected Dictionary<Int32, OutlinerLayer> layers;
        protected Dictionary<Int32, OutlinerMaterial> materials;

        protected Dictionary<Int32, List<Int32>> objects_by_parentHandle;
        protected Dictionary<Int32, List<Int32>> objects_by_layerHandle;
        protected Dictionary<Int32, List<Int32>> objects_by_materialHandle;

        protected Dictionary<Int32, List<Int32>> layers_by_parentHandle;

        protected Dictionary<Int32, List<Int32>> materials_by_parentHandle;

        public OutlinerScene()
        {
            objectCounter = 0;

            objects = new Dictionary<Int32, OutlinerObject>();
            layers = new Dictionary<Int32, OutlinerLayer>();
            materials = new Dictionary<Int32, OutlinerMaterial>();

            objects_by_parentHandle = new Dictionary<Int32, List<Int32>>();
            objects_by_layerHandle = new Dictionary<Int32, List<Int32>>();
            objects_by_materialHandle = new Dictionary<Int32, List<Int32>>();

            layers_by_parentHandle = new Dictionary<Int32, List<Int32>>();
            materials_by_parentHandle = new Dictionary<Int32, List<Int32>>();

            AddMaterial(new OutlinerMaterial(this, UnassignedHandle, RootHandle, "", ""));
        }

        public void Clear()
        {
            objectCounter = 0;

            objects.Clear();
            layers.Clear();
            ClearMaterials();
            
            objects_by_parentHandle.Clear();
            objects_by_layerHandle.Clear();
            objects_by_materialHandle.Clear();

            layers_by_parentHandle.Clear();
        }

        public void ClearMaterials()
        {
            materials.Clear();
            materials_by_parentHandle.Clear();
            AddMaterial(new OutlinerMaterial(this, UnassignedHandle, RootHandle, "", ""));
        }


        #region Objects, RootObjects, Layers, Materials

        public List<OutlinerNode> RootObjects
        {
            get
            {
                return GetObjectsByParentHandle(RootHandle);
            }
        }

        public List<OutlinerObject> Objects
        {
            get
            {
                return new List<OutlinerObject>(objects.Values);
            }
        }

        public List<OutlinerNode> RootLayers
        {
            get
            {
                return GetLayersByParentHandle(RootHandle);
            }
        }

        public List<OutlinerLayer> Layers
        {
            get
            {
                return new List<OutlinerLayer>(layers.Values);
            }
        }

        public List<OutlinerNode> RootMaterials
        {
            get
            {
                return GetMaterialsByParentHandle(RootHandle);
            }
        }

        public List<OutlinerMaterial> Materials
        {
            get
            {
                return new List<OutlinerMaterial>(materials.Values);
            }
        }

        #endregion


        #region GetObjectByHandle, GetLayerByHandle, GetMaterialByHandle

        //Should only be used if you're not sure what type the node will be, using of GetObjectByHandle, GetLayerByHandle etc is preferred.
        public OutlinerNode GetNodeByHandle(Int32 handle)
        {
            OutlinerNode node = GetObjectByHandle(handle);
            if (node == null)
                node = GetLayerByHandle(handle);
            if (node == null)
                node = GetMaterialByHandle(handle);
            return node;
        }

        public OutlinerObject GetObjectByHandle(Int32 handle)
        {
            OutlinerObject obj = null;
            objects.TryGetValue(handle, out obj);
            return obj;
        }

        public OutlinerLayer GetLayerByHandle(Int32 handle)
        {
            OutlinerLayer layer = null;
            layers.TryGetValue(handle, out layer);
            return layer;
        }

        public OutlinerMaterial GetMaterialByHandle(Int32 handle)
        {
            OutlinerMaterial mat = null;
            materials.TryGetValue(handle, out mat);
            return mat;
        }

        #endregion


        #region GetObjectsByParentHandle, GetObjectsByLayerHandle, GetObjectsByMaterialHandle, GetLayersByParentHandle, GetMaterialsByParentHandle

        public List<OutlinerNode> GetObjectsByParentHandle(Int32 handle)
        {
            return getNodesFromDict(objects_by_parentHandle, handle, GetObjectByHandle);
        }

        public List<OutlinerNode> GetObjectsByLayerHandle(Int32 handle)
        {
            return getNodesFromDict(objects_by_layerHandle, handle, GetObjectByHandle);
        }

        public List<OutlinerNode> GetObjectsByMaterialHandle(Int32 handle)
        {
            return getNodesFromDict(objects_by_materialHandle, handle, GetObjectByHandle);
        }

        public List<OutlinerNode> GetLayersByParentHandle(Int32 handle)
        {
            return getNodesFromDict(layers_by_parentHandle, handle, GetLayerByHandle);
        }

        public List<OutlinerNode> GetMaterialsByParentHandle(Int32 handle)
        {
            return getNodesFromDict(materials_by_parentHandle, handle, GetMaterialByHandle);
        }

        #endregion


        #region GetChildNodesCount

        public Int32 GetObjectChildNodesCount(Int32 objectHandle)
        {
            return getNodesFromDictCount(objects_by_parentHandle, objectHandle);
        }

        public Int32 GetLayerChildNodesCount(Int32 layerHandle)
        {
            return getNodesFromDictCount(objects_by_layerHandle, layerHandle) + getNodesFromDictCount(layers_by_parentHandle, layerHandle);
        }

        public Int32 GetMaterialChildNodesCount(Int32 materialHandle)
        {
            return getNodesFromDictCount(objects_by_materialHandle, materialHandle) + getNodesFromDictCount(materials_by_parentHandle, materialHandle);
        }

        #endregion


        #region AddObject, AddLayer, AddMaterial

        public void AddObject(OutlinerObject obj)
        {
            if (!objects.ContainsKey(obj.Handle))
            {
                objects.Add(obj.Handle, obj);

                addHandleToListInDict(obj.Handle, objects_by_parentHandle, obj.ParentHandle);
                addHandleToListInDict(obj.Handle, objects_by_layerHandle, obj.LayerHandle);
                addHandleToListInDict(obj.Handle, objects_by_materialHandle, obj.MaterialHandle);
            }
        }

        public void AddObject(Int32 handle, Int32 parentHandle, Int32 layerHandle, Int32 materialHandle,
                              String name, String objClass, String objSuperClass,
                              Boolean isGroupHead, Boolean isGroupMember,
                              Boolean isHidden, Boolean isFrozen, Boolean boxMode)
        {
            if (!hidden_particle_classes.Contains(objClass))
            {
                OutlinerObject obj = new OutlinerObject(this, ++objectCounter, handle, parentHandle, layerHandle, materialHandle, name, objClass, objSuperClass, isGroupHead, isGroupMember, isHidden, isFrozen, boxMode);
                this.AddObject(obj);
            }
        }


        public void AddLayer(OutlinerLayer layer)
        {
            if (!layers.ContainsKey(layer.Handle))
            {
                layers.Add(layer.Handle, layer);

                addHandleToListInDict(layer.Handle, layers_by_parentHandle, layer.ParentHandle);
            }
        }

        public void AddLayer(Int32 handle, Int32 parentHandle, String name, Boolean isActive, Boolean isHidden, Boolean isFrozen, Boolean boxMode)
        {
            OutlinerLayer layer = new OutlinerLayer(this, handle, parentHandle, name, isActive, isHidden, isFrozen, boxMode);
            AddLayer(layer);
        }


        public void AddMaterial(OutlinerMaterial mat)
        {
            if (!materials.ContainsKey(mat.Handle))
            {
                materials.Add(mat.Handle, mat);

                addHandleToListInDict(mat.Handle, materials_by_parentHandle, mat.ParentHandle);
            }
        }

        public void AddMaterial(Int32 handle, Int32 parentHandle, String name, String type)
        {
            OutlinerMaterial mat = new OutlinerMaterial(this, handle, parentHandle, name, type);
            AddMaterial(mat);
        }

        #endregion


        #region RemoveNode, RemoveObject, RemoveLayer, RemoveMaterial

        public void RemoveNode(OutlinerNode node)
        {
            if (node is OutlinerObject)
                RemoveObject((OutlinerObject)node);
            else if (node is OutlinerLayer)
                RemoveLayer((OutlinerLayer)node);
            else if (node is OutlinerMaterial)
                RemoveMaterial((OutlinerMaterial)node);
        }

        public void RemoveObject(OutlinerObject obj)
        {
            objects.Remove(obj.Handle);
            removeHandleFromListInDict(obj.Handle, objects_by_parentHandle, obj.ParentHandle);
            removeHandleFromListInDict(obj.Handle, objects_by_layerHandle, obj.LayerHandle);
            removeHandleFromListInDict(obj.Handle, objects_by_materialHandle, obj.MaterialHandle);
        }

        public void RemoveLayer(OutlinerLayer layer)
        {
            layers.Remove(layer.Handle);
            objects_by_layerHandle.Remove(layer.Handle);
            removeHandleFromListInDict(layer.Handle, layers_by_parentHandle, layer.Handle);
        }

        public void RemoveMaterial(OutlinerMaterial mat)
        {
            materials.Remove(mat.Handle);
            objects_by_materialHandle.Remove(mat.Handle);
            removeHandleFromListInDict(mat.Handle, materials_by_parentHandle, mat.ParentHandle);
        }

        #endregion


        #region SetObjectParent, SetObjectLayer, SetObjectMaterial, SetLayerParent

        public void SetObjectParentHandle(OutlinerObject obj, Int32 newParentHandle)
        {
            removeHandleFromListInDict(obj.Handle, objects_by_parentHandle, obj.ParentHandle);
            addHandleToListInDict(obj.Handle, objects_by_parentHandle, newParentHandle);
            obj.ParentHandle = newParentHandle;
        }

        public void SetObjectLayerHandle(OutlinerObject obj, Int32 newLayerHandle)
        {
            removeHandleFromListInDict(obj.Handle, objects_by_layerHandle, obj.LayerHandle);
            addHandleToListInDict(obj.Handle, objects_by_layerHandle, newLayerHandle);
            obj.LayerHandle = newLayerHandle;
        }

        public void SetObjectMaterialHandle(OutlinerObject obj, Int32 newMaterialHandle)
        {
            removeHandleFromListInDict(obj.Handle, objects_by_materialHandle, obj.MaterialHandle);
            addHandleToListInDict(obj.Handle, objects_by_materialHandle, newMaterialHandle);
            obj.MaterialHandle = newMaterialHandle;
        }

        public void SetLayerParentHandle(OutlinerLayer layer, Int32 newParentHandle)
        {
            removeHandleFromListInDict(layer.Handle, layers_by_parentHandle, layer.ParentHandle);
            addHandleToListInDict(layer.Handle, layers_by_parentHandle, newParentHandle);
            layer.ParentHandle = newParentHandle;
        }

        #endregion


        #region IsValidLayerName, IsValidMaterialName

        public Boolean IsValidLayerName(OutlinerLayer editingLayer, String newName)
        {
            if (newName == String.Empty)
                return false;

            foreach (KeyValuePair<Int32, OutlinerLayer> kvp in layers)
            {
                if (String.Compare(kvp.Value.Name, newName, true) == 0 && kvp.Value != editingLayer)
                    return false;
            }
            return true;
        }

        public Boolean IsValidLayerName(Int32 layerHandle, String newName)
        {
            OutlinerLayer layer;
            if (layers.TryGetValue(layerHandle, out layer))
                return IsValidLayerName(layer, newName);
            else
                return false;
        }

        public Boolean IsValidMaterialName(OutlinerMaterial editingMaterial, String newName)
        {
            if (newName == String.Empty)
                return false;

            foreach (KeyValuePair<Int32, OutlinerMaterial> kvp in materials)
            {
                if (String.Compare(kvp.Value.Name, newName, true) == 0 && kvp.Value != editingMaterial)
                    return false;
            }
            return true;
        }

        public Boolean IsValidMaterialName(Int32 materialHandle, String newName)
        {
            OutlinerMaterial mat;
            if (materials.TryGetValue(materialHandle, out mat))
                return IsValidMaterialName(mat, newName);
            else
                return false;
        }

        public Boolean ContainsMaterial(Int32 materialHandle)
        {
            return materials.ContainsKey(materialHandle);
        }

        #endregion



        #region List helper functions

        private delegate OutlinerNode getNodeFn(Int32 handle);
        private List<OutlinerNode> getNodesFromDict(Dictionary<Int32, List<Int32>> dict, Int32 listHandle, getNodeFn nodeFn)
        {
            List<Int32> nodeHandles;
            if (dict.TryGetValue(listHandle, out nodeHandles))
            {
                List<OutlinerNode> nodes = new List<OutlinerNode>(nodeHandles.Count);
                foreach (Int32 handle in nodeHandles)
                {
                    OutlinerNode node = nodeFn(handle);
                    if (node != null)
                        nodes.Add(node);
                }
                return nodes;
            }
            else
                return new List<OutlinerNode>(0);
        }

        private Int32 getNodesFromDictCount(Dictionary<Int32, List<Int32>> dict, Int32 listHandle)
        {
            List<Int32> nodeHandles;
            if (dict.TryGetValue(listHandle, out nodeHandles))
                return nodeHandles.Count;
            else
                return 0;
        }

        private void addHandleToListInDict(Int32 handle, Dictionary<Int32, List<Int32>> dict, Int32 listHandle)
        {
            List<Int32> list;
            if (!dict.TryGetValue(listHandle, out list))
            {
                list = new List<Int32>();
                dict.Add(listHandle, list);
            }
            list.Add(handle);
        }


        private void removeHandleFromListInDict(Int32 handle, Dictionary<Int32, List<Int32>> dict, Int32 listHandle)
        {
            List<Int32> list;
            if (dict.TryGetValue(listHandle, out list))
            {
                list.Remove(handle);
            }
        }

        #endregion
    }
}
