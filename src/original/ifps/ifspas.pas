{
IfPasScript

version: 2.82
Last stable version: 2.82

Features:
 - Support for standard types: Byte, Shortint, Char, Word, SmallInt,
   Cardinal, Longint, Integer, String, Real, Double, Single, Extended,
   Comp, Boolean, Array, Record, Variant, Enumerations
 - Classes (Declared inside or outside script)
 - Variables, Constants
 - Standard statements: Begin/End, If/Then/Else, For/To/Downto/Do,
   Case x Of, Repeat/Until, While, With, Uses, Try/Except/Finally,
 - Exit, Continue, Break
 - Functions (Declared inside or outside script)
 - Array of Const parameters, Var parameters
 - External modules (attached script engines)
 - A lot of libraries like Databases, Forms, Dll calls, Delphi calls...
 - Documentation and examples
}
unit ifspas;
{$I ifs_def.inc}
interface
uses
  SysUtils, ifs_var, ifs_utl{$IFNDEF NOCLASSES}, ifs_obj{$ENDIF}{$IFDEF VARIANTSUNIT}, Variants{$ENDIF};
const
  IFPSVersion = '2.82';

type
  TIfPasScript = class;
  TIFSError = record
    ErrorCode: TIfPasScriptError;
    ErrorPosition: Longint;
    ErrorParam: string;
    ErrorModule: string;
  end;
  TResourceFree = procedure(id: Pointer; Data: Pointer);
  PIFPSResourceData = ^TIFPSResourceData;
  TIFPSResourceData = record
    Data: Pointer;
    FreeProc: TResourceFree;
  end;
  TCs2PascalScript = TIfPasScript;
  TOnUses = function(id: Pointer; Sender: TIfPasScript; Name: string): TIfPasScriptError;
  TOnRunLine = function(id: Pointer; Sender: TIfPasScript; Position: Longint): TIfPasScriptError;
  TOnExternal = function(id: Pointer; Sender: TIfPasScript; const Param, FuncName: string; Func: PProcedure; const CallingConvention: string): Boolean;
  TPerformType = (PtSet, ptMinus, PtPlus, PtMul, ptDiv, PtIntDiv, PtIntMod, PtAnd, ptOr, ptXor, PtShl, PtShr, PtGreater, PtLess, PtEqual, PtNotEqual, PtGreaterEqual, PtLessEqual{$IFNDEF NOCLASSES}, ptIs, ptAs{$ENDIF});
  TIfPasScript = class
  Private
    FUses: TIfStringList;
    FFreeOnCleanup: Boolean;
{$IFNDEF NOCLASSES}
    CreatedClasses: TIfList;
{$ENDIF}
    FISUnit: Boolean;
    FModuleName: string;
    MainOffset: Longint;
    fId: Pointer;
    FError: TIFSError;
    FOnUses: TOnUses;
    FOnRunLine: TOnRunLine;
    FOnExternal: TOnExternal;
    FBeginNesting: Longint;
    FMaxBeginNesting: Longint;
    FMaxArrayLength: Longint;
    function GetIdentifier(WithList: TIfList; Vars: PVariableManager; Mode: Byte; var w: PIfVariant): Byte;
    {mode 0 = normal; 1 = AsVariable; 2 = asProcPointer}
    function IdentifierExists(AlsoVariables: Boolean; SubVars: PVariableManager; const s: string): Boolean;
    function ProcessVars(Vars: PVariableManager): Boolean;
    function ProcessConsts(Vars: PVariableManager): Boolean;
    function ReadType(Parser: TIfPascalParser; AllowClasses: Boolean; const Name: string): PTypeRec;
    function RunBegin(WithList: TIfList; Vars: PVariableManager; Skip: Boolean): Boolean;
    function calc(WithList: TIfList; Vars: PVariableManager; res: PIfVariant; StopOn: TIfPasToken; OnlyConst: Boolean): Boolean;
    function DoProc(WithList: TIfList; {$IFNDEF NOCLASSES}Myself: PCreatedClass; {$ENDIF}proc: PProcedure; Vars: PVariableManager): PIfVariant;
    function ReadParams(WithList: TIfList; ProcDef: string; Vars, Params: PVariableManager): Boolean;
{$IFNDEF NOCLASSES}
    function DoClassConstructor(WithList: TIfList; Myclass: PTypeRec; proc: PProcedure; Vars: PVariableManager): PIfVariant;
{$ENDIF}
    function Perform(V1: PIfVariant; v2: PIfVariant; t: TPerformType): Boolean;
    function MakeCompat(v: PIfVariant; FType: PTypeRec): Boolean;
    procedure AddStandard;
    function GetErrorCode: TIfPasScriptError;
    function GetErrorPos: Longint;
    function GetErrorString: string;
    function GetErrorModule: string;
    procedure LoadData;
  Protected
    FAllocatedResources: TIfList;
    Variables: PVariableManager;
    Types: PTypeManager;
    Procedures: PProcedureManager;
    Parser: TIfPascalParser;
    ProcStack: TIfList;
    CurrVars: PVariableManager;
    FAttachedOnes: TIfList;
    FLastException: TIFSError;
    function GetCurrProc: PProcedure;
    function PopProcStack: PProcedure;
    function ExecRunLine: Boolean; Virtual;
  Public
    procedure RunError(SE: TIfPasScript; C: TIfPasScriptError);
    procedure RunError2(SE: TIfPasScript; C: TIfPasScriptError; Ext: string);

    function GetVariable(const Name: string): PIfVariant;
    function GetFunction(s: string): PProcedure;
    function GetType(const s: string): PTypeRec;

    function RemoveFunction(d: PProcedure): Boolean; // does not dispose it

    function AddVariable(Name, FType: string; Constant: Boolean): PIfVariant;
    function AddFunction(proc: Pointer; Decl: string; Ext: Pointer): PProcedure;
    function AddClassFunction(proc: TRegisteredProcObject; Decl: string; Ext: Pointer): PProcedure;
    function AddType(const Name, Decl: string): PTypeRec;
    function AddTypeEx(Name: string): PTypeRec;
{$IFNDEF NOCLASSES}
    function AddClass(const Name, Decl: string; RegProc: Pointer): PTypeRec;
{$ENDIF}
{$IFDEF VARIANTSUPPORT}
    function CallFunction(p: PProcedure; Params: array of Variant): Variant;
{$IFNDEF NOCLASSES}
    function CallMethod(p: PProcedure; Myself: PCreatedClass; Params: array of Variant): Variant;
{$ENDIF}
{$ENDIF}

