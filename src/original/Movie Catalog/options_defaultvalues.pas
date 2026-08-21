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

unit options_defaultvalues;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, framemovie, StdCtrls, ComCtrls, ExtCtrls,

  AntCorelButton, AntAutoHintLabel, AntJvExControls, AntJvToolEdit;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TDefaultValuesWin = class(TBaseDlg)
    PanelMovie: TPanel;
    FrmMovie: TMovieFrame;
    procedure btn3Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
  end;

var
  DefaultValuesWin: TDefaultValuesWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Global, movieclass;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.btn3Click(Sender: TObject);
var
  bChecked: Boolean;
  iColorTag: Integer;
begin
  with Settings.rOptions.rMovieInformation.rDefaultMovie do
  begin
    bChecked := Values.bChecked;
    iColorTag := Values.iColorTag;
    Values.InitFields;
    Values.bChecked := bChecked;
    Values.iColorTag := iColorTag;
    FrmMovie.LoadFromObject(Values);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.LoadOptions;
begin
  with Settings.rOptions.rMovieInformation.rDefaultMovie do
  begin
    Self.Width := WindowWidth;
    Self.Height := WindowHeight;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.SaveOptions;
begin
  with Settings.rOptions.rMovieInformation.rDefaultMovie do
  begin
    WindowWidth := Self.Width;
    WindowHeight := Self.Height;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.btn2Click(Sender: TObject);
begin
  with Settings.rOptions.rMovieInformation.rDefaultMovie do
  begin
    FrmMovie.SaveToObject(Values);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.FormShow(Sender: TObject);
begin
  inherited;
  FrmMovie.EMedia.SetFocus;
  FrmMovie.LoadFromObject(Settings.rOptions.rMovieInformation.rDefaultMovie.Values);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDefaultValuesWin.Translate;
begin
  inherited;
  Translator.Translate(FrmMovie);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
