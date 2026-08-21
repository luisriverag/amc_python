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

unit getmedia;

interface

uses
  Windows, Classes, SysUtils, StrUtils, Contnrs, Math, Forms, Controls, Dialogs,

  functions_files, framemovie, framemoviecustom, fields, movieclass;

const
  mediaLow             =  0;

  mediaVolumeLabel     =  0;
  mediaPath            =  1;
  mediaPathName        =  2;
  mediaPathNameExt     =  3;
  mediaName            =  4;
  mediaNameFiltered    =  5;
  mediaNameExt         =  6;
  mediaFolder          =  7;
  mediaFolderFiltered  =  8;
  mediaExt             =  9;
  mediaExtWithoutDot   = 10;
  mediaSizeStr         = 11;
  mediaSize            = 12;
  mediaDisks           = 13;
  mediaPicture         = 14;
  mediaLength          = 15;
  mediaResolution      = 16;
  mediaResWidth        = 17;
  mediaResHeight       = 18;
  mediaFramerate       = 19;
  mediaVideoCodec      = 20;
  mediaVideoBitrate    = 21;
  mediaAudioCodec      = 22;
  mediaAudioChannels   = 23;
  mediaAudioCodecAndChannels = 24;
  mediaAudioBitrate    = 25;
  mediaLanguages       = 26;
  mediaSubtitles       = 27;

  mediaCount           = 28;
  mediaFileCount       = 15;

  strTagMedia: array [mediaLow..mediaCount-1] of string = (
    'VolumeLabel',
    'Path',
    'PathName',
    'PathNameExt',
    'Name',
    'NameFiltered',
    'NameExt',
    'Folder',
    'FolderFiltered',
    'Ext',
    'ExtWithoutDot',
    'SizeStr',
    'Size',
    'Disks',
    'Picture',
    'Length',
    'Resolution',
    'ResWidth',
    'ResHeight',
    'Framerate',
    'VideoCodec',
    'VideoBitrate',
    'AudioCodec',
    'AudioChannels',
    'AudioCodecAndChannels',
    'AudioBitrate',
    'Languages',
    'Subtitles'
  );
var
  strMedia: TStrings;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TMedia = class(TObject)
  public
    Value: array [mediaLow..mediaCount-1] of string;
    procedure InitValues(DefaultValue: string = '');
    procedure Assign(Media: TMedia);
  end;

  TMediaFilter = class(TObject)
  public
    Value: array [mediaLow..mediaCount-1] of Boolean;
    procedure InitValues(DefaultValue: Boolean = False);
    procedure Assign(MediaFilter: TMediaFilter);
  end;

function GetFilteredName(const Name: string): string;
function GetDefaultMediaFilter(MediaFilter: TMediaFilter; Properties: TCustomFieldsProperties): Boolean;
function GetInfoFromMedia(const FileName: TFileName; Media: TMedia; UseInternalAVI: Boolean;
  SizeUnit: TFileSizeUnit; MediaFilter: TMediaFilter = nil; ImportOnlyFileInfo: Boolean = False;
  MergeInfo: Boolean = False): Boolean;
function SetInfoFromMediaToFrame(const Media: TMedia; FrmMovie: TMovieFrame;
  FrmMovieCustom: TMovieFrameCustom): Boolean;
function SetInfoFromMediaToMovie(const Media: TMedia; Movie: TMovie;
  Properties: TCustomFieldsProperties): Boolean;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TGetMediaThread = class(TThread)
  private
    FFileName: TFileName; // Input
    FMedia: TMedia; // Output
    FInternalAVI: Boolean;
    FSizeUnit: TFileSizeUnit;
    FMediaFilter: TMediaFilter;
    FOnlyFileInfo: Boolean;
    FMergeInfo: Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(FileName: TFileName; Media: TMedia;
      UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
      MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean; MergeInfo: Boolean);
  end;

var
  GetMediaThr: TGetMediaThread;
  GetMediaThrDone: Boolean;

procedure StartGetMediaThread(FileName: TFileName; Media: TMedia;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean; MergeInfo: Boolean = False);
procedure StopGetMediaThread;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TGetFileListThread = class(TThread)
  private
    FDirList: TStringList; // Input/Output (Empty when thread terminates)
    FFileList: TStringList; // Output
    FFileListError: TStringList; // Output
    FFileListTmp: TStringList;
    FBrowseDepth: Integer;
    FMultiDisks: Boolean;
    FDiskTag: string;
    FMediaFilesFound: string;
    FNbFilesFound: Integer;
  protected
    procedure Execute; override;
    procedure SetStatus;
  public
    constructor Create(DirList: TStringList; FileList: TStringList;
      FileListError: TStringList; BrowseDepth: Integer; MultiDisks: Boolean;
      DiskTag: string; MediaFilesFound: string);
    destructor Destroy; override;
  end;

var
  GetFileListThr: TGetFileListThread;
  GetFileListThrDone: Boolean;

procedure StartGetFileListThread(DirList: TStringList; FileList: TStringList;
  FileListError: TStringList; BrowseDepth: Integer; MultiDisks: Boolean;
  DiskTag: string; MediaFilesFound: string);
procedure StopGetFileListThread;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TGetMediaListThread = class(TThread)
  private
    FFileList: TStringList; // Input
    FMediaList: TObjectList; // Output
    FInternalAVI: Boolean;
    FSizeUnit: TFileSizeUnit;
    FMediaFilter: TMediaFilter;
    FOnlyFileInfo: Boolean;
    iFileList: Integer;
  protected
    procedure Execute; override;
    procedure SetStatus;
  public
    constructor Create(FileList: TStringList; MediaList: TObjectList;
      UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
      MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean);
  end;

var
  GetMediaListThr: TGetMediaListThread;
  GetMediaListThrDone: Boolean;

procedure StartGetMediaListThread(FileList: TStringList; MediaList: TObjectList;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean);
procedure StopGetMediaListThread;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  IniFiles,

  ConstValues, Global, functions_str, functions_video, MediaInfo,
  ProgramSettings, AntJvSpin, functions_gui, stringfilter, RegExpr;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TMedia }

procedure TMedia.InitValues(DefaultValue: string);
var
  i: Integer;
begin
  for i := mediaLow to mediaCount-1 do
    Value[i] := DefaultValue;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMedia.Assign(Media: TMedia);
var
  i: Integer;
begin
  for i := mediaLow to mediaCount-1 do
    Value[i] := Media.Value[i];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TMediaFilter }

procedure TMediaFilter.InitValues(DefaultValue: Boolean);
var
  i: Integer;
begin
  for i := mediaLow to mediaCount-1 do
    Value[i] := DefaultValue;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMediaFilter.Assign(MediaFilter: TMediaFilter);
var
  i: Integer;
begin
  for i := mediaLow to mediaCount-1 do
    Value[i] := MediaFilter.Value[i];
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetFilteredName(const Name: string): string;
begin
  Result := ApplyStringFilter(Settings.rOptions.rMovieInformation.FilterFileName, Name);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetDefaultMediaFilter(MediaFilter: TMediaFilter; Properties: TCustomFieldsProperties): Boolean;
var
  i, idx: Integer;
