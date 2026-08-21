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

unit extrasedit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, shellAPI, ComCtrls, Clipbrd,

  ConstValues, AntCorelButton, AntJvExControls, AntJvToolEdit, AntAutoHintLabel,

  base, movieclass, AntStringList, TBX, TBXDkPanels, Menus, TB2Item,
  TB2Dock, TB2Toolbar, ActnList,

  JPEG, PNGImage, AntJvGIF, AntJvEdit, AntJvSpin, frameextra;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TExtrasEditWin = class(TBaseDlg)
    LPicture: TLabel;
    PanelExtraPicture: TPanel;
    ScrollBox1: TScrollBox;
    PreviewPicture: TImage;
    DockExtraPictureTop: TTBXDock;
    ToolbarExtraPicture: TTBXToolbar;
    MnuPicLoa: TTBXItem;
    MnuPicSav: TTBXItem;
    MnuPicCpy: TTBXItem;
    MnuPicPst: TTBXItem;
    MnuPicDel: TTBXItem;
    chkPicture: TCheckBox;
    Messages: TAntStringList;
    ActionList1: TActionList;
    ActionPicSelect: TAction;
    ActionPicDelete: TAction;
    ActionPicSaveAs: TAction;
    ActionPicCopy: TAction;
    ActionURLOpen: TAction;
    ActionURLBrowse: TAction;
    ActionURLCopy: TAction;
    ActionURLExplore: TAction;
    ActionPicPaste: TAction;
    PopupEURL: TTBXPopupMenu;
    MnuPopupUrpOpen: TTBXItem;
    MnuPopupUrlExp: TTBXItem;
    MnuPopupUrlCopy: TTBXItem;
    MnuPopupUrlBrw: TTBXItem;
    PopupImage: TTBXPopupMenu;
    TBXMnuPicSelect: TTBXItem;
    TBXMnuPicSaveAs: TTBXItem;
    TBXMnuPicCopy: TTBXItem;
    TBXMnuPicPaste: TTBXItem;
    TBXMnuPicDelete: TTBXItem;
    FrmExtra: TExtraFrame;
    BtnNextExtra: TTBXButton;
    BtnPreviousExtra: TTBXButton;
    ActionPreviousExtra: TAction;
    ActionNextExtra: TAction;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn2Click(Sender: TObject);
    procedure ActionPicSelectExecute(Sender: TObject);
    procedure ActionPicDeleteExecute(Sender: TObject);
    procedure ActionPicSaveAsExecute(Sender: TObject);
    procedure ActionPicCopyExecute(Sender: TObject);
    procedure ActionPicPasteExecute(Sender: TObject);
    procedure PreviewPictureMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OnURLButtonClick(Sender: TObject);
    procedure OnURLEnter(Sender: TObject);
    procedure ActionURLOpenExecute(Sender: TObject);
    procedure ActionURLBrowseExecute(Sender: TObject);
    procedure ActionURLCopyExecute(Sender: TObject);
    procedure ActionURLExploreExecute(Sender: TObject);
    procedure PreviewPictureMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ActionPreviousExtraExecute(Sender: TObject);
    procedure ActionNextExtraExecute(Sender: TObject);
  private
    FMouseDownPicture: Boolean;
  protected
    FMovie: TMovie;
    FCatalogFile: string;
    FPicture: TMoviePicture;
    FPictureURL: string;
    FNbExtrasEdit: Integer;
    FCurrentExtraIdx: Integer;
    procedure LoadOptions; override;
    procedure SaveOptions; override;
    procedure LoadValues(ExtraIdx: Integer = -1);
    procedure SaveValues;
    procedure LoadLists;
    procedure SaveLists;
    procedure UpdateLists;

    procedure RemovePreviewPicture;
    procedure LoadPreviewPicture;
    function ImportExtraPicture(const AFileName: TFileName): Boolean;
    function ImportExtraPictureFromStream(Stream: TMemoryStream; DefaultExt: string): Boolean;
  public
    function Execute(Movie: TMovie; CatalogFile: string): Boolean;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ExtrasEditWin: TExtrasEditWin;