{$IFDEF VARIANTSUPPORT}
    function VariantToIFVariant(const v: Variant; res: PIfVariant): Boolean;
    function IfVariantToVariant(v: PIfVariant; var res: Variant): Boolean;
{$ENDIF}

    function CopyVariant(p: PIfVariant): PIfVariant;
    function CreateReal(const E: Extended): PIfVariant;
    function CreateString(const s: string): PIfVariant;
    function CreateInteger(I: Longint): PIfVariant;
    function CreateBool(b: Boolean): PIfVariant;
    function CreateVarType(p: PIfVariant): PIfVariant;

    procedure Cleanup; // cleans up classes and reset all variables

    procedure RunScript;
    function RunScriptProc(Func: PProcedure; Parameters: PVariableManager): PIfVariant;
{$IFNDEF NOCLASSES}
    function RunScriptConstructor(FType: PTypeRec; Func: PProcedure; Parameters: PVariableManager): PIfVariant;
    function RunInherited(proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
    function SetProperty(prop, Data: PIfVariant): Boolean;
    function GetProperty(prop: PIfVariant): PIfVariant; // nil = error
{$ENDIF}

    function Attach(ScriptEngine: TIfPasScript): Boolean;
    function Attach2(ScriptEngine: TIfPasScript; FreeOnCleanup: Boolean): Boolean;

    procedure AddResource(FreeProc: TResourceFree; Data: Pointer);
    procedure RemoveResource(Data: Pointer);
    function IsValidResource(FreeProc: TResourceFree; Data: Pointer): Boolean;
    function FindResource(FreeProc: TResourceFree): Pointer;

    procedure SetText(const Data: string);
    procedure SetPData(const Data: string);
    function GetPData(var Data: string): Boolean;

    constructor Create(id: Pointer);
    destructor Destroy; Override;

    property ModuleName: string Read FModuleName Write FModuleName;

    property IsUnit: Boolean Read FISUnit;
    property OnRunLine: TOnRunLine Read FOnRunLine Write FOnRunLine;
    property OnUses: TOnUses Read FOnUses Write FOnUses;
    property OnExternal: TOnExternal Read FOnExternal Write FOnExternal;

    property ErrorCode: TCs2Error Read GetErrorCode;
    property ErrorPos: Longint Read GetErrorPos;
    property ErrorString: string Read GetErrorString;
    property ErrorModule: string Read GetErrorModule;

    property MaxBeginNesting: Longint Read FMaxBeginNesting Write FMaxBeginNesting;
    property MaxArrayLength: Longint Read FMaxArrayLength Write FMaxArrayLength;
  end;
{$IFNDEF NOCLASSES}
function GetClassVariable(Self: PIfVariant; ProcClass: PIFSClassType; const Name: string; var thevar: PIfVariant; AlsoProtected: Boolean): Boolean;
function GetClassVariable2(Self: PCreatedClass; ProcClass: PIFSClassType; const Name: string; var thevar: PIfVariant; AlsoProtected: Boolean): Boolean;
function GetClassProcedure(Self: PIfVariant; ProcClass: PIFSClassType; const Name: string; var proc: PProcedure; AlsoProtected: Boolean): Boolean;
function GetInheritedProc(CurrProc: PProcedure): PProcedure;
{$ENDIF}

procedure SetArrayLength(fVar: PIfVariant; NewLength: Longint);

procedure RegisterStdLib(p: TIfPasScript; OnlySafe: Boolean);
{If onlysafe is true, All Floating point functions are disabled (cos, sin, tan, round etc)}
{Register all standard functions:}
{
Installs:
  Function StrGet(S : String; I : Integer) : Char;
  Function StrSet(c : Char; I : Integer; var s : String) : Char;
  Function Chr(B : Byte) : Char;
  Function StrToInt(s : string;def : Longint) : Longint;
  Function IntToStr(i : Longint) : String;
  Function Uppercase(s : string) : string;
  Function Lowercase(s : string) : string;
  Function Trim(s : string) : string;
  Function Copy(S : String; Indx, Count : Integer) : String;
  Procedure Delete(var S : String; Indx, Count : Integer);
  Function Pos(SubStr, S : String) : Integer;
  Procedure Insert(Source : String; var Dest : String; Indx : Integer);
  Function Length(s : String) : Longint;
  procedure SetLength(var S: String; L: Longint);
  Function Sin(e : Extended) : Extended;
  Function Cos(e : Extended) : Extended;
  Function Sqrt(e : Extended) : Extended;
  Function Round(e : Extended) : Longint;
  Function Trunc(e : Extended) : Longint;
  Function Int(e : Extended) : Longint;
  Function Pi : Extended;
  Function Abs(e : Extended) : Extended;
  Function Sqrt(e : Extended) : Extended;
  function StrToFloat(s: string): Extended;
  Function FloatToStr(e : Extended) : String;
  Function Padl(s : string;I : longInt) : string;
  Function Padr(s : string;I : longInt) : string;
  Function Padz(s : string;I : longInt) : string;
  Function Replicate(c : char;I : longInt) : string;
  Function StringOfChar(c : char;I : longInt) : string;
  procedure SetArrayLength(var u: array; Length: Longint);
  function GetArrayLength(var u: array): Longint;
  function GetType(const data): String;
  function Assigned(const data): Boolean;

  Function Ord(var C) : Longint;
  function Pred(var C);
  function Succ(var c);
  function Low(var u);
  function High(var u);

Type
  TObject = class
  public
    Constructor Create;
    Destructor Destroy; virtual;
    procedure Free;

    function ClassNameIs(FType: string): Boolean;
    function ClassName: string;
    function GetAncestors: string;
  end;

}

procedure RegisterExceptionLib(Sender: TIfPasScript);

{
  function GetLastErrorCode: word;
  function GetLastErrorParam: string;
  function GetLastErrorModule: string;
  function GetLastErrorAsString: string;
  function GetLastErrorPosition: Longint;
  procedure RaiseError(ErrorCode: Word; Param: string);

}
{$IFDEF USEIDISPATCH}
type
  TIDispatchToIFVariant = function(ScriptEngine: TIfPasScript; res: PIfVariant; I: IDispatch): Boolean;
  TIFVariantToIDispatch = function(ScriptEngine: TIfPasScript; var res: IDispatch; I: PIfVariant): Boolean;
var
  IDispatchToIFVariantProc: TIDispatchToIFVariant = nil;
  IFVariantToIDispatchProc: TIFVariantToIDispatch = nil;
{$ENDIF}
function ms2i(const s: string): Longint;
function IntProcDefParam(s: string; I: Integer): Integer;
function IntProcDefName(s: string; I: Integer): string;

implementation

{
mi2s(funcRes)+params

Param:
  chr(modifier)+mystring(name)+mi2s(type)
  modifier: #0 = no; #1 = Varparam; #2 = constparam
}

function ms2i(const s: string): Longint;
begin
  if Length(s) < 4 then begin
    Result := 0;
  end else
    Result := Longint((@s[1])^);
end;

function IntProcDefParam(s: string; I: Integer): Integer;
{
Parse the incode-script procedure definition from a string.
When I=0 this function will return the result type.
When I=-1 this function will return the number of parameters.
When I=1 this function will return the first parameter type.
When I=2 this function will return the second parameter type.
etc.
}
var
  l, res: Integer;
begin
  if I = 0 then
  {Return result-type} IntProcDefParam := ms2i(s)
  else if I < 0 then {Return param count}  begin
    Delete(s, 1, 5); // delete result and modifier
    res := 0;
    while Length(s) > 0 do begin
      l := ms2i(s);
      Delete(s, 1, (4 + 4 + 1) + l); {4+4+1 = length; type; modifier}
      Inc(res);
    end; {while}
    IntProcDefParam := res;
  end {else if} else begin
    Delete(s, 1, 5); // delete result and modifier
    res := 0;
    while Length(s) > 0 do begin
      Inc(res);
      l := ms2i(s);
      Delete(s, 1, 4 + l);
      if res = I then begin
        IntProcDefParam := ms2i(s);
        exit;
      end;
      Delete(s, 1, 4 + 1);
      rs(s);
    end; {while}
    IntProcDefParam := 0;
  end {Else Else if}
end; {IntProcDefParam}
//-------------------------------------------------------------------

function IntProcDefName(s: string; I: Integer): string;
{
Parse the incode-script procedure definition from a string.
i=0 will return the procedure name
I=1 will return the first one
}
var
  res: Integer;
begin
{  chr(modifier)+mystring(name)+mi2s(type) }
  res := 0;
  if I < 1 then begin
    IntProcDefName := '';
    exit;
  end;
  Delete(s, 1, 4);
  while Length(s) > 0 do begin
    Inc(res);
    if res = I then begin
      res := Ord(s[1]); // modifier
      Delete(s, 1, 1);
      I := ms2i(s); // string length
      Delete(s, 1, 4);
      if res = 0 then
        IntProcDefName := copy(s, 1, I)
      else if res = 1 then
        IntProcDefName := '!' + copy(s, 1, I)
      else
        IntProcDefName := '^' + copy(s, 1, I);
      exit;
    end;
    Delete(s, 1, 1);
    delete(s, 1, ms2i(s)+4+4);
  end; {while}
  IntProcDefName := '';
end; {IntProcDefParam}

procedure DestroyWithList(I: TIfList);
var
  u: Integer;
begin
  for u := 0 to Longint(I.Count) - 1 do begin
    DestroyCajVariant(I.GetItem(u));
  end;
  I.Free;
end;

{$IFNDEF NOCLASSES}

function IsSameClassFamily(s1, s2: PIFSClassType; EnableSwitch: Boolean): Boolean;
var
  s3: PIFSClassType;
begin
  if (s1.VarNoStart > s2.VarNoStart) and EnableSwitch then begin
    s3 := s1;
    s1 := s2;
    s2 := s3;
  end;
  while (s1 <> s2) do begin
    if assigned(s2^.InheritsFrom) then
      s2 := s2^.InheritsFrom^.Ext
    else begin
      s2 := nil;
      break;
    end;
  end;
  IsSameClassFamily := s2 <> nil;
end;

//-------------------------------------------------------------------

function GetClassProcedure(Self: PIfVariant; ProcClass: PIFSClassType; const Name: string; var proc: PProcedure; AlsoProtected: Boolean): Boolean;
var
  pc: PIFSClassType;
  I: Integer;

  procedure CheckForward;
  var
    n: TIfList;
    I, I2: Integer;
    E: PProcedure;
  begin
    if (proc^.Flags and $30) <> 0 then begin
      n := TIfList.Create;
      if assigned(Self) then
        ProcClass := Self.CV_Class^.ClassType^.Ext;
      while assigned(ProcClass) and (ProcClass <> proc^.ClassType^.Ext) do begin
        n.Add(ProcClass);
        if assigned(ProcClass^.InheritsFrom) then
          ProcClass := ProcClass^.InheritsFrom^.Ext
        else
          ProcClass := nil;
      end;
      for I := Longint(n.Count) - 1 downto 0 do begin
        ProcClass := n.GetItem(I);
        for I2 := 0 to (ProcClass^.Procedures.Count) - 1 do begin
          E := ProcClass^.Procedures.GetItem(I2);
          if copy(E^.Name, 2, Length(E^.Name) - 1) = Name then begin
            if (E^.Flags and $30) <> $20 then begin
              break;
            end else
              proc := E;
          end; {if}
        end; {for}
      end; {for}
      n.Free;
    end;
  end;
begin
  pc := ProcClass;
  while assigned(pc) do begin
    for I := 0 to Longint(pc^.Procedures.Count) - 1 do begin
      proc := pc^.Procedures.GetItem(I);
      if copy(proc^.Name, 2, Length(proc^.Name) - 1) = Name then begin
        if (proc.Flags and $3) = $2 then begin
          CheckForward;
          GetClassProcedure := True;
          exit;
        end;
        if AlsoProtected then begin
          if pc = ProcClass then begin
            CheckForward;
            GetClassProcedure := True;
            exit;
          end else
            if (proc.Flags and $3) = $1 then begin
              CheckForward;
              GetClassProcedure := True;
              exit;
            end;
          if (proc.Flags and $3) = $3 then begin
            CheckForward;
            GetClassProcedure := True;
            exit;
          end;
        end;
      end;
    end; {for}
    if assigned(pc^.InheritsFrom) then
      pc := pc^.InheritsFrom^.Ext
    else
      pc := nil;
  end; {while}
  GetClassProcedure := False;
end;
//-------------------------------------------------------------------

function FindProc(TheClass: PTypeRec; const Name: string): PProcedure;
var
  Curr: PTypeRec;
  res: PProcedure;

  function SearchList(List: TIfList): PProcedure;
  var
    I: Integer;
    n: PProcedure;
  begin
    for I := 0 to Longint(List.Count) - 1 do begin
      n := List.GetItem(I);
      if n^.Name = Name then begin
        SearchList := n;
        exit;
      end;
    end;
    SearchList := nil;
  end; {searchlist}
begin
  Curr := TheClass;
  res := nil;
  while assigned(Curr) do begin
    res := SearchList(PIFSClassType(Curr^.Ext)^.Procedures);
    if res = nil then
      Curr := PIFSClassType(Curr^.Ext)^.InheritsFrom
    else
      break;
  end;
  FindProc := res;
end;
//-------------------------------------------------------------------

function GetClassVariable(Self: PIfVariant; ProcClass: PIFSClassType; const Name: string; var thevar: PIfVariant; AlsoProtected: Boolean): Boolean;
begin
  GetClassVariable := GetClassVariable2(Self^.CV_Class, ProcClass, Name, thevar, AlsoProtected);
end;

//-------------------------------------------------------------------

function GetClassVariable2(Self: PCreatedClass; ProcClass: PIFSClassType; const Name: string; var thevar: PIfVariant; AlsoProtected: Boolean): Boolean;
var
  TC: PCreatedClass;
  ct: PIFSClassType;
  pp: PPropertyDef;
  I: Longint;
  u, s: string;
begin
  TC := Self;
  if not IsSameClassFamily(TC^.ClassType^.Ext, ProcClass, True) then begin
    GetClassVariable2 := False;
    exit;
  end;
  ct := ProcClass;
  while assigned(ct) do begin
    s := ct^.Variables.u;
    I := ct^.VarNoStart;
    while Length(s) > 0 do begin
      u := Fw(s);
      Rfw(s); {remove name}
      Rfw(s); {remove type}
      if copy(u, 2, Length(u) - 1) = Name then begin
        thevar := Vm_Get(TC^.Variables, I);
        if (thevar.Flags and $6) = $4 then begin
          GetClassVariable2 := True;
          exit;
        end;
        if AlsoProtected then begin
          if ct = ProcClass then begin
            GetClassVariable2 := True;
            exit;
          end else if (thevar.Flags and $6) = $6 then begin
            GetClassVariable2 := True;
            exit;
          end;
        end; {if}
      end; {while}
      Inc(I);
    end;
    for I := 0 to Longint(ct^.Properties.Count) - 1 do begin
      pp := ct^.Properties.GetItem(I);
      if pp^.Name = Name then begin
        thevar := Vm_Get(TC^.Variables, Longint(PIFSClassType(Self^.ClassType.Ext)^.VarNoStart + PIFSClassType(Self^.ClassType.Ext)^.VarCount) + I + Longint(ct^.PropStart));
        if (thevar.Flags and $6) = $4 then begin
          GetClassVariable2 := True;
          exit;
        end;
        if AlsoProtected then begin
          if ct = ProcClass then begin
            GetClassVariable2 := True;
            exit;
          end else if (thevar.Flags and $6) = $6 then begin
            GetClassVariable2 := True;
            exit;
          end;
        end;
      end;
    end;
    if assigned(ct.InheritsFrom) then
      ct := ct.InheritsFrom^.Ext
    else
      ct := nil;
  end;
  GetClassVariable2 := False;
end;
//-------------------------------------------------------------------

//-------------------------------------------------------------------

function TIfPasScript.SetProperty(prop, Data: PIfVariant): Boolean;
var
  v: PVariableManager;
begin
  SetProperty := False;
  if (prop.CV_PropFlags and $2) = 0 then begin
    RunError(Self, ECanNotWriteProperty);
    exit;
  end;
  if (prop.CV_PropFlags and $8) <> 0 then begin
    v := VM_Create;
    Vm_Add(v, CreateCajVariant(PCreatedClass(prop^.CV_Self)^.ClassType), 'SELF')^.CV_Class := prop^.CV_Self;
    Vm_Add(v, CopyVariant(Data), 'DATA');
    DestroyCajVariant(RunScriptProc(prop.CV_PropWrite, v));
    if FError.ErrorCode = EParameterError then begin
      FError.ErrorCode := ENoError;
      RunError(Self, ETypeMismatch);
      VM_Destroy(v);
      exit;
    end;
    VM_Destroy(v);
  end else begin
    if not Perform(prop.CV_PropWrite, Data, PtSet) then
      exit;
  end;
  SetProperty := True;
end;
//-------------------------------------------------------------------

function TIfPasScript.GetProperty(prop: PIfVariant): PIfVariant;
var
  v: PVariableManager;
  res: PIfVariant;
begin
  GetProperty := nil;
  if (prop.CV_PropFlags and $1) = 0 then begin
    RunError(Self, ECanNotReadProperty);
    exit;
  end;
  if (prop.CV_PropFlags and $4) <> 0 then begin
    v := VM_Create;
    Vm_Add(v, CreateCajVariant(PCreatedClass(prop^.CV_Self)^.ClassType), 'SELF')^.CV_Class := prop^.CV_Self;
    res := RunScriptProc(prop.CV_PropRead, v);
    if FError.ErrorCode = EParameterError then begin
      FError.ErrorCode := ENoError;
      RunError(Self, ETypeMismatch);
      VM_Destroy(v);
      exit;
    end;
    VM_Destroy(v);
    GetProperty := res;
  end else begin
    GetProperty := CopyVariant(prop.CV_PropRead);
  end;
end;
//-------------------------------------------------------------------
{$ENDIF}

function TIfPasScript.Perform(V1: PIfVariant; v2: PIfVariant; t: TPerformType): Boolean;
var
  Err: Boolean;
  I: Longint;
  p: PIfVariant;

  procedure AddArrayVar(var v: TIfList; I: PIfVariant);
  var
    n: PIfVariant;
  begin
    New(n);
    n^.VType^.atypeid := CSV_Var;
    n^.CV_Var := nil;
    Perform(n, I, PtSet);
  end;


  procedure MakeItReal(v: Extended);
  begin
    ChangeType(V1, TM_Add(Types, '', CSV_Extended, nil));
    V1^.Cv_Extended := v;
  end;

  procedure MakeItBool(v: Boolean);
  begin
    ChangeType(V1, TM_Add(Types, '', CSV_Bool, nil));
    V1^.Cv_Bool := v;
  end;

  procedure MakeItString(const v: string);
  begin
    ChangeType(V1, TM_Add(Types, '', CSV_String, nil));
    V1^.Cv_Str := v;
  end;

begin
  V1 := GetVarLink(V1);
  v2 := GetVarLink(v2);
{$IFDEF VARIANTSUPPORT}
  if (v2^.VType^.atypeid = CSV_Variant) and (V1^.VType^.atypeid <> CSV_Variant) then begin
    v2 := v2^.CV_Variant;
    if v2 = nil then begin
      Perform := False;
      RunError(Self, EVariantIsNil);
      exit;
    end;
  end;
{$ENDIF}
  if V1^.VType^.atypeid = CSV_Record then begin
    if V1.VType <> v2.VType then begin
      Perform := False;
      RunError(Self, ETypeMismatch);
      exit;
    end;
  end else
    if ((V1^.VType^.atypeid <> v2^.VType^.atypeid) and
      not (IsIntRealType(V1) and IsIntRealType(v2)) and
      not (IsStringType(V1) and IsStringType(v2)) and
      not (V1^.VType^.atypeid = CSV_Var)){$IFNDEF NOCLASSES} and
    not ((V1^.VType^.atypeid = CSV_Class) and (v2^.VType^.atypeid = CSV_ClassRef)
      and ((t = ptAs) or (t = ptIs))){$ENDIF} and
{$IFDEF VARIANTSUPPORT}
    not (V1^.VType^.atypeid = CSV_Variant) and
{$ENDIF}
    not (((t = PtSet) or (t = PtEqual) or (t = PtNotEqual)) and
      (v2^.VType^.atypeid = CSV_Special) and ((V1^.VType^.atypeid = CSV_Var){$IFNDEF NOCLASSES}
      or (V1^.VType^.atypeid = CSV_Class) or (V1^.VType^.atypeid = CSV_ExternalObject) or
      (V1^.VType^.atypeid = CSV_ClassRef){$ENDIF}
{$IFDEF VARIANTSUPPORT} or (V1^.VType^.atypeid = CSV_Variant){$ENDIF}
      or (V1^.VType^.atypeid = CSV_ProcVariable)))
      then begin
      Perform := False;
      RunError(Self, ETypeMismatch);
      exit;
    end;
  Err := False;
  case t of
{$IFNDEF NOCLASSES}
    ptIs: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Class: begin
              if not assigned(v2^.Cv_ClassRef) then begin
                MakeItBool(False);
              end else begin
                if not assigned(V1^.CV_Class) then begin
                  MakeItBool(False)
                end else
                  if IsSameClassFamily(v2^.Cv_ClassRef^.Ext, V1^.CV_Class^.ClassType^.Ext, True) then begin
                    MakeItBool(True);
                  end else begin
                    MakeItBool(False);
                  end;
              end;
            end;
        else begin
            RunError(Self, ETypeMismatch);
            Err := True;
          end;
        end;
      end;
    ptAs: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Class: begin
              if not assigned(v2^.Cv_ClassRef) then begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end else begin
                if not assigned(V1^.CV_Class) then begin
                  RunError(Self, EClassNotCreated);
                  Err := True;
                end else
                  if IsSameClassFamily(v2^.Cv_ClassRef^.Ext, V1^.CV_Class^.ClassType^.Ext, True) then begin
                    V1^.VType := v2^.Cv_ClassRef;
                  end else begin
                    Err := True;
                    RunError(Self, ETypeMismatch);
                  end;
              end;
            end;
        else begin
            RunError(Self, ETypeMismatch);
            Err := True;
          end;
        end;
      end;
{$ENDIF}
    PtSet: begin
        if IsIntegerType(V1) and not IsIntegerType(v2) then begin
          RunError(Self, ETypeMismatch);
          Err := True;
        end else
          case V1^.VType^.atypeid of
            CSV_Enum: begin
                if V1^.VType = v2^.VType then begin
                  V1^.CV_Enum := v2^.CV_Enum;
                end else begin
                  RunError(Self, ETypeMismatch);
                end;
              end;
{$IFDEF VARIANTSUPPORT}
            CSV_Variant: begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then begin
                    DestroyCajVariant(V1^.CV_Variant);
                    V1^.CV_Variant := nil;
                  end;
                end else begin
                  if v2^.VType^.atypeid = CSV_Variant then begin
                    DestroyCajVariant(V1^.CV_Variant);
                    V1^.CV_Variant := CopyVariant(v2^.CV_Variant);
                  end else begin
                    DestroyCajVariant(V1^.CV_Variant);
                    V1^.CV_Variant := CopyVariant(v2);
                  end;
                end;
              end;
{$ENDIF}
            CSV_Special: begin
                V1^.CV_Spec := v2^.CV_Spec;
              end;
            CSV_ProcVariable: begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then { nil }  begin
                    V1^.Cv_Proc := nil;
{$IFNDEF NOCLASSES}V1^.Cv_ProcSelf := nil;
{$ENDIF}
                  end;
                end else if V1^.VType <> v2^.VType then begin
                  if v2^.VType^.Ext = nil then begin
                    if not assigned(v2^.Cv_Proc) then begin
                      RunError(Self, ETypeMismatch);
                      Err := True;
                    end else begin
                      if {$IFNDEF NOCLASSES}(PIFSProcType(V1^.VType^.Ext)^.Method = (PProcedure(v2^.Cv_Proc)^.ClassType = nil)) or {$ENDIF}
                      (PIFSProcType(V1^.VType^.Ext)^.Decl <> PProcedure(v2^.Cv_Proc)^.Decl) then begin
                        RunError(Self, ETypeMismatch);
                        Err := True;
                      end else begin
                        V1^.Cv_Proc := v2^.Cv_Proc;
{$IFNDEF NOCLASSES}V1^.Cv_ProcSelf := v2^.Cv_ProcSelf;
{$ENDIF}
                      end;
                    end;
                  end else begin
                    RunError(Self, ETypeMismatch);
                    Err := True;
                  end;
                end else begin
                  V1^.Cv_Proc := v2^.Cv_Proc;
{$IFNDEF NOCLASSES}V1^.Cv_ProcSelf := v2^.Cv_ProcSelf;
{$ENDIF}
                end;
              end;
            CSV_UByte: V1^.Cv_UByte := GetInteger(v2);
            CSV_SByte: V1^.Cv_SByte := GetInteger(v2);
            CSV_Char: begin
                V1^.Cv_Str := GetString(v2);
                if Length(V1^.Cv_Str) <> 1 then begin
                  Err := True;
                  RunError(Self, ETypeMismatch);
                end else
                  V1^.Cv_Char := V1^.Cv_Str[1];
              end;
            CSV_UInt16: V1^.Cv_UInt16 := GetInteger(v2);
            CSV_SInt16: V1^.Cv_SInt16 := GetInteger(v2);
            CSV_UInt32: V1^.Cv_UInt32 := GetInteger(v2);
            CSV_SInt32: V1^.Cv_SInt32 := GetInteger(v2);
            CSV_String: V1^.Cv_Str := GetString(v2);
            CSV_Real: V1^.CV_Real := GetReal(v2);
            CSV_Single: V1^.CV_Single := GetReal(v2);
            CSV_Double: V1^.CV_Double := GetReal(v2);
            CSV_Extended: V1^.Cv_Extended := GetReal(v2);
            CSV_Comp: V1^.CV_comp := GetReal(v2);
{$IFNDEF NOCLASSES}
            CSV_ExternalObject: begin
                if V2^.VType^.atypeid = CSV_Special then begin
                  V1^.CV_ExternalObject := nil;
                end else if not TIfsExtClass(V1^.VType^.ext).IsCompatibleWith(v2^.VType) then begin
                  Err := True;
                  RunError(Self, ETypeMismatch);
                end else 
                  V1^.CV_ExternalObject := v2^.CV_ExternalObject;
              end;
{$ENDIF}
            CSV_Bool: begin
                if v2^.VType^.atypeid = CSV_Bool then
                  V1^.Cv_Bool := v2^.Cv_Bool
                else begin
                  Err := True;
                  RunError(Self, ETypeMismatch);
                end;
              end;
            CSV_Record: begin
                for I := 0 to Longint(V1^.CV_RecItems.Count) - 1 do begin
                  if not Perform(V1^.CV_RecItems.GetItem(I), v2^.CV_RecItems.GetItem(I), PtSet) then begin
                    Err := True;
                    RunError(Self, ETypeMismatch);
                  end;
                end;
              end;
{$IFNDEF NOCLASSES}
            CSV_Class: begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then { nil }  begin
                    V1^.CV_Class := nil;
                  end;
                end else
                  if not assigned(v2^.CV_Class) then begin
                    V1.CV_Class := nil;
                  end else
                    if IsSameClassFamily(V1^.VType^.Ext, v2^.CV_Class^.ClassType^.Ext, False) then begin
                      V1^.CV_Class := v2^.CV_Class;
                    end else begin
                      Err := True;
                      RunError(Self, ETypeMismatch);
                    end;
              end;
{$ENDIF}
            CSV_Array: begin
                for I := 0 to Longint(V1^.CV_ArrItems.Count) - 1 do begin
                  DestroyCajVariant(V1^.CV_ArrItems.GetItem(I));
                end;
                V1^.CV_ArrItems.Clear;
                for I := 0 to Longint(v2^.CV_ArrItems.Count) - 1 do begin
                  p := CreateCajVariant(PIfVariant(v2.CV_ArrItems.GetItem(I))^.VType);
                  V1^.CV_ArrItems.Add(p);
                  if not Perform(V1^.CV_ArrItems.GetItem(I), v2^.CV_ArrItems.GetItem(I), PtSet) then begin
                    Err := True;
                    RunError(Self, ETypeMismatch);
                    break;
                  end;
                end;
              end;
            CSV_Internal: begin
                V1^.Cv_Int1 := v2^.Cv_Int1;
                V1^.Cv_Int2 := v2^.Cv_Int2;
              end;
{$IFNDEF NOCLASSES}
            CSV_ClassRef: begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then { nil }  begin
                    V1^.Cv_ClassRef := nil;
                  end;
                end else

                  if IsSameClassFamily(V1^.VType^.Ext, v2^.VType^.Ext, True) then
                    V1^.Cv_ClassRef := v2^.Cv_ClassRef
                  else begin
                    RunError(Self, ETypeMismatch);
                    Err := True;
                  end;
              end;
{$ENDIF}
            CSV_Var: begin
                V1^.VType := v2^.VType;
                case v2^.VType^.atypeid of
                  CSV_Enum: V1^.CV_Enum := v2^.CV_Enum;
                  CSV_UByte: V1^.Cv_UByte := v2^.Cv_UByte;
                  CSV_SByte: V1^.Cv_SByte := v2^.Cv_SByte;
                  CSV_UInt16: V1^.Cv_UInt16 := v2^.Cv_UInt16;
                  CSV_SInt16: V1^.Cv_SInt16 := v2^.Cv_SInt16;
                  CSV_UInt32: V1^.Cv_UInt32 := v2^.Cv_UInt32;
                  CSV_SInt32: V1^.Cv_SInt32 := v2^.Cv_SInt32;
                  CSV_Char: V1^.Cv_Char := v2^.Cv_Char;
                  CSV_String: V1^.Cv_Str := v2^.Cv_Str;
                  CSV_Real: V1^.CV_Real := v2^.CV_Real;
                  CSV_Single: V1^.CV_Single := v2^.CV_Single;
                  CSV_Double: V1^.CV_Double := v2^.CV_Double;
                  CSV_Extended: V1^.Cv_Extended := v2^.Cv_Extended;
                  CSV_Comp: V1^.CV_comp := v2^.CV_comp;
                  CSV_Bool: V1^.Cv_Bool := v2^.Cv_Bool;
                  CSV_Variant: begin
                      if v2^.CV_Variant = nil then begin
                        V1^.VType := TM_Add(Types, '', CSV_Special, nil);
                        V1^.CV_Spec := 0;
                      end else begin
                        V1 := CopyVariant(v2);
                      end;
                    end;
                  CSV_Record: begin
                      V1^.CV_RecItems := TIfList.Create;
                      for I := 0 to Longint(v2^.CV_RecItems.Count) - 1 do begin
                        V1^.CV_RecItems.Add(CopyVariant(v2^.CV_RecItems.GetItem(I)));
                      end;
                    end;
                  CSV_ProcVariable: begin
                      if v2^.VType^.atypeid = CSV_Special then begin
                        if v2^.CV_Spec = 0 then { nil }  begin
                          V1^.Cv_Proc := nil;
{$IFNDEF NOCLASSES}V1^.Cv_ProcSelf := nil;
{$ENDIF}
                        end;
                      end else begin
{$IFNDEF NOCLASSES}
                        V1^.Cv_ProcSelf := v2^.Cv_ProcSelf;
{$ENDIF}
                        V1^.Cv_Proc := v2^.Cv_Proc;
                      end;
                    end;
                  CSV_Array: begin
                      V1^.CV_ArrItems := TIfList.Create;
                      for I := 0 to Longint(v2^.CV_ArrItems.Count) - 1 do begin
                        p := CreateCajVariant(PIfVariant(v2.CV_ArrItems.GetItem(I))^.VType);
                        V1^.CV_ArrItems.Add(p);
                        if not Perform(V1^.CV_ArrItems.GetItem(I), v2^.CV_ArrItems.GetItem(I), PtSet) then begin
                          Err := True;
                          RunError(Self, ETypeMismatch);
                          break;
                        end;
                      end;
                    end;
{$IFNDEF NOCLASSES}
                  CSV_Class: begin
                      if v2^.VType^.atypeid = CSV_Special then begin
                        if v2^.CV_Spec = 0 then { nil }  begin
                          V1^.CV_Class := nil;
                        end;
                      end else
                        V1^.CV_Class := v2^.CV_Class;
                    end;
                  CSV_ClassRef: begin
                      if v2^.VType^.atypeid = CSV_Special then begin
                        if v2^.CV_Spec = 0 then { nil }  begin
                          V1^.Cv_ClassRef := nil;
                        end;
                      end else

                        V1^.Cv_ClassRef := v2^.Cv_ClassRef;
                    end;
                  CSV_ExternalObject: begin
                      V1^.CV_ExternalObject := v2^.CV_ExternalObject;
                    end;
{$ENDIF}
                  CSV_Internal: begin
                      V1^.Cv_Int1 := v2^.Cv_Int1;
                      V1^.Cv_Int2 := v2^.Cv_Int2;
                    end;
                end;
              end;
          else begin
              RunError(Self, ETypeMismatch);
              Err := True;
            end;
          end;
      end;
    ptMinus: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UByte - GetReal(v2))
              else
                V1^.Cv_UByte := V1^.Cv_UByte - TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SByte - GetReal(v2))
              else
                V1^.Cv_SByte := V1^.Cv_SByte - TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt16 - GetReal(v2))
              else
                V1^.Cv_UInt16 := V1^.Cv_UInt16 - TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt16 - GetReal(v2))
              else
                V1^.Cv_SInt16 := V1^.Cv_SInt16 - TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt32 - GetReal(v2))
              else
                V1^.Cv_UInt32 := V1^.Cv_UInt32 - TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt32 - GetReal(v2))
              else
                V1^.Cv_SInt32 := V1^.Cv_SInt32 - TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Real: begin
              V1^.CV_Real := V1^.CV_Real - GetReal(v2);
            end;
          CSV_Single: begin
              V1^.CV_Single := V1^.CV_Single - GetReal(v2);
            end;
          CSV_Double: begin
              V1^.CV_Double := V1^.CV_Double - GetReal(v2);
            end;
          CSV_Extended: begin
              V1^.Cv_Extended := V1^.Cv_Extended - GetReal(v2);
            end;
          CSV_Comp: begin
              V1^.CV_comp := V1^.CV_comp - GetReal(v2);
            end;
        else begin
            RunError(Self, ETypeMismatch);
            Err := True;
          end;
        end { CASE };
      end;
    PtPlus: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UByte + GetReal(v2))
              else
                V1^.Cv_UByte := V1^.Cv_UByte + TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SByte + GetReal(v2))
              else
                V1^.Cv_SByte := V1^.Cv_SByte + TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt16 + GetReal(v2))
              else
                V1^.Cv_UInt16 := V1^.Cv_UInt16 + TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt16 + GetReal(v2))
              else
                V1^.Cv_SInt16 := V1^.Cv_SInt16 + TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt32 + GetReal(v2))
              else
                V1^.Cv_UInt32 := V1^.Cv_UInt32 + TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt32 + GetReal(v2))
              else
                V1^.Cv_SInt32 := V1^.Cv_SInt32 + TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Real: begin
              V1^.CV_Real := V1^.CV_Real + GetReal(v2);
            end;
          CSV_Single: begin
              V1^.CV_Single := V1^.CV_Single + GetReal(v2);
            end;
          CSV_Double: begin
              V1^.CV_Double := V1^.CV_Double + GetReal(v2);
            end;
          CSV_Extended: begin
              V1^.Cv_Extended := V1^.Cv_Extended + GetReal(v2);
            end;
          CSV_Comp: begin
              V1^.CV_comp := V1^.CV_comp + GetReal(v2);
            end;
          CSV_Char: begin
              MakeItString(V1^.Cv_Char + GetString(v2));
            end;
          CSV_String: begin
              V1^.Cv_Str := V1^.Cv_Str + GetString(v2);
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end { CASE };
      end;
    PtMul: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UByte * GetReal(v2))
              else
                V1^.Cv_UByte := V1^.Cv_UByte * TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SByte * GetReal(v2))
              else
                V1^.Cv_SByte := V1^.Cv_SByte * TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt16 * GetReal(v2))
              else
                V1^.Cv_UInt16 := V1^.Cv_UInt16 * TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt16 * GetReal(v2))
              else
                V1^.Cv_SInt16 := V1^.Cv_SInt16 * TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_UInt32 * GetReal(v2))
              else
                V1^.Cv_UInt32 := V1^.Cv_UInt32 * TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              if IsRealType(v2) then
                MakeItReal(V1^.Cv_SInt32 * GetReal(v2))
              else
                V1^.Cv_SInt32 := V1^.Cv_SInt32 * TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Real: begin
              V1^.CV_Real := V1^.CV_Real * GetReal(v2);
            end;
          CSV_Single: begin
              V1^.CV_Single := V1^.CV_Single * GetReal(v2);
            end;
          CSV_Double: begin
              V1^.CV_Double := V1^.CV_Double * GetReal(v2);
            end;
          CSV_Extended: begin
              V1^.Cv_Extended := V1^.Cv_Extended * GetReal(v2);
            end;
          CSV_Comp: begin
              V1^.CV_comp := V1^.CV_comp * GetReal(v2);
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end { CASE };
      end;
    ptDiv: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if GetReal(v2) = 0 then begin
          RunError(Self, EDivideByZero);
          Err := True;
        end else
          case V1^.VType^.atypeid of
            CSV_UByte: begin
                MakeItReal(V1^.Cv_UByte / GetReal(v2));
              end;
            CSV_SByte: begin
                MakeItReal(V1^.Cv_SByte / GetReal(v2));
              end;
            CSV_UInt16: begin
                MakeItReal(V1^.Cv_UInt16 / GetReal(v2));
              end;
            CSV_SInt16: begin
                MakeItReal(V1^.Cv_SInt16 / GetReal(v2));
              end;
            CSV_UInt32: begin
                MakeItReal(V1^.Cv_UInt32 / GetReal(v2));
              end;
            CSV_SInt32: begin
                MakeItReal(V1^.Cv_SInt32 / GetReal(v2));
              end;
            CSV_Real: begin
                V1^.CV_Real := V1^.CV_Real / GetReal(v2);
              end;
            CSV_Single: begin
                V1^.CV_Single := V1^.CV_Single / GetReal(v2);
              end;
            CSV_Double: begin
                V1^.CV_Double := V1^.CV_Double / GetReal(v2);
              end;
            CSV_Extended: begin
                V1^.Cv_Extended := V1^.Cv_Extended / GetReal(v2);
              end;
            CSV_Comp: begin
                V1^.CV_comp := V1^.CV_comp / GetReal(v2);
              end;
          else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          end { CASE };
      end; { begin }
    PtIntDiv: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if not IsIntegerType(v2) then begin
          RunError(Self, ETypeMismatch);
          Perform := False;
          exit;
        end;
        if GetInteger(v2) = 0 then begin
          RunError(Self, EDivideByZero);
          Perform := False;
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte div TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte div TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 div TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 div TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 div TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 div TCSV_SInt32(GetInteger(v2));
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    PtIntMod: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if not IsIntegerType(v2) then begin
          Perform := False;
          RunError(Self, ETypeMismatch);
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte mod TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte mod TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 mod TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 mod TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 mod TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 mod TCSV_SInt32(GetInteger(v2));
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    PtAnd: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if (not IsIntegerType(v2)) and (not ISBooleanType(v2)) then begin
          RunError(Self, ETypeMismatch);
          Perform := False;
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte and TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte and TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 and TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 and TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 and TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 and TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Bool: begin
              V1^.Cv_Bool := V1^.Cv_Bool and GetBoolean(v2);
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    ptOr: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if (not IsIntegerType(v2)) and (not ISBooleanType(v2)) then begin
          RunError(Self, ETypeMismatch);
          Perform := False;
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte or TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte or TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 or TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 or TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 or TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 or TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Bool: begin
              V1^.Cv_Bool := V1^.Cv_Bool or GetBoolean(v2);
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);

          end;
        end;
      end;
    ptXor: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if (not IsIntegerType(v2)) and (not ISBooleanType(v2)) then begin
          Perform := False;
          RunError(Self, ETypeMismatch);
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte xor TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte xor TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 xor TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 xor TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 xor TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 xor TCSV_SInt32(GetInteger(v2));
            end;
          CSV_Bool: begin
              V1^.Cv_Bool := V1^.Cv_Bool xor GetBoolean(v2);
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    PtShr: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if not IsIntegerType(v2) then begin
          Perform := True;
          RunError(Self, ETypeMismatch);
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte shr TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte shr TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 shr TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 shr TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 shr TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 shr TCSV_SInt32(GetInteger(v2));
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    PtShl: begin
{$IFDEF VARIANTSUPPORT}
        if V1^.VType^.atypeid = CSV_Variant then begin
          V1 := V1^.CV_Variant;
          if V1 = nil then begin
            Perform := False;
            RunError(Self, EVariantIsNil);
            exit;
          end;
          if v2^.VType^.atypeid = CSV_Variant then begin
            v2 := v2^.CV_Variant;
            if v2 = nil then begin
              Perform := False;
              RunError(Self, EVariantIsNil);
              exit;
            end;
          end;
        end;
{$ENDIF}
        if not IsIntegerType(v2) then begin
          Perform := True;
          RunError(Self, ETypeMismatch);
          exit;
        end;
        case V1^.VType^.atypeid of
          CSV_UByte: begin
              V1^.Cv_UByte := V1^.Cv_UByte shl TCSV_UByte(GetInteger(v2));
            end;
          CSV_SByte: begin
              V1^.Cv_SByte := V1^.Cv_SByte shl TCSV_SByte(GetInteger(v2));
            end;
          CSV_UInt16: begin
              V1^.Cv_UInt16 := V1^.Cv_UInt16 shl TCSV_UInt16(GetInteger(v2));
            end;
          CSV_SInt16: begin
              V1^.Cv_SInt16 := V1^.Cv_SInt16 shl TCSV_SInt16(GetInteger(v2));
            end;
          CSV_UInt32: begin
              V1^.Cv_UInt32 := V1^.Cv_UInt32 shl TCSV_UInt32(GetInteger(v2));
            end;
          CSV_SInt32: begin
              V1^.Cv_SInt32 := V1^.Cv_SInt32 shl TCSV_SInt32(GetInteger(v2));
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end;
      end;
    PtGreater: begin
{$IFDEF VARIANTSUPPORT}
        if (V1^.VType^.atypeid = CSV_Variant) and (V1^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
        if (v2^.VType^.atypeid = CSV_Variant) and (v2^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum > v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UByte > GetReal(v2))
            else
              MakeItBool(V1^.Cv_UByte > TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SByte > GetReal(v2))
            else
              MakeItBool(V1^.Cv_SByte > TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char then
              MakeItBool(V1^.Cv_Char > v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char > v2^.Cv_Str[1]);
            end else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          CSV_UInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt16 > GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt16 > TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt16 > GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt16 > TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt32 > GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt32 > TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt32 > GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt32 > TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real > GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single > GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double > GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended > GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp > GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool > v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str > v2^.Cv_Str);
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
    PtLess: begin
{$IFDEF VARIANTSUPPORT}
        if (V1^.VType^.atypeid = CSV_Variant) and (V1^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
        if (v2^.VType^.atypeid = CSV_Variant) and (v2^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum < v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UByte < GetReal(v2))
            else
              MakeItBool(V1^.Cv_UByte < TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SByte < GetReal(v2))
            else
              MakeItBool(V1^.Cv_SByte < TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char then
              MakeItBool(V1^.Cv_Char < v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char < v2^.Cv_Str[1]);
            end
            else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;

          CSV_UInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt16 < GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt16 < TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt16 < GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt16 < TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt32 < GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt32 < TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt32 < GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt32 < TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real < GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single < GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double < GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended < GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp < GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool < v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str < v2^.Cv_Str);
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
    PtGreaterEqual: begin
{$IFDEF VARIANTSUPPORT}
        if (V1^.VType^.atypeid = CSV_Variant) and (V1^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
        if (v2^.VType^.atypeid = CSV_Variant) and (v2^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum >= v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UByte >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UByte >= TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SByte >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SByte >= TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char then
              MakeItBool(V1^.Cv_Char >= v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char >= v2^.Cv_Str[1]);
            end
            else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          CSV_UInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt16 >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt16 >= TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt16 >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt16 >= TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt32 >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt32 >= TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt32 >= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt32 >= TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real >= GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single >= GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double >= GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended >= GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp >= GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool >= v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str >= v2^.Cv_Str);
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
    PtLessEqual: begin
{$IFDEF VARIANTSUPPORT}
        if (V1^.VType^.atypeid = CSV_Variant) and (V1^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
        if (v2^.VType^.atypeid = CSV_Variant) and (v2^.CV_Variant = nil) then begin
          Perform := False;
          RunError(Self, EVariantIsNil);
          exit;
        end;
{$ENDIF}
        case V1^.VType^.atypeid of
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum <= v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UByte <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UByte <= TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SByte <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SByte <= TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char then
              MakeItBool(V1^.Cv_Char <= v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char <= v2^.Cv_Str[1]);
            end
            else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          CSV_UInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt16 <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt16 <= TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt16 <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt16 <= TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt32 <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt32 <= TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt32 <= GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt32 <= TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real <= GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single <= GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double <= GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended <= GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp <= GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool <= v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str <= v2^.Cv_Str);
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
    PtEqual: begin
        case V1^.VType^.atypeid of
{$IFDEF VARIANTSUPPORT}
          CSV_Variant: begin
              if v2^.VType^.atypeid = CSV_Variant then begin
                if (V1^.CV_Variant = nil) or (v2^.CV_Variant = nil) then begin
                  MakeItBool(V1^.CV_Variant = v2^.CV_Variant);
                end else begin
                  Err := not Perform(V1^.CV_Variant, v2^.CV_Variant, t);
                end;
              end else begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then begin
                    MakeItBool(V1^.CV_Variant = nil);
                  end;
                end else if not assigned(V1^.CV_Variant) then begin
                  RunError(Self, EVariantIsNil);
                  Perform := False;
                  exit;
                end else
                  Err := not Perform(V1^.CV_Variant, v2, t);
              end;
            end;
{$ENDIF}
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum = v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UByte = GetReal(v2))
            else
              MakeItBool(V1^.Cv_UByte = TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SByte = GetReal(v2))
            else
              MakeItBool(V1^.Cv_SByte = TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char then
              MakeItBool(V1^.Cv_Char = v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char = v2^.Cv_Str[1]);
            end
            else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          CSV_UInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt16 = GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt16 = TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt16 = GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt16 = TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_UInt32 = GetReal(v2))
            else
              MakeItBool(V1^.Cv_UInt32 = TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2) then
              MakeItBool(V1^.Cv_SInt32 = GetReal(v2))
            else
              MakeItBool(V1^.Cv_SInt32 = TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real = GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single = GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double = GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended = GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp = GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool = v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str = v2^.Cv_Str);
          CSV_Special: MakeItBool(V1^.CV_Spec = v2^.CV_Spec);
{$IFNDEF NOCLASSES}
          CSV_Class: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.CV_Class = nil);
                end;
              end else
                MakeItBool(V1^.CV_Class = v2^.CV_Class);
            end;
          CSV_ClassRef: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.Cv_ClassRef = nil);
                end;
              end else
                MakeItBool(V1^.Cv_ClassRef = v2^.Cv_ClassRef);
            end;
          CSV_ExternalObject: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.CV_ExternalObject= nil);
                end;
              end else 
                MakeItBool(V1^.CV_ExternalObject = V2^.CV_ExternalObject);
            end;
{$ENDIF}
          CSV_ProcVariable: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.Cv_Proc = nil);
                end;
              end else
                MakeItBool((V1^.Cv_Proc = v2^.Cv_Proc){$IFNDEF NOCLASSES} and (V1^.Cv_ProcSelf = v2^.Cv_ProcSelf){$ENDIF});
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
    PtNotEqual: begin
        case V1^.VType^.atypeid of
{$IFDEF VARIANTSUPPORT}
          CSV_Variant: begin
              if v2^.VType^.atypeid = CSV_Variant then begin
                if (V1^.CV_Variant = nil) or (v2^.CV_Variant = nil) then begin
                  MakeItBool(V1^.CV_Variant <> v2^.CV_Variant);
                end else begin
                  Err := not Perform(V1^.CV_Variant, v2^.CV_Variant, t);
                end;
              end else begin
                if v2^.VType^.atypeid = CSV_Special then begin
                  if v2^.CV_Spec = 0 then begin
                    MakeItBool(V1^.CV_Variant <> nil);
                  end;
                end else if not assigned(V1^.CV_Variant) then begin
                  RunError(Self, EVariantIsNil);
                  Perform := False;
                  exit;
                end else
                  Err := not Perform(V1^.CV_Variant, v2, t);
              end;
            end;
{$ENDIF}
          CSV_Enum: begin
              if v2^.VType = V1^.VType then begin
                MakeItBool(V1^.CV_Enum <> v2^.CV_Enum);
              end else begin
                Err := True;
                RunError(Self, ETypeMismatch);
              end;
            end;
          CSV_UByte: if IsRealType(v2)
            then MakeItBool(V1^.Cv_UByte <> GetReal(v2))
            else MakeItBool(V1^.Cv_UByte <> TCSV_UByte(GetInteger(v2)));
          CSV_SByte: if IsRealType(v2)
            then MakeItBool(V1^.Cv_SByte <> GetReal(v2))
            else MakeItBool(V1^.Cv_SByte <> TCSV_SByte(GetInteger(v2)));
          CSV_Char: if v2^.VType^.atypeid = CSV_Char
            then MakeItBool(V1^.Cv_Char <> v2^.Cv_Char)
            else if (v2^.VType^.atypeid = CSV_String) and (Length(v2^.Cv_Str) = 1) then begin
              MakeItBool(V1^.Cv_Char <> v2^.Cv_Str[1]);
            end
            else begin
              Err := True;
              RunError(Self, ETypeMismatch);
            end;
          CSV_UInt16: if IsRealType(v2)
            then MakeItBool(V1^.Cv_UInt16 <> GetReal(v2))
            else MakeItBool(V1^.Cv_UInt16 <> TCSV_UInt16(GetInteger(v2)));
          CSV_SInt16: if IsRealType(v2)
            then MakeItBool(V1^.Cv_SInt16 <> GetReal(v2))
            else MakeItBool(V1^.Cv_SInt16 <> TCSV_SInt16(GetInteger(v2)));
          CSV_UInt32: if IsRealType(v2)
            then MakeItBool(V1^.Cv_UInt32 <> GetReal(v2))
            else MakeItBool(V1^.Cv_UInt32 <> TCSV_UInt32(GetInteger(v2)));
          CSV_SInt32: if IsRealType(v2)
            then MakeItBool(V1^.Cv_SInt32 <> GetReal(v2))
            else MakeItBool(V1^.Cv_SInt32 <> TCSV_SInt32(GetInteger(v2)));
          CSV_Real: MakeItBool(V1^.CV_Real <> GetReal(v2));
          CSV_Single: MakeItBool(V1^.CV_Single <> GetReal(v2));
          CSV_Double: MakeItBool(V1^.CV_Double <> GetReal(v2));
          CSV_Extended: MakeItBool(V1^.Cv_Extended <> GetReal(v2));
          CSV_Comp: MakeItBool(V1^.CV_comp <> GetReal(v2));
          CSV_Bool: MakeItBool(V1^.Cv_Bool <> v2^.Cv_Bool);
          CSV_String: MakeItBool(V1^.Cv_Str <> v2^.Cv_Str);
          CSV_Special: MakeItBool(V1^.CV_Spec <> v2^.CV_Spec);
{$IFNDEF NOCLASSES}
          CSV_Class: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.CV_Class <> nil);
                end;
              end else
                MakeItBool(V1^.CV_Class <> v2^.CV_Class);
            end;
          CSV_ClassRef: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.Cv_ClassRef <> nil);
                end;
              end else
                MakeItBool(V1^.Cv_ClassRef <> v2^.Cv_ClassRef);
            end;
          CSV_ExternalObject: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.CV_ExternalObject <> nil);
                end;
              end else if v2^.VType = v1^.VType then
                MakeItBool(V1^.CV_ExternalObject <> V2^.CV_ExternalObject);
            end;
{$ENDIF}
          CSV_ProcVariable: begin
              if v2^.VType^.atypeid = CSV_Special then begin
                if v2^.CV_Spec = 0 then { nil }  begin
                  MakeItBool(V1^.Cv_Proc <> nil);
                end;
              end else
                MakeItBool((V1^.Cv_Proc <> v2^.Cv_Proc){$IFNDEF NOCLASSES} or (V1^.Cv_ProcSelf <> v2^.Cv_ProcSelf){$ENDIF});
            end;
        else begin
            Err := True;
            RunError(Self, ETypeMismatch);
          end;
        end; {case item}
      end;
  end;
  Perform := not Err;
end;

//-------------------------------------------------------------------

