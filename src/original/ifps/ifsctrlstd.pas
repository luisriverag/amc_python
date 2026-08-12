unit ifsctrlstd;

{
  Innerfuse Pascal Script Forms Library
  For license see Innerfuse Pascal Script license file

}
interface
uses
  ifspas, ifs_var, ifs_utl, ifsdfrm;

procedure RegisterStdControlsLibrary(p: TIfPasScript);
{
Before registering this, you must also register the forms library.
This Will register:
type
  TMemo = class(TControl)
  private
    function GetText: string;
    procedure SetText(S: String);
    function GetReadonly: Boolean;
    procedure SetReadonly(B: Boolean);
  public
    Constructor Create(AParent: TControl);
    property Text: string read GetText write SetText;
    property readonly: Boolean read GetReadonly write SetReadonly;
  end;
  TButton = class(TControl)
  private
    function GetDefault: Boolean;
    procedure SetDefault(b: Boolean);
    function GetCancel: Boolean;
    procedure SetCancel(b: Boolean);
    function GetCaption: string;
    procedure SetCaption(s: string);
  public
    Constructor Create(AParent: TControl);
    property Caption: string read GetCaption write SetCaption;
    property Cancel: Boolean read GetCancel write SetCancel;
    property Default: Boolean read GetDefault write SetDefault;
  end;
  TEdit = class(TControl)
  private
    function GetReadonly: Boolean;
    procedure SetReadonly(B: Boolean);
    funtion GetText: string;
    procedure SetText(s: string);
  public
    constructor Create(AParent: TControl);
    property Text: string read GetText write SetText;
    property readonly: Boolean read GetReadonly write SetReadonly;
  end;
  TLabel = class(TControl)
  private
    function GetCaption: string;
    procedure SetCaption(s: string);
  public
    constructory Create(Aparent: TControl);
    property Caption: string read GetCaption write SetCaption;
  end;
}
{$I ifs_def.inc}
implementation
uses
  Classes{$IFDEF CLX}, QControls, QStdCtrls{$ELSE}, Controls, StdCtrls{$ENDIF};
const
  TButtonClass = 'class(TControl)' +
    'private ' +
    'function GetCaption: string;' +
    'function GetDefault: Boolean;' +
    'procedure SetDefault(b: Boolean);' +
    'function GetCancel: Boolean;' +
    'procedure SetCancel(b: Boolean);' +
    'procedure SetCaption(s: string);' +
    'public ' +
    'Constructor Create(AParent: TControl);' +
    'property Caption: string read GetCaption write SetCaption;' +
    'property Cancel: Boolean read GetCancel write SetCancel;' +
    'property Default: Boolean read GetDefault write SetDefault;' +
    'end;';
  TEditClass = 'class(TControl)private '+'function GetReadonly: Boolean;'+
  'procedure SetReadonly(B: Boolean);'+'function GetText: string;procedure SetText(s' +
    ': string);public constructor Create(AParent: TControl);property Text: string ' +
    'read GetText write SetText;property ReadOnly: Boolean read GetReadonly write SetReadonly;end;';
  TLabelClass = 'class(TControl)private function GetCaption: string;procedure ' +
    'SetCaption(s: string);public constructor Create(Aparent: TControl);property ' +
    'Caption: string read GetCaption write SetCaption;end;';
  TMemoClass = 'class(TControl)private '+
    'function GetText: string;'+
    'procedure SetText(S: String);'+
    'function GetReadonly: Boolean;'+
    'procedure SetReadonly(B: Boolean);'+
  'public '+
    'Constructor Create(AParent: TControl);'+
    'property Text: string read GetText write SetText;'+
    'property Readonly: Boolean read GetReadonly write SetReadonly;'+
  'end;';


function TButtonProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Ctrl, Self: PIfVariant;
  v: PVariableManager;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, proc^.ClassType^.Ext, 'FCONTROL', Ctrl, True)) then begin
    TButtonProc := ENotSupported; // internal error
    exit;
  end;
  TButtonProc := ENoError;
  if proc^.Name = '!GETCAPTION' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    SetString(res, TButton(Ctrl^.Cv_Int1).Caption);
  end else if proc^.Name = '!SETCANCEL' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    TButton(Ctrl^.Cv_Int1).Cancel := GetBoolean(Vm_Get(Params, 1));
  end else if proc^.Name = '!SETDEFAULT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    TButton(Ctrl^.Cv_Int1).Default := GetBoolean(Vm_Get(Params, 1));
  end else if proc^.Name = '!GETCANCEL' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    SetBoolean(res, TButton(Ctrl^.Cv_Int1).Cancel);
  end else if proc^.Name = '!GETDEFAULT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    SetBoolean(res, TButton(Ctrl^.Cv_Int1).Default);
  end else if proc^.Name = '!SETCAPTION' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TButtonProc := ENotSupported;
      exit;
    end;
    TButton(Ctrl^.Cv_Int1).Caption := GetString(Vm_Get(Params, 1));
  end else if proc^.Name = '!CREATE' then begin
    Ctrl^.Cv_Int1 := TButton.Create(nil);
    Ctrl^.Cv_Int2 := GetCV_Int2;
    TControl(Ctrl^.Cv_Int1).Tag := Integer(Self^.CV_Class);
    v := VM_Create;
    Vm_Add(v, Self, 'SELF');
    Vm_Add(v, Sender.CopyVariant(Vm_Get(Params, 1)), '');
    Sender.RunScriptProc(GetInheritedProc(proc), v);
    VM_Delete(v, 0);
    VM_Destroy(v);
    TButton(Ctrl^.Cv_Int1).OnClick := TNotifyEvent(Proc2Method(@MyOnClick, Sender));
    TButton(Ctrl^.Cv_Int1).OnKeyPress := TKeyPressEvent(Proc2Method(@MyOnKeyPress, Sender));
  end;
end;

function TLabelProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Ctrl, Self: PIfVariant;
  v: PVariableManager;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, proc^.ClassType^.Ext, 'FCONTROL', Ctrl, True)) then begin
    TLabelProc := ENotSupported; // internal error
    exit;
  end;
  TLabelProc := ENoError;
  if proc^.Name = '!GETCAPTION' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TLabelProc := ENotSupported;
      exit;
    end;
    SetString(res, TLabel(Ctrl^.Cv_Int1).Caption);
  end else if proc^.Name = '!SETCAPTION' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TLabelProc := ENotSupported;
      exit;
    end;
    TLabel(Ctrl^.Cv_Int1).Caption := GetString(Vm_Get(Params, 1));
  end else if proc^.Name = '!CREATE' then begin
    Ctrl^.Cv_Int1 := TLabel.Create(nil);
    Ctrl^.Cv_Int2 := GetCV_Int2;
    TControl(Ctrl^.Cv_Int1).Tag := Integer(Self^.CV_Class);
    v := VM_Create;
    Vm_Add(v, Self, 'SELF');
    Vm_Add(v, Sender.CopyVariant(Vm_Get(Params, 1)), '');
    Sender.RunScriptProc(GetInheritedProc(proc), v);
    VM_Delete(v, 0);
    VM_Destroy(v);
    TLabel(Ctrl^.Cv_Int1).OnClick := TNotifyEvent(Proc2Method(@MyOnClick, Sender));
    TLabel(Ctrl^.Cv_Int1).OnDblClick := TNotifyEvent(Proc2Method(@MyOnDblClick, Sender));
  end;
end;

function TEditProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Ctrl, Self: PIfVariant;
  v: PVariableManager;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, proc^.ClassType^.Ext, 'FCONTROL', Ctrl, True)) then begin
    TEditProc := ENotSupported; // internal error
    exit;
  end;
  TEditProc := ENoError;
  if proc^.Name = '!GETTEXT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TEditProc := ENotSupported;
      exit;
    end;
    SetString(res, TEdit(Ctrl^.Cv_Int1).Text);
  end else if proc^.Name = '!SETTEXT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TEditProc := ENotSupported;
      exit;
    end;
    TEdit(Ctrl^.Cv_Int1).Text := GetString(Vm_Get(Params, 1));
  end else if Proc^.Name ='!SETREADONLY' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TEditProc := ENotSupported;
      exit;
    end;
    SetBoolean(res, TEdit(Ctrl^.Cv_Int1).Readonly);
  end
  else if Proc^.Name ='!GETREADONLY' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TEditProc := ENotSupported;
      exit;
    end;
    TEdit(Ctrl^.CV_Int1).Readonly := GetBoolean(VM_Get(Params, 1));
  end else if proc^.Name = '!CREATE' then begin
    Ctrl^.Cv_Int1 := TEdit.Create(nil);
    Ctrl^.Cv_Int2 := GetCV_Int2;
    TControl(Ctrl^.Cv_Int1).Tag := Integer(Self^.CV_Class);
    v := VM_Create;
    Vm_Add(v, Self, 'SELF');
    Vm_Add(v, Sender.CopyVariant(Vm_Get(Params, 1)), '');
    Sender.RunScriptProc(GetInheritedProc(proc), v);
    VM_Delete(v, 0);
    VM_Destroy(v);
    TEdit(Ctrl^.Cv_Int1).OnClick := TNotifyEvent(Proc2Method(@MyOnClick, Sender));
    TEdit(Ctrl^.Cv_Int1).OnDblClick := TNotifyEvent(Proc2Method(@MyOnDblClick, Sender));
    TEdit(Ctrl^.Cv_Int1).OnChange := TNotifyEvent(Proc2Method(@MyOnChange, Sender));
    TEdit(Ctrl^.Cv_Int1).OnKeyPress := TKeyPressEvent(Proc2Method(@MyOnKeyPress, Sender));
  end;
end;

function TMemoProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Ctrl, Self: PIfVariant;
  v: PVariableManager;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, proc^.ClassType^.Ext, 'FCONTROL', Ctrl, True)) then begin
    TMemoProc := ENotSupported; // internal error
    exit;
  end;
  TMemoProc := ENoError;
  if proc^.Name = '!GETTEXT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TMemoProc := ENotSupported;
      exit;
    end;
    SetString(res, TMemo(Ctrl^.Cv_Int1).Text);
  end else if proc^.Name = '!SETTEXT' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TMemoProc := ENotSupported;
      exit;
    end;
    TMemo(Ctrl^.Cv_Int1).Text := GetString(Vm_Get(Params, 1));
  end
  else if Proc^.Name ='!SETREADONLY' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TMemoProc := ENotSupported;
      exit;
    end;
    TMemo(Ctrl^.CV_Int1).Readonly := GetBoolean(VM_Get(Params, 1));
  end
  else if Proc^.Name ='!GETREADONLY' then begin
    if Ctrl^.Cv_Int1 = nil then begin
      TMemoProc := ENotSupported;
      exit;
    end;
    SetBoolean(res, TMemo(Ctrl^.Cv_Int1).Readonly);
  end else if proc^.Name = '!CREATE' then begin
    Ctrl^.Cv_Int1 := TMemo.Create(nil);
    Ctrl^.Cv_Int2 := GetCV_Int2;
    TControl(Ctrl^.Cv_Int1).Tag := Integer(Self^.CV_Class);
    v := VM_Create;
    Vm_Add(v, Self, 'SELF');
    Vm_Add(v, Sender.CopyVariant(Vm_Get(Params, 1)), '');
    Sender.RunScriptProc(GetInheritedProc(proc), v);
    VM_Delete(v, 0);
    VM_Destroy(v);
    TMemo(Ctrl^.Cv_Int1).OnClick := TNotifyEvent(Proc2Method(@MyOnClick, Sender));
    TMemo(Ctrl^.Cv_Int1).OnDblClick := TNotifyEvent(Proc2Method(@MyOnDblClick, Sender));
    TMemo(Ctrl^.Cv_Int1).OnChange := TNotifyEvent(Proc2Method(@MyOnChange, Sender));
    TMemo(Ctrl^.Cv_Int1).OnKeyPress := TKeyPressEvent(Proc2Method(@MyOnKeyPress, Sender));
  end;
end;

procedure RegisterStdControlsLibrary(p: TIfPasScript);
begin
  p.AddClass('TBUTTON', TButtonClass, @TButtonProc);
  p.AddClass('TEDIT', TEditClass, @TEditProc);
  p.AddClass('TLABEL', TLabelClass, @TLabelProc);
  p.AddClass('TMEMO', TMemoClass, @TMemoProc);
end;

end.

