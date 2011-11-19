using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Linq;
using System.Resources;
using System.Runtime.InteropServices;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;
using Outliner.DragDropHandlers;
using Outliner.Scene;

namespace Outliner
{
    public partial class TreeView : System.Windows.Forms.TreeView
    {
        private Dictionary<OutlinerNode, TreeNode> _treeNodes;
        private HashSet<OutlinerNode> _selectedNodes;
        private HashSet<OutlinerNode> _expandedNodes;
        private Boolean _restoringExpandedStates;

        private Timer _updateTimer;
        private Boolean _updateWaitingForSort;
        private Timer _sortTimer;
        private Timer _ensureSelectionVisibleTimer;
        private EnsureSelectionVisibleAction _ensureSelectionVisibleAction;
        private Boolean _ensureSelectionVisibleWaitingForSort;

        public OutlinerScene Scene { get; private set; }
        public TreeStyle Style { get; private set; }
        public OutlinerFilter Filter { get; private set; }

        public OutlinerListMode ListMode { get; set; }

        #region Node buttons

        public IconClickAction IconClickAction { get; set; }

        private NodeButtonsLocation _nodeButtonsLocation;
        public NodeButtonsLocation NodeButtonsLocation 
        {
            get { return _nodeButtonsLocation; }
            set { _nodeButtonsLocation = value; Invalidate(); }
        }

        public Boolean ShowNodeIcon
        {
            get { return _icons != null && _icons.Count > 0; }
        }

        private Boolean _showNodeHideButton;
        public Boolean ShowNodeHideButton 
        {
            get { return _showNodeHideButton; }
            set { _showNodeHideButton = value; Invalidate(); }
        }

        private Boolean _showNodeFreezeButton;
        public Boolean ShowNodeFreezeButton 
        {
            get { return _showNodeFreezeButton; }
            set { _showNodeFreezeButton = value; Invalidate(); }
        }

        #endregion

        public Boolean HighlighLastSelectedObject { get; set; }
        public Keys ExpandHierarchyKey { get; set; }
        public MouseButtons DragMouseButton { get; set; }
        public DoubleClickAction DoubleClickAction { get; set; }

        #region AutoExpand

        private Boolean _autoExpandHierarchy = false;
        public Boolean AutoExpandHierarchy
        {
            get { return _autoExpandHierarchy; }
            set
            {
                _autoExpandHierarchy = value;
                if (value && ListMode == OutlinerListMode.Hierarchy) this.ExpandAll();
            }
        }
        private Boolean _autoExpandLayer = false;
        public Boolean AutoExpandLayer
        {
            get { return _autoExpandLayer; }
            set
            {
                _autoExpandLayer = value;
                if (value && ListMode == OutlinerListMode.Layer) this.ExpandAll();
            }
        }
        private Boolean _autoExpandMaterial = false;
        public Boolean AutoExpandMaterial
        {
            get { return _autoExpandMaterial; }
            set
            {
                _autoExpandMaterial = value;
                if (value && ListMode == OutlinerListMode.Material) this.ExpandAll();
            }
        }

        #endregion

        private Boolean _hideGroupMembersLayerMode = true;
        public Boolean HideGroupMembersLayerMode
        { 
            get { return _hideGroupMembersLayerMode; }
            set 
            { 
                _hideGroupMembersLayerMode = value; 
                FillTree(); 
            }
        }


        public TreeView()
        {
            InitializeComponent();

            this.SetStyle(ControlStyles.UserPaint, true);
            this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
            this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);

            AllowDrop = true;

            Scene = new OutlinerScene();
            Style = new TreeStyle(this);
            Filter = new OutlinerFilter();

            ListMode = OutlinerListMode.Hierarchy;

            IconClickAction = IconClickAction.Hide;
            NodeButtonsLocation = NodeButtonsLocation.BeforeNode;
            ShowNodeHideButton = true;
            ShowNodeFreezeButton = true;

            HighlighLastSelectedObject = false;

            AutoExpandHierarchy = false;
            AutoExpandLayer = false;
            AutoExpandMaterial = false;

            ExpandHierarchyKey = Keys.Control;
            DragMouseButton = MouseButtons.Middle;
            DoubleClickAction = DoubleClickAction.Rename;


            _treeNodes = new Dictionary<OutlinerNode, TreeNode>();
            _selectedNodes = new HashSet<OutlinerNode>();
            _expandedNodes = new HashSet<OutlinerNode>();

            _treeDragDropHandler = new TreeDragDropHandler(this, Scene);

            _updateTimer = new Timer();
            _updateTimer.Interval = 40;
            _updateTimer.Tick += new EventHandler(updateTimer_Tick);

            _sortTimer = new Timer();
            _sortTimer.Interval = 60;
            _sortTimer.Tick += new EventHandler(sortTimer_Tick);

            _updateWaitingForSort = false;

            _ensureSelectionVisibleTimer = new Timer();
            _ensureSelectionVisibleTimer.Interval = 50;
            _ensureSelectionVisibleTimer.Tick += new EventHandler(_ensureSelectionVisibleTimer_Tick);
            _ensureSelectionVisibleAction = EnsureSelectionVisibleAction.None;
            _ensureSelectionVisibleWaitingForSort = false;
        }


        

       

        


        

        public TreeView(IContainer container) : this()
        {
            container.Add(this);
        }


        #region DetachHandlers

        private void DetachTimerHandlers()
        {
            if (_updateTimer != null)
                _updateTimer.Tick -= new EventHandler(updateTimer_Tick);
            if (_sortTimer != null)
                _sortTimer.Tick -= new EventHandler(sortTimer_Tick);
        }

        #endregion



        // Avoid tooltips popping up when a treenode's text is outside the bounds (gives draw error)
        protected override CreateParams CreateParams
        {
            get
            {
                CreateParams parms = base.CreateParams;
                parms.Style |= 0x80; // Turn on TVS_NOTOOLTIPS 
                return parms; 
            }
        }





        #region Helper functions

        public Int32 GetNodeCount()
        {
            return _treeNodes.Count;
        }

        // Re-applies the node style for all nodes in the tree.
        public void ResetAllNodesStyle()
        {
            ResetNodeStyleIntern(this.Nodes);
            HighlightAllParents();
        }

        private void ResetNodeStyleIntern(TreeNodeCollection col)
        {
            foreach (TreeNode tn in col)
            {
                Style.SetNodeImageKey(tn);
                Style.SetNodeColorAuto(tn);
                ResetNodeStyleIntern(tn.Nodes);
            }
        }


        internal OutlinerNode[] SelectedOutlinerNodes
        {
            get { return _selectedNodes.ToArray(); }
        }

