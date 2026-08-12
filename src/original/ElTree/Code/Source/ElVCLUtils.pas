
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

    DrawButtonFrameEx2 rewritten to support clNone color

*)

unit ElVCLUtils;

interface

uses Messages, Classes, Windows, SysUtils, Controls, StdCtrls, Forms, Graphics, ElTools;

const
  MOUSE_WHEEL_DELTA = 120;
  SC_DRAGMOVE = $F012;

var
  ParentControlRepaintedMessage : DWORD;

{$IFNDEF VCL_4_USED}
{$IFNDEF BUILDER_USED}
const
  WM_MOUSEWHEEL = $020A;
{$ENDIF}
type
  TWMMouseWheel = record
    Msg : Cardinal;
    Keys : SmallInt;
    WheelDelta : SmallInt;
    case Integer of
      0 : (
        XPos : Smallint;
        YPos : Smallint);
      1 : (
        Pos : TSmallPoint;
        Result : Longint);
  end;

{$ENDIF}

type
  TElBkGndType = (bgtTileBitmap, bgtStretchBitmap, bgtColorFill, bgtCenterBitmap, bgtHorzGradient, bgtVertGradient);
  TElBorderSide = (ebsLeft, ebsRight, ebsTop, ebsBottom);
  TElBorderSides = set of TElBorderSide;
  TElFlatBorderType = (fbtFlat, fbtSunken, fbtSunkenInner,
                       fbtSunkenOuter, fbtRaised, fbtRaisedInner, fbtRaisedOuter,
                       fbtBump, fbtBigBump, fbtEtched, fbtFramed,
                       fbtLine, fbtLineBorder, fbtNone);

  TElTextDrawType = (tdtNormal, tdtShadowed, tdtRaised);
  TElArrowDir = (eadLeft, eadUp, eadRight, eadDown);

  TTaskbarEdge = (tbeBottom, tbeLeft, tbeTop, tbeRight);

function GetSysTrayRect : TRect;
function GetTaskbarEdge : TTaskbarEdge;
function GetTaskbarRect : TRect;

procedure MinimizeToTray (Wnd : HWND);

procedure GradientFill(DC : HDC; R : TRect; StartColor, EndColor : TColor; Steps : integer; Vertical : boolean);
procedure GradientFillEx(DC : HDC; DCRect, R : TRect; Origin : TPoint; StartColor, EndColor : TColor; Steps : integer; Vertical : boolean);
// DCRect - the rectangle of the "real DC", i.e. the DC, on which the painting is
//          usually performed
// R      - the real rectangle to be painted
// Origin - The original point, i.e. the point, which, when addded to R, would have
//          been copied from the "real DC" 

function GetTopOwnerControl(Component : TComponent) : TControl;
function GetOwnerForm(Component : TComponent) : TForm;
function FindVCLChild(Control : TWinControl; ChildHandle : HWND) : TWinControl;

function GetShiftState : TShiftState;
function GetKeysState : integer;

function HitTest(R : TRect; Pt : TPoint; CornerSize, BorderSize : integer) : integer;

function GetKeybTimes(TimeKind : integer) : integer;
// correct parameter values are SPI_GETKEYBOARDDELAY and SPI_GETKEYBOARDSPEED

procedure FillSolidRect2(DC : HDC; Rect : TRect; Color : COLORREF);
procedure FillSolidRect(DC : HDC; x, y, cx, cy : integer; Color : COLORREF);
procedure TiledPaint(Canvas : TCanvas; Bitmap : TBitmap; Rect : TRect);
// destination rectangle is meant.

procedure DrawButtonFrameEx(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean;
                            ButtonColor : TColor; Thin : boolean);
procedure DrawButtonFrameEx2(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean;
                            ButtonColor : TColor; Thin : boolean; clrHighlight, clrDkShadow, clrFace, clrShadow : TColor);
procedure DrawButtonFrame(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean);
function DrawBevel(DC : HDC; R : TRect; Color1, Color2 : TColor; Sides : TElBorderSides) : TRect;
procedure Draw3dBorder(DC : HDC; rc : TRect; nColor1, nColor2, nColor3, nColor4 : TColor);
function DrawFlatFrame(DC : HDC; R : TRect; BkColor : TColor; Focused : boolean) : TRect;
procedure DrawFlatFrameEx(DC : HDC; R : TRect; BkColor : TColor; Focused, Enabled : boolean);
procedure DrawFlatFrameEx2(DC : HDC; R : TRect; BkColor : TColor; Focused, Enabled : boolean; BorderType : TElFlatBorderType);

function DrawFlatScrollbars(Wnd : HWND; DC : HDC; Rect : TRect; Focused : 
    boolean; ScrollBars : TScrollStyle; DragHorz, DragVert : boolean; IsControl 
    : boolean): TRect;

procedure DrawTypedText(Canvas : TCanvas; Bounds : TRect; Text : string; Flags : integer; DrawType : TElTextDrawType);
procedure DrawFlatScrollbarThumb(DC : HDC; rc : TRect; Focused : boolean);
procedure DrawTransparentBitmapEx(DC : HDC; Bitmap : HBitmap; X, Y : integer; Src : TRect; Transparent : TColor);

procedure DrawArrow(Canvas : TCanvas; Dir : TElArrowDir; R : TRect; Color : TColor; Enabled : boolean);

function RectsIntersect(R1, R2 : TRect) : boolean;

function GetDesktopTop    : integer;
function GetDesktopLeft   : integer;
function GetDesktopBottom : integer;
function GetDesktopRight  : integer;
function GetDesktopRect   : TRect;

function GetWorkSpaceTop    : integer;
function GetWorkSpaceLeft   : integer;
function GetWorkSpaceBottom : integer;
function GetWorkSpaceRight  : integer;
function GetWorkSpaceRect   : TRect;

const
  WaitCursor: TCursor = crHourGlass;

procedure StartWait;
procedure StopWait;

function InvertColor(aColor: TColor): TColor;

function RGBtoHLS(rgbc: integer): integer;
function HLStoRGB(hlsc: integer): integer;

procedure DrawFlatScrollBarsEx(Wnd : HWND; DC : HDC; Rect : TRect; Focused : 
    boolean; ScrollBars : TScrollStyle; DragHorz, DragVert : boolean; IsControl 
    : boolean; BkColor, DitherColor,  ButtonColor, ArrowColor, HotButtonColor : 
    TColor; DrawFrames, DitherBack : boolean);

procedure DrawFlatScrollBarEx(Wnd : HWND; DC : HDC; rect : TRect; nType : 
    integer; bScrollbarCtrl : boolean; Dragging : boolean; Focused : boolean; 
    BkColor, DitherColor, ButtonColor, ArrowColor, HotButtonColor : TColor; 
    DrawFrames, DitherBack : boolean);

implementation

function InvertColor(aColor: TColor): TColor;
var
  r,g,b: integer;
begin
  r := GetRValue(ColorToRgb(aColor));
  g := GetGValue(ColorToRgb(aColor));
  b := GetBValue(ColorToRgb(aColor));

  r := (not r) and $000000FF;
  g := ((not g) and $000000FF) shl 8;
  b := ((not b) and $000000FF) shl 16;

  Result := b or g or r;
end;

function GetWorkSpaceRect : TRect;

const SM_XVIRTUALSCREEN  = 76;
      SM_YVIRTUALSCREEN  = 77;
      SM_CXVIRTUALSCREEN = 78;
      SM_CYVIRTUALSCREEN = 79;


begin
  if IsWin98Up or IsWin2000Up then
  begin
    result.Left  := 0;
    result.Top   := 0;
    result.Right := GetSystemMetrics(SM_CXVIRTUALSCREEN);
    result.Bottom := GetSystemMetrics(SM_CYVIRTUALSCREEN);
    OffsetRect(Result, GetSystemMetrics(SM_XVIRTUALSCREEN), GetSystemMetrics(SM_YVIRTUALSCREEN));
  end
  else
  begin
    result.Left  := 0;
    result.Top   := 0;
    result.Right := GetSystemMetrics(SM_CXSCREEN);
    result.Bottom := GetSystemMetrics(SM_CYSCREEN);
  end;
end;

function GetWorkSpaceTop  : integer;
begin
  result := GetWorkSpaceRect.Top;
end;

function GetWorkSpaceLeft   : integer;
begin
  result := GetWorkSpaceRect.Left;
end;

function GetWorkSpaceBottom : integer;
begin
  result := GetWorkSpaceRect.Bottom;
end;

function GetWorkSpaceRight  : integer;
begin
  result := GetWorkSpaceRect.Right;
end;

function GetDesktopRect : TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @result, 0);
end;

function GetDesktopTop  : integer;
begin
  result := GetDesktopRect.Top;
end;

function GetDesktopLeft   : integer;
begin
  result := GetDesktopRect.Left;
