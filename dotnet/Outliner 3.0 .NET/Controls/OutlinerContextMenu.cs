using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner.Controls.Filters;
using Outliner.Controls.NodeSorters;
using Outliner.Scene;
using Outliner.Controls.TreeViewModes;

namespace Outliner.Controls
{
public partial class OutlinerContextMenu : Form
{
    private TreeView _tree;
    private List<ToolStripMenuItem> _listModeItems;
    private List<ToolStripMenuItem> _sortModeItems;
    private List<ToolStripMenuItem> _filterItems;

    public OutlinerContextMenu()
    {
        InitializeComponent();

        this.btn_hierarchyMode.Tag      = typeof(HierarchyMode);
        this.btn_layerMode.Tag          = typeof(LayerMode);
        this.btn_materialMode.Tag       = typeof(MaterialMode);
        this.btn_flatObjectListMode.Tag = typeof(FlatObjectListMode);
        this.btn_selectionSets.Tag      = typeof(SelectionSetMode);

        this.geometryToolStripMenuItem.Tag      = typeof(GeometryFilter);
        this.shapesToolStripMenuItem.Tag        = typeof(ShapeFilter);
        this.camerasToolStripMenuItem.Tag       = typeof(CameraFilter);
        this.lightsToolStripMenuItem.Tag        = typeof(LightFilter);
        this.helpersToolStripMenuItem.Tag       = typeof(HelperFilter);
        this.bonesToolStripMenuItem.Tag         = typeof(BoneFilter);
        this.particlesToolStripMenuItem.Tag     = typeof(ParticleFilter);
        this.xRefsToolStripMenuItem.Tag         = typeof(XRefFilter);
        this.hiddenObjectsToolStripMenuItem.Tag = typeof(HiddenFilter);
        this.frozenObjectsToolStripMenuItem.Tag = typeof(FrozenFilter);

        this.alphabeticalToolStripMenuItem.Tag  = typeof(AlphabeticalSorter);
        this.chronologicalToolStripMenuItem.Tag = typeof(ChronologicalSorter);
        this.layerToolStripMenuItem.Tag         = typeof(LayerSorter);
        this.materialToolStripMenuItem.Tag      = typeof(MaterialSorter);
        this.typeToolStripMenuItem.Tag          = typeof(TypeSorter);
        this.visibilityToolStripMenuItem.Tag    = typeof(VisibilitySorter);

        _listModeItems = new List<ToolStripMenuItem>() { this.btn_hierarchyMode, this.btn_layerMode, this.btn_materialMode };
        _sortModeItems = new List<ToolStripMenuItem>() { this.alphabeticalToolStripMenuItem, this.chronologicalToolStripMenuItem, 
                                                         this.layerToolStripMenuItem, this.materialToolStripMenuItem, 
                                                         this.typeToolStripMenuItem, this.visibilityToolStripMenuItem };
        _filterItems = new List<ToolStripMenuItem>() { this.geometryToolStripMenuItem, this.shapesToolStripMenuItem,
                                                       this.camerasToolStripMenuItem, this.lightsToolStripMenuItem,
                                                       this.helpersToolStripMenuItem, this.bonesToolStripMenuItem,
                                                       this.particlesToolStripMenuItem, this.xRefsToolStripMenuItem,
                                                       this.hiddenObjectsToolStripMenuItem, this.frozenObjectsToolStripMenuItem };
    }

    public void Show(TreeView tree, Point position) 
    {
        _tree = tree;
        this.SetButtonStates();

        List<List<Type>> customFilters = CustomFilters.LoadFilterAssemblies("C:/code/outliner/outliner 2.1 Maxscript/script/custom_filters/");
        
        foreach (List<Type> filterTypes in customFilters)
        {
            foreach (Type t in filterTypes)
            {
                this.btn_filter.DropDownItems.Add(new ToolStripSeparator());

                try
                {
                    CustomNodeFilter tempFilterInstance = Activator.CreateInstance(t) as CustomNodeFilter;
                    if (tempFilterInstance != null)
                    {
                        ToolStripItem tsItem = this.btn_filter.DropDownItems.Add(tempFilterInstance.Name, tempFilterInstance.Image);
                        tsItem.Tag = t;
                    }
                }
                catch (Exception e) { Console.WriteLine(e); }
            }
        }

        position.Y -= this.toolStrip1.Height + 15;
        this.Location = position;
        this.Width = this.toolStrip1.Width + 2;
        this.Height = this.toolStrip1.Height + 15 + this.toolStrip2.Height + 4;
        this.Show();
    }

    public event ToolStripItemClickedEventHandler ItemClicked;
    protected virtual void OnItemClicked(ToolStripItemClickedEventArgs e)
    {
        if (this.ItemClicked != null)
            this.ItemClicked(this, e);
    }

