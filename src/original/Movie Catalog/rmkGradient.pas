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

unit rmkGradient;

interface

uses
  Windows, Messages, Graphics, Types, TBXUtils;

type
  TGradDir = (tgLeftRight, tgTopBottom);

// ---
{ LOW LEVEL }
function GradientFillWinEnabled: Boolean;
function GradientFillWin(DC: HDC; PVertex: Pointer; NumVertex: Cardinal;
  PMesh: Pointer; NumMesh, Mode: Cardinal): BOOL;
{ HIGH LEVEL }
procedure GradientFill(DC: HDC; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir); overload;
procedure GradientFill(Canvas: TCanvas; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir); overload;

{ Redeclare TRIVERTEX }
type
  {$EXTERNALSYM COLOR16}
  COLOR16 = Word; { in Delphi Windows.pas wrong declared as Shortint }

  PTriVertex = ^TTriVertex;
  {$EXTERNALSYM _TRIVERTEX}
  _TRIVERTEX = packed record
    x     : Longint;
    y     : Longint;
    Red   : COLOR16;
    Green : COLOR16;
    Blue  : COLOR16;
    Alpha : COLOR16;
  end;
  TTriVertex = _TRIVERTEX;
  {$EXTERNALSYM TRIVERTEX}
  TRIVERTEX = _TRIVERTEX;
// ---


implementation

