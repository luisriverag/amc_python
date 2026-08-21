unit ifpscall;
{
  Innerfuse Pascal Script Call unit
  You may not copy a part of this unit, only use it as whole, with
  Innerfuse Pascal Script Script Engine.

Todo:
  - Record passing
}
{$I ifs_def.inc}
interface
uses
  ifspas, ifs_var, ifs_utl;

type
  TCallingConvention = (ccRegister, ccPascal, CCCdecl, CCStdCall);
  TExternalObjectToStr = function(Ptr: Pointer; v: PIfVariant; SE: TIfPasScript): string;
  TExternalVarObjectToStr = function(Ptr: Pointer; v: PIfVariant; SE: TIfPasScript): string;
  TResultToExternalObject = procedure(Ptr: Pointer; res: PIfVariant; v: Pointer; SE: TIfPasScript);
  PExternalObjectSupport = ^TExternalObjectSupport;
  TExternalObjectSupport = packed record
    Ptr: Pointer;
    ObjToStr: TExternalObjectToStr;
    VarObjToStr: TExternalVarObjectToStr;
    ResultToStr: TResultToExternalObject;
  end;

function InnerfuseCall(SE: TIfPasScript; Self, Address: Pointer; CallingConv: TCallingConvention; Params: PVariableManager; res: PIfVariant): Boolean;
function InnerfuseCall2(SE: TIfPasScript; Self, Address: Pointer; CallingConv: TCallingConvention; Params: PVariableManager; res: PIfVariant; ExtObjSupport: PExternalObjectSupport): Boolean; // res should already have been created with the type used for it

function ReadHeader(SE: TIfPasScript; Decl: string; var FuncName, FuncParam: string; var CC: TCallingConvention; DefaultCC: TCallingConvention): Boolean;

implementation

function ReadHeader(SE: TIfPasScript; Decl: string; var FuncName, FuncParam: string; var CC: TCallingConvention; DefaultCC: TCallingConvention): Boolean;
var
  Parser: TIfPascalParser;
  Temp, CurrVar: string;
  FuncRes,
    CurrType: Longint;
  E: TIFPARSERERROR;

  function GetType(const s: string): Longint;
  var
    t: PTypeRec;
  begin
    if (s = 'PCHAR') then begin
      t := SE.GetType('!PCHAR');
      if t = nil then begin
        t := SE.AddTypeEx('!PCHAR');
        t^.Ext := Pointer(1);
      end;
      GetType := Longint(t);
    end else
      if (s = 'LONGBOOL') then begin
        t := SE.GetType('!LONGBOOL');
        if t = nil then begin
          t := SE.AddTypeEx('!LONGBOOL');
          t^.Ext := Pointer(2);
        end;
        GetType := Longint(t);
      end else
        if (s = 'WORDBOOL') then begin
          t := SE.GetType('!WORDBOOL');
          if t = nil then begin
            t := SE.AddTypeEx('!WORDBOOL');
            t^.Ext := Pointer(1);
          end;
          GetType := Longint(t);
        end else begin
          t := SE.GetType(s);
          if not assigned(t) then begin
            GetType := 0;
            exit;
          end;
          case t.atypeid of
            CSV_UByte,
              CSV_SByte,
              CSV_UInt16,
              CSV_SInt16,
              CSV_UInt32,
              CSV_SInt32,
              CSV_Char,
              CSV_Bool,
              CSV_Double,
              CSV_Single,
              CSV_Extended,
              CSV_String {,
        CSV_Record}: GetType := Longint(t);
          else GetType := 0;
          end;
        end;
  end;
