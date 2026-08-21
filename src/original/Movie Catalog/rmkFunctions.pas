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

unit rmkFunctions;

interface

uses
  Windows, Classes, SysUtils, Graphics;

type
  PRGB24 = ^TRGB24;
  TRGB24 = record B, G, R: Byte;
  end;
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..0] of TRGB24;
  
function BytesToStr(const i64Size: Int64): string;
procedure MakeThumbNail(Src, Dst: TBitmap);
function Blend(Color1, Color2: TColor; A: Byte): TColor;
procedure BiResample(Src, Dest: TBitmap; Sharpen: Boolean);
procedure DrawLine(Canvas : TCanvas; StartX, StartY, EndX, EndY : integer);
procedure DrawDotLine(Canvas : TCanvas; StartX, StartY, EndX, EndY : integer);

  
implementation

function BytesToStr(const i64Size: Int64): string;
const
  i64GB = 1024 * 1024 * 1024;
  i64MB = 1024 * 1024;
  i64KB = 1024;
begin
  if i64Size div i64GB > 0 then
    Result := Format('%.1f GB', [i64Size / i64GB])
  else if i64Size div i64MB > 0 then
    Result := Format('%.2f MB', [i64Size / i64MB])
  else if i64Size div i64KB > 0 then
    Result := Format('%.0f kB', [i64Size / i64KB])
  else
    Result := IntToStr(i64Size) + ' byte';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure MakeThumbNail(Src, Dst: TBitmap);
var
  x, y, ix, iy, w, h, dx, dy: Integer;
  x1, x2, x3: integer;
  RowDest, RowSource, RowSourceStart: Integer;
  iRatio: Cardinal;
  Ratio: Single;
  iRed, iGrn, iBlu: Cardinal;
  pt: PRGB24;
  iSrc, iDst: Integer;
  lutW, lutH: array of Integer;
begin
  if (Src.Width <= Dst.Width) and (Src.Height <= Dst.Height) then
  begin
    Dst.Assign(Src);
    Exit;
  end;
  w := Dst.Width;
  h := Dst.Height;
  Ratio := 1 / (w / Src.Width);
  SetLength(lutW, w);
  x1 := 0;
  x2 := Trunc(Ratio);
  for x := 0 to w - 1 do
  begin
    lutW[x] := x2 - x1;
    x1 := x2;
    x2 := Trunc((x + 2) * Ratio);
  end;
  Ratio := 1 / (h / Src.Height);
  SetLength(lutH, h);
  x1 := 0;
  x2 := Trunc(Ratio);
  for x := 0 to h - 1 do
  begin
    lutH[x] := x2 - x1;
    x1 := x2;
    x2 := Trunc((x + 2) * Ratio);
  end;
  RowDest := Integer(Dst.Scanline[0]);
  RowSourceStart := integer(Src.Scanline[0]);
  RowSource := RowSourceStart;
  iDst := ((w * 24 + 31) and not 31) shr 3;
  iSrc := ((Src.Width * 24 + 31) and not 31) shr 3;
  for y := 0 to h - 1 do
  begin
    dy := lutH[y];
    x1 := 0;
    x3 := 0;
    for x := 0 to w - 1 do
    begin
      dx := lutW[x];
      iRed := 0;
      iGrn := 0;
      iBlu := 0;
      RowSource := RowSourceStart;
      for iy := 1 to dy do
      begin
        pt := PRGB24(RowSource + x1);
        for ix := 1 to dx do
        begin
          iRed := iRed + pt.R;
          iGrn := iGrn + pt.G;
          iBlu := iBlu + pt.B;
          inc(pt);
        end;
        RowSource := RowSource - iSrc;
      end;
      iRatio := $00FFFFFF div (dx * dy);
      pt := PRGB24(RowDest + x3);
      pt.R := (iRed * iRatio) shr 24;
      pt.G := (iGrn * iRatio) shr 24;
      pt.B := (iBlu * iRatio) shr 24;
      x1 := x1 + 3 * dx;
      inc(x3, 3);
    end;
    RowDest := RowDest - iDst;
    RowSourceStart := RowSource;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function Blend(Color1, Color2: TColor; A: Byte): TColor;
var
  c1, c2: LongInt;
  r, g, b, v1, v2: byte;
begin
  A := Round(2.55 * A);
  c1 := ColorToRGB(Color1);
  c2 := ColorToRGB(Color2);
  v1 := Byte(c1);
  v2 := Byte(c2);
  r := A * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 8);
  v2 := Byte(c2 shr 8);
  g := A * (v1 - v2) shr 8 + v2;
  v1 := Byte(c1 shr 16);
  v2 := Byte(c2 shr 16);
  b := A * (v1 - v2) shr 8 + v2;
  Result := (b shl 16) + (g shl 8) + r;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure BiReSample(src, Dest: TBitmap; Sharpen: Boolean); // RMK
type
  TRGB24 = record
    B, G, R: Byte;
  end;
  PRGBArray = ^TRGBArray;
  TRGBArray = array[0..0] of TRGB24;
