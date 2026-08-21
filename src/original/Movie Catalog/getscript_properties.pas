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

unit getscript_properties;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ExtCtrls, Grids, ValEdit,

  AntCorelButton, AntAutoHintLabel, AntStringList,

  getscript_readscripts, memoform, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TScriptPropertiesWin = class(TBaseDlg)
    lstProperties: TValueListEditor;
    Messages: TAntStringList;
    grpOptions: TGroupBox;
    lstOptions: TListBox;
    btnOptionAdd: TTBXButton;
    btnOptionDel: TTBXButton;
    lstValues: TStringGrid;
    grpValues: TGroupBox;
    lblValueDefault: TLabel;
    cbxValueDefault: TComboBox;
    grpParameters: TGroupBox;
    lstParameters: TStringGrid;
    btnOptionDown: TTBXButton;
    btnOptionUp: TTBXButton;
    btnValueAdd: TTBXButton;
    btnValueDel: TTBXButton;
    btnValueUp: TTBXButton;
    btnValueDown: TTBXButton;
    btnParameterAdd: TTBXButton;
    btnParameterDel: TTBXButton;
    btnParameterUp: TTBXButton;
    btnParameterDown: TTBXButton;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);

    procedure lstPropertiesEditButtonClick(Sender: TObject);

    procedure btnOptionAddClick(Sender: TObject);
    procedure btnOptionDelClick(Sender: TObject);
    procedure btnOptionDownClick(Sender: TObject);
    procedure btnOptionUpClick(Sender: TObject);
    procedure lstOptionsClick(Sender: TObject);
    procedure lstOptionsDblClick(Sender: TObject);

    procedure btnValueAddClick(Sender: TObject);
    procedure btnValueDelClick(Sender: TObject);
    procedure btnValueDownClick(Sender: TObject);
    procedure btnValueUpClick(Sender: TObject);
    procedure lstValuesSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
    procedure cbxValueDefaultChange(Sender: TObject);

    procedure btnParameterAddClick(Sender: TObject);
    procedure btnParameterDelClick(Sender: TObject);
    procedure btnParameterDownClick(Sender: TObject);
    procedure btnParameterUpClick(Sender: TObject);
    procedure lstParametersSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);

    procedure btn1Click(Sender: TObject);
  private
    MemoEditWin: TMemoWin;
    FScript: TScriptInfo;
    FOptionsBackup: string;
    FParametersBackup: string;
    procedure Load;
    procedure Save;
    procedure FillParameters;
    procedure ReloadOptionDefaultValues;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
    function Execute(const AScript: TScriptInfo; const LanguagesList: TStrings): Boolean;
  end;

  type TPublicStringGrid = class(TCustomGrid);
  procedure RemoveRow(AStringGrid: TStringGrid; ARow: Integer);
  procedure InsertRow(AStringGrid: TStringGrid; ARow: Integer);

var
  ScriptPropertiesWin: TScriptPropertiesWin;

const
  msgInfoAuthors          =  0;
  msgInfoTitle            =  1;
  msgInfoDescr            =  2;
  msgInfoSite             =  3;
  msgInfoLanguage         =  4;
  msgInfoVersion          =  5;
  msgInfoRequires         =  6;
  msgInfoComments         =  7;
  msgInfoLicense          =  8;
  msgInfoGetInfo          =  9;
  msgInfoRequiresMovies   = 10;
  msgOptionValue          = 11;
  msgOptionDescr          = 12;
  msgOptionDelete         = 13;
  msgOptionName           = 14;
  msgOptionRename         = 15;
  msgOptionNameExists     = 16;
  msgParamName            = 17;
  msgParamDefaultValue    = 18;
  msgParamDesc            = 19;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  StrUtils, Math,

  Global, ConstValues, functions_str, functions_tbx;

