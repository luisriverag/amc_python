(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2017 Antoine Potten, Mickaël Vanneufville                 *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   This program is free software; you can redistribute it and/or      *
 *   modify it under the terms of the GNU General Public License        *
 *   as published by the Free Software Foundation; either version 2     *
 *   of the License, or (at your option) any later version.             *
 *                                                                      *
 *   This program is distributed in the hope that it will be useful,    *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *
 *   GNU General Public License for more details.                       *
 *                                                                      *
 ************************************************************************)

unit ProgramSettings;

interface

uses
  Classes, Controls, Graphics, IniFiles, Dialogs,

  JvSimpleXml,

  ConstValues, fields, MovieClass, functions_files;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type

TComboOptions = record
  Contents:             TStringList;
  AutoAdd:              Boolean;
  Sort:                 Boolean;
  AutoComplete:         Boolean;
  UseCatalogValues:     Boolean;
end;

TFileNaming = class(TObject)
  public
    Prefix:               Integer; // 0 = No, 1 = Catalog name, 2 = Save filename
    Separator1:           string;  // '_' by dfault
    MovieFieldName:       string;  // '' = nothing, '*OriginalFileName*' = original picture name
    MovieNumberAddZeroes: Boolean; // Add zeroes in front of the number for low numbers
    // if MovieFieldName = '*OriginalFileName*' then what it is below is not used
    Separator2:           string;  // '_' by default
    ExtraFieldName:       string;  // '' = nothing
    ExtraNumberAddZeroes: Boolean; // Add zeroes in front of the number for low numbers

    procedure Load(Root: TJvSimpleXmlElem; const DefaultPrefix: Integer = 1);
    procedure Save(Items: TJvSimpleXmlElems);
    function  GetFileName(const CatalogFileName: string = ''; const SaveFileName: string = '';
      const OriginalFileName: string = ''; const FileExt: string = '';
      const AMovie: TMovie = nil; const AExtra: TMovieExtra = nil;
      const MaxMovieNumber: Integer = 99999; const MaxExtraNumber: Integer = 9999): string;
end;

TImportCommonSettings = class(TObject)
  public
    Fields:             TStringList;
    KeyField:           string;
    AutoLoadFields:     Boolean;
    AutoResizeColumns:  Boolean;

    constructor Create;
    destructor  Destroy; override;
    procedure   Load(Root: TJvSimpleXmlElem);
    procedure   Save(Items: TJvSimpleXmlElems);
end;

TFolder = class(TObject)
  private
    Path:       string;
    PathType:   Integer;
    procedure   UpdateFolder(const newPath: string);
    function    ReturnPath: string;
  public
    DefaultPath: string;
    constructor Create;
    destructor  Destroy; override;
    property    FolderType: integer read PathType;
    property    Value: string read ReturnPath write UpdateFolder;
    property    ValueRaw: string read Path;
    procedure   SetFolder(const newPath: string; const newType: Integer);
    procedure   Load(Root: TJvSimpleXmlElem; nr: Integer); overload;
    procedure   Load(ini: TMemIniFile; nr: Integer); overload;
    procedure   Save(Items: TJvSimpleXmlElems; const nr: Integer);
end;

TSettings = class(TObject)
  private
    FXml:                       TJvSimpleXml;
    FLanguage:                  string;
  public
    intVersion:                 Integer;
    version:                    string;
    rDataFolders:             record
      DirToolbars :             string;
      DirLanguages :            string;
      DirTemplates :            string;
      DirScripts :              string;
      DirCatalogs :             string;
    end;
    rMain:                    record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      WindowLeft:               Integer;
      WindowTop:                Integer;
      Statusbar:                Boolean;
      ListWidth:                Integer;
      GridMode:                 Boolean;
      ListAlClient:             Boolean;
      DisplayHTML:              Boolean;
      DisplayThumbnails:        Boolean;
      ThumbnailsSize:           Integer;
      ThumbnailsDisplayTitle:   Boolean;
      ExtrasThumbsSize:         Integer;
      ExtrasThumbsDisplayTitle: Boolean;
      ExtrasThumbsDisplayInfo:  Boolean;
      MovieInfosTabIndex:       Integer;
      MovieInfosBothWidth:      Integer;
      MovieInfosHideMediaFields:Boolean;
      MovieInfosHideVideoFields:Boolean;
      PictureDockedHeight:      Integer;
      ExtrasDockedWidth:        Integer;
      MRU:                      TStringList;
      FindWholeField:           Boolean;
      FindReverse:              Boolean;
      FindFieldName:            string;
      SortFieldName:            string;
      GroupFieldName:           string;
      ExtrasSortFieldName:      string;
      ExtrasGroupFieldName:     string;
      GroupsFormatOption:       Integer;
      GroupsFormatRoundType:    Integer;
      ColumnSettings:           string;
      SortAdvancedFields:       TStringList;
      ExtrasSortAdvancedFields: TStringList;
      PasteDeselectedFields:    TStringList;
      Toolbars:                 TJvSimpleXmlElem;
      PictureWinLeft:           Integer;
      PictureWinTop:            Integer;
    end;
    rExport:                  record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      OrderBy:                  Integer;
      OrderDescend:             Boolean;
      OrderFields:              TStringList;
      Includemov:               Integer;
      CSVDelimiter:             string;
      CSVDelimExtras:           string;
      CSVBloc:                  string;
      CSVLinebreaks:            string;
      CSVColumnTitles:          Boolean;
      CSVFields:                TStringList;
      SQLUpdate:                Boolean;
      SQLDrop:                  Boolean;
      SQLCreate:                Boolean;
      SQLFields:                TStringList;
      SQLTableName:             string;
      SQLTableNameExtras:       string;
      SQLLinebreaks:            string;
      HTMLLastTemplate:         string;
      HTMLLastTemplate2:        string;
      HTMLMRU:                  TStringList;
      PictureNaming:            TFileNaming;
      ExportBoth:               Boolean;
    end;
    rImport:                  record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      AllowDup:                 Boolean;
      AllowClear:               Boolean;
      AutoAssign:               Boolean;
      PicImport:                Integer;
      ExtraPicImport:           Integer;
      rCsv:                   record
        Delim:                  string;
        DelimExtras:            string;
        Quote:                  string;
        FirstLineHeaders:       Boolean;
        Linebreaks:             string;
        rCommon:                TImportCommonSettings;
      end;
      rAmc:                   record
        rCommon:                TImportCommonSettings;
      end;
      rQuery:                 record
        From:                   string;
        Where:                  string;
        rCommon:                TImportCommonSettings;
      end;
      rDvp:                   record
        rCommon:                TImportCommonSettings;
      end;
      rGcs:                   record
        rCommon:                TImportCommonSettings;
      end;
      rDir:                   record
        MultiDisks:             Boolean;
        DiskTag:                string;
        BrowseDepth:            string;
        ExtractProcess:         Integer;
        rCommon:                TImportCommonSettings;
      end;
      LastFiles:                TStringList;
    end;                     
    rPrint:                   record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      OrderBy:                  Integer;
      OrderDescend:             Boolean;
      OrderFields:              TStringList;
      Includemov:               Integer;
      ReportsListWidth:         Integer;
    end;                     
    rScripts:                 record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      ScriptMRU:                TStringList;
      ScriptRemember1:          string;
      ScriptRemember2:          string;
      Includemov:               Integer;
      LangFilterExcl:           string;
      ListViewStyle:            Integer;
      ShowResGetInfo:           Boolean;
      ShowResScripting:         Boolean;
      CloseWinGetInfo:          Boolean;
      CloseWinScripting:        Boolean;
      AllowClearGetInfo:        Boolean;
      AllowClearScripting:      Boolean;
      rProperties:            record
        WindowWidth:            Integer;
        WindowHeight:           Integer;
      end;
      rResults:               record
        WindowState:            Integer;
        WindowWidth:            Integer;
        WindowHeight:           Integer;
      end;
      rExtrasResults:         record
        WindowState:            Integer;
        WindowWidth:            Integer;
        WindowHeight:           Integer;
      end;
      rPickList:              record
        WindowWidth:            Integer;
        WindowHeight:           Integer;
      end;                    
      rPickTree:              record
        WindowWidth:            Integer;
        WindowHeight:           Integer;
      end;                    
      Toolbars:                 TJvSimpleXmlElem;
    end;                      
    rLoan:                    record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      LvMoviesHeight:           Integer;
      LvMoviesColWidth:         Integer;
      LvMoviesSort:             Integer;
      LvNamesWidth:             Integer;
      LvNamesSort:              Integer;
      LvLentSort:               Integer;
      IncludeSameNum:           Boolean;
      IncludeSameLabel:         Boolean;
    end;                      
    rProperties:              record
      WindowWidth:              Integer;
      WindowHeight:             Integer;
    end;                      
    rStatistics:              record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      EmptyMonths:              Boolean;
      Legend:                   Boolean;
      Labels:                   Boolean;
      Group:                    Boolean;
      Includemov:               Integer;
    end;                      
    rRenumber:                record
      OrderBy:                  Integer;
      OrderDescend:             Boolean;
      OrderFields:              TStringList;
    end;
    rRenumberExtras:          record
      OrderBy:                  Integer;
      OrderDescend:             Boolean;
      OrderFields:              TStringList;
    end;
    rOptions:                 record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      rDisplay:               record
        ImagesInMenu:           Boolean;
        OfficeXP:               Boolean;
        IconSet:                string;
        ColorType:              Integer;
        Logo:                   Boolean;
        SoftBorders:            Boolean;
        NaturalCompare:         Boolean;
        ScrollUnderPointer:     Boolean;
        AutoFocus:              Boolean;
        ForceRefresh:           Boolean;
      end;                    
      rFiles:                 record
