using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Resources;
using System.Runtime.InteropServices;
using System.Windows.Forms;
using System.Windows.Forms.VisualStyles;
using Outliner.Controls.DragDropHandlers;
using Outliner.Controls.Filters;
using Outliner.Controls.NodeSorters;
using Outliner.Scene;
using Outliner.Controls.TreeViewModes;

namespace Outliner.Controls
{
public class TreeView : System.Windows.Forms.TreeView
{
    private OutlinerScene _scene;
    internal OutlinerScene Scene 
    {
        get { return _scene; }
        set
        {
            if (_scene != null)
            {
                _scene.UpdateBegin -= _scene_UpdateBegin;
                _scene.UpdateEnd -= _scene_UpdateEnd;
            }
            _scene = value;
            _scene.UpdateBegin += _scene_UpdateBegin;
            _scene.UpdateEnd += _scene_UpdateEnd;
        }
    }
    

    protected HashSet<TreeNode> _selectedNodes;
    protected HashSet<Int32> _expandedNodes;
    protected TreeNode _lastSelectedTreeNode;

    private TreeViewMode _mode;
    public TreeViewMode Mode 
    {
        get { return _mode; }
        set
        {
            if (_mode != null)
                _mode.SwitchFromMode(this);

            if (value == null)
                _mode = new TreeViewNullMode();
            else
                _mode = value;

            _mode.SwitchToMode(this);
        }
    }
    private TreeViewColors _colors;
    public TreeViewColors Colors 
    {
        get { return _colors; }
        set
        {
            _colors = value;
            _backgroundBrush = null;
            _linePen = null;
            this.Invalidate();
        }
    }
    public TreeViewSettings Settings { get; set; }
    private NodeFilterCollection _filters;
    public NodeFilterCollection Filters 
    {
        get { return _filters; }
        set
        {
            if (_filters != null)
            {
                _filters.FiltersEnabled -= this.filtersEnabled;
                _filters.FiltersCleared -= this.filtersCleared;
                _filters.FilterAdded -= this.filterAdded;
                _filters.FilterRemoved -= this.filterRemoved;
                _filters.FilterChanged -= this.filterChanged;
            }

            _filters = value;
            _filters.FiltersEnabled += this.filtersEnabled;
            _filters.FiltersCleared += this.filtersCleared;
            _filters.FilterAdded += this.filterAdded;
            _filters.FilterRemoved += this.filterRemoved;
            _filters.FilterChanged += this.filterChanged;
        }
    }
    public TreeDragDropHandler DragDropHandler { get; protected set; }

   

    

    public TreeView() 
    {
        this.BeginUpdate();

        this.SetStyle(ControlStyles.UserPaint, true);
        this.SetStyle(ControlStyles.AllPaintingInWmPaint, true);
        this.SetStyle(ControlStyles.OptimizedDoubleBuffer, true);
        this.AllowDrop = true;

        _selectedNodes = new HashSet<TreeNode>();
        _expandedNodes = new HashSet<Int32>();
        _sortQueue = new List<TreeNodeCollection>();

        this.Font = new Font("Tahoma", 8f, FontStyle.Regular);
        this.Filters = new NodeFilterCollection();
        this.Mode = new HierarchyMode();
        this.Colors = new TreeViewColors();
        this.Settings = new TreeViewSettings();
        this.NodeSorter = new AlphabeticalSorter(this);
        this.IconSet = IconSet.Max;
        this.DragDropHandler = new TreeDragDropHandler(this);

        this.EndUpdate();
    }



    public override Color BackColor 
    {
        get
        {
            return this.Colors.BackColor;
        }
        set
        {
            this.Colors.BackColor = value;
        }
    }
    public override Color ForeColor 
    {
        get
        {
            return this.Colors.NodeForeColor;
        }
        set
        {
            this.Colors.NodeForeColor = value;
        }
    }



    #region BeginUpdate, EndUpdate

    private short _updateCount = 0;
    new public void BeginUpdate() 
    {
        _updateCount++;
        base.BeginUpdate();
    }
    new public void EndUpdate() 
    {
        if (_updateCount > 0)
            _updateCount--;

        if (_updateCount == 0)
            this.SortQueue();

        base.EndUpdate();
    }

    #endregion


    #region Paint

    private SolidBrush _backgroundBrush;
    protected override void OnPaintBackground(PaintEventArgs pevent)
    {
        if (_backgroundBrush == null)
            _backgroundBrush = new SolidBrush(BackColor);

        pevent.Graphics.FillRectangle(_backgroundBrush, this.ClientRectangle);
        //pevent.Graphics.FillRectangle(_backgroundBrush, pevent.ClipRectangle);
    }

    private Pen _linePen;
    private void createLinePen() 
    {
        _linePen = new Pen(LineColor);
        _linePen.DashStyle = System.Drawing.Drawing2D.DashStyle.Solid;
    }
    protected override void OnPaint(PaintEventArgs e) 
    {
        if (_updateCount > 0 || Nodes.Count == 0)
            return;

        Int32 curY = e.ClipRectangle.Y;
        while (curY <= e.ClipRectangle.Bottom)
        {
            TreeNode tn = GetNodeAt(0, curY);

            if (tn == null)
                break;

            Rectangle tnBounds = tn.Bounds;
            if (tnBounds.Width != 0 && tnBounds.Height != 0)
                this.DrawTreeNode(tn, tnBounds, e.Graphics);

            curY += ItemHeight;
        }
    }

