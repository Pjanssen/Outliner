using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Outliner.Scene;

namespace Outliner.Controls
{
    public delegate void SelectionChangedEventHandler(object sender, SelectionChangedEventArgs e);
    public class SelectionChangedEventArgs : EventArgs
    {
        private Int32[] _selectedNodeHandles;
        private Int32[] _selectedObjectHandles;
        private Int32[] _selectedLayerHandles;
        private Int32[] _selectedMaterialHandles;

        private Int32[] getTypeHandles(Type t) 
        {
            List<Int32> handles = new List<Int32>();

            foreach (OutlinerNode n in this.SelectedNodes)
            {
                if (t == null || n.GetType().Equals(t))
                    handles.Add(n.Handle);
            }

            return handles.ToArray();
        }

        public Int32[] SelectedNodeHandles 
        {
            get
            {
                if (_selectedNodeHandles == null)
                    _selectedNodeHandles = this.getTypeHandles(null);
                
                return _selectedNodeHandles;
            }
        }
        public Int32[] SelectedObjectHandles 
        {
            get
            {
                if (_selectedObjectHandles == null)
                   _selectedObjectHandles = this.getTypeHandles(typeof(OutlinerObject));

                return _selectedObjectHandles;
            }
        }
        public Int32[] SelectedLayerHandles 
        {
            get
            {
                if (_selectedLayerHandles == null)
                    _selectedLayerHandles = this.getTypeHandles(typeof(OutlinerLayer));

                return _selectedLayerHandles;
            }
        }
        public Int32[] SelectedMaterialHandles 
        {
            get
            {
                if (_selectedMaterialHandles == null)
                    _selectedMaterialHandles = this.getTypeHandles(typeof(OutlinerMaterial));

                return _selectedMaterialHandles;
            }
        }

        public List<OutlinerNode> SelectedNodes { get; private set; }

        public SelectionChangedEventArgs(List<OutlinerNode> nodes)
        {
            this.SelectedNodes = nodes;
        }
    }
}
