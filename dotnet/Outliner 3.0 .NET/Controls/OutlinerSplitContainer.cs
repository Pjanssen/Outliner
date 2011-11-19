using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Outliner.Controls
{
    public class OutlinerSplitContainer : SplitContainer
    {
        public event SplitPanelEventHandler PanelCollapsedChanged;

        public void ToSinglePanel(SplitterPanel panelToMaximize)
        {
            if (panelToMaximize == this.Panel1)
            {
                this.Panel2Collapsed = true;
                this.OnPanelCollapsedChanged(new SplitPanelEventArgs(this.Panel2, true));
            }
            else if (panelToMaximize == this.Panel2)
            {
                this.Panel1Collapsed = true;
                this.OnPanelCollapsedChanged(new SplitPanelEventArgs(this.Panel1, true));
            }
        }

        public void ToSplitPanels()
        {
            if (this.Panel1Collapsed)
            {
                this.Panel1Collapsed = false;
                this.OnPanelCollapsedChanged(new SplitPanelEventArgs(this.Panel1, false));
            }
            else if (this.Panel2Collapsed)
            {
                this.Panel2Collapsed = false;
                this.OnPanelCollapsedChanged(new SplitPanelEventArgs(this.Panel2, false));
            }
        }

        protected void OnPanelCollapsedChanged(SplitPanelEventArgs e)
        {
            if (this.PanelCollapsedChanged != null)
                this.PanelCollapsedChanged(this, e);
        }
    }

    public delegate void SplitPanelEventHandler(object sender, SplitPanelEventArgs args);

    public class SplitPanelEventArgs : EventArgs
    {
        public SplitterPanel Panel { get; private set; }
        public Boolean IsCollapsed { get; private set; }

        public SplitPanelEventArgs(SplitterPanel panel, Boolean isCollapsed)
        {
            this.Panel = panel;
            this.IsCollapsed = isCollapsed;
        }
    }
}
