unit stdimport;
interface
uses
  ifspas, ifs_utl, ifs_var, ifpsclass;

{
  Will register files from:
    System
    Classes
    Controls
    Graphics

  Todo:
    TStream
    TBrush
    TPen
}

procedure SIRegisterTObject(CL: TIFPSClasses); {will be called DelphiTObject}
procedure SIRegisterTPersistent(Cl: TIFPSClasses); // requires DelphiTObject
procedure SIRegisterTComponent(Cl: TIFPSClasses); // requires TPersistent
procedure SIRegisterTControl(Cl: TIFPSClasses); // requires TComponent
procedure SIRegisterTWinControl(Cl: TIFPSClasses); // requires TControl
procedure SIRegisterTFont(Cl: TIFPSClasses); // requires TPersistent
procedure SIRegisterTStrings(cl: TIFPSClasses); // requires TPersistent
procedure SIRegisterTStringList(cl: TIFPSClasses); // requires TStrings
procedure SIRegisterTCanvas(cl: TIFPSClasses); // requires TPersistent
procedure SIRegisterTGraphicControl(cl: TIFPSClasses); // requires TControl

procedure SIRegister_Std(Cl: TIFPSClasses);

function RCheck(Cla: TClass; Sender: TIfPasScript; Obj: TObject): Boolean;
implementation
uses
  Classes, Controls, Graphics;
function RCheck(Cla: TClass; Sender: TIfPasScript; Obj: TObject): Boolean;
begin
  if (Obj = nil) or (not (TObject(Obj) is Cla)) then
  begin
    Sender.RunError2(Sender, ECustomError, 'Object is nil, or type differs');
    Result := True;
  end else result := false;
end;

procedure SIRegisterTObject(CL: TIFPSClasses); {will be called DelphiTObject}
begin
  with cl.AddClass(TObject, nil) do
  begin
    AddFunction(@TObject.Free, 'procedure Free');
  end;
end;

procedure SIRegisterTPersistent(Cl: TIFPSClasses);
begin
  with Cl.AddClass(TPersistent, cl.FindClass('DelphiTObject')) do
  begin
    {Nothing}
  end;
