namespace Outliner.Controls
{
    partial class MainContainer
    {
        /// <summary> 
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary> 
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Component Designer generated code

        /// <summary> 
        /// Required method for Designer support - do not modify 
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            Outliner.Controls.Filters.NodeFilterCollection nodeFilterCollection1 = new Outliner.Controls.Filters.NodeFilterCollection();
            Outliner.Controls.TreeViewModes.HierarchyMode treeViewHierarchyMode1 = new Outliner.Controls.TreeViewModes.HierarchyMode();
            Outliner.Controls.TreeViewSettings treeViewSettings1 = new Outliner.Controls.TreeViewSettings();
            Outliner.Controls.Filters.NodeFilterCollection nodeFilterCollection2 = new Outliner.Controls.Filters.NodeFilterCollection();
            Outliner.Controls.TreeViewModes.HierarchyMode treeViewHierarchyMode2 = new Outliner.Controls.TreeViewModes.HierarchyMode();
            Outliner.Controls.TreeViewSettings treeViewSettings2 = new Outliner.Controls.TreeViewSettings();
            this.TreeSplitContainer = new Outliner.Controls.OutlinerSplitContainer();
            this.Tree_Top = new Outliner.Controls.TreeView();
            this.Tree_Bottom = new Outliner.Controls.TreeView();
            this.TreeSplitContainer.Panel1.SuspendLayout();
            this.TreeSplitContainer.Panel2.SuspendLayout();
            this.TreeSplitContainer.SuspendLayout();
            this.SuspendLayout();
            // 
            // TreeSplitContainer
            // 
            this.TreeSplitContainer.Dock = System.Windows.Forms.DockStyle.Fill;
            this.TreeSplitContainer.ForeColor = System.Drawing.SystemColors.ControlText;
            this.TreeSplitContainer.Location = new System.Drawing.Point(0, 0);
            this.TreeSplitContainer.Margin = new System.Windows.Forms.Padding(0);
            this.TreeSplitContainer.Name = "TreeSplitContainer";
            this.TreeSplitContainer.Orientation = System.Windows.Forms.Orientation.Horizontal;
            // 
            // TreeSplitContainer.Panel1
            // 
            this.TreeSplitContainer.Panel1.Controls.Add(this.Tree_Top);
            this.TreeSplitContainer.Panel1.ForeColor = System.Drawing.SystemColors.ControlText;
            this.TreeSplitContainer.Panel1MinSize = 40;
            // 
            // TreeSplitContainer.Panel2
            // 
            this.TreeSplitContainer.Panel2.Controls.Add(this.Tree_Bottom);
            this.TreeSplitContainer.Panel2MinSize = 40;
            this.TreeSplitContainer.Size = new System.Drawing.Size(278, 343);
            this.TreeSplitContainer.SplitterDistance = 162;
            this.TreeSplitContainer.TabIndex = 0;
            // 
            // Tree_Top
            // 
            this.Tree_Top.Dock = System.Windows.Forms.DockStyle.Fill;
            nodeFilterCollection1.Enabled = true;
            this.Tree_Top.Filters = nodeFilterCollection1;
            this.Tree_Top.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Tree_Top.IconSet = Outliner.Controls.IconSet.Max;
            this.Tree_Top.ImageIndex = 0;
            this.Tree_Top.Indent = 12;
            this.Tree_Top.InvertIcons = false;
            this.Tree_Top.ItemHeight = 18;
            this.Tree_Top.Location = new System.Drawing.Point(0, 0);
            this.Tree_Top.Margin = new System.Windows.Forms.Padding(0);
            this.Tree_Top.Mode = treeViewHierarchyMode1;
            this.Tree_Top.Name = "Tree_Top";
            this.Tree_Top.SelectedImageIndex = 0;
            treeViewSettings1.DoubleClickAction = Outliner.Controls.DoubleClickAction.Rename;
            treeViewSettings1.DragMouseButton = System.Windows.Forms.MouseButtons.Middle;
            treeViewSettings1.IconClickAction = Outliner.Controls.IconClickAction.SetLayerActive;
            treeViewSettings1.InvertNodeHideButton = false;
            treeViewSettings1.ShowNodeAddToLayerButton = true;
            treeViewSettings1.ShowNodeBoxModeButton = false;
            treeViewSettings1.ShowNodeFreezeButton = true;
            treeViewSettings1.ShowNodeHideButton = true;
            treeViewSettings1.ShowNodeIcon = true;
            this.Tree_Top.Settings = treeViewSettings1;
            this.Tree_Top.Size = new System.Drawing.Size(278, 162);
            this.Tree_Top.TabIndex = 0;
            // 
            // Tree_Bottom
            // 
            this.Tree_Bottom.Dock = System.Windows.Forms.DockStyle.Fill;
            nodeFilterCollection2.Enabled = true;
            this.Tree_Bottom.Filters = nodeFilterCollection2;
            this.Tree_Bottom.Font = new System.Drawing.Font("Tahoma", 8.25F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Tree_Bottom.IconSet = Outliner.Controls.IconSet.Max;
            this.Tree_Bottom.ImageIndex = 0;
            this.Tree_Bottom.Indent = 12;
            this.Tree_Bottom.InvertIcons = false;
            this.Tree_Bottom.ItemHeight = 18;
            this.Tree_Bottom.Location = new System.Drawing.Point(0, 0);
            this.Tree_Bottom.Mode = treeViewHierarchyMode2;
            this.Tree_Bottom.Name = "Tree_Bottom";
            this.Tree_Bottom.SelectedImageIndex = 0;
            treeViewSettings2.DoubleClickAction = Outliner.Controls.DoubleClickAction.Rename;
            treeViewSettings2.DragMouseButton = System.Windows.Forms.MouseButtons.Middle;
            treeViewSettings2.IconClickAction = Outliner.Controls.IconClickAction.SetLayerActive;
            treeViewSettings2.InvertNodeHideButton = false;
            treeViewSettings2.ShowNodeAddToLayerButton = true;
            treeViewSettings2.ShowNodeBoxModeButton = false;
            treeViewSettings2.ShowNodeFreezeButton = true;
            treeViewSettings2.ShowNodeHideButton = true;
            treeViewSettings2.ShowNodeIcon = true;
            this.Tree_Bottom.Settings = treeViewSettings2;
            this.Tree_Bottom.Size = new System.Drawing.Size(278, 177);
            this.Tree_Bottom.TabIndex = 0;
            // 
            // MainContainer
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.BackColor = System.Drawing.Color.Transparent;
            this.Controls.Add(this.TreeSplitContainer);
            this.Font = new System.Drawing.Font("Tahoma", 9.75F, System.Drawing.FontStyle.Regular, System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.Margin = new System.Windows.Forms.Padding(0);
            this.Name = "MainContainer";
            this.Size = new System.Drawing.Size(278, 343);
            this.TreeSplitContainer.Panel1.ResumeLayout(false);
            this.TreeSplitContainer.Panel2.ResumeLayout(false);
            this.TreeSplitContainer.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        public TreeView Tree_Bottom;
        public TreeView Tree_Top;
        public Outliner.Controls.OutlinerSplitContainer TreeSplitContainer;
    }
}
