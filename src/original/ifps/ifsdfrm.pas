unit ifsdfrm;
{
  Innerfuse Pascal Script Forms Library
  For license see Innerfuse Pascal Script license file

}
{$I ifs_def.inc}
interface
uses
  ifspas, ifs_var, ifs_utl, Classes, {$IFDEF CLX}QControls, QForms,
    QGraphics{$ELSE}Controls, Forms, Graphics{$ENDIF};

procedure RegisterFormsLibrary(p: TIfPasScript);
{
This Will register:
const
  fsBold = 1;
  fsItalic = 2;
  fsUnderline = 4;
  fsStrikeOut = 8;

type
  TNotifyEvent = procedure(Sender: TObject);
  TCloseQueryEvent = procedure(Sender: TObject; Var CanClose: Boolean);
  TKeyPressEvent = procedure(Sender: TObject; var Key: Char);
  TControl = class(TObject)
  private
    FParent: TControl;
  protected
    FOnKeyPress: TKeyPressEvent;
    FOnCloseQuery: TCloseQueryEvent;
    FOnChange,
    FOnClick,
    FOnDblClick: TNotifyEvent;
    FControl: ResourcePointer;
    procedure SetEnabled(B: Boolean); virtual;
    function GetEnabled: Boolean;
    procedure SetLeft(I: Integer); virtual;
    procedure SetTop(I: Integer); virtual;
    procedure SetWidth(I: Integer); virtual;
    procedure SetHeight(I: Integer); virtual;
    function GetLeft: Integer; virtual;
    function GetTop: Integer; virtual;
    function GetWidth: Integer; virtual;
    function GetHeight: Integer; virtual;
    function GetVisible: Boolean; virtual;
    procedure SetVisible(b: Boolean); virtual;
    function GetControl: ResourcePointer;

    function GetFontName: string;
    function GetFontSize: Integer;
    function GetFontColor: Integer;
    function GetFontStyle: Byte;
    procedure SetFontName(s: string);
    procedure SetFontSize(i: Integer);
    procedure SetFontColor(i: Integer);
    procedure SetFontStyle(b: Byte);
    function GetColor: Longint;
    property SetColor(I: Longint);
  public
    Constructor Create(AParent: TControl);

    property Parent: TControl read FParent;

    procedure SetBounds(Left, Top, Width, Height: Integer);

    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Visible: Boolean read GetVisible write SetVisible;

    property FontName: string read GetFontName write SetFontName;
    property FontSize: Integer read GetFontSize write SetFontSize;
    property FontColor: Integer read GetFontColor write GetFontColor;
    property FontStyle: Byte read GetFontStyle write GetFontStyle;
    property Enabled: Boolean read GetEnabled write SetEnabled;
    property OnKeyPress: TKeyPressEvent read/write;
    property OnChange: TNotifyEvent read/write;
    property OnClick: TNotifyEvent read/write;
    property OnDblClick: TNotifyEvent read/write;
    property OnCloseQuery: TCloseQueryEvent read/write;
    property Color: Longint read GetColor write GetColor;
  end;

const
  bsNone = 0;
  bsSingle = 1;
  bsDialog = 2;
  bsSizeable = 3;

  biSystemMenu = 1;
  biMinimize = 2;
  biMaximize = 4;
type
  TForm = class(TControl)
  private
  public
    constructor Create;
    destructor Destroy; override;
    procedure Close;
    procedure Center;
    property Caption: string read/write;
    property Color: Integer read/write;
    property BorderStyle: Byte read/write;
    property BorderIcons: Byte read/write;
    procedure SetActiveControl(c: TControl);
  end;

procedure ProcessMessages;

}

function GetCV_Int2: Pointer;
function GetControl(SE: TIFPasScript; C: PCreatedClass): TControl;

type
  TMethod = record
    Proc,
      Self: Pointer;
  end;
function AddTObjectFreeProc(SE: TIFPasScript; P: TObject): TObject;
// returns P again. Use this to call the AddResource and automaticly
// free a properly override destroy method of TObject.

function Proc2Method(Proc, SelfPtr: Pointer): TMethod;
// A delphi method is a pair of two pointers, use this function to create
// a method and assign it like: Control.OnClick := TNotifyEvent(Proc2Method(@Proc, ....));
// SelfPtr is the first parameter that will be send to the method (the Self pointer in delphi).