    protected void DrawTreeNode(TreeNode tn, Rectangle tnBounds, Graphics graphics) 
    {
        TreeNodeData tnData = TreeNodeData.GetTreeNodeData(tn);
        if (tnData == null || tnData.OutlinerNode == null)
            return;

        Int32 scrollPosX = this.ScrollPosX;

        this.DrawTreeNodeLines(tn, tnBounds, graphics, scrollPosX);
        this.DrawTreeNodePlusMinus(tn, tnBounds, graphics, scrollPosX);
        this.DrawTreeNodeIcon(tn, tnBounds, graphics, scrollPosX, tnData.OutlinerNode, tnData.FilterResult);
        this.DrawTreeNodeText(tn, tnBounds, graphics, scrollPosX, tnData.OutlinerNode, tnData.FilterResult);
        this.DrawTreeNodeButtons(tn, tnBounds, graphics, scrollPosX, tnData.OutlinerNode);
    }
    protected void DrawTreeNodeLines(TreeNode tn, Rectangle tnBounds, Graphics graphics, Int32 scrollPosX) 
    {
        if (_linePen == null)
            createLinePen();

        //Draw vertical line segments for parent nodes with next nodes.
        Int32 xPos = Indent * tn.Level + _plusMinPadding - scrollPosX;
        TreeNode parent = tn.Parent;
        while (parent != null)
        {
            xPos -= Indent;
            if (parent.NextNode != null)
            {
                Int32 x = xPos + _halfPlusMinSize;
                graphics.DrawLine(_linePen, x, tnBounds.Y, x, tnBounds.Bottom);
            }
            parent = parent.Parent;
        }

        //Draw L / T shaped line in front of node.
        Int32 lineX = Indent * tn.Level + _plusMinPadding + _halfPlusMinSize - scrollPosX;
        Int32 nodeYMid = tnBounds.Y + (int)Math.Ceiling(ItemHeight / 2f) - 1;
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

        graphics.DrawLine(_linePen, lineX, vlineStartY, lineX, vlineEndY);
        graphics.DrawLine(_linePen, lineX, nodeYMid, lineX + _halfPlusMinSize + _plusMinPadding - 1, nodeYMid);
    }
    protected void DrawTreeNodePlusMinus(TreeNode tn, Rectangle tnBounds, Graphics graphics, Int32 scrollPosX) 
    {
        if (tn.GetNodeCount(false) == 0)
            return;

        if (Application.RenderWithVisualStyles)
        {
            VisualStyleElement element = (tn.IsExpanded) ? VisualStyleElement.TreeView.Glyph.Opened : VisualStyleElement.TreeView.Glyph.Closed;
            VisualStyleRenderer renderer = new VisualStyleRenderer(element);
            renderer.DrawBackground(graphics, GetPlusMinusBounds(tn, false));
        }
        else
        {
            Rectangle bounds = this.GetPlusMinusBounds(tn, false);
            ControlPaint.DrawButton(graphics, bounds, ButtonState.Normal);

            bounds.Width -= 1;
            bounds.Height -= 1;
            graphics.DrawLine(SystemPens.ControlText, bounds.X + 2, bounds.Y + bounds.Height / 2, bounds.X + bounds.Width - 2, bounds.Y + bounds.Height / 2);
            if (!tn.IsExpanded)
                graphics.DrawLine(SystemPens.ControlText, bounds.X + bounds.Width / 2, bounds.Y + 2, bounds.X + bounds.Width / 2, bounds.Y + bounds.Height - 2);
        }
    }
    protected void DrawTreeNodeIcon(TreeNode tn, Rectangle tnBounds, Graphics graphics, Int32 scrollPosX, OutlinerNode n, FilterResult filterResult) 
    {
        if (!this.Settings.ShowNodeIcon)
            return;

        Bitmap img;
        String imgKey = tn.ImageKey;
        if ((filterResult & FilterResult.ShowChildren) == FilterResult.ShowChildren)
            imgKey += "_filtered";
        else if (!this.Settings.ShowNodeHideButton && this.Settings.IconClickAction == IconClickAction.Hide)
        {
            if (n is IDisplayable && ((IDisplayable)n).IsHidden)
                imgKey += "_hidden";
        }
        else if (!this.Settings.ShowNodeFreezeButton && this.Settings.IconClickAction == IconClickAction.Freeze)
        {
            if (n is IDisplayable && ((IDisplayable)n).IsFrozen)
                imgKey += "_hidden";
        }
        if (_icons.TryGetValue(imgKey, out img) || _icons.TryGetValue("unknown", out img))
            graphics.DrawImage(img, this.GetIconBounds(tn, false, n));
    }
    protected void DrawTreeNodeText(TreeNode tn, Rectangle tnBounds, Graphics graphics, Int32 scrollPosX, OutlinerNode n, FilterResult filterResult) 
    {
        if (!tn.IsEditing)
        {
            Rectangle txtBgBounds = this.GetTextBackgroundBounds(tn, n);
            Point txtLocation = txtBgBounds.Location;

            SizeF txtSize = graphics.MeasureString(tn.Text, this.Font);
            txtBgBounds.Width = (int)txtSize.Width - 1;

            txtLocation.Y += (Int32)((float)ItemHeight - txtSize.Height) / 2 + 1;

            Color foreColor;
            if (filterResult == FilterResult.ShowChildren)
                foreColor = Color.FromArgb(50, tn.ForeColor.R, tn.ForeColor.G, tn.ForeColor.B);
            else
                foreColor = this.ForeColor;

            using (SolidBrush bgBrush = new SolidBrush(tn.BackColor), fgBrush = new SolidBrush(foreColor))
            {
                graphics.FillRectangle(bgBrush, txtBgBounds);
                graphics.DrawString(n.DisplayName, this.Font, fgBrush, txtLocation);
            }
        }
    }
    protected void DrawTreeNodeButtons(TreeNode tn, Rectangle tnBounds, Graphics graphics, Int32 scrollPosX, OutlinerNode n) 
    {
        if (this.Settings.ShowNodeHideButton && n is IDisplayable)
        {
            Boolean isHidden = ((IDisplayable)n).IsHidden || (n is OutlinerObject && n.Layer != null && ((IDisplayable)n.Layer).IsHidden);
            if ((isHidden && !this.Settings.InvertNodeHideButton) || (!isHidden && this.Settings.InvertNodeHideButton))
                graphics.DrawImage(OutlinerResources.hide_button, this.GetHideButtonBounds(tn, n));
            else
                graphics.DrawImage(OutlinerResources.hide_button_disabled, this.GetHideButtonBounds(tn, n));
        }

        if (this.Settings.ShowNodeFreezeButton && n is IDisplayable)
        {
            if (((IDisplayable)n).IsFrozen || (n is OutlinerObject && n.Layer != null && ((IDisplayable)n.Layer).IsFrozen))
                graphics.DrawImage(OutlinerResources.freeze_button, this.GetFreezeButtonBounds(tn, n));
            else
                graphics.DrawImage(OutlinerResources.freeze_button_disabled, this.GetFreezeButtonBounds(tn, n));
        }

        if (this.Settings.ShowNodeBoxModeButton && n is IDisplayable)
        {
            if (((IDisplayable)n).BoxMode)
                graphics.DrawImage(OutlinerResources.boxmode_button, this.GetBoxModeButtonBounds(tn, n));
            else
                graphics.DrawImage(OutlinerResources.boxmode_button_disabled, this.GetBoxModeButtonBounds(tn, n));
        }

        if (this.Settings.ShowNodeAddToLayerButton && (n is OutlinerLayer || n is SelectionSet))
        {
            if (n.CanAddNodes(this.SelectedNodes))
                graphics.DrawImage(OutlinerResources.add_button, this.GetAddToLayerButtonBounds(tn, n));
            else
                graphics.DrawImage(OutlinerResources.add_button_disabled, this.GetAddToLayerButtonBounds(tn, n));
        }
    }

    internal void InvalidateTreeNode(TreeNode tn)
    {
        Rectangle r = new Rectangle(0, tn.Bounds.Y, ClientSize.Width, this.ItemHeight);
        Invalidate(r);
    }

    #endregion


    #region ScrollPosition

    [DllImport("user32.dll", CharSet = System.Runtime.InteropServices.CharSet.Auto)]
    private static extern int GetScrollPos(IntPtr hWnd, int nBar);
    [DllImport("user32.dll")]
    private static extern int SetScrollPos(IntPtr hWnd, int nBar, int nPos, bool bRedraw);
    [DllImport("user32.dll")]
    private static extern int SendMessage(IntPtr hWnd, int wMsg, int wParam, int lParam);
    
    protected Point ScrollPos 
    {
        get
        {
            return new Point(this.ScrollPosX, this.ScrollPosY);
        }
        set
        {
            this.ScrollPosX = value.X;
            this.ScrollPosY = value.Y;
        }
    }
    protected int ScrollPosX 
    {
        get { return GetScrollPos(this.Handle, 0); }
        set { SetScrollPos(this.Handle, 0, value, true); }
    }
    protected int ScrollPosY 
    {
        get { return GetScrollPos(this.Handle, 1); }
        set { SetScrollPos(this.Handle, 1, value, true); }
    }

    #endregion


    #region Node Bounds methods

