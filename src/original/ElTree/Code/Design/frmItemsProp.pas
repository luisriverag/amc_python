
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2000, EldoS                   }
{                                                    }
{====================================================}

{$I ElPack.inc}

unit frmItemsProp;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
{$ifdef D_6_UP}
  DesignIntf, DesignEditors, DesignWindows, DsnConst
{$else}
  DsgnIntf
{$endif}
  , Buttons, ExtCtrls, ElTree, frmItemCol, Dialogs,
  ElVCLUtils;

type
  TItemsPropDlg = class(TForm)
    ItemsGB : TGroupBox;
    OpenDlg : TOpenDialog;
    SaveDlg : TSaveDialog;
    Tree : TElTree;
    NewItemBtn: TButton;
    SubitemBtn: TButton;
    DeleteBtn: TButton;
    SaveBtn: TButton;
    LoadBtn: TButton;
    EditBtn: TButton;
    OKBtn: TButton;
    CancelBtn: TButton;
    ApplyBtn: TButton;
    procedure DeleteBtnClick(Sender : TObject);
    procedure SubitemBtnClick(Sender : TObject);
    procedure TreeItemFocused(Sender : TObject);
    procedure NewItemBtnClick(Sender : TObject);
    procedure EditBtnClick(Sender : TObject);
    procedure OKBtnClick(Sender : TObject);
    procedure SaveBtnClick(Sender : TObject);
    procedure LoadBtnClick(Sender : TObject);
    procedure TreeStartDrag(Sender : TObject; var DragObject : TDragObject);
    procedure TreeDragOver(Sender, Source : TObject; X, Y : Integer;
      State : TDragState; var Accept : Boolean);
    procedure TreeDragDrop(Sender, Source : TObject; X, Y : Integer);
    procedure FormCreate(Sender : TObject);
  private
    { Private declarations }
    FDragItem : TElTreeItem;
//    procedure SetItems(value : TElTreeItems);
//    function  GetItems:TElTreeItems;
  public
    { Public declarations }
    AComp : TComponent;
    DTreeItems : TElTreeItems;
  end;

  TElTreeItemsProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes : TPropertyAttributes; override;
    function GetValue : string; override;
  end;

var
  ItemsPropDlg : TItemsPropDlg;

implementation

{$R *.DFM}

type
  TElDragObject = class(TDragControlObject)
    function GetDragCursor(Accepted : Boolean; X, Y : Integer) : TCursor; override;
  end;

function TElDragObject.GetDragCursor(Accepted : Boolean; X, Y : Integer) : TCursor;
begin
  if Control is TElTree then
  begin
    if ((Control as TElTree).GetItemAtY(Y) <> nil) or (Accepted) then
      Result := (Control as TElTree).DragCursor
    else
      Result := crNoDrop;
  end
  else
    result := inherited GetDragCursor(Accepted, X, Y);
end;

procedure TElTreeItemsProperty.Edit;
var
  Editor : TItemsPropDlg;
begin
  Editor := nil;
  try
    Editor := TItemsPropDlg.Create(Application);
    Editor.AComp := TComponent(GetComponent(0));
    Editor.DTreeItems := TCustomElTree(Editor.AComp).Items;
    Editor.Tree.Items := Editor.DTreeItems;
    Editor.ShowModal;
  finally
    Editor.Free;
  end;
end;

function TElTreeItemsProperty.GetAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TElTreeItemsProperty.GetValue;
begin
  FmtStr(Result, '(%s)', [GetPropType^.Name]);
end;

// ===========================================================================

procedure TItemsPropDlg.DeleteBtnClick(Sender : TObject);
var
  Form : TCustomForm;
begin
  if Tree.ItemFocused <> nil then Tree.Items.DeleteItem(Tree.ItemFocused);
  Form := GetOwnerForm(AComp);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TItemsPropDlg.SubitemBtnClick(Sender : TObject);
