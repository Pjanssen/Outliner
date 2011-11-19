using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;

namespace Outliner.Controls.Filters
{
    public abstract class NodeFilter
    {
        public event EventHandler FilterChanged;
        protected virtual void OnFilterChanged()
        {
            if (this.FilterChanged != null)
                this.FilterChanged(this, new EventArgs());
        }

        /// <summary>
        /// Returns whether the node should be shown or hidden. 
        /// Must return either FilterResult.Show or FilterResult.Hide, not FilterResult.ShowChildren.
        /// </summary>
        public abstract FilterResult ShowNode(OutlinerNode n);
    }
}
