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

05/27/2001 (c) Akzhan Abdulin

    Fixed Color property design-time storing issue (clWindow didn't stored)

    Fixed SystemBkColor property setter (always didn't changed)

    DrawArrowFrames, DrawBars, BarOffset and BarColor properties added (inspired by Windows XP)
    Note: try to setup all by default except: Color to clWindow, MinThumbSize to 23 and DrawArrowFrames to false

    Painting was slightly restructured using subroutines

04/28/2001 

    Fixed design-time settings being loaded for UseSystemMetrics-related properties

03/01/2001

    Now background color is drawn in the same way as for system scrollbar

    Now scrollbar behaves more like standard scrollbar 

02/10/2001

    Added HintColor and HintTextColor properties

10/10/2000

    Colors adjusted to be the same as standard scrollbars

10/05/2000

    Added following properties:

    ImageForm  - pseudo-transparency support
    ArrowColor -  defines the color of the arrow
    ArrowHotTrackColor - defines the color of the arrow when cursor is over
                         the button
    DrawFrames - enables or disables buttons and thumb frames (border)
    ThinFrames - enables or disables thin buttons and thumb frames (border)

07/09/2000

    OnMouse* events published.

*)

unit ElScrollBar; { TElScrollBar component. }

{ ScrollBar replacement component }

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus,
  StdCtrls,
  ExtCtrls,
  ElTools,
  ElHintWnd,
  ElVCLUtils
{$IFDEF ELPACK_COMPLETE}
  ,
  ElImgFrm
{$ENDIF}
{$IFDEF HAS_HTML_RENDER}
  ,
  HTMLRender
{$ENDIF}
  ;

type
  TElScrollHintNeededEvent = procedure(Sender : TObject; TrackPosition : integer; var Hint : string) of object;

  TElScrollBarPart = (sbpNowhere,
    sbpLeftArrow, sbpRightSndArrow {actually pointing to the left},
    sbpRightArrow, sbpLeftSndArrow {actually pointing to the right},
    sbpThumb, sbpLeftTop, sbpRightBottom);

  TElScrollDrawPartEvent = procedure(Sender : TObject; Canvas : TCanvas; R : TRect; Part : TElScrollBarPart; Enabled, Focused, Pressed : boolean; var DefaultDraw : boolean) of object;

  TElScrollCode = (escLineUp, escLineDown, escPageUp, escPageDown, escPosition, escTrack, escTop, escBottom, escEndScroll, escSndLineUp, escSndLineDown);

  TElScrollEvent = procedure(Sender : TObject; ScrollCode : TElScrollCode; var ScrollPos : integer; var DoChange : boolean) of object;

  TElSecButtonsKind = (sbkOpposite, sbkPage, sbkCustom);
  TElScrollThumbMode = (etmFixed, etmAuto);

  TCustomElScrollBar = class(TCustomControl)
  private
    FThinFrames: Boolean;
    FDrawFrames: Boolean;
    FDrawArrowFrames: Boolean;
    FDrawBars: Boolean;
    FBarOffset: Cardinal;
    FBarColor: TColor;
    FArrowColor: TColor;
    FArrowHotTrackColor: TColor;
{$IFDEF ELPACK_COMPLETE}
    FImgFormChLink: TImgFormChangeLink;
    FImgForm: TElImageForm;
{$ENDIF}
    FUseSystemMetrics: boolean;
    FNoSunkenThumb: Boolean;
    FShowLeftArrows: Boolean;
    FShowRightArrows: Boolean;
    FChangeColorsOnScroll: Boolean;
    FBlendBitmap: TBitmap;
    FBlendBackground: boolean;
    FShowTrackHint: Boolean;
    FNoDisableButtons: Boolean;
    FOwnerDraw: Boolean;

    FSecondaryButtons: Boolean;
    FSecondBtnKind: TElSecButtonsKind;
    FPage: Integer;
    FMinThumbSize: Integer;
    FThumbMode: TElScrollThumbMode;
    FThumbSize: Integer;
    FButtonSize: Integer;
    FKind: TScrollBarKind;
    FPosition: Integer;
    FMax: Integer;
    FMin: Integer;
    FFlat: Boolean;
    FActiveFlat: Boolean;
    FMouseInControl: boolean;
{$IFDEF HAS_HTML_RENDER}
    FIsHTML: boolean;
{$ENDIF}
    FOnChange: TNotifyEvent;
    FOnScroll: TElScrollEvent;
    FOnDrawPart: TElScrollDrawPartEvent;
    FOnScrollHintNeeded: TElScrollHintNeededEvent;
{$IFNDEF VCL_4_USED}
    FOnResize: TNotifyEvent;
{$ENDIF}

    FScrollTimer: TTimer;
    FThumbOffset,
      FOrigPos,
      FOrigCoord: integer;
    FSaveCapture: THandle;
    FTrackPos, 
    FThumbPos   : integer;

    FPressedIn,
      FOrigPressedIn,
      FMouseOver: TElScrollBarPart;
    FHintWnd: TElHintWindow;
    FPressedPos: TPoint;
    FPressed: boolean;
    FTracking : boolean;
    FNoScrollMessages: boolean;
    FAltDisablingArrows: Boolean;
    procedure SetKind(newValue: TScrollBarKind);

    procedure SetPosition(newValue: Integer);
    procedure SetMax(newValue: Integer);
    procedure SetMin(newValue: Integer);
    procedure SetPage(newValue: Integer);

    procedure DoSetPosition(newValue : Integer; Redraw : boolean);
    procedure DoSetMax(newValue : Integer; Redraw : boolean);
    procedure DoSetMin(newValue : Integer; Redraw : boolean);
    procedure DoSetPage(newValue : Integer; Redraw : boolean);
    function ShadowColor: TColor;
    function LighterColor: TColor;
    procedure SetFlat(newValue: Boolean);
    procedure SetActiveFlat(newValue: Boolean);
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
    procedure CMEnter(var Msg: TCMEnter); message CM_ENTER;
    procedure CMExit(var Msg: TCMExit); message CM_EXIT;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMGetDlgCode(var Msg: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure OnScrollTimer(Sender: TObject);
    procedure SetButtonSize(newValue: Integer);
    procedure SetThumbMode(newValue: TElScrollThumbMode);
    procedure SetThumbSize(newValue: Integer);
    function  GetAutoThumbSize : integer;
    function  GetThumbPos : integer;
    function  GetTopBtns : integer;
    function  GetBottomBtns : integer;
    function  AdjustThumbPos : integer;
    function  UpdateThumbPos : integer;
    procedure SetMinThumbSize(newValue: Integer);
    procedure SetSecondaryButtons(newValue: Boolean);
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure SetOwnerDraw(newValue: Boolean);
    procedure SetSecondBtnKind(newValue: TElSecButtonsKind);
    procedure SBMSetScrollInfo(var Msg: TMessage); message SBM_SETSCROLLINFO;
    procedure SBMGetScrollInfo(var Msg: TMessage); message SBM_GETSCROLLINFO;
    procedure SetNoDisableButtons(newValue: Boolean);
    procedure UpdateScrollingRegion;
    procedure ShowHintAt(APosition, X, Y: integer);
    function  GetButtonSize : integer;
    procedure WMPaint(var Msg : TWMPaint); message WM_PAINT;
    procedure SetIsDesigning(newValue : Boolean);
    function  GetIsDesigning : Boolean;
    procedure SetBlendBackground(newValue: boolean);
    procedure WMSysColorChange(var Msg: TWMSysColorChange); message WM_SYSCOLORCHANGE;
    procedure SetShowLeftArrows(newValue: Boolean);
    procedure SetShowRightArrows(newValue: Boolean);
    procedure SetNoSunkenThumb(newValue: Boolean);
    procedure SetUseSystemMetrics(value: boolean);
    procedure SetArrowColor(newValue: TColor);
    procedure SetArrowHotTrackColor(newValue: TColor);
    procedure SetDrawFrames(newValue: Boolean);
    procedure SetDrawBars(const Value: Boolean);
    procedure SetDrawArrowFrames(const Value: Boolean);
    procedure SetThinFrames(newValue: Boolean);
    procedure SetBarColor(const Value: TColor);
    procedure SetBarOffset(const Value: Cardinal);
{$IFDEF ELPACK_COMPLETE}
    procedure ImageFormChange(Sender: TObject);
    procedure SetImageForm(newValue: TElImageForm); virtual;
{$ENDIF}
    procedure CMColorChanged(var Msg: TMessage); message CM_COLORCHANGED;
    function RightBtnsEnabled: Boolean;
    function LeftBtnsEnabled: Boolean;
    procedure RebuildBackground;
    procedure SetAltDisablingArrows(const Value: Boolean);
    function GetThumbSize: Integer;
  protected
    FHintColor: TColor;
    FHintTextColor: TColor;
    FSysBkColor: boolean;
    procedure TriggerChangeEvent; virtual;
    procedure TriggerScrollEvent(ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange: boolean); virtual;
    procedure TriggerScrollHintNeededEvent(TrackPosition: integer; var Hint: string); virtual;
{$IFNDEF VCL_4_USED}
    procedure TriggerResizeEvent; virtual;
{$ENDIF}
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CreateWindowHandle(const Params : TCreateParams); override;
    procedure SetSysBkColor(Value: boolean);

    property Color default clBtnFace;
    property ParentColor default False;

    property Kind: TScrollBarKind read FKind write SetKind default sbHorizontal; { Published }
    property Position: Integer read FPosition write SetPosition default 0; { Published }
    property Max: Integer read FMax write SetMax default 100; { Published }
    property Min: Integer read FMin write SetMin default 0; { Published }
    property Flat: Boolean read FFlat write SetFlat default true; { Published }
    property ActiveFlat: Boolean read FActiveFlat write SetActiveFlat default true; { Published }
    property ButtonSize: Integer read GetButtonSize write SetButtonSize; { Published }
    property ThumbMode: TElScrollThumbMode read FThumbMode write SetThumbMode default etmAuto; { Published }
    property ThumbSize: Integer read GetThumbSize write SetThumbSize default 0;
    property MinThumbSize: Integer read FMinThumbSize write SetMinThumbSize default 4; { Published }
    property Page: Integer read FPage write SetPage default 1; { Published }
    property SecondaryButtons: Boolean read FSecondaryButtons write SetSecondaryButtons default false; { Published }
    property SecondBtnKind: TElSecButtonsKind read FSecondBtnKind write SetSecondBtnKind default sbkOpposite;
    property NoDisableButtons: Boolean read FNoDisableButtons write SetNoDisableButtons default false; { Published }
    property ShowTrackHint: Boolean read FShowTrackHint write FShowTrackHint default false; { Published }
    property IsDesigning: Boolean read GetIsDesigning write SetIsDesigning default false; { Protected }
    property BlendBackground: boolean read FBlendBackground write SetBlendBackground default true; { Protected }
    property ShowLeftArrows: Boolean read FShowLeftArrows write SetShowLeftArrows default True; { Protected }
    property ShowRightArrows: Boolean read FShowRightArrows write SetShowRightArrows default true; { Protected }
    property ChangeColorsOnScroll: Boolean read FChangeColorsOnScroll write FChangeColorsOnScroll default True; { Protected }
    property NoScrollMessages: boolean read FNoScrollMessages write FNoScrollMessages default false;
    property NoSunkenThumb: Boolean read FNoSunkenThumb write SetNoSunkenThumb default false; { Protected }
    property UseSystemMetrics: boolean read FUseSystemMetrics write SetUseSystemMetrics default true;
    property DrawFrames: Boolean read FDrawFrames write SetDrawFrames default true; { Protected }
    property DrawArrowFrames: Boolean read FDrawArrowFrames write SetDrawArrowFrames default true; { Protected }
    property DrawBars: Boolean read FDrawBars write SetDrawBars default True;
    property BarOffset: Cardinal read FBarOffset write SetBarOffset default 2;
    property BarColor: TColor read FBarColor write SetBarColor default clBtnShadow;
{$IFDEF HAS_HTML_RENDER}
    property IsHTML: boolean read FIsHTML write FIsHTML default false;
{$ENDIF}
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnScroll: TElScrollEvent read FOnScroll write FOnScroll;
    property OnScrollHintNeeded: TElScrollHintNeededEvent read FOnScrollHintNeeded write FOnScrollHintNeeded;
    property OwnerDraw: Boolean read FOwnerDraw write SetOwnerDraw;
    property OnDrawPart: TElScrollDrawPartEvent read FOnDrawPart write FOnDrawPart;
    property ArrowColor: TColor read FArrowColor write SetArrowColor default clBtnText; { Protected }
    property ArrowHotTrackColor: TColor read FArrowHotTrackColor write SetArrowHotTrackColor default clHighlight; { Protected }
    property ThinFrames: Boolean read FThinFrames write SetThinFrames default false; { Protected }
    property HintColor: TColor read FHintColor write FHintColor default clInfoBk;
    property HintTextColor: TColor read FHintTextColor write FHintTextColor default
      clInfoText;

{$IFDEF ELPACK_COMPLETE}
    property ImageForm: TElImageForm read FImgForm write SetImageForm; { Protected }
{$ENDIF}
{$IFNDEF VCL_4_USED}
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
{$ENDIF}
    property SystemBkColor : boolean read FSysBkColor write SetSysBkColor default true;
    property AltDisablingArrows: Boolean read FAltDisablingArrows write 
        SetAltDisablingArrows default false;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Loaded; override;
    function GetHitTest(X, Y : integer) : TElScrollBarPart;
    procedure Paint; override;
{$IFNDEF VCL_4_USED}
    procedure Resize; virtual;
{$ELSE}
    procedure Resize; override;
{$ENDIF}
    procedure EndScroll;
  end; { TCustomElScrollBar }

  TElScrollBarStyles = class(TPersistent)
  private
    FElScrollBar: TCustomElScrollBar;
    FOnChange: TNotifyEvent;
    function GetButtonSize: integer;
    procedure SetButtonSize(newValue: Integer);
    function GetNoDisableButtons: Boolean;
    procedure SetNoDisableButtons(newValue: Boolean);
    function GetNoSunkenThumb: Boolean;
    procedure SetNoSunkenThumb(newValue: Boolean);
    procedure SetActiveFlat(newValue: Boolean);
    function GetActiveFlat: Boolean;
    procedure SetColor(newValue: TColor);
    function GetColor: TColor;
    procedure SetFlat(newValue: Boolean);
    function GetFlat: Boolean;
    procedure SetMinThumbSize(newValue: Integer);
    function GetMinThumbSize: Integer;
    procedure SetOwnerDraw(newValue: Boolean);
    function GetOwnerDraw: Boolean;
    procedure SetSecondaryButtons(newValue: Boolean);
    function GetSecondaryButtons: Boolean;
    procedure SetSecondBtnKind(newValue: TElSecButtonsKind);
    function GetSecondBtnKind: TElSecButtonsKind;
    procedure SetShowTrackHint(newValue: Boolean);
    function GetShowTrackHint: Boolean;
    procedure SetThumbMode(newValue: TElScrollThumbMode);
    function GetThumbMode: TElScrollThumbMode;
    procedure SetThumbSize(newValue: Integer);
    function GetThumbSize: Integer;
    function GetBlendBackground: Boolean;
    procedure SetBlendBackground(newValue: Boolean);
    function GetWidth : Integer;
    procedure SetWidth(newValue : Integer);
    function GetShowLeftArrows: Boolean;
    procedure SetShowLeftArrows(newValue: Boolean);
    function GetShowRightArrows: Boolean;
    procedure SetShowRightArrows(newValue: Boolean);
    function GetUseSystemMetrics: boolean;
    procedure SetUseSystemMetrics(Value: boolean);
    function GetArrowColor: TColor;
    procedure SetArrowColor(newValue: TColor);
    function GetArrowHotTrackColor: TColor;
    procedure SetArrowHotTrackColor(newValue: TColor);
    function GetDrawFrames: Boolean;
    procedure SetDrawFrames(newValue: Boolean);
    function GetThinFrames: Boolean;
    procedure SetThinFrames(newValue: Boolean);
    function GetHintColor: TColor;
    procedure SetHintColor(Value: TColor);
    function GetHintTextColor: TColor;
    procedure SetHintTextColor(Value: TColor);
    function GetDrawBars: Boolean;
    procedure SetDrawBars(const Value: Boolean);
    function GetBarColor: TColor;
    procedure SetBarColor(const Value: TColor);
    function GetBarOffset: Cardinal;
    procedure SetBarOffset(const Value: Cardinal);
{$IFDEF ELPACK_COMPLETE}
    function GetImageForm: TElImageForm;
    procedure SetImageForm(newValue: TElImageForm);
{$ENDIF}
    function GetDrawArrowFrames: Boolean;
    procedure SetDrawArrowFrames(const Value: Boolean);
  protected
    function GetSysBkColor: boolean;
    procedure SetSysBkColor(Value: boolean);
  public
    constructor Create(AControl: TCustomElScrollBar);
    procedure Assign(Source: TPersistent); override;
  published
    property ActiveFlat: Boolean read GetActiveFlat write SetActiveFlat default false;
    property BlendBackground: Boolean read GetBlendBackground write SetBlendBackground default true; { Published }
    property Color: TColor read GetColor write SetColor default clBtnFace;
    property Flat: Boolean read GetFlat write SetFlat default true;
    property MinThumbSize: Integer read GetMinThumbSize write SetMinThumbSize default 4;
    property NoDisableButtons: Boolean read GetNoDisableButtons write SetNoDisableButtons default false; { Published }
    property NoSunkenThumb: Boolean read GetNoSunkenThumb write SetNoSunkenThumb default false; { Published }
    property OwnerDraw: Boolean read GetOwnerDraw write SetOwnerDraw default false;
    property SecondaryButtons: Boolean read GetSecondaryButtons write SetSecondaryButtons default false;
    property SecondBtnKind: TElSecButtonsKind read GetSecondBtnKind write SetSecondBtnKind default sbkOpposite;
    property ShowLeftArrows: Boolean read GetShowLeftArrows write SetShowLeftArrows default true; { Published }
    property ShowRightArrows: Boolean read GetShowRightArrows write SetShowRightArrows default true; { Published }
    property ShowTrackHint: Boolean read GetShowTrackHint write SetShowTrackHint default false;
    property ThumbMode: TElScrollThumbMode read GetThumbMode write SetThumbMode default etmAuto;
    property ThumbSize: Integer read GetThumbSize write SetThumbSize default 0;
    property Width     : Integer read GetWidth write SetWidth;  { Published }
    property ButtonSize: integer read GetButtonSize write SetButtonSize;
    property UseSystemMetrics: boolean read GetUseSystemMetrics write SetUseSystemMetrics default true;
    property ArrowColor: TColor read GetArrowColor write SetArrowColor default clBtnText; { Published }
    property ArrowHotTrackColor: TColor read GetArrowHotTrackColor write SetArrowHotTrackColor default clHighlight; { Published }

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property DrawFrames: Boolean read GetDrawFrames write SetDrawFrames default true; { Published }
    property DrawArrowFrames: Boolean read GetDrawArrowFrames write SetDrawArrowFrames default true; { Published }
    property DrawBars: Boolean read GetDrawBars write SetDrawBars default True;
    property BarOffset: Cardinal read GetBarOffset write SetBarOffset default 2;
    property BarColor: TColor read GetBarColor write SetBarColor default clBtnShadow;
    property ThinFrames: Boolean read GetThinFrames write SetThinFrames default false; { Published }
    property HintColor: TColor read GetHintColor write SetHintColor default clInfoBk;
    property HintTextColor: TColor read GetHintTextColor write SetHintTextColor default clInfoText;
    property SystemBkColor: boolean read GetSysBkColor write SetSysBkColor default true;
{$IFDEF ELPACK_COMPLETE}
    property ImageForm: TElImageForm read GetImageForm write SetImageForm; { Published }
{$ENDIF}
  end;

  TElScrollBar = class(TCustomElScrollBar)
  published
    property AltDisablingArrows;
    property ArrowColor;
    property ArrowHotTrackColor;
    property Kind;
    property Position;
    property Max;
    property Min;
    property Flat;
    property ActiveFlat;
    property BlendBackground;
    property SystemBkColor;
    property ButtonSize;
    property ChangeColorsOnScroll;
    property DrawFrames;
    property DrawArrowFrames;
    property DrawBars;
    property BarOffset;
    property BarColor;
{$IFDEF ELPACK_COMPLETE}
    property ImageForm;
{$ENDIF}
{$IFDEF HAS_HTML_RENDER}
    property IsHTML;
{$ENDIF}
    property MinThumbSize;
    property NoDisableButtons;
    property NoSunkenThumb;
    property Page;
    property SecondaryButtons;
    property SecondBtnKind;
    property ShowLeftArrows;
    property ShowRightArrows;
    property ShowTrackHint;
    property ThinFrames;
    property ThumbMode;
    property ThumbSize;
    property UseSystemMetrics;

    { Inherited properties: }

    property Align;
    property Color;
    property Ctl3D;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property ShowHint;

    property TabOrder;
    property TabStop;
    property Visible;

    property OnChange;
    property OnScroll;
    property OnScrollHintNeeded;
    property OwnerDraw;
    property OnDrawPart;

{$IFNDEF VCL_4_USED}
    property OnResize;
{$ENDIF}

    { Inherited events: }
{$IFDEF VCL_4_USED}
    property OnStartDock;
    property OnEndDock;
{$ENDIF}
{$IFDEF VCL_5_USED}
    property OnContextPopup;
{$ENDIF}
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnStartDrag;
  end;

implementation

procedure TCustomElScrollBar.SetKind(newValue: TScrollBarKind);
begin
  if (FKind <> newValue) then
  begin
    FKind := newValue;
    if not (csLoading in ComponentState) then SetBounds(Left, Top, Height, Width);
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      if FUseSystemMetrics then
      begin
        FUseSystemMetrics := false;
        UseSystemMetrics := true;
      end
      else
      begin
        FThumbPos := AdjustThumbPos;
        Invalidate;
      end;
    end;
  end; { if }
end; { SetKind }

procedure TCustomElScrollBar.DoSetPosition(newValue: Integer; Redraw: boolean);
var op : integer;
    DoChange: boolean;
begin
  if (FPosition <> newValue) then
  begin
    op := FPosition;
    if not (csLoading in ComponentState) then
    begin
      if newValue < FMin then
        FPosition := FMin
      else
        if newValue > FMax then
          FPosition := FMax
        else
          FPosition := newValue;
      FThumbPos := AdjustThumbPos;
    end
    else
      FPosition := newValue;
    if Redraw and (OP <> FPosition) then
    begin
      if FNoDisableButtons or (InRange(Min + 1, Max - 1, op) = InRange(Min + 1, Max - 1, FPosition)) then
        UpdateScrollingRegion
      else
        Invalidate;
    end;
    TriggerScrollEvent(escPosition, newValue, DoChange);
  end; { if }
end;

procedure TCustomElScrollBar.DoSetMax(newValue: Integer; Redraw: boolean);
begin
  if (FMax <> newValue) then
  begin
    FMax := newValue;
    if not (csLoading in ComponentState) then
    begin
      if FMin >= FMax then FMax := FMin;
      FPage := ElTools.Min(FPage, FMax - FMin + 1);
      FThumbPos := AdjustThumbPos;
      if HandleAllocated then Invalidate;
    end;
    if FPosition > FMax then
      SetPosition(Max)
    else
      if Redraw then Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.DoSetMin(newValue: Integer; Redraw: boolean);
begin
  if (FMin <> newValue) then
  begin
    FMin := newValue;
    if not (csLoading in ComponentState) then
    begin
      if FMin >= FMax then FMax := FMin;
      FPage := ElTools.Min(FPage, FMax - FMin + 1);
      FThumbPos := AdjustThumbPos;
      if HandleAllocated then Invalidate;
    end;
    if FPosition < FMin then
      SetPosition(Min)
    else
      if Redraw then Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.DoSetPage(newValue: Integer; Redraw: boolean);
begin
  if (FPage <> newValue) and (newValue >= 0) then
  begin
    FPage := newValue;
    if (not (csLoading in ComponentState)) and HandleAllocated then Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.SetPosition(newValue: Integer);
begin
  DoSetPosition(newValue, not (csLoading in ComponentState) and HandleAllocated);
end; { SetPosition }

procedure TCustomElScrollBar.SetMax(newValue: Integer);
begin
  DoSetMax(newValue, not (csLoading in ComponentState) and HandleAllocated);
end; { SetMax }

procedure TCustomElScrollBar.SetMin(newValue: Integer);
{ Sets data member FMin to newValue. }
begin
  DoSetMin(newValue, not (csLoading in ComponentState) and HandleAllocated);
end; { SetMin }

procedure TCustomElScrollBar.SetFlat(newValue: Boolean);
{ Sets data member FFlat to newValue. }
begin
  if (FFlat <> newValue) then
  begin
    FFlat := newValue;
    if not (csLoading in ComponentState) and HandleAllocated then Invalidate;
  end; { if }
end; { SetFlat }

procedure TCustomElScrollBar.SetActiveFlat(newValue: Boolean);
{ Sets data member FActiveFlat to newValue. }
begin
  if (FActiveFlat <> newValue) then
  begin
    FActiveFlat := newValue;
    if (FMouseInControl or Focused) then Invalidate;
  end; { if }
end; { SetActiveFlat }

procedure TCustomElScrollBar.CMMouseEnter(var Msg: TMessage); { private }
begin
  inherited;
  FMouseInControl := true;
  if Flat and (not ActiveFlat) then Invalidate;
end; { CMMouseEnter }

procedure TCustomElScrollBar.CMMouseLeave(var Msg: TMessage); { private }
begin
  inherited;
  FMouseInControl := false;
  if Flat and (not ActiveFlat) then Invalidate;
end; { CMMouseLeave }

procedure TCustomElScrollBar.CMEnter(var Msg: TCMEnter); { private }
begin
  inherited;
  if Flat and (not ActiveFlat) then Invalidate;
end; { CMEnter }

procedure TCustomElScrollBar.CMExit(var Msg: TCMExit); { private }
begin
  inherited;
  if Flat and (not ActiveFlat) then Invalidate;
end; { CMExit }

function TCustomElScrollBar.ShadowColor: TColor;
var
  hlscol, rgbcol: COLORREF;
  lum: integer;
begin
  if Color = clBtnFace then
    result := clBtnShadow
  else
  begin
    rgbcol := ColorToRGB(Color);
    hlscol := RGBtoHLS(rgbcol);
    lum := Hi(LoWord(hlscol));
    hlscol := Cardinal((ElTools.Min(255, (Hi(LoWord(hlscol)) - lum div 4)) shl 8)) or (hlscol and $FF00FF);
    result := HLStoRGB(hlscol);
  end;
end;

function TCustomElScrollBar.LighterColor: TColor;
var
  hlscol, rgbcol: COLORREF;
  lum: integer;
begin
  if Color = clBtnFace then
    result := clBtnHighlight
  else
  begin
    rgbcol := ColorToRGB(Color);
    hlscol := RGBtoHLS(rgbcol);
    lum := Hi(LoWord(hlscol));
    hlscol := Cardinal((ElTools.Min(255, (Hi(LoWord(hlscol)) + lum div 4)) shl 8)) or (hlscol and $FF00FF);
    result := HLStoRGB(hlscol);
  end;
end;

procedure TCustomElScrollBar.Paint; { public }
var
  R1, R2: TRect;
  ATS: integer;
  b, e: boolean;
  DefDraw: boolean;
  TransBk: boolean;
  aW, aH, aSh: Integer;
{$IFDEF ELPACK_COMPLETE}
  AForm: TCustomForm;
  ax, ay: integer;
  P: TPoint;
  BgRect: TRect;
{$ENDIF}
  ArrColors: array[boolean] of TColor;

  procedure FillBackground(Rect: TRect);
  begin
    if not TransBk then
    begin
      if (BlendBackground and (not SystemBkColor)) or (SystemBkColor and (GetSysColor(COLOR_SCROLLBAR) = GetSysColor(COLOR_BTNFACE))) then
      begin
          Canvas.Brush.Bitmap := FBlendBitmap;
          Canvas.FillRect(Rect);
          Canvas.Brush.Bitmap := nil;
          Canvas.Brush.Color := Color;
      end
      else
      begin
        if SystemBkColor then
          Canvas.Brush.Handle := GetSysColorBrush(COLOR_SCROLLBAR)
        else
          Canvas.Brush.Color := Color;
        Canvas.FillRect(Rect);
        Canvas.Brush.Color := Color;
      end;
    end;
  end;

  procedure FillShadow(Rect: TRect);
  begin
    if not TransBk then
    begin
      Canvas.Brush.Color := ShadowColor;
      Canvas.FillRect(Rect);
      Canvas.Brush.Color := Color;
    end;
  end;

  procedure FillArrowFrame(Rect: TRect);
  var
    OldColor: TColor;
  begin
    if not TransBk then
    begin
      OldColor := Canvas.Brush.Color;
      if FDrawArrowFrames then
      begin
        Canvas.Brush.Color := Color;
        Canvas.FillRect(Rect)
      end
      else
      begin
        FillBackground(Rect);
      end;
      Canvas.Brush.Color := OldColor;
    end;
  end;

begin
  ArrColors[false] := ArrowColor;
  ArrColors[true] := ArrowHotTrackColor;

  Canvas.Brush.Color := Color;
  R2 := ClientRect;
  R1 := R2;
  TransBk := false;
{$IFDEF ELPACK_COMPLETE}
  if (FImgForm <> nil) and (not (csDesigning in FImgForm.ComponentState)) then
  begin
    TransBk := true;
    Canvas.Brush.Style := bsClear;
    AForm := GetParentForm(Self);
    R1 := R2;
    BgRect := R1;
    BgRect.TopLeft := ClientToScreen(BgRect.TopLeft);
    P := Parent.ClientToScreen(Point(Left, Top));
    ax := BgRect.Left - P.x;
    ay := BgRect.Top - P.y;

    BgRect.BottomRight := ClientToScreen(BgRect.BottomRight);
    BgRect.TopLeft := AForm.ScreenToClient(BgRect.TopLeft);
    BgRect.BottomRight := AForm.ScreenToClient(BgRect.BottomRight);
    FImgForm.PaintBkgnd(Canvas.Handle, R1, Point(BgRect.Left - ax, BgRect.Top - ay), false);
  end
  else
{$ENDIF}
    Canvas.Brush.Style := bsSolid;
  R2 := ClientRect;
  R1 := R2;
  if (kind = sbHorizontal) then
  begin
    if FShowLeftArrows then
    begin
      R1.Right := R1.Left + ButtonSize;
      R2.Left := R1.Right;
      FillArrowFrame(R1);
      b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpLeftArrow) and (LeftBtnsEnabled or NoDisableButtons));
      DefDraw := true;
      if OwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpLeftArrow, LeftBtnsEnabled, b, (FPressedIn = sbpLeftArrow) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if FDrawArrowFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpLeftArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
        DrawArrow(Canvas, eadLeft, R1, ArrColors[b], LeftBtnsEnabled or NoDisableButtons);
      end;
    end;

    if FShowRightArrows then
    begin
      R1 := R2;
      R1.Left := R1.Right - ButtonSize;
      R2.Right := R1.Left;
      FillArrowFrame(R1);
      b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpRightArrow) and (RightBtnsEnabled or NoDisableButtons));
      DefDraw := true;
      if OwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpRightArrow, RightBtnsEnabled, b, (FPressedIn = sbpRightArrow) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if FDrawArrowFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpRightArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
        DrawArrow(Canvas, eadRight, R1, ArrColors[b], RightBtnsEnabled or NoDisableButtons);
      end;
    end;

    if FSecondaryButtons then
    begin
      if FShowLeftArrows then
      begin
        R1 := R2;
        R1.Right := R1.Left + ButtonSize;
        R2.Left := R1.Right;
        FillArrowFrame(R1);
        e := ((RightBtnsEnabled and (FSecondBtnKind <> sbkPage)) or (LeftBtnsEnabled and (FSecondBtnKind = sbkPage)) or (FSecondBtnKind = sbkCustom) or NoDisableButtons);
        b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpLeftSndArrow) and e);
        DefDraw := true;
        if OwnerDraw and Assigned(FOnDrawPart) then
        begin
          FOnDrawPart(Self, Canvas, R1, sbpLeftSndArrow, e, b, (FPressedIn = sbpLeftSndArrow) and (FMouseOver = FPressedIn), DefDraw);
        end;
        if DefDraw then
        begin
          if FDrawArrowFrames then
            DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpLeftSndArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
          if FSecondBtnKind = sbkPage then
          begin
            OffsetRect(R1, 1, 0);
            DrawArrow(Canvas, eadLeft, R1, ArrColors[b], e);
            OffsetRect(R1, -3, 0);
            DrawArrow(Canvas, eadLeft, R1, ArrColors[b], e);
            OffsetRect(R1, 2, 0);
          end
          else
            DrawArrow(Canvas, eadRight, R1, ArrColors[b], e);
        end;
      end;

      if FShowRightArrows then
      begin
        R1 := R2;
        R1.Left := R1.Right - ButtonSize;
        R2.Right := R1.Left;
        FillArrowFrame(R1);
        e := ((LeftBtnsEnabled and (FSecondBtnKind <> sbkPage)) or (RightBtnsEnabled and (FSecondBtnKind = sbkPage)) or (FSecondBtnKind = sbkCustom) or NoDisableButtons);
        b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpRightSndArrow) and e);
        DefDraw := true;
        if OwnerDraw and Assigned(FOnDrawPart) then
        begin
          FOnDrawPart(Self, Canvas, R1, sbpRightSndArrow, e, b, (FPressedIn = sbpRightSndArrow) and (FMouseOver = FPressedIn), DefDraw);
        end;
        if DefDraw then
        begin
          if FDrawArrowFrames then
            DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpRightSndArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
          if FSecondBtnKind = sbkPage then
          begin
            OffsetRect(R1, 2, 0);
            DrawArrow(Canvas, eadRight, R1, ArrColors[b], e);
            OffsetRect(R1, -3, 0);
            DrawArrow(Canvas, eadRight, R1, ArrColors[b], e);
            OffsetRect(R1, 1, 0);
          end
          else
            DrawArrow(Canvas, eadLeft, R1, ArrColors[b], e);
        end;
      end;
    end;

    if FThumbMode = etmFixed then
      ATS := ThumbSize
    else
      ATS := GetAutoThumbSize;
    if (ATS > 0) and Enabled then
    begin

      // first draw the left part of the scroll fields
      DefDraw := true;

      R2.Right := FThumbPos;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpLeftTop, Enabled, Focused, (FPressedIn = sbpLeftTop) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if (FPressedIn = sbpLeftTop) and (FMouseOver = FPressedIn) and ChangeColorsOnScroll then
        begin
          FillShadow(R2);
        end
        else
        begin
          FillBackground(R2);
        end;
      end;

      R1 := ClientRect;
      R1.Left := FThumbPos;
      R1.Right := R1.Left + ATS;
      b := (Focused and (not FActiveFlat)) or (not Flat) or (FMouseInControl and (not FActiveFlat) and ((FMouseOver = sbpThumb) and ((Max >= Min + 1) and (FPage < (Max - Min)))));
      DefDraw := true;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpThumb, Enabled, b, FPressedIn = sbpThumb, DefDraw);
      end;
      if DefDraw then
      begin
        Canvas.Brush.Color := Color;
        if not TransBk then
          Canvas.FillRect(R1);
        if FDrawFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpThumb) and (not NoSunkenThumb), Color, ThinFrames);
        if FDrawBars and (ATS > 14) then
        begin
          aH := FBarOffset;
          if FDrawFrames then Inc(aH);
          if (b) and (FPressedIn = sbpThumb) and (not NoSunkenThumb) then
            aSh := 1
          else
            aSh := 0;
          if (R1.Bottom - R1.Top) >= aH + aH + 3 then
          begin
            with R1 do
            begin
              aW := (Right + Left) shr 1;
            end;
            Inc(aW, aSh);
            with Canvas do
            begin
              Pen.Color := FBarColor;
              MoveTo(aW - 1, R1.Top + aH + aSh);
              LineTo(aW - 1, R1.Bottom - aH + aSh);
              MoveTo(aW - 3, R1.Top + aH + aSh);
              LineTo(aW - 3, R1.Bottom - aH + aSh);
              MoveTo(aW + 1, R1.Top + aH + aSh);
              LineTo(aW + 1, R1.Bottom - aH + aSh);
              MoveTo(aW + 3, R1.Top + aH + aSh);
              LineTo(aW + 3, R1.Bottom - aH + aSh);
            end;
          end;
        end;
      end;

      // then draw the right part of the scroll fields
      R2.Left := FThumbPos + ATS;
      R2.Right := ClientWidth - ButtonSize * GetBottomBtns;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpRightBottom, Enabled, Focused, (FPressedIn = sbpRightBottom) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if (FPressedIn = sbpRightBottom) and (FMouseOver = FPressedIn) and ChangeColorsOnScroll then
        begin
          FillShadow(R2);
        end
        else
        begin
          FillBackground(R2);
        end;
      end;
    end
    else
    begin
      DefDraw := true;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpNowhere, Enabled, Focused, false, DefDraw);
      end;
      if DefDraw then
      begin
        if not TransBk then
          Canvas.FillRect(R2);
      end;
    end;
  end
  else
  begin
    if FShowLeftArrows then
    begin
      R1.Bottom := R1.Top + ButtonSize;
      R2.Top := R1.Bottom;
      FillArrowFrame(R1);
      b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpLeftArrow) and (LeftBtnsEnabled or NoDisableButtons));
      DefDraw := true;
      if OwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpLeftArrow, LeftBtnsEnabled, b, (FPressedIn = sbpLeftArrow) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if FDrawArrowFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpLeftArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
        DrawArrow(Canvas, eadUp, R1, ArrColors[b], LeftBtnsEnabled or NoDisableButtons);
      end;
    end;

    if Self.FShowRightArrows then
    begin
      R1 := R2;
      R1.Top := R1.Bottom - ButtonSize;
      R2.Bottom := R1.Top;
      FillArrowFrame(R1);
      b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpRightArrow) and (RightBtnsEnabled or NoDisableButtons));
      DefDraw := true;
      if OwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpRightArrow, RightBtnsEnabled, b, (FPressedIn = sbpRightArrow) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if FDrawArrowFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpRightArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
        DrawArrow(Canvas, eadDown, R1, ArrColors[b], RightBtnsEnabled or NoDisableButtons);
      end;
    end;

    if FSecondaryButtons then
    begin
      if FShowLeftArrows then
      begin
        R1 := R2;
        R1.Bottom := R1.Top + ButtonSize;
        R2.Top := R1.Bottom;
        FillArrowFrame(R1);
        e := ((RightBtnsEnabled and (FSecondBtnKind <> sbkPage)) or (LeftBtnsEnabled and (FSecondBtnKind = sbkPage)) or (FSecondBtnKind = sbkCustom) or NoDisableButtons);
        b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpLeftSndArrow) and e);
        DefDraw := true;
        if OwnerDraw and Assigned(FOnDrawPart) then
        begin
          FOnDrawPart(Self, Canvas, R1, sbpLeftSndArrow, e, b, (FPressedIn = sbpLeftSndArrow) and (FMouseOver = FPressedIn), DefDraw);
        end;
        if DefDraw then
        begin
          if FDrawArrowFrames then
            DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpLeftSndArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
          if FSecondBtnKind = sbkPage then
          begin
            OffsetRect(R1, 0, 1);
            DrawArrow(Canvas, eadUp, R1, ArrColors[b], e);
            OffsetRect(R1, 0, -3);
            DrawArrow(Canvas, eadUp, R1, ArrColors[b], e);
            OffsetRect(R1, 0, 2);
          end
          else
            DrawArrow(Canvas, eadDown, R1, ArrColors[b], e);
        end;
      end;

      if FShowRightArrows then
      begin
        R1 := R2;
        R1.Top := R1.Bottom - ButtonSize;
        R2.Bottom := R1.Top;
        FillArrowFrame(R1);
        e := (((LeftBtnsEnabled) and (FSecondBtnKind <> sbkPage)) or (RightBtnsEnabled and (FSecondBtnKind = sbkPage)) or (FSecondBtnKind = sbkCustom) or NoDisableButtons);
        b := (not Flat) or ((not FPressed) and FMouseInControl and (not FActiveFlat) and (FMouseOver = sbpRightSndArrow) and e);
        DefDraw := true;
        if OwnerDraw and Assigned(FOnDrawPart) then
        begin
          FOnDrawPart(Self, Canvas, R1, sbpRightSndArrow, e, b, (FPressedIn = sbpRightSndArrow) and (FMouseOver = FPressedIn), DefDraw);
        end;
        if DefDraw then
        begin
          if FDrawArrowFrames then
            DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpRightSndArrow) and (FMouseOver = FPressedIn), Color, ThinFrames);
          if FSecondBtnKind = sbkPage then
          begin
            OffsetRect(R1, 0, 2);
            DrawArrow(Canvas, eadDown, R1, ArrColors[b], e);
            OffsetRect(R1, 0, -3);
            DrawArrow(Canvas, eadDown, R1, ArrColors[b], e);
            OffsetRect(R1, 0, 1);
          end
          else
            DrawArrow(Canvas, eadUp, R1, ArrColors[b], e);
        end;
      end;
    end;

    if FThumbMode = etmFixed then
      ATS := ThumbSize
    else
      ATS := GetAutoThumbSize;
    if (ATS > 0) and Enabled then
    begin

      // first draw the left part of the scroll fields
      DefDraw := true;

      R2.Bottom := FThumbPos;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpLeftTop, Enabled, Focused, (FPressedIn = sbpLeftTop) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if (FPressedIn = sbpLeftTop) and (FMouseOver = FPressedIn) and ChangeColorsOnScroll then
        begin
          FillShadow(R2);
        end
        else
        begin
          FillBackground(R2);
        end;
      end;

      R1 := ClientRect;
      R1.Top := FThumbPos;
      R1.Bottom := R1.Top + ATS;
      b := (Focused and (not FActiveFlat)) or (not Flat) or (FMouseInControl and (not FActiveFlat) and ((FMouseOver = sbpThumb) and ((Max >= Min + 1) and (FPage < (Max - Min)))));
      DefDraw := true;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R1, sbpThumb, Enabled, b, FPressedIn = sbpThumb, DefDraw);
      end;
      if DefDraw then
      begin
        Canvas.Brush.Color := Color;
        if not TransBk then
          Canvas.FillRect(R1);
        if FDrawFrames then
          DrawButtonFrameEx(Canvas.Handle, R1, b, (FPressedIn = sbpThumb) and (not NoSunkenThumb), Color, ThinFrames);
        if FDrawBars and (ATS > 14) then
        begin
          aH := FBarOffset;
          if FDrawFrames then Inc(aH);
          if (b) and (FPressedIn = sbpThumb) and (not NoSunkenThumb) then
            aSh := 1
          else
            aSh := 0;
          if (R1.Right - R1.Left) >= aH + aH + 3 then
          begin
            with R1 do
            begin
              aW := (Bottom + Top) shr 1;
            end;
            Inc(aW, aSh);
            with Canvas do
            begin
              Pen.Color := FBarColor;
              MoveTo(R1.Left + aH + aSh, aW - 1);
              LineTo(R1.Right - aH + aSh, aW - 1);
              MoveTo(R1.Left + aH + aSh, aW - 3);
              LineTo(R1.Right - aH + aSh, aW - 3);
              MoveTo(R1.Left + aH + aSh, aW + 1);
              LineTo(R1.Right - aH + aSh, aW + 1);
              MoveTo(R1.Left + aH + aSh, aW + 3);
              LineTo(R1.Right - aH + aSh, aW + 3);
            end;
          end;
        end;
      end;

      // then draw the right part of the scroll fields
      R2.Top := FThumbPos + ATS;
      R2.Bottom := ClientHeight;
      Dec(R2.Bottom, ButtonSize * GetBottomBtns);
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpRightBottom, Enabled, Focused, (FPressedIn = sbpRightBottom) and (FMouseOver = FPressedIn), DefDraw);
      end;
      if DefDraw then
      begin
        if (FPressedIn = sbpRightBottom) and (FMouseOver = FPressedIn) and ChangeColorsOnScroll then
        begin
          FillShadow(R2);
        end
        else
        begin
          FillBackground(R2);
        end;
      end;
    end
    else
    begin
      DefDraw := true;
      if FOwnerDraw and Assigned(FOnDrawPart) then
      begin
        FOnDrawPart(Self, Canvas, R2, sbpNowhere, Enabled, Focused, false, DefDraw);
      end;
      if DefDraw then
      begin
        FillBackground(R2);
      end;
    end;
  end;