    protected override void OnLostFocus(EventArgs e) 
    {
        base.OnLostFocus(e);

        Console.WriteLine("lost focus");
        if (!this.text_filter.Focused)
            this.Close();
    }

    private void SetButtonStates()
    {
        if (_tree == null)
            return;

        if (_tree.Mode != null)
        {
            foreach (ToolStripItem tsItem in _listModeItems)
            {
                if (_tree.Mode.GetType().Equals(tsItem.Tag as Type))
                {
                    this.btn_listMode.Image = tsItem.Image;
                    break;
                }
            }
        }

        if (_tree.Filters != null)
        {
            this.btn_filter.Checked = _tree.Filters.Enabled;

            Boolean clearEnabled = false;
            foreach (ToolStripMenuItem tsItem in _filterItems)
            {
                if (_tree.Filters.Contains(tsItem.Tag as Type))
                {
                    tsItem.Checked = true;
                    clearEnabled = true;
                }
                else
                    tsItem.Checked = false;
            }

            this.btn_clearFilters.Enabled = clearEnabled;
        }

        if (_tree.NodeSorter != null)
        {
            foreach (ToolStripMenuItem tsItem in _sortModeItems)
            {
                if (_tree.NodeSorter.GetType().Equals(tsItem.Tag))
                {
                    this.btn_sortMode.Image = tsItem.Image;
                    break;
                }
            }
        }

        

        Boolean ungroupEnabled = false;
        Boolean unlinkEnabled = false;
        foreach (OutlinerNode n in _tree.SelectedNodes)
        {
            //Ungroup.
            if (n is OutlinerObject)
            {
                if (!this.btn_ungroup.Enabled && (((OutlinerObject)n).IsGroupHead || ((OutlinerObject)n).IsGroupMember))
                    ungroupEnabled = true;
            }

            //Unlink.
            if (!this.btn_unlink.Enabled && !n.IsRootNode)
                unlinkEnabled = true;
        }

        this.btn_ungroup.Enabled = ungroupEnabled;
        this.btn_unlink.Enabled = unlinkEnabled;
    }

    public void HideContextMenuSection() 
    {
        this.toolStrip2.Visible = false;
        this.Height = this.toolStrip1.Height + 2;
    }
    public void HideObjectItems() { }
    public void HideLayerItems() 
    {
        this.btn_layerActive.Visible = false;
        this.btn_layerNew.Visible = false;
        this.btn_layerProperties.Visible = false;

        this.toolStrip2.PerformLayout();
    }
    public void HideMaterialItems() { }

    private void btn_listMode_DropDownItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        if (e.ClickedItem == null || !(e.ClickedItem.Tag is Type))
            return;

        Type modeType = e.ClickedItem.Tag as Type;
        if (modeType.IsSubclassOf(typeof(TreeViewMode)))
        {
            TreeViewMode treeViewMode = Activator.CreateInstance(modeType) as TreeViewMode;
            if (treeViewMode != null)
                _tree.Mode = treeViewMode;
        }
    }
    private void btn_filter_ButtonClick(object sender, EventArgs e) 
    {
        if (_tree != null && _tree.Filters != null)
            _tree.Filters.Enabled = !btn_filter.Checked;
    }
    private void btn_filter_DropDownItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        if (e.ClickedItem == null || !(e.ClickedItem is ToolStripMenuItem) || _tree == null || _tree.Filters == null)
            return;

        ToolStripMenuItem clickedItem = e.ClickedItem as ToolStripMenuItem;

