(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit import2_engines;

interface

uses
  Windows, Classes, Types, SysUtils, ComCtrls, Contnrs, IniFiles, Forms, Dialogs,

  movieclass, interfaces, fields, ElTree, ElList, ElHeader;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  ConnectStringAccess = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Mode=Read;Persist Security Info=False';

type

  TFieldCorresp = record
    SourceField: Integer;
    TargetField: Integer;
  end;
  TFieldCorresps = array of TFieldCorresp;

  TImportEngine = class(TObject)
  private
  protected
    FFormatName: string;
    FImportWin: TForm;
    FColumnsName: TStrings;
    FCancel: Boolean;
    procedure OnCancelProc(Sender: TObject); virtual;
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); virtual;
    procedure AfterImport(const AListView: TElTree); virtual;
  public
    Properties: TCustomFieldsProperties; // ref
    constructor Create(const AFormatName: string; CustomFieldsProperties: TCustomFieldsProperties;
      ImportWin: TForm);
    destructor Destroy; override;
    procedure Import(const AFileName: TFileName; AListView: TElTree);
    function GetURL: string; virtual;
    property FormatName: string read FFormatName;
    function GetFilter: string; virtual;
    procedure GetFieldCorresp(out fc: TFieldCorresps; HeaderSections: TElHeaderSections); virtual;
    function GetExtraSep: string; virtual;
    function AdjustValue(const ATargetField: Integer; AValue: string): string; virtual;
    function GetHint(const AColumnId: Integer; AColumnValue: string): string; virtual;
    procedure ExtractDelayedInfo(AListView: TElTree; const Idx: Integer; var FCancelImport: Boolean); virtual;
  end;

  TImportEngineCsv = class(TImportEngine)
  private
  protected
    procedure ImportFromCsv(const AStream: TStream; AListView: TElTree; const Delim, Quote: Char);
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    function GetFilter: string; override;
    function GetExtraSep: string; override;
    function AdjustValue(const ATargetField: Integer; AValue: string): string; override;
  end;

  TImportEngineAmc = class(TImportEngine)
  private
    FList: TMovieList;
  protected
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    destructor Destroy; override;
    function GetFilter: string; override;
    function GetURL: string; override;
    procedure GetFieldCorresp(out fc: TFieldCorresps; HeaderSections: TElHeaderSections); override;
  end;

  TImportEngineDll = class(TImportEngine)
  private
  protected
    FDll: Cardinal;
  public
    constructor Create(const AFormatName: string; CustomFieldsProperties: TCustomFieldsProperties;
      ImportWin: TForm);
    destructor Destroy; override;
  end;

  TImportEngineMdb = class(TImportEngineDll)
  private
  protected
    procedure ImportFromMdb(const AFileName: TFileName; AListView: TElTree; AFrom, AWhere: string);
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    function GetFilter: string; override;
    procedure ListTables(const AFileName: TFileName; AList: TStrings);
  end;

  TImportEngineDvdpro = class(TImportEngine)
  private
  protected
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    function GetFilter: string; override;
    function GetURL: string; override;
  end;

  TImportEngineGCstar = class(TImportEngine)
  private
  protected
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    function GetFilter: string; override;
    function GetURL: string; override;
  end;

  TImportEngineDir = class(TImportEngine)
  private
    FFileList: TStringList; // Needed to import advanced media info during delayed extract
    FExtractDelayed: Boolean; // To know if extract of advanced media info is delayed or not
  protected
    procedure ImportFromDir(const AFileName: TFileName; AListView: TElTree; BrowseDepth: Integer; MultiDisks: Boolean; DiskTag: string);
    procedure DoImport(const AFileName: TFileName; AListView: TElTree); override;
    procedure AfterImport(const AListView: TElTree); override;
  public
    destructor Destroy; override;
    function GetFilter: string; override;
    function AdjustValue(const ATargetField: Integer; AValue: string): string; override;
    procedure ExtractDelayedInfo(AListView: TElTree; const Idx: Integer; var FCancelImport: Boolean); override;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Math, Global,
  JvSimpleXml, functions_str,
  ConstValues, ProgramSettings, getmedia, import2, progress;

{-------------------------------------------------------------------------------
  TImportEngine
-------------------------------------------------------------------------------}

constructor TImportEngine.Create(const AFormatName: string;
  CustomFieldsProperties: TCustomFieldsProperties; ImportWin: TForm);
begin
  FFormatName := AFormatName;
  Properties := CustomFieldsProperties;
  FImportWin := ImportWin;
  FColumnsName := TStringList.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportEngine.Destroy;
begin
  FColumnsName.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngine.GetURL: string;
begin
  Result := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.OnCancelProc(Sender: TObject);
begin
  FCancel := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.Import(const AFileName: TFileName; AListView: TElTree);
var
  MaxCol: Integer;
  i, n: Integer;
begin
  if AFileName = '' then
    Abort;
  //AListView.Items.Clear;
  //AListView.HeaderSections.Clear;
  AListView.Items.BeginUpdate;
  try
    AListView.Items.Clear;
    AListView.HeaderSections.Clear;
    AListView.ShowColumns := False;
    FColumnsName.Clear;
    DoImport(AFileName, AListView);
    MaxCol := 0;
    for i := 0 to AListView.Items.Count-1 do
    begin
      MaxCol := Max(MaxCol, AListView.Items[i].SubItems.Count);
      AListView.Items[i].Tag := i;
    end;
    if MaxCol > 0 then
    begin
      // Add empty main column for checkboxes
      with AListView.HeaderSections.AddSection do
      begin
        Text := '';
        FieldName := '-1';
        FieldType := sftCustom;
        Width := 50;
      end;
      for i := 0 to MaxCol - 1 do
        with AListView.HeaderSections.AddSection do
        begin
          Text := '';
          FieldName := '-1';
          FieldType := sftCustom;//sftText;
          Width := 100;
        end;
      AListView.MainTreeColumn := 0;
      AListView.ShowColumns := True;
      AlistView.SortSection := 0;
      AlistView.HeaderSections[AlistView.SortSection].SortMode := hsmAscend;
      //AlistView.Sort(True); // Not needed, already sorted on this column
    end;
    AfterImport(AListView);
    for i := 1 to AListView.HeaderSections.Count - 1 do
      with AListView.HeaderSections[i] do
      begin
        n := StrToInt(FieldName);
        if n = fieldPicture then
          Text := strFieldPicture
        else if n = extraFieldPicture then
          Text := strExtraFieldPicture + ' (' + strExtras + ')'
        else if n in (AllFields - VirtualFields) then
          Text := strFields[n]
        else if n in (AllExtraFields - VirtualFields) then
          Text := strExtraFields[n - extraFieldLow] + ' (' + strExtras + ')'
        else if (n >= customFieldLow) and
          (n - customFieldLow < Properties.Count) and
          (Properties.Objects[n - customFieldLow].FieldType <> ftVirtual) then
          Text := Properties.Objects[n - customFieldLow].FieldName
        else
          FieldName := '-1';
      end;
  finally
    AListView.Items.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.AfterImport(const AListView: TElTree);
begin

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.DoImport(const AFileName: TFileName; AListView: TElTree);
begin

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngine.GetFilter: string;
begin
  Result := '*.*|*.*';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.GetFieldCorresp(out fc: TFieldCorresps; HeaderSections: TElHeaderSections);
var
  i: Integer;
begin
  SetLength(fc, HeaderSections.Count-1);
  for i := 1 to HeaderSections.Count-1 do
  begin
    fc[i-1].SourceField := -1;
    fc[i-1].TargetField := StrToInt(HeaderSections[i].FieldName);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngine.GetExtraSep: string;