end;
function ReadTComponentOwner (Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TComponent, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject := Obj;
  Result := True;
end;

procedure SIRegisterTComponent(Cl: TIFPSClasses);
begin
  with Cl.AddClass(TComponent, cl.FindClass('TPersistent')) do
  begin
    AddFunction(@TComponent.FindComponent, 'function FindComponent(AName: string): TComponent;');
    AddFunction(@TComponent.Create, 'constructor Create(AOwner: TComponent); virtual;');
    AddPropertyHelper('Owner', 'TComponent', @ReadTComponentOwner, nil);
    AddProperty('Owner', 'TComponent');
  end;
end;

function ReadTControlAlign(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, Byte(TControl(Obj).Align));
  Result := True;
end;
function WriteTControlAlign(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  TControl(Obj).Align := TAlign(GetInteger(Src));
  Result := True;
end;
function ReadTControlClientHeight(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TControl(Obj).ClientHeight);
  Result := True;
end;
function WriteTControlClientHeight(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  TControl(Obj).ClientHeight := GetInteger(Src);
  Result := True;
end;
function ReadTControlClientWidth(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TControl(Obj).ClientWidth);
  Result := True;
end;
function WriteTControlClientWidth(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  TControl(Obj).ClientWidth := GetInteger(Src);
  Result := True;
end;

function ReadTControlShowHint(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TControl(Obj).ShowHint);
  Result := True;
end;
function WriteTControlShowHint(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  TControl(Obj).ShowHint := GetBoolean(Src);
  Result := True;
end;
function ReadTControlVisible(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TControl(Obj).Visible);
  Result := True;
end;
function WriteTControlVisible(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  TControl(Obj).Visible := GetBoolean(Src);
  Result := True;
end;

procedure SIRegisterTControl(Cl: TIFPSClasses);
begin
  Cl.AddType('TMouseEvent', 'procedure(Sender: DelphiTObject; Button: Byte; Shift: TShiftState; X, Y: Integer);');
  cl.AddType('TMouseMoveEvent', 'procedure(Sender: DelphiTObject; Shift: Byte; X, Y: Integer);');
  cl.AddType('TKeyEvent', 'procedure(Sender: DelphiTObject; var Key: Word; Shift: Byte);');
  cl.AddType('TKeyPressEvent', 'procedure(Sender: DelphiTObject; var Key: Char);');

  with Cl.AddClass(TControl, cl.FindClass('TComponent')) do
  begin
    AddFunction(@TControl.Create, 'constructor Create(AOwner: TComponent);virtual;');
    AddFunction(@TControl.BRingToFront, 'procedure BringToFront;');
    AddFunction(@TControl.Dragging, 'function Dragging: Boolean;');
    AddFunction(@TControl.HasParent, 'function HasParent: Boolean;');
    AddFunction(@TControl.Hide, 'procedure Hide;');
    AddFunction(@TControl.Invalidate, 'procedure Invalidate;virtual;');
    AddFunction(@TControl.Refresh, 'procedure refresh;');
    AddFunction(@TControl.Repaint, 'procedure Repaint;virtual;');
    AddFunction(@TControl.SendToBack, 'procedure SendToBack;');
    AddFunction(@TControl.Show, 'procedure Show;');
    AddFunction(@TControl.Update, 'procedure Update;');
    AddFunction(@TControl.SetBounds, 'procedure SetBounds(x,y,w,h: Integer);virtual;');
    AddProperty('Left', 'Integer');
    AddProperty('Top', 'Integer');
    AddProperty('Width', 'Integer');
    AddProperty('Height', 'Integer');
    AddProperty('Hint', 'String');
    AddPropertyHelper('Align', 'Byte', @ReadTControlAlign, @WriteTControlAlign);
    AddPropertyHelper('ClientHeight', 'Longint', @ReadTControlClientHeight, @WriteTControlClientHeight);
    AddPropertyHelper('ClientWidth', 'Longint', @ReadTControlClientWidth, @WriteTControlClientWidth);
    AddPropertyHelper('ShowHint', 'Boolean', @ReadTControlShowHint, @WriteTControlShowHint);
    AddPropertyHelper('Visible', 'Boolean', @ReadTControlVisible, @WriteTControlVisible);
  end;
end;
function ReadTControlParent(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TControl, Caller, Obj) then begin result := false; exit; end;
  Dest^.CV_ExternalObject:= TControl(Obj).Parent;
  Result := True;
end;
function WriteTControlParent(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  TControl(Obj).Parent := Src^.CV_ExternalObject;
  Result := True;
end;

function ReadTWinControlHandle(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TWinControl(Obj).Handle);
  Result := True;
end;

function ReadTWinControlParentWindow(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TWinControl(Obj).ParentWindow);
  Result := True;
end;

function WriteTWinControlParentWindow(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
  TWinControl(Obj).ParentWindow := GetInteger(Src);
  Result := True;
End;

function ReadTWinControlShowing(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
 SetBoolean(Dest, TWinControl(Obj).Showing);
  Result := True;
end;

function ReadTWinControlTabOrder(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TWinControl(Obj).TabOrder);
  Result := True;
end;

function WriteTWinControlTabOrder(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
  TWinControl(Obj).TabOrder := GetInteger(Src);
  Result := True;
End;

function ReadTWinControlTabStop(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
 SetBoolean(Dest, TWinControl(Obj).TabStop);
  Result := True;
end;

function WriteTWinControlTabStop(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TWinControl, Caller, Obj) then begin result := false; exit; end;
  TWinControl(Obj).TabStop := GetBoolean(Src);
  Result := True;
End;

procedure SIRegisterTWinControl(Cl: TIFPSClasses); // requires TControl
begin
  with Cl.AddClass(TWinControl, cl.FindClass('TControl')) do
  begin
    with Cl.FindClass('TControl') do
    begin
      AddPropertyHelper('Parent', 'TWinControl', @ReadTControlParent, @WriteTControlParent);
    end;
    AddFunction(@TWinControl.HandleAllocated, 'function HandleAllocated: Boolean;');
    AddFunction(@TWinControl.HandleNeeded, 'procedure HandleNeeded;');
    AddFunction(@TWinControl.EnableAlign, 'procedure EnableAlign;');
    AddFunction(@TWinControl.RemoveControl, 'procedure RemoveControl(AControl: TControl);');
    AddFunction(@TWinControl.InsertControl, 'procedure InsertControl(AControl: TControl);');
    AddFunction(@TWinControl.Realign, 'procedure Realign;');
    AddFunction(@TWinControl.ScaleBy, 'procedure ScaleBy(M, D: Integer);');
    AddFunction(@TWinControl.ScrollBy, 'procedure ScrollBy(DeltaX, DeltaY: Integer);');
    AddFunction(@TWinControl.SetFocus, 'procedure SetFocus; virtual;');
    AddPropertyHelper('Handle', 'Longint', @ReadTWinControlHandle,nil);
    AddPropertyHelper('ParentWindow', 'Longint', @ReadTWinControlParentWindow, @WriteTWinControlParentWindow);
    AddPropertyHelper('Showing', 'Boolean', @ReadTWinControlShowing, nil);
    AddPropertyHelper('TabOrder', 'Integer', @ReadTWinControlTabOrder, @WriteTWinControlTabOrder);
    AddPropertyHelper('TabStop', 'Boolean', @ReadTWinControlTabStop, @WriteTWinControlTabStop);
  end;
end;

function ReadTFontPixelsPerInch(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TFont, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TFont(Obj).PixelsPerInch);
  Result := True;
end;

function WriteTFontPixelsPerInch(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TFont, Caller, Obj) then begin result := false; exit; end;
  TFont(Obj).PixelsPerInch := GetInteger(Src);
  Result := True;
End;

function ReadTFontHandle(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TFont, Caller, Obj) then begin result := false; exit; end;
 SetInteger(Dest, TFont(Obj).Handle);
  Result := True;
end;

function WriteTFontHandle(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TFont, Caller, Obj) then begin result := false; exit; end;
  TFont(Obj).Handle := GetInteger(Src);
  Result := True;
End;

procedure SIRegisterTFont(Cl: TIFPSClasses);
begin
  with Cl.AddClass(TFont, cl.FindClass('TPersistent')) do
  begin
    AddFunction(@TFont.Create, 'constructor Create;');
    AddProperty('Handle', 'Integer');
    Addproperty('PixelsPerInch', 'Integer');
    Addproperty('Color', 'Integer');
    Addproperty('Height', 'Integer');
    Addproperty('Name', 'string');
    Addproperty('Pitch', 'Byte');
    Addproperty('Size', 'Integer');
    AddPropertyHelper('Handle', 'Integer', @ReadTFontHandle, @WriteTFontHandle);
    AddPropertyHelper('PixelsPerInch', 'Integer', @ReadTFontPixelsPerInch, @WriteTFontPixelsPerInch);
  end;
end;

function ReadTStringsCapacity(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TStrings(Obj).Capacity);
  Result := True;
end;

function WriteTStringsCapacity(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).Capacity := GetInteger(Src);
  Result := True;
End;

function ReadTStringsCount(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TStrings(Obj).Count);
  Result := True;
end;

function ReadTStringsText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TStrings(Obj).Text);
  Result := True;
end;

function WriteTStringsText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).Text := GetString(Src);
  Result := True;
End;

function ReadTStringsCommaText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TStrings(Obj).CommaText);
  Result := True;
end;

function WriteTStringsCommaText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).CommaText := GetString(Src);
  Result := True;
End;

function ReadTStringsDelimitedText(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetString(Dest, TStrings(Obj).DelimitedText);
  Result := True;
end;

function WriteTStringsDelimitedText(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).DelimitedText := GetString(Src);
  Result := True;
End;

function ReadTStringsDelimiter(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetChar(Dest, TStrings(Obj).Delimiter);
  Result := True;
end;

function WriteTStringsDelimiter(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).Delimiter := GetChar(Src);
  Result := True;
End;

function ReadTStringsQuoteChar(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  SetChar(Dest, TStrings(Obj).QuoteChar);
  Result := True;
end;

function WriteTStringsQuoteChar(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStrings, Caller, Obj) then begin result := false; exit; end;
  TStrings(Obj).QuoteChar := GetChar(Src);
  Result := True;
End;

procedure TStringsSetValue(Self: TStrings; const x1, s: string);
begin
  try
    Self.Values[x1] := s;
  except
  end;
end;

function TStringsGetValue(Self: TStrings; const x1: string): string;
begin
  try
    Result := Self.Values[x1];
  except
  end;
end;
procedure TStringsSetString(Self: TStrings; I: Integer; const s: string);
begin
  try
    Self.Strings[i] := s;
  except
  end;
end;

function TStringsGetString(Self: TStrings; I: Integer): string;
begin
  try
    Result := Self.Strings[i];
  except
  end;
end;

function TStringsGetName(Self: TStrings; I: Integer): string;
begin
  try
    Result := Self.Names[i];
  except
  end;
end;

procedure SIRegisterTStrings(cl: TIFPSClasses); // requires TPersistent
begin
  with Cl.AddClass(TStrings, cl.FindClass('TPersistent')) do
  begin
    AddFunction(@TStrings.Add, 'function Add(S: string): Integer; virtual;');
    AddFunction(@TStrings.Append, 'procedure Append(S: string);');
    AddFunction(@TStrings.AddStrings, 'procedure AddStrings(Strings: TStrings); virtual;');
    AddFunction(@TStrings.BeginUpdate, 'procedure BeginUpdate;');
    AddFunction(@TStrings.Clear, 'procedure Clear; virtual;');
    AddFunction(@TStrings.Delete, 'procedure Delete(Index: Integer); virtual;');
    AddFunction(@TStrings.EndUpdate, 'procedure EndUpdate;');
    AddFunction(@TStrings.Equals,  'function Equals(Strings: TStrings): Boolean;');
    AddFunction(@TStrings.Exchange, 'procedure Exchange(Index1, Index2: Integer); virtual;');
    AddFunction(@TStrings.IndexOf, 'function IndexOf(S: string): Integer; virtual;');
    AddFunction(@TStrings.IndexOfName, 'function IndexOfName(Name: string): Integer;');
    AddFunction(@TStrings.Insert, 'procedure Insert(Index: Integer; S: string); virtual;');
    AddFunction(@TStrings.LoadFromFile, 'procedure LoadFromFile(FileName: string); virtual;');
    AddFunction(@TStrings.LoadFromStream, 'procedure LoadFromStream(Stream: TStream); virtual;');
    AddFunction(@TStrings.Move, 'procedure Move(CurIndex, NewIndex: Integer); virtual;');
    AddFunction(@TStrings.SaveToFile, 'procedure SaveToFile(FileName: string); virtual;');
    AddFunction(@TStrings.SaveToStream, 'procedure SaveToStream(Stream: TStream); virtual;');
    AddFunction(@TStrings.SetText, 'procedure SetText(Text: PChar); virtual;');
    AddFunction(@TStringsGetName, 'function GetName(I: Integer): string;');
    AddFunction(@TStringsGetString, 'function GetString(I: Integer): string;');
    AddFunction(@TStringsSetString, 'procedure SetString(I: Integer; s: string);');
    AddFunction(@TStringsGetValue, 'function GetValue(x1: string): string;');
    AddFunction(@TStringsSetValue, 'procedure SetValue(x1: string; s: string);');
    AddPropertyHelper('Capacity', 'Integer', @ReadTStringsCapacity, @WriteTStringsCapacity);
    AddPropertyHelper('Count', 'Integer', @ReadTStringsCount, nil);
    AddPropertyHelper('Text', 'String', @ReadTStringsText, @WriteTStringsText);
    AddPropertyHelper('CommaText', 'String', @ReadTStringsCommaText, @WriteTStringsCommaText);
    AddPropertyHelper('DelimitedText', 'String', @ReadTStringsDelimitedText, @WriteTStringsDelimitedText);
    AddPropertyHelper('Delimiter', 'Char', @ReadTStringsDelimiter, @WriteTStringsDelimiter);
    AddPropertyHelper('QuoteChar', 'Char', @ReadTStringsQuoteChar, @WriteTStringsQuoteChar);
  end;
end;

function ReadTStringListSorted(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStringList, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TStringList(Obj).Sorted);
  Result := True;
end;

function WriteTStringListSorted(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStringList, Caller, Obj) then begin result := false; exit; end;
  TStringList(Obj).Sorted := GetBoolean(Src);
  Result := True;
End;

function ReadTStringListCaseSensitive(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TStringList, Caller, Obj) then begin result := false; exit; end;
  SetBoolean(Dest, TStringList(Obj).CaseSensitive);
  Result := True;
end;

function WriteTStringListCaseSensitive(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TStringList, Caller, Obj) then begin result := false; exit; end;
  TStringList(Obj).CaseSensitive := GetBoolean(Src);
  Result := True;
End;

procedure SIRegisterTStringList(cl: TIFPSClasses); // requires TStrings
begin
  with Cl.AddClass(TStringList, cl.FindClass('TStrings')) do
  begin
    AddFunction(@TStringList.Create, 'constructor Create;');
    AddFunction(@TStringList.Sort, 'procedure Sort; virtual;');
    AddFunction(@TStringList.Add, 'function Add(S: string): Integer; virtual;');
    AddFunction(@TStringList.Clear, 'procedure Clear; virtual;');
    AddFunction(@TStringList.Delete, 'procedure Delete(Index: Integer); virtual;');
    AddFunction(@TStringList.Insert, 'procedure Insert(Index: Integer; S: string); virtual;');
    AddPropertyHelper('Sorted', 'Boolean', @ReadTStringListSorted, @WriteTStringListSorted);
    AddPropertyHelper('CaseSensitive', 'Boolean', @ReadTStringListCaseSensitive, @WriteTStringListCaseSensitive);
  end;
end;

procedure TCanvasSetPixel(Self: TCanvas; X,Y,C: Integer);
begin
  Self.Pixels[x,y] := c;
end;

function TCanvasGetPixel(Self: TCanvas; X,Y: Integer): Integer;
begin
  Result := Self.Pixels[x,y];
end;

function ReadTCanvasLockCount(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCanvas, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCanvas(Obj).LockCount);
  Result := True;
end;

function ReadTCanvasHandle(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCanvas, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCanvas(Obj).Handle);
  Result := True;
end;

function WriteTCanvasHandle(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCanvas, Caller, Obj) then begin result := false; exit; end;
  TCanvas(Obj).Handle := GetInteger(Src);
  Result := true;
End;

function ReadTCanvasTextFlags(Caller: TIFPasScript; Obj: TObject; Dest: PIFVariant): Boolean;
begin
  if RCheck(TCanvas, Caller, Obj) then begin result := false; exit; end;
  SetInteger(Dest, TCanvas(Obj).TextFlags);
  Result := True;
end;

function WriteTCanvasTextFlags(Caller: TIFPasScript; Obj: TObject; Src: PIFVariant): Boolean;
begin
  if RCheck(TCanvas, Caller, Obj) then begin result := false; exit; end;
  TCanvas(Obj).TextFlags := GetInteger(Src);
  Result := true;
End;
procedure SIRegisterTCanvas(cl: TIFPSClasses); // requires TPersistent
begin
  with Cl.AddClass(TCanvas, cl.FindClass('TPersistent')) do
  begin
    AddFunction(@TCanvas.Arc, 'procedure Arc(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);');
    AddFunction(@TCanvas.Chord, 'procedure Chord(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);');
    AddFunction(@TCanvas.Draw, 'procedure Draw(X, Y: Integer; Graphic: TGraphic);');
    AddFunction(@TCanvas.Ellipse, 'procedure Ellipse(X1, Y1, X2, Y2: Integer);');
    AddFunction(@TCanvas.FloodFill, 'procedure FloodFill(X, Y: Integer; Color: TColor; FillStyle: Byte);');
    AddFunction(@TCanvas.Lineto, 'procedure LineTo(X, Y: Integer);');
    AddFunction(@TCanvas.Lock, 'procedure Lock;');
    AddFunction(@TCanvas.Moveto, 'procedure MoveTo(X, Y: Integer);');
    AddFunction(@TCanvas.Pie, 'procedure Pie(X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer);');
    AddFunction(@TCanvas.Rectangle, 'procedure Rectangle(X1, Y1, X2, Y2: Integer);');
    AddFunction(@TCanvas.Refresh, 'procedure Refresh;');
    AddFunction(@TCanvas.RoundRect, 'procedure RoundRect(X1, Y1, X2, Y2, X3, Y3: Integer);');
    AddFunction(@TCanvas.TextHeight, 'function TextHeight(Text: string): Integer;');
    AddFunction(@TCanvas.TextOut, 'procedure TextOut(X, Y: Integer; Text: string);');
    AddFunction(@TCanvas.TextWidth, 'function TextWidth(Text: string): Integer;');
    AddFunction(@TCanvas.Trylock, 'function TryLock: Boolean;');
    AddFunction(@TCanvas.Unlock, 'procedure Unlock;');
    AddPropertyHelper('Handle', 'Integer', @ReadTCanvasHandle, @WriteTCanvasHandle);
    AddPropertyHelper('LockCount', 'Integer', @ReadTCanvasLockCount, nil);
    AddPropertyHelper('TextFlags', 'Longint', @ReadTCanvasTextFlags, @WriteTCanvasTextFlags);
    AddFunction(@TCanvasSetPixel, 'procedure SetPixel(X,Y,C: Integer);');
    AddFunction(@TCanvasGetPixel, 'function GetPixel(X,Y: Integer): Integer;');
    AddProperty('Brush', 'TBrush');
    AddProperty('CopyMode', 'Byte');
    AddProperty('Font', 'TFont');
    AddProperty('Pen', 'TPen');
  end;
end;

procedure SIRegisterTGraphicControl(cl: TIFPSClasses); // requires TControl
begin
  Cl.AddClass(TGraphicControl, cl.FindClass('TControl'));
end;

procedure SIRegister_Std(Cl: TIFPSClasses);
begin
  SIRegisterTObject(CL);
  SIRegisterTPersistent(Cl);
  SIRegisterTFont(Cl);
  SIRegisterTComponent(Cl);
  SIRegisterTControl(Cl);
  SIRegisterTWinControl(Cl);
  SIRegisterTStrings(cl);
  SIRegisterTStringList(cl);
  SIRegisterTCanvas(cl);
  SIRegisterTGraphicControl(cl);
  cl.AddType('TNotifyEvent', 'procedure (Sender: DelphiTObject);');
end;

end.