implementation

uses
  Math, Global, fields, ProgramSettings, functions_str, functions_tbx, functions_sys,
  functions_files,

  FramePictureSelectionOptions, PictureSelection, PictureDragDrop,
  pictureform;

const
  // Messages
  msgPicSaveAs            = 0;
  msgPicOpen              = 1;
  msgPicLoadFailed        = 2;
  msgPicHintStored        = 3;
  msgPicHintLinked        = 4;
  msgPicHintInfo          = 5;
  msgFileNotExists        = 6;
  msgDragDropFiles        = 7;
  msgSelectFileURL        = 8;
  msgSaveChanges          = 9;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.FormCreate(Sender: TObject);
begin
  ToolbarExtraPicture.Images := ToolbarImages;
  PopupImage.Images := ToolbarImages;
  PopupEURL.Images := ToolbarImages;
  ActionPicSelect.ImageIndex := Ord(ICON_PICTUREOPEN);
  ActionPicDelete.ImageIndex := Ord(ICON_PICTUREDELETE);
  ActionPicSaveAs.ImageIndex := Ord(ICON_PICTURESAVE);
  ActionPicCopy.ImageIndex := Ord(ICON_PICTURECOPY);
  ActionPicPaste.ImageIndex := Ord(ICON_MOVIEPASTE);
  ActionURLOpen.ImageIndex := Ord(ICON_MOVIEURL);
  ActionURLExplore.ImageIndex := Ord(ICON_BROWSE);
  ActionURLCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  ActionURLBrowse.ImageIndex := Ord(ICON_FILEOPEN);
  BtnNextExtra.Images := ToolbarImages;
  BtnPreviousExtra.Images := ToolbarImages;
  BtnNextExtra.ImageIndex := Ord(ICON_MOVERIGHT);
  BtnPreviousExtra.ImageIndex := Ord(ICON_MOVELEFT);

  if Settings.rOptions.rMovieInformation.PictureFitWindow then
  begin
    PreviewPicture.Align := alClient;
    PreviewPicture.Stretch := true;
  end else
  begin
    PreviewPicture.Align := alNone;
    PreviewPicture.Stretch := false;
  end;
  FMouseDownPicture := False;

  FrmExtra.OnURLButtonClick := Self.OnURLButtonClick;
  FrmExtra.OnURLEnter := Self.OnURLEnter;

  Translator.Translate(FrmExtra);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.FormShow(Sender: TObject);
begin
  inherited;
  if FrmExtra.ETitle.CanFocus then
    FrmExtra.ETitle.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if btn1.ModalResult = mrOk then
    ModalResult := mrOk
  else
    ModalResult := btn2.ModalResult;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.LoadOptions;
begin
  with Settings do
  begin
    with rExtrasEdit do
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
    end; // with rExtrasEdit
  end; // with settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.SaveOptions;
begin
  with Settings do
  begin
    with rExtrasEdit do
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
    end; // with rExtrasEdit
  end; // with settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExtrasEditWin.Execute(Movie: TMovie; CatalogFile: string): Boolean;
begin
  FMovie := Movie;
  FCatalogFile := CatalogFile;
  // We fake the extra pointer to manage picture as extra picture
  // (Extra pointer is never used to read extra object of course!)
  FPicture := TMoviePicture.Create(Movie, Pointer(1));
  FPictureURL := '';
  LoadValues;
  LoadLists;
  Result := ShowModal = mrOk;
  RemovePreviewPicture;
  FPicture.Free;
