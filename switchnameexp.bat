@echo off
setlocal DisableDelayedExpansion

set /p "infile=Enter full path and filename: "

if not exist "%infile%" (
    echo File not found:
    echo %infile%
    pause
    exit /b 1
)

for %%F in ("%infile%") do (
    set "outfile=%%~dpnFnameexpswitched%%~xF"
)

break > "%outfile%"

for /f "usebackq delims=" %%L in ("%infile%") do (
    set "line=%%L"
    call :ProcessLine >> "%outfile%"
)

echo.
echo Output written to:
echo %outfile%
pause
exit /b

:ProcessLine
setlocal EnableDelayedExpansion

set "line=%line%"

echo(!line! | findstr /c:"expression=""" >nul
if errorlevel 1 (
    echo(!line!
    goto :eof
)

echo(!line! | findstr /c:"name=""" >nul
if errorlevel 1 (
    echo(!line!
    goto :eof
)

set "beforeExpr=!line:*expression="=!"
for /f delims^=^" tokens^=1 %%A in ("!beforeExpr!") do set "expr=%%A"

set "beforeName=!line:*name="=!"
for /f delims^=^" tokens^=1 %%A in ("!beforeName!") do set "name=%%A"

set "newline=!line:expression="!expr!"=__TEMP_EXPR__!"
set "newline=!newline:name="!name!"=expression="!name!"!"
set "newline=!newline:__TEMP_EXPR__=name="!expr!"!"

echo(!newline!

endlocal
goto :eof
