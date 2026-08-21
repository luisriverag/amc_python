unit ifpsclass;
{
  Innerfuse Pascal Script Class unit

  You may not copy a part of this unit, only use it as whole, with
  Innerfuse Pascal Script Script Engine.

}
{$I ifs_def.inc}
interface
uses
  ifpscall, ifspas, ifs_utl, ifs_var, ifs_obj, typinfo, SysUtils;

type
  TPropertyReadProc = function(Caller: TIfPasScript; Obj: TObject; dest:
    PIfVariant): Boolean;
  TPropertyWriteProc = function(Caller: TIfPasScript; Obj: TObject; Src:
    PIfVariant): Boolean;
  TIFPSClasses = class;
  TIFPSClassWrapper = class
  private
    FInheritsFrom: TIFPSClassWrapper;
    FCl: TClass;
    FEndOfVMT: Longint;
    FClasses: TIFPSClasses;
    FConstructors, FPropHelpers, FProps, FFuncs: TIfStringList;
    FClassName: string;
    FClassNameHash: Cardinal;
  public
    constructor Create(Classes: TIFPSClasses; Cl: TClass; InheritsFrom:
      TIFPSClassWrapper);
    destructor Destroy; override;

    property Classes: TIFPSClasses read FClasses;
    property TheClass: TClass read FCl;
    function AddFunction(Ptr: Pointer; const Decl: string): Boolean;
    function AddProperty(const Name, FType: string): Boolean;
    function AddPropertyHelper(const Name, FType: string; read:
      TPropertyReadProc; write: TPropertyWriteProc): Boolean;

    property TheClassName: string read FClassName;
    property ClassNameHash: Cardinal read FClassNameHash;
  end;

  TIFPSClasses = class
  private
    FClasses: TIfList;
    FTypes: PTypeManager;
    function ReadType(Parser: TIfPascalParser; const Name: string): PTypeRec;
  public
    constructor Create;
    destructor Destroy; override;
    function FindClass(const Name: string): TIFPSClassWrapper;
    function AddClass(FClass: TClass; InheritsFrom: TIFPSClassWrapper):
      TIFPSClassWrapper;
    function AddType(const Name, Decl: string): Boolean;
  end;

procedure RegisterEClasses(ScriptEngine: TIfPasScript; FCl: TIFPSClasses);
function AddClassToScriptEngine(ScriptEngine: TIfPasScript; FClass: TObject;
  const ClassName, VarName: string): Boolean;

function PProcedureToMethod(p: PProcedure): TMethod;
// This function makes a TMethod of a TProcedure.

implementation
type
  PPointer = ^Pointer;

function MyAllMethodsHandler2(Self: PProcedure; const Stack: PPointer; _EDX, _ECX:
  Pointer): Integer; forward;

procedure MyAllMethodsHandler;
//  On entry:
//     EAX = Self pointer
//     EDX, ECX = param1 and param2
//     STACK = param3... paramcount
asm
  push ecx
  push edx
  mov edx, esp
  add edx, 12
  pop ecx
  call MyAllMethodsHandler2
  mov edx, [esp]
  add esp, eax
  mov [esp], edx
end;

function MyAllMethodsHandler2(Self: PProcedure; const Stack: PPointer; _EDX, _ECX:
  Pointer): Integer;
var
  I, C, regno: Integer;
  Params: PVariableManager;
  VarParams: PVariableManager;
  Tmp: PIfVariant;
  cpt: PTypeRec;
  fmod: char;
  s: string;
  FStack: pointer;