{-------------------------------------------------------------------------------
  TScriptPropertiesWin
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.FormCreate(Sender: TObject);
begin
  inherited;
  MemoEditWin := TMemoWin.Create(Self);
  LoadButtonIcon(btnOptionAdd, ICON_ROWINSERT);
  LoadButtonIcon(btnOptionDel, ICON_ROWDELETE);
  LoadButtonIcon(btnOptionUp, ICON_MOVEUP);
  LoadButtonIcon(btnOptionDown, ICON_MOVEDOWN);

  LoadButtonIcon(btnValueAdd, ICON_ROWINSERT);
  LoadButtonIcon(btnValueDel, ICON_ROWDELETE);
  LoadButtonIcon(btnValueUp, ICON_MOVEUP);
  LoadButtonIcon(btnValueDown, ICON_MOVEDOWN);

  LoadButtonIcon(btnParameterAdd, ICON_ROWINSERT);
  LoadButtonIcon(btnParameterDel, ICON_ROWDELETE);
  LoadButtonIcon(btnParameterUp, ICON_MOVEUP);
  LoadButtonIcon(btnParameterDown, ICON_MOVEDOWN);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.FormShow(Sender: TObject);
begin
  inherited;
  MemoEditWin.Icon.Assign(Icon);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.FormDestroy(Sender: TObject);
begin
  FreeAndNil(MemoEditWin);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.FormResize(Sender: TObject);
var
  h, hProperties, hOptions, hParameters: Integer;
  space: Integer;
begin
  inherited;
  lstValues.HandleNeeded;
  lstValues.ColWidths[0] := 40;
  lstValues.ColWidths[1] := lstValues.ClientWidth - lstValues.ColWidths[0] - 2;

  lstParameters.HandleNeeded;
  lstParameters.ColWidths[0] := 108;
  lstParameters.ColWidths[1] := 108;
  lstParameters.ColWidths[2] := lstParameters.ClientWidth -
    lstParameters.ColWidths[0] - lstParameters.ColWidths[1] - 3;

  space := 3;
  h := ClientHeight - (space * 4) - 33;
  hProperties := Min(h - 243, 231);
  h := h - hProperties;
  hOptions := Trunc(h * 0.5) + 11;
  h := h - hOptions;
  hParameters := h;
  lstProperties.Top := space;
  lstProperties.Height := hProperties;
  grpOptions.Top := hProperties + space * 2;
  grpOptions.Height := hOptions;
  grpValues.Top := grpOptions.Top;
  grpValues.Height := grpOptions.Height;
  grpParameters.Top := hProperties + hOptions + space * 3;
  grpParameters.Height := hParameters;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptPropertiesWin.Execute(const AScript: TScriptInfo; const LanguagesList: TStrings): Boolean;
begin
  FScript := AScript;
  FOptionsBackup := FScript.Options.AsString;
  FParametersBackup := FScript.Parameters.AsString;
  Load;
  with lstProperties.ItemProps[msgInfoLanguage] do
  begin
    if LanguagesList.Count > 0 then
      EditStyle := esPickList
    else
      EditStyle := esSimple;
    PickList.Assign(LanguagesList);
  end;
  Result := ShowModal = mrOk;
  if Result then
    Save
  else
  begin
    FScript.Options.AsString := FOptionsBackup;
    FScript.Parameters.AsString := FParametersBackup;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.Load;
  procedure SetVal(const AIndex: Integer; const AString: string);
  begin
    if AString = '' then
      lstProperties.Strings[AIndex] := lstProperties.Strings.Names[AIndex] + '='
    else
      lstProperties.Strings.ValueFromIndex[AIndex] := AString;
  end;
begin
  Assert(msgInfoAuthors = 0);
  with FScript.Properties do
  begin
    lstProperties.Strings.BeginUpdate;
    try
      SetVal(msgInfoAuthors, Authors);
      SetVal(msgInfoTitle, Title);
      SetVal(msgInfoDescr, Description);
      SetVal(msgInfoSite, Site);
      SetVal(msgInfoLanguage, Language);
      SetVal(msgInfoVersion, Version);
      SetVal(msgInfoRequires, Requires);
      SetVal(msgInfoComments, Comments);
      SetVal(msgInfoLicense, License);
      lstProperties.Strings.ValueFromIndex[msgInfoGetInfo] := IfThen(GetInfo, DefaultTrueBoolStr, DefaultFalseBoolStr);
      lstProperties.Strings.ValueFromIndex[msgInfoRequiresMovies] := IfThen(RequiresMovies, DefaultTrueBoolStr, DefaultFalseBoolStr);
    finally
      lstProperties.Strings.EndUpdate;
    end;
  end;

  lstOptions.Items.Clear;
  FScript.Options.FillNames(lstOptions.Items);
  lstOptions.ItemIndex := -1;
  lstOptionsClick(lstValues);
  
  FillParameters;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.Save;
begin
  with lstProperties, FScript.Properties do
  begin
    Authors := Strings.ValueFromIndex[msgInfoAuthors];
    Title := Strings.ValueFromIndex[msgInfoTitle];
    Description := Strings.ValueFromIndex[msgInfoDescr];
    Site := Strings.ValueFromIndex[msgInfoSite];
    Language := Strings.ValueFromIndex[msgInfoLanguage];
    Version := Strings.ValueFromIndex[msgInfoVersion];
    Requires := Strings.ValueFromIndex[msgInfoRequires];
    Comments := Strings.ValueFromIndex[msgInfoComments];
    License := Strings.ValueFromIndex[msgInfoLicense];
    GetInfo := Strings.ValueFromIndex[msgInfoGetInfo] = DefaultTrueBoolStr;
    RequiresMovies := Strings.ValueFromIndex[msgInfoRequiresMovies] = DefaultTrueBoolStr;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.FillParameters;
var
  i: Integer;
begin
  lstParameters.RowCount := 2;
  lstParameters.Cells[0, 1] := '';
  lstParameters.Cells[1, 1] := '';
  lstParameters.Cells[2, 1] := '';
  if FScript.Parameters.Count > 0 then
  begin
    lstParameters.RowCount := FScript.Parameters.Count + 2;
    for i := 0 to FScript.Parameters.Count-1 do
    begin
      lstParameters.Cells[0, i + 1] := FScript.Parameters.Items[i].Name;
      lstParameters.Cells[1, i + 1] := FScript.Parameters.Items[i].DefValue;
      lstParameters.Cells[2, i + 1] := FScript.Parameters.Items[i].Description;
    end;
    lstParameters.Cells[0, lstParameters.RowCount - 1] := '';
    lstParameters.Cells[1, lstParameters.RowCount - 1] := '';
    lstParameters.Cells[2, lstParameters.RowCount - 1] := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.LoadOptions;
begin
  with Settings.rScripts.rProperties do
  begin
    Self.Width := WindowWidth;
    Self.Height := WindowHeight;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.SaveOptions;
begin
  with Settings.rScripts.rProperties do
  begin
    WindowWidth := Self.Width;
    WindowHeight := Self.Height;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.Translate;
var
  i: Integer;
begin
  inherited;
  with lstProperties do
  begin
    for i := msgInfoAuthors to msgInfoRequiresMovies do
      ItemProps[i].KeyDesc := Messages.Strings[i];
    ItemProps[msgInfoComments].EditStyle := esEllipsis;
    ItemProps[msgInfoLicense].EditStyle := esEllipsis;
    ItemProps[msgInfoGetInfo].EditStyle := esPickList;
    with ItemProps[msgInfoGetInfo].PickList do
    begin
      Add(DefaultTrueBoolStr);
      Add(DefaultFalseBoolStr);
    end;
    ItemProps[msgInfoRequiresMovies].EditStyle := esPickList;
    with ItemProps[msgInfoRequiresMovies].PickList do
    begin
      Add(DefaultTrueBoolStr);
      Add(DefaultFalseBoolStr);
    end;
  end;
  lstValues.Cells[0, 0] := Messages.Strings[msgOptionValue];
  lstValues.Cells[1, 0] := Messages.Strings[msgOptionDescr];

  lstParameters.Cells[0, 0] := Messages.Strings[msgParamName];
  lstParameters.Cells[1, 0] := Messages.Strings[msgParamDefaultValue];
  lstParameters.Cells[2, 0] := Messages.Strings[msgParamDesc];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.lstPropertiesEditButtonClick(Sender: TObject);
var
  s: string;
  i: Integer;
begin
  i := lstProperties.Row - 1;
  if i in [msgInfoComments, msgInfoLicense] then
  begin
    s := InsertLineBreaks(lstProperties.Strings.ValueFromIndex[i]);
    if MemoEditWin.Execute(Messages.Strings[i], s) then
      if s = '' then
        lstProperties.Strings[i] := lstProperties.Strings.Names[i] + '='
      else
        lstProperties.Strings.ValueFromIndex[i] := ReplaceLineBreaks(s);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnOptionAddClick(Sender: TObject);
var
  idx: Integer;
  NewOpt: TScriptOption;
  OptName: string;
begin
  OptName := '';
  if InputWin.Execute(GetLongHint(btnOptionAdd.Hint), Messages.Strings[msgOptionName], OptName) then
  begin
    //OptName := RemoveLettersNotInList(Trim(OptName), ['A'..'Z', 'a'..'z', '0'..'9', '_']);
    OptName := StringReplace(Trim(OptName), '|', '', [rfReplaceAll]);
    idx := lstOptions.Items.IndexOf(OptName);
    if idx <> -1 then
    begin
      lstOptions.ItemIndex := idx;
      lstOptionsClick(lstOptions);
      Exit;
    end;
    idx := lstOptions.ItemIndex;
    if (idx = -1) or (idx = lstOptions.Count-1) then
    begin
      NewOpt := FScript.Options.Add;
      NewOpt.Name := OptName;
      idx := lstOptions.Items.AddObject(OptName, NewOpt);
    end
    else
    begin
      idx := idx + 1;
      NewOpt := FScript.Options.Insert(idx);
      NewOpt.Name := OptName;
      lstOptions.Items.InsertObject(idx, OptName, NewOpt);
    end;
    lstOptions.ItemIndex := idx;
    lstOptionsClick(lstOptions);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnOptionDelClick(Sender: TObject);
var
  idx: Integer;
  optIdx: Integer;
begin
  idx := lstOptions.ItemIndex;
  if idx = -1 then
    Exit;
  optIdx := FScript.Options.IndexOf(lstOptions.Items.Objects[idx]);
  if MessageWin.Execute(Format(Messages.Strings[msgOptionDelete], [lstOptions.Items[idx]]), mtWarning, [mbOk, mbCancel]) = 1 then
  begin
    if optIdx <> -1 then
      FScript.Options.Delete(optIdx);
    lstOptions.DeleteSelected;
    if (idx > 0) then
      lstOptions.ItemIndex := idx - 1
    else
      lstOptions.ItemIndex := Min(idx, lstOptions.Items.Count-1);
    lstOptionsClick(lstOptions);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnOptionDownClick(Sender: TObject);
var
  idx: Integer;
  optIdx: Integer;
begin
  idx := lstOptions.ItemIndex;
  if (idx = -1) or (idx = lstOptions.Count-1) then
    Exit;
  optIdx := FScript.Options.IndexOf(lstOptions.Items.Objects[idx]);
  if (idx <> optIdx) then
    Exit;
  FScript.Options.Move(optIdx, optIdx + 1);
  lstOptions.Items.Move(idx, idx + 1);
  lstOptions.ItemIndex := idx + 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnOptionUpClick(Sender: TObject);
var
  idx: Integer;
  optIdx: Integer;
begin
  idx := lstOptions.ItemIndex;
  if (idx = -1) or (idx = 0) then
    Exit;
  optIdx := FScript.Options.IndexOf(lstOptions.Items.Objects[idx]);
  if (idx <> optIdx) then
    Exit;
  FScript.Options.Move(optIdx, optIdx - 1);
  lstOptions.Items.Move(idx, idx - 1);
  lstOptions.ItemIndex := idx - 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.lstOptionsClick(Sender: TObject);
var
  i, idx, len: Integer;
  CurOption: TScriptOption;
begin
  lstValues.RowCount := 2;
  lstValues.Cells[0, 1] := '';
  lstValues.Cells[1, 1] := '';
  cbxValueDefault.Items.Clear;
  idx := lstOptions.ItemIndex;
  if idx = -1 then
  begin
    lstValues.Enabled := False;
    lblValueDefault.Enabled := False;
    cbxValueDefault.Enabled := False;
    btnValueAdd.Enabled := False;
    btnValueDel.Enabled := False;
    btnValueUp.Enabled := False;
    btnValueDown.Enabled := False;
  end
  else
  begin
    lstValues.Enabled := True;
    lblValueDefault.Enabled := True;
    cbxValueDefault.Enabled := True;
    btnValueAdd.Enabled := True;
    btnValueDel.Enabled := True;
    btnValueUp.Enabled := True;
    btnValueDown.Enabled := True;
    CurOption := lstOptions.Items.Objects[idx] as TScriptOption;
    len := Length(CurOption.Values);
    if len > 0 then
    begin
      lstValues.RowCount := len + 2;
      for i := 0 to len-1 do
      begin
        lstValues.Cells[0, i + 1] := IntToStr(CurOption.Values[i].Value);
        lstValues.Cells[1, i + 1] := CurOption.Values[i].Description;
      end;
      lstValues.Cells[0, len + 1] := '';
      lstValues.Cells[1, len + 1] := '';
      with cbxValueDefault.Items do
      begin
        Assign(lstValues.Cols[0]);
        Delete(Count-1);
        Delete(0);
        cbxValueDefault.ItemIndex := IndexOf(IntToStr(CurOption.DefValue));
      end;
    end;
  end;
  FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.lstOptionsDblClick(Sender: TObject);
var
  idx: Integer;
  optIdx: Integer;
  OptName: string;
begin
  idx := lstOptions.ItemIndex;
  if idx = -1 then
    Exit;
  optIdx := FScript.Options.IndexOf(lstOptions.Items.Objects[idx]);
  OptName := lstOptions.Items.Strings[idx];
  if InputWin.Execute((Format(Messages.Strings[msgOptionRename], [OptName])), Messages.Strings[msgOptionName], OptName) then
  begin
    //OptName := RemoveLettersNotInList(Trim(OptName), ['A'..'Z', 'a'..'z', '0'..'9', '_']);
    OptName := StringReplace(Trim(OptName), '|', '', [rfReplaceAll]);
    if not AnsiSameText(OptName, lstOptions.Items.Strings[idx]) then
      if lstOptions.Items.IndexOf(OptName) <> -1 then
      begin
        MessageWin.Execute(Format(Messages.Strings[msgOptionNameExists], [OptName]), mtError, [mbOk]);
        Exit;
      end;
    FScript.Options.Items[optIdx].Name := OptName;
    lstOptions.Items.Strings[idx] := OptName;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.ReloadOptionDefaultValues;
var
  i: Integer;
  defVal: string;
begin
  i := cbxValueDefault.ItemIndex;
  if i <> -1 then
    defVal := cbxValueDefault.Items[i]
  else
    defVal := '';
  with cbxValueDefault.Items do
  begin
    Assign(lstValues.Cols[0]);
    Delete(Count-1);
    Delete(0);
    cbxValueDefault.ItemIndex := IndexOf(defVal);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnValueAddClick(Sender: TObject);
var
  i, idx: Integer;
  CurOption: TScriptOption;
begin
  idx := lstValues.Row;
  if (idx < 1) or (idx >= lstValues.RowCount - 2) then
    Exit;
  lstValues.OnSetEditText := nil;
  CurOption := lstOptions.Items.Objects[lstOptions.ItemIndex] as TScriptOption;
  InsertRow(lstValues, idx + 1);
  SetLength(CurOption.Values, lstValues.RowCount - 2);
  for i := 1 to lstValues.RowCount - 2 do
  begin
    CurOption.Values[i - 1].Value := StrToIntDef(lstValues.Cells[0, i], 0);
    CurOption.Values[i - 1].Description := lstValues.Cells[1, i];
  end;
  lstValues.Row := idx + 1;
  lstValues.OnSetEditText := lstValuesSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnValueDelClick(Sender: TObject);
var
  i, idx: Integer;
  CurOption: TScriptOption;
begin
  idx := lstValues.Row;
  if (idx < 1) or (idx = lstValues.RowCount - 1) then
    Exit;
  lstValues.OnSetEditText := nil;
  CurOption := lstOptions.Items.Objects[lstOptions.ItemIndex] as TScriptOption;
  RemoveRow(lstValues, idx);
  SetLength(CurOption.Values, lstValues.RowCount - 2);
  for i := 1 to lstValues.RowCount - 2 do
  begin
    CurOption.Values[i - 1].Value := StrToIntDef(lstValues.Cells[0, i], 0);
    CurOption.Values[i - 1].Description := lstValues.Cells[1, i];
  end;
  if (idx > 1) then
    lstValues.Row := idx - 1
  else
    lstValues.Row := Min(idx, lstValues.RowCount - 1);
  lstValues.OnSetEditText := lstValuesSetEditText;
  ReloadOptionDefaultValues;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnValueDownClick(Sender: TObject);
var
  i, idx: Integer;
  CurOption: TScriptOption;
begin
  idx := lstValues.Row;
  if (idx < 1) or (idx >= lstValues.RowCount - 2) then
    Exit;
  lstValues.OnSetEditText := nil;
  CurOption := lstOptions.Items.Objects[lstOptions.ItemIndex] as TScriptOption;
  TPublicStringGrid(lstValues).MoveRow(idx, idx + 1);
  for i := 1 to lstValues.RowCount - 2 do
  begin
    CurOption.Values[i - 1].Value := StrToIntDef(lstValues.Cells[0, i], 0);
    CurOption.Values[i - 1].Description := lstValues.Cells[1, i];
  end;
  lstValues.Row := idx;
  lstValues.Row := idx + 1;
  SendMessage(lstValues.Handle, EM_LINESCROLL , 0, lstValues.Row);
  lstValues.OnSetEditText := lstValuesSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnValueUpClick(Sender: TObject);
var
  i, idx: Integer;
  CurOption: TScriptOption;
begin
  idx := lstValues.Row;
  if (idx < 2) or (idx = lstValues.RowCount - 1) then
    Exit;
  lstValues.OnSetEditText := nil;
  CurOption := lstOptions.Items.Objects[lstOptions.ItemIndex] as TScriptOption;
  TPublicStringGrid(lstValues).MoveRow(idx, idx - 1);
  for i := 1 to lstValues.RowCount - 2 do
  begin
    CurOption.Values[i - 1].Value := StrToIntDef(lstValues.Cells[0, i], 0);
    CurOption.Values[i - 1].Description := lstValues.Cells[1, i];
  end;
  lstValues.Row := idx;
  lstValues.Row := idx - 1;
  lstValues.OnSetEditText := lstValuesSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.lstValuesSetEditText(Sender: TObject; ACol, ARow: Integer; const Value: String);
var
  i, last: Integer;
  CurOption: TScriptOption;
begin
  last := lstValues.RowCount-1;
  if (lstValues.Cells[0, last] <> '') or (lstValues.Cells[1, last] <> '') then
  begin
    lstValues.RowCount := last + 2;
    lstValues.Cells[0, last + 1] := '';
    lstValues.Cells[1, last + 1] := '';
  end
  else
    while (last > 1) and (lstValues.Cells[0, last-1] = '') and (lstValues.Cells[1, last-1] = '') do
    begin
      lstValues.RowCount := last;
      Dec(last);
    end;
  ReloadOptionDefaultValues;
  CurOption := lstOptions.Items.Objects[lstOptions.ItemIndex] as TScriptOption;
  SetLength(CurOption.Values, lstValues.RowCount - 2);
  for i := 1 to lstValues.RowCount - 2 do
  begin
    CurOption.Values[i - 1].Value := StrToIntDef(lstValues.Cells[0, i], 0);
    CurOption.Values[i - 1].Description := lstValues.Cells[1, i];
  end;
  FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.cbxValueDefaultChange(Sender: TObject);
var
  idxO, idxV: Integer;
begin
  idxO := lstOptions.ItemIndex;
  idxV := cbxValueDefault.ItemIndex;
  if (idxO <> -1) and (idxV <> -1) then
    with lstOptions.Items.Objects[idxO] as TScriptOption do
    begin
      DefValue := StrToIntDef(cbxValueDefault.Items[idxV], 0);
      Value := DefValue;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnParameterAddClick(Sender: TObject);
var
  idx: Integer;
begin
  idx := lstParameters.Row;
  if (idx < 1) or (idx >= lstParameters.RowCount - 2) then
    Exit;
  lstParameters.OnSetEditText := nil;
  InsertRow(lstParameters, idx + 1);
  FScript.Parameters.Insert(idx);
  lstParameters.Row := idx + 1;
  lstParameters.OnSetEditText := lstParametersSetEditText;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnParameterDelClick(Sender: TObject);
var
  idx: Integer;
begin
  idx := lstParameters.Row;
  if (idx < 1) or (idx = lstParameters.RowCount - 1) then
    Exit;
  lstParameters.OnSetEditText := nil;
  RemoveRow(lstParameters, idx);
  FScript.Parameters.Delete(idx - 1);
  if (idx > 1) then
    lstParameters.Row := idx - 1
  else
    lstParameters.Row := Min(idx, lstParameters.RowCount - 1);
  lstParameters.OnSetEditText := lstParametersSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnParameterDownClick(Sender: TObject);
var
  idx: Integer;
begin
  idx := lstParameters.Row;
  if (idx < 1) or (idx >= lstParameters.RowCount - 2) then
    Exit;
  lstParameters.OnSetEditText := nil;
  TPublicStringGrid(lstParameters).MoveRow(idx, idx + 1);
  FScript.Parameters.Move(idx - 1, idx);
  lstParameters.Row := idx;
  lstParameters.Row := idx + 1;
  lstParameters.OnSetEditText := lstParametersSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btnParameterUpClick(Sender: TObject);
var
  idx: Integer;
begin
  idx := lstParameters.Row;
  if (idx < 2) or (idx = lstParameters.RowCount - 1) then
    Exit;
  lstParameters.OnSetEditText := nil;
  TPublicStringGrid(lstParameters).MoveRow(idx, idx - 1);
  FScript.Parameters.Move(idx - 1, idx - 2);
  lstParameters.Row := idx;
  lstParameters.Row := idx - 1;
  lstParameters.OnSetEditText := lstParametersSetEditText;
  //FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.lstParametersSetEditText(Sender: TObject;
  ACol, ARow: Integer; const Value: String);