//        XMLHeader:              string;
        Backup:                 Boolean;
        RecentFiles:            Integer;
        AutoLoad:               Boolean;
        AutoLoadFile:           string;
        AutoLoadLast:           Boolean;
        AutoLoadCF:             Boolean;
        AutoLoadCFFile:         string;
        History:                Boolean;
        HistoryFile:            string;
        HTMLTemplateFile:       string;
      end;
      rMovieList:             record
        TitleColumn:            Integer;
        UsePrefixes:            Boolean;
        Prefixes:               TStringList;
        TitleTemplate:          string;
        ConfirmDelete:          Boolean;
        ConfirmUndo:            Boolean;
        Checkboxes:             Boolean;
        CheckboxesInThumbs:     Boolean;
        CheckboxesColor:        Boolean;
        LinesColor:             Boolean;
        HotTrack:               Boolean;
        EnhancedScrollbars:     Boolean;
        MovieNumColumn:         Boolean;
        GridTextSize:           Integer;
        AutoStretchListGrid:    Boolean;
        AutoStretchListThumbs:  Boolean;
        ShortcutPrev:           TShortcut;
        ShortcutNext:           TShortcut;
        GroupCount:             Boolean;
        GroupExpand:            Boolean;
        GroupsAbove:            Boolean;
        GroupUnique:            Boolean;
        GroupMulti:             Boolean;
        GroupMultiSep:          Char;
        GroupMultiRmAllP:       Boolean;
        GroupMultiAddPatch:     Boolean;
        SortGroupsByCount:      Boolean;
        ColorsTag: array [0..Length(DefaultColorsTag)-1] of TColor;
      end;
      rExtraList:             record
        ConfirmDelete:          Boolean;
        Checkboxes:             Boolean;
        NumWithTitle:           Boolean;
        InfoWhenNoPic:          Boolean;
        CellBorders:            Boolean;
        GroupCount:             Boolean;
        GroupExpand:            Boolean;
        GroupsAbove:            Boolean;
        GroupMulti:             Boolean;
        GroupMultiSep:          Char;
        GroupMultiRmAllP:       Boolean;
        SortGroupsByCount:      Boolean;
        ActionDoubleClick:      Integer;
        ActionKeyReturn:        Integer;
      end;
      rMovieInformation:      record
        AskNumber:              Boolean;
        FirstAvailable:         Boolean;
        AddScript:              Boolean;
        AddFiles:               Boolean;
        RatingTrunc:            Boolean;
        SetCurrentDate:         Boolean;
        PictureBackground:      Integer;
        PictureFitWindow:       Boolean;
        PictureInfo:            Boolean;
        MovieFrameBackground:   Integer;
        HTMLSearchFontTextColor:string;
        HTMLSearchBackTextColor:string;
        HTMLNoMoviePage:        string;
        ImportExt:              string;
        ImportAllowClear:       Boolean;
        ImportMediaLabel:       Boolean;
        ImportFileName:         Boolean;
        ImportFileInFilePath:   Boolean;
        ImportFileInURL:        Boolean;
        ImportSize:             Boolean;
        ImportSizeString:       Boolean;
        ImportSizeUnit:         TFileSizeUnit;
        ImportPicture:          Boolean;
        ImportInternalAVI:      Boolean;
        ImportLength:           Boolean;
        ImportResolution:       Boolean;
        ImportFramerate:        Boolean;
        ImportVideoCodec:       Boolean;
        ImportVideoBitrate:     Boolean;
        ImportAudioCodec:       Boolean;
        ImportAudioChannels:    Boolean;
        ImportAudioBitrate:     Boolean;
        ImportLanguages:        Boolean;
        ImportSubtitles:        Boolean;
        rPicImport:           record
          GetInfoMethod:        Integer;
          ScriptingMethod:      Integer;
          PicConvertJPG:        Boolean;
          MaxPicSizeW:          Integer;
          MaxPicSizeH:          Integer;
        end;
        rExtraPicImport:      record
          GetInfoMethod:        Integer;
          ScriptingMethod:      Integer;
          PicConvertJPG:        Boolean;
          MaxPicSizeW:          Integer;
          MaxPicSizeH:          Integer;
        end;
        PictureNaming:          TFileNaming;
        FilterFileName:         TStringList;
        PosterNames:            TStringList;
        SearchSites:            TStringList;
        ComboSameForAll:        Boolean;
        rCombo:                 array[0..ddlCount-1] of TComboOptions;
        rDefaultMovie:        record
          Values:               TMovie;
          WindowWidth:          Integer;
          WindowHeight:         Integer;
        end;
        rDefaultExtra:        record
          Values:               TMovieExtra;
          WindowWidth:          Integer;
          WindowHeight:         Integer;
        end;
      end;                    
      rScripting:             record
        ScriptAutorun:          Boolean;
        Proxy:                  Boolean;
        ProxyServer:            string;
        ProxyPort:              Integer;
        ProxyUsername:          string;
        ProxyPassword:          string;
        KeepConnection:         Boolean;
        HTTP10:                 Boolean;
      end;                    
      rExport:                record
        LoadTemplate:           Boolean;
        Linebreak:              string;
        ForcePicSizeW:          Integer;
        ForcePicSizeH:          Integer;
        ForceExtraPicSizeW:     Integer;
        ForceExtraPicSizeH:     Integer;
        SQLDate:                string;
        RememberLastFile:       Boolean;
        LastFile:               string;
        OpenExportedFile:       Boolean;
        ExpFileNaming:          TFileNaming;
        ExpFileExt:             string;
        CopyPictures:           Boolean;
        CopyPicturesInPicDir:   Boolean;
        CopyPicturesNew:        Boolean;
        CopyPicturesIncExtras:  Boolean;
        PicturesExportMethodAMC:      Integer;
        PicturesExportMethodXML:      Integer;
        ExtraPicturesExportMethodAMC: Integer;
        ExtraPicturesExportMethodXML: Integer;
        PicturesSaveXMLInPicDir:Boolean;
      end;
      rFolders:               array[0..9] of TFolder;
      SameFolderForAll:         Boolean;
      rLanguage:              record
        Language:               string;
      end;                    
    end;
    rCustomFieldsManager:     record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
    end;
    rStringFilter:            record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
    end;
    rHTMLEditor:              record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
      HTMLLastTemplate:         string;
      HTMLMRU:                  TStringList;
    end;
    rExtrasEdit:              record
      WindowState:              Integer;
      WindowWidth:              Integer;
      WindowHeight:             Integer;
    end;
    constructor   Create;
    destructor    Destroy; override;
    procedure     Load;
    procedure     Save;
    property      Language: string read FLanguage write FLanguage;
    function      GetLanguageFile: string;
    function      GetFilesSizeUnit(const ByteString: string): string;
end;

function GetCurItem(Root: TJvSimpleXmlElem; const ItemName: string): TJvSimpleXmlElem;
procedure LoadList(Items: TJvSimpleXmlElems; const PropName: string; List: TStrings;
  ConvertFieldTagToId: Boolean = False; KeepItemName: Boolean = False);

function PrepareItem(Items: TJvSimpleXmlElems; const AName: string): TJvSimpleXmlElem;
procedure SaveList(Items: TJvSimpleXmlElems; const SubItemName, PropName: string;
  List: TStrings; ConvertFieldIdToTag: Boolean = False);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Windows, Sysutils,

  tb2toolbar,

  functions_sys, functions_str, functions_xml, Global;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TImportCommonSettings.Create;
begin
  Fields := TStringList.Create();
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportCommonSettings.Destroy;
begin
  Fields.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportCommonSettings.Load(Root: TJvSimpleXmlElem);
