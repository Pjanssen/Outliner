@ECHO OFF

CALL :GetZip zip
dir "%zip%" > nul || goto :PathError "Could not find 7z.exe."


SET dir=%~dp0
SET Configuration=Release
SET sourceDir=%dir%maxscript\
SET targetDir=%dir%mzp\
SET output=%dir%outliner.mzp

ECHO Removing old target files and directory...

::Remove target dir if it exists
IF EXIST %targetDir% (
  rmdir /Q /S %targetDir% || goto :error
  echo Removed %targetDir%
)

::Remove output file if it exists
IF EXIST %output% ( del /Q /S %output% || goto :error )

::Perform SVN export of source dir
ECHO.
ECHO Exporting maxscript from svn...
svn export %sourceDir% %targetDir% || goto :error

::Copy Outliner.dll from dotnet to maxscript
ECHO.
ECHO Copying Outliner.dll to bundle...
copy %dir%dotnet\bin\%Configuration%\Outliner.dll %targetDir%script\Outliner.dll || goto :error

::Create output from target dir
ECHO.
ECHO Packing mzp...
"%zip%" a -tzip %output% %targetDir%* || goto :error

::Remove target dir
rmdir /Q /S %targetDir% || goto :error

ECHO Done.
goto :eof


:GetZip
SET KEY_NAME=HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip
SET KEY_VALUE=Path

FOR /F "tokens=2*" %%A IN ('REG QUERY "%KEY_NAME%" /v %KEY_VALUE% 2^>nul') DO (
   set %~1=%%B7z.exe
)
goto :eof

:PathError
ECHO %~1
goto :error

:error
ECHO.
ECHO Bundling failed.
PAUSE
EXIT /B %ERRORLEVEL%