// the following are standard methods to use. use it like proc2Method(@MyOnKeyPress, ScriptEngine).
procedure MyOnKeyPress(ScriptEngine: TIfPasScript; Sender: TControl; var Key:
  Char);
procedure MyOnClick(ScriptEngine: TIfPasScript; Sender: TControl);
procedure MyOnChange(ScriptEngine: TIfPasScript; Sender: TControl);
procedure MyOnDblClick(ScriptEngine: TIfPasScript; Sender: TControl);
procedure MyOnCloseQuery(ScriptEngine: TIfPasScript; Sender: TControl; var
  CanClose: Boolean);

implementation

function Proc2Method(Proc, SelfPtr: Pointer): TMethod;
begin
  Result.Proc := Proc;
  Result.Self := SelfPtr;
end;

const
  TFormClass =
    'class(TControl)' +
    'protected ' +
    'function GetBorderIcons: Byte;' +
    'procedure SetBorderIcons(b: Byte);' +
    'procedure SetBorderStyle(b: Byte);' +
    'function GetBorderStyle: Byte;' +
    'procedure SetColor(I: Integer);' +
    'function GetColor:Integer;' +
    'function GetCaption:string;' +
    'procedure SetCaption(s: string);' +
    'public ' +
    'constructor Create;' +
    'procedure Close;' +
    'property Color: Integer read GetColor write SetColor;' +
    'property BorderStyle: Byte read GetBorderStyle write SetBorderStyle;' +
    'property BorderIcons: Byte read GetBorderIcons write SetBorderIcons;' +
    'property Caption: string read GetCaption write SetCaption;' +
    'procedure Center;' +
    'procedure SetActiveControl(c: TControl);' +
    'end;';
  TControlClass =
    'class(TObject) private FParent: TControl;' +
    'protected FOnKeyPress: TKeyPressEvent;' +
    'FOnCloseQuery: TCloseQueryEvent;' +
    'FOnChange,FOnClick,FOnDblClick: TNotifyEvent;' +
    'FControl:ResourcePointer;' +
    'procedure SetEnabled(B: Boolean);virtual;' +
    'function GetEnabled: Boolean;virtual;' +
    'procedure SetColor(I: Longint); virtual;' +
    'function GetColor: Longint; virtual;' +
    'procedure SetLeft(I: Integer);virtual;' +
    'procedure SetTop(I: Integer);virtual;' +
    'procedure SetWidth(I: Integer);virtual;' +
    'procedure SetHeight(I: Integer);virtual;' +
    'function GetLeft: Integer; virtual;' +
    'function GetTop: Integer; virtual;' +
    'function GetWidth: Integer;virtual;' +
    'function GetHeight: Integer; virtual;' +
    'function GetVisible: Boolean; virtual;' +
    'procedure SetVisible(b: Boolean); virtual;' +
    'function GetFontName: string;' +
    'function GetFontSize: Integer;' +
    'function GetFontColor: Integer;' +
    'function GetFontStyle: Byte;' +
    'procedure SetFontName(s: string);' +
    'procedure SetFontSize(i: Integer);' +
    'procedure SetFontColor(i: Integer);' +
    'procedure SetFontStyle(b: Byte);' +
    'public ' +
    'Constructor Create(AParent: TControl);' +
    'procedure SetBounds(Left, Top, Width, Height: Integer);' +
    'property Color: Longint read GetColor write SetColor;' +
    'property Parent:TControl read FParent;' +
    'property Left: Integer read GetLeft write SetLeft;' +
    'property Top: Integer read GetTop write SetTop;' +
    'property Width: Integer read GetWidth write SetWidth;' +
    'property Height: Integer read GetHeight write SetHeight;' +
    'property Visible: Boolean read GetVisible write SetVisible;' +
    'property OnClick: TNotifyEvent read FOnClick write FOnClick;' +
    'property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;' +
    'property OnChange: TNotifyEvent read FOnChange write FOnChange;' +
    'property OnDblClick: TNotifyEvent read FOnClick write FOnClick;' +
    'property OnCloseQuery: TCloseQueryEvent read FOnCloseQuery write FOnCloseQuery;' +
    'Destructor Destroy; override; ' +
    'property FontName: string read GetFontName write SetFontName;' +
    'property FontSize: Integer read GetFontSize write SetFontSize;' +
    'property FontColor: Integer read GetFontColor write SetFontColor;' +
    'property FontStyle: Byte read GetFontStyle write SetFontStyle;' +
    'property Enabled: Boolean read GetEnabled write SetEnabled;' +
    'end;';