begin
  Root := GetCurItem(Root, 'Fields');
  with Root do
  begin
    LoadList(Items, 'Name', Fields);
    Root := Parent;
  end;
  KeyField := Root.Properties.Value('KeyField', '');
  AutoLoadFields := Root.Properties.BoolValue('AutoLoadFields', False);
  AutoResizeColumns := Root.Properties.BoolValue('AutoResizeColumns', False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportCommonSettings.Save(Items: TJvSimpleXmlElems);
begin
  SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', Fields);
  Items.Parent.Properties.Add('KeyField', KeyField);
  Items.Parent.Properties.Add('AutoLoadFields', AutoLoadFields);
  Items.Parent.Properties.Add('AutoResizeColumns', AutoResizeColumns);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNaming.Load(Root: TJvSimpleXmlElem; const DefaultPrefix: Integer);
begin
  Prefix := Root.Properties.IntValue('Prefix', DefaultPrefix);
  Separator1 := Root.Properties.Value('Separator1', '_');
  MovieFieldName := Root.Properties.Value('MovieFieldName', 'Number');
  MovieNumberAddZeroes := Root.Properties.BoolValue('MovieNumberAddZeroes', False);
  Separator2 := Root.Properties.Value('Separator2', '_');
  ExtraFieldName := Root.Properties.Value('ExtraFieldName', 'ENumber');
  ExtraNumberAddZeroes := Root.Properties.BoolValue('ExtraNumberAddZeroes', False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNaming.Save(Items: TJvSimpleXmlElems);
begin
  Items.Parent.Properties.Add('Prefix', Prefix);
  Items.Parent.Properties.Add('Separator1', Separator1);
  Items.Parent.Properties.Add('MovieFieldName', MovieFieldName);
  Items.Parent.Properties.Add('MovieNumberAddZeroes', MovieNumberAddZeroes);
  Items.Parent.Properties.Add('Separator2', Separator2);
  Items.Parent.Properties.Add('ExtraFieldName', ExtraFieldName);
  Items.Parent.Properties.Add('ExtraNumberAddZeroes', ExtraNumberAddZeroes);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TFileNaming.GetFileName(const CatalogFileName: string;
  const SaveFileName: string; const OriginalFileName: string;
  const FileExt: string; const AMovie: TMovie; const AExtra: TMovieExtra;
  const MaxMovieNumber: Integer; const MaxExtraNumber: Integer): string;
var
  sPrefix, sPart1, sPart2, NumberMask: string;
  iField: Integer;
begin
  sPrefix := '';
  if (Prefix = 1) and (CatalogFileName <> '') then
    sPrefix := ExtractFileName(ChangeFileExt(CatalogFileName, ''))
  else if (Prefix = 2) and (SaveFileName <> '') then
    sPrefix := ExtractFileName(ChangeFileExt(SaveFileName, ''));

  sPart1 := '';
  if (MovieFieldName = '*OriginalFileName*') then
  begin
    if OriginalFileName <> '' then
      sPart1 := ExtractFileName(ChangeFileExt(OriginalFileName, ''))
    else if (AMovie <> nil) then
      sPart1 := AMovie.GetFormattedTitle;
  end
  else if (MovieFieldName <> '') and (AMovie <> nil) then
  begin
    if (MovieFieldName = strTagFields[fieldNumber]) then
    begin
      NumberMask := '%d';
      if MovieNumberAddZeroes then
        NumberMask := Format('%%.%dd', [Length(IntToStr(MaxMovieNumber))]);
      sPart1 := Format(NumberMask, [AMovie.iNumber]);
    end
    else
    begin
      iField := IndexText(MovieFieldName, strTagFields);
      if (iField >= fieldLow) and (iField < fieldCount) then
        sPart1 := AMovie.GetFieldValue(iField)
      else
        sPart1 := AMovie.CustomFields.GetFieldValue(MovieFieldName);
    end;
  end;

  sPart2 := '';
  if (ExtraFieldName <> '') and (AExtra <> nil) and (MovieFieldName <> '*OriginalFileName*') then
  begin
    if (ExtraFieldName = strTagExtraFields[extraFieldNumber - extraFieldLow]) then
    begin
      NumberMask := '%d';
      if ExtraNumberAddZeroes then
        NumberMask := Format('%%.%dd', [Length(IntToStr(MaxExtraNumber))]);
      sPart2 := Format(NumberMask, [AExtra.iNumber]);
    end
    else
    begin
      iField := IndexText(ExtraFieldName, strTagExtraFields) + extraFieldLow;
      if (iField >= extraFieldLow) and (iField < extraFieldCount) then
        sPart2 := AExtra.GetFieldValue(iField);
    end;
  end;

  if (sPart1 <> '') and (sPart2 <> '') then
    Result := sPart1 + Separator2 + sPart2
  else
    Result := sPart1 + sPart2;
  if Result = '' then
    Result := 'untitled';
  Result := Result + lowercase(FileExt);
  if (sPrefix <> '') and (not StartsStr(sPrefix + Separator1, Result)) then
    Result := sPrefix + Separator1 + Result;
  Result := ValidateFileName(Result);
  // Limit filename length
  if Length(Result) > 160 then
    System.Delete(Result, 160 - Length(FileExt) + 1, Length(Result) - 160);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TFolder.Create;
begin
  DefaultPath := '';
  PathType := ftDefault;
  Path := '';
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TFolder.Destroy;
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFolder.UpdateFolder(const newPath: string);
begin
  if PathType = ftLast then
    Path := newPath;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TFolder.ReturnPath: string;
var
  Dir: string;
begin
  if PathType = ftDefault then
    Result := ''
  else
  begin
    Dir := GetCurrentDir;
    SetCurrentDir(strDirApp);
    SetCurrentDir(ExpandFileName(DefaultPath));
    if (Path <> '') and DirectoryExists(ExpandFileName(Path)) then
      Result := ExpandFileName(Path)
    else
      Result := DefaultPath;
    SetCurrentDir(Dir);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFolder.SetFolder(const newPath: string; const newType: integer);
begin
  PathType := newType;
  case PathType of
     ftDefault : Path := '';
     ftUser : Path := newPath;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const strXMLFolders: array [0..9] of string =
    ( 'Catalogs', 'Picture', 'Export', 'Templates', 'Import',
      'GetFromFiles', 'Graphic', 'Scripts', 'CustomFields', 'StringFilter' );

procedure TFolder.Load(Root: TJvSimpleXmlElem; nr: Integer);
begin
  Root := Root.Items.ItemNamed[strXMLFolders[nr]];
  if Root <> nil then
    with Root do
    begin
      PathType := Properties.IntValue('Type', ftLast);
      Path := Properties.Value('Path', '');
    end
  else
  begin
    PathType := ftLast;
    Path := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFolder.Load(ini: TMemIniFile; nr: Integer);
begin
  with ini do
  begin
    PathType := ReadInteger('Folders', 'Type'+intToStr(nr), ftLast);
    Path := ReadString('Folders', 'Path'+intToStr(nr), '');
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFolder.Save(Items: TJvSimpleXmlElems; const nr: integer);
begin
  with Items.Add(strXMLFolders[nr]) do
  begin
    Properties.Add('Type', PathType);
    Properties.Add('Path', Path);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TSettings.Create;
var
  i: Integer;
begin
  FXml := TJvSimpleXml.Create(nil);
  with rOptions do
  begin
    for i := 0 to Length(rFolders)-1 do
      rFolders[i] := TFolder.Create;
    for i := 0 to Length(rMovieInformation.rCombo)-1 do
      rMovieInformation.rCombo[i].Contents := TStringList.Create;
    rMovieList.Prefixes := TStringList.Create;
    rMovieInformation.PictureNaming := TFileNaming.Create;
    rMovieInformation.FilterFileName := TStringList.Create;
    rMovieInformation.PosterNames := TStringList.Create;
    rMovieInformation.SearchSites := TStringList.Create;
    rMovieInformation.rDefaultMovie.Values := TMovie.Create(nil);
    rMovieInformation.rDefaultExtra.Values := TMovieExtra.Create(nil);
    rExport.ExpFileNaming := TFileNaming.Create;
  end;
  with rExport do
  begin
    PictureNaming := TFileNaming.Create;
    HTMLMRU := TStringList.Create;
    CSVFields := TStringList.Create;
    SQLFields := TStringList.Create;
    OrderFields := TStringList.Create;
  end;
  with rImport do
  begin
    rCsv.rCommon := TImportCommonSettings.Create;
    rAmc.rCommon := TImportCommonSettings.Create;
    rQuery.rCommon := TImportCommonSettings.Create;
    rDvp.rCommon := TImportCommonSettings.Create;
    rGcs.rCommon := TImportCommonSettings.Create;
    rDir.rCommon := TImportCommonSettings.Create;
    LastFiles := TStringList.Create;
  end;
  with rRenumber do
  begin
    OrderFields := TStringList.Create;
  end;
  with rRenumberExtras do
  begin
    OrderFields := TStringList.Create;
  end;
  with rMain do
  begin
    MRU := TStringList.Create;
    SortAdvancedFields := TStringList.Create;
    ExtrasSortAdvancedFields := TStringList.Create;
    PasteDeselectedFields := TStringList.Create;
  end;
  with rScripts do
  begin
    ScriptMRU := TStringList.Create;
  end;
  with rPrint do
  begin
    OrderFields := TStringList.Create;
  end;
  with rHTMLEditor do
  begin
    HTMLMRU := TStringList.Create;
  end;
  inherited Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TSettings.Destroy;
var
  i: integer;
begin
  with rOptions do
  begin
    for i := 0 to Length(rFolders)-1 do
      rFolders[i].Free;
    for i := 0 to Length(rMovieInformation.rCombo)-1 do
      rMovieInformation.rCombo[i].Contents.Free;
    rMovieList.Prefixes.Free;
    rMovieInformation.PictureNaming.Free;
    rMovieInformation.FilterFileName.Free;
    rMovieInformation.PosterNames.Free;
    rMovieInformation.SearchSites.Free;
    rMovieInformation.rDefaultMovie.Values.Free;
    rMovieInformation.rDefaultExtra.Values.Free;
    rExport.ExpFileNaming.Free;
  end;
  with rExport do
  begin
    PictureNaming.Free;
    HTMLMRU.Free;
    CSVFields.Free;
    SQLFields.Free;
    OrderFields.Free;
  end;
  with rImport do
  begin
    rCsv.rCommon.Free;
    rAmc.rCommon.Free;
    rQuery.rCommon.Free;
    rDvp.rCommon.Free;
    rGcs.rCommon.Free;
    rDir.rCommon.Free;
    LastFiles.Free;
  end;
  with rRenumber do
  begin
    OrderFields.Free;
  end;
  with rRenumberExtras do
  begin
    OrderFields.Free;
  end;
  with rMain do
  begin
    MRU.Free;
    SortAdvancedFields.Free;
    ExtrasSortAdvancedFields.Free;
    PasteDeselectedFields.Free;
  end;
  with rScripts do
  begin
    ScriptMRU.Free;
  end;
  with rPrint do
  begin
    OrderFields.Free;
  end;
  with rHTMLEditor do
  begin
    HTMLMRU.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSettings.Load;
var
  i, c: integer;
  s: string;
  CurItem: TJvSimpleXmlElem;
begin
  SetCurrentDir(strDirData);
  c := ParamCount;
  for i := 1 to c do
  begin
    s := ParamStr(i);
    // if specified, loads another file than the normal one
    if SameText('/prefs', s) and (i < c) then
      strFileSettings := ParamStr(i + 1)
    // if specified, show errors when applying translation file
    else
    if SameText('/tr_show_errors', s) then
      Translator.ShowErrors := True;
  end;
  if not FileExists(strFileSettings) then
  begin
    // in old versions the file was moviecatalog.xml instead of prefs.xml
    if FileExists('moviecatalog.xml') then
      RenameFile(strDirData + 'moviecatalog.xml', strFileSettings)
    else // load default settings, as no config file was found
      CopyFile(PChar(strFileDefault), PChar(strFileSettings), True);
  end;
  if FileExists(strFileSettings) then
    try
      FXml.LoadFromFile(strFileSettings);
    except
    end;
  CurItem := FXml.Root;
  intVersion := FXml.Root.Properties.IntValue('Format', intFileVersion);
  version := FXml.Root.Properties.Value('Version', strVersion);
  CurItem := GetCurItem(CurItem, 'Settings');
  CurItem := GetCurItem(CurItem, 'DataFolders');
  with CurItem, rDataFolders do
  begin
    DirToolbars := Properties.Value('Toolbars', '');
    DirLanguages := Properties.Value('Languages', '');
    DirTemplates := Properties.Value('Templates', '');
    DirScripts := Properties.Value('Scripts', '');
    DirCatalogs := Properties.Value('Catalogs', '');
    SetCurrentDir(strDirData);
    if DirTemplates <> '' then strDirTemplates := ExpandFileName(DirTemplates);
    if DirScripts <> '' then strDirScripts := ExpandFileName(DirScripts);
    SetCurrentDir(strDirDocs);
    if DirCatalogs <> '' then strDirCatalogs := ExpandFileName(DirCatalogs);
    SetCurrentDir(strDirApp); // restore default path
    if DirToolbars <> '' then strDirToolbars := ExpandFileName(DirToolbars);
    if DirLanguages <> '' then strDirLanguages := ExpandFileName(DirLanguages);
    CurItem := Parent;
  end; // DataFolders
  CurItem := GetCurItem(CurItem, 'Main');
  with CurItem, rMain do
  begin
    CurItem := GetCurItem(CurItem, 'MRU');
    with CurItem do
    begin
      LoadList(Items, 'Name', MRU);
      CurItem := Parent;
    end;
    WindowWidth := Properties.IntValue('WindowWidth', 750);
    WindowHeight := Properties.IntValue('WindowHeight', 550);
    WindowLeft := Properties.IntValue('WindowLeft', 20);
    WindowTop := Properties.IntValue('WindowTop', 20);
    WindowState := Properties.IntValue('WindowState', 2);
    Statusbar := Properties.BoolValue('Statusbar', True);
    ListWidth := Properties.IntValue('ListWidth', 200);
    if ListWidth < 1 then
      ListWidth := 200;
    GridMode := Properties.BoolValue('GridMode', False);
    ListAlClient := Properties.BoolValue('ListAlClient', False);
    DisplayHTML := Properties.BoolValue('DisplayHTML', False);
    DisplayThumbnails := Properties.BoolValue('DisplayThumbnails', False);
    ThumbnailsSize := Properties.IntValue('ThumbnailsSize', 6);
    ThumbnailsDisplayTitle := Properties.BoolValue('ThumbnailsDisplayTitle', True);
    ExtrasThumbsSize := Properties.IntValue('ExtrasThumbsSize', 5);
    ExtrasThumbsDisplayTitle := Properties.BoolValue('ExtrasThumbsDisplayTitle', False);
    ExtrasThumbsDisplayInfo := Properties.BoolValue('ExtrasThumbsDisplayInfo', False);
    MovieInfosTabIndex := Properties.IntValue('MovieInfosTabIndex', 0);
    MovieInfosBothWidth := Properties.IntValue('MovieInfosBothWidth', 0);
    MovieInfosHideMediaFields := Properties.BoolValue('MovieInfosHideMediaFields', False);
    MovieInfosHideVideoFields := Properties.BoolValue('MovieInfosHideVideoFields', False);
    PictureDockedHeight := Properties.IntValue('PicDockedHeight', 180);
    ExtrasDockedWidth := Properties.IntValue('ExtrasDockedWidth', 200);
    FindWholeField := Properties.BoolValue('FindWholeField', False);
    FindReverse := Properties.BoolValue('FindReverse', False);
    FindFieldName := Properties.Value('FindFieldName', 'All');
    SortFieldName := Properties.Value('SortFieldName', 'Number'); //use '-' before for descending sort
    GroupFieldName := Properties.Value('GroupFieldName', '*None*');
    ExtrasSortFieldName := Properties.Value('ExtrasSortFieldName', 'ENumber'); //use '-' before for descending sort
    ExtrasGroupFieldName := Properties.Value('ExtrasGroupFieldName', '*None*');
    GroupsFormatOption := Properties.IntValue('GroupsFormatOption', 0);
    GroupsFormatRoundType := Properties.IntValue('GroupsFormatRoundType', 1);
    if intVersion >= 42 then
      ColumnSettings := Properties.Value('ColumnSettings', '');

    if intVersion >= 42 then
    begin
      CurItem := GetCurItem(CurItem, 'SortAdvanced');
      with CurItem do
      begin
        CurItem := GetCurItem(CurItem, 'Fields');
        with CurItem do
        begin
          LoadList(Items, 'Name', SortAdvancedFields, True);
          CurItem := Parent;
        end;
        CurItem := Parent;
      end;
    end;

    CurItem := GetCurItem(CurItem, 'ExtrasSortAdvanced');
    with CurItem do
    begin
      CurItem := GetCurItem(CurItem, 'Fields');
      with CurItem do
      begin
        LoadList(Items, 'Name', ExtrasSortAdvancedFields, True);
        CurItem := Parent;
      end;
      CurItem := Parent;
    end;

    CurItem := GetCurItem(CurItem, 'MoviePaste');
    with CurItem do
    begin
      if CurItem.Items.ItemNamed['DeselectedFields'] = nil then
        PasteDeselectedFields.Add(strTagFields[fieldNumber])
      else
      begin
        CurItem := GetCurItem(CurItem, 'DeselectedFields');
        with CurItem do
        begin
          LoadList(Items, 'Name', PasteDeselectedFields);
          CurItem := Parent;
        end;
      end;
      CurItem := Parent;
    end;
    
    PictureWinLeft := Properties.IntValue('PictureWinLeft', 100);
    PictureWinTop := Properties.IntValue('PictureWinTop', 100);
    Toolbars := Items.ItemNamed['Toolbars'];
    if Toolbars = nil then
      Toolbars := Items.Add('Toolbars');
    CurItem := Parent;
  end; // Main
  CurItem := GetCurItem(CurItem, 'Export');
  with CurItem, rExport do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 780);
    WindowHeight := Properties.IntValue('WindowHeight', 520);
    WindowState := Properties.IntValue('WindowState', 1);
    Includemov := Properties.IntValue('Includemov', 0);
    //ImgFileName := Properties.IntValue('ImgFileName', 0);
    CurItem := GetCurItem(CurItem, 'Pictures');
    with CurItem do
    begin
      CurItem := GetCurItem(CurItem, 'PictureNaming');
      with CurItem, PictureNaming do
      begin
        Load(CurItem, 2);
        CurItem := Parent;
      end;
      CurItem := Parent;
    end; // Export/HTML
    CurItem := GetCurItem(CurItem, 'HTML');
    with CurItem do
    begin
      ExportBoth := Properties.BoolValue('ExportBoth', True);
      HTMLLastTemplate := Properties.Value('LastTemplate', strDirTemplates + 'template.html');
      HTMLLastTemplate2 := Properties.Value('LastTemplate2', '');
      CurItem := GetCurItem(CurItem, 'MRU');
      with CurItem do
      begin
        LoadList(Items, 'Name', HTMLMRU);
        CurItem := Parent;
      end;
      CurItem := Parent;
    end; // Export/HTML
    CurItem := GetCurItem(CurItem, 'CSV');
    with CurItem do
    begin
      CSVDelimiter := Properties.Value('Delimiter', ';');
      CSVDelimExtras := Properties.Value('DelimExtras', '<+>');
      CSVBloc := Properties.Value('Bloc', '"');
      CSVLinebreaks := Properties.Value('Linebreaks', '');
      CSVColumnTitles := Properties.BoolValue('ColumnTitles', True);
      if intVersion >= 42 then
      begin
        CurItem := GetCurItem(CurItem, 'Fields');
        with CurItem do
        begin
          LoadList(Items, 'Name', CSVFields, True);
          CurItem := Parent;
        end;
      end;
      CurItem := Parent;
    end; // Export/CSV
    CurItem := GetCurItem(CurItem, 'SQL');
    with CurItem do
    begin
      SQLUpdate := Properties.BoolValue('SQLUpdate', False);
      SQLDrop := Properties.BoolValue('SQLDrop', True);
      SQLCreate := Properties.BoolValue('SQLCreate', True);
      if intVersion >= 42 then
      begin
        CurItem := GetCurItem(CurItem, 'Fields');
        with CurItem do
        begin
          LoadList(Items, 'Name', SQLFields, True);
          CurItem := Parent;
        end;
      end;
      SQLTableName := Properties.Value('SQLTableName', 'movies');
      SQLTableNameExtras := Properties.Value('SQLTableNameExtras', 'extras');
      SQLLinebreaks := Properties.Value('SQLLinebreaks', '\n');
      CurItem := Parent;
    end; // Export/SQL
    CurItem := GetCurItem(CurItem, 'Sort');
    with CurItem do
    begin
      OrderBy := Properties.IntValue('Order', 0);
      OrderDescend := Properties.BoolValue('Descend', False);
      if intVersion >= 42 then
      begin
        CurItem := GetCurItem(CurItem, 'Fields');
        with CurItem do
        begin
          LoadList(Items, 'Name', OrderFields, True);
          CurItem := Parent;
        end;
      end;
      CurItem := Parent;
    end; // Export/Sort
    CurItem := Parent;
  end; // Export
  CurItem := GetCurItem(CurItem, 'Import');
  with CurItem, rImport do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 780);
    WindowHeight := Properties.IntValue('WindowHeight', 520);
    WindowState := Properties.IntValue('WindowState', 1);
    AllowDup := Properties.BoolValue('AllowDup', False);
    AllowClear := Properties.BoolValue('AllowClear', False);
    AutoAssign := Properties.BoolValue('AutoAssign', True);
    PicImport := Properties.IntValue('PicImport', 0);
    ExtraPicImport := Properties.IntValue('ExtraPicImport', 3);

    CurItem := GetCurItem(CurItem, 'CSV');
    with CurItem, rCsv do
    begin
      Delim := Properties.Value('Delim', ';');
      DelimExtras := Properties.Value('DelimExtras', '<+>');
      Quote := Properties.Value('Quote', '"');
      FirstLineHeaders := Properties.BoolValue('FirstLineHeaders', True);
      Linebreaks := Properties.Value('Linebreaks', '');
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'AMC');
    with CurItem, rAmc do
    begin
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'Query');
    with CurItem, rQuery do
    begin
      From := Properties.Value('From', '');
      Where := Properties.Value('Where', '');
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'DVP');
    with CurItem, rDvp do
    begin
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'GCS');
    with CurItem, rGcs do
    begin
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'Dir');
    with CurItem, rDir do
    begin
      MultiDisks := Properties.BoolValue('MultiDisks', True);
      DiskTag := Properties.Value('DiskTag', '(cd)[0-9]{1,3}');
      BrowseDepth := Properties.Value('BrowseDepth', '*');
      ExtractProcess := Properties.IntValue('ExtractProcess', 0);
      rCommon.Load(CurItem);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'LastFiles');
    with CurItem do
    begin
      LoadList(Items, 'FileName', LastFiles, False, True);
      CurItem := Parent;
    end;
    CurItem := Parent;
  end; // Import
  CurItem := GetCurItem(CurItem, 'Print');
  with CurItem, rPrint do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 750);
    WindowHeight := Properties.IntValue('WindowHeight', 480);
    WindowState := Properties.IntValue('WindowState', 1);
    CurItem := GetCurItem(CurItem, 'Sort');
    with CurItem do
    begin
      OrderBy := Properties.IntValue('Order', 0);
      OrderDescend := Properties.BoolValue('Descend', False);
      if intVersion >= 42 then
      begin
        CurItem := GetCurItem(CurItem, 'Fields');
        with CurItem do
        begin
          LoadList(Items, 'Name', OrderFields, True);
          CurItem := Parent;
        end;
      end;
      CurItem := Parent;
    end; // Print/Sort
    Includemov := Properties.IntValue('Includemov', 0);
    ReportsListWidth := Properties.IntValue('ReportsListWidth', 175);
    if ReportsListWidth < 1 then
      ReportsListWidth := 175;
    CurItem := Parent;
  end; // Print
  CurItem := GetCurItem(CurItem, 'Scripts');
  with CurItem, rScripts do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 580);
    WindowHeight := Properties.IntValue('WindowHeight', 430);
    WindowState := Properties.IntValue('WindowState', 1);
    ScriptRemember1 := Properties.Value('ScriptRemember1', '');
    ScriptRemember2 := Properties.Value('ScriptRemember2', '');
    Includemov := Properties.IntValue('Includemov', 0);
    LangFilterExcl := Properties.Value('LangFilterExcl', '');
    ListViewStyle := Properties.IntValue('ListViewStyle', 2 {vsList});
    ShowResGetInfo := Properties.BoolValue('ShowResGetInfo', True);
    ShowResScripting := Properties.BoolValue('ShowResScripting', False);
    CloseWinGetInfo := Properties.BoolValue('CloseWinGetInfo', True);
    CloseWinScripting := Properties.BoolValue('CloseWinScripting', False);
    AllowClearGetInfo := Properties.BoolValue('AllowClearGetInfo', False);
    AllowClearScripting := Properties.BoolValue('AllowClearScripting', True);
    CurItem := GetCurItem(CurItem, 'MRU');
    with CurItem do
    begin
      LoadList(Items, 'Name', ScriptMRU);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'Properties');
    with CurItem, rProperties do
    begin
      WindowWidth := Properties.IntValue('WindowWidth', 500);
      WindowHeight := Properties.IntValue('WindowHeight', 450);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'Results');
    with CurItem, rResults do
    begin
      WindowState := Properties.IntValue('WindowState', 1);
      WindowWidth := Properties.IntValue('WindowWidth', 690);
      WindowHeight := Properties.IntValue('WindowHeight', 550);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'ExtrasResults');
    with CurItem, rExtrasResults do
    begin
      WindowState := Properties.IntValue('WindowState', 1);
      WindowWidth := Properties.IntValue('WindowWidth', 690);
      WindowHeight := Properties.IntValue('WindowHeight', 450);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'PickList');
    with CurItem, rPickList do
    begin
      WindowWidth := Properties.IntValue('WindowWidth', 500);
      WindowHeight := Properties.IntValue('WindowHeight', 440);
      CurItem := Parent;
    end;
    CurItem := GetCurItem(CurItem, 'PickTree');
    with CurItem, rPickTree do
    begin
      WindowWidth := Properties.IntValue('WindowWidth', 450);
      WindowHeight := Properties.IntValue('WindowHeight', 440);
      CurItem := Parent;
    end;
    Toolbars := Items.ItemNamed['Toolbars'];
    if Toolbars = nil then
      Toolbars := Items.Add('Toolbars');
    CurItem := Parent;
  end; // Scripts
  CurItem := GetCurItem(CurItem, 'Loan');
  with CurItem, rLoan do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 650);
    WindowHeight := Properties.IntValue('WindowHeight', 550);
    WindowState := Properties.IntValue('WindowState', 1);
    LvMoviesHeight := Properties.IntValue('MoviesHeight', 175);
    if LvMoviesHeight < 1 then
      LvMoviesHeight := 175;
    LvMoviesColWidth := Properties.IntValue('MoviesColWidth', WindowWidth div 3);
    LvMoviesSort := Properties.IntValue('MoviesSort', 0);
    LvNamesWidth := Properties.IntValue('NamesWidth', 210);
    if LvNamesWidth < 1 then
      LvNamesWidth := 210;
    LvNamesSort := Properties.IntValue('NamesSort', 0);
    LvLentSort := Properties.IntValue('LentSort', 0);
    IncludeSameNum := Properties.BoolValue('IncludeSameNum', False);
    IncludeSameLabel := Properties.BoolValue('IncludeSameLabel', False);
    CurItem := Parent;
  end; // Loan
  CurItem := GetCurItem(CurItem, 'Properties');
  with CurItem, rProperties do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 400);
    WindowHeight := Properties.IntValue('WindowHeight', 350);
    CurItem := Parent;
  end; // Properties
  CurItem := GetCurItem(CurItem, 'Statistics');
  with CurItem, rStatistics do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 750);
    WindowHeight := Properties.IntValue('WindowHeight', 550);
    WindowState := Properties.IntValue('WindowState', 1);
    EmptyMonths := Properties.BoolValue('EmptyMonths', True);
    Legend := Properties.BoolValue('Legend', True);
    Labels := Properties.BoolValue('Labels', False);
    Group := Properties.BoolValue('GroupValues', True);
    Includemov := Properties.IntValue('Includemov', 0);
    CurItem := Parent;
  end; // Statistics
  CurItem := GetCurItem(CurItem, 'Renumber');
  with CurItem, rRenumber do
  begin
    OrderBy := Properties.IntValue('SortOrder', 0);
    OrderDescend := Properties.BoolValue('SortDescend', False);
    if intVersion >= 42 then
    begin
      CurItem := GetCurItem(CurItem, 'Fields');
      with CurItem do
      begin
        LoadList(Items, 'Name', OrderFields, True);
        CurItem := Parent;
      end;
    end;
    CurItem := Parent;
  end; // Renumber
  CurItem := GetCurItem(CurItem, 'RenumberExtras');
  with CurItem, rRenumberExtras do
  begin
    OrderBy := Properties.IntValue('SortOrder', 0);
    OrderDescend := Properties.BoolValue('SortDescend', False);
    CurItem := GetCurItem(CurItem, 'Fields');
    with CurItem do
    begin
      LoadList(Items, 'Name', OrderFields, True);
      CurItem := Parent;
    end;
    CurItem := Parent;
  end; // Renumber Extras
  CurItem := GetCurItem(CurItem, 'Options');
  with CurItem, rOptions do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 650);
    WindowHeight := Properties.IntValue('WindowHeight', 550);
    WindowState := Properties.IntValue('WindowState', 1);
    CurItem := GetCurItem(CurItem, 'Display');
    with CurItem, rDisplay do
    begin
      ImagesInMenu := Properties.BoolValue('ImagesInMenu', True);
      OfficeXP := Properties.BoolValue('OfficeXP', False);
      if IsThemedXP then
        IconSet := Properties.Value('IconSet', 'Windows XP')
      else
        IconSet := Properties.Value('IconSet', 'Scrows');
      if (IconSet = '') and (StrToIntDef(StringReplace(Copy(version, 1, 3), '.', '', []), 35) < 35) then
        IconSet := 'Scrows';
      ColorType := Properties.IntValue('ColorType', 0);
      Logo := Properties.BoolValue('Logo', True);
      SoftBorders := Properties.BoolValue('SoftBorders', False);
      NaturalCompare := Properties.BoolValue('NaturalCompare', True);
      ScrollUnderPointer := Properties.BoolValue('ScrollUnderPointer', True);
      AutoFocus := Properties.BoolValue('AutoFocus', False);
      ForceRefresh := Properties.BoolValue('ForceRefresh', True);
      CurItem := Parent;
    end; // Options/Display
    CurItem := GetCurItem(CurItem, 'Files');
    with CurItem, rFiles do
    begin
