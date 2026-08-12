
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2001, EldoS                   }
{   Parts:                                           }
{   copyright (c) 2001 Akzhan Abdulin                }
{                                                    }
{====================================================}

{$I ElPack.inc}

(*
  Version History:

  03/15/2001

  * StrStartsWith fixed (string end tests were bad).

  * IsAlpha, IsAlphaStr and IsIdentStr now tests for '_' char too.

  + IsAlphaOrDigit added.

  03/14/2001

  + StrStartsWith and ContainsAt methods.

  * H2D function updated.

*)

unit ElStrUtils;

interface

function IntToStrFmt(value: integer): string;
function FloatToStrFmt(value: extended; decims: integer): string;

function IntToStrPad(value: integer; MinSize: integer): string;

{$ifndef KYLIX_USED}
function OEMToStr(S: string): string;
function StrToOEM(S: string): string;

function MessageRes(Txt: Integer; Title: PChar; TextType: Word; Sounds: boolean): Integer;
{$endif}

function replace(var Str: string; SourceString, DestString: string): boolean;

function ExtractWord(str: string; n: integer): string;

function FstNonSpace(str: string): integer;

function NextWordBegin(str: string; CurrentPos: integer): integer;

function LastPos(SubStr: string; Strn: string): integer;
{ Returns the beginning of the last substring in a string }

function LineIsEmpty(str: string): boolean;
// Returns true, if line doesn't contain any characters except, probably, spaces and tabs

function CompleteLine(Str: string; FLen: integer; symb: char): string;
{ completes a string with some chars }

function PrefixLine(Str: string; FLen: integer; symb: char): string;

function MakeString(FLen: Integer; Symb: char): string;
// creates a new string, filled with specified chars

function H2D(S: string): integer;
function H2DDef(const S: string; Def: integer): integer;

function Bin2Int(S: string): integer;

function Bin2IntDef(S: string; Default: integer): integer;

function Data2Str(Buffer: pointer; BufLen: integer): string;
function Str2Data(S: string; var Buffer: pointer; var BufLen: integer): boolean;

function IsDigit(ch: char): boolean;
function IsDigitStr(const S: string): boolean;
function IsAlpha(ch: char): boolean;
function IsAlphaOrDigit(ch: char): boolean;
function IsAlphaStr(const S: string): boolean;
function IsIdentStr(const S: string): boolean;

function ExtractStr(var S: string; SPos, SLen: integer): string;

function LeftBreak(S: string; Pos: integer): integer;

function EscapeString(aString: string; UnsafeChars: string; EscapeChar: Char): string;
function UnEscapeString(aString: string; EscapeChar: Char): string;

function StrStartsWith(Source: PChar; Seq: PChar): Boolean;
function ContainsAt(Source: string; Index: Integer; Seq: string): Boolean;

function AnsiSameText(const S1, S2: string): Boolean;

function CurrToPrettyStr(const Value: Currency): string;
function PrettyStrToCurr(const Value: string): Currency;

function CurrSign(const Value: Currency): Integer;

implementation

uses
{$ifdef KYLIX_USED}
  Libc,
{$else}
  Windows,
  Consts,
{$endif}
  SysUtils,
{$ifdef VCL_6_USED}
  SysConst,
{$endif}
  Math;

type
  PArr = ^TByteArr;
  TByteArr = array[0..$7FFFFFFE] of byte;

function LeftBreak(S: string; Pos: integer): integer;
var
  i: integer;
  b: boolean;