    private const Int32 _plusMinSize = 9;
    private const Int32 _halfPlusMinSize = _plusMinSize / 2;
    private Int32 _plusMinPadding = 3;
    private Int32 _iconPadding = 1;
    private Int32 _nodeButtonSpacing = 1;
    private Size _hideButtonSize = new Size(8, 16);
    private Size _freezeButtonSize = new Size(12, 16);
    private Size _boxModeButtonSize = new Size(9, 16);
    private Size _addButtonSize = new Size(9, 16);

    private Int32 _indent = 12;
    public new Int32 Indent 
    {
        get { return _indent; }
        set { _indent = value; }
    }

    private Rectangle GetNodeBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null)
            return Rectangle.Empty;

        Rectangle r = new Rectangle();

        r.X = Indent * tn.Level - this.ScrollPosX;
        r.Y = tn.Bounds.Y;
        r.Width = _plusMinPadding * 2 + _plusMinSize + tn.Bounds.Width - 1;
        if (this.Settings.ShowNodeIcon) r.Width += _iconPadding * 2 + _iconSize.Width;

        if (n is IDisplayable)
        {
            Int32 buttonsBeforeImage = 0;
            if (this.Settings.ShowNodeHideButton)
            {
                r.Width += _hideButtonSize.Width;
                buttonsBeforeImage++;
            }
            if (this.Settings.ShowNodeFreezeButton)
            {
                r.Width += _freezeButtonSize.Width;
                buttonsBeforeImage++;
            }
            if (this.Settings.ShowNodeBoxModeButton)
            {
                r.Width += _boxModeButtonSize.Width;
                buttonsBeforeImage++;
            }

            r.Width += _nodeButtonSpacing * buttonsBeforeImage;
        }

        if (this.Settings.ShowNodeAddToLayerButton && n is OutlinerLayer)
            r.Width += _addButtonSize.Width;

        r.Height = ItemHeight;
        
