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

unit import2_frameDir;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  ComCtrls, Dialogs, ExtCtrls, StdCtrls, ActnList,

  TBXDkPanels, TB2Item, TBX, Menus,
  AntStringList, AntJvLinkLabel, AntJvExControls, AntJvEdit, AntJvSpin,

  ProgramSettings, MovieClass, import2_frame, import2_engines, getMedia,
  AntCorelButton, ElTree;

const
  msgSourceDir    = 10;
  msgBrowseDir    = 11;
  msgScanDir      = 12;

type
  TImportFrameDir = class(TImportFrame)
    lblBrowseDepth: TLabel;
    edtBrowseDepth: TComboBox;
    chkMultiDisks: TCheckBox;
    edtDiskTag: TComboBox;
    chkInternalAVI: TCheckBox;
    lblExtVideo: TLabel;
    edtExtVideo: TEdit;
    btnDefaultExtVideo: TCorelButton;
    btnFilterFileName: TCorelButton;
    lblDiskTag: TLabel;
    lblExtractProcess: TLabel;
    cmbExtractProcess: TComboBox;
    procedure btnReloadClick(Sender: TObject);
    procedure chkMultiDisksClick(Sender: TObject);
    procedure btnDefaultExtVideoClick(Sender: TObject);
    procedure btnFilterFileNameClick(Sender: TObject);
    procedure FrameResize(Sender: TObject);
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
  ConstValues, Global, functions_tbx, functions_str, fields,
  stringfilter;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TImportFrameDir.Create(Owner: TForm; Engine: TImportEngine;
  const ImportType: string; CustomFieldsProperties: TCustomFieldsProperties;
  CommonSettings: TImportCommonSettings);
begin
  inherited;
  grpSourceFile.Caption := Messages.Strings[msgSourceDir];
  btnBrowse.Hint := Messages.Strings[msgBrowseDir];
  btnReload.Caption := Messages.Strings[msgScanDir];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.btnReloadClick(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.LoadSettings;
begin
  inherited;
  with Settings.rImport.rDir do
  begin
    chkMultiDisks.Checked := MultiDisks;
    chkMultiDisksClick(nil);
    edtDiskTag.Text := DiskTag;
    edtBrowseDepth.Text := BrowseDepth;
    cmbExtractProcess.ItemIndex := ExtractProcess;
  end;
  with Settings.rOptions.rMovieInformation do
  begin
    chkInternalAvi.Checked := ImportInternalAVI;
    edtExtVideo.Text := ImportExt;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.SaveSettings;
begin
  inherited;
  with Settings.rImport.rDir do
  begin
    MultiDisks := chkMultiDisks.Checked;
    DiskTag := edtDiskTag.Text;
    BrowseDepth := edtBrowseDepth.Text;
    ExtractProcess := cmbExtractProcess.ItemIndex;
  end;
  with Settings.rOptions.rMovieInformation do
  begin
    ImportInternalAVI := chkInternalAvi.Checked;
    ImportExt := edtExtVideo.Text;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.chkMultiDisksClick(Sender: TObject);
begin
  edtDiskTag.SelLength := 0;
  edtDiskTag.Enabled := chkMultiDisks.Checked;
  lblDiskTag.Enabled := edtDiskTag.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.btnDefaultExtVideoClick(Sender: TObject);
begin
  edtExtVideo.Text := GetExtVideo;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.btnFilterFileNameClick(Sender: TObject);
var
  PrevCursor: TCursor;
begin
  PrevCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TStringFilterWin, StringFilterWin);
    try
      StringFilterWin.DefaultStringFilter(strFilterFileName);
      StringFilterWin.LoadStringFilter(Settings.rOptions.rMovieInformation.FilterFileName);
      if StringFilterWin.Execute then
        StringFilterWin.SaveStringFilter(Settings.rOptions.rMovieInformation.FilterFileName);
    finally
      StringFilterWin.Release;
      StringFilterWin := nil;
    end;
  finally
    Screen.Cursor := PrevCursor;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportFrameDir.FrameResize(Sender: TObject);
begin
  edtDiskTag.SelLength := 0;
end;

end.

