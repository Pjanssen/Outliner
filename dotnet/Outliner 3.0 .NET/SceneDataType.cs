using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner
{
    [Flags]
    public enum SceneDataType : byte
    {
        Objects = 0x01,
        Layers = 0x02,
        Materials = 0x04,
        SelectionSets = 0x08
    }
}
