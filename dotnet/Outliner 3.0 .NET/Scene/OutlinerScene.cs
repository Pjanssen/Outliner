using System;
using System.Collections.Generic;
using System.Linq;

namespace Outliner.Scene
{
public class OutlinerScene
{
    public const Int32 ObjectRootHandle = -1;
    public const Int32 LayerRootHandle = -2;
    public const Int32 MaterialRootHandle = -3;
    public const Int32 MaterialUnassignedHandle = -4;
    public const Int32 SelectionSetHandle = -5;

    protected Dictionary<Int32, OutlinerNode> _nodes;
    protected Dictionary<Int32, List<OutlinerNode>> _nodes_by_parentHandle; //used to store nodes by parent-, layer- and materialHandle.
    protected List<SelectionSet> _selectionSets;

    public OutlinerScene() 
    {
        _nodes = new Dictionary<Int32, OutlinerNode>();
        _nodes_by_parentHandle = new Dictionary<Int32, List<OutlinerNode>>();
        _selectionSets = new List<SelectionSet>();

        this.addUnassignedMaterial();
    }

    public void Clear() 
    {
        _nodes.Clear();
        _nodes_by_parentHandle.Clear();
        _selectionSets.Clear();

        this.addUnassignedMaterial();
    }

    private void addUnassignedMaterial() 
    {
        this.AddNode(new OutlinerMaterial(OutlinerScene.MaterialUnassignedHandle, OutlinerScene.MaterialRootHandle, "", ""));
    }

    public void AddNode(OutlinerNode n) 
    {
        if (n == null)
            return;

        if (_nodes.ContainsKey(n.Handle))
            return;

        n.Scene = this;
        _nodes.Add(n.Handle, n);

        if (n.IndexByParent)
        {
            AddNodeToParentList(n.ParentHandle, n);
            n.ParentChanged += node_ParentHandleChanged;
        }
        if (n.IndexByLayer)
        {
            AddNodeToParentList(n.LayerHandle, n);
            n.LayerChanged += node_ParentHandleChanged;
        }
        if (n.IndexByMaterial)
        {
            AddNodeToParentList(n.MaterialHandle, n);
            n.MaterialChanged += node_ParentHandleChanged;
        }
    }
    public void RemoveNode(OutlinerNode n) 
    {
        if (n == null)
            return;

        _nodes.Remove(n.Handle);

        if (n.IndexByParent)
        {
            RemoveNodeFromParentList(n.ParentHandle, n);
            n.ParentChanged -= node_ParentHandleChanged;
        }
        if (n.IndexByLayer)
        {
            RemoveNodeFromParentList(n.LayerHandle, n);
            n.LayerChanged -= node_ParentHandleChanged;
        }
        if (n.IndexByMaterial)
        {
            RemoveNodeFromParentList(n.MaterialHandle, n);
            n.MaterialChanged -= node_ParentHandleChanged;
        }

        n.Scene = null;
    }
    private void AddNodeToParentList(Int32 parentHandle, OutlinerNode n) 
    {
        List<OutlinerNode> parentNodeList;
        if (_nodes_by_parentHandle.TryGetValue(parentHandle, out parentNodeList))
            parentNodeList.Add(n);
        else
        {
            parentNodeList = new List<OutlinerNode>();
            parentNodeList.Add(n);
            _nodes_by_parentHandle.Add(parentHandle, parentNodeList);
        }
    }
    private void RemoveNodeFromParentList(Int32 parentHandle, OutlinerNode n) 
    {
        List<OutlinerNode> parentNodes;
        if (_nodes_by_parentHandle.TryGetValue(parentHandle, out parentNodes))
            parentNodes.Remove(n);
    }
    private void node_ParentHandleChanged(OutlinerNode sender, NodeHandleChangedEventArgs args) 
    {
        if (args.OldHandle == args.NewHandle)
            return;

        RemoveNodeFromParentList(args.OldHandle, sender);
        AddNodeToParentList(args.NewHandle, sender);
    }

    public OutlinerNode GetNodeByHandle(Int32 handle) 
    {
        OutlinerNode n;
        _nodes.TryGetValue(handle, out n);
        return n;
    }
    public List<OutlinerNode> GetChildNodes(Int32 parentHandle) 
    {
        List<OutlinerNode> nodes;
        if (_nodes_by_parentHandle.TryGetValue(parentHandle, out nodes))
            return nodes;
        else
            return new List<OutlinerNode>(0);
    }
    public Int32 GetChildNodesCount(Int32 parentHandle) 
    {
        if (!_nodes_by_parentHandle.ContainsKey(parentHandle))
            return 0;
        else
            return this.GetChildNodes(parentHandle).Count;
    }

    public List<OutlinerNode> Nodes { get { return _nodes.Values.ToList(); } }
    public List<OutlinerNode> RootNodes { get { return GetChildNodes(OutlinerScene.ObjectRootHandle); } }
    public List<OutlinerNode> RootLayers { get { return GetChildNodes(OutlinerScene.LayerRootHandle); } }
    public List<OutlinerNode> RootMaterials { get { return GetChildNodes(OutlinerScene.MaterialRootHandle); } }

    private OutlinerLayer _activeLayer;
    public OutlinerLayer ActiveLayer 
    {
        get { return _activeLayer; }
        set
        {
            if (_activeLayer != null && value != _activeLayer)
                _activeLayer.IsActive = false;

            _activeLayer = value;
        }
    }

    public Boolean IsValidLayerName(String newName) 
    {
        return IsValidLayerName(newName, null);
    }
    public Boolean IsValidLayerName(String newName, OutlinerLayer editingLayer) 
    {
        if (newName == null || newName == String.Empty)
            return false;
        
        foreach(OutlinerNode n in _nodes.Values)
        {
            if (n is OutlinerLayer && n != editingLayer)
                if (String.Compare(n.Name, newName, true) == 0)
                    return false;
        }

        return true;
    }
    public Boolean IsValidMaterialName(String newName) 
    {
        return this.IsValidMaterialName(newName, null);
    }
    public Boolean IsValidMaterialName(String newName, OutlinerMaterial editingMaterial) 
    {
        if (newName == null || newName == String.Empty)
            return false;

        foreach (OutlinerNode n in _nodes.Values)
        {
            if (n is OutlinerMaterial && n != editingMaterial)
                if (String.Compare(n.Name, newName, true) == 0)
                    return false;
        }

        return true;
    }

    public void AddSelectionSet(SelectionSet s) 
    {
        if (!_selectionSets.Contains(s))
            this._selectionSets.Add(s);
        s.Scene = this;
    }
    public List<SelectionSet> SelectionSets { get { return this._selectionSets; } }


    public void BeginUpdate() 
    {
        this.OnUpdateBegin(new EventArgs());
    }
    public void EndUpdate() 
    {
        this.OnUpdateEnd(new EventArgs());
    }

    public event EventHandler UpdateBegin;
    protected virtual void OnUpdateBegin(EventArgs args)
    {
        if (this.UpdateBegin != null)
            this.UpdateBegin(this, args);
    }
    public event EventHandler UpdateEnd;
    protected virtual void OnUpdateEnd(EventArgs args)
    {
        if (this.UpdateEnd != null)
            this.UpdateEnd(this, args);
    }
}
}
