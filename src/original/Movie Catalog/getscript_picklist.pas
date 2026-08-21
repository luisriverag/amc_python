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

unit getscript_picklist;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls,

  AntCorelButton, base, AntAutoHintLabel;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPickListWin = class(TBaseDlg)
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure ListBox1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FDefaultTitle: string;
    Texts: TStringList;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure SetTitle(const Title: string);
    procedure SetDefaultTitle;
    procedure Clear;
    procedure Add(const Text: string);
    function Count: Integer;
    function Execute(const WelcomeText: string; out Selected: string; out SelectedId: Integer): Boolean;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  PickListWin: TPickListWin;

implementation

{$R *.dfm}

uses
  Global, ProgramSettings;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.SetTitle(const Title: string);
begin
  Caption := Title;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.SetDefaultTitle;
begin
  Caption := FDefaultTitle;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.Clear;
begin
  ListBox1.Clear;
  Texts.Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.Add(const Text: string);
begin
  Texts.Add(Text);
  ListBox1.Items.Add(copy(Text, 1, 128) + ' (...)');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPickListWin.Count: Integer;
begin
  Result := ListBox1.Items.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPickListWin.Execute(const WelcomeText: string; out Selected: string; out SelectedId: Integer): Boolean;
var
  idx: Integer;
begin
  Selected := '';
  SelectedId := -1;
  if Texts.Count = 0 then
  begin
    Result := False;
  end else
  if Texts.Count = 1 then
  begin
    Result := True;
    Selected := Texts.Strings[0];
    SelectedId := 0;
  end else
  begin
    btn2.Enabled := False;
    Memo1.Lines.Text := WelcomeText;
    Result := ShowModal = mrOk;
    idx := ListBox1.ItemIndex;
    if Result and (idx > -1) and (idx < Texts.Count) then
    begin
      Selected := Texts.Strings[idx];
      SelectedId := idx;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.ListBox1Click(Sender: TObject);
begin
  with ListBox1 do
    if (ItemIndex > -1) and (ItemIndex < Texts.Count) then
    begin
      Memo1.Lines.Text := Texts.Strings[ItemIndex];
      btn2.Enabled := True;
    end else
    begin
      Memo1.Lines.Text := '';
      btn2.Enabled := False;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.FormCreate(Sender: TObject);
begin
  Texts := TStringList.Create;
  inherited;
  FDefaultTitle := Caption;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.FormDestroy(Sender: TObject);
begin
  Texts.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.ListBox1DblClick(Sender: TObject);
begin
  if btn2.Enabled then
    btn2.Click;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.FormResize(Sender: TObject);
var
  h: Integer;
begin
  h := Bevel1.Top - ListBox1.Top - 10;
  ListBox1.Height := h div 2;
  Memo1.Top := ListBox1.Top + ListBox1.Height + 5;
  Memo1.Height := ListBox1.Height + (h mod 2);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.LoadOptions;
begin
  with Settings.rScripts.rPickList do
  begin
    Width := WindowWidth;
    Height := WindowHeight;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPickListWin.SaveOptions;
begin
  with Settings.rScripts.rPickList do
  begin
    WindowWidth := Width;
    WindowHeight := Height;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
