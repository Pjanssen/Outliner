using System;
using System.Collections.Generic;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner
{
    internal enum NodeColor
    {
        Default = 0x01,
        Selected = 0x02,
        ParentOfSelected = 0x04,
        LinkTarget = 0x8
    }

    public class TreeStyle
    {
        private TreeView _tree;

        Font _frozenFont;
        public Font FrozenFont
        {
            get { return _frozenFont; }
        }

        public Color BackColor 
        {
            get { return _tree.BackColor; }
            set { _tree.BackColor = value; }
        }

        public Color LineColor
        {
            get { return _tree.LineColor; }
            set { _tree.LineColor = value; }
        }

        public Color NodeForeColor { get; set; }
        public Color NodeBackColor { get; set; }

        public Color FrozenForeColor { get; set; }
        public Color FrozenBackColor { get; set; }

        public Color HiddenForeColor { get; set; }
        public Color HiddenBackColor { get; set; }

        public Color XrefForeColor { get; set; }
        public Color XrefBackColor { get; set; }

        public Color SelectionForeColor { get; set; }
        public Color SelectionBackColor { get; set; }

        public Color LinkForeColor { get; set; }
        public Color LinkBackColor { get; set; }

        public Color ParentForeColor { get; set; }
        public Color ParentBackColor { get; set; }

        public Color LayerForeColor { get; set; }
        public Color LayerBackColor { get; set; }


        public TreeStyle(TreeView tree)
        {
            _tree = tree;
            _frozenFont = new Font(_tree.Font, FontStyle.Italic);

            NodeForeColor = SystemColors.WindowText;
            NodeBackColor = SystemColors.Window;
            FrozenForeColor = SystemColors.GrayText;
            FrozenBackColor = SystemColors.Window;
            HiddenForeColor = SystemColors.GrayText;
            HiddenBackColor = SystemColors.Window;
            XrefForeColor = SystemColors.WindowText;
            XrefBackColor = SystemColors.Window;

            SelectionForeColor = SystemColors.HighlightText;
            SelectionBackColor = SystemColors.Highlight;

            LinkForeColor = SystemColors.WindowText;
            LinkBackColor = Color.FromArgb(255, 177, 177);

            ParentForeColor = SystemColors.WindowText;
            ParentBackColor = Color.FromArgb(177, 255, 177);

            LayerForeColor = SystemColors.WindowText;
            LayerBackColor = Color.FromArgb(177, 228, 255);
        }


        /*
        internal void SetNodeStyle(TreeNode node, Boolean selected)
        {
            SetNodeImageKey(node);
            SetNodeColor(node, (selected) ? NodeColor.Selected : NodeColor.Default);
        }
        */

        internal void SetNodeColor(TreeNode tn, NodeColor color)
        {
            switch (color)
            {
                case NodeColor.Default:
                    tn.ForeColor = GetNodeForeColor((OutlinerNode)tn.Tag);
                    tn.BackColor = GetNodeBackColor((OutlinerNode)tn.Tag);
                    break;
                case NodeColor.Selected:
                    tn.ForeColor = this.SelectionForeColor;
                    tn.BackColor = this.SelectionBackColor;
                    break;
                case NodeColor.ParentOfSelected:
                    if (tn.Tag is OutlinerObject)
                    {
                        tn.ForeColor = this.ParentForeColor;
                        tn.BackColor = this.ParentBackColor;
                    }
                    else if (tn.Tag is OutlinerLayer)
                    {
                        tn.ForeColor = this.LayerForeColor;
                        tn.BackColor = this.LayerBackColor;
                    }
                    else
                    {
                        tn.ForeColor = GetNodeForeColor((OutlinerNode)tn.Tag);
                        tn.BackColor = GetNodeBackColor((OutlinerNode)tn.Tag);
                    }
                    break;
                case NodeColor.LinkTarget:
                    tn.ForeColor = this.LinkForeColor;
                    tn.BackColor = this.LinkBackColor;
                    break;
            }
        }

        internal void SetNodeColor(TreeNode tn, Color foreColor, Color backColor)
        {
            tn.ForeColor = foreColor;
            tn.BackColor = backColor;
        }

        internal void SetNodeColorAuto(TreeNode tn)
        {
            NodeColor nodeColor;
            if (_tree.IsNodeSelected(tn))
                nodeColor = NodeColor.Selected;
            else if (_tree.IsParentOfSelectedNode(tn, true))
                nodeColor = NodeColor.ParentOfSelected;
            else
                nodeColor = NodeColor.Default;

            SetNodeColor(tn, nodeColor);
        }

        private Color GetNodeForeColor(OutlinerNode node)
        {
            if (node is IDisplayable && ((IDisplayable)node).IsHidden)
                return HiddenForeColor;
            else if (node is IDisplayable && ((IDisplayable)node).IsFrozen)
                return FrozenForeColor;
            else if (node is OutlinerObject && ((OutlinerObject)node).Class == OutlinerScene.XrefObjectType)
                return XrefForeColor;
            else
                return NodeForeColor;
        }

        private Color GetNodeBackColor(OutlinerNode node)
        {
            if (node is IDisplayable && ((IDisplayable)node).IsHidden)
                return HiddenBackColor;
            else if (node is IDisplayable && ((IDisplayable)node).IsFrozen)
                return FrozenBackColor;
            else if (node is OutlinerObject && ((OutlinerObject)node).Class == OutlinerScene.XrefObjectType)
                return XrefBackColor;
            else
                return NodeBackColor;
        }





        internal void SetNodeImageKey(TreeNode tn)
        {
            tn.ImageKey = GetImageKey((OutlinerNode)tn.Tag);
        }

        private String GetImageKey(OutlinerNode node)
        {
            String imgKey = "unknown";

            if (node is OutlinerObject)
                imgKey = GetObjectImageKey((OutlinerObject)node);
            else if (node is OutlinerLayer)
                imgKey = GetLayerImageKey((OutlinerLayer)node);
            else if (node is OutlinerMaterial)
                imgKey = GetMaterialImageKey((OutlinerMaterial)node);

            return imgKey;
        }


        private String GetLayerImageKey(OutlinerLayer layer)
        {
            if (layer.IsActive)
                return "layer_active";
            else
                return "layer";
        }


        private String GetMaterialImageKey(OutlinerMaterial mat)
        {
            if (mat.IsUnassigned)
                return "material_unassigned";
            else if (mat.Type == OutlinerScene.XrefMaterialType)
                return "material_xref";
            else
                return "material";
        }


        private String GetObjectImageKey(OutlinerObject obj)
        {
            if (obj.Class == OutlinerScene.XrefObjectType)
                return (obj.IsGroupHead) ? "xref_group" : "xref";
            else if (obj.IsGroupHead)
                return "group";
            else if (obj.SuperClass == OutlinerScene.GeometryType)
            {
                if (obj.Class == OutlinerScene.TargetType)
                    return "helper";
                else if (obj.Class == OutlinerScene.BoneType || obj.Class == OutlinerScene.BipedType)
                    return "bone";
                else if (obj.Class == OutlinerScene.PfSourceType || obj.Class == OutlinerScene.PCloudType ||
                         obj.Class == OutlinerScene.PArrayType || obj.Class == OutlinerScene.PBlizzardType ||
                         obj.Class == OutlinerScene.PSprayType || obj.Class == OutlinerScene.PSuperSprayType ||
                         obj.Class == OutlinerScene.PSnowType)
                    return "particle";
                // Assumption: Only PowerNurbs classes start with "Pwr_"
                else if (obj.Class == OutlinerScene.NurbsCvSurfType || obj.Class == OutlinerScene.NurbsPtSurfType || obj.Class.StartsWith(OutlinerScene.PowerNurbsPrefixType))
                    return "nurbs";
                else if (obj.Class == OutlinerScene.PatchQuadType || obj.Class == OutlinerScene.PatchTriType || obj.Class == OutlinerScene.PatchEditableType)
                    return "nurbs";
                else
                    return "geometry";
            }
            else if (obj.SuperClass == OutlinerScene.SpacewarpType)
                return "spacewarp";
            else if (obj.SuperClass == OutlinerScene.HelperType)
                if (obj.Class == OutlinerScene.ContainerType)
                    return (obj.ChildNodesCount > 0) ? "container" : "container_closed";
                else if (obj.Class == OutlinerScene.PBirthTextureType || obj.Class == OutlinerScene.PSpeedByIconType ||
                         obj.Class == OutlinerScene.PGroupSelectionType || obj.Class == OutlinerScene.PFindTargetType ||
                         obj.Class == OutlinerScene.PInitialStateType || obj.Class == OutlinerScene.ParticlePaintType)
                    return "particle";
                else
                    return "helper";
            else
                // shape, light, camera
                return obj.SuperClass;
        }

    }
}