        if (clickedItem == this.btn_clearFilters)
        {
            _tree.Filters.Clear();
            this.SetButtonStates();
        }
        else
        {
            if (!(e.ClickedItem.Tag is Type))
                return;

            Type filterType = clickedItem.Tag as Type;
            if (filterType.IsSubclassOf(typeof(NodeFilter)))
            {
                if (_tree.Filters.Contains(filterType))
                {
                    _tree.Filters.Remove(filterType);
                    clickedItem.Checked = false;
                }
                else
                {
                    NodeFilter nodeFilter = Activator.CreateInstance(filterType) as NodeFilter;
                    if (nodeFilter != null)
                    {
                        _tree.Filters.Add(nodeFilter);
                        clickedItem.Checked = true;
                    }
                }
            }
        }
    }
    private void btn_sortMode_DropDownItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        if (e.ClickedItem == null || !(e.ClickedItem.Tag is Type))
            return;

        Type sorterType = e.ClickedItem.Tag as Type;
        if (typeof(IComparer<TreeNode>).IsAssignableFrom(sorterType))
        {
            IComparer<TreeNode> nodeSorter = Activator.CreateInstance(sorterType, _tree) as IComparer<TreeNode>;
            if (nodeSorter != null)
                _tree.NodeSorter = nodeSorter;
        }
    }
    private void btn_view_DropDownItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        this.OnItemClicked(e);
        this.HideContextMenuSection();
    }

    void text_filter_TextChanged(object sender, EventArgs e)
    {
        Boolean isEmpty = this.text_filter.TextLength == 0;
        this.btn_clearNameFilter.Enabled = !isEmpty;

        if (isEmpty)
            _tree.Filters.Remove(typeof(NameFilter));
        else
        {
            NameFilter f = _tree.Filters.Get(typeof(NameFilter)) as NameFilter;
            if (f == null)
            {
                f = new NameFilter();
                f.CaseSensitive = this.btn_matchCase.Checked;
                _tree.Filters.Add(f, true);
            }
            f.SearchString = this.text_filter.Text;
        }
    }
    void btn_clearFilter_Click(object sender, EventArgs e)
    {
        this.text_filter.Clear();
        this.text_filter.Focus();
    }
    void btn_matchCase_Click(object sender, EventArgs e)
    {
        this.btn_matchCase.Checked = !this.btn_matchCase.Checked;
        NameFilter f = _tree.Filters.Get(typeof(NameFilter)) as NameFilter;
        if (f != null)
        {
            f.CaseSensitive = this.btn_matchCase.Checked;
        }
    }

    

    

    private void toolStrip1_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        this.HideContextMenuSection();
    }

    private void text_filter_Enter(object sender, EventArgs e)
    {
        this.HideContextMenuSection();
    }

    private void toolStrip2_ItemClicked(object sender, ToolStripItemClickedEventArgs e)
    {
        this.OnItemClicked(e);
        this.Close();
    }
}




    internal class CheckedToolStripSplitButton : ToolStripSplitButton 
    {
        private Boolean _checked = false;
        public Boolean Checked 
        {
            get { return _checked; }
            set
            {
                _checked = value;
                this.Invalidate();
            }
        }
        public override Image Image
        {
            get
            {
                if (this.Checked)
                    return this.ImageChecked;
                else
                    return this.ImageUnchecked;
            }
            set { base.Image = value; }
        }
        public Image ImageUnchecked { get; set; }
        public Image ImageChecked { get; set; }

        protected override void OnButtonClick(EventArgs e)
        {
            this.Checked = !this.Checked;

            base.OnButtonClick(e);
        } 
    }

    internal class CustomToolStripDropDownButton : ToolStripDropDownButton
    {
        
        
        protected override void OnDropDownItemClicked(ToolStripItemClickedEventArgs e)
        {
            if (e.ClickedItem != null && e.ClickedItem.Image != null)
            {
                this.Image = e.ClickedItem.Image;
            }

            base.OnDropDownItemClicked(e);
        }
    }

    internal class ToolStripAutoDropDownButton : ToolStripDropDownButton
    {
        protected override void OnMouseEnter(EventArgs e)
        {
            this.ShowDropDown();
            base.OnMouseEnter(e);
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);
            if (this.HasDropDownItems)
                e.Graphics.FillPolygon(SystemBrushes.ControlText, new Point[3] { new Point(this.Width - 8, 4), new Point(this.Width - 4, 8), new Point(this.Width - 8, 12) });
        }
    }

    internal class CustomToolStrip : ToolStrip
    {
        public CustomToolStrip()
        {
            this.Renderer = new CustomToolStripRenderer();
        }

        public Boolean ShowImageMargin { get; set; }

        protected override void OnPaintBackground(PaintEventArgs e)
        {
            base.OnPaintBackground(e);

            if (this.ShowImageMargin)
            {
                this.Renderer.DrawImageMargin(new ToolStripRenderEventArgs(e.Graphics, this, new Rectangle(0,-1, 24, this.Height + 2), SystemColors.ControlDark));
            }
        }
    }

    internal class CustomToolStripRenderer : ToolStripProfessionalRenderer
    {
        public CustomToolStripRenderer()
        {
            this.RoundedEdges = false;
        }

        protected override void OnRenderItemText(ToolStripItemTextRenderEventArgs e) 
        {
            ToolStrip toolStrip = e.ToolStrip;
            if (toolStrip is CustomToolStrip)
            {
                if (((CustomToolStrip)toolStrip).ShowImageMargin)
                    e.TextRectangle = new Rectangle(e.TextRectangle.X + 10, e.TextRectangle.Y, e.TextRectangle.Width, e.TextRectangle.Height);
                if (e.Item.Image == null)
                    e.TextRectangle = new Rectangle(e.TextRectangle.X + 16, e.TextRectangle.Y, e.TextRectangle.Width, e.TextRectangle.Height);
            }
            
            base.OnRenderItemText(e);
        }
        protected override void OnRenderToolStripBorder(ToolStripRenderEventArgs e) 
        {
            Rectangle borderBounds = e.AffectedBounds;
            borderBounds.Width -= 1;
            borderBounds.Height -= 1;
            e.Graphics.DrawRectangle(SystemPens.ControlDarkDark, borderBounds);
        }
    }
}
