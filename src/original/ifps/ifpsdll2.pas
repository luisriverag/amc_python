unit ifpsdll2;

interface
uses
  ifpscall, ifspas, ifs_var, ifs_utl, {$IFDEF LINUX}libc{$ELSE}Windows{$ENDIF};

{
  Defines for this unit:
    DEFCCPPASCAL - Set default calling convention to Pascal.
    DEFCCCDECL - Set default calling convention to Cdecl.
    DEFCCSTDCALL - Set default calling convention to StdCall.
    Else the default Calling Convention is Register.
}


function DllExternalProc(id: Pointer; Sender: TIFPasScript; const Param, FuncName: string; Func: PProcedure; const CallingConvention: string): Boolean;
{
  Use this as the OnExternal Handler to make 'External' work.

  syntax:
    procedure MyCall; external 'mydll.dll' name 'MyCall'; stdcall;
}

procedure RegisterDll2library(Sender: TIfPasScript);
{
  Register PChar type.

}

implementation
const
  DefaultCallingConvention: TCallingConvention =
{$IFDEF DEFCCPPASCAL}ccPascal; {$ELSE}
{$IFDEF DEFCCCDECL}ccCdecl; {$ELSE}
{$IFDEF DEFCCSTDCALL}ccStdcall; {$ELSE}
  ccRegister;
{$ENDIF}
{$ENDIF}
{$ENDIF}

type
  PMyDllHandle = ^TMyDllHandle;
  TMyDllHandle = record
    DllName: string;
{$IFDEF LINUX}
    Dll: Pointer;
{$ELSE}
    Dll: THandle;
{$ENDIF}
  end;
  PMYDll = TIFList;

procedure FreeProc(id: Pointer; Data: PMyDll);
  procedure FreeDll(p: PMyDllHandle);
  begin
{$IFDEF LINUX}
    dlclose(p^.Dll);
{$ELSE}
    FreeLibrary(p^.Dll);
{$ENDIF}
    Dispose(P);
  end;
var
  i: Longint;
begin
  for i := 0 to Longint(Data.Count) - 1 do
  begin
    FreeDll(Data.GetItem(I));
  end;
end;

function DProc(Sender: TIFPasScript; ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  if not InnerfuseCall(Sender, nil, PProcedure(Proc)^._Ext, TCallingConvention(PProcedure(Proc)^._Ext2), Params, Res) then
  begin
    Sender.RunError2(Sender, ECustomError, 'Could not call function');
    DProc := ECustomError;
  end else
    DPRoc := ENoError;
end;


function DllExternalProc(id: Pointer; Sender: TIFPasScript; const Param, FuncName: string; Func: PProcedure; const CallingConvention: string): Boolean;
  function GetDllProcPtr(const FuncName: string): Pointer;
  var
    n: PMyDllHandle;
    X: PMydll;
    L: Longint;
  begin
    x := Sender.FindResource(@FreeProc);
    if x = nil then
    begin
      x := TIFList.Create;
      Sender.AddResource(@FreeProc, x);
    end;
    for L := 0 to Longint(x.Count) - 1 do
    begin
      n := x.GetItem(L);
      if n^.DllName = FastUppercase(Param) then
      begin
{$IFDEF LINUX}
        GetDllProcPtr := dlsym(n^.Dll, Pchar(FuncName));
{$ELSE}
        GetDllProcPtr := GetProcAddress(n^.Dll, Pchar(FuncName));
{$ENDIF}
        Exit;
      end;
    end;
    New(n);
    n^.DllName := FastUppercase(Param);
{$IFDEF LINUX}
    n^.Dll := dlopen(PChar(Param), RTLD_LAZY);
{$ELSE}
    n^.Dll := LoadLibrary(PChar(Param));
{$ENDIF}
    if n^.Dll = {$IFDEF LINUX}nil{$ELSE}0{$ENDIF} then
    begin
      Dispose(N);
      GetDllProcPtr := nil;
      exit;
    end;
    x.Add(N);
{$IFDEF LINUX}
    GetDllProcPtr := dlsym(n^.Dll, Pchar(FuncName));
{$ELSE}
    GetDllProcPtr := GetProcAddress(n^.Dll, Pchar(FuncName));
{$ENDIF}
  end;
var
  CC: TCallingConvention;
  p: Pointer;
begin
  if CallingConvention = 'STDCALL' then
    cc := ccStdCall
  else if CallingConvention = 'CDECL' then
    cc := ccCdecl
  else if CallingConvention = 'PASCAL' then
    cc := ccPascal
  else if CallingConvention = 'REGISTER' then
    cc := ccRegister
  else if CallingConvention = '' then
    cc := DefaultCallingConvention
  else begin
    Sender.RunError2(Sender, ECustomError, 'Invalid Calling Convention');
    DllExternalProc := False;
    exit;
  end;
  P := GetDllProcPtr(FuncName);
  if p = nil then
  begin
    Sender.RunError2(Sender, ECustomError, 'Could not find Proc Address');
    DllExternalProc := False;
    exit;
  end;
  Func^.Mode := 1;
  Func^.Proc1 := @DProc;
  Func^._Ext := p;
  Func^._Ext2 := Pointer(Byte(CC));
  DllExternalProc := True;
end;

procedure RegisterDll2library(Sender: TIfPasScript);
begin
  with Sender.AddTypeEx('PChar')^ do
  begin
    atypeid := CSV_String;
    ext := pchar(1);
  end;
  Sender.AddType('LONGBOOL', 'BOOLEAN');
  Sender.AddType('WORDBOOL', 'BOOLEAN');
  // since all variables are 4 bytes aligned, and the rest is 0, there is
  // no real difference in LongBool and WordBool.

end;

end.

