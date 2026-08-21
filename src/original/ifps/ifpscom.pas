unit ifpscom;
{
  Innerfuse Pascal Script Com Object Library
  For license see Innerfuse Pascal Script license file

  Version: 0.1 beta.

}
interface
uses
  ifspas, ifs_utl, ifs_var, ifs_obj;


procedure RegisterComLibrary(p: TIfPasScript);
{

Type
  IDispatch = (TIfComObject)

function CreateOleObject(Name: string): IDispatch;

}

implementation
(*
uses
  ActiveX, ComObj, Sysutils;

type
  TIfComObject = class(TIfsExtClass)
  private
    FObject: IDispatch;
    FObjects: TIfStringList;
    procedure EnumProcs;
  public
    function FindProc(FSelf: PIFPSClassSelf; const Name: string): Longint; override;
    function GetProcHeader(FSelf: PIFPSClassSelf; I: Longint): string; override;
    function CallProc(FSelf: PIFPSClassSelf; I: Longint; Params: PVariableManager): PIFVariant; override;
    function GetProcCount(FSelf: PIFPSClassSelf): Longint; override;
  end;


function ComProc(Sender: TIfPasScript; ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  p: TIfComObject;
begin
  if Proc^.Name = 'CREATEOLEOBJECT' then
  begin
    try
      p := TIfComObject.Create(Sender, CreateOleObject(GetString(VM_Get(Params, 0))));
      Res.CV_ExternalObject := CreateResource(p);
      ComProc := ENoError;
    except
      on e: Exception do
      begin
        Sender.RunError2(Sender, ECustomError, 'could not create ole object:'+ E.Message);
        ComProc := ECustomError;
      end else ComProc := ECustomError;
    end;
  end else
    ComProc := EUnknownIdentifier;
end;

function D1(ScriptEngine: TIFPasScript; Res: PIfVariant; I: IDispatch): Boolean;
begin
  if ChangeType(Res, ScriptEngine.GetType('IDISPATCH')) = nil then
  begin
    Result := False;
    exit;
  end;
  res^.CV_ExternalObject := CreateResource(TIfComObject.Create(ScriptEngine, I));
  Result := True;
end;

function D2(ScriptEngine: TIFPasScript; var Res: IDispatch; I: PIfVariant): Boolean;
begin
  if not assigned(I^.CV_ExternalObject) or (PCreatedCustomObject(I^.CV_ExternalObject).AlreadyFreed) or (TIFsCustomObjectType(I^.VType^.Ext) <> TIfComObject) then
  begin
    D2 := False;
    exit;
  end;
  Res := TIFComobject(PCreatedCustomObject(I^.CV_ExternalObject)^.P).FObject;
  D2 := True;
end;
  *)
procedure RegisterComLibrary(p: TIfPasScript);
begin
(*  with p.AddTypeEx('IDispatch')^ do
  begin
    atypeid := CSV_ExternalObject;
    TIFsCustomObjectType(ext) := TIfComObject;
  end;
  p.AddFunction(@ComProc, 'function CreateOleObject(Name: string): IDispatch', nil);
  {$IFDEF USEIDISPATCH}
  IDispatchToIFVariantProc := D1;
  IFVariantToIDispatchProc := D2;
  {$ENDIF}*)
end;
(*
function TIfComObject.FindProc(const Name: string): Longint;
var
  s, n: string;
  i: Longint;
begin
  s := FastUppercase(name);
  for i := 0 to Longint(FObjects.Count)-1 do
  begin
    n := FObjects.GetItem(I);
    n := copy(N, 1, pos(' ', n)-1);
    if n = s then
    begin
      FindProc := I;
      exit;
    end;
  end;
  FindProc := -1;
end;

function TIfComObject.GetProcHeader(I: Longint): string;
begin
  Result := FObjects.GetItem(I);
  Delete(Result, 1, pos(' ', Result)); // delete the name
end;

function TIfComObject.CallProc(I: Longint; Params: PVariableManager): PIFVariant;
var
  Name: string;
  FTemp: WideString;
  IL: Longint;
  DispParams: TDispParams;
  adispid: TDispID;
  Ex: TExcepInfo;
  Res: OleVariant;
  r: Variant;
begin
  Name := FObjects.GetItem(I);
  Name := Copy(Name, 1, pos(' ',Name)-1);
  FTemp := Name;
  if succeeded(FObject.GetIDsOfNames(GUID_NULL, @FTemp, 1, 0, @adispid)) then
  begin
    try
      DispParams.cNamedArgs := 0;
      DispParams.cArgs := VM_Count(Params);
      DispParams.rgdispidNamedArgs := nil;
      GetMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
      for il := 0 to DispParams.cArgs-1 do
      begin
        if not TIfPasScript(ScriptEngine).IfVariantToVariant(VM_Get(Params, DispParams.cArgs - il - 1), r) then
        begin
          FreeMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
          TIFPasScript(ScriptEngine).RunError2(ScriptEngine, ECustomError, 'could not convert parameter');
          CallProc := nil;
          exit;
        end;
        OleVariant(DispParams.rgvarg^[il]) := R;
      end;
      if Succeeded(FObject.Invoke(adispid, GUID_NULL, 0, DISPATCH_METHOD or DISPATCH_PROPERTYGET, DispParams, @Res, @ex, nil)) then
      begin
        r := Res;
        Result := TIFPasScript(ScriptEngine).CreateVarType(nil);
        if not TIFPasScript(ScriptEngine).VariantToIFVariant(r, result) then
        begin
          TIFPasScript(ScriptEngine).RunError2(ScriptEngine, ECustomError, 'could convert result');
          FreeMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
          DestroyCajVariant(Result);
          CallProc := nil;
          exit;
        end;
      end else
      begin
        TIFPasScript(ScriptEngine).RunError2(ScriptEngine, ECustomError, 'failled calling ole method');
        CallProc := nil;
        FreeMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
        exit;
      end;
    except
      TIFPasScript(ScriptEngine).RunError2(ScriptEngine, ECustomError, 'error calling ole method');
      CallProc := nil;
      FreeMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
      exit;
    end;
    FreeMem(DispParams.rgvarg, sizeof(TVariantArg) * DispParams.cArgs);
  end else
  begin
    TIFPasScript(ScriptEngine).RunError2(ScriptEngine, ECustomError, 'could not find ole method');
    CallProc := nil;
    exit;
  end;
end;

function TIfComObject.GetProcCount: Longint;
begin
  Result := FObjects.Count;
end;

constructor TIfComObject. Create(SE: TIfPasScript; Obj: IDispatch);
begin
  inherited Create(Se);
  fObject := Obj;
  FObjects := TIfStringList.Create;
  EnumProcs;
end;

destructor TIfComObject.Destroy;
begin
  FObject := nil;
  FObjects.Free;
  inherited Destroy;
end;

procedure TIfComObject.EnumProcs;
var
  Count, I, I2, I3, ParamCount: Longint;
  TI: ITypeInfo;
  TA: PTypeAttr;
  FD: PFuncDesc;
  Names: PBStrList;
  FF: string;
  N: PTypeRec;
begin
  n := TIfPasScript(ScriptEngine).AddTypeEx('');
  n^.atypeid := CSV_Variant;
  if Succeeded(FObject.GetTypeInfoCount(Count)) then
  begin
    for i := 0 to Count-1 do
    begin
      if Succeeded(FObject.GetTypeInfo(I, 0, TI)) and Succeeded(TI.GetTypeAttr(TA)) and (TA^.typekind = TKIND_DISPATCH) then
      begin
        for I2 := 0 to TA^.cFuncs-1 do
        begin
          if succeeded(TI.GetFuncDesc(I2,FD)) then
          begin
            if FD.cParamsOpt = -1 then
              ParamCount := Fd.cParams
            else
              ParamCount := fd.cParams - Fd.cParamsOpt;
            GetMem(Names, Sizeof(TBStr));
            if Succeeded(TI.GetNames(fd.memid, Names, 1, I3)) then
            begin
              FF := FastUppercase(Names^[0])+#0#0#0;
              while ParamCount > 0 do
              begin
                FF := FF + #0#5#0#0#0'PARAM'+ mi2s(Longint(n));
                Dec(ParamCount);
              end;
            end;
            FreeMem(Names, Sizeof(TBStr));
            FObjects.Add(FF);
            TI.ReleaseFuncDesc(FD);
          end;
        end;
        TI.ReleaseTypeAttr(TA);
      end;
    end;
  end;
end;
  *)
end.