        private void RestoreSelection(OutlinerNode[] selection)
        {
            _selectedNodes.Clear();

            foreach (OutlinerNode n in selection)
            {
                SelectNode(n, true);
            }

            BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction.SelectionChanged);
            _selectionChanged = false;
        }

        private void RestoreExpandedStates()
        {
            _restoringExpandedStates = true;
            if ((ListMode == OutlinerListMode.Hierarchy && AutoExpandHierarchy) || (ListMode == OutlinerListMode.Layer && AutoExpandLayer))
                ExpandAll();
            else
            {
                foreach (OutlinerNode n in _expandedNodes)
                {
                    TreeNode tn;
                    if (_treeNodes.TryGetValue(n, out tn))
                        if (!tn.IsExpanded)
                            tn.Expand();
                }
            }
            _restoringExpandedStates = false;
        }


        internal Boolean IsNodeSelected(OutlinerNode n)
        {
            if (n == null)
                return false;

            return _selectedNodes.Contains(n);
        }

        internal Boolean IsNodeSelected(TreeNode tn)
        {
            if (tn == null || !(tn.Tag is OutlinerNode))
                return false;

            return IsNodeSelected((OutlinerNode)tn.Tag);
        }



        internal Boolean IsParentOfSelectedNode(TreeNode tn, Boolean entireHierarchy)
        {
            if (tn != null)
            {
                foreach (OutlinerNode n in _selectedNodes)
                {
                    if (n.MarkedForDelete)
                        continue;

                    TreeNode cn;
                    if (_treeNodes.TryGetValue(n, out cn))
                    {
                        if (!entireHierarchy)
                        {
                            if (cn.Parent == tn)
                                return true;
                        }
                        else
                        {
                            while (cn != null)
                            {
                                cn = cn.Parent;
                                if (cn == tn)
                                    return true;
                            }
                        }
                    }
                }
            }
            return false;
        }



        internal Boolean IsChildOfSelectedNode(TreeNode tn)
        {
            if (tn != null)
            {
                TreeNode parentNode = tn.Parent;
                while (parentNode != null)
                {
                    if (IsNodeSelected(parentNode))
                        return true;

                    parentNode = parentNode.Parent;
                }
            }
            return false;
        }


        internal Boolean IsChildOfSelectedNode(OutlinerNode n)
        {
            if (n == null)
                return false;

            TreeNode tn;
            if (_treeNodes.TryGetValue(n, out tn))
                return IsChildOfSelectedNode(tn);
            else
                return false;
        }


        internal Boolean IsChildOfNode(TreeNode cn, TreeNode pn)
        {
            if (cn != null && pn != null)
            {
                while (cn != null)
                {
                    if (cn == pn)
                        return true;
                    cn = cn.Parent;
                }
            }
            return false;
        }



        private OutlinerNode GetHighestParentToAdd(OutlinerNode o)
        {
            if (ListMode == OutlinerListMode.Layer)
                return o;
            else
            {
                // Keeping prevParentNode reference (previous parentNode inspected) to avoid having to do dictionary lookup twice for each iteration.
                OutlinerNode parentNode = o;
                OutlinerNode prevParentNode = o;
                while (parentNode != null && !_treeNodes.ContainsKey(parentNode))
                {
                    prevParentNode = parentNode;
                    parentNode = parentNode.Parent;
                }
                return prevParentNode;
            }
        }

        private OutlinerNode GetHighestParentToRemove(OutlinerNode o)
        {
            if (ListMode == OutlinerListMode.Layer)
                return o;
            else
            {
                // Keeping prevParentNode reference (previous parentNode inspected) to avoid having to do dictionary lookup twice for each iteration.
                OutlinerNode parentNode = o.Parent;
                OutlinerNode prevParentNode = o;
                while (parentNode != null && !this.Filter.ShowNode(parentNode))
                {
                    prevParentNode = parentNode;
                    parentNode = parentNode.Parent;
                }
                return prevParentNode;
            }
        }


        internal List<Int32> getChildNodeHandlesRecursive(OutlinerNode node)
        {
            List<Int32> childHandles = new List<Int32>();
            foreach (OutlinerNode cn in node.ChildNodes)
            {
                childHandles.Add(cn.Handle);
                childHandles.AddRange(getChildNodeHandlesRecursive(cn));
            }
            return childHandles;
        }


        private Boolean hasCollapsedParents(TreeNode tn)
        {
            if (tn == null)
                return false;

            TreeNode parent = tn.Parent;
            while (parent != null)
            {
                if (!parent.IsExpanded)
                    return true;

                parent = parent.Parent;
            }
            return false;
        }

        #endregion






        #region Paint

        private Int32 _indent = 16;
        public new Int32 Indent
        {
            get { return _indent; }
            set { _indent = value; }
        }


        private Pen _dottedLinePen;
        new public Color LineColor
        {
            get { return base.LineColor; }
            set
            {
                base.LineColor = value;
                createLinePen();
            }
        }

        private SolidBrush _backgroundBrush;
        public override Color BackColor
        {
            get { return base.BackColor; }
            set
            {
                _backgroundBrush = new SolidBrush(value);
                base.BackColor = value;
            }
        }

        private void createLinePen()
        {
            _dottedLinePen = new Pen(LineColor);
            _dottedLinePen.DashStyle = System.Drawing.Drawing2D.DashStyle.Dot;
        }

        protected override void OnPaintBackground(PaintEventArgs pevent)
        {
            if (_backgroundBrush == null)
                _backgroundBrush = new SolidBrush(BackColor);

            pevent.Graphics.FillRectangle(_backgroundBrush, pevent.ClipRectangle);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            if (Nodes.Count == 0)
                return;

            if (_dottedLinePen == null)
                createLinePen();

            Int32 curY = e.ClipRectangle.Y;
            while(curY <= e.ClipRectangle.Bottom)
            {
                TreeNode tn = GetNodeAt(0, curY);
                if (tn != null)
                {
                    Rectangle tnBounds = tn.Bounds;
                    if (tnBounds.Width != 0 && tnBounds.Height != 0)
                    {
                        if (tn.ImageKey == "")
                            Style.SetNodeImageKey(tn);
                        else
                            DrawCustomNode(tn, e.Graphics);
                    }
                }

                curY += ItemHeight;
            }
        }


        

        private const Int32 _plusMinSize = 9;
        private const Int32 _halfPlusMinSize = _plusMinSize / 2;
        private Point _plusMinOffset = new Point(4, 4);
        private Point _iconOffset = new Point(5, 0);

        protected void DrawCustomNode(TreeNode tn, Graphics graphics)
        {
            Rectangle tnBounds = tn.Bounds;
            Object tnTag = tn.Tag;
            Int32 scrlPosX = GetScrollPos(Handle, H_SCROLL);
            //Draw vertical line segments for parent nodes with next nodes.
            Int32 xPos = Indent * tn.Level + _plusMinOffset.X - scrlPosX;
            TreeNode parent = tn.Parent;
            while (parent != null)
            {
                xPos -= Indent;
                if (parent.NextNode != null)
                {
                    Int32 x = xPos + _halfPlusMinSize;
                    graphics.DrawLine(_dottedLinePen, x, tnBounds.Y, x, tnBounds.Bottom);
                }
                parent = parent.Parent;
            }
            
            //Draw L / T shaped line in front of node.
            Int32 lineX = Indent * tn.Level + _plusMinOffset.X + _halfPlusMinSize - scrlPosX;
            Int32 nodeYMid = tnBounds.Y + (int)Math.Ceiling(ItemHeight / 2f) -1;
            Int32 vlineStartY;
            Int32 vlineEndY;

            if (tn.Parent == null && tn.Index == 0)
                vlineStartY = nodeYMid;
            else
                vlineStartY = tnBounds.Y;
            
            if (tn.NextNode == null)
                vlineEndY = nodeYMid;
            else
                vlineEndY = tnBounds.Bottom;

            graphics.DrawLine(_dottedLinePen, lineX, vlineStartY, lineX, vlineEndY);
            graphics.DrawLine(_dottedLinePen, lineX, nodeYMid, lineX + _halfPlusMinSize + _iconOffset.X, nodeYMid);


            //Draw plusminus.
            if (tn.GetNodeCount(false) != 0)
            {
                if (Application.RenderWithVisualStyles)
                {
                    VisualStyleElement element = (tn.IsExpanded) ? VisualStyleElement.TreeView.Glyph.Opened : VisualStyleElement.TreeView.Glyph.Closed;
                    VisualStyleRenderer renderer = new VisualStyleRenderer(element);
                    renderer.DrawBackground(graphics, GetPlusMinusBounds(tn));
                }
                else
                {
                    DrawPlusMinus(graphics, GetPlusMinusBounds(tn), tn.IsExpanded);
                }
            }

            if (ShowNodeHideButton && tnTag is IHidable)
            {
                if (((IHidable)tnTag).IsHidden)
                    graphics.DrawImage(OutlinerResources.hide_button, GetHideButtonBounds(tn));
                else
                    graphics.DrawImage(OutlinerResources.hide_button_disabled, GetHideButtonBounds(tn));
            }

            if (ShowNodeFreezeButton && tnTag is IFreezable)
            {
                if (((IFreezable)tnTag).IsFrozen)
                    graphics.DrawImage(OutlinerResources.freeze_button, GetFreezeButtonBounds(tn));
                else
                    graphics.DrawImage(OutlinerResources.freeze_button_disabled, GetFreezeButtonBounds(tn));
            }

            //Draw icon.
            if (ShowNodeIcon)
            {
                Bitmap img;
                String imgKey = tn.ImageKey;
                if (tnTag is OutlinerNode && ((OutlinerNode)tnTag).Filtered)
                {
                    imgKey += "_filtered";
                }
                else if (!ShowNodeHideButton && IconClickAction == IconClickAction.Hide)
                {
                    if (tnTag is IHidable && ((IHidable)tnTag).IsHidden)
                        imgKey += "_hidden";
                }
                else if (!ShowNodeFreezeButton && IconClickAction == IconClickAction.Freeze)
                {
                    if (tnTag is IFreezable && ((IFreezable)tnTag).IsFrozen)
                        imgKey += "_hidden";
                }
                if (_icons.TryGetValue(imgKey, out img))
                    graphics.DrawImage(img, GetImageBounds(tn));
            }

            //Draw background & Text.
            if (!tn.IsEditing)
            {
                Rectangle txtBgBounds = GetTextBackgroundBounds(tn, false);
                Point txtLocation = txtBgBounds.Location;

                Font f = Font;
                if (tn.Tag is IFreezable && ((IFreezable)tn.Tag).IsFrozen)
                {
                    f = Style.FrozenFont;
                    txtLocation.X -= 2;
                }
                if (HighlighLastSelectedObject && tn.Tag == _lastSelectedObject && IsNodeSelected(tn))
                    f = new Font(Font, f.Style | FontStyle.Bold);
                
                SizeF txtSize = graphics.MeasureString(tn.Text, f);
                txtBgBounds.Width = (int)txtSize.Width + 3;

                txtLocation.Y += (Int32)((float)ItemHeight - txtSize.Height) / 2 + 1;

                Color foreColor;
                if (tnTag is OutlinerNode && ((OutlinerNode)tnTag).Filtered)
                    foreColor = Color.FromArgb(50, tn.ForeColor.R, tn.ForeColor.G, tn.ForeColor.B);
                else
                    foreColor = tn.ForeColor;

                using (SolidBrush bgBrush = new SolidBrush(tn.BackColor), fgBrush = new SolidBrush(foreColor))
                {
                    graphics.FillRectangle(bgBrush, txtBgBounds);
                    graphics.DrawString(tn.Text, f, fgBrush, txtLocation);
                }
            }
        }

        private void DrawPlusMinus(Graphics graphics, Rectangle bounds, Boolean isExpanded)
        {
            ControlPaint.DrawButton(graphics, bounds, ButtonState.Normal);
            
            bounds.Width -= 1;
            bounds.Height -= 1;
            graphics.DrawLine(SystemPens.ControlText, bounds.X + 2, bounds.Y + bounds.Height / 2, bounds.X + bounds.Width - 2, bounds.Y + bounds.Height / 2);
            if (!isExpanded)
                graphics.DrawLine(SystemPens.ControlText, bounds.X + bounds.Width / 2, bounds.Y + 2, bounds.X + bounds.Width / 2, bounds.Y + bounds.Height - 2);
        }

        #endregion



        #region Node Bounds methods

        protected Rectangle GetNodeBounds(TreeNode tn)
        {
            Rectangle tnBounds = tn.Bounds;
            Rectangle b = new Rectangle();
            b.X = Indent * tn.Level - GetScrollPos(Handle, H_SCROLL);
            b.Y = tnBounds.Y;
            b.Width = _plusMinOffset.X + _plusMinSize + tnBounds.Width - 1;
            if (ShowNodeIcon) b.Width += _iconOffset.X * 2 + _iconSize.Width;
            if (ShowNodeHideButton && tn.Tag is IHidable) b.Width += _hideButtonSize.Width;
            if (ShowNodeFreezeButton && tn.Tag is IFreezable) b.Width += _freezeButtonSize.Width;
            b.Height = ItemHeight;
            return b;
        }



        private Rectangle GetPlusMinusBounds(TreeNode tn)
        {
            if (tn == null)
                return Rectangle.Empty;

            Rectangle r = new Rectangle();
            r.X = Indent * tn.Level + _plusMinOffset.X - GetScrollPos(Handle, H_SCROLL);
            r.Y = tn.Bounds.Y + (ItemHeight - _plusMinSize) / 2;
            r.Width = _plusMinSize;
            r.Height = _plusMinSize;
            return r;
        }

        



        private Rectangle GetImageBounds(TreeNode tn)
        {
            if (tn == null || !ShowNodeIcon)
                return Rectangle.Empty;

            Rectangle r = new Rectangle();
            r.X = Indent * tn.Level + _plusMinOffset.X + _plusMinSize + _iconOffset.X - GetScrollPos(Handle, H_SCROLL);
            if (NodeButtonsLocation == NodeButtonsLocation.BeforeNode)
            {
                if (ShowNodeHideButton && tn.Tag is IHidable) r.X += _hideButtonSize.Width + 1;
                if (ShowNodeFreezeButton && tn.Tag is IFreezable) r.X += _freezeButtonSize.Width + 1;
            }
            r.Y = tn.Bounds.Y + (ItemHeight - _iconSize.Height) / 2;
            r.Width = _iconSize.Width;
            r.Height = _iconSize.Height;
            return r;
        }

        


        private Rectangle GetTextBackgroundBounds(TreeNode tn, Boolean includeIconSpacing)
        {
            if (tn == null)
                return Rectangle.Empty;

            Rectangle r = tn.Bounds;
            r.X = Indent * tn.Level + _plusMinOffset.X + _plusMinSize - GetScrollPos(Handle, H_SCROLL);
            if (NodeButtonsLocation == NodeButtonsLocation.BeforeNode)
            {
                if (ShowNodeHideButton && tn.Tag is IHidable) r.X += _hideButtonSize.Width + 1;
                if (ShowNodeFreezeButton && tn.Tag is IFreezable) r.X += _freezeButtonSize.Width + 1;
            }
            if (ShowNodeIcon)
                r.X += _iconSize.Width;

            r.Width -= 1;
            r.X += _iconOffset.X;
            if (includeIconSpacing)
                r.Width += _iconOffset.X;
            else
                r.X += _iconOffset.X;

            return r;
        }

        private Size _hideButtonSize = new Size(10, 16);
        private Rectangle GetHideButtonBounds(TreeNode tn)
        {
            if (tn == null || !ShowNodeHideButton || !(tn.Tag is IHidable))
                return Rectangle.Empty;

            Rectangle r = new Rectangle();
            if (NodeButtonsLocation == NodeButtonsLocation.BeforeNode)
                r.X = Indent * tn.Level + _plusMinOffset.X + _plusMinSize + _iconOffset.X - GetScrollPos(Handle, H_SCROLL);
            else if (NodeButtonsLocation == NodeButtonsLocation.AfterNode)
                r.X = GetTextBackgroundBounds(tn, false).Right - GetScrollPos(Handle, H_SCROLL);
            else if (NodeButtonsLocation == NodeButtonsLocation.AlignRight)
            {
                if (ShowNodeFreezeButton && tn.Tag is IFreezable)
                    r.X = ClientRectangle.Right - _freezeButtonSize.Width - _hideButtonSize.Width - 2 - GetScrollPos(Handle, H_SCROLL);
                else
                    r.X = ClientRectangle.Right - _hideButtonSize.Width - 2 - GetScrollPos(Handle, H_SCROLL);
            }

            r.Y = tn.Bounds.Y + (ItemHeight - _hideButtonSize.Height) / 2;
            r.Size = _hideButtonSize;
            
            return r;
        }



        private Size _freezeButtonSize = new Size(14, 16);
        private Rectangle GetFreezeButtonBounds(TreeNode tn)
        {
            if (tn == null || !ShowNodeFreezeButton || !(tn.Tag is IFreezable))
                return Rectangle.Empty;

            Rectangle r = new Rectangle();
            if (NodeButtonsLocation == NodeButtonsLocation.BeforeNode)
            {
                if (ShowNodeHideButton && tn.Tag is IHidable)
                    r.X = Indent * tn.Level + _plusMinOffset.X + _plusMinSize + _iconOffset.X + _hideButtonSize.Width - GetScrollPos(Handle, H_SCROLL);
                else
                    r.X = Indent * tn.Level + _plusMinOffset.X + _plusMinSize + _iconOffset.X - GetScrollPos(Handle, H_SCROLL);
            }
            else if (NodeButtonsLocation == NodeButtonsLocation.AfterNode)
            {
                if (ShowNodeHideButton && tn.Tag is IHidable)
                    r.X = GetTextBackgroundBounds(tn, false).Right + _hideButtonSize.Width + 2 - GetScrollPos(Handle, H_SCROLL);
                else
                    r.X = GetTextBackgroundBounds(tn, false).Right - GetScrollPos(Handle, H_SCROLL);
            }
            else if (NodeButtonsLocation == NodeButtonsLocation.AlignRight)
                r.X = ClientRectangle.Right - _freezeButtonSize.Width - 2;

            r.Y = tn.Bounds.Y + (ItemHeight - _freezeButtonSize.Height) / 2;
            r.Size = _freezeButtonSize;

            return r;
        }



        private Boolean IsClickOnImage(TreeNode tn, MouseEventArgs e)
        {
            if (tn == null || !ShowNodeIcon)
                return false;

            return GetImageBounds(tn).Contains(e.Location);
        }

        private Boolean IsClickOnHideButton(TreeNode tn, MouseEventArgs e)
        {
            if (tn == null || !ShowNodeHideButton)
                return false;

            return GetHideButtonBounds(tn).Contains(e.Location);
        }

        private Boolean IsClickOnFreezeButton(TreeNode tn, MouseEventArgs e)
        {
            if (tn == null || !ShowNodeFreezeButton)
                return false;

            return GetFreezeButtonBounds(tn).Contains(e.Location);
        }

        private Boolean IsClickOnText(TreeNode tn, MouseEventArgs e)
        {
            if (tn == null)
                return false;

            return GetTextBackgroundBounds(tn, true).Contains(e.Location);
        }

        private Boolean IsClickOnPlusMinus(TreeNode tn, MouseEventArgs e)
        {
            if (tn == null)
                return false;

            return GetPlusMinusBounds(tn).Contains(e.Location);
        }



        private Boolean IsDragOnNode(TreeNode tn, Point e)
        {
            if (tn == null)
                return false;

            return GetNodeBounds(tn).Contains(e);
        }

        private Boolean IsDragLeftOfPlusMinus(TreeNode tn, Point e)
        {
            if (tn == null)
                return false;

            Int32 boundLeft = Indent * tn.Level + _plusMinOffset.X - GetScrollPos(Handle, H_SCROLL);
            if (tn.GetNodeCount(false) == 0)
                boundLeft += _plusMinSize;

            return e.X < boundLeft;
        }

        #endregion



        #region MultiSelect

        private Boolean _handlingMouseClick = false;
        private Int32 _numMouseClicks = 0;
        private Boolean _nodeProcessedOnMouseDown = false;
        private Boolean _selectionChanged = false;
        private TreeNode _mostRecentSelectedNode;
        private OutlinerObject _lastSelectedObject;

        // Override the OnBeforeSelect event to cancel it (we'll do the selecting thank you).
        protected override void OnBeforeSelect(TreeViewCancelEventArgs e)
        {
            e.Cancel = true;
        }



        #region OnMouseDown, OnMouseUp

        protected override void OnMouseDown(MouseEventArgs e)
        {
            _handlingMouseClick = true;
            _numMouseClicks = e.Clicks;

            TreeNode tn = this.GetNodeAt(e.X, e.Y);


            if (IsClickOnText(tn, e))
            {
                if (!IsNodeSelected(tn))
                {
                    _nodeProcessedOnMouseDown = true;
                    ProcessNodeClick(tn, e, Control.ModifierKeys);
                }

                if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
                    showContextMenu(PointToScreen(e.Location));
                else if ((e.Button & DragMouseButton) == DragMouseButton && (DragMouseButton & MouseButtons.Middle) == MouseButtons.Middle)
                    OnItemDrag(new ItemDragEventArgs(e.Button, tn));
            }
            else if (IsClickOnImage(tn, e))
            {
                _nodeProcessedOnMouseDown = true;
                OnNodeIconClick(tn, e);
            }
            else if (IsClickOnHideButton(tn, e))
            {
                _nodeProcessedOnMouseDown = true;
                OnHideButtonClick(tn, e);
            }
            else if (IsClickOnFreezeButton(tn, e))
            {
                _nodeProcessedOnMouseDown = true;
                OnFreezeButtonClick(tn, e);
            }
            else if (IsClickOnPlusMinus(tn, e))
            {
                _internalExpandCollapse = true;
                this.BeginUpdate();
                if (tn.IsExpanded)
                    tn.Collapse(!((Control.ModifierKeys & ExpandHierarchyKey) == ExpandHierarchyKey));
                else
                {
                    if ((Control.ModifierKeys & ExpandHierarchyKey) == ExpandHierarchyKey)
                        tn.ExpandAll();
                    else
                        tn.Expand();
                }
                this.EndUpdate();
                _internalExpandCollapse = false;
            }
            else if (Control.ModifierKeys == Keys.None)
            {
                _nodeProcessedOnMouseDown = true;

                if (_selectedNodes.Count > 0)
                {
                    this.UnselectAllNodes();
                    OnSelectionChanged();
                }
                OnBackgroundClick(e);
            }

            base.OnMouseDown(e);
        }


        protected override void OnMouseUp(MouseEventArgs e)
        {
            if (!_nodeProcessedOnMouseDown)
            {
                TreeNode tn = this.GetNodeAt(e.X, e.Y);

                // Mouse click has not been handled by the mouse down event, so do it here. This is the case when
                // a selected node was clicked again; in that case we handle that click here because in case the
                // user is dragging the node, we should not put it in edit mode.					

                if (tn != null && IsClickOnText(tn, e))
                {
                    this.ProcessNodeClick(tn, e, Control.ModifierKeys);
                    if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
                        showContextMenu(PointToScreen(e.Location));
                    else if ((e.Button & DragMouseButton) == DragMouseButton && (DragMouseButton & MouseButtons.Middle) == MouseButtons.Middle)
                        OnItemDrag(new ItemDragEventArgs(e.Button, tn));
                }
            }

            _nodeProcessedOnMouseDown = false;

            _handlingMouseClick = false;
            
           base.OnMouseUp(e);
        }

        #endregion


        #region ProcessNodeRange

        /// <summary>
        /// Processes a node range.
        /// </summary>
        /// <param name="startNode">Start node of range.</param>
        /// <param name="endNode">End node of range.</param>
        /// <param name="e">MouseEventArgs.</param>
        /// <param name="keys">Keys.</param>
        /// <param name="tva">TreeViewAction.</param>
        /// <param name="allowStartEdit">True if node can go to edit mode, false if not.</param>
        private void ProcessNodeClick(TreeNode node, MouseEventArgs e, Keys keys)
        {
            _selectionChanged = false; // prepare for OnSelectionsChanged

            if ((e.Button & MouseButtons.Left) == MouseButtons.Left || (e.Button & DragMouseButton) == DragMouseButton || ((e.Button & MouseButtons.Right) == MouseButtons.Right && !IsNodeSelected(node)))
            {
                if (((keys & Keys.Control) != Keys.Control) && ((keys & Keys.Shift) != Keys.Shift))
                {
                    // CTRL and SHIFT not held down

                    // If it was a double click, select node and suspend further processing					
                    if (_numMouseClicks == 2)
                    {
                        base.OnMouseDown(e);
                        return;
                    }

                    UnselectAllNodes();
                    SelectNode(node, true);
                }
                else if (((keys & Keys.Control) == Keys.Control) && ((keys & Keys.Shift) != Keys.Shift))
                    //Control pressed
                    SelectNode(node, !IsNodeSelected(node));
                else if (((keys & Keys.Control) != Keys.Control) && ((keys & Keys.Shift) == Keys.Shift))
                {
                    // SHIFT pressed
                    if (_mostRecentSelectedNode == null)
                    {
                        _mostRecentSelectedNode = node;
                    }

                    SelectNodesInsideRange(_mostRecentSelectedNode, node);
                }
            }

            OnSelectionChanged();
        }

        #endregion


        #region Internal selection methods

        internal void SelectNode(OutlinerNode node, Boolean select)
        {
            if (node == null)
                return;

            TreeNode tn;
            if (_treeNodes.TryGetValue(node, out tn))
                SelectNode(node, tn, select);
        }

        internal void SelectNode(TreeNode tn, Boolean select)
        {
            if (tn == null || (!(tn.Tag is OutlinerNode)))
                return;

            SelectNode((OutlinerNode)tn.Tag, tn, select);
        }

        internal void SelectNode(OutlinerNode node, TreeNode tn, Boolean select)
        {
            if (node == null || tn == null)
                return;

            if (select)
            {
                this.Style.SetNodeColor(tn, NodeColor.Selected);

                if (!_selectedNodes.Contains(node))
                {
                    _selectedNodes.Add(node);
                    if (node is OutlinerObject)
                        _lastSelectedObject = (OutlinerObject)node;
                }

                HighlightParents(node);

                _selectionChanged = true;

                _mostRecentSelectedNode = tn;
            }
            else
            {
                _selectedNodes.Remove(node);
                _selectionChanged = true;

                if (IsParentOfSelectedNode(tn, true))
                    Style.SetNodeColor(tn, NodeColor.ParentOfSelected);
                else
                    Style.SetNodeColor(tn, NodeColor.Default);

                RemoveParentHighlights(node);
            }
        }



        private void SelectNodesInsideRange(TreeNode startNode, TreeNode endNode)
        {
            // Calculate start node and end node
            TreeNode firstNode = null;
            TreeNode lastNode = null;
            if (startNode.Bounds.Y < endNode.Bounds.Y)
            {
                firstNode = startNode;
                lastNode = endNode;
            }
            else
            {
                firstNode = endNode;
                lastNode = startNode;
            }

            // Select each node in range
            SelectNode(firstNode, true);
            TreeNode tnTemp = firstNode;
            while (tnTemp != lastNode)
            {
                tnTemp = tnTemp.NextVisibleNode;
                if (tnTemp != null)
                {
                    SelectNode(tnTemp, true);
                }
            }
            SelectNode(lastNode, true);
        }


        private void SelectAllNodes()
        {
            foreach (KeyValuePair<OutlinerNode, TreeNode> kvp in _treeNodes)
            {
                SelectNode(kvp.Key, kvp.Value, true);
            }
        }

        private void UnselectAllNodes()
        {
            OutlinerNode[] nodesToUnselect = _selectedNodes.ToArray();

            foreach (OutlinerNode n in nodesToUnselect)
            {
                SelectNode(n, false);
            }
        }


        private void SelectChildNodes()
        {
            OutlinerNode[] sel = _selectedNodes.ToArray();
            foreach(OutlinerNode n in sel)
            {
                SelectChildNodesIntern(n);
            }

            OnSelectionChanged();
        }

        private void SelectChildNodesIntern(OutlinerNode n)
        {
            if (n.ChildNodesCount > 0)
            {
                List<OutlinerNode> c = n.ChildNodes;
                foreach (OutlinerNode o in c)
                {
                    SelectNode(o, true);
                    SelectChildNodesIntern(o);
                }
            }
        }

        #endregion



        protected void OnSelectionChanged()
        {
            if (_selectionChanged && SelectionChanged != null)
            {
                SelectionChanged(this, new SelectionChangedEventArgs(SelectedObjectHandles, SelectedLayerHandlesIndirect, SelectedMaterialHandles));
            }
        }


        #endregion



        #region OnItemDrag, OnDragEnter, OnDragOver, OnDragDrop

        // Use "Scroll" enum value as "None", so that DragDrop event is fired even when a droptarget is not valid.
        internal const DragDropEffects DragDropEffectsNone = DragDropEffects.Scroll;
        internal const DragDropEffects AllowedDragDropEffects = DragDropEffects.Copy | DragDropEffects.Link | DragDropEffects.Move;

        private TreeDragDropHandler _treeDragDropHandler;
        private TreeNode _dragDropTargetNode;
        private Color _dragDropTargetForeColor;
        private Color _dragDropTargetBackColor;
        private DragDropHandler _dragDropHandler;
        private DateTime _dragOverStartTime;
        private HashSet<TreeNode> _dragOverExpandedNodes;

        private DateTime _lastScrollTime;
        private const int WM_HSCROLL = 276;
        private const int WM_VSCROLL = 277;
        private readonly TimeSpan fastScrollSpan = TimeSpan.FromMilliseconds(100);
        private readonly TimeSpan slowScrollSpan = TimeSpan.FromMilliseconds(300);

        protected override void OnItemDrag(ItemDragEventArgs e)
        {
            Boolean canDragDrop = true;

            // If the button pressed isn't the prefered drag-drop button, don't start dragdrop.
            if ((e.Button & DragMouseButton) != DragMouseButton)
                canDragDrop = false;
            else
            {
                // Check if all nodes in the selection can be dragged.
                foreach (OutlinerNode n in _selectedNodes)
                {
                    if (n.DragDropHandler == null || !n.DragDropHandler.AllowDrag)
                    {
                        canDragDrop = false;
                        break;
                    }
                }
            }

            if (canDragDrop)
            {
                Point mousePos = PointToClient(Control.MousePosition);
                if (IsClickOnText((TreeNode)e.Item, new MouseEventArgs(e.Button, 1, mousePos.X, mousePos.Y, 0)))
                {
                    OutlinerNode[] selOutlinerNodes = SelectedOutlinerNodes;

                    _dragOverExpandedNodes = new HashSet<TreeNode>();
                    DoDragDrop(selOutlinerNodes, AllowedDragDropEffects);
                }
            }

            base.OnItemDrag(e);
        }



        protected override void OnDragEnter(DragEventArgs drgevent)
        {
            drgevent.Effect = drgevent.AllowedEffect;
            base.OnDragEnter(drgevent);
        }


        // Restore previous dragDropTarget colors.
        private void RestorePreviousDragDropTargetColor()
        {
            if (_dragDropTargetNode != null)
            {
                Style.SetNodeColor(_dragDropTargetNode, _dragDropTargetForeColor, _dragDropTargetBackColor);
            }
        }

        private void RestoreDragDropExpandedStates()
        {
            _internalExpandCollapse = true;

            foreach (TreeNode tn in _dragOverExpandedNodes)
            {
                if (_dragDropTargetNode == null || !IsChildOfNode(_dragDropTargetNode, tn))
                    tn.Collapse();
            }
            _dragOverExpandedNodes.Clear();

            _internalExpandCollapse = false;
        }



        protected override void OnDragOver(DragEventArgs drgevent)
        {
            // Get node under cursor.
            Point targetPoint = this.PointToClient(new Point(drgevent.X, drgevent.Y));
            TreeNode targetNode = this.GetNodeAt(targetPoint);

            if (IsDragLeftOfPlusMinus(targetNode, targetPoint))
            {
                drgevent.Effect = DragDropEffectsNone;
                RestorePreviousDragDropTargetColor();
                _dragDropTargetNode = null;
            }
            else
            {
                if (!IsDragOnNode(targetNode, targetPoint))
                    targetNode = null;

                if (targetNode != _dragDropTargetNode || targetNode == null)
                {
                    RestorePreviousDragDropTargetColor();

                    _dragOverStartTime = DateTime.Now;
                    _dragDropTargetNode = targetNode;
                    if (targetNode != null)
                    {
                        _dragDropTargetForeColor = targetNode.ForeColor;
                        _dragDropTargetBackColor = targetNode.BackColor;
                    }

                    // Store the dragdrophandler for the current target.
                    if (_dragDropTargetNode != null)
                        _dragDropHandler = ((OutlinerNode)_dragDropTargetNode.Tag).DragDropHandler;
                    else
                        _dragDropHandler = _treeDragDropHandler;
                }

                // Get dragdrop effect for targetnode. 
                // Note: if the node is selected, or is a child of the selection, it can never be a valid droptarget -> DragDropEffects.None.
                //TODO move isnodeselected and ischildofselectednode to dragdrophandler (?)
                if (IsNodeSelected(_dragDropTargetNode) || IsParentOfSelectedNode(_dragDropTargetNode, false) || IsChildOfSelectedNode(_dragDropTargetNode))
                    drgevent.Effect = DragDropEffectsNone;
                else
                    drgevent.Effect = _dragDropHandler.GetDragDropEffect(drgevent.Data);

                if (drgevent.Effect != DragDropEffectsNone && _dragDropTargetNode != null)
                    this.Style.SetNodeColor(_dragDropTargetNode, NodeColor.LinkTarget);
            }


            // Auto expand
            if (_dragDropTargetNode != null && !_dragDropTargetNode.IsExpanded)
            {
                if (DateTime.Now - _dragOverStartTime > TimeSpan.FromMilliseconds(750))
                {
                    _internalExpandCollapse = true;
                    _dragDropTargetNode.Expand();
                    _internalExpandCollapse = false;
                    _dragOverExpandedNodes.Add(_dragDropTargetNode);
                }
            }


            // Scroll
            if (_lastScrollTime == null)
                _lastScrollTime = DateTime.Now;

            TimeSpan dScrollTime = DateTime.Now - _lastScrollTime;
            Int32 _scrollBounds = ItemHeight;

            Int32 scroll = -1;
            if (targetPoint.X < _scrollBounds * 2 && dScrollTime > slowScrollSpan)
                scroll = 0;
            else if (targetPoint.X > Bounds.Width - _scrollBounds * 2 && dScrollTime > slowScrollSpan)
                scroll = 1;

            if (targetPoint.X < _scrollBounds && dScrollTime > fastScrollSpan)
                scroll = 0;
            else if (targetPoint.X > Bounds.Width - _scrollBounds && dScrollTime > fastScrollSpan)
                scroll = 1;

            if (scroll != -1)
            {
                SendMessage(Handle, WM_HSCROLL, scroll, 0);
                _lastScrollTime = DateTime.Now;
            }

            scroll = -1;
            if (targetPoint.Y < _scrollBounds * 2 && dScrollTime > slowScrollSpan)
                scroll = 0;
            else if (targetPoint.Y > Bounds.Height - _scrollBounds * 2 && dScrollTime > slowScrollSpan)
                scroll = 1;

            if (targetPoint.Y < _scrollBounds && dScrollTime > fastScrollSpan)
                scroll = 0;
            else if (targetPoint.Y > Bounds.Height - _scrollBounds && dScrollTime > fastScrollSpan)
                scroll = 1;

            if (scroll != -1)
            {
                SendMessage(Handle, WM_VSCROLL, scroll, 0);
                _lastScrollTime = DateTime.Now;
            }

            base.OnDragOver(drgevent);
        }



        protected override void OnDragDrop(DragEventArgs drgevent)
        {
            this.BeginUpdate();

            RestorePreviousDragDropTargetColor();

            // Handle drop.
            if (drgevent.Effect != DragDropEffectsNone)
                _dragDropHandler.ItemDropped(drgevent.Data);

            RestoreDragDropExpandedStates();

            _dragDropTargetNode = null;

            this.EndUpdate();

            base.OnDragDrop(drgevent);
        }


        protected override void OnDragLeave(EventArgs e)
        {
            this.BeginUpdate();

            RestorePreviousDragDropTargetColor();

            _dragDropTargetNode = null;

            RestoreDragDropExpandedStates();

            this.EndUpdate();

            base.OnDragLeave(e);
        }

        #endregion



        #region Expand & Collapse

        private Boolean _internalExpandCollapse = false;

        // Override DefWndProc to block double-click expand if necessary.
        protected override void DefWndProc(ref Message m)
        {
            if (m.Msg == 515 && DoubleClickAction != DoubleClickAction.Expand)
            {
                /* WM_LBUTTONDBLCLK BLOCKED */
            }
            else
                base.DefWndProc(ref m);
        }
        

        protected override void OnBeforeExpand(TreeViewCancelEventArgs e)
        {
            if (_handlingMouseClick && !_internalExpandCollapse && !_restoringExpandedStates)
                e.Cancel = true;
            base.OnBeforeExpand(e);
        }
        protected override void OnBeforeCollapse(TreeViewCancelEventArgs e)
        {
            if (_handlingMouseClick && !_internalExpandCollapse)
                e.Cancel = true;
            base.OnBeforeCollapse(e);
        }

        protected override void OnAfterExpand(TreeViewEventArgs e)
        {
            if (!_restoringExpandedStates && e.Node.Tag is OutlinerNode)
                _expandedNodes.Add((OutlinerNode)e.Node.Tag);

            base.OnAfterExpand(e);
        }

        protected override void OnAfterCollapse(TreeViewEventArgs e)
        {
            if (e.Node.Tag is OutlinerNode)
                _expandedNodes.Remove((OutlinerNode)e.Node.Tag);

            base.OnAfterCollapse(e);
        }
        
        #endregion




        #region OnNodeImageClick, OnNodeMouseClick, OnBackgrounClick, OnNodeMouseDoubleClick

        //Toggles the hidden state of a treenode (after a mouseup event on it's image).
        private void OnNodeIconClick(TreeNode tn, MouseEventArgs e)
        {
            if (IconClickAction == IconClickAction.Hide)
                OnHideButtonClick(tn, e);
            else if (IconClickAction == IconClickAction.Freeze)
                OnFreezeButtonClick(tn, e);
            else if (IconClickAction == IconClickAction.SetActive)
            {
                if (tn.Tag is OutlinerLayer)
                {
                    OutlinerLayer layer = (OutlinerLayer)tn.Tag;
                    layer.IsActive = !layer.IsActive;
                    if (LayerActiveChanged != null)
                        LayerActiveChanged(this, new NodePropertyChangedEventArgs(new Int32[1] { layer.Handle }, "isActive", layer.IsActive));
                }
            }
        }

        private void OnHideButtonClick(TreeNode tn, MouseEventArgs e)
        {
            if (!(tn.Tag is OutlinerNode))
                return;

            OutlinerNode node = (OutlinerNode)tn.Tag;

            if ((e.Button & MouseButtons.Left) == MouseButtons.Left && node is IHidable)
            {
                Boolean hidden = !((IHidable)node).IsHidden;

                List<Int32> handles = new List<Int32>();


                if ((Control.ModifierKeys & Keys.Control) != Keys.Control && IsNodeSelected(node))
                {
                    // Store selection in array, because HideNode could remove treenodes if filter is set to not show hidden nodes.
                    OutlinerNode[] selNodes = SelectedOutlinerNodes;
                    foreach (OutlinerNode n in selNodes)
                    {
                        if (n is IHidable)
                        {
                            if (n is OutlinerObject && ((OutlinerObject)n).IsGroupHead)
                            {
                                HideNodeRecursive(n, hidden);
                                handles.Add(n.Handle);
                                handles.AddRange(getChildNodeHandlesRecursive(n));
                            }
                            else
                            {
                                HideNode(n, hidden);
                                handles.Add(n.Handle);
                            }
                        }
                    }
                }
                else
                {
                    if (node is OutlinerObject && ((OutlinerObject)node).IsGroupHead)
                    {
                        HideNodeRecursive(node, hidden);
                        handles.Add(node.Handle);
                        handles.AddRange(getChildNodeHandlesRecursive(node));
                    }
                    else
                    {
                        HideNode(node, hidden);
                        handles.Add(node.Handle);
                    }
                }

                if (NodeHidden != null)
                    NodeHidden(this, new NodePropertyChangedEventArgs(handles.ToArray(), "isHidden", hidden));
            }
        }



        private void OnFreezeButtonClick(TreeNode tn, MouseEventArgs e)
        {
            if (!(tn.Tag is OutlinerNode))
                return;

            OutlinerNode node = (OutlinerNode)tn.Tag;

            if ((e.Button & MouseButtons.Left) == MouseButtons.Left && node is IFreezable)
            {
                Boolean frozen = !((IFreezable)node).IsFrozen;

                List<Int32> handles = new List<Int32>();


                if ((Control.ModifierKeys & Keys.Control) != Keys.Control && IsNodeSelected(node))
                {
                    // Store selection in array, because FreezeNode could remove treenodes if filter is set to not show frozen nodes.
                    OutlinerNode[] selNodes = SelectedOutlinerNodes;
                    foreach (OutlinerNode n in selNodes)
                    {
                        if (n is IFreezable)
                        {
                            if (n is OutlinerObject && ((OutlinerObject)n).IsGroupHead)
                            {
                                FreezeNodeRecursive(n, frozen);
                                handles.Add(n.Handle);
                                handles.AddRange(getChildNodeHandlesRecursive(n));
                            }
                            else
                            {
                                FreezeNode(n, frozen);
                                handles.Add(n.Handle);
                            }
                        }
                    }
                }
                else
                {
                    if (node is OutlinerObject && ((OutlinerObject)node).IsGroupHead)
                    {
                        FreezeNodeRecursive(node, frozen);
                        handles.Add(node.Handle);
                        handles.AddRange(getChildNodeHandlesRecursive(node));
                    }
                    else
                    {
                        FreezeNode(node, frozen);
                        handles.Add(node.Handle);
                    }
                }

                if (NodeFrozen != null)
                    NodeFrozen(this, new NodePropertyChangedEventArgs(handles.ToArray(), "isFrozen", frozen));
            }
        }



        protected void OnBackgroundClick(MouseEventArgs e)
        {
            if ((e.Button & MouseButtons.Right) == MouseButtons.Right && this.ListMode == OutlinerListMode.Layer)
                showContextMenu(PointToScreen(e.Location));
        }

        protected override void OnNodeMouseDoubleClick(TreeNodeMouseClickEventArgs e)
        {
            if (IsClickOnText(e.Node, e))
            {
                if (this.DoubleClickAction == DoubleClickAction.Rename)
                    TreeNodeBeginEdit(e.Node);
                else if (DoubleClickAction == DoubleClickAction.Expand)
                {
                    _internalExpandCollapse = true;
                    e.Node.Toggle();
                    _internalExpandCollapse = false;
                }
            }

            base.OnNodeMouseDoubleClick(e);
        }

        #endregion




        #region ContextMenus

        private void showContextMenu(Point pos)
        {
            Int32 selCount = _selectedNodes.Count;
            Int32 selObjCount = 0;
            Int32 selLayerCount = 0;
            Int32 selMatCount = 0;
            Boolean showObjectItems = false;
            Boolean showLayerItems = false;
            Boolean showMaterialItems = false;
            Boolean showIHidableItems = false;
            Boolean showIFreezableItems = false;
            Boolean selHasChildnodes = false;
            Boolean selContainsActiveLayer = false;
            Boolean selCanDelete = false;
            Boolean selAllHidden = true;
            Boolean selAllUnhidden = true;
            Boolean selAllFrozen = true;
            Boolean selAllUnfrozen = true;
            Boolean selCanUnlink = false;
            Boolean selCanUngroup = false;
            Boolean selCanEditMat = false;

            foreach (OutlinerNode n in _selectedNodes)
            {
                if (n.ChildNodesCount > 0)
                    selHasChildnodes = true;

                if (n.CanBeDeleted)
                    selCanDelete = true;

                if (n is OutlinerObject)
                {
                    selObjCount++;
                    showObjectItems = true;
                    if (!n.IsRootNode)
                        selCanUnlink = true;
                    if (((OutlinerObject)n).IsGroupHead)
                        selCanUngroup = true;
                }
                else if (n is OutlinerLayer)
                {
                    showLayerItems = true;
                    selLayerCount++;
                    if (((OutlinerLayer)n).IsActive)
                        selContainsActiveLayer = true;
                }
                else if (n is OutlinerMaterial)
                {
                    showMaterialItems = true;
                    selMatCount++;
                    if (!((OutlinerMaterial)n).IsUnassigned)
                        selCanEditMat = true;
                }

                if (n is IHidable)
                {
                    if (((IHidable)n).IsHidden)
                        selAllUnhidden = false;
                    else
                        selAllHidden = false;

                    showIHidableItems = true;
                }
                if (n is IFreezable)
                {
                    showIFreezableItems = true;
                    if (((IFreezable)n).IsFrozen)
                        selAllUnfrozen = false;
                    else
                        selAllFrozen = false;
                }
            }

            ContextMenus.ShowContextMenu(pos, showObjectItems, showLayerItems, showMaterialItems,
                                         showIHidableItems, showIFreezableItems, 
                                         showObjectItems || showLayerItems || showMaterialItems, 
                                         showObjectItems || showLayerItems);

            if (showObjectItems || showLayerItems)
            {
                foreach (OutlinerLayer layer in Scene.Layers)
                {
                    ToolStripItem item = ContextMenus.AddSelectionToMenu.Items.Add(layer.Name, OutlinerResources.layer);
                    item.Name = "addSelToExistingLayer";
                    item.Tag = layer.Handle;
                }
            }

            ContextMenus.SelectChildnodesItem.Enabled   = selHasChildnodes;
            ContextMenus.SetActiveLayerItem.Enabled     = selLayerCount == 1 && !selContainsActiveLayer;
            ContextMenus.CreateNewLayerItem.Visible     = ListMode == OutlinerListMode.Layer;
            ContextMenus.EditMaterialItem.Enabled       = selMatCount == 1 && selCanEditMat;
            ContextMenus.RenameItem.Enabled             = selCount == 1 && _selectedNodes.First().CanEditName;
            ContextMenus.DeleteItem.Enabled             = selCanDelete;
            ContextMenus.AddToNewLayerItem.Enabled      = selObjCount > 0 || selLayerCount > 1 || (selLayerCount == 1 && !((OutlinerLayer)_selectedNodes.First()).IsDefaultLayer);
            ContextMenus.HideItem.Enabled               = !selAllHidden;
            ContextMenus.UnhideItem.Enabled             = !selAllUnhidden;
            ContextMenus.FreezeItem.Enabled             = !selAllFrozen;
            ContextMenus.UnfreezeItem.Enabled           = !selAllUnfrozen;
            ContextMenus.UnlinkItem.Enabled             = selCanUnlink;
            ContextMenus.UngroupItem.Enabled            = selCanUngroup;
            ContextMenus.DisplayShowInVptItem.Enabled   = selCanEditMat;

            ContextMenus.MainMenu.ItemClicked += new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.EditMaterialMenu.ItemClicked += new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.AddSelectionToMenu.ItemClicked += new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.DisplayPropertiesMenu.ItemClicked += new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.RenderPropertiesMenu.ItemClicked += new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.MainMenu.Closed += new ToolStripDropDownClosedEventHandler(Menu_Closed);

            if (ContextMenuOpened != null)
                ContextMenuOpened(this, new EventArgs());
        }



        private void ContextMenu_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem == ContextMenus.SelectChildnodesItem)
                SelectChildNodes();
            else if (e.ClickedItem == ContextMenus.RenameItem)
            {
                TreeNode tn;
                if (_treeNodes.TryGetValue(_selectedNodes.First(), out tn))
                    TreeNodeBeginEdit(tn);
            }

            if (ContextMenuItemClicked != null)
                ContextMenuItemClicked(sender, new ContextMenuItemClickedEventArgs((ContextMenuStrip)sender, e.ClickedItem));
        }


        private void Menu_Closed(object sender, ToolStripDropDownClosedEventArgs e)
        {
            ContextMenus.MainMenu.ItemClicked -= new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.EditMaterialMenu.ItemClicked -= new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.AddSelectionToMenu.ItemClicked -= new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.DisplayPropertiesMenu.ItemClicked -= new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.RenderPropertiesMenu.ItemClicked -= new ToolStripItemClickedEventHandler(ContextMenu_ItemClicked);
            ContextMenus.MainMenu.Closed -= new ToolStripDropDownClosedEventHandler(Menu_Closed);
        }

        #endregion


        

        #region LabelEdit

        private const int TVM_GETEDITCONTROL = 0x110F;
        /** SendMessage already imported for scroll position**/
        //[DllImport("user32.dll", CharSet = CharSet.Auto)]
        //private static extern IntPtr SendMessage(IntPtr hWnd, int msg, int wParam, int lParam);

        private class LabelEditWindowHook : NativeWindow
        {
            private const int WM_GETDLGCODE = 135;
            private const int DLGC_WANTALLKEYS = 0x0004;

            public LabelEditWindowHook() { }

            protected override void WndProc(ref Message m)
            {
                if (m.Msg == WM_GETDLGCODE)
                    m.Result = (IntPtr)DLGC_WANTALLKEYS;
                else
                    base.WndProc(ref m);
            }
        }

        private LabelEditWindowHook m_Hook = new LabelEditWindowHook();


        // Function to begin editing the TreeNode's name.
        // Begins by setting the treenode.Text to Name rather than DisplayName (to avoid editing curly braces for example).
        private void TreeNodeBeginEdit(TreeNode tn)
        {
            if (tn.Tag is OutlinerNode && ((OutlinerNode)tn.Tag).CanEditName && !tn.IsEditing)
            {
                // Make sure endupdate and sort are called before putting the node into labeledit mode.
                if (_updateTimer.Enabled)
                    updateTimer_Tick(_updateTimer, new EventArgs());
                if (_sortTimer.Enabled)
                    sortTimer_Tick(_sortTimer, new EventArgs());

                tn.Text = ((OutlinerNode)tn.Tag).Name;
                
                this.LabelEdit = true;
                tn.BeginEdit();
            }
        }


        protected override void OnBeforeLabelEdit(NodeLabelEditEventArgs e)
        {
            IntPtr handle = (IntPtr)SendMessage(this.Handle, TVM_GETEDITCONTROL, 0, 0);
            if (handle != IntPtr.Zero)
                m_Hook.AssignHandle(handle);

            base.OnBeforeLabelEdit(e);
        }


        protected override void OnAfterLabelEdit(NodeLabelEditEventArgs e)
        {
            m_Hook.ReleaseHandle();
            
            OutlinerNode node = (OutlinerNode)e.Node.Tag;
            if (e.Label != null && e.Label != node.Name)
            {
                if (e.Label.Length == 0)
                {
                    e.Node.EndEdit(true);
                    e.Node.BeginEdit();
                    return;
                }

                if (node is OutlinerLayer && !Scene.IsValidLayerName((OutlinerLayer)node, e.Label))
                {
                    MessageBox.Show(OutlinerResources.InvalidLayerNameMessage, OutlinerResources.InvalidLayerNameTitle, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    e.Node.EndEdit(true);
                    e.Node.BeginEdit();
                    return;
                }
                else if (node is OutlinerMaterial && !Scene.IsValidMaterialName((OutlinerMaterial)node, e.Label))
                {
                    MessageBox.Show(OutlinerResources.InvalidMaterialNameMessage, OutlinerResources.InvalidMaterialNameTitle, MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    e.Node.EndEdit(true);
                    e.Node.BeginEdit();
                    return;
                }
                else
                {
                    node.Name = e.Label;
                    if (_treeViewNodeSorter is Outliner.NodeSorters.AlphabeticalSorter)
                        BeginTimedSort();

                    if (NodeRenamed != null)
                        NodeRenamed(this, new NodeRenamedEventArgs(node.Handle, e.Label));
                }
            }

            // CancelEdit true isn't pretty, but doing so enables you to set e.node.text.
            e.CancelEdit = true;
            e.Node.Text = node.DisplayName;

            this.LabelEdit = false;
        }

        #endregion















        #region ScrollPosition

        [DllImport("user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
        protected static extern int GetScrollPos(IntPtr hWnd, int nBar);
        [DllImport("user32.dll")]
        protected static extern int SetScrollPos(IntPtr hWnd, int nBar, int nPos, bool bRedraw);
        [DllImport("user32.dll")]
        private static extern int SendMessage(IntPtr hWnd, int wMsg, int wParam, int lParam);

        private const Int32 H_SCROLL = 0;
        private const Int32 V_SCROLL = 1;

        private Point GetScrollPosition()
        {
            return new Point(GetScrollPos(this.Handle, H_SCROLL), GetScrollPos(this.Handle, V_SCROLL));
        }

        private void SetScrollPosition(Point scrollPosition)
        {
            SetScrollPos(this.Handle, H_SCROLL, scrollPosition.X, true);
            SetScrollPos(this.Handle, V_SCROLL, scrollPosition.Y, true);
        }

        #endregion







        #region IconSet

        private IconSet _iconSet;
        private Dictionary<String, Bitmap> _icons;
        private Size _iconSize = Size.Empty;

        private Boolean _invertIcons = false;
        public Boolean InvertIcons
        {
            get { return _invertIcons; }
            set
            {
                _invertIcons = value;
                IconSet = _iconSet;
            }
        }

        public IconSet IconSet
        {
            get { return _iconSet; }
            set
            {
                _iconSet = value;
                _icons = new Dictionary<string, Bitmap>();
                _iconSize = Size.Empty;
                
                ResourceSet resSet = null;
                if (value == IconSet.Max)
                    resSet = MaxIcons.ResourceManager.GetResourceSet(System.Globalization.CultureInfo.CurrentCulture, true, true);
                else if (value == IconSet.Maya_16x16)
                    resSet = MayaIcons16x16.ResourceManager.GetResourceSet(System.Globalization.CultureInfo.CurrentCulture, true, true);
                else if (value == IconSet.Maya_20x20)
                    resSet = MayaIcons20x20.ResourceManager.GetResourceSet(System.Globalization.CultureInfo.CurrentCulture, true, true);
                
                if (resSet != null)
                {
                    foreach (System.Collections.DictionaryEntry e in resSet)
                    {
                        if (e.Key is String && e.Value is Bitmap)
                        {
                            if (_iconSize == Size.Empty)
                                _iconSize = ((Bitmap)e.Value).Size;

                            Bitmap b = (Bitmap)e.Value;
                            if (InvertIcons)
                            {
                                BitmapProcessing.Desaturate(b);
                                BitmapProcessing.Invert(b);
                                BitmapProcessing.Brightness(b, 101);
                            }

                            Bitmap b_hidden = new Bitmap(b);
                            BitmapProcessing.Opacity(b_hidden, 100);

                            Bitmap b_filtered = new Bitmap(b);
                            BitmapProcessing.Opacity(b_filtered, 50);

                            _icons.Add((String)e.Key, b);
                            _icons.Add((String)e.Key + "_hidden", b_hidden);
                            _icons.Add((String)e.Key + "_filtered", b_filtered);
                        }
                    }
                }

                this.Indent = (_iconSize.Width > 0) ? _iconSize.Width : 16;
                this.ItemHeight = (_iconSize.Height > 0) ? _iconSize.Height + 2 : 16;
                
                // Create dummy imagelist to 'correct' labeledit textbox position.
                ImageList = new ImageList();
            }
        }


        #endregion




       

        #region HighlightParents

        internal void HighlightParents(OutlinerNode n)
        {
            if ((ListMode != OutlinerListMode.Hierarchy && ListMode != OutlinerListMode.Layer) || n == null)
                return;

            TreeNode tn;
            if(_treeNodes.TryGetValue(n, out tn))
            {
                tn = tn.Parent;

                while (tn != null && tn.Tag is OutlinerNode && !IsNodeSelected((OutlinerNode)tn.Tag))
                {
                    Style.SetNodeColor(tn, NodeColor.ParentOfSelected);
                    tn = tn.Parent;
                }
            }
        }

        internal void HighlightAllParents()
        {
            foreach (OutlinerNode n in _selectedNodes)
                HighlightParents(n);
        }


        internal void RemoveParentHighlights(OutlinerNode n)
        {
            if ((ListMode != OutlinerListMode.Hierarchy && ListMode != OutlinerListMode.Layer) || n == null)
                return;

            TreeNode tn;
            if (_treeNodes.TryGetValue(n, out tn))
            {
                tn = tn.Parent;
                while (tn != null && !IsNodeSelected(tn) && !IsParentOfSelectedNode(tn, true))
                {
                    Style.SetNodeColor(tn, NodeColor.Default);
                    tn = tn.Parent;
                }
            }
        }

        #endregion





        #region BeginTimedUpdate, BeginTimedSort, new TreeViewNodeSorter

        internal void BeginTimedUpdate()
        {
            if (!_updateTimer.Enabled)
            {
                this.BeginUpdate();

                _updateTimer.Start();
            }
        }

        private void updateTimer_Tick(object sender, EventArgs e)
        {
            _updateTimer.Stop();
            if (!_sortTimer.Enabled)
                this.EndUpdate();
            else
                _updateWaitingForSort = true;
        }


        internal void BeginTimedSort()
        {
            if (!_sortTimer.Enabled)
                _sortTimer.Start();
        }

        private void sortTimer_Tick(object sender, EventArgs e)
        {
            _sortTimer.Stop();
            _internalExpandCollapse = true;
            Point pos = GetScrollPosition();

            base.TreeViewNodeSorter = _treeViewNodeSorter;
            base.TreeViewNodeSorter = null;
            base.Sorted = false;

            SetScrollPosition(pos);
            _internalExpandCollapse = false;

            if (_updateWaitingForSort)
            {
                updateTimer_Tick(_updateTimer, new EventArgs());
                _updateWaitingForSort = false;
            }

            if (_ensureSelectionVisibleWaitingForSort)
            {
                _ensureSelectionVisibleTimer_Tick(_ensureSelectionVisibleTimer, new EventArgs());
                _ensureSelectionVisibleWaitingForSort = false;
            }
        }
        
        private IComparer _treeViewNodeSorter;
        new public IComparer TreeViewNodeSorter
        {
            get { return null; }
            set
            {
                _treeViewNodeSorter = value;
                sortTimer_Tick(this, new EventArgs());
            }
        }

        new public Boolean Sorted
        {
            get { return false; }
            set { }
        }

        new public void Sort()
        {
            sortTimer_Tick(this, new EventArgs());
        }


        internal void BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction action)
        {
            _ensureSelectionVisibleAction |= action;
            if (!_ensureSelectionVisibleTimer.Enabled)
                _ensureSelectionVisibleTimer.Start();
        }

        void _ensureSelectionVisibleTimer_Tick(object sender, EventArgs e)
        {
            _ensureSelectionVisibleTimer.Stop();
            if (!_sortTimer.Enabled)
            {
                EnsureSelectionVisible(_ensureSelectionVisibleAction);
                _ensureSelectionVisibleAction = EnsureSelectionVisibleAction.None;
            }
            else
                _ensureSelectionVisibleWaitingForSort = true;
        }
         

        
        #endregion






        #region FillTree, CreateTreeNodeForOutlinerNode, AddLayersToTree, AddObjectsToTreeNodeCollection

        public void FillTree()
        {
            this.BeginUpdate();

            // Store selection.
            OutlinerNode[] selection = SelectedOutlinerNodes;

            // Clear nodes.
            this.Nodes.Clear();
            // Clear outlinernode-treenode dictionary
            _treeNodes.Clear();
            // Clear selection.
            _selectedNodes.Clear();

            // Set sorter, so nodes are added in sorted order.
            if (_treeViewNodeSorter != null)
                base.TreeViewNodeSorter = _treeViewNodeSorter;

            // Fill the tree.
            if (ListMode == OutlinerListMode.Hierarchy)
                AddObjectsToTreeNodeCollection(this.Nodes, Scene.RootObjects, true);
            else if (ListMode == OutlinerListMode.Layer)
                AddLayersToTree();
            else if (ListMode == OutlinerListMode.Material)
                AddMaterialsToTree();

            // Avoid unintended sorting by base TreeView.
            base.TreeViewNodeSorter = null;
            base.Sorted = false;
            
            
            // Restore expanded states.
            RestoreExpandedStates();

            // Restore selection
            RestoreSelection(selection);

            this.EndUpdate();
        }



        private TreeNode CreateTreeNodeForOutlinerNode(OutlinerNode n)
        {
            TreeNode tn = new TreeNode(n.DisplayName);

            n.DragDropHandler = DragDropHandler.GetDragDropHandlerForNode(this, n);
            tn.Tag = n;

            Style.SetNodeColor(tn, NodeColor.Default);

            return tn;
        }




        private void AddLayersToTree()
        {
            List<OutlinerNode> layers = this.Scene.RootLayers;
            List<TreeNode> treeNodes = new List<TreeNode>();

            foreach (OutlinerNode layer in layers)
            {
                if (Filter.ShowNode(layer))
                {
                    TreeNode tn = CreateTreeNodeForOutlinerNode(layer);

                    // Add node to outlinernode/treenode dictionary.
                    _treeNodes.Add(layer, tn);

                    // Add all objects belonging to the layer to the layers nodecollection.
                    this.AddObjectsToTreeNodeCollection(tn.Nodes, layer.ChildNodes, false);

                    treeNodes.Add(tn);
                }
            }

            this.Nodes.AddRange(treeNodes.ToArray());
        }



        private void AddMaterialsToTree()
        {
            List<OutlinerNode> materials = Scene.RootMaterials;

            List<TreeNode> treeNodes = new List<TreeNode>(materials.Count);

            foreach (OutlinerNode m in materials)
            {
                if (Filter.ShowNode(m))
                {
                    TreeNode tn = CreateTreeNodeForOutlinerNode(m);

                    _treeNodes.Add(m, tn);

                    AddObjectsToTreeNodeCollection(tn.Nodes, m.ChildNodes, false);

                    treeNodes.Add(tn);
                }
            }

            this.Nodes.AddRange(treeNodes.ToArray());
        }






        public void AddObjectsToTreeNodeCollection(TreeNodeCollection col, List<OutlinerNode> nodes, Boolean addChildNodes)
        {
            if (nodes == null || nodes.Count == 0)
                return;

            List<TreeNode> newNodes = new List<TreeNode>();

            foreach (OutlinerNode node in nodes)
            {
                node.MarkedForDelete = false;

                if (!_treeNodes.ContainsKey(node) && Filter.ShowNode(node) && (!(ListMode == OutlinerListMode.Layer) || !HideGroupMembersLayerMode || !(node is OutlinerObject) || !((OutlinerObject)node).IsGroupMember))
                {
                    TreeNode tn = CreateTreeNodeForOutlinerNode(node);

                    // Add node to outlinernode/treenode dictionary.
                    _treeNodes.Add(node, tn);

                    newNodes.Add(tn);

                    // Recursively go through childnodes.
                    if ((addChildNodes && node.ChildNodesCount > 0) || !(node is OutlinerObject)) 
                        AddObjectsToTreeNodeCollection(tn.Nodes, node.ChildNodes, addChildNodes);
                }
            }
            
            col.AddRange(newNodes.ToArray());
        }


        #endregion


        #region AddObjectToTree, AddLayerToTree, AddMaterialToTree

        internal void AddObjectToTree(OutlinerObject obj)
        {
            if (obj == null)
                return;

            obj.MarkedForDelete = false;

            if(!Filter.ShowNode(obj))
                return;
            
            TreeNodeCollection parentCollection = null;

            if (ListMode == OutlinerListMode.Hierarchy)
            {
                if (obj.IsRootNode)
                    parentCollection = this.Nodes;
                else
                {
                    obj = (OutlinerObject)GetHighestParentToAdd(obj);
                    TreeNode tn;
                    if (obj.IsRootNode)
                        parentCollection = this.Nodes;
                    else
                    {
                        if (_treeNodes.TryGetValue(obj.Parent, out tn))
                            parentCollection = tn.Nodes;
                    }
                }
            }
            else if (ListMode == OutlinerListMode.Layer)
            {
                OutlinerLayer layer = obj.Layer;
                if (layer != null)
                {
                    TreeNode layerTreeNode;
                    if (_treeNodes.TryGetValue(layer, out layerTreeNode))
                        parentCollection = layerTreeNode.Nodes;
                }
            }
            else if (ListMode == OutlinerListMode.Material)
            {
                OutlinerMaterial m = obj.Material;
                if (m != null)
                {
                    TreeNode matNode;
                    if (_treeNodes.TryGetValue(m, out matNode))
                        parentCollection = matNode.Nodes;
                    else
                        AddMaterialToTree(m);
                }
            }

            if (parentCollection != null && obj != null)
            {
                BeginTimedUpdate();
                BeginTimedSort();
                AddObjectsToTreeNodeCollection(parentCollection, new List<OutlinerNode>(1) { obj }, (ListMode == OutlinerListMode.Hierarchy));
            }
        }


        internal void AddLayerToTree(OutlinerLayer layer)
        {
            if (layer == null || ListMode != OutlinerListMode.Layer)
                return;

            layer.MarkedForDelete = false;

            BeginTimedUpdate();
            BeginTimedSort();

            TreeNodeCollection parentCollection = null;
            OutlinerNode layerParent = layer.Parent;
            if (layerParent != null)
            {
                TreeNode parentNode;
                if (_treeNodes.TryGetValue(layerParent, out parentNode))
                    parentCollection = parentNode.Nodes;
            }
            else
                parentCollection = this.Nodes;


            if (parentCollection != null)
            {
                AddObjectsToTreeNodeCollection(parentCollection, new List<OutlinerNode>(1){layer}, false);
            }
        }

        internal void AddMaterialToTree(OutlinerMaterial material)
        {
            if (material == null || ListMode != OutlinerListMode.Material)
                return;

            material.MarkedForDelete = false;

            if (Filter.ShowNode(material))
            {
                BeginTimedUpdate();
                BeginTimedSort();

                TreeNode tn = CreateTreeNodeForOutlinerNode(material);

                // Add all objects belonging to the layer to the layers nodecollection.
                this.AddObjectsToTreeNodeCollection(tn.Nodes, material.ChildNodes, false);

                _treeNodes.Add(material, tn);
                this.Nodes.Add(tn);
            }
        }
        #endregion


        #region RemoveNodeFromTree

        internal void RemoveNodeFromTree(OutlinerNode n, Boolean removeReferences)
        {
            if (n == null)
                return;

            n.MarkedForDelete = true;

            if (ListMode == OutlinerListMode.Hierarchy)
                n = GetHighestParentToRemove(n);

            TreeNode tn;
            if (_treeNodes.TryGetValue(n, out tn))
                RecursiveRemoveTreeNode(n, tn, removeReferences);
        }


        private void RecursiveRemoveTreeNode(OutlinerNode n, TreeNode tn, Boolean removeReferences)
        {
            RecursiveRemoveTreeNodeIntern(n, tn, removeReferences);
            tn.Remove();
        }
        private void RecursiveRemoveTreeNodeIntern(OutlinerNode n, TreeNode tn, Boolean removeReferences)
        {
            n.MarkedForDelete = true;

            if (removeReferences)
            {
                _expandedNodes.Remove(n);
                _selectedNodes.Remove(n);
            }
            RemoveParentHighlights(n);
            _treeNodes.Remove(n);

            foreach (TreeNode cn in tn.Nodes)
                RecursiveRemoveTreeNodeIntern((OutlinerNode)cn.Tag, cn, removeReferences);
        }

        #endregion





        #region HideNode, FreezeNode, LinkObject, SetObjectMaterial

        internal void HideNode(OutlinerNode n, Boolean hidden)
        {
            if (n is IHidable && ((IHidable)n).IsHidden != hidden)
            {
                ((IHidable)n).IsHidden = hidden;

                Boolean showNode = this.Filter.ShowNode(n);
                TreeNode tn;
                _treeNodes.TryGetValue(n, out tn);

                if (tn != null && showNode)
                {
                    Style.SetNodeImageKey(tn);
                    Style.SetNodeColorAuto(tn);
                }
                else if (tn != null && !showNode)
                    RemoveNodeFromTree(n, true);
                else if (tn == null && showNode)
                {
                    if (n is OutlinerObject && !(ListMode == OutlinerListMode.Layer || !HideGroupMembersLayerMode || ((OutlinerObject)n).IsGroupMember))
                        AddObjectToTree((OutlinerObject)n);
                    else if (n is OutlinerLayer && ListMode == OutlinerListMode.Layer)
                        AddLayerToTree((OutlinerLayer)n);
                }

                if (_treeViewNodeSorter is Outliner.NodeSorters.VisibilitySorter)
                    BeginTimedSort();
            }
        }


        internal void HideNodeRecursive(OutlinerNode n, Boolean hidden)
        {
            HideNode(n, hidden);
            foreach (OutlinerNode cn in n.ChildNodes)
            {
                HideNodeRecursive(cn, hidden);
            }
        }

        internal void FreezeNode(OutlinerNode n, Boolean frozen)
        {
            if (n is IFreezable && ((IFreezable)n).IsFrozen != frozen)
            {
                ((IFreezable)n).IsFrozen = frozen;

                Boolean showNode = this.Filter.ShowNode(n);
                TreeNode tn;
                _treeNodes.TryGetValue(n, out tn);

                if (tn != null && showNode)
                    Style.SetNodeColorAuto(tn);
                else if (tn != null && !showNode)
                    RemoveNodeFromTree(n, true);
                else if (tn == null && showNode)
                {
                    if (n is OutlinerObject)
                        AddObjectToTree((OutlinerObject)n);
                    else if (n is OutlinerLayer && ListMode == OutlinerListMode.Layer)
                        AddLayerToTree((OutlinerLayer)n);
                }
            }
        }

        internal void FreezeNodeRecursive(OutlinerNode n, Boolean frozen)
        {
            FreezeNode(n, frozen);
            foreach (OutlinerNode cn in n.ChildNodes)
            {
                FreezeNodeRecursive(cn, frozen);
            }
        }

        

        internal void LinkObject(OutlinerObject obj, Int32 newParentHandle, Boolean group, Boolean isGroupMember)
        {
            RemoveNodeFromTree(obj, false);

            Scene.SetObjectParentHandle(obj, newParentHandle);

            if (group)
                obj.SetIsGroupMemberRec(isGroupMember);

            AddObjectToTree(obj);

            RestoreExpandedStates();

            if (IsNodeSelected(obj))
            {
                SelectNode(obj, true);
                _selectionChanged = false;
                if (ListMode == OutlinerListMode.Hierarchy)
                    BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction.HierarchyChanged);
            }
        }


        internal void SetObjectLayer(OutlinerObject obj, Int32 newLayerHandle)
        {
            if (ListMode == OutlinerListMode.Layer)
            {
                BeginTimedUpdate();
                BeginTimedSort();

                RemoveNodeFromTree(obj, false);
                Scene.SetObjectLayerHandle(obj, newLayerHandle);
                AddObjectToTree(obj);

                if (IsNodeSelected(obj))
                {
                    SelectNode(obj, true);
                    _selectionChanged = false;
                    BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction.LayerChanged);
                }
            }
            else
            {
                Scene.SetObjectLayerHandle(obj, newLayerHandle);
                if (_treeViewNodeSorter is Outliner.NodeSorters.LayerSorter) BeginTimedSort();
            }
        }


        internal void SetObjectMaterial(OutlinerObject obj, Int32 newMatHandle)
        {
            if (ListMode == OutlinerListMode.Material)
            {
                OutlinerMaterial oldMat = obj.Material;

                RemoveNodeFromTree(obj, false);
                Scene.SetObjectMaterialHandle(obj, newMatHandle);
                AddObjectToTree(obj);

                if (oldMat != null && oldMat.ChildNodes.Count == 0)
                {
                    RemoveNodeFromTree(oldMat, true);
                    if (!oldMat.IsUnassigned)
                        Scene.RemoveMaterial(oldMat);
                }

                // Reselect the node if necessary.
                if (IsNodeSelected(obj))
                {
                    SelectNode(obj, true);
                    _selectionChanged = false;
                    BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction.MaterialChanged);
                }
            }
            else
            {
                Scene.SetObjectMaterialHandle(obj, newMatHandle);
                if (_treeViewNodeSorter is Outliner.NodeSorters.MaterialSorter) BeginTimedSort();
            }
        }


        internal void SetLayerParent(OutlinerLayer layer, Int32 newParentHandle)
        {
            RemoveNodeFromTree(layer, false);

            Scene.SetLayerParentHandle(layer, newParentHandle);

            AddLayerToTree(layer);

            RestoreExpandedStates();

            if (IsNodeSelected(layer))
            {
                SelectNode(layer, true);
                _selectionChanged = false;
            }
        }
        #endregion








        #region Events

        public event SelectionChangedEventHandler SelectionChanged;
        public event NodeLinkedEventHandler ObjectLinked;
        public event NodeLinkedEventHandler ObjectLayerChanged;
        public event NodeGroupedEventHandler ObjectGrouped;
        public event NodeGroupedEventHandler ObjectAddedToContainer;
        public event NodePropertyChangedEventHandler ObjectMaterialChanged;
        public event NodeRenamedEventHandler NodeRenamed;
        public event NodePropertyChangedEventHandler NodeHidden;
        public event NodePropertyChangedEventHandler NodeFrozen;
        public event NodeLinkedEventHandler SpaceWarpBound;
        public event NodeLinkedEventHandler LayerLinked;
        public event NodePropertyChangedEventHandler LayerActiveChanged;

        public event EventHandler ContextMenuOpened;
        public event ContextMenuItemClickedEventHandler ContextMenuItemClicked;

        public event DebugEventHandler DebugEvent;

        internal void RaiseObjectLinkedEvent(NodeLinkedEventArgs e)
        {
            if (ObjectLinked != null)
                ObjectLinked(this, e);
        }

        internal void RaiseObjectGroupedEvent(NodeGroupedEventArgs e)
        {
            if (ObjectGrouped != null)
                ObjectGrouped(this, e);
        }

        internal void RaiseObjectAddedToContainerEvent(NodeGroupedEventArgs e)
        {
            if (ObjectAddedToContainer != null)
                ObjectAddedToContainer(this, e);
        }

        internal void RaiseObjectLayerChangedEvent(NodeLinkedEventArgs e)
        {
            if (ObjectLayerChanged != null)
                ObjectLayerChanged(this, e);
        }

        internal void RaiseObjectMaterialChangedEvent(NodePropertyChangedEventArgs e)
        {
            if (ObjectMaterialChanged != null)
                ObjectMaterialChanged(this, e);
        }

        internal void RaiseLayerLinkedEvent(NodeLinkedEventArgs e)
        {
            if (LayerLinked != null)
                LayerLinked(this, e);
        }

        internal void RaiseSpaceWarpBoundEvent(NodeLinkedEventArgs e)
        {
            if (SpaceWarpBound != null)
                SpaceWarpBound(this, e);
        }

        #endregion




        #region EnsureSelectionVisible


        public ExpandPolicy ExpandSelectionPolicyHierarchy = ExpandPolicy.WhenNecessary;
        public ExpandPolicy ExpandSelectionPolicyLayer = ExpandPolicy.WhenNecessary;
        public ExpandPolicy ExpandSelectionPolicyMaterial = ExpandPolicy.WhenNecessary;

        

        internal void EnsureSelectionVisible(EnsureSelectionVisibleAction action)
        {
            if (_selectedNodes.Count == 0 || action == EnsureSelectionVisibleAction.None)
                return;

            Boolean ensureSelVisible = false;

            if ((action & EnsureSelectionVisibleAction.SelectionChanged) == EnsureSelectionVisibleAction.SelectionChanged)
                ensureSelVisible = true;
            else if ((action & EnsureSelectionVisibleAction.HierarchyChanged) == EnsureSelectionVisibleAction.HierarchyChanged)
                ensureSelVisible = true;
            else if ((action & EnsureSelectionVisibleAction.LayerChanged) == EnsureSelectionVisibleAction.LayerChanged)
                ensureSelVisible = true;
            else if ((action & EnsureSelectionVisibleAction.MaterialChanged) == EnsureSelectionVisibleAction.MaterialChanged)
                ensureSelVisible = true;

            if (ensureSelVisible)
            {
                List<TreeNode> selectedTreeNodes = new List<TreeNode>(_selectedNodes.Count);
                ExpandPolicy expPolicy = ExpandPolicy.Never;
                if (ListMode == OutlinerListMode.Hierarchy)
                {
                    if (AutoExpandHierarchy)
                        expPolicy = ExpandPolicy.Always;
                    else
                        expPolicy = ExpandSelectionPolicyHierarchy;
                }
                else if (ListMode == OutlinerListMode.Layer)
                {
                    if (AutoExpandLayer)
                        expPolicy = ExpandPolicy.Always;
                    else
                        expPolicy = ExpandSelectionPolicyLayer;
                }
                else if (ListMode == OutlinerListMode.Material)
                {
                    if (AutoExpandMaterial)
                        expPolicy = ExpandPolicy.Always;
                    else
                        expPolicy = ExpandSelectionPolicyMaterial;
                }


                _internalExpandCollapse = true;
                Boolean shouldExpandSelection = true;
                foreach (OutlinerNode n in _selectedNodes)
                {
                    TreeNode tn;
                    if (_treeNodes.TryGetValue(n, out tn))
                    {
                        selectedTreeNodes.Add(tn);

                        if (expPolicy == ExpandPolicy.WhenNecessary && !hasCollapsedParents(tn))
                            shouldExpandSelection = false;
                        else if (expPolicy == ExpandPolicy.Always && hasCollapsedParents(tn))
                        {
                            TreeNode p = tn.Parent;
                            while (p != null)
                            {
                                p.Expand();
                                p = p.Parent;
                            }
                        }
                    }
                }


                if (expPolicy == ExpandPolicy.WhenNecessary && shouldExpandSelection)
                {
                    TreeNode tn = selectedTreeNodes[0].Parent;
                    while (tn != null)
                    {
                        tn.Expand();
                        tn = tn.Parent;
                    }
                }

                _internalExpandCollapse = false;


                List<Rectangle> treeNodeBounds = new List<Rectangle>(_selectedNodes.Count);
                TreeNode highestNode = null;
                Int32 highestNodeY = Int32.MaxValue;
                foreach (TreeNode tn in selectedTreeNodes)
                {
                    Rectangle bounds = tn.Bounds;
                    treeNodeBounds.Add(bounds);
                    if (bounds.Y < highestNodeY && !hasCollapsedParents(tn))
                    {
                        highestNode = tn;
                        highestNodeY = bounds.Y;
                    }
                }

                if (highestNode != null)
                {
                    highestNode.EnsureVisible();
                    TreeNode lowestNode = null;
                    Int32 lowestNodeY = Int32.MinValue;
                    for (Int32 i = 0; i < selectedTreeNodes.Count; i++)
                    {
                        TreeNode tn = selectedTreeNodes[i];
                        if (tn != highestNode)
                        {
                            Rectangle bounds = treeNodeBounds[i];
                            if (((bounds.Y + bounds.Height) - highestNodeY) < ClientRectangle.Height && bounds.Y > lowestNodeY && !hasCollapsedParents(tn))
                            {
                                lowestNode = tn;
                                lowestNodeY = bounds.Y;
                            }
                        }
                    }

                    if (lowestNode != null)
                    {
                        lowestNode.EnsureVisible();
                    }
                }
            }
        }


        #endregion


        //Functions called from 3dsmax:
        // Objects, layers and materials will only be referred to by their handle (GetHandleByAnim).

        // Selection functions
        #region GetSelectedNodeHandles, SelectedObjectHandles, SelectedLayerHandles, SelectedMaterialHandles, GetSelectedParentObjectHandles

        public Int32[] GetSelectedNodeHandles(Boolean includeObjects, Boolean includeLayers, Boolean includeMaterials)
        {
            List<Int32> nodeHandles = new List<Int32>();
            foreach (OutlinerNode n in _selectedNodes)
            {
                if (n is OutlinerObject && includeObjects)
                    nodeHandles.Add(n.Handle);
                else if (n is OutlinerLayer && includeLayers)
                    nodeHandles.Add(n.Handle);
                else if (n is OutlinerMaterial && includeMaterials && !((OutlinerMaterial)n).IsUnassigned)
                    nodeHandles.Add(n.Handle);
            }
            return nodeHandles.ToArray();
        }

        public Int32[] SelectedNodeHandles
        {
            get { return GetSelectedNodeHandles(true, true, true); }
        }

        public Int32[] SelectedObjectHandles
        {
            get { return GetSelectedNodeHandles(true, false, false); }
        }

        public Int32[] SelectedLayerHandles
        {
            get { return GetSelectedNodeHandles(false, true, false); }
        }

        public Int32[] SelectedMaterialHandles
        {
            get { return GetSelectedNodeHandles(false, false, true); }
        }

        public Int32[] SelectedLayerHandlesIndirect
        {
            get
            {
                List<Int32> layerHandles = new List<Int32>();
                foreach (OutlinerNode n in _selectedNodes)
                {
                    if (n is OutlinerLayer)
                    {
                        layerHandles.Add(n.Handle);
                        addChildLayerHandlesRecursive(n, ref layerHandles);
                    }
                }
                return layerHandles.ToArray();
            }
        }

        private void addChildLayerHandlesRecursive(OutlinerNode layer, ref List<Int32> handles)
        {
            foreach (OutlinerNode n in layer.ChildNodes)
            {
                if (n is OutlinerLayer)
                {
                    handles.Add(n.Handle);
                    addChildLayerHandlesRecursive(n, ref handles);
                }
            }
        }


        public Int32[] GetSelectedParentObjectHandles()
        {
            List<Int32> handles = new List<Int32>();

            foreach (OutlinerNode n in _selectedNodes)
            {
                if (n is OutlinerObject && !IsChildOfSelectedNode(n))
                {
                    handles.Add(n.Handle);
                }
            }

            return handles.ToArray();
        }

        #endregion
        


        #region SelectObject, SelectObjectRange, SelectAll

        public void SelectObject(Int32 handle, Boolean select)
        {
            OutlinerObject obj = this.Scene.GetObjectByHandle(handle);
            if (obj != null)
                SelectNode(obj, select);

            _selectionChanged = false;
        }

        public void SelectObjectRange(Int32[] handles, Boolean select)
        {
            foreach (Int32 handle in handles)
            {
                SelectObject(handle, select);
            }
            _selectionChanged = false;
            BeginTimedEnsureSelectionVisible(EnsureSelectionVisibleAction.SelectionChanged);
        }

        public void SelectLayer(Int32 handle, Boolean select)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(handle);
            if (layer != null)
                SelectNode(layer, select);
            _selectionChanged = false;
        }

        public void SelectLayerRange(Int32[] handles, Boolean select)
        {
            foreach (Int32 handle in handles)
            {
                SelectLayer(handle, select);
            }
            _selectionChanged = false;
        }

        public void SelectAll(Boolean select)
        {
            if (select)
                SelectAllNodes();
            else
                UnselectAllNodes();

            _selectionChanged = false;
        }

        #endregion

        #region SelectFilteredNodes

        public void SelectFilteredNodes()
        {
            this.BeginTimedUpdate();

            // Deselect all selected nodes.
            UnselectAllNodes();

            if (Filter.NameFilter != String.Empty)
            {
                RegexOptions options = Filter.NameFilterCaseSensitive ? RegexOptions.None : RegexOptions.IgnoreCase;
                foreach (KeyValuePair<OutlinerNode, TreeNode> kvp in _treeNodes)
                {
                    if (Regex.IsMatch(kvp.Key.Name, Filter.NameFilter, options))
                    {
                        SelectNode(kvp.Key, kvp.Value, true);
                    }
                }
            }
            EnsureSelectionVisible(EnsureSelectionVisibleAction.SelectionChanged);
            OnSelectionChanged();
        }

        #endregion


        #region ExpandedNodeHandles

        public Int32[] ExpandedNodeHandles
        {
            get
            {
                Int32[] handles = new Int32[_expandedNodes.Count];
                Int32 i = 0;
                foreach (OutlinerNode n in _expandedNodes)
                {
                    handles[i] = n.Handle;
                    i++;
                }
                return handles;
            }
            set
            {
                if (!(_autoExpandHierarchy && ListMode == OutlinerListMode.Hierarchy) && !(_autoExpandLayer && ListMode == OutlinerListMode.Layer))
                {
                    BeginTimedUpdate();
                    foreach (Int32 handle in value)
                    {
                        OutlinerNode node = Scene.GetNodeByHandle(handle);
                        if (node != null)
                        {
                            TreeNode tn;
                            if (_treeNodes.TryGetValue(node, out tn))
                                tn.Expand();
                            else if (!_expandedNodes.Contains(node))
                                _expandedNodes.Add(node);
                        }
                    }
                }
            }
        }

        #endregion



        // Generic functions

        #region EditNodeName

        public void EditNodeName(Int32 handle)
        {
            OutlinerNode n = Scene.GetNodeByHandle(handle);
            if (n == null)
                return;

            TreeNode tn;
            if (_treeNodes.TryGetValue(n, out tn))
                TreeNodeBeginEdit(tn);
        }

        #endregion



        //Object functions.
        #region AddObjectToTree, DeleteObject

        public void AddObjectToTree(Int32 handle)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj != null)
                AddObjectToTree(obj);
        }

        public void DeleteObject(Int32 handle)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj != null)
            {
                BeginTimedUpdate();
                OutlinerMaterial m = obj.Material;
                if (m != null && m.ChildNodesCount == 1)
                {
                    if (ListMode == OutlinerListMode.Material)
                        RemoveNodeFromTree(m, true);
                    else
                        RemoveNodeFromTree(obj, true);

                    Scene.RemoveMaterial(m);
                }
                else
                    RemoveNodeFromTree(obj, true);

                Scene.RemoveObject(obj);
            }
        }

        #endregion


        #region SetObjectName, SetLayerName

        public void SetObjectName(Int32 handle, String name)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj == null)
                return;

            obj.Name = name;

            TreeNode tn;
            if (_treeNodes.TryGetValue(obj, out tn))
            {
                BeginTimedUpdate();
                BeginTimedSort();
                tn.Text = obj.DisplayName;
            }
        }

        #endregion


        #region SetObjectHidden, SetObjectFrozen

        public void SetObjectHidden(Int32 handle, Boolean hidden)
        {
            OutlinerNode n = Scene.GetObjectByHandle(handle);

            if (n == null)
                return;

            BeginTimedUpdate();
            if (_treeViewNodeSorter is Outliner.NodeSorters.VisibilitySorter)
                BeginTimedSort();

            HideNode(n, hidden);
        }


        public void SetObjectFrozen(Int32 handle, Boolean frozen)
        {
            OutlinerNode n = Scene.GetObjectByHandle(handle);

            if (n == null)
                return;

            BeginTimedUpdate();

            FreezeNode(n, frozen);
        }

        #endregion


        #region SetObjectParent

        public void SetObjectParent(Int32 handle, Int32 newParentHandle, Boolean isGroupMember)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj == null)
                return;

            if (ListMode == OutlinerListMode.Layer)
            {
                Scene.SetObjectParentHandle(obj, newParentHandle);
                if (isGroupMember != obj.IsGroupMember)
                {
                    obj.IsGroupMember = isGroupMember;
                    if (HideGroupMembersLayerMode)
                    {
                        if (isGroupMember)
                            RemoveNodeFromTree(obj, true);
                        else
                            AddObjectToTree(obj);
                    }
                    else
                    {
                        TreeNode tn;
                        if (_treeNodes.TryGetValue(obj, out tn))
                        {
                            BeginTimedUpdate();
                            tn.Text = obj.DisplayName;
                        }
                    }
                }
            }
            else if (ListMode == OutlinerListMode.Hierarchy)
            {
                BeginTimedUpdate();
                BeginTimedSort();

                LinkObject(obj, newParentHandle, obj.IsGroupMember != isGroupMember, isGroupMember);
            }
        }

        #endregion


        #region SetObjectClass

        public void SetObjectClass(Int32 handle, String className, String superClassName)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj == null)
                return;
            
            obj.Class = className;
            obj.SuperClass = superClassName;

            TreeNode tn;
            if (_treeNodes.TryGetValue(obj, out tn))
            {
                Style.SetNodeImageKey(tn);
                BeginTimedUpdate();
            }

            Boolean showNode = Filter.ShowNode(obj);

            if (showNode && tn == null)
                AddObjectToTree(obj);
            else if (!showNode && tn != null)
                RemoveNodeFromTree(obj, true);
        }

        #endregion


        #region SetObjectLayer

        public void SetObjectLayer(Int32 handle, Int32 newLayerHandle)
        {
            OutlinerObject n = Scene.GetObjectByHandle(handle);
            if (n == null)
                return;

            if (newLayerHandle != n.LayerHandle)
                SetObjectLayer(n, newLayerHandle);
        }

        #endregion


        #region SetObjectMaterial

        public void SetObjectMaterial(Int32 handle, Int32 materialHandle)
        {
            OutlinerObject obj = Scene.GetObjectByHandle(handle);
            if (obj == null)
                return;

            SetObjectMaterial(obj, materialHandle);
        }

        #endregion



        // Layer functions.
        #region AddLayerToTree, DeleteLayer

        public void AddLayerToTree(Int32 layerHandle)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer != null)
                AddLayerToTree(layer);
        }

        public void DeleteLayer(Int32 layerHandle)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer != null)
            {
                BeginTimedUpdate();
                
                List<OutlinerNode> childLayers = layer.ChildLayers;
                if (childLayers.Count > 0)
                    BeginTimedSort();

                foreach (OutlinerNode clayer in childLayers)
                {
                    if (clayer is OutlinerLayer)
                        SetLayerParent((OutlinerLayer)clayer, OutlinerScene.RootHandle);
                }

                RemoveNodeFromTree(layer, true);
                Scene.RemoveLayer(layer);
            }
        }

        #endregion


        #region SetLayerName

        public void SetLayerName(Int32 layerHandle, String newName)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer == null)
                return;

            if (Scene.IsValidLayerName(layer, newName))
            {
                layer.Name = newName;

                if (ListMode == OutlinerListMode.Layer)
                {
                    TreeNode tn;
                    if (_treeNodes.TryGetValue(layer, out tn))
                    {
                        BeginTimedUpdate();
                        BeginTimedSort();
                        tn.Text = layer.DisplayName;
                    }
                }
                else if (_treeViewNodeSorter is Outliner.NodeSorters.LayerSorter)
                    BeginTimedSort();
            }
        }

        #endregion


        #region SetLayerHidden, SetLayerFrozen, SetLayerActive

        public void SetLayerHidden(Int32 layerHandle, Boolean isHidden)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer == null || layer.IsHidden == isHidden)
                return;

            layer.IsHidden = isHidden;

            if (ListMode == OutlinerListMode.Layer)
            {
                TreeNode tn;
                if (_treeNodes.TryGetValue(layer, out tn))
                {
                    BeginTimedUpdate();
                    Style.SetNodeImageKey(tn);
                    Style.SetNodeColorAuto(tn);
                    if (_treeViewNodeSorter is Outliner.NodeSorters.VisibilitySorter)
                        BeginTimedSort();
                }
            }
        }

        public void SetLayerFrozen(Int32 layerHandle, Boolean isFrozen)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer == null || layer.IsFrozen == isFrozen)
                return;

            layer.IsFrozen = isFrozen;

            if (ListMode == OutlinerListMode.Layer)
            {
                TreeNode tn;
                if (_treeNodes.TryGetValue(layer, out tn))
                {
                    BeginTimedUpdate();
                    Style.SetNodeColorAuto(tn);
                }
            }
        }

        //Function wrapper to avoid having to make 2 function calls from 3dsmax.
        public void SetLayerHiddenFrozen(Int32 layerHandle, Boolean isHidden, Boolean isFrozen)
        {
            SetLayerHidden(layerHandle, isHidden);
            SetLayerFrozen(layerHandle, isFrozen);
        }

        public void SetLayerActive(Int32 layerHandle, Boolean isActive)
        {
            OutlinerLayer layer = this.Scene.GetLayerByHandle(layerHandle);
            if (layer == null)
                return;

            layer.IsActive = isActive;

            if (ListMode == OutlinerListMode.Layer)
            {
                TreeNode tn;
                if (_treeNodes.TryGetValue(layer, out tn))
                {
                    BeginTimedUpdate();
                    this.Style.SetNodeImageKey(tn);
                }
            }
        }

        #endregion


        #region SetLayerParent

        public void SetLayerParent(Int32 layerHandle, Int32 parentLayerHandle)
        {
            OutlinerLayer layer = Scene.GetLayerByHandle(layerHandle);
            if (layer == null)
                return;

            if (ListMode == OutlinerListMode.Layer)
            {
                BeginTimedUpdate();
                BeginTimedSort();
                SetLayerParent(layer, parentLayerHandle);
            }
            else
                Scene.SetLayerParentHandle(layer, parentLayerHandle);
        }

        #endregion


        // Material functions.
        #region AddMaterialToTree

        public void AddMaterialToTree(Int32 materialHandle)
        {
            OutlinerMaterial mat = Scene.GetMaterialByHandle(materialHandle);
            if (mat != null)
                AddMaterialToTree(mat);
        }

        #endregion


        #region SetMaterialName

        public void SetMaterialName(Int32 handle, String newName)
        {
            OutlinerMaterial mat = Scene.GetMaterialByHandle(handle);
            if (mat == null)
                return;

            mat.Name = newName;

            if (ListMode == OutlinerListMode.Material)
            {
                TreeNode tn;
                if (_treeNodes.TryGetValue(mat, out tn))
                {
                    BeginTimedUpdate();
                    BeginTimedSort();
                    tn.Text = mat.DisplayName;
                }
            }
            else if (_treeViewNodeSorter is Outliner.NodeSorters.MaterialSorter)
                BeginTimedSort();
        }
        

        #endregion
    }
}