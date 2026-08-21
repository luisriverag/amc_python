(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit import2_frameCsv;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Dialogs, ExtCtrls, StdCtrls, ActnList,

  TBXDkPanels, TB2Item, TBX, Menus,
  AntStringList, AntJvLinkLabel, AntJvExControls, AntJvEdit, AntJvSpin,

  ProgramSettings, MovieClass, import2_frame, import2_engines, ElTree;

type
  TImportFrameCSV = class(TImportFrame)
    lblDelim: TLabel;
    edtDelim: TComboBox;
    lblDelimExtras: TLabel;
    edtDelimExtras: TComboBox;
    lblQuote: TLabel;
    edtQuote: TComboBox;
    chkFirstLineHeaders: TCheckBox;
    edtLinebreaks: TComboBox;
    lblLinebreaks: TLabel;
    procedure btnReloadClick(Sender: TObject);
    procedure chkFirstLineHeadersClick(Sender: TObject);
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
  ConstValues, Global, functions_tbx, functions_str, fields;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TImportFrameCSV.Create(Owner: TForm; Engine: TImportEngine;
  const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
  CommonSettings: TImportCommonSettings);
begin
  inherited;
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameCSV.btnReloadClick(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameCSV.LoadSettings;
begin
  inherited;
  with Settings.rImport.rCsv do
  begin
    chkFirstLineHeaders.Checked := FirstLineHeaders;
    chkFirstLineHeadersClick(chkFirstLineHeaders);
    edtDelim.Text := Delim;
    edtDelimExtras.Text := DelimExtras;
    edtQuote.Text := Quote;
    edtLinebreaks.Text := Linebreaks;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameCSV.SaveSettings;
begin
  inherited;
  with Settings.rImport.rCsv do
  begin
    FirstLineHeaders := chkFirstLineHeaders.Checked;
    Delim := edtDelim.Text;
    DelimExtras := edtDelimExtras.Text;
    Quote := edtQuote.Text;
    Linebreaks := edtLinebreaks.Text;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameCSV.chkFirstLineHeadersClick(Sender: TObject);
begin
  chkAutoAssign.Enabled := chkFirstLineHeaders.Checked;
//  if not chkAutoAssign.Enabled then
//    chkAutoAssign.Checked := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