procedure TObjectFree(id: Pointer; Ctrl: Pointer);
begin
  TObject(ctrl).Free;
end;

function AddTObjectFreeProc(SE: TIFPasScript; P: TObject): TObject;
begin
  Se.AddResource(@TObjectFree, P);
  AddTObjectFreeProc := p;
end;

procedure MyOnKeyPress(ScriptEngine: TIfPasScript; Sender: TControl; var Key:
  Char);
var
  Vars: PVariableManager;
  E, CKey: PIfVariant;
begin
  if not GetClassVariable2(PCreatedClass(Sender.Tag),
    PCreatedClass(Sender.Tag)^.ClassType^.Ext, 'FONKEYPRESS', E, True) then
    exit;
  if not assigned(E^.Cv_Proc) then
    exit;
  CKey := CreateCajVariant(ScriptEngine.GetType('CHAR'));
  Vars := VM_Create;
  Vm_Add(Vars, CreateCajVariant(PCreatedClass(Sender.Tag)^.ClassType),
    'SELF')^.CV_Class := PCreatedClass(Sender.Tag);
  Vm_Add(Vars, ScriptEngine.CreateVarType(CKey), 'Key');
  ScriptEngine.RunScriptProc(E^.Cv_Proc, Vars);
  VM_Destroy(Vars);
  Key := CKey.Cv_Char;
  DestroyCajVariant(CKey);
end;

procedure MyOnChange(ScriptEngine: TIfPasScript; Sender: TControl);
var
  Vars: PVariableManager;
  E: PIfVariant;
begin
  if not GetClassVariable2(PCreatedClass(Sender.Tag),
    PCreatedClass(Sender.Tag)^.ClassType^.Ext, 'FONCHANGE', E, True) then
    exit;
  if not assigned(E^.Cv_Proc) then
    exit;
  Vars := VM_Create;
  Vm_Add(Vars, CreateCajVariant(PCreatedClass(Sender.Tag)^.ClassType),
    'SELF')^.CV_Class := PCreatedClass(Sender.Tag);
  ScriptEngine.RunScriptProc(E^.Cv_Proc, Vars);
  VM_Destroy(Vars);
end;

procedure MyOnClick(ScriptEngine: TIfPasScript; Sender: TControl);
var
  Vars: PVariableManager;
  E: PIfVariant;
begin
  if not GetClassVariable2(PCreatedClass(Sender.Tag),
    PCreatedClass(Sender.Tag)^.ClassType^.Ext, 'FONCLICK', E, True) then
    exit;
  if not assigned(E^.Cv_Proc) then
    exit;
  Vars := VM_Create;
  Vm_Add(Vars, CreateCajVariant(PCreatedClass(Sender.Tag)^.ClassType),
    'SELF')^.CV_Class := PCreatedClass(Sender.Tag);
  ScriptEngine.RunScriptProc(E^.Cv_Proc, Vars);
  VM_Destroy(Vars);
end;

procedure MyOnDblClick(ScriptEngine: TIfPasScript; Sender: TControl);
var
  Vars: PVariableManager;
  E: PIfVariant;
begin
  if not GetClassVariable2(PCreatedClass(Sender.Tag),
    PCreatedClass(Sender.Tag)^.ClassType^.Ext, 'FONDBLCLICK', E, True) then
    exit;
  if not assigned(E^.Cv_Proc) then
    exit;
  Vars := VM_Create;
  Vm_Add(Vars, CreateCajVariant(PCreatedClass(Sender.Tag)^.ClassType),
    'SELF')^.CV_Class := PCreatedClass(Sender.Tag);
  ScriptEngine.RunScriptProc(E^.Cv_Proc, Vars);
  VM_Destroy(Vars);
end;

procedure MyOnCloseQuery(ScriptEngine: TIfPasScript; Sender: TControl; var
  CanClose: Boolean);
