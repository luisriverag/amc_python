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

unit framemovieextras;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Contnrs, DateUtils, Clipbrd,

  AntJvDragDrop, AntJvEdit, AntJvSpin, AntJvExControls, AntJvToolEdit,

  fields, movieclass, ConstValues, ComCtrls, ActnList, TB2Item, TBX, Menus,
  TB2Dock, TB2Toolbar,

  JPEG, PNGImage, AntJvGIF, rkIntegerList, rkSmartView, AntStringList,
  ImgList;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  CM_UpdateViewExtras = WM_USER + 2103; // Custom Message...
  ExtrasGroupNoneField = -1;
  ExtrasGroupNoneFieldName = '*None*';
  ExtrasSortAdvancedField = extraFieldPicture;
  ExtrasSortAdvancedFieldName = '*Advanced*';

type
  TMovieFrameExtras = class;

  {ThumbsViewer}
  PCacheItem = ^TCacheItem;
  TCacheItem = record
    Picture: TMoviePicture;
    Size: Integer;
    Age: TDateTime;
    Scale: Integer;
    Bmp: TBitmap;
  end;

  ThumbThreadExtras = class(TThread)
  private
    { Private declarations }
    MsgHandle: THandle;
    MovieFrameExtras: TMovieFrameExtras;
    ThumbsViewer: TrkSmartView;
    MovieExtras: TMovieExtras;
  protected
    procedure Execute; override;
  public
    constructor Create(MovieFrameExtras: TMovieFrameExtras);
  end;
  {End ThumbsViewer}

  TMovieFrameExtras = class(TFrame)
    PanelMovieExtras: TPanel;
    PanelThumbs: TPanel;
    PanelThumbsBottom: TPanel;
    ThumbsSizer: TTrackBar;
    ThumbsDisplayTitle: TCheckBox;
    ThumbsProgress: TProgressBar;
    ThumbsViewer: TrkSmartView;
    DockExtrasTop: TTBXDock;
    ToolbarExtras: TTBXToolbar;
    Messages: TAntStringList;
    MinusPicture: TImage;
    PlusPicture: TImage;
    ActionList1: TActionList;
    ActionExtrasImportFiles: TAction;
    ActionExtrasAdd: TAction;
    ActionExtrasEdit: TAction;
    ActionExtrasDelete: TAction;
    ActionExtraShowPic: TAction;
    ActionExtraURL: TAction;
    ActionURLOpen: TAction;
    ActionURLBrowse: TAction;
    ActionURLCopy: TAction;
    ActionURLExplore: TAction;
    TBItemExtrasImportFiles: TTBXItem;
    TBItemExtrasAdd: TTBXItem;
    TBItemExtrasEdit: TTBXItem;
    TBItemExtrasDelete: TTBXItem;
    TBItemExtraShowPic: TTBXItem;
    TBItemExtraURL: TTBXSubmenuItem;
    TBItemURLExplore: TTBXItem;
    TBItemURLCopy: TTBXItem;
    TBItemURLBrowse: TTBXItem;
    TBItemURLOpen: TTBXItem;
    TBSeparatorExtra: TTBXSeparatorItem;
    ThumbsDisplayInfo: TCheckBox;
    PopupMovieExtras: TTBXPopupMenu;
    MnuMepImportFiles: TTBXItem;
    MnuMepAdd: TTBXItem;
    MnuMepEdit: TTBXItem;
    MnuMepDel: TTBXItem;
    MnuMep__1: TTBXSeparatorItem;
    MnuMepPaste: TTBXItem;
    MnuMepCopy: TTBXItem;
    ActionExtrasCopy: TAction;
    ActionExtrasPaste: TAction;
    MnuMep__2: TTBXSeparatorItem;
    ActionExtrasCheck: TAction;
    ActionExtrasUncheck: TAction;
    ActionExtrasSelCheck: TAction;
    ActionExtrasSelUncheck: TAction;
    MnuSelected: TTBXSubmenuItem;
    MnuSelect: TTBXSubmenuItem;
    ActionExtrasSelGroup: TAction;
    MnuMepSelUnchecked: TTBXItem;
    MnuMepSelChecked: TTBXItem;
    MnuMepSelGroup: TTBXItem;
    MnuMep__5: TTBXSeparatorItem;
    MnuMepCheck: TTBXItem;
    MnuMepUncheck: TTBXItem;
    TBSeparatorCopy: TTBXSeparatorItem;
    TBItemExtraPaste: TTBXItem;
    TBItemExtraCopy: TTBXItem;
    MnuMep_3: TTBXSeparatorItem;
    MnuMepShowPic: TTBXItem;
    MnuMepURL: TTBXSubmenuItem;
    ActionExtrasSort: TAction;
    ActionExtrasGroup: TAction;
    Mnu_Mep_4: TTBXSeparatorItem;
    MnuMepSort: TTBXSubmenuItem;
    MnuMepGrp: TTBXSubmenuItem;
    ImageListCheckboxes: TImageList;
    MnuMepSortAscend: TTBXItem;
    MnuMepSortDescend: TTBXItem;
    MnuMepSort__1: TTBXSeparatorItem;
    MnuMepSortAdvanced: TTBXItem;
    MnuMepGrpNone: TTBXItem;
    MnuMepGrp__1: TTBXSeparatorItem;
    ActionExtrasSortAscend: TAction;
    ActionExtrasSortDescend: TAction;
    ActionExtrasSortAdvanced: TAction;
    ActionExtrasGroupNone: TAction;
    ActionExtrasRenumber: TAction;
    TBSeparatorTools: TTBSeparatorItem;
    TBItemExtrasRenumber: TTBXItem;
    MnuMepRenumber: TTBXItem;
    MnuMep_5: TTBSeparatorItem;

    {ThumbsViewer}
    procedure CMUpdateView(var message: TMessage); message CM_UpdateViewExtras;
    procedure ItemPaintBasic(Canvas: TCanvas; R: TRect; State: TsvItemState; Focused: Boolean);
    procedure ThumbsViewerCellPaint(Sender: TObject; Canvas: TCanvas; Cell: TRect;
      IdxGrp, IdxItem: Integer; Data: Int64; State: TsvItemState);
    procedure ThumbsViewerDividerPaint(Sender: TObject; Canvas: TCanvas;
      Cell: TRect; IdxGrp: Integer; Group: PSmartGroup; State: TsvItemState);
    procedure ThumbsViewerHeaderPaint(Sender: TObject; Canvas: TCanvas;
      Header: TRect; Offset, Active: Integer; State: TsvItemState; Columns: array of Integer);
    procedure ThumbsViewerSelecting(Sender: TObject; Count: Integer);
    procedure ThumbsViewerCellSelectedChange(Sender: TObject; IdxGrp,
      IdxItem: Integer; Data: Int64; Selected: Boolean);
    procedure ThumbsViewerCellHit(Sender: TObject; Canvas: TCanvas;
      IdxGrp, IdxItem: Integer; Data: Int64; x, y: Integer; Shift: TShiftState;
      Clicked: Boolean; Button: TMouseButton; var Selected: Boolean);
    procedure ThumbsViewerDividerHit(Sender: TObject; Canvas: TCanvas;
      IdxGrp: Integer; Group: PSmartGroup; x: Integer; Shift: TShiftState;
      Clicked: Boolean; Button: TMouseButton; var Selected: Boolean;
      var Expanded: Boolean);
    procedure ThumbsViewerDividerExpandedChange(Sender: TObject;
      IdxGrp: Integer; Group: PSmartGroup; Expanded: Boolean);
    procedure ThumbsViewerHeaderClick(Sender: TObject; Column: Integer);
    procedure ThumbsViewerDblClick(Sender: TObject);
    procedure ThumbsViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ThumbsViewerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ThumbsViewerKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ThumbsViewerKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ThumbsViewerResize(Sender: TObject);
    procedure ThumbsSizerChange(Sender: TObject);
    procedure ThumbsDisplayTitleClick(Sender: TObject);
    procedure ThumbsDisplayInfoClick(Sender: TObject);
    procedure ThumbsViewerCellFocusedChange(Sender: TObject; IdxGrp,
      IdxItem: Integer; Data: Int64);
    {End ThumbsViewer}

    procedure DockExtrasTopRequestDock(Sender: TObject;
      Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DragDropFilesDrop(Sender: TObject; Position: TPoint; Value: TStringList);
    procedure OnCancelDragDrop(Sender: TObject);
    procedure ActionExtrasImportFilesExecute(Sender: TObject);
    procedure ActionExtrasAddExecute(Sender: TObject);
    procedure ActionExtrasDeleteExecute(Sender: TObject);
    procedure ActionExtrasEditExecute(Sender: TObject);
    procedure ActionExtraShowPicExecute(Sender: TObject);
    procedure ActionExtraURLExecute(Sender: TObject);
    procedure ActionURLOpenExecute(Sender: TObject);
    procedure ActionURLBrowseExecute(Sender: TObject);
    procedure ActionURLCopyExecute(Sender: TObject);
    procedure ActionURLExploreExecute(Sender: TObject);
    procedure PopupMovieExtrasPopup(Sender: TObject);
    procedure ActionExtrasSelGroupExecute(Sender: TObject);
    procedure ActionExtrasSelCheckExecute(Sender: TObject);
    procedure ActionExtrasSelUncheckExecute(Sender: TObject);
    procedure ActionExtrasCheckExecute(Sender: TObject);
    procedure ActionExtrasUncheckExecute(Sender: TObject);
    procedure ActionExtrasCopyExecute(Sender: TObject);
    procedure ActionExtrasPasteExecute(Sender: TObject);
    procedure ActionExtrasSortExecute(Sender: TObject);
    procedure ActionExtrasGroupExecute(Sender: TObject);

    procedure ExtrasBeforeChange(Sender: TObject);
    procedure ExtrasChange(Sender: TObject);

    procedure ActionSortExecute(Sender: TObject);
    procedure ActionGroupExecute(Sender: TObject);
    procedure ActionExtrasRenumberExecute(Sender: TObject);

  private
    FKeyDownThumbs:         Boolean;
    FCancelDragDrop:        Boolean;
    FCatalogFile:           string;
    FCurrentMovie:          TMovie;
    FAllowEdit:             Boolean;
    FModified:              Boolean;
    FUpdateCount:           Integer;
    FSortField:             Integer;
    FGroupField:            Integer;
    FSelectedExtra:         TMovieExtra;
    FOldSelectedExtra:      TMovieExtra;

    FOnExtrasBeforeChange:  TNotifyEvent;
    FOnExtrasChange:        TNotifyEvent;

    {ThumbsViewer}
    ThumbSizeW, ThumbSizeH: Integer;
    ThumbJPEG:              TJpegImage;
    ThumbGIF:               TJvGIFImage;
    ThumbPNG:               TPNGObject;
    ThumbBMP:               TBitmap;
    ThumbLoading:           TBitmap;
    WI, HI:                 Integer;
    CellJpeg :              TJpegImage;
    CellScale:              Integer;
    CellStyle:              Integer;
    ThumbsPool:             TList;
    PoolSize, MaxPool:      Integer;
    FullExpandOrCollapse:   Boolean;
    TimeUpdateView:         TDateTime;
    ThumbCheckboxOver:      Int64;
    ThumbCheckboxClick:     Boolean;
    FMouseThumbsViewerX:    Integer;
    FMouseThumbsViewerY:    Integer;

    procedure ThumbsGetThumbnail(Sender: TObject; Extra: TMovieExtra);
    function GetThumbBmp(Picture: TMoviePicture): TBitmap;
    procedure SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
    procedure ClearThumbsPool;
    procedure EnsureVisibleThumbsViewer(IdxGrp: Integer; IdxItem: Integer); overload;
    procedure ThumbsViewerEnsureVisiblePlus;
    {End ThumbsViewer}

    procedure FillAndSetImageListCheckboxes;
    procedure FillFieldsSortBy;
    procedure FillFieldsGroupBy;
    procedure SetCurrentMovie(Movie: TMovie);
    procedure SetAllowEdit(Value: Boolean);
    procedure ExtraSelected;

    procedure LoadSortField;
    procedure SaveSortField;
    procedure LoadGroupField;
    procedure SaveGroupField;
    procedure SetSortField(Field: Integer; Descend: Boolean);
    procedure SetGroupField(Field: Integer);

  protected
    {ThumbsViewer}
    ThumbThr: ThumbThreadExtras;
    ThreadDone: Boolean;
    {End ThumbsViewer}

    procedure ImportExtraPicture(Picture: TMoviePicture;
      const AFileName: TFileName; const ImportMethod: TMoviePictureImport);
    procedure ImportExtraPictureFromStream(Picture: TMoviePicture;
      Stream: TMemoryStream; DefaultExt: string; const ImportMethod: TMoviePictureImport);

  public
    {ThumbsViewer}
    // Colors
    cGSelectedStart,
    cGSelectedEnd,
    cGSelectedFocusedStart,
    cGSelectedFocusedEnd,
    cGHotStart,
    cGHotEnd,
    cGDisabledStart,
    cGDisabledEnd,
    cGDisabledFocusedStart,
    cGDisabledFocusedEnd,
    cGHeaderStart,
    cGHeaderEnd,
    cGHeaderHotStart,
    cGHeaderHotEnd,
    cGHeaderSelStart,
    cGHeaderSelEnd,
    cBorder,
    cHot,
    cSelected,
    cSelectedFocused,
    cDisabled,
    cDisabledFocused,
    cBackground,
    cLineHighLight,
    cShadeBorder,
    cShadeHot,
    cShadeSelect,
    cShadeSelectFocused,
    cShadeDisabled,
    cShadeDisabledFocused: TColor;

    CellShade0: TColor;
    CellShade1: TColor;
    CellShade2: TColor;
    CellShade3: TColor;
    CellShade4: TColor;
    CellBkgColor: TColor;
    CellBrdColor: array[Boolean, Boolean] of TColor;

    procedure GenCellColors;

    procedure StartThumbThread;
    procedure StopThumbThread;
    procedure ThumbsViewerStop;
    procedure ThumbsViewerStart;
    procedure ClearSelectedStates;
    {End ThumbsViewer}

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Init;
    procedure Translate;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: Boolean;

    procedure SelectExtrasCheckedOrUnchecked(Checked: Boolean);
    procedure CheckOrUncheckExtrasSelected(Check: Boolean);

    property CatalogFile: string read FCatalogFile write FCatalogFile;
    property CurrentMovie: TMovie read FCurrentMovie write SetCurrentMovie;
    property AllowEdit: Boolean read FAllowEdit write SetAllowEdit;
    property Modified: Boolean read FModified write FModified;

    property OnExtrasBeforeChange: TNotifyEvent read FOnExtrasBeforeChange write FOnExtrasBeforeChange;
    property OnExtrasChange: TNotifyEvent read FOnExtrasChange write FOnExtrasChange;
  end;

  function  CompareExtrasGroups(List: TStringList; Index1, Index2: Integer): Integer;

implementation

uses
  Global, StrUtils, Math, Variants,

  functions_str, functions_files, functions_sys, functions_img,

  rmkGradient, rmkFunctions, extrasedit, pictureform,
  FramePictureSelectionOptions, PictureDragDrop, sort, main,
  extrasrenumber;

{$R *.dfm}

const
  // Messages
  msgDeleteExtras           = 0;
  msgDoNotConfirm           = 1;
  msgSortBy                 = 2;
  msgGroupBy                = 3;
  msgGroupEmpty             = 4;
  msgFileNotExists          = 5;
  msgDragDropFiles          = 6;
  msgSelectFileURL          = 7;
  msgPicLoadFailed          = 8;
  msgSelectFilesImport      = 9;
  msgInfoNumberAndTag       = 10;
  msgInfoTitle              = 11;
  msgInfoCategory           = 12;
  msgInfoURL                = 13;
  msgInfoDescription        = 14;
  msgInfoComments           = 15;
  msgInfoCreatedBy          = 16;
  msgInfoShortNumberAndTag  = 17;
  msgInfoShortTitle         = 18;
  msgInfoShortCategory      = 19;
  msgInfoShortURL           = 20;
  msgInfoShortDescription   = 21;
  msgInfoShortComments      = 22;
  msgInfoShortCreatedBy     = 23;

var
  GroupByFieldType: TFieldType;

{-------------------------------------------------------------------------------
  ThumbThreadExtras
-------------------------------------------------------------------------------}

constructor ThumbThreadExtras.Create(MovieFrameExtras: TMovieFrameExtras);
begin
  Self.MsgHandle := MovieFrameExtras.Handle;
  Self.MovieFrameExtras := MovieFrameExtras;
  Self.ThumbsViewer := MovieFrameExtras.ThumbsViewer;
  Self.MovieExtras := MovieFrameExtras.CurrentMovie.Extras;
  FreeOnTerminate := False;
  inherited Create(False);
  Priority := tpLower;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure ThumbThreadExtras.Execute;
var
  id, nb, nb10, i: Integer;
  Extra: TMovieExtra;
  InView: Boolean;
  PtTmp: TPoint;
  List: TIntList;
  InViewComplete: Boolean;
  PreviousInView: Boolean;
begin
  inherited;

  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
  begin
    id := 0;
    nb := 0;
    i := 0;
    PreviousInView := False;
    
    while (i < MovieExtras.Count) and (not Terminated) do
    begin
      if (MovieExtras.Items[i].Picture._thumb <> nil) or
        (MovieExtras.Items[i].Picture._thumbError > 0) then
        Inc(nb);
      Inc(i);
    end;
    
    if (nb < MovieExtras.Count) and (not Terminated) then
    begin
      nb10 := Trunc(10*nb/MovieExtras.Count);
      PostMessage(MsgHandle, CM_UpdateViewExtras, 0, nb10);
      PostMessage(MsgHandle, CM_UpdateViewExtras, 3, 1); // Show progress bar

      while (nb < MovieExtras.Count) and (not Terminated) do
      begin
        i := 0;
        InView := True;
        Extra := nil;
        ThumbsViewer.LockInView();
        while (i < ThumbsViewer.InView.Count) and
          ((Extra = nil) or (Extra.Picture._thumb <> nil) or (Extra.Picture._thumbError > 0)) do
        begin
          PtTmp := ThumbsViewer.InView.Points[i];
          if(PtTmp.X <> -1) then
            List := PSmartGroup(ThumbsViewer.SmartGroups.Items[PtTmp.X]).Items
          else
            List := ThumbsViewer.Items;
          Extra := TMovieExtra(Pointer(List.Integers[PtTmp.Y]));
          Inc(i);
        end;
        InViewComplete := ThumbsViewer.InViewComplete;
        ThumbsViewer.UnlockInView();

        if (Extra = nil) or (Extra.Picture._thumb <> nil) or (Extra.Picture._thumbError > 0) then
        begin
          InView := False;
          while (MovieExtras.Items[id].Picture._thumb <> nil) or (MovieExtras.Items[id].Picture._thumbError > 0) do
          begin
            Inc(id);
            if (id > MovieExtras.Count) then
              id := 0;
          end;
          Extra := MovieExtras.Items[id];
        end;

        Extra.Picture.Lock;
        MovieFrameExtras.ThumbsGetThumbnail(ThumbsViewer, Extra);
        Extra.Picture.Unlock;
        Inc(nb);

        if InView or not InViewComplete then
        begin
          nb10 := Trunc(10*nb/MovieExtras.Count);
          PostMessage(MsgHandle, CM_UpdateViewExtras, 1, nb10);
          PreviousInView := True;
        end
        else if(Trunc(10*nb/MovieExtras.Count) > nb10) then
        begin
          nb10 := Trunc(10*nb/MovieExtras.Count);
          PostMessage(MsgHandle, CM_UpdateViewExtras, 0, nb10);
        end;
        if (not InView) and PreviousInView and InViewComplete then // Force to update view
        begin
          PostMessage(MsgHandle, CM_UpdateViewExtras, 2, nb10);
          PreviousInView := False
        end;
      end;
      
      if (not Terminated) then
        PostMessage(MsgHandle, CM_UpdateViewExtras, 2, 10) // Force to update view
      else
      begin
        nb10 := Trunc(10*nb/MovieExtras.Count);
        PostMessage(MsgHandle, CM_UpdateViewExtras, 2, nb10); // Force to update view
      end;
      PostMessage(MsgHandle, CM_UpdateViewExtras, 3, 0); // Hide progress bar
    end;
  end;
  MovieFrameExtras.ThreadDone := True;
end;


{-------------------------------------------------------------------------------
  TMovieFrameExtras
-------------------------------------------------------------------------------}

constructor TMovieFrameExtras.Create(AOwner: TComponent);
var
  RStream: TResourceStream;
begin
  inherited Create(AOwner);

  FKeyDownThumbs := False;
  FCurrentMovie := nil;
  FCatalogFile := '';
  FModified := False;
  FAllowEdit := True;
  FGroupField := ExtrasGroupNoneField;
  FSortField := extraFieldNumber + 1;
  FSelectedExtra := nil;
  FOldSelectedExtra := nil;
  
  {ThumbsViewer}
  ThumbJPEG := TJpegImage.Create;
  ThumbJPEG.CompressionQuality := 80;
  ThumbJPEG.Performance := jpBestSpeed;
  ThumbGIF := TJvGIFImage.Create;
  ThumbPNG := TPNGObject.Create;
  ThumbBMP := TBitmap.Create;
  ThumbLoading := TBitmap.Create;
  ThumbLoading.TransparentColor := clWhite;
  ThumbLoading.Transparent := True;
  try
    RStream := TResourceStream.Create( HInstance, 'Loading', 'BMP' );
    try
      ThumbLoading.LoadFromStream(RStream);
    finally
      RStream.Free;
    end;
  except
    FreeAndNil(ThumbLoading);
  end;

  // Max thumbnail size...
  ThumbSizeW := 255;
  ThumbSizeH := 255;
  ThumbsViewer.CellWidth := ThumbSizeW + 10;
  ThumbsViewer.CellHeight := ThumbSizeH + 30;

  CellJpeg := TJpegImage.Create;
  CellJPEG.Performance := jpBestSpeed;
  GenCellColors;
  CellStyle := 1;
  PoolSize := 0;
  MaxPool := Round((Screen.Width * Screen.Height) * 1.5);
  ThumbsPool := TList.Create;
  FullExpandOrCollapse := False;
  TimeUpdateView := Now;
  ThumbCheckboxOver := -1;
  ThumbCheckboxClick := False;
  FMouseThumbsViewerX := 0;
  FMouseThumbsViewerY := 0;
  {End ThumbsViewer}
  FillAndSetImageListCheckboxes;
  ExtraSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieFrameExtras.Destroy;
begin
  {ThumbsViewer}
  ThumbsViewerStop;
  ThumbJPEG.Free;
  ThumbGIF.Free;
  ThumbPNG.Free;
  ThumbBMP.Free;
  ThumbLoading.Free;
  CellJpeg.Free;
  ThumbsPool.Free;
  {End ThumbsViewer}
  inherited Destroy;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.Init;
begin
  ToolbarExtras.Images := ToolbarImages;
  PopupMovieExtras.Images := ToolbarImages;

  ActionExtrasImportFiles.ImageIndex := Ord(ICON_EXTRASIMPORTFILES);
  ActionExtrasAdd.ImageIndex := Ord(ICON_EXTRASADD);
  ActionExtrasEdit.ImageIndex := Ord(ICON_EXTRASEDIT);
  ActionExtrasDelete.ImageIndex := Ord(ICON_EXTRASDEL);
  ActionExtraShowPic.ImageIndex := Ord(ICON_MOVIEPICTURE);
  ActionExtraURL.ImageIndex := Ord(ICON_MOVIEURL);
  ActionExtrasCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  ActionExtrasPaste.ImageIndex := Ord(ICON_MOVIEPASTE);
  ActionExtrasSort.ImageIndex := Ord(ICON_SORTASCEND);
  ActionExtrasGroup.ImageIndex := Ord(ICON_GROUP);
  ActionExtrasRenumber.ImageIndex := Ord(ICON_RENUMBER);
  ActionURLOpen.ImageIndex := Ord(ICON_MOVIEURL);
  ActionURLExplore.ImageIndex := Ord(ICON_BROWSE);
  ActionURLCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  ActionURLBrowse.ImageIndex := Ord(ICON_FILEOPEN);

  FillFieldsSortBy;
  FillFieldsGroupBy;
  LoadSortField;
  LoadGroupField;

  GenCellColors;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.FillAndSetImageListCheckboxes;
var
  bmp: TBitmap;
  Rect: TRect;
begin
  // Fill ImageList
  bmp := TBitmap.Create;
  bmp.Height := 16;
  bmp.Width := 16;
  with ImageListCheckboxes do
  begin
    Clear;
    AllocBy := 1;
    Rect.Left := 2;
    Rect.Right := 14;
    Rect.Top := 2;
    Rect.Bottom := 14;
    bmp.Canvas.Pen.Color := clBtnFace;
    bmp.Canvas.Brush.Color := clBtnFace;
    bmp.Canvas.Rectangle(0, 0, 16, 16);
    // Uncheck picture
    DrawFrameControl(bmp.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK);
    AddMasked(bmp, clBtnFace);
    // Check picture
    DrawFrameControl(bmp.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED);
    AddMasked(bmp, clBtnFace);
  end;
  bmp.Free;

  // Set ImageList
  MnuMepSelUnchecked.Images := ImageListCheckboxes;
  MnuMepSelUnchecked.ImageIndex := 0;
  MnuMepSelChecked.Images := ImageListCheckboxes;
  MnuMepSelChecked.ImageIndex := 1;
  MnuMepUncheck.Images := ImageListCheckboxes;
  MnuMepUncheck.ImageIndex := 0;
  MnuMepCheck.Images := ImageListCheckboxes;
  MnuMepCheck.ImageIndex := 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.Translate;
begin
  Translator.Translate(Self);
  FillFieldsSortBy;
  FillFieldsGroupBy;
  LoadSortField;
  LoadGroupField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.FillFieldsSortBy;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuMepSort do
    while Count > 4 do
      Delete(4);
  with strExtraFields do
  begin
    for i := extraFieldLow to extraFieldCount-1 do
    begin
      if (i in SortByExtraFields) then
      begin
        newMenuItem := TTBXItem.Create(MnuMepSort);
        MnuMepSort.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Strings[i - extraFieldLow];
          Hint := Format(Messages.Strings[msgSortBy], [Strings[i - extraFieldLow]]);
          Tag := i;
          OnClick := ActionSortExecute;
          GroupIndex := 2;
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.FillFieldsGroupBy;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuMepGrp do
    while Count > 2 do
      Delete(2);
  with strExtraFields do
  begin
    for i := extraFieldLow to extraFieldCount-1 do
      if (i in GroupByExtraFields) then
      begin
        newMenuItem := TTBXItem.Create(MnuMepGrp);
        MnuMepGrp.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Strings[i - extraFieldLow];
          Hint := Format(Messages.Strings[msgGroupBy], [Strings[i - extraFieldLow]]);
          Tag := i;
          OnClick := ActionGroupExecute;
          GroupIndex := 3;
        end;
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount < 0 then
    FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameExtras.IsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SetCurrentMovie(Movie: TMovie);
begin
  BeginUpdate;
  try
    ThumbsViewerStop;
    FCurrentMovie := Movie;
    ThumbsViewerStart;
  finally
    EndUpdate;
  end;
  FModified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SetAllowEdit(Value: Boolean);
begin
  FAllowEdit := Value;
  ExtraSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ExtraSelected;
var
  SelCount: Integer;
  CanEdit: Boolean;
  i: Integer;
begin
  with ThumbsViewer do
  begin
    SelCount := 0;
    FOldSelectedExtra := FSelectedExtra;
    FSelectedExtra := nil;
    for i := 0 to SelectionCount - 1 do
      if GetSelection(i) > 0 then
      begin
        Inc(SelCount);
        if SelCount = 1 then
          FSelectedExtra := TMovieExtra(GetSelection(i));
        if SelCount > 1 then
        begin
          FSelectedExtra := nil;
          break;
        end;
      end;
  end;
  CanEdit := (FCurrentMovie <> nil) and FAllowEdit;
  ActionExtrasImportFiles.Enabled := CanEdit;
  ActionExtrasAdd.Enabled := CanEdit;
  ActionExtrasEdit.Enabled := CanEdit;
  ActionExtrasDelete.Enabled := CanEdit and (SelCount > 0);
  ActionExtraShowPic.Enabled := CanEdit and (SelCount = 1);
  ActionExtraURL.Enabled := CanEdit and (SelCount = 1);
  ActionURLOpen.Enabled := ActionExtraURL.Enabled;
  ActionURLBrowse.Enabled := ActionExtraURL.Enabled;
  ActionURLCopy.Enabled := ActionExtraURL.Enabled;
  ActionURLExplore.Enabled := ActionExtraURL.Enabled;
  ActionExtrasCopy.Enabled := CanEdit and (SelCount >= 1);
  ActionExtrasPaste.Enabled := CanEdit;
  ActionExtrasSelGroup.Enabled := CanEdit and (ThumbsViewer.IdxGrp > -1) and (ThumbsViewer.IdxItem = -1);
  MnuSelect.Enabled := CanEdit and ((ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0));
  ActionExtrasSelCheck.Enabled := MnuSelect.Enabled;
  ActionExtrasSelUncheck.Enabled := MnuSelect.Enabled;
  MnuSelected.Enabled := (SelCount > 0);
  ActionExtrasCheck.Enabled := MnuSelected.Enabled;
  ActionExtrasUncheck.Enabled := MnuSelected.Enabled;
  ActionExtrasSort.Enabled := CanEdit;
  ActionExtrasGroup.Enabled := CanEdit;
  ActionExtrasRenumber.Enabled := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ExtrasBeforeChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    if Assigned(FOnExtrasBeforeChange) then
      FOnExtrasBeforeChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ExtrasChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    FModified := True;
    if Assigned(FOnExtrasChange) then
      FOnExtrasChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.LoadSortField;
var
  FieldName: string;
  SortOrder, Idx: Integer;
begin
  with Settings.rMain do
  begin
    FSortField := extraFieldNumber + 1;
    FieldName := ExtrasSortFieldName;
    SortOrder := 1;
    if (Length(FieldName) > 0) and (FieldName[1] = '-') then
    begin
      Delete(FieldName, 1, 1);
      SortOrder := -1;
    end;

    if SameText(FieldName, ExtrasSortAdvancedFieldName) then
      FSortField := (ExtrasSortAdvancedField + 1) * SortOrder
    else
    begin
      Idx := IndexText(FieldName, strTagExtraFields);
      if Idx > -1 then
      begin
        Idx := Idx + extraFieldLow;
        if Idx in SortByExtraFields then
          FSortField := (Idx + 1) * SortOrder;
      end;
    end;
  end;
  SetSortField(Abs(FSortField) - 1, FSortField < 0) // Update GUI
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SaveSortField;
var
  Field: Integer;
  Descend: string;
begin
  with Settings.rMain do
  begin
    ExtrasSortFieldName := strTagExtraFields[extraFieldNumber - extraFieldLow];
    Field := FSortField;
    Descend := '';
    if Field < 0 then
    begin
      Field := -Field;
      Descend := '-';
    end;
    Field := Field - 1;
    if Field = ExtrasSortAdvancedField then
      ExtrasSortFieldName := Descend + ExtrasSortAdvancedFieldName
    else if Field in AllExtraFields then
      ExtrasSortFieldName := Descend + strTagExtraFields[Field - extraFieldLow];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.LoadGroupField;
var
  Idx: Integer;
begin
  with Settings.rMain do
  begin
    FGroupField := ExtrasGroupNoneField;
    Idx := IndexText(ExtrasGroupFieldName, strTagExtraFields);
    if Idx > -1 then
    begin
      Idx := Idx + extraFieldLow;
      if Idx in GroupByExtraFields then
        FGroupField := Idx;
    end;
  end;
  SetGroupField(FGroupField); // Update GUI
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SaveGroupField;
begin
  with Settings.rMain do
  begin
    ExtrasGroupFieldName := ExtrasGroupNoneFieldName;
    if FGroupField in AllExtraFields then
      ExtrasGroupFieldName := strTagExtraFields[FGroupField - extraFieldLow]
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SetSortField(Field: Integer; Descend: Boolean);
var
  i: Integer;
begin
  if not ((Field = ExtrasSortAdvancedField) or (Field in SortByExtraFields)) then
    Field := extraFieldNumber;
  FSortField := Field + 1;
  if Descend then
   FSortField := FSortField * -1;

  if Descend then
    MnuMepSortDescend.Checked := True
  else
    MnuMepSortAscend.Checked := True;

  with MnuMepSort do
    for i := 3 to Count-1 do
      with Items[i] do
        if (Tag = Field) then
        begin
          Checked := True;
          Break;
        end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SetGroupField(Field: Integer);
var
  i: Integer;
begin
  if not (Field in GroupByExtraFields) then
    Field := ExtrasGroupNoneField;
  FGroupField := Field;

  if FGroupField = ExtrasGroupNoneField then
    MnuMepGrpNone.Checked := True
  else
  begin
    with MnuMepGrp do
      for i := 2 to Count-1 do
        with Items[i] do
          if (Tag = Field) then
          begin
            Checked := True;
            Break;
          end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionSortExecute(Sender: TObject);
begin
  if (Sender = ActionExtrasSortAscend) or (Sender = ActionExtrasSortDescend) then
    SetSortField(Abs(FSortField) - 1, Sender = ActionExtrasSortDescend)
  else if (Sender = ActionExtrasSortAdvanced) then
  begin
    with Settings.rMain do
    begin
      SortWin := TSortWin.Create(Self);
      try
        SortWin.Fields.LoadFromStrings(ExtrasSortAdvancedFields, nil, False, True);
        SortWin.ShowModal;
        SortWin.Fields.SaveToStrings(ExtrasSortAdvancedFields, nil);
      finally
        SortWin.Free;
      end;
      SetSortField(ExtrasSortAdvancedField, MnuMepSortDescend.Checked);
    end;
  end
  else if Sender is TTBXItem then
    SetSortField(TTBXItem(Sender).Tag, MnuMepSortDescend.Checked);
  SaveSortField;
  ThumbsViewerStart;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionGroupExecute(Sender: TObject);
begin
  if Sender = ActionExtrasGroupNone then
    SetGroupField(ExtrasGroupNoneField)
  else if Sender is TTBXItem then
    SetGroupField(TTBXItem(Sender).Tag);
  SaveGroupField;
  if (FCurrentMovie <> nil) and (FCurrentMovie.MovieList <> nil) then
    FCurrentMovie.MovieList._extraGroups.Clear;
  ThumbsViewerStart;
end;

{-------------------------------------------------------------------------------
  ThumbsViewer
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.CMUpdateView(var message: TMessage);
begin
  if (message.WParam = 3) then
  begin
    if message.LParam = 0 then
      ThumbsProgress.Visible := False
    else
      ThumbsProgress.Visible := True;
  end else
  begin
    if (message.WParam = 2) or ((message.WParam = 1) and (Now > TimeUpdateView)) then
    begin
      ThumbsViewer.Invalidate;
      TimeUpdateView := IncMilliSecond(Now, 300);
    end;
    if (message.LParam >= 0) then
    begin
      if (message.LParam <> ThumbsProgress.Position) then
        ThumbsProgress.Position := message.LParam;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsGetThumbnail(Sender: TObject; Extra: TMovieExtra);
var
  ThumbBitmap, bmp: TBitmap;
  MS: TMemoryStream;
  RStream: TResourceStream;
  ThumbSize: TPoint;
  newW, newH: Integer;
  sf: Integer;
  Ext: String;
  Path: String;
  ThumbGraphic: TGraphic;
  isLock: Boolean;
  Icon: TIcon;

begin
  ThumbBitmap := nil;
  bmp := nil;
  ThumbGraphic := nil;
  Path := '';
  isLock := False;
  MS := nil;

  if Extra.Picture.PicStream = nil then
  begin
    if Extra.Picture.PicPath = '' then
    begin
      if ExtractFileExt(Extra.strURL) <> '' then
      begin
        Icon := GetIcon(Extra.strURL, True);
        if Icon <> nil then
        begin
          try
            try
              ThumbBitmap := TBitmap.Create;
              ThumbBitmap.Canvas.Lock;
              ThumbBitmap.PixelFormat := pf24Bit;
              ThumbBitmap.Width := Icon.Width;
              ThumbBitmap.Height := Icon.Width;
              ThumbBitmap.Canvas.Draw(0, 0, Icon);
              MS := TMemoryStream.Create;
              ThumbBitmap.SaveToStream(MS);
              Path := '.bmp';
            except
              FreeAndNil(MS);
            end;
          finally
            ThumbBitmap.Canvas.UnLock;
            FreeAndNil(Icon);
            FreeAndNil(ThumbBitmap);
          end;
        end;
      end;
      if MS = nil then
      begin
        Path := strFileNoPicture2;
        if not FileExists(Path) then
        begin
          MS := TMemoryStream.Create;
          try
            RStream := TResourceStream.Create( HInstance, 'nopicture2', 'PNG' );
            Path := '.png';
            try
              MS.LoadFromStream(RStream);
            finally
              RStream.Free;
            end;
          except
            FreeAndNil(MS);
          end;
        end;
      end;
    end
    else
    begin
      if (FCatalogFile <> '') then
        Path := ExtractFilePath(FCatalogFile) + Extra.Picture.PicPath;
      if not FileExists(Path) then
        Path := Extra.Picture.PicPath;
      if not FileExists(Path) then
        Path := strFileNotFound2;
      if not FileExists(Path) then
      begin
        MS := TMemoryStream.Create;
        try
          RStream := TResourceStream.Create( HInstance, 'filenotfound2', 'PNG' );
          Path := '.png';
          try
            MS.LoadFromStream(RStream);
          finally
            RStream.Free;
          end;
        except
          FreeAndNil(MS);
        end;
      end;
    end;
    Ext := LowerCase(ExtractFileExt(ExtractFileName(Path)))
  end else
  begin
    Ext := Extra.Picture.PicPath;
  end;

  case IndexText(Ext, extImage) of
    extPNG:
      ThumbGraphic := ThumbPNG;
    extJPG, extJPE, extJPEG:
      ThumbGraphic := ThumbJPEG;
    extGIF:
      ThumbGraphic := ThumbGIF;
    extBMP:
      ThumbGraphic := ThumbBMP;
  else
    Extra.Picture._thumbError := 1;
  end;

  if Extra.Picture._thumbError = 0 then
  begin
    if ThumbGraphic = ThumbJPEG then
    begin
      if (MS <> nil) then
        GetJPGSize(MS, WI, HI)
      else if (Extra.Picture.PicStream <> nil) then
        GetJPGSize(Extra.Picture.PicStream, WI, HI)
      else
        GetJPGSizeFromFile(Path, WI, HI);

      if WI < 1 then
        WI := 1;
      if HI < 1 then
        HI := 1;
      sf := Trunc(Min(HI / 255, WI / 255));
      if sf < 0 then
        sf := 0;
      case sf of
        0..1: ThumbJPEG.Scale := jsFullSize;
        2..3: ThumbJPEG.Scale := jsHalf;
        4..7: ThumbJPEG.Scale := jsQuarter;
      else
        ThumbJPEG.Scale := jsEighth;
      end;
    end;

    try
      if (MS <> nil) then
      begin
        MS.Seek(0, soBeginning);
        ThumbGraphic.LoadFromStream(MS);
        FreeAndNil(MS);
      end else if (Extra.Picture.PicStream <> nil) then
      begin
        Extra.Picture.PicStream.Seek(0, soBeginning);
        ThumbGraphic.LoadFromStream(Extra.Picture.PicStream);
      end else
        ThumbGraphic.LoadFromFile(Path);

      bmp := TBitmap.Create;
      bmp.PixelFormat := pf24Bit;
      bmp.Width := ThumbGraphic.Width;
      bmp.Height := ThumbGraphic.Height;
      bmp.Canvas.Lock;
      isLock := True;
      ThumbBMP.Canvas.Lock;
      bmp.Canvas.Draw(0, 0, ThumbGraphic);
      ThumbBMP.Canvas.Unlock;
      try
        ThumbBitmap := TBitmap.Create;
        ThumbBitmap.Canvas.Lock;
        ThumbSize := CalcImageSize(bmp.Width, bmp.Height,
          ThumbSizeW, ThumbSizeH);
        newW := ThumbSize.X;
        newH := ThumbSize.Y;
        if newW <= 0 then
          newW := 1;
        if newH <= 0 then
          newH := 1;
        ThumbBitmap.PixelFormat := pf24Bit;
        ThumbBitmap.Width := newW;
        ThumbBitmap.Height := newH;
        MakeThumbNail(bmp, ThumbBitmap);
      except
        ThumbBitmap.Canvas.UnLock;
        FreeAndNil(ThumbBitmap);
        Extra.Picture._thumbError := 3;
      end;

      bmp.Canvas.UnLock;
      bmp.Free;
    except
      Extra.Picture._thumbError := 2;
      FreeAndNil(MS);
      if (bmp <> nil) then
      begin
        if (isLock) then
          bmp.Canvas.Unlock;
        bmp.Free;
      end;
    end;

    if ThumbBitmap <> nil then
    begin
      MS := TMemoryStream.Create;
      MS.Seek(0, soBeginning);
      try
        ThumbJPEG.Assign(ThumbBitmap);
        ThumbJPEG.Compress;
        ThumbJPEG.SaveToStream(MS);
        Extra.Picture._thumb := MS;
        Extra.Picture._thumbWidth := ThumbBitmap.Width;
        Extra.Picture._thumbHeight := ThumbBitmap.Height;
      except
        MS.Free;
        Extra.Picture._thumbError := 4;
      end;
      ThumbBitmap.Canvas.UnLock;
      ThumbBitmap.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.StartThumbThread;
begin
  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
  begin
    if ThumbThr = nil then
    begin
      ThreadDone := False;
      ThumbThr := ThumbThreadExtras.Create(Self);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.StopThumbThread;
begin
  if ThumbThr <> nil then
  begin
    ThumbThr.Terminate;
    ThumbThr.WaitFor;
    ThumbThr.Free;
    ThumbThr := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ClearThumbsPool;
var
  i: Integer;
  Thumb: PCacheItem;
begin
  for i := ThumbsPool.Count - 1 downto 0 do
  begin
    Thumb := ThumbsPool[i];
    if Thumb.Bmp <> nil then
      Thumb.Bmp.Free;
    Dispose(Thumb);
  end;
  ThumbsPool.Clear;
  PoolSize := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ClearSelectedStates;
var
  i: Integer;
begin
  if FCurrentMovie = nil then
    Exit;
  with FCurrentMovie.Extras do
    for i := 0 to Count-1 do
    begin
      Items[i]._bSelected := False;
    end;
  ThumbsViewer.Invalidate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerStop;
begin
  StopThumbThread;
  ThumbsViewer.Clear;
  ClearThumbsPool;
  ExtraSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerStart;
var
  GroupCount, GroupExpand: Boolean;
  Groups: TStringList;
  GroupName: string;
  GroupItem: PSmartGroup;
  GroupExtras: TObjectList;
  Extra: TMovieExtra;
  iData: Int64;
  iGroup, iExtra: Integer;
  Grp, Idx, Field: Integer;
  MovieList: TMovieList;
  CompareFunction: TListSortCompare;
  
  // Args: IN [GroupName] OUT [GroupItem]
  procedure AddGroupI;
  var
    n: Integer;
  begin
    Grp := ThumbsViewer.AddSmartGroup(GroupName);
    GroupItem := PSmartGroup(ThumbsViewer.SmartGroups.Items[Grp]);
    GroupItem.Name:= GroupName;
    n := -1;
    if MovieList <> nil then
      n := MovieList._extraGroups.IndexOf(GroupName);
    if n > -1 then
      GroupItem^.Expanded := Integer(MovieList._extraGroups.Objects[n]) = 1
    else
      GroupItem^.Expanded := GroupExpand; // Default value
  end;

  // Args: IN [GroupItem]
  procedure AddGroupCount;
  begin
    if GroupCount and (GroupItem <> nil) then
      GroupItem.Caption := Format('%s (%d)', [GroupItem.Caption, GroupItem.Items.Count]);
  end;
begin
  ThumbsViewerStop;
  if FCurrentMovie = nil then
    Exit;
  ThumbsViewer.OnCellSelectedChange := nil;
  ThumbsViewer.Grouped := (FGroupField <> ExtrasGroupNoneField);
  GroupCount := Settings.rOptions.rExtraList.GroupCount;
  GroupExpand := Settings.rOptions.rExtraList.GroupExpand;
  Grp := -1;
  GroupItem := nil;
  Groups := FCurrentMovie.Extras.GetExtrasByGroups(FGroupField);
  MovieList := FCurrentMovie.MovieList;

  // *** Sort groups ***
  GroupByFieldType := GetFieldType(FGroupField);
  Groups.Sorted := False;
  Groups.CustomSort(CompareExtrasGroups);

  Field := Abs(FSortField) - 1;
  if Field = ExtrasSortAdvancedField then
  begin
    CompareExtrasAdvInit(Settings.rMain.ExtrasSortAdvancedFields, True);
    if FSortField < 0 then
      CompareFunction := CompareExtrasAdvReverse
    else
      CompareFunction := CompareExtrasAdv;
  end else
  begin
    CompareExtrasStdInit(Field, True);
    if FSortField < 0 then
      CompareFunction := CompareExtrasStdReverse
    else
      CompareFunction := CompareExtrasStd;
  end;

  // *** Sort extras in groups ***
  if Assigned(CompareFunction) then
    for iGroup := 0 to Groups.Count-1 do
    begin
      GroupExtras := TObjectList(Groups.Objects[iGroup]);
      GroupExtras.Sort(CompareFunction);
    end;

  // *** For all groups ***
  for iGroup := 0 to Groups.Count-1 do
  begin
    GroupName := Groups.Strings[iGroup];
    GroupExtras := TObjectList(Groups.Objects[iGroup]);

    // ** If group wanted ***
    if FGroupField <> ExtrasGroupNoneField then
      if GroupName = '$$$EMPTY$$$' then
      begin
        GroupName := Messages.Strings[msgGroupEmpty];
        AddGroupI;
      end
      else
        AddGroupI;

    // *** For all extras in group ***
    for iExtra := 0 to GroupExtras.Count-1 do
    begin
      Extra := TMovieExtra(GroupExtras.Items[iExtra]);
      iData := ULong(Pointer(Extra));
      if GroupItem <> nil then
        Idx := GroupItem.Items.Add(iData)
      else
        Idx := ThumbsViewer.Items.Add(iData);
      if Extra._bSelected then
      begin
        ThumbsViewer.AddSelection(iData, Grp, Idx);
        if (GroupItem <> nil) and (not GroupItem.Expanded) then
          GroupItem.Expanded := True;
        if ThumbsViewer.SelectionCount = 1 then
        begin
          ThumbsViewer.IdxGrp := Grp;
          ThumbsViewer.IdxItem := Idx;
        end;
      end;
    end; // for all extras in group
    AddGroupCount; // Add group count
  end; // for all groups
  FreeObjects(Groups);
  Groups.Free;

  ThumbsViewer.CalcView(True);
  SetThumbSize((ThumbsSizer.Position shl 4) - 1, False);
  ThumbsViewerEnsureVisiblePlus;
  ThumbsViewer.Invalidate;
  TimeUpdateView := IncMilliSecond(Now, 300);
  StartThumbThread;
  ThumbsViewer.OnCellSelectedChange := ThumbsViewerCellSelectedChange;
  ExtraSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareExtrasGroups(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := 0;
  if Index1 <> Index2 then
    with Settings.rOptions.rExtraList do
    begin
      if List.Strings[Index1] = '$$$EMPTY$$$' then
        if GroupsAbove then Result := 1 else Result := -1
      else
      if List.Strings[Index2] = '$$$EMPTY$$$' then
        if GroupsAbove then Result := -1 else Result := 1
      else
      begin
        if SortGroupsByCount then
          Result := CompareValue(TObjectList(List.Objects[Index2]).Count,
            TObjectList(List.Objects[Index1]).Count);
        if Result = 0 then
        begin
          case GroupByFieldType of
            ftInteger: Result := CompareValue(StrToIntDef(List.Strings[Index1], 0),
              StrToIntDef(List.Strings[Index2], 0));
          end;
          if Result = 0 then
            if Settings.rOptions.rDisplay.NaturalCompare then
              Result := AnsiNatCompareText(List.Strings[Index1], List.Strings[Index2])
            else
              Result := AnsiCompareText(List.Strings[Index1], List.Strings[Index2]);
        end;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.GenCellColors;
begin
  if Settings.rOptions.rExtraList.CellBorders then
  begin
    cBorder := $00EFE9E3;
    cShadeBorder := $00FFFFFF;
    cHot := $00F1E2C3;
    cGHotStart := $00FFFFFF;
    cGHotEnd := $00FFFFFF;
    cShadeHot := $00FFFFFF;
  end else
  begin
    cBorder := $00FFFFFF;
    cShadeBorder := $00FFFFFF;
    cHot := $00FFFFFF;
    cGHotStart := $00FFFFFF;
    cGHotEnd := $00FFFFFF;
    cShadeHot := $00FFFFFF;
  end;

  cSelected := $00FF9000;
  cGSelectedStart := $00FFA93A;
  cGSelectedEnd := $00FFC775;
  cShadeSelect := $00FFD59A;
  cSelectedFocused := $00FF7000;
  cGSelectedFocusedStart := $00FF8F19;
  cGSelectedFocusedEnd := $00FFAD55;
  cShadeSelectFocused := $00FFC78C;

  cDisabled := cSelected;
  cGDisabledStart := cGSelectedStart;
  cGDisabledEnd := cGSelectedEnd;
  cShadeDisabled := cShadeSelect;
  cDisabledFocused := cSelectedFocused;
  cGDisabledFocusedStart := cGSelectedFocusedStart;
  cGDisabledFocusedEnd := cGSelectedFocusedEnd;
  cShadeDisabledFocused := cShadeSelectFocused;

  cGHeaderStart := $00F9F9F9;
  cGHeaderEnd := $00FEFEFE;
  cGHeaderHotStart := $00FFEDBD;
  cGHeaderHotEnd := $00FFF7E3;
  cGHeaderSelStart := $00FCEABA;
  cGHeaderSelEnd := $00FCF4E0;
  cBackground := clWindow;
  cLineHighLight := $00FEFBF6;

  CellBkgColor := clWindow;
  CellBrdColor[False, False] := $00B5B5B5;
  CellBrdColor[False, True] := cSelected;
  CellBrdColor[True, False] := $00B5B5B5;
  CellBrdColor[True, True] := cSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ItemPaintBasic(Canvas: TCanvas; R: TRect; State: TsvItemState; Focused: Boolean);
var
  C: TColor;
  R1: TRect;
begin
  R1 := R;
  if R1.Right < 48 then
    R1.Right := 48;
  Canvas.Brush.Style := bsClear;

  if (State = svSelected) or (State = svHot) or (State = svHotSelected) then
  begin
    if (ThumbsViewer.Focused) and ((State = svSelected) or (State = svHotSelected)) then
    begin
      if not Focused then
      begin
        Canvas.Pen.Color:= cSelected;
        GradientFill(Canvas, R1, cGSelectedStart, cGSelectedEnd, tgTopBottom);
        C:= cShadeSelect
      end
      else
      begin
        Canvas.Pen.Color:= cSelectedFocused;
        GradientFill(Canvas, R1, cGSelectedFocusedStart, cGSelectedFocusedEnd, tgTopBottom);
        C:= cShadeSelectFocused
      end;
    end
    else if (State = svHot) then
    begin
      Canvas.Pen.Color:= cHot;
      GradientFill(Canvas, R1, cGHotStart, cGHotEnd, tgTopBottom);
      C:= cShadeHot;
    end else
    begin
      Canvas.Pen.Color:= cDisabled;
      if not Focused then
      begin
        Canvas.Pen.Color:= cDisabled;
        GradientFill(Canvas, R1, cGDisabledStart, cGDisabledEnd, tgTopBottom);
        C:= cShadeDisabled;
      end
      else
      begin
        Canvas.Pen.Color:= cDisabledFocused;
        GradientFill(Canvas, R1, cGDisabledFocusedStart, cGDisabledFocusedEnd, tgTopBottom);
        C:= cShadeDisabledFocused;
      end;
    end;
    Canvas.Rectangle(R1);

    Canvas.Pen.Color:= C;
    Canvas.MoveTo(R1.Left + 1, R1.Top + 2);
    Canvas.LineTo(R1.Left + 1, R1.Bottom - 2);
    Canvas.LineTo(R1.Right - 2, R1.Bottom - 2);
    Canvas.LineTo(R1.Right - 2, R1.Top + 1);

    Canvas.Pen.Style:= psSolid;
    Canvas.Pixels[R1.Left, R1.Top]:= C;
    Canvas.Pixels[R1.Left, R1.Bottom - 1]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Top]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Bottom - 1]:= C;
  end
  else if not Focused then
  begin
    Canvas.Pen.Color := cBorder;
    C:= cShadeBorder;
    Canvas.Rectangle(R1);

    Canvas.Pen.Style:= psSolid;
    Canvas.Pixels[R1.Left, R1.Top]:= C;
    Canvas.Pixels[R1.Left, R1.Bottom - 1]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Top]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Bottom - 1]:= C;
  end;

  if Focused and not ((State = svSelected) or (State = svHotSelected)) then
  begin
    if (ThumbsViewer.Focused) then
    begin
      Canvas.Pen.Color := cSelectedFocused;
      C:= cShadeSelectFocused;
    end
    else
    begin
      Canvas.Pen.Color := cDisabledFocused;
      C:= cShadeDisabledFocused;
    end;
    Canvas.Rectangle(R1);

    Canvas.Pen.Style:= psSolid;
    Canvas.Pixels[R1.Left, R1.Top]:= C;
    Canvas.Pixels[R1.Left, R1.Bottom - 1]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Top]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Bottom - 1]:= C;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
