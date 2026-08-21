{$I ElPack.inc}
unit TreeDsgn;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
{$ifdef D_6_UP}
  DesignIntf, DesignEditors, DesignWindows, DsnConst
{$else}
  DsgnIntf
{$endif}
  , ElTree, ElHeader, frmItemsProp, frmSectProp;

type
  TElTreeEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index : Integer); override;
    function GetVerb(Index : Integer) : string; override;
    function GetVerbCount : Integer; override;
  end;

implementation

procedure TElTreeEditor.ExecuteVerb(Index : Integer);
var Form : TCustomForm;
    j    : integer;
    S    : string;

begin
  if Index = 0 then
  begin
    with TItemsPropDlg.Create(Application) do
    begin
      try
        { Set dialog's caption. }
        Caption := Component.Owner.Name + '.' + Component.Name + ' - ' + Caption;
        AComp := Component;
        DTreeItems := TCustomElTree(AComp).Items;
        Tree.Items := DTreeItems;
        if (ShowModal = mrOk) then
        begin
          Form := GetParentForm(Component as TControl);
          if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
        end;
      finally
        Free;  { Free dialog. }
      end;  { try/finally }
    end;  { with }
  end else
  if Index = 1 then
  begin
    with TElSectionsPropDlg.Create(Application) do
    begin
      DSect := TElTree(Component).HeaderSections;
      Caption := Format('Editing %s.Sections', [Component.Name]);
      for j := 0 to DSect.Count - 1 do
      begin
        S := IntToStr(DSect.ItemByPos[j].Index) + ' - ';
        if DSect.ItemByPos[j].Text = '' then
          S := S + '(Untitled)'
        else
          S := S + DSect.ItemByPos[j].Text;
        SecList.Items.AddObject(S, DSect.ItemByPos[j]);
      end;
      if ShowModal = mrOk then
      begin
        Form := GetParentForm(Component as TControl);
        if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
      end;
    end;
  end;
end;

function TElTreeEditor.GetVerb(Index : Integer) : string;
begin
  if Index = 0 then Result := 'Items Editor' else
  if Index = 1 then Result := 'Header Sections Editor';
end;

function TElTreeEditor.GetVerbCount : Integer;
begin
  Result := 2;
end;


end.

