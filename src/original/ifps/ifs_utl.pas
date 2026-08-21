//  Filename: ifs_utl.pas
//  Author: Carlo Kok (ck@carlo-kok.com)
//  Utility functions to support script component
//-------------------------------------------------------------------
unit ifs_utl;
{$I ifs_def.inc}

interface

const
  MaxListSize = Maxint div 16;

type
  PPointerList = ^TPointerList;
  TPointerList = array[0..MaxListSize - 1] of Pointer;

  TIfList = class(TObject)
  private
    FCapacity: Cardinal;
    FCount: Cardinal;
    FData: PPointerList;
    {$IFNDEF NOSMARTLIST}
    FCheckCount: Cardinal;
    {$ENDIF}
  public
    {$IFNDEF NOSMARTLIST}
    procedure Recreate;
    {$ENDIF}


    constructor Create;
    destructor Destroy; override;
    function Count: Cardinal;
    function GetItem(Nr: Cardinal): Pointer;
    procedure SetItem(Nr: Cardinal; P: Pointer);
    procedure Add(P: Pointer);
    procedure Insert(P: Pointer; Where: Longint); 
    procedure AddBlock(List: PPointerList; Count: Longint);
    procedure Remove(P: Pointer);
    procedure Delete(Nr: Cardinal);
    procedure Clear; virtual;
  end;

  TIfStringList = class(TObject)
  private
    List: TIfList;
  public
    function Count: LongInt;
    function GetItem(Nr: LongInt): string;
    procedure SetItem(Nr: LongInt; const s: string);
    procedure Add(const P: string);
    procedure Delete(NR: LongInt);
    procedure Clear; 
    constructor Create; 
    destructor Destroy; override;
  end;

type
  TIfPasToken = (
  {Items that are used internally}
    CSTIINT_Comment,
    CSTIINT_WhiteSpace,
  {Tokens}
    CSTI_EOF,
    CSTI_Identifier,
    CSTI_SemiColon,
    CSTI_Comma,
    CSTI_Period,
    CSTI_Colon,
    CSTI_OpenRound,
    CSTI_CloseRound,
    CSTI_OpenBlock,
    CSTI_CloseBlock,
    CSTI_Assignment,
    CSTI_Equal,
    CSTI_NotEqual,
    CSTI_Greater,
    CSTI_GreaterEqual,
    CSTI_Less,
    CSTI_LessEqual,
    CSTI_Plus,
    CSTI_Minus,
    CSTI_Divide,
    CSTI_Multiply,
    CSTI_Integer,
    CSTI_Real,
    CSTI_String,
    CSTI_Char,
    CSTI_HexInt,
    CSTI_AddressOf,
    CSTI_Dereference,
  {Identifiers}
    CSTII_and,
    CSTII_array,
    CSTII_begin,
    CSTII_case,
    CSTII_const,
    CSTII_div,
    CSTII_do,
    CSTII_downto,
    CSTII_else,
    CSTII_end,
    CSTII_for,
    CSTII_function,
    CSTII_if,
    CSTII_in,
    CSTII_mod,
    CSTII_not,
    CSTII_of,
    CSTII_or,
    CSTII_procedure,
    CSTII_program,
    CSTII_repeat,
    CSTII_record,
    CSTII_set,
    CSTII_shl,
    CSTII_shr,
    CSTII_then,
    CSTII_to,
    CSTII_type,
    CSTII_until,
    CSTII_uses,
    CSTII_var,
    CSTII_while,
    CSTII_with,
    CSTII_xor,
    CSTII_exit,
    CSTII_break,
    CSTII_class,
    CSTII_constructor,
    CSTII_destructor,
    CSTII_inherited,
    CSTII_private,
    CSTII_public,
    CSTII_published,
    CSTII_protected,
    CSTII_property,
    CSTII_virtual,
    CSTII_override,
    CSTII_As,
    CSTII_Is,
    CSTII_Unit,
    CSTII_Continue,
    CSTII_Try,
    CSTII_Except,
    CSTII_Finally,
    CSTII_External,
    CSTII_Forward
    );

  TIFParserErrorKind = (iNoError, iCommentError, iStringError, iCharError, iSyntaxError);
  TIFParserError = record
    Kind: TIFParserErrorKind;
    Position: Cardinal;
  end;
  TIfPascalParser = class
  private
    FTokens: TIFList;
    FCurrToken: Cardinal;
    procedure SetCurrTokenPos(I: Cardinal);
    function GetCurrTokenPos: Cardinal;
  public
    procedure Next;

    function GetToken: string;

    property CurrTokenPos: Cardinal read GetCurrTokenPos write SetCurrTokenPos;
    function CurrTokenID: TIFPasToken;

    procedure Clear;
    function SetText(const Data: string; var ErrRec: TIFParserError): Boolean;

    function SetData(const Data: string): Boolean;
    function GetData(var Data: string): Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