begin
  Result := defaultExtraSepImport;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngine.AdjustValue(const ATargetField: Integer; AValue: string): string;
begin
  Result := AValue;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngine.GetHint(const AColumnId: Integer; AColumnValue: string): string;
begin
  AColumnValue := StringReplace(AColumnValue, '|', ' ', [rfReplaceAll]);
  AColumnValue := StringReplace(AColumnValue, #13#10, ' ', [rfReplaceAll]);
  if AColumnId = 0 then
    Result := ''
  else if AColumnId-1 < FColumnsName.Count then
    Result := FColumnsName.Strings[AColumnId-1] + ' = ' + AColumnValue
  else
    Result := AColumnValue;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngine.ExtractDelayedInfo(AListView: TElTree; const Idx: Integer; var FCancelImport: Boolean);
begin

end;

{-------------------------------------------------------------------------------
  TImportEngineCsv
-------------------------------------------------------------------------------}

procedure TImportEngineCsv.DoImport(const AFileName: TFileName; AListView: TElTree);
var
  f: TFileStream;
begin
  f := TFileStream.Create(AFileName, fmOpenRead);
  try
    // Import values
    ImportFromCsv(f, AListView, StrToChar(Settings.rImport.rCsv.Delim), StrToChar(Settings.rImport.rCsv.Quote));
  finally
    f.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineCsv.AfterImport(const AListView: TElTree);
var
  i, fld: Integer;
  s: string;
begin
  if (Settings.rImport.rCsv.FirstLineHeaders) and (AListView.Items.Count > 0) then
  begin
    // Set columns name
    for i := 1 to AListView.HeaderSections.Count-1 do
    begin
      if i <= AListView.Items[0].SubItems.Count then
        FColumnsName.Add(AListView.Items[0].SubItems.Strings[i-1])
      else
        FColumnsName.Add('');
    end;

    if Settings.rImport.AutoAssign then
    begin
      for i := 1 to AListView.HeaderSections.Count-1 do
      begin
        if i <= AListView.Items[0].SubItems.Count then
          s := AListView.Items[0].SubItems.Strings[i-1]
        else
          Break;
        if SameText(s, strFieldPicture) or SameText(s, strTagFieldPicture) then
          fld := fieldPicture
        else if SameText(s, strExtraFieldPicture) or SameText(s, strTagExtraFieldPicture) then
          fld := extraFieldPicture
        else
        begin
          fld := IndexText(s, strTagFields);
          if fld = -1 then
            fld := strFields.IndexOf(s);
          if fld = -1 then
          begin
            fld := IndexText(s, strTagExtraFields);
            if fld = -1 then
              fld := strExtraFields.IndexOf(s);
            if fld <> -1 then
              fld := fld + extraFieldLow;
          end;
          if fld = -1 then
          begin
            fld := Properties.IndexOf(s);
            if fld <> -1 then
            begin
              if Properties.Objects[fld].FieldType <> ftVirtual then
                fld := fld + customFieldLow
              else
                fld := -1;
            end;
          end;
        end;
        if (fld <> -1) and not (fld in VirtualFields) then
          with AListView.HeaderSections[i] do
            FieldName := IntToStr(fld);
      end;
    end;
    AListView.Items.Item[0].Delete;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineCsv.GetFilter: string;
begin
  Result := DialogCSVFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineCsv.ImportFromCsv(const AStream: TStream; AListView: TElTree; const Delim, Quote: Char);
var
  c, cc: Char;
  s: string;
  CurItem: TElTreeItem;
  InStr: Boolean;
  NbLines, NbRead: Integer;
begin
  CurItem := nil;
  s := '';
  InStr := False;

  FCancel := False;
  with ProgressWin do
  begin
    Maximum := 1;
    IntProgress := 0;
    Progress := '';
    Status := Format(TImportWin2(FImportWin).Messages.Strings[msgImportFrom], [FormatName]);
    Execute(FImportWin);
    OnCancel := OnCancelProc;
    try
      NbLines := 0;
      NbRead := 0;
      AStream.Seek(0, soBeginning);
      while (AStream.Read(c, 1) > 0) and (not FCancel) do
      begin
        Inc(NbRead);
        if NbRead > 1000 then
        begin
          Application.ProcessMessages;
          NbRead := 0;
        end;
        if c = Quote then
        begin
          if (s = '') and (not InStr) then
          begin
            InStr := True;
            Continue;
          end;
          AStream.Read(c, 1);
          if c <> Quote then
          begin
            if InStr then
            begin
              InStr := False;
              AStream.Seek(-1, soFromCurrent);
              Continue;
            end;
          end;
        end;
        if (c in [Delim, #13, #10]) and not InStr then
        begin
          if CurItem = nil then
          begin
            CurItem := AListView.Items.AddChild(nil, '');
            CurItem.ShowCheckBox := True;
            CurItem.Checked := True;
          end;
          CurItem.SubItems.Add(s);
          s := '';
          if c in [#13, #10] then
          begin
            CurItem := nil;
            cc := c;
            AStream.Read(c, 1);
            // support for linux/mac/win linebreaks
            if ((cc = #13) and not (c = #10)) or ((cc = #10) and not (c = #13)) then
              AStream.Seek(-1, soFromCurrent);
            Inc(NbLines);
            Progress := IntToStr(NbLines);
          end;
          Continue;
        end;
        s := s + c;
      end;
      if (CurItem <> nil) then
        CurItem.SubItems.Add(s);
    finally
      OnCancel := nil;
      Close;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineCsv.GetExtraSep: string;
begin
  Result := Settings.rImport.rCsv.DelimExtras;
  if Result = '' then
    Result := defaultExtraSepImport
  else if Result = '[tab]' then
    Result := #9;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineCsv.AdjustValue(const ATargetField: Integer; AValue: string): string;
begin
  Result := AValue;
  with Settings.rImport.rCsv do
    if (Linebreaks <> '') then
    begin
      if (ATargetField < fieldCount) and (GetFieldType(ATargetField) = ftText) then
        Result := StringReplace(AValue, Linebreaks, sLineBreak, [rfReplaceAll])
      else if (ATargetField >= extraFieldLow) and (ATargetField < extraFieldCount) and
        (GetFieldType(ATargetField) = ftText) then
        Result := StringReplace(AValue, Linebreaks, sLineBreak, [rfReplaceAll])
      else if (ATargetField >= customFieldLow) and (ATargetField - customFieldLow < Properties.Count) and
        (Properties.Objects[ATargetField - customFieldLow].FieldType = ftText) then
        Result := StringReplace(AValue, Linebreaks, sLineBreak, [rfReplaceAll]);
    end;
end;

{-------------------------------------------------------------------------------
  TImportEngineAmc
-------------------------------------------------------------------------------}

procedure TImportEngineAmc.DoImport(const AFileName: TFileName; AListView: TElTree);
var
  i, f: Integer;
  Mov: TMovie;
  Item: TElTreeItem;
begin
  Assert(fieldLow = 0);
  FreeAndNil(FList);
  FList := TMovieList.Create;
  if LowerCase(ExtractFileExt(AFileName)) = extCatalog[extXML] then
    FList.LoadFromXML(AFileName)
  else
    FList.LoadFromFile(AFileName);

  // Set columns name
  for i := fieldLow to fieldCount-1 do
    if not (i in VirtualFields) then
      FColumnsName.Add(strFields.Strings[i]);
  FColumnsName.Add(strFieldPicture);
  for i := 0 to FList.CustomFieldsProperties.Count-1 do
    if (FList.CustomFieldsProperties.Objects[i].FieldType <> ftVirtual) then
      FColumnsName.Add(FList.CustomFieldsProperties.Objects[i].FieldName);
  for i := extraFieldLow to extraFieldCount-1 do
    if not (i in VirtualFields) then
      FColumnsName.Add(strExtraFields.Strings[i - extraFieldLow] + ' (' + strExtras + ')');
  FColumnsName.Add(strExtraFieldPicture + ' (' + strExtras + ')');

  // Import values
  FCancel := False;
  with ProgressWin do
  begin
    Maximum := FList.Count;
    IntProgress := 0;
    Status := Format(TImportWin2(FImportWin).Messages.Strings[msgImportFrom], [FormatName]);
    Execute(FImportWin);
    OnCancel := OnCancelProc;
    try
      i := 0;
      while (i < FList.Count) and (not FCancel) do
      begin
        Mov := FList[i];
        Item := AListView.Items.AddChild(nil, '');
        Item.ShowCheckBox := True;
        Item.Checked := True;
        Item.Data := Mov;
        for f := fieldLow to fieldCount-1 do
          if not (f in VirtualFields) then
            Item.SubItems.Add(Mov.GetFieldValue(f, True));
        if Mov.Picture.PicStream = nil then
          Item.SubItems.Add(Mov.Picture.PicPath)
        else
          Item.SubItems.Add(Format('<%s>', [strFieldPicture]));
        with FList.CustomFieldsProperties do
          for f := 0 to Count-1 do
            if (FList.CustomFieldsProperties.Objects[f].FieldType <> ftVirtual) then
              Item.SubItems.Add(Mov.CustomFields.GetFieldValue(Strings[f], True));
        for f := extraFieldLow to extraFieldCount-1 do
          if not (f in VirtualFields) then
            Item.SubItems.Add(Mov.Extras.GetFieldValues(f, defaultExtraSepImport, True));
        Item.SubItems.Add(Mov.Extras.GetPictureValues(defaultExtraSepImport,
          Format('<%s>', [strFieldPicture]), False));
        Inc(i);
        StepIt;
      end;
    finally
      OnCancel := nil;
      Close;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineAmc.AfterImport(const AListView: TElTree);
var
  c, f, i: Integer;
begin
  if Settings.rImport.AutoAssign then
  begin
    c := 1;
    for f := fieldLow to fieldCount-1 do
      if not (f in VirtualFields) and (c < AListView.HeaderSections.Count) then
      begin
        AListView.HeaderSections[c].FieldName := IntToStr(f);
        Inc(c);
      end;
    if c < AListView.HeaderSections.Count then
      AListView.HeaderSections[c].FieldName := IntToStr(fieldPicture);
    Inc(c);
    with FList.CustomFieldsProperties do
      for f := 0 to Count-1 do
        if (FList.CustomFieldsProperties.Objects[f].FieldType <> ftVirtual) and
          (c < AListView.HeaderSections.Count) then
        begin
          AListView.HeaderSections[c].FieldName := '-1';
          i := Properties.IndexOf(Strings[f]);
          if (i <> -1) and (Properties.Objects[i].FieldType <> ftVirtual) then
            AListView.HeaderSections[c].FieldName := IntToStr(i + customFieldLow);
          Inc(c);
        end;
    for f := extraFieldLow to extraFieldCount-1 do
      if not (f in VirtualFields) and (c < AListView.HeaderSections.Count) then
      begin
        AListView.HeaderSections[c].FieldName := IntToStr(f);
        Inc(c);
      end;
    if c < AListView.HeaderSections.Count then
      AListView.HeaderSections[c].FieldName := IntToStr(extraFieldPicture);
    //Inc(c);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineAmc.GetFilter: string;
begin
  Result := DialogCatalogFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineAmc.GetURL: string;
begin
  Result := 'http://www.antp.be/software/moviecatalog/';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportEngineAmc.Destroy;
begin
  FreeAndNil(FList);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineAmc.GetFieldCorresp(out fc: TFieldCorresps; HeaderSections: TElHeaderSections);
var
  c, f: Integer;
begin
  SetLength(fc, HeaderSections.Count-1);
  c := 1;
  for f := fieldLow to fieldCount-1 do
    if not (f in VirtualFields) and (c < HeaderSections.Count) then
    begin
      fc[c-1].SourceField := f;
      fc[c-1].TargetField := StrToInt(HeaderSections[c].FieldName);
      Inc(c);
    end;
  if c < HeaderSections.Count then
  begin
    fc[c-1].SourceField := fieldPicture;
    fc[c-1].TargetField := StrToInt(HeaderSections[c].FieldName);
    Inc(c);
  end;
  with FList.CustomFieldsProperties do
    for f := 0 to Count-1 do
      if (Objects[f].FieldType <> ftVirtual) and (c < HeaderSections.Count) then
      begin
        fc[c-1].SourceField := f + customFieldLow;
        fc[c-1].TargetField := StrToInt(HeaderSections[c].FieldName);
        Inc(c);
     end;
  for f := extraFieldLow to extraFieldCount-1 do
    if not (f in VirtualFields) and (c < HeaderSections.Count) then
    begin
      fc[c-1].SourceField := f;
      fc[c-1].TargetField := StrToInt(HeaderSections[c].FieldName);
      Inc(c);
    end;
  if c < HeaderSections.Count then
  begin
    fc[c-1].SourceField := extraFieldPicture;
    fc[c-1].TargetField := StrToInt(HeaderSections[c].FieldName);
    //Inc(c);
  end;
end;

{-------------------------------------------------------------------------------
  TImportEngineDll
-------------------------------------------------------------------------------}

constructor TImportEngineDll.Create(const AFormatName: string;
  CustomFieldsProperties: TCustomFieldsProperties; ImportWin: TForm);
begin
  inherited;
  FDll := LoadLibrary(PChar(strFileExchangeDLL));
  if FDll = 0 then
    RaiseLastOSError; 
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportEngineDll.Destroy;
begin
  FreeLibrary(FDll);
  inherited;
end;

{-------------------------------------------------------------------------------
  TImportEngineMdb
-------------------------------------------------------------------------------}

procedure TImportEngineMdb.AfterImport(const AListView: TElTree);
var
  i, fld: Integer;
  s: string;
begin
  if AListView.Items.Count > 0 then
  begin
    if Settings.rImport.AutoAssign then
    begin
      for i := 1 to AListView.HeaderSections.Count-1 do
      begin
        if i <= AListView.Items[0].SubItems.Count then
          s := AListView.Items[0].SubItems[i-1]
        else
          Break;
        if SameText(s, strTagFieldPicture) then
          fld := fieldPicture
        else
        begin
          fld := IndexText(s, strTagFields);
          if fld = -1 then
          begin
            fld := Properties.IndexOf(s);
            if fld <> -1 then
            begin
              if Properties.Objects[fld].FieldType <> ftVirtual then
                fld := fld + customFieldLow
              else
                fld := -1;
            end;
          end;
        end;
        if (fld <> -1) and not (i in VirtualFields) then
          AListView.HeaderSections[i].FieldName := IntToStr(fld);
      end;
      AListView.Items.Item[0].Delete;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineMdb.DoImport(const AFileName: TFileName; AListView: TElTree);
begin
  if Settings.rImport.rQuery.From <> '' then
    ImportFromMdb(AFileName, AListView, Settings.rImport.rQuery.From, Settings.rImport.rQuery.Where);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineMdb.GetFilter: string;
begin
  Result := DialogMDBFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineMdb.ImportFromMdb(const AFileName: TFileName; AListView: TElTree; AFrom, AWhere: string);
var
  QueryCreator: TWrappedQueryCreator;
  Query: IWrappedQuery;
  i, nb: Integer;
  CurItem: TElTreeItem;
  q, s: string;
  procedure AddCaption(const S: string);
  begin
    if CurItem = nil then
    begin
      CurItem := AListView.Items.AddChild(nil, '');
      CurItem.ShowCheckBox := True;
      CurItem.Checked := True;
    end;
    CurItem.SubItems.Add(S);
  end;
begin
  @QueryCreator := GetProcAddress(FDll, 'CreateAdoQuery');
  if @QueryCreator <> nil then
  begin
    Query := QueryCreator;
    if not Query.Connect(Format(ConnectStringAccess, [AFileName])) then
      raise Exception.Create(Query.LastError);
    try
      CurItem := nil;
      q := 'SELECT * FROM ' + AFrom;
      if AWhere <> '' then
        q := Format('%s WHERE %s', [q, AWhere]);
      Query.SetSQL(q);
      if not Query.Open then
        raise Exception.Create(Query.LastError);
      try
        // Set columns name
        if (not Query.Eof) then
        begin
          for i := 0 to Query.FieldCount-1 do
          begin
            s := Query.FieldName(i);
            if (Settings.rImport.AutoAssign) then
              AddCaption(s);
            FColumnsName.Add(s);
          end;
          CurItem := nil;
        end;
        FCancel := False;
        with ProgressWin do
        begin
          Maximum := 1;
          IntProgress := 0;
          Progress := '';
          Status := Format(TImportWin2(FImportWin).Messages.Strings[msgImportFrom], [FormatName]);
          Execute(FImportWin);
          OnCancel := OnCancelProc;
          try
            nb := 0;
            while (not Query.Eof) and (not FCancel) do
            begin
              for i := 0 to Query.FieldCount-1 do
                AddCaption(Query.Value(i));
              CurItem := nil;
              Query.Next;
              Inc(nb);
              Progress := IntToStr(nb);
            end;
          finally
            OnCancel := nil;
            Close;
          end;
        end;
      finally
        Query.Close;
      end;
    finally
      Query.Disconnect;
      Query := nil;
    end;
  end
  else
    RaiseLastOSError;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineMdb.ListTables(const AFileName: TFileName; AList: TStrings);
var
  QueryCreator: TWrappedQueryCreator;
  Query: IWrappedQuery;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    @QueryCreator := GetProcAddress(FDll, 'CreateAdoQuery');
    if @QueryCreator <> nil then
    begin
      Query := QueryCreator;
      if not Query.Connect(Format(ConnectStringAccess, [AFileName])) then
        raise Exception.Create(Query.LastError);
      try
        AList.Text := Query.ListTables;
      finally
        Query.Disconnect;
        Query := nil;
      end;
    end
    else
      RaiseLastOSError;
  finally
    AList.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
 TImportEngineDvdpro
-------------------------------------------------------------------------------}

procedure TImportEngineDvdpro.AfterImport(const AListView: TElTree);
begin
  if (AListView.Items.Count > 0) and Settings.rImport.AutoAssign
    and (AListView.HeaderSections.Count >= 31) then
  begin
    AListView.HeaderSections[5].FieldName := IntToStr(fieldOriginalTitle);
    AListView.HeaderSections[8].FieldName := IntToStr(fieldMedia);
    AListView.HeaderSections[9].FieldName := IntToStr(fieldNumber);
    AListView.HeaderSections[11].FieldName := IntToStr(fieldCountry);
    AListView.HeaderSections[12].FieldName := IntToStr(fieldYear);
    AListView.HeaderSections[14].FieldName := IntToStr(fieldLength);
    AListView.HeaderSections[15].FieldName := IntToStr(fieldMediaType);
    AListView.HeaderSections[16].FieldName := IntToStr(fieldCategory);
    AListView.HeaderSections[17].FieldName := IntToStr(fieldResolution);
    AListView.HeaderSections[18].FieldName := IntToStr(fieldVideoFormat);
    AListView.HeaderSections[20].FieldName := IntToStr(fieldLanguages);
    AListView.HeaderSections[22].FieldName := IntToStr(fieldAudioFormat);
    AListView.HeaderSections[23].FieldName := IntToStr(fieldSubtitles);
    AListView.HeaderSections[24].FieldName := IntToStr(fieldActors);
    AListView.HeaderSections[25].FieldName := IntToStr(fieldDirector);
    AListView.HeaderSections[26].FieldName := IntToStr(fieldWriter);
    AListView.HeaderSections[27].FieldName := IntToStr(fieldProducer);
    AListView.HeaderSections[28].FieldName := IntToStr(fieldDate);
    AListView.HeaderSections[29].FieldName := IntToStr(fieldDescription);
    AListView.HeaderSections[30].FieldName := IntToStr(fieldPicture);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineDvdpro.DoImport(const AFileName: TFileName; AListView: TElTree);
var
  xml: TJvSimpleXml;
  xmlRoot, xmlItem, xmlSubitem: TJvSimpleXmlElem;
  i, j: Integer;
  Folder: TFileName;
  Value: string;
  function GetItemValue(AItem: TJvSimpleXmlElem; const AItemName: string): string;
  var
    SubItem: TJvSimpleXmlElem;
  begin
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem = nil then
      Result := ''
    else
      Result := SubItem.Value;
  end;
  function GetItemList(AItem: TJvSimpleXmlElem; const AItemName: string): string; overload;
  var
    i: Integer;
    SubItem: TJvSimpleXmlElem;
  begin
    Result := '';
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        if Result <> '' then
          Result := Result + ', ';
        Result := Result + SubItem.Items[i].Value;
      end;
  end;
  function GetItemList(AItem: TJvSimpleXmlElem; const AItemName, ALastItemName: string): string; overload;
  var
    i: Integer;
    SubItem, LastItem: TJvSimpleXmlElem;
  begin
    Result := '';
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        LastItem := SubItem.Items[i].Items.ItemNamed[ALastItemName];
        if LastItem = nil then
          Continue;
        if Result <> '' then
          Result := Result + ', ';
        Result := Result + LastItem.Value;
      end;
  end;
  function GetActors(AItem: TJvSimpleXmlElem): string;
  var
    i: Integer;
    Value, Role: string;
    SubItem: TJvSimpleXmlElem;
  begin
    Result := '';
    SubItem := AItem.Items.ItemNamed['Actors'];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        if Result <> '' then
          Result := Result + ', ';
        if SubItem.Items[i].Items.Count = 0 then
        begin
          Value := Trim(SubItem.Items[i].Properties.Value('FirstName') + ' ' + SubItem.Items[i].Properties.Value('LastName'));
          Role := Trim(SubItem.Items[i].Properties.Value('Role'));
        end
        else
        begin
          Value := Trim(SubItem.Items[i].Items.Value('FirstName') + ' ' + SubItem.Items[i].Items.Value('LastName'));
          Role := Trim(SubItem.Items[i].Properties.Value('Role'));
        end;
        if (Role <> '') then
          Result := Format('%s%s (%s)', [Result, Value, Role])
        else
          Result := Result + Value;
      end;
  end;
  function GetCredit(AItem: TJvSimpleXmlElem; const ACreditType: string): string;
  var
    i: Integer;
    Value, CrType: string;
    SubItem: TJvSimpleXmlElem;
  begin
    Result := '';
    SubItem := AItem.Items.ItemNamed['Credits'];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        if SubItem.Items[i].Items.Count = 0 then
          CrType := Trim(SubItem.Items[i].Properties.Value('CreditType'))
        else
          CrType := Trim(SubItem.Items[i].Items.Value('CreditType'));
        if (CrType = ACreditType) then
        begin
          if Result <> '' then
            Result := Result + ', ';
          if SubItem.Items[i].Items.Count = 0 then
            Value := Trim(SubItem.Items[i].Properties.Value('FirstName') + ' ' + SubItem.Items[i].Properties.Value('LastName'))
          else
            Value := Trim(SubItem.Items[i].Items.Value('FirstName') + ' ' + SubItem.Items[i].Items.Value('LastName'));
          Result := Result + Value;
        end;
      end;
  end;
begin
  Folder := ExtractFilePath(AFileName);
  xml := TJvSimpleXml.Create(nil);
  try
    xml.LoadFromFile(AFileName);
    xmlRoot := xml.Root;
    if (xmlRoot = nil) or (xmlRoot.Name <> 'Collection') then
      raise Exception.Create('Root item "Collection" not found');

    // Set columns name
    FColumnsName.Add('ID');
    FColumnsName.Add('UPC');
    FColumnsName.Add('ProfileTimestamp');
    FColumnsName.Add('ProfileTimestamp2');
    FColumnsName.Add('Title');
    FColumnsName.Add('SortTitle');
    FColumnsName.Add('Regions');
    FColumnsName.Add('CollectionType');
    FColumnsName.Add('CollectionNumber');
    FColumnsName.Add('Rating');
    FColumnsName.Add('CountryOfOrigin');
    FColumnsName.Add('ProductionYear');
    FColumnsName.Add('Released');
    FColumnsName.Add('RunningTime');
    FColumnsName.Add('CaseType');
    FColumnsName.Add('Genres');
    FColumnsName.Add('FormatAspectRatio');
    FColumnsName.Add('FormatVideoStandard');
    FColumnsName.Add('Studios');
    FColumnsName.Add('AudioLanguage');
    FColumnsName.Add('AudioCompression');
    FColumnsName.Add('AudioChannels');
    FColumnsName.Add('Subtitles');
    FColumnsName.Add('Actors');
    FColumnsName.Add('Direction');
    FColumnsName.Add('Writing');
    FColumnsName.Add('Production');
    FColumnsName.Add('PurchaseDate');
    FColumnsName.Add('Overview');
    FColumnsName.Add('Picture');

    // Import values
    FCancel := False;
    with ProgressWin do
    begin
      Maximum := xmlRoot.Items.Count;
      IntProgress := 0;
      Status := Format(TImportWin2(FImportWin).Messages.Strings[msgImportFrom], [FormatName]);
      Execute(FImportWin);
      OnCancel := OnCancelProc;
      try
        i := 0;
        while (i < xmlRoot.Items.Count) and (not FCancel) do
        begin
          xmlItem := xmlRoot.Items[i];
          if xmlItem.Name = 'DVD' then
            with AListView.Items.AddChild(nil, '') do
            begin
              ShowCheckBox := True;
              Checked := True;
              SubItems.Add(GetItemValue(xmlItem, 'ID'));                               // 0
              SubItems.Add(GetItemValue(xmlItem, 'UPC'));                              // 1
              SubItems.Add(GetItemValue(xmlItem, 'ProfileTimestamp'));                 // 2
              SubItems.Add(TextBefore(GetItemValue(xmlItem, 'ProfileTimestamp'), ' '));// 3
              SubItems.Add(GetItemValue(xmlItem, 'Title'));                            // 4
              SubItems.Add(GetItemValue(xmlItem, 'SortTitle'));                        // 5
              SubItems.Add(GetItemList(xmlItem, 'Regions'));                           // 6
              SubItems.Add(GetItemValue(xmlItem, 'CollectionType'));                   // 7
              SubItems.Add(GetItemValue(xmlItem, 'CollectionNumber'));                 // 8
              SubItems.Add(GetItemValue(xmlItem, 'Rating'));                           // 9
              SubItems.Add(GetItemValue(xmlItem, 'CountryOfOrigin'));                  // 10
              SubItems.Add(GetItemValue(xmlItem, 'ProductionYear'));                   // 11
              SubItems.Add(GetItemValue(xmlItem, 'Released'));                         // 12
              SubItems.Add(GetItemValue(xmlItem, 'RunningTime'));                      // 13
              SubItems.Add(GetItemValue(xmlItem, 'CaseType'));                         // 14
              SubItems.Add(GetItemList(xmlItem, 'Genres'));                            // 15
              xmlSubItem := xmlItem.Items.ItemNamed['Format'];
              if xmlSubItem <> nil then
              begin
                SubItems.Add(GetItemValue(xmlSubItem, 'FormatAspectRatio'));           // 16
                SubItems.Add(GetItemValue(xmlSubItem, 'FormatVideoStandard'));         // 17
              end
              else
                for j := 1 to 2 do
                  SubItems.Add('');
              SubItems.Add(GetItemList(xmlItem, 'Studios'));                           // 18
              Value := GetItemList(xmlItem, 'Audio', 'AudioLanguage');                 // 19
              if Value = '' then
                Value := GetItemList(xmlItem, 'Audio', 'AudioContent');
              SubItems.Add(Value);
              SubItems.Add(GetItemList(xmlItem, 'Audio', 'AudioCompression'));         // 20
              Value := GetItemList(xmlItem, 'Audio', 'AudioChannels');                 // 21
              if Value = '' then
                Value := GetItemList(xmlItem, 'Audio', 'AudioFormat');
              SubItems.Add(Value);
              SubItems.Add(GetItemList(xmlItem, 'Subtitles'));                         // 22
              SubItems.Add(GetActors(xmlItem));                                        // 23
              SubItems.Add(GetCredit(xmlItem, 'Direction'));                           // 24
              SubItems.Add(GetCredit(xmlItem, 'Writing'));                             // 25
              SubItems.Add(GetCredit(xmlItem, 'Production'));                          // 26
              xmlSubItem := xmlItem.Items.ItemNamed['PurchaseInfo'];
              if xmlSubItem <> nil then
                SubItems.Add(GetItemValue(xmlSubItem, 'PurchaseDate'))                 // 27
              else
                SubItems.Add('');
              SubItems.Add(GetItemValue(xmlItem, 'Overview'));                         // 28
              if (SubItems[0] <> '') and FileExists(Folder + SubItems[0] + 'f.jpg') then
                SubItems.Add(SubItems[0] + 'f.jpg')                                    // 29
              else
                SubItems.Add('');
            end;
          Inc(i);
          StepIt;
        end;
      finally
        OnCancel := nil;
        Close;
      end;
    end;
  finally
    xml.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineDvdpro.GetFilter: string;
begin
  Result := DialogXmlFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineDvdpro.GetURL: string;
begin
  Result := 'http://www.invelos.com/';
end;

{-------------------------------------------------------------------------------
  TImportEngineGCstar
-------------------------------------------------------------------------------}

procedure TImportEngineGCstar.DoImport(const AFileName: TFileName; AListView: TElTree);
var
  xml: TJvSimpleXml;
  xmlRoot, xmlItem: TJvSimpleXmlElem;
  i: Integer;
  Folder: TFileName;
  s: string;
  function GetItemValue(AItem: TJvSimpleXmlElem; const AItemName: string): string;
  var
    SubItem: TJvSimpleXmlElem;
  begin
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem = nil then
      Result := ''
    else
      Result := SubItem.Value;
  end;
  function GetItemList(AItem: TJvSimpleXmlElem; const AItemName: string; const col: Integer): string; overload;
  var
    i: Integer;
    SubItem, CurItem: TJvSimpleXmlElem;
  begin
    Result := '';
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        if col < SubItem.Items.Item[i].Items.Count then
        begin
          CurItem := SubItem.Items.Item[i].Items.Item[col];
          if CurItem = nil then
            Continue;
          if Result <> '' then
            Result := Result + ', ';
          Result := Result + CurItem.Value;
        end;
      end;
  end;
  function GetItemActors(AItem: TJvSimpleXmlElem; const AItemName: string): string; overload;
  var
    i, j: Integer;
    Value: string;
    SubItem, CurItem: TJvSimpleXmlElem;
  begin
    Result := '';
    Value := '';
    SubItem := AItem.Items.ItemNamed[AItemName];
    if SubItem <> nil then
      for i := 0 to SubItem.Items.Count - 1 do
      begin
        for j := 0 to 1 do
          begin
            CurItem := SubItem.Items.Item[i].Items.Item[j];
            if CurItem = nil then
              Continue;
            if (j = 1) and (Value <> '') and (CurItem.Value <> '') then
              Value := Value + ' (';
            Value := Value + CurItem.Value;
            if (j = 1) and (Value <> '') and (CurItem.Value <> '') then
              Value := Value + ')';
          end;
        if Result <> '' then
          Result := Result + ', ';//#13#10;
        Result := Result + Value;
        Value := '';
      end;
  end;
  function GetItemBorrower(AItem: TJvSimpleXmlElem): string;
  begin
    Result := '';
    Result := xmlItem.Properties.Value('borrower');
    if Result = 'none' then
      Result := '';
  end;

begin
  Folder := ExtractFilePath(AFileName);
  xml := TJvSimpleXml.Create(nil);
  try
    xml.LoadFromFile(AFileName);
    xmlRoot := xml.Root;
    if (xmlRoot = nil) or (xmlRoot.Properties.Value('type') <> 'GCfilms') then
      raise Exception.Create('This is not a GCstar movie database file');
    // Set columns name
    FColumnsName.Add('Id');
    FColumnsName.Add('Title');
    FColumnsName.Add('Date');
    FColumnsName.Add('Time');
    FColumnsName.Add('Director');
    FColumnsName.Add('Country');
    FColumnsName.Add('Picture');
    FColumnsName.Add('BackPic');
    FColumnsName.Add('Original');
    FColumnsName.Add('WebPage');
    FColumnsName.Add('Seen');
    FColumnsName.Add('Added');
    FColumnsName.Add('Region');
    FColumnsName.Add('Format');
    FColumnsName.Add('Number');
    FColumnsName.Add('Identifier');
    FColumnsName.Add('Place');
    FColumnsName.Add('Rating');
    FColumnsName.Add('RatingPress');
    FColumnsName.Add('Age');
    FColumnsName.Add('VideoFormat');
    FColumnsName.Add('Serie');
    FColumnsName.Add('Rank');
    FColumnsName.Add('Trailer');
    FColumnsName.Add('Borrower');
    FColumnsName.Add('LendDate');
    FColumnsName.Add('Favorite');
    FColumnsName.Add('Synopsis');
    FColumnsName.Add('Comment');
    FColumnsName.Add('Genre');
    FColumnsName.Add('Actors');
    FColumnsName.Add('Languages');
    FColumnsName.Add('AudioFormat');
    FColumnsName.Add('Subtitles');
    FColumnsName.Add('Tags');

    // Import values
    FCancel := False;
    with ProgressWin do
    begin
      Maximum := xmlRoot.Items.Count;
      IntProgress := 0;
      Status := Format(TImportWin2(FImportWin).Messages.Strings[msgImportFrom], [FormatName]);
      Execute(FImportWin);
      OnCancel := OnCancelProc;
      try
        i := 0;
        while (i < xmlRoot.Items.Count) and (not FCancel) do
        begin
          xmlItem := xmlRoot.Items[i];
          if xmlItem.Name = 'item' then
            with AListView.Items.AddChild(nil, '') do
            begin
              ShowCheckBox := True;
              Checked := True;
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('id')));                                  // 0
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('title')));                               // 1
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('date')));                                // 2
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('time')));                                // 3
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('director')));                            // 4
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('country')));                             // 5
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('image')));                               // 6
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('backpic')));                             // 7
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('original')));                            // 8
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('webPage')));                             // 9
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('seen')));                                // 10
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('added')));                               // 11
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('region')));                              // 12
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('format')));                              // 13
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('number')));                              // 14
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('identifier')));                          // 15
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('place')));                               // 16
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('rating')));                              // 17
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('ratingpress')));                         // 18
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('age')));                                 // 19
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('video')));                               // 20
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('serie')));                               // 21
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('rank')));                                // 22
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('trailer')));                             // 23
              SubItems.Add(UTF8Decode(GetItemBorrower(xmlItem)));                                        // 24
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('lendDate')));                            // 25
              SubItems.Add(UTF8Decode(xmlItem.Properties.Value('favourite')));                           // 26
              SubItems.Add(UTF8Decode(GetItemValue(xmlItem, 'synopsis')));                               // 27
              SubItems.Add(UTF8Decode(GetItemValue(xmlItem, 'comment')));                                // 28
              SubItems.Add(UTF8Decode(GetItemList(xmlItem, 'genre', 0)));                                // 29
              s := xmlItem.Properties.Value('actors', '');                                               // 30
              if s <> '' then
                SubItems.Add(UTF8Decode(s))
              else
                SubItems.Add(UTF8Decode(GetItemActors(xmlItem, 'actors')));
              SubItems.Add(UTF8Decode(GetItemList(xmlItem, 'audio', 0)));                                // 31
              SubItems.Add(UTF8Decode(GetItemList(xmlItem, 'audio', 1)));                                // 32
              SubItems.Add(UTF8Decode(GetItemList(xmlItem, 'subt', 0)));                                 // 33
              SubItems.Add(UTF8Decode(GetItemList(xmlItem, 'tags', 0)));                                 // 34
            end;
          Inc(i);
          StepIt;
        end;
      finally
        OnCancel := nil;
        Close;
      end;
    end;
  finally
    xml.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineGCstar.AfterImport(const AListView: TElTree);