begin
  FStack := Stack;
  Params := VM_Create;
  VarParams := VM_Create;
  C := IntProcDefParam(Self.Decl, -1);
  for I := C - 1 downto 0 do
    Vm_Add(Params, nil, '');
  regno := 0;
  I := 0;
  Result := 0;
  while I < C do
  begin
    s := IntProcDefName(Self.Decl, I + 1);
    if s = '' then
      fmod := #0
    else
      fmod := s[1];
    cpt := PTypeRec(IntProcDefParam(Self.Decl, I + 1));
    if fmod = '!' then
    begin
      case cpt.atypeid of
        CSV_ExternalObject:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.CV_ExternalObject := Pointer(Pointer(_EDX)^);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.CV_ExternalObject := Pointer(Pointer(_ECX)^);
            end;
            VM_Add(VarParams, Tmp, '');
            VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
          end;
        CSV_String:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.Cv_Str := string(Pointer(_EDX)^);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.Cv_Str := string(Pointer(_ECX)^);
            end;
            VM_Add(VarParams, Tmp, '');
            VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
          end;
        CSV_Real, CSV_Double, CSV_Comp:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Move(Pointer(_EDX)^, tmp^.Cv_Double, 8);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Move(Pointer(_ECX)^, tmp^.Cv_Double, 8);
            end;
            VM_Add(VarParams, Tmp, '');
            VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
          end;
        CSV_Extended:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Move(Pointer(_EDX)^, tmp^.Cv_Extended, 10);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Move(Pointer(_ECX)^, tmp^.Cv_Extended, 10);
            end;
            VM_Add(VarParams, Tmp, '');
            VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
          end;
        CSV_Single,
          CSV_Enum,
          CSV_Bool,
          CSV_UByte,
          CSV_SByte,
          CSV_Char,
          CSV_UInt16,
          CSV_SInt16,
          CSV_UInt32,
          CSV_SInt32:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.CV_SInt32 := Longint(Pointer(_EDX)^);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.CV_SInt32 := Longint(Pointer(_ECX)^);
            end;
            VM_Add(VarParams, Tmp, '');
            VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
          end;
      else
        begin
          VM_Destroy(Params);
          VM_Destroy(VarParams);
          exit;
        end;
      end;
    end
    else
    begin
      case cpt.atypeid of
        CSV_ExternalObject:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.CV_ExternalObject := _EDX;
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.CV_ExternalObject := _ECX;
            end;
            VM_Set(Params, I, Tmp);
          end;
        CSV_String:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.Cv_Str := string(_EDX);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.Cv_Str := string(_ECX);
            end;
            VM_Set(Params, I, Tmp);
          end;
        CSV_Enum,
          CSV_Bool,
          CSV_UByte,
          CSV_SByte,
          CSV_Char,
          CSV_UInt16,
          CSV_SInt16,
          CSV_UInt32,
          CSV_SInt32:
          begin
            Tmp := CreateCajVariant(cpt);
            if regno = 0 then
            begin
              Inc(regno);
              Tmp^.Cv_SInt32 := Longint(_EDX);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Tmp^.Cv_SInt32 := Longint(_ECX);
            end;
            VM_Set(Params, I, Tmp);
          end;
      end;
    end;
    inc(i);
    if regno = 2 then
      break;
  end;
  for I := C - 1 downto 0 do
  begin
    if Vm_Get(Params, I) = nil then
    begin
      s := IntProcDefName(Self.Decl, I + 1);
      if s = '' then
        fmod := #0
      else
        fmod := s[1];
      cpt := PTypeRec(IntProcDefParam(Self.Decl, I + 1));
      if fmod = '!' then
      begin
        case cpt.atypeid of
          CSV_ExternalObject:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.CV_ExternalObject := Pointer(Pointer(FStack^)^);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
              VM_Add(VarParams, Tmp, '');
              VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
            end;
          CSV_String:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.Cv_Str := string(FStack^);
              FStack := Pointer(Pointer(Longint(FStack) + 4)^);
              Inc(Result, 4);
              VM_Add(VarParams, Tmp, '');
              VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
            end;
          CSV_Real, CSV_Double, CSV_Comp:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Move(Pointer(FStack^)^, Tmp^.CV_Double, 8);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
              VM_Add(VarParams, Tmp, '');
              VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
            end;
          CSV_Extended:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Move(Pointer(FStack^)^, Tmp^.CV_Double, 10);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
              VM_Add(VarParams, Tmp, '');
              VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
            end;
          CSV_Single,
            CSV_Enum,
            CSV_Bool,
            CSV_UByte,
            CSV_SByte,
            CSV_Char,
            CSV_UInt16,
            CSV_SInt16,
            CSV_UInt32,
            CSV_SInt32:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.Cv_SInt32 := Longint(Pointer(FStack^)^);
              VM_Add(VarParams, Tmp, '');
              VM_Set(Params, I,  TIfPasScript(Self.FScriptEngine).CreateVarType(Tmp));
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
            end;
        else
          begin
            VM_Destroy(Params);
            VM_Destroy(VarParams);
            exit;
          end;
        end;
      end
      else
      begin
        case cpt.atypeid of
          CSV_ExternalObject:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.CV_ExternalObject := Pointer(FStack^);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
              VM_Set(Params, I, Tmp);
            end;
          CSV_String:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.Cv_Str := string(FStack^);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
              VM_Set(Params, I, Tmp);
            end;
          CSV_Real, CSV_Double, CSV_Comp:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Move(FStack^, Tmp^.CV_Double, 8);
              FStack := Pointer(Longint(FStack) + 8);
              Inc(Result, 8);
              VM_Set(Params, I, Tmp);
            end;
          CSV_Extended:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Move(FStack^, Tmp^.CV_Double, 10);
              FStack := Pointer(Longint(FStack) + 12);
              Inc(Result, 12);
              VM_Set(Params, I, Tmp);
            end;
          CSV_Single,
            CSV_Enum,
            CSV_Bool,
            CSV_UByte,
            CSV_SByte,
            CSV_Char,
            CSV_UInt16,
            CSV_SInt16,
            CSV_UInt32,
            CSV_SInt32:
            begin
              Tmp := CreateCajVariant(cpt);
              tmp^.Flags := 2;
              Tmp^.Cv_SInt32 := Longint(FStack^);
              VM_Set(Params, I, Tmp);
              FStack := Pointer(Longint(FStack) + 4);
              Inc(Result, 4);
            end;
        else
          begin
            VM_Destroy(Params);
            VM_Destroy(VarParams);
            exit;
          end;
        end;
      end;
    end;
  end;
  TIfPasScript(Self.FScriptEngine).RunScriptProc(Self, Params);
  FStack := Stack;
  regno := 0;
  I := 0;
  while I < C do
  begin
    s := IntProcDefName(Self.Decl, I + 1);
    if s = '' then
      fmod := #0
    else
      fmod := s[1];
    cpt := PTypeRec(IntProcDefParam(Self.Decl, I + 1));
    if fmod = '!' then
    begin
      case cpt.atypeid of
        CSV_ExternalObject:
          begin
            tmp := GetVarLink(VM_Get(Params, i));
            if regno = 0 then
            begin
              Inc(regno);
              Pointer(Pointer(_EDX)^) := Tmp^.CV_ExternalObject;
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Pointer(Pointer(_ECX)^) := Tmp^.CV_ExternalObject;
            end;
          end;
        CSV_String:
          begin
            tmp := GetVarLink(VM_Get(Params, i));
            if regno = 0 then
            begin
              Inc(regno);
              string(Pointer(_EDX)^) := Tmp^.Cv_Str;
            end
            else if regno = 1 then
            begin
              Inc(regno);
              string(Pointer(_ECX)^) := Tmp^.Cv_Str;
            end;
          end;
        CSV_Real, CSV_Double, CSV_Comp:
          begin
            tmp := GetVarLink(VM_Get(Params, i));
            if regno = 0 then
            begin
              Inc(regno);
              Move(tmp^.Cv_Double, Pointer(_EDX)^, 8);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Move(tmp^.Cv_Double, Pointer(_ECX)^, 8);
            end;
          end;
        CSV_Extended:
          begin
            tmp := GetVarLink(VM_Get(Params, i));
            if regno = 0 then
            begin
              Inc(regno);
              Move(tmp^.Cv_Extended, Pointer(_EDX)^, 10);
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Move(tmp^.Cv_Extended, Pointer(_ECX)^, 10);
            end;
          end;
        CSV_Single,
          CSV_Enum,
          CSV_Bool,
          CSV_UByte,
          CSV_SByte,
          CSV_Char,
          CSV_UInt16,
          CSV_SInt16,
          CSV_UInt32,
          CSV_SInt32:
          begin
            tmp := GetVarLink(VM_Get(Params, i));
            if regno = 0 then
            begin
              Inc(regno);
              Longint(Pointer(_EDX)^) := Tmp^.CV_SInt32;
            end
            else if regno = 1 then
            begin
              Inc(regno);
              Longint(Pointer(_ECX)^) := Tmp^.CV_SInt32;
            end;
          end;
      else
        begin
          VM_Destroy(Params);
          VM_Destroy(VarParams);
          exit;
        end;
      end;
    end else begin
      case cpt.atypeid of
        CSV_ExternalObject,
          CSV_String,
          CSV_Enum,
          CSV_Bool,
          CSV_UByte,
          CSV_SByte,
          CSV_Char,
          CSV_UInt16,
          CSV_SInt16,
          CSV_UInt32,
          CSV_SInt32:
          begin
            Inc(regno);
          end;
      end;
    end;
    inc(i);
  end;
  for I := C - 1 downto 0 do
  begin
    tmp := GetVarLink(VM_Get(Params, i));
    if tmp^.Flags = 2 then // 2 = stack parameter
    begin
      s := IntProcDefName(Self.Decl, I + 1);
      if s = '' then
        fmod := #0
      else
        fmod := s[1];
      cpt := PTypeRec(IntProcDefParam(Self.Decl, I + 1));
      if fmod = '!' then
      begin
        case cpt.atypeid of
          CSV_ExternalObject:
            begin
              Pointer(Pointer(FStack^)^) := Tmp^.CV_ExternalObject;
              FStack := Pointer(Longint(FStack) + 4);
            end;
          CSV_String:
            begin
              string(FStack^) := Tmp^.Cv_Str;
              FStack := Pointer(Pointer(Longint(FStack) + 4)^);
            end;
          CSV_Real, CSV_Double, CSV_Comp:
            begin
              Move(Tmp^.CV_Double, Pointer(FStack^)^, 8);
              FStack := Pointer(Longint(FStack) + 4);
            end;
          CSV_Extended:
            begin
              Move(Tmp^.CV_Double, Pointer(FStack^)^, 10);
              FStack := Pointer(Longint(FStack) + 4);
            end;
          CSV_Single,
            CSV_Enum,
            CSV_Bool,
            CSV_UByte,
            CSV_SByte,
            CSV_Char,
            CSV_UInt16,
            CSV_SInt16,
            CSV_UInt32,
            CSV_SInt32:
            begin
              Longint(Pointer(FStack^)^) := Tmp^.Cv_SInt32;
              VM_Set(Params, I, Tmp);
            end;
        else
          begin
            VM_Destroy(Params);
            VM_Destroy(VarParams);
            exit;
          end;
        end;
      end;
    end;
  end;
  VM_Destroy(Params);
  VM_Destroy(VarParams);