function FastUpperCase(const s: string): string; // Fast uppercase
function FastLowerCase(const s: string): string; // Fast lowercase
function Fw(const S: string): string; // First word
procedure Rs(var S: string); // Remove space left
procedure RFw(var s: string); //remove first word

function StrToReal(const S: string): Extended;
function Padr(s: string; i: longInt): string;
function Padz(s: string; i: longInt): string;
function Padl(s: string; i: longInt): string;
function MKHash(const s: string): Cardinal; // used by ifpsdclass
function mi2s(i: Longint): string;

implementation

function mi2s(i: Longint): string;
begin
  result := #0#0#0#0;
  Longint((@result[1])^) := i;
end;

function MKHash(const s: string): Cardinal;
var
  i: Longint;
begin
  Result := 0;
  for I := 1 to length(s) do
  begin
    Result := ((Result shl 7) or (Result shr 25)) + ord(s[i]);
  end;
end;
//-------------------------------------------------------------------

//-------------------------------------------------------------------

function Padl(s: string; i: longInt): string;
begin
  result := StringOfChar(' ', i - length(result)) + s;
end;
//-------------------------------------------------------------------

function Padz(s: string; i: longInt): string;
begin
  result := StringOfChar('0', i - length(result)) + s;
end;
//-------------------------------------------------------------------

function Padr(s: string; i: longInt): string;
begin
  result := s + StringOfChar(' ', i - Length(s));
end;
//-------------------------------------------------------------------

function StrToReal(const S: string): Extended;
var
  e: Integer;
  Res: Extended;
begin
  Val(S, Res, e);
  if e <> 0 then
    StrToReal := -1
  else
    StrToReal := Res;
end;
//-------------------------------------------------------------------

constructor TIfList.Create;
begin
  inherited Create;
  FCount := 0;
  FCapacity := 16;
  {$IFNDEF NOSMARTLIST}
  FCheckCount := 0;
  {$ENDIF}
  GetMem(FData, 64);
end;

const
  FCapacityInc = 32;
{$IFNDEF NOSMARTLIST}
  FMaxCheckCount = (FCapacityInc div 4) * 16;
{$ENDIF}

function MM(i1,i2: Integer): Integer;
begin
  if ((i1 div i2) * i2) < i1 then
    mm := (i1 div i2 + 1) * i2
  else
    mm := (i1 div i2) * i2;
end;

{$IFNDEF NOSMARTLIST}
procedure TIfList.Recreate;
var
  NewData: PPointerList;
  NewCapacity: Cardinal;
  I: Longint;

begin

  FCheckCount := 0;
  NewCapacity := mm(FCount, FCapacityInc);
  if NewCapacity < 64 then NewCapacity := 64;
  GetMem(NewData, NewCapacity * 4);
  for I := 0 to Longint(FCount) -1 do
  begin
    NewData^[i] := FData^[I];
  end;
  FreeMem(FData, FCapacity * 4);
  FData := NewData;
  FCapacity := NewCapacity;
end;
{$ENDIF}

//-------------------------------------------------------------------

procedure TIfList.Add(P: Pointer);
begin
  if FCount >= FCapacity then
  begin
    Inc(FCapacity, FCapacityInc);// := FCount + 1;
    ReAllocMem(FData, FCapacity shl 2);
  end;
  FData[FCount] := P; // Instead of SetItem
  Inc(FCount);
  Inc(FCheckCount);
{$IFNDEF NOSMARTLIST}
  if FCheckCount > FMaxCheckCount then Recreate;
{$ENDIF}
end;

