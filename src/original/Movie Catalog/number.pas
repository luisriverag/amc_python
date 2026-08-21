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

unit number;

interface

uses
  Windows, Messages, SysUtils, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ComCtrls, ExtCtrls, Classes,

  AntCorelButton, AntAutoHintLabel, AntJvEdit,
  AntJvSpin, AntJvExControls,

  base, movieclass, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TNumberWin = class(TBaseDlg)
    LEnterNumber: TLabel;
    CBDoNotAsk: TCheckBox;
    ENumber: TAntJvSpinEdit;
    grpNotUnique: TRadioGroup;
    btnFindNum: TTBXButton;
    procedure ENumberChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure grpNotUniqueClick(Sender: TObject);
    procedure btnFindNumClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    FList: TMovieList;
    FCurrentNum: Integer;
    FAlreadyMovie: string;
  protected
  public
    procedure Translate; override;
    function Execute(const List: TMovieList; const EnableCheckbox: boolean; const CheckCheckbox: boolean; const MustShow: boolean; const CurrentNum: Integer = -1): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  NumberWin: TNumberWin;

implementation

uses
  ConstValues, Global;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TNumberwin.Execute(const List: TMovieList; const EnableCheckbox: Boolean; const CheckCheckbox: Boolean; const MustShow: Boolean; const CurrentNum: Integer = -1): TModalResult;
begin
  FList := List;
  FCurrentNum := CurrentNum;
  if CurrentNum <> -1 then
    ENumber.Value := CurrentNum
  else
    btnFindNumClick(Self);    
  CBDoNotAsk.Enabled := EnableCheckbox;
  CBDoNotAsk.Checked := CheckCheckbox;
  if MustShow then
  begin
    ENumberChange(ENumber);
    grpNotUniqueClick(grpNotUnique);
    Result := ShowModal;
  end
  else
    Result := mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.ENumberChange(Sender: TObject);
var
  ok: boolean;
begin
  if FList <> nil then
  begin
    ok := (ENumber.AsInteger = FCurrentNum) or (FList.Count(ENumber.AsInteger) <> 1);
    grpNotUnique.Enabled := not ok;
    if ok then
      grpNotUnique.Caption := ''
    else
      grpNotUnique.Caption := FAlreadyMovie;
    grpNotUnique.ItemIndex := -1;
    Btn2.Enabled := ok;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.FormShow(Sender: TObject);
begin
  ENumber.SetFocus;
  btnFindNum.Caption := '';
  btnFindNum.ButtonStyle := bsFlat;
  btnFindNum.Images := ToolbarImages;
  btnFindNum.ImageIndex := Ord(ICON_MOVIEFIND);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.btn2Click(Sender: TObject);
begin
  ENumber.Text := ENumber.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.grpNotUniqueClick(Sender: TObject);
begin
  btn2.Enabled := (not grpNotUnique.Enabled) or (grpNotUnique.ItemIndex <> -1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.Translate;
begin
  inherited;
  if grpNotUnique.Caption <> '' then
    FAlreadyMovie := grpNotUnique.Caption;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.btnFindNumClick(Sender: TObject);
begin
  if Settings.rOptions.rMovieInformation.FirstAvailable then
    ENumber.Value := FList.FirstFreeNumber
  else
    ENumber.Value := FList.MaxNumber + 1;
  if Self.Visible and ENumber.CanFocus then
    ENumber.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TNumberWin.FormActivate(Sender: TObject);
begin
  inherited;
  ENumber.SetFocus;
  ENumber.SelectAll;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
