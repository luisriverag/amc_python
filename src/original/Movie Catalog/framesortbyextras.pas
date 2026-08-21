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

unit framesortbyextras;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,

  AntCorelButton,

  MovieClass, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TExtrasSortByFrame = class(TFrame)
    grp: TGroupBox;
    EOrderBy: TComboBox;
    BtnAdvSort: TCorelButton;
    BtnSortDescend: TTBXButton;
    procedure EOrderByChange(Sender: TObject);
    procedure BtnAdvSortClick(Sender: TObject);
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure Sort(MovieExtras: TMovieExtras);
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  sort, fields, Global, ConstValues, functions_tbx;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasSortByFrame.EOrderByChange(Sender: TObject);
begin
  if EOrderBy.ItemIndex = 3 then
    BtnAdvSort.Click;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasSortByFrame.BtnAdvSortClick(Sender: TObject);
begin
  SortWin.ShowModal;
  if SortWin.Fields.SelectedCount > 0 then
    EOrderBy.ItemIndex := 3;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtrasSortByFrame.Sort(MovieExtras: TMovieExtras);
var
  FieldsList: TStringList;
begin
  if MovieExtras <> nil then
    case EOrderBy.ItemIndex of
      0:
        if BtnSortDescend.Checked then
          MovieExtras.SortReverse(extraFieldNumber, True)
        else
          MovieExtras.Sort(extraFieldNumber, True);
      1:
        if BtnSortDescend.Checked then
          MovieExtras.SortReverse(extraFieldTag, True)
        else
          MovieExtras.Sort(extraFieldTag, True);
      2:
        if BtnSortDescend.Checked then
          MovieExtras.SortReverse(extraFieldTitle, True)
        else
          MovieExtras.Sort(extraFieldTitle, True);
      3:
      begin
        FieldsList := TStringList.Create;
        SortWin.Fields.SaveToStrings(FieldsList, nil);
        if BtnSortDescend.Checked then
          MovieExtras.SortReverse(FieldsList, True)
        else
          MovieExtras.Sort(FieldsList, True);
        FieldsList.Free;
      end;
    end; // case
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TExtrasSortByFrame.Create(AOwner: TComponent);
begin
  inherited;
  LoadButtonIcon(BtnSortDescend, ICON_SORTDESCEND);
  EOrderBy.Items[0] := strExtraFields[extraFieldNumber - extraFieldLow];
  EOrderBy.Items[1] := strExtraFields[extraFieldTag - extraFieldLow];
  EOrderBy.Items[2] := strExtraFields[extraFieldTitle - extraFieldLow];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
