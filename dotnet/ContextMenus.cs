using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows.Forms;
using Outliner.Scene;

namespace Outliner
{
   public static class ContextMenus
   {
      public static OutlinerNode ClickedNode { get; private set; }
      
      //ClosedTicks keeps track of the time in ticks when the context menu was closed.
      //Used to determine whether the selection should be changed after a mouseclick in
      //the treeview.
      internal static long ClosedTicks { get; private set; }

      public static ContextMenuStrip MainMenu { get; private set; }
      public static ContextMenuStrip EditMaterialMenu { get; private set; }
      public static ContextMenuStrip AddSelectionToMenu { get; private set; }
      public static ContextMenuStrip DisplayPropertiesMenu { get; private set; }
      public static ContextMenuStrip RenderPropertiesMenu { get; private set; }

      // Common items.
      public static ToolStripItem SelectChildnodesItem { get; private set; }
      public static ToolStripItem RenameItem { get; private set; }
      public static ToolStripItem AdvancedRenameItem { get; private set; }
      public static ToolStripItem DeleteItem { get; private set; }
      public static ToolStripMenuItem AddSelectionToItem { get; private set; }
      public static ToolStripItem AddToNewLayerItem { get; private set; }

      // Object items.
      public static ToolStripItem ObjectPropertiesItem { get; private set; }
      public static ToolStripItem UnlinkItem { get; private set; }
      public static ToolStripItem UngroupItem { get; private set; }
      public static ToolStripItem AddToNewContainerItem { get; private set; }
      public static ToolStripItem AddToNewGroupItem { get; private set; }

      // Layer items.
      public static ToolStripItem SetActiveLayerItem { get; private set; }
      public static ToolStripItem CreateNewLayerItem { get; private set; }
      public static ToolStripItem LayerPropertiesItem { get; private set; }

      // Material items.
      public static ToolStripMenuItem EditMaterialItem { get; private set; }
      public static ToolStripItem DisplayShowInVptItem { get; private set; }

      // IHidable items.
      public static ToolStripItem HideItem { get; private set; }
      public static ToolStripItem UnhideItem { get; private set; }

      // IFreezable items.
      public static ToolStripItem FreezeItem { get; private set; }
      public static ToolStripItem UnfreezeItem { get; private set; }

      // Display items.
      public static ToolStripMenuItem DisplayPropertiesItem { get; private set; }
      public static ToolStripMenuItem DisplayViewportItem { get; private set; }
      public static ToolStripMenuItem DisplayBoundingBoxItem { get; private set; }
      public static ToolStripMenuItem DisplayWireframeItem { get; private set; }
      public static ToolStripMenuItem DisplayShadedItem { get; private set; }
      public static ToolStripMenuItem DisplaySeeThroughItem { get; private set; }
      public static ToolStripMenuItem DisplayBackfaceCullItem { get; private set; }
      public static ToolStripMenuItem DisplayBoxModeItem { get; private set; }
      public static ToolStripMenuItem DisplayTrajectoryItem { get; private set; }
      public static ToolStripMenuItem DisplayFrozenInGrayItem { get; private set; }
      public static ToolStripMenuItem DisplayByLayerItem { get; private set; }
      public static ToolStripMenuItem DisplayByLayerAllItem { get; private set; }

      // Render items.
      public static ToolStripMenuItem RenderPropertiesItem { get; private set; }
      public static ToolStripMenuItem RenderableItem { get; private set; }
      public static ToolStripMenuItem VisibleToCamItem { get; private set; }
      public static ToolStripMenuItem VisibleToReflItem { get; private set; }
      public static ToolStripMenuItem ReceiveShadowsItem { get; private set; }
      public static ToolStripMenuItem CastShadowsItem { get; private set; }
      public static ToolStripMenuItem RenderByLayerItem { get; private set; }
      public static ToolStripMenuItem RenderByLayerAllItem { get; private set; }

      // Separators.
      private static ToolStripSeparator separator1;
      private static ToolStripSeparator separator2;
      private static ToolStripSeparator separator3;
      private static ToolStripSeparator separator4;
      private static ToolStripSeparator displaySeparator1;
      private static ToolStripSeparator displaySeparator2;


      #region Show ContextMenu