end; { Paint }

procedure TCustomElScrollBar.WMEraseBkgnd(var Msg: TWMEraseBkgnd); { private }
begin
  Msg.Result := 1;
end; { WMEraseBkgnd }

procedure TCustomElScrollBar.Resize; { public }
begin
  if HandleAllocated then
  begin
    FThumbPos := AdjustThumbPos;
    Invalidate;
  end;
{$IFNDEF VCL_4_USED}
  TriggerResizeEvent;
{$ENDIF}
end; { Resize }

procedure TCustomElScrollBar.WMMouseMove(var Msg: TWMMouseMove); { private }
var
  OldMouseOver: TElScrollBarPart;
  ATS, OP, NP, CS: integer;
  DoChange: boolean;
  AX, AY: integer;
begin
  inherited;
  if not FPressed then
  begin
    OldMouseOver := FMouseOver;
    with Msg do
      FMouseOver := GetHitTest(XPos, YPos);
    if FMouseOver <> OldMouseOver then Invalidate;
  end
  else
  begin
    if FTrackPos = -1 then
    begin
      FTracking := true;
      FTrackPos := FThumbOffset;
    end;
    if FPressedIn = sbpThumb then
    begin
      if Kind = sbHorizontal then
      begin
        CS := ClientWidth;
        if ((Msg.XPos < 0) and (Abs(Msg.XPos) > CS shr 1)) or
          ((Msg.XPos > CS) and (Msg.XPos - CS > CS shr 1)) then
        begin
          FThumbPos := FOrigCoord - FThumbOffset;
          NP := UpdateThumbPos;
          UpdateScrollingRegion;
        end
        else
        begin
          if FThumbMode = etmFixed then
            ATS := ThumbSize
          else
            ATS := GetAutoThumbSize;
          OP := FThumbPos;
          FThumbPos := Msg.XPos - FThumbOffset;
          if FThumbPos < ButtonSize * (GetTopBtns) then
            FThumbPos := ButtonSize * (GetTopBtns)
          else
            if FThumbPos > (CS - ButtonSize * (GetBottomBtns) - ATS) then FThumbPos := CS - ButtonSize * (GetBottomBtns) - ATS;
          NP := UpdateThumbPos;
          if not NoScrollMessages then
            SendMessage(Parent.Handle, WM_HSCROLL, NP shl 16 + SB_THUMBPOSITION, Handle);
          TriggerScrollEvent(escTrack, NP, DoChange);
          if OP <> FThumbPos then
            UpdateScrollingRegion;
        end;
      end
      else
      begin
        CS := ClientHeight;
        if ((Msg.YPos < 0) and (Abs(Msg.YPos) > CS shr 1)) or
          ((Msg.YPos > CS) and (Msg.YPos - CS > CS shr 1)) then
        begin
          FThumbPos := FOrigCoord - FThumbOffset;
          NP := UpdateThumbPos;
          UpdateScrollingRegion;
        end
        else
        begin
          if FThumbMode = etmFixed then
            ATS := ThumbSize
          else
            ATS := GetAutoThumbSize;
          OP := FThumbPos;
          FThumbPos := Msg.YPos - FThumbOffset;
          if FThumbPos < ButtonSize * (GetTopBtns) then
            FThumbPos := ButtonSize * (GetTopBtns)
          else
            if FThumbPos > (CS - ButtonSize * (GetBottomBtns) - ATS) then FThumbPos := CS - ButtonSize * (GetBottomBtns) - ATS;
          NP := UpdateThumbPos;
          if not NoScrollMessages then
            SendMessage(Parent.Handle, WM_VSCROLL, NP shl 16 + SB_THUMBPOSITION, Handle);
          TriggerScrollEvent(escTrack, NP, Dochange);
          if OP <> FThumbPos then UpdateScrollingRegion;
        end;
      end;
      if FShowTrackHint and (NP <> FThumbPos) then
      begin
        if Kind = sbHorizontal then
        begin
          AY := -5;
          AX := FThumbPos - 2;
        end
        else
        begin
          AX := -2;
          AY := FThumbPos - 2;
        end;
        ShowHintAt(NP, AX, AY);
      end;
    end
    else
    begin
      OldMouseOver := FMouseOver;
      with Msg do
        FMouseOver := GetHitTest(XPos, YPos);
      if FMouseOver <> FPRessedIn then
      begin
        FScrollTimer.Enabled := false;
      end
      else
        if OldMouseOver <> FMouseOver then
        begin
          if (FPressedIn <> sbpThumb) then
          begin
            FScrollTimer.Enabled := true;
          end;
        end;
      if OldMouseOver <> FMouseOver then Invalidate;
    end;
    //if FMouseIn <>
    //if FMouseOver <> OldMouseOver then Invalidate;
  end;