end;
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.LoadValues(ExtraIdx: Integer);
var
  i: Integer;

  procedure LoadExtra(AExtra: TMovieExtra);
  begin
    with FrmExtra, AExtra do
    begin
      Inc(FNbExtrasEdit);
      if FNbExtrasEdit = 1 then
      begin
        FCurrentExtraIdx := i;
        ENumber.Enabled := True;
        ENumber.MaxValue := FMovie.Extras.Count;
        LoadFromObject(AExtra);
        FPicture.Assign(Picture);
      end else
      begin
        FCurrentExtraIdx  := -1;
        ENumber.Enabled := False;
        if strTag <> ETag.Text then
          ETag.Text := '';
        if strTitle <> ETitle.Text then
          ETitle.Text := '';
        if strCategory <> ECategory.Text then
          ECategory.Text := '';
        if strURL <> EURL.Text then
          EURL.Text := '';
        if strDescription <> EDescription.Text then
          EDescription.Text := '';
        if strComments <> EComments.Text then
          EComments.Text := '';
        if strCreatedBy <> ECreatedBy.Text then
          ECreatedBy.Text := '';
        if (FPicture.PicPath = '') or (FPicture.PicStream = nil) or
          not AnsiSameText(FPicture.PicPath, Picture.PicPath) then
          FPicture.Init;
      end;
    end;
  end;

