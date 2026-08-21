(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2006 Antoine Potten                                       *
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

unit import2_frameQuery;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ExtCtrls, StdCtrls, Dialogs, Menus, ActnList, ComCtrls,

  TB2Item, TBX, TBXDkPanels,
  AntJvLinkLabel, AntStringList,

  ProgramSettings, MovieClass, import2_frame, import2_engines, ElTree;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TImportFrameQuery = class(TImportFrame)
    btnQueryExec: TTBXButton;
    edtQueryWhere: TEdit;
    grpQuery: TGroupBox;
    lblQuerySelect: TLabel;
    lblQueryWhere: TLabel;
    edtQueryFrom: TComboBox;
    procedure btnReloadClick(Sender: TObject);
  private
  public
    constructor Create(Owner: TForm; Engine: TImportEngine;
      const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
      CommonSettings: TImportCommonSettings);
    procedure LoadSettings; override;
    procedure SaveSettings; override;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  ConstValues, Global, functions_tbx;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TImportFrameQuery.Create(Owner: TForm; Engine: TImportEngine;
  const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
  CommonSettings: TImportCommonSettings);
begin
  inherited;
  LoadButtonIcon(btnQueryExec, ICON_DEBUGRUN);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameQuery.LoadSettings;
begin
  inherited;
  with Settings.rImport.rQuery do
  begin
    edtQueryFrom.Text := From;
    edtQueryWhere.Text := Where;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameQuery.SaveSettings;
begin
  inherited;
  with Settings.rImport.rQuery do
  begin
    From := edtQueryFrom.Text;
    Where := edtQueryWhere.Text;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameQuery.btnReloadClick(Sender: TObject);
begin
  if FImportEngine is TImportEngineMdb then
    TImportEngineMdb(FImportEngine).ListTables(edtSourceFile.Text, edtQueryFrom.Items);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
