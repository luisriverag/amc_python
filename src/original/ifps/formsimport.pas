unit formsimport;

interface
uses
  ifspas, ifs_utl, ifs_var, ifpsclass;

procedure SIRegisterTScrollingWinControl(Cl: TIFPSClasses); // requires TWinControl
procedure SIregisterTCustomForm(Cl: TIFPSClasses); // requires TScrollingWinControl; TFont
procedure SIRegisterTForm(Cl: TIFPSClasses); // Requires TCustomForm
procedure SIRegisterTApplication(Cl: TIFPSClasses); // Requires TComponent

procedure SIRegister_Forms(Cl: TIFPSClasses);

implementation
uses
  sysutils, classes, controls, Forms, stdimport;

procedure SIRegister_Forms(Cl: TIFPSClasses);
begin
  SIRegisterTScrollingWinControl(cl);
  SIregisterTCustomForm(Cl);
  SIRegisterTForm(Cl);
  SIRegisterTApplication(Cl);
end;

procedure SIRegisterTApplication(Cl: TIFPSClasses); // Requires TComponent
begin
  with Cl.AddClass(TApplication, cl.FindClass('TApplication')) do
  begin
    AddFunction(@TApplication.BringToFront, 'procedure BringToFront;');
    AddFunction(@TApplication.ControlDestroyed, 'procedure ControlDestroyed(Control: TControl);');
    AddFunction(@TApplication.CancelHint, 'procedure CancelHint;');
    Addfunction(@TApplication.CreateHandle, 'procedure CreateHandle;');
    AddFunction(@TApplication.HandleException, 'procedure HandleException(Sender: TObject);');
    AddFunction(@Tapplication.HandleMessage, 'procedure HandleMessage;');
    AddFunction(@TApplication.HelpCommand, 'function HelpCommand(Command: Integer; Data: Longint): Boolean;');
    AddFunction(@TApplication.HelpContext, 'function HelpContext(Context: THelpContext): Boolean;');
    Addfunction(@Tapplication.HelpJump, 'function HelpJump(const JumpID: string): Boolean;');
    AddFunction(@TApplication.HideHint, 'procedure HideHint;');
    AddFunction(@TApplication.Initialize, 'procedure Initialize;');
    AddFunction(@Tapplication.Minimize, 'procedure Minimize;');
    Addfunction(@TApplication.NormalizeAllTopMosts, 'procedure NormalizeAllTopMosts;');
    AddFunction(@TApplication.NormalizeTopMosts, 'procedure NormalizeTopMosts;');
    AddFunction(@TApplication.ProcessMessages, 'procedure ProcessMessages;');
    Addfunction(@Tapplication.Restore, 'procedure Restore;');
    AddFunction(@TApplication.RestoreTopMosts, 'procedure RestoreTopMosts;');
    AddFunction(@TApplication.Run, 'procedure Run;');
    Addfunction(@Tapplication.Terminate, 'procedure Terminate;');
    {
    property Active: Boolean read FActive;
    property AllowTesting: Boolean read FAllowTesting write FAllowTesting;
    property CurrentHelpFile: string read GetCurrentHelpFile;
    property DialogHandle: HWnd read GetDialogHandle write SetDialogHandle;
    property ExeName: string read GetExeName;
    property Handle: HWnd read FHandle write SetHandle;
    property HelpFile: string read FHelpFile write FHelpFile;
    property Hint: string read FHint write SetHint;
    property HintColor: TColor read FHintColor write SetHintColor;
    property HintHidePause: Integer read FHintHidePause write FHintHidePause;
    property HintPause: Integer read FHintPause write FHintPause;
    property HintShortCuts: Boolean read FHintShortCuts write FHintShortCuts;
    property HintShortPause: Integer read FHintShortPause write FHintShortPause;
    property Icon: TIcon read FIcon write SetIcon;
    property MainForm: TForm read FMainForm;
    property BiDiMode: TBiDiMode read FBiDiMode
      write SetBiDiMode default bdLeftToRight;
    property ShowHint: Boolean read FShowHint write SetShowHint;
    property ShowMainForm: Boolean read FShowMainForm write FShowMainForm;
    property Terminated: Boolean read FTerminate;
    property Title: string read GetTitle write SetTitle;
    property UpdateFormatSettings: Boolean read FUpdateFormatSettings
      write FUpdateFormatSettings;
    property UpdateMetricSettings: Boolean read FUpdateMetricSettings
      write FUpdateMetricSettings;
    property OnActionExecute: TActionEvent read FOnActionExecute write FOnActionExecute;
    property OnActionUpdate: TActionEvent read FOnActionUpdate write FOnActionUpdate;
    property OnActivate: TNotifyEvent read FOnActivate write FOnActivate;
    property OnDeactivate: TNotifyEvent read FOnDeactivate write FOnDeactivate;
    property OnException: TExceptionEvent read FOnException write FOnException;
    property OnIdle: TIdleEvent read FOnIdle write FOnIdle;
    property OnHelp: THelpEvent read FOnHelp write FOnHelp;
    property OnHint: TNotifyEvent read FOnHint write FOnHint;
    property OnMessage: TMessageEvent read FOnMessage write FOnMessage;
    property OnMinimize: TNotifyEvent read FOnMinimize write FOnMinimize;
    property OnRestore: TNotifyEvent read FOnRestore write FOnRestore;
    property OnShowHint: TShowHintEvent read FOnShowHint write FOnShowHint;
    property OnShortCut: TShortCutEvent read FOnShortCut write FOnShortCut;
    }
  end;
