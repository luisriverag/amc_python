{$D-}
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2001, EldoS                   }
{                                                    }
{====================================================}

(*

Version History

09/08/2015 by Soulsnake

  Fixed a problem of scrolling with some mouse drivers (comment code in CMMouseWheel function)

07/01/2012 by Soulsnake

  Added FFullVisible variable
  Modified FillFullVisFwd(StartIndex: integer) to fill FFullVisible variable
  Fixed a bug in EnsureVisible/EnsureVisibleBottom function by using FFullVisible instead of FVisible

20/11/2011 by Soulsnake

  Some Mods/Fixes
  Added possibility to use CheckBoxColor.

06/28/2001

  Fixed format for Date and Time inplace editors.

06/21/2001

  Added ElCellStyle.UseBkColor. This property defines whether CellBkColor and
  TextBkColor properties of ElCellStyle object are used.

06/06/2001

  Now empty space between image and text belongs to text and GetItemAt
  returns ipText. As result, one can select the item by clicking this empty space

06/05/2001

  HideSelection property was reset (and so lost) under certain conditions. Fixed.

06/03/2001

  Horizontal scroll thumb size changed

06/02/2001

  Default for LineHintTimeout was not set correctly. It is 3000 ms now and is
  set fine.

05/29/2001

  Fixed the problem that appears in treecombo, when MouseDown is called and tree
  is already not visible (tree combo has been closed).  

05/21/2001

  OnAfterSelectionChange was triggered when no selection change happened during
  keyboard operation.
  Such behaviour has been improved (although this event doesn't guarantee, that
  actual selection has been changed during keyboard operation).

  FullExpand and FullCollapse methods could corrupt update counter if no children
  were available for some items. Fixed.

05/12/2001

  LineHintTimeout property added. 

04/26/2001

  DrawLine function fixed -- worked incorrectly on Riva TNT 2 video cards (and
  maybe some others)

04/18/2001

  Vertical scrollbar behaviour changed to reflect the total/on-screen ratio
  (before the change scrollbar reflected total/1 ratio) 

  Fixed the problem with select when clicking on expand button

  Fixed the problem of redrawing items when some window is slowly dragged over
  the tree 

04/13/2001

  Added ScrollBarOpposite to allow left-aligned scrollbar. Works with custom
    scrollbars only.

  Fixed the bug with incorrect drag image when multiple items were dragged while
    DragImageKind was set to dimOne or dimNever.
  BevelKind property is ignored now (this is better than drawing garbage) 
  Sorting improved

04/10/2001

  Fixed AV that happened when cancelling the inplace editor

04/04/2001

  Fixed the incorrect default for RightClickSelect property

============================== Version 2.78 ====================================

03/30/2001

  Added ipPicture2 to hit states

03/26/2001 (c) Akzhan Abdulin

  Currency inplace editor setup fixed.

  Inplace editors placement fixed.

  Sorting preparation step modified, currency sorting fixed.

03/15/2001

  Shift+down pressed twice in the end of the list in mutliselect mode
  selected all items. Fixed.

03/14/2001 (c) Akzhan Abdulin

  Incremental search now works correctly with international
  and shifted characters.

  Item comparison and insertion methods now correctly compares
  international strings using Windows locale.

  Types used by event handlers defined inside unit.

  Minor code optimizations and readness improvements.
  Unnecessary variables, 'if' statements excluded, some 'while' statements
  replaced with 'for' statements. DrawLine dot line drawing rewritten.

03/10/2001

  Fixed possible AVs that could happen when image list is removed.

  Minor optimizations and readness improvements.

  Added automatic scrolling of the item, which is expanded and it's children
  don't fint into view.

03/01/2001

  RootItem  property  added  to  ElTreeItems.  Lets application randomly access
  0-level items

  Fixed the bug with incorrect section width when ImageIndex2 is set in code
  before the tree is shown for the first time

  Added indentation to the cell contents

02/23/2001

  Added ELTREE_USE_INPLACE_EDITORS directive
  Added ELTREE_USE_STYLES directive
  Added ELTREE_USE_OLE_DRAGDROP directive
  Added ELTREE_USE_EXT_EDITORS directive

  Added new drag target drawing styles

  VisibleRowCount property added.

  DragExpandDelay property added.

  Incremental Search added.

  Currency inplace editor and currency field type added.

02/15/2001

  OnAfterSelectionChange event added. It is fired after user changes selection
  using mouse or keyboard. This event is especially useful when you need to
  enable/disable some controls to reflect possibility to perform some action with
  selected items (Delete button/menu item is a perfect sample).

  DragRectAcceptColor and DragRectDenyColor properties added.

02/08/2001                                         

  Fixed the problem with Header Height in case of change of tree's
  (and header's) font

01/31/2001

  Shift-Tab navigation fixed.
  Default for ExpandOnDoubleClick set to true.

============================== Version 2.77 ====================================

01/20/2001

  ChangeDelay property added. It sets delay time between focus
is moved with keyboard and OnItemFocused event is fired.

01/16/2001

  MoveFocusOnCollapse property didn't work. Fixed.

12/30/2000

  OnItemChecked event added
  Fixed possible AVs that could happen when drag'n'drop is started

12/25/2000

  Christmas gift -- sorting and other operations improved. Sorting is about 100
  times faster now.

12/21/2000

  Item hints added. Now every item can have its own hint and you don't need to implement
  OnItemHintNeeded event handler to provide a hint for the item

12/16/2000

  Centering of item cell text was incorrect under some circumstances. Fixed.

  Opening a dialog form in responce to MouseDown caused further problems with
  selecting items. Fixed.

12/14/2000

  IterateBranch method added.

  Fixed focus movement in AutoExpand mode.

============================== Version 2.76 ====================================

12/06/2000

  Items text, that contains "&" was drawing with end-ellipse at the end. Fixed.
  Disabled items now don't react on clicks and can't be selected with keyboard.

============================== Version 2.75 ====================================

11/04/2000

  Improved vertical alignment of text when drawing multiline and HTML items

10/27/2000

  Fixed the bug, when the height for multiline items with no multiline main text
  (i.e. the item where only column text is multiline) was defined incorrectly.

10/26/2000

  Fixed the bug, that slows down scrolling after 2.74.

10/25/2000

  Added edition of multiline items

============================== Version 2.74 ====================================

10/21/2000

  Property UseCustomScrollBars added. Now you can use standard Windows or custom
  scrollbars.
  Support for mouse wheel in Windows 95 added (Delphi 4/5 and C++Builder 4/5 only).
  Support for Genius and Microsoft mouse drivers (autoscroll feature) added.

10/17/2000

  Added Item.DataInterface property to keep interface reference in it

10/12/2000

  Selecting multiple items with keyboard or mouse worked not always properly.
  Fixed.

10/10/2000

  Divider lines were not painted after 10/06/2000 (v2.73). Fixed.
  Items with multiline main text are supported now. WARNING: enabling multiline
    significantly slows down the tree

10/06/2000

  Fixed drawing of cell text when styles are defined

10/04/2000

  HeaderColor property added
  Vertical alignment of the item main text is the same as of the cell text
  Tree font style is not spoiled when the item that is dragged has
  ParentStyle = false
  RowBkColor is not used if UseBkColor is false

10/01/2000

  Backspace key moves focus to the parent item now.

09/30/2000

  UseSystemHintColors property added. Allows to show item hints using system
  colors instead of tree colors
  Speed optimized by changing IndexOf to IndexOfFrom in some important iteration
  methods.

09/25/2000

  Added ElTreeItem.RowBkColor property. Allows to define a color for the whole
  item row

09/20/2000

  Automatical resizing of columns worked incorrectly for columns after the main
  one. Fixed

09/05/2000

  DoubleBuffered made obsolete.

09/01/2000

  OnEndDrag event didn't work. Fixed.

08/15/2000.

  Added ElTreeItems.AddLastItem method.
  Made ElCellStyle.Assign method public. 
  ItemExt constant now is the tree's property

07/31/2000.

  Fixed the LockedHeaderHeight property loading.
  Fixed the cell button text color.

07/29/2000.

  Checkbox clicks moved from MouseDown to MouseUp to correctly process
  double-clicks.

  Selecting items with mouse in simple SelectionMode fixed.

07/19/2000.

  AlwaysKeepFocus property added. This property prevents the tree from setting
  ItemFocused to nil when the user clicks empty space.

  LineHintColor property added. This property defines the color of the line hint. 

  ElTreeItem.UseBkColor property added. If item uses own colors, background of
  the text is filled with BkColor. To prevent this (for example, when background
  image is used in the tree), set UseBkColor property to false.

07/09/2000.

  Added TElTreeItem.AnObject property. This property can be used as a simple
  placeholder for the object references, as Data is used to hold pointers.

07/02/2000.
  Different routines changed to improve speed of scrolling in keyboard operations.
  FillVisFwd fixed to ensure correct scrolling when FilteredVisibility enabled.

*)

unit ElTree;

{$I ElPack.inc}

{$B-}

{$RANGECHECKS OFF}
{$ALIGN ON}

{$define PaintBackground}

interface

uses
  Dialogs,
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  StdCtrls,
  ExtCtrls,
  ElTools,
  ElHeader,
  ElList,
  ElScrollBar,
  ElStrUtils,
  ElHintWnd,
  ComCtrls,
{$ifdef ELTREE_USE_STYLES}
  Buttons,
{$endif}
{$IFDEF ELPACK_COMPLETE}
{$ifdef SUPPORT_STORAGE}
  ElIni,
{$endif}
{$ifdef ELTREE_USE_STYLES}
  ElPopBtn,
{$endif}
{$IFDEF ELTREE_USE_INPLACE_EDITORS}
{$ifdef ELTREE_USE_EXT_EDITORS}
  ElBtnEdit,
  ElACtrls,
  ElDTPick,
  ElCurrEdit,
  ElCheckCtl,
{$endif}
{$ENDIF}
  ElImgFrm,
  ElTimers,
{$ENDIF}
{$IFDEF HAS_HTML_RENDER}
  ElArray,                     
  HTMLRender,
{$ENDIF}
{$IFDEF VCL_4_USED}
  ImgList,
  ActnList,
{$ENDIF}
  ElVCLUtils,
{$IFNDEF VER90}
  ActiveX,
{$ENDIF}
  Menus;

{$R *.res}

type
  TElHeaderSection = ElHeader.TElHeaderSection;
  TCustomElHeader = ElHeader.TCustomElHeader;
  TFieldTypes = ElHeader.TFieldTypes;
  TElScrollBarPart = ElScrollBar.TElScrollBarPart;

const
  stsFocused = 1; // TElTreeItem states
  stsSelected = 2;
  stsCut = 3;
  stsUnderlined = 4;
  stsBold = 5;
  stsItalic = 6;
  stsExpanded = 7;
  stsStrikeOut = 8;
  stiMaxState = 8;

  tisFocused    = 1;
  tisSelected   = 2;
  tisCut        = 4;
  tisExpanded   = 8;
  tisBold       = 16;
  tisItalic     = 32;
  tisUnderlined = 64;
  tisStrikeout  = 128;

type
  TSTIStates = set of 1..stiMaxState;

type
  EElTreeError = class(Exception)
  end;

resourcestring
  STExOutOfBounds = 'ElTree item index out of bounds.';
  STexInvItem = 'ElTree item not specified';
  STexRecursiveMove = 'Can''t move Item to one of its subitems.';

type
  TItemChangeMode = (icmText, icmState, icmCheckState);

type
  TSTItemPart =  (ipButton, ipMainText, ipColumn, ipInside, ipPicture, ipPicture2, ipCheckBox);
  TSTSelModes =  (smSimple, smUsual);
  TSortDirs =    (sdAscend, sdDescend);
  TSortModes =   (smNone, smAdd, smClick, smAddClick);
  TSortTypes =   (stCustom, stText, stNumber, stFloating, stDateTime, stDate, stTime, stBoolean, stCurrency);
  THintModes =   (shmNone, shmLong, shmAll);
  TElHintType  = (shtMainText, shtHintOnly, shtHintOrText);
  TDragImgMode = (dimNever, dimOne, dimAll);
  TNodeAttachMode = (naAdd, naAddFirst, naAddChild, naAddChildFirst, naInsert);
  TElCheckBoxType = (ectCheckBox, ect3SCheckBox, ectRadioButton);

type
  TElDragType = (dtOLE, dtDelphi, dtBoth);

type
  TDragTargetDraw = (ColorFrame,
                     ColorRect,
                     SelColorRect,
                     dtdNone,
                     dtdUpColorLine,
                     dtdDownColorLine,
                     dtdUpSelColorLine,
                     dtdDownSelColorLine);
     // ColorFrame - usual background, color frame
     // ColorRect  - green rect (drop allowed) or red rect (drop not allowed)
     // SelColorRect - usual selected color rect

// *****************************************************************************

type
  TCustomElTree = class;
  TElTreeItem = class;
  TElTreeItems = class;
{$ifdef ELTREE_USE_STYLES}
  TElCellStyle = class;
{$else}
  TElCEllStyle = class end;
{$endif}
  TElTreeView = class;

{$ifdef ELTREE_USE_STYLES}
{$warnings off}
  TElCellControl = class(TComponent)
  private
    FPopupMenu: TPopupMenu;
    FOwner: TElCellStyle;
    FCaption: TCaption;
       //FBoundsRect : TRect;
    FVisible: Boolean;
    FEnabled: boolean;

    FOnClick: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseUp: TMouseEvent;
    FOnDblClick: TNotifyEvent;
    FOnMouseMove: TMouseMoveEvent;

    procedure SetPopupMenu(newValue: TPopupMenu);
  protected
       //procedure SetBoundsRect(newValue : TRect); virtual;
    procedure SetCaption(newValue: TCaption); virtual;
    procedure SetVisible(newValue: Boolean); virtual;
    procedure SetEnabled(newValue: Boolean); virtual;

    procedure TriggerClickEvent; virtual;
    procedure TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure TriggerDblClickEvent; virtual;
    procedure TriggerMouseMoveEvent(Shift: TShiftState; X, Y: Integer); virtual;
    procedure Paint(Canvas: TCanvas; Rect: TRect); virtual; abstract;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    procedure Update; virtual;
    procedure Assign(Source: TElCellControl); virtual; abstract;
    constructor Create; virtual;
    destructor Destroy; override;
  published
    property Caption: TCaption read FCaption write SetCaption;
    property Owner : TElCellStyle read FOwner;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Visible: Boolean read FVisible write SetVisible default True;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
  end;
{$warnings on}

{$IFDEF ELPACK_COMPLETE}
  TElCellCheckBox = class (TElCellControl)
  private
    FAlignment : TAlignment;
    FState     : TCheckBoxState;
    FAllowGrayed : boolean;
    procedure SetState(newValue : TCheckBoxState);
    procedure SetAllowGrayed(newValue : Boolean);
    function GetChecked : Boolean;
    procedure SetChecked(newValue : Boolean);
    procedure SetAlignment(newValue : TAlignment);
  protected
    procedure Paint(Canvas: TCanvas; R: TRect); override;
    procedure TriggerClickEvent; override;
    procedure TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    procedure Assign(Source: TElCellControl); override;
    constructor Create; override;
    destructor Destroy; override;

    property State : TCheckBoxState read FState write SetState;
    property Checked : boolean read GetChecked write SetChecked;
    property AllowGrayed : Boolean read FAllowGrayed write SetAllowGrayed; { Published }
    property Alignment : TAlignment read FAlignment write SetAlignment; { Protected }
  end;

  TElCellButtonGlyph = class(TElButtonGlyph)
    property ImageList;
    property ImageIndex;
    property UseImageList;
  end;

  TElCellButton = class(TElCellControl)
  private
    FGlyph: TElCellButtonGlyph;
    FLayout: TButtonLayout;
    FFixClick: Boolean;
    FDown: Boolean;
    FFont: TFont;
    function GetGlyph: TBitmap;
    procedure SetGlyph(newValue: TBitmap);
    procedure GlyphChanged(Sender: TObject);
    procedure FontChanged(Sender: TObject);
    procedure SetFont(newValue: TFont);
    procedure SetDown(newValue: Boolean);
    procedure SetLayout(newValue: TButtonLayout);
    function GetUseImageList : Boolean;
    procedure SetUseImageList(newValue : Boolean);
    function GetImageList : TImageList;
    procedure SetImageList(newValue : TImageList);
    function GetImageIndex : Integer;
    procedure SetImageIndex(newValue : Integer);
  protected
    procedure Paint(Canvas: TCanvas; R: TRect); override;
    procedure TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;

  public
    procedure Assign(Source: TElCellControl); override;
    constructor Create; override;
    destructor Destroy; override;
    property UseImageList : Boolean read GetUseImageList write SetUseImageList;  { Public }
    property ImageList : TImageList read GetImageList write SetImageList;  { Public }
    property ImageIndex : Integer read GetImageIndex write SetImageIndex;  { Public }

    property Glyph: TBitmap read GetGlyph write SetGlyph;
    property FixClick: Boolean read FFixClick write FFixClick;
    property Down: Boolean read FDown write SetDown default False;
    property Font: TFont read FFont write SetFont;
    property Layout: TButtonLayout read FLayout write SetLayout;
  end;

{$ENDIF}

  TElCellStyle = class
  private
    FTag: Integer;
    FOwner: TElTreeItem;
    FCellBkColor: TColor;
    FTextBkColor: TColor;
    FTextColor: TColor;
    FTextFlags: DWORD;
    FPicture: TBitmap;
    FCellType: TFieldTypes;
    FStyle: TElSectionStyle;
    FOwnerProps: Boolean;
    FFontSize: integer;
    FFontStyles: TFontStyles;
    FFontName: TFontName;
    FControl: TElCellControl;
    FUseBkColor: Boolean;
    procedure SetControl(newValue: TElCellControl);
    procedure SetFontSize(newValue: integer);
    procedure SetFontStyles(newValue: TFontStyles);
    procedure SetFontName(newValue: TFontName);
    procedure SetOwnerColors(newValue: Boolean);
    procedure SetStyle(newValue: TElSectionStyle);
    procedure SetCellBkColor(newValue: TColor);
    procedure SetTextBkColor(newValue: TColor);
    procedure SetTextColor(newValue: TColor);
    procedure SetTextFlags(newValue: DWORD);
    procedure SetPicture(newValue: TBitmap);
    procedure SetCellType(newValue: TFieldTypes);
    procedure SetUseBkColor(Value: Boolean);
  public
    constructor Create(Owner: TElTreeItem);
    destructor Destroy; override;
    procedure Assign(Source: TElCellStyle);
    procedure Update;

    property Tag: Integer read FTag write FTag;
    property Control: TElCellControl read FControl write SetControl; { Published }
    property CellBkColor: TColor read FCellBkColor write SetCellBkColor;
    property TextBkColor: TColor read FTextBkColor write SetTextBkColor;
    property TextColor: TColor read FTextColor write SetTextColor;
    property TextFlags: DWORD read FTextFlags write SetTextFlags;
    property Picture: TBitmap read FPicture write SetPicture;
    property CellType: TFieldTypes read FCellType write SetCellType;
    property Style: TElSectionStyle read FStyle write SetStyle;
    property OwnerProps: Boolean read FOwnerProps write SetOwnerColors;
    property FontSize: integer read FFontSize write SetFontSize;
    property FontStyles: TFontStyles read FFontStyles write SetFontStyles;
    property FontName: TFontName read FFontName write SetFontName;
    property Owner : TElTreeItem read FOwner;
    property UseBkColor: Boolean read FUseBkColor write SetUseBkColor;
  end;
{$endif}

  TElTreeItem = class(TPersistent)
  private
    FRec: boolean;
  protected
{$IFDEF HAS_HTML_RENDER}
    FIsHTML        : boolean;
    FHTMLData      : TElHTMLData;
    FHTMLDataArray : TElArray;
{$ENDIF}
    FTag           : Integer;
    FObject        : TObject;
    FDataInterface : IUnknown;
    {$IFDEF USE_VARIANT}
    FSortData      : Variant;
    {$ELSE}
    FSortData      : Pointer;
    FSortType      : integer;
    {$ENDIF}
    FSortRef       : integer;
    FSuppressLines : Boolean;

    FFullyVisible: Boolean;
    FHidden: Boolean;
    FEnabled: Boolean;
    FSuppressButtons: Boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
{Soulsnake Add}
    FUseCheckBoxColor: Boolean;
    FCheckBoxColor: TColor;
    FCheckColor: TColor;
{End Soulsnake Add}
{$ifdef ELTREE_USE_STYLES}
    FMainStyle: TElCellStyle;
    FUseStyles: Boolean;
{$endif}
    FState: TSTIStates;
    FIState: integer;

    FText: string; // Main text
    FColText: TStringList; // text for additional columns
    FHint   : String;
    FChildren: TElList;
    FOwner: TCustomElTree;
    FList: TElTreeItems;
    FData: pointer; // generic data
    FRowBkColor : TColor;
    FColor,
      FBkColor: TColor;
    FUseBkColor  : boolean;
    FParentColors: boolean;
    FTextLeft,
      FTextRight: integer;
    FParentStyle: boolean;
    FImageIndex,
      FStImageIndex: integer;
    FImageIndex2,
      FStImageIndex2: integer;
    FImageDrawn: boolean;
    FImageDrawn2: boolean;
    FForceButtons: boolean;
    FStyles: TElList;
    FStrikedLineColor: TColor;
    FStrikedOutLine: boolean;
    FDrawHLine: boolean;
    FAllowSelection: boolean;
    FAllowEdit: boolean;

    FParent: TElTreeItem;
    FRoot  : TElTreeItem;
    function GetParent: TElTreeItem;
    function GetLevel: integer;
    procedure SetColor(index: integer; value: TColor);
    procedure SetUseBkColor(newValue : boolean);
    function EqualColumns(cols: TStringList): boolean;
    function GetHasChildren: boolean;
    function GetHasVisibleChildren: Boolean;
    procedure SetExpanded(value: boolean);
    procedure SetParentColors(value: boolean);
    procedure SetParentStyle(value: boolean);
    function GetIndex: integer;
    function GetAbsIndex: integer;
    function GetVisIndex: integer;
    function GetChildIndex(Child: TElTreeItem): integer;
    function IsExpanded: boolean;
    function GetFullExpand: boolean;
    procedure MakeFullyExpanded(value: boolean);
    procedure OnColTextChange(Sender: TObject);
    procedure SetImageIndex(value: integer);
    procedure SetStImageIndex(value: integer);
    procedure SetImageIndex2(value: integer);
    procedure SetStImageIndex2(value: integer);
    procedure SetForceButtons(newValue: Boolean);
    function GetChildrenCount: Integer;
    function GetCount: Integer;
    function GetItems(Index: integer): TElTreeItem;
{$ifdef ELTREE_USE_STYLES}
    procedure SetUseStyles(newValue: Boolean);
{$endif}
    procedure OnStyleDelete(Sender: TObject; Item: pointer);
{$ifdef ELTREE_USE_STYLES}
    function GetStyles(index: integer): TElCellStyle;
    procedure SetStyles(index: integer; newValue: TElCellStyle);
    function GetStylesCount: Integer;
{$endif}
    procedure SetCheckBoxState(newValue: TCheckBoxState);
    procedure SetChecked(newValue: Boolean);
    function GetChecked: boolean;
    procedure SetShowCheckBox(newValue: Boolean);
    procedure SetCheckBoxType(newValue: TElCheckBoxType);
    procedure SetCheckBoxEnabled(newValue: Boolean);
{Soulsnake Add}
    procedure SetUseCheckBoxColor(newValue: Boolean);
    procedure SetCheckBoxColor(newValue: TColor);
    procedure SetCheckColor(newValue: TColor);
{End Soulsnake Add}
    procedure SetSuppressButtons(newValue: Boolean);
    procedure SetEnabled(newValue: Boolean);
    procedure SetHidden(newValue: Boolean);
    function GetFullyVisible: Boolean;
    procedure SetFullyVisible(newValue: Boolean);
    function GetSelected : boolean;
    procedure SetSelected(newValue : boolean);
    procedure CreateStyles;
    function  GetHeight : Integer;
    procedure SetSuppressLines(newValue : Boolean);
    procedure UpdateItem;
    procedure SetText(Value: string); virtual;
    function GetState(index: integer): boolean;
    procedure SetState(index: integer; value: boolean);
    procedure RemoveChild(Child: TElTreeItem);
    procedure DeleteChild(Child: TElTreeItem);
    function  AddChild(Child: TElTreeItem): integer;
    function  AddLastChild(Child: TElTreeItem): integer;
    function InsertChild(index: integer; Child: TElTreeItem): integer;
    function IsEqual(Item: TElTreeItem): boolean;
    procedure ReadData(Stream: TStream); virtual;
    procedure WriteData(Stream: TStream); virtual;
    procedure ExchangeItems(I, J: integer);

    // Sorting-related methods
    procedure QuickSort(recursive: boolean;
                        L, R: Integer;
                        SM : TElSSortMode;
                        SortType: TSortTypes;
                        FSortSection : integer);
    procedure AddSortData(SortType: TSortTypes;
                          FSortSection : integer);
    procedure ReleaseSortData;
    procedure NormalizeSorts(StartIdx : integer);
                        
    procedure SetRowBkColor(newValue : TColor); virtual;
{$IFDEF HAS_HTML_RENDER}
    procedure SetIsHTML(newValue : boolean);
    procedure OnHTMLDataDestroy(Sender :TObject; Item : Pointer);
    procedure ReRenderMainText;
    procedure ReRenderAllTexts;
{$ENDIF}
    function GetAncestor: TElTreeItem;

    procedure SetStrikedOutLine(const Value: boolean);
    procedure SetStrikedLineColor(const Value: TColor);
    function GetStrikedOutLine: boolean;
    procedure SetDrawHLine(const Value: boolean);

    procedure SetAllowEdit(const Value: boolean);
    function CalcSubItemsHeight: Integer;
  public
    constructor Create(AOwner: TCustomElTree); virtual;
    destructor Destroy; override;
    function IsUnder(Item: TElTreeItem): boolean;
    function GetFullName(separator: string): string;
    function GetFullNameEx(separator: string; AddRoot: boolean): string;
    procedure Expand(recursive: boolean);
    procedure Collapse(recursive: boolean);
    procedure Sort(recursive: boolean);
    procedure MoveTo(NewParent: TElTreeItem);
       // Moves the item to the new parent, adding it to the NewParent's
       // children list.
    procedure MoveToIns(NewParent: TElTreeItem; AnIndex: integer);
       // Moves the item to the new parent, inserting it to the NewParent's
       // children list at Index position

    procedure Clear;
    function GetFirstVisibleChild: TElTreeItem;
    function GetFirstChild: TElTreeItem;
    function GetLastChild: TElTreeItem;
    function GetNextChild(Child: TElTreeItem): TElTreeItem;
    function GetPrevChild(Child: TElTreeItem): TElTreeItem;
    function GetFirstSibling: TElTreeItem;
    function GetLastSibling: TElTreeItem;
    function GetNextSibling: TElTreeItem;
    function GetPrevSibling: TElTreeItem;
    function GetLastSubItem : TElTreeItem;
      // Get the last item, that has current item as one of its "parents"
    function GetChildByIndex(index: integer): TElTreeItem;
       // Get child item, which is on "index" position in the children list
{$IFDEF ELTREE_USE_INPLACE_EDITORS}
    procedure EditText;
       // If inline editing is allowed, the EditBox appears and the user
       // can change the Text property of the item
{$ENDIF}
    procedure Assign(Source: TPersistent); override;

    procedure Delete; virtual;
    property TreeView: TCustomElTree read FOwner;

    function IsVisible: Boolean;
    function GetNextVisible: TElTreeItem;
    function GetPrevVisible: TElTreeItem;
    function GetPrev: TElTreeItem; virtual;
    function GetNext: TElTreeItem; virtual;
    procedure MoveToItem(Item: TElTreeItem; Mode: TNodeAttachMode); virtual;
{$ifdef ELTREE_USE_STYLES}
    function AddStyle: TElCellStyle; virtual;
    procedure RemoveStyle(Style: TElCellStyle); virtual;
{$endif}
    procedure RedrawItem(DoCheck: boolean);
    procedure RedrawItemPart(DoCheck: boolean; Left, Right: integer);

    property Data: pointer read FData write FData;
       // User defined data. The ElTree doesn't free this memory when
       // the item is deleted
    property AnObject: TObject read FObject write FObject;
       // User defined data. The ElTree doesn't free this memory when
       // the item is deleted
    property Owner: TCustomElTree read FOwner;
       // Points to the item's owner ElTree component
    property Parent: TElTreeItem read GetParent write MoveTo;
       // Points to the item's parent item

    property HasVisibleChildren: boolean read GetHasVisibleChildren;
       // Shows, if the item has child items, that are not hidden

    property HasChildren: boolean read GetHasChildren;
       // Shows, if the item has child items
    property Index: integer read GetIndex;
       // This is the index of the item in the parent's children list

    property AbsoluteIndex: integer read GetAbsIndex;
       // This is the index of the item among all items in the tree

    property VisIndex: integer read GetVisIndex;
       // This is the index of the item among all expanded items in the tree

    property ChildrenCount: integer read GetChildrenCount;

    property Count: Integer read GetCount; { Public }

    property Children[Index: integer]: TElTreeItem read GetItems; { Public }
       // the same but for TTreeView compatibility

    property Item[Index: integer]: TElTreeItem read GetItems; { Public }

    property Level: integer read GetLevel;
       // Tells, on which level the item is
       // Root items have Level 0 (zero)
    property DataInterface: IUnknown read FDataInterface write FDataInterface;
    // User defined interface. Will be set to NIL before destruction to
    // decrease the reference counter.

    property Tag : Integer read FTag write FTag;

{$ifdef ELTREE_USE_STYLES}
    property Styles[index: integer]: TElCellStyle read GetStyles write SetStyles;
{$endif}

    property Ancestor: TElTreeItem read GetAncestor;

    property StrikedOutLine: boolean read GetStrikedOutLine write SetStrikedOutLine;

    property StrikedLineColor: TColor read FStrikedLineColor write SetStrikedLineColor;

    property DrawHLine: boolean read FDrawHLine write SetDrawHLine;

    property AllowSelection: boolean read FAllowSelection write FAllowSelection;

    property AllowEdit: boolean read FAllowEdit write SetAllowEdit;

  published
    property Focused: boolean index 1 read GetState write SetState;
       // The item currently has focus
    property Selected: boolean read GetSelected write SetSelected;
       // The item is marked as selected
    property Cut: boolean index 3 read GetState write SetState;
       // The item is marked as cut
    property Underlined: boolean index 4 read GetState write SetState;
       // This property sets the item's main text font style
       // This doesn't affect columns text style
    property Bold: boolean index 5 read GetState write SetState;
       // This property sets the item's main text font style
       // This doesn't affect columns text style
    property Italic: boolean index 6 read GetState write SetState;
       // This property sets the item's main text font style
       // This doesn't affect columns text style
    property StrikeOut: boolean index 8 read GetState write SetState;
       // This property sets the item's main text font style
       // This doesn't affect columns text style
    property ParentStyle: boolean read FParentStyle write SetParentStyle;
       // if ParentStyle=true, then item's font styles are ignored, and tree's
       // are used
    property Text: string read FText write SetText;
       // Main tree text
    property ColumnText: TStringList read FColText;
    // the alias for ColumnText
    property SubItems  : TStringList read FColText;
       // Text for additional columns
    property Expanded: boolean read IsExpanded write SetExpanded;
       // The item is expanded

    property FullyExpanded: boolean read GetFullExpand write MakeFullyExpanded;
       // The item and all its parent are expanded

    property Color: TColor index 1 read FColor write SetColor;
       // Color of item's text

    property BkColor: TColor index 2 read FBkColor write SetColor;
       // Color of item's text background

    property UseBkColor : boolean read FUseBkColor write SetUseBkColor;

    property ParentColors: boolean read FParentColors write SetParentColors;
       // if ParentColors=True, then Color and BkColor properties are ignored

    property ImageIndex: integer read FImageIndex write SetImageIndex;
    property StateImageIndex: integer read FStImageIndex write SetStImageIndex;

    property ImageIndex2: integer read FImageIndex2 write SetImageIndex2;
    property StateImageIndex2: integer read FStImageIndex2 write SetStImageIndex2;

    property ForceButtons: Boolean read FForceButtons write SetForceButtons default False;
    property SuppressButtons: Boolean read FSuppressButtons write SetSuppressButtons default False;
    property SuppressLines : Boolean read FSuppressLines write SetSuppressLines;  { Public }

    property Hint : String read FHint write FHint;

{$ifdef ELTREE_USE_STYLES}
    property UseStyles: Boolean read FUseStyles write SetUseStyles;
    property MainStyle: TElCellStyle read FMainStyle;
    property StylesCount: Integer read GetStylesCount;
{$endif}
    property CheckBoxState: TCheckBoxState read FCheckBoxState write SetCheckBoxState;
    property Checked: Boolean read GetChecked write SetChecked default False;
    property ShowCheckBox: Boolean read FShowCheckBox write SetShowCheckBox default True;
    property CheckBoxType: TElCheckBoxType read FCheckBoxType write SetCheckBoxType;
    property CheckBoxEnabled: Boolean read FCheckBoxEnabled write SetCheckBoxEnabled;
{Soulsnake Add}
    property UseCheckBoxColor: Boolean read FUseCheckBoxColor write SetUseCheckBoxColor default False;
    property CheckBoxColor: TColor read FCheckBoxColor write SetCheckBoxColor default $FFFFFF;
    property CheckColor: TColor read FCheckColor write SetCheckColor default $000000;
{End Soulsnake Add}
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Hidden: Boolean read FHidden write SetHidden;
    property FullyVisible: Boolean read GetFullyVisible write SetFullyVisible;
    property RowBkColor : TColor read FRowBkColor write SetRowBkColor;  { Public }
    // The color of the item background (complete, not under text
{$IFDEF HAS_HTML_RENDER}
    property IsHTML : boolean read FIsHTML write SetIsHTML;
{$ENDIF}
  end;

// *****************************************************************************

  TElTreeItemClass = class of TElTreeItem;

  TElLookupCompareProc = function(Item: TElTreeItem; SearchDetails: Pointer): boolean;
  
  TIterateProc = procedure(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);

  TElTreeItems = class(TPersistent)
  private
    FOwner: TCustomElTree;
    //FCount: integer;

    function GetItem(index: integer): TElTreeItem;
    function GetVisItem(index: integer): TElTreeItem;
  protected
    FRoot: TElTreeItem;
    FItemClass : TElTreeItemClass;
    function GetVisCount: integer;
    procedure ReadData(Stream: TStream); virtual;
    procedure WriteData(Stream: TStream); virtual;
    procedure DefineProperties(Filer: TFiler); override;
    function CreateItem(FOwner: TCustomElTree): TElTreeItem; virtual;
    function GetCount : integer;
    function GetRootCount: Integer;
    function GetRootItem(Index: Integer): TElTreeItem;
  public
    procedure Assign(Source: TPersistent); override;
    constructor Create(AOwner: TCustomElTree); virtual;
    destructor Destroy; override;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(FileName: string);
    procedure LoadFromFile(FileName: string);
    procedure DeleteItem(Child: TElTreeItem);
    procedure RemoveItem(Child: TElTreeItem);
    function GetAbsIndex(Child: TElTreeItem) : integer;
    function GetVisIndex(Child: TElTreeItem) : integer;
    function AddItem(Parent: TElTreeItem)    : TElTreeItem;
    function AddLastItem(Parent: TElTreeItem): TElTreeItem;
    procedure SetItem(Index: Integer; Value: TElTreeItem);
    function InsertItem(Index: integer; Parent: TElTreeItem): TElTreeItem;
    procedure AddExistingItem(Item, Parent: TElTreeItem);
    procedure InsertExistingItem(Item, Parent: TElTreeItem; Index: integer);

    // AllocateStorage increases the size of the list, thus speeding up items adding
    procedure AllocateStorage(MaxItems : integer);
    function Add(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function AddChild(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function AddChildFirst(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function AddChildObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; virtual;
    function AddChildObjectFirst(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; virtual;
    function AddFirst(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function AddObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; virtual;
    function AddObjectFirst(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; virtual;
    function Insert(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function InsertObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; virtual;
    function InsertAfter(Item: TElTreeItem; Text: string): TElTreeItem; virtual;
    function InsertAfterObject(Item: TElTreeItem; Text: string; Ptr: Pointer): TElTreeItem; virtual;

    procedure Delete(Item: TElTreeItem); virtual;
    function GetFirstNode: TElTreeItem;

    procedure Clear;
    procedure IterateBranch(VisibleOnly: boolean; IterateProc: TIterateProc; IterateData: pointer; BranchParent: TElTreeItem);

    procedure IterateFrom(VisibleOnly: boolean; IterateProc: TIterateProc; IterateData: pointer; StartFrom: TElTreeItem);
    procedure IterateBackFrom(VisibleOnly: boolean; IterateProc: TIterateProc; IterateData: pointer; StartFrom: TElTreeItem);
    procedure Iterate(VisibleOnly: boolean; IterateProc: TIterateProc; IterateData: pointer);
    procedure IterateBack(VisibleOnly: boolean; IterateProc: TIterateProc; IterateData: pointer);

    procedure BeginUpdate; virtual;
    procedure EndUpdate; virtual;

    function LookForItem(StartItem: TElTreeItem;
      TextToFind: string;
      DataToFind: pointer;
      ColumnNum : integer;
      LookForData,
      CheckStartItem,
      SubItemsOnly,
      VisibleOnly,
      NoCase: boolean): TElTreeItem;

    function LookForItemEx(StartItem: TElTreeItem; ColumnNum: integer;
      CheckStartItem, SubItemsOnly, VisibleOnly: boolean;
      SearchDetails: pointer;
      CompareProc: TElLookupCompareProc): TElTreeItem;

    function LookBackForItemEx2(StartItem: TElTreeItem; ColumnNum: integer;
      CheckStartItem, SubItemsOnly, VisibleOnly, CheckCollapsed: boolean;
      SearchDetails: pointer;
      CompareProc: TElLookupCompareProc): TElTreeItem;


    property ItemClass : TElTreeItemClass read FItemClass write FItemClass;
    property Owner: TCustomElTree read FOwner;
    property Item[Index: integer]: TElTreeItem read GetItem; default;
    property ItemAsVis[Index: integer]: TElTreeItem read GetVisItem;
    property Count: integer read GetCount;
    property VisCount: integer read GetVisCount;
    property RootCount: Integer read GetRootCount;
    property RootItem[Index: Integer]: TElTreeItem read GetRootItem;
  end;

// *****************************************************************************

  TMeasureItemPartEvent = procedure(Sender: TObject; Item: TElTreeItem; PartIndex: integer; var Size: TPoint) of object;
  THeaderSectionEvent = procedure(Sender: TObject; Section: TElHeaderSection) of object;
  TColumnNotifyEvent = procedure(Sender: TObject; SectionIndex: integer) of object;
  TOnItemDrawEvent = procedure(Sender: TObject; Item: TElTreeItem; Surface: TCanvas;
    R: TRect; SectionIndex: integer) of object;
  TOnTextNeededEvent = procedure(Sender: TObject; Item: TElTreeItem; var Text: string) of object;
  TOnShowHintEvent = procedure(Sender: TObject; Item: TElTreeItem; var Text: string;
    HintWindow: THintWindow;
    MousePos: TPoint;
    var DoShowHint: boolean) of object;
  TApplyVisFilterEvent = procedure(Sender: TObject; Item: TElTreeItem; var Hidden: boolean) of object;

  TTuneUpInplaceEditEvent = procedure(Sender : TObject; Item : TElTreeItem; SectionIndex : integer; Editor : TCustomEdit) of object;
  TOnItemExpandEvent = procedure(Sender: TObject; Item: TElTreeItem) of object;
  TOnItemCheckedEvent = procedure (Sender: TObject; Item: TElTreeItem) of Object;
{Soulsnake Add}
  TOnItemColorPickEvent = procedure (Sender: TObject; Item: TElTreeItem) of Object;
{End Soulsnake Add}
  TItemSelChangeEvent = procedure(Sender: TObject; Item: TElTreeItem) of object;
  TOnItemChangeEvent = procedure(Sender: TObject; Item: TElTreeItem;
    ItemChangeMode: TItemChangeMode) of object;

  TOnCompareItems = procedure(Sender: TObject; Item1, Item2: TElTreeItem;
    var res: integer) of object;

  TOnItemExpanding = procedure(Sender: TObject; Item: TElTreeItem;
    var CanProcess: boolean) of object;

  TOnPicDrawEvent = procedure(Sender: TObject; Item: TElTreeItem;
    var ImageIndex: integer) of object;

  THotTrackEvent = procedure(Sender: TObject; OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem; NewSection: TElHeaderSection) of object;

  TOnValidateEvent = procedure(Sender: TObject; Item: TElTreeItem;
    Section: TElHeaderSection;
    var Text: string; var Accept: boolean) of object;

  TTryEditEvent = procedure(Sender: TObject; Item: TElTreeItem;
    Section: TElHeaderSection; var CellType: TFieldTypes; var CanEdit: boolean) of object;

  TEditRequestEvent = procedure(Sender: TObject; Item: TElTreeItem;
    Section: TElHeaderSection) of object;

  TComboEditShowEvent = procedure(Sender: TObject; Item: TElTreeItem;
    Section: TElHeaderSection;
    Combobox: TCombobox) of object;

  TValidateComboEvent = procedure(Sender: TObject; Item: TElTreeItem;
    Section: TElHeaderSection;
    Combo: TComboBox;
    var Accept: boolean) of object;

  TElScrollEvent = procedure(Sender: TObject;
    ScrollBarKind: TScrollBarKind;
    ScrollCode: integer) of object;

  TElColumnMoveEvent = procedure(Sender: TCustomElTree;
    Section: TElHeaderSection;
    OldPos, NewPos: integer) of object;

  TItemSaveEvent = procedure(Sender: TObject; Stream: TStream;
    Item: TElTreeItem) of object;

  TCellStyleSaveEvent = procedure(Sender: TObject; Stream: TStream;
    Style: TElCellStyle) of object;

  TElTreeChangingEvent = procedure (Sender : TObject; Item : TElTreeItem;
    var AllowChange: Boolean) of object;

  TElTreeItemPostDrawEvent = procedure(Sender : TObject; Canvas : TCanvas; Item : TElTreeItem;
    ItemRect : TRect; var DrawFocusRect : boolean) of object;

  TElTreeItemDragTargetEvent = procedure (Sender : TObject; Item : TElTreeItem;
    ItemRect : TRect; X, Y : integer) of object;

  TElTreeView = class(TCustomControl)
  protected
    FHeader   : TElHeader;
    FOwner    : TCustomElTree;
    FItems    : TElTreeItems;

    // Hint fields
    FHintTimer: TTimer;
    FHintWnd  : TElHintWindow;
    FHintCoord: TPoint;
    FHintItem,
    FHintItemEx : TElTreeItem;

    // Update fields
    FPainting, // already in Paint
    FClearVis, // do update visibles list
    FClearAll, // clear the whole ClientRect
    FVisUpdated, // visibles list updated
    FRangeUpdate // all items should be updated
               : boolean;

    // Positioning fields
    FHRange    : integer;

    // Mouse action fields
    FPressCoord: TPoint;
    FPressed   : boolean;
    FClickCoord: TPoint;
    FClicked   : boolean;
{$ifdef ELTREE_USE_STYLES}
    FClickControl: TElCellControl;
{$endif}
    FIgnoreClick,
    FIgnoreClick2: boolean;
    FClickPassed : boolean;
    FPassedItem  : TElTreeItem;
    FPassedShift : TShiftState;

    // Current items
    FClickItem,
    FTrackItem,
{$IFDEF ELTREE_USE_INPLACE_EDITORS}
    FEditingItem,
{$endif}
    FFocused,
    FSelected,
    FDropTrg  : TElTreeItem;

    // Current section associated to current item
    FTrackSection : TElHeaderSection;

    // Painting helper fields
    FVisible  : TElList;
    FFullVisible: TElList;
    FOverColors,
    FRowOvColors: boolean;

    // Drag'n'drop fields
    FDragScrollTimer,
    FDragExpandTimer : TTimer;
    FDropAcc   : boolean;
    FInDragging: boolean;
    FDDY       : integer;
{$IFDEF VCL_4_USED}
    FDragImages: TDragImageList;
{$ELSE}
    FDragImages: TImageList;
{$ENDIF}

    // Edit fields
{$IFDEF ELTREE_USE_INPLACE_EDITORS}
    FInpEdit   : TWinControl;
    FEditing   : boolean;
    FEditType  : TFieldTypes;
    FEditSect  : integer;
    FEditTimer : TTimer;
    FItemToEdit: TElTreeItem;
{$ENDIF}
    FOldHide   : boolean;
    FFakePopup : TPopupMenu;
{$IFDEF HAS_HTML_RENDER}
    FRender    : TElHTMLRender;
{$ENDIF}
    SearchText: string;
    SearchTextTimeoutThread : TThread;

    FScrollFirstClick: boolean;

    procedure StartClearSearchTimeoutThread ;
    procedure StopClearSearchTimeoutThread ;
    procedure SearchTextTimeout (Sender : TObject) ;

    function ProcessSearch(Key : Char): Boolean;
    procedure WMSize(var Msg : TWMSize); message WM_SIZE;

    // Painting routines
    procedure RedrawTree(ACanvas : TCanvas);
    procedure DrawImages(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
    procedure DrawButtons(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
    procedure DrawCheckBoxes(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
    procedure DrawItemLines(ACanvas : TCanvas; Item : TElTreeItem; var R : TRect; var ItemRect : TRect);
    procedure DoRedrawItem(ACanvas : TCanvas; Item: TElTreeItem; ItemRect, SurfRect: TRect);
    procedure DoRedrawItemTree(ACanvas : TCanvas; Item: TElTreeItem; ItemRect, SurfRect: TRect);
    procedure Paint; override;
    procedure WMPaint(var Msg : TWMPaint); message WM_PAINT;
    procedure UpdateView;

    // Hint routines
    procedure OnHintTimer(Sender: TObject);
    procedure DoHideLineHint;
    procedure DoShowLineHint(Item: TElTreeItem);

    // Dynamic height helper routines
    function CalcPageUpPos(CurIdx : integer) : integer;
    function CalcPageDownPos(CurIdx : integer) : integer;

    // Windows Message handling
    procedure WndProc(var Message: TMessage); override;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LButtonDblClk;
    procedure WMRButtonDblClk(var Msg: TWMRButtonDblClk); message WM_RBUTTONDBLCLK;
    procedure WMRButtonDown(var Message: TWMRButtonDown); message WM_RBUTTONDOWN;
    procedure WMRButtonUp(var Msg: TWMRButtonUp); message WM_RBUTTONUP;
    procedure WMSetFocus(var Msg : TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg : TWMKillFocus); message WM_KILLFOCUS;

    // VCL notification handlers
    {$IFDEF VCL_4_USED}
    procedure CMMouseWheel(var Msg : TCMMouseWheel); message CM_MOUSEWHEEL;
    {$ENDIF}

    procedure CMSysColorChange(var Msg: TMessage); message CM_SYSCOLORCHANGE;
    procedure CMHintShow(var Msg : TMessage); message CM_HINTSHOW;

    // Scrolling routines
    procedure SetHPosition(value: integer);
    procedure SetVPosition(value: integer);
    procedure DoSetTopIndex(Value: integer);

    procedure OnHScroll(Sender: TObject; ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange : boolean);
    procedure OnVScroll(Sender: TObject; ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange : boolean);

    // Painting helper routines
    procedure FillVisFwd(StartIndex: integer);
    procedure DefineHRange;
    function GetVisCount: integer; virtual;
    function GetVisiblesHeight : integer;

    // editing routines
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    function  DoEndEdit(ByCancel: boolean) : boolean; virtual;
    procedure OnEditExit(Sender: TObject);
    procedure DoEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function  SetupEditControl(Item : TElTreeItem; Section : TElHeaderSection; FT : TFieldTypes) : boolean; virtual;
    function  SetupNumericEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupFloatEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupEnumEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupTextEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupDateTimeEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupDateEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupTimeEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupCustomEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupBoolEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupBlobEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function  SetupPictureEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean; virtual;
    function SetupCurrencyEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect): Boolean; virtual;

    procedure ProcessEditResults(ByCancel : boolean); virtual;
    procedure ProcessFloatEditResults(ByCancel : boolean); virtual;
    procedure ProcessNumericEditResults(ByCancel : boolean); virtual;
    procedure ProcessDateTimeEditResults(ByCancel : boolean); virtual;
    procedure ProcessDateEditResults(ByCancel : boolean); virtual;
    procedure ProcessTimeEditResults(ByCancel : boolean); virtual;
    procedure ProcessEnumEditResults(ByCancel : boolean); virtual;
    procedure ProcessBoolEditResults(ByCancel : boolean); virtual;
    procedure ProcessTextEditResults(ByCancel : boolean); virtual;
    procedure ProcessBlobEditResults(ByCancel : boolean); virtual;
    procedure ProcessPictureEditResults(ByCancel : boolean); virtual;
    procedure ProcessCustomEditResults(ByCancel : boolean); virtual;
    procedure ProcessCurrencyEditResults(ByCancel : boolean); virtual;

    procedure DoEditItem(Item: TElTreeItem; SectionNum: integer); virtual;
    procedure OnEditTimer(Sender : TObject);

{$endif}

    // drag'n'drop routines
    procedure FillDragImage;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure DoDragOver(Source: TDragObject; X, Y: Integer; CanDrop: Boolean); virtual;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure CMDrag(var Message: TCMDrag); message CM_DRAG;
    function DragScroll(Source: TDragObject; X, Y: integer): boolean; virtual;
    procedure OnScrollTimer(Sender : TObject);
    procedure OnDragExpandTimer(Sender : TObject);
{$IFDEF VCL_4_USED}
    function GetDragImages: TDragImageList; override;
{$ELSE}
    function GetDragImages: TCustomImageList; override;
{$ENDIF}

    // coords routines
    function GetItemRect(ItemIndex: integer): TRect; virtual;
    function GetItemAtY(Y: integer): TElTreeItem; virtual;
    function GetItemAt(X, Y: Integer; var ItemPart: TSTItemPart; var HitColumn: integer): TElTreeItem; virtual;

    // user input routines
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CMMouseLeave(var Message: TMessage); message CM_MouseLeave;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    procedure ProcessPassedClick;

    procedure DoEnter; override;
    procedure DoExit; override;

    // selection routines
    procedure DoSetSelected(value: TElTreeItem);
    function GetVisCount2: Integer; virtual;
    procedure FitMostChildren(Item : TElTreeItem);

    property OnClick;
    property OnEnter;
    property OnExit;
    property OnDragDrop;
    property OnDragOver;
    property OnStartDrag;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
  public
    constructor Create(Owner : TComponent); override;
    destructor Destroy; override;
    property Owner : TCustomElTree read FOwner;
  end;

  TCustomElTree = class(TCustomControl)
  protected
    FLineHintTimeout     : Integer;
    FFireFocusEvents     : integer;
    FTransButtons        : boolean;
    FTransCheckBoxes     : boolean;
    FTrackColor          : TColor;
    FExpandOnDragOver    : Boolean;
    FForcedScrollBars    : TScrollStyle;
    FMoveFocusOnCollapse : Boolean;
    FHeaderHeight        : integer;
    FOnVertScrollHintNeeded : TElScrollHintNeededEvent;
    FOnHorzScrollDrawPart   : TElScrollDrawPartEvent;
    FOnHorzScrollHintNeeded : TElScrollHintNeededEvent;
    FOnVertScrollDrawPart   : TElScrollDrawPartEvent;
    FOnChanging             : TElTreeChangingEvent;

{$IFDEF VCL_4_USED}
    FBevelKindDummy : TBevelKind;
{$ENDIF}
    FHintType : TElHintType;
    FOnClick : TNotifyEvent;
    FOnDblClick : TNotifyEvent;
    //FOnEndDrag : TDragDropEvent;
    FOnDrop : TDragDropEvent;
    FOnOver : TDragOverEvent;
    FOnDrag : TEndDragEvent;
    FOnEnter : TNotifyEvent;
    FOnExit : TNotifyEvent;
    FOnKeyDown : TKeyEvent;
    FOnKeyPress : TKeyPressEvent;
    FOnKeyUp : TKeyEvent;
    FOnMouseDown : TMouseEvent;
    FOnMouseMove : TMouseMoveEvent;
    FOnMouseUp : TMouseEvent;
    FOnStartDrag : TStartDragEvent;
    FOnItemPreDraw: TOnItemExpandEvent;
    FOnDragTargetChange: TElTreeItemDragTargetEvent;

    FActiveBorderType : TElFlatBorderType;
    FInactiveBorderType : TElFlatBorderType;
    FRowHotTrack : Boolean;
    FFocusedSelectColor: TColor;
    FHideSelectColor: TColor;
    FFocusedSelectTextColor: TColor;
    FHideSelectTextColor: TColor;
    FFlatFocusedScrollbars : Boolean;
    FAutoResizeColumns : Boolean;
    FHideFocusRect: Boolean;
    FShowEmptyImages : Boolean;
    FShowEmptyImages2: Boolean;
    FShowRootButtons : Boolean;
    FUnderlineTracked: Boolean;
    FCustomCheckboxes: Boolean;
    FCheckBoxGlyph: TBitmap;
    FRadioButtonGlyph: TBitmap;
    FFilteredVisibility: Boolean;
    FOnApplyVisFilter: TApplyVisFilterEvent;
    FRightAlignedText: Boolean;
    FFlat: Boolean;
    FRightAlignedTree: Boolean;
    FPathSeparator: Char;
    FLinesStyle: TPenStyle;
    FDivLinesColor,
    FLinesColor: TColor;
    FDeselectChildrenOnCollapse: Boolean;
    FDrawFocusRect: Boolean;
    FBarStyle: Boolean;
    FAlwaysKeepFocus : boolean;
    FAlwaysKeepSelection: Boolean;
    FFullRowSelect: Boolean;
    FDragType  : TElDragType;
    FMouseOver : boolean;

    FDragObject : TDragObject;
    FAutoLookup: Boolean;
    FSelectColumn: Integer;
    FAutoExpand: Boolean;
    FPlusPicture: TBitmap;
    FMinusPicture: TBitmap;
    FCustomPlusMinus: Boolean;
    FShowHeader,
    FShowCheckboxes: Boolean;
{Soulsnake Add}
    FInvertClickCheckBoxes: Boolean;
{End Soulsnake Add}

{$IFDEF ELPACK_COMPLETE}
    FImgForm : TElImageForm;
    FImgFormChLink : TImgFormChangeLink;
    FStorage: TElIniFile;
    FStoragePath: string;
{$ENDIF}
    FDragImageMode: TDragImgMode;
    FHideHorzScrollBar: Boolean;
    FHideVertScrollBar: Boolean;
    FExpandOnDblClick: Boolean;
    FHideHintOnMove: Boolean;
    FSortSection: Integer;
    FSortMode: TSortModes;
    FSortType: TSortTypes;
    FDragAllowed: Boolean;
    PlusBmp,
      MinusBmp: TBitmap;
    FBkColor: TColor;
    FTextColor: TColor;
    FShowButtons: boolean;
    FShowLines: boolean;
    FShowImages: boolean;
    FShowRoot: boolean;
    FLineHintColor: TColor;
    FShowHintMode: THintModes;
    BMP: TBitmap;
    FBorderStyle: TBorderStyle;

    FCanEdit: boolean;

    FIgnoreSBChange : boolean;

    FSortRequired,
    FProcUpdate, // already in SetIsUpdating
    FUpdated : boolean;
    FInSorting : integer;
    FBSVLines,
    FHLines,
      FVLines: boolean;

    FAllList,
      FSelectedList : TElList;

    FScrollTracking,
      FTracking: boolean;
    FHeaderHotTrack: boolean;
    FODFollowCol: boolean;
    FODMask: string;

    FImages: TImageList;
    FImages2: TImageList;

    FImageChangeLink: TChangeLink;

    FTopIndex,
      FBottomIndex: integer; // visible items
    FChStateImage: boolean;
    FRealHint, 
    FHint       : string;
    FMainTreeCol: integer;
    FMultiSelect: boolean;
    FRowSelect  : boolean;
    FHideSelect : boolean;
    FLineHeight : integer;
    FAutoLineHeight: boolean;
    ItemExt        : integer;  
    FUseCustomBars : boolean;

    FHPos: integer;
    FVScrollVisible,
    FHScrollVisible: boolean;
    FSelMode: TSTSelModes;
    FSortDir: TSortDirs;

    FSelChange: boolean;
    FUpdating : // UpdateCount > 0
                 boolean;
    FUpdateCount: integer;

    FHintHide: boolean;
    FUseSystemHintColors : boolean;
    IgnoreResize: boolean;
    FCurBkColor: TColor;
    FCurTextColor: TColor;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    FDelOnEdit: boolean;
{$endif}
    FAutoSizingColumns: boolean;
    FItems: TElTreeItems;

    FOnColumnResize: TColumnNotifyEvent;
    FOnColumnClick: TColumnNotifyEvent;
    FOnColumnDraw: TElSectionRedrawEvent;
{$IFNDEF VCL_4_USED}
    FOnResize: TNotifyEvent;
{$ENDIF}
    FOnValidate: TOnValidateEvent;
    FOnItemChange: TOnItemChangeEvent;
    FOnItemDraw: TOnItemDrawEvent;
    FOnItemChecked : TOnItemCheckedEvent;
{Soulsnake Add}
    FOnItemColorPick : TOnItemColorPickEvent;
{End Soulsnake Add}
    FOnItemExpand: TOnItemExpandEvent;
    FOnItemCollapse: TOnItemExpandEvent;
    FOnItemExpanding: TOnItemExpanding;
    FOnItemCollapsing: TOnItemExpanding;
    FOnItemDelete: TOnItemExpandEvent;
    FOnItemFocused: TNotifyEvent;
    FOnItemPostDraw : TElTreeItemPostDrawEvent;
    FOnShowHint: TOnShowHintEvent;
    FOnCompareItems: TOnCompareItems;
    FOnItemPicDraw: TOnPicDrawEvent;
    FOnItemPicDraw2: TOnPicDrawEvent;
    FOnHotTrack: THotTrackEvent;
    FOnComboEditShow: TComboEditShowEvent;
    FOnEditRequest: TEditRequestEvent;
    FOnValidateCombo: TValidateComboEvent;
    FOnScroll: TElScrollEvent;
    FOnItemSave: TItemSaveEvent;
    FOnItemLoad: TItemSaveEvent;
    FOnTryEdit: TTryEditEvent;
    FOnHeaderColumnMove: TElColumnMoveEvent;
    FOnSave: TCellStyleSaveEvent;
    FOnLoad: TCellStyleSaveEvent;
    FOnItemSelectedChange: TItemSelChangeEvent;
    FOnHeaderLookup: TElHeaderLookupEvent;
    FOnHeaderLookupDone: TElHeaderLookupDoneEvent;
    FOnHeaderResize: TNotifyEvent;
    FOnHeaderSectionExpand: THeaderSectionEvent;
    FOnHeaderSectionCollapse: THeaderSectionEvent;
    FOnHeaderSectionMeasure : TMeasureSectionEvent;
    FOnSectionAutoSize : TColumnNotifyEvent;
    FOnSectionFilterCall : TColumnNotifyEvent;
    FOnTuneUpInplaceEdit : TTuneUpInplaceEditEvent;
    FOnMeasureItemPart   : TMeasureItemPartEvent;
    FOnSortBegin,
    FOnSortEnd           : TNotifyEvent;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    FOnEditKeyDown       : TKeyEvent;
{$endif}


    TotalHiddenCount,
    TotalVisCount: integer;
    TotalVarHeightCount : integer;

    FView  : TElTreeView;
    FHeader: TElHeader;
    FHScrollBar : TElScrollBar;
    FVScrollBar : TElScrollBar;
    FHorzScrollBarStyle,
    FVertScrollBarStyle : TElScrollBarStyles;
    FFakeBool : boolean;
    SavedHH   : integer;
    FDelayTimer: TTimer;

    FDelayedItem: TElTreeItem;
    FDragExpandDelay,
    FChangeDelay: Integer;
    FDragTrgDrawMode: TDragTargetDraw;

    FOnHeaderMouseDown: TMouseEvent;
    FOnAfterSelectionChange: TNotifyEvent;
    FDragRectAcceptColor: TColor;
    FDragRectDenyColor: TColor;
    FIncrementalSearch: Boolean;
    FRightClickSelect: Boolean;
    FScrollbarOpposite: Boolean;
    FVerticalLinesLong: Boolean;

{$IFDEF HAS_HTML_RENDER}
    FOnImageNeeded : TElHTMLImageNeededEvent;
    procedure TriggerImageNeededEvent(Sender : TObject; Src : string; var Image : TBitmap); virtual;
{$ENDIF}
    procedure OnHeaderSectionResize(Header: TCustomElHeader; Section: TElHeaderSection);
    procedure OnHeaderSectionClick(Header: TCustomElHeader; Section: TElHeaderSection);
    procedure OnHeaderSectionDelete(Header: TCustomElHeader; Section: TElHeaderSection);
    procedure DoHeaderMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure OnHeaderSectionLookup(Sender: TObject; Section: TElHeaderSection; var Text: string);
    procedure OnHeaderSectionLookupDone(Sender: TObject; Section: TElHeaderSection; Text: string; Accepted: boolean);
    procedure OnHeaderExpand(Sender: TCustomElHeader; Section: TElHeaderSection);
    procedure OnHeaderCollapse(Sender: TCustomElHeader; Section: TElHeaderSection);
    procedure OnHeaderSectionVisChange(Sender: TCustomElHeader; Section: TElHeaderSection);
    procedure HeaderSectionAutoSizeHandler(Sender : TCustomElHeader; Section : TElHeaderSection);  { TElHeaderSectionEvent }
    procedure SectionAutoSizeTransfer(Sender : TCustomElHeader; Section : TElHeaderSection);  { TElHeaderSectionEvent }
    procedure SectionFilterCallTransfer(Sender : TCustomElHeader; Section : TElHeaderSection);  { TElHeaderSectionEvent }

    procedure DoHeaderResize(Sender: TObject);
    procedure OnFontChange(Sender: TObject);
    procedure OnSignChange(Sender: TObject);
    procedure ImageListChange(Sender: TObject);

    function GetDropTarget: TElTreeItem;

    procedure SetTextColor(value: TColor);
    procedure SetBkColor(value: TColor);
    procedure SetHeaderHotTrack(value: boolean);
    procedure SetHeaderHeight(value: integer);
    procedure SetShowEmptyImages(newValue : boolean);
    procedure SetShowEmptyImages2(newValue : boolean);
    procedure SetImages(Value: TImageList);
    procedure SetImages2(newValue: TImageList);
    procedure SetLineHintTimeout(Value: Integer);

    procedure SetLineStyle(Value: Boolean);
    procedure SetRootStyle(Value: Boolean);
    procedure SetImagesStyle(Value: Boolean);
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetButtonStyle(Value: Boolean);
    procedure SetUpdating(value: boolean);
    function  GetUpdating : boolean;
    procedure SetHLines(value: boolean);
    procedure SetVLines(value: boolean);
    procedure SetBSVLines(value: boolean);
    procedure SetRowSelect(value: boolean);
    procedure SetMultiSelect(value: boolean);
    procedure SetFocused(value: TElTreeItem);
    procedure SetHideSelect(value: boolean);
    procedure SetAutoExpand(value: boolean);
    procedure SetMoveFocusOnCollapse(value: boolean);
    function GetHeaderSections: TElHeaderSections;
    procedure SetHeaderSections(value: TElHeaderSections);
    procedure SetChStateImage(value: boolean);
    procedure SetUseStdBars(value : boolean);

    procedure SetItemIndent(value: integer);
    procedure SetLineHeight(value: integer);
    procedure SetAutoLineHeight(value: boolean);
    function GetHeaderHeight: integer;
    procedure SetMainTreeCol(value: integer);
    procedure SetItems(value: TElTreeItems);
    function GetTotalVisCount: integer;
    function GetDraggableSections: Boolean;
    procedure SetDraggableSections(newValue: Boolean);
    procedure SetSortMode(newValue: TSortModes);
    procedure SetSortSection(newValue: Integer);

    function GetMoveColumnOnDrag: Boolean;
    procedure SetMoveColumnOnDrag(newValue: Boolean);
    procedure SetHideHorzScrollBar(newValue: Boolean);
    procedure SetHideVertScrollBar(newValue: Boolean);
    function GetHeaderImages: TImageList;
    procedure SetHeaderImages(newValue: TImageList);

    function GetFireFocusEvents: boolean;
    procedure SetFireFocusEvents(Value: boolean);

    procedure SetScrollbarOpposite(Value: Boolean);
    procedure SetVerticalLinesLong(Value: Boolean);

    function GetSelCount: integer;
    function GetSelected: TElTreeItem;
    function GetFocused : TElTreeItem;
    procedure SetSelected(newValue: TElTreeItem);
{$ifdef SUPPORT_STORAGE}
    procedure SetStorage(newValue: TElIniFile);
{$endif}
{$IFDEF ELPACK_COMPLETE}
    procedure SetImageForm(newValue : TElImageForm);
    procedure ImageFormChange(Sender: TObject);
    procedure SetHeaderImageForm(newValue : TElImageForm);
    function GetHeaderImageForm : TElImageForm;
{$ENDIF}
    procedure SetShowCheckboxes(newValue: Boolean);
    procedure SetPlusPicture(newValue: TBitmap);
    procedure SetMinusPicture(newValue: TBitmap);
    procedure SetCustomPlusMinus(newValue: Boolean);
    procedure SetSelectColumn(newValue: Integer);
    procedure SetDragType(newValue: TElDragType);

    procedure HeaderResizeTransfer(Sender: TObject);
    procedure HeaderResizeHandler(Sender: TObject);

    function GetStickyHeaderSections: Boolean;
    procedure SetStickyHeaderSections(newValue: Boolean);
    procedure SetBarStyle(newValue: Boolean);
    procedure SetDrawFocusRect(newValue: Boolean);
    procedure SetLinesColor(newValue: TColor);
    procedure SetDivLinesColor(newValue: TColor);
    procedure SetLinesStyle(newValue: TPenStyle);
    procedure SetRightAlignedTree(newValue: Boolean);
    procedure SetFlat(newValue: Boolean);
    procedure SetRightAlignedText(newValue: Boolean);
    procedure SetFilteredVisibility(newValue: Boolean);
    procedure SetUnderlineTracked(newValue: Boolean);
    procedure SetCustomCheckboxes(newValue: Boolean);
    procedure SetCheckBoxGlyph(newValue: TBitmap);
    procedure SetRadioButtonGlyph(newValue: TBitmap);
    procedure SetShowRootButtons(newValue: Boolean);
    procedure SetHideFocusRect(newValue: Boolean);
    function GetLockHeaderHeight: Boolean;
    procedure SetLockHeaderHeight(newValue: Boolean);
    procedure SetTransButtons(newValue : boolean);

    procedure UpdateFrame;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    function GetInEditing : boolean;
{$endif}
    procedure SetHeaderActiveFilterColor(newValue : TColor);
    function GetHeaderActiveFilterColor : TColor;
    procedure SetHeaderFilterColor(newValue : TColor);
    function GetHeaderFilterColor : TColor;
    procedure SetHeaderFlat(newValue : Boolean);
    function GetHeaderFlat : Boolean;
    procedure DrawFlatBorder(HorzTracking, VertTracking : boolean);
    procedure DrawFlatBorderEx(DC : HDC; HorzTracking, VertTracking : boolean);

    procedure SetFlatFocusedScrollbars(newValue : Boolean);
    procedure WMNCHITTEST(var Msg : TMessage); message WM_NCHITTEST;
    procedure WMVScroll(var Msg : TWMVScroll); message WM_VSCROLL;
    procedure WMHScroll(var Msg : TWMHScroll); message WM_HSCROLL;
    procedure WMEnable(var Msg : TMessage); message WM_ENABLE;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var Msg : TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg : TWMKillFocus); message WM_KILLFOCUS;
    procedure WMNCPaint(var Msg: TMessage); message WM_NCPAINT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMNCCalcSize(var Message : TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure CMMouseEnter( var Msg: TMessage ); message CM_MouseEnter;
    procedure CMMouseLeave(var Message: TMessage); message CM_MouseLeave;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;

    procedure SetHideSelectColor(newValue: TColor);
    procedure SetFocusedSelectColor(newValue: TColor);

    procedure SetHideSelectTextColor(newValue: TColor);
    procedure SetFocusedSelectTextColor(newValue: TColor);

    procedure SetRowHotTrack(newValue : Boolean);
    procedure SetActiveBorderType(newValue : TElFlatBorderType);
    procedure SetInactiveBorderType(newValue : TElFlatBorderType);
    procedure SetHPosition(value: integer);
    procedure SetVPosition(value: integer);

    procedure ClickTransfer(Sender : TObject);  virtual;
    procedure DblClickTransfer(Sender : TObject); virtual;
    procedure DropTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer);  virtual;
    //procedure EndDragTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer);
    procedure OverTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer; State : TDragState; var Accept : Boolean); virtual;
    procedure DragTransfer(Sender : TObject; Target : TObject; X : Integer; Y : Integer); virtual;
    procedure EnterTransfer(Sender : TObject); virtual;
    procedure ExitTransfer(Sender : TObject); virtual;
    procedure KeyDownTransfer(Sender : TObject; var Key : Word; Shift : TShiftState); virtual;
    procedure KeyPressTransfer(Sender : TObject; var Key : Char); virtual;
    procedure KeyUpTransfer(Sender : TObject; var Key : Word; Shift : TShiftState); virtual;
    procedure MouseDownTransfer(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X : Integer; Y : Integer); virtual;
    procedure MouseMoveTransfer(Sender : TObject; Shift : TShiftState; X : Integer; Y : Integer); virtual;
    procedure MouseUpTransfer(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X : Integer; Y : Integer); virtual;
    procedure StartDragTransfer(Sender : TObject; var DragObject : TDragObject); virtual;
    procedure MeasureSectionTransfer(Sender : TObject; Section : TElHeaderSection; var Size: TPoint); virtual;
    procedure SetCursor(newValue : TCursor);
    function  GetCursor : TCursor;
    function  SetScrollInfo(hWnd: HWND; BarFlag: Integer; const ScrollInfo: TScrollInfo; Redraw: BOOL): Integer;
    function  GetScrollInfo(hWnd: HWND; BarFlag: Integer; var ScrollInfo: TScrollInfo): BOOL;
    procedure SetHorzScrollBarStyle(newValue : TElScrollBarStyles);
    procedure SetVertScrollBarStyle(newValue : TElScrollBarStyles);
    procedure HorzScrollDrawPartTransfer(Sender : TObject; Canvas : TCanvas; R : TRect; Part : TElScrollBarPart; Enabled : Boolean; Focused : Boolean; Pressed : Boolean; var DefaultDraw : Boolean);  { TElScrollDrawPartEvent }
    procedure HorzScrollHintNeededTransfer(Sender : TObject; TrackPosition : Integer; var Hint : String);  { TElScrollHintNeededEvent }
    procedure VertScrollDrawPartTransfer(Sender : TObject; Canvas : TCanvas; R : TRect; Part : TElScrollBarPart; Enabled : Boolean; Focused : Boolean; Pressed : Boolean; var DefaultDraw : Boolean);  { TElScrollDrawPartEvent }
    procedure VertScrollHintNeededHandler(Sender : TObject; TrackPosition : Integer; var Hint : String);  { TElScrollHintNeededEvent }
    procedure VertScrollHintNeededTransfer(Sender : TObject; TrackPosition : Integer; var Hint : String);  { TElScrollHintNeededEvent }
    function GetHeaderInvertSortArrows : Boolean;
    procedure SetHeaderInvertSortArrows(newValue : Boolean);
    procedure FontChanged(Sender: TObject);
    procedure SBChanged(Sender: TObject);
    procedure ScrollBarMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure SetForcedScrollBars(newValue : TScrollStyle);
    function GetDragCursor : TCursor;
    procedure SetDragCursor(Value : TCursor);
    procedure SetTrackColor(value : TColor);
{$IFDEF VCL_4_USED}
    procedure ActionChange(Sender : TObject; CheckDefaults : Boolean); override;
{$ENDIF}
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure AlignPieces;
    function GetRoot: TElTreeItem; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function  CompareItems(Item1, Item2: TElTreeItem; SM : TElSSortMode; ST : TSortTypes; FSortSection : integer): integer; virtual;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    procedure SetCanEdit(value: boolean); virtual;
{$endif}
    procedure SetShowHeader(value: boolean); virtual;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMCtl3DChanged(var Message: TMessage); message CM_CTL3DCHANGED;
{$IFDEF VCL_4_USED}
    procedure Resize; override;
{$ELSE}
    procedure Resize; dynamic;
{$ENDIF}
    function  DoGetPicture(Item: TElTreeItem): integer; virtual;
    function  DoGetPicture2(Item: TElTreeItem): integer; virtual;
    function  DefineLineHeight: integer; virtual;
    procedure UpdateScrollBars;
    procedure CreateParams(var Params: TCreateParams); override;

    function  CreateItems: TElTreeItems; virtual;
    function  CreateHeader: TElHeader; virtual;
    function DoSetFocused(value: TElTreeItem; Forced : boolean; AutoSelect : boolean = True): Boolean;
    function DoSetFocusedEx(value: TElTreeItem; Forced, Delayed : boolean; AutoSelect : boolean = True): Boolean;
    procedure SetHeaderColor(newValue : TColor); virtual;
    function  GetHeaderColor : TColor; virtual;
    function  GetHint : string;
    procedure SetHint(newValue : string);

    procedure DoChanging(Item : TElTreeItem; var AllowChange: Boolean); virtual;
    procedure DoOnColumnResize(SectionIndex: integer); virtual;
    procedure DoColumnClick(SectionIndex: integer); virtual;
    procedure DoItemFocused; virtual;
    procedure DoItemDraw(Item: TElTreeItem; Surface: TCanvas; R: TRect; SectionIndex: integer); virtual;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    procedure DoValidate(Item: TElTreeItem; Section: TElHeaderSection; var Text: string; var Accept: boolean); virtual;
    procedure NotifyOnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{$endif}

    procedure DoItemChange(Item: TElTreeItem; ItemChangeMode: TItemChangeMode); virtual;
    procedure DoItemExpanding(Item: TElTreeItem; var CanProcess: boolean); virtual;
    procedure DoItemCollapsing(Item: TElTreeItem; var CanProcess: boolean); virtual;
    procedure DoItemChecked(Item : TElTreeItem); virtual;
{Soulsnake Add}
    procedure DoItemColorPick(Item : TElTreeItem); virtual;
{End Soulsnake Add}
    procedure DoItemExpand(Item: TElTreeItem); virtual;
    procedure DoItemCollapse(Item: TElTreeItem); virtual;
    procedure DoItemDelete(Item: TElTreeItem); virtual;
    procedure DoCompareItems(Item1, Item2: TElTreeItem; var res: integer); virtual;
    procedure DoHeaderDraw(Header: TCustomElHeader; Section: TElHeaderSection;
      Rect: TRect; Pressed: Boolean); virtual;
    procedure OnHeaderSectionChange(Sender: TCustomElHeader; Section: TElHeaderSection; Change: TSectionChangeMode); virtual;
    procedure OnHeaderSectionMove(Sender: TCustomElHeader; Section: TElHeaderSection; OldPos, NewPos: integer); virtual;
    procedure TriggerHotTrackEvent(OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem; NewSection: TElHeaderSection); virtual;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    procedure TriggerEditRequestEvent(Item: TElTreeItem; Section: TElHeaderSection); virtual;
    procedure TriggerComboEditShowEvent(Item: TElTreeItem; Section: TElHeaderSection; Combobox: TCombobox); virtual;
    procedure TriggerTryEditEvent(Item: TElTreeItem; Section: TElHeaderSection;
      var CellType: TFieldTypes; var CanEdit: boolean); virtual;
    procedure TriggerTuneUpInplaceEditEvent(Item : TElTreeItem; SectionIndex : integer; Editor : TCustomEdit); virtual;
{$endif}
    procedure TriggerScrollEvent(ScrollBarKind: TScrollBarKind; ScrollCode: integer); virtual;
    procedure TriggerHeaderColumnMoveEvent(Section: TElHeaderSection; OldPos, NewPos: integer); virtual;
    procedure TriggerItemSaveEvent(Stream: TStream; Item: TElTreeItem); virtual;
    procedure TriggerItemLoadEvent(Stream: TStream; Item: TElTreeItem); virtual;
    procedure TriggerItemSelectedChangeEvent(Item: TElTreeItem); virtual;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    procedure DoValidateCombo(Item: TElTreeItem; Section: TElHeaderSection; Combo: TComboBox; var Accept: boolean); virtual;
{$endif}
    procedure DoShowHint(Item: TElTreeItem; var Text: string; HintWindow: THintWindow; MousePos: TPoint; var DoShowHint: boolean); virtual;

    procedure Paint; override;
    procedure OnHeaderSectionCreate(Header: TCustomElHeader; Section: TElHeaderSection); virtual;

    procedure TriggerHeaderLookupEvent(Section: TElHeaderSection; var Text: string); virtual;
    procedure TriggerHeaderLookupDoneEvent(Section: TElHeaderSection; Text: string; Accepted: boolean); virtual;
    procedure TriggerHeaderSectionExpandEvent(Section: TElHeaderSection); virtual;
    procedure TriggerHeaderSectionCollapseEvent(Section: TElHeaderSection); virtual;
    procedure TriggerMeasureItemPartEvent(Item: TElTreeItem; PartIndex: integer; var Size: TPoint); virtual;
    procedure TriggerApplyVisFilterEvent(Item: TElTreeItem; var Hidden: boolean); virtual;
    procedure TriggerItemPostDrawEvent(Canvas : TCanvas; Item : TElTreeItem; ItemRect : TRect; var DrawFocusRect : boolean); virtual;

{$IFDEF VCL_4_USED}
    function GetDragImages: TDragImageList; override;
{$ELSE}
    function GetDragImages: TCustomImageList; override;
{$ENDIF}

    procedure AutoSizeAllColumns;
    procedure AutoSizeColumn(SectionIndex : integer);
    function GetTopItem: TElTreeItem; virtual;
    procedure SetTopItem(Item: TElTreeItem); virtual;
    procedure Loaded; override;
    function SectionTypeToSortType(SectionType: TFieldTypes): TSortTypes;
    procedure TriggerSortBegin; virtual;
    procedure TriggerSortEnd; virtual;
    function CreateView : TElTreeView; virtual;
    procedure CreateWnd; override;
    procedure StartDelayedFocus(FocusItemToReport : TElTreeItem);
    procedure StopDelayedFocus;
    procedure OnDelayTimer(Sender : TObject);
    procedure DoAfterSelectionChange; virtual;
    procedure SetDragRectAcceptColor(const Value: TColor);
    procedure SetDragRectDenyColor(Value: TColor);
    procedure SetDragTrgDrawMode(Value: TDragTargetDraw);
    function GetVisibleRowCount: Integer;
    procedure DoSetDragTrgDrawMode(Value: TDragTargetDraw; RedrawItem : boolean);

    property TextColor: TColor read FTextColor write SetTextColor default clWindowText;
    property BkColor: TColor read FBkColor write SetBkColor default clWindow;
    property ShowButtons: Boolean read FShowButtons write SetButtonStyle default true;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property ShowLines: Boolean read FShowLines write SetLineStyle default true;
    property ShowImages: Boolean read FShowImages write SetImagesStyle default true;
    property ShowRoot: boolean read FShowRoot write SetRootStyle default false;
    property LineHintMode: THintModes read FShowHintMode write FShowHintMode default shmLong;
    property LineHintColor: TColor read FLineHintColor write FLineHintColor default clWindow;
    property HideSelection: Boolean read FHideSelect write SetHideSelect default false;
    property HideHintOnTimer: boolean read FHintHide write FHintHide default false;
    property Images: TImageList read FImages write SetImages;
    property Images2: TImageList read FImages2 write SetImages2;

    property ChangeStateImage: boolean read FChStateImage write SetChStateImage default false;
    property ShowColumns: Boolean read FShowHeader write SetShowHeader default false;
    property DragTrgDrawMode: TDragTargetDraw read FDragTrgDrawMode write
        SetDragTrgDrawMode default SelColorRect;
    property DraggableSections: Boolean read GetDraggableSections write SetDraggableSections default false; { Published }
    property SelectionMode: TSTSelModes read FSelMode write FSelMode default smUsual;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    property DoInplaceEdit: boolean read FCanEdit write SetCanEdit default true;
{$else}
    property DoInplaceEdit: boolean read FCanEdit write FCanEdit default true;
{$endif}
    property VerticalLines: boolean read FVLines write SetVLines default false;
    property BarStyleVerticalLines : boolean read FBSVLines write SetBSVLines default false;
    property HorizontalLines: boolean read FHLines write SetHLines default false;
    property ScrollTracking: boolean read FScrollTracking write FScrollTracking default false;
    property Tracking: boolean read FTracking write FTracking default true;
    property RowSelect: boolean read FRowSelect write SetRowSelect default true;
    property MultiSelect: boolean read FMultiSelect write SetMultiSelect default true;
    property LineHeight: integer read FLineHeight write SetLineHeight nodefault;
    property AutoLineHeight: boolean read FAutoLineHeight write SetAutoLineHeight default true;
    property HeaderHotTrack: boolean read FHeaderHotTrack write SetHeaderHotTrack default true;
    property HeaderSections: TElHeaderSections read GetHeaderSections write SetHeaderSections;
    property HeaderHeight: integer read GetHeaderHeight write SetHeaderHeight nodefault;
    property MainTreeColumn: integer read FMainTreeCol write SetMainTreeCol default 0;
    property OwnerDrawByColumn: boolean read FODFollowCol write FODFollowCol default true;
    property OwnerDrawMask: string read FODMask write FODMask;
    property DragAllowed: Boolean read FDragAllowed write FDragAllowed default false;
    property SortDir: TSortDirs read FSortDir write FSortDir default sdAscend;
    property SortMode: TSortModes read FSortMode write SetSortMode default smNone; { Published }
    property SortSection: Integer read FSortSection write SetSortSection default 0; { Published }
    property SortType: TSortTypes read FSortType write FSortType default stText;
    property HideHintOnMove: Boolean read FHideHintOnMove write FHideHintOnMove default true; { Protected }
    property ExpandOnDblClick: Boolean read FExpandOnDblClick write FExpandOnDblClick default true; { Protected }
    property MoveColumnOnDrag: Boolean read GetMoveColumnOnDrag write SetMoveColumnOnDrag default false; { Published }
    property HideHorzScrollBar: Boolean read FHideHorzScrollBar write SetHideHorzScrollBar default false; { Published }
    property HideVertScrollBar: Boolean read FHideVertScrollBar write SetHideVertScrollBar default false; { Published }
    property HorzScrollBarStyles : TElScrollBarStyles read FHorzScrollBarStyle write SetHorzScrollBarStyle stored true;
    property VertScrollBarStyles : TElScrollBarStyles read FVertScrollBarStyle write SetVertScrollBarStyle stored true;

    property HeaderImages: TImageList read GetHeaderImages write SetHeaderImages; { Protected }
    property DragImageMode: TDragImgMode read FDragImageMode write FDragImageMode default dimNever; { Protected }
{$IFDEF ELPACK_COMPLETE}
    property StoragePath     : string read FStoragePath write FStoragePath;
{$IFDEF SUPPORT_STORAGE}
    property Storage         : TElIniFile read FStorage write SetStorage;
{$ELSE}
    property Storage         : TElIniFile read FStorage write FStorage;
{$ENDIF}
{$ENDIF}

{$IFDEF ELPACK_COMPLETE}
    property ImageForm       : TElImageForm read FImgForm write SetImageForm;
    property HeaderImageForm : TElImageForm read GetHeaderImageForm write SetHeaderImageForm;
{$ENDIF}
    property ShowCheckboxes: Boolean read FShowCheckboxes write SetShowCheckboxes default false;
{Soulsnake Add}
    property InvertClickCheckboxes: Boolean read FInvertClickCheckBoxes write FInvertClickCheckBoxes default false;
{End Soulsnake Add}
    property PlusPicture: TBitmap read FPlusPicture write SetPlusPicture;
    property MinusPicture: TBitmap read FMinusPicture write SetMinusPicture;
    property CustomPlusMinus: Boolean read FCustomPlusMinus write SetCustomPlusMinus default false;
    property SelectColumn: Integer read FSelectColumn write SetSelectColumn default -1;
    property AutoExpand: Boolean read FAutoExpand write SetAutoExpand default false;
    property AutoLookup: Boolean read FAutoLookup write FAutoLookup default false;
    property DragType: TElDragType read FDragType write SetDragType default dtDelphi;
    property FullRowSelect: Boolean read FFullRowSelect write FFullRowSelect default true;
    property AlwaysKeepSelection: Boolean read FAlwaysKeepSelection write FAlwaysKeepSelection default true;
    property AlwaysKeepFocus: Boolean read FAlwaysKeepFocus write FAlwaysKeepFocus default false;
    property StickyHeaderSections: Boolean read GetStickyHeaderSections write SetStickyHeaderSections default false;
    property BarStyle: Boolean read FBarStyle write SetBarStyle default false;
    property DrawFocusRect: Boolean read FDrawFocusRect write SetDrawFocusRect default true;
    property DeselectChildrenOnCollapse: Boolean read FDeselectChildrenOnCollapse write FDeselectChildrenOnCollapse default false;
    property DivLinesColor: TColor read FDivLinesColor write SetDivLinesColor default clBtnFace;
    property LinesColor: TColor read FLinesColor write SetLinesColor default clBtnFace;
    property LinesStyle: TPenStyle read FLinesStyle write SetLinesStyle default psDot;
    property PathSeparator: Char read FPathSeparator write FPathSeparator default '\'; { Protected }
    property RightAlignedTree: Boolean read FRightAlignedTree write SetRightAlignedTree default false;
    property Flat: Boolean read FFlat write SetFlat default false; { Protected }
    property RightAlignedText: Boolean read FRightAlignedText write SetRightAlignedText default false;
    property FilteredVisibility: Boolean read FFilteredVisibility write SetFilteredVisibility default false;
    property UnderlineTracked: Boolean read FUnderlineTracked write SetUnderlineTracked default true; { Published }
    property CustomCheckboxes: Boolean read FCustomCheckboxes write SetCustomCheckboxes default false; { Published }
    property CheckBoxGlyph: TBitmap read FCheckBoxGlyph write SetCheckBoxGlyph; { Published }
    property RadioButtonGlyph: TBitmap read FRadioButtonGlyph write SetRadioButtonGlyph; { Published }
    property ScrollbarOpposite: Boolean read FScrollbarOpposite write SetScrollbarOpposite;
    property ShowRootButtons: Boolean read FShowRootButtons write SetShowRootButtons default false;
    property ShowEmptyImages : Boolean read FShowEmptyImages write SetShowEmptyImages default false;
    property ShowEmptyImages2: Boolean read FShowEmptyImages2 write SetShowEmptyImages2 default false;

    property HideFocusRect: Boolean read FHideFocusRect write SetHideFocusRect default false;
    property LockHeaderHeight: Boolean read GetLockHeaderHeight write SetLockHeaderHeight default false; { Protected }
    property AutoResizeColumns : Boolean read FAutoResizeColumns write FAutoResizeColumns default True;  { Protected }
    property HeaderActiveFilterColor : TColor read GetHeaderActiveFilterColor write SetHeaderActiveFilterColor default clBlack;
    property HeaderFilterColor : TColor read GetHeaderFilterColor write SetHeaderFilterColor default clBtnText;
    property HeaderFlat : Boolean read GetHeaderFlat write SetHeaderFlat default false;
    property FlatFocusedScrollbars : Boolean read FFlatFocusedScrollbars write SetFlatFocusedScrollbars default true;  { Protected }
    property HideSelectColor: TColor read FHideSelectColor write SetHideSelectColor default clBtnFace;
    property FocusedSelectColor: TColor read FFocusedSelectColor write SetFocusedSelectColor default clHighlight;
    property HideSelectTextColor: TColor read FHideSelectTextColor write SetHideSelectTextColor default clBtnShadow;
    property FocusedSelectTextColor: TColor read FFocusedSelectTextColor write SetFocusedSelectTextColor default clHighlightText;
    property UseCustomScrollBars : boolean read FUseCustomBars write SetUseStdBars default true;

    property RowHotTrack : Boolean read FRowHotTrack write SetRowHotTrack default false;  { Protected }
    property ActiveBorderType : TElFlatBorderType read FActiveBorderType write SetActiveBorderType default fbtSunken;  { Protected }
    property InactiveBorderType : TElFlatBorderType read FInactiveBorderType write SetInactiveBorderType default fbtSunkenOuter;  { Protected }
    property ItemIndent : integer read ItemExt write SetItemIndent default 17;
    property Cursor : TCursor read GetCursor write SetCursor default crArrow;
    property HeaderInvertSortArrows : Boolean read GetHeaderInvertSortArrows write SetHeaderInvertSortArrows default false;  { Protected }
    property MoveFocusOnCollapse : Boolean read FMoveFocusOnCollapse write SetMoveFocusOnCollapse default false;  { Protected }
    property ForcedScrollBars : TScrollStyle read FForcedScrollBars write SetForcedScrollBars default ssNone;  { Protected }
    property PlusMinusTransparent : boolean read FTransButtons write SetTransButtons default false;
    property Hint : string read GetHint write SetHint;
    property DragRectAcceptColor: TColor read FDragRectAcceptColor write
        SetDragRectAcceptColor default clGreen;
    property DragRectDenyColor: TColor read FDragRectDenyColor write
        SetDragRectDenyColor default clRed;
    property DragExpandDelay: Integer read FDragExpandDelay write FDragExpandDelay
        default 500;
    property IncrementalSearch: Boolean read FIncrementalSearch write
        FIncrementalSearch;
    property FireFocusEvents: boolean read GetFireFocusEvents write SetFireFocusEvents;

{$IFNDEF VCL_4_USED}
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
{$ENDIF}
    property OnValidateInplaceEdit: TOnValidateEvent read FOnValidate write FOnValidate;
    property OnItemChange: TOnItemChangeEvent read FOnItemChange write FOnItemChange;
    property OnItemDraw: TOnItemDrawEvent read FOnItemDraw write FOnItemDraw;
    property OnItemChecked: TOnItemCheckedEvent read FOnItemChecked write FOnItemChecked;
{Soulsnake Add}
    property OnItemColorPick: TOnItemColorPickEvent read FOnItemColorPick write FOnItemColorPick;
{End Soulsnake Add}
    property OnItemExpand: TOnItemExpandEvent read FOnItemExpand write FOnItemExpand;
    property OnItemCollapse: TOnItemExpandEvent read FOnItemCollapse write FOnItemCollapse;
    property OnItemExpanding: TOnItemExpanding read FOnItemExpanding write FOnItemExpanding;
    property OnItemCollapsing: TOnItemExpanding read FOnItemCollapsing write FOnItemCollapsing;
    property OnScroll: TElScrollEvent read FOnScroll write FOnScroll;
    property OnItemDeletion: TOnItemExpandEvent read FOnItemDelete write FOnItemDelete;
    property OnChanging: TElTreeChangingEvent read FOnChanging write FOnChanging;
    property OnItemFocused: TNotifyEvent read FOnItemFocused write FOnItemFocused;
    property OnShowLineHint: TOnShowHintEvent read FOnShowHint write FOnShowHint;
    property OnCompareItems: TOnCompareItems read FOnCompareItems write FOnCompareItems;
    property OnItemPicDraw: TOnPicDrawEvent read FOnItemPicDraw write FOnItemPicDraw;
    property OnItemPicDraw2: TOnPicDrawEvent read FOnItemPicDraw2 write FOnItemPicDraw2;
    property OnHotTrack: THotTrackEvent read FOnHotTrack write FOnHotTrack;
    property OnEditRequest: TEditRequestEvent read FOnEditRequest write FOnEditRequest;
    property OnComboEditShow: TComboEditShowEvent read FOnComboEditShow write FOnComboEditShow;
    property OnValidateCombo: TValidateComboEvent read FOnValidateCombo write FOnValidateCombo;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
    property OnEditKeyDown: TKeyEvent read FOnEditKeyDown write FOnEditKeyDown;
{$endif}

    property OnTryEdit: TTryEditEvent read FOnTryEdit write FOnTryEdit;
    property OnItemSave: TItemSaveEvent read FOnItemSave write FOnItemSave;
    property OnItemLoad: TItemSaveEvent read FOnItemLoad write FOnItemLoad;
    property OnItemSelectedChange: TItemSelChangeEvent read FOnItemSelectedChange write FOnItemSelectedChange;
    property OnCellStyleSave: TCellStyleSaveEvent read FOnSave write FOnSave;
    property OnCellStyleLoad: TCellStyleSaveEvent read FOnLoad write FOnLoad;
    property OnSortBegin : TNotifyEvent read FOnSortBegin write FOnSortBegin;
    property OnSortEnd : TNotifyEvent read FOnSortEnd write FOnSortEnd;
    
    property OnHeaderResize: TNotifyEvent read FOnHeaderResize write FOnHeaderResize;
    property OnHeaderLookup: TElHeaderLookupEvent read FOnHeaderLookup write FOnHeaderLookup;
    property OnHeaderLookupDone: TElHeaderLookupDoneEvent read FOnHeaderLookupDone write FOnHeaderLookupDone;
    property OnHeaderSectionExpand: THeaderSectionEvent read FOnHeaderSectionExpand write FOnHeaderSectionExpand;
    property OnHeaderSectionCollapse : THeaderSectionEvent read FOnHeaderSectionCollapse write FOnHeaderSectionCollapse;
    property OnHeaderSectionAutoSize : TColumnNotifyEvent read FOnSectionAutoSize write FOnSectionAutoSize;
    property OnHeaderColumnResize: TColumnNotifyEvent read FOnColumnResize write FOnColumnResize;
    property OnHeaderColumnClick: TColumnNotifyEvent read FOnColumnClick write FOnColumnClick;
    property OnHeaderColumnMove: TElColumnMoveEvent read FOnHeaderColumnMove write FOnHeaderColumnMove;
    property OnHeaderColumnDraw: TElSectionRedrawEvent read FOnColumnDraw write FOnColumnDraw;
    property OnHeaderSectionFilterCall : TColumnNotifyEvent read FOnSectionFilterCall write FOnSectionFilterCall;
    property OnHeaderSectionMeasure : TMeasureSectionEvent read FOnHeaderSectionMeasure write FOnHeaderSectionMeasure;
    property OnApplyVisFilter: TApplyVisFilterEvent read FOnApplyVisFilter write FOnApplyVisFilter;
    property OnTuneUpInplaceEdit : TTuneUpInplaceEditEvent read FOnTuneUpInplaceEdit write FOnTuneUpInplaceEdit;
    property OnItemPostDraw : TElTreeItemPostDrawEvent read FOnItemPostDraw write FOnItemPostDraw;
    property OnMeasureItemPart: TMeasureItemPartEvent read FOnMeasureItemPart write FOnMeasureItemPart;
{$IFDEF HAS_HTML_RENDER}
    property OnHTMLImageNeeded : TElHTMLImageNeededEvent read FOnImageNeeded write FOnImageNeeded;
{$ENDIF}

    property OnClick : TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick : TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnDragDrop : TDragDropEvent read FOnDrop write FOnDrop;
    property OnDragOver : TDragOverEvent read FOnOver write FOnOver;
    //property OnEndDrag : TEndDragEvent read FOnDrag write FOnDrag;
    property OnEnter : TNotifyEvent read FOnEnter write FOnEnter;
    property OnExit : TNotifyEvent read FOnExit write FOnExit;
    property OnKeyDown : TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress : Tkeypressevent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp : TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnMouseDown : TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove : TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp : TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnStartDrag : TStartDragEvent read FOnStartDrag write FOnStartDrag;
    property OnHorzScrollDrawPart : TElScrollDrawPartEvent read FOnHorzScrollDrawPart write FOnHorzScrollDrawPart;
    property OnHorzScrollHintNeeded : TElScrollHintNeededEvent read FOnHorzScrollHintNeeded write FOnHorzScrollHintNeeded;
    property OnVertScrollDrawPart : TElScrollDrawPartEvent read FOnVertScrollDrawPart write FOnVertScrollDrawPart;
    property OnVertScrollHintNeeded : TElScrollHintNeededEvent read FOnVertScrollHintNeeded write FOnVertScrollHintNeeded;
    property ExpandOnDragOver : Boolean read FExpandOnDragOver write FExpandOnDragOver default false;  { Protected }
    property DragCursor : TCursor read GetDragCursor write SetDragCursor;
    property TrackColor : TColor read FTrackColor write SetTrackColor default clHighlight;
    property DoubleBuffered : boolean read FFakeBool write FFakeBool default false;
    property UseSystemHintColors : Boolean read FUseSystemHintColors write FUseSystemHintColors default false;  { Protected }
    property HeaderColor : TColor read GetHeaderColor write SetHeaderColor default clBtnFace;
    property ChangeDelay: Integer read FChangeDelay write FChangeDelay default 500;
    property RightClickSelect: Boolean read FRightClickSelect write
        FRightClickSelect default true;

    property OnHeaderMouseDown: TMouseEvent read FOnHeaderMouseDown write
        FOnHeaderMouseDown;
    property OnAfterSelectionChange: TNotifyEvent read FOnAfterSelectionChange
        write FOnAfterSelectionChange;
    property OnItemPreDraw: TOnItemExpandEvent read FOnItemPreDraw write
        FOnItemPreDraw;
    property OnDragTargetChange: TElTreeItemDragTargetEvent read
        FOnDragTargetChange write FOnDragTargetChange;
    property LineHintTimeout: Integer read FLineHintTimeout write 
        SetLineHintTimeout default 3000;
    property VerticalLinesLong: Boolean read FVerticalLinesLong write 
        SetVerticalLinesLong default true;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update; override;
    procedure Assign(Source: TPersistent); override;
    procedure FullCollapse; virtual;
    procedure FullExpand; virtual;
    function Focused: Boolean; {$IFDEF VCL_4_USED} override; {$ENDIF VCL_4_USED}
    function GetItemRect(ItemIndex: integer): TRect; virtual;
    function GetItemAtY(Y: integer): TElTreeItem; virtual;
    function GetItemAt(X, Y: Integer; var ItemPart: TSTItemPart;
      var HitColumn: integer): TElTreeItem; virtual;
    procedure MeasureCell(Item : TElTreeItem; ColumnNum : integer; var Size : TPoint); virtual;
    function GetNextSelected(Prev: TElTreeItem): TElTreeItem; virtual;
    procedure AllSelected(SelectedItems: TElList); virtual;
    procedure SelectAll; virtual;
    procedure InvertSelection; virtual;
    procedure SelectAllEx(IncludeHidden: boolean); virtual;
    procedure InvertSelectionEx(IncludeHidden: boolean); virtual;
    procedure DeselectAll; virtual;
    procedure DeselectAllEx(IncludeHidden: boolean); virtual;
    procedure SelectRange(FromItem, ToItem: TElTreeItem); virtual;
    procedure SelectRange2(FromItem, ToItem: TElTreeItem; SelectDisabled : boolean); virtual;
    procedure SelectRangeEx(FromItem, ToItem: TElTreeItem; IncludeHidden : boolean); virtual;
    procedure SelectRangeEx2(FromItem, ToItem: TElTreeItem; IncludeHidden, SelectDisabled : boolean); virtual;
    procedure Sort(recursive: boolean); virtual;
{$IFDEF SUPPORT_STORAGE}
    procedure Save; virtual;
    procedure Restore; virtual;
{$ENDIF}
    procedure EnsureVisible(Item: TElTreeItem);
    procedure EnsureVisibleBottom(Item: TElTreeItem);
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    procedure EditItem(Item: TElTreeItem; SectionNum: integer); virtual;
    procedure EndEdit(ByCancel: boolean);
    function IsEditing: boolean;
{$endif}
    procedure SaveStringsToStream(Stream: TStream); virtual;
    function GetNodeAt(X, Y: integer): TElTreeItem;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    function IsInView(Item: TElTreeItem): Boolean; virtual;
    function MeasureColumnWidth(ColumnNum: integer; VisibleOnly : boolean): integer;
    function IndexInView(Item : TElTreeItem): Integer;
    procedure AllSelectedEx(SelectedItems : TElList; Order : boolean);
    procedure SetItemFocused(Value: TElTreeItem; AutoSelect: Boolean = True);
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    property InEditState: Boolean read GetInEditing;
{$endif}
    property TopIndex: integer read FTopIndex write SetVPosition;

    property BottomIndex: integer read FBottomIndex;
    property IsUpdating: boolean read GetUpdating write SetUpdating;
    property Items: TElTreeItems read FItems write SetItems;
    property ItemFocused: TElTreeItem read GetFocused write SetFocused;
    property SelectedCount: integer read GetSelCount;

    property Selected: TElTreeItem read GetSelected write SetSelected;
    property TopItem: TElTreeitem read GetTopItem write SetTopItem;
    property DragObject : TDragObject read FDragObject;
    property View : TElTreeView read FView;
    property HorzScrollBarVisible : boolean read FHScrollVisible;
    property VertScrollBarVisible : boolean read FVScrollVisible;
    property DropTarget: TElTreeItem read GetDropTarget;
  published
    property LeftPosition: integer read FHPos write SetHPosition;
{$IFDEF VCL_4_USED}
    property BevelKind : TBevelKind read FBevelKindDummy write FBevelKindDummy stored false default bkNone;
{$ENDIF}
  end;

  TElTree = class(TCustomElTree)
  published
    property ActiveBorderType;
    property Align;
    property AlwaysKeepFocus;
    property AlwaysKeepSelection;
    property AutoExpand;
    property AutoLookup;
    property AutoResizeColumns;
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
    property AutoLineHeight;
    property BarStyle;
    property BarStyleVerticalLines;
    property BorderStyle;
    property ChangeDelay;
    property ChangeStateImage;
    property CheckBoxGlyph;
    property Ctl3D;
    property Color;
    property Cursor;
    property CustomCheckboxes;
    property CustomPlusMinus;
    property DeselectChildrenOnCollapse;
    property DivLinesColor;
    property DoInplaceEdit;
    property DragCursor;
    property DraggableSections;
    property DragAllowed;
    property DragTrgDrawMode;
    property DragType;
    property DragExpandDelay;
    property DragImageMode;
    property DrawFocusRect;
    property DragRectAcceptColor;
    property DragRectDenyColor;

    property Enabled;
    property ExpandOnDblClick;
    property ExpandOnDragOver;
    property FilteredVisibility;
    property Flat;
    property FlatFocusedScrollbars;
    property FocusedSelectColor;
    property FocusedSelectTextColor;
    property ForcedScrollBars;
    property Font stored true;
    property FullRowSelect;
    property HeaderActiveFilterColor;
    property HeaderColor;
    property HeaderHeight;
    property HeaderHotTrack;
    property HeaderInvertSortArrows;
    property HeaderSections;
    property HeaderFilterColor;
    property HeaderFlat;
    property HeaderImages;
    property HideFocusRect;
    property HideHintOnTimer;
    property HideHintOnMove;
    property HideSelectColor;
    property HideSelectTextColor;
    property HideSelection;
    property HorizontalLines;
    property HideHorzScrollBar;
    property HideVertScrollBar;
    property Hint;
    property HorzScrollBarStyles;
{$IFDEF ELPACK_COMPLETE}
    property HeaderImageForm;
    property ImageForm;
{$ENDIF}
    property Images;
    property Images2;
    property InactiveBorderType;
    property IncrementalSearch;
    property ItemIndent;
    property Items;
    property LineHeight;
    property LinesColor;
    property LinesStyle;
    property LineHintColor;
    property LineHintMode default shmLong;
    property LineHintTimeout;
    property LockHeaderHeight;
    property MainTreeColumn;
    property MinusPicture;
    property MoveColumnOnDrag;
    property MoveFocusOnCollapse;
    property MultiSelect;
    property OwnerDrawByColumn default true;
    property OwnerDrawMask;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PathSeparator;
    property PlusMinusTransparent;
    property PlusPicture;
    property PopupMenu;
    property RadioButtonGlyph;
    property RightAlignedText;
    property RightAlignedTree;
    property RightClickSelect;
    property RowHotTrack;
    property RowSelect;
    property ScrollbarOpposite;
    property ScrollTracking;
    property SelectColumn;
    property ShowButtons;
    property ShowColumns;
    property ShowCheckboxes;
{Soulsnake Add}
    property InvertClickCheckBoxes;
{End Soulsnake Add}
    property ShowEmptyImages;
    property ShowEmptyImages2;
    property ShowHint;
    property ShowImages;
    property ShowLines;
    property ShowRoot;
    property ShowRootButtons;
    property SelectionMode;
    property SortDir;
    property SortMode;
    property SortSection;
    property SortType;
{$IFDEF ELPACK_COMPLETE}
    property Storage;
    property StoragePath;
{$ENDIF}
    property StickyHeaderSections;
    property TabOrder;
    property TabStop;
    property Tracking;
    property TrackColor;
    property UnderlineTracked;
    property UseCustomScrollBars;

    property VerticalLines;
    property VerticalLinesLong;
    property VertScrollBarStyles;
    property Visible;
    property UseSystemHintColors;
    property TextColor;
    property BkColor;

    property OnScroll;
    property OnHeaderColumnClick;
    property OnHeaderColumnDraw;
    property OnHeaderColumnResize;
    property OnHeaderColumnMove;
    property OnHeaderLookup;
    property OnHeaderLookupDone;
    property OnHeaderResize;
    property OnHeaderSectionExpand;
    property OnHeaderSectionCollapse;
    property OnHeaderSectionFilterCall;
    property OnHeaderSectionAutoSize;
    property OnHeaderSectionMeasure;
    property OnHorzScrollDrawPart;
    property OnHorzScrollHintNeeded;

    property OnAfterSelectionChange;
    property OnChanging;
    property OnDragTargetChange;
    property OnItemChange;
    property OnItemPreDraw;
    property OnItemDraw;
    property OnResize;
    property OnEditRequest;
    property OnComboEditShow;
    property OnValidateCombo;
    property OnValidateInplaceEdit;
    property OnTuneUpInplaceEdit;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    property OnEditKeyDown;
{$endif}
    property OnItemChecked;
{Soulsnake Add}
    property OnItemColorPick;
{End Soulsnake Add}
    property OnItemExpand;
    property OnItemCollapse;
    property OnItemExpanding;
    property OnItemCollapsing;
    property OnItemDeletion;
    property OnItemFocused;
    property OnShowLineHint;
    property OnCompareItems;
    property OnItemPicDraw;
    property OnItemPicDraw2;
    property OnItemPostDraw;
    property OnHotTrack;
    property OnSortBegin;
    property OnSortEnd;
    property OnTryEdit;
    property OnItemSave;
    property OnItemLoad;
    property OnItemSelectedChange;
    property OnCellStyleSave;
    property OnCellStyleLoad;
    property OnVertScrollDrawPart;
    property OnVertScrollHintNeeded;
{$IFDEF HAS_HTML_RENDER}
    property OnHTMLImageNeeded;
{$ENDIF}

    property OnHeaderMouseDown;
    property OnClick;
    property OnEnter;
    property OnExit;
    property OnDragDrop;
    property OnDragOver;
    property OnStartDrag;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnDblClick;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
{$IFDEF VCL_4_USED}
    property OnStartDock;
    property OnEndDock;
{$ENDIF}
{$IFDEF VCL_5_USED}
    property OnContextPopup;
{$ENDIF}
  end;

type

  TElTreeDragObject = class(TDragControlObject)
    procedure Finished(Target: TObject; X, Y: Integer; Accepted: Boolean); override;
    function GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor; override;
    destructor Destroy; override;
  end;

const
  FDivLineWidth = 1;
  CheckBoxSize = 13;
  CheckMargin = 2;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
type
{$IFDEF ELPACK_COMPLETE}
{$ifdef ELTREE_USE_EXT_EDITORS}
     EditBoxClass  = TElButtonEdit;
     ComboBoxClass = TElFlatComboBox;
     CheckBoxClass = TElCheckBox;
{$ELSE}
     EditBoxClass  = TEdit;
     ComboBoxClass = TComboBox;
     CheckBoxClass = TCheckBox;
{$endif}
{$ELSE}
     EditBoxClass  = TEdit;
     ComboBoxClass = TComboBox;
     CheckBoxClass = TCheckBox;
{$ENDIF}
{$endif}

implementation

{.$DEFINE SPEED_TEST}

uses
{$IFDEF SPEED_TEST}
  dbugintf,
{$ENDIF}
{$IFDEF USE_RX}
  ToolEdit,
{$ENDIF}
  ElStack;

type THackElList = class(TElList)
     end;

    TSearchTextTimeoutThread =
    class (TThread)
      private
        CriticalSection : TRTLCriticalSection;
        fKeepAlive : Boolean;
        procedure SetKeepAlive (KeepAlive : Boolean);
        function GetKeepAlive : Boolean;
      protected
        procedure Execute; override;
      public
        constructor Create;
        destructor Destroy ;override;
        property KeepAlive : Boolean read GetKeepAlive write SetKeepAlive;
    end ;

const MultiLineFlags : array[boolean] of integer = (DT_SINGLELINE, 0);
      MultiLineEllipseFlags : array[boolean] of integer = (DT_END_ELLIPSIS, 0);

(*
function GetErrorMsg(ID: integer): string;
var
  p: pchar;
begin
  GetMem(p, 260);
  LoadString(HInstance, ID, p, 260);
  result := StrPas(p);
  FreeMem(p, 260);
end;
*)

procedure TSearchTextTimeoutThread.SetKeepAlive (KeepAlive : Boolean) ;
begin
  EnterCriticalSection(CriticalSection);
  try
    fKeepAlive := KeepAlive;
  finally
    LeaveCriticalSection(CriticalSection);
  end
end ;

function TSearchTextTimeoutThread.GetKeepAlive : Boolean ;
begin
  EnterCriticalSection(CriticalSection);
  try
    Result := fKeepAlive;
  finally
    LeaveCriticalSection(CriticalSection);
  end
end ;

constructor TSearchTextTimeoutThread.Create ;
begin
  inherited Create (True) ;
  InitializeCriticalSection(CriticalSection);
  fKeepAlive := False;
end ;

destructor TSearchTextTimeoutThread.Destroy ;
begin
  DeleteCriticalSection(CriticalSection);
  inherited Destroy;
end ;

procedure TSearchTextTimeoutThread.Execute ;
begin
  while not Terminated do
  begin
    Sleep (500);
    if not KeepAlive then
      break ;
    KeepAlive := False
  end
end ;

function TElTreeDragObject.GetDragCursor(Accepted: Boolean; X, Y: Integer): TCursor;
begin
  if Accepted and (Control is TCustomElTree) then
     result := (Control as TCustomElTree).DragCursor
  else
     result := inherited GetDragCursor(Accepted, X, Y); 
end;

procedure TElTreeDragObject.Finished;
begin
  inherited;
  Free;
end;

destructor TElTreeDragObject.Destroy;
begin
  inherited;
end;

// ****************************************************************************
//                            TElCellControl
// ****************************************************************************

{$ifdef ELTREE_USE_STYLES}
procedure TElCellControl.Update;
begin
  if Visible and (Owner <> nil) then Owner.Update;
end;

constructor TElCellControl.Create;
begin
  inherited Create(nil);
  FVisible := true;
  FEnabled := true;
end;

destructor TElCellControl.Destroy;
begin
  if Owner <> nil then
  begin
    Owner.FControl := nil;
    Owner.Update;
  end;
  inherited;
end;

procedure TElCellControl.SetCaption(newValue: TCaption);
{ Sets data member FCaption to newValue. }
begin
  if (FCaption <> newValue) then
  begin
    FCaption := newValue;
    if Visible then Update;
  end; { if }
end; { SetCaption }

procedure TElCellControl.TriggerClickEvent;
{ Triggers the OnClick event. This is a virtual method (descendants of this component can override it). }
begin
  if (assigned(FOnClick)) then FOnClick(Self);
end; { TriggerClickEvent }

procedure TElCellControl.TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{ Triggers the onMousedown event. This is a virtual method (descendants of this component can override it). }
begin
  if (assigned(FOnMouseDown)) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end; { TriggerMouseDownEvent }

procedure TElCellControl.TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{ Triggers the OnMouseUp event. This is a virtual method (descendants of this component can override it). }
begin
  if (assigned(FOnMouseUp)) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end; { TriggerMouseUpEvent }

procedure TElCellControl.TriggerDblClickEvent;
{ Triggers the OnDblClick event. This is a virtual method (descendants of this component can override it). }
begin
  if (assigned(FOnDblClick)) then
    FOnDblClick(Self);
end; { TriggerDblClickEvent }

procedure TElCellControl.TriggerMouseMoveEvent(Shift: TShiftState; X, Y: Integer);
{ Triggers the OnMouseMove event. This is a virtual method (descendants of this component can override it). }
begin
  if (assigned(FOnMouseMove)) then
    FOnMouseMove(Self, Shift, X, Y);
end; { TriggerMouseMoveEvent }
(*
procedure TElCellControl.SetBoundsRect(newValue : TRect);
begin
  if not EqualRect(FBoundsRect, newValue) then
  begin
    FBoundsRect := newValue;
    if Visible then Update;
  end;  { if }
end;  { SetBoundsRect }
*)

procedure TElCellControl.SetVisible(newValue: Boolean);
begin
  if (FVisible <> newValue) then
  begin
    FVisible := newValue;
    //if not newValue then FBoundsRect := Rect(0, 0, 0, 0);
    Update;
  end; {if}
end;

procedure TElCellControl.SetEnabled(newValue: Boolean);
begin
  if (FEnabled <> newValue) then
  begin
    FEnabled := newValue;
    Update;
  end; {if}
end; {SetEnabled}

procedure TElCellControl.SetPopupMenu(newValue: TPopupMenu);
begin
  if (FPopupMenu <> newValue) then
  begin
    FPopupMenu := newValue;
    if FPopupMenu <> nil then FPopupMenu.FreeNotification(Self);
  end;  {if}
end;

procedure TElCellControl.Notification(AComponent: TComponent; Operation:
  TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FPopupMenu) then FPopupMenu := nil;
end;

// ****************************************************************************
//                              TElCellCheckBox  
// ****************************************************************************

{$IFDEF ELPACK_COMPLETE}

procedure TElCellCheckBox.SetState(newValue : TCheckBoxState);
begin
  if FState <> newValue then
  begin
    if (newValue = cbGrayed) and not FAllowGrayed then exit;
    FState := newValue;
    Update;
  end;
end;

procedure TElCellCheckBox.SetAllowGrayed(newValue : Boolean);
begin
  if (not newValue) and (FState = cbGrayed) then State := cbUnchecked;
  FAllowGrayed := newValue;
end;

function TElCellCheckBox.GetChecked : Boolean;
begin
  result := FState = cbChecked;
end;

procedure TElCellCheckBox.SetChecked(newValue : Boolean);
begin
  if newValue
     then State := cbChecked
     else State := cbUnchecked;
end;

procedure TElCellCheckBox.SetAlignment(newValue : TAlignment);
begin
 if (FAlignment <> newValue) then
  begin
    FAlignment := newValue;
    Update;
  end; { if }
end;

procedure TElCellCheckBox.Paint(Canvas: TCanvas; R: TRect);
var
  ARect : TRect;
  SrcRect,
    CheckRect : TRect;
  cbh, ch,
  cw, cbw : integer;
  i : integer;
  FTree : TCustomElTree;
  AFont : TFont;
  FGlyph: TBitmap;
begin
  {Canvas.Brush.Color := Color;
  Canvas.FillRect(R);
  }
  ARect  := R;
  FTree  := FOwner.FOwner.FOwner;
  FGlyph := FTree.FCheckBoxGlyph;
  if FTree.FCustomCheckboxes and (not FGlyph.Empty) then
  begin
    cbh := FGlyph.Height;
    cbw := FGlyph.Width div 6;
    case State of
      cbUnchecked :
        if Enabled then SrcRect := Rect(0, 0, cbw, cbh) else SrcRect := Rect(cbw, 0, cbw * 2, cbh);
      cbChecked :
        if Enabled then SrcRect := Rect(cbw * 2, 0, cbw * 3, cbh) else SrcRect := Rect(cbw * 3, 0, cbw * 4, cbh);
      cbGrayed :
        if Enabled then SrcRect := Rect(cbw * 4, 0, cbw * 5, cbh) else SrcRect := Rect(cbw * 5, 0, cbw * 6, cbh);
    end;
    i := 0;
  end
  else
  begin
    cbw := CheckBoxSize;
    cbh := CheckBoxSize;
    i := DFCS_BUTTONCHECK or DFCS_CHECKED;
    begin
      case State of
        cbChecked : i := DFCS_BUTTONCHECK or DFCS_CHECKED;
        cbUnchecked : i := DFCS_BUTTONCHECK;
        cbGrayed : i := DFCS_BUTTON3STATE or DFCS_CHECKED;
      end; // case
    end;
    if (not Enabled) {or (FMouseInControl and FPressed) }then i := i or DFCS_INACTIVE;
  end;
  ch := R.Bottom - R.Top + 1;
  cw := R.Right {- R.Left} + 1;
  if (Alignment = taRightJustify) xor FTree.RightAlignedText then
  begin
    CheckRect := Rect(R.Left + CheckMargin, R.Top + (ch div 2 - cbh div 2), R.Left + CheckMargin + cbw, R.Top + (ch div 2 + cbh - cbh div 2));
  end
  else
  if (Alignment = taRightJustify) xor FTree.RightAlignedText then
  begin
    CheckRect := Rect(cw - CheckMargin - cbw, R.Top + (ch div 2 - cbh div 2), cw - CheckMargin, R.Top + (ch div 2 + cbh - cbh div 2));
  end
  else
  if Alignment = taCenter then
  begin
    CheckRect := Rect((R.Left + R.Right - cbw) div 2 - 1 , R.Top + (ch div 2 - cbh div 2), (R.Left + R.Right - cbw) div 2 + cbw, R.Top + (ch div 2 + cbh - cbh div 2));
  end;

  if FTree.FCustomCheckboxes and (not FGlyph.Empty) then
  begin
    Canvas.CopyRect(CheckRect, FGlyph.Canvas, SrcRect);
  end
  else
  begin
    DrawFrameControl(Canvas.Handle, CheckRect, DFC_BUTTON, i);
    //if (Flat and not (Focused or FMouseInControl or FPressed)) and Enabled then DrawFlatFrame(CheckRect);
  end;
  if (Alignment = taRightJustify) xor FTree.RightAlignedText then
  begin
    ARect.Left := ARect.Left + cbw + CheckMargin * 2;
  end else
  begin
    ARect.Right := ARect.Right - cbw - CheckMargin * 2;
  end;
  Canvas.Brush.Style := bsClear;
  InflateRect(ARect, -1, -1);
  AFont := TFont.Create;
  AFont.Assign(Canvas.Font);
  Canvas.Font.Assign(FTree.Font);
  if not Enabled then
  begin
    OffsetRect(ARect, 1, 1);
    Canvas.Font.Color := clBtnHighlight;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), ARect, DT_SINGLELINE or DT_LEFT or DT_VCENTER);
    Canvas.Font.Color := clBtnShadow;
    OffsetRect(ARect, -1, -1);
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), ARect, DT_SINGLELINE or DT_LEFT or DT_VCENTER);
  end
  else
  begin
    Canvas.Font.Color := FTree.TextColor;
    DrawTypedText(Canvas, ARect, Caption, DT_SINGLELINE or DT_LEFT or DT_VCENTER, tdtNormal);
  end;
end; { Paint }

procedure TElCellCheckBox.TriggerClickEvent;
var
  State : TCheckBoxState;
begin
  State := Self.State;
  case State of
    cbChecked : Checked := false;
    cbGrayed : Checked := true;
    cbUnchecked :
      if AllowGrayed then Self.State := cbGrayed else Checked := true;
  end;
  inherited;
end;

procedure TElCellCheckBox.TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TElCellCheckBox.TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
end;

procedure TElCellCheckBox.Assign(Source: TElCellControl);
begin
  inherited;
end;

constructor TElCellCheckBox.Create;
begin
  inherited;
  Alignment := taRightJustify;
end;

destructor TElCellCheckBox.Destroy;
begin
  inherited;
end;

// ****************************************************************************
//                                   TElCellButton       
// ****************************************************************************

function TElCellButton.GetGlyph: TBitmap;
begin
  Result := FGlyph.Glyph;
end; {GetGlyph}

procedure TElCellButton.FontChanged(Sender: TObject);
begin
  Update;
end;

procedure TElCellButton.GlyphChanged(Sender: TObject);
begin
  Update;
end;

procedure TElCellButton.SetGlyph(newValue: TBitmap);
begin
  FGlyph.Glyph := newValue;
  Update;
end; {SetGlyph}

procedure TElCellButton.SetDown(newValue: Boolean);
begin
  if (FDown <> newValue) then
  begin
    FDown := newValue;
    Update;
  end; {if}
end; {SetDown}

procedure TElCellButton.Assign;
begin
  if Source is TElCellButton then
    with Source as TElCellButton do
    begin
      Self.Glyph := Glyph;
      Self.FFixClick := FixClick;
      Self.FDown := Down;
    end else inherited;
end;

procedure TElCellButton.TriggerMouseDownEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FFixClick then SetDown(not Down) else SetDown(true);
  inherited;
end;

procedure TElCellButton.TriggerMouseUpEvent(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not FFixClick then SetDown(false);
  inherited;
end;

procedure TElCellButton.Paint(Canvas: TCanvas; R: TRect);
var
  DrawFlags: Integer;
  FState   : TElButtonState;
  FBrush   : TBrush;
  FPen     : TPen;
  FSFont   : TFont;
begin
  DrawFlags := DFCS_BUTTONPUSH or DFCS_ADJUSTRECT;
  if (FDown) then DrawFlags := DrawFlags or DFCS_PUSHED;
  DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DrawFlags);
  InflateRect(R, 1, 1);
  if not FEnabled then FState := ebsDisabled else
    if FDown then
    begin
      FState := ebsDown;
      OffsetRect(R, 1, 1);
    end else FState := ebsUp;
  FBrush   := TBrush.Create;
  FPen     := TPen.Create;
  FSFont   := TFont.Create;
  FBrush.Assign(Canvas.Brush);
  FPen.Assign(Canvas.Pen);
  FSFont.Assign(Canvas.Font);
  Canvas.Font.Assign(FFont);
  FGlyph.Draw(Canvas, R, Point(0, 0), Caption, FLayout, 1, 1, FState, FState, false,
    Pos(#13#10, FCaption) > 0, false, true, true, 0, tdtNormal, clBtnFace);
  Canvas.Font.Assign(FSFont);
  Canvas.Pen.Assign(FPen);
  Canvas.Brush.Assign(FBrush);
end; {Paint}

procedure TElCellButton.SetFont(newValue: TFont);
begin
  FFont.Assign(newValue);
end;

procedure TElCellButton.SetLayout(newValue: TButtonLayout);
begin
  if (FLayout <> newValue) then
  begin
    FLayout := newValue;
    Update;
  end; {if}
end;

function TElCellButton.GetUseImageList : Boolean;
{ Returns the value of data member FUseImageList. }
begin
  result := FGlyph.UseImageList; //FUseImageList;
end;  { GetUseImageList }

procedure TElCellButton.SetUseImageList(newValue : Boolean);
{ Sets data member FUseImageList to newValue. }
begin
  if (FGlyph.UseImageList <> newValue) then
  begin
    FGlyph.UseImageList := newValue;
    Update;
  end;  { if }
end;  { SetUseImageList }

function TElCellButton.GetImageList : TImageList;
{ Returns the value of data member FImageList. }
begin
  result := FGlyph.ImageList;
end;  { GetImageList }

procedure TElCellButton.SetImageList(newValue : TImageList);
{ Sets data member FImageList to newValue. }
begin
  if (FGlyph.ImageList <> newValue) then
  begin
    FGlyph.ImageList := newValue;
    if FGlyph.ImageList <> nil then FGlyph.ImageList.FreeNotification(Self);
    if UseImageList then Update;
  end;  { if }
end;  { SetImageList }

function TElCellButton.GetImageIndex : Integer;
{ Returns the value of data member FImageIndex. }
begin
  result := FGlyph.ImageIndex;
end;  { GetImageIndex }

procedure TElCellButton.SetImageIndex(newValue : Integer);
{ Sets data member FImageIndex to newValue. }
begin
  if (FGlyph.ImageIndex <> newValue) then
  begin
    FGlyph.ImageIndex := newValue;
    if UseImageList then Update;
  end;  { if }
end;  { SetImageIndex }

destructor TElCellButton.Destroy;
begin
  Dec(ButtonCount);
  if ButtonCount <= 0 then
  begin
    Pattern.Free;
    Pattern := nil;
  end;
  FFont.Free;
  FGlyph.Free;
  inherited;
end;

constructor TElCellButton.Create;
begin
  FGlyph := TElCellButtonGlyph.Create;
  FGlyph.OnChange := GlyphChanged;
  inherited;
  Inc(ButtonCount);
  FDown := False;
  FLayout := blGlyphLeft;
  FFont := TFont.Create;
  FFont.Color := clBtnText;
  FFont.OnChange := FontChanged;
end; {Create}

{$ENDIF}
{$endif ELTREE_USE_STYLES}

// ****************************************************************************
//                                TElTreeView    
// ****************************************************************************

constructor TElTreeView.Create(Owner : TComponent);
begin
  FOwner := Owner as TCustomElTree;
  inherited;
  ControlStyle := ControlStyle + [csOpaque, csDisplayDragImage];
  FVisible := TElList.Create;
  FFullVisible := TElList.Create;
  FHRange := -1;
end;

destructor TElTreeView.Destroy;
begin
  StopClearSearchTimeoutThread;

  if FDragExpandTimer <> nil then
  begin
    FDragExpandTimer.Free;
    FDragExpandTimer := nil;
  end;
  if FHintItem <> nil then
     DoHideLineHint;
  FHintItemEx := nil;
  If FHintTimer <> nil then
  begin
    FHintTimer.Free;
    FHintTimer := nil;
  end;
  if FHintWnd <> nil then
  begin
    FHintWnd.Free;
    FHintWnd := nil;
  end;
  if FDragScrollTimer <> nil then
  begin
    FDragScrollTimer.Free;
    FDragScrollTimer := nil;
  end;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if FInpEdit <> nil then
  begin
    DoEndEdit(true);
    if FFakePopup <> nil then FFakePopup.Free;
    FFakePopup := nil;
  end;
  if FEditTimer <> nil then FEditTimer.Free;
{$endif}
  FVisible.Free;
  FFullVisible.Free;
  inherited;
end;

procedure TElTreeView.DoHideLineHint;
begin
  FHintItem := nil;
  if FHintTimer <> nil then
  begin
    FHintTimer.Free;
    FHintTimer := nil;
  end;
  if FHintWnd <> nil then
  begin
    FHintWnd.ReleaseHandle;
    FHintWnd.Hide;
    //FHintWnd.Free;
    //FHintWnd := nil;
  end;
end;

procedure TElTreeView.DoShowLineHint;
var
  s: string;
  R, R1, R2: TRect;
  dx, dy: integer;
  b: boolean;
  P: TPoint;
  xOffs : integer;
begin
  R1 := GetItemRect(FVisible.IndexOf(Item));
  if IsRectEmpty(R1) then exit;
  if FHintWnd = nil then
     FHintWnd := TElHintWindow.Create(self);
  if Item.Hint <> '' then
     S := Item.Hint
  else
     S := Item.Text;
  if not FOwner.UseSystemHintColors then
  begin
    FHintWnd.Color        := FOwner.FLineHintColor;
    FHintWnd.Font.Color   := FOwner.FTextColor;
  end
  else
  begin
    FHintWnd.Color := clInfoBk;
    FHintWnd.Font.Color := clInfoText;
  end;
  FHintWnd.Font.Charset := Font.Charset;

{$IFDEF HAS_HTML_RENDER}
  if Item.IsHTML then
     FHintWnd.IsHTML := true;
{$ENDIF}

  with FOwner do
    if FHeader.Visible and (FMainTreeCol <> - 1) and
         (FHeader.Sections.Count > FMainTreeCol)
         then
      xOffs := - FHPos
    else
      xOffs := 0;

  R1.Left := Max(0, Item.FTextLeft - FOwner.FHPos - xOffs);
{$IFNDEF VER90}
  R := FHintWnd.CalcHintRect(10000, S, nil);
{$ELSE}
  R.Left := 0;
  R.Right := FHintWnd.Canvas.TextWidth(S) + 6;
  R.Top := 0;
  R.Bottom := FHintWnd.Canvas.TextHeight(S) + 2;
{$ENDIF}

  dec(R.Bottom, 2);
  dx := R.Right - R.Left + 1;
  dy := R.Bottom - R.Top + 1;
  R.Left := R1.Left;
  R.Top := R1.Top;
  R.Right := R.Left + dx;
  R.Bottom := R.Top + dy;
  R.TopLeft := ClientToScreen(R.TopLeft);
  R.BottomRight := ClientToScreen(R.BottomRight);
  FHintWnd.BoundsRect := R;
  b := true;
  P := FHintCoord;
  if FOwner.ShowColumns then Inc(P.Y, FOwner.HeaderHeight);
  FOwner.DoShowHint(Item, S, FHintWnd, P, b);
  if (b and (S <> Item.Text)) then
  begin
    R := FHintWnd.BoundsRect;
{$IFNDEF VER90}
    R2 := FHintWnd.CalcHintRect(10000, S, nil);
{$ELSE}
    R2.Left := 0;
    R2.Right := FHintWnd.Canvas.TextWidth(S) + 6;
    R2.Top := 0;
    R2.Bottom := FHintWnd.Canvas.TextHeight(S) + 2;
{$ENDIF}
    dec(R2.Bottom, 2);
    dx := R2.Right - R2.Left + 1;
    dy := R2.Bottom - R2.Top + 1;
    R.Right := R.Left + dx;
    R.Bottom := R.Top + dy;
  end;
  if b then
  begin
    FHintItem := Item;
    FHintWnd.ActivateHint(R, S);
  end;
end;

procedure TElTreeView.WndProc(var Message: TMessage);
var P1 : TPoint;
    Item : TElTreeItem;
    HCol : Integer;
    IP : TSTItemPart;
begin
  if (FHintItem <> nil) and (FOwner.FHideHintOnMove) then
  begin
    if ((Message.Msg >= WM_MOUSEMOVE) and (Message.Msg <= WM_MOUSELAST)) or (Message.Msg = WM_NCMOUSEMOVE) then
    begin
      GetCursorPos(P1);
      P1 := ScreenToClient(P1);
      Item := GetItemAt(P1.X, P1.Y, IP, HCol);
      if Item <> FHintItem then
         DoHideLineHint;
      inherited;
      exit;
    end else
    if
      ((Message.Msg >= WM_KEYFIRST) and (Message.Msg <= WM_KEYLAST)) or
      ((Message.Msg = CM_ACTIVATE) or (Message.Msg = CM_DEACTIVATE)) or
      (Message.Msg = CM_APPKEYDOWN) or (Message.Msg = CM_APPSYSCOMMAND) or
      (Message.Msg = WM_COMMAND) or
      ((Message.Msg > WM_MOUSEMOVE) and (Message.Msg <= WM_MOUSELAST))
      or (Message.Msg = WM_NCMOUSEMOVE) then
      DoHideLineHint;
  end;
  if (FHintItem <> nil) and ((Message.Msg = CM_ACTIVATE) or (Message.Msg = CM_DEACTIVATE))
    or (Message.Msg = WM_NCMOUSEMOVE) then
    DoHideLineHint;
  inherited;
end;

procedure TElTreeView.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

{$IFDEF VCL_4_USED}
procedure TElTreeView.CMMouseWheel(var Msg : TCMMouseWheel);  { private }
{Original}
(*var
  Dy : integer;
  sl : integer;
begin
  if IsWinNT or IsWin98 then SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @sl, SPIF_SENDCHANGE) else sl := 3;
  if sl = 0 then sl := 1;
  Dy := Msg.WheelDelta div (MOUSE_WHEEL_DELTA div sl);
  if Dy <> 0 then SetVPosition(FOwner.FTopIndex - Dy);*)
{End Original}
{Soulsnake Fix}
begin
{End Soulsnake Fix}
end;  { CMMouseWheel }
{$ENDIF}

procedure TElTreeView.WMMouseWheel(var Msg: TWMMouseWheel); { private }
var
  Dy : integer;
  sl : integer;
begin
  if IsWinNT or IsWin98 then SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @sl, SPIF_SENDCHANGE) else sl := 3;
  if sl = 0 then sl := 1;
  Dy := Msg.WheelDelta div (MOUSE_WHEEL_DELTA div sl);
  if Dy <> 0 then SetVPosition(FOwner.FTopIndex - Dy);
end; { WMMouseWheel }

procedure TElTreeView.OnHintTimer;
var
  Item  : TElTreeItem;
  R3: TRect;
  xOffs : integer;
begin
  if FHintItem <> nil then
  begin
    DoHideLineHint;
    exit;
  end;
  FHintTimer.Enabled := false;
  if not FOwner.HandleAllocated then exit;
  Item := GetItemAtY(FHintCoord.Y);
  if Item = nil then exit;
  if (not (csDesigning in ComponentState)) then
  begin
    if (FOwner.FShowHintMode = shmLong) and (Item.Hint = '') then
    begin
      SetRectEmpty(R3);
{$IFDEF HAS_HTML_RENDER}
      if Item.IsHTML and (Copy(Item.Text, 1, 6) = '<html>') then
      begin
        if Item.FHTMLData <> nil then
        begin
          R3.Right := Item.FHTMLData.TextSize.cx;
          R3.Bottom := Item.FHTMLData.TextSize.cy;
        end;
      end else
{$ENDIF}
        DrawText(Canvas.Handle, PChar(Item.Text), Length(Item.Text), R3, DT_NOPREFIX or DT_CALCRECT);
    end;
    with FOwner do
      if FHeader.Visible and (FMainTreeCol <> - 1) and
         (FHeader.Sections.Count > FMainTreeCol)
         then
       xOffs := - FHPos
    else
       xOffs := 0;

    if (FHintItem = nil) and
      ((FOwner.FShowHintMode = shmAll) or (Item.Hint <> '') or
      (
      (FOwner.FShowHintMode = shmLong) and
      ((Canvas <> nil) and
      ((R3.Right - R3.Left) > (Item.FTextRight - Item.FTextLeft)) or
      ((Item.FTextRight > ClientWidth + FOwner.FHPos + xOffs) or (Item.FTextLeft < FOwner.FHPos + xOffs))))) then
      DoShowLineHint(Item);
    if FOwner.FHintHide then
    begin
      if FOwner.FLineHintTimeout <= 0 then
      begin
        FHintTimer.Interval := Application.HintHidePause;
        if FHintTimer.Interval = 0 then
          FHintTimer.Interval := 1000;
      end
      else
        FHintTimer.Interval := FOwner.FLineHintTimeout;
      FHintTimer.Enabled := true;
    end;
  end;
end;

procedure TElTreeView.SetHPosition(value: integer);
var
  Code: Word;
{$IFNDEF VER90}
  Form: TCustomForm;
{$ELSE}
  Form: TForm;
{$ENDIF}
begin
  FOwner.IsUpdating := true;
  if csReading in ComponentState then FOwner.FHPos := Value
  else
  begin
    if Value > FHRange - Width then Value := FHRange - Width;
    //if Value > FHRange then Value := FHRange;
    if Value < 0 then Value := 0;
    if Value <> FOwner.FHPos then
    begin
      FOwner.FHPos := Value;
      with FOwner do
      begin
        FHeader.LeftPos := FHPos;
        {//LockedColumn, update
         FHeader.Left := -FHPos;
        FHeader.Width := FHPos + FView.Width;}
      end;
      FClearAll := true;
      if csDesigning in ComponentState then
      begin
        Form := GetParentForm(self);
        if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
      end;
      FOwner.FUpdated := true;
      FRangeUpdate := true;
    end;
    Code := SB_CTL;
    with FOwner do
      if Windows.GetScrollPos(FHScrollBar.Handle, Code) <> FHPos then SetScrollPos(fhscRollbar.Handle, Code, FHPos, true);
  end;
  FOwner.IsUpdating := false;
end;

procedure TElTreeView.SetVPosition(value: integer);
var
  Code: Word;
  MaxV: integer;
{$IFNDEF VER90}
  Form: TCustomForm;
{$ELSE}
  Form: TForm;
{$ENDIF}

begin
  FOwner.IsUpdating := true;
  FTrackItem := nil;
  FTrackSection := nil;
  if csReading in ComponentState then
    FOwner.FTopIndex := Value
  else
  begin
    with FOwner do
    begin
      if TotalVarHeightCount > 0 then
      begin
        if TotalVisCount = 0 then GetTotalVisCount;
        maxV := CalcPageUpPos(TotalVisCount - 1) + 1;
      end else
      begin
        if TotalVisCount = 0 then
          GetTotalVisCount;
        maxV := TotalVisCount - GetVisCount + 1;
      end;
      if Value >= maxV then Value := maxV;
    end;
    if Value < 0 then Value := 0;
    if Value <> FOwner.FTopIndex then
    begin
      FOwner.FUpdated := true;
      FClearVis := true;
      FClearAll := true;
      DoSetTopIndex(Value);
    end;
    if csDesigning in ComponentState then
    begin
      Form := GetParentForm(self);
      if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
    end;
    Code := SB_CTL;
    with FOwner do
      SetScrollPos(FVScrollBar.Handle, Code, FTopIndex, True);
  end;
  FOwner.IsUpdating := false;
end;

procedure TElTreeView.DoSetTopIndex;
var MaxV : integer;
begin
  if ((value >= FItems.Count) and (value > 0)) or (value < 0) then
    // Raise EElTreeError.Create(GetErrorMsg(STExOutOfBounds));
    value := 0;
  with FOwner do
  begin
    if TotalVisCount = 0 then GetTotalVisCount;
    if TotalVarHeightCount > 0 then
      maxV := CalcPageUpPos(TotalVisCount - 1) + 1
    else
      maxV := TotalVisCount - View.GetVisCount + 1;
    if (Value < 0) or (MaxV < 0) then Value := 0 else
    if Value > MaxV then Value := MaxV;
    FTopIndex := value;
    if (FTopIndex = 0) and (FItems.Count = 0) then FBottomIndex := 0
    else
    begin
      FillVisFwd(FTopIndex);
      FBottomIndex := FTopIndex + FVisible.Count - 1;
    end;
  end;
end;

procedure TElTreeView.FillVisFwd;
var i, j, k : integer;
    Item : TElTreeItem;
    ah, th, CurHeight : integer;
begin
  FVisible.Clear;
{Soulsnake Add}
  FFullVisible.Clear;
{End Soulsnake Add}
  th := Height;
  i := 0;
  j := FOwner.FAllList.Count;
  k := 0;
  CurHeight := 0;
  while k < j do
  begin
    Item := TElTreeItem(FOwner.FAllList[k]);
    if (FOwner.FilteredVisibility and Item.Hidden) then
      k := FOwner.FAllList.IndexOfFrom(k, Item.GetLastSubItem)
    else
    begin
      if i >= StartIndex then
      begin
        if (CurHeight > th) then break;
        if FOwner.TotalVarHeightCount > 0 then
           ah := Item.GetHeight
        else
           ah := FOwner.LineHeight;
        FVisible.Add(Item);
        inc(CurHeight, ah);
        if (CurHeight > th) then break
{Soulsnake Add}
        else FFullVisible.Add(Item);
{End Soulsnake Add}
      end;
      if (Item.FChildren <> nil) and (Item.FChildren.Count > 0) then
         if not Item.Expanded then
           k := FOwner.FAllList.IndexOfFrom(k, Item.GetLastSubItem);
      inc(i);
    end;
    inc(k);
  end;
end;

procedure TElTreeView.WMSize(var Msg : TWMSize);  { private }
begin
  inherited;
  begin
    FOwner.IsUpdating := true;
    FOwner.FUpdated := true;
    FClearVis := true;
    FClearAll := true;
    DoSetTopIndex(FOwner.FTopIndex);
    FOwner.IsUpdating := false;
  end;
  //Invalidate;
end;  { WMSize }

const ScrollCodesToInt : array [TElScrollCode] of Integer = (SB_LINEUP, SB_LINEDOWN, SB_PAGEUP, SB_PAGEDOWN, SB_THUMBPOSITION, SB_THUMBTRACK, SB_TOP, SB_BOTTOM, SB_ENDSCROLL, SB_ENDSCROLL + 1, SB_ENDSCROLL + 2);

procedure TElTreeView.OnHScroll(Sender: TObject; ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange : boolean);
var AScrollCode : TElScrollCode;
begin
  AScrollCode := ScrollCode;
  if AScrollCode = escSndLineDown then
  begin
    if FOwner.FVScrollBar.SecondBtnKind = sbkOpposite then AscrollCode := escLineUp else
    if FOwner.FVscrollBar.SecondBtnKind = sbkPage then AScrollCode := escPageDown;
  end else
  if AScrollCode = escSndLineUp then
  begin
    if FOwner.FVscrollBar.SecondBtnKind = sbkOpposite then AscrollCode := escLineDown else
    if FOwner.FVscrollBar.SecondBtnKind = sbkPage then AScrollCode := escPageUp;
  end;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if FInpEdit <> nil then DoEndEdit(false);
{$endif}
  with FOwner do
  case AScrollCode of
    escLineUp : SetHPosition(FHPos - 4);
    escLineDown: SetHPosition(FHPos + 4);
    escPageUp: SetHPosition(FHPos - Self.Width div 2);
    escPageDown: SetHPosition(FHPos + Self.Width div 2);
    escPosition: SetHPosition(ScrollPos);
    escTrack: if FScrollTracking then SetHPosition(ScrollPos);
    escTop: SetHPosition(0);
    escBottom: SetHPosition(FHRange);
  end; // case
  FOwner.TriggerScrollEvent(sbHorizontal, ScrollCodesToInt[ScrollCode]);
  {with FOwner do
    if Flat or FUseCustomBars then DrawFlatBorder(false, false);
  }
  DoChange := false;
end;

procedure TElTreeView.OnVScroll(Sender: TObject; ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange : boolean);
var AScrollCode : TElScrollCode;
    aNewPos     : integer;
begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if (FInpEdit <> nil) then
  begin
    DoChange := false;
    FScrollFirstClick := not FScrollFirstClick;
    if FScrollFirstClick then
    begin
      FOwner.FVScrollbar.EndScroll;
      exit
    end
    else
    if ScrollCode <> escEndScroll then
      if not DoEndEdit(false) then exit;
  end
  else
{$endif}
    FScrollFirstClick := false;

  AScrollCode := ScrollCode;
  if AScrollCode = escSndLineDown then
  begin
    if FOwner.FVscrollBar.SecondBtnKind = sbkOpposite then AscrollCode := escLineUp else
    if FOwner.FVscrollBar.SecondBtnKind = sbkPage then AScrollCode := escPageDown;
  end else
  if AScrollCode = escSndLineUp then
  begin
    if FOwner.FVscrollBar.SecondBtnKind = sbkOpposite then AscrollCode := escLineDown else
    if FOwner.FVscrollBar.SecondBtnKind = sbkPage then AScrollCode := escPageUp;
  end;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if FInpEdit <> nil then DoEndEdit(false);
{$endif}
  with FOwner do
  case AScrollCode of
    escLineUp:   SetVPosition(FTopIndex - 1);
    escLineDown: SetVPosition(FTopIndex + 1);
    escPageUp  :
      begin
        {aNewPos := CalcPageUpPos(FTopIndex);
        if (aNewPos = FTopIndex) and (FVisible.Count = 1) and (TotalVisCount <> 1) then dec(aNewPos);}
        if FOwner.TotalVarHeightCount > 0 then
           aNewPos := CalcPageUpPos(FTopIndex)
        else
           aNewPos := FTopIndex - (GetVisCount - 1);
        if aNewPos < 0 then aNewPos := 0;
        SetVPosition(aNewPos);
      end;
    escPageDown:
      begin
        if FOwner.TotalVarHeightCount > 0 then
           aNewPos := CalcPageDownPos(FTopIndex)
        else
           aNewPos := FTopIndex + (GetVisCount - 1);
        if (aNewPos = FTopIndex) and (FVisible.Count = 1) and (TotalVisCount <> 1) then inc(aNewPos);
        SetVPosition(aNewPos);
      end;
    escPosition: SetVPosition(ScrollPos);
    escTop:      SetVPosition(0);
    escBottom:   SetVPosition(TotalVisCount);
    escTrack:    if FScrollTracking then SetVPosition(ScrollPos);
  end; // case
  FOwner.TriggerScrollEvent(sbVertical, ScrollCodesToInt[ScrollCode]);
  {with FOwner do
    if Flat or FUseCustomBars then DrawFlatBorder(false, false);
  }
  DoChange := false;
end;

function TElTreeView.CalcPageUpPos;
var i : integer;

type TSRec = record
       MaxHeight : integer;
       CurHeight : integer;
       CurIdx    : integer;
       StartIdx  : integer;
     end;
     PSRec = ^TSRec;

     procedure IntPrevVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
               IterateData: pointer; Tree: TCustomElTree);
     begin
       with PSRec(IterateData)^ do
       begin
         CurIdx := Item.VisIndex;
         Inc(CurHeight, Item.GetHeight);
         if CurHeight >= MaxHeight then ContinueIterate := false;
       end;
     end;

var SRec : TSRec;

begin
  i := CurIdx;
  if (i = 0) or (FVisible.Count = 0) then
  begin
    result := 0;
    exit;
  end;
  SRec.MaxHeight := ClientHeight;
  SRec.CurHeight := 0;
  SRec.CurIdx := i;
  SRec.StartIdx := i;
  FOwner.FItems.IterateBackFrom(true, @IntPrevVis, @SRec, FOwner.FItems.GetVisItem(i));
  result := SRec.CurIdx;
end;

function TElTreeView.CalcPageDownPos;
var i : integer;

type TSRec = record
       MaxHeight : integer;
       CurHeight : integer;
       CurIdx    : integer;
       StartIdx  : integer;
     end;
     PSRec = ^TSRec;

     procedure IntPrevVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
               IterateData: pointer; Tree: TCustomElTree);
     begin
       with PSRec(IterateData)^ do
       begin
         CurIdx := Item.VisIndex;
         Inc(CurHeight, Item.GetHeight);
         if CurHeight >= MaxHeight then ContinueIterate := false;
       end;
     end;

var SRec : TSRec;

begin
  i := CurIdx;
  if (FVisible.Count = 0) then
  begin
    result := 0;
    exit;
  end;
  SRec.MaxHeight := ClientHeight;
  SRec.CurHeight := 0;
  SRec.CurIdx := i;
  SRec.StartIdx := i;
  FOwner.FItems.IterateFrom(true, @IntPrevVis, @SRec, FItems.GetVisItem(i));
  result := SRec.CurIdx;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TElTreeView.ProcessFloatEditResults(ByCancel : boolean);
begin
  ProcessTextEditResults(ByCancel);
end;

procedure TElTreeView.ProcessBlobEditResults(ByCancel : boolean);
begin
  // Intentionally left blank
end;

procedure TElTreeView.ProcessPictureEditResults(ByCancel : boolean);
begin
  // Intentionally left blank
end;

procedure TElTreeView.ProcessCustomEditResults(ByCancel : boolean);
begin
  // Intentionally left blank
end;

procedure TElTreeView.ProcessDateTimeEditResults(ByCancel : boolean);
{$ifdef ELTREE_USE_EXT_EDITORS}
{$ifdef ELPACK_COMPLETE}
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;
{$endif}
{$endif}
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
{$ifdef ELPACK_COMPLETE}
  b := not ByCancel;
  TElDateTimePicker(FInpEdit).OnExit := nil;
  if b then
    S := DateTimeToStr(TElDateTimePicker(FInpEdit).DateTime)
  else
    s := '';
  if (Fowner.FShowHeader) and (FEditSect <> -1) then
    ASection := FHeader.Sections[FEditSect]
  else
    ASection := nil;
  FOwner.DoValidate(FEditingItem, ASection, s, b);
  if (FEditingItem <> nil) and b then
  begin
    if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    begin
      FEditingItem.Text := s;
    end else
    begin
      sn := FEditSect;
      if sn > FOwner.FMainTreeCol then
        dec(sn);
      while FEditingItem.FColText.Count <= sn do
        FEditingItem.FColText.Add('');
      FEditingItem.FColText[sn] := s;
    end;
  end;
{$else}
  ProcessTextEditResults(ByCancel);
{$endif}
{$else}
  ProcessTextEditResults(ByCancel);
{$endif}
end;

procedure TElTreeView.ProcessNumericEditResults(ByCancel : boolean);
begin
  ProcessTextEditResults(ByCancel);
end;

procedure TElTreeView.ProcessTextEditResults(ByCancel : boolean);
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;
begin
    b := not ByCancel;
    if b then
      s := (FInpEdit as EditBoxClass).Text
    else
      s := '';
    (FInpEdit as EditBoxClass).OnExit := nil;
    if (FOwner.FShowHeader) and (FEditSect <> -1) then
       ASection := FHeader.Sections[FEditSect]
    else
       ASection := nil;
    FOwner.DoValidate(FEditingItem, ASection, s, b);
    if (FEditingItem <> nil) and (b) then
    begin
      if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
        FEditingItem.Text := s
      else
      begin
        sn := FEditSect;
        if sn > FOwner.FMainTreeCol then dec(sn);
        while FEditingItem.FColText.Count <= sn do FEditingItem.FColText.Add('');
        FEditingItem.FColText[sn] := s;
      end;
    end;
end;

procedure TElTreeView.ProcessBoolEditResults(ByCancel : boolean);
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;
    
begin
  b := not ByCancel;
  if b then
  begin
    if CheckBoxClass(FInpEdit).Checked then
       S := '1'
    else
       S := '';
  end
  else
    s := '';
  if (FOwner.FShowHeader) and (FEditSect <> -1)
     then ASection := FOwner.FHeader.Sections[FEditSect]
     else ASection := nil;
  FOwner.DoValidate(FEditingItem, ASection, s, b);
  if (FEditingItem <> nil) and b then
  begin
    if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    begin
      FEditingItem.Text := s;
    end else
    begin
      sn := FEditSect;
      if sn > FOwner.FMainTreeCol then
        dec(sn);
      while FEditingItem.FColText.Count <= sn do
        FEditingItem.FColText.Add('');
      FEditingItem.FColText[sn] := s;
    end;
  end;
  CheckBoxClass(FInpEdit).OnExit := nil;
end;

procedure TElTreeView.ProcessCurrencyEditResults(ByCancel : boolean);
{$ifdef ELTREE_USE_EXT_EDITORS}
{$ifdef ELPACK_COMPLETE}
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;
{$endif}
{$endif}
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
  b := not ByCancel;
  if b then
    S := CurrToPrettyStr(TElCurrencyEdit(FInpEdit).Value)
  else
    s := '';
  if (Fowner.FShowHeader) and (FEditSect <> -1) then
    ASection := FHeader.Sections[FEditSect]
  else
    ASection := nil;
  FOwner.DoValidate(FEditingItem, ASection, s, b);
  if (FEditingItem <> nil) and b then
  begin
    if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    begin
      FEditingItem.Text := s;
    end else
    begin
      sn := FEditSect;
      if sn > FOwner.FMainTreeCol then
        dec(sn);
      while FEditingItem.FColText.Count <= sn do
        FEditingItem.FColText.Add('');
      FEditingItem.FColText[sn] := s;
    end;
  end;
  TElCurrencyEdit(FInpEdit).OnExit := nil;
{$else}
  ProcessTextEditResults(ByCancel);
{$endif}
end;

procedure TElTreeView.ProcessDateEditResults(ByCancel : boolean);
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;
begin
  b := not ByCancel;
{$ifdef ELTREE_USE_EXT_EDITORS}
  TElDateTimePicker(FInpEdit).OnExit := nil;
  if b then
    S := DateToStr(TElDateTimePicker(FInpEdit).Date)
  else
{$else}
  TDateTimePicker(FInpEdit).OnExit := nil;
  if b then
    S := DateToStr(TDateTimePicker(FInpEdit).Date)
  else
{$endif}
    s := '';
  if (Fowner.FShowHeader) and (FEditSect <> -1)
     then ASection := FHeader.Sections[FEditSect]
     else ASection := nil;
  FOwner.DoValidate(FEditingItem, ASection, s, b);
  if (FEditingItem <> nil) and b then
  begin
    if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    begin
      FEditingItem.Text := s;
    end else
    begin
      sn := FEditSect;
      if sn > FOwner.FMainTreeCol then
        dec(sn);
      while FEditingItem.FColText.Count <= sn do
        FEditingItem.FColText.Add('');
      FEditingItem.FColText[sn] := s;
    end;
  end;
end;

procedure TElTreeView.ProcessTimeEditResults(ByCancel : boolean);
var b : boolean;
    s : string;
    sn: integer;
    ASection : TElHeaderSection;

begin
  b := not ByCancel;
{$ifdef ELTREE_USE_EXT_EDITORS}
  TElDateTimePicker(FInpEdit).OnExit := nil;
  if b then
    S := TimeToStr(TElDateTimePicker(FInpEdit).Time)
  else
{$else}
  TDateTimePicker(FInpEdit).OnExit := nil;
  if b then
    S := TimeToStr(TDateTimePicker(FInpEdit).Time)
  else
{$endif}
    s := '';

  if (FOwner.FShowHeader) and (FEditSect <> -1)
     then ASection := FHeader.Sections[FEditSect]
     else ASection := nil;

  FOwner.DoValidate(FEditingItem, ASection, s, b);
  if (FEditingItem <> nil) and b then
  begin
    if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    begin
      FEditingItem.Text := s;
    end else
    begin
      sn := FEditSect;
      if sn > FOwner.FMainTreeCol then
        dec(sn);
      while FEditingItem.FColText.Count <= sn do
        FEditingItem.FColText.Add('');
      FEditingItem.FColText[sn] := s;
    end;
  end;
end;

procedure TElTreeView.ProcessEnumEditResults(ByCancel : boolean);
var b: boolean;
    ASection : TElHeaderSection;
begin
  b := not ByCancel;
  if (FEditSect = FOwner.FMainTreeCol) or (FEditSect = -1) then
    ASection := nil
  else
    ASection := FHeader.Sections[FEditSect];
  FOwner.DoValidateCombo(FEditingItem, ASection, TComboBox(FInpEdit), b);
  ComboBoxClass(FInpEdit).OnExit := nil;
end;

procedure TElTreeView.ProcessEditResults(ByCancel : boolean);
begin
  case FEditType of
    sftPicture : ProcessPictureEditResults(ByCancel);
    sftCustom  : ProcessCustomEditResults(ByCancel);
    sftBLOB    : ProcessBlobEditResults(ByCancel);
    sftEnum    : ProcessEnumEditResults(ByCancel);
    sftDate    : ProcessDateEditResults(ByCancel);
    sftTime    : ProcessTimeEditResults(ByCancel);
    sftDateTime: ProcessDateTimeEditResults(ByCancel);
    sftText    : ProcessTextEditResults(ByCancel);
    sftFloating: ProcessFloatEditResults(ByCancel);
    sftNumber  : ProcessNumericEditResults(ByCancel);
    sftBool    : ProcessBoolEditResults(ByCancel);
{$ifdef ELPACK_COMPLETE}
    sftCurrency: ProcessCurrencyEditResults(ByCancel);
{$else}
    sftCurrency: ProcessTextEditResults(ByCancel);
{$endif}
  end;

end;

function TElTreeView.DoEndEdit;
begin
  result := true;
  if FEditing then
    FOwner.HideSelection := FOldHide;
  if (FInpEdit = nil) or (FEditingItem = nil) or (not FInpEdit.Visible) then
  begin
    if assigned(FInpEdit) then
    begin
      FInpEdit.Parent := nil;
      FInpEdit.Free;
      if Assigned(FFakePopup) then FFakePopup.Free;
      FFakePopup := nil;
      FInpEdit := nil;
    end;
    FEditingItem := nil;
    try
      if (not (csDestroying in ComponentState)) and CanFocus then SetFocus;
    except
    end;
    FEditing := false;
    exit;
  end;
  //if not ByCancel then
  ProcessEditResults(ByCancel);

  if FInpEdit <> nil then
    FInpEdit.Visible := false;
  if (FEditingItem <> nil) and (not (csDestroying in ComponentState)) then
  begin
    FEditingItem.RedrawItem(false);
    FOwner.FUpdated := true;
    if not FOwner.IsUpdating then Update;
  end;
  FEditingItem := nil;
  try
    if (not (csDestroying in ComponentState)) and CanFocus then SetFocus;
  except
  end;
  FEditing := false;
end;

procedure TElTreeView.OnEditExit;
begin
  if FEditing then
     DoEndEdit(False);
end;
{$endif}

procedure TElTreeView.DefineHRange;

  procedure CalcWidth(Item: TElTreeItem; {Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; }Tree: TCustomElTree);
  var
    w: integer;

    function GetWidth(Item: TElTreeItem): integer;
    var
      SText: string;
      R3: TRect;
    begin
      SText := Item.FText;
      SetRectEmpty(R3);
      with Tree do
      if (FShowHeader and not OwnerDrawByColumn) or (OwnerDrawMask = SText)
{$ifdef ELTREE_USE_STYLES}
       or
         (Item.UseStyles and (Item.MainStyle.FCellType <> sftText))
{$endif}
      then
      begin
        TriggerMeasureItemPartEvent(Item, -1, R3.BottomRight);
        result := Item.FTextLeft + R3.Right + (ItemExt div 3 + 3);
      end else
      begin
{$IFDEF HAS_HTML_RENDER}
        if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
        begin
          R3.Left := 0;
          R3.Top := 0;
          with FRender do
          begin
            PrepareText(SText, 0, false);
            R3.Right := Data.TextSize.cx;
            R3.Bottom := Data.TextSize.cy;
          end;
        end else
{$ENDIF}
          DrawText(FView.Canvas.Handle, PChar(SText), Length(SText), R3, DT_NOPREFIX or DT_SINGLELINE or DT_CALCRECT);
        result := (R3.Right - R3.Left) + (ItemExt div 3 + 3);
      end;
      with Tree do
      begin
        if (FShowRoot and FShowLines) or FShowButtons then
          inc(Result, ItemExt)
        else
          inc(Result, ItemExt div 5);
        if FShowCheckBoxes and Item.FShowCheckBox then inc(result, ItemExt);
        inc(result, (Item.Level) * ItemExt);
        if (FShowImages) then
        begin
          if (FImages <> nil) then inc(result, FImages.Width);
          inc(result, ItemExt div 3);
          if (FImages2 <> nil) then inc(result, FImages2.Width) else
            if (FImages <> nil) then inc(result, FImages.Width);
        end;
      end;
    end;

  begin
    w := GetWidth(Item);
    if w > FHRange then FHRange := w;
  end;
                                                       
var i, j : integer;
    Item : TElTreeItem;

begin
  FHRange := 0;
  j := FOwner.FAllList.Count;
  i := 0;
  while i < j do
  begin
    Item := TElTreeItem(FOwner.FAllList[i]);
    if (FOwner.FilteredVisibility and Item.Hidden) then
    begin
      i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      CalcWidth(Item, FOwner);
      if not Item.Expanded then
         i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  exit;

  //FItems.Iterate(true, @CalcWidth, nil);
end;

procedure TElTreeView.Paint;
begin
  FPainting := true;
  RedrawTree(Canvas);
  FPainting := false;
end;

procedure TElTreeView.FillDragImage;
var
  ABmp: TBitmap;
  TIL : TImageList;
  i, j: integer;
  b: boolean;
  tt,
    bb: integer;
  R   : TRect;

  procedure IntRedrawItemTree(Index: integer; Surface: TBitmap);
  var
    R: TRect;
    SText: string;
    Item: TElTreeItem;
    R1, R3: TRect;
    //SaveStyle: TFontStyles;
    ImDrawStyle: TDrawingStyle;
    StImIndex: integer;

  begin
    Item := FVisible[index];
    SText := Item.Text;

    with FOwner do
    begin

      R := Self.GetItemRect(index);
      dec(R.Top, FDDY);
      dec(R.Bottom, FDDY);
      if RightAlignedTree then
      begin
        if (FShowRoot and FShowLines) or (FShowButtons and FShowRootButtons) then dec(R.Right, ItemExt);
      end else
      begin
        if (FShowRoot and FShowLines) or (FShowButtons and FShowRootButtons) then Inc(R.Left, ItemExt);
      end;

      if RightAlignedTree then
      begin
        dec(R.Right, Item.Level * ItemExt);
      end else
      begin
        inc(R.Left, Item.Level * ItemExt);
      end;

      if FShowImages then
      begin
        if (FImages <> nil) then
        begin
          ImDrawStyle := FImages.DrawingStyle;
          FImages.DrawingStyle := dsFocus;
          if Item.FState = [] then StImIndex := Item.FImageIndex else StImIndex := Item.FStImageIndex;
          if StImIndex = -1 then
            StImIndex := DoGetPicture(Item);
          if InRange(0, FImages.Count - 1, StImIndex) then
          begin
            if RightAlignedTree then
            begin
              FImages.Draw(Surface.Canvas, R.Right - FImages.Width, (R.Top + (R.Bottom - R.Top + 1) div 2) - (FImages.Height div 2), StImIndex);
              dec(R.Right, FImages.Width);
            end else
            begin
              FImages.Draw(Surface.Canvas, R.Left, (R.Top + (R.Bottom - R.Top + 1) div 2) - (FImages.Height div 2), StImIndex);
              inc(R.Left, FImages.Width);
            end;
          end;
          FImages.DrawingStyle := ImDrawStyle;
        end;
      end; // Show images
      if RightAlignedTree then
      begin
        dec(R.Right, (ItemExt div 3));
      end else
      begin
        inc(R.Left, (ItemExt div 3));
      end;

      if (FODFollowCol and (FHeader.Sections.Count > 0) and (FHeader.Sections[FMainTreeCol].Style = ElhsOwnerDraw))
        or ((not (FODFollowCol)) and (SText = FODMask)) then
      begin
        DoItemDraw(Item, Canvas, R, FMainTreeCol);
      end
      else
      begin
        with Surface.Canvas do
        begin
          if not Item.ParentStyle then
          begin
            with Surface.Canvas.Font do
            begin
              Style := [];
              if Item.Bold then Style := [fsBold];
              if Item.Italic then Style := Style + [fsItalic];
              if Item.Underlined then Style := Style + [fsUnderline];
              if Item.StrikeOut then Style := Style + [fsStrikeOut];
            end;
          end;
        end;
        R1 := R;
        SetRectEmpty(R3);
{$IFDEF HAS_HTML_RENDER}
        if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
        begin
          R3.Left := 0;
          R3.Top := 0;
          with FRender do
          begin
            Data.Charset := Surface.Canvas.Font.Charset;
            PrepareText(SText, 0, false);
            R3.Right := Data.TextSize.cx;
            R3.Bottom := Data.TextSize.cy;
          end;
        end else
{$ENDIF}
          DrawText(Surface.Canvas.Handle, PChar(SText), Length(SText), R3, DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_CALCRECT);
        if RightAlignedTree then
        begin
          R1.Left := R1.Right - (R3.Right - R3.Left);
        end else
        begin
          R1.Right := R1.Left + (R3.Right - R3.Left);
        end;
{$IFDEF HAS_HTML_RENDER}
        if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
        begin
          FRender.Data.DefaultStyle := Surface.Canvas.Font.Style;

          with FRender do
          begin
            //Charset := Surface.Canvas.Font.Charset;
            //PrepareText(SText, 0, false);
            DrawText(Surface.Canvas, Point(0, 0), R1);
          end;
        end else
{$ENDIF}
        //SaveStyle := Surface.Canvas.Font.Style;
        begin
          if RightAlignedText then
          begin
            DrawText(Surface.Canvas.Handle, PChar(SText), Length(SText), R1, DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_VCENTER or DT_RIGHT or DT_RTLREADING);
          end else
          begin
            DrawText(Surface.Canvas.Handle, PChar(SText), Length(SText), R1, DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_VCENTER);
          end;
        end;
        //Surface.Canvas.Font.Style := SaveStyle;
      end; // if ... else
    end;
  end;

  procedure DrawDragImages;
  var
    i: integer;
    R,
      R1: TRect;

  begin
    with FOwner do
    begin
      j := FVisible.Count;
      for i := 0 to j - 1 do
        if (TElTreeItem(FVisible[i]).Selected) then
        begin
          R := Self.GetItemRect(i);
          dec(R.Top, FDDY);
          dec(R.Bottom, FDDY);
          if FHLines then dec(R.Bottom, FDivLineWidth);
          R.Left := 0;
          r1 := r;
          if FShowHeader then
             r1.right := FHeader.Sections[FMainTreeCol].Width
          else
             r1.right := Max(FHRange, FHPos + ClientWidth);
          ABmp.Canvas.Font := Canvas.Font;
          ABmp.Canvas.Font.Color := FTextColor;
          ABmp.Canvas.Pen.Color := FTextColor;
          IntRedrawItemTree(i, ABmp);
        end;
    end;
  end;

begin
  FDragImages := nil;
  if FOwner.DragImageMode = dimNever then exit;
  b := false;
  tt := -1;
  bb := -1;

  with FOwner do
    if DragImageMode = dimOne then
      for i := 0 to FVisible.Count - 1 do
      begin
        if (TElTreeItem(FVisible[i]).Selected) then
        begin
          if b then
          begin
            FDragImages := nil;
            exit;
          end
          else
          begin
            b := true;
            R := Self.GetItemRect(i);
            tt := R.Top;//i * LineHeight;
            bb := R.Bottom;
          end;
        end;
      end
    else
    begin
      for i := 0 to FVisible.Count - 1 do
      begin
        if (TElTreeItem(FVisible[i]).Selected) then
        begin
          R := Self.GetItemRect(i);
          bb := R.Bottom;
          if not b then
          begin
            tt := R.Top;
            b := true;
          end;
        end;
      end;
    end;
  TIL := TImageList.Create(self);
  TIL.Height := bb - tt + 1;
  FDDY := tt;

  with FOwner do
    if FMainTreeCol >= FHeader.Sections.Count then
      FMainTreeCol := 0;
  if FOwner.FShowHeader then
    TIL.Width := FHeader.Sections[FOwner.FMainTreeCol].Width
  else
    TIL.Width := Max(FHRange, FOwner.FHPos + Width);

  ABmp := TBitmap.Create;
  ABmp.Width := TIL.Width;
  ABmp.Height := TIL.Height;
{$IFNDEF VER90}
  ABmp.TransparentMode := tmFixed;
  ABmp.TransparentColor := FOwner.FBkColor;
{$ENDIF}
  ABmp.Canvas.FillRect(Rect(0, 0, ABMP.Width, ABMP.Height));
{$IFNDEF VER90}
  ABmp.Canvas.Lock;
{$ENDIF}
  try
    DrawDragImages;
  finally
{$IFNDEF VER90}
    ABmp.Canvas.UnLock;
{$ENDIF}
  end;
  TIL.AddMasked(ABmp, clDefault);
  FDragImages := TIL;
end;

procedure TElTreeView.DrawImages(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
var
  FTImages : TImageList;
  ImDrawStyle: TDrawingStyle;
  StImIndex: integer;
  h, w     : integer;  
  R2       : TRect;

  procedure DoDrawImage;
  begin
    h := FTImages.Height;
    w := FTImages.Width;

    if FOwner.RightAlignedTree then
      R2 := Rect(Max(R.Left, R.Right - w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), R.Right, R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h)
    else
      R2 := Rect(R.Left, R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), Min(R.Right, R.Left + w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);

    if R2.Right >= R2.Left then
    begin
      HelperBitmap.PixelFormat := pfDevice;

      HelperBitmap.Height := R2.Bottom - R2.Top;
      HelperBitmap.Width  := R2.Right - R2.Left;

      bitblt(HelperBitmap.Canvas.Handle, 0, 0, HelperBitmap.Width, HelperBitmap.Height, ACanvas.Handle, R2.Left, R2.Top, srccopy);

      if FOwner.RightAlignedTree then
         FTImages.Draw(HelperBitmap.Canvas, HelperBitmap.Width - w, 0, StImIndex)
      else
         FTImages.Draw(HelperBitmap.Canvas, 0, 0, StImIndex);

      bitblt(ACanvas.Handle, r2.Left, R2.Top, HelperBitmap.Width, HelperBitmap.Height, HelperBitmap.Canvas.Handle, 0, 0, srccopy);
    end;
    
    if FOwner.RightAlignedTree then dec(R.Right, w) else inc(R.Left, w);
  end;

begin
  if R.Left >= R.Right then exit;

  with FOwner do
  begin
    if FImages2 <> nil then
      FTImages := FImages2
    else
      FTImages := FImages;
    if FTImages <> nil then
    begin
      ImDrawStyle := FTImages.DrawingStyle;
      if FChStateImage then
      begin
        if Item.Selected then
          FTImages.DrawingStyle := dsSelected
        else
        if Item.Focused then
          FTImages.DrawingStyle := dsFocus
        else
          FTImages.DrawingStyle := dsNormal;
      end;
  
      // draw 2nd image
      if (Item.Focused or Item.Selected or Item.Cut or (Item.Expanded and Item.HasVisibleChildren)) then
        StImIndex := Item.FStImageIndex2
      else
        StImIndex := Item.fimageiNdex2;
      if StImIndex = -1 then
         StImIndex := DoGetPicture2(Item);
      if InRange(0, FTImages.Count - 1, StImIndex) then
      begin
        DoDrawImage;
        Item.FImageDrawn2 := true;
      end else
      begin
        if FShowEmptyImages2 then
        begin
          if FOwner.RightAlignedTree then
            dec(R.Right, FTImages.Width) else inc(R.Left, FTImages.Width);
          Item.FImageDrawn2 := true;
        end else
          Item.FImageDrawn2 := false;
      end;
      FTImages.DrawingStyle := ImDrawStyle;
    end;
    if (FImages <> nil) then
    begin
      FTImages := FImages;
      ImDrawStyle := FImages.DrawingStyle;
      if FChStateImage then
      begin
        if Item.Selected then
           FTImages.DrawingStyle := dsSelected
        else
           if Item.Focused then
              FTImages.DrawingStyle := dsFocus
           else
              FTImages.DrawingStyle := dsNormal;
      end;

      if (Item.Focused or Item.Selected or Item.Cut or (Item.Expanded and Item.HasVisibleChildren)) then
        StImIndex := Item.FStImageIndex
      else
        StImIndex := Item.FImageIndex;
      if StImIndex = -1 then
        StImIndex := DoGetPicture(Item);
      if InRange(0, FTImages.Count - 1, StImIndex) then
      begin
        if RightAlignedTree then
        begin
          if Item.FImageDrawn2 then dec(R.Right, ItemExt div 3); // make the space between images
        end else
        begin
          if Item.FImageDrawn2 then inc(R.Left, ItemExt div 3); // make the space between images
        end;
        DoDrawImage;
        Item.FImageDrawn := true;
      end else
        if FShowEmptyImages then
        begin
          if RightAlignedTree then
          begin
            if Item.FImageDrawn2 then dec(R.Right, ItemExt div 3); // make the space between images
          end else
          begin
            if Item.FImageDrawn2 then inc(R.Left, ItemExt div 3); // make the space between images
          end;
          if FOwner.RightAlignedTree then dec(R.Right, FTImages.Width) else inc(R.Left, FTImages.Width);
          Item.FImageDrawn := true;
        end else
          Item.FImageDrawn := false;

      FTImages.DrawingStyle := ImDrawStyle;
    end;
  end;
end;
{$HINTS OFF}
procedure TElTreeView.DrawButtons(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
var FCCanvas : TCanvas;
    FCBitmap : HBitmap;
    R1 : TRect;
    w,
    h  : integer;
    TC : TColor;
begin
  if R.Left >= R.Right then exit;
  with FOwner do
  begin
    if FCustomPlusMinus then
    begin
      w := FPlusPicture.Width;
      h := FPlusPicture.Height;
      
      CenterRects(w, ItemExt, h, R.Bottom - R.Top + 1, R1);

      if not Item.Expanded then
      begin
        FCCanvas := FPlusPicture.Canvas;
        FCBitmap := FPlusPicture.Handle;
        TC := FPlusPicture.Canvas.Pixels[0, h-1];
        FCBitmap := FPlusPicture.Handle;
      end else
      begin
        FCCanvas := FMinusPicture.Canvas;
        FCBitmap := FMinusPicture.Handle;
        TC := FMinusPicture.Canvas.Pixels[0, h-1];
        FCBitmap := FMinusPicture.Handle;
      end;
    end else
    begin
      w := 10;
      CenterRects(w, ItemExt, w, R.Bottom - R.Top + 1, R1);
      if not Item.Expanded then
      begin
        FCCanvas := PlusBmp.Canvas;
        TC := PlusBmp.Canvas.Pixels[0, PlusBmp.Height-1];
        FCBitmap := PlusBmp.Handle;
      end else
      begin
        FCCanvas := MinusBmp.Canvas;
        TC := MinusBmp.Canvas.Pixels[0, MinusBmp.Height-1];
        FCBitmap := MinusBmp.Handle;
      end;
    end;
    if RightAlignedTree then
    begin
      R1 := Rect(max(R.Right - R1.Right, R.Left), R1.Top + R.Top, R.Right - (R1.Right - w), R1.Bottom + R.Top);
      if FOwner.FTransButtons then
         DrawTransparentBitmapEx(ACanvas.Handle, FCBitmap, R1.Left, R1.Top, Rect(w - (R1.Right - R1.Left), 0, w, R1.Bottom - R1.Top), TC)
      else
         BitBlt(ACanvas.Handle, R1.Left, R1.Top, R1.Right - R1.Left + 1, R1.Bottom - R1.Top + 1, FCCanvas.Handle, w - (R1.Right - R1.Left), 0, SRCCOPY);
    end else
    begin
      OffsetRect(R1, R.Left, R.Top);
      if FOwner.FTransButtons then
         DrawTransparentBitmapEx(ACanvas.Handle, FCBitmap, R1.Left, R1.Top,
                                 Rect(0, 0, min(R1.Right - R1.Left + 1, R.Right - R1.Left), R1.Bottom - R1.Top + 1), TC)
      else
         BitBlt(ACanvas.Handle, R1.Left, R1.Top, min(R1.Right - R1.Left + 1, R.Right - R1.Left), R1.Bottom - R1.Top + 1, FCCanvas.Handle, 0, 0, SRCCOPY);
    end;
  end;
end;
{$HINTS ON}
procedure TElTreeView.DrawCheckBoxes(ACanvas : TCanvas; Item : TElTreeItem; HelperBitmap : TBitmap; var R : TRect; var ItemRect : TRect);
var
  cbh,
  cbw,
  i    : integer;
  R2,
  R3   : TRect;
 ADC   : HDC;
 HObj  : HGDIObj;

begin
  with FOwner do
  begin
    if Item.FShowCheckBox then
    begin
      cbw := 0;
      try
        if RightAlignedTree then
          dec(R.Right, 2)
        else
          inc(R.Left, 2);

        if FCustomCheckboxes then
        begin
          if Item.FCheckBoxType = ectRadioButton then
          begin
            cbh := FRadioButtonGlyph.Height;
            cbw := FRadioButtonGlyph.Width div 6;

            if not Item.Checked then
            begin
              if Item.CheckBoxEnabled then R3 := Rect(0, 0, cbw, cbh)
              else R3 := Rect(cbw, 0, cbw * 2, cbh);
            end else
            begin
              if Item.CheckBoxEnabled then R3 := Rect(cbw * 2, 0, cbw * 3, cbh)
              else R3 := Rect(cbw * 3, 0, cbw * 6, cbh);
            end;
          end else
          if Item.FCheckBoxType = ectCheckBox then
          begin
            cbh := FCheckBoxGlyph.Height;
            cbw := FCheckBoxGlyph.Width div 6;

            if not Item.Checked then
            begin
              if Item.CheckBoxEnabled then R3 := Rect(0, 0, cbw, cbh)
              else R3 := Rect(cbw, 0, cbw * 2, cbh);
            end else
            begin
              if Item.CheckBoxEnabled then R3 := Rect(cbw * 2, 0, cbw * 3, cbh)
              else R3 := Rect(cbw * 3, 0, cbw * 4, cbh);
            end;
          end else
          begin
            cbh := FCheckBoxGlyph.Height;
            cbw := FCheckBoxGlyph.Width div 6;

            case Item.CheckBoxState of
              cbUnchecked:
                if Item.CheckBoxEnabled then R3 := Rect(0, 0, cbw, cbh)
                else R3 := Rect(cbw, 0, cbw * 2, cbh);
              cbChecked:
                if Item.CheckBoxEnabled then R3 := Rect(cbw * 2, 0, cbw * 3, cbh)
                else R3 := Rect(cbw * 3, 0, cbw * 4, cbh);
              cbGrayed:
                if Item.CheckBoxEnabled then R3 := Rect(cbw * 4, 0, cbw * 5, cbh)
                else R3 := Rect(cbw * 5, 0, cbw * 6, cbh);
            end;
          end;
          if RightAlignedTree then
          begin
            R2 := Rect(R.Right - cbw + 1, R.Top + ((R.Bottom - R.Top + 1) div 2) - cbh div 2, R.Right, R.Top + ((R.Bottom - R.Top + 1) div 2) + cbw div 2);
  
            if R.Left >= R2.Right then exit;
            if R.Left >= R.Right - cbw then
            begin
              R2.Left := R.Left;
              R3.Left := r3.Right - (R.Right - R.Left + 1);
              HelperBitmap.Width := R.Right - R2.Left;
            end
            else
              HelperBitmap.Width := cbw;
          end
          else
          begin
            R2 := Rect(R.Left, R.Top + ((R.Bottom - R.Top + 1) div 2) - cbh div 2, R.Left + cbw, R.Top + ((R.Bottom - R.Top + 1) div 2) + cbw div 2);

            if R2.Left >= R.Right then exit;
            if R2.Left + cbw >= R.Right then
            begin
              R2.Right := R.Right;
              R3.Right := R3.Left + (R.Right - R.Left + 1);
              HelperBitmap.Width := R.Right - R.Left + 1;
            end
            else
              HelperBitmap.Width := cbw;
          end;
          HelperBitmap.Height := R2.Bottom - R2.Top + 1;

          bitblt(HelperBitmap.Canvas.Handle, 0, 0, HelperBitmap.Width, HelperBitmap.Height, ACanvas.Handle, r2.Left, R2.Top, srccopy);

          if Item.FCheckBoxType = ectRadioButton then
          begin
            FRadioButtonGlyph.Pixelformat := pfDevice;
            DrawTransparentBitmapEx(HelperBitmap.Canvas.Handle, FRadioButtonGlyph.Handle, 0, 0, R3, FRadioButtonGlyph.traNsparentcolor);
          end
          else
          begin
            FCheckBoxGlyph.Pixelformat := pfDevice;
            DrawTransparentBitmapEx(HelperBitmap.Canvas.Handle, FCheckBoxGlyph.Handle, 0, 0, R3, FCheckBoxGlyph.TransparentColor);
          end;

          bitblt(ACanvas.Handle, r2.Left, R2.Top, HelperBitmap.Width, HelperBitmap.Height, HelperBitmap.Canvas.Handle, 0, 0, srccopy);
        end
        else
        begin
          cbw := ItemExt - 2;
          //cbh := ItemExt - 2;
          i := DFCS_BUTTONCHECK or DFCS_CHECKED;
          if Item.FCheckBoxType = ectRadioButton then
          begin
            if Item.Checked then i := DFCS_BUTTONRADIO or DFCS_CHECKED
            else i := DFCS_BUTTONRADIO;
          end else
            if Item.FCheckBoxType = ectCheckBox then
            begin
              if Item.Checked then i := DFCS_BUTTONCHECK or DFCS_CHECKED
              else i := DFCS_BUTTONCHECK;
            end else
            begin
              case Item.FCheckBoxState of //
                cbChecked: i := DFCS_BUTTONCHECK or DFCS_CHECKED;
                cbUnchecked: i := DFCS_BUTTONCHECK;
                cbGrayed: i := DFCS_BUTTON3STATE or DFCS_CHECKED;
              end; // case
            end;
          if not Item.FCheckBoxEnabled then i := i or DFCS_INACTIVE;

          if RightAlignedTree then
          begin
            R2 := Rect(Max(R.Left, R.Right - (cbw - 2)), R.Top + ((R.Bottom - R.Top + 1) div 2) - ((ItemExt - 2) div 2 - 1), R.Right, R.Top + ((R.Bottom - R.Top + 1) div 2) + (ItemExt - 2) div 2);

            R3 := Rect(0, 0, cbw -2, cbw -2);
            if R.Left >= R2.Right then exit;
            if R.Left >= R.Right - cbw then
            begin
              R2.Left := R.Left;
              OffsetRect(R3, -(R.Left - (R.Right - cbw)), 0);
              HelperBitmap.Width := R.Right - R2.Left;
            end else HelperBitmap.Width := cbw;
          end else
          begin
            R2 := Rect(R.Left, R.Top + ((R.Bottom - R.Top + 1) div 2) - ((ItemExt - 2) div 2 - 1), Min(R.Right, R.Left + (ItemExt - 2)), R.Top + ((R.Bottom - R.Top + 1) div 2) + (ItemExt - 2) div 2);

            R3 := Rect(0, 0, cbw - 2, cbw -2);
            if R2.Left >= R.Right then exit;
            if R2.Left + cbw >= R.Right then
            begin
              R2.Right := R.Right;
              HelperBitmap.Width := R.Right - R2.Left;
            end else HelperBitmap.Width := cbw;
          end;
          HelperBitmap.Height := cbw - 1;

{Soulsnake Add}
          if Item.FUseCheckBoxColor then
          begin
            ACanvas.Brush.Color := Item.FCheckBoxColor;
            R3.Left := R3.Left + R2.Left;
            R3.Right := R3.Right + R2.Left;
            R3.Top := R3.Top + R2.Top;
            R3.Bottom := R3.Bottom + R2.Top;
            ACanvas.Rectangle(R3);
            if Item.FCheckBoxState = cbChecked then
            begin
              ACanvas.Brush.Color := Item.FCheckColor;
              R3.Left := R3.Left + 4;
              R3.Right := R3.Right - 4;
              R3.Top := R3.Top + 4;
              R3.Bottom := R3.Bottom - 4;
              //ACanvas.Ellipse(R3);
              ACanvas.Rectangle(R3);
            end;
          end else
{End Soulsnake Add}
          begin
            ADC := CreateCompatibleDC(ACanvas.Handle);
            HObj := SelectObject(ADC, HelperBitmap.Handle);

            bitblt(ADC, 0, 0, HelperBitmap.Width, HelperBitmap.Height, ACanvas.Handle, r2.Left, R2.Top, srccopy);

            DrawFrameControl(ADC, R3, DFC_BUTTON, i);

            bitblt(ACanvas.Handle, r2.Left, R2.Top, HelperBitmap.Width, HelperBitmap.Height, ADC, 0, 0, srccopy);
            SelectObject(ADC, HObj);
            DeleteDC(ADC);
          end;

        end;
      finally
        if RightAlignedTree then
           dec(R.Right, cbw)
        else
           inc(R.Left, cbw);
      end;
    end;
  end;
end;

procedure TElTreeView.DrawItemLines(ACanvas : TCanvas; Item : TElTreeItem; var R : TRect; var ItemRect : TRect);

var
  Stack : TElStack;
  //ItemRoot,
  TSI,
    TSI1: TElTreeItem;
  SavePen    : TPenStyle;
  SavePenCol : TColor;

function GetPrevVisChild(Parent, Item: TElTreeItem; NoRoot : boolean): TElTreeItem;
  begin
    if NoRoot and (Item.FParent = FItems.FRoot) then
    begin
      result := nil;
      exit;
    end;
    Result := Parent.GetPrevChild(Item);
    if FOwner.FilteredVisibility then
      while Assigned(Result) and (Result.Hidden) do Result := Parent.GetPrevChild(Result);
  end;

  function GetNextVisChild(Parent, Item: TElTreeItem; NoRoot : boolean): TElTreeItem;
  begin
    if NoRoot and (Item.FParent = FItems.FRoot) then
    begin
      Result := nil;
      exit;
    end;
    Result := Parent.GetNextChild(Item);
    if FOwner.FilteredVisibility then
      while Assigned(Result) and (Result.Hidden) do Result := Parent.GetNextChild(Result);
  end;

  procedure DrawLine(Canvas : TCanvas; StartX, StartY, EndX, EndY : integer);
  var
    Coord: Integer;
    // CRef: COLORREF;
    // DC: HDC;
  begin
    if FOwner.LinesStyle = psDot then
    begin
      // CRef := ColorToRGB(Canvas.Pen.Color);
      // skip a pixel if not in grid
      Coord := (StartX and 1) xor (StartY and 1);
      if StartX = EndX then
      begin
        // draw vertical line
        Inc(Coord, StartY);
        // DC := Canvas.Handle;
        while Coord < EndY do
        begin
          Canvas.MoveTo(StartX, Coord);
          Inc(Coord, 1);
          Canvas.LineTo(StartX, Coord);
          Inc(Coord, 1);
          (*
          SetPixel(DC, StartX, Coord, CRef);
          Inc(Coord, 2);
          *)
        end;
      end
      else
      begin
        // draw horizontal line
        Inc(Coord, StartX);
        //DC := Canvas.Handle;
        while Coord < EndX do
        begin
          Canvas.MoveTo(Coord, StartY);
          Inc(Coord, 1);
          Canvas.LineTo(Coord, StartY);
          Inc(Coord, 1);
          (*
          SetPixel(DC, Coord, StartY, CRef);
          Inc(Coord, 2);
          *)
        end;
      end;
    end
    else
    begin
      Canvas.MoveTo(StartX, StartY);
      Canvas.LineTo(EndX, EndY);

      {MoveToEx(Canvas.Handle, StartX, StartY, nil);
      LineTo(Canvas.Handle, EndX, EndY);}
    end;
  end;

  function GetNextNotLineSuppressedSibling(Item: TElTreeItem): TElTreeItem;
  var
    NextSibling: TElTreeItem;
  begin
    Result := nil;

    NextSibling := Item.GetNextSibling;
    while (NextSibling <> nil) and (Result = nil) do begin
      if not NextSibling.SuppressLines then Result := NextSibling;

      NextSibling := NextSibling.GetNextSibling;
    end;
  end;

begin
  inc(R.Bottom);
  try
    with FOwner do
    begin
      Stack := TElStack.Create;
      TSI := Item.Parent;
      SavePen := ACanvas.Pen.Style;
      SavePenCol := ACanvas.Pen.Color;
      ACanvas.Pen.Style := LinesStyle;
      ACanvas.Pen.Color := LinesColor;
      while TSI <> nil do
      begin
        Stack.Push(TSI);
        TSI := TSI.Parent;
      end;
      //DC := ACanvas.Handle;

      if Item.Parent <> nil then
      begin
        TSI := Item;
        while TSI.Parent <> nil do TSI := TSI.Parent;
        if ShowRoot and (GetNextVisChild(TSI.FParent, TSI, false) <> nil) then
        begin
          if RightAlignedTree then
          begin
            Inc(R.Right, ItemExt);
            if (R.Right - (ItemExt div 2 {+ 4}) > R.Left) then
              DrawLine(ACanvas, R.Right - (ItemExt div 2 {+ 4}), R.Top{ + ((R.Bottom - R.Top + 1) div 2)}, R.Right - (ItemExt div 2 {+ 4}), R.Top + (R.Bottom - R.Top + 1));
            Dec(R.Right, ItemExt);
          end else
          begin
            Dec(R.Left, ItemExt);
            if (R.Left + (ItemExt div 2 {- 4}) < R.Right) then
              DrawLine(ACanvas, R.Left + (ItemExt div 2 {- 4}), R.Top, R.Left + (ItemExt div 2 {- 4}), R.Top + (R.Bottom - R.Top + 1));
            Inc(R.Left, ItemExt);
          end;
        end;
      end;

      if Stack.Count > 0 then
      begin
        TSI := TElTreeItem(Stack.Pop);
        while Stack.Count > 0 do
        begin
          TSI1 := TSI;

          if Stack.Count > 0 then
          begin
            TSI := TElTreeItem(Stack.Pop);

            if (GetNextVisChild(TSI1, TSI, true) <> nil) and ((R.Left + ItemExt div 2) < R.Right) and
               (GetNextNotLineSuppressedSibling(TSI) <> nil) then
              if RightAlignedTree then
              begin
                if (GetNextVisChild(TSI1, TSI, true) <> nil) and ((R.Right - ItemExt div 2) > R.Left) then
                  DrawLine(ACanvas, R.Right - ItemExt div 2, R.Top, R.Right - ItemExt div 2, ItemRect.Bottom + 1);
              end
              else
              begin
                if (GetNextVisChild(TSI1, TSI, true) <> nil) and ((R.Left + ItemExt div 2) < R.Right) then
                  DrawLine(ACanvas, R.Left + ItemExt div 2, R.Top,  R.Left + ItemExt div 2, ItemRect.Bottom + 1);
              end;
          end;
          if RightAlignedTree then
            dec(R.Right, ItemExt)
          else
            inc(R.Left, ItemExt);
        end;
        if RightAlignedTree then
          dec(R.Right, ItemExt)
        else
          inc(R.Left, ItemExt);
      end;
      Stack.Free;

      if (Item.FParent <> Item.FRoot) then
      begin
        if RightAlignedTree then
        begin
          inc(R.Right, ItemExt);
          if ((R.Right - ItemExt div 2) > R.Left) then
          begin
            DrawLine(ACanvas, R.Right - ItemExt div 2, R.Top, R.Right - ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2));
            if not Item.SuppressLines then
              DrawLine(ACanvas, R.Right - ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2), Max(R.Right - ItemExt, R.Left), R.Top + ((R.Bottom - R.Top + 1) div 2));
          end;
        end else
        begin
          dec(R.Left, ItemExt);
          if ((R.Left + ItemExt div 2) < R.Right) then
          begin
            if not Item.SuppressLines or (GetNextNotLineSuppressedSibling(Item) <> nil) then
              DrawLine(ACanvas, R.Left + ItemExt div 2, R.Top, R.Left + ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2));
            if not Item.SuppressLines then
              DrawLine(ACanvas, R.Left + ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2), Min(R.Left + ItemExt, R.Right), R.Top + ((R.Bottom - R.Top + 1) div 2));
          end;
        end;

        if (GetNextVisChild(Item.Parent, Item, true) <> nil) and
           (GetNextNotLineSuppressedSibling(Item) <> nil) then
        begin
          if RightAlignedTree then
          begin
            if ((R.Right - ItemExt div 2) > R.Left) then
              DrawLine(ACanvas, R.Right - ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2), R.Right - ItemExt div 2, R.Bottom + 1);
          end else
          begin
            if ((R.Left + ItemExt div 2) < R.Right) then
              DrawLine(ACanvas, R.Left + ItemExt div 2, R.Top + ((R.Bottom - R.Top + 1) div 2), R.Left + ItemExt div 2, R.Bottom + 1);
          end;
        end; //if
      end // if
      else
      begin
        if RightAlignedTree then
          inc(R.Right, ItemExt)
        else
          dec(R.Left, ItemExt);

        if FShowRoot then
        begin
          if RightAlignedTree then
          begin
            if (R.Right - (ItemExt div 2{ + 4}) > R.Left) then
            begin
              if not Item.SuppressLines then
                DrawLine(ACanvas, R.Right - (ItemExt div 2{ + 4}), R.Top + ((R.Bottom - R.Top + 1) div 2), Max(R.Right - ItemExt, R.Left), R.Top + ((R.Bottom - R.Top + 1) div 2));
              if GetPrevVisChild(Item.FParent, Item, false) <> nil then
                DrawLine(ACanvas, R.Right - (ItemExt div 2 {+ 4}), R.Top, R.Right - (ItemExt div 2 {+ 4}), R.Top + ((R.Bottom - R.Top + 1) div 2));
              if not Item.SuppressLines then
                if GetNextVisChild(Item.FParent, Item, false) <> nil then
                   DrawLine(ACanvas, R.Right - (ItemExt div 2 {+ 4}), R.Top + ((R.Bottom - R.Top + 1) div 2), R.Right - (ItemExt div 2 {+ 4}), R.Top + (R.Bottom - R.Top + 1));
            end;
          end else
          begin
            if (R.Left + (ItemExt div 2 {- 4}) < R.Right) then
            begin
              if not Item.SuppressLines then
                DrawLine(ACanvas, R.Left + (ItemExt div 2 {- 4}), R.Top + ((R.Bottom - R.Top + 1) div 2), Min(R.Left + ItemExt, R.Right), R.Top + ((R.Bottom - R.Top + 1) div 2));
              if GetPrevVisChild(Item.FParent, Item, false) <> nil then
                DrawLine(ACanvas, R.Left + (ItemExt div 2 {- 4}), R.Top, R.Left + (ItemExt div 2 {- 4}), R.Top + ((R.Bottom - R.Top + 1) div 2));
              if (GetNextVisChild(Item.FParent, Item, false) <> nil) then
                if not Item.SuppressLines then
                  DrawLine(ACanvas, R.Left + (ItemExt div 2 {- 4}), R.Top + ((R.Bottom - R.Top + 1) div 2), R.Left + (ItemExt div 2 {- 4}), R.Top + (R.Bottom - R.Top + 1));
            end;
          end;
        end;
      end;
      ACanvas.Pen.Style := SavePen;
      ACanvas.Pen.Color := SavePenCol;
    end;
  finally
    dec(R.Bottom);
  end;
end;

{.$HINTS OFF}
procedure TElTreeView.DoRedrawItemTree;
var
  SText: string;
  R, R1,
{$ifdef ELTREE_USE_STYLES}
  R2,
{$endif}
  R3: TRect;
{$IFNDEF PaintBackground}
  BgRect,
  BgRect1,
  BgRect2,
  BgRect4    : TRect;
{$ENDIF}
  AL, VAL    : integer;
{$ifdef ELTREE_USE_STYLES}
  W,
  H     : integer;
  CurStyle : TElCellStyle;
{$endif}
  xxx      : TFontStyles;
{$IFNDEF PaintBackground}
  Blend    : boolean;
{$ENDIF}
  TransBk  : boolean;
  OwnBk    : boolean;
  xOffs    : integer;
  HelperBmp: TBitmap;
{$IFDEF HAS_HTML_RENDER}
  FData    : TElHTMLData;
{$ENDIF}

begin
  OwnBk := FOverColors;
  TransBk := false;
  HelperBmp := TBitmap.Create;
{$IFNDEF PaintBackground}
  Blend := false;
{$ENDIF}
  SText := Item.Text;
  xOffs := 0;

  with FOwner do
  begin
    if FShowHeader then
    begin
      R := Rect(FHeader.Sections[FMainTreeCol].Left - FHPos - xOffs, ItemRect.Top, FHeader.Sections[FOwner.FMainTreeCol].Right - FHPos  - xOffs, ItemRect.Bottom);

      if FVLines and (not FBarStyle) then Dec(R.Right, FDivLineWidth);
    end
    else
      R := Rect(SurfRect.Left - FHPos - xOffs, ItemRect.Top, SurfRect.Right - FHPos - xOffs, ItemRect.Bottom);
    //if not FHLines then
         //inc(R.Bottom, FDivLineWidth);

{$ifdef ELTREE_USE_STYLES}
    if Item.FUseStyles then
    begin
      CurStyle := Item.FMainStyle;
      if FOverColors or CurStyle.FOwnerProps then
      begin
        ACanvas.Brush.Color := FCurBkColor;
        ACanvas.Font.Color := FCurTextColor;
        OwnBk := true;
      end
      else
      begin
        ACanvas.Brush.Color := CurStyle.FCellBkColor;
        if FOverColors then
          OwnBk := false
        else
          OwnBk := CurStyle.UseBkColor;
      end;
{$IFNDEF PaintBackground}
      Blend := true;
{$ENDIF}
    end else
{$endif}
    begin
      ACanvas.Brush.Color := FCurBkColor;
      ACanvas.Font.Color := FCurTextColor;
    end;
    if Item.Selected and (not FBarStyle) and (((FSelectColumn = FMainTreeCol) and (FShowHeader)) or FRowSelect) then
    begin
      if (((GetParentForm(self) <> nil) and (GetParentForm(self).ActiveControl = self)) or (not FHideSelect)) then
        ACanvas.Brush.Color := FFocusedSelectColor
      else
        ACanvas.Brush.Color := FHideSelectColor;
      OwnBk := true;
{$IFNDEF PaintBackground}
      Blend := true;
{$ENDIF}
    end;
    if (Item = FDropTrg) and (FDragTrgDrawMode <> dtdNone)
       and (((FSelectColumn = FMainTreeCol) and (FShowHeader)) or FRowSelect) then
    begin
      case FDragTrgDrawMode of
        ColorRect:
          begin
            if FDropAcc then
              ACanvas.Brush.Color := FOwner.FDragRectAcceptColor
            else
              ACanvas.Brush.Color := FOwner.FDragRectDenyColor;
          end;
        SelColorRect:
          ACanvas.Brush.Color := clHighlight;
      end; // case
{$IFNDEF PaintBackground}
      Blend := true;
{$ENDIF}
      OwnBk := true;
    end;
    // now fill the background
    //if (not FHLines) or FBarStyle then
    inc(R.Bottom);

    if OwnBk then
    begin
      ACanvas.FillRect(R);
    end;
    //if (not FHLines) or FBarStyle then dec(R.Bottom);

    if RightAlignedTree then
    begin
      if (FShowRoot and FShowLines) or (FShowButtons and FShowRootButtons) then
        dec(R.Right, ItemExt)
      else
        dec(R.Right, ItemExt div 5);
    end else
    begin
      if (FShowRoot and FShowLines) or (FShowButtons and FShowRootButtons) then
        Inc(R.Left, ItemExt)
      else
        Inc(R.Left, ItemExt div 5);
    end;

    // draw tree and images
    if (FShowLines) and (not Item.SuppressLines) then
      DrawItemLines(ACanvas, Item, r, ItemRect)
    else
    begin
      if RightAlignedTree then
        dec(R.Right, (Item.Level - 1) * ItemExt)
      else
        inc(R.Left, (Item.Level - 1) * ItemExt);
    end;

    if Item.Ancestor.SuppressButtons then
    begin //Eyal
      if RightAlignedTree then
      begin
        inc(R.Right, ItemExt);
      end else
      begin
        dec(R.Left, ItemExt);
      end;
    end;

    if FShowButtons and ((Item.HasVisibleChildren) or Item.ForceButtons) and
       (not Item.SuppressButtons) and (FShowRootButtons or (Item.FParent <> Items.FRoot)) then DrawButtons(ACanvas, Item, helpeRbmp, R, ItemRect);

    if RightAlignedTree then
      dec(R.Right, ItemExt)
    else
      inc(R.Left, ItemExt);

    if FShowCheckBoxes then
      DrawCheckBoxes(ACanvas, Item, HelperBmp, R, ItemRect);

    Item.FImageDrawn := false;
    Item.FImageDrawn2 := false;

    if (FShowImages) then
      DrawImages(ACanvas, Item, HelperBmp, R, ItemRect);

{$WARNINGS off}
    if (FODFollowCol and (FHeader.Sections.Count > 0) and (FHeader.Sections[FMainTreeCol].Style = ElhsOwnerDraw))
      or ((SText = FODMask) and (not (FODFollowCol)))
{$ifdef ELTREE_USE_STYLES}
      or (Item.FUseStyles and (Item.FMainStyle.FStyle = elhsOwnerDraw))
{$endif}
      then
    begin
      DoItemDraw(Item, ACanvas, R, FMainTreeCol);
      if RightAlignedTree then
      begin
        dec(R.Right, ItemExt div 3);
        R1 := R;
        Item.FTextLeft := R1.Left + FHPos - xOffs;
        Item.FTextRight := R1.Right + FHPos - xOffs;
        inc(R1.Right);
      end else
      begin
        inc(R.Left, ItemExt div 3);
        R1 := R;
        Item.FTextLeft := R1.Left + FHPos + xOffs;
        Item.FTextRight := R1.Right + FHPos + xOffs;
        dec(R1.Left);
      end;
    end else
    begin
      // make the empty space, that relates to the text
      if RightAlignedTree then
         dec(R.Right, ItemExt div 3)
      else
         inc(R.Left, ItemExt div 3);
{$ifdef ELTREE_USE_STYLES}
      if (Item.UseStyles and (CurStyle.FStyle = elhsText)) or
      (not Item.FUseStyles) then
{$endif}
      begin
        xxx := [];
{$ifdef ELTREE_USE_STYLES}
        if Item.FUseStyles then
        begin
          AL := CurStyle.FTextFlags;
          if FOverColors or CurStyle.FOwnerProps then
          begin
            ACanvas.Font.Color := FCurTextColor;
            ACanvas.Brush.Color := FCurBkColor;
            TransBk := false;
          end else
          begin
            ACanvas.Brush.Color := CurStyle.FTextBkColor;
            ACanvas.Font.Color := CurStyle.FTextColor;
            if not CurStyle.UseBkColor then
              TransBk := true; 
{$IFNDEF PaintBackground}
            Blend := true;
{$ENDIF}
          end;
          if not CurStyle.FOwnerProps then with CurStyle do
          begin
            //if ACanvas.Font.Name <> FontName then
            ACanvas.Font.Name := FontName;
            xxx := FontStyles; //if ACanvas.Font.Style <> FontStyles then
            //if ACanvas.Font.Size <> FontSize then
            ACanvas.Font.Size := FontSize;
          end
          else
          begin
            if ACanvas.Font.Name <> Font.Name then ACanvas.Font.Name := Font.Name;
            if Item.FParentStyle then xxx := Font.Style else
            begin
              if stsBold in Item.FState then Include(xxx, fsBold);
              if stsItalic in Item.FState then Include(xxx, fsItalic);
              if stsUnderlined in Item.FState then Include(xxx, fsUnderline);
              if stsStrikeOut in Item.FState then Include(xxx, fsStrikeout);
            end;
            //if ACanvas.Font.Size <> Font.Size then
              ACanvas.Font.Size := Font.Size;

            Al := DT_LEFT;
            if Assigned(FHeader) and (FShowHeader) and (FHeader.Sections.Count > FMainTreeCol) then
              case FHeader.Sections[FMainTreeCol].Alignment of
                hsaCenter: Al := DT_CENTER;
                hsaRight: Al := DT_RIGHT;
              end; // case
            AL := DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}AL or {$IFNDEF LITE}MultiLineEllipseFlags[Item.Multiline]{$ELSE}DT_END_ELLIPSIS{$ENDIF};
          end;
        end else
{$endif ELTREE_USE_STYLES}
        begin
          ACanvas.Font.Color := FCurTextColor;
          ACanvas.Brush.Color := FCurBkColor;
          if ACanvas.Font.Name <> Font.Name then ACanvas.Font.Name := Font.Name;
          if Item.FParentStyle then xxx := Font.Style else
          begin
            if stsBold in Item.FState then Include(xxx, fsBold);
            if stsItalic in Item.FState then Include(xxx, fsItalic);
            if stsUnderlined in Item.FState then Include(xxx, fsUnderline);
            if stsStrikeOut in Item.FState then Include(xxx, fsStrikeout);
          end;
          if not Item.FParentColors then
          begin
            ACanvas.Font.Color := Item.Color;
            if Item.FUseBkColor then
              ACanvas.Brush.Color := Item.BkColor
            else
               TransBk := true;
            OwnBk := (not FOverColors) or FRowOvColors;
          end;
          if ACanvas.Font.Size <> Font.Size then
            ACanvas.Font.Size := Font.Size;

          if FRightAlignedText then
            Al := DT_RIGHT
          else
            Al := DT_LEFT;

          AL := DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}AL or {$IFNDEF LITE}MultiLineEllipseFlags[Item.Multiline]{$ELSE}DT_END_ELLIPSIS{$ENDIF};
          if RightAlignedText then AL := AL or DT_RTLREADING;
        end;
        if (FTracking and (Item = FTrackItem)) and FUnderlineTracked then Include(xxx, fsUnderline);
        ACanvas.Font.Style := xxx;
        if Item.Selected and (not FBarStyle) and ((FSelectColumn = -1) or (FSelectColumn = FMainTreeCol) or FRowSelect or (not FShowHeader)) then
        begin
          if (((GetParentForm(self) <> nil) and (GetParentForm(self).ActiveControl = self)) or (not FHideSelect)) then
          begin
            ACanvas.Brush.Color := FFocusedSelectColor;
            ACanvas.Font.Color := FFocusedSelectTextColor;
            TransBk := false;
          end else
          begin
            ACanvas.Brush.Color := FHideSelectColor;
            ACanvas.Font.Color := FHideSelectTextColor;
          end;
{$IFNDEF PaintBackground}
          Blend := true;
{$ENDIF}
          OwnBk := true;
        end;
        if (FTracking and (Item = FTrackItem)) then
           if Item.Selected and (FRowSelect or (FSelectColumn = -1) or
             (FShowHeader and (FMainTreeCol = FSelectColumn))) then
             begin
               ACanvas.Brush.Color := FFocusedSelectColor;
               ACanvas.Font.Color := FFocusedSelectTextColor;
             end
{Soulsnake fix}
           else if FOwner.TrackColor <> clNone then
{End Soulsnake fix}
              ACanvas.Font.Color := FOwner.TrackColor;

        if (Item = FDropTrg)
           and (FDragTrgDrawMode <> dtdNone)
           and ((FSelectColumn = -1)
             or (FSelectColumn = FMainTreeCol)
             or FRowSelect
             or (not FShowHeader)) then
        begin
          case FDragTrgDrawMode of
            ColorRect:
              begin
                if FDropAcc then
                  ACanvas.Brush.Color := FDragRectAcceptColor
                else
                  ACanvas.Brush.Color := FDragRectDenyColor;
                ACanvas.Font.Color := clBtnText;
              end;
            SelColorRect:
              begin
                ACanvas.Brush.Color := clHighlight;
                ACanvas.Font.Color := clHighlightText;
              end;
          end; // case
{$IFNDEF PaintBackground}
          Blend := true;
{$ENDIF}
          OwnBk := true;
        end;

        SetRectEmpty(R3);
        ACanvas.Font.Charset := Font.Charset;
{$IFDEF HAS_HTML_RENDER}
        if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
        begin
          R3.Left := 0;
          R3.Top := 0;

          FData := Item.FHTMLData;
          if FData = nil then
          begin
            R3.Right := 0;
            R3.Bottom := 0;
          end else
          begin
            R3.Right := FData.TextSize.cx;
            R3.Bottom := FData.TextSize.cy;
          end;

          {with FRender do
          begin
            Data.DefaultStyle := ACanvas.Font.Style;
            Data.DefaultFont  := ACanvas.Font.Name;
            Data.DefaultColor := ACanvas.Font.Color;
            Data.DefaultSize  := ACanvas.Font.Size;
            Data.Charset      := ACanvas.Font.Charset;

            PrepareText(SText, 0, false);
            R3.Right := Data.TextSize.cx;
            R3.Bottom := Data.TextSize.cy;
          end;}
          
        end else
{$ENDIF}
          DrawText(ACanvas.Handle, PChar(SText), Length(SText), R3, DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF} DT_LEFT or DT_CALCRECT);
        //InflateRect(R, 2, 0);

        if RightAlignedTree then
        begin
          R1 := R;
          inc(R1.Right, 2);
          R1.Left := Max(R1.Left, R1.Right - ((R3.Right - R3.Left + 1) + 4) + FDivLineWidth);
        end else
        begin
          R1 := R;
          dec(R1.Left);
          R1.Right := Min(R1.Left + (R3.Right - R3.Left + 1) + 4 - FDivLineWidth, R.Right);
        end;
        //InflateRect(R1, -1, -1);
        if R1.Left < R1.Right then
        begin
          if OwnBk and (not TransBk) then
          begin
            //ACanvas.Pen.Style := psClear;
            ACanvas.FillRect(R1);
          end;

          if RightAlignedTree then
            dec(R1.Right)
          else
            inc(R1.Left);
          ACanvas.Brush.Style := bsClear;
            VAL := DT_VCENTER;

{$IFDEF HAS_HTML_RENDER}
          if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
          begin
            FData := Item.FHTMLData;
          
            if FData <> nil then
            begin
              if RightAlignedText then
              begin
                R3.Left := R1.Right - Min(R1.Right - R.Left, R3.Right - R3.Left);
                R3.Right := R1.Right;
              end else
              begin
                R3.Right := Min(R1.Right - R.Left, R3.Right - R3.Left) + R1.Left;
                R3.Left := R1.Left;
              end;
              if (VAL and DT_BOTTOM) = DT_BOTTOM then
              begin
                OffsetRect(R3, 0, R1.Top + (R1.Bottom - r1.Top) - (R3.Bottom - R3.Top));
              end else
              if (VAL and DT_VCENTER) = DT_VCENTER then
              begin
                OffsetRect(R3, 0, R1.Top + (((R1.Bottom - r1.Top) - (R3.Bottom - R3.Top)) div 2) - 1);
              end else
              begin
                OffsetRect(R3, 0, R1.Top);
              end;
              with FRender do
              begin
                //PrepareText(SText, 0, false);
                SetData(FData);
                DrawTextEx(ACanvas, Point(0, 0), R3, true, ACanvas.Font.Color, FData.DefaultBgColor, FData.HighlightColor, FData.HighlightBgColor);
                SetData(nil);
              end;
            end;
          end else
{$ENDIF}
            DrawText(ACanvas.Handle, PChar(SText), Length(SText), R1, VAL or DT_NOPREFIX or AL or DT_EXTERNALLEADING);
          ACanvas.Brush.Style := bsSolid;
          if RightAlignedTree then
            inc(R1.Right)
          else
            dec(R1.Left);
          Item.FTextLeft := R1.Left + FHPos + xOffs -1;
          Item.FTextRight := R1.Right + FHPos + xOffs + 1;
        end else
        begin
          Item.FTextLeft := R1.Left + FHPos + xOffs -1;
          Item.FTextRight := Item.FTextLeft;
        end;
      end
{$ifdef ELTREE_USE_STYLES}
      else
        if Item.UseStyles and (CurStyle.FStyle = elhsPictureOnly) and Assigned(CurStyle.FPicture) then
        begin
          h := CurStyle.FPicture.Height;
          w := CurStyle.FPicture.Width;

          if RightAlignedTree then
          begin
            R2 := Rect(((R.Left + R.Right) div 2)-(w div 2), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), Min(R.Right, ((R.Left + R.Right) div 2)-(w div 2) + w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);
            // R2 := Rect(Max(R.Left, R.Right - w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), R.Right, R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);
            Item.FTextLeft := R.Left + FHPos + xOffs;
            Item.FTextRight := R.Right + FHPos + xOffs;
  
            if CurStyle.FPicture.Transparent then
            begin
            //R2 := Rect(0, 0, Min(CurStyle.FPicture.Width, R.Right - R.Left), Min(CurStyle.FPicture.Height, ((R.Bottom-R.Top+1) div 2)- (h div 2) + h));
            //DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R.Left, R.Top + ((R.Bottom-R.Top + 1) div 2)-(h div 2), R2, CurStyle.FPicture.TransparentColor)
              DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R2.Left, R2.Top, Rect(0, 0, R.Right - min(w, Max(R.Left, R.Right - w + 1) + 1), h), CurStyle.FPicture.TransparentColor);
            end else ACanvas.CopyRect(R2, CurStyle.FPicture.Canvas, Rect(0, 0, R.Right - min(w, Max(R.Left, R.Right - w + 1) + 1), h));
          end else
          begin
            R2 := Rect(R.Left, R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), Min(R.Right, R.Left + w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);
            Item.FTextLeft := R.Left + FHPos + xOffs;
            Item.FTextRight := R.Right + FHPos + xOffs;
            if CurStyle.FPicture.Transparent then
            begin
            //R2 := Rect(0, 0, Min(CurStyle.FPicture.Width, R.Right - R.Left), Min(CurStyle.FPicture.Height, ((R.Bottom-R.Top+1) div 2)- (h div 2) + h));
            //DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R.Left, R.Top + ((R.Bottom-R.Top + 1) div 2)-(h div 2), R2, CurStyle.FPicture.TransparentColor)
              DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R2.Left, R2.Top, Rect(0, 0, min(w, Min(R.Right, R.Left + w - 1) - R.Left + 1), h), CurStyle.FPicture.TransparentColor);
            end else ACanvas.CopyRect(R2, CurStyle.FPicture.Canvas, Rect(0, 0, min(w, Min(R.Right, R.Left + w - 1) - R.Left + 1), h));
          end;
        end;
{$endif}
    end; // if ... else
  end;
  HelperBmp.Free;
end;

procedure TElTreeView.DoRedrawItem;
var
  TSI: TElTreeItem;
{$IFNDEF PaintBackground}
  BgRect,
  BgRect1,
  BgRect2,
  BgRect4    : TRect;
{$ENDIF}
  R, R1, RD,
{$ifdef ELTREE_USE_STYLES}
  R2,
{$endif}
  R3: TRect;
{$IFNDEF PaintBackground}
  Blend    : boolean;
{$ENDIF}
  SText: string;
  i, j, k,
{$ifdef ELTREE_USE_STYLES}
  h,
  w,
{$endif}
  al,
  val,
  hi,
  tw: integer;
  dfr : boolean;
  HS: TElHeaderSection;
  PrevPenColor : TColor;
  FTransBk     : boolean;
  flv: integer;
{$ifdef ELTREE_USE_STYLES}
  CurStyle: TElCellStyle;
{$endif}
  AForm: TCustomForm;
{$IFNDEF LITE}
  OwnBk : boolean;
{$ENDIF}
  xOffs : integer;
  aLockBmp : TBitmap;
{$IFDEF HAS_HTML_RENDER}
  FData    : TElHTMLData;
{$ENDIF}

begin
  aLockBmp := nil;
  TSI      := Item;
  xOffs := 0;
  FTransBk := false;
  with FOwner do
  begin
    r1 := Rect(SurfRect.Left - FHPos, ItemRect.Top, SurfRect.Right - 1 - FHPos, ItemRect.Bottom);
    flv := FDivLineWidth;
    if (not VerticalLines) or FBarStyle then flv := 0;
    FOverColors := false;
    FRowOvColors:= false;
    AForm := GetParentForm(self);
    if (not Item.ParentColors) and (Item.UseBkColor) then
    begin
      ACanvas.Brush.Color := Item.RowBkColor;
      FCurBkColor := Item.RowBkColor;
      FOverColors := true;
      FRowOvColors:= true;
{Soulsnake Add}  
      ACanvas.Font.Color := Item.Color;
      FCurTextColor := Item.Color;
{End Soulsnake Add}
    end;

    if TSI.Selected and (not FBarStyle) and FRowSelect then
    begin
      if (((AForm <> nil) and (AForm.ActiveControl = self)) or (not FHideSelect)) then
      begin
        ACanvas.Brush.Color := FFocusedSelectColor;
        ACanvas.Font.Color := FFocusedSelectTextColor;
        FCurBkColor := FFocusedSelectColor;
        FCurTextColor := clHighlightText;
      end else
      begin
        FCurBkColor := FHideSelectColor;
        ACanvas.Brush.Color := FHideSelectColor;
        ACanvas.Font.Color := FHideSelectTextColor;
        FCurTextColor := FHideSelectTextColor;
      end;
      FOverColors := true;
{$IFNDEF PaintBackground}
      Blend := true;
{$ENDIF}
    end; // if
    if FRowSelect then
    begin
      if (TSI = FDropTrg) and (FDragTrgDrawMode <> dtdNone) then
      begin
        case FDragTrgDrawMode of
          ColorRect:
            begin
              if FDropAcc then
                ACanvas.Brush.Color := FOwner.FDragRectAcceptColor
              else
                ACanvas.Brush.Color := FOwner.FDragRectDenyColor;
              FCurBkColor := ACanvas.Brush.Color;
              ACanvas.Font.Color := clBtnText;
              FCurTextColor := clBtnText;
              FOverColors := true;
            end;
          SelColorRect:
            begin
              ACanvas.Brush.Color := clHighlight;
              ACanvas.Font.Color := clHighlightText;
              FCurBkColor := clHighlight;
              FCurTextColor := clHighlightText;
              FOverColors := true;
            end;
        end; // case
{$IFNDEF PaintBackground}
        Blend := true;
{$ENDIF}
      end;
    end;
    k := FHeader.Sections.Count;
    if FShowHeader then
    begin
      for j := 0 to k do
      begin
        if (j = k) then
        begin
    	  break;
        end else
        begin
          HS := FHeader.Sections[j];
        end;
        if not HS.Visible then Continue;
{Soulsnake Add (Optimisation)}
        if (HS.Right < FHPos - flv) or (HS.Left > FHPos - flv + ItemRect.Right) then continue;
{End Soulsnake Add}
        xOffs := 0;
        hi := HS.Index;
{$IFNDEF PaintBackground}
        Blend := false;
{$ENDIF}
        if HS.Visible then
        begin
          if HS.Index = FMainTreeCol then
            DoRedrawItemTree(ACanvas, Item, ItemRect, ItemRect)
          else
          begin
          // check the proper section and subtext index
            i := hi;
            if i > FMainTreeCol then dec(i);
            if i >= Item.ColumnText.count then SText := '' else
              if HS.Password then SText := '******' else SText := Item.ColumnText[i];
{$ifdef ELTREE_USE_STYLES}
            if Item.FUseStyles then
            begin
              if (Item.FStyles = nil) or (i >= Item.FStyles.Count) or (HS.UseMainStyle) then
                 CurStyle := Item.FMainStyle
              else
                 CurStyle := Item.FStyles[i];
              if FOverColors or CurStyle.FOwnerProps then
              begin
                ACanvas.Brush.Color := FCurBkColor;
                ACanvas.Font.Color := FCurTextColor;
              end
              else
              begin
                ACanvas.Brush.Color := CurStyle.FCellBkColor;
                if not CurStyle.UseBkColor then
                  FTransBk := true; 
              end;

            end
            else
{$endif}
            begin
              ACanvas.Brush.Color := FCurBkColor;
              ACanvas.Font.Color := FCurTextColor;
            end;
            if Item.Selected and (not FBarStyle) and ((FSelectColumn = HS.Index) or FRowSelect) then
            begin
              if (((GetParentForm(self) <> nil) and
                  (GetParentForm(self).ActiveControl = self)) or
                 (not FHideSelect)) then
                 ACanvas.Brush.Color := FFocusedSelectColor
              else
                 ACanvas.Brush.Color := FHideSelectColor;
{$IFNDEF PaintBackground}
              Blend := true;
{$ENDIF}
            end;
            if (TSI = FDropTrg) and (FDragTrgDrawMode <> dtdNone)
               and (((not FRowSelect) and (FSelectColumn = hi)) or FRowSelect) then
            begin
              case FDragTrgDrawMode of
                ColorRect:
                  begin
                    if FDropAcc then
                      ACanvas.Brush.Color := FDragRectAcceptColor
                    else
                      ACanvas.Brush.Color := FDragRectDenyColor;
                  end;
                SelColorRect:
                  ACanvas.Brush.Color := clHighlight;
              end; // case
            end;
            // now fill the background

            R := Rect(HS.Left - FHPos - xOffs, ItemRect.Top, HS.Right - FHPos - flv - xOffs, ItemRect.Bottom);
            //if (not FHLines) or FBarStyle then
               inc(R.Bottom, FDivLineWidth);

            if not FTransBk then
              ACanvas.FillRect(R);

            if (FODFollowCol and (HS.Style = ElhsOwnerDraw)) or ((not (FODFollowCol)) and (SText = FODMask))
{$ifdef ELTREE_USE_STYLES}
              or (Item.FUseStyles and (CurStyle.FStyle = elhsOwnerDraw))
{$endif}
              then
            begin
              R := Rect(HS.Left + 1 - FHPos - xOffs, ItemRect.Top + 1, HS.Right - (FHPos + flv + 1) - xOffs, ItemRect.Bottom - 1);
              DoItemDraw(Item, ACanvas, R, hi);
            end else
            begin
{$ifdef ELTREE_USE_STYLES}
              if Item.UseStyles and (CurStyle.Control <> nil) then
              begin
                R := Rect(HS.Left - FHPos - xOffs, ItemRect.Top, HS.Right - (FHPos + flv) - xOffs, ItemRect.Bottom);
                CurStyle.Control.Paint(ACanvas, R);
              end
              else
              if (Item.UseStyles and (CurStyle.FStyle = elhsText)) or (not Item.FUseStyles) then
{$endif}
              begin
{$ifdef ELTREE_USE_STYLES}
                if Item.FUseStyles then
                begin
                  AL := CurStyle.FTextFlags;
{$IFNDEF LITE}
                  VAL:= AL and (DT_TOP or DT_BOTTOM or DT_VCENTER);
{$ENDIF}
                  if FOverColors or CurStyle.FOwnerProps then
                  begin
                    ACanvas.Font.Color := FCurTextColor;
                    ACanvas.Brush.Color := FCurBkColor;
                  end
                  else
                  begin
                    ACanvas.Brush.Color := CurStyle.FTextBkColor;
                    ACanvas.Font.Color := CurStyle.FTextColor;
                    if not CurStyle.UseBkColor then
                      FTransBk := true;
{$IFNDEF PaintBackground}
                    Blend := true;
{$ENDIF}
                  end;
                  if not CurStyle.FOwnerProps then with CurStyle do
                    begin
                      if ACanvas.Font.Name <> FontName then ACanvas.Font.Name := FontName;
                      if ACanvas.Font.Style <> FontStyles then ACanvas.Font.Style := FontStyles;
                      if ACanvas.Font.Size <> FontSize then ACanvas.Font.Size := FontSize;
                    end else
                  begin
                    if ACanvas.Font.Name <> Font.Name then ACanvas.Font.Name := Font.Name;
                    if ACanvas.Font.Style <> Font.Style then ACanvas.Font.Style := Font.Style;
                    if ACanvas.Font.Size <> Font.Size then ACanvas.Font.Size := Font.Size;
                  end;
                end else
{$endif}
                begin
                  if ACanvas.Font.Name <> Font.Name then ACanvas.Font.Name := Font.Name;
                  if ACanvas.Font.Style <> Font.Style then ACanvas.Font.Style := Font.Style;
                  if ACanvas.Font.Size <> Font.Size then ACanvas.Font.Size := Font.Size;

                  if FRightAlignedText then al := DT_RIGHT else Al := DT_LEFT;
                  if FRightAlignedText then
                  begin
                    case HS.Alignment of
                      hsaCenter: Al := DT_CENTER;
                      hsaRight: Al := DT_LEFT;
                    end; // case
                    AL := AL or DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_RTLREADING or {$IFNDEF LITE}MultiLineEllipseFlags[Item.Multiline]{$ELSE}DT_END_ELLIPSIS{$ENDIF};
                  end else
                  begin
                    case HS.Alignment of
                      hsaCenter: Al := DT_CENTER;
                      hsaRight: Al := DT_RIGHT;
                    end; // case
                    AL := AL or DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF} {$IFNDEF LITE}MultiLineEllipseFlags[Item.Multiline]{$ELSE}DT_END_ELLIPSIS{$ENDIF};
                  end;
                end;
                if (FTracking and (Item = FTrackItem)) and FUnderlineTracked and FRowHotTrack then ACanvas.Font.Style := ACanvas.Font.Style + [fsUnderline];

                if Item.Selected and (not FBarStyle) and ((FSelectColumn = hi) or FRowSelect) then
                begin
                  if (((GetParentForm(self) <> nil) and (GetParentForm(self).ActiveControl = self)) or (not FHideSelect)) then
                  begin
                    ACanvas.Brush.Color := FFocusedSelectColor;
                    ACanvas.Font.Color := FFocusedSelectTextColor;
                  end else
                  begin
                    ACanvas.Brush.Color := FHideSelectColor;
                    ACanvas.Font.Color := FHideSelectTextColor;
                  end;
{$IFNDEF PaintBackground}
                  Blend := true;
{$ENDIF}
                end;
                if (TSI = FDropTrg) and (FDragTrgDrawMode <> dtdNone)
                   and (((not FRowSelect) and (FSelectColumn = hi)) or FRowSelect) then
                begin
                  case FDragTrgDrawMode of
                    ColorRect:
                      begin
                        if FDropAcc then
                          ACanvas.Brush.Color := FDragRectAcceptColor
                        else
                          ACanvas.Brush.Color := FDragRectDenyColor;
                        ACanvas.Font.Color := clBtnText;
                      end;
                    SelColorRect:
                      begin
                        ACanvas.Brush.Color := clHighlight;
                        ACanvas.Font.Color := clHighlightText;
                      end;
                  end; // case
{$IFNDEF PaintBackground}
                  Blend := true;
{$ENDIF}
                end;
                SetRectEmpty(R3);
                ACanvas.Font.Charset := Font.Charset;
{$IFDEF HAS_HTML_RENDER}
                if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
                begin
                  R3.Left := 0;
                  R3.Top := 0;
                  FData := TElHTMLData(Item.FHTMLDataArray[i]);

                  if FData = nil then
                  begin
                    R3.Right  := 0;
                    R3.Bottom := 0;
                  end else
                  with FRender do
                  begin
                    R3.Right := FData.TextSize.cx;
                    R3.Bottom := FData.TextSize.cy;
                  end;
                end else
{$ENDIF}
                begin
                  if FTransBk then
                    ACanvas.Brush.Style := bsClear;
                  DrawText(ACanvas.Handle, PChar(SText), Length(SText), R3, DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF} DT_CALCRECT);
                end;
                tw := R3.Right - R3.Left + FDivLineWidth * 2;
                // define the rectangle for the text
                R := Rect(HS.Left - FHPos - xOffs + FDivLineWidth, ItemRect.Top, HS.Right - (FHPos + flv) - xOffs - FDivLineWidth, ItemRect.Bottom + 1);

                case (AL and (DT_LEFT or DT_RIGHT or DT_CENTER)) of
                  DT_LEFT:
                    begin
                      R.Right := Min(R.Left + tw + ItemExt div 3, R.Right);
                      Inc(R.Left, ItemExt div 5);
                    end;
                  DT_RIGHT:
                    begin
                      R.Left := Max(R.Right - (tw + ItemExt div 3), R.Left);
                      Dec(R.Right, ItemExt div 5);
                    end;
                  DT_CENTER:
                    begin
                      //InflateRect(R, -FDivLineWidth, 0);
                      i := Min(R.Right - R.Left, tw + 3);
                      R.Left := R.Left + ((R.Right - R.Left) div 2 - i div 2);
                      R.Right := R.Left + i;
                    end;
                end;

                //InflateRect(R, 1, 1);
                //if FHLines then inc(R.Bottom, FDivLineWidth);

                  ACanvas.FillRect(R);
                ACanvas.Brush.Style := bsClear;

                {$IFNDEF LITE}
                if (Item.Multiline
                {$IFDEF HAS_HTML_RENDER}or Item.IsHTML{$ENDIF})
                and (VAL = 0) and (LineHeight < (R1.Bottom - R1.Top)) then
                    VAL := DT_TOP
                else
                {$ENDIF}
                    VAL := DT_VCENTER;
                
{$IFDEF HAS_HTML_RENDER}
                if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
                begin
                  if RightAlignedText then
                  begin
                    R3.Left := R.Right - Min(R.Right - R.Left, R3.Right - R3.Left);
                    R3.Right := R.Right;
                  end else
                  begin
                    R3.Right := Min(R.Right - R.Left, R3.Right - R3.Left) + R.Left;
                    R3.Left := R.Left;
                  end;
                  if (VAL and DT_BOTTOM) = DT_BOTTOM then
                  begin
                    OffsetRect(R3, 0, R.Top + (R.Bottom - R.Top) - (R3.Bottom - R3.Top));
                  end else
                  if (VAL and DT_VCENTER) = DT_VCENTER then
                  begin
                    OffsetRect(R3, 0, R.Top + (((R.Bottom - R.Top) - (R3.Bottom - R3.Top)) div 2) - 1);
                  end else
                  begin
                    OffsetRect(R3, 0, R.Top);
                  end;

                  FData := TElHTMLData(Item.FHTMLDataArray[i]);
                  if FData <> nil then
                  with FRender do
                  begin
                    SetData(FData);
                    DrawTextEx(ACanvas, Point(0, 0), R, true, ACanvas.Font.Color, FData.DefaultBgColor, FData.HighlightColor, FData.HighlightBgColor);
                    SetData(nil);
                  end;
                end else
{$ENDIF}
                  DrawText(ACanvas.Handle, PChar(SText), Length(SText), R, DT_NOPREFIX or VAL or AL or DT_EXTERNALLEADING);
                ACanvas.Brush.Style := bsSolid;
              end
{$ifdef ELTREE_USE_STYLES}
              else
              if Item.UseStyles and (CurStyle.FStyle = elhsPictureOnly) and Assigned(CurStyle.FPicture) then
              begin
                R := Rect(HS.Left - FHPos - xOffs, ItemRect.Top, HS.Right - (FHPos + flv) - xOffs, ItemRect.Bottom);
                h := CurStyle.FPicture.Height;
                w := CurStyle.FPicture.Width;
                R2 := Rect(((R.Left + R.Right) div 2)-(w div 2), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), Min(R.Right, ((R.Left + R.Right) div 2)-(w div 2) + w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);
                //R2 := Rect(R.Left, R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2), Min(R.Right, R.Left + w), R.Top + ((R.Bottom - R.Top + 1) div 2) - (h div 2) + h);
                if CurStyle.FPicture.Transparent then
                begin
              //R2 := Rect(0, 0, Min(CurStyle.FPicture.Width, R.Right - R.Left), Min(CurStyle.FPicture.Height, ((R.Bottom-R.Top+1) div 2)- (h div 2) + h));
              //DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R.Left, R.Top + ((R.Bottom-R.Top + 1) div 2)-(h div 2), R2, CurStyle.FPicture.TransparentColor)
                  DrawTransparentBitmapEx(ACanvas.Handle, CurStyle.FPicture.Handle, R2.Left, R2.Top, Rect(0, 0, min(w, Min(R.Right, R.Left + w - 1) - R.Left + 1), h), CurStyle.FPicture.TransparentColor);
                end
                else ACanvas.CopyRect(R2, CurStyle.FPicture.Canvas, Rect(0, 0, min(w, Min(R.Right, R.Left + w - 1) - R.Left + 1), h));
              end;
{$endif}
            end; // if/else
          end;
        end;
      end; //for

      if Item.StrikedOutLine then
      begin
        PrevPenColor := ACanvas.Pen.Color;
        if Item.Selected then
          ACanvas.Pen.Color := clHighlightText
        else
          ACanvas.Pen.Color := Item.StrikedLineColor;

        MoveToEx(ACanvas.Handle,Item.FTextLeft - 2 - FHPos,(ItemRect.Top + ItemRect.Bottom) div 2 + 1 , nil);
        LineTo(ACanvas.Handle, ItemRect.Right + FHPos, (ItemRect.Top + ItemRect.Bottom) div 2 + 1);
        ACanvas.Pen.Color := PrevPenColor;
      end;


    end else
        DoRedrawItemTree(ACanvas, Item, ItemRect, ItemRect);
    if ALockBmp <> nil then ALockBmp.Free;

    if not (FRowSelect) then
    begin
      if (FSelectColumn = -1) or (not FShowHeader) or (FHeader.Sections.Count <= FSelectColumn) then
      begin
        R1.left := TSI.FTextLeft - FHPos - xOffs + 1;
        R1.Right := TSI.FTextRight - FHPos - xOffs - 1;
      end else
      begin
        HS := FHeader.Sections[FSelectColumn];
        R1.Left := HS.Left - FHPos - xOffs;
        R1.Right := R1.Left + HS.Width - xOffs;
        if FVLines then
           dec(R1.Right, FDivLineWidth);
      end;
    end;

    begin
      RD := R1;
      RD.Left := ItemRect.Left - FHPos;
      if FShowHeader then
      begin
        RD.Right := ClientWidth;
        if FBarStyle then
        begin
          dec(RD.Right);
        end;
      end
      else
         RD.Right := ItemRect.Right + 1;

      Inc(RD.Bottom);

      if FRowSelect then
      begin
        R1.Left := ItemRect.Left - FHPos;
        if FShowHeader then
        begin
          R1.Right := FHeader.SectionsWidth - FHPos - flv; //ItemRect.Right {- FHPos }- flv;
          if FBarStyle then
          begin
            dec(R1.Right);
          end;
        end
        else
           R1.Right := ItemRect.Right + 1;
      end
    end;
    //if not FHLines then
    dfr := Focused or (not FHideFocusRect);
    if assigned(FOnItemPostDraw) then
      FOnItemPostDraw(FOwner, ACanvas, Item, R1, dfr);
    inc(R1.Bottom);
    if TSI.Focused and dfr and FDrawFocusRect then
    begin
      ACanvas.Brush.Color := FBkColor;
      ACanvas.Pen.Color := FTextColor;
      ACanvas.Font.Color := FTextColor;
      // this one is made to fix the colors
      ACanvas.TextOut(R1.Left, R1.Top, '');
      // otherwise FocusRect won't draw right
      ACanvas.DrawFocusRect(R1);
    end;
    if (TSI = FDropTrg) then
    begin
      case FDragTrgDrawMode of
      ColorFrame:
        begin
          if FDropAcc then
            ACanvas.Brush.Color := FDragRectAcceptColor
          else
            ACanvas.Brush.Color := FDragRectDenyColor;
          ACanvas.TextOut(RD.Left, RD.Top, '');
          ACanvas.FrameRect(RD);
        end;
      dtdUpColorLine:
        begin
          if FDropAcc then
            ACanvas.Pen.Color := FDragRectAcceptColor
          else
            ACanvas.Pen.Color := FDragRectDenyColor;
          ACanvas.MoveTo(RD.Left, RD.Top);
          ACanvas.LineTo(RD.Right, RD.Top);

          ACanvas.MoveTo(RD.Left, RD.Top + 3);
          ACanvas.LineTo(RD.Left, RD.Top);
          ACanvas.MoveTo(RD.Left + 1, RD.Top + 1);
          ACanvas.LineTo(RD.Left + 1, RD.Top);

          ACanvas.MoveTo(RD.Right - 1, RD.Top + 3);
          ACanvas.LineTo(RD.Right - 1, RD.Top);
          ACanvas.MoveTo(RD.Right - 2, RD.Top + 1);
          ACanvas.LineTo(RD.Right - 2, RD.Top);
        end;
      dtdDownColorLine:
        begin
          dec(RD.Bottom);
          if FDropAcc then
            ACanvas.Pen.Color := FDragRectAcceptColor
          else
            ACanvas.Pen.Color := FDragRectDenyColor;
          ACanvas.MoveTo(RD.Left, RD.Bottom);
          ACanvas.LineTo(RD.Right, RD.Bottom);

          ACanvas.MoveTo(RD.Left, RD.Bottom - 3);
          ACanvas.LineTo(RD.Left, RD.Bottom);
          ACanvas.MoveTo(RD.Left + 1, RD.Bottom - 1);
          ACanvas.LineTo(RD.Left + 1, RD.Bottom);

          ACanvas.MoveTo(RD.Right - 1, RD.Bottom - 3);
          ACanvas.LineTo(RD.Right - 1, RD.Bottom);
          ACanvas.MoveTo(RD.Right - 2, RD.Bottom - 1);
          ACanvas.LineTo(RD.Right - 2, RD.Bottom);
        end;
      dtdUpSelColorLine:
        begin
          ACanvas.Pen.Color := clHighlight;
          ACanvas.MoveTo(RD.Left, RD.Top);
          ACanvas.LineTo(RD.Right, RD.Top);

          ACanvas.MoveTo(RD.Left, RD.Top + 3);
          ACanvas.LineTo(RD.Left, RD.Top);
          ACanvas.MoveTo(RD.Left + 1, RD.Top + 1);
          ACanvas.LineTo(RD.Left + 1, RD.Top);

          ACanvas.MoveTo(RD.Right - 1, RD.Top + 3);
          ACanvas.LineTo(RD.Right - 1, RD.Top);
          ACanvas.MoveTo(RD.Right - 2, RD.Top + 1);
          ACanvas.LineTo(RD.Right - 2, RD.Top);
        end;
      dtdDownSelColorLine:
        begin
          dec(RD.Bottom);
          ACanvas.Pen.Color := clHighlight;
          ACanvas.MoveTo(RD.Left, RD.Bottom);
          ACanvas.LineTo(RD.Right, RD.Bottom);

          ACanvas.MoveTo(RD.Left, RD.Bottom - 3);
          ACanvas.LineTo(RD.Left, RD.Bottom);
          ACanvas.MoveTo(RD.Left + 1, RD.Bottom - 1);
          ACanvas.LineTo(RD.Left + 1, RD.Bottom);

          ACanvas.MoveTo(RD.Right - 1, RD.Bottom - 3);
          ACanvas.LineTo(RD.Right - 1, RD.Bottom);
          ACanvas.MoveTo(RD.Right - 2, RD.Bottom - 1);
          ACanvas.LineTo(RD.Right - 2, RD.Bottom);
        end;
      end;
    end;
  end;
end;
{$WARNINGS on}
{$hints on}

function TElTreeView.GetVisiblesHeight : integer;
var i : integer;
begin
  result := 0;
  for i := 0 to FVisible.Count - 1 do
      inc(Result, TelTreeItem(FVisible[i]).GetHeight);
end;

procedure TElTreeView.RedrawTree;
var
  i, j,
  y, h,
  oy  : integer;
  R, r1, R2, r4: TRect;
  Item: TElTreeItem;
  Sect: TElHeaderSection;
  fSaveStyle : TBrushStyle;
  mb : integer;
begin

  with FOwner do
  begin
    if FShowHeader then
      with FHeader do
      if (Left <> FHPos) {or (Width <> FHPos + FView.Width) }then
      begin
        LeftPos := FHPos;
        //Width := FHPos + FView.Width;
      end;

    if FHeader.Sections.Count <= MainTreeColumn then
       MainTreeColumn := 0;

    fSaveStyle := ACanvas.Brush.Style;
    // redraw items
    j := FVisible.Count - 1;
    for i := 0 to j do
    begin
      R := Self.GetItemRect(i);
      if FHLines and (not FBarStyle) then
          dec(R.Bottom, FDivLineWidth);
      if IntersectRect(R4, R, ACanvas.ClipRect) then
      begin
        r1 := r4;
        R1.Bottom := r1.Top + LineHeight;
        if FHLines and (not FBarStyle) then
           dec(R1.Bottom, FDivLineWidth);
        if FShowHeader then
           r1.right := FHeader.SectionsWidth
        else
        begin
          R.Right := Max(FHRange, FHPos + Self.Width);
          r1.right := R.Right;
        end;

        Item := TElTreeItem(FVisible[i]);
{$ifdef ELTREE_USE_STYLES}
        if not Item.FUseStyles then
{$endif}
        begin
          ACanvas.Font.Color := FTextColor;
          ACanvas.Pen.Color := FTextColor;
        end;
        FCurBkColor := FBkColor;
        FCurTextColor := FTextColor;
        if FBarStyle then
        begin
          InflateRect(R, -1, -1);
          InflateRect(R1, -1, -1);
        end;
        DoRedrawItem(ACanvas, Item, R, R1);
        if FBarStyle then
        begin
          InflateRect(R, 1, 1);
          inc(R.Bottom);
          if FShowHeader then R.Right := -FHPos + FHeader.SectionsWidth;
          if not Item.Selected then DrawEdge(ACanvas.Handle, R, BDR_RAISEDINNER, BF_RECT)
          else DrawEdge(ACanvas.Handle, R, BDR_SUNKENOUTER, BF_RECT);
        end;
      end;
    end;
    ACanvas.Brush.Style := fSaveStyle;
    // fill the rest of the window
    r2 := Self.ClientRect;
    Inc(R2.Right);
    Inc(R2.Bottom);
    if IntersectRect(R4, R2{Self.ClientRect}, ACanvas.ClipRect) then
    begin
      // Draw side empty part
      ACanvas.Brush.Color := FBkColor;
      oy := R4.top - 1;
      Y := GetVisiblesHeight;
      //Changed for flexible heights FVisible.Count * FLineHeight;
      if (R4.Top < Y) then
        R4.Top := Y;
      (*
        ACanvas.FillRect(R4);
      *)
      // Draw bottom empty part

      if FShowHeader then
      begin
        if FHeader.Sections.Count > 0 then
          r4.Left := FHeader.SectionsWidth
        else
          r4.left := 0;
        dec(R4.Left, FHPos);
        R4.Top := oy;
        (*
        ACanvas.FillRect(R4);*)
      end;
    end;

    ACanvas.Pen.Color := FOwner.DivLinesColor;

    // Draw horizontal lines
    if (not FBarStyle) or FBSVLines then
    begin
      if FHLines and (not BarStyle) then
      begin
        y := 0;
        if FShowHeader then
          h := FHeader.SectionsWidth - FHPos
        else
          h := Self.ClientWidth;

        i := 0;
        if FVisible.Count > 0 then
        begin
          Inc(Y, TElTreeItem(FVisible[i]).GetHeight - 1);

          while Y < Self.ClientHeight do
          begin
            if TElTreeItem(FVisible[i]).DrawHLine then
              if IntersectRect(R, Rect(0, Y, h, Y + FDivLineWidth), ACanvas.ClipRect) then
              begin
                ACanvas.MoveTo(R.Left, R.Top);
                ACanvas.LineTo(R.Right, R.Top);
              end;
            inc(i);
            if i >= FVisible.Count then break;
            Inc(Y, TElTreeItem(FVisible[i]).GetHeight);
          end;
        end;
      end;

     // Draw vertical lines
      if FVLines and (FShowHeader) and (FHeader.Sections.Count > 0) then
      begin

        if (FBottomIndex >= 0) then
          mb := GetItemRect(FBottomIndex-FTopIndex).Bottom - FHeader.Height
        else
          mb := 999999;

        for i := 0 to FHeader.Sections.Count - 1 do
        begin
          Sect := FHeader.Sections[i];
          if (not Sect.Visible) or (Sect.Width <= 0) then continue;
          begin
            j := Sect.Right - FHPos;
          end;

          if IntersectRect(R, Rect(j - FDivLineWidth, 0, j, Self.ClientHeight), ACanvas.ClipRect) then
          begin
            if not FVerticalLinesLong then
              R.Bottom := Min(R.Bottom, mb);
            ACanvas.MoveTo(R.Left, R.Top);
            ACanvas.LineTo(R.Left, R.Bottom);
          end;
        end;
      end;
    end;
  end;
end;

procedure TElTreeView.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TElTreeView.OnEditTimer(Sender : TObject);
begin
  FEditTimer.Enabled := false;
  DoEditItem(FItemToEdit, FEditSect);
end;

function TElTreeView.SetupPictureEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  FEditing := true;
  FOwner.TriggerEditRequestEvent(Item, Section);
  FEditing := false;
  FEditingItem := nil;
  result := false;
end;

function TElTreeView.SetupCustomEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  FEditing := true;
  FOwner.TriggerEditRequestEvent(Item, Section);
  FEditing := false;
  FEditingItem := nil;
  result := false;
end;

function TElTreeView.SetupBlobEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  FEditing := true;
  FOwner.TriggerEditRequestEvent(Item, Section);
  FEditing := false;
  FEditingItem := nil;
  result := false;
end;

function TElTreeView.SetupFloatEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  result := SetupTextEditControl(Item, Section, Text, EditRect);
end;

function TElTreeView.SetupDateTimeEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
  FInpEdit  := TElDateTimePicker.Create(Self);
  FFakePopup:= TPopupMenu.Create(self);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  TElDateTimePicker(FInpEdit).Format := edfShortDateLongTime;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  try
    TElDateTimePicker(FInpEdit).DateTime := StrToDateTime(Text);
  except
    on E : EConvertError do
    begin
      TElDateTimePicker(FInpEdit).DateTime := Now;
    end;
  end;
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  TElDateTimePicker(FInpEdit).OnExit := OnEditExit;
  TElDateTimePicker(FInpEdit).OnKeyDown := DoEditKeyDown;
  TElDateTimePicker(FInpEdit).Font.Assign(Font);
  Inc(EditRect.Bottom, 4);

  TElDateTimePicker(FInpEdit).BoundsRect := EditRect;
  result := true;
{$else}
  result := SetupTextEditControl(Item, Section, Text, EditRect);
{$endif}
end;

function TElTreeView.SetupDateEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
  FInpEdit  := TElDateTimePicker.Create(Self);
  FFakePopup:= TPopupMenu.Create(self);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  TElDateTimePicker(FInpEdit).Format := edfLongDate;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  try
    TElDateTimePicker(FInpEdit).DateTime := StrToDateTime(Text);
  except
    on E : EConvertError do
    begin
      TElDateTimePicker(FInpEdit).DateTime := Now;
    end;
  end;
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  TElDateTimePicker(FInpEdit).OnExit := OnEditExit;
  TElDateTimePicker(FInpEdit).OnKeyDown := DoEditKeyDown;
  TElDateTimePicker(FInpEdit).Font.Assign(Font);
  Inc(EditRect.Bottom, 4);

  TElDateTimePicker(FInpEdit).BoundsRect := EditRect;
  result := true;
{$else}
  FInpEdit  := TDateTimePicker.Create(Self);
  TDateTimePicker(FInpEdit).Kind := dtkDate;
  FFakePopup:= TPopupMenu.Create(self);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  TDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  try
    TDateTimePicker(FInpEdit).Date := StrToDate(Text);
  except
    on E : EConvertError do
    begin
      TDateTimePicker(FInpEdit).Date := Now;
    end;
  end;
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  TDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  TDateTimePicker(FInpEdit).OnExit := OnEditExit;
  TDateTimePicker(FInpEdit).OnKeyDown := DoEditKeyDown;
  TDateTimePicker(FInpEdit).Font.Assign(Font);
  Inc(EditRect.Bottom, 4);

  TDateTimePicker(FInpEdit).BoundsRect := EditRect;
  result := true;
{$endif}
end;

function TElTreeView.SetupTimeEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
  FInpEdit  := TElDateTimePicker.Create(Self);
  FFakePopup:= TPopupMenu.Create(self);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  TElDateTimePicker(FInpEdit).Format := edfLongTime;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  try
    TElDateTimePicker(FInpEdit).DateTime := StrToDateTime(Text);
  except
    on E : EConvertError do
    begin
      TElDateTimePicker(FInpEdit).DateTime := Now;
    end;
  end;
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  TElDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  TElDateTimePicker(FInpEdit).OnExit := OnEditExit;
  TElDateTimePicker(FInpEdit).OnKeyDown := DoEditKeyDown;
  TElDateTimePicker(FInpEdit).Font.Assign(Font);
  Inc(EditRect.Bottom, 4);

  TElDateTimePicker(FInpEdit).BoundsRect := EditRect;
  result := true;
{$else}
  FInpEdit  := TDateTimePicker.Create(Self);
  TDateTimePicker(FInpEdit).Kind := dtkTime;
  FFakePopup:= TPopupMenu.Create(Self);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  TDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  try
    TDateTimePicker(FInpEdit).Time := StrToTime(Text);
  except
    on E : EConvertError do
    begin
      TDateTimePicker(FInpEdit).Time := Now;
    end;
  end;
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  TDateTimePicker(FInpEdit).PopupMenu := FFakePopup;
  TDateTimePicker(FInpEdit).OnExit := OnEditExit;
  TDateTimePicker(FInpEdit).OnKeyDown := DoEditKeyDown;
  TDateTimePicker(FInpEdit).Font.Assign(Font);
  Inc(EditRect.Bottom, 4);

  TDateTimePicker(FInpEdit).BoundsRect := EditRect;
  result := true;
{$endif}
end;

function TElTreeView.SetupNumericEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  result := SetupTextEditControl(Item, Section, Text, EditRect);
end;

function TElTreeView.SetupTextEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
var b : boolean;
begin
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;

{$ifdef ELTREE_USE_EXT_EDITORS}
  FInpEdit := EditBoxClass.Create(self);
  FInpEdit.Parent := self;
  FInpEdit.Visible := false;

  EditBoxClass(FInpEdit).HandleDialogKeys := true;
  EditBoxClass(FInpEdit).ButtonVisible    := false;
  EditBoxClass(FInpEdit).AltButtonVisible := false;
  EditBoxClass(FInpEdit).ActiveBorderType := FOwner.ActiveBorderType;
  if Item.Multiline then
     EditBoxClass(FInpEdit).AutoSize      := false;
  EditBoxClass(FInpEdit).Multiline        := Item.Multiline;

  EditBoxClass(FInpEdit).PopupMenu := FFakePopup;
  EditBoxClass(FInpEdit).BorderStyle := bsSingle;
  EditBoxClass(FInpEdit).ParentCtl3D := false;
  EditBoxClass(FInpEdit).Ctl3D := false;
  EditBoxClass(FInpEdit).OnExit := OnEditExit;
  EditBoxClass(FInpEdit).OnKeyDown := DoEditKeyDown;
  EditBoxClass(FInpEdit).AutoSize := false;
  EditBoxClass(FInpEdit).HandleDialogKeys := true;
  EditBoxClass(FInpEdit).Font.Assign(Font);

  b := EditBoxClass(FInpEdit).Font.Height < 0;
  if b then
     EditBoxClass(FInpEdit).Height := -Font.Height + 2
  else
     EditBoxClass(FInpEdit).Height := Font.Height + 2;
  EditBoxClass(FInpEdit).Text := Text;
  with EditBoxClass(FInpEdit) do
  begin
    Modified := false;
    SelStart := 0;
    SelLength := Length(Text);
    Height := Max(Height, EditRect.Bottom - EditRect.Top);
  end;
{$ELSE}
  begin
    FInpEdit := TEdit.Create(Self);
    FInpEdit.Parent := self;
    FInpEdit.Visible := false;

    TEdit(FInpEdit).PopupMenu := FFakePopup;
    TEdit(FInpEdit).BorderStyle := bsSingle;
    TEdit(FInpEdit).ParentCtl3D := false;
    TEdit(FInpEdit).Ctl3D := false;
    TEdit(FInpEdit).OnExit := OnEditExit;
    TEdit(FInpEdit).OnKeyDown := DoEditKeyDown;
    TEdit(FInpEdit).AutoSize := false;
    TEdit(FInpEdit).Font.Assign(Font);

    b := TEdit(FInpEdit).Font.Height < 0;
    if b then
       TEdit(FInpEdit).Height := -Font.Height + 2
    else
       TEdit(FInpEdit).Height := Font.Height + 2;
    TEdit(FInpEdit).Text := Text;
    with TEdit(FInpEdit) do
    begin
      Modified := false;
      SelStart := 0;
      SelLength := Length(Text);
      Height := Max(Height, EditRect.Bottom - EditRect.Top);
    end;
  end;
{$ENDIF}

  if Section <> nil then
     FOwner.TriggerTuneUpInplaceEditEvent(Item, Section.Index, TCustomEdit(FInpEdit));

  FInpEdit.BoundsRect := EditRect;
  result := true;
end;

function TElTreeView.SetupBoolEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  FInpEdit := CheckBoxClass.Create(Self);

  FInpEdit.Parent := self;
  FInpEdit.Visible := false;

  CheckBoxClass(FInpEdit).AllowGrayed := false;
  CheckBoxClass(FInpEdit).Caption := '';
  CheckBoxClass(FInpEdit).BoundsRect := EditRect;
  CheckBoxClass(FInpEdit).OnExit := OnEditExit;
  CheckBoxClass(FInpEdit).OnKeyDown := DoEditKeyDown;
  CheckBoxClass(FInpEdit).Checked := Text <> '';
{$ifdef ELTREE_USE_EXT_EDITORS}
  CheckBoxClass(FInpEdit).Flat := FOwner.Flat;
  CheckBoxClass(FInpEdit).UseCustomGlyphs := FOwner.CustomCheckboxes;
  if FOwner.CustomCheckboxes then
     CheckBoxClass(FInpEdit).Glyph := FOwner.CheckBoxGlyph;
{$ENDIF}
  result := true;
end;

function TElTreeView.SetupCurrencyEditControl(Item : TElTreeItem; Section :
    TElHeaderSection; Text : string; EditRect : TRect): Boolean;
begin
{$ifdef ELTREE_USE_EXT_EDITORS}
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  FInpEdit := TElCurrencyEdit.Create(Self);
  FInpEdit.Parent := self;
  FInpEdit.Visible := false;

  TElCurrencyEdit(FInpEdit).ActiveBorderType := FOwner.ActiveBorderType;

  TElCurrencyEdit(FInpEdit).PopupMenu := FFakePopup;
  TElCurrencyEdit(FInpEdit).BorderStyle := bsSingle;
  TElCurrencyEdit(FInpEdit).ParentCtl3D := false;
  TElCurrencyEdit(FInpEdit).Ctl3D := false;
  TElCurrencyEdit(FInpEdit).OnExit := OnEditExit;
  TElCurrencyEdit(FInpEdit).OnKeyDown := DoEditKeyDown;
  TElCurrencyEdit(FInpEdit).Font.Assign(Font);

  if Section <> nil then
     FOwner.TriggerTuneUpInplaceEditEvent(Item, Section.Index, TCustomEdit(FInpEdit));

  TElCurrencyEdit(FInpEdit).Value := PrettyStrToCurr(Text);
  FInpEdit.BoundsRect := EditRect;
  result := true;
{$ELSE}
  result := SetupTextEditControl(Item, Section, Text, EditRect);
{$ENDIF}
end;

function TElTreeView.SetupEnumEditControl(Item : TElTreeItem; Section : TElHeaderSection; Text : string; EditRect : TRect) : boolean;
begin
  FInpEdit := ComboBoxClass.Create(self);
{$ifdef ELTREE_USE_EXT_EDITORS}
  ComboBoxClass(FInpEdit).ActiveBorderType := FOwner.ActiveBorderType;
{$ENDIF}
  FFakePopup := TPopupMenu.Create(nil);
  FFakePopup.AutoPopup := false;
  FInpEdit.Parent := self;
  ComboBoxClass(FInpEdit).PopupMenu := FFakePopup;
  FInpEdit.Visible := false;
  ComboBoxClass(FInpEdit).Style := csDropDownList;
  ComboBoxClass(FInpEdit).ParentCtl3D := false;
  ComboBoxClass(FInpEdit).Ctl3D := false;
  ComboBoxClass(FInpEdit).OnExit := OnEditExit;
  ComboBoxClass(FInpEdit).OnKeyDown := DoEditKeyDown;
  ComboBoxClass(FInpEdit).ItemIndex := 0;
  ComboBoxClass(FInpEdit).Text := Text;
  ComboBoxClass(FInpEdit).BoundsRect := EditRect;
  FOwner.TriggerComboEditShowEvent(Item, Section, ComboBoxClass(FInpEdit));
  ComboBoxClass(FInpEdit).Font.Assign(Font);

  if ComboBoxClass(FInpEdit).Font.Height < 0 then
     ComboBoxClass(FInpEdit).Font.Height := -(-Font.Height - 1)
  else
     ComboBoxClass(FInpEdit).Font.Height := Font.Height - 1;

  result := true;
end;

function TElTreeView.SetupEditControl(Item : TElTreeItem; Section : TElHeaderSection; FT : TFieldTypes) : boolean;
var s  : string;
    sn : integer;
    R  : TRect;
    Left : integer;
begin
  R := GetItemRect(FVisible.IndexOf(Item));

  if (Section = nil) or (Section.Index = FOwner.FMainTreeCol) then
  begin
    s := Item.Text;
    with FOwner do
    begin
      if (Item.FTextLeft < FHPos) or (Item.FTextLeft > FHPos + Self.Width) then
         SetHPosition(Item.FTextLeft);
      R.Left := Item.FTextLeft - FHPos;
      if Section <> nil then
         R.Right := Section.Right
      else
         R.Right := ClientWidth - 1;
      if R.Right >= ClientWidth then
         R.Right := ClientWidth - 1;
    end;
  end else
  begin
    sn := Section.Index;
    if sn > FOwner.MainTreeColumn then dec(sn);
    if Item.ColumnText.Count <= sn then
       s := ''
    else
       s := Item.ColumnText[sn];
    Left := Section.Left;
    if (Left < FOwner.FHPos) or (Left > FOwner.FHPos + ClientWidth) then
       FOwner.SetHPosition(Left);
    R.Left := Left - FOwner.FHPos;
    R.Right := R.Left + Section.Width;
    if R.Right >= ClientWidth then
       R.Right := ClientWidth - 1;
  end;

  case FT of
    sftPicture: result := SetupPictureEditControl(Item, Section, s, R);
    sftCustom : result := SetupCustomEditControl(Item, Section, s, R);
    sftBLOB   : result := SetupBlobEditControl(Item, Section, s, R);
    sftEnum   : result := SetupEnumEditControl(Item, Section, s, R);
    sftDate   : result := SetupDateEditControl(Item, Section, s, R);
    sftTime   : result := SetupTimeEditControl(Item, Section, s, R);
    sftDateTime: result := SetupDateTimeEditControl(Item, Section, s, R);
    sftText   : result := SetupTextEditControl(Item, Section, s, R);
    sftFloating,
    sftNumber : result := SetupNumericEditControl(Item, Section, s, R);
    sftBool   : result := SetupBoolEditControl(Item, Section, s, R);
    sftCurrency: result := SetupCurrencyEditControl(Item, Section, s, R);
    else
      result := false;
  end; // case
end;

procedure TElTreeView.DoEditItem;
var
  Section: TElHeaderSection;
  b: boolean;
{$ifdef ELTREE_USE_STYLES}
  Style: TElCellStyle;
  i: integer;
{$endif}
  FT: TFieldTypes;

begin
  if Item = nil then
    raise EElTreeError.Create(STexInvItem);
{Original}
  //if FVisible.IndexOf(Item) = -1 then
{End Original}
{Soulsnake Fix}
  if FFullVisible.IndexOf(Item) = -1 then
{End Soulsnake Fix}
    FOwner.EnsureVisible(Item);
  if FInpEdit <> nil then
  begin
    if FInpEdit.Visible then
      DoEndEdit(true);
    FInpEdit.Parent := nil;
    if FFakePopup <> nil then
      FFakePopup.Free;
    FFakePopup := nil;
    FInpEdit.Free;
    FInpEdit := nil;
  end;
  if FOwner.ShowColumns and (SectionNum = -1) then
     SectionNum := FOwner.MainTreeColumn;
  FEditingItem := Item;
  FEditSect := SectionNum;
  if (SectionNum <> -1) then
  begin
    Section := FHeader.Sections[SectionNum];
    if (not Section.Visible) then
    begin
      FEditingItem := nil;
      exit;
    end;
  end else
    Section := nil;
{$ifdef ELTREE_USE_STYLES}
  if Item.UseStyles then
  begin
    if (SectionNum = FOwner.MainTreeColumn) or (SectionNum = -1) then
       Style := Item.MainStyle
    else
    begin
      i := SectionNum;
      if i > FOwner.MainTreeColumn then dec(i);
      if (Item.FStyles = nil) or (Item.FStyles.Count > i) then
        Style := Item.FStyles[i]
      else
        Style := Item.MainStyle;
    end;
    FT := Style.CellType;
  end else
{$endif}
  begin
    if Section <> nil then
      FT := Section.FieldType
    else
      FT := sftText;
  end;
  b := true;
  FOwner.TriggerTryEditEvent(Item, Section, FT, b);
  if not b then
  begin
    FEditingItem := nil;
    exit;
  end;
  FEditType := FT;
  if not SetupEditControl(Item, Section, FT) then
     exit;

  FOldHide := FOwner.HideSelection;
  FOwner.FHideSelect := false;

  FInpEdit.Visible := true;
  FInpEdit.SetFocus;
  FEditing := true;
end;
{$endif}

procedure TElTreeView.DoEndDrag(Target: TObject; X, Y: Integer);
var
  TSI: TElTreeItem;
begin
  inherited DoEndDrag(Target, X, Y);
  FDragImages.Free;
  FDragImages := nil;
  TSI := FDropTrg;
  FDropTrg := nil;
  if TSI <> nil then
    TSI.RedrawItem(true);
end;

procedure TElTreeView.WMRButtonUp(var Msg: TWMRButtonUp);
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  Item: TElTreeItem;
{$ifdef ELTREE_USE_STYLES}
  Ctrl: TElCellControl;
  b: boolean;
  PopupMenu : TPopupMenu;
  j : integer;
{$endif}
  X, Y : integer;

begin
  DoHideLineHint;

  X := Msg.XPos;
  Y := Msg.YPos;
{$ifdef ELTREE_USE_STYLES}
  b := (FClickControl <> nil);
{$endif}
  Item := GetItemAt(X, Y, ItemPart, HCol);
  if (Item = nil) or (Item.Enabled) then
  begin
    if ItemPart = ipColumn then
    begin
{$ifdef ELTREE_USE_STYLES}
      j := HCol;
      if HCol > FOwner.FMainTreeCol then Dec(HCol);
      if Item.UseStyles and (Item.StylesCount > HCol) then
      begin
        with FOwner do
          y := (y div LineHeight) * LineHeight;
        if not Item.Styles[HCol].OwnerProps then
        begin
          Ctrl := Item.Styles[HCol].Control;
          if Ctrl <> nil then
          begin
            Ctrl.TriggerMouseUpEvent(mbRight, ElVCLUtils.GetShiftState, X - FOwner.FHPos - FHeader.Sections[j].Left, Y);
            if Ctrl = FClickControl then Ctrl.TriggerClickEvent;
            PopupMenu := Ctrl.PopupMenu;
            if (PopupMenu <> nil) and PopupMenu.AutoPopup then
            begin
              SendCancelMode(nil);
              PopupMenu.PopupComponent := Ctrl;
              with ClientToScreen(SmallPointToPoint(Msg.Pos)) do PopupMenu.Popup(X, Y);
              Exit;
            end else
              inherited;
            b := false;
          end;
        end;
      end;
{$endif}
    end;
{$ifdef ELTREE_USE_STYLES}
    if b then
       FClickControl.TriggerMouseUpEvent(mbRight, ElVCLUtils.GetShiftState, -1, -1);
    FClickControl := nil;
    if (not b) then
{$endif}
       inherited;
  end;
end;

procedure TElTreeView.WMLButtonUp(var Message: TWMLButtonUp);
var
  Item: TElTreeItem;
  ItemPart: TSTItemPart;
  HCol    : Integer;
{$ifdef ELTREE_USE_STYLES}
  j: Integer;
  Ctrl: TElCellControl;
  b: boolean;
  X, Y : integer;
{$endif}

begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if FEditTimer <> nil then
     FEditTimer.Enabled := false;
{$endif}
  DoHideLineHint;
  FPressed := false;
  Item := GetItemAt(Message.XPos, Message.YPos, ItemPart, HCol);

  if (Item = nil) or (Item.Enabled) then
  begin
    if (FPressCoord.Y = Message.YPos) and (FPressCoord.X = Message.XPos)
    // if the mouse was moved when the button was pressed, we don't check for editing
    and (ItemPart <> ipInside) and (ItemPart <> ipButton) then
    begin
      if not FIgnoreClick2 then
      begin
        FClicked := true;
        FClickCoord := Point(Message.XPos, Message.YPos);
        FClickItem := Item;
      end;
    end;
    if Item = nil then FClickItem := nil;
    FIgnoreClick2 := false;
    inherited;
{$ifdef ELTREE_USE_STYLES}
    // now check the CellControl
    X := Message.XPos;
    Y := Message.YPos;
    b := (FClickControl <> nil);
    Item := GetItemAt(X, Y, ItemPart, HCol);
    if ItemPart = ipColumn then
    begin
      j := HCol;
      if HCol > FOwner.FMainTreeCol then Dec(HCol);
      if Item.UseStyles and (Item.StylesCount > HCol) then
      begin
        with FOwner do
          y := (y div LineHeight) * LineHeight;
        if not Item.Styles[HCol].OwnerProps then
        begin
          Ctrl := Item.Styles[HCol].Control;
          if Ctrl <> nil then
          begin
            Ctrl.TriggerMouseUpEvent(mbRight, ElVCLUtils.GetShiftState, X - FOwner.FHPos - FHeader.Sections[j].Left, Y);
            if Ctrl = FClickControl then Ctrl.TriggerClickEvent;
            b := false;
          end;
        end;
      end;
    end;
    if b then
      FClickControl.TriggerMouseUpEvent(mbRight, ElVCLUtils.GetShiftState, -1, -1);
    FClickControl := nil;
{$endif}
  end;
end;

procedure TElTreeView.MouseMove(Shift: TShiftState; X, Y: Integer); { protected }
{$ifdef ELTREE_USE_STYLES}
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  Item: TElTreeItem;
  Ctrl: TElCellControl;
  CX, CY: integer;
  i, j: integer;
{$endif}
begin
{$ifdef ELTREE_USE_STYLES}
  HCol := 0;
  Item := GetItemAt(X, Y, ItemPart, HCol);
  if (ItemPart = ipColumn) then
  begin
    i := HCol;
    j := i;
    if i > FOwner.FMainTreeCol then Dec(i);
    if Item.UseStyles and (Item.StylesCount > HCol) then
    begin
      CY := X;
      CX := Y;
      with FOwner do
        cy := (cy div LineHeight) * LineHeight;
      if not Item.Styles[i].OwnerProps then
      begin
        Ctrl := Item.Styles[i].Control;
        if Ctrl <> nil then
        begin
          Ctrl.TriggerMouseMoveEvent(GetShiftState, CX - FOwner.FHPos - FHeader.Sections[j].Left, CY);
          exit;
        end;
      end;
    end;
  end;
{$endif}
  inherited;
end; { MouseMove }

procedure TElTreeView.WMRButtonDblClk(var Msg: TWMRButtonDblClk); { private }
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  Item: TElTreeItem;
{$ifdef ELTREE_USE_STYLES}
  Ctrl: TElCellControl;
  i: integer;
{$endif}
begin
  HCol := 0;
  Item := GetItemAt(Msg.XPos, Msg.YPos, ItemPart, HCol);
  if (Item = nil) or (Item.Enabled) then
  begin
    if (ItemPart = ipColumn) then
    begin
{$ifdef ELTREE_USE_STYLES}
      i := HCol;
      if i > FOwner.FMainTreeCol then Dec(i);
      if Item.UseStyles and (Item.StylesCount > HCol) then
      begin
        if not Item.Styles[i].OwnerProps then
        begin
          Ctrl := Item.Styles[i].Control;
          if Ctrl <> nil then
          begin
            Ctrl.TriggerDblClickEvent;
            exit;
          end;
        end;
      end;
{$endif}
    end;
    inherited;
  end;
end; { WMRButtonDblClk }

procedure TElTreeView.WMLButtonDblClk(var Message: TWMLButtonDblClk);
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  Item: TElTreeItem;
{$ifdef ELTREE_USE_STYLES}
  Ctrl: TElCellControl;
  i: integer;
{$endif}
begin
  HCol := 0;
  Item := GetItemAt(Message.XPos, Message.YPos, ItemPart, HCol);
  if (Item = nil) or (Item.Enabled) then
  begin
    if ((ItemPart = ipMainText) or ((Item <> nil) and (FOwner.FFullRowSelect) and (ItemPart <> ipCheckBox))) and FOwner.FExpandOnDblClick then
    begin
      if Item.Expanded then
        Item.Expanded := false
      else
      begin
        Item.Expanded := true;
        //FitMostChildren(Item);
      end;
    end;
    if (ItemPart = ipColumn) then
    begin
{$ifdef ELTREE_USE_STYLES}
      i := HCol;
      if i > FOwner.FMainTreeCol then Dec(i);
      if Item.UseStyles and (Item.StylesCount > HCol) then
      begin
        if not Item.Styles[i].OwnerProps then
        begin
          Ctrl := Item.Styles[i].Control;
          if Ctrl <> nil then
          begin
            Ctrl.TriggerDblClickEvent;
            exit;
          end;
        end;
      end;
{$endif}
{$ifdef ELTREE_USE_INPLACE_EDITORS}
      if (FOwner.FCanEdit) and (FHeader.Sections[HCol].Editable) and Item.Enabled and not (csDesigning in FOwner.ComponentState) then DoEditItem(Item, HCol);
{$endif}
    end;
    FClicked := false;
    FClickItem := nil;
    FIgnoreClick2 := true;
    FIgnoreClick := true;
    try
      if ItemPart <> ipButton then
        inherited;
    finally
      FIgnoreClick := false;
    end;
  end;
end;

procedure TElTreeView.WMLButtonDown(var Message: TWMLButtonDown);
var
  Item    : TElTreeItem;
  ItemPart: TSTItemPart;
  HCol    : Integer;
  XPos,
  YPos    : integer;
begin
  DoHideLineHint;
  FIgnoreClick2 := false;
  // this has been moved to MouseDown
  if (not (csDesigning in ComponentState)) and (not Focused) and CanFocus then SetFocus;
  XPos := Message.XPos;
  YPos := Message.YPos;
  inherited;
  FPressCoord := Point(XPos, YPos);
  FPressed := true;
  Item := GetItemAt(XPos, YPos, ItemPart, HCol);
  if (Item = nil) or (Item.Enabled) then
  begin
    if (ItemPart = ipMainText) then
    begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
      if (Item = FClickItem) and Item.AllowEdit and FOwner.FCanEdit and FClicked then
      begin
        with FOwner do
        if (FShowHeader) then
        begin
          if FHeader.Sections[FMainTreeCol].Editable and not (csDesigning in FOwner.ComponentState) then
          begin
            if FEditTimer = nil then FEditTimer := TTimer.Create(nil);
            FEditTimer.Enabled := false;
            FEditTimer.Interval := 500;
            FEditTimer.OnTimer := OnEditTimer;
            FItemToEdit := Item;
            FEditSect   := FMainTreeCol;
            FEditTimer.Enabled := true;
          end;
        end else if not (csDesigning in FOwner.ComponentState) then
        begin
          if FEditTimer = nil then FEditTimer := TTimer.Create(nil);
          FEditTimer.Enabled := false;
          FEditTimer.Interval := 500;
          FEditTimer.OnTimer := OnEditTimer;
          FItemToEdit := Item;
          FEditSect   := -1;
          FEditTimer.Enabled := true;
        end;
        FClicked := false;
      end;
{$endif}
    end;
  end;
end;

procedure TElTreeView.WMRButtonDown(var Message: TWMRButtonDown);
begin
  DoHideLineHint;
  inherited;
  if not (csDesigning in ComponentState) and
    (CanFocus or (GetParentForm(Self) = nil)) then
  begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    DoEndEdit(false);
{$endif}    
    SetFocus;
  end;
end;

procedure TElTreeView.WMMouseMove(var Message: TWMMouseMove);
var
  TSI  : TElTreeItem;
  TSI2 : TElHeaderSection;
  R    : Trect;
  IP   : TSTItemPart;
{$IFNDEF VCL_5_USED}
  AMsg : TMessage;
{$ENDIF}
  HCol : integer;
  P    : TPoint;
begin
  inherited;
  if not Dragging then
  begin
    if FPressed then
    begin
      if FOwner.DragAllowed and
         ((FOwner.MultiSelect and (FOwner.FSelectedList.Count > 0)) or
          (not FOwner.MultiSelect and (FSelected <> nil))) and
         (sqrt(sqr(FPressCoord.X - Message.XPos) + sqr(FPressCoord.Y - Message.YPos)) >= 5) then
      begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
        if FEditTimer <> nil then
           FEditTimer.Enabled := false;
{$endif}
        FClickPassed := false;
        FPassedItem := nil;
        FIgnoreClick2 := true;

        if FOwner.DragType <> dtOLE then
        begin
          BeginDrag(true);
        end
{$IFDEF VER90}
          ;
{$ELSE}
        else
        begin
        end;
{$ENDIF}
      end;
    end;
    if (FHintItemEx <> nil) or (not ShowHint) then
    begin
      Application.Hint := FOwner.FRealHint;
      Hint := FOwner.FRealHint;

      TSI := GetItemAt(Message.XPos, Message.YPos, IP, HCol);
      if (TSI <> nil) then
      begin
        if (FHintItemEx <> TSI) then
        begin
          if Length(TSI.Hint) > 0 then
          begin
             Application.Hint := TSI.Hint;
             Hint := TSI.Hint;
          end;
          if ShowHint and (not FInDragging) then
          begin
            P := ClientToScreen(SmallPointToPoint(Message.Pos));
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
      end;
    end;
    
    if FOwner.FShowHintMode <> shmNone then
    begin
      if (FHintCoord.X <> Message.XPos) or (FHintCoord.Y <> Message.YPos) then
      begin
        if {(FOwner.FHideHintOnMove) or} (FHintItem <> GetItemAtY(Message.YPos)) then
        begin
          DoHideLineHint;
          FHintItem := nil;
          FHintCoord := Point(Message.XPos, Message.YPos);
          FHintTimer := TTimer.Create(self);
          FHintTimer.Enabled  := false;
          FHintTimer.OnTimer  := OnHintTimer;
          FHintTimer.Interval := Application.HintShortPause;
          if FHintTimer.Interval = 0 then
             FHintTimer.Interval := 1000;
          FHintTimer.Enabled := true;
        end;
      end;
    end;
    if FOwner.FTracking and Focused then
    begin
      TSI := FTrackItem;
      TSI2 := FTrackSection;
      FTrackItem := GetItemAtY(Message.YPos);
      FTrackSection := FHeader.GetSectionAt(Message.XPos, 0);
      if (TSI = FTrackItem) and (TSI2 = FTrackSection) then exit;
      if (TSI <> nil) and (TSI <> FTrackItem) then
      begin
        if (not FOwner.FShowHeader) or FOwner.FRowHotTrack then TSI.RedrawItem(false)
        else
        begin
          R := GetItemRect(FVisible.IndexOf(TSI));
          with FOwner do
          begin
            R.Left := FHeader.Sections[FMainTreeCol].Left - FHPos;
            R.Right := FHeader.Sections[FMainTreeCol].Right - FHPos;
          end;
          InvalidateRect(Handle, @R, true);
        end;
      end;
      if (FTrackItem <> nil) and (TSI <> FTrackItem) then
      begin
        if (not FOwner.FShowHeader) or FOwner.FRowHotTrack then FTrackItem.RedrawItem(false)
        else
        begin
          R := GetItemRect(FVisible.IndexOf(FTrackItem));
          with FOwner do
          begin
            R.Left := FHeader.Sections[FMainTreeCol].Left - FHPos;
            R.Right := FHeader.Sections[FMainTreeCol].Right - FHPos;
          end;
          InvalidateRect(Handle, @R, true);
        end;
      end;
      FOwner.TriggerHotTrackEvent(TSI, TSI2, FTrackItem, FTrackSection);
      //Update;
    end; // if (FTracking and Focused)
  end; //if (not Dragging)
end;

procedure TElTreeView.CMDrag(var Message: TCMDrag);
var
  TSI: TElTreeItem;
begin
  FOwner.FDragObject := Message.DragRec^.Source;
  inherited;
  with Message, DragRec^ do
  begin
    case DragMessage of
      dmDragEnter:
        FInDragging := true;
      dmDragMove:
        begin
          if FOwner.DragAllowed then
            with ScreenToClient(Pos) do
              DoDragOver(Source, X, Y, Message.Result <> 0);
        end;
      dmDragLeave:
        begin
          FInDragging := false;
          FOwner.FDragObject := nil;
          if FDragExpandTimer <> nil then
          begin
            FDragExpandTimer.Enabled := false;
          end;

          if FOwner.DragAllowed then
          begin
            if FDragScrollTimer <> nil then
            begin
              FDragScrollTimer.Free;
              FDragScrollTimer := nil;
            end;
            TDragObject(Source).HideDragImage;
            TSI := FDropTrg;
            FDropTrg := nil;
            if TSI <> nil then
            begin
              TSI.RedrawItem(false);
              Update;
            end;
            TDragObject(Source).ShowDragImage;
          end;
        end;
      dmDragDrop,
      dmDragCancel:
        begin
          FInDragging := false;
          FOwner.FDragObject := nil;
          if FDragExpandTimer <> nil then
          begin
            FDragExpandTimer.Enabled := false;
            FDragExpandTimer.Free;
            FDragExpandTimer := nil;
          end;

          if FOwner.DragAllowed then
          begin
            if FDragScrollTimer <> nil then
            begin
              FDragScrollTimer.Free;
              FDragScrollTimer := nil;
            end;
            TSI := FDropTrg;
            FDropTrg := nil;
            if TSI <> nil then
            begin
              TSI.RedrawItem(false);
              Update;
            end;
          end;
        end;
    end;
  end;
end;

procedure TElTreeView.DoStartDrag(var DragObject: TDragObject);
begin
  DragCursor := FOwner.DragCursor;
  FDropTrg := nil;
  if (FSelected <> nil) or ((FOwner.FSelectedList <> nil) and (FOwner.FSelectedList.Count > 0)) then
     FillDragImage;
  if (FDragImages <> nil) then
  begin
    with FOwner do
    if FShowHeader then
      FDragImages.SetDragImage(0, FPressCoord.X + FHPos - FHeader.Sections[FMainTreeCol].Left, FPressCoord.y - fddy)
    else
      FDragImages.SetDragImage(0, FPressCoord.X + FHPos, FPressCoord.y - fddy);
  end;
  inherited DoStartDrag(DragObject);
end;

procedure TElTreeView.OnScrollTimer(Sender : TObject);
var P : TPoint;
    Y : integer;
begin
  FDragScrollTimer.Enabled := false;
  FDragScrollTimer.Interval := 100;
  if FVisible.Count > 0 then
  begin
    GetCursorPos(P);
    P := ScreenToClient(P);
    y := P.Y;
    if ((FOwner.TopIndex > 0) and (Y <= TElTreeItem(FVisible[0]).GetHeight div 2)) then
    begin
      if FOwner.FDragObject <> nil then FOwner.FDragObject.HideDragImage;
      SetVPosition(FOwner.TopIndex - 1);
      if FOwner.FDragObject <> nil then FOwner.FDragObject.ShowDragImage;
      FDragScrollTimer.Enabled := true;
    end else
    if ((FOwner.BottomIndex <= FOwner.TotalVisCount) and (Y >= Height - TElTreeItem(FVisible.Last).GetHeight div 2)) then
    begin
      if FOwner.FDragObject <> nil then FOwner.FDragObject.HideDragImage;
      SetVPosition(FOwner.TopIndex + 1);
      if FOwner.FDragObject <> nil then FOwner.FDragObject.ShowDragImage;
      FDragScrollTimer.Enabled := true;
    end;
  end;
end;

function TElTreeView.DragScroll; { protected }
var
  NewY: integer;
begin
  result := false;
  NewY := 0;
  if (Y < NewY + (FOwner.FLineHeight div 2)) and (FOwner.TopIndex > 0) then
  begin
    Source.HideDragImage;
    result := true;
    SetVPosition(FOwner.TopIndex - 1);
  end else
    if (Y > Height - (FOwner.FLineHeight div 2)) and (FOwner.BottomIndex <= FOwner.TotalVisCount) then
    begin
      Source.HideDragImage;
      result := true;
      SetVPosition(FOwner.TopIndex + 1);
    end;
end; { DragScroll }

procedure TElTreeView.DoDragOver(Source: TDragObject; X, Y: Integer; CanDrop: Boolean);
var
  TSI: TElTreeItem;
  R  : TRect;
begin
  //TDragObject(Source).HideDragImage;
  if (FHintTimer <> nil) or (FHintItem <> nil) then
    DoHideLineHint;

  if FVisible.Count > 0 then
    if ((FOwner.TopIndex > 0) and
        (Y <= TElTreeItem(FVisible[0]).GetHeight div 2)) or
       ((FOwner.BottomIndex <= FOwner.TotalVisCount) and
        (Y >= Height - TElTreeItem(FVisible.Last).GetHeight div 2)) then
    begin
      if FDragScrollTimer = nil then
        FDragScrollTimer := TTimer.Create(nil);
      FDragScrollTimer.OnTimer := OnScrollTimer;
      FDragScrollTimer.Interval := 300;
      FDragScrollTimer.Enabled := true;
    end;
  //fh := DragScroll(Source, X, Y);

  FDropAcc := CanDrop;
  TSI := FDropTrg;

  FDropTrg := GetItemAtY(Y);
  if Assigned(FDropTrg) and (not FDropTrg.Enabled) then
    FDropTrg := nil;
  if TSI = FDropTrg then
  begin
    //if fh then Source.ShowDragImage;
    exit;
  end;
  Source.HideDragImage;
  try
    if TSI <> nil then
      TSI.RedrawItem(false);

    if Assigned(FOwner.OnDragTargetChange) then
    begin
      R := FOwner.GetItemRect(FVisible.IndexOf(FDropTrg));
      FOwner.OnDragTargetChange(FOwner, FDropTrg, R, X, Y + Top);
    end;

    if FDropTrg <> nil then
    begin
      if FOwner.FExpandOnDragOver then
      begin
        if FOwner.FDragExpandDelay = 0 then
          FDropTrg.Expand(false)
        else
        begin
          if FDragExpandTimer = nil then
            FDragExpandTimer := TTimer.Create(nil);
          with FDragExpandTimer do
          begin
            Enabled := false;
            OnTimer := OnDragExpandTimer;
            Interval:= FOwner.FDragExpandDelay;
            Enabled := true;
          end;
        end;
      end;
      FDropTrg.RedrawItem(false);
    end;
    Update;
  finally
    Source.ShowDragImage;
  end;
end;

function TElTreeView.GetItemAt;
var
  dX, i: integer;
  odx  : integer;
  io   : integer;
begin
  result := GetItemAtY(Y);
  ItemPart := ipInside;
  if Result = nil then exit;
  with FOwner do
  begin
    if RightAlignedTree then
    begin
      dX := X + FHPos;
      odx := dX;
      if FShowHeader then
        for i := 0 to FHeader.Sections.Count - 1 do
        begin
          begin
            dx := odx;
          end;
          if (dX >= FHeader.Sections[i].Left) and (dX < FHeader.Sections[i].Right) then
          begin
            HitColumn := i;
            if HitColumn <> FMainTreeCol then
            begin
              ItemPart := ipColumn;
              exit;
            end else
              break;
          end; // if
        end; // for
      if (dX >= Result.FTextLeft) and (dX <= Result.FTextRight + (ItemExt div 3)) then
      begin
        ItemPart := ipMainText;
        HitColumn := MainTreeColumn;
        exit;
      end; // else ItemPart := ipInside;
      if Result.FImageDrawn then
      begin
        i := Result.FTextRight + FImages.Width + (ItemExt div 3);
        if (dX >= i - FImages.Width) and (dX < i) then
        begin
          ItemPart := ipPicture;
          HitColumn := MainTreeColumn;
          exit;
        end
      end
      else
        i := Result.FTextRight + (ItemExt div 3);
      if Result.FImageDrawn2 then
      begin
        io := 0;
        if Result.FImageDrawn then
        begin
          inc(i, ItemExt div 3);
          io := ItemExt div 3;
        end;
        if FImages2 <> nil then
        begin
          inc(i, FImages2.Width);
          if (dX >= i - FImages2.Width) and (dX < i + io) then
          begin
            ItemPart := ipPicture2;
            HitColumn := MainTreeColumn;
            exit;
          end;
        end else
        begin
          inc(i, FImages.Width);
          if (dX >= i - FImages.Width) and (dX < i) then
          begin
            ItemPart := ipPicture;
            HitColumn := MainTreeColumn;
            exit;
          end;
        end;
      end;
      if FShowCheckBoxes and (Result.FShowCheckBox) then
      begin
        dec(i, 2);
        if FCustomCheckboxes then
        begin
          if Result.FCheckBoxType = ectRadioButton then
          begin
            if (dX >= i) and (dX < i + FRadioButtonGlyph.Width div 4) then
            begin
              ItemPart := ipCheckBox;
              HitColumn := MainTreeColumn;
              exit;
            end;
            inc(i, FRadioButtonGlyph.Width div 4);
          end else
          begin
            if (dX >= i) and (dX < i + FCheckBoxGlyph.Width div 6) then
            begin
              ItemPart := ipCheckBox;
              HitColumn := MainTreeColumn;
              exit;
            end;
            inc(i, FCheckBoxGlyph.Width div 6);
          end;
        end else
        begin
          if (dX >= i) and (dX < i + (ItemExt - 2)) then
          begin
            ItemPart := ipCheckBox;
            HitColumn := MainTreeColumn;
            exit;
          end;
          inc(i, ItemExt - 4);
        end;
      end;
      if not (ShowButtons) or (not (Result.HasVisibleChildren or Result.ForceButtons)) then exit;
      if (dX >= i) and (dX < i + ItemExt) then
      begin
        if Result.SuppressButtons then ItemPart := ipInside else ItemPart := ipButton;
        HitColumn := MainTreeColumn;
        exit;
      end;
    end
    else
    begin
      dX := X + FHPos;
      odx := dx;

      if FShowHeader then
        for i := 0 to FHeader.Sections.Count - 1 do
        begin
          begin
            dx := odx;
          end;
          if (dX >= FHeader.Sections[i].Left) and (dX < FHeader.Sections[i].Right) then
          begin
            HitColumn := i;
            if HitColumn <> FMainTreeCol then
            begin
              ItemPart := ipColumn;
              exit;
            end else
            begin
    //          dec(dX, FHeader.Sections[i].Left);
              break;
            end;
          end; // if
        end; // for
      if (dX >= Result.FTextLeft - (ItemExt div 3)) and (dX <= Result.FTextRight) then
      begin
        ItemPart := ipMainText;
        HitColumn := MainTreeColumn;
        exit;
      end; // else ItemPart := ipInside;
      if Result.FImageDrawn then
      begin
        i := Result.FTextLeft - FImages.Width - (ItemExt div 3);
        if (dX < i + FImages.Width) and (dX >= i) then
        begin
          ItemPart := ipPicture;
          HitColumn := MainTreeColumn;
          exit;
        end;
      end
      else
        i := Result.FTextLeft - (ItemExt div 3);
      if Result.FImageDrawn2 then
      begin
        io := 0;
        if Result.FImageDrawn then
        begin
          dec(i, ItemExt div 3);
          io := ItemExt div 3;
        end;
        if FImages2 <> nil then
        begin
          dec(i, FImages2.Width);
          if (dX < i + FImages2.Width + io) and (dX >= i) then
          begin
            ItemPart := ipPicture2;
            HitColumn := MainTreeColumn;
            exit;
          end;
        end else
        begin
          dec(i, FImages.Width);
          if (dX < i + FImages.Width) and (dX >= i) then
          begin
            ItemPart := ipPicture;
            HitColumn := MainTreeColumn;
            exit;
          end;
        end;
      end;
      if FShowCheckBoxes and (Result.FShowCheckBox) then
      begin
        inc(i, 2);
        if FCustomCheckboxes then
        begin
          if Result.FCheckBoxType = ectRadioButton then
          begin
            if (dX < i) and (dX >= i - FRadioButtonGlyph.Width div 4) then
            begin
              ItemPart := ipCheckBox;
              HitColumn := MainTreeColumn;
              exit;
            end;
            dec(i, FRadioButtonGlyph.Width div 4);
          end else
          begin
            if (dX < i) and (dX >= i - FCheckBoxGlyph.Width div 6) then
            begin
              ItemPart := ipCheckBox;
              HitColumn := MainTreeColumn;
              exit;
            end;
            dec(i, FCheckBoxGlyph.Width div 6);
          end;
        end else
        begin
          if (dX < i) and (dX >= i - (ItemExt - 2)) then
          begin
            ItemPart := ipCheckBox;
            HitColumn := MainTreeColumn;
            exit;
          end;
          dec(i, ItemExt - 4);
        end;
      end;
      if not (ShowButtons) or (not (Result.HasVisibleChildren or Result.ForceButtons)) then exit;
      if (dX < i) and (dX >= i - ItemExt) then
      begin
        if Result.SuppressButtons then ItemPart := ipInside else ItemPart := ipButton;
        HitColumn := MainTreeColumn;
        exit;
      end;
    end;
  end;
  ItemPart := ipInside;
end;

function TElTreeView.GetItemAtY(y: integer): TElTreeItem;
var
  i : integer;
  j : integer;
begin
  result := nil;
  if Y < 0 then exit;
  j := 0;
  for i := 0 to FVisible.Count - 1 do
  begin
    Inc(J, TElTreeItem(FVisible[i]).GetHeight);
    if Y < J then
    begin
      result := TElTreeItem(FVisible[i]);
      exit;
    end;
  end;
end;

function TElTreeView.GetItemRect;
var i, j : integer;
begin
  if (not InRange(0, FVisible.Count - 1, ItemIndex)) or (csDestroying in ComponentState) then
  begin
    SetRectEmpty(result);
    exit;
  end;
  j := 0;
  for i := 0 to ItemIndex - 1 do
    Inc(J, TElTreeItem(FVisible[i]).GetHeight);
  Result := Rect(0, j, Self.Width, j + TElTreeItem(FVisible[ItemIndex]).GetHeight - 1);
end;

procedure TElTreeView.ProcessPassedClick;
var Item,
    FS : TElTreeItem;
    FFS  : boolean;
begin
  Item := FPassedItem;
  FClickPassed := false;
  with FOwner do
    if FMultiSelect then IsUpdating := true;
  FFS := false;
  if (FOwner.FSelMode = smUsual) and (FOwner.FMultiSelect) then
  begin
    if (not (ssCtrl in FPassedShift)) and (not (ssShift in FPassedShift)) then
    begin
      with FOwner do
      begin
        if ItemFocused <> nil then FFS := ItemFocused.Selected;
        DeselectAll;
      end;
    end;
    if ssShift in FPassedShift then
    begin
      with FOwner do
      begin
        FS := FSelected;
        DeselectAll;
        if FS <> nil then
        begin
          FSelected := FS;
          FSelected.Selected := true;
        end;
        SelectRange2(Item, FSelected, false);
      end;
    end;
  end;
  with FOwner do
  begin
    if ItemFocused = Item then
    begin
      if (((not FFS) or (FOwner.FAlwaysKeepSelection)) and
         (FOwner.FSelMode = smUsual)) and (not Item.Selected) then
         DoSetSelected(Item)
    end
    else
      DoSetFocused(Item, false);
    if ((FMultiSelect) and (not (ssCtrl in FPassedShift)) and (not (ssShift in FPassedShift))) or
       (not FMultiSelect) and Item.AllowSelection then
        FSelected := Item;
{Soulsnake Add}
    // Added to keep selection when you do a simple click on item already selected
    if (not (ssCtrl in FPassedShift)) and (not (ssShift in FPassedShift))
      and (FMultiSelect) and (FOwner.FSelectedList.Count = 0) then
      DoSetSelected(Item);
{End Soulsnake Add}
  end;
  with FOwner do
    if FMultiSelect then
       IsUpdating := false;
  FOwner.DoAfterSelectionChange;
end;

procedure TElTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  FOldSelected,
  Item: TElTreeItem;
  SelList: TElList;
  FFS: boolean;
  //Form : TCustomForm;
{$ifdef ELTREE_USE_STYLES}
  Ctrl: TElCellControl;
  CX, CY: integer;
  i, j: integer;
{$endif}
  FOldSelcount : integer;
begin
  //Form := GetParentForm(Self);
  if FIgnoreClick then exit;
  FOwner.FSelChange := false;

  HCol := 0;
  Item := GetItemAt(X, Y, ItemPart, HCol);

{Soulsnake Add}
  if FOwner.PopupMenu <> nil then
    if ItemPart = ipCheckBox then
      FOwner.PopupMenu.AutoPopup := False
    else
      FOwner.PopupMenu.AutoPopup := True;
{End Soulsnake Add}

  if ((Item = nil) or (Item.Enabled))
{Soulsnake Add}
    and (ItemPart <> ipCheckBox) then
{End Soulsnake Add}
  begin
    //b := true;
    if (ItemPart = ipButton) and (ssRight in Shift) then
       ItemPart := ipMainText;
    if (ItemPart = ipButton) then
    begin
      if Item.Expanded then
        Item.Expanded := false
      else
      begin
        Item.Expanded := true;
        //FitMostChildren(Item);
      end;
      //b := false;
    end
    else if (ItemPart = ipColumn) then
    begin
{$ifdef ELTREE_USE_STYLES}
      i := HCol;
      j := i;
      if i > FOwner.FMainTreeCol then Dec(i);
      if Item.UseStyles and (Item.StylesCount > i) then
      begin
        CY := y;
        CX := x;
        with FOwner do
          cy := (cy div LineHeight) * LineHeight;
        if not Item.Styles[i].OwnerProps then
        begin
          Ctrl := Item.Styles[i].Control;
          if Ctrl <> nil then
          begin
            begin
              Ctrl.TriggerMouseDownEvent(Button, Shift, CX - FOwner.FHPos - FHeader.Sections[j].Left, CY);
              FClickControl := Ctrl;
            end;
            inherited;
            exit;
          end;
        end;
      end;
{$endif}
      if (not FHeader.Sections[HCol].ClickSelect) then exit;
    end;
    if (ssLeft in Shift) and (ItemPart <> ipButton) then
    begin
      with FOwner do
        if FMultiSelect then IsUpdating := true;
      if (Item <> nil) and ((ItemPart <> ipInside) or FOwner.FFullRowSelect) then
      begin
        with FOwner do
        begin
          if FMultiSelect then
             FOldSelcount := FSelectedList.Count
          else
          if FSelected <> nil then
             FOldSelCount := 1
          else {Eyal}
          if not FOwner.AlwaysKeepSelection then {Eyal}
             FOldSelCount := 0;
        end;    { with }
        if FOwner.MultiSelect and Item.Selected and (not (ssCtrl in Shift)) then
        begin
          FClickPassed := true;
          FPassedItem := Item;
          FPassedShift := Shift;
          FFS := Item.Selected;
          FOwner.DoSetFocused(Item, false);
          if (FFS or (FOwner.AlwaysKeepSelection)) then
          begin
            Item.Selected := (FOwner.FSelMode = smUsual);
          end;
        end else
        begin
          //FFS := false;
          if (FOwner.FSelMode = smUsual) and (FOwner.FMultiSelect) then
          begin
            if (not (ssCtrl in shift)) and (not (ssShift in shift)) then
            begin
              with FOwner do
              begin
                //if ItemFocused <> nil then FFS := ItemFocused.Selected;
                DeselectAll;
              end;
            end;
            if ssShift in shift then
            begin
              with FOwner do
              begin
                FOldSelected := FSelected;
                DeselectAll;
                FSelected := FOldSelected;
                if FSelected <> nil then
                   FSelected.Selected := true;
                SelectRange2(Item, FSelected, false);
                if ItemFocused <> Item then
                  Item.Selected := false;
              end;
            end else
            if ssCtrl in Shift then
            begin
              (*
              if Assigned(FOwner.ItemFocused) then
                 FFS := not FOwner.ItemFocused.Selected
              else
                 FFS := true;
              *)
            end;
          end;
          with FOwner do
          begin
            if ItemFocused = Item then
            begin
              if (not Item.Selected) or ((not FOwner.FAlwaysKeepSelection) or (FOldSelcount > 1)) then
                DoSetSelected(Item);
            end else if Item.AllowSelection then
              DoSetFocused(Item, false);
            if (((FMultiSelect) and (not (ssCtrl in shift)) and (not (ssShift in shift)))
              or (not FMultiSelect)) and Item.AllowSelection then
              FSelected := Item;
            // REMOVED !!!
            (*if ((ssCtrl in shift) and (FOldSelCount <= 1))
              and (FMultiSelect) and (FOwner.FSelectedList.Count = 0)
              {and FOwner.FAlwaysKeepSelection} then
              DoSetSelected(Item);*)
          end;
        end;
      end else // Eyal: (?) if FOwner.FMultiSelect or not FOwner.FAlwaysKeepSelection then {Eyal}
        if (Item = nil) and (not FOwner.FAlwaysKeepFocus) then
          FOwner.DoSetFocused(nil, false);
      with FOwner do
        if FMultiSelect then IsUpdating := false;
      if FOwner.FSelChange then
      begin
        FOwner.DoAfterSelectionChange;
        FOwner.FSelChange := false;
      end;
    end
    else if (ssRight in Shift) and FOwner.RightClickSelect then
    begin
      with FOwner do
      if FMultiSelect then
      begin
        IsUpdating := true;
        SelList := TElList.Create;
        AllSelected(SelList);
      end;

      if FOwner.MultiSelect and Assigned(Item) and Item.Selected then
      begin
        FFS := Item.Selected;
        FOwner.DoSetFocused(Item, false);
        if FFS or (FOwner.AlwaysKeepSelection) then Item.Selected := true;
      end else
{$WARNINGS off}
      with FOwner do
      if (not FMultiSelect) or (FMultiSelect and ((SelList.Count < 2) and (FSelMode = smUsual)) or (FSelMode = smSimple)) then
      begin
        if (Item <> nil) and ((ItemPart <> ipInside) or FFullRowSelect) then
        begin
          begin
            if (FSelMode = smUsual) and (FMultiSelect) then
            begin
              if (not (ssCtrl in shift)) and (not (ssShift in shift)) then
              begin
            //if ItemFocused <> nil then FFS := ItemFocused.Selected;
                DeselectAll;
              end;
              if ssShift in shift then
              begin
                DeselectAll;
                if FSelected <> nil then FSelected.Selected := true;
                SelectRange2(Item, FSelected, false);
              end;
            end;
            if (ItemFocused = Item) and (not Item.Selected) then
               DoSetSelected(Item)
            else
            if Item.AllowSelection and (ItemFocused <> Item) then
              DoSetFocused(Item, false);
            if ((FMultiSelect) and (not (ssCtrl in shift)) and (not (ssShift in shift)))
              or (not FMultiSelect) then
             FSelected := Item;
          end;
        end
        else // Eyal: (?) if FOwner.FMultiSelect or not FOwner.FAlwaysKeepSelection then {Eyal}

// WARNING!!!
          if (Item = nil) and (not FAlwaysKeepFocus) then
            DoSetFocused(nil, false);
// End of WARNING!!!
      end;
      with FOwner do
      if FMultiSelect then
      begin
        SelList.Free;
        IsUpdating := false;
      end;
      if FOwner.FSelChange then
      begin
        FOwner.DoAfterSelectionChange;
        FOwner.FSelChange := false;
      end;
    end;
    inherited;
  end;
end;
{$WARNINGS on}

procedure TElTreeView.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ItemPart: TSTItemPart;
  HCol: Integer;
  Item: TElTreeItem;
begin
  inherited;
  HCol := 0;
  Item := GetItemAt(X, Y, ItemPart, HCol);
  if (Item = nil) or (Item.Enabled) then
  begin
    if (ItemPart = ipCheckBox) then
{Soulsnake Add}
      if ((Button = mbLeft) and (not FOwner.InvertClickCheckboxes)) or
       ((Button = mbRight) and FOwner.InvertClickCheckboxes) then
{End Soulsnake Add}
      begin
        if not Item.Enabled then exit;
        if Item.CheckBoxEnabled then
        begin
          if Item.CheckBoxType = ect3SCheckBox then
          begin
            if Item.CheckBoxState = cbChecked then Item.CheckBoxState := cbUnchecked else
              if Item.CheckBoxState = cbUnchecked then Item.CheckBoxState := cbGrayed else
                Item.CheckBoxState := cbChecked;
          end
          else
            if Item.CheckBoxType = ectCheckBox then Item.Checked := not Item.Checked
            else Item.Checked := true;
          FOwner.DoItemChecked(Item);
          FOwner.DoItemChange(Item, icmCheckState);
        end;
      end
{Soulsnake Add}
      else if ((Button = mbRight) and (not FOwner.InvertClickCheckboxes)) or
       ((Button = mbLeft) and FOwner.InvertClickCheckboxes) then
        if(Item <> nil) {and Item.FUseCheckBoxColor} then
          FOwner.DoItemColorPick(Item);
{End Soulsnake Add}
    if FClickPassed then ProcessPassedClick;
  end;
end;
{$WARNINGS OFF}
procedure TElTreeView.KeyDown(var Key: Word; Shift: TShiftState);
type
  PGIRec = ^TGIRec;
  TGIRec = record
    i, oi,
    ni, PgCnt  : integer;
    TSI, OTSI  : TElTreeItem;
    Sel, fp    : boolean;
    NewFocused : TElTreeItem;
  end;
var
  GIRec: TGIRec;
  PrevSel,
  TSI, TSI1: TElTreeItem;
  OldSel, OldSel1: boolean;

  procedure IntNextVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    with PGIRec(IterateData)^ do
    begin
      if (OTSI = Tree.FView.FFocused) and (Item.Enabled) and Item.AllowSelection then
      begin
        Sel := Item.Selected;
        NewFocused := Item;
        i := Index;
        ContinueIterate := false;
      end;
      if Item = Tree.FView.FFocused then
         OTSI := Item;
    end;
  end;

  procedure IntPgVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    with PGIRec(IterateData)^ do
    begin
      if Item = Tree.FView.FFocused then
         oi := 1;
      if oi = 1 then
      begin
        if Item.Enabled then
        begin
          dec(PgCnt);
          NewFocused := Item;
        end;

        TSI := Item;
        Sel := Item.Selected;
        i := Index;
      end;
      if PgCnt < 0 then
      begin
        ContinueIterate := false;
      end;
    end;
  end;

  procedure IntVis0(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    with PGIRec(IterateData)^ do
    begin
      if Item.Enabled then
      begin
        Sel := Item.Selected;
        NewFocused := Item;
        i := 0;
        ContinueIterate := false;
      end;
    end;
  end;

  (*
  procedure IntNextVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if (PGIRec(IterateData)^.OTSI = Tree.FView.FFocused) and (Item.Enabled) then
    begin
      PGIRec(IterateData)^.Sel := Item.Selected;
      PGIRec(IterateData)^.NewFocused := Item;
      PGIRec(IterateData)^.i := Index;
      ContinueIterate := false;
    end;
    if Item = Tree.FView.FFocused then
       PGIRec(IterateData)^.OTSI := Item;
  end;

  procedure IntPgVis(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if Item = Tree.FView.FFocused then
       PGIRec(IterateData)^.oi := 1;
    if PGIRec(IterateData)^.oi = 1 then
    begin
      if Item.Enabled then
      begin
        dec(PGIRec(IterateData)^.PgCnt);
        PGIRec(IterateData)^.NewFocused := Item;
      end;

      PGIRec(IterateData)^.TSI := Item;
      PGIRec(IterateData)^.Sel := Item.Selected;
      PGIRec(IterateData)^.i := Index;
    end;
    if PGIRec(IterateData)^.PgCnt < 0 then
    begin
      ContinueIterate := false;
    end;
  end;

  procedure IntVis0(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if Item.Enabled then
    begin
      PGIRec(IterateData)^.Sel := Item.Selected;
      PGIRec(IterateData)^.NewFocused := Item;
      PGIRec(IterateData)^.i := 0;
      ContinueIterate := false;
    end;
  end;
  *)

var
  NewFocused: TElTreeItem;

begin
  inherited;
  if not (csNoStdEvents in ControlStyle) then
  begin
    (*
    if FOwner.FIncrementalSearch and (Shift = []) then
    begin
      if ProcessSearch(Char(Key)) then exit;
    end;
    *)

    FOwner.FSelChange := false;

    with FOwner do
      if FMultiSelect then IsUpdating := true;
    TSI := nil;
    TSI1 := nil;
    NewFocused := nil;
    OldSel := false;
    OldSel1 := false;

    if (ssCtrl in shift) and (ssShift in shift) then Shift := Shift - [ssCtrl];
    if (ssShift in shift) and (Key = Ord('8')) then
    begin
      if (FFocused <> nil) and (FFocused.Enabled) and (FFocused.HasVisibleChildren or FFocused.ForceButtons) then FFocused.Expand(true);
    end
    else
    case Key of //
      VK_BACK:
        if (FFocused <> nil) and (FFocused.Parent <> nil) and (FFocused.Parent.Enabled) then
        begin
          FOwner.DoSetFocusedEx(FFocused.Parent, false, true);
          FOwner.EnsureVisible(FOwner.ItemFocused);
        end;
      VK_ADD:
        if (FFocused <> nil) and (FFocused.HasVisibleChildren or FFocused.ForceButtons) and
           (not (FFocused.Expanded)) and (FFocused.Enabled) then
        begin
          FFocused.Expanded := true;
          //FitMostChildren(FFocused);
        end;
      VK_SUBTRACT:
        if (FFocused <> nil) and (FFocused.Enabled) and (FFocused.Expanded) then
           FFocused.Expanded := false;
      VK_MULTIPLY:
        if (FFocused <> nil) and (FFocused.Enabled) and
           (FFocused.HasVisibleChildren or FFocused.ForceButtons) then
           begin
             FFocused.Expand(true);
             //FitMostChildren(FFocused);
           end;
      VK_DIVIDE:
        if (FFocused <> nil) and (FFocused.Enabled)then
           FFocused.Collapse(true);
{Original}
      //VK_SPACE:
{End Original}
{Soulsnake Mod}
      VK_RETURN:
{End Soulsnake Mod}
        if (FFocused <> nil) and (FFocused.Enabled) and (FOwner.FMultiSelect) then
        begin
          if (not (ssCtrl in shift)) and (not (ssShift in shift)) and (FOwner.FSelMode = smUsual) then
          begin
            FOwner.DeselectAll;
            FSelected := FFocused;
          end;
          if FOwner.FSelMode = smSimple then
            FSelected := FFocused;
{Original}
          //FFocused.Selected := not (FFocused.Selected);
          //FOwner.DoAfterSelectionChange;
{End Original}
{Soulsnake Fix}
          FFocused.SetSelected(not (FFocused.Selected));
{End Soulsnake Fix}
        end;
      VK_HOME,
      VK_END,
      VK_PRIOR,
      VK_NEXT,
      VK_LEFT,
      VK_RIGHT,
      VK_UP,
      VK_DOWN:
        begin
          if FOwner.RightAlignedTree then
          begin
            if Key = VK_LEFT then
              Key := VK_RIGHT
            else
              if Key = VK_RIGHT then
                Key := VK_LEFT;
          end;
          if Key = VK_LEFT then
            if (FFocused <> nil) and FFocused.Expanded and (FFocused.Enabled) then
            begin
              FFocused.Expanded := false;
              with FOwner do
                if FMultiSelect then IsUpdating := false;
              exit;
            end;
          if Key = VK_RIGHT then
            if (FFocused <> nil) and (not (FFocused.Expanded)) and (FFocused.Enabled) and (FFocused.HasVisibleChildren or FFocused.ForceButtons) then
            begin
              FFocused.Expanded := true;
              //FitMostChildren(FFocused);
              with FOwner do
                if FMultiSelect then IsUpdating := false;
              exit;
            end;
          GIRec.OTSI := nil;
          GIRec.TSI := nil;
          GIRec.i := 0;
          GIRec.NewFocused := nil;
          with FOwner do
          if FMultiSelect then
          begin
            if ((ssCtrl in Shift) and (FSelMode = smUsual)) or (FSelMode = smSimple) then
            begin
              TSI := FFocused;
              if TSI <> nil then
                 OldSel := TSI.Selected
              else
                 OldSel := false;
            end;
            if (ssShift in Shift) then
            begin
              TSI1 := FSelected;
              if TSI1 <> nil then
                 OldSel1 := TSI1.Selected
              else
                 OldSel1 := false;
            end;
            PrevSel := FSelected;
            if (FSelMode = smUsual) and (not (ssCtrl in shift)) then
               DeselectAll;
          end;
          if Key = VK_UP then
          begin
            if FFocused = nil then
            begin
              if FOwner.TotalVisCount > 0 then
              begin
                FItems.Iterate(true, @IntVis0, @GIRec);
                NewFocused := GIRec.NewFocused;
              end else
              begin
                with FOwner do
                  if FMultiSelect then
                    IsUpdating := false;
                exit;
              end;
            end
            else //FItems.Iterate(true,@IntPrevVis,@GIRec);
            begin
              FItems.IterateBack(true, @IntNextVis, @GIRec);
              if GIRec.NewFocused <> nil then
                NewFocused := GIRec.NewFocused
              else
                NewFocused := FFocused;
            end;
          end
          else
          if Key = VK_DOWN then
          begin
            if FFocused = nil then
            begin
              if FOwner.TotalVisCount > 0 then
              begin
                FItems.Iterate(true, @IntVis0, @GIRec);
                NewFocused := GIRec.NewFocused;
              end else
              begin
                with FOwner do
                  if FMultiSelect then
                    IsUpdating := false;
                exit;
              end;
            end else
            begin
              FItems.Iterate(true, @IntNextVis, @GIRec);
              if GIRec.NewFocused <> nil then
                NewFocused := GIRec.NewFocused
              else
                NewFocused := FFocused;
            end;
          end
          else
          if Key = VK_Left then
          begin
            NewFocused := FFocused;
            if (FFocused <> nil) and (FFocused.Parent <> nil) then
              if FFocused.Parent <> nil then
                NewFocused := FFocused.Parent
              else
                NewFocused := FFocused;
          end
          else
          if Key = VK_Right then
          begin
            NewFocused := FFocused;
            if (FFocused <> nil) and (FFocused.GetFirstVisibleChild <> nil) then
            begin
              FOwner.IsUpdating := true;
              NewFocused := FFocused.GetFirstVisibleChild;
              if NewFocused = nil then NewFocused := FFocused;
              FOwner.FUpdated := true;
              FRangeUpdate := true;
              FOwner.IsUpdating := false;
            end;
          end else
          if Key = VK_NEXT then
          begin
            if FOwner.TotalVarHeightCount > 0 then
               GIRec.PgCnt := CalcPageDownPos(FOwner.FTopIndex) - FOwner.FTopIndex
            else
               GIRec.PgCnt := GetVisCount - 1;

            GIRec.oi := 0;
            GIRec.NewFocused := nil;
            if FFocused <> nil then
               FItems.IterateFrom(true, @IntPgVis, @GIRec, FOwner.ItemFocused);
            if GIRec.NewFocused <> nil then
              NewFocused := GIRec.NewFocused else
              NewFocused := FFocused;
          end else
          if Key = VK_PRIOR then
          begin
            if FFocused = nil then
            begin
              if FOwner.TotalVarHeightCount > 0 then
                 GIRec.PgCnt := FOwner.FTopIndex - CalcPageUpPos(FOwner.FTopIndex)
              else
                 GIRec.PgCnt := GetVisCount - 1;
            end else
            begin
              GIRec.oi := FFocused.VisIndex;
              if FOwner.TotalVarHeightCount > 0 then
                 GIRec.PgCnt := GIRec.oi - CalcPageUpPos(GIRec.oi)
              else
                 GIRec.PgCnt := GetVisCount - 1;
            end;
            GIRec.oi := 0;
            GIRec.NewFocused := nil;

            if FFocused <> nil then
               FItems.IterateBackFrom(true, @IntPgVis, @GIRec, FOwner.ItemFocused);
            if GIRec.NewFocused <> nil then
              NewFocused := GIRec.NewFocused
            else
              NewFocused := FFocused;
          end
          else
          if Key = VK_HOME then
          begin
            if FFocused <> nil then
            begin
              FItems.Iterate(true, @IntVis0, @GIRec);
              NewFocused := GIRec.NewFocused;
              GIRec.i := 0;
              if NewFocused = nil then
              begin
                with FOwner do
                begin
                  NewFocused := ItemFocused;
                  GIRec.i := FTopIndex;
                end;
              end;
            end;
          end
          else
          if Key = VK_END then
          begin
            if FFocused <> nil then
            with FOwner do
            begin
              GIRec.i := TotalVisCount - 1;
              NewFocused := FItems.GetVisItem(GIRec.i);
              while (NewFocused <> nil) and (not NewFocused.Enabled) do
              begin
                dec(GIRec.i);
                if GIRec.i >= 0 then
                   NewFocused := FItems.GetVisItem(GIRec.i);
              end;
              if NewFocused = nil then
              begin
                NewFocused := ItemFocused;
                GIRec.i := FTopIndex;
              end;
            end;
          end;
          if FOwner.FMultiSelect then
          begin
            if ((ssCtrl in Shift) and (FOwner.FSelMode = smUsual)) or (FOwner.FSelMode = smSimple) then
            begin
              if TSI <> nil then TSI.Selected := OldSel;
               //if FFocused<>TSI then FFocused.Selected:=GIRec.Sel;
            end;
            if ssShift in shift then
            begin
              if TSI1 <> nil then
                TSI1.Selected := OldSel1;
              FOwner.SelectRangeEx2(TSI1, NewFocused, false, false);
               //if FFocused <> nil then FFocused.Selected:=true;
            end;
          end;
          if NewFocused <> nil then
          begin
            if FOwner.FMultiSelect then
            begin
              if ((ssCtrl in Shift) and (FOwner.FSelMode = smUsual)) or (FOwner.FSelMode = smSimple) then
              begin
              if NewFocused <> TSI then
                NewFocused.Selected := not GIRec.Sel;
              end;
              if ssShift in shift then
              begin
                if FFocused <> NewFocused then
                begin
                  NewFocused.Selected := false;
                  if (PrevSel <> nil) and (PrevSel <> NewFocused) then
                    PrevSel.Selected := true;
                end;
              end;
            end;
            if FFocused <> NewFocused then
            begin
              FOwner.DoSetFocusedEx(NewFocused, false, true);
              if FOwner.FMultiSelect then
                 FSelected := PrevSel;
            end
            else
            begin
              if FOwner.FMultiSelect then
                FSelected := PrevSel;
{Soulsnake Fix}
              //NewFocused.Selected := true;
{End Soulsnake Fix}
            end;
          end;
          if (not ((ssCtrl in shift) or (ssShift in shift))) or
             (not FOwner.FMultiSelect) then
          begin
            if FFocused <> nil then
              FSelected := FFocused;
            if (FFocused <> nil) and (not ((FOwner.FMultiSelect) and (FOwner.FSelMode = smSimple))) and (FOwner.FMultiSelect) then
              FFocused.Selected := true;
          end;
          if (FFocused <> nil) and ((FVisible.IndexOf(FFocused) = -1) {or xx}) then
          begin
            if Key = VK_UP then
            begin
              SetVPosition(GIRec.i);
            end else
            if Key = VK_DOWN then
            begin
              //FOwner.EnsureVisibleBottom(FItems.GetVisItem(GIRec.i));
              if FOwner.TotalVarHeightCount > 0 then
                 SetVPosition(CalcPageUpPos(GIRec.i))
              else
                 SetVPosition(GIRec.i - (GetVisCount - 2));
            end else
            if Key = VK_Left then
            begin
              SetVPosition(FFocused.VisIndex);
            end else
            if Key = VK_Right then
            begin
              FOwner.EnsureVisibleBottom(FItems.GetVisItem(GIRec.i));
              //SetVPosition(GIRec.i - (GetVisCount - 2));
            end else
            if Key = VK_PRIOR then
            begin
              if FOwner.TotalVarHeightCount > 0 then
                   SetVPosition(CalcPageUpPos(FOwner.FTopIndex))
                else
                   SetVPosition(FOwner.FTopIndex - (GetVisCount - 1));
            end else
            if Key = VK_NEXT then
            begin
              if FOwner.TotalVarHeightCount > 0 then
                 SetVPosition(CalcPageDownPos(FOwner.FTopIndex))
              else
                 SetVPosition(FOwner.FTopIndex + (GetVisCount - 1));
            end
            else
            if KEY = VK_Home then
            begin
              SetVPosition(0);
            end else
            if KEY = VK_End then
            begin
              SetVPosition(FOwner.TotalVisCount - 1);
            end;
            FClearVis := true;
            FClearAll := true;
          end;
        end;
    end; // case
    with FOwner do
      if FMultiSelect then
        IsUpdating := false;
    if FOwner.FSelChange then
    begin
{Soulsnake Add (optimisation)}
      if not (FOwner.FMultiSelect and (shift = [ssCtrl]) and ((KEY = VK_DOWN) or (KEY = VK_UP))) then
{End Soulsnake Add (optimisation}
      FOwner.DoAfterSelectionChange;
      FOwner.FSelChange := false;
    end;
  end;
end;

{$WARNINGS ON}
procedure TElTreeView.KeyPress(var Key: Char);
begin
  if not (csNoStdEvents in ControlStyle) then
  begin
    if FOwner.FIncrementalSearch and ProcessSearch(Key) then exit;
  end;
  inherited;
end;

procedure TElTreeView.DoSetSelected;
begin
  if (value <> nil) and (not value.AllowSelection) then exit;

  if FOwner.FMultiSelect then
  begin
    if Value <> nil then with Value do
    begin
      if (FIState and tisSelected) > 0 then
      begin
        FOwner.FSelChange := true;
        Exclude(FState, stsSelected);
        FIState := FIState and (not tisSelected);
        FOwner.FSelectedList.Remove(Value);
{Original}
        //if FSelected = Value then
        //   FSelected := nil;
{End Original}
{Soulsnake Fix}
        if (FSelected = Value) then
          FSelected := TElTreeItem(FOwner.FSelectedList.First);
        // Code after is not good for all functions (e.g. KeyDown: CTRL+KEYDOWN/KEYUP DOESN'T WORKS)
        // So I remove it and it works great like this anymore.
        {if (FFocused = Value) and (FSelected <> nil) then
        begin
          FFocused := FSelected;
          Exclude(Value.FState, stsFocused);
          Value.RedrawItem(true);
          Include(FFocused.FState, stsFocused);
          FFocused.RedrawItem(true);
        end;}
{End Soulsnake Fix}
      end
      else
      begin
        FOwner.FSelChange := true;
        Include(FState, stsSelected);
        FIState := FIState or tisSelected;
        FOwner.FSelectedList.Add(Value);
{Soulsnake Fix}
        if FOwner.FSelectedList.Count = 1 then
          FSelected := Value;
{End Soulsnake Fix}
      end;
      FOwner.TriggerItemSelectedChangeEvent(Value);
      Value.UpdateItem;
    end
  end
  else
  begin
    if Self.FSelected <> nil then with FSelected do
    begin
      FOwner.FSelChange := true;
      Exclude(FState, stsSelected);
      FIState := FIState and (not tisSelected);
      FSelected.UpdateItem;
      FOwner.TriggerItemSelectedChangeEvent(Self.FSelected);
      FSelected := nil;
    end;
    if Value <> nil then with value do
    begin
      FOwner.FSelChange := true;
      Include(FState, stsSelected);
      FIState   := FIState or tisSelected;
      FSelected := Value;
      FOwner.TriggerItemSelectedChangeEvent(Value);
      Value.UpdateItem;
    end;
  end;
end;

function TElTreeView.GetVisCount;
var
  j: integer;
  CliHeight: integer;

begin
  CliHeight := Height;
  j := FOwner.FLineHeight;
  result := CliHeight div j;
  if ((CliHeight mod j) > 0) then inc(result);
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TElTreeView.DoEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  FOwner.NotifyOnEditKeyDown(Sender,Key,Shift);
  if Shift = [] then
  begin
    if Key = VK_Return then
    begin
      DoEndEdit(false);
      Key := 0;
    end;
    if Key = VK_Escape then
    begin
      DoEndEdit(True);
      Key := 0;
    end;
  end;
end;
{$endif}

procedure TElTreeView.CMMouseLeave;
var
  TSI:  TElTreeItem;
begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if assigned(FInpEdit) and FInpEdit.Visible then exit;
{$endif}
  TSI := FTrackItem;
  FTrackItem := nil;
  FTrackSection := nil;
  if TSI <> nil then
  begin
    TSI.RedrawItem(true);
    Update;
  end;
  FHintItemEx := nil;
  // Destroy Hint timer
  DoHideLineHint;
{$ifdef ELTREE_USE_STYLES}
  if FClickControl <> nil then
  begin
    FClickControl.TriggerMouseUpEvent(mbLeft, ElVCLUtils.GetShiftState, -1, -1);
    FClickControl := nil;
  end;
{$endif}
  inherited;
end;

procedure TElTreeView.CMHintShow(var Msg : TMessage);
var
  HintInfo : PHintInfo;
  Item     : TElTreeItem;
  IP       : TSTItemPart;
  HCol     : integer;
begin
  HintInfo := PHintInfo(Msg.lParam);
  Item := GetItemAt(HintInfo.CursorPos.X, HintInfo.CursorPos.Y, IP, HCol);
  if (Item <> nil) and (Item.Hint <> '') then
     HintInfo.HintStr := Item.Hint;
  FHintItemEx := Item;
end;

procedure TElTreeView.CMSysColorChange(var Msg: TMessage);
begin
  inherited;
  Invalidate;//Repaint;
end;

procedure TElTreeView.WMSetFocus(var Msg : TWMSetFocus);  { private }
begin
  inherited;
  with FOwner do
    if Flat or FUseCustomBars then UpdateFrame;
end;  { WMSetFocus }

procedure TElTreeView.WMKillFocus(var Msg : TWMKillFocus);  { private }
begin
  FPressed := false;
  inherited;
  FHintItemEx := nil;
  DoHideLineHint;
  with FOwner do
    if Flat or FUseCustomBars then UpdateFrame;
end;  { WMKillFocus }

{$IFDEF VCL_4_USED}
function TElTreeView.GetDragImages: TDragImageList;
{$ELSE}
function TElTreeView.GetDragImages: TCustomImageList;
{$ENDIF}
begin
  if (FDragImages <> nil) and (FDragImages.Count > 0) then
     Result := FDragImages
  else
     result := nil;
end;

procedure TElTreeView.DoEnter;
begin
  inherited;
  if FOwner.FHideSelect then
  begin
    Invalidate;
    //Repaint;
  end;
end;

procedure TElTreeView.DoExit;
begin
  inherited;
  if FOwner.FHideSelect then
    Invalidate;
end;

procedure TElTreeView.UpdateView;
var
  R: TRect;
begin
  if (not HandleAllocated) then
  begin
    FOwner.FUpdated := true;
    exit;
  end;
  if FOwner.FUpdating then FOwner.FUpdated := true else
  begin
    if FRangeUpdate or (FClearAll) then
    begin
      if (FOwner.FVLines and FOwner.FShowHeader) or (FClearAll) then
      begin
        R := ClientRect;
        FClearAll := false;
      end
      else
        R := Rect(0, 0, ClientWidth, GetVisiblesHeight);
      InvalidateRect(Handle, @R, true);
      FRangeUpdate := false;
    end;
    //TODO: Update;
  end;
end;

procedure TElTreeView.WMPaint(var Msg : TWMPaint);  { private }
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  R : TRect;
  ARgn : HRGN;

    procedure DoPaintBkgnd(DC : HDC; ClipRect : TRect);
    var
      AClipRect: TRect;
{$IFDEF ELPACK_COMPLETE}
      AForm : TCustomForm;
      R1,
{$ENDIF}
      BgRect
              : TRect;
    begin
      Canvas.Brush.Color := FOwner.BkColor;
      BgRect := ClientRect;
      Inc(BgRect.Bottom);
      Inc(BgRect.Right);
      AClipRect := ClipRect;
      {$IFDEF ELPACK_COMPLETE}
      if (FOwner.FImgForm <> nil) and (not (csDesigning in ComponentState)) then
      begin
        AForm := GetParentForm(Self);
        R1 := BgRect;
        BgRect.TopLeft := ClientToScreen(BgRect.TopLeft);
        BgRect.BottomRight := ClientToScreen(BgRect.BottomRight);
        BgRect.TopLeft := AForm.ScreenToClient(BgRect.TopLeft);
        BgRect.BottomRight := AForm.ScreenToClient(BgRect.BottomRight);

        FOwner.FImgForm.PaintBkgnd(DC, R1, BgRect.TopLeft, false);
      end
      else
      {$ENDIF}
      begin
        FillRect(DC, AClipRect, Canvas.Brush.Handle);
      end;
    end;

{$IFDEF SPEED_TEST}
var TickCount : integer;
{$ENDIF}
begin
{$IFDEF SPEED_TEST}
  TickCount := GetTickCount;
{$ENDIF}
  //if not FOwner.IsUpdating then
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

        with R do
          ARgn := CreateRectRgn(Left, Top, Right, Bottom);
        SelectClipRgn(MemDC, ARgn);

        DoPaintBkgnd(MemDC, R);

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
  end;
{$IFDEF SPEED_TEST}
  TickCount := GetTickCount - TickCount;
  SendDebug('Redrawing time: ' + IntToStr(TickCount) + ' msec');
{$ENDIF}
end;

function TElTreeView.GetVisCount2: Integer;
var
  j: integer;
  CliHeight: integer;

begin
  CliHeight := Height;
  j := FOwner.FLineHeight;
  result := CliHeight div j;
end;

procedure TElTreeView.OnDragExpandTimer(Sender : TObject);
begin
  FDragExpandTimer.Enabled := false;
  if (FDropTrg <> nil) and (not FDropTrg.Expanded) and (FDropTrg.HasVisibleChildren) then
  begin
    if FOwner.FDragObject <> nil then
      FOwner.FDragObject.HideDragImage;
    FDropTrg.Expand(false);
    Update;
    if FOwner.FDragObject <> nil then
      FOwner.FDragObject.ShowDragImage;
  end;
end;

function TElTreeView.ProcessSearch(Key : Char): Boolean;
var
  liSearchTextLength,
    liIndex : Integer ;
    AnItem  : TElTreeItem;
begin
  Result := false;
  if (Key = #27) then
  begin
    SearchText := '' ;
    FOwner.DeselectAll ;
    Exit
  end
  else
    if (Key = #8) then
    begin
      if (SearchText > '') then
        SetLength(SearchText, Length(SearchText) - 1);
    end
    else
      if (Key > #32) then
        SearchText := SearchText + Key
      else
        Exit ;

  if (SearchText > '') then
  begin
    liSearchTextLength := Length (SearchText) ;

    for liIndex := 0 to (FOwner.Items.Count - 1) do
    begin
      AnItem := FOwner.Items [liIndex];
      if AnsiSameText(SearchText, Copy (AnItem.Text, 1, liSearchTextLength)) then
      begin
        FOwner.EnsureVisible(AnItem);
{Original}
        //AnItem.Focused := True;
        //AnItem.Selected := False;
{End Original}
{Soulsnake Fix}
        if AnItem.Selected then
        begin
          if not AnItem.Focused then
          begin
            AnItem.Focused := True;
            AnItem.Selected := True;
            FFocused := AnItem;
            FSelected := AnItem;
          end;
        end
        else
        begin
          AnItem.Focused := True;
          AnItem.Selected := False;
          FFocused := AnItem;
        end;
{End Soulsnake Fix}
        break;
      end ;
    end;
    StartClearSearchTimeoutThread;
  end;
end;

procedure TElTreeView.StartClearSearchTimeoutThread ;
begin
  if Assigned (SearchTextTimeoutThread) then
    TSearchTextTimeoutThread(SearchTextTimeoutThread).KeepAlive := True
  else
  begin
    SearchTextTimeoutThread := TSearchTextTimeoutThread.Create ;
    SearchTextTimeoutThread.OnTerminate := SearchTextTimeout ;
    SearchTextTimeoutThread.Resume
  end
end ;

procedure TElTreeView.StopClearSearchTimeoutThread ;
begin
  if Assigned (SearchTextTimeoutThread) then
  begin
    SearchTextTimeoutThread.OnTerminate := nil ;
    SearchTextTimeoutThread.Terminate ;

    SearchTextTimeoutThread := nil
  end
end ;

procedure TElTreeView.SearchTextTimeout (Sender : TObject) ;
begin
  SearchTextTimeoutThread := nil ;
  SearchText := ''
end;

procedure TElTreeView.FitMostChildren(Item : TElTreeItem);
var
  R: TRect;
  i,
  k,
  ch,
  cti : integer;
  oi  : integer;
  TopItem: TElTreeItem;

begin
  if Item.FullyExpanded and Item.FullyVisible and (FOwner.IsInView(Item)) then
  begin
    k := Item.CalcSubItemsHeight;
    TopItem := FOwner.GetTopItem();
    if TopItem <> nil then
    begin
      cti := TopItem.VisIndex;
      oi  := Item.VisIndex;
      R   := FOwner.GetItemRect(FVisible.IndexOf(Item));
      i   := 0;
      ch := ClientHeight;
      if cti < oi then
      begin
        while (cti < oi) do
        begin
          if FVisible.Count <= i then
            break;
          if R.Bottom + k >= ch then
          begin
			      Dec(R.Bottom,  FOwner.LineHeight);
            inc(i);
            Inc(cti);
          end
          else
          begin
            break;
          end;
        end;
        FOwner.GetTotalVisCount;
        FOwner.TopIndex := FOwner.TopIndex + i;
      end;
    end;
  end;
end;

// ****************************************************************************
//                                   TElTreeItem       
// ****************************************************************************

constructor TElTreeItem.Create(AOwner: TCustomElTree);
begin
  inherited Create;
  FOwner := AOwner;
  FColText := TStringList.Create;
  FColText.OnChange := OnColTextChange;
  FParentColors := true;
  FParentStyle := true;
  FState := [];
  FImageIndex := -1;
  FStImageIndex := -1;
  FImageIndex2 := -1;
  FStImageIndex2 := -1;
  FForceButtons := False;
{$ifdef ELTREE_USE_STYLES}
  FMainStyle := TElCellStyle.Create(Self);
  FMainStyle.FOwnerProps := true;
{$endif}
  FCheckBoxState := cbUnchecked;
  FShowCheckBox := false;
  FCheckBoxType := ectCheckBox;
  FCheckBoxEnabled := true;
  FUseCheckBoxColor := False;
  FCheckBoxColor := $FFFFFF;
  FCheckColor := $000000;
  FSuppressButtons := False;
  FEnabled := True;
  FUseBkColor := true;
  FDrawHLine := true;
  FAllowSelection := true;
  FAllowEdit := true;  
end;

destructor TElTreeItem.Destroy;
begin
  if (FOwner <> nil) and ((FIState and tisSelected) > 0) then
  begin
    with FOwner do
    begin
      if FMultiSelect then FSelectedList.Remove(Self);
    end;
  end;
  FColText.Free;
  if FChildren <> nil then FChildren.Free;
{$ifdef ELTREE_USE_STYLES}
  FMainStyle.Free;
  if FStyles <> nil then FStyles.Free;
{$endif}
  FDataInterface := nil;
{$IFDEF HAS_HTML_RENDER}
  IsHTML := false;
{$ENDIF}
  inherited Destroy;
end;

procedure TElTreeItem.CreateStyles;
begin
  FStyles := TElList.Create;
  FStyles.OnDelete := OnStyleDelete;
end;

procedure TElTreeItem.OnStyleDelete(Sender: TObject; Item: pointer);
begin
  TElCellStyle(Item).Free;
end;

type

  TS28aItemInfo = record
    FState       : TSTIStates;
    FImageIndex  : integer;
    FStImageIndex: integer;
    ForceButtons : LongBool;
    FColor,
    FRowBkColor,
      FBkColor   : TColor;
    FParentColors: boolean;
    FParentStyle : boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
    FImageIndex2: integer;
    FStImageIndex2: integer;
    FEnabled: boolean;
    FHidden: boolean;
    FUseBkColor : boolean;
{$IFDEF HAS_HTML_RENDER}
    FIsHTML   : boolean;
{$ENDIF}
  end;

  TS28ItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
    FImageIndex2: integer;
    FStImageIndex2: integer;
    FEnabled: boolean;
    FHidden: boolean;
{$IFDEF HAS_HTML_RENDER}
    FIsHTML   : boolean;
{$ENDIF}
  end;

  TS27ItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
    FImageIndex2: integer;
    FStImageIndex2: integer;
    FEnabled: boolean;
    FHidden: boolean;
{$IFDEF ELPACK_COMPLETE}
    FIsHTML   : boolean;
{$ENDIF}
  end;

  TS26ItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
    FImageIndex2: integer;
    FStImageIndex2: integer;
    FEnabled: boolean;
    FHidden: boolean;
  end;

  TSItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
    FImageIndex2: integer;
    FStImageIndex2: integer;
    FEnabled: boolean;
  end;

  TS22ItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    b, c: integer;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
  end;

  TS20ItemInfo = record
    FState: TSTIStates;
    FImageIndex: integer;
    FStImageIndex: integer;
    ForceButtons: LongBool;
    FColor,
      FBkColor: TColor;
    FParentColors: boolean;
    FParentStyle: boolean;
    FCheckBoxEnabled: Boolean;
    FCheckBoxState: TCheckBoxState;
    FShowCheckBox: Boolean;
    FCheckBoxType: TElCheckBoxType;
  end;

  PStyleInfo = ^TStyleInfo;
  TStyleInfo = record
    FCellBkColor: TColor;
    FTextBkColor: TColor;
    FTextColor: TColor;
    FTextFlags: DWORD;
    FPicture: TBitmap;
    FCellType: TFieldTypes;
    FStyle: TElSectionStyle;
    FOwnerProps: Boolean;
    FFontSize: integer;
    FFontStyles: TFontStyles;
    FTag: integer;
  end;

procedure StateSetToStateInt(FState : TSTIStates; var FIState : Integer);
begin
  FIState := 0;
  if stsFocused in FState then FIState := FIState or tisFocused else FIState := FIState and (not tisFocused);
  if stsSelected in FState then FIState := FIState or tisSelected else FIState := FIState and (not tisSelected);
  if stsCut in FState then FIState := FIState or tisCut else FIState := FIState and (not tisCut);
  if stsExpanded in FState then FIState := FIState or tisExpanded else FIState := FIState and (not tisExpanded);
  if stsBold in FState then FIState := FIState or tisBold else FIState := FIState and (not tisBold);
  if stsItalic in FState then FIState := FIState or tisItalic else FIState := FIState and (not tisItalic);
  if stsUnderlined in FState then FIState := FIState or tisUnderlined else FIState := FIState and (not tisUnderlined);
  if stsStrikeOut in FState then FIState := FIState or tisStrikeOut else FIState := FIState and (not tisStrikeOut);
end;

procedure TElTreeItem.ReadData(Stream: TStream);
var
  i, j, k: integer;
  s: string;
  t: TSItemInfo;
{$IFNDEF ELPACK_COMPLETE}
{$ENDIF}
  t28  : TS28ItemInfo;
  t28a : TS28aItemInfo;
  t20  : TS20ItemInfo;
  t26  : TS26ItemInfo;
  ver  : integer;
{$ifdef ELTREE_USE_STYLES}
  SI   : TStyleInfo;
  Style: TElCellStyle;
{$endif}
  b    : boolean;
begin
  Stream.ReadBuffer(k, SizeOf(k));
  Ver := 0;
  if k < 0 then
  begin
    ver := k;
    Stream.ReadBuffer(k, SizeOf(k));
  end;
  SetLength(s, k);
  Stream.ReadBuffer(pchar(s)^, k);
  FText := s;
  if Ver = -3 then
  begin
    Stream.ReadBuffer(T20, SizeOf(T20));
    FState := T20.FState - [stsFocused, stsSelected];
    StateSetToStateInt(FState, FIState);
    FColor := T20.FColor;
    FBkColor := T20.FBkColor;
    FImageIndex := T20.FImageIndex;
    FStImageIndex := T20.FStImageIndex;
    FParentColors := T20.FParentColors;
    FParentStyle := T20.FParentStyle;
    FForceButtons := T20.ForceButtons;
    FCheckBoxEnabled := T20.FCheckBoxEnabled;
    FCheckBoxState := T20.FCheckBoxState;
    FShowCheckBox := T20.FShowCheckBox;
    FCheckBoxType := T20.FCheckBoxType;
  end else
    if Ver = -4 then
    begin
      Stream.ReadBuffer(T, SizeOf(T));
      FState := T.FState - [stsFocused, stsSelected];
      StateSetToStateInt(FState, FIState);
      FColor := T.FColor;
      FBkColor := T.FBkColor;
      FImageIndex := T.FImageIndex;
      FStImageIndex := T.FStImageIndex;
      FParentColors := T.FParentColors;
      FParentStyle := T.FParentStyle;
      FForceButtons := T.ForceButtons;
      FCheckBoxEnabled := T.FCheckBoxEnabled;
      FCheckBoxState := T.FCheckBoxState;
      FShowCheckBox := T.FShowCheckBox;
      FCheckBoxType := T.FCheckBoxType;
      FImageIndex2 := T.FImageIndex2;
      FStImageIndex2 := T.FStImageIndex2;
      FEnabled := T.FEnabled;
    end else
      if Ver = -5 then
      begin
        Stream.ReadBuffer(T26, SizeOf(T26));
        FState := T26.FState - [stsFocused, stsSelected];
        StateSetToStateInt(FState, FIState);
        FColor := T26.FColor;
        FBkColor := T26.FBkColor;
        FImageIndex := T26.FImageIndex;
        FStImageIndex := T26.FStImageIndex;
        FParentColors := T26.FParentColors;
        FParentStyle := T26.FParentStyle;
        FForceButtons := T26.ForceButtons;
        FCheckBoxEnabled := T26.FCheckBoxEnabled;
        FCheckBoxState := T26.FCheckBoxState;
        FShowCheckBox := T26.FShowCheckBox;
        FCheckBoxType := T26.FCheckBoxType;
        FImageIndex2 := T26.FImageIndex2;
        FStImageIndex2 := T26.FStImageIndex2;
        FEnabled := T26.FEnabled;
        FHidden := T26.FHidden;
      end else
      if Ver = -6 then
      begin
        Stream.ReadBuffer(T26, SizeOf(T26));
        Stream.ReadBuffer(FUseBkColor, SizeOf(FUseBkColor));
        FState := T26.FState - [stsFocused, stsSelected];
        StateSetToStateInt(FState, FIState);
        FColor := T26.FColor;
        FBkColor := T26.FBkColor;
        FImageIndex := T26.FImageIndex;
        FStImageIndex := T26.FStImageIndex;
        FParentColors := T26.FParentColors;
        FParentStyle := T26.FParentStyle;
        FForceButtons := T26.ForceButtons;
        FCheckBoxEnabled := T26.FCheckBoxEnabled;
        FCheckBoxState := T26.FCheckBoxState;
        FShowCheckBox := T26.FShowCheckBox;
        FCheckBoxType := T26.FCheckBoxType;
        FImageIndex2 := T26.FImageIndex2;
        FStImageIndex2 := T26.FStImageIndex2;
        FEnabled := T26.FEnabled;
        FHidden := T26.FHidden;
      end else
{$IFNDEF ELPACK_COMPLETE}
{$ENDIF}
      if
{$IFDEF ELPACK_COMPLETE}
        (Ver = -7) or
{$ENDIF}
        (Ver = -8) or
        (Ver = -9) then
      begin
        Stream.ReadBuffer(T28, SizeOf(T28));
        Stream.ReadBuffer(FUseBkColor, SizeOf(FUseBkColor));
        FState := T28.FState - [stsFocused, stsSelected];
        StateSetToStateInt(FState, FIState);
        FColor := T28.FColor;
        FBkColor := T28.FBkColor;
        FImageIndex := T28.FImageIndex;
        FStImageIndex := T28.FStImageIndex;
        FParentColors := T28.FParentColors;
        FParentStyle := T28.FParentStyle;
        FForceButtons := T28.ForceButtons;
        FCheckBoxEnabled := T28.FCheckBoxEnabled;
        FCheckBoxState := T28.FCheckBoxState;
        FShowCheckBox := T28.FShowCheckBox;
        FCheckBoxType := T28.FCheckBoxType;
        FImageIndex2 := T28.FImageIndex2;
        FStImageIndex2 := T28.FStImageIndex2;
        FEnabled := T28.FEnabled;
        FHidden := T28.FHidden;
{$IFDEF HAS_HTML_RENDER}
        IsHTML       := T28.FIsHTML;
{$ENDIF}
      end
      else
        if Ver = -10 then
        begin
          Stream.ReadBuffer(T28a, SizeOf(T28a));
          Stream.ReadBuffer(FUseBkColor, SizeOf(FUseBkColor));
          FState := T28a.FState - [stsFocused, stsSelected];
          StateSetToStateInt(FState, FIState);
          FColor := T28a.FColor;
          FBkColor := T28a.FBkColor;
          FRowBkColor := T28a.FRowBkColor;
          FUseBkColor := T28a.FUseBkColor;
          FImageIndex := T28a.FImageIndex;
          FStImageIndex := T28a.FStImageIndex;
          FParentColors := T28a.FParentColors;
          FParentStyle := T28a.FParentStyle;
          FForceButtons := T28a.ForceButtons;
          FCheckBoxEnabled := T28a.FCheckBoxEnabled;
          FCheckBoxState := T28a.FCheckBoxState;
          FShowCheckBox := T28a.FShowCheckBox;
          FCheckBoxType := T28a.FCheckBoxType;
          FImageIndex2 := T28a.FImageIndex2;
          FStImageIndex2 := T28a.FStImageIndex2;
          FEnabled := T28a.FEnabled;
          FHidden := T28a.FHidden;
  {$IFDEF HAS_HTML_RENDER}
          IsHTML       := T28a.FIsHTML;
  {$ENDIF}
        end;
  Stream.ReadBuffer(i, SizeOf(i));
  if i = -1 then
  begin
    ReadStringFromStream(Stream, FHint);
    Stream.ReadBuffer(i, SizeOf(i));
  end;
  for j := 0 to i - 1 do
  begin
    Stream.ReadBuffer(k, SizeOf(k));
    SetLength(s, k);
    Stream.ReadBuffer(pchar(s)^, k);
    FColText.Add(s);
  end;
  if Ver < 0 then
  begin
{$ifdef ELTREE_USE_STYLES}
    Stream.ReadBuffer(FUseStyles, sizeof(FUseStyles));
{$else}
    Stream.ReadBuffer(b, sizeof(b));
{$endif}
{$ifdef ELTREE_USE_STYLES}
    if FUseStyles then
    begin
      if Ver < -1 then
        Stream.ReadBuffer(b, sizeof(boolean))
      else
        b := false;
      if b then
      begin
        if Assigned(FOwner.FOnLoad) then FOwner.FOnLoad(Self, Stream, MainStyle);
      end
      else
      begin
        Stream.ReadBuffer(SI, sizeof(TStyleInfo));
        with MainStyle do
        begin
          FCellBkColor := SI.FCellBkColor;
          FTextBkColor := SI.FTextBkColor;
          FTextColor := SI.FTextColor;
          FTextFlags := SI.FTextFlags;
          FPicture := SI.FPicture;
          FCellType := SI.FCellType;
          FStyle := SI.FStyle;
          FOwnerProps := SI.FOwnerProps;
          FFontSize := SI.FFontSize;
          FFontStyles := SI.FFontStyles;
          FTag := SI.FTag;
        end;
        ReadStringFromStream(Stream, s);
        MainStyle.FFontName := s;
      end;
      Stream.ReadBuffer(i, SizeOf(i));
      for j := 1 to i do
      begin
        Style := AddStyle;
        if b then
        begin
          if Assigned(FOwner.FOnLoad) then FOwner.FOnLoad(Self, Stream, Style);
        end else
        begin
          Stream.ReadBuffer(SI, sizeof(TStyleInfo));
          with Style do
          begin
            FCellBkColor := SI.FCellBkColor;
            FTextBkColor := SI.FTextBkColor;
            FTextColor := SI.FTextColor;
            FTextFlags := SI.FTextFlags;
            FPicture := SI.FPicture;
            FCellType := SI.FCellType;
            FStyle := SI.FStyle;
            FOwnerProps := SI.FOwnerProps;
            FFontSize := SI.FFontSize;
            FFontStyles := SI.FFontStyles;
            FTag := SI.FTag;
          end;
          ReadStringFromStream(Stream, s);
          Style.FFontName := s;
        end;
      end; // for
    end;
{$endif}
  end;
  FOwner.TriggerItemLoadEvent(Stream, Self);
  Stream.ReadBuffer(i, SizeOf(i));
  for j := 0 to i - 1 do FList.AddItem(self).ReadData(Stream);
end;

procedure TElTreeItem.WriteData(Stream: TStream);
var
  i, j, k: integer;
  s: string;
  T20: TS28aItemInfo;
  p: pchar;
{$ifdef ELTREE_USE_STYLES}
  SI: TStyleInfo;
  Style: TElCellStyle;
{$endif}
  b: boolean;

begin
  // write version
  k := -10;
  Stream.WriteBuffer(k, SizeOf(k));
  // write text data
  s := FText;
  k := length(s);
  Stream.WriteBuffer(k, SizeOf(k));
  GetMem(p, k + 1);
  StrPCopy(p, s);
  Stream.WriteBuffer(p^, k);
  FreeMem(p, k + 1);
  // write binary data

  T20.FState := FState;
  T20.FColor := FColor;
  T20.FBkColor := FBkColor;
  T20.FRowBkColor := FRowBkColor;
  T20.FUseBkColor := FUseBkColor;
  T20.FParentColors := FParentColors;
  T20.FParentStyle := FParentStyle;
  T20.FImageIndex := FImageIndex;
  T20.FStImageIndex := FStImageIndex;
  T20.ForceButtons := FForceButtons;
  T20.FCheckBoxEnabled := FCheckBoxEnabled;
  T20.FCheckBoxState := FCheckBoxState;
  T20.FShowCheckBox := FShowCheckBox;
  T20.FCheckBoxType := FCheckBoxType;
  T20.FEnabled := FEnabled;
  T20.FImageIndex2 := FImageIndex2;
  T20.FStImageIndex2 := FStImageIndex2;
  T20.FHidden := FHidden;

{$IFDEF HAS_HTML_RENDER}
  T20.FIsHTML       := FIsHTML;
{$ENDIF}

  Stream.WriteBuffer(T20, SizeOf(T20));
  Stream.WriteBuffer(FUseBkColor, SizeOf(FUseBkColor));
  // write SubStrings
  i := -1;
  Stream.WriteBuffer(i, SizeOf(i));
  WriteStringToStream(Stream, FHint);
  i := FColText.Count;
  Stream.WriteBuffer(i, SizeOf(i));
  for j := 0 to i - 1 do
  begin
    s := FColText[j];
    k := length(s);
    Stream.WriteBuffer(k, SizeOf(k));
    Stream.WriteBuffer(pchar(s)^, k);
  end;
{$ifdef ELTREE_USE_STYLES}
  Stream.WriteBuffer(FUseStyles, sizeof(FUseStyles));
{$else}
  b := false;
  Stream.WriteBuffer(b, sizeof(b));
{$endif}
{$ifdef ELTREE_USE_STYLES}
  if FUseStyles then
  begin
    b := Assigned(FOwner.FOnSave);
    Stream.WriteBuffer(b, sizeof(boolean));
    if FStyles = nil then i := 0 else i := FStyles.Count;
    for j := 0 to i do
    begin
      if j = 0 then Style := MainStyle
      else Style := TElCellStyle(FStyles[j - 1]);
      if b then FOwner.FOnSave(Self, Stream, Style)
      else
        with Style do
        begin
          SI.FCellBkColor := FCellBkColor;
          SI.FTextBkColor := FTextBkColor;
          SI.FTextColor := FTextColor;
          SI.FTextFlags := FTextFlags;
          SI.FPicture := FPicture;
          SI.FCellType := FCellType;
          SI.FStyle := FStyle;
          SI.FOwnerProps := FOwnerProps;
          SI.FFontSize := FFontSize;
          SI.FFontStyles := FFontStyles;
          SI.FTag := FTag;
        end;
      Stream.WriteBuffer(SI, sizeof(TStyleInfo));
      WriteStringToStream(Stream, Style.FFontName);
      if j = 0 then Stream.WriteBuffer(i, sizeof(i));
    end;
  end;
{$endif}
  FOwner.TriggerItemSaveEvent(Stream, Self);
  // write subitems
  if FChildren = nil then i := 0 else i := FChildren.Count;
  Stream.WriteBuffer(i, SizeOf(i));
  for j := 0 to i - 1 do
      TElTreeItem(THackElList(FChildren).FList[j]).WriteData(Stream);
end;

procedure TElTreeItem.Assign(Source: TPersistent);
var
  Item, Child: TElTreeItem;
  i, j : integer;
{$ifdef ELTREE_USE_STYLES}
  Style: TElCellStyle;
{$endif}
begin
  if Source is TElTreeItem then
  begin
    if FOwner <> nil then FOwner.IsUpdating := true;
    Item := TElTreeItem(Source);
    FText := Item.Text;
    FColText.Assign(Item.FColText);
    Data := Item.Data;
    FColor := Item.FColor;
    FBkColor := Item.FBkColor;
    FRowBkColor := Item.FRowBkColor;
    FState := Item.FState;
    FState := FState - [stsFocused, stsSelected];
    FParentStyle := Item.FParentStyle;
    FParentColors := Item.FParentColors;
    FImageIndex := Item.FImageIndex;
    FStImageIndex := Item.FStImageIndex;
    FImageIndex2 := Item.FImageIndex2;
    FStImageIndex2 := Item.FStImageIndex2;
    FCheckBoxState := Item.FCheckBoxState;
    FShowCheckBox := Item.FShowCheckBox;
    FCheckBoxType := Item.FCheckBoxType;
    FCheckBoxEnabled := Item.FCheckBoxEnabled;
    FEnabled := Item.FEnabled;
    FHidden := Item.FHidden;
    FForceButtons := Item.FForceButtons;
{$ifdef ELTREE_USE_STYLES}
    FUseStyles := Item.FUseStyles;
{$endif}
    FObject := Item.FObject;
    FUseBkColor := Item.FUseBkColor;
    FDataInterface := Item.FDataInterface;
    FTag := Item.FTag;
{$ifdef ELTREE_USE_STYLES}
    FMainStyle.Assign(Item.FMainStyle);
    if FStyles <> nil then FStyles.Clear;
    if Item.FStyles <> nil then
    begin
      if FStyles = nil then CreateStyles;
      for i := 0 to Item.FStyles.Count - 1 do
      begin
        Style := AddStyle;
        Style.Assign(Item.Styles[i]);
      end;
    end;
{$endif}
    Clear;
    if Item.FChildren <> nil then
    begin
      if FChildren = nil then FChildren := TElList.Create;
      j := 0;
      for i := 0 to Item.FChildren.Count - 1 do
      begin
        Child := FList.CreateItem(FOwner);
        if FOwner.FAllList.Count > 0 then
           j := FOwner.FAllList.IndexOfFrom(j, GetLastSubItem) + 1
        else
           j := 0;
        FChildren.Add(Child);
        FOwner.FAllList.Insert(j, Child);
        Child.FRoot := FRoot;
        Child.FList := FList;
        Child.FParent := self;
        Child.FOwner := FOwner;
        Child.Assign(TElTreeItem(THackElList(Item.FChildren).FList[i]));
      end;
    end else
      if FChildren <> nil then
      begin
        FChildren.Free;
        FChildren := nil;
      end;

    if (FOwner <> nil) then
    with FOwner.FView do
    begin
      FOwner.FUpdated := true;
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
      FOwner.IsUpdating := false;
    end;
  end else inherited Assign(Source);
end;

procedure TElTreeItem.SetUseBkColor(newValue : boolean);
begin
  if FUseBkColor <> newValue then
  begin
    FUseBkColor := newValue;
    UpdateItem;
  end;
end;

procedure TElTreeItem.SetColor(index: integer; value: TColor);
begin
  if index = 1 then
  begin
    if FColor = value then exit;
    FColor := value;
  end
  else
  begin
    if FBkColor = value then exit;
    FBkColor := value;
  end;
  UpdateItem;
  //REMOVE: RedrawItem(true);
  //REMOVE: if FOwner.IsUpdating then FOwner.FUpdated:=true else FOwner.Update;
end;

function TElTreeItem.GetParent;
begin
  if FParent = FRoot then result := nil else result := FParent;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TElTreeItem.EditText;
begin
  FOwner.FView.DoEditItem(self, -1);
end;
{$endif}

function TElTreeItem.GetFullNameEx;
begin
  if (FParent <> FRoot) or (AddRoot) then result := separator + FText else result := FText;
  if FParent <> FRoot then result := FParent.GetFullNameEx(separator, AddRoot) + result;
end;

function TElTreeItem.GetFullName;
begin
  result := separator + FText;
  if FParent <> FRoot then result := FParent.GetFullName(separator) + result;
end;

function TElTreeItem.GetChildByIndex;
begin
  if (index < 0) or (FChildren = nil) or (index >= FChildren.Count) then
    raise EElTreeError.Create(STExOutOfBounds);
  result := TElTreeItem(THackElList(FChildren).FList[index]);
end;

function TElTreeItem.GetChildrenCount;
var
  i, j: integer;
begin
  if FChildren = nil then
     Result := 0
  else
     Result := FChildren.Count;
  j := result;
  for i := 0 to j - 1 do
    result := result + TElTreeItem(THackElList(FChildren).FList[i]).ChildrenCount;
end;

function TElTreeItem.GetNextChild;
var
  i: integer;
begin
  if FChildren = nil then
     result := nil
  else
  begin
    i := Child.Index;
    if (i = (FChildren.Count - 1)) then
       result := nil
    else
       result := TElTreeItem(THackElList(FChildren).FList[i + 1]);
  end;
end;

function TElTreeItem.GetPrevChild;
var
  i: integer;
begin
  if FChildren = nil then
     result := nil
  else
  begin
    i := Child.Index;
    if i = 0 then
       result := nil
    else
      result := TElTreeItem(THackElList(FChildren).FList[i - 1]);
  end;
end;

function TElTreeItem.GetFirstVisibleChild;
var
  i: integer;
  ChC : integer;
  Item: TElTreeItem;
begin
  result := nil;
  if (not FOwner.FilteredVisibility) then
  begin
    result := GetFirstChild;
    exit;
  end;
  if (FChildren <> nil) then
  begin
    Chc := FChildren.Count;
    if (Chc > 0) then
    for i := 0 to ChC - 1 do
    begin
      Item := TElTreeItem(THackElList(FChildren).FList[i]);
      if not Item.Hidden then
      begin
        result := Item;
        exit;
      end;
    end;
  end;
end;

function TElTreeItem.GetFirstChild;
begin
  if (FChildren = nil) or (FChildren.Count = 0) then
     result := nil
  else
     result := TElTreeItem(THackElList(FChildren).FList[0]);
end;

function TElTreeItem.GetLastChild;
begin
  if (FChildren = nil) or (FChildren.Count = 0) then
     result := nil
  else
     result := TElTreeItem(FChildren.Last);
end;

function TElTreeItem.GetFirstSibling;
begin
  if FParent = nil then
     result := nil
  else
     result := FParent.GetFirstChild;
end;

function TElTreeItem.GetLastSibling;
begin
  if FParent = nil then
     result := nil
  else
     result := FParent.GetLastChild;
end;

function TElTreeItem.GetNextSibling;
begin
  if FParent = nil then
     result := nil
  else
     result := FParent.GetNextChild(self);
end;

function TElTreeItem.GetPrevSibling;
begin
  if FParent = nil then
     result := nil
  else
    result := FParent.GetPrevChild(self);
end;

function TElTreeItem.GetFullExpand;
begin
  if Parent = nil then
     result := true
  else
     result := (Parent.FullyExpanded and Parent.Expanded);
end;

function TElTreeItem.GetSelected : boolean;
begin
  result := (FIState and tisSelected) > 0;
end;

procedure TElTreeItem.SetSelected(newValue : boolean);
var b : boolean;
begin
   if FOwner.FMultiSelect then
   begin
     b := ((FIState and tisSelected) > 0) xor newValue;
     if b then
     begin
       if newValue = false then
       begin
         FOwner.FSelChange := true;
         Exclude(FState, stsSelected);
         FIState := FIState and (not tisSelected);
         FOwner.FSelectedList.Remove(Self);
         with FOwner.FView do
{Original}
         //if FSelected = Self then FSelected := nil;
{End Original}
{Soulsnake Fix}
         if (FSelected = Self) then
           FSelected := TElTreeItem(FOwner.FSelectedList.First);
{End Soulsnake Fix}
       end else
       begin
         FOwner.FSelChange := true;
         Include(FState, stsSelected);
         FIState := FIState or tisSelected;
         FOwner.FSelectedList.Add(Self);
{Soulsnake Fix}
         if FOwner.FSelectedList.Count = 1 then
           FOwner.FView.FSelected := Self;
{End Soulsnake Fix}
       end;
       FOwner.TriggerItemSelectedChangeEvent(Self);
     end;
   end;
   UpdateItem;
end;

procedure TElTreeItem.SetState;
var
  FOldState: TSTIStates;
  reqitemch: boolean;
begin
  reqitemch := true;
  FOldState := FState;
  case index of
    stsFocused: begin
        if (value = false) then
        begin
          if FOwner.ItemFocused = Self then
             FOwner.DoSetFocused(nil, false);
        end
        else
           FOwner.DoSetFocused(self, false);
        exit;
      end;
    stsCut:
      begin
        if value = false then Exclude(FState, stsCut)
        else Include(FState, stsCut);
      end;
    stsUnderlined:
      begin
        if value = false then Exclude(FState, stsUnderlined)
        else Include(FState, stsUnderlined);
      end;
    stsBold:
      begin
        if value = false then Exclude(FState, stsBold)
        else Include(FState, stsBold);
      end;
    stsItalic:
      begin
        if value = false then Exclude(FState, stsItalic)
        else Include(FState, stsItalic);
      end;
    stsStrikeOut:
      begin
        if value = false then Exclude(FState, stsStrikeOut)
        else Include(FState, stsStrikeOut);
      end;
  end; // case
  if (index in [stsBold, stsItalic]) and (not FOwner.FShowHeader) and FullyExpanded then FOwner.FView.DefineHRange;
  if FOldState <> FState then
  begin
    if reqitemch then FOwner.DoItemChange(self, icmState);
    UpdateItem;
  end;
end;

function TElTreeItem.GetState;
begin
  result := index in FState;
end;

function TElTreeItem.IsExpanded;
begin
  result := stsExpanded in FState;
end;

procedure TElTreeItem.Expand;
var
  i,
  j: integer;
  b: boolean;

begin
  b := true;
  if Self <> FRoot then FOwner.DoItemExpanding(self, b);
  if not (b) then exit;
  FOwner.IsUpdating := true;
  with FOwner.FView do
  begin
    FVisUpdated := true;
    FRangeUpdate := true;
  end;
  FState := FState + [stsExpanded];
  if Self <> FRoot then FOwner.DoItemExpand(self);
  if recursive then
  begin
    if (FChildren = nil) then
       j := 0
    else
       j := FChildren.Count;
    for i := 0 to j - 1 do
        TElTreeItem(THackElList(FChildren).FList[i]).expand(true);
  end;
  if (not FOwner.FShowHeader) and FullyExpanded then
    FOwner.FView.FHRange := -1;
  with FOwner.FView do
  begin
    FClearVis := true;
    FOwner.FUpdated := true;
  end;
  FOwner.IsUpdating := false;
end;

procedure TElTreeItem.Collapse;
var
  i : integer;
  b : boolean;
  AnItem : TElTreeItem;

  procedure IterateProc(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if not Item.IsUnder(TElTreeItem(IterateData)) then
    begin
      ContinueIterate := false;
      exit;
    end;
    ContinueIterate := true;
    if Item <> IterateData then Item.Selected := false;
  end;

begin
  b := true;
  if Self <> FRoot then FOwner.DoItemCollapsing(self, b);
  if not (b) then exit;
  FOwner.IsUpdating := true;
  with FOwner.FView do
  begin
    FRangeUpdate := true;
    FVisUpdated := true;
  end;
  FState := FState - [stsExpanded];
  if Self <> FRoot then FOwner.DoItemCollapse(self);
  with FOwner do
    if (ItemFocused <> nil) and (ItemFocused <> Self) and (ItemFocused.IsUnder(Self)) and (FMoveFocusOnCollapse) then
    begin
      if SelectedCount = 1 then
      begin
        AnItem := ItemFocused;
        DoSetFocused(Self, false);
        AnItem.Selected := false;
      end
      else
        DoSetFocused(Self, false);
    end;
  
  if Recursive then
  begin
    if Assigned(FChildren) then
      for i := 0 to Pred(FChildren.Count) do
        TElTreeItem(THackElList(FChildren).FList[i]).Collapse(True);
  end;

  if FOwner.FDeselectChildrenOnCollapse then
    FOwner.Items.IterateFrom(false, @IterateProc, Self, Self);

  if (not FOwner.FShowHeader) and FullyExpanded then
     FOwner.FView.FHRange := -1;
  with FOwner.FView do
  begin
    FClearVis := true;
    FClearAll := true;
  end;
  FOwner.FUpdated := true;
  FOwner.IsUpdating := false;
end;

function TElTreeItem.GetChildIndex;
begin
  if FChildren = nil then
     result := -1
  else
     result := FChildren.IndexOf(Child);
end;

function TElTreeItem.GetIndex;
begin
  if FParent = nil then
     result := -1
  else
     result := FParent.GetChildIndex(self);
end;

function TElTreeItem.GetVisIndex;
begin
  // no check for root - should never be called for root
  result := FList.GetVisIndex(self);
end;

function TElTreeItem.GetAbsIndex;
begin
  // no check for root - should never be called for root
  result := FList.GetAbsIndex(self);
end;

procedure TElTreeItem.RemoveChild;
var
  i: integer;
begin
  with FOwner.FView do
  begin
    i := FVisible.IndexOf(Child);
    if i >= 0 then
       FVisible.Delete(i);
  end;

  {with FOwner.FView do
    if FSelected = Child then FSelected := nil;
  }
  
  if FChildren <> nil then
  begin
    i := FChildren.IndexOf(Child);
    if i <> -1 then
       FChildren.Delete(i);
    if FChildren.Count = 0 then
    begin
      FChildren.Free;
      FChildren := nil;
    end;
    //dec(FList.FCount);
  end;
end;

procedure TElTreeItem.DeleteChild;
var
  i: integer;
begin
  FOwner.IsUpdating := true;
  Child.Clear;
  if Child.Hidden then
  begin
    dec(FOwner.TotalHiddenCount);
    Child.FHidden := false;
  end;
  if Child = FOwner.FView.FSelected then
  begin
    //if Self = FRoot then
    //begin
{Soulsnake Fix}
      if FOwner.FMultiSelect then
        FOwner.FView.FSelected := TElTreeItem(FOwner.FSelectedList.First)
      else
{End Soulsnake Fix}
      begin
        FOwner.SetSelected(GetPrevChild(Child));
        if FOwner.FView.FSelected = nil then
           FOwner.SetSelected(GetNextChild(Child));
        if (FOwner.FView.FSelected = nil) and (Self <> FRoot) then
          FOwner.SetSelected(Self);
      end;
    //end else
    //  FOwner.SetSelected(Self);
  end;
  Child.Selected := false;
  
  {with FOwner.FView do
    if FSelected = Child then FSelected := nil;
  }

  // Move focus, if needed
  if Child = FOwner.FView.FFocused then
  begin
    //if Self = FRoot then
    //begin
      FOwner.DoSetFocused(GetPrevChild(Child), true, false);
      if FOwner.ItemFocused = nil then
         FOwner.DoSetFocused(GetNextChild(Child), true, false);
      if (FOwner.ItemFocused = nil) and (Self <> FRoot) then
        FOwner.DoSetFocused(Self, true, false);
    //end else
    //  FOwner.DoSetFocused(Self, true, false);
  end;
  with FOwner.FView do
  begin
    if FPassedItem = Child then
       FPassedItem := nil;
    if FTrackItem = Child then
    begin
       FTrackItem := nil;
       FTrackSection := nil;
    end;
{$ifdef ELTREE_USE_INPLACE_EDITORS}
    if (FInpEdit <> nil) then
    begin
      FEditingItem := nil;
      if not FOwner.FDelOnEdit then
         DoEndEdit(true);
    end;
{$endif}
  end;
  with FOwner.FView do
  begin
    i := FVisible.IndexOf(Child);
    if (i >= 0) then
       FVisible.Delete(i);
  end;
  FOwner.DoItemDelete(Child);
  //if FChildren <> nil then
  //begin
    i := FChildren.IndexOf(Child);
    if i <> -1 then
       FChildren.Delete(i);
    if FChildren.Count = 0 then
    begin
      FChildren.Free;
      FChildren := nil;
    end;
  //end;
  Child.Clear;
  FOwner.FAllList.Remove(Child);
  Child.Free;
  with FOwner do
  begin
    FUpdated := true;
    FView.FRangeUpdate := true;
    IsUpdating := false;
  end;
end;

function TElTreeItem.GetLastSubItem : TElTreeItem;
var Item : TElTreeItem;
begin
  result := Self;
  Item := Result.GetLastChild;
  While Item <> nil do
  begin
    result := Item;
    Item := Result.GetLastChild;
  end;
end;

function TElTreeItem.AddChild;
var i : integer;
begin
  if FChildren = nil then
     FChildren := TElList.Create;
  with FOwner do
  begin
    if (FAllList.Count = 0) or (GetLastSubItem = FAllList.Last) then
        FAllList.Add(Child)
    else
    begin
      i := FAllList.IndexOf(GetLastSubItem);
      FAllList.Insert(i + 1, Child);
    end;
  end;
  result := FChildren.Add(Child);
  Child.FRoot := FRoot;
  FOwner.FUpdated := true;
end;

function TElTreeItem.AddLastChild;
begin
  if FChildren = nil then FChildren := TElList.Create;
  with FOwner do
  begin
    FAllList.Add(Child);
  end;
  result := FChildren.Add(Child);
  Child.FRoot := FRoot;
  FOwner.FUpdated := true;
end;

function TElTreeItem.InsertChild;
var i : integer;
    SI: TElTreeItem;

begin
  if FChildren = nil then FChildren := TElList.Create;
  if Index > FChildren.Count then
    raise EElTreeError.Create(STExOutOfBounds);

  with FOwner do
  begin
    if Count = 0 then
      i := FAllList.IndexOf(Self) + 1
    else
    begin
      if FChildren.Count = Index then
      begin
        SI := TElTreeItem(THackElList(FChildren).FList[Index - 1]).GetLastSubItem;
        if SI = FAllList.Last then
           i := FAllList.Count
        else
           i := FAllList.IndexOf(SI) + 1;
      end
      else
        i := FAllList.IndexOf(THackElList(FChildren).FList[Index]);
    end;
    if i = FAllList.Count then
       FAllList.Add(Child)
    else
       FAllList.Insert(i, Child);
  end;

  FChildren.Insert(Index, Child);
  result := index;
  Child.FParent := self;
  Child.FRoot := FRoot;
  FOwner.FUpdated := true;
end;

procedure TElTreeItem.MoveTo;
var TSI: TElTreeItem;
begin
  if NewParent = self then exit;
  if NewParent = nil then
     TSI := FRoot
  else
     TSI := NewParent;
  if TSI.FChildren = nil then
     MoveToIns(NewParent, 0)
  else
     MoveToIns(NewParent, TSI.FChildren.Count);
end;

procedure TElTreeItem.MoveToIns;
var i : integer;
    OldStart,
    OldEnd,
    NewStart : integer;
    aresize  : boolean;
    //OldSel   : boolean;
begin
  if NewParent = self then exit;
  if NewParent = nil then NewParent := FRoot;
  if NewParent.IsUnder(self) then
    raise EElTreeError.Create(STexRecursiveMove);
  FOwner.IsUpdating := true;
  {if FParent.FChildren = nil then
  begin
    i := -1;
    FParent.FChildren := TElList.Create;
  end else }
  i := FParent.FChildren.IndexOf(self);

  with FOwner.FAllList do
  begin
    OldStart := IndexOf(Self);
    OldEnd   := IndexOfFrom(OldStart, GetLastSubItem);
  end;
  aresize := false;
  {if FParent <> nil then }
  //OldSel := FOwner.FView.FSelected = Self;
  FParent.RemoveChild(self);
  if (FParent = NewParent) and (i < AnIndex) and (AnIndex >= FParent.Count) then
  begin
    NewStart := FOwner.FAllList.IndexOfFrom(OldStart, FParent.GetLastSubItem);
    with FOwner.FAllList do
    if NewStart = Count - 1 then
    begin
      aresize := true;
      Count := Count + 1;
    end;
    inc(NewStart);
    with FParent do
    begin
      if FChildren = nil then
         FChildren := TElList.Create;
      FChildren.Add(self);
    end;
    FOwner.FAllList.MoveRange(OldStart, OldEnd, NewStart);
  end else
  begin
    with NewParent do
    begin
      if FChildren = nil then
         FChildren := TElList.Create;
      FChildren.Insert(AnIndex, self);
      if AnIndex = 0 then
         NewStart := FOwner.FAllList.IndexOf(NewParent)
      else
         NewStart := FOwner.FAllList.IndexOf(TElTreeItem(THackElList(FChildren).FList[AnIndex - 1]).GetLastSubItem);
    end;
    with FOwner.FAllList do
      if NewStart = Count - 1 then
      begin
        aresize := true;
        Count := Count + 1;
      end;
    inc(NewStart);
    FOwner.FAllList.MoveRange(OldStart, OldEnd, NewStart);
  end;
  //if OldSel then FOwner.FView.FSelected := Self;

  if aresize then
  with FOwner.FAllList do
     Count := Count - 1;
  FParent := NewParent;
  with FOwner do
  begin
    //inc(FItems.FCount);
    if ((FSortMode = smAdd) or (FSortMode = smAddClick)) and (FInSorting = 0) then
    begin
      if (FMainTreeCol = FSortSection) or (FSortSection = -1) then
      begin
        if FUpdateCount > 0 then
           FSortRequired := true
        else
        begin
          FOwner.TriggerSortBegin;
          FParent.Sort(false);
          FOwner.TriggerSortBegin;
        end;
      end;
    end;
    with FOwner.FView do
    begin
      FVisUpdated := true;
      FClearVis := true;
      FUpdated := true;
      FClearAll := true;
    end;
    IsUpdating := false;
  end;
end;

procedure TElTreeItem.RedrawItemPart;
var
  R: TRect;
begin
  if (FOwner = nil) then exit;
  with FOwner do
    R := FView.GetItemRect(FView.FVisible.IndexOf(self));
  inc(R.Bottom);
  if DoCheck and IsRectEmpty(R) then exit;
  R.Left := Left - FOwner.FHPos;
  R.Right := Right - FOwner.FHPos;
  if not (csDestroying in FOwner.ComponentState) then InvalidateRect(FOwner.FView.Handle, @R, true);
end;

procedure TElTreeItem.RedrawItem;
var
  R: TRect;
begin
  if (FOwner = nil) then exit;
  with FOwner do
    R := FView.GetItemRect(FView.FVisible.IndexOf(self));
  inc(R.Bottom);
  if DoCheck and IsRectEmpty(R) then exit;
  if not (csDestroying in FOwner.ComponentState) then
    InvalidateRect(FOwner.FView.Handle, @R, true);
end;

procedure TElTreeItem.SetText;
begin
  FText := Value;
  FOwner.DoItemChange(Self, icmText);
  with FOwner do
  begin
    if (not FShowHeader) and FullyExpanded then
    begin
      if FUpdateCount > 0 then FView.FHRange := -1 else FView.DefineHRange;
    end;
    if (FSortMode = smAdd) or (FSortMode = smAddClick) then
    begin
      if (FMainTreeCol = FSortSection) or (FSortSection = -1) then
      begin
        if FUpdateCount > 0 then
           FSortRequired := true
        else
        begin
          FOwner.TriggerSortBegin;
          FParent.Sort(false);
          FOwner.TriggerSortBegin;
        end;
      end;
    end;
    if FShowHeader and (FUpdateCount = 0) then
       AutoSizeColumn(FMainTreeCol);
  end;
  UpdateItem;
end;

function TElTreeItem.GetLevel: integer;
begin
  if Self = FRoot then result := -1 else result := FParent.Level + 1;
end;

function TElTreeItem.EqualColumns;
var
  i: integer;
begin
  result := false;
  if FColText.Count <> Cols.Count then exit;
  for i := 0 to FColText.Count - 1 do
    if (Cols.Count <= i) or (Cols[i] <> FColText[i]) then exit;
  result := true;
end;

function TElTreeItem.IsEqual;
begin
  result := (Text = Item.Text) and (FState = Item.FState) and
    (EqualColumns(Item.FColText)) and (FColor = Item.FColor) and (FBkColor = Item.FBkColor);
end;

{Returns true if the item is under then given item in the tree}

function TElTreeItem.IsUnder(Item: TElTreeItem): boolean;
begin
  if Item = nil then
  begin
    result := false;
    exit;
  end;
  if Self = Item then
     result := true
  else
  if (FParent <> FRoot) and (FParent <> nil) then
     result := FParent.IsUnder(Item)
  else
     result := false;
end;

procedure TElTreeItem.SetExpanded;
begin
  if value = Expanded then exit;
  FOwner.IsUpdating := true;
  if value = true then Expand(false) else Collapse(false);
  FOwner.IsUpdating := false;
end;

procedure TElTreeItem.MakeFullyExpanded;
var
  TSI: TElTreeItem;
begin
  if not value then exit;
  FOwner.IsUpdating := true;
  try
    TSI := Self;
    while TSI.FParent <> nil do
    begin
      TSI.FParent.Expand(false);
      TSI := TSI.FParent;
    end; // while
    with FOwner.FView do
    begin
      FClearVis := true;
      FVisUpdated := true;
      FRangeUpdate := true;
    end;
    FOwner.FUpdated := true;
  finally
    FOwner.IsUpdating := false;
  end;
end;

procedure TElTreeItem.SetParentStyle(value: boolean);
begin
  if value = FParentStyle then exit;
  FParentStyle := value;
  UpdateItem;
end;

procedure TElTreeItem.SetParentColors(value: boolean);
begin
  if value = FParentColors then exit;
  FParentColors := value;
  UpdateItem;
end;

function TElTreeItem.GetHasChildren: boolean;
begin
  result := (FChildren <> nil) and (FChildren.Count > 0);
end;

(*
procedure TElTreeItem.Clear;
var i : integer;
begin
  inc(FOwner.FFireFocusEvents);
  try
    if FChildren = nil then exit;
    for i := -FChildren.Count + 1 to 0 do
        DeleteChild(TElTreeItem(FChildren.Last));
    FChildren.Free;
    FChildren := nil;
  finally
    Dec(FOwner.FFireFocusEvents);
  end;
end;
*)

// Version 3.2
procedure TElTreeItem.Clear;
var i : integer;
    OldFocused : TElTreeItem;
begin
  OldFocused := FOwner.FView.FFocused;
  inc(FOwner.FFireFocusEvents);
  try
    if FChildren = nil then exit;
    for i := -FChildren.Count + 1 to 0 do
        DeleteChild(TElTreeItem(FChildren.Last));
    FChildren.Free;
    FChildren := nil;
    if FullyExpanded then
      FOwner.FView.FVisUpdated := true;
  finally
    Dec(FOwner.FFireFocusEvents);
  end;
  if (OldFocused <> FOwner.FView.FFocused) and (FOwner.FFireFocusEvents = 0) then
    FOwner.DoItemFocused;
end;

procedure TElTreeItem.ExchangeItems(I, J: integer);
var
  //TI1, TI2: TElTreeItem;
  P    : Pointer;
  //k, l : integer;
begin
  // No check for FChildren and indexes validity. The routine should be called from QuickSort only!
  //TI1 := TElTreeItem(THackElList(FChildren).FList[i]);
  //TI2 := TElTreeItem(THackElList(FChildren).FList[j]);
  //if (TI1.Count = 0) and (TI2.Count = 0) then
  if true then
  begin
    P := THackElList(FChildren).FList[i];
    THackElList(FChildren).FList[i] := THackElList(FChildren).FList[j];
    THackElList(FChildren).FList[j] := P;

    {k := FOwner.FAllList.IndexOf(TI1);
    l := FOwner.FAllList.IndexOf(TI2);

    P := THackElList(FOwner.FAllList).FList[k];
    THackElList(FOwner.FAllList).FList[k] := THackElList(FOwner.FAllList).FList[l];
    THackElList(FOwner.FAllList).FList[l] := P;}
  end else
  begin
    //TI2.MoveToIns(Self, i);
    //TI1.MoveToIns(Self, j);
  end;
end;

procedure TElTreeItem.NormalizeSorts(StartIdx : integer);

  procedure IntNormalize(List : TElList; Item : TElTreeItem; var CurIdx : integer);
  var i : integer;
      AChild : TElTreeItem;
      ChC    : integer;
  begin
    if (Item.FChildren <> nil) then
    begin
      ChC := Item.FChildren.Count;
      if (ChC > 0) then
      begin
        for i := 0 to ChC - 1 do
        begin
          AChild := TElTreeItem(THackElList(Item.FChildren).FList[i]);
          if CurIdx > List.Count - 1 then
            List.Count := CurIdx + 1; 

          List[CurIdx] := AChild;
          Inc(CurIdx);
          if (AChild.FChildren <> nil) and (AChild.FChildren.Count > 0) then
             IntNormalize(List, AChild, CurIdx);
        end;
      end;
    end;
  end;

begin
  IntNormalize(FOwner.FAllList, Self, StartIdx);
end;

procedure TElTreeItem.Sort(recursive: boolean);
var
  ST       : TSortTypes;
  ASection : TElHeaderSection;
  SM       : TElSSortMode;
  FCol     : integer;

  StartItem: TElTreeItem;
  StartIdx : Integer;

begin
  inc(FOwner.FInSorting);
  if (FChildren <> nil) and (Recursive or (FChildren.Count > 1)) then
  begin
    FOwner.IsUpdating := true;

    with FOwner do
    begin
      if (FSortSection = FMainTreeCol) or (FSortSection = -1) then
      begin
        FCol := -1;
        SM   := hsmNone;
        ST   := FSortType;

        if FShowHeader then
        begin
          FCol := FMainTreeCol;
          ASection := FHeader.Sections[FCol];
          if ASection <> nil then
          begin
            SM := ASection.SortMode;
            ST := SectionTypeToSortType(ASection.FieldType);
          end
          else
            FCol := -1;
        end;
      end
      else
      begin
        FCol     := FSortSection;
        ASection := FHeader.Sections[FCol];
        SM       := ASection.SortMode;
        ST       := SectionTypeToSortType(ASection.FieldType);
      end;
    end;

    StartItem := FChildren.FastGet(0);
    StartIdx := StartItem.AbsoluteIndex;

    FRec := false;

    QuickSort(recursive, 0, FChildren.Count - 1, SM, ST, FCol);

    NormalizeSorts(StartIdx);

    with FOwner.FView do
    begin
      FClearAll := true;
      FClearVis := true;
    end;
    with FOwner do
    begin
      FUpdated := true;
      IsUpdating := false;
    end;
  end;
  dec(FOwner.FInSorting);
end;

procedure TElTreeItem.AddSortData(SortType: TSortTypes;
                                  FSortSection : integer);
var S : String;
    N, I, FCol : integer;
    T : TDateTime;
    F : Extended;
    MTC: integer;
begin
  MTC := FOwner.FMainTreeCol;
  if FSortRef = 0 then
  begin
    if FSortSection > -1 then
    begin
      {$IFDEF USE_VARIANT}
      VarClear(FSortData);
      {$ELSE}
      FSortType := -1;
      {$ENDIF}
      if FSortSection = MTC then
      begin
        S := Text;
      end
      else
      begin
        FCol := FSortSection;
        if FSortSection > MTC then
           dec(FCol);
        if FCol >= FColText.Count then
           S := ''
        else
           S := FColText[FCol];
      end;

      if SortType = stText then
      begin
        {$IFDEF USE_VARIANT}
        FSortData := S;
        {$ELSE}
        FSortType := vtString;
        GetMem(FSortData, Length(S) + 1);
        StrPLCopy(PChar(FSortData), S, Length(S));
        {$ENDIF}
      end
      else
      if SortType = stNumber then
      begin
        {$IFDEF USE_VARIANT}
        TVarData(FSortData).VType := vtInteger;
        Val(S, N, I);
        if I <> 0 then
          FSortData := NULL
        else
          FSortData := N;
        {$ELSE}
        FSortType := vtInteger;
        Val(S, N, I);
        if I <> 0 then
          FSortType := -1
        else
          Integer(FSortData) := N;
        {$ENDIF}
      end
      else
      case SortType of
        stCurrency:
          begin
            {$IFDEF USE_VARIANT}
            FSortData := PrettyStrToCurr(S);
            {$ELSE}
            FSortType := vtCurrency;
            GetMem(FSortData, sizeof(Currency));
            PCurrency(FSortData)^ := PrettyStrToCurr(S);
            {$ENDIF}
          end;
        stFloating:
          begin
            {$IFDEF USE_VARIANT}
            TVarData(FSortData).VType := vtExtended;
            if (not TextToFloat(Pchar(S), F, fvExtended)) then
               FSortData := NULL
            else
               FSortData := F;
            {$ELSE}
            FSortType := vtExtended;
            if (not TextToFloat(PChar(S), F, fvExtended)) then
               FSortType := -1
            else
            begin
              GetMem(FSortData, sizeof(Double));
              PDouble(FSortData)^ := F;
            end;
            {$ENDIF}
          end;
        stDateTime:
          begin
            {$IFDEF USE_VARIANT}
            TVarData(FSortData).VType := vtExtended;
            try
              T := StrToDateTime(S);
              FSortData := T;
            except
              FSortData := NULL
            end;
            {$ELSE}
            FSortType := vtExtended;
            try
              T := StrToDateTime(S);
              GetMem(FSortData, sizeof(Double));
              PDouble(FSortData)^ := T;
            except
              FSortType := -1;
            end;
            {$ENDIF}
          end;
        stDate:
          begin
            {$IFDEF USE_VARIANT}
            TVarData(FSortData).VType := vtExtended;
            try
              T := StrToDate(S);
              FSortData := T;
            except
              FSortData := NULL
            end;
            {$ELSE}
            FSortType := vtExtended;
            try
              T := StrToDate(S);
              GetMem(FSortData, sizeof(Double));
              PDouble(FSortData)^ := T;
            except
              FSortType := -1;
            end;
            {$ENDIF}
          end;
        stTime:
          begin
            {$IFDEF USE_VARIANT}
            TVarData(FSortData).VType := vtExtended;
            try
              T := StrToTime(S);
              FSortData := T;
            except
              FSortData := NULL
            end;
            {$ELSE}
            FSortType := vtExtended;
            try
              T := StrToTime(S);
              GetMem(FSortData, sizeof(Double));
              PDouble(FSortData)^ := T;
            except
              FSortType := -1;
            end;
            {$ENDIF}
          end;
        stBoolean:
          begin
            {$IFDEF USE_VARIANT}
            TVarData(FSortData).VType := vtBoolean;
            FSortData := boolean(Length(S) > 0);
            {$ELSE}
            FSortType := vtBoolean;
            Integer(FSortData) := Length(S);
            {$ENDIF}
          end;
        else
          begin
            {$IFDEF USE_VARIANT}
            FSortData := S;
            {$ELSE}
            FSortType := vtString;
            GetMem(FSortData, Length(S) + 1);
            StrPLCopy(PChar(FSortData), S, Length(S));
            {$ENDIF}
          end;
      end;
    end;
  end;
  inc(FSortRef);
end;

procedure TElTreeItem.ReleaseSortData;
begin
  dec(FSortRef);
  if (FSortRef = 0) then
  {$IFDEF USE_VARIANT}
     VarClear(FSortData);
  {$ELSE}
  begin
    if ((FSortType = vtExtended) or (FSortType = vtString)) and (FSortData <> nil) then
       FreeMem(FSortData);
    FSortData := nil;
    FSortType := -1;
  end;
  {$ENDIF}
end;

procedure TElTreeItem.QuickSort(recursive: boolean;
                                L, R: Integer;
                                SM : TElSSortMode;
                                SortType: TSortTypes;
                                FSortSection : integer);
var
  I, J       : Integer;
  P          : TElTreeItem;
  EL, ER     : integer;
  ChildCount : integer;
  LocalFRec  : boolean;

begin
  //if (FChildren = nil) then exit;
  Childcount := FChildren.Count;
  //if ChildCount = 0 then exit;
  inc(FOwner.FInSorting);
  if ChildCount > 1 then
  begin
    if FRec=false then
    begin
      for i := 0 to ChildCount - 1 do
      begin
        p := TElTreeItem(THackElList(FChildren).FList[i]);
        if P.FSortRef = 0 then
           P.AddSortData(SortType, FSortSection)
        else
           inc(P.FSortRef);
      end;
    end;
    repeat
      El := L;
      Er := R;
      I := L;
      J := R;
      P := TElTreeItem(THackElList(FChildren).FList[(L + R) shr 1]);
      repeat
        while (I < ChildCount) and (FOwner.CompareItems(TElTreeItem(THackElList(FChildren).FList[I]), P, SM, SortType, FSortSection) < 0) do
          Inc(I);
        while (J >= 0) and (FOwner.CompareItems(TElTreeItem(THackElList(FChildren).FList[J]), P, SM, SortType, FSortSection) > 0) do
          Dec(J);
        if I <= J then
        begin
          if i <> j then
             ExchangeItems(I, J);
          Inc(I);
          Dec(J);
        end;
      until I > J;
      if (L < J) and ((EL <> L) or (ER <> J)) then
      begin
        LocalFRec:=FRec;
        FRec:=true;
        QuickSort(recursive, L, J, SM, SortType, FSortSection);
        FRec:=LocalFRec;
      end;
      L := I;
    until I >= R;
    if FRec=false then
      for i := 0 to ChildCount - 1 do
      begin
        P := TElTreeItem(THackElList(FChildren).FList[i]);
        if P.FSortRef = 1 then
           P.ReleaseSortData
        else
           dec(P.FSortRef);
      end;
  end;

  if Recursive then
  begin
    if not FRec then
    begin
      for i := 0 to ChildCount - 1 do
      begin
        P := TElTreeItem(THackElList(FChildren).FList[i]);
        if (P.FChildren <> nil) and (P.FChildren.Count > 1) then
            P.QuickSort(recursive, 0, P.FChildren.Count - 1, SM, SortType, FSortSection);
      end; // for
    end;
  end;
  dec(FOwner.FInSorting);
end;

procedure TElTreeItem.OnColTextChange(Sender: TObject);
begin
  if FOwner <> nil then
  begin
    with FOwner do
    if (FSortMode = smAdd) or (FSortMode = smAddClick) then
    begin
      if InRange(-1, FHeader.Sections.Count - 1, FSortSection) then
      begin
        if FParent <> nil then
        begin
          if FUpdateCount > 0 then
             FSortRequired := true
          else
          begin
            FOwner.TriggerSortBegin;
            FParent.Sort(false);
            FOwner.TriggerSortBegin;
          end;
        end;
      end;
    end;
    with FOwner do
      if FShowHeader and (FUpdateCount = 0) then
         AutoSizeAllColumns;
    UpdateItem;
  end;
end;

procedure TElTreeItem.SetImageIndex(value: integer); { private }
begin
  if FImageIndex = value then exit;
  FImageIndex := value;
  if FOwner.FShowImages then
  begin
    with FOwner do
      if (not FShowEmptyImages) and FShowHeader then
         AutoSizeColumn(FMainTreeCol);
    UpdateItem;
  end;
end; { SetImageIndex }

procedure TElTreeItem.SetStImageIndex(value: integer); { private }
begin
  if FStImageIndex = value then exit;
  FStImageIndex := value;
  if FOwner.FShowImages then
  begin
    with FOwner do
      if (not FShowEmptyImages) and FShowHeader then
         AutoSizeColumn(FMainTreeCol);
    UpdateItem;
  end;
end; { SetStImageIndex }

procedure TElTreeItem.SetImageIndex2(value: integer); { private }
begin
  if FImageIndex2 = value then exit;
  FImageIndex2 := value;
  if FOwner.FShowImages then
  begin
    with FOwner do
      if (not FShowEmptyImages2) and FShowHeader then
         AutoSizeColumn(FMainTreeCol);
    UpdateItem;
  end;
end; { SetImageIndex }

procedure TElTreeItem.SetStImageIndex2(value: integer); { private }
begin
  if FStImageIndex2 = value then exit;
  FStImageIndex2 := value;
  if FOwner.FShowImages then
  begin
    with FOwner do
      if (not FShowEmptyImages2) and FShowHeader then
         AutoSizeColumn(FMainTreeCol);
    UpdateItem;
  end;
end; { SetStImageIndex }

procedure TElTreeItem.SetForceButtons(newValue: Boolean);
{ Sets data member FForceButtons to newValue. }
begin
  if FForceButtons <> newValue then
  begin
    FForceButtons := newValue;
    if FOwner.FShowButtons then
    begin
      with FOwner do
        if FShowHeader then
           AutoSizeAllColumns;
      UpdateItem;
    end;
  end;
end; { SetForceButtons }

function TElTreeItem.GetCount: Integer;
begin
  if FChildren = nil then result := 0 else result := FChildren.Count;
end; { GetCount }

function TElTreeItem.GetItems(Index: integer): TElTreeItem;
{ Returns the value of data member FItems[Index ]. }
begin
  if FChildren = nil then
     result := nil
  else
     result := FChildren[Index];
end; { GetItems }

procedure TElTreeItem.Delete; { public }
begin
  FList.DeleteItem(Self);
end; { Delete }

function TElTreeItem.IsVisible: Boolean; { public }
begin
  result := FullyExpanded;
  if FOwner.FFilteredVisibility then result := result and (not Hidden) and (FParent.IsVisible);
end; { IsVisible }

function TElTreeItem.GetNextVisible: TElTreeItem; { public }
begin
  Result := GetNext;
  while Assigned(Result) and (not Result.IsVisible) do Result := Result.GetNext;
end;

function TElTreeItem.GetPrevVisible: TElTreeItem; { public }
begin
  Result := GetPrev;
  while Assigned(Result) and (not Result.IsVisible) do Result := Result.GetPrev;
end;

function TElTreeItem.GetPrev: TElTreeItem; { public }
var i : integer;

begin
  i := FOwner.FAllList.IndexOf(Self);
  if i = 0 then
     Result := nil
  else
     Result := FOwner.FAllList[Pred(i)];
end; { GetPrev }

function TElTreeItem.GetNext: TElTreeItem; { public }
var i : integer;

begin
  i := FOwner.FAllList.IndexOf(Self);
  if i = Pred(FOwner.FAllList.Count) then
     Result := nil
  else
     Result := FOwner.FAllList[Succ(i)];
end; { GetNext }

procedure TElTreeItem.MoveToItem(Item: TElTreeItem; Mode: TNodeAttachMode); { public }
begin
  case Mode of
    naAdd:
      begin
        if not Assigned(item) then
           raise EElTreeError.Create(STexInvItem);
        if not Assigned(item) then
           MoveTo(nil)
        else
           MoveToIns(item.FParent, item.FParent.Count);
      end;
    naAddFirst:
      begin
        if not Assigned(item) then
           MoveToIns(nil, 0)
        else
           MoveToIns(item.FParent, 0);
      end;
    naAddChild: MoveTo(item);
    naAddChildFirst: MoveToIns(item, 0);
    naInsert:
      begin
        if not Assigned(item) then
           MoveToIns(nil, 0)
        else
           MoveToIns(item.FParent, item.Index);
      end;
  end;
end; { MoveToItem }

{$ifdef ELTREE_USE_STYLES}
procedure TElTreeItem.SetUseStyles(newValue: Boolean);
begin
  if (FUseStyles <> newValue) then
  begin
    FUseStyles := newValue;
    if FUseStyles then
    begin
      if FStyles = nil then CreateStyles;
    end else
    begin
      if FStyles <> nil then
      begin
        FStyles.Free;
        FStyles := nil;
      end;
    end;
    UpdateItem;
  end; {if}
end;
{$endif}

procedure TElTreeItem.UpdateItem;
begin
  if not (FOwner.FFilteredVisibility and Hidden) then RedrawItem(true);
  with FOwner do
    if FUpdateCount > 0 then FUpdated := true else FView.Update;
end;

{$ifdef ELTREE_USE_STYLES}
function TElTreeItem.GetStyles(index: integer): TElCellStyle;
begin
  if FStyles = nil then result := nil else result := FStyles[index];
end;

procedure TElTreeItem.SetStyles(index: integer; newValue: TElCellStyle);
begin
  if FStyles = nil then CreateStyles;
  if (FStyles[index] <> newValue) then
  begin
    FStyles[index] := newValue;
  end; {if}
end;

function TElTreeItem.AddStyle: TElCellStyle;
begin
  Result := TElCellStyle.Create(Self);
  Result.FOwnerProps := true;
  Result.FFontSize := FOwner.Font.Size;
  Result.FFontStyles := FOwner.Font.Style;
  Result.FFontName := FOwner.Font.Name;
  if Assigned(FMainStyle) then Result.Assign(FMainStyle);
  if FStyles = nil then CreateStyles;
  FStyles.Add(Result);
end;

procedure TElTreeItem.RemoveStyle(Style: TElCellStyle);
begin
  FStyles.Remove(Style);
  if FStyles.Count = 0 then
  begin
    FStyles.Free;
    FStyles := nil;
  end;
end;

function TElTreeItem.GetStylesCount: Integer;
begin
  if FStyles = nil then result := 0 else result := FStyles.Count;
end;
{$endif}

procedure TElTreeItem.SetCheckBoxState(newValue: TCheckBoxState);
var
  Section: TElHeaderSection;
begin
  if (FCheckBoxState <> newValue) then
  begin
    FCheckBoxState := newValue;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end else RedrawItem(true);
      with FOwner do
        if IsUpdating then FUpdated := true else FView.Update;
    end;
  end; {if}
end; {SetCheckBoxState}

function TElTreeItem.GetChecked: boolean;
begin
  Result := FCheckBoxState = cbChecked;
end;

procedure TElTreeItem.SetChecked(newValue: Boolean);
var
  Section: TElHeaderSection;
  i: integer;
  Item: TElTreeItem;
begin
  if (Checked <> newValue) then
  begin
    if newValue then FCheckBoxState := cbChecked else FCheckBoxState := cbUnchecked;
    if (FCheckBoxType = ectRadioButton) and (newValue) then
    begin
      //FOwner.IsUpdating := true;
      if Assigned(FParent.FChildren) then
      begin
        for i := 0 to Pred(FParent.FChildren.Count) do
        begin
          Item := FParent.Children[i];
          if (Item.FCheckBoxType = ectRadioButton) and (Item <> Self) then
          begin
            Item.Checked := false;
            //FOwner.FUpdated:=true;
          end;
        end; // for
      end; // if
      //FOwner.IsUpdating := false;
    end;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end else RedrawItem(true);
      with FOwner do
        if IsUpdating then FUpdated := true else FView.Update;
    end;
  end;
end; {SetChecked}

procedure TElTreeItem.SetShowCheckBox(newValue: Boolean);
begin
  if (FShowCheckBox <> newValue) then
  begin
    FShowCheckBox := newValue;
    with FOwner do
      if (FShowCheckboxes) then
      begin
        if FShowHeader then
           AutoSizeColumn(FMainTreeCol);
        UpdateItem;
      end;
  end; {if}
end; {SetShowCheckBox}

procedure TElTreeItem.SetCheckBoxType(newValue: TElCheckBoxType);
var
  Section: TElHeaderSection;
begin
  if (FCheckBoxType <> newValue) then
  begin
    FCheckBoxType := newValue;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end
      else
        RedrawItem(true);
      with FOwner do
        if IsUpdating then
          FUpdated := true
        else
          FView.Update;
    end;
  end; {if}
end; {SetCheckBoxType}

procedure TElTreeItem.SetCheckBoxEnabled(newValue: Boolean);
var
  Section: TElHeaderSection;
begin
  if (FCheckBoxEnabled <> newValue) then
  begin
    FCheckBoxEnabled := newValue;
    if FShowCheckBox and FOwner.FShowCheckboxes then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end else RedrawItem(true);
      with FOwner do
        if IsUpdating then FUpdated := true else FView.Update;
    end;
  end; {if}
end; {SetCheckBoxEnabled}

{Soulsnake Add}
procedure TElTreeItem.SetUseCheckBoxColor(newValue: Boolean);
var
  Section: TElHeaderSection;
begin
  if (FUseCheckBoxColor <> newValue) then
  begin
    FUseCheckBoxColor := newValue;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end
      else
        RedrawItem(true);
      with FOwner do
        if IsUpdating then
          FUpdated := true
        else
          FView.Update;
    end;
  end; {if}
end; {SetUseCheckBoxColor}

procedure TElTreeItem.SetCheckBoxColor(newValue: TColor);
var
  Section: TElHeaderSection;
begin
  if (FCheckBoxColor <> newValue) then
  begin
    FCheckBoxColor := newValue;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end
      else
        RedrawItem(true);
      with FOwner do
        if IsUpdating then
          FUpdated := true
        else
          FView.Update;
    end;
  end; {if}
end; {SetCheckBoxColor}

procedure TElTreeItem.SetCheckColor(newValue: TColor);
var
  Section: TElHeaderSection;
begin
  if (FCheckColor <> newValue) then
  begin
    FCheckColor := newValue;
    if FShowCheckBox and (FOwner.FShowCheckboxes) then
    begin
      if FOwner.FShowHeader then
      begin
        Section := FOwner.FHeader.Sections[FOwner.FMainTreeCol];
        RedrawItemPart(true, Section.Left, Section.Right);
      end
      else
        RedrawItem(true);
      with FOwner do
        if IsUpdating then
          FUpdated := true
        else
          FView.Update;
    end;
  end; {if}
end; {SetCheckColor}
{End Soulsnake Add}

procedure TElTreeItem.SetSuppressButtons(newValue: Boolean);
begin
  if (FSuppressButtons <> newValue) then
  begin
    FSuppressButtons := newValue;
    with FOwner do
    begin
      if FShowButtons and FShowHeader then
         AutoSizeColumn(FMainTreeCol);
    end;
    UpdateItem;
  end; {if}
end;

procedure TElTreeItem.SetEnabled(newValue: Boolean);
begin
  if (FEnabled <> newValue) then
  begin
    FEnabled := newValue;
    UpdateItem;
  end; {if}
end; {SetEnabled}

procedure TElTreeItem.SetHidden(newValue: Boolean);
begin
  if (FHidden <> newValue) then
  begin
    FHidden := newValue;
    if FOwner <> nil then
    begin
      FOwner.IsUpdating := true;
      if FHidden = true then
      begin
        inc(FOwner.TotalHiddenCount);
      end else
      begin
        dec(FOwner.TotalHiddenCount);
      end;
      if FOwner.FilteredVisibility then
      with FOwner.FView do
      begin
        FVisUpdated := true;
        FClearVis := true;
        FClearAll := true;
        FRangeUpdate := true;
        FOwner.FUpdated := true;
      end;
      with FOwner do
      begin
        IsUpdating := false;
      end;
    end;
    with FOwner do
      if FShowHeader then
         AutoSizeColumn(FMainTreeCol);
  end; {if}
end;

function TElTreeItem.GetFullyVisible: Boolean;
begin
  if Parent <> nil then result := (not hidden) and Parent.FullyVisible else result := not hidden;
end;

procedure TElTreeItem.SetFullyVisible(newValue: Boolean);
begin
  if (FFullyVisible <> newValue) then
  begin
    if newValue and (Parent <> nil) then
    begin
      Parent.FullyVisible := true;
      Hidden := false;
    end;
  end; {if}
end;

function TElTreeItem.GetHasVisibleChildren: Boolean;
var
  i: integer;
begin
  result := false;
  if FChildren = nil then result := false else
  begin
    if not FOwner.FilteredVisibility then result := FChildren.Count > 0 else
    begin
      if FChildren.Count = 0 then exit else
        for i := 0 to FChildren.Count - 1 do
        begin
          if not TElTreeItem(THackElList(FChildren).FList[i]).Hidden then
          begin
            result := true;
            exit;
          end;
        end;
    end;
  end;
end;


function TElTreeItem.GetHeight : Integer;

    function TextLinesCount : integer;
    var i, j : integer;
    begin
      i := 1;
      result := 0;
      j := Length(FText);
      while i <= j do
      begin
        if (FText[i] = #13) and (i < j) and (FText[i + 1] = #10) then
        begin
          inc(result);
          inc(i);
        end;
        inc(i);
      end;
      if i > 1 then inc(result);
    end;

begin
  result := FOwner.LineHeight;
end;  { GetHeight }

procedure TElTreeItem.SetSuppressLines(newValue : Boolean);
{ Sets data member FSuppressLines to newValue. }


  procedure InvalidateItemPart(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
           IterateData: pointer; Tree: TCustomElTree);
  var R: TRect;
  begin
    with Item.TreeView do
      R := GetItemRect(Item.AbsoluteIndex);
    Item.RedrawItemPart(true,R.Left, R.Right);

    ContinueIterate := true;
  end;

begin
  if (FSuppressLines <> newValue) then
  begin
    FSuppressLines := newValue;
    if FOwner.FShowLines then
    begin
      FList.IterateFrom(true, @InvalidateItemPart,nil,FParent);
      with FOwner do
        if FShowHeader then
           AutoSizeColumn(FMainTreeCol);
      RedrawItem(true);
    end;
  end;  { if }
end;  { SetSuppressLines }

procedure TElTreeItem.SetRowBkColor(newValue : TColor);
{ Sets data member FRowBkColor to newValue. }
begin
  if (FRowBkColor <> newValue) then
  begin
    FRowBkColor := newValue;
    if (not FParentColors) and (FUseBkColor) then
       RedrawItem(true);
  end;  { if }
end;  { SetRowBkColor }

{$IFDEF HAS_HTML_RENDER}

procedure TElTreeItem.ReRenderMainText;
begin
  if csLoading in FOwner.ComponentState then exit;
  if not IsHTML then exit;
  if FHTMLData <> nil then
     FOwner.FView.FRender.DestroyData(FHTMLData);
  if (FText = '') or (Pos('<html>', FText) <> 1) then
     FHTMLData := nil
  else
  begin
    FHTMLData := FOwner.FView.FRender.CreateData;

    FHTMLData.DefaultStyle := FOwner.Font.Style;
    FHTMLData.DefaultFont  := FOwner.Font.Name;
    FHTMLData.DefaultColor := FOwner.TextColor;
    FHTMLData.DefaultSize  := FOwner.Font.Size;
    FHTMLData.Charset      := FOwner.Font.Charset;

    FOwner.FView.FRender.PrepareToData(FText, 0, false, FHTMLData);
  end;
end;

procedure TElTreeItem.ReRenderAllTexts;
var i : integer;
    FData : TElHTMLData;
begin
  if csLoading in FOwner.ComponentState then exit;
  if not IsHTML then exit;
  FHTMLDataArray.Clear;
  for i := 0 to ColumnText.Count -1 do
  begin
    if (Pos('<html>', ColumnText[i]) = 1) then
    begin
      FHTMLDataArray[i] := FOwner.FView.FRender.CreateData;
      FData := FHTMLDataArray[i];

      FData.DefaultStyle := FOwner.Font.Style;
      FData.DefaultFont  := FOwner.Font.Name;
      FData.DefaultColor := FOwner.TextColor;
      FData.DefaultSize  := FOwner.Font.Size;
      FData.Charset      := FOwner.Font.Charset;

      FOwner.FView.FRender.PrepareToData(ColumnText[i], 0, false, FData);
    end;
  end;
end;

procedure TElTreeItem.OnHTMLDataDestroy(Sender :TObject; Item : Pointer);
var FData : TElHTMLData;
begin
  FData := TElHTMLData(Item);
  if FOwner <> nil then
     FOwner.FView.FRender.DestroyData(FData)
  else
     FData.Free;
end;

procedure TElTreeItem.SetIsHTML(newValue : boolean);
begin
  if (FIsHTML <> newValue) then
  begin
    FRealHeight := -1;
    FIsHTML := newValue;
    if NewValue then
    begin
      FHTMLData      := nil;
      FHTMLDataArray := TElArray.Create;
      FHTMLDataArray.OnDelete := OnHTMLDataDestroy;
      ReRenderMainText;
      ReRenderAllTexts;
    end else
    begin
      if FHTMLData <> nil then
      begin
        if FOwner <> nil then
           FOwner.FView.FRender.DestroyData(FHTMLData)
        else
           FHTMLData.Free;
      end;
      FHTMLData := nil;
      FHTMLDataArray.Free;
      FHTMLDataArray := nil;
    end;
    if not (csDestroying in FOwner.ComponentState) then
    begin
      FOwner.IsUpdating := true;
      if newValue then
        inc(FOwner.TotalVarHeightCount)
      else
        dec(FOwner.TotalVarHeightCount);
      with FOwner.FView do
      begin
        FVisUpdated := true;
        FClearVis := true;
        FClearAll := true;
        FRangeUpdate := true;
        FOwner.FUpdated := true;
      end;
      FOwner.IsUpdating := false;
    end;
  end;  { if }
end;

{$ENDIF}

function TElTreeItem.GetAncestor: TElTreeItem;
begin
  Result := Self;
  while Result.Parent <> nil do
    Result := Result.Parent;
end;

function TElTreeItem.CalcSubItemsHeight: Integer;
var
  Item : TElTreeItem;
  i    : integer;
begin
  Result := 0;
  if Expanded and (FChildren <> nil) then
  begin
    for i := 0 to FChildren.Count - 1 do
    begin
      Item := FChildren[i];
      if Item.Hidden then
        Continue;
      inc(Result, FOwner.LineHeight);
      if Item.Expanded then
        inc(Result, Item.CalcSubItemsHeight);
    end;
  end;
end;

procedure TElTreeItem.SetStrikedOutLine(const Value: boolean);
begin
  if FStrikedOutLine <> Value then begin
    FStrikedOutLine := Value;

    UpdateItem;
  end;
end;

procedure TElTreeItem.SetStrikedLineColor(const Value: TColor);
begin
  if FStrikedLineColor <> Value then begin
    FStrikedLineColor := Value;

    UpdateItem;
  end;
end;

function TElTreeItem.GetStrikedOutLine: boolean;
begin
  Result := FStrikedOutLine;
end;

procedure TElTreeItem.SetDrawHLine(const Value: boolean);
begin
  if FDrawHLine <> Value then
  begin
    FDrawHLine := Value;
    UpdateItem;
  end;
end;

procedure TElTreeItem.SetAllowEdit(const Value: boolean);
begin
  if FAllowEdit <> Value then
    FAllowEdit := Value;
end;

// ****************************************************************************
//                               TElTreeItems   
// ****************************************************************************

constructor TElTreeItems.Create(AOwner: TCustomElTree);
begin
  inherited Create;
  FOwner := AOwner;
  FItemClass := TElTreeItem;
  FRoot := FItemClass.Create(FOwner);
  FRoot.FList := self;
  FRoot.FParent := nil;
  FRoot.FRoot := FRoot;
  FRoot.FState := [stsExpanded];
end;

destructor TElTreeItems.Destroy;
begin
  FOwner.IsUpdating := true;
  FRoot.Clear;        
  FRoot.Free;
  inherited Destroy;
end;

function TElTreeItems.GetVisCount: integer;
begin
  result := FOwner.TotalVisCount;
end;

procedure TElTreeItems.DefineProperties(Filer: TFiler);

  function WriteNodes: Boolean;
  begin
    Result := Count > 0;
  end;

begin
  inherited DefineProperties(Filer);
  Filer.DefineBinaryProperty('Data', ReadData, WriteData, WriteNodes);
end;

procedure TElTreeItems.SetItem(Index: Integer; Value: TElTreeItem);
begin
  GetItem(Index).Assign(Value);
end;

procedure TElTreeItems.Iterate;
var
  j: integer;
  DoContinue: boolean;

  procedure IntIterate(VisibleOnly: boolean; Item: TElTreeItem);
  var
    i, k: integer;
  begin
    inc(j);
    if (j >= 0) and ((not VisibleOnly) or ((not Item.Hidden) or (not FOwner.FilteredVisibility))) then IterateProc(Item, j, DoContinue, IterateData, FOwner);
    if not (DoContinue) then exit;
    if (not (VisibleOnly)) or (Item.Expanded) then
    begin
      if Item.FChildren = nil then
         k := 0
      else
         k := Item.FChildren.Count;
      for i := 0 to k - 1 do
      begin
        if (not VisibleOnly) or ((not TElTreeItem(THackElList(Item.FChildren).FList[i]).Hidden) or (not FOwner.FilteredVisibility)) then
          IntIterate(VisibleOnly, TElTreeItem(THackElList(Item.FChildren).FList[i]));
        if not (DoContinue) then exit;
      end;
    end;
  end;

begin
  j := -2;
  DoContinue := true;
  IntIterate(VisibleOnly, FRoot);
end;

procedure TElTreeItems.IterateBranch;
var
  j: integer;
  DoContinue: boolean;
  Stack: TElStack;
  TSI: TElTreeItem;

  procedure IntIterate(VisibleOnly: boolean; Item: TElTreeItem; StartFrom: TElTreeItem; var Stack: TElStack);
  var
    i, k, l: integer;
  begin
    inc(j);
    if (Stack <> nil) and (Stack.Count > 0) then
    begin
      if Item.FChildren = nil then
         k := -1
      else
         k := Item.FChildren.IndexOf(Stack.Pop);
      if Stack.Count = 0 then
      begin
        Stack.Free;
        Stack := nil;
      end;
    end
    else
    begin
      if not Item.IsUnder(StartFrom) then
         DoContinue := false
      else
        if (j >= 0) and ((not VisibleOnly) or ((not Item.Hidden) or (not FOwner.FilteredVisibility))) then
           IterateProc(Item, j, DoContinue, IterateData, FOwner);
      if not (DoContinue) then
         exit;
      k := 0;
    end;
    if (not (VisibleOnly)) or (Item.Expanded) then
    begin
      if Item.FChildren = nil then
         l := 0
      else
         l := Item.FChildren.Count;
      if k <> - 1 then
        for i := k to l - 1 do
        begin
          if (not VisibleOnly) or ((not TElTreeItem(THackElList(Item.FChildren).FList[i]).Hidden) or (not FOwner.FilteredVisibility)) then
              IntIterate(VisibleOnly, TElTreeItem(THackElList(Item.FChildren).FList[i]), StartFrom, Stack);
          if not DoContinue then
             exit;
        end;
    end;
  end;

begin
  j := -2;
  if BranchParent <> nil then
  begin
    Stack := TElStack.Create;
    TSI := BranchParent;
    Stack.Push(TSI);
    while TSI.Parent <> nil do
    begin
      Stack.Push(TSI.Parent);
      TSI := TSI.Parent;
    end; // while
    DoContinue := true;
    IntIterate(VisibleOnly, FRoot, BranchParent, Stack);
    Stack.Free;
  end
  else
    Iterate(VisibleOnly, IterateProc, IterateData);
end;

procedure TElTreeItems.IterateFrom;
var
  j: integer;
  DoContinue: boolean;
  Stack: TElStack;
  TSI: TElTreeItem;

  procedure IntIterate(VisibleOnly: boolean; Item: TElTreeItem; StartFrom: TElTreeItem; var Stack: TElStack);
  var
    i, k, l: integer;
  begin
    inc(j);
    if (Stack <> nil) and (Stack.Count > 0) then
    begin
      if Item.FChildren = nil then
        k := -1
      else
        k := Item.FChildren.IndexOf(Stack.Pop);
      if Stack.Count = 0 then
      begin
        Stack.Free;
        Stack := nil;
      end;
    end
    else
    begin
      if (j >= 0) and ((not VisibleOnly) or ((not Item.Hidden) or (not FOwner.FilteredVisibility))) then IterateProc(Item, j, DoContinue, IterateData, FOwner);
      if not (DoContinue) then exit;
      k := 0;
    end;
    if (not (VisibleOnly)) or (Item.Expanded) then
    begin
      if Item.FChildren = nil
         then l := 0
      else
         l := Item.FChildren.Count;
      if k <> - 1 then
        for i := k to l - 1 do
        begin
          if (not VisibleOnly) or ((not TElTreeItem(THackElList(Item.FChildren).FList[i]).Hidden) or (not FOwner.FilteredVisibility)) then
            IntIterate(VisibleOnly, TElTreeItem(THackElList(Item.FChildren).FList[i]), StartFrom, Stack);
          if not (DoContinue) then exit;
        end;
    end;
  end;

begin
  j := -2;
  if StartFrom <> nil then
  begin
    Stack := TElStack.Create;
    TSI := StartFrom;
    Stack.Push(TSI);
    while TSI.Parent <> nil do
    begin
      Stack.Push(TSI.Parent);
      TSI := TSI.Parent;
    end; // while
  end else Stack := nil;
  DoContinue := true;
  IntIterate(VisibleOnly, FRoot, StartFrom, Stack);
  if Stack <> nil then Stack.Free;
end;

procedure TElTreeItems.IterateBack;
var
  j: integer;
  DoContinue: boolean;

  procedure IntIterate(VisibleOnly: boolean; Item: TElTreeItem);
  var
    i, k: integer;
  begin
    if not (VisibleOnly) or (Item.Expanded) then
    begin
      if Item.FChildren = nil then
        k := 0
      else
        k := Item.FChildren.Count;
      for i := k - 1 downto 0 do
      begin
        if (not VisibleOnly) or ((not TElTreeItem(THackElList(Item.FChildren).FList[i]).Hidden) or (not FOwner.FilteredVisibility)) then
           IntIterate(VisibleOnly, TElTreeItem(THackElList(Item.FChildren).FList[i]));
        if not (DoContinue) then exit;
      end;
    end;
    dec(j);
    if (j >= 0) and ((not VisibleOnly) or ((not Item.Hidden) or (not FOwner.FilteredVisibility))) then
       IterateProc(Item, j, DoContinue, IterateData, FOwner);
    if not (DoContinue) then exit;
  end;

begin
  if VisibleOnly then
     j := FOwner.TotalVisCount
  else
     j := FOwner.FAllList.Count;
  DoContinue := true;
  IntIterate(VisibleOnly, FRoot);
end;

// Changed 10/28/98 by EM

procedure TElTreeItems.IterateBackFrom;
var
  j: integer;
  DoContinue: boolean;
  Stack: TElStack;
  TSI: TElTreeItem;

  procedure IntIterate(VisibleOnly: boolean; Item: TElTreeItem; StartFrom: TElTreeItem; var Stack: TElStack);
  var
    i, k: integer;
  begin
    if (Stack <> nil) and (Stack.Count > 0) then
    begin
      if Item.FChildren = nil then
        k := -1
      else
        k := Item.FChildren.IndexOf(Stack.Pop);
      if Stack.Count = 0 then
      begin
        Stack.Free;
        Stack := nil;
      end;
    end
    else
    begin
      if Item.FChildren = nil then k := -1 else k := Item.FChildren.Count - 1;
    end;
    if (not (VisibleOnly) or (Item.Expanded)) and (Item <> StartFrom) then
      for i := k downto 0 do
      begin
        if (not VisibleOnly) or ((not TElTreeItem(THackElList(Item.FChildren).FList[i]).Hidden) or (not FOwner.FilteredVisibility)) then IntIterate(VisibleOnly, TElTreeItem(THackElList(Item.FChildren).FList[i]), StartFrom, Stack);
        if not (DoContinue) then exit;
      end;
    dec(j);
    if (j >= 0) and ((not VisibleOnly) or ((not Item.Hidden) or (not FOwner.FilteredVisibility))) and (Item <> FRoot) then IterateProc(Item, j, DoContinue, IterateData, FOwner);
    if (not DoContinue) then exit;
  end;

begin
  if VisibleOnly then
     j := FOwner.TotalVisCount
  else
     j := FOwner.FAllList.Count;
  if StartFrom <> nil then
  begin
    Stack := TElStack.Create;
    TSI := StartFrom;
    Stack.Push(TSI);
    while TSI.Parent <> nil do
    begin
      Stack.Push(TSI.Parent);
      TSI := TSI.Parent;
    end; // while
  end else Stack := nil;
  DoContinue := true;
  IntIterate(VisibleOnly, FRoot, StartFrom, Stack);
  if Stack <> nil then Stack.Free;
end;

function TElTreeItems.GetVisItem;
var i, j, idx : integer;
    Item : TElTreeItem;
begin
  if (index < 0) or (index >= FOwner.TotalVisCount) then
  begin
    result := nil;
    exit;
  end;

  i := 0;
  idx := 0;
  j := FOwner.FAllList.Count;
  while i < j do
  begin
    Item := TElTreeItem(FOwner.FAllList[i]);
    if (FOwner.FilteredVisibility and Item.Hidden) then
    begin
      i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      if idx = index then
      begin
        result := Item;
        exit;
      end;
      inc(idx);
      if not Item.Expanded then
         i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  result := nil;
end;

function TElTreeItems.GetItem;
begin
  if (index < 0) or (index >= Count) then
  begin
    result := nil;
    exit;
  end;
  result := TElTreeItem(THackElList(FOwner.FAllList).FList[index]);
end;

function TElTreeItems.GetVisIndex;
var i, j, idx : integer;
    Item : TElTreeItem;

begin
  if Child = nil then
  begin
    result := -1;
    exit;
  end;

  i := 0;
  idx := 0;
  j := FOwner.FAllList.Count;
  while i < j do
  begin
    Item := TElTreeItem(FOwner.FAllList[i]);
    if (FOwner.FilteredVisibility and Item.Hidden) then
    begin
      i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      if Child = Item then
      begin
        result := idx;
        exit;
      end;
      inc(idx);
      if not Item.Expanded then
         i := FOwner.FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  result := -1;
end;

function TElTreeItems.GetAbsIndex;
begin
  if Child = nil then
    result := -1
  else
    result := FOwner.FAllList.IndexOf(Child);
end;

procedure TElTreeItems.DeleteItem;
var
  TSI: TElTreeItem;
begin
  if (Child = nil) or (child = FRoot) then exit;
  FOwner.IsUpdating := true;
  try
    TSI := Child.FParent;
    TSI.DeleteChild(Child);
    if TSI.FullyExpanded and TSI.Expanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FClearAll := true;
        FVisUpdated := true;
      end;
      FOwner.FUpdated := true;
    end;
  finally
    FOwner.IsUpdating := false;
  end;
end;

// OLD - NOT USED ANYMORE
procedure TElTreeItems.RemoveItem;
var
  TSI: TElTreeItem;
begin
  if (Child = nil) or (child = FRoot) then exit;
  FOwner.IsUpdating := true;
  try
    TSI := Child.FParent;
    // Move focus, if needed
    if Child = FOwner.ItemFocused then
    begin
      //if TSI = FRoot then
      //begin
        FOwner.DoSetFocused(TSI.GetPrevChild(Child), false, false);
        if FOwner.ItemFocused = nil then FOwner.DoSetFocused(TSI.GetNextChild(Child), false, false);
        if (FOwner.ItemFocused = nil) and (TSI <> FRoot) then FOwner.DoSetFocused(TSI, false, false);
      //end else
      //  FOwner.DoSetFocused(TSI, false, false);
    end;
    // actually remove child
    TSI.RemoveChild(Child);
    Child.FParent := nil;
    if TSI.FullyExpanded and TSI.Expanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FVisUpdated := true;
      end;
    end;
    with FOwner do
    begin
      FUpdated := true;
      FView.FRangeUpdate := true;
    end;
  finally
    FOwner.IsUpdating := false;
  end;
end;

procedure TElTreeItems.AllocateStorage(MaxItems : integer);
begin
  with FOwner do
    if FAllList.Capacity < MaxItems then FAllList.Capacity := MaxItems;
end;

procedure TElTreeItems.AddExistingItem(Item, Parent: TElTreeItem); { public }
var
  Child, AParent: TElTreeItem;
begin
  FOwner.IsUpdating := true;   
  Child := Item;
  Child.FList := self;
  Child.FParent := Parent;
  if Child.FParent = nil then Child.FParent := FRoot;
  AParent := Child.FParent;
  AParent.AddChild(Child);
  //inc(FCount);
  with FOwner do
  begin
    if AParent.FullyExpanded and AParent.Expanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FVisUpdated := true;
      end;
    end;
    FUpdated := true;
    FView.FRangeUpdate := true;
    IsUpdating := false;
  end;
end;

procedure TElTreeItems.InsertExistingItem(Item, Parent: TElTreeItem; Index: integer); { public }
var
  Child, AParent: TElTreeItem;
begin
  FOwner.IsUpdating := true;
  Child := Item;
  Child.FList := self;
  Child.FParent := Parent;
  if Child.FParent = nil then Child.FParent := FRoot;
  AParent := Child.FParent;
  if (AParent.FChildren = nil) then AParent.FChildren := TElList.Create; 
  if (index > AParent.FChildren.Count) or (index < 0) then
    raise EElTreeError.Create(STExOutOfBounds);
  AParent.InsertChild(Index, Child);
  //inc(FCount);
  with FOwner do
  begin
    if AParent.FullyExpanded and AParent.Expanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FClearAll := true;
        FVisUpdated := true;
      end;
    end;
    with FOwner.FView do
    begin
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

function TElTreeItems.InsertItem;
var
  Child, AParent: TElTreeItem;
begin
  FOwner.IsUpdating := true;
  Child := CreateItem(FOwner);
  Child.FList := self;
  Child.FParent := Parent;
  if Child.FParent = nil then Child.FParent := FRoot;
  AParent := Child.FParent;
  if (AParent.FChildren = nil) then AParent.FChildren := TElList.Create;
  if (index > AParent.FChildren.Count) or (index < 0) then
    raise EElTreeError.Create(STExOutOfBounds);
  AParent.InsertChild(Index, Child);
  //inc(FCount);

  result := Child;
  with FOwner do
  begin
    if AParent.FullyExpanded and AParent.Expanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FClearAll := true;
        FVisUpdated := true;
      end;
    end;
    with FOwner.FView do
    begin
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

function TElTreeItems.AddLastItem(Parent: TElTreeItem): TElTreeItem;
var
  Child, AParent: TElTreeItem;
begin
  FOwner.IsUpdating := true;
  Child := CreateItem(FOwner);
  Child.FList := self;
  Child.FParent := Parent;
  if Child.FParent = nil then Child.FParent := FRoot;
  AParent := Child.FParent;
  AParent.AddLastChild(Child);
  //inc(FCount);
  result := Child;
  with FOwner do
  begin
    if AParent.Expanded and AParent.FullyExpanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FVisUpdated := true;
      end;
    end;
    with FOwner.FView do
    begin
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

function TElTreeItems.AddItem;
var
  Child, AParent: TElTreeItem;
begin
  FOwner.IsUpdating := true;
  Child := CreateItem(FOwner);
  Child.FList := self;
  Child.FParent := Parent;
  if Child.FParent = nil then Child.FParent := FRoot;
  AParent := Child.FParent;
  AParent.AddChild(Child);
  //inc(FCount);
  result := Child;
  with FOwner do
  begin
    if AParent.Expanded and AParent.FullyExpanded then
    begin
      with FOwner.FView do
      begin
        FClearVis := true;
        FVisUpdated := true;
      end;
    end;
    with FOwner.FView do
    begin
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

procedure TElTreeItems.Assign;
begin
  if Source is TElTreeItems then
  begin
    if FOwner <> nil then FOwner.IsUpdating := true;
    FRoot.Assign(TElTreeItems(Source).FRoot);
    //FCount := TElTreeItems(Source).FCount;
    if FOwner <> nil then with FOwner.FView do
      begin
        FHRange  := -1;
        FOwner.FUpdated := true;
        FVisUpdated := true;
        FClearVis := true;
        FClearAll := true;
        FOwner.IsUpdating := false;
      end;
  end else inherited;
end;

(*
procedure TElTreeItems.Clear;
var i : integer;
begin
  i := Count;
  if FOwner <> nil then FOwner.IsUpdating := true;
  FRoot.Clear;
  if FOwner <> nil then with FOwner.FView do
    begin
      FHRange := -1;
      if i > 0 then
      begin
        FVisUpdated := true;
        FClearVis := true;
        FClearAll := true;
      end;
      FOwner.FUpdated := true;
      FOwner.IsUpdating := false;
    end;
end;
*)

// Version 3.2
procedure TElTreeItems.Clear;
var i : integer;
begin
  i := Count;
  if FOwner <> nil then
    FOwner.IsUpdating := true;
  FOwner.DoSetFocused(nil, false);
  FOwner.FView.FVisible.Clear;
  FRoot.Clear;
  if FOwner <> nil then
  with FOwner.FView do
  begin
    FHRange := -1;
    if i > 0 then
    begin
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
    end;
    FOwner.FUpdated := true;
    FOwner.IsUpdating := false;
  end;
end;

function TElTreeItems.GetCount;
begin
  if Self.FOwner <> nil then result := FOwner.FAllList.Count else result := 0;
end;

function TElTreeItems.CreateItem;
begin
  result := FItemClass.Create(FOwner);
end;

procedure TElTreeItems.ReadData;
begin
  if FOwner <> nil then FOwner.IsUpdating := true;
  FRoot.Clear;
  FRoot.ReadData(Stream);
  if FOwner <> nil then
  with FOwner.FView do
    begin
      FHRange := -1;
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
      FOwner.FUpdated := true;
      FOwner.IsUpdating := false;
    end;
end;

procedure TElTreeItems.WriteData;
var
  TSI: TElTreeItem;
begin
  TSI := nil;
  if FOwner <> nil then
  begin
    TSI := FOwner.ItemFocused;
    FOwner.DoSetFocused(nil, false);
  end;
  FRoot.WriteData(Stream);
  if FOwner <> nil then
  begin
    FOwner.DoSetFocused(TSI, false);
  end;
end;

procedure TElTreeItems.SaveToStream;
begin
  WriteData(Stream);
end;

procedure TElTreeItems.LoadFromStream;
begin
  ReadData(Stream);
end;

procedure TElTreeItems.SaveToFile;
var
  T: TFileStream;
begin
  T := nil;
  try
    T := TFileStream.Create(FileName, fmCreate or fmShareDenyWrite);
    SaveToStream(T);
  finally
    T.Free;
  end;
end;

procedure TElTreeItems.LoadFromFile;
var
  T: TFileStream;
begin
  T := nil;
  try
    T := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
    LoadFromStream(T);
  finally
    T.Free;
  end;
end;

function TElTreeItems.Add(Item: TElTreeItem; Text: string): TElTreeItem; { public }
begin
  if Item = nil
     then result := AddItem(nil)
     else result := AddItem(Item.FParent);
  Result.Text := Text;
end; { Add }

function TElTreeItems.AddChild(Item: TElTreeItem; Text: string): TElTreeItem; { public }
begin
  result := AddItem(Item);
  Result.Text := Text;
end; { AddChild }

function TElTreeItems.AddChildFirst(Item: TElTreeItem; Text: string): TElTreeItem; { public }
begin
  result := InsertItem(0, Item);
  Result.Text := Text;
end; { AddChildFirst }

function TElTreeItems.AddChildObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; { public }
begin
  Result := AddItem(Item);
  Result.Text := Text;
  Result.Data := Ptr;
end; { AddChildObject }

function TElTreeItems.AddChildObjectFirst(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; { public }
begin
  result := InsertItem(0, Item);
  Result.Text := Text;
  Result.Data := Ptr;
end; { AddChildObjectFirst }

function TElTreeItems.AddFirst(Item: TElTreeItem; Text: string): TElTreeItem; { public }
begin
  if Item = nil then result := InsertItem(0, nil)
  else result := InsertItem(0, Item.FParent);
  Result.Text := Text;
end; { AddFirst }

function TElTreeItems.AddObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; { public }
begin
  if Item = nil then result := AddItem(nil) else result := AddItem(Item.FParent);
  Result.Text := Text;
  Result.Data := Ptr;
end; { AddObject }

function TElTreeItems.AddObjectFirst(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; { public }
begin
  if Item = nil then result := InsertItem(0, nil) else result := InsertItem(0, Item.FParent);
  Result.Text := Text;
  Result.Data := Ptr;
end; { AddObjectFirst }

function TElTreeItems.Insert(Item: TElTreeItem; Text: string): TElTreeItem; { public }
var
  i: integer;
  FParent: TElTreeItem;
begin
  if Item = nil then
  begin
    i := 0;
    FParent := nil;
  end else
  begin
    i := Item.Index;
    FParent := Item.FParent;
  end;
  result := InsertItem(i, FParent);
  Result.Text := Text;
end; { Insert }

// Changed 10/28/98 by EM

function TElTreeItems.InsertObject(Item: TElTreeItem; Text: string; Ptr: pointer): TElTreeItem; { public }
var
  i: integer;
  FParent: TElTreeItem;
begin
  if Item = nil then
  begin
    i := 0;
    FParent := nil;
  end else
  begin
    i := Item.Index;
    FParent := Item.FParent;
  end;
  result := InsertItem(i, FParent);
  Result.Text := Text;
  Result.Data := Ptr;
end; { InsertObject }

procedure TElTreeItems.Delete; { public }
begin
  DeleteItem(Item);
end; { Delete }

function TElTreeItems.GetFirstNode: TElTreeItem; { public }
begin
  Result := Item[0];
end; { GetFirstNode }

// Changed 10/27/98 by EM

procedure TElTreeItems.BeginUpdate; { public }
begin
  FOwner.IsUpdating := true;
end; { BeginUpdate }

// Changed 10/27/98 by EM

procedure TElTreeItems.EndUpdate; { public }
begin
  FOwner.IsUpdating := false;
end; { EndUpdate }


// Changed 10/28/98 by EM

function TElTreeItems.InsertAfterObject(Item: TElTreeItem; Text: string; Ptr: Pointer): TElTreeItem; { public }
var
  i: integer;
  FParent: TElTreeItem;
begin
  if Item = nil then
  begin
    i := 0;
    FParent := nil;
  end else
  begin
    i := Succ(Item.Index);
    FParent := Item.FParent;
  end;
  result := InsertItem(i, FParent);
  Result.Text := Text;
  Result.Data := Ptr;
end; { InsertAfterObject }

// Changed 10/28/98 by EM

function TElTreeItems.InsertAfter(Item: TElTreeItem; Text: string): TElTreeItem; { public }
var
  i: integer;
  FParent: TElTreeItem;
begin
  if Item = nil then
  begin
    i := 0;
    FParent := nil;
  end else
  begin
    i := Item.Index + 1;
    FParent := Item.FParent;
  end;
  result := InsertItem(i, FParent);
  Result.Text := Text;
end; { InsertAfter }

type
  TSRec = record
    TextToFind: string;
    WholeTextOnly: boolean;
    ColumnNum: integer;
    StartItem: TElTreeItem;
    DataToFind: pointer;
    CheckStartItem,
      LookForData,
      SubItemsOnly: boolean;
    NoCase: boolean;
    Result: TElTreeItem;
  end;
  PSRec = ^TSRec;

  TSRecEx = record
    ColumnNum: integer;
    StartItem: TElTreeItem;
    CheckStartItem,
      SubItemsOnly: boolean;
    Result: TElTreeItem;
    CompProc: TElLookupCompareProc;
    SearchDetails: pointer;
  end;
  PSRecEx = ^TSRecEx;

function TElTreeItems.LookBackForItemEx2(StartItem: TElTreeItem; ColumnNum: integer;
        CheckStartItem, SubItemsOnly, VisibleOnly, CheckCollapsed: boolean;
        SearchDetails: pointer;
        CompareProc: TElLookupCompareProc): TElTreeItem;

  procedure IntFind(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  var
    b: boolean;

  begin
    if (Item = PSRecEx(IterateData).StartItem) and (not PSRecEx(IterateData).CheckStartItem) then exit;
    if ((not PSRecEx(IterateData).CheckStartItem) or (Item <> PSRecEx(IterateData).StartItem)) and
    (PSRecEx(IterateData).SubItemsOnly) and (not Item.IsUnder(PSRecEx(IterateData).StartItem)) then
    begin
      ContinueIterate := false;
      exit;
    end;
    b := PSRecEx(IterateData).CompProc(Item, PSRecEx(IterateData).SearchDetails);
    if b then
    begin
      PSRecEx(IterateData).result := Item;
      ContinueIterate := false;
      exit;
    end;
  end;

var
  SRec: TSRecEx;
begin
  SRec.ColumnNum := ColumnNum;
  SRec.StartItem := StartItem;
  SRec.CheckStartItem := CheckStartItem;
  SRec.SubItemsOnly := SubItemsOnly;
  SRec.CompProc := CompareProc;
  SRec.SearchDetails := SearchDetails;
  SRec.Result := nil;
  try
    IterateBackFrom(VisibleOnly, @IntFind, @SRec, StartItem);
  finally
    Result := SRec.Result;
  end;
end;

function TElTreeItems.LookForItem(StartItem: TElTreeItem;
  TextToFind: string;
  DataToFind: pointer;
  ColumnNum: integer;
  LookForData,
  CheckStartItem,
  SubItemsOnly,
  VisibleOnly,
  NoCase: boolean): TElTreeItem;

type
  TSRec = record
    TextToFind: string;
    ColumnNum: integer;
    StartItem: TElTreeItem;
    DataToFind: pointer;
    CheckStartItem,
      LookForData,
      SubItemsOnly: boolean;
    NoCase: boolean;
    Result: TElTreeItem;
  end;
  PSRec = ^TSRec;

  procedure IntFind(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  var
    i: integer;
    s: string;
  begin
    if (Item = PSRec(IterateData).StartItem) and (not PSRec(IterateData).CheckStartItem) then exit;
    if (PSRec(IterateData).SubItemsOnly) and (not Item.IsUnder(PSRec(IterateData).StartItem)) then
    begin
      ContinueIterate := false;
      exit;
    end;
    if PSRec(IterateData).LookForData then
    begin
      if Item.FData = PSRec(IterateData).DataToFind then
      begin
        PSRec(IterateData).result := Item;
        ContinueIterate := false;
        exit;
      end;
    end else
    begin
      if (PSRec(IterateData).ColumnNum = -1) or (PSRec(IterateData).ColumnNum = Tree.MainTreeColumn) then s := Item.Text else
      begin
        i := PSRec(IterateData).ColumnNum;
        if i > Tree.MainTreeColumn then dec(i);
        if Item.ColumnText.Count <= i then s := ''
        else s := Item.ColumnText[i];
      end;
      if PSRec(IterateData).NoCase then
      begin
        if AnsiSameText(S, PSRec(IterateData).TextToFind) then
        begin
          PSRec(IterateData).result := Item;
          ContinueIterate := false;
          exit;
        end;
      end else
      begin
        if S = PSRec(IterateData).TextToFind then
        begin
          PSRec(IterateData).result := Item;
          ContinueIterate := false;
          exit;
        end;
      end;
    end;
  end;

var
  SRec: TSRec;
begin
  SRec.TextToFind := TextToFind;
  SRec.ColumnNum := ColumnNum;
  SRec.StartItem := StartItem;
  SRec.LookForData := LookForData;
  SRec.DataToFind := DataToFind;
  SRec.NoCase := NoCase;
  SRec.CheckStartItem := CheckStartItem;
  SRec.SubItemsOnly := SubItemsOnly;
  SRec.Result := nil;
  try
    IterateFrom(VisibleOnly, @IntFind, @SRec, StartItem);
  finally
    Result := SRec.Result;
  end;
end;

function TElTreeItems.LookForItemEx(StartItem: TElTreeItem; ColumnNum: integer; CheckStartItem, SubItemsOnly,
  VisibleOnly: boolean; SearchDetails: pointer; CompareProc: TElLookupCompareProc): TElTreeItem;

type
  TSRec = record
    ColumnNum: integer;
    StartItem: TElTreeItem;
    CheckStartItem,
      SubItemsOnly: boolean;
    Result: TElTreeItem;
    CompProc: TElLookupCompareProc;
    SearchDetails: pointer;
  end;
  PSRec = ^TSRec;

  procedure IntFind(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  var
    b: boolean;

  begin
    if (Item = PSRec(IterateData).StartItem) and (not PSRec(IterateData).CheckStartItem) then exit;
    if (PSRec(IterateData).SubItemsOnly) and (not Item.IsUnder(PSRec(IterateData).StartItem)) then
    begin
      ContinueIterate := false;
      exit;
    end;
    b := PSRec(IterateData).CompProc(Item, PSRec(IterateData).SearchDetails);
    if b then
    begin
      PSRec(IterateData).result := Item;
      ContinueIterate := false;
      exit;
    end;
  end;

var
  SRec: TSRec;
begin
  SRec.ColumnNum := ColumnNum;
  SRec.StartItem := StartItem;
  SRec.CheckStartItem := CheckStartItem;
  SRec.SubItemsOnly := SubItemsOnly;
  SRec.CompProc := CompareProc;
  SRec.SearchDetails := SearchDetails;
  SRec.Result := nil;
  try
    IterateFrom(VisibleOnly, @IntFind, @SRec, StartItem);
  finally
    Result := SRec.Result;
  end;
end;

function TElTreeItems.GetRootCount: Integer;
begin
  Result := FRoot.Count;
end;

function TElTreeItems.GetRootItem(Index: Integer): TElTreeItem;
begin
  Result := FRoot.Item[Index];
end;

// ****************************************************************************
//                                 TCustomElTree          
// ****************************************************************************

procedure TCustomElTree.SetBSVLines;
begin
  if (FBSVLines = value) then exit;
  IsUpdating := true;
  with FView do
  begin
    FBSVLines := value;
    if BarStyle then
    begin
      FClearAll := true;
      FUpdated := true;
    end;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.AlignPieces;
var TreeRect,
    HeaderRect,
    HScrollRect,
    VScrollRect : TRect;
    BlindRect   : TRect;
    hh, hs, wv  : integer;
begin
  if not HandleAllocated then exit;
  FIgnoreSBChange := true;
  try
    TreeRect := ClientRect;
    if FShowHeader then
    begin
      SavedHH := GetHeaderHeight;
      hh := SavedHH;
      HeaderRect := Rect(0, 0, TreeRect.Right, hh);
      if StickyHeaderSections then inc(HeaderRect.Right);
      TreeRect.Top := hh;
    end;
    SetRectEmpty(BlindRect);
    if FHScrollVisible and FUseCustomBars then
    begin
      hs := FHScrollBar.Height;
      Dec(TreeRect.Bottom, hs);
      HScrollRect := Rect(0, TreeRect.Bottom, TreeRect.Right, TreeRect.Bottom + hs);
    end;
    if FVScrollVisible and FUseCustomBars then
    begin
      wv := FVScrollBar.Width;
      if RightAlignedText xor ScrollBarOpposite then
      begin
        VScrollRect := Rect(TreeRect.Left, 0, TreeRect.Left + wv, TreeRect.Bottom);
        Inc(HeaderRect.Left, wv);
        Inc(TreeRect.Left, wv);
        Inc(HScrollRect.Left, wv);
        if FHScrollVisible then
           BlindRect := Rect(0, VScrollRect.Bottom + 1, VScrollRect.Right, HScrollRect.Bottom);
      end else
      begin
        VScrollRect := Rect(TreeRect.Right - wv, 0, TreeRect.Right, TreeRect.Bottom);
        dec(HeaderRect.Right, wv);
        dec(TreeRect.Right, wv);
        dec(HScrollRect.Right, wv);
        if FHScrollVisible then
           BlindRect := Rect(VScrollRect.Left, VScrollRect.Bottom + 1, VScrollRect.Right, HScrollRect.Bottom);
      end;
    end;
    with HeaderRect do
      if FShowHeader then
        SetWindowPos(FHeader.Handle, HWND_TOP, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOZORDER or SWP_NOOWNERZORDER or SWP_SHOWWINDOW or SWP_NOSENDCHANGING)
      else
        SetWindowPos(FHeader.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_HIDEWINDOW);
    with TreeRect do
        SetWindowPos(FView.Handle, HWND_TOP, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOZORDER or SWP_SHOWWINDOW or SWP_NOSENDCHANGING);
    with HScrollRect do
      if FHScrollVisible and FUseCustomBars then
        SetWindowPos(FHScrollBar.Handle, HWND_TOP, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE or SWP_NOOWNERZORDER or SWP_NOZORDER or SWP_SHOWWINDOW or SWP_NOSENDCHANGING)
      else
        SetWindowPos(FHScrollBar.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_HIDEWINDOW);
    with VScrollRect do
      if FVScrollVisible and FUseCustomBars then
        SetWindowPos(FVScrollBar.Handle, HWND_TOP, VScrollRect.Left, VScrollRect.Top, VScrollRect.Right - VScrollRect.Left, VScrollRect.Bottom - VScrollRect.Top, SWP_NOACTIVATE or SWP_NOOWNERZORDER {or SWP_NOZORDER }or SWP_SHOWWINDOW or SWP_NOSENDCHANGING)
      else
        SetWindowPos(FVScrollBar.Handle, HWND_TOP, 0, 0, 0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or SWP_HIDEWINDOW);
    if not IsRectEmpty(BlindRect) then
      Invalidaterect(Handle, @BlindRect, true); 
  finally
    FIgnoreSBChange := false;
  end;
end;

function TCustomElTree.GetRoot: TElTreeItem;
begin
  result := FItems.FRoot;
end;

procedure TCustomElTree.FontChanged(Sender: TObject);
{$IFDEF HAS_HTML_RENDER}
var i : integer;
    Item : TElTreeItem;
{$ENDIF}
begin
  Perform(CM_FONTCHANGED, 0, 0);
  {$IFDEF HAS_HTML_RENDER}
  if (csLoading in ComponentState) then exit;
  for i := 0 to Pred(FItems.Count) do
  begin
    Item := FAllList.FastGet(i);
    if Item.IsHTML then
    begin
      Item.ReRenderMainText;
      Item.ReRenderAllTexts;
    end;
  end;
  {$ENDIF}
end;

type THackScrollBar = class(TElScrollBar)
       property Font;
       property NoScrollMessages;
     end;

constructor TCustomElTree.Create;
begin
  inherited;
  FUseCustomBars := true;
  Font.OnChange := FontChanged;
  ControlStyle :=
{$IFDEF VER90}
  [csClickEvents, csOpaque, csDoubleClicks, csCaptureMouse,
    csDisplayDragImage, csReplicatable];
{$ELSE}
  [csClickEvents, csOpaque, csDoubleClicks, csCaptureMouse,
    csDisplayDragImage, csReplicatable, csReflector];
{$ENDIF}
  FAllList := TElList.Create;
  FSelectedList := TElList.Create;
  FItems := CreateItems;
  BMP := TBitmap.Create;
  Height := 100;
  Width := 200;
  FView := CreateView;
{$IFDEF HAS_HTML_RENDER}
  FView.FRender := TElHTMLRender.Create;
  FView.FRender.OnImageNeeded := TriggerImageNeededEvent;
{$ENDIF}
  FView.Parent := Self;
  FView.TabStop := false;
  FView.OnClick := ClickTransfer;
  FView.OnDblClick := DblClickTransfer;
  FView.OnDragDrop := DropTransfer;
  FView.OnDragOver := OverTransfer;
  FView.OnEndDrag := DragTransfer;
  FView.OnEnter := EnterTransfer;
  FView.OnExit := ExitTransfer;
  FView.OnKeyDown := KeyDownTransfer;
  FView.OnKeyPress := KeyPressTransfer;
  FView.OnKeyUp := KeyUpTransfer;
  FView.OnMouseDown := MouseDownTransfer;
  FView.OnMouseMove := MouseMoveTransfer;
  FView.OnMouseUp := MouseUpTransfer;
  FView.OnStartDrag := StartDragTransfer;
  FView.Ctl3D := false;
  FView.ParentShowHint := true;
  FView.TabStop := true;
  FView.TabOrder := 0;

  FHScrollBar := TElScrollBar.Create(Self);
  THackScrollBar(FHScrollBar).NoScrollMessages := true;
  FHorzScrollBarStyle := TElScrollBarStyles.Create(FHScrollBar);
  FHorzScrollBarStyle.OnChange := SBChanged;
  FHScrollBar.OnDrawPart := HorzScrollDrawPartTransfer;
  FHScrollBar.OnScrollHintNeeded := HorzScrollHintNeededTransfer;
  FHScrollBar.Parent := Self;
  FHScrollBar.TabStop := false;
  FHScrollBar.OnScroll := FView.OnHScroll;
  FHScrollBar.Ctl3D := false;
  FHScrollBar.Height := GetSystemMetrics(SM_CYVTHUMB);
  FHScrollBar.Visible := false;
  FHScrollBar.OnMouseDown := ScrollBarMouseDown;
  FHScrollBar.AltDisablingArrows := true;
{$IFDEF HAS_HTML_RENDER}
  FHScrollBar.IsHTML := true;
{$ENDIF}

  FVScrollBar := TElScrollBar.Create(Self);
  THackScrollBar(FVScrollBar).NoScrollMessages := true;
  FVertScrollBarStyle := TElScrollBarStyles.Create(FVScrollBar);
  FVertScrollBarStyle.OnChange := SBChanged;
  FVScrollBar.OnDrawPart := VertScrollDrawPartTransfer;
  FVScrollBar.OnScrollHintNeeded := VertScrollHintNeededHandler;
  FVScrollBar.ShowTrackHint := true;
  FVScrollBar.Parent := Self;
  FVScrollBar.Kind := sbVertical;
  FVScrollBar.TabStop := false;
  FVScrollBar.OnScroll := FView.OnVScroll;
  FVScrollBar.Ctl3D := false;
  FVScrollBar.Width := GetSystemMetrics(SM_CXHTHUMB);
  FVScrollBar.Visible := false;
  FVScrollBar.OnMouseDown := ScrollBarMouseDown;
  FVScrollBar.AltDisablingArrows := true;
{$IFDEF HAS_HTML_RENDER}
  FVScrollBar.IsHTML := true;
{$ENDIF}

  ItemExt := 17;
  FHeader := CreateHeader;
  FView.FHeader := FHeader;
  FView.FItems := FItems;

  with FHeader do
  begin
    TabStop := false;
    SetDesigning(csDesigning in ComponentState);
    OnSectionDraw := DoHeaderDraw;
    OnResize := HeaderResizeHandler;
    OnSectionResize := OnHeaderSectionResize;
    OnSectionClick := OnHeaderSectionClick;
    OnSectionDelete := OnHeaderSectionDelete;
    OnMouseDown := DoHeaderMouseDown;
    OnSectionMove := OnHeaderSectionMove;
    OnSectionShowHide := OnHeaderSectionVisChange;
    OnSectionChange := OnHeaderSectionChange;
    OnSectionCreate := OnHeaderSectionCreate;
    OnHeaderLookup := OnHeaderSectionLookup;
    OnHeaderLookupDone := OnHeaderSectionLookupDone;
    OnSectionExpand := Self.OnHeaderExpand;
    OnSectionCollapse := Self.OnHeaderCollapse;
    OnSectionAutoSize := HeaderSectionAutoSizeHandler;
    OnFilterCall := SectionFilterCallTransfer;
    Tracking := FHeaderHotTrack;
    Parent := self;
    Align := alNone;
    Visible := false;
    AllowDrag := false;
  end; //with
  FHeader.Font.Assign(Font);
  FShowHeader := False;
  Font.OnChange := OnFontChange;

  PlusBmp := TBitmap.Create;
  MinusBmp := TBitmap.Create;
  PlusBmp.LoadFromResourceName(HInstance, 'PlusBmp');
  MinusBmp.LoadFromResourceName(HInstance, 'MinusBmp');
  PlusBmp.PixelFormat := pfDevice;
  MinusBmp.PixelFormat := pfDevice;
  FBorderStyle := bsSingle;
  FBkColor := clWindow;
  FTextColor := clWindowText;
  FCanEdit := true;
  FHLines := false;
  FVLines := false;
  FVerticalLinesLong := true;
  FFullRowSelect := true;
  FSelMode := smUsual;
  FShowHintMode := shmLong;
  FMultiSelect := true;
  FExpandOnDblClick := true;
  FHideSelect := false;
  FODFollowCol := true;
  FODMask := '~~@~~';
  FRowSelect := True;
  FTracking := true;
  FShowButtons := True;
  FShowImages := True;
  FShowLines := True;
  FDrawFocusRect := true;
  TabStop := true;
  FAutoLineHeight := true;
  FLineHeight := DefineLineHeight;
  FDragTrgDrawMode := SelColorRect;
  FPathSeparator := '\';
  FSortMode := smNone;
  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;
  DragMode := dmManual;
  FHideHintOnMove := true;
  FAlwaysKeepSelection := true;
  FPlusPicture := TBitmap.Create;
  FPlusPicture.OnChange := OnSignChange;
  FMinusPicture := TBitmap.Create;
  FMinusPicture.OnChange := OnSignChange;
  FSelectColumn := -1;
  FDragType := dtDelphi;
  FLinesColor := clBtnFace;
  FLineHintColor := FBkColor;
  FLinesStyle := psDot;
  FActiveBorderType := fbtSunken;
  FInactiveBorderType := fbtSunkenOuter;
{$IFDEF ELPACK_COMPLETE}
  FStoragePath := 'Tree';
  FImgFormChLink := TImgFormChangeLink.Create;
  FImgFormChLink.OnChange := ImageFormChange;
{$ENDIF}
  FCheckBoxGlyph := TBitmap.Create;
  FRadioButtonGlyph := TBitmap.Create;
  FUnderlineTracked := true;
  FShowRootButtons := true;
  FAutoResizeColumns := True;
  FFlatFocusedScrollbars := true;
  FDivLinesColor := clBtnFace;
  FFocusedSelectColor := clHighlight;
  FHideSelectColor := clBtnFace;
  FFocusedSelectTextColor := clHighlightText;
  FHideSelectTextColor := clBtnShadow;
  FTrackColor := clHighlight;
  FDragRectAcceptColor := clGreen;
  FDragRectDenyColor   := clRed;
  FrightClickSelect := true;

  FLineHintTimeout := 3000;
  FChangeDelay := 500;
  FDragExpandDelay := 500;
{$IFNDEF LITE}
  FGradientSteps := 64;
{$ENDIF LITE}
  FDelayTimer := TTimer.Create(nil);
  FDelayTimer.Enabled := false;
  FDelayTimer.OnTimer := OnDelayTimer;
end;

destructor TCustomElTree.Destroy;
begin
  inherited Destroying;
{$IFNDEF LITE}
  FBackground.Free;
  {$IFDEF ELPACK_COMPLETE}
  ImageForm := nil;
  FImgFormChLink.Free;
  {$ENDIF}
{$ENDIF}

  FCheckBoxGlyph.Free;
  FRadioButtonGlyph.Free;
  MinusBmp.Free;
  PlusBmp.Free;
  FPlusPicture.Free;
  FMinusPicture.Free;
  FItems.Free;
{$IFDEF HAS_HTML_RENDER}
  FView.FRender.Free;
{$ENDIF}
{$ifdef ELTREE_USE_OLE_DRAGDROP}
{$IFNDEF VER90}
{$IFNDEF LITE}
  if FDropTarget <> nil then
     FDropTarget.Free;
{$ENDIF}
{$ENDIF}
{$endif}
  FView.Free;
  FVertScrollBarStyle.Free;
  FHorzScrollBarStyle.Free;
  FHScrollBar.Free;
  FVScrollBar.Free;
  FHeader.Free;
  FDelayedItem := nil;
  FDelayTimer.Free;
  FDelayTimer := nil;
  if FSelectedList <> nil then
    FSelectedList.Free;
  FAllList.Free;
  if Font <> nil then Font.OnChange := nil;
  if FImages <> nil then FImages.UnregisterChanges(FImageChangeLink);
  if FImages2 <> nil then FImages2.UnregisterChanges(FImageChangeLink);
  FImageChangeLink.Free;
  BMP.Free;
  inherited Destroy;
end;

procedure TCustomElTree.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
{$ifdef ELTREE_USE_OLE_DRAGDROP}
{$IFNDEF VER90}
{$IFNDEF LITE}
  if Assigned(FDropTarget) then FDropTarget.Target := Self;
{$ENDIF}
{$ENDIF}
{$endif}
  AlignPieces;
end; {CreateWindowHandle}

function TCustomElTree.GetSelCount;
begin
  if MultiSelect then
  begin
    result := FSelectedList.Count;
  end else
  begin
    if ItemFocused = nil then result := 0 else result := 1;
  end;
end;

procedure TCustomElTree.CreateParams;
const
{$IFNDEF VCL_4_USED}
  BorderStyles: array[TBorderStyle] of Longint = (0, WS_BORDER);
{$ELSE}
  BorderStyles: array[TBorderStyle] of DWord = (0, WS_BORDER);
{$ENDIF}
begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style or BorderStyles[FBorderStyle] or (WS_HSCROLL or WS_VSCROLL);

    if NewStyleControls and Ctl3D and (FBorderStyle = bsSingle) then
    begin
      Style := Style and not WS_BORDER;
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end;

    with Params.WindowClass do
      style := style and not (CS_HREDRAW or CS_VREDRAW);
    if RightAlignedText then
      ExStyle := ExStyle or WS_EX_RTLREADING or WS_EX_RIGHT and (not WS_EX_RIGHTSCROLLBAR);
  end;
end;

procedure TCustomElTree.CMCtl3DChanged(var Message: TMessage);
begin
  if NewStyleControls and (FBorderStyle = bsSingle) then RecreateWnd;
  inherited;
end;

procedure TCustomElTree.SetHorzScrollBarStyle(newValue : TElScrollBarStyles);
begin
  FHorzScrollBarStyle.Assign(newValue);
end;

procedure TCustomElTree.SetVertScrollBarStyle(newValue : TElScrollBarStyles);
begin
  FVertScrollBarStyle.Assign(newValue);
end;

function TCustomElTree.GetItemAt;
begin
  y := Y - FView.Top;
  X := X - FView.Left;
  result := FView.GetItemAt(X, Y, ItemPart, HitColumn);
end;

procedure TCustomElTree.SetImages;
var
  i: integer;
begin
  if FImages = value then exit;
  IsUpdating := true;
  if FImages <> nil then FImages.UnRegisterChanges(FImageChangeLink);
  FImages := Value;
  if FImages <> nil then
  begin
    FImages.RegisterChanges(FImageChangeLink);
    FImages.FreeNotification(Self);
  end;
  if csDestroying in ComponentState then exit;
  i := DefineLineHeight;
  if FAutoLineHeight and (i <> FLineHeight) then
  begin
    FLineHeight := i;
    with FView do
    begin
      FClearVis := true;
      FClearAll := true;
    end;
  end;
  if not FShowHeader then
  begin
    with FView do
    begin
      FHRange := -1;
      DefineHRange;
    end;
    if RightAlignedTree then
    begin
      FRightAlignedTree := false;
      RightAlignedTree := true;
    end;
  end else
  begin
    if FShowHeader and FHeader.Sections[FMainTreeCol].AutoSize then
       AutoSizeColumn(FMainTreeCol);
  end;
  with FView do
  begin
    FRangeUpdate := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetLineStyle;
begin
  if FShowLines = value then exit;
  IsUpdating := true;
  FShowLines := value;
  with FView do
  begin
    if not FShowHeader then FHRange := -1;
    FRangeUpdate := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetShowEmptyImages(newValue : boolean);
begin
  if FShowEmptyImages <> newValue then
  begin
    FShowEmptyImages := newValue;
    if (not ShowImages) or (FImages = nil) then exit;
    IsUpdating := true;
    with FView do
    begin
      if not FShowHeader then FHRange := -1;
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.SetShowEmptyImages2(newValue : boolean);
begin
  if FShowEmptyImages2 <> newValue then
  begin
    FShowEmptyImages2 := newValue;
    if (not ShowImages) or (FImages = nil) then exit;
    IsUpdating := true;
    with FView do
    begin
      if not FShowHeader then FHRange := -1;
      FUpdated := true;
      FRangeUpdate := true;
    end;
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.SetRootStyle;
begin
  if FShowRoot = value then exit;
  IsUpdating := true;
  FShowRoot := value;
  with FView do
  begin
    if not FShowHeader then FHRange := -1;
    FUpdated := true;
    FRangeUpdate := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetImagesStyle;
var
  i: integer;
begin
  if FShowImages = value then exit;
  IsUpdating := true;
  FShowImages := value;
  if not FShowHeader then FView.FHRange := -1;
  i := DefineLineHeight;
  if FAutoLineHeight and (i <> FLineHeight) then
  begin
    FLineHeight := i;
    with FView do
    begin
      FClearVis := true;
      FClearAll := true;
    end;
  end;
  with FView do
  begin
    FRangeUpdate := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.ImageListChange;
var
  i: integer;
begin
  if FView.FPainting then exit;
  IsUpdating := true;
  if AutoLineHeight then
  begin
    i := DefineLineHeight;
    if i <> FLineHeight then
    begin
      with FView do
      begin
        FClearVis := true;
        if i < FLineHeight then FClearAll := true;
      end;
      FLineHeight := i;
    end;
  end;
  with FView do
  begin
    FUpdated := true;
    FRangeUpdate := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetBorderStyle;
begin
  if FBorderStyle = value then exit;
  FBorderStyle := value;
  RecreateWnd;
end;

procedure TCustomElTree.SetButtonStyle;
begin
  if FShowButtons = value then exit;
  IsUpdating := true;
  FShowButtons := value;
  with FView do
  begin
    if not FShowHeader then FHRange := -1;
    FUpdated := true;
    FRangeUpdate := true;
  end;
  IsUpdating := false;
end;

function TCustomElTree.GetUpdating : boolean;
begin
  result := FUpdateCount > 0;
end;

procedure TCustomElTree.SetUpdating;
var
  i: integer;
begin
  if FProcUpdate then exit;

  if value = true then
  begin
    FHeader.BeginUpdate;
    inc(FUpdateCount)
  end
  else
  begin
    dec(FUpdateCount);
    FHeader.EndUpdate;
  end;
  
  if FUpdateCount > 0 then
    exit;
  if (csDestroying in ComponentState) or (csLoading in ComponentState) then
    exit;
  FProcUpdate := true;
  with FView do
  begin
    if FAutoLineHeight then
    begin
      i := DefineLineHeight;
      if i <> FLineHeight then
      begin
        FClearVis := true;
        FLineHeight := i;
      end;
    end;
    if (FHRange = -1) and (not FShowHeader) then FView.DefineHRange;
    if FSortRequired then
    begin
      TriggerSortBegin;
      Sort(true);
      TriggerSortEnd;
    end;
    FSortRequired := false;
    if FUpdated then
    begin
      if FVisUpdated then // recount visibles
      begin
        TotalVisCount := GetTotalVisCount;
        FVisUpdated := false;
      end;
      IgnoreResize := true;
      if (not (csLoading in ComponentState)) and (HandleAllocated) then
      begin
        UpdateScrollBars;
      end;
      IgnoreResize := false;
      if FClearVis and HandleAllocated then // refresh FVisible
      begin
        DoSetTopIndex(FTopIndex);
        FClearVis := false;
      end;
      IgnoreResize := true;
      if FShowHeader then AutoSizeAllColumns;
      if (not (csLoading in ComponentState)) and (HandleAllocated) then
        UpdateScrollBars;
      IgnoreResize := false;
      UpdateView;
      FUpdated := false;
    end;
  end;
  FProcUpdate := false;
end;

function TCustomElTree.GetTotalVisCount;
var i, j, idx : integer;
    Item : TElTreeItem;
begin
  i := 0;
  idx := 0;
  j := FAllList.Count;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);
    if (FilteredVisibility and Item.Hidden) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      inc(idx);
      if not Item.Expanded then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  result := idx;
  TotalVisCount := result;
end;

{
function TCustomElTree.VisToIndex;
type PGIRec = ^TGIRec;
     TGIRec = record
       VisIndex,
       Visibles:integer;
       j:integer;
     end;
var GIRec : TGIRec;

    procedure IntVisToIndex(Item:TElTreeItem; Index: integer; var ContinueIterate:boolean;
                                              IterateData:pointer; Tree:TCustomElTree);
    var i : integer;
    begin
      if Item.FullyExpanded then inc(PGIRec(IterateData)^.Visibles);
      if PGIRec(IterateData)^.Visibles=PGIRec(IterateData)^.VisIndex then
      begin
        PGIRec(IterateData)^.j:=Index;
        ContinueIterate:=false;
      end;
    end;

begin
  GIRec.VisIndex:=Index;
  GIRec.Visibles:=-1;
  GIRec.j:=-1;
  FItems.Iterate(false,@IntVisToIndex,@GIRec);
  result:=GIRec.j;
end;
}
{function TCustomElTree.IndexToVis;
type PGIRec = ^TGIRec;
     TGIRec = record
       VisIndex,
       Visibles:integer;
       j:integer;
     end;
var GIRec : TGIRec;

    procedure IntIndexToVis(Item:TElTreeItem; Index: integer; var ContinueIterate:boolean;
                                              IterateData:pointer; Tree:TCustomElTree);
    var i : integer;
    begin
      if Item.FullyExpanded then inc(PGIRec(IterateData)^.Visibles);
      if Index=PGIRec(IterateData)^.VisIndex then
      begin
        PGIRec(IterateData)^.j:=PGIRec(IterateData)^.Visibles;
        ContinueIterate:=false;
      end;
    end;

begin
  GIRec.VisIndex:=Index;
  GIRec.Visibles:=-1;
  GIRec.j:=-1;
  FItems.Iterate(false,@IntIndexToVis,@GIRec);
  result:=GIRec.j;
end;
}

procedure TCustomElTree.UpdateScrollBars;

  function UpdHBar: boolean;
  var
    b1: boolean;
    ScrollInfo: TScrollInfo;
    CurPos: integer;
    hsw : integer;
  begin
    b1 := FHScrollVisible;
    ScrollInfo.cbSize := Sizeof(ScrollInfo);
    GetScrollInfo(FHScrollBar.Handle, SB_CTL, ScrollInfo);
    if FShowHeader then
    begin
      FView.FHRange := 0;
      if FHeader.Sections.Count > 0 then
      begin
        hsw := FHeader.SectionsWidth;
        ScrollInfo.nMax := hsw;
        FView.FHRange := hsw;
      end
         else ScrollInfo.nMax := 0;
    end
    else
      ScrollInfo.nMax := FView.FHRange;
    if ScrollInfo.nMax < 0 then
      ScrollInfo.nMax := 0;
    ScrollInfo.nPage := FView.Width + 1;

    FHScrollVisible := (ScrollInfo.nMax - Integer(ScrollInfo.nPage) > 0) and (not FHideHorzScrollBar);
    if (not FHScrollVisible) then
    begin
      ScrollInfo.nMax := 0;
      FHPos := 0;
      FHeader.LeftPos := 0
      //LockedColumn, update
      //if FHeader.Left < 0 then FHeader.Left := 0;
    end;
    result := (FHScrollVisible <> b1) and (not (ForcedScrollBars in [ssHorizontal, ssBoth]));

    FHPos := Min(FHPos, Max(0, ScrollInfo.nMax));
    CurPos := FHPos;

    ScrollInfo.fMask := SIF_ALL;

    ScrollInfo.nMin := 0;
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.nPos := CurPos;
    ScrollInfo.nTrackPos := CurPos;

    SetScrollInfo(FHScrollBar.Handle, SB_CTL, ScrollInfo, true);

    // Set info for hidden standard scrollbar
    if FUseCustomBars or (ForcedScrollBars in [ssHorizontal, ssBoth]) then
       ScrollInfo.fMask := ScrollInfo.fMask or SIF_DISABLENOSCROLL;
    Windows.SetScrollInfo(Handle, SB_HORZ, ScrollInfo, true);

    if (FHeader.LeftPos <> FHPos) then
      FHeader.LeftPos := FHPos;
    FHScrollVisible := FHScrollVisible or (ForcedScrollBars in [ssHorizontal, ssBoth])
  end;

  function UpdVBar: boolean;
  var
    b: boolean;
    CHeight   : integer;
    ScrollInfo: TScrollInfo;
    maxV      : integer;
  begin
    if TotalVisCount = 0 then GetTotalVisCount;
    maxV := TotalVisCount - 1;

    ScrollInfo.nMax := maxV;

    ScrollInfo.fMask := SIF_ALL;
    ScrollInfo.nMin := 0;
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.nPos := FTopIndex;
    ScrollInfo.nTrackPos := FTopIndex;
    B := FVScrollVisible;
    CHeight := FView.Height;
    FVScrollVisible := ((FTopIndex > 0) or (FView.GetVisiblesHeight > CHeight) or ((ScrollInfo.nMax > FView.FVisible.Count) and (FView.FVisible.Count > 0))) and (not FHideVertScrollBar);
    //if (FTopIndex > 0) and (not FHideVertScrollBar) then FVScrollVisible := true;
    if TotalVarHeightCount > 0 then
    begin
      ScrollInfo.nPage := FView.CalcPageUpPos(TopIndex);
    end else
    begin
      ScrollInfo.nPage := View.GetVisCount - 1;
    end;
    if not (FVScrollVisible) then
    begin
      ScrollInfo.nMax := 0;
      ScrollInfo.nPage := 1;
    end;

    SetScrollInfo(FVScrollBar.Handle, SB_CTL, ScrollInfo, true);

    // Set info for hidden standard scrollbar

    //ScrollInfo.fMask := SIF_POS or SIF_RANGE or SIF_PAGE;
    if FUseCustomBars or (ForcedScrollBars in [ssVertical, ssBoth]) then
       ScrollInfo.fMask := ScrollInfo.fMask or SIF_DISABLENOSCROLL;

    Windows.SetScrollInfo(Handle, SB_VERT, ScrollInfo, true);

    result := (FVScrollVisible <> b) and (not (ForcedScrollBars in [ssVertical, ssBoth]));
    FVScrollVisible := FVScrollVisible or (ForcedScrollBars in [ssVertical, ssBoth])
  end;

var FHVis, FVVis : boolean;
begin
  FHVis := FHScrollVisible;
  FVVis := FVScrollVisible;
  while UpdHBar or UpdVBar do ;
  if (FHVis <> FHScrollVisible) or (FVVis <> FVScrollVisible) then AlignPieces;
  if FUseCustomBars then 
     DrawFlatBorder(false, false);
end;

procedure TCustomElTree.SetHLines;
var
  i: integer;
begin
  if FHLines = value then exit;
  IsUpdating := true;
  FHLines := value;
  if FAutoLineHeight then
  begin
    i := DefineLineHeight;
    if i <> FLineHeight then
    begin
      FLineHeight := i;
      with FView do
      begin
        FClearVis := true;
        FClearAll := true;
      end;
    end;
  end;
  with FView do
  begin
    FRangeUpdate := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetVLines;
begin
  if FVLines = value then exit;
  IsUpdating := true;
  with FView do
  begin
    FVLines := value;
    FClearAll := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.OnHeaderSectionResize;
begin
  IsUpdating := true;
  DoOnColumnResize(Section.Index);
  with FView do
  begin
    FUpdated := true;
    FRangeUpdate := true;
    FClearVis := true;
    if FVLines then FClearAll := true else FRangeUpdate := true;
  end;
  IsUpdating := false;
  {if FHeader.SectionsWidth < FView.Width then AlignPieces;}
end;

procedure TCustomElTree.OnHeaderSectionLookup(Sender: TObject; Section: TElHeaderSection; var Text: string);

type
  TSRec = record
    Text: PChar;
    ColNum: integer;
  end;
  PSRec = ^TSRec;

var
  SRec: TSrec;
  TI: TElTreeItem;

  function IntCompare(Item: TElTreeItem; SearchDetails: Pointer): boolean;
  var
    i: integer;
    AT: string;
  begin
    i := PSRec(SearchDetails).ColNum;
    if Item.FOwner.MainTreeColumn = i then AT := AnsiUpperCase(Item.Text) else
    begin
      if Item.ColumnText.Count <= i then AT := '' else
      begin
        if I > Item.FOwner.MainTreeColumn then AT := AnsiUpperCase(Item.ColumnText[i - 1])
        else AT := AnsiUpperCase(Item.ColumnText[i]);
      end;
    end;
    result := Pos(AnsiUpperCase(StrPas(PSRec(SearchDetails).Text)), AT) = 1;
  end;

begin
  TriggerHeaderLookupEvent(Section, Text);
  if AutoLookup then
  begin
    SRec.Text := PChar(Text);
    SRec.ColNum := Section.Index;
    TI := Items.LookForItemEx(ItemFocused, Section.Index, false, false, true, @SRec, @IntCompare);
    if TI <> nil then
    begin
      EnsureVisible(TI);
      DoSetFocused(TI, false);
    end;
  end;
end;

procedure TCustomElTree.OnHeaderExpand;
begin
  TriggerHeaderSectionExpandEvent(Section);
  try
    IsUpdating := true;
    with FView do
    begin
      FUpdated := true;
      FClearAll := true;
    end;
    //if FShowHeader then FHeader.Repaint;
  finally
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.OnHeaderCollapse;
begin
  TriggerHeaderSectionCollapseEvent(Section);
  try
    IsUpdating := true;
    with FView do
    begin
      FUpdated := true;
      FClearAll := true;
    end;
    //if FShowHeader then FHeader.Repaint;
  finally
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.OnHeaderSectionLookupDone(Sender: TObject; Section: TElHeaderSection; Text: string; Accepted: boolean);
begin
  TriggerHeaderLookupDoneEvent(Section, Text, Accepted);
end;

procedure TCustomElTree.DoHeaderMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
{$ifdef ELTREE_USE_INPLACE_EDITORS}
  if FView.FInpEdit <> nil then FView.DoEndEdit(true);
{$endif}
  if Assigned(FOnHeaderMouseDown) then
    FOnHeaderMouseDown(Sender, Button, Shift, X, Y);
end;

procedure TCustomElTree.OnHeaderSectionClick(Header: TCustomElHeader; Section: TElHeaderSection);
begin
  if (FSortMode = smClick) or (FSortMode = smAddClick) then
  begin
    IsUpdating := true;
    SortSection := Section.Index;
    if Section.SortMode = hsmNone then
      if SortDir = sdAscend then Section.SortMode := hsmDescend else Section.SortMode := hsmAscend;
    if Section.SortMode = hsmAscend then Section.SortMode := hsmDescend else Section.SortMode := hsmAscend;
    case Section.FieldType of
      sftText: SortType := stText;
      sftNumber: SortType := stNumber;
      sftFloating: SortType := stFloating;
      sftDateTime: SortType := stDateTime;
      sftDate: SortType := stDate;
      sftTime: SortType := stTime;
      sftBool: SortType := stBoolean; 
      sftCurrency: SortType := stCurrency;
    else
      SortType := stCustom;
    end;
    TriggerSortBegin;
    FItems.FRoot.Sort(true);
    TriggerSortEnd;
    with FView do
    begin
      FUpdated := true;
      FRangeUpdate := true;
      FVisUpdated := true;
    end;
    IsUpdating := false;
  end;
  DoColumnClick(Section.Index);
end;

procedure TCustomElTree.OnSignChange(Sender: TObject);
var
  i: integer;
begin
  if not FCustomPlusMinus then exit;
  IsUpdating := true;
  if AutoLineHeight then
  begin
    i := DefineLineHeight;
    if i <> FLineHeight then
    begin
      with FView do
      begin
        FClearVis := true;
        if i < FLineHeight then FClearAll := true;
      end;
      FLineHeight := i;
    end;
    FView.FVisUpdated := true;
  end;
  with FView do
  begin
    FRangeUpdate := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

type

TElHeaderHack = class (TCustomElHeader)
public
  property IsDesigning;
end;

procedure TCustomElTree.OnFontChange;
var
  i: integer;
begin
  if FView.FPainting then exit;
  IsUpdating := true;
  ParentFont := false;
  Canvas.Font.Assign(Font);
  FHeader.Font.Assign(Font);
  TElHeaderHack(FHeader).OnFontChange(FHeader.Font);
  if AutoLineHeight then
  begin
    i := DefineLineHeight;
    if i <> FLineHeight then
    begin
      with FView do
      begin
        FClearVis := true;
        if i < FLineHeight then FClearAll := true;
      end;
      FLineHeight := i;
    end;
  end;
  with FView do
  begin
    FUpdated := true;
    FRangeUpdate := true;
  end;
  IsUpdating := false;
end;
{$IFNDEF LITE}
function TCustomElTree.GetHeaderWrapCaptions : boolean;
begin
  result := TElHeader(FHeader).WrapCaptions;
end;

procedure TCustomElTree.SetHeaderWrapCaptions(Value : boolean);
begin
  TElHeader(FHeader).WrapCaptions := value;
end;
{$ENDIF}
procedure TCustomElTree.SetHeaderHotTrack;
begin
  FHeaderHotTrack := value;
  FHeader.Tracking := value;
end;

procedure TCustomElTree.SetRowSelect;
begin
  IsUpdating := true;
  FRowSelect := value;
  if FRowSelect = false then FullRowSelect := false;
  with FView do
  begin
    FClearAll := true;
    FClearVis := true;
    FUpdated := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetMultiSelect;
var TSI: TElTreeItem;
begin
  if Value <> FMultiSelect then
  begin
    IsUpdating := true;
    FUpdated := true;
    FMultiSelect := value;
    TSI := ItemFocused;
    if Value = true then
    begin
      FSelectedList := TElList.Create;
      with FView do
        if FSelected <> nil then FSelectedList.Add(FSelected);
    end else
    begin
      DeselectAllEx(true);
      if TSI <> nil then
      begin
        TSI.Focused := true;
        TSI.Selected := true;
      end;
      FSelectedList.Free;
      FSelectedList := nil;
    end;
    IsUpdating := false;
  end;
end;

function TCustomElTree.DoSetFocused(value: TElTreeItem; Forced : boolean; AutoSelect : boolean):
    Boolean;
begin
  result := DoSetFocusedEx(value, Forced, false, AutoSelect);
end;

function TCustomElTree.DoSetFocusedEx(value: TElTreeItem; Forced, Delayed : 
    boolean; AutoSelect : boolean): Boolean;
var
  AnItem,
  FOld     : TElTreeItem;
  DoChange : boolean;

begin
  result := false;
  if (value <> nil) and
     (not value.AllowSelection) then exit;

{Original}
  //if FView.FFocused <> Value then
{End Original}
{Soulsnake Fix}
  if (FView.FFocused <> Value) or (Value = nil) or ((Value.FIState and tisSelected) = 0) then
{End Soulsnake Fix}
  begin
    DoChange := Forced;
    DoChanging(Value, DoChange);
    if (not Forced) and (not DoChange) then
    begin
      if AutoSelect then
        FView.DoSetSelected(FView.FFocused);
      exit;
    end;

    IsUpdating := true;
    AnItem := FView.FFocused;
    if AnItem <> nil then with AnItem do
    begin
      Exclude(FState, stsFocused);
      RedrawItem(true);
      FView.FFocused := nil;
      if FAutoExpand and
        (value <> nil) then
      begin
        FOld := AnItem;
        while (FOld <> nil) and (not Value.IsUnder(FOld)) do
        begin
          FOld.Collapse(false);
          FOld := FOld.Parent;
        end; // while
        FUpdated := true;
      end;
    end;
    result := true;
    FView.FFocused := value;
    if AutoSelect then  
      FView.DoSetSelected(value);
{Soulsnake Fix}
    if FView.FSelected = nil then
      FView.FSelected := FView.FFocused;
{End Soulsnake Fix}
    if FView.FFocused <> nil then
    begin
      with FView do
      begin
        Include(FFocused.FState, stsFocused);
        FFocused.RedrawItem(true);
        if FAutoExpand then FFocused.Expand(false);
      end;
      if not (csDestroying in ComponentState) then
      begin
        with FView do
          if (FVisible.IndexOf(FFocused) = FVisible.Count - 1) and (GetVisiblesHeight > Height) and (FVisible.Count > 1) then
            TopIndex := TopIndex + 1;
      end;
    end;
    if (FChangeDelay = 0) or (not Delayed) then
      DoItemFocused
    else
    begin
      StopDelayedFocus;
      StartDelayedFocus(FView.FFocused);
    end;
    FUpdated := true;
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.DoChanging(Item : TElTreeItem; var AllowChange: Boolean);
begin
  if Assigned(FOnChanging) and (FFireFocusEvents = 0) then
     FOnChanging(Self, Item, AllowChange)
  else AllowChange := true;
end;

procedure TCustomElTree.SetFocused;
begin
  DoSetFocused(Value, false, true);
end;

procedure TCustomElTree.SetItemFocused(Value: TElTreeItem; AutoSelect: Boolean = True);
begin
  DoSetFocused(Value, false, AutoSelect);
end;

function TCustomElTree.GetNextSelected;
var i : integer;
begin
  if not (FMultiSelect) then
  begin
    if Prev = nil then
       result := ItemFocused
    else
       result := nil;
    exit;
  end;

  if (Prev = nil) and (FSelectedList.Count > 0) then
     result := TElTreeItem(FSelectedList[0])
  else
  begin
    i := FSelectedList.IndexOf(Prev);
    if (i <> -1) and (i < FSelectedList.Count - 1) then
       result := TElTreeItem(FSelectedList[i+1])
    else
       result := nil;
  end;
end;

procedure TCustomElTree.AllSelected(SelectedItems: TElList);
begin
  if FMultiSelect then
    SelectedItems.Assign(FSelectedList)
  else
  begin
    SelectedItems.Clear;
    if (ItemFocused <> nil) then
      SelectedItems.Add(ItemFocused);
  end;
end;

procedure TCustomElTree.EnsureVisible;
begin
  FView.FillVisFwd(TopIndex);

  if Item = nil then
     exit;
{Original}
  //if FView.FVisible.IndexOf(Item) <> -1 then exit;
{End Original}
{Soulsnake Fix}
  if FView.FFullVisible.IndexOf(Item) <> -1 then exit;
{End Soulsnake Fix}
  if not Item.FullyExpanded then
     Item.MakeFullyExpanded(true);
  IsUpdating := true;
  SetVPosition(Item.VisIndex);
  FUpdated := true;
  with FView do
  begin
    FRangeUpdate := true;
    FClearAll := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.EnsureVisibleBottom;
begin
  if Item = nil then
     exit;
{Original}
  //if FView.FVisible.IndexOf(Item) <> -1 then exit;
{End Original}
{Soulsnake Fix}
  if FView.FFullVisible.IndexOf(Item) <> -1 then exit;
{End Soulsnake Fix}
  if not Item.FullyExpanded then
     Item.MakeFullyExpanded(true);
  IsUpdating := true;
  SetVPosition(FView.CalcPageUpPos(Item.VisIndex) + 1);
  FUpdated := true;
  with FView do
  begin
    FRangeUpdate := true;
    FClearAll := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetAutoLineHeight;
begin
  if FAutoLineHeight = value then
     exit;
  IsUpdating := true;
  FAutoLineHeight := value;
  if value = true then
     FLineHeight := DefineLineHeight;
  FUpdated := true;
  with FView do
  begin
    FClearAll := true;
    FClearVis := true;
  end;
  FUpdated := true;
  IsUpdating := false;
end;

procedure TCustomElTree.SetItemIndent(value: integer);
begin
  if ItemExt <> Value then
  begin
    ItemExt := Value;
    IsUpdating := true;
    FUpdated := true;
    FView.FClearAll := true;
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.SetLineHeight;
begin
  if (FLineHeight = value) or FAutoLineHeight then
     exit;
  IsUpdating := true;
  FUpdated := true;
  FLineHeight := value;
  with FView do
  begin
    FClearVis := true;
    FClearAll := true;
  end;
  if value = 0 then FLineHeight := DefineLineHeight;
  IsUpdating := false;
end;

function TCustomElTree.DefineLineHeight;
var
  m: integer;
begin
  m := 0;
  if FShowImages then
  begin
    if (Images <> nil) then m := Images.Height;
    if (Images2 <> nil) then m := Max(m, Images2.Height);
  end;
  if ItemExt > m then m := ItemExt;
  if Font.Height < 0 then
     m := max(m, Abs(Font.Height) + 4)
  else
     m := max(m, Abs(Font.Height) + 2);
  if ShowCheckboxes then
  begin
    if CustomCheckboxes then
    begin
      m := Max(m, Max(FRadioButtonGlyph.Height, FCheckBoxGlyph.Height));
    end else
    begin
      m := max(m, ItemExt - 2);
    end;
  end;
  result := m;
  if FBarStyle then inc(result, 2);
  if FHLines and not (FBarStyle) then inc(result, FDivLineWidth);
end;

procedure TCustomElTree.WMSize;
begin
  inherited;
{$IFNDEF VCL_4_USED}
  if not (csLoading in ComponentState) and (not IgnoreResize) then Resize;
{$ENDIF}
  if Flat or FUseCustomBars then UpdateFrame;
end;

procedure TCustomElTree.Resize;
begin
{$IFNDEF VCL_4_USED}
  if Assigned(FOnResize) then FOnResize(Self);
{$ELSE}
  inherited;
{$ENDIF}
  IsUpdating := true;
  AlignPieces;
  with FView do
  begin
    FVisUpdated := true;
    FClearAll := true;
    FClearVis := true;
  end;
  FUpdated := true;
  IsUpdating := false;
end;

function TCustomElTree.GetItemRect;
begin
  result := FView.GetItemRect(ItemIndex);
  OffsetRect(result, 0, FView.Top);
end;

procedure TCustomElTree.OnHeaderSectionVisChange(Sender: TCustomElHeader; Section: TElHeaderSection); { private }
begin
  IsUpdating := true;
  with FView do
  begin
    FClearAll := true;
    FHRange := -1;
  end;
  if FHeader.SectionsWidth < FView.Width then
  begin
    FHeader.Invalidate;
    SetHPosition(0);
  end;
  FUpdated := true;
  IsUpdating := false;
end; { OnHeaderSectionVisChange }

procedure TCustomElTree.DoOnColumnResize(SectionIndex: integer); { protected }
begin
  if Assigned(FOnColumnResize) then FOnColumnResize(self, SectionIndex);
end; { DoOnColumnResize }

procedure TCustomElTree.DoColumnClick(SectionIndex: integer); { protected }
begin
  if Assigned(FOnColumnClick) then FOnColumnClick(self, SectionIndex);
end; { DoColumnClick }

procedure TCustomElTree.DoItemFocused; { protected }
begin
  if Assigned(FOnItemFocused) and
     (not (csDestroying in ComponentState)) and
     (FFireFocusEvents = 0) then
    FOnItemFocused(self);
end; { DoItemFocused }

procedure TCustomElTree.DoItemDraw(Item: TElTreeItem; Surface: TCanvas; R: TRect; SectionIndex: integer); { protected }
begin
  if Assigned(FOnItemDraw) then FOnItemDraw(Self, Item, Surface, R, SectionIndex);
end; { DoItemDraw }

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.DoValidate(Item: TElTreeItem; Section: TElHeaderSection; var Text: string; var Accept: boolean); { protected }
begin
  FDelOnEdit := true;
  if assigned(FOnValidate) then FOnValidate(self, Item, Section, Text, Accept);
  FDelOnEdit := false;
end; { DoValidate }
{$endif}

procedure TCustomElTree.DoShowHint(Item: TElTreeItem; var Text: string; HintWindow: THintWindow; MousePos: TPoint; var DoShowHint: boolean); { protected }
begin
  if assigned(FOnShowHint) then FOnShowHint(Self, Item, Text, HintWindow, MousePos, DoShowHint);
end; { DoShowHint }

procedure TCustomElTree.DoItemChange(Item: TElTreeItem; ItemChangeMode: TItemChangeMode); { protected }
begin
  if Assigned(FOnItemChange) then FOnItemChange(Self, Item, ItemChangeMode);
end; { DoOnItemChange }

procedure TCustomElTree.DoItemExpanding(Item: TElTreeItem; var CanProcess: boolean); { protected }
begin
  if assigned(FOnItemExpanding) then FOnItemExpanding(Self, Item, CanProcess);
end; { DoItemExpanding }

procedure TCustomElTree.DoItemCollapsing(Item: TElTreeItem; var CanProcess: boolean); { protected }
begin
  if assigned(FOnItemCollapsing) then FOnItemCollapsing(Self, Item, CanProcess);
end; { DoItemCollapsing }

procedure TCustomElTree.DoItemChecked(Item : TElTreeItem);  { protected }
begin
  if assigned(FOnItemChecked) then FOnItemChecked(Self, Item);
end;  { DoItemChecked }

{Soulsnake Add}
procedure TCustomElTree.DoItemColorPick(Item : TElTreeItem);  { protected }
begin
  if assigned(FOnItemColorPick) then FOnItemColorPick(Self, Item);
end;  { DoItemChecked }
{End Soulsnake Add}

procedure TCustomElTree.DoItemExpand(Item: TElTreeItem); { protected }
begin
  if assigned(FOnItemExpand) then FOnItemExpand(Self, Item);
end; { DoItemExpand }

procedure TCustomElTree.DoItemCollapse(Item: TElTreeItem); { protected }
begin
  if assigned(FOnItemCollapse) then FOnItemCollapse(Self, Item);
end; { DoItemCollapse }

procedure TCustomElTree.DoItemDelete(Item: TElTreeItem); { protected }
begin
  if assigned(FOnItemDelete) then FOnItemDelete(Self, Item);
end; { DoItemDelete }

procedure TCustomElTree.DoCompareItems(Item1, Item2: TElTreeItem; var res: integer); { protected }
begin
  if assigned(FOnCompareItems) then FOnCompareItems(Self, Item1, Item2, res) else res := 0;
end; { DoCompareItems }

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.TriggerEditRequestEvent(Item: TElTreeItem; Section: TElHeaderSection);
begin
  if (assigned(FOnEditRequest)) then FOnEditRequest(Self, Item, Section);
end; { TriggerEditRequestEvent }

procedure TCustomElTree.TriggerComboEditShowEvent(Item: TElTreeItem; Section: TElHeaderSection; Combobox: TCombobox);
begin
  if (assigned(FOnComboEditShow)) then
    FOnComboEditShow(Self, Item, Section, Combobox);
end; { TriggerComboEditShowEvent }

procedure TCustomElTree.DoValidateCombo(Item: TElTreeItem; Section: TElHeaderSection; Combo: TComboBox; var Accept: boolean);
begin
  FDelOnEdit := true;
  if (assigned(FOnValidateCombo)) then
    FOnValidateCombo(Self, Item, Section, Combo, Accept);
  FDelOnEdit := false;
end; { TriggerValidateComboEvent }
{$endif}

procedure TCustomElTree.OnHeaderSectionChange(Sender: TCustomElHeader; Section: TElHeaderSection; Change: TSectionChangeMode); { protected }
begin
  case Change of
    scmAlign: if Section.Visible then
      begin
        IsUpdating := true;
        FView.FClearAll := true;
        IsUpdating := false;
      end;
    scmStyle: if FODFollowCol and Section.Visible then
      begin
        IsUpdating := true;
        FView.FClearAll := true;
        IsUpdating := false;
      end;
    scmPassword: if Section.Visible then FView.Invalidate;//Repaint;
  end;
end; { OnHeaderSectionChange }

function TCustomElTree.CreateHeader: TElHeader; { protected }
begin
  result := TElHeader.Create(self);
end; { CreateHeader }

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.SetCanEdit(value: boolean);
begin
  FCanEdit := value;
end;
{$endif}

procedure TCustomElTree.OnHeaderSectionCreate(Header: TCustomElHeader; Section: TElHeaderSection); { protected }
begin
  IsUpdating := true;
  FUpdated := true;
  AlignPieces;
  IsUpdating := false;
end; { OnHeaderSectionCreate }

procedure TCustomElTree.Paint; { protected }
var R : TRect;
  {$IFDEF ELPACK_COMPLETE}
    AForm  : TCustomForm;
    ax, ay : integer;
    P      : TPoint;
    BgRect : TRect;
  {$ENDIF}
begin
  if Flat or FUseCustomBars then DrawFlatBorder(false, false);
  if (FVScrollVisible and FHScrollVisible) and FUseCustomBars then
  begin
    R := Rect(FVScrollbar.Left, FHScrollBar.Top, FVScrollBar.Left + FVScrollBar.Width, FHScrollBar.Top + FHScrollBar.Height);
{$IFDEF ELPACK_COMPLETE}
    if (FImgForm <> nil) and (not (csDesigning in FImgForm.ComponentState)) then
    begin
      AForm := GetParentForm(Self);
      BgRect := R;
      BgRect.TopLeft := ClientToScreen(BgRect.TopLeft);
      P := Parent.ClientToScreen(Point(Left, Top));
      ax := BgRect.Left - P.x;
      ay := BgRect.Top - P.y;

      BgRect.BottomRight := ClientToScreen(BgRect.BottomRight);
      BgRect.TopLeft := AForm.ScreenToClient(BgRect.TopLeft);
      BgRect.BottomRight := AForm.ScreenToClient(BgRect.BottomRight);
      FImgForm.PaintBkgnd(Canvas.Handle, R, Point(BgRect.Left - ax, BgRect.Top - ay), false);
    end
    else
{$ENDIF}
    begin
      Canvas.Brush.Style := bsSolid;
      Canvas.Brush.Color := FVScrollBar.Color;
      Canvas.FillRect(R);
    end;
  end;
end; { Paint }

function TCustomElTree.GetMoveColumnOnDrag: Boolean;
begin
  result := FHeader.MoveOnDrag;
end; { GetMoveColumnOnDrag }

procedure TCustomElTree.SetMoveColumnOnDrag(newValue: Boolean);
begin
  if (FHeader.MoveOnDrag <> newValue) then FHeader.MoveOnDrag := newValue;
end; { SetMoveColumnOnDrag }

procedure TCustomElTree.SetHideHorzScrollBar(newValue: Boolean);
begin
  if (FHideHorzScrollBar <> newValue) then
  begin
    FHideHorzScrollBar := newValue;
    IsUpdating := true;
    with FView do
    begin
      FVisUpdated := true;
      FClearAll := true;
      FClearVis := true;
    end;
    FUpdated := true;
    AlignPieces;
    IsUpdating := false;
  end; { if }
end; { SetHideHorzScrollBar }

procedure TCustomElTree.SetHideVertScrollBar(newValue: Boolean);
begin
  if (FHideVertScrollBar <> newValue) then
  begin
    FHideVertScrollBar := newValue;
    IsUpdating := true;
    with FView do
    begin
      FVisUpdated := true;
      FClearAll := true;
      FClearVis := true;
    end;
    FUpdated := true;
    AlignPieces;
    IsUpdating := false;
  end; { if }
end; { SetHideVertScrollBar }

procedure TCustomElTree.SetUnderlineTracked(newValue: Boolean);
begin
  if (FUnderlineTracked <> newValue) then
  begin
    FUnderlineTracked := newValue;
    with FView do
      if Tracking and (FTrackItem <> nil) then FTrackItem.RedrawItem(true);
  end; { if }
end; { SetUnderlineTracked }

procedure TCustomElTree.SetCustomCheckboxes(newValue: Boolean);
begin
  if (FCustomCheckboxes <> newValue) then
  begin
{202747356}
    FCustomCheckboxes := newValue;
    if ShowCheckBoxes then
    begin
      IsUpdating := true;
      FUpdated := true;
      FView.FClearAll := true;
      IsUpdating := false;
    end;
  end; { if }
end; { SetCustomCheckboxes }

procedure TCustomElTree.SetCheckBoxGlyph(newValue: TBitmap);
begin
  FCheckBoxGlyph.Assign(newValue);

  if newValue = nil then
    CustomCheckboxes := false;
  if ShowCheckBoxes then
  begin
    IsUpdating := true;
    FUpdated := true;
    FView.FClearAll := true;
    IsUpdating := false;
  end;
end; { SetCheckBoxGlyph }

procedure TCustomElTree.SetRadioButtonGlyph(newValue: TBitmap);
{ Sets data member FRadioButtonGlyph to newValue. }
begin
  FRadioButtonGlyph.Assign(newValue);

  if newValue = nil then
    CustomCheckboxes := false;
  if ShowCheckBoxes then
  begin
    IsUpdating := true;
    FUpdated := true;
    FView.FClearAll := true;
    IsUpdating := false;
  end;
end; { SetRadioButtonGlyph }

procedure TCustomElTree.SetShowRootButtons(newValue: Boolean);
begin
  if FShowRootButtons = newValue then exit;
  IsUpdating := true;
  FShowRootButtons := newValue;
  if not FShowHeader then FView.FHRange := -1;
  FUpdated := true;
  FView.FRangeUpdate := true;
  IsUpdating := false;
end;

procedure TCustomElTree.SetHideFocusRect(newValue: Boolean);
begin
  if (FHideFocusRect <> newValue) then
  begin
    FHideFocusRect := newValue;
    if (not Focused) and (HandleAllocated) then
    begin
      IsUpdating := true;
      FView.FRangeUpdate := true;
      FUpdated := true;
      IsUpdating := false;
    end;
  end; {if}
end;

function TCustomElTree.GetLockHeaderHeight: Boolean;
begin
  result := FHeader.LockHeight;
end; { GetLockHeaderHeight }

procedure TCustomElTree.SetLockHeaderHeight(newValue: Boolean);
begin
  if (LockHeaderHeight <> newValue) then
    FHeader.LockHeight := newValue;
end; { SetLockHeaderHeight }

{$ifdef ELTREE_USE_INPLACE_EDITORS}
function TCustomElTree.GetInEditing : boolean;
begin
  result := FView.FEditing;
end;
{$endif}

procedure TCustomElTree.UpdateFrame;
var R : TRect;
begin
  R := Rect( 0, 0, Width, Height );
  if (BorderStyle = bsSingle) then
     RedrawWindow( Handle, @R, 0, rdw_Invalidate or rdw_UpdateNow or rdw_Frame );
end;

type TSelHackWinControl = class (TWinControl)
     end;

procedure TCustomElTree.WMSetFocus(var Msg : TWMSetFocus);  { private }
begin
  inherited;
  if Msg.FocusedWnd <> FView.Handle then
    FView.SetFocus
  else
    TSelHackWinControl(Parent).SelectNext(Self, false, True);
  if (Flat and (FInactiveBorderType <> FActiveBorderType)) or FUseCustomBars then
    UpdateFrame;
end;  { WMSetFocus }

procedure TCustomElTree.WMKillFocus(var Msg : TWMKillFocus);  { private }
begin
  inherited;
  if (Flat and (FInactiveBorderType <> FActiveBorderType)) or FUseCustomBars then UpdateFrame;
end;  { WMKillFocus }

procedure TCustomElTree.AutoSizeColumn(SectionIndex : integer);
var Section : TElHeaderSection;
begin
  if FUpdateCount > 0 then exit;
  Section := FHeader.Sections[SectionIndex];
  if (section <> nil) and Section.AutoSize then
  begin
    Section.Width := Max(FHeader.MeasureSectionWidth(Section, nil), MeasureColumnWidth(SectionIndex, true));
    OnHeaderSectionResize(FHeader, Section);
  end;
end;

procedure TCustomElTree.AutoSizeAllColumns;
var i : integer;
begin
  if FAutosizingColumns then exit;
  if FUpdateCount > 0 then exit;
  FAutosizingColumns := true;
  for i := 0 to Pred(FHeader.Sections.Count) do
  begin
    AutoSizeColumn(i);
  end;
  FAutosizingColumns := false;
end;

{$warnings off}
{$hints off}
procedure TCustomElTree.MeasureCell(Item : TElTreeItem; ColumnNum : integer; var Size : TPoint);
var HS : TElHeaderSection;
{$ifdef ELTREE_USE_STYLES}
    CurStyle : TElCellStyle;
{$endif}
    OwnFontSet : boolean;
    xxx,
    SaveFontStyle : TFontStyles;
    SaveFontSize : integer;
    SaveFontName : TFontName;
    AL : integer;
    R3 : TRect;
    FTImages : TImageList;
    StImIndex : integer;
    FID       : boolean;
    ASize : TPoint;
    SText : string;

begin
  if (ColumnNum = -1) or (ColumnNum = FMainTreeCol) then
  begin
{$ifdef ELTREE_USE_STYLES}
    if Item.FUseStyles then CurStyle := Item.FMainStyle else CurStyle := nil;
{$endif}
    Size.Y := FLineHeight;
    Size.X := 0;
    if (FShowRoot and FShowLines) or (FShowButtons and FShowRootButtons) then
      Inc(Size.X, ItemExt)
    else
      Inc(Size.X, ItemExt div 5);

    Inc(Size.X, Item.Level * ItemExt);

    if FShowCheckBoxes then
    begin
      if Item.FShowCheckBox then
      begin
        inc(Size.X, 2);
        if FCustomCheckboxes then
          inc(Size.X, FRadioButtonGlyph.Width div 6)
        else
          inc(Size.X, ItemExt + 2);
      end;
    end;

    if (FShowImages) then
    begin
      Fid := false;
      if FImages2 <> nil then FTImages := FImages2 else FTImages := FImages;
      if FTImages <> nil then
      begin
        if (Item.Focused or Item.Selected or Item.Cut or (Item.Expanded and Item.HasVisibleChildren)) then StImIndex := Item.FStImageIndex2 else StImIndex := Item.FImageIndex2;
        if StImIndex = -1 then StImIndex := DoGetPicture2(Item);
        if InRange(0, FTImages.Count - 1, StImIndex) or FShowEmptyImages2 then
        begin
          inc(Size.X, FTImages.Width);
          FID := true;
        end;
      end;
      if (FImages <> nil) then
      begin
        if (Item.Focused or Item.Selected or Item.Cut or (Item.Expanded and Item.HasVisibleChildren)) then StImIndex := Item.FStImageIndex else StImIndex := Item.FImageIndex;
        if StImIndex = -1 then StImIndex := DoGetPicture(Item);
        if InRange(0, FImages.Count - 1, StImIndex) or FShowEmptyImages then
        begin
          if FID then inc(Size.X, ItemExt div 3); // make the space between images
          inc(Size.X, FImages.Width);
        end;
      end;
    end; // Show images

    if (FODFollowCol and ({FShowHeader and }(FHeader.Sections.Count > 0) and (FHeader.Sections[FMainTreeCol].Style = ElhsOwnerDraw)))
      or ((Item.Text = FODMask) and (not (FODFollowCol)))
{$ifdef ELTREE_USE_STYLES}
      or (Item.FUseStyles and (Item.FMainStyle.FStyle = elhsOwnerDraw))
{$endif}
      then
    begin
      TriggerMeasureItemPartEvent(Item, ColumnNum, ASize);
      inc(Size.X, ASize.X + (ItemExt div 5) * 3);
    end
    else
    begin
      inc(Size.X, (ItemExt div 5) * 3);
{$ifdef ELTREE_USE_STYLES}
      if (Item.UseStyles and (CurStyle.FStyle = elhsText)) or (not Item.FUseStyles) then
{$endif}
      begin
        xxx := [];
        SaveFontStyle := Canvas.Font.Style;
        SaveFontSize := Canvas.Font.Height;
        SaveFontName := Canvas.Font.Name;
        OwnFontSet := false;
{$ifdef ELTREE_USE_STYLES}
        if Item.FUseStyles then
        begin
          if not CurStyle.FOwnerProps then with CurStyle do
          begin
            if Canvas.Font.Name <> FontName then
            begin
              Canvas.Font.Name := FontName;
              OwnFontSet := true;
            end;
            xxx := FontStyles;
            if Canvas.Font.Size <> FontSize then
            begin
              Canvas.Font.Size := FontSize;
              OwnFontSet := true;
            end;
            end else
          begin
            if Canvas.Font.Name <> Font.Name then
            begin
              Canvas.Font.Name := Font.Name;
              OwnFontSet := true;
            end;
            if Item.FParentStyle then xxx := Font.Style else
            begin
              if stsBold in Item.FState then Include(xxx, fsBold);
              if stsItalic in Item.FState then Include(xxx, fsItalic);
              if stsUnderlined in Item.FState then Include(xxx, fsUnderline);
              if stsStrikeOut in Item.FState then Include(xxx, fsStrikeout);
            end;
            if Canvas.Font.Size <> Font.Size then
            begin
              Canvas.Font.Size := Font.Size;
              OwnFontSet := true;
            end;
          end;
        end else
{$endif}
        begin
          if Canvas.Font.Name <> Font.Name then
          begin
            Canvas.Font.Name := Font.Name;
            OwnFontSet := true;
          end;
          if Item.FParentStyle then xxx := Font.Style else
          begin
            if stsBold in Item.FState then Include(xxx, fsBold);
            if stsItalic in Item.FState then Include(xxx, fsItalic);
            if stsUnderlined in Item.FState then Include(xxx, fsUnderline);
            if stsStrikeOut in Item.FState then Include(xxx, fsStrikeout);
          end;
          if Canvas.Font.Size <> Font.Size then
          begin
            Canvas.Font.Size := Font.Size;
            OwnFontSet := true;
          end;
        end;
        if Canvas.Font.Style <> xxx then
        begin
          Canvas.Font.Style := xxx;
          OwnFontSet := true;
        end;
        AL := DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_VCENTER or DT_LEFT or DT_CALCRECT;
        if RightAlignedText then
          AL := AL or DT_RTLREADING;
        SetRectEmpty(R3);
{$IFDEF HAS_HTML_RENDER}
        if Item.IsHTML and (Copy(Item.Text, 1, 6) = '<html>') then
        begin
          R3.Left := 0;
          R3.Top := 0;
          with FView.FRender do
          begin
            Data.DefaultStyle := Canvas.Font.Style;
            Data.DefaultFont  := Canvas.Font.Name;
            Data.DefaultSize  := Canvas.Font.Size;
            Data.Charset      := Canvas.Font.Charset;

            PrepareText(Item.Text, 0, false);
            R3.Right := Data.TextSize.cx;
            R3.Bottom := Data.TextSize.cy;
          end;
        end else
{$ENDIF}
          DrawText(Canvas.Handle, PChar(Item.Text), Length(Item.Text), R3,  DT_NOPREFIX or AL);

        Size.Y := Max(Size.Y, R3.Bottom - R3.Top + 1);

        Inc(Size.X, R3.Right - R3.Left);
        if OwnFontSet then
        begin
          Canvas.Font.Style  := SaveFontStyle;
          Canvas.Font.Height := SaveFontSize;
          Canvas.Font.Name   := SaveFontName;
        end;
      end
{$ifdef ELTREE_USE_STYLES}
      else
      if Item.UseStyles and (CurStyle.FStyle = elhsPictureOnly) and Assigned(CurStyle.FPicture) then
        Inc(Size.X, CurStyle.Picture.Width + 3);
{$endif}
    end;
    if FVLines then
      Inc(Size.X, 4)
    else
      Inc(Size.X, 2);
    exit;
  end;
  HS := FHeader.Sections[ColumnNum];
  if ColumnNum > FMainTreeCol then dec(ColumnNum);

  OwnFontSet := false;
{$ifdef ELTREE_USE_STYLES}
  CurStyle := nil;
  if Item.UseStyles then
  begin
    if (Item.StylesCount > ColumnNum) then
       CurStyle := Item.Styles[ColumnNum];
    if CurStyle = nil then
      CurStyle := Item.MainStyle;
  end;
{$endif}
  if Item.ColumnText.Count <= ColumnNum then SText := '' else SText := Item.ColumnText[ColumnNum];

  if (FODFollowCol and (HS.Style = ElhsOwnerDraw)) or ((not (FODFollowCol)) and (SText = FODMask))
{$ifdef ELTREE_USE_STYLES}
    or (Item.FUseStyles and (CurStyle.FStyle = elhsOwnerDraw))
{$endif}
    then
  begin
    TriggerMeasureItemPartEvent(Item, ColumnNum, Size);
    Inc(Size.X, (ItemExt div 5) * 3);
  end else
{$ifdef ELTREE_USE_STYLES}
  if Item.UseStyles and (CurStyle.Control <> nil) then
  begin
    Size.X := HS.Width;
    Size.Y := FLineHeight;
  end
  else
  if Item.UseStyles and (CurStyle.FStyle = elhsPictureOnly) and Assigned(CurStyle.FPicture) then
  begin
    Size.Y := CurStyle.FPicture.Height;
    Size.X := CurStyle.FPicture.Width;
  end
  else
  if (Item.UseStyles and (CurStyle.FStyle = elhsText)) or (not Item.FUseStyles) then
{$endif}
  begin
    SaveFontStyle := Canvas.Font.Style;
    SaveFontSize := Canvas.Font.Height;
    SaveFontName := Canvas.Font.Name;
{$ifdef ELTREE_USE_STYLES}
    if Item.FUseStyles then
    begin
      if not CurStyle.FOwnerProps then with CurStyle do
      begin
        if Canvas.Font.Name <> FontName then Canvas.Font.Name := FontName;
        if Canvas.Font.Style <> FontStyles then Canvas.Font.Style := FontStyles;
        if Canvas.Font.Size <> FontSize then Canvas.Font.Size := FontSize;
        OwnFontSet := true;
      end;
    end;
{$endif}
    AL := DT_NOPREFIX or {$IFNDEF LITE}MultiLineFlags[Item.Multiline] or {$ELSE} DT_SINGLELINE or{$ENDIF}DT_VCENTER or DT_LEFT or DT_CALCRECT;
    if RightAlignedText then AL := AL or DT_RTLREADING;
    if Item.ColumnText.Count <= ColumnNum then SText := '' else SText := Item.ColumnText[ColumnNum];
    if HS.Password then SText := '******';
    SetRectEmpty(R3);
{$IFDEF HAS_HTML_RENDER}
    if Item.IsHTML and (Copy(SText, 1, 6) = '<html>') then
    begin
      with FView.FRender do
      begin
        Data.DefaultStyle := Canvas.Font.Style;
        Data.DefaultFont  := Canvas.Font.Name;
        Data.DefaultSize  := Canvas.Font.Size;
        Data.Charset      := Canvas.Font.Charset;

        PrepareText(SText, 0, false);
        R3.Right := Data.TextSize.cx;
        R3.Bottom := Data.TextSize.cy;
      end;
    end else
{$ENDIF}
      DrawText(Canvas.Handle, PChar(SText), Length(SText), R3, DT_NOPREFIX or AL);
    InflateRect(R3, 1, 1);

    Size.X := R3.Right - R3.Left + FDivLineWidth * 2 + ItemExt div 5 * 3;
    Size.Y := Max(FLineHeight, R3.Bottom - R3.Top + 1);

    if OwnFontSet then
    begin
      Canvas.Font.Style  := SaveFontStyle;
      Canvas.Font.Height := SaveFontSize;
      Canvas.Font.Name   := SaveFontName;
    end;
  end
{$ifdef ELTREE_USE_STYLES}
  else
  begin
    Size.X := 0;
    Size.Y := FLineHeight;
  end;
{$endif}
end;
{$warnings on}
{$hints on}
function TCustomElTree.MeasureColumnWidth(ColumnNum: integer; VisibleOnly : boolean): integer;

{type TMeasureProc = procedure(Item : TElTreeItem; ColumnNum : integer; var Size : TPoint) of object;

type TSRec = record
       MeasureProc : TMeasureProc;
       CurWidth,
       ColumnNum    : integer;
     end;
     PSRec = ^TSRec;

         procedure IntMeasure(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean; IterateData: pointer; Tree: TCustomElTree);
         var P : TPoint;
         begin
           PSRec(IterateData).MeasureProc(Item, PSRec(IterateData).ColumnNum, P);
           if P.X > PSRec(IterateData).CurWidth then PSRec(IterateData).CurWidth := P.x;
         end;

var SRec : TSRec;
}
var i, j : integer;
    Item : TElTreeItem;
    CurWidth : integer;
    P    : TPoint;

begin
  if (ColumnNum >= FHeader.Sections.Count) then
  begin
    result := 0;
    exit;
  end;

  CurWidth := 0;
  i := 0;
  j := FAllList.Count;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);

    if (FilteredVisibility and Item.Hidden and VisibleOnly) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      MeasureCell(Item, ColumnNum, P);
      if P.X > CurWidth then CurWidth := P.x;
      if (not Item.Expanded) and VisibleOnly then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  result := CurWidth;
  {SRec.MeasureProc := MeasureCell;
  SRec.ColumnNum := ColumnNum;
  Canvas.Font.Assign(Font);
  Items.Iterate(VisibleOnly, @IntMeasure, @SRec);
  result := SRec.CurWidth;}
end;

procedure TCustomElTree.HeaderSectionAutoSizeHandler(Sender : TCustomElHeader; Section : TElHeaderSection);
begin
  if FAutoResizeColumns then
  begin
    if Section.AutoSize then
       AutoSizeColumn(Section.Index)
    else
       Section.Width := Max(FHeader.MeasureSectionWidth(Section, nil), MeasureColumnWidth(Section.Index, true));
    OnHeaderSectionResize(FHeader, Section);
  end else
  begin
    if Section.AutoSize then
       AutoSizeColumn(Section.Index)
    else
      SectionAutoSizeTransfer(Sender, Section);
  end;
end;  { HeaderSectionAutoSizeHandler }

procedure TCustomElTree.SectionAutoSizeTransfer(Sender : TCustomElHeader; Section : TElHeaderSection);
{ Transfers FHeader OnSectionAutoSize event to the outside world. }
begin
  if (assigned(FOnSectionAutoSize)) then
    FOnSectionAutoSize(Self, Section.Index);  { Substitute Self for subcomponent's Sender. }
end;  { SectionAutoSizeTransfer }

procedure TCustomElTree.SectionFilterCallTransfer(Sender : TCustomElHeader; Section : TElHeaderSection);
{ Transfers FHeader OnFilterCall event to the outside world. }
begin
  if (assigned(FOnSectionFilterCall)) then
    FOnSectionFilterCall(Self, Section.Index);  { Substitute Self for subcomponent's Sender. }
end;  { SectionFilterCallTransfer }

{ Exposed properties' Read/Write methods: }
procedure TCustomElTree.SetHeaderActiveFilterColor(newValue : TColor);
{ Sets the FHeader subcomponent's ActiveFilterColor property to newValue. }
begin
  FHeader.ActiveFilterColor := newValue;
end;  { SetHeaderActiveFilterColor }

function TCustomElTree.GetHeaderActiveFilterColor : TColor;
{ Returns the ActiveFilterColor property from the FHeader subcomponent. }
begin
  GetHeaderActiveFilterColor := FHeader.ActiveFilterColor;
end;  { GetHeaderActiveFilterColor }

procedure TCustomElTree.SetHeaderFilterColor(newValue : TColor);
{ Sets the FHeader subcomponent's FilterColor property to newValue. }
begin
  FHeader.FilterColor := newValue;
end;  { SetHeaderFilterColor }

function TCustomElTree.GetHeaderFilterColor : TColor;
{ Returns the FilterColor property from the FHeader subcomponent. }
begin
  GetHeaderFilterColor := FHeader.FilterColor;
end;  { GetHeaderFilterColor }

procedure TCustomElTree.SetHeaderFlat(newValue : Boolean);
{ Sets the FHeader subcomponent's Flat property to newValue. }
begin
  FHeader.Flat := newValue;
end;  { SetHeaderFlat }

function TCustomElTree.GetHeaderFlat : Boolean;
{ Returns the Flat property from the FHeader subcomponent. }
begin
  GetHeaderFlat := FHeader.Flat;
end;  { GetHeaderFlat }

procedure TCustomElTree.WMEnable(var Msg : TMessage);  { private }
begin
  inherited;
  if Flat or FUseCustomBars then DrawFlatBorder(false, false);
end;  { WMEnable }

procedure TCustomElTree.SetFlatFocusedScrollbars(newValue : Boolean);
{ Sets data member FFlatFocusedScrollbars to newValue. }
begin
  if (FFlatFocusedScrollbars <> newValue) then
  begin
    FFlatFocusedScrollbars := newValue;
    if Focused and (not FUseCustomBars) then DrawFlatBorder(false, false);
  end;  { if }
end;  { SetFlatFocusedScrollbars }

{$IFNDEF LITE}

procedure TCustomElTree.BackgroundChange(Sender : TObject);
begin
  if (Background.Empty) then FBackgroundType := bgtColorFill else
  begin
    with FView do
    begin
      RedoTmpBmp;
      if BackgroundType <> bgtColorFill then
        if not (csLoading in ComponentState) then Invalidate;//Repaint;
    end;
  end;
end;

procedure TCustomElTree.SetBackground(newValue : TBitmap);
{ Sets data member FBackground to newValue. }
begin
  FBackground.Assign(newValue);
end;  { SetBackground }

procedure TCustomElTree.SetBackgroundType(newValue : TElBkGndType);
{ Sets data member FBackgroundType to newValue. }
begin
  if (FBackgroundType <> newValue) then
  begin
    if (Background.Empty) and (FBackGroundType in [bgtTileBitmap, bgtStretchBitmap, bgtCenterBitmap])
       then FBackgroundType := bgtColorFill
       else FBackgroundType := newValue;
    with FView do
    begin
      RedoTmpBmp;
      if not (csLoading in Self.ComponentState) then Invalidate;//Repaint;
    end;
  end;  { if }
end;  { SetBackgroundType }
{$ENDIF}

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.TriggerTuneUpInplaceEditEvent(Item : TElTreeItem; SectionIndex : integer; Editor : TCustomEdit);
begin
  if (assigned(FOnTuneUpInplaceEdit)) then
    FOnTuneUpInplaceEdit(Self, Item , SectionIndex, Editor);
end;  { TriggerTuneUpInplaceEditEvent }
{$endif}

procedure TCustomElTree.SetHideSelectTextColor(newValue: TColor);
begin
  if (FHideSelectTextColor <> newValue) then
  begin
    FHideSelectTextColor := newValue;
    if (((GetParentForm(self) = nil) or (GetParentForm(self).ActiveControl <> self)) and FHideSelect) then FView.Invalidate;//Repaint;
  end;  {if}
end;

procedure TCustomElTree.SetFocusedSelectTextColor(newValue: TColor);
begin
  if (FFocusedSelectTextColor <> newValue) then
  begin
    FFocusedSelectTextColor := newValue;
    if (((GetParentForm(self) <> nil) and (GetParentForm(self).ActiveControl = self)) or (not FHideSelect)) then FView.Invalidate;//Repaint;
  end;  {if}
end;

procedure TCustomElTree.SetHideSelectColor(newValue: TColor);
begin
  if (FHideSelectColor <> newValue) then
  begin
    FHideSelectColor := newValue;
    if (((GetParentForm(self) = nil) or (GetParentForm(self).ActiveControl <> self)) and FHideSelect) then FView.Invalidate;//Repaint;
  end;  {if}
end;

procedure TCustomElTree.SetFocusedSelectColor(newValue: TColor);
begin
  if (FFocusedSelectColor <> newValue) then
  begin
    FFocusedSelectColor := newValue;
    if (((GetParentForm(self) <> nil) and (GetParentForm(self).ActiveControl = self)) or (not FHideSelect)) then FView.Invalidate;//Repaint;
  end;  {if}
end;
{$IFNDEF LITE}
procedure TCustomElTree.SetNoBlendSelected(newValue : Boolean);
{ Sets data member FNoBlendSelected to newValue. }
begin
  if (FNoBlendSelected <> newValue) then
  begin
    FNoBlendSelected := newValue;
    if BackGroundType <> bgtColorFill then FView.Invalidate;//Repaint;
  end;  { if }
end;  { SetNoBlendSelected }
{$ENDIF}
procedure TCustomElTree.SetRowHotTrack(newValue : Boolean);
{ Sets data member FRowHotTrack to newValue. }
begin
  if (FRowHotTrack <> newValue) then
  begin
    FRowHotTrack := newValue;
    with FView do
      if Tracking and (FTrackItem <> nil) then FTrackItem.RedrawItem(true);
  end;  { if }
end;  { SetRowHotTrack }

procedure TCustomElTree.SetActiveBorderType(newValue : TElFlatBorderType);
{ Sets data member FActiveBorderStyle to newValue. }
begin
  if (FActiveBorderType <> newValue) then
  begin
    FActiveBorderType := newValue;
    if (FView.Focused or FMouseOver) or FUseCustomBars then UpdateFrame;
  end;  { if }
end;  { SetActiveBorderStyle }

procedure TCustomElTree.SetInactiveBorderType(newValue : TElFlatBorderType);
{ Sets data member FInactiveBorderStyle to newValue. }
begin
  if (FInactiveBorderType <> newValue) then
  begin
    FInactiveBorderType := newValue;
    if not (FView.Focused or FMouseOver) or FUseCustomBars then UpdateFrame;
  end;  { if }
end;  { SetInactiveBorderStyle }

{$IFNDEF LITE}
procedure TCustomElTree.SetGradientStartColor(newValue : TColor);
{ Sets data member FGradientStartColor to newValue. }
begin
  if (FGradientStartColor <> newValue) then
  begin
    FGradientStartColor := newValue;
    if (BackgroundType in [bgtHorzGradient, bgtVertGradient]) and (FUpdateCount = 0) then
    with FView do
    begin
      RedoTmpBmp;
      Invalidate;//Repaint;
    end;
  end;  { if }
end;  { SetGradientStartColor }

procedure TCustomElTree.SetGradientEndColor(newValue : TColor);
{ Sets data member FGradientEndColor to newValue. }
begin
  if (FGradientEndColor <> newValue) then
  begin
    FGradientEndColor := newValue;
    if (BackgroundType in [bgtHorzGradient, bgtVertGradient]) and (FUpdateCount = 0) then
    with FView do
    begin
      RedoTmpBmp;
      Invalidate;//Repaint;
    end;
  end;  { if }
end;  { SetGradientEndColor }

procedure TCustomElTree.SetGradientSteps(newValue : Integer);
{ Sets data member FGradientSteps to newValue. }
begin
  if (FGradientSteps <> newValue) and (newValue > 0) then
  begin
    FGradientSteps := newValue;
    if (BackgroundType in [bgtHorzGradient, bgtVertGradient]) and (FUpdateCount = 0) then
    with FView do
    begin
      RedoTmpBmp;
      Invalidate;//Repaint;
    end;
  end;  { if }
end;  { SetGradientSteps }
{$ENDIF LITE}

function TCustomElTree.GetHeaderImages: TImageList;
{ Returns the value of data member FHeaderImages. }
begin
  result := FHeader.Images;
end; { GetHeaderImages }

procedure TCustomElTree.SetHeaderImages(newValue: TImageList);
{ Sets data member FHeaderImages to newValue. }
begin
  if (FHeader.Images <> newValue) then FHeader.Images := newValue;
end; { SetHeaderImages }

procedure TCustomElTree.TriggerScrollEvent(ScrollBarKind: TScrollBarKind; ScrollCode: integer);
begin
  if (assigned(FOnScroll)) then
    FOnScroll(Self, ScrollBarKind, ScrollCode);
end; { TriggerScrollEvent }

procedure TCustomElTree.DeSelectAllEx; { public }

{  procedure IntSelAll(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if (Item.FIState and tisSelected) > 0 then
    begin
      Item.Selected := false;
      if Tree.FSelectedList.Count = 0 then ContinueIterate := false;
    end;
  end;
}
var i : integer;
    TI : TElTreeItem;
begin
  if FMultiSelect = false then exit;
  if not IncludeHidden then DeselectAll else
  begin
    IsUpdating := true;
    for i := 0 to Pred(FSelectedList.Count) do    // Iterate
    begin
      TI := TElTreeItem(FSelectedList[i]);
      FSelChange := true;
      Exclude(TI.FState, stsSelected);
      TI.FIState := TI.FIState and (not tisSelected);
      if FView.FSelected = TI then FView.FSelected := nil;
      TriggerItemSelectedChangeEvent(TI);
      TI.UpdateItem;
    end;    // for
    FSelectedList.Count := 0;
    IsUpdating := false;
  end;
{  exit;

  IsUpdating := true;
  FItems.Iterate(not IncludeHidden, @IntSelAll, nil);
  IsUpdating := false;
}
end; { DeSelectAll }

procedure TCustomElTree.DeSelectAll; { public }

{  procedure IntSelAll(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if (Item.FIState and tisSelected) > 0 then
    begin
      Item.Selected := false;
      if Tree.FSelectedList.Count = 0 then ContinueIterate := false;
    end;
  end;
}

var i  : integer;
    TI : TElTreeItem;
begin
  if FMultiSelect = false then exit;
  IsUpdating := true;
  i := 0;
  while i < FSelectedList.Count do    // Iterate
  begin
    TI := TElTreeItem(FSelectedList[i]);
    if not (FilteredVisibility and TI.Hidden) then
    begin
      FSelChange := true;
      Exclude(TI.FState, stsSelected);
      TI.FIState := TI.FIState and (not tisSelected);
      FSelectedList.Remove(TI);
      if FView.FSelected = TI then FView.FSelected := nil;
      TriggerItemSelectedChangeEvent(TI);
      TI.UpdateItem;
    end else inc(i);
  end;    // for
  //FItems.Iterate(FilteredVisibility, @IntSelAll, nil);
  IsUpdating := false;
end; { DeSelectAll }

procedure TCustomElTree.SelectAllEx; { public }

{  procedure IntSelAll(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if (Item.FIState and tisSelected) = 0 then Item.Selected := true;
  end;
}

var i, j : integer;
    Item : TElTreeItem;

begin
  if FMultiSelect = false then exit;
  i := 0;
  j := FAllList.Count;
  IsUpdating := true;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);

    if (FilteredVisibility and (not IncludeHidden) and Item.Hidden) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      if (Item.FIState and tisSelected) = 0 then Item.Selected := true;
      if (not Item.Expanded) and (not IncludeHidden) then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  IsUpdating := false;

  {if FMultiSelect = false then exit;
  IsUpdating := true;
  FItems.Iterate(not IncludeHidden, @IntSelAll, nil);
  IsUpdating := false;}
end; { SelectAll }

procedure TCustomElTree.SelectAll; { public }

{  procedure IntSelAll(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    if (Item.FIState and tisSelected) = 0 then Item.Selected := true;
  end;
}

var i, j : integer;
    Item : TElTreeItem;

begin
  if FMultiSelect = false then exit;
  i := 0;
  j := FAllList.Count;
  IsUpdating := true;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);

    if (FilteredVisibility and Item.Hidden) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      if (Item.FIState and tisSelected) = 0 then Item.Selected := true;
      if (not Item.Expanded) and (FilteredVisibility) then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  IsUpdating := false;

  {if FMultiSelect = false then exit;
  IsUpdating := true;
  FItems.Iterate(FilteredVisibility, @IntSelAll, nil);
  IsUpdating := false;}
end; { SelectAll }

procedure TCustomElTree.InvertSelectionEx; { public }

{  procedure IntInvSel(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    Item.Selected := not Item.Selected;
  end;
}
var i, j : integer;
    Item : TElTreeItem;

begin
  if FMultiSelect = false then exit;
  i := 0;
  j := FAllList.Count;
  IsUpdating := true;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);

    if (FilteredVisibility and (not IncludeHidden) and Item.Hidden) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      Item.Selected := not Item.Selected;
      if (not Item.Expanded) and (not IncludeHidden) then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  IsUpdating := false;

  {if FMultiSelect = false then exit;
  IsUpdating := true;
  FItems.Iterate(not IncludeHidden, @IntInvSel, nil);
  IsUpdating := false;}
end;

procedure TCustomElTree.InvertSelection; { public }

{  procedure IntInvSel(Item: TElTreeItem; Index: integer; var ContinueIterate: boolean;
    IterateData: pointer; Tree: TCustomElTree);
  begin
    Item.Selected := not Item.Selected;
  end;
}

var i, j : integer;
    Item : TElTreeItem;

begin
  if FMultiSelect = false then exit;
  i := 0;
  j := FAllList.Count;
  IsUpdating := true;
  while i < j do
  begin
    Item := TElTreeItem(FAllList[i]);

    if (FilteredVisibility and Item.Hidden) then
    begin
      i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end else
    begin
      Item.Selected := not Item.Selected;
      if (not Item.Expanded) and (FilteredVisibility) then
         i := FAllList.IndexOfFrom(i, Item.GetLastSubItem);
    end;
    inc(i);
  end;
  IsUpdating := false;

{
  if FMultiSelect = false then exit;
  IsUpdating := true;
  FItems.Iterate(FilteredVisibility, @IntInvSel, nil);
  IsUpdating := false;
}  
end;

function TCustomElTree.GetFocused: TElTreeItem;
begin
  result := FView.FFocused;
end;

function TCustomElTree.GetSelected: TElTreeItem;
begin
  result := FView.FSelected;
end; { GetSelected }  

procedure TCustomElTree.SetSelected(newValue: TElTreeItem);
begin
  if not FMultiSelect then
     DoSetFocused(newValue, false)
  else
    if FView <> nil then
       FView.FSelected := newValue;
end; { SetSelected }

function TCustomElTree.GetTopItem: TElTreeItem; { public }
begin
  with FView do
    if FVisible.Count = 0 then
      result := nil
    else
      Result := FVisible[0];
end; { GetTopItem }

procedure TCustomElTree.SetTopItem(Item: TElTreeItem); { public }
begin
  if Item = nil then raise EElTreeError.Create(STexInvItem);
  TopIndex := Item.VisIndex;
end; { SetTopItem }

procedure TCustomElTree.TriggerHeaderColumnMoveEvent;
begin
  if (assigned(FOnHeaderColumnMove)) then
    FOnHeaderColumnMove(Self, Section, OldPos, NewPos);
end; { TriggerHeaderColumnMoveEvent }

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.TriggerTryEditEvent(Item: TElTreeItem; Section:
  TElHeaderSection; var CellType: TFieldTypes; var CanEdit: boolean);
begin
  if (assigned(FOnTryEdit)) and (not (csDestroying in ComponentState)) then
    FOnTryEdit(Self, Item, Section, CellType, CanEdit);
end;
{$endif}

procedure TCustomElTree.TriggerItemSaveEvent(Stream: TStream; Item: TElTreeItem);
begin
  if (assigned(FOnItemSave)) then FOnItemSave(Self, Stream, Item);
end;

procedure TCustomElTree.TriggerItemLoadEvent(Stream: TStream; Item:
  TElTreeItem);
begin
  if (assigned(FOnItemLoad)) then FOnItemLoad(Self, Stream, Item);
end;

{$ifdef SUPPORT_STORAGE}
procedure TCustomElTree.Save;
var
  FSaveKey: string;
  F: TForm;
  S: string;
  AKey: string;
begin
  if Assigned(FStorage) then
  begin
    F := GetOwnerForm(Self);
    if (F <> nil) and (F.Name <> '') then S := F.Name + FStorage.Delimiter else S := '';
    AKey := FStorage.Delimiter + S + FStoragePath;
    FHeader.Storage := FStorage;
    FHeader.StoragePath := AKey;
    FHeader.Save;
    if FStorage.OpenKey(AKey, true) then
    begin
      FStorage.WriteInteger('', 'FontSize', Font.Size);
      FStorage.WriteInteger('', 'FontColor', Font.Color);
      FStorage.WriteString('', 'FontName', Font.Name);
      FStorage.WriteBool('', 'FontBold', fsBold in Font.Style);
      FStorage.WriteBool('', 'FontItalic', fsItalic in Font.Style);
      FStorage.WriteBool('', 'FontUnderline', fsUnderline in Font.Style);
      FStorage.WriteBool('', 'FontStrikeout', fsStrikeout in Font.Style);
      FStorage.WriteInteger('', 'SortType', integer(FSortType));
      FStorage.WriteInteger('', 'SortMode', integer(FSortMode));
      FStorage.WriteInteger('', 'SortDir', integer(FSortDir));
      FStorage.WriteInteger('', 'SortSection', integer(FSortSection));
    end;
    FStorage.OpenKey(FSaveKey, false);
  end;
end; {Save}

procedure TCustomElTree.Restore;
var
  FSaveKey: string;
  i: integer;
  b: Boolean;
  s: string;
  F: TForm;
  AKey: string;
begin
  IsUpdating := true;
  if Assigned(FStorage) then
  begin
    F := GetOwnerForm(Self);
    if (F <> nil) and (F.Name <> '') then S := F.Name + FStorage.Delimiter else S := '';
    AKey := FStorage.Delimiter + S + FStoragePath;
    FHeader.Storage := FStorage;
    FHeader.StoragePath := AKey;
    FHeader.Restore;
    FSaveKey := FStorage.CurrentKey;
    if FStorage.OpenKey(AKey, false) then
    begin
      FStorage.ReadInteger('', 'FontSize', Font.Size, i);
      Font.Size := i;
      FStorage.ReadInteger('', 'FontColor', Font.Color, i);
      Font.Color := i;
      FStorage.ReadString('', 'FontName', Font.Name, s);
      Font.Name := s;
      FStorage.ReadBool('', 'FontBold', fsBold in Font.Style, b);
      if b then Font.Style := Font.Style + [fsBold] else Font.Style := Font.Style - [fsBold];
      FStorage.ReadBool('', 'FontItalic', fsItalic in Font.Style, b);
      if b then Font.Style := Font.Style + [fsItalic] else Font.Style := Font.Style - [fsItalic];
      FStorage.ReadBool('', 'FontUnderline', fsUnderline in Font.Style, b);
      if b then Font.Style := Font.Style + [fsUnderline] else Font.Style := Font.Style - [fsUnderline];
      FStorage.ReadBool('', 'FontStrikeout', fsStrikeout in Font.Style, b);
      if b then Font.Style := Font.Style + [fsStrikeout] else Font.Style := Font.Style - [fsStrikeout];
      FStorage.ReadInteger('', 'SortType', integer(FSortType), i);
      FSortType := TSortTypes(i);
      FStorage.ReadInteger('', 'SortMode', integer(FSortMode), i);
      FSortMode := TSortModes(i);
      FStorage.ReadInteger('', 'SortDir', integer(FSortDir), i);
      FSortDir := TSortDirs(i);
      FStorage.ReadInteger('', 'SortSection', FSortSection, i);
      FSortSection := i;
    end;
    FStorage.OpenKey(FSaveKey, false);
  end;
  IsUpdating := false;
end; {Restore}
{$ENDIF}

procedure TCustomElTree.TriggerItemSelectedChangeEvent(Item: TElTreeItem);
begin
  if (assigned(FOnItemSelectedChange)) and (not (csDestroying in ComponentState)) then
    FOnItemSelectedChange(Self, Item);
end; {TriggerItemSelectedChangeEvent}

procedure TCustomElTree.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  //inherited;
  Message.Result := 1;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.EndEdit(ByCancel: boolean);
begin
  FView.DoEndEdit(ByCancel);
end;

procedure TCustomElTree.EditItem;
begin
  if not FCanEdit then exit;
  try
    with FView do
      if FInpEdit <> nil then EndEdit(true);
  except
  end;
  FView.DoEditItem(Item, SectionNum);
end;
{$endif}

procedure TCustomElTree.SetShowHeader;
begin
  if (FHeader = nil) then exit;
  if not (csReading in ComponentState) and (Value) and (FHeader.Sections.Count = 0) then exit;
  FShowHeader := value;
  if value = false then FView.FHRange := -1;
  //if csReading in ComponentState then exit;
  IsUpdating := true;
  FUpdated := true;
  with FView do
  begin
    FVisUpdated := true;
    FClearAll := true;
    FClearVis := true;
  end;
{$IFNDEF LITE}
  if not (BackgroundType in [bgtColorFill, bgtCenterBitmap]) then FView.RedoTmpBmp;
{$ENDIF}
  AlignPieces;
  IsUpdating := false;
end;

procedure TCustomElTree.SetMainTreeCol;
begin
  if value = FMainTreeCol then exit;
  if value >= FHeader.Sections.Count then FMainTreeCol := 0 else FMainTreeCol := value;
  IsUpdating := true;
  FView.FRangeUpdate := true;
  FUpdated := true;
  IsUpdating := false;
end;

procedure TCustomElTree.DoHeaderResize;
begin
  if FView.FPainting then exit;
  IsUpdating := true;
  FUpdated := true;
  with FView do
  begin
    FRangeUpdate := true;
    FClearVis := true;
  end;
  if SavedHH <> FHeader.Height then
  begin
    with FView do
    begin
      FClearAll := true;
      FVisUpdated:= true;
    end;
    AlignPieces;
  end;
  if (FHeader.LeftPos <> FHPos) {or (FHeader.Width <> FHPos + FView.Width)} then
  begin
    FHeader.LeftPos := FHPos;
    {//LockedColumn, update
    FHeader.Left := -FHPos;
    FHeader.Width := FHPos + FView.Width;}
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.DoHeaderDraw;
begin
  if assigned(FOnColumnDraw) then FOnColumnDraw(Header, Section, Rect, Pressed);
end;

procedure TCustomElTree.CMFontChanged(var Message: TMessage);
begin
  inherited;
  if Canvas <> nil then Canvas.Font.Assign(Font);
//  if FInpEdit <>nil then FInpEdit.Font.Assign(Font);
  if FHeader <> nil then
  begin
    FHeader.Font.Assign(Font);
    TElHeaderHack(FHeader).OnFontChange(FHeader.Font);
  end;
  FView.Font.Assign(Font);
  if FHScrollBar <> nil then THackScrollBar(FHScrollBar).Font.Assign(Font);
  if FVScrollBar <> nil then THackScrollBar(FVScrollBar).Font.Assign(Font);

  IsUpdating := true;
  FView.FRangeUpdate := true;
  FUpdated := true;
  IsUpdating := false;
end;

procedure TCustomElTree.CMColorChanged(var Message: TMessage);
begin
  inherited;
  if Canvas <> nil then Canvas.Brush.Color := Color;
end;

procedure TCustomElTree.SetHeaderHeight(value: integer);
begin
  IsUpdating := true;
  if csLoading in ComponentState then FHeaderHeight := value else
  begin
    FHeader.Height := value;
    AlignPieces;
    {$IFNDEF LITE}
    if not (BackgroundType in [bgtColorFill, bgtCenterBitmap]) then FView.RedoTmpBmp;
    {$ENDIF}
  end;
  with FView do
  begin
    FClearAll := true;
    FClearVis := true;
  end;
  FUpdated := true;
  IsUpdating := false;
end;

function TCustomElTree.GetHeaderHeight;
begin
  Result := FHeader.Height;
end;

procedure TCustomElTree.SetHeaderSections;
begin
  IsUpdating := true;
  FHeader.Sections := value;
  FUpdated := true;
  FView.FRangeUpdate := true;
  IsUpdating := false;
end;

function TCustomElTree.GetHeaderSections;
begin
  Result := FHeader.Sections;
end;

procedure TCustomElTree.SaveStringsToStream(Stream: TStream);

  procedure IntSaveString(Item: TElTreeItem);
  var
    NodeStr: string;
  begin
    NodeStr := StringOfChar(' ', Pred(Item.Level)) + Item.Text + #13#10;
    Stream.Write(Pointer(NodeStr)^, Length(NodeStr));
  end;

var i : integer;
    Item : TElTreeItem;

begin
  for i := 0 to Pred(FAllList.Count) do
  begin
    Item := TElTreeItem(FAllList[i]);
    IntSaveString(Item);
  end;
end;

function TCustomElTree.GetItemAtY(y: integer): TElTreeItem;
begin
  Result := FView.GetItemAtY(y - FView.Top);
end;

function TCustomElTree.Focused : boolean;
begin
  result := (HandleAllocated and (GetFocus = Handle)) or
            (FView.HandleAllocated and (GetFocus = FView.Handle));
end;

procedure TCustomElTree.FullCollapse;
var
  i: integer;
begin
  if FItems.FRoot.FChildren = nil then exit;
  IsUpdating := true;
  try
    for i := 0 to FItems.FRoot.FChildren.Count - 1 do
      TElTreeItem(THackElList(FItems.FRoot.FChildren).FList[i]).Collapse(true);
  finally
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.FullExpand;
var
  i: integer;
begin
  if FItems.FRoot.FChildren = nil then exit;
  IsUpdating := true;
  try
    for i := 0 to FItems.FRoot.FChildren.Count - 1 do
      TElTreeItem(THackElList(FItems.FRoot.FChildren).FList[i]).Expand(true);
  finally
    IsUpdating := false;
  end;
end;

{$IFDEF ELPACK_COMPLETE}
procedure TCustomElTree.ImageFormChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomElTree.SetImageForm(newValue : TElImageForm);
begin
  if FImgForm <> newValue then
  begin
    if FImgForm <> nil then FImgForm.UnregisterChanges(FImgFormChLink);
    if newValue <> nil then
       newValue.FreeNotification(Self);
    FImgForm := newValue;
    if FImgForm <> nil then
    begin
      FImgForm.RegisterChanges(FImgFormChLink);
      FImgForm.FreeNotification(Self);
    end;
    Invalidate;
  end;
end;
{$ENDIF}
procedure TCustomElTree.SetTextColor(value: TColor);
begin
  if FTextColor = value then exit;
  FTextColor := value;
  IsUpdating := true;
  FUpdated := true;
  with FView do
  begin
    FVisUpdated := true;
    FClearVis := true;
    FClearAll := true;
  end;
  IsUpdating := false;
end;

procedure TCustomElTree.SetBkColor(value: TColor);
begin
  if FBkColor = value then exit;
  FBkColor := value;
  IsUpdating := true;
  FUpdated := true;
  with FView do
  begin
    FVisUpdated := true;
    FClearVis := true;
    FClearAll := true;
  end;
  IsUpdating := false;
end;                           

procedure TCustomElTree.SetItems(value: TElTreeItems);
begin
  FItems.Assign(value);
end;

function TCustomElTree.CreateItems;
begin
  result := TElTreeItems.Create(Self);
end;

procedure TCustomElTree.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
{$ifdef SUPPORT_STORAGE}
    if AComponent = FStorage then FStorage := nil;
{$endif}
{$IFDEF ELPACK_COMPLETE}
    if AComponent = FImgForm then
    begin
      ImageForm := nil;
      Invalidate;
    end;
{$ENDIF}
    if AComponent = Images then
    begin
      Images.UnRegisterChanges(FImageChangeLink);
      Images := nil;
    end;
    if AComponent = Images2 then
    begin
      Images2.UnRegisterChanges(FImageChangeLink);
      Images2 := nil;
    end;
  end;
end;

procedure TCustomElTree.SelectRangeEx2(FromItem, ToItem: TElTreeItem; IncludeHidden, SelectDisabled: boolean);
var i,
    EndIdx,
    StartIdx : integer;
    Item,
    LItem : TElTreeItem;
begin
  if FMultiSelect = false then exit;
  if (FromItem = ToItem) and (FromItem <> nil) then exit;
  if (not FilteredVisibility) or IncludeHidden then
     SelectRange2(FromItem, ToItem, SelectDisabled)
  else
  begin
    IsUpdating := true;
    try
      if FromItem = nil then
         StartIdx := 0
      else
         StartIdx := FromItem.AbsoluteIndex;

      if ToItem = nil then
         EndIdx := 0
      else
         EndIdx := ToItem.AbsoluteIndex;

      if StartIdx > EndIdx then
      begin
        i := EndIdx;
        EndIdx := StartIdx;
        StartIdx := i;
      end;
      i := StartIdx;
      while i < EndIdx do
      begin
        Item := TElTreeItem(FAllList[i]);
        if Item.Hidden then
        begin
          LItem := Item.GetLastSubItem;
          if LItem <> nil then
             i := FAllList.IndexOfFrom(i, LItem);
        end else
        begin
          if SelectDisabled or TElTreeItem(FAllList[i]).Enabled then
             TElTreeItem(FAllList[i]).Selected := true;
        end;
        inc(i);
      end;
    finally
      IsUpdating := false;
    end;
  end;
end;

procedure TCustomElTree.SelectRangeEx(FromItem, ToItem: TElTreeItem; IncludeHidden: boolean);
begin
  SelectRangeEx2(FromItem, ToItem, IncludeHidden, true);
end;

procedure TCustomElTree.SelectRange2(FromItem, ToItem: TElTreeItem; SelectDisabled : boolean);
var i, EndIdx,
    StartIdx : integer;
begin
  if FMultiSelect = false then exit;
  if (FromItem = ToItem) and (FromItem <> nil) then exit;
  IsUpdating := true;
  try
    if FromItem = nil then
       StartIdx := 0
    else
       StartIdx := FromItem.AbsoluteIndex;

    if ToItem = nil then
       EndIdx := 0
    else
       EndIdx := ToItem.AbsoluteIndex;

    if StartIdx > EndIdx then
    begin
      i := EndIdx;
      EndIdx := StartIdx;
      StartIdx := i;
    end;
    for i := StartIdx to EndIdx do
      if SelectDisabled or (TElTreeItem(FAllList[i]).Enabled) then
         TElTreeItem(FAllList[i]).Selected := true;
  finally
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.SelectRange(FromItem, ToItem: TElTreeItem);
begin
  SelectRange2(FromItem, ToItem, true);
end;

procedure TCustomElTree.SetUseStdBars(value : boolean);
begin
  if Value <> FUseCustomBars then
  begin
    FUseCustomBars := Value;
    RecreateWnd;
  end;
end;

procedure TCustomElTree.SetChStateImage(value: boolean);
begin
  if value = FChStateImage then exit;
  IsUpdating := true;
  FChStateImage := value;
  FView.FRangeUpdate := true;
  FUpdated := true;
  IsUpdating := false;
end;

procedure TCustomElTree.SetHideSelect(value: boolean);
begin
  if value = FHideSelect then exit;
  FHideSelect := value;
  if (not Focused) and (HandleAllocated) then
  begin
    IsUpdating := true;
    FView.FRangeUpdate := true;
    FUpdated := true;
    IsUpdating := false;
  end;
end;

procedure TCustomElTree.Assign(Source: TPersistent);
var
  T: TCustomElTree;
{$IFNDEF VER90}
  Form: TCustomForm;
{$ELSE}
  Form: TForm;
{$ENDIF}

begin
  if Source is TCustomElTree then
  begin
    //inherited;
    IsUpdating := true;
    T := TCustomElTree(Source);
    FItems.Assign(T.FItems);
    FLinesStyle := T.FLinesStyle;
    FLinesColor := T.LinesColor;
    FDeselectChildrenOnCollapse := T.FDeselectChildrenOnCollapse;
    FDrawFocusRect := T.FDrawFocusRect;
    FBarStyle := T.FBarStyle;
    FAlwaysKeepSelection := T.FAlwaysKeepSelection;
    FFullRowSelect := T.FFullRowSelect;
    FDragType := T.FDragType;
    FAutoLookup := T.FAutoLookup;
    FSelectColumn := T.FSelectColumn;
    FAutoExpand := AutoExpand;
    FPlusPicture.Assign(T.FPlusPicture);
    FMinusPicture.Assign(T.FMinusPicture);
    FCustomPlusMinus := T.FCustomPlusMinus;
    FShowCheckboxes := T.FShowCheckboxes;
{Soulsnake Add}
    FInvertClickCheckBoxes := T.FInvertClickCheckBoxes;
{End Soulsnake Add}
    FHideHorzScrollBar := T.FHideHorzScrollBar;
    FHideVertScrollBar := T.FHideVertScrollBar;

    FBkColor := T.FBkColor;
    FTextColor := T.FTextColor;
    FShowButtons := T.FShowButtons;
    FShowLines := T.FShowLines;
    FShowImages := T.FShowImages;
    FShowRoot := T.FShowRoot;
    FShowHintMode := T.FShowHintMode;
    ShowColumns := T.ShowColumns;
    FBorderStyle := T.FBorderStyle;
    FCanEdit := T.FCanEdit;
    FHLines := T.FHLines;
    FVLines := T.FVLines;
    FScrollTracking := T.FScrollTracking;
    FTracking := T.FTracking;
    HeaderHotTrack := T.HeaderHotTrack;
    FODFollowCol := T.FODFollowCol;
    FODMask := T.FODMask;
    FDragTrgDrawMode := T.FDragTrgDrawMode;
    TopIndex := T.TopIndex;
    FAutoLineHeight := T.FAutoLineHeight;
    FLineHeight := T.FLineHeight;
{$IFDEF ELPACK_COMPLETE}
    FStorage := T.FStorage;
    FStoragePath := T.FStoragePath;
{$ENDIF}
    FUpdated := true;
    with FView do
    begin
      FHRange := -1;
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
    end;
    IsUpdating := false;
    if csDesigning in ComponentState then
    begin
      Form := GetParentForm(self);
      if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
    end;
  end else inherited;
end;

procedure TCustomElTree.Sort;
begin
  TriggerSortBegin;
  inc(FInSorting);
  FItems.FRoot.Sort(recursive);
  dec(FInSorting);
  TriggerSortEnd;
end;

procedure TCustomElTree.CMMouseEnter;
begin
  inherited;
  FMouseOver := true;
  if Flat and (not Focused) and (FInactiveBorderType <> FActiveBorderType) then DrawFlatBorder(false, false);
end;

procedure TCustomElTree.CMMouseLeave;
begin
  FMouseOver := false;
  if Flat and (not Focused) and (FInactiveBorderType <> FActiveBorderType) then DrawFlatBorder(false, false);
  inherited;
end;

procedure TCustomElTree.OnHeaderSectionDelete;
begin
  if FHeader.Sections.Count = 0 then ShowColumns := false;
  IsUpdating := true;
  with FView do
    if not FShowHeader then FHRange := -1 else FClearVis := true;
  AlignPieces;
  FUpdated := true;
  IsUpdating := false;
end;

function TCustomElTree.DoGetPicture(Item: TElTreeItem): integer;
begin
  result := Item.ImageIndex;
  if Assigned(FOnItemPicDraw) then FOnItemPicDraw(self, Item, result);
end;

function TCustomElTree.DoGetPicture2(Item: TElTreeItem): integer;
begin
  result := Item.ImageIndex2;
  if Assigned(FOnItemPicDraw2) then FOnItemPicDraw2(self, Item, result);
end;

function TCustomElTree.GetDraggableSections: Boolean;
{ Returns the value of data member FDraggableSections. }
begin
  result := FHeader.AllowDrag;
end; { GetDraggableSections }

procedure TCustomElTree.SetDraggableSections(newValue: Boolean);
begin
  if FHeader.AllowDrag <> newValue then
  begin
    FHeader.AllowDrag := newValue;
  end; { if }
end; { SetDraggableSections }

procedure TCustomElTree.OnHeaderSectionMove(Sender: TCustomElHeader; Section: TElHeaderSection; OldPos, NewPos: integer); { protected }
begin
  IsUpdating := true;
  FView.FClearAll := true;
  FUpdated := true;
  IsUpdating := false;
  TriggerHeaderColumnMoveEvent(Section, OldPos, NewPos);
end; { OnHeaderSectionMove }

procedure TCustomElTree.TriggerHotTrackEvent(OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem; NewSection: TElHeaderSection);
begin
  if assigned(FOnHotTrack) then FOnHotTrack(Self, OldItem, OldSection, NewItem, NewSection);
end; { TriggerHotTrackEvent }

procedure TCustomElTree.SetSortMode(newValue: TSortModes);
begin
  if FSortMode <> newValue then FSortMode := newValue;
end; { SetSortMode }

procedure TCustomElTree.SetSortSection(newValue: Integer);
begin
  if FSortSection <> newValue then
  begin
    FSortSection := newValue;
  end;
end; { SetSortSection }

function TCustomElTree.CompareItems(Item1, Item2: TElTreeItem; SM : TElSSortMode; ST : TSortTypes; FSortSection : integer): integer;
var
  T1, T2   : TDateTime;
  N1, N2   : integer;
  F1, F2   : extended;
  B1, B2   : boolean;
  C1, C2   : Currency;
begin
  if FSortSection = -1 then
  begin
    DoCompareItems(Item1, Item2, result);
    if FSortDir = sdDescend then
       result := -result;
  end
  else
  begin
    if ST = stCustom then
    begin
      DoCompareItems(Item1, Item2, result);
      if (SM = hsmDescend) or ((SM = hsmNone) and (FSortDir = sdDescend)) then
         result := -result;
    end
    else
    begin
      {$IFDEF USE_VARIANT}
      if (not VarIsEmpty(Item1.FSortData)) and (not VarIsEmpty(Item2.FSortData)) then
      {$ELSE}
      if (Item1.FSortType <> -1) and (Item2.FSortType <> -1) then
      {$ENDIF}
      begin
        {$IFDEF USE_VARIANT}
        if TVarData(Item1.FSortData).VType = TVarData(Item2.FSortData).VType then
        {$ELSE}
        if Item1.FSortType = Item2.FSortType then
        {$ENDIF}
        begin
          if ST = stText then
          begin
            {$IFDEF USE_VARIANT}
            result := AnsiCompareText(Item1.FSortData, Item2.FSortData);
            {$ELSE}
            result := AnsiStrIComp(PChar(Item1.FSortData), PChar(Item2.FSortData));
            {$ENDIF}
          end
          else
          if ST = stNumber then
          begin
            {$IFDEF USE_VARIANT}
            N1 := Item1.FSortData;
            N2 := Item2.FSortData;
            {$ELSE}
            N1 := Integer(Item1.FSortData);
            N2 := Integer(Item2.FSortData);
            {$ENDIF}
            if N1 > N2 then
               result := 1
            else
            if N1 < N2 then
               result := -1
            else
               result := 0;
          end
          else
          case ST of
            stFloating:
              begin
                {$IFDEF USE_VARIANT}
                F1 := Item1.FSortData;
                F2 := Item2.FSortData;
                {$ELSE}
                F1 := PDouble(Item1.FSortData)^;
                F2 := PDouble(Item2.FSortData)^;
                {$ENDIF}
                if F1 > F2 then
                   result := 1
                else
                if F1 < F2 then
                   result := -1
                else
                   result := 0;
              end;
            stCurrency:
              begin
                {$IFDEF USE_VARIANT}
                C1 := Item1.FSortData;
                C2 := Item2.FSortData;
                {$ELSE}
                C1 := PCurrency(Item1.FSortData)^;
                C2 := PCurrency(Item2.FSortData)^;
                {$ENDIF}
                if C1 > C2 then
                   result := 1
                else
                if C1 < C2 then
                   result := -1
                else
                   result := 0;
              end;
            stDateTime:
              begin
                {$IFDEF USE_VARIANT}
                T1 := Item1.FSortData;
                T2 := Item2.FSortData;
                {$ELSE}
                T1 := PDouble(Item1.FSortData)^;
                T2 := PDouble(Item2.FSortData)^;
                {$ENDIF}
                if T1 > T2 then
                   result := 1
                else
                if T1 < T2 then
                   result := -1
                else
                   result := 0;
              end;
            stDate:
              begin
                {$IFDEF USE_VARIANT}
                T1 := Item1.FSortData;
                T2 := Item2.FSortData;
                T1 := Trunc(T1);
                T2 := Trunc(T2);
                {$ELSE}
                T1 := PDouble(Item1.FSortData)^;
                T2 := PDouble(Item2.FSortData)^;
                T1 := Trunc(T1);
                T2 := Trunc(T2);
                {$ENDIF}

                if T1 > T2 then
                   result := 1
                else
                if T1 < T2 then
                   result := -1
                else
                   result := 0;
              end;
            stTime:
              begin
                {$IFDEF USE_VARIANT}
                T1 := Item1.FSortData;
                T2 := Item2.FSortData;
                T1 := Frac(T1);
                T2 := Frac(T2);
                {$ELSE}
                T1 := PDouble(Item1.FSortData)^;
                T2 := PDouble(Item2.FSortData)^;
                T1 := Frac(T1);
                T2 := Frac(T2);
                {$ENDIF}
                if T1 > T2 then
                   result := 1
                else
                if T1 < T2 then
                   result := -1
                else
                   result := 0;
              end;
            stBoolean:
              begin
               {$IFDEF USE_VARIANT}
                B1 := Item1.FSortData;
                B2 := Item2.FSortData;
                {$ELSE}
                B1 := Integer(Item1.FSortData) > 0;
                B2 := Integer(Item2.FSortData) > 0;
                {$ENDIF}
                if B1 = B2 then
                   result := 0
                else
                if B1 then
                   result := 1
                else
                   result := -1;
              end;
          end;
        end
        else
          // if items can't be compared, they are treated as equal
          result := 0;
      end
      else
      {$IFDEF USE_VARIANT}
      if (VarIsEmpty(Item1.FSortData)) then
      begin
        if (VarIsEmpty(Item2.FSortData)) then
      {$ELSE}
      if Item1.FSortType = -1 then
      begin
        if Item2.FSortType = -1 then
      {$ENDIF}
        begin
          result := 0;
        end
        else
        begin
          result := -1;
        end;
      end
      else
      {$IFDEF USE_VARIANT}
      if (VarIsEmpty(Item2.FSortData)) then
      {$ELSE}
      if Item2.FSortType = -1 then
      {$ENDIF}
        result := 1
      ;
      if (not (SM = hsmAscend)) then
          if (SM = hsmDescend) or ((SM = hsmNone) and (FSortDir = sdDescend)) then
              result := -result;
    end;
  end;
end;

procedure TCustomElTree.Update;
begin
  inherited;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
function TCustomElTree.IsEditing: boolean;
begin
  result := FView.FEditing;
end;
{$endif}

{$ifdef SUPPORT_STORAGE}
procedure TCustomElTree.SetStorage(newValue: TElIniFile);
begin
  if newValue <> FStorage then
  begin
    FStorage := newValue;
    if FStorage <> nil then
      FStorage.FreeNotification(Self);
  end;
end;
{$ENDIF}

function TCustomElTree.GetNodeAt(X, Y: integer): TElTreeItem; { public }
begin
  result := GetItemAtY(Y);
end; { GetNodeAt }

procedure TCustomElTree.SetShowCheckboxes(newValue: Boolean);
begin
  if (FShowCheckboxes <> newValue) then
  begin
    IsUpdating := true;
    FShowCheckboxes := newValue;
    with FView do
    begin
      if not FShowHeader then FView.FHRange := -1;
      FClearAll := true;
    end;
    FUpdated := true;
    IsUpdating := false;
  end; {if}
end; {SetShowCheckboxes}

procedure TCustomElTree.SetPlusPicture(newValue: TBitmap);
begin
  FPlusPicture.Assign(newValue);
end; {SetPlusPicture}

procedure TCustomElTree.SetMinusPicture(newValue: TBitmap);
begin
  FMinusPicture.Assign(newValue);
end; {SetMinusPicture}

procedure TCustomElTree.SetCustomPlusMinus(newValue: Boolean);
begin
  if (FCustomPlusMinus <> newValue) then
  begin
    IsUpdating := true;
    FCustomPlusMinus := newValue;
    with FView do
    begin
      if not FShowHeader then FView.FHRange := -1;
      FClearAll := true;
    end;
    FUpdated := true;
    IsUpdating := false;
  end; {if}
end; {SetCustomPlusMinus}

procedure TCustomElTree.SetSelectColumn(newValue: Integer);
begin
  if (FSelectColumn <> newValue) then
  begin
    if (newValue > -2) and (newValue < FHeader.Sections.Count) then
    begin
      FSelectColumn := newValue;
      if not FRowSelect then
      begin
        if not FMultiSelect then
        begin
          with FView do
            if (FFocused <> nil) then FFocused.UpdateItem;
        end else
        begin
          IsUpdating := true;
          FView.FClearAll := true;
          FUpdated := true;
          IsUpdating := false;
        end; // if/else
      end; //if
    end; // if
  end;
end; {SetSelectColumn}

procedure TCustomElTree.TriggerHeaderLookupEvent;
begin
  if (assigned(FOnHeaderLookup)) then FOnHeaderLookup(Self, Section, Text);
end; {TriggerHeaderLookupEvent}

procedure TCustomElTree.TriggerHeaderLookupDoneEvent;
begin
  if (assigned(FOnHeaderLookupDone)) then FOnHeaderLookupDone(Self, Section, Text, Accepted);
end; {TriggerHeaderLookupDoneEvent}

procedure TCustomElTree.TriggerHeaderSectionExpandEvent(Section:
  TElHeaderSection);
begin
  if (assigned(FOnHeaderSectionExpand)) then FOnHeaderSectionExpand(Self, Section);
end;

procedure TCustomElTree.TriggerHeaderSectionCollapseEvent(Section: TElHeaderSection);
begin
  if (assigned(FOnHeaderSectionCollapse)) then
    FOnHeaderSectionCollapse(Self, Section);
end;

procedure TCustomElTree.ScrollBarMouseDown;
begin
  if (not FView.Focused) and FView.CanFocus then
      FView.SetFocus;
end;

procedure TCustomElTree.SBChanged;
begin
  if (not FIgnoreSBChange) and (not (csLoading in ComponentState)) then
  begin
    AlignPieces;
    UpdateScrollBars;
  end;
end;

procedure TCustomElTree.Loaded;
var
  DT: TElDragType;
begin
  inherited;
  IsUpdating := true;
  FHeader.Loaded;
  if (FSortMode = smAdd) or (FSortMode = smAddClick) then
  begin
    TriggerSortBegin;
    FItems.FRoot.Sort(true);
    TriggerSortEnd;
  end;
  FUpdated := true;
  FView.FClearAll := true;
  DT := FDragType;
  FDragType := dtDelphi;
  DragType := DT;
  FontChanged(Font);

  if FHeader.Height <> FHeaderHeight then
  begin
    FHeader.Height := FHeaderHeight;
    AlignPieces;
    {$IFNDEF LITE}
    if not (BackgroundType in [bgtColorFill, bgtCenterBitmap]) then FView.RedoTmpBmp;
    {$ENDIF}
  end;
  FHScrollBar.Loaded;
  FVScrollBar.Loaded;
  AutoSizeAllColumns;
  IsUpdating := false;
end;

procedure TCustomElTree.SetDragType(newValue: TElDragType);
begin
  if (FDragType <> newValue) then
  begin
{$IFNDEF VER90}
    if newValue = dtDelphi then
{$ifdef ELTREE_USE_OLE_DRAGDROP}
{$IFNDEF LITE}
    begin
      FDropTarget.Free;
      FDropTarget := nil;
    end
{$ENDIF}
{$endif}
    else
    begin
      if (FDragType = dtDelphi) and (FView.Handle <> 0) and (not (csLoading in ComponentState)) then // when switching from one to another OLE mode we don't create a drop target
      begin
{$ifdef ELTREE_USE_OLE_DRAGDROP}
{$IFNDEF LITE}
        FDropTarget := TElDropTarget.Create(nil);
        FDropTarget.Target := FView;
        FDropTarget.OnTargetDrag := FView.OnDropTargetDrag;
        FDropTarget.OnTargetDrop := FView.OnDropTargetDrop;
{$ENDIF}
{$endif}
      end;
    end;
{$ENDIF}
    FDragType := newValue;
  end; {if}
end; {SetDragType}

{$ifdef ELTREE_USE_OLE_DRAGDROP}
{$IFNDEF VER90}
{$IFNDEF LITE}
procedure TCustomElTree.TriggerOleTargetDragEvent;
begin
  Y := Y + FView.Top;
  X := X + FView.Left;
  if (assigned(FOnOleTargetDrag)) then
    FOnOleTargetDrag(Self, State, Source, Shift, X, Y, DragType);
end; {TriggerOleTargetDragEvent}

procedure TCustomElTree.TriggerOleTargetDropEvent;
begin
  Y := Y + FView.Top;
  X := X + FView.Left;
  if (assigned(FOnOleTargetDrop)) then
    FOnOleTargetDrop(Self, Source, Shift, X, Y, DragType);
end; {TriggerOleTargetDropEvent}

procedure TCustomElTree.TriggerOleDragStartEvent;
begin
  if (assigned(FOnOleDragStart)) then
    FOnOleDragStart(Self, dataObj, dropSource, dwOKEffects);
end; {TriggerOleDragStartEvent}

procedure TCustomElTree.TriggerOleDragFinishEvent;
begin
  if (assigned(FOnOleDragFinish)) then FOnOleDragFinish(Self, dwEffect, Result);
end; {TriggerOleDragFinishEvent}
{$ENDIF}
{$ENDIF}
{$endif}

procedure TCustomElTree.HeaderResizeTransfer(Sender: TObject);
begin
  if (assigned(FOnHeaderResize)) then
    FOnHeaderResize(Self);
end;

procedure TCustomElTree.HeaderResizeHandler(Sender: TObject);
begin
  DoHeaderResize(Sender);
  HeaderResizeTransfer(Self);
end;

function TCustomElTree.IsInView(Item: TElTreeItem): Boolean;
begin
  result := FView.FVisible.IndexOf(Item) <> -1;
end;

function TCustomElTree.SectionTypeToSortType(SectionType: TFieldTypes):
  TSortTypes;
begin
  case SectionType of
    sftText: result := stText;
    sftNumber: result := stNumber;
    sftFloating: result := stFloating;
    sftDateTime: result := stDateTime;
    sftDate: result := stDate;
    sftTime: result := stTime;
    sftBool: result := stBoolean;
    sftCurrency: result := stCurrency;
  else
    result := stCustom;
  end;
end;

function TCustomElTree.GetStickyHeaderSections: Boolean;
begin
  result := FHeader.StickySections;
end; {GetStickyHeaderSections}

procedure TCustomElTree.SetStickyHeaderSections(newValue: Boolean);
begin
  FHeader.StickySections := newValue;
end; {SetStickyHeaderSections}

procedure TCustomElTree.SetBarStyle(newValue: Boolean);
begin
  if (FBarStyle <> newValue) then
  begin
    IsUpdating := true;
    FBarStyle := newValue;
    if FBarStyle then
    begin
      BkColor := clBtnFace;
      TextColor := clBtnText;
      LinesColor := clBtnShadow;
    end;
    if FAutoLineHeight then FLineHeight := DefineLineHeight;
    with FView do
    begin
      if not FShowHeader then FHRange := -1;
      FClearAll := true;
    end;
    FUpdated := true;
    IsUpdating := false;
  end; {if}
end; {SetBarStyle}

procedure TCustomElTree.SetDrawFocusRect(newValue: Boolean);
begin
  if (FDrawFocusRect <> newValue) then
  begin
    FDrawFocusRect := newValue;
    if ItemFocused <> nil then ItemFocused.RedrawItem(true);
  end; {if}
end; {SetDrawFocusRect}

procedure TCustomElTree.TriggerMeasureItemPartEvent(Item: TElTreeItem; PartIndex: integer; var Size: TPoint);
begin
  if (assigned(FOnMeasureItemPart)) then
    FOnMeasureItemPart(Self, Item, PartIndex, Size);
end; {TriggerMeasureItemPartEvent}

procedure TCustomElTree.SetDivLinesColor(newValue: TColor);
begin
  if (FDivLinesColor <> newValue) then
  begin
    IsUpdating := true;
    FDivLinesColor := newValue;
    if FHLines or FVLines then
    begin
      FView.FClearAll := true;
      FUpdated := true;
    end;
    IsUpdating := false;
  end; {if}
end; {SetLinesColor}

procedure TCustomElTree.SetLinesColor(newValue: TColor);
begin
  if (FLinesColor <> newValue) then
  begin
    IsUpdating := true;
    FLinesColor := newValue;
    if FShowLines then
    begin
      FView.FClearAll := true;
      FUpdated := true;
    end;
    IsUpdating := false;
  end; {if}
end; {SetLinesColor}

procedure TCustomElTree.SetLinesStyle(newValue: TPenStyle);
begin
  if (FLinesStyle <> newValue) then
  begin
    IsUpdating := true;
    FLinesStyle := newValue;
    if FShowLines then
    begin
      FView.FClearAll := true;
      FUpdated := true;
    end;
    IsUpdating := false;
  end; {if}
end; {SetLinesStyle}

procedure TCustomElTree.SetImages2(newValue: TImageList);
var
  i: integer;
begin
  if FImages2 = newValue then exit;
  IsUpdating := true;
  if FImages2 <> nil then FImages2.UnRegisterChanges(FImageChangeLink);
  FImages2 := newValue;
  if FImages2 <> nil then
  begin
    FImages2.RegisterChanges(FImageChangeLink);
    FImages2.FreeNotification(Self);
  end;
  if csDestroying in ComponentState then exit;
  i := DefineLineHeight;
  if FAutoLineHeight and (i <> FLineHeight) then
  begin
    FLineHeight := i;
    with FView do
    begin
      FClearVis := true;
      FClearAll := true;
    end;
  end;
  if not FShowHeader then
  begin
    with FView do
    begin
      FHRange := -1;
      DefineHRange;
    end;
    if RightAlignedTree then
    begin
      FRightAlignedTree := false;
      RightAlignedTree := true;
    end;
  end;
  FView.FRangeUpdate := true;
  FUpdated := true;
  IsUpdating := false;
end;

procedure TCustomElTree.SetRightAlignedTree(newValue: Boolean);
begin
  if (FRightAlignedTree <> newValue) then
  begin
    FRightAlignedTree := newValue;
    FHeader.RightAlignedOrder := newValue;
    if not FShowHeader then
    begin
      with FView do
      begin
        if FHRange = -1 then DefineHRange;
        if newValue then SetHPosition(FHRange - FHPos) else SetHPosition(0);
      end;
    end;
    FView.Invalidate;//Repaint;
  end; {if}
end;

procedure TCustomElTree.SetFlat(newValue: Boolean);
begin
  if (FFlat <> newValue) then
  begin
    FFlat := newValue;
    UpdateFrame;
  end; { if }
end; { SetFlat }

procedure TCustomElTree.DrawFlatBorder(HorzTracking, VertTracking : boolean);
var
  DC : HDC;
  R  : TRect;
  b  : boolean;
  BS : TElFlatBorderType;

const ScrollBars: array [boolean, boolean] of TScrollStyle = ((ssNone, ssVertical), (ssHorizontal, ssBoth));
begin
  R := Rect(0, 0, Width, Height);
  DC := GetWindowDC(Handle);
  try
    if (BorderStyle = bsSingle) then
    begin
      b := Focused or FMouseOver;
      if b then BS := FActiveBorderType else BS := FInactiveBorderType;
      if ((not FFlat) and FUseCustomBars) then
         BS := fbtSunken;
      if bs = fbtRaised then bs := fbtRaisedOuter;
      DrawFlatFrameEx2(DC, R, BkColor, b, Enabled, BS);
    end;
    if not FUseCustomBars then
       DrawFlatScrollBars(Handle, DC, R, (Focused or FMouseOver) and (not FlatFocusedScrollBars), ScrollBars[FHScrollVisible, FVScrollVisible], HorzTracking, VertTracking, false);
  finally
    ReleaseDC(Handle, DC);
  end;
end;

procedure TCustomElTree.DrawFlatBorderEx(DC : HDC; HorzTracking, VertTracking : boolean);
var
  R  : TRect;
  b  : boolean;
  BS : TElFlatBorderType;

const ScrollBars: array [boolean, boolean] of TScrollStyle = ((ssNone, ssVertical), (ssHorizontal, ssBoth));
begin
  R := Rect(0, 0, Width, Height);

  if (BorderStyle = bsSingle) then
  begin
    b := Focused or FMouseOver;
    if b then BS := FActiveBorderType else BS := FInactiveBorderType;
    if ((not FFlat) and FUseCustomBars) then
       BS := fbtSunken;
    if bs = fbtRaised then bs := fbtRaisedOuter;
    DrawFlatFrameEx2(DC, R, BkColor, b, Enabled, BS);
  end;
  if not FUseCustomBars then
     DrawFlatScrollBars(Handle, DC, R, (Focused or FMouseOver) and (not FlatFocusedScrollBars), ScrollBars[FHScrollVisible, FVScrollVisible], HorzTracking, VertTracking, false);
end;

procedure TCustomElTree.WMNCCalcSize(var Message : TWMNCCalcSize);
begin
  inherited;
  if not FUseCustomBars then exit;
  Inc(Message.CalcSize_Params.rgrc[0].Bottom, GetSystemMetrics(SM_CYVTHUMB));
  if RightAlignedText then
     Dec(Message.CalcSize_Params.rgrc[0].Left, GetSystemMetrics(SM_CXHTHUMB))
  else
     Inc(Message.CalcSize_Params.rgrc[0].Right, GetSystemMetrics(SM_CXHTHUMB));
end;

procedure TCustomElTree.WMNCHITTEST(var Msg : TMessage);  { private }
begin
  inherited;
  if FUseCustomBars then
  begin
    if (Msg.Result = HTHSCROLL) or (Msg.Result = HTVSCROLL) then
        Msg.Result := HTBORDER;
  end;
end;  { WMNCHITTEST }

procedure TCustomElTree.WMNCPaint(var Msg: TMessage); { private }
var DC : HDC;
begin
  if not FUseCustomBars then
     inherited;
  if Flat or FUseCustomBars then
  begin
    DC := GetDCEx(Handle, Msg.wParam, DCX_WINDOW or DCX_INTERSECTRGN);
    if DC <> 0 then
       DrawFlatBorderEx(DC, false, false)
    else
    begin
      DC := GetWindowDC(Handle);
      DrawFlatBorderEx(DC, false, false);
    end;

    ReleaseDC(Handle, DC);
    Msg.Result := 0;
  end;
end; { WMNCPaint }


procedure TCustomElTree.WMMouseMove(var Message: TWMMouseMove);
begin
  inherited;
  FView.MouseMove(KeysToShiftState(Message.Keys),Message.XPos - FView.Left, Message.YPos - FView.Top);
end;

procedure TCustomElTree.SetRightAlignedText(newValue: Boolean);
begin
  if (FRightAlignedText <> newValue) then
  begin
    FRightAlignedText := newValue;
    FHeader.RightAlignedText := newValue;
    RecreateWnd;
  end; {if}
end;

procedure TCustomElTree.SetForcedScrollBars(newValue : TScrollStyle);
begin
  if (FForcedScrollBars <> newValue) then
  begin
    FForcedScrollBars := newValue;
    if HandleAllocated then
    begin
      if (not FUseCustomBars) then
         RecreateWnd;
      IsUpdating := true;
      FUpdated   := true;
      IsUpdating := false;
    end;
  end;  { if }
end;  { SetForcedScrollBars }

procedure TCustomElTree.SetFilteredVisibility(newValue: Boolean);
begin
  if (FFilteredVisibility <> newValue) then
  begin
    IsUpdating := true;
    FFilteredVisibility := newValue;
    with FView do
    begin
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
      if not FShowHeader then FHRange := -1;
      FRangeUpdate := true;
    end;
    FUpdated := true;
    IsUpdating := false;
  end; {if}
end;

procedure TCustomElTree.TriggerApplyVisFilterEvent(Item: TElTreeItem; var
  Hidden: boolean);
begin
  if (assigned(FOnApplyVisFilter)) then
    FOnApplyVisFilter(Self, Item, Hidden);
end;

procedure TCustomElTree.SetHPosition(value: integer);
begin
  FView.SetHPosition(value);
end;

procedure TCustomElTree.SetVPosition(value: integer);
begin
  FView.SetVPosition(value);
end;

procedure TCustomElTree.ClickTransfer(Sender : TObject);
{ Transfers FView OnClick event to the outside world. }
begin
  if (assigned(FOnClick)) then FOnClick(Self);  { Substitute Self for subcomponent's Sender. }
end;  { ClickTransfer }

procedure TCustomElTree.DblClickTransfer(Sender : TObject);
{ Transfers FView OnDblClick event to the outside world. }
begin
  if (assigned(FOnDblClick)) then FOnDblClick(Self);
end;  { DblClickTransfer }
(*
procedure TCustomElTree.EndDragTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer);
begin
  y := Y + FView.Top;
  X := X + FView.Left;
  if Source = FView then Source := Self
  else
  if Source is TElTreeDragObject then Source := TElTreeDragObject(Source).Control;
  if (assigned(FOnDrop)) then
    FOnDrop(Self, Source , X , Y );  { Substitute Self for subcomponent's Sender. }
end;
*)
procedure TCustomElTree.DropTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer);
{ Transfers FView OnDragDrop event to the outside world. }
begin
  y := Y + FView.Top;
  X := X + FView.Left;
  {if Source is TElTreeDragObject then
     Sender := Source
  else
     }Sender := Self;
  if Source = FView then
     Source := Self
  else
  if Source is TElTreeDragObject then
     Source := TElTreeDragObject(Source).Control;
  if (assigned(FOnDrop)) then
     FOnDrop(Sender, Source , X , Y );  { Substitute Self for subcomponent's Sender. }
end;  { DropTransfer }

procedure TCustomElTree.OverTransfer(Sender : TObject; Source : TObject; X : Integer; Y : Integer; State : TDragState; var Accept : Boolean);
{ Transfers FView OnDragOver event to the outside world. }
begin
  Accept := false;
  y := Y + FView.Top;
  X := X + FView.Left;
  {if Source is TElTreeDragObject then
     Sender := Source
  else}
     Sender := Self;
  if Source = FView then
     Source := Self
  else
  if Source is TElTreeDragObject then
     Source := TElTreeDragObject(Source).Control;
  if (assigned(FOnOver)) then
     FOnOver(Sender, Source , X , Y , State , Accept );  { Substitute Self for subcomponent's Sender. }
end;  { OverTransfer }

procedure TCustomElTree.DragTransfer(Sender : TObject; Target : TObject; X : Integer; Y : Integer);
{ Transfers FView OnEndDrag event to the outside world. }
begin
  y := Y + FView.Top;
  X := X + FView.Left;
  {if Target is TElTreeDragObject then
     Sender := Target
  else
     }Sender := Self;
  if Target = FView then Target := Self;
  if (assigned(FOnDrag)) then
    FOnDrag(Sender, Target , X , Y );  { Substitute Self for subcomponent's Sender. }
end;  { DragTransfer }

procedure TCustomElTree.EnterTransfer(Sender : TObject);
{ Transfers FView OnEnter event to the outside world. }
begin
  if (assigned(FOnEnter)) then
    FOnEnter(Self);  { Substitute Self for subcomponent's Sender. }
end;  { EnterTransfer }

procedure TCustomElTree.ExitTransfer(Sender : TObject);
{ Transfers FView OnExit event to the outside world. }
begin
  if (assigned(FOnExit)) then
    FOnExit(Self);  { Substitute Self for subcomponent's Sender. }
end;  { ExitTransfer }

procedure TCustomElTree.KeyDownTransfer(Sender : TObject; var Key : Word; Shift : TShiftState);
{ Transfers FView OnKeyDown event to the outside world. }
begin
  if (assigned(FOnKeyDown)) then
    FOnKeyDown(Self, Key , Shift );  { Substitute Self for subcomponent's Sender. }
end;  { KeyDownTransfer }

procedure TCustomElTree.KeyPressTransfer(Sender : TObject; var Key : Char);
{ Transfers FView OnKeyPress event to the outside world. }
begin
  if (assigned(FOnKeyPress)) then
    FOnKeyPress(Self, Key );  { Substitute Self for subcomponent's Sender. }
end;  { KeyPressTransfer }

procedure TCustomElTree.KeyUpTransfer(Sender : TObject; var Key : Word; Shift : TShiftState);
{ Transfers FView OnKeyUp event to the outside world. }
begin
  if (assigned(FOnKeyUp)) then
    FOnKeyUp(Self, Key , Shift );  { Substitute Self for subcomponent's Sender. }
end;  { KeyUpTransfer }

procedure TCustomElTree.MouseDownTransfer(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X : Integer; Y : Integer);
{ Transfers FView OnMouseDown event to the outside world. }
begin
  y := Y + FView.Top;
  X := X + FView.Left;
  if (assigned(FOnMouseDown)) then
    FOnMouseDown(Self, Button , Shift , X , Y );  { Substitute Self for subcomponent's Sender. }
end;  { MouseDownTransfer }

procedure TCustomElTree.MouseMoveTransfer(Sender : TObject; Shift : TShiftState; X : Integer; Y : Integer);
{ Transfers FView OnMouseMove event to the outside world. }
begin
  Y := Y + FView.Top;
  X := X + FView.Left;
  if (assigned(FOnMouseMove)) then
    FOnMouseMove(Self, Shift , X , Y );  { Substitute Self for subcomponent's Sender. }
end;  { MouseMoveTransfer }

procedure TCustomElTree.MouseUpTransfer(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X : Integer; Y : Integer);
{ Transfers FView OnMouseUp event to the outside world. }
begin
  Y := Y + FView.Top;
  X := X + FView.Left;
  if (assigned(FOnMouseUp)) then
    FOnMouseUp(Self, Button , Shift , X , Y );  { Substitute Self for subcomponent's Sender. }
end;  { MouseUpTransfer }

procedure TCustomElTree.StartDragTransfer(Sender : TObject; var DragObject : TDragObject);
{ Transfers FView OnStartDrag event to the outside world. }
begin
{$IFDEF VCL_4_USED}  
  if DragObject <> nil then
  with DragObject.DragPos do
  begin
    y := Y + FView.Top;
    X := X + FView.Left;
  end;
{$ENDIF VCL_4_USED}
  if (assigned(FOnStartDrag)) then
    FOnStartDrag(Self, DragObject );  { Substitute Self for subcomponent's Sender. }
{$IFDEF VCL_4_USED}
  if DragObject <> nil then
  with DragObject.DragPos do
  begin
    y := Y - FView.Top;
    X := X - FView.Left;
  end;
{$ENDIF VCL_4_USED}
  if DragObject = nil then
  begin
    DragObject := TElTreeDragObject.Create(Self);
  end;
end;  { StartDragTransfer }

procedure TCustomElTree.MeasureSectionTransfer(Sender : TObject; Section : TElHeaderSection; var Size: TPoint);
begin
  if Assigned(FOnHeaderSectionMeasure) then FOnHeaderSectionMeasure(Self, Section, Size);
end;

function TCustomElTree.CreateView : TElTreeView;  { protected }
begin
  result := TElTreeView.Create(Self);
end;  { CreateView }

{ Exposed properties' Read/Write methods: }
procedure TCustomElTree.SetCursor(newValue : TCursor);
begin
  FView.Cursor := newValue;
end;  { SetCursor }

function TCustomElTree.GetCursor : TCursor;
{ Returns the Cursor property from the FView subcomponent. }
begin
  GetCursor := FView.Cursor;
end;  { GetCursor }

function TCustomElTree.SetScrollInfo(hWnd: HWND; BarFlag: Integer; const ScrollInfo: TScrollInfo; Redraw: BOOL): Integer;
begin
  if (hWnd = FHScrollBar.Handle) or (hWnd = FVScrollBar.Handle) then
  begin
    result := SendMessage(hWnd, SBM_SetScrollInfo, Integer(Redraw), Integer(@ScrollInfo));
  end else result := -1;
end;

function TCustomElTree.GetScrollInfo(hWnd: HWND; BarFlag: Integer; var ScrollInfo: TScrollInfo): BOOL;
begin
  if (hWnd = FHScrollBar.Handle) or (hWnd = FVScrollBar.Handle) then
  begin
    SendMessage(hWnd, SBM_GetScrollInfo, 0, Integer(@ScrollInfo));
    result := BOOL(true);
  end else result := BOOL(false);
end;

procedure TCustomElTree.HorzScrollDrawPartTransfer(Sender : TObject;
                                                   Canvas : TCanvas;
                                                   R : TRect;
                                                   Part : TElScrollBarPart;
                                                   Enabled : Boolean;
                                                   Focused : Boolean;
                                                   Pressed : Boolean;
                                                   var DefaultDraw : Boolean);
{ Transfers FHScrollBar OnDrawPart event to the outside world. }
begin
  if (assigned(FOnHorzScrollDrawPart)) then
    FOnHorzScrollDrawPart(Self, Canvas , R , Part , Enabled , Focused , Pressed , DefaultDraw );  { Substitute Self for subcomponent's Sender. }
end;  { HorzScrollDrawPartTransfer }

procedure TCustomElTree.HorzScrollHintNeededTransfer(Sender : TObject; TrackPosition : Integer; var Hint : String);
{ Transfers FHScrollBar OnScrollHintNeeded event to the outside world. }
begin
  if (assigned(FOnHorzScrollHintNeeded)) then
    FOnHorzScrollHintNeeded(Self, TrackPosition , Hint );  { Substitute Self for subcomponent's Sender. }
end;  { HorzScrollHintNeededTransfer }

procedure TCustomElTree.VertScrollDrawPartTransfer(Sender : TObject; Canvas : TCanvas;
                                                   R : TRect;
                                                   Part : TElScrollBarPart;
                                                   Enabled : Boolean;
                                                   Focused : Boolean;
                                                   Pressed : Boolean;
                                                   var DefaultDraw : Boolean);
{ Transfers FVScrollBar OnDrawPart event to the outside world. }
begin
  if (assigned(FOnVertScrollDrawPart)) then
    FOnVertScrollDrawPart(Self, Canvas , R , Part , Enabled , Focused , Pressed , DefaultDraw );  { Substitute Self for subcomponent's Sender. }
end;  { VertScrollDrawPartTransfer }

procedure TCustomElTree.VertScrollHintNeededHandler(Sender : TObject; TrackPosition : Integer; var Hint : String);
var Item : TElTreeItem;
    FCol : integer;

begin
  VertScrollHintNeededTransfer(Self, TrackPosition, Hint);
  if Hint = '' then
  begin
    if FSortSection = -1 then exit;
    Item := Items.ItemAsVis[TrackPosition];
    if Item = nil then exit;
    if FSortSection = FMainTreeCol then Hint := Item.Text else
    begin
      FCol := FSortSection;
      if FSortSection > FMainTreeCol then dec(FCol);
      try
        if FCol < Item.FColText.Count then Hint := Item.FColText[FCol];
      except
      end;
    end;
  end;
end;  { VertScrollHintNeededHandler }

procedure TCustomElTree.VertScrollHintNeededTransfer(Sender : TObject; TrackPosition : Integer; var Hint : String);
{ Transfers FHScrollBar OnScrollHintNeeded event to the outside world. }
begin
  if (assigned(FOnVertScrollHintNeeded)) then
    FOnVertScrollHintNeeded(Self, TrackPosition , Hint );  { Substitute Self for subcomponent's Sender. }
end;  { HorzScrollHintNeededTransfer }

type TElScrollBarHack = class(TElScrollBar)
public
  property IsDesigning;
end;

procedure TCustomElTree.CreateWnd;  { protected }
begin
  inherited;
  TElScrollBarHack(FHScrollBar).SetDesigning(false);
  TElScrollBarHack(FVScrollBar).SetDesigning(false);
  //FHScrollBar.ControlStyle := FHScrollBar.ControlStyle + [csNoDesignVisible];
  //FVScrollBar.ControlStyle := FVScrollBar.ControlStyle + [csNoDesignVisible];
  TElHeaderHack(FHeader).IsDesigning := false;
  FView.SetDesigning(csDesigning in ComponentState);
  AlignPieces;
end;  { CreateWnd }

procedure TCustomElTree.AlignControls(AControl: TControl; var Rect: TRect);
begin
  if not (csDesigning in ComponentState) then
     inherited;
end;

function TCustomElTree.GetHeaderInvertSortArrows : Boolean;
{ Returns the value of data member FHeaderInvertSortArrows. }
begin
  result := FHeader.InvertSortArrows;
end;  { GetHeaderInvertSortArrows }

procedure TCustomElTree.SetHeaderInvertSortArrows(newValue : Boolean);
{ Sets data member FHeaderInvertSortArrows to newValue. }
begin
  FHeader.InvertSortArrows := newValue;
end;  { SetHeaderInvertSortArrows }

{$IFDEF VCL_4_USED}
function TCustomElTree.GetDragImages: TDragImageList;
{$ELSE}
function TCustomElTree.GetDragImages: TCustomImageList;
{$ENDIF}
begin
  result := FView.GetDragImages;
end;

{$IFNDEF LITE}
function TCustomElTree.GetLockedHeaderSection : TElHeaderSection;
{ Returns the value of data member FLockedHeaderSection. }
begin
  result := FHeader.LockedSection;
end;  { GetLockedHeaderSection }

procedure TCustomElTree.SetLockedHeaderSection(newValue : TElHeaderSection);
{ Sets data member FLockedHeaderSection to newValue. }
begin
  FHeader.LockedSection := newValue;
end;  { SetLockedHeaderSection }
{$ENDIF LITE}
{$IFDEF VCL_4_USED}
procedure TCustomElTree.ActionChange(Sender : TObject; CheckDefaults : Boolean);
begin
  inherited;
end;
{$ENDIF}

procedure TCustomElTree.SetAutoExpand(value: boolean);
begin
  if AutoExpand <> value then
  begin
    FAutoExpand := value;
    if value then FMoveFocusOnCollapse := false;
  end;
end;

procedure TCustomElTree.SetMoveFocusOnCollapse(value: boolean);
begin
  if FMoveFocusOnCollapse <> value then
  begin
    FMoveFocusOnCollapse := value;
    if value then AutoExpand := false;
  end;
end;

function TCustomElTree.GetDragCursor : TCursor;
begin
  result := FView.DragCursor;
end;

procedure TCustomElTree.SetDragCursor(Value : TCursor);
begin
  FView.DragCursor := Value;
end;

procedure TCustomElTree.SetTrackColor(value : TColor);
begin
  if FTrackColor <> Value then
  begin
    FTrackColor := Value;
    if Assigned(FView.FTrackItem) then
       FView.FTrackItem.RedrawItem(true);
  end;
end;

procedure TCustomElTree.SetTransButtons(newValue : boolean);
begin
  if newValue <> FTransButtons then
  begin
    FTransButtons := newValue;
    if FShowButtons then
    begin
      IsUpdating := true;
      FUpdated := true;
      FView.FRangeUpdate := true;
      IsUpdating := false;
    end;
  end;
end;

procedure TCustomElTree.SetHeaderColor(newValue : TColor);
{ Sets the FHeader subcomponent's Color property to newValue. }
begin
  FHeader.Color := newValue;
end;  { SetColor }

function TCustomElTree.GetHeaderColor : TColor;
{ Returns the Color property from the FHeader subcomponent. }
begin
  result := FHeader.Color;
end;  { GetColor }

{$IFNDEF LITE}
procedure TCustomElTree.SetAdjustMultilineHeight(newValue : Boolean);
var i, j : integer;
begin
  if (FAdjustMultilineHeight <> newValue) then
  begin
    FAdjustMultilineHeight := newValue;
    j := FAllList.Count - 1;
    for i := 0 to j do
    begin
      if TElTreeItem(FAllList[i]).Multiline then
      begin
        if newValue then
           inc(TotalVarHeightCount)
        else
           dec(TotalVarHeightCount);
      end;
    end;
    IsUpdating := true;
    with FView do
    begin
      FVisUpdated := true;
      FClearVis := true;
      FClearAll := true;
      FRangeUpdate := true;
    end;
    FUpdated := true;
    IsUpdating := false;
  end;  { if }
end;  { SetAdjustMultilineHeight }
{$ENDIF}

{$IFDEF HAS_HTML_RENDER}
procedure TCustomElTree.TriggerImageNeededEvent(Sender : TObject; Src : string; var Image : TBitmap);
begin
  if (assigned(FOnImageNeeded)) then
    FOnImageNeeded(Self, Src , Image );
end;
{$ENDIF}

{$WARNINGS OFF}
procedure TCustomElTree.WMVScroll(var Msg : TWMVScroll);  { private }
var b : boolean;
    sc: TElscrollCode;
    sp: integer;
begin
  b := false;
  case Msg.ScrollCode of
    SB_TOP:       sc := escTop;
    SB_BOTTOM:    sc := escBottom;
    SB_ENDSCROLL: sc := escEndScroll;
    SB_LINEDOWN:  sc := escLineDown;
    SB_LINEUP:    sc := escLineUp;
    SB_PAGEDOWN:  sc := escPageDown;
    SB_PAGEUP:    sc := escPageUp;
    SB_THUMBPOSITION: sc := escPosition;
    SB_THUMBTRACK: sc := escTrack;
  end;
  sp := Msg.Pos;
  FView.OnVScroll(FVScrollBar, SC, sp, b);
end;  { WMVScroll }

procedure TCustomElTree.WMHScroll(var Msg : TWMHScroll);  { private }
var b : boolean;
    sc: TElscrollCode;
    sp: integer;
begin
  b := false;
  case Msg.ScrollCode of
    SB_TOP:       sc := escTop;
    SB_BOTTOM:    sc := escBottom;
    SB_ENDSCROLL: sc := escEndScroll;
    SB_LINEDOWN:  sc := escLineDown;
    SB_LINEUP:    sc := escLineUp;
    SB_PAGEDOWN:  sc := escPageDown;
    SB_PAGEUP:    sc := escPageUp;
    SB_THUMBPOSITION: sc := escPosition;
    SB_THUMBTRACK: sc := escTrack;
  end;
  sp := Msg.Pos;
  FView.OnHScroll(FHScrollBar, SC, sp, b);
end;  { WMHScroll }
{$WARNINGS ON}

procedure TCustomElTree.TriggerSortBegin;
begin
  if Assigned(FOnSortBegin) then FOnSortBegin(Self);
end;

procedure TCustomElTree.TriggerSortEnd;
begin
  if Assigned(FOnSortEnd) then FOnSortEnd(Self);
end;

procedure TCustomElTree.TriggerItemPostDrawEvent(Canvas : TCanvas; Item : TElTreeItem; ItemRect : TRect; var DrawFocusRect : boolean);
begin
  if (assigned(FOnItemPostDraw)) then
    FOnItemPostDraw(Self, Canvas , Item, ItemRect , DrawFocusRect );
end;  { TriggerItemPostDrawEvent }
{$IFDEF ELPACK_COMPLETE}
procedure TCustomElTree.SetHeaderImageForm(newValue : TElImageForm);
begin
  FHeader.ImageForm := newValue;
end;  { SetImageForm }

function TCustomElTree.GetHeaderImageForm : TElImageForm;
begin
  result := FHeader.ImageForm;
end;  { GetImageForm }
{$ENDIF}

function TCustomElTree.GetHint : string;
begin
  result := FHint;
end;

procedure TCustomElTree.SetHint(newValue : string);
begin
  FHint := newValue;
  FRealHint := newValue;
end;

procedure TCustomElTree.StartDelayedFocus(FocusItemToReport : TElTreeItem);
begin
  FDelayTimer.Enabled := false;
  FDelayedItem := FocusItemToReport;
  FDelayTimer.Interval := FChangeDelay;
  FDelayTimer.Enabled := true;
end;

procedure TCustomElTree.StopDelayedFocus;
begin
  FDelayTimer.Enabled := false;
  FDelayedItem := nil;
end;

procedure TCustomElTree.OnDelayTimer(Sender : TObject);
begin
  FDelayTimer.Enabled := false;
  if FDelayedItem = FView.FFocused then
    DoItemFocused;
end;

procedure TCustomElTree.DoAfterSelectionChange;
begin
  if Assigned(FOnAfterSelectionChange) then
    FOnAfterSelectionChange(Self);
end;

procedure TCustomElTree.SetDragRectAcceptColor(const Value: TColor);
begin
  if FDragRectAcceptColor <> Value then
  begin
    FDragRectAcceptColor := Value;
    if (FDragTrgDrawMode in [ColorFrame, ColorRect, dtdUpColorLine, dtdDownColorLine]) and (FView.FDropTrg <> nil) then
    begin
      if FDragObject <> nil then
        FDragObject.HideDragImage;
      FView.FDropTrg.RedrawItem(false);
      Update;
      if FDragObject <> nil then
        FDragObject.ShowDragImage;
    end;
  end;
end;

procedure TCustomElTree.SetDragRectDenyColor(Value: TColor);
begin
  if FDragRectDenyColor <> Value then
  begin
    FDragRectDenyColor := Value;
    if (FDragTrgDrawMode in [ColorFrame, ColorRect, dtdUpColorLine, dtdDownColorLine]) and (FView.FDropTrg <> nil) then
    begin
      if FDragObject <> nil then
        FDragObject.HideDragImage;
      FView.FDropTrg.RedrawItem(false);
      Update;
      if FDragObject <> nil then
        FDragObject.ShowDragImage;
    end;
  end;
end;

procedure TCustomElTree.SetDragTrgDrawMode(Value: TDragTargetDraw);
begin
  if FDragTrgDrawMode <> Value then
  begin
    DoSetDragTrgDrawMode(Value, True);
  end;
end;

function TCustomElTree.GetVisibleRowCount: Integer;
begin
  Result := FView.GetVisCount2;
end;

function TCustomElTree.IndexInView(Item : TElTreeItem): Integer;
begin
  Result := FView.FVisible.IndexOf(Item);
end;

function TCustomElTree.GetDropTarget: TElTreeItem;
begin
  Result := FView.FDropTrg;
end;

procedure TCustomElTree.DoSetDragTrgDrawMode(Value: TDragTargetDraw; RedrawItem 
    : boolean);
begin
  if FDragTrgDrawMode <> Value then
  begin
    FDragTrgDrawMode := Value;
    if (FView.FDropTrg <> nil) and (RedrawItem) then
    begin
      if FDragObject <> nil then
        FDragObject.HideDragImage;
      FView.FDropTrg.RedrawItem(false);
      Update;
      if FDragObject <> nil then
        FDragObject.ShowDragImage;
    end;
  end;
end;

procedure TCustomElTree.AllSelectedEx(SelectedItems : TElList; Order : boolean);
var i : integer;
    Item : TElTreeItem;
begin
  if FSelectedList = nil then
    exit;

  if not Order then
  begin
    SelectedItems.Assign(FSelectedList);
  end
  else
  begin
    SelectedItems.Capacity := FSelectedList.Capacity;
    for i := 0 to FAllList.Count - 1 do
    begin
      Item := TElTreeItem(FAllList.FastGet(i));
      if Item.Selected then
        SelectedItems.Add(Item);
    end;
  end;
end;

{$ifdef ELTREE_USE_INPLACE_EDITORS}
procedure TCustomElTree.NotifyOnEditKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnEditKeyDown) then FOnEditKeyDown(Sender,Key,Shift);
end;
{$endif}

function TCustomElTree.GetFireFocusEvents: boolean;
begin
  Result := (FFireFocusEvents = 0) and not (csDestroying in ComponentState);
end;

procedure TCustomElTree.SetFireFocusEvents(Value: boolean);
begin
  if Value then
    dec(FFireFocusEvents)
  else
    inc(FFireFocusEvents);
end;

procedure TCustomElTree.SetScrollbarOpposite(Value: Boolean);
begin
  if FScrollbarOpposite <> Value then
  begin
    FScrollbarOpposite := Value;
    if FUseCustomBars then
      AlignPieces; 
  end;
end;

procedure TCustomElTree.SetLineHintTimeout(Value: Integer);
begin
  if FLineHintTimeout <> Value then
  begin
    FLineHintTimeout := Value;
  end;
end;

procedure TCustomElTree.SetVerticalLinesLong(Value: Boolean);
begin
  if FVerticalLinesLong <> Value then
  begin
    FVerticalLinesLong := Value;
    if FVLines then
      Invalidate;
  end;
end;

// ****************************************************************************
//                                  TElCellStyle
// ****************************************************************************
{$ifdef ELTREE_USE_STYLES}
constructor TElCellStyle.Create;
begin
  inherited Create;
  FOwner := Owner;
  FTextFlags := DT_NOPREFIX or DT_SINGLELINE or DT_VCENTER or DT_LEFT or DT_END_ELLIPSIS;
  FCellType := sftText;
end;

destructor TElCellStyle.Destroy;
begin
  Control := nil;
  inherited;
end;

procedure TElCellStyle.SetCellBkColor(newValue: TColor);
begin
  if (FCellBkColor <> newValue) then
  begin
    FCellBkColor := newValue;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetTextBkColor(newValue: TColor);
begin
  if (FTextBkColor <> newValue) then
  begin
    FTextBkColor := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetTextColor(newValue: TColor);
begin
  if (FTextColor <> newValue) then
  begin
    FTextColor := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetTextFlags(newValue: DWORD);
begin
  if (FTextFlags <> newValue) then
  begin
    FTextFlags := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetPicture(newValue: TBitmap);
begin
  if (FPicture <> newValue) then
  begin
    FPicture := newValue;
    if FStyle <> elhsPictureOnly then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetCellType(newValue: TFieldTypes);
begin
  if (FCellType <> newValue) then
  begin
    FCellType := newValue;
  end; {if}
end;

procedure TElCellStyle.SetStyle(newValue: TElSectionStyle);
begin
  if (FStyle <> newValue) then
  begin
    FStyle := newValue;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetOwnerColors(newValue: Boolean);
begin
  if (FOwnerProps <> newValue) then
  begin
    FOwnerProps := newValue;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetFontSize(newValue: integer);
begin
  if (FFontSize <> newValue) then
  begin
    FFontSize := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetFontStyles(newValue: TFontStyles);
begin
  if (FFontStyles <> newValue) then
  begin
    FFontStyles := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.SetFontName(newValue: TFontName);
begin
  if (FFontName <> newValue) then
  begin
    FFontName := newValue;
    if FStyle <> elhsText then exit;
    if Assigned(FOwner) and FOwner.FUseStyles then FOwner.UpdateItem;
  end; {if}
end;

procedure TElCellStyle.Assign(Source: TElCellStyle);
begin
  if Source = nil then exit;
  FUseBkColor  := Source.FUseBkColor; 
  FCellBkColor := Source.FCellBkColor;
  FTextBkColor := Source.FTextBkColor;
  FTextColor := Source.FTextColor;
  FTextFlags := Source.FTextFlags;
  FPicture := Source.FPicture;
  FCellType := Source.FCellType;
  FStyle := Source.FStyle;
  FOwnerProps := Source.FOwnerProps;
  FFontSize := Source.FFontSize;
  FFontStyles := Source.FFontStyles;
  FFontName := Source.FFontName;
end; {Assign}

procedure TElCellStyle.SetControl(newValue: TElCellControl);
begin
  if (FControl <> newValue) then
  begin
    if FControl <> nil then FControl.Destroy;
    FControl := newValue;
    if FControl <> nil then FControl.FOwner := Self;
    Update;
  end; { if }
end; { SetControl }

procedure TElCellStyle.Update; { public }
begin
  if FOwner <> nil then FOwner.RedrawItem(true);
end; { Update }

procedure TElCellStyle.SetUseBkColor(Value: Boolean);
begin
  if FUseBkColor <> Value then
  begin
    FUseBkColor := Value;
    if Assigned(FOwner) and FOwner.FUseStyles then
      FOwner.UpdateItem;
  end;
end;

{$endif}

end.