begin
  FNbExtrasEdit := 0;
  FCurrentExtraIdx := -1;

  with FrmExtra do
  begin
    BeginUpdate;
    try
      ENumber.MaxValue := FMovie.Extras.Count+1;
      ENumber.Value := FMovie.Extras.Count+1;
      InitValues;
      RemovePreviewPicture;
      FPicture.Init;

      if (ExtraIdx > -1) and (ExtraIdx < FMovie.Extras.Count) then
      begin
        i := ExtraIdx;
        LoadExtra(FMovie.Extras.Items[i]);
      end
      else
      begin
        with FMovie.Extras do
        begin
          for i := 0 to Count-1 do
          begin
            if Items[i]._bSelected then
            begin
              LoadExtra(Items[i]);
            end;
          end;
        end;
        if FNbExtrasEdit = 0 then
          with Settings.rOptions.rMovieInformation.rDefaultExtra do
          begin
            FCurrentExtraIdx  := -1;
            ENumber.Enabled := True;
            ENumber.MaxValue := FMovie.Extras.Count + 1;
            LoadFromObject(Values);
            ENumber.Value := ENumber.MaxValue;
            if Values.Picture.PicPath <> '' then
              try
                FPicture.ImportPicture(Values.Picture.PicPath, FCatalogFile, mpiStore);
              except
              end;
          end;
      end;

      LoadPreviewPicture;

      Modified := False;
      chkPicture.Checked := False;

      if FNbExtrasEdit <= 1 then
      begin
        Checkboxes := False;
        chkPicture.Visible := False;
        LPicture.Left := chkPicture.Left;
      end
      else
      begin
        Checkboxes := True;
        chkPicture.Visible := True;
        LPicture.Left := chkPicture.Left + chkPicture.Width;
      end;

      ActionNextExtra.Enabled := (FNbExtrasEdit = 1) and
        (FCurrentExtraIdx > -1) and (FMovie.Extras.Count > 1);
      ActionPreviousExtra.Enabled := ActionNextExtra.Enabled;
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.SaveValues;
var
  ImportMethod: TMoviePictureImport;
  MovieExtra: TMovieExtra;
  i: Integer;

  procedure SaveExtraValues(AExtra: TMovieExtra);
  begin
    with FrmExtra, AExtra do
    begin
      if FNbExtrasEdit <= 1 then
      begin
        if iNumber <> Trunc(ENumber.Value) then
        begin
          FMovie.Extras.Move(iNumber-1, Trunc(ENumber.Value)-1);
          btn2.ModalResult := mrOk;
        end;
      end;
      if Modified then
      begin
        if chkURL.Checked then
        begin
          FreeAndNil(Picture._thumb);
          Picture._thumbError := 0;
        end;
        SaveToObject(AExtra, False);
        btn2.ModalResult := mrOK;
      end;
    end;
  end;
  
  procedure SaveExtraPicture(AExtra: TMovieExtra);
  begin
    with AExtra do
    begin
      if chkPicture.Checked then
      begin
        if FPicture.PicPath <> '' then
        begin
          if (FPictureURL <> '') and (FileExists(FPictureURL)) then
            Picture.ImportPicture(FPictureURL, FCatalogFile, ImportMethod)
          else
            Picture.ImportPictureFromStream(FPicture.PicStream, FPicture.PicPath,
              FCatalogFile, ImportMethod,
              ValidateFileName(Lowercase(Copy(FPictureURL, LastDelimiter('/\', FPictureURL) + 1, Length(FPictureURL)))));
        end else
          Picture.PictureOperation(FCatalogFile, mpoDelete);
        btn2.ModalResult := mrOk;
      end;
    end;
  end;

begin
  inherited;
  ImportMethod := TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod));

  if (FNbExtrasEdit = 1) and (FCurrentExtraIdx > -1) and
    (FCurrentExtraIdx < FMovie.Extras.Count) then
  begin
    i := FCurrentExtraIdx;
    MovieExtra := FMovie.Extras.Items[i];
    SaveExtraValues(MovieExtra);
    SaveExtraPicture(MovieExtra);
    FrmExtra.Modified := False;
    chkPicture.Checked := False;
    FCurrentExtraIdx := MovieExtra.iNumber-1;
  end
  else if FNbExtrasEdit = 0 then
  begin
    i := FMovie.Extras.AddExtra;
    if i <> -1 then
    begin
      MovieExtra := FMovie.Extras.Items[i];
      MovieExtra.bChecked := True;
      MovieExtra._bSelected := True;
      MovieExtra.Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
      // We import pictures later to have the good filename according to field values
      SaveExtraValues(MovieExtra);
      // We import pictures here to have the good filename according to field values
      if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
        try
          MovieExtra.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
            FCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
        except
        end;
      SaveExtraPicture(MovieExtra);
      FNbExtrasEdit := 1;
      btn2.ModalResult := mrOk;
      FrmExtra.Modified := False;
      chkPicture.Checked := False;
    end;
  end
  else
  begin
    for i := 0 to FMovie.Extras.Count-1 do
    begin
      MovieExtra := FMovie.Extras.Items[i];
      if MovieExtra._bSelected then
      begin
        SaveExtraValues(MovieExtra);
        SaveExtraPicture(MovieExtra);
      end;
    end;
    FrmExtra.Modified := False;
    chkPicture.Checked := False;
  end;
  SaveLists;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.LoadLists;
  procedure LoadList(const ACombo: TComboBox; ddlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[ddlIndex] do
    begin
      if UseCatalogValues then
      begin
        if FMovie.MovieList <> nil then
          FMovie.MovieList.GetExtrasValues(ACombo.Items, strFieldsDdl[ddlIndex])
        else
          ACombo.Items.Clear;
      end else
        ACombo.Items.Assign(Contents);
      ACombo.Sorted := Sort;
      ACombo.AutoComplete := AutoComplete;
    end;
  end;
begin
  with FrmExtra do
  begin
    LoadList(ETag, ddlExtrasTag);
    LoadList(ECategory, ddlExtrasCategory);
    LoadList(ECreatedBy, ddlExtrasCreatedBy);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.SaveLists;
  procedure SaveList(const ACombo: TComboBox; ddlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[ddlIndex] do
      if (not UseCatalogValues) and (AutoAdd) and (ACombo.Items.Count > 0) then
        Contents.Assign(ACombo.Items);
  end;
begin
  UpdateLists;
  with FrmExtra do
  begin
    SaveList(ETag, ddlExtrasTag);
    SaveList(ECategory, ddlExtrasCategory);
    SaveList(ECreatedBy, ddlExtrasCreatedBy);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.UpdateLists;
  procedure UpdateList(const Combo: TComboBox; ddlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[ddlIndex] do
      if (AutoAdd or UseCatalogValues) and (Combo.Text <> '') and (Combo.Items.IndexOf(Combo.Text) = -1) then
        Combo.Items.Add(Combo.Text);
  end;
begin
  with FrmExtra do
  begin
    UpdateList(ETag, ddlExtrasTag);
    UpdateList(ECategory, ddlExtrasCategory);
    UpdateList(ECreatedBy, ddlExtrasCreatedBy);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.RemovePreviewPicture;
begin
  with PreviewPicture do
  begin
    Hint := '|' + GetLongHint(Hint);
    Picture.Assign(nil);
    Width := 0;
    Height := 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.LoadPreviewPicture;
var
  loadedPic: TGraphic;
  PicSizeDouble: Double;
begin
  RemovePreviewPicture;
  try
    if FPicture.PicStream = nil then
    begin
      if FPicture.PicPath = '' then
      begin
        if FileExists(strFileNoPicture2) then
          PreviewPicture.Picture.LoadFromFile(strFileNoPicture2);
      end else
      begin
        if FCatalogFile <> '' then
          SetCurrentDir(ExtractFilePath(FCatalogFile))
        else
          SetCurrentDir(strDirCatalogs);
        if FileExists(ExpandFileName(FPicture.PicPath)) then
        begin
          PreviewPicture.Picture.LoadFromFile(ExpandFileName(FPicture.PicPath));
          PicSizeDouble := GetFileSize(ExpandFileName(FPicture.PicPath));
          PreviewPicture.Hint := Format('%s%s%s%s', [
            Format(Messages.Strings[msgPicHintLinked], [FPicture.PicPath]),
            sLineBreak,
            Format(Messages.Strings[msgPicHintInfo], [PicSizeDouble]),
            PreviewPicture.Hint]);
        end else
        begin
          if FileExists(strFileNotFound2) then
            PreviewPicture.Picture.LoadFromFile(strFileNotFound2);
          PreviewPicture.Hint := Format(Messages.Strings[msgFileNotExists] + PreviewPicture.Hint, [FPicture.PicPath]);
        end;
      end;
    end else
    begin
      case IndexText(FPicture.PicPath, extImage) of
        extPNG:
          loadedPic := TPNGObject.Create;
        extJPG, extJPE, extJPEG:
          loadedPic := TJpegImage.Create;
        extGIF:
          loadedPic := TJvGIFImage.Create;
        extBMP:
          loadedPic := TBitmap.Create;
      else
        loadedPic := nil;
        Abort;
      end;
      PicSizeDouble := FPicture.PicStream.Size;
      PreviewPicture.Hint := Format('%s%s%s%s', [
        Format(Messages.Strings[msgPicHintStored], [
          typeImage[IndexText(FPicture.PicPath, extImage)]
        ]),
        sLineBreak,
        Format(Messages.Strings[msgPicHintInfo], [
          PicSizeDouble
        ]),
        PreviewPicture.Hint
      ]);
      FPicture.PicStream.Seek(0, soFromBeginning);
      loadedPic.LoadFromStream(FPicture.PicStream);
      PreviewPicture.Picture.Assign(loadedPic);
      loadedPic.Free;
    end;
  except
    with PreviewPicture do
    begin
      Width:=0;
      Height:=0;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExtrasEditWin.ImportExtraPicture(const AFileName: TFileName): Boolean;
var
  OldPicPath: string;
begin
  Result := False;
  if FPicture = nil then
    Exit;
  // If extra has a linked or copied picture, with remove its link to not delete old picture file during import !
  // Old picture file will be deleted during save if needed
  if (FPicture.PicPath <> '') and (FPicture.PicStream = nil) then
  begin
    OldPicPath := FPicture.PicPath;
    FPicture.PicPath := '';
  end;
  try
    Result := FPicture.ImportPicture(AFileName, FCatalogFile, mpiStore);
    if Result then
    begin
      chkPicture.Checked := True;
      FPictureURL := ExpandFileName(AFileName);
    end
    else if OldPicPath <> '' then
      FPicture.PicPath := OldPicPath;
  except
    on e: Exception do
    begin
      if OldPicPath <> '' then
        FPicture.PicPath := OldPicPath;
      MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
    end
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExtrasEditWin.ImportExtraPictureFromStream(Stream: TMemoryStream; DefaultExt: string): Boolean;
var
  OldPicPath: string;
begin
  Result := False;
  if (FPicture = nil) or (Stream = nil) then
    Exit;
  // If extra has a linked or copied picture, with remove its link to not delete old picture file during import !
  // Old picture file will be deleted during save if needed
  if (FPicture.PicPath <> '') and (FPicture.PicStream = nil) then
  begin
    OldPicPath := FPicture.PicPath;
    FPicture.PicPath := '';
  end;
  try
    Result := FPicture.ImportPictureFromStream(Stream, DefaultExt, FCatalogFile, mpiStore);
    if Result then
      chkPicture.Checked := True
    else if OldPicPath <> '' then
      FPicture.PicPath := OldPicPath;
  except
    on e: Exception do
    begin
      if OldPicPath <> '' then
        FPicture.PicPath := OldPicPath;
      MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
    end
  end;
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.btn2Click(Sender: TObject);
begin
  SaveValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPicSelectExecute(Sender: TObject);
var
  ImportMethod: TPictureSelectOption;
begin
  with TPictureSelectionWin.Create(Self) do
    try
      InitialDir := Settings.rOptions.rFolders[fuPicture].Value;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      FileName := '';
      HelpContext := 1062;
      Options := DialogOpenOptions + [ofShowHelp];
      Title := Messages.Strings[msgPicOpen];
      Filter := DialogImageFilter;
      ImportMethod := TPictureSelectOption(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod));
      if Execute(ImportMethod) then
      begin
        Settings.rOptions.rFolders[fuPicture].Value := ExtractFilePath(FileName);
        with Settings.rOptions.rMovieInformation do
          if rExtraPicImport.GetInfoMethod > 0 then
            rExtraPicImport.GetInfoMethod := Integer(ImportMethod)
          else
            rExtraPicImport.GetInfoMethod := - Integer(ImportMethod);
        if ImportExtraPicture(FileName) then
        begin
          if (FrmExtra.ETitle.Text = '') and (FNbExtrasEdit <= 1) then
          begin
            FrmExtra.ETitle.Text := ExtractFileName(ChangeFileExt(FileName, ''));
            FrmExtra.chkTitle.Checked := True;
          end;
        end;
        LoadPreviewPicture;
      end;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPicSaveAsExecute(Sender: TObject);
var
  Ext: string;
begin
  if FPicture.PicPath <> '' then
    with TSaveDialog.Create(Self) do
      try
        InitialDir := Settings.rOptions.rFolders[fuPicture].Value;
        if InitialDir <> '' then
          ClearLastVisitedMRU(Application.ExeName);
        Options := DialogSaveOptions;
        Title := Messages.Strings[msgPicSaveAs];
        Ext := ExtractFileExt(FPicture.PicPath);
        case IndexText(ext, extImage) of
          extPNG:
            Filter := 'PNG (*.png)|*.png';
          extJPG, extJPE, extJPEG:
            Filter := 'JPEG (*.jpg, *.jpe, *.jpeg)|*.jpg;*.jpe;*.jpeg';
          extGIF:
            Filter := 'GIF (*.gif)|*.gif';
        else
          Filter := 'All files (*.*)|*.*';
        end;
        FileName := ValidateFileName(FMovie.GetFormattedTitle);
        if FileName = '' then
          FileName := IntToStr(FMovie.iNumber);
        System.Delete(Ext, 1, 1);
        DefaultExt := Ext;
        if Execute then
        begin
          Settings.rOptions.rFolders[fuPicture].Value := ExtractFilePath(FileName);
          if FPicture.PicStream <> nil then
            FPicture.PicStream.SaveToFile(FileName)
          else
          begin
            if FCatalogFile <> '' then
              SetCurrentDir(ExtractFilePath(FCatalogFile))
            else
              SetCurrentDir(strDirCatalogs);
            CopyFile(PChar(FPicture.PicPath), PChar(FileName), False);
          end;
        end;
      finally
        Free;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPicCopyExecute(Sender: TObject);
begin
  Clipboard.Assign(PreviewPicture.Picture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPicPasteExecute(Sender: TObject);
var
  PicImportMethod: TPictureSelectOption;
  DoNotAsk, ImportPic: Boolean;
  Jpeg: TJPEGImage;
  Bitmap: TBitmap;
  Stream: TMemoryStream;
begin
  Clipboard.Open;
  try
    if (Clipboard.HasFormat(CF_BITMAP)) or
      (Clipboard.HasFormat(CF_PICTURE)) or
      (Clipboard.HasFormat(CF_METAFILEPICT)) then
    begin
      with Settings.rOptions.rMovieInformation do
      begin
        ImportPic := True;
        PicImportMethod := TPictureSelectOption(Abs(rExtraPicImport.GetInfoMethod));
        if (rExtraPicImport.GetInfoMethod <= 0) then
        begin
          with TPictureDragDropWin.Create(Application) do
            try
              ToolbarImages.GetIcon(Ord(ICON_PICTUREOPEN), Icon);
              if not Execute(PicImportMethod, DoNotAsk) then
                ImportPic := False
              else
              begin
                rExtraPicImport.GetInfoMethod := Integer(PicImportMethod);
                if not DoNotAsk then
                  rExtraPicImport.GetInfoMethod := - rExtraPicImport.GetInfoMethod;
              end;
            finally
              Release;
            end;
        end;
      end;

      if ImportPic then
      begin
        Bitmap := TBitmap.Create;
        try
          Bitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(CF_BITMAP), 0);
          Jpeg := TJPEGImage.Create;
          Jpeg.CompressionQuality := 90;
          Jpeg.Performance := jpBestQuality;
          try
            Jpeg.Assign(Bitmap);
          except
            FreeAndNil(Jpeg);
          end;
        finally
          Bitmap.Free;
        end;
        if Jpeg = nil then
          Exit;
        try
          Stream := TMemoryStream.Create;
          try
            Jpeg.SaveToStream(Stream);
          except
            FreeAndNil(Stream);
          end;
        finally
          Jpeg.Free;
        end;
        if Stream = nil then
          Exit;
        ImportExtraPictureFromStream(Stream, '.jpg');
        LoadPreviewPicture;
        Stream.Free;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPicDeleteExecute(Sender: TObject);
begin
  FPicture.Init;
  LoadPreviewPicture;
  chkPicture.Checked := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.PreviewPictureMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  FMouseDownPicture := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.PreviewPictureMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Pt: TPoint;
  PictureCaption: string;
begin
  inherited;
  if not FMouseDownPicture then
    exit;
  FMouseDownPicture := False;
  if (Button = mbLeft) then
  begin
    PictureCaption := FMovie.GetFormattedTitle;
    if (FrmExtra.ETitle.Text <> '') and (PictureCaption <> '') then
      PictureCaption := ' - ' + PictureCaption;
    PictureCaption := FrmExtra.ETitle.Text + PictureCaption;

    if (FPicture.PicPath <> '') then
    begin
      if (FPicture.PicStream <> nil) then
      begin
        PictureWin := TPictureWin.Create(Self);
        try
          PictureWin.Execute(PictureCaption, FPicture.PicStream, FPicture.PicPath)
        finally
          FreeAndNil(PictureWin);
        end;
      end else
      begin
        if FCatalogFile <> '' then
          SetCurrentDir(ExtractFilePath(FCatalogFile))
        else
          SetCurrentDir(strDirCatalogs);
        if FileExists(ExpandFileName(FPicture.PicPath)) then
        begin
          PictureWin := TPictureWin.Create(Self);
          try
            PictureWin.Execute(PictureCaption, ExpandFileName(FPicture.PicPath));
          finally
            FreeAndNil(PictureWin);
          end;
        end else
          MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [FPicture.PicPath]), mtError, [mbOk]);
      end;
    end;
  end
  else if (Button = mbRight) then
  begin
    GetCursorPos(Pt);
    PopupImage.Popup(Pt.X, Pt.Y);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.OnURLButtonClick(Sender: TObject);
var
  FieldPos: TPoint;
begin
  if Sender is TAntJvComboEditXP then
  begin
    with TAntJvComboEditXP(Sender) do
      FieldPos := ClientToScreen(Point(Width-1, Height-1));
    PopupEURL.Popup(FieldPos.X, FieldPos.Y);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.OnURLEnter(Sender: TObject);
begin
  ActionURLOpen.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionURLOpenExecute(Sender: TObject);
var
  url: string;
begin
  url := FrmExtra.EURL.Text;
  if url <> '' then
  begin
    if FCatalogFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile))
    else
      SetCurrentDir(strDirCatalogs);
    if FileExists(ExpandFileName(url)) then
      LaunchProg(ExpandFileName(url))
    else
      LaunchProg(url);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionURLBrowseExecute(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
    try
      InitialDir := Settings.rOptions.rFolders[fuGetFromFiles].Value;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      FileName := '';
      Title := Messages.Strings[msgSelectFileURL];
      Options := DialogOpenOptions;
      Filter := DialogAnyFileFilter;
      if Execute then
      begin
        Settings.rOptions.rFolders[fuGetFromFiles].Value := ExtractFilePath(FileName);
        FrmExtra.EURL.Text := FileName;
        if (FrmExtra.ETitle.Text = '') and (FNbExtrasEdit <= 1) then
        begin
          FrmExtra.ETitle.Text := ExtractFileName(FileName);
          FrmExtra.chkTitle.Checked := True;
        end;
      end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionURLCopyExecute(Sender: TObject);
begin
  Clipboard.AsText := FrmExtra.EURL.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionURLExploreExecute(Sender: TObject);
var
  url: string;
begin
  url := FrmExtra.EURL.Text;
  if url <> '' then
  begin
    if FCatalogFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile))
    else
      SetCurrentDir(strDirCatalogs);
    LaunchExplorer(ExpandFileName(url));
  end
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionPreviousExtraExecute(Sender: TObject);
var
  res: Integer;
