
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2000, EldoS                   }
{                                                    }
{====================================================}

{$I ElPack.inc}

unit frmItemCol;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
{$ifdef D_6_UP}
  DesignIntf, DesignEditors, DesignWindows, DsnConst
{$else}
  DsgnIntf
{$endif}
  , Buttons, ExtCtrls, ElTree, Mask, TypInfo;

type
  TItemColDlg = class(TForm)
    Bevel1 : TBevel;
    Label1 : TLabel;
    StylesGB : TGroupBox;
    Label2 : TLabel;
    ColorsGB : TGroupBox;
    Label4 : TLabel;
    Label5 : TLabel;
    Label3 : TLabel;
    Label6 : TLabel;
    Label7 : TLabel;
    CBGroup : TGroupBox;
    Label8 : TLabel;
    Label9 : TLabel;
    Label10 : TLabel;
    Label11 : TLabel;
    OKBtn: TButton;
    CancelBtn: TButton;
    TextEdit: TEdit;
    IndexEdit: TEdit;
    StIndexEdit: TEdit;
    Index2Edit: TEdit;
    StIndex2Edit: TEdit;
    ColorCombo: TComboBox;
    BkColorCombo: TComboBox;
    CBTypeCombo: TComboBox;
    CBStateCombo: TComboBox;
    BoldCB: TCheckBox;
    ItCB: TCheckBox;
    ULCB: TCheckBox;
    StrikeCB: TCheckBox;
    CBEnabledCB: TCheckBox;
    ColorsCB: TCheckBox;
    StylesCB: TCheckBox;
    ForcedBtnsCB: TCheckBox;
    ShowChecksCB: TCheckBox;
    HiddenCB: TCheckBox;
    ColTextMemo: TMemo;
    procedure ColorsCBClick(Sender : TObject);
    procedure StylesCBClick(Sender : TObject);
    procedure FormCloseQuery(Sender : TObject; var CanClose : Boolean);
    procedure OKBtnClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure CancelBtnClick(Sender : TObject);
    procedure ShowChecksCBClick(Sender : TObject);
    procedure CBTypeComboChange(Sender : TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Item : TElTreeItem;
    ByCancel : boolean;
    procedure SetData;
    procedure GetData;
  end;

var
  ItemColDlg : TItemColDlg;

implementation

{$R *.DFM}

procedure TItemColDlg.SetData;
begin
  ColorCombo.Text := ColorToString(Item.Color);
  BkColorCombo.Text := ColorToString(Item.BkColor);
  ColorsCB.Checked := Item.ParentColors;
  ColorsGB.Enabled := not ColorsCB.Checked;
  StylesCB.Checked := Item.ParentStyle;
  StylesGB.Enabled := not StylesCB.Checked;
  TextEdit.Text := Item.Text;
  ColTextMemo.Lines.Assign(Item.ColumnText);
  ItCB.Checked := Item.Italic;
  ULCB.Checked := Item.Underlined;
  BoldCB.Checked := Item.Bold;
  StrikeCB.Checked := Item.Strikeout;
  ForcedBtnsCB.Checked := Item.ForceButtons;
  IndexEdit.Text := IntToStr(Item.ImageIndex);
  StIndexEdit.Text := IntToStr(Item.StateImageIndex);
  Index2Edit.Text := IntToStr(Item.ImageIndex2);
  StIndex2Edit.Text := IntToStr(Item.StateImageIndex2);
  CBStateCombo.ItemIndex := Integer(Item.CheckBoxState);
  CBTypeCombo.ItemIndex := Integer(Item.CheckBoxType);
  CBEnabledCB.Checked := Item.CheckBoxEnabled;
  ShowChecksCB.Checked := Item.ShowCheckBox;
  HiddenCB.Checked := Item.Hidden;
end;

procedure TItemColDlg.GetData;
var
  I, J : integer;
  S : string;
begin
  Item.ParentColors := ColorsCB.Checked;
  if not ColorsCB.Checked then
  begin
    IdentToColor(ColorCombo.Text, i);
    Item.Color := TColor(i);
    IdentToColor(BkColorCombo.Text, i);
    Item.BkColor := TColor(i);
  end;
  Item.ParentStyle := StylesCB.Checked;
  Item.Text := TextEdit.Text;
  Item.ColumnText.Assign(ColTextMemo.Lines);
  Item.Italic := ItCB.Checked;
  Item.Underlined := ULCB.Checked;
  Item.Bold := BoldCB.Checked;
  Item.Strikeout := StrikeCB.Checked;
  Item.ForceButtons := ForcedBtnsCB.Checked;
  S := IndexEdit.Text;
  val(S, I, J);
  if J = 0 then Item.ImageIndex := I;
  S := StIndexEdit.Text;
  val(S, I, J);
  if J = 0 then Item.StateImageIndex := I;

  S := Index2Edit.Text;
  val(S, I, J);
  if J = 0 then Item.ImageIndex2 := I;
  S := StIndex2Edit.Text;
  val(S, I, J);
  if J = 0 then Item.StateImageIndex2 := I;

  Item.CheckBoxState := TCheckBoxState(CBStateCombo.ItemIndex);
  Item.CheckBoxType := TElCheckBoxType(CBTypeCombo.ItemIndex);
  Item.ShowCheckBox := ShowChecksCB.Checked;
  Item.CheckBoxEnabled := CBEnabledCB.Checked;
  Item.Hidden := HiddenCB.Checked;
end;

procedure TItemColDlg.ColorsCBClick(Sender : TObject);
begin
  ColorsGB.Enabled := not ColorsCB.Checked;
  ColorCombo.Enabled := ColorsGB.Enabled;
  BkColorCombo.Enabled := ColorsGB.Enabled;
end;

procedure TItemColDlg.StylesCBClick(Sender : TObject);
begin
  StylesGB.Enabled := not StylesCB.Checked;
  ItCB.enabled := StylesGB.Enabled;
  BoldCB.enabled := StylesGB.Enabled;
  StrikeCB.enabled := StylesGB.Enabled;
  ULCB.enabled := StylesGB.Enabled;
end;

{$HINTS off}

procedure TItemColDlg.FormCloseQuery(Sender : TObject; var CanClose : Boolean);
var
  C : integer;
  s : string;
  i, j : integer;
begin
  if (ByCancel) or (ColorsCB.Checked) then
  begin
    CanClose := true;
    exit;
  end;
  CanClose := false;
  if IdentToColor(ColorCombo.Text, C) and IdentToColor(BkColorCombo.Text, C) then
    CanClose := true
  else
  begin
    MessageBox(Handle, 'Invalid color property', 'Error', mb_IconError or mb_Ok);
    ByCancel := true;
    exit;
  end;
  S := IndexEdit.Text;
  val(S, I, J);
  if J > 0 then CanClose := false;
  S := StIndexEdit.Text;
  val(S, I, J);
  if J > 0 then CanClose := false;
  if not CanClose then
  begin
    MessageBox(Handle, 'Invalid image index property', 'Error', mb_IconError or mb_Ok);
    ByCancel := true;
  end;
end;
{$HINTS on}

procedure TItemColDlg.OKBtnClick(Sender : TObject);
begin
  ByCancel := false;
end;

procedure TItemColDlg.FormCreate(Sender : TObject);
begin
  ByCancel := true;
end;

procedure TItemColDlg.CancelBtnClick(Sender : TObject);
begin
  ByCancel := true;
end;

procedure TItemColDlg.ShowChecksCBClick(Sender : TObject);
var
  i : integer;
  b : boolean;
begin
  CBGroup.Enabled := ShowChecksCB.Checked;
  b := ShowChecksCB.Checked;
  for i := 0 to CBGroup.ControlCount - 1 do
  begin
    CBGroup.Controls[i].Enabled := b;
  end;
end;

procedure TItemColDlg.CBTypeComboChange(Sender : TObject);
begin
  if (CBTypeCombo.ItemIndex <> 1) then
  begin
    if CBStateCombo.Items.Count = 3 then CBStateCombo.Items.Delete(2);
  end
  else
  begin
    if CBStateCombo.Items.Count = 2 then CBStateCombo.items.Add('Grayed');
  end;
end;

end.
