@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

:Variables
REM Variables that can be modified bellow
set UnrealVersion=4.20
set pFastPreview=GPULightmassIntegration-4.20.1-FastPreview.zip
set pMedium=GPULightmassIntegration-4.20.1-MediumQuality.zip
set pUltraHigh=GPULightmassIntegration-4.20.1-UltraHigh.zip
set pExtreme=GPULightmassIntegration-4.20.1-Extreme.zip

REM URLS can be modified
set u7ZIP=https://www.7-zip.org/a/7za920.zip
set uGPULightmass=https://dl.orangedox.com/gjD37r7TcxMV4jqx9U?dl=1

REM TDR Settings
set iTDRValue=300

REM NVIDIA DRIVER VERSION 398.26 or later required. 
set iMinDriverVersion=2421139826

:FUNCTIONS
REM HERE BE DRAGONS!
REM ...................................................................
REM DO NOT CHANGE ANYTHING FROM HERE UNLESS YOU KNOW WHAT YOU ARE DOING
REM ...................................................................

set sScriptVersion=v0.2.1

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

REM REGISTRY SETTINGS
set KEY_NAME=HKLM\Software\EpicGames\Unreal Engine\%UnrealVersion%
set VALUE_NAME=InstalledDirectory

set KEY_NAME_TDR=HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers
set VALUE_NAME_TDR=TdrDelay

:MAIN
CALL :UAC
CALL :HEADER
CALL :TDRDELAY
CALL :7Z
CALL :CHECKRUNNING
CALL :SETUP
IF EPICERROR EQU 1 GOTO :EXIT
CALL :MENU
GOTO :EXIT

:UAC
REM  --> Check for permissions
net session >nul 2>&1
REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
	echo.
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    cscript "%temp%\getadmin.vbs"
    exit
) else ( 
    REM Cleanning up...
	if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
)
Exit /B

:7z
IF NOT EXIST 7za.exe (
	ECHO %mINFO%Downloading 7zip
	powershell -Command "Invoke-WebRequest %u7ZIP% -OutFile 7za.zip"
	powershell -Command "Expand-Archive -LiteralPath 7za.zip -DestinationPath ."
	del /q 7za.zip >nul
)
EXIT /B

:HEADER
ECHO.
ECHO %cStrong%Luoshuang's GPULightmass %cSoft%Installer Script %sScriptVersion%%cReset%
ECHO %cSoft%                     - For Unreal Version %UnrealVersion%%cReset%
ECHO.
wmic path win32_VideoController get driverVersion,Name
FOR /F "tokens=1*" %%a IN ('wmic path win32_VideoController get driverVersion^,Name ^| find "NVIDIA"') DO (SET _DRIVER=%%a)
SET _DRIVER=%_DRIVER:.=%
IF DEFINED _DRIVER (
IF "%_DRIVER%" GEQ "%iMinDriverVersion%" (ECHO %mINFO%%cGREEN%Nvidia Driver version is %iMinDriverVersion:~5,3%.%iMinDriverVersion:~8,2% or greater ^(GOOD^)%cReset%) ELSE (ECHO %mINFO%%cGREEN%Nvidia Driver version is %_DRIVER:~5,3%.%_DRIVER:~8,2% %cReset% && ECHO %mERROR%%cRED%NVIDIA DRIVER NEEDS TO BE UPDATED TO %iMinDriverVersion:~5,3%.%iMinDriverVersion:~8,2% OR GREATER TO USE GPU LIGHTMASS.%cReset% && ECHO. && PAUSE)
) ELSE (
ECHO %mERROR%%cRED%CAN'T FIND NVIDIA DRIVER INFORMATION ^(CRITICAL^)%cReset%
TIMEOUT 3 
)
EXIT /B