begin
  if (FNbExtrasEdit = 1) and (FCurrentExtraIdx > -1) and (FMovie.Extras.Count > 1) then
  begin
    if FrmExtra.Modified or chkPicture.Checked then
    begin
      res := MessageWin.Execute(Messages.Strings[msgSaveChanges],
        mtConfirmation, [mbYes, mbNo, mbCancel]);
      if res = 3 then
        exit;
      if res = 1 then
      begin
        SaveValues;
        btn1.ModalResult := mrOk;
      end;
    end;
    LoadValues((FCurrentExtraIdx + FMovie.Extras.Count - 1) mod FMovie.Extras.Count)
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasEditWin.ActionNextExtraExecute(Sender: TObject);
var
  res: Integer;
begin
  if (FNbExtrasEdit = 1) and (FCurrentExtraIdx > -1) and (FMovie.Extras.Count > 1) then
  begin
    if FrmExtra.Modified or chkPicture.Checked then
    begin
      res := MessageWin.Execute(Messages.Strings[msgSaveChanges],
        mtConfirmation, [mbYes, mbNo, mbCancel]);
      if res = 3 then
        exit;
      if res = 1 then
      begin
        SaveValues;
        btn1.ModalResult := mrOk;
      end;
    end;
    LoadValues((FCurrentExtraIdx + 1) mod FMovie.Extras.Count)
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
