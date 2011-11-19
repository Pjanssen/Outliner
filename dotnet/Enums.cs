using System;

namespace Outliner
{
    [Flags]
    internal enum EnsureSelectionVisibleAction : int
    {
        None = 0x0,
        SelectionChanged = 0x1,
        HierarchyChanged = 0x2,
        LayerChanged = 0x4,
        MaterialChanged = 0x8
    }

    public enum OutlinerDragDropEffects
    {
        None = System.Windows.Forms.DragDropEffects.Scroll
    }


    public enum DoubleClickAction
    {
        Rename,
        Expand
    }


    public enum OutlinerListMode
    {
        Hierarchy,
        Layer,
        Material
    }


    public enum IconSet
    {
        Max,
        Maya_16x16,
        Maya_20x20
    }

    public enum ExpandPolicy
    {
        Never,
        WhenNecessary,
        Always
    }

    public enum NodeButtonsLocation
    {
        BeforeNode,
        AfterNode,
        AlignRight
    }

    public enum IconClickAction
    {
        Hide,
        Freeze,
        SetActive
    }
}