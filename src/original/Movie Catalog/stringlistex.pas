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
 
unit stringlistex;
interface

uses
  Windows, SysUtils, Classes,
  functions_str;

type
  TStringListEx = class(TStringList)
  private
    function GetDelimitedCSVText: string;
    procedure SetDelimitedCSVText(const Value: string);
    function GetDelimitedAMCText: string;
    procedure SetDelimitedAMCText(const Value: string);
  public
    procedure NaturalSort;
    property DelimitedCSVText: string read GetDelimitedCSVText write SetDelimitedCSVText;
    property DelimitedAMCText: string read GetDelimitedAMCText write SetDelimitedAMCText;
  end;
  
  function NaturalSortCompare(List: TStringList; Index1, Index2: Integer): Integer;

implementation

procedure TStringListEx.NaturalSort;
begin
  CustomSort(NaturalSortCompare);
end;

function TStringListEx.GetDelimitedCSVText: string;
var
  S: string;
  P: PChar;
  I, Count: Integer;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
    Result := QuoteChar + QuoteChar
  else
  begin
    Result := '';
    for I := 0 to Count - 1 do
    begin
      S := Get(I);
      P := PChar(S);
      while not (P^ in [#0, QuoteChar, Delimiter, #10, #13]) do
        P := CharNext(P);
      if P^ <> #0 then
        S := AnsiQuotedStr(S, QuoteChar);
      Result := Result + S + Delimiter;
    end;
    if Result <> '' then
      System.Delete(Result, Length(Result), 1);
  end;
end;

procedure TStringListEx.SetDelimitedCSVText(const Value: string);
var
  P, P1: PChar;
  S: string;
begin
  BeginUpdate;
  try
    Clear;
    P := PChar(Value);
    while P^ <> #0 do
    begin
      P1 := P;
      while P^ in [' '] do
        P := CharNext(P);
      if P^ = QuoteChar then
      begin
        S := AnsiExtractQuotedStr(P, QuoteChar);
        while not (P^ in [#0, Delimiter, #13, #10]) do
          P := CharNext(P);
      end else
      begin
        P := P1;
        while not (P^ in [#0, Delimiter, #13, #10]) do
          P := CharNext(P);
        SetString(S, P1, P - P1);
      end;
      Add(S);
      if P^ <> #0 then
      begin
        P1 := P;
        P := CharNext(P);
        if ((P1^ = #13) and (P^ = #10)) or ((P1^ = #10) and (P^ = #13)) then
          P := CharNext(P);
        if (P^ = #0) and (P1^ = Delimiter) then
          Add('');
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function TStringListEx.GetDelimitedAMCText: string;
var
  S: string;
  P: PChar;
  I, n, Count: Integer;
  nbP: Integer;
begin
  Count := GetCount;
  if (Count = 1) and (Get(0) = '') then
    Result := ''
  else
  begin
    Result := '';
    for I := 0 to Count - 1 do
    begin
      S := Get(I);
      S := StringReplace(S, #10#13, ' ', []);
      S := StringReplace(S, #13#10, ' ', []);
      S := StringReplace(S, #10, ' ', []);
      S := StringReplace(S, #13, ' ', []);
      S := Trim(S);
      P := PChar(S);
      nbP := 0;
      while P^ <> #0 do
      begin
        if P^ = '(' then
          Inc(nbP)
        else if P^ = ')' then
          Dec(nbP)
        else if (P^ = Delimiter) and (nbP = 0) then
          P^ := ' ';
        P := CharNext(P);
      end;
      if nbP < 0 then
        for n := 0 downto nbP+1 do
          S := '(' + S
      else if nbP > 0 then
        for n := 0 to nbP-1 do
          S := S + ')'; 
      if S <> '' then
        Result := Result + S + Delimiter + ' ';
    end;
    if Result <> '' then
      System.Delete(Result, Length(Result)-1, 2);
  end;
end;

procedure TStringListEx.SetDelimitedAMCText(const Value: string);
var
  P, P1: PChar;
  S: string;
  nbP: Integer;
begin
  BeginUpdate;
  try
    Clear;
    P := PChar(Value);
    while P^ <> #0 do
    begin
      P1 := P;
      nbP := 0;
      while (P^ <> #0) and (not (P^ in [Delimiter, #10, #13]) or (nbP <> 0)) do
      begin
        if P^ = '(' then
          Inc(nbP)
        else if P^ = ')' then
          Dec(nbP);
        P := CharNext(P);
      end;
      SetString(S, P1, P - P1);
      S := StringReplace(S, #10#13, ' ', []);
      S := StringReplace(S, #13#10, ' ', []);
      S := StringReplace(S, #10, ' ', []);
      S := StringReplace(S, #13, ' ', []);
      S := Trim(S);
      if S <> '' then
        Add(S);
      if P^ <> #0 then
      begin
        P1 := P;
        P := CharNext(P);
        if ((P1^ = #13) and (P^ = #10)) or ((P1^ = #10) and (P^ = #13)) then
          P := CharNext(P);
      end;
    end;
  finally
    EndUpdate;
  end;
end;

function NaturalSortCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  if (Index1 < 0) or (Index2 < 0) or (Index1 >= List.Count) or (Index1 >= List.Count) then
    Result := 0
  else
    Result := AnsiNatCompare(List[Index1], List[Index2], not List.CaseSensitive);
end;

end.