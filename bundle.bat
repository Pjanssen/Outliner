@ECHO OFF
SET zipdir=C:\Program Files\7-Zip

SET dir=%~dp0
SET sourceDir=%dir%maxscript\
SET targetDir=%dir%mzp\
SET bundle=%dir%build.mzp

ECHO Bundling %sourceDir%

::Remove target dir if it exists
IF EXIST %targetDir% (
  rmdir /Q /S %targetDir%
  echo Removed %targetDir%
)

::Remove bundle file if it exists
IF EXIST %bundle% ( del /Q /S %bundle% )

::Perform SVN export of source dir
svn export %sourceDir% %targetDir%

::Create bundle from target dir
"%zipdir%\7z.exe" a -tzip %bundle% %targetDir%*

::Remove target dir
rmdir /Q /S %targetDir%