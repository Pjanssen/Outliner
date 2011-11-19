using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;
using Outliner.Controls;
using Outliner.Controls.TreeViewModes;
using Outliner.Controls.NodeSorters;

namespace Outliner
{
public class OutlinerTreeController
{
    private OutlinerScene _scene { get; set; }
    private List<TreeView> _treeViews { get; set; }
    private Boolean _pushingScene = false;

    public OutlinerTreeController() 
    {
        _scene = new OutlinerScene();
        _treeViews = new List<TreeView>();
    }


    public void RegisterTreeView(TreeView tree) 
    {
        if (tree == null)
            return;

        if (!_treeViews.Contains(tree))
        {
            _treeViews.Add(tree);

            tree.ContextMenuItemClicked += ContextMenu_ItemClicked;
            tree.SelectionChanged += new SelectionChangedEventHandler(tree_SelectionChanged);
        }
    }
    public void UnRegisterTreeView(TreeView tree) 
    {
        if (tree == null)
            return;

        if (_treeViews.Contains(tree))
        {
            _treeViews.Remove(tree);

            tree.ContextMenuItemClicked -= ContextMenu_ItemClicked;
            tree.SelectionChanged -= new SelectionChangedEventHandler(tree_SelectionChanged);
        }
    }
    public void RegisterContainer(MainContainer container) 
    {
        if (container == null)
            return;

        if (container.Tree_Top != null)
            this.RegisterTreeView(container.Tree_Top);
        if (container.Tree_Bottom != null)
            this.RegisterTreeView(container.Tree_Bottom);

        container.TreeSplitContainer.PanelCollapsedChanged += TreeSplitContainer_PanelCollapsed;
    }
    public void UnRegisterContainer(MainContainer container) 
    {
        if (container == null)
            return;

        if (container.Tree_Top != null)
            this.UnRegisterTreeView(container.Tree_Top);
        if (container.Tree_Bottom != null)
            this.UnRegisterTreeView(container.Tree_Bottom);

        container.TreeSplitContainer.PanelCollapsedChanged -= TreeSplitContainer_PanelCollapsed;
    }

    void TreeSplitContainer_PanelCollapsed(Object sender, SplitPanelEventArgs e)
    {
        if (e.Panel == null || e.Panel.Controls.Count == 0)
            return;

        TreeView tree = e.Panel.Controls[0] as TreeView;
        if (tree == null)
            return;

        if (e.IsCollapsed)
        {
            this.UnRegisterTreeView(tree);
            tree.Clear();
        }
        else
        {
            this.RegisterTreeView(tree);
            tree.FillTree(this._scene);
        }
    }
    void ContextMenu_ItemClicked(Object sender, System.Windows.Forms.ToolStripItemClickedEventArgs e)
    {
        OutlinerSplitContainer splitContainer = null;
        System.Windows.Forms.SplitterPanel panel = null;
        System.Windows.Forms.Control ctrl = sender as System.Windows.Forms.Control;
        while (ctrl != null && splitContainer == null)
        {
            if (ctrl is System.Windows.Forms.SplitterPanel)
                panel = ctrl as System.Windows.Forms.SplitterPanel;
            if (ctrl is OutlinerSplitContainer)
                splitContainer = ctrl as OutlinerSplitContainer;

            ctrl = ctrl.Parent;
        }

        if (splitContainer == null || panel == null)
            return;

        if (e.ClickedItem.Name == "btn_viewSingle")
            splitContainer.ToSinglePanel(panel);
        else if (e.ClickedItem.Name == "btn_viewSplitHor")
        {
            splitContainer.ToSplitPanels();
            splitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
        }
        else if (e.ClickedItem.Name == "btn_viewSplitVer")
        {
            splitContainer.ToSplitPanels();
            splitContainer.Orientation = System.Windows.Forms.Orientation.Vertical;
        }
    }

    public void SetTreeViewSettings(TreeViewSettings settings) 
    {
        foreach (TreeView tree in _treeViews)
        {
            tree.Settings = settings;
        }
    }
    public void SetTreeViewColors(TreeViewColors colors) 
    {
        foreach (TreeView tree in _treeViews)
        {
            tree.Colors = colors;
        }
    }


    public void BeginUpdate() 
    {
        foreach (TreeView tree in _treeViews)
            tree.BeginUpdate();
    }
    public void EndUpdate() 
    {
        foreach (TreeView tree in _treeViews)
            tree.EndUpdate();
    }
    public void BeginScenePush() 
    {
        _pushingScene = true;

        this.BeginUpdate();
        this.Clear();
    }
    public void EndScenePush() 
    {
        foreach (TreeView tree in _treeViews)
        {
            tree.FillTree(_scene);
        }

        this.EndUpdate();

        _pushingScene = false;
    }