end;

function GetDesktopBottom : integer;
begin
  result := GetDesktopRect.Bottom;
end;

function GetDesktopRight  : integer;
begin
  result := GetDesktopRect.Right;
end;

procedure MinimizeToTray (Wnd : HWND);
var
  WinPlace   : TWindowPlacement;
  R          : TRect;
begin
  WinPlace.length   := SizeOf(TWindowPlacement);
  GetWindowPlacement(Wnd, @WinPlace);
  WinPlace.flags    := WPF_SETMINPOSITION;
  R := GetSysTrayRect;
  WinPlace.ptMinPosition.x := R.Left;
  WinPlace.ptMinPosition.y := R.Top;
  SetWindowPlacement(Wnd, @WinPlace);
  SendMessage(Wnd, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

function GetSysTrayRect : TRect;
var H1,
    H2 : HWND;
begin
  SetRectEmpty(result);
  H1 := FindWindow('Shell_TrayWnd', nil);
  if H1 <> 0 then
  begin
    H2 := FindWindowEx(H1, 0, 'TrayNotifyWnd', nil);
    if H2 <> 0 then
       GetWindowRect(H2, result);
  end;
end;

function GetTaskbarRect : TRect;
var H1 : HWND;
begin
  H1 := FindWindow('Shell_TrayWnd', nil);
  if H1 <> 0 then
     GetWindowRect(H1, Result)
  else
     SetRectEmpty(result);
end;

function GetTaskbarEdge : TTaskbarEdge;
var H1 : HWND;
    R  : TRect;
    DesktopWidth,
    DesktopHeight  : integer;
begin
  result := tbeBottom;
  H1 := FindWindow('Shell_TrayWnd', nil);
  if H1 <> 0 then
  begin
    R := GetWorkSpaceRect;
    DesktopWidth := R.Right - R.Left;
    DesktopHeight:= R.Bottom - R.Top;
    GetWindowRect(H1, R);
    if R.Top > DesktopHeight div 2 then result := tbeBottom else
    if R.Right < DesktopWidth div 2 then result := tbeLeft else
    if R.Bottom < DesktopHEight div 2 then result := tbeTop else
    if R.Left > DesktopWidth div 2 then result := tbeRight;
  end;
end;

function GetKeybTimes(TimeKind : integer) : integer;
begin
  SystemParametersInfo(TimeKind, 0, @result, 0);
  if TimeKind = SPI_GETKEYBOARDSPEED then
  begin
    result := 1000 div (result + 1);
  end else
  if TimeKind = SPI_GETKEYBOARDDELAY then
  begin
    result := 250 * (result + 1);
  end;
end;

procedure GradientFillEx(DC : HDC; DCRect, R : TRect; Origin : TPoint; StartColor, EndColor : TColor; Steps : integer; Vertical : boolean);
var
  i : integer;
  RBeg, RDif, Rc,
    GBeg, GDif, Gc,
    BBeg, BDif, Bc : integer;
  Brush, OldBrush  : HBrush;
  R1, R2, R3       : TRect;
begin
  if StartColor = EndColor then
  begin
    Brush := CreateSolidBrush(ColorToRGB(StartColor));
    FillRect(DC, R, Brush);
    DeleteObject(Brush);
  end
  else
  begin
    RBeg := GetRValue(ColorToRGB(StartColor));
    GBeg := GetGValue(ColorToRGB(StartColor));
    BBeg := GetBValue(ColorToRGB(StartColor));
    RDif := GetRValue(ColorToRGB(EndColor)) - RBeg;
    GDif := GetGValue(ColorToRGB(EndColor)) - GBeg;
    BDif := GetBValue(ColorToRGB(EndColor)) - BBeg;
    R1 := R;
    for i := 0 to Steps - 1 do // Iterate
    begin
      if Vertical then
      begin
        R1.Top := R.Top + MulDiv(i, R.Bottom - R.Top, Steps);
        R1.Bottom := R.Top + MulDiv(i + 1, R.Bottom - R.Top, Steps);
      end else
      begin
        R1.Left := R.Left + MulDiv(i, R.Right - R.Left, Steps);
        R1.Right := R.Left + MulDiv(i + 1, R.Right - R.Left, Steps);
      end;
      R3 := DCRect;
      OffsetRect(R3, Origin.X, Origin.Y);
      IntersectRect(R2, R3, R1);
      if not IsRectEmpty(R2) then
      begin
        //R2 := R1;
        OffsetRect(R2, -Origin.x, -Origin.y);
        Rc := RBeg + MulDiv(i, RDif, Steps - 1);
        Gc := GBeg + MulDiv(i, GDif, Steps - 1);
        Bc := BBeg + MulDiv(i, BDif, Steps - 1);

        Brush := CreateSolidBrush(RGB(Rc, Gc, Bc));
        OldBrush := SelectObject(DC, Brush);
        PatBlt(DC, R2.Left, R2.Top, R2.Right - R2.Left, R2.Bottom - R2.Top, PATCOPY);
        SelectObject(DC, OldBrush);
        DeleteObject(Brush);
      end;
    end; // for
  end;
end;

procedure GradientFill(DC : HDC; R : TRect; StartColor, EndColor : TColor; Steps : integer; Vertical : boolean);
var
  i : integer;
  RBeg, RDif, Rc,
    GBeg, GDif, Gc,
    BBeg, BDif, Bc : integer;
  Brush, OldBrush : HBrush;
  R1 : TRect;
begin
  if StartColor = EndColor then
  begin
    Brush := CreateSolidBrush(ColorToRGB(StartColor));
    FillRect(DC, R, Brush);
    DeleteObject(Brush);
  end
  else
  begin
    RBeg := GetRValue(ColorToRGB(StartColor));
    GBeg := GetGValue(ColorToRGB(StartColor));
    BBeg := GetBValue(ColorToRGB(StartColor));
    RDif := GetRValue(ColorToRGB(EndColor)) - RBeg;
    GDif := GetGValue(ColorToRGB(EndColor)) - GBeg;
    BDif := GetBValue(ColorToRGB(EndColor)) - BBeg;
    R1 := R;
    for i := 0 to Steps - 1 do // Iterate
    begin
      if Vertical then
      begin
        R1.Top := R.Top + MulDiv(i, R.Bottom - R.Top, Steps);
        R1.Bottom := R.Top + MulDiv(i + 1, R.Bottom - R.Top, Steps);
      end else
      begin
        R1.Left := R.Left + MulDiv(i, R.Right - R.Left, Steps);
        R1.Right := R.Left + MulDiv(i + 1, R.Right - R.Left, Steps);
      end;

      Rc := RBeg + MulDiv(i, RDif, Steps - 1);
      Gc := GBeg + MulDiv(i, GDif, Steps - 1);
      Bc := BBeg + MulDiv(i, BDif, Steps - 1);

      Brush := CreateSolidBrush(RGB(Rc, Gc, Bc));
      OldBrush := SelectObject(DC, Brush);
      PatBlt(DC, R1.Left, R1.Top, R1.Right - R1.Left, R1.Bottom - R1.Top, PATCOPY);
      SelectObject(DC, OldBrush);
      DeleteObject(Brush);
    end; // for
  end;
end;

procedure DrawArrow(Canvas : TCanvas; Dir : TElArrowDir; R : TRect; Color : TColor; Enabled : boolean);
var FSavePenColor : TColor;
    DestRect : TRect;
begin
  FSavePenColor := Canvas.Pen.Color;
  if Enabled
     then Canvas.Pen.Color := Color
     else Canvas.Pen.Color := clBtnHighlight;
  case Dir of
    eadRight:
      begin
        if (R.Right - R.Left < 3) or (R.Bottom - R.Top < 6) then exit;
        CenterRects(4, R.Right - R.Left, 7, R.Bottom - R.Top, DestRect);
        if not Enabled then
           OffsetRect(DestRect, R.Left + 1, R.Top + 1)
        else
           OffsetRect(DestRect, R.Left, R.Top);
        with Canvas do
        begin
          MoveTo(DestRect.Left, DestRect.Top);
          LineTo(DestRect.Left, DestRect.Top + 7);
          MoveTo(DestRect.Left + 1, DestRect.Top + 1);
          LineTo(DestRect.Left + 1, DestRect.Top + 6);
          MoveTo(DestRect.Left + 2, DestRect.Top + 2);
          LineTo(DestRect.Left + 2, DestRect.Top + 5);
          Pixels[DestRect.Left + 3, DestRect.Top + 3] := Canvas.Pen.Color;
          if not Enabled then
          begin
            Canvas.Pen.Color := clBtnShadow;
            OffsetRect(DestRect, -1, -1);
            MoveTo(DestRect.Left, DestRect.Top);
            LineTo(DestRect.Left, DestRect.Top + 7);
            MoveTo(DestRect.Left + 1, DestRect.Top + 1);
            LineTo(DestRect.Left + 1, DestRect.Top + 6);
            MoveTo(DestRect.Left + 2, DestRect.Top + 2);
            LineTo(DestRect.Left + 2, DestRect.Top + 5);
            Pixels[DestRect.Left + 3, DestRect.Top + 3] := Canvas.Pen.Color;
          end;
        end;
      end;
    eadUp:
      begin
        if (R.Right - R.Left < 6) or (R.Bottom - R.Top < 3) then exit;
        CenterRects(7, R.Right - R.Left, 4, R.Bottom - R.Top, DestRect);
        if not Enabled then
           OffsetRect(DestRect, R.Left + 1, R.Top + 1)
        else
           OffsetRect(DestRect, R.Left, R.Top);
        with Canvas do
        begin
          //mdm - Decremented all "LineTo(DestRect.Left" by one to draw properly
          MoveTo(DestRect.Left, DestRect.Top + 3);
          LineTo(DestRect.Left + 7, DestRect.Top + 3);

          MoveTo(DestRect.Left + 1, DestRect.Top + 2);
          LineTo(DestRect.Left + 6, DestRect.Top + 2);

          MoveTo(DestRect.Left + 2, DestRect.Top + 1);
          LineTo(DestRect.Left + 5, DestRect.Top + 1);

          Pixels[DestRect.Left + 3, DestRect.Top] := Canvas.Pen.Color;

          if not Enabled then
          begin
            Canvas.Pen.Color := clBtnShadow;
            OffsetRect(DestRect, -1, -1);
            MoveTo(DestRect.Left, DestRect.Top + 3);
            LineTo(DestRect.Left + 7, DestRect.Top + 3);

            MoveTo(DestRect.Left + 1, DestRect.Top + 2);
            LineTo(DestRect.Left + 6, DestRect.Top + 2);

            MoveTo(DestRect.Left + 2, DestRect.Top + 1);
            LineTo(DestRect.Left + 5, DestRect.Top + 1);

            Pixels[DestRect.Left + 3, DestRect.Top] := Canvas.Pen.Color;

          end;
        end;
      end;
    eadLeft:
      begin
        if (R.Right - R.Left < 3) or (R.Bottom - R.Top < 6) then exit;
        CenterRects(4, R.Right - R.Left, 7, R.Bottom - R.Top, DestRect);
        if not Enabled then
           OffsetRect(DestRect, R.Left + 1, R.Top + 1)
        else
           OffsetRect(DestRect, R.Left, R.Top);
        with Canvas do
        begin
          MoveTo(DestRect.Left + 3, DestRect.Top);
          LineTo(DestRect.Left + 3, DestRect.Top + 7);
          MoveTo(DestRect.Left + 2, DestRect.Top + 1);
          LineTo(DestRect.Left + 2, DestRect.Top + 6);
          MoveTo(DestRect.Left + 1, DestRect.Top + 2);
          LineTo(DestRect.Left + 1, DestRect.Top + 5);
          Pixels[DestRect.Left, DestRect.Top + 3] := Canvas.Pen.Color;
          if not Enabled then
          begin
            Canvas.Pen.Color := clBtnShadow;
            OffsetRect(DestRect, -1, -1);
            MoveTo(DestRect.Left + 3, DestRect.Top);
            LineTo(DestRect.Left + 3, DestRect.Top + 7);
            MoveTo(DestRect.Left + 2, DestRect.Top + 1);
            LineTo(DestRect.Left + 2, DestRect.Top + 6);
            MoveTo(DestRect.Left + 1, DestRect.Top + 2);
            LineTo(DestRect.Left + 1, DestRect.Top + 5);
            Pixels[DestRect.Left, DestRect.Top + 3] := Canvas.Pen.Color;
          end;
        end;
      end;
    eadDown:
      begin
        if (R.Right - R.Left < 6) or (R.Bottom - R.Top < 3) then exit;
        CenterRects(7, R.Right - R.Left, 4, R.Bottom - R.Top, DestRect);
        if not Enabled then
           OffsetRect(DestRect, R.Left + 1, R.Top + 1)
        else
           OffsetRect(DestRect, R.Left, R.Top);
        with Canvas do
        begin
          MoveTo(DestRect.Left, DestRect.Top);
          LineTo(DestRect.Left + 7, DestRect.Top);

          MoveTo(DestRect.Left + 1, DestRect.Top + 1);
          LineTo(DestRect.Left + 6, DestRect.Top + 1);

          MoveTo(DestRect.Left + 2, DestRect.Top + 2);
          LineTo(DestRect.Left + 5, DestRect.Top + 2);

          Pixels[DestRect.Left + 3, DestRect.Top + 3] := Canvas.Pen.Color;

          if not Enabled then
          begin
            Canvas.Pen.Color := clBtnShadow;
            OffsetRect(DestRect, -1, -1);

            MoveTo(DestRect.Left, DestRect.Top);
            LineTo(DestRect.Left + 7, DestRect.Top);

            MoveTo(DestRect.Left + 1, DestRect.Top + 1);
            LineTo(DestRect.Left + 6, DestRect.Top + 1);

            MoveTo(DestRect.Left + 2, DestRect.Top + 2);
            LineTo(DestRect.Left + 5, DestRect.Top + 2);

            Pixels[DestRect.Left + 3, DestRect.Top + 3] := Canvas.Pen.Color;
          end;
        end;
      end;
  end;
  Canvas.Pen.Color := FSavePenColor;
end;

function RectsIntersect(R1, R2 : TRect) : boolean;
var
  R : TRect;
begin
  IntersectRect(R, R1, R2);
  result := IsRectEmpty(R);
end;

function FindVCLChild(Control : TWinControl; ChildHandle : HWND) : TWinControl;
var
  i : integer;
  C : TWinControl;
begin
  for i := 0 to Control.ControlCount - 1 do // Iterate
  begin
    if Control.Controls[i] is TWinControl then
    begin
      C := TWinControl(Control.Controls[i]);
      if C.HandleAllocated and (C.Handle = ChildHandle) then
      begin
        result := C;
        exit;
      end;
    end;
  end; // for
  result := nil;
end;

procedure DrawTransparentBitmapEx(DC : HDC; Bitmap : HBitmap; X, Y : integer; Src : TRect; Transparent : TColor);
var
  cColor : TColorRef;
  bmAndBack,
    bmAndObject,
    bmAndMem,
    bmSave,
    bmBackOld,
    bmObjectOld,
    bmMemOld,
    bmSaveOld : HBitmap;
  hdcMem,
    hdcBack,
    hdcObject,
    hdcTemp,
    hdcSave : HDC;
  bmWidth, bmHeight : integer;

begin
  hdcTemp := CreateCompatibleDC(DC);
  SelectObject(hdcTemp, Bitmap); { select the bitmap }

  bmWidth := Src.Right - Src.Left;
  bmHeight := Src.Bottom - Src.Top;

   { create some DCs to hold temporary data }
  hdcBack := CreateCompatibleDC(DC);
  hdcObject := CreateCompatibleDC(DC);
  hdcMem := CreateCompatibleDC(DC);
  hdcSave := CreateCompatibleDC(DC);

   { create a bitmap for each DC }

   { monochrome DC }
  bmAndBack := CreateBitmap(bmWidth, bmHeight, 1, 1, nil);
  bmAndObject := CreateBitmap(bmWidth, bmHeight, 1, 1, nil);

  bmAndMem := CreateCompatibleBitmap(DC, bmWidth, bmHeight);
  bmSave := CreateCompatibleBitmap(DC, bmWidth, bmHeight);

   { each DC must select a bitmap object to store pixel data }
  bmBackOld := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld := SelectObject(hdcMem, bmAndMem);
  bmSaveOld := SelectObject(hdcSave, bmSave);

   { set proper mapping mode }
  SetMapMode(hdcTemp, GetMapMode(DC));

   { save the bitmap sent here, because it will be overwritten }
  BitBlt(hdcSave, 0, 0, bmWidth, bmHeight, hdcTemp, Src.Left, Src.Top, SRCCOPY);

   { set the background color of the source DC to the color.
    contained in the parts of the bitmap that should be transparent }
  cColor := SetBkColor(hdcTemp, ColorToRGB(Transparent));

   { create the object mask for the bitmap by performing a BitBlt()
     from the source bitmap to a monochrome bitmap }
  BitBlt(hdcObject, 0, 0, bmWidth, bmHeight, hdcTemp, Src.Left, Src.Top, SRCCOPY);

   { set the background color of the source DC back to the original
color }
  SetBkColor(hdcTemp, cColor);

   { create the inverse of the object mask }
  BitBlt(hdcBack, 0, 0, bmWidth, bmHeight, hdcObject, 0, 0, NOTSRCCOPY);

   { copy the background of the main DC to the destination }
  BitBlt(hdcMem, 0, 0, bmWidth, bmHeight, DC, X, Y, SRCCOPY);

   { mask out the places where the bitmap will be placed }
  BitBlt(hdcMem, 0, 0, bmWidth, bmHeight, hdcObject, 0, 0, SRCAND);

   { mask out the transparent colored pixels on the bitmap }
  BitBlt(hdcTemp, Src.Left, Src.Top, bmWidth, bmHeight, hdcBack, 0, 0, SRCAND);

   { XOR the bitmap with the background on the destination DC }
  BitBlt(hdcMem, 0, 0, bmWidth, bmHeight, hdcTemp, Src.Left, Src.Top, SRCPAINT);

   { copy the destination to the screen }
  BitBlt(DC, X, Y, bmWidth, bmHeight, hdcMem, 0, 0, SRCCOPY);

   { place the original bitmap back into the bitmap sent here }
  BitBlt(hdcTemp, Src.Left, Src.Top, bmWidth, bmHeight, hdcSave, 0, 0, SRCCOPY);

   { delete the memory bitmaps }
  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcSave, bmSaveOld));

   { delete the memory DCs }
  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcSave);
  DeleteDC(hdcTemp);