        return r;
    }
    private Rectangle GetNodeBounds(TreeNode tn) 
    {
        return this.GetNodeBounds(tn, TreeNodeData.GetOutlinerNode(tn));
    }

    private Rectangle GetNodeButtonBounds(TreeNode tn, OutlinerNode n) 
    {
        Rectangle r = new Rectangle();
        r.X = GetPlusMinusBounds(tn, true).Right;
        r.Y = tn.Bounds.Y;
        
        if (n is IDisplayable)
        {
            Int32 buttonsBeforeImage = 0;
            if (this.Settings.ShowNodeHideButton)
            {
                r.Width += _hideButtonSize.Width;
                buttonsBeforeImage++;
            }
            if (this.Settings.ShowNodeFreezeButton)
            {
                r.Width += _freezeButtonSize.Width;
                buttonsBeforeImage++;
            }
            if (this.Settings.ShowNodeBoxModeButton)
            {
                r.Width += _boxModeButtonSize.Width;
                buttonsBeforeImage++;
            }

            r.Width += _nodeButtonSpacing * buttonsBeforeImage;
        }
        return r;
    }

    private Rectangle GetPlusMinusBounds(TreeNode tn, Boolean includePadding) 
    {
        if (tn == null)
            return Rectangle.Empty;

        Rectangle r = new Rectangle();
        
        r.X = this.Indent * tn.Level + _plusMinPadding - this.ScrollPosX;
        r.Y = tn.Bounds.Y + (this.ItemHeight - _plusMinSize) / 2;
        r.Width = _plusMinSize;
        r.Height = _plusMinSize;

        if (includePadding)
        {
            r.X -= _plusMinPadding;
            r.Width += _plusMinPadding * 2;
        }

        return r;
    }
    private Rectangle GetHideButtonBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeHideButton || !(n is IDisplayable))
            return Rectangle.Empty;

        Rectangle r = new Rectangle();

        r.X = this.GetPlusMinusBounds(tn, true).Right;
        r.Y = tn.Bounds.Y + (ItemHeight - _hideButtonSize.Height) / 2;
        r.Size = _hideButtonSize;

        return r;
    }
    private Rectangle GetFreezeButtonBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeFreezeButton || !(n is IDisplayable))
            return Rectangle.Empty;

        Rectangle r = new Rectangle();
        
        r.X = this.GetPlusMinusBounds(tn, true).Right;
        if (this.Settings.ShowNodeHideButton) r.X += _hideButtonSize.Width + _nodeButtonSpacing;

        r.Y = tn.Bounds.Y + (ItemHeight - _freezeButtonSize.Height) / 2;
        r.Size = _freezeButtonSize;

        return r;
    }
    private Rectangle GetBoxModeButtonBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeBoxModeButton || !(n is IDisplayable))
            return Rectangle.Empty;

        Rectangle r = new Rectangle();

        r.X = this.GetPlusMinusBounds(tn, true).Right;
        if (this.Settings.ShowNodeHideButton) r.X += _hideButtonSize.Width + _nodeButtonSpacing;
        if (this.Settings.ShowNodeFreezeButton) r.X += _freezeButtonSize.Width + _nodeButtonSpacing;

        r.Y = tn.Bounds.Y + (ItemHeight - _boxModeButtonSize.Height) / 2;
        r.Size = _boxModeButtonSize;

        return r;
    }
    private Rectangle GetAddToLayerButtonBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeAddToLayerButton)
            return Rectangle.Empty;

        Rectangle r = new Rectangle();

        r.X = this.GetTextBackgroundBounds(tn, n).Right;
        r.Y = tn.Bounds.Y + (ItemHeight - _addButtonSize.Height) / 2;
        r.Size = _addButtonSize;

        return r;
    }
    private Rectangle GetAddToLayerButtonBounds(TreeNode tn) 
    {
        return this.GetAddToLayerButtonBounds(tn, TreeNodeData.GetOutlinerNode(tn));
    }
    private Rectangle GetIconBounds(TreeNode tn, Boolean includePadding, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeIcon)
            return Rectangle.Empty;

        Rectangle r = new Rectangle();

        r.X = this.GetNodeButtonBounds(tn, n).Right + _iconPadding;
        r.Y = tn.Bounds.Y + (ItemHeight - _iconSize.Height) / 2;
        r.Width = _iconSize.Width;
        r.Height = _iconSize.Height;

        if (includePadding)
        {
            r.X -= _iconPadding;
            r.Width += _iconPadding * 2;
        }

        return r;
    }
    private Rectangle GetIconBounds(TreeNode tn, Boolean includePadding) 
    {
        return this.GetIconBounds(tn, includePadding, TreeNodeData.GetOutlinerNode(tn));
    }
    private Rectangle GetTextBackgroundBounds(TreeNode tn, OutlinerNode n) 
    {
        if (tn == null)
            return Rectangle.Empty;

        Rectangle r = tn.Bounds;

        r.X = this.GetIconBounds(tn, true, n).Right;

        return r;
    }
    private Rectangle GetTextBackgroundBounds(TreeNode tn) 
    {
        return this.GetTextBackgroundBounds(tn, TreeNodeData.GetOutlinerNode(tn));
    }


    private Boolean IsClickOnPlusMinus(TreeNode tn, Point location) 
    {
        if (tn == null)
            return false;

        return GetPlusMinusBounds(tn, false).Contains(location);
    }
    private Boolean IsClickOnHideButton(TreeNode tn, Point location, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeHideButton || !(n is IDisplayable))
            return false;

        return this.GetHideButtonBounds(tn, n).Contains(location);
    }
    private Boolean IsClickOnFreezeButton(TreeNode tn, Point location, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeFreezeButton || !(n is IDisplayable))
            return false;

        return this.GetFreezeButtonBounds(tn, n).Contains(location);
    }
    private Boolean IsClickOnBoxModeButton(TreeNode tn, Point location, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeBoxModeButton || !(n is IDisplayable))
            return false;

        return this.GetBoxModeButtonBounds(tn, n).Contains(location);
    }
    private Boolean IsClickOnAddToLayerButton(TreeNode tn, Point location, OutlinerNode n) 
    {
        if (tn == null || !this.Settings.ShowNodeAddToLayerButton || !(n is OutlinerLayer))
            return false;

        return this.GetAddToLayerButtonBounds(tn, n).Contains(location);
    }
    private Boolean IsClickOnAddToLayerButton(TreeNode tn, Point location) 
    {
        return IsClickOnAddToLayerButton(tn, location, TreeNodeData.GetOutlinerNode(tn));
    }
    private Boolean IsClickOnIcon(TreeNode tn, Point location, OutlinerNode n)
    {
        if (tn == null || !this.Settings.ShowNodeIcon)
            return false;

        return this.GetIconBounds(tn, false, n).Contains(location);
    }
    private Boolean IsClickOnIcon(TreeNode tn, Point location) 
    {
        if (tn == null || !this.Settings.ShowNodeIcon)
            return false;

        return this.GetIconBounds(tn, false).Contains(location);
    }
    private Boolean IsClickOnText(TreeNode tn, Point location, OutlinerNode n)
    {
        if (tn == null)
            return false;

        return this.GetTextBackgroundBounds(tn, n).Contains(location);
    }
    private Boolean IsClickOnText(TreeNode tn, Point location) 
    {
        if (tn == null)
            return false;

        return this.GetTextBackgroundBounds(tn).Contains(location);
    }
   
    private Boolean IsClickOnNode(TreeNode tn, Point location) 
    {
        if (tn == null)
            return false;

        return this.GetNodeBounds(tn).Contains(location);
    }
    private Boolean IsClickLeftOfText(TreeNode tn, Point location) 
    {
        if (tn == null)
            return false;

        return location.X <= this.GetTextBackgroundBounds(tn).Right;
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

            this.ItemHeight = (_iconSize.Height > 0) ? _iconSize.Height + 2 : 16;

            // Create dummy imagelist to more or less 'correct' labeledit textbox position.
            ImageList = new ImageList();
        }
    }

    #endregion


    #region Selection

    public event SelectionChangedEventHandler SelectionChanged;
    protected void OnSelectionChanged() 
    {
        if (this.SelectionChanged != null)
        {
            List<OutlinerNode> nodes = new List<OutlinerNode>();
            foreach (TreeNode tn in _selectedNodes)
            {
                nodes.Add(TreeNodeData.GetOutlinerNode(tn));
            }
            this.SelectionChanged(this, new SelectionChangedEventArgs(nodes));
        }
    }

    public void SelectNode(TreeNode tn, Boolean select) 
    {
        if (tn == null)
            return;

        if (select)
        {
            this.SetNodeColor(tn, NodeColor.Selected);

            if (!this.IsSelectedNode(tn))
                _selectedNodes.Add(tn);

            this.HighlightParentNodes(tn);

            _lastSelectedTreeNode = tn;
        }
        else
        {
            _selectedNodes.Remove(tn);

            if (IsParentOfSelectedNode(tn, true))
                this.SetNodeColor(tn, NodeColor.ParentOfSelected);
            else
                this.SetNodeColor(tn, NodeColor.Default);

            this.RemoveParentHighlights(tn);
        }
    }
    public void SelectNode(OutlinerNode n, Boolean select) 
    {
        this.SelectNode(this.Mode.GetTreeNode(n), select);
    }
    public void SelectAllNodes(Boolean select) 
    {
        this.SelectAllNodes(select, this.Nodes);
    }
    private void SelectAllNodes(Boolean select, TreeNodeCollection nodes) 
    {
        foreach (TreeNode tn in nodes)
        {
            SelectNode(tn, select);
            this.SelectAllNodes(select, tn.Nodes);
        }
    }
    public void SelectNodesInsideRange(TreeNode startNode, TreeNode endNode)
    {
        if (startNode == null || endNode == null)
            return;

        // Calculate start node and end node
        TreeNode firstNode = startNode;
        TreeNode lastNode = endNode;
        if (startNode.Bounds.Y > endNode.Bounds.Y)
        {
            firstNode = endNode;
            lastNode = startNode;
        }

        // Select each node in range
        TreeNode tnTemp = firstNode;
        while (tnTemp != lastNode && tnTemp != null)
        {
            if (tnTemp != null)
            {
                SelectNode(tnTemp, true);
                tnTemp = tnTemp.NextVisibleNode;
            }
        }
        SelectNode(lastNode, true);
    }

    public Boolean IsSelectedNode(TreeNode tn) 
    {
        if (tn == null)
            return false;

        return _selectedNodes.Contains(tn);
    }
    public Boolean IsParentOfSelectedNode(TreeNode tn, Boolean includeChildren) 
    {
        if (tn == null || this.IsSelectedNode(tn))
            return false;

        foreach (TreeNode sn in _selectedNodes)
        {
            if (!includeChildren)
            {
                if (sn.Parent == tn)
                    return true;
            }
            else
            {
                TreeNode pn = sn.Parent;
                while (pn != null)
                {
                    if (pn == tn)
                        return true;
                    pn = pn.Parent;
                }
            }
        }

        return false;
    }
    public Boolean IsChildOfSelectedNode(TreeNode tn) 
    {
        if (tn == null)
            return false;

        TreeNode parentNode = tn.Parent;
        while (parentNode != null)
        {
            if (IsSelectedNode(parentNode))
                return true;

            parentNode = parentNode.Parent;
        }

        return false;
    }

    public Int32[] GetSelectedNodeHandles(Boolean includeObjects, Boolean includeLayers, Boolean includeMaterials) 
    {
        List<Int32> nodeHandles = new List<Int32>();
        foreach (TreeNode tn in _selectedNodes)
        {
            OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
            if (includeObjects && n is OutlinerObject)
                nodeHandles.Add(n.Handle);
            else if (includeLayers && n is OutlinerLayer)
                nodeHandles.Add(n.Handle);
            else if (includeMaterials && n is OutlinerMaterial && !((OutlinerMaterial)n).IsUnassigned)
                nodeHandles.Add(n.Handle);
        }
        return nodeHandles.ToArray();
    }
    public Int32[] SelectedNodeHandles 
    {
        get { return this.GetSelectedNodeHandles(true, true, true); }
    }
    public Int32[] SelectedObjectHandles 
    {
        get { return this.GetSelectedNodeHandles(true, false, false); }
    }
    public Int32[] SelectedLayerHandles 
    {
        get { return this.GetSelectedNodeHandles(false, true, false); }
    }
    public Int32[] SelectedMaterialHandles 
    {
        get { return this.GetSelectedNodeHandles(false, false, true); }
    }
    public Int32[] SelectedLayerHandlesIndirect 
    {
        get
        {
            List<Int32> layerHandles = new List<Int32>();
            foreach (TreeNode tn in _selectedNodes)
            {
                OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
                if (n is OutlinerLayer)
                {
                    layerHandles.Add(n.Handle);
                    this.addChildLayerHandlesRecursive(n, ref layerHandles);
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

        foreach (TreeNode tn in _selectedNodes)
        {
            OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
            if (n is OutlinerObject && !this.IsChildOfSelectedNode(tn))
                handles.Add(n.Handle);
        }

        return handles.ToArray();
    }
    public List<OutlinerNode> SelectedNodes 
    {
        get
        {
            List<OutlinerNode> selNodes = new List<OutlinerNode>(_selectedNodes.Count);
            foreach (TreeNode tn in _selectedNodes)
            {
                selNodes.Add(TreeNodeData.GetOutlinerNode(tn));
            }
            return selNodes;
        }
    }

    protected virtual void HighlightParentNodes(TreeNode tn) 
    {
        if (tn == null)
            return;

        tn = tn.Parent;
        while (tn != null && !this.IsSelectedNode(tn))
        {
            this.SetNodeColor(tn, NodeColor.ParentOfSelected);
            tn = tn.Parent;
        }
    }
    protected virtual void RemoveParentHighlights(TreeNode tn) 
    {
        if (tn == null)
            return;

        tn = tn.Parent;
        while (tn != null && !this.IsSelectedNode(tn) && !this.IsParentOfSelectedNode(tn, true))
        {
            this.SetNodeColor(tn, NodeColor.Default);
            tn = tn.Parent;
        }
    }

    #endregion


    #region Mouse Events

    private Boolean _handlingMouseClick = false;
    private Boolean _internalExpandCollapse = false;
    private Boolean _restoringExpandedStates = false;
    private Int32 _numMouseClicks = 0; 

    // Override the OnBeforeSelect, OnBeforeExpand, OnBeforeCollapse event to cancel it (we'll do this ourselves, thank you).
    protected override void OnBeforeSelect(TreeViewCancelEventArgs e) 
    {
        e.Cancel = true;
    }
    protected override void OnBeforeCollapse(TreeViewCancelEventArgs e) 
    {
        if (!_internalExpandCollapse)
            e.Cancel = true;
        else
        {
            TreeNodeData tnData = TreeNodeData.GetTreeNodeData(e.Node);
            if (tnData != null && tnData.OutlinerNode != null)
                _expandedNodes.Remove(tnData.OutlinerNode.Handle);
        }

        base.OnBeforeCollapse(e);
    }
    protected override void OnBeforeExpand(TreeViewCancelEventArgs e) 
    {
        if (!_internalExpandCollapse && !_restoringExpandedStates)
            e.Cancel = true;
        else if (!_restoringExpandedStates)
        {
            TreeNodeData tnData = TreeNodeData.GetTreeNodeData(e.Node);
            if (tnData != null && tnData.OutlinerNode != null)
                _expandedNodes.Add(tnData.OutlinerNode.Handle);
        }

        base.OnBeforeExpand(e);
    }
    // Override DefWndProc to block double-click expand if necessary.
    protected override void DefWndProc(ref Message m) 
    {
        /* WM_LBUTTONDBLCLK BLOCKED */
        if (m.Msg != 515 || this.Settings.DoubleClickAction != DoubleClickAction.Expand)
            base.DefWndProc(ref m);
    }
    
    protected override void OnMouseDown(MouseEventArgs e) 
    {
        _handlingMouseClick = true;
        _numMouseClicks = e.Clicks;

        TreeNode tn = this.GetNodeAt(e.X, e.Y);
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);

        if (this.IsClickOnText(tn, e.Location, n))
            this.OnNodeTextClick(tn, e);

        base.OnMouseUp(e);
    }
    protected override void OnMouseClick(MouseEventArgs e)
    {
        _handlingMouseClick = true;
        _numMouseClicks = e.Clicks;

        TreeNode tn = this.GetNodeAt(e.X, e.Y);
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);

        if (this.IsClickOnHideButton(tn, e.Location, n))
            this.OnHideButtonClick(tn, e);
        else if (this.IsClickOnFreezeButton(tn, e.Location, n))
            this.OnFreezeButtonClick(tn, e);
        else if (this.IsClickOnBoxModeButton(tn, e.Location, n))
            this.OnBoxModeButtonClick(tn, e);
        else if (this.IsClickOnAddToLayerButton(tn, e.Location, n))
            this.OnAddToLayerButtonClick(tn, e);
        else if (this.IsClickOnIcon(tn, e.Location, n))
            this.OnNodeIconClick(tn, e);
        else if (this.IsClickOnPlusMinus(tn, e.Location))
            this.OnPlusMinusClick(tn, e);
        else if (!this.IsClickLeftOfText(tn, e.Location))
            this.OnBackgroundClick(e);

        base.OnMouseClick(e);
    }

    private void OnHideButtonClick(TreeNode tn, MouseEventArgs e) 
    {
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
        if (!(n is IDisplayable))
            return;

        Boolean isHidden = !((IDisplayable)n).IsHidden;
        List<Int32> handles = new List<Int32>();

        ((IDisplayable)n).IsHidden = isHidden;

        //this.NodeChangedHidden(n);

        //this.OnNodeHiddenChanged(new NodePropertyChangedEventArgs(this.SelectedNodeHandles, isHidden));
    }
    private void OnFreezeButtonClick(TreeNode tn, MouseEventArgs e) 
    {
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
        if (!(n is IDisplayable))
            return;

        Boolean isFrozen = !((IDisplayable)n).IsFrozen;
        List<Int32> handles = new List<Int32>();

        ((IDisplayable)n).IsFrozen = isFrozen;

        //this.NodeChangedFrozen(n);

        //this.OnNodeFrozenChanged(new NodePropertyChangedEventArgs(this.SelectedNodeHandles, isFrozen));
    }
    private void OnBoxModeButtonClick(TreeNode tn, MouseEventArgs e) 
    {
        throw new NotImplementedException();
    }
    private void OnAddToLayerButtonClick(TreeNode tn, MouseEventArgs e) 
    {
        throw new NotImplementedException();
    }
    private void OnNodeIconClick(TreeNode tn, MouseEventArgs e) 
    {
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);
        if (n == null)
            return;

        if (this.Settings.IconClickAction == IconClickAction.SetLayerActive && n is OutlinerLayer)
            ((OutlinerLayer)n).IsActive = true;
    }
    private void OnPlusMinusClick(TreeNode tn, MouseEventArgs e) 
    {
        _internalExpandCollapse = true;

        if (tn.IsExpanded)
            tn.Collapse(!((Control.ModifierKeys & Keys.Control) == Keys.Control));
        else
        {
            if ((Control.ModifierKeys & Keys.Control) == Keys.Control)
                tn.ExpandAll();
            else
                tn.Expand();
        }

        _internalExpandCollapse = false;
    }
    private void OnNodeTextClick(TreeNode tn, MouseEventArgs e) 
    {
        Boolean shiftPressed = (Control.ModifierKeys & Keys.Shift) == Keys.Shift;
        Boolean ctrlPressed = (Control.ModifierKeys & Keys.Control) == Keys.Control;

        Boolean leftMouseBtnPressed = (e.Button & MouseButtons.Left) == MouseButtons.Left;
        Boolean rightMouseBtnPressed = (e.Button & MouseButtons.Right) == MouseButtons.Right;
        Boolean middleMouseBtnPressed = (e.Button & MouseButtons.Middle) == MouseButtons.Middle;

        if (leftMouseBtnPressed || (!this.IsSelectedNode(tn) && (rightMouseBtnPressed || middleMouseBtnPressed)))
        {
            if (!ctrlPressed && !shiftPressed)
                SelectAllNodes(false);

            if (shiftPressed)
            {
                if (_lastSelectedTreeNode == null)
                    _lastSelectedTreeNode = tn;

                this.SelectNodesInsideRange(_lastSelectedTreeNode, tn);
            }
            else
                this.SelectNode(tn, !this.IsSelectedNode(tn));

            this.OnSelectionChanged();
        }

        if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
            this.showContextMenu(PointToScreen(e.Location));
        else if ((e.Button & this.Settings.DragMouseButton) == this.Settings.DragMouseButton && (this.Settings.DragMouseButton & MouseButtons.Middle) == MouseButtons.Middle && _numMouseClicks == 1)
            this.OnItemDrag(new ItemDragEventArgs(e.Button, tn));
    }
    private void OnBackgroundClick(MouseEventArgs e) 
    {
        if ((e.Button & MouseButtons.Left) == MouseButtons.Left && Control.ModifierKeys == Keys.None)
        {
            this.SelectAllNodes(false);
            this.OnSelectionChanged();
        }
        else if ((e.Button & MouseButtons.Right) == MouseButtons.Right)
            this.showContextMenu(PointToScreen(e.Location));
    }

    #endregion


    #region Sort

    private IComparer<TreeNode> _nodeSorter;
    public IComparer<TreeNode> NodeSorter 
    {
        get { return _nodeSorter; }
        set
        {
            _nodeSorter = value;
            this.Sort();
        }
    }
    new public IComparer TreeViewNodeSorter 
    {
        get { return null; }
        set { }
    }
    new public Boolean Sorted 
    {
        get { return false; }
        set { }
    }
    new public void Sort() 
    {
        this.Sort(this.Nodes, true);
        this.restoreExpandedStates();
        _sortQueue.Clear();
    }
    public void Sort(TreeNodeCollection nodes, Boolean recursive) 
    {
        if (this.NodeSorter == null || nodes == null)
            return;

        if (nodes.Count == 1 && recursive)
            this.Sort(nodes[0].Nodes, true);
        else
        {
            TreeNode[] dest = new TreeNode[nodes.Count];
            nodes.CopyTo(dest, 0);

            Array.Sort<TreeNode>(dest, this.NodeSorter);

            if (recursive)
            {
                foreach (TreeNode tn in dest)
                {
                    if (tn.GetNodeCount(false) > 0)
                        this.Sort(tn.Nodes, true);
                }
            }

            nodes.Clear();
            nodes.AddRange(dest);
        }
    }

    protected List<TreeNodeCollection> _sortQueue;
    /// <summary>
    /// Adds the TreeNodeCollection to the sort queue.
    /// </summary>
    internal void AddToSortQueue(TreeNodeCollection nodes) 
    {
        if (!_sortQueue.Contains(nodes))
            _sortQueue.Add(nodes);
    }
    /// <summary>
    /// Adds the parent's TreeNodeCollection to the sort queue.
    /// </summary>
    internal void AddToSortQueue(TreeNode tn)
    {
        if (tn == null)
            return;

        if (tn.Parent != null)
            this.AddToSortQueue(tn.Parent.Nodes);
        else
            this.AddToSortQueue(this.Nodes);
    }
    /// <summary>
    /// Adds the parent's TreeNodeCollection to the sort queue.
    /// </summary>
    internal void AddToSortQueue(OutlinerNode node) 
    {
        TreeNode tn = this.Mode.GetTreeNode(node);
        this.AddToSortQueue(tn);
    }
    internal void SortQueue() 
    {
        if (_sortQueue == null || _sortQueue.Count == 0)
            return;

        foreach (TreeNodeCollection nodes in _sortQueue)
        {
            this.Sort(nodes, false);
        }

        _sortQueue.Clear();

        this.restoreExpandedStates();
    }
    
    #endregion


    #region Filter Events

    private void filtersEnabled(object sender, EventArgs e) 
    {
        this.Mode.FiltersEnabled(this);
    }
    private void filtersCleared(object sender, EventArgs e) 
    {
        this.Mode.FiltersCleared(this);
    }
    private void filterAdded(object sender, NodeFilterChangedEventArgs e) 
    {
        this.Mode.FilterAdded(this, e.Filter);
    }
    private void filterRemoved(object sender, NodeFilterChangedEventArgs e) 
    {
        this.Mode.FilterRemoved(this, e.Filter);
    }
    private void filterChanged(object sender, NodeFilterChangedEventArgs e) 
    {
        this.Mode.FilterChanged(this, e.Filter);
    }

    #endregion


    private void restoreExpandedStates() 
    {
        _restoringExpandedStates = true;

        foreach (Int32 handle in _expandedNodes)
        {
            TreeNode tn = this.Mode.GetTreeNode(handle);
            if (tn != null && tn.TreeView != null)
                tn.Expand();
        }

        _restoringExpandedStates = false;
    }


    internal TreeNode CreateTreeNode(OutlinerNode n) 
    {
        return this.CreateTreeNode(n, new TreeNodeData(n, Outliner.Controls.DragDropHandlers.DragDropHandler.GetDragDropHandler(this, n), FilterResult.Show));
    }
    internal TreeNode CreateTreeNode(OutlinerNode n, TreeNodeData tnData) 
    {
        TreeNode tn = new TreeNode(n.DisplayName);
        tn.ImageKey = this.GetImageKey(n);
        tn.Tag = tnData;
        tnData.TreeNode = tn;

        n.NameChanged += node_NameChanged;
        n.ParentChanged += node_ParentChanged;
        n.LayerChanged += node_LayerChanged;
        n.MaterialChanged += node_MaterialChanged;

        if (n is OutlinerObject)
        {
            ((OutlinerObject)n).ClassChanged += node_ClassChanged;
            ((OutlinerObject)n).SuperClassChanged += node_SuperClassChanged;
        }

        if (n is OutlinerLayer)
        {
            ((OutlinerLayer)n).IsActiveChanged += node_IsActiveChanged;
        }

        if (n is IDisplayable)
        {
            ((IDisplayable)n).HiddenChanged += node_HiddenChanged;
            ((IDisplayable)n).FrozenChanged += node_FrozenChanged;
            ((IDisplayable)n).BoxModeChanged += node_BoxModeChanged;
        }

        if (n is SelectionSet)
        {
            ((SelectionSet)n).NodeAdded += selSet_nodeAdded;
            ((SelectionSet)n).NodeRemoved += selSet_nodeRemoved;
        }

        return tn;
    }



    void _scene_UpdateEnd(object sender, EventArgs e) 
    {
        this.EndUpdate();
    }
    void _scene_UpdateBegin(object sender, EventArgs e) 
    {
        this.BeginUpdate();
    }

    void node_NameChanged(OutlinerNode sender, OutlinerNodeChangedEventArgs args) 
    {
        this.Mode.NodeNameChanged(this, sender);
    }
    void node_ParentChanged(OutlinerNode sender, NodeHandleChangedEventArgs args) 
    {
        this.Mode.NodeParentChanged(this, sender);
    }
    void node_LayerChanged(OutlinerNode sender, NodeHandleChangedEventArgs args) 
    {
        this.Mode.NodeLayerChanged(this, sender);

        if (this.NodeSorter is LayerSorter)
            this.AddToSortQueue(sender);
    }
    void node_MaterialChanged(OutlinerNode sender, NodeHandleChangedEventArgs args) 
    {
        this.Mode.NodeMaterialChanged(this, sender);

        if (this.NodeSorter is MaterialSorter)
            this.AddToSortQueue(sender);
    }
    void node_ClassChanged(OutlinerObject sender, EventArgs args) 
    {
        TreeNode tn = this.Mode.GetTreeNode(sender);
        if (tn == null)
            return;

        if (this.NodeSorter is TypeSorter)
            this.AddToSortQueue(tn);
    }
    void node_SuperClassChanged(OutlinerObject sender, EventArgs args) 
    {
        TreeNode tn = this.Mode.GetTreeNode(sender);
        if (tn == null)
            return;
    
        tn.ImageKey = this.GetImageKey(sender);

        if (this.NodeSorter is TypeSorter)
            this.AddToSortQueue(tn);
    }
    void node_IsActiveChanged(OutlinerLayer sender, EventArgs args) 
    {
        TreeNode tn = this.Mode.GetTreeNode(sender);
        if (tn == null)
            return;

        tn.ImageKey = this.GetImageKey(sender);
    }
    void node_HiddenChanged(IDisplayable sender, EventArgs args) 
    {
        this.Mode.NodeHiddenChanged(this, sender as OutlinerNode);

        if (this.NodeSorter is VisibilitySorter)
            this.AddToSortQueue(sender as OutlinerNode);
    }
    void node_FrozenChanged(IDisplayable sender, EventArgs args) 
    {
        this.Mode.NodeFrozenChanged(this, sender as OutlinerNode);
    }
    void node_BoxModeChanged(IDisplayable sender, EventArgs args) 
    {
        this.Mode.NodeBoxModeChanged(this, sender as OutlinerNode);
    }
    void selSet_nodeAdded(OutlinerNode sender, NodeAddedEventArgs args) 
    {
        if (sender is SelectionSet)
            this.Mode.SelectionSetNodeAdded(this, (SelectionSet)sender, args.AddedNode);
    }
    void selSet_nodeRemoved(OutlinerNode sender, NodeRemovedEventArgs args) 
    {
        if (sender is SelectionSet)
            this.Mode.SelectionSetNodeRemoved(this, (SelectionSet)sender, args.RemovedNode);
    }




    

    #region ContextMenu

    public event ToolStripItemClickedEventHandler ContextMenuItemClicked;
    protected virtual void showContextMenu(Point location) 
    {
        OutlinerContextMenu contextMenu = this.Mode.ShowContextMenu(this, location);
        if (contextMenu != null)
            contextMenu.ItemClicked += contextMenu_ItemClicked;
    }

    void contextMenu_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        if (this.ContextMenuItemClicked != null)
            this.ContextMenuItemClicked(this, e);
    }
    
    #endregion


    #region DragDrop

    // Use "Scroll" enum value as "None", so that DragDrop event is fired even when a droptarget is not valid.
    internal const DragDropEffects DragDropEffectsNone = DragDropEffects.Scroll;
    internal const DragDropEffects AllowedDragDropEffects = DragDropEffects.Copy | DragDropEffects.Link | DragDropEffects.Move;

    private TreeNode _dragDropTargetNode;
    private Color _dragDropTargetForeColor;
    private Color _dragDropTargetBackColor;
    private DateTime _dragOverStartTime;
    private TimeSpan _dragExpandDelay = TimeSpan.FromMilliseconds(750);
    private HashSet<TreeNode> _dragOverExpandedNodes;

    private void SetDragDropTargetColor(TreeNode tn) 
    {
        if (tn != _dragDropTargetNode)
        {
            // Restore previous dragdrop target node's colors.
            this.RestoreDragDropTargetColor();

            if (tn != null)
            {
                // Store new dragdrop target node and colors.
                _dragDropTargetNode = tn;
                _dragDropTargetForeColor = tn.ForeColor;
                _dragDropTargetBackColor = tn.BackColor;

                // Set link target colors.
                this.SetNodeColor(tn, NodeColor.LinkTarget);
            }
        }
    }
    private void RestoreDragDropTargetColor() 
    {
        if (_dragDropTargetNode != null)
            this.SetNodeColor(_dragDropTargetNode, _dragDropTargetForeColor, _dragDropTargetBackColor);

        _dragDropTargetNode = null;
    }
    private void RestoreDragDropExpandedStates()
    {
        if (_dragOverExpandedNodes == null || _dragOverExpandedNodes.Count == 0)
            return;

        this.BeginUpdate();
        _internalExpandCollapse = true;

        foreach (TreeNode tn in _dragOverExpandedNodes)
        {
            tn.Collapse();
        }
        _dragOverExpandedNodes.Clear();

        _internalExpandCollapse = false;
        this.EndUpdate();
    }

    protected override void OnItemDrag(ItemDragEventArgs e) 
    {
        Boolean canDragDrop = true;

        // If the button pressed isn't the preferred drag-drop button, don't start dragdrop.
        if ((e.Button & this.Settings.DragMouseButton) != this.Settings.DragMouseButton)
            canDragDrop = false;
        else
        {
            // Check if all nodes in the selection can be dragged.
            foreach (TreeNode tn in _selectedNodes)
            {
                TreeNodeData tnData = TreeNodeData.GetTreeNodeData(tn);
                if (tnData == null || tnData.DragDropHandler == null || !tnData.DragDropHandler.AllowDrag)
                {
                    canDragDrop = false;
                    break;
                }
            }
        }

        if (canDragDrop)
        {
            //Point mousePos = PointToClient(Control.MousePosition);
            //if (IsClickOnText((TreeNode)e.Item, new MouseEventArgs(e.Button, 1, mousePos.X, mousePos.Y, 0)))
            //{
                //OutlinerNode[] selOutlinerNodes = this.SelectedNodes.ToArray();
                List<TreeNodeData> dragData = new List<TreeNodeData>();
                foreach (TreeNode tn in _selectedNodes)
                {
                    if (tn.Tag is TreeNodeData)
                        dragData.Add((TreeNodeData)tn.Tag);
                }

                this.DoDragDrop(dragData, TreeView.AllowedDragDropEffects);
            //}
        }

        base.OnItemDrag(e);
    }
    protected override void OnDragOver(DragEventArgs drgevent) 
    {
        Point targetPoint = this.PointToClient(new Point(drgevent.X, drgevent.Y));
        TreeNode targetNode = this.GetNodeAt(targetPoint);
        DragDropHandler dragDropHandler = (targetNode != null) ? TreeNodeData.GetDragDropHandler(targetNode) : this.DragDropHandler;
        DragDropEffects dragDropEffect = (dragDropHandler != null) ? dragDropHandler.GetDragDropEffect(drgevent.Data) : TreeView.DragDropEffectsNone;
        
        drgevent.Effect = dragDropEffect;

        if (targetNode != null && !targetNode.Equals(_dragDropTargetNode))
            _dragOverStartTime = DateTime.Now;

        if ((dragDropEffect & TreeView.DragDropEffectsNone) == TreeView.DragDropEffectsNone)
            this.RestoreDragDropTargetColor();
        else
            this.SetDragDropTargetColor(targetNode);


        // Auto expand
        if (_dragDropTargetNode != null && !_dragDropTargetNode.IsExpanded && _dragDropTargetNode.Nodes.Count > 0)
        {
            if (DateTime.Now - _dragOverStartTime > _dragExpandDelay)
            {
                _internalExpandCollapse = true;
                _dragDropTargetNode.Expand();
                _internalExpandCollapse = false;

                if (_dragOverExpandedNodes == null)
                    _dragOverExpandedNodes = new HashSet<TreeNode>();
                _dragOverExpandedNodes.Add(_dragDropTargetNode);
            }
        }
        
        base.OnDragOver(drgevent);
    }
    protected override void OnDragLeave(EventArgs e) 
    {
        this.RestoreDragDropTargetColor();
        this.RestoreDragDropExpandedStates();
        base.OnDragLeave(e);
    }
    protected override void OnDragDrop(DragEventArgs drgevent) 
    {
        this.RestoreDragDropTargetColor();
        this.RestoreDragDropExpandedStates();

        Point targetPoint = this.PointToClient(new Point(drgevent.X, drgevent.Y));
        TreeNode targetNode = this.GetNodeAt(targetPoint);
        DragDropHandler dragDropHandler = TreeNodeData.GetDragDropHandler(targetNode);

        if (dragDropHandler != null)
            dragDropHandler.HandleDrop(drgevent.Data);

        base.OnDragDrop(drgevent);
    }

    #endregion


    public void Clear() 
    {
        this.Nodes.Clear();
        this.Mode.Clear();
        _selectedNodes.Clear();
        _expandedNodes.Clear();
        _lastSelectedTreeNode = null;
        _dragDropTargetNode = null;
    }
    public void FillTree(OutlinerScene scene)  
    {
        this.Scene = scene;
        this.Mode.FillTree(this, scene);
    }
    public void AddNodeToTree(OutlinerNode n) 
    {
        this.Mode.AddNodeToTree(this, n);
    }
    public void SetSelection(Int32[] selHandles) 
    {
        this.Mode.SetSelection(this, selHandles);
    }
    public void SetSelection(List<OutlinerNode> selNodes)
    {
        this.Mode.SetSelection(this, selNodes);
    }





    internal void SetNodeColor(TreeNode tn, NodeColor color)
    {
        OutlinerNode n = TreeNodeData.GetOutlinerNode(tn);

        switch (color)
        {
            case NodeColor.Default:
                tn.ForeColor = this.GetNodeForeColor(n);
                tn.BackColor = this.GetNodeBackColor(n);
                break;
            case NodeColor.Selected:
                tn.ForeColor = this.Colors.SelectionForeColor;
                tn.BackColor = this.Colors.SelectionBackColor;
                break;
            case NodeColor.ParentOfSelected:
                if (n is OutlinerObject)
                {
                    tn.ForeColor = this.Colors.ParentForeColor;
                    tn.BackColor = this.Colors.ParentBackColor;
                }
                else if (n is OutlinerLayer || n is OutlinerMaterial || n is SelectionSet)
                {
                    tn.ForeColor = this.Colors.LayerForeColor;
                    tn.BackColor = this.Colors.LayerBackColor;
                }
                else
                {
                    tn.ForeColor = this.GetNodeForeColor(n);
                    tn.BackColor = this.GetNodeBackColor(n);
                }
                break;
            case NodeColor.LinkTarget:
                tn.ForeColor = this.Colors.LinkForeColor;
                tn.BackColor = this.Colors.LinkBackColor;
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
        if (this.IsSelectedNode(tn))
            nodeColor = NodeColor.Selected;
        else if (this.IsParentOfSelectedNode(tn, true))
            nodeColor = NodeColor.ParentOfSelected;
        else
            nodeColor = NodeColor.Default;

        SetNodeColor(tn, nodeColor);
    }

    private Color GetNodeForeColor(OutlinerNode node)
    {
        if (node is IDisplayable && ((IDisplayable)node).IsHidden)
            return this.Colors.HiddenForeColor;
        else if (node is IDisplayable && ((IDisplayable)node).IsFrozen)
            return this.Colors.FrozenForeColor;
        else if (node is OutlinerObject && ((OutlinerObject)node).Class == MaxTypes.XrefObject)
            return this.Colors.XrefForeColor;
        else
            return this.Colors.NodeForeColor;
    }
    private Color GetNodeBackColor(OutlinerNode node)
    {
        if (node is IDisplayable && ((IDisplayable)node).IsHidden)
            return this.Colors.HiddenBackColor;
        else if (node is IDisplayable && ((IDisplayable)node).IsFrozen)
            return this.Colors.FrozenBackColor;
        else if (node is OutlinerObject && ((OutlinerObject)node).Class == MaxTypes.XrefObject)
            return this.Colors.XrefBackColor;
        else
            return this.Colors.NodeBackColor;
    }

    internal String GetImageKey(OutlinerNode node)
    {
        String imgKey = "unknown";

        if (node is OutlinerObject)
            imgKey = GetObjectImageKey((OutlinerObject)node);
        else if (node is OutlinerLayer)
            imgKey = GetLayerImageKey((OutlinerLayer)node);
        else if (node is OutlinerMaterial)
            imgKey = GetMaterialImageKey((OutlinerMaterial)node);
        else if (node is SelectionSet)
            imgKey = "selectionset";

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
        else if (mat.Type == MaxTypes.XrefMaterial)
            return "material_xref";
        else
            return "material";
    }
    private String GetObjectImageKey(OutlinerObject obj)
    {
        if (obj.Class == MaxTypes.XrefObject)
            return (obj.IsGroupHead) ? "xref_group" : "xref";
        else if (obj.IsGroupHead)
            return "group";
        else if (obj.SuperClass == MaxTypes.Geometry)
        {
            if (obj.Class == MaxTypes.Target)
                return "helper";
            else if (obj.Class == MaxTypes.Bone || obj.Class == MaxTypes.Biped)
                return "bone";
            else if (obj.Class == MaxTypes.PfSource || obj.Class == MaxTypes.PCloud || obj.Class == MaxTypes.PArray || obj.Class == MaxTypes.PBlizzard ||
                     obj.Class == MaxTypes.PSpray || obj.Class == MaxTypes.PSuperSpray || obj.Class == MaxTypes.PSnow)
                return "particle";
            // Assumption: Only PowerNurbs classes start with "Pwr_"
            else if (obj.Class == MaxTypes.NurbsCvSurf || obj.Class == MaxTypes.NurbsPtSurf || obj.Class.StartsWith(MaxTypes.PowerNurbsPrefix))
                return "nurbs";
            else if (obj.Class == MaxTypes.PatchQuad || obj.Class == MaxTypes.PatchTri || obj.Class == MaxTypes.PatchEditable)
                return "nurbs";
            else
                return "geometry";
        }
        else if (obj.SuperClass == MaxTypes.Spacewarp)
            return "spacewarp";
        else if (obj.SuperClass == MaxTypes.Helper)
            if (obj.Class == MaxTypes.Container)
                return (obj.ChildNodesCount > 0) ? "container" : "container_closed";
            else if (obj.Class == MaxTypes.PBirthTexture || obj.Class == MaxTypes.PSpeedByIcon ||
                     obj.Class == MaxTypes.PGroupSelection || obj.Class == MaxTypes.PFindTarget ||
                     obj.Class == MaxTypes.PInitialState || obj.Class == MaxTypes.ParticlePaint)
                return "particle";
            else
                return "helper";
        else
            // shape, light, camera
            return obj.SuperClass;
    }
}
}