end; { WMMouseMove }

procedure TCustomElScrollBar.ShowHintAt(APosition, X, Y: integer);
var
  HintText: string;
  R: TRect;
  P: TPoint;
  mx,
    my: integer;

begin
  P := ClientToScreen(Point(X, Y));
  HintText := '';
  TriggerScrollHintNeededEvent(APosition, HintText);
  if FHintWnd = nil then
    FHintWnd := TElHintWindow.Create(nil);
{$IFDEF HAS_HTML_RENDER}
  FHintWnd.IsHTML := IsHTML;
{$ENDIF}
  FHintWnd.Canvas.Font.Charset := Font.Charset;
{$IFDEF VCL_4_USED}
  mx := Screen.DesktopWidth + Screen.DesktopLeft;
  my := Screen.DesktopHeight + Screen.DesktopTop;
{$ELSE}
  mx := GetSystemMetrics(SM_CXSCREEN);
  my := GetSystemMetrics(SM_CYSCREEN);
{$ENDIF}
  R := FHintWnd.CalcHintRect(mx, HintText, nil);
  OffsetRect(R, P.X - (R.Right - R.Left + 1), P.Y - (R.Bottom - R.Top + 1));
{$IFDEF VCL_4_USED}
  if R.Left < Screen.DesktopLeft then OffsetRect(R, Screen.DesktopLeft - R.Left, 0);
  if R.Top < Screen.DesktopTop then OffsetRect(R, 0, Screen.DesktopTop - R.Top);
{$ELSE}
  if R.Left < 0 then OffsetRect(R, -R.Left, 0);
  if R.Top < 0 then OffsetRect(R, 0, -R.Top);
{$ENDIF}
  if R.Right > mx then OffsetRect(R, -(R.Right - mx), 0);
  if R.Bottom > my then OffsetRect(R, -(R.Bottom - my), 0);

  FHintWnd.Color := Application.HintColor;
  FHintWnd.ActivateHint(R, HintText);
  { else
  begin
    with FHintWnd do
    begin
      SetBounds(R.Left, R.Top, R.Right - R.Left +1, R.Bottom - R.Top +1);
      FHintWnd.Caption := HintText;
    end;
  end;}
