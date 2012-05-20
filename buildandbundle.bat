@ECHO OFF

::Adjust the value of MaxDir to match your local 3dsmax installation directory.
SET MaxDir=C:\Program Files\Autodesk\3ds Max 2013\

CALL :GetMsBuild MSBuild 4.0
IF "%MSBuild%"=="" goto :PathError "Could not find MSBuild.exe for .NET 4.0."
dir "%MSBuild%" > nul || goto :PathError "Could not find MSBuild.exe for .NET 4.0."


::Build Outliner.dll
ECHO Building Outliner...
:: SET Configuration=Release
%MSBuild% dotnet/Outliner.csproj /nologo /verbosity:quiet /ToolsVersion:4.0 /p:ReferencePath="%MaxDir%;" || goto :error


ECHO.
call bundle.bat
goto :eof


:: Usage: CALL :GetMSBuild variable_to_set dot_net_version
:GetMSBuild
SET KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\
SET KEY_VALUE=MSBuildToolsPath

FOR /F "tokens=2*" %%A IN ('REG QUERY "%KEY_NAME%%2" /v %KEY_VALUE% 2^>nul') DO (
   set %~1=%%B\MSBuild.exe
)
goto :eof


:PathError
ECHO %~1
goto :error

:error
PAUSE
EXIT /B %ERRORLEVEL%