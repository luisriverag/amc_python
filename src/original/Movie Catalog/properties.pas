(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2006 Antoine Potten                                       *
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

unit properties;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, shellAPI, ComCtrls,

  AntCorelButton, AntJvExControls, AntJvToolEdit, AntAutoHintLabel,

  base, movieclass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPropertiesWin = class(TBaseDlg)
    LFileName: TLabel;
    EFileName: TEdit;
    LFileSize: TLabel;
    EFileSize: TEdit;
    LFileVersion: TLabel;
    EFileVersion: TEdit;
    LHOwnerInfo: TLabel;
    LOwnerName: TLabel;
    EOwnerName: TEdit;
    LOwnerMail: TLabel;
    LOwnerSite: TLabel;
    Bevel2: TBevel;
    EDescription: TMemo;
    LDescription: TLabel;
    LHXMLHeader: TLabel;
    Bevel3: TBevel;
    EEncoding: TComboBox;
    LEncoding: TLabel;
    EOwnerMail: TAntJvComboEditXP;
    EOwnerSite: TAntJvComboEditXP;
    procedure EOwnerMailButtonClick(Sender: TObject);
    procedure EOwnerSiteButtonClick(Sender: TObject);
  private
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    function Execute(const CurrentFile: TFileName; var CurrentCatalog: TMovieList): Boolean;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  PropertiesWin: TPropertiesWin;

implementation

uses
  Global, ProgramSettings;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPropertiesWin.LoadOptions;
begin
  with Settings do
  begin
    with rProperties do
    begin
      Self.Width := WindowWidth;
      Self.Height := WindowHeight;
    end; // with rProperties
  end; // with settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPropertiesWin.SaveOptions;
begin
  with Settings do
  begin
    with rProperties do
    begin
      WindowWidth := Self.Width;
      WindowHeight := Self.Height;
    end; // with rProperties
  end; // with settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPropertiesWin.EOwnerMailButtonClick(Sender: TObject);
begin
  if EOwnerMail.Text <> '' then
    ShellExecute(0, Nil, PChar('mailto:'+EOwnerMail.Text), Nil, Nil, SW_NORMAL);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPropertiesWin.EOwnerSiteButtonClick(Sender: TObject);
begin
  if EOwnerSite.Text <> '' then
  begin
     ShellExecute(0, Nil, PChar(EOwnerSite.Text), Nil, Nil, SW_NORMAL);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPropertiesWin.Execute(const CurrentFile: TFileName; var CurrentCatalog: TMovieList): Boolean;
var
  Header: string;
  Size: Double;
begin
  EFileName.Text := CurrentFile;
  try
    Size := TMovieList.ReadHeader(CurrentFile, Header);
    EFileSize.Text := Format('%.0n', [Size]);
    EFileVersion.Text := Header;
  except
    EFileSize.Text:='N/A';
    EFileVersion.Text:='N/A';
  end;
  if CurrentCatalog <> nil then
    with CurrentCatalog.MovieProperties do
    begin
      EOwnerName.Text := strName;
      EOwnerSite.Text := strSite;
      EOwnerMail.Text := strMail;
      EDescription.Text := strDescription;
      EEncoding.Text := strEncoding;
    end
  else
  begin
    EOwnerName.Text := '';
    EOwnerSite.Text := '';
    EOwnerMail.Text := '';
    EDescription.Text := '';
    EEncoding.Text := 'iso-8859-1';
  end;
  Result := ShowModal = mrOk;
  if Result then
  begin
    if CurrentCatalog = nil then
      CurrentCatalog := TMovieList.Create;
    with CurrentCatalog.MovieProperties do
    begin
      strName := EOwnerName.Text;
      strSite := EOwnerSite.Text;
      strMail := EOwnerMail.Text;
      strDescription := EDescription.Text;
      strEncoding := EEncoding.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
