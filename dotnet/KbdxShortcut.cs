using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using System.Windows.Forms;

namespace Outliner
{
[XmlType("shortcut")]
[XmlRoot("shortcut")]
public class KbdxShortcut
{
   public const Int32 MainTableId = 0;
   public const Int32 MacroTableId = 647394;

   [XmlAttribute("fVirt")]
   public Int32 ModKey;

   [XmlAttribute("accleleratorKey")] //This is not a typo on my side...
   public Int32 AccelleratorKey;

   [XmlAttribute("actionID")]
   public String ActionId;

   [XmlAttribute("actionTableID")]
   public Int32 TableId;

   [XmlIgnore]
   public UInt32 PersistentId
   {
      get
      {
         try { return UInt32.Parse(this.ActionId); }
         catch { return 0; }
      }
   }

   [XmlIgnore]
   public String MacroName
   {
      get
      {
         if (this.ActionId.Contains('`'))
            return this.ActionId.Split(new char[] { '`' })[0];
         else
            return null;
      }
   }

   [XmlIgnore]
   public String MacroCategory
   {
      get
      {
         if (this.ActionId.Contains('`'))
            return this.ActionId.Split(new char[] { '`' })[1];
         else
            return null;
      }
   }

   [XmlIgnore]
   public Keys Key
   {
      get { return modKeycodeToKeys(this.ModKey) | keyCodeToKeys(this.AccelleratorKey); }
      set
      {
         this.ModKey = keysToModKeycode(value);
         this.AccelleratorKey = keysToKeyCode(value);
      }
   }


   public KbdxShortcut()
      : this(Keys.None, "0", KbdxShortcut.MainTableId) { }
   public KbdxShortcut(Keys key, String macroName, String macroCategory)
      : this(key, macroName + "`" + macroCategory, KbdxShortcut.MacroTableId) { }
   public KbdxShortcut(Keys key, String actionID, Int32 actionTableID)
   {
      this.Key = key;
      this.ActionId = actionID;
      this.TableId = actionTableID;
   }



   private Keys keyCodeToKeys(Int32 keyCode)
   {
      return (Keys)keyCode;
   }

   private Int32 keysToKeyCode(Keys keys)
   {
      return (Int32)((keys ^ Keys.Modifiers) & Keys.KeyCode);
   }

   private Keys modKeycodeToKeys(Int32 keycode)
   {
      Keys keys = Keys.None;
      if ((keycode & 4) == 4) keys |= Keys.Shift;
      if ((keycode & 8) == 8) keys |= Keys.Control;
      if ((keycode & 16) == 16) keys |= Keys.Alt;
      return keys;
   }
   private Int32 keysToModKeycode(Keys keys)
   {
      Int32 keycode = 3;
      if ((keys & Keys.Shift) == Keys.Shift) keycode += 4;
      if ((keys & Keys.Control) == Keys.Control) keycode += 8;
      if ((keys & Keys.Alt) == Keys.Alt) keycode += 16;
      return keycode;
   }
}
}
