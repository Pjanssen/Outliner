using System;

namespace Outliner.Scene
{
public interface IDisplayable
{
    Boolean IsHidden { get; set; }
    Boolean IsFrozen { get; set; }
    Boolean BoxMode { get; set; }

    event IDisplayableChangedEventHandler HiddenChanged;
    event IDisplayableChangedEventHandler FrozenChanged;
    event IDisplayableChangedEventHandler BoxModeChanged;
}
}
