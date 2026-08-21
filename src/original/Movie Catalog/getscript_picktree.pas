(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2017 Antoine Potten, Mickaël Vanneufville                 *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   This program is free software; you can redistribute it and/or      *
 *   modify it under the terms of the GNU General Public License        *
 *   as published by the Free Software Foundation; either version 2     *
 *   of the License, or (at your option) any later version.             *
 *                                                                      *
 *   This program is distributed in the hope that it will be useful,    *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *
 *   GNU General Public License for more details.                       *
 *                                                                      *
 ************************************************************************)

unit getscript_picktree;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls,

  AntCorelButton, base, ExtCtrls, AntAutoHintLabel;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPickTreeWin = class(TBaseDlg)
    TreeView1: TTreeView;
    btnView: TCorelButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeView1Change(Sender: TObject; Node: TTreeNode);
    procedure TreeView1DblClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
  private
    FDefaultTitle: string;
    FAddresses: TStringList;
    FLastRoot: TTreeNode;
    FMoreLink: string;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure SetTitle(const Title: string);
    procedure SetDefaultTitle;
    procedure Clear;
    procedure Add(const Caption, Address: string);
    function Count: Integer;
    function CountAddresses: Integer;
    procedure SetMoreLink(const Address: string);
    function Execute(const Message: string; out Address: string; out AddressId: Integer): Boolean; overload;
    procedure Sort;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  PickTreeWin: TPickTreeWin;

implementation

uses
  Global, functions_files;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.SetTitle(const Title: string);
begin
  Caption := Title;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.SetDefaultTitle;
begin
  Caption := FDefaultTitle;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.Clear;
begin
  FLastRoot := nil;
  FAddresses.Clear;
  TreeView1.Items.Clear;
  SetMoreLink('');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.Add(const Caption, Address: string);
begin
  with TreeView1.Items do
    if Address = '' then
    begin
      FLastRoot := Add(nil, Caption);
      FLastRoot.Data := Pointer(0);
    end else
      AddChild(FLastRoot, Caption).Data := Pointer(FAddresses.Add(Address)+1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPickTreeWin.Count: Integer;
begin
  Result := TreeView1.Items.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPickTreeWin.CountAddresses: Integer;
begin
  Result := FAddresses.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPickTreeWin.Execute(const Message: string;
  out Address: string; out AddressId: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;
  Address := '';
  AddressId := -1;
  if TreeView1.Items.Count = 0 then
    if Caption = FDefaultTitle then
      MessageWin.Execute('No movie found!', mtWarning, [mbOk])
    else
      MessageWin.Execute('No value found!', mtWarning, [mbOk])
  else
  begin
    if Message = '' then
    begin
      Label1.Caption := '';
      Label1.Visible := False;
      TreeView1.Top := 4;
      TreeView1.Height := ClientHeight - TreeView1.Top - 36;
    end
    else
    begin
      Label1.Caption := Message;
      Label1.Visible := True;
      TreeView1.Top := 36;
      TreeView1.Height := ClientHeight - TreeView1.Top - 36;
    end;
    btn3.Enabled := False;
    with TreeView1.Items do
    begin
      for i := 0 to Count-1 do
        Item[i].Expand(True);
      Item[0].Selected := True;
      Item[0].MakeVisible;
    end;
    case ShowModal of
      mrOk:
        begin
          if (TreeView1.Selected <> nil) and (Integer(TreeView1.Selected.Data) > 0) then
          begin
            Address := FAddresses.Strings[Integer(TreeView1.Selected.Data)-1];
            AddressId := Integer(TreeView1.Selected.Data)-1;
          end;
          Result := True;
        end;
      mrRetry:
        begin
          Address := FMoreLink;
          AddressId := -2;
          Result := True;
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.FormCreate(Sender: TObject);
begin
  FAddresses := TStringList.Create;
  FLastRoot := nil;
  SetMoreLink('');
  inherited;
  FDefaultTitle := Caption;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.FormDestroy(Sender: TObject);
begin
  FAddresses.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.SetMoreLink(const Address: string);
begin
  FMoreLink := Address;
  btn2.Enabled := Address <> '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.TreeView1Change(Sender: TObject; Node: TTreeNode);
begin
  with TreeView1 do
    btn3.Enabled := (Selected <> nil) and (Integer(Selected.Data) > 0);
  btnView.Enabled := btn3.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.TreeView1DblClick(Sender: TObject);
begin
  if btn3.Enabled then
    btn3.Click;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.btnViewClick(Sender: TObject);
begin
  if (TreeView1.Selected <> nil) and (Integer(TreeView1.Selected.Data) > 0) then
    LaunchProg(FAddresses.Strings[Integer(TreeView1.Selected.Data)-1]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.Sort;
begin
  TreeView1.AlphaSort(True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.LoadOptions;
begin
  with Settings.rScripts.rPickTree do
  begin
    Width := WindowWidth;
    Height := WindowHeight;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickTreeWin.SaveOptions;
begin
  with Settings.rScripts.rPickTree do
  begin
    WindowWidth := Width;
    WindowHeight := Height;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