end;


procedure SIRegisterTScrollingWinControl(Cl: TIFPSClasses); // requires TWinControl
begin
  with Cl.AddClass(TScrollingWinControl, cl.FindClass('TWinControl')) do
  begin
    AddFunction(@TScrollingWinControl.DisableAutoRange, 'procedure DisableAutoRange');
    AddFunction(@TScrollingWinControl.EnableAutoRange, 'procedure EnableAutoRange');
    AddFunction(@TScrollingWinControl.ScrollInView, 'procedure ScrollInView(AControl: TControl);');
  end;
end;


function ReadTCustomFormBorderStyle(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, byte(TCustomForm(Obj).BorderStyle));
  Result := True;
end;

function WriteTCustomFormBorderStyle(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).BorderStyle := TBorderStyle(GetInteger(Src));
  Result := true;
End;

function ReadTCustomFormModalResult(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TCustomForm(Obj).ModalResult);
  Result := True;
end;


function WriteTCustomFormModalResult(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).ModalResult := GetInteger(Src);
  Result := true;
End;

function ReadTCustomFormKeyPreview(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
 SetBoolean(Dest, TCustomForm(Obj).KeyPreview);
  Result := True;
end;

function WriteTCustomFormKeyPreview(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).KeyPreview := GetBoolean(Src);
  Result := true;
End;

function ReadTCustomFormHelpFile(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
 SetString(Dest, TCustomForm(Obj).HelpFile);
  Result := True;
end;

function WriteTCustomFormHelpFile(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).HelpFile := GetString(Src);
  Result := true;
End;


function ReadTCustomFormFont(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject := TCustomForm(Obj).Font;
  Result := True;
end;

function WriteTCustomFormFont(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).Font := Src^.Cv_ExternalObject;
  Result := true;
End;


function ReadTCustomFormColor(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCustomForm(Obj).Color);
  Result := True;
end;

function WriteTCustomFormColor(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).Color := GetInteger(Src);
  Result := true;
End;

function ReadTCustomFormCaption(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
 SetString(Dest, TCustomForm(Obj).Caption);
  Result := True;
end;

function WriteTCustomFormCaption(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  TCustomForm(Obj).Caption := GetString(Src);
  Result := true;
End;

function ReadTCustomFormCanvas(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomForm, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject := TCustomForm(Obj).Canvas;
  Result := True;
end;

procedure SIregisterTCustomForm(Cl: TIFPSClasses); // requires TScrollingWinControl; TFont
begin
  with Cl.AddClass(TCustomForm, cl.FindClass('TScrollingWinControl')) do
  begin
    AddFunction(@TCustomForm.CreateNew, 'constructor CreateNew(AOwner: TComponent; Dummy: Integer); virtual;');
    Addfunction(@TCustomForm.Close, 'procedure Close;');
    AddFunction(@TcustomForm.CloseQuery, 'function CloseQuery: Boolean; virtual;');
    Addfunction(@TcustomForm.DefocusControl, 'procedure DefocusControl(Control: TWinControl; Removing: Boolean);');
    Addfunction(@TcustomForm.FocusControl, 'procedure FocusControl(Control: TWinControl);');
    AddFunction(@TcustomForm.Hide, 'procedure Hide;');
    AddFunction(@TCustomForm.Print, 'procedure Print;');
    AddFunction(@TCustomForm.Release, 'procedure Release;');
    AddFunction(@TCustomForm.SetFocusedControl, 'function SetFocusedControl(Control: TWinControl): Boolean; virtual;');
    AddFunction(@TCustomForm.Show, 'procedure Show;');
    AddFunction(@TCustomForm.ShowModal, 'function ShowModal: Integer; virtual;');
    AddPropertyHelper('BorderStyle', 'Byte', @ReadTCustomFormBorderStyle, @WriteTCustomFormBorderStyle);
    AddPropertyHelper('Canvas', 'TCanvas', @ReadTCustomFormCanvas, nil);
    AddPropertyHelper('Caption', 'String', @ReadTCustomFormCaption, @WriteTCustomFormCaption);
    AddPropertyHelper('Color', 'Integer', @ReadTCustomFormColor, @WriteTCustomFormColor);
    AddPropertyHelper('Font', 'TFont', @ReadTCustomFormFont, @WriteTCustomFormFont);
    AddPropertyHelper('HelpFile', 'String', @ReadTCustomFormHelpFile, @WriteTCustomFormHelpFile);
    AddPropertyHelper('KeyPreview', 'Boolean', @ReadTCustomFormKeyPreview, @WriteTCustomFormKeyPreview);
    AddPropertyHelper('ModalResult', 'Integer', @ReadTCustomFormModalResult, @WriteTCustomFormModalResult);
  end;
end;


procedure SIRegisterTForm(Cl: TIFPSClasses); // Requires TCustomForm
begin
  cl.AddType('TCloseEvent', 'procedure(Sender: DelphiTObject; var Action: Byte);');
  cl.AddType('TCloseQueryEvent', 'procedure(Sender: DelphiTObject; var CanClose: Boolean);');
//  cl.AddType('THelpEvent' ,'function(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;');

  with Cl.AddClass(TForm, cl.FindClass('TCustomForm')) do
  begin
    Addproperty('AutoScroll', 'Boolean');
    Addproperty('BorderWidth', 'Integer');
    Addproperty('Ctl3D', 'Boolean');
    Addproperty('Enabled', 'Boolean');
    Addproperty('ParentFont', 'Boolean');
    Addproperty('FormStyle', 'Byte');
    Addproperty('Height', 'Integer');
    Addproperty('Position', 'Byte');
    Addproperty('PrintScale', 'byte');
    Addproperty('Scaled', 'boolean');
    Addproperty('Width', 'Integer');
    AddProperty('ActiveControl', 'TWinControl');
    AddProperty('OnActivate', 'TNotifyEvent');
    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnCreate', 'TNotifyEvent');
    AddProperty('OnDblClick', 'TNotifyEvent');
    AddProperty('OnDestroy', 'TNotifyEvent');
    AddProperty('OnDeactivate', 'TNotifyEvent');
    AddProperty('OnHide', 'TNotifyEvent');
    AddProperty('OnPaint', 'TNotifyEvent');
    AddProperty('OnResize', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnShow', 'TNotifyEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
    AddProperty('OnClose', 'TCloseEvent');
    AddProperty('OnCloseQuery', 'TCloseQueryEvent');
{
    property OnHelp: THelpEvent;
    }
  end;
end;


end.