end;

procedure DrawTypedText(Canvas : TCanvas; Bounds : TRect; Text : string; Flags : integer; DrawType : TElTextDrawType);
var
  Col : TColor;
begin
  case DrawType of
    tdtNormal :
      DrawText(Canvas.Handle, PChar(Text), Length(Text), Bounds, Flags);
    tdtShadowed :
      begin
        OffsetRect(Bounds, 2, 2);
        Col := Canvas.Font.Color;
        Canvas.Font.Color := clBtnShadow;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), Bounds, Flags);
        OffsetRect(Bounds, -2, -2);
        Canvas.Font.Color := col;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), Bounds, Flags);
      end;
    tdtRaised :
      begin
        OffsetRect(Bounds, -1, -1);
        Col := Canvas.Font.Color;
        Canvas.Font.Color := clBtnHighlight;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), Bounds, Flags);
        OffsetRect(Bounds, 1, 1);
        Canvas.Font.Color := col;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), Bounds, Flags);
      end;
  end;
end;

procedure FillSolidRect2(DC : HDC; Rect : TRect; Color : COLORREF);
var
  SaveC : COLORREF;
begin
  SaveC := GetBkColor(DC);
  SetBkColor(DC, Color);
  ExtTextOut(DC, 0, 0, ETO_OPAQUE, @Rect, nil, 0, nil);
  SetBkColor(DC, SaveC);
