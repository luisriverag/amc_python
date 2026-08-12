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

unit import2_frame;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ComCtrls, ActnList, Contnrs, FileCtrl, CommCtrl,

  TBXDkPanels,
  AntStringList, AntJvLinkLabel,

  ProgramSettings, MovieClass, import2_engines, TB2Item, TBX, Menus,
  ElTree, importmethod;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TImportFrame = class(TFrame)
    grpSettings: TGroupBox;
    grpPreview: TGroupBox;
    grpSourceFile: TGroupBox;
    PanelTop: TPanel;
    lblLink: TAntJvLinkLabel;
    btnReload: TTBXButton;
    btnBrowse: TTBXButton;
    edtSourceFile: TEdit;
    chkAllowDup: TCheckBox;
    chkAllowClear: TCheckBox;
    chkAutoAssign: TCheckBox;
    listPreview: TElTree;
    lblPreview: TLabel;
    ActionList1: TActionList;
    ActionListAll: TAction;
    ActionListCheck: TAction;
    ActionListNone: TAction;
    ActionListUncheck: TAction;
    MenuPopupList: TTBXPopupMenu;
    MnuLspChk: TTBXItem;
    MnuLspUnc: TTBXItem;
    MnuLsp__1: TTBXSeparatorItem;
    MnuLspAll: TTBXItem;
    MnuLspNon: TTBXItem;
    MenuPopupHeader: TTBXPopupMenu;
    ActionHeaderNoImport: TAction;
    MnuHdpNot: TTBXItem;
    lblPictures: TLabel;
    cmbPictures: TComboBox;
    Messages: TAntStringList;
    MnuMov: TTBXSubmenuItem;
    MnuMovCF: TTBXSubmenuItem;
    MnuDefKeyField: TTBXItem;
    ActionDefineKeyField: TAction;
    ActionListCheckExists: TAction;
    ActionListUncheckExists: TAction;
    MnuLsp__2: TTBXSeparatorItem;
    MnuLstChkExits: TTBXItem;
    MnuLstUncExits: TTBXItem;
    btnFieldsLoad: TTBXButton;
    btnFieldsSave: TTBXButton;
    btnFieldsAutoLoad: TTBXButton;
    ActionSortAscend: TAction;
    ActionSortDescend: TAction;
    MnuHdr__1: TTBXSeparatorItem;
    MnuSortDescend: TTBXItem;
    MnuSortAscend: TTBXItem;
    btnColumnsAutoResize: TTBXButton;
    LMovie: TLabel;
    LExtras: TLabel;
    cmbExtraPictures: TComboBox;
    MnuMovExtras: TTBXSubmenuItem;
    procedure lblLinkLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
    procedure btnBrowseClick(Sender: TObject);
    procedure btnReloadClick(Sender: TObject);
    procedure btnFieldsLoadClick(Sender: TObject);
    procedure btnFieldsSaveClick(Sender: TObject);
    procedure btnFieldsAutoLoadClick(Sender: TObject);
    procedure btnColumnsAutoResizeClick(Sender: TObject);
    procedure ActionListCheckExecute(Sender: TObject);
    procedure ActionListCheckExistsExecute(Sender: TObject);
    procedure ActionHeaderClick(Sender: TObject);
    procedure ActionDefineKeyFieldExecute(Sender: TObject);
    procedure ActionSortExecute(Sender: TObject);
    procedure listPreviewHeaderColumnClick(Sender: TObject; SectionIndex: Integer);
    procedure listPreviewMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure listPreviewHotTrack(Sender: TObject; OldItem: TElTreeItem;
      OldSection: TElHeaderSection; NewItem: TElTreeItem;
      NewSection: TElHeaderSection);
    procedure listPreviewKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure listPreviewShowLineHint(Sender: TObject; Item: TElTreeItem;
      var Text: String; HintWindow: THintWindow; MousePos: TPoint;
      var DoShowHint: Boolean);
    procedure listPreviewCompareItems(Sender: TObject; Item1,
      Item2: TElTreeItem; var res: Integer);
    procedure edtSourceFileKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    FCancelImport: Boolean;
    
    procedure OnCancelImport(Sender: TObject);
    procedure SetCatalogFile(const ACatalogFile: TFileName);
    procedure MakeKeyFieldValues;
    procedure ResizeColumns(Auto: Boolean);
  protected
    FImportWin: TForm;
    FFirstImport : Boolean;
    FImportEngine: TImportEngine;
    FImportType: string;
    FCommonSettings: TImportCommonSettings;
    FCatalogFile: TFileName;
    FCatalogPath: TFileName;
    FKeyColumn: Integer;
    FKeyFieldValues: TStringList;
    FKeyFieldValuesNotUnique: Boolean;
  public
    Properties: TCustomFieldsProperties; // ref
    constructor Create(Owner: TForm; Engine: TImportEngine;
      const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
      CommonSettings: TImportCommonSettings); reintroduce;
    destructor Destroy; override;
    property ImportEngine: TImportEngine read FImportEngine;
    procedure LoadSettings; virtual;
    procedure SaveSettings; virtual;
    function ImportToList: Boolean;
    procedure ImportPicture(SourceMovie, CurrentMovie: TMovie;
      SourceField: Integer; FieldValue: string; const AllowClears: Boolean);
    procedure ImportExtraPictures(SourceMovie, CurrentMovie: TMovie;
      SourceField: Integer; FieldValues: string; const Separator: string;
      Start: Integer; const AllowClears: Boolean);
  published
    property CatalogFile: TFileName read FCatalogFile write SetCatalogFile;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  Global, ConstValues, fields, functions_str, functions_files, functions_gui,
  functions_tbx, functions_sys, ComboBoxAutoWidth, ElHeader;

const
  msgNoMovie            = 0;
  msgNoColumn           = 1;
  msgNoCatalogName      = 2;
  msgSelectFolder       = 3;
  msgMoviesFound        = 4;
  msgMoviesAdded        = 5;
  msgMoviesUpdated      = 6;
  msgKeyValuesNotUnique = 7;
  msgKeyFieldNotDefined = 8;
  msgImport             = 9;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TImportFrame.Create(Owner: TForm; Engine: TImportEngine;
  const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
  CommonSettings: TImportCommonSettings);
var
  i: Integer;
  NewItem: TTBXItem;