begin
  Result := False;
  if MediaFilter = nil then
    Exit;
  MediaFilter.InitValues;
  with Settings.rOptions.rMovieInformation do
  begin
    Result := True;
    MediaFilter.Value[mediaSize] := ImportSize and (not ImportSizeString);
    MediaFilter.Value[mediaSizeStr] := ImportSize and ImportSizeString;
    MediaFilter.Value[mediaDisks] := ImportSize;
    MediaFilter.Value[mediaVolumeLabel] := ImportMediaLabel;
    MediaFilter.Value[mediaNameFiltered] := ImportFileName;
    MediaFilter.Value[mediaPathNameExt] := ImportFileInFilePath or ImportFileInURL;
    MediaFilter.Value[mediaResolution] := ImportResolution;
    MediaFilter.Value[mediaLength] := ImportLength;
    MediaFilter.Value[mediaFramerate] := ImportFramerate;
    MediaFilter.Value[mediaVideoCodec] := ImportVideoCodec;
    MediaFilter.Value[mediaAudioCodec] := ImportAudioCodec and (not ImportAudioChannels);
    MediaFilter.Value[mediaAudioChannels] := ImportAudioChannels and (not ImportAudioCodec);
    MediaFilter.Value[mediaAudioCodecAndChannels] := ImportAudioCodec and ImportAudioChannels;
    MediaFilter.Value[mediaVideoBitrate] := ImportVideoBitrate;
    MediaFilter.Value[mediaAudioBitrate] := ImportAudioBitrate;
    MediaFilter.Value[mediaLanguages] := ImportLanguages;
    MediaFilter.Value[mediaSubtitles] := ImportSubtitles;
    if Properties <> nil then
    with Properties do
      for i := 0 to Count-1 do
        if (Objects[i].MediaInfo <> '') then
        begin
          idx := IndexText(Objects[i].MediaInfo, strTagMedia);
          if (idx <> -1) then
            MediaFilter.Value[idx] := True;
        end;
    MediaFilter.Value[mediaPicture] := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetInfoFromMedia(const FileName: TFileName; Media: TMedia; UseInternalAVI: Boolean;
  SizeUnit: TFileSizeUnit; MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean;
  MergeInfo: Boolean): Boolean;
var
  IniCodecFile: TMemIniFile;
  Path, Name, Folder, Ext, VolumeLabel, SizeStr: string;
  VideoResX, VideoResY, VideoLength, VideoBitrate, AudioBitrate: Integer;
  VideoFramerate: Single;
  VideoCodec, AudioCodec, AudioChannels, AudioCodecAndChannels, Languages, Subtitles: string;
  Disks, StreamCount: Integer;
  i, p, c, n: Integer;
  s, tmp: string;