function TIfPasScript.ReadType(Parser: TIfPascalParser; AllowClasses: Boolean; const Name: string): PTypeRec;
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
      if (Pos(p + ' ', CurrNames) = 1) or (Pos(' ' + p + ' ', CurrNames) <> 0) then
        IsDuplicate := True;
    end;
  begin
    Parser.Next;
    s := '';
    while Parser.CurrTokenId <> CSTII_End do begin
      CurrNames := '';
      repeat
        if Parser.CurrTokenId <> CSTI_Identifier then begin
          RunError(Self, EIdentifierExpected);
          ReadRecord := nil;
          exit;
        end;
        if IsDuplicate(Parser.GetToken) then begin
          RunError(Self, EDuplicateIdentifier);
          ReadRecord := nil;
          exit;
        end else
          CurrNames := CurrNames + Parser.GetToken + ' ';
        Parser.Next;
        if (Parser.CurrTokenId = CSTI_Comma) then begin
          Parser.Next;
        end else if (Parser.CurrTokenId = CSTI_Colon) then begin
          break;
        end else begin
          RunError(Self, EColonExpected);
          ReadRecord := nil;
          exit;
        end;
      until False;
      Parser.Next;
      Ex := ReadType(Parser, False, '');
      if Ex = nil then begin
        ReadRecord := nil;
        exit;
      end;
      if (Parser.CurrTokenId <> CSTI_Semicolon) and (Parser.CurrTokenId <> CSTII_End) then begin
        RunError(Self, ESemiColonExpected);
        ReadRecord := nil;
        exit;
      end;
      while Length(CurrNames) > 0 do begin
        s := s + copy(CurrNames, 1, Pos(' ', CurrNames) - 1) + ' ' + IntToStr(Longint(Ex)) + ' ';
        Delete(CurrNames, 1, Pos(' ', CurrNames));
      end;
      if Parser.CurrTokenId = CSTI_Semicolon then
        Parser.Next;
    end;
    Parser.Next;
    New(Exu);
    Exu^.u := s;
    ReadRecord := TM_Add(Types, Name, CSV_Record, Exu);
  end; // readclass
{$IFNDEF NOCLASSES}

  function ReadClass: PTypeRec;
  type
    TClassPlace = (cpPrivate, cpPublic, cpProtected);
  var
    I, Nc: PTypeRec;
    CurrPlace: TClassPlace;
    AllowVars: Boolean;

    Myclass: PIFSClassType;

    function CheckDuplicate(const s: string): Boolean;
    var
      u: string;
      I: Integer;

      function Rf(const s: string): string;
      begin
        Rf := copy(s, 2, Length(s) - 1);
      end;
    begin
      if s = 'SELF' then begin
        CheckDuplicate := True;
        exit;
      end;
      u := Myclass.Variables.u;
      while Length(u) > 0 do begin
        if Rf(Fw(u)) = s then begin
          CheckDuplicate := True;
          exit;
        end;
        Rfw(u);
        Rfw(u);
      end;
      for I := 0 to Longint(Myclass.Properties.Count) - 1 do begin
        if PPropertyDef(Myclass.Properties.GetItem(I))^.Name = s then begin
          CheckDuplicate := True;
          exit;
        end;
      end;
      for I := 0 to Longint(Myclass.Procedures.Count) - 1 do begin
        u := PProcedure(Myclass.Procedures.GetItem(I))^.Name;
        if Pos('!', u) = 1 then begin
          Delete(u, 1, 1);
          if s = u then begin
            CheckDuplicate := True;
            exit;
          end;
        end;
      end;
      CheckDuplicate := False;
    end;

    function AddProc: Boolean;
    var
      p: PProcedure;
      IsFunc: Boolean;
      t: PTypeRec;
      iv: Byte;
      vn: string;

      function CheckOverridable(InhClass: PTypeRec): Boolean;

        function SearchList(List: TIfList): Byte;
        var
          I: Integer;
          n: PProcedure;
        begin
          for I := 0 to Longint(List.Count) - 1 do begin
            n := List.GetItem(I);
            if n^.Name = p^.Name then begin
              if (n^.Decl = p^.Decl) and ((n^.Flags and not $30) = (p^.Flags and not $30)) and ((n^.Flags or $30) <> 0) then begin
                SearchList := 1;
                exit;
              end;
              SearchList := 2;
              exit;
            end;
          end;
          SearchList := 0;
        end; {searchlist}
      begin
        CheckOverridable := False;
        while assigned(InhClass) do begin
          case SearchList(PIFSClassType(InhClass^.Ext)^.Procedures) of
            0: InhClass := PIFSClassType(InhClass^.Ext)^.InheritsFrom;
            1: begin
                CheckOverridable := True;
                exit;
              end;
            2: exit;
          end; {case}
        end; {if}
      end; {checkoverridable}

      function PCheckDuplic(const n: string): Boolean;
      var
        u, a: string;
        l: Longint;
      begin
        PCheckDuplic := False;
        if n = p^.Name then PCheckDuplic := True else begin
          u := p^.Decl;
          while Length(u) > 0 do begin
            Delete(u, 1, 1);
            l := ms2i(u);
            a := copy(u, 5, l);
            Delete(u, 1, 8 + l);
            if a = n then begin
              PCheckDuplic := True;
              exit;
            end;
          end;
          u := vn;
          while Length(u) > 0 do begin
            a := Fw(u);
            Rfw(u); {remove name}
            if a = n then begin
              PCheckDuplic := True;
              exit;
            end;
          end;
        end;
      end;

    begin
      New(p);
      p^.FScriptEngine := Self;
      p^.Mode := 0;
      p^.offset := -1;
      p^.ClassType := Nc;
      case CurrPlace of
        cpPrivate: p^.Flags := $1;
        cpPublic: p^.Flags := $2;
        cpProtected: p^.Flags := $3;
      end;
      if Parser.CurrTokenId = CSTII_Constructor then begin
        IsFunc := False;
        p^.Flags := p^.Flags or $40
      end else if Parser.CurrTokenId = CSTII_Destructor then begin
        IsFunc := False;
        p^.Flags := p^.Flags or $80
      end else if Parser.CurrTokenId = CSTII_Function then begin
        IsFunc := True;
      end else
        IsFunc := False; {procedure}
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        Dispose(p);
        AddProc := False;
        exit;
      end;
      if CheckDuplicate(Parser.GetToken) then begin
        RunError(Self, EDuplicateIdentifier);
        AddProc := False;
        Dispose(p);
        exit;
      end;
      p^.Name := '!' + Parser.GetToken;
      Parser.Next;
      if Parser.CurrTokenId = CSTI_OpenRound then begin
        Parser.Next;
        if Parser.CurrTokenId = CSTI_CloseRound then begin
          Parser.Next;
        end else begin
          repeat
            if Parser.CurrTokenId = CSTII_Var then begin
              Parser.Next;
              iv := 1; {var}
            end else if Parser.CurrTokenId = CSTII_Const then begin
              Parser.Next;
              iv := 2; {const}
            end else iv := 0; {normal}
            if Parser.CurrTokenId <> CSTI_Identifier then begin
              RunError(Self, EIdentifierExpected);
              AddProc := False;
              Dispose(p);
              exit;
            end; {if}
            vn := '';
            if CheckDuplicate(Parser.GetToken) or PCheckDuplic(Parser.GetToken) then begin
              RunError(Self, EDuplicateIdentifier);
              AddProc := False;
              Dispose(p);
              exit;
            end;
            vn := Parser.GetToken;
            Parser.Next;
            while Parser.CurrTokenId = CSTI_Comma do begin
              Parser.Next;
              if Parser.CurrTokenId <> CSTI_Identifier then begin
                RunError(Self, EIdentifierExpected);
                AddProc := False;
                Dispose(p);
                exit;
              end; {if}
              if (CheckDuplicate(Parser.GetToken)) or PCheckDuplic(Parser.GetToken) then begin
                RunError(Self, EDuplicateIdentifier);
                AddProc := False;
                Dispose(p);
                exit;
              end; {if}
              vn := vn + ' ' + Parser.GetToken;
              Parser.Next;
            end; {while}
            if Parser.CurrTokenId <> CSTI_Colon then begin
              RunError(Self, EColonExpected);
              AddProc := False;
              Dispose(p);
              exit;
            end;
            Parser.Next;
            t := GetTypeLink(TM_Get(Types, Parser.GetToken));
            if t = nil then begin
              RunError2(Self, EUnknownIdentifier, Parser.GetToken);
              Dispose(p);
              AddProc := False;
              exit;
            end;
            if iv = 0 then begin
              while Length(vn) > 0 do begin
                p^.Decl := p^.Decl + #0 + mi2s(Length(Fw(vn))) + Fw(vn) + mi2s(Longint(t));
                Rfw(vn);
              end;
            end else if iv = 1 then begin {var}
              while Length(vn) > 0 do begin
                p^.Decl := p^.Decl + #1 + mi2s(Length(Fw(vn))) + Fw(vn) + mi2s(Longint(t));
                Rfw(vn);
              end;
            end else begin {const}
              while Length(vn) > 0 do begin
                p^.Decl := p^.Decl + #1 + mi2s(Length(Fw(vn))) + Fw(vn) + mi2s(Longint(t));
                Rfw(vn);
              end;
            end;
            Parser.Next;
            if Parser.CurrTokenId = CSTI_Semicolon then begin
              Parser.Next;
            end else
              if (Parser.CurrTokenId <> CSTI_CloseRound) then begin
                RunError(Self, ESemiColonExpected);
                Dispose(p);
                AddProc := False;
                exit;
              end else
                break;
          until False;
          Parser.Next;
        end;
      end;
      if IsFunc then begin
        if Parser.CurrTokenId <> CSTI_Colon then begin
          RunError(Self, EColonExpected);
          Dispose(p);
          AddProc := False;
          exit;
        end;
        Parser.Next;
        t := GetTypeLink(TM_Get(Types, Parser.GetToken));
        if t = nil then begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          Dispose(p);
          AddProc := False;
          exit;
        end;
        p^.Decl := mi2s(Longint(t)) + p^.Decl;
        Parser.Next;
      end else
        p^.Decl := mi2s(0) + p^.Decl;

      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        AddProc := False;
        Dispose(p);
        exit;
      end;
      Parser.Next;
      if Parser.CurrTokenId = CSTII_Virtual then begin
        p^.Flags := p^.Flags or $10;
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Semicolon then begin
          RunError(Self, ESemiColonExpected);
          AddProc := False;
          Dispose(p);
          exit;
        end;
        Parser.Next;
      end else if Parser.CurrTokenId = CSTII_Override then begin
        if not CheckOverridable(I) then begin
          RunError(Self, ECanNotOverride);
          AddProc := False;
          Dispose(p);
          exit;
        end;
        p^.Flags := p^.Flags or $20;
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Semicolon then begin
          RunError(Self, ESemiColonExpected);
          AddProc := False;
          Dispose(p);
          exit;
        end;
        Parser.Next;
      end;
      Procedures.Add(p);
      Myclass.Procedures.Add(p);
      AddProc := True;
    end; //addproc

    function AddVar: Boolean;

      procedure ReallyAddVar(const Name: string; FType: PTypeRec);
      begin
        case CurrPlace of
          cpPrivate: Myclass.Variables.u := Myclass.Variables.u + '1' + Name + ' ' + IntToStr(Longint(FType)) + ' ';
          cpPublic: Myclass.Variables.u := Myclass.Variables.u + '2' + Name + ' ' + IntToStr(Longint(FType)) + ' ';
          cpProtected: Myclass.Variables.u := Myclass.Variables.u + '3' + Name + ' ' + IntToStr(Longint(FType)) + ' ';
        end;
        Inc(Myclass.VarCount);
      end;
    var
      Vars: string;
      FType: PTypeRec;

      function IVarCheck(const s: string): Boolean;
      var
        u: string;
      begin
        u := Vars;
        while Length(u) > 0 do begin
          if Fw(u) = s then begin
            IVarCheck := True;
            exit;
          end;
          Rfw(u);
        end;
        IVarCheck := False;
      end;

    begin
      if CheckDuplicate(Parser.GetToken) or (IVarCheck(Parser.GetToken)) then begin
        RunError(Self, EDuplicateIdentifier);
        AddVar := False;
        exit;
      end; {if}
      Vars := Parser.GetToken;
      Parser.Next;
      while Parser.CurrTokenId = CSTI_Comma do begin
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Identifier then begin
          RunError(Self, EIdentifierExpected);
          AddVar := False;
          exit;
        end; {if}
        if CheckDuplicate(Parser.GetToken) or (IVarCheck(Parser.GetToken)) then begin
          RunError(Self, EDuplicateIdentifier);
          AddVar := False;
          exit;
        end; {if}
        Vars := Vars + ' ' + Parser.GetToken;
        Parser.Next;
      end; {if}
      if Parser.CurrTokenId <> CSTI_Colon then begin
        RunError(Self, EColonExpected);
        AddVar := False;
        exit;
      end; {if}
      Parser.Next;
      FType := ReadType(Parser, False, '');
      if FType = nil then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        AddVar := False;
        exit;
      end;
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        AddVar := False;
        exit;
      end;
      Parser.Next;
      while Length(Vars) > 0 do begin
        ReallyAddVar(Fw(Vars), FType);
        Rfw(Vars);
      end;
      AddVar := True;
    end; // addvar

    function AddProperty: Boolean;
    var
      p: PPropertyDef;
      proc: PProcedure;
      FType: PTypeRec;

      function FindProc(const Name: string): Boolean;
      var
        I: Integer;
      begin
        for I := 0 to Longint(Myclass.Procedures.Count) - 1 do begin
          if PProcedure(Myclass.Procedures.GetItem(I))^.Name = '!' + Name then begin
            proc := Myclass.Procedures.GetItem(I);
            FindProc := True;
            exit;
          end;
        end;
        FindProc := False;
      end;

      function CheckProc(read: Boolean): Boolean;
      var
        s: string;
      begin
        CheckProc := False;
        s := proc.Decl;
        if read then begin
          if ms2i(s) <> Longint(FType) then exit;
          Delete(s, 1, 4);
          if s <> '' then
            exit;
        end else begin
          if ms2i(s) <> 0 then
            exit;
          Delete(s, 1, 5);
          Delete(s, 1, ms2i(s) + 4);
          if Longint(FType) <> ms2i(s) then
            exit;
          Delete(s, 1, 4);
          if s <> '' then
            exit;
        end;
        CheckProc := True;
      end;

      function CheckVariable(const Name: string): Longint;
      var
        s: string;
        I: Integer;
      begin
        s := Myclass^.Variables.u;
        CheckVariable := -1;
        I := 0;
        while Length(s) > 0 do begin
          if copy(Fw(s), 2, Length(Fw(s)) - 1) = Name then begin
            Rfw(s);
            if Fw(s) <> IntToStr(Longint(FType)) then begin
              RunError(Self, ETypeMismatch);
              exit;
            end;
            CheckVariable := I;
            exit;
          end;
          Rfw(s);
          Rfw(s);
          Inc(I);
        end;
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
      end;
    begin
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        AddProperty := False;
        exit;
      end;
      New(p);
      if CheckDuplicate(Parser.GetToken) then begin
        RunError(Self, EDuplicateIdentifier);
        Dispose(p);
        AddProperty := False;
        exit;
      end;
      p^.Name := Parser.GetToken;
      case CurrPlace of
        cpPrivate: p^.CV_PropFlags := $10;
        cpPublic: p^.CV_PropFlags := $20;
        cpProtected: p^.CV_PropFlags := $30;
      end;
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Colon then begin
        RunError(Self, EColonExpected);
        Dispose(p);
        AddProperty := False;
        exit;
      end;
      Parser.Next;
      FType := GetTypeLink(TM_Get(Types, Parser.GetToken));
      p^.CV_Type := FType;

      if FType = nil then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        Dispose(p);
        AddProperty := False;
        exit;
      end;
      Parser.Next;
      if Parser.GetToken = 'READ' then begin
        Parser.Next;
        if FindProc(Parser.GetToken) then begin
          if not CheckProc(True) then begin
            RunError(Self, ETypeMismatch);
            Dispose(p);
            AddProperty := False;
            exit;
          end;
          p^.CV_PropFlags := p^.CV_PropFlags or 5;
          p^.CV_PropRead := proc;
        end else begin
          p.CV_PropRead := Pointer(CheckVariable(Parser.GetToken));
          if Longint(p^.CV_PropRead) = -1 then begin
            Dispose(p);
            AddProperty := False;
            exit;
          end;
          p^.CV_PropFlags := p^.CV_PropFlags or 1;
        end;
        Parser.Next;
      end;
      if Parser.GetToken = 'WRITE' then begin
        Parser.Next;
        if FindProc(Parser.GetToken) then begin
          if not CheckProc(False) then begin
            RunError(Self, ETypeMismatch);
            Dispose(p);
            AddProperty := False;
            exit;
          end;
          p^.CV_PropFlags := p^.CV_PropFlags or 10;
          p^.CV_PropWrite := proc;
        end else begin
          p.CV_PropWrite := Pointer(CheckVariable(Parser.GetToken));
          if Longint(p^.CV_PropWrite) = -1 then begin
            Dispose(p);
            AddProperty := False;
            exit;
          end;
          p^.CV_PropFlags := p^.CV_PropFlags or 2;
        end;
        Parser.Next;
      end;
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        Dispose(p);
        AddProperty := False;
        exit;
      end;
      Parser.Next;
      if (p^.CV_PropFlags and $3) = 0 then begin
        RunError(Self, ECanNotReadOrWriteProperty);
        Dispose(p);
        AddProperty := False;
        exit;
      end;
      AddProperty := True;
      Myclass.Properties.Add(p);
    end;
  begin
    CurrPlace := cpPublic;
    AllowVars := True; // No vars are allowed after a procedure definition
    Parser.Next;
    if Parser.CurrTokenId = CSTI_OpenRound then begin
      Parser.Next;
      I := GetTypeLink(TM_Get(Types, Parser.GetToken));
      if not assigned(I) then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        ReadClass := nil;
        exit;
      end; {if}
      if I.atypeid <> CSV_Class then begin
        RunError(Self, EClassTypeExpected);
        ReadClass := nil;
        exit;
      end; {if}
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_CloseRound then begin
        RunError(Self, ECloseRoundExpected);
        ReadClass := nil;
        exit;
      end; {if}
      Parser.Next;
    end else {if}  begin
      if Parser.CurrTokenId = CSTII_Of then begin
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Identifier then begin
          RunError(Self, EIdentifierExpected);
          ReadClass := nil;
          exit;
        end;
        I := GetTypeLink(TM_Get(Types, Parser.GetToken));
        if I^.atypeid <> CSV_Class then begin
          RunError(Self, EClassTypeExpected);
          ReadClass := nil;
          exit;
        end;
        ReadClass := TM_Add(Types, Name, CSV_ClassRef, I);
        exit;
      end;
      I := GetTypeLink(TM_Get(Types, 'TOBJECT'));
      if not assigned(I) then begin
        RunError(Self, EClassTypeExpected);
        ReadClass := nil;
        exit;
      end; {if}
    end; {else if}
    New(Myclass);
    Myclass^.InheritsFrom := I;
    Myclass^.VarNoStart := PIFSClassType(Myclass^.InheritsFrom^.Ext)^.VarNoStart + PIFSClassType(Myclass^.InheritsFrom^.Ext)^.VarCount;
    Myclass^.PropStart := PIFSClassType(Myclass^.InheritsFrom^.Ext)^.PropStart + PIFSClassType(Myclass^.InheritsFrom^.Ext)^.Properties.Count;
    Myclass^.VarCount := 0;
    Myclass^.Variables.u := '';
    Myclass^.Procedures := TIfList.Create;
    Myclass^.Properties := TIfList.Create;
    Nc := TM_Add(Types, Name, CSV_Class, Myclass);
    while Parser.CurrTokenId <> CSTII_End do begin
      if Parser.CurrTokenId = CSTII_Private then begin
        CurrPlace := cpPrivate;
        Parser.Next;
        AllowVars := True;
      end else if Parser.CurrTokenId = CSTII_Public then begin
        CurrPlace := cpPublic;
        Parser.Next;
        AllowVars := True;
      end else if Parser.CurrTokenId = CSTII_Published then begin
        CurrPlace := cpPublic;
        Parser.Next;
        AllowVars := True;
      end else if Parser.CurrTokenId = CSTII_Protected then begin
        CurrPlace := cpProtected;
        Parser.Next;
        AllowVars := True;
      end else if (Parser.CurrTokenId = CSTII_Property) then begin
        if not AddProperty then begin
          ReadClass := nil;
          exit;
        end;
      end else if (Parser.CurrTokenId = CSTII_Procedure) or
        (Parser.CurrTokenId = CSTII_Function) or
        (Parser.CurrTokenId = CSTII_Constructor) or
        (Parser.CurrTokenId = CSTII_Destructor) then begin
        if not AddProc then begin
          ReadClass := nil;
          exit;
        end;
        AllowVars := False;
      end else if Parser.CurrTokenId = CSTI_Identifier then begin
        if not AllowVars then begin
          RunError(Self, EEndExpected);
          ReadClass := nil;
          exit;
        end;
        if not AddVar then begin
          ReadClass := nil;
          exit;
        end;
      end else begin
        RunError(Self, EEndExpected);
        ReadClass := nil;
        exit;
      end;
    end;
    Parser.Next;
    ReadClass := Nc;
  end; {ReadClass}
{$ENDIF}

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
      while Length(u) > 0 do begin
        a := Fw(u);
        Rfw(u); {remove name}
        Rfw(u); {remove type}
        if Pos('!', a) = 1 then
          Delete(a, 1, 1);
        if a = n then begin
          PCheckDuplic := True;
          exit;
        end;
      end;
      u := vn;
      while Length(u) > 0 do begin
        a := Fw(u);
        Rfw(u); {remove name}
        if a = n then begin
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
    if Parser.CurrTokenId = CSTI_OpenRound then begin
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then begin
        Parser.Next;
      end else begin
        repeat
          if Parser.CurrTokenId = CSTII_Var then begin
            Parser.Next;
            iv := 1; {var}
          end else iv := 0; {normal}
          if Parser.CurrTokenId <> CSTI_Identifier then begin
            RunError(Self, EIdentifierExpected);
            Dispose(Data);
            exit;
          end; {if}
          vn := '';
          if PCheckDuplic(Parser.GetToken) then begin
            RunError(Self, EDuplicateIdentifier);
            Dispose(Data);
            exit;
          end;
          vn := Parser.GetToken;
          Parser.Next;
          while Parser.CurrTokenId = CSTI_Comma do begin
            Parser.Next;
            if Parser.CurrTokenId <> CSTI_Identifier then begin
              RunError(Self, EIdentifierExpected);
              Dispose(Data);
              exit;
            end; {if}
            if PCheckDuplic(Parser.GetToken) then begin
              RunError(Self, EDuplicateIdentifier);
              Dispose(Data);
              exit;
            end; {if}
            vn := vn + ' ' + Parser.GetToken;
            Parser.Next;
          end; {while}
          if Parser.CurrTokenId <> CSTI_Colon then begin
            RunError(Self, EColonExpected);
            Dispose(Data);
            exit;
          end;
          Parser.Next;
          t := GetTypeLink(TM_Get(Types, Parser.GetToken));
          if t = nil then begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            Dispose(Data);
            exit;
          end;
          if iv = 0 then begin
            while Length(vn) > 0 do begin
              Data^.Decl := Data^.Decl + #0 + mi2s(Length(Fw(vn))) + Fw(vn) + mi2s(Longint(t));
              Rfw(vn);
            end;
          end else
            if iv = 1 then begin
              while Length(vn) > 0 do begin
                Data^.Decl := Data^.Decl + #1 + mi2s(Length(Fw(vn))) + Fw(vn) + mi2s(Longint(t));
                Rfw(vn);
              end;
            end;
          Parser.Next;
          if Parser.CurrTokenId = CSTI_Semicolon then begin
            Parser.Next;
          end else
            if (Parser.CurrTokenId <> CSTI_CloseRound) then begin
              RunError(Self, ESemiColonExpected);
              Dispose(Data);
              exit;
            end else
              break;
        until False;
        Parser.Next;
      end;
    end;
    if Func then begin
      if Parser.CurrTokenId <> CSTI_Colon then begin
        RunError(Self, EColonExpected);
        Dispose(Data);
        exit;
      end;
      Parser.Next;
      t := GetTypeLink(TM_Get(Types, Parser.GetToken));
      if t = nil then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        Dispose(Data);
        exit;
      end;
      Data^.Decl := mi2s(Longint(t)) + Data^.Decl;
      Parser.Next;
    end else
      Data^.Decl := mi2s(0) + Data^.Decl;
{$IFNDEF NOCLASSES}
    if Parser.CurrTokenId = CSTII_Of then begin
      Parser.Next;
      if Parser.GetToken <> 'OBJECT' then begin
        RunError(Self, EObjectExpected);
        Dispose(Data);
        exit;
      end;
      Parser.Next;
      Data^.Method := True;
    end;
{$ENDIF}
    Result := TM_Add(Types, Name, CSV_ProcVariable, Data);
  end; // readprocedure

  function ReadEnum: PTypeRec;
  var
    VarName: string;
    p: PTypeRec;
    P2: PIfVariant;
    I: Longint;
  begin
    p := TM_Add(Types, Name, CSV_Enum, nil);
    ReadEnum := nil;
    Parser.Next; // skip CSTI_OpenRound
    I := 0;
    repeat
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end;
      VarName := Parser.GetToken;
      if IdentifierExists(True, nil, VarName) then begin
        RunError(Self, EDuplicateIdentifier);
        exit;
      end;
      P2 := Vm_Add(Variables, CreateCajVariant(p), VarName);
      P2^.CV_Enum := I;
      P2^.Flags := P2^.Flags or 1;
      I := I + 1;
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then break;
      if Parser.CurrTokenId <> CSTI_Comma then begin
        RunError(Self, ECloseRoundExpected);
        exit;
      end;
      Parser.Next;
    until False;
    Longint(p^.Ext) := I - 1; // max
    Parser.Next;
    ReadEnum := p;
  end;
begin
  if (Parser.CurrTokenId = CSTII_Procedure) or (Parser.CurrTokenId = CSTII_Function) then begin
    ReadType := ReadProcedure;
  end else if Parser.CurrTokenId = CSTI_OpenRound then begin
    ReadType := ReadEnum;
  end else {$IFNDEF NOCLASSES}if Parser.CurrTokenId = CSTII_Class then begin
      if not AllowClasses then begin
        RunError(Self, EClassNotAllowedHere);
        ReadType := nil;
        exit;
      end;
      ReadType := ReadClass;
    end else {$ENDIF}if Parser.CurrTokenId = CSTII_Array then begin
        Parser.Next;
        if Parser.CurrTokenId <> CSTII_Of then begin
          RunError(Self, EOfExpected);
          ReadType := nil;
          exit;
        end;
        Parser.Next;
        if Parser.CurrTokenId = CSTII_Const then begin
          ReadType := TM_Add(Types, Name, CSV_Array, TM_Add(Types, '', CSV_Var, nil));
          Parser.Next;
        end else begin
          Ex := ReadType(Parser, False, '');
          if Ex <> nil then
            ReadType := TM_Add(Types, Name, CSV_Array, Ex)
          else begin
            ReadType := nil;
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          end;
        end;
      end else if Parser.CurrTokenId = CSTII_Record then begin
        ReadType := ReadRecord;
      end else begin
        Ex := GetTypeLink(TM_Get(Types, Parser.GetToken));
        Parser.Next;
        if Ex = nil then begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          ReadType := nil;
          exit;
        end;
        if PTypeRec(Ex)^.Ident = '' then begin
          PTypeRec(Ex)^.Ident := Name;
          ReadType := Ex;

        end else begin
          if Name = '' then
            ReadType := Ex
          else
            ReadType := TM_Add(Types, Name, CSV_TypeCopy, Ex);
        end;
      end;
end;
//-------------------------------------------------------------------
{$IFNDEF NOCLASSES}

function TIfPasScript.AddClass(const Name, Decl: string; RegProc: Pointer): PTypeRec;
var
  p: PTypeRec;
  I: Integer;
  proc: PProcedure;
begin
  p := AddType(Name, Decl);
  if p = nil then begin
    AddClass := nil;
    exit;
  end;
  for I := 0 to Longint(PIFSClassType(p^.Ext)^.Procedures.Count) - 1 do begin
    proc := PIFSClassType(p^.Ext)^.Procedures.GetItem(I);
    proc^.Mode := 1;
    proc^.proc1 := RegProc;
  end;
  AddClass := p;
end;
{$ENDIF}
//-------------------------------------------------------------------

function TIfPasScript.AddTypeEx(Name: string): PTypeRec;
begin
  Result := TM_Add(Types, FastUppercase(Name), CSV_Var, nil);
end;
//-------------------------------------------------------------------

function TIfPasScript.AddType(const Name, Decl: string): PTypeRec;
var
  Parser: TIfPascalParser;
  E: TIFPARSERERROR;
  p: PTypeRec;
begin
  Parser := TIfPascalParser.Create;
  if not Parser.SetText(Decl, E) then begin
    AddType := nil;
    Parser.Free;
    exit;
  end;
  p := ReadType(Parser, True, FastUppercase(Name));
  if p = nil then begin
    AddType := nil;
    RunError(Self, ENoError);
  end else
    AddType := p;
  Parser.Free;
end; {AddType}
//-------------------------------------------------------------------

function TIfPasScript.GetIdentifier(WithList: TIfList; Vars: PVariableManager; Mode: Byte; var w: PIfVariant): Byte;
{
When it returns nil in W and Result = True then a procedure is called
that has no result.

returns:
  2: Successful returns variant that needs to be freed.
  1: Successful returns variant and need assignment.
  False: Not

}

  function GetRecordSubVar(p: PIfVariant; const Name: string): PIfVariant;
  var
    s: string;
    I: Integer;
  begin
    s := PIFSRecordType(p.VType.Ext)^.u;
    I := 0;
    while Length(s) > 0 do begin
      if Fw(s) = Name then begin
        GetRecordSubVar := p.CV_RecItems.GetItem(I);
        exit;
      end;
      Rfw(s); {Remove name}
      Rfw(s); {Remove type}
      Inc(I);
    end;
    GetRecordSubVar := nil;
  end;

var
{$IFNDEF NOCLASSES}
  TempType: PTypeRec;
  VM: PVariableManager;
  AL: Longint;
{$ENDIF}
  p: PProcedure;
  C, c2: PIfVariant;
  AssignmentNeeded: Boolean;