    public void Clear() 
    {
        foreach (TreeView tree in _treeViews)
            tree.Clear();

        _scene.Clear();
    }
    public void Dispose() 
    {
        this.Clear();
        _scene = null;

        foreach (TreeView tree in _treeViews)
            tree.Dispose();

        _treeViews.Clear();
        _treeViews = null;
    }


    public Boolean RequiresData(SceneDataType data) 
    {
        return true; //TODO: remove temp true
        if ((data & SceneDataType.Objects) == SceneDataType.Objects || (data & SceneDataType.Layers) == SceneDataType.Layers)
            return true;

        if ((data & SceneDataType.Materials) == SceneDataType.Materials)
        {
            foreach (TreeView tree in _treeViews)
            {
                if ((tree.Mode is MaterialMode) || (tree.NodeSorter is MaterialSorter))
                    return true;
            }
        }

        if ((data & SceneDataType.SelectionSets) == SceneDataType.SelectionSets)
        {
            foreach (TreeView tree in _treeViews)
            {
                if (tree.Mode is SelectionSetMode)
                    return true;
            }
        }

        return false;
    }

    public void AddNode(OutlinerNode n) 
    {
        _scene.AddNode(n);
        n.ParentChanged += nodeParentChanged;

        if (!_pushingScene)
        {
            foreach (TreeView tree in _treeViews)
                tree.AddNodeToTree(n);
        }
    }
    public void DeleteNode(OutlinerNode n) 
    {
        if (n == null)
            return;

        n.ParentChanged -= nodeParentChanged;

        _scene.RemoveNode(n);
    }

    public void AddObject(Int32 handle, Int32 parentHandle, String name, Int32 layerHandle, Int32 materialHandle,
                          String objClass, String objSuperClass, Boolean isGroupHead, Boolean isGroupMember,
                          Boolean isHidden, Boolean isFrozen, Boolean boxMode) 
    {
        OutlinerObject o = new OutlinerObject(handle, parentHandle, name, layerHandle, materialHandle, objClass, objSuperClass, isGroupHead, isGroupMember, isHidden, isFrozen, boxMode);
        this.AddNode(o);
    }
    public void AddLayer(Int32 handle, Int32 parentHandle, String name, Boolean isActive, 
                          Boolean isHidden, Boolean isFrozen, Boolean boxMode) 
    {
        OutlinerLayer l = new OutlinerLayer(handle, parentHandle, name, isActive, isHidden, isFrozen, boxMode);
        this.AddNode(l);
    }
    public void AddMaterial(Int32 handle, Int32 parentHandle, String name, String type) 
    {
        OutlinerMaterial m = new OutlinerMaterial(handle, parentHandle, name, type);
        this.AddNode(m);
    }
    public void DeleteNode(Int32 handle) 
    {
        OutlinerNode n = _scene.GetNodeByHandle(handle);
        this.DeleteNode(n);
    }

    public void SetSelection(Int32[] selHandles)
    {
        foreach (TreeView tree in _treeViews)
        {
            tree.SetSelection(selHandles);
        }
    }
    public void AddSelectionSet(String name, Int32[] nodeHandles) 
    {
        List<OutlinerNode> nodes = new List<OutlinerNode>();
        foreach (Int32 handle in nodeHandles)
        {
            OutlinerNode n = _scene.GetNodeByHandle(handle);
            if (n != null)
                nodes.Add(n);
        }
        SelectionSet s = new SelectionSet(name, nodes);
        _scene.AddSelectionSet(s);
    }

