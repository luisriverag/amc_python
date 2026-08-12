(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2013-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit getscript_extrasresults;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ExtCtrls, Contnrs,

  ComCtrls, AntStringList, AntCorelButton, AntAutoHintLabel,

  movieclass, FileManager, fields, ActnList, TB2Item, TBX, Menus, getscript_results,
  ElTree, ElList, ElHeader;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TScriptExtrasResultsWin = class(TBaseDlg)
    Messages: TAntStringList;
    ActionList1: TActionList;
    ActionListCheck: TAction;
    ActionListUncheck: TAction;
    ActionListAll: TAction;
    ActionListNone: TAction;
    MenuPopupList: TTBXPopupMenu;
    MnuLspChk: TTBXItem;
    MnuLspUnc: TTBXItem;
    MnuLsp__1: TTBXSeparatorItem;
    MnuLspAll: TTBXItem;
    MnuLspNon: TTBXItem;
    listExtras: TElTree;
    listValues: TElTree;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure listExtrasMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure listExtrasAfterSelectionChange(Sender: TObject);
    procedure listExtrasItemChecked(Sender: TObject; Item: TElTreeItem);
    procedure listExtrasDblClick(Sender: TObject);
    procedure listExtrasKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure listValuesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure listValuesDblClick(Sender: TObject);
    procedure listValuesHotTrack(Sender: TObject; OldItem: TElTreeItem;
      OldSection: TElHeaderSection; NewItem: TElTreeItem;
      NewSection: TElHeaderSection);
    procedure listValuesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listValuesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure listValuesResize(Sender: TObject);
    procedure ActionListCheckExecute(Sender: TObject);

  private
    FCurrentCatalog: TFileManager;
    FMovieOrig: TMovie;
    FMovieCopy: TMovie;
    FAddedExtras: TStringList;
    FModifiedExtras: TStringList;
    FCurrentExtra: TMovieExtra;
    FCurrentExtraInfo: TScriptExtraInfo;
    FCurrentDefaultPicPath: string;
    FHeaderSectionValuesOver: Integer;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
    procedure FillExtras(StatusFilter: Integer; FieldFilter: Integer);
    procedure FillFields;
    function GetExtraInfo(Extra: TMovieExtra): TScriptExtraInfo;
    procedure SaveExtraInfo;
  public
    procedure Execute(const ScriptName: string;
      const CurrentCatalog: TFileManager;
      const MovieOrig: TMovie;
      const MovieCopy: TMovie;
      const AddedExtras: TStringList;
      const ModifiedExtras: TStringList;
      const StatusFilter: Integer = -1;
      const FieldFilter: Integer = -1;
      const CustomCaption: string = '');
  end;

var
  ScriptExtrasResultsWin: TScriptExtrasResultsWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  CommCtrl,

  Global, functions_files, functions_str, constValues, pictureform;

const
  msgResultsCaption       = 0;
  msgClickPicture         = 1;
  msgExtraStatus          = 2;
  msgExtraAdded           = 3;
  msgExtraDeleted         = 4;
  msgExtraModified        = 5;
  msgFileNotExists        = 6;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.FormCreate(Sender: TObject);
var
  f: Integer;
begin
  FMovieOrig := nil;
  FMovieCopy := nil;
  FAddedExtras := nil;
  FModifiedExtras := nil;
  FHeaderSectionValuesOver := -1;

  for f := extraFieldLow to extraFieldCount-1 do
    with listExtras.HeaderSections.AddSection do
    begin
      Text := strExtraFields[f - extraFieldLow];
      FieldName := IntToStr(f);
      FieldType := sftCustom;//sftText;
      Width := 100;
    end;
  inherited;
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  SaveExtraInfo;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.FormDestroy(Sender: TObject);
begin
  //
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.Execute(const ScriptName: string;
  const CurrentCatalog: TFileManager;
  const MovieOrig: TMovie;
  const MovieCopy: TMovie;
  const AddedExtras: TStringList;
  const ModifiedExtras: TStringList;
  const StatusFilter: Integer;
  const FieldFilter: Integer;
  const CustomCaption: string);
var
  s: string;
begin
  FCurrentCatalog := CurrentCatalog;
  FMovieOrig := MovieOrig;
  FMovieCopy := MovieCopy;
  FModifiedExtras := ModifiedExtras;
  FAddedExtras := AddedExtras;

  if CustomCaption = '' then
  begin
    Caption := Format(Messages.Strings[msgResultsCaption], [ScriptName, FMovieOrig.iNumber]);
    s := FMovieOrig.GetFormattedTitle;
    if s = '' then
      s := FMovieCopy.GetFormattedTitle;
    if s <> '' then
      Caption := Format('%s "%s"', [Caption, s]);
  end
  else
    Caption := CustomCaption;

  FCurrentExtra := nil;
  FCurrentExtraInfo := nil;
  FillExtras(StatusFilter, FieldFilter);
  FillFields;
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.LoadOptions;
begin
  with Settings.rScripts.rExtrasResults do
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
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.SaveOptions;
begin
  with Settings.rScripts.rExtrasResults do
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
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.FillExtras(StatusFilter: Integer; FieldFilter: Integer);
var
  i, f: Integer;
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
  CurItem: TElTreeItem;
begin
  with listExtras.Items do
  begin
    BeginUpdate;
    try
      listExtras.Items.Clear;
      with FMovieCopy.Extras do
        for i := 0 to Count-1 do
        begin
          Extra := Items[i];
          if (Extra._iStatus = mesAdded) or (Extra._iStatus = mesCancelAdded) then
          begin
            if (StatusFilter = -1) or (StatusFilter = Integer(mesAdded)) or
              (StatusFilter = Integer(mesCancelAdded)) then
            begin
              if (FieldFilter <> -1) then
              begin
                ExtraInfo := GetExtraInfo(Extra);
                if (ExtraInfo = nil) or (not (FieldFilter in ExtraInfo.ModifiedFields) and
                  ((FieldFilter = extraFieldPicture) and not ExtraInfo.ModifiedPicture)) then
                  continue;
              end;
              CurItem := AddChild(nil, Messages.Strings.Strings[msgExtraAdded]);
              CurItem.Data := Extra;
              CurItem.ShowCheckBox := True;
              CurItem.Checked := (Extra._iStatus = mesAdded);
              for f := extraFieldLow to extraFieldCount-1 do
                CurItem.SubItems.Add(Extra.GetFieldValue(f, True));
            end;
          end
        end;

      with FMovieOrig.Extras do
        for i := 0 to Count-1 do
        begin
          Extra := Items[i];
          if (Extra._iStatus = mesDeleted) or (Extra._iStatus = mesCancelDeleted) then
          begin
            if (StatusFilter = -1) or (StatusFilter = Integer(mesDeleted)) or
              (StatusFilter = Integer(mesCancelDeleted)) then
            begin
              if (FieldFilter <> -1) then
                continue;
              CurItem := AddChild(nil, Messages.Strings.Strings[msgExtraDeleted]);
              CurItem.Data := Extra;
              CurItem.ShowCheckBox := True;
              CurItem.Checked := (Extra._iStatus = mesDeleted);
              for f := extraFieldLow to extraFieldCount-1 do
                CurItem.SubItems.Add(Extra.GetFieldValue(f, True));
            end;
          end;
        end;

      with FMovieCopy.Extras do
        for i := 0 to Count-1 do
        begin
          Extra := Items[i];
          if (Extra._iStatus = mesModified) or (Extra._iStatus = mesCancelModified) then
          begin
            if (StatusFilter = -1) or (StatusFilter = Integer(mesModified)) or
              (StatusFilter = Integer(mesCancelModified)) then
            begin
              if (FieldFilter <> -1) then
              begin
                ExtraInfo := GetExtraInfo(Extra);
                if (ExtraInfo = nil) or (not (FieldFilter in ExtraInfo.ModifiedFields) and
                  ((FieldFilter = extraFieldPicture) and not ExtraInfo.ModifiedPicture)) then
                  continue;
              end;
              CurItem := AddChild(nil, Messages.Strings.Strings[msgExtraModified]);
              CurItem.Data := Extra;
              CurItem.ShowCheckBox := True;
              CurItem.Checked := (Extra._iStatus = mesModified);
              for f := extraFieldLow to extraFieldCount-1 do
                CurItem.SubItems.Add(Extra.GetFieldValue(f, True));
            end;
          end
        end;
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.FillFields;
var
  f: Integer;
  CurItem: TElTreeItem;
  DoubleSize: Double;
begin
  listValues.Items.Clear;
  if FCurrentExtra = nil then
    exit;

  with listValues.Items do
  begin
    BeginUpdate;
    try
      if (FCurrentExtra._iStatus = mesDeleted) or (FCurrentExtra._iStatus = mesCancelDeleted) then
      begin
        for f := extraFieldLow to extraFieldCount-1 do
          if not (f in VirtualFields) then
          begin
            CurItem := AddChild(nil, strExtraFields[f - extraFieldLow]);
            CurItem.ShowCheckBox := False;
            CurItem.Data := Pointer(f);
            CurItem.SubItems.Add(FCurrentExtra.GetFieldValue(f, True));
            CurItem.SubItems.Add('');
          end;
        CurItem := AddChild(nil, strExtraFieldPicture);
        CurItem.ShowCheckBox := False;
        CurItem.Data := Pointer(extraFieldPicture);
        if (FCurrentExtra.Picture.PicPath <> '') then
        begin
          DoubleSize := FCurrentExtra.Picture.
            GetPictureSize(FCurrentCatalog.CurrentFile) / 1024.0;
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
        end else
          CurItem.SubItems.Add('');
      end
      else if ((FCurrentExtra._iStatus = mesAdded) or (FCurrentExtra._iStatus = mesCancelAdded) or
        (FCurrentExtra._iStatus = mesModified) or (FCurrentExtra._iStatus = mesCancelModified)) and
        (FCurrentExtraInfo <> nil) then
      begin
        for f := extraFieldLow to extraFieldCount-1 do
          if not (f in VirtualFields) then
          begin
            CurItem := AddChild(nil, strExtraFields[f - extraFieldLow]);
            CurItem.ShowCheckBox := True;
            CurItem.Data := Pointer(f);
            if (FCurrentExtra._linkedExtra <> nil) then
              CurItem.SubItems.Add(FCurrentExtra._linkedExtra.GetFieldValue(f, True))
            else
              CurItem.SubItems.Add(Settings.rOptions.rMovieInformation.
                rDefaultExtra.Values.GetFieldValue(f, True));
            if (f in FCurrentExtraInfo.ModifiedFields) then
            begin
              CurItem.SubItems.Add(FCurrentExtra.GetFieldValue(f, True));
              CurItem.Checked := (f in FCurrentExtraInfo.SelectedFields);
            end else
            begin
              CurItem.SubItems.Add('');
              CurItem.Checked := False;
              CurItem.UseStyles := True;
              CurItem.MainStyle.OwnerProps := False;
              CurItem.MainStyle.FontSize := listValues.Font.Size;
              CurItem.MainStyle.FontStyles := listValues.Font.Style;
              CurItem.MainStyle.FontName := listValues.Font.Name;
              CurItem.MainStyle.TextColor := clGrayText;
            end;
          end;
        CurItem := AddChild(nil, strExtraFieldPicture);
        CurItem.ShowCheckBox := True;
        CurItem.Data := Pointer(extraFieldPicture);
        if (FCurrentExtra._linkedExtra <> nil) and
          (FCurrentExtra._linkedExtra.Picture.PicPath <> '') then
        begin
          DoubleSize := FCurrentExtra._linkedExtra.Picture.
            GetPictureSize(FCurrentCatalog.CurrentFile) / 1024.0;
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
        end
        else if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
        begin
          if FCurrentCatalog.CurrentFile <> '' then
            SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
          else
            SetCurrentDir(strDirCatalogs);
          FCurrentDefaultPicPath := ExpandFileName(Settings.rOptions.rMovieInformation.
            rDefaultExtra.Values.Picture.PicPath);
          if FileExists(FCurrentDefaultPicPath) then
          begin
            DoubleSize := GetFileSize(FCurrentDefaultPicPath) / 1024.0;
            CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
          end else
          begin
            FCurrentDefaultPicPath := '';
            CurItem.SubItems.Add('');
          end;
        end else
          CurItem.SubItems.Add('');
        if FCurrentExtraInfo.ModifiedPicture then
        begin
          if (FCurrentExtra.Picture.PicPath <> '') then
          begin
            DoubleSize := FCurrentExtra.Picture.
              GetPictureSize(FCurrentCatalog.CurrentFile) / 1024.0;
            CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
          end else
            CurItem.SubItems.Add('');
          CurItem.Checked := FCurrentExtraInfo.SelectedPicture;
        end else
        begin
          CurItem.SubItems.Add('');
          CurItem.Checked := False;
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
      end;
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptExtrasResultsWin.GetExtraInfo(Extra: TMovieExtra): TScriptExtraInfo;
var
  idx: Integer;
begin
  Result := nil;
  if (Extra._iStatus = mesAdded) or (Extra._iStatus = mesCancelAdded) then
  begin
    idx := FAddedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
      Result := TScriptExtraInfo(FAddedExtras.Objects[idx]);
  end
  else if (Extra._iStatus = mesModified) or (Extra._iStatus = mesCancelModified) then
  begin
    idx := FModifiedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
      Result := TScriptExtraInfo(FModifiedExtras.Objects[idx]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.SaveExtraInfo;
var
  CurItem: TElTreeItem;
  i, f: Integer;
begin
  if (FCurrentExtra = nil) or (FCurrentExtraInfo = nil) then
    exit;
  with FCurrentExtraInfo do
  begin
    SelectedFields := [];
    SelectedPicture := False;
    for i := 0 to listValues.Items.Count-1 do
    begin
      CurItem := listValues.Items[i];
      if CurItem.Checked then
      begin
        f := Integer(CurItem.Data);
        if f in AllExtraFields then
          Include(SelectedFields, f)
        else if f = extraFieldPicture then
          SelectedPicture := True
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.btn1Click(Sender: TObject);
begin
  inherited;
  Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listExtrasMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (not listExtras.Focused) and (listExtras.CanFocus) then
    listExtras.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listExtrasAfterSelectionChange(
  Sender: TObject);
begin
  inherited;
  SaveExtraInfo;
  listValues.Items.Clear;
  if (listExtras.Selected <> nil) and (listExtras.Selected.Data <> nil) then
  begin
    FCurrentExtra := TMovieExtra(listExtras.Selected.Data);
    FCurrentExtraInfo := GetExtraInfo(FCurrentExtra);
  end else
  begin
    FCurrentExtra := nil;
    FCurrentExtraInfo := nil;
  end;
  FCurrentDefaultPicPath := '';
  FillFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listExtrasItemChecked(Sender: TObject;
  Item: TElTreeItem);
var
  Extra: TMovieExtra;
begin
  inherited;
  if (Item = nil) or (Item.Data = nil) then
    exit;
  Extra := TMovieExtra(Item.Data);
  if (Extra._iStatus = mesAdded) or (Extra._iStatus = mesCancelAdded) then
    if Item.Checked then
      Extra._iStatus := mesAdded
    else
      Extra._iStatus := mesCancelAdded
  else if (Extra._iStatus = mesDeleted) or (Extra._iStatus = mesCancelDeleted) then
    if Item.Checked then
      Extra._iStatus := mesDeleted
    else
      Extra._iStatus := mesCancelDeleted
  else if (Extra._iStatus = mesModified) or (Extra._iStatus = mesCancelModified) then
    if Item.Checked then
      Extra._iStatus := mesModified
    else
      Extra._iStatus := mesCancelModified;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listExtrasDblClick(Sender: TObject);
begin
  inherited;
  with (Sender as TElTree) do
    if (Selected <> nil) then
    begin
      Selected.Checked := not Selected.Checked;
      listExtrasItemChecked(Sender, Selected);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listExtrasKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
    with listExtras do
      if ItemFocused <> nil then
      begin
        ItemFocused.Checked := not ItemFocused.Checked;
        listExtrasItemChecked(Sender, ItemFocused);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (not listValues.Focused) and (listValues.CanFocus) then
    listValues.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesDblClick(Sender: TObject);
begin
  with (Sender as TElTree) do
    if (Selected <> nil) and (Selected.ShowCheckBox) then
      Selected.Checked := not Selected.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesHotTrack(Sender: TObject;
  OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem;
  NewSection: TElHeaderSection);
begin
  inherited;
  if NewSection <> nil then
    FHeaderSectionValuesOver := NewSection.Index;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CurItem: TElTreeItem;
  Extra: TMovieExtra;
begin
  if (Button <> mbLeft) then
    Exit;
  CurItem := listValues.Selected;
  if (CurItem = nil) or (Integer(CurItem.Data) <> extraFieldPicture) then
    Exit;
  Extra := nil;
  case FHeaderSectionValuesOver of
    1:
      if (FCurrentExtra._iStatus = mesDeleted) or
        (FCurrentExtra._iStatus = mesCancelDeleted) then
        Extra := FCurrentExtra
      else if FCurrentExtra._linkedExtra <> nil then
        Extra := FCurrentExtra._linkedExtra;
    2:
      if not ((FCurrentExtra._iStatus = mesDeleted) or
        (FCurrentExtra._iStatus = mesCancelDeleted)) then
        Extra := FCurrentExtra;
  end;
  if (Extra <> nil) and (Extra.Picture.PicPath <> '') then
  begin
    PictureWin := TPictureWin.Create(Self);
    try
      PictureWin.CenterWindow := True;
      if (FCurrentCatalog.CurrentFile <> '') then
        SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      if Extra.Picture.PicStream = nil then
        if FileExists(ExpandFileName(Extra.Picture.PicPath)) then
          PictureWin.Execute(Extra.Picture.GetPictureCaption, ExpandFileName(Extra.Picture.PicPath))
        else
          MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [Extra.Picture.PicPath]), mtError, [mbOk])
      else
        PictureWin.Execute(Extra.Picture.GetPictureCaption, Extra.Picture.PicStream, Extra.Picture.PicPath);
    finally
      FreeAndNil(PictureWin)
    end;
  end
  else if (FCurrentDefaultPicPath <> '') and (FHeaderSectionValuesOver = 1) then
  begin
    PictureWin := TPictureWin.Create(Self);
    try
      PictureWin.CenterWindow := True;
      if (FCurrentCatalog.CurrentFile <> '') then
        SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      if FileExists(ExpandFileName(FCurrentDefaultPicPath)) then
        PictureWin.Execute(ExtractFileName(FCurrentDefaultPicPath), ExpandFileName(FCurrentDefaultPicPath))
      else
        MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [FCurrentDefaultPicPath]), mtError, [mbOk]);
    finally
      FreeAndNil(PictureWin)
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesKeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
    with listValues do
      if (ItemFocused <> nil) and (ItemFocused.ShowCheckBox) then
        ItemFocused.Checked := not ItemFocused.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.listValuesResize(Sender: TObject);
begin
  listValues.HeaderSections.Item[1].Width := Trunc((Width-listValues.HeaderSections.Item[0].Width-44)/2);
  listValues.HeaderSections.Item[2].Width := Trunc((Width-listValues.HeaderSections.Item[0].Width-44)/2);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtrasResultsWin.ActionListCheckExecute(Sender: TObject);
var
  i: Integer;
  bState, bAll: Boolean;
begin
  bState := (Sender = ActionListCheck) or (Sender = ActionListAll);
  bAll := (Sender = ActionListAll) or (Sender = ActionListNone);
  if Sender is TAction then
    if TAction(Sender).ActionComponent is TTBXItem then
      if MenuPopupList.PopupComponent is TElTree then
      begin
        with TElTree(MenuPopupList.PopupComponent) do
        begin
          Items.BeginUpdate;
          for i := 0 to Items.Count-1 do
            if Items[i].ShowCheckBox and (bAll or Items[i].Selected) then
            begin
              Items[i].Checked := bState;
              if TElTree(MenuPopupList.PopupComponent) = listExtras then
                listExtrasItemChecked(Sender, Items[i]);
            end;
          Items.EndUpdate;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
