//  Filename: ifs_var.pas
//  Author: Carlo Kok (ckok.1@hccnet.nl)
//
// Innerfuse Pascal Script Variable management, Procedure management and Type Management

unit ifs_var;
{$I ifs_def.inc}

interface

uses
  SysUtils, ifs_utl;

type
  TIfPasScriptError = Word;
  TCS2Error = TIfPasScriptError;

const
  ERuntimeError = 32768;
  ECompileError = 1;

  ENoError = 0;
  ECanNotReadProperty = 1;
  ECanNotWriteProperty = 2;
  EUnknownIdentifier = 3;
  EIdentifierExpected = 4;
  ESemicolonExpected = 5;
  EBeginExpected = 6;
  EDuplicateIdentifier = 7;
  EUnexpectedEndOfFile = 8;
  EColonExpected = 9;
  ESyntaxError = 10;
  EStringError = 11;
  EErrorInStatement = 12;
  EAssignmentExpected = 13;
  ETypeMismatch = 14;
  EErrorInExpression = 15;
  ERoundOpenExpected = 16;
  ERoundCloseExpected = 17;
  EVariableExpected = 18;
  ECommaExpected = 19;
  EThenExpected = 20;
  EPeriodExpected = 21;
  EParameterError = 22;
  EToExpected = 23;
  EDoExpected = 24;
  EOfExpected = 25;
  EEndExpected = 26;
  EOpenBlockExpected = 27;
  ECloseBlockExpected = 28;
  EConstantExpected = 29;
  EIsExpected = 30;
  EIntegerExpected = 31;
  ECloseRoundExpected = 32;
  EUntilExpected = 33;
  {$IFNDEF NOCLASSES}
  EClassNotAllowedHere = 34;
  EClassTypeExpected = 35;
  ECanNotOverride = 36;
  EConstructorExpected = 38;
  ENoInheritedAllowedHere = 39;
  ECanNotReadOrWriteProperty = 40;
  EObjectExpected = 41;
  {$ENDIF}
  EUnsatisfiedForward = 37;
  ECommentError = 42;
  ECharError = 43;
  EExceptExpected = 44;
  EStringExpected = 45;

  EUnitNotFound = ERuntimeError + 0;
  EClassNotCreated = ERuntimeError + 1;
  EOutOfRange = ERuntimeError + 2;
  EDivideByZero = ERuntimeError + 3;
  ENotSupported = ERuntimeError + 4;
  EExitCommand = ERuntimeError + 5;
  EClassAlreadyFreed = ERuntimeError + 6;
  EClassReferenceNotAssigned = ERuntimeError + 7;
{$IFNDEF NOVARIANTS}
  EVariantIsNil = ERuntimeError + 8;
{$ENDIF}
  ECustomError = ERuntimeError + 9;
  EOutOfMemoryError = ERuntimeError + 10;

const
  CSV_NONE = 0; { Void/ERROR }
  CSV_UByte = 1; { Byte }
  CSV_SByte = 2; { ShortInt }
  CSV_UInt16 = 3; { Word }
  CSV_SInt16 = 4; { Integer (Delphi : SmallInt) }
  CSV_UInt32 = 5; { Longint (Delphi : Cardinal) }
  CSV_SInt32 = 6; { Longint }
  CSV_Char = 7; { Char }
  CSV_String = 8; { String }
  CSV_Real = 9; { Real }
  CSV_Single = 10; { Single }
  CSV_Double = 11; { Double }
  CSV_Extended = 12; { Extended }
  CSV_Comp = 13; { Comp }
  CSV_Bool = 14; { Boolean }
  CSV_Var = 15; { Variable in function call }
  CSV_Array = 16; { Array }
  CSV_Record = 17; { Record }
  CSV_Internal = 19; { Internal }
  {$IFNDEF NOCLASSES}
  CSV_Class = 18; { Class }
  CSV_ClassRef = 20; { Class of Class }
  CSV_Property = 21; { Property }
  {$ENDIF}
  CSV_TypeCopy = 22;
  CSV_ProcVariable = 23;
  CSV_Special = 24;
  {$IFNDEF NOCLASSES}
  CSV_ExternalObject = 25;
  CSV_ExternalObjectProperty = 26;
  {$ENDIF}
{$IFNDEF NOVARIANTS}
  CSV_Variant = 28;
{$ENDIF}
  CSV_Enum = 29;

