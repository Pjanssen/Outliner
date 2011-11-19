using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Scene
{
    public interface IDisplayable
    {
        Boolean IsHidden { get; set; }
        Boolean IsFrozen { get; set; }
        Boolean BoxMode { get; set; }
    }
}
