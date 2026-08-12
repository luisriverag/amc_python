(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2011-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit importmethod;

interface

uses
  Windows, Messages, SysUtils, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, Classes,

  AntCorelButton, AntAutoHintLabel,

  base, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TImportMethodWin = class(TBaseDlg)
    grpImportMethod: TRadioGroup;
    LMsg1: TLabel;
    LMsg2: TLabel;
    chkImportExtrasNew: TCheckBox;
    chkDeleteExtras: TCheckBox;
    chkImportExtras: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure grpImportMethodClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
  protected
  public
    function Execute(KeyFieldDefined: Boolean): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ImportMethodWin: TImportMethodWin;

implementation

uses
  ConstValues, Global;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportMethodWin.FormCreate(Sender: TObject);
begin
  ToolbarImages.GetIcon(Ord(ICON_FILEIMPORT), Self.Icon);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportMethodWin.Execute(KeyFieldDefined: Boolean): TModalResult;
begin
  if KeyFieldDefined then
  begin
    grpImportMethod.Top := 56 - 13;
    chkImportExtrasNew.Top := 168 - 13;
    chkImportExtras.Top := 188 - 13;
    chkDeleteExtras.Top := 208 - 13;
    Self.ClientHeight := 266 - 13;
    grpImportMethod.ItemIndex := 1;
    grpImportMethod.Enabled := True;
    LMsg2.Visible := False;
    LMsg1.Visible := True;
  end
  else
  begin
    grpImportMethod.Top := 56;
    chkImportExtrasNew.Top := 168;
    chkImportExtras.Top := 188;
    chkDeleteExtras.Top := 208;
    Self.ClientHeight := 266;
    grpImportMethod.ItemIndex := 0;
    grpImportMethod.Enabled := False;
    LMsg1.Visible := False;
    LMsg2.Visible := True;
  end;
  grpImportMethodClick(Self);
  Result := ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportMethodWin.FormShow(Sender: TObject);
begin
  if grpImportMethod.Enabled then
    grpImportMethod.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportMethodWin.grpImportMethodClick(Sender: TObject);
begin
  btn2.Enabled := (grpImportMethod.ItemIndex <> -1);
  chkImportExtrasNew.Enabled := (grpImportMethod.ItemIndex in [0, 1, 3]);
  chkImportExtras.Enabled := (grpImportMethod.ItemIndex in [2, 3]);
  chkDeleteExtras.Enabled := (grpImportMethod.ItemIndex in [2, 3]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportMethodWin.FormActivate(Sender: TObject);
begin
  inherited;
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
