// found on http://groups.google.com/group/borland.public.delphi.winapi/browse_thread/thread/40a666374d317648?tvc=2&q=delphi+combobox+setwindowpos&hl=en
unit ComboBoxAutoWidth;

interface

uses
  Windows, Messages, Classes, Controls, Forms, StdCtrls, Dialogs, Sysutils;

procedure SetComboxDropDownAutoWidth(AComboBox: TComboBox);

implementation

var
  cwpHandle: THandle;

  SaveRight:Integer;  //This is kind of a hack, but because there isn't a
                      //connection between the the edit part and the listbox
                      //part the assumption is being made that the CBN_DROPDOWN
                      //and WM_CTLCOLORLISTBOX are for the same combobox.

procedure SetComboxDropDownAutoWidth(AComboBox: TComboBox);
var
  i: Integer;
  MaxWidth: Integer;
  CurWidth: Integer;
  TempSize: SIZE;
  TempHDC: HDC;
  SaveFont: HFont;
begin
  MaxWidth := AComboBox.Width;//(GetSystemMetrics(SM_CXVSCROLL)*2);

  TempHDC := GetDC(0);
  try
    for i:=0 to AComboBox.Items.Count-1 do
    begin
      SaveFont := SelectObject(TempHDC, AComboBox.Font.Handle);
      Windows.GetTextExtentPoint32(TempHDC, PChar(AComboBox.Items[i]), Length(AComboBox.Items[i]), TempSize);
      SelectObject(TempHDC, SaveFont);

      if AComboBox.Items.Count>AComboBox.DropDownCount then //if scrollbar needed.
       CurWidth := TempSize.cx + (GetSystemMetrics(SM_CXVSCROLL)+8) //The 8 seems to provide a centering effect between left and right.
      else
       CurWidth := TempSize.cx+8;

      if CurWidth>MaxWidth then
       MaxWidth := CurWidth;
    end;
  finally
    ReleaseDC(0, TempHDC);
  end;

  SaveRight := AComboBox.ClientOrigin.X + AComboBox.Width;

  AComboBox.Perform(CB_SETDROPPEDWIDTH, MaxWidth, 0);
end;

procedure MoveDropDownListIfNecessary(AComboBoxListHandle: LongInt);
var
  R: TRect;
begin
  GetWindowRect(AComboBoxListHandle, R);

  if R.Right>=Screen.Width then
  begin
    MoveWindow(AComboBoxListHandle, SaveRight-(R.Right-R.Left)-1, R.Top, R.Right-R.Left, R.Bottom-R.Top, True);
  end;
end;

function HookCallbackFunction(nCode: Integer; wParam: LongInt; lParam: LongInt): Integer; stdcall;
var
  wNotifyCode: Integer;
  Control: TWinControl;
  ListHandle: LongInt;
begin
  Result := CallNextHookEx(cwpHandle,nCode,wParam,lParam);

  if (Application.Terminated) or (nCode<0) then //Don't do anything when program is closing
   Exit;

  if nCode=HC_ACTION then
  begin
    if PCWPStruct(LParam)^.message = WM_COMMAND then
    begin
      wNotifyCode := HIWORD(PCWPStruct(LParam)^.wParam);

      if wNotifyCode = CBN_DROPDOWN then
      begin
        Control := FindControl(PCWPStruct(LParam)^.lParam);

        if (Control<>nil) and (Control is TComboBox) then
          SetComboxDropDownAutoWidth(TComboBox(Control));
      end;
    end
    else if PCWPStruct(LParam)^.message = WM_CTLCOLORLISTBOX then
    begin
      ListHandle := PCWPStruct(LParam)^.lParam;
      MoveDropDownListIfNecessary(ListHandle);
    end;
  end;
end;

initialization
  cwpHandle := SetWindowsHookEx(WH_CALLWNDPROC, @HookCallbackFunction, 0, MainThreadID);
finalization
  if cwpHandle <> 0 then
   UnhookWindowsHookEx(cwpHandle);
end.