end;

function PProcedureToMethod(p: PProcedure): TMethod;
begin
  if p <> nil then
  begin
    Result.Code := @MyAllMethodsHandler;
    Result.Data := p;
  end
  else
  begin
    Result.Code := nil;
    Result.Data := nil;
  end;
end;

type
  TIfsExternalClassWrapper = class(TIfsExtClass)
  private
    ScriptType: PTypeRec;
    fs: TIFPSClassWrapper;
    FPropHelpers, FProps, FConstructors, FFuncs: TIfStringList;
  public
    constructor Create(ScriptEngine: Pointer; s: TIFPSClassWrapper);
    destructor Destroy; override;

    procedure InitClasses;

    function GetPropertyType(FSelf: PIFSExternalObject; I: Longint): PTypeRec;
      override;
    function SetProperty(FSelf: PIFSExternalObject; I: Longint; p: PIfVariant):
      Boolean; override;
    function GetProperty(FSelf: PIFSExternalObject; I: Longint; dest:
      PIfVariant): Boolean; override;
    function FindProperty(FSelf: PIFSExternalObject; const Name: string):
      Longint; override;

    function FindProc(FSelf: PIFSExternalObject; const Name: string): Longint;
      override;
    function GetProcHeader(FSelf: PIFSExternalObject; I: Longint): string;
      override;
    function CallProc(FSelf: PIFSExternalObject; I: Longint; Params:
      PVariableManager): PIfVariant; override;

    function FindClassProc(const Name: string): Longint; override;
    function GetClassProcHeader(I: Longint): string; override;
    function CallClassProc(I: Longint; Params: PVariableManager): PIfVariant;
      override;
    function IsCompatibleWith(x: PTypeRec): Boolean; override;
  end;

function ClassObjToStr(Ptr: Pointer; v: PIfVariant; SE: TIfPasScript): string;
begin
  Result := #0#0#0#0;
  if (v^.CV_ExternalObject <> nil) then
  begin
    Pointer((@Result[1])^) := v^.CV_ExternalObject;
  end;
end;

function ClassVarObjToStr(Ptr: Pointer; v: PIfVariant; SE: TIfPasScript):
  string;
begin
  if (v^.CV_ExternalObject <> nil) then
  begin
    Pointer((@Result[1])^) := @(v^.CV_ExternalObject);
  end
  else
    Result := '';
end;

procedure CreateClassInstance(SE: TIfPasScript; fVar: PIfVariant; C: Pointer);
begin
  fVar^.CV_ExternalObject := C;
end;

procedure ClassResultToObj(Ptr: Pointer; res: PIfVariant; v: Pointer; SE:
  TIfPasScript);
begin
  if v = nil then
  begin
    res^.CV_ExternalObject := nil;
  end
  else
  begin
    CreateClassInstance(SE, res, v);
  end;
end;

const
  DefExtObjSupport: TExternalObjectSupport = (
    Ptr: nil;
    ObjToStr: ClassObjToStr;
    VarObjToStr: ClassVarObjToStr;
    ResultToStr: ClassResultToObj);

  { TIFPSClassWrapper }

  {
  mi2s(funcnamehash)+mystring(funcname)+chr(IsVirtual)+mi2s(pointer)+chr(callingconvention)+mi2s(funcRes)+params

  Param:
    chr(modifier)+mystring(name)+mi2s(type)

    modifier: #0 = no; #1 = Varparam;

  Properties:
  mi2s(NameHash)+mi2s(LengthOfName)+name+mi2s(FType)+mi2s(PropInfo)+chr(ord(TTypeKind))

  Propertyhelper:
  mi2s(NameHash)+mi2s(LengthOfName)+name+mi2s(FType)+mi2s(Longint(Readproc))+mi2s(Longint(WriteProc))

  }

type
  TPtrArr = array[0..1000] of Pointer;
  PPtrArr = ^TPtrArr;

function FindVirtualMethodPtr(Ret: TIFPSClassWrapper; FClass: TClass; Ptr:
  Pointer): Pointer;
// Idea of getting the number of VMT items from GExperts
var
  p: PPtrArr;
  I: Longint;
begin
  p := Pointer(FClass);
  if Ret.FEndOfVMT = MaxInt then
  begin
    I := vmtSelfPtr div SizeOf(Pointer) + 1;
    while I < 0 do
    begin
      if I < 0 then
      begin
        if I <> (vmtTypeInfo div SizeOf(Pointer)) then
        begin // from GExperts code
          if (Longint(p^[I]) > Longint(p)) and ((Longint(p^[I]) - Longint(p))
            div
            4 < Ret.FEndOfVMT) then
          begin
            Ret.FEndOfVMT := (Longint(p^[I]) - Longint(p)) div SizeOf(Pointer);
          end;
        end;
      end;
      Inc(I);
    end;
    if Ret.FEndOfVMT = MaxInt then
    begin
      Ret.FEndOfVMT := 0; // cound not find EndOfVMT
      Result := nil;
      exit;
    end;
  end;
  I := 0;
  while I < Ret.FEndOfVMT do
  begin
    if p^[I] = Ptr then
    begin
      Result := Pointer(I);
      exit;
    end;
    I := I + 1;
  end;
  Result := nil;
end;

function TIFPSClassWrapper.AddFunction(Ptr: Pointer; const Decl: string):
  Boolean;
var
  Parser: TIfPascalParser;
  ProcType: Byte;
  FuncParam, FuncName, n, CurrVar: string;
  FuncRes,
    CurrType: Longint;
  E: TIFPARSERERROR;
  CC: TCallingConvention;
  FVirtual: Boolean;

  function GetType(const s: string): Longint;
  var
    I: Longint;
    h: Cardinal;
  begin
    h := mkhash(s);
    for I := 0 to FClasses.FTypes^.List.Count - 1 do
    begin
      with PTypeRec(FClasses.FTypes^.List.GetItem(I))^ do
      begin
        if (identhash = h) and (s = Ident) then
        begin
          Result := Longint(FClasses.FTypes^.List.GetItem(I));
          exit;
        end;
      end;
    end;
    Result := 0;
  end;