procedure TIfList.AddBlock(List: PPointerList; Count: Longint);
var
  L: Longint;

begin
  if Longint(FCount) + Count > Longint(FCapacity) then
  begin
    Inc(FCapacity, mm(Count, FCapacityInc));
    ReAllocMem(FData, FCapacity shl 2);
  end;
  for L := 0 to Count -1 do
  begin
    FData^[FCount] := List^[L];
    Inc(FCount);
  end;
{$IFNDEF NOSMARTLIST}
  Inc(FCheckCount);
  if FCheckCount > FMaxCheckCount then Recreate;
{$ENDIF}
end;


//-------------------------------------------------------------------

procedure TIfList.Delete(Nr: Cardinal);
begin
  if FCount = 0 then Exit;
  if Nr < FCount then
  begin
    Move(FData[Nr + 1], FData[Nr], (FCount - Nr) * 4);
    Dec(FCount);
{$IFNDEF NOSMARTLIST}
    Inc(FCheckCount);
    if FCheckCount > FMaxCheckCount then Recreate;
{$ENDIF}
  end;
end;
//-------------------------------------------------------------------

procedure TIfList.Remove(P: Pointer);
var
  I: Cardinal;
begin
  if FCount = 0 then Exit;
  I := 0;
  while I < FCount do
  begin
    if FData[I] = P then
    begin
      Delete(I);
      Exit;
    end;
    Inc(I);
  end;
end;
//-------------------------------------------------------------------

procedure TIfList.Clear;
begin
  FCount := 0;
{$IFNDEF NOSMARTLIST}
  Recreate;
{$ENDIF}
end;
//-------------------------------------------------------------------

destructor TIfList.Destroy;
begin
  FreeMem(FData, FCapacity * 4);
  inherited Destroy;
end;
//-------------------------------------------------------------------

procedure TIfList.SetItem(Nr: Cardinal; P: Pointer);
begin
  if (FCount = 0) or (Nr >= FCount) then
    Exit;
  FData[Nr] := P;
end;
//-------------------------------------------------------------------
procedure TIfList.Insert(P: Pointer; Where: Integer);
var
  NewData: PPointerList;
  NewCapacity: Cardinal;
  I: Longint;

begin
  NewCapacity := mm(FCount+1, FCapacityInc);
  if NewCapacity < 64 then NewCapacity := 64;
  GetMem(NewData, NewCapacity * 4);
  for I := 0 to Where -1 do
  begin
    NewData^[i] := FData^[I];
  end;
  NewData[Where] := P;
  for I := Where to Longint(FCount) -1 do
  begin
    NewData^[i+1] := FData^[I];
  end;
  FreeMem(FData, FCapacity * 4);
  FData := NewData;
  Inc(FCount);
  FCapacity := NewCapacity;
{$IFNDEF NOSMARTLIST}
  FCheckCount := 0;
{$ENDIF}

end;
//-------------------------------------------------------------------

function TifList.GetItem(Nr: Cardinal): Pointer;
begin
  if Nr < FCount then
    Result := FData[Nr]
  else
    Result := nil;
end;
//-------------------------------------------------------------------

function TifList.Count: Cardinal;
begin
  Result := FCount;
end;
//-------------------------------------------------------------------

function TIfStringList.Count: LongInt;
begin
  count := List.count;
end;
type pStr = ^string;

//-------------------------------------------------------------------

function TifStringList.GetItem(Nr: LongInt): string;
var
  S: PStr;
begin
  s := List.GetItem(Nr);
  if s = nil then
    Result := ''
  else

    Result := s^;
end;
//-------------------------------------------------------------------

procedure TifStringList.SetItem(Nr: LongInt; const s: string);
var
  p: PStr;
begin
  p := List.GetItem(Nr);
  if p = nil
    then
    Exit;
  p^ := s;
end;
//-------------------------------------------------------------------

procedure TifStringList.Add(const P: string);
var
  w: PStr;
begin
  new(w);
  w^ := p;
  List.Add(w);
end;
//-------------------------------------------------------------------

procedure TifStringList.Delete(NR: LongInt);
var
  W: PStr;
