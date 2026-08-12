(************************************************************************
 *                                                                      *
 *   (C) 2002-2006 Antoine Potten                                       *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   I wrote this file on the basis of the  informations found on       *
 *   http://www.wotsit.org/ in the following document :                 *
 *   http://www.wotsit.org/download.asp?f=avi                           *
 *   You can use this file for free, as long as you do not remove my    *
 *   name and address from the source.                                  *
 *   It would be nice if you could include in the credits, about box    *
 *   or in the documentation my name and/or web address.                *
 *                                                                      *
 *   This program is distributed in the hope that it will be useful,    *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               *
 *                                                                      *
 ************************************************************************)

unit functions_video;

interface

uses
  Windows, Graphics;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type

  FOURCC = array[1..4] of Char;
  TAVIHeader = record
    dwMicroSecPerFrame:     DWORD;
    dwMaxBytesPerSec:       DWORD;
    dwReserved1:            DWORD;
    dwFlags:                DWORD;
    dwTotalFrames:          DWORD;
    dwInitialFrames:        DWORD;
    dwStreams:              DWORD;
    dwSuggestedBufferSize:  DWORD;
    dwWidth:                DWORD;
    dwHeight:               DWORD;
    dwScale:                DWORD;
    dwRate:                 DWORD;
    dwStart:                DWORD;
    dwLength:               DWORD;
  end;
  TStreamHeader = record
    fccType:                FOURCC;
    fccHandler:             FOURCC;
    dwFlags:                DWORD;
    dwReserved1:            DWORD;
    dwInitialFrames:        DWORD;
    dwScale:                DWORD;
    dwRate:                 DWORD;
    dwStart:                DWORD;
    dwLength:               DWORD;
    dwSuggestedBufferSize:  DWORD;
    dwQuality:              DWORD;
    dwSampleSize:           DWORD;
  end;
  TVidsStreamFormat = BITMAPINFO;
  TAudsStreamFormat = record
    wFormatTag:             Word;
    nChannels:              Word;
    nSamplesPerSec:         DWORD;
    nAvgBytesPerSec:        DWORD;
    nBlockAlign:            Word;
    wBitsPerSample:         Word;
    cbSize:                 Word;
  end;

function ExtractAVIInfos(const AVIFileName: string; out ResX, ResY, Length: Integer;
  out FrameRate: Single; out VideoCodec, AudioCodec, AudioChannels: string;
  out VideoBitrate, AudioBitrate: Integer): Boolean;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Sysutils, Dialogs, ShellAPI, classes;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const

  RIFF = $46464952;
  AVI_ = $20495641;
  LIST = $5453494C;
  HDRL = $6C726468;
  AVIH = $68697661;
  STRL = $6C727473;
  STRH = $68727473;
  STRF = $66727473;
  STRC = $63727473;
  VIDS = $73646976;
  AUDS = $73647561;

var
  DWORDSize: DWORD = SizeOf(DWORD);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ExtractAVIInfos(
  const AVIFileName: string;
  out ResX, ResY, Length: Integer;
  out FrameRate: Single;
  out VideoCodec, AudioCodec, AudioChannels: string;
  out VideoBitrate, AudioBitrate: Integer
): Boolean;
var
  VideoFile: THandleStream;
  FileHandle: THandle;
  AAVIHeader: TAVIHeader;
  AVidsStreamFormat: TVidsStreamFormat;
  AAudsStreamFormat: TAudsStreamFormat;
  AStreamHeader: TStreamHeader;
  StructHeader, ListHeader: DWORD;
  StructSize, ListSize: DWORD;
  FullHeaderStart, FullHeaderSize: DWORD;
  LastPos, VideoSize: Int64;
