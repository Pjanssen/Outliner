struct outlinerHelperFunctions
(
	--Load an assembly with shadow-copy enabled.
	public function loadDotNetAssembly dir dll =
	(
		local AppDomain = dotNetClass "System.AppDomain";
		local AssemblyName = dotNetClass "System.Reflection.AssemblyName";

		AppDomain.CurrentDomain.SetShadowCopyPath dir;
		AppDomain.CurrentDomain.SetShadowCopyFiles();

		local assemblyName = AssemblyName.GetAssemblyName (dir + dll);
		AppDomain.CurrentDomain.Load assemblyName;
	),
	
	
	--Returns a dotnet enum value from the supplied type and value strings.
	public function parseDotNetEnum enumType enumValue =
	(
		(dotNetClass "System.Enum").Parse (dotNet.getType enumType) enumValue;
	),


	--Return the names in the enum as an array.
	public function getNamesDotNetEnum enumType =
	(
		(dotNetClass "System.Enum").GetNames (dotNet.getType enumType);
	),
	


	--Converts a string representing a color to a color object. (can be "color 0 120 15", or a colorman color such as "window").
	public function getColorFromStr colorStr = 
	(
		local newColor = color 0 0 0;
		
		try
		(
			if (matchPattern colorStr pattern:"(color * * *)") then
			(
				local fStr = filterString colorStr " )";
				newColor.r = fStr[2] as float;
				newColor.g = fStr[3] as float;
				newColor.b = fStr[4] as float;
				if (fStr.count >= 5) do newColor .a = fStr[5] as float;
			)
			else if (colorMan.getName colorStr != undefined) then
				newColor = ((colorMan.getColor colorStr) * 255) as color;
		)
		catch
		(
			newColor = color 0 0 0;
		)
		
		newColor;
	),
	
	--Returns true if the user is using the dark colour scheme.
	public function usingMaxDarkScheme =
	(
		local windowColor = (colorman.getcolor #window) * 255;
		(windowColor[1] < 120 AND windowColor[2] < 120 AND windowColor[3] < 120)
	)
)