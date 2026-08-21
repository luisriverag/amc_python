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

unit extrasrenumber;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ComCtrls, ExtCtrls,

  AntStringList, AntCorelButton,

  MovieClass, framesortbyextras, AntAutoHintLabel, framesortby,
  frameincludemov;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TExtrasRenumberWin = class(TBaseDlg)
    Messages: TAntStringList;
    SortBy: TExtrasSortByFrame;
    chkAllMovies: TCheckBox;
    FrmIncludemov: TIncludemovFrame;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure SortByBtnAdvSortClick(Sender: TObject);
    procedure chkAllMoviesClick(Sender: TObject);
  private
    FMovie: TMovie;
    FMovieList: TMovieList;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
    function Execute(Movie: TMovie; MovieList: TMovieList): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ExtrasRenumberWin: TExtrasRenumberWin;

implementation

uses
  sort, fields, Global;

const
  msgRenumbering         =  0;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExtrasRenumberWin.Execute(Movie: TMovie; MovieList: TMovieList): TModalResult;
begin
  FMovie := Movie;
  FMovieList := MovieList;
  with SortWin.Fields do
  begin
    LoadFromStrings(Settings.rRenumberExtras.OrderFields, nil, False, True);
    DeleteField(extraFieldDescription);
  end;
  if FMovieList <> nil then
    FrmIncludemov.SetCount(FMovieList);
  FrmIncludemov.rbtAll.Checked := True;
  chkAllMovies.Checked := (FMovie = nil);
  chkAllMovies.Enabled := (FMovieList <> nil) and (FMovie <> nil);
  chkAllMoviesClick(nil);
  result := ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.LoadOptions;
begin
  SortBy.EOrderBy.ItemIndex := Settings.rRenumberExtras.OrderBy;
  SortBy.BtnSortDescend.Checked := Settings.rRenumberExtras.OrderDescend;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.SaveOptions;
begin
  Settings.rRenumberExtras.OrderBy := SortBy.EOrderBy.ItemIndex;
  Settings.rRenumberExtras.OrderDescend := SortBy.BtnSortDescend.Checked;
  SortWin.Fields.SaveToStrings(Settings.rRenumberExtras.OrderFields, nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.FormCreate(Sender: TObject);
begin
  SortWin := TSortWin.Create(Self);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.FormDestroy(Sender: TObject);
begin
  SortWin.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.btn2Click(Sender: TObject);
var
  i: Integer;
begin
  if (FMovie = nil) and (FMovieList = nil) then
    Exit;
  if chkAllMovies.Checked and (FMovieList <> nil) then
  begin
    with ProgressWin do
    begin
      Maximum := FMovieList.Count;
      Status := Messages.Strings[msgRenumbering];
      IntProgress := 0;
      Execute(Self);
      try
        with FMovieList do
          for i := 0 to Count-1 do
          begin
            IntProgress := i;
            if Items[i].CanInclude(FrmIncludemov.ItemIndex) then
              SortBy.Sort(Items[i].Extras);
          end;
        IntProgress := Maximum;
      finally
        Close;
      end;
    end;
    Application.ProcessMessages;
  end
  else if (FMovie <> nil) then
    SortBy.Sort(FMovie.Extras);
  ModalResult := mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.Translate;
begin
  Translator.Translate(SortBy);
  Translator.Translate(FrmIncludemov);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.SortByBtnAdvSortClick(Sender: TObject);
begin
  inherited;
  SortBy.BtnAdvSortClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasRenumberWin.chkAllMoviesClick(Sender: TObject);
begin
  inherited;
  FrmIncludemov.Visible := chkAllMovies.Checked;
end;

end.