begin
  Parser := TIfPascalParser.Create;
  ReadHeader := False;
  if not Parser.SetText(Decl, E) then begin
    Parser.Free;
    exit;
  end;
  if Parser.CurrTokenId = CSTII_Procedure then
    FuncRes := 0
  else
    FuncRes := 1;
  Parser.Next;
  FuncName := Parser.GetToken;
  Parser.Next;
  FuncParam := '';
  CurrVar := '';
  if Parser.CurrTokenId = CSTI_OpenRound then begin
    Parser.Next;
    while True do begin
      if Parser.CurrTokenId = CSTI_EOF then begin
        Parser.Free;
        exit;
      end;
      if Parser.CurrTokenId = CSTII_Var then begin
        CurrVar := '!';
        Parser.Next;
      end; {if}
      while True do begin
        if Parser.CurrTokenId = CSTI_EOF then begin
          Parser.Free;
          exit;
        end;
        if Parser.CurrTokenId <> CSTI_Identifier then begin
          Parser.Free;
          exit;
        end;
        CurrVar := CurrVar + Parser.GetToken + '|';
        Parser.Next;
        if Parser.CurrTokenId = CSTI_Colon then break;
        if Parser.CurrTokenId <> CSTI_Comma then begin
          Parser.Free;
          exit;
        end;
        Parser.Next;
      end; {while}
      Parser.Next;
      CurrType := GetType(Parser.GetToken);
      if CurrType = 0 then begin
        Parser.Free;
        exit;
      end;
      if Pos('!', CurrVar) = 1 then begin
        Delete(CurrVar, 1, 1);
        while Pos('|', CurrVar) > 0 do begin
          Temp := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #1 + mi2s(Length(Temp)) + Temp + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end else begin
        while Pos('|', CurrVar) > 0 do begin
          Temp := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #0 + mi2s(Length(Temp)) + Temp + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end; {if}
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then begin
        Parser.Next;
        break;
      end; {if}
      Parser.Next;
    end;
  end;
  if FuncRes = 1 then begin
    Parser.Next;
    FuncRes := GetType(Parser.GetToken);
    if FuncRes = 0 then begin
      Parser.Free;
      exit;
    end;
    Parser.Next;
  end;
  CC := ccRegister;
  if Parser.CurrTokenId = CSTI_Semicolon then begin
    Parser.Next;
    if Parser.CurrTokenId = CSTI_Identifier then begin
      if Parser.GetToken = 'STDCALL' then
        CC := CCStdCall
      else if Parser.GetToken = 'CDECL' then
        CC := CCCdecl
      else if Parser.GetToken = 'PASCAL' then
        CC := ccPascal
      else if Parser.GetToken = 'REGISTER' then
        CC := ccRegister
      else
        CC := DefaultCC;
      // Register is default.
    end;
  end;
  FuncParam := mi2s(FuncRes) + FuncParam;
  ReadHeader := True;
  Parser.Free;
end;

function RealFloatCall_Register(p: Pointer;
  _EAX, _EDX, _ECX: Cardinal;
  StackData: Pointer;
  StackDataLen: Longint // stack length are in 4 bytes. (so 1 = 4 bytes)
  ): Extended; Stdcall; // make sure all things are on stack
var
  E: Extended;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    mov eax,_EAX
    mov edx,_EDX
    mov ecx,_ECX
    call p
    fstp tbyte ptr [e]
  end;
  Result := E;
end;

function RealFloatCall_Other(p: Pointer;
  StackData: Pointer;
  StackDataLen: Longint // stack length are in 4 bytes. (so 1 = 4 bytes)
  ): Extended; Stdcall; // make sure all things are on stack
var
  E: Extended;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    call p
    fstp tbyte ptr [e]
  end;
  Result := E;
end;

function RealFloatCall_CDecl(p: Pointer;
  StackData: Pointer;
  StackDataLen: Longint // stack length are in 4 bytes. (so 1 = 4 bytes)
  ): Extended; Stdcall; // make sure all things are on stack
var
  E: Extended;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    call p
    fstp tbyte ptr [e]
    @@5:
    mov ecx, stackdatalen
    jecxz @@2
    @@6:
    pop edx
    dec ecx
    or ecx, ecx
    jnz @@6
  end;
  Result := E;
end;

function RealCall_Register(p: Pointer;
  _EAX, _EDX, _ECX: Cardinal;
  StackData: Pointer;
  StackDataLen: Longint; // stack length are in 4 bytes. (so 1 = 4 bytes)
  ResultLength: Longint): Longint; Stdcall; // make sure all things are on stack
var
  r: Longint;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    mov eax,_EAX
    mov edx,_EDX
    mov ecx,_ECX
    call p
    mov ecx, resultlength
    cmp ecx, 0
    je @@5
    cmp ecx, 1
    je @@3
    cmp ecx, 2
    je @@4
    mov r, eax
    jmp @@5
    @@3:
    xor ecx, ecx
    mov cl, al
    mov r, ecx
    jmp @@5
    @@4:
    xor ecx, ecx
    mov cx, ax
    mov r, ecx
    @@5:
  end;
  Result := r;
end;

function RealCall_Other(p: Pointer;
  StackData: Pointer;
  StackDataLen: Longint; // stack length are in 4 bytes. (so 1 = 4 bytes)
  ResultLength: Longint): Longint; Stdcall; // make sure all things are on stack