var
  w, h: Integer;
begin
  CellScale := Value;
  case CellScale of
    31..63: CellJpeg.Scale := jsQuarter;
    64..127: CellJpeg.Scale := jsHalf;
    128..255: CellJpeg.Scale := jsFullSize;
  else
    CellJpeg.Scale := jsEighth;
  end;

  CellStyle := 0;
  h := CellScale + 10;
  w := CellScale + 10;
  if ThumbsDisplayInfo.Checked then
  begin
    CellStyle := CellStyle + 2;
    w := w + 240;
  end;
  if ThumbsDisplayInfo.Checked or Settings.rOptions.rExtraList.InfoWhenNoPic then
  begin
    if h < 72 then
      h := 72;
  end;
  if ThumbsDisplayTitle.Checked then
  begin
    CellStyle := CellStyle + 1;
    h := h + 20;
  end;
  ThumbsViewer.CellWidth := w;
  ThumbsViewer.CellHeight := h;

  if UpdateTrackbar then
  begin
    ThumbsSizer.OnChange := nil;
    ThumbsSizer.Position := Trunc((CellScale + 1) shr 4);
    ThumbsSizer.OnChange := ThumbsSizerChange;
  end;

  ThumbsViewer.CalcView(False);
  ThumbsViewer.Invalidate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameExtras.GetThumbBmp(Picture: TMoviePicture): TBitmap;