      public static void ShowContextMenu(Point pos, OutlinerNode node, 
                                         Boolean showObjectItems, Boolean showLayerItems,
                                         Boolean showMaterialItems, Boolean showIDisplayableItems,
                                         Boolean showDisplayItems, Boolean showRenderItems)
      {
         if (MainMenu == null)
            createMainMenu();
         
         MainMenu.Closed += delegate(Object sender, ToolStripDropDownClosedEventArgs e) { ClosedTicks = DateTime.Now.Ticks; };

         ClickedNode = node;

         // Always create "Add Selection To" menu, because it is partially populated by tree each time it is opened.
         AddSelectionToItem.DropDown = createAddSelectionToMenu();

         // Common items.
         SelectChildnodesItem.Visible = showObjectItems || showLayerItems || showMaterialItems;
         RenameItem.Visible = showObjectItems || showLayerItems || showMaterialItems;
         AdvancedRenameItem.Visible = showObjectItems;
         DeleteItem.Visible = showObjectItems || showLayerItems || showMaterialItems;
         AddSelectionToItem.Visible = showObjectItems || showLayerItems;

         // Object items.
         ObjectPropertiesItem.Visible = showObjectItems;
         AddToNewContainerItem.Visible = showObjectItems;
         AddToNewGroupItem.Visible = showObjectItems;
         UnlinkItem.Visible = showObjectItems;
         UngroupItem.Visible = showObjectItems;

         // Layer items.
         SetActiveLayerItem.Visible = showLayerItems;
         LayerPropertiesItem.Visible = showLayerItems;

         // Material items.
         EditMaterialItem.Visible = showMaterialItems;
         DisplayShowInVptItem.Visible = showMaterialItems;

         // IDisplayable items.
         HideItem.Visible = showIDisplayableItems;
         UnhideItem.Visible = showIDisplayableItems;
         FreezeItem.Visible = showIDisplayableItems;
         UnfreezeItem.Visible = showIDisplayableItems;

         // Display items.
         DisplayPropertiesItem.Visible = showDisplayItems;
         DisplayViewportItem.Visible = showLayerItems;
         DisplayBoundingBoxItem.Visible = showLayerItems;
         DisplayWireframeItem.Visible = showLayerItems;
         DisplayShadedItem.Visible = showLayerItems;
         DisplaySeeThroughItem.Visible = showObjectItems || showLayerItems;
         DisplayBoxModeItem.Visible = showObjectItems || showLayerItems;
         DisplayBackfaceCullItem.Visible = showObjectItems || showLayerItems;
         DisplayTrajectoryItem.Visible = showObjectItems || showLayerItems;
         displaySeparator1.Visible = showLayerItems;
         displaySeparator2.Visible = showObjectItems || showLayerItems;
         DisplayByLayerItem.Visible = showObjectItems;
         DisplayByLayerAllItem.Visible = showLayerItems;

         // Render items.
         RenderPropertiesItem.Visible = showRenderItems;
         RenderByLayerItem.Visible = showObjectItems;
         RenderByLayerAllItem.Visible = showLayerItems;

         // Separators.
         separator1.Visible = showObjectItems || showLayerItems || showMaterialItems;
         separator2.Visible = showObjectItems || showIDisplayableItems;
         separator3.Visible = showObjectItems || showDisplayItems || showRenderItems;
         separator4.Visible = showObjectItems || showLayerItems;

         MainMenu.Show(pos);
      }

      #endregion


      #region Create MainMenu

