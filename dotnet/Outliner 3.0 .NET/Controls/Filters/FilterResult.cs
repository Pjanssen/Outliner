using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Controls.Filters
{
    [Flags]
    public enum FilterResult : byte
    {
        Show = 0x01,
        ShowChildren = 0x02,
        Hide = 0x04
    }
}