begin
  result := -1;
  if (Pos = 0) or (Pos > Length(S)) then exit;
  b := (S[Pos] = ' ') or (S[Pos] = #9);
  i := Pos;
  while i > 0 do
  begin
    if ((S[i] = ' ') or (S[i] = ' ')) xor b then
    begin
      result := i;
      break;
    end;
    inc(i);
  end;
end;

{$ifndef KYLIX_USED}
function OEMToStr(S: string): string;
begin
  SetLength(Result, Length(S));
  if Length(S) > 0 then OEMToChar(PChar(S), PChar(result));
end;

function StrToOEM(S: string): string;
begin
  SetLength(Result, Length(S));
  if Length(S) > 0 then CharToOEM(PChar(S), PChar(result));
end;
{$endif}

function ExtractStr(var S: string; SPos, SLen: integer): string;
begin
  result := Copy(S, SPos, SLen);
  Delete(S, SPos, SLen);
end;

function Data2Str(Buffer: pointer; BufLen: integer): string;
var
  p: PArr;
  i: integer;
begin
  P := PArr(Buffer);
  result := '454C ' + IntToHex(BufLen, 1) + ' ';
  for i := 0 to BufLen - 1 do
    result := result + IntToHex(P[i], 2) + ' ';
end;

function Str2Data(S: string; var Buffer: pointer; var BufLen: integer): boolean;
var
  p: PArr;
  i, j: integer;
  S1: string;
  b: Boolean;
begin
  result := false;
  BufLen := -1;
  Buffer := nil;
  if pos('454C', S) <> 1 then exit;
  Delete(S, 1, 5);
  S1 := ExtractStr(S, 1, Pos(' ', S) - 1);
  Delete(S, 1, 1);
  if S1 = '' then exit;
{$ifdef KYLIX_USED}
  j := 0;
{$endif}
  try
    j := H2D(S1);
  except
    exit;
  end;
  GetMem(Buffer, j);
  BufLen := j;
  p := PArr(Buffer);
  try
    for i := 0 to J - 1 do
    begin
      if Pos(#32, S) > 0 then
      begin
        S1 := ExtractStr(S, 1, Pos(#32, S) - 1);
        delete(S, 1, 1);
        b := False;
      end
      else
      begin
        S1 := S;
        b := true;
      end;
      P[i] := H2D(S1);
      if b and (i < j - 1) then break;
    end;
    result := i >= j;
  except
    result := False;
  end;
end;

function IsIdentStr(const S: string): boolean;
var
  i, j: integer;
begin
  j := length(S);
  result := false;
  if (J = 0) or (not (IsAlpha(s[1]))) then exit;
  for i := 2 to j do
    if not IsAlphaOrDigit(S[i]) then exit;

  result := true;
end;

function IsAlpha(ch: char): boolean;
begin
  result := ch in ['_', 'A'..'Z', 'a'..'z'];
end;

function IsAlphaOrDigit(ch: char): boolean;
begin
  Result := ch in ['0'..'9', '_', 'A'..'Z', 'a'..'z'];
end;

function IsAlphaStr(const S: string): boolean;
var
  i, j: integer;
begin
  j := length(S);
  result := false;
  for i := 1 to j do
    if not IsAlpha(S[i]) then exit;
  result := true;
end;

function IsDigit(ch: char): boolean;
begin
  result := (ch >= '0') and (ch <= '9');
end;

function IsDigitStr(const S: string): boolean;
var
  i, j: integer;
begin
  j := length(S);
  result := false;
  for i := 1 to j do
  begin
    if (S[i] < '0') or (S[i] > '9') then exit;
  end;
  result := true;
end;

function H2D(S: string): integer;
var
  i: integer;
  n: boolean;
  c: char;
begin
  result := 0;
  if Pos('$', S) = 1 then
    Delete(S, 1, 1);
  S := Trim(S);
  if Length(S) = 0 then
{$IFNDEF VER90}
    raise EConvertError.CreateFmt(SInvalidInteger, [S]);
{$ELSE}
    raise EConvertError.CreateResFmt(SInvalidInteger, [S]);
{$ENDIF}
  n := false;
  if S[1] = '-' then n := true;
  if (S[1] = '-') or (S[1] = '+') then
    Delete(S, 1, 1);
  if Length(S) = 0 then
{$IFNDEF VER90}
    raise EConvertError.CreateFmt(SInvalidInteger, [S]);
{$ELSE}
    raise EConvertError.CreateResFmt(SInvalidInteger, [S]);
{$ENDIF}

  for i := 1 to Length(S) do
  begin
    c := S[i];
    if c in ['0'..'9'] then
      result := result shl 4 + Ord(c) - Ord('0')
    else
    begin
      c := UpCase(c);
      if c in ['A'..'F'] then
        result := result shl 4 + Ord(c) - Ord('A') + 10
      else
{$IFNDEF VER90}
        raise EConvertError.CreateFmt(SInvalidInteger, [S]);
{$ELSE}
        raise EConvertError.CreateResFmt(SInvalidInteger, [S]);
{$ENDIF}
    end;
  end;
  if n then result := -result;
end;

function H2DDef(const S: string; Def: integer): integer;
begin
  try
    result := H2D(S);
  except
    result := Def;
  end;
end;

{$ifndef KYLIX_USED}
function MessageRes(Txt: Integer; Title: PChar; TextType: Word; Sounds: boolean): Integer;
begin
  if Sounds then
    MessageBeep(TextType and
      (mb_IconAsterisk or mb_IconExclamation or mb_IconHand or mb_IconQuestion or mb_Ok));
  result := MessageBox(0, PChar(LoadStr(TXT)), Title, TextType);
end;
{$endif}

function replace;
var
  i: integer;
begin
  i := pos(SourceString, Str);
  if i = 0 then
  begin
    result := false;
    exit;
  end;
  Delete(Str, i, Length(SourceString));
  Insert(DestString, Str, i);
  result := true;
end;

function extractword(str: string; n: integer): string;
var
  count: integer;
  i: integer;
  len: integer;
  done: boolean;
  retstr: string;

begin
  retstr := '';
  len := length(str);
  count := 0;
  i := 1;
  done := false;
  while (i <= len) and (not done) do
  begin
    while ((i <= len) and ((str[i] = #32) or (str[i] = #9) or (str[i] = ';'))) do
      inc(i);
    if i <= len then
      inc(count);
    if count = n then
    begin
      setstring(retstr, nil, 0);
      if (i > 1) then
        if str[i - 1] = ';' then
          retstr := ';';
      while ((i <= len) and ((str[i] <> #32) and (str[i] <> #9) and (str[i] <> ';'))) do
      begin
        setlength(retstr, length(retstr) + 1);
        retstr[ord(length(retstr))] := str[i];
        inc(i);
      end;
      done := true;
    end
    else
      while ((i <= len) and ((str[i] <> #32) and (str[i] <> #9) and (str[i] <> ';'))) do
        inc(i);
  end;
  result := retstr;
end;

function FstNonSpace(str: string): integer;
var //P : PChar;
  i: integer;

begin
  i := 1;
  while (i < Length(Str)) and ((str[i] = #32) or (str[i] = #9)) do
    inc(i);
  if i = Length(Str) then
    result := -1
  else
    result := i;
end;

function NextWordBegin(str: string; CurrentPos: integer): integer;
var
  i: integer;
begin
  i := CurrentPos;
  while (i < Length(str)) and ((Str[i] = #32) or (Str[i] = #9)) do
    inc(i);
  if i = Length(str) then
    result := -1
  else
    result := i;
end;

function LastPos(SubStr: string; Strn: string): integer;
var
  i,
    j: integer;
  ls, // total length of substring
    ld // length of string
    : integer;

begin
  result := 0;
  ls := Length(SubStr);
  ld := Length(Strn);
  if (ls > ld) or (ls = 0) or (ld = 0) then exit;
  for i := ld downto ls do
  begin
    j := ls;
    while j >= 1 do
    begin
      if Strn[i - ls + j] <> SubStr[j] then break;
      dec(j);
    end;
    if j = 0 then
    begin
      result := i - ls + 1;
      exit;
    end;
  end;
 (*s:=Strn;
 n:=0;
 while Pos(Substr,s)>0 do
 begin
  n:=n+Pos(Substr,s);
  s:=Copy(Strn, n+1, Length(Strn));
 end;
 if n=0 then n:=-1;
 Result:=n;*)
end;

function LineIsEmpty(str: string): boolean;
begin
  result := FstNonSpace(str) = -1;
end;

function PrefixLine(Str: string; FLen: integer; symb: char): string;
begin
  if FLen = 0 then
  begin
    result := Str;
    exit;
  end;
  SetLength(Result, FLen);
  {$IFNDEF KYLIX_USED}
  FillMemory(PChar(result), FLen, byte(symb));
  {$ELSE}
  FillChar(Result, FLen, byte(symb));
  {$ENDIF}
  result := Result + Str;
end;

function CompleteLine(Str: string; FLen: integer; symb: char): string;
var
  S: string;
  i, j: integer;
begin
  s := Str;
  if Length(s) >= FLen then
  begin
    result := s;
    Exit;
  end;
  j := Length(S);
  SetLength(S, FLen);
  for i := j to FLen do
  begin
    S[i] := symb;
  end;
  result := s;
end;

function MakeString(FLen: Integer; Symb: char): string;
begin
  result := StringOfChar(Symb, FLen);
end;

function FloatToStrFmt(value: extended; decims: integer): string;
begin
  result := IntToStrFmt(Trunc(Value)) + DecimalSeparator + IntToStr(Round(Frac(Value) * Power(10, decims)));
end;

function IntToStrFmt(value: integer): string;
var
  S: string;
  sl,
    i,
    j,
    k: integer;
  b: boolean;
begin
  S := IntToStr(Value);
  sl := Length(S);
  if S[1] in ['-', '+'] then
  begin
    dec(sl);
    if sl > 3 then
    begin
      k := sl + sl div 3 + 1;
      b := SL mod 3 = 0;
      if b then
        dec(k);
    end
    else
      k := sl + 1;
    inc(sl);
    SetLength(Result, k);
    Result[1] := S[1];
    i := 2;
  end
  else
  begin
    if sl > 3 then
    begin
      k := sl + sl div 3;
      b := SL mod 3 = 0;
      if b then
        dec(k);
    end
    else
      k := sl;
    SetLength(Result, k);
    i := 1;
  end;
  k := i;
  for j := i to sl do
  begin
    {if (sl > 3 + (i - 1)) and
       (((not b) and ((sl - j + 1 + (i - 1)) mod 3 = 0)) or (b and ((sl - j + 1 + (i - 1)) mod 3 = 1))) then}
    if (sl > 3 + (i - 1)) and
      ((sl - j + 1) mod 3 = 0) and (j > i) then
    begin
      {if b then
      begin
        result[k] := S[j];
        inc(k);
        result[k] := ThousandSeparator;
        inc(k);
        Continue;
      end;
      } result[k] := ThousandSeparator;
      inc(k);
    end;
    result[k] := S[j];
    inc(k);
  end;
end;

function IntToStrPad(value: integer; MinSize: integer): string;
begin
  result := IntToStr(Value);
  while Length(result) < MinSize do
    Result := '0' + result;
end;

function Bin2IntDef(S: string; Default: integer): integer;
begin
  try
    result := Bin2Int(S);
  except
    result := Default;
  end;
end;

function Bin2Int(S: string): integer;
var
  i, l: integer;
begin
  l := length(S);
  result := 0;
  for i := 1 to l do
  begin
    result := (result shl 1);
    if s[i] = '1' then
      result := result or 1 {and ($ffffffff)}
    else
{$IFNDEF VER90}
      if s[i] <> '0' then
        raise EConvertError.CreateFmt(SInvalidInteger, [S]);
{$ELSE}
      if s[i] <> '0' then
        raise EConvertError.CreateResFmt(SInvalidInteger, [S]);
{$ENDIF}
  end;
end;

function EscapeString(aString: string; UnsafeChars: string; EscapeChar: Char): string;
var
  CurSrc, TotSrc: integer;
  CurChar: Char;
  i: integer;
begin
  if UnsafeChars = '' then // if the list is not given, we escape terminal charset
  begin
    SetLength(UnsafeChars, 31 + 128);
    for i := 0 to 31 do
      UnsafeChars[i + 1] := Char(i);
    for i := 128 to 255 do
      UnsafeChars[33 + i - 128] := Char(i);
  end;
  UnsafeChars := UnsafeChars + EscapeChar;
  result := '';
  TotSrc := Length(aString);
  CurSrc := 1;
  while CurSrc <= TotSrc do
  begin
    CurChar := aString[CurSrc];
    if Pos(CurChar, UnsafeChars) > 0 then
      result := result + EscapeChar + IntToHex(Ord(CurChar), 2)
    else
      result := result + CurChar;
    inc(CurSrc);
  end;
end;

function UnEscapeString(aString: string; EscapeChar: Char): string;
var
  CurSrc, TotSrc: integer;
  CurChar: Char;
begin
  result := '';
  TotSrc := Length(aString);
  CurSrc := 1;
  while CurSrc <= TotSrc do
  begin
    CurChar := aString[CurSrc];
    if CurChar = EscapeChar then
    begin
      if CurSrc + 2 <= TotSrc then
      begin
        result := result + Char(h2d(aString[CurSrc + 1] + aString[CurSrc + 2]));
        inc(CurSrc, 2);
      end
      else
        break;
    end
    else
      result := result + CurChar;
    inc(CurSrc);
  end;
end;

function StrStartsWith(Source: PChar; Seq: PChar): Boolean;
begin
  if Assigned(Seq) then
  begin
    Result := False;
    if not Assigned(Source) then Exit;
    while Seq^ <> #0 do
    begin
      if Source^ <> Seq^ then Exit;
      Inc(Source);
      Inc(Seq);
    end;
  end;
  Result := True;
end;

function ContainsAt(Source: string; Index: Integer; Seq: string): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(Source))
    and StrStartsWith(PChar(Source) + Index - 1, PChar(Seq));
end;

function AnsiSameText(const S1, S2: string): Boolean;
begin
  {$IFNDEF KYLIX_USED}
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) = 2;
  {$ELSE}
  Result := CompareText(S1, S2) = 0;
  {$ENDIF}
end;

function CurrToPrettyStr(const Value: Currency): string;
begin
  Result := CurrToStrF(Value, ffCurrency, CurrencyDecimals);
end;

function PrettyStrToCurr(const Value: string): Currency;
const
  OneStepMultiplicator = 0.1;
var
  I: Cardinal;
  CurrNegFormatted: Boolean;
  Digit: Currency;
  FractPartMultiplicator: Currency;
  Ch: Char;
  CurrSymbolPosition: Cardinal;
  Len: Cardinal;
  DigitsFound: Boolean;
begin
  Result := 0.0;
  if Value <> '' then
  begin
    CurrNegFormatted := False;
    DigitsFound := False;
    FractPartMultiplicator := 0.0;
    if CurrencyString <> '' then
    begin
      CurrSymbolPosition := Pos(CurrencyString, Value);
    end
    else
    begin
      CurrSymbolPosition := 0;
    end;
    I := 1;
    Len := Length(Value);
    while I <= Len do
    begin
      if I = CurrSymbolPosition then
      begin
        // skip currency symbol(s)
        if DigitsFound and CurrNegFormatted then Break;
        Inc(I, Length(CurrencyString));
        Continue;
      end;
      Ch := Value[I];
      case Ch of
        '0'..'9':
          begin
          // next digit found
            DigitsFound := True;
            Digit := Cardinal(Ord(Ch) - Ord('0'));
            if FractPartMultiplicator > 0.0 then
            begin
              Digit := Digit * FractPartMultiplicator;
              FractPartMultiplicator := FractPartMultiplicator *
                OneStepMultiplicator;
              Result := Result + Digit;
            end
            else
            begin
              Result := (Result * 10) + Digit;
            end;
          end;
        '-', '(':
          begin
            CurrNegFormatted := True;
            if DigitsFound then Break;
          end;
        '.', ',':
          begin
            DigitsFound := True;
            if FractPartMultiplicator > 0.0 then
            begin
              Break;
            end;
            FractPartMultiplicator := OneStepMultiplicator;
          end;
      else
        begin
          if Ch <> ThousandSeparator then
          begin
            if Ch = DecimalSeparator then
            begin
              DigitsFound := True;
              if FractPartMultiplicator > 0.0 then
              begin
                Break;
              end;
              FractPartMultiplicator := OneStepMultiplicator;
            end
            else
            begin
              if Ch > #32 then
              begin
                Break;
              end;
            end;
          end;
        end;
      end;
      Inc(I);
    end;
    if CurrNegFormatted then
    begin
      Result := -Result;
    end;
  end;
end;

function CurrSign(const Value: Currency): Integer;
begin
  if Value <> 0.0 then
  begin
    if Value > 0.0 then
    begin
      Result := +1;
    end
    else
    begin
      Result := -1;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

end.



