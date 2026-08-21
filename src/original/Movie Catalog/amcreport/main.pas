(************************************************************************
 *                                                                      *
 *   (C) 2002-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FR_Desgn, FR_Class, FR_Dock,

  fields;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TForm1 = class(TForm)
    frDesigner1: TfrDesigner;
    frReport1: TfrReport;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    CustomFieldsTag: TStringList;
  public
    procedure Execute;
    procedure ReportLoaded(Sender: TObject);
    procedure TutorialMenuClick(Sender: TObject);
  end;

var
  Form1: TForm1;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  functions_files;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TForm1.FormCreate(Sender: TObject);
begin
  CustomFieldsTag := TStringList.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TForm1.FormDestroy(Sender: TObject);
begin
  CustomFieldsTag.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TForm1.Execute;
var
  s, ext: string;
  i: Integer;
  //ReportFound: Boolean;
begin
  //ReportFound := False;
  frReport1.OnReportLoaded := ReportLoaded;
  
  for i := 1 to ParamCount do
  begin
    s := ParamStr(i);
    if (s <> '') and (s[1] = '*') then // Custom Field Tag
      CustomFieldsTag.Add(Copy(s, 2, MaxInt))
    else
    begin
      ext := ExtractFileExt(s);
      if SameText(ext, '.frf') then
      begin
        //ReportFound := True;
        frReport1.TemplatesDir := ExtractFilePath(s);
        frReport1.LoadFromFile(s);
      end
      else
      if SameText(ext, '.chm') then
      begin
        strHelpFile := s;
        frDesigner.SetSecondHelpFile(s, TutorialMenuClick)
      end
      else
      if SameText(ext, '.ini') then
      begin
        FR_Dock.IniPath := s;
      end
      else
      if DirectoryExists(s) then
        frReport1.TemplatesDir := s;
    end;
  end;
  //if not ReportFound then
    ReportLoaded(frReport1);
  frReport1.DesignReport;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TForm1.ReportLoaded(Sender: TObject);
var
  i: Integer;
begin
  with frReport1 do
  begin
    Variables.Clear;
    Variables.Add('Movie Fields');
    for i := fieldLow to fieldCount-1 do
      Variables.Add(' ' + strTagFields[i]);
    Variables.Add(' ' + strTagFieldPicture);
    Variables.Add('Custom Fields');
    for i := 0 to CustomFieldsTag.Count-1 do
      Variables.Add(' ' + CustomFieldsTag.Strings[i]);
    Variables.Add('Extra Fields');
    for i := extraFieldLow to extraFieldCount-1 do
    begin
      Variables.Add(' ' + strTagExtraFields[i - extraFieldLow] + '#Tag');
      Variables.Add(' ' + strTagExtraFields[i - extraFieldLow] + '##Pos#Category#Checked');
    end;
    Variables.Add(' ' + strTagExtraFieldPicture + '#Tag');
    Variables.Add(' ' + strTagExtraFieldPicture + '##Pos#Category#Checked');

    Variables.Add('Labels movie fields');
    for i := fieldLow to fieldCount-1 do
      Variables.Add(' label:' + strTagFields[i]);
    Variables.Add('Labels custom fields');
    for i := 0 to CustomFieldsTag.Count-1 do
      Variables.Add(' label:' + CustomFieldsTag.Strings[i]);
    Variables.Add('Labels extra fields');
    for i := extraFieldLow to extraFieldCount-1 do
      Variables.Add(' label:' + strTagExtraFields[i - extraFieldLow]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TForm1.TutorialMenuClick(Sender: TObject);
begin
  LaunchHelp(1074);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
