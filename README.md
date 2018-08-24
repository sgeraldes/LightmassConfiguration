# LightmassConfiguration
LightmassConfiguration is a script made for Unreal Engina 4 to allow to change from Unreal's CPU Lightmass to GPU Lightmass (made by Luoshuang for the Unreal Forums) and back. Since there are no options in GPU Lightmass, the script also allows anyone to change bake quality levels without the need to even restart Unreal Editor. 

# Usage
To use:
- Simply download LightmassConfiguration.zip and decompress the .bat file to any folder (empty is better)
- Double-click it, it will ask for admin permissions and do the rest, prompting you each step of the way

# Background and use case
I had to install GPU lightmass 4.20.1 on more than 10 computers, so I made a script that will perform a batch of checks and allow to change from GPU bake quality without the need to restart Unreal. It will also check quite a few other things. Hope it helps someone.

It currently works with Unreal Engine 4.20, but can easily adapted for 4.19.x if needed.

# Requirements
- Windows 10 (not tested in earlier versions, may work but no guarantees)
- Admin privileges

# Features
The script has the following features:

    Show you the version of Nvidia drivers running (and any other display driver that's running, i.e.: Intel HD)
    Check if you have TDR settings as recommended, IF NOT: the script will ask you to do the changes for you (optional)
    Allows changing GPU Lightmass quality settings (fast preview, medium, high-ultra, extreme) without needing to restart unreal.
    Backup CPU lightmass for you and give you the option to go restore it later
    It will override BaseLightmass.ini on your Unreal folder (it will first backup in the zip archive the version you have and allow to restore at will).
    Checks if GPU Lightmass is installed, if not...
        Download the latest version of GPU Lightmass for you from Luoshuang's links
        Download 7Z.exe to quickly backup and perform decompression of the files in the archives
        Finds the installation directory of Unreal, and unzip the files there according to the quality you select (will prompt you for it)
    If UnrealEd is running, the script will disable the option to change GPU and CPU lightmass as it needs to access files that are in use to do so.

Please note: The script will give an error while copying when trying to change the quality settings with Unreal Ed running. That's perfectly fine, the file is just been copied over to be sure it remains the same. I guess I could just copy GPULightmassKernel.dll instead of the whole bunch, but I just think it works as-is just fine. The copy of a single will fail but GPU Lightmass will work the same.

Also note: the script can't change from CPU to GPU lightmass while the Unreal Editor is running, so the script will check for that and disable the option accordingly.

The only file that has the changes for quality, and the only file that is in any way different between the different packs, is GPULightmassKernel.dll (I did a binary compare of each file to be sure).

# Updates
UPDATE 08/23/2018 v0.2: Modified to allow easier updates of the engine. Fixed some bugs. better detection of some parameters and added a fail-safe in case it fails.TDR settings now in decimal instead of hexa.
UPDATE 08/23/2018 v0.2.1: The script now actually checks for driver version and warns the user if the driver does not meet the requirement. 
