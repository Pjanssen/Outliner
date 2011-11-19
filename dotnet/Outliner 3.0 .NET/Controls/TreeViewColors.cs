using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace Outliner.Controls
{
    public class TreeViewColors
    {
        public Color BackColor { get; set; }
        public Color LineColor { get; set; }

        public Color NodeForeColor { get; set; }
        public Color NodeBackColor { get; set; }

        public Color FrozenForeColor { get; set; }
        public Color FrozenBackColor { get; set; }

        public Color HiddenForeColor { get; set; }
        public Color HiddenBackColor { get; set; }

        public Color XrefForeColor { get; set; }
        public Color XrefBackColor { get; set; }

        public Color SelectionForeColor { get; set; }
        public Color SelectionBackColor { get; set; }

        public Color LinkForeColor { get; set; }
        public Color LinkBackColor { get; set; }

        public Color ParentForeColor { get; set; }
        public Color ParentBackColor { get; set; }

        public Color LayerForeColor { get; set; }
        public Color LayerBackColor { get; set; }

        public TreeViewColors()
        {
            BackColor = SystemColors.Window;
            LineColor = SystemColors.ControlText;

            NodeForeColor = SystemColors.WindowText;
            NodeBackColor = SystemColors.Window;
            FrozenForeColor = SystemColors.GrayText;
            FrozenBackColor = SystemColors.Window;
            HiddenForeColor = SystemColors.GrayText;
            HiddenBackColor = SystemColors.Window;
            XrefForeColor = SystemColors.WindowText;
            XrefBackColor = SystemColors.Window;

            SelectionForeColor = SystemColors.HighlightText;
            SelectionBackColor = SystemColors.Highlight;

            LinkForeColor = SystemColors.WindowText;
            LinkBackColor = Color.FromArgb(255, 177, 177);

            ParentForeColor = SystemColors.WindowText;
            ParentBackColor = Color.FromArgb(177, 255, 177);

            LayerForeColor = SystemColors.WindowText;
            LayerBackColor = Color.FromArgb(177, 228, 255);
        }
    }
}