type
  PTypeManager = ^TTypeManager;
  TTypeManager = packed record
    List: TIfList;
  end;
  PTypeRec = ^TTypeRec;
  TTypeRec = record
    Ident: string;
    identhash: cardinal;
    atypeid: Word;
    ext: Pointer;
    { When using records, this will be a pointer to a TIFSRecordType type,
     using string, it is used for the dll call library: 0 = normal string and 1 = pchar
     using arrays it will be a Pointer to TTypeRec
     using classes it will be a pointer to TIfsClassType
     using classreferences it will be a pointer to an TTypeRec
     using property it will be a pointer to the type of the property
     using TypeCopy it will be a pointer an other PTyperec
     using ProcVariable it will be a pointer to a TIfsProcType
     using ExternalObject it will be a TIfsExtClass
    }
  end;

  PIFSProcType = ^TIfsProcType;
  TIfsProcType = packed record
    Decl: string;
    Method: Boolean;
  end;

  PIFSRecordType = ^TIFSRecordType;
  TIFSRecordType = packed record
    u: string; // stored like 'Name1 Type1 Name2 Type2' Types as pointers casted to longints.
  end;


  {$IFNDEF NOCLASSES}
  PIFSClassType = ^TIFSClassType;
  TIFSClassType = packed record
    InheritsFrom: PTypeRec; {until it's nil}
    PropStart, VarNoStart, VarCount: Cardinal; { Used in the variable manager; It's for finding the fields of the class}
    Variables: TIFsRecordType;
    {
      Things before name:                    
      1 Private
      2 Public
      3 Protected
    }
    Properties: TIFList; { of PPropertyDef }
    Procedures: TIfList; { of PProcedure }
    { Flags:
       $1    = Private
       $2    = Public
       $1+$2 = Protected
       $10   = Virtual begin
       $20   = Virtual override
       $40   = Constructor
       $80   = Destructor
    }
    Ext: Pointer;
  end;
  PCreatedClass = ^TCreatedClass;
  TCreatedClass = packed record
    Variables: Pointer;{TVariableManager}
    ClassType: PTypeRec;
    AlreadyFreed: Boolean;
    Ext: Pointer;
  end;

  PPropertyDef = ^TPropertyDef;
  TPropertyDef = packed record
    Name: string;
    CV_Type: PTypeRec;
    Cv_PropRead,
    CV_PropWrite: Pointer;
    CV_PropFlags: Word;
      { CSV_Property flags:
         $1 = Readable
         $2 = Writeable
         $4 = CV_Read = Procedure (if not CV_Read = Longint(no) absolute number in TCreatedClass.Variables )
         $8 = CV_Write = Procedure (if not CV_Write = Longint(no) absolute number in TCreatedClass.Variables )
         $10 = Private
         $20 = Public
         $30 = Protected
      }
   end;
  {$ENDIF}

  TCSV_UByte = Byte;
  TCSV_SByte = ShortInt;
  TCSV_Char = Char;
  TCSV_UInt16 = Word;
  TCSV_SInt16 = SmallInt;
  TCSV_UInt32 = Cardinal;
  TCSV_SInt32 = Longint;
  PIfVariant = ^TCajVariant;
  PCajVariant = PIfVariant;
  TIfVariant = packed record
    VType: PTypeRec;
    Flags: Byte;
    {
      Readonly(Const) = 1
      Only for classes:
      $2    Private
      $4    Public
      $2+$4 Protected

    }
    CV_Str: string;
    case Word of
      CSV_UByte: (CV_UByte: TCSV_UByte);
      CSV_SByte: (CV_SByte: TCSV_SByte);
      CSV_Char: (CV_Char: TCSV_Char);
      CSV_UInt16: (CV_UInt16: TCSV_UInt16);
      CSV_SInt16: (CV_SInt16: TCSV_SInt16);
      CSV_UInt32: (CV_UInt32: TCSV_UInt32);
      CSV_SInt32: (CV_SInt32: TCSV_SInt32);
      CSV_String: ();
      CSV_Real: (CV_Real: Real);
      CSV_Single: (CV_Single: Single);
      CSV_Double: (CV_Double: Double);
      CSV_Extended: (CV_Extended: Extended);
      CSV_Comp: (CV_Comp: Comp);
      CSV_Bool: (CV_Bool: Boolean);
      CSV_Var: (CV_Var: Pointer); {Pointer to a CajVariant}
      CSV_Array: (CV_ArrItems: TifList); {of PIfVariant}
      CSV_Record: (CV_RecItems: TIfList); {of PIfVariant}
  {$IFNDEF NOCLASSES}
      CSV_Class: (CV_Class: PCreatedClass);
      CSV_ClassRef: (Cv_ClassRef: PTypeRec);
      CSV_Property: (CV_Self, Cv_PropRead, CV_PropWrite: Pointer; CV_PropFlags: Word);
  {$ENDIF}
      CSV_Internal: (Cv_Int1,CV_Int2: Pointer);
      CSV_ProcVariable: (Cv_Proc: pointer{$IFNDEF NOCLASSES};Cv_ProcSelf: PCreatedClass{$ENDIF});
      CSV_Special: (CV_Spec: Byte { 0 = nil pointer });
  {$IFNDEF NOCLASSES}
      CSV_ExternalObject: (CV_ExternalObject: Pointer {PIFSExternalObject});
      CSV_ExternalObjectProperty: (CV_ExtObj: Pointer; CV_PropertyNo: Longint);
  {$ENDIF}
  {$IFNDEF NOVARIANTS}
      CSV_Variant: (CV_Variant: PIfVariant); // always created!
  {$ENDIF}
      CSV_Enum: (CV_Enum: Longint);
  end;
  TCajVariant = TIfVariant;
{ Array:
  SubType(s): IntToStr(TypeNo);
}
function CreateCajVariant(PType: PTypeRec): PIfVariant;
procedure DestroyCajVariant(p: PIfVariant);
function ChangeType(p: PIfVariant; newtype: PTypeRec): PIfVariant;
{Changetype changes the type of p but also returns P}

type
  PIFNamedVariable = ^TIFNamedVariable;
  TIFNamedVariable = packed record
    Name: string;
    NameHash: Cardinal;
    FVar: PIFVariant;
  end;
  TVariableManager = TIFList;
  PVariableManager = TVariableManager;

function VM_Create: PVariableManager;
procedure VM_Destroy(p: PVariableManager);
function VM_Add(P: PVariableManager; D: PIfVariant; const Name: string): PIfVariant;
procedure VM_Delete(p: PVariableManager; Idx: LongInt);
function VM_Insert(P: PVariableManager; Idx: Longint; D: PIfVariant; const Name: string): PIFVariant;
function VM_Get(p: PVariableManager; Idx: LongInt): PIfVariant;
function VM_Get2(p: PVariableManager; Idx: LongInt): PIfVariant;
function VM_GetName(p: PVariableManager; Idx: LongInt): String;
procedure VM_SetName(p: PVariableManager; Idx: LongInt; const S: string);
procedure VM_Set(p: PVariableManager; Idx: LongInt; N: PIfVariant);
function VM_Count(p: PVariableManager): LongInt;
function VM_Find(p: PVariableManager; const Name: string): LongInt;
procedure VM_Clear(p: PVariableManager);



type
  PProcedure = ^TProcedure;
  TRegisteredProc = function(Sender, ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  TRegisteredProcObject = function(Sender, ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError of object;
  TProcedure = packed record
    FScriptEngine: Pointer;
    Mode: Byte; { 0 = Internal; 1 = RegisteredProc; 2 = RegisteredProc of Object }
    Flags: Word;
    Name,
    Decl: string;
    NameHash: Cardinal;     
 {  Spec: RESTYPE PARAM1NAME PARAM1TYPE PARAM2NAME PARAM2TYPE
    an ! before the paramname means is VARIABLE
    an ^ before the paramname means is CONSTANT

    an ! before the name means that it's a method (class)
    }
    {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF}
    _Ext: Pointer; 
    case Byte of
    0: (Offset: Longint);
    1: (Proc1: TRegisteredProc; _Ext2: Pointer); // _Ext2 can not be used with Proc2, because Proc2 is already 8 bytes.
    2: (Proc2: TRegisteredProcObject);
  end;

  TProcedureManager = TIfList;
  PProcedureManager = TProcedureManager;

function PM_Create: PProcedureManager;
procedure PM_Destroy(p: PProcedureManager);
procedure PM_Clear(p: PProcedureManager);

function PM_AddExtOfObject(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext: Pointer; Addr: TRegisteredProcObject): PProcedure;
function PM_AddExt(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext, Addr: Pointer): PProcedure;
function PM_AddInt(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext: Pointer; Offset: Longint): PProcedure;

function PM_Find(p: PProcedureManager; const Name: string): Integer;
function PM_Get(p: PProcedureManager; i: LongInt): PProcedure;

function DoMinus(p: PIfVariant): Boolean;
function DoNot(p: PIfVariant): Boolean;


procedure SetInteger(p: PIfVariant; I: LongInt);
procedure SetReal(p: PIfVariant; i: Extended);
procedure SetChar(p: PIfVariant; i: Char);
procedure SetString(p: PIfVariant; const I: string);
procedure SetBoolean(p: PIfVariant; i: Boolean);

function IsCharType(v: PIfVariant): Boolean;
function IsStringType(v: PIfVariant): Boolean;
function IsIntRealType(v: PIfVariant): Boolean;
function IsIntegerType(v: PIfVariant): Boolean;
function IsBooleanType(v: PIfVariant): Boolean;
function IsRealType(v: PIfVariant): Boolean;

function GetChar(v: PIfVariant): Char;
function GetString(v: PIfVariant): string;
function GetReal(v: PIfVariant): Extended;
function GetInteger(v: PIfVariant): LongInt;
function GetBoolean(v: PIfVariant): Boolean;

function ErrorToString(e: TIfPasScriptError; const ErrorString: string): string;

function TM_Create: PTypeManager;
function TM_Add(P: PTypeManager; const Name: string; FType: Word; ex: Pointer): Pointer;
function TM_Get(P: PTypeManager; const Name: string): PTypeRec;
procedure TM_Destroy(p: PTypeManager);
{s format of S is: IntToHex(Longint(FType1),8)+IntToHex(Longint(FType2), 8)+etc;}

function GetVarLink(p: PIfVariant): PIfVariant;
function GetTypeLink(p: PTypeRec): PTypeRec;


implementation
uses
  ifs_obj;

//
//  Function: ErrorToString
//   Purpose: Convert an error code to a string description
//-----------------------------------------------------------

function ErrorToString(e: TIfPasScriptError; const ErrorString: string): string;
begin
  case e of
    ENoError: ErrorToString := 'no error';
    ECanNotReadProperty: ErrorToString := 'can not read property';
    ECanNotWriteProperty: ErrorToString := 'can not write property';
    EUnknownIdentifier:
      begin
        if ErrorString <> '' then
          ErrorToString := 'unknown identifier: '+ErrorString
        else
          ErrorToString := 'unknown identifier';
      end;
    EIdentifierExpected: ErrorToString := 'identifier expected';
    ESemicolonExpected: ErrorToString := 'semicolon expected';
    EBeginExpected: ErrorToString := 'begin expected';
    EDuplicateIdentifier: ErrorToString := 'duplicate identifier';
    EUnexpectedEndOfFile: ErrorToString := 'unexpected end of file';
    EColonExpected: ErrorToString := 'colon expected';
    ESyntaxError: ErrorToString := 'syntax error';
    EStringError: ErrorToString := 'string error';
    EErrorInStatement: ErrorToString := 'error in statement';
    EAssignmentExpected: ErrorToString := 'assignment expected';
    ETypeMismatch: ErrorToString := 'type mismatch';
    EErrorInExpression: ErrorToString := 'error in expression';
    ERoundOpenExpected: ErrorToString := 'round open expected';
    ERoundCloseExpected: ErrorToString := 'round close expected';
    EVariableExpected: ErrorToString := 'variable expected';
    ECommaExpected: ErrorToString := 'comma expected';
    EThenExpected: ErrorToString := 'then expected';
    EPeriodExpected: ErrorToString := 'period expected';
    EParameterError: ErrorToString := 'parameter error';
    EToExpected: ErrorToString := 'to expected';
    EDoExpected: ErrorToString := 'do expected';
    EOfExpected: ErrorToString := 'of expected';
    EEndExpected: ErrorToString := 'end expected';
    EOutOfRange: ErrorToString := 'out of range';
    EOpenBlockExpected: ErrorToString := 'open block expected';
    ECloseBlockExpected: ErrorToString := 'close block expected';
    EConstantExpected: ErrorToString := 'constant expected';
    EIsExpected: ErrorToString := 'is expected';
    EUnitNotFound: ErrorToString := 'unit is not found';
    EIntegerExpected: ErrorToString := 'integer variable expected';
    ENotSupported: ErrorToString := 'command is not supported';
    ECloseRoundExpected: ErrorToString := 'close round expected';
    EUntilExpected: ErrorToString := 'until expected';
    EDivideByZero: ErrorToString := 'divide by zero';
    {$IFNDEF NOCLASSES}
    EClassNotCreated: ErrorToString := 'class is not created';
    EClassNotAllowedHere: ErrorToString := 'class not allowed here';
    EClassTypeExpected: ErrorToString := 'class type expected';
    ECanNotOverride: ErrorToString := 'can not override';
    EUnsatisfiedForward: ErrortoString := 'unsatisfied forward: '+ErrorString;
    EConstructorExpected: ErrorToString := 'constructor expected';
    ENoInheritedAllowedHere: errorToString := 'no inherited allowed here';
    EClassAlreadyFreed: ErrorToString := 'class already freed';
    EClassReferenceNotAssigned: ErrorToString := 'class reference not assigned';
    ECanNotReadOrWriteProperty: ErrorToString := 'can not read or write property';
    EObjectExpected: ErrorToString := 'object expected';
    {$ENDIF}
{$IFNDEF NOVARIANTS}
    EVariantIsNil: ErrorToString := 'variant is nil';
{$ENDIF}
    ECustomError: ErrorToString := ErrorString;
    ECommentError: ErrorToString := 'comment error';
    ECharError: ErrorToString := 'char error';
    EOutOfMemoryError: ErrorToString := 'out of memory';
    EExceptExpected: ErrorToString := 'except expected';
    EStringExpected: ErrorToString := 'string expected'

  else
    ErrorToString := 'unknown error';
  end;
end;

function GetTypeLink(p: PTypeRec): PTypeRec;
begin
  while (p<>nil) and (p^.atypeid = CSV_TypeCopy) do
  begin
    p := p^.ext;
  end;
  GetTypeLink := p;
end;


function CreateCajVariant(PType: PTypeRec): PIfVariant;
{
  Creates an instance of a CajVariant.
}
var
  p: PIfVariant;
  n: PTypeRec;
  s: string;
begin
  PType := GetTypeLink(PType);
  if PTYpe = nil then begin CreatecajVariant := nil; exit;end;
  New(p);
  FillChar(p^, Sizeof(P^), 0);
  p^.VType := PType;
  p^.Flags := 0;
  {$IFNDEF NOVARIANTS}
  if PType^.ATypeID = CSV_Variant then
  begin
    p^.CV_Variant := nil;
  end else
  {$ENDIF}
  {$IFNDEF NOCLASSES}
  if PType^.ATypeId = CSV_ExternalObject then
  begin
    p^.CV_ExternalObject := nil;
  end else
  if PType^.AtypeID = CSV_ClassRef then
  begin
    p^.Cv_ClassRef := nil;
  end else {$ENDIF}
  if Ptype^.AtypeID = CSV_Internal then
  begin
    p^.Cv_Int1 := nil;
    p^.Cv_Int2 := nil;
  end else{$IFNDEF NOCLASSES}
  if pType^.Atypeid = CSV_Class then
  begin
    p^.CV_Class := nil;
  end else
  if PType^.ATypeid = CSV_Property then
  begin
    p^.CV_PropFlags := 0;
  end else{$ENDIF}
  if PType^.atypeid = CSV_Var then
    p^.CV_Var := nil
  else if PType^.atypeid = CSV_Array then
  begin
    p^.CV_ArrItems := TIfList.Create;
  end else if PType^.Atypeid = CSV_Record then
  begin
    p^.CV_RecItems := TIfList.Create;
    s := PIFsRecordType(Ptype^.ext)^.u;
    while length(s) > 0 do
    begin
      rfw(S); {remove name}
      n := Pointer(longint(StrToIntDef(Fw(s), 0)));
      if n = nil then break;
      p^.Cv_RecItems.Add(CreateCajVariant(n));
      rfw(s); {remove type}
    end;
  end else if PType^.AtypeID = CSV_String then
  begin
    p^.CV_Str := ''
  end else if PType^.ATypeId = CSV_ProcVariable then
  begin
    P^.Cv_Proc := nil;
    {$IFNDEF NOCLASSES}
    p^.CV_ProcSelf := nil;
    {$ENDIF}
  end;
  CreateCajVariant := p;
end;


function ChangeType(p: PIfVariant; newtype: PTypeRec): PIfVariant;
{ Changes the type of a variant }
var
  n: PTypeRec;
  s: string;
  i: Integer;
begin
  if NewType = nil then begin ChangeType := nil; exit;end;
  newtype := GetTypeLink(newtype);
  {$IFNDEF NOVARIANTS}
  if p^.VType^.ATypeID = CSV_variant then
  begin
    if assigned(p^.CV_Variant) then
      DestroyCajVariant(P^.CV_Variant);
  end else {$ENDIF}
  if P^.Vtype^.atypeid = CSV_Array then
  begin
    for i := 0 to Longint(p^.CV_ArrItems.count) - 1 do
    begin
      DestroyCajVariant(p^.CV_ArrItems.GetItem(i));
    end;
    p^.CV_ArrItems.Free;
  end else if p^.Vtype^.atypeid = CSV_Record then
  begin
    for i := 0 to Longint(p^.CV_RecItems.count) - 1 do
    begin
      DestroyCajVariant(p^.CV_RecItems.GetItem(i));
    end;
    p^.CV_RecItems.Free;
  end;
  FillChar(p^, Sizeof(P), 0);
  p^.VType := newtype;
  {$IFNDEF NOVARIANTS}
  if newtype^.ATypeID = CSV_Variant then
  begin
    p^.CV_Variant := nil;
  end else
  {$ENDIF}
  if NewType.AtypeID = CSV_Internal then
  begin
    p^.Cv_Int1 := nil;
    p^.Cv_Int2 := nil;
  end else{$IFNDEF NOCLASSES}
  if newtype^.ATypeId = CSV_ExternalObject then
  begin
    p^.CV_ExternalObject := nil;
  end else
  if NewType.ATypeid = CSV_Class then
  begin
    P^.CV_Class := nil;
  end else {$ENDIF}
  if newtype.atypeid = CSV_Var then
    p^.CV_Var := nil
  else if newtype.atypeid = CSV_Array then
  begin
    p^.CV_ArrItems := TIfList.Create;
  end else if newtype.Atypeid = CSV_Record then
  begin
    p^.CV_RecItems := TIfList.Create;
    s := PIFsRecordType(newtype^.ext)^.u;
    while length(s) > 0 do
    begin
      rfw(S); {remove name}
      n := Pointer(longint(StrToIntDef(Fw(s), 0)));
      if n = nil then break;
      p^.Cv_RecItems.Add(CreateCajVariant(n));
      rfw(s); {remove type}
    end;
  end else if newtype^.ATypeId = CSV_String then
    p^.CV_Str := ''
  else if newtype^.ATypeId = CSV_ProcVariable then
  begin
    P^.Cv_Proc := nil;
    {$IFNDEF NOCLASSES}
    P^.Cv_ProcSelf := nil;
    {$ENDIF}
  end;
  changeType := P;
end;

procedure DestroyCajVariant(p: PIfVariant);
{ Destroys an instance of a CajVariant.}
var
  i: Longint;
begin
  if Assigned(p) then
  begin
    {$IFNDEF NOVARIANTS}
    if p^.VType^.ATypeID = CSV_variant then
    begin
      if assigned(p^.CV_Variant) then
        DestroyCajVariant(P^.CV_Variant);
    end else {$ENDIF}
    if P^.Vtype^.atypeid = CSV_Array then
    begin
      for i := 0 to Longint(p^.CV_ArrItems.count) - 1 do
      begin
        DestroyCajVariant(p^.CV_ArrItems.GetItem(i));
      end;
      p^.CV_ArrItems.Free;
    end else if p^.Vtype^.atypeid = CSV_Record then
    begin
      for i := 0 to Longint(p^.CV_RecItems.count) - 1 do
      begin
        DestroyCajVariant(p^.CV_RecItems.GetItem(i));
      end;
      p^.CV_RecItems.Free;
    end;
    Dispose(p);
  end;
end;

function VM_Create: PVariableManager;
{Creates an instance of a VariableManger}
begin
  VM_Create := TIFList.Create;
end;

procedure VM_Destroy(p: PVariableManager);
{Destroys an instance of a VariableManager}
var
  i: Integer;
  x: PIFNamedVariable;
begin
  for i := 0 to Longint(p.count) - 1 do
  begin
    x := p.GetItem(I);
    DestroyCajVariant(x^.FVar);
    Dispose(x);
  end;
  p.Free;
end;

function VM_Add(P: PVariableManager; D: PIfVariant; const Name: string): PIfVariant;
var
  temp: PIFNamedVariable;
begin
  new(temp);
  temp^.Name := name;
  temp^.NameHash := MKHash(name);
  temp^.FVar := d;
  p.Add(temp);
  result := d;
end;
function VM_Insert(P: PVariableManager; Idx: Longint; D: PIfVariant; const Name: string): PIFVariant;
var
  temp: PIFNamedVariable;
begin
  new(temp);
  temp^.Name := name;
  temp^.NameHash := MKHash(name);
  temp^.FVar := d;
  p.Insert(temp, Idx);
  result := d;
end;

procedure VM_Clear(p: PVariableManager);
var
  i: Integer;
  x: PIFNamedVariable;
begin
  for i := 0 to Longint(p.count) - 1 do
  begin
    x := p.GetItem(I);
    DestroyCajVariant(x^.FVar);
    Dispose(x);
  end;
  p.Clear;
end;

procedure VM_Delete(p: PVariableManager; Idx: LongInt);
var
  x: PIFNamedVariable;
begin
  x := p.GetItem(idx);
  if x <> nil then
  begin
    dispose(x);
  end;
  p.Delete(idx);
end;

function VM_Find(p: PVariableManager; const Name: string): LongInt;
var
  i: Integer;
  h: Cardinal;
begin
  h := mkhash(name);
  for i := 0 to Longint(p.Count) - 1 do
  begin
    if (PIFNamedVariable(p.GetItem(i))^.NameHash = h) and (PIFNamedVariable(p.getitem(i))^.Name = Name) then
    begin
      VM_Find := I;
      Exit;
    end;
  end;
  VM_Find := -1;
end;

function VM_Count(p: PVariableManager): LongInt;
begin
  VM_Count := P.Count;
end;

function VM_Get2(p: PVariableManager; Idx: LongInt): PIfVariant;
begin
  Result := GetVarLink(VM_Get(P, Idx));
end;

function VM_Get(p: PVariableManager; Idx: LongInt): PIfVariant;
var
  tmp: PIFNamedVariable;
begin
  tmp := P.GetItem(idx);
  if tmp = nil then
    vm_get := nil
  else
    VM_Get := tmp^.FVar;
end;
function VM_GetName(p: PVariableManager; Idx: LongInt): String;
var
  tmp: PIFNamedVariable;
begin
  tmp := P.GetItem(idx);
  if tmp <> nil then
    VM_GetName := tmp^.Name;
end;

procedure VM_Set(p: PVariableManager; Idx: LongInt; N: PIfVariant);
var
  tmp: PIFNamedVariable;
begin
  tmp := P.GetItem(idx);
  if tmp <> nil then
    tmp^.FVar := n;
end;

procedure VM_SetName(p: PVariableManager; Idx: LongInt; const S: string);
var
  tmp: PIFNamedVariable;
begin
  tmp := P.GetItem(idx);
  if tmp <> nil then
  begin
    tmp^.Name := s;
    tmp^.NameHash := mkhash(s);
  end;
end;


function PM_Create: PProcedureManager;
{Creates an instance of a Procedure Manager}
begin
  PM_Create := TIFList.Create;
end;

procedure PM_Clear(p: PProcedureManager);
var
  n: PProcedure;
  i: Integer;
begin
  for i := 0 to Longint(p.Count) -1 do
  begin
    n := p.GetItem(I);
    Dispose(n);
  end;
  p.Clear;
end;

procedure PM_Destroy(p: PProcedureManager);
begin
  PM_Clear(p);
  p.Free;
end;

function PM_AddExtOfObject(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext: Pointer; Addr: TRegisteredProcObject): PProcedure;
var
  n: PProcedure;
begin
  new(n);
  n^.FScriptEngine := ScriptEngine;
  N^.Flags := 0;
  n^.Mode := 2;
  n^.Name := Name;
  n^.NameHash := mkhash(name);
  N^.Decl := Decl;
  N^._Ext := Ext;
  n^.Proc2 := Addr;
  {$IFNDEF NOCLASSES}
  n^.ClassType := ClassType;
  {$ENDIF}
  P.Add(n);
  PM_AddExtOfObject:= N;
end;
function PM_AddExt(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext, Addr: Pointer): PProcedure;
var
  n: PProcedure;
begin
  new(n);
  n^.FScriptEngine := ScriptEngine;
  N^.Flags := 0;
  n^.Mode := 1;
  n^.Name := Name;
  n^.NameHash := mkhash(name);
  N^.Decl := Decl;
  N^._Ext := Ext;
  n^.Proc1 := Addr;
  {$IFNDEF NOCLASSES}
  n^.ClassType := ClassType;
  {$ENDIF}
  P.Add(n);
  PM_AddExt:= N;
end;

function PM_AddInt(p: PProcedureManager; ScriptEngine: Pointer; const Name, Decl: string; {$IFNDEF NOCLASSES}ClassType: PTypeRec;{$ENDIF} Ext: Pointer; Offset: Longint): PProcedure;
var
  n: PProcedure;
begin
  new(n);
  N^.FScriptEngine := ScriptEngine;
  N^.Flags := 0;
  n^.Mode := 0;
  n^.Name := Name;
  n^.NameHash := mkhash(name);
  N^.Decl := Decl;
  N^._Ext := Ext;
  {$IFNDEF NOCLASSES}
  N^.ClassType := ClassType;
  {$ENDIF}
  n^.Offset := Offset;
  P.Add(n);
  PM_AddInt:= N;
end;


function PM_Find(p: PProcedureManager; const Name: string): Integer;
var
  i: Integer;
  c: Cardinal;
begin
  c := mkhash(name);
  for i := 0 to Longint(p.Count) - 1 do
  begin
    if (PProcedure(p.GetItem(i))^.NameHash = c) and (PProcedure(p.GetItem(i))^.Name = Name) then
    begin
      PM_Find:= I;
      exit;
    end;
  end;
  PM_Find := -1;
end;

function PM_Get(p: PProcedureManager; i: LongInt): PProcedure;
begin
  PM_Get := p.GetItem(i);
end;

function GetVarLink(p: PIfVariant): PIfVariant;
begin
  if assigned(p) then
  begin
    while p.VType.atypeid = CSV_VAR do
    begin
      if assigned(p^.CV_Var) then
        p := p^.CV_Var
      else
        break;
    end;
  end;
  GetVarLink := p;
end;

function DoMinus(p: PIfVariant): Boolean;
begin
  p := GetVarLink(p);
  DoMinus := True;
  case P^.VType^.atypeid of
    CSV_UByte: p^.Cv_UByte := -p^.Cv_UByte;
    CSV_SByte: p^.Cv_SByte := -p^.Cv_SByte;
    CSV_UInt16: p^.Cv_UInt16 := -p^.Cv_UInt16;
    CSV_SInt16: p^.Cv_SInt16 := -p^.Cv_SInt16;
    CSV_UInt32: p^.Cv_UInt32 := -p^.Cv_UInt32;
    CSV_SInt32: p^.Cv_SInt32 := -p^.Cv_SInt32;
    CSV_Real: p^.Cv_Real := -p^.Cv_Real;
    CSV_Single: p^.Cv_Single := -p^.cv_Single;
    CSV_Double: p^.Cv_Double := -p^.Cv_Double;
    CSV_Extended: p^.Cv_Extended := -p^.Cv_Extended;
    CSV_Comp: p^.Cv_Comp := -p^.Cv_Comp;
  else
    DoMinus := False;
  end;
end;

function DoNot(p: PIfVariant): Boolean;
begin
  p := GetVarLink(p);
  DoNot := True;
  case P^.VType^.atypeid of
    CSV_UByte: p^.Cv_UByte := not p^.Cv_UByte;
    CSV_SByte: p^.Cv_SByte := not p^.Cv_SByte;
    CSV_UInt16: p^.Cv_UInt16 := not p^.Cv_UInt16;
    CSV_SInt16: p^.Cv_SInt16 := not p^.Cv_SInt16;
    CSV_UInt32: p^.Cv_UInt32 := not p^.Cv_UInt32;
    CSV_SInt32: p^.Cv_SInt32 := not p^.Cv_SInt32;
    CSV_Bool: p^.CV_Bool := not p^.CV_Bool;
  else
    DoNot := False;
  end;
end;

procedure SetInteger(p: PIfVariant; I: LongInt);
begin
  p := GetVarLink(p);
  case P^.VType^.atypeid of
    CSV_UByte: p^.Cv_UByte := i;
    CSV_SByte: p^.Cv_SByte := i;
    CSV_UInt16: p^.Cv_UInt16 := i;
    CSV_SInt16: p^.Cv_SInt16 := i;
    CSV_UInt32: p^.Cv_UInt32 := i;
    CSV_SInt32: p^.Cv_SInt32 := i;
  end;
end;

procedure SetReal(p: PIfVariant; i: Extended);
begin
  p := GetVarLink(p);
  case P^.VType^.atypeid of
    CSV_Real: P^.CV_Real := i;
    CSV_Single: P^.CV_Single := i;
    CSV_Double: P^.CV_Double := i;
    CSV_Extended: P^.CV_Extended := i;
    CSV_Comp: P^.CV_Comp := i;
  end;
end;

procedure SetBoolean(p: PIfVariant; i: Boolean);
begin
  p := GetVarLink(p);
  case P^.VType^.atypeid of
    CSV_Bool: P^.CV_Bool := i;
  end;
end;

procedure SetChar(p: PIfVariant; i: Char);
begin
  p := GetVarLink(p);
  case P^.VType^.atypeid of
    CSV_Char: P^.CV_Char := i;
  end;
end;

procedure SetString(p: PIfVariant; const I: string);
begin
  p := GetVarLink(p);
  case P^.VType^.atypeid of
    CSV_String: P^.Cv_Str := i;
  end;
end;

function IsRealType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsRealType := (V^.VType^.atypeid = CSV_Real) or
    (v^.Vtype^.atypeid = CSV_Single) or
    (v^.Vtype^.atypeid = CSV_Double) or
    (v^.Vtype^.atypeid = CSV_Extended) or
    (v^.Vtype^.atypeid = CSV_Comp);
end;

function IsIntegerType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsIntegerType := (v^.VType^.atypeid = CSV_UByte) or
    (v^.Vtype^.atypeid = CSV_SByte) or
    (v^.VType^.atypeid = CSV_UInt16) or
    (v^.VType^.atypeid = CSV_SInt16) or
    (v^.VType^.atypeid = CSV_UInt32) or
    (v^.VType^.atypeid = CSV_SInt32);
end;

function IsBooleanType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsBooleanType := (v^.VType^.atypeid = CSV_Bool);
end;

function IsIntRealType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsIntRealType := (v^.VType^.atypeid = CSV_UByte) or
    (v^.VType^.atypeid = CSV_SByte) or
    (v^.VType^.atypeid = CSV_UInt16) or
    (v^.VType^.atypeid = CSV_SInt16) or
    (v^.VType^.atypeid = CSV_UInt32) or
    (v^.VType^.atypeid = CSV_SInt32) or
    (V^.VType^.atypeid = CSV_Real) or
    (v^.VType^.atypeid = CSV_Single) or
    (v^.VType^.atypeid = CSV_Double) or
    (v^.VType^.atypeid = CSV_Extended) or
    (v^.VType^.atypeid = CSV_Comp);
end;

function IsCharType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsCharType := (v^.VType^.atypeid = CSV_Char);
end;

function IsStringType(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  IsStringType := (v^.VType^.atypeid = CSV_Char) or
    (v^.VType^.atypeid = CSV_String);
end;

function GetInteger(v: PIfVariant): LongInt;
begin
  v := GetVarLink(v);
  case v^.VType^.aTypeid of
    CSV_UByte: GetInteger := V^.CV_UByte;
    CSV_SByte: GetInteger := V^.CV_SByte;
    CSV_UInt16: GetInteger := V^.CV_UInt16;
    CSV_SInt16: GetInteger := V^.CV_SInt16;
    CSV_UInt32: GetInteger := V^.CV_UInt32;
    CSV_SInt32: GetInteger := V^.CV_SInt32;
  else
    GetInteger := 0;
  end;
end;

function GetReal(v: PIfVariant): Extended;
begin
  v := GetVarLink(v);
  case v^.VType^.aTypeid of
    CSV_Real: GetReal := V^.CV_Real;
    CSV_Single: GetReal := V^.CV_single;
    CSV_Double: GetReal := V^.CV_double;
    CSV_Extended: GetReal := V^.CV_Extended;
    CSV_Comp: GetReal := V^.CV_Comp;
    CSV_UByte: GetReal := V^.CV_UByte;
    CSV_SByte: GetReal := V^.CV_SByte;
    CSV_UInt16: GetReal := V^.CV_UInt16;
    CSV_SInt16: GetReal := V^.CV_SInt16;
    CSV_UInt32: GetReal := V^.CV_UInt32;
    CSV_SInt32: GetReal := V^.CV_SInt32;
  else
    GetReal := 0;
  end;
end;

function GetChar(v: PIfVariant): Char;
begin
  v := GetVarLink(v);
  case v^.VType^.aTypeid of
    CSV_Char: GetChar := V^.CV_Char;
  else
    GetChar := #0;
  end;
end;

function GetString(v: PIfVariant): string;
begin
  v := GetVarLink(v);
  case v^.VType^.aTypeid of
    CSV_String: GetString := V^.CV_Str;
    CSV_Char: GetString := V^.CV_Char;
  else
    GetString := '';
  end;
end;

function GetBoolean(v: PIfVariant): Boolean;
begin
  v := GetVarLink(v);
  case v^.VType^.aTypeid of
    CSV_Bool: GetBoolean := V^.CV_Bool;
  else
    GetBoolean := False;
  end;
end;


function TM_Create: PTypeManager;
var
  x: PTypeManager;
begin
  new(X);
  X^.List := TIFList.Create;
  TM_Create := x;
end;

function TM_Add(P: PTypeManager; const Name: string; FType: Word; ex: Pointer): Pointer;
var
  n: PTypeRec;
  i: Integer;
begin
  if (Name = '') then
  begin
    {$IFNDEF NOCLASSES}if FType <> CSV_Class then
    begin{$ENDIF}
      for i := 0 to Longint(p.List.Count) - 1 do
      begin
        if (PTypeRec(p.List.GetItem(i))^.atypeid = FType) and (PTypeRec(p.List.GetItem(i))^.ext = Ex) then
        begin
          TM_Add := p.List.GetItem(i);
          Exit;
        end;
      end;
    {$IFNDEF NOCLASSES}end;{$ENDIF}
    new(n);
    N^.Ident := Name;
    n^.identhash := mkhash(n^.Ident);
    N^.atypeid := FType;
    N^.ext := ex;
    p^.List.Add(n);
    TM_Add := N;
  end else
    if (TM_GET(p, Name) = nil) then
    begin
      new(n);
      N^.Ident := Name;
      n^.identhash := mkhash(n^.Ident);
      N^.atypeid := FType;
      N^.ext := ex;
      p^.List.Add(n);
      TM_ADD := n;
    end else
      TM_Add := nil;
end;

procedure DisposeTypeRec(p: PTypeRec);
  procedure DestroyRecord(p: PIFSRecordType);
  begin
    Dispose(p);
  end;
  procedure DestroyProc(p: PIFSProcType);
  begin
    Dispose(p);
  end;
  {$IFNDEF NOCLASSES}
  procedure DestroyExtClass(P: TIfsExtClass);
  begin
    p.Free;
  end;
  procedure DestroyClass(c: PIFSClassType);
  var
    i: Longint;
    p: PPropertyDef;
  begin
    for i := 0 to Longint(c^.Properties.Count) -1 do
    begin
      p := c^.Properties.GetItem(i);
      Dispose(p);
    end;
    c^.Properties.Free;
    c^.Procedures.Free;
    Dispose(c);
  end;
  {$ENDIF}

begin
  {$IFNDEF NOCLASSES}
  if (P^.atypeid = CSV_ExternalObject) and (assigned(p^.Ext)) then
  begin
    DestroyExtClass(p^.Ext);
  end else {$ENDIF}if (p^.atypeid = CSV_Record) and (assigned(p^.ext)) then
  begin
    DestroyRecord(p^.ext);
  end else
  if (P^.ATypeID = CSV_ProcVariable) and (Assigned(P^.Ext)) then
  begin
    DestroyProc(p^.Ext);
  end {$IFNDEF NOCLASSES} else
  if (p^.AtypeId = CSV_Class) and assigned(p^.Ext) then
  begin
    DestroyClass(p^.ext);
  end{$ENDIF};
  Dispose(p);
end;

function TM_Get(P: PTypeManager; const Name: string): PTypeRec;
var
  i: Integer;
  c: Cardinal;
begin
  c := mkhash(name);
  for i := 0 to Longint(p^.List.Count) - 1 do
  begin
    if (c = PTypeRec(p^.List.GetItem(i))^.identhash) and (name = PTypeRec(p^.List.GetItem(i))^.ident) then
    begin
      TM_Get := p^.List.GetItem(i);
      exit;
    end;
  end;
  TM_Get := nil;
end;

procedure TM_Destroy(p: PTypeManager);
var
  I: Integer;
begin
  for i := 0 to Longint(p^.List.Count) - 1 do
  begin
    DisposeTypeRec(p^.List.GetItem(i));
  end;
  p.List.Free;
  Dispose(p);
end;


end.

