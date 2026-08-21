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

unit getscript_readscripts;

interface

uses
  Classes, Contnrs, SysUtils, IniFiles,

  fields;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TScriptProperties = record
    Authors: string;
    Title: string;    
    Description: string;
    Site: string;
    Language: string;
    Version: string;
    Requires: string;
    Comments: string;
    License: string;
    LicenseAccepted: Integer;
    GetInfo: Boolean;
    RequiresMovies: Boolean;
    OldFormat: Boolean;
  end;

  TScriptValue = record
    Value: Integer;
    Description: string;
  end;

  TScriptOption = class(TObject)
  private
    function GetString: string;
    procedure SetString(AStr: string);
  public
    Name: string;
    DefValue: Integer;
    Value: Integer;
    Values: array of TScriptValue;
    property AsString: string read GetString write SetString;
  end;

  TScriptOptions = class(TObjectList)
  private
    function GetString: string;
    procedure SetString(const Value: string);
    function GetOption(Index: Integer): TScriptOption;
    procedure SetOption(Index: Integer; const Value: TScriptOption);
  public
    property Items[Index: Integer]: TScriptOption read GetOption write SetOption; default;
    property AsString: string read GetString write SetString;
    procedure FillNames(AList: TStrings);
    function Add: TScriptOption; overload;
    function Insert(Index: Integer): TScriptOption; overload;
    function Find(const AName: string): TScriptOption;
  end;

  TScriptParameter = class(TObject)
  private
    function GetString: string;
    procedure SetString(AStr: string);
  public
    Name: string;
    DefValue: string;
    Value: string;
    Description: string;
    property AsString: string read GetString write SetString;
  end;

  TScriptParameters = class(TObjectList)
  private
    function GetString: string;
    procedure SetString(const Value: string);
    function GetParameter(Index: Integer): TScriptParameter;
    procedure SetParameter(Index: Integer; const Value: TScriptParameter);
  public
    property Items[Index: Integer]: TScriptParameter read GetParameter write SetParameter; default;
    property AsString: string read GetString write SetString;
    procedure FillNames(AList: TStrings);
    function Add: TScriptParameter; overload;
    function Insert(Index: Integer): TScriptParameter; overload;
    function Find(const AName: string): TScriptParameter;
  end;

  TScriptFields = class(TObject)
  private
    FFieldsExcluded: TMovieFields;
    FPicture: Boolean;
    //FCustomFieldsExcluded: TMovieFields;
    FAddExtras: Boolean;
    FDeleteExtras: Boolean;
    FModifyExtras: Boolean;
    FExtraFieldsExcluded:TMovieFields;
    FExtraPicture: Boolean;
    function GetStringFields: string;
    procedure SetStringFields(const Value: string);
    //function GetStringCustomFields: string;
    //procedure SetStringCustomFields(const Value: string);
    function GetStringExtraFields: string;
    procedure SetStringExtraFields(const Value: string);
  public
    property FieldsExcluded: TMovieFields read FFieldsExcluded write FFieldsExcluded;
    property Picture: Boolean read FPicture write FPicture;
    //property CustomFieldsExcluded: TMovieFields read FCustomFieldsExcluded write FCustomFieldsExcluded;
    property AddExtras: Boolean read FAddExtras write FAddExtras;
    property DeleteExtras: Boolean read FDeleteExtras write FDeleteExtras;
    property ModifyExtras: Boolean read FModifyExtras write FModifyExtras;
    property ExtraFieldsExcluded: TMovieFields read FExtraFieldsExcluded write FExtraFieldsExcluded;
    property ExtraPicture: Boolean read FExtraPicture write FExtraPicture;
    property AsStringFields: string read GetStringFields write SetStringFields;
    //property AsStringCustomFields: string read GetStringCustomFields write SetStringCustomFields;
    property AsStringExtraFields: string read GetStringExtraFields write SetStringExtraFields;
  end;

  TScriptInfo = class(TObject)
  private
    FIni: TMemIniFile;
    FFolder: TFileName;
    FFileName: TFileName;
    FProperties: TScriptProperties;
    FOptions: TScriptOptions;
    FParameters: TScriptParameters;
    FFields: TScriptFields;
    FStatic: TStringList;
    FFileDate: string;
  public
    constructor Create(AIni: TMemIniFile; const AFolder: TFileName; const AFileName: TFileName);
    destructor Destroy; override;
    procedure Load(const ADate: TDateTime);
    procedure Save(const ANewFileName: TFileName = '');
    function FullPath: TFileName;
    property FileName: TFileName read FFileName;
    property Properties: TScriptProperties read FProperties;
    property Options: TScriptOptions read FOptions;
    property Parameters: TScriptParameters read FParameters;
    property Fields: TScriptFields read FFields write FFields;
    property Static: TStringList read FStatic;
    property FileDate: string read FFileDate write FFileDate;
    procedure SaveToStream(AStream: TStream);
    procedure AcceptLicense(const Number: Integer);
  end;

  TScriptList = class(TObjectList)
  private
    FIni: TMemIniFile;
    FLanguages: TStringList;
  public
    constructor Create(const AFolder: TFileName); reintroduce;
    destructor Destroy; override;
    procedure Save;
    function Add(const FilePath: TFileName = ''): TScriptInfo; overload;
    function Find(const FilePath: TFileName): TScriptInfo;
    property Languages: TStringList read FLanguages;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Math, StrUtils, 
  Global, ConstValues, functions_str, movieclass, functions_files;

