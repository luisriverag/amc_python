unit ifpslib;
{
  Innerfuse Pascal Script Library
  For license see Innerfuse Pascal Script license file

}
interface
uses
  ifspas, ifs_var, ifs_utl, ifs_obj;

procedure RegisterTIfStringList(p: TIfPasScript);
{
Type
  TIfStringList = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;

    procedure Clear;
    function GetItem(I: Integer): string;
    procedure SetItem(I: Integer; S: string);
    function Count: Integer;
    function Add(s: string): Integer;
    procedure Delete(I: Integer);
  end;
}

function GetTIFStringList(SE: TIFPasScript; P: PCreatedClass): TIfStringList;

implementation

procedure TIFStrListFree(id: Pointer; Data: Pointer);
begin
  TIfStringList(Data).Free;
end;

const
  TIfStringListT =
    'class(TObject) private data: ResourcePointer;public constructor Create; destructor Destroy; override; ' +
    'procedure Clear;function GetItem(I: Integer): string;procedure SetItem(I: ' +
    'Integer; S: string);function Count: Integer; function Add(s: string): Integer;' +
    'procedure Delete(I: Integer);end;';

function GetTIFStringList(SE: TIFPasScript; P: PCreatedClass): TIfStringList;
var
  res: PIFVariant;
begin
  if not GetClassVariable2(p, p^.classType^.ext, 'DATA', res, True) then begin
    GetTIFStringList := nil;
    exit;
  end;
  if SE.IsValidResource(TIFStrListFree, res^.Cv_Int1) then
    GetTIFStringList := res^.CV_Int1
  else
    GetTIFStringList := nil;
end;

function StrListProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  p, Self: PIfVariant;
begin
  Self := Vm_Get(Params, 0);
  StrListProc := ENoError;
  if not GetClassVariable2(Self^.CV_Class, proc^.ClassType^.Ext, 'DATA', p, True) then begin
    StrListProc := ENotSupported;
    exit;
  end;
  if proc^.Name = '!CREATE' then begin
    p^.Cv_Int1 := TIfStringList.Create;
    Sender.AddResource(TIFStrListFree, p^.Cv_Int1);
  end else if proc^.Name = '!DESTROY' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      Sender.RemoveResource(p^.Cv_Int1);
      TIfStringList(p^.Cv_Int1).Free;
      p^.Cv_Int1 := nil;
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!CLEAR' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      TIfStringList(p^.Cv_Int1).Clear;
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!GETITEM' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      SetString(res, TIfStringList(p^.Cv_Int1).GetItem(GetInteger(GetVarLink(Vm_Get(Params, 1)))));
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!SETITEM' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      TIfStringList(p^.Cv_Int1).SetItem(GetInteger(GetVarLink(Vm_Get(Params, 1))), GetString(GetVarLink(Vm_Get(Params, 2))));
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!COUNT' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      SetInteger(res, TIfStringList(p^.Cv_Int1).Count);
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!ADD' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      SetInteger(res, TIfStringList(p^.Cv_Int1).Count);
      TIfStringList(p^.Cv_Int1).Add(GetString(GetVarLink(Vm_Get(Params, 1))));
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else if proc^.Name = '!DELETE' then begin
    if Sender.IsValidResource(TIFStrListFree, p^.Cv_Int1) then begin
      TIfStringList(p^.Cv_Int1).Delete(GetInteger(GetVarLink(Vm_Get(Params, 1))));
    end else
      StrListProc := EClassNotCreated; // EInternalError
  end else StrListProc := EUnknownIdentifier;
end;

procedure RegisterTIfStringList(p: TIfPasScript);
begin
  p.AddClass('TIfStringList', TIfStringListT, @StrListProc);
end;

end.