//          XMLHeader := Properties.Value('XMLHeader', 'iso-8859-1');
      Backup := Properties.BoolValue('Backup', True);
      RecentFiles := Properties.IntValue('RecentFiles', 5);
      CurItem := GetCurItem(CurItem, 'AutoLoad');
      with CurItem do
      begin
        AutoLoad := Properties.BoolValue('Enabled', False);
        AutoLoadFile := Properties.Value('File', '');
        AutoLoadLast := Properties.BoolValue('Last', False);
        CurItem := Parent;
      end; // Options/Files/Autoload
      CurItem := GetCurItem(CurItem, 'AutoLoadCF');
      with CurItem do
      begin
        AutoLoadCF := Properties.BoolValue('Enabled', False);
        AutoLoadCFFile := Properties.Value('File', '');
        CurItem := Parent;
      end; // Options/Files/AutoloadCF
      CurItem := GetCurItem(CurItem, 'History');
      with CurItem do
      begin
        History := Properties.BoolValue('Enabled', True);
        HistoryFile := Properties.Value('File', 'Loans history.csv');
        CurItem := Parent;
      end; // Options/Files/History
      CurItem := GetCurItem(CurItem, 'HTMLTemplate');
      with CurItem do
      begin
        HTMLTemplateFile := Properties.Value('File', 'HTMLDefaultTemplate.html');
        CurItem := Parent;
      end; // Options/Files/HTMLTemplate
      CurItem := Parent;
    end; // Options/Files
    CurItem := GetCurItem(CurItem, 'MovieList');
    with CurItem, rMovieList do
    begin
      CurItem := GetCurItem(CurItem, 'TitleDisplay');
      with CurItem do
      begin
        TitleColumn := Properties.IntValue('TitleColumn', 2);
        CurItem := GetCurItem(CurItem, 'Prefixes');
        with CurItem do
        begin
          UsePrefixes := Properties.BoolValue('Use', False);
          LoadList(Items, 'Text', Prefixes);
          CurItem := Parent;
        end;
        TitleTemplate := Properties.Value('TitleTemplate', '');
        CurItem := Parent;
      end; // Options/MovieList/TitleDisplay
      ConfirmDelete := Properties.BoolValue('ConfirmDelete', True);
      ConfirmUndo := Properties.BoolValue('ConfirmUndo', True);
      Checkboxes := Properties.BoolValue('Checkboxes', True);
      CheckboxesInThumbs :=  Properties.BoolValue('CheckboxesInThumbs', True);
      CheckboxesColor := Properties.BoolValue('CheckboxesColor', True);
      LinesColor := Properties.BoolValue('LinesColor', False);
      HotTrack := Properties.BoolValue('HotTrack', False);
      EnhancedScrollbars := Properties.BoolValue('EnhancedScrollbars', False);
      MovieNumColumn := Properties.BoolValue('MovieNumColumn', True);
      GridTextSize := Properties.IntValue('GridTextSize', 32);
      AutoStretchListGrid := Properties.BoolValue('AutoStretchListGrid', True);
      AutoStretchListThumbs := Properties.BoolValue('AutoStretchListThumbs', False);
      ShortcutPrev := Properties.IntValue('ShortcutPrev', 16417);
      ShortcutNext := Properties.IntValue('ShortcutNext', 16418);
      GroupCount := Properties.BoolValue('GroupCount', True);
      GroupExpand := Properties.BoolValue('GroupExpand', False);
      GroupsAbove := Properties.BoolValue('GroupsAbove', False);
      GroupUnique := Properties.BoolValue('GroupUnique', False);
      GroupMulti := Properties.BoolValue('GroupMulti', True);
      GroupMultiSep := Properties.Value('GroupMultiSep', defaultSep)[1];
      GroupMultiRmAllP := Properties.BoolValue('GroupMultiRmAllP', False);
      GroupMultiAddPatch := Properties.BoolValue('GroupMultiAddPatch', True);
      SortGroupsByCount := Properties.BoolValue('SortGroupsByCount', False);
      for i := 0 to Length(ColorsTag)-1 do
        ColorsTag[i] := ConvertColorFromHTML(Properties.Value('ColorTag'+IntToStr(i), ''), DefaultColorsTag[i]);
      CurItem := Parent;
    end; // Options/MovieList
    CurItem := GetCurItem(CurItem, 'ExtraList');
    with CurItem, rExtraList do
    begin
      ConfirmDelete := Properties.BoolValue('ConfirmDelete', True);
      Checkboxes := Properties.BoolValue('Checkboxes', True);
      NumWithTitle := Properties.BoolValue('NumWithTitle', False);
      InfoWhenNoPic := Properties.BoolValue('InfoWhenNoPic', False);
      CellBorders := Properties.BoolValue('CellBorders', False);
      GroupCount := Properties.BoolValue('GroupCount', True);
      GroupExpand := Properties.BoolValue('GroupExpand', True);
      GroupsAbove := Properties.BoolValue('GroupsAbove', False);
      GroupMulti := Properties.BoolValue('GroupMulti', True);
      GroupMultiSep := Properties.Value('GroupMultiSep', defaultSep)[1];
      GroupMultiRmAllP := Properties.BoolValue('GroupMultiRmAllP', False);
      SortGroupsByCount := Properties.BoolValue('SortGroupsByCount', False);
      ActionDoubleClick := Properties.IntValue('ActionDoubleClick', 1);
      ActionKeyReturn := Properties.IntValue('ActionKeyReturn', 1);
      CurItem := Parent;
    end; // Options/ExtraList
    CurItem := GetCurItem(CurItem, 'MovieInfo');
    with CurItem, rMovieInformation do
    begin
      AskNumber := Properties.BoolValue('AskNumber', True);
      FirstAvailable := Properties.BoolValue('FirstAvailable', False);
      AddScript := Properties.BoolValue('AddScript', False);
      AddFiles := Properties.BoolValue('AddFiles', False);
      RatingTrunc := Properties.BoolValue('RatingTrunc', False);
      SetCurrentDate := Properties.BoolValue('SetCurrentDate', True);
      CurItem := GetCurItem(CurItem, 'Picture');
      with CurItem do
      begin
        PictureBackground := Properties.IntValue('Background', clDefault);
        PictureFitWindow := Properties.BoolValue('FitWindow', True);
        PictureInfo := Properties.BoolValue('PictureInfo', False);
        CurItem := Parent;
      end; // Options/MovieInfo/Picture
      CurItem := GetCurItem(CurItem, 'MovieFrame');
      with CurItem do
      begin
        MovieFrameBackground := Properties.IntValue('Background', clDefault);
        CurItem := Parent;
      end; // Options/MovieInfo/MovieFrame
      CurItem := GetCurItem(CurItem, 'HTMLDisplay');
      with CurItem do
      begin
        HTMLSearchFontTextColor := Properties.Value('SearchFontTextColor', '#000000');
        HTMLSearchBackTextColor := Properties.Value('SearchBackTextColor', '#FFFF00');
        HTMLNoMoviePage := Properties.Value('NoMoviePage',
          '<html><head></head><body bgcolor="' +
          ConvertColorToHTML(clBtnFace) + '"></body></html>');
        CurItem := Parent;
      end; // Options/MovieInfo/HTMLDisplay
      CurItem := GetCurItem(CurItem, 'DefaultMovie');
      with CurItem, rDefaultMovie do
      begin
        WindowWidth := Properties.IntValue('WindowWidth', 558);
        WindowHeight := Properties.IntValue('WindowHeight', 549);
        Values.InitFields;
        Values.bChecked := True;
        try
          if (Items.ItemNamed['Values'] <> nil) then
            Values.LoadFromXML(Items.ItemNamed['Values']);
        except
        end;
        CurItem := Parent;
      end; // Options/MovieInfo/DefaultMovie
      CurItem := GetCurItem(CurItem, 'DefaultExtra');
      with CurItem, rDefaultExtra do
      begin
        WindowWidth := Properties.IntValue('WindowWidth', 432);
        WindowHeight := Properties.IntValue('WindowHeight', 341);
        Values.InitFields;
        Values.bChecked := True;
        try
          if (Items.ItemNamed['Values'] <> nil) then
            Values.LoadFromXML(Items.ItemNamed['Values']);
        except
        end;
        CurItem := Parent;
      end; // Options/MovieInfo/DefaultExtra
      CurItem := GetCurItem(CurItem, 'ImportInfo');
      with CurItem do
      begin
        ImportExt := Properties.Value('ImportExt', GetExtVideo);
        ImportAllowClear := Properties.BoolValue('AllowClear', False);
        ImportMediaLabel := Properties.BoolValue('MediaLabel', False);
        ImportFileName := Properties.BoolValue('FileName', False);
        ImportFileInFilePath := Properties.BoolValue('FileInFilePath', True);
        ImportFileInURL := Properties.BoolValue('FileInURL', False);
        ImportSize := Properties.BoolValue('Size', True);
        ImportSizeString := Properties.BoolValue('SizeString', True);
        ImportSizeUnit := TFileSizeUnit(Properties.IntValue('SizeUnit', 2));
        if StrToIntDef(StringReplace(Copy(version, 1, 3), '.', '', []), 35) < 35 then
        // unit "GB" added to the list in version 3.5, and the list order was reversed
          case Integer(ImportSizeUnit) of
            1:  ImportSizeUnit := fsuKB;
            2:  ImportSizeUnit := fsuB;
          else
            ImportSizeUnit := fsuMB;
          end;
        ImportPicture := Properties.BoolValue('Picture', False);
        ImportInternalAVI := Properties.BoolValue('InternalAVI', False);
        ImportLength := Properties.BoolValue('Length', True);
        ImportResolution := Properties.BoolValue('Resolution', True);
        ImportFramerate := Properties.BoolValue('Framerate', True);
        ImportVideoCodec := Properties.BoolValue('VideoCodec', True);
        ImportVideoBitrate := Properties.BoolValue('VideoBitrate', True);
        ImportAudioCodec := Properties.BoolValue('AudioCodec', True);
        ImportAudioChannels := Properties.BoolValue('AudioChannels', False);
        ImportAudioBitrate := Properties.BoolValue('AudioBitrate', True);
        ImportLanguages := Properties.BoolValue('Languages', True);
        ImportSubtitles := Properties.BoolValue('Subtitles', True);
        CurItem := Parent;
      end; // Options/MovieInfo/ImportInfo
      CurItem := GetCurItem(CurItem, 'FilterFileName');
      with CurItem do
      begin
        LoadList(Items, 'Value', FilterFileName);
        CurItem := Parent;
      end; // Options/MovieInfo/FilterFileName
      if CurItem.Items.ItemNamed['PosterNames'] = nil then
      begin
        PosterNames.AddStrings(strPosterNames)
      end else
      begin
        CurItem := GetCurItem(CurItem, 'PosterNames');
        with CurItem do
        begin
          LoadList(Items, 'Name', PosterNames);
          CurItem := Parent;
        end; // Options/MovieInfo/PosterNames
      end;
      CurItem := GetCurItem(CurItem, 'PicImport');
      with CurItem, rPicImport do
      begin
        GetInfoMethod := Properties.IntValue('GetInfoMethod', -Integer(mpiStore));
        ScriptingMethod := Properties.IntValue('ScriptingMethod', Integer(mpiStore));
        PicConvertJPG := Properties.BoolValue('PicConvertJPG', False);
        MaxPicSizeW := Properties.IntValue('MaxPicSizeW', -1);
        MaxPicSizeH := Properties.IntValue('MaxPicSizeH', -1);
        CurItem := Parent;
      end; // Options/MovieInfo/PicImport
      CurItem := GetCurItem(CurItem, 'ExtraPicImport');
      with CurItem, rExtraPicImport do
      begin
        GetInfoMethod := Properties.IntValue('GetInfoMethod', -Integer(mpiCopyInPicDir));
        ScriptingMethod := Properties.IntValue('ScriptingMethod', Integer(mpiCopyInPicDir));
        PicConvertJPG := Properties.BoolValue('PicConvertJPG', False);
        MaxPicSizeW := Properties.IntValue('MaxPicSizeW', -1);
        MaxPicSizeH := Properties.IntValue('MaxPicSizeH', -1);
        CurItem := Parent;
      end; // Options/MovieInfo/ExtraPicImport
      CurItem := GetCurItem(CurItem, 'PictureNaming');
      with CurItem, PictureNaming do
      begin
        Load(CurItem);
        CurItem := Parent;
      end; // Options/MovieInfo/PictureNaming
      CurItem := GetCurItem(CurItem, 'Search');
      with CurItem do
      begin
        LoadList(Items, 'Address', SearchSites);
        CurItem := Parent;
      end;
      CurItem := GetCurItem(CurItem, 'Lists');
      with CurItem do
      begin
        ComboSameForAll := Properties.BoolValue('SameForAll', False);
        for i := 0 to Length(rCombo)-1 do
        begin
          CurItem := GetCurItem(CurItem, strXMLDdl[i]);
          with CurItem, rCombo[i] do
          begin
            AutoAdd := Properties.BoolValue('AutoAdd', False);
            Sort := Properties.BoolValue('Sorted', True);
            AutoComplete := Properties.BoolValue('AutoComplete', False);
            UseCatalogValues := Properties.BoolValue('UseCatalogValues', True);
            LoadList(Items, 'Text', Contents);
            CurItem := Parent;
          end;
        end;
        CurItem := Parent;
      end;
      CurItem := Parent;
    end; // Options/MovieInfo
    CurItem := GetCurItem(CurItem, 'Scripting');
    with CurItem, rScripting do
    begin
      ScriptAutorun := Properties.BoolValue('Autorun', False);
      CurItem := GetCurItem(CurItem, 'Proxy');
      with CurItem do
      begin
        Proxy := Properties.BoolValue('Use', False);
        ProxyServer := Properties.Value('Server', '');
        ProxyPort := Properties.IntValue('Port', 8080);
        ProxyUsername := Properties.Value('Username', '');
        ProxyPassword := Decrypt(Properties.Value('Password', ''));
        KeepConnection := Properties.BoolValue('KeepConnection', False);
        HTTP10 := Properties.BoolValue('HTTP10', False);
        CurItem := Parent;
      end;
      CurItem := Parent;
    end; // Options/Scripting
    CurItem := GetCurItem(CurItem, 'Export');
    with CurItem, rExport do
    begin
      LoadTemplate := Properties.BoolValue('LoadTemplate', True);
      Linebreak := Properties.Value('LineBreak', '<br />');
      ForcePicSizeW := Properties.IntValue('ForcePicSizeW', -1);
      ForcePicSizeH := Properties.IntValue('ForcePicSizeH', -1);
      ForceExtraPicSizeW := Properties.IntValue('ForceExtraPicSizeW', -1);
      ForceExtraPicSizeH := Properties.IntValue('ForceExtraPicSizeH', -1);
      SQLDate := Properties.Value('SQLDate', 'yyyy''-''mm''-''dd');
      RememberLastFile := Properties.BoolValue('RememberLastFile', False);
      LastFile := Properties.Value('LastFile', '');
      OpenExportedFile := Properties.BoolValue('OpenExportedFile', False);
      CurItem := GetCurItem(CurItem, 'ExpFileNaming');
      with CurItem, ExpFileNaming do
      begin
        Load(CurItem, 2);
        CurItem := Parent;
      end; // ExpFileNaming
      ExpFileExt := Properties.Value('ExpFileExt', '');
      CopyPictures := Properties.BoolValue('CopyPictures', True);
      CopyPicturesInPicDir := Properties.BoolValue('CopyPicturesInPicDir', False);
      CopyPicturesNew := Properties.BoolValue('CopyPicturesNew', False);
      CopyPicturesIncExtras := Properties.BoolValue('CopyPicturesIncExtras', False);
      PicturesExportMethodAMC := Properties.IntValue('PicturesExportMethodAMC', 0);
      PicturesExportMethodXML := Properties.IntValue('PicturesExportMethodXML', 0);
      ExtraPicturesExportMethodAMC := Properties.IntValue('ExtraPicturesExportMethodAMC', 0);
      ExtraPicturesExportMethodXML := Properties.IntValue('ExtraPicturesExportMethodXML', 0);
      PicturesSaveXMLInPicDir := Properties.BoolValue('PicturesSaveXMLInPicDir', False);
      CurItem := Parent;
    end; // Options/Export
    CurItem := GetCurItem(CurItem, 'Folders');
    with CurItem do
    begin
      SameFolderForAll := Properties.BoolValue('SameForAll', False);
      for i := 0 to length(rFolders)-1 do
        with rFolders[i] do
        begin
          DefaultPath := strDirApp;
          case i of
            fuCatalogs,
            fuExport,
            fuImport,
            fuPicture,
            fuCustomFields,
            fuStringFilter:   DefaultPath := strDirCatalogs;
            fuTemplates:      DefaultPath := strDirTemplates;
            fuScripts:        DefaultPath := strDirScripts;
          end;
          DefaultPath := ExcludeTrailingPathDelimiter(DefaultPath);
          if (Length(DefaultPath) > 0) and (DefaultPath[Length(DefaultPath)] = ':') then
            DefaultPath := DefaultPath + '\';
          Load(CurItem, i);
        end; // for-with
      CurItem := Parent;
    end; // Options/Folders
    CurItem := GetCurItem(CurItem, 'Language');
    with CurItem, rLanguage do
    begin
      Language := Properties.Value('File', '?');
      CurItem := Parent;
    end; // Options/Languages
    CurItem := Parent;
  end; // Options
  CurItem := GetCurItem(CurItem, 'CustomFieldsManager');
  with CurItem, rCustomFieldsManager do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 450);
    WindowHeight := Properties.IntValue('WindowHeight', 350);
    WindowState := Properties.IntValue('WindowState', 1);
    CurItem := Parent;
  end; // CustomFieldsManager
  CurItem := GetCurItem(CurItem, 'StringFilter');
  with CurItem, rStringFilter do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 700);
    WindowHeight := Properties.IntValue('WindowHeight', 500);
    WindowState := Properties.IntValue('WindowState', 1);
    CurItem := Parent;
  end; // CustomFieldsManager
  CurItem := GetCurItem(CurItem, 'HTMLEditor');
  with CurItem, rHTMLEditor do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 772);
    WindowHeight := Properties.IntValue('WindowHeight', 510);
    WindowState := Properties.IntValue('WindowState', 1);
    HTMLLastTemplate := Properties.Value('LastTemplate', strDirTemplates + 'HTMLDefaultTemplate.html');
    CurItem := GetCurItem(CurItem, 'MRU');
    with CurItem do
    begin
      LoadList(Items, 'Name', HTMLMRU);
      CurItem := Parent;
    end;
    CurItem := Parent;
  end; // HTMLEditor
  CurItem := GetCurItem(CurItem, 'ExtrasEdit');
  with CurItem, rExtrasEdit do
  begin
    WindowWidth := Properties.IntValue('WindowWidth', 650);
    WindowHeight := Properties.IntValue('WindowHeight', 340);
    WindowState := Properties.IntValue('WindowState', 1);
    //CurItem := Parent;
  end; // ExtrasEdit
  intVersion := intFileVersion;
  version := strVersion;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSettings.Save;