    public void SetNodeName(Int32 handle, String name) 
    {
        OutlinerNode n = _scene.GetNodeByHandle(handle);
        if (n == null)
            return;

        n.NodeChangeSource = NodeChangeSource.Max;
        n.Name = name;
        n.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetNodeParent(Int32 handle, Int32 newParentHandle) 
    {
        OutlinerNode n = _scene.GetNodeByHandle(handle);
        if (n == null)
            return;

        n.NodeChangeSource = NodeChangeSource.Max;
        n.ParentHandle = newParentHandle;
        n.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetNodeLayer(Int32 handle, Int32 newLayerHandle) 
    {
        OutlinerNode n = _scene.GetNodeByHandle(handle);
        if (n == null)
            return;

        n.NodeChangeSource = NodeChangeSource.Max;
        n.LayerHandle = newLayerHandle;
        n.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetNodeMaterial(Int32 handle, Int32 newMaterialHandle) 
    {
        OutlinerNode n = _scene.GetNodeByHandle(handle);
        if (n == null)
            return;

        n.NodeChangeSource = NodeChangeSource.Max;
        n.MaterialHandle = newMaterialHandle;
        n.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetObjectClass(Int32 handle, String newClass, String newSuperClass) 
    {
        OutlinerObject o = _scene.GetNodeByHandle(handle) as OutlinerObject;
        if (o == null)
            return;

        o.NodeChangeSource = NodeChangeSource.Max;
        o.Class = newClass;
        o.SuperClass = newSuperClass;
        o.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetLayerActive(Int32 handle, Boolean isActive) 
    {
        OutlinerLayer l = _scene.GetNodeByHandle(handle) as OutlinerLayer;
        if (l == null)
            return;

        l.NodeChangeSource = NodeChangeSource.Max;
        l.IsActive = isActive;
        l.NodeChangeSource = NodeChangeSource.Outliner;
    }
    public void SetNodeHidden(Int32[] handles, Boolean isHidden) 
    {
        foreach (Int32 handle in handles)
        {
            OutlinerNode n = _scene.GetNodeByHandle(handle);
            if (n == null || !(n is IDisplayable))
                continue;

            n.NodeChangeSource = NodeChangeSource.Max;
            ((IDisplayable)n).IsHidden = isHidden;
            n.NodeChangeSource = NodeChangeSource.Outliner;
        }
    }
    public void SetNodeFrozen(Int32[] handles, Boolean isFrozen) 
    {
        foreach (Int32 handle in handles)
        {
            OutlinerNode n = _scene.GetNodeByHandle(handle);
            if (n == null || !(n is IDisplayable))
                continue;

            n.NodeChangeSource = NodeChangeSource.Max;
            ((IDisplayable)n).IsFrozen = isFrozen;
            n.NodeChangeSource = NodeChangeSource.Outliner;
        }
    }
    public void SetNodeBoxMode(Int32[] handles, Boolean boxMode) 
    {
        foreach (Int32 handle in handles)
        {
            OutlinerNode n = _scene.GetNodeByHandle(handle);
            if (n == null || !(n is IDisplayable))
                continue;

            n.NodeChangeSource = NodeChangeSource.Max;
            ((IDisplayable)n).BoxMode = boxMode;
            n.NodeChangeSource = NodeChangeSource.Outliner;
        }
    }


    public event SelectionChangedEventHandler SelectionChanged;
    void tree_SelectionChanged(Object sender, SelectionChangedEventArgs e) 
    {
        foreach (TreeView tree in _treeViews)
        {
            if (!tree.Equals(sender))
            {
                tree.SetSelection(e.SelectedNodes);
            }
        }

        if (this.SelectionChanged != null)
            this.SelectionChanged(sender, e);
    }

    /*
    protected System.Timers.Timer _eventTimer;
    protected void createTimer() 
    {
        _eventTimer = new System.Timers.Timer(40);
        _eventTimer.Elapsed += _eventTimer_Elapsed;
        _eventTimer.AutoReset = false;
    }
    void _eventTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
    {
        if (this.parentChangedEventArgs != null)
        {
            this.OnNodesParentChanged(this.parentChangedEventArgs);
            this.parentChangedEventArgs = null;
        }   
    }
    public event NodesHandleChangedEventHandler NodesParentChanged;
    protected void OnNodesParentChanged(NodesHandleChangedEventArgs args)
    {
        if (this.NodesParentChanged != null)
            this.NodesParentChanged(this, args);
    }
    protected NodesHandleChangedEventArgs parentChangedEventArgs;
    */
    public event NodesHandleChangedEventHandler NodeParentChanged;
    protected void OnNodeParentChanged(NodesHandleChangedEventArgs args)
    {
        if (this.NodeParentChanged != null)
            this.NodeParentChanged(this, args);
    }
    protected void nodeParentChanged(OutlinerNode sender, Outliner.Scene.NodeHandleChangedEventArgs args)
    {
        if (args.Source == NodeChangeSource.Max)
            return;

        this.OnNodeParentChanged(new NodesHandleChangedEventArgs(sender.Handle, args.NewHandle));

        /*
        if (parentChangedEventArgs != null && parentChangedEventArgs.TargetHandle != args.NewHandle)
            this._eventTimer_Elapsed(null, null);

        if (parentChangedEventArgs == null)
        {
            this.parentChangedEventArgs = new NodesHandleChangedEventArgs(args.NewHandle);
            if (_eventTimer == null)
                createTimer();
            _eventTimer.Start();
        }

        this.parentChangedEventArgs._nodeHandles.Add(sender.Handle);
         */
    }

}

public delegate void NodesHandleChangedEventHandler(OutlinerTreeController sender, NodesHandleChangedEventArgs args);
public class NodesHandleChangedEventArgs : EventArgs
{
    public Int32 NodeHandle { get; private set; }
    public Int32 TargetHandle { get; private set; }

    public NodesHandleChangedEventArgs(Int32 nodeHandle, Int32 targetHandle)
    {
        this.NodeHandle = nodeHandle;
        this.TargetHandle = targetHandle;
    }
}
}