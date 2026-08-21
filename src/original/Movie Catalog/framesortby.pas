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

unit framesortby;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,

  AntCorelButton,

  MovieClass, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TSortByFrame = class(TFrame)
    grp: TGroupBox;
    EOrderBy: TComboBox;
    BtnAdvSort: TCorelButton;
    BtnSortDescend: TTBXButton;
    procedure EOrderByChange(Sender: TObject);
    procedure BtnAdvSortClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure Sort(MovieList: TMovieList);
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  sort, fields, Global, ConstValues, functions_tbx;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortByFrame.EOrderByChange(Sender: TObject);
begin
  if EOrderBy.ItemIndex = 4 then
    BtnAdvSort.Click;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortByFrame.BtnAdvSortClick(Sender: TObject);
begin
  SortWin.ShowModal;
  if SortWin.Fields.SelectedCount > 0 then
    EOrderBy.ItemIndex := 4;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortByFrame.Sort(MovieList: TMovieList);
var
  FieldsList: TStringList;
begin
  if MovieList <> nil then
    case EOrderBy.ItemIndex of
      0:
        if BtnSortDescend.Checked then
          MovieList.SortReverse(fieldNumber)
        else
          MovieList.Sort(fieldNumber);
      1:
        if BtnSortDescend.Checked then
          MovieList.SortReverse(fieldOriginalTitle)
        else
          MovieList.Sort(fieldOriginalTitle);
      2:
        if BtnSortDescend.Checked then
          MovieList.SortReverse(fieldTranslatedTitle)
        else
          MovieList.Sort(fieldTranslatedTitle);
      3:
        if BtnSortDescend.Checked then
          MovieList.SortReverse(fieldFormattedTitle)
        else
          MovieList.Sort(fieldFormattedTitle);
      4:
      begin
        FieldsList := TStringList.Create;
        SortWin.Fields.SaveToStrings(FieldsList, MovieList.CustomFieldsProperties);
        if BtnSortDescend.Checked then
          MovieList.SortReverse(FieldsList)
        else
          MovieList.Sort(FieldsList);
        FieldsList.Free;
      end;
    end; // case
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TSortByFrame.Create(AOwner: TComponent);
begin
  inherited;
  LoadButtonIcon(BtnSortDescend, ICON_SORTDESCEND);
  EOrderBy.Items[0] := strFields[fieldNumber];
  EOrderBy.Items[1] := strFields[fieldOriginalTitle];
  EOrderBy.Items[2] := strFields[fieldTranslatedTitle];
  EOrderBy.Items[3] := strFields[fieldFormattedTitle];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
