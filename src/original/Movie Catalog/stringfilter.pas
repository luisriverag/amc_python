(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2011-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit stringfilter;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, AntCorelButton, AntAutoHintLabel, ExtCtrls,
  TBXDkPanels, ComCtrls, ImgList, AntStringList, AntJvLabel, AntJvHotLink;

type
  TStringFilterWin = class(TBaseDlg)
    EExprString: TEdit;
    EReplaceString: TEdit;
    LvStringFilter: TListView;
    btnAdd: TTBXButton;
    btnDel: TTBXButton;
    btnUp: TTBXButton;
    btnDown: TTBXButton;
    LExprString: TLabel;
    LReplaceString: TLabel;
    LNote1: TLabel;
    ImageListStringFilter: TImageList;
    LNote2: TLabel;
    LNote3: TLabel;
    btnClearAll: TTBXButton;
    btnImport: TTBXButton;
    btnExport: TTBXButton;
    Messages: TAntStringList;
    LNote4: TAntJvHotLink;
    procedure LvStringFilterSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnAddClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure EExprStringChange(Sender: TObject);
    procedure EReplaceStringChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnDefaultClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
  private
    FDefaultStringFilter: TStrings;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure DefaultStringFilter(StringFilter: TStrings);
    procedure LoadStringFilter(StringFilter: TStrings; MergeValues: Boolean = False);
    procedure SaveStringFilter(StringFilter: TStrings);
    function Execute: Boolean;
  end;

const
  msgImportStringFilter     = 0;
  msgExportStringFilter     = 1;

function ApplyStringFilter(StringFilter: TStrings; Str: string): string;

var
  StringFilterWin: TStringFilterWin;

implementation

uses
  functions_gui, functions_tbx, functions_sys, StrUtils, Global,
  ProgramSettings, ConstValues, RegExpr;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.FormCreate(Sender: TObject);
begin
  //ImageListStringFilter.GetIcon(0, Self.Icon);
  ToolbarImages.GetIcon(Ord(ICON_VIEWFILTER), Self.Icon);
  //ImageListStringFilter.ReplaceIcon(0, Self.Icon);
  LoadButtonIcon(btnAdd, ICON_ROWINSERT);
  LoadButtonIcon(btnDel, ICON_ROWDELETE);
  LoadButtonIcon(btnUp, ICON_MOVEUP);
  LoadButtonIcon(btnDown, ICON_MOVEDOWN);
  LoadButtonIcon(btnClearAll, ICON_FILENEW);
  LoadButtonIcon(btnImport, ICON_FILEIMPORT);
  LoadButtonIcon(btnExport, ICON_FILEEXPORT);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.DefaultStringFilter(StringFilter: TStrings);
begin
  FDefaultStringFilter := StringFilter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.LoadStringFilter(StringFilter: TStrings; MergeValues: Boolean);
var
  i, j: Integer;
  Found: Boolean;
begin
  if not MergeValues then
    LvStringFilter.Clear;
  LvStringFilter.ItemIndex := -1;
  LvStringFilter.ItemFocused := nil;
  for i := 0 to StringFilter.Count-1 do
  begin
    Found := False;
    if MergeValues then
      for j := 0 to LvStringFilter.Items.Count-1 do
        if AnsiSameText(LvStringFilter.Items.Item[j].Caption, StringFilter.Names[i]) and
          AnsiSameText(LvStringFilter.Items.Item[j].SubItems.Strings[0], StringFilter.ValueFromIndex[i]) then
        begin
          Found := True;
          Break;
        end;
    if not Found then
      with LvStringFilter.Items.Add do
      begin
        Caption := StringFilter.Names[i];
        SubItems.Add(StringFilter.Values[Caption]);
      end;
  end;
  btnDel.Enabled := False;
  btnDown.Enabled := False;
  btnUp.Enabled := False;
  EExprString.Enabled := False;
  LExprString.Enabled := EExprString.Enabled;
  EReplaceString.Enabled := False;
  LReplaceString.Enabled := EReplaceString.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.SaveStringFilter(StringFilter: TStrings);
var
  i: Integer;
begin
  StringFilter.Clear;
  with LvStringFilter.Items do
    for i := 0 to Count-1 do
      StringFilter.Add(Item[i].Caption + '=' + Item[i].SubItems.Strings[0]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TStringFilterWin.Execute: Boolean;
begin
  Result := ShowModal = mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.LvStringFilterSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  btnDel.Enabled := Selected;
  btnDown.Enabled := Selected;
  btnUp.Enabled := Selected;
  EExprString.Enabled := Selected;
  LExprString.Enabled := EExprString.Enabled;
  EReplaceString.Enabled := Selected;
  LReplaceString.Enabled := EReplaceString.Enabled;
  if Selected and (Item <> nil) then
  begin
    EExprString.Text := Item.Caption;
    EReplaceString.Text := Item.SubItems.Strings[0];
  end else
  begin
    EExprString.Text := '';
    EReplaceString.Text := '';
  end;
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnAddClick(Sender: TObject);
var
  Item: TListItem;
begin
  with LvStringFilter do
  begin
    Items.BeginUpdate;
    if (ItemIndex = -1) or (ItemIndex = Items.Count-1) then
      Item := Items.Add
    else
      Item := Items.Insert(ItemIndex+1);
    with Item do
    begin
      SubItems.Add('');
      Selected := True;
      Focused := True;
      MakeVisible(False);
    end;
    Items.EndUpdate;
  end;

  if EExprString.CanFocus then
    EExprString.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnDelClick(Sender: TObject);
var
  idx: Integer;
begin
  with LvStringFilter do
  begin
    Items.BeginUpdate;
    if Selected <> nil then
    begin
      idx := Selected.Index;
      DeleteSelected;
      if (idx > 0) then
        dec(idx);
      if (idx >= 0) and (LvStringFilter.Items.Count > 0) then
        with Items.Item[idx] do
        begin
          Selected := True;
          Focused := True;
          MakeVisible(False);
        end; // with
    end; // if
    Items.EndUpdate;
  end;

  if (LvStringFilter.Items.Count > 0) then
  begin
    if btnDel.CanFocus then
      btnDel.SetFocus;
  end else
  begin
    if btnAdd.CanFocus then
      btnAdd.SetFocus;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnDownClick(Sender: TObject);
begin
  MoveItems(LvStringFilter, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnUpClick(Sender: TObject);
begin
  MoveItems(LvStringFilter, True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnClearAllClick(Sender: TObject);
begin
  LvStringFilter.Items.Clear;
  if btnAdd.CanFocus then
    btnAdd.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnImportClick(Sender: TObject);
var
  StringFilterTmp: TStringList;
begin
  with TOpenDialog.Create(Self) do
  try
    InitialDir := Settings.rOptions.rFolders[fuStringFilter].Value;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Options := DialogOpenOptions;
    Title := Messages.Strings[msgImportStringFilter];
    Filter := DialogTextFilter;
    FileName := '';
    if Execute then
    begin
      Settings.rOptions.rFolders[fuStringFilter].Value := ExtractFilePath(FileName);
      StringFilterTmp := TStringList.Create;
      StringFilterTmp.LoadFromFile(FileName);
      LoadStringFilter(StringFilterTmp);
      StringFilterTmp.Free;;
    end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnExportClick(Sender: TObject);
var
  StringFilterTmp: TStringList;
begin
  with TSaveDialog.Create(Self) do
  try
    InitialDir := Settings.rOptions.rFolders[fuStringFilter].Value;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Options := DialogSaveOptions;
    Title := Messages.Strings[msgExportStringFilter];
    Filter := DialogTextFilter;
    FileName := 'Filter';
    DefaultExt := 'txt';
    if Execute then
    begin
      Settings.rOptions.rFolders[fuStringFilter].Value := ExtractFilePath(FileName);
      StringFilterTmp := TStringList.Create;
      SaveStringFilter(StringFilterTmp);
      StringFilterTmp.SaveToFile(FileName);
      StringFilterTmp.Free;
    end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.btnDefaultClick(Sender: TObject);
begin
  if FDefaultStringFilter <> nil then
    LoadStringFilter(FDefaultStringFilter)
  else
    btnClearAllClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.EExprStringChange(Sender: TObject);
begin
  with LvStringFilter do
  begin
    if Selected <> nil then
    begin
      Selected.Caption := EExprString.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.EReplaceStringChange(Sender: TObject);
begin
  with LvStringFilter do
  begin
    if Selected <> nil then
    begin
      Selected.Subitems.Strings[0] := EReplaceString.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.FormResize(Sender: TObject);
var
  FreeWidth: Integer;
begin
  FreeWidth := Self.ClientWidth - 124;
  EExprString.Left := 8;
  LExprString.Left := EExprString.Left;
  EExprString.Width := (FreeWidth shr 1);
  LExprString.Width := EExprString.Width;
  EReplaceString.Left := EExprString.Left + EExprString.Width + 6;
  LReplaceString.Left := EReplaceString.Left;
  EReplaceString.Width := (FreeWidth shr 1);
  LReplaceString.Width := EReplaceString.Width;

  FreeWidth := Self.ClientWidth - 120;
  LvStringFilter.Columns.Items[0].Width := (FreeWidth shr 1);
  LvStringFilter.Columns.Items[1].Width := (FreeWidth shr 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ApplyStringFilter(StringFilter: TStrings; Str: string): string;
var
  i: Integer;
  exprStr, replaceStr: string;
  useRegExp, useSubs: Boolean;
begin
  Result := Str;
  if StringFilter = nil then
    Exit;
  for i := 0 to StringFilter.Count-1 do
  begin
    useRegExp := False;
    useSubs := False;
    exprStr := StringFilter.Names[i];
    replaceStr := StringFilter.ValueFromIndex[i];
    if AnsiStartsText('::>', exprStr) then //UseRegExpr
    begin
      useRegExp := True;
      System.Delete(exprStr, 1, 3);
      if AnsiStartsText('::>', replaceStr) then //UseSubstitution
      begin
        useSubs := True;
        System.Delete(replaceStr, 1, 3);
      end;
    end;
    if useRegExp then
      Result := ReplaceRegExpr(exprStr, Result, replaceStr, useSubs)
    else
      Result := StringReplace(Result, exprStr, replaceStr, [rfIgnoreCase, rfReplaceAll]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.LoadOptions;
begin
  with Settings.rStringFilter do
  begin
    case WindowState of
      1:
        begin
          self.WindowState := wsNormal;
          self.Width := WindowWidth;
          self.Height := WindowHeight;
        end;
      2:
        begin
          self.WindowState := wsMaximized;
        end;
      else
        begin
          self.WindowState := wsNormal;
        end;
    end; // case
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStringFilterWin.SaveOptions;
begin
  with Settings.rStringFilter do
  begin
    case self.WindowState of
      wsNormal:
        begin
          WindowState := 1;
          WindowWidth := Width;
          WindowHeight := Height;
        end;
      wsMaximized:
        begin
          WindowState := 2;
        end;
    end; // case
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
