(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2018 Antoine Potten, Mickaël Vanneufville                 *
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

program moviecatalog;

uses
  Graphics in '..\DelphiFix\Graphics.pas',
  HTMLGif2 in '..\DelphiFix\HTMLGif2.pas',
  HTMLSubs in '..\DelphiFix\HTMLSubs.pas',
  JConsts in '..\DelphiFix\JConsts.pas',
  JPEG in '..\DelphiFix\JPEG.pas',
  StdCtrls in '..\DelphiFix\StdCtrls.pas',
  ComCtrls in '..\DelphiFix\ComCtrls.pas',
  TB2Dock in '..\DelphiFix\TB2Dock.pas',
  AntTranslator in '..\Common\AntTranslator.pas',
  FileManager in '..\Common\FileManager.pas',
  MediaInfo in '..\Common\MediaInfo.pas',
  base in '..\Common\base.pas' {BaseDlg},
  inputform in '..\Common\inputform.pas' {InputWin},
  messageform in '..\Common\messageform.pas' {MessageWin},
  memoform in '..\Common\memoform.pas' {MemoWin},
  listform in '..\Common\listform.pas' {ListWin},
  frameLanguage in '..\Common\frameLanguage.pas' {LanguageFrame: TFrame},
  functions_files in '..\Common\functions_files.pas',
  functions_gui in '..\Common\functions_gui.pas',
  functions_html in '..\Common\functions_html.pas',
  functions_str in '..\Common\functions_str.pas',
  functions_xml in '..\Common\functions_xml.pas',
  functions_video in '..\Common\functions_video.pas',
  functions_sys in '..\Common\functions_sys.pas',
  functions_tbx in '..\Common\functions_tbx.pas',
  functions_img in '..\Common\functions_img.pas',
  Forms,
  SysUtils,
  Controls,
  Windows,
  Global in 'Global.pas',
  main in 'main.pas' {MainWindow},
  options in 'options.pas' {OptionsWin},
  about in 'about.pas' {AboutWin},
  export in 'export.pas' {ExportWin},
  number in 'number.pas' {NumberWin},
  loan in 'loan.pas' {LoanWin},
  progress in 'progress.pas' {ProgressWin},
  framefields in 'framefields.pas' {FieldsFrame: TFrame},
  sort in 'sort.pas' {SortWin},
  properties in 'properties.pas' {PropertiesWin},
  splash in 'splash.pas' {SplashWin},
  stats in 'stats.pas' {StatsWin},
  framesortby in 'framesortby.pas' {SortByFrame: TFrame},
  getscript in 'getscript.pas' {GetScriptWin},
  getscript_picktree in 'getscript_picktree.pas' {PickTreeWin},
  getscript_picklist in 'getscript_picklist.pas' {PickListWin},
  pictureform in 'pictureform.pas' {PictureWin},
  framemovie in 'framemovie.pas' {MovieFrame: TFrame},
  options_defaultvalues in 'options_defaultvalues.pas' {DefaultValuesWin},
  printform in 'printform.pas' {PrintWin},
  movieclass in 'movieclass.pas',
  fields in 'fields.pas',
  ProgramSettings in 'programsettings.pas',
  loanhistory in 'loanhistory.pas',
  ConstValues in 'ConstValues.pas',
  threaddownload in 'threaddownload.pas',
  languageselect in 'languageselect.pas' {LanguageWin},
  frameincludemov in 'frameincludemov.pas' {IncludemovFrame: TFrame},
  getscript_results in 'getscript_results.pas' {ScriptResultsWin},
  FramePictureOperation in 'FramePictureOperation.pas' {PictureOperationFrame: TFrame},
  PictureSelection in 'PictureSelection.pas',
  PictureDragDrop in 'PictureDragDrop.pas' {PictureDragDropWin},
  getscript_readscripts in 'getscript_readscripts.pas',
  getscript_properties in 'getscript_properties.pas' {ScriptPropertiesWin},
  movieclass_old in 'movieclass_old.pas',
  getscript_debug in 'getscript_debug.pas',
  getmedia in 'getmedia.pas',
  getscript_xml in 'getscript_xml.pas',
  import2 in 'import2.pas' {ImportWin2},
  import2_frame in 'import2_frame.pas' {ImportFrame: TFrame},
  import2_engines in 'import2_engines.pas',
  import2_frameCsv in 'import2_frameCsv.pas' {ImportFrameCSV: TFrame},
  interfaces in 'interfaces.pas',
  import2_frameQuery in 'import2_frameQuery.pas' {ImportFrameQuery: TFrame},
  import2_frameDir in 'import2_frameDir.pas' {ImportFrameDir: TFrame},
  framemoviecustom in 'framemoviecustom.pas' {MovieFrameCustom: TFrame},
  framemovieextras in 'framemovieextras.pas' {MovieFrameExtras: TFrame},
  stringfilter in 'stringfilter.pas' {StringFilterWin},
  FramePictureSelectionOptions in 'FramePictureSelectionOptions.pas' {PictureSelectOptionsFrame: TFrame},
  picturesmanager in 'picturesmanager.pas' {PicturesManagerWin},
  FramePictureOperationExport in 'FramePictureOperationExport.pas' {PictureOperationExportFrame: TFrame},
  FrameHtmlTemplateEdit in 'FrameHtmlTemplateEdit.pas' {HTMLTemplateEdit: TFrame},
  HTMLEditor in 'HTMLEditor.pas' {HTMLEditorWin},
  frameextra in 'frameextra.pas' {ExtraFrame: TFrame},
  extrasedit in 'extrasedit.pas' {ExtrasEditWin},
  framesortbyextras in 'framesortbyextras.pas' {ExtrasSortByFrame: TFrame},
  extrasrenumber in 'extrasrenumber.pas' {ExtrasRenumberWin},
  getscript_extrasresults in 'getscript_extrasresults.pas' {ScriptExtrasResultsWin},
  options_extradefaultvalues in 'options_extradefaultvalues.pas' {ExtraDefaultValuesWin},
  frameincludepic in 'frameincludepic.pas' {IncludepicFrame: TFrame},
  framefilenaming in 'framefilenaming.pas' {FileNamingFrame: TFrame},
  ExpressionParser in 'ExpressionParser.pas';

{$R *.res}
{$R MANIFEST.RES}
{$R TOOLBARS.RES}
{$R ICONS.RES}
{$R TEMPLATES.RES}

{$I+}

begin
  SetWaitCursor;
  try
    {$IFDEF DISABLETHEMES}
    IsThemedXP := False;
    Graphics.DefFontData.Name := 'MS Sans Serif';
    {$ELSE}
    if IsWindowsNT then
      Graphics.DefFontData.Name := 'MS Shell Dlg 2'
    else
      Graphics.DefFontData.Name := 'MS Shell Dlg';
    {$ENDIF}
    Graphics.DefFontData.Charset := DEFAULT_CHARSET;
    Application.Initialize;
    Application.Title := 'Ant Movie Catalog 4';
    Application.HelpFile := '';
    Settings := TSettings.Create;
    Translator := TAntTranslator.Create(nil);
    Settings.Load;
    SplashWin := TSplashWin.Create(nil);
    with SplashWin do
    begin
      ProgressBar1.Max := 70;
      ProgressBar1.Position := 0;
      if Settings.rOptions.rDisplay.Logo then
        Show;
      Application.ProcessMessages;
      ProgressBar1.Position := 11;
      ProgressBar1.Position := 10;
      Application.CreateForm(TMainWindow, MainWindow);
      strFields := MainWindow.Fields.Strings;
      strExtraFields := MainWindow.ExtraFields.Strings;
      strMedia := MainWindow.Media.Strings;
      strPictureStatus := MainWindow.PictureStatus.Strings;
      ProgressBar1.Position := 21;
      ProgressBar1.Position := 20;
      Application.CreateForm(TMessageWin, MessageWin);
      Application.CreateForm(TInputWin, InputWin);
      ProgressBar1.Position := 31;
      ProgressBar1.Position := 30;
      Application.CreateForm(TNumberWin, NumberWin);
      Application.CreateForm(TProgressWin, ProgressWin);
      ProgressBar1.Position := 41;
      ProgressBar1.Position := 40;
    end;
  finally
    RestoreCursor;
  end;
  Application.Run;
  SplashWin.Free;
  Translator.Free;
  Settings.Free;
end.