var
  Vars: PVariableManager;
  E, CCanClose: PIfVariant;
begin
  if not GetClassVariable2(PCreatedClass(Sender.Tag),
    PCreatedClass(Sender.Tag)^.ClassType^.Ext, 'FONCLOSEQUERY', E, True) then
    exit;
  if not assigned(E^.Cv_Proc) then
    exit;
  CCanClose := CreateCajVariant(ScriptEngine.GetType('BOOLEAN'));
  Vars := VM_Create;
  Vm_Add(Vars, CreateCajVariant(PCreatedClass(Sender.Tag)^.ClassType),
    'SELF')^.CV_Class := PCreatedClass(Sender.Tag);
  Vm_Add(Vars, ScriptEngine.CreateVarType(CCanClose), 'CanClose');
  ScriptEngine.RunScriptProc(E^.Cv_Proc, Vars);
  VM_Destroy(Vars);
  CanClose := CCanClose^.Cv_Bool;
  DestroyCajVariant(CCanClose);
end;

procedure TControlFree(id: Pointer; Ctrl: Pointer);
var
  I: Integer;
begin
  if TControl(Ctrl) is TWinControl then
  begin
    with TControl(Ctrl) as TWinControl do
    begin
      for I := ControlCount - 1 downto 0 do
      begin
        Controls[I].Parent := nil;
      end;
    end;
  end;
  TControl(Ctrl).Free;
end;

function TFormProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure;
  Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  p, Ctrl, Self: PIfVariant;
  v: PVariableManager;
  b: byte;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, proc^.ClassType^.Ext, 'FCONTROL', Ctrl, True))
    then
  begin
    TFormProc := ENotSupported; // internal error
    exit;
  end;
  TFormProc := ENoError;
  if Proc^.Name = '!CLOSE' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    TForm(Ctrl^.Cv_Int1).Close;
  end
  else if proc^.Name = '!SETACTIVECONTROL' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    if (not GetClassVariable(Vm_Get(Params, 1), Sender.GetType('TCONTROL')^.Ext,
      'FCONTROL', p, True)) or (p^.Cv_Int1 = nil) or (p^.Cv_Int2 <> GetCV_Int2)
      then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    if not (TControl(p^.Cv_Int1) is TWinControl) then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    try
      TForm(Ctrl^.Cv_Int1).ActiveControl := p^.Cv_Int1;
    except
    end;
  end
  else if proc^.name = '!GETBORDERICONS' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    b := 0;
    if biSystemMenu in TForm(Ctrl^.Cv_Int1).BorderIcons then
      b := b or 1;
    if biMinimize in TForm(Ctrl^.Cv_Int1).BorderIcons then
      b := b or 2;
    if biMaximize in TForm(Ctrl^.Cv_Int1).BorderIcons then
      b := b or 4;
    SetInteger(Res, b);
  end
  else if proc^.name = '!SETCAPTION' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    TForm(Ctrl^.Cv_Int1).Caption := GetString(VM_Get(Params, 1));
  end
  else if proc^.name = '!GETCAPTION' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    SetString(Res, TForm(Ctrl^.Cv_Int1).Caption);
  end
  else if proc^.name = '!SETBORDERICONS' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    b := GetInteger(Vm_Get(Params, 1));
    TForm(Ctrl^.Cv_Int1).BorderIcons := [];
    if (b and 1) <> 0 then
      TForm(Ctrl^.Cv_Int1).BorderIcons := TForm(Ctrl^.Cv_Int1).BorderIcons +
        [biSystemMenu];
    if (b and 2) <> 0 then
      TForm(Ctrl^.Cv_Int1).BorderIcons := TForm(Ctrl^.Cv_Int1).BorderIcons +
        [biMinimize];
    if (b and 4) <> 0 then
      TForm(Ctrl^.Cv_Int1).BorderIcons := TForm(Ctrl^.Cv_Int1).BorderIcons +
        [biMaximize];
  end
  else if proc^.Name = '!SETBORDERSTYLE' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
{$IFDEF CLX}
    case GetInteger(Vm_Get(Params, 1)) of
      0: TForm(Ctrl^.Cv_Int1).BorderStyle := fbsNone;
      1: TForm(Ctrl^.Cv_Int1).BorderStyle := fBsSingle;
      2: TForm(Ctrl^.Cv_Int1).BorderStyle := fbsDialog;
      3: TForm(Ctrl^.Cv_Int1).BorderStyle := fbsSizeable;
    end;
{$ELSE}
    case GetInteger(Vm_Get(Params, 1)) of
      0: TForm(Ctrl^.Cv_Int1).BorderStyle := bsNone;
      1: TForm(Ctrl^.Cv_Int1).BorderStyle := BsSingle;
      2: TForm(Ctrl^.Cv_Int1).BorderStyle := bsDialog;
      3: TForm(Ctrl^.Cv_Int1).BorderStyle := bsSizeable;
    end;
{$ENDIF}
  end
  else if proc^.Name = '!GETBORDERSTYLE' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
{$IFDEF CLX}
    case TForm(Ctrl^.Cv_Int1).BorderStyle of
      fbsNone: SetInteger(res, 0);
      fBsSingle: SetInteger(res, 1);
      fbsDialog: SetInteger(res, 2);
      fbsSizeable: SetInteger(res, 3);
    end;
{$ELSE}
    case TForm(Ctrl^.Cv_Int1).BorderStyle of
      bsNone: SetInteger(res, 0);
      BsSingle: SetInteger(res, 1);
      bsDialog: SetInteger(res, 2);
      bsSizeable: SetInteger(res, 3);
    end;
{$ENDIF}
  end
  else if proc^.Name = '!SETCOLOR' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    TForm(Ctrl^.Cv_Int1).Color := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!GETCOLOR' then
  begin
    if Ctrl^.Cv_Int1 = nil then
    begin
      TFormProc := ENotSupported;
      exit;
    end;
    SetInteger(res, TForm(Ctrl^.Cv_Int1).Color);
  end
  else if proc^.Name = '!CREATE' then
  begin
    Ctrl^.Cv_Int1 := TForm.CreateNew(nil);
    Ctrl^.Cv_Int2 := GetCV_Int2;
    TControl(Ctrl^.Cv_Int1).Tag := Integer(Self^.CV_Class);
    v := VM_Create;
    Vm_Add(v, Self, 'SELF');
    Vm_Add(v, CreateCajVariant(Self^.VType), ''); // nil
    Sender.RunScriptProc(GetInheritedProc(proc), v);
    VM_Delete(v, 0);
    VM_Destroy(v);
    TForm(Ctrl^.Cv_Int1).OnCloseQuery :=
      TCloseQueryEvent(Proc2Method(@MyOnCloseQuery, Sender));
    TForm(Ctrl^.Cv_Int1).OnClick := TNotifyEvent(Proc2Method(@MyOnClick,
      Sender));
    TForm(Ctrl^.Cv_Int1).OnDblClick := TNotifyEvent(Proc2Method(@MyOnDblClick,
      Sender));
    TForm(Ctrl^.Cv_Int1).OnKeyPress := TKeyPressEvent(Proc2Method(@MyOnKeyPress,
      Sender));
  end
  else if proc^.Name = '!CENTER' then
  begin
    TForm(Ctrl^.Cv_Int1).Position := poScreenCenter;
  end;
end;

type
  TControlHack = class(TControl)
  end;

function MyProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure;
  Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  if Proc^.Name = 'PROCESSMESSAGES' then
  begin
    Application.ProcessMessages;
    MyProc := Sender.ErrorCode;
  end
  else
    myproc := EUnknownIdentifier;
end;

function GetControl(SE: TIFPasScript; C: PCreatedClass): TControl;
var
  Ctrl: PIfVariant;
begin
  if (not GetClassVariable2(c, C^.ClassType^.ext, 'FCONTROL', Ctrl, True)) or
    (Ctrl^.Cv_Int1 = nil) then
  begin
    GetControl := nil;
    exit;
  end;
  if (Ctrl^.Cv_Int1 = nil) or (Ctrl^.Cv_Int2 <> GetCV_Int2) then
    GetControl := nil
  else
    GetControl := Ctrl^.CV_Int1;
end;

function TControlProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure;
  Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  Ctrl, p, Self: PIfVariant;
  b: Byte;