begin
  if (AListView.Items.Count > 0) and Settings.rImport.AutoAssign
    and (AListView.HeaderSections.Count >= 36) then
  begin
    AListView.HeaderSections[1].FieldName := IntToStr(fieldNumber);
    AListView.HeaderSections[2].FieldName := IntToStr(fieldTranslatedTitle);
    AListView.HeaderSections[3].FieldName := IntToStr(fieldYear);
    AListView.HeaderSections[4].FieldName := IntToStr(fieldLength);
    AListView.HeaderSections[5].FieldName := IntToStr(fieldDirector);
    AListView.HeaderSections[6].FieldName := IntToStr(fieldCountry);
    AListView.HeaderSections[7].FieldName := IntToStr(fieldPicture);
    //AListView.HeaderSections[8].FieldName := IntToStr(field);
    AListView.HeaderSections[9].FieldName := IntToStr(fieldOriginalTitle);
    AListView.HeaderSections[10].FieldName := IntToStr(fieldURL);
    //AListView.HeaderSections[11].FieldName := IntToStr(field);
    AListView.HeaderSections[12].FieldName := IntToStr(fieldDate);
    //AListView.HeaderSections[13].FieldName := IntToStr(field);
    AListView.HeaderSections[14].FieldName := IntToStr(fieldMediaType);
    //AListView.HeaderSections[15].FieldName := IntToStr(field);
    //AListView.HeaderSections[16].FieldName := IntToStr(field);
    AListView.HeaderSections[17].FieldName := IntToStr(fieldMedia);
    AListView.HeaderSections[18].FieldName := IntToStr(fieldUserRating);
    AListView.HeaderSections[19].FieldName := IntToStr(fieldRating);
    AListView.HeaderSections[20].FieldName := IntToStr(fieldCertification);
    AListView.HeaderSections[21].FieldName := IntToStr(fieldVideoFormat);
    //AListView.HeaderSections[22].FieldName := IntToStr(field);
    //AListView.HeaderSections[23].FieldName := IntToStr(field);
    AListView.HeaderSections[24].FieldName := IntToStr(fieldFilePath);
    AListView.HeaderSections[25].FieldName := IntToStr(fieldBorrower);
    AListView.HeaderSections[26].FieldName := IntToStr(fieldDateWatched);
    //AListView.HeaderSections[27].FieldName := IntToStr(field);
    AListView.HeaderSections[28].FieldName := IntToStr(fieldDescription);
    AListView.HeaderSections[29].FieldName := IntToStr(fieldComments);
    AListView.HeaderSections[30].FieldName := IntToStr(fieldCategory);
    AListView.HeaderSections[31].FieldName := IntToStr(fieldActors);
    AListView.HeaderSections[32].FieldName := IntToStr(fieldLanguages);
    AListView.HeaderSections[33].FieldName := IntToStr(fieldAudioFormat);
    AListView.HeaderSections[34].FieldName := IntToStr(fieldSubtitles);
    //AListView.HeaderSections[35].FieldName := IntToStr(field);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineGCstar.GetFilter: string;