end;
{$WARNINGS OFF}

procedure TCustomElScrollBar.WMLButtonDown(var Msg: TWMLButtonDown); { private }
var
  FHit: TElScrollBarPart;
  ScrollCode: TElScrollCode;
  NewPos: Integer;
  DoChange: boolean;
  AX, AY: integer;
begin
  inherited;
  FHit := FPressedIn;
  with Msg do
    FPressedIn := GetHitTest(XPos, YPos);
  if not FPressed then
  begin
    FOrigPressedIn := FPressedIn;
    FPressed := true;
    case FPressedIn of
      sbpThumb:
        begin
          FPressed := (Page < Max - Min + 1) and (Max - Min <> 0);
          if FPressed then
          begin
            with Msg do
              if Kind = sbHorizontal then
                FOrigCoord := XPos
              else
                FOrigCoord := YPos;
            FOrigPos := Position;
            FThumbOffset := FOrigCoord - GetThumbPos;
            if FShowTrackHint then
            begin
              if Kind = sbHorizontal then
              begin
                AY := -5;
                AX := FThumbPos - 2;
              end
              else
              begin
                AX := -2;
                AY := FThumbPos - 2;
              end;
              ShowHintAt(Position, AX, AY);
            end;
          end;
        end;
      sbpLeftTop:
        begin
          ScrollCode := escPageUp;
          NewPos := ElTools.Max(FMin, FPosition - FPage);
          FPressed := LeftBtnsEnabled;
        end;
      sbpRightBottom:
        begin
          ScrollCode := escPageDown;
          NewPos := ElTools.Min(FMax, FPosition + FPage);
          FPressed := RightBtnsEnabled;
        end;
      sbpLeftArrow:
        begin
          ScrollCode := escLineUp;
          NewPos := ElTools.Max(FMin, FPosition - 1);
          FPressed := LeftBtnsEnabled;
        end;
      sbpRightArrow:
        begin
          ScrollCode := escLineDown;
          NewPos := ElTools.Min(FMax, FPosition + 1);
          FPressed := RightBtnsEnabled;
        end;
      sbpRightSndArrow:
        begin
          case FSecondBtnKind of
            sbkOpposite:
              begin
                ScrollCode := escLineUp;
                NewPos := ElTools.Max(FMin, FPosition - 1);
                FPressed := LeftBtnsEnabled;
              end;
            sbkPage:
              begin
                ScrollCode := escPageDown;
                NewPos := ElTools.Min(FMax, FPosition + FPage);
                FPressed := RightBtnsEnabled;
              end;
            sbkCustom:
              begin
                ScrollCode := escSndLineUp;
                NewPos := FPosition;
              end;
          end;
        end;
      sbpLeftSndArrow:
        begin
          case FSecondBtnKind of
            sbkOpposite:
              begin
                ScrollCode := escLineDown;
                NewPos := ElTools.Min(FMax, FPosition + 1);
                FPressed := LeftBtnsEnabled;
              end;
            sbkPage:
              begin
                ScrollCode := escPageUp;
                NewPos := ElTools.Max(FMin, FPosition - FPage);
                FPressed := RightBtnsEnabled;
              end;
            sbkCustom:
              begin
                ScrollCode := escSndLineDown;
                NewPos := FPosition;
              end;
          end;
        end;
    end;
    if FPressed or (NoDisableButtons and (FPressedIn <> sbpThumb)) then
    begin
      FPressed := true;
      FSaveCapture := GetCapture;
      if FSaveCapture = Handle then FSaveCapture := 0;
      SetCapture(Handle);
      if FPressedIn <> sbpThumb then
      begin
        FPressedPos.x := Msg.XPos;
        FPressedPos.y := Msg.YPos;
        FScrollTimer.Interval := GetKeybTimes(SPI_GETKEYBOARDDELAY);
        FScrollTimer.Enabled := true;
        TriggerScrollEvent(ScrollCode, NewPos, DoChange);
        if DoChange then
        begin
          Position := NewPos;
          TriggerChangeEvent;
        end;
      end;
    end
    else
      FPressedIn := sbpNowhere;
  end;
  if FHit <> FPressedIn then Invalidate;
  inherited;
