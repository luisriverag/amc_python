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

program AMCReport;

uses
  Graphics in '..\DelphiFix\Graphics.pas',
  JConsts in '..\..\DelphiFix\JConsts.pas',
  JPEG in '..\..\DelphiFix\JPEG.pas',
  StdCtrls in '..\..\DelphiFix\StdCtrls.pas',
  ComCtrls in '..\..\DelphiFix\ComCtrls.pas',
  TB2Dock in '..\..\DelphiFix\TB2Dock.pas',
  functions_files in '..\..\Common\functions_files.pas',
  regexpr in '..\..\Compos\Regexpr\regexpr.pas',
  Forms,
  main in 'main.pas' {Form1},
  fields in '..\fields.pas',
  FR_Class,
  FR_Desgn;

{$R *.res}
{$R MANIFEST.RES}

begin
  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := 'Report Designer for Ant Movie Catalog';
  Application.CreateForm(TForm1, Form1);
  Form1.Execute;
end.