var
  r: Longint;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    call p
    mov ecx, resultlength
    cmp ecx, 0
    je @@5
    cmp ecx, 1
    je @@3
    cmp ecx, 2
    je @@4
    mov r, eax
    jmp @@5
    @@3:
    xor ecx, ecx
    mov cl, al
    mov r, ecx
    jmp @@5
    @@4:
    xor ecx, ecx
    mov cx, ax
    mov r, ecx
    @@5:
  end;
  Result := r;
end;

function RealCall_CDecl(p: Pointer;
  StackData: Pointer;
  StackDataLen: Longint; // stack length are in 4 bytes. (so 1 = 4 bytes)
  ResultLength: Longint): Longint; Stdcall; // make sure all things are on stack
var
  r: Longint;
begin
  asm
    mov ecx, stackdatalen
    jecxz @@2
    mov eax, stackdata
    @@1:
    mov edx, [eax]
    push edx
    add eax,4
    dec ecx
    or ecx, ecx
    jnz @@1
    @@2:
    call p
    mov ecx, resultlength
    cmp ecx, 0
    je @@5
    cmp ecx, 1
    je @@3
    cmp ecx, 2
    je @@4
    mov r, eax
    jmp @@5
    @@3:
    xor ecx, ecx
    mov cl, al
    mov r, ecx
    jmp @@5
    @@4:
    xor ecx, ecx
    mov cx, ax
    mov r, ecx
    @@5:
    mov ecx, stackdatalen
    jecxz @@2
    @@6:
    pop edx
    dec ecx
    or ecx, ecx
    jnz @@6
  end;
  Result := r;
end;

function InnerfuseCall(SE: TIfPasScript; Self, Address: Pointer; CallingConv: TCallingConvention; Params: PVariableManager; res: PIfVariant): Boolean; // res should already have been created with the type used for it
begin
  Result := InnerfuseCall2(SE, Self, Address, CallingConv, Params, res, nil);
end;

function InnerfuseCall2(SE: TIfPasScript; Self, Address: Pointer; CallingConv: TCallingConvention; Params: PVariableManager; res: PIfVariant; ExtObjSupport: PExternalObjectSupport): Boolean; // res should already have been created with the type used for it
var
  Temp, Stack: ansistring;
  I: Longint;
  RegUsage: Byte;
  EAX, EDX, ECX: Longint;
  b: Boolean;

  function GetPtr(fVar: PIfVariant; var CanInRegister: Boolean): string;
  begin
    CanInRegister := True;
    Result := '';
    if fVar^.VType^.atypeid = CSV_Var then begin
      fVar := GetVarLink(fVar);
      case fVar^.VType^.atypeid of
{$IFNDEF NOCLASSES}
        CSV_ExternalObject: begin
            if ExtObjSupport = nil then exit;
            Result := ExtObjSupport^.VarObjToStr(ExtObjSupport^.Ptr, fVar, SE);
          end;
{$ENDIF}
        CSV_String: begin
            Result := #0#0#0#0;
            Pointer((@Result[1])^) := @(fVar^.Cv_Str);
          end;
        CSV_Bool, CSV_Char, CSV_UByte, CSV_SByte, CSV_UInt16, CSV_SInt16, CSV_UInt32, CSV_SInt32, CSV_Double, CSV_Single, CSV_Extended: begin
            Result := #0#0#0#0;
            Pointer((@Result[1])^) := @(fVar^.Cv_Char);
          end;
      else begin
          exit; //invalid type
        end;
      end;
    end else begin
      case fVar^.VType^.atypeid of
{$IFNDEF NOCLASSES}
        CSV_ExternalObject: begin
            if ExtObjSupport = nil then exit;
            Result := ExtObjSupport^.ObjToStr(ExtObjSupport^.Ptr, fVar, SE);
          end;
{$ENDIF}
        CSV_Double: {8 bytes} begin
            CanInRegister := False;
            Result := #0#0#0#0#0#0#0#0;
            double((@Result[1])^) := fVar^.CV_Double;
          end;

        CSV_Single: {4 bytes} begin
            CanInRegister := False;
            Result := #0#0#0#0;
            Single((@Result[1])^) := fVar^.CV_Single;
          end;

        CSV_Extended: {10 bytes} begin
            CanInRegister := False;
            Result := #0#0#0#0#0#0#0#0#0#0;
            Extended((@Result[1])^) := fVar^.Cv_Extended;
          end;

        CSV_Char, CSV_UByte, CSV_SByte, CSV_Bool: begin
            Result := fVar^.Cv_Char + #0#0#0;
          end;
        CSV_UInt16, CSV_SInt16: begin
            Result := #0#0#0#0;
            Word((@Result[1])^) := fVar^.Cv_UInt16;
          end;
        CSV_UInt32, CSV_SInt32: begin
            Result := Result + #0#0#0#0;
            Longint((@Result[1])^) := fVar^.Cv_SInt32;
          end;
        CSV_String: begin
            Result := #0#0#0#0;
            if fVar^.VType^.Ext = nil then begin
              if fVar^.Cv_Str <> '' then
                Pointer((@Result[1])^) := Pointer(fVar^.Cv_Str);
            end else begin
              if fVar^.Cv_Str <> '' then
                Pointer((@Result[1])^) := Pchar(fVar^.Cv_Str);
            end;
          end;
      end;
    end;
  end;