end; { WMLButtonDown }
{$WARNINGS ON}

procedure TCustomElScrollBar.WMLButtonUp(var Msg: TWMLButtonUp); { private }
var
  NewPos: integer;
  DoChange: boolean;
begin
  inherited;
  if FPressed then
  begin
    FScrollTimer.Enabled := false;
    if FSaveCapture <> 0 then
      SetCapture(FSaveCapture)
    else
      ReleaseCapture;
    FSaveCapture := 0;
    FPressed := false;
    if FTrackPos <> -1 then
    begin
      FTracking := false;
      FTrackPos := -1;
    end;
    
    if FPressedIn = sbpThumb then
    begin
      if FHintWnd <> nil then
      begin
        FHintWnd.Free;
        FHintWnd := nil;
      end;
      NewPos := UpdateThumbPos;
      TriggerScrollEvent(escPosition, NewPos, DoChange);
      if DoChange then
      begin
        Position := NewPos;
        TriggerChangeEvent;
      end;
      FThumbPos := AdjustThumbPos;
    end
    else
      if FPressedIn <> sbpNowhere then
      begin
        NewPos := Position;
        TriggerScrollEvent(escEndScroll, NewPos, DoChange);
        if DoChange then
        begin
          Position := NewPos;
          TriggerChangeEvent;
        end;
        FThumbPos := AdjustThumbPos;
      end;
    FPressedIn := sbpNowhere;
    Invalidate;
  end
  else
  begin
    if FSaveCapture <> 0 then
      SetCapture(FSaveCapture)
    else
      ReleaseCapture;
    FSaveCapture := 0;
  end;
end; { WMLButtonUp }

procedure TCustomElScrollBar.TriggerChangeEvent;
begin
  if (assigned(FOnChange)) then
    FOnChange(Self);
end; { TriggerChangeEvent }

procedure TCustomElScrollBar.TriggerScrollEvent(ScrollCode: TElScrollCode; var ScrollPos: Integer; var DoChange: boolean);
begin
  DoChange := true;
  if (assigned(FOnScroll)) then FOnScroll(Self, ScrollCode, ScrollPos, DoChange);
end; { TriggerScrollEvent }

procedure TCustomElScrollBar.TriggerScrollHintNeededEvent(TrackPosition: integer; var Hint: string);
begin
  if (assigned(FOnScrollHintNeeded)) then
    FOnScrollHintNeeded(Self, TrackPosition, Hint);
end; { TriggerScrollHintNeededEvent }

{$IFNDEF VCL_4_USED}

procedure TCustomElScrollBar.TriggerResizeEvent;
begin
  if (assigned(FOnResize)) then
    FOnResize(Self);
end; { TriggerResizeEvent }
{$ENDIF}

procedure TCustomElScrollBar.WMGetDlgCode(var Msg: TWMGetDlgCode); { private }
begin
  inherited;
  Msg.Result := dlgc_WantArrows; { so we get the arrow keys. }
end; { WMGetDlgCode }

{$WARNINGS OFF}

procedure TCustomElScrollBar.KeyDown(var Key: Word; Shift: TShiftState);
var
  ScrollCode: TElScrollCode;
  NewPos: Integer;
  DoChange: boolean;
begin
  if (Shift = []) then
  begin
    case Key of
      VK_PRIOR:
        begin
          ScrollCode := escPageUp;
          NewPos := ElTools.Max(FMin, FPosition - FPage);
        end;
      VK_NEXT:
        begin
          ScrollCode := escPageDown;
          NewPos := ElTools.Min(FMax, FPosition + FPage);
        end;
      VK_LEFT, VK_UP:
        begin
          ScrollCode := escLineUp;
          NewPos := ElTools.Max(FMin, FPosition - 1);
        end;
      VK_RIGHT, VK_DOWN:
        begin
          ScrollCode := escLineDown;
          NewPos := ElTools.Min(FMax, FPosition + 1);
        end;
      VK_HOME:
        begin
          ScrollCode := escTop;
          NewPos := FMin;
        end;
      VK_END:
        begin
          ScrollCode := escBottom;
          NewPos := FMax;
        end;
    end;
    TriggerScrollEvent(ScrollCode, NewPos, DoChange);
    if DoChange then
    begin
      Position := NewPos;
      TriggerChangeEvent;
    end;
    Key := 0;
  end
  else
    inherited;
end; { KeyDown }
{$WARNINGS ON}

procedure TCustomElScrollBar.WMSize(var Msg: TWMSize); { private }
begin
  inherited;
{$IFNDEF VCL_4_USED}
  Resize;
{$ENDIF}
end; { WMSize }

function TCustomElScrollBar.GetHitTest(X, Y: integer): TElScrollBarPart;
var
  BS: integer;
  CS: integer;
  ATS: integer;
begin
  if Kind = sbHorizontal then
  begin
    if (Y < 0) or (Y > ClientHeight) then
    begin
      result := sbpNowhere;
      exit;
    end;
    CS := ClientWidth;
    if CS > ButtonSize * (GetTopBtns + GetBottomBtns) then
      BS := ButtonSize
    else
      BS := CS div (GetTopBtns + GetBottomBtns);
    if FShowLeftArrows and InRange(0, BS, X) then
    begin
      result := sbpLeftArrow;
      exit;
    end
    else
      if FShowRightArrows and (CS - X < BS) then
      begin
        result := sbpRightArrow;
        exit;
      end;
    if FSecondaryButtons then
    begin
      if FShowLeftArrows and InRange(BS, BS shl 1, X) then
      begin
        result := sbpLeftSndArrow;
        exit;
      end
      else
        if FShowRightArrows and InRange(CS - BS shl 1, CS - BS, X) then
        begin
          result := sbpRightSndArrow;
          exit;
        end;
    end;

    BS := GetThumbPos;
    if BS = -1 then
    begin
      result := sbpNowhere;
      exit;
    end;
    if X < BS then
    begin
      result := sbpLeftTop;
      exit;
    end;
    if FThumbMode = etmFixed then
      ATS := ThumbSize
    else
      ATS := GetAutoThumbSize;
    if X >= BS + ATS then
    begin
      result := sbpRightBottom;
      exit;
    end;
    result := sbpThumb;
  end
  else
  begin
    if (X < 0) or (X > ClientWidth) then
    begin
      result := sbpNowhere;
      exit;
    end;
    CS := ClientHeight;
    if CS > ButtonSize * (GetTopBtns + GetBottomBtns) then
      BS := ButtonSize
    else
      BS := CS div (GetTopBtns + GetBottomBtns);
    if FShowLeftArrows and InRange(0, BS, Y) then
    begin
      result := sbpLeftArrow;
      exit;
    end
    else
      if Self.FShowRightArrows and (CS - Y < BS) then
      begin
        result := sbpRightArrow;
        exit;
      end;
    if SecondaryButtons then
    begin
      if FShowLeftArrows and InRange(BS, BS shl 1, Y) then
      begin
        result := sbpLeftSndArrow;
        exit;
      end
      else
        if FShowRightArrows and InRange(CS - BS shl 1, CS - BS, Y) then
        begin
          result := sbpRightSndArrow;
          exit;
        end;
    end;
    BS := GetThumbPos;
    if BS = -1 then
    begin
      result := sbpNowhere;
      exit;
    end;
    if Y < BS then
    begin
      result := sbpLeftTop;
      exit;
    end;
    if FThumbMode = etmFixed then
      ATS := ThumbSize
    else
      ATS := GetAutoThumbSize;
    if Y >= BS + ATS then
    begin
      result := sbpRightBottom;
      exit;
    end;
    result := sbpThumb;
  end;
end;

{$WARNINGS OFF}

procedure TCustomElScrollBar.OnScrollTimer(Sender: TObject);
var
  ScrollCode: TElScrollCode;
  NewPos: Integer;
  DoChange: boolean;
  CP: TPoint;
  FPage: integer;
