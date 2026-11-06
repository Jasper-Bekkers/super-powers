@echo off
rem Delete cargo `target` dirs (root and one level deep, e.g. editor\target) in
rem every git worktree of this repo. Only gitignored dirs are touched.
rem   -n     dry run: list what would be deleted
rem   --all  include the main worktree
setlocal

set DRY=0
set ALL=0
:args
if "%~1"=="" goto run
if "%~1"=="-n" (set DRY=1) else if "%~1"=="--all" (set ALL=1) else (
    echo usage: %~nx0 [-n] [--all] 1>&2
    exit /b 1
)
shift
goto args

:run
set FIRST=1
for /f "tokens=1,*" %%a in ('git worktree list --porcelain') do (
    if "%%a"=="worktree" call :worktree "%%b"
)
exit /b 0

:worktree
if %FIRST%==1 (
    set FIRST=0
    if %ALL%==0 exit /b 0
)
set "WT=%~1"
set "WT=%WT:/=\%"
call :target "%WT%" "target"
for /d %%d in ("%WT%\*") do call :target "%WT%" "%%~nxd\target"
exit /b 0

:target
if not exist "%~1\%~2\" exit /b 0
git -C "%~1" check-ignore -q "%~2" 2>nul || (
    echo skip ^(not ignored^): %~1\%~2
    exit /b 0
)
if %DRY%==1 (
    echo would delete: %~1\%~2
) else (
    echo deleting: %~1\%~2
    rem \\?\ prefix so rd copes with paths past MAX_PATH
    rd /s /q "\\?\%~1\%~2"
)
exit /b 0