begin
  W := list.getitem(nr);
  if assigned(w) then
  begin
    dispose(w);
  end;
  list.Delete(Nr);
end;

procedure TifStringList.Clear;
begin
  while List.Count > 0 do Delete(0);
end;

constructor TifStringList.Create;
begin
  inherited Create;
  List := TIfList.Create;
end;

destructor TifStringList.Destroy;
begin
  while List.Count > 0 do
    Delete(0);
  List.Destroy;
  inherited Destroy;
end;

//-------------------------------------------------------------------

procedure RFw(var s: string); //remove first word
var
  x: longint;
begin
  x := pos(' ', s);
  if x = 0 then s := '' else delete(s, 1, x);
  rs(s);
end;

function Fw(const S: string): string; //  First word
var
  x: integer;
begin
  x := pos(' ', s);
  if x > 0
    then Fw := Copy(S, 1, x - 1)
  else Fw := S;
end;
//-------------------------------------------------------------------

procedure Rs(var S: string); // Remove space
var
  x: integer;
begin
  if s > '' then
  begin
    x := 1;
    while (copy(s, x, 1) = ' ') do inc(x);
    if x > 1
      then s := copy(s, x, (length(s) - x) + 1);
  end;
end;

//-------------------------------------------------------------------
function FastUpperCase(const s: String): string;
{Fast uppercase}
var
  I: Integer; 
  C: Char;
