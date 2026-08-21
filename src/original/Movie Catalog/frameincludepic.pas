(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2013-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit frameincludepic;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls,

  movieclass;

const
  CountMask = '%s (%d)';

type
  TIncludepicFrame = class(TFrame)
    grp: TGroupBox;
    rbtAll: TRadioButton;
    rbtMovie: TRadioButton;
    rbtExtras: TRadioButton;
  private
    FLabels: array [pioAll..pioExtras] of string;
    function GetItemIndex: TPictureIncludeOption;
    procedure SetItemIndex(const Value: TPictureIncludeOption);
    function GetItemIndexCaption: TCaption;
  public
    property ItemIndex: TPictureIncludeOption read GetItemIndex write SetItemIndex;
    property ItemIndexCaption: TCaption read GetItemIndexCaption;
    procedure SetCount(const cAll, cMovie, cExtras: Integer); overload;
    procedure SetCount(const AMovieList: TMovieList;
      const IncMovieOpt: TMovieIncludeOption = mioAll); overload;
  end;

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
  TIncludepicFrame
-------------------------------------------------------------------------------}

function TIncludepicFrame.GetItemIndex: TPictureIncludeOption;
begin
  if rbtMovie.Checked then
    Result := pioMovie
  else
  if rbtExtras.Checked then
    Result := pioExtras
  else
    Result := pioAll
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludepicFrame.SetItemIndex(const Value: TPictureIncludeOption);
begin
  case Value of
    pioAll:        rbtAll.Checked := True;
    pioMovie:      rbtMovie.Checked := True;
    pioExtras:     rbtExtras.Checked := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludepicFrame.SetCount(const cAll, cMovie, cExtras: Integer);
begin
  if FLabels[pioAll] = '' then
  begin
    FLabels[pioAll] := rbtAll.Caption;
    FLabels[pioMovie] := rbtMovie.Caption;
    FLabels[pioExtras] := rbtExtras.Caption;
  end;
  rbtAll.Caption := Format(CountMask, [FLabels[pioAll], cAll]);
  rbtMovie.Caption := Format(CountMask, [FLabels[pioMovie], cMovie]);
  rbtExtras.Caption := Format(CountMask, [FLabels[pioExtras], cExtras]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TIncludepicFrame.SetCount(const AMovieList: TMovieList;
  const IncMovieOpt: TMovieIncludeOption);
var
  cAll, cMovie, cExtras: Integer;
begin
  if AMovieList <> nil then
  begin
    AMovieList.CountPictures(cAll, cMovie, cExtras, IncMovieOpt);
    SetCount(cAll, cMovie, cExtras);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TIncludepicFrame.GetItemIndexCaption: TCaption;
begin
  Result := FLabels[ItemIndex];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