// ---
type
  TGradientFillWin = function(DC: HDC; PVertex: Pointer; NumVertex: ULONG;
    Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
  TGradientFill = procedure(DC: HDC; const ARect: TRect;
    StartColor, EndColor: TColor; Direction: TGradDir);
var
  InitDone        : Boolean = False;
  MSImg32Module   : THandle;
  GradFillWinProc : TGradientFillWin;
  GradFillProc    : TGradientFill;
// ----

// Code belowe is from Vladimir Bochkarev

(******************************************************************************)
procedure
  InitializeGradientFill; forward;
(******************************************************************************)
{ GradientFillWin }
(******************************************************************************)
function GradFillWinInitProc(DC: HDC; PVertex: Pointer; NumVertex: ULONG;
  Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
begin
  InitializeGradientFill;
  Result := GradFillWinProc(DC, PVertex, NumVertex, Mesh, NumMesh, Mode);
end;
(******************************************************************************)
function GradFillWinNone(DC: HDC; PVertex: Pointer; NumVertex: ULONG;
  Mesh: Pointer; NumMesh, Mode: ULONG): BOOL; stdcall;
begin
  Result := False;
end;
(******************************************************************************)
function GradientFillWin(DC: HDC; PVertex: Pointer; NumVertex: Cardinal;
  PMesh: Pointer; NumMesh, Mode: Cardinal): BOOL;
begin
  Result := GradFillWinProc(DC, PVertex, NumVertex, PMesh, NumMesh, Mode);
end;
(******************************************************************************)
function GradientFillWinEnabled: Boolean;
begin
  if not InitDone then InitializeGradientFill;
  Result := @GradFillWinProc <> @GradFillWinNone;
end;
(******************************************************************************)
{ GradientFill }
(******************************************************************************)
procedure GradFillInitProc(DC: HDC; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir);
begin
  InitializeGradientFill;
  GradFillProc(DC, ARect, StartColor, EndColor, Direction);
end;
(*****************************************************************************)
procedure GradFillInt(DC: HDC; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir);
var
  FillRect    : TRect;
  RS, GS, BS  : TColor;
  RE, GE, BE  : TColor;
  LineCount   : Integer;
  CurLine     : Integer;
  //----------------------------------------------------------------------------
  procedure InternalFillRect;
  var Brush: HBRUSH;
  begin
    Brush := CreateSolidBrush(
      RGB((RS+ (((RE- RS)* CurLine) div LineCount)),
          (GS+ (((GE- GS)* CurLine) div LineCount)),
          (BS+ (((BE- BS)* CurLine) div LineCount))));
    Windows.FillRect(DC, FillRect, Brush);
    DeleteObject(Brush);
  end;
  //----------------------------------------------------------------------------
begin
  FillRect := ARect;
  if StartColor < 0 then
    StartColor := Integer(GetSysColor(StartColor and $000000FF));
  if EndColor < 0 then
    EndColor := Integer(GetSysColor(EndColor and $000000FF));
  RS := GetRValue(Cardinal(StartColor));
  GS := GetGValue(Cardinal(StartColor));
  BS := GetBValue(Cardinal(StartColor));
  RE := GetRValue(Cardinal(EndColor));
  GE := GetGValue(Cardinal(EndColor));
  BE := GetBValue(Cardinal(EndColor));
  if Direction = tgLeftRight then begin
    FillRect.Right := FillRect.Left+ 1;
    LineCount := ARect.Right- ARect.Left;
    for CurLine := 1 to LineCount do begin
      InternalFillRect;
      Inc(FillRect.Left);
      Inc(FillRect.Right);
    end;
  end else begin
    FillRect.Bottom := FillRect.Top+ 1;
    LineCount := ARect.Bottom- ARect.Top;
    for CurLine := 1 to LineCount do begin
      InternalFillRect;
      Inc(FillRect.Top);
      Inc(FillRect.Bottom);
    end;
  end;
end;
(******************************************************************************)

procedure GradFillWin(DC: HDC; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir);
var
  Vertexs: array[0..1] of TTriVertex;
  //----------------------------------------------------------------------------
  procedure SetVertex(Index, AX, AY, AColor: TColor);
  begin
    with Vertexs[Index] do begin
      X     := AX;
      Y     := AY;
      Red   := (AColor and $000000FF) shl 8;
      Green := (AColor and $0000FF00);
      Blue  := (AColor and $00FF0000) shr 8;
      Alpha := 0;
    end;
  end;
  //----------------------------------------------------------------------------
var
  GRect : TGradientRect;
  Mode  : Cardinal;
begin
  if StartColor < 0 then
    StartColor := Integer(GetSysColor(StartColor and $000000FF));
  if EndColor < 0 then
    EndColor := Integer(GetSysColor(EndColor and $000000FF));
  SetVertex(0, ARect.Left, ARect.Top, StartColor);
  SetVertex(1, ARect.Right, ARect.Bottom, EndColor);
  with GRect do begin
    UpperLeft  := 0;
    LowerRight := 1;
  end;
  if Direction = tgLeftRight
    then Mode := GRADIENT_FILL_RECT_H
    else Mode := GRADIENT_FILL_RECT_V;
  GradientFillWin(DC, @Vertexs, 2, @GRect, 1, Mode);
end;

(******************************************************************************)
procedure GradientFill(DC: HDC; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir);
begin
  GradFillProc(DC, ARect, StartColor, EndColor, Direction);
end;

(******************************************************************************)
procedure GradientFill(Canvas: TCanvas; const ARect: TRect;
  StartColor, EndColor: TColor; Direction: TGradDir);
begin
  GradientFill(Canvas.Handle, ARect, EndColor, StartColor, Direction);
end;

{ Initializations }
(******************************************************************************)
procedure InitializeGradientFill;
begin
  if InitDone then Exit;
  MSImg32Module := LoadLibrary('msimg32.dll');
  if MSImg32Module <> 0
    then GradFillWinProc := GetProcAddress(MSImg32Module, 'GradientFill')
    else GradFillWinProc := nil;
  if @GradFillWinProc = nil then
  begin
    GradFillWinProc := GradFillWinNone;
    GradFillProc    := GradFillInt;
  end
  else GradFillProc := GradFillWin;
  InitDone := True;
end;
(******************************************************************************)
procedure UninitializeGradientFill;
begin
  if MSImg32Module <> 0 then FreeLibrary(MSImg32Module);
end;
(******************************************************************************)
initialization
  GradFillWinProc := GradFillWinInitProc;
  GradFillProc    := GradFillInitProc;
finalization
  UninitializeGradientFill;
(******************************************************************************)
end.