var
  i, n, sf: Integer;
  p: PCacheItem;
  Bmp, tmp: TBitmap;
  pt: TPoint;
  Oldest: TDateTime;
begin
  Result := nil;
  // if we have thumbs, see if we can find it...
  if ThumbsPool.Count > 0 then
  begin
    i := ThumbsPool.Count - 1;
    while (i >= 0) and (PCacheItem(ThumbsPool[i]).Picture <> Picture) do
      i := i - 1;
    if i <> -1 then
    begin
      p := ThumbsPool[i];
      if (p.Picture = Picture) then
      begin
        if (p.Scale = CellScale) then
        begin
          p.Age := Now;
          Result := p.Bmp
        end
        else
        begin
          PoolSize := PoolSize - p.Size;
          p.Bmp.Free;
          Dispose(p);
          ThumbsPool.Delete(i);
        end;
      end;
    end;
  end;
  // if we dont have a thumb, make one...
  if Result = nil then
  begin
    if Picture._thumb <> nil then
    begin
      sf := Trunc(Min(Picture._thumbWidth / CellScale, Picture._thumbHeight / CellScale));
      if sf < 0 then
        sf := 0;
      case sf of
        0..1: CellJPEG.Scale := jsFullSize;
        2..3: CellJPEG.Scale := jsHalf;
        4..7: CellJPEG.Scale := jsQuarter;
      else
        CellJPEG.Scale := jsEighth;
      end;
      Picture._thumb.Seek(0, soBeginning);
      CellJPEG.LoadFromStream(Picture._thumb);

      Bmp := TBitmap.Create;
      Bmp.PixelFormat := pf24bit;
      pt := CalcImageSize(CellJPEG.Width, CellJPEG.Height, CellScale, CellScale);
      if pt.X <> CellJPEG.Width then
      begin
        tmp := TBitmap.Create;
        tmp.PixelFormat := pf24bit;
        tmp.Width := CellJPEG.Width;
        tmp.Height := CellJPEG.Height;
        tmp.Canvas.Draw(0, 0, CellJPEG);
        Bmp.Width := pt.X + 1;
        Bmp.Height := pt.Y + 1;
        if (Bmp.Width > 4) and (Bmp.Height > 4) then
          BiReSample(tmp, Bmp, False)
        else
          Bmp.Canvas.StretchDraw(Bmp.Canvas.ClipRect, tmp);
        tmp.Free;
      end
      else
      begin
        Bmp.Width := CellJPEG.Width;
        Bmp.Height := CellJPEG.Height;
        Bmp.Canvas.Draw(0, 0, CellJPEG);
      end;

      // Purge thumbs if needed
      while (PoolSize > MaxPool) and (ThumbsPool.Count > 0) do
      begin
        Oldest := Now;
        n := 0;
        for i := 0 to ThumbsPool.Count - 1 do
        begin
          p := ThumbsPool[i];
          if p.Age <= Oldest then
          begin
            Oldest := p.Age;
            n := i;
          end;
        end;
        Assert(n >= 0);
        p := ThumbsPool[n];
        PoolSize := PoolSize - p.Size;
        p.Bmp.Free;
        Dispose(p);
        ThumbsPool.Delete(n);
      end;

      New(p);
      p.Picture := Picture;
      p.Size := Bmp.Width * Bmp.Height;
      p.Age := Now;
      p.Scale := CellScale;
      p.Bmp := Bmp;
      ThumbsPool.Add(p);
      PoolSize := PoolSize + p.Size;
      Result := p.Bmp;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerCellPaint(Sender: TObject; Canvas: TCanvas;
  Cell: TRect; IdxGrp, IdxItem: Integer; Data: Int64; State: TsvItemState);
var
  Extra: TMovieExtra;
  LabelColor, TextColor: TColor;
  X, Y, TW, TH, SizeLabel, SizeLine, Height: Integer;
  F, S, HasPicture, ShowOnlyInfo, Checkboxes, LockOk, ThumbOk: Boolean;
  R, RCell: TRect;
  pt: TPoint;
  Txt, PaddingTextLeft: string;
begin
  Extra := TMovieExtra(Pointer(Data));
  HasPicture := (Extra.Picture.PicStream <> nil) or (Extra.Picture.PicPath <> '');
  ShowOnlyInfo := Settings.rOptions.rExtraList.InfoWhenNoPic and
    not HasPicture;
  Checkboxes := Settings.rOptions.rExtraList.Checkboxes;
  LockOk := Extra.Picture.LockWait(0);
  if (LockOk) then
    ThumbOk := (Extra.Picture._thumb <> nil) and (Extra.Picture._thumbError = 0)
  else
    ThumbOk := False;

  ItemPaintBasic(Canvas, Cell, State,
    (ThumbsViewer.IdxGrp = IdxGrp) and (ThumbsViewer.IdxItem = IdxItem));

  F := ThumbsViewer.Focused;
  S := (State = svSelected) or (State = svHotSelected);

  RCell := Cell;
  if (CellStyle >= 2) then
    RCell.Right := RCell.Left + CellScale + 10;
  if (CellStyle = 1) or (CellStyle = 3) then
    RCell.Bottom := RCell.Bottom - 20;

  if not ShowOnlyInfo then
  begin
    if ThumbOk then
      pt := CalcImageSize(Extra.Picture._thumbWidth, Extra.Picture._thumbHeight, CellScale, CellScale)
    else if (Extra.Picture._thumbError = 0) and (ThumbLoading <> nil) then
      pt := CalcImageSize(ThumbLoading.Width, ThumbLoading.Height, CellScale,
        CellScale)
    else
      pt := CalcImageSize(CellScale, CellScale, CellScale, CellScale);

    TW := pt.X;
    TH := pt.Y;
    X := RCell.Left + ((RCell.Right - (RCell.Left + TW)) shr 1);
    Y := RCell.Top + ((RCell.Bottom - (RCell.Top + TH)) shr 1);
    R.Left := X;
    R.Top := Y;
    R.Right := X + TW;
    R.Bottom := Y + TH;

    if ThumbOk then
    begin
      Canvas.Draw(X, Y, GetThumbBmp(Extra.Picture));
      Canvas.Pen.Color := CellBrdColor[F, S];
      InflateRect(R, 2, 2);
      Canvas.Rectangle(R);
      Canvas.Pen.Color := clWhite;
      InflateRect(R, -1, -1);
      Canvas.Rectangle(R);
    end
    else if (Extra.Picture._thumbError = 0) then
    begin
      if ThumbLoading <> nil then
      begin
        Canvas.Draw(X, Y, ThumbLoading);
      end else
      begin
        txt := 'Loading...';
        DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
        DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);
      end;
    end
    else
    begin
      R.Top := R.Top - 10;
      R.Bottom := R.Bottom - 10;

      txt := 'No Picture';
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);

      R.Top := R.Top + 20;
      R.Bottom := R.Bottom + 20;

      txt := 'Error '+ IntToStr(Extra.Picture._thumbError);
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);

      R.Top := R.Top - 10;
      R.Bottom := R.Bottom - 10;

      Canvas.Pen.Color := CellBrdColor[F, S];
      InflateRect(R, 2, 2);
      Canvas.Rectangle(R);
      Canvas.Pen.Color := clWhite;
      InflateRect(R, -1, -1);
      Canvas.Rectangle(R);
    end;
  end;

  if ((State = svSelected) or (State = svHotSelected)) then
  begin
    LabelColor := $E0E0E0;
    TextColor := clWhite;
  end else
  begin
    LabelColor := $808080;
    TextColor := clBlack;
  end;

  if (CellStyle >= 2) or ShowOnlyInfo then
  begin
    if ShowOnlyInfo then
    begin
      RCell.Left := Cell.Left + 4;
      RCell.Right := Cell.Right;
      R := RCell;
      R.Top := R.Top + 1;
      R.Bottom := R.Bottom - 2;
    end else
    begin
      RCell.Left := RCell.Right + 5;
      RCell.Right := Cell.Right;
      R := RCell;
      R.Top := R.Top + 1;
      R.Bottom := R.Bottom - 2;
    end;

    if (CellStyle >= 2) then
    begin
      SizeLabel := 79;
      PaddingTextLeft := '                            ';
    end else
    begin
      SizeLabel := 19;
      PaddingTextLeft := '        ';
    end;
    SizeLine := 14;

    R.Right := R.Left + SizeLabel;
    if (CellStyle >= 2) then
      txt := Messages.Strings[msgInfoNumberAndTag]
    else
      txt := Messages.Strings[msgInfoShortNumberAndTag];
    SetTextColor(Canvas.Handle, LabelColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
    R.Left := R.Right + 5;
    R.Right := RCell.Right;
    txt := IntToStr(Extra.iNumber);
    if Length(Extra.strTag) > 0 then
      txt := txt + ' / ' + Extra.strTag;
    SetTextColor(Canvas.Handle, TextColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

    R.Top := R.Top + SizeLine;
    R.Left := RCell.Left;
    R.Right := R.Left + SizeLabel;
    if (CellStyle >= 2) then
      txt := Messages.Strings[msgInfoTitle]
    else
      txt := Messages.Strings[msgInfoShortTitle];
    SetTextColor(Canvas.Handle, LabelColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
    R.Left := R.Right + 5;
    R.Right := RCell.Right;
    txt := Extra.strTitle;
    SetTextColor(Canvas.Handle, TextColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

    R.Top := R.Top + SizeLine;
    R.Left := RCell.Left;
    R.Right := R.Left + SizeLabel;
    if (CellStyle >= 2) then
      txt := Messages.Strings[msgInfoCategory]
    else
      txt := Messages.Strings[msgInfoShortCategory];
    SetTextColor(Canvas.Handle, LabelColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
    R.Left := R.Right + 5;
    R.Right := RCell.Right;
    txt := Extra.strCategory;
    SetTextColor(Canvas.Handle, TextColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

    R.Top := R.Top + SizeLine;
    R.Left := RCell.Left;
    R.Right := R.Left + SizeLabel;
    if (CellStyle >= 2) then
      txt := Messages.Strings[msgInfoURL]
    else
      txt := Messages.Strings[msgInfoShortURL];
    SetTextColor(Canvas.Handle, LabelColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
    R.Left := R.Right + 5;
    R.Right := RCell.Right;
    txt := Extra.strURL;
    SetTextColor(Canvas.Handle, TextColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_END_ELLIPSIS or DT_PATH_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

    R.Top := R.Top + SizeLine;
    R.Left := RCell.Left;
    R.Right := R.Left + SizeLabel;
    if (CellStyle >= 2) then
      txt := Messages.Strings[msgInfoDescription]
    else
      txt := Messages.Strings[msgInfoShortDescription];
    SetTextColor(Canvas.Handle, LabelColor);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
      DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

    txt := PaddingTextLeft + StringReplace(Extra.strDescription, sLineBreak, ' ', [rfReplaceAll]);
    R.Right := RCell.Right;
    SetTextColor(Canvas.Handle, TextColor);
    Height := DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_NOPREFIX or DT_LEFT or DT_WORDBREAK or DT_EDITCONTROL );

    if Height + SizeLine - 11 < SizeLine then
      R.Top := R.Top + SizeLine
    else
      R.Top := R.Top + Height + SizeLine - 11;
    if R.Bottom - R.Top >= 11 then
    begin
      R.Left := RCell.Left;
      R.Right := R.Left + SizeLabel;
      if (CellStyle >= 2) then
        txt := Messages.Strings[msgInfoComments]
      else
        txt := Messages.Strings[msgInfoShortComments];
      SetTextColor(Canvas.Handle, LabelColor);
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
        DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);

      txt := PaddingTextLeft + StringReplace(Extra.strComments, sLineBreak, ' ', [rfReplaceAll]);
      R.Right := RCell.Right;
      SetTextColor(Canvas.Handle, TextColor);
      Height := DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
        DT_NOPREFIX or DT_LEFT or DT_WORDBREAK or DT_EDITCONTROL );
    end;

    if Height + SizeLine - 11 < SizeLine then
      R.Top := R.Top + SizeLine
    else
      R.Top := R.Top + Height + SizeLine - 11;
    if R.Bottom - R.Top >= 11 then
    begin
      R.Left := RCell.Left;
      R.Right := R.Left + SizeLabel;
      if (CellStyle >= 2) then
        txt := Messages.Strings[msgInfoCreatedBy]
      else
        txt := Messages.Strings[msgInfoShortCreatedBy];
      SetTextColor(Canvas.Handle, LabelColor);
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
        DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
      R.Left := R.Right + 5;
      R.Right := RCell.Right;
      txt := Extra.strCreatedBy;
      SetTextColor(Canvas.Handle, TextColor);
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
        DT_SINGLELINE or DT_NOPREFIX or DT_LEFT);
    end;

    SetTextColor(Canvas.Handle, clBlack);
  end;

  if (CellStyle = 1) or (CellStyle = 3) then
  begin
    RCell := Cell;
    if Checkboxes then
    begin
      R := RCell;
      R.Top := R.Bottom - 16;
      R.Left := R.Left + 4;
      R.Right := R.Left + 12;
      R.Bottom := R.Bottom - 4;

      if Extra.bChecked then
        DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED)
      else
        DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DFCS_BUTTONCHECK);
      Canvas.Brush.Style := bsClear;

      R := RCell;
      R.Top := R.Bottom - 20;
      R.Left := R.Left + 4 + 16;
      R.Right := R.Right - 4;
    end
    else
    begin
      R := RCell;
      R.Top := R.Bottom - 20;
      R.Left := R.Left + 4;
      R.Right := R.Right - 4;
    end;

    txt := '';
    if Settings.rOptions.rExtraList.NumWithTitle then
    begin
      txt := IntToStr(Extra.iNumber);
      if Extra.strTitle <> '' then
        txt := txt + ' - ';
    end;
    txt := txt + Extra.strTitle;

    SetTextColor(Canvas.Handle, TextColor);
    if Checkboxes then
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
        DT_SINGLELINE or DT_NOPREFIX or DT_LEFT or DT_VCENTER)
    else
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
        DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);
    SetTextColor(Canvas.Handle, clBlack);
  end;

  if (LockOk) then
    Extra.Picture.Unlock
  else
    PostMessage(Self.Handle, CM_UpdateViewExtras, 1, -1) // Need to be refresh again later !
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerDividerPaint(Sender: TObject;
  Canvas: TCanvas; Cell: TRect; IdxGrp: Integer; Group: PSmartGroup;
  State: TsvItemState);
var
  R: TRect;
  txt: string;
  x: Integer;
  cFontColorSave: TColor;
begin
  cFontColorSave := Canvas.Font.Color;
  R := Cell;
  ItemPaintBasic(Canvas, Cell, State,
    (ThumbsViewer.IdxGrp = IdxGrp) and (ThumbsViewer.IdxItem = -1));
  if (Group.Expanded) then
  begin
    Canvas.Draw(R.Left + 1, R.Top+2, MinusPicture.Picture.Bitmap);
  end else
  begin
    Canvas.Draw(R.Left + 1, R.Top+2, PlusPicture.Picture.Bitmap);
  end;
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  //Canvas.Font.Color := $00905422;
  R.Left := R.Left + 22;
  txt := Group.Caption;
  if (State = svSelected) or (State = svHotSelected) then
    SetTextColor(Canvas.Handle, clWhite);
  DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
    DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER);
  SetTextColor(Canvas.Handle, clBlack);
  x := Canvas.TextWidth(txt) + R.Left + 8;
  if x < R.Right - 8 then
  begin
    Canvas.Pen.Color := $00F0F0F0;
    Canvas.MoveTo(x, R.Top + 10);
    Canvas.LineTo(R.Right - 8, R.Top + 10);
    Canvas.Font.Color := cFontColorSave;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerHeaderPaint(Sender: TObject;
  Canvas: TCanvas; Header: TRect; Offset, Active: Integer;
  State: TsvItemState; Columns: array of Integer);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.EnsureVisibleThumbsViewer(IdxGrp: Integer; IdxItem: Integer);
begin
  if (ThumbsViewer.SmartGroups.Count > 0) or (ThumbsViewer.Items.Count > 0) then
  begin
    if (IdxGrp > -1) and (IdxItem > -1) then
    begin
      if PSmartGroup(ThumbsViewer.SmartGroups.Items[IdxGrp]).Expanded then
      begin
        ThumbsViewer.SetAtTop(IdxGrp, -1);
        ThumbsViewer.SetInView(IdxGrp, IdxItem);
      end else
        ThumbsViewer.SetAtTop(IdxGrp, -1);
    end else
    begin
      ThumbsViewer.SetAtTop(IdxGrp, IdxItem);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerEnsureVisiblePlus;
begin
  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
    EnsureVisibleThumbsViewer(ThumbsViewer.IdxGrp, ThumbsViewer.IdxItem);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerSelecting(Sender: TObject; Count: Integer);
begin
  ExtraSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerCellFocusedChange(Sender: TObject;
  IdxGrp, IdxItem: Integer; Data: Int64);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerCellSelectedChange(Sender: TObject;
  IdxGrp, IdxItem: Integer; Data: Int64; Selected: Boolean);
begin
  if Data > 0 then
    TMovieExtra(Pointer(Data))._bSelected := Selected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerCellHit(Sender: TObject; Canvas: TCanvas;
  IdxGrp, IdxItem: Integer; Data: Int64; x, y: Integer; Shift: TShiftState; Clicked: Boolean;
  Button: TMouseButton; var Selected: Boolean);
begin
  with Settings.rOptions.rExtraList do
    Selected := not Checkboxes or (CellStyle = 0) or (CellStyle = 2) or
      not ((x >= 4) and (x <= 16) and (y >= 4) and (y <= 16) and (Button = mbLeft));
  if Selected then
    ThumbCheckboxOver := -1
  else
    ThumbCheckboxOver := Data;
  if Clicked then
    if Selected then
      Selected := (Button = mbLeft)
    else
      ThumbCheckboxClick := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerDividerHit(Sender: TObject; Canvas: TCanvas;
  IdxGrp: Integer; Group: PSmartGroup; x: Integer; Shift: TShiftState;
  Clicked: Boolean; Button: TMouseButton; var Selected: Boolean;
  var Expanded: Boolean);
begin
  Selected := (x > 20);
  if Clicked then
  begin
    Selected := False;
    Expanded := Group.Expanded;
    if Button = mbLeft then
    begin
      if (x <= 20) then
        Expanded := not Group.Expanded
      else
        Selected := True;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerDividerExpandedChange(Sender: TObject;
  IdxGrp: Integer; Group: PSmartGroup; Expanded: Boolean);
var
  n: Integer;
begin
  if (FCurrentMovie <> nil) and (FCurrentMovie.MovieList <> nil) then
    with FCurrentMovie.MovieList do
    begin
      n := _extraGroups.IndexOf(Group.Name);
      if n = -1 then
        if Expanded then
          _extraGroups.AddObject(Group.Name, Pointer(1))
        else
          _extraGroups.AddObject(Group.Name, Pointer(0))
      else
        if Expanded then
          _extraGroups.Objects[n] := Pointer(1)
        else
          _extraGroups.Objects[n] := Pointer(0)
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerHeaderClick(Sender: TObject;
  Column: Integer);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerDblClick(Sender: TObject);
begin
  if (ThumbsViewer.IdxGrp <> -1) and (ThumbsViewer.IdxItem = -1) then
  begin
    with ThumbsViewer do
    begin
      ExpandSmartGroup(IdxGrp, not PSmartGroup(SmartGroups.Items[IdxGrp]).Expanded, False);
      CalcViewGroups;
      SetInView(IdxGrp, 0);
      Invalidate;
    end;
  end
  else if (ThumbsViewer.IdxItem <> -1) then
  begin
    if Settings.rOptions.rExtraList.ActionDoubleClick = 1 then
      ActionExtrasEdit.Execute
    else if Settings.rOptions.rExtraList.ActionDoubleClick = 2 then
      ActionExtraShowPic.Execute
    else if Settings.rOptions.rExtraList.ActionDoubleClick = 3 then
      ActionURLOpen.Execute;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (X <> FMouseThumbsViewerX) or (Y <> FMouseThumbsViewerY) then
  begin
    if (Settings.rOptions.rDisplay.AutoFocus) and
      (not ThumbsViewer.Focused) and ThumbsViewer.CanFocus then
      ThumbsViewer.SetFocus;
    FMouseThumbsViewerX := X;
    FMouseThumbsViewerY := Y;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Extra: TMovieExtra;
begin
  if (ThumbCheckboxClick) then
  begin
    if (ThumbCheckboxOver > -1) and (ThumbsViewer.HotIdx = -2) then
    begin
      ExtrasBeforeChange(Self);
      Extra := TMovieExtra(Pointer(ThumbCheckboxOver));
      Extra.bChecked := not Extra.bChecked;
      ThumbsViewer.Invalidate;
      ExtrasChange(Self);
    end;
  end else
  begin
    if (Button = mbRight) then
    begin
      PopupMovieExtrasPopup(ThumbsViewer);
      PopupMovieExtras.Popup(ThumbsViewer.ClientOrigin.X + X, ThumbsViewer.ClientOrigin.Y + Y);
    end;
  end;
  ThumbCheckboxClick := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  FKeyDownThumbs := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Extra: TMovieExtra;
begin
  if not FKeyDownThumbs then
    Exit;
  FKeyDownThumbs := False;
  if (Key = VK_RETURN) and (Shift = []) and (FSelectedExtra <> nil) and
    (FSelectedExtra = FOldSelectedExtra) then
  begin
    if Settings.rOptions.rExtraList.ActionKeyReturn = 1 then
      ActionExtrasEdit.Execute
    else if Settings.rOptions.rExtraList.ActionKeyReturn = 2 then
      ActionExtraShowPic.Execute
    else if Settings.rOptions.rExtraList.ActionKeyReturn = 3 then
      ActionURLOpen.Execute;
  end
  else if (Key = Ord('R')) and (Shift = []) then
    ThumbsViewerStart
  else if (Key = Ord('M')) and (Shift = []) then
    ActionExtrasEdit.Execute
  else if (Key = Ord('P')) and (Shift = []) then
    ActionExtraShowPic.Execute
  else if (Key = Ord('U')) and (Shift = []) then
    ActionURLOpen.Execute
  else if (Key = Ord('D')) and (Shift = []) then
    ActionURLExplore.Execute
  else if (Key = Ord('C')) and (Shift = []) then
    ActionURLCopy.Execute
  else if (Key = Ord('B')) and (Shift = []) then
    ActionURLBrowse.Execute
  else if (Key = Ord('C')) and (Shift = [ssCtrl]) then
    ActionExtrasCopy.Execute
  else if (Key = Ord('V')) and (Shift = [ssCtrl]) then
    ActionExtrasPaste.Execute
  else if (Key = Ord('A')) and (Shift = [ssCtrl]) then
    ThumbsViewer.SelectAll(False, True, True)
  else if (Key = VK_DELETE) and (Shift = []) then
    ActionExtrasDelete.Execute
  else if (Key = VK_INSERT) and (Shift = []) then
    ActionExtrasAdd.Execute
  else if (Key = VK_INSERT) and (Shift = [ssCtrl]) then
    ActionExtrasImportFiles.Execute
  else if ((Key = Ord('T')) and (Shift = [ssCtrl])) or
    ((Key = VK_MULTIPLY) and (Shift = [])) or ((Key = VK_ADD) and (Shift = [ssCtrl])) then
  begin
    ThumbsViewer.SetExpanded(True);
    ThumbsViewerEnsureVisiblePlus;
  end
  else if ((Key = Ord('T')) and (Shift = [ssCtrl, ssShift])) or
    ((Key = VK_SUBTRACT) and (Shift = [ssCtrl])) then
  begin
    ThumbsViewer.SetExpanded(False);
    ThumbsViewerEnsureVisiblePlus;
  end
  else if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
    with ThumbsViewer do
    begin
      if (IdxItem > -1) then
      begin
        ExtrasBeforeChange(Self);
        if (IdxGrp > -1) then
          Extra := TMovieExtra(Pointer(PSmartGroup(SmartGroups.Items[IdxGrp]).Items[IdxItem]))
        else
          Extra := TMovieExtra(Pointer(Items[IdxItem]));
        Extra.bChecked := not Extra.bChecked;
        Invalidate;
        ExtrasChange(Self);
      end;
    end;

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsViewerResize(Sender: TObject);
begin
  ThumbsViewerEnsureVisiblePlus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsSizerChange(Sender: TObject);
begin
  SetThumbSize((ThumbsSizer.Position shl 4) - 1, False);
  ThumbsViewerEnsureVisiblePlus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsDisplayTitleClick(Sender: TObject);
begin
  ThumbsSizerChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ThumbsDisplayInfoClick(Sender: TObject);
begin
  ThumbsSizerChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ImportExtraPicture(Picture: TMoviePicture;
  const AFileName: TFileName; const ImportMethod: TMoviePictureImport);
begin
  if Picture = nil then
    Exit;
  ExtrasBeforeChange(Self);
  try
    Picture.ImportPicture(AFileName, FCatalogFile, ImportMethod);
  except
    on e: Exception do
      MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
  end;
  ExtrasChange(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ImportExtraPictureFromStream(Picture: TMoviePicture;
  Stream: TMemoryStream; DefaultExt: string; const ImportMethod: TMoviePictureImport);
begin
  if (Picture = nil) or (Stream = nil) then
    Exit;
  ExtrasBeforeChange(Self);
  try
    Picture.ImportPictureFromStream(Stream, DefaultExt, FCatalogFile, ImportMethod);
  except
    on e: Exception do
      MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
  end;
  ExtrasChange(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.DockExtrasTopRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarExtras);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.OnCancelDragDrop;
begin
  FCancelDragDrop := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.DragDropFilesDrop(Sender: TObject; Position: TPoint;
  Value: TStringList);
var
  FileName, ext: string;
  i, IdxGrp, IdxItem: Integer;
  DoNotAsk, Multiple: Boolean;
  PicImportMethod: TPictureSelectOption;
  AddedExtras: TObjectList;
  iData: Int64;

  function AddNewExtra: Boolean;
  var
    OldSelectedExtra: TMovieExtra;
  begin
    Result := False;
    OldSelectedExtra := FSelectedExtra;
    ActionExtrasAddExecute(nil);
    if (OldSelectedExtra= FSelectedExtra) or (FSelectedExtra = nil) then
      FCancelDragDrop := True
    else
      AddedExtras.Add(FSelectedExtra);
  end;

begin
  if (FCurrentMovie = nil) or (Value.Count = 0) then
    Exit;
  //if (FSelectedExtra = nil) then
    Multiple := True;
  //else
  //  Multiple := False;

  AddedExtras := TObjectList.Create(False);

  Application.ProcessMessages;
  ProgressWin.Status := Messages.Strings[msgDragDropFiles] + ' (' + IntToStr(Value.Count) + ')';
  ProgressWin.Maximum := Value.Count;
  ProgressWin.AutoUpdateTextProgress := False;
  ProgressWin.IntProgress := 0;
  ProgressWin.Progress := '';
  ProgressWin.Execute(MainWindow);
  ProgressWin.OnCancel := OnCancelDragDrop;
  FCancelDragDrop := False;
  try
    BeginUpdate;
    with Settings.rOptions.rMovieInformation do
    begin
      PicImportMethod := TPictureSelectOption(Abs(rExtraPicImport.GetInfoMethod));
      if rExtraPicImport.GetInfoMethod <= 0 then
        for i := 0 to Value.Count-1 do
        begin
          FileName := Value.Strings[i];
          ext := LowerCase(ExtractFileExt(FileName));
          if IndexText(ext, extImage) <> -1 then
          begin
            with TPictureDragDropWin.Create(Application) do
              try
                ToolbarImages.GetIcon(Ord(ICON_PICTUREOPEN), Icon);
                if not Execute(PicImportMethod, DoNotAsk) then
                  FCancelDragDrop := True
                else
                begin
                  rExtraPicImport.GetInfoMethod := Integer(PicImportMethod);
                  if not DoNotAsk then
                    rExtraPicImport.GetInfoMethod := - rExtraPicImport.GetInfoMethod;
                end;
              finally
                Release;
              end;
            break;
          end;
        end;
    end;

    if not FCancelDragDrop then
      ExtrasBeforeChange(Self);

    i := 0;
    while (i < Value.Count) and (not FCancelDragDrop) do
    begin
      //ProgressWin.Status := Messages.Strings[msgDragDropFiles] + '(' + IntToStr(i+1) + '/' + IntToStr(Value.Count) + ')';
      ProgressWin.IntProgress := i;
      ProgressWin.Progress := ExtractFileName(Value.Strings[i]);

      FileName := Value.Strings[i];
      ext := LowerCase(ExtractFileExt(FileName));

      // **** Import something ****
      // **** Picture ***
      if IndexText(ext, extImage) <> -1 then
      begin
        if Multiple then
          AddNewExtra;
        if (not FCancelDragDrop) and (FSelectedExtra <> nil) then
        begin
          if not FCancelDragDrop then
          begin
            StopThumbThread;
            ImportExtraPicture(FSelectedExtra.Picture, FileName, TMoviePictureImport(PicImportMethod));
            if FSelectedExtra.strTitle = '' then
              FSelectedExtra.strTitle := ExtractFileName(ChangeFileExt(FileName, ''));
            //LoadPreviewPicture;
            ThumbsViewerStart;
          end;
        end;
      end else

      // **** Video ****
      if (IndexText(ext, extVideo) <> -1) or
        ((Ext <> '') and (Pos(ext+' ', Settings.rOptions.rMovieInformation.ImportExt+' ') > 0)) then
      begin
        if Multiple then
          AddNewExtra;
        if (not FCancelDragDrop) and (FSelectedExtra <> nil) then
        begin
          StopThumbThread;
          FSelectedExtra.strURL := FileName;
          if FSelectedExtra.strTitle = '' then
            FSelectedExtra.strTitle := ExtractFileName(ChangeFileExt(FileName, ''));
          FreeAndNil(FSelectedExtra.Picture._thumb);
          FSelectedExtra.Picture._thumbError := 0;
          ThumbsViewerStart;
        end;
      end;  // if extVideo
      Inc(i);
    end;
    ProgressWin.IntProgress := ProgressWin.Maximum;
  finally
    EndUpdate;
    ProgressWin.OnCancel := nil;
    ProgressWin.Close;
    ProgressWin.AutoUpdateTextProgress := True;
  end;
  Application.ProcessMessages;

  if Multiple and (AddedExtras.Count > 0) then
  begin
    ThumbsViewer.ClearSelection;
    for i := 0 to AddedExtras.Count-1 do
    begin
      iData := ULong(Pointer(AddedExtras.Items[i]));
      if ThumbsViewer.FindCellFromData(iData, IdxGrp, IdxItem) then
      begin
        ThumbsViewer.AddSelection(iData, IdxGrp, IdxItem);
        if i = 0 then
          ThumbsViewer.SetFocused(IdxGrp, IdxItem, False);
      end;
    end;
    ThumbsViewerEnsureVisiblePlus;
    ThumbsViewer.Invalidate;
    ExtraSelected;
  end;

  if (AddedExtras.Count > 0) then
    ExtrasChange(Self);

  AddedExtras.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasImportFilesExecute(Sender: TObject);
var
  s: string;
begin
  if FCurrentMovie = nil then
    Exit;
  //StopThumbThread; // Done in DragDropFilesDrop
  with TOpenDialog.Create(Self) do
    try
      InitialDir := Settings.rOptions.rFolders[fuGetFromFiles].Value;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      FileName := '';
      Title := Messages.Strings[msgSelectFilesImport];
      Options := DialogOpenOptions + [ofAllowMultiSelect];
      s := Trim(Settings.rOptions.rMovieInformation.ImportExt);
      if (s <> '') then
      begin
        s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
        s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
        s := '*' + StringReplace(s, ' ', ';*', [rfReplaceAll]);
      end else
      begin
        //for i := Low(extVideo) to High(extVideo) do
        //begin
        //  if s <> '' then
        //    s := s + ';';
        //  s := Format('%s*%s', [s, extVideo[i]]);
        //end;
        s := '*.novideoext';
      end;

      Filter := Format(DialogImportExtrasFilter, [s]);
      if Execute then
      begin
        Settings.rOptions.rFolders[fuGetFromFiles].Value := ExtractFilePath(FileName);
        DragDropFilesDrop(sender, point(0, 0), TStringList(Files));
      end;
  finally
    Free;
  end;
  //ThumbsViewerStart; // Done in DragDropFilesDrop
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasAddExecute(Sender: TObject);
var
  idx: Integer;
begin
  if FCurrentMovie = nil then
    Exit;
  ExtrasBeforeChange(Self);
  ThumbsViewerStop;
  ClearSelectedStates;
  idx := FCurrentMovie.Extras.AddExtra;
  if idx <> -1 then
  begin
    CurrentMovie.Extras.Items[idx]._bSelected := True;
    CurrentMovie.Extras.Items[idx].bChecked := True;
    CurrentMovie.Extras.Items[idx].Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
    if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
      try
        CurrentMovie.Extras.Items[idx].Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
          FCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
      except
      end;
  end;
  ThumbsViewerStart;
  ExtrasChange(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasEditExecute(Sender: TObject);
begin
  if FCurrentMovie = nil then
    Exit;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TExtrasEditWin, ExtrasEditWin);
    try
      ToolbarImages.GetIcon(Ord(ICON_EXTRASEDIT), ExtrasEditWin.Icon);
      ExtrasBeforeChange(Self);
      StopThumbThread;
      if ExtrasEditWin.Execute(FCurrentMovie, FCatalogFile) then
      begin
        ThumbsViewerStart;
        ExtrasChange(Self);
      end
      else
        StartThumbThread;
    finally
      ExtrasEditWin.Release;
      ExtrasEditWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasDeleteExecute(Sender: TObject);
var
  i, iData, nb: Integer;
  Pt: TPoint;
  Extra: TMovieExtra;
  Group: PSmartGroup;
  Buttons: array of Variant;
  DoNotAsk: Boolean;
begin
  if FCurrentMovie = nil then
    Exit;
  if Settings.rOptions.rExtraList.ConfirmDelete then
  begin
    DoNotAsk := false;
    Buttons := VarArrayOf([mbYes,mbNo]);
    if MessageWin.Execute(Messages.Strings[msgDeleteExtras], mtConfirmation,
      DoNotAsk, Messages.Strings[msgDoNotConfirm], Buttons) = 1 then
      Settings.rOptions.rExtraList.ConfirmDelete := not DoNotAsk
    else
      Exit;
  end;

  ExtrasBeforeChange(Self);
  StopThumbThread;

  nb := 0;
  Pt.X := -1;
  Pt.Y := -1;
  for i := ThumbsViewer.SelectionCount - 1 downto 0 do
  begin
    iData := ThumbsViewer.GetSelection(i);
    if iData > 0 then
    begin
      Inc(nb);
      Pt := ThumbsViewer.GetSelectionCell(i);
      Extra := TMovieExtra(Pointer(iData));
      Extra.Picture.PictureOperation(FCatalogFile, mpoDelete);
      CurrentMovie.Extras.Remove(Extra);
    end;
  end;

  if nb = 1 then
  begin
    with ThumbsViewer do
    begin
      if Pt.X > -1 then
      begin
        Group := PSmartGroup(SmartGroups.Items[Pt.X]);
        if Pt.Y > 0 then
          Dec(Pt.Y)
        else if Pt.X > 0 then
        begin
          Dec(Pt.X);
          Group := PSmartGroup(SmartGroups.Items[Pt.X]);
          Pt.Y := Group.Items.Count-1;
        end
        else
        begin
          Inc(Pt.Y);
          if Pt.Y >= Group.Items.Count then
          begin
            Pt.Y := 0;
            Pt.X := Pt.X + 1;
            if (Pt.X >= SmartGroups.Count) or
              (PSmartGroup(SmartGroups.Items[Pt.X]).Items.Count = 0) then
              Pt.Y := -1;
          end;
        end;
      end else
      begin
        if Pt.Y > 0 then
          Dec(Pt.Y)
        else
        begin
          Inc(Pt.Y);
          if Pt.Y >= Items.Count then
            Pt.Y := -1;
        end;
      end;
      if Pt.Y > -1 then
      begin
        if Pt.X > -1 then
          Extra := TMovieExtra(Pointer(PSmartGroup(SmartGroups.Items[Pt.X]).Items[Pt.Y]))
        else
          Extra := TMovieExtra(Pointer(Items[Pt.Y]));
        Extra._bSelected := True;
      end;
    end;
  end;

  ThumbsViewerStart;
  ExtrasChange(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtraShowPicExecute(Sender: TObject);
var
  Picture: TMoviePicture;
begin
  if (FCurrentMovie = nil) or (FSelectedExtra = nil) then
    Exit;
  Picture := FSelectedExtra.Picture;
  Picture.Lock;
  try
    if (Picture.PicPath <> '') then
    begin
      if (Picture.PicStream <> nil) then
      begin
        PictureWin := TPictureWin.Create(Self);
        try
          PictureWin.Execute(Picture.GetPictureCaption, Picture.PicStream, Picture.PicPath)
        finally
          FreeAndNil(PictureWin);
        end;
      end else
      begin
        if FCatalogFile <> '' then
          SetCurrentDir(ExtractFilePath(FCatalogFile))
        else
          SetCurrentDir(strDirCatalogs);
        if FileExists(ExpandFileName(Picture.PicPath)) then
        begin
          PictureWin := TPictureWin.Create(Self);
          try
            PictureWin.Execute(Picture.GetPictureCaption, ExpandFileName(Picture.PicPath));
          finally
            FreeAndNil(PictureWin);
          end;
        end else
          MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [Picture.PicPath]), mtError, [mbOk]);
      end;
    end;
  finally
    Picture.Unlock;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtraURLExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionURLOpenExecute(Sender: TObject);
var
  url: string;
begin
  if (FCurrentMovie = nil) or (FSelectedExtra = nil) then
    Exit;
  url := FSelectedExtra.strURL;
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

procedure TMovieFrameExtras.ActionURLBrowseExecute(Sender: TObject);
begin
  if (FCurrentMovie = nil) or (FSelectedExtra = nil) then
    Exit;
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
        ExtrasBeforeChange(Self);
        StopThumbThread;
        Settings.rOptions.rFolders[fuGetFromFiles].Value := ExtractFilePath(FileName);
        FSelectedExtra.strURL := FileName;
        if FSelectedExtra.strTitle = '' then
          FSelectedExtra.strTitle := ExtractFileName(ChangeFileExt(FileName, ''));
        FreeAndNil(FSelectedExtra.Picture._thumb);
        FSelectedExtra.Picture._thumbError := 0;
        ThumbsViewerStart;
        ExtrasChange(Self);
      end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionURLCopyExecute(Sender: TObject);
begin
  if (FCurrentMovie = nil) or (FSelectedExtra = nil) then
    Exit;
  Clipboard.AsText := FSelectedExtra.strURL;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionURLExploreExecute(Sender: TObject);
var
  url: string;
begin
  if (FCurrentMovie = nil) or (FSelectedExtra = nil) then
    Exit;
  url := FSelectedExtra.strURL;
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

procedure TMovieFrameExtras.ActionExtrasCopyExecute(Sender: TObject);
var
  TempExtras: TMovieExtras;
  Status: TMoviePictureStatus;
  DataHandle: THandle;
  i, idx: Integer;
begin
  if FCurrentMovie = nil then
    Exit;
  TempExtras := TMovieExtras.Create(FCurrentMovie);
  try
    StopThumbThread;
    if FCatalogFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile))
    else
      SetCurrentDir(strDirCatalogs);
    with FCurrentMovie.Extras do
    begin
      for i := 0 to Count-1 do
      begin
        if Items[i]._bSelected then
        begin
          idx := TempExtras.AddExtra;
          if idx <> -1 then
          begin
            with TempExtras.Items[idx] do
            begin
              Assign(FCurrentMovie.Extras.Items[i], True, True, True);
              Status := Picture.GetPictureStatus(FCatalogFile);
              if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) or (Status = mpsLinkRel) then
                Picture.PicPath := ExpandFileName(Picture.PicPath);
            end;
          end;
        end;
      end;
    end;
    if TempExtras.Count > 0 then
    begin
      try
        DataHandle := TempExtras.SaveToMemory;
        try
          ClipBoard.SetAsHandle(ClipboardExtrasFormat, DataHandle);
        finally
          TempExtras.FreeMemory(DataHandle, True);
        end;
      except
        on e:Exception do
        begin
          MessageWin.Execute('Copy to clipboard - Error: '+e.Message, mtError, [mbOk]);
        end;
      end;
    end;
  finally
    TempExtras.Free;
    StartThumbThread;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasPasteExecute(Sender: TObject);
var
  TempExtras: TMovieExtras;
  DataHandle: THandle;
  picImportMethod: TPictureSelectOption;
  ImportPic, DoNotAsk: Boolean;
  i, idx: Integer;

begin
  if FCurrentMovie = nil then
    Exit;
  TempExtras := nil;
  try
    DataHandle := ClipBoard.GetAsHandle(ClipboardExtrasFormat);
    if DataHandle <> 0 then
    begin
      TempExtras := TMovieExtras.Create(FCurrentMovie);
      TempExtras.LoadFromMemory(DataHandle)
    end;
  except
    FreeAndNil(TempExtras);
  end;
  if TempExtras = nil then Exit;

  if TempExtras.Count > 0 then
  begin
    if FCatalogFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile))
    else
      SetCurrentDir(strDirCatalogs);

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
                rExtraPicImport.GetInfoMethod := -rExtraPicImport.GetInfoMethod;
            end;
          finally
            Release;
          end;
      end;
    end;

    ExtrasBeforeChange(Self);
    StopThumbThread;
    ClearSelectedStates;
    for i := 0 to TempExtras.Count-1 do
    begin
      idx := FCurrentMovie.Extras.AddExtra;
      if idx <> -1 then
      begin
        with FCurrentMovie.Extras.Items[idx] do
        begin
          if ImportPic then
          begin
            Assign(TempExtras.Items[i], True, True, True);
            if picImportMethod = psoStore then
              Picture.PictureOperation(FCatalogFile, mpoStore)
            else if picImportMethod = psoCopyInCatDir then
              Picture.PictureOperation(FCatalogFile, mpoCopyInCatDir)
            else if picImportMethod = psoCopyInPicDir then
              Picture.PictureOperation(FCatalogFile, mpoCopyInPicDir)
            else if picImportMethod = psoLinkRel then
              Picture.PictureOperation(FCatalogFile, mpoAbsToRelLink);
          end else
            Assign(TempExtras.Items[i], True, False);
          _bSelected := True;
        end;
      end;
    end;
    ThumbsViewerStart;
    ExtrasChange(Self);
  end;
  TempExtras.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.PopupMovieExtrasPopup(Sender: TObject);
var
  i: Integer;
begin
  with PopupMovieExtras.Items do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
  with MnuSelect do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
  with MnuSelected do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasSelGroupExecute(Sender: TObject);
var
  Group: PSmartGroup;
  i: Integer;
begin
  if FCurrentMovie = nil then
    Exit;
  with ThumbsViewer do
    if (IdxGrp > -1) and (IdxItem = -1) then
    begin
      if (not IsKeyDown(VK_CONTROL)) then
        ClearSelection;
      Group := PSmartGroup(SmartGroups.Items[IdxGrp]);
      if Group.Items.Count > 0 then
      begin
        if not Group.Expanded then
          ExpandSmartGroup(IdxGrp, True, True);
        for i := 0 to Group.Items.Count-1 do
          AddSelection(Group.Items[i], IdxGrp, i);
        IdxItem := 0;
        Invalidate;
        ExtraSelected;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.SelectExtrasCheckedOrUnchecked(Checked: Boolean);
var
  Group: PSmartGroup;
  Extra: TMovieExtra;
  n, i: Integer;
begin
  if FCurrentMovie = nil then
    Exit;
  with ThumbsViewer do
  begin
    if (not IsKeyDown(VK_CONTROL)) then
      ClearSelection;
    if Grouped then
    begin
      for n := 0 to SmartGroups.Count - 1 do
      begin
        Group := PSmartGroup(SmartGroups.Items[n]);
        for i := 0 to Group.Items.Count - 1 do
        begin
          Extra := TMovieExtra(Pointer(Group.Items[i]));
          if Extra.bChecked = Checked then
          begin
            if not Group.Expanded then
              ExpandSmartGroup(n, True, False);
            AddSelection(Group.Items[i], n, i);
            if SelectionCount = 1 then
            begin
              IdxGrp := n;
              IdxItem := i;
            end;
          end;
        end;
      end;
    end else
    begin
      for i := 0 to Items.Count - 1 do
      begin
        Extra := TMovieExtra(Pointer(Items[i]));
        if Extra.bChecked = Checked then
        begin
          AddSelection(Items[i], -1, i);
          if SelectionCount = 1 then
            IdxItem := i;
        end;
      end;
    end;
    CalcView(True);
    Invalidate;
    ExtraSelected;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasSelCheckExecute(Sender: TObject);
begin
  SelectExtrasCheckedOrUnchecked(True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasSelUncheckExecute(
  Sender: TObject);
begin
  SelectExtrasCheckedOrUnchecked(False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.CheckOrUncheckExtrasSelected(Check: Boolean);
var
  i, iData: Integer;
  Extra: TMovieExtra;
  Found: Boolean;
begin
  if FCurrentMovie = nil then
    Exit;
  Found := False;
  for i := 0 to ThumbsViewer.SelectionCount - 1 do
  begin
    iData := ThumbsViewer.GetSelection(i);
    if iData > 0 then
    begin
      Extra := TMovieExtra(Pointer(iData));
      if Extra.bChecked <> Check then
      begin
        if not Found then
          ExtrasBeforeChange(Self);
        Extra.bChecked := Check;
        Found := True;
      end;
    end;
  end;
  ThumbsViewer.Invalidate;
  ExtraSelected;
  if Found then
    ExtrasChange(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasCheckExecute(Sender: TObject);
begin
  CheckOrUncheckExtrasSelected(True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasUncheckExecute(Sender: TObject);
begin
  CheckOrUncheckExtrasSelected(False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasSortExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasGroupExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameExtras.ActionExtrasRenumberExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  MainWindow.StoreSelectedState;
  try
    Application.CreateForm(TExtrasRenumberWin, ExtrasRenumberWin);
    try
      ExtrasBeforeChange(Self);
      ToolbarImages.GetIcon(Ord(ICON_RENUMBER), ExtrasRenumberWin.Icon);
      StopThumbThread;
      if ExtrasRenumberWin.Execute(FCurrentMovie, MainWindow.CurrentMovieList) = mrOk then
      begin
        ThumbsViewerStart;
        ExtrasChange(Self);
      end else
        StartThumbThread;
    finally
      ExtrasRenumberWin.Release;
      ExtrasRenumberWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.