begin
  Parser := TIfPascalParser.Create;
  AddFunction := False;
  if not Parser.SetText(Decl, E) then
  begin
    Parser.Free;
    exit;
  end;
  if Parser.CurrTokenId = CSTII_Procedure then
    ProcType := 0
  else if Parser.CurrTokenId = CSTII_Function then
    ProcType := 1
  else if Parser.CurrTokenId = CSTII_Constructor then
    ProcType := 2
  else
  begin
    Parser.Free;
    exit;
  end;
  Parser.Next;
  FuncName := Parser.GetToken;
  FuncName := mi2s(mkhash(FuncName)) + mi2s(Length(FuncName)) + FuncName;
  Parser.Next;
  CurrVar := '';
  if Parser.CurrTokenId = CSTI_OpenRound then
  begin
    Parser.Next;
    while True do
    begin
      if Parser.CurrTokenId = CSTI_EOF then
      begin
        Parser.Free;
        exit;
      end;
      if Parser.CurrTokenId = CSTII_Var then
      begin
        CurrVar := '!';
        Parser.Next;
      end; {if}
      while True do
      begin
        if Parser.CurrTokenId = CSTI_EOF then
        begin
          Parser.Free;
          exit;
        end;
        if Parser.CurrTokenId <> CSTI_Identifier then
        begin
          Parser.Free;
          exit;
        end;
        CurrVar := CurrVar + Parser.GetToken + '|';
        Parser.Next;
        if Parser.CurrTokenId = CSTI_Colon then
          break;
        if Parser.CurrTokenId <> CSTI_Comma then
        begin
          Parser.Free;
          exit;
        end;
        Parser.Next;
      end; {while}
      Parser.Next;
      CurrType := GetType(Parser.GetToken);
      if CurrType = -1 then
      begin
        Parser.Free;
        exit;
      end;
      if Pos('!', CurrVar) = 1 then
      begin
        Delete(CurrVar, 1, 1);
        while Pos('|', CurrVar) > 0 do
        begin
          n := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #1 + mi2s(Length(n)) + n + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end
      else
      begin
        while Pos('|', CurrVar) > 0 do
        begin
          FuncParam := FuncParam + #0 + mi2s(Length(n)) + n + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end; {if}
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then
      begin
        Parser.Next;
        break;
      end; {if}
      Parser.Next;
    end;
  end;
  if ProcType = 1 then
  begin
    Parser.Next;
    FuncRes := GetType(Parser.GetToken);
    if FuncRes = -1 then
    begin
      Parser.Free;
      exit;
    end;
    Parser.Next;
  end
  else
    FuncRes := 0;
  CC := ccRegister;
  FVirtual := False;
  if Parser.CurrTokenId = CSTI_Semicolon then
  begin
    Parser.Next;
    if Parser.CurrTokenId = CSTII_Virtual then
    begin
      Parser.Next;
      FVirtual := True;
      if Parser.CurrTokenId = CSTI_Semicolon then
      begin
        Parser.Next;
        if Parser.CurrTokenId = CSTI_Identifier then
        begin
          if Parser.GetToken = 'STDCALL' then
            CC := CCStdCall
          else if Parser.GetToken = 'CDECL' then
            CC := CCCdecl
          else if Parser.GetToken = 'PASCAL' then
            CC := ccPascal
          else if Parser.GetToken = 'REGISTER' then
            CC := ccRegister
          else
            CC := ccRegister;
        end;
      end;
    end
    else if Parser.CurrTokenId = CSTI_Identifier then
    begin
      if Parser.GetToken = 'STDCALL' then
        CC := CCStdCall
      else if Parser.GetToken = 'CDECL' then
        CC := CCCdecl
      else if Parser.GetToken = 'PASCAL' then
        CC := ccPascal
      else if Parser.GetToken = 'REGISTER' then
        CC := ccRegister
      else
        CC := ccRegister;
      // Register is default.
    end;
  end;
  if FVirtual then
  begin
    Ptr := FindVirtualMethodPtr(Self, FCl, Ptr);
    if Ptr = nil then
    begin
      Parser.Free;
      exit;
    end;
  end;
  FuncParam := FuncName + Chr(Ord(FVirtual)) + mi2s(Longint(Ptr)) + Chr(Ord(CC))
    + mi2s(FuncRes) + FuncParam;
  if ProcType = 2 then
    FConstructors.Add(FuncParam)
  else
    FFuncs.Add(FuncParam);
  AddFunction := True;
  Parser.Free;
end;

function getsgproc(n: PTypeRec): Byte;
begin
  case n^.atypeid of
    CSV_UByte,
      CSV_SByte,
      CSV_Bool,
      CSV_Char: Result := 0;
    CSV_UInt16,
      CSV_SInt16: Result := 1;
    CSV_UInt32,
      CSV_Enum,
      CSV_SInt32: Result := 2;
    CSV_String: Result := 3;
    CSV_Real,
      CSV_Single,
      CSV_Double,
      CSV_Extended,
      CSV_Comp: Result := 4;
    CSV_ExternalObject: Result := 5;
    CSV_ProcVariable: Result := 6;
  else
    Result := 255;
  end;
end;

function TIFPSClassWrapper.AddPropertyHelper(const Name, FType: string; read:
  TPropertyReadProc; write: TPropertyWriteProc): Boolean;
var
  p: PTypeRec;
  na: string;
begin
  p := TM_Get(FClasses.FTypes, FastUppercase(FType));
  if (p = nil) then
  begin
    Result := False;
    exit;
  end;
  na := FastUppercase(Name);
  FPropHelpers.Add(mi2s(mkhash(na)) + mi2s(Length(na)) + na + mi2s(Longint(p)) +
    mi2s(Longint(@read)) + mi2s(Longint(@write)));
  Result := True;
end;

function TIFPSClassWrapper.AddProperty(const Name, FType: string): Boolean;
var
  n: PPropInfo;
  p: PTypeRec;
  na: string;
  SetGetProc: Byte;
begin
  p := TM_Get(FClasses.FTypes, FastUppercase(FType));
  n := GetPropInfo(FCl.ClassInfo, Name);
  if (p = nil) or (n = nil) then
  begin
    Result := False;
    exit;
  end;
  SetGetProc := getsgproc(p);
  if SetGetProc = 255 then
  begin
    Result := False;
    exit;
  end;
  na := FastUppercase(Name);
  FProps.Add(mi2s(mkhash(na)) + mi2s(Length(na)) + na + mi2s(Longint(p)) +
    mi2s(Longint(n)) + Chr(SetGetProc));
  Result := True;
end;

constructor TIFPSClassWrapper.Create(Classes: TIFPSClasses; Cl: TClass;
  InheritsFrom: TIFPSClassWrapper);
begin
  inherited Create;

  FEndOfVMT := MaxInt;
  FClasses := Classes;
  FCl := Cl;
  FInheritsFrom := InheritsFrom;
  if FCl = TObject then
    FClassName := 'DELPHITOBJECT'
  else
    FClassName := FastUppercase(FCl.ClassName);
  FClassNameHash := mkhash(FClassName);
  FClasses.FClasses.Add(Self);
  FFuncs := TIfStringList.Create;
  FConstructors := TIfStringList.Create;
  FProps := TIfStringList.Create;
  FPropHelpers := TIfStringList.Create;
end;

destructor TIFPSClassWrapper.Destroy;
begin
  FClasses.FClasses.Remove(Self);
  FConstructors.Free;
  FFuncs.Free;
  FProps.Free;
  FPropHelpers.Free;
  inherited Destroy;
end;

{ TIFPSClasses }

function TIFPSClasses.AddClass(FClass: TClass; InheritsFrom: TIFPSClassWrapper):
  TIFPSClassWrapper;
begin
  Result := TIFPSClassWrapper.Create(Self, FClass, InheritsFrom);
  TM_Add(FTypes, Result.FClassName, CSV_ExternalObject, Result);
end;