begin
  FPage := Self.FPage;
  if FPage = 0 then FPage := 1;
  FScrollTimer.Interval := GetKeybTimes(SPI_GETKEYBOARDSPEED);
  GetCursorPos(CP);
  CP := ScreenToClient(CP);
  DoChange := true;
  case FPressedIn of
    sbpLeftTop:
      begin
        ScrollCode := escPageUp;
        with CP do
          if GetHitTest(X, Y) = sbpLeftTop then
            NewPos := ElTools.Max(FMin, FPosition - FPage)
          else
            NewPos := Position;
      end;
    sbpRightBottom:
      begin
        ScrollCode := escPageDown;
        with CP do
          if GetHitTest(X, Y) = sbpRightBottom then
            NewPos := ElTools.Min(FMax, FPosition + FPage)
          else
            NewPos := Position;
      end;
    sbpLeftArrow:
      begin
        ScrollCode := escLineUp;
        NewPos := ElTools.Max(FMin, FPosition - 1);
      end;
    sbpRightArrow:
      begin
        ScrollCode := escLineDown;
        NewPos := ElTools.Min(FMax, FPosition + 1);
      end;
    sbpRightSndArrow:
      begin
        case FSecondBtnKind of
          sbkOpposite:
            begin
              ScrollCode := escLineUp;
              NewPos := ElTools.Max(FMin, FPosition - 1);
            end;
          sbkPage:
            begin
              ScrollCode := escPageDown;
              NewPos := ElTools.Min(FMax, FPosition + FPage);
            end;
          sbkCustom:
            begin
              ScrollCode := escSndLineUp;
              NewPos := FPosition;
            end;
        end;
      end;
    sbpLeftSndArrow:
      begin
        case FSecondBtnKind of
          sbkOpposite:
            begin
              ScrollCode := escLineDown;
              NewPos := ElTools.Min(FMax, FPosition + 1);
            end;
          sbkPage:
            begin
              ScrollCode := escPageUp;
              NewPos := ElTools.Max(FMin, FPosition - FPage);
            end;
          sbkCustom:
            begin
              ScrollCode := escSndLineDown;
              NewPos := FPosition;
            end;
        end;
      end;
  end;
  TriggerScrollEvent(ScrollCode, NewPos, DoChange);
  if DoChange then Position := NewPos;
end;
{$WARNINGS ON}

function TCustomElScrollBar.GetTopBtns: integer;
begin
  if not FShowLeftArrows then
    result := 0
  else
    if Self.FSecondaryButtons then
      result := 2
    else
      result := 1;
end;

function TCustomElScrollBar.GetBottomBtns: integer;
begin
  if not FShowRightArrows then
    result := 0
  else
    if Self.FSecondaryButtons then
      result := 2
    else
      result := 1;
end;

function TCustomElScrollBar.GetThumbPos: integer;
begin
  result := FThumbPos;
end;

function TCustomElScrollBar.UpdateThumbPos: integer;
var
  CS: integer;
  ATS: integer;
begin
  if Kind = sbHorizontal then
    CS := ClientWidth
  else
    CS := ClientHeight;
  if FThumbMode = etmFixed then
    ATS := ThumbSize
  else
    ATS := GetAutoThumbSize;
  result := MulDiv(FThumbPos - ButtonSize * GetTopBtns, (Max - Min + 1) - ElTools.Min((Page), (Max - Min + 1)), (CS - ButtonSize * (GetTopBtns + GetBottomBtns) - ATS));
end;

function TCustomElScrollBar.AdjustThumbPos: integer;
var
  CS: integer;
  ATS: integer;
  XX: integer;
  TB,
    BB: integer;
begin
  if Kind = sbHorizontal then
    CS := ClientWidth
  else
    CS := ClientHeight;
  if FThumbMode = etmFixed then
    ATS := ThumbSize
  else
    ATS := GetAutoThumbSize;
  TB := GetTopBtns;
  BB := GetBottomBtns;
  if (CS > (ButtonSize * (TB + BB) + ATS)) and (Max > Min - 1) then
  begin
    XX := ElTools.Min(Max + 1 - Page, Position - Min);
    result := ButtonSize * TB
      + ElTools.Max(0, MulDiv((CS - ButtonSize * (TB + BB) - ATS),
      XX, (Max - Min + 1) - ElTools.Min((Page), (Max - Min + 1))));
  end
  else
    result := ButtonSize * TB;
end;

function TCustomElScrollBar.GetButtonSize: integer;
var
  CS: integer;
  AButtonSize : integer;
begin
  if FUseSystemMetrics then
  begin
    if Kind = sbHorizontal then
      AButtonSize := GetSystemMetrics(SM_CXHSCROLL)
    else
      AButtonSize := GetSystemMetrics(SM_CYVSCROLL);
  end
  else
    AButtonSize := FButtonSize;
  if Kind = sbHorizontal then
    CS := ClientWidth
  else
    CS := ClientHeight;
  if CS < AButtonSize * (GetTopBtns + GetBottomBtns) then
    result := CS div (GetTopBtns + GetBottomBtns)
  else
    result := AButtonSize;
end;

function TCustomElScrollBar.GetAutoThumbSize: integer;
var
  CS: integer;
  FW: integer;
  TB,
    BB,
    BS: integer;
begin
  if Kind = sbHorizontal then
    CS := ClientWidth
  else
    CS := ClientHeight;
  TB := GetTopBtns;
  BB := GetBottomBtns;
  BS := ButtonSize;
  FW := CS - (ButtonSize * (TB + BB));
  if FW < 0 then
    result := 0
  else
  begin
    if (FPage = 0) then
    begin
      if (Max < Min + 1) or (FPage > (Max - Min)) then
        result := (CS - BS * (TB + BB))
      else
        if Kind = sbHorizontal then
          result := GetSystemMetrics(SM_CXHTHUMB)
        else
          result := GetSystemMetrics(SM_CYVTHUMB);
    end
    else
    begin
      if (Max < Min + 1) or (FPage > (Max - Min)) then
        result := (CS - BS * (TB + BB))
      else
        result := MulDiv({(Max - Min + 1) -} ElTools.Min((Page), (Max - Min + 1)), (CS - BS * (TB + BB)), (Max - Min + 1));
    end;
    if Result < FMinThumbSize then Result := FMinThumbSize;
    if Result > FW then result := 0;
  end;
end;

procedure TCustomElScrollBar.SetButtonSize(newValue: Integer);
{ Sets data member FButtonSize to newValue. }
begin
  if (FButtonSize <> newValue) and (newValue > 0) then
  begin

    if (not HandleAllocated) or (((kind = sbHorizontal) and (newValue shl 1 <= ClientWidth)) or ((kind = sbVertical) and (newValue shl 1 <= ClientHeight))) then
    begin
      FButtonSize := newValue;
      if (not (csLoading in ComponentState)) and HandleAllocated then
      begin
        FThumbPos := AdjustThumbPos;
        Invalidate;
      end;
    end;
  end; { if }
end; { SetButtonSize }

procedure TCustomElScrollBar.SetThumbMode(newValue: TElScrollThumbMode);
{ Sets data member FThumbMode to newValue. }
begin
  if (FThumbMode <> newValue) then
  begin
    FThumbMode := newValue;
    if UseSystemMetrics and (ThumbMode = etmFixed) then
    begin
      if Kind = sbHorizontal then
        ThumbSize := GetSystemMetrics(SM_CXHTHUMB)
      else
        ThumbSize := GetSystemMetrics(SM_CYVTHUMB);
    end;
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetThumbMode }

procedure TCustomElScrollBar.SetThumbSize(newValue: Integer);
begin
  if (FThumbSize <> newValue) and (newValue > 0) then
  begin
    FThumbSize := newValue;
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetThumbSize }

procedure TCustomElScrollBar.SetMinThumbSize(newValue: Integer);
{ Sets data member FMinThumbSize to newValue. }
begin
  if (FMinThumbSize <> newValue) and (newValue > 0) then
  begin
    FMinThumbSize := newValue;
    if (ThumbMode = etmAuto) and (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetMinThumbSize }

procedure TCustomElScrollBar.SetPage(newValue: Integer);
{ Sets data member FPage to newValue. }
begin
  DoSetPage(newValue, not (csLoading in ComponentState) and HandleAllocated);
end; { SetPage }

procedure TCustomElScrollBar.SetSecondaryButtons(newValue: Boolean);
{ Sets data member FSecondaryButtons to newValue. }
begin
  if (FSecondaryButtons <> newValue) then
  begin
    FSecondaryButtons := newValue;
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetSecondaryButtons }

procedure TCustomElScrollBar.SetSecondBtnKind(newValue: TElSecButtonsKind);
begin
  if newValue <> FSecondBtnKind then
  begin
    FSecondBtnKind := newValue;
    if FSecondaryButtons and (not (csLoading in ComponentState)) and HandleAllocated then Invalidate;
  end;
end;

procedure TCustomElScrollBar.SetOwnerDraw(newValue: Boolean);
{ Sets data member FOwnerDraw to newValue. }
begin
  if (FOwnerDraw <> newValue) then
  begin
    FOwnerDraw := newValue;
    Invalidate;
  end; { if }
end; { SetOwnerDraw }

procedure TCustomElScrollBar.Loaded; { protected }
begin
  inherited;
  if FMin >= FMax then FMax := FMin;
  FPage := ElTools.Min(FPage, FMax - FMin + 1);
  if FPosition < FMin then
    FPosition := FMin
  else
    if FPosition > FMax then FPosition := FMax;
  if UseSystemMetrics then
  begin
    FUseSystemMetrics := false;
    UseSystemMetrics := true;
  end;
  FThumbPos := AdjustThumbPos;
  if HandleAllocated then Invalidate;
end; { Loaded }

type
  PScrollInfo = ^TScrollInfo;

procedure TCustomElScrollBar.SBMSetScrollInfo(var Msg: TMessage); { private }
var
  ScrollInfo: PScrollInfo;
  Redraw: BOOL;
begin
  with Msg do
  begin
    ScrollInfo := PScrollInfo(lParam);
    Redraw := BOOL(wParam);
  end;
  if ScrollInfo.cbSize < sizeof(TScrollInfo) then
  begin
    Msg.Result := Position;
    exit;
  end;
  with ScrollInfo^ do
  begin
    if (fMask and SIF_RANGE) <> 0 then
    begin
      if (nMin <= nMax) then
      begin
        if (fMask and SIF_POS) <> 0 then
        begin
          if not InRange(nMin, nMax, nPos) then nPos := nMax;
          begin
            FPosition := nPos;
            FMin := nMin;
            FMax := nMax;

            if (fMask and SIF_PAGE) <> 0 then
            begin
              FPage := nPage;
            end;
            FThumbPos := AdjustThumbPos;
          end;
        end
        else
        begin
          if InRange(nMin, nMax, FPosition) then
          begin
            FMin := nMin;
            FMax := nMax;
            if (fMask and SIF_PAGE) <> 0 then
            begin
              {if nPage < (FMax - FMin) then } FPage := nPage;
            end;
          end;
        end;
        FThumbPos := AdjustThumbPos;
        if Redraw then Invalidate;
      end;
    end
    else
      if (fMask and SIF_POS) <> 0 then
      begin
        if InRange(FMin, FMax, nPos) then
        begin
          if (fMask and SIF_PAGE) <> 0 then
          begin
          {if nPage < (FMax - FMin) then } FPage := nPage;
          end;
          FPosition := nPos;
          FThumbPos := AdjustThumbPos;
          if Redraw then Invalidate;
        end;
      end
      else
        if (fMask and SIF_PAGE) <> 0 then
        begin
      // if nPage < (FMax - FMin) then
          begin
            FPage := nPage;
            FThumbPos := AdjustThumbPos;
            if Redraw then Invalidate;
          end;
        end;
  end;
  Msg.Result := Position;
end; { SBMSetScrollInfo }

procedure TCustomElScrollBar.SBMGetScrollInfo(var Msg: TMessage); { private }
var
  ScrollInfo: PScrollInfo;
begin
  ScrollInfo := PScrollInfo(Msg.lParam);
  if ScrollInfo.cbSize < sizeof(TScrollInfo) then
  begin
    Msg.Result := 0;
    exit;
  end;
  with ScrollInfo^ do
  begin
    if (fMask and SIF_PAGE) <> 0 then nPage := FPage;
    if (fMask and SIF_POS) <> 0 then nPos := FPosition;
    if (fMask and SIF_TRACKPOS) <> 0 then nTrackPos := UpdateThumbPos;
    if (fMask and SIF_RANGE) <> 0 then
    begin
      nMin := FMin;
      nMax := FMax;
    end;
  end; { with }
  Msg.Result := 1;
end; { SBMGetScrollInfo }

procedure TCustomElScrollBar.SetNoDisableButtons(newValue: Boolean);
{ Sets data member FNoDisableButtons to newValue. }
begin
  if (FNoDisableButtons <> newValue) then
  begin
    FNoDisableButtons := newValue;
    Invalidate;
  end; { if }
end; { SetNoDisableButtons }

procedure TCustomElScrollBar.UpdateScrollingRegion;
var
  R: TRect;
