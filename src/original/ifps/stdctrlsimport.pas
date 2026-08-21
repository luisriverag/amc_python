unit stdctrlsimport;

interface
uses
  ifspas, ifs_utl, ifs_var, ifpsclass;
{
   Will register files from:
     stdctrls
//     buttons


Todo:
    TRadioButton, TSpeedButton

}
procedure SIRegisterTButtonControl(cl: TIFPSClasses); // requires TWinControl
procedure SIRegisterTButton(cl: TIFPSClasses); // requires TButtonControl, TFont
procedure SIRegisterTCustomCheckBox(cl: TIFPSClasses); // requires TButtonControl
procedure SIRegisterTCheckBox(cl: TIFPSClasses); // requires TCustomCheckbox
procedure SIRegisterTCustomEdit(cl: TIFPSClasses); // requires TWinControl
procedure SIRegisterTEdit(cl: TIFPSClasses); // requires TCustomEdit
procedure SIRegisterTCustomMemo(cl: TIFPSClasses); // requires TCustomEdit
procedure SIRegisterTMemo(cl: TIFPSClasses); // requires TCustomMemo
procedure SIRegisterTCustomLabel(cl: TIFPSClasses); // required TGraphicControl
procedure SIRegisterTLabel(cl: TIFPSClasses); // required TGraphicControl

procedure SIRegister_stdctrls(cl: TIFPSClasses);
implementation
uses
  sysutils, classes, controls, stdctrls, stdimport;

function ReadTCustomEditText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TCustomEdit(Obj).Text);
  Result := True;
end;

function WriteTCustomEditText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  TCustomEdit(Obj).Text := GetString(Src);
  Result := true;
End;

function ReadTCustomEditSelText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TCustomEdit(Obj).SelText);
  Result := True;
end;

function WriteTCustomEditSelText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  TCustomEdit(Obj).SelText := GetString(Src);
  Result := true;
End;

function ReadTCustomEditSelStart(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCustomEdit(Obj).SelStart);
  Result := True;
end;