begin
  Result := False;
  if (not FileExists(FileName)) or (Media = nil) then
    Exit;
  Result := True;
  try
    // Media file info
    Path := ExtractFilePath(FileName);
    Name := ChangeFileExt(ExtractFileName(FileName), '');
    Folder := ExtractFileName(ExtractFileDir(FileName));
    Ext := AnsiLowerCase(ExtractFileExt(FileName));
    ExtractFileSize(FileName, False, SizeStr, Disks, SizeUnit);
    if (UpCase(FileName[1]) in ['A'..'Z']) then
      VolumeLabel := GetVolumeLabel(FileName[1])
    else
      VolumeLabel := '';

    // Write media file info
    if (MediaFilter = nil) or MediaFilter.Value[mediaPath] then
      if (not MergeInfo) or (Media.Value[mediaPath] = '') then
        Media.Value[mediaPath] := Path;
    if (MediaFilter = nil) or MediaFilter.Value[mediaPathName] then
      if (not MergeInfo) or (Media.Value[mediaPathName] = '') then
        Media.Value[mediaPathName] := Path + Name;
    if (MediaFilter = nil) or MediaFilter.Value[mediaPathNameExt] then
      if (not MergeInfo) or (Media.Value[mediaPathNameExt] = '') then
        Media.Value[mediaPathNameExt] := Path + Name + Ext;
    if (MediaFilter = nil) or MediaFilter.Value[mediaName] then
      if (not MergeInfo) or (Media.Value[mediaName] = '') then
        Media.Value[mediaName] := Name;
    if (MediaFilter = nil) or MediaFilter.Value[mediaNameFiltered] then
      if (not MergeInfo) or (Media.Value[mediaNameFiltered] = '') then
        Media.Value[mediaNameFiltered] := GetFilteredName(Name);
    if (MediaFilter = nil) or MediaFilter.Value[mediaNameExt] then
      if (not MergeInfo) or (Media.Value[mediaNameExt] = '') then
        Media.Value[mediaNameExt] := Name + Ext;
    if (MediaFilter = nil) or MediaFilter.Value[mediaFolder] then
      if (not MergeInfo) or (Media.Value[mediaFolder] = '') then
        Media.Value[mediaFolder] := Folder;
    if (MediaFilter = nil) or MediaFilter.Value[mediaFolderFiltered] then
      if (not MergeInfo) or (Media.Value[mediaFolderFiltered] = '') then
        Media.Value[mediaFolderFiltered] := GetFilteredName(Folder);
    if (MediaFilter = nil) or MediaFilter.Value[mediaExt] then
      if (not MergeInfo) or (Media.Value[mediaExt] = '') then
        Media.Value[mediaExt] := Ext;
    if (MediaFilter = nil) or MediaFilter.Value[mediaExtWithoutDot] then
      if (not MergeInfo) or (Media.Value[mediaExtWithoutDot] = '') then
      begin
        Media.Value[mediaExtWithoutDot] := Ext;
        System.Delete(Media.Value[mediaExtWithoutDot], 1, 1);
      end;
    if (MediaFilter = nil) or MediaFilter.Value[mediaVolumeLabel] then
      if (not MergeInfo) or (Media.Value[mediaVolumeLabel] = '') then
          Media.Value[mediaVolumeLabel] := VolumeLabel;
    if (MediaFilter = nil) or MediaFilter.Value[mediaSizeStr] then
      if (not MergeInfo) or (Media.Value[mediaSizeStr] = '') then
        Media.Value[mediaSizeStr] := SizeStr
      else
        Media.Value[mediaSizeStr] := Format('%s+%s', [Media.Value[mediaSizeStr], SizeStr]);
    if (MediaFilter = nil) or MediaFilter.Value[mediaSize] then
      if (not MergeInfo) or (Media.Value[mediaSize] = '') then
        Media.Value[mediaSize] := SizeStr
      else
        Media.Value[mediaSize] := IntToStr(StrToInt64Def(Media.Value[mediaSize], 0) + StrToInt64Def(SizeStr, 0));
    if (MediaFilter = nil) or MediaFilter.Value[mediaDisks] then
      if not MergeInfo then
        Media.Value[mediaDisks] := IntToStr(Disks)
      else
        Media.Value[mediaDisks] := IntToStr(StrToIntDef(Media.Value[mediaDisks], 0) + Disks);
    if (MediaFilter = nil) or MediaFilter.Value[mediaPicture] then
      if (not MergeInfo) or (Media.Value[mediaPicture] = '') then
      begin
        i := 0;
        while (i < Length(extImage)) and (Media.Value[mediaPicture] = '') do
        begin
          tmp := Path + Name + extImage[i];
          if FileExists(tmp) then
            Media.Value[mediaPicture] := tmp;
          Inc(i);
        end;
        i := 0;
        while (i < Length(extImage)) and (Media.Value[mediaPicture] = '') do
        begin
          tmp := Path + Folder + extImage[i];
          if FileExists(tmp) then
            Media.Value[mediaPicture] := tmp;
          Inc(i);
        end;
        with Settings.rOptions.rMovieInformation.PosterNames do
        begin
          p := 0;
          while (p < Count) and (Media.Value[mediaPicture] = '') do
          begin
            i := 0;
            while (i < Length(extImage)) and (Media.Value[mediaPicture] = '') do
            begin
              tmp := Path + Strings[p] + extImage[i];
              if FileExists(tmp) then
                Media.Value[mediaPicture] := tmp;
              Inc(i);
            end;
            Inc(p);
          end;
        end;
      end;

    // Media info
    if not ImportOnlyFileInfo then
    begin
      VideoResX := 0; VideoResY := 0; VideoLength := 0;
      VideoFramerate := 0; VideoBitrate := 0; AudioBitrate := 0;
      VideoCodec := ''; AudioCodec := ''; AudioChannels := '';
      AudioCodecAndChannels := ''; Languages := ''; Subtitles := '';
      IniCodecFile := nil;
      if ((MediaFilter = nil) or MediaFilter.Value[mediaVideoCodec] or
        MediaFilter.Value[mediaAudioCodec] or MediaFilter.Value[mediaAudioChannels] or
        MediaFilter.Value[mediaAudioCodecAndChannels]) and
        FileExists(strFileCodecs) then
        try
          IniCodecFile := TMemIniFile.Create(strFileCodecs)
        except
          FreeAndNil(IniCodecFile)
        end;

      if UseInternalAVI and (Ext = extVideo[extAVI]) then
      begin
        ExtractAVIInfos(FileName, VideoResX, VideoResY, VideoLength, VideoFramerate,
          VideoCodec, AudioCodec, AudioChannels, VideoBitrate, AudioBitrate);
        if ((MediaFilter = nil) or MediaFilter.Value[mediaVideoCodec]) and
          (VideoCodec <> '') and (IniCodecFile <> nil) then
          VideoCodec := IniCodecFile.ReadString('Video', VideoCodec, VideoCodec);
        if ((MediaFilter = nil) or MediaFilter.Value[mediaAudioCodec] or
          MediaFilter.Value[mediaAudioCodecAndChannels]) and (AudioCodec <> '') then
        begin
          s := '';
          for i := 0 to (Length(AudioCodec) div 4) - 1 do
          begin
            if s <> '' then
              s := s + ', ';
            tmp := Copy(AudioCodec, (i * 4) + 1, 4);
            if IniCodecFile <> nil then
              tmp := IniCodecFile.ReadString('Audio', tmp, tmp);
            s := s + tmp;
          end;
          AudioCodec := s;
        end;
        if ((MediaFilter = nil) or MediaFilter.Value[mediaAudioChannels] or
          MediaFilter.Value[mediaAudioCodecAndChannels]) and (AudioChannels <> '') then
        begin
          s := '';
          p := 1;
          for i := 1 to Length(AudioChannels) do
          begin
            if (AudioChannels[i] = '|') then
            begin
              if (p < i) then
              begin
                if s <> '' then
                  s := s + ', ';
                tmp := Copy(AudioChannels, p, i - p);
                if IniCodecFile <> nil then
                  tmp := IniCodecFile.ReadString('AudioChannels', tmp, tmp);
                s := s + tmp;
              end;
              p := i + 1;
            end;
          end;
          if p <= Length(AudioChannels) then
          begin
            if s <> '' then
              s := s + ', ';
            tmp := Copy(AudioChannels, p, Length(AudioChannels));
            if IniCodecFile <> nil then
              tmp := IniCodecFile.ReadString('AudioChannels', tmp, tmp);
            s := s + tmp;
          end;
          AudioChannels := s;
        end;
        if ((MediaFilter = nil) or (MediaFilter.Value[mediaAudioCodecAndChannels])) and
          ((AudioCodec <> '') or (AudioChannels <> '')) then
        begin
          AudioCodecAndChannels := AudioCodec;
          if (AudioCodecAndChannels <> '') and (AudioChannels <> '') then
            AudioCodecAndChannels := AudioCodecAndChannels + ', ';
          AudioCodecAndChannels := AudioCodecAndChannels + AudioChannels;
        end;
      end else
      begin
        with TMediaInfo.Create(strFileMediaInfoDLL, True) do
        try
          if Open(FileName) <> 0 then
          begin
            if (MediaFilter = nil) or MediaFilter.Value[mediaLength]  then
              VideoLength := StrToIntDef(Get(misStreamGeneral, 0, 'PlayTime'), 0) div 1000 div 60;

            // Video Streams
            StreamCount := StrToIntDef(Get(misStreamGeneral, 0, 'VideoCount'), 0);
            if StreamCount > 0 then
            begin
              // Video Codec
              if (MediaFilter = nil) or MediaFilter.Value[mediaVideoCodec] then
              begin
                for i := 0 to StreamCount-1 do
                begin
                  s := Get(misStreamVideo, i, 'Format/String');
                  if s = '' then
                    s := Get(misStreamVideo, i, 'Codec/String');
                  if s = '' then
                    s := Get(misStreamAudio, i, 'Codec');
                  if IniCodecFile <> nil then
                    s := IniCodecFile.ReadString('MediaInfoVideo', s, s);
                  if s <> '' then
                  begin
                    if VideoCodec <> '' then
                      VideoCodec := VideoCodec + ', ';
                    VideoCodec := VideoCodec + s;
                  end;
                end;
              end;
              // Video Bitrate
              if (MediaFilter = nil) or MediaFilter.Value[mediaVideoBitrate] then
              begin
                c := 0;
                for i := 0 to StreamCount-1 do
                begin
                  n := StrToIntTrunc(Get(misStreamVideo, i, 'BitRate')) div 1000;
                  if n > 0 then
                  begin
                    Inc(VideoBitrate, n);
                    Inc(c);
                  end;
                end;
                if c > 0 then
                  VideoBitrate := VideoBitrate div c;
              end;
              // Resolution Width
              if (MediaFilter = nil) or MediaFilter.Value[mediaResolution] or MediaFilter.Value[mediaResWidth] then
                VideoResX := StrToIntTrunc(Get(misStreamVideo, 0, 'Width'));
              // Resolution Height
              if (MediaFilter = nil) or MediaFilter.Value[mediaResolution] or MediaFilter.Value[mediaResHeight] then
                VideoResY := StrToIntTrunc(Get(misStreamVideo, 0, 'Height'));
              // Framerate
              if (MediaFilter = nil) or MediaFilter.Value[mediaFramerate] then
                VideoFramerate := StrToFloatDef(Get(misStreamVideo, 0, 'FrameRate'), 0, FormatSettings);
            end; // video streams > 0

            // Audio Streams
            StreamCount := StrToIntDef(Get(misStreamGeneral, 0, 'AudioCount'), 0);
            if StreamCount > 0 then
            begin
              // Audio Codec
              if (MediaFilter = nil) or MediaFilter.Value[mediaAudioCodec] or
                MediaFilter.Value[mediaAudioCodecAndChannels] then
              begin
                for i := 0 to StreamCount-1 do
                begin
                  s := Get(misStreamAudio, i, 'Format/String');
                  if s = '' then
                    s := Get(misStreamAudio, i, 'Codec/String');
                  if s = '' then
                    s := Get(misStreamAudio, i, 'Codec');
                  if IniCodecFile <> nil then
                    s := IniCodecFile.ReadString('MediaInfoAudio', s, s);
                  if s <> '' then
                  begin
                    if AudioCodec <> '' then
                      AudioCodec := AudioCodec + ', ';
                    AudioCodec := AudioCodec + s;
                  end;
                end;
              end;
              // Audio Channels
              if (MediaFilter = nil) or MediaFilter.Value[mediaAudioChannels] or
                MediaFilter.Value[mediaAudioCodecAndChannels] then
              begin
                for i := 0 to StreamCount-1 do
                begin
                  s := Get(misStreamAudio, i, 'Channel(s)');
                  if IniCodecFile <> nil then
                    s := IniCodecFile.ReadString('MediaInfoAudioChannels', s, s);
                  if s <> '' then
                  begin
                    if AudioChannels <> '' then
                      AudioChannels := AudioChannels + ', ';
                    AudioChannels := AudioChannels + s;
                  end;
                end;
              end;
              // Audio Bitrate
              if (MediaFilter = nil) or MediaFilter.Value[mediaAudioBitrate] then
              begin
                c := 0;
                for i := 0 to StreamCount-1 do
                begin
                  n := StrToIntTrunc(Get(misStreamAudio, i, 'BitRate')) div 1000;
                  if n > 0 then
                  begin
                    Inc(AudioBitrate, n);
                    Inc(c);
                  end;
                end;
                if c > 0 then
                  AudioBitrate := AudioBitrate div c;
              end;

              // Languages
              if (MediaFilter = nil) or MediaFilter.Value[mediaLanguages] then
              begin
                for i := 0 to StreamCount-1 do
                begin
                  s := Get(misStreamAudio, i, 'Language/String');
                  if s <> '' then
                  begin
                    if Languages <> '' then
                      Languages := Languages + ', ';
                    Languages := Languages + s;
                  end;
                end;
              end;
            end; // audio streams > 0

            // AudioCodec + AudioChannels
            if ((MediaFilter = nil) or (MediaFilter.Value[mediaAudioCodecAndChannels])) and
              ((AudioCodec <> '') or (AudioChannels <> '')) then
            begin
              AudioCodecAndChannels := AudioCodec;
              if (AudioCodecAndChannels <> '') and (AudioChannels <> '') then
                AudioCodecAndChannels := AudioCodecAndChannels + ', ';
              AudioCodecAndChannels := AudioCodecAndChannels + AudioChannels;
            end;

            // Text Streams
            StreamCount := StrToIntDef(Get(misStreamGeneral, 0, 'TextCount'), 0);
            if StreamCount > 0 then
            begin
              // Subtitles
              if (MediaFilter = nil) or MediaFilter.Value[mediaSubtitles] then
              begin
                for i := 0 to StreamCount-1 do
                begin
                  s := Get(misStreamText, i, 'Language/String');
                  if s <> '' then
                  begin
                    if Subtitles <> '' then
                      Subtitles := Subtitles + ', ';
                    Subtitles := Subtitles + s;
                  end;
                end;
              end;
            end; // text streams > 0
          end; // if open
        finally
          Free;
        end;
      end;
    end;

    // Write media info
    if not ImportOnlyFileInfo then
    begin
      if (MediaFilter = nil) or MediaFilter.Value[mediaLength] then
        if (not MergeInfo) or (Media.Value[mediaLength] = '') then
          Media.Value[mediaLength] := IntToStr(VideoLength)
        else
          Media.Value[mediaLength] := IntToStr(StrToIntDef(Media.Value[mediaLength], 0) + VideoLength);
      if (MediaFilter = nil) or MediaFilter.Value[mediaResolution] then
        if (VideoResX > 0) and (VideoResY > 0) then
          Media.Value[mediaResolution] := Format('%dx%d', [VideoResX, VideoResY]);
      if (MediaFilter = nil) or MediaFilter.Value[mediaResHeight] then
        if (VideoResX > 0) then
          Media.Value[mediaResHeight] := IntToStr(VideoResY);
      if (MediaFilter = nil) or MediaFilter.Value[mediaResWidth] then
        if (VideoResX > 0) then
          Media.Value[mediaResWidth] := IntToStr(VideoResX);
      if (MediaFilter = nil) or MediaFilter.Value[mediaFramerate] then
        if (VideoFramerate > 0) then
          Media.Value[mediaFramerate] := FormatFloat('#0.000', VideoFramerate{, FormatSettings});
      if (MediaFilter = nil) or MediaFilter.Value[mediaVideoCodec] then
        Media.Value[mediaVideoCodec] := VideoCodec;
      if (MediaFilter = nil) or MediaFilter.Value[mediaVideoBitrate] then
        if (VideoBitrate > 0) then
          if (not MergeInfo) or (Media.Value[mediaVideoBitrate] = '') then
            Media.Value[mediaVideoBitrate] := IntToStr(VideoBitrate)
          else
            Media.Value[mediaVideoBitrate] := IntToStr((StrToIntDef(Media.Value[mediaVideoBitrate], 0) + VideoBitrate) div 2);
      if (MediaFilter = nil) or MediaFilter.Value[mediaAudioCodec] then
        Media.Value[mediaAudioCodec] := AudioCodec;
      if (MediaFilter = nil) or MediaFilter.Value[mediaAudioChannels] then
        Media.Value[mediaAudioChannels] := AudioChannels;
      if (MediaFilter = nil) or MediaFilter.Value[mediaAudioCodecAndChannels] then
        Media.Value[mediaAudioCodecAndChannels] := AudioCodecAndChannels;
      if (MediaFilter = nil) or MediaFilter.Value[mediaAudioBitrate] then
        if (AudioBitrate > 0) then
          if (not MergeInfo) or (Media.Value[mediaAudioBitrate] = '') then
            Media.Value[mediaAudioBitrate] := IntToStr(AudioBitrate)
          else
            Media.Value[mediaAudioBitrate] := IntToStr((StrToIntDef(Media.Value[mediaAudioBitrate], 0) + AudioBitrate) div 2);
      if (MediaFilter = nil) or MediaFilter.Value[mediaLanguages] then
        Media.Value[mediaLanguages] := Languages;
      if (MediaFilter = nil) or MediaFilter.Value[mediaSubtitles] then
        Media.Value[mediaSubtitles] := Subtitles;
    end;
  except
    //Result := False;
  end;
  FreeAndNil(IniCodecFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function SetInfoFromMediaToFrame(const Media: TMedia; FrmMovie: TMovieFrame;
  FrmMovieCustom: TMovieFrameCustom): Boolean;
var
  i, idx: Integer;
  Value: string;
begin
  Result := False;
  with Settings.rOptions.rMovieInformation do
  begin
    if Media <> nil then
    begin
      Result := True;
      if ImportSize then
        with FrmMovie do
        begin
          if ESize.Text = '' then
            if ImportSizeString then
              ESize.Text :=  Media.Value[mediaSizeStr]
            else
              ESize.Text :=  Media.Value[mediaSize]
          else
            if ImportSizeString then
            begin
              if (Media.Value[mediaSizeStr] <> '') then
                ESize.Text := Format('%s+%s', [ESize.Text, Media.Value[mediaSizeStr]])
              else if ImportAllowClear then
                ESize.Text := '';
            end else
            begin
              if (Media.Value[mediaSize] <> '') then
                ESize.Text := IntToStr(StrToInt64Def(ESize.Text, 0) + StrToInt64Def(Media.Value[mediaSize], 0))
              else if ImportAllowClear then
                ESize.Text := '';
            end;
          if (Media.Value[mediaDisks] <> '') then
            EDisks.Text := IntToStr(StrToIntDef(EDisks.Text, 0) + StrToIntDef(Media.Value[mediaDisks], 0))
          else if ImportAllowClear then
            EDisks.Text := '';
        end;
      if ImportMediaLabel and ((Media.Value[mediaVolumeLabel] <> '') or ImportAllowClear) then
        FrmMovie.EMedia.Text := Media.Value[mediaVolumeLabel];
      if ImportFileName and ((Media.Value[mediaNameFiltered] <> '') or ImportAllowClear) then
        FrmMovie.EOriginalTitle.Text := Media.Value[mediaNameFiltered];
      if ImportFileInFilePath and ((Media.Value[mediaPathNameExt] <> '') or ImportAllowClear) then
        FrmMovie.EFilePath.Text := Media.Value[mediaPathNameExt];
      if ImportFileInURL and ((Media.Value[mediaPathNameExt] <> '') or ImportAllowClear) then
        FrmMovie.EURL.Text := Media.Value[mediaPathNameExt];
      if ImportResolution and ((Media.Value[mediaResolution] <> '') or ImportAllowClear) then
        FrmMovie.EResolution.Text := Media.Value[mediaResolution];
      if ImportLength then
      begin
        if Media.Value[mediaLength] <> '' then
          if FrmMovie.ELength.Text = '' then
            FrmMovie.ELength.Text := Media.Value[mediaLength]
          else
            FrmMovie.ELength.Text := IntToStr(StrToIntDef(Media.Value[mediaLength], 0) + StrToIntDef(FrmMovie.ELength.Text, 0))
        else if ImportAllowClear then
          FrmMovie.ELength.Text := '';
      end;
      if ImportFramerate and ((Media.Value[mediaFramerate] <> '') or ImportAllowClear) then
        FrmMovie.EFramerate.Text := Media.Value[mediaFramerate];
      if ImportVideoCodec and ((Media.Value[mediaVideoCodec] <> '') or ImportAllowClear) then
        FrmMovie.EVideoFormat.Text := Media.Value[mediaVideoCodec];
      if ImportAudioCodec and (not ImportAudioChannels) and
        ((Media.Value[mediaAudioCodec] <> '') or ImportAllowClear) then
        FrmMovie.EAudioFormat.Text := Media.Value[mediaAudioCodec]
      else if ImportAudioChannels and (not ImportAudioCodec) and
        ((Media.Value[mediaAudioChannels] <> '') or ImportAllowClear) then
        FrmMovie.EAudioFormat.Text := Media.Value[mediaAudioChannels]
      else if ImportAudioCodec and ImportAudioChannels and
        ((Media.Value[mediaAudioCodecAndChannels] <> '') or ImportAllowClear) then
        FrmMovie.EAudioFormat.Text := Media.Value[mediaAudioCodecAndChannels];
      if ImportVideoBitrate then
      begin
        if Media.Value[mediaVideoBitrate] <> '' then
          if FrmMovie.EVideoBitrate.Text <> '' then
            FrmMovie.EVideoBitrate.Text := IntToStr((StrToIntDef(FrmMovie.EVideoBitrate.Text, 0) +
              StrToIntDef(Media.Value[mediaVideoBitrate], 0)) div 2)
          else
            FrmMovie.EVideoBitrate.Text := Media.Value[mediaVideoBitrate]
        else if ImportAllowClear then
          FrmMovie.EVideoBitrate.Text := '';
      end;
      if ImportAudioBitrate then
      begin
        if Media.Value[mediaAudioBitrate] <> '' then
          if FrmMovie.EAudioBitrate.Text <> '' then
            FrmMovie.EAudioBitrate.Text := IntToStr((StrToIntDef(FrmMovie.EAudioBitrate.Text, 0) +
              StrToIntDef(Media.Value[mediaAudioBitrate], 0)) div 2)
          else
            FrmMovie.EAudioBitrate.Text := Media.Value[mediaAudioBitrate]
        else if ImportAllowClear then
          FrmMovie.EAudioBitrate.Text := '';
      end;
      if ImportLanguages and ((Media.Value[mediaLanguages] <> '') or ImportAllowClear) then
        FrmMovie.ELanguages.Text := Media.Value[mediaLanguages];
      if ImportSubtitles and ((Media.Value[mediaSubtitles] <> '') or ImportAllowClear) then
        FrmMovie.ESubtitles.Text := Media.Value[mediaSubtitles];
      if FrmMovieCustom.Properties <> nil then
        with FrmMovieCustom do
          for i := 0 to Properties.Count-1 do
            if (Properties.Objects[i].MediaInfo <> '') then
            begin
              idx := IndexText(Properties.Objects[i].MediaInfo, strTagMedia);
              if idx <> -1 then
              begin
                Value := GetCurrentValue(Properties.Strings[i]);
                case idx of
                  mediaSizeStr:
                    if (Media.Value[mediaSizeStr] <> '') then
                    begin
                      if Value = '' then
                        Value := Media.Value[mediaSizeStr]
                      else
                        Value := Format('%s+%s', [Value, Media.Value[mediaSizeStr]]);
                    end else if ImportAllowClear then
                      Value := '';
                  mediaSize:
                    if (Media.Value[mediaSize] <> '') then
                    begin
                      if Value = '' then
                        Value := Media.Value[mediaSize]
                      else
                        Value := IntToStr(StrToInt64Def(Value, 0) + StrToInt64Def(Media.Value[mediaSize], 0));
                    end else if ImportAllowClear then
                      Value := '';
                  mediaDisks:
                    if (Media.Value[mediaDisks] <> '') then
                      Value := IntToStr(StrToIntDef(Value, 0) + StrToIntDef(Media.Value[mediaDisks], 0))
                    else if ImportAllowClear then
                      Value := '';
                  mediaLength:
                    if (Media.Value[mediaLength] <> '') then
                    begin
                      if Value = '' then
                        Value := Media.Value[mediaLength]
                      else
                        Value := IntToStr(StrToIntDef(Media.Value[mediaLength], 0) + StrToIntDef(Value, 0));
                    end else if ImportAllowClear then
                      Value := '';
                  mediaVideoBitrate:
                    if (Media.Value[mediaVideoBitrate] <> '') then
                    begin
                      if Value <> '' then
                        Value := IntToStr((StrToIntDef(Value, 0) +
                          StrToIntDef(Media.Value[mediaVideoBitrate], 0)) div 2)
                      else
                        Value := Media.Value[mediaVideoBitrate];
                    end else if ImportAllowClear then
                      Value := '';
                  mediaAudioBitrate:
                    if (Media.Value[mediaAudioBitrate] <> '') then
                    begin
                      if Value <> '' then
                        Value := IntToStr((StrToIntDef(Value, 0) +
                          StrToIntDef(Media.Value[mediaAudioBitrate], 0)) div 2)
                      else
                        Value := Media.Value[mediaAudioBitrate];
                    end else if ImportAllowClear then
                      Value := '';
                  else
                    if (Media.Value[idx] <> '') or ImportAllowClear then
                      Value := Media.Value[idx];
                end;
                SetCurrentValue(Properties.Strings[i], Value);
              end;
            end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function SetInfoFromMediaToMovie(const Media: TMedia; Movie: TMovie;
  Properties: TCustomFieldsProperties): Boolean;
var
  i, idx: Integer;
  Value: string;
begin
  Result := False;
  with Settings.rOptions.rMovieInformation do
  begin
    if Media <> nil then
    begin
      Result := True;
      if ImportSize and (Media.Value[mediaSize] <> '') then
      begin
        Value := Movie.GetFieldValue(fieldSize);
        if Value = '' then
          if ImportSizeString then
            Movie.SetFieldValue(fieldSize, Media.Value[mediaSizeStr])
          else
            Movie.SetFieldValue(fieldSize, Media.Value[mediaSize])
        else
          if ImportSizeString then
          begin
            if (Media.Value[mediaSizeStr] <> '') then
              Movie.SetFieldValue(fieldSize, Format('%s+%s', [Value, Media.Value[mediaSizeStr]]))
            else if ImportAllowClear then
              Movie.SetFieldValue(fieldSize, '');
          end else
          begin
            if (Media.Value[mediaSize] <> '') then
              Movie.SetFieldValue(fieldSize, IntToStr(StrToInt64Def(Value, 0) + StrToInt64Def(Media.Value[mediaSize], 0)))
            else if ImportAllowClear then
              Movie.SetFieldValue(fieldSize, '');
          end;
        if (Media.Value[mediaDisks] <> '') then
        begin
          Value := Movie.GetFieldValue(fieldDisks);
          Movie.SetFieldValue(fieldDisks, IntToStr(StrToIntDef(Value, 0) + StrToIntDef(Media.Value[mediaDisks], 0)));
        end else if ImportAllowClear then
          Movie.SetFieldValue(fieldDisks, '');
      end;
      if ImportMediaLabel and ((Media.Value[mediaVolumeLabel] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldMedia, Media.Value[mediaVolumeLabel]);
      if ImportFileName and ((Media.Value[mediaNameFiltered] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldOriginalTitle, Media.Value[mediaNameFiltered]);
      if ImportFileInFilePath and ((Media.Value[mediaPathNameExt] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldFilePath, Media.Value[mediaPathNameExt]);
      if ImportFileInURL and ((Media.Value[mediaPathNameExt] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldUrl, Media.Value[mediaPathNameExt]);
      if ImportResolution and ((Media.Value[mediaResolution] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldResolution, Media.Value[mediaResolution]);
      if ImportLength then
      begin
        if Media.Value[mediaLength] <> '' then
        begin
          Value := Movie.GetFieldValue(fieldLength);
          if Value = '' then
             Movie.SetFieldValue(fieldLength, Media.Value[mediaLength])
          else
            Movie.SetFieldValue(fieldLength, IntToStr(StrToIntDef(Media.Value[mediaLength], 0) + StrToIntDef(Value, 0)));
        end else if ImportAllowClear then
          Movie.SetFieldValue(fieldLength, '');
      end;
      if ImportFramerate and ((Media.Value[mediaFramerate] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldFramerate, Media.Value[mediaFramerate]);
      if ImportVideoCodec and ((Media.Value[mediaVideoCodec] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldVideoFormat, Media.Value[mediaVideoCodec]);
      if ImportAudioCodec and (not ImportAudioChannels) and
        ((Media.Value[mediaAudioCodec] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldAudioFormat, Media.Value[mediaAudioCodec])
      else if ImportAudioChannels and (not ImportAudioCodec) and
        ((Media.Value[mediaAudioChannels] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldAudioFormat, Media.Value[mediaAudioChannels])
      else if ImportAudioCodec and ImportAudioChannels and
        ((Media.Value[mediaAudioCodecAndChannels] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldAudioFormat, Media.Value[mediaAudioCodecAndChannels]);
      if ImportVideoBitrate then
      begin
        if Media.Value[mediaVideoBitrate] <> '' then
        begin
          Value := Movie.GetFieldValue(fieldVideoBitrate);
          if Value <> '' then
            Movie.SetFieldValue(fieldVideoBitrate, IntToStr((StrToIntDef(Value, 0) +
              StrToIntDef(Media.Value[mediaVideoBitrate], 0)) div 2))
          else
            Movie.SetFieldValue(fieldVideoBitrate, Media.Value[mediaVideoBitrate]);
        end else if ImportAllowClear then
           Movie.SetFieldValue(fieldVideoBitrate, '');
      end;
      if ImportAudioBitrate then
      begin
        if Media.Value[mediaAudioBitrate] <> '' then
        begin
          Value := Movie.GetFieldValue(fieldAudioBitrate);
          if Value <> '' then
            Movie.SetFieldValue(fieldAudioBitrate, IntToStr((StrToIntDef(Value, 0) +
              StrToIntDef(Media.Value[mediaAudioBitrate], 0)) div 2))
          else if ImportAllowClear then
            Movie.SetFieldValue(fieldAudioBitrate, Media.Value[mediaAudioBitrate]);
        end else
          Movie.SetFieldValue(fieldAudioBitrate, '');
      end;
      if ImportLanguages and ((Media.Value[mediaLanguages] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldLanguages, Media.Value[mediaLanguages]);
      if ImportSubtitles and ((Media.Value[mediaSubtitles] <> '') or ImportAllowClear) then
        Movie.SetFieldValue(fieldSubtitles, Media.Value[mediaSubtitles]);
      if Properties <> nil then
        for i := 0 to Properties.Count-1 do
          if (Properties.Objects[i].MediaInfo <> '') then
          begin
            idx := IndexText(Properties.Objects[i].MediaInfo, strTagMedia);
            if idx <> -1 then
            begin
              Value := Movie.CustomFields.GetFieldValue(Properties.Strings[i]);
              case idx of
                mediaSizeStr:
                  if (Media.Value[mediaSizeStr] <> '') then
                  begin
                    if Value = '' then
                      Value := Media.Value[mediaSizeStr]
                    else
                      Value := Format('%s+%s', [Value, Media.Value[mediaSizeStr]]);
                  end else if ImportAllowClear then
                    Value := '';
                mediaSize:
                  if (Media.Value[mediaSize] <> '') then
                  begin
                    if Value = '' then
                      Value := Media.Value[mediaSize]
                    else
                      Value := IntToStr(StrToInt64Def(Value, 0) + StrToInt64Def(Media.Value[mediaSize], 0));
                  end else if ImportAllowClear then
                    Value := '';
                mediaDisks:
                  if (Media.Value[mediaDisks] <> '') then
                    Value := IntToStr(StrToIntDef(Value, 0) + StrToIntDef(Media.Value[mediaDisks], 0))
                  else if ImportAllowClear then
                    Value := '';
                mediaLength:
                  if (Media.Value[mediaLength] <> '') then
                  begin
                    if Value = '' then
                      Value := Media.Value[mediaLength]
                    else
                      Value := IntToStr(StrToIntDef(Media.Value[mediaLength], 0) + StrToIntDef(Value, 0));
                  end else if ImportAllowClear then
                    Value := '';
                mediaVideoBitrate:
                  if (Media.Value[mediaVideoBitrate] <> '') then
                  begin
                    if Value <> '' then
                      Value := IntToStr((StrToIntDef(Value, 0) +
                        StrToIntDef(Media.Value[mediaVideoBitrate], 0)) div 2)
                    else
                      Value := Media.Value[mediaVideoBitrate];
                  end else if ImportAllowClear then
                    Value := '';
                mediaAudioBitrate:
                  if (Media.Value[mediaAudioBitrate] <> '') then
                  begin
                    if Value <> '' then
                      Value := IntToStr((StrToIntDef(Value, 0) +
                        StrToIntDef(Media.Value[mediaAudioBitrate], 0)) div 2)
                    else
                      Value := Media.Value[mediaAudioBitrate];
                  end else if ImportAllowClear then
                    Value := '';
                else
                  if (Media.Value[idx] <> '') or ImportAllowClear then
                    Value := Media.Value[idx];
              end;
              Movie.CustomFields.SetFieldValue(Properties.Strings[i], Value);
            end;
          end;
    end;
  end;
end;

{ TGetMediaThread }

constructor TGetMediaThread.Create(FileName: TFileName; Media: TMedia;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean; MergeInfo: Boolean);
begin
  FFileName := FileName;
  FMedia := Media;
  FInternalAVI := UseInternalAVI;
  FSizeUnit := FileSizeUnit;
  FMediaFilter := MediaFilter;
  FOnlyFileInfo := ImportOnlyFileInfo;
  FMergeInfo := MergeInfo;
  FreeOnTerminate := False;
  inherited Create(False);
  Priority := tpLower;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetMediaThread.Execute;
begin
  if FMedia <> nil then
    GetInfoFromMedia(FFileName, FMedia, FInternalAVI, FSizeUnit, FMediaFilter, FOnlyFileInfo, FMergeInfo);
  GetMediaThrDone := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StartGetMediaThread(FileName: TFileName; Media: TMedia;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean; MergeInfo: Boolean);
begin
  StopGetMediaThread;
  GetMediaThrDone := False;
  GetMediaThr := TGetMediaThread.Create(FileName, Media, UseInternalAvi,
    FileSizeUnit, MediaFilter, ImportOnlyFileInfo, MergeInfo);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StopGetMediaThread;
var
  i: Integer;
begin
  if GetMediaThr <> nil then
  begin
    GetMediaThr.Terminate;
    //MediaThr.WaitFor;
    i := 0;
    while (not GetMediaThrDone) and (i < 50) do
    begin
      Application.ProcessMessages; //Important to avoid dead lock with synchronize
      Sleep(100);
      Inc(i);
    end;
    if (not GetMediaThrDone) then
    begin
      TerminateThread(GetMediaThr.ThreadID, 0);
      MessageWin.Execute('MediaInfo.dll process seems to be in infinite loop...' + #10 +
        'AMC can kill thread but process will continue to run until you close AMC.' + #10 +
        'It is recommended to save your work and restart AMC as soon as possible.', mtError, [mbOk]);
    end else
      GetMediaThr.Free;
    GetMediaThr := nil;
    GetMediaThrDone := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TGetFileListThread }

constructor TGetFileListThread.Create(DirList: TStringList; FileList: TStringList;
  FileListError: TStringList; BrowseDepth: Integer; MultiDisks: Boolean;
  DiskTag: string; MediaFilesFound: string);
begin
  FDirList := DirList;
  FFileList := FileList;
  FFileListError := FileListError;
  FBrowseDepth := BrowseDepth;
  FMultiDisks := MultiDisks;
  FDiskTag := DiskTag;
  FMediaFilesFound := MediaFilesFound;
  FreeOnTerminate := False;
  FFileListTmp := TStringList.Create;
  FFileListTmp.Sorted := True;
  inherited Create(False);
  Priority := tpLower;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TGetFileListThread.Destroy;
begin
  FFileListTmp.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetFileListThread.Execute;
var
  DirPath, Ext, CurrentName, LastName, Name1, Name2: string;
  Res: TSearchRec;
  EOFound: Boolean;
  Idx, DirDepth, i: Integer;
begin
  FNbFilesFound := -1;
  for Idx := FDirList.Count-1 downto 0 do
  begin
    FDirList.Objects[Idx] := Pointer(0); //Dir depth
    if Pos('?', FDirList.Strings[Idx]) > 0 then
    begin
      FFileListError.Add(FDirList.Strings[Idx]);
      FDirList.Delete(Idx);
    end;
  end;
  while (FDirList.Count > 0) and (Terminated = False) do
  begin
    DirPath := FDirList.Strings[0];
    DirDepth := Integer(FDirList.Objects[0]);
    FDirList.Delete(0);

    if FNbFilesFound <> FFileList.Count then
    begin
      FNbFilesFound := FFileList.Count;
      Synchronize(SetStatus);
    end;

    if DirectoryExists(DirPath) then
    begin
      if DirPath[Length(DirPath)] = '\' then
        System.Delete(DirPath, Length(DirPath), 1);

      // Add files in FileListTmp to sort them by filename
      FFileListTmp.Clear;
      EOFound := False;
      if FindFirst(DirPath + '\*.*', faAnyFile, Res) >= 0 then
        while (not EOFound) do
        begin
          if FileExists(DirPath + '\' + Res.Name) then
          begin
            Ext := LowerCase(ExtractFileExt(Res.Name));
            if {IndexText(Ext, extVideo) <> -1} (Ext <> '') and (Pos(Ext+' ', Settings.rOptions.rMovieInformation.ImportExt+' ') > 0) then
            begin
              if Pos('?', Res.Name) = 0 then
                FFileListTmp.Add(Res.Name)
              else
                FFileListError.Add(DirPath + '\' + Res.Name);
            end;
          end;
          EOFound := FindNext(Res) <> 0;
        end;
      FindClose(Res);

      // Add files
      LastName := '';
      for i := 0 to FFileListTmp.Count-1 do
      begin
        CurrentName := FFileListTmp.Strings[i];
        if FMultiDisks and (LastName <> '') then
        begin
          try
            Name1 := ReplaceRegExpr(FDiskTag, LastName, '', False);
            Name2 := ReplaceRegExpr(FDiskTag, LowerCase(CurrentName), '', False);
          except
            Name1 := '1';
            Name2 := '2';
          end;
          if (Name1 <> Name2) then
            FFileList.Add(DirPath + '\' + CurrentName)
          else
          begin
            Idx := FFileList.Add(DirPath + '\' + CurrentName);
            if Idx <> -1 then
              FFileList.Objects[idx] := Pointer(1); // Same movie than before
          end;
        end
        else
        begin
          FFileList.Add(DirPath + '\' + CurrentName);
        end;
        LastName := LowerCase(CurrentName);
      end;

      // Add sub-directories
      if (DirDepth < FBrowseDepth) then
      begin
        EOFound := False;
        if FindFirst(DirPath + '\*', faDirectory, Res) >= 0 then
          while (not EOFound) do
          begin
            if ((Res.Attr and faDirectory) <> 0) and (Res.Name <> '.') and (Res.Name <> '..') then
            begin
              if Pos('?', Res.Name) = 0 then
              begin
                Idx := FDirList.Add(DirPath + '\' + Res.Name);
                if Idx <> -1 then
                  FDirList.Objects[Idx] := Pointer(DirDepth+1); //Dir depth
              end
              else
                FFileListError.Add(DirPath + '\' + Res.Name + '\');
            end;
            EOFound := FindNext(Res) <> 0;
          end;
        FindClose(Res);
      end;
    end;
  end;
  
  if (not Terminated) and (FNbFilesFound <> FFileList.Count) then
  begin
    FNbFilesFound := FFileList.Count;
    Synchronize(SetStatus);
  end;
  GetFileListThrDone := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetFileListThread.SetStatus;
begin
  if (ProgressWin <> nil) and ProgressWin.Visible then
  with ProgressWin do
    Progress := FMediaFilesFound + IntToStr(FNbFilesFound);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StartGetFileListThread(DirList: TStringList; FileList: TStringList;
  FileListError: TStringList; BrowseDepth: Integer; MultiDisks: Boolean;
  DiskTag: string; MediaFilesFound: string);
begin
  StopGetFileListThread;
  GetFileListThrDone := False;
  GetFileListThr := TGetFileListThread.Create(DirList, FileList, FileListError,
    BrowseDepth, MultiDisks, DiskTag, MediaFilesFound);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StopGetFileListThread;
var
  i: Integer;
begin
  if GetFileListThr <> nil then
  begin
    GetFileListThr.Terminate;
    //GetFilesThr.WaitFor;
    i := 0;
    while (not GetFileListThrDone) and (i < 50) do
    begin
      Application.ProcessMessages; //Important to avoid dead lock with synchronize
      Sleep(100);
      Inc(i);
    end;
    if (not GetFileListThrDone) then
    begin
      TerminateThread(GetFileListThr.ThreadID, 0);
    end else
      GetFileListThr.Free;
    GetFileListThr := nil;
    GetFileListThrDone := True;
  end;
end;

{ TGetMediaListThread }

constructor TGetMediaListThread.Create(FileList: TStringList; MediaList: TObjectList;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean);
begin
  FFileList := FileList;
  FMediaList := MediaList;
  FInternalAVI := UseInternalAVI;
  FSizeUnit := FileSizeUnit;
  FMediaFilter := MediaFilter;
  FOnlyFileInfo := ImportOnlyFileInfo;
  FreeOnTerminate := False;
  inherited Create(False);
  Priority := tpLower;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetMediaListThread.Execute;
var
  Media, MediaCopy: TMedia;
  bOk: Boolean;

  procedure AddMediaInList;
  begin
    MediaCopy := TMedia.Create;
    MediaCopy.Assign(Media);
    FMediaList.Add(MediaCopy);
  end;
begin
  if FFileList.Count > 0 then
  begin
    Media := TMedia.Create;
    Media.InitValues;
    if (FMediaList = nil) then
      FMediaList := TObjectList.Create(True);
    FMediaList.OwnsObjects := True;
    FMediaList.Clear;
    iFileList := 0;
    Synchronize(SetStatus);
    bOk := GetInfoFromMedia(FFileList.Strings[0], Media, FInternalAVI, FSizeUnit, FMediaFilter, FOnlyFileInfo, False);
    iFileList := 1;
    while (iFileList < FFileList.Count) and (Terminated = False) do
    begin
      if not bOk then
      begin
        Media.InitValues;
        Synchronize(SetStatus);
        bOk := GetInfoFromMedia(FFileList.Strings[iFileList], Media, FInternalAVI, FSizeUnit, FMediaFilter, FOnlyFileInfo, False);
      end else
      if (Integer(FFileList.Objects[iFileList]) <> 0) then // Same movie, Merge media file info
      begin
        Synchronize(SetStatus);
        bOk := GetInfoFromMedia(FFileList.Strings[iFileList], Media, FInternalAVI, FSizeUnit, FMediaFilter, FOnlyFileInfo, True);
      end else
      begin
        AddMediaInList;
        Media.InitValues;
        Synchronize(SetStatus);
        bOk := GetInfoFromMedia(FFileList.Strings[iFileList], Media, FInternalAVI, FSizeUnit, FMediaFilter, FOnlyFileInfo, False);
      end;
      Inc(iFileList);
    end;
    if bOk then
      AddMediaInList;
    Media.Free;
    if (not Terminated) then
      Synchronize(SetStatus);
  end;
  GetMediaListThrDone := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetMediaListThread.SetStatus;
begin
  if (ProgressWin <> nil) and ProgressWin.Visible then
  with ProgressWin do
  begin
    IntProgress := iFileList;
    if (iFileList >= 0) and (iFileList < FFileList.Count) then
      Progress := ExtractFileName(FFileList.Strings[iFileList]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StartGetMediaListThread(FileList: TStringList; MediaList: TObjectList;
  UseInternalAVI: Boolean; FileSizeUnit: TFileSizeUnit;
  MediaFilter: TMediaFilter; ImportOnlyFileInfo: Boolean);
begin
  StopGetMediaListThread;
  GetMediaListThrDone := False;
  GetMediaListThr := TGetMediaListThread.Create(FileList, MediaList, UseInternalAvi,
    FileSizeUnit, MediaFilter, ImportOnlyFileInfo);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure StopGetMediaListThread;
var
  i: Integer;
begin
  if GetMediaListThr <> nil then
  begin
    GetMediaListThr.Terminate;
    //MediaThr.WaitFor;
    i := 0;
    while (not GetMediaListThrDone) and (i < 50) do
    begin
      Application.ProcessMessages; //Important to avoid dead lock with synchronize
      Sleep(100);
      Inc(i);
    end;
    if (not GetMediaListThrDone) then
    begin
      TerminateThread(GetMediaListThr.ThreadID, 0);
      MessageWin.Execute('MediaInfo.dll process seems to be in infinite loop...' + #10 +
        'AMC can kill thread but process will continue to run until you close AMC.' + #10 +
        'It is recommended to save your work and restart AMC as soon as possible.', mtError, [mbOk]);
    end else
      GetMediaListThr.Free;
    GetMediaListThr := nil;
    GetMediaListThrDone := True;
  end;
end;

end.
