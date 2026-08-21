(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2012-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit HTMLEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, FrameHtmlTemplateEdit, StdCtrls, AntCorelButton,
  AntAutoHintLabel, ExtCtrls, MovieClass, TB2Item, TBX;

type
  THTMLEditorWin = class(TBaseDlg)
    HTMLTemplateEdit1: THTMLTemplateEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn1Click(Sender: TObject);
  private
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Execute(const CustomFieldsProperties: TCustomFieldsProperties);
    procedure Translate; override;
  end;

var
  HTMLEditorWin: THTMLEditorWin;

implementation

uses
  Global, ProgramSettings, functions_files;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.FormCreate(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  inherited;
  CanClose := HTMLTemplateEdit1.CloseQuery;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.LoadOptions;
begin
  with Settings.rHTMLEditor do
  begin
    case WindowState of
      1:
        begin
          self.WindowState := wsNormal;
          self.Width := WindowWidth;
          self.Height := WindowHeight;
        end;
      2:
        begin
          self.WindowState := wsMaximized;
        end;
      else
        begin
          self.WindowState := wsNormal;
        end;
    end;
  end;
  HTMLTemplateEdit1.SetMode(False);
  HTMLTemplateEdit1.LoadOptions;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.SaveOptions;
begin
  with Settings.rHTMLEditor do
  begin
    case self.WindowState of
      wsNormal:
        begin
          WindowState := 1;
          WindowWidth := Width;
          WindowHeight := Height;
        end;
      wsMaximized:
        begin
          WindowState := 2;
        end;
    end;
  end;
  HTMLTemplateEdit1.SaveOptions;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.Execute(const CustomFieldsProperties: TCustomFieldsProperties);
begin
  HTMLTemplateEdit1.InitTags(CustomFieldsProperties);
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.Translate;
begin
  Translator.Translate(HTMLTemplateEdit1);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLEditorWin.btn1Click(Sender: TObject);
begin
  inherited;
  functions_files.LaunchHelp(HelpContext);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