begin
  GetIdentifier := 0;
  AssignmentNeeded := False;
{$IFNDEF NOCLASSES}
  if Parser.CurrTokenId = CSTII_Inherited then begin
    if Mode <> 0 then begin
      RunError(Self, EVariableExpected);
      exit;
    end;
    if (GetCurrProc() = nil) or (GetCurrProc()^.ClassType = nil) then begin
      RunError(Self, ENoInheritedAllowedHere);
      exit;
    end;
    Parser.Next;
    if Parser.CurrTokenId = CSTI_Semicolon then begin
      if IntProcDefParam(GetCurrProc^.Decl, 0) <> 0 then begin
        C := CreateCajVariant(Pointer(IntProcDefParam(GetCurrProc^.Decl, 0)));
      end else
        C := nil;
      RunInherited(GetCurrProc, Vars, C);
      if FError.ErrorCode <> 0 then begin
        exit;
      end;
      DestroyCajVariant(C);
    end else begin
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end;
      if not GetClassProcedure(nil, GetCurrProc^.ClassType^.Ext, Parser.GetToken, p, True) then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        exit;
      end;
      p := GetInheritedProc(p);
      if not assigned(p) then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        exit;
      end;
      Parser.Next;
      w := DoProc(WithList, GetVarLink(Vm_Get(Vars, VM_Find(Vars, 'SELF')))^.CV_Class, p, Vars);
      if ErrorCode <> 0 then begin
        exit;
      end;
      if w = nil then begin
        GetIdentifier := 2;
        exit;
      end;
    end;
  end {CSTII_Inherited} else {$ENDIF}if Parser.CurrTokenId = CSTI_OpenRound then begin
      if Mode = 1 then begin
        RunError(Self, EVariableExpected);
        exit;
      end;
      Parser.Next;
      w := CreateVarType(nil);
      if not calc(WithList, Vars, w, CSTI_CloseRound, False) then begin
        DestroyCajVariant(w);
        exit;
      end;
      if Parser.CurrTokenId <> CSTI_CloseRound then begin
        RunError(Self, ECloseRoundExpected);
        DestroyCajVariant(w);
        exit;
      end;
      Parser.Next;
    end {CSTI_OpenRound} else if Parser.CurrTokenId = CSTI_Identifier then begin
{$IFNDEF NOCLASSES}
      w := nil;
      if WithList.Count > 0 then begin
        for AL := 0 to Longint(WithList.Count) - 1 do begin
          if GetVarLink(WithList.GetItem(AL))^.VType.atypeid = CSV_Class then begin
            if GetClassVariable2(GetVarLink(WithList.GetItem(AL))^.CV_Class, GetVarLink(WithList.GetItem(AL))^.VType^.Ext, Parser.GetToken, w, True) then begin
              AssignmentNeeded := True;
              Parser.Next;
              break;
            end else if GetClassProcedure(nil, GetVarLink(WithList.GetItem(AL))^.VType^.Ext, Parser.GetToken, p, True) then begin
              if Mode = 1 then begin
                RunError(Self, EVariableExpected);
                exit;
              end;
              Parser.Next;
              if Mode = 2 then begin
                w := CreateCajVariant(TM_Add(Types, '', CSV_ProcVariable, nil));
                w^.Cv_Proc := p;
                w^.Cv_ProcSelf := GetVarLink(WithList.GetItem(AL))^.CV_Class;
              end else begin
                if (p = GetCurrProc()) and (assigned(Vars)) and (IntProcDefParam(p^.Decl, 0) <> 0) and (Parser.CurrTokenId <> CSTI_OpenRound) then begin
                  w := Vm_Get(Vars, VM_Find(Vars, 'RESULT'));
                  AssignmentNeeded := True;
                end else begin
                  w := DoProc(WithList, GetVarLink(WithList.GetItem(AL))^.CV_Class, p, Vars);
                  if ErrorCode <> 0 then begin
                    exit;
                  end;
                end;
              end;
              if w = nil then begin
                GetIdentifier := 2;
                exit;
              end;
              break;
            end else w := nil;
          end else if GetVarLink(WithList.GetItem(AL))^.VType.atypeid = CSV_Record then begin
            w := GetRecordSubVar(GetVarLink(WithList.GetItem(AL)), Parser.GetToken);
            if w <> nil then begin
              Parser.Next;
              AssignmentNeeded := True;
            end;
          end;
        end;
      end;
      if not assigned(w) then
        if (TM_Get(Types, Parser.GetToken) <> nil) and not (PM_Find(Procedures, Parser.GetToken) <> -1) then begin
          if Mode = 1 then begin
            RunError(Self, EVariableExpected);
            exit;
          end;
          TempType := GetTypeLink(TM_Get(Types, Parser.GetToken));
          if TempType^.atypeid = CSV_Class then begin
            Parser.Next;
            if Parser.CurrTokenId = CSTI_Period then begin
              if Mode = 2 then begin
                RunError(Self, EVariableExpected);
                exit;
              end;
              Parser.Next;
              if Parser.CurrTokenId <> CSTI_Identifier then begin
                RunError(Self, EIdentifierExpected);
                exit;
              end;
              p := FindProc(TempType, '!' + Parser.GetToken);
              if p = nil then begin
                RunError2(Self, EUnknownIdentifier, Parser.GetToken);
                exit;
              end;
              w := DoClassConstructor(WithList, TempType, p, Vars);
              if FError.ErrorCode <> 0 then begin
                exit;
              end;
            end else if Parser.CurrTokenId = CSTI_OpenRound then begin
              Parser.Next;
              w := CreateCajVariant(TempType);
              if not calc(WithList, Vars, w, CSTI_CloseRound, False) then begin
                DestroyCajVariant(w);
                exit;
              end;
              if Parser.CurrTokenId <> CSTI_CloseRound then begin
                RunError(Self, ECloseRoundExpected);
                DestroyCajVariant(w);
                exit;
              end;
              Parser.Next;
            end else begin
              w := CreateCajVariant(TM_Add(Types, '', CSV_ClassRef, TempType));
              w^.Cv_ClassRef := TempType;
            end;
          end else if TempType^.atypeid = CSV_ExternalObject then begin
            if Mode = 2 then begin
              RunError(Self, EVariableExpected);
              exit;
            end;
            Parser.Next;
            if Parser.CurrTokenId <> CSTI_Period then begin
              RunError(Self, EPeriodExpected);
              exit;
            end;
            Parser.Next;
            if Parser.CurrTokenId <> CSTI_Identifier then begin
              RunError(Self, EPeriodExpected);
              exit;
            end;
            AL := TIfsExtClass(TempType^.Ext).FindClassProc(Parser.GetToken);
            if AL = -1 then begin
              RunError2(Self, EUnknownIdentifier, Parser.GetToken);
              exit;
            end;
            Parser.Next;
            VM := VM_Create;
            if not ReadParams(WithList, TIfsExtClass(TempType^.Ext).GetClassProcHeader(AL), Vars, VM) then begin
              VM_Destroy(VM);
              exit;
            end;
            w := TIfsExtClass(TempType^.Ext).CallClassProc(AL, VM);

            if FError.ErrorCode <> 0 then begin
              VM_Destroy(VM);
              w := nil;
              exit;
            end;
          end else begin
            RunError(Self, EClassTypeExpected);
            exit;
          end;
        end else {$ENDIF}if assigned(Vars) and (VM_Find(Vars, Parser.GetToken) <> -1) then begin
            AssignmentNeeded := True;
            w := Vm_Get(Vars, VM_Find(Vars, Parser.GetToken));
            Parser.Next;
          end else if VM_Find(Variables, Parser.GetToken) <> -1 then begin
            AssignmentNeeded := True;
            w := Vm_Get(Variables, VM_Find(Variables, Parser.GetToken));
            Parser.Next;
          end else if PM_Find(Procedures, Parser.GetToken) <> -1 then begin
            if Mode = 1 then begin
              RunError(Self, EVariableExpected);
              exit;
            end;
            p := PM_Get(Procedures, PM_Find(Procedures, Parser.GetToken));
            Parser.Next;
            if Mode = 2 then begin
              w := CreateCajVariant(TM_Add(Types, '', CSV_ProcVariable, nil));
              w^.Cv_Proc := p;
{$IFNDEF NOCLASSES}w^.Cv_ProcSelf := nil;
{$ENDIF}
            end else begin
              if (p = GetCurrProc()) and (assigned(Vars)) and (IntProcDefParam(p^.Decl, 0) <> 0) and (Parser.CurrTokenId <> CSTI_OpenRound) then begin
                w := Vm_Get(Vars, VM_Find(Vars, 'RESULT'));
                AssignmentNeeded := True;
              end else begin
                w := DoProc(WithList, {$IFNDEF NOCLASSES}nil, {$ENDIF}p, Vars);
                if ErrorCode <> 0 then begin
                  exit;
                end;
              end;
            end;
            if w = nil then begin
              GetIdentifier := 2;
              exit;
            end;
          end else begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            exit;
          end;
    end else begin
      RunError(Self, EIdentifierExpected);
      exit;
    end;
  if (Parser.CurrTokenId = CSTI_DEREFERENCE) and (w^.VType^.atypeid = CSV_ProcVariable) then begin
    if Mode <> 0 then begin
      if not AssignmentNeeded then DestroyCajVariant(w);
      RunError(Self, EVariableExpected);
      exit;
    end;
    Parser.Next;
    C := w;
    w := DoProc(WithList, {$IFNDEF NOCLASSES}w^.Cv_ProcSelf, {$ENDIF}w^.Cv_Proc, Vars);
    if not AssignmentNeeded then DestroyCajVariant(C);
    if ErrorCode <> ENoError then begin
      exit;
    end;
    if w = nil then begin
      GetIdentifier := 2;
      exit;
    end;
  end;
  while (Parser.CurrTokenId = CSTI_OpenBlock) or (Parser.CurrTokenId = CSTI_Period) do begin
    w := GetVarLink(w);
{$IFNDEF NOCLASSES}
    if (w^.VType^.atypeid = CSV_Property) then begin
      if Mode = 1 then begin
        if AssignmentNeeded then DestroyCajVariant(w);
        RunError(Self, EVariableExpected);
        exit;
      end;
      C := w;
      w := GetProperty(w);
      if not AssignmentNeeded then begin
        DestroyCajVariant(C);
      end;
      if w = nil then begin
        exit;
      end;
      AssignmentNeeded := False;
    end;
    if (w^.VType^.atypeid = CSV_ExternalObjectProperty) then begin
      if Mode = 1 then begin
        if AssignmentNeeded then DestroyCajVariant(w);
        RunError(Self, EVariableExpected);
        exit;
      end;
      C := w;
      if (not assigned(w^.CV_ExtObj)) then begin
        RunError(Self, EClassNotCreated);
        if AssignmentNeeded then DestroyCajVariant(C);
        exit;
      end;
      w := CreateCajVariant(TIfsExtClass(C^.VType^.ext).GetPropertyType(C^.CV_ExtObj, C^.CV_PropertyNo));
      if not TIfsExtClass(C^.VType^.ext).GetProperty(PIFSExternalObject(C^.CV_ExtObj), C^.CV_PropertyNo, w) then begin
        RunError(Self, ECanNotReadProperty);
        DestroyCajVariant(w);
        if AssignmentNeeded then DestroyCajVariant(C);
        exit;
      end;
      if not AssignmentNeeded then DestroyCajVariant(C);
      if w = nil then begin
        RunError(Self, ETypeMismatch);
        exit;
      end;
      AssignmentNeeded := False;
    end;
{$ENDIF}
    if Parser.CurrTokenId = CSTI_OpenBlock then begin
      Parser.Next;
      if not AssignmentNeeded then begin
        RunError(Self, ETypeMismatch);
        DestroyCajVariant(w);
        exit;
      end;
      while True do begin
        if w^.VType^.atypeid <> CSV_Array then begin
          RunError(Self, ETypeMismatch);
          exit;
        end; {if}
        C := CreateCajVariant(TM_Add(Types, '', CSV_SInt32, nil));
        if not calc(WithList, Vars, C, CSTI_CloseBlock, False) then begin
          DestroyCajVariant(C);
          exit;
        end; {if}
        w := w^.CV_ArrItems.GetItem(C^.Cv_SInt32);
        DestroyCajVariant(C);
        if w = nil then begin
          RunError(Self, EOutOfRange);
          exit;
        end;
        if Parser.CurrTokenId = CSTI_CloseBlock then begin
          Parser.Next;
          break;
        end;
        if Parser.CurrTokenId = CSTI_Comma then begin
          Parser.Next;
        end else begin
          RunError(Self, ECloseBlockExpected);
          exit;
        end;
      end;
    end else if Parser.CurrTokenId = CSTI_Period then begin
      Parser.Next;
      if w^.VType^.atypeid = CSV_Record then begin
        if Parser.CurrTokenId <> CSTI_Identifier then begin
          RunError(Self, EIdentifierExpected);
          exit;
        end;
        if AssignmentNeeded then begin
          w := GetRecordSubVar(w, Parser.GetToken);
          if w = nil then begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            exit;
          end;
          Parser.Next;
        end else begin
          c2 := w;
          w := GetRecordSubVar(w, Parser.GetToken);
          if w = nil then begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            DestroyCajVariant(c2);
            exit;
          end;
          Parser.Next;
        end;
      end{$IFNDEF NOCLASSES} else if w^.VType^.atypeid = CSV_Class then begin
        if Mode = 1 then begin
          if not AssignmentNeeded then DestroyCajVariant(w);
          RunError(Self, EVariableExpected);
          exit;
        end;
        if not assigned(w^.CV_Class) or (w^.CV_Class^.AlreadyFreed) then begin
          if not AssignmentNeeded then DestroyCajVariant(w);
          if not assigned(w^.CV_Class) then
            RunError(Self, EClassNotCreated)
          else
            RunError(Self, EClassAlreadyFreed);
          exit;
        end;
        if Mode = 1 then begin
          RunError(Self, EVariableExpected);
          if not AssignmentNeeded then DestroyCajVariant(C);
          exit;
        end;
        if not GetClassVariable2(w^.CV_Class, w^.VType^.Ext, Parser.GetToken, C, False) then begin
          if GetClassProcedure(w, w^.VType^.Ext, Parser.GetToken, p, False) then begin
            C := w;
            Parser.Next;
            if Mode = 2 then begin
              w := CreateCajVariant(TM_Add(Types, '', CSV_ProcVariable, nil));
              w^.Cv_Proc := p;
              w^.Cv_ProcSelf := C^.CV_Class;
              if not AssignmentNeeded then DestroyCajVariant(C);
              AssignmentNeeded := False;
            end else begin
              w := DoProc(WithList, w^.CV_Class, p, Vars);
              if not AssignmentNeeded then begin
                DestroyCajVariant(C);
              end;
              if ErrorCode <> 0 then begin
                exit;
              end else
                AssignmentNeeded := False;
            end;
            if w = nil then begin
              GetIdentifier := 2;
              exit;
            end;
          end else begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            if not AssignmentNeeded then DestroyCajVariant(C);
            exit;
          end;
        end else begin
          if not AssignmentNeeded then DestroyCajVariant(w);
          w := C;
          AssignmentNeeded := True;
          Parser.Next;
        end;
      end else if w^.VType^.atypeid = CSV_ClassRef then begin
        if w^.Cv_ClassRef = nil then begin
          RunError(Self, EClassReferenceNotAssigned);
          if not AssignmentNeeded then DestroyCajVariant(w);
          exit;
        end;
        if not GetClassProcedure(nil, w^.Cv_ClassRef^.Ext, Parser.GetToken, p, False) then begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          if not AssignmentNeeded then DestroyCajVariant(w);
          exit;
        end;
        if (p^.Flags and $40) = 0 then begin
          RunError(Self, EConstructorExpected);
          if not AssignmentNeeded then DestroyCajVariant(w);
          exit;
        end;
        C := w;
        w := DoClassConstructor(WithList, w^.Cv_ClassRef, p, Vars);
        if not AssignmentNeeded then DestroyCajVariant(C);
        if FError.ErrorCode <> 0 then begin
          exit;
        end;
        AssignmentNeeded := False;
      end else if w^.VType^.atypeid = CSV_ExternalObject then begin
        if Mode = 1 then begin
          if not AssignmentNeeded then DestroyCajVariant(w);
          RunError(Self, EVariableExpected);
          exit;
        end;
        if not assigned(w^.CV_ExternalObject) then begin
          RunError(Self, EClassNotCreated);
          if not AssignmentNeeded then DestroyCajVariant(w);
          exit;
        end;
        if TIfsExtClass(w^.VType^.ext).FindProperty(PIFSExternalObject(w^.CV_ExternalObject), Parser.GetToken) <> -1 then begin
          AL := TIfsExtClass(w^.VType^.ext).FindProperty(PIFSExternalObject(w^.CV_ExternalObject), Parser.GetToken);
          Parser.Next;
          C := w;
          w := CreateCajVariant(TM_Add(Types, '', CSV_ExternalObjectProperty, W^.VTYpe^.Ext));
          w^.CV_ExtObj := C^.CV_ExternalObject;
          w^.CV_PropertyNo := AL;
          if not AssignmentNeeded then DestroyCajVariant(C);
          AssignmentNeeded := False;
        end else if TIfsExtClass(w^.VType^.ext).FindProc(PIFSExternalObject(w^.CV_ExternalObject), Parser.GetToken) <> -1 then begin
          AL := TIfsExtClass(w^.VType^.ext).FindProc(PIFSExternalObject(w^.CV_ExternalObject), Parser.GetToken);
          VM := VM_Create;
          Parser.Next;
          if not ReadParams(WithList, TIfsExtClass(w^.VType^.ext).GetProcHeader(PIFSExternalObject(w^.CV_ExternalObject), AL), Vars, VM) then begin
            if not AssignmentNeeded then DestroyCajVariant(w);
            VM_Destroy(VM);
            exit;
          end;
          C := w;
          w := TIfsExtClass(w^.VType^.ext).CallProc(w^.CV_ExternalObject, AL, VM);
          if not AssignmentNeeded then DestroyCajVariant(C);
          AssignmentNeeded := False;
          VM_Destroy(VM);
          if w = nil then begin
            GetIdentifier := 2;
            exit;
          end;
        end else begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          if not AssignmentNeeded then DestroyCajVariant(w);
          exit;
        end;
      end{$ENDIF} else begin
        RunError(Self, ETypeMismatch);
      end;
    end else begin
      if not AssignmentNeeded then DestroyCajVariant(w);
      RunError(Self, ENotSupported);
      exit;
    end;
    if (Parser.CurrTokenId = CSTI_DEREFERENCE) and (w^.VType^.atypeid = CSV_ProcVariable) then begin
      if Mode <> 0 then begin
        if not AssignmentNeeded then DestroyCajVariant(w);
        RunError(Self, EVariableExpected);
        exit;
      end;
      Parser.Next;
      C := w;
      w := DoProc(WithList, {$IFNDEF NOCLASSES}w^.Cv_ProcSelf, {$ENDIF}w^.Cv_Proc, Vars);
      if not AssignmentNeeded then DestroyCajVariant(C);
      if ErrorCode <> ENoError then begin
        exit;
      end;
      if w = nil then begin
        GetIdentifier := 2;
        exit;
      end;
    end;
  end; {while}
  if AssignmentNeeded then
    GetIdentifier := 1
  else
    GetIdentifier := 2;
end; {GetIdentifier}
//-------s------------------------------------------------------------

function TIfPasScript.IdentifierExists(AlsoVariables: Boolean; SubVars: PVariableManager; const s: string): Boolean;
{ Check if an identifier exists }

  function UsesExists(s: string): Boolean;
  var
    I: Integer;
  begin
    UsesExists := False;
    for I := 0 to Longint(FUses.Count) - 1 do
      if FUses.GetItem(I) = s then begin
        UsesExists := True;
        break;
      end;
  end; { UsesExists }
begin
  IdentifierExists := False;
{$IFNDEF NOCLASSES}
  if s = 'SELF' then
    IdentifierExists := True
  else {$ENDIF}if UsesExists(s) then
      IdentifierExists := True
    else if PM_Find(Procedures, s) <> -1 then
      IdentifierExists := True
    else if AlsoVariables and (VM_Find(Variables, s) <> -1) then
      IdentifierExists := True
    else if TM_Get(Types, s) <> nil then
      IdentifierExists := True
    else if assigned(SubVars) and (VM_Find(SubVars, s) <> -1) then
      IdentifierExists := True
end; {IdentifierExists}

//-------------------------------------------------------------------

function TIfPasScript.GetPData(var Data: string): Boolean;
begin
  GetPData := Parser.GETDATA(Data);
end;
//-------------------------------------------------------------------

procedure TIfPasScript.SetText(const Data: string);
var
  E: TIFPARSERERROR;
begin
  if not Parser.SetText(Data, E) then begin
    case E.KIND of
      ICOMMENTERROR: RunError(Self, ECommentError);
      ISTRINGERROR: RunError(Self, EStringError);
      ICHARERROR: RunError(Self, ECharError);
    else
      RunError(Self, ESyntaxError);
    end;
    FError.ErrorPosition := E.Position;
    exit;
  end;
  LoadData;
end;

procedure TIfPasScript.SetPData(const Data: string);
begin
  if not Parser.SetData(Data) then begin
    RunError2(Self, ECustomError, 'Could not load PData');
    exit;
  end;
  LoadData;
end;

//-------------------------------------------------------------------

procedure TIfPasScript.LoadData;
{ Assign a text to the script engine, this also checks for uses and variables. }
var
  HaveHadProgram,
    HaveHadUnit,
    HaveHadUses: Boolean;

  function ProcessUses: Boolean;
  {Process Uses block}
  var
    I: Integer;
  begin
    ProcessUses := False;
    while Parser.CurrTokenId <> CSTI_EOF do begin
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end; {If}
      if IdentifierExists(True, nil, Parser.GetToken) then begin
        RunError(Self, EDuplicateIdentifier);
        exit;
      end; {If}
      FUses.Add(Parser.GetToken);
      if assigned(OnUses) then begin
        I := OnUses(fId, Self, Parser.GetToken);
        if I <> ENoError then begin
          RunError(Self, I);
          exit;
        end; {If}
      end {If}
      else begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        exit;
      end; {Else if}
      Parser.Next;
      if (Parser.CurrTokenId = CSTI_Semicolon) then begin
        Parser.Next;
        break;
      end {if}
      else if (Parser.CurrTokenId <> CSTI_Comma) then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end else {Else if}  begin
        Parser.Next;
      end;
    end;
    if Parser.CurrTokenId = CSTI_EOF then begin
      RunError(Self, EUnexpectedEndOfFile);
    end {If}
    else begin
      ProcessUses := True;
    end; {Else If}
  end; {ProcessUses}

  function DoFuncHeader: Boolean;
  var
    Ts, FuncName, CurrVar, FuncParam: string;
    CurrType: Pointer;
    FuncRes: Pointer;
    PT: Byte;
    Cp: PProcedure;
    Temp: PIfVariant;
  {$IFNDEF NOCLASSES}
    Myclass: PTypeRec;

    function GetclassProc: Boolean;
    var
      I: Integer;
      p: PProcedure;
    begin
      for I := 0 to Longint(PIFSClassType(Myclass.Ext)^.Procedures.Count) - 1 do begin
        p := PIFSClassType(Myclass.Ext)^.Procedures.GetItem(I);
        if (Pos('!', p^.Name) = 1) and (copy(p^.Name, 2, Length(p^.Name) - 1) = FuncName) then begin
          if (p^.Mode <> 0) or (p^.offset <> -1) then begin
            RunError(Self, EDuplicateIdentifier);
            Result := False;
            exit;
          end else begin
            Cp := p;
            Result := True;
            exit;
          end;
        end;
      end;
      RunError2(Self, EUnknownIdentifier, Parser.GetToken);
      Result := False;
    end;
  {$ENDIF}

    function MKString(const s: string): string;
    begin
      MKString := copy(s, 2, Length(s) - 2);
    end;

    function Duplic(s: string): Boolean;
    var
      s2, s3: string;
      I: Integer;
    begin
      if s = FuncName then begin
        Duplic := True;
        exit;
      end; {if}
      if (FuncRes <> nil) and (s = 'RESULT') then begin
        Duplic := True;
        exit;
      end;
      s2 := CurrVar;
      while Pos('|', s2) > 0 do begin
        if Pos('!', s2) = 1 then
          Delete(s2, 1, 1);
        if copy(s2, 1, Pos('|', s2) - 1) = s then begin
          Duplic := True;
          exit;
        end; {if}
        Delete(s2, 1, Pos('|', s2));
      end; {while}
      s2 := #0#0#0#0 + FuncParam;
      for I := 1 to IntProcDefParam(s2, -1) do begin
        s3 := IntProcDefName(s2, 0);
        if Pos('!', s2) = 1 then
          Delete(s2, 1, 1);
        if s3 = s then begin
          Duplic := True;
          exit;
        end; {if}
      end; {for}
      Duplic := False;
    end; {duplic}
  begin
    DoFuncHeader := False;
    if Parser.CurrTokenId = CSTII_Procedure then begin
      PT := 0;
      FuncRes := nil
    end else
      if Parser.CurrTokenId = CSTII_Constructor then begin
        PT := 2;
        FuncRes := nil
      end else
        if Parser.CurrTokenId = CSTII_Destructor then begin
          PT := 3;
          FuncRes := nil
        end else begin
          PT := 1;
          FuncRes := Pointer(1);
        end;
    Parser.Next;
    if Parser.CurrTokenId <> CSTI_Identifier then begin
      RunError(Self, EIdentifierExpected);
      exit;
    end; {if}
    Cp := nil;
    if IdentifierExists(True, nil, Parser.GetToken) then begin
{$IFNDEF NOCLASSES}
      Myclass := GetTypeLink(TM_Get(Types, Parser.GetToken));
      if not assigned(Myclass) or (Myclass^.atypeid <> CSV_Class) then begin
{$ENDIF}
        Cp := Procedures.GetItem(PM_Find(Procedures, Parser.GetToken));
        if (Cp^.Mode <> 0) or (Cp^.offset <> -1) then begin
          RunError(Self, EDuplicateIdentifier);
          exit;
        end;
{$IFNDEF NOCLASSES}
      end else begin
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Period then begin
          RunError(Self, EPeriodExpected);
          exit;
        end;
        Parser.Next;
      end;
{$ENDIF}
    end{$IFNDEF NOCLASSES} else Myclass := nil{$ENDIF}; {if}
    FuncName := Parser.GetToken;
{$IFNDEF NOCLASSES}
    if assigned(Myclass) then begin
      if not GetclassProc then
        exit;
      if ((Cp^.Flags and $40) <> 0) then begin
        if (PT <> 2) then begin
          RunError(Self, EParameterError);
          exit;
        end;
      end else if ((Cp^.Flags and $80) <> 0) then begin
        if (PT <> 3) then begin
          RunError(Self, EParameterError);
          exit;
        end;
      end else if (ms2i(Cp^.Decl) = 0) then begin
        if PT <> 0 then begin
          RunError(Self, EParameterError);
          exit;
        end;
      end else begin
        if PT <> 1 then begin
          RunError(Self, EParameterError);
          exit;
        end;
      end;
    end else begin
{$ENDIF}
      if (PT <> 0) and (PT <> 1) then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end;
{$IFNDEF NOCLASSES} end;
{$ENDIF}
    FuncParam := '';
    CurrVar := '';
    Parser.Next;
    if Parser.CurrTokenId = CSTI_OpenRound then begin
      Parser.Next;
      if Parser.CurrTokenId = CSTI_CloseRound then begin
        Parser.Next;
      end else begin
        while True do begin
          if Parser.CurrTokenId = CSTII_Var then begin
            CurrVar := '!';
            Parser.Next;
          end else {if}
            if Parser.CurrTokenId = CSTII_Const then begin
              CurrVar := '^';
              Parser.Next;
            end; {if}
          while True do begin
            if Parser.CurrTokenId <> CSTI_Identifier then begin
              RunError(Self, EIdentifierExpected);
              exit;
            end; {if}
            if IdentifierExists(True, nil, Parser.GetToken) or Duplic(Parser.GetToken)
              then begin
              RunError(Self, EDuplicateIdentifier);
              exit;
            end; {if}
            CurrVar := CurrVar + Parser.GetToken + '|';
            Parser.Next;
            if Parser.CurrTokenId = CSTI_Colon then
              break;
            if Parser.CurrTokenId <> CSTI_Comma then begin
              RunError(Self, ECommaExpected);
              exit;
            end; {if}
            Parser.Next;
          end; {while}
          Parser.Next;
          CurrType := ReadType(Parser, False, '');
          if CurrType = nil then begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            exit;
          end; {if}
          if Pos('^', CurrVar) = 1 then begin
            Delete(CurrVar, 1, 1);
            while Pos('|', CurrVar) > 0 do begin
              Ts := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
              FuncParam := FuncParam + #2 + mi2s(Length(Ts)) + Ts + mi2s(Longint(CurrType));
              Delete(CurrVar, 1, Pos('|', CurrVar));
            end; {while}
          end else if Pos('!', CurrVar) = 1 then begin
            Delete(CurrVar, 1, 1);
            while Pos('|', CurrVar) > 0 do begin
              Ts := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
              FuncParam := FuncParam + #1 + mi2s(Length(Ts)) + Ts + mi2s(Longint(CurrType));
              Delete(CurrVar, 1, Pos('|', CurrVar));
            end; {while}
          end else begin
            while Pos('|', CurrVar) > 0 do begin
              Ts := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
              FuncParam := FuncParam + #0 + mi2s(Length(Ts)) + Ts + mi2s(Longint(CurrType));
              Delete(CurrVar, 1, Pos('|', CurrVar));
            end; {while}
          end; {if}
          if Parser.CurrTokenId = CSTI_CloseRound then begin
            Parser.Next;
            break;
          end; {if}
          if Parser.CurrTokenId <> CSTI_Semicolon then begin
            RunError(Self, ESemiColonExpected);
            exit;
          end; {if}
          Parser.Next;
        end; {while}
      end; {else if}
    end; {if}
    if FuncRes <> nil then begin
      if Parser.CurrTokenId <> CSTI_Colon then begin
        RunError(Self, EColonExpected);
        exit;
      end;
      Parser.Next;
      FuncRes := ReadType(Parser, False, '');
      if FuncRes = nil then begin
        RunError2(Self, EUnknownIdentifier, Parser.GetToken);
        exit;
      end;
    end;
    FuncParam := mi2s(Longint(FuncRes)) + FuncParam;
    if Parser.CurrTokenId <> CSTI_Semicolon then begin
      RunError(Self, ESemiColonExpected);
      exit;
    end;
    Parser.Next;
    if assigned(Cp) then begin
      if Cp.Decl <> FuncParam then begin
        RunError(Self, EParameterError);
        exit;
      end; {if}
      Cp.offset := Parser.CurrTokenPos;
      if Parser.CurrTokenId = CSTII_Var then begin
        while (Parser.CurrTokenId <> CSTII_Begin) and (Parser.CurrTokenId <> CSTI_EOF) do
          Parser.Next;
      end;
      RunBegin(nil, nil, True);
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end;
      Parser.Next;
      DoFuncHeader := True;
    end else begin
      Cp := PM_AddInt(Procedures, Self, FuncName, FuncParam, {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, Parser.CurrTokenPos);
      if Parser.CurrTokenId = CSTII_External then begin
{$IFNDEF NOCLASSES}
        if assigned(Myclass) then begin
          RunError(Self, EBeginExpected);
          exit;
        end;
{$ENDIF}
        Parser.Next;
        if Parser.CurrTokenId = CSTI_Identifier then begin
          Temp := Vm_Get(Variables, VM_Find(Variables, Parser.GetToken));
          if Temp = nil then begin
            RunError2(Self, EUnknownIdentifier, Parser.GetToken);
            exit;
          end;
          if Temp^.VType^.atypeid <> CSV_String then begin
            RunError(Self, EStringExpected);
            exit;
          end;
          FuncParam := Temp^.Cv_Str;
          Parser.Next;
        end else if Parser.CurrTokenId = CSTI_String then begin
          FuncParam := MKString(Parser.GetToken);
          Parser.Next;
        end else begin
          RunError(Self, EStringExpected);
          exit;
        end;
        if Parser.CurrTokenId = CSTI_Identifier then begin
          if Parser.GetToken <> 'NAME' then begin
            RunError(Self, ESemiColonExpected);
            exit;
          end;
          Parser.Next;
          if Parser.CurrTokenId = CSTI_Identifier then begin
            Temp := Vm_Get(Variables, VM_Find(Variables, Parser.GetToken));
            if Temp = nil then begin
              RunError2(Self, EUnknownIdentifier, Parser.GetToken);
              exit;
            end;
            if Temp^.VType^.atypeid <> CSV_String then begin
              RunError(Self, EStringExpected);
              exit;
            end;
            FuncName := Temp^.Cv_Str;
            Parser.Next;
          end else if Parser.CurrTokenId = CSTI_String then begin
            FuncName := MKString(Parser.GetToken);
            Parser.Next;
          end else begin
            RunError(Self, EStringExpected);
            exit;
          end;
        end;
        if Parser.CurrTokenId <> CSTI_Semicolon then begin
          RunError(Self, ESemiColonExpected);
          exit;
        end;
        Parser.Next;
        if Parser.CurrTokenId = CSTI_Identifier then begin
          CurrVar := Parser.GetToken;
          Parser.Next; {skip that}
          if Parser.CurrTokenId <> CSTI_Semicolon then begin
            RunError(Self, ESemiColonExpected);
            exit;
          end;
          Parser.Next; {skip the semicolon}
        end else CurrVar := '';
        if @FOnExternal = nil then begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          exit;
        end;
        if not FOnExternal(fId, Self, FuncParam, FuncName, Cp, CurrVar) then begin
          RunError2(Self, EUnknownIdentifier, Parser.GetToken);
          exit;
        end;
        DoFuncHeader := True;
        exit;
      end else if Parser.CurrTokenId = CSTII_Forward then begin
{$IFNDEF NOCLASSES}
        if assigned(Myclass) then begin
          RunError(Self, EBeginExpected);
          exit;
        end;
{$ENDIF}
        Parser.Next;
        if Parser.CurrTokenId <> CSTI_Semicolon then begin
          RunError(Self, ESemiColonExpected);
          exit;
        end;
        Parser.Next;
        DoFuncHeader := True;
        Cp^.Mode := 0;
        Cp^.offset := -1;
        exit;
      end;
      if Parser.CurrTokenId = CSTII_Var then begin
        while (Parser.CurrTokenId <> CSTII_Begin) and (Parser.CurrTokenId <> CSTI_EOF) do
          Parser.Next;
      end;
      RunBegin(nil, nil, True);
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end;
      Parser.Next;
      DoFuncHeader := True;
    end;
  end; {DoFuncHeader}

  function ProcessTypes: Boolean;
  var
    Name: string;
    p: PTypeRec;
  begin
    ProcessTypes := False;
    Parser.Next;
    repeat
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end; {if}
      Name := Parser.GetToken;
      if IdentifierExists(True, nil, Name) then begin
        RunError(Self, EDuplicateIdentifier);
        exit;
      end; {if}
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Equal then begin
        RunError(Self, EIsExpected);
        exit;
      end;
      Parser.Next;
      p := ReadType(Parser, True, Name);
      if p = nil then begin
        exit;
      end;
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end;
      Parser.Next;
    until Parser.CurrTokenId <> CSTI_Identifier;
    ProcessTypes := True;
  end; {ProcessTypes}

  function CheckForwardProcs: Boolean;
  var
    I: Integer;
    p: PProcedure;
  begin
    for I := 0 to Longint(Procedures.Count) - 1 do begin
      p := Procedures.GetItem(I);
      if (p^.Mode = 0) and (p^.offset = -1) then begin
{$IFNDEF NOCLASSES}
        if p^.ClassType <> nil then
          RunError2(Self, EUnsatisfiedForward, p^.ClassType^.Ident + '.' + copy(p^.Name, 2, Length(p^.Name) - 1)) else
{$ENDIF}
          RunError2(Self, EUnsatisfiedForward, p^.Name);
        Result := False;
        exit;
      end;
    end;
    Result := True;
  end; {CheckClassProcs}
begin
  Cleanup;
  FISUnit := False;
  FModuleName := 'MAIN';
  FUses.Clear;
  VM_Clear(Variables);
  TM_Destroy(Types);
  Types := TM_Create;
  PM_Clear(Procedures);
  AddStandard;
  Vm_Add(Variables, CreateBool(True), 'TRUE')^.Flags := 1;
  Vm_Add(Variables, CreateBool(False), 'FALSE')^.Flags := 1;
  with Vm_Add(Variables, CreateCajVariant(TM_Add(Types, '', CSV_Special, nil)), 'NIL')^ do begin
    CV_Spec := 0;
    Flags := 1;
  end;
  FUses.Add('SYSTEM');
  if assigned(OnUses) then
    OnUses(fId, Self, 'SYSTEM');

  RunError(Self, ENoError);
  MainOffset := -1;
  HaveHadProgram := False;
  HaveHadUses := False;
  HaveHadUnit := False;
  while Parser.CurrTokenId <> CSTI_EOF do begin
    if (Parser.CurrTokenId = CSTII_Program) and (HaveHadProgram = False) and
      (HaveHadUses = False) and (HaveHadUnit = False) then begin
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end; {if}
      FModuleName := Parser.GetToken;
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end; {if}
      Parser.Next;
      HaveHadProgram := True;
    end else if (Parser.CurrTokenId = CSTII_UNIT) and (HaveHadProgram = False) and
      (HaveHadUses = False) and (HaveHadUnit = False) then begin
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end;
      FModuleName := Parser.GetToken;
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Semicolon then begin
        RunError(Self, ESemiColonExpected);
        exit;
      end; {if}
      Parser.Next;
      HaveHadUnit := True;
      FISUnit := True;
    end else if (Parser.CurrTokenId = CSTII_Uses) and (HaveHadUses = False) then begin
      Parser.Next;
      if not ProcessUses then
        exit;
      HaveHadUses := True;
    end {else if}
    else if (Parser.CurrTokenId = CSTII_Type) then begin
      if not ProcessTypes then
        exit;
    end
    else if (Parser.CurrTokenId = CSTII_Var) then begin
      if not ProcessVars(Variables) then
        exit;
    end {Else if}
    else if (Parser.CurrTokenId = CSTII_Const) then begin
      if not ProcessConsts(Variables) then
        exit;
    end
    else if (Parser.CurrTokenId = CSTII_Procedure) or
      (Parser.CurrTokenId = CSTII_Function) or
      (Parser.CurrTokenId = CSTII_Constructor) or
      (Parser.CurrTokenId = CSTII_Destructor) then begin
      if not DoFuncHeader then
        exit;
    end {else if}
    else if (Parser.CurrTokenId = CSTII_Begin) then begin
      if not CheckForwardProcs then
        exit;
      MainOffset := Parser.CurrTokenPos;
      exit;
    end {Else if}
    else if (Parser.CurrTokenId = CSTII_End) and FISUnit then begin
      if not CheckForwardProcs then
        exit;
      MainOffset := Parser.CurrTokenPos;
      exit;
    end { Else if}
    else if (Parser.CurrTokenId = CSTI_EOF) then begin
      RunError(Self, EUnexpectedEndOfFile);
    end {Else if}
    else begin
      RunError(Self, EBeginExpected);
      exit;
    end; {Else If}
  end; {While}
end; {SetText}

//-------------------------------------------------------------------

function TIfPasScript.ProcessConsts(Vars: PVariableManager): Boolean;
        { Process constants block (const s = '') }
var
  Name: string;
  Value: PIfVariant;
  WithList: TIfList;
begin
  ProcessConsts := False;
  Parser.Next;
  repeat
    if Parser.CurrTokenId <> CSTI_Identifier then begin
      RunError(Self, EIdentifierExpected);
      exit;
    end;
    Name := Parser.GetToken;
    if IdentifierExists(True, Vars, Name) then begin
      RunError(Self, EDuplicateIdentifier);
      exit;
    end;
    Parser.Next;
    if Parser.CurrTokenId <> CSTI_Equal then begin
      RunError(Self, EIsExpected);
      exit;
    end;
    Parser.Next;
    Value := CreateCajVariant(TM_Add(Types, '', CSV_Var, nil));
    Value^.CV_Var := nil;
    WithList := TIfList.Create;
    if not calc(WithList, Vars, Value, CSTI_Semicolon, True) then begin
      DestroyCajVariant(Value);
      DestroyWithList(WithList);
      exit;
    end;
    DestroyWithList(WithList);
    Value^.Flags := $1;
    Vm_Add(Vars, Value, Name);
    Parser.Next;
  until Parser.CurrTokenId <> CSTI_Identifier;
  ProcessConsts := True;
end;
//-------------------------------------------------------------------

function TIfPasScript.ProcessVars(Vars: PVariableManager): Boolean;
        { Process Vars block }
var
  Names: string;
  n: PTypeRec;

  function IsDuplic(n, s: string): Boolean;
  begin
    while Pos('|', n) > 0 do begin
      if copy(n, 1, Pos('|', n) - 1) = s then begin
        IsDuplic := True;
        exit;
      end;
      Delete(n, 1, Pos('|', n));
    end; {if}
    IsDuplic := False;
  end;
begin
  Parser.Next;
  ProcessVars := False;
  while True do begin
    case Parser.CurrTokenId of
      CSTI_EOF: begin
          RunError(Self, EUnexpectedEndOfFile);
          exit;
        end;
    end;
    if Parser.CurrTokenId <> CSTI_Identifier then begin
      RunError(Self, EIdentifierExpected);
      exit;
    end;
    if IdentifierExists(False, Vars, Parser.GetToken) then begin
      RunError(Self, EDuplicateIdentifier);
      exit;
    end; {if}

    Names := Parser.GetToken + '|';
    Parser.Next;
    while Parser.CurrTokenId = CSTI_Comma do begin
      Parser.Next;
      if Parser.CurrTokenId <> CSTI_Identifier then begin
        RunError(Self, EIdentifierExpected);
        exit;
      end; {if}
      if IsDuplic(Names, Parser.GetToken) or IdentifierExists(False, Vars, Parser.GetToken) then begin
        RunError(Self, EDuplicateIdentifier);
        exit;
      end; {if}
      Names := Names + Parser.GetToken + '|';
      Parser.Next;
    end; {while}
    if Parser.CurrTokenId <> CSTI_Colon then begin
      RunError(Self, EColonExpected);
      exit;
    end; {if}
    Parser.Next;
    n := ReadType(Parser, False, '');
    if n = nil then begin
      exit;
    end; {if}
    while Pos('|', Names) > 0 do begin
      Vm_Add(Vars, CreateCajVariant(n), copy(Names, 1, Pos('|', Names) - 1));
      Delete(Names, 1, Pos('|', Names));
    end; {if}
    if Parser.CurrTokenId <> CSTI_Semicolon then begin
      RunError(Self, ESemiColonExpected);
      exit;
    end; {if}
    Parser.Next;
    if Parser.CurrTokenId <> CSTI_Identifier then
      break;
  end; {while}
  ProcessVars := True;
end; {ProcessVars}

//-------------------------------------------------------------------

constructor TIfPasScript.Create(id: Pointer);
begin
  inherited Create;
  fId := id;
{$IFNDEF NOCLASSES}
  CreatedClasses := TIfList.Create;
{$ENDIF}
  FModuleName := 'MAIN';
  FISUnit := False;
  FMaxBeginNesting := High(Longint);
  FMaxArrayLength := High(Longint);

  Parser := TIfPascalParser.Create;
  FAttachedOnes := TIfList.Create;
  FUses := TIfStringList.Create;
  FAllocatedResources := TIfList.Create;
  RunError(Self, ENoError);
  MainOffset := -1;
  Procedures := PM_Create;
  Variables := VM_Create;
  Types := TM_Create;
  OnUses := nil;
  OnRunLine := nil;
  ProcStack := TIfList.Create;

end; {Create}
//-------------------------------------------------------------------

destructor TIfPasScript.Destroy;
begin
  Cleanup;
  Parser.Free;
  VM_Destroy(Variables);
  PM_Destroy(Procedures);
  TM_Destroy(Types);
  FAttachedOnes.Free;
  FAllocatedResources.Free;
  ProcStack.Free;
{$IFNDEF NOCLASSES}
  CreatedClasses.Free;
{$ENDIF}
  FUses.Free;
  inherited Destroy;
end; {Create}
//-------------------------------------------------------------------

function TIfPasScript.GetErrorCode: TIfPasScriptError;
begin
  GetErrorCode := FError.ErrorCode;
end;

function TIfPasScript.GetErrorPos: Longint;
begin
  GetErrorPos := FError.ErrorPosition;
end;

function TIfPasScript.GetErrorString: string;
begin
  GetErrorString := FError.ErrorParam;
end;

function TIfPasScript.GetErrorModule: string;
begin
  GetErrorModule := FError.ErrorModule;
end;

procedure TIfPasScript.RunError(SE: TIfPasScript; C: TIfPasScriptError);
begin
  if C = ENoError then begin
    FError.ErrorCode := C;
    FError.ErrorPosition := -1;
    FError.ErrorParam := '';
    FError.ErrorModule := '';
  end {if}
  else begin
    if FError.ErrorCode = ENoError then begin
      FError.ErrorCode := C;
      FError.ErrorPosition := SE.Parser.CurrTokenPos;
      FError.ErrorParam := '';
      FError.ErrorModule := SE.ModuleName;
    end;
  end; {else if}
end; {RunError}
//-------------------------------------------------------------------

procedure TIfPasScript.RunError2(SE: TIfPasScript; C: TIfPasScriptError; Ext: string);
begin
  if C = ENoError then begin
    FError.ErrorCode := C;
    FError.ErrorPosition := -1;
    FError.ErrorParam := '';
    FError.ErrorModule := '';
  end {if}
  else begin
    if FError.ErrorCode = ENoError then begin
      FError.ErrorCode := C;
      FError.ErrorPosition := SE.Parser.CurrTokenPos;
      FError.ErrorParam := Ext;
      FError.ErrorModule := SE.ModuleName;
    end;
  end; {else if}
end; {RunError2}

//-------------------------------------------------------------------
// Procedure: RunScript
//   Purpose: Process the script commands
//-------------------------------------------------------------------

procedure TIfPasScript.RunScript;
var
  WithList: TIfList;
begin
  ProcStack.Clear;
  CurrVars := nil;

  if MainOffset = -1 then exit;

  RunError(Self, ENoError); // Reset the error code and position
  Parser.CurrTokenPos := MainOffset; // Position for the next token
  //
  // RunBegin actually parses the script and expects a final period
  //-----------------
  WithList := TIfList.Create;
  if RunBegin(WithList, nil, False) then begin
    if Parser.CurrTokenId <> CSTI_Period then RunError(Self, EPeriodExpected);
  end;
  if FError.ErrorCode = EExitCommand then
    FError.ErrorCode := 0;
  DestroyWithList(WithList);
  FBeginNesting := 0;

end; {RunScript}
//-------------------------------------------------------------------
type
  PSmallCalculation = ^TSmallCalculation;
  TSmallCalculation = packed record
    TType: Byte;
                                  {
                                  0 = Variant

                                  2 = *
                                  3 = /
                                  4 = DIV
                                  5 = MOD
                                  6 = AND
                                  7 = SHR
                                  8 = SHL

                                  9 = +
                                  10 = -
                                  11 = OR
                                  12 = XOR

                                  13 = =
                                  14 = >
                                  15 = <
                                  16 = <>
                                  17 = <=
                                  18 = >=
                                  19 = AS
                                  20 = IS
                                  }
    CajVariant: PIfVariant;
  end;

function TIfPasScript.calc(WithList: TIfList; Vars: PVariableManager; res: PIfVariant; StopOn: TIfPasToken; OnlyConst: Boolean): Boolean;
{ Calculate an expression }
var
  Items: TIfList;
  PreCalc: string;
  temp4: PIfVariant;
  Work: PSmallCalculation;

  function ChrToStr(s: string): Char;
    {Turn a char intto a string}
  begin
    Delete(s, 1, 1); {First char : #}
    ChrToStr := Chr(StrToIntDef(s, 0));
  end;

  function PString(s: string): string;
    { remove the ' from the strings}
  begin
    s := copy(s, 2, Length(s) - 2);
    PString := s;
  end;

  function DoPrecalc: Boolean;
    {Pre calculate (- not +)}
  begin
    DoPrecalc := True;
    while Length(PreCalc) > 0 do begin
      if PreCalc[1] = '-' then begin
        if not DoMinus(Work^.CajVariant) then begin
          RunError(Self, ETypeMismatch);
          exit;
        end;
      end else if PreCalc[1] = '|' then begin
        if not DoNot(Work^.CajVariant) then begin
          RunError(Self, ETypeMismatch);
          exit;
        end;
      end else if PreCalc[1] = '+' then begin
        {plus has no effect}
      end else begin
        DoPrecalc := False;
        exit;
      end;
      Delete(PreCalc, 1, 1);
    end;
  end;

  procedure DisposeList;
    { Dispose the items }
  var
    I: Integer;
    p: PSmallCalculation;
  begin
    for I := 0 to Longint(Items.Count) - 1 do begin
      p := Items.GetItem(I);
      if p^.TType = 0 then
        DestroyCajVariant(p^.CajVariant);
      Dispose(p);
    end;
    Items.Destroy;
  end;

  function ParseString: string;
    { Parse a string }
  var
    temp3: string;
  begin
    temp3 := '';
    while (Parser.CurrTokenId = CSTI_String) or
      (Parser.CurrTokenId = CSTI_Char) do begin
      if Parser.CurrTokenId = CSTI_String
        then begin
        temp3 := temp3 + PString(Parser.GetToken);
        Parser.Next;
        if Parser.CurrTokenId = CSTI_String then
          temp3 := temp3 + #39;
      end {if}
      else begin
        temp3 := temp3 + ChrToStr(Parser.GetToken);
        Parser.Next;
      end; {else if}
    end; {while}
    ParseString := temp3;
  end;

  procedure Calculate;
    { Calculate the full expression }
  var
    l: PSmallCalculation;
    I: Longint;
  begin
    I := 0;
    while I < Longint(Items.Count - 1) div 2 do begin
      l := PSmallCalculation(Items.GetItem(I * 2 + 1));
      if ((l^.TType >= 2) and (l^.TType <= 8)) or (l^.TType = 19) then begin
        case l^.TType of
{$IFNDEF NOCLASSES}
          19: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptAs)
            then
              exit;
{$ENDIF}
          2: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtMul)
            then
              exit;
          3: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptDiv)
            then
              exit;
          4: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtIntDiv)
            then
              exit;
          5: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtIntMod)
            then
              exit;
          6: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtAnd)
            then
              exit;
          7: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtShr)
            then
              exit;
          8: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtShl)
            then
              exit;
        end;
        if ErrorCode <> 0 then
          exit;
        l := PSmallCalculation(Items.GetItem(I * 2 + 2));
        DestroyCajVariant(l^.CajVariant);
        Items.Remove(l);
        Dispose(l);
        l := PSmallCalculation(Items.GetItem(I * 2 + 1));
        Items.Remove(l);
        Dispose(l);
      end else Inc(I);
    end;

    I := 0;
    while I < Longint(Items.Count - 1) div 2 do begin
      l := PSmallCalculation(Items
        .GetItem(I * 2 + 1));
      if (l^.TType >= 9) and (l^.TType <= 12) then begin
        case l^.TType of
          9: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtPlus)
            then
              exit;
          10: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptMinus)
            then
              exit;
          11: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptOr)
            then
              exit;
          12: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptXor)
            then
              exit;
        end;
        if ErrorCode <> 0 then
          exit;
        l := PSmallCalculation(Items.GetItem(I * 2 + 2));
        DestroyCajVariant(l^.CajVariant);
        Items.Remove(l);
        Dispose(l);
        l := PSmallCalculation(Items
          .GetItem(I * 2 + 1));
        Items.Remove(l);
        Dispose(l);
      end else Inc(I);
    end;
    I := 0;
    while I < Longint(Items.Count - 1) div 2 do begin
      l := PSmallCalculation(Items.GetItem(I * 2 + 1));
      if ((l^.TType >= 13) and (l^.TType <= 18)) or (l^.TType = 20) then begin
        case l^.TType of
          13: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtEqual)
            then
              exit;
          14: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtGreater)
            then
              exit;
          15: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtLess)
            then
              exit;
          16: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtNotEqual)
            then
              exit;
          17: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtLessEqual)
            then
              exit;
          18: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, PtGreaterEqual)
            then
              exit;
{$IFNDEF NOCLASSES}
          20: if not Perform(PSmallCalculation(Items.GetItem(I * 2))^.
              CajVariant, PSmallCalculation(Items.GetItem(I * 2 + 2))
              ^.CajVariant, ptIs)
            then
              exit;
{$ENDIF}
        end;
        if ErrorCode <> 0 then
          exit;
        l := PSmallCalculation(Items.GetItem(I * 2 + 2));
        DestroyCajVariant(l^.CajVariant);
        Items.Remove(l);
        Dispose(l);
        l := PSmallCalculation(Items.GetItem(I * 2 + 1));
        Items.Remove(l);
        Dispose(l);
      end else Inc(I);
    end;
  end; {Calculate}