function TIFPSClasses.ReadType(Parser: TIfPascalParser; const Name: string):
  PTypeRec;
var
  Ex: Pointer;

  function ReadRecord: PTypeRec;
  var
    Exu: PIFSRecordType;
    s, CurrNames: string;

    function IsDuplicate(p: string): Boolean;
    begin
      IsDuplicate := False;
      if (Pos(p + ' ', s) = 1) or (Pos(' ' + p + ' ', s) <> 0) then
        IsDuplicate := True;
      if (Pos(p + ' ', CurrNames) = 1) or (Pos(' ' + p + ' ', CurrNames) <> 0)
        then
        IsDuplicate := True;
    end;
  begin
    Parser.Next;
    s := '';
    while Parser.CurrTokenId <> CSTII_End do
    begin
      CurrNames := '';
      repeat
        if Parser.CurrTokenId <> CSTI_Identifier then
        begin
          ReadRecord := nil;
          exit;
        end;
        if IsDuplicate(Parser.GetToken) then
        begin
          ReadRecord := nil;
          exit;
        end
        else
          CurrNames := CurrNames + Parser.GetToken + ' ';
        Parser.Next;
        if (Parser.CurrTokenId = CSTI_Comma) then
        begin
          Parser.Next;
        end
        else if (Parser.CurrTokenId = CSTI_Colon) then
        begin
          break;
        end
        else
        begin
          ReadRecord := nil;
          exit;
        end;
      until False;
      Parser.Next;
      Ex := ReadType(Parser, '');
      if Ex = nil then
      begin
        ReadRecord := nil;
        exit;
      end;
      if (Parser.CurrTokenId <> CSTI_Semicolon) and (Parser.CurrTokenId <>
        CSTII_End) then
      begin
        ReadRecord := nil;
        exit;
      end;
      while Length(CurrNames) > 0 do
      begin
        s := s + copy(CurrNames, 1, Pos(' ', CurrNames) - 1) + ' ' +
          inttostr(Longint(Ex)) + ' ';
        Delete(CurrNames, 1, Pos(' ', CurrNames));
      end;
      if Parser.CurrTokenId = CSTI_Semicolon then
        Parser.Next;
    end;
    Parser.Next;
    New(Exu);
    Exu^.u := s;
    ReadRecord := TM_Add(FTypes, Name, CSV_Record, Exu);
  end; // readclass

  function ReadProcedure: PTypeRec;
  var
    Func: Boolean;
    Data: PIFSProcType;
    vn: string;
    iv: Byte;
    t: PTypeRec;

    function PCheckDuplic(const n: string): Boolean;
    var
      u, a: string;
    begin
      PCheckDuplic := False;
      u := Data^.Decl;
      rs(u);
      while Length(u) > 0 do
      begin
        a := Fw(u);
        Rfw(u); {remove name}
        Rfw(u); {remove type}
        if Pos('!', a) = 1 then
          Delete(a, 1, 1);
        if a = n then
        begin
          PCheckDuplic := True;
          exit;
        end;
      end;
      u := vn;
      while Length(u) > 0 do
      begin
        a := Fw(u);
        Rfw(u); {remove name}
        if a = n then
        begin
          PCheckDuplic := True;
          exit;
        end;
      end;
    end;
  begin
    ReadProcedure := nil;
    Func := Parser.CurrTokenId = CSTII_Function;
    Parser.Next;
    New(Data);
    Data^.Decl := '';
    Data^.Method := False;
    if Parser.CurrTokenId = CSTI_OpenRound then
    begin
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then
      begin
        Parser.Next;
      end
      else
      begin
        repeat
          if Parser.CurrTokenId = CSTII_Var then
          begin
            Parser.Next;
            iv := 1; {var}
          end
          else
            iv := 0; {normal}
          if Parser.CurrTokenId <> CSTI_Identifier then
          begin
            Dispose(Data);
            exit;
          end; {if}
          vn := '';
          if PCheckDuplic(Parser.GetToken) then
          begin
            Dispose(Data);
            exit;
          end;
          vn := Parser.GetToken;
          Parser.Next;
          while Parser.CurrTokenId = CSTI_Comma do
          begin
            Parser.Next;
            if Parser.CurrTokenId <> CSTI_Identifier then
            begin
              Dispose(Data);
              exit;
            end; {if}
            if PCheckDuplic(Parser.GetToken) then
            begin
              Dispose(Data);
              exit;
            end; {if}
            vn := vn + ' ' + Parser.GetToken;
            Parser.Next;
          end; {while}
          if Parser.CurrTokenId <> CSTI_Colon then
          begin
            Dispose(Data);
            exit;
          end;
          Parser.Next;
          t := GetTypeLink(TM_Get(FTypes, Parser.GetToken));
          if t = nil then
          begin
            Dispose(Data);
            exit;
          end;
          if iv = 0 then
          begin
            while Length(vn) > 0 do
            begin
              Data^.Decl := Data^.Decl + #0 + mi2s(Length(Fw(vn))) + Fw(vn) +
                mi2s(Longint(t));
              Rfw(vn);
            end;
          end
          else if iv = 1 then
          begin
            while Length(vn) > 0 do
            begin
              Data^.Decl := Data^.Decl + #1 + mi2s(Length(Fw(vn))) + Fw(vn) +
                mi2s(Longint(t));
              Rfw(vn);
            end;
          end;
          Parser.Next;
          if Parser.CurrTokenId = CSTI_Semicolon then
          begin
            Parser.Next;
          end
          else if (Parser.CurrTokenId <> CSTI_CloseRound) then
          begin
            Dispose(Data);
            exit;
          end
          else
            break;
        until False;
        Parser.Next;
      end;
    end;
    if Func then
    begin
      if Parser.CurrTokenId <> CSTI_Colon then
      begin
        Dispose(Data);
        exit;
      end;
      Parser.Next;
      t := GetTypeLink(TM_Get(FTypes, Parser.GetToken));
      if t = nil then
      begin
        Dispose(Data);
        exit;
      end;
      Data^.Decl := mi2s(Longint(t)) + Data^.Decl;
      Parser.Next;
    end
    else
      Data^.Decl := mi2s(0) + Data^.Decl;
{$IFNDEF NOCLASSES}
    if Parser.CurrTokenId = CSTII_Of then
    begin
      Parser.Next;
      if Parser.GetToken <> 'OBJECT' then
      begin
        Dispose(Data);
        exit;
      end;
      Parser.Next;
      Data^.Method := True;
    end;
{$ENDIF}
    Result := TM_Add(FTypes, Name, CSV_ProcVariable, Data);
  end; // readprocedure

begin
  if (Parser.CurrTokenId = CSTII_Procedure) or (Parser.CurrTokenId =
    CSTII_Function) then
  begin
    ReadType := ReadProcedure;
  end
  else if Parser.CurrTokenId = CSTII_Record then
  begin
    ReadType := ReadRecord;
  end
  else
  begin
    Ex := GetTypeLink(TM_Get(FTypes, Parser.GetToken));
    Parser.Next;
    if Ex = nil then
    begin
      ReadType := nil;
      exit;
    end;
    if PTypeRec(Ex)^.Ident = '' then
    begin
      PTypeRec(Ex)^.Ident := Name;
      ReadType := Ex;

    end
    else
    begin
      if Name = '' then
        ReadType := Ex
      else
        ReadType := TM_Add(FTypes, Name, CSV_TypeCopy, Ex);
    end;
  end;