var
  last: Integer;
  tmp: string;
  CurParameter: TScriptParameter;
begin
  last := lstParameters.RowCount-1;
  if (lstParameters.Cells[0, last] <> '') or (lstParameters.Cells[1, last] <> '')
    or (lstParameters.Cells[2, last] <> '') then
  begin
    lstParameters.RowCount := last + 2;
    lstParameters.Cells[0, last + 1] := '';
    lstParameters.Cells[1, last + 1] := '';
    lstParameters.Cells[2, last + 1] := '';
    FScript.Parameters.Add;
  end
  else
    while (last > 1) and (lstParameters.Cells[0, last-1] = '')
      and (lstParameters.Cells[1, last-1] = '')
      and (lstParameters.Cells[2, last-1] = '') do
    begin
      lstParameters.RowCount := last;
      Dec(last);
      FScript.Parameters.Delete(last-1);
    end;
  if (lstParameters.Row < 1) or (lstParameters.Row > lstParameters.RowCount - 2) then
    Exit;
  CurParameter := FScript.Parameters.Items[lstParameters.Row - 1];
  //CurParameter.Name := RemoveLettersNotInList(Trim(lstParameters.Cells[0, lstParameters.Row]), ['A'..'Z', 'a'..'z', '0'..'9', '_']);
  CurParameter.Name := StringReplace(Trim(lstParameters.Cells[0, lstParameters.Row]), '|', '', [rfReplaceAll]);
  if CurParameter.Name = '' then
    CurParameter.Name := '?';
  tmp := lstParameters.Cells[1, lstParameters.Row];
  if CurParameter.DefValue <> tmp then
  begin
    CurParameter.DefValue := tmp;
    CurParameter.Value := CurParameter.DefValue;
  end;
  CurParameter.Description := lstParameters.Cells[2, lstParameters.Row];
  FormResize(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptPropertiesWin.btn1Click(Sender: TObject);
begin
  LaunchHelp;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure RemoveRow(AStringGrid: TStringGrid; ARow: Integer);
var
  i: Integer;
begin
  for i := ARow to AStringGrid.RowCount - 2 do
    AStringGrid.Rows[i] := AStringGrid.Rows[i + 1];
  AStringGrid.RowCount := AStringGrid.RowCount - 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure InsertRow(AStringGrid: TStringGrid; ARow: Integer);
var
  i: Integer;
begin
  AStringGrid.RowCount := AStringGrid.RowCount + 1;
  for i := AStringGrid.RowCount - 1 downto ARow + 1 do
    AStringGrid.Rows[i] := AStringGrid.Rows[i - 1];
  AStringGrid.Rows[ARow].Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

