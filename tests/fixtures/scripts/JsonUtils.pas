(***************************************************

Ant Movie Catalog importation script
www.antp.be/software/moviecatalog/

[Infos]
Authors=
Title=StringUtils1.pas
Description=Very basic (and incomplete!) JSON parser, originally made for importing data via MovieMeter API
Site=
Language=?
Version=
Requires=4.2.2
Comments=
License=GPL
GetInfo=0

[Options]

***************************************************)

unit JsonUtils;

uses
  StringUtils1;

const
  JsonUtils_Version = 1;


function GetJsonValue(obj: string; prop: string; defValue: string): string;
var
  value: string;
  i: Integer;
begin
  value := TextAfter(obj, '"' + prop + '":');
  if value = '' then
  begin
    Result := defValue;
    Exit;
  end;
  if StrGet(value, 1) = '"' then
  begin
    i := 2;
    while i <= Length(value) do
    begin
      if StrGet(value, i) = '\' then
      begin
        i := i + 2;
        Continue;
      end;
      if StrGet(value, i) = '"' then
      begin
        value := Copy(value, 2, i - 2);
        Break;
      end;
      i := i + 1;
    end;
    Result := DecodeJson(value);
  end else
  if StrGet(value, 1) = '{' then
  begin
    Result := TextBetween(value, '{', '}');
  end else
  if StrGet(value, 1) = '[' then
  begin
    Result := TextBetween(value, '[', ']');
  end else
  begin
    if Pos(',', value) > 0 then
    begin
      value := Copy(value, 1, Pos(',', value) - 1);
    end;
    if value = 'null' then
      Result := defValue
    else
      Result := value;
  end;
end;

function DecodeJson(s: string): string;
var
  i: Integer;
  val: String;
begin
  s := StringReplace(s, '\r', '');
  s := StringReplace(s, '\n', #13#10);
  s := StringReplace(s, '\"', '"');
  s := StringReplace(s, '\/', '/');
  i := 1;
  Result := '';
  while i <= Length(s) do
  begin
    if (i <= Length(s) - 5) and (Copy(s, i, 2) = '\u') then
    begin
      // converting the \u hex number to base-10 then to HTML entity to decode it
      val := '&#' + IntToStr(StrToInt('$' + Copy(s, i + 2, 4), 0)) + ';';
      HtmlDecode(val);
      Result := Result + val;
      i := i + 6;
      Continue;
    end;
    Result := Result + StrGet(s, i);
    i := i + 1;
  end;
  Result := StringReplace(Result, '\\', '\');
end;

function ConvertJsonArray(jsonArray: string; delimiter: string): string;
var
  i: Integer;
  InStr: Boolean;
  c: Char;
begin
  if jsonArray = '' then
  begin
    Result := '';
    Exit;
  end;
  i := 1;
  InStr := False;
  Result := '';
  while i <= Length(jsonArray) do
  begin
    c := StrGet(jsonArray, i);
    if c = '"' then
    begin
      InStr := not InStr;
    end else
    if (c = '\') and (i < Length(jsonArray)) then
    begin
      i := i + 2;
      Result := Result + c + StrGet(jsonArray, i + 1);
      Continue;
    end else
    if (not InStr) and (c = ',') then
    begin
      if delimiter = '' then
        Break
      else
        Result := Result + delimiter;
    end else
    begin
      Result := Result + c;
    end;
    i := i + 1;
  end;
  Result := DecodeJson(Result);
end;

begin
end.
