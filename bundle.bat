@ECHO OFF

SET dir=%~dp0
SET Configuration=Release
SET targetDir=%dir%mzp\
SET output=%dir%outliner.mzp


ECHO Checking bundle prerequisites...
CALL :GetZip zip
dir "%zip%" > nul || goto :ZipNotFoundError
ECHO Found 7Zip.


ECHO.
ECHO Removing old target files and directory...

::Remove target dir if it exists
IF EXIST %targetDir% (
  rmdir /Q /S %targetDir% || goto :error
  echo Removed %targetDir%
)

::Remove output file if it exists
IF EXIST %output% ( del /Q /S %output% || goto :error )



::Copy the maxscript dir to a temporary directory.
ECHO.
ECHO Copying maxscript to temporary mzp directory...
xcopy %dir%maxscript %targetDir% /e /q || goto :error



::Copy Outliner.dll from dotnet to maxscript
ECHO.
ECHO Copying Outliner.dll to bundle...
copy %dir%dotnet\bin\%Configuration%\Outliner.dll %targetDir%script\Outliner.dll || goto :OutlinerDllError



::Create package from target dir
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

:ZipNotFoundError
ECHO Could not find 7z.exe.
goto :error

:OutlinerDllError
ECHO You may have to build the .NET library first using buildandbundle.bat
goto :error

:error
ECHO.
ECHO Bundling failed.
PAUSE
EXIT /B %ERRORLEVEL%