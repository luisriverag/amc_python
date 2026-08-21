(************************************************************************
 *                                                                      *
 *   (C) 2004-2006 Antoine Potten                                       *
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

unit listform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, AntCorelButton, AntAutoHintLabel, ExtCtrls;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TListWin = class(TBaseDlg)
    lst: TListBox;
    procedure lstClick(Sender: TObject);
    procedure lstDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  public
    function Execute: Boolean;
    procedure FitToContents;
  end;

var
  ListWin: TListWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  Math;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TListWin.Execute: Boolean;
begin
  lstClick(lst);
  Result := ShowModal = mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TListWin.lstClick(Sender: TObject);
begin
  btn2.Enabled := lst.ItemIndex <> -1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TListWin.lstDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TListWin.FormShow(Sender: TObject);
begin
  inherited;
  lst.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TListWin.FitToContents;
var
  MaxW: Integer;
  i: Integer;
begin
  MaxW := 200;
  for i := 0 to lst.Items.Count-1 do
  begin
    MaxW := Max(MaxW, lst.Canvas.TextWidth(lst.Items[i]));
  end;
  Self.Width := Min(MaxW + (Self.Width - lst.ClientWidth) + 10, Trunc(Self.Monitor.Width * 0.9));
  Self.Position := poDefaultPosOnly;
  Self.Position := poOwnerFormCenter;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
