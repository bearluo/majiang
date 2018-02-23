@echo off
set ROOT_PATH=%~dp0
echo %ROOT_PATH%

rem XCOPY %ROOT_PATH%res %ROOT_PATH%res_temp\ /s /h /d /y
rem XCOPY %ROOT_PATH%src %ROOT_PATH%src_temp\ /s /h /d /y

if exist res_temp (
	rmdir res_temp /s /q
)

if exist src_temp (
	rmdir src_temp /s /q
)

mkdir src_temp

call encrypt_res.bat -i res -o res_temp -ek woyaopoker -es poker
rem XCOPY res res_temp\ /s /h /d /y
if exist res_temp\icon (
	rmdir res_temp\icon /s /q
)
XCOPY res\icon res_temp\icon\ /s /h /d /y
call compile_scripts.bat -i src -o res_temp/game.zip -e xxtea_zip -ek woyaopoker -es poker
del res_temp\project.manifest
del res_temp\version.manifest
rem call compile_scripts.bat -i src -x framework,cocos -o res_temp/game.zip
rem call compile_scripts.bat -i src -x app,appentry,config,main,sproto,sprotoparser -o res_temp/framework.zip
rem call compile_scripts.bat -i src -x framework,cocos -o res_temp/game64.zip -e xxtea_zip -ek woyaopoker -es poker -b 64
rem call compile_scripts.bat -i src -x app,appentry,config,main,sproto,sprotoparser -o res_temp/framework64.zip -e xxtea_zip -ek woyaopoker -es poker -b 64
call GenHotUpdate.py
call py frameworks/runtime-src/proj.android/build_native_temp.py
rem cd /frameworks/runtime-src/proj.android
rem call C:/Users/bearluo/.gradle/wrapper/dists/gradle-3.3-all/55gk2rcmfc6p2dg9u9ohc3hw9/gradle-3.3/bin/gradle.bat assembleRelease
pause