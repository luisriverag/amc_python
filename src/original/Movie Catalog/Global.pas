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

unit Global;

interface

uses
  SysUtils, Controls, ImgList,

  AntTranslator,

  ProgramSettings, MessageForm, InputForm, Progress, StringFilter;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  Settings: TSettings;
  Translator: TAntTranslator;
  ToolbarImages: TCustomImageList;
  MessageWin: TMessageWin;
  InputWin: TInputWin;
  ProgressWin: TProgressWin;

function CheckVersion(const Major, Minor, Revision: Integer; CurVersion: string = ''): Boolean; overload;
function CheckVersion(AVersion: string; CurVersion: string = ''): Boolean; overload;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Windows,

  functions_files, functions_str;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CheckVersion(const Major, Minor, Revision: Integer; CurVersion: string = ''): Boolean;
var
  Zero: Integer;
begin
  Zero := Integer('0');
  if CurVersion = '' then
    CurVersion := Settings.version;
  Result := False;
  if Major < (Integer(CurVersion[1]) - Zero) then
    Result := True
  else
    if Major = (Integer(CurVersion[1]) - Zero) then
      if Minor < (Integer(CurVersion[3]) - Zero) then
        Result := True
      else
        if Minor = (Integer(CurVersion[3]) - Zero) then
          if Revision <= (Integer(CurVersion[5]) - Zero) then
            Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CheckVersion(AVersion: string; CurVersion: string = ''): Boolean;
var
  Major, Minor, Revision: string;
  s: string;
begin
  Assert(False, 'Never tested');
  if CurVersion = '' then
    CurVersion := Settings.version;
  Split(AVersion, '.', Major, s, True);
  AVersion := s;
  Split(Aversion, '.', Minor, s, True);
  AVersion := s;
  Split(AVersion, '.', Revision, s, True);
  Result := CheckVersion(StrToIntDef(Major, 0), StrToIntDef(Minor, 0), StrToIntDef(Revision, 0), CurVersion);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
