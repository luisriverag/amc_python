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

unit printform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, AntCorelButton, ComCtrls, ExtCtrls, ActnList, Menus,

  PNGImage, JPEG, AntJvGIF, FR_DSet, FR_Class, TB2Item, TBX, AntStringList,
  FR_View, TB2ExtItems, TB2Dock, TB2Toolbar, AntAutoHintLabel,

  base, framesortby, movieclass, frameincludemov, TBXExtItems;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPrintWin = class(TBaseDlg)
    ActionExportHTML: TAction;
    ActionExportRTF: TAction;
    ActionFileDesigner: TAction;
    ActionFileLoad: TAction;
    ActionList1: TActionList;
    ActionPreviewPageFirst: TAction;
    ActionPreviewPageFull: TAction;
    ActionPreviewPageLast: TAction;
    ActionPreviewPageNext: TAction;
    ActionPreviewPagePrevious: TAction;
    ActionPreviewPageTwo: TAction;
    ActionPreviewPageWidth: TAction;
    ActionPreviewRefresh: TAction;
    ActionPreviewZoomIn: TAction;
    ActionPreviewZoomOut: TAction;
    ActionPrint: TAction;
    frPreview1: TfrPreview;
    frReport1: TfrReport;
    frUserDataset1: TfrUserDataset;
    Includemov: TIncludemovFrame;
    LvScripts: TListView;
    Messages: TAntStringList;
    Panel1: TPanel;
    Panel2: TPanel;
    popupPreview: TTBXPopupMenu;
    popupReports: TTBXPopupMenu;
    SortBy: TSortByFrame;
    Splitter1: TSplitter;
    TBDock1: TTBXDock;
    TBItem10: TTBXItem;
    TBItem12: TTBXItem;
    TBItem13: TTBXItem;
    TBItem14: TTBXItem;
    TBItem16: TTBXItem;
    TBItem2: TTBXItem;
    TBItem21: TTBXItem;
    TBItem22: TTBXItem;
    TBItem23: TTBXItem;
    TBItem24: TTBXItem;
    TBItem25: TTBXItem;
    TBItem26: TTBXItem;
    TBItem27: TTBXItem;
    TBItem28: TTBXItem;
    TBItem29: TTBXItem;
    TBItem3: TTBXItem;
    TBItem30: TTBXItem;
    TBItem4: TTBXItem;
    TBItem5: TTBXItem;
    TBItem6: TTBXItem;
    TBItem7: TTBXItem;
    TBItem8: TTBXItem;
    TBItem9: TTBXItem;
    TBSeparatorItem1: TTBXSeparatorItem;
    TBSeparatorItem2: TTBXSeparatorItem;
    TBSeparatorItem3: TTBXSeparatorItem;
    TBSeparatorItem4: TTBXSeparatorItem;
    TBSeparatorItem6: TTBXSeparatorItem;
    TBSeparatorItem7: TTBXSeparatorItem;
    ToolbarPreview: TTBXToolbar;
    EZoom: TTBXEditItem;
    procedure ActionExportExecute(Sender: TObject);
    procedure ActionFileDesignerExecute(Sender: TObject);
    procedure ActionFileLoadExecute(Sender: TObject);
    procedure ActionPreviewPageFirstExecute(Sender: TObject);
    procedure ActionPreviewPageFullExecute(Sender: TObject);
    procedure ActionPreviewPageLastExecute(Sender: TObject);
    procedure ActionPreviewPageNextExecute(Sender: TObject);
    procedure ActionPreviewPagePreviousExecute(Sender: TObject);
    procedure ActionPreviewPageTwoExecute(Sender: TObject);
    procedure ActionPreviewPageWidthExecute(Sender: TObject);
    procedure ActionPreviewRefreshExecute(Sender: TObject);
    procedure ActionPreviewZoomInExecute(Sender: TObject);
    procedure ActionPreviewZoomOutExecute(Sender: TObject);
    procedure ActionPrintExecute(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure EZoomAcceptText(Sender: TObject; var NewText: String; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure frPreview1MouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure frReport1GetValue(const ParName: String; var ParValue: Variant);
    procedure frReport1EnterRect(Memo: TStringList; View: TfrView);
    procedure frReport1UserFunction(const Name: String; p1, p2,
      p3: Variant; var Val: String);
    procedure frUserDataset1CheckEOF(Sender: TObject; var Eof: Boolean);
    procedure IncludeMovClick(Sender: TObject);
    procedure LvMoviesDblClick(Sender: TObject);
    procedure LvScriptsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure SortByBtnAdvSortClick(Sender: TObject);
  private
    FImgJpg: TJPEGImage;
    FImgPng: TPNGObject;
    FImgGif: TJvGIFImage;
    FImgBmp: TBitmap;
    FImg: TBitmap;
    FImg2: TJPEGImage;
    FMovieList: TMovieList;
    FPrintList: TMovieList;
    FCurrentFile: TFileName;
    function ChangeZoom(const NewZoom: string; Change: Integer = 0): string;
    function GetZoomFactor: string;
  protected
    procedure SaveOptions; override;
    procedure LoadOptions; override;
  public
    procedure Translate; override;
    function Execute(const AFileName: TFileName; const AList: TMovieList): TModalResult;
  end;

procedure Init_FR;
procedure Final_FR;

var
  PrintWin: TPrintWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Math, Printers,

  FR_Prntr,

  Global, ProgramSettings, ConstValues, fields,
  functions_gui, functions_str, functions_files, functions_sys,
  Sort, regexpr;

{$R *.dfm}

const
  msgCaption           =  0;
  msgNoneSelected      =  1;
  msgCannotPreview     =  2;
  msgDesignerNotFound  =  3;

  strReportTitle = 'Ant Movie Catalog - %s - %s';

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure FindFiles(const aList: TListView);
var
  SearchRecord: TSearchRec;
  RemaindFiles: Integer;
  Path: string;
begin
  Path := strDirTemplates;
  SetCurrentDir(Path);
  RemaindFiles := FindFirst('*.frf', 0, SearchRecord);
  aList.Items.BeginUpdate;
  try
    while RemaindFiles = 0 do
    begin
      with aList.Items.Add do
      begin
        Caption := ChangeFileExt(SearchRecord.Name, '');
        SubItems.Add(Path + SearchRecord.Name);
      end;
      RemaindFiles := FindNext(SearchRecord);
    end;
  finally
    aList.Items.EndUpdate;
    FindClose(SearchRecord);
  end;
  aList.AlphaSort;
  aList.Columns[0].Width := -2;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPrintWin.Execute(const AFileName: TFileName; const AList: TMovieList): TModalResult;

begin
  FMovieList := AList;
  FPrintList.CustomFieldsProperties.Assign(FMovieList.CustomFieldsProperties);
  FCurrentFile := AFileName;
  FindFiles(LvScripts);
  Includemov.SetCount(AList);

  with Settings.rPrint, SortWin.Fields do
  begin
    LoadFromStrings(OrderFields, FMovieList.CustomFieldsProperties);
    DeleteField(fieldActors);
    DeleteField(fieldDescription);
    DeleteField(fieldComments);
  end;

  Result := ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.LoadOptions;
begin
  with Settings do
  begin
    with rPrint do
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
      LvScripts.Width := ReportsListWidth;
      Self.SortBy.EOrderBy.ItemIndex := OrderBy;
      Self.SortBy.BtnSortDescend.Checked := OrderDescend;
      Self.Includemov.ItemIndex := TMovieIncludeOption(Includemov);
    end;
  end;
  ToolbarPreview.Images := ToolbarImages;
  if Settings.rOptions.rDisplay.ImagesInMenu then
  begin
    popupReports.Images := ToolbarImages;
    popupPreview.Images := ToolbarImages;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.SaveOptions;
begin
  with Settings do
  begin
    with rPrint do
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
      OrderBy := Self.SortBy.EOrderBy.ItemIndex;
      OrderDescend := Self.SortBy.BtnSortDescend.Checked;
      SortWin.Fields.SaveToStrings(OrderFields, FMovieList.CustomFieldsProperties);
      Includemov := Integer(Self.Includemov.ItemIndex);
      ReportsListWidth := LvScripts.Width;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.FormShow(Sender: TObject);
begin
  inherited;
  LvScriptsSelectItem(Sender, nil, False);
  EZoom.Text := ChangeZoom('100');
  ActionPrint.Enabled := False;
  btn3.Visible := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.FormCreate(Sender: TObject);
begin
  SortWin := TSortWin.Create(Self);
  FPrintList := TMovieList.Create(False);
  FImg := TBitmap.Create;
  FImg.PixelFormat := pf24bit;
  FImg2 := TJPEGImage.Create;
  FImg2.PixelFormat := jf24Bit;
  FImg2.CompressionQuality := 90;
  FImg2.Performance := jpBestQuality;
  FImgJpg := TJPEGImage.Create;
  FImgPng := TPNGObject.Create;
  FImgGif := TJvGIFImage.Create;
  FImgBmp := TBitmap.Create;
  ActionPreviewRefresh.ImageIndex := Ord(ICON_PRINTREFRESH);
  ActionPreviewPageFirst.ImageIndex := Ord(ICON_PRINTPAGEFIRST);
  ActionPreviewPagePrevious.ImageIndex := Ord(ICON_PRINTPAGEPREVIOUS);
  ActionPreviewPageNext.ImageIndex := Ord(ICON_PRINTPAGENEXT);
  ActionPreviewPageLast.ImageIndex := Ord(ICON_PRINTPAGELAST);
  ActionPreviewPageFull.ImageIndex := Ord(ICON_PRINTPAGEFULL);
  ActionPreviewPageTwo.ImageIndex := Ord(ICON_PRINTPAGETWO);
  ActionPreviewPageWidth.ImageIndex := Ord(ICON_PRINTPAGEWIDTH);
  ActionFileLoad.ImageIndex := Ord(ICON_PRINTLOAD);
  ActionPreviewZoomOut.ImageIndex := Ord(ICON_PRINTZOOMOUT);
  ActionPreviewZoomIn.ImageIndex := Ord(ICON_PRINTZOOMIN);
  ActionPrint.ImageIndex := Ord(ICON_PRINT);
  ActionFileDesigner.ImageIndex := Ord(ICON_PRINTDESIGNER);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.FormDestroy(Sender: TObject);
begin
  LvScripts.OnSelectItem := nil;
  FImg.Free;
  FImg2.Free;
  FImgJpg.Free;
  FImgPng.Free;
  FImgGif.Free;
  FImgBmp.Free;
  FPrintList.Free;
  SortWin.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewRefreshExecute(Sender: TObject);
var
  i: Integer;
  CurZoom: Double;
  IncOpt: TMovieIncludeOption;
begin
  CurZoom := frPreview1.Zoom;
  SetWaitCursor;
  try
    ActionPrint.Enabled := False;
    with LvScripts do
      if Selected <> nil then
        try
          frReport1.LoadFromFile(Selected.SubItems.Strings[0]);
        except
          on E: Exception do
          begin
            MessageWin.Execute(Format(Messages.Strings[msgCannotPreview], [E.Message]), mtError, [mbOk]);
            Selected := nil;
          end;
        end;
    FPrintList.Clear;
    if LvScripts.Selected <> nil then
    begin
      IncOpt := Includemov.ItemIndex;
      with FMovieList do
        for i := 0 to Count-1 do
          if TMovie(Items[i]).CanInclude(IncOpt) then
            FPrintList.Add(Items[i]);
      SortBy.Sort(FPrintList);
    end;
    frUserDataset1.RangeEndCount := FPrintList.Count;
    if FCurrentFile <> '' then
      SetCurrentDir(ExtractFilePath(FCurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    frReport1.ShowReport;
    frPreview1.Zoom := CurZoom;
    ActionPrint.Enabled := True;
  finally
    RestoreCursor;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.LvMoviesDblClick(Sender: TObject);
begin
  with (Sender as TListView) do
    if (Selected <> nil) then
      Selected.Checked := not Selected.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.LvScriptsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and (Item <> nil) then
  begin
    Caption := Format(Messages.Strings[msgCaption], [Item.Subitems[0]]);
  end else
  begin
    Caption := Format(Messages.Strings[msgCaption], [Messages.Strings[msgNoneSelected]]);
  end;
  ActionPreviewRefresh.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.IncludeMovClick(Sender: TObject);
begin
  LvScriptsSelectItem(LvScripts, LvScripts.Selected, Assigned(LvScripts.Selected) and LvScripts.Selected.Selected);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.SortByBtnAdvSortClick(Sender: TObject);
begin
  inherited;
  SortBy.BtnAdvSortClick(Sender);
  IncludeMovClick(SortBy);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.frUserDataset1CheckEOF(Sender: TObject;
  var Eof: Boolean);
begin
  Eof := (frUserDataset1.RecNo >= FPrintList.Count);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.frReport1GetValue(const ParName: String; var ParValue: Variant);
const
  labStr = 'label:';
var
  idx, i, field: Integer;
  Value, Tag, Position, Category, Checked: string;
  FieldProperties: TCustomFieldProperties;
  Movie: TMovie;
begin
  if VarIsNull(ParValue) then
    ParValue := varEmpty;
  // If ParName is a specific function (DATE, TIME, LINE#, ...) we do nothing here !
  if IndexStr(ParName, frSpecFuncs) <> -1 then
    Exit;
  if StartsText(labStr, ParName) then
  begin
    Value := Copy(ParName, Length(labStr) + 1, MaxInt);
    idx := IndexStr(Value, strTagFields);
    if idx <> -1 then // label movie field
      ParValue := strFields[idx]
    else
    begin
      FieldProperties := FMovieList.CustomFieldsProperties.GetField(value);
      if (FieldProperties <> nil) and (FieldProperties.FieldTag = Value) then // label custom field
        ParValue := FieldProperties.FieldName
      else
      begin
        idx := IndexStr(value, strTagExtraFields);
        if idx <> -1 then // label extra field
          ParValue := strExtraFields[idx];
      end;
    end;
  end
  else
  begin
    idx := IndexText(ParName, strTagFields);
    if idx <> -1 then // movie field
    begin
      if frUserDataset1.RecNo < FPrintList.Count then
        ParValue := TMovie(FPrintList.Items[frUserDataset1.RecNo]).GetFieldValue(idx, True)
      else
        ParValue := '';
    end
    else
    begin
      FieldProperties := FMovieList.CustomFieldsProperties.GetField(ParName);
      if (FieldProperties <> nil) then // custom field
      begin
        if frUserDataset1.RecNo < FPrintList.Count then
          ParValue := TMovie(FPrintList.Items[frUserDataset1.RecNo]).CustomFields.GetFieldValue(ParName, True)
        else
          ParValue := '';
      end else
      begin
        i := Pos('#', ParName);
        if i > 0 then
        begin
          Value := ParName;
          Delete(Value, i, Length(Value)-i+1);
          idx := IndexStr(Value, strTagExtraFields);
          if idx <> -1 then // extra field
          begin
            if frUserDataset1.RecNo < FPrintList.Count then
            begin
              Movie := TMovie(FPrintList.Items[frUserDataset1.RecNo]);
              field := idx + extraFieldLow;
              Tag := ParName;
              Delete(Tag, 1, i);
              Tag := Trim(Tag);
              Position := '';
              Category := '';
              Checked := '';
              i := Pos('#', Tag);
              if i > 0 then
              begin
                Position := Trim(Copy(Tag, i+1, Length(Tag)-i));
                Tag := Trim(Copy(Tag, 1, i-1));
                i := Pos('#', Position);
                if i > 0 then
                begin
                  Category := Trim(Copy(Position, i+1, Length(Position)-i));
                  Position := Trim(Copy(Position, 1, i-1));
                  i := Pos('#', Category);
                  if i > 0 then
                  begin
                    Checked := Trim(Copy(Category, i+1, Length(Category)-i));
                    Category := Trim(Copy(Category, 1, i-1));
                  end;
                end;
              end;
              idx := -1;
              if Tag <> '' then // Find by Tag
                idx := Movie.Extras.FindExtra(Tag)
              else if Position <> '' then // Find by Position + Category + Checked
                idx := Movie.Extras.FindExtraAdv(StrToIntDef(Position, -1), Category, Checked);
              if idx <> -1 then
                ParValue := Movie.Extras.Items[idx].GetFieldValue(field, True)
              else
                ParValue := '';
            end else
              ParValue := '';
          end;
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.frReport1EnterRect(Memo: TStringList; View: TfrView);
var
  ImageFound: Boolean;
  PicType, MaxBmpSize, idx, i: Integer;
  PicFile: TFileName;
  Movie: TMovie;
  Picture: TMoviePicture;
  Tag, Position, Category, Checked: string;
begin
  if not ((Memo.Count > 0) and (View is TfrPictureView) and
    ((Memo.Strings[0] = '['+strTagFieldPicture+']') or
    StartsStr('['+strTagExtraFieldPicture+'#', Memo.Strings[0]))) then
    exit;
  ImageFound := False;
  PicType := -1;
  if frUserDataset1.RecNo < FPrintList.Count then
  begin
    try
      Movie := TMovie(FPrintList.Items[frUserDataset1.RecNo]);
      Picture := nil;
      if (Memo.Strings[0] = '['+strTagFieldPicture+']') then // Picture
        Picture := Movie.Picture
      else if StartsStr('['+strTagExtraFieldPicture+'#', Memo.Strings[0]) then
      begin // Extra picture
        Tag := Memo.Strings[0];
        Delete(Tag, 1, Length('['+strTagExtraFieldPicture+'#'));
        Delete(Tag, Length(Tag), 1);
        Tag := Trim(Tag);
        Position := '';
        Category := '';
        Checked := '';
        i := Pos('#', Tag);
        if i > 0 then
        begin
          Position := Trim(Copy(Tag, i+1, Length(Tag)-i));
          Tag := Trim(Copy(Tag, 1, i-1));
          i := Pos('#', Position);
          if i > 0 then
          begin
            Category := Trim(Copy(Position, i+1, Length(Position)-i));
            Position := Trim(Copy(Position, 1, i-1));
            i := Pos('#', Category);
            if i > 0 then
            begin
              Checked := Trim(Copy(Category, i+1, Length(Category)-i));
              Category := Trim(Copy(Category, 1, i-1));
            end;
          end;
        end;
        idx := -1;
        if Tag <> '' then // Find by Tag
          idx := Movie.Extras.FindExtra(Tag)
        else if Position <> '' then // Find by Position + Category + Checked
          idx := Movie.Extras.FindExtraAdv(StrToIntDef(Position, -1), Category, Checked);
        if idx <> -1 then
          Picture := Movie.Extras.Items[idx].Picture;
      end;
      if Picture = nil then
        Abort;
      if Picture.PicStream = nil then
      begin
        if (Picture.PicPath = '') or (not FileExists(ExpandFileName(Picture.PicPath))) then
          Abort
        else
        begin
          PicFile := ExpandFileName(Picture.PicPath);
          PicType := IndexText(ExtractFileExt(Picture.PicPath), extImage);
          case PicType of
            extPNG:
              FImgPng.LoadFromFile(PicFile);
            extJPG, extJPE, extJPEG:
              FImgJpg.LoadFromFile(PicFile);
            extGIF:
              FImgGif.LoadFromFile(PicFile);
            extBMP:
              FImgBmp.LoadFromFile(PicFile);
          else
            Abort;
          end;
        end;
      end else
      begin
        PicType := IndexText(Picture.PicPath, extImage);
        Picture.PicStream.Seek(0, soFromBeginning);
        case PicType of
          extPNG:
            FImgPng.LoadFromStream(Picture.PicStream);
          extJPG, extJPE, extJPEG:
            FImgJpg.LoadFromStream(Picture.PicStream);
          extGIF:
            FImgGif.LoadFromStream(Picture.PicStream);
          extBMP:
            FImgBmp.LoadFromStream(Picture.PicStream);
        else
          Abort;
        end;
      end;
      ImageFound := True;
    except
    end;
  end;
  if ImageFound then
  begin
    MaxBmpSize := 300;
    case PicType of
      extPNG:
        with FImgPNG do
        begin
          FImg.Assign(nil);
          FImg.Width := Width;
          FImg.Height := Height;
          Draw(FImg.Canvas, Rect(0, 0, Width, Height));
          if (Width > MaxBmpSize) or (Height > MaxBmpSize) then
          begin
            FImg2.Assign(FImg);
            TFrPictureView(View).Picture.Assign(FImg2);
          end else
            TFrPictureView(View).Picture.Assign(FImg);
        end;
      extJPG, extJPE, extJPEG:
        begin
          FImgJpg.DIBNeeded;
          TFrPictureView(View).Picture.Assign(FImgJpg);
        end;
      extGIF:
        with FImgGif do
        begin
          FImg.Assign(FImgGif);
          if (Width > MaxBmpSize) or (Height > MaxBmpSize) then
          begin
            FImg2.Assign(FImg);
            TFrPictureView(View).Picture.Assign(FImg2);
          end else
            TFrPictureView(View).Picture.Assign(FImg);
        end;
      extBMP:
        with FImgBmp do
        begin
          if (Width > MaxBmpSize) or (Height > MaxBmpSize) then
          begin
            FImg2.Assign(FImgBmp);
            TFrPictureView(View).Picture.Assign(FImg2);
          end else
            TFrPictureView(View).Picture.Assign(FImgBmp);
        end;
      else
        TFrPictureView(View).Picture.Assign(nil);
    end;
  end else
    TFrPictureView(View).Picture.Assign(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.frReport1UserFunction(const Name: String; p1, p2,
  p3: Variant; var Val: String);
var
  RegExpr: TRegExpr;
begin
  if (Name = 'LENGTH') then
      Val := IntToStr(Length(VarToStr(frParser.Calc(p1))))
  else if (Name = 'POS') then
      Val := IntToStr(Pos(VarToStr(frParser.Calc(p1)),
        VarToStr(frParser.Calc(p2))))
  else if (Name = 'LASTPOS') then
      Val := IntToStr(LastPos(VarToStr(frParser.Calc(p1)),
        VarToStr(frParser.Calc(p2))))
  else if (Name = 'STRINGREPLACE') then
  begin
    Val := StringReplace(VarToStr(frParser.Calc(p1)),
      VarToStr(frParser.Calc(p2)),
      VarToStr(frParser.Calc(p3)), [rfReplaceAll]);
    Val := '''' + Val + '''';
  end
  else if (Name = 'STRINGREPLACEIGNORECASE') then
  begin
    Val := StringReplace(VarToStr(frParser.Calc(p1)),
      VarToStr(frParser.Calc(p2)),
      VarToStr(frParser.Calc(p3)), [rfReplaceAll, rfIgnoreCase]);
    Val := '''' + Val + '''';
  end
  else if (Name = 'REGEXPRSETSUBSTITUTE') then
  begin
    RegExpr := TRegExpr.Create;
    try
      RegExpr.Expression := VarToStr(frParser.Calc(p1));
      if RegExpr.Exec(VarToStr(frParser.Calc(p2))) then
        Val := RegExpr.Substitute(VarToStr(frParser.Calc(p3)))
      else
        Val := '';
      Val := '''' + Val + '''';
    except
      Val := '''''''';
    end;
    RegExpr.Free;
  end
  else if (Name = 'REGEXPRSETREPLACE') then
  begin
    RegExpr := TRegExpr.Create;
    try
      RegExpr.Expression := VarToStr(frParser.Calc(p1));
      Val := RegExpr.Replace(VarToStr(frParser.Calc(p2)), VarToStr(frParser.Calc(p3)), True);
      Val := '''' + Val + '''';
    except
      Val := '''''''';
    end;
    RegExpr.Free;
  end
  else if (Name = 'REGEXPRSETREPLACESIMPLE') then
  begin
    RegExpr := TRegExpr.Create;
    try
      RegExpr.Expression := VarToStr(frParser.Calc(p1));
      Val := RegExpr.Replace(VarToStr(frParser.Calc(p2)), VarToStr(frParser.Calc(p3)), False);
      Val := '''' + Val + '''';
    except
      Val := '''''''';
    end;
    RegExpr.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageFirstExecute(Sender: TObject);
begin
  frPreview1.First;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPagePreviousExecute(Sender: TObject);
begin
  frPreview1.Prev;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageNextExecute(Sender: TObject);
begin
  frPreview1.Next;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageLastExecute(Sender: TObject);
begin
  frPreview1.Last;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageFullExecute(Sender: TObject);
begin
  frPreview1.OnePage;
  EZoom.Text := GetZoomFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageTwoExecute(Sender: TObject);
begin
  frPreview1.TwoPages;
  EZoom.Text := GetZoomFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewPageWidthExecute(Sender: TObject);
begin
  frPreview1.PageWidth;
  EZoom.Text := GetZoomFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionFileLoadExecute(Sender: TObject);
var
  i: Integer;
  ItemFound: TListItem;
begin
  ItemFound := nil;
  with TOpenDialog.Create(Self) do
  begin
    InitialDir := strDirTemplates;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Filter := DialogReportFilter;
    Options := DialogOpenOptions;
    if Execute then
    begin
      with LvScripts.Items do
        for i := 0 to Count-1 do
          if Item[i].SubItems.Strings[0] = FileName then
          begin
            ItemFound := Item[i];
            Break;
          end;
      if ItemFound = nil then
      begin
        ItemFound := LvScripts.Items.Add;
        ItemFound.Caption := ExtractFileName(ChangeFileExt(FileName, ''));
        ItemFound.SubItems.Add(FileName);
      end;
      LvScripts.Selected := ItemFound;
      LvScripts.Selected.Focused := True;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewZoomOutExecute(Sender: TObject);
begin
  EZoom.Text := ChangeZoom(EZoom.Text, - 10);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPreviewZoomInExecute(Sender: TObject);
begin
  EZoom.Text := ChangeZoom(EZoom.Text, + 10);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.EZoomAcceptText(Sender: TObject; var NewText: String; var Accept: Boolean);
begin
  NewText := ChangeZoom(NewText);
  Accept := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPrintWin.ChangeZoom(const NewZoom: string; Change: Integer = 0): string;
var
  RealZoom: Integer;
begin
  RealZoom := StrToIntTrunc(NewZoom, 100) + Change;
  if RealZoom <= 0 then
    RealZoom := 1;
  frPreview1.Zoom := RealZoom;
  Result := GetZoomFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPrintWin.GetZoomFactor: string;
begin
  Result := Format('%.0f %%', [frPreview1.Zoom]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.btn1Click(Sender: TObject);
begin
  LaunchHelp;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure Init_FR;
begin
  if FR_Prntr.Prn <> nil then
    raise Exception.Create('[printform.pas] Prn variable in FR_Prntr.pas has already been initialized');
  try
    FR_Prntr.Prn := TfrPrinter.Create;
    FR_Prntr.Prn.Printer := Printer;
  except
    FR_Prntr.Prn := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure Final_FR;
begin
  try
    Prn.Free;
  finally
    Prn := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.frPreview1MouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  if Shift = [ssCtrl] then
  begin
    Handled := True;
    if WheelDelta > 0 then
      ActionPreviewZoomIn.Execute
    else
    if WheelDelta < 0 then
      ActionPreviewZoomOut.Execute;
  end else
  if Shift = [] then
  begin
    Handled := True;
    if WheelDelta <> 0 then
      with frPreview1.FWindow.VScrollBar do
        Position := Position - (LargeChange * Sign(WheelDelta));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionPrintExecute(Sender: TObject);
begin
  ActionPrint.Enabled := False;
  frReport1.Title := Format(strReportTitle, [ExtractFileName(FCurrentFile), LvScripts.Selected.Caption]);
  frPreview1.Print;
  ActionPrint.Enabled := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionExportExecute(Sender: TObject);
begin
{
  frReport1.Title := Format(strReportTitle, [ExtractFileName(FCurrentFile), LvScripts.Selected.Caption]);
  with TSaveDialog.Create(Self) do
    try
      Options := DialogSaveOptions;
      if Sender = ActionExportRTF then
      begin
        DefaultExt := 'rtf';
        if Execute then
        begin
          frReport1.ExportTo(TfrRTFExportFilter, FileName);
        end;
      end
      else
      if Sender = ActionExportHTML then
      begin
        DefaultExt := 'html';
        if Execute then
        begin
          frHTMExport1.
          frReport1.ExportTo(TfrHTMExportFilter, FileName);
        end;
      end;
    finally
      Free;
    end;
}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.ActionFileDesignerExecute(Sender: TObject);
var
  Template: string;
  Params: string;
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  with LvScripts do
    if Selected <> nil then
      Template := Format('"%s"', [Selected.SubItems.Strings[0]])
    else
      Template := Format('"%s"', [strDirTemplates]);
  if FileExists(strFileDesigner) then
  begin
    Params := Format('%s "%s" "%s"', [Template, strHelpFile, strFileDesignerConfig]);
    with FMovieList.CustomFieldsProperties do
      for i := 0 to Count-1 do
      begin
        FieldProperties := Objects[i];
        Params := Params + ' "*' + FieldProperties.FieldTag + '"';
      end;
    LaunchProg(strFileDesigner, Params, strDirTemplates)
  end
  else
    MessageWin.Execute(Format(Messages.Strings[msgDesignerNotFound], [strFileDesigner]), mtError, [mbOk]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPrintWin.Translate;
begin
  Translator.Translate(SortBy);
  Translator.Translate(Includemov);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
