using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Outliner;
using Outliner.Controls;
using Outliner.Controls.NodeSorters;
using Outliner.Controls.TreeViewModes;
using Outliner.Scene;

namespace OutlinerTestForm
{
    public partial class Form1 : Form
    {
        private OutlinerTreeController outlinerController;

        public Form1()
        {
            InitializeComponent();

            outlinerController = new OutlinerTreeController();
            outlinerController.RegisterContainer(this.mainContainer1);

            TreeViewSettings settings = new TreeViewSettings();
            settings.DragMouseButton = MouseButtons.Left;
            outlinerController.SetTreeViewSettings(settings);

            this.mainContainer1.Tree_Top.NodeSorter = new AlphabeticalSorter(this.mainContainer1.Tree_Top);
            this.mainContainer1.Tree_Bottom.Mode = new SelectionSetMode();

            outlinerController.BeginScenePush();

            outlinerController.AddLayer(15, OutlinerScene.LayerRootHandle, "0", false, false, false, false);
            outlinerController.AddLayer(16, 15, "layer B", false, false, false, false);
            outlinerController.AddLayer(17, OutlinerScene.LayerRootHandle, "layer C", false, false, false, false);
            outlinerController.AddMaterial(18, OutlinerScene.MaterialRootHandle, "mat_1", "Standard");
            outlinerController.AddMaterial(19, OutlinerScene.MaterialRootHandle, "mat_2", "Standard");
            outlinerController.AddMaterial(20, 18, "mat_3", "Standard");
            outlinerController.AddObject(1, OutlinerScene.ObjectRootHandle, "test", 15, OutlinerScene.MaterialUnassignedHandle, "sphere", "GeometryClass", false, false, true, false, false);
            outlinerController.AddObject(2, OutlinerScene.ObjectRootHandle, "asd", 15, 19, "sphere", "GeometryClass", false, false, false, false, false);
            outlinerController.AddObject(3, 2, "smth", 15, 18, "spline", "shape", false, false, false, false, false);
            outlinerController.AddObject(4, 3, "object", 16, 20, "sphere", "GeometryClass", false, false, false, false, false);
            outlinerController.AddObject(5, OutlinerScene.ObjectRootHandle, "abcdefg", 17, OutlinerScene.MaterialUnassignedHandle, "spline", "shape", false, false, false, false, false);
            outlinerController.AddObject(6, OutlinerScene.ObjectRootHandle, "henk", 17, OutlinerScene.MaterialUnassignedHandle, "sphere", "GeometryClass", false, false, true, false, false);
            outlinerController.AddObject(7, OutlinerScene.ObjectRootHandle, "grp_test", 16, OutlinerScene.MaterialUnassignedHandle, "dummy", "helper", true, false, false, false, false);
            outlinerController.AddObject(8, 7, "grp_test_bone", 16, OutlinerScene.MaterialUnassignedHandle, "Bone", "GeometryClass", false, true, false, false, false);
            outlinerController.AddObject(9, OutlinerScene.ObjectRootHandle, "spline", 15, 18, "spline", "shape", false, false, false, false, false);

            outlinerController.AddSelectionSet("test_set", new Int32[] { 2, 3, 5, 6 });
            outlinerController.AddSelectionSet("sel_set_2", new Int32[] { 7, 8, 2, 3, 9 });
            outlinerController.AddSelectionSet("sel_set_3", new Int32[] { 1 });
            outlinerController.EndScenePush();

            outlinerController.BeginUpdate();
            outlinerController.SetSelection(new Int32[] { 4, 18 });
            outlinerController.AddObject(24, OutlinerScene.ObjectRootHandle, "add_test", 15, OutlinerScene.MaterialUnassignedHandle, "sphere", "GeometryClass", false, false, false, false, false);
            outlinerController.AddLayer(25, 15, "add_layer_test", false, false, false, false);
            outlinerController.AddMaterial(26, OutlinerScene.MaterialRootHandle, "add_material_test", "Standard");
            outlinerController.EndUpdate();

            TreeViewColors col = new TreeViewColors();
            col.BackColor = Color.FromArgb(245, 245, 245);
            outlinerController.SetTreeViewColors(col);
        }
    }
}