begin
  Items := TIfList.Create;
  calc := False;
  res := GetVarLink(res);
  while True do begin
    if Parser.CurrTokenId = StopOn then
      break;
    case Parser.CurrTokenId of
      CSTII_Else,
        CSTII_To,
        CSTII_DownTo,
        CSTII_do,
        CSTII_until,
        CSTI_Semicolon,
        CSTII_End,
        CSTI_Comma,
        CSTI_CloseRound: begin
          break;
        end; {Csti_Else...}
      CSTI_EOF: begin
          RunError(Self, EUnexpectedEndOfFile);
          DisposeList;
          exit;
        end; {CSTI_Eof}
    end; {case}
    if (Items.Count and $1) = 0 then begin
      PreCalc := '';
      while (Parser.CurrTokenId = CSTI_Minus) or
        (Parser.CurrTokenId = CSTII_Not) or
        (Parser.CurrTokenId = CSTI_Plus)
        do begin
        if (Parser.CurrTokenId = CSTI_Minus) then
          PreCalc := PreCalc + '-';
        if (Parser.CurrTokenId = CSTII_Not) then
          PreCalc := PreCalc + '|';
        if (Parser.CurrTokenId = CSTI_Plus) then
          PreCalc := PreCalc + '+';
        Parser.Next;
      end; {While}

      New(Work);
      case Parser.CurrTokenId of
        CSTI_AddressOf: begin
            Parser.Next;
            case GetIdentifier(WithList, Vars, 2, temp4) of
              0: begin
                  Dispose(Work);
                  DisposeList;
                  exit;
                end;
              1: begin
                  RunError(Self, ETypeMismatch);
                  Dispose(Work);
                  DisposeList;
                  exit;
                end;
              2: begin
                  if temp4^.VType^.atypeid <> CSV_ProcVariable then begin
                    RunError(Self, ETypeMismatch);
                    DestroyCajVariant(temp4);
                    Dispose(Work);
                    DisposeList;
                    exit;
                  end;
                end;
            end;
            Work^.CajVariant := temp4;
            Work^.TType := 0;
            Items.Add(Work);
          end;
        CSTI_OpenBlock: begin
            Parser.Next;
            if res^.VType^.atypeid = CSV_Array then begin
              Work^.CajVariant := CreateCajVariant(res^.VType);
              while True do begin
                temp4 := CreateCajVariant(res^.VType^.Ext);
                if not calc(WithList, Vars, temp4, CSTI_CloseBlock, False) then begin
                  DestroyCajVariant(temp4);
                  DestroyCajVariant(Work^.CajVariant);
                  Dispose(Work);
                  DisposeList;
                  exit;
                end;
                Work^.CajVariant^.CV_ArrItems.Add(temp4);
                if Parser.CurrTokenId = CSTI_CloseBlock then
                  break;
                if (Parser.CurrTokenId <> CSTI_Comma) then begin
                  RunError(Self, ECloseBlockExpected);
                  DestroyCajVariant(Work^.CajVariant);
                  Dispose(Work);
                  DisposeList;
                  exit;
                end;
                Parser.Next;
              end;
              Parser.Next;
              Work^.TType := 0;
              Items.Add(Work);
            end else begin
              RunError(Self, ETypeMismatch);
              Dispose(Work);
              DisposeList;
              exit;
            end;
          end;
        CSTI_OpenRound: begin
            Parser.Next;
            Work^.CajVariant := CreateCajVariant(TM_Add(Types, '', CSV_Var, nil));
            Work^.CajVariant^.CV_Var := nil;
            Work^.TType := 0;
            if not calc(WithList, Vars, Work^.CajVariant, CSTI_CloseRound, OnlyConst) then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            Parser.Next;
            Items.Add(Work);
          end; {CSTI_OpenRound}
        CSTII_Inherited,
          CSTI_Identifier: begin
            case GetIdentifier(WithList, Vars, 0, temp4) of
              0: begin
                  Dispose(Work);
                  DisposeList;
                  exit;
                end;
              1: Work^.CajVariant := CopyVariant(temp4);
              2: Work^.CajVariant := temp4;
            end;
            if Work^.CajVariant = nil then begin
              RunError(Self, ETypeMismatch);
              Dispose(Work);
              DisposeList;
              exit;
            end;
{$IFNDEF NOCLASSES}
            if Work^.CajVariant^.VType^.atypeid = CSV_Property then begin
              temp4 := GetProperty(Work^.CajVariant);
              DestroyCajVariant(Work^.CajVariant);
              if temp4 = nil then begin
                Dispose(Work);
                DisposeList;
                exit;
              end;
              Work^.CajVariant := temp4;
            end;
            if (Work^.CajVariant^.VType^.atypeid = CSV_ExternalObjectProperty) then begin
              temp4 := Work.CajVariant;
              if (not assigned(temp4^.CV_ExtObj)) then begin
                RunError(Self, EClassNotCreated);
                DestroyCajVariant(temp4);
                Dispose(Work);
                DisposeList;
                exit;
              end;
              Work^.CajVariant := CreateCajVariant(TIfsExtClass(temp4^.VType^.ext).GetPropertyType(PIFSExternalObject(temp4^.CV_ExtObj), temp4^.CV_PropertyNo));
              if not TIfsExtClass(temp4^.VType^.ext).GetProperty(PIFSExternalObject(temp4^.CV_ExtObj), temp4^.CV_PropertyNo, Work^.CajVariant) then begin
                RunError(Self, ECanNotReadProperty);
                DestroyCajVariant(Work^.CajVariant);
                DestroyCajVariant(temp4);
                Dispose(Work);
                DisposeList;
                exit;
              end;
              DestroyCajVariant(temp4);
              if Work^.CajVariant = nil then begin
                RunError(Self, ETypeMismatch);
                DestroyCajVariant(Work^.CajVariant);
                Dispose(Work);
                DisposeList;
                exit;
              end;
            end;
{$ENDIF}
            Work^.TType := 0;
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            Items.Add(Work);
          end; {CSTI_Identifier, CSTII_Inherited}
        CSTI_Integer: begin
            if ((res^.VType^.atypeid >= CSV_SByte) and (res^.VType^.atypeid <= CSV_SInt32)) { or
              ((res^.VType^.atypeid >= CSV_Real) and (res^.VType^.atypeid <= CSV_Comp)) }then
              Work^.CajVariant := CreateCajVariant(res^.VType)
            else
              Work^.CajVariant := CreateCajVariant(TM_Add(Types, '', CSV_SInt32, nil));
            Work^.TType := 0;
            if IsRealType(Work^.CajVariant) then
              SetReal(Work^.CajVariant, StrToIntDef(Parser.GetToken, 0))
            else
              SetInteger(Work^.CajVariant, StrToIntDef(Parser.GetToken, 0));
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            Parser.Next;
            Items.Add(Work);
          end; {CSTI_Integer}
        CSTI_Real: begin
            if (res^.VType^.atypeid >= CSV_Real) and (res^.VType^.atypeid <= CSV_Comp) then
              Work^.CajVariant := CreateCajVariant(res^.VType)
            else
              Work^.CajVariant := CreateCajVariant(TM_Add(Types, '', CSV_Extended, nil));
            Work^.TType := 0;
            SetReal(Work^.CajVariant, StrToReal(Parser.GetToken));
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end;
            Parser.Next;
            Items.Add(Work);
          end; {CSTI_Real}
        CSTI_String, CSTI_Char: begin

            Work^.CajVariant := CreateCajVariant(TM_Add(Types, '', CSV_String, nil));
            Work^.TType := 0;
            Work^.CajVariant^.Cv_Str := ParseString;
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            Items.Add(Work);
          end; {CSTI_String}
        CSTI_HexInt: begin
            Work^.TType := 0;
            if (res^.VType^.atypeid >= CSV_SByte) and (res^.VType^.atypeid <= CSV_SInt32) then
              Work^.CajVariant := CreateCajVariant(res^.VType)
            else
              Work^.CajVariant := CreateCajVariant(TM_Add(Types, '', CSV_SInt32, nil));
            SetInteger(Work^.CajVariant, StrToIntDef(Parser.GetToken, 0));
            if not DoPrecalc then begin
              DestroyCajVariant(Work^.CajVariant);
              Dispose(Work);
              DisposeList;
              exit;
            end; {if}
            Parser.Next;
            Items.Add(Work);
          end; {CSTI_HexInt}
      else begin
          RunError(Self, EErrorInExpression);
          Dispose(Work);
          DisposeList;
          exit;
        end;
      end; {case}
    end {if}
    else begin
      New(Work);
      case Parser.CurrTokenId of
        CSTI_Equal: Work^.TType := 13;
        CSTI_NotEqual: Work^.TType := 16;
        CSTI_Greater: Work^.TType := 14;
        CSTI_GreaterEqual: Work^.TType := 18;
        CSTI_Less: Work^.TType := 15;
        CSTI_LessEqual: Work^.TType := 17;
        CSTI_Plus: Work^.TType := 9;
        CSTI_Minus: Work^.TType := 10;
        CSTI_Divide: begin
            Work^.TType := 3;
            if res^.VType^.atypeid = CSV_Var then
              ChangeType(res, TM_Add(Types, '', CSV_Extended, nil));
          end;
        CSTI_Multiply: Work^.TType := 2;
        CSTII_and: Work^.TType := 6;
        CSTII_div: Work^.TType := 4;
        CSTII_mod: Work^.TType := 5;
        CSTII_or: Work^.TType := 11;
        CSTII_shl: Work^.TType := 8;
        CSTII_shr: Work^.TType := 7;
        CSTII_xor: Work^.TType := 12;
{$IFNDEF NOCLASSES}
        CSTII_As: Work^.TType := 19;
        CSTII_Is: Work^.TType := 20;
{$ENDIF}
      else begin
          RunError(Self, EErrorInExpression);
          Dispose(Work);
          DisposeList;
          exit;
        end; {else case}
      end; {case}
      Items.Add(Work);
      Parser.Next;
    end; {else if}
  end; {while}
  Calculate;
  if ErrorCode = 0 then begin
    if Longint(Items.Count) <> 1 then begin
      RunError(Self, EErrorInExpression);
      calc := False;
    end else begin
      Work := Items.GetItem(0);
      if Perform(res, Work^.CajVariant, PtSet) then
        calc := True
      else
        calc := False;
    end; {if}
  end; {if}
  DisposeList;
end; {Calc}

function TIfPasScript.MakeCompat(v: PIfVariant; FType: PTypeRec): Boolean;
var
  n: PIfVariant;
begin
  if v^.VType = FType then
    MakeCompat := True
  else if (v^.VType^.atypeid = CSV_Array) and (FType^.atypeid = CSV_Array) and (FType^.Ext = nil) then
    MakeCompat := True
  else begin
    n := CreateCajVariant(v^.VType);
    if not Perform(n, v, PtSet) then begin
      MakeCompat := False;
      DestroyCajVariant(n);
      exit;
    end;
    ChangeType(v, FType);
    if not Perform(v, n, PtSet) then begin
      MakeCompat := False;
      DestroyCajVariant(n);
      exit;
    end;
    DestroyCajVariant(n);
    MakeCompat := True;
  end;
end;
{$IFNDEF NOCLASSES}

