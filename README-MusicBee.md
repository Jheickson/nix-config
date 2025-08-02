# MusicBee on NixOS with Wine

This guide explains how to set up and use MusicBee on NixOS using Wine.

## Prerequisites

After rebuilding your NixOS configuration, you'll have Wine and related tools installed:

- Wine (full version with WoW64 support)
- Winetricks (for installing Windows dependencies)
- Bottles (GUI Wine prefix manager)

## Installing MusicBee

1. **Download MusicBee**:

   - Visit https://getmusicbee.com/downloads/ and download the Windows installer
   - Save the installer to your Downloads folder

2. **Set up Wine prefix** (optional but recommended):

   ```bash
   # Create a dedicated Wine prefix for MusicBee
   export WINEPREFIX=$HOME/.wine-musicbee
   winecfg
   ```

3. **Install MusicBee**:

   ```bash
   # Navigate to your Downloads folder
   cd ~/Downloads

   # Install MusicBee using Wine
   export WINEPREFIX=$HOME/.wine-musicbee
   wine MusicBeeSetup_*.exe
   ```

4. **Install required dependencies** (if needed):
   ```bash
   # Install .NET Framework and other dependencies
   export WINEPREFIX=$HOME/.wine-musicbee
   winetricks dotnet48 corefonts
   ```

## Running MusicBee

After installation, you can run MusicBee in several ways:

1. **From terminal**:

   ```bash
   export WINEPREFIX=$HOME/.wine-musicbee
   wine "$WINEPREFIX/drive_c/Program Files/MusicBee/MusicBee.exe"
   ```

2. **Create a desktop entry** (optional):
   Create a file at `~/.local/share/applications/musicbee.desktop`:
   ```ini
   [Desktop Entry]
   Name=MusicBee
   Comment=Music management and player
   Exec=env WINEPREFIX="/home/felipe/.wine-musicbee" wine "/home/felipe/.wine-musicbee/drive_c/Program Files/MusicBee/MusicBee.exe"
   Icon=/home/felipe/.wine-musicbee/drive_c/Program Files/MusicBee/Resources/Icons/MusicBee.ico
   Terminal=false
   Type=Application
   Categories=AudioVideo;Player;
   ```

## Using Bottles (Alternative Method)

1. Open Bottles from your application menu
2. Create a new bottle with the following settings:
   - Name: MusicBee
   - Environment: Application
   - Architecture: win64
3. Once created, click "Run executable" and select the MusicBee installer
4. After installation, you can launch MusicBee directly from Bottles

## MusicBee Features

The following features you requested should work with this setup:

- **Ratings**: Fully functional
- **Auto-DJ**: Fully functional
- **Lyrics**: Fully functional (may require online access)
- **Export music to phone**: Fully functional

## Troubleshooting

If you encounter issues:

1. **Audio problems**:

   - Ensure PipeWire is properly configured
   - Check audio settings in Wine configuration

2. **Missing fonts or UI issues**:

   ```bash
   export WINEPREFIX=$HOME/.wine-musicbee
   winetricks corefonts
   ```

3. **Performance issues**:

   - In Wine configuration, set Windows version to Windows 10
   - Disable unnecessary visual effects in Wine

4. **Library import issues**:
   - Make sure your music library is accessible from Wine (use drive mappings if needed)

## Rebuilding Your System

After making these changes to your NixOS configuration, rebuild your system:

```bash
sudo nixos-rebuild switch
```

Then follow the installation steps above to complete the MusicBee setup.