      private static void createMainMenu()
      {
         MainMenu = new ContextMenuStrip();
         MainMenu.RenderMode = ToolStripRenderMode.Professional;
         MainMenu.ShowImageMargin = true;
         MainMenu.ShowCheckMargin = false;

         SelectChildnodesItem = MainMenu.Items.Add(OutlinerResources.ContextMenuSelectChildnodes, OutlinerResources.childnodes);
         SetActiveLayerItem = MainMenu.Items.Add(OutlinerResources.ContextMenuSetActiveLayer, OutlinerResources.activelayer);
         CreateNewLayerItem = MainMenu.Items.Add(OutlinerResources.ContextMenuCreateNewLayer, OutlinerResources.newlayer);
         EditMaterialItem = new ToolStripMenuItem(OutlinerResources.ContextMenuEditMaterial);
         EditMaterialItem.DropDown = createEditMaterialMenu();
         MainMenu.Items.Add(EditMaterialItem);

         separator1 = new ToolStripSeparator();
         MainMenu.Items.Add(separator1);

         RenameItem = MainMenu.Items.Add(OutlinerResources.ContextMenuRename, OutlinerResources.rename);
         AdvancedRenameItem = MainMenu.Items.Add(OutlinerResources.ContextMenuAdvRename, OutlinerResources.advrename);
         DeleteItem = MainMenu.Items.Add(OutlinerResources.ContextMenuDelete, OutlinerResources.delete);

         separator2 = new ToolStripSeparator();
         MainMenu.Items.Add(separator2);

         HideItem = MainMenu.Items.Add(OutlinerResources.ContextMenuHide, OutlinerResources.hide);
         UnhideItem = MainMenu.Items.Add(OutlinerResources.ContextMenuUnhide);
         FreezeItem = MainMenu.Items.Add(OutlinerResources.ContextMenuFreeze, OutlinerResources.freeze);
         UnfreezeItem = MainMenu.Items.Add(OutlinerResources.ContextMenuUnfreeze);

         separator3 = new ToolStripSeparator();
         MainMenu.Items.Add(separator3);

         AddSelectionToItem = new ToolStripMenuItem(OutlinerResources.ContextMenuAddTo);
         AddSelectionToItem.DropDown = createAddSelectionToMenu();
         MainMenu.Items.Add(AddSelectionToItem);
         UnlinkItem = MainMenu.Items.Add(OutlinerResources.ContextMenuUnlink, OutlinerResources.unlink);
         UngroupItem = MainMenu.Items.Add(OutlinerResources.ContextMenuUngroup);

         separator4 = new ToolStripSeparator();
         MainMenu.Items.Add(separator4);

         DisplayPropertiesItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayProperties);
         DisplayPropertiesItem.DropDown = createDisplayPropertiesMenu();
         MainMenu.Items.Add(DisplayPropertiesItem);
         RenderPropertiesItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRenderProperties);
         RenderPropertiesItem.DropDown = createRenderPropertiesMenu();
         MainMenu.Items.Add(RenderPropertiesItem);