function TIfPasScript.RunInherited(proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  u: PIfVariant;
  p: PVariableManager;
  I: Integer;
begin
  proc := GetInheritedProc(proc);
  p := VM_Create;
  for I := 0 to IntProcDefParam(proc^.Decl, -1) do begin
    Vm_Add(p, CopyVariant(Vm_Get(Params, 0)), '');
  end;
  VM_SetName(p, 0, 'SELF');
  u := RunScriptProc(proc, p);
  VM_Destroy(p);
  if FError.ErrorCode <> 0 then begin
    RunInherited := FError.ErrorCode;
  end else begin
    if assigned(u) then begin
      Perform(res, u, PtSet);
      DestroyCajVariant(u);
    end;
    RunInherited := 0;
  end;
end;
{$ENDIF}

function TIfPasScript.RunScriptProc(Func: PProcedure; Parameters: PVariableManager): PIfVariant;
{Call an internal/external Procedure}
var
  OldVars: PVariableManager;
  w: PIfVariant;
  I: Longint;
  WithList: TIfList;
{$IFNDEF NOCLASSES}SaveSelf: PIfVariant;
{$ENDIF}

  function IRem(s: string): string;
  {Remove the !}
  begin
    Delete(s, 1, 1);
    IRem := s;
  end; {irem}



  {$IFNDEF NOCLASSES}procedure AddSelf;
  var
    u: PIfVariant;
  begin
    SaveSelf := Vm_Get(Parameters, 0);
    if GetVarLink(SaveSelf)^.VType <> Func^.ClassType then begin
      u := CreateCajVariant(Func^.ClassType);
      u^.CV_Class := GetVarLink(SaveSelf)^.CV_Class;
      VM_Set(Parameters, 0, u);
    end;
  end;

  procedure RestoreSelf;
  begin
    if (SaveSelf <> Vm_Get(Parameters, 0)) and (Func^.ClassType <> nil) then begin
      DestroyCajVariant(Vm_Get(Parameters, 0));
      VM_Set(Parameters, 0, SaveSelf);
    end;
  end;
{$ENDIF}
begin
  RunScriptProc := nil;
  RunError(Self, ENoError); //reset
  if not assigned(Func) then begin
    FError.ErrorCode := EUnknownIdentifier;
    FError.ErrorPosition := -1;
    exit;
  end;
  if Func^.FScriptEngine <> Self then begin
    RunScriptProc := TIfPasScript(Func^.FScriptEngine).RunScriptProc(Func, Parameters);
    if TIfPasScript(Func^.FScriptEngine).ErrorCode <> 0 then begin
      RunError2(Func^.FScriptEngine, TIfPasScript(Func^.FScriptEngine).ErrorCode, TIfPasScript(Func^.FScriptEngine).ErrorString);
    end;
    exit;
  end;
{$IFNDEF NOCLASSES}
  if assigned(Func^.ClassType) then begin
    if (VM_Count(Parameters) = 0) or (VM_GetName(Parameters, 0) <> 'SELF') then begin
      FError.ErrorCode := EParameterError;
      FError.ErrorPosition := -1;
      exit;
    end;
    AddSelf;
    if IntProcDefParam(Func^.Decl, -1) <> VM_Count(Parameters) - 1 then begin
      FError.ErrorPosition := -1; { -1 means that the count is not the same }
      FError.ErrorCode := EParameterError;
      exit;
    end;
  end else {$ENDIF}begin
    if IntProcDefParam(Func^.Decl, -1) <> VM_Count(Parameters) then begin
      FError.ErrorPosition := -1; { -1 means that the count is not the same }
      FError.ErrorCode := EParameterError;
      exit;
    end;
  end;
  for I := 1 to IntProcDefParam(Func^.Decl, -1) do begin
{$IFNDEF NOCLASSES}
    if assigned(Func^.ClassType) then
      w := Vm_Get(Parameters, I)
    else
{$ENDIF}
      w := Vm_Get(Parameters, I - 1);
    if Pos('!', IntProcDefName(Func^.Decl, I)) = 1 then begin
      if (w^.VType^.atypeid <> CSV_Var) or (not assigned(w^.CV_Var)) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
{$IFNDEF NOCLASSES}RestoreSelf; {$ENDIF}
        exit;
      end;
      if (PIfVariant(w^.CV_Var)^.VType <> Pointer(IntProcDefParam(Func^.Decl, I))) and not ((PTypeRec(IntProcDefParam(Func^.Decl, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Array)) and not (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Var) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
{$IFNDEF NOCLASSES}RestoreSelf;{$ENDIF}
        exit;
      end;
{$IFNDEF NOCLASSES} if assigned(Func^.ClassType) then VM_SetName(Parameters, I, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I)))) else {$ENDIF}
        VM_SetName(Parameters, I - 1, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I))));
    end else if Pos('^', IntProcDefName(Func^.Decl, I)) = 1 then begin
      if (w^.VType^.atypeid <> CSV_Var) or (not assigned(w^.CV_Var)) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
{$IFNDEF NOCLASSES}RestoreSelf;
{$ENDIF}
        exit;
      end;
      if (PIfVariant(w^.CV_Var)^.VType <> Pointer(IntProcDefParam(Func^.Decl, I))) and not ((PTypeRec(IntProcDefParam(Func^.Decl, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Array))
        and not (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Var) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
{$IFNDEF NOCLASSES}RestoreSelf;
{$ENDIF}
        exit;
      end;
{$IFNDEF NOCLASSES}
      if assigned(Func^.ClassType) then
        VM_SetName(Parameters, I, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I))))
      else
{$ENDIF}
        VM_SetName(Parameters, I - 1, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I))));
      w^.Flags := w^.Flags or 1;
    end else begin
      if not MakeCompat(w, Pointer(IntProcDefParam(Func^.Decl, I))) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
{$IFNDEF NOCLASSES}RestoreSelf; {$ENDIF}
        exit;
      end;
{$IFNDEF NOCLASSES}if assigned(Func^.ClassType) then VM_SetName(Parameters, I, IntProcDefName(Func^.Decl, I)) else{$ENDIF}
      VM_SetName(Parameters, I - 1, IntProcDefName(Func^.Decl, I));
    end;
  end; {for}
  ProcStack.Add(Func);
  OldVars := CurrVars;
  CurrVars := Parameters;
  if Func^.Mode = 0 then begin
    if IntProcDefParam(Func^.Decl, 0) <> 0 then begin
      w := CreateCajVariant(Pointer(IntProcDefParam(Func^.Decl, 0)));
      Vm_Add(Parameters, w, 'RESULT');
    end {if}
    else w := nil;
    I := Parser.CurrTokenPos;
    Parser.CurrTokenPos := Func^.offset;
    if Parser.CurrTokenId = CSTII_Var then begin
      if not ProcessVars(Parameters) then begin
        DestroyCajVariant(w);
        if IntProcDefParam(Func^.Decl, 0) <> 0 then begin
          VM_Delete(Parameters, VM_Find(Parameters, 'RESULT'));
        end; {if}
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end; {if}
    end; {if}
    WithList := TIfList.Create;
  {$IFNDEF NOCLASSES}
    if assigned(Func^.ClassType) then begin
      WithList.Add(CreateVarType(Vm_Get(Parameters, 0)));
    end;
  {$ENDIF}
    if not RunBegin(WithList, Parameters, False) then begin
      if FError.ErrorCode = EExitCommand then
        FError.ErrorCode := 0
      else begin
        if IntProcDefParam(Func^.Decl, 0) <> 0 then begin
          VM_Delete(Parameters, VM_Find(Parameters, 'RESULT'));
        end; {if}
        DestroyCajVariant(w);
        DestroyWithList(WithList);
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
        PopProcStack;
        CurrVars := OldVars;

        exit;
      end;
    end; {if}
    DestroyWithList(WithList);
    if IntProcDefParam(Func^.Decl, 0) <> 0 then begin
      VM_Delete(Parameters, VM_Find(Parameters, 'RESULT'));
    end; {if}
    Parser.CurrTokenPos := I;
    RunScriptProc := w;
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
    RunError(Self, ENoError);
    PopProcStack;
    CurrVars := OldVars;
    exit;
  end {if}
  else if Func^.Mode = 1 then begin
    if IntProcDefParam(Func^.Decl, 0) <> 0 then
      w := CreateCajVariant(Pointer(IntProcDefParam(Func^.Decl, 0)))
    else
      w := nil;
  {$IFNDEF NOCLASSES}
    if assigned(Func^.ClassType) then
      RunError(Self, Func^.proc1(Func^.FScriptEngine, fId, Func, Parameters, w))
    else
  {$ENDIF}
      RunError(Self, Func^.proc1(Func^.FScriptEngine, fId, Func, Parameters, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        DestroyCajVariant(w);
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
        PopProcStack;
        CurrVars := OldVars;

        exit;
      end; {if}
    RunScriptProc := w;
  end
  else begin
    if IntProcDefParam(Func^.Decl, 0) <> 0 then
      w := CreateCajVariant(Pointer(IntProcDefParam(Func^.Decl, 0)))
    else
      w := nil;
  {$IFNDEF NOCLASSES}
    if assigned(Func^.ClassType) then
      RunError(Self, Func^.proc2(Func^.FScriptEngine, fId, Func, Parameters, w))
    else
  {$ENDIF}
      RunError(Self, Func^.proc2(Func^.FScriptEngine, fId, Func, Parameters, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        DestroyCajVariant(w);
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end; {if}
    RunScriptProc := w;
  end; {if}
  PopProcStack;
  CurrVars := OldVars;
  {$IFNDEF NOCLASSES}RestoreSelf;
  {$ENDIF}
end;
{$IFNDEF NOCLASSES}

function TIfPasScript.RunScriptConstructor(FType: PTypeRec; Func: PProcedure; Parameters: PVariableManager): PIfVariant;
{Call an internal/external constructor.
Note the first parameters must be a dummy one, something like:
VM_Add(Parameters, Nil, '');

And then the real parameters. This is because SELF must be the first
parameter but it is self-created.

}
var
  OldVars: PVariableManager;
  slf, w: PIfVariant;
  WithList: TIfList;
  I: Longint;
  CC: PCreatedClass;

  function IRem(s: string): string;
  {Remove the !}
  begin
    Delete(s, 1, 1);
    IRem := s;
  end; {irem}

  procedure CreateVars;
  var
    I, AA: Longint;
    C: PIFSClassType;
    s, Name: string;
    u: PTypeRec;
    n: PIfVariant;
    tmpv: PIFNamedVariable;

    function CreateProperty(p: PPropertyDef): PCajvariant;
    var
      prop: PCajvariant;
    begin
      prop := CreateCajVariant(TM_Add(Types, '', CSV_Property, p^.CV_Type));
      prop^.CV_Self := CC;
      prop^.CV_PropFlags := p^.CV_PropFlags;
      if (p^.CV_PropFlags and $5) = $1 then
        prop^.CV_PropRead := Vm_Get(CC^.Variables, Longint(p^.CV_PropRead))
      else
        prop^.CV_PropRead := p^.CV_PropRead;
      if (p^.CV_PropFlags and $A) = $2 then
        prop^.CV_PropWrite := Vm_Get(CC^.Variables, Longint(p^.CV_PropWrite))
      else
        prop^.CV_PropWrite := p^.CV_PropWrite;
      if (prop^.CV_PropFlags and $30) = $10 then
        prop^.Flags := prop^.Flags or 2
      else if (prop^.CV_PropFlags and $30) = $20 then
        prop^.Flags := prop^.Flags or 4
      else if (prop^.CV_PropFlags and $30) = $30 then
        prop^.Flags := prop^.Flags or 6;
      CreateProperty := prop;
    end;
  begin
    for I := 0 to (PIFSClassType(CC^.ClassType^.Ext)^.VarNoStart + PIFSClassType(CC^.ClassType^.Ext)^.VarCount) - 1 do begin
      PVariableManager(CC^.Variables).Add(nil);
    end;
    C := PIFSClassType(CC^.ClassType^.Ext);
    while assigned(C) do begin
      s := C^.Variables.u;
      I := C^.VarNoStart;
      while Length(s) > 0 do begin
        Name := Fw(s);
        Rfw(s);
        u := Pointer(StrToIntDef(Fw(s), 0));
        Rfw(s);
        n := CreateCajVariant(u);
        case Name[1] of
          '1': n^.Flags := $2;
          '2': n^.Flags := $4;
          '3': n^.Flags := $6;
        end;
        New(tmpv);
        tmpv^.fVar := n;
        Delete(Name, 1, 1);
        tmpv^.Name := Name;
        tmpv^.NameHash := mkhash(Name);
        PVariableManager(CC^.Variables).SetItem(I, tmpv);

        Inc(I);
      end; {while}
      if assigned(C^.InheritsFrom) then
        C := (C^.InheritsFrom^.Ext)
      else
        C := nil;
    end; {while}
    AA := VM_Count(CC^.Variables);
    C := PIFSClassType(CC^.ClassType^.Ext);
    for I := 0 to (PIFSClassType(CC^.ClassType^.Ext)^.PropStart + PIFSClassType(CC^.ClassType^.Ext)^.Properties.Count) - 1 do begin
      PVariableManager(CC^.Variables).Add(nil);
    end;
    while assigned(C) do begin
      for I := 0 to Longint(C^.Properties.Count) - 1 do begin
        New(tmpv);
        tmpv^.Name := '';
        tmpv^.NameHash := 1;
        tmpv^.fVar := CreateProperty(C^.Properties.GetItem(I));
        PVariableManager(CC^.Variables).SetItem(AA + Longint(C^.PropStart) + I, tmpv);
      end;
      if assigned(C^.InheritsFrom) then
        C := (C^.InheritsFrom^.Ext)
      else
        C := nil;
    end;
  end;

begin
  if Func^.FScriptEngine <> Self then begin
    RunScriptConstructor := TIfPasScript(Func^.FScriptEngine).RunScriptConstructor
      (FType, Func, Parameters);
    if TIfPasScript(Func^.FScriptEngine).ErrorCode <> 0 then begin
      RunError2(Func^.FScriptEngine, TIfPasScript(Func^.FScriptEngine).ErrorCode, TIfPasScript(Func^.FScriptEngine).ErrorString);
    end;

    exit;
  end;
  RunError(Self, ENoError);
  if (Func^.Flags and $40) = 0 then begin
    FError.ErrorCode := EConstructorExpected;
    RunScriptConstructor := nil;
    FError.ErrorPosition := 0;
    exit;
  end;
  New(CC);
  CC^.Variables := VM_Create;
  CC^.ClassType := FType;
  CreateVars;
  CC^.AlreadyFreed := False;
  CreatedClasses.Add(CC);
  slf := CreateCajVariant(FType);
  slf^.CV_Class := CC;
  DestroyCajVariant(Vm_Get(Parameters, 0));
  VM_Set(Parameters, 0, CreateCajVariant(Func^.ClassType));
  with Vm_Get(Parameters, 0)^ do begin
    CV_Class := slf^.CV_Class;
    Flags := 1;
  end;
  VM_SetName(Parameters, 0, 'SELF');
  RunScriptConstructor := nil;
  if not assigned(Func) then begin
    FError.ErrorCode := EUnknownIdentifier;
    DestroyCajVariant(slf);
    FError.ErrorPosition := -1;
    exit;
  end;
  if IntProcDefParam(Func^.Decl, -1) <> VM_Count(Parameters) - 1 then begin
    FError.ErrorPosition := -1; { -1 means that the count is not the same }
    DestroyCajVariant(slf);
    FError.ErrorCode := EParameterError;
    exit;
  end;
  for I := 1 to IntProcDefParam(Func^.Decl, -1) do begin
    w := Vm_Get(Parameters, I);
    if Pos('!', IntProcDefName(Func^.Decl, I)) = 1 then begin
      if (w^.VType^.atypeid <> CSV_Var) or (not assigned(w^.CV_Var)) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
        DestroyCajVariant(slf);
        exit;
      end;
      if (PIfVariant(w^.CV_Var)^.VType <> Pointer(IntProcDefParam(Func^.Decl, I))) and not ((PTypeRec(IntProcDefParam(Func^.Decl, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Array))
        and not (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Var) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
        DestroyCajVariant(slf);
        exit;
      end;
      VM_SetName(Parameters, I, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I))))
    end else if Pos('^', IntProcDefName(Func^.Decl, I)) = 1 then begin
      if (w^.VType^.atypeid <> CSV_Var) or (not assigned(w^.CV_Var)) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
        DestroyCajVariant(slf);
        exit;
      end;
      if (PIfVariant(w^.CV_Var)^.VType <> Pointer(IntProcDefParam(Func^.Decl, I))) and not ((PTypeRec(IntProcDefParam(Func^.Decl, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Array))
        and not (PTypeRec(IntProcDefParam(Func^.Decl, I))^.atypeid = CSV_Var) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
        DestroyCajVariant(slf);
        exit;
      end;
      VM_SetName(Parameters, I, copy(IntProcDefName(Func^.Decl, I), 2, Length(IntProcDefName(Func^.Decl, I))));
      w^.Flags := w^.Flags or 1;
    end else begin
      if not MakeCompat(w, Pointer(IntProcDefParam(Func^.Decl, I))) then begin
        FError.ErrorPosition := I - 1;
        FError.ErrorCode := EParameterError;
        DestroyCajVariant(slf);
        exit;
      end;
      VM_SetName(Parameters, I, IntProcDefName(Func^.Decl, I))
    end;
  end; {for}
  ProcStack.Add(Func);
  OldVars := CurrVars;
  CurrVars := Parameters;
  if Func^.Mode = 0 then begin
    I := Parser.CurrTokenPos;
    Parser.CurrTokenPos := Func^.offset;
    if Parser.CurrTokenId = CSTII_Var then begin
      if not ProcessVars(Parameters) then begin
        DestroyCajVariant(slf);
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end; {if}
    end; {if}
    WithList := TIfList.Create;
    WithList.Add(CreateVarType(slf));
    if not RunBegin(WithList, Parameters, False) then begin
      if FError.ErrorCode = EExitCommand then
        FError.ErrorCode := 0
      else begin
        DestroyCajVariant(slf);
        DestroyWithList(WithList);
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end;
    end; {if}
    DestroyWithList(WithList);
    Parser.CurrTokenPos := I;
    RunScriptConstructor := slf;
    RunError(Self, 0);
    PopProcStack;
    CurrVars := OldVars;
    exit;
  end {if}
  else if Func^.Mode = 1 then begin
    w := nil;
    RunError(Self, Func.proc1(Func^.FScriptEngine, fId, Func, Parameters, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if ErrorCode <> ENoError then begin
        DestroyCajVariant(slf);
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end; {if}
    RunScriptConstructor := slf;
  end {if}
  else begin
    w := nil;
    RunError(Self, Func.proc2(Func^.FScriptEngine, fId, Func, Parameters, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if ErrorCode <> ENoError then begin
        DestroyCajVariant(slf);
        PopProcStack;
        CurrVars := OldVars;
        exit;
      end; {if}
    RunScriptConstructor := slf;
  end; {if}
  PopProcStack;
  CurrVars := OldVars;
end;

function TIfPasScript.DoClassConstructor(WithList: TIfList; Myclass: PTypeRec; proc: PProcedure; Vars: PVariableManager): PIfVariant;
{Call an internal/external Procedure}
var
  OldVars: PVariableManager;
  slf: PIfVariant;
  I: Longint;
  Params: PVariableManager;
  CC: PCreatedClass;

  function IRem(s: string): string;
  {Remove the !}
  begin
    Delete(s, 1, 1);
    IRem := s;
  end; {irem}

  procedure CreateVars;
  var
    AA, I: Longint;
    C: PIFSClassType;
    s, Name: string;
    u: PTypeRec;
    n: PIfVariant;
    tmpv: PIFNamedVariable;

    function CreateProperty(p: PPropertyDef): PCajvariant;
    var
      prop: PCajvariant;
    begin
      prop := CreateCajVariant(TM_Add(Types, '', CSV_Property, p^.CV_Type));
      prop^.CV_Self := CC;
      prop^.CV_PropFlags := p^.CV_PropFlags;
      if (p^.CV_PropFlags and $5) = $1 then
        prop^.CV_PropRead := Vm_Get(CC^.Variables, Longint(p^.CV_PropRead))
      else
        prop^.CV_PropRead := p^.CV_PropRead;
      if (p^.CV_PropFlags and $A) = $2 then
        prop^.CV_PropWrite := Vm_Get(CC^.Variables, Longint(p^.CV_PropWrite))
      else
        prop^.CV_PropWrite := p^.CV_PropWrite;
      if (prop^.CV_PropFlags and $30) = $10 then
        prop^.Flags := prop^.Flags or 2
      else if (prop^.CV_PropFlags and $30) = $20 then
        prop^.Flags := prop^.Flags or 4
      else if (prop^.CV_PropFlags and $30) = $30 then
        prop^.Flags := prop^.Flags or 6;
      CreateProperty := prop;
    end;
  begin
    for I := 0 to Longint((PIFSClassType(CC^.ClassType^.Ext)^.VarNoStart + PIFSClassType(CC^.ClassType^.Ext)^.VarCount)) - 1 do begin
      PVariableManager(CC^.Variables).Add(nil);
    end;
    C := PIFSClassType(CC^.ClassType^.Ext);
    while assigned(C) do begin
      s := C^.Variables.u;
      I := C^.VarNoStart;
      while Length(s) > 0 do begin
        Name := Fw(s);
        Rfw(s);
        u := Pointer(StrToIntDef(Fw(s), 0));
        Rfw(s);
        n := CreateCajVariant(u);
        case Name[1] of
          '1': n^.Flags := $2;
          '2': n^.Flags := $4;
          '3': n^.Flags := $6;
        end;
        Delete(Name, 1, 1);
        New(tmpv);
        tmpv^.fVar := n;
        tmpv^.Name := Name;
        tmpv^.NameHash := mkhash(Name);
        PVariableManager(CC^.Variables).SetItem(I, tmpv);
        Inc(I);
      end; {while}
      if assigned(C^.InheritsFrom) then
        C := (C^.InheritsFrom^.Ext)
      else
        C := nil;
    end; {while}
    AA := VM_Count(CC^.Variables);
    C := PIFSClassType(CC^.ClassType^.Ext);
    for I := 0 to Longint(PIFSClassType(CC^.ClassType^.Ext)^.PropStart + PIFSClassType(CC^.ClassType^.Ext)^.Properties.Count) - 1 do begin
      PVariableManager(CC^.Variables).Add(nil);
    end;
    while assigned(C) do begin
      for I := 0 to Longint(C^.Properties.Count) - 1 do begin
        New(tmpv);
        tmpv^.Name := '';
        tmpv^.NameHash := 1;
        tmpv^.fVar := CreateProperty(C^.Properties.GetItem(I));
        PVariableManager(CC^.Variables).SetItem(AA + Longint(C^.PropStart) + I, tmpv);
      end;
      if assigned(C^.InheritsFrom) then
        C := (C^.InheritsFrom^.Ext)
      else
        C := nil;
    end;
  end;

begin
  if (proc^.Flags and $40) = 0 then begin
    DoClassConstructor := nil;
    RunError(Self, EConstructorExpected);
    exit;
  end;
  DoClassConstructor := nil;
  Params := VM_Create;
  New(CC);
  CC^.Variables := VM_Create;
  CC^.ClassType := Myclass;
  CreateVars;
  CC^.AlreadyFreed := False;
  CreatedClasses.Add(CC);
  slf := CreateCajVariant(Myclass);
  slf^.CV_Class := CC;
  with Vm_Add(Params, CreateCajVariant(proc^.ClassType), 'SELF')^ do begin
    CV_Class := slf^.CV_Class;
    Flags := 1;
  end;
  Parser.Next;
  if not ReadParams(WithList, proc^.Decl, Vars, Params) then begin
    VM_Destroy(Params);
    DestroyCajVariant(slf);
    exit;
  end;
  ProcStack.Add(proc);
  OldVars := CurrVars;
  CurrVars := Params;
  {Now we have all the parameters}
  if proc^.Mode = 0 then begin
    I := Parser.CurrTokenPos;
    Parser.CurrTokenPos := proc^.offset;
    if Parser.CurrTokenId = CSTII_Var then begin
      if not ProcessVars(Params) then begin
        DestroyCajVariant(slf);
        exit;
      end; {if}
    end; {if}
    WithList := TIfList.Create; // old withlist is no longer needed
    WithList.Add(CreateVarType(Vm_Get(Params, 0)));
    if not RunBegin(WithList, Params, False) then begin
      if FError.ErrorCode = EExitCommand then
        FError.ErrorCode := 0
      else begin
        DestroyCajVariant(slf);
        DestroyWithList(WithList);
        exit;
      end;
    end; {if}
    DestroyWithList(WithList);
    Parser.CurrTokenPos := I;
    DoClassConstructor := slf;
    VM_Destroy(Params);
  end {if}
  else if proc^.Mode = 1 then begin
    RunError(Self, proc^.proc1(proc^.FScriptEngine, fId, proc, Params, nil));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        VM_Destroy(Params);
        DestroyCajVariant(slf);
        exit;
      end; {if}
    VM_Destroy(Params);
    DoClassConstructor := slf;
  end {if}
  else begin
    RunError(Self, proc^.proc2(proc^.FScriptEngine, fId, proc, Params, nil));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        VM_Destroy(Params);
        DestroyCajVariant(slf);
        exit;
      end; {if}
    VM_Destroy(Params);
    DoClassConstructor := slf;
  end; {if}
  PopProcStack;
  CurrVars := OldVars;
end; {DoClassConstructor}
{$ENDIF}

function TIfPasScript.ReadParams(WithList: TIfList; ProcDef: string; Vars, Params: PVariableManager): Boolean;
{Call an internal/external Procedure}
var
  w: PIfVariant;
  I: Longint;

  function IRem(s: string): string;
  {Remove the !}
  begin
    Delete(s, 1, 1);
    IRem := s;
  end; {irem}
begin
  ReadParams := False;
  if (IntProcDefParam(ProcDef, -1) <> 0) and (Parser.CurrTokenId <> CSTI_OpenRound) then begin
    RunError(Self, ERoundOpenExpected);
    exit;
  end; {if}
  if (IntProcDefParam(ProcDef, -1) = 0) and (Parser.CurrTokenId = CSTI_OpenRound) then begin
    Parser.Next;
    if Parser.CurrTokenId = CSTI_CloseRound then begin
      Parser.Next;
    end else begin
      RunError(Self, ECloseRoundExpected);
      exit;
    end;
  end; {if}
  if Parser.CurrTokenId = CSTI_OpenRound then begin
    for I := 1 to IntProcDefParam(ProcDef, -1) do begin
      Parser.Next;
      if Pos('!', IntProcDefName(ProcDef, I)) = 1 then begin
        {Expect a variable}
        case GetIdentifier(WithList, Vars, 1, w) of
          0: begin
              exit;
            end;
          2: begin
              DestroyCajVariant(w);
              RunError(Self, EVariableExpected);
              exit;
            end;
        end;
        if (w^.Flags and $1) <> 0 then begin
          RunError(Self, EVariableExpected);
          exit;
        end; {if}
        w := GetVarLink(w);
        if (Longint(w^.VType) <> IntProcDefParam(ProcDef, I)) and not ((PTypeRec(IntProcDefParam(ProcDef, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Array)) and not (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Var) then begin
          RunError(Self, ETypeMismatch);
          exit;
        end;
        Vm_Add(Params, CreateCajVariant(TM_Add(Types, '', CSV_Var, nil)), FastUppercase(IRem(IntProcDefName(ProcDef, I))))^.CV_Var := w;
      end {if}
      else if Pos('^', IntProcDefName(ProcDef, I)) = 1 then begin
        {Expect a constant}
        case GetIdentifier(WithList, Vars, 1, w) of
          0: begin // error
              exit;
            end;
          2: begin // created variable
              w := GetVarLink(w);
              if (Longint(w^.VType) <> IntProcDefParam(ProcDef, I)) and not ((PTypeRec(IntProcDefParam(ProcDef, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Array))
                and not (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Var) then begin
                RunError(Self, ETypeMismatch);
                exit;
              end;
              Vm_Add(Params, w, IRem(IntProcDefName(ProcDef, I)))^.Flags := 1; {readonly}
            end;
        else begin
            w := GetVarLink(w);
            if (Longint(w^.VType) <> IntProcDefParam(ProcDef, I)) and not ((PTypeRec(IntProcDefParam(ProcDef, I))^.Ext = nil) and (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Array))
              and not (PTypeRec(IntProcDefParam(ProcDef, I))^.atypeid = CSV_Var) then begin
              RunError(Self, ETypeMismatch);
              exit;
            end;
            with Vm_Add(Params, CreateCajVariant(TM_Add(Types, '', CSV_Var, nil)), IRem(IntProcDefName(ProcDef, I)))^ do begin
              CV_Var := w;
              Flags := 1; {readonly}
            end;
          end;
        end;
      end {if}
      else begin
        w := Vm_Add(Params, CreateCajVariant(Pointer(IntProcDefParam(ProcDef, I))), IntProcDefName(ProcDef, I));
        if not calc(WithList, Vars, w, CSTI_CloseRound, False) then begin
          exit;
        end; {if}
      end; {else if}
      if I = IntProcDefParam(ProcDef, -1) then begin
        if Parser.CurrTokenId <> CSTI_CloseRound then begin
          RunError(Self, ERoundCloseExpected);
          exit;
        end; {if}
      end {if}
      else begin
        if Parser.CurrTokenId <> CSTI_Comma then begin
          RunError(Self, ECommaExpected);
          exit;
        end; {if}
      end; {else if}
    end; {for}
    Parser.Next;
  end; {if}
  ReadParams := True;
end;

function TIfPasScript.DoProc(WithList: TIfList; {$IFNDEF NOCLASSES}Myself: PCreatedClass; {$ENDIF}proc: PProcedure; Vars: PVariableManager): PIfVariant;
{Call an internal/external Procedure}
var
  OldVars: PVariableManager;
  w: PIfVariant;
  I: Longint;
  Params: PVariableManager;

  function IRem(s: string): string;
  {Remove the !}
  begin
    Delete(s, 1, 1);
    IRem := s;
  end; {irem}
{$IFNDEF NOCLASSES}

  procedure AddSelf;
  begin
    with Vm_Add(Params, CreateCajVariant(proc^.ClassType), 'SELF')^ do begin
      CV_Class := Myself;
      Flags := 1;
    end;
  end;
{$ENDIF}
begin
  DoProc := nil;
  Params := VM_Create;
{$IFNDEF NOCLASSES}
  if assigned(Myself) then begin
    AddSelf;
  end;
{$ENDIF}
  if not ReadParams(WithList, proc^.Decl, Vars, Params) then begin
    VM_Destroy(Params);
    exit;
  end;
  ProcStack.Add(proc);
  OldVars := CurrVars;
  CurrVars := Params;
  {Now we have all the parameters}
  if proc^.Mode = 0 then begin
    if proc^.FScriptEngine = Self then begin
      if IntProcDefParam(proc^.Decl, 0) <> 0 then begin
        w := CreateCajVariant(Pointer(IntProcDefParam(proc^.Decl, 0)));
        Vm_Add(Params, CreateCajVariant(TM_Add(Types, '', CSV_Var, nil)), 'RESULT')^.CV_Var := w;
      end {if}
      else w := nil;
      I := Parser.CurrTokenPos;
      Parser.CurrTokenPos := proc^.offset;
      if Parser.CurrTokenId = CSTII_Var then begin
        if not ProcessVars(Params) then begin
          VM_Destroy(Params);
          DestroyCajVariant(w);
          exit;
        end; {if}
      end; {if}
      WithList := TIfList.Create;
{$IFNDEF NOCLASSES}
      if assigned(proc^.ClassType) then begin
        WithList.Add(CreateVarType(Vm_Get(Params, 0)));
      end;
{$ENDIF}
      if not RunBegin(WithList, Params, False) then begin
        if FError.ErrorCode = EExitCommand then
          FError.ErrorCode := 0
        else begin
          VM_Destroy(Params);
          DestroyWithList(WithList);
          DestroyCajVariant(w);
          exit;
        end;
      end; {if}
      DestroyWithList(WithList);
      Parser.CurrTokenPos := I;
      DoProc := w;
      VM_Destroy(Params);
    end else begin
      DoProc := TIfPasScript(proc^.FScriptEngine).RunScriptProc(proc, Params);
      if TIfPasScript(proc^.FScriptEngine).ErrorCode <> 0 then begin
        RunError2(proc^.FScriptEngine, TIfPasScript(proc^.FScriptEngine).ErrorCode, TIfPasScript(proc^.FScriptEngine).ErrorString);
        DoProc := nil;
      end;
      VM_Destroy(Params);
    end;
  end {if}
  else if proc^.Mode = 1 then begin
    if IntProcDefParam(proc^.Decl, 0) <> 0 then
      w := CreateCajVariant(Pointer(IntProcDefParam(proc^.Decl, 0)))
    else
      w := nil;
    RunError(Self, proc^.proc1(proc^.FScriptEngine, fId, proc, Params, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        VM_Destroy(Params);
        DestroyCajVariant(w);
        exit;
      end; {if}
    VM_Destroy(Params);
    DoProc := w;
  end {if} else begin
    if IntProcDefParam(proc^.Decl, 0) <> 0 then
      w := CreateCajVariant(Pointer(IntProcDefParam(proc^.Decl, 0)))
    else
      w := nil;
    RunError(Self, proc^.proc2(proc^.FScriptEngine, fId, proc, Params, w));
    if FError.ErrorCode = EExitCommand then
      FError.ErrorCode := 0
    else
      if FError.ErrorCode <> ENoError then begin
        VM_Destroy(Params);
        DestroyCajVariant(w);
        exit;
      end; {if}
    VM_Destroy(Params);
    DoProc := w;
  end; {if}
  PopProcStack;
  CurrVars := OldVars;
end; {DoProc}

//-------------------------------------------------------------------
// Procedure: RunBegin
//   Purpose: Steps through the script, parsing the tokens
//-------------------------------------------------------------------
type
  TBeginMode = (mbTry, mbRepeat, mbBegin, mbOneLiner);

function TIfPasScript.RunBegin(WithList: TIfList; Vars: PVariableManager; Skip: Boolean): Boolean;
      { Run the Script, this is the main part of the script engine }
var
  C, c2, C3: PIfVariant;
  IPos, IStart, ii, IEnd: Longint;
  b: Boolean;
{$IFNDEF NOCLASSES}
  NewWithList: TIfList;
{$ENDIF}
  BeginMode: TBeginMode;
  lBreak: Boolean;
begin
  if Parser.CurrTokenId = CSTII_repeat then BeginMode := mbRepeat else
    if Parser.CurrTokenId = CSTII_try then BeginMode := mbTry else
      BeginMode := mbOneLiner;
  Inc(FBeginNesting);
  if FBeginNesting > FMaxBeginNesting then begin
    Dec(FBeginNesting);
    RunError(Self, EOutOfMemoryError);
    RunBegin := False;
    exit;
  end;

  if Skip then begin
    if (Parser.CurrTokenId = CSTII_Begin) or (Parser.CurrTokenId = CSTII_Case) or (Parser.CurrTokenId = CSTII_repeat) or (Parser.CurrTokenId = CSTII_try) or (Parser.CurrTokenId = CSTII_Except)
      or (Parser.CurrTokenId = CSTII_Finally) then begin
      IPos := 1;
      Parser.Next;
      while Parser.CurrTokenId <> CSTI_EOF do begin
        case Parser.CurrTokenId of
          CSTII_Case, CSTII_Begin, CSTII_try, CSTII_repeat: Inc(IPos);
          CSTII_until, CSTII_End: begin
              Dec(IPos);
              if IPos = 0 then begin
                RunBegin := True;
                Parser.Next;
                Dec(FBeginNesting);
                exit;
              end;
            end;
        end;
        Parser.Next;
      end;
      RunError(Self, EUnexpectedEndOfFile);
      RunBegin := False;
      Dec(FBeginNesting);
      exit;
    end else begin
      IPos := 1;
      while Parser.CurrTokenId <> CSTI_EOF do begin
        case Parser.CurrTokenId of
          CSTII_If: Inc(IPos);
          CSTI_Semicolon: begin
              RunBegin := True;
              Dec(FBeginNesting);
              exit;
            end;
          CSTII_Else: begin
              Dec(IPos);
              if IPos = 0 then begin
                RunBegin := True;
                Dec(FBeginNesting);
                exit;
              end;
            end;
          CSTII_Begin, CSTII_Case, CSTII_repeat: begin
              if ExecRunLine then begin
                Dec(FBeginNesting);
                RunBegin := True;
                exit;
              end;
              RunBegin(WithList, Vars, True);
              continue;
            end;
          CSTII_End, CSTII_until: begin
              RunBegin := True;
              Dec(FBeginNesting);
              exit;
            end;
        end;
        Parser.Next;
      end;
      RunError(Self, EUnexpectedEndOfFile);
      RunBegin := False;
      Dec(FBeginNesting);
      exit;
    end;
  end;
  RunBegin := False;
  if (Parser.CurrTokenId = CSTII_Begin) or (Parser.CurrTokenId = CSTII_Except) or (Parser.CurrTokenId = CSTII_Finally) then begin
    BeginMode := mbBegin;
    Parser.Next; {skip begin}
  end else
    if (Parser.CurrTokenId = CSTII_repeat) or (Parser.CurrTokenId = CSTII_try) then
      Parser.Next;

  while True do begin

    case Parser.CurrTokenId of
      CSTI_EOF: begin
          RunError(Self, EUnexpectedEndOfFile);
          Dec(FBeginNesting);
          exit;
        end;
      CSTII_Else: begin
          if BeginMode = mbOneLiner then begin
            RunBegin := True;
            Dec(FBeginNesting);
            exit;
          end
          else begin
            RunError(Self, EErrorInStatement);
            RunBegin := False;
            Dec(FBeginNesting);
            exit;
          end;
        end;
      CSTII_try: begin
          if RunBegin(WithList, Vars, False) then begin
            if Parser.CurrTokenId = CSTII_Finally then begin
              RunBegin(WithList, Vars, False);
            end else if Parser.CurrTokenId = CSTII_Except then begin
              RunBegin(WithList, Vars, True);
            end;
          end else begin
            if FError.ErrorCode < ERuntimeError then exit;
            FLastException := FError;
            RunError(Self, ENoError);
            while (Parser.CurrTokenId <> CSTII_Except) and (Parser.CurrTokenId <> CSTII_Finally) do begin
              if Parser.CurrTokenId = CSTI_EOF then begin
                RunError(Self, EUnexpectedEndOfFile);
                exit;
              end;
              Parser.Next;
            end;
            if Parser.CurrTokenId = CSTII_Finally then begin
              if not RunBegin(WithList, Vars, False) then
                exit;
              FError := FLastException;
              exit;
            end else if Parser.CurrTokenId = CSTII_Except then begin
              if not RunBegin(WithList, Vars, FLastException.ErrorCode = EExitCommand) then
                exit;
              FLastException := FError;
            end;
          end;
        end;
      CSTII_Finally,
        CSTII_Except: begin
          if BeginMode = mbTry then begin
            RunBegin := True;
            Dec(FBeginNesting);
            exit;
          end else begin
            case BeginMode of
              mbRepeat: RunError(Self, EUntilExpected);
              mbOneLiner, mbBegin: RunError(Self, EEndExpected);
            end;
            RunBegin := False;
            Dec(FBeginNesting);
            exit;
          end;
        end;

      CSTII_End: begin
          if (BeginMode = mbBegin) or (BeginMode = mbOneLiner) then begin
            RunBegin := True;
            if BeginMode <> mbOneLiner then
              Parser.Next;
            Dec(FBeginNesting);
            exit;
          end else begin
            case BeginMode of
              mbTry: RunError(Self, EExceptExpected);
              mbRepeat: RunError(Self, EUntilExpected);
            end;
            RunBegin := False;
            Dec(FBeginNesting);
            exit;
          end;
        end; {CSTII_End}
      CSTII_until: begin
          if BeginMode = mbRepeat then begin
            RunBegin := True;
            Dec(FBeginNesting);
            exit;
          end else begin
            case BeginMode of
              mbTry: RunError(Self, EExceptExpected);
              mbOneLiner, mbBegin: RunError(Self, EEndExpected);
            end;
            RunError(Self, EEndExpected);
            RunBegin := False;
            Dec(FBeginNesting);
            exit;
          end;
        end; {CSTII_Until}
//-------------------------------------------------------
// Exit command - aborts the script
//-------------------------------------------------------
      CSTII_Exit: begin
          RunBegin := False;
          RunError(Self, EExitCommand);
          Dec(FBeginNesting);
          exit;
        end; { CSTII_Exit}
//-------------------------------------------------------
// Break command - breaks out of loop
//-------------------------------------------------------
      CSTII_Break: begin
          RunBegin := True;
          Dec(FBeginNesting);
          exit;
        end; { CSTII_Break }
//-------------------------------------------------------
// Continue command - breaks out of loop
//-------------------------------------------------------
      CSTII_Continue: begin
          RunBegin := True;
          Dec(FBeginNesting);
          exit;
        end; { CSTII_Break }

//-------------------------------------------------------
// Semicolon is handled specially
//-------------------------------------------------------
      CSTI_Semicolon: begin
          if BeginMode = mbOneLiner then begin
            RunBegin := True;
            Dec(FBeginNesting);
            exit;
          end;
          Parser.Next;
        end; {CSTI_SemiColon}
//-------------------------------------------------------
// Process an IF statement
//-------------------------------------------------------
      CSTII_If: begin
          if ExecRunLine then begin
            Dec(FBeginNesting);
            exit;
          end;
          Parser.Next;
          C := CreateCajVariant(TM_Add(Types, '', CSV_Bool, nil));
          if not calc(WithList, Vars, C, CSTII_Then, False) then begin
            DestroyCajVariant(C);
            Dec(FBeginNesting);
            exit;
          end; {if}
          if Parser.CurrTokenId <> CSTII_Then
            then begin
            RunError(Self, EThenExpected);
            DestroyCajVariant(C);
            Dec(FBeginNesting);
            exit;
          end;
          Parser.Next; {skip THEN}
          if C^.Cv_Bool then begin
            DestroyCajVariant(C);
            if not RunBegin(WithList, Vars, False) then begin
              Dec(FBeginNesting);
              exit;
            end; {if}
            if Parser.CurrTokenId = CSTII_Else then begin
              if ExecRunLine then begin
                Dec(FBeginNesting);
                exit;
              end;
              Parser.Next;
              if not RunBegin(WithList, Vars, True) then begin
                Dec(FBeginNesting);
                exit;
              end; {if}
            end; {if}
          end {if}
          else begin
            DestroyCajVariant(C);
            if not RunBegin(WithList, Vars, True) then begin
              Dec(FBeginNesting);
              exit;
            end; {if}
            if Parser.CurrTokenId = CSTII_Else then begin
              Parser.Next;
              if ExecRunLine then begin
                Dec(FBeginNesting);
                exit;
              end;
              if not RunBegin(WithList, Vars, False) then begin
                Dec(FBeginNesting);
                exit;
              end; {if}
            end; {if}
          end; {if}
        end; {CSTII_If}

//--------------------------------------------------------------------
// Process the WHILE DO loop ***************************************--
//--------------------------------------------------------------------
      CSTII_While: begin
          lBreak := False;

          Parser.Next; // Find Next token

          C := CreateCajVariant(TM_Add(Types, '', CSV_Bool, nil)); // Create a boolean variable
          IPos := Parser.CurrTokenPos; // Save position of variable

          // Test the expression up to the DO command
          //-------------------------------------------
          if not calc(WithList, Vars, C, CSTII_do, False) then begin
            DestroyCajVariant(C);
            Dec(FBeginNesting);
            exit;
          end; {if}

          // If not a DO command, this is an error
          //-----------------------------------------
          if Parser.CurrTokenId <> CSTII_do then begin
            RunError(Self, EDoExpected);
            DestroyCajVariant(C);
            Dec(FBeginNesting);
            exit;
          end;

          Parser.Next;

          // Save the DO block starting position
          //--------------------------------------
          IStart := Parser.CurrTokenPos;

          //-------------------------------
          // Start the loop processing
          //-------------------------------
          while C^.Cv_Bool and (not lBreak) do begin
             // See if any command to run
             // ---------------------------
            if ExecRunLine then begin
              Dec(FBeginNesting);
              exit;
            end;

             // Call routine to process the code
             //----------------------------------
            if not RunBegin(WithList, Vars, False) then begin
              DestroyCajVariant(C);
              Dec(FBeginNesting);
              exit;
            end;

            // If a break were returned
            //--------------------------
            if Parser.CurrTokenId = CSTII_Break then begin
              lBreak := True;
            end;

            // Go back to the variable test position
            //----------------------------------------
            Parser.CurrTokenPos := IPos;

            // Test the condition again, if false, exit
            //-----------------------------------------
            if not calc(WithList, Vars, C, CSTII_do, False) then begin
              DestroyCajVariant(C);
              Dec(FBeginNesting);
              exit;
            end;

            // Reset to the DO starting block
            //---------------------------------
            Parser.CurrTokenPos := IStart;
          end;

          DestroyCajVariant(C);
          if not RunBegin(WithList, Vars, True) then begin
            Dec(FBeginNesting);
            exit;
          end;
        end;
//--------------------------------------------------------------------
// Process the REPEAT UNTIL loop ***********************************--
//--------------------------------------------------------------------
      CSTII_repeat: begin
          lBreak := False;

          C := CreateCajVariant(TM_Add(Types, '', CSV_Bool, nil)); // Create a boolean variable

          IStart := Parser.CurrTokenPos;

          //-------------------------------
          // Start the loop processing
          //-------------------------------
          repeat
            Parser.CurrTokenPos := IStart;
             // See if any command to run
             // ---------------------------
            if ExecRunLine then begin
              Dec(FBeginNesting);
              exit;
            end;

             // Call routine to process the code
             //----------------------------------
            if not RunBegin(WithList, Vars, False) then begin
              DestroyCajVariant(C);
              Dec(FBeginNesting);
              exit;
            end;

            // If a break were returned
            //--------------------------
            if Parser.CurrTokenId = CSTII_Break then begin
              lBreak := True;
              break;
            end;

            if Parser.CurrTokenId <> CSTII_until then begin
              RunError(Self, EUntilExpected);
              DestroyCajVariant(C);
              Dec(FBeginNesting);
              exit;
            end;

            Parser.Next;

            // Test the condition again, if false, exit
            //-----------------------------------------
            if not calc(WithList, Vars, C, CSTI_Semicolon, False) then begin
              DestroyCajVariant(C);
              Dec(FBeginNesting);
              exit;
            end;
          until C^.Cv_Bool;

          DestroyCajVariant(C);

          if lBreak then begin
            Parser.CurrTokenPos := IStart;
            if not RunBegin(WithList, Vars, True) then begin
              Dec(FBeginNesting);
              exit;
            end;
          end;
        end;

//-------------------------------------------------------
// FOR LOOP is handled here
//-------------------------------------------------------
      CSTII_For: begin
          // Found the FOR keyword
          // ----------------------
          Parser.Next; // Find the next token

          // It should be an identifier
          //------------------------------
          if Parser.CurrTokenId <> CSTI_Identifier then begin
            RunError(Self, EIdentifierExpected);
            Dec(FBeginNesting);
            exit;
          end; {if}

          // The variable must exist
          //------------------------------
          if assigned(Vars) and
            (VM_Find(Vars, Parser.GetToken) <> -1)
            then C := GetVarLink(Vm_Get(Vars, VM_Find(Vars,
              Parser.GetToken)))
          else
            if VM_Find(Variables, Parser.GetToken) <> -1
              then C := GetVarLink(Vm_Get(Variables, VM_Find(Variables,
                Parser.GetToken)))
            else begin
              RunError2(Self, EUnknownIdentifier, Parser.GetToken);
              Dec(FBeginNesting);
              exit;
            end; {if}

          // It cannot be a constant
          //------------------------------
          if (C^.Flags and $1) <> 0 then begin
            RunError(Self, EVariableExpected);
            Dec(FBeginNesting);
            exit;
          end; {if}

          // And it must be an integer
          //------------------------------
          if not IsIntegerType(C) then begin
            RunError(Self, eIntegerExpected);
          end; {if}

          Parser.Next; // Find the next token

          // Expecting an assignment statement
          //----------------------------------------
          if Parser.CurrTokenId <> CSTI_Assignment then begin
            RunError(Self, EAssignmentExpected);
            Dec(FBeginNesting);
            exit;
          end; {if}

          Parser.Next; // Find the next token

          // Calculate expression of token from current position
          // to the TO keyword
          //--------------------------------------------------
          if not calc(WithList, Vars, C, CSTII_To, False)
            then begin
            Dec(FBeginNesting);
            exit;
          end;

          // Get the result of the calculation
          //---------------------------------------
          IStart := GetInteger(C);

          if (Parser.CurrTokenId <> CSTII_To) and
            (Parser.CurrTokenId <> CSTII_DownTo) then begin
            RunError(Self, EToExpected);
            Dec(FBeginNesting);
            exit;
          end; {if}

          // See if we are going up or down
          //-----------------------------------
          b := (Parser.CurrTokenId = CSTII_DownTo);

          Parser.Next; // Find the next token

          if not calc(WithList, Vars, C, CSTII_do, False)
            then begin
            Dec(FBeginNesting);
            exit;
          end;

          // Get the result of the calculation
          //---------------------------------------
          IEnd := GetInteger(C);

          if Parser.CurrTokenId <> CSTII_do then begin
            RunError(Self, EDoExpected);
            Dec(FBeginNesting);
            exit;
          end; {if}

          Parser.Next; // Find the next token

          lBreak := False; // Assume the loop will complete
          IPos := Parser.CurrTokenPos;

          if b then begin
            C^.Flags := C^.Flags or $1;

            // Start the loop
            //------------------------------
            for ii := IStart downto IEnd do begin
              if ExecRunLine then begin
                Dec(FBeginNesting);
                exit;
              end;

              // Make the loop variable visible to program
              //--------------------------------------------
              SetInteger(C, ii);
              if not RunBegin(WithList, Vars, False) then begin
                C^.Flags := C^.Flags and not $1;
                Dec(FBeginNesting);
                exit;
              end;

              // If a break were returned
              //--------------------------
              if Parser.CurrTokenId = CSTII_Break
                then lBreak := True;

              Parser.CurrTokenPos := IPos;

              if lBreak then break;

            end;
            C^.Flags := C^.Flags and not $1;
            if not RunBegin(WithList, Vars, True) then begin
              Dec(FBeginNesting);
              exit;
            end;
          end {if}
          else begin
            C^.Flags := C^.Flags or $1;
            for ii := IStart to IEnd do begin
              if ExecRunLine then begin
                Dec(FBeginNesting);
                exit;
              end;

              SetInteger(C, ii);
              if not RunBegin(WithList, Vars, False) then begin
                C^.Flags := C^.Flags and not $1;
                Dec(FBeginNesting);
                exit;
              end;

              // If a break were returned
              //--------------------------
              if Parser.CurrTokenId = CSTII_Break
                then lBreak := True;

              Parser.CurrTokenPos := IPos;

              // If a break were returned
                            //--------------------------
              if lBreak then break

            end;
            C^.Flags := C^.Flags and not $1;
            if not RunBegin(WithList, Vars, True) then begin
              Dec(FBeginNesting);
              exit;
            end;
          end {if}
        end;
//-------------------------------------------------------
// Begin a block
//-------------------------------------------------------
      CSTII_Begin: begin
          if not RunBegin(WithList, Vars, False) then begin
            Dec(FBeginNesting);
            exit;
          end;
        end; {CSTII_Begin}
//-------------------------------------------------------
// CASE <x> OF
//-------------------------------------------------------
      CSTII_Case: begin
          Parser.Next;
          C := CreateCajVariant(TM_Add(Types, '', CSV_Var, nil));
          C^.CV_Var := nil; {Say that calc can assign any type}
          if not calc(WithList, Vars, C, CSTII_Of, False) then begin
            DestroyCajVariant(C);
            Dec(FBeginNesting);
            exit;
          end; {If}
          if Parser.CurrTokenId <> CSTII_Of then begin
            RunError(Self, EOfExpected);
            Dec(FBeginNesting);
            exit;
          end; {If}
          Parser.Next;
          b := False;
          while Parser.CurrTokenId <> CSTII_End do begin
            if Parser.CurrTokenId = CSTII_Else then begin
              Parser.Next;
              if not RunBegin(WithList, Vars, b) then begin
                Dec(FBeginNesting);
                exit;
              end;
              if Parser.CurrTokenId = CSTI_Semicolon then begin
                Parser.Next;
              end;
              if Parser.CurrTokenId <> CSTII_End then begin
                RunError(Self, EEndExpected);
                Dec(FBeginNesting);
                exit;
              end;
              break;
            end;
            if ExecRunLine then begin
              Dec(FBeginNesting);
              exit;
            end;
            c2 := CreateCajVariant(C^.VType);
            if not calc(WithList, Vars, c2, CSTI_Colon, False) then begin
              DestroyCajVariant(C);
              DestroyCajVariant(c2);
              Dec(FBeginNesting);
              exit;
            end; {If}
            if not Perform(c2, C, PtEqual) then begin
              DestroyCajVariant(C);
              DestroyCajVariant(c2);
              Dec(FBeginNesting);
              exit;
            end; {If}
            while Parser.CurrTokenId = CSTI_Comma do begin
              Parser.Next;
              C3 := CreateCajVariant(C^.VType);
              if not calc(WithList, Vars, C3, CSTI_Colon, False) then begin
                DestroyCajVariant(C);
                DestroyCajVariant(c2);
                DestroyCajVariant(C3);
                Dec(FBeginNesting);
                exit;
              end; {If}
              if not Perform(C3, C, PtEqual) then begin
                DestroyCajVariant(C);
                DestroyCajVariant(c2);
                DestroyCajVariant(C3);
                Dec(FBeginNesting);
                exit;
              end; {If}
              if not Perform(c2, C3, ptOr) then begin
                DestroyCajVariant(C);
                DestroyCajVariant(c2);
                Dec(FBeginNesting);
                exit;
              end;
            end;
            if Parser.CurrTokenId <> CSTI_Colon then begin
              RunError(Self, EColonExpected);
              DestroyCajVariant(C);
              DestroyCajVariant(c2);
              Dec(FBeginNesting);
              exit;
            end; {If}
            Parser.Next;
            if not RunBegin(WithList, Vars, (not c2^.Cv_Bool or b)) then begin
              DestroyCajVariant(C);
              DestroyCajVariant(c2);
              Dec(FBeginNesting);
              exit;
            end;
            if c2^.Cv_Bool then
              b := True;
            if Parser.CurrTokenId = CSTI_Semicolon then begin
              Parser.Next;
            end;
            DestroyCajVariant(c2);
          end; {While}
          DestroyCajVariant(C);
          Parser.Next; {Skip end}
        end; {CSTII_Case}
{$IFNDEF NOClASSES}
      CSTII_WITH: begin
          Parser.Next;
          NewWithList := TIfList.Create;
          case GetIdentifier(WithList, Vars, 0, C) of
            0: begin
                DestroyWithList(NewWithList);
                Dec(FBeginNesting);
                exit;
              end; // case 0
            1: C := CreateVarType(C);
            2: ;
          end; //case
          if (GetVarLink(C)^.VType^.atypeid = CSV_Class) or (GetVarLink(C)^.VType^.atypeid = CSV_Record) then begin
            if GetVarLink(C)^.VType^.atypeid = CSV_Class then begin
              if (GetVarLink(C)^.CV_Class = nil) then begin
                DestroyCajVariant(C);
                DestroyWithList(NewWithList);
                RunError(Self, EClassNotCreated);
                Dec(FBeginNesting);
                exit;
              end;
              if (GetVarLink(C)^.CV_Class^.AlreadyFreed) then begin
                DestroyCajVariant(C);
                DestroyWithList(NewWithList);
                RunError(Self, EClassAlreadyFreed);
                Dec(FBeginNesting);
                exit;
              end;
            end;
            NewWithList.Add(C);
            while Parser.CurrTokenId <> CSTII_do do begin
              if Parser.CurrTokenId <> CSTI_Comma then begin
                DestroyWithList(NewWithList);
                RunError(Self, ECommaExpected);
                Dec(FBeginNesting);
                exit;
              end;
              Parser.Next;
              case GetIdentifier(WithList, Vars, 0, C) of
                0: begin
                    DestroyWithList(NewWithList);
                    Dec(FBeginNesting);
                    exit;
                  end;
                1: C := CreateVarType(C);
                2: ;
              end; //case
              if GetVarLink(C)^.VType^.atypeid = CSV_Class then begin
                if (GetVarLink(C)^.CV_Class = nil) then begin
                  DestroyCajVariant(C);
                  DestroyWithList(NewWithList);
                  RunError(Self, EClassNotCreated);
                  Dec(FBeginNesting);
                  exit;
                end;
                if (GetVarLink(C)^.CV_Class^.AlreadyFreed) then begin
                  DestroyCajVariant(C);
                  DestroyWithList(NewWithList);
                  RunError(Self, EClassAlreadyFreed);
                  Dec(FBeginNesting);
                  exit;
                end;
              end else if GetVarLink(C)^.VType^.atypeid <> CSV_Record then begin
                DestroyCajVariant(C);
                DestroyWithList(NewWithList);
                RunError(Self, EClassTypeExpected);
                Dec(FBeginNesting);
                exit;
              end;
              NewWithList.Add(C);
            end; //while
            for ii := 0 to Longint(WithList.Count) - 1 do begin
              NewWithList.Add(CreateVarType(WithList.GetItem(ii)));
            end;
            Parser.Next;
            if not RunBegin(NewWithList, Vars, False) then begin
              DestroyWithList(NewWithList);
              Dec(FBeginNesting);
              exit;
            end;
            DestroyWithList(NewWithList);
          end else begin
            DestroyCajVariant(C);
            DestroyWithList(NewWithList);
            RunError(Self, EClassTypeExpected);
            Dec(FBeginNesting);
            exit;
          end;
        end; {CSTII_With}
{$ENDIF}
//-------------------------------------------------------
// Found an identifier
//-------------------------------------------------------
      CSTII_Inherited,
        CSTI_OpenRound,
        CSTI_Identifier: begin
          if ExecRunLine then begin
            Dec(FBeginNesting);
            exit;
          end;
          case GetIdentifier(WithList, Vars, 0, C) of
            0: begin
                Dec(FBeginNesting);
                exit;
              end;
            1: begin
                if (C^.Flags and 1) <> 0 then begin
                  RunError(Self, EVariableExpected);
                  Dec(FBeginNesting);
                  exit;
                end;
                if Parser.CurrTokenId <> CSTI_Assignment then begin
                  RunError(Self, EAssignmentExpected);
                  Dec(FBeginNesting);
                  exit;
                end;
                Parser.Next;
{$IFNDEF NOCLASSES}
                if C^.VType^.atypeid = CSV_Property then begin
                  c2 := CreateCajVariant(TM_Add(Types, '', CSV_Var, nil));
                  if not calc(WithList, Vars, c2, CSTI_Semicolon, False) then begin
                    Dec(FBeginNesting);
                    exit;
                  end;
                  if not SetProperty(C, c2) then begin
                    DestroyCajVariant(c2);
                    Dec(FBeginNesting);
                    exit;
                  end;
                  DestroyCajVariant(c2);
                end else begin
                  if not calc(WithList, Vars, C, CSTI_Semicolon, False) then begin
                    Dec(FBeginNesting);
                    exit;
                  end;
                end;
{$ELSE}
                if not calc(WithList, Vars, C, CSTI_Semicolon, False) then begin
                  Dec(FBeginNesting);
                  exit;
                end;
{$ENDIF}
              end;
            2: begin
{$IFNDEF NOCLASSES}
                if assigned(C) and (C^.VType^.atypeid = CSV_ExternalObjectProperty) then begin
                  if Parser.CurrTokenId <> CSTI_Assignment then begin
                    DestroyCajVariant(C);
                    RunError(Self, EAssignmentExpected);
                    Dec(FBeginNesting);
                    exit;
                  end;
                  Parser.Next;
                  if (not assigned(C^.CV_ExtObj)) then begin
                    DestroyCajVariant(C);
                    Dec(FBeginNesting);
                    RunError(Self, EClassNotCreated);
                    exit;
                  end;
                  c2 := CreateCajVariant(TIfsExtClass(C^.VType^.ext).GetPropertyType(PIFSExternalObject(C^.CV_ExtObj), C^.CV_PropertyNo));
                  if not calc(WithList, Vars, c2, CSTI_Semicolon, False) then begin
                    DestroyCajVariant(C);
                    Dec(FBeginNesting);
                    exit;
                  end;
                  if not TIfsExtClass(C^.VType^.ext).SetProperty(PIFSExternalObject(C^.CV_ExtObj), C^.CV_PropertyNo, c2) then begin
                    DestroyCajVariant(C);
                    DestroyCajVariant(c2);
                    Dec(FBeginNesting);
                    exit;
                  end;
                  DestroyCajVariant(c2);
                  DestroyCajVariant(C);
                end else {$ENDIF}
                  DestroyCajVariant(C);
              end;
          end;
        end; {CSTI_Identifier}
    else begin
        RunError(Self, EErrorInStatement);
        Dec(FBeginNesting);
        exit;
      end; {Else case}
    end; {Case}
  end; {While}
  RunBegin := True;
  Dec(FBeginNesting);
end; {RunBegin}
{$IFNDEF NOCLASSES}

function TObjProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Self: PIfVariant;
  nn: PVariableManager;
  p: PProcedure;
  PT: PTypeRec;
  s: string;
begin
  Self := GetVarLink(Vm_Get(Params, 0));
  if proc^.Name = '!CLASSNAME' then begin
    SetString(res, Self^.CV_Class^.ClassType^.Ident);
  end else if proc^.Name = '!CLASSNAMEIS' then begin
    s := FastUppercase(GetString(GetVarLink(Vm_Get(Params, 1))));
    PT := Self^.CV_Class^.ClassType;
    SetBoolean(res, False);
    while assigned(PT) do begin
      if PT^.Ident = s then begin
        SetBoolean(res, True);
        break;
      end;
      PT := PIFSClassType(PT^.Ext)^.InheritsFrom;
    end;
  end else if proc^.Name = '!GETANCESTORS' then begin
    PT := Self^.CV_Class^.ClassType;
    s := PT^.Ident;
    PT := PIFSClassType(PT^.Ext)^.InheritsFrom;
    while assigned(PT) do begin
      s := PT.Ident + '.' + s;
      PT := PIFSClassType(PT^.Ext)^.InheritsFrom;
    end;
    SetString(res, s);
  end else if proc^.Name = '!CREATE' then begin
  end else if (proc^.Name = '!DESTROY') then begin
    if assigned(Self^.CV_Class) and not (Self^.CV_Class^.AlreadyFreed) then begin
      VM_Destroy(Self.CV_Class^.Variables);
      Self.CV_Class^.AlreadyFreed := True;
    end else begin
      if Self^.CV_Class^.AlreadyFreed then
        TObjProc := EClassAlreadyFreed
      else
        TObjProc := EClassNotCreated;
      exit;
    end;
  end else if proc^.Name = '!FREE' then begin
    GetClassProcedure(Self, Sender.GetType('TObject')^.Ext, 'DESTROY', p, True);
    nn := VM_Create;
    Vm_Add(nn, Self, 'SELF');
    DestroyCajVariant(Sender.RunScriptProc(p, nn));
    VM_Delete(nn, 0);
    VM_Destroy(nn);
    if Sender.ErrorCode <> 0 then begin
      TObjProc := Sender.ErrorCode;
      exit;
    end;
  end;
  TObjProc := ENoError;
end;
{$ENDIF}

function Trim(s: string): string;
begin
  while (Length(s) > 0) and (s[1] = ' ') do
    Delete(s, 1, 1);
  while (Length(s) > 0) and (s[Length(s)] = ' ') do
    Delete(s, Length(s), 1);
  Trim := s;
end;

function ExProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  I: Word;
begin
  if proc^.Name = 'GETLASTERRORCODE' then begin
    SetInteger(res, Sender.FLastException.ErrorCode);
  end else if proc^.Name = 'GETLASTERRORPOSITION' then begin
    SetInteger(res, Sender.FLastException.ErrorPosition);
  end else if proc^.Name = 'GETLASTERRORPARAM' then begin
    SetString(res, Sender.FLastException.ErrorParam);
  end else if proc^.Name = 'GETLASTERRORMODULE' then begin
    SetString(res, Sender.FLastException.ErrorModule);
  end else if proc^.Name = 'GETLASTERRORASSTRING' then begin
    SetString(res, ErrorToString(Sender.FLastException.ErrorCode, Sender.FLastException.ErrorParam));
  end else if proc^.Name = 'RAISEERROR' then begin
    I := GetInteger(Vm_Get(Params, 0));
    if I < ERuntimeError then
      I := ECustomError;
    Sender.RunError2(Sender, I, GetString(Vm_Get(Params, 1)));
    Result := I;
    exit;
  end;
  Result := ENoError;
end;

function StdProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  C: PIfVariant;
  i1, I2: Longint;
  cStr: string;
  x: PPointerList;

  function mkchr(C: PIfVariant): Integer;
  begin
    if C^.VType^.atypeid = CSV_String then begin
      if Length(C^.Cv_Str) = 1 then begin
        mkchr := Ord(C^.Cv_Str[1]);
      end else
        mkchr := -1;
    end else begin
      mkchr := Ord(C^.Cv_Char);
    end;
  end;
begin
  StdProc := ENoError;
  if proc^.Name = 'SETLENGTH' then begin
    C := GetVarLink(Vm_Get(Params, 0));
    SetLength(C^.Cv_Str, GetInteger(Vm_Get(Params, 1)));
  end else if proc^.Name = 'ASSIGNED' then begin
    C := GetVarLink(Vm_Get(Params, 0));
    case C^.VType.atypeid of
{$IFNDEF NOCLASSES}
      CSV_Class: SetBoolean(res, assigned(C^.CV_Class) and (not C^.CV_Class^.AlreadyFreed));
      CSV_ClassRef: SetBoolean(res, assigned(C^.Cv_ClassRef));
      CSV_ExternalObject: SetBoolean(res, assigned(C^.CV_ExternalObject));
{$ENDIF}
      CSV_ProcVariable: SetBoolean(res, assigned(C^.Cv_Proc));
      CSV_Variant: SetBoolean(res, assigned(C^.CV_Variant));
    else
      StdProc := ETypeMismatch;
    end;
  end else
    if proc^.Name = 'GETTYPE' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if C^.VType.Ident <> '' then
        SetString(res, C^.VType.Ident)
      else
        SetString(res, 'VAR');
    end else if proc^.Name = 'STRGET' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      i1 := GetInteger(GetVarLink(Vm_Get(Params, 1)));
      if (i1 < 1) or (i1 > Length(C^.Cv_Str)) then begin
        StdProc := EOutOfRange;
        exit;
      end;
      res^.Cv_Char := C^.Cv_Str[i1];
    end else if proc^.Name = 'STRSET' then begin
      C := GetVarLink(Vm_Get(Params, 2));
      i1 := GetInteger(GetVarLink(Vm_Get(Params, 1)));
      if (i1 < 1) or (i1 > Length(C^.Cv_Str)) then begin
        StdProc := EOutOfRange;
        exit;
      end;
      I2 := mkchr(GetVarLink(Vm_Get(Params, 0)));
      if I2 = -1 then begin
        StdProc := EOutOfRange;
        exit;
      end;
      C^.Cv_Str[i1] := Chr(I2);
    end else if proc^.Name = 'LOW' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if C^.VType^.atypeid = CSV_Enum then begin
        ChangeType(res, C^.VType)^.CV_Enum := 0;
      end else if C^.VType^.atypeid = CSV_Array then begin
        ChangeType(res, Sender.GetType('LONGINT'))^.Cv_SInt32 := 0;
      end else begin
        StdProc := ETypeMismatch;
        exit;
      end;
    end else if proc^.Name = 'HIGH' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if C^.VType^.atypeid = CSV_Enum then begin
        ChangeType(res, C^.VType)^.CV_Enum := Longint(C^.VType^.Ext);
      end else if C^.VType^.atypeid = CSV_Array then begin
        ChangeType(res, Sender.GetType('LONGINT'))^.Cv_SInt32 := Longint(C^.CV_ArrItems.Count) - 1;
      end else begin
        StdProc := ETypeMismatch;
        exit;
      end;
    end else if proc^.Name = 'PRED' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if C^.VType^.atypeid = CSV_Enum then begin
        if C^.CV_Enum = 0 then begin
          StdProc := EOutOfRange;
        end else
          ChangeType(res, C^.VType)^.CV_Enum := C^.CV_Enum - 1;

      end else begin
        StdProc := ETypeMismatch;
        exit;
      end;
    end else if proc^.Name = 'SUCC' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if C^.VType^.atypeid = CSV_Enum then begin
        if C^.CV_Enum = Longint(C^.VType^.Ext) - 1 then begin
          StdProc := EOutOfRange;
        end else
          ChangeType(res, C^.VType)^.CV_Enum := C^.CV_Enum + 1;
      end else begin
        StdProc := ETypeMismatch;
        exit;
      end;
    end else if (proc^.Name = 'ORD') then begin
      C := GetVarLink(Vm_Get(Params, 0));
      if (C^.VType^.atypeid = CSV_Char) or (C^.VType^.atypeid = CSV_String) then begin
        i1 := mkchr(C);
        if i1 = -1 then begin
          StdProc := EOutOfRange;
          exit;
        end;
        ChangeType(res, Sender.GetType('LONGINT'));
        res^.Cv_SInt32 := i1;
      end else if (C^.VType^.atypeid = CSV_Enum) then begin
        ChangeType(res, Sender.GetType('LONGINT'));
        res^.Cv_SInt32 := C^.CV_Enum;
      end else begin
        StdProc := ETypeMismatch;
        exit;
      end;
    end else if proc^.Name = 'CHR' then begin
      res^.Cv_Char := Chr(GetInteger(GetVarLink(Vm_Get(Params, 0))));
    end else if proc^.Name = 'UPPERCASE' then begin
      SetString(res, FastUppercase(GetString(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'LOWERCASE' then begin
      SetString(res, FastLowercase(GetString(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'TRIM' then begin
      SetString(res, Trim(GetString(GetVarLink(Vm_Get(Params, 0)))));
    end else if (proc^.Name = 'POS') then begin
      SetInteger(res, Pos(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetString(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'INTTOSTR' then begin
      SetString(res, IntToStr(GetInteger(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'STRTOINT' then begin
      SetInteger(res, StrToIntDef(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'COPY' then begin
      SetString(res, copy(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetInteger(GetVarLink(Vm_Get(Params, 1))),
        GetInteger(GetVarLink(Vm_Get(Params, 2)))));
    end else if proc^.Name = 'LEFT' then begin
      SetString(res, copy(GetString(GetVarLink(Vm_Get(Params, 0))), 1,
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'DELETE' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      Delete(C^.Cv_Str, GetInteger(GetVarLink(Vm_Get(Params, 1))),
        GetInteger(GetVarLink(Vm_Get(Params, 2))));
    end else if proc^.Name = 'INSERT' then begin
      C := GetVarLink(Vm_Get(Params, 1));
      insert(GetString(GetVarLink(Vm_Get(Params, 0))), C^.Cv_Str,
        GetInteger(GetVarLink(Vm_Get(Params, 2))));
    end else if proc^.Name = 'SETARRAYLENGTH' then begin
      C := GetVarLink(Vm_Get(Params, 0));
      i1 := GetInteger(GetVarLink(Vm_Get(Params, 1)));
      if i1 > Sender.MaxArrayLength then begin
        StdProc := EOutOfMemoryError;
        exit;
      end;
      if i1 > Longint(C^.CV_ArrItems.Count) then begin
        i1 := i1 - Longint(C^.CV_ArrItems.Count);
        GetMem(x, i1 * SizeOf(PIfVariant)); { i1 * 4 }
        for I2 := 0 to i1 - 1 do begin
          x[I2] := CreateCajVariant(C^.VType^.Ext);
        end;
        C^.CV_ArrItems.AddBlock(x, i1);
        FreeMem(x, i1 * SizeOf(PIfVariant));
      end else if i1 < Longint(C^.CV_ArrItems.Count) then begin
        for I2 := 1 to Longint(C^.CV_ArrItems.Count) - i1 do begin
          DestroyCajVariant(C^.CV_ArrItems.GetItem(C^.CV_ArrItems.Count - 1));
          C^.CV_ArrItems.Delete(C^.CV_ArrItems.Count - 1);
        end;
      end;
    end else if proc^.Name = 'GETARRAYLENGTH' then begin
      SetInteger(res, GetVarLink(Vm_Get(Params, 0))^.CV_ArrItems.Count);
    end else if proc^.Name = 'LENGTH' then begin
      SetInteger(res, Length(GetString(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'SIN' then begin
      SetReal(res, Sin(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'COS' then begin
      SetReal(res, Cos(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'TAN' then begin
      SetReal(res, Sin(GetReal(GetVarLink(Vm_Get(Params, 0)))) / Cos(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'SQRT' then begin
      SetReal(res, Sqrt(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'PI' then begin
      SetReal(res, pi);
    end else if proc^.Name = 'ROUND' then begin
      SetInteger(res, Round(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'TRUNC' then begin
      SetInteger(res, Trunc(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'INT' then begin
      SetInteger(res, Trunc(GetReal(GetVarLink(Vm_Get(Params, 0))) + 0.5));
    end else if proc^.Name = 'ABS' then begin
      SetReal(res, Abs(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'SQRT' then begin
      SetReal(res, Sqrt(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.Name = 'FLOATTOSTR' then begin
      SetString(res, FloatToStr(GetReal(GetVarLink(Vm_Get(Params, 0)))));
    end else if proc^.name = 'STRTOFLOAT' then begin
      val(GetString(VM_Get(Params, 0)), res^.CV_Extended, i1);
      if i1 <> 0 then Res^.CV_Extended := 0;
    end else if proc^.Name = 'PADZ' then begin
      SetString(res, Padz(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'PADL' then begin
      SetString(res, Padl(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'PADR' then begin
      SetString(res, Padr(GetString(GetVarLink(Vm_Get(Params, 0))),
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else if proc^.Name = 'VERSION' then begin
      SetString(res, IFPSVersion);
    end else if (proc^.Name = 'REPLICATE') or (proc^.Name = 'STRINGOFCHAR') then begin
      cStr := GetString(GetVarLink(Vm_Get(Params, 0)));
      SetString(res, StringOfChar(cStr[1],
        GetInteger(GetVarLink(Vm_Get(Params, 1)))));

    end;

end;

procedure TIfPasScript.Cleanup;
var
  p: PIFPSResourceData;
{$IFNDEF NOCLASSES}
  p1: PCreatedClass;
{$ENDIF}
  I: Integer;
begin
  FLastException.ErrorCode := 0;
  FAttachedOnes.Clear;
  FBeginNesting := 0;
  VM_Clear(Variables);
  for I := Longint(FAllocatedResources.Count) - 1 downto 0 do begin
    p := FAllocatedResources.GetItem(I);
    p.FreeProc(fId, p.Data);
    Dispose(p);
  end;
  FAllocatedResources.Clear;
{$IFNDEF NOCLASSES}
  for I := 0 to Longint(CreatedClasses.Count) - 1 do begin
    p1 := CreatedClasses.GetItem(I);
    if not p1^.AlreadyFreed then begin
      VM_Destroy(p1^.Variables);
    end;
    Dispose(p1);
  end;
  CreatedClasses.Clear;
{$ENDIF}
  TM_Destroy(Types);
  Types := TM_Create;
  for I := 0 to Longint(FAttachedOnes.Count) - 1 do begin
    if TIfPasScript(FAttachedOnes.GetItem(I)).FFreeOnCleanup then
      TIfPasScript(FAttachedOnes.GetItem(I)).Free;
  end;
end;

//
//  Purpose: Adds a pointer to a needed resource
//
//-------------------------------------------------------------------

procedure TIfPasScript.AddResource(FreeProc: TResourceFree; Data: Pointer);
var
  p: PIFPSResourceData;
begin
  New(p);
  p^.Data := Data;
  p^.FreeProc := FreeProc;
  FAllocatedResources.Add(p);
end;

function TIfPasScript.FindResource(FreeProc: TResourceFree): Pointer;
var
  I: Longint;
  p: PIFPSResourceData;
begin
  for I := Longint(FAllocatedResources.Count) - 1 downto 0 do begin
    p := FAllocatedResources.GetItem(I);
    if @p^.FreeProc = @FreeProc then begin
      FindResource := p^.Data;
      exit;
    end;
  end;
  FindResource := nil;
end;

//
//  Purpose: Removes a resource pointer and cleans up the memory
//
//-------------------------------------------------------------------

procedure TIfPasScript.RemoveResource(Data: Pointer);
var
  I: Longint;
  p: PIFPSResourceData;
begin
  for I := Longint(FAllocatedResources.Count) - 1 downto 0 do begin
    p := FAllocatedResources.GetItem(I);
    if p^.Data = Data then begin
      FAllocatedResources.Delete(I);
      Dispose(p);
      break;
    end;
  end;
end;

//-------------------------------------------------------------------

function TIfPasScript.IsValidResource(FreeProc: TResourceFree; Data: Pointer): Boolean;
var
  I: Longint;
  p: PIFPSResourceData;
begin
  IsValidResource := True;

  for I := Longint(FAllocatedResources.Count) - 1 downto 0 do begin
    p := FAllocatedResources.GetItem(I);
    if (p^.Data = Data) and (@p^.FreeProc = @FreeProc)
      then exit;
  end;
  IsValidResource := False;
end;

function TIfPasScript.GetVariable(const Name: string): PIfVariant;
begin
  Result := Vm_Get(Variables, VM_Find(Variables, FastUppercase(Name)));
  // added by antp : if the variable is not found and if there are local variables, then use them
  if (Result = nil) and (CurrVars <> nil) then
    Result := Vm_Get(CurrVars, VM_Find(CurrVars, FastUppercase(Name)));
end;

function TIfPasScript.AddVariable(Name, FType: string; Constant: Boolean): PIfVariant;
var
  Parser: TIfPascalParser;
  ptype: PTypeRec;
  p: PIfVariant;
  E: TIFPARSERERROR;
begin
  Name := FastUppercase(Name);
  Parser := TIfPascalParser.Create;
  if not Parser.SetText(FType, E) then begin
    AddVariable := nil;
    Parser.Free;
    exit;
  end;
  Parser.CurrTokenPos := 0;
  ptype := ReadType(Parser, False, '');
  if ptype = nil then begin
    AddVariable := nil;
    RunError(Self, 0);
  end else begin
    if Constant then begin
      p := Vm_Add(Variables, CreateCajVariant(ptype), Name);
      p^.Flags := 1;
      AddVariable := p;
    end else
      AddVariable := Vm_Add(Variables, CreateCajVariant(ptype), Name);
  end;
  Parser.Free;
end;

function TIfPasScript.RemoveFunction(d: PProcedure): Boolean;
var
  I: Longint;
begin
  for I := Longint(Procedures.Count) - 1 downto 0 do begin
    if Procedures.GetItem(I) = d then begin
      Procedures.Delete(I);
      RemoveFunction := True;
      exit;
    end;
  end;
  RemoveFunction := False;
end;

function TIfPasScript.AddClassFunction(proc: TRegisteredProcObject; Decl: string; Ext: Pointer): PProcedure;
var
  Tmp: PProcedure;
begin
  Tmp := AddFunction(nil, Decl, Ext);
  Result := Tmp;
  if Tmp <> nil then Tmp^.proc2 := proc;
end;

function TIfPasScript.AddFunction(proc: Pointer; Decl: string; Ext: Pointer): PProcedure;
var
  Parser: TIfPascalParser;
  CurrVar: string;
  FuncName,
    Temp,
    FuncParam: string;
  FuncRes,
    CurrType: Longint;
  E: TIFPARSERERROR;

begin
  Parser := TIfPascalParser.Create;
  AddFunction := nil;
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
      if Parser.CurrTokenId = CSTII_Var then begin
        CurrVar := '!';
        Parser.Next;
      end else {if}
        if Parser.CurrTokenId = CSTII_Const then begin
          CurrVar := '^';
          Parser.Next;
        end; {if}
      while True do begin
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

      CurrType := Longint(ReadType(Parser, False, ''));
      if Pos('!', CurrVar) = 1 then begin
        Delete(CurrVar, 1, 1);
        while Pos('|', CurrVar) > 0 do begin
          Temp := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #1 + mi2s(Length(Temp)) + Temp + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end else if Pos('^', CurrVar) = 1 then begin
        Delete(CurrVar, 1, 1);
        while Pos('|', CurrVar) > 0 do begin
          Temp := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #2 + mi2s(Length(Temp)) + Temp + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end else begin
        while Pos('|', CurrVar) > 0 do begin
          Temp := copy(CurrVar, 1, Pos('|', CurrVar) - 1);
          FuncParam := FuncParam + #0 + mi2s(Length(Temp)) + Temp + mi2s(CurrType);
          Delete(CurrVar, 1, Pos('|', CurrVar));
        end; {while}
      end; {if}
      if Parser.CurrTokenId = CSTI_CloseRound then begin
        Parser.Next;
        break;
      end; {if}
      Parser.Next;
    end;
  end;
  if FuncRes = 1 then begin
    Parser.Next;
    FuncRes := Longint(ReadType(Parser, False, ''));
  end;
  FuncParam := mi2s(FuncRes) + FuncParam;
  AddFunction := PM_AddExt(Procedures, Self, FuncName, FuncParam, {$IFNDEF NOCLASSES}nil, {$ENDIF}Ext, proc);
  Parser.Free;
end;

function TIfPasScript.CreateReal(const E: Extended): PIfVariant;
var
  p: PIfVariant;
begin
  p := CreateCajVariant(TM_Add(Types, '', CSV_Extended, nil));
  p^.Cv_Extended := E;
  CreateReal := p;
end;

function TIfPasScript.CreateString(const s: string): PIfVariant;
var
  p: PIfVariant;
begin
  p := CreateCajVariant(TM_Add(Types, '', CSV_String, nil));
  p^.Cv_Str := s;
  CreateString := p;
end;

function TIfPasScript.CreateVarType(p: PIfVariant): PIfVariant;
var
  n: PIfVariant;
begin
  n := CreateCajVariant(TM_Add(Types, '', CSV_Var, nil));
  n^.CV_Var := GetVarLink(p);
  CreateVarType := n;
end;

function TIfPasScript.CreateInteger(I: Longint): PIfVariant;
var
  p: PIfVariant;
begin
  p := CreateCajVariant(TM_Add(Types, '', CSV_SInt32, nil));
  p^.Cv_SInt32 := I;
  CreateInteger := p;
end;

function TIfPasScript.CreateBool(b: Boolean): PIfVariant;
var
  p: PIfVariant;
begin
  p := CreateCajVariant(TM_Add(Types, '', CSV_Bool, nil));
  p^.Cv_Bool := b;
  CreateBool := p;
end;

//
//  Purpose: Adds various internal function calls
//
//-------------------------------------------------------------------

procedure RegisterExceptionLib(Sender: TIfPasScript);

begin
  Sender.AddFunction(@ExProc, 'function GetLastErrorCode: word;', nil);
  Sender.AddFunction(@ExProc, 'function GetLastErrorParam: string;', nil);
  Sender.AddFunction(@ExProc, 'function GetLastErrorModule: string;', nil);
  Sender.AddFunction(@ExProc, 'function GetLastErrorAsString: string;', nil);
  Sender.AddFunction(@ExProc, 'procedure RaiseError(ErrorCode: Word; Param: string);', nil);
  Sender.AddFunction(@ExProc, 'function GetLastErrorPosition: Longint;', nil);

end;
//
//  Purpose: Adds various internal function calls
//
//-------------------------------------------------------------------

procedure RegisterStdLib(p: TIfPasScript; OnlySafe: Boolean);
{Register standard library}
begin
  p.AddFunction(@StdProc, 'function StrGet(var s: string; I: Longint): char', nil);
  p.AddFunction(@StdProc, 'procedure StrSet(c: char; i: Longint; var s: string): char', nil);
  p.AddFunction(@StdProc, 'function Chr(b: Byte): Char', nil);
  p.AddFunction(@StdProc, 'function StrToInt(s: string; I: Longint): Integer', nil);
  p.AddFunction(@StdProc, 'function IntToStr(i: Longint): string', nil);
  p.AddFunction(@StdProc, 'function Uppercase(s: string): string', nil);
  p.AddFunction(@StdProc, 'function Copy(s: string; i1, i2: Longint): string', nil);
  p.AddFunction(@StdProc, 'procedure Delete(var s: string; i1,i2: Longint)', nil);
  p.AddFunction(@StdProc, 'procedure Insert(s1: string; var s: string; i1: Longint)', nil);
  p.AddFunction(@StdProc, 'function Pos(s1, s2: string): Longint', nil);
  p.AddFunction(@StdProc, 'function Length(s: string): Longint', nil);
  p.AddFunction(@StdProc, 'function LowerCase(s: string): string', nil);
  p.AddFunction(@StdProc, 'function Trim(s: string): string', nil);
  p.AddFunction(@StdProc, 'function Int(s: Extended): Longint', nil);
  p.AddFunction(@StdProc, 'function FloatToStr(s: Extended): string', nil);
  p.AddFunction(@StdProc, 'function StrToFloat(s: string): Extended;', nil);
  p.AddFunction(@StdProc, 'function replicate(s: string; i: Longint): string', nil);
  p.AddFunction(@StdProc, 'function Version: string', nil);
  p.AddFunction(@StdProc, 'function Left(s: string; i: Longint): string', nil);
  p.AddFunction(@StdProc, 'function StringOfChar(s: string; i: Integer): string', nil);
  p.AddFunction(@StdProc, 'procedure SetLength(var S: String; L: Longint);', nil);
  p.AddFunction(@StdProc, 'function abs(s: extended): extended;', nil);
  PM_AddExt(p.Procedures, p, 'GETTYPE', mi2s(Longint(TM_Get(p.Types, 'STRING'))) + #0#5#0#0#0'MYVAR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'GETARRAYLENGTH', mi2s(Longint(TM_Get(p.Types, 'LONGINT'))) + #1#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!ARRAY'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'SETARRAYLENGTH', #0#0#0#0#1#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!ARRAY'))) + #0#6#0#0#0'NEWLEN' + mi2s(Longint(TM_Get(p.Types, 'LONGINT'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'ASSIGNED', mi2s(Longint(TM_Get(p.Types, 'BOOLEAN'))) + #0#5#0#0#0'MYVAR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);

  PM_AddExt(p.Procedures, p, 'LOW', mi2s(Longint(TM_Get(p.Types, '!VAR'))) + #2#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'HIGH', mi2s(Longint(TM_Get(p.Types, '!VAR'))) + #2#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'ORD', mi2s(Longint(TM_Get(p.Types, 'LONGINT'))) + #0#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'PRED', mi2s(Longint(TM_Get(p.Types, '!VAR'))) + #0#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  PM_AddExt(p.Procedures, p, 'SUCC', mi2s(Longint(TM_Get(p.Types, '!VAR'))) + #0#3#0#0#0'ARR' + mi2s(Longint(TM_Get(p.Types, '!VAR'))), {$IFNDEF NOCLASSES}nil, {$ENDIF}nil, @StdProc);
  if not OnlySafe then begin
    p.AddFunction(@StdProc, 'function sin(s: Extended): Extended', nil);
    p.AddFunction(@StdProc, 'function cos(s: Extended): Extended', nil);
    p.AddFunction(@StdProc, 'function tan(s: Extended): Extended', nil);
    p.AddFunction(@StdProc, 'function SQRT(s: Extended): Extended', nil);
    p.AddFunction(@StdProc, 'function Round(s: Extended): Longint', nil);
    p.AddFunction(@StdProc, 'function Trunc(s: Extended): Longint', nil);
    p.AddFunction(@StdProc, 'function PI: Extended', nil);
  end;
end;
//-------------------------------------------------------------------

procedure TIfPasScript.AddStandard;
var
{$IFNDEF NOCLASSES}
  TObjClass: PIFSClassType;
  n: PProcedure;
{$ENDIF}
  u: PTypeRec;
begin
  TM_Add(Types, 'BYTE', CSV_UByte, nil);
  TM_Add(Types, 'SHORTINT', CSV_SByte, nil);
  TM_Add(Types, 'CHAR', CSV_Char, nil);
  TM_Add(Types, 'WORD', CSV_UInt16, nil);
  TM_Add(Types, 'SMALLINT', CSV_SInt16, nil);
  TM_Add(Types, 'CARDINAL', CSV_UInt32, nil);
  u := TM_Add(Types, 'LONGINT', CSV_SInt32, nil);
  TM_Add(Types, 'INTEGER', CSV_TypeCopy, u);
  TM_Add(Types, 'STRING', CSV_String, nil);
  TM_Add(Types, 'REAL', CSV_Real, nil);
  TM_Add(Types, 'SINGLE', CSV_Single, nil);
  TM_Add(Types, 'DOUBLE', CSV_Double, nil);
  TM_Add(Types, 'EXTENDED', CSV_Extended, nil);
  TM_Add(Types, 'COMP', CSV_Comp, nil);
  TM_Add(Types, 'BOOLEAN', CSV_Bool, nil);
  TM_Add(Types, 'RESOURCEPOINTER', CSV_Internal, nil); // can be used for resources (See AddResource)

  TM_Add(Types, '!ARRAY', CSV_Array, nil); // only for internal use! (SetArrayLength; GetArrayLength)
  TM_Add(Types, '!VAR', CSV_Var, nil); // only for internal use! (GetType)
{$IFDEF VARIANTSUPPORT}
  TM_Add(Types, 'VARIANT', CSV_Variant, nil);
{$ENDIF}
{$IFNDEF NOCLASSES}
  New(TObjClass);
  TObjClass.InheritsFrom := nil;
  TObjClass.VarNoStart := 0;
  TObjClass.VarCount := 0;
  TObjClass.Variables.u := '';
  TObjClass.PropStart := 0;
  TObjClass.Procedures := TIfList.Create;
  TObjClass.Properties := TIfList.Create;
  u := TM_Add(Types, 'TOBJECT', CSV_Class, TObjClass);
  n := AddFunction(@TObjProc, 'procedure Create', TObjClass);
  n^.Flags := $40 or $2; {public Constructor}
  n^.Name := '!' + n^.Name;
  n^.ClassType := u;
  TObjClass.Procedures.Add(n);
  n := AddFunction(@TObjProc, 'procedure Destroy', TObjClass);
  n^.Flags := $80 or $10 or $2; {Public virtualstart destructor}
  n^.ClassType := u;
  n^.Name := '!' + n^.Name;
  TObjClass.Procedures.Add(n);
  n := AddFunction(@TObjProc, 'procedure Free', TObjClass);
  n^.Flags := $2; {Public}
  n^.ClassType := u;
  n^.Name := '!' + n^.Name;
  TObjClass.Procedures.Add(n);
  n := AddFunction(@TObjProc, 'function ClassNameIs(ftype: string): Boolean', TObjClass);
  n^.Flags := $2; {Public}
  n^.ClassType := u;
  n^.Name := '!' + n^.Name;
  TObjClass.Procedures.Add(n);
  n := AddFunction(@TObjProc, 'function ClassName: String', TObjClass);
  n^.Flags := $2; {Public}
  n^.ClassType := u;
  n^.Name := '!' + n^.Name;
  TObjClass.Procedures.Add(n);
  n := AddFunction(@TObjProc, 'function GetAncestors: string', TObjClass);
  n^.Flags := $2; {Public}
  n^.ClassType := u;
  n^.Name := '!' + n^.Name;
  TObjClass.Procedures.Add(n);
{$ENDIF}
end;
//-------------------------------------------------------------------

function TIfPasScript.GetFunction(s: string): PProcedure;
{$IFNDEF NOCLASSES}
var
  ptype: PTypeRec;
  p: PProcedure;
{$ENDIF}
begin
{$IFNDEF NOCLASSES}
  if Pos('.', s) > 0 then begin
    ptype := GetType(FastUppercase(copy(s, 1, Pos('.', s) - 1)));
    Delete(s, 1, Pos('.', s));
    if ptype^.atypeid = CSV_Class then begin
      if GetClassProcedure(nil, ptype^.Ext, FastUppercase(s), p, True) then
        GetFunction := p
      else
        GetFunction := nil;
    end else
      GetFunction := nil;
  end else begin
{$ENDIF}
    GetFunction := PM_Get(Procedures, PM_Find(Procedures, FastUppercase(s)));
{$IFNDEF NOCLASSES} end;
{$ENDIF}
end;
//-------------------------------------------------------------------

function TIfPasScript.CopyVariant(p: PIfVariant): PIfVariant;
var
  r: PIfVariant;
begin
  if p = nil then begin
    CopyVariant := nil;
    exit;
  end;
{$IFNDEF NOCLASSES}
  if p^.VType^.atypeid = CSV_Property then begin
    p := GetProperty(p);
    if p = nil then begin
      CopyVariant := nil;
      exit;
    end;
    CopyVariant := p;
  end else begin
{$ENDIF}
    r := CreateCajVariant(p^.VType);
    Perform(r, p, PtSet);
    CopyVariant := r;
{$IFNDEF NOCLASSES}
  end;
{$ENDIF}
end;
//-------------------------------------------------------------------
{$IFDEF VARIANTSUPPORT}

function TIfPasScript.VariantToIFVariant(const v: Variant; res: PIfVariant): Boolean;
var
  f: Word;
  I: Longint;
  l: PIfVariant;
begin
  f := VarType(v);
  VariantToIFVariant := True;
  if (f and varArray) = 0 then begin
    case f and varTypeMask of
{$IFDEF USEIDISPATCH}
      varDispatch: begin
          if assigned(IDispatchToIFVariantProc) then
            VariantToIFVariant := IDispatchToIFVariantProc(Self, res, v)
          else
            VariantToIFVariant := False;
        end;
{$ENDIF}
      varEmpty, varNull: ChangeType(res, TM_Add(Types, '', CSV_Special, nil))^.CV_Spec := 0; {nil}
      varSmallInt: ChangeType(res, TM_Add(Types, '', CSV_SInt16, nil))^.Cv_SInt16 := v;
      varInteger: ChangeType(res, TM_Add(Types, '', CSV_SInt32, nil))^.Cv_SInt32 := v;
      varSingle: ChangeType(res, TM_Add(Types, '', CSV_Single, nil))^.CV_Single := v;
      varDouble, VarDate: ChangeType(res, TM_Add(Types, '', CSV_Double, nil))^.CV_Double := v;
      varBoolean: ChangeType(res, TM_Add(Types, '', CSV_Bool, nil))^.Cv_Bool := v;
      varByte: ChangeType(res, TM_Add(Types, '', CSV_UByte, nil))^.Cv_UByte := v;
      varString: ChangeType(res, TM_Add(Types, '', CSV_String, nil))^.Cv_Str := v;
      varOleStr: ChangeType(res, TM_Add(Types, '', CSV_String, nil))^.Cv_Str := v;
    else begin
        VariantToIFVariant := False;
      end;
    end;
  end else begin
    if VarArrayDimCount(v) > 0 then begin
      VariantToIFVariant := False;
      exit;
    end;
    ChangeType(res, TM_Add(Types, '', CSV_Array, res^.VType));
    for I := VarArrayLowBound(v, 0) to VarArrayHighBound(v, 0) do begin
      l := CreateVarType(nil);
      res.CV_ArrItems.Add(l);
      if not VariantToIFVariant(v[I], l) then begin
        VariantToIFVariant := False;
        exit;
      end;
    end;
  end;
end;

function TIfPasScript.IfVariantToVariant(v: PIfVariant; var res: Variant): Boolean;
var
  I: Longint;
  q: Variant;
{$IFNDEF NOCLASSES}{$IFDEF USEIDISPATCH}n: IDispatch;
{$ENDIF}{$ENDIF}
begin
  if v = nil then begin
    res := null;
    IfVariantToVariant := True;
    exit;
  end;
  v := GetVarLink(v);
  res := Unassigned;
  IfVariantToVariant := True;
  if v^.VType^.atypeid = CSV_Variant then begin
    v := v^.CV_Variant;
  end;
  if v^.VType^.atypeid = CSV_Array then begin
    if (PTypeRec(v^.VType^.Ext)^.atypeid = CSV_Array) or (PTypeRec(v^.VType^.Ext)^.atypeid = CSV_Var) then begin
      IfVariantToVariant := False;
    end;
    res := VarArrayCreate([0, v^.CV_ArrItems.Count - 1], varVariant);
    for I := 0 to Longint(v^.CV_ArrItems.Count) - 1 do begin
      if IfVariantToVariant(v^.CV_ArrItems.GetItem(I), q) then
        res[I] := q
      else begin
        IfVariantToVariant := False;
        res := null;
      end;
    end;
  end else begin
    case v^.VType^.atypeid of
      CSV_Special: res := null;
      CSV_UByte: res := v^.Cv_UByte;
      CSV_SByte: res := v^.Cv_SByte;
      CSV_UInt16: res := v^.Cv_UInt16;
      CSV_SInt16: res := v^.Cv_SInt16;
      CSV_UInt32: res := Longint(v^.Cv_UInt32);
      CSV_SInt32: res := v^.Cv_SInt32;
      CSV_Char: res := v^.Cv_Char;
      CSV_String: res := v^.Cv_Str;
      CSV_Real: res := v^.CV_Real;
      CSV_Single: res := v^.CV_Single;
      CSV_Double: res := v^.CV_Double;
      CSV_Extended: res := v^.Cv_Extended;
      CSV_Comp: res := v^.CV_comp;
      CSV_Bool: res := v^.Cv_Bool;
{$IFNDEF NOCLASSES}
{$IFDEF USEIDISPATCH}
      CSV_ExternalObject: begin
          if assigned(IFVariantToIDispatchProc) then begin
            if IFVariantToIDispatchProc(Self, n, v) then
              res := n
            else
              IfVariantToVariant := False;
          end else
            IfVariantToVariant := False;
        end;
{$ENDIF}
{$ENDIF}
    else
      IfVariantToVariant := False;
    end;
  end;
end;

function TIfPasScript.CallFunction(p: PProcedure; Params: array of Variant): Variant;
var
  RealParams: PVariableManager;
  I: Longint;
  n: PIfVariant;
  a: Variant;
begin
  RunError(Self, 0);
{$IFNDEF NOCLASSES}
  if assigned(p^.ClassType) then begin // use CallMethod instead
    FError.ErrorCode := ETypeMismatch;
    FError.ErrorPosition := -1;
    exit;
  end;
{$ENDIF}
  CallFunction := null;
  RealParams := VM_Create;
  for I := Low(Params) to High(Params) do begin
    n := CreateVarType(nil);
    Vm_Add(RealParams, n, '');
    if not VariantToIFVariant(Params[I], n) then begin
      FError.ErrorCode := ETypeMismatch;
      FError.ErrorPosition := -1;
      VM_Destroy(RealParams);
      CallFunction := null;
      exit;
    end;
  end;
  n := RunScriptProc(p, RealParams);
  VM_Destroy(RealParams);
  IfVariantToVariant(n, a);
  DestroyCajVariant(n);
  CallFunction := a;
end;

//-------------------------------------------------------------------
{$IFNDEF NOCLASSES}

function TIfPasScript.CallMethod(p: PProcedure; Myself: PCreatedClass; Params: array of Variant): Variant;
var
  RealParams: PVariableManager;
  I: Longint;
  n: PIfVariant;
  a: Variant;
begin
  RunError(Self, 0);
  if not assigned(p^.ClassType) then begin // use CallFunction instead
    FError.ErrorCode := ETypeMismatch;
    FError.ErrorPosition := -1;
    exit;
  end;
  CallMethod := null;
  RealParams := VM_Create;
  n := CreateCajVariant(Myself^.ClassType);
  n^.CV_Class := Myself;
  Vm_Add(RealParams, n, 'SELF');
  for I := Low(Params) to High(Params) do begin
    n := CreateVarType(nil);
    Vm_Add(RealParams, n, '');
    if not VariantToIFVariant(Params[I], n) then begin
      FError.ErrorCode := ETypeMismatch;
      FError.ErrorPosition := -1;
      VM_Destroy(RealParams);
      CallMethod := null;
      exit;
    end;
  end;
  n := RunScriptProc(p, RealParams);
  VM_Destroy(RealParams);
  IfVariantToVariant(n, a);
  DestroyCajVariant(n);
  CallMethod := a;
end;

{$ENDIF}
{$ENDIF}

//-------------------------------------------------------------------

function TIfPasScript.Attach(ScriptEngine: TIfPasScript): Boolean;
begin
  Attach := Attach2(ScriptEngine, True);
end;

function TIfPasScript.Attach2(ScriptEngine: TIfPasScript; FreeOnCleanup: Boolean): Boolean;
var
  I: Longint;
  nt: PTypeRec;
  Nc: PIfVariant;
  np: PProcedure;
begin
  if (ScriptEngine = nil) or (ScriptEngine = Self) or (ScriptEngine.MainOffset = -1) or (not ScriptEngine.IsUnit) then begin
    Attach2 := False;
    exit;
  end;
  for I := 0 to Longint(FAttachedOnes.Count) - 1 do begin
    if FastUppercase(TIfPasScript(FAttachedOnes.GetItem(I)).ModuleName) = (ScriptEngine.ModuleName) then begin
      Attach2 := False;
      exit;
    end;
  end;
  ScriptEngine.FFreeOnCleanup := FreeOnCleanup;
  for I := 0 to Longint(ScriptEngine.Types.List.Count) - 1 do begin
    nt := ScriptEngine.Types.List.GetItem(I);
    TM_Add(Types, nt^.Ident, CSV_TypeCopy, nt);
  end;
  for I := 0 to VM_Count(ScriptEngine.Variables) - 1 do begin
    Nc := Vm_Get(ScriptEngine.Variables, I);
    if VM_Find(Variables, VM_GetName(ScriptEngine.Variables, I)) = -1 then begin
      Vm_Add(Variables, CreateVarType(Nc), VM_GetName(ScriptEngine.Variables, I));
    end;
  end;
  for I := 0 to Longint(ScriptEngine.Procedures.Count) - 1 do begin
    np := ScriptEngine.Procedures.GetItem(I);
    if np^.Mode = 0 then
      PM_AddInt(Procedures, np^.FScriptEngine, np^.Name, np^.Decl, {$IFNDEF NOCLASSES}np^.ClassType, {$ENDIF}np^._Ext, np^.offset)^.Flags := np^.Flags
    else
      PM_AddExt(Procedures, np^.FScriptEngine, np^.Name, np^.Decl, {$IFNDEF NOCLASSES}np^.ClassType, {$ENDIF}np^._Ext, @np^.proc1)^.Flags := np^.Flags;
  end;
  FAttachedOnes.Add(ScriptEngine);
  Attach2 := True;
end;
//-------------------------------------------------------------------

function TIfPasScript.GetType(const s: string): PTypeRec;
begin
  GetType := GetTypeLink(TM_Get(Types, FastUppercase(s)));
end;
//-------------------------------------------------------------------
{$IFNDEF NOCLASSES}

function GetInheritedProc(CurrProc: PProcedure): PProcedure;
var
  p: PIFSClassType;
  n: PProcedure;
  I: Integer;
begin
  p := PTypeRec(CurrProc^.ClassType)^.Ext;
  repeat
    p := p^.InheritsFrom^.Ext;
    for I := 0 to Longint(p^.Procedures.Count) - 1 do begin
      n := p^.Procedures.GetItem(I);
      if n^.Name = CurrProc^.Name then begin
        GetInheritedProc := n;
        exit;
      end;
    end;
  until p = nil;
  GetInheritedProc := nil;
end;
{$ENDIF}

function TIfPasScript.GetCurrProc: PProcedure;
begin
  if Longint(ProcStack.Count) > 0 then
    GetCurrProc := ProcStack.GetItem(ProcStack.Count - 1)
  else
    GetCurrProc := nil;
end;

function TIfPasScript.PopProcStack: PProcedure;
begin
  if ProcStack.Count > 0 then begin
    PopProcStack := ProcStack.GetItem(ProcStack.Count - 1);
    ProcStack.Delete(ProcStack.Count - 1);
  end else
    PopProcStack := nil;
end;

function TIfPasScript.ExecRunLine: Boolean;
begin
  if @FOnRunLine <> nil then begin
    RunError(Self, FOnRunLine(fId, Self, Parser.CurrTokenPos));
    ExecRunLine := FError.ErrorCode <> ENoError;
  end else
    ExecRunLine := False;
end;

procedure SetArrayLength(fVar: PIfVariant; NewLength: Longint);
var
  I: Longint;
  x: PPointerList;

begin
  if (NewLength > Longint(fVar^.CV_ArrItems.Count)) then begin
    NewLength := NewLength - Longint(fVar^.CV_ArrItems.Count);
    GetMem(x, NewLength * SizeOf(PIfVariant)); { i1 * 4 }
    for I := 0 to NewLength - 1 do begin
      x[I] := CreateCajVariant(fVar^.VType^.Ext);
    end;
    fVar^.CV_ArrItems.AddBlock(x, NewLength);
    FreeMem(x, NewLength * SizeOf(PIfVariant));
  end else if NewLength < Longint(fVar^.CV_ArrItems.Count) then begin
    for I := 1 to Longint(fVar^.CV_ArrItems.Count) - NewLength do begin
      DestroyCajVariant(fVar^.CV_ArrItems.GetItem(fVar^.CV_ArrItems.Count - 1));
      fVar^.CV_ArrItems.Delete(fVar^.CV_ArrItems.Count - 1);
    end;
  end;
end;

end.

