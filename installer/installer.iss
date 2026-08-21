#ifndef MyAppVersion
  #define MyAppVersion "dev"
#endif
#ifndef Variant
  #define Variant "nvidia"
#endif

#define MyAppName "Auto Target Encoder"
#define MyAppPublisher "Johnnycyan"
#define MyAppExeName "AutoTargetEncoder.exe"

[Setup]
AppId={{B6C1A2C3-9D0A-4B1E-9A2F-AUTOTARGETENC}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={localappdata}\Programs\AutoTargetEncoder
DefaultGroupName=Auto Target Encoder
DisableProgramGroupPage=yes
; Per-user install: no admin rights needed, nothing touches system-wide
; Python, ffmpeg, or PATH.
PrivilegesRequired=lowest
OutputDir=..\installer\output
OutputBaseFilename=AutoTargetEncoder-Setup-{#Variant}-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
Source: "staging\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Auto Target Encoder"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Uninstall Auto Target Encoder"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Auto Target Encoder"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch Auto Target Encoder"; Flags: nowait postinstall skipifsilent

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
var
  AppDir, ConfigDefault, ConfigTarget: String;
  Lines: TArrayOfString;
  I: Integer;
begin
  if CurStep = ssPostInstall then
  begin
    AppDir := ExpandConstant('{app}');
    ForceDirectories(AppDir + '\data');

    ConfigDefault := AppDir + '\config.ini.default';
    ConfigTarget := AppDir + '\config.ini';

    // Only generate config.ini if it doesn't already exist, so upgrades
    // never clobber a user's saved settings.
    if not FileExists(ConfigTarget) then
    begin
      if LoadStringsFromFile(ConfigDefault, Lines) then
      begin
        for I := 0 to GetArrayLength(Lines) - 1 do
        begin
          StringChangeEx(Lines[I], '{{FFMPEG}}',  AppDir + '\bin\ffmpeg.exe', True);
          StringChangeEx(Lines[I], '{{FFPROBE}}', AppDir + '\bin\ffprobe.exe', True);
          StringChangeEx(Lines[I], '{{FFVSHIP}}', AppDir + '\bin\FFVship\ffvship.exe', True);
          StringChangeEx(Lines[I], '{{DBPATH}}',  AppDir + '\data\database.db', True);
          StringChangeEx(Lines[I], '{{LOGPATH}}', AppDir + '\data\encoding_log.txt', True);
        end;
        SaveStringsToFile(ConfigTarget, Lines, False);
      end;
    end;
  end;
end;
