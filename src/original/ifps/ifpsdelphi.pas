unit ifpsdelphi;

interface
uses
  SysUtils, ifpscall, ifspas, ifs_utl, ifs_var;

function RegisterDelphiFunction(ScriptEngine: TIfPasScript; const Declaration: string; Address: Pointer): Boolean;

{
Valid types for in Declaration:
Byte
Shortint
Word
Smallint
Cardinal
Longint
Integer
PChar (string with EXT param of TypeRec to 1) (*)
String
Single
Double
Extended

Valid calling conventions:
register (default)
stdcall
cdecl
pascal

* Pchar type does not support Var parameter.


  Defines for this unit:
    D1_DEFCCPPASCAL - Set default calling convention to Pascal.
    D1_DEFCCCDECL - Set default calling convention to Cdecl.
    D1_DEFCCSTDCALL - Set default calling convention to StdCall.
    Else the default Calling Convention is Register.

}

implementation
const
  DefaultCallingConvention: TCallingConvention =
{$IFDEF D1_DEFCCPPASCAL}ccPascal; {$ELSE}
{$IFDEF D1_DEFCCCDECL}ccCdecl; {$ELSE}
{$IFDEF D1_DEFCCSTDCALL}ccStdcall; {$ELSE}
  ccRegister;
{$ENDIF}
{$ENDIF}
{$ENDIF}

function DProc(Sender: TIFPasScript; ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  try
    if not InnerfuseCall(Sender, nil, PProcedure(Proc)^._Ext, TCallingConvention(PProcedure(Proc)^._Ext2), Params, Res) then
    begin
      Sender.RunError2(Sender, ECustomError, 'Could not call function');
      DProc := ECustomError;
    end else
      DPRoc := ENoError;
  except
    on e: Exception do
    begin
      Sender.RunError2(Sender, ECustomError, e.Message);
      DProc := ECustomError;
    end;
  end;
end;

function RegisterDelphiFunction(ScriptEngine: TIfPasScript; const Declaration: string; Address: Pointer): Boolean;
var
  FuncName, FuncParam: string;
  cc: TCallingConvention;
  P: PProcedure;
begin
  if not ReadHeader(ScriptEngine, Declaration, FuncName, FuncParam, CC, DefaultCallingConvention) then
    RegisterDelphiFunction := False
  else begin
    p := ScriptEngine.AddFunction(@dproc, 'procedure ' + FuncName + ';', Address);
    if assigned(p) then
    begin
      with P^ do
      begin
        _Ext2 := Pointer(CC);
        Decl := FuncParam;
        Name := FuncName;
      end;
      RegisterDelphiFunction := True;
    end else
      RegisterDelphiFunction := False;
  end;
end;

end.

