unit ifpsdll;
{
  Innerfuse Pascal Script DLL Library
  For license see Innerfuse Pascal Script license file

  This unit and all parts of it may only be used with Innerfuse Pascal
  Script.

  Does not work in attached units.
}
{$I ifs_def.inc}
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

procedure RegisterDllCallLibrary(Sender: TIFPasScript);
{
Adds:

  function LoadLibrary(Name: string; var Res: ResourcePointer): Boolean;
  procedure CloseLibrary(Res: ResourcePointer);
  function MapLibraryProc(RealProcName, Declaration: string): Boolean;

Valid types for in Declaration:
Boolean,
WordBool,
LongBool,
Byte
Shortint
Word
Smallint
Longint
Integer
Cardinal
PChar (string with EXT param of TypeRec to 1) (*)
String

Valid calling conventions:
register (default)
stdcall
cdecl
pascal

Pchar type does not support Var parameter.
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
  PCreatedDll = ^TCreatedDll;
  TCreatedDll = record
    AlreadyFreed: Boolean;
{$IFDEF LINUX}
    Dll: Pointer;
{$ELSE}
    Dll: THandle;
{$ENDIF}
    Calls: TIFList; { Contains PProcedure pointers. PProcedure()^.Ext contains a pointer to the procedure. }
  end;

procedure FreeProc(id: Pointer; Data: PCreatedDll);
begin
  if not data.AlreadyFreed then
  begin
    Data^.Calls.Free;
{$IFDEF LINUX}
    dlclose(Data^.Dll);
{$ELSE}
    FreeLibrary(Data^.Dll);
{$ENDIF}
  end;
  Dispose(Data);
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



function MProc(Sender: TIFPasScript; ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  n: PCreatedDll;
  p: PProcedure;
  I: Longint;
  procedure F1;
  var
    FuncName, FuncParam: string;
    CC: TCallingConvention;
    u: Pointer;
  begin
    if ReadHeader(Sender, GetString(VM_Get(Params, 2)), FuncName, FuncParam, CC, DefaultCallingConvention) then
    begin
{$IFDEF LINUX}
      u := dlsym(n^.Dll, PChar(GetString(VM_Get(Params, 1))));
{$ELSE}
      u := GetProcAddress(n^.Dll, PChar(GetString(VM_Get(Params, 1))));
{$ENDIF}
      if u <> nil then
      begin
        u := Sender.AddFunction(@DProc, 'procedure ' + FuncName + ';', U);
        n^.calls.Add(U);
        PProcedure(U)^.Decl := FuncParam;
        PProcedure(U)^._Ext2 := Pointer(Byte(CC));
        SetBoolean(Res, True);
      end else
        SetBoolean(Res, False);
    end else
      SetBoolean(Res, False);
  end;
begin
  MProc := ENoError;
  if Proc^.Name = 'LOADLIBRARY' then
  begin
    New(N);
{$IFDEF LINUX}
    N^.Dll := dlopen(PChar(GetString(VM_Get(Params, 0))), RTLD_LAZY);
{$ELSE}
    N^.Dll := LoadLibrary(PChar(GetString(VM_Get(Params, 0))));
{$ENDIF}
    if N^.Dll = {$IFDEF LINUX}nil{$ELSE}0{$ENDIF} then
    begin
      Dispose(N);
      SetBoolean(Res, False);
    end else begin
      N^.AlreadyFreed := False;
      N^.Calls := TIFList.Create;
      GetVarLink(VM_Get(Params, 1))^.Cv_Int1 := N;
      GetVarLink(VM_Get(Params, 1))^.CV_Int2 := @MProc;
      SetBoolean(Res, True);
      Sender.AddResource(@FreeProc, N);
    end;
  end else if Proc^.Name = 'CLOSELIBRARY' then
  begin
    if GetVarLink(VM_Get(Params, 0))^.CV_Int2 <> @MProc then
    begin
      MPRoc := ETypeMismatch;
      exit;
    end;
    n := GetVarLink(VM_Get(Params, 0))^.CV_Int1;
    if n^.AlreadyFreed then
    begin
      MProc := ETypeMismatch;
      exit;
    end;
    for i := 0 to Longint(n^.Calls.Count) - 1 do
    begin
      Sender.RemoveFunction(n^.Calls.GetItem(I));
      p := N^.Calls.GetItem(I);
      Dispose(P);
    end;
{$IFDEF LINUX}
    dlclose(N^.Dll);
{$ELSE}
    FreeLibrary(N^.DLL);
{$ENDIF}
    N^.AlreadyFreed := True;
  end else if Proc^.Name = 'MAPLIBRARYPROC' then
  begin
    if GetVarLink(VM_Get(Params, 0))^.CV_Int2 <> @MProc then
    begin
      MPRoc := ETypeMismatch;
      exit;
    end;
    n := GetVarLink(VM_Get(Params, 0))^.CV_Int1;
    if n^.AlreadyFreed then
    begin
      MProc := ETypeMismatch;
      exit;
    end;
    F1;
  end;
end;

procedure RegisterDllCallLibrary(Sender: TIFPasScript);
begin
  Sender.AddFunction(@MProc, 'function LoadLibrary(Name: string; var Res: ResourcePointer): Boolean;', nil);
  Sender.AddFunction(@MProc, 'procedure CloseLibrary(Res: ResourcePointer);', nil);
  Sender.AddFunction(@MProc, 'function MapLibraryProc(Res: ResourcePointer; DllProcName, Declaration: string): Boolean;', nil);
end;

end.

