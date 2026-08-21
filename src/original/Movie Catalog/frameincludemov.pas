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

unit frameincludemov;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  MovieClass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  CountMask = '%s (%d)';

type
  TIncludemovFrame = class(TFrame)
    grp: TGroupBox;
    rbtAll: TRadioButton;
    rbtSelected: TRadioButton;
    rbtChecked: TRadioButton;
    rbtVisible: TRadioButton;
  private
    FLabels: array [mioAll..mioVisible] of string;
    function GetItemIndex: TMovieIncludeOption;
    procedure SetItemIndex(const Value: TMovieIncludeOption);
    function GetItemIndexCaption: TCaption;
  public
    property ItemIndex: TMovieIncludeOption read GetItemIndex write SetItemIndex;
    property ItemIndexCaption: TCaption read GetItemIndexCaption;
    procedure SetCount(const cAll, cSelected, cChecked, cVisible: Integer); overload;
    procedure SetCount(const AMovieList: TMovieList); overload;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
  TIncludemovFrame
-------------------------------------------------------------------------------}

function TIncludemovFrame.GetItemIndex: TMovieIncludeOption;
begin
  if rbtSelected.Checked then
    Result := mioSelected
  else
  if rbtChecked.Checked then
    Result := mioChecked
  else
  if rbtVisible.Checked then
    Result := mioVisible
  else
    Result := mioAll
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludemovFrame.SetItemIndex(const Value: TMovieIncludeOption);
begin
  case Value of
    mioAll:        rbtAll.Checked := True;
    mioSelected:   rbtSelected.Checked := True;
    mioChecked:    rbtChecked.Checked := True;
    mioVisible:    rbtVisible.Checked := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludemovFrame.SetCount(const cAll, cSelected, cChecked, cVisible: Integer);
begin
  if FLabels[mioAll] = '' then
  begin
    FLabels[mioAll] := rbtAll.Caption;
    FLabels[mioSelected] := rbtSelected.Caption;
    FLabels[mioChecked] := rbtChecked.Caption;
    FLabels[mioVisible] := rbtVisible.Caption;
  end;
  rbtAll.Caption := Format(CountMask, [FLabels[mioAll], cAll]);
  rbtSelected.Caption := Format(CountMask, [FLabels[mioSelected], cSelected]);
  rbtChecked.Caption := Format(CountMask, [FLabels[mioChecked], cChecked]);
  rbtVisible.Caption := Format(CountMask, [FLabels[mioVisible], cVisible]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludemovFrame.SetCount(const AMovieList: TMovieList);
var
  cAll, cSelected, cChecked, cVisible: Integer;
begin
  if AMovieList <> nil then
  begin
    AMovieList.Count(cAll, cSelected, cChecked, cVisible);
    SetCount(cAll, cSelected, cChecked, cVisible);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TIncludemovFrame.GetItemIndexCaption: TCaption;
begin
  Result := FLabels[ItemIndex];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
