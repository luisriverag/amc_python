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

unit renumber;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ComCtrls, ExtCtrls,

  AntStringList, AntCorelButton,

  MovieClass, framesortby, AntAutoHintLabel;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TRenumberWin = class(TBaseDlg)
    SortBy: TSortByFrame;
    Messages: TAntStringList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure SortByBtnAdvSortClick(Sender: TObject);
  private
    FMovieList: TMovieList;
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
    function Execute(MovieList: TMovieList): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  RenumberWin: TRenumberWin;

implementation

uses
  sort, fields, Global;

const
  msgRenumbering         =  0;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TRenumberWin.Execute(MovieList: TMovieList): TModalResult;
begin
  FMovieList := MovieList;
  with SortWin.Fields do
  begin
    LoadFromStrings(Settings.rRenumber.OrderFields, FMovieList.CustomFieldsProperties);
    DeleteField(fieldActors);
    DeleteField(fieldDescription);
    DeleteField(fieldComments);
  end;
  result := ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.LoadOptions;
begin
  SortBy.EOrderBy.ItemIndex := Settings.rRenumber.OrderBy;
  SortBy.BtnSortDescend.Checked := Settings.rRenumber.OrderDescend;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.SaveOptions;
begin
  Settings.rRenumber.OrderBy := SortBy.EOrderBy.ItemIndex;
  Settings.rRenumber.OrderDescend := SortBy.BtnSortDescend.Checked;
  SortWin.Fields.SaveToStrings(Settings.rRenumber.OrderFields, FMovieList.CustomFieldsProperties);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.FormCreate(Sender: TObject);
begin
  SortWin := TSortWin.Create(Self);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.FormDestroy(Sender: TObject);
begin
  SortWin.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.btn2Click(Sender: TObject);
var
  i: Integer;
begin
  if FMovieList <> nil then
  begin
    SortBy.Sort(FMovieList);
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
            if Items[i] <> nil then
              TMovie(Items[i]).iNumber := i + 1;
          end;
        IntProgress := Maximum;
      finally
        Close;
      end;
    end;
    Application.ProcessMessages;
  end;
  ModalResult := mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.Translate;
begin
  Translator.Translate(SortBy);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TRenumberWin.SortByBtnAdvSortClick(Sender: TObject);
begin
  inherited;
  SortBy.BtnAdvSortClick(Sender);

end;

end.
