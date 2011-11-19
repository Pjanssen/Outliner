using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Outliner.Controls.DragDropHandlers
{
public class NullDragDropHandler : DragDropHandler
{
    public NullDragDropHandler() : base(null, null) { }

    public override bool AllowDrag { get { return false; } }

    public override bool IsValidDropTarget(System.Windows.Forms.IDataObject dragData)
    {
        return false;
    }

    public override System.Windows.Forms.DragDropEffects GetDragDropEffect(System.Windows.Forms.IDataObject dragData)
    {
        return TreeView.DragDropEffectsNone;
    }

    public override void HandleDrop(System.Windows.Forms.IDataObject dragData) { }   
}
}