var
  TSI : TElTreeItem;
var
  Form : TCustomForm;
begin
  if Tree.ItemFocused <> nil then
  begin
    Tree.ItemFocused.Expanded := true;
    TSI := Tree.Items.AddItem(Tree.ItemFocused);
    TSI.Text := 'New Item';
    Form := GetOwnerForm(AComp);
    if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  end;
end;

procedure TItemsPropDlg.TreeItemFocused(Sender : TObject);
begin
  SubItemBtn.Enabled := Tree.ItemFocused <> nil;
  EditBtn.Enabled := Tree.ItemFocused <> nil;
  DeleteBtn.Enabled := Tree.ItemFocused <> nil;
end;

procedure TItemsPropDlg.NewItemBtnClick(Sender : TObject);
var
  TSI : TElTreeItem;
var
  Form : TCustomForm;
begin
  TSI := Tree.Items.AddItem(nil);
  TSI.Text := 'New Item';
  Form := GetOwnerForm(AComp);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TItemsPropDlg.EditBtnClick(Sender : TObject);
var
  T : TItemColDlg;
var
  Form : TCustomForm;
begin
  if Tree.ItemFocused = nil then exit;
  T := nil;
  try
    T := TItemColDlg.Create(self);
    T.Item := Tree.ItemFocused;
    T.SetData;
    if T.ShowModal = mrOk then
    begin
      T.GetData;
      Form := GetOwnerForm(AComp);
      if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
    end;
  finally
    T.Free;
  end;
end;

procedure TItemsPropDlg.OKBtnClick(Sender : TObject);
begin
  DTreeItems.Assign(Tree.Items);
end;

procedure TItemsPropDlg.SaveBtnClick(Sender : TObject);
var
  T : TFileStream;
begin
  if not SaveDlg.Execute then exit;
  T := nil;
  try
    T := TFileStream.Create(SaveDlg.FileName, fmCreate or fmShareDenyWrite);
    Tree.Items.SaveToStream(T);
  finally
    T.Free;
  end;
end;

procedure TItemsPropDlg.LoadBtnClick(Sender : TObject);
var
  T : TFileStream;
var
  Form : TCustomForm;
begin
  if not OpenDlg.Execute then exit;
  T := nil;
  try
    T := TFileStream.Create(OpenDlg.FileName, fmOpenRead or fmShareDenyWrite);
    Tree.Items.LoadFromStream(T);
    Form := GetOwnerForm(AComp);
    if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
  finally
    T.Free;
  end;
end;

procedure TItemsPropDlg.TreeStartDrag(Sender : TObject;
  var DragObject : TDragObject);
begin
  FDragItem := Tree.ItemFocused;
  DragObject := TElDragObject.Create(Tree);
end;

procedure TItemsPropDlg.TreeDragOver(Sender, Source : TObject; X,
  Y : Integer; State : TDragState; var Accept : Boolean);
var
  TSI : TElTreeItem;
begin
  Accept := false;
  if (Source <> Tree) and ((not (Source is TDragControlObject)) or (TDragControlObject(Source).Control <> Tree)) then exit;
  TSI := Tree.GetItemAtY(Y);
  if (TSI <> nil) and (not TSI.IsUnder(FDragItem)) then Accept := true;
end;

procedure TItemsPropDlg.TreeDragDrop(Sender, Source : TObject; X,
  Y : Integer);
var
  TSI : TElTreeItem;
var
  Form : TCustomForm;
begin
  TSI := Tree.GetItemAtY(Y);
  if (TSI <> nil) and (not TSI.IsUnder(FDragItem)) then FDragItem.MoveToIns(TSI.Parent, TSI.Index);
  Form := GetOwnerForm(AComp);
  if (Form <> nil) and (Form.Designer <> nil) then Form.Designer.Modified;
end;

procedure TItemsPropDlg.FormCreate(Sender : TObject);
begin
  TreeItemFocused(self);
end;

end.
