@echo off
:: WHEN UPDATING GODOT: don't forget to regen SLN file with: scons vsproj=yes ... (same command than scons below)
set PROJECT_PATH=D:\Dev\Godot\sea-survivors
set BUILD_PROFILE=DragonRegularEditor
set INCLUDE_DEBUG=yes
set USE_LLVM=yes

if %USE_LLVM% == no (
	set USE_LLVM=no
	CALL "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
) else (
	set USE_LLVM=yes
)
@echo on

scons platform=windows target=editor^
 arch=x86_64 use_mingw=%USE_LLVM% use_llvm=%USE_LLVM%^
 module_mono_enabled=yes accesskit=no angle=no winrt=no^
 build_profile=%PROJECT_PATH%\%BUILD_PROFILE%.gdbuild^
 debug_symbols=%INCLUDE_DEBUG% separate_debug_symbols=%INCLUDE_DEBUG%^
 CCFLAGS="-fno-omit-frame-pointer -fno-inline -ggdb3"^
 profiler=tracy profiler_path=%~dp0modules\godot_tracy\tracy

@echo off
if %errorlevel% neq 0 exit /b %errorlevel%
@echo on

bin\godot.windows.editor.x86_64.mono.console.exe --headless --generate-mono-glue modules/mono/glue 1>nul

@echo off
if %errorlevel% neq 0 exit /b %errorlevel%
@echo on

python modules/mono/build_scripts/build_assemblies.py^
 --godot-output-dir=./bin^
 --push-nupkgs-local %PROJECT_PATH%\LocalNugetSource\

@echo off
if %errorlevel% neq 0 exit /b %errorlevel%

if %~1 == zip (
	pushd "bin\"
	if exist GodotEditor.zip DEL /q /s GodotEditor.zip
	CALL "C:\Program Files\7-Zip\7z.exe" a -mx9 GodotEditor.zip godot.windows.editor.x86_64.llvm.mono.exe GodotSharp
	popd
) else (
	echo "Skipping zip step"
)

@echo off
exit /b %errorlevel%