begin
  InnerfuseCall2 := False;
  if Address = nil then
    exit; // need address
  Stack := '';
  case CallingConv of
    ccRegister: begin
        EAX := 0;
        EDX := 0;
        ECX := 0;
        RegUsage := 0;
        if assigned(Self) then begin
          RegUsage := 1;
          EAX := Longint(Self);
        end;
        for I := 0 to VM_Count(Params) - 1 do begin
          Temp := GetPtr(Vm_Get(Params, I), b);
          if Temp = '' then exit;
          if b and (RegUsage < 3) then begin
            case RegUsage of
              0: begin
                  EAX := Longint((@Temp[1])^);
                  Inc(RegUsage);
                end;
              1: begin
                  EDX := Longint((@Temp[1])^);
                  Inc(RegUsage);
                end;
              2: begin
                  ECX := Longint((@Temp[1])^);
                  Inc(RegUsage);
                end;
            end;
          end else begin
            Stack := Stack + Temp;
          end;
        end;
        if assigned(res) then begin
          case res^.VType^.atypeid of
            CSV_String: begin
                if Longint(res^.VType^.Ext) = 0 then begin
                  case RegUsage of
                    0: begin
                        EAX := Longint(@res^.Cv_Str);
                      end;
                    1: begin
                        EDX := Longint(@res^.Cv_Str);
                      end;
                    2: begin
                        ECX := Longint(@res^.Cv_Str);
                      end;
                  else begin
                      Stack := Stack + #0#0#0#0;
                      Longint((@Stack[Length(Stack) - 3])^) := Longint(@res^.Cv_Str);
                    end;
                  end;
                end;
              end;
          end;
          case res^.VType^.atypeid of
            CSV_Single: begin
                res^.CV_Single := RealFloatCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Double: begin
                res^.CV_Double := RealFloatCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Extended: begin
                res^.Cv_Extended := RealFloatCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4);
              end;

            CSV_Bool, CSV_Char, CSV_UByte, CSV_SByte: begin
                res^.Cv_UByte := RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 1);
              end;
            CSV_UInt16, CSV_SInt16: begin
                res^.Cv_UInt16 := RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 2);
              end;
            CSV_UInt32, CSV_SInt32: begin
                res^.Cv_SInt32 := RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 4);
              end;
{$IFNDEF NOCLASSES}
            CSV_ExternalObject: begin
                if ExtObjSupport = nil then exit;
                ExtObjSupport^.ResultToStr(ExtObjSupport^.Ptr, res, Pointer(RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 4)), SE);
              end;
{$ENDIF}
            CSV_String: if Longint(res^.VType^.Ext) = 1 then begin
                res^.Cv_Str := Pchar(RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 0));
              end else RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 0);
          else
            exit;
          end;
        end else begin
          RealCall_Register(Address, EAX, EDX, ECX, @Stack[1], Length(Stack) div 4, 0);
        end;
        Result := True;
      end;

    ccPascal: begin
        for I := 0 to VM_Count(Params) - 1 do begin
          Temp := GetPtr(Vm_Get(Params, I), b);
          if Temp = '' then exit;
          Stack := Stack + Temp;
        end;
        if assigned(res) then begin
          case res^.VType^.atypeid of
            CSV_String: begin
                if Longint(res^.VType^.Ext) = 0 then begin
                  Stack := Stack + #0#0#0#0;
                  Longint((@Stack[Length(Stack) - 3])^) := Longint(@res^.Cv_Str);
                end;
              end;
          end;
        end;
        if assigned(Self) then begin
          Stack := Stack + #0#0#0#0;
          Pointer((@Stack[Length(Stack) - 3])^) := Self;
        end;
        if assigned(res) then begin
          case res^.VType^.atypeid of
{$IFNDEF NOCLASSES}
            CSV_ExternalObject: begin
                if ExtObjSupport = nil then exit;
                ExtObjSupport^.ResultToStr(ExtObjSupport^.Ptr, res, Pointer(RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 4)), SE);
              end;
{$ENDIF}
            CSV_Single: begin
                res^.CV_Single := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Double: begin
                res^.CV_Double := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Extended: begin
                res^.Cv_Extended := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Bool, CSV_Char, CSV_UByte, CSV_SByte: begin
                res^.Cv_UByte := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 1);
              end;
            CSV_UInt16, CSV_SInt16: begin
                res^.Cv_UInt16 := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 2);
              end;
            CSV_UInt32, CSV_SInt32: begin
                res^.Cv_SInt32 := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 4);
              end;
            CSV_String: if Longint(res^.VType^.Ext) = 1 then begin
                res^.Cv_Str := Pchar(RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0));
              end else RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0);
          else
            exit;
          end;
        end else begin
          RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0);
        end;
        Result := True;
      end;

    CCCdecl: begin
        if assigned(Self) then begin
          Stack := Stack + #0#0#0#0;
          Pointer((@Stack[Length(Stack) - 3])^) := Self;
        end;
        for I := VM_Count(Params) - 1 downto 0 do begin
          Temp := GetPtr(Vm_Get(Params, I), b);
          if Temp = '' then exit;
          Stack := Stack + Temp;
        end;
        if assigned(res) then begin
          case res^.VType^.atypeid of
            CSV_String: begin
                if Longint(res^.VType^.Ext) = 0 then begin
                  Stack := Stack + #0#0#0#0;
                  Longint((@Stack[Length(Stack) - 3])^) := Longint(@res^.Cv_Str);
                  RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 0);
                end else begin
                  res^.Cv_Str := Pchar(RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 0));
                end;
              end;
{$IFNDEF NOCLASSES}
            CSV_ExternalObject: begin
                if ExtObjSupport = nil then exit;
                ExtObjSupport^.ResultToStr(ExtObjSupport^.Ptr, res, Pointer(RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 4)), SE);
              end;
{$ENDIF}
            CSV_Single: begin
                res^.CV_Single := RealFloatCall_CDecl(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Double: begin
                res^.CV_Double := RealFloatCall_CDecl(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Extended: begin
                res^.Cv_Extended := RealFloatCall_CDecl(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Bool, CSV_Char, CSV_UByte, CSV_SByte: begin
                res^.Cv_UByte := RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 1);
              end;
            CSV_UInt16, CSV_SInt16: begin
                res^.Cv_UInt16 := RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 2);
              end;
            CSV_UInt32, CSV_SInt32: begin
                res^.Cv_SInt32 := RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 4);
              end;
          else
            exit;
          end;
        end else begin
          RealCall_CDecl(Address, @Stack[1], Length(Stack) div 4, 0);
        end;
        Result := True;
      end;
    CCStdCall: begin
        if assigned(Self) then begin
          Stack := Stack + #0#0#0#0;
          Pointer((@Stack[Length(Stack) - 3])^) := Self;
        end;
        for I := VM_Count(Params) - 1 downto 0 do begin
          Temp := GetPtr(Vm_Get(Params, I), b);
          if Temp = '' then exit;
          Stack := Stack + Temp;
        end;
        if assigned(res) then begin
          case res^.VType^.atypeid of
            CSV_String: begin
                if Longint(res^.VType^.Ext) = 0 then begin
                  Stack := Stack + #0#0#0#0;
                  Longint((@Stack[Length(Stack) - 3])^) := Longint(@res^.Cv_Str);
                  RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0);
                end else res^.Cv_Str := Pchar(RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0));
              end;
{$IFNDEF NOCLASSES}
            CSV_ExternalObject: begin
                if ExtObjSupport = nil then exit;
                ExtObjSupport^.ResultToStr(ExtObjSupport^.Ptr, res, Pointer(RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 4)), SE);
              end;
{$ENDIF}
            CSV_Single: begin
                res^.CV_Single := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Double: begin
                res^.CV_Double := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Extended: begin
                res^.Cv_Extended := RealFloatCall_Other(Address, @Stack[1], Length(Stack) div 4);
              end;
            CSV_Bool, CSV_Char, CSV_UByte, CSV_SByte: begin
                res^.Cv_UByte := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 1);
              end;
            CSV_UInt16, CSV_SInt16: begin
                res^.Cv_UInt16 := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 2);
              end;
            CSV_UInt32, CSV_SInt32: begin
                res^.Cv_SInt32 := RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 4);
              end;
          else
            exit;
          end;
        end else begin
          RealCall_Other(Address, @Stack[1], Length(Stack) div 4, 0);
        end;
        Result := True;
      end;
  end;
end;

end.