begin
  inherited Create(Owner);
  FImportWin := Owner;
  LoadButtonIcon(btnBrowse, ICON_BROWSE);
  LoadButtonIcon(btnReload, ICON_REFRESH, False);
  LoadButtonIcon(btnFieldsLoad, ICON_FILEOPEN);
  LoadButtonIcon(btnFieldsSave, ICON_FILESAVE);
  LoadButtonIcon(btnFieldsAutoLoad, ICON_REFRESH);
  LoadButtonIcon(btnColumnsAutoResize, ICON_STRETCHLIST);
  listPreview.Font.Name := Font.Name;
  Properties := CustomFieldsProperties; // ref

  // Movie fields
  for i := fieldLow to fieldCount - 1 do
    if not (i in VirtualFields) then
    begin
      NewItem := TTBXItem.Create(MnuMov);
      NewItem.Caption := strFields[i];
      NewItem.Tag := i;
      NewItem.OnClick := ActionHeaderClick;
      NewItem.GroupIndex := 1;
      MnuMov.Add(NewItem);
    end;
  // Picture
  NewItem := TTBXItem.Create(MnuMov);
  NewItem.Caption := strFieldPicture;
  NewItem.Tag := fieldPicture;
  NewItem.OnClick := ActionHeaderClick;
  NewItem.GroupIndex := 1;
  MnuMov.Add(NewItem);
  // Custom fields
  with Properties do
    for i := 0 to Count-1 do
      if Properties.Objects[i].FieldType <> ftVirtual then
      begin
        NewItem := TTBXItem.Create(MnuMovCF);
        NewItem.Caption := Objects[i].FieldName;
        NewItem.Tag := i + customFieldLow;
        NewItem.OnClick := ActionHeaderClick;
        NewItem.GroupIndex := 2;
        MnuMovCF.Add(NewItem);
      end;
  // Extra fields
  for i := extraFieldLow to extraFieldCount - 1 do
    if not (i in VirtualFields) then
    begin
      NewItem := TTBXItem.Create(MnuMovExtras);
      NewItem.Caption := strExtraFields[i - extraFieldLow];
      NewItem.Tag := i;
      NewItem.OnClick := ActionHeaderClick;
      NewItem.GroupIndex := 3;
      MnuMovExtras.Add(NewItem);
    end;
  // Extra picture
  NewItem := TTBXItem.Create(MnuMovExtras);
  NewItem.Caption := strExtraFieldPicture;
  NewItem.Tag := extraFieldPicture;
  NewItem.OnClick := ActionHeaderClick;
  NewItem.GroupIndex := 3;
  MnuMovExtras.Add(NewItem);

  FFirstImport := True;
  FImportEngine := Engine;
  FImportType := ImportType;
  FCommonSettings := CommonSettings;
  FKeyColumn := -1;
  FKeyFieldValues := TStringList.Create;
  FKeyFieldValues.Sorted := True;
  FKeyFieldValues.Duplicates := dupError;
  FKeyFieldValuesNotUnique := False;
  Translator.Translate(Self);
  cmbExtraPictures.Items.Assign(cmbPictures.Items);
  if FImportEngine.GetURL <> '' then
    lblLink.Caption := Format(lblLink.Caption, [Format('<link>%s</link>', [FImportEngine.FormatName])])
  else
    lblLink.Caption := Format(lblLink.Caption, [FImportEngine.FormatName]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TImportFrame.Destroy;
begin
  FreeAndNil(FImportEngine);
  FreeObjects(FKeyFieldValues);
  FreeAndNil(FKeyFieldValues);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.lblLinkLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
begin
  LaunchProg(FImportEngine.GetURL);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnBrowseClick(Sender: TObject);
var
  dir: string;
begin
  if FImportEngine.GetFilter = DialogDirFilter then
  begin
    Dir := ExtractFileDir(IncludeTrailingPathDelimiter(edtSourceFile.Text));
    if SelectDirectory(Messages.Strings[msgSelectFolder], '', Dir) then
    begin
      edtSourceFile.Text := Dir;
      btnReload.Click;
    end;
  end
  else
    with TOpenDialog.Create(Self) do
      try
        Filter := FImportEngine.GetFilter;
        InitialDir := ExtractFilePath(edtSourceFile.Text);
        if not DirectoryExists(InitialDir) then
          InitialDir := '';
        FileName := ExtractFileName(edtSourceFile.Text);
        if ExtractFileName(FileName) = '' then
        begin
          if DirectoryExists(FileName) then
            InitialDir := FileName;
          FileName := '';
        end;
        if InitialDir <> '' then
          ClearLastVisitedMRU(Application.ExeName);
        Options := DialogOpenOptions;
        if Execute then
        begin
          edtSourceFile.Text := FileName;
          btnReload.Click;
        end;
      finally
        Free;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnReloadClick(Sender: TObject);
var
  AutoAssign: Boolean;
begin
  SetWaitCursor;
  try
    SaveSettings;
    FKeyColumn := -1;
    listPreview.Tag := -1;
    AutoAssign := Settings.rImport.AutoAssign;
    if btnFieldsAutoLoad.Checked then
      Settings.rImport.AutoAssign := False;
    FImportEngine.Import(edtSourceFile.Text, listPreview);
    Settings.rImport.AutoAssign := AutoAssign;
    if btnFieldsAutoLoad.Checked then
      btnFieldsLoadClick(Self)
    else if listPreview.Tag <> -1 then
      ActionDefineKeyFieldExecute(nil);
    ResizeColumns(btnColumnsAutoResize.Checked);
    // Inform User
    MessageWin.Execute(
      Format(Messages.Strings[msgMoviesFound], [IntToStr(listPreview.Items.Count)]),
        mtInformation, [mbOk]);
  finally
    RestoreCursor;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnFieldsLoadClick(Sender: TObject);
var
  i, idx: Integer;
  s, f: string;
begin
  if FCommonSettings = nil then
    Exit;
  FKeyColumn := -1;
  listPreview.Tag := -1;
  for i := 1 to listPreview.HeaderSections.Count - 1 do
  begin
    f := '';
    if i <= FCommonSettings.Fields.Count then
      s := FCommonSettings.Fields[i-1]
    else
      s := '';
    if s = '' then
      idx := -1
    else if SameText(s, strFieldPicture) or SameText(s, strTagFieldPicture) then
    begin
      idx := fieldPicture;
      f := strTagFieldPicture;
      s := strFieldPicture;
    end
    else if SameText(s, strExtraFieldPicture  + ' (' + strExtras + ')') or
      SameText(s, strTagExtraFieldPicture) then
    begin
      idx := extraFieldPicture;
      f := strTagExtraFieldPicture;
      s := strExtraFieldPicture  + ' (' + strExtras + ')';
    end
    else
    begin
      idx := IndexText(s, strTagFields);
      if idx = -1 then
        idx := strFields.IndexOf(s);
      if idx <> -1 then
      begin
        f := strTagFields[idx];
        s := strFields.Strings[idx]
      end else
      begin
        idx := IndexText(s, strTagExtraFields);
        if idx = -1 then
          idx := strExtraFields.IndexOf(s + ' (' + strExtras + ')');
        if idx <> -1 then
        begin
          f := strTagExtraFields[idx];
          s := strExtraFields.Strings[idx] + ' (' + strExtras + ')';
          idx := idx + extraFieldLow;
        end else
        begin
          idx := Properties.IndexOf(s);
          if idx <> -1 then
          begin
            if Properties.Objects[idx].FieldType <> ftVirtual then
            begin
              f := Properties.Objects[idx].FieldTag;
              s := Properties.Objects[idx].FieldName;
              idx := idx + customFieldLow;
            end else
              idx := -1;
          end;
        end;
      end;
    end;
    if idx in VirtualFields then
      idx := -1;
    if idx = -1 then
      s := '';
    listPreview.HeaderSections[i].FieldName := IntToStr(idx);
    listPreview.HeaderSections[i].Text := s;
    if (idx <> -1) and (FCommonSettings.KeyField <> '') and (FCommonSettings.KeyField = f) and
      ((idx in AllFields) or (idx in AllCustomFields)) then
      listPreview.Tag := i;
  end;
  if listPreview.Tag <> -1 then
    ActionDefineKeyFieldExecute(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnFieldsSaveClick(Sender: TObject);
var
  i, n, Last: Integer;
  f: string;
begin
  if FCommonSettings = nil then
    Exit;
  Last := -1;
  FCommonSettings.Fields.Clear;
  FCommonSettings.KeyField := '';
  for i := 1 to listPreview.HeaderSections.Count - 1 do
  begin
    with listPreview.HeaderSections[i] do
    begin
      f := '';
      n := StrToInt(FieldName);
      if n = fieldPicture then
        f := strTagFieldPicture
      else if n = extraFieldPicture then
        f := strTagExtraFieldPicture
      else if (n >= fieldLow) and (n < fieldCount) then
        f := strTagFields[n]
      else if (n >= extraFieldLow) and (n < extraFieldCount) then
        f := strTagExtraFields[n - extraFieldLow]
      else if (n >= customFieldLow) and (n - customFieldLow < Properties.Count) then
        f := Properties.Objects[n - customFieldLow].FieldTag;
    end;
    FCommonSettings.Fields.Add(f);
    if (FKeyColumn <> -1) and (n = StrToInt(listPreview.HeaderSections[FKeyColumn].FieldName)) then
      FCommonSettings.KeyField := f;
    if f <> '' then
      Last := i-1;
  end;
  while FCommonSettings.Fields.Count - 1 > Last do
    FCommonSettings.Fields.Delete(Last + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnFieldsAutoLoadClick(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.btnColumnsAutoResizeClick(Sender: TObject);
begin
  ResizeColumns(btnColumnsAutoResize.Checked);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ActionListCheckExecute(Sender: TObject);
var
  State, All: Boolean;
  i: Integer;
begin
  State := (Sender = ActionListCheck) or (Sender = ActionListAll);
  All := (Sender = ActionListAll) or (Sender = ActionListNone);
  listPreview.Items.BeginUpdate;
  for i := 0 to listPreview.Items.Count-1 do
    if All or listPreview.Items[i].Selected then
      listPreview.Items[i].Checked := State;
  listPreview.Items.EndUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ActionListCheckExistsExecute(Sender: TObject);
var
  State: Boolean;
  i: Integer;
  SourceMovie: TMovie;
  Corresp: TFieldCorresps;
  Item: TElTreeItem;
  Value: String;

  function GetFieldValue(const c: Integer): string;
  begin
    if c < Item.SubItems.Count then
      Result := Item.SubItems[c]
    else
      Result := '';
  end;
begin
  if FKeyColumn = -1 then
  begin
    MessageWin.Execute(InsertLineBreaks(Messages.Strings[msgKeyFieldNotDefined]), mtError, [mbOk]);
    Exit;
  end;
  State := (Sender = ActionListCheckExists);
  ImportEngine.GetFieldCorresp(Corresp, listPreview.HeaderSections);
  listPreview.Items.BeginUpdate;
  for i := 0 to listPreview.Items.Count-1 do
  begin
    Item := listPreview.Items[i];
    SourceMovie := TMovie(Item.Data); // can be nil
    Value := '';
    if (SourceMovie <> nil) and (Corresp[FKeyColumn-1].SourceField <> -1) then
    begin
      if Corresp[FKeyColumn-1].SourceField < fieldCount then // Movie Field
        Value := SourceMovie.GetFieldValue(Corresp[FKeyColumn-1].SourceField)
      else if Corresp[FKeyColumn-1].SourceField >= customFieldLow then // Custom Field
        Value := SourceMovie.CustomFields.GetFieldValue(SourceMovie.CustomFields.Properties.Strings[Corresp[FKeyColumn-1].SourceField - customFieldLow]);
    end
    else if Corresp[FKeyColumn-1].TargetField <> -1 then
    begin
      Value := ImportEngine.AdjustValue(Corresp[FKeyColumn-1].TargetField, GetFieldValue(FKeyColumn-1));
    end;
    if (Value <> '') and (FKeyFieldValues.IndexOf(Value) <> -1) then
      listPreview.Items[i].Checked := State;
  end;
  listPreview.Items.EndUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ActionHeaderClick(Sender: TObject);
var
  n: Integer;
begin
  if Sender is TTBXItem then
    with listPreview.HeaderSections[listPreview.Tag] do
    begin
      n := TTBXItem(Sender).Tag;
      FieldName := IntToStr(n);
      if n = fieldPicture then
        Text := strFieldPicture
      else if n = extraFieldPicture then
        Text := strExtraFieldPicture + ' (' + strExtras +  ')'
      else if (n >= fieldLow) and (n < fieldCount) then
        Text := strFields[n]
      else if (n >= extraFieldLow) and (n < extraFieldCount) then
        Text := strExtraFields[n - extraFieldLow] + ' (' + strExtras +  ')'
      else if (n >= customFieldLow) and (n - customFieldLow < Properties.Count) then
        Text := Properties.Objects[n - customFieldLow].FieldName
      else
      begin
        FieldName := '-1';
        Text := '';
      end;
      if listPreview.Tag = FKeyColumn then
        FKeyColumn := -1;
    end
  else if Sender = ActionHeaderNoImport then
    with listPreview.HeaderSections[listPreview.Tag] do
    begin
      FieldName := '-1';
      Text := '';
      if listPreview.Tag = FKeyColumn then
        FKeyColumn := -1;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ActionDefineKeyFieldExecute(Sender: TObject);
begin
  if FKeyColumn <> -1 then
    with listPreview.HeaderSections[FKeyColumn] do
    begin
      Text := Copy(Text, 3, Length(Text)-2);
      if FKeyColumn <> listPreview.Tag then
        FKeyColumn := -1
      else
        FKeyColumn := -2;
    end;
  if (FKeyColumn = -1) and ((listPreview.Tag in AllFields) or (listPreview.Tag in AllCustomFields)) then
    with listPreview.HeaderSections[listPreview.Tag] do
    begin
      Text := '* ' + Text;
      FKeyColumn := listPreview.Tag;
      MakeKeyFieldValues;
      if (Sender <> nil) and FKeyFieldValuesNotUnique then
        MessageWin.Execute(InsertLineBreaks(Messages.Strings[msgKeyValuesNotUnique]), mtWarning, [mbOk]);
    end
  else
    FKeyColumn := -1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ActionSortExecute(Sender: TObject);
begin
  listPreview.SortSection := listPreview.Tag;
  with listPreview do
  with HeaderSections do
  begin
    if Sender = ActionSortDescend then
      Item[SortSection].SortMode := hsmDescend
    else
      Item[SortSection].SortMode := hsmAscend;
  end;
  listPreview.Sort(True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewHeaderColumnClick(Sender: TObject; SectionIndex: Integer);
var
  i, n: Integer;
  PicAssigned: Boolean;
  ExtraPicAssigned: Boolean;
  FieldsAssigned: TMovieFields;
  CustomFieldsAssigned: TMovieFields;
  ExtraFieldsAssigned: TMovieFields;
  Item: TTBXItem;
  HeaderSection: TElHeaderSection;
begin
  listPreview.Tag := SectionIndex;
  if SectionIndex = 0 then
  begin
    with listPreview do
    with HeaderSections do
      if (SortSection = 0) and (Item[SortSection].SortMode = hsmAscend) then
         ActionSortExecute(ActionSortDescend)
      else
         ActionSortExecute(ActionSortAscend);
  end;
  if SectionIndex <= 0 then
    Exit;
  HeaderSection := listPreview.HeaderSections[SectionIndex];
  PicAssigned := False;
  ExtraPicAssigned := False;
  FieldsAssigned := [];
  CustomFieldsAssigned := [];
  ExtraFieldsAssigned := [];
  for i := 1 to listPreview.HeaderSections.Count - 1 do
  begin
    n := StrToInt(listPreview.HeaderSections[i].FieldName);
    if n = fieldPicture then
      PicAssigned := True
    else if n = extraFieldPicture then
      ExtraPicAssigned := True
    else if (n >= fieldLow) and (n < fieldCount) then
      Include(FieldsAssigned, n)
    else if (n >= extraFieldLow) and (n < extraFieldCount) then
      Include(ExtraFieldsAssigned, n)
    else if (n >= customFieldLow) and
      (n - customFieldLow < Properties.Count) then
      Include(CustomFieldsAssigned, n);
  end;
  n := StrToInt(HeaderSection.FieldName);
  for i := 0 to MnuMov.Count-1 do
  begin
    Item := MnuMov.Items[i] as TTBXItem;
    Item.Checked := n = Item.Tag;
    if Item.Tag = fieldPicture then
      Item.Enabled := not PicAssigned
    else
      Item.Enabled := not (Item.Tag in FieldsAssigned);
  end;
  for i := 0 to MnuMovCF.Count-1 do
  begin
    Item := MnuMovCF.Items[i] as TTBXItem;
    Item.Checked := n = Item.Tag;
    Item.Enabled := not (Item.Tag in CustomFieldsAssigned);
  end;
  for i := 0 to MnuMovExtras.Count-1 do
  begin
    Item := MnuMovExtras.Items[i] as TTBXItem;
    Item.Checked := n = Item.Tag;
    if Item.Tag = extraFieldPicture then
      Item.Enabled := not ExtraPicAssigned
    else
      Item.Enabled := not (Item.Tag in ExtraFieldsAssigned);
  end;
  ActionDefineKeyField.Enabled :=  (n <> -1) and ((n in AllFields) or (n in AllCustomFields));
  ActionDefineKeyField.Checked := (FKeyColumn = SectionIndex);
  MenuPopupHeader.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.LoadSettings;
begin
  with Settings.rImport do
  begin
    chkAllowDup.Checked := AllowDup;
    chkAllowClear.Checked := AllowClear;
    chkAutoAssign.Checked := AutoAssign;
    cmbPictures.ItemIndex := PicImport;
    cmbPictures.ItemIndex := PicImport;
    cmbExtraPictures.ItemIndex := ExtraPicImport;
    edtSourceFile.Text := LastFiles.Values[FImportType];
  end;
  //FitDropDownToContents(cmbPictures);
  SetComboxDropDownAutoWidth(cmbPictures);
  SetComboxDropDownAutoWidth(cmbExtraPictures);
  if (FCommonSettings <> nil) then
  begin
    btnFieldsAutoLoad.Checked := FCommonSettings.AutoLoadFields;
    btnColumnsAutoResize.Checked := FCommonSettings.AutoResizeColumns;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.SaveSettings;
begin
  with Settings.rImport do
  begin
    AllowDup := chkAllowDup.Checked;
    AllowClear := chkAllowClear.Checked;
    AutoAssign := chkAutoAssign.Checked;
    PicImport := cmbPictures.ItemIndex;
    ExtraPicImport := cmbExtraPictures.ItemIndex;
    LastFiles.Values[FImportType] := edtSourceFile.Text;
  end;
  if (FCommonSettings <> nil) then
  begin
    FCommonSettings.AutoLoadFields := btnFieldsAutoLoad.Checked;
    FCommonSettings.AutoResizeColumns := btnColumnsAutoResize.Checked;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.SetCatalogFile(const ACatalogFile: TFileName);
begin
  FCatalogFile := ACatalogFile;
  FCatalogPath := ExtractFilePath(FCatalogFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.MakeKeyFieldValues;
var
  i, idx, field: Integer;
  value: string;
  AList: TMovieList;
  movie: TMovie;
  objectList: TObjectList;
begin
  FreeObjects(FKeyFieldValues);
  FKeyFieldValues.Clear;
  FKeyFieldValuesNotUnique := False;
  AList := Properties.MovieList;
  if (AList = nil) or (FKeyColumn = -1) then
    exit;
  field := StrToInt(listPreview.HeaderSections[FKeyColumn].FieldName);
  if (field = -1) or not ((field in AllFields) or (field in AllCustomFields)) then
    exit;
  for i := 0 to AList.Count-1 do
  begin
    value := '';
    movie := AList.Items[i];
    if (field < fieldCount) then // Movie Field
      value := movie.GetFieldValue(field)
    else if field >= customFieldLow then // CustomField
      value := movie.CustomFields.GetFieldValue(Properties.Strings[field - customFieldLow]);
    if value <> '' then
    begin
      idx := FKeyFieldValues.IndexOf(value);
      if idx = -1 then
      begin
        objectList := TObjectList.Create(False);
        FKeyFieldValues.AddObject(value, objectList);
        objectList.Add(movie);
      end else
      begin
        FKeyFieldValuesNotUnique := True;
        objectList := TObjectList(FKeyFieldValues.Objects[idx]);
        objectList.Add(movie);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ResizeColumns(Auto: Boolean);
var
  i, j, tmp, size: Integer;
  c: TBitmap;
begin
  if listPreview.HeaderSections.Count > 0 then
  begin
    listPreview.HeaderSections[0].Width := 22;
    if (Auto) then
    begin
      c := TBitmap.Create;
      try
        c.Canvas.Font.Assign(listPreview.Font);
        for i := 1 to listPreview.HeaderSections.Count-1 do
        begin
          size := 0;
          for j := 0 to listPreview.Items.Count-1 do
          begin
            if (i-1) < listPreview.Items[j].SubItems.Count then
            begin
              tmp := c.Canvas.TextWidth(listPreview.Items[j].SubItems[i-1])+10;
              if size < tmp then
                size := tmp;
              if size > 1000 then
                Break;
            end;
          end;
          if size < 100 then
            size := 100
          else if size > 1000 then
            size := 1000;
          listPreview.HeaderSections[i].Width := size;
        end;
      finally
        c.Free;
      end;
    end else
    begin
      for i := 1 to listPreview.HeaderSections.Count-1 do
      begin
        listPreview.HeaderSections[i].Width := 100;
      end;
    end;
    listPreview.Width := listPreview.Width - 1;
    listPreview.Width := listPreview.Width + 1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportFrame.ImportToList: Boolean;
var
  i, j, idx, MaxNum: Integer;
  NbAssignedColumns: Integer;
  NbMoviesToImport: Integer;
  NbMoviePictures: Integer;
  NbExtraPictures: Integer;
  AList: TMovieList;
  Item: TElTreeItem;
  SourceMovie, CurrentMovie: TMovie;
  Corresp: TFieldCorresps;
  AddedMovies: TList;
  UpdatedMovies: TList;
  AllowDups, AllowClears: Boolean;
  Value: string;
  PrevCursor: TCursor;
  ImportMethod: Integer;
  ImportExtrasNew: Boolean;
  ImportExtras: Boolean;
  DeleteExtras: Boolean;
  ExtraStart: Integer;
  ExtraSep: string;
  ObjectList: TObjectList;

  function GetFieldValue(const c: Integer): string;
  begin
    if (c >= 0) and (c < Item.SubItems.Count) then
      Result := Item.SubItems[c]
    else
      Result := '';
  end;

  procedure AnalysePreviewList;
  var
    i, c: Integer;
    cMoviePicture: Integer;
    cExtraPictures: Integer;
  begin
    NbAssignedColumns := 0;
    NbMoviesToImport := 0;
    NbMoviePictures := 0;
    NbExtraPictures := 0;
    cMoviePicture := -1;
    cExtraPictures := -1;
    // for each column
    for c := 0 to Length(Corresp)-1 do
    begin
      if Corresp[c].TargetField <> -1 then
        Inc(NbAssignedColumns);
      if Corresp[c].TargetField = fieldPicture then
        cMoviePicture := c
      else if (Corresp[c].TargetField = extraFieldPicture) then
        cExtraPictures := c;
    end;
    // for each line
    for i := 0 to listPreview.Items.Count-1 do
    begin
      Item := listPreview.Items[i];
      if Item.Checked then
      begin
        Inc(NbMoviesToImport);
        if GetFieldValue(cMoviePicture) <> '' then
          Inc(NbMoviePictures);
        if GetFieldValue(cExtraPictures) <> '' then
          Inc(NbExtraPictures);
      end;
    end;
  end;

  procedure SetMovieValues(SetExtraValues: Boolean; SetExtraValuesStart: Integer = 0);
  var
    c: Integer;
  begin
    // for each column
    for c := 0 to Length(Corresp)-1 do
    begin
      if (Corresp[c].TargetField <> -1) and (Corresp[c].TargetField <> fieldPicture) and
        (Corresp[c].TargetField <> extraFieldPicture) and
        (SetExtraValues or (Corresp[c].SourceField < extraFieldLow) or
        (Corresp[c].SourceField >= extraFieldCount)) then
      begin
        // get field value
        Value := '';
        if (SourceMovie <> nil) and (Corresp[c].SourceField <> -1) and
          (Corresp[c].SourceField <> fieldPicture) and
          (Corresp[c].SourceField <> extraFieldPicture) then
        begin
          if Corresp[c].SourceField < fieldCount then // Movie Field
            Value := SourceMovie.GetFieldValue(Corresp[c].SourceField)
          else if (Corresp[c].SourceField >= extraFieldLow) and
            (Corresp[c].SourceField < extraFieldCount) then // Extra Field
            Value := SourceMovie.Extras.GetFieldValues(Corresp[c].SourceField)
          else if (Corresp[c].SourceField >= customFieldLow) and
            (Corresp[c].SourceField - customFieldLow <
            SourceMovie.CustomFields.Properties.Count) then // CustomField
            Value := SourceMovie.CustomFields.GetFieldValue(
              SourceMovie.CustomFields.Properties.Strings[Corresp[c].SourceField - customFieldLow]);
        end
        else
        begin
          Value := ImportEngine.AdjustValue(Corresp[c].TargetField, GetFieldValue(c));
        end;
        // copy field value
        if (Value <> '') or AllowClears then
        begin
          if Corresp[c].TargetField < fieldCount then // Movie Field
            CurrentMovie.SetFieldValue(Corresp[c].TargetField, Value)
          else if (Corresp[c].TargetField >= extraFieldLow) and
            (Corresp[c].TargetField < extraFieldCount) then // Extra Field
            CurrentMovie.Extras.SetFieldValues(Corresp[c].TargetField, Value, ExtraSep,
              SetExtraValuesStart, AllowClears, True, True, False)
          else if (Corresp[c].TargetField >= customFieldLow) and
            (Corresp[c].TargetField - customFieldLow < Properties.Count) then // CustomField
            CurrentMovie.CustomFields.SetFieldValue(
              Properties.Strings[Corresp[c].TargetField - customFieldLow],
              Value, False);
        end;
        // check for duplicates
        if (not AllowDups) and (Corresp[c].TargetField = fieldNumber) and (CurrentMovie.iNumber > 0) then
          if AList.Count(CurrentMovie.iNumber) > 1 then
          begin
            CurrentMovie.iNumber := 0;
          end;
      end;
    end;
    // assign movie number if needed
    if CurrentMovie.iNumber = 0 then
    begin
      if MaxNum < MaxInt then
      begin
        Inc(MaxNum);
        CurrentMovie.iNumber := MaxNum;
      end
      else
        CurrentMovie.iNumber := AList.FirstFreeNumber;
    end;
  end;
  
  procedure SetMovieDefaultPicture();
  begin
    if Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath <> '' then
    begin
      try
        CurrentMovie.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath,
          FCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rPicImport.GetInfoMethod)));
      except
      end;
    end;
  end;
  
  // Add default picture on extras added (_status = mesAdded) and reset status to normal
  procedure SetMovieDefaultExtraPictures();
  var
    i: Integer;
  begin
    for i := 0 to CurrentMovie.Extras.Count-1 do
      if CurrentMovie.Extras.Items[i]._iStatus = mesAdded then
      begin
        if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
          try
            CurrentMovie.Extras.Items[i].Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
              FCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
          except
          end;
        CurrentMovie.Extras.Items[i]._iStatus := mesNormal;
      end;
  end;
  
  procedure SetMoviePictures(SetExtraPictures: Boolean; SetExtraPicturesStart: Integer = 0);
  var
    c: Integer;
  begin
    // for each column
    for c := 0 to Length(Corresp)-1 do
    begin
      if Corresp[c].TargetField = fieldPicture then
      begin
        ImportPicture(SourceMovie, CurrentMovie, Corresp[c].SourceField,
          ImportEngine.AdjustValue(Corresp[c].TargetField,
          GetFieldValue(c)), AllowClears);
      end
      else
      if (Corresp[c].TargetField = extraFieldPicture) and SetExtraPictures then
      begin
        ImportExtraPictures(SourceMovie, CurrentMovie, Corresp[c].SourceField,
          ImportEngine.AdjustValue(Corresp[c].TargetField,
          GetFieldValue(c)), ExtraSep, ExtraStart, AllowClears);
      end
    end;
  end;

begin
  Result := False;

  ImportEngine.GetFieldCorresp(Corresp, listPreview.HeaderSections);
  AnalysePreviewList;
  if (FCatalogFile = '') and (
      ((cmbPictures.ItemIndex in [1,2,3,4,6]) and ((NbMoviePictures > 0) or
        (Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath <> '')))
      or
      ((cmbExtraPictures.ItemIndex in [1,2,3,4,6]) and ((NbExtraPictures > 0) or
        (Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '')))
    ) then
    raise Exception.Create(Messages.Strings[msgNoCatalogName]);
  if NbMoviesToImport = 0 then
    raise Exception.Create(Messages.Strings[msgNoMovie]);
  if NbAssignedColumns = 0 then
    raise Exception.Create(Messages.Strings[msgNoColumn]);

  AList := Properties.MovieList;

  PrevCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TImportMethodWin, ImportMethodWin);
    try
      if ImportMethodWin.Execute(FKeyColumn <> -1) = mrOk then
      begin
        ImportMethod := ImportMethodWin.grpImportMethod.ItemIndex;
        ImportExtrasNew := ImportMethodWin.chkImportExtrasNew.Checked;
        ImportExtras := ImportMethodWin.chkImportExtras.Checked;
        DeleteExtras := ImportMethodWin.chkDeleteExtras.Checked;
      end else
      begin
        ImportMethod := -1;
        ImportExtrasNew := False;
        ImportExtras := False;
        DeleteExtras := False;
      end;
    finally
      ImportMethodWin.Release;
      ImportMethodWin := nil;
    end;
  finally
    Screen.Cursor := PrevCursor;
  end;
  if ImportMethod = -1 then
    Exit;

  AllowDups := chkAllowDup.Checked;
  AllowClears := chkAllowClear.Checked;
  AddedMovies := TList.Create;
  UpdatedMovies := TList.Create;

  if FFirstImport then // We clear selected items
    with AList do
      for i := 0 to Count-1 do
        with Items[i] do
        begin
          _bSelected := False;
          _selectedGroup := '';
        end;
  FFirstImport := False;

  FCancelImport := False;
  ProgressWin.Status := Messages.Strings[msgImport];
  ProgressWin.Maximum := NbMoviesToImport;
  ProgressWin.IntProgress := 0;
  ProgressWin.Execute(FImportWin);
  ProgressWin.OnCancel := OnCancelImport;
  try
    try
      if Settings.rOptions.rMovieInformation.FirstAvailable then
        MaxNum := MaxInt
      else
        MaxNum := AList.MaxNumber;
      
      ExtraSep := ImportEngine.GetExtraSep;
      
      // for each movie
      i := 0;
      while (i < listPreview.Items.Count) and (not FCancelImport) do
      begin
        Item := listPreview.Items[i];
        if Item.Checked then
        begin
          SourceMovie := TMovie(Item.Data); // can be nil

          idx := -1;
          if (ImportMethod > 0) then
          begin
            Value := '';
            if (SourceMovie <> nil) and (Corresp[FKeyColumn-1].SourceField <> -1) then
            begin
              if Corresp[FKeyColumn-1].SourceField < fieldCount then // Movie Field
                Value := SourceMovie.GetFieldValue(Corresp[FKeyColumn-1].SourceField)
              else if Corresp[FKeyColumn-1].SourceField >= customFieldLow then // Custom Field
                Value := SourceMovie.CustomFields.GetFieldValue(
                  SourceMovie.CustomFields.Properties.Strings[Corresp[FKeyColumn-1].SourceField - customFieldLow]);
            end
            else if Corresp[FKeyColumn-1].TargetField <> -1 then
            begin
              Value := ImportEngine.AdjustValue(
                Corresp[FKeyColumn-1].TargetField, GetFieldValue(FKeyColumn-1));
            end;
            if Value <> '' then
              idx := FKeyFieldValues.IndexOf(Value);
          end;

          if idx = -1 then
          begin
            if (ImportMethod = 0) or (ImportMethod = 1) or (ImportMethod = 3) then
            begin
              ImportEngine.ExtractDelayedInfo(listPreview, i, FCancelImport);
              if not FCancelImport then
              begin
                CurrentMovie := AList.Add;
                CurrentMovie.bChecked := True;
                CurrentMovie._bSelected := True;
                CurrentMovie.Assign(Settings.rOptions.rMovieInformation.rDefaultMovie.Values, False, False, False, False, True);
                if Settings.rOptions.rMovieInformation.SetCurrentDate then
                  CurrentMovie.iDate := Trunc(Date);
                CurrentMovie.CustomFields.SetDefaultValues;
                // We import pictures later to have the good filename according to field values
                SetMovieValues(ImportExtrasNew, 0);
                // We import pictures here to have the good filename according to field values
                SetMovieDefaultPicture;
                if ImportExtrasNew then
                  SetMovieDefaultExtraPictures;
                SetMoviePictures(ImportExtrasNew, 0);
                AddedMovies.Add(CurrentMovie);
              end;
            end;
          end else
          begin
            if (ImportMethod = 2) or (ImportMethod = 3) then
            begin
              ImportEngine.ExtractDelayedInfo(listPreview, i, FCancelImport);
              if not FCancelImport then
              begin
                ObjectList := TObjectList(FKeyFieldValues.Objects[idx]);
                for j := 0 to ObjectList.Count-1 do
                begin
                  CurrentMovie := TMovie(ObjectList.Items[j]);
                  CurrentMovie._bSelected := True;
                  if DeleteExtras then
                  begin
                    CurrentMovie.Extras.DeletePictures(FCatalogFile);
                    CurrentMovie.Extras.Clear;
                  end;
                  ExtraStart := CurrentMovie.Extras.Count;
                  SetMovieValues(ImportExtras, ExtraStart);
                  // We import pictures here to have the good filename according to field values
                  if ImportExtras then
                    SetMovieDefaultExtraPictures;
                  SetMoviePictures(ImportExtras, ExtraStart);
                  UpdatedMovies.Add(CurrentMovie);
                end;
              end;
            end;
          end;
          ProgressWin.StepIt;
        end;
        Inc(i);
      end;

      // Close progress window
      ProgressWin.IntProgress := ProgressWin.Maximum;
      ProgressWin.OnCancel := nil;
      ProgressWin.Close;

      // Inform User
      MessageWin.Execute(
        Format(Messages.Strings[msgMoviesAdded] + #10 + Messages.Strings[msgMoviesUpdated],
          [IntToStr(AddedMovies.Count), IntToStr(UpdatedMovies.Count)]),
          mtInformation, [mbOk]);
    except
      for i := AddedMovies.Count-1 downto 0 do
      begin
        CurrentMovie := TMovie(AddedMovies[i]);
        CurrentMovie.Picture.PictureOperation(FCatalogFile, mpoDelete);
        CurrentMovie.Extras.DeletePictures(FCatalogFile);
        AList.Remove(AddedMovies[i]);
      end;

      // Close progress window
      ProgressWin.OnCancel := nil;
      ProgressWin.Close;

      if Item <> nil then
      begin
        Value := 'An error occur on item:';
        for i := 0 to Item.SubItems.Count-1 do
          Value := Value + #10 + FImportEngine.GetHint(i+1, Item.SubItems[i]);
        MessageWin.Execute(Value, mtError, [mbOk]);
      end;
      raise;
    end;
  finally
    listPreview.Visible := False;
    listPreview.Items.Clear;
    listPreview.HeaderSections.Clear;
    listPreview.ShowColumns := False;
    listPreview.Visible := True;

    Result := (AddedMovies.Count > 0) or (UpdatedMovies.Count > 0);

    // Free
    AddedMovies.Free;
    UpdatedMovies.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ImportPicture(SourceMovie, CurrentMovie: TMovie;
  SourceField: Integer; FieldValue: string; const AllowClears: Boolean);
var
  PicImport: TMoviePictureImport;
  res: Integer;
begin
  PicImport := mpiUndefined;
  if cmbPictures.ItemIndex = 0 then
    PicImport := mpiStore
  else if cmbPictures.ItemIndex = 1 then
    PicImport := mpiCopyInCatDir
  else if cmbPictures.ItemIndex = 2 then
    if (SourceMovie <> nil) and (SourceField = fieldPicture) and
      (SourceMovie.Picture.PicStream <> nil) then
      PicImport := mpiStore
    else
      PicImport := mpiCopyInCatDir
  else if cmbPictures.ItemIndex = 3 then
    PicImport := mpiCopyInPicDir
  else if cmbPictures.ItemIndex = 4 then
    if (SourceMovie <> nil) and (SourceField = fieldPicture) and
     (SourceMovie.Picture.PicStream <> nil) then
      PicImport := mpiStore
    else
      PicImport := mpiCopyInPicDir
  else if cmbPictures.ItemIndex = 5 then
    PicImport := mpiLinkAbs
  else if cmbPictures.ItemIndex = 6 then
    PicImport := mpiLinkRel;
  try
    if (SourceMovie <> nil) and (SourceField = fieldPicture) then
    begin
      if SourceMovie.Picture.PicPath <> '' then
        if SourceMovie.Picture.PicStream <> nil then
          CurrentMovie.Picture.ImportPictureFromStream(SourceMovie.Picture.PicStream, SourceMovie.Picture.PicPath, FCatalogFile, PicImport)
        else
        begin
          SetCurrentDir(ExtractFilePath(edtSourceFile.Text));
          CurrentMovie.Picture.ImportPicture(ExpandFileName(SourceMovie.Picture.PicPath), FCatalogFile, PicImport);
        end
      else if AllowClears then
        CurrentMovie.Picture.PictureOperation(FCatalogFile, mpoDelete);
    end
    else
    begin
      if FieldValue <> '' then
      begin
        SetCurrentDir(ExtractFilePath(edtSourceFile.Text));
        CurrentMovie.Picture.ImportPicture(ExpandFileName(FieldValue), FCatalogFile, PicImport);
      end
      else if AllowClears then
        CurrentMovie.Picture.PictureOperation(FCatalogFile, mpoDelete);
    end;
  except
    on e: Exception do
    begin
      //res := 1;
      if SourceMovie <> nil then
        if SourceMovie.Picture.PicStream <> nil then
          res := MessageWin.Execute('<Picture> : ' + e.Message, mtError, [mbOk, mbAbort])
        else
          res := MessageWin.Execute(SourceMovie.Picture.PicPath + ' : ' + e.Message, mtError, [mbOk, mbAbort])
      else
        res := MessageWin.Execute(FieldValue + ' : ' + e.Message, mtError, [mbOk, mbAbort]);
      if res = 2 then
        FCancelImport := True;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.ImportExtraPictures(SourceMovie, CurrentMovie: TMovie;
  SourceField: Integer; FieldValues: string; const Separator: string;
  Start: Integer; const AllowClears: Boolean);
var
  SourceDir: TFileName;
  ExtraPicImport: TMoviePictureImport;
  nbPic, i, res: Integer;
  list: TStringList;
  PicSrc, PicDst: TMoviePicture;
  Value: string;
begin
  SourceDir := GetCurrentDir;
  if (SourceMovie <> nil) and (SourceField = extraFieldPicture) then
  begin
    list := nil;
    nbPic := SourceMovie.Extras.Count
  end else
  begin
    list := GetMultiValuesSimple(FieldValues, Separator);
    nbPic := list.Count;
  end;
  
  if Start > CurrentMovie.Extras.Count then
    Start := CurrentMovie.Extras.Count;

  ExtraPicImport := mpiUndefined;
  if cmbExtraPictures.ItemIndex = 0 then
    ExtraPicImport := mpiStore
  else if cmbExtraPictures.ItemIndex = 1 then
    ExtraPicImport := mpiCopyInCatDir
  else if cmbExtraPictures.ItemIndex = 2 then
      ExtraPicImport := mpiCopyInCatDir
  else if cmbExtraPictures.ItemIndex = 3 then
    ExtraPicImport := mpiCopyInPicDir
  else if cmbExtraPictures.ItemIndex = 4 then
    ExtraPicImport := mpiCopyInPicDir
  else if cmbExtraPictures.ItemIndex = 5 then
    ExtraPicImport := mpiLinkAbs
  else if cmbExtraPictures.ItemIndex = 6 then
    ExtraPicImport := mpiLinkRel;

  for i := 0 to nbPic-1 do
  begin
    if (list = nil) and ((cmbExtraPictures.ItemIndex = 2) or
      (cmbExtraPictures.ItemIndex = 4)) then
      if (SourceMovie.Extras.Items[i].Picture.PicStream <> nil) then
        ExtraPicImport := mpiStore
      else if (cmbExtraPictures.ItemIndex = 2) then
        ExtraPicImport := mpiCopyInCatDir
      else
        ExtraPicImport := mpiCopyInPicDir;

    if (Start + i) = CurrentMovie.Extras.Count then
    begin
      if CurrentMovie.Extras.AddExtra = -1 then
        break;
      CurrentMovie.Extras.Items[Start + i]._bSelected := True;
      CurrentMovie.Extras.Items[Start + i].bChecked := True;
      CurrentMovie.Extras.Items[Start + i].Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
      if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
        try
          CurrentMovie.Extras.Items[Start + i].Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
            FCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
        except
        end;
    end;

    PicSrc := nil;
    Value := '';
    try
      PicDst := CurrentMovie.Extras.Items[Start + i].Picture;
      if (list = nil) then
      begin
        PicSrc := SourceMovie.Extras.Items[i].Picture;
        if PicSrc.PicPath <> '' then
          if PicSrc.PicStream <> nil then
            PicDst.ImportPictureFromStream(PicSrc.PicStream, PicSrc.PicPath, FCatalogFile, ExtraPicImport)
          else
          begin
            SetCurrentDir(ExtractFilePath(edtSourceFile.Text));
            PicDst.ImportPicture(ExpandFileName(PicSrc.PicPath), FCatalogFile, ExtraPicImport);
          end
        else if AllowClears then
          PicDst.PictureOperation(FCatalogFile, mpoDelete);
      end
      else
      begin
        if list.Strings[i] <> '' then
        begin
          Value := list.Strings[i];
          SetCurrentDir(ExtractFilePath(edtSourceFile.Text));
          PicDst.ImportPicture(ExpandFileName(Value), FCatalogFile, ExtraPicImport);
        end
        else if AllowClears then
          PicDst.PictureOperation(FCatalogFile, mpoDelete);
      end;
    except
      on e: Exception do
      begin
        //res := 1;
        if PicSrc <> nil then
          if PicSrc.PicStream <> nil then
            res := MessageWin.Execute('<Extra picture> : ' + e.Message, mtError, [mbOk, mbAbort])
          else
            res := MessageWin.Execute(PicSrc.PicPath + ' : ' + e.Message, mtError, [mbOk, mbAbort])
        else
          res := MessageWin.Execute(Value + ' : ' + e.Message, mtError, [mbOk, mbAbort]);
        if res = 2 then
          FCancelImport := True;
      end;
    end;
  end;

  FreeAndNil(list);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (not listPreview.Focused) and (listPreview.CanFocus) then
    listPreview.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewHotTrack(Sender: TObject;
  OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem;
  NewSection: TElHeaderSection);
var
  i: Integer;
  hint: string;
begin
  hint := '';
  if (NewItem <> nil) and (NewSection <> nil) then
  begin
    i := NewSection.Index;
    if i > 0 then
    begin
      if i <= NewItem.SubItems.Count then
        hint := FImportEngine.GetHint(i, NewItem.SubItems[i-1])
      else
        hint := FImportEngine.GetHint(i, '');
    end;
  end;
  listPreview.Hint := hint;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('A')) and (Shift = [ssCtrl]) then
  begin
    listPreview.SelectAll;
  end
  else if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
  begin
    with listPreview do
      if ItemFocused <> nil then
        ItemFocused.Checked := not ItemFocused.Checked;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewShowLineHint(Sender: TObject;
  Item: TElTreeItem; var Text: String; HintWindow: THintWindow;
  MousePos: TPoint; var DoShowHint: Boolean);
begin
  DoShowHint := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.listPreviewCompareItems(Sender: TObject; Item1,
  Item2: TElTreeItem; var res: Integer);
begin
  with listPreview do
  begin
    if (Item1 = Item2) or (SortSection = -1) then
      res := 0
    else
    begin
      if (SortSection <> 0) then
        if Settings.rOptions.rDisplay.NaturalCompare then
          res := AnsiNatCompareText(Item1.SubItems[SortSection-1], Item2.SubItems[SortSection-1])
        else
          res := AnsiCompareText(Item1.SubItems[SortSection-1], Item2.SubItems[SortSection-1])
      else
        res := CompareText(BoolToStr(Item1.Checked, True), BoolToStr(Item2.Checked, True));
      if res = 0 then
        res := (Item1.Tag - Item2.Tag);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.edtSourceFileKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_RETURN) then
    btnReloadClick(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrame.OnCancelImport(Sender: TObject);
begin
  FCancelImport := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