begin
  Result := DialogGCstarFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineGCstar.GetURL: string;
begin
  Result := 'http://www.gcstar.org/';
end;

{-------------------------------------------------------------------------------
  TImportEngineDir
-------------------------------------------------------------------------------}

procedure TImportEngineDir.DoImport(const AFileName: TFileName; AListView: TElTree);
var
  Depth: Integer;
  i: Integer;
begin
  try
    with Settings.rImport.rDir do
    begin
      if BrowseDepth = '*' then
        Depth := 100
      else
        Depth := StrToIntDef(BrowseDepth, 0);
      // Set columns name
      for i := 0 to strMedia.Count-1 do
        FColumnsName.Add(strMedia.Strings[i]);
      // Import values
      ImportFromDir(AFileName, AListView, Depth, MultiDisks, DiskTag);
    end;
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineDir.AfterImport(const AListView: TElTree);
var
  i, idx: Integer;
begin
  if (AListView.Items.Count > 0) and Settings.rImport.AutoAssign then
    with Settings.rOptions.rMovieInformation, Settings.rImport.rDir do
    begin
      //if ImportSize then
      begin
        if ImportSizeString then
          AListView.HeaderSections[mediaSizeStr+1].FieldName := IntToStr(fieldSize)
        else
          AListView.HeaderSections[mediaSize+1].FieldName := IntToStr(fieldSize);
       AListView.HeaderSections[mediaDisks+1].FieldName := IntToStr(fieldDisks);
      end;
      //if ImportMediaLabel then
        AListView.HeaderSections[mediaVolumeLabel+1].FieldName := IntToStr(fieldMedia);
      //if ImportFileName then
        AListView.HeaderSections[mediaNameFiltered+1].FieldName := IntToStr(fieldOriginalTitle);
      if ImportFileInURL and not ImportFileInFilePath then
      begin
        AListView.HeaderSections[mediaPathNameExt+1].FieldName := IntToStr(fieldURL);
        AListView.Tag := mediaPathNameExt+1; // Key Column
      end else //if ImportFileInFilePath then
      begin
        AListView.HeaderSections[mediaPathNameExt+1].FieldName := IntToStr(fieldFilePath);
        AListView.Tag := mediaPathNameExt+1; // Key Column
      end;
      AListView.HeaderSections[mediaPicture+1].FieldName := IntToStr(fieldPicture);
      if ExtractProcess <> 2 then
      begin
        //if ImportResolution then
          AListView.HeaderSections[mediaResolution+1].FieldName := IntToStr(fieldResolution);
        //if ImportLength then
          AListView.HeaderSections[mediaLength+1].FieldName := IntToStr(fieldLength);
        //if ImportFramerate then
          AListView.HeaderSections[mediaFramerate+1].FieldName := IntToStr(fieldFramerate);
        //if ImportVideoCodec then
          AListView.HeaderSections[mediaVideoCodec+1].FieldName := IntToStr(fieldVideoFormat);
        if ImportAudioCodec and (not ImportAudioChannels) then
          AListView.HeaderSections[mediaAudioCodec+1].FieldName := IntToStr(fieldAudioFormat)
        else if ImportAudioChannels and (not ImportAudioCodec) then
          AListView.HeaderSections[mediaAudioChannels+1].FieldName := IntToStr(fieldAudioFormat)
        else if ImportAudioCodec and ImportAudioChannels then
          AListView.HeaderSections[mediaAudioCodecAndChannels+1].FieldName := IntToStr(fieldAudioFormat)
        else
          AListView.HeaderSections[mediaAudioCodec+1].FieldName := IntToStr(fieldAudioFormat);
        //if ImportVideoBitrate then
          AListView.HeaderSections[mediaVideoBitrate+1].FieldName := IntToStr(fieldVideoBitrate);
        //if ImportAudioBitrate then
          AListView.HeaderSections[mediaAudioBitrate+1].FieldName := IntToStr(fieldAudioBitrate);
        //if ImportLanguages then
          AListView.HeaderSections[mediaLanguages+1].FieldName := IntToStr(fieldLanguages);
        //if ImportSubtitles then
          AListView.HeaderSections[mediaSubtitles+1].FieldName := IntToStr(fieldSubtitles);
      end;
      if Properties <> nil then
        for i := 0 to Properties.Count-1 do
          if (Properties.Objects[i].FieldType <> ftVirtual) and
            (Properties.Objects[i].MediaInfo <> '') then
          begin
            idx := IndexText(Properties.Objects[i].MediaInfo, strTagMedia);
            if (idx <> -1) and ((ExtractProcess <> 2) or (idx < mediaFileCount)) then
              AListView.HeaderSections[idx+1].FieldName := IntToStr(customFieldLow + i);
          end;

    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineDir.GetFilter: string;
