using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Controls
{
    internal enum NodeColor
    {
        Default = 0x01,
        Selected = 0x02,
        ParentOfSelected = 0x04,
        LinkTarget = 0x8
    }
}
