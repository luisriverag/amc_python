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

unit sort;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,

  framefields, movieclass, TBXDkPanels;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TSortWin = class(TForm)
    Fields: TFieldsFrame;
    BtnSortOrder: TTBXButton;
    procedure FormCreate(Sender: TObject);
    procedure BtnSortOrderClick(Sender: TObject);
    procedure FieldsLbSelectedMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
  public
  end;

var
  SortWin: TSortWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.DFM}

uses
  fields, Global, ConstValues, functions_tbx;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortWin.FormCreate(Sender: TObject);
begin
  LoadButtonIcon(BtnSortOrder, ICON_SORTDESCEND);
  Font.Name := Graphics.DefFontData.Name;
  Font.Charset := Graphics.DefFontData.Charset;
  Translator.Translate(Fields);
  Translator.Translate(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortWin.BtnSortOrderClick(Sender: TObject);
var
  idx: integer;
  s: TString;
  str: string;
begin
  idx := Fields.LbSelected.ItemIndex;
  if idx <> -1 then
    with Fields.LbSelected.Items do
    begin
      s := TString(Objects[idx]);
      if (Length(s.str) > 0) and (s.str[1] = '-') then
      begin
        str := s.str;
        System.Delete(str, 1, 1);
        s.str := str;
        Strings[idx] := Copy(Strings[idx], 4, Length(Strings[idx]));
      end
      else
      begin
        s.str := '-' + s.str;
        Strings[idx] := ' - ' + Strings[idx];
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TSortWin.FieldsLbSelectedMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    BtnSortOrderClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
