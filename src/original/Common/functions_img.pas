(************************************************************************
 *                                                                      *
 *   (C) 2013 Antoine Potten, Mickaël Vanneufville                      *
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
 
{-------------------------------------------------------------------------------
 With help of this page: http://www.swissdelphicenter.ch/en/showcode.php?id=1698
-------------------------------------------------------------------------------}

unit functions_img;

interface

uses Windows, Classes, SysUtils, Graphics, JPEG;

function ReadMWord(stream: TStream): Word;
procedure GetImageSize(const stream: TStream; ext: string; var wWidth, wHeight: Integer);
procedure GetImageSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
procedure GetJPGSize(const stream: TStream; var wWidth, wHeight: Integer);
procedure GetJPGSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
procedure GetPNGSize(const stream: TStream; var wWidth, wHeight: Integer);
procedure GetPNGSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
procedure GetGIFSize(const stream: TStream; var wWidth, wHeight: Integer);
procedure GetGIFSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
procedure GetBMPSize(const stream: TStream; var wWidth, wHeight: Integer);
procedure GetBMPSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
function CalcImageSize(w, h, maxw, maxh: Integer): TPoint;
function ConvertImage(const stream: TStream; ext: string; MaxWidth: Integer = -1;
  MaxHeight: Integer = -1; ForceConvert: Boolean = False): TJPEGImage;
function ConvertImageFromFile(const sFile: string; MaxWidth: Integer = -1;
  MaxHeight: Integer = -1; ForceConvert: Boolean = False): TJPEGImage;

implementation

uses
  PNGImage, AntJvGIF;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ReadMWord(stream: TStream): Word;
type
  TMotorolaWord = record
    case Byte of
      0: (Value: Word);
      1: (Byte1, Byte2: Byte);
  end;
var
  MW: TMotorolaWord;
begin
  { It would probably be better to just read these two bytes in normally }
  { and then do a small ASM routine to swap them.  But we aren't talking }
  { about reading entire files, so I doubt the performance gain would be }
  { worth the trouble. }
  stream.read(MW.Byte2, SizeOf(Byte));
  stream.read(MW.Byte1, SizeOf(Byte));
  Result := MW.Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetImageSize(const stream: TStream; ext: string; var wWidth, wHeight: Integer);
begin
  ext := AnsiLowerCase(ext);
  if ext = '.bmp' then
    GetBMPSize(stream, wWidth, wHeight)
  else if ext = '.gif' then
    GetGIFSize(stream, wWidth, wHeight)
  else if (ext = '.jpg') or
    (ext = '.jpeg') or
    (ext = '.jpe') then
    GetJPGSize(stream, wWidth, wHeight)
  else if ext = '.png' then
    GetPNGSize(stream, wWidth, wHeight)
  else
  begin
    wWidth := 0;
    wHeight := 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetImageSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
var
  ext: string;
begin
  ext := AnsiLowerCase(ExtractFileExt(sFile));
  if ext = '.bmp' then
    GetBMPSizeFromFile(sFile, wWidth, wHeight)
  else if ext = '.gif' then
    GetGIFSizeFromFile(sFile, wWidth, wHeight)
  else if (ext = '.jpg') or (ext = '.jpeg') or (ext = '.jpe') then
    GetJPGSizeFromFile(sFile, wWidth, wHeight)
  else if ext = '.png' then
    GetPNGSizeFromFile(sFile, wWidth, wHeight)
  else
  begin
    wWidth := 0;
    wHeight := 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetJPGSize(const stream: TStream; var wWidth, wHeight: Integer);
const
  ValidSig: array[0..1] of Byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Sig: array[0..1] of byte;
  x: integer;
  Seg: byte;
  Dummy: array[0..15] of byte;
  Len: word;
  ReadLen: LongInt;
  Img: TJPEGImage;
begin
  wWidth := 0;
  wHeight := 0;
  if (stream <> nil) then
  begin
    FillChar(Sig, SizeOf(Sig), #0);
    try
      stream.Seek(0, soBeginning);
      ReadLen := stream.read(Sig[0], SizeOf(Sig));
      for x := Low(Sig) to High(Sig) do
        if Sig[x] <> ValidSig[x] then
          ReadLen := 0;
      if ReadLen > 0 then
      begin
        ReadLen := stream.read(Seg, 1);
        while (Seg = $FF) and (ReadLen > 0) do
        begin
          ReadLen := stream.read(Seg, 1);
          if Seg <> $FF then
          begin
            if (Seg = $C0) or (Seg = $C1) then
            begin
              ReadLen := stream.read(Dummy[0], 3); { don't need these bytes }
              wHeight := ReadMWord(stream);
              wWidth := ReadMWord(stream);
            end
            else
            begin
              if not (Seg in Parameterless) then
              begin
                Len := ReadMWord(stream);
                stream.Seek(Len - 2, 1);
                stream.read(Seg, 1);
              end
              else
                Seg := $FF; { Fake it to keep looping. }
            end;
          end;
        end;
      end;
      if (wWidth = 0) or (wHeight = 0) then
      begin
        Img := TJPEGImage.Create;
        try
          stream.Seek(0, soBeginning);
          Img.LoadFromStream(stream);
          wHeight := Img.Height;
          wWidth := Img.Width;
        finally
          FreeAndNil(Img);
        end;
      end;
    except
      raise;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetJPGSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
var
  f: TFileStream;
begin
  wWidth := 0;
  wHeight := 0;
  if(FileExists(sFile)) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    GetJPGSize(f, wWidth, wHeight);
    f.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetPNGSize(const stream: TStream; var wWidth, wHeight: Integer);
type
  TPNGSig = array[0..7] of Byte;
const
  ValidSig: TPNGSig = (137, 80, 78, 71, 13, 10, 26, 10);
var
  Sig: TPNGSig;
  x: integer;
  Img: TPNGObject;
  ReadLen: LongInt;
begin
  wWidth := 0;
  wHeight := 0;
  if (stream <> nil) then
  begin
    try
      stream.Seek(0, soBeginning);
      FillChar(Sig, SizeOf(Sig), #0);
      ReadLen := stream.read(Sig[0], SizeOf(Sig));
      for x := Low(Sig) to High(Sig) do
        if Sig[x] <> ValidSig[x] then
          ReadLen := 0;
      if ReadLen > 0 then
      begin
        stream.Seek(18, 0);
        wWidth := ReadMWord(stream);
        stream.Seek(22, 0);
        wHeight := ReadMWord(stream);
      end;
      if (wWidth = 0) or (wHeight = 0) then
      begin
        Img := TPNGObject.Create;
        try
          stream.Seek(0, soBeginning);
          Img.LoadFromStream(stream);
          wHeight := Img.Height;
          wWidth := Img.Width;
        finally
          FreeAndNil(Img);
        end;
      end;
    except
      raise;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetPNGSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
var
  f: tFileStream;
begin
  wWidth := 0;
  wHeight := 0;
  if FileExists(sFile) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    try
      GetPNGSize(f, wWidth, wHeight);
    finally
      f.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetGIFSize(const stream: TStream; var wWidth, wHeight: Integer);
type
  TGIFHeader = record
    Sig: array[0..5] of char;
    ScreenWidth, ScreenHeight: Word;
    Flags, Background, Aspect: Byte;
  end;

  TGIFImageBlock = record
    Left, Top, Width, Height: Word;
    Flags: Byte;
  end;
var
  Header: TGifHeader;
  ImageBlock: TGifImageBlock;
  ReadLen: LongInt;
  x: integer;
  c: char;
  DimensionsFound: boolean;
  Img: TJvGIFImage;
begin
  wWidth  := 0;
  wHeight := 0;
  if stream <> nil then
  begin
    try
      { Read header and ensure valid file. }
      stream.Seek(0, soBeginning);
      ReadLen := stream.read(Header, SizeOf(TGifHeader));
      if (ReadLen = SizeOf(TGifHeader)) and
        (StrLComp('GIF', Header.Sig, 3) = 0) then
      begin
        { Skip color map, if there is one }
        if (Header.Flags and $80) > 0 then
        begin
          x := 3 * (1 shl ((Header.Flags and 7) + 1));
          stream.Seek(x, 0);
        end;

        DimensionsFound := False;
        FillChar(ImageBlock, SizeOf(TGIFImageBlock), #0);
        { Step through blocks. }
        ReadLen := stream.Read(c, 1);
        while (ReadLen > 0) and (not DimensionsFound) do
        begin
          case c of
            ',': { Found image }
              begin
                ReadLen := stream.Read(ImageBlock, SizeOf(TGIFImageBlock));
                if ReadLen = SizeOf(TGIFImageBlock) then
                begin
                  wWidth := ImageBlock.Width;
                  wHeight := ImageBlock.Height;
                  DimensionsFound := True;
                end;
              end;
            'ÿ': { Skip }
              begin
                { NOP }
              end;
            { nothing else.  just ignore }
          end;
          ReadLen := stream.Read(c, 1);
        end;
      end;

      if (wWidth = 0) or (wHeight = 0) then
      begin
        Img := TJvGIFImage.Create;
        try
          stream.Seek(0, soBeginning);
          Img.LoadFromStream(stream);
          wHeight := Img.Height;
          wWidth := Img.Width;
        finally
          FreeAndNil(Img);
        end;
      end;
    except
      raise;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetGIFSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
var
  f: tFileStream;
begin
  wWidth := 0;
  wHeight := 0;
  if FileExists(sFile) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    try
      GetGIFSize(f, wWidth, wHeight);
    finally
      f.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetBMPSize(const stream: TStream; var wWidth, wHeight: Integer);
const
  BMP_MAGIC_WORD = ord('M') shl 8 or ord('B');
var
  Header: TBitmapFileHeader;
  Info: TBitmapInfoHeader;
  Img: TBitmap;
begin
  wWidth := 0;
  wHeight := 0;
  if (stream <> nil) then
  begin
    try
      stream.Seek(0, soBeginning);
      if stream.Read(header, sizeof(Header)) = sizeof(Header) then
        if Header.bfType = BMP_MAGIC_WORD then
          if stream.Read(info, sizeof(Info)) = sizeof(Info) then
          begin
            wWidth := abs(Info.biWidth);
            wHeight := abs(Info.biHeight);
          end;
      if (wWidth = 0) or (wHeight = 0) then
      begin
        Img := TBitmap.Create;
        try
          stream.Seek(0, soBeginning);
          Img.LoadFromStream(stream);
          wHeight := Img.Height;
          wWidth := Img.Width;
        finally
          FreeAndNil(Img);
        end;
      end;
    except
      raise;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure GetBMPSizeFromFile(const sFile: string; var wWidth, wHeight: Integer);
var
  f: TFileStream;
begin
  wWidth := 0;
  wHeight := 0;
  if FileExists(sFile) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    try
      GetBMPSize(f, wWidth, wHeight);
    finally
      f.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CalcImageSize(w, h, maxw, maxh: Integer): TPoint;
begin
  Result.X := 0;
  Result.Y := 0;
  if (w = 0) or (h = 0) then
    exit
  else if (w <= maxw) and (h <= maxh) then
  begin
    Result.X := w;
    Result.Y := h;
  end
  else
  begin
    if w > h then
    begin
      if w < maxw then
        maxw := w;
      Result.X := maxw;
      Result.Y := Trunc(maxw * h / w);
      if Result.Y > maxh then
      begin
        Result.Y := maxh;
        Result.X := Trunc(maxh * w / h);
      end;
    end
    else
    begin
      if h < maxh then
        maxh := h;
      Result.Y := maxh;
      Result.X := Trunc(maxh * w / h);
      if Result.X > maxw then
      begin
        Result.X := maxw;
        Result.Y := Trunc(maxw * h / w);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertImage(const stream: TStream; ext: string; MaxWidth: Integer;
  MaxHeight: Integer; ForceConvert: Boolean): TJPEGImage;
var
  ImageFound: Boolean;
  Img: TGraphic;
  BmpImg: TBitmap;
  TmpImg: TBitmap;
  Pt: TPoint;
begin
  Result := nil;
  ImageFound := False;
  Img := nil;
  BmpImg := nil;
  TmpImg := nil;

  try
    ext := AnsiLowerCase(ext);
    stream.Seek(0, soFromBeginning);
    if ext = '.png' then
    begin
      Img := TPNGObject.Create;
      Img.LoadFromStream(stream);
    end
    else if (ext = '.jpg') or (ext = '.jpeg') or (ext = '.jpe') then
    begin
      Img := TJPEGImage.Create;
      Img.LoadFromStream(stream);
    end
    else if ext = '.gif' then
    begin
      Img := TJvGIFImage.Create;
      Img.LoadFromStream(stream);
    end
    else if ext = '.bmp' then
    begin
      Img := TBitmap.Create;
      Img.LoadFromStream(stream);
    end
    else
      Abort;
    ImageFound := True;
  except
    FreeAndNil(Img);
  end;

  if ImageFound and ( ForceConvert or ((MaxWidth > 0) and (Img.Width > MaxWidth)) or
     ((MaxHeight > 0) and (Img.Height > MaxHeight)) or (ext <> '.jpg') ) then
  begin
    try
      if (MaxWidth <= 0) then
        MaxWidth := Img.Width;
      if (MaxHeight <= 0) then
        MaxHeight := Img.Height;
      Pt := CalcImageSize(Img.Width, Img.Height, MaxWidth, MaxHeight);
      BmpImg := TBitmap.Create;
      BmpImg.PixelFormat := pf24bit;
      BmpImg.Width := Pt.X;
      BmpImg.Height := Pt.Y;
      if BmpImg.Width < 2 then
        BmpImg.Width := 2;
      if BmpImg.Height < 2 then
        BmpImg.Height := 2;

      TmpImg := TBitmap.Create;
      TmpImg.PixelFormat := pf24bit;
      TmpImg.Assign(nil);
      if ext = '.png' then
        with TPNGObject(Img) do
        begin
          TmpImg.Width := Width;
          TmpImg.Height := Height;
          Draw(TmpImg.Canvas, TmpImg.Canvas.ClipRect);
        end
      else
        TmpImg.Assign(Img);
      BmpImg.Canvas.StretchDraw(BmpImg.Canvas.ClipRect, TmpImg);

      Result := TJPEGImage.Create;
      try
        Result.PixelFormat := jf24Bit;
        Result.CompressionQuality := 90;
        Result.Performance := jpBestQuality;
        Result.Assign(BmpImg);
        Result.Compress;
      except
        FreeAndNil(Result);
      end;
    finally
      FreeAndNil(Img);
      FreeAndNil(TmpImg);
      FreeAndNil(BmpImg);
    end;
  end else
    FreeAndNil(Img);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertImageFromFile(const sFile: string; MaxWidth: Integer;
  MaxHeight: Integer; ForceConvert: Boolean): TJPEGImage;
var
  f: TFileStream;
begin
  Result := nil;
  if FileExists(sFile) then
  begin
    f := TFileStream.Create(sFile, fmOpenRead);
    try
      Result := ConvertImage(f, ExtractFileExt(sFile), MaxWidth, MaxHeight, ForceConvert);
    finally
      f.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