function WriteTCustomEditSelStart(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  TCustomEdit(Obj).SelStart := GetInteger(Src);
  Result := true;
End;

function ReadTCustomEditSelLength(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCustomEdit(Obj).SelLength);
  Result := True;
end;

function WriteTCustomEditSelLength(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  TCustomEdit(Obj).SelLength := GetInteger(Src);
  Result := true;
End;

function ReadTCustomEditCanUndo(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TCustomEdit(Obj).CanUndo);
  Result := True;
end;


function ReadTCustomEditModified(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TCustomEdit(Obj).Modified);
  Result := True;
end;

function WriteTCustomEditModified(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCustomEdit, Caller, Obj) then begin result := false; exit; end;
  TCustomEdit(Obj).Modified := GetBoolean(Src);
  Result := true;
End;
procedure SIRegisterTCustomEdit(cl: TIFPSClasses); // requires TWinControl
begin
  with cl.AddClass(TCustomEdit, cl.FindClass('TWinControl')) do
  begin
    AddFunction(@TCustomEdit.Clear, 'procedure Clear; virtual;');
    AddFunction(@TCustomEdit.ClearSelection, 'procedure ClearSelection;');
    AddFunction(@TCustomEdit.CopyToClipboard, 'procedure CopyToClipboard;');
    AddFunction(@TCustomEdit.CutToClipboard, 'procedure CutToClipboard;');
    AddFunction(@TCustomEdit.PasteFromClipboard, 'procedure PasteFromClipboard;');
    AddFunction(@TCustomEdit.Undo, 'procedure Undo;');
    AddFunction(@TCustomEdit.ClearUndo, 'procedure ClearUndo;');
    AddFunction(@TCustomEdit.SelectAll, 'procedure SelectAll;');
    AddPropertyHelper('CanUndo', 'Boolean', @ReadTCustomEditCanUndo, nil);
    AddPropertyHelper('Modified', 'Boolean', @ReadTCustomEditModified, @WriteTCustomEditModified);
    AddPropertyHelper('SelLength', 'Integer', @ReadTCustomEditSelLength, @WriteTCustomEditSelLength);
    AddPropertyHelper('SelStart', 'Integer', @ReadTCustomEditSelStart, @WriteTCustomEditSelStart);
    AddPropertyHelper('SelText', 'String', @ReadTCustomEditSelText, @WriteTCustomEditSelText);
    AddPropertyHelper('Text', 'String', @ReadTCustomEditText, @WriteTCustomEditText);
  end;
end;

procedure SIRegisterTEdit(cl: TIFPSClasses); // requires TCustomEdit
begin
  with cl.AddClass(TEdit, cl.FindClass('TCustomEdit')) do
  begin
    AddProperty('AutoSelect', 'Boolean');
    AddProperty('AutoSize', 'Boolean');
    AddProperty('BorderStyle', 'Byte');
    AddProperty('CharCase', 'Byte');
    AddProperty('Color', 'Integer');
    AddProperty('Ctl3D', 'boolean');
    AddProperty('DragCursor', 'Integer');
    AddProperty('Enabled', 'Boolean');
    AddProperty('Font', 'TFont');
    AddProperty('HideSelection', 'Boolean');
    AddProperty('MaxLength', 'Integer');
    AddProperty('OEMConvert', 'Boolean');
    AddProperty('ParentColor', 'Boolean');
    AddProperty('ParentCtl3D', 'Boolean');
    AddProperty('ParentFont', 'Boolean');
    AddProperty('ParentShowHint', 'Boolean');
    AddProperty('PasswordChar', 'char');
    AddProperty('ReadOnly', 'Boolean');
    AddProperty('ShowHint', 'boolean');
    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnDblClick', 'TNotifyEvent');
    AddProperty('OnEnter', 'TNotifyEvent');
    AddProperty('OnExit', 'TNotifyEvent');
    AddProperty('OnChange', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
  end;
end;


function ReadTCustomMemoLines(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomMemo, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject := TCustomMemo(Obj).Lines;
  Result := True;
end;

procedure SIRegisterTCustomMemo(cl: TIFPSClasses); // requires TCustomEdit
begin
  with cl.AddClass(TCustomMemo, cl.FindClass('TCustomEdit')) do
  begin
    AddPropertyHelper('Lines', 'TStrings', @ReadTCustomMemoLines, nil);
  end;
end;
procedure SIRegisterTMemo(cl: TIFPSClasses); // requires TCustomMemo
begin
  with cl.AddClass(TMemo, cl.FindClass('TCustomMemo')) do
  begin
    AddProperty('Alignment', 'Byte');
    AddProperty('ScrollBars', 'Byte');
    AddProperty('WantReturns', 'Boolean');
    AddProperty('WantTabs', 'Boolean');
    AddProperty('WordWrap', 'Boolean');
    AddProperty('Align', 'Byte');
    AddProperty('BorderStyle', 'byte');
    AddProperty('Color', 'Integer');
    AddProperty('Ctl3D', 'boolean');
    AddProperty('DragCursor', 'integer');
    AddProperty('Enabled', 'boolean');
    AddProperty('Font', 'TFont');
    AddProperty('HideSelection', 'Boolean');
    AddProperty('MaxLength', 'integer');
    AddProperty('OEMConvert', 'Boolean');
    AddProperty('ParentColor', 'boolean');
    AddProperty('ParentCtl3D', 'Boolean');
    AddProperty('ParentFont', 'Boolean');
    AddProperty('ParentShowHint', 'Boolean');
    AddProperty('ReadOnly', 'Boolean');

    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnDblClick', 'TNotifyEvent');
    AddProperty('OnEnter', 'TNotifyEvent');
    AddProperty('OnExit', 'TNotifyEvent');
    AddProperty('OnChange', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
  end;
end;
procedure SIRegisterTCustomCheckBox(cl: TIFPSClasses); // requires TButtonControl
begin
  cl.AddClass(TCustomCheckBox, cl.FindClass('TButtonControl'));
end;
procedure SIRegisterTCheckBox(cl: TIFPSClasses); // requires TCustomCheckbox
begin
  with cl.AddClass(TCheckBox, cl.FindClass('TCustomCheckBox')) do
  begin
    AddProperty('Alignment', 'Byte');
    AddProperty('AllowGrayed', 'Boolean');
    AddProperty('State', 'Byte');
    AddProperty('Caption', 'string');
    AddProperty('Checked', 'Boolean');
    AddProperty('Color', 'Integer');
    AddProperty('Ctl3D', 'Boolean');
    AddProperty('DragCursor', 'Integer');
    AddProperty('Enabled', 'Boolean');
    AddProperty('Font', 'TFont');
    AddProperty('ParentColor', 'Boolean');
    AddProperty('ParentCtl3D', 'Boolean');
    AddProperty('ParentFont', 'Boolean');
    AddProperty('ParentShowHint', 'Boolean');

    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnEnter', 'TNotifyEvent');
    AddProperty('OnExit', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
  end;
end;

procedure SIRegisterTButtonControl(cl: TIFPSClasses); // requires TWinControl
begin
  Cl.AddClass(TButtonControl, cl.FindClass('TWinControl'));
end;

procedure SIRegisterTButton(cl: TIFPSClasses); // requires TButtonControl, TFont
begin
  with Cl.AddClass(TButton, cl.FindClass('TButtonControl')) do
  begin
    AddProperty('Cancel', 'Boolean');
    AddProperty('Caption', 'String');
    AddProperty('Default', 'Boolean');
    AddProperty('DragCursor', 'SmallInt');
    AddProperty('DragKind', 'byte');
    AddProperty('DragMode', 'byte');
    AddProperty('Enabled', 'Boolean');
    AddProperty('Font', 'TFont');
    AddProperty('ModalResult', 'Integer');
    AddProperty('ParentFont', 'Boolean');
    AddProperty('ParentShowHint', 'Boolean');
    AddProperty('TabOrder', 'Integer');
    AddProperty('TabStop', 'Boolean');
    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnEnter', 'TNotifyEvent');
    AddProperty('OnExit', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
  end;
end;

function ReadTCustomLabelCanvas(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCustomLabel, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject := TCustomLabel(Obj).Canvas;
  Result := True;
end;

procedure SIRegisterTCustomLabel(cl: TIFPSClasses); // required TGraphicControl
begin
  with Cl.AddClass(TCustomLabel, cl.FindClass('TGraphicControl')) do
  begin
    AddPropertyHelper('Canvas', 'TCanvas', @ReadTCustomLabelCanvas, nil);
  end;
end;

procedure SIRegisterTLabel(cl: TIFPSClasses); // required TGraphicControl
begin
  with Cl.AddClass(TLabel, cl.FindClass('TCustomLabel')) do
  begin
    AddProperty('Alignment', 'byte');
    AddProperty('Align', 'Byte');
    AddProperty('AutoSize' ,'Boolean');
    AddProperty('Caption', 'String');
    AddProperty('Color', 'Integer');
    AddProperty('Enabled', 'Boolean');
    AddProperty('FocusControl', 'TWinControl');
    AddProperty('Font', 'TFont');
    AddProperty('ParentColor', 'Boolean');
    AddProperty('ParentFont', 'Boolean');
    AddProperty('ParentShowHint', 'ParentShowHint');
    AddProperty('PopupMenu', 'TPopupMenu');
    AddProperty('ShowAccelChar', 'Boolean');
    AddProperty('ShowHint', 'Boolean');
    AddProperty('Transparent', 'Boolean');
    AddProperty('Layout', 'Byte');
    AddProperty('WordWrap', 'Boolean');
    AddProperty('OnClick', 'TNotifyEvent');
    AddProperty('OnMouseDown', 'TMouseEvent');
    AddProperty('OnMouseMove', 'TMouseMoveEvent');
    AddProperty('OnMouseUp', 'TMouseEvent');
    AddProperty('OnKeyDown', 'TKeyEvent');
    AddProperty('OnKeyPress', 'TKeyPressEvent');
    AddProperty('OnKeyUp', 'TKeyEvent');
  end;
end;

procedure SIRegister_stdctrls(cl: TIFPSClasses);
begin
  SIRegisterTButtonControl(cl);
  SIRegisterTButton(cl);
  SIRegisterTCustomCheckBox(cl);
  SIRegisterTCheckBox(cl);
  SIRegisterTCustomEdit(cl);
  SIRegisterTEdit(cl);
  SIRegisterTCustomMemo(cl);
  SIRegisterTMemo(cl);
  SIRegisterTCustomLabel(cl);
  SIRegisterTLabel(cl);
end;

end.
