
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2000, EldoS                   }
{                                                    }
{====================================================}

{$I ElPack.inc}

unit frmSectProp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
{$ifdef D_6_UP}
  DesignIntf, DesignEditors, DesignWindows, DsnConst
{$else}
  DsgnIntf
{$endif}
  , ElHeader, StdCtrls, frmSectEdit, ExtCtrls;

type
  TElSectionsPropDlg = class(TForm)
    OpenDlg : TOpenDialog;
    SaveDlg : TSaveDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    AddBtn: TButton;
    DeleteBtn: TButton;
    EditBtn: TButton;
    UpBtn: TButton;
    DownBtn: TButton;
    LoadBtn: TButton;
    SaveBtn: TButton;
    SecList: TListBox;
    procedure LoadBtnClick(Sender : TObject);
    procedure SaveBtnClick(Sender : TObject);
    procedure EditBtnClick(Sender : TObject);
    procedure AddBtnClick(Sender : TObject);
    procedure DeleteBtnClick(Sender : TObject);
    procedure UpBtnClick(Sender : TObject);
    procedure DownBtnClick(Sender : TObject);
    procedure SecListClick(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure SecListKeyPress(Sender : TObject; var Key : Char);
  protected
    //Designer : TFormDesigner;
  public
    DSect : TElHeaderSections;
  end;

  TElSectionsProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
  end;

  TElHeaderEditor = class(TDefaultEditor)
  public
{$ifdef D_6_UP}
    procedure EditProperty(const PropertyEditor : IProperty; var Continue : Boolean); override;
{$else}
    procedure EditProperty(PropertyEditor : TPropertyEditor; var Continue, FreeEditor : Boolean); override;
{$endif}
    procedure ExecuteVerb(Index: integer); override;
    function GetVerb(Index: integer): string; override;
    function GetVerbCount: integer; override;
  end;

var
  ElSectionsPropDlg : TElSectionsPropDlg;

implementation

{$R *.DFM}

procedure TElSectionsProperty.Edit;
var
  Editor : TElSectionsPropDlg;
  j : integer;
  S: string;
begin
  Editor := nil;
  try
    Editor := TElSectionsPropDlg.Create(Application);
    Editor.DSect := TElHeaderSections(GetOrdValue);
    Editor.Caption := Format('Editing %s.Sections', [Editor.DSect.Owner.Name]);
    for j := 0 to Editor.DSect.Count - 1 do
    begin
      S := IntToStr(Editor.DSect.ItemByPos[j].Index) + ' - ';
      if Editor.DSect.ItemByPos[j].Text = '' then
        S := S + '(Untitled)'
      else
        S := S + Editor.DSect.ItemByPos[j].Text;
      Editor.SecList.Items.AddObject(S, Editor.DSect.ItemByPos[j]);
    end;  
    Editor.ShowModal;
  finally
    Editor.Free;
  end;
end;

function TElSectionsProperty.GetAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TElSectionsProperty.GetValue;
begin
  FmtStr(Result, '(%s)', [GetPropType^.Name]);
end;

procedure TElSectionsPropDlg.LoadBtnClick(Sender : TObject);
var
  j : integer;
  Form : TCustomForm;
  S: string;
begin
  if not OpenDlg.Execute then exit;
  DSect.LoadFromFile(OpenDlg.FileName);
  SecList.Items.Clear;
  for j := 0 to DSect.Count - 1 do // Iterate
  begin
    S := IntToStr(DSect.ItemByPos[j].Index) + ' - ';
    if DSect.ItemByPos[j].Text = '' then
      S := S + '(Untitled)'
    else
      S := S + DSect.ItemByPos[j].Text;
    SecList.Items.AddObject(S, DSect.ItemByPos[j]);
  end;
  Form := GetParentForm(DSect.Owner);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TElSectionsPropDlg.SaveBtnClick(Sender : TObject);
begin
  if not SaveDlg.Execute then exit;
  DSect.SaveToFile(SaveDlg.FileName);
end;

procedure TElSectionsPropDlg.EditBtnClick(Sender : TObject);
var
  SectDlg : TSectEdit;
  THS : TElHeaderSection;
  Form : TCustomForm;
  S: string;
begin
  SectDlg := nil;
  if SecList.ItemIndex = -1 then exit;
  try
    SectDlg := TSectEdit.Create(self);
    THS := TElHeaderSection(SecList.Items.Objects[SecList.ItemIndex]);
    SectDlg.Item := THS;
    SectDlg.Items := DSect;
    SectDlg.Form := TForm(GetParentForm(DSect.Owner));
    SectDlg.SetData;
    if SectDlg.ShowModal = mrOk then
    begin
      SectDlg.GetData;
      S := IntToStr(THS.Index) + ' - ';
      if THS.Text = '' then S := S + '(Untitled)' else S := S + THS.Text;
      SecList.Items[SecList.ItemIndex] := S;
      Form := GetParentForm(DSect.Owner);
      if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
    end;
  finally
    SectDlg.Free;
  end;
end;

procedure TElSectionsPropDlg.AddBtnClick(Sender : TObject);
var
  THS : TElHeaderSection;
  Form : TCustomForm;
begin
  THS := DSect.AddSection;
  THS.Text := '';
  SecList.Items.AddObject(IntToStr(THS.Index) + ' - (Untitled)', THS);
  Form := GetParentForm(DSect.Owner);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  SecListClick(Sender);
end;

procedure TElSectionsPropDlg.DeleteBtnClick(Sender : TObject);
var
  THS : TElHeaderSection;
  Form : TCustomForm;
  j : integer;
  S: string;
begin
  if SecList.ItemIndex = -1 then exit;
  THS := TElHeaderSection(SecList.Items.Objects[SecList.ItemIndex]);
  DSect.DeleteSection(THS);
  SecList.Items.Clear;
  for j := 0 to DSect.Count - 1 do // Iterate
  begin
    S := IntToStr(DSect.ItemByPos[j].Index) + ' - ';
    if DSect.ItemByPos[j].Text = '' then
      S := S + '(Untitled)'
    else
      S := S + DSect.ItemByPos[j].Text;
    SecList.Items.AddObject(S, DSect.ItemByPos[j]);
  end;
  Form := GetParentForm(DSect.Owner);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  SecListClick(Sender);
end;

procedure TElSectionsPropDlg.UpBtnClick(Sender : TObject);
var
  i : integer;
  THS : TElHeaderSection;
  Form : TCustomForm;

begin
  if SecList.ItemIndex = -1 then exit;
  i := SecList.ItemIndex;
  THS := TElHeaderSection(SecList.Items.Objects[i]);
  SecList.Items.Exchange(i, i - 1);
  DSect.MoveSection(THS, i - 1);
  SecList.ItemIndex := i - 1;
  SecListClick(Self);
  Form := GetParentForm(DSect.Owner);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TElSectionsPropDlg.DownBtnClick(Sender : TObject);
var
  i : integer;
  THS : TElHeaderSection;
  Form : TCustomForm;
begin
  if SecList.ItemIndex = -1 then exit;
  i := SecList.ItemIndex;
  THS := TElHeaderSection(SecList.Items.Objects[i]);
  SecList.Items.Exchange(i, i + 1);
  DSect.MoveSection(THS, i + 1);
  SecList.ItemIndex := i + 1;
  SecListClick(Self);
  Form := GetParentForm(DSect.Owner);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TElSectionsPropDlg.SecListClick(Sender : TObject);
var
  b : boolean;
begin
  if (SecList.ItemIndex = 0) or (SecList.ItemIndex = -1) then
    UpBtn.Enabled := false
  else
    UpBtn.Enabled := true;
  b := SecList.ItemIndex <> -1;
  if SecList.ItemIndex = SecList.Items.Count - 1 then
    DownBtn.Enabled := false
  else
    DownBtn.Enabled := true;
  DeleteBtn.Enabled := b;
  EditBtn.Enabled := b;
  //if b then Designer.SelectComponent(TElHeaderSection(SecList.Items.Objects[SecList.ItemIndex]));
end;

procedure TElSectionsPropDlg.FormCreate(Sender : TObject);
begin
  SecListClick(sender);
end;

procedure TElSectionsPropDlg.SecListKeyPress(Sender : TObject;
  var Key : Char);
begin
  SecListClick(sender);
end;

{ TElHeaderEditor }

{$ifdef D_6_UP}
    procedure TElHeaderEditor.EditProperty(const PropertyEditor : IProperty; var Continue : Boolean);
{$else}
    procedure TElHeaderEditor.EditProperty(PropertyEditor : TPropertyEditor; var Continue, FreeEditor : Boolean);
{$endif}
var
  PropName : string;
begin
  PropName := PropertyEditor.GetName;
  if (CompareText(PropName, 'SECTIONS') = 0) then
  begin
    PropertyEditor.Edit;
    Continue := False;
  end;
end;

procedure TElHeaderEditor.ExecuteVerb(Index: integer);
begin
  Edit;
end;

function TElHeaderEditor.GetVerb(Index: integer): string;
begin
  Result := 'Se&ctions Editor...';
end;

function TElHeaderEditor.GetVerbCount: integer;
begin
  Result := 1;
end;

end.