end;

procedure FillSolidRect(DC : HDC; x, y, cx, cy : integer; Color : COLORREF);
var
  Rect : TRect;
  SaveC : COLORREF;
begin
  SaveC := GetBkColor(DC);
  SetBkColor(DC, Color);
  Rect := Classes.Rect(x, y, x + cx, y + cy);
  ExtTextOut(DC, 0, 0, ETO_OPAQUE, @Rect, nil, 0, nil);
  SetBkColor(DC, SaveC);
end;

procedure Draw3dRect(DC : HDC; x, y, cx, cy : integer; clrTopLeft, clrBottomRight : COLORREF);
begin
  FillSolidRect(DC, x, y, cx - 1, 1, clrTopLeft);
  FillSolidRect(DC, x, y, 1, cy - 1, clrTopLeft);
  FillSolidRect(DC, x + cx, y, -1, cy, clrBottomRight);
  FillSolidRect(DC, x, y + cy, cx, -1, clrBottomRight);
end;

procedure Draw3dBorder(DC : HDC; rc : TRect; nColor1, nColor2, nColor3, nColor4 : TColor);
begin
  nColor1 := ColorToRGB(nColor1);
  nColor2 := ColorToRGB(nColor2);
  nColor3 := ColorToRGB(nColor3);
  nColor4 := ColorToRGB(nColor4);

  Draw3dRect(DC, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, GetSysColor(nColor1), GetSysColor(nColor2));
  Draw3dRect(DC, rc.left + 1, rc.top + 1, rc.right - rc.left - 2, rc.bottom - rc.top - 2, GetSysColor(nColor3), GetSysColor(nColor4));
end;

const
  hlsMax=252; // H, L, S vary over 0 - hlsMax; best if divisible by 6
  rgbMax=255; // r, g, b vary over 0-rgbMax; must each fit in a byte

  hlsMaxD2   = hlsMax div 2;
  hlsMaxD3   = hlsMax div 3;
  hlsMaxD6   = hlsMax div 6;
  hlsMaxD12  = hlsMax div 12;
  hlsMaxM2D3 = hlsMax*2 div 3;
  rgbMaxM2   = rgbMax*2;
  undefined  = (hlsMaxM2D3);

procedure checkRange(var hls: integer);
begin
  if hls<0 then inc(hls, hlsMax); if hls>hlsMax then dec(hls, hlsMax)
end;

function RGBtoHLS(rgbc: integer): integer;
var
  r, g, b, h, l, s, cMax, cMin, rD, gD, bD,
  cDiff, cDiffD2, cSum, cSumD2: integer;
begin
  r:=getRValue(rgbc);
  g:=getGValue(rgbc);
  b:=getBValue(rgbc);
  cMax:=max(max(r, g), b);
  cMin:=min(min(r, g), b);

  l:=(((cMax+cMin)*hlsMax)+rgbMax) div (rgbMaxM2);

  if cMax=cMin then
  begin
    s:=0;
    h := undefined
  end
  else
  begin
    cDiff:=cMax-cMin;
    cDiffD2:=cDiff div 2;
    cSum:=cMax+cMin;
    cSumD2:=cSum div 2;
    if l<=hlsMaxD2 then
       s:=(cDiff*hlsMax + cSumD2) div cSum
    else
       s:=(cDiff*hlsMax + (rgbMaxM2-cDiff) div 2) div (rgbMaxM2-cDiff);
    rD:=((cMax-r)*hlsMaxD6 + cDiffD2) div cDiff;
    gD:=((cMax-g)*hlsMaxD6 + cDiffD2) div cDiff;
    bD:=((cMax-b)*hlsMaxD6 + cDiffD2) div cDiff;
    if r=cMax then
       h:= bD - gD
    else
    if g=cMax then
       h:=hlsMaxD3 + rD - bD
    else
       h:=hlsMaxM2D3 + gD - rD;
    checkRange(h);
  end;
  result:=rgb(h, l, s);
end;

function HLStoRGB(hlsc: integer): integer;
var
  h, l, s, r, g, b, magic1, magic2: integer;

  function hueToRGB(n1, n2, hue: integer): integer;
  begin
    checkRange(hue);
    if hue<hlsMaxD6 then
      result:=n1+((n2-n1)*hue+hlsMaxD12) div hlsMaxD6
    else if hue<hlsMaxD2 then result:=n2
    else if hue<hlsMaxM2D3 then
      result:=n1+((n2-n1)*(hlsMaxM2D3-hue)+hlsMaxD12) div hlsMaxD6
    else result:=n1
  end;

begin
  h:=getRValue(hlsc); l:=getGValue(hlsc); s:=getBValue(hlsc);
  if s=0 then
  begin
    r:=l * rgbMax div hlsMax; g:=r; b:=r;
    if h<>undefined then begin {ERROR} end
  end
  else
  begin
    if l<=hlsMaxD2 then magic2:=(l*(hlsMax+s) + hlsMaxD2) div hlsMax
    else magic2:=l+s-(l*s+hlsMaxD2) div hlsMax;
    magic1:=2*l-magic2;
    r:=Max(0, Min(255, (hueToRGB(magic1, magic2, h+hlsMaxD3)*rgbMax+hlsMaxD2) div hlsMax));
    g:=Max(0, Min(255, (hueToRGB(magic1, magic2, h)*rgbMax+hlsMaxD2) div hlsMax));
    b:=Max(0, Min(255, (hueToRGB(magic1, magic2, h-hlsMaxD3)*rgbMax+hlsMaxD2) div hlsMax));
  end;
  result:=rgb(r,g,b)
end;

procedure DrawButtonFrameEx(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean; ButtonColor : TColor; Thin : boolean);
var Color1,
    Color2,
    Color3,
    Color4 : TColor;
    hls1, hls2, hls3, hls4 : integer;
    lum : integer;

    procedure DrawBorder(DC : HDC; rc : TRect; nColor1, nColor2, nColor3, nColor4 : TColor; Thin : boolean);

        procedure Draw3dRect(DC : HDC; x, y, cx, cy : integer; clrTopLeft, clrBottomRight : COLORREF);
        begin
          FillSolidRect(DC, x, y, cx - 1, 1, clrTopLeft);
          FillSolidRect(DC, x, y, 1, cy - 1, clrTopLeft);
          FillSolidRect(DC, x + cx, y, -1, cy, clrBottomRight);
          FillSolidRect(DC, x, y + cy, cx, -1, clrBottomRight);
        end;

    begin
      Draw3dRect(DC, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, nColor1, nColor2);
      if not Thin then
        Draw3dRect(DC, rc.left + 1, rc.top + 1, rc.right - rc.left - 2, rc.bottom - rc.top - 2, nColor3, nColor4);
    end;