var
  x, y, px, py: Integer;
  i, x1, x2, z, z2, iz2: Integer;
  w1, w2, w3, w4: Integer;
  Ratio: Integer;
  sDst, sDstOff: Integer;
  sScanLine: array[0..255] of PRGBArray;
  Src1, Src2: PRGBArray;
  C, C1, C2: TRGB24;
  y1, y2, y3, x3, iRed, iGrn, iBlu: Integer;
  p1, p2, p3, p4, p5: PRGB24;
begin
  // ScanLine buffer for Source
  sDst := Integer(src.Scanline[0]);
  sDstOff := Integer(src.Scanline[1]) - sDst;
  for i := 0 to src.Height - 1 do
  begin
    sScanLine[i] := PRGBArray(sDst);
    sDst := sDst + sDstOff;
  end;
  // ScanLine for Destiantion
  sDst := Integer(Dest.Scanline[0]);
  y1 := sDst; // only for sharpening...
  sDstOff := Integer(Dest.Scanline[1]) - sDst;
  // Ratio is same for width and height
  Ratio := ((src.Width - 1) shl 15) div Dest.Width;
  py := 0;
  for y := 0 to Dest.Height - 1 do
  begin
    i := py shr 15;
    if i > src.Height - 1 then
      i := src.Height - 1;
    Src1 := sScanLine[i];
    if i < src.Height - 1 then
      Src2 := sScanLine[i + 1]
    else
      Src2 := Src1;
    z2 := py and $7FFF;
    iz2 := $8000 - z2;
    px := 0;
    for x := 0 to Dest.Width - 1 do
    begin
      x1 := px shr 15;
      x2 := x1 + 1;
      C1 := Src1[x1];
      C2 := Src2[x1];
      z := px and $7FFF;
      w2 := (z * iz2) shr 15;
      w1 := iz2 - w2;
      w4 := (z * z2) shr 15;
      w3 := z2 - w4;
      C.R := (C1.R * w1 + Src1[x2].R * w2 + C2.R * w3 + Src2[x2].R * w4) shr 15;
      C.G := (C1.G * w1 + Src1[x2].G * w2 + C2.G * w3 + Src2[x2].G * w4) shr 15;
      C.B := (C1.B * w1 + Src2[x2].B * w2 + C2.B * w3 + Src2[x2].B * w4) shr 15;
      // Set destination pixel
      PRGBArray(sDst)[x] := C;
      inc(px, Ratio);
    end;
    sDst := sDst + sDstOff;
    inc(py, Ratio);
  end;

  if not Sharpen then
    Exit;

  // Sharpening...
  y2 := y1 + sDstOff;
  y3 := y2 + sDstOff;
  for y := 1 to Dest.Height - 2 do
  begin
    for x := 0 to Dest.Width - 3 do
    begin
      x1 := x * 3;
      x2 := x1 + 3;
      x3 := x1 + 6;
      p1 := PRGB24(y1 + x1);
      p2 := PRGB24(y1 + x3);
      p3 := PRGB24(y2 + x2);
      p4 := PRGB24(y3 + x1);
      p5 := PRGB24(y3 + x3);
      // -15 -11                       // -17 - 13
      iRed := (p1.R + p2.R + (p3.R * -15) + p4.R + p5.R) div -11;
      iGrn := (p1.G + p2.G + (p3.G * -15) + p4.G + p5.G) div -11;
      iBlu := (p1.B + p2.B + (p3.B * -15) + p4.B + p5.B) div -11;
      if iRed < 0 then
        iRed := 0
      else if iRed > 255 then
        iRed := 255;
      if iGrn < 0 then
        iGrn := 0
      else if iGrn > 255 then
        iGrn := 255;
      if iBlu < 0 then
        iBlu := 0
      else if iBlu > 255 then
        iBlu := 255;
      PRGB24(y2 + x2).R := iRed;
      PRGB24(y2 + x2).G := iGrn;
      PRGB24(y2 + x2).B := iBlu;
    end;
    inc(y1, sDstOff);
    inc(y2, sDstOff);
    inc(y3, sDstOff);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure DrawLine(Canvas : TCanvas; StartX, StartY, EndX, EndY : integer);
begin
  if StartX = EndX then
  begin
    // draw vertical line
    Canvas.MoveTo(StartX, StartY);
    Canvas.LineTo(StartX, EndY);
  end
  else
  begin
    // draw horizontal line
    Canvas.MoveTo(StartX, StartY);
    Canvas.LineTo(EndX, StartY);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure DrawDotLine(Canvas : TCanvas; StartX, StartY, EndX, EndY : integer);
var
  Coord: Integer;
begin
  Coord := 0;
  if StartX = EndX then
  begin
    // draw vertical line
    Inc(Coord, StartY);
    while Coord <= EndY do
    begin
      Canvas.MoveTo(StartX, Coord);
      Inc(Coord, 1);
      Canvas.LineTo(StartX, Coord);
      Inc(Coord, 1);
    end;
  end
  else
  begin
    // draw horizontal line
    Inc(Coord, StartX);
    while Coord <= EndX do
    begin
      Canvas.MoveTo(Coord, StartY);
      Inc(Coord, 1);
      Canvas.LineTo(Coord, StartY);
      Inc(Coord, 1);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.