end;

function TIFPSClasses.AddType(const Name, Decl: string): Boolean;
var
  Parser: TIfPascalParser;
  ERRREC: TIFPARSERERROR;
begin
  Parser := TIfPascalParser.Create;
  if not Parser.SetText(Decl, ERRREC) then
  begin
    Result := False;
    exit;
  end;
  Result := ReadType(Parser, FastUppercase(Name)) <> nil;
  Parser.Free;
end;

constructor TIFPSClasses.Create;
begin
  inherited Create;
  FClasses := TIfList.Create;
  FTypes := TM_Create;
  TM_Add(FTypes, 'BYTE', CSV_UByte, nil);
  TM_Add(FTypes, 'SHORTINT', CSV_SByte, nil);
  TM_Add(FTypes, 'CHAR', CSV_Char, nil);
  TM_Add(FTypes, 'WORD', CSV_UInt16, nil);
  TM_Add(FTypes, 'SMALLINT', CSV_SInt16, nil);
  TM_Add(FTypes, 'CARDINAL', CSV_UInt32, nil);
  TM_Add(FTypes, 'LONGINT', CSV_SInt32, nil);
  TM_Add(FTypes, 'INTEGER', CSV_SInt32, nil);
  TM_Add(FTypes, 'STRING', CSV_String, nil);
  TM_Add(FTypes, 'REAL', CSV_Real, nil);
  TM_Add(FTypes, 'SINGLE', CSV_Single, nil);
  TM_Add(FTypes, 'DOUBLE', CSV_Double, nil);
  TM_Add(FTypes, 'EXTENDED', CSV_Extended, nil);
  TM_Add(FTypes, 'COMP', CSV_Comp, nil);
  TM_Add(FTypes, 'BOOLEAN', CSV_Bool, nil);
end;

destructor TIFPSClasses.Destroy;
var
  I: Longint;
begin
  for I := FClasses.Count - 1 downto 0 do
  begin
    TIFPSClassWrapper(FClasses.GetItem(I)).Free;
  end;
  FClasses.Free;
  for I := FTypes.List.Count - 1 downto 0 do
  begin
    if PTypeRec(FTypes.List.GetItem(I))^.atypeid = CSV_ExternalObject then
      PTypeRec(FTypes.List.GetItem(I))^.Ext := nil;
  end;
  TM_Destroy(FTypes);
  inherited Destroy;
end;

function TIFPSClasses.FindClass(const Name: string): TIFPSClassWrapper;
var
  I: Longint;
  h: Cardinal;
begin
  h := mkhash(FastUppercase(Name));
  for I := 0 to FClasses.Count - 1 do
  begin
    if (TIFPSClassWrapper(FClasses.GetItem(I)).FClassNameHash = h) and
      (TIFPSClassWrapper(FClasses.GetItem(I)).FClassName = FastUppercase(Name))
        then
    begin
      Result := FClasses.GetItem(I);
      exit;
    end;
  end;
  Result := nil;
end;

{ TIfsExternalClassWrapper }

function VirtualMethodPtrToPtr(Ptr, FClass: Pointer): Pointer;
begin
  Result := PPtrArr(FClass)^[Longint(Ptr)];
end;

function TIfsExternalClassWrapper.CallClassProc(I: Integer;
  Params: PVariableManager): PIfVariant;
var
  C: TCallingConvention;
  FIsVirtual: Boolean;
  Ptr: Pointer;
  s, s2: string;
  slf: PIfVariant;
begin
  s := FConstructors.GetItem(I);
  Result := nil;
  if s = '' then
    exit;
  Delete(s, 1, 4); //deletehash
  s2 := copy(s, 5, ms2i(s));
  Delete(s, 1, Length(s2) + 4);
  if Length(s) < 6 then
  begin
    TIfPasScript(ScriptEngine).RunError(ScriptEngine, ENotSupported);
    exit;
  end;
  FIsVirtual := Boolean(s[1]);
  Delete(s, 1, 1); // skip FVirtual
  Ptr := Pointer(ms2i(s));
  C := TCallingConvention(s[5]);
  Delete(s, 1, 5);
  VM_Insert(Params, 0, TIfPasScript(ScriptEngine).CreateBool(True), 'CStr');
  Result := CreateCajVariant(Pointer(ms2i(s)));
  slf := CreateCajVariant(ScriptType);
  if FIsVirtual then
  begin
    Ptr := VirtualMethodPtrToPtr(Ptr, fs.FCl);
  end;
  if not InnerfuseCall2(ScriptEngine, fs.FCl, Ptr, C, Params, slf,
    @DefExtObjSupport) then
  begin
    TIfPasScript(ScriptEngine).RunError(ScriptEngine, ENotSupported);
    DestroyCajVariant(Result);
    Result := nil;
    exit;
  end;
  Result := slf;
end;

function TIfsExternalClassWrapper.CallProc(FSelf: PIFSExternalObject;
  I: Integer; Params: PVariableManager): PIfVariant;
var
  C: TCallingConvention;
  Ptr: Pointer;
  FIsVirtual: Boolean;
  s, s2: string;
begin
  s := FFuncs.GetItem(I);
  Result := nil;
  if s = '' then
    exit;
  Delete(s, 1, 4); //deletehash
  s2 := copy(s, 5, ms2i(s));
  Delete(s, 1, Length(s2) + 4);
  if Length(s) < 6 then
  begin
    TIfPasScript(ScriptEngine).RunError(ScriptEngine, ENotSupported);
    exit;
  end;
  FIsVirtual := Boolean(s[1]);
  Delete(s, 1, 1);
  Ptr := Pointer(ms2i(s));
  C := TCallingConvention(s[5]);
  Delete(s, 1, 5);
  Result := CreateCajVariant(Pointer(ms2i(s)));
  if FIsVirtual then
  begin
    Ptr := VirtualMethodPtrToPtr(Ptr, PPointer(FSelf)^);
  end;
  if not InnerfuseCall2(ScriptEngine, FSelf, Ptr, C, Params, Result,
    @DefExtObjSupport) then
  begin
    TIfPasScript(ScriptEngine).RunError(ScriptEngine, ENotSupported);
    DestroyCajVariant(Result);
    Result := nil;
    exit;
  end;
end;

type
  TDummyIFPS = class(TIfPasScript)
  end;

constructor TIfsExternalClassWrapper.Create(ScriptEngine: Pointer; s:
  TIFPSClassWrapper);

begin
  inherited Create(ScriptEngine);
  fs := s;
  FFuncs := TIfStringList.Create;
  FProps := TIfStringList.Create;
  FConstructors := TIfStringList.Create;
  FPropHelpers := TIfStringList.Create;
end;

destructor TIfsExternalClassWrapper.Destroy;
begin
  FFuncs.Free;
  FProps.Free;
  FConstructors.Free;
  FPropHelpers.Free;
  inherited;
end;

function TIfsExternalClassWrapper.FindClassProc(const Name: string): Longint;
var
  I, l: Longint;
  h, n: Cardinal;
  s: string;