var
  i: integer;
begin
  WriteXMLHeader(FXml.Root, intFileVersion, 'AntMovieCatalog', strVersion, strDate);
  with PrepareItem(FXml.Root.Items, 'Settings') do
  begin
    with PrepareItem(Items, 'DataFolders'), rDataFolders do
    begin
      Properties.Add('Toolbars', DirToolbars);
      Properties.Add('Languages', DirLanguages);
      Properties.Add('Templates', DirTemplates);
      Properties.Add('Scripts', DirScripts);
      Properties.Add('Catalogs', DirCatalogs);
    end; //DataFolders
    with PrepareItem(Items, 'Main'), rMain do
    begin
      SaveList(PrepareItem(Items, 'MRU').Items, 'File', 'Name', MRU);
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowLeft', WindowLeft);
      Properties.Add('WindowTop', WindowTop);
      Properties.Add('WindowState', WindowState);
      Properties.Add('Statusbar', Statusbar);
      Properties.Add('ListWidth', ListWidth);
      Properties.Add('GridMode', GridMode);
      Properties.Add('ListAlClient', ListAlClient);
      Properties.Add('DisplayHTML', DisplayHTML);
      Properties.Add('DisplayThumbnails', DisplayThumbnails);
      Properties.Add('ThumbnailsSize', ThumbnailsSize);
      Properties.Add('ThumbnailsDisplayTitle', ThumbnailsDisplayTitle);
      Properties.Add('ExtrasThumbsSize', ExtrasThumbsSize);
      Properties.Add('ExtrasThumbsDisplayTitle', ExtrasThumbsDisplayTitle);
      Properties.Add('ExtrasThumbsDisplayInfo', ExtrasThumbsDisplayInfo);
      Properties.Add('MovieInfosTabIndex', MovieInfosTabIndex);
      Properties.Add('MovieInfosBothWidth', MovieInfosBothWidth);
      Properties.Add('MovieInfosHideMediaFields', MovieInfosHideMediaFields);
      Properties.Add('MovieInfosHideVideoFields', MovieInfosHideVideoFields);
      Properties.Add('PicDockedHeight', PictureDockedHeight);
      Properties.Add('ExtrasDockedWidth', ExtrasDockedWidth);
      Properties.Add('FindWholeField', FindWholeField);
      Properties.Add('FindReverse', FindReverse);
      Properties.Add('FindFieldName', FindFieldName);
      Properties.Add('SortFieldName', SortFieldName);
      Properties.Add('GroupFieldName', GroupFieldName);
      Properties.Add('GroupsFormatOption', GroupsFormatOption);
      Properties.Add('GroupsFormatRoundType', GroupsFormatRoundType);
      Properties.Add('ExtrasSortFieldName', ExtrasSortFieldName);
      Properties.Add('ExtrasGroupFieldName', ExtrasGroupFieldName);
      Properties.Add('ColumnSettings', ColumnSettings);
      with PrepareItem(Items, 'SortAdvanced') do
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', SortAdvancedFields, True);
      with PrepareItem(Items, 'ExtrasSortAdvanced') do
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', ExtrasSortAdvancedFields, True);
      with PrepareItem(Items, 'MoviePaste') do
        SaveList(PrepareItem(Items, 'DeselectedFields').Items, 'Field', 'Name', PasteDeselectedFields);
      Properties.Add('PictureWinLeft', PictureWinLeft);
      Properties.Add('PictureWinTop', PictureWinTop);
    end; // Main
    with PrepareItem(Items, 'Export'), rExport do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('Includemov', Includemov);
      //Properties.Add('ImgFileName', ImgFileName);
      PictureNaming.Save(Items);
      with PrepareItem(Items, 'Pictures') do
      begin
        with PrepareItem(Items, 'PictureNaming'), PictureNaming do
        begin
          Save(Items);
        end;
      end; // Export/Pictures
      with PrepareItem(Items, 'HTML') do
      begin
        Properties.Add('ExportBoth', ExportBoth);
        Properties.Add('LastTemplate', HTMLLastTemplate);
        Properties.Add('LastTemplate2', HTMLLastTemplate2);
        SaveList(PrepareItem(Items, 'MRU').Items, 'File', 'Name', HTMLMRU);
      end; // Export/HTML
      with PrepareItem(Items, 'CSV') do
      begin
        Properties.Add('Delimiter', CSVDelimiter);
        Properties.Add('DelimExtras', CSVDelimExtras);
        Properties.Add('Bloc', CSVBloc);
        Properties.Add('Linebreaks', CSVLinebreaks);
        Properties.Add('ColumnTitles', CSVColumnTitles);
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', CSVFields, True);
      end; // Export/CSV
      with PrepareItem(Items, 'SQL') do
      begin
        Properties.Add('SQLUpdate', SQLUpdate);
        Properties.Add('SQLDrop', SQLDrop);
        Properties.Add('SQLCreate', SQLCreate);
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', SQLFields, True);
        Properties.Add('SQLTableName', SQLTableName);
        Properties.Add('SQLTableNameExtras', SQLTableNameExtras);
        Properties.Add('SQLLinebreaks', SQLLinebreaks);
      end; // Export/SQL
      with PrepareItem(Items, 'Sort') do
      begin
        Properties.Add('Order', OrderBy);
        Properties.Add('Descend', OrderDescend);
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', OrderFields, True);
      end; // Export/Sort
    end; // Export
    with PrepareItem(Items, 'Import'), rImport do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('AllowDup', AllowDup);
      Properties.Add('AllowClear', AllowClear);
      Properties.Add('AutoAssign', AutoAssign);
      Properties.Add('PicImport', PicImport);
      Properties.Add('ExtraPicImport', ExtraPicImport);
      with PrepareItem(Items, 'CSV'), rCsv do
      begin
        Properties.Add('Delim', Delim);
        Properties.Add('DelimExtras', DelimExtras);
        Properties.Add('Quote', Quote);
        Properties.Add('FirstLineHeaders', FirstLineHeaders);
        Properties.Add('Linebreaks', Linebreaks);
        rCommon.Save(Items);
      end;
      with PrepareItem(Items, 'AMC'), rAmc do
      begin
        rCommon.Save(Items);
      end;
      with PrepareItem(Items, 'Query'), rQuery do
      begin
        Properties.Add('From', From);
        Properties.Add('Where', Where);
        rCommon.Save(Items);
      end;
      with PrepareItem(Items, 'DVP'), rDvp do
      begin
        rCommon.Save(Items);
      end;
      with PrepareItem(Items, 'GCS'), rGcs do
      begin
        rCommon.Save(Items);
      end;
      with PrepareItem(Items, 'Dir'), rDir do
      begin
        Properties.Add('MultiDisks', MultiDisks);
        Properties.Add('DiskTag', DiskTag);
        Properties.Add('BrowseDepth', BrowseDepth);
        Properties.Add('ExtractProcess', ExtractProcess);
        rCommon.Save(Items);
      end;
      SaveList(PrepareItem(Items, 'LastFiles').Items, '', 'FileName', LastFiles);
    end; // Import
    with PrepareItem(Items, 'Print'), rPrint do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      with PrepareItem(Items, 'Sort') do
      begin
        Properties.Add('Order', OrderBy);
        Properties.Add('Descend', OrderDescend);
        SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', OrderFields, True);
      end; // Print/Sort
      Properties.Add('Includemov', Includemov);
      Properties.Add('ReportsListWidth', ReportsListWidth);
    end; // Print
    with PrepareItem(Items, 'Scripts'), rScripts do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('ScriptRemember1', ScriptRemember1);
      Properties.Add('ScriptRemember2', ScriptRemember2);
      Properties.Add('Includemov', Includemov);
      Properties.Add('LangFilterExcl', LangFilterExcl);
      Properties.Add('ListViewStyle', ListViewStyle);
      Properties.Add('ShowResGetInfo', ShowResGetInfo);
      Properties.Add('ShowResScripting', ShowResScripting);
      Properties.Add('CloseWinGetInfo', CloseWinGetInfo);
      Properties.Add('CloseWinScripting', CloseWinScripting);
      Properties.Add('AllowClearGetInfo', AllowClearGetInfo);
      Properties.Add('AllowClearScripting', AllowClearScripting);
      SaveList(PrepareItem(Items, 'MRU').Items, 'File', 'Name', ScriptMRU);
      with PrepareItem(Items, 'Properties'), rProperties do
      begin
        Properties.Add('WindowWidth', WindowWidth);
        Properties.Add('WindowHeight', WindowHeight);
      end;
      with PrepareItem(Items, 'Results'), rResults do
      begin
        Properties.Add('WindowState', WindowState);
        Properties.Add('WindowWidth', WindowWidth);
        Properties.Add('WindowHeight', WindowHeight);
      end;
      with PrepareItem(Items, 'ExtrasResults'), rExtrasResults do
      begin
        Properties.Add('WindowState', WindowState);
        Properties.Add('WindowWidth', WindowWidth);
        Properties.Add('WindowHeight', WindowHeight);
      end;
      with PrepareItem(Items, 'PickList'), rPickList do
      begin
        Properties.Add('WindowWidth', WindowWidth);
        Properties.Add('WindowHeight', WindowHeight);
      end;
      with PrepareItem(Items, 'PickTree'), rPickTree do
      begin
        Properties.Add('WindowWidth', WindowWidth);
        Properties.Add('WindowHeight', WindowHeight);
      end;
    end; // Scripts
    with PrepareItem(Items, 'Loan'), rLoan do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('MoviesHeight', LvMoviesHeight);
      Properties.Add('MoviesColWidth', LvMoviesColWidth);
      Properties.Add('MoviesSort', LvMoviesSort);
      Properties.Add('NamesWidth', LvNamesWidth);
      Properties.Add('NamesSort', LvNamesSort);
      Properties.Add('LentSort', LvLentSort);
      Properties.Add('IncludeSameNum', IncludeSameNum);
      Properties.Add('IncludeSameLabel', IncludeSameLabel);
    end; // Loan
    with PrepareItem(Items, 'Properties'), rProperties do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
    end; // Properties
    with PrepareItem(Items, 'Statistics'), rStatistics do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('EmptyMonths', EmptyMonths);
      Properties.Add('Legend', Legend);
      Properties.Add('Labels', Labels);
      Properties.Add('GroupValues', Group);
      Properties.Add('Includemov', Includemov);
    end; // Statistics
    with PrepareItem(Items, 'Renumber'), rRenumber do
    begin
      Properties.Add('SortOrder', OrderBy);
      Properties.Add('SortDescend', OrderDescend);
      SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', OrderFields, True);
    end; // Renumber
    with PrepareItem(Items, 'RenumberExtras'), rRenumberExtras do
    begin
      Properties.Add('SortOrder', OrderBy);
      Properties.Add('SortDescend', OrderDescend);
      SaveList(PrepareItem(Items, 'Fields').Items, 'Field', 'Name', OrderFields, True);
    end; // Renumber Extras
    with PrepareItem(Items, 'Options'), rOptions do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      with PrepareItem(Items, 'Display'), rDisplay do
      begin
        Properties.Add('ImagesInMenu', ImagesInMenu);
        Properties.Add('OfficeXP', OfficeXP);
        Properties.Add('IconSet', IconSet);
        Properties.Add('ColorType', ColorType);
        Properties.Add('Logo', Logo);
        Properties.Add('SoftBorders', SoftBorders);
        Properties.Add('NaturalCompare', NaturalCompare);
        Properties.Add('ScrollUnderPointer', ScrollUnderPointer);
        Properties.Add('AutoFocus', AutoFocus);
        Properties.Add('ForceRefresh', ForceRefresh);
      end; // Options/Display
      with PrepareItem(Items, 'Files'), rFiles do
      begin
