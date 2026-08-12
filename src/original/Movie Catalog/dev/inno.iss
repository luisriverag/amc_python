; Innosetup 5.4.2

#define DirDataName "Ant Movie Catalog"

[Setup]
AppName=Ant Movie Catalog
AppVerName=Ant Movie Catalog 4.2.3.3
AppCopyright=Copyright © 2000-2025 Antoine Potten, Mickaël Vanneufville
AppPublisher=Ant Software
AppPublisherURL=http://www.antp.be/software/
AppUpdatesURL=http://www.antp.be/software/moviecatalog/download/
AppVersion=4.2.3.3
AppId=Ant Movie Catalog

DefaultDirName={pf}\Ant Movie Catalog
DefaultGroupName=Ant Movie Catalog

LicenseFile=license.txt
InfoBeforeFile=readme.txt

OutputBaseFilename=amc_install
ChangesAssociations=true
UninstallDisplayName=Ant Movie Catalog
AllowNoIcons=true

Compression=lzma
SolidCompression=yes

[Code]
var
  DataDir: String;
  DocsDir: String;
  UseDataDir: Boolean;
  AppVirtualDir: String;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  Ver: Cardinal;
  VerMajor, VerMinor, BuildNum: Cardinal;
  s: string;
begin
  Result := True;
  if CurPageID = wpSelectDir then
  begin
    Ver := GetWindowsVersion();
    VerMajor := Ver shr 24;
    VerMinor := (Ver shr 16) and $FF;
    BuildNum := Ver and $FFFF;
    UseDataDir := (VerMajor >= 5) and (not (FileExists(ExpandConstant('{app}') + '\default.xml') or FileExists(ExpandConstant('{app}') + '\prefs.xml')));
    if UseDataDir then
    begin
      DataDir := ExpandConstant('{commonappdata}') + '\' + ExpandConstant('{#DirDataName}')
      DocsDir := ExpandConstant('{userdocs}');
    end
    else
    begin
      DataDir := ExpandConstant('{app}');
      DocsDir := ExpandConstant('{app}');
    end;
    s := ExpandConstant('{app}');
    s := ExtractRelativePath(ExtractFileDrive(s), s);
    AppVirtualDir := ExpandConstant('{localappdata}') + '\VirtualStore\' + s;
  end;
end;

function GetUseDataDir: Boolean;
begin
  Result := UseDataDir;
end;

function GetDataDir(Default: String): String;
begin
  Result := DataDir;
end;

function GetDocsDir(Default: String): String;
begin
  Result := DocsDir;
end;

function GetAppVirtualDir(Default: String): String;
begin
  Result := AppVirtualDir;
end;

[Dirs]
Name: "{commonappdata}\{#DirDataName}"; Permissions: users-modify; Check: GetUseDataDir

[Files]
Source: "MovieCatalog.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "AMCReport.exe"; DestDir: "{app}"; Flags: ignoreversion; Components: PrintTemplates
Source: "AMCExchange.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "MediaInfo.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "libeay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "ssleay32.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "unicows.dll"; DestDir: "{app}"; Flags: ignoreversion; MinVersion: 4.0,0
Source: "license.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "readme.txt"; DestDir: "{app}"; Flags: ignoreversion

Source: "Toolbars\*.bmp"; DestDir: "{app}\Toolbars"; Flags: ignoreversion
Source: "Languages\*.*"; Excludes: "English.*"; DestDir: "{app}\Languages"; Flags: ignoreversion; Components: Lang
Source: "Languages\English.*"; DestDir: "{app}\Languages"; Flags: ignoreversion
Source: "FRUSER.CNT"; DestDir: "{app}"; Flags: ignoreversion; Components: PrintTemplates
Source: "FRUSER.HLP"; DestDir: "{app}"; Flags: ignoreversion; Components: PrintTemplates
Source: "FRUSER.PDF"; DestDir: "{app}"; Flags: ignoreversion; Components: PrintTemplates; MinVersion: 0,10.0

Source: "default.xml"; DestDir: "{code:GetDataDir}"; Flags: onlyifdoesntexist
Source: "Codecs.ini"; DestDir: "{code:GetDataDir}"; Flags: onlyifdoesntexist

Source: "Templates\*.gif"; DestDir: "{code:GetDataDir}\Templates"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\*.png"; DestDir: "{code:GetDataDir}\Templates"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\*.htm*"; DestDir: "{code:GetDataDir}\Templates"; Flags: onlyifdoesntexist; Components: HtmlTemplates
Source: "Templates\*.txt"; DestDir: "{code:GetDataDir}\Templates"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\*.zip"; DestDir: "{code:GetDataDir}\Templates"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\dvd_fr_light\*.*"; DestDir: "{code:GetDataDir}\Templates\dvd_fr_light"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\Indigo\*.*"; DestDir: "{code:GetDataDir}\Templates\Indigo"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\RedLine\*.*"; DestDir: "{code:GetDataDir}\Templates\RedLine"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\BlueBasic\*.*"; DestDir: "{code:GetDataDir}\Templates\BlueBasic"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\Rainbow Seagull\*.*"; DestDir: "{code:GetDataDir}\Templates\Rainbow Seagull"; Flags: ignoreversion; Components: HtmlTemplates
Source: "Templates\*.frf"; DestDir: "{code:GetDataDir}\Templates"; Flags: onlyifdoesntexist; Components: PrintTemplates

Source: "Scripts\*.*"; DestDir: "{code:GetDataDir}\Scripts"; Flags: ignoreversion; Components: Scripts

Source: "Catalogs\Sample_3.5.1.amc"; DestDir: "{code:GetDocsDir}\Catalogs"
Source: "Catalogs\Sample_4.2.0.amc"; DestDir: "{code:GetDocsDir}\Catalogs"

[Registry]
Root: HKCR; Subkey: .amc; ValueType: string; ValueData: Ant Movie Catalog; Flags: uninsdeletekey
Root: HKCR; Subkey: Ant Movie Catalog; ValueType: string; ValueData: Ant Movie Catalog; Flags: uninsdeletekey
Root: HKCR; Subkey: Ant Movie Catalog\Shell\Open\Command; ValueType: string; ValueData: """{app}\moviecatalog.exe"" ""%1"""; Flags: uninsdeletevalue
Root: HKCR; Subkey: Ant Movie Catalog\DefaultIcon; ValueType: string; ValueData: {app}\moviecatalog.exe,1; Flags: uninsdeletevalue

[Icons]
Name: "{group}\Ant Movie Catalog"; Filename: "{app}\moviecatalog.exe"; WorkingDir: "{app}"
Name: "{group}\Report Designer"; Filename: "{app}\amcreport.exe"; Parameters: """{code:GetDataDir}\AMCReport.ini"""; WorkingDir: "{app}"; Flags: createonlyiffileexists
;Name: "{group}\Uninstall Ant Movie Catalog"; Filename: "{uninstallexe}"; WorkingDir: "{app}"
Name: "{app}\Link to data files (prefs, scripts, templates)"; FileName: "{code:GetDataDir}"; Check: GetUseDataDir

[InstallDelete]
Type: files; Name: "{app}\Toolbars\Classic.bmp"
Type: files; Name: "{app}\Toolbars\Kids.bmp"
Type: files; Name: "{code:GetAppVirtualDir}\prefs.xml"; Check: GetUseDataDir; MinVersion: 0,6.0
Type: files; Name: "{code:GetAppVirtualDir}\default.xml"; Check: GetUseDataDir; MinVersion: 0,6.0

[UninstallDelete]
Type: dirifempty; Name: "{app}\Languages"
Type: dirifempty; Name: "{app}\Toolbars"
Type: dirifempty; Name: "{code:GetDataDir}\Templates"
Type: dirifempty; Name: "{code:GetDataDir}\Scripts"
Type: dirifempty; Name: "{code:GetDocsDir}\Catalogs"
Type: files; Name: "{code:GetDataDir}\prefs.xml"
Type: files; Name: "{code:GetDataDir}\scripts.ini"
Type: files; Name: "{code:GetDataDir}\AMCReport.ini"
Type: files; Name: "{code:GetDataDir}\scan.log"
Type: files; Name: "{app}\AMCReport.ini"
Type: files; Name: "{app}\FRUSER.GID"
Type: dirifempty; Name: "{code:GetDataDir}"; Check: GetUseDataDir
Type: dirifempty; Name: "{app}"

[Components]
Name: Lang; Description: Language files (translations); Types: custom full
Name: Scripts; Description: Scripts; Types: custom full
Name: PrintTemplates; Description: Printing templates & report designer; Types: custom full
Name: HtmlTemplates; Description: HTML export templates; Types: custom full