begin
  if ButtonColor = clBtnFace then
  begin
    Color1 := GetsysColor(COLOR_3DHIGHLIGHT);
    Color2 := GetsysColor(COLOR_3DDKSHADOW);
    Color3 := GetsysColor(COLOR_3DFACE);
    Color4 := GetsysColor(COLOR_3DSHADOW);
  end else
  begin
    ButtonColor := ColorToRGB(ButtonColor);

    hls1 := RGBtoHLS(ButtonColor);
    hls2 := hls1;
    hls3 := hls1;
    hls4 := hls1;

    lum := Hi(LoWord(hls3));
    hls1 := (Min(239, (Hi(LoWord(hls3))  + lum div 3)) shl 8) or (hls1 and $FF00FF);
    hls2 := (Min(239, (Hi(LoWord(hls3))  - lum div 2)) shl 8) or (hls2 and $FF00FF);
    hls4 := (Min(239, (Hi(LoWord(hls3))  - lum div 3)) shl 8) or (hls4 and $FF00FF);

    Color1 := HLStoRGB(hls1);
    Color2 := HLStoRGB(hls2);
    Color3 := ButtonColor;
    Color4 := HLStoRGB(hls4);
  end;

  if not Pushed then
  begin
    if Focused then
      DrawBorder(DC, rc, Color1, Color2, Color3, Color4, Thin)
    else
      DrawBorder(DC, rc, Color1, Color4, Color3, Color3, Thin);
  end
  else
  begin
    if Focused then
      DrawBorder(DC, rc, Color2, Color1, Color4, Color3, Thin)
    else
      DrawBorder(DC, rc, Color4, Color1, Color3, Color3, Thin);
  end;
end;

procedure DrawButtonFrame(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean);
begin
  if not Pushed then
  begin
    if Focused then
      Draw3dBorder(DC, rc, COLOR_3DHIGHLIGHT, COLOR_3DDKSHADOW, COLOR_3DFACE, COLOR_3DSHADOW)
    else
      Draw3dBorder(DC, rc, COLOR_3DHIGHLIGHT, COLOR_3DSHADOW, COLOR_3DFACE, COLOR_3DFACE);
  end
  else
    Draw3dBorder(DC, rc, COLOR_3DDKSHADOW , COLOR_3DHIGHLIGHT, COLOR_3DSHADOW, COLOR_3DFACE);
end;

procedure DrawButtonFrameEx2(DC : HDC; rc : TRect; Focused : boolean; Pushed : boolean; ButtonColor : TColor; Thin : boolean; clrHighlight, clrDkShadow, clrFace, clrShadow : TColor);
var Color1,
    Color2,
    Color3,
    Color4 : TColor;

    procedure DrawBorder(DC : HDC; rc : TRect; nColor1, nColor2, nColor3, nColor4 : TColor; Thin : boolean);

      procedure Draw3dRect(DC : HDC; x, y, cx, cy : integer; clrTopLeft, clrBottomRight : TColor);
      var
        Clr: COLORREF;
      begin
        if clrTopLeft <> clNone then
        begin
          Clr := ColorToRGB(clrTopLeft);
          FillSolidRect(DC, x, y, cx - 1, 1, Clr);
          FillSolidRect(DC, x, y, 1, cy - 1, Clr);
        end;
        if clrBottomRight <> clNone then
        begin
          Clr := ColorToRGB(clrBottomRight);
          FillSolidRect(DC, x + cx, y, -1, cy, Clr);
          FillSolidRect(DC, x, y + cy, cx, -1, Clr);
        end;
      end;

    begin
      Draw3dRect(DC, rc.left, rc.top, rc.right - rc.left, rc.bottom - rc.top, nColor1, nColor2);
      if not Thin then
        Draw3dRect(DC, rc.left + 1, rc.top + 1, rc.right - rc.left - 2, rc.bottom - rc.top - 2, nColor3, nColor4);
    end;

begin
  Color1 := clrHighlight;
  Color2 := clrDkShadow;
  Color3 := clrFace;
  Color4 := clrShadow;
  if not Pushed then
  begin
    if Focused then
      DrawBorder(DC, rc, Color1, Color2, Color3, Color4, Thin)
    else
      DrawBorder(DC, rc, Color1, Color4, Color3, Color3, Thin);
  end
  else
    DrawBorder(DC, rc, Color2, Color1, Color4, Color3, Thin);
end;

{$WARNINGS off}

procedure DrawFlatFrameEx2(DC : HDC; R : TRect; BkColor : TColor; Focused, Enabled : boolean; BorderType : TElFlatBorderType);
var BtnFaceBrush,
    WindowBrush,
    ShadowBrush: HBRUSH;
    R1 : TRect;

const EdgeTypes : array [TElFlatBorderType] of DWORD = (EDGE_RAISED, BDR_SUNKEN, BDR_SUNKENINNER, BDR_SUNKENOUTER, EDGE_RAISED, BDR_RAISEDINNER, BDR_RAISEDOUTER, EDGE_BUMP, EDGE_BUMP, EDGE_ETCHED, EDGE_BUMP, 0, 0, 0);
      EdgeFlat  : array [boolean] of DWORD = (BF_RECT or BF_ADJUST, BF_FLAT or BF_ADJUST);