begin
  R := ClientRect;
  if Kind = sbHorizontal then
  begin
    R.Left := R.Left + ButtonSize * GetTopBtns;
    R.Right := R.Right - ButtonSize * GetBottomBtns;
  end
  else
  begin
    R.Top := R.Top + ButtonSize * GetTopBtns;
    R.Bottom := R.Bottom - ButtonSize * GetBottomBtns;
  end;
  InvalidateRect(Handle, @R, false);
  Update;
end;

procedure TCustomElScrollBar.CreateWnd; { protected }
begin
  inherited;
  FThumbPos := AdjustThumbPos;
end; { CreateWnd }

procedure TCustomElScrollBar.WMPaint(var Msg: TWMPaint); { private }
var
  DC, MemDC: HDC;
  MemBitmap, OldBitmap: HBITMAP;
  PS: TPaintStruct;
  R: TRect;
begin
  if (Msg.DC <> 0) then
    PaintHandler(Msg)
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
      if IsRectEmpty(R) then R := ClientRect;
      InvalidateRect(MemDC, @R, false);
      Perform(WM_ERASEBKGND, MemDC, MemDC);
      Msg.DC := MemDC;
      WMPaint(Msg);
      Msg.DC := 0;
      GetClipBox(DC, R);
      if IsRectEmpty(R) then R := ClientRect;
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

function TCustomElScrollBar.GetIsDesigning: boolean;
begin
  result := csDesigning in ComponentState;
end;

procedure TCustomElScrollBar.SetIsDesigning(newValue: Boolean);
begin
  SetDesigning(newValue);
end; { SetIsDesigning }

procedure TCustomElScrollBar.SetBlendBackground(newValue: boolean);
begin
  if (FBlendBackground <> newValue) then
  begin
    FBlendBackground := newValue;
    if HandleAllocated then
      Invalidate;
  end; { if }
end; { SetBlendBackground }

procedure TCustomElScrollBar.WMSysColorChange(var Msg: TWMSysColorChange); { private }
begin
  inherited;
  RebuildBackground;
end; { WMSysColorChange }

procedure TCustomElScrollBar.SetShowLeftArrows(newValue: Boolean);
{ Sets data member FShowLeftArrows to newValue. }
begin
  if (FShowLeftArrows <> newValue) then
  begin
    FShowLeftArrows := newValue;
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetShowLeftArrows }

procedure TCustomElScrollBar.SetShowRightArrows(newValue: Boolean);
{ Sets data member FShowRightArrows to newValue. }
begin
  if (FShowRightArrows <> newValue) then
  begin
    FShowRightArrows := newValue;
    if (not (csLoading in ComponentState)) and HandleAllocated then
    begin
      FThumbPos := AdjustThumbPos;
      Invalidate;
    end;
  end; { if }
end; { SetShowRightArrows }

procedure TCustomElScrollBar.SetUseSystemMetrics(value: boolean);
begin
  if FUseSystemMetrics <> value then
  begin
    FUseSystemMetrics := value;
    if (csLoading in ComponentState) or
       ((Owner <> nil) and (csLoading in Owner.ComponentState)) then exit;
    if Value then
    begin
      if Kind = sbHorizontal then
      begin
        ButtonSize := GetSystemMetrics(SM_CXHSCROLL);
        Height := GetSystemMetrics(SM_CXVSCROLL);
      end
      else
      begin
        ButtonSize := GetSystemMetrics(SM_CYVSCROLL);
        Width := GetSystemMetrics(SM_CYHSCROLL);
      end;
      if HandleAllocated then
      begin
        FThumbPos := AdjustThumbPos;
        Invalidate;
      end;
    end
    else
      if HandleAllocated then
      begin
        FThumbPos := AdjustThumbPos;
        Invalidate;
      end;
  end;
end;

procedure TCustomElScrollBar.SetNoSunkenThumb(newValue: Boolean);
{ Sets data member FNoSunkenThumb to newValue. }
begin
  if (FNoSunkenThumb <> newValue) then
  begin
    FNoSunkenThumb := newValue;
    if FPressedIn = sbpThumb then Invalidate;
  end; { if }
end;

{$IFDEF ELPACK_COMPLETE}

procedure TCustomElScrollBar.ImageFormChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TCustomElScrollBar.SetImageForm(newValue: TElImageForm);
{ Sets data member FImageForm to newValue. }
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
end; { SetImageForm }
{$ENDIF}

procedure TCustomElScrollBar.Notification(AComponent: TComponent; Operation: TOperation); { protected }
begin
  inherited;
{$IFDEF ELPACK_COMPLETE}
  if AComponent = FImgForm then
  begin
    ImageForm := nil;
    Invalidate;
  end;
{$ENDIF}
end; { Notification }

procedure TCustomElScrollBar.SetArrowColor(newValue: TColor);
{ Sets data member FArrowColor to newValue. }
begin
  if (FArrowColor <> newValue) then
  begin
    FArrowColor := newValue;
    Invalidate;
  end; { if }
end; { SetArrowColor }

procedure TCustomElScrollBar.SetArrowHotTrackColor(newValue: TColor);
{ Sets data member FArrowHotTrackColor to newValue. }
begin
  if (FArrowHotTrackColor <> newValue) then
  begin
    FArrowHotTrackColor := newValue;
    Invalidate;
  end; { if }
end; { SetArrowHotTrackColor }

procedure TCustomElScrollBar.SetDrawFrames(newValue: Boolean);
{ Sets data member FDrawFrames to newValue. }
begin
  if (FDrawFrames <> newValue) then
  begin
    FDrawFrames := newValue;
    if not newValue then FDrawArrowFrames := False;
    Invalidate;
  end; { if }
end; { SetDrawFrames }

procedure TCustomElScrollBar.SetThinFrames(newValue: Boolean);
{ Sets data member FThinFrames to newValue. }
begin
  if (FThinFrames <> newValue) then
  begin
    FThinFrames := newValue;
    Invalidate;
  end; { if }
end; { SetThinFrames }

procedure TCustomElScrollBar.CMColorChanged(var Msg: TMessage); { private }
begin
  inherited;
  if FBlendBackground then
    RebuildBackground;
  Invalidate;
end; { CMColorChanged }

destructor TCustomElScrollBar.Destroy;
begin
  FBlendBitmap.Free;
  FBlendBitmap := nil;
  FScrollTimer.Free;
{$IFDEF ELPACK_COMPLETE}
  ImageForm := nil;
  FImgFormChLink.Free;
{$ENDIF}
  inherited;
end; { Destroy }

constructor TCustomElScrollBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := False;
  Color := clBtnFace;
  FScrollTimer := TTimer.Create(nil);
  FScrollTimer.Enabled := false;
  FScrollTimer.OnTimer := OnScrollTimer;
  Width := 121;
  ControlStyle := [csFramed];
  Height := GetSystemMetrics(SM_CYHSCROLL);
  TabStop := True;
  FKind := sbHorizontal;
  FFlat := true;
  FMinThumbSize := 4;
  FThumbMode := etmAuto; 
  FPosition := 0;
  FMin := 0;
  FMax := 100;
  FPage := 1;
  FTrackPos := -1;
  Ctl3D := false;
  //FButtonSize := GetSystemMetrics(SM_CYHSCROLL);
  BlendBackground := true;
  FShowLeftArrows := True;
  FShowRightArrows := true;
  FChangeColorsOnScroll := True;

  UseSystemMetrics := true;
  FArrowColor := clBtnText;
  FArrowHotTrackColor := clHighlight;

  FHintColor := clInfoBk;
  FHintTextColor := clInfoText;

  FSysBkColor := true;

  FDrawFrames := true;
  FDrawArrowFrames := true;
  FDrawBars := true;
  FBarOffset := 2;
  FBarColor := clBtnShadow;
{$IFDEF ELPACK_COMPLETE}
  FImgFormChLink := TImgFormChangeLink.Create;
  FImgFormChLink.OnChange := ImageFormChange;
{$ENDIF}
  FBlendBitmap := TBitmap.Create;
  FBlendBitmap.Width := 8;
  FBlendBitmap.Height := 8;
  RebuildBackground;
end; { Create }

procedure TCustomElScrollBar.EndScroll;
var NewPos   : integer;
    DoChange : boolean;
begin
  FScrollTimer.Enabled := false;
  if FSaveCapture <> 0 then SetCapture(FSaveCapture) else ReleaseCapture;
  FSaveCapture := 0;
  FPressed := false;
  if FPressedIn = sbpThumb then
  begin
    if FHintWnd <> nil then
    begin
      FHintWnd.Free;
      FHintWnd := nil;
    end;
    NewPos := UpdateThumbPos;
    TriggerScrollEvent(escPosition, NewPos, DoChange);
    if DoChange then
    begin
      Position := NewPos;
      TriggerChangeEvent;
    end;
    FThumbPos := AdjustThumbPos;
  end else
  if FPressedIn <> sbpNowhere then
  begin
    NewPos := Position;
    TriggerScrollEvent(escEndScroll, NewPos, DoChange);
    if DoChange then
    begin
      Position := NewPos;
      TriggerChangeEvent;
    end;
    FThumbPos := AdjustThumbPos;
  end;
  FPressedIn := sbpNowhere;
  Invalidate;
end;

function TCustomElScrollBar.RightBtnsEnabled: Boolean;
begin
  if FAltDisablingArrows then
  begin
    Result := (Position < FMax - FPage + 1) and (Page <= FMax - FMin);
  end
  else
    Result := (Position < FMax) and (Page <= FMax - FMin);
end;

function TCustomElScrollBar.LeftBtnsEnabled: Boolean;
begin
  Result := (Position > 0) and (Page <= FMax - FMin);
end;

procedure TCustomElScrollBar.CreateWindowHandle(const Params : TCreateParams);
begin
  inherited;
end;

procedure TCustomElScrollBar.SetSysBkColor(Value: boolean);
begin
  if FSysBkColor <> Value then
  begin
    FSysBkColor := Value;
    Invalidate;
  end;
end;

