(
--Macro template.
local macro_template = "macroScript outliner_%macro_name%
            category:\"Outliner\"
            toolTip:%tooltip%
            buttonText:%buttontext%
            icon:#(\"%icon_name%\", %icon_index%) (
   global outliner;
   global outliner_status;
   
   on isEnabled do outliner_status != undefined AND \
                   outliner_status.windowOpen AND \
                   %is_enabled_cond%;
                   
   on isChecked do outliner_status != undefined AND \
                   outliner_status.windowOpen AND \
                   %is_checked_cond%;
      
   on execute do (
      if (outliner != undefined  AND \
         outliner_status != undefined AND \
         outliner_status.windowOpen) do (
           %execute_cmd%
      )
   )
)"

--Sortmode macros.
local sortmodes = #("Alphabetical", "Chronological", "Layer", \
                    "Material", "Type", "Visibility");

for s = 1 to sortmodes.count do
(
   local mode = sortmodes[s];
   local mcr_str = macro_template;
   mcr_str = substituteString mcr_str "%macro_name%" ("sortmode_" + mode);
   mcr_str = substituteString mcr_str "%tooltip%" ("\"SortMode: " + mode + "\"");
   mcr_str = substituteString mcr_str "%buttontext%" ("\"SortMode: " + mode + "\"");
   mcr_str = substituteString mcr_str "%icon_name%" "Outliner_sortmodes";
   mcr_str = substituteString mcr_str "%icon_index%" (s as string);
   mcr_str = substituteString mcr_str "%is_enabled_cond%" "true";
   mcr_str = substituteString mcr_str "%is_checked_cond%" \
                  ("(outliner.getSortMode()) == \"" + mode + "\"");
   mcr_str = substituteString mcr_str "%execute_cmd%" \
                  ("outliner.switchSortMode \"" + mode + "\"");
   
   execute mcr_str;
)


--Filter macros.
local filters = #("Geometry", "Shapes", "Lights", "Cameras", "Helpers", \
                  "SpaceWarps", "Bones", "Particles", "Xrefs", \
                  "Hidden", "Frozen");

for f = 1 to filters.count do
(
   local fl = filters[f];
   local mcr_str = macro_template;
   mcr_str = substituteString mcr_str "%macro_name%" ("filter_" + fl);
   mcr_str = substituteString mcr_str "%tooltip%" ("\"Filter: " + fl + "\"");
   mcr_str = substituteString mcr_str "%buttontext%" ("\"Filter: " + fl + "\"");
   mcr_str = substituteString mcr_str "%icon_name%" "Outliner_filter";
   mcr_str = substituteString mcr_str "%icon_index%" ((f + 1) as string);
   mcr_str = substituteString mcr_str "%is_enabled_cond%" "(outliner.getFilterEnabled())";
   mcr_str = substituteString mcr_str "%is_checked_cond%" \
               ("(outliner.getFilterEnabled()) AND outliner.getObjectFilter " + (f as string));
   mcr_str = substituteString mcr_str "%execute_cmd%" \
               ("local enabled = not (outliner.getObjectFilter " + (f as string) + ");" + \
                "outliner.setObjectFilter " + (f as string) + " enabled;");
   
   execute mcr_str; 
)

)