begin
  Result := S;
  I := Length(Result);
  while I > 0 do
  begin
    C := Result[I];
    if C in [#97..#122] then
      Dec(Byte(Result[I]), 32);
    Dec(I);
  end;
end;
//-------------------------------------------------------------------

function FastLowerCase(const s: string): string;
{Fast lowercase}
var
  I: Integer;
  C: Char;
begin
  Result := S;
  I := Length(Result);
  while I > 0 do
  begin
    C := Result[I];
    if C in [#65..#90] then
      Inc(Byte(Result[I]), 32);
    Dec(I);
  end;
end;

//-------------------------------------------------------------------
type
  PIFToken = ^TIFToken;
  TIFToken = packed record
    RealPosition: Cardinal;
    Token: TIfPasToken;
    Data: string;  // only applicable when Token in [CSTI_Identifier, CSTI_Integer, CSTI_Real, CSTI_String, CSTI_Char, CSTI_HexInt]
  end;

procedure TIfPascalParser.SetCurrTokenPos(I: Cardinal);
var
  U: Longint;
  R: Cardinal;
begin
  R := Cardinal($FFFFFFFF);
  for u := 0 to FTokens.Count-1 do
  begin
    if PIFToken(FTokens.GetItem(U))^.RealPosition <= I then
      R := U;
  end;
  FCurrToken := R;
end;

procedure TIfPascalParser.Next;
begin
  if FCurrToken + 1 < Cardinal(FTokens.Count) then
  begin
    Inc(FCurrToken);
  end else
    FCurrToken := Cardinal($FFFFFFFF);
end;

function TIFPascalParser.GetCurrTokenPos: Cardinal;
var
  T: PIFToken;
begin
  T := FTokens.GetItem(FCurrToken);
  if T <> nil then
    GetCurrTokenPos := T^.RealPosition
  else begin
    T := FTokens.GetItem(FTokens.Count -1);
    if t = nil then
      GetCurrTokenPos := 0
    else
      GetCurrTokenPos := T^.RealPosition;
  end;
end;

function TIfPascalParser.GetToken: string;
var
  T: PIFToken;
begin
  T := FTokens.GetItem(FCurrToken);
  if T <> nil then
    GetToken := T^.Data
  else
    GetToken := '';
end;

function TIfPascalParser.CurrTokenID: TIFPasToken;
var
  T: PIFToken;
begin
  T := FTokens.GetItem(FCurrToken);
  if T <> nil then
    CurrTokenId := T^.Token
  else
    CurrTokenId := CSTI_EOF;
end;

procedure TIfPascalParser.Clear;
var
  i: Integer;
  T: PIFToken;
begin
  for i := 0 to Longint(FTokens.Count) -1 do
  begin
    T := FTokens.GetItem(I);
    T^.Data := '';
    Dispose(t);
  end;
  FTokens.Clear;
end;

type
  TRTab = record
    name: string[20];
    c: TIfPasToken;
  end;


const
  KEYWORD_COUNT = 56;
  LookupTable: array[0..KEYWORD_COUNT - 1] of TRTab = (
      (name: 'AND'; c: CSTII_and),
      (name: 'ARRAY'; c: CSTII_array),
      (name: 'AS'; c: CSTII_as),
      (name: 'BEGIN'; c: CSTII_begin),
      (name: 'BREAK'; c: CSTII_break),
      (name: 'CASE'; c: CSTII_case),
      (name: 'CLASS'; c: CSTII_class),
      (name: 'CONST'; c: CSTII_const),
      (name: 'CONSTRUCTOR'; c: CSTII_constructor),
      (name: 'CONTINUE'; c: CSTII_Continue),
      (name: 'DESTRUCTOR'; c: CSTII_destructor),
      (name: 'DIV'; c: CSTII_div),
      (name: 'DO'; c: CSTII_do),
      (name: 'DOWNTO'; c: CSTII_downto),
      (name: 'ELSE'; c: CSTII_else),
      (name: 'END'; c: CSTII_end),
      (name: 'EXCEPT'; c: CSTII_except),
      (name: 'EXIT'; c: CSTII_exit),
      (name: 'EXTERNAL'; c: CSTII_External),
      (name: 'FINALLY'; c: CSTII_finally),
      (name: 'FOR'; c: CSTII_for),
      (name: 'FORWARD'; c: CSTII_Forward),
      (name: 'FUNCTION'; c: CSTII_function),
      (name: 'IF'; c: CSTII_if),
      (name: 'IN'; c: CSTII_in),
      (name: 'INHERITED'; c: CSTII_inherited),
      (name: 'IS'; c: CSTII_is),
      (name: 'MOD'; c: CSTII_mod),
      (name: 'NOT'; c: CSTII_not),
      (name: 'OF'; c: CSTII_of),
      (name: 'OR'; c: CSTII_or),
      (name: 'OVERRIDE'; c: CSTII_override),
      (name: 'PRIVATE'; c: CSTII_private),
      (name: 'PROCEDURE'; c: CSTII_procedure),
      (name: 'PROGRAM'; c: CSTII_program),
      (name: 'PROPERTY'; c: CSTII_property),
      (name: 'PROTECTED'; c: CSTII_protected),
      (name: 'PUBLIC'; c: CSTII_public),
      (name: 'PUBLISHED'; c: CSTII_published),
      (name: 'RECORD'; c: CSTII_record),
      (name: 'REPEAT'; c: CSTII_repeat),
      (name: 'SET'; c: CSTII_set),
      (name: 'SHL'; c: CSTII_shl),
      (name: 'SHR'; c: CSTII_shr),
      (name: 'THEN'; c: CSTII_then),
      (name: 'TO'; c: CSTII_to),
      (name: 'TRY'; c: CSTII_try),
      (name: 'TYPE'; c: CSTII_type),
      (name: 'UNIT'; c: CSTII_Unit),
      (name: 'UNTIL'; c: CSTII_until),
      (name: 'USES'; c: CSTII_uses),
      (name: 'VAR'; c: CSTII_var),
      (name: 'VIRTUAL'; c: CSTII_virtual),
      (name: 'WHILE'; c: CSTII_while),
      (name: 'WITH'; c: CSTII_with),
      (name: 'XOR'; c: CSTII_xor));


function TIfPascalParser.SetText(const Data: string; var ErrRec: TIFParserError): Boolean;
var
  Text: PChar;
  _CurrTokenPos, _CurrTokenLen: Cardinal;
  _CurrToken: TIFPasToken;
  P: PIFToken;
  //-------------------------------------------------------------------

  function CheckReserved(Const S: ShortString; var CurrTokenId: TIfPasToken): Boolean;
  {Check if an identifier is a reserved word}
  var
    L, H, I: LongInt;
    J: Char;
    SName: ShortString;
  begin
    L := 0;
    J := S[0];
    H := KEYWORD_COUNT-1;
    while L <= H do
    begin
      I := (L + H) shr 1;
      SName := LookupTable[i].Name;
      if J = SName[0] then
      begin
        if S = SName then
        begin
          CheckReserved := True;
          CurrTokenId := LookupTable[I].c;
          Exit;
        end;
        if S > SName then
          L := I + 1
        else
          H := I - 1;
      end else
        if S > SName then
          L := I + 1
        else
          H := I - 1;
    end;
    CheckReserved := False;
  end;
  //-------------------------------------------------------------------

  function GetToken(CurrTokenPos, CurrTokenLen: Cardinal): string;
  var
    s: string;
  begin
    SetLength(s, CurrTokenLen);
    Move(Text[CurrTokenPos], S[1], CurrtokenLen);
    GetToken := s;
  end;

  function ParseToken(var CurrTokenPos, CurrTokenLen: Cardinal; var CurrTokenId: TIfPasToken): TIFParserErrorKind;
  {Parse the token}
  var
    ct, ci: Cardinal;
    hs: Boolean;
  begin
    ParseToken := iNoError;
    ct := CurrTokenPos;
    case Text[ct] of
      #0:
        begin
          CurrTokenId := CSTI_EOF;
          CurrTokenLen := 0;
        end;
      'A'..'Z', 'a'..'z', '_':
        begin
          ci := ct + 1;
          while (Text[ci] in ['_', '0'..'9', 'a'..'z', 'A'..'Z']) do begin
            Inc(ci);
          end;
          CurrTokenLen := ci - ct;
          if not CheckReserved(FastUppercase(GetToken(CurrTokenPos, CurrtokenLen)), CurrTokenId) then
          begin
            CurrTokenId := CSTI_Identifier;
          end;
        end;
      '$':
        begin
          ci := ct + 1;

          while (Text[ci] in ['0'..'9', 'a'..'f', 'A'..'F'])
            do Inc(ci);

          CurrTokenId := CSTI_HexInt;
          CurrTokenLen := ci - ct;
        end;

      '0'..'9':
        begin
          hs := False;
          ci := ct;
          while (Text[ci] in ['0'..'9']) do
          begin
            Inc(ci);
            if (Text[ci] = '.') and (not hs) then
            begin
              hs := True;
              Inc(ci);
            end;
          end;
          if (text[ci] = 'E')or (text[ci] = 'e') then
          begin
            hs := true;
            inc(ci);
            while (text[ci] in ['0'..'9']) do
            begin
              inc(ci);
            end;
          end;
          if hs then CurrTokenId := CSTI_Real
          else CurrTokenId := CSTI_Integer;

          CurrTokenLen := ci - ct;
        end;


      #39:
        begin
          ci := ct + 1;
          while (Text[ci] <> #0) and (Text[ci] <> #13) and
            (Text[ci] <> #10) and (Text[ci] <> #39)
            do begin
            Inc(ci);
          end;
          if Text[ci] = #39 then
            CurrTokenId := CSTI_String
          else
          begin
            CurrTokenId := CSTI_String;
            ParseToken := iStringError;
          end;
          CurrTokenLen := ci - ct + 1;
        end;
      '#':
        begin
          ci := ct + 1;
          if Text[ci] = '$' then
          begin
            while (Text[ci] in ['A'..'Z', 'a'..'z', '0'..'9']) do begin
              Inc(ci);
            end;
            CurrTokenId := CSTI_Char;
            CurrTokenLen := ci - ct - 1;
          end else
          begin
            while (Text[ci] in ['0'..'9']) do begin
              Inc(ci);
            end;
            if Text[ci] in ['A'..'Z', 'a'..'z', '_'] then
            begin
              ParseToken := iCharError;
              CurrTokenId := CSTI_Char;
            end else
              CurrTokenId := CSTI_Char;
            CurrTokenLen := ci - ct;
          end;
        end;
      '=':
        begin
          CurrTokenId := CSTI_Equal;
          CurrTokenLen := 1;
        end;
      '>':
        begin
          if Text[ct + 1] = '=' then
          begin
            CurrTokenid := CSTI_GreaterEqual;
            CurrTokenLen := 2;
          end else
          begin
            CurrTokenid := CSTI_Greater;
            CurrTokenLen := 1;
          end;
        end;
      '<':
        begin
          if Text[ct + 1] = '=' then
          begin
            CurrTokenId := CSTI_LessEqual;
            CurrTokenLen := 2;
          end else
            if Text[ct + 1] = '>' then
            begin
              CurrTokenId := CSTI_NotEqual;
              CurrTokenLen := 2;
            end else
            begin
              CurrTokenId := CSTI_Less;
              CurrTokenLen := 1;
            end;
        end;
      ')':
        begin
          CurrTokenId := CSTI_CloseRound;
          CurrTokenLen := 1;
        end;
      '(':
        begin
          if Text[ct + 1] = '*' then
          begin
            ci := ct + 1;
            while (Text[ci] <> #0) do begin
              if (Text[ci] = '*') and (Text[ci + 1] = ')') then
                Break;
              Inc(ci);
            end;
            if (Text[ci] = #0) then
            begin
              CurrTokenId := CSTIINT_Comment;
              ParseToken := iCommentError;
            end else
            begin
              CurrTokenId := CSTIINT_Comment;
              Inc(ci, 2);
            end;
            CurrTokenLen := ci - ct;
          end
          else
          begin
            CurrTokenId := CSTI_OpenRound;
            CurrTokenLen := 1;
          end;
        end;
      '[':
        begin
          CurrTokenId := CSTI_OpenBlock;
          CurrTokenLen := 1;
        end;
      ']':
        begin
          CurrTokenId := CSTI_CloseBlock;
          CurrTokenLen := 1;
        end;
      ',':
        begin
          CurrTokenId := CSTI_Comma;
          CurrTokenLen := 1;
        end;
      '.':
        begin
          CurrTokenId := CSTI_Period;
          CurrTokenLen := 1;
        end;
      '@':
        begin
          CurrTokenId := CSTI_AddressOf;
          CurrTokenLen := 1;
        end;
      '^':
        begin
          CurrTokenId := CSTI_Dereference;
          CurrTokenLen := 1;
        end;
      ';':
        begin
          CurrTokenId := CSTI_Semicolon;
          CurrTokenLen := 1;
        end;
      ':':
        begin
          if Text[ct + 1] = '=' then
          begin
            CurrTokenId := CSTI_Assignment;
            CurrTokenLen := 2;
          end else
          begin
            CurrTokenId := CSTI_Colon;
            CurrTokenLen := 1;
          end;
        end;
      '+':
        begin
          CurrTokenId := CSTI_Plus;
          CurrTokenLen := 1;
        end;
      '-':
        begin
          CurrTokenId := CSTI_Minus;
          CurrTokenLen := 1;
        end;
      '*':
        begin
          CurrTokenId := CSTI_Multiply;
          CurrTokenLen := 1;
        end;
      '/':
        begin
          if Text[ct + 1] = '/' then
          begin
            ci := ct + 1;
            while (Text[ci] <> #0) and (Text[ci] <> #13) and
              (Text[ci] <> #10) do begin
              Inc(ci);
            end;
            if (Text[ci] = #0) then
            begin
              CurrTokenId := CSTIINT_Comment;
              ParseToken := iCommentError;
            end else
            begin
              if Text[ci + 1] = #10 then
                Inc(ci) else

                if Text[ci + 1] = #13 then
                  Inc(ci);
              CurrTokenId := CSTIINT_Comment;
            end;
            CurrTokenLen := ci - ct + 1;
          end else
          begin
            CurrTokenId := CSTI_Divide;
            CurrTokenLen := 1;
          end;
        end;
      #32, #9, #13, #10:
        begin
          ci := ct + 1;
          while (Text[ci] in [#32, #9, #13, #10]) do begin
            Inc(ci);
          end;
          CurrTokenId := CSTIINT_WhiteSpace;
          CurrTokenLen := ci - ct;
        end;
      '{':
        begin
          ci := ct + 1;
          while (Text[ci] <> #0) and (Text[ci] <> '}') do begin
            Inc(ci);
          end;
          if (Text[ci] = #0) then
          begin
            CurrTokenId := CSTIINT_Comment;
            ParseToken := iCommentError;
          end else
            CurrTokenId := CSTIINT_Comment;
          CurrTokenLen := ci - ct + 1;
        end;
    else
      begin
        ParseToken := iSyntaxError;
        CurrTokenId := CSTIINT_Comment;
        CurrTokenLen := 1;
      end;
    end;
  end;
  //-------------------------------------------------------------------
begin
  Clear;
  SetText := False;
  Text := PChar(Data);
  _CurrTokenPos := 0;
  repeat
    ErrRec.Kind := ParseToken(_CurrTokenPos, _CurrTokenLen, _CurrToken);
    if ErrRec.Kind <> iNoError then
    begin
      ErrRec.Position := _CurrTokenPos;
      Clear;
      exit;
    end;
    p := nil;
    case _CurrToken of
      CSTIINT_Comment, CSTIINT_WhiteSpace:; //ignore those
      CSTI_Integer, CSTI_Real, CSTI_String, CSTI_Char, CSTI_HexInt:
        begin
          new(P);
          p^.Data := GetToken(_CurrTokenPos, _CurrTokenLen);
        end;
      CSTI_Identifier:
        begin
          new(P);
          p^.Data := FastUppercase(GetToken(_CurrTokenPos, _CurrTokenLen));
        end;
      else
        begin
          New(P);
        end;
    end;
    if p <> nil then
    begin
      p^.RealPosition := _CurrTokenPos;
      p^.Token := _CurrToken;
      FTokens.Add(P);
    end;
    _CurrTokenPos := _CurrTokenPos + _CurrTokenLen;
  until _CurrToken = CSTI_Eof;
  SetText := True;
  FCurrToken := 0;
end;

constructor TIfPascalParser.Create;
begin
  inherited Create;
  FTokens := TIFList.Create;
  FCurrToken := Cardinal($FFFFFFFF);
end;

const HDR = Longint(ord('I') shl 24 or Ord('F') shl 16 or ord('S') shl 8);

function TIfPascalParser.SetData(const Data: string): Boolean;
var
  Pos: Longint;
  function Read(var dta; Size: Longint): boolean;
  begin
    if (Length(Data)-pos+1) < size then
      Read := False
    else
      begin
        Read := True;
        Move(Data[Pos], Dta, Size);
        Pos := pos + Size;
      end;
  end;
var
  N: PIFToken;
  D: Longint;
begin
  Pos := 1;
  SetData := false;
  Clear;
  if not Read(D, sizeof(D)) then Exit;
  if D <> HDR then Exit;
  while Pos <= Length(Data) do
  begin
    new(n);
    if not Read(N^.RealPosition, Sizeof(N^.RealPosition)) then begin Dispose(N); Exit; end;
    if not Read(N^.Token, Sizeof(N^.Token)) then begin Dispose(N); Exit; end;
    if n^.Token in [CSTI_Integer, CSTI_Real, CSTI_String, CSTI_Char, CSTI_HexInt, CSTI_Identifier] then
    begin
      if not Read(D, Sizeof(D)) then begin Dispose(N); Exit; end;
      SetLength(N^.Data, D);
      if not Read(N^.Data[1], D) then begin Dispose(N); Exit; end;
    end;
    FTokens.Add(n);
  end;
  SetData := True;
end;

function TIfPascalParser.GetData(var Data: string): Boolean;

  procedure Write(const Dta; size: Longint);
  begin
    SetLength(Data, Length(Data)+Size);
    Move(Dta, Data[Length(data)-Size+1], Size);
  end;
var
  i,l: Longint;
  n: PIFToken;
begin
  Data := '';
  L := Hdr;
  Write(L, sizeof(L));
  for i := 0 to FTokens.Count-1 do
  begin
    n := FTokens.GetItem(I);
    Write(n^.RealPosition, Sizeof(n^.RealPosition));
    Write(n^.Token, Sizeof(n^.Token));
    if n^.Token in [CSTI_Integer, CSTI_Real, CSTI_String, CSTI_Char, CSTI_HexInt, CSTI_Identifier] then
    begin
      l := length(n^.Data);
      Write(L, Sizeof(L));
      Write(n^.Data[1], L);
    end;
  end;
  GetData := True;
end;

destructor TIfPascalParser.Destroy;
begin
  Clear;
  FTokens.Free;
  inherited Destroy;
end;



end.