begin
  Result := DialogDirFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineDir.ImportFromDir(const AFileName: TFileName; AListView: TElTree; BrowseDepth: Integer; MultiDisks: Boolean; DiskTag: string);
var
  DirList: TStringList;
  FileListError: TStringList;
  LogFile: TextFile;
  MediaList: TObjectList;
  i, j, n: Integer;
  Item: TElTreeItem;
begin
  SetCurrentDir(strDirApp);

  // Create log file
  AssignFile(LogFile, strDirData + '\scan.log');
  Rewrite(LogFile);

  // Write scan properties in log file
  WriteLn(LogFile, '---------------------------------------------------------');
  WriteLn(LogFile, 'Scan properties');
  WriteLn(LogFile, '---------------------------------------------------------');
  WriteLn(LogFile, '');
  with Settings.rOptions.rMovieInformation, Settings.rImport.rDir do
  begin
    WriteLn(LogFile, 'Root folder:             ' + ExpandFileName(AFileName));
    WriteLn(LogFile, 'Subfolders browse depth: ' + BrowseDepth);
    WriteLn(LogFile, 'File extensions:         ' + ImportExt);
    WriteLn(LogFile, 'Merge multi disks:       ' + BoolToStr(MultiDisks, True));
    WriteLn(LogFile, 'Disk tag:                ' + DiskTag);
    WriteLn(LogFile, 'Extract process:         ' + IntToStr(ExtractProcess));
    WriteLn(LogFile, 'Use internal AVI engine: ' + BoolToStr(ImportInternalAVI, True));
  end;
  WriteLn(LogFile, '');
  WriteLn(LogFile, '---------------------------------------------------------');
  WriteLn(LogFile, 'Files founds');
  WriteLn(LogFile, '---------------------------------------------------------');
  WriteLn(LogFile, '');

  if DirectoryExists(ExpandFileName(AFileName)) then
  begin
    DirList := TStringList.Create;
    FreeAndNil(FFileList);
    FFileList := TStringList.Create;
    FileListError := TStringList.Create;
    MediaList := TObjectList.Create(True);

    DirList.Add(ExpandFileName(AFileName));
    FCancel := False;
    with ProgressWin do
    begin
      Maximum := 1;
      AutoUpdateTextProgress := False;
      IntProgress := 0;
      Progress := '';
      Status := TImportWin2(FImportWin).Messages.Strings[msgSearchMediaFiles];
      Execute(FImportWin);
      OnCancel := OnCancelProc;
      try
        StartGetFileListThread(DirList, FFileList, FileListError, BrowseDepth, MultiDisks, DiskTag,
          TImportWin2(FImportWin).Messages.Strings[msgMediaFilesFound]+' ');
        while (FCancel = False) and (GetFileListThrDone = False) do
          Application.ProcessMessages;
        //IntProgress := Maximum;
      finally
        StopGetFileListThread;
        OnCancel := nil;
        Close;
        AutoUpdateTextProgress := True;
      end;
    end;

    // Write files found in log file
    if FFileList.Count > 0 then
    begin
      for n := 0 to FFileList.Count-1 do
        if Integer(FFileList.Objects[n]) = 0 then
          WriteLn(LogFile, FFileList.Strings[n])
        else
          WriteLn(LogFile, ' + ' + FFileList.Strings[n]);
      WriteLn(LogFile, '');
    end;

    if FileListError.Count > 0 then
    begin
      MessageWin.Execute(
        TImportWin2(FImportWin).Messages.Strings[msgBadCharsFound] +
        #10#13 + #10#13 +
        FileListError.Text, mtWarning, [mbOk]);

      // Write files or folders ignored in log file
      WriteLn(LogFile, '---------------------------------------------------------');
      WriteLn(LogFile, 'Files or folders ignored because they contain bad chars');
      WriteLn(LogFile, '---------------------------------------------------------');
      WriteLn(LogFile, '');
      for n := 0 to FileListError.Count-1 do
        WriteLn(LogFile, FileListError.Strings[n]);
      WriteLn(LogFile, '');
    end;

    if FFileList.Count > 0 then
    begin
      FCancel := False;
      with Settings.rOptions.rMovieInformation, Settings.rImport.rDir, ProgressWin do
      begin
        FExtractDelayed := (ExtractProcess = 1);
        Maximum := FFileList.Count;
        AutoUpdateTextProgress := False;
        IntProgress := 0;
        Progress := '';
        Status := TImportWin2(FImportWin).Messages.Strings[msgImportMediaInfo] + ' ('+ IntToStr(FFileList.Count) + ')';
        Execute(FImportWin);
        OnCancel := OnCancelProc;
        try
          StartGetMediaListThread(FFileList, MediaList, ImportInternalAVI, ImportSizeUnit, nil, ExtractProcess in [1,2]);
          while (FCancel = False) and (GetMediaListThrDone = False) do
            Application.ProcessMessages;
          //IntProgress := Maximum;
        finally
          StopGetMediaListThread;
          OnCancel := nil;
          Close;
          AutoUpdateTextProgress := True;
        end;
      end;

      // Write media info in log file
      WriteLn(LogFile, '---------------------------------------------------------');
      WriteLn(LogFile, 'Media info');
      WriteLn(LogFile, '---------------------------------------------------------');
      WriteLn(LogFile, '');
      // Write media info line header in log file
      if Settings.rImport.rDir.ExtractProcess <> 2 then
        for j := 0 to mediaCount-1 do
          Write(LogFile, strTagMedia[j] + #9)
      else
        for j := 0 to mediaFileCount-1 do
          Write(LogFile, strTagMedia[j] + #9);
      WriteLn(LogFile, '');

      AListView.Items.BeginUpdate;
      for i := 0 to MediaList.Count-1 do
      begin
        Item := AListView.Items.AddChild(nil, '');
        Item.ShowCheckBox := True;
        Item.Checked := True;
        if Settings.rImport.rDir.ExtractProcess = 0 then
        begin
          for j := 0 to mediaCount-1 do
          begin
            Item.SubItems.Add(TMedia(MediaList.Items[i]).Value[j]);
            Write(LogFile, TMedia(MediaList.Items[i]).Value[j] + #9);
          end
        end
        else if Settings.rImport.rDir.ExtractProcess = 1 then
        begin
          for j := 0 to mediaFileCount-1 do
          begin
            Item.SubItems.Add(TMedia(MediaList.Items[i]).Value[j]);
            Write(LogFile, TMedia(MediaList.Items[i]).Value[j] + #9);
          end;
          for j := mediaFileCount to mediaCount-1 do
          begin
            Item.SubItems.Add('...');
            Write(LogFile, '...' + #9);
          end
        end
        else
        begin
          for j := 0 to mediaFileCount-1 do
          begin
            Item.SubItems.Add(TMedia(MediaList.Items[i]).Value[j]);
            Write(LogFile, TMedia(MediaList.Items[i]).Value[j] + #9);
          end;
        end;
        WriteLn(LogFile, '');
      end;
      AListView.Items.EndUpdate;
      WriteLn(LogFile, '');
    end;

    DirList.Free;
    FileListError.Free;
    MediaList.Free;
  end
  else
  begin
    WriteLn(LogFile, 'Root folder "' + ExpandFileName(AFileName) + '" does not exists !');
  end;

  // Close log file
  CloseFile(LogFile)
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportEngineDir.ExtractDelayedInfo(AListView: TElTree; const Idx: Integer; var FCancelImport: Boolean);
var
  Media: TMedia;
  Item: TElTreeItem;
  i, j: Integer;
begin
  if FExtractDelayed then
    with Settings.rOptions.rMovieInformation, Settings.rImport.rDir do
    begin
      Media := TMedia.Create;
      try
        Media.InitValues;
        Item := AListView.Items.Item[idx];
        i := FFileList.IndexOf(Item.SubItems[mediaPathNameExt]);
        if i <> -1 then
        begin
          repeat
            try
              StartGetMediaThread(FFileList.Strings[i], Media, ImportInternalAVI, ImportSizeUnit, nil, False, Integer(FFileList.Objects[i]) = 1);
              while (FCancelImport = False) and (GetMediaThrDone = False) do
                Application.ProcessMessages;
            finally
              StopGetMediaThread;
              Application.ProcessMessages;
            end;
            Inc(i);
          until (FCancelImport or (i = FFileList.Count) or (Integer(FFileList.Objects[i]) = 0));
          AListView.Items.BeginUpdate;
          for j := mediaFileCount to mediaCount-1 do
            Item.SubItems.Strings[j] := Media.Value[j];
          AListView.Items.EndUpdate;
        end;
      finally
        Media.Free;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportEngineDir.AdjustValue(const ATargetField: Integer; AValue: string): string;
begin
  Result := AValue;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportEngineDir.Destroy;
begin
  FreeAndNil(FFileList);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

