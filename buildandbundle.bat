@ECHO OFF

::SET MSBuild=%SystemRoot%\Microsoft.NET\Framework\v3.5\MSBuild.exe
CALL :GetMsBuild MSBuild 3.5
dir "%MSBuild%" > nul || goto :PathError "Could not find MSBuild.exe for .NET 3.5."


::Build Outliner.dll
ECHO Building Outliner...
SET Configuration=Release
%MSBuild% dotnet/Outliner.csproj /nologo || goto :error


ECHO.
call bundle.bat
goto :eof


:: Usage: CALL :GetMSBuild variable_to_set dot_net_version
:GetMSBuild
SET KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\MSBuild\ToolsVersions\
SET KEY_VALUE=MSBuildToolsPath

FOR /F "tokens=2*" %%A IN ('REG QUERY "%KEY_NAME%%2" /v %KEY_VALUE% 2^>nul') DO (
   set %~1=%%BMSBuild.exe
)
goto :eof


:PathError
ECHO %~1
goto :error

:error
PAUSE
EXIT /B %ERRORLEVEL%