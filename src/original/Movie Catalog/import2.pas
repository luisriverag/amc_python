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

unit import2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, ImgList,

  AntCorelButton, AntAutoHintLabel,

  base, MovieClass, AntStringList, import2_frame;

type
  TImportWin2 = class(TBaseDlg)
    PanelMain: TPanel;
    lvFormat: TListView;
    Splitter1: TSplitter;
    FormatImages: TImageList;
    Messages: TAntStringList;
    procedure btn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvFormatSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btn3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FCurrentFrame: TImportFrame;
    FCurrentList: TMovieList;
    FCurrentFile: TFileName;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    function Execute(const CurrentFileName: TFileName; CurrentList: TMovieList): Boolean;
    procedure Translate; override;
  end;

const
  msgSearchMediaFiles   = 0;
  msgMediaFilesFound    = 1;
  msgImportMediaInfo    = 2;
  msgImportFrom         = 3;
  msgBadCharsFound      = 4;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ImportWin: TImportWin2;

implementation

{$R *.dfm}

uses
  Global, functions_files, import2_engines, import2_frameCsv, import2_frameQuery, import2_frameDir;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TImportWin2.Execute(const CurrentFileName: TFileName; CurrentList: TMovieList): Boolean;
begin
  FCurrentList := CurrentList;
  FCurrentFile := CurrentFileName;
  Result := ShowModal = mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.btn1Click(Sender: TObject);
begin
  functions_files.LaunchHelp(HelpContext);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FCurrentFrame);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.lvFormatSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  c: string;
begin
  if FCurrentFrame <> nil then
  begin
    FCurrentFrame.SaveSettings;
    FreeAndNil(FCurrentFrame);
  end;
  if (Item <> nil) and (Selected) then
  begin
    c := Item.Caption;
    case Item.Index of
      0: {CSV}FCurrentFrame := TImportFrameCSV.Create(Self,
        TImportEngineCsv.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'CSV', FCurrentList.CustomFieldsProperties, Settings.rImport.rCsv.rCommon);
      1: {AMC}FCurrentFrame := TImportFrame.Create(Self,
        TImportEngineAmc.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'AMC', FCurrentList.CustomFieldsProperties, Settings.rImport.rAmc.rCommon);
      2: {MDB}FCurrentFrame := TImportFrameQuery.Create(Self,
        TImportEngineMdb.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'MDB', FCurrentList.CustomFieldsProperties, Settings.rImport.rQuery.rCommon);
      3: {Dvdpro}FCurrentFrame := TImportFrame.Create(Self,
        TImportEngineDvdpro.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'DVDPRO', FCurrentList.CustomFieldsProperties, Settings.rImport.rDvp.rCommon);
      4: {GCstar}FCurrentFrame := TImportFrame.Create(Self,
        TImportEngineGCstar.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'GCS', FCurrentList.CustomFieldsProperties, Settings.rImport.rGcs.rCommon);
      5: {ScanDir}FCurrentFrame := TImportFrameDir.Create(Self,
        TImportEngineDir.Create(c, FCurrentList.CustomFieldsProperties, Self),
        'MEDIAFILES', FCurrentList.CustomFieldsProperties, Settings.rImport.rDir.rCommon);
    end;
    if FCurrentFrame <> nil then
    begin
      FCurrentFrame.CatalogFile := FCurrentFile;
      FCurrentFrame.Align := alClient;
      FCurrentFrame.Parent := PanelMain;
      FCurrentFrame.LoadSettings;
      FCurrentFrame.Visible := True;
    end;
  end;
  btn3.Enabled := FCurrentFrame <> nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.LoadOptions;
begin
  with Settings.rImport do
    case WindowState of
      1:
        begin
          Self.WindowState := wsNormal;
          Self.Width := WindowWidth;
          Self.Height := WindowHeight;
        end;
      2:
        Self.WindowState := wsMaximized;
      else
        Self.WindowState := wsNormal;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.SaveOptions;
begin
  with Settings.rImport do
    if Self.WindowState = wsMaximized then
      WindowState := 2
    else
    begin
      WindowState := 1;
      WindowWidth := Width;
      WindowHeight := Height;
    end;
  if FCurrentFrame <> nil then
    FCurrentFrame.SaveSettings;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.btn3Click(Sender: TObject);
begin
  if FCurrentFrame <> nil then
    try
      if FCurrentFrame.ImportToList then
        btn2.ModalResult := mrOk;
    except
      on E: Exception do
        MessageWin.Execute(E.Message, mtError, [mbOk]);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  ModalResult := btn2.ModalResult;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TImportWin2.Translate;
begin
  if Assigned(FCurrentFrame) then
    Translator.Translate(FCurrentFrame);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