:SETUP
REM GET THE FOLDER WHERE UE4 WAS INSTALLED
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME%" /v "%VALUE_NAME%" 2^>nul') DO (set pInstallDir=%%B)
IF NOT DEFINED pInstallDir (
	echo %mERROR%%cRED%Unreal Engine Version %UnrealVersion% Not Installed or registry not set... %cReset%
	echo %cSoft%Script will now quit.%cReset%
	echo.
	SET EPICERROR=1
	goto exit
)
echo %mINFO%[1mUnreal Engine Version %UnrealVersion% is installed in: %cReset%
echo      - !pInstallDir!

REM CHECK IF GPU LIGHTMASS IS INSTALLED
IF EXIST !pInstallDir!\Engine\Binaries\Win64\GPULightmassKernel.dll (
	ECHO %mINFO%%cGREEN%GPU Lightmass is Installed%cReset%
	SET NOTINSTALLED=0
) ELSE (
	ECHO %mINFO%%cRED%GPU Lightmass is NOT Installed%cReset%
	SET NOTINSTALLED=1
)

REM CHECK FOR BACKUP
IF EXIST CPULightmass-%UnrealVersion%.zip (
	ECHO %mINFO%%cGREEN%CPU Lightmass is BACKED UP%cReset%
	SET BACKED=1
	REM GOTO MENU
) ELSE (
	ECHO %mWARN%%cRED%CPU Lightmass is NOT BACKED UP%cReset%
	SET BACKED=0
	CALL :BACKUP
)

REM CHECK FOR SETUP FILES
IF NOT EXIST GPULightmassIntegration-4.20.1-FastPreview.zip (
	ECHO Downloading GPU Lightmass, this can take a while. Please wait...
	powershell -Command "Invoke-WebRequest %uGPULightmass% -OutFile %UnrealVersion%.zip"
	powershell -Command "Expand-Archive -LiteralPath %UnrealVersion%.zip -DestinationPath ."
	IF !ERRORLEVEL! EQU 0 (del %UnrealVersion%.zip /q) ELSE (ECHO %mERROR%%cRED%ERROR DOWNLOADING. ERRORLEVEL: !ERRORLEVEL!%cReset%)
	echo.
	IF EXIST GPULightmassIntegration-4.20.1-FastPreview.zip (ECHO %mINFO%DOWNLOAD COMPLETE.) ELSE (ECHO %mERROR%%cRED%DOWNLOAD ERROR.%cReset%)
) ELSE (
	ECHO %mINFO%%cGREEN%GPULightmass is already downloaded.%cReset%
)
EXIT /B 0

:CHECKRUNNING
REM DETECT IF UNREAL IS RUNNING
tasklist /FI "IMAGENAME eq UE4Editor.exe" | find /I /N "UE4Editor.exe">NUL
if !ERRORLEVEL! EQU 0 (
echo %mWARN%Unreal Editor is running. GPU INSTALL NOT POSSIBLE if not installed already.
SET RUNNING=1
) ELSE (
echo %mINFO%%cGREEN%Unreal Editor is NOT running. *GOOD*%cReset%
)
EXIT /B 0

:BACKUP
ECHO Lightmass backup procedure in progress...
ECHO.
IF EXIST !pInstallDir!\Engine\Binaries\DotNET\ProgressReporter.exe (
	ECHO.
	ECHO %mERROR%%cRED%GPU Lightmass is installed. Clean backup not possible.%cReset%
	ECHO.
	CHOICE /m "Do you want to force backup anyway? (Useful if you just updated Unreal and had GPULightmass installed)."
	IF !ERRORLEVEL! EQU 1 GOTO :FORCED
	ECHO %mERROR%%cRED%User canceled, skiping backup%cReset%
	EXIT /B
)
GOTO :BACKINGUP
:FORCED
ECHO Performing FORCED BACKUP...
:BACKINGUP
ECHO.
ECHO %mINFO%%cSoft%Performing Lightmass BACKUP%cReset%
set InstallVersion=CPULightmass-%UnrealVersion%.zip
if exist listfile.txt del listfile.txt /Q
echo !pInstallDir!\Engine\Config\BaseLightmass.ini >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-SwarmInterface.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass.exe >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-ApplicationCore.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-BuildSettings.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Core.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-CoreUObject.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Json.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Messaging.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Networking.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Projects.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-SandboxFile.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Serialization.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UnrealLightmass-Sockets.dll >> listfile.txt
echo !pInstallDir!\Engine\Binaries\Win64\UE4Editor-UnrealEd.dll >> listfile.txt
7za a %InstallVersion% @listfile.txt
del listfile.txt /Q

set datestr=%date:~10,4%-%date:~7,2%-%date:~4,2%
Set backupfile=Lightmass-Backup-%UnrealVersion%-%datestr%.zip

IF EXIST !backupfile! (
	ECHO.
	ECHO %mWARN%%cRED%There is currently a !backupfile! file in the current folder.%cReset%
	ECHO.
	ECHO This is optional. You can still recover CPU Lightmass from !InstallVersion!
	ECHO.
	CHOICE /c yn /m "Do you want to overrite your current Lightmass Backup?"
	IF !ERRORLEVEL! NEQ 1 EXIT /B 1
)
copy !InstallVersion! !backupfile!
EXIT /B

:MENU
REM TO DO: CHECK VERSION Installed
REM FOR /F "skip=1 delims=" %%a IN ('certutil -hashfile "!pInstallDir!\Engine\Binaries\Win64\GPULightmassKernel.dll" MD5') DO (SET _HASH=%%a)
REM ECHO %_HASH%
ECHO.
ECHO Choose the Lightmass version you would like to install:
ECHO ------------------------------------------------------
ECHO.
IF !RUNNING! NEQ 1 (ECHO %cSoft%0 - Backup Current Lightmass%cReset%) ELSE (ECHO %mWARN%%cSoft%CPU LIGHTMASS Cannot be backup while UnrealEd is running [DISABLED]%cReset%)
IF !RUNNING! NEQ 1 (ECHO 1 - RESTORE CPU Lightmass) ELSE (ECHO %mWARN%%cSoft%CPU LIGHTMASS Cannot be restored until UnrealEd is closed [DISABLED]%cReset%)
ECHO [97m2 - GPU Lightmass Fast Preview
ECHO 3 - GPU Lightmass Medium Quality
ECHO 4 - GPU Lightmass Ultra High Quality
ECHO 5 - GPU Lightmass Extreme Quality[0m
ECHO [93m6 - EXIT[0m
ECHO.
CHOICE /C:0123456 /M "Choose your option"
IF !ERRORLEVEL! EQU 1 CALL :BACKUP && GOTO :MENU
IF !ERRORLEVEL! EQU 2 CALL :CPU && GOTO :MENU
IF !ERRORLEVEL! EQU 3 CALL :Fast && GOTO :MENU
IF !ERRORLEVEL! EQU 4 CALL :Medium && GOTO :MENU
IF !ERRORLEVEL! EQU 5 CALL :UltraHigh && GOTO :MENU
IF !ERRORLEVEL! EQU 6 CALL :Extreme && GOTO :MENU
IF !ERRORLEVEL! EQU 7 GOTO :EOF

GOTO :MENU

:CPU
ECHO CPU Lightmass Install
ECHO.
IF EXIST set CPULightmass-%UnrealVersion%.zip (
	ECHO Cleaning up %UnrealVersion% of old GPU Lightmass Files
	SET InstallVersion=CPULightmass-%UnrealVersion%.zip
	del "!pInstallDir!\Engine\Binaries\DotNET\ProgressReporter.exe"
	del "!pInstallDir!\Engine\Binaries\Win64\GPULightmassKernel.dll"
	GOTO INSTALL
)
ECHO %mERROR%%cRED%Can't find %InstallVersion%. CPU Lightmass won't be restored.%cReset%
EXIT /B

:Fast
Set InstallVersion=%pFastPreview% 
GOTO INSTALL

:Medium
Set InstallVersion=%pMedium%
GOTO INSTALL

:UltraHigh
Set InstallVersion=%pUltraHigh%
GOTO INSTALL

:Extreme
set InstallVersion=%pExtreme%
GOTO INSTALL

:INSTALL
IF !NOTINSTALLED! EQU 1 (
	IF !RUNNING! EQU 1 (
		GOTO :WONTINSTALL
	) ELSE (
		ECHO GPU Lightmass Install, version: !InstallVersion!
		ECHO.
	)
) ELSE (
	IF !RUNNING! EQU 1 (
		ECHO SWITCHING GPU VERSION: !InstallVersion!
		ECHO.
	) ELSE (
		ECHO GPU Lightmass Install, version: !InstallVersion!
	)
)
IF EXIST !InstallVersion! (7za x !InstallVersion! -o"!pInstallDir!" -y -r) ELSE (ECHO %mERROR%Can't find !InstallVersion!)
EXIT /B

:TDRDELAY
FOR /F "tokens=2*" %%A IN ('REG.exe query "%KEY_NAME_TDR%" /v "%VALUE_NAME_TDR%" 2^>nul') DO (set /a iTdrDelay=%%B)
IF NOT DEFINED iTdrDelay (
	ECHO %mWARN%%cRED%TDR Delay settings not found%cReset%
	ECHO.
	ECHO It is recommended to change Windows Timeout Detection and Recovery settings to prevent 
	ECHO        the GPU from being timed out under heavy workload: e.g.: unspecified launch failure and other Error crashes
	ECHO.
	CHOICE /m "Do you want to set your TDR setting to %iTDRValue% (recommended)?"
	IF !ERRORLEVEL! EQU 1 CALL :TDRSet
) else (
	Echo %mINFO%%cGREEN%Your TdrDelay is set to !iTdrDelay! *GOOD*%cReset%
)
Exit /B

:TDRSet
ECHO.
REG ADD %KEY_NAME_TDR% /v %VALUE_NAME_TDR% /t REG_DWORD /d %iTDRValue%
if %ERRORLEVEL% EQU 0 ECHO %mWARN%%cGREEN%TDR Settings added successfully. %cRED%Please restart or log-off for changes to take effect%cReset%
Exit /B

:WONTINSTALL
ECHO %mERROR%%cRED%Can't install GPU if Unreal is running. Quit Unreal and install.%cReset%
EXIT /B 1

:EXIT
ECHO.
ECHO ALL DONE. Have a good day!
TIMEOUT 3 >nul
EXIT /B 0
