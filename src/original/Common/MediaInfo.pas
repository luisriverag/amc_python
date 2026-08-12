(************************************************************************
 *                                                                      *
 *   (C) 2006 Antoine Potten                                            *
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

unit MediaInfo;

interface

uses
  Classes, Windows, SysUtils;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  MedaInfoExpectedVersion = '22.12';

type
  TMediaInfoHandle = Pointer;

  TMediaInfoStream =( misStreamGeneral, misStreamVideo, misStreamAudio, misStreamText, misStreamChapters, misStreamImage, misStreamMax );
  TMediaInfoInfo = ( miiInfoName, miiInfoText, miiInfoMeasure, miiInfoOptions, miiInfoNameText, miiInfoMeasureText, miiInfoInfo, miiInfoHowTo, miiInfoMax );

  TMediaInfoProcNew = function (): TMediaInfoHandle cdecl stdcall;
  TMediaInfoProcOption = function (AHandle: TMediaInfoHandle; AOption: PChar; AValue: PChar): PChar cdecl stdcall;
  TMediaInfoProcOpen = function (AHandle: TMediaInfoHandle; AFile: PChar): Integer cdecl stdcall;
  TMediaInfoProcGet = function (AHandle: TMediaInfoHandle; AStreamKind: Integer; AStreamNumber: Integer; AParameter: PChar; AKindOfInfo: Integer; AKindOfSearch: Integer): PChar cdecl stdcall;
  TMediaInfoProcGetI = function (AHandle: TMediaInfoHandle; AStreamKind: Integer; AStreamNumber: Integer; AParameter: Integer; AKindOfInfo: Integer): PChar cdecl stdcall;
  TMediaInfoProcDelete = procedure (AHandle: TMediaInfoHandle) cdecl stdcall;

  TMediaInfo = class(TObject)
  private
    FLib: Cardinal;
    FHandle: TMediaInfoHandle;
    FProcNew : TMediaInfoProcNew;
    FProcOption: TMediaInfoProcOption;
    FProcOpen: TMediaInfoProcOpen;
    FProcGet: TMediaInfoProcGet;
    FProcGetI: TMediaInfoProcGetI;
    FProcDelete: TMediaInfoProcDelete;
  protected
  public
    constructor Create(const ADLLPath: TFileName; const CheckVersion: Boolean);
    destructor Destroy; override;
    function Version: string;
    function Parameters: string;
    function Open(const AFileName: string): Integer;
    function Get(const AStreamKind: TMediaInfoStream; const AStreamNumber: Integer; const AParameter: string; const AKindOfInfo: TMediaInfoInfo = miiInfoText; const AKindOfSearch: TMediaInfoInfo = miiInfoName): string;
    function GetI(const AStreamKind: TMediaInfoStream; const AStreamNumber: Integer; const AParameter: Integer; const AKindOfInfo: TMediaInfoInfo = miiInfoText): string;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  functions_str;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TMediaInfo.Create(const ADLLPath: TFileName; const CheckVersion: Boolean);
var
  MajorVersion: string;
begin
  FLib := LoadLibrary(PChar(ADLLPath));
  if FLib = 0 then
    RaiseLastOSError;
  if CheckVersion then
  begin
    MajorVersion := Version;
    if not StartsStr(MedaInfoExpectedVersion, MajorVersion) then
      raise Exception.Create(Format('%s: wrong version, expected "%s" but found "%s"', [ExtractFileName(ADLLPath), MedaInfoExpectedVersion, MajorVersion]));
  end;
  @FProcNew := GetProcAddress(FLib, 'MediaInfoA_New');
  if @FProcNew = nil then
    RaiseLastOSError;
  FHandle := FProcNew();
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMediaInfo.Destroy;
begin
  @FProcDelete := GetProcAddress(FLib, 'MediaInfoA_Delete');
  if @FProcDelete <> nil then
    FProcDelete(FHandle);
  FreeLibrary(FLib);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMediaInfo.Version: string;
var
  s1, s2: string;
begin
  if @FProcOption = nil then
    @FProcOption := GetProcAddress(FLib, 'MediaInfoA_Option');
  if @FProcOption = nil then
    RaiseLastOSError;
  Result := FProcOption(nil, PChar('Info_Version'), PChar(''));
  Split(Result, ' - ', s1, s2, False);
  Result := s2;
  Split(Result, ' - ', s1, s2, True);
  Result := s1;
  if (Length(Result) > 0) and (Result[1] = 'v') then
    Delete(Result, 1, 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMediaInfo.Open(const AFileName: string): Integer;
begin
  if @FProcOpen = nil then
    @FProcOpen := GetProcAddress(FLib, 'MediaInfoA_Open');
  if @FProcOpen = nil then
    RaiseLastOSError;
  Result := FProcOpen(FHandle, PChar(AFileName));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMediaInfo.Get(const AStreamKind: TMediaInfoStream; const AStreamNumber: Integer; const AParameter: string; const AKindOfInfo, AKindOfSearch: TMediaInfoInfo): string;
begin
  if @FProcGet = nil then
    @FProcGet := GetProcAddress(FLib, 'MediaInfoA_Get');
  if @FProcGet = nil then
    RaiseLastOSError;
  Result := FProcGet(FHandle, Integer(AStreamKind), AStreamNumber, PChar(AParameter), Integer(AKindOfInfo), Integer(AKindOfSearch));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMediaInfo.GetI(const AStreamKind: TMediaInfoStream; const AStreamNumber: Integer; const AParameter: Integer; const AKindOfInfo: TMediaInfoInfo): string;
begin
  if @FProcGetI = nil then
    @FProcGetI := GetProcAddress(FLib, 'MediaInfoA_GetI');
  if @FProcGetI = nil then
    RaiseLastOSError;
  Result := FProcGetI(FHandle, Integer(AStreamKind), AStreamNumber, AParameter, Integer(AKindOfInfo));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMediaInfo.Parameters: string;
begin
  if @FProcOption = nil then
    @FProcOption := GetProcAddress(FLib, 'MediaInfoA_Option');
  if @FProcOption = nil then
    RaiseLastOSError;
  Result := FProcOption(nil, PChar('Info_Parameters'), PChar(''));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