begin

  if BorderType = fbtFlat then
  begin
    DrawFlatFrame(DC, R, BkColor, false);
    exit;
  end;

  BtnFaceBrush := GetSysColorBrush(COLOR_BTNFACE); //get the Windows brush
  WindowBrush := GetSysColorBrush(COLOR_WINDOW); //get the Windows brush
  ShadowBrush := GetSysColorBrush(COLOR_BTNSHADOW);

  if BorderType < fbtLine then
    DrawEdge(DC, R, EdgeTypes[BorderType], EdgeFlat[BorderType = fbtFlat]);

  case BorderType of
    fbtFramed:
      with R do
      begin
        FrameRect (DC, Rect(Left-1, Top, Left, Bottom), BtnFaceBrush);
        FrameRect (DC, Rect(Left-2, Top-1, Right+1, Top), BtnFaceBrush);
        FrameRect (DC, Rect(Right+1, Top-2, Right+2, Bottom+2), ShadowBrush);
        FrameRect (DC, Rect(Left-2, Bottom+1, Right+2, Bottom+2), ShadowBrush);
      end;
    fbtRaised:
      begin
        R1 := R;
        R1 := DrawBevel(DC, R1, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
        R1 := DrawBevel(DC, R1, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
        R1 := DrawBevel(DC, R, clBtnShadow, clBtnHighlight, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
      end;
    fbtRaisedInner:
      with R do
      begin
        FrameRect(DC, Rect(Left, Top, Left+1, Bottom), BtnFaceBrush);
        FrameRect(DC, Rect(Left, Top, Right, Top+1), BtnFaceBrush);

        FillRect(DC, Rect(Right-1, Top, Right, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Left, Bottom - 1, Right, Bottom), BtnFaceBrush);
      end;
    fbtRaisedOuter:
      with R do
      begin
        FillRect(DC, Rect(Left, Top, Left+1, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Left, Top, Right, Top+1), BtnFaceBrush);
        FillRect(DC, Rect(Right-1, Top, Right, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Left, Bottom - 1, Right, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Right, Top-1, Right+1, Bottom+1), ShadowBrush);
        FillRect(DC, Rect(Left-1, Bottom, Right+1, Bottom+1), ShadowBrush);
      end;
    {fbtSunken:
      begin
        if not Focused then
        begin
          FrameRect (DC, R, BtnFaceBrush);
          InflateRect (R, -1, -1);
          if (not Enabled)
             then FrameRect(DC, R, WindowBrush)
             else FrameRect(DC, R, BtnFaceBrush);
        end;
      end;
    }fbtSunkenInner:
      with R do
      begin
        FrameRect(DC, Rect(Left, Top, Left+1, Bottom), BtnFaceBrush);
        FrameRect(DC, Rect(Left, Top, Right, Top+1), BtnFaceBrush);

        FillRect(DC, Rect(Right-1, Top, Right, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Left, Bottom - 1, Right, Bottom), BtnFaceBrush);

        FillRect(DC, Rect(Right, Top-1, Right+1, Bottom+1), BtnFaceBrush);
        FillRect(DC, Rect(Left-1, Bottom, Right+1, Bottom+1), BtnFaceBrush);
      end;
    fbtSunkenOuter:
      with R do
      begin
        FrameRect(DC, Rect(Left, Top, Left+1, Bottom-1), BtnFaceBrush);
        FrameRect(DC, Rect(Left, Top, Right-1, Top+1), BtnFaceBrush);

        FillRect(DC, Rect(Right-1, Top, Right, Bottom), BtnFaceBrush);
        FillRect(DC, Rect(Left, Bottom - 1, Right, Bottom), BtnFaceBrush);

        FillRect(DC, Rect(Right, Top-1, Right+1, Bottom+1), WindowBrush);
        FillRect(DC, Rect(Left-1, Bottom, Right+1, Bottom+1), WindowBrush);
      end;
    fbtBump:
      with R do
      begin
        FillRect(DC, Rect(Left-1, Top-1, Left, Bottom), ShadowBrush);
        FillRect(DC, Rect(Left, Top-1, Right, Top), ShadowBrush);
        FillRect(DC, Rect(Right+2, Top-2, Right+1, Bottom+2), ShadowBrush);
        FillRect(DC, Rect(Left-2, Bottom+1, Right+2, Bottom+2), ShadowBrush);
      end;
    fbtBigBump:
      with R do
      begin
        FillRect(DC, Rect(Left-1, Top-1, Left, Bottom), ShadowBrush);
        FillRect(DC, Rect(Left, Top-1, Right, Top), ShadowBrush);
        FillRect(DC, Rect(Right+2, Top-2, Right+1, Bottom+2), ShadowBrush);
        FillRect(DC, Rect(Left-2, Bottom+1, Right+2, Bottom+2), ShadowBrush);
        FillRect(DC, Rect(Left-2, Top-2, Left-1, Bottom+1), WindowBrush);
        FillRect(DC, Rect(Left-2, Top-2, Right+1, Top-1), WindowBrush);
        FillRect(DC, Rect(Right+1, Top-2, Right, Bottom+1), WindowBrush);
        FillRect(DC, Rect(Left-2, Bottom, Right+1, Bottom+1), WindowBrush);
      end;
    fbtFlat:
      with R do
      begin
        FillRect (DC, Rect(Left-1, Top-1, Right, Top), BtnFaceBrush);
      end;
    fbtEtched:
      with R do
      begin
        FillRect (DC, Rect(Left-1, Top-1, Right, Top), BtnFaceBrush);
      end;
    fbtLine, fbtLineBorder, fbtNone: //mdm - Support for new styles
      begin
        R1 := DrawBevel(DC, R, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
        DrawBevel(DC, R1, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
        case BorderType of
          fbtLine:       DrawBevel(DC, R, clWindowFrame, clWindowFrame, [ebsBottom]);
          fbtLineBorder: DrawBevel(DC, R, clWindowFrame, clWindowFrame, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
        end;
      end;
  end;
end;

procedure DrawFlatFrameEx(DC : HDC; R : TRect; BkColor : TColor; Focused, Enabled : boolean);
begin
  if Focused then
  begin
    Draw3dBorder(DC, R, COLOR_3DSHADOW, COLOR_3DHIGHLIGHT, COLOR_3DDKSHADOW, COLOR_3DLIGHT);
  end
  else
  begin
    if not Enabled
      then
      Draw3dBorder(DC, R, COLOR_3DSHADOW, COLOR_3DHIGHLIGHT, COLOR_3DFACE, COLOR_3DFACE)
    else
      Draw3dBorder(DC, R, COLOR_3DSHADOW, COLOR_3DHIGHLIGHT, COLOR_3DLIGHT, COLOR_3DLIGHT);
  end;
end;

function DrawFlatFrame(DC : HDC; R : TRect; BkColor : TColor; Focused : boolean) : TRect;
var
  R1 : TRect;
begin
  R1 := R;
  R1 := DrawBevel(DC, R1, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
  R1 := DrawBevel(DC, R1, BkColor, BkColor, [ebsLeft, ebsRight, ebsTop, ebsBottom]);

  if Focused then
  begin
    R := DrawBevel(DC, R, clBtnShadow, clBtnHighlight, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
    R := DrawBevel(DC, R, clBtnText, cl3DLight, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
  end
  else
  begin
    DrawBevel(DC, R, clBtnShadow, clBtnHighlight, [ebsLeft, ebsRight, ebsTop, ebsBottom]);
  end;
end;

function DrawBevel(DC : HDC; R : TRect; Color1, Color2 : TColor; Sides : TElBorderSides) : TRect;
var
  APN,
  OPN : HPEN;
begin
  APN := CreatePen(PS_SOLID, 1, ColorToRGB(Color1));
  OPN := SelectObject(DC, APN);
  if ebsLeft in Sides then
  begin
    MoveToEx(DC, R.Left, R.Top, nil);
    LineTo(DC, R.Left, R.Bottom);
  end;
  if ebsTop in Sides then
  begin
    MoveToEx(DC, R.Left, R.Top, nil);
    LineTo(DC, R.Right, R.Top);
  end;

  SelectObject(DC, OPN);
  DeleteObject(APN);
  APN := CreatePen(PS_SOLID, 1, ColorToRGB(Color2));
  SelectObject(DC, APN);
  if ebsRight in Sides then
  begin
    MoveToEx(DC, R.Right - 1, R.Top, nil);
    LineTo(DC, R.Right - 1, R.Bottom);
  end;
  if ebsBottom in Sides then
  begin
    MoveToEx(DC, R.Left, R.Bottom - 1, nil);
    LineTo(DC, R.Right, R.Bottom - 1);
  end;
  SelectObject(DC, OPN);
  DeleteObject(APN);

  if ebsLeft in Sides then inc(R.Left);
  if ebsTop in Sides then inc(R.Top);
  if ebsRight in Sides then dec(R.Right);
  if ebsBottom in Sides then dec(R.Bottom);
  Result := R;
end;

procedure TiledPaint(Canvas : TCanvas; Bitmap : TBitmap; Rect : TRect);
var
  CurRect : TRect;
  CurLeft,
    CurTop : integer;
begin
  if not IsWinNT then
  begin
    CurTop := Rect.Top;
    while CurTop < Rect.Bottom do
    begin
      CurLeft := Rect.Left;
      while CurLeft < Rect.Right do
      begin
        CurRect := Classes.Rect(CurLeft, CurTop, Min(CurLeft + Bitmap.Width, Rect.Right), Min(CurTop + Bitmap.Height, Rect.Bottom));
        BitBlt(Canvas.Handle, CurLeft, CurTop, CurRect.Right - CurRect.Left, CurRect.Bottom - CurRect.Top, Bitmap.Canvas.Handle, 0, 0, SRCCOPY);
        Inc(CurLeft, Bitmap.Width);
      end;
      Inc(CurTop, Bitmap.Height);
    end;
  end
  else
  begin
    Canvas.Brush.Bitmap := TBitmap.Create;
    Canvas.Brush.Bitmap.Assign(Bitmap);
    Canvas.FillRect(Rect);
    Canvas.Brush.Bitmap.Free;
    Canvas.Brush.Bitmap := nil;
  end;
end;

function HitTest(R : TRect; Pt : TPoint; CornerSize, BorderSize : integer) : integer;
begin
  if not PtInRect(R, Pt) then
  begin
    result := HTNOWHERE;
    exit;
  end;
  if InRange(R.Left, R.Left + BorderSize - 1, Pt.X) then
  begin
    if Pt.Y <= (R.Top + CornerSize) then
    begin
      result := HTTOPLEFT;
      exit;
    end;
    if Pt.Y >= (R.Bottom - CornerSize - 1) then
    begin
      result := HTBOTTOMLEFT;
      exit;
    end;
    result := HTLEFT;
    exit;
  end
  else if InRange(R.Top, R.Top + BorderSize - 1, Pt.Y) then
  begin
    if PT.X <= (R.Left + CornerSize) then
    begin
      result := HTTOPLEFT;
      exit;
    end;
    if PT.x >= (R.Right - CornerSize - 1) then
    begin
      result := HTTOPRIGHT;
      exit;
    end;
    result := HTTOP;
    exit;
  end
  else if InRange(R.Bottom - BorderSize, R.Bottom - 1, Pt.Y) then
  begin
    if PT.X <= (R.Left + CornerSize) then
    begin
      result := HTBOTTOMLEFT;
      exit;
    end;
    if PT.x >= (R.Right - CornerSize - 1) then
    begin
      result := HTBOTTOMRIGHT;
      exit;
    end;
    result := HTBOTTOM;
    exit;
  end
  else if InRange(R.Right - BorderSize, R.Right - 1, Pt.X) then
  begin
    if Pt.Y <= (R.Top + CornerSize) then
    begin
      result := HTTOPRIGHT;
      exit;
    end;
    if Pt.Y >= (R.Bottom - CornerSize - 1) then
    begin
      result := HTBOTTOMRIGHT;
      exit;
    end;
    result := HTRIGHT;
    exit;
  end;
  result := HTCLIENT;
end;

function GetKeysState : integer;
begin
  result := 0;
  if GetKeyState(VK_CONTROL) < 0 then Result := result or MK_CONTROL;
  if GetKeyState(VK_Shift) < 0 then Result := result or MK_SHIFT;
end;

function GetShiftState : TShiftState;
begin
  result := [];
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if GetKeyState(VK_Shift) < 0 then Include(Result, ssShift);
end;

function GetTopOwnerControl(Component : TComponent) : TControl;
begin
  while (not (Component is TControl)) and (Component.Owner <> nil) do
    Component := Component.Owner;
  result := Component as TControl;
end;

function GetOwnerForm(Component : TComponent) : TForm;
begin
  result := nil;
  while (not (Component is TForm)) and (Component.Owner <> nil) do
    Component := Component.Owner;
  if Component is TForm then result := (Component as TForm);
end;

var
  WaitCount: Integer = 0;
  SaveCursor: TCursor = crDefault;

procedure StartWait;
begin
  if WaitCount = 0 then
  begin
    SaveCursor := Screen.Cursor;
    Screen.Cursor := WaitCursor;
  end;
  Inc(WaitCount);
end;

procedure StopWait;
begin
  if WaitCount > 0 then
  begin
    Dec(WaitCount);
    if WaitCount <= 0 then
       Screen.Cursor := SaveCursor;
  end;
end;

procedure DrawFlatScrollbarThumb(DC : HDC; rc : TRect; Focused : boolean);
begin
  if Focused then
    Draw3dBorder(DC, rc, COLOR_3DFACE, COLOR_3DDKSHADOW, COLOR_3DHIGHLIGHT, COLOR_3DSHADOW)
  else
    Draw3dBorder(DC, rc, COLOR_3DHIGHLIGHT, COLOR_3DSHADOW, COLOR_3DFACE, COLOR_3DFACE);
end;

procedure DrawFlatScrollBar(Wnd : HWND; DC : HDC; rect : TRect; nType : integer; bScrollbarCtrl : boolean; Dragging : boolean; Focused : boolean);
var
  nScrollSize : integer;
  nMinThumbSize : integer;
  RC1, RC2 : TRect;
  si : TScrollInfo;
  nRange : integer;
  nThumbPos,
    nThumbSize : integer;
  nScrollArea : integer;

begin
  nScrollSize := GetSystemMetrics(SM_CXHSCROLL);

   // The minimal thumb size depends on the system version
   // For Windows 98 minimal thumb size is a half of scrollbar size
   // and for Windows NT is always 8 pixels regardless of system metrics.
   // I really don't know why.
  if IsWin98 then // Windows 98 code
    nMinThumbSize := nScrollSize div 2
  else
    nMinThumbSize := 8;

   // Calculate the arrow rectangles
  rc1 := rect;
  rc2 := rect;

  if (nType = SB_HORZ) then
  begin
    if ((rect.right - rect.left) < 2 * nScrollSize) then //nScrollSize := ( rect.right - rect.left ) div 2;
      nScrollSize := Round((rect.right - rect.left) / 2);
    rc1.right := rect.left + nScrollSize;
    rc2.left := rect.right - nScrollSize;
  end
  else // SB_VERT
  begin
    if ((rect.bottom - rect.top) < 2 * nScrollSize) then nScrollSize := (rect.bottom - rect.top) div 2;
    rc1.bottom := rect.top + nScrollSize;
    rc2.top := rect.bottom - nScrollSize;
  end;
  if not Dragging then
  begin
     // Draw the scrollbar arrows
    DrawFlatScrollbarThumb(DC, rc1, Focused);
    DrawFlatScrollbarThumb(DC, rc2, Focused);
  end;

   // Disabled scrollbar never have a thumb
  if (bScrollbarCtrl and not (IsWindowEnabled(Wnd))) then exit;

  si.cbSize := sizeof(TSCROLLINFO);
  si.fMask := SIF_ALL;
  if bScrollbarCtrl
    then
    GetScrollInfo(Wnd, SB_CTL, si)
  else
    GetScrollInfo(Wnd, nType, si);

   // Calculate the size and position of the thumb
  nRange := si.nMax - si.nMin + 1;

  if (nRange <> 0) then
  begin
    if nType = SB_VERT
      then
      nScrollArea := (rect.bottom - rect.top) - 2 * nScrollSize
    else
      nScrollArea := (rect.right - rect.left) - 2 * nScrollSize;
    if (si.nPage = 0) then // If nPage is not set then thumb has default size
      nThumbSize := GetSystemMetrics(SM_CXHTHUMB)
    else
      nThumbSize := max(MulDiv(si.nPage, nScrollArea, nRange), nMinThumbSize);

    if (nThumbSize >= nScrollArea) then
    begin
      nThumbSize := nScrollArea;
      if (bScrollbarCtrl = FALSE) then exit;
    end;

    if (DWORD(nRange) = si.nPage) then
    begin
      nThumbPos := 0;
      dec(nThumbSize);
    end
    else
    begin
      if Dragging
        then
        nThumbPos := MulDiv(si.nTrackPos - si.nMin, nScrollArea - nThumbSize, nRange - si.nPage)
      else
        nThumbPos := MulDiv(si.nPos - si.nMin, nScrollArea - nThumbSize, nRange - si.nPage);
    end;

    if (nType = SB_VERT) then
    begin
      rc1.top := rc1.top + nScrollSize + nThumbPos;
      rc1.bottom := rc1.top + nThumbSize;
    end
    else // SB_HORZ
    begin
      rc1.left := rc1.left + nScrollSize + nThumbPos;
      rc1.right := rc1.left + nThumbSize;
    end;

    if (nThumbSize <= nScrollArea) then // Don't draw the thumb when it's larger than the scroll area
      DrawFlatScrollbarThumb(DC, rc1, Focused);
  end;
end;
{$WARNINGS on}

function DrawFlatScrollbars(Wnd : HWND; DC : HDC; Rect : TRect; Focused : boolean; ScrollBars : TScrollStyle; DragHorz, DragVert : boolean; IsControl : boolean): TRect;
var
  nFrameSize,
  hScrollSize,
  vScrollSize : integer;
  RC, RC1 : TRect;
  dwStyle : DWORD;
  st: integer;
begin
  if ScrollBars = ssNone then exit;
  dwStyle := GetWindowLong(Wnd, GWL_STYLE);
  st := GetWindowLong(Wnd, GWL_EXSTYLE);
  if ((dwStyle and WS_BORDER) = WS_BORDER) or ((st and WS_EX_CLIENTEDGE) = WS_EX_CLIENTEDGE) then
     nFrameSize := GetSystemMetrics(SM_CXEDGE)
  else
     nFrameSize := 0;
  hScrollSize := GetSystemMetrics(SM_CXHSCROLL);
  vScrollSize := GetSystemMetrics(SM_CYVSCROLL);
  GetClientRect(Wnd, Rc);
  GetWindowRect(Wnd, Rc1);
  OffsetRect(Rc1, - Rc1.Left, - Rc1.Top);

  if ScrollBars <> ssBoth then
  begin
    if ScrollBars = ssVertical then dwStyle := dwStyle and not WS_HSCROLL;
    if ScrollBars = ssHorizontal then dwStyle := dwStyle and not WS_VSCROLL;
  end;
  if ((dwStyle and WS_HSCROLL) <> 0) and ((dwStyle and WS_VSCROLL) <> 0)
     and ((Rc1.Right - Rc1.Left) - (Rc.Right - Rc.Left) >= nFrameSize + hScrollSize)
     and ((Rc1.Bottom - Rc1.Top) - (Rc.Bottom - Rc.Top) >= nFrameSize + vScrollSize) then
  begin
    rc.left := rect.left + nFrameSize;
    rc.top := rect.bottom - nFrameSize - vScrollSize;
    rc.right := rect.right - nFrameSize - hScrollSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBar(Wnd, DC, rc, SB_HORZ, IsControl, DragHorz, Focused);

    rc.left := rect.right - nFrameSize - hScrollSize;
    rc.top := rect.top + nFrameSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize - vScrollSize;
    DrawFlatScrollBar(Wnd, DC, rc, SB_VERT, IsControl, DragVert, Focused);
  end
  else
  if ((dwStyle and WS_VSCROLL) <> 0)
     and ((Rc1.Right - Rc1.Left) - (Rc.Right - Rc.Left) >= nFrameSize + hScrollSize) then
  begin
    rc.left := rect.right - nFrameSize - hScrollSize;
    rc.top := rect.top + nFrameSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBar(Wnd, DC, rc, SB_VERT, IsControl, DragVert, Focused);
  end
  else
  if ((dwStyle and WS_HSCROLL) <> 0)
     and ((Rc1.Bottom - Rc1.Top) - (Rc.Bottom - Rc.Top) >= nFrameSize + vScrollSize) then
  begin
    rc.left := rect.left + nFrameSize;
    rc.top := rect.bottom - nFrameSize - vScrollSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBar(Wnd, DC, rc, SB_HORZ, IsControl, DragHorz, Focused);
  end;
end;

{$warnings off}

procedure DrawFlatScrollBarEx(Wnd : HWND; DC : HDC; rect : TRect; nType :
    integer; bScrollbarCtrl : boolean; Dragging : boolean; Focused : boolean;
    BkColor, DitherColor, ButtonColor, ArrowColor, HotButtonColor : TColor;
    DrawFrames, DitherBack : boolean);
var
  nScrollSize : integer;
  nMinThumbSize : integer;
  RC1, RC2 : TRect;
  si : TScrollInfo;
  nRange : integer;
  nThumbPos,
    nThumbSize : integer;
  nScrollArea : integer;

begin
  nScrollSize := GetSystemMetrics(SM_CXHSCROLL);

   // The minimal thumb size depends on the system version
   // For Windows 98 minimal thumb size is a half of scrollbar size
   // and for Windows NT is always 8 pixels regardless of system metrics.
   // I really don't know why.
  if IsWin98 then // Windows 98 code
    nMinThumbSize := nScrollSize div 2
  else
    nMinThumbSize := 8;

   // Calculate the arrow rectangles
  rc1 := rect;
  rc2 := rect;

  if (nType = SB_HORZ) then
  begin
    if ((rect.right - rect.left) < 2 * nScrollSize) then //nScrollSize := ( rect.right - rect.left ) div 2;
      nScrollSize := Round((rect.right - rect.left) / 2);
    rc1.right := rect.left + nScrollSize;
    rc2.left := rect.right - nScrollSize;
  end
  else // SB_VERT
  begin
    if ((rect.bottom - rect.top) < 2 * nScrollSize) then nScrollSize := (rect.bottom - rect.top) div 2;
    rc1.bottom := rect.top + nScrollSize;
    rc2.top := rect.bottom - nScrollSize;
  end;
  if not Dragging then
  begin
     // Draw the scrollbar arrows
    DrawFlatScrollbarThumb(DC, rc1, Focused);
    DrawFlatScrollbarThumb(DC, rc2, Focused);
  end;

   // Disabled scrollbar never have a thumb
  if (bScrollbarCtrl and not (IsWindowEnabled(Wnd))) then exit;

  si.cbSize := sizeof(TSCROLLINFO);
  si.fMask := SIF_ALL;
  if bScrollbarCtrl
    then
    GetScrollInfo(Wnd, SB_CTL, si)
  else
    GetScrollInfo(Wnd, nType, si);

   // Calculate the size and position of the thumb
  nRange := si.nMax - si.nMin + 1;

  if (nRange <> 0) then
  begin
    if nType = SB_VERT
      then
      nScrollArea := (rect.bottom - rect.top) - 2 * nScrollSize
    else
      nScrollArea := (rect.right - rect.left) - 2 * nScrollSize;
    if (si.nPage = 0) then // If nPage is not set then thumb has default size
      nThumbSize := GetSystemMetrics(SM_CXHTHUMB)
    else
      nThumbSize := max(MulDiv(si.nPage, nScrollArea, nRange), nMinThumbSize);

    if (nThumbSize >= nScrollArea) then
    begin
      nThumbSize := nScrollArea;
      if (bScrollbarCtrl = FALSE) then exit;
    end;

    if (DWORD(nRange) = si.nPage) then
    begin
      nThumbPos := 0;
      dec(nThumbSize);
    end
    else
    begin
      if Dragging
        then
        nThumbPos := MulDiv(si.nTrackPos - si.nMin, nScrollArea - nThumbSize, nRange - si.nPage)
      else
        nThumbPos := MulDiv(si.nPos - si.nMin, nScrollArea - nThumbSize, nRange - si.nPage);
    end;

    if (nType = SB_VERT) then
    begin
      rc1.top := rc1.top + nScrollSize + nThumbPos;
      rc1.bottom := rc1.top + nThumbSize;
    end
    else // SB_HORZ
    begin
      rc1.left := rc1.left + nScrollSize + nThumbPos;
      rc1.right := rc1.left + nThumbSize;
    end;

    if (nThumbSize <= nScrollArea) then // Don't draw the thumb when it's larger than the scroll area
      DrawFlatScrollbarThumb(DC, rc1, Focused);
  end;
end;

procedure DrawFlatScrollBarsEx(Wnd : HWND; DC : HDC; Rect : TRect; Focused :
    boolean; ScrollBars : TScrollStyle; DragHorz, DragVert : boolean; IsControl
    : boolean; BkColor, DitherColor,  ButtonColor, ArrowColor, HotButtonColor :
    TColor; DrawFrames, DitherBack : boolean);
var
  nFrameSize,
  hScrollSize,
  vScrollSize : integer;
  RC, RC1 : TRect;
  dwStyle : DWORD;
  st: integer;
begin
  if ScrollBars = ssNone then exit;
  dwStyle := GetWindowLong(Wnd, GWL_STYLE);
  st := GetWindowLong(Wnd, GWL_EXSTYLE);
  if ((dwStyle and WS_BORDER) = WS_BORDER) or ((st and WS_EX_CLIENTEDGE) = WS_EX_CLIENTEDGE) then
     nFrameSize := GetSystemMetrics(SM_CXEDGE)
  else
     nFrameSize := 0;
  hScrollSize := GetSystemMetrics(SM_CXHSCROLL);
  vScrollSize := GetSystemMetrics(SM_CYVSCROLL);
  GetClientRect(Wnd, Rc);
  GetWindowRect(Wnd, Rc1);
  OffsetRect(Rc1, - Rc1.Left, - Rc1.Top);

  if ScrollBars <> ssBoth then
  begin
    if ScrollBars = ssVertical then dwStyle := dwStyle and not WS_HSCROLL;
    if ScrollBars = ssHorizontal then dwStyle := dwStyle and not WS_VSCROLL;
  end;
  if ((dwStyle and WS_HSCROLL) <> 0) and ((dwStyle and WS_VSCROLL) <> 0)
     and ((Rc1.Right - Rc1.Left) - (Rc.Right - Rc.Left) >= nFrameSize + hScrollSize)
     and ((Rc1.Bottom - Rc1.Top) - (Rc.Bottom - Rc.Top) >= nFrameSize + vScrollSize) then
  begin
    rc.left := rect.left + nFrameSize;
    rc.top := rect.bottom - nFrameSize - vScrollSize;
    rc.right := rect.right - nFrameSize - hScrollSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBarEx(Wnd, DC, rc, SB_HORZ, IsControl, DragHorz, Focused,
                        BkColor, DitherColor, ButtonColor, ArrowColor,
                        HotButtonColor, DrawFrames, DitherBack);

    rc.left := rect.right - nFrameSize - hScrollSize;
    rc.top := rect.top + nFrameSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize - vScrollSize;
    DrawFlatScrollBarEx(Wnd, DC, rc, SB_VERT, IsControl, DragVert, Focused,
                        BkColor, DitherColor, ButtonColor, ArrowColor,
                        HotButtonColor, DrawFrames, DitherBack);
  end
  else
  if ((dwStyle and WS_VSCROLL) <> 0)
     and ((Rc1.Bottom - Rc1.Top) - (Rc.Bottom - Rc.Top) >= nFrameSize + vScrollSize) then
  begin
    rc.left := rect.right - nFrameSize - hScrollSize;
    rc.top := rect.top + nFrameSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBarEx(Wnd, DC, rc, SB_VERT, IsControl, DragVert, Focused,
                        BkColor, DitherColor, ButtonColor, ArrowColor,
                        HotButtonColor, DrawFrames, DitherBack);
  end
  else
  if ((dwStyle and WS_HSCROLL) <> 0)
     and ((Rc1.Right - Rc1.Left) - (Rc.Right - Rc.Left) >= nFrameSize + hScrollSize) then
  begin
    rc.left := rect.left + nFrameSize;
    rc.top := rect.bottom - nFrameSize - vScrollSize;
    rc.right := rect.right - nFrameSize;
    rc.bottom := rect.bottom - nFrameSize;
    DrawFlatScrollBarEx(Wnd, DC, rc, SB_HORZ, IsControl, DragHorz, Focused,
                        BkColor, DitherColor, ButtonColor, ArrowColor,
                        HotButtonColor, DrawFrames, DitherBack);
  end;
end;

{$warnings on}

initialization

  ParentControlRepaintedMessage := RegisterWindowMessage('Transparent controls notification -- parent repainted');

end.
