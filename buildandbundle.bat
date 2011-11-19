@ECHO OFF

SET MSBuild=%SystemRoot%\Microsoft.NET\Framework\v3.5\MSBuild.exe

::Build Outliner.dll
ECHO Building Outliner...
SET Configuration=Release
%MSBuild% dotnet/Outliner.csproj || goto :error

ECHO.
bundle.bat
goto :eof

:error
PAUSE
EXIT /B %ERRORLEVEL%