using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
public class SelectionSet : OutlinerNode
{
    private List<OutlinerNode> nodes;

    public SelectionSet(String name, List<OutlinerNode> nodes)
        : base(OutlinerScene.SelectionSetHandle, OutlinerScene.SelectionSetHandle, name)
    {
        this.nodes = nodes;
    }

    internal override bool IndexByParent { get { return false; } }
    public override bool IsRootNode { get { return true; } }

    public override OutlinerNode Parent 
    {
        get { return null; }
        set { }
    }
    public override OutlinerNode Layer 
    {
        get { return null; }
        set { }
    }
    public override OutlinerNode Material 
    {
        get { return null; }
        set { }
    }


    public override int ChildNodesCount { get { return this.nodes.Count; } }
    public override List<OutlinerNode> ChildNodes { get { return this.nodes; } }

    public override bool CanAddNode(OutlinerNode n)
    {
        if (n is OutlinerObject)
            return !this.nodes.Contains(n);

        return false;
    }
    public void AddNode(OutlinerNode n)
    {
        if (this.CanAddNode(n))
        {
            this.nodes.Add(n);
            this.OnNodeAdded(new NodeAddedEventArgs(this.NodeChangeSource, n));
        }
    }
    public void RemoveNode(OutlinerNode n)
    {
        if (this.nodes.Remove(n))
            this.OnNodeRemoved(new NodeRemovedEventArgs(this.NodeChangeSource, n));
    }

    public event NodeAddedEventHandler NodeAdded;
    protected void OnNodeAdded(NodeAddedEventArgs e)
    {
        if (this.NodeAdded != null)
            this.NodeAdded(this, e);
    }
    public event NodeRemovedEventHandler NodeRemoved;
    protected void OnNodeRemoved(NodeRemovedEventArgs e)
    {
        if (this.NodeRemoved != null)
            this.NodeRemoved(this, e);
    }


}
}
