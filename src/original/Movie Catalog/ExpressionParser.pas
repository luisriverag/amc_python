(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2014-2017 Mickaël Vanneufville                                 *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *           ExpressionParser - Version 1.0 - 24/08/2014                *
 *                                                                      *
 *   This parser has been written from scratch by Mickaël Vanneufville  *
 *   for Ant Movie Catalog.                                             *
 *   The objective was to write an optimized, customizable and          *
 *   standalone parser using variables to evaluate a same expression    *
 *   many times with differents values for variables.                   *
 *   For this purpose, there are two steps. First we prepare expression *
 *   by creating an optimized tree and we evaluate all sub-expressions  *
 *   of tree where child nodes do not contain variable and "eval"       *
 *   operators. Second we can evaluate the prepared expression many     *
 *   times by changing only variables value which is very fast !        *
 *                                                                      *
 *   Expression example: [NAME]="ABC" or ([SIZE]>5 and [SIZE]<10)       *
 *   In this example, [NAME] and [SIZE] are variables where values      *
 *   can be changed for each evaluation of prepared expression.         *
 *                                                                      *
 *   In Ant Movie Catalog, we evaluate a search expression for all      *
 *   movies in catalog where variables are here movie fields and where  *
 *   values change for each movie.                                      *
 *   Of course, you can also use this parser without using variables.   *
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

unit ExpressionParser;

interface

uses
  Windows, Classes, SysUtils, StrUtils, Contnrs, Math;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
const

  eopOr                   =  1;
  eopAnd                  =  2;
  eopNot                  =  3;
                         
  eopContains             =  4;
  eopMatchRegExp          =  5;
  eopGOrEqual             =  6;
  eopLOrEqual             =  7;
  eopNotEqual             =  8;
  eopEqual                =  9;
  eopGreater              = 10;
  eopLower                = 11;
                         
  eopAdd                  = 12;
  eopMinus                = 13;
  eopMult                 = 14;
  eopDiv                  = 15;
  eopMod                  = 16;

  eopCastBoolean          = 17;
  eopCastDate             = 18;
  eopCastInteger          = 19;
  eopCastFloat            = 20;
  eopCastString           = 21;
  eopCastEval             = 22;
                         
  eopIf                   = 23;
  eopElse                 = 24;

type
  TExprType = (
    etyNone               =  0,
    etyString             =  1,
    etyBoolean            =  2,
    etyDate               =  3,
    etyInteger            =  4,
    etyFloat              =  5,
    etyVariable           =  6);
    
  TExprOperand = (
    eodLeft               =  0,
    eodBoth               =  1,
    eodRight              =  2);

  TExprAssociativity = (
    easLeftToRight        =  0,
    easRightToLeft        =  1);
  
  TExpression = class;
  
  TExprEvalFunction = procedure (Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);

  TExprOperator = class(TObject)
  private
    FId: Integer;
    FToken: string;
    FEvalFunction: TExprEvalFunction;
    FOperand: TExprOperand;
  public
    constructor Create(Id: Integer; Token: string;
      EvalFunction: TExprEvalFunction; Operand: TExprOperand); reintroduce;
    property Id: Integer read FId write FId;
    property Token: string read FToken write FToken;
    property EvalFunction: TExprEvalFunction read FEvalFunction write FEvalFunction;
    property Operand: TExprOperand read FOperand write FOperand;
  end;

  TExprOperators = class(TObjectList)
  private
    FAssociativity: TExprAssociativity;
    procedure SetOperator(const idx: Integer; Value: TExprOperator);
    function GetOperator(const idx: Integer): TExprOperator;
  public
    constructor Create(Associativity: TExprAssociativity); reintroduce;
    property Associativity: TExprAssociativity read FAssociativity write FAssociativity;
    property Items[const idx: Integer]: TExprOperator read GetOperator write SetOperator; default;
  end;

  TExprGroupsOperators = class(TObjectList)
  private
    procedure SetOperators(const idx: Integer; Value: TExprOperators);
    function GetOperators(const idx: Integer): TExprOperators;
  public
    constructor Create; reintroduce;
    property Items[const idx: Integer]: TExprOperators read GetOperators write SetOperators; default;
  end;

  TExprVarParser = class(TObject)
  private
    FNbSubExprEval: Integer; // Number of subexpressions using eval operator
  public
    constructor Create; reintroduce;
    function IsVar(Expression: string): Boolean; virtual; abstract;
    function GetVarId(Expression: string): string; virtual; abstract;
    function GetVarValue(VarId: string; VarObject: TObject): string; virtual; abstract;
    function GetVarType(VarId: string; VarObject: TObject): TExprType; virtual; abstract;
  end;

  TExpression = class(TObject)
  private
    FEVarParser: TExprVarParser;
    FEValue: string;
    FEType: TExprType;
    FEOperator: TExprOperator;
    FExpression1: TExpression;
    FExpression2: TExpression;
    FDepth: Integer;
    procedure Prepare(Expression: string; VarParser: TExprVarParser);
  public
    constructor Create(Expression: string; VarParser: TExprVarParser); reintroduce;
    destructor Destroy; override;
    function IsValid: Boolean;
    function GetDepth: Integer;
    procedure Eval(VarObject: TObject;
      var vVal: string; var vType: TExprType);
    function EvalAsBoolean(VarObject: TObject): Boolean;
    property EVarParser: TExprVarParser read FEVarParser;
    property EValue: string read FEValue;
    property EType: TExprType read FEType;
    property EOperator: TExprOperator read FEOperator;
    property Expression1: TExpression read FExpression1;
    property Expression2: TExpression read FExpression2;
    property Depth: Integer read FDepth;
  end;
  
var
  // Default configuration used to parse and evaluate expressions
  // This configuration can be modified during run time if needed
  
  // Special values used for type Boolean
  expBoolTrue  : string  = 'true';
  expBoolFalse : string  = 'false';

  // Parenthesis used for precedence
  expParOpen  : char = '(';
  expParClose : char = ')';
  
  // Quote used for strings
  expQuote : char = '"';
  
  // Groups of operators organized by precedence (from lowest to highest)
  // used to parse and evaluate expressions
  ExprGroupsOperatorsPrecedence: TExprGroupsOperators;

  // Format settings used for types float and dates
  ExprFormatSettings: TFormatSettings;

  // Number max of subexpressions using eval operator :
  // Protection to avoid infinite cycles if a variable tries to evaluate itself
  ExprMaxSubExprEval: Integer = 5;

  function GetStrType(Str: string): TExprType;
  function IsStrType(Str: string; Typ: TExprType): Boolean;
  function IsStrBoolean(Str: string): Boolean;
  function IsStrDate(Str: string): Boolean;
  function IsStrInteger(Str: string): Boolean;
  function IsStrFloat(Str: string): Boolean;
  function GetStrBoolean(Str: string): Boolean;
  function GetStrDateDef(Str: string; Default: TDateTime): TDateTime;
  function GetStrIntegerDef(Str: string; Default: Integer): Integer;
  function GetStrFloatDef(Str: string; Default: Extended): Extended;
  
  procedure EvalIfOp(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalElseOp(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalOrOp(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalAndOp(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalNotOp(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalCompOps(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalArithmOps(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);
  procedure EvalCastOps(Expression: TExpression; VarObject: TObject;
    var vVal: string; var vType: TExprType);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  functions_str, DateUtils, RegExpr;

const
  MaxInt =  2147483647;
  MinInt = -2147483647;

var
  GIdx: Integer;
  
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TExprOperator }
  
constructor TExprOperator.Create(Id: Integer; Token: string;
    EvalFunction: TExprEvalFunction; Operand: TExprOperand);
begin
  inherited Create;
  FId := Id;
  FToken := Token;
  FEvalFunction := EvalFunction;
  FOperand := Operand;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TExprOperators }

constructor TExprOperators.Create(Associativity: TExprAssociativity);
begin
  inherited Create(True);
  FAssociativity := Associativity;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExprOperators.SetOperator(const idx: Integer; Value: TExprOperator);
begin
  inherited Items[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprOperators.GetOperator(const idx: Integer): TExprOperator;
begin
  Result := TExprOperator(inherited Items[idx]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TExprGroupsOperators }

constructor TExprGroupsOperators.Create;
begin
  inherited Create(True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExprGroupsOperators.SetOperators(const idx: Integer; Value: TExprOperators);
begin
  inherited Items[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprGroupsOperators.GetOperators(const idx: Integer): TExprOperators;
begin
  Result := TExprOperators(inherited Items[idx]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TExprVarParser }

constructor TExprVarParser.Create;
begin
  inherited Create;
  FNbSubExprEval := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{ TExpression }

constructor TExpression.Create(Expression: string; VarParser: TExprVarParser);
begin
  Prepare(Expression, VarParser);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TExpression.Destroy;
begin
  FExpression1.Free;
  FExpression2.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExpression.Prepare(Expression: string; VarParser: TExprVarParser);
var
  s: string;
  opGrpIdx, i, len, len2, nbPar, nbQuote: Integer;
  opFound, readInReverse: Boolean;

  procedure CheckOperators;
  var
    sOp, sExp1, sExp2: string;
    opIdx, j, lenOp: Integer;
    op: TExprOperator;
  begin
    with ExprGroupsOperatorsPrecedence.Items[opGrpIdx] do
      for opIdx := 0 to Count-1 do
      begin
        op := Items[opIdx];
        sOp := op.Token;
        lenOp := Length(sOp);
        // Read string in reverse (because of recursivity) to evaluate
        // operators of same precedence from left to right (associativity)
        if readInReverse then
        begin
          j := lenOp;
          while (i-lenOp+j <> 0) and (j <> 0) do
          begin
            if (s[i-lenOp+j] <> sOp[j]) and (
                  not (ord(sOp[j]) in [ord('a')..ord('z')]) or
                  (s[i-lenOp+j] <> char(ord(sOp[j])-ord('a')+ord('A'))) ) then
              break;
            Dec(j)
          end;
          if (j = 0) then
          begin
            opFound := True;
            sExp1 := Copy(s, 1, i-lenOp);
            sExp2 := Copy(s, i+1, len2-i);
          end;
        end else
        begin
          j := 1;
          while (i+j-1 <> len2+1) and (j <> lenOp+1) do
          begin
            if (s[i+j-1] <> sOp[j]) and (
                  not (ord(sOp[j]) in [ord('a')..ord('z')]) or
                  (s[i+j-1] <> char(ord(sOp[j])-ord('a')+ord('A'))) ) then
              break;
            Inc(j)
          end;
          if (j = lenOp+1) then
          begin
            opFound := True;
            sExp1 := Copy(s, 1, i-1);
            sExp2 := Copy(s, i+lenOp, len2-i-lenOp+1);
          end;
        end;
        if (opFound) then
        begin
          // Operator found
          FEOperator := op;
          FExpression1 := TExpression.Create(sExp1, VarParser);
          FExpression2 := TExpression.Create(sExp2, VarParser);
          FDepth := Max(FExpression1.Depth, FExpression2.Depth) + 1;
          // Try to check if expression is valid
          // If it is the last level for one expression (no operator)
          // and expected operand for current operator does not exist (type is not defined)
          // or not expected operand for current operator exists (type is defined)
          if ((FExpression1.FEOperator = nil) and (FEOperator.Id <> eopElse) and
              ((FExpression1.FEType = etyNone) and
               (FEOperator.Operand in [eodLeft, eodBoth]))
              or
              ((FExpression1.FEType <> etyNone) and
               (FEOperator.Operand = eodRight)))
             or
             ((FExpression2.FEOperator = nil) and (FEOperator.Id <> eopIf) and
              ((FExpression2.FEType = etyNone) and
               (FEOperator.Operand in [eodRight, eodBoth]))
              or
              ((FExpression2.FEType <> etyNone) and
               (FEOperator.Operand = eodLeft))) then
          begin
            //FEValue := expParOpen +  FExpression1.FEValue + sOp + FExpression2.FEValue + expParClose;
            FEType := etyNone;
            FEOperator := nil;
            FreeAndNil(FExpression1);
            FreeAndNil(FExpression2);
            FDepth := 1;
          end
          // Try to eval expression here if it is possible
          // If it is the last level for both expressions (no operator)
          // and there are no variable and no eval operator
          else if (FExpression1.FEOperator = nil) and
             (FExpression2.FEOperator = nil) then
          begin
            // If there are no variable and no eval operator
            if (FExpression1.FEType <> etyVariable) and
               (FExpression2.FEType <> etyVariable) and
               (FEOperator.Id <> eopCastEval) then
            begin
              Eval(nil, FEValue, FEType);
              FEOperator := nil;
              FreeAndNil(FExpression1);
              FreeAndNil(FExpression2);
              FDepth := 1;
            end;
          end;
          break;
        end;
      end;
  end;
  
  function OperatorTokenExists(Token: string): Boolean;
  var
    j, k: Integer;
  begin
    for j := 0 to ExprGroupsOperatorsPrecedence.Count-1 do
      for k := 0 to ExprGroupsOperatorsPrecedence.Items[j].Count-1 do
        if SameText(ExprGroupsOperatorsPrecedence.Items[j].Items[k].Token, Token) then
        begin
          Result := True;
          exit;
        end;
    Result := False;
  end;

begin
  FEVarParser := VarParser;
  FEValue := Trim(Expression);
  FEType := etyNone;
  FEOperator := nil;
  FExpression1 := nil;
  FExpression2 := nil;
  FDepth := 1;
  len := Length(FEValue);
  nbPar := 0;
  nbQuote := 0;

  if (len = 0) then
    exit;

  // Delete unnecessary parenthesis
  s := FEValue;
  while (len > 0) and (s[1] = expParOpen) and (s[len] = expParClose) and
    (not OperatorTokenExists(s)) do
  begin
    nbPar := 0;
    nbQuote := 0;
    for i := 2 to len-1 do
    begin
      if (s[i] = expParOpen) and (nbQuote = 0) then
        Inc(nbPar)
      else if (s[i] = expParClose) and (nbQuote = 0) then
      begin
        Dec(nbPar);
        if nbPar < 0 then
          break;
      end
      else if (s[i] = expQuote) then
        nbQuote := (nbQuote + 1) mod 2;
    end;
    if (nbPar = 0) and (nbQuote = 0) then
    begin
      s := trim(copy(s, 2, len-2));
      len := Length(s);
    end else
      break;
  end;
  FEValue := s;

  if (len = 0) then
    exit;

  // Search an operator by precedence (from lowest to highest)
  opFound := False;
  s := ' ' + FEValue + ' ';
  len2 := len + 2;
  for opGrpIdx := 0 to ExprGroupsOperatorsPrecedence.Count-1 do
  begin
    // Read string in reverse (because of recursivity) to evaluate
    // operators of same precedence from left to right (associativity)
    readInReverse := ExprGroupsOperatorsPrecedence.Items[opGrpIdx].Associativity = easLeftToRight;
    if readInReverse then
    begin
      i := len2;
      nbPar := 0;
      nbQuote := 0;
      repeat
        if (s[i] = expParClose) and (nbQuote = 0) then
        begin
          if nbPar = 0 then
            CheckOperators;
          if not opFound then
            Inc(nbPar);
        end
        else if (s[i] = expParOpen) and (nbQuote = 0) then
        begin
          Dec(nbPar);
          if nbPar < 0 then
            exit; // Expression is not valid
        end
        else if (s[i] = expQuote) then
          nbQuote := (nbQuote+1) mod 2
        else if (nbPar = 0) and (nbQuote = 0) then
        begin
          CheckOperators;
        end;
        Dec(i);
      until (i = 0) or (opFound);
    end else
    begin
      i := 1;
      nbPar := 0;
      nbQuote := 0;
      repeat
        if (s[i] = expParOpen) and (nbQuote = 0) then
        begin
          if nbPar = 0 then
            CheckOperators;
          if not opFound then
            Inc(nbPar);
        end
        else if (s[i] = expParClose) and (nbQuote = 0) then
        begin
          Dec(nbPar);
          if nbPar < 0 then
            exit; // Expression is not valid
        end
        else if (s[i] = expQuote) then
          nbQuote := (nbQuote+1) mod 2
        else if (nbPar = 0) and (nbQuote = 0) then
        begin
          CheckOperators;
        end;
        Inc(i);
      until (i = len2+1) or (opFound);
    end;
    if opFound then
      break;
  end;

  // Operator not found and expression is valid
  if (not opFound) and (nbPar = 0) and (nbQuote = 0) then
  begin
    // A variable or constant
    s := FEValue;
    if (s[1] = expQuote) and (s[len] = expQuote) then
    begin
      s := Copy(s, 2, len-2);
      FEValue := StringReplace(s, expQuote + expQuote, expQuote, [rfReplaceAll]);
      FEType := etyString;
      if IsStrDate(FEValue) then
        FEType := etyDate;
    end
    else if (EVarParser <> nil) and EVarParser.IsVar(s) then
    begin
      FEValue := EVarParser.GetVarId(s);
      FEType := etyVariable;
    end
    else
      FEType := GetStrType(FEValue);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExpression.IsValid: Boolean;
begin
  Result := (FEType <> etyNone) or (FEOperator <> nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExpression.GetDepth: Integer;
begin
  Result := Depth;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExpression.Eval(VarObject: TObject;
  var vVal: string; var vType: TExprType);
begin
  vVal := FEValue;
  vType := etyNone;
  if (FEOperator <> nil) then
  begin
    if Assigned(FEOperator.EvalFunction) then
      FEOperator.EvalFunction(Self, VarObject, vVal, vType);
  end
  else if (FEType = etyVariable) then
  begin // Variable
    vVal := EVarParser.GetVarValue(FEValue, VarObject);
    vType := EVarParser.GetVarType(FEValue, VarObject);
    if (vType <> etyString) and (vType <> etyNone) and
      (not IsStrType(vVal, vType)) then
      vType := etyString;
  end
  else
  begin
    vVal := FEValue;
    vType := FEType;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExpression.EvalAsBoolean(VarObject: TObject): Boolean;
var
  Val1: string;
  Type1: TExprType;
begin
  Eval(VarObject, Val1, Type1);
  Result := (Type1 <> etyNone) and (SameText(Val1, expBoolTrue));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetStrType(Str: string): TExprType;
begin
  Result := etyString;
  if IsStrBoolean(Str) then
    Result := etyBoolean
  else if IsStrDate(Str) then
    Result := etyDate
  else if IsStrInteger(Str) then
    Result := etyInteger
  else if IsStrFloat(Str) then
    Result := etyFloat;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsStrType(Str: string; Typ: TExprType): Boolean;
begin
  case Typ of
    etyString:
      Result := True;
    etyBoolean:
      Result := IsStrBoolean(Str);
    etyDate:
      Result := IsStrDate(Str);
    etyInteger:
      Result := IsStrInteger(Str);
    etyFloat:
      Result := IsStrFloat(Str);
    else
      Result := False;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsStrBoolean(Str: string): Boolean;
begin
  Result := SameText(Str, expBoolTrue) or SameText(Str, expBoolFalse);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsStrDate(Str: string): Boolean;
begin
  Result := GetStrDateDef(Str, 0) <> 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsStrInteger(Str: string): Boolean;
begin
  Result := GetStrIntegerDef(Str, MinInt) <> MinInt;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsStrFloat(Str: string): Boolean;
begin
  Result := GetStrFloatDef(Str, MinDouble) <> MinDouble;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetStrBoolean(Str: string): Boolean;
begin
  Result := SameText(Str, expBoolTrue);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetStrDateDef(Str: string; Default: TDateTime): TDateTime;
begin
  Result := StrToDateDef(Str, Default);
  if Result = 0 then
    Result := StrToDateDef(Str, Default, ExprFormatSettings);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetStrIntegerDef(Str: string; Default: Integer): Integer;
begin
  Result := StrToIntDef(Str, Default);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetStrFloatDef(Str: string; Default: Extended): Extended;
begin
  Result := StrToFloatDef(CharReplace(Str, ',', '.'), Default,
    ExprFormatSettings);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalIfOp(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1, Val2: string;
  Type1, Type2: TExprType;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;

    // if left operand is true then take right operand
    // else expression is not valid
    Expression1.Eval(VarObject, Val1, Type1);
    Expression2.Eval(VarObject, Val2, Type2);

    if (Type1 = etyNone) or (Type2 = etyNone) then
      exit;

    if (Type1 = etyBoolean) and (SameText(Val1, expBoolTrue)) then
    begin
      vVal := Val2;
      vType := Type2;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalElseOp(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1, Val2: string;
  Type1, Type2: TExprType;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;

    // if left operand is not valid then take right operand
    // else take left operand
    Expression1.Eval(VarObject, Val1, Type1);
    Expression2.Eval(VarObject, Val2, Type2);

    if (Type1 = etyNone) and (Type2 = etyNone) then
      exit;

    if (Type1 = etyNone) then
    begin
      vVal := Val2;
      vType := Type2;
    end
    else
    begin
      vVal := Val1;
      vType := Type1;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalOrOp(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1: string;
  Type1: TExprType;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;
    Expression1.Eval(VarObject, Val1, Type1);
    if (Type1 = etyBoolean) and (not SameText(Val1, expBoolTrue)) then
      Expression2.Eval(VarObject, Val1, Type1);
    if Type1 = etyBoolean then
    begin
      vVal := Val1;
      vType := etyBoolean;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalAndOp(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1: string;
  Type1: TExprType;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;
    Expression1.Eval(VarObject, Val1, Type1);
    if (Type1 = etyBoolean) and (SameText(Val1, expBoolTrue)) then
      Expression2.Eval(VarObject, Val1, Type1);
    if Type1 = etyBoolean then
    begin
      vVal := Val1;
      vType := etyBoolean;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalNotOp(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1: string;
  Type1: TExprType;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;
    Expression2.Eval(VarObject, Val1, Type1);
    if (Type1 = etyBoolean) then
    begin
      if (SameText(Val1, expBoolTrue)) then
        vVal := expBoolFalse
      else
        vVal := expBoolTrue;
      vType := etyBoolean;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalCompOps(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1, Val2: string;
  Type1, Type2: TExprType;
  Date1, Date2: TDateTime;
  Flt1, Flt2: Extended;
  Int1, Int2: Integer;
  Bool1, Bool2, Ok: Boolean;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;

    Expression1.Eval(VarObject, Val1, Type1);
    Expression2.Eval(VarObject, Val2, Type2);

    if (Type1 = etyNone) or (Type2 = etyNone) then
      exit;

    Ok := False;
    Bool1 := False;
    if (Type1 = etyBoolean) and (Type2 = etyBoolean) then
    begin // Compare booleans
      Bool1 := GetStrBoolean(Val1);
      Bool2 := GetStrBoolean(Val2);
      case EOperator.Id of
        eopEqual:
          Bool1 := Bool1 = Bool2;
        eopNotEqual:
          Bool1 := Bool1 <> Bool2;
        else
          exit;
      end;
      Ok := True;
    end
    else if (Type1 = etyDate) and (Type2 = etyDate) then
    begin // Compare dates
      Date1 := GetStrDateDef(Val1, 0);
      Date2 := GetStrDateDef(Val2, 0);
      if (Date1 = 0) or (Date2 = 0) then
        exit;
      case EOperator.Id of
        eopEqual:
          Bool1 := Date1 = Date2;
        eopNotEqual:
          Bool1 := Date1 <> Date2;
        eopGreater:
          Bool1 := Date1 > Date2;
        eopLower:
          Bool1 := Date1 < Date2;
        eopGOrEqual:
          Bool1 := Date1 >= Date2;
        eopLOrEqual:
          Bool1 := Date1 <= Date2;
        else
          exit;
      end;
      Ok := True;
    end
    else if (Type1 = etyInteger) and (Type2 = etyInteger) then
    begin // Compare integers
      Int1 := GetStrIntegerDef(Val1, MinInt);
      Int2 := GetStrIntegerDef(Val2, MinInt);
      if (Int1 = MinInt) or (Int2 = MinInt) then
        exit;
      case EOperator.Id of
        eopEqual:
          Bool1 := Int1 = Int2;
        eopNotEqual:
          Bool1 := Int1 <> Int2;
        eopGreater:
          Bool1 := Int1 > Int2;
        eopLower:
          Bool1 := Int1 < Int2;
        eopGOrEqual:
          Bool1 := Int1 >= Int2;
        eopLOrEqual:
          Bool1 := Int1 <= Int2;
        else
          exit;
      end;
      Ok := True;
    end
    else if ((Type1 = etyFloat) or (Type1 = etyInteger)) and
      ((Type2 = etyFloat) or (Type2 = etyInteger)) then
    begin // Compare floats
      Flt1 := GetStrFloatDef(Val1, MinDouble);
      Flt2 := GetStrFloatDef(Val2, MinDouble);
      if (Flt1 = MinDouble) or (Flt2 = MinDouble) then
        exit;
      case EOperator.Id of
        eopEqual:
          Bool1 := Flt1 = Flt2;
        eopNotEqual:
          Bool1 := Flt1 <> Flt2;
        eopGreater:
          Bool1 := Flt1 > Flt2;
        eopLower:
          Bool1 := Flt1 < Flt2;
        eopGOrEqual:
          Bool1 := Flt1 >= Flt2;
        eopLOrEqual:
          Bool1 := Flt1 <= Flt2;
        else
          exit;
      end;
      Ok := True;
    end
    else if (Type1 = etyString) or (Type2 = etyString) then
    begin // Compare strings
      case EOperator.Id of
        eopEqual:
          Bool1 := AnsiSameTextEx(Val1, Val2, True);
        eopNotEqual:
          Bool1 := not AnsiSameTextEx(Val1, Val2, True);
        eopGreater:
          Bool1 := AnsiCompareTextEx(Val1, Val2, True) > 0;
        eopLower:
          Bool1 := AnsiCompareTextEx(Val1, Val2, True) < 0;
        eopGOrEqual:
          Bool1 := AnsiCompareTextEx(Val1, Val2, True) >= 0;
        eopLOrEqual:
          Bool1 := AnsiCompareTextEx(Val1, Val2, True) <= 0;
        eopContains:
          Bool1 := AnsiContainsTextEx(Val1, Val2, True);
        eopMatchRegExp:
          try
            Bool1 := ExecRegExpr(Val2, Val1);
          except
            exit;
          end;
        else
          exit;
      end;
      Ok := True;
    end;
    if Ok then
    begin
      if Bool1 then
        vVal := expBoolTrue
      else
        vVal := expBoolFalse;
      vType := etyBoolean;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalArithmOps(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1, Val2: string;
  Type1, Type2: TExprType;
  Date1: TDateTime;
  Flt1, Flt2: Extended;
  Int1, Int2: Integer;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;

    Expression1.Eval(VarObject, Val1, Type1);
    Expression2.Eval(VarObject, Val2, Type2);

    if (Type1 = etyNone) or (Type2 = etyNone) then
      exit;

    if ((Type1 = etyDate) and (Type2 = etyInteger)) or
      ((Type1 = etyInteger) and (Type2 = etyDate)) then
    begin // Operation on dates
      if (Type1 = etyDate) and (Type2 = etyInteger) then
      begin
        Date1 := GetStrDateDef(Val1, 0);
        Int1 := GetStrIntegerDef(Val2, MinInt);
      end else
      begin
        Date1 := GetStrDateDef(Val2, 0);
        Int1 := GetStrIntegerDef(Val1, MinInt);
      end;
      if (Date1 = 0) or (Int1 = MinInt) then
        exit;
      case EOperator.Id of
        eopAdd:
        begin
          vVal := DateToStr(IncDay(Date1, Int1));
          vType := etyDate;
        end;
        eopMinus:
        begin
          vVal := DateToStr(IncDay(Date1, -Int1));
          vType := etyDate;
        end;
      end;
    end
    else if (Type1 = etyInteger) and (Type2 = etyInteger) then
    begin // Operation on integers
      Int1 := GetStrIntegerDef(Val1, MinInt);
      Int2 := GetStrIntegerDef(Val2, MinInt);
      if (Int1 = MinInt) or (Int2 = MinInt) then
        exit;
      case EOperator.Id of
        eopMult:
        begin
          vVal := IntToStr(Int1 * Int2);
          vType := etyInteger;
        end;
        eopDiv:
        begin
          vVal := IntToStr(Int1 div Int2);
          vType := etyInteger;
        end;
        eopMod:
        begin
          vVal := IntToStr(Int1 mod Int2);
          vType := etyInteger;
        end;
        eopAdd:
        begin
          vVal := IntToStr(Int1 + Int2);
          vType := etyInteger;
        end;
        eopMinus:
        begin
          vVal := IntToStr(Int1 - Int2);
          vType := etyInteger;
        end;
      end;
    end
    else if ((Type1 = etyFloat) or (Type1 = etyInteger)) and
      ((Type2 = etyFloat) or (Type2 = etyInteger)) then
    begin // Operation on floats
      Flt1 := GetStrFloatDef(Val1, MinDouble);
      Flt2 := GetStrFloatDef(Val2, MinDouble);
      if (Flt1 = MinDouble) or (Flt2 = MinDouble) then
        exit;
      case EOperator.Id of
        eopMult:
        begin
          vVal := FloatToStr(Flt1 * Flt2);
          vType := etyFloat;
        end;
        eopDiv:
        begin
          if Flt2 = 0 then
            exit;
          vVal := FloatToStr(Flt1 / Flt2);
          vType := etyFloat;
        end;
        eopMod:
        begin
          Int1 := Trunc(Flt1);
          Int2 := Trunc(Flt2);
          if (Int1 <> Flt1) or (Int2 <> Flt2) then
            exit;
          vVal := IntToStr(Int1 mod Int2);
          vType := etyInteger;
        end;
        eopAdd:
        begin
          vVal := FloatToStr(Flt1 + Flt2);
          vType := etyFloat;
        end;
        eopMinus:
        begin
          vVal := FloatToStr(Flt1 - Flt2);
          vType := etyFloat;
        end;
      end;
    end
    else if (Type1 = etyString) or (Type2 = etyString) then
    begin // Operation on strings
      case EOperator.Id of
        eopAdd:
        begin
          vVal := Val1 + Val2;
          vType := etyString;
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure EvalCastOps(Expression: TExpression; VarObject: TObject; var vVal: string; var vType: TExprType);
var
  Val1: string;
  Type1: TExprType;
  Expr: TExpression;
begin
  with Expression do
  begin
    vVal := EValue;
    vType := etyNone;

    Expression2.Eval(VarObject, Val1, Type1);

    if (Type1 = etyNone) then
      exit;

    case EOperator.Id of
      eopCastBoolean:
      if IsStrBoolean(Val1) then
      begin
        vVal := Val1;
        vType := etyBoolean;
      end;
      eopCastDate:
      if IsStrDate(Val1) then
      begin
        vVal := Val1;
        vType := etyDate;
      end;
      eopCastInteger:
      if IsStrInteger(Val1) then
      begin
        vVal := Val1;
        vType := etyInteger;
      end
      else if IsStrFloat(Val1) then
      begin
        vVal := IntToStr(Trunc(GetStrFloatDef(Val1, 0)));
        vType := etyInteger;
      end;
      eopCastFloat:
      if IsStrFloat(Val1) then
      begin
        vVal := Val1;
        vType := etyFloat;
      end;
      eopCastString:
      begin
        vVal := Val1;
        vType := etyString;
      end;
      eopCastEval:
      begin
        if (Type1 = etyString) and (Trim(Val1) = '') then
        begin
          vVal := '';
          vType := etyString;
        end else
        begin
          if (EVarParser <> nil) then
            Inc(EVarParser.FNbSubExprEval);
          if (EVarParser <> nil) and (EVarParser.FNbSubExprEval <= ExprMaxSubExprEval) then
            Expr := TExpression.Create(Val1, EVarParser)
          else
            Expr := TExpression.Create(Val1, nil);
          Expr.Eval(VarObject, vVal, vType);
          vVal := vVal;
          vType := vType;
          Expr.Free;
          if(EVarParser <> nil) then
            Dec(EVarParser.FNbSubExprEval);
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

initialization
  ExprGroupsOperatorsPrecedence := TExprGroupsOperators.Create;

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopIf, '?', EvalIfOp, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopElse, ':', EvalElseOp, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopOr, ' or ', EvalOrOp, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopAnd, ' and ', EvalAndOp, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopNot, ' not ', EvalNotOp, eodRight));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopContains, '<--', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopMatchRegExp, '<==', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopGOrEqual, '>=', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopLOrEqual, '<=', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopNotEqual, '<>', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopEqual, '=', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopGreater, '>', EvalCompOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopLower, '<', EvalCompOps, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopAdd, '+', EvalArithmOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopMinus, '-', EvalArithmOps, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easLeftToRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopMult, '*', EvalArithmOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopDiv, '/', EvalArithmOps, eodBoth));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopMod, '%', EvalArithmOps, eodBoth));

  GIdx := ExprGroupsOperatorsPrecedence.Add(TExprOperators.Create(easRightToLeft));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastBoolean, '(bool)', EvalCastOps, eodRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastDate, '(date)', EvalCastOps, eodRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastInteger, '(int)', EvalCastOps, eodRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastFloat, '(float)', EvalCastOps, eodRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastString, '(string)', EvalCastOps, eodRight));
  ExprGroupsOperatorsPrecedence.Items[GIdx].Add(TExprOperator.Create(eopCastEval, '(eval)', EvalCastOps, eodRight));

  with ExprFormatSettings do
  begin
    ThousandSeparator := #0;
    DecimalSeparator := '.';
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-mm-dd';
    TimeSeparator := ':';
    ShortTimeFormat := 'HH:nn';
    LongTimeFormat := 'HH:nn:ss';
  end;

finalization
  ExprGroupsOperatorsPrecedence.Free;

end.
