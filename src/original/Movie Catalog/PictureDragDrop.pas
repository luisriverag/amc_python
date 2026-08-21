(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2006 Antoine Potten                                       *
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

unit PictureDragDrop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, FramePictureSelectionOptions, AntCorelButton,
  AntAutoHintLabel, ExtCtrls;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPictureDragDropWin = class(TBaseDlg)
    Options: TPictureSelectOptionsFrame;
    CBDoNotAsk: TCheckBox;
    procedure btn1Click(Sender: TObject);
  private
  public
    function Execute(var ImportMethod: TPictureSelectOption; out DoNotAsk: Boolean): Boolean;
    procedure Translate; override;
  end;

implementation

{$R *.dfm}

uses
  functions_files, Global;

{-------------------------------------------------------------------------------
  TPictureDragDropWin
-------------------------------------------------------------------------------}

function TPictureDragDropWin.Execute(var ImportMethod: TPictureSelectOption; out DoNotAsk: Boolean): Boolean;
begin
  Options.Selected := ImportMethod;
  Result := ShowModal = mrOk;
  ImportMethod := Options.Selected;
  DoNotAsk := CBDoNotAsk.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureDragDropWin.btn1Click(Sender: TObject);
begin
  functions_files.LaunchHelp(HelpContext);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureDragDropWin.Translate;
begin
  inherited;
  Translator.Translate(Options);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
