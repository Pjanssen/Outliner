using System;
using System.Collections.Generic;
using Outliner.Scene;

namespace Outliner.Controls.Filters
{
public class NodeFilterCollection
{
    public NodeFilterCollection() : this(null) { }
    public NodeFilterCollection(NodeFilterCollection collection) 
    {
        if (collection == null)
        {
            this.Enabled = true;
            _filters = new List<NodeFilter>();
            _permanentFilters = new List<NodeFilter>();
        }
        else
        {
            this.Enabled = collection.Enabled;
            _filters = collection._filters;
            _permanentFilters = collection._permanentFilters;
        }
    }

    private List<NodeFilter> _filters;
    private List<NodeFilter> _permanentFilters;


    private Boolean _enabled;
    public Boolean Enabled 
    {
        get { return _enabled; }
        set
        {
            _enabled = value;
            this.OnFiltersEnabled();
        }
    }
    public Boolean HasPermanentFilters 
    {
        get
        {
            return _permanentFilters.Count > 0;
        }
    }
    
    public void Add(NodeFilter filter) 
    {
        this.Add(filter, false);
    }
    public void Add(NodeFilter filter, Boolean permanent) 
    {
        if (permanent)
        {
            if (!_permanentFilters.Contains(filter))
                _permanentFilters.Add(filter);
        }
        else
        {
            if (!_filters.Contains(filter))
                _filters.Add(filter);
        }

        filter.FilterChanged += filterChanged;

        this.OnFilterAdded(filter);
    }


    public NodeFilter Get(Type filterType) 
    {
        foreach (NodeFilter filter in _filters)
        {
            if (filter.GetType().Equals(filterType))
                return filter;
        }
        foreach (NodeFilter filter in _permanentFilters)
        {
            if (filter.GetType().Equals(filterType))
                return filter;
        }
        return null;
    }

    public void Remove(NodeFilter filter) 
    {
        if (_filters.Contains(filter))
            _filters.Remove(filter);

        if (_permanentFilters.Contains(filter))
            _permanentFilters.Remove(filter);

        filter.FilterChanged -= filterChanged;

        this.OnFilterRemoved(filter);
    }
    public void Remove(Type filterType) 
    {
        List<NodeFilter> filtersToRemove = new List<NodeFilter>();
        
        foreach (NodeFilter filter in _filters)
        {
            if (filter.GetType().Equals(filterType))
                filtersToRemove.Add(filter);
        }
        foreach (NodeFilter filter in _permanentFilters)
        {
            if (filter.GetType().Equals(filterType))
                filtersToRemove.Add(filter);
        }

        foreach (NodeFilter filter in filtersToRemove)
        {
            this.Remove(filter);
        }
        filtersToRemove.Clear();
    }
    
    public void Clear() 
    {
        this.Clear(false);
    }
    public void Clear(Boolean clearPermanentFilters) 
    {
        foreach (NodeFilter filter in _filters)
        {
            filter.FilterChanged -= filterChanged;
        }
        _filters.Clear();

        if (clearPermanentFilters)
        {
            foreach (NodeFilter filter in _permanentFilters)
            {
                filter.FilterChanged -= filterChanged;
            }
            _permanentFilters.Clear();
        }

        this.OnFiltersCleared();
    }
    
    public Boolean Contains(Type filterType) 
    {
        foreach (NodeFilter filter in _filters)
        {
            if (filter.GetType().Equals(filterType))
                return true;
        }
        foreach (NodeFilter filter in _permanentFilters)
        {
            if (filter.GetType().Equals(filterType))
                return true;
        }

        return false;
    }