begin
  h := mkhash(Name);
  for I := 0 to FConstructors.Count - 1 do
  begin
    s := FConstructors.GetItem(I);
    n := ms2i(s);
    if n = h then
    begin
      Delete(s, 1, 4);
      l := ms2i(s);
      s := copy(s, 5, l);
      if s = Name then
      begin
        Result := I;
        exit;
      end;
    end;
  end;
  Result := -1;
end;

function TIfsExternalClassWrapper.FindProc(FSelf: PIFSExternalObject; const
  Name: string): Longint;
var
  I, l: Longint;
  h, n: Cardinal;
  s: string;

begin
  h := mkhash(Name);
  for I := 0 to FFuncs.Count - 1 do
  begin
    s := FFuncs.GetItem(I);
    n := ms2i(s);
    if n = h then
    begin
      Delete(s, 1, 4);
      l := ms2i(s);
      s := copy(s, 5, l);
      if s = Name then
      begin
        Result := I;
        exit;
      end;
    end;
  end;
  Result := -1;
end;

const
  PropHelpersStart = 1073741824;

function TIfsExternalClassWrapper.FindProperty(FSelf: PIFSExternalObject;
  const Name: string): Longint;
var
  I: Longint;
  h: Cardinal;
  s: string;
begin
  h := mkhash(Name);
  for I := 0 to FProps.Count - 1 do
  begin
    s := FProps.GetItem(I);
    if Cardinal(ms2i(s)) = h then
    begin
      Delete(s, 1, 4);
      if copy(s, 5, ms2i(s)) = Name then
      begin
        Result := I;
        exit;
      end;
    end;
  end;
  for I := 0 to FPropHelpers.Count - 1 do
  begin
    s := FPropHelpers.GetItem(I);
    if Cardinal(ms2i(s)) = h then
    begin
      Delete(s, 1, 4);
      if copy(s, 5, ms2i(s)) = Name then
      begin
        Result := PropHelpersStart + I;
        exit;
      end;
    end;
  end;
  Result := -1;
end;
{
0: 8 bits value
1: 16 bits value
2: 32 bits value
3: String;
4: Real type
5: ExternalObject (Ptr)
6: Event (TMethod)

mi2s(NameHash)+mi2s(LengthOfName)+name+mi2s(FType)+mi2s(PropInfo)+chr(ord(TTypeKind))

}

function TIfsExternalClassWrapper.GetProperty(FSelf: PIFSExternalObject;
  I: Integer; dest: PIfVariant): Boolean;
var
  p: PPropInfo;
  Nr: TPropertyReadProc;
  FType: Byte;
  s: string;
begin
  if I >= PropHelpersStart then
  begin
    s := FPropHelpers.GetItem(I - PropHelpersStart);
    if s = '' then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    Delete(s, 1, 4 + 4 + ms2i(s));
    @Nr := Pointer(ms2i(s));
    if @Nr = nil then
    begin
      Result := False;
      exit;
    end;
    Result := Nr(ScriptEngine, FSelf, dest);
  end
  else
  begin
    s := FProps.GetItem(I);
    if s = '' then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    Delete(s, 1, 4 + 4 + ms2i(s));
    p := Pointer(ms2i(s));
    if p^.GetProc = nil then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    FType := Ord(s[1]);
    case FType of
      0: dest^.Cv_UByte := GetOrdProp(TObject(FSelf), p);
      1: dest^.Cv_UInt16 := GetOrdProp(TObject(FSelf), p);
      2: dest^.Cv_SInt32 := GetOrdProp(TObject(FSelf), p);
      3: dest^.Cv_Str := GetStrProp(TObject(FSelf), p);
      4: SetReal(dest, GetFloatProp(TObject(FSelf), p));
      5: CreateClassInstance(ScriptEngine, dest,
          Pointer(GetOrdProp(TObject(FSelf), p)));
    end;
    Result := True;
  end;
end;

function TIfsExternalClassWrapper.GetPropertyType(
  FSelf: PIFSExternalObject; I: Integer): PTypeRec;
var
  s: string;
begin
  if I >= PropHelpersStart then
  begin
    s := FPropHelpers.GetItem(I - PropHelpersStart);
    Delete(s, 1, 4);
    Delete(s, 1, 4 + ms2i(s));
    Result := Pointer(ms2i(s));
  end
  else
  begin
    s := FProps.GetItem(I);
    Delete(s, 1, 4);
    Delete(s, 1, 4 + ms2i(s));
    Result := Pointer(ms2i(s));
  end;
end;

function TIfsExternalClassWrapper.IsCompatibleWith(x: PTypeRec): Boolean;
var
  n: TIFPSClassWrapper;
begin
  if (x^.Ext <> nil) and (TObject(x^.Ext) is TIfsExternalClassWrapper) then
  begin
    n := TIfsExternalClassWrapper(x^.Ext).fs;
    Result := False;
    repeat
      if n = fs then
      begin
        Result := True;
        exit;
      end
      else
        n := n.FInheritsFrom;
    until n = nil;
  end
  else
    Result := False;
end;

function TIfsExternalClassWrapper.SetProperty(FSelf: PIFSExternalObject;
  I: Integer; p: PIfVariant): Boolean;
var
  PT: PPropInfo;
  FType: Byte;
  nw: TPropertyWriteProc;
  s: string;
begin
  if I >= PropHelpersStart then
  begin
    s := FPropHelpers.GetItem(I - PropHelpersStart);
    if s = '' then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    Delete(s, 1, 4 + 4 + 4 + ms2i(s));
    @nw := Pointer(ms2i(s));
    if @nw = nil then
    begin
      Result := False;
      exit;
    end;
    Result := nw(ScriptEngine, FSelf, p);
  end
  else
  begin
    s := FProps.GetItem(I);
    if s = '' then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    Delete(s, 1, 4 + 4 + ms2i(s));
    PT := Pointer(ms2i(s));
    if PT^.SetProc = nil then
    begin
      Result := False;
      exit;
    end;
    Delete(s, 1, 4);
    FType := Ord(s[1]);
    case FType of
      0: SetOrdProp(TObject(FSelf), PT, p^.Cv_UByte);
      1: SetOrdProp(TObject(FSelf), PT, p^.Cv_UInt16);
      2: SetOrdProp(TObject(FSelf), PT, p^.Cv_SInt32);
      3: SetStrProp(TObject(FSelf), PT, p^.Cv_Str);
      4: SetFloatProp(TObject(FSelf), PT, GetReal(p));
      5:
        begin
          if (p^.CV_ExternalObject = nil) then
            SetOrdProp(TObject(FSelf), PT, 0)
          else
            SetOrdProp(TObject(FSelf), PT, Longint(p^.CV_ExternalObject));
        end;
      6:
        begin
          SetMethodProp(TObject(FSelf), PT, PProcedureToMethod(p^.Cv_Proc));
        end;
    end;
    Result := True;
  end;
end;