//            Properties.Add('XMLHeader', XMLHeader);
        Properties.Add('Backup', Backup);
        Properties.Add('RecentFiles', RecentFiles);
        with PrepareItem(Items, 'AutoLoad') do
        begin
          Properties.Add('Enabled', AutoLoad);
          Properties.Add('File', AutoLoadFile);
          Properties.Add('Last', AutoLoadLast);
        end; // Options/Files/Autoload
        with PrepareItem(Items, 'AutoLoadCF') do
        begin
          Properties.Add('Enabled', AutoLoadCF);
          Properties.Add('File', AutoLoadCFFile);
        end; // Options/Files/AutoloadCF
        with PrepareItem(Items, 'History') do
        begin
          Properties.Add('Enabled', History);
          Properties.Add('File', HistoryFile);
        end; // Options/Files/History
        with PrepareItem(Items, 'HTMLTemplate') do
        begin
          Properties.Add('File', HTMLTemplateFile);
        end; // Options/Files/HTMLTemplate
      end; // Options/Files
      with PrepareItem(Items, 'MovieList'), rMovieList do
      begin
        with PrepareItem(Items, 'TitleDisplay') do
        begin
          Properties.Add('TitleColumn', TitleColumn);
          with PrepareItem(Items, 'Prefixes') do
          begin
            SaveList(Items, 'Item', 'Text', Prefixes);
            Properties.Add('Use', UsePrefixes);
          end; // Options/MovieList/TitleDisplay/Prefixes
          Properties.Add('TitleTemplate', TitleTemplate);
        end; // Options/MovieList/TitleDisplay
        Properties.Add('ConfirmDelete', ConfirmDelete);
        Properties.Add('ConfirmUndo', ConfirmUndo);
        Properties.Add('Checkboxes', Checkboxes);
        Properties.Add('CheckboxesInThumbs', CheckboxesInThumbs);
        Properties.Add('CheckboxesColor', CheckboxesColor);
        Properties.Add('LinesColor', LinesColor);
        Properties.Add('HotTrack', HotTrack);
        Properties.Add('EnhancedScrollbars', EnhancedScrollbars);
        Properties.Add('MovieNumColumn', MovieNumColumn);
        Properties.Add('GridTextSize', GridTextSize);
        Properties.Add('AutoStretchListGrid', AutoStretchListGrid);
        Properties.Add('AutoStretchListThumbs', AutoStretchListThumbs);
        Properties.Add('ShortcutPrev', ShortcutPrev);
        Properties.Add('ShortcutNext', ShortcutNext);
        Properties.Add('GroupCount', GroupCount);
        Properties.Add('GroupExpand', GroupExpand);
        Properties.Add('GroupsAbove', GroupsAbove);
        Properties.Add('GroupUnique', GroupUnique);
        Properties.Add('GroupMulti', GroupMulti);
        Properties.Add('GroupMultiSep', GroupMultiSep);
        Properties.Add('GroupMultiRmAllP', GroupMultiRmAllP);
        Properties.Add('GroupMultiAddPatch', GroupMultiAddPatch);
        Properties.Add('SortGroupsByCount', SortGroupsByCount);
        for i := 0 to Length(ColorsTag)-1 do
           Properties.Add('ColorTag'+IntToStr(i), ConvertColorToHTML(ColorsTag[i]));
      end; // Options/MovieList
      with PrepareItem(Items, 'ExtraList'), rExtraList do
      begin
        Properties.Add('ConfirmDelete', ConfirmDelete);
        Properties.Add('Checkboxes', Checkboxes);
        Properties.Add('NumWithTitle', NumWithTitle);
        Properties.Add('InfoWhenNoPic', InfoWhenNoPic);
        Properties.Add('CellBorders', CellBorders);
        Properties.Add('GroupCount', GroupCount);
        Properties.Add('GroupExpand', GroupExpand);
        Properties.Add('GroupsAbove', GroupsAbove);
        Properties.Add('GroupMulti', GroupMulti);
        Properties.Add('GroupMultiSep', GroupMultiSep);
        Properties.Add('GroupMultiRmAllP', GroupMultiRmAllP);
        Properties.Add('SortGroupsByCount', SortGroupsByCount);
        Properties.Add('ActionDoubleClick', ActionDoubleClick);
        Properties.Add('ActionKeyReturn', ActionKeyReturn);
      end; // Options/ExtraList
      with PrepareItem(Items, 'MovieInfo'), rMovieInformation do
      begin
        Properties.Add('AskNumber', AskNumber);
        Properties.Add('FirstAvailable', FirstAvailable);
        Properties.Add('AddScript', AddScript);
        Properties.Add('AddFiles', AddFiles);
        Properties.Add('RatingTrunc', RatingTrunc);
        Properties.Add('SetCurrentDate', SetCurrentDate);
        with PrepareItem(Items, 'Picture') do
        begin
          Properties.Add('Background', PictureBackground);
          Properties.Add('FitWindow', PictureFitWindow);
          Properties.Add('PictureInfo', PictureInfo);
        end; // Options/MovieInfo/Picture
        with PrepareItem(Items, 'MovieFrame') do
        begin
          Properties.Add('Background', MovieFrameBackground);
        end; // Options/MovieInfo/MovieFrame
        with PrepareItem(Items, 'HTMLDisplay') do
        begin
          Properties.Add('SearchFontTextColor', HTMLSearchFontTextColor);
          Properties.Add('SearchBackTextColor', HTMLSearchBackTextColor);
          Properties.Add('NoMoviePage', HTMLNoMoviePage);
        end; // Options/MovieInfo/HTMLDisplay
        with PrepareItem(Items, 'DefaultMovie'), rDefaultMovie do
        begin
          Properties.Add('WindowWidth', WindowWidth);
          Properties.Add('WindowHeight', WindowHeight);
          Values.SaveToXML(PrepareItem(Items, 'Values'), '', '', 100);
        end; // Options/MovieInfo/DefaultMovie
        with PrepareItem(Items, 'DefaultExtra'), rDefaultExtra do
        begin
          Properties.Add('WindowWidth', WindowWidth);
          Properties.Add('WindowHeight', WindowHeight);
          Values.SaveToXML(PrepareItem(Items, 'Values'), '', '', 100);
        end; // Options/MovieInfo/DefaultExtra
        with PrepareItem(Items, 'ImportInfo') do
        begin
          if ImportExt <> GetExtVideo then
            Properties.Add('ImportExt', ImportExt);
          Properties.Add('AllowClear', ImportAllowClear);
          Properties.Add('MediaLabel', ImportMediaLabel);
          Properties.Add('FileName', ImportFileName);
          Properties.Add('FileInFilePath', ImportFileInFilePath);
          Properties.Add('FileInURL', ImportFileInURL);
          Properties.Add('Size', ImportSize);
          Properties.Add('SizeString', ImportSizeString);
          Properties.Add('SizeUnit', Integer(ImportSizeUnit));
          Properties.Add('Picture', ImportPicture);
          Properties.Add('InternalAVI', ImportInternalAVI);
          Properties.Add('Length', ImportLength);
          Properties.Add('Resolution', ImportResolution);
          Properties.Add('Framerate', ImportFramerate);
          Properties.Add('VideoCodec', ImportVideoCodec);
          Properties.Add('VideoBitrate', ImportVideoBitrate);
          Properties.Add('AudioCodec', ImportAudioCodec);
          Properties.Add('AudioChannels', ImportAudioChannels);
          Properties.Add('AudioBitrate', ImportAudioBitrate);
          Properties.Add('Languages', ImportLanguages);
          Properties.Add('Subtitles', ImportSubtitles);
        end; // Options/MovieInfo/ImportInfo
        SaveList(PrepareItem(Items, 'FilterFileName').Items, 'Filter', 'Value', FilterFileName);
        SaveList(PrepareItem(Items, 'PosterNames').Items, 'Poster', 'Name', PosterNames);
        with PrepareItem(Items, 'PicImport'), rPicImport do
        begin
          Properties.Add('GetInfoMethod', GetInfoMethod);
          Properties.Add('ScriptingMethod', ScriptingMethod);
          Properties.Add('PicConvertJPG', PicConvertJPG);
          Properties.Add('MaxPicSizeW', MaxPicSizeW);
          Properties.Add('MaxPicSizeH', MaxPicSizeH);
        end; // Options/MovieInfo/PicImport
        with PrepareItem(Items, 'ExtraPicImport'), rExtraPicImport do
        begin
          Properties.Add('GetInfoMethod', GetInfoMethod);
          Properties.Add('ScriptingMethod', ScriptingMethod);
          Properties.Add('PicConvertJPG', PicConvertJPG);
          Properties.Add('MaxPicSizeW', MaxPicSizeW);
          Properties.Add('MaxPicSizeH', MaxPicSizeH);
        end; // Options/MovieInfo/ExtraPicImport
        with PrepareItem(Items, 'PictureNaming'), PictureNaming do
        begin
          Save(Items);
        end; // Options/MovieInfo/PictureNaming
        SaveList(PrepareItem(Items, 'Search').Items, 'Site', 'Address', SearchSites);
        with PrepareItem(Items, 'Lists') do
        begin
          Properties.Add('SameForAll', ComboSameForAll);
          for i := 0 to Length(rCombo)-1 do
          begin
            with PrepareItem(Items, strXMLDdl[i]), rCombo[i] do
            begin
              SaveList(Items, 'Item', 'Text', Contents);
              Properties.Add('AutoAdd', AutoAdd);
              Properties.Add('Sorted', Sort);
              Properties.Add('AutoComplete', AutoComplete);
              Properties.Add('UseCatalogValues', UseCatalogValues);
            end;
          end;
        end;
      end; // Options/MovieInfo
      with PrepareItem(Items, 'Scripting'), rScripting do
      begin
        Properties.Add('Autorun', ScriptAutorun);
        with PrepareItem(Items, 'Proxy') do
        begin
          Properties.Add('Use', Proxy);
          Properties.Add('Server', ProxyServer);
          Properties.Add('Port', ProxyPort);
          Properties.Add('Username', ProxyUsername);
          Properties.Add('Password', Encrypt(ProxyPassword));
          Properties.Add('KeepConnection', KeepConnection);
          Properties.Add('HTTP10', HTTP10);
        end;
      end; // Options/Scripting
      with PrepareItem(Items, 'Export'), rExport do
      begin
        Properties.Add('LoadTemplate', LoadTemplate);
        Properties.Add('LineBreak', Linebreak);
        Properties.Add('ForcePicSizeW', ForcePicSizeW);
        Properties.Add('ForcePicSizeH', ForcePicSizeH);
        Properties.Add('ForceExtraPicSizeW', ForceExtraPicSizeW);
        Properties.Add('ForceExtraPicSizeH', ForceExtraPicSizeH);
        Properties.Add('SQLDate', SQLDate);
        Properties.Add('RememberLastFile', RememberLastFile);
        Properties.Add('LastFile', LastFile);
        Properties.Add('OpenExportedFile', OpenExportedFile);
        with PrepareItem(Items, 'ExpFileNaming'), ExpFileNaming do
        begin
          Save(Items);
        end; // ExpFileNaming
        Properties.Add('ExpFileExt', ExpFileExt);
        Properties.Add('CopyPictures', CopyPictures);
        Properties.Add('CopyPicturesInPicDir', CopyPicturesInPicDir);
        Properties.Add('CopyPicturesNew', CopyPicturesNew);
        Properties.Add('CopyPicturesIncExtras', CopyPicturesIncExtras);
        Properties.Add('PicturesExportMethodAMC', PicturesExportMethodAMC);
        Properties.Add('PicturesExportMethodXML', PicturesExportMethodXML);
        Properties.Add('ExtraPicturesExportMethodAMC', ExtraPicturesExportMethodAMC);
        Properties.Add('ExtraPicturesExportMethodXML', ExtraPicturesExportMethodXML);
        Properties.Add('PicturesSaveXMLInPicDir', PicturesSaveXMLInPicDir);
      end; // Options/Export
      with PrepareItem(Items, 'Folders') do
      begin
        Properties.Add('SameForAll', SameFolderForAll);
        Items.Clear;
        for i := 0 to length(rFolders)-1 do
          with rFolders[i] do
            rFolders[i].Save(Items, i);
      end; // Options/Folders
      with PrepareItem(Items, 'Language'), rLanguage do
      begin
        Properties.Add('File', Language);
      end; // Options/Languages
    end; // Options
    with PrepareItem(Items, 'CustomFieldsManager'), rCustomFieldsManager do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
    end; // CustomFieldsManager
    with PrepareItem(Items, 'StringFilter'), rStringFilter do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
    end; // StringFilter
    with PrepareItem(Items, 'HTMLEditor'), rHTMLEditor do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
      Properties.Add('LastTemplate', HTMLLastTemplate);
      SaveList(PrepareItem(Items, 'MRU').Items, 'File', 'Name', HTMLMRU);
    end; // HTMLEditor
    with PrepareItem(Items, 'ExtrasEdit'), rExtrasEdit do
    begin
      Properties.Add('WindowWidth', WindowWidth);
      Properties.Add('WindowHeight', WindowHeight);
      Properties.Add('WindowState', WindowState);
    end; // ExtrasEdit
  end;
  try
    FXml.SaveToFile(strFileSettings);
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TSettings.GetLanguageFile: string;
begin
  if rOptions.rLanguage.Language = '' then
    Result := ''
  else
    result := strDirLanguages + rOptions.rLanguage.Language+'.lng'
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TSettings.GetFilesSizeUnit(const ByteString: string): string;
begin
  case rOptions.rMovieInformation.ImportSizeUnit of
    fsuGB:   Result := 'G' + ByteString;
    fsuMB:   Result := 'M' + ByteString;
    fsuKB:   Result := 'K' + ByteString;
  else
    Result := ByteString;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetCurItem(Root: TJvSimpleXmlElem; const ItemName: string): TJvSimpleXmlElem;
