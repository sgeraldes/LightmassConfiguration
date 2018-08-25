@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

set uGPULightmass4191=https://www.dropbox.com/sh/3issyqm20wb08ts/AAAtbdIywQm7Wg_af6eEbmKRa?dl=1
set uGPULightmass4192=https://www.dropbox.com/sh/nkte4fotkczd7vy/AAAHMrzKvwiJww0Km6dBe-i_a?dl=1
set uGPULightmass4201=https://dl.orangedox.com/gjD37r7TcxMV4jqx9U?dl=1
set uGPULightmass4202=https://dl.orangedox.com/P02pizph3hSVF1OtSJ?dl=1

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
ECHO. >test.txt
set UnrealVersion=4.19
ECHO. >>test.txt
ECHO UnrealVersion=!UnrealVersion! >>test.txt
REM REGISTRY SETTINGS
set KEY_NAME=HKLM\Software\EpicGames\Unreal Engine\%UnrealVersion%
set VALUE_NAME=InstalledDirectory
CALL :GETINSTALLPATH
CALL :Testing

set UnrealVersion=4.20
ECHO. >>test.txt
ECHO UnrealVersion=!UnrealVersion! >>test.txt
REM REGISTRY SETTINGS
set KEY_NAME=HKLM\Software\EpicGames\Unreal Engine\%UnrealVersion%
set VALUE_NAME=InstalledDirectory
CALL :GETINSTALLPATH
CALL :Testing

SET pUnrealEd=.\Engine\Binaries\Win64\UE4Editor-UnrealEd.dll
SET pGPULightmass=.\Engine\Binaries\Win64\GPULightmassKernel.dll

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
SET pUnrealEd=!pInstallDir!\Engine\Binaries\Win64\UE4Editor-UnrealEd.dll
SET pGPULightmass=!pInstallDir!\Engine\Binaries\Win64\GPULightmassKernel.dll

EXIT /B

:DOWNLOAD
IF EXIST %UnrealVersion%.zip ECHO FILE %UnrealVersion%.zip EXISTS and NO NEED TO DOWNLOAD && EXIT /B
ECHO Downloading GPU Lightmass, this can take a while. Please wait...
powershell -Command "Invoke-WebRequest !uGPULightmass! -OutFile %UnrealVersion%.zip"
powershell -Command "Expand-Archive -LiteralPath %UnrealVersion%.zip -DestinationPath . -Force"
REM IF %ERRORLEVEL% EQU 0 (del %UnrealVersion%.zip /q) ELSE (ECHO %mERROR%%cRED%ERROR DOWNLOADING. ERRORLEVEL: %ERRORLEVEL%%cReset%)
echo.
7za x %UnrealVersion%.zip -y -r
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
REM ECHO FILE: !pFileToCheck! >>test.txt
FOR /F "tokens=*" %%a IN ('certutil -hashfile "!pFileToCheck!" MD5 ^| find /i /v "md5" ^| find /i /v "certutil"') DO (SET _HASH=%%a)
IF DEFINED _HASH (
	find /c "!_HASH!" test.txt >nul
	if !errorlevel! equ 1 (
		ECHO. >>test.txt
		ECHO !UnrealVersion!:!pFileToCheck:*Win64^\=!:!_Quality!:!_HASH! >>test.txt
	)
) ELSE (
	ECHO !pFileToCheck!FILE NOT FOUND >>test.txt
)
EXIT /B