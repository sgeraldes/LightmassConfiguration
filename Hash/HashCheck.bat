@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

set uGPULightmass4191=https://www.dropbox.com/sh/3issyqm20wb08ts/AAAtbdIywQm7Wg_af6eEbmKRa?dl=1
set uGPULightmass4192=https://www.dropbox.com/sh/nkte4fotkczd7vy/AAAHMrzKvwiJww0Km6dBe-i_a?dl=1
set uGPULightmass4201=https://dl.orangedox.com/gjD37r7TcxMV4jqx9U?dl=1
set uGPULightmass4202=https://www.dropbox.com/s/8x2w3b4iamj81ac/GPULightmassIntegration-4.20.2.zip?dl=1
set uGPULightmass421=https://dl.orangedox.com/YtozAlX0QCNN57KXT2?dl=1
set uGPULightmass422=https://dl.orangedox.com/93ekBf83FHfyK0zZbp?dl=1
set uGPULightmass423=https://dl.orangedox.com/QcG2N4qxn5bXfyo0VL?dl=1
set uGPULightmass4231=https://dl.orangedox.com/byWAUR3EZfV1aFqTXX?dl=1

REM CONSOLE COLORS AND MESSAGES
SET mERROR=[31m[7mERRO[0m: 
SET mINFO=[42m[7mINFO[0m: 
SET mWARN=[43m[7mWARN[0m: 
SET cStrong=[97m
SET cUnderline=[4m
SET cReset=[0m
SET cRED=[31m
SET cGREEN=[32m
SET cSOFT=[90m


:MAIN
set UnrealVersion=4.23
ECHO UnrealVersion=!UnrealVersion! >test.txt
REM REGISTRY SETTINGS
set KEY_NAME=HKLM\Software\EpicGames\Unreal Engine\%UnrealVersion%
set VALUE_NAME=InstalledDirectory
SET pathUnrealEd=Engine\Binaries\Win64\UE4Editor-UnrealEd.dll
SET pathGPULightmass=Engine\Binaries\Win64\GPULightmassKernel.dll

CALL :GETINSTALLPATH
CALL :Testing

SET pUnrealEd=%pathUnrealEd%
SET pGPULightmass=%pathGPULightmass%

set UnrealVersion=4.19.1
set uGPULightmass=%uGPULightmass4191%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.19.2
set uGPULightmass=%uGPULightmass4192%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.20.1
set uGPULightmass=%uGPULightmass4201%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.20.2
set uGPULightmass=%uGPULightmass4202%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.21
set uGPULightmass=%uGPULightmass421%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.22
set uGPULightmass=%uGPULightmass422%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.23
set uGPULightmass=%uGPULightmass423%
CALL :DOWNLOAD
CALL :UNZIP

set UnrealVersion=4.23.1
set uGPULightmass=%uGPULightmass4231%
CALL :DOWNLOAD
CALL :UNZIP

ECHO.
ECHO ALL DONE. Have a good day!
TIMEOUT 3 >NUL
Pause
EXIT /B


:GETINSTALLPATH
REM GET THE FOLDER WHERE UE4 WAS INSTALLED
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul') DO (set pInstallDir=%%B)
IF NOT DEFINED pInstallDir (
	echo %mERROR%%cRED%Unreal Engine Version %UnrealVersion% Not Installed or registry not set... %cReset%
	echo %cSoft%Script will now quit.%cReset%
	echo.
	SET EPICERROR=1
	EXIT /B
)
echo %mINFO%[1mUnreal Engine Version %UnrealVersion% is installed in: %cReset%
echo      - !pInstallDir!

REM IF EXIST !pInstallDir!\Engine\Binaries\Win64\GPULightmassKernel.dll
SET pUnrealEd=!pInstallDir!\%pathUnrealEd%
SET pGPULightmass=!pInstallDir!\%pathGPULightmass%

EXIT /B

:DOWNLOAD
IF EXIST %UnrealVersion%.zip ECHO FILE %UnrealVersion%.zip EXISTS and NO NEED TO DOWNLOAD && EXIT /B
ECHO Downloading GPU Lightmass, this can take a while. Please wait...
powershell -Command "Invoke-WebRequest !uGPULightmass! -OutFile !UnrealVersion!.zip"
powershell -Command "Expand-Archive -LiteralPath !UnrealVersion!.zip -DestinationPath . -Force"
REM IF %ERRORLEVEL% EQU 0 (del %UnrealVersion%.zip /q) ELSE (ECHO %mERROR%%cRED%ERROR DOWNLOADING. ERRORLEVEL: %ERRORLEVEL%%cReset%)
echo.
:UZIPFILE
7za x !UnrealVersion!.zip -y -r
REM Del %UnrealVersion%.zip /Q
EXIT /B

:UNZIP
ECHO. >>test.txt
ECHO UnrealVersion=!UnrealVersion! >>test.txt
FOR /f "tokens=*" %%G IN ('dir GPULightmassIntegration-!UnrealVersion!*.zip ^/b') DO (
	rmdir Engine /S /Q
	7za x %%G Engine\Binaries\Win64\UE4Editor-UnrealEd.dll >nul
	7za x %%G Engine\Binaries\Win64\GPULightmassKernel.dll >nul
	SET _Quality=%%G
	REM SET _Quality=!_Quality:GPULightmassIntegration-=!
	SET _Quality=!_Quality:~31!
	SET _Quality=!_Quality:.zip=!
	Call :Testing
	REM del %%G /Q
)
EXIT /B

:Testing
SET pFileToCheck=!pUnrealEd!
Call :Test
SET pFileToCheck=!pGPULightmass!
Call :Test
EXIT /B

:Test
SET "_HASH="
SET "_LINE="
REM ECHO FILE: !pFileToCheck! >>test.txt
FOR /F "tokens=*" %%a IN ('certutil -hashfile "!pFileToCheck!" MD5 ^| find /i /v "md5" ^| find /i /v "certutil"') DO (SET _HASH=%%a)
IF DEFINED _HASH (
	REM FOR /F "tokens=1 delims=:" %g IN ('find /c "dcb8f8c59d98eb7b3520db82af0a3ae0" test.txt ^>nul') DO (SET _LINE=%g)
	find /c "!_HASH!" test.txt >nul
	if !errorlevel! equ 1 (
		ECHO. >>test.txt
		ECHO !UnrealVersion!:!pFileToCheck:*Win64^\=!:!_Quality!:!_HASH! >>test.txt
	) ELSE (
		FOR /F "skip=2 tokens=1 delims=:" %%g IN ('find /n "!_HASH!" test.txt') DO (SET _LINE=%%g)
		ECHO !UnrealVersion!:!pFileToCheck:*Win64^\=!:!_Quality!:!_HASH! [DUPLICATE:!_LINE:~0,-7!] >>test.txt
	)
) ELSE (
	ECHO !pFileToCheck!FILE NOT FOUND >>test.txt
)
EXIT /B