{ Exposed properties' Read/Write methods: }

procedure TCustomElScrollBar.RebuildBackground;
var i, j : integer;
begin
  with FBlendBitmap.Canvas do
  begin
    for i := 0 to 7 do
      for j := 0 to 7 do
        if ((j xor i) and 1) <> 0 then
          Pixels[i, j] := Color
        else
          Pixels[i, j] := LighterColor;
  end;
end;

procedure TCustomElScrollBar.SetAltDisablingArrows(const Value: Boolean);
begin
  if FAltDisablingArrows <> Value then
  begin
    FAltDisablingArrows := Value;
    Invalidate;
  end;
end;

function TCustomElScrollBar.GetThumbSize: Integer;
begin
  Result := FThumbSize;
  if FUseSystemMetrics then
  begin
    if Kind = sbHorizontal then
    begin
      if ThumbMode = etmFixed then
        result := GetSystemMetrics(SM_CXHTHUMB);
    end
    else
    begin
      if ThumbMode = etmFixed then
        result := GetSystemMetrics(SM_CYVTHUMB);
    end;
  end;
end;

procedure TCustomElScrollBar.SetDrawArrowFrames(const Value: Boolean);
begin
  if (FDrawArrowFrames <> Value) then
  begin
    FDrawArrowFrames := Value;
    Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.SetDrawBars(const Value: Boolean);
begin
  if (FDrawBars <> Value) then
  begin
    FDrawBars := Value;
    Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.SetBarColor(const Value: TColor);
begin
  if (FBarColor <> Value) then
  begin
    FBarColor := Value;
    Invalidate;
  end; { if }
end;

procedure TCustomElScrollBar.SetBarOffset(const Value: Cardinal);
begin
  if (FBarOffset <> Value) then
  begin
    FBarOffset := Value;
    Invalidate;
  end; { if }
end;

procedure TElScrollBarStyles.SetActiveFlat(newValue: Boolean);
begin
  FElScrollBar.ActiveFlat := newValue;
end; { SetActiveFlat }

function TElScrollBarStyles.GetActiveFlat: Boolean;
{ Returns the ActiveFlat property from the FElScrollBar subcomponent. }
begin
  GetActiveFlat := FElScrollBar.ActiveFlat;
end; { GetActiveFlat }

procedure TElScrollBarStyles.SetColor(newValue: TColor);
{ Sets the FElScrollBar subcomponent's Color property to newValue. }
begin
  FElScrollBar.Color := newValue;
end; { SetFElScrollBarColor }

function TElScrollBarStyles.GetColor: TColor;
{ Returns the Color property from the FElScrollBar subcomponent. }
begin
  GetColor := FElScrollBar.Color;
end; { GetFElScrollBarColor }

procedure TElScrollBarStyles.SetFlat(newValue: Boolean);
{ Sets the FElScrollBar subcomponent's Flat property to newValue. }
begin
  FElScrollBar.Flat := newValue;
end; { SetFlat }

function TElScrollBarStyles.GetFlat: Boolean;
{ Returns the Flat property from the FElScrollBar subcomponent. }
begin
  GetFlat := FElScrollBar.Flat;
end; { GetFlat }

procedure TElScrollBarStyles.SetMinThumbSize(newValue: Integer);
{ Sets the FElScrollBar subcomponent's MinThumbSize property to newValue. }
begin
  FElScrollBar.MinThumbSize := newValue;
end; { SetMinThumbSize }

function TElScrollBarStyles.GetMinThumbSize: Integer;
{ Returns the MinThumbSize property from the FElScrollBar subcomponent. }
begin
  GetMinThumbSize := FElScrollBar.MinThumbSize;
end; { GetMinThumbSize }

procedure TElScrollBarStyles.SetOwnerDraw(newValue: Boolean);
{ Sets the FElScrollBar subcomponent's OwnerDraw property to newValue. }
begin
  FElScrollBar.OwnerDraw := newValue;
end; { SetOwnerDraw }

function TElScrollBarStyles.GetOwnerDraw: Boolean;
{ Returns the OwnerDraw property from the FElScrollBar subcomponent. }
begin
  GetOwnerDraw := FElScrollBar.OwnerDraw;
end; { GetOwnerDraw }

procedure TElScrollBarStyles.SetSecondaryButtons(newValue: Boolean);
{ Sets the FElScrollBar subcomponent's SecondaryButtons property to newValue. }
begin
  FElScrollBar.SecondaryButtons := newValue;
end; { SetSecondaryButtons }

function TElScrollBarStyles.GetSecondaryButtons: Boolean;
{ Returns the SecondaryButtons property from the FElScrollBar subcomponent. }
begin
  GetSecondaryButtons := FElScrollBar.SecondaryButtons;
end; { GetSecondaryButtons }

procedure TElScrollBarStyles.SetSecondBtnKind(newValue: TElSecButtonsKind);
{ Sets the FElScrollBar subcomponent's SecondBtnKind property to newValue. }
begin
  FElScrollBar.SecondBtnKind := newValue;
end; { SetSecondBtnKind }

function TElScrollBarStyles.GetSecondBtnKind: TElSecButtonsKind;
{ Returns the SecondBtnKind property from the FElScrollBar subcomponent. }
begin
  GetSecondBtnKind := FElScrollBar.SecondBtnKind;
end; { GetSecondBtnKind }

procedure TElScrollBarStyles.SetShowTrackHint(newValue: Boolean);
{ Sets the FElScrollBar subcomponent's ShowTrackHint property to newValue. }
begin
  FElScrollBar.ShowTrackHint := newValue;
end; { SetShowTrackHint }

function TElScrollBarStyles.GetShowTrackHint: Boolean;
{ Returns the ShowTrackHint property from the FElScrollBar subcomponent. }
begin
  GetShowTrackHint := FElScrollBar.ShowTrackHint;
end; { GetShowTrackHint }

procedure TElScrollBarStyles.SetThumbMode(newValue: TElScrollThumbMode);
{ Sets the FElScrollBar subcomponent's ThumbMode property to newValue. }
begin
  FElScrollBar.ThumbMode := newValue;
end; { SetThumbMode }

function TElScrollBarStyles.GetThumbMode: TElScrollThumbMode;
{ Returns the ThumbMode property from the FElScrollBar subcomponent. }
begin
  GetThumbMode := FElScrollBar.ThumbMode;
end; { GetThumbMode }

procedure TElScrollBarStyles.SetThumbSize(newValue: Integer);
{ Sets the FElScrollBar subcomponent's ThumbSize property to newValue. }
begin
  FElScrollBar.ThumbSize := newValue;
end; { SetThumbSize }

function TElScrollBarStyles.GetThumbSize: Integer;
{ Returns the ThumbSize property from the FElScrollBar subcomponent. }
begin
  GetThumbSize := FElScrollBar.ThumbSize;
end; { GetThumbSize }

resourcestring
  esbsNoControl = 'No scrollbar specified when attempting to create TElScrollBarStyles instance';

procedure TElScrollBarStyles.Assign(Source: TPersistent);
begin
  if Source is TElScrollBarStyles then
    with TElScrollBarStyles(Source) do
    begin
      Self.ActiveFlat := ActiveFlat;
      Self.BlendBackground := BlendBackground;
      Self.Color := Color;
      Self.Flat := Flat;
      Self.MinThumbSize := MinThumbSize;
      Self.OwnerDraw := OwnerDraw;
      Self.SecondaryButtons := SecondaryButtons;
      Self.SecondBtnKind := SecondBtnKind;
      Self.ShowTrackHint := ShowTrackHint;
      Self.ThumbMode := ThumbMode;
      Self.ThumbSize := ThumbSize;
    end
  else
    inherited;
end;

function TElScrollBarStyles.GetBlendBackground: Boolean;
{ Returns the value of data member FBlendBackground. }
begin
  result := FElScrollBar.BlendBackground;
end; { GetBlendBackground }

procedure TElScrollBarStyles.SetBlendBackground(newValue: Boolean);
{ Sets data member FBlendBackground to newValue. }
begin
  FElScrollBar.BlendBackground := newValue;
end; { SetBlendBackground }

function TElScrollBarStyles.GetUseSystemMetrics: boolean;
begin
  result := FElScrollBar.UseSystemMetrics;
end;

procedure TElScrollBarStyles.SetUseSystemMetrics(Value: boolean);
begin
  if FElScrollBar.UseSystemMetrics <> Value then
  begin
    FElScrollBar.UseSystemMetrics := Value;
    if Assigned(FOnChange) then FOnChange(Self);
  end;
end;

function TElScrollBarStyles.GetWidth : Integer;
begin
  if FElScrollBar.FKind = sbHorizontal then
    result := FElScrollBar.Height
  else
    result := FElScrollBar.Width;
end; { GetWidth }

procedure TElScrollBarStyles.SetWidth(newValue : Integer);
begin
  if newValue = 0 then
  begin
    if FElScrollBar.FKind = sbHorizontal then
      FElScrollBar.Height := GetSystemMetrics(SM_CYHSCROLL)
    else
      FElScrollBar.Width := GetSystemMetrics(SM_CXVSCROLL);
  end
  else
  begin
    if FElScrollBar.FKind = sbHorizontal then
      FElScrollBar.Height := newValue
    else
      FElScrollBar.Width := newValue;
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end; { SetWidth }

function TElScrollBarStyles.GetShowLeftArrows: Boolean;
{ Returns the value of data member FShowLeftArrows. }
begin
  result := FElScrollBar.ShowLeftArrows;
end; { GetShowLeftArrows }

procedure TElScrollBarStyles.SetShowLeftArrows(newValue: Boolean);
{ Sets data member FShowLeftArrows to newValue. }
begin
  FElScrollBar.ShowLeftArrows := newValue;
end; { SetShowLeftArrows }

function TElScrollBarStyles.GetShowRightArrows: Boolean;
{ Returns the value of data member FShowRightArrows. }
begin
  result := FElScrollBar.ShowRightArrows;
end; { GetShowRightArrows }

procedure TElScrollBarStyles.SetShowRightArrows(newValue: Boolean);
{ Sets data member FShowRightArrows to newValue. }
begin
  FElScrollBar.ShowRightArrows := newValue;
end; { SetShowRightArrows }

function TElScrollBarStyles.GetNoSunkenThumb: Boolean;
{ Returns the value of data member FNoSunkenThumb. }
begin
  result := FElScrollBar.NoSunkenThumb;
end; { GetNoSunkenThumb }

procedure TElScrollBarStyles.SetNoSunkenThumb(newValue: Boolean);
{ Sets data member FNoSunkenThumb to newValue. }
begin
  FElScrollBar.NoSunkenThumb := newValue;
end; { SetNoSunkenThumb }

function TElScrollBarStyles.GetNoDisableButtons: Boolean;
begin
  result := FElScrollBar.NoDisableButtons;
end;

procedure TElScrollBarStyles.SetNoDisableButtons(newValue: Boolean);
begin
  FElScrollBar.NoDisableButtons := newValue;
end; { SetNoDisableButtons }

function TElScrollBarStyles.GetButtonSize: integer;
begin
  result := FElScrollBar.ButtonSize;
end;

procedure TElScrollBarStyles.SetButtonSize(newValue: Integer);
begin
  FElScrollBar.ButtonSize := newValue;
end;

function TElScrollBarStyles.GetArrowColor: TColor;
{ Returns the value for the ArrowColor property. }
begin
  Result := FElScrollBar.ArrowColor;
end; { GetArrowColor }

procedure TElScrollBarStyles.SetArrowColor(newValue: TColor);
{ Sets the value for the ArrowColor property. }
begin
  FElScrollBar.ArrowColor := newValue;
end; { SetArrowColor }

function TElScrollBarStyles.GetArrowHotTrackColor: TColor;
{ Returns the value for the ArrowHotTrackColor property. }
begin
  result := FElScrollBar.ArrowHotTrackColor;
end; { GetArrowHotTrackColor }

procedure TElScrollBarStyles.SetArrowHotTrackColor(newValue: TColor);
{ Sets the value for the ArrowHotTrackColor property. }
begin
  FElScrollBar.ArrowHotTrackColor := newValue;
end; { SetArrowHotTrackColor }

function TElScrollBarStyles.GetDrawFrames: Boolean;
{ Returns the value for the DrawFrames property. }
begin
  result := FElScrollBar.Drawframes;
end; { GetDrawFrames }

procedure TElScrollBarStyles.SetDrawFrames(newValue: Boolean);
{ Sets the value for the DrawFrames property. }
begin
  FElScrollBar.Drawframes := newValue;
end; { SetDrawFrames }

function TElScrollBarStyles.GetThinFrames: Boolean;
{ Returns the value for the ThinFrames property. }
begin
  result := FElScrollBar.ThinFrames;
end; { GetThinFrames }

procedure TElScrollBarStyles.SetThinFrames(newValue: Boolean);
{ Sets the value for the ThinFrames property. }
begin
  FElScrollBar.ThinFrames := newValue;
end; { SetThinFrames }

{$IFDEF ELPACK_COMPLETE}

function TElScrollBarStyles.GetImageForm: TElImageForm;
{ Returns the value for the ImageForm property. }
begin
  Result := FElScrollBar.ImageForm;
end; { GetImageForm }

procedure TElScrollBarStyles.SetImageForm(newValue: TElImageForm);
{ Sets the value for the ImageForm property. }
begin
  FElScrollBar.ImageForm := newValue;
end; { SetImageForm }
{$ENDIF}

constructor TElScrollBarStyles.Create(AControl: TCustomElScrollBar);
{ Creates an object of type TElScrollBarStyles, and initializes properties. }
begin
  if AControl = nil then raise Exception.Create(esbsNoControl);
  inherited Create;
  FElScrollBar := AControl;
  UseSystemMetrics := true;
end; { Create }

procedure TElScrollBarStyles.SetHintColor(Value: TColor);
begin
  FElScrollBar.HintColor := Value;
end;

function TElScrollBarStyles.GetHintColor: TColor;
begin
  result := FElScrollBar.HintColor;
end;

procedure TElScrollBarStyles.SetHintTextColor(Value: TColor);
begin
  FElScrollBar.HintTextColor := Value;
end;

function TElScrollBarStyles.GetHintTextColor: TColor;
begin
  result := FElScrollBar.HintTextColor;
end;

function TElScrollBarStyles.GetSysBkColor: boolean;
begin
  Result := FElScrollBar.SystemBkColor;
end;

procedure TElScrollBarStyles.SetSysBkColor(Value: boolean);
begin
  FElScrollBar.SystemBkColor := Value;
end;

function TElScrollBarStyles.GetDrawArrowFrames: Boolean;
begin
  Result := FElScrollBar.DrawArrowFrames;
end;

function TElScrollBarStyles.GetDrawBars: Boolean;
begin
  Result := FElScrollBar.DrawBars;
end;

function TElScrollBarStyles.GetBarColor: TColor;
begin
  Result := FElScrollBar.BarColor;
end;

function TElScrollBarStyles.GetBarOffset: Cardinal;
begin
  Result := FElScrollBar.BarOffset;
end;

procedure TElScrollBarStyles.SetDrawBars(const Value: Boolean);
begin
  FElScrollBar.DrawBars := Value;
end;

procedure TElScrollBarStyles.SetBarColor(const Value: TColor);
begin
  FElScrollBar.BarColor := Value;
end;

procedure TElScrollBarStyles.SetBarOffset(const Value: Cardinal);
begin
  FElScrollBar.BarOffset := Value;
end;

procedure TElScrollBarStyles.SetDrawArrowFrames(const Value: Boolean);
begin
  FElScrollBar.DrawArrowFrames := Value;
end;
initialization
  RegisterClass(TElScrollBarStyles);

end.

