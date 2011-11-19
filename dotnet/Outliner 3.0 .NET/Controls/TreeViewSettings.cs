using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Outliner.Controls
{
    public class TreeViewSettings
    {
        public MouseButtons DragMouseButton { get; set; }
        public DoubleClickAction DoubleClickAction { get; set; }
        public IconClickAction IconClickAction { get; set; }
        public Boolean InvertNodeHideButton { get; set; }
        public Boolean ShowNodeIcon { get; set; }
        public Boolean ShowNodeHideButton { get; set; }
        public Boolean ShowNodeFreezeButton { get; set; }
        public Boolean ShowNodeBoxModeButton { get; set; }
        public Boolean ShowNodeAddToLayerButton { get; set; }

        public TreeViewSettings()
        {
            this.DragMouseButton = MouseButtons.Middle;
            this.DoubleClickAction = DoubleClickAction.Rename;
            this.IconClickAction = IconClickAction.SetLayerActive;
            this.InvertNodeHideButton = false;
            this.ShowNodeHideButton = true;
            this.ShowNodeFreezeButton = true;
            this.ShowNodeBoxModeButton = false;
            this.ShowNodeAddToLayerButton = true;
            this.ShowNodeIcon = true;
        }
    }
}
