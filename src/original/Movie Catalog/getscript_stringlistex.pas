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

unit getscript_stringlistex;

interface

uses
  Classes, SysUtils,

  ifs_var, ifspas, ifpsclass, stdimport, stringlistex;
  
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure SIRegister_StringListEx(Cl: TIFPSClasses);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
  TStringListEx
-------------------------------------------------------------------------------}

function ReadTStringListExDelimitedCSVText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStringListEx, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TStringListEx(Obj).DelimitedCSVText);
  Result := True;
end;

function WriteTStringListExDelimitedCSVText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStringListEx, Caller, Obj) then begin result := false; exit; end;
  TStringListEx(Obj).DelimitedCSVText := GetString(Src);
  Result := True;
End;

function ReadTStringListExDelimitedAMCText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStringListEx, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TStringListEx(Obj).DelimitedAMCText);
  Result := True;
end;

function WriteTStringListExDelimitedAMCText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStringListEx, Caller, Obj) then begin result := false; exit; end;
  TStringListEx(Obj).DelimitedAMCText := GetString(Src);
  Result := True;
End;

{-------------------------------------------------------------------------------
  Register
-------------------------------------------------------------------------------}

procedure SIRegister_StringListEx(cl: TIFPSClasses); // requires TStringList
begin
  with Cl.AddClass(TStringListEx, cl.FindClass('TStringList')) do
  begin
    AddFunction(@TStringListEx.Create, 'constructor Create;');
    AddFunction(@TStringListEx.NaturalSort, 'procedure NaturalSort;');
    AddPropertyHelper('DelimitedCSVText', 'String', @ReadTStringListExDelimitedCSVText, @WriteTStringListExDelimitedCSVText);
    AddPropertyHelper('DelimitedAMCText', 'String', @ReadTStringListExDelimitedAMCText, @WriteTStringListExDelimitedAMCText);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.