begin
  Result := Root.Items.ItemNamed[ItemName];
  if Result = nil then
  begin
    Result := Root.Items.Add(ItemName);
    Result.Parent := Root;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure LoadList(Items: TJvSimpleXmlElems; const PropName: string; List: TStrings;
  ConvertFieldTagToId: Boolean; KeepItemName: Boolean);
var
  i, field: Integer;
  val, str, order: string;
begin
  List.Clear;
  with Items do
    for i := 0 to Count-1 do
      if Item[i].Properties.ItemNamed[PropName] <> nil then
      begin
        val := Item[i].Properties.ItemNamed[PropName].Value;

        if ConvertFieldTagToId then
        begin
          str := val;
          if Length(str) > 0 then
          begin
            order := '';
            if str[1] = '-' then
            begin
              System.Delete(str, 1, 1);
              order := '-';
            end;
            if Length(str) > 0 then
            begin
              if not (str[1] in ['0'..'9']) then // movie field or extras field (Field Id)
              begin
                field := IndexText(str, strTagFields);
                if field = -1 then
                begin
                  field := IndexText(str, strTagExtraFields);
                  if field <> -1 then
                    field := field + extraFieldLow;
                end;
                if field = -1 then
                  if SameText(str, strTagFieldPicture) then
                    field := fieldPicture;
                if field = -1 then
                  if SameText(str, strTagExtraFieldPicture) then
                    field := extraFieldPicture;
                if field <> -1 then
                  val := order + IntToStr(field);
              end;
            end;
          end;
        end;

        if KeepItemName then
          List.Values[Item[i].Name] := val
        else
          List.Add(val);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function PrepareItem(Items: TJvSimpleXmlElems; const AName: string): TJvSimpleXmlElem;
