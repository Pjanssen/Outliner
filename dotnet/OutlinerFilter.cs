using System;
using System.Collections.Generic;
using System.Text;
using Outliner.Scene;
using System.Text.RegularExpressions;

namespace Outliner
{
    public class OutlinerFilter
    {
        public Boolean Enabled { get; set; }
        public Boolean AffectLayers { get; set; }

        public Boolean ShowGeometry { get; set; }
        public Boolean ShowShapes { get; set; }
        public Boolean ShowLights { get; set; }
        public Boolean ShowCameras { get; set; }
        public Boolean ShowHelpers { get; set; }
        public Boolean ShowSpaceWarps { get; set; }
        public Boolean ShowBones { get; set; }
        public Boolean ShowParticles { get; set; }
        public Boolean ShowXRefs { get; set; }
        public Boolean ShowGroups { get; set; }
        public Boolean ShowHidden { get; set; }
        public Boolean ShowFrozen { get; set; }

        private TreeView _tree;

        private String _nameFilter;
        private RegexOptions _nameFilterOptions;

        public String NameFilter 
        {
            get
            {
                return _nameFilter;
            }
            set
            {
                if (value == String.Empty)
                    _nameFilter = value;
                else
                {
                    // Escape the filter value.
                    _nameFilter = "^" + Regex.Escape(value);
                    
                    // Replace all escaped occurrences of * with [\w\s-]*.
                    _nameFilter = Regex.Replace(_nameFilter, @"(\\\*)", @"[\w\s-]*");
                }
            }
        }

        public Boolean NameFilterCaseSensitive
        {
            get
            {
                return _nameFilterOptions == RegexOptions.None;
            }
            set
            {
                if (value)
                    _nameFilterOptions = RegexOptions.None;
                else
                    _nameFilterOptions = RegexOptions.IgnoreCase;
            }
        }

        public OutlinerFilter(Outliner.TreeView tree)
        {
            _tree = tree;
            Enabled = false;
            AffectLayers = false;
            NameFilter = String.Empty;
            NameFilterCaseSensitive = false;

            ShowGeometry = ShowShapes = ShowLights = ShowCameras = ShowHelpers = ShowSpaceWarps =
            ShowBones = ShowParticles = ShowXRefs = ShowGroups = ShowHidden = ShowFrozen = true;
        }


        public Boolean ShowNode(OutlinerNode node)
        {
            if (node == null)
                return false;

            Boolean nodeVisible = true;
            if (node is OutlinerObject)
                nodeVisible = ObjectIsVisible((OutlinerObject)node);
            else if (node is OutlinerLayer)
                nodeVisible = LayerIsVisible((OutlinerLayer)node);
            else if (node is OutlinerMaterial)
                nodeVisible = MaterialIsVisible((OutlinerMaterial)node);


            Boolean childNodesVisible;
            if (_tree.ListMode != OutlinerListMode.Hierarchy && node is OutlinerObject)
                childNodesVisible = false;
            else if (!Enabled && NameFilter == String.Empty)
                childNodesVisible = true;
            else
                childNodesVisible = ShowChildNodes(node);

            node.Filtered = !nodeVisible;

            return nodeVisible || childNodesVisible;
        }

        private Boolean ShowChildNodes(OutlinerNode node)
        {
            if (node == null || node.ChildNodesCount == 0)
                return false;

            foreach (OutlinerNode child in node.ChildNodes)
            {
                if (ShowNode(child))
                    return true;
            }

            return false;
        }



        private Boolean ObjectIsVisible(OutlinerObject obj)
        {
            // If the filter is disabled, all objects are shown.
            if (!Enabled && NameFilter == String.Empty) return true;

            if (NameFilter != String.Empty)
            {
                if (!Regex.IsMatch(obj.Name, NameFilter, _nameFilterOptions))
                    return false;
                else if (!Enabled)
                    return true;
            }

            if (!ShowHidden || !ShowFrozen)
            {
                OutlinerLayer objLayer = obj.Layer;
                if (!ShowHidden && (obj.IsHidden || (objLayer != null && objLayer.IsHidden))) return false;
                if (!ShowFrozen && (obj.IsFrozen || (objLayer != null && objLayer.IsFrozen))) return false;
            }

            if (!ShowXRefs && obj.Class == OutlinerScene.XrefObjectType) return false;
            if (!ShowGroups && (obj.IsGroupHead || obj.IsGroupMember)) return false;

            if (!ShowShapes && obj.SuperClass == OutlinerScene.ShapeType) return false;
            if (!ShowLights && obj.SuperClass == OutlinerScene.LightType) return false;
            if (!ShowCameras && obj.SuperClass == OutlinerScene.CameraType) return false;
            if (!ShowHelpers && obj.SuperClass == OutlinerScene.HelperType && !obj.IsGroupHead) return false;
            if (!ShowSpaceWarps && obj.SuperClass == OutlinerScene.SpacewarpType) return false;

            if ((!ShowBones || !ShowParticles || !ShowGeometry || !ShowHelpers) && obj.SuperClass == OutlinerScene.GeometryType)
            {
                if (obj.Class == OutlinerScene.BoneType || obj.Class == OutlinerScene.BipedType)
                    return ShowBones;
                else if (obj.Class == OutlinerScene.TargetType)
                    return ShowHelpers;
                else if (obj.Class == OutlinerScene.PfSourceType || obj.Class == OutlinerScene.PCloudType ||
                         obj.Class == OutlinerScene.PArrayType || obj.Class == OutlinerScene.PBlizzardType ||
                         obj.Class == OutlinerScene.PSprayType || obj.Class == OutlinerScene.PSuperSprayType ||
                         obj.Class == OutlinerScene.PSnowType)
                    return ShowParticles;
                else
                    return ShowGeometry;
            }

            return true;
        }


        private Boolean LayerIsVisible(OutlinerLayer layer)
        {
            if (NameFilter != String.Empty && !Regex.IsMatch(layer.Name, NameFilter, _nameFilterOptions))
               return false;

            if (AffectLayers)
            {
                if (Enabled && !ShowHidden && layer.IsHidden) return false;
                if (Enabled && !ShowFrozen && layer.IsFrozen) return false;
            }

            return true;
        }


        private Boolean MaterialIsVisible(OutlinerMaterial mat)
        {
            if (NameFilter != String.Empty && !Regex.IsMatch(mat.Name, NameFilter, _nameFilterOptions))
                return false;

            if (mat.IsUnassigned && mat.ChildNodesCount == 0)
                return false;

            return true;
        }
    }
}