{-------------------------------------------------------------------------------
  TScriptList
-------------------------------------------------------------------------------}

constructor TScriptList.Create(const AFolder: TFileName);
var
  sr: TSearchRec;
  sc: Integer;
  NewScript: TScriptInfo;
begin
  inherited Create;
  FLanguages := TStringList.Create;
  FLanguages.Sorted := True;
  FLanguages.Duplicates := dupIgnore;
  FIni := TMemIniFile.Create(strFileScriptsCache);
  SetCurrentDir(AFolder);
  sc := FindFirst('*.ifs', 0, sr);
  while sc = 0 do
  begin
    NewScript := TScriptInfo.Create(FIni, AFolder, sr.Name);
    try
      NewScript.Load(FileDateToDateTime(sr.Time));
      if NewScript.Properties.Language <> '' then
        FLanguages.Add(NewScript.Properties.Language);
      Add(NewScript);
    except
      NewScript.Free;
    end;
    sc := FindNext(sr);
  end;
  FindClose(sr);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TScriptList.Destroy;
begin
  FIni.Free;
  FLanguages.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptList.Add(const FilePath: TFileName): TScriptInfo;
begin
  if FilePath = '' then
    Result := TScriptInfo.Create(FIni, '', '')
  else
  begin
    Result := TScriptInfo.Create(FIni, ExtractFilePath(FilePath), ExtractFileName(FilePath));
    Result.Load(GetFileModifiedDate(FilePath));
  end;
  Add(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptList.Save;
begin
  try
    FIni.UpdateFile;
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptList.Find(const FilePath: TFileName): TScriptInfo;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
    if SameFileName(TScriptInfo(Items[i]).FullPath, FilePath) then
    begin
      Result := TScriptInfo(Items[i]);
      Break;
    end;
end;

{-------------------------------------------------------------------------------
  TScriptInfo
-------------------------------------------------------------------------------}

constructor TScriptInfo.Create(AIni: TMemIniFile; const AFolder: TFileName; const AFileName: TFileName);
begin
  FIni := AIni;
  FFolder := AFolder;
  FFileName := AFileName;
  FOptions := TScriptOptions.Create;
  FParameters := TScriptParameters.Create;
  FFields := TScriptFields.Create;
  FProperties.Requires := strVersion;
  FProperties.GetInfo := False;
  FProperties.RequiresMovies := True;
  FProperties.OldFormat := False;
  FFields.AddExtras := True;
  FFields.DeleteExtras := True;
  FFields.ModifyExtras := True;
  FFields.Picture := True;
  FFields.ExtraPicture := True;
  FStatic := TStringList.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TScriptInfo.Destroy;
begin
  FOptions.Free;
  FParameters.Free;
  FFields.Free;
  FStatic.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptInfo.Load(const ADate: TDateTime);
var
  CacheDate: string;
  s: string;
  L, LOptions, LParameters, OldIni: TStringList;
  f: TFileStream;
  i: Integer;
  FValues: TStringList;
  procedure FillListWithSection(AList: TStringList; const ASection, AContents: string);
  var
    i, StartPos: Integer;
  begin
    AList.Clear;
    StartPos := Pos(Format('[%s]', [ASection]), AContents);
    if StartPos = 0 then
      Exit;
    AList.Text := Copy(AContents, StartPos, MaxInt);
    AList.Delete(0);
    for i := 0 to AList.Count-1 do
      if Pos('=', AList[i]) = 0 then
      begin
        while (AList.Count > i) do
          AList.Delete(i);
        Break;
      end;
  end;
begin
  FValues := TStringList.Create;
  try
    FIni.ReadSectionValues(FFileName, FValues);
    CacheDate := FValues.Values['Infos.Date'];
    FFileDate := DateTimeToStr(ADate, FormatSettings);
    if CacheDate <> FFileDate then
    begin
      FFields.AsStringFields := FIni.ReadString(FFileName, 'Fields.Excluded', '');
      FFields.Picture := FIni.ReadBool(FFileName, 'Fields.Picture', True);
      //FFields.AsStringCustomFields := FIni.ReadString(FFileName, 'CustomFields.Excluded', '');
      FFields.AddExtras := FIni.ReadBool(FFileName, 'ExtraFields.AddExtras', True);
      FFields.DeleteExtras := FIni.ReadBool(FFileName, 'ExtraFields.DeleteExtras', True);
      FFields.ModifyExtras := FIni.ReadBool(FFileName, 'ExtraFields.ModifyExtras', True);
      FFields.AsStringExtraFields := FIni.ReadString(FFileName, 'ExtraFields.Excluded', '');
      FFields.ExtraPicture := FIni.ReadBool(FFileName, 'ExtraFields.Picture', True);
      L := TStringList.Create;
      OldIni := TStringList.Create;
      try
        FIni.ReadSectionValues(FFileName, OldIni);
        FIni.EraseSection(FFileName);
        FIni.WriteString(FFileName, 'Infos.Date', FFileDate);
        try
          f := TFileStream.Create(FullPath, fmOpenRead);
          try
            SetLength(s, f.Size);
            i := 1;
            while i <= Length(s) do
            begin
              f.Read(s[i], 1);
              if (i = 2) and (not StartsStr('(*', s)) then
                Abort;
              if (i > 1) and (Copy(s, i-1, 2) = '*)') then
              begin
                SetLength(s, i);
                Break;
              end;
              Inc(i);
            end;
          finally
            f.Free;
          end;
          with FProperties do
          begin
            FillListWithSection(L, 'Infos', s);
            Authors := L.Values['Authors'];
            Title := L.Values['Title'];
            if Title = '' then
              Title := FFileName;
            Description := L.Values['Description'];
            Site := L.Values['Site'];
            Language := L.Values['Language'];
            Version := L.Values['Version'];
            Requires := L.Values['Requires'];
            if Requires = '' then
              Requires := strVersion;
            Comments := L.Values['Comments'];
            License := L.Values['License'];
            LicenseAccepted := StrToIntDef(OldIni.Values['Infos.LicenseAccepted'], 0);
            GetInfo := L.Values['GetInfo'] <> '0';
            RequiresMovies := L.Values['RequiresMovies'] <> '0';
            OldFormat := False;
          end;
          FillListWithSection(L, 'Options', s);
          FOptions.AsString := L.Text;
          for i := 0 to FOptions.Count-1 do
            FOptions[i].Value := StrToIntDef(DelAfterChar(OldIni.Values['Options.' + FOptions[i].Name], '|'), FOptions[i].DefValue);
          FillListWithSection(L, 'Parameters', s);
          FParameters.AsString := L.Text;
          for i := 0 to FParameters.Count-1 do
            FParameters[i].Value := DelAfterChar(OldIni.Values['Parameters.' + FParameters[i].Name], '|');
          FStatic.Clear;
          for i := 0 to OldIni.Count-1 do
            if StartsStr('Static.', OldIni[i]) then
              FStatic.Add(DelBeforeChar(OldIni[i], '.'));
        except
          on EAbort do
          begin
            FProperties.OldFormat := True;
            FProperties.Title := FFileName;
          end;
        end;
      finally
        L.Free;
        OldIni.Free;
      end;
      Save;
    end
    else
    begin
      with FIni, FProperties do
      begin
        Authors := ReadString(FFileName, 'Infos.Authors', '');
        Title := ReadString(FFileName, 'Infos.Title', FFileName);
        Description := ReadString(FFileName, 'Infos.Description', '');
        Site := ReadString(FFileName, 'Infos.Site', '');
        Language := ReadString(FFileName, 'Infos.Language', '?');
        Version := ReadString(FFileName, 'Infos.Version', '');
        Requires := ReadString(FFileName, 'Infos.Requires', '');
        Comments := ReadString(FFileName, 'Infos.Comments', '');
        License := ReadString(FFileName, 'Infos.License', '');
        LicenseAccepted := FIni.ReadInteger(FFileName, 'Infos.LicenseAccepted', 0);
        GetInfo := ReadBool(FFileName, 'Infos.GetInfo', False);
        RequiresMovies := ReadBool(FFileName, 'Infos.RequiresMovies', True);
        OldFormat := ReadBool(FFileName, 'Infos.OldFormat', False);
      end;
      L := TStringList.Create;
      LOptions := TStringList.Create;
      LParameters := TStringList.Create;
      try
        FStatic.Clear;
        FIni.ReadSectionValues(FFileName, L);
        for i := 0 to L.Count-1 do
          if StartsStr('Options.', L[i]) then
            LOptions.Add(Copy(L[i], 9, MaxInt))
          else if StartsStr('Parameters.', L[i]) then
            LParameters.Add(Copy(L[i], 12, MaxInt))
          else if StartsStr('Static.', L[i]) then
            FStatic.Add(DelBeforeChar(L[i], '.'));
        FOptions.AsString := LOptions.Text;
        FParameters.AsString := LParameters.Text;
      finally
        L.Free;
        LOptions.Free;
        LParameters.Free;
      end;
      FFields.AsStringFields := FIni.ReadString(FFileName, 'Fields.Excluded', '');
      FFields.Picture := FIni.ReadBool(FFileName, 'Fields.Picture', True);
      //FFields.AsStringCustomFields := FIni.ReadString(FFileName, 'CustomFields.Excluded', '');
      FFields.AddExtras := FIni.ReadBool(FFileName, 'ExtraFields.AddExtras', True);
      FFields.DeleteExtras := FIni.ReadBool(FFileName, 'ExtraFields.DeleteExtras', True);
      FFields.ModifyExtras := FIni.ReadBool(FFileName, 'ExtraFields.ModifyExtras', True);
      FFields.AsStringExtraFields := FIni.ReadString(FFileName, 'ExtraFields.Excluded', '');
      FFields.ExtraPicture := FIni.ReadBool(FFileName, 'ExtraFields.Picture', True);
    end;
  finally
    FValues.Free;
  end;
  if FProperties.Language = '' then
    FProperties.Language := '?';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptInfo.FullPath: TFileName;
begin
  Result := FFolder + FFileName;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptInfo.Save(const ANewFileName: TFileName = '');
var
  i: Integer;
begin
  if ANewFileName <> '' then
  begin
    FFolder := ExtractFilePath(ANewFileName);
    FFileName := ExtractFileName(ANewFileName);
  end;
  with FIni, FProperties do
  begin
    WriteString(FFileName, 'Infos.Date', FileDate);
    WriteString(FFileName, 'Infos.Authors', Authors);
    WriteString(FFileName, 'Infos.Title', Title);
    WriteString(FFileName, 'Infos.Description', Description);
    WriteString(FFileName, 'Infos.Site', Site);
    WriteString(FFileName, 'Infos.Language', Language);
    WriteString(FFileName, 'Infos.Version', Version);
    WriteString(FFileName, 'Infos.Requires', Requires);
    WriteString(FFileName, 'Infos.Comments', Comments);
    WriteString(FFileName, 'Infos.License', License);
    WriteInteger(FFileName, 'Infos.LicenseAccepted', LicenseAccepted);
    WriteBool(FFileName, 'Infos.GetInfo', GetInfo);
    WriteBool(FFileName, 'Infos.RequiresMovies', RequiresMovies);
    WriteBool(FFileName, 'Infos.OldFormat', OldFormat);
  end;
  with FIni, FOptions do
  begin
    for i := 0 to Count-1 do
      WriteString(FFileName, 'Options.' + Items[i].Name, DelBeforeChar(Items[i].AsString, '='));
  end;
  with FIni, FParameters do
  begin
    for i := 0 to Count-1 do
      WriteString(FFileName, 'Parameters.' + Items[i].Name, DelBeforeChar(Items[i].AsString, '='));
  end;
  with FIni do
  begin
    for i := 0 to FStatic.Count-1 do
      WriteString(FFileName, 'Static.' + FStatic.Names[i], FStatic.ValueFromIndex[i]);
  end;
  FIni.WriteString(FFileName, 'Fields.Excluded', FFields.AsStringFields);
  FIni.WriteBool(FFileName, 'Fields.Picture', Fields.Picture);
  //FIni.WriteString(FFileName, 'CustomFields.Excluded', FFields.AsStringCustomFields);
  FIni.WriteBool(FFileName, 'ExtraFields.AddExtras', FFields.AddExtras);
  FIni.WriteBool(FFileName, 'ExtraFields.DeleteExtras', FFields.DeleteExtras);
  FIni.WriteBool(FFileName, 'ExtraFields.ModifyExtras', FFields.ModifyExtras);
  FIni.WriteString(FFileName, 'ExtraFields.Excluded', FFields.AsStringExtraFields);
  FIni.WriteBool(FFileName, 'ExtraFields.Picture', FFields.ExtraPicture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptInfo.SaveToStream(AStream: TStream);
var
  s: string;
begin
  with FProperties do
    s := '(***************************************************' + sLineBreak
       + sLineBreak
       + 'Ant Movie Catalog importation script' + sLineBreak
       + 'www.antp.be/software/moviecatalog/' + sLineBreak
       + sLineBreak
       + '[Infos]' + sLineBreak
       + 'Authors=' + Authors + sLineBreak
       + 'Title=' + Title + sLineBreak
       + 'Description=' + Description + sLineBreak
       + 'Site=' + Site + sLineBreak
       + 'Language=' + Language + sLineBreak
       + 'Version=' + Version + sLineBreak
       + 'Requires=' + Requires + sLineBreak
       + 'Comments=' + Comments + sLineBreak
       + 'License=' + License + sLineBreak
       + 'GetInfo=' + IfThen(GetInfo, '1', '0') + sLineBreak
       + 'RequiresMovies=' + IfThen(RequiresMovies, '1', '0') + sLineBreak
       + sLineBreak
       + '[Options]' + sLineBreak
       + FOptions.AsString
       + sLineBreak
       + '[Parameters]' + sLineBreak
       + FParameters.AsString
       + sLineBreak
       + '***************************************************)' + sLineBreak
       + sLineBreak;
  AStream.Write(s[1], Length(s));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptInfo.AcceptLicense(const Number: Integer);
begin
  FProperties.LicenseAccepted := Number;
  Save;
end;

{-------------------------------------------------------------------------------
  TScriptFields
-------------------------------------------------------------------------------}

function TScriptFields.GetStringFields: string;
var
  f: Integer;
begin
  Result := '';
  for f := fieldLow to fieldCount-1 do
    if f in FFieldsExcluded then
      Result := Result + strTagFields[f] + '|';
  if Result <> '' then
    SetLength(Result, Length(Result) - 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptFields.SetStringFields(const Value: string);
var
  L: TStringList;
  i, val: Integer;
begin
  L := TStringList.Create;
  try
    L.Delimiter := '|';
    L.DelimitedText := Value;
    FFieldsExcluded := [];
    for i := 0 to L.Count-1 do
    begin
      val := IndexText(L[i], strTagFields);
      if val in AllFields then
        Include(FFieldsExcluded, val);
    end;
  finally
    L.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptFields.GetStringExtraFields: string;
var
  f: Integer;
begin
  Result := '';
  for f := extraFieldLow to extraFieldCount-1 do
    if f in FExtraFieldsExcluded then
      Result := Result + strTagExtraFields[f - extraFieldLow] + '|';
  if Result <> '' then
    SetLength(Result, Length(Result) - 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptFields.SetStringExtraFields(const Value: string);
var
  L: TStringList;
  i, val: Integer;
begin
  L := TStringList.Create;
  try
    L.Delimiter := '|';
    L.DelimitedText := Value;
    FExtraFieldsExcluded := [];
    for i := 0 to L.Count-1 do
    begin
      val := IndexText(L[i], strTagExtraFields);
      if val > -1 then
      begin
        val := val + extraFieldLow;
        if val in AllExtraFields then
          Include(FExtraFieldsExcluded, val);
      end;
    end;
  finally
    L.Free;
  end;
end;

{-------------------------------------------------------------------------------
  TScriptOptions 
-------------------------------------------------------------------------------}

function TScriptOptions.GetOption(Index: Integer): TScriptOption;
begin
  Result := inherited Items[Index] as TScriptOption;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptOptions.SetOption(Index: Integer; const Value: TScriptOption);
begin
  inherited Items[Index] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptOptions.GetString: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
    Result := Result + Items[i].AsString + sLineBreak;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptOptions.SetString(const Value: string);
var
  L: TStringList;
  i: Integer;
  NewOption: TScriptOption;
begin
  Clear;
  L := TStringList.Create;
  try
    L.Text := Value;
    for i := 0 to L.Count-1 do
      if L[i] <> '' then
      begin
        NewOption := TScriptOption.Create;
        try
          NewOption.AsString := L[i];
          Add(NewOption);
        except
          NewOption.Free;
        end;
      end;
  finally
    L.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptOptions.FillNames(AList: TStrings);
var
  i: Integer;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    for i := 0 to Count-1 do
      AList.AddObject(Items[i].Name, Items[i]);
  finally
    AList.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptOptions.Add: TScriptOption;
begin
  Result := TScriptOption.Create;
  Add(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptOptions.Insert(Index: Integer): TScriptOption;
begin
  Result := TScriptOption.Create;
  Insert(Index, Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptOptions.Find(const AName: string): TScriptOption;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
    if AnsiSameText(Items[i].Name, AName) then
    begin
      Result := Items[i];
      Break;
    end;
end;

{-------------------------------------------------------------------------------
  TScriptOption
-------------------------------------------------------------------------------}

function TScriptOption.GetString: string;
var
  i: Integer;
begin
  Result := Format('%s=%d|%d', [
    StringReplace(Trim(Name), '|', '', [rfReplaceAll]),
    Value, DefValue]);
  for i := 0 to Length(Values)-1 do
  begin
    Result := Format('%s|%d=%s', [Result, Values[i].Value,
      StringReplace(Values[i].Description, '|', '', [rfReplaceAll])]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptOption.SetString(AStr: string);
var
  len: Integer;
  s1, s2: string;
begin
  Split(AStr, '=', s1, s2, True);
  if (s1 = '') or (s2 = '') then
    raise Exception.Create('Emty name or value');
  Name := s1;
  AStr := s2;
  Split(AStr, '|', s1, s2, True);
  Value := StrToIntDef(s1, MaxInt);
  AStr := s2;
  Split(AStr, '|', s1, s2, True);
  DefValue := StrToIntDef(s1, MaxInt);
  len := 0;
  Values := nil;
  AStr := s2;
  Split(AStr, '|', s1, s2, True);
  while s1 <> '' do
  begin
    Inc(len);
    SetLength(Values, len);
    Values[len-1].Value := StrToIntDef(DelAfterChar(s1, '='), 0);
    Values[len-1].Description := DelBeforeChar(s1, '=');
    AStr := s2;
    Split(AStr, '|', s1, s2, True);
  end;
  if DefValue = MaxInt then
  begin
    if Length(Values) > 0 then
      DefValue := Values[0].Value
    else
      DefValue := 0;
  end;
  if Value = MaxInt then
    Value := DefValue;
end;

{-------------------------------------------------------------------------------
  TScriptParameters
-------------------------------------------------------------------------------}

function TScriptParameters.GetParameter(Index: Integer): TScriptParameter;
begin
  Result := inherited Items[Index] as TScriptParameter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptParameters.SetParameter(Index: Integer; const Value: TScriptParameter);
begin
  inherited Items[Index] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptParameters.GetString: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
    Result := Result + Items[i].AsString + sLineBreak;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptParameters.SetString(const Value: string);
var
  L: TStringList;
  i: Integer;
  NewParameter: TScriptParameter;
begin
  Clear;
  L := TStringList.Create;
  try
    L.Text := Value;
    for i := 0 to L.Count-1 do
      if L[i] <> '' then
      begin
        NewParameter := TScriptParameter.Create;
        try
          NewParameter.AsString := L[i];
          Add(NewParameter);
        except
          NewParameter.Free;
        end;
      end;
  finally
    L.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptParameters.FillNames(AList: TStrings);
var
  i: Integer;
begin
  AList.BeginUpdate;
  try
    AList.Clear;
    for i := 0 to Count-1 do
      AList.AddObject(Items[i].Name, Items[i]);
  finally
    AList.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptParameters.Add: TScriptParameter;
begin
  Result := TScriptParameter.Create;
  Add(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptParameters.Insert(Index: Integer): TScriptParameter;
begin
  Result := TScriptParameter.Create;
  Insert(Index, Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptParameters.Find(const AName: string): TScriptParameter;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
    if AnsiSameText(Items[i].Name, AName) then
    begin
      Result := Items[i];
      Break;
    end;
end;

{-------------------------------------------------------------------------------
  TScriptParameter
-------------------------------------------------------------------------------}

function TScriptParameter.GetString: string;
begin
  Result := Format('%s=%s|%s|%s', [
    StringReplace(Trim(Name), '|', '', [rfReplaceAll]),
    StringReplace(Value, '|', '', [rfReplaceAll]),
    StringReplace(DefValue, '|', '', [rfReplaceAll]),
    StringReplace(Description, '|', '', [rfReplaceAll])]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptParameter.SetString(AStr: string);
var
  s1, s2: string;
begin
  Split(AStr, '=', s1, s2, True);
  if (s1 = '') or (s2 = '') then
    raise Exception.Create('Emty name or value');
  Name := s1;
  AStr := s2;
  Split(AStr, '|', s1, s2, True);
  Value := s1;
  AStr := s2;
  Split(AStr, '|', s1, s2, True);
  DefValue := s1;
  Description := s2;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