begin
  Result := False;
  ResX := 0;
  ResY := 0;
  FrameRate := 0;
  VideoCodec := '';
  AudioCodec := '';
  AudioChannels := '';
  VideoBitrate := 0;
  AudioBitrate := 0;
  VideoFile := nil;
  VideoSize := 0;
  FileHandle := CreateFile(PChar(AVIFileName), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if FileHandle = INVALID_HANDLE_VALUE then
    Exit;
  try
    VideoFile := THandleStream.Create(FileHandle);
    VideoFile.Seek(0, soFrombeginning);
    VideoSize := VideoFile.Size;
    VideoFile.Read(StructHeader, DWORDSize);
    VideoFile.Read(StructSize, DWORDSize);
    if (StructHeader <> RIFF) then
      Exit;
    VideoFile.Read(StructHeader, DWORDSize);
    if (StructHeader <> AVI_) then
      Exit;
    VideoFile.Read(StructHeader, DWORDSize);
    VideoFile.Read(StructSize, DWORDSize);
    if (StructHeader <> LIST) then
      Exit
    else
    begin
      FullHeaderStart := VideoFile.Position;
      FullHeaderSize := StructSize;
    end;
    VideoFile.Read(StructHeader, DWORDSize);
    if StructHeader <> HDRL then
      Exit;
    VideoFile.Read(StructHeader, DWORDSize);
    VideoFile.Read(StructSize, DWORDSize);
    if (StructHeader <> AVIH) then
      Exit;
    LastPos := VideoFile.Position;
    VideoFile.Read(AAVIHeader, SizeOf(AAVIHeader));
    ResX := AAVIHeader.dwWidth;
    ResY := AAVIHeader.dwHeight;
    Length := (AAVIHeader.dwTotalFrames * (AAVIHeader.dwMicroSecPerFrame div 1000)) div 60000;
    FrameRate := 1000000 / AAVIHeader.dwMicroSecPerFrame;
    VideoCodec := '';
    AudioCodec := '';
    AudioChannels := '';
    VideoBitrate := 0;
    AudioBitrate := 0;
    Result := True;
    ListSize := StructSize;
    while VideoFile.Position < (FullHeaderStart + FullHeaderSize) do
    begin
      VideoFile.Seek(LastPos, soFromBeginning);
      VideoFile.Seek(ListSize, soFromCurrent);
      VideoFile.Read(ListHeader, DWORDSize);
      VideoFile.Read(ListSize, DWORDSize);
      LastPos := VideoFile.Position;
      if (ListHeader = STRC) then
      begin
        Continue;
      end else
      if (ListHeader <> LIST) then
        Exit;
      VideoFile.Read(StructHeader, DWORDSize);
      if (StructHeader <> STRL) then
        Exit;
      VideoFile.Read(StructHeader, DWORDSize);
      VideoFile.Read(StructSize, DWORDSize);
      if (StructHeader <> STRH) then
        Exit;
      VideoFile.Read(AStreamHeader, StructSize);
      case Integer(AStreamHeader.fccType) of
        VIDS:
          begin
            VideoFile.Read(StructHeader, DWORDSize);
            VideoFile.Read(StructSize, DWORDSize);
            if (StructHeader = STRF) then
            begin
              VideoFile.Read(AVidsStreamFormat, SizeOf(AVidsStreamFormat));
              VideoCodec := Copy(FourCC(AVidsStreamFormat.bmiHeader.biCompression), 1, 4);
              if SizeOf(AVidsStreamFormat) <> StructSize + 4 then
                VideoFile.Seek(StructSize + 4 - SizeOf(AVidsStreamFormat), soFromCurrent)
            end;
          end;
        AUDS:
          begin
            {
            with AStreamHeader do
              if dwSampleSize > 0 then
                Inc(AudioBitrate, Trunc(8 * (dwSampleSize * (dwRate / dwScale)) / 1000))
              else
                Inc(AudioBitrate, Trunc(8 * (dwSuggestedBufferSize * (dwRate / dwScale)) / 1000));
            }
            VideoFile.Read(StructHeader, DWORDSize);
            VideoFile.Read(StructSize, DWORDSize);
            if (StructHeader = STRF) then
            begin
              VideoFile.Read(AAudsStreamFormat, SizeOf(AAudsStreamFormat));
              AudioCodec := AudioCodec + IntToHex(AAudsStreamFormat.wFormatTag, 4);
              if AudioChannels <> '' then
                AudioChannels := AudioChannels + '|';
              AudioChannels := AudioChannels + IntToStr(AAudsStreamFormat.nChannels);
              Inc(AudioBitrate, AAudsStreamFormat.nAvgBytesPerSec * 8 div 1000);
              if SizeOf(AAudsStreamFormat) <> StructSize then
                VideoFile.Seek(StructSize - SizeOf(AAudsStreamFormat), soFromCurrent)
            end;
          end;
      end;
    end;
  finally
    if Length > 0 then
      VideoBitrate := VideoSize * 8 div (Length * 60) div 1000 - AudioBitrate;
    VideoFile.Free;
    CloseHandle(FileHandle);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