procedure TIfsExternalClassWrapper.InitClasses;
var
  I: Longint;
  CC: TIFPSClassWrapper;
  translatetable: TIfStringList;
  function TranslateType(SE: TDummyIFPS; p1: PTypeRec): PTypeRec; forward;

  function TranslateProcHeader(s: string): string;
  var
    n: string;
    l: Longint;
  begin
    n := mi2s(Longint(TranslateType(ScriptEngine, Pointer(ms2i(s)))));
    delete(s, 1, 4);
    while length(s) > 0 do
    begin
      n := n + s[1];
      delete(s, 1, 1);
      l := 4 + ms2i(s);
      n := n + copy(s, 1, l);
      delete(s, 1, l);
      n := n + mi2s(Longint(TranslateType(Scriptengine, Pointer(ms2i(s)))));
      delete(s, 1, 4);
    end;
    result := n;
  end;

  function TranslateType(SE: TDummyIFPS; p1: PTypeRec): PTypeRec;
  var
    I: Longint;
    s: string;
    n: PTypeRec;
    pt: PIFSProcType;
  begin
    if p1 = nil then
    begin
      Result := nil;
      exit;
    end;
    for I := 0 to translatetable.Count - 1 do
    begin
      s := translatetable.GetItem(I);
      if Longint(p1) = ms2i(s) then
      begin
        Delete(s, 1, 4);
        Result := PTypeRec(ms2i(s));
        exit;
      end;
    end;
    for I := 0 to SE.Types.List.Count - 1 do
    begin
      n := PTypeRec(SE.Types.List.GetItem(I));
      if (n^.atypeid = p1^.atypeid) and (n^.Ext = p1^.Ext) then
      begin
        translatetable.Add(mi2s(Longint(p1)) + mi2s(Longint(n)));
        Result := n;
        exit;
      end
      else if (p1^.atypeid = CSV_ExternalObject) and (n^.atypeid =
        CSV_ExternalObject) and (TObject(n^.Ext) is TIfsExternalClassWrapper)
          then
      begin
        if TIfsExternalClassWrapper(n^.Ext).fs = p1^.Ext then
        begin
          translatetable.Add(mi2s(Longint(p1)) + mi2s(Longint(n)));
          Result := n;
          exit;
        end;
      end;
    end;
    case p1^.atypeid of
      CSV_Record, CSV_ExternalObject: Result := nil;
      CSV_ProcVariable:
        begin
          new(pt);
          pt^.Decl := TranslateProcHeader(PIFSProcType(p1^.Ext)^.Decl);
          pt^.Method := PIFSProcType(p1^.Ext)^.Method;
          n := TM_Add(SE.Types, '', CSV_ProcVariable, pt);
          translatetable.Add(mi2s(Longint(p1)) + mi2s(Longint(n)));
          Result := n;
        end;
    else
      begin
        n := TM_Add(SE.Types, '', p1^.atypeid, p1^.Ext);
        translatetable.Add(mi2s(Longint(p1)) + mi2s(Longint(n)));
        Result := n;
      end;
    end;
  end;

  function TranslateProcTypes(s: string): string;
  var
    l: Longint;

  begin
    Result := copy(s, 1, 4); {namehash}
    Delete(s, 1, 4);
    l := ms2i(s); // length
    Result := Result + copy(s, 1, 4 + 1 + 5 + l);
    //length+name+ptr+callconv+fvirtual
    Delete(s, 1, 5 + 1 + 4 + l);
    l := ms2i(s); // result type
    Result := Result + mi2s(Longint(TranslateType(ScriptEngine, PTypeRec(l))));
    Delete(s, 1, 4);
    while Length(s) > 0 do
    begin
      Result := Result + s[1];
      Delete(s, 1, 1);
      l := ms2i(s); // length of name
      Result := Result + copy(s, 1, 4 + l);
      Delete(s, 1, 4 + l);
      l := ms2i(s);
      Result := Result + mi2s(Longint(TranslateType(ScriptEngine,
        PTypeRec(l))));
      Delete(s, 1, 4);
    end;
  end;

  function TranslatePropTypes(s: string): string;
  var
    l: Longint;

  begin
    Result := copy(s, 1, 4); {namehash}
    Delete(s, 1, 4);
    l := ms2i(s); // length
    Result := Result + copy(s, 1, 4 + l); //name+lengthofname
    Delete(s, 1, 4 + l);
    l := ms2i(s); // result type
    Delete(s, 1, 4);
    Result := Result + mi2s(Longint(TranslateType(ScriptEngine, PTypeRec(l)))) +
      s;
  end;
begin
  CC := fs;
  translatetable := TIfStringList.Create;
  while assigned(CC) do
  begin
    for I := 0 to CC.FProps.Count - 1 do
    begin
      FProps.Add(TranslatePropTypes(CC.FProps.GetItem(I)));
    end;
    for I := 0 to CC.FPropHelpers.Count - 1 do
    begin
      FPropHelpers.Add(TranslatePropTypes(CC.FPropHelpers.GetItem(I)));
    end;
    for I := 0 to CC.FFuncs.Count - 1 do
    begin
      FFuncs.Add(TranslateProcTypes(CC.FFuncs.GetItem(I)));
    end;
    for I := 0 to CC.FConstructors.Count - 1 do
    begin
      FConstructors.Add(TranslateProcTypes(CC.FConstructors.GetItem(I)));
    end;
    CC := CC.FInheritsFrom;
  end;
  translatetable.Free;
end;

function TIfsExternalClassWrapper.GetClassProcHeader(I: Integer): string;
var
  s: string;
begin
  s := FConstructors.GetItem(I);
  if s <> '' then
  begin
    Delete(s, 1, 4);
    Delete(s, 1, ms2i(s) + 10);
  end;
  Result := s;
end;

function TIfsExternalClassWrapper.GetProcHeader(FSelf: PIFSExternalObject;
  I: Integer): string;
var
  s: string;
begin
  s := FFuncs.GetItem(I);
  if s <> '' then
  begin
    Delete(s, 1, 4);
    Delete(s, 1, ms2i(s) + 10);
  end;
  Result := s;
end;

procedure RegisterEClasses(ScriptEngine: TIfPasScript; FCl: TIFPSClasses);
var
  IClasses: TIfList;

  procedure RegisterClass(Cl: TIFPSClassWrapper);
  var
    p: PTypeRec;
  begin
    p := ScriptEngine.AddTypeEx(Cl.FClassName);
    if assigned(p) then
    begin
      p^.atypeid := CSV_ExternalObject;
      p^.Ext := TIfsExternalClassWrapper.Create(ScriptEngine, Cl);
      TIfsExternalClassWrapper(p^.Ext).ScriptType := p;
      IClasses.Add(p^.Ext);
    end;
  end;
var
  I: Longint;
begin
  IClasses := TIfList.Create;
  for I := 0 to FCl.FClasses.Count - 1 do
  begin
    RegisterClass(FCl.FClasses.GetItem(I));
  end;
  for I := 0 to IClasses.Count - 1 do
  begin
    TIfsExternalClassWrapper(IClasses.GetItem(I)).InitClasses;
    RegisterClass(FCl.FClasses.GetItem(I));
  end;
  IClasses.Free;
end;

function AddClassToScriptEngine(ScriptEngine: TIfPasScript; FClass: TObject;
  const ClassName, VarName: string): Boolean;
var
  p: PIfVariant;
begin
  p := ScriptEngine.AddVariable(VarName, ClassName, False);
  if (p = nil) then
  begin
    Result := False;
    exit;
  end;
  CreateClassInstance(ScriptEngine, p, FClass);
  Result := True;
end;

end.

