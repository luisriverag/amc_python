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

unit languageselect;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, AntCorelButton, AntAutoHintLabel, ExtCtrls,

  frameLanguage;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TLanguageWin = class(TBaseDlg)
    LanguageFrame: TLanguageFrame;
    procedure LanguageFramelstLanguagesDblClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
  public
    function Execute: Boolean;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  Global, ConstValues, ProgramSettings;

{-------------------------------------------------------------------------------
  TLanguageWin
-------------------------------------------------------------------------------}

function TLanguageWin.Execute: Boolean;
begin
  with Settings.rOptions do
  begin
    LanguageFrame.LoadLanguages(lfLNG, strDirLanguages, '*.lng');
    LanguageFrame.SelectedLanguageFile := rLanguage.Language + '.lng';
    if LanguageFrame.lstLanguages.Selected <> nil then
      LanguageFrame.lstLanguages.Selected.MakeVisible(False);
    Result := ShowModal = mrOk;
    if Result then
      rLanguage.Language := ChangeFileExt(LanguageFrame.SelectedLanguageFile, '')
    else
      if rLanguage.Language = '?' then
        rLanguage.Language := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLanguageWin.LanguageFramelstLanguagesDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLanguageWin.FormActivate(Sender: TObject);
begin
  inherited;
  LanguageFrame.Repaint;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