    public virtual FilterResult ShowNode(OutlinerNode n) 
    {
        FilterResult filterResult = FilterResult.Show;

        // Loop through filters.
        if (this.Enabled && _filters.Count > 0)
        {
            foreach (NodeFilter filter in _filters)
            {
                if (filter.ShowNode(n) == FilterResult.Hide)
                {
                    filterResult = FilterResult.Hide;
                    break;
                }
            }
        }

        if (filterResult == FilterResult.Show && _permanentFilters.Count > 0)
        {
            foreach (NodeFilter filter in _permanentFilters)
            {
                if (filter.ShowNode(n) == FilterResult.Hide)
                {
                    filterResult = FilterResult.Hide;
                    break;
                }
            }
        }

        // If any of the filters return FilterResult.Hide, loop through children too.
        if (filterResult == FilterResult.Hide)
            return this.ShowChildNodes(n);
        else
            return filterResult;
    }
    protected virtual FilterResult ShowChildNodes(OutlinerNode n) 
    {
        if (n == null || n.ChildNodesCount == 0)
            return FilterResult.Hide;

        foreach (OutlinerNode child in n.ChildNodes)
        {
            if (this.ShowNode(child) == FilterResult.Show)
                return FilterResult.ShowChildren;
            else if (this.ShowChildNodes(child) == FilterResult.ShowChildren)
                return FilterResult.ShowChildren;
        }

        return FilterResult.Hide;
    }

    public virtual FilterResult ShowNode(System.Windows.Forms.TreeNode tn, TreeNodeData tnData, NodeFilter filter) 
    {
        if (tn == null || tnData == null || tnData.OutlinerNode == null || filter == null)
            return FilterResult.Hide;

        if ((filter.ShowNode(tnData.OutlinerNode) & FilterResult.Show) == FilterResult.Show)
            return FilterResult.Show;
        else
            return this.ShowChildNodes(tn, filter);
    }
    protected virtual FilterResult ShowChildNodes(System.Windows.Forms.TreeNode tn, NodeFilter filter) 
    {
        if (tn == null)
            return FilterResult.Hide;

        foreach (System.Windows.Forms.TreeNode childTn in tn.Nodes)
        {
            if ((this.ShowNode(childTn, (childTn.Tag as TreeNodeData), filter) & FilterResult.Show) == FilterResult.Show)
                return FilterResult.ShowChildren;
            else if ((this.ShowChildNodes(childTn, filter) & FilterResult.ShowChildren) == FilterResult.ShowChildren)
                return FilterResult.ShowChildren;
        }

        return FilterResult.Hide;
    }


    // Events.
    public event EventHandler FiltersEnabled;
    protected virtual void OnFiltersEnabled() 
    {
        if (this.FiltersEnabled != null)
            this.FiltersEnabled(this, new EventArgs());
    }
    
    public event EventHandler FiltersCleared;
    protected virtual void OnFiltersCleared() 
    {
        if (this.FiltersCleared != null)
            this.FiltersCleared(this, new EventArgs());
    }

    public event NodeFilterChangedEventHandler FilterAdded;
    protected virtual void OnFilterAdded(NodeFilter filter) 
    {
        if (this.FilterAdded != null)
            this.FilterAdded(this, new NodeFilterChangedEventArgs(filter));
    }

    public event NodeFilterChangedEventHandler FilterRemoved;
    protected virtual void OnFilterRemoved(NodeFilter filter) 
    {
        if (this.FilterRemoved != null)
            this.FilterRemoved(this, new NodeFilterChangedEventArgs(filter));
    }

    public event NodeFilterChangedEventHandler FilterChanged;
    protected void filterChanged(object sender, EventArgs e) 
    {
        if (this.FilterChanged != null)
            this.FilterChanged(this, new NodeFilterChangedEventArgs(sender as NodeFilter));
    }
}

    public delegate void NodeFilterChangedEventHandler(object sender, NodeFilterChangedEventArgs args);
    public class NodeFilterChangedEventArgs : EventArgs
    {
        public NodeFilter Filter { get; private set; }

        public NodeFilterChangedEventArgs(NodeFilter filter)
        {
            this.Filter = filter;
        }
    }
}