         LayerPropertiesItem = MainMenu.Items.Add(OutlinerResources.ContextMenuLayerProperties, OutlinerResources.properties);
         ObjectPropertiesItem = MainMenu.Items.Add(OutlinerResources.ContextMenuObjectProperties, OutlinerResources.properties);
      }

      #endregion


      #region Edit Material

      private static ToolStripDropDown createEditMaterialMenu()
      {
         EditMaterialMenu = new ContextMenuStrip();
         EditMaterialMenu.RenderMode = ToolStripRenderMode.Professional;
         EditMaterialMenu.ShowCheckMargin = true;
         EditMaterialMenu.ShowImageMargin = false;

         for (int i = 0; i < 24; ++i)
         {
            ToolStripMenuItem item = new ToolStripMenuItem(i.ToString());
            item.Tag = i + 1;
            EditMaterialMenu.Items.Add(item);
         }

         return EditMaterialMenu;
      }

      #endregion

      #region Add Selection To

      private static ContextMenuStrip createAddSelectionToMenu()
      {
         AddSelectionToMenu = new ContextMenuStrip();
         AddSelectionToMenu.RenderMode = ToolStripRenderMode.Professional;
         AddSelectionToMenu.ShowImageMargin = true;

         AddToNewContainerItem = AddSelectionToMenu.Items.Add(OutlinerResources.ContextMenuNewContainer, OutlinerResources.newcontainer);
         AddToNewGroupItem = AddSelectionToMenu.Items.Add(OutlinerResources.ContextMenuNewGroup, OutlinerResources.newgroup);
         AddToNewLayerItem = AddSelectionToMenu.Items.Add(OutlinerResources.ContextMenuNewLayer, OutlinerResources.newlayer);

         AddSelectionToMenu.Items.Add(new ToolStripSeparator());

         //Layer items are added by treeview.

         return AddSelectionToMenu;
      }

      #endregion

      #region Display Properties

      private static ContextMenuStrip createDisplayPropertiesMenu()
      {
         DisplayPropertiesMenu = new ContextMenuStrip();
         DisplayPropertiesMenu.RenderMode = ToolStripRenderMode.Professional;
         DisplayPropertiesMenu.ShowImageMargin = false;
         DisplayPropertiesMenu.ShowCheckMargin = true;

         DisplayShowInVptItem = new ToolStripMenuItem(OutlinerResources.ContextMenuShowInVpt);
         DisplayViewportItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayViewport);
         DisplayBoundingBoxItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayBoundingBox);
         DisplayWireframeItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayWireframe);
         DisplayShadedItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayShaded);
         displaySeparator1 = new ToolStripSeparator();
         DisplaySeeThroughItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplaySeeThrough);
         DisplayBackfaceCullItem = new ToolStripMenuItem(OutlinerResources.ContextMenuBackfaceCull);
         DisplayBoxModeItem = new ToolStripMenuItem(OutlinerResources.ContextMenuBoxMode);
         DisplayTrajectoryItem = new ToolStripMenuItem(OutlinerResources.ContextMenuDisplayTrajectory);
         DisplayFrozenInGrayItem = new ToolStripMenuItem(OutlinerResources.ContextMenuFrozenInGray);
         displaySeparator2 = new ToolStripSeparator();
         DisplayByLayerItem = new ToolStripMenuItem(OutlinerResources.ContextMenuInheritFromLayer);
         DisplayByLayerAllItem = new ToolStripMenuItem(OutlinerResources.ContextMenuInheritFromLayerAll);

         DisplayPropertiesMenu.Items.Add(DisplayShowInVptItem);
         DisplayPropertiesMenu.Items.Add(DisplayViewportItem);
         DisplayPropertiesMenu.Items.Add(DisplayBoundingBoxItem);
         DisplayPropertiesMenu.Items.Add(DisplayWireframeItem);
         DisplayPropertiesMenu.Items.Add(DisplayShadedItem);
         DisplayPropertiesMenu.Items.Add(displaySeparator1);
         DisplayPropertiesMenu.Items.Add(DisplaySeeThroughItem);
         DisplayPropertiesMenu.Items.Add(DisplayBoxModeItem);
         DisplayPropertiesMenu.Items.Add(DisplayBackfaceCullItem);
         DisplayPropertiesMenu.Items.Add(DisplayTrajectoryItem);
         DisplayPropertiesMenu.Items.Add(DisplayFrozenInGrayItem);
         DisplayPropertiesMenu.Items.Add(displaySeparator2);
         DisplayPropertiesMenu.Items.Add(DisplayByLayerItem);
         DisplayPropertiesMenu.Items.Add(DisplayByLayerAllItem);

         return DisplayPropertiesMenu;
      }

      #endregion

      #region Render Properties

      private static ContextMenuStrip createRenderPropertiesMenu()
      {
         RenderPropertiesMenu = new ContextMenuStrip();
         RenderPropertiesMenu.RenderMode = ToolStripRenderMode.Professional;
         RenderPropertiesMenu.ShowCheckMargin = true;
         RenderPropertiesMenu.ShowImageMargin = false;

         RenderableItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRender);
         VisibleToCamItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRenderVisToCam);
         VisibleToReflItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRenderVisToRefl);
         ReceiveShadowsItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRenderReceiveShadows);
         CastShadowsItem = new ToolStripMenuItem(OutlinerResources.ContextMenuRenderCastShadows);
         RenderByLayerItem = new ToolStripMenuItem(OutlinerResources.ContextMenuInheritFromLayer);
         RenderByLayerAllItem = new ToolStripMenuItem(OutlinerResources.ContextMenuInheritFromLayerAll);

         RenderPropertiesMenu.Items.Add(RenderableItem);
         RenderPropertiesMenu.Items.Add(VisibleToCamItem);
         RenderPropertiesMenu.Items.Add(VisibleToReflItem);
         RenderPropertiesMenu.Items.Add(ReceiveShadowsItem);
         RenderPropertiesMenu.Items.Add(CastShadowsItem);
         RenderPropertiesMenu.Items.Add(new ToolStripSeparator());
         RenderPropertiesMenu.Items.Add(RenderByLayerItem);
         RenderPropertiesMenu.Items.Add(RenderByLayerAllItem);

         return RenderPropertiesMenu;
      }

      #endregion

   }
}
