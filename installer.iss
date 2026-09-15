[Setup]
AppName=ARKAS SD Zaha
AppVersion=1.0.0
DefaultDirName={autopf}\ARKAS SD Zaha
DefaultGroupName=ARKAS SD Zaha
OutputDir=dist
OutputBaseFilename=arkas-sd-zaha Setup 1.0.0
SetupIconFile=assets\app_icon.ico
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\ARKAS SD Zaha"; Filename: "{app}\arkas_sd_zaha.exe"
Name: "{autodesktop}\ARKAS SD Zaha"; Filename: "{app}\arkas_sd_zaha.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked