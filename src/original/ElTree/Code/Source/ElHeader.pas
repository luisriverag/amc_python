{$D-}
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2001, EldoS                   }
{                                                    }
{====================================================}

{$I ElPack.inc}

(*

Version History

03/10/2001

  Fixed possible AVs that could happen when image list is removed.

  Minor optimizations and readness improvements.

01/11/2001

   Fixed the bug in UpdateSection, which incorrectly invalidated sections when
   parent tree was horizontally scrolled

12/02/2000

   WrapCaptions property added. Now header captions can be multiline and wrapped
   automatically, if they don't fit into width 

   ImageForm support added

10/06/2000

   Deletion of the section could cause AV. Fixed. 

09/22/2000

   Fixed Section hints showing to be changed when cursor moves to another section

09/20/2000

   ElHeaderSection.AutoSize property added.
   
08/09/2000

   Lookup focus returning caused an exception ("can't focus hidden window"). Fixed. 

07/25/2000

  Lookup improved. Now focus is returned to the previously focused control.

07/09/2000

  Fixed lookup, expandable and filter sections to react on sign clicks when the
  heaader is scrolled.
  Changed section drawing to make offset of caption for non-resizable sections.  

*)

unit ElHeader;

interface

{$I elpack.inc}
{$R ElHeader.res}                  
{$B-}
{$RANGECHECKS OFF}
{$ALIGN ON}
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
{$IFDEF ELPACK_COMPLETE}
{$ifdef SUPPORT_STORAGE}
  ElIni,
{$endif}
  ElImgFrm,
  ElACtrls,
{$ENDIF}
{$IFDEF VCL_4_USED}
  ImgList,
{$ENDIF}
  ElTools,
  ElList,
  Menus,
  StdCtrls,
  ElVCLUtils, 
  ExtCtrls;

type
  TElSectionStyle = (ElhsText, ElhsOwnerDraw, ElhsPictureOnly);

  TElSSortMode = (hsmNone, hsmAscend, hsmDescend);

  TElSAlignment = (hsaLeft, hsaCenter, hsaRight);

  TElHResizingStates = (trsBegin, trsMove, trsEnd);

  TSectionChangeMode = (scmCaption, scmFieldName, scmFieldType,
    scmAlign, scmStyle, scmEditable, scmPassword);

  TElSectionPart = (espResizeArea, espText, espExpandSign, espLookupSign, espFilterSign);

  TAdjustCondition = (acAll,acAutoSizedOnly);

  TFieldTypes = (
    sftCustom, // custom field
    sftText, // text field
    sftNumber, // Integer numbers
    sftFloating, // Floating numbers
    sftDateTime, // DateTime
    sftDate, // Date
    sftTime, // Time
    sftPicture, // Picture
    sftEnum,  // enumeration
    sftBLOB,  // BLOB data
    sftUndef, // undefined field
    sftBool,   // boolean field
    sftCurrency // currency
    );

  EElError = class(Exception)
  end;

type
  TCustomElHeader = class;
  TElHeaderSection = class;

{$ifndef SUPPORT_STORAGE}
  TElIniFile = class end;
{$endif}

  TElHeaderSectionEvent = procedure(Sender : TCustomElHeader; Section : TElHeaderSection) of object;

  TElHeaderLookupEvent = procedure(Sender : TObject; Section : TElHeaderSection; var Text : string) of object;
  TElHeaderLookupDoneEvent = procedure(Sender : TObject;
    Section : TElHeaderSection;
    Text : string;
    Accepted : boolean) of object;

  TElHeaderSection = class(TPersistent)
  private
    FFilterIsActive : Boolean;
    FFilterEnabled : Boolean;
    FHint : string;

    FTextLayout : TTextLayout;
    FUseMainStyle : Boolean;
    FFontColor : TColor;
    FColor : TColor;
    FParentColor : Boolean;
    FLookupEnabled : boolean;
    FExpandable : Boolean;
    FExpanded : Boolean;
    FParentSection : TElHeaderSection;
    FParentIdx : integer;
    FPopupMenu : TPopupMenu;
    FPopupName : string;
    FResizable : Boolean;
    FClickSelect : Boolean;
    FProtected : Boolean;
    FFieldName : string;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FIntTag,
    FTag : integer;
    FVisible : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FText : string;
    FData : pointer;
    FOwner : TCustomElHeader;
    FLookupHist : TStringList;
    FAutoSize   : boolean;

    FStickySize : single;
    ASaveSize : integer;
    FOnResize: TNotifyEvent;
    FShowSortMark: Boolean;
    procedure SetWidth(value : integer);
    procedure SetShowSortMark(Value: Boolean);
    function GetWidth : integer;
    function GetLeft  : integer;
    function GetRight : integer;
    procedure SetMaxWidth(value : integer);
    procedure SetMinWidth(value : integer);
    procedure SetText(value : string);
    procedure SetStyle(value : TElSectionStyle);
    procedure SetSortMode(value : TElSSortMode);
    procedure SetAlignment(value : TElSAlignment);
    procedure SetVisible(value : boolean);

    function GetIndex : integer;
    function GetPosition : Integer;
    procedure SetImageIndex(newValue : Integer);
    procedure SetProtected(newValue : Boolean);
    procedure SetExpandable(newValue : Boolean);
    procedure SetExpanded(newValue : Boolean);
    procedure SetParentSection(newValue : TElHeaderSection);
    procedure SetPopupMenu(newValue : TPopupMenu);
    function GetVisible : boolean;
    procedure SetLookupEnabled(newValue : boolean);
    procedure SetParentColor(newValue : Boolean);
    procedure SetColor(newValue : TColor);
    procedure SetFontColor(newValue : TColor);
    procedure SetUseMainStyle(newValue : Boolean);
    procedure SetTextLayout(newValue : TTextLayout);
    procedure SetFilterEnabled(newValue : Boolean);
    procedure SetFilterIsActive(newValue : Boolean);
    procedure SetLookupList(newValue : TStringList);
    procedure SetAutoSize(newValue : boolean);
  protected
    procedure SetFieldName(newValue : string); virtual;
    procedure SetFieldType(newValue : TFieldTypes); virtual;
    procedure SetEditable(newValue : boolean); virtual;
    procedure SetResizable(newValue : boolean); virtual;
    procedure SetSaveSize(newValue : integer);
    property FSaveSize : integer read ASaveSize write SetSaveSize;
    function GetOwner : TPersistent; override;
    property OnResize : TNotifyEvent read FOnResize write FOnResize;
  public
    constructor Create(AOwner : TCustomElHeader);
    destructor Destroy; override;
    procedure UpdateSection;
    procedure Assign(source : TPersistent); override;
    property Index : integer read GetIndex;
    property Left : integer read GetLeft;
    property Right : integer read GetRight;
    property Position : Integer read GetPosition; { Public }
    property Data : pointer read FData write FData;
    property Owner: TCustomElHeader read FOwner;
  published
    property Text : string read FText write SetText;
    property Style : TElSectionStyle read FStyle write SetStyle;
    property Width : integer read GetWidth write SetWidth;
    property MaxWidth : integer read FMaxWidth write SetMaxWidth;
    property MinWidth : integer read FMinWidth write SetMinWidth;
    property SortMode : TElSSortMode read FSortMode write SetSortMode;
    property AllowClick : boolean read FAllowClick write FAllowClick;
    property Alignment : TElSAlignment read FAlignment write SetAlignment;
    property PictureAlign : TElSAlignment read FPicAlign write FPicAlign;
    property Visible : boolean read GetVisible write SetVisible;
    property ImageIndex : Integer read FImageIndex write SetImageIndex; { Published }
    property FieldName : string read FFieldName write SetFieldName; { Public }
    property FieldType : TFieldTypes read FFieldType write SetFieldType; { Public }
    property Editable : Boolean read FEditable write SetEditable; { Public }
    property Password : Boolean read FProtected write SetProtected default False; { Public }
    property Resizable : Boolean read FResizable write SetResizable; { Public }
    property ClickSelect : Boolean read FClickSelect write FClickSelect; { Public }
    property Expandable : Boolean read FExpandable write SetExpandable;
    property Expanded : Boolean read FExpanded write SetExpanded;
    property ParentSection : TElHeaderSection read FParentSection write SetParentSection;
    property PopupMenu : TPopupMenu read FPopupMenu write SetPopupMenu;
    property LookupEnabled : boolean read FLookupEnabled write SetLookupEnabled;
    property LookupHistory : TStringList read FLookupHist write SetLookupList;
    property ParentColor : Boolean read FParentColor write SetParentColor;
    property Color : TColor read FColor write SetColor;
    property FontColor : TColor read FFontColor write SetFontColor;
    property UseMainStyle : Boolean read FUseMainStyle write SetUseMainStyle;
    property TextLayout : TTextLayout read FTextLayout write SetTextLayout;
    property FilterEnabled : Boolean read FFilterEnabled write SetFilterEnabled; { Public }
    property FilterIsActive : Boolean read FFilterIsActive write SetFilterIsActive; { Published }
    property Hint : string read FHint write FHint;
    property AutoSize : boolean read FAutoSize write SetAutoSize;
    property ShowSortMark: Boolean read FShowSortMark write SetShowSortMark;
  end;

  TElHeaderSections = class(TPersistent)
  private
    FList : TElList;
    function GetCount : integer;
    function GetSectionsOrder : string;
    procedure SetSectionsOrder(newValue : string);
  protected
    FOwner : TCustomElHeader;
    function GetSectionByIntTag(IntTag : integer) : TElHeaderSection; virtual;
    function GetSection(index : integer) : TElHeaderSection; virtual;
    procedure SetSection(index : integer; Section : TElHeaderSection); virtual;
    function GetSectionByPos(index : integer) : TElHeaderSection; virtual;
    function CreateSection : TElHeaderSection; virtual;
    procedure WriteData(Stream : TStream); virtual;
    procedure IntReadData(Stream : TStream; ClearCurrent : boolean); virtual;
    procedure ReadData(Stream : TStream); virtual;
    procedure FrameReadData(Stream : TStream); virtual;
    procedure DefineProperties(Filer : TFiler); override;
    function LastVisibleSection : TElHeaderSection;
    function GetPrevVisibleSection(Section : TElHeaderSection) : TElHeaderSection;
    function FindSection(tag : integer) : TElHeaderSection; virtual;
    function GetOwner : TPersistent; override;
  public
    constructor Create(AOwner : TCustomElHeader);
    destructor Destroy; override;
    procedure Clear;

    procedure Assign(source : TPersistent); override;
    function AddSection : TElHeaderSection;
    function InsertSection(index : integer) : TElHeaderSection;
    procedure DeleteSection(Section : TElHeaderSection);
    procedure MoveSection(Section : TElHeaderSection; NewPos : integer);
    procedure LoadFromStream(Stream : TStream);
    procedure SaveToStream(Stream : TStream);
    procedure SaveToFile(FileName : string);
    procedure LoadFromFile(FileName : string);

    property Owner : TCustomElHeader read FOwner;
    property SectionsOrder : string read GetSectionsOrder write SetSectionsOrder; { Protected }
    property Count : integer read GetCount;
    property ItemByPos[Index : integer] : TElHeaderSection read GetSectionByPos;
    property Item[Index : integer] : TElHeaderSection read GetSection write SetSection; default;
  end;

  TMeasureSectionEvent = procedure(Sender: TObject; Section : TElHeaderSection; var Size: TPoint) of object;

  TElSectionRedrawEvent = procedure(Sender : TCustomElHeader;
    Section : TElHeaderSection; R : TRect; Pressed : boolean) of object;
  TElSectionResizingEvent = procedure(Sender : TCustomElHeader;
    Section : TElHeaderSection; State : TElHResizingStates; Width : integer) of object;
  TElSectionMoveEvent = procedure(Sender : TCustomElHeader;
    Section : TElHeaderSection; OldPos, NewPos : integer) of object;
  TPictureNeededEvent = procedure(Sender : TCustomElHeader; Section : TElHeaderSection; var ImageIndex : integer) of object;
  TSectionChangeEvent = procedure(Sender : TCustomElHeader; Section : TElHeaderSection; Change : TSectionChangeMode) of object;

  TCustomElHeader = class(TCustomControl)
  private
    FHPos : Integer;
    FInvertSortArrows : Boolean;
    FFlat : Boolean;
    FActiveFilterColor : TColor;
    FOnFilterCall : TElHeaderSectionEvent;
    FOnSectionAutoSize : TElHeaderSectionEvent;
    FFilterColor : TColor;
    FLockHeight : Boolean;
    FRightAlignedText : Boolean;
    FRightAlignedOrder : Boolean;
    FStickySections : Boolean;
    FMoveOnDrag : Boolean;
    FImages : TImageList;

    FImageChangeLink : TChangeLink;
    FSections : TElHeaderSections;
    FTracking : boolean;
    FAllowDrag : boolean;
    FPainting : boolean;
    FAscBmp,
      FDescBmp,
      FLeftBmp,
      FRightBmp,
      FPointBmp,
      DragBmp,
      DragBmpMask : TBitmap;
    DragRect : TRect;
    FDragCoord : TPoint;
    FLookup : TComboBox;
    FPressCoord : TPoint;
    FPressed : boolean;
    FPressedItem : TElHeaderSection;
    FHintSection,
    FLookupSection,
      FTrackSection : TElHeaderSection;
    FResizing : boolean;
    FResizeSection : TElHeaderSection;
    FDropSrc,
      FDropTrg : TElHeaderSection;
    FLineDC : HDC;
    FHeaderLine : integer;
    FLineTab : integer;
    FResizeOnDrag : boolean;
    FHeaderLineVis : boolean;
    FIgnoreLookupChange : boolean;
    FDoingLookup : boolean;
    FFocusedCtl : THandle;
    LoadingCount : integer;

    FInStick : boolean;
    FOldWidth : integer;
    FUpdateCount: integer;

    FOnSectionClick : TElHeaderSectionEvent;
    FOnSectionResize : TElHeaderSectionEvent;
    FOnSectionDraw : TElSectionRedrawEvent;
{$IFNDEF VCL_4_USED}
    FOnResize : TNotifyEvent;
{$ENDIF}
    FOnSectionResizing : TElSectionResizingEvent;
    FOnSectionDelete : TElHeaderSectionEvent;
    FOnSectionMove : TElSectionMoveEvent;
    FOnVisibleChange : TElHeaderSectionEvent;
    FOnPictureNeeded : TPictureNeededEvent;
    FOnSectionChange : TSectionChangeEvent;
    FOnSectionCreate : TElHeaderSectionEvent;
    FOnHeaderLookup : TElHeaderLookupEvent;
    FOnHeaderLookupDone : TElHeaderLookupDoneEvent;
    FOnSectionExpand : TElHeaderSectionEvent;
    FOnSectionCollapse : TElHeaderSectionEvent;
    FOnMeasureSection  : TMeasureSectionEvent;
    procedure DrawLine;
    procedure AllocateLineDC;
    procedure ReleaseLineDC;
    function GetColumnsWidth : integer;
    procedure InvalidateRight(value : integer);
    procedure SetTracking(newValue : boolean);
    procedure CMDrag(var Message : TCMDrag); message CM_DRAG;
    procedure RedrawSection(Canvas : TCanvas; Section : TElHeaderSection; R : TRect);
    procedure RedrawSections;
    procedure SetSections(value : TElHeaderSections);
    procedure SetImages(newValue : TImageList);
    procedure OnImageListChange(Sender : TObject);
    procedure GetDragImage(XPos : Integer);
    procedure WMEraseBkgnd(var Msg : TWMEraseBkgnd); message WM_ERASEBKGND;
{$ifdef SUPPORT_STORAGE}
    procedure SetStorage(newValue : TElIniFile);
{$ENDIF}
    procedure EditExit(Sender : TObject);
    procedure EditKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
    procedure EditKeyUp(Sender : TObject; var Key : Word; Shift : TShiftState);
    procedure EditChange(Sender : TObject);
    procedure WMRButtonDown(var Msg : TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMSize(var Msg : TWMSize); message WM_SIZE;
    procedure SetStickySections(newValue : Boolean);
    procedure AdjustHeaderHeight;
    procedure AdjustStickySize(Caller : TElHeaderSection);
    procedure WMRButtonUp(var Msg : TWMRButtonUp); message WM_RBUTTONUP;
    function IsLoading : Boolean;
    procedure SetRightAlignedText(newValue : Boolean);
    procedure SetRightAlignedOrder(newValue : Boolean);
    procedure SetLockHeight(newValue : Boolean);
    procedure SetFilterColor(newValue : TColor);
    procedure WMLButtonDblClk(var Msg : TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure SetActiveFilterColor(newValue : TColor);
    procedure SetFlat(newValue : Boolean);
    procedure CMHintShow(var Msg : TMessage); message CM_HINTSHOW;
    procedure CMSysColorChange(var Msg: TMessage); message CM_SYSCOLORCHANGE;
    function GetIsDesigning : Boolean;
    procedure SetIsDesigning(newValue : Boolean);
    procedure SetInvertSortArrows(newValue : Boolean);
    procedure WMPaint(var Msg : TWMPaint); message WM_PAINT;
    procedure SetLeftPos(newValue : Integer);
{$IFDEF ELPACK_COMPLETE}
    procedure ImageFormChange(Sender : TObject);
    procedure SetImageForm(newValue : TElImageForm);
{$ENDIF}
    procedure CMExit(var Msg : TCMExit); message CM_EXIT;
  protected
      { Protected declarations }
    procedure Notification(AComponent : TComponent; Operation : TOperation); override;
    function  CreateSections : TElHeaderSections; virtual;
    function  InResizeArea(X : integer; var HitSection : TElHeaderSection) : boolean; virtual;

    procedure WMLButtonDown(var Message : TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message : TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Message : TWMMouseMove); message WM_MOUSEMOVE;
    procedure CMMouseEnter(var Message : TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message : TMessage); message CM_MOUSELEAVE;
    procedure Paint; override;
{$IFDEF VCL_4_USED}
    procedure Resize; override;
{$ELSE}
    procedure Resize; dynamic;
{$ENDIF}
    function DoGetPicture(Section : TElHeaderSection) : integer; virtual;
    procedure DoVisChanged(Section : TElHeaderSection); virtual;
    procedure DoSectionDelete(Section : TElHeaderSection); virtual;
    procedure DoSectionMove(Section : TElHeaderSection; OldPos, NewPos : integer); virtual;
    procedure DoSectionResizing(Section : TElHeaderSection; State : TElHResizingStates; NewWidth : integer); virtual;
    procedure DoSectionResize(Section : TElHeaderSection); virtual;
    procedure DoSectionClick(Section : TElHeaderSection); virtual;
    procedure DoSectionDraw(Section : TElHeaderSection; R : TRect; Pressed : boolean); virtual;
    procedure DoNotifySectionChange(Section : TElHeaderSection; Change : TSectionChangeMode); virtual;
    procedure DoSectionExpandEvent(Section : TElHeaderSection); virtual;
    procedure DoSectionCollapseEvent(Section : TElHeaderSection); virtual;
    procedure DoSectionCreate(Section : TElHeaderSection); virtual;
    procedure DoSectionLookupEvent(Section : TElHeaderSection; var Text : string); virtual;
    procedure DoSectionLookupDoneEvent(Section : TElHeaderSection; Text : string; Accepted : boolean); virtual;
    procedure TriggerSectionAutoSizeEvent(Section : TElHeaderSection); virtual;
    procedure TriggerFilterCallEvent(Section : TElHeaderSection); virtual;
    procedure TriggerMeasureSectionEvent(Section : TElHeaderSection; var Size: TPoint); virtual;

    procedure OnFontChange(Sender : TObject);
    function GetResizableWidth : integer;
    procedure CreateParams(var Params : TCreateParams); override;

    property SectionsWidth : integer read GetColumnsWidth;
    property Sections : TElHeaderSections read FSections write SetSections;
    property ResizeOnDrag : boolean read FResizeOnDrag write FResizeOnDrag;
    property Tracking : boolean read FTracking write SetTracking;
    property AllowDrag : boolean read FAllowDrag write FAllowDrag;

    property Images : TImageList read FImages write SetImages; { Published }

    property MoveOnDrag : Boolean read FMoveOnDrag write FMoveOnDrag; { Published }
{$ifdef SUPPORT_STORAGE}
    property StoragePath : string read FStoragePath write FStoragePath;
    property Storage : TElIniFile read FStorage write SetStorage;
{$ELSE}
{$IFDEF ELPACK_COMPLETE}
    property StoragePath : string read FStoragePath write FStoragePath;
    property Storage : TElIniFile read FStorage write FStorage;
{$ENDIF}
{$ENDIF}
    property StickySections : Boolean read FStickySections write SetStickySections;
    property RightAlignedText : Boolean read FRightAlignedText write SetRightAlignedText;
    property RightAlignedOrder : Boolean read FRightAlignedOrder write SetRightAlignedOrder;
    property LockHeight : Boolean read FLockHeight write SetLockHeight; { Protected }
    property FilterColor : TColor read FFilterColor write SetFilterColor; { Protected }
    property ActiveFilterColor : TColor read FActiveFilterColor write SetActiveFilterColor; { Published }
{$IFDEF ELPACK_COMPLETE}
    property ImageForm   : TElImageForm read FImgForm write SetImageForm;
{$ENDIF}
    property OnSectionChange : TSectionChangeEvent read FOnSectionChange
      write FOnSectionChange;
{$IFNDEF VCL_4_USED}
    property OnResize : TNotifyEvent read FOnResize write FOnResize;
{$ENDIF}
    property OnSectionShowHide : TElHeaderSectionEvent read FOnVisibleChange
      write FOnVisibleChange;
    property OnSectionClick : TElHeaderSectionEvent read FOnSectionClick
      write FOnSectionClick;
    property OnSectionResize : TElHeaderSectionEvent read FOnSectionResize
      write FOnSectionResize;
    property OnSectionDraw : TElSectionRedrawEvent read FOnSectionDraw
      write FOnSectionDraw;
    property OnSectionDelete : TElHeaderSectionEvent read FOnSectionDelete
      write FOnSectionDelete;
    property OnSectionResizing : TElSectionResizingEvent read FOnSectionResizing
      write FOnSectionResizing;
    property OnSectionMove : TElSectionMoveEvent read FOnSectionMove
      write FOnSectionMove;
    property OnPictureNeeded : TPictureNeededEvent read FOnPictureNeeded
      write FOnPictureNeeded;
    property OnSectionCreate : TElHeaderSectionEvent read FOnSectionCreate
      write FOnSectionCreate;
    property OnSectionExpand : TElHeaderSectionEvent read FOnSectionExpand
      write FOnSectionExpand;
    property OnSectionCollapse : TElHeaderSectionEvent read FOnSectionCollapse
      write FOnSectionCollapse;
    property OnHeaderLookup : TElHeaderLookupEvent read FOnHeaderLookup
      write FOnHeaderLookup;
    property OnHeaderLookupDone : TElHeaderLookupDoneEvent read FOnHeaderLookupDone
      write FOnHeaderLookupDone;
    property OnMeasureSection  : TMeasureSectionEvent read FOnMeasureSection write FOnMeasureSection;
    
    property OnSectionAutoSize : TElHeaderSectionEvent read FOnSectionAutoSize write FOnSectionAutoSize;
    property OnFilterCall : TElHeaderSectionEvent read FOnFilterCall write FOnFilterCall;
    property Flat : Boolean read FFlat write SetFlat; { Protected }
    property IsDesigning : Boolean read GetIsDesigning write SetIsDesigning;  { Protected }
    property InvertSortArrows : Boolean read FInvertSortArrows write SetInvertSortArrows default False;  { Protected }
  public
      { Public declarations }
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    function GetSectionAt(X, Y : integer) : TElHeaderSection;
    function GetSectionAtEx(X, Y : integer; var SectionPart : TElSectionPart) : TElHeaderSection;
    function GetSectionRect(SectionNum : integer) : TRect;
    function  MeasureSectionWidth(Section : TElHeaderSection; TextWidth : PInteger) : integer;

    property Canvas;
    procedure Loaded; override;
{$IFDEF ELPACK_COMPLETE}
    function Setup: boolean;
{$ENDIF}
{$ifdef SUPPORT_STORAGE}
    procedure Save;
    procedure Restore;
{$ENDIF}
    procedure Update; override;

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure MarkStickySections;
    property LeftPos : Integer read FHPos write SetLeftPos;  { Public }
  end;

  TElHeader = class(TCustomElHeader)
  published
    property Color;
    property ActiveFilterColor;
    property Flat;
    property SectionsWidth;
    property Sections;
    property Tracking;
    property AllowDrag;
    property Align;
    property Enabled;
{$IFDEF VCL_4_USED}
    property Anchors;
    property Action;
    property Constraints;
    property DockOrientation;
    property Floating;
    property BevelKind;
    property DoubleBuffered;
    property DragKind;
{$ENDIF}
//        property FixClick; // Left for future
    property MoveOnDrag;
    property Font;
    property FilterColor;
    property Images;
{$IFDEF ELPACK_COMPLETE}
    property ImageForm;
{$ENDIF}
    property InvertSortArrows;
    property LockHeight;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ResizeOnDrag;
    property RightAlignedText;
    property RightAlignedOrder;
    property ShowHint;
    property StickySections;
{$IFDEF ELPACK_COMPLETE}
    property Storage;
    property StoragePath;
{$ENDIF}
    property Visible;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnSectionClick;
    property OnSectionResize;
    property OnSectionDraw;
    property OnSectionResizing;
    property OnSectionDelete;
    property OnSectionMove;
    property OnSectionShowHide;
    property OnPictureNeeded;
    property OnSectionChange;
    property OnSectionCreate;
    property OnSectionExpand;
    property OnSectionCollapse;
    property OnHeaderLookup;
    property OnHeaderLookupDone;
    property OnSectionAutoSize;
    property OnFilterCall;
{$IFDEF VCL_4_USED}
    property OnStartDock;
    property OnEndDock;
{$ENDIF}
{$IFDEF VCL_5_USED}
    property OnContextPopup;
{$ENDIF}
  end;

implementation

{$IFDEF ELPACK_COMPLETE}
uses
  frmHdrStp;

{$ENDIF}

const
  ResizeWidth = 5;

// =============================================================================

constructor TElHeaderSection.Create;
begin
  inherited Create;
  FStyle := ElhsText;
  FVisible := true;
  FOwner := FOwner;
  FWidth := 120;
  FMinWidth := 0;
  FMaxWidth := 10000;
  FAlignment := hsaLeft;
  FAllowClick := true;
  FResizable := true;
  FClickSelect := true;
  FLookupHist := TStringList.Create;
  FParentColor := True;
  FSaveSize := -1;
  FTextLayout := tlCenter;
  FShowSortMark := true;
end;

procedure TElHeaderSection.UpdateSection;
var
  R : TRect;
begin
  if (not Visible) or (not FOwner.HandleAllocated) then exit;
  FOwner.BeginUpdate;
  try
  R := Rect(Left, 0, Left + FWidth, FOwner.Height - 1);
  OffsetRect(R, -FOwner.FHPos, 0);
  InvalidateRect(FOwner.Handle, @R, false);
  finally
    FOwner.EndUpdate;
  end;
  //FOwner.Refresh;
end;

procedure TElHeaderSection.SetSortMode(value : TElSSortMode);
var
  i : integer;
begin
  if FSortMode = value then exit;
  for i := 0 to FOwner.FSections.Count - 1 do
    FOwner.FSections[i].FSortMode := hsmNone;
  FSortMode := value;
  if AutoSize then
     FOwner.TriggerSectionAutoSizeEvent(Self);
  if (not FOwner.HandleAllocated) then exit;
  if FShowSortMark then
    FOwner.Invalidate;//Repaint;
end;

procedure TElHeaderSection.SetMaxWidth(value : integer);
begin
  if value = FMaxWidth then exit;
  FMaxWidth := value;
  if FWidth > FMaxWidth then Width := FMaxWidth;
end;

procedure TElHeaderSection.SetMinWidth(value : integer);
begin
  if value = FMinWidth then exit;
  FMinWidth := value;
  if FWidth < FMinWidth then Width := FMinWidth;
end;

procedure TElHeaderSection.SetWidth(value : integer);
var
  diff, i, wo, wn : integer;
  HS, LS : TElHeaderSection;

begin
  if (value > FMaxWidth) or (value < FMinWidth) then exit;
  if (not FOwner.FStickySections) or (not Visible) or (FOwner.FInStick) or (FOwner.IsLoading) then
  begin
    FWidth := value;
    if Visible and (not FOwner.FInStick) then
    begin
      FOwner.AdjustHeaderHeight;
      if (FOwner.HandleAllocated) then
        FOwner.Invalidate;
      //FOwner.InvalidateRight(Self.Index);
      //FOwner.Refresh;
    end;
  end
    else if Visible then
  begin
    if Position = FOwner.FSections.Count - 1 then
    begin
      // the last section, do nothing (we can't resize it)
    end
    else
    begin
      wo := FOwner.Width - (Left + FWidth); if wo = 0 then wo := 1;
      wn := FOwner.Width - (Left + Value);
      Ls := nil;
      for i := Position + 1 to FOwner.Sections.Count - 1 do // Iterate
      begin
        HS := FOwner.FSections.ItemByPos[i];
        if HS.Resizable and HS.Visible then
        begin
          HS.FWidth := Round((HS.Width / wo) * wn);
          LS := HS;
        end;
      end; // for
      FWidth := value;
      if (LS <> nil) then
      begin
        diff := FOwner.Width - FOwner.SectionsWidth;
        if diff > 0 then
          LS.FWidth := LS.FWidth + diff;
      end;
      FOwner.AdjustStickySize(Self);
    end;
    FOwner.MarkStickySections;
    if Visible and (not FOwner.FInStick) then
    begin
      FOwner.InvalidateRight(Index);
      //FOwner.Refresh;
    end;
  end;
end;

procedure TElHeaderSection.SetLookupEnabled(newValue : boolean);
begin
  if FLookupEnabled <> newValue then
  begin
    FLookupEnabled := newValue;
    if newValue then
    begin
      FFilterEnabled := false;
      with FOwner do
      begin
        if (Height > 0) and (Height < 17) then Height := 17;
      end;
    end;
    if AutoSize then
       FOwner.TriggerSectionAutoSizeEvent(Self);
    UpdateSection;
  end;
end;

function TElHeaderSection.GetVisible : boolean;
begin
  if FParentSection = nil then
    result := FVisible
  else
    result := FVisible and FParentSection.Visible and FParentSection.Expanded;
end;

procedure TElHeaderSection.SetVisible;
var
  ns, os, j, k, wo, wn, i : integer;
  HS : TElHeaderSection;
begin
  if FVisible <> Value then begin
    FOwner.BeginUpdate;
    try
  if (not FOwner.FStickySections) or ((Self.FParentSection <> nil) and (not FParentSection.Visible)) or (FOwner.FInStick) or (FOwner.IsLoading) then
  begin
    FVisible := value;
    FOwner.AdjustHeaderHeight;
    if (not FOwner.FInStick) and ((ParentSection = nil) or (ParentSection.Visible)) then
    begin
      FOwner.InvalidateRight(Index);
      //FOwner.Refresh;
    end;
  end
  else
  begin
    if Value then
    begin
      ns := Width;
      os := 0;
    end
    else
    begin
      ns := 0;
      os := Width;
    end;
    FVisible := value;
    wo := FOwner.Width - (Left + os);
    wn := FOwner.Width - (Left + ns);
    if Position = FOwner.FSections.Count - 1 then
    begin
      j := 0;
      k := FOwner.Sections.Count - 2;
    end
    else
    begin
      j := Position + 1;
      k := FOwner.Sections.Count - 1;
    end;
    for i := j to k do // Iterate
    begin
      HS := FOwner.FSections.ItemByPos[i];
      if HS.Resizable then
      begin
        HS.FWidth := Round((HS.Width / wo) * wn);
      end;
    end; // for
    FOwner.AdjustStickySize(Self);
    FOwner.MarkStickySections;
  end;
  if (FOwner.HandleAllocated) then
    FOwner.Invalidate;//Repaint;
  FOwner.DoVisChanged(self);
    finally
      FOwner.EndUpdate;
    end;
  end;
end;

function TElHeaderSection.GetWidth : integer;
begin
  result := FWidth;
  //if FOwner.FLockedSection <> self then result := FWidth else result := 0;
end;

function TElHeaderSection.GetLeft : integer;
var
  ind : integer;
begin
  ind := FOwner.Sections.FList.IndexOf(self);
  if ind = 0 then
    result := 0
  else
    result := TElHeaderSection(FOwner.FSections.FList[ind - 1]).Right;
end;

function TElHeaderSection.GetRight : integer;
var
  i : integer;
  ind : integer;
begin
  ind := FOwner.FSections.FList.IndexOf(self);
  if ind = 0 then
    i := 0
  else
    i := TElHeaderSection(FOwner.FSections.FList[ind - 1]).Right;
  if Visible then
    result := i + FWidth
  else
    result := i;
end;

procedure TElHeaderSection.SetText(value : string);
begin
  if FText = value then exit;
  FText := value;
  if AutoSize then
     FOwner.TriggerSectionAutoSizeEvent(Self);
  FOwner.AdjustHeaderHeight;
  if FStyle = ElhsText then
     UpdateSection;
  FOwner.DoNotifySectionChange(self, scmCaption);
end;

procedure TElHeaderSection.SetStyle(value : TElSectionStyle);
begin
  if FStyle = value then exit;
  FStyle := value;
  FOwner.DoNotifySectionChange(self, scmStyle);
  UpdateSection;
end;

procedure TElHeaderSection.SetAlignment(value : TElSAlignment);
begin
  if FAlignment = value then exit;
  FAlignment := value;
  FOwner.DoNotifySectionChange(self, scmAlign);
  UpdateSection;
end;

function TElHeaderSection.GetIndex : integer;
begin
  result := FTag;
end;

procedure TElHeaderSection.Assign(source : TPersistent);
var
  THS : TElHeaderSection;
begin
  if Source is TElHeaderSection then
  begin
    THS := TElHeaderSection(source);
    FHint := THS.Hint;
    FVisible := THS.FVisible;
    FStyle := THS.FStyle;
    FText := THS.FText;
    FWidth := THS.FWidth;
    FMinWidth := THS.FMinWidth;
    FMaxWidth := THS.FMaxWidth;
    FSortMode := THS.FSortMode;
    FAllowClick := THS.FAllowClick;
    FAlignment := THS.FAlignment;
    FExpandable := THS.FExpandable;
    FExpanded := THS.FExpanded;
    if THS.FParentSection = nil then
      FParentSection := nil
    else
      FParentSection := FOwner.Sections.Item[THS.FParentSection.Index];
    FPopupMenu := THS.PopupMenu;
    FLookupEnabled := THS.FLookupEnabled;
    FUseMainStyle := THS.FUseMainStyle;
    FTextLayout := THS.FTextLayout;
    FFilterEnabled := THS.FFilterEnabled;
    FParentColor := THS.FParentColor;
    FFontColor := THS.FFontColor;
    FColor := THS.FColor;
    FAutoSize := THS.FAutoSize;
    FHint := THS.FHint;
    FPicAlign := THS.FPicAlign;
    FResizable := THS.FResizable;
    FClickSelect := THS.FClickSelect;
    FProtected := THS.FProtected;
    FImageIndex := THS.FImageIndex;
    FEditable := THS.FEditable;
  end
  else
    inherited;
end;

function TElHeaderSection.GetPosition : Integer;
{ Returns the value of data member FPosition. }
begin
  result := -1;
  if FOwner <> nil then result := FOwner.FSections.FList.IndexOf(self);
end; { GetPosition }

procedure TElHeaderSection.SetImageIndex(newValue : Integer);
{ Sets data member FImageIndex to newValue. }
begin
  if (FImageIndex <> newValue) then
  begin
    FImageIndex := newValue;
    if AutoSize then
       FOwner.TriggerSectionAutoSizeEvent(Self);
    UpdateSection;
  end; { if }
end; { SetImageIndex }

procedure TElHeaderSection.SetResizable(newValue : boolean);
begin
  FResizable := newValue;
  if Assigned(FOwner) then
    if FOwner.FStickySections then FOwner.SetStickySections(true);
end;

procedure TElHeaderSection.SetSaveSize(newValue : integer);
begin
  ASaveSize := newValue;
end;

procedure TElHeaderSection.SetEditable(newValue : boolean);
begin
  if FEditable <> newValue then
  begin
    FEditable := newValue;
    FOwner.DoNotifySectionChange(self, scmEditable);
  end;
end;

procedure TElHeaderSection.SetFieldName(newValue : string);
{ Sets data member FFieldName to newValue. }
begin
  if (FFieldName <> newValue) then
  begin
    FFieldName := newValue;
    FOwner.DoNotifySectionChange(self, scmFieldName);
  end; { if }
end; { SetFieldName }

procedure TElHeaderSection.SetFieldType(newValue : TFieldTypes);
{ Sets data member FFieldType to newValue. }
begin
  if (FFieldType <> newValue) then
  begin
    FFieldType := newValue;
    FOwner.DoNotifySectionChange(self, scmFieldType);
  end; { if }
end; { SetFieldType }

procedure TElHeaderSection.SetProtected(newValue : Boolean);
{ Sets data member FProtected to newValue. }
begin
  if (FProtected <> newValue) then
  begin
    FProtected := newValue;
    FOwner.DoNotifySectionChange(self, scmPassword);
  end; { if }
end; { SetProtected }

procedure TElHeaderSection.SetExpandable(newValue : Boolean);
var
  i : integer;
  b : boolean;
begin
  if (FExpandable <> newValue) then
  begin
    b := false;
    FExpandable := newValue;
    if not FExpandable then
      for i := 0 to FOwner.FSections.Count - 1 do
      begin
        if TElHeaderSection(FOwner.FSections.FList[i]).FParentSection = Self then
        begin
          TElHeaderSection(FOwner.FSections.FList[i]).FParentSection := nil;
          b := true;
        end;
      end;
      if AutoSize then
         FOwner.TriggerSectionAutoSizeEvent(Self);
    if b and (not (csDestroying in FOwner.ComponentState)) and (FOwner.HandleAllocated) then
      FOwner.Invalidate;//Repaint;
  end; {if}
end;

procedure TElHeaderSection.SetExpanded(newValue : Boolean);
begin
  if (FExpanded <> newValue) and Expandable then
  begin
    if (FExpandable and newValue) or (not newValue) then
    begin
      FExpanded := newValue;
      if (FOwner.HandleAllocated) then
        FOwner.Invalidate;//Repaint;
    end;
  end; {if}
end;

procedure TElHeaderSection.SetParentSection(newValue : TElHeaderSection);
var
  S : TElHeaderSection;
begin
  if (FParentSection <> newValue) then
  begin
    S := newValue;
    while S <> nil do
    begin
      if S = Self then exit;
      S := S.FParentSection;
    end;
    FParentSection := newValue;
    FOwner.DoVisChanged(Self);
    FOwner.AdjustHeaderHeight;
    if (FOwner.HandleAllocated) then
      FOwner.Invalidate;//Repaint;
  end; {if}
end;

procedure TElHeaderSection.SetPopupMenu(newValue : TPopupMenu);
begin
  if (FPopupMenu <> newValue) then
  begin
    FPopupMenu := newValue;
    FPopupName := FPopupMenu.Name;
  end; {if}
end;

procedure TElHeaderSection.SetParentColor(newValue : Boolean);
begin
  if (FParentColor <> newValue) then
  begin
    FParentColor := newValue;
    UpdateSection;
  end; {if}
end;

procedure TElHeaderSection.SetColor(newValue : TColor);
begin
  if (FColor <> newValue) then
  begin
    FColor := newValue;
    ParentColor := false;
    UpdateSection;
  end; {if}
end;

procedure TElHeaderSection.SetFontColor(newValue : TColor);
begin
  if (FFontColor <> newValue) then
  begin
    FFontColor := newValue;
    ParentColor := false;
    UpdateSection;
  end; {if}
end;

procedure TElHeaderSection.SetUseMainStyle(newValue : Boolean);
begin
  if (FUseMainStyle <> newValue) then
  begin
    FUseMainStyle := newValue;
    if Assigned(FOwner.Parent) and (FOwner.Parent.HandleAllocated) then
      FOwner.Parent.Invalidate;//Repaint;
  end; {if}
end;

procedure TElHeaderSection.SetTextLayout(newValue : TTextLayout);
begin
  if (FTextLayout <> newValue) then
  begin
    FTextLayout := newValue;
    UpdateSection;
  end; {if}
end;

procedure TElHeaderSection.SetFilterEnabled(newValue : Boolean);
begin
  if (FFilterEnabled <> newValue) then
  begin
    FFilterEnabled := newValue;
    if newValue then
    begin
      FLookupEnabled := false;
      with FOwner do
      begin
        if (Height > 0) and (Height < 17) then Height := 17;
      end;
    end;
    if AutoSize then
       FOwner.TriggerSectionAutoSizeEvent(Self);
    UpdateSection;
  end; { if }
end; { SetFilterEnabled }

procedure TElHeaderSection.SetAutoSize;
begin
  if FAutoSize <> newValue then
  begin
    FAutoSize := newValue;
    if newValue then
       FOwner.TriggerSectionAutoSizeEvent(Self);
  end;
end;

procedure TElHeaderSection.SetLookupList(newValue : TStringList);
begin
  FLookupHist.Assign(newValue);
end;

procedure TElHeaderSection.SetFilterIsActive(newValue : Boolean);
{ Sets data member FFilterApplied to newValue. }
begin
  if (FFilterIsActive <> newValue) then
  begin
    FFilterIsActive := newValue;
    if FFilterEnabled then UpdateSection;
  end; { if }
end; { SetFilterApplied }

function TElHeaderSection.GetOwner : TPersistent; { protected }
begin
  result := FOwner.Sections;
end; { GetOwner }

destructor TElHeaderSection.Destroy;
begin
  Expandable := false;
  FLookupHist.Free;
  inherited;
end;

procedure TElHeaderSection.SetShowSortMark(Value: Boolean);
begin
  if FShowSortMark <> Value then
  begin
    FShowSortMark := Value;
    if Self.SortMode <> hsmNone then
      UpdateSection; 
  end;
end;

// =============================================================================

constructor TElHeaderSections.Create;
begin
  inherited Create;
  FOwner := AOwner;
  FList := TElList.Create;
end;

destructor TElHeaderSections.Destroy;
begin
  Clear;
  FList.Free;
  inherited destroy;
end;

procedure TElHeaderSections.Clear;
begin
  while FList.Count > 0 do
  begin
    TElHeaderSection(FList[0]).Free;
    FList.Delete(0);
  end;
end;

procedure TElHeaderSections.DefineProperties(Filer : TFiler);
begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', FrameReadData, WriteData, true);
end;

function TElHeaderSections.CreateSection : TElHeaderSection;
begin
  result := TElHeaderSection.Create(FOwner);
end;

function TElHeaderSections.AddSection : TElHeaderSection;
begin
  result := InsertSection(FList.Count);
end;

function TElHeaderSections.InsertSection(index : integer) : TElHeaderSection;
var
  i : integer;
begin
  FOwner.BeginUpdate;
  try
  result := CreateSection;
  i := 0;
  while FindSection(i) <> nil do
    inc(i);
  Result.FTag := i;
  Result.FIntTag := Integer(Pointer(result));
  while Self.GetSectionByIntTag(Result.FIntTag) <> nil do
    inc(Result.FIntTag);
  Result.FOwner := FOwner;
  FList.Insert(index, result);
  FOwner.InvalidateRight(i);
  FOwner.DoSectionCreate(result);
  finally
    FOwner.EndUpdate;
  end;
end;

procedure TElHeaderSections.DeleteSection(Section : TElHeaderSection);
var
  i : integer;
begin
  FOwner.BeginUpdate;
  try
  if Section = nil then raise EElError.Create('Invalid section');
  FList.Remove(Section);
  for i := 0 to FList.Count - 1 do
    TElHeaderSection(FList[i]).FTag := i;
  FOwner.DoSectionDelete(Section);
  Section.Free;
  if (FOwner.HandleAllocated) then
    FOwner.Invalidate;
  finally
    FOwner.EndUpdate;
  end;
end;

procedure TElHeaderSections.MoveSection(Section : TElHeaderSection; NewPos : integer);
var
  i : integer;
begin
  FOwner.BeginUpdate;
  try
  i := FList.IndexOf(Section);
  FList.Move(i, NewPos);
  FOwner.DoSectionMove(TElHeaderSection(FList[i]), i, NewPos);
  if (FOwner.HandleAllocated) then
    FOwner.Invalidate;
  finally
    FOwner.EndUpdate;
  end;
end;

function TElHeaderSections.GetCount : integer;
begin
  result := FList.Count;
end;

procedure TElHeaderSections.SetSection(index : integer; Section : TElHeaderSection);
begin

end;

function TElHeaderSections.GetSectionByIntTag(IntTag : integer) : TElHeaderSection;
var
  i, j : integer;
begin
  j := FList.Count - 1;
  for i := 0 to j do
    if TElHeaderSection(FList[i]).FIntTag = IntTag then
    begin
      result := TElHeaderSection(FList[i]);
      exit;
    end;
  result := nil;
end;

function TElHeaderSections.GetSection;
begin
  result := FindSection(index);
end;

function TElHeaderSections.GetSectionByPos;
begin
  result := TElHeaderSection(FList[index]);
end;

type

  PSectionData = ^TSectionData;
  TSectionData = record
    FFakeProperty1 : Integer;
    FLookupEnabled : boolean;
    FParentIdx : integer;
    FExpandable : Boolean;
    FExpanded : Boolean;
    FVisible : boolean;
    FClickSel : boolean;
    FResizable : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FIntTag,
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
    FParentColor : boolean;
    FColor, FFontColor : TColor;
    FFilterEnabled : boolean;
    FTextLayout : TTextLayout;
    FUseMainStyle : boolean;
    FAutoSize     : boolean;
  end;

  P8aSectionData = ^T8aSectionData;
  T8aSectionData = record
    FFakeProperty1 : Integer;
    FLookupEnabled : boolean;
    FParentIdx : integer;
    FExpandable : Boolean;
    FExpanded : Boolean;
    FVisible : boolean;
    FClickSel : boolean;
    FResizable : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
    FParentColor : boolean;
    FColor, FFontColor : TColor;
    FFilterEnabled : boolean;
    FTextLayout : TTextLayout;
    FUseMainStyle : boolean;
    FAutoSize     : boolean;
  end;

  P8SectionData = ^T8SectionData;
  T8SectionData = record
    FFakeProperty1 : Integer;
    FLookupEnabled : boolean;
    FParentIdx : integer;
    FExpandable : Boolean;
    FExpanded : Boolean;
    FVisible : boolean;
    FClickSel : boolean;
    FResizable : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
    FParentColor : boolean;
    FColor, FFontColor : TColor;
    FFilterEnabled : boolean;
    FTextLayout : TTextLayout;
    FUseMainStyle : boolean;
  end;

  P7SectionData = ^T7SectionData;
  T7SectionData = record
    FFakeProperty1 : Integer;
    FLookupEnabled : boolean;
    FParentIdx : integer;
    FExpandable : Boolean;
    FExpanded : Boolean;
    FVisible : boolean;
    FClickSel : boolean;
    FResiable : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
  end;

type
  P5SectionData = ^T5SectionData;
  T5SectionData = record
    FVisible : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
  end;

type
  P6SectionData = ^T6SectionData;
  T6SectionData = record
    FVisible : boolean;
    FClickSel : boolean;
    FResiable : boolean;
    FStyle : TElSectionStyle;
    FWidth : integer;
    FMinWidth,
      FMaxWidth : integer;
    FSortMode : TElSSortMode;
    FAllowClick : boolean;
    FAlignment : TElSAlignment;
    FTag : integer;
    FFieldType : TFieldTypes;
    FEditable : Boolean;
    FImageIndex : Integer;
    FPicAlign : TElSAlignment;
    FPassword : boolean;
  end;

procedure TElHeaderSections.WriteData(Stream : TStream);
var
  i, j : integer;
  P : PSectionData;
  TS : TElHeaderSection;
  P1 : PChar;
  S : string;
begin
  inherited;
  GetMem(P, SizeOf(TSectionData));
  i := -10;
  Stream.WriteBuffer(i, SizeOf(integer));
  i := Count;
  Stream.WriteBuffer(i, SizeOf(integer));
  for i := 0 to count - 1 do
  begin
    TS := TElHeaderSection(FList[i]);
    P.FLookupEnabled := TS.FLookupEnabled;
    if TS.FParentSection <> nil then
      P.FParentIdx := TS.FParentSection.Index
    else
      P.FParentIdx := -1;
    P.FExpandable := TS.FExpandable;
    P.FExpanded := TS.FExpanded;
    P.FVisible := TS.FVisible;
    P.FStyle := TS.FStyle;
    P.FWidth := TS.FWidth;
    P.FResizable := TS.FResizable;
    P.FClickSel := TS.FClickSelect;
    P.FMinWidth := TS.FMinWidth;
    P.FMaxWidth := TS.FMaxWidth;
    P.FSortMode := TS.FSortMode;
    P.FAllowClick := TS.FAllowClick;
    P.FAlignment := TS.FAlignment;
    P.FIntTag := TS.FIntTag;
    P.FTag := TS.FTag;
    P.FFieldType := TS.FFieldType;
    P.FEditable := TS.FEditable;
    P.FImageIndex := TS.FImageIndex;
    P.FPicAlign := TS.FPicAlign;
    P.FPassword := TS.FProtected;
    P.FParentColor := TS.FParentColor;
    P.FColor := TS.FColor;
    P.FFontColor := TS.FFontColor;
    P.FFilterEnabled := TS.FFilterEnabled;
    P.FTextLayout := TS.FTextLayout;
    P.FUseMainStyle := TS.FUseMainStyle;
    P.FAutoSize := TS.FAutoSize;

    Stream.WriteBuffer(p^, SizeOf(TSectionData));

    S := TElHeaderSection(FList[i]).Text;
    j := Length(S) + 1;
    GetMem(P1, j);
    StrPCopy(P1, S);
    Stream.WriteBuffer(j, SizeOf(integer));
    Stream.WriteBuffer(P1^, j);
    FreeMem(P1, j);

    S := TElHeaderSection(FList[i]).FFieldName;
    j := Length(S) + 1;
    GetMem(P1, j);
    StrPCopy(P1, S);
    Stream.WriteBuffer(j, SizeOf(integer));
    Stream.WriteBuffer(P1^, j);
    FreeMem(P1, j);
    WriteStringToStream(Stream, TS.FPopupName);
    WriteStringToStream(Stream, TS.Hint);
  end;
  FreeMem(P, SizeOf(TSectionData));
end;

procedure TElHeaderSections.ReadData(Stream : TStream);
begin
  IntReadData(Stream, true);
end;

procedure TElHeaderSections.FrameReadData(Stream : TStream);
begin
  IntReadData(Stream, false);
end;

procedure TElHeaderSections.IntReadData(Stream : TStream; ClearCurrent : boolean);
var
  i, j : integer;
  Q  : P6SectionData;
  T7 : P7SectionData;
  T  : PSectionData;
  T8a: P8aSectionData;
  T8 : P8SectionData;
  P1 : PChar;
  S  : string;
  THS : TElHeaderSection;
  Ver : integer;
  //failed killsection : boolean;
begin
  inherited;
  Stream.ReadBuffer(i, SizeOf(integer));
  ver := i;
  //failed if ClearCurrent or (ver > -10) then
    Clear;
  if ver = -10 then
  begin
    Stream.ReadBuffer(i, SizeOf(integer));
    GetMem(T, SizeOf(TSectionData));
    while i > 0 do
    begin
      Stream.ReadBuffer(T^, SizeOf(TSectionData));
      //failed killsection := (GetSectionByIntTag(T^.FIntTag) <> nil) and (not ClearCurrent);
      THS := AddSection;
      THS.FLookupEnabled := T.FLookupEnabled;
      THS.FExpandable := T.FExpandable;
      THS.FExpanded := T.FExpanded;
      THS.FParentIdx := T.FParentIdx;
      THS.FResizable := T.FResizable;
      THS.FClickSelect := T.FClickSel;
      THS.FVisible := T.FVisible;
      THS.FStyle := T.FStyle;
      THS.FWidth := T.FWidth;
      THS.FMinWidth := T.FMinWidth;
      THS.FMaxWidth := T.FMaxWidth;
      THS.FSortMode := T.FSortMode;
      THS.FAllowClick := T.FAllowClick;
      THS.FAlignment := T.FAlignment;
      THS.FIntTag := T.FIntTag;
      THS.FTag := T.FTag;
      THS.FFieldType := T.FFieldType;
      THS.FEditable := T.FEditable;
      THS.FImageIndex := T.FImageIndex;
      THS.FPicAlign := T.FPicAlign;
      THS.FProtected := T.FPassword;
      THS.FTextLayout := T.FTextLayout;
      THS.FUseMainStyle := T.FUseMainStyle;
      THS.FParentColor := T.FParentColor;
      THS.FColor := T.FColor;
      THS.FFontColor := T.FFontColor;
      THS.FFilterEnabled := T.FFilterEnabled;
      THS.FAutoSize := T.FAutoSize;

      // read caption
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FText := S;
      FreeMem(P1, j);
      // read field name
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FFieldName := S;
      FreeMem(P1, j);
      dec(i);
      ReadStringFromStream(Stream, THS.FPopupName);
      ReadStringFromStream(Stream, THS.FHint);
      (*failed
      if KillSection then
      begin
        DeleteSection(THS);
        Continue;
      end;*)
    end;
    FreeMem(T);
    for i := 0 to Count - 1 do
    begin
      if Item[i].FParentIdx <> -1 then
      begin
        Item[i].FParentSection := Item[Item[i].FParentIdx];
      end;
    end;
  end
  else
  if (ver = -9) then
  begin
    Stream.ReadBuffer(i, SizeOf(integer));
    GetMem(T8a, SizeOf(T8aSectionData));
    while i > 0 do
    begin
      Stream.ReadBuffer(T8A^, SizeOf(T8ASectionData));
      THS := AddSection;
      THS.FLookupEnabled := T8A.FLookupEnabled;
      THS.FExpandable := T8A.FExpandable;
      THS.FExpanded := T8A.FExpanded;
      THS.FParentIdx := T8A.FParentIdx;
      THS.FResizable := T8A.FResizable;
      THS.FClickSelect := T8A.FClickSel;
      THS.FVisible := T8A.FVisible;
      THS.FStyle := T8A.FStyle;
      THS.FWidth := T8A.FWidth;
      THS.FMinWidth := T8A.FMinWidth;
      THS.FMaxWidth := T8A.FMaxWidth;
      THS.FSortMode := T8A.FSortMode;
      THS.FAllowClick := T8A.FAllowClick;
      THS.FAlignment := T8A.FAlignment;
      THS.FTag := T8A.FTag;
      THS.FFieldType := T8A.FFieldType;
      THS.FEditable := T8A.FEditable;
      THS.FImageIndex := T8A.FImageIndex;
      THS.FPicAlign := T8A.FPicAlign;
      THS.FProtected := T8A.FPassword;
      THS.FTextLayout := T8A.FTextLayout;
      THS.FUseMainStyle := T8A.FUseMainStyle;
      THS.FParentColor := T8A.FParentColor;
      THS.FColor := T8A.FColor;
      THS.FFontColor := T8A.FFontColor;
      THS.FFilterEnabled := T8A.FFilterEnabled;
      THS.FAutoSize := T8A.FAutoSize;

      // read caption
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FText := S;
      FreeMem(P1, j);
      // read field name
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FFieldName := S;
      FreeMem(P1, j);
      dec(i);
      ReadStringFromStream(Stream, THS.FPopupName);
      ReadStringFromStream(Stream, THS.FHint);
    end;
    FreeMem(T8a);
    for i := 0 to Count - 1 do
    begin
      if Item[i].FParentIdx <> -1 then
      begin
        Item[i].FParentSection := Item[Item[i].FParentIdx];
      end;
    end;
  end
  else
  if (ver = -8) then
  begin
    Stream.ReadBuffer(i, SizeOf(integer));
    GetMem(T8, SizeOf(T8SectionData));
    while i > 0 do
    begin
      Stream.ReadBuffer(T8^, SizeOf(T8SectionData));
      THS := AddSection;
      THS.FLookupEnabled := T8.FLookupEnabled;
      THS.FExpandable := T8.FExpandable;
      THS.FExpanded := T8.FExpanded;
      THS.FParentIdx := T8.FParentIdx;
      THS.FResizable := T8.FResizable;
      THS.FClickSelect := T8.FClickSel;
      THS.FVisible := T8.FVisible;
      THS.FStyle := T8.FStyle;
      THS.FWidth := T8.FWidth;
      THS.FMinWidth := T8.FMinWidth;
      THS.FMaxWidth := T8.FMaxWidth;
      THS.FSortMode := T8.FSortMode;
      THS.FAllowClick := T8.FAllowClick;
      THS.FAlignment := T8.FAlignment;
      THS.FTag := T8.FTag;
      THS.FFieldType := T8.FFieldType;
      THS.FEditable := T8.FEditable;
      THS.FImageIndex := T8.FImageIndex;
      THS.FPicAlign := T8.FPicAlign;
      THS.FProtected := T8.FPassword;
      THS.FTextLayout := T8.FTextLayout;
      THS.FUseMainStyle := T8.FUseMainStyle;
      THS.FParentColor := T8.FParentColor;
      THS.FColor := T8.FColor;
      THS.FFontColor := T8.FFontColor;
      THS.FFilterEnabled := T8.FFilterEnabled;

      // read caption
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FText := S;
      FreeMem(P1, j);
      // read field name
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FFieldName := S;
      FreeMem(P1, j);
      dec(i);
      ReadStringFromStream(Stream, THS.FPopupName);
      ReadStringFromStream(Stream, THS.FHint);
    end;
    FreeMem(T8);
    for i := 0 to Count - 1 do
    begin
      if Item[i].FParentIdx <> -1 then
      begin
        Item[i].FParentSection := Item[Item[i].FParentIdx];
      end;
    end;
  end
  else if (ver = -5) or (ver = -6) then
  begin
    Stream.ReadBuffer(i, SizeOf(integer));
    GetMem(T7, SizeOf(T7SectionData));
    while i > 0 do
    begin
      Stream.ReadBuffer(T7^, SizeOf(T7SectionData));
      THS := AddSection;
      THS.FLookupEnabled := T7.FLookupEnabled;
      THS.FExpandable := T7.FExpandable;
      THS.FExpanded := T7.FExpanded;
      THS.FParentIdx := T7.FParentIdx;
      THS.FResizable := T7.FResiable;
      THS.FClickSelect := T7.FClickSel;
      THS.FVisible := T7.FVisible;
      THS.FStyle := T7.FStyle;
      THS.FWidth := T7.FWidth;
      THS.FMinWidth := T7.FMinWidth;
      THS.FMaxWidth := T7.FMaxWidth;
      THS.FSortMode := T7.FSortMode;
      THS.FAllowClick := T7.FAllowClick;
      THS.FAlignment := T7.FAlignment;
      THS.FTag := T7.FTag;
      THS.FFieldType := T7.FFieldType;
      THS.FEditable := T7.FEditable;
      THS.FImageIndex := T7.FImageIndex;
      THS.FPicAlign := T7.FPicAlign;
      THS.FProtected := T7.FPassword;
      // read caption
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FText := S;
      FreeMem(P1, j);
      // read field name
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FFieldName := S;
      FreeMem(P1, j);
      dec(i);
      if Ver = -6 then ReadStringFromStream(Stream, THS.FPopupName);
    end;
    FreeMem(T7);
    for i := 0 to Count - 1 do
    begin
      if Item[i].FParentIdx <> -1 then
      begin
        Item[i].FParentSection := Item[Item[i].FParentIdx];
      end;
    end;
  end
  else if i = -4 then
  begin
    Stream.ReadBuffer(i, SizeOf(integer));
    GetMem(q, SizeOf(T6SectionData));
    while i > 0 do
    begin
      Stream.ReadBuffer(q^, SizeOf(T6SectionData));
      THS := AddSection;
      THS.FResizable := Q^.FResiable;
      THS.FClickSelect := Q^.FClickSel;
      THS.FVisible := q^.FVisible;
      THS.FStyle := q^.FStyle;
      THS.FWidth := q^.FWidth;
      THS.FMinWidth := q^.FMinWidth;
      THS.FMaxWidth := q^.FMaxWidth;
      THS.FSortMode := q^.FSortMode;
      THS.FAllowClick := q^.FAllowClick;
      THS.FAlignment := q^.FAlignment;
      THS.FTag := q^.FTag;
      THS.FFieldType := q^.FFieldType;
      THS.FEditable := q^.FEditable;
      THS.FImageIndex := q^.FImageIndex;
      THS.FPicAlign := q^.FPicAlign;
      THS.FProtected := q^.FPassword;
    // read caption
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FText := S;
      FreeMem(P1, j);
    // read field name
      Stream.ReadBuffer(J, SizeOf(integer));
      GetMem(P1, j);
      Stream.ReadBuffer(P1^, j);
      S := StrPas(P1);
      THS.FFieldName := S;
      FreeMem(P1, j);
      dec(i);
    end;
    FreeMem(q);
  end;
  if (FOwner.HandleAllocated) then
    FOwner.Invalidate;//Repaint;
end;

procedure TElHeaderSections.LoadFromStream(Stream : TStream);
begin
  ReadData(Stream);
  if (FOwner <> nil) and (FOwner.HandleAllocated) then
    FOwner.Invalidate;
end;

procedure TElHeaderSections.SaveToStream(Stream : TStream);
begin
  WriteData(Stream);
end;

procedure TElHeaderSections.SaveToFile(FileName : string);
var
  T : TStream;
begin
  T := nil;
  try
    T := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    SaveToStream(T);
  finally
    T.Free;
  end;
end;

procedure TElHeaderSections.LoadFromFile(FileName : string);
var
  T : TStream;
begin
  T := nil;
  try
    T := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    LoadFromStream(T);
  finally
    T.Free;
  end;
end;

function TElHeaderSections.LastVisibleSection : TElHeaderSection;
begin
  result := TElHeaderSection(FList[Count - 1]);
  if not Result.Visible then result := GetPrevVisibleSection(Result);
end;

function TElHeaderSections.GetPrevVisibleSection;
var
  I : Integer;

begin
  result := nil;
  I := FList.IndexOf(Section) - 1;
  if i < 0 then exit;
  while i >= 0 do
  begin
    if TElHeaderSection(FList[i]).Visible then
    begin
      result := TElHeaderSection(FList[i]);
      break;
    end;
    dec(i);
  end; // while
end;

procedure TElHeaderSections.Assign;
var
  IT : TElHeaderSections;
  j : integer;
begin
  if source is TElHeaderSections then
  begin
    IT := TElHeaderSections(source);
    // delete old sections
    for j := 0 to FList.Count - 1 do
      DeleteSection(Item[j]);
    // add new sections
    for j := 0 to IT.Count - 1 do
      AddSection.Assign(IT.Item[j]);
    FOwner.MarkStickySections;
  end
  else
    inherited;
end;

function TElHeaderSections.GetOwner : TPersistent;
begin
  result := FOwner;
end;

function TElHeaderSections.FindSection(tag : integer) : TElHeaderSection; { protected }
var
  i, j : integer;
begin
  j := FList.Count - 1;
  for i := 0 to j do
    if TElHeaderSection(FList[i]).FTag = tag then
    begin
      result := TElHeaderSection(FList[i]);
      exit;
    end;
  result := nil;
end; { FindSection }

// =============================================================================

constructor TCustomElHeader.Create(AOwner : TComponent);
begin
  inherited;
{$IFNDEF VER90}
  ControlStyle := [csClickEvents, csDisplayDragImage, csDoubleClicks, csCaptureMouse,
    {csDesignInteractive,} csReplicatable, csOpaque, csReflector];
{$ELSE}
  ControlStyle := [csClickEvents, csDisplayDragImage, csDoubleClicks, csCaptureMouse,
    {csDesignInteractive,} csReplicatable, csOpaque];
{$ENDIF}
{$IFDEF ELPACK_COMPLETE}
  FImgFormChLink := TImgFormChangeLink.Create;
  FImgFormChLink.OnChange := ImageFormChange;
{$ENDIF}
  FSections := CreateSections;
  TabStop := false;
  Font.OnChange := OnFontChange;
  Height := abs(Font.Height) + 6 + GetSystemMetrics(SM_CYBORDER) * 2;
  DragMode := dmManual;
  FPressed := false;
  DragCursor := Cursor;
  FAscBmp := TBitmap.Create;
  FDescBmp := TBitmap.Create;
  FLeftBmp := TBitmap.Create;
  FRightBmp := TBitmap.Create;
  FPointBmp := TBitmap.Create;
  FPressed := false;
  FTracking := true;
  FAllowDrag := true;
  FResizeOnDrag := false;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := OnImageListChange;
  FAscBmp.LoadFromResourceName(HInstance, 'ELHEADERASCBMP');
  FDescBmp.LoadFromResourceName(HInstance, 'ELHEADERDESCBMP');
  FLeftBmp.LoadFromResourceName(HInstance, 'ELHEADERLEFTBMP');
  FRightBmp.LoadFromResourceName(HInstance, 'ELHEADERRIGHTBMP');
  FPointBmp.LoadFromResourceName(HInstance, 'ELHEADERPOINTBMP');
  Color := clBtnFace;
  Align := alTop;
  FFilterColor := clBtnText;
  FInvertSortArrows := False;
end;

destructor TCustomElHeader.Destroy;
begin
  Destroying;
  FSections.Free;
  FPointBmp.Free;
  FAscBmp.Free;
  FDescBmp.Free;
  FLeftBmp.Free;
  FRightBmp.Free;
{$IFDEF ELPACK_COMPLETE}
  ImageForm := nil;
  FImgFormChLink.Free;
  FImgFormChLink := nil;
{$ENDIF}
  if FImages <> nil then
     FImages.UnregisterChanges(FImageChangeLink);
  FImageChangeLink.Free;
  inherited Destroy;
end;

function TCustomElHeader.CreateSections;
begin
  result := TElHeaderSections.Create(self);
end;

function TCustomElHeader.GetSectionAtEx(X, Y : integer; var SectionPart : TElSectionPart) : TElHeaderSection;
var
  THS : TElHeaderSection;
  rm : integer;
begin
  if InResizeArea(X, THS) then
  begin
    result := THS;
    SectionPart := espResizeArea;
    exit;
  end
  else
  begin
    THS := GetSectionAt(X, Y);
    if THS <> nil then
    begin
      rm := THS.Right - 4;
      if THS.Expandable then
      begin
        if ((rm + 13 - THS.Width) + (ResizeWidth - 4) < RM)
          and InRange(rm - 6 - (ResizeWidth - 4), RM, X)
          and InRange(2, 9, Y) then
        begin
          result := THS;
          SectionPart := espExpandSign;
          exit;
        end;
      end;
      if THS.FLookupEnabled then
      begin
        if ((rm + 13 - THS.Width) + (ResizeWidth - 4) < RM)
          and InRange(rm - 6 - (ResizeWidth - 4), RM, X)
          and InRange(12, 16, Y) then
        begin
          result := THS;
          SectionPart := espLookupSign;
          exit;
        end;
      end
      else if THS.FFilterEnabled then
      begin
        if ((rm + 13 - THS.Width) + (ResizeWidth - 4) < RM)
          and InRange(rm - 6 - (ResizeWidth - 4), RM, X)
          and InRange(12, 16, Y) then
        begin
          result := THS;
          SectionPart := espFilterSign;
          exit;
        end;
      end;
    end;
  end;
  result := THS;
  SectionPart := espText;
end;

function TCustomElHeader.GetSectionAt(X, Y : integer) : TElHeaderSection;
var
  i : integer;
  j : integer;
  ASection : TElHeaderSection;
begin
  j := 0;
  result := nil;
  X := X + FHPos;
  for i := 0 to FSections.FList.Count - 1 do
  begin
    ASection := TElHeaderSection(FSections.FList[i]);
    //if ASection = FLockedSection then Continue;
    if ASection.Visible then j := j + ASection.Width;
    if j > X then
    begin
      result := ASection;
      exit;
    end;
  end;
end;

procedure TCustomElHeader.InvalidateRight(value : integer);
var
  R : TRect;
begin
  if not inRange(0, Sections.Count - 1, value) then raise EElError.Create('Index out of bounds');
  if not HandleAllocated then exit;
  R := Rect(TElHeaderSection(Sections[value]).Left, 0, ClientWidth, ClientHeight);
  if (HandleAllocated) then
    InvalidateRect(Handle, @R, false);
  //Update;
end;

function TCustomElHeader.GetColumnsWidth : integer;
var
  i : integer;
begin
  result := 0;
  i := FSections.Count - 1;
  while i >= 0 do
  begin
    if TElHeaderSection(FSections.FList[i]).Visible then
    begin
      result := TElHeaderSection(FSections.FList[i]).Right;
      exit;
    end;
    dec(i);
  end;
end;

function TCustomElHeader.InResizeArea(X : integer; var HitSection : TElHeaderSection) : boolean;
var
  THS : TElHeaderSection;
  l : integer;
begin
  THS := GetSectionAt(X, 0);
  HitSection := THS;
  if THS = nil then
  begin
    if Sections.Count > 0 then THS := Sections.LastVisibleSection;
    if THS <> nil then
    begin
      l := THS.Right;
      dec(l, FHPos);

      if L + ResizeWidth > X then
      begin
        result := true;
        HitSection := THS;
        exit;
      end;
    end;
    result := false;
    HitSection := nil;
    exit;
  end
  else
  begin
    if THS.Width < ResizeWidth * 3 then
      result := false
    else
    begin
      l := THS.Left;
      dec(l, FHPos);
      if L + ResizeWidth > X then
      begin
        if Sections.GetPrevVisibleSection(THS) = nil then
        begin
          result := false;
          HitSection := THS;
          exit;
        end;
        result := true;
        HitSection := Sections.GetPrevVisibleSection(THS);
        exit;
      end;
      if L + THS.FWidth - ResizeWidth <= X then
      begin
        result := true;
        exit;
      end;
      result := false;
    end;
  end;
end;

procedure TCustomElHeader.WMLButtonDown(var Message : TWMLButtonDown);
var
  THS, THS1 : TElHeaderSection;
  b : boolean;
  rm : integer;
  R : TRect;
  xoffs : integer;
begin
  if FDoingLookup then
  begin
    FDoingLookup := false;
    FLookup.Visible := false;
    DoSectionLookupDoneEvent(FLookupSection, FLookup.Text, false);
    try
      Windows.SetFocus(FFocusedCtl);
    except
      on E : Exception do
      begin
      end;
    end;
    inherited;
    exit;
  end;
  if not (csNoStdEvents in ControlStyle) then
  begin
    if InResizeArea(Message.XPos, THS) and (THS.FResizable) then
    begin
      FResizing := true;
      FResizeSection := THS;
      THS1 := FTrackSection;
      FTrackSection := nil;
      if THS1 <> nil then THS1.UpdateSection;
      Screen.Cursor := crHSplit;
      SetCapture(Handle);
      FHeaderLine := FResizeSection.Right;
         Dec(FHeaderLine, FHPos);
      FLineTab := Message.XPos - FHeaderLine;
      if (not ResizeOnDrag) then
      begin
        AllocateLineDC;
        DrawLine;
      end;
      DoSectionResizing(THS, trsBegin, THS.Width);
    end // Resizing
    else
    begin
      FPressCoord := Point(Message.XPos, Message.YPos);
      FPressed := true;
      if FPressedItem <> nil then
      begin
        THS := FPressedItem;
        FPressedItem := nil;
        THS.UpdateSection;
      end;
      FPressedItem := GetSectionAt(Message.XPos, Message.YPos);
      THS := FPressedItem;
      if FPressedItem <> nil then
      begin
        b := true;
        rm := FPressedItem.Right - 4;
        Dec(rm, FHPos);
        if FPressedItem.Expandable then
        begin
          if ((rm + 13 - FPressedItem.Width) + (ResizeWidth - 4) < RM)
            and InRange(rm - 6 - (ResizeWidth - 4), RM, Message.XPos)
            and InRange(2, 9, Message.YPos) then
          begin
            THS := FPressedItem;
            FPressedItem := nil;
            THS.Expanded := not THS.Expanded;
            if THS.Expanded then
              DoSectionExpandEvent(THS)
            else
              DoSectionCollapseEvent(THS);
            b := false;
          end;
        end;
        if THS.FFilterEnabled then
        begin
          if ((rm + 13 - THS.Width) + (ResizeWidth - 4) < RM) and InRange(rm - 5 - (ResizeWidth - 4), RM, Message.XPos)
            and InRange(12, 16, Message.YPos)
            then TriggerFilterCallEvent(THS);
        end;
        if THS.FLookupEnabled then
        begin
          if ((rm + 13 - THS.Width) + (ResizeWidth - 4) < RM)
            and InRange(rm - 6 - (ResizeWidth - 4), RM, Message.XPos)
            and InRange(12, 16, Message.YPos) then
          begin
            if Flookup <> nil then
              FLookup.Text := ''
            else
            begin
{$IFDEF ELPACK_COMPLETE}
              Flookup := TElFlatComboBox.Create(nil);
              TElFlatComboBox(FLookup).Flat := Self.Flat;
              TElFlatComboBox(FLookup).ActiveBorderType := fbtSunkenOuter;
{$ELSE}
              Flookup := TComboBox.Create(nil);
{$ENDIF}
              FLookup.Visible := false;
              FLookup.Style := csDropDown;
            end;
            FLookup.Parent := Parent;//Self;
            FLookup.OnExit := EditExit;
            FLookup.OnKeyDown := EditKeyDown;
            FLookup.OnChange := EditChange;
            FLookup.OnKeyUp := EditKeyUp;
            FLookup.Items.Assign(THS.FLookupHist);
            FLookupSection := THS;
            R := GetSectionRect(THS.Index);
            xoffs := 0;
            OffsetRect(R, Left - xoffs, Top);
            FLookup.BoundsRect := R;
            FLookup.Font.Assign(Font);
            FLookup.Font.Height := Abs(Font.Height) - 3;
            FLookup.Height := Max(FLookup.Height, R.Bottom - R.Top - 2);
            FDoingLookup := true;
            FLookup.Visible := true;
            FFocusedCtl := Windows.GetFocus;
            FLookup.SetFocus;

            b := false;
          end;
        end;
        if b and (FPressedItem.FAllowClick {or FPressed}) then
          FPressedItem.UpdateSection
        else
          FPressedItem := nil;
      end;
    end; // not Resizing
  end;
  inherited;
end;

procedure TCustomElHeader.WMMouseMove(var Message : TWMMouseMove);
var
  THS      : TElHeaderSection;
{$IFNDEF VCL_5_USED}
  AMsg     : TMessage;
{$ENDIF}
  NewPos,
  NewWidth,
  L        : integer;
  XOffs    : integer;
  P        : TPoint;

  function FixedRighterSections(Section : TElHeaderSection) : integer;
  var i : integer;
      ASect: TElHeaderSection;

  begin
    result := 0;
    for i := Section.Position + 1 to FSections.FList.Count - 1 do
    begin
      ASect := FSections.ItemByPos[i];
      if not ASect.Resizable then inc(result, ASect.Width);
    end;
  end;

begin
  if (FPressed) and (FAllowDrag)
  then
  begin
    if (FPressedItem <> nil) and (FDropSrc = nil)
      and (sqrt(sqr(FPressCoord.X - Message.XPos) + sqr(FPressCoord.Y - Message.YPos)) >= 5) then
    begin
      FDropSrc := FPressedItem;
      FPressed := false;
      GetDragImage(FPressCoord.X);
      inc(FPressCoord.X, FHPos);
      SetCapture(Handle);
      FDropTrg := nil;
      FDragCoord := FPressCoord;
      DragRect := GetSectionRect(FDropSrc.Index);
      OffsetRect(DragRect, - FHPos, 0);
    end;
  end;
  if (FAllowDrag) and (not FPressed) and (FDropSrc <> nil) then
  begin
    FDropTrg := GetSectionAt(Message.XPos, Message.YPos);
    if FMoveOnDrag then
    begin
      if (FDropSrc <> FDropTrg) then
      begin
        if FDropTrg = nil then
        begin
          NewPos := Sections.Count - 1;
          FSections.MoveSection(FDropSrc, NewPos);
        end
{Soulsnake Mod (Bug)}
        //else if ((FDropSrc.Position < FDropTrg.Position) and (FDropTrg.Right - FDropSrc.Width < Message.XPos))
        //  or ((FDropSrc.Position > FDropTrg.Position) and (FDropTrg.Left + FDropSrc.Width > Message.XPos)) then
        else if ((FDropSrc.Position < FDropTrg.Position) and (FDropTrg.Right - FDropSrc.Width < Message.XPos + FHPos))
          or ((FDropSrc.Position > FDropTrg.Position) and (FDropTrg.Left + FDropSrc.Width > Message.XPos + FHPos)) then
{End Soulsnake Mod}
        begin
          NewPos := FSections.FList.IndexOf(FDropTrg);
          FSections.MoveSection(FDropSrc, NewPos);
        end;
      end;
    end;
    InvalidateRect(Handle, @DragRect, false);
    Update;
    XOffs := FHPos;
    OffsetRect(DragRect, - (FDragCoord.x - (Message.XPos + xOffs)), 0);
    //InvalidateRect(Handle, @DragRect, false);
    //Update;
{$IFNDEF VER90}
    if IsWinNT then
      MaskBlt(Canvas.Handle, DragRect.Left, DragRect.Top, DragBmp.Width - 1, DragBmp.Height - 1, DragBmp.Canvas.Handle,
        0, 0, DragBmpMask.MaskHandle, 0, 0, ((SRCCOPY shl 8) and $FF000000) or SRCAND)
    else
{$ENDIF}
      BitBlt(Canvas.Handle, DragRect.Left, DragRect.Top, DragBmp.Width - 1, DragBmp.Height - 1, DragBmp.Canvas.Handle,
        0, 0, SRCCOPY);
    FDragCoord.X := Message.XPos;
    inc(FDragCoord.X, FHPos);
  end;

  if (FTracking) and (not FResizing) and (FDropSrc = nil) and (not (csNoStdEvents in ControlStyle)) and (not (csDesigning in ComponentState)) then
  begin
    THS := FTrackSection;
    FTrackSection := GetSectionAt(Message.XPos, Message.YPos);
    if THS <> FTrackSection then
    begin
      if THS <> nil then THS.UpdateSection;
      if FTrackSection <> nil then FTrackSection.UpdateSection;
    end;
  end;
  if (not FPressed) and (not FResizing) and (FDropSrc = nil) then
  begin
    if InResizeArea(Message.XPos, THS) and (not (csDesigning in ComponentState)) and (THS.FResizable) then
    begin
      if Screen.Cursor <> crHSplit then Screen.Cursor := crHSplit;
    end
    else if Screen.Cursor = crHSplit then
      Screen.Cursor := Cursor;

    if (FHintSection <> nil) and (FHintSection <> THS) and (THS <> nil) and ShowHint and (THS.Hint <> '') then
    begin
      P := Point(Message.XPos, Message.YPos);
      P := ClientToScreen(P);
      {$IFDEF VCL_5_USED}
      Application.ActivateHint(P);
      {$ELSE}
      MoveMemory(@AMsg, @Message, sizeof(AMsg));
      TWMMouse(AMsg).XPos := -10000;
      TWMMouse(AMsg).YPos := -10000;
      Application.HintMouseMessage(Self, AMsg);
      TWMMouse(AMsg).Pos := Message.Pos;
      Application.HintMouseMessage(Self, AMsg);
      {$ENDIF}
    end;
  end;
  if FResizing then
  begin
    L := FResizeSection.Left;
    XOffs := - FHPos
    ;
    if (Message.XPos - xOffs - FLineTab >= L)  and ((not StickySections) or (Message.XPos - xOffs - FLineTab < Width - FixedRighterSections(FResizeSection))) then
    begin
      NewWidth := Message.XPos - L - FLineTab;
      inc(NewWidth, FHPos);
      with FResizeSection do
        if InRange(MinWidth, MaxWidth, NewWidth) then
        begin
          if FResizeOnDrag then
          begin
            Width := NewWidth;
            InvalidateRight(FResizeSection.Index);
            Update;
            DoSectionResizing(FResizeSection, trsMove, NewWidth);
          end
          else
          begin
            DrawLine;
            FHeaderLine := L + NewWidth;
            dec(FHeaderLine, FHPos);
            DrawLine;
            DoSectionResizing(FResizeSection, trsMove, NewWidth);
          end;
        end;
    end; // really in client width
  end;
  inherited;
end;

procedure TCustomElHeader.WMLButtonUp(var Message : TWMLButtonUp);
var
  THS : TElHeaderSection;
  NewPos : integer;
begin
  if not (csNoStdEvents in ControlStyle) then
  begin
    if FResizing then
    begin
      FResizing := false;
      Screen.Cursor := Cursor;
      ReleaseCapture;
      if (not FResizeOnDrag) then
      begin
        if (FHeaderLineVis) then DrawLine;
        ReleaseLineDC;
        Dec(FHeaderLine, FResizeSection.Left);
        inc(FHeaderLine, FHPos);
        FResizeSection.Width := FHeaderLine;
      end;
      DoSectionResizing(FResizeSection, trsEnd, FResizeSection.Width);
      DoSectionResize(FResizeSection);
      FResizeSection := nil;
      Invalidate;
      Update;
    end
    else if FDropSrc <> nil then
    begin
      FDropTrg := GetSectionAt(Message.XPos, Message.YPos);
      if (FDropSrc <> FDropTrg) then
      begin
        if FDropTrg = nil then
          NewPos := Sections.Count - 1
        else
          NewPos := FSections.FList.IndexOf(FDropTrg);
        FSections.MoveSection(FDropSrc, NewPos);
      end;
      THS := FPressedItem;
      FPressedItem := nil;
      if THS <> nil then THS.UpdateSection;
      FDropSrc := nil;
      FDropTrg := nil;
      Invalidate;//Repaint;
      DragBmp.Free;
      DragBmp := nil;
      DragBmpMask.Free;
      ReleaseCapture;
    end
    else
    begin
      FPressed := false;
      THS := FPressedItem;
      FPressedItem := nil;
      if THS <> nil then
      begin
        THS.UpdateSection;
        if (GetSectionAt(FPressCoord.X, FPressCoord.Y) =
          GetSectionAt(Message.XPos, Message.YPos)) then DoSectionClick(THS);
      end;
    end;
  end;
  inherited;
end;

procedure TCustomElHeader.CMMouseLeave;
var
  THS : TElHeaderSection;
begin
  FDropTrg := nil;
  FPressed := false;
  if FPressedItem <> nil then
  begin
    THS := FPressedItem;
    THS.UpdateSection;
  end;
  if FTrackSection <> nil then
  begin
    THS := FTrackSection;
    FTrackSection := nil;
    THS.UpdateSection;
  end;
  if (not FResizing) and (Screen.Cursor = crHSplit) then Screen.Cursor := Cursor;
  FHintSection := nil;
  inherited;
end;

procedure TCustomElHeader.CMMouseEnter;
begin
  inherited;
  if (FPressedItem <> nil) and (FDropSrc = nil) then
  begin
    FPressed := true;
    FPressedItem.UpdateSection;
  end;
end;

procedure TCustomElHeader.CMDrag(var Message : TCMDrag);
var
  TSI : TElHeaderSection;
begin
  inherited;
  with Message, DragRec^ do
    case DragMessage of
//      dmDragMove: with ScreenToClient(Pos) do DoDragOver(Source, X, Y, Message.Result<>0);
      dmDragLeave :
        begin
          TSI := FDropTrg;
          FDropTrg := nil;
          if TSI <> nil then
          begin
            TSI.UpdateSection;
            Update;
          end;
        end;
      dmDragDrop :
        begin
          TSI := FDropTrg;
          FDropTrg := nil;
          if TSI <> nil then
          begin
            TSI.UpdateSection;
            Update;
          end;
        end;
      dmDragCancel :
        begin
          TSI := FDropTrg;
          FDropTrg := nil;
          if TSI <> nil then
          begin
            TSI.UpdateSection;
            Update;
          end;
          FDropSrc := nil;
        end;
    end;
end;

function TCustomElHeader.GetSectionRect(SectionNum : integer) : TRect;
var
  THS : TElHeaderSection;
  i : integer;
begin
  THS := Sections.FindSection(SectionNum);
  i := THS.Left;
  result := Rect(i, 0, i + THS.Width, ClientHeight);
end;

function TCustomElHeader.DoGetPicture;
begin
  result := -1;
  if Assigned(FOnPictureNeeded) then FOnPictureNeeded(self, Section, result);
end;

function TCustomElHeader.MeasureSectionWidth(Section : TElHeaderSection; TextWidth : PInteger) : integer;
var p  : TPoint;
    StImIndex : integer;
    R  : TRect;
    AL : integer;
begin
  result := 10; // minimal width for resize area and borders
  if TextWidth <> nil then
     TextWidth^ := 0;
  try
    if (Section.FExpandable or
        Section.FLookupEnabled or
        Section.FFilterEnabled) then
        inc(Result, 8);
    {if Section.FSortMode <> hsmNone then }inc(result, 12);
    inc(result, ResizeWidth);
    if Section.Style = elhsOwnerdraw then
    begin
      p.x := 0;
      Self.TriggerMeasureSectionEvent(Section, P);
      inc(result, p.x);
    end else
    begin
      if (FImages <> nil) then
      begin
        StImIndex := Section.FImageIndex;
        if StImIndex = -1 then StImIndex := DoGetPicture(Section);
        if InRange(0, FImages.Count - 1, StImIndex) then
           inc(result, FImages.Width);
      end;
      if (Section.Style = elhsPictureOnly) then exit;
      SetRectEmpty(R);
         AL := DT_SINGLELINE;

      DrawText(Canvas.Handle, PChar(Section.Text), -1, R, DT_NOPREFIX or AL or DT_CALCRECT);

      inc(result, R.Right);
      if TextWidth <> nil then
         TextWidth^ := R.Right - R.Left;
    end;
  finally
    if result < Section.MinWidth then
       result := Section.MinWidth;
  end;
end;

procedure TCustomElHeader.RedrawSection(Canvas : TCanvas; Section : TElHeaderSection; R : TRect);
var
  TS          : TElHeaderSection;
  R1,
  R2,
  BgRect      : TRect;
  w           : integer;
  DC          : THandle;
  s           : string;
  SaveCol,
    SaveColor : TColor;
  SaveStyle   : TFontStyles;
  StImIndex   : integer;
  BMP         : TBitmap;
  AL          : integer;
  AForm       : TCustomForm;
  imfd        : boolean;

begin
  TS := Section;

  if TS.FParentColor then
    Canvas.Brush.Color := Color
  else
    Canvas.Brush.Color := TS.FColor;

  imfd := false;
{$IFDEF ELPACK_COMPLETE}
  if (FImgForm <> nil) and (not (csDesigning in Parent.ComponentState)) then
  begin
    AForm := GetParentForm(Self);
    BgRect := R;
    OffsetRect(BgRect, -Section.Left + FHPos, 0);
    BgRect.TopLeft := ClientToScreen(BgRect.TopLeft);
    BgRect.BottomRight := ClientToScreen(BgRect.BottomRight);
    BgRect.TopLeft := AForm.ScreenToClient(BgRect.TopLeft);
    BgRect.BottomRight := AForm.ScreenToClient(BgRect.BottomRight);
    FImgForm.PaintBkgnd(Canvas.Handle, R, BgRect.TopLeft, false);
    imfd := true;
  end
  else
{$ENDIF}
    Canvas.FillRect(R);

  DC := Canvas.Handle;
  if (TS = FPressedItem) and (FPressed = true) then
  begin
    if Flat then
    begin
      DrawEdge(DC, R, BDR_SUNKENOUTER, BF_RECT);
      InflateRect(R, -1, -1);
      OffsetRect(R, 1, 1);
    end
    else
    begin
      DrawEdge(DC, R, BDR_SUNKENINNER, BF_TOPLEFT); { black     }
      DrawEdge(DC, R, BDR_SUNKENOUTER, BF_BOTTOMRIGHT); { btnhilite }
      InflateRect(R, -1, -1);
      OffsetRect(R, 1, 1);
    end;
  end
  else
  begin
    if Flat then
    begin
      DrawEdge(DC, R, BDR_RAISEDINNER, BF_RECT);
    end
    else
    begin
      DrawEdge(DC, R, BDR_RAISEDOUTER, BF_BOTTOMRIGHT); { black }
      Dec(R.Bottom);
      Dec(R.Right);
      DrawEdge(DC, R, BDR_RAISEDINNER, BF_TOPLEFT); { btnhilite }
      Inc(R.Top);
      Inc(R.Left);
      DrawEdge(DC, R, BDR_RAISEDINNER, BF_BOTTOMRIGHT); { btnshadow }
      Dec(R.Bottom);
      Dec(R.Right);
    end;
  end;

  inc(R.Top);
  inc(R.Left);
  dec(R.Bottom);
  dec(R.Right, 4);
  if (TS.FExpandable or TS.FLookupEnabled or TS.FFilterEnabled) and (R.Left + 6 + (ResizeWidth - 4) < R.Right) then
  begin
    if TS.Expandable then
    begin
      R2 := Rect(R.Right - 5, R.Top, R.Right, R.Top + 7);
      if TS.Expanded then
        DrawArrow(Canvas, eadLeft, R2, clBtnText, true)
      else
        DrawArrow(Canvas, eadRight, R2, clBtnText, true);
    end;
    if TS.FLookupEnabled then
    begin
      BMP := FPointBmp;
      R2 := Rect(R.Right - 5, R.Top + 10, R.Right, Min(R.Top + 14, R.Bottom));
      if imfd then
        DrawTransparentBitmapEx(Canvas.Handle, Bmp.Handle, R2.Left, R2.Top, Rect(0, 0, R2.Right - R2.Left, R2.Bottom - R2.Top), BMP.TransparentColor)
      else
        Canvas.BrushCopy(R2, Bmp, Rect(0, 0, R2.Right - R2.Left, R2.Bottom - R2.Top), BMP.TransparentColor)
    end
    else if TS.FFilterEnabled then
    begin
      SaveColor := Canvas.Brush.Color;
      SaveCol := Canvas.Pen.Color;
      if TS.FFilterIsActive
        then
        Canvas.Brush.Color := FActiveFilterColor
      else
        Canvas.Brush.Color := FFilterColor;
      Canvas.Pen.Color := Canvas.Brush.Color;
      Canvas.Polygon([Point(R.Right - 4, R.Top + 10), Point(R.Right, R.Top + 10), Point(R.Right - 2, Min(R.Top + 14, R.Bottom))]);
      Canvas.Brush.Color := SaveColor;
      Canvas.Pen.Color := SaveCol;
    end;
    Dec(R.Right, 8);
  end;
  R1 := R;
  //if (TS=FPressedItem) and (FPressed=true) then inc(R1.Left,2);
  if (TS.FSortMode <> hsmNone) and (TS.FShowSortMark) then
  begin
    if R1.Right - 8 < R1.Left + ResizeWidth then
    begin
      w := 0;
      R1.Right := R1.Left + ResizeWidth;
    end
    else
    begin
      w := 9;
      dec(R1.Right, 9);
    end;
    R2 := Rect(R1.Right, ((R1.Bottom - R.Top) div 2 + R.Top) - 3, R1.Right + W, ((R1.Bottom - R.Top) div 2 + R.Top) + 3);
    if TS.FParentColor then
      Canvas.Brush.Color := Color
    else
      Canvas.Brush.Color := TS.FColor;
    if w > 0 then
    begin
      if (TS.FSortMode = hsmAscend) xor (InvertSortArrows) then
        BMP := FAscBmp
      else
        BMP := FDescBmp;
      if imfd then
        DrawTransparentBitmapEx(Canvas.Handle, Bmp.Handle, R2.Left, R2.Top, Rect(0, 0, 9, 6), Bmp.Canvas.Pixels[0, 5])
      else
        Canvas.BrushCopy(R2, Bmp, Rect(0, 0, 9, 6), Bmp.Canvas.Pixels[0, 5]);
      dec(R1.Right, 3);
    end;
  end;
  {if TS.FResizable then }
  inc(R1.Left, ResizeWidth);
  if R1.Right < R1.Left then exit;
  if TS.FStyle = ElhsOwnerDraw then
  begin
    DoSectionDraw(TS, R1, (TS = FPressedItem) and (FPressed = true));
  end
  else
  begin
    if TS.FStyle = elhsPictureOnly then
    begin
      if (FImages <> nil) then
      begin
        StImIndex := TS.FImageIndex;
        if StImIndex = -1 then StImIndex := DoGetPicture(TS);
        if InRange(0, FImages.Count - 1, StImIndex) then
        begin
          BMP := TBitmap.Create;
          BMP.Width := FImages.Width;
          BMP.Height := FImages.Height;
          if R.Left < R.Right then
          begin
            BMP.Canvas.Brush.Color := Canvas.Brush.Color;
            BMP.Canvas.FillRect(Rect(0, 0, FImages.Width, FImages.Height));
            FImages.Draw(BMP.Canvas, 0, 0, StImIndex);
            R2 := Rect(Max(R1.Left + ((R1.Right - R1.Left + 1) div 2) - (FImages.Width div 2), R1.Left),
              R1.Top + ((R1.Bottom - R1.Top + 1) div 2) - (FImages.Height div 2),
              Min(R1.Right, R1.Left + ((R1.Right - R1.Left + 1) div 2) - (FImages.Width div 2) + FImages.Width),
              R1.Top + FImages.Height);
            Canvas.CopyRect(R2, BMP.Canvas, Rect(0, 0, min(FImages.Width, Min(R1.Right, R1.Left + FImages.Width - 1) - R1.Left + 1), FImages.Height));
          end;
          inc(R1.Left, FImages.Width);
          BMP.Free;
        end;
      end;
      exit;
    end;
    if (FImages <> nil) and (TS.FPicAlign = hsaLeft) then
    begin
      StImIndex := TS.FImageIndex;
      if StImIndex = -1 then StImIndex := DoGetPicture(TS);
      if InRange(0, FImages.Count - 1, StImIndex) then
      begin
        BMP := TBitmap.Create;
        BMP.Width := FImages.Width;
        BMP.Height := FImages.Height;
        if R.Left < R.Right then
        begin
          BMP.Canvas.Brush.Color := Canvas.Brush.Color;
          BMP.Canvas.FillRect(Rect(0, 0, FImages.Width, FImages.Height));
          FImages.Draw(BMP.Canvas, 0, 0, StImIndex);
{$IFNDEF VER90}
          BMP.TransparentMode := tmAuto;
{$ENDIF}
          R2 := Rect(R1.Left, R1.Top + ((R1.Bottom - R1.Top + 1) div 2) - (FImages.Height div 2), Min(R1.Right, R1.Left + FImages.Width), R1.Top + FImages.Height);
          Canvas.CopyRect(R2, BMP.Canvas, Rect(0, 0, min(FImages.Width, Min(R1.Right, R1.Left + FImages.Width - 1) - R1.Left + 1), FImages.Height));
        end;
        inc(R1.Left, FImages.Width);
        BMP.Free;
      end;
    end;
    if R1.Right < R1.Left then exit;
    if TS.FStyle = elhsText then
    begin
      s := TS.Text;
      if FRightAlignedText then
      begin
        Al := DT_RIGHT;
        case TS.FAlignment of
          hsaCenter : Al := DT_CENTER;
          hsaRight : Al := DT_LEFT;
        end; // case
      end
      else
      begin
        Al := DT_LEFT;
        case TS.FAlignment of
          hsaCenter : Al := DT_CENTER;
          hsaRight : Al := DT_RIGHT;
        end; // case
      end;
      case TS.FTextLayout of
        tlTop : Al := AL or DT_TOP;
        tlCenter : Al := Al or DT_VCENTER;
        tlBottom : Al := Al or DT_BOTTOM;
      end;
      if RightAlignedText then
         AL := AL or DT_RTLREADING;
         AL := AL or DT_SINGLELINE or DT_END_ELLIPSIS;

      Canvas.Brush.Style := bsClear;
      if TS = FTrackSection then
      begin
        SaveCol := Canvas.Font.Color;
        SaveStyle := Canvas.Font.Style;
        Canvas.Font.Color := clHighlight;
        Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];
        DrawText(Canvas.Handle, PChar(S), -1, R1,
          DT_NOPREFIX or AL);
        Canvas.Font.Color := SaveCol;
        Canvas.Font.Style := SaveStyle;
      end
      else
      begin
        if TS.ParentColor then
          Canvas.Font.Color := Font.Color
        else
          Canvas.Font.Color := TS.FontColor;
        DrawText(Canvas.Handle, PChar(S), -1, R1, DT_NOPREFIX or AL);
      end;
      Canvas.Brush.Style := bsSolid;
    end;
    inc(R1.Left, Canvas.TextWidth(S) + 3);
    if R1.Right < R1.Left then exit;
  end;
  if (FImages <> nil) and (TS.FPicAlign = hsaRight) then
  begin
    StImIndex := TS.FImageIndex;
    if StImIndex = -1 then StImIndex := DoGetPicture(TS);
    if InRange(0, FImages.Count - 1, StImIndex) then
    begin
      BMP := TBitmap.Create;
      BMP.Width := FImages.Width;
      BMP.Height := FImages.Height;
      if R.Left < R.Right then
      begin
        BMP.Canvas.Brush.Color := Canvas.Brush.Color;
        BMP.Canvas.FillRect(Rect(0, 0, FImages.Width, FImages.Height));
        FImages.Draw(BMP.Canvas, 0, 0, StImIndex);
{$IFNDEF VER90}
        BMP.TransparentMode := tmAuto;
{$ENDIF}
        R2 := Rect(R1.Left, R1.Top + ((R1.Bottom - R1.Top + 1) div 2) - (FImages.Height div 2), Min(R1.Right, R1.Left + FImages.Width), R1.Top + FImages.Height);
        Canvas.CopyRect(R2, BMP.Canvas, Rect(0, 0, min(FImages.Width, Min(R1.Right, R1.Left + FImages.Width - 1) - R1.Left + 1), FImages.Height));
      end;
      inc(R1.Left, FImages.Width);
      BMP.Free;
    end;
  end;
end;

procedure TCustomElHeader.RedrawSections;
var
  R, R1
{$IFDEF ELPACK_COMPLETE}
  , BgRect
{$ENDIF}
  	 : TRect;
  i      : integer;
{$IFDEF ELPACK_COMPLETE}
  AForm  : TCustomForm;
{$ENDIF}
begin
  for i := 0 to Sections.Count - 1 do
  begin
    if not Sections[i].Visible then Continue;
    begin
      R := GetSectionRect(i);
      OffsetRect(R, -FHPos, 0);
      if IntersectRect(R1, R, Canvas.ClipRect) and (Sections[i].Visible) then
         RedrawSection(Canvas, Sections[i], R);
    end;
  end;
  R := ClientRect;
  R.Left := SectionsWidth - FHPos;
  begin
    Canvas.Brush.Color := Color;
    Canvas.FillRect(R);
  end;
  DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_RECT);
end;

procedure TCustomElHeader.AdjustHeaderHeight;
var mh : integer;    
begin
  if LockHeight then exit;
   mh := Abs(Font.Height) + 4;
  if Assigned(Images) then
     ClientHeight := Max(Max(17, mh + 4), Images.Height)
  else
     ClientHeight := Max(17, mh + 4);
end;

procedure TCustomElHeader.AdjustStickySize(Caller : TElHeaderSection);
var
  i, cw, sw : integer;
  HS : TElHeaderSection;

begin
  i := 0;
  while (SectionsWidth >= ClientWidth) and (ClientWidth > 0) and (i > -1) do
  begin
    i := FSections.Count - 1;
    while i >= 0 do
    begin
      HS := FSections.ItemByPos[i];
      cw := ClientWidth;
      sw := SectionsWidth;
      if HS.Visible and (HS.Width > 0) and (HS.Resizable) and (HS <> Caller) then
      begin
        if HS.Width > (sw - cw - 1) then
          Hs.FWidth := hs.Width - (sw - cw) - 1
        else
          HS.FWidth := 0;
        //HS.FStickySize := HS.Width / cw;
        break;
      end;
      dec(i);
    end; // while
  end;
  i := 0;
  while (SectionsWidth >= ClientWidth) and (ClientWidth > 0) and (i > -1) do // we probably have non-resizable sections
  begin
    i := FSections.Count - 1;
    while i >= 0 do
    begin
      HS := FSections.ItemByPos[i];
      cw := ClientWidth;
      sw := SectionsWidth;
      if HS.Visible and (HS.Width > 0) and ((not HS.Resizable) or (HS = Caller)) then
      begin
        if HS.FSaveSize = -1 then HS.FSaveSize := HS.Width; // this is the size we have to save, cause later we'll have to restore it
        if HS.Width > (sw - cw - 1) then
          HS.FWidth := hs.Width - (sw - cw) - 1
        else
          HS.FWidth := 0;
        break;
      end;
      dec(i);
    end;
  end;

  // first restore "non-resizable" sections
  i := 0;
  while (SectionsWidth < ClientWidth - 1) and (i > -1) do
  begin
    i := FSections.Count - 1;
    while i >= 0 do
    begin
      HS := FSections.ItemByPos[i];
      cw := ClientWidth;
      sw := SectionsWidth;
      if HS.Visible and (not HS.Resizable) and (HS.Width < HS.FSaveSize) and (HS.FSaveSize <> -1) then
      begin
        HS.FWidth := min(hs.Width + (cw - sw) - 1, HS.FSaveSize);
        if HS.FWidth = HS.FSaveSize then
          HS.FSaveSize := -1
        else
          break;
      end;
      dec(i);
    end; // while
  end;

  i := FSections.Count - 1;
  while i >= 0 do
  begin
    HS := FSections.ItemByPos[i];
    cw := ClientWidth;
    sw := SectionsWidth;
    if HS.Visible and (HS.Resizable) and (HS <> Caller) then
    begin
      HS.FWidth := hs.Width + (cw - sw) - 1;
      //HS.FStickySize := HS.Width / cw;
      break;
    end;
    dec(i);
  end; // while
end;

function TCustomElHeader.GetResizableWidth : integer;
var
  i, w : integer;
  HS : TElHeaderSection;
begin
  w := Width;
  for i := 0 to FSections.Count - 1 do // Iterate
  begin
    HS := FSections[i];
    //if HS.Visible and (HS.Resizable) then w := w + HS.Width;
    if HS.Visible and (not HS.Resizable) then w := w - HS.Width;
  end; // for
  result := w;
end;

procedure TCustomElHeader.MarkStickySections;
var
  w, i : integer;
  HS : TElHeaderSection;
begin
  W := GetResizableWidth;
  for i := 0 to FSections.Count - 1 do
  begin
    HS := FSections.ItemByPos[i];
    if HS.Resizable and HS.Visible then
      if (W <> 0) then
        HS.FStickySize := HS.FWidth / w
      else
        HS.FStickySize := 0;
  end;
end;

procedure TCustomElHeader.Resize;
var
  i, oh, nh, w : integer;
  HS : TElHeaderSection;
begin
  if not FLockHeight then
  begin
    oh := ClientHeight;
    if Images <> nil then
      nh := Max(Max(Images.Height, oh), Abs(Font.Height) + 6)
    else
      nh := Max(oh, Abs(Font.Height) + 6);
    if nh <> oh then
       AdjustHeaderHeight;
  end;
  if StickySections then
  begin
    FInStick := true;
    if FOldWidth < ClientWidth then
      for i := FSections.Count - 1 downto 0 do // Iterate
      begin
        HS := FSections.ItemByPos[i];
        if (not HS.Resizable) and (HS.Visible) and (HS.FSaveSize <> -1) then
        begin
          HS.Width := min(HS.FSaveSize, ClientWidth);
          if HS.Width = HS.FSaveSize then HS.FSaveSize := -1;
        end;
      end;
    W := GetResizableWidth;
    if w = 0 then w := 1;
    for i := 0 to FSections.Count - 1 do // Iterate
    begin
      HS := FSections.ItemByPos[i];
      if HS.Resizable and HS.Visible then HS.Width := Round(w * HS.FStickySize);
    end; // for
    AdjustStickySize(nil);
    FOldWidth := ClientWidth;
    FInStick := false;
  end;
{$IFNDEF VCL_4_USED}
  if Assigned(FOnResize) then FOnResize(Self);
{$ELSE}
  inherited;
{$ENDIF}
end;

procedure TCustomElHeader.AllocateLineDC;
begin
  FLineDC := GetDCEx(Handle, 0, DCX_CACHE {or DCX_CLIPSIBLINGS }or DCX_PARENTCLIP
    or DCX_LOCKWINDOWUPDATE);
end;

procedure TCustomElHeader.ReleaseLineDC;
begin
  ReleaseDC(Handle, FLineDC);
end;

procedure TCustomElHeader.DrawLine;
begin
  FHeaderLineVis := not FHeaderLineVis;
  PatBlt(FLineDC, FHeaderLine, 0, 1, Parent.Height, PATINVERT);
end;

procedure TCustomElHeader.Paint;
begin
  FPainting := true;
  RedrawSections;
  FPainting := false;
end;

procedure TCustomElHeader.SetSections;
begin
  FSections.Assign(value);
end;

procedure TCustomElHeader.SetLockHeight(newValue : Boolean);
{ Sets data member FLockHeight to newValue. }
begin
  if (FLockHeight <> newValue) then
  begin
    FLockHeight := newValue;
    if (not FLockHeight) and (Parent <> nil) and (not (csLoading in Parent.ComponentState)) then
       AdjustHeaderHeight;
  end; { if }
end; { SetLockHeight }

procedure TCustomElHeader.SetFilterColor(newValue : TColor);
var
  i : integer;
  S : TElHeaderSection;
begin
  if (FFilterColor <> newValue) then
  begin
    FFilterColor := newValue;
    for i := 0 to FSections.Count - 1 do // Iterate
    begin
      S := FSections[i];
      if (S.Visible) and (S.FFilterEnabled) and (not S.FFilterIsActive) then S.UpdateSection;
    end; // for
  end; { if }
end; { SetFilterColor }

procedure TCustomElHeader.TriggerSectionAutoSizeEvent;
begin
  if (assigned(FOnSectionAutoSize)) then
    FOnSectionAutoSize(Self, Section);
end; { TriggerSectionAutoSizeEvent }

procedure TCustomElHeader.TriggerMeasureSectionEvent(Section : TElHeaderSection; var Size: TPoint);
begin
  if assigned(FOnMeasureSection) then FOnMeasureSection(Self, Section, Size); 
end;

procedure TCustomElHeader.TriggerFilterCallEvent;
begin
  if (assigned(FOnFilterCall)) then FOnFilterCall(Self, Section);
end; { TriggerFilterCallEvent }

procedure TCustomElHeader.WMLButtonDblClk(var Msg : TWMLButtonDblClk); { private }
var
  S : TElHeaderSection;
  SP : TElSectionPart;
begin
  S := GetSectionAtEx(Msg.XPos, Msg.YPos, SP);
  if (SP = espResizeArea) and (S <> nil) and (S.Resizable) then TriggerSectionAutoSizeEvent(S);
  inherited;
end; { WMLButtonDblClk }

procedure TCustomElHeader.SetActiveFilterColor(newValue : TColor);
var
  i : integer;
  S : TElHeaderSection;
begin
  if (FActiveFilterColor <> newValue) then
  begin
    FActiveFilterColor := newValue;
    for i := 0 to FSections.Count - 1 do // Iterate
    begin
      S := FSections[i];
      if (S.Visible) and (S.FFilterEnabled) and S.FFilterIsActive then S.UpdateSection;
    end; // for
  end; { if }
end; { SetFilterColor }

procedure TCustomElHeader.SetFlat(newValue : Boolean);
{ Sets data member FFlat to newValue. }
begin
  if (FFlat <> newValue) then
  begin
    FFlat := newValue;
    if (HandleAllocated) then
      Invalidate;//Repaint;
  end; { if }
end; { SetFlat }

procedure TCustomElHeader.CMHintShow(var Msg : TMessage); { private }
var
  HintInfo : PHintInfo;
  Section : TElHeaderSection;
begin
  HintInfo := PHintInfo(Msg.lParam);
  Section := GetSectionAt(HintInfo.CursorPos.X, HintInfo.CursorPos.Y);
  if (Section <> nil) and (Section.Hint <> '') then HintInfo.HintStr := Section.Hint;
  FHintSection := Section;
end; { CMHintShow }

procedure TCustomElHeader.SetImages(newValue : TImageList);
{ Sets data member FImages to newValue. }
begin
  if (FImages <> newValue) then
  begin
    if FImages <> nil then
      FImages.UnRegisterChanges(FImageChangeLink);
    FImages := newValue;
    if FImages <> nil then
    begin
      FImages.RegisterChanges(FImageChangeLink);
      FImages.FreeNotification(Self);
      if not LockHeight then
         AdjustHeaderHeight;
    end
    else
    if not LockHeight then
      AdjustHeaderHeight;
    if FPainting then exit;
    if (HandleAllocated) then
      Invalidate;//Repaint;
  end; { if }
end; { SetImages }

procedure TCustomElHeader.OnImageListChange(Sender : TObject); { private }
begin
  if FPainting then exit;
  if not LockHeight then
    AdjustHeaderHeight;
  if (HandleAllocated) then
    Invalidate;//Repaint;
end; { OnImageListChange }

procedure TCustomElHeader.DoVisChanged(Section : TElHeaderSection); { protected }
begin
  if Assigned(FOnVisibleChange) then FOnVisibleChange(Self, Section);
end; { DoVisChanged }

procedure TCustomElHeader.DoSectionDelete(Section : TElHeaderSection); { protected }
begin
  if assigned(FOnSectionDelete) then FOnSectionDelete(Self, Section);
end; { DoSectionDelete }

procedure TCustomElHeader.DoSectionMove(Section : TElHeaderSection; OldPos, NewPos : integer); { protected }
begin
  if assigned(FOnSectionMove) then FOnSectionMove(Self, Section, OldPos, NewPos);
end; { DoSectionMove }

procedure TCustomElHeader.DoSectionResizing(Section : TElHeaderSection; State : TElHResizingStates; NewWidth : integer); { protected }
begin
  if Assigned(FOnSectionResizing) then FOnSectionResizing(Self, Section, State, NewWidth);
end; { DoSectionResizing }

procedure TCustomElHeader.DoSectionResize(Section : TElHeaderSection); { protected }
begin
  if Assigned(FOnSectionResize) then FOnSectionResize(Self, Section);
end; { DoSectionResize }

procedure TCustomElHeader.DoSectionClick(Section : TElHeaderSection); { protected }
begin
  if (Assigned(FOnSectionClick)) then FOnSectionClick(Self, Section);
end; { DoSectionClick }

procedure TCustomElHeader.DoSectionDraw(Section : TElHeaderSection; R : TRect; Pressed : boolean); { protected }
begin
  if Assigned(FOnSectionDraw) then FOnSectionDraw(Self, Section, R, Pressed);
end; { DoSectionDraw }

procedure TCustomElHeader.DoNotifySectionChange(Section : TElHeaderSection; Change : TSectionChangeMode);
begin
  if (assigned(FOnSectionChange)) then
    FOnSectionChange(Self, Section, Change);
end; { TriggerSectionChangeEvent }

procedure TCustomElHeader.OnFontChange(Sender : TObject); { protected }
begin
  if not LockHeight then
     AdjustHeaderHeight;

  Canvas.Font.Assign(Font);
  if (HandleAllocated) then
    Invalidate;//Repaint;
end; { OnFontChange }

procedure TCustomElHeader.DoSectionCreate(Section : TElHeaderSection);
begin
  if (assigned(FOnSectionCreate)) then FOnSectionCreate(Self, Section);
end; { TriggerSectionCreateEvent }

procedure TCustomElHeader.GetDragImage; { private }
var //i : integer;
  R : TRect;
  S : TElHeaderSection;

begin
  S := GetSectionAt(XPos, 0);
  if S = nil then exit;
  R := GetSectionRect(S.Index);
  DragRect := R;
  DragBmp := TBitmap.Create;
  DragBmp.Height := R.Bottom - R.Top + 1;
  DragBmp.Width := R.Right - R.Left + 1;
  DragBmp.Canvas.Brush.Color := Color;
  R := Rect(0, 0, DragBmp.Width - 1, DragBmp.Height - 1);
  DragBmp.Canvas.FillRect(R);
  DragBmpMask := TBitmap.Create;
  DragBmp.Canvas.Font.Assign(Font);
  RedrawSection(DragBmp.Canvas, S, R);
  DragBmpMask.Width := DragBmp.Width;
  DragBmpMask.Height := DragBmp.Height;
  DragBmpMask.Canvas.CopyRect(R, DragBmp.Canvas, R);
{$IFNDEF VER90}
  DragBmpMask.Mask(Color);
{$ENDIF}
end; { GetDragImage }

procedure TCustomElHeader.SetTracking(newValue : boolean);
begin
  if FTracking <> newValue then
  begin
    FTracking := newValue;
    if not FTracking then
    begin
      FTrackSection := nil;
      if (HandleAllocated) then
        Invalidate;//Repaint;
    end;
  end;
end;

procedure TCustomElHeader.WMEraseBkgnd(var Msg : TWMEraseBkgnd); { private }
begin
  Msg.Result := 1;
end; { WMEraseBkgnd }

{$ifdef SUPPORT_STORAGE}
procedure TCustomElHeader.Save;
var
  SaveKey, CKey : string;
  i : integer;
begin
  if Assigned(FStorage) then
  begin
    SaveKey := FStorage.CurrentKey;
    if FStorage.OpenKey(StoragePath + FStorage.Delimiter + 'ElHeader', true) then
    begin
      FStorage.WriteInteger(CKey, 'Width', Width);
      for i := 0 to FSections.Count - 1 do // Iterate
      begin
        CKey := 'Section' + IntToStr(i);
        FStorage.WriteBool(CKey, 'Visible', FSections[i].FVisible);
        FStorage.WriteBool(CKey, 'Expanded', FSections[i].Expanded);
        FStorage.WriteInteger(CKey, 'Width', FSections[i].Width);
        FStorage.WriteInteger(CKey, 'SortOrder', Integer(FSections[i].SortMode));
      end; // for
      FStorage.OpenKey(SaveKey, false);
    end;
  end;
end; {Save}

procedure TCustomElHeader.Restore;
var
  SaveKey, CKey : string;
  i, j, k : integer;
  b : boolean;
begin
  inc(LoadingCount);
  if Assigned(FStorage) then
  begin
    SaveKey := FStorage.CurrentKey;
    if FStorage.OpenKey(StoragePath + FStorage.Delimiter + 'ElHeader', false) then
    begin
      FStorage.ReadInteger(CKey, 'Width', Width, k);
      for i := 0 to FSections.Count - 1 do // Iterate
      begin
        CKey := 'Section' + IntToStr(i);
        FStorage.ReadBool(CKey, 'Visible', FSections[i].FVisible, FSections[i].FVisible);
        if FStorage.ReadBool(CKey, 'Expanded', FSections[i].Expanded, b) then FSections[i].Expanded := b;
        if FStorage.ReadInteger(CKey, 'Width', FSections[i].Width, j) then
          if ((FSections[i].Resizable) and (StickySections)) then
            FSections[i].Width := Trunc(j * (Width / k))
          else
            FSections[i].Width := j;
        if FStorage.ReadInteger(CKey, 'SortOrder', Integer(FSections[i].SortMode), j) then FSections[i].SortMode := TElSSortMode(j);
      end; // for
      FStorage.OpenKey(SaveKey, false);
    end;
  end;
  dec(LoadingCount);
  b := FStickySections;
  FStickySections := false;
  SetStickySections(b);
end; {Restore}
{$ENDIF}

procedure TCustomElHeader.EditExit(Sender : TObject);
begin
  if FDoingLookup then
  begin
    FLookup.Visible := false;
    FDoingLookup := false;
    DoSectionLookupDoneEvent(FLookupSection, FLookup.Text, false);
    try
      Windows.SetFocus(FFocusedCtl);
    except
      on E : Exception do
      begin
      end;
    end;
  end;
end;

procedure TCustomElHeader.EditChange;
var
  S : string;
begin
  if not FIgnoreLookupChange then
  begin
    S := FLookup.Text;
    DoSectionLookupEvent(FLookupSection, S);
    if S <> FLookup.Text then
    begin
      FIgnoreLookupChange := true;
      FLookup.Text := S;
      FIgnoreLookupChange := false;
    end;
  end;
end;

procedure TCustomElHeader.EditKeyUp(Sender : TObject; var Key : Word; Shift : TShiftState);
begin
  if (Shift = []) and ((Key = VK_RETURN) or (Key = VK_ESCAPE)) then Key := 0;
end;

procedure TCustomElHeader.EditKeyDown(Sender : TObject; var Key : Word; Shift : TShiftState);
var
  i : integer;
begin
  if (Shift = []) then
  begin
    if Key = VK_RETURN then
    begin
      FDoingLookup := false;
      DoSectionLookupDoneEvent(FLookupSection, FLookup.Text, true);
      i := FLookupSection.FLookupHist.IndexOf(FLookup.Text);
      if i <> -1 then FLookupSection.FLookupHist.Delete(i);
      FLookupSection.FLookupHist.Insert(0, FLookup.Text);
      FLookup.Visible := false;
      try
        Windows.SetFocus(FFocusedCtl);
      except
        on E : Exception do
        begin
        end;
      end;
      Key := 0;
    end;
    if Key = VK_ESCAPE then
    begin
      FDoingLookup := false;
      DoSectionLookupDoneEvent(FLookupSection, FLookup.Text, false);
      FLookup.Visible := false;
      try
        Windows.SetFocus(FFocusedCtl);
      except
        on E : Exception do
        begin
        end;
      end;
      Key := 0;
    end;
  end;
end;

{$ifdef SUPPORT_STORAGE}
procedure TCustomElHeader.SetStorage(newValue : TElIniFile);
begin
  if newValue <> FStorage then
  begin
    FStorage := newValue;
    if FStorage <> nil then
      FStorage.FreeNotification(Self);
  end;
end;
{$ENDIF}

procedure TCustomElHeader.Notification(AComponent : TComponent; Operation : TOperation);
var
  i : integer;
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
{$ifdef SUPPORT_STORAGE}
    if AComponent = FStorage then FStorage := nil;
{$ENDIF}
    if AComponent = Images then
       Images := nil;
{$IFDEF ELPACK_COMPLETE}
    if AComponent = FImgForm then
    begin
      FImgForm := nil;
      if (HandleAllocated) then
        Invalidate;
    end;
{$ENDIF}
    if AComponent is TPopupMenu then
      for i := 0 to FSections.Count - 1 do
        if TElHeaderSection(FSections.FList[i]).FPopupMenu = AComponent then TElHeaderSection(FSections.Item[i]).FPopupMenu := nil;
  end;
end;

procedure TCustomElHeader.DoSectionExpandEvent(Section : TElHeaderSection);
begin
  if (assigned(FOnSectionExpand)) then FOnSectionExpand(Self, Section);
end;

procedure TCustomElHeader.DoSectionCollapseEvent(Section :
  TElHeaderSection);
begin
  if (assigned(FOnSectionCollapse)) then FOnSectionCollapse(Self, Section);
end;

procedure TCustomElHeader.DoSectionLookupEvent;
begin
  if (assigned(FOnHeaderLookup)) then FOnHeaderLookup(Self, Section, Text);
end; {TriggerHeaderLookupEvent}

procedure TCustomElHeader.DoSectionLookupDoneEvent;
begin
  if (assigned(FOnHeaderLookupDone)) then FOnHeaderLookupDone(Self, Section, Text, Accepted);
end; {TriggerHeaderLookupDoneEvent}

procedure TCustomElHeader.WMRButtonUp(var Msg : TWMRButtonUp);
begin
  if FResizing then
  begin
    Msg.Result := 0;
    exit;
  end;
  inherited;
end; {WMRButtonUp}

procedure TCustomElHeader.WMRButtonDown(var Msg : TWMRButtonDown);
var
  S : TElHeaderSection;
  P : TPoint;
begin
  if FResizing then
  begin
    Msg.Result := 0;
    exit;
  end;
  S := Self.GetSectionAt(Msg.XPos, Msg.YPos);
  P := ClientToScreen(Point(Msg.XPos, Msg.YPos));
  if (S = nil) or (S.PopupMenu = nil) then
  begin
    if Assigned(PopupMenu) and (PopupMenu.AutoPopup) then PopupMenu.Popup(P.X, P.Y);
  end
  else if S.FPopupMenu.AutoPopup then
    S.FPopupMenu.Popup(P.X, P.Y);
  Msg.Result := 1;
end;

procedure TCustomElHeader.Loaded;
var
  i : integer;
  O : TComponent;
  Form : TForm;
  b : boolean;
begin
  inherited Loaded;
  Form := ElVCLUtils.GetOwnerForm(Self);
  if Form = nil then exit;
  for i := 0 to FSections.Count - 1 do
  begin
    if FSections[i].FPopupName <> '' then
    begin
      O := Form.FindComponent(FSections[i].FPopupName);
      if (O <> nil) and (O is TPopupMenu) then FSections[i].FPopupMenu := TPopupMenu(O);
    end;
  end;
  b := FStickySections;
  FStickySections := false;
  SetStickySections(b);
  if RightAlignedOrder then
  begin
    FRightAlignedOrder := false;
    RightAlignedOrder := true;
  end;
end;

procedure TCustomElHeader.WMSize(var Msg : TWMSize);
var
  i : integer;
begin
  for i := 0 to Sections.Count - 1 do // Iterate
  begin
    if (Sections[i].LookupEnabled) or (Sections[i].FilterEnabled) then
    begin
      if (Height > 0) and (Height < 17) then Height := 17;
      break;
    end;
  end; // for
{$IFNDEF VCL_4_USED}
  Resize;
{$ELSE}
  inherited;
{$ENDIF}
end;

procedure TCustomElHeader.SetStickySections(newValue : Boolean);
var
  i, w : integer;
  HS : TElHeaderSection;
begin
  if IsLoading then
  begin
    FStickySections := newValue;
    exit;
  end;
  //if (FStickySections <> newValue) then
  begin
    FStickySections := newValue;
    if newValue then
    begin
      w := GetResizableWidth;
      if w = 0 then w := 1;        
      for i := 0 to FSections.Count - 1 do // Iterate
      begin
        HS := FSections[i];
        if HS.Visible and (HS.Resizable) and (not IsLoading) and (w <> 0) then
          HS.FStickySize := HS.Width / w
        else
          HS.FStickySize := 0;
      end; // for
    end;
  end; {if}
end; {SetStickySections}

function TCustomElHeader.IsLoading : Boolean;
begin
  if Owner <> nil then
  begin
    result := (csLoading in ComponentState) or (LoadingCount > 0);
    if not result then result := csLoading in Owner.ComponentState;
  end
  else
  begin
    result := csLoading in ComponentState;
  end;
end; {IsLoading}

procedure TCustomElHeader.SetRightAlignedText(newValue : Boolean);
begin
  if (FRightAlignedText <> newValue) then
  begin
    FRightAlignedText := newValue;
    RecreateWnd;
  end; {if}
end;

procedure TCustomElHeader.CreateParams(var Params : TCreateParams);
begin
  inherited;
  if RightAlignedText then
  begin
    Params.ExStyle := Params.ExStyle or WS_EX_RTLREADING or WS_EX_LEFTSCROLLBAR or WS_EX_RIGHT;
  end;
end;

procedure TCustomElHeader.SetRightAlignedOrder(newValue : Boolean);
var
  FList : TElList;
  i : integer;
begin
  if (FRightAlignedOrder <> newValue) then
  begin
    FRightAlignedOrder := newValue;
    if csLoading in ComponentState then exit;
    FList := TElList.Create;
    for i := 0 to FSections.FList.Count - 1 do
      FList.Add(FSections.FList[FSections.FList.Count - i - 1]);
    FSections.FList.Clear;
    for i := 0 to FList.Count - 1 do
      FSections.FList.Add(FList[i]);
    FList.Free;
  end; {if}
end;

procedure TCustomElHeader.CMSysColorChange(var Msg: TMessage);
begin
  inherited;
  Invalidate;//Repaint;
end;

function TCustomElHeader.GetIsDesigning : Boolean;
{ Returns the value of data member FIsDesigning. }
begin
  result := csDesigning in ComponentState;
end;  { GetIsDesigning }

procedure TCustomElHeader.SetIsDesigning(newValue : Boolean);
{ Sets data member FIsDesigning to newValue. }
begin
  if (IsDesigning <> newValue) then
  begin
    SetDesigning(newValue);
  end;  { if }
end;  { SetIsDesigning }

procedure TCustomElHeader.SetInvertSortArrows(newValue : Boolean);
{ Sets data member FInvertSortArrows to newValue. }
begin
  if (FInvertSortArrows <> newValue) then
  begin
    FInvertSortArrows := newValue;
    if (HandleAllocated) then
      Invalidate;//Repaint;
  end;  { if }
end;  { SetInvertSortArrows }

procedure TCustomElHeader.WMPaint(var Msg : TWMPaint);  { private }
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  R : TRect;
  ARgn : HRGN;

begin
  if (Msg.DC <> 0) then PaintHandler(Msg)
  else
  begin
    DC := GetDC(0);
    MemBitmap := CreateCompatibleBitmap(DC, ClientRect.Right, ClientRect.Bottom);
    ReleaseDC(0, DC);
    MemDC := CreateCompatibleDC(0);
    OldBitmap := SelectObject(MemDC, MemBitmap);
    try
      DC := BeginPaint(Handle, PS);
      GetClipBox(DC, R);
      if IsRectEmpty(R) then
        R := ClientRect
      else
      begin
        InflateRect(R, 1, 1);
      end;

      with R do ARgn := CreateRectRgn(Left, Top, right, Bottom);
      SelectClipRgn(MemDC, ARgn);
      //InvalidateRect(MemDC, @R, false);
      Perform(WM_ERASEBKGND, MemDC, MemDC);
      Msg.DC := MemDC;
      WMPaint(Msg);
      SelectClipRgn(MemDC, 0);
      DeleteObject(ARgn);
      Msg.DC := 0;
      with R do
        BitBlt(DC, Left, Top, Right, Bottom, MemDC, Left, Top, SRCCOPY);
      EndPaint(Handle, PS);
    finally
      SelectObject(MemDC, OldBitmap);
      DeleteDC(MemDC);
      DeleteObject(MemBitmap);
    end;
  end;
end;  { WMPaint }
{$IFDEF ELPACK_COMPLETE}
procedure TCustomElHeader.ImageFormChange(Sender : TObject);
begin
  if (HandleAllocated) then
    Invalidate;
end;

procedure TCustomElHeader.SetImageForm(newValue : TElImageForm);
begin
  if FImgForm <> newValue then
  begin
    if FImgForm <> nil then
       FImgForm.UnregisterChanges(FImgFormChLink);
    if newValue <> nil then
       newValue.FreeNotification(Self);
    FImgForm := newValue;
    if FImgForm <> nil then
    begin
      FImgForm.RegisterChanges(FImgFormChLink);
      FImgForm.FreeNotification(Self);
    end;
    RecreateWnd;
    Perform(CM_COLORCHANGED, 0, 0);
  end;
end;
{$ENDIF}
procedure TCustomElHeader.SetLeftPos(newValue : Integer);
{ Sets data member FLeftPos to newValue. }
begin
  if (FHPos <> newValue) then
  begin
    FHPos := newValue;
    if (HandleAllocated) then
      Invalidate;//Repaint;
  end;  { if }
end;  { SetLeftPos }

procedure TCustomElHeader.CMExit(var Msg : TCMExit);  { private }
var P : TPoint;
begin
  inherited;
  if FPressed or FResizing or (FDropSrc <> nil) then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);
    MouseUp(mbLeft, [], P.X, P.Y);
  end;
end;  { CMExit }

function TElHeaderSections.GetSectionsOrder : string;
var
  i : integer;
  Section : TElHeaderSection;

begin
  result := '';
  for i := 0 to FList.Count - 1 do
  begin
    Section := TElHeaderSection(FList[i]);
    result := result + 'i' + IntToStr(Section.Index) + ':w' + IntToStr(Section.Width) + ':v';
    if Section.Visible then
      result := result + 't,'
    else
      result := result + 'f,';
  end;
end; { GetSectionsOrder }

procedure TElHeaderSections.SetSectionsOrder(newValue : string);
var
  i : integer;
  Section : TElHeaderSection;
  s : string;
begin
  i := 0;
  while newValue <> '' do
  begin
    s := copy(newValue, 2, pos(':', newValue) - 2);
    delete(newValue, 1, pos(':', newValue));
    Section := Item[StrToInt(s)];
    MoveSection(Section, i);
    s := copy(newValue, 2, pos(':', newValue) - 2);
    delete(newValue, 1, pos(':', newValue));
    Section.Width := StrToInt(s);
    if (pos('vf,', newValue) = 1) or (pos('vf;', newValue) = 1) then
      Section.Visible := false
    else
      Section.Visible := true;
    delete(newValue, 1, 3);
    inc(i);
  end;
end; { SetSectionsOrder }

procedure TCustomElHeader.BeginUpdate;
begin
  inc(FUpdateCount);
end;

procedure TCustomElHeader.EndUpdate;
begin
  dec(FUpdateCount);
  if FUpdateCount = 0 then Update;
end;

procedure TCustomElHeader.Update;
begin
  if FUpdateCount = 0 then
    inherited;
end;

{$IFDEF ELPACK_COMPLETE}
function TCustomElHeader.Setup: boolean;
var
  Form: TfrmHeaderSetup;
begin
  Application.CreateForm(TfrmHeaderSetup, Form);
  Form.LoadHeaderSections(FSections);
  Result := (Form.ShowModal = mrOk);
  if Result then Form.SaveHeaderSections(FSections);
  Form.Free;
end;
{$ENDIF}

{$IFNDEF LITE}
procedure TCustomElHeader.SetWrapCaptions(newValue : Boolean);
{ Sets data member FWrapCaptions to newValue. }
begin
  if (FWrapCaptions <> newValue) then
  begin
    FWrapCaptions := newValue;
    AdjustHeaderHeight;
  end;  { if }
end;  { SetWrapCaptions }
{$ENDIF}

end.