begin
  Self := Vm_Get(Params, 0);
  if (not GetClassVariable(Self, PTypeRec(proc^.ClassType)^.Ext, 'FCONTROL',
    Ctrl, True)) or (Ctrl^.Cv_Int1 = nil) then
  begin
    TControlProc := ENotSupported; // internal error
    exit;
  end;
  if (Ctrl^.Cv_Int1 = nil) or (Ctrl^.Cv_Int2 <> GetCV_Int2) then
  begin
    TControlProc := ENotSupported;
    exit;
  end;
  TControlProc := ENoError;
  if proc^.Name = '!SETBOUNDS' then
  begin
    TControl(Ctrl.Cv_Int1).SetBounds(GetInteger(VM_Get(Params, 1)),
      GetInteger(VM_Get(Params, 2)), GetInteger(VM_Get(Params, 3)),
      GetInteger(VM_Get(Params, 4)));
  end
  else if Proc^.Name = '!SETCOLOR' then
  begin
    TControlHack(Ctrl.Cv_Int1).Color := GetInteger(VM_Get(Params, 1));
  end
  else if Proc^.Name = '!GETCOLOR' then
  begin
    SetInteger(Res, TControlHack(Ctrl.Cv_Int1).Color);
  end
  else if proc^.Name = '!SETFONTNAME' then
  begin
    TControlHack(Ctrl.Cv_Int1).Font.Name := GetString(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETFONTSIZE' then
  begin
    TControlHack(Ctrl.Cv_Int1).Font.size := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETFONTCOLOR' then
  begin
    TControlHack(Ctrl.Cv_Int1).Font.Color := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETFONTSTYLE' then
  begin
    b := GetInteger(Vm_Get(Params, 1));
    TControlHack(Ctrl.Cv_Int1).Font.Style := [];
    if (b and 1) <> 0 then
      TControlHack(Ctrl.Cv_Int1).Font.Style :=
        TControlHack(Ctrl.Cv_Int1).Font.Style + [fsBold];
    if (b and 2) <> 0 then
      TControlHack(Ctrl.Cv_Int1).Font.Style :=
        TControlHack(Ctrl.Cv_Int1).Font.Style + [fsitalic];
    if (b and 4) <> 0 then
      TControlHack(Ctrl.Cv_Int1).Font.Style :=
        TControlHack(Ctrl.Cv_Int1).Font.Style + [fsUnderline];
    if (b and 8) <> 0 then
      TControlHack(Ctrl.Cv_Int1).Font.Style :=
        TControlHack(Ctrl.Cv_Int1).Font.Style + [fsstrikeout];
  end
  else if proc^.Name = '!GETFONTNAME' then
  begin
    SetString(res, TControlHack(Ctrl.Cv_Int1).Font.Name);
  end
  else if proc^.Name = '!GETFONTSIZE' then
  begin
    SetInteger(res, TControlHack(Ctrl.Cv_Int1).Font.size);
  end
  else if proc^.Name = '!GETFONTCOLOR' then
  begin
    SetInteger(res, TControlHack(Ctrl.Cv_Int1).Font.Color);
  end
  else if proc^.Name = '!GETFONTSTYLE' then
  begin
    b := 0;
    if fsBold in TControlHack(Ctrl.Cv_Int1).Font.Style then
      b := b or 1;
    if fsitalic in TControlHack(Ctrl.Cv_Int1).Font.Style then
      b := b or 2;
    if fsUnderline in TControlHack(Ctrl.Cv_Int1).Font.Style then
      b := b or 4;
    if fsstrikeout in TControlHack(Ctrl.Cv_Int1).Font.Style then
      b := b or 8;
    SetInteger(res, b);
  end
  else if proc^.Name = '!SETENABLED' then
  begin
    TControl(Ctrl.Cv_Int1).Enabled := GetBoolean(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETLEFT' then
  begin
    TControl(Ctrl.Cv_Int1).Left := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETTOP' then
  begin
    TControl(Ctrl.Cv_Int1).Top := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETWIDTH' then
  begin
    TControl(Ctrl.Cv_Int1).Width := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!SETHEIGHT' then
  begin
    TControl(Ctrl.Cv_Int1).Height := GetInteger(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!GETENABLED' then
  begin
    SetBoolean(res, TControl(Ctrl.Cv_Int1).Enabled);
  end
  else if proc^.Name = '!GETLEFT' then
  begin
    SetInteger(res, TControl(Ctrl.Cv_Int1).Left);
  end
  else if proc^.Name = '!GETTOP' then
  begin
    SetInteger(res, TControl(Ctrl.Cv_Int1).Top);
  end
  else if proc^.Name = '!GETWIDTH' then
  begin
    SetInteger(res, TControl(Ctrl.Cv_Int1).Width);
  end
  else if proc^.Name = '!GETHEIGHT' then
  begin
    SetInteger(res, TControl(Ctrl.Cv_Int1).Height);
  end
  else if proc^.Name = '!GETVISIBLE' then
  begin
    SetBoolean(res, TControl(Ctrl.Cv_Int1).Visible);
  end
  else if proc^.Name = '!SETVISIBLE' then
  begin
    TControl(Ctrl.Cv_Int1).Visible := GetBoolean(Vm_Get(Params, 1));
  end
  else if proc^.Name = '!CANBEPARENT' then
  begin
    SetBoolean(res, False);
  end
  else if proc^.Name = '!GETCONTROL' then
  begin
    res^.Cv_Int1 := Ctrl^.Cv_Int1;
  end
  else if proc^.Name = '!CREATE' then
  begin
    if Vm_Get(Params, 1)^.CV_Class <> nil then
    begin
      if not (GetClassVariable(Vm_Get(Params, 1), PTypeRec(proc^.ClassType)^.Ext,
        'FCONTROL', p, True)) or not assigned(p^.Cv_Int1) then
      begin
        TControlProc := ETypeMismatch;
        exit;
      end;
      if not (TControl(p^.Cv_Int1) is TWinControl) then
      begin
        TControlProc := ENotSupported;
        exit;
      end;
    end;
    if Vm_Get(Params, 1)^.CV_Class = nil then
      TControl(Ctrl^.Cv_Int1).Parent := nil
    else
      TControl(Ctrl^.Cv_Int1).Parent := TControl(p^.Cv_Int1) as TWinControl;
    GetClassVariable(Self, proc^.ClassType^.Ext, 'FPARENT', p, True);
    p^.CV_Class := Vm_Get(Params, 1)^.CV_Class;
    Sender.AddResource(TControlFree, Ctrl^.Cv_Int1);
  end
  else if proc^.Name = '!DESTROY' then
  begin
    TControlFree(ScriptID, Ctrl^.Cv_Int1);
    Sender.RemoveResource(Ctrl^.Cv_Int1);
  end;
end;

procedure RegisterFormsLibrary(p: TIfPasScript);
begin
  p.AddVariable('fsBold', 'Integer', True)^.Cv_SInt32 := 1;
  p.AddVariable('fsItalic', 'Integer', True)^.Cv_SInt32 := 2;
  p.AddVariable('fsUnderline', 'Integer', True)^.Cv_SInt32 := 4;
  p.AddVariable('fsStrikeOut', 'Integer', True)^.Cv_SInt32 := 8;
  p.AddType('TNotifyEvent', 'procedure(Sender: TObject);');
  p.AddType('TCloseQueryEvent',
    'procedure(Sender: TObject; Var CanClose: Boolean);');
  p.AddType('TKeyPressEvent', 'procedure(Sender: TObject; var Key: Char);');
  p.AddClass('TControl', TControlClass, @TControlProc);

  p.AddFunction(@MyProc, 'procedure ProcessMessages;', nil);

  p.AddVariable('bsNone', 'Integer', True)^.Cv_SInt32 := 0;
  p.AddVariable('bsSingle', 'Integer', True)^.Cv_SInt32 := 1;
  p.AddVariable('bsDialog', 'Integer', True)^.Cv_SInt32 := 2;
  p.AddVariable('bsSizeable', 'Integer', True)^.Cv_SInt32 := 3;
  p.AddVariable('BiSystemMenu', 'Integer', True)^.Cv_SInt32 := 1;
  p.AddVariable('biMinimize', 'Integer', True)^.Cv_SInt32 := 2;
  p.AddVariable('biMaximize', 'Integer', True)^.Cv_SInt32 := 4;
  p.AddClass('TForm', TFormClass, @TFormProc);
end;

function GetCV_Int2: Pointer;
begin
  GetCV_Int2 := @RegisterFormsLibrary;
end;

end.