begin
  Result := Items.ItemNamed[AName];
  if Result = nil then
    Result := Items.Add(AName)
  else
    Result.Properties.Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure SaveList(Items: TJvSimpleXmlElems; const SubItemName, PropName: string;
  List: TStrings; ConvertFieldIdToTag: Boolean = False);
var
  i, field: Integer;
  val, str, order: string;
begin
  Items.Clear;
  for i := 0 to List.Count-1 do
  begin
    if SubItemName = '' then
      val := List.ValueFromIndex[i]
    else
      val := List.Strings[i];

    if ConvertFieldIdToTag then
    begin
      str := val;
      if Length(str) > 0 then
      begin
        order := '';
        if str[1] = '-' then
        begin
          System.Delete(str, 1, 1);
          order := '-';
        end;
        if Length(str) > 0 then
        begin
          if (str[1] in ['0'..'9']) then // movie field or extras field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= fieldLow) and (field < fieldCount) then
              val := order + strTagFields[field]
            else if (field >= extraFieldLow) and (field < extraFieldCount) then
              val := order + strTagExtraFields[field - extraFieldLow]
            else if field = fieldPicture then
              val := order + strTagFieldPicture
            else if field = extraFieldPicture then
              val := order + strTagExtraFieldPicture;
          end;
        end;
      end;
    end;

    if SubItemName = '' then
      with Items.Add(List.Names[i]) do
        Properties.Add(PropName, val)
    else
      with Items.Add(SubItemName) do
        Properties.Add(PropName, val);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
