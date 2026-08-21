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

unit export;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ShellAPI, ImgList, ComCtrls, Menus,
  ActnList,

  AntCorelButton, AntStringList, AntJvLabel, AntJvHotLink,
  TB2Item, TBX, TB2MRU, TBXExtItems,
  TB2Dock, TB2Toolbar, AntAutoHintLabel, AntJvLinkLabel,
  SynEdit, SynEditHighlighter, SynHighlighterHtml,

  ConstValues, ProgramSettings, base, MovieClass, FileManager, framefields,
  framesortby, frameincludemov, FramePictureOperationExport, FrameHtmlTemplateEdit,
  framefilenaming, frameincludepic;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const

  strFilterExtHTML    = 'html';
  strFilterExtCSV     = 'csv';
  strFilterExtSQL     = 'sql';
  strFilterExtImages  = '';
  strFilterExtXML     = 'xml';
  strFilterExtAMC     = 'amc';

  ToHTML    = 0;
  ToCSV     = 1;
  ToSQL     = 2;
  ToImages  = 3;
  ToAMC     = 4;
  ToXML     = 5;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TExportWin = class(TBaseDlg)
    CBCopyPictures: TCheckBox;
    CBCopyPicturesInPicDir: TCheckBox;
    CBCopyPicturesNew: TCheckBox;
    CBCopyPicturesIncExtras: TCheckBox;
    CBCSVColumnTitles: TCheckBox;
    CBSQLCreate: TCheckBox;
    CBSQLDrop: TCheckBox;
    CBSQLUpdate: TCheckBox;
    FieldsCSV: TFieldsFrame;
    FieldsSQL: TFieldsFrame;
    grpImages: TGroupBox;
    ImageListFormat: TImageList;
    LSQLCommands: TLabel;
    LSQLTableName: TLabel;
    ESQLTableName: TEdit;
    LSQLTableNameExtras: TLabel;
    ESQLTableNameExtras: TEdit;
    Messages: TAntStringList;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SortBy: TSortByFrame;
    tshCSV: TTabSheet;
    tshHTML: TTabSheet;
    tshPictures: TTabSheet;
    tshSQL: TTabSheet;
    LCSVDelimiter: TLabel;
    ECSVDelimiter: TComboBox;
    LCSVDelimExtras: TLabel;
    ECSVDelimExtras: TComboBox;
    LCSVBloc: TLabel;
    ECSVBloc: TComboBox;
    LCSVLinebreaks: TLabel;
    ECSVLinebreaks: TComboBox;
    LSQLLinebreaks: TLabel;
    ESQLLinebreaks: TComboBox;
    LvFormat: TListView;
    pnlLeft: TPanel;
    Splitter1: TSplitter;
    Includemov: TIncludemovFrame;
    tshXML: TTabSheet;
    LXMLNote: TLabel;
    tshAMC: TTabSheet;
    LAMCNote: TLabel;
    tshEmpty: TTabSheet;
    LSelectFormat: TLabel;
    HTMLTemplateEdit1: THTMLTemplateEdit;
    PictureOperationExportAMC: TPictureOperationExportFrame;
    PictureOperationExportXML: TPictureOperationExportFrame;
    ExtraPictureOperationExportAMC: TPictureOperationExportFrame;
    ExtraPictureOperationExportXML: TPictureOperationExportFrame;
    PictureNaming: TFileNamingFrame;
    Includepic: TIncludepicFrame;
    procedure btn1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure CBCopyPicturesClick(Sender: TObject);
    procedure CBSQLUpdateClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure LvFormatSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure SortByBtnAdvSortClick(Sender: TObject);
    procedure SortByEOrderByChange(Sender: TObject);
    procedure LinkLabelLinkClick(Sender: TObject; LinkNumber: Integer;
      LinkText: String);
    procedure IncludemovClick(Sender: TObject);
  private
    MovieList: TMovieList;
    SourceFile: string;
    DestFile: string;

    FHTMLPicAttr: string;
    FHTMLExtraPicAttr: string;

    FExpFileNaming: TFileNaming;
    FExpFileExt: string;
    FExpFileNames: TStringList;
    FMaxMovieNumber: Integer;

    FCancelExport: Boolean;

    procedure OnCancelExport(Sender: TObject);

    procedure ReplaceTagsGeneral(var Page: string; const LineBreak: string);
    procedure ReplaceTagsMovie(var Page: string; const AMovie: TMovie;
      const ExportPic, OnlyNewPic, IncPicExtras: Boolean;
      const PicDirWithBackslash: string; const LineBreak: string; const RecNr: Integer);
    procedure ReplaceTagsExtras(var Page: string; const AMovie: TMovie;
      const ExportPic, OnlyNewPic, IncPicExtras: Boolean;
      const PicDirWithBackslash: string; const LineBreak: string);
    procedure ReplaceTagsExtra(var Page: string; const AMovie: TMovie;
      const AExtra: TMovieExtra; const ExportPic, OnlyNewPic, IncPicExtras: Boolean;
      const PicDirWithBackslash: string; const LineBreak: string; const ExtraRecNr: Integer);
    function GetExpFileName(const AMovie: TMovie; const AExtra: TMovieExtra): string;

    procedure ExportToHTML;
    procedure ExportToCSV;
    procedure ExportToSQL;
    procedure ExportToImages;
    procedure ExportToXmlOrAmc(ToXml: Boolean; Version: Integer);
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
    function Execute(const AFileName: TFileName; const AList: TMovieList): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ExportWin: TExportWin;

implementation

uses
  StrUtils,

  main, // Needed for some labels translations in HTML export

  fields, sort, Global, functions_files, functions_str, functions_sys, progress;

{$R *.DFM}

const
  msgExportInit       =  0;
  msgExporting        =  1;
  msgCopying          =  2;
  msgToHTML           =  3;
  msgToCSV            =  4;
  msgToSQL            =  5;
  msgToImages         =  6;
  msgToOrigons        =  7;
  msgToAmc            =  8;
  msgToXml            =  9;
  msgCatalogSamePath  = 10;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  with PageControl1 do
    for i := 0 to PageCount-1 do
      Pages[i].TabVisible := false;
  SortWin := TSortWin.Create(Self);

  FExpFileNames := TStringList.Create;
  FExpFileNames.Sorted := True;
  FExpFileNames.Duplicates := dupIgnore;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.FormShow(Sender: TObject);
begin
  inherited;
  LvFormat.SetFocus;
  LvFormat.Selected := nil;
  LvFormatSelectItem(Sender, nil, False);
  CBCopyPicturesClick(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := HTMLTemplateEdit1.CloseQuery;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.FormDestroy(Sender: TObject);
begin
  SortWin.Free;
  FExpFileNames.Free;
end;

{-------------------------------------------------------------------------------
   Options
-------------------------------------------------------------------------------}

procedure TExportWin.LoadOptions;
begin
  with Settings do
  begin
    with rExport do
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

      Self.SortBy.EOrderBy.ItemIndex := OrderBy;
      Self.SortBy.BtnSortDescend.Checked := OrderDescend;
      Self.Includemov.ItemIndex := TMovieIncludeOption(Includemov);

      HTMLTemplateEdit1.SetMode(True);
      HTMLTemplateEdit1.LoadOptions;

      //PictureNamingFrame.LoadFromObject(PictureNaming,
      //  MovieList.CustomFieldsProperties); // Done in Execute

      ECSVDelimiter.Text := CSVDelimiter;
      ECSVDelimExtras.Text := CSVDelimExtras;
      ECSVBloc.Text := CSVBloc;
      ECSVLinebreaks.Text := CSVLinebreaks;
      CBCSVColumnTitles.Checked := CSVColumnTitles;

      CBSQLUpdate.Checked := SQLUpdate;
      CBSQLDrop.Checked := SQLDrop;
      CBSQLCreate.Checked := SQLCreate;
      CBSQLUpdateClick(CBSQLUpdate);
      ESQLTableName.Text := SQLTableName;
      ESQLTableNameExtras.Text := SQLTableNameExtras;
      ESQLLinebreaks.Text := SQLLinebreaks;

      with rOptions.rExport do
      begin
        FExpFileNaming := ExpFileNaming;
        FHTMLPicAttr := '';
        if ForcePicSizeW >= 0 then
          FHTMLPicAttr := Format(' width="%d"', [ForcePicSizeW]);
        if ForcePicSizeH >= 0 then
          FHTMLPicAttr := Format('%s height="%d"', [FHTMLPicAttr, ForcePicSizeH]);
        FHTMLExtraPicAttr := '';
        if ForceExtraPicSizeW >= 0 then
          FHTMLExtraPicAttr := Format(' width="%d"', [ForceExtraPicSizeW]);
        if ForceExtraPicSizeH >= 0 then
          FHTMLExtraPicAttr := Format('%s height="%d"', [FHTMLExtraPicAttr, ForceExtraPicSizeH]);

        CBCopyPictures.Checked := CopyPictures;
        CBCopyPicturesInPicDir.Checked := CopyPicturesInPicDir;
        CBCopyPicturesNew.Checked := CopyPicturesNew;
        CBCopyPicturesIncExtras.Checked := CopyPicturesIncExtras;

        PictureOperationExportAMC.SetExportFormat(False);
        PictureOperationExportAMC.Selected := TMoviePictureOperation(PicturesExportMethodAMC);
        PictureOperationExportXML.SetExportFormat(True);
        PictureOperationExportXML.Selected := TMoviePictureOperation(PicturesExportMethodXML);
        ExtraPictureOperationExportAMC.SetExportFormat(False);
        ExtraPictureOperationExportAMC.Selected := TMoviePictureOperation(ExtraPicturesExportMethodAMC);
        ExtraPictureOperationExportXML.SetExportFormat(True);
        ExtraPictureOperationExportXML.Selected := TMoviePictureOperation(ExtraPicturesExportMethodXML);
      end; // with rOptions.rExport
    end; // with rExport
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.SaveOptions;
begin
  with Settings do
  begin
    with rExport do
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

      OrderBy := Self.SortBy.EOrderBy.ItemIndex;
      OrderDescend := Self.SortBy.BtnSortDescend.Checked;
      SortWin.Fields.SaveToStrings(OrderFields, MovieList.CustomFieldsProperties);
      Includemov := Integer(Self.Includemov.ItemIndex);

      HTMLTemplateEdit1.SaveOptions;

      Self.PictureNaming.SaveToObject(PictureNaming);

      with rOptions.rExport do
      begin
        CopyPictures := CBCopyPictures.Checked;
        CopyPicturesInPicDir := CBCopyPicturesInPicDir.Checked;
        CopyPicturesNew := CBCopyPicturesNew.Checked;
        CopyPicturesIncExtras := CBCopyPicturesIncExtras.Checked;

        PicturesExportMethodAMC := Integer(PictureOperationExportAMC.Selected);
        PicturesExportMethodXML := Integer(PictureOperationExportXML.Selected);
        ExtraPicturesExportMethodAMC := Integer(PictureOperationExportAMC.Selected);
        ExtraPicturesExportMethodXML := Integer(PictureOperationExportXML.Selected);
      end;

      CSVDelimiter := ECSVDelimiter.Text;
      CSVDelimExtras := ECSVDelimExtras.Text;
      CSVBloc := ECSVBloc.Text;
      CSVLinebreaks := ECSVLinebreaks.Text;
      CSVColumnTitles := CBCSVColumnTitles.checked;
      FieldsCSV.SaveToStrings(CSVFields, MovieList.CustomFieldsProperties);

      SQLUpdate := CBSQLUpdate.Checked;
      SQLDrop := CBSQLDrop.Checked;
      SQLCreate := CBSQLCreate.Checked;
      FieldsSQL.SaveToStrings(SQLFields, MovieList.CustomFieldsProperties);
      SQLTableName := ESQLTableName.Text;
      SQLTableNameExtras := ESQLTableNameExtras.Text;
      SQLLinebreaks := ESQLLinebreaks.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
   General window management
-------------------------------------------------------------------------------}

function TExportWin.Execute(const AFileName: TFileName; const AList: TMovieList): TModalResult;
begin
  // Used in place of the ShowModal to allow the initialization of some variables
  SourceFile := AFileName;
  MovieList := AList;

  Includemov.SetCount(MovieList);
  PictureNaming.LoadFromObject(Settings.rExport.PictureNaming,
    MovieList.CustomFieldsProperties);
  Includepic.SetCount(MovieList, Includemov.ItemIndex);
  Includepic.ItemIndex := pioAll;

  HTMLTemplateEdit1.InitTags(MovieList.CustomFieldsProperties);

  with Settings.rExport do
  begin
    FieldsCSV.LoadFromStrings(CSVFields, MovieList.CustomFieldsProperties, True, False);
    FieldsSQL.LoadFromStrings(SQLFields, MovieList.CustomFieldsProperties, True, False);
    FieldsSQL.DeleteField(fieldNumber);
    FieldsSQL.DeleteField(extraFieldNumber);
    with SortWin.Fields do
    begin
      LoadFromStrings(OrderFields, MovieList.CustomFieldsProperties);
      DeleteField(fieldActors);
      DeleteField(fieldDescription);
      DeleteField(fieldComments);
    end;
  end;

  Result := ShowModal;
end;

{-------------------------------------------------------------------------------
   Export to ...
-------------------------------------------------------------------------------}

procedure TExportWin.ExportToCSV;
var
  CSV: TextFile;
  iMovie, iExtra, ifield, field: Integer;
  CurrentLine, ImageFileName, fieldval, ReplLinebr: string;
  DelimChar, QuoteChar: Char;
  bCopyPictures, bInPicDir, bIncPicExtras, bOnlyNewPictures: Boolean;
  IncOpt: TMovieIncludeOption;
  FieldsList: TStringList;
  PicDirWithBackslash: string;
  ExtraSep: string;
begin
  bCopyPictures := CBCopyPictures.Checked;
  bInPicDir := CBCopyPicturesInPicDir.Checked;
  PicDirWithBackslash := '';
  bOnlyNewPictures := CBCopyPicturesNew.Checked;
  bIncPicExtras := CBCopyPicturesIncExtras.Checked;
  ExtraSep := ECSVDelimExtras.Text;
  if ExtraSep = '' then
    ExtraSep := defaultExtraSepExport
  else if ExtraSep = '[tab]' then
    ExtraSep := #9;
  IncOpt := Includemov.ItemIndex;
  DelimChar := StrToChar(ECSVDelimiter.Text);
  QuoteChar := StrToChar(ECSVBloc.Text);
  ReplLinebr := ECSVLinebreaks.Text;
  ProgressWin.Status := Format(Messages.Strings[msgExporting],['CSV']);
  ProgressWin.OnCancel := OnCancelExport;
  AssignFile(CSV, DestFile);
  Rewrite(CSV);
  FieldsList := TStringList.Create;
  FieldsCSV.SaveToStrings(FieldsList, MovieList.CustomFieldsProperties);
  if CBCSVColumnTitles.Checked then
  begin
    CurrentLine := '';
    for ifield := 0 to FieldsList.Count-1 do
    begin
      if ifield > 0 then
        CurrentLine := CurrentLine + DelimChar;
      if (Length(FieldsList.Strings[ifield]) > 0) and
        (FieldsList.Strings[ifield][1] in ['0'..'9']) then // movie field or extra field (Field Id)
      begin
        field := StrToIntDef(FieldsList.Strings[ifield], -1);
        if (field >= fieldLow) and (field < fieldCount) then
          CurrentLine := CurrentLine + strTagFields[field]
        else if (field >= extraFieldLow) and (field < extraFieldCount) then
          CurrentLine := CurrentLine + strTagExtraFields[field - extraFieldLow]
        else
          CurrentLine := CurrentLine + 'UNKNOW_' + FieldsList.Strings[ifield];
      end else // custom field (Custom Field Tag)
      begin
        field := MovieList.CustomFieldsProperties.IndexOf(FieldsList.Strings[ifield]);
        if field > -1 then
          CurrentLine := CurrentLine + MovieList.CustomFieldsProperties.Objects[field].FieldTag
        else
          CurrentLine := CurrentLine + 'UNKNOW_' + FieldsList.Strings[ifield];
      end;
    end;
    if bCopyPictures then
    begin
      if FieldsList.Count > 0 then
        CurrentLine := CurrentLine + DelimChar;
      CurrentLine := CurrentLine + strTagFieldPicture;
      if bIncPicExtras then
      begin
        CurrentLine := CurrentLine + DelimChar;
        CurrentLine := CurrentLine + strTagExtraFieldPicture;
      end;
    end;
    Writeln(CSV,CurrentLine);
  end;
  iMovie := 0;
  while (iMovie < MovieList.Count) and (not FCancelExport) do
  begin
    with MovieList.Items[iMovie] do
      if CanInclude(IncOpt) then
      begin
        CurrentLine := '';
        for iField := 0 to FieldsList.Count-1 do
        begin
          if iField > 0 then
            CurrentLine := CurrentLine + DelimChar;
          if (Length(FieldsList.Strings[ifield]) > 0) and
            (FieldsList.Strings[ifield][1] in ['0'..'9']) then // movie field or extra field (Field Id)
          begin
            field := StrToIntDef(FieldsList.Strings[ifield], -1);
            if (field >= fieldLow) and (field < fieldCount) then
              fieldval := GetFieldValue(field)
            else if (field >= extraFieldLow) and (field < extraFieldCount) then
              fieldval := Extras.GetFieldValues(field, ExtraSep)
            else
              fieldval := '';
          end
          else // custom field (Custom Field Tag)
            fieldval := CustomFields.GetFieldValue(FieldsList.Strings[ifield]);
          fieldval := QuotedStrEx(fieldval, QuoteChar);
          if (ReplLinebr <> '') or (QuoteChar = #0) then
            CurrentLine := CurrentLine + StringReplace(fieldval, sLineBreak, ReplLinebr, [rfReplaceAll])
          else
            CurrentLine := CurrentLine + fieldval;
        end;
        if bCopyPictures then
        begin
          if Picture.PicPath <> '' then
          begin
            ImageFileName := '';
            if (PicDirWithBackslash = '') and bInPicDir then
            begin
              PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
              if SourceFile <> '' then
                SetCurrentDir(ExtractFilePath(SourceFile))
              else
                SetCurrentDir(strDirCatalogs);
            end;
            if Picture.PicStream <> nil then
            begin
              ImageFileName := GetExpFileName(MovieList.Items[iMovie], nil);
              if ImageFileName <> '' then
                ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Picture.PicPath));
              if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
              if (ImageFileName <> '') then
                if not bOnlyNewPictures or (bOnlyNewPictures and not FileExists(ImageFileName)) then
                  try
                    Picture.PicStream.SaveToFile(ImageFileName);
                  except
                    ImageFileName := '';
                  end;
            end
            else if FileExists(ExpandFileName(Picture.PicPath)) then
            begin
              ImageFileName := GetExpFileName(MovieList.Items[iMovie], nil);
              if ImageFileName <> '' then
                ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Picture.PicPath)));
              if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
              if (ImageFileName <> '') then
                CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageFileName), bOnlyNewPictures);
            end;
            fieldval := '';
            if ImageFileName <> '' then
              fieldval := PicDirWithBackslash + ExtractFileName(ImageFileName);
            fieldval := QuotedStrEx(fieldval, QuoteChar);
            if CurrentLine <> '' then
              CurrentLine := CurrentLine + DelimChar;
            CurrentLine := CurrentLine + fieldval;
          end
          else if CurrentLine <> '' then
            CurrentLine := CurrentLine + DelimChar;
            
          if bIncPicExtras then
          begin
            iExtra := 0;
            fieldval := '';
            while (iExtra < Extras.Count) and (not FCancelExport) do
              with Extras.Items[iExtra] do
              begin
                if iExtra > 0 then
                  fieldval := fieldval + ExtraSep;
                if Picture.PicPath <> '' then
                begin
                  ImageFileName := '';
                  if (PicDirWithBackslash = '') and bInPicDir then
                  begin
                    PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
                    if SourceFile <> '' then
                      SetCurrentDir(ExtractFilePath(SourceFile))
                    else
                      SetCurrentDir(strDirCatalogs);
                  end;
                  if Picture.PicStream <> nil then
                  begin
                    ImageFileName := GetExpFileName(MovieList.Items[iMovie], Extras.Items[iExtra]);
                    if ImageFileName <> '' then
                      ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Picture.PicPath));
                    if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                      ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
                    if ImageFileName <> '' then
                      if not bOnlyNewPictures or (bOnlyNewPictures and not FileExists(ImageFileName)) then
                        try
                          Picture.PicStream.SaveToFile(ImageFileName);
                        except
                          ImageFileName := '';
                        end;
                  end
                  else if FileExists(ExpandFileName(Picture.PicPath)) then
                  begin
                    ImageFileName := GetExpFileName(MovieList.Items[iMovie], Extras.Items[iExtra]);
                    if ImageFileName <> '' then
                      ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Picture.PicPath)));
                    if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                      ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
                    if ImageFileName <> '' then
                      CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageFileName), bOnlyNewPictures);
                  end;
                  if ImageFileName <> '' then
                    fieldval := fieldval + PicDirWithBackslash + ExtractFileName(ImageFileName);
                end;
                Inc(iExtra);
              end;
            fieldval := QuotedStrEx(fieldval, QuoteChar);
            if CurrentLine <> '' then
              CurrentLine := CurrentLine + DelimChar;
            CurrentLine := CurrentLine + fieldval;
          end;
        end;
        Writeln(CSV,CurrentLine);
        ProgressWin.StepIt;
      end;
    Inc(iMovie);
    Application.ProcessMessages;
  end;
  Closefile(CSV);
  FieldsList.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ExportToSQL;
var
  SQL: TextFile;
  iMovie, iExtra, iField, field: Integer;
  CurrentLine, ImageFileName, TableNameMovies, TableNameExtras: string;
  DateMask, FieldValue, ReplLinebr: string;
  bCreateTables, bDropTables, bUseUpdate, bExportExtras: Boolean;
  bCopyPictures, bInPicDir, bOnlyNewPictures, bIncPicExtras: Boolean;
  IncOpt: TMovieIncludeOption;
  FieldsList: TStringList;
  FieldProperties: TCustomFieldProperties;
  PicDirWithBackslash: string;
  Movie: TMovie;
  MovieFieldFound: Boolean;
  Extra: TMovieExtra;
  
  function IsExtraField(FieldName: string): Boolean;
  var
    idx: Integer;
  begin
    Result := False;
    if (Length(FieldName) > 0) and (FieldName[1] in ['0'..'9']) then // movie field or extra field (Field Id)
    begin
      idx := StrToIntDef(FieldName, -1);
      if (idx >= extraFieldLow) and (idx < extraFieldCount) then
        Result := True;
    end;
  end;
  
  function GetSQLName(FieldName: string): string;
  var
    idx: Integer;
  begin
    if (Length(FieldName) > 0) and (FieldName[1] in ['0'..'9']) then // movie field or extra field (Field Id)
    begin
      idx := StrToIntDef(FieldName, -1);
      if (idx >= fieldLow) and (idx < fieldCount) then
        Result := strTagSqlFields[idx]
      else if (idx >= extraFieldLow) and (idx < extraFieldCount) then
        Result := strTagSqlExtraFields[idx - extraFieldLow]
      else
        Result := 'UNKNOW_' + FieldName;
    end else // custom field (Custom Field Tag)
    begin
      idx := MovieList.CustomFieldsProperties.IndexOf(FieldName);
      if idx  <> -1 then
        with MovieList.CustomFieldsProperties.Objects[idx] do
          Result := 'CF_' + UpperCase(FieldTag)
      else
        Result := 'UNKNOW_' + FieldName;
    end;
  end;
  
  function GetSQLType(FieldName: string): string;
  var
    idx: Integer;
  begin
    if (Length(FieldName) > 0) and (FieldName[1] in ['0'..'9']) then // movie field or extra field (Field Id)
    begin
      idx := StrToIntDef(FieldName, -1);
      if (idx >= fieldLow) and (idx < fieldCount) then
      begin
        Result := ConvertFieldTypeToSQL(GetFieldType(idx));
        if idx = fieldNumber then
          Result := Result + ' NOT NULL';
      end
      else if (idx >= extraFieldLow) and (idx < extraFieldCount) then
      begin
        Result := ConvertFieldTypeToSQL(GetFieldType(idx));
        if idx = extraFieldNumber then
          Result := Result + ' NOT NULL';
      end else
        Result := 'TEXT';
    end else // custom field (Custom Field Tag)
    begin
      idx := MovieList.CustomFieldsProperties.IndexOf(FieldName);
      if idx  <> -1 then
        Result := ConvertFieldTypeToSQL(MovieList.CustomFieldsProperties.Objects[idx].FieldType)
      else
        Result := 'TEXT';
    end;
  end;
begin
  ReplLinebr := ESQLLinebreaks.Text;
  bCopyPictures := CBCopyPictures.Checked;
  bInPicDir := CBCopyPicturesInPicDir.Checked;
  PicDirWithBackslash := '';
  bOnlyNewPictures := CBCopyPicturesNew.Checked;
  bIncPicExtras := CBCopyPicturesIncExtras.Checked;
  bCreateTables := CBSQLCreate.Checked;
  bDropTables := CBSQLDrop.Checked;
  bUseUpdate := CBSQLUpdate.Checked;
  IncOpt := Includemov.ItemIndex;
  FieldsList := TStringList.Create;
  FieldsSQL.SaveToStrings(FieldsList, MovieList.CustomFieldsProperties);
  DateMask := Settings.rOptions.rExport.SQLDate;

  ifield := FieldsList.IndexOf(IntToStr(fieldNumber));
  if ifield <> -1 then
    FieldsList.Delete(ifield);
  ifield := FieldsList.IndexOf(IntToStr(extraFieldNumber));
  if ifield <> -1 then
    FieldsList.Delete(ifield);

  bExportExtras := bIncPicExtras;
  if not bExportExtras then
    for ifield := 0 to FieldsList.Count-1 do
      if IsExtraField(FieldsList.Strings[ifield]) then
      begin
        bExportExtras := True;
        break;
      end;

  TableNameMovies := ESQLTableName.Text;
  if TableNameMovies = '' then
    TableNameMovies := 'movies'
  else if (Length(TableNameMovies) = 0) or (TableNameMovies[1] in ['0'..'9']) then
    TableNameMovies := '_' + TableNameMovies;

  TableNameExtras := ESQLTableNameExtras.Text;
  if TableNameExtras = '' then
    TableNameExtras := 'extras'
  else if (Length(TableNameExtras) = 0) or (TableNameExtras[1] in ['0'..'9']) then
    TableNameExtras := '_' + TableNameExtras;

  ProgressWin.Status := Format(Messages.Strings[msgExporting], ['SQL']);
  ProgressWin.OnCancel := OnCancelExport;
  AssignFile(SQL, DestFile);
  Rewrite(SQL);

  if bDropTables then
  begin
    if bExportExtras then
    begin
      CurrentLine := 'DROP TABLE IF EXISTS ' + TableNameExtras + ';';
      Writeln(SQL,CurrentLine);
    end;
    CurrentLine := 'DROP TABLE IF EXISTS ' + TableNameMovies + ';';
    Writeln(SQL,CurrentLine);
  end;
 
  if bCreateTables then
  begin
    CurrentLine := 'CREATE TABLE ' + TableNameMovies + ' (';
    CurrentLine := CurrentLine + strTagSqlFields[fieldNumber] + ' ';
    CurrentLine := CurrentLine + ConvertFieldTypeToSQL(GetFieldType(fieldNumber));
    for ifield := 0 to FieldsList.Count-1 do
      if not IsExtraField(FieldsList.Strings[ifield]) then
      begin
        CurrentLine := CurrentLine + ', ';
        CurrentLine := CurrentLine + GetSQLName(FieldsList.Strings[ifield]) + ' ';
        CurrentLine := CurrentLine + GetSQLType(FieldsList.Strings[ifield]);
      end;
    if bCopyPictures then
    begin
      CurrentLine := CurrentLine + ', ';
      CurrentLine := Format('%s%s TEXT', [CurrentLine, strTagSqlFieldPicture]);
    end;
    CurrentLine := CurrentLine + ', PRIMARY KEY (' + strTagSqlFields[fieldNumber] + ')';
    CurrentLine := CurrentLine + ');';
    Writeln(SQL,CurrentLine);
    
    if bExportExtras then
    begin
      CurrentLine := 'CREATE TABLE ' + TableNameExtras + ' (';
      CurrentLine := CurrentLine + strTagSqlExtraFields[extraFieldNumber - extraFieldLow] + ' ';
      CurrentLine := CurrentLine + ConvertFieldTypeToSQL(GetFieldType(extraFieldNumber));
      CurrentLine := CurrentLine + ', ';
      CurrentLine := CurrentLine + strTagSqlExtraFieldRefMovieNumber + ' ';
      CurrentLine := CurrentLine + ConvertFieldTypeToSQL(GetFieldType(fieldNumber));
      for ifield := 0 to FieldsList.Count-1 do
        if IsExtraField(FieldsList.Strings[ifield]) then
        begin
          CurrentLine := CurrentLine + ', ';
          CurrentLine := CurrentLine + GetSQLName(FieldsList.Strings[ifield]) + ' ';
          CurrentLine := CurrentLine + GetSQLType(FieldsList.Strings[ifield]);
        end;
      if bCopyPictures and bIncPicExtras then
      begin
        CurrentLine := CurrentLine + ', ';
        CurrentLine := Format('%s%s TEXT', [CurrentLine, strTagSqlFieldPicture]);
      end;
      CurrentLine := CurrentLine + ', PRIMARY KEY (' + strTagSqlExtraFields[extraFieldNumber - extraFieldLow] +
        ', ' + strTagSqlExtraFieldRefMovieNumber + ')';
      CurrentLine := CurrentLine + ', FOREIGN KEY (' + strTagSqlExtraFieldRefMovieNumber +
        ') REFERENCES ' + TableNameMovies + '(' + strTagSqlFields[fieldNumber] +')';
      CurrentLine := CurrentLine + ');';
      Writeln(SQL,CurrentLine);
    end; 
  end;

  iMovie := 0;
  while (iMovie < MovieList.Count) and (not FCancelExport) do
  begin
    Movie := MovieList.Items[iMovie];
    with Movie do
    begin
      if CanInclude(IncOpt) then
      begin
        if bUseUpdate then
          CurrentLine := 'UPDATE ' + TableNameMovies + ' SET '
        else
        begin
          CurrentLine := 'INSERT INTO '+ TableNameMovies +' (';
          CurrentLine := CurrentLine + strTagSqlFields[fieldNumber];
          for ifield := 0 to FieldsList.Count-1 do
          begin
            if not IsExtraField(FieldsList.Strings[ifield]) then
            begin
              CurrentLine := CurrentLine + ', ';
              CurrentLine := CurrentLine + GetSQLName(FieldsList.Strings[ifield]);
            end;
          end;
          if bCopyPictures then
          begin
            CurrentLine := CurrentLine + ', ';
            CurrentLine := CurrentLine + strTagSqlFieldPicture;
          end;
          CurrentLine := CurrentLine + ') VALUES (';
        end;
        with FieldsList do
        begin
          MovieFieldFound := False; 
          if not bUseUpdate then
          begin
            CurrentLine := CurrentLine + QuotedStr(GetFieldValue(fieldNumber));
            MovieFieldFound := True;
          end;
          for iField := 0 to Count-1 do
          begin
            if not IsExtraField(FieldsList.Strings[ifield]) then
            begin
              if (iField > 0) or (not bUseUpdate) then
                CurrentLine := CurrentLine + ', ';
              if (Length(FieldsList.Strings[ifield]) > 0) and
                (FieldsList.Strings[ifield][1] in ['0'..'9']) then // movie field (Field Id)
              begin
                field := StrToIntDef(FieldsList.Strings[ifield], -1);
                if (field = fieldDate) and (DateMask <> '') and (iDate > 0) then
                  FieldValue := FormatDateTime(DateMask, iDate)
                else if (field = fieldDateWatched) and (DateMask <> '') and (iDateWatched > 0) then
                  FieldValue := FormatDateTime(DateMask, iDateWatched)
                else
                  FieldValue := GetFieldValue(field);
              end else // custom field (Custom Field Tag)
              begin
                FieldProperties := MovieList.CustomFieldsProperties.GetField(FieldsList.Strings[ifield]);
                if (FieldProperties <> nil) and (FieldProperties.FieldType = ftDate) and
                  (DateMask <> '') and (CustomFields.GetFieldValue(FieldsList.Strings[ifield]) <> '') then
                  FieldValue := FormatDateTime(DateMask, CustomFields.GetIntFieldValue(FieldsList.Strings[ifield]))
                else
                  FieldValue := CustomFields.GetFieldValue(FieldsList.Strings[ifield]);
              end;
              FieldValue := StringReplace(FieldValue, '\', '\\', [rfReplaceAll]);
              FieldValue := StringReplace(FieldValue, sLineBreak, ReplLinebr, [rfReplaceAll]);
              FieldValue := QuotedStr(FieldValue);
              if bUseUpdate then
                CurrentLine := CurrentLine + GetSQLName(FieldsList.Strings[ifield]) + ' = ' + FieldValue
              else
                CurrentLine := CurrentLine + FieldValue;
              MovieFieldFound := True;
            end;
          end;
        end;
        if bCopyPictures then
        begin
          ImageFileName := '';
          if (Picture.PicPath <> '') then
          begin
            if (PicDirWithBackslash = '') and bInPicDir then
            begin
              PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
              if SourceFile <> '' then
                SetCurrentDir(ExtractFilePath(SourceFile))
              else
                SetCurrentDir(strDirCatalogs);
            end;
            if Picture.PicStream <> nil then
            begin
              ImageFileName := GetExpFileName(Movie, nil);
              if ImageFileName <> '' then
                ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Picture.PicPath));
              if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
              if ImageFileName <> '' then
                if not bOnlyNewPictures or (bOnlyNewPictures and not FileExists(ImageFileName)) then
                  try
                    Picture.PicStream.SaveToFile(ImageFileName);
                  except
                    ImageFileName := '';
                  end;
            end
            else if FileExists(ExpandFileName(Picture.PicPath)) then
            begin
              ImageFileName := GetExpFileName(Movie, nil);
              if ImageFileName <> '' then
                ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Picture.PicPath)));
              if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
              if ImageFileName <> '' then
                CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageFileName), bOnlyNewPictures);
            end;
          end;
          if MovieFieldFound then
            CurrentLine := CurrentLine + ', ';
          if ImageFileName <> '' then
          begin
            FieldValue := PicDirWithBackslash + ExtractFileName(ImageFileName);
            FieldValue := StringReplace(FieldValue, '\', '/', [rfReplaceAll]);
            FieldValue := QuotedStr(FieldValue);
          end else
            FieldValue := QuotedStr('');
          if bUseUpdate then
            CurrentLine := Format('%s%s = %s', [CurrentLine, strTagSqlFieldPicture, FieldValue])
          else
            CurrentLine := Format('%s%s', [CurrentLine, FieldValue]);
        end;
        if bUseUpdate then
          CurrentLine := Format('%s WHERE %s = %d;', [CurrentLine, strTagSqlFields[fieldNumber], iNumber])
        else
          CurrentLine := CurrentLine + ');';
        Writeln(SQL, CurrentLine);

        if bExportExtras then
        begin
          if bUseUpdate then
          begin
            CurrentLine := Format('DELETE FROM %s WHERE %s = %d;', [TableNameExtras, strTagSqlExtraFieldRefMovieNumber, Movie.iNumber]);
            Writeln(SQL, CurrentLine);
          end;
          iExtra := 0;
          while (iExtra < Extras.Count) and (not FCancelExport) do
          begin
            Extra := Extras.Items[iExtra];
            CurrentLine := 'INSERT INTO '+ TableNameExtras +' (';
            CurrentLine := CurrentLine + strTagSqlExtraFields[extraFieldNumber - extraFieldLow];
            CurrentLine := CurrentLine + ', ';
            CurrentLine := CurrentLine + strTagSqlExtraFieldRefMovieNumber;
            for ifield := 0 to FieldsList.Count-1 do
            begin
              if IsExtraField(FieldsList.Strings[ifield]) then
              begin
                CurrentLine := CurrentLine + ', ';
                CurrentLine := CurrentLine + GetSQLName(FieldsList.Strings[ifield]);
              end;
            end;
            if bCopyPictures and bIncPicExtras then
            begin
              CurrentLine := CurrentLine + ', ';
              CurrentLine := CurrentLine + strTagSqlExtraFieldPicture;
            end;
            CurrentLine := CurrentLine + ') VALUES (';
            with FieldsList do
            begin
              CurrentLine := CurrentLine + QuotedStr(Extra.GetFieldValue(extraFieldNumber));
              CurrentLine := CurrentLine + ', ';
              CurrentLine := CurrentLine + QuotedStr(Movie.GetFieldValue(fieldNumber));
              for iField := 0 to Count-1 do
              begin
                if IsExtraField(FieldsList.Strings[ifield]) then
                begin
                  CurrentLine := CurrentLine + ', ';
                  if (Length(FieldsList.Strings[ifield]) > 0) and
                    (FieldsList.Strings[ifield][1] in ['0'..'9']) then // extra field (Field Id)
                  begin
                    field := StrToIntDef(FieldsList.Strings[ifield], -1);
                    FieldValue := Extra.GetFieldValue(field);
                    FieldValue := StringReplace(FieldValue, '\', '\\', [rfReplaceAll]);
                    FieldValue := StringReplace(FieldValue, sLineBreak, ReplLinebr, [rfReplaceAll]);
                    FieldValue := QuotedStr(FieldValue);
                  end else
                    FieldValue := QuotedStr('');
                  CurrentLine := CurrentLine + FieldValue;
                end;
              end;
            end;
            if bCopyPictures and bIncPicExtras then
            begin
              ImageFileName := '';
              if (Extra.Picture.PicPath <> '') then
              begin
                if (PicDirWithBackslash = '') and bInPicDir then
                begin
                  PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
                  if SourceFile <> '' then
                    SetCurrentDir(ExtractFilePath(SourceFile))
                  else
                    SetCurrentDir(strDirCatalogs);
                end;
                if Extra.Picture.PicStream <> nil then
                begin
                  ImageFileName := GetExpFileName(Movie, Extra);
                  if ImageFileName <> '' then
                    ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Extra.Picture.PicPath));
                  if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                    ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
                  if ImageFileName <> '' then
                    if not bOnlyNewPictures or (bOnlyNewPictures and not FileExists(ImageFileName)) then
                      try
                        Extra.Picture.PicStream.SaveToFile(ImageFileName);
                      except
                        ImageFileName := '';
                      end;
                end
                else if FileExists(ExpandFileName(Extra.Picture.PicPath)) then
                begin
                  ImageFileName := GetExpFileName(Movie, Extra);
                  if ImageFileName <> '' then
                    ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Extra.Picture.PicPath)));
                  if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
                    ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
                  if ImageFileName <> '' then
                    CopyFile(PChar(ExpandFileName(Extra.Picture.PicPath)), PChar(ImageFileName), bOnlyNewPictures);
                end;
              end;
              CurrentLine := CurrentLine + ', ';
              if ImageFileName <> '' then
              begin
                FieldValue := PicDirWithBackslash + ExtractFileName(ImageFileName);
                FieldValue := StringReplace(FieldValue, '\', '/', [rfReplaceAll]);
                FieldValue := QuotedStr(FieldValue);
              end else
                FieldValue := QuotedStr('');
              CurrentLine := Format('%s%s', [CurrentLine, FieldValue]);
            end;
            CurrentLine := CurrentLine + ');';
            Writeln(SQL, CurrentLine);
            Inc(iExtra);
          end;
        end;
        ProgressWin.StepIt;
      end;
    end;
    Inc(iMovie);
    Application.ProcessMessages;
  end;
  Closefile(SQL);
  FieldsList.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ExportToImages;
var
  Path: string;
  i, j: Integer;
  Movie: TMovie;
  IncOpt: TMovieIncludeOption;
  IncPicOpt: TPictureIncludeOption;

  procedure SavePicture(Picture: TMoviePicture; AMovie: TMovie; AExtra: TMovieExtra);
  var
    OriginalName, Ext, ImageName: string;
  begin
    if (Picture.PicPath <> '') then
    begin
      Ext := ExtractFileExt(Picture.PicPath);
      OriginalName := '';
      if Picture.PicStream = nil then
        OriginalName := Picture.PicPath;
      ImageName := Settings.rExport.PictureNaming.GetFileName(SourceFile, DestFile,
        OriginalName, Ext, AMovie, AExtra, FMaxMovieNumber, AMovie.Extras.Count);
      ImageName := Path + ImageName;
      if Picture.PicStream <> nil then
      begin
        try
          Picture.PicStream.SaveToFile(ImageName);
        except
        end;
      end else
      begin
        try
          if SourceFile <> '' then
            SetCurrentDir(ExtractFilePath(SourceFile))
          else
            SetCurrentDir(strDirCatalogs);
          CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageName), false);
        except
        end;
      end;
    end;
  end;
begin
  Path := ExtractFilePath(DestFile);
  IncOpt := Includemov.ItemIndex;
  IncPicOpt := Includepic.ItemIndex;
  ProgressWin.Status := Format(Messages.Strings[msgExporting],[Path]);
  ProgressWin.OnCancel := OnCancelExport;
  PictureNaming.SaveToObject(Settings.rExport.PictureNaming);
  i := 0;
  while (i < MovieList.Count) and (not FCancelExport) do
  begin
    Movie := MovieList.Items[i];
    with Movie do
      if CanInclude(IncOpt) then
      begin
        if (IncPicOpt = pioAll) or (IncPicOpt = pioMovie) then
          SavePicture(Movie.Picture, Movie, nil);
        j := 0;
        if (IncPicOpt = pioAll) or (IncPicOpt = pioExtras) then
          while (j < Movie.Extras.Count) and (not FCancelExport) do
          begin
            SavePicture(Movie.Extras.Items[j].Picture, Movie, Movie.Extras.Items[j]);
            Inc(j);
          end;
        ProgressWin.StepIt;
      end;
    Inc(i);
    Application.ProcessMessages;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ExportToXmlOrAmc(ToXml: Boolean; Version: Integer);
var
  OtherList: TMovieList;
  i: Integer;
  IncOpt: TMovieIncludeOption;
begin
  IncOpt := Includemov.ItemIndex;
  if ToXml then
    ProgressWin.Status := Format(Messages.Strings[msgExporting], ['XML'])
  else
    ProgressWin.Status := Format(Messages.Strings[msgExporting], ['AMC']);
  ProgressWin.Maximum := 0;

  OtherList := TMovieList.Create;
  try
    OtherList.MovieProperties.Assign(MovieList.MovieProperties);
    OtherList.CustomFieldsProperties.Assign(MovieList.CustomFieldsProperties);
    for i := 0 to MovieList.Count - 1 do
      if MovieList[i].CanInclude(IncOpt) then
        with OtherList.Add do
        begin
          Assign(Self.MovieList[i], True, True, True, True, True);
        end;
    if ToXml then
      OtherList.SaveToXML(SourceFile, DestFile, Version, False,
        PictureOperationExportXML.Selected, ExtraPictureOperationExportXML.Selected)
    else
      OtherList.SaveToFile(SourceFile, DestFile, Version,
        PictureOperationExportAMC.Selected, PictureOperationExportAMC.Selected);
  finally
    OtherList.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ExportToHTML;
var
  Page, Part, Output, LineBreak, TemplatePath: string;
  i, EndPos, RecNr: Integer;
  ExportPic, InPicDir, IncPicExtras, OnlyNewPic, bStepIt: Boolean;
  IncOpt: TMovieIncludeOption;
  HTML: TextFile;
  PicDirWithBackslash: string;
begin
  HTMLTemplateEdit1.HTMLStoreTemplate;

  Output := '';
  ExportPic := CBCopyPictures.Checked;
  InPicDir := CBCopyPicturesInPicDir.Checked;
  PicDirWithBackslash := '';
  OnlyNewPic := CBCopyPicturesNew.Checked;
  IncPicExtras := CBCopyPicturesIncExtras.Checked;
  IncOpt := Includemov.ItemIndex;
  LineBreak := Settings.rOptions.rExport.Linebreak;
  TemplatePath := '';
  bStepIt := False;

  ProgressWin.Status := Format(Messages.Strings[msgExporting],['HTML']);
  if (HTMLTemplateEdit1.btnHTMLExport.Action <> HTMLTemplateEdit1.ActionExportSelected) then
    ProgressWin.Maximum := ProgressWin.Maximum * 2;
  ProgressWin.Maximum := ProgressWin.Maximum + 1;
  ProgressWin.OnCancel := OnCancelExport;

  Page := HTMLTemplateEdit1.FHTMLFullDoc.Text;
  if (((HTMLTemplateEdit1.btnHTMLExport.Action = HTMLTemplateEdit1.ActionExportSelected) and
    (HTMLTemplateEdit1.ActionDisplayFull.Checked)) or
    (HTMLTemplateEdit1.btnHTMLExport.Action <> HTMLTemplateEdit1.ActionExportSelected)) and
    (not IsReallyEmpty(Page)) then
  begin
    if ExportPic and (PicDirWithBackslash = '') and InPicDir then
      if (Pos(TAG_ITEMPICTURE, Page) <> 0) or (IncPicExtras and
        ((Pos(TAG_ITEMEXTRAPICTURE, Page) <> 0) or (Pos(TAG_ITEMEXTRAPICFILENAME, Page) <> 0))) then
        PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
    SetCurrentDir(strDirTemplates);
    TemplatePath := ExtractFilePath(HTMLTemplateEdit1.FHTMLFullFile.CurrentFile);
    if (not SameFileName(TemplatePath + ExtractFileName(DestFile), DestFile)) then
    begin
      if (Pos(TAG_ITEMAPPR10, Page) <> 0) or (Pos(TAG_ITEMUSERAPPR10, Page) <> 0) then
        CopyAllFiles(TemplatePath + 'appr10_*.gif', ExtractFilePath(DestFile));
      if (Pos(TAG_ITEMAPPRECIATION, Page) <> 0) or (Pos(TAG_ITEMUSERAPPR4, Page) <> 0) then
        CopyAllFiles(TemplatePath + 'appr?.gif', ExtractFilePath(DestFile));
    end;
    if SourceFile <> '' then
      SetCurrentDir(ExtractFilePath(SourceFile))
    else
      SetCurrentDir(strDirCatalogs);

    AssignFile(HTML, DestFile);
    Rewrite(HTML);
    ReplaceTagsGeneral(Page, LineBreak);
    while Length(Page) > 0 do
    begin
      if Pos(TAG_ITEMBEGIN, Page) = 1 then
      begin
        Delete(Page, 1, Length(TAG_ITEMBEGIN));
        EndPos := Pos(TAG_ITEMEND, Page);
        if EndPos = 0 then
          EndPos := Length(Page) + 1;
        RecNr := 1;
        with MovieList do
        begin
          i := 0;
          while (i < Count) and (not FCancelExport) do
          begin
            if Items[i].CanInclude(IncOpt) then
            begin
              Part := Copy(Page, 1, EndPos-1);
              ReplaceTagsMovie(Part, Items[i], ExportPic, OnlyNewPic,
                IncPicExtras, PicDirWithBackslash, LineBreak, RecNr);
              Inc(RecNr);
              Output := Output + Part;
              // We write the string in file here to avoid to have
              // a too long string and an "Out of memory" exception !
              Write(HTML, Output);
              Output := '';
              if not bStepIt then
                ProgressWin.StepIt;
            end;
            Inc(i);
            Application.ProcessMessages;
          end;
        end;
        if EndPos <> (Length(Page) + 1) then
          Inc(EndPos, Length(TAG_ITEMEND));
        bStepIt := True;
      end else
      begin
        EndPos := Pos(TAG_ITEMBEGIN, Page);
        if EndPos = 0 then
          EndPos := Length(Page) + 1;
        Output := Output + Copy(Page, 1, EndPos-1);
      end;
      Delete(Page, 1, EndPos-1);
    end;
    WriteLn(HTML, Output);
    CloseFile(HTML);
  end;
  Page := HTMLTemplateEdit1.FHTMLIndivDoc.Text;
  RecNr := 1;
  if (((HTMLTemplateEdit1.btnHTMLExport.Action = HTMLTemplateEdit1.ActionExportSelected) and
    (HTMLTemplateEdit1.ActionDisplayIndividual.Checked)) or
    (HTMLTemplateEdit1.btnHTMLExport.Action <> HTMLTemplateEdit1.ActionExportSelected)) and
    (not IsReallyEmpty(Page)) then
  begin
    if ExportPic and (PicDirWithBackslash = '') and InPicDir then
      if (Pos(TAG_ITEMPICTURE, Page) <> 0) or (IncPicExtras and
        ((Pos(TAG_ITEMEXTRAPICTURE, Page) <> 0) or (Pos(TAG_ITEMEXTRAPICFILENAME, Page) <> 0))) then
        PicDirWithBackslash := GetCatalogPicDir(DestFile, True) + '\';
    SetCurrentDir(strDirTemplates);
    TemplatePath := ExtractFilePath(HTMLTemplateEdit1.FHTMLIndivFile.CurrentFile);
    if (not SameFileName(TemplatePath + ExtractFileName(DestFile), DestFile)) then
    begin
      if (Pos(TAG_ITEMAPPR10, Page) <> 0) or (Pos(TAG_ITEMUSERAPPR10, Page) <> 0) then
        CopyAllFiles(TemplatePath + 'appr10_*.gif', ExtractFilePath(DestFile));
      if (Pos(TAG_ITEMAPPRECIATION, Page) <> 0) or (Pos(TAG_ITEMUSERAPPR4, Page) <> 0) then
        CopyAllFiles(TemplatePath + 'appr?.gif', ExtractFilePath(DestFile));
    end;
    if SourceFile <> '' then
      SetCurrentDir(ExtractFilePath(SourceFile))
    else
      SetCurrentDir(strDirCatalogs);

    with MovieList do
    begin
      i := 0;
      while (i < Count) and (not FCancelExport) do
      begin
        if Items[i].CanInclude(IncOpt) then
        begin
          AssignFile(HTML, GetExpFileName(Items[i], nil));
          Rewrite(HTML);
          Output := Page;
          ReplaceTagsGeneral(Output, LineBreak);
          ReplaceTagsMovie(Output, Items[i], ExportPic, OnlyNewPic,
            IncPicExtras, PicDirWithBackslash, LineBreak, RecNr);
          Inc(RecNr);
          WriteLn(HTML, Output);
          CloseFile(HTML);
          ProgressWin.StepIt;
        end;
        Inc(i);
        Application.ProcessMessages;
      end;
    end;
  end;
  ProgressWin.IntProgress := ProgressWin.Maximum;
end;

{-------------------------------------------------------------------------------
   HTML stuff
-------------------------------------------------------------------------------}

procedure TExportWin.ReplaceTagsGeneral(var Page: string; const LineBreak: string);
var
  i, c: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  Page := StringReplace(Page, TAG_FILENAME, ExtractFileName(SourceFile),[rfReplaceAll]);
  Page := StringReplace(Page, TAG_FILEPATH, SourceFile,[rfReplaceAll]);
  Page := StringReplace(Page, TAG_TOTALMOVIES, IntToStr(MovieList.Count(Includemov.ItemIndex)),[rfReplaceAll]);
  if Pos(TAG_TOTALDISKS, Page) > 0 then
  begin
    c := 0;
    for i := 0 to MovieList.Count-1 do
      if MovieList.Items[i].CanInclude(Includemov.ItemIndex) then
        Inc(c, MovieList.Items[i].iDisks);
    Page := StringReplace(Page, TAG_TOTALDISKS, IntToStr(c), [rfReplaceAll]);
  end;
  Page := StringReplace(Page, TAG_DATE, DateToStr(Date),[rfReplaceAll]);
  Page := StringReplace(Page, TAG_TIME, TimeToStr(Time),[rfReplaceAll]);
  with MovieList.MovieProperties do
  begin
    Page := StringReplace(Page, TAG_OWNERNAME, strName,[rfReplaceAll]);
    Page := StringReplace(Page, TAG_OWNERMAIL, strMail,[rfReplaceAll]);
    Page := StringReplace(Page, TAG_OWNERSITE, strSite,[rfReplaceAll]);
    Page := StringReplace(Page, TAG_DESCRIPTION, IfThen(LineBreak <> '', StringReplace(strDescription, #13#10, LineBreak, [rfReplaceAll]), strDescription), [rfReplaceAll]);
  end;
  
  // Replace field labels
  Page := StringReplace(Page, TAG_LABELNUMBER, strFields.Strings[fieldNumber], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCHECKED, strFields.Strings[fieldChecked], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCOLORTAG, strFields.Strings[fieldColorTag], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELMEDIA, strFields.Strings[fieldMedia], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELTYPE, strFields.Strings[fieldMediaType], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELSOURCE, strFields.Strings[fieldSource], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELDATEADD, strFields.Strings[fieldDate], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELBORROWER, strFields.Strings[fieldBorrower], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELDATEWATCHED, strFields.Strings[fieldDateWatched], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELUSERRATING, strFields.Strings[fieldUserRating], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELRATING, strFields.Strings[fieldRating], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELORIGINALTITLE, strFields.Strings[fieldOriginalTitle], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELTRANSLATEDTITLE, strFields.Strings[fieldTranslatedTitle], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELFORMATTEDTITLE, strFields.Strings[fieldFormattedTitle], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELDIRECTOR, strFields.Strings[fieldDirector], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELPRODUCER, strFields.Strings[fieldProducer], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELWRITER, strFields.Strings[fieldWriter], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCOMPOSER, strFields.Strings[fieldComposer], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELACTORS, strFields.Strings[fieldActors], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCOUNTRY, strFields.Strings[fieldCountry], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELYEAR, strFields.Strings[fieldYear], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELLENGTH, strFields.Strings[fieldLength], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCATEGORY, strFields.Strings[fieldCategory], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCERTIFICATION, strFields.Strings[fieldCertification], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELURL, strFields.Strings[fieldURL], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELDESCRIPTION, strFields.Strings[fieldDescription], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELCOMMENTS, strFields.Strings[fieldComments], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELFILEPATH, strFields.Strings[fieldFilePath], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELVIDEOFORMAT, strFields.Strings[fieldVideoFormat], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELVIDEOBITRATE, strFields.Strings[fieldVideoBitrate], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELAUDIOFORMAT, strFields.Strings[fieldAudioFormat], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELAUDIOBITRATE, strFields.Strings[fieldAudioBitrate], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELRESOLUTION, strFields.Strings[fieldResolution], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELFRAMERATE, strFields.Strings[fieldFramerate], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELLANGUAGES, strFields.Strings[fieldLanguages], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELSUBTITLES, strFields.Strings[fieldSubtitles], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELSIZE, strFields.Strings[fieldSize], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELDISKS, strFields.Strings[fieldDisks], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELNBEXTRAS, strFields.Strings[fieldNbExtras], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELPICTURE, HTMLTemplateEdit1.MnuLabPic.Caption, [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELAUDIOKBPS, MainWindow.FrmMovie.LAudioKbps.Caption, [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELVIDEOKBPS, MainWindow.FrmMovie.LVideoKbps.Caption, [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELFPS, MainWindow.FrmMovie.LFramerateFPS.Caption, [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELUNIT, MainWindow.FrmMovie.LSizeUnit.Caption, [rfReplaceAll]);

  // Replace custom field labels
  with MovieList.CustomFieldsProperties do
    for i:= Count-1 downto 0 do
    begin
      FieldProperties := Objects[i];
      Page := StringReplace(Page, TAG_LABEL_CF + UpperCase(FieldProperties.FieldTag),
        FieldProperties.FieldName, [rfReplaceAll]);
    end;
    
  // Replace extra field labels
  Page := StringReplace(Page, TAG_LABELEXTRANUMBER, strExtraFields.Strings[extraFieldNumber - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRACHECKED, strExtraFields.Strings[extraFieldChecked - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRATAG, strExtraFields.Strings[extraFieldTag - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRATITLE, strExtraFields.Strings[extraFieldTitle - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRACATEGORY, strExtraFields.Strings[extraFieldCategory - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRAURL, strExtraFields.Strings[extraFieldURL - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRADESCRIPTION, strExtraFields.Strings[extraFieldDescription - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRACOMMENTS, strExtraFields.Strings[extraFieldComments - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRACREATEDBY, strExtraFields.Strings[extraFieldCreatedBy - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRAPICSTATUS, strExtraFields.Strings[extraFieldPictureStatus - extraFieldLow], [rfReplaceAll]);
  Page := StringReplace(Page, TAG_LABELEXTRAPICTURE, HTMLTemplateEdit1.MnuLabEPic.Caption, [rfReplaceAll]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ReplaceTagsMovie(var Page: string; const AMovie: TMovie;
  const ExportPic, OnlyNewPic, IncPicExtras: Boolean; const PicDirWithBackslash: string;
  const LineBreak: string; const RecNr: Integer);
var
  ImageFileName: string;
  i: integer;
  FieldProperties: TCustomFieldProperties;
begin
  if AMovie <> nil then
  begin
    with AMovie do
    begin
      Page := StringReplace(Page, TAG_RECNR, IntToStr(RecNr), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMNUMBER, GetFieldValue(fieldNumber), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCHECKED, IfThen(bChecked, 'x', ' '), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCOLORTAG, IntToStr(iColorTag), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCOLORHTML,
        ConvertColorToHTML(Settings.rOptions.rMovieList.ColorsTag[iColorTag]), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMTYPE, strMediaType, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMMEDIA, strMedia, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMSOURCE, strSource, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMDATEADD, GetFieldValue(fieldDate, True), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMBORROWER, strBorrower, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMDATEWATCHED, GetFieldValue(fieldDateWatched, True), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMORIGINALTITLE, strOriginalTitle, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMTRANSLATEDTITLE, strTranslatedTitle, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFORMATTEDTITLE1, GetFormattedTitle(2, False, ''), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFORMATTEDTITLE2, GetFormattedTitle(3, False, ''), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFORMATTEDTITLE, GetFormattedTitle, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMDIRECTOR, strDirector, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMPRODUCER, strProducer, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMWRITER, strWriter, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCOMPOSER, strComposer, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMACTORS, IfThen(LineBreak <> '', StringReplace(strActors, #13#10, LineBreak, [rfReplaceAll]), strActors), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCOUNTRY, strCountry, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMYEAR, GetFieldValue(fieldYear), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMLENGTH, GetFieldValue(fieldLength), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCATEGORY, strCategory, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCERTIFICATION, strCertification, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMURL, strURL, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMCOMMENTS, IfThen(LineBreak <> '', StringReplace(strComments, #13#10, LineBreak, [rfReplaceAll]), strComments), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMDESCRIPTION, IfThen(LineBreak <> '', StringReplace(strDescription, #13#10, LineBreak, [rfReplaceAll]), strDescription), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFILEPATH, strFilePath, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFORMAT, strVideoFormat, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMVIDEOFORMAT, strVideoFormat, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMAUDIOFORMAT, strAudioFormat, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMVIDEOBITRATE, GetFieldValue(fieldVideoBitrate), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMAUDIOBITRATE, GetFieldValue(fieldAudioBitrate), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMRESOLUTION, strResolution, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMFRAMERATE, strFramerate, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMSIZE, strSize, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMLANGUAGES, strLanguages, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMSUBTITLES, strSubtitles, [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMDISKS, GetFieldValue(fieldDisks), [rfReplaceAll]);
      Page := StringReplace(Page, TAG_ITEMNBEXTRAS, GetFieldValue(fieldNbExtras), [rfReplaceAll]);

      if iUserRating > -1 then
      begin
        i := Round(iUserRating/10.0);
        Page := StringReplace(Page, TAG_ITEMUSERRATING10, IntToStr(i), [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMUSERAPPR10, Format('<img src="appr10_%d.gif" alt="%d/10" />', [i, i]), [rfReplaceAll]);
        i := 0;
        case iUserRating of
           0..29:  i := 0;
          30..49:  i := 1;
          50..69:  i := 2;
          70..89:  i := 3;
          90..100: i := 4;
        end;
        Page := StringReplace(Page, TAG_ITEMUSERRATING4, IntToStr(i), [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMUSERAPPR4, Format('<img src="appr%d.gif" alt="%d/4" />', [i, i]), [rfReplaceAll]);
      end else
      begin
        Page := StringReplace(Page, TAG_ITEMUSERRATING10, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMUSERRATING4, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMUSERAPPR10, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMUSERAPPR4, '', [rfReplaceAll]);
      end;
      Page := StringReplace(Page, TAG_ITEMUSERRATING, GetFieldValue(fieldUserRating, True), [rfReplaceAll]);
      
      if iRating > -1 then
      begin
        i := Round(iRating/10.0);
        Page := StringReplace(Page, TAG_ITEMRATING10, IntToStr(i), [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMAPPR10, Format('<img src="appr10_%d.gif" alt="%d/10" />', [i, i]), [rfReplaceAll]);
        i := 0;
        case iRating of
           0..29:  i := 0;
          30..49:  i := 1;
          50..69:  i := 2;
          70..89:  i := 3;
          90..100: i := 4;
        end;
        Page := StringReplace(Page, TAG_ITEMRATING4, IntToStr(i), [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMAPPRECIATION, Format('<img src="appr%d.gif" alt="%d/4" />', [i, i]), [rfReplaceAll]);
      end else
      begin
        Page := StringReplace(Page, TAG_ITEMRATING10, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMRATING4, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMAPPR10, '', [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMAPPRECIATION, '', [rfReplaceAll]);
      end;
      Page := StringReplace(Page, TAG_ITEMRATING, GetFieldValue(fieldRating, True), [rfReplaceAll]);

      if Pos(TAG_ITEMPICTURE, Page) > 0 then
      begin
        ImageFileName := '';
        if Picture.PicPath <> '' then
        begin
          if Picture.PicStream <> nil then
          begin
            ImageFileName := GetExpFileName(AMovie, nil);
            if ImageFileName <> '' then
              ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Picture.PicPath));
            if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
              ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
            if (ImageFileName <> '') and ExportPic then
              try
                if (not OnlyNewPic) or ((OnlyNewPic) and (not FileExists(ImageFileName))) then
                  Picture.PicStream.SaveToFile(ImageFileName);
              except
              end;
          end
          else if FileExists(ExpandFileName(Picture.PicPath)) then
          begin
            ImageFileName := GetExpFileName(AMovie, nil);
            if ImageFileName <> '' then
              ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Picture.PicPath)));
            if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
              ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
            if (ImageFileName <> '') and ExportPic then
              CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageFileName), OnlyNewPic);
          end;
        end;
        if ImageFileName <> '' then
        begin
          ImageFileName := PicDirWithBackslash + ExtractFileName(ImageFileName);
          ImageFileName := StringReplace(ImageFileName, '\', '/', [rfReplaceAll]);
        end;
        Page := StringReplace(Page, TAG_ITEMPICTUREFILENAMENP, ImageFileName, [rfReplaceAll]);
        Page := StringReplace(Page, TAG_ITEMPICTUREFILENAME, ImageFileName, [rfReplaceAll]);
        if ImageFileName <> '' then
        begin
          Page := StringReplace(Page, TAG_ITEMPICTURENP, Format('<img src="%s" alt="pic_movie_%d"%s />',
            [ImageFileName, iNumber, FHTMLPicAttr]), [rfReplaceAll]);
          Page := StringReplace(Page, TAG_ITEMPICTURE, Format('<img src="%s" alt="pic_movie_%d"%s />',
            [ImageFileName, iNumber, FHTMLPicAttr]), [rfReplaceAll]);
        end
        else
        begin
          Page := StringReplace(Page, TAG_ITEMPICTURENP, '', [rfReplaceAll]);
          Page := StringReplace(Page, TAG_ITEMPICTURE, '', [rfReplaceAll]);
        end;
      end;

      with MovieList.CustomFieldsProperties do
        for i:= Count-1 downto 0 do
        begin
          FieldProperties := Objects[i];
          Page := StringReplace(Page, TAG_ITEM_CF + UpperCase(FieldProperties.FieldTag),
            AMovie.CustomFields.GetFieldValue(Strings[i], True), [rfReplaceAll]);
        end;

      if Pos(TAG_ITEMFILEINDIV, Page) > 0 then
        Page := StringReplace(Page, TAG_ITEMFILEINDIV, ExtractFileName(GetExpFileName(AMovie, nil)), [rfReplaceAll]);
        
      ReplaceTagsExtras(Page, AMovie, ExportPic, OnlyNewPic, IncPicExtras, PicDirWithBackslash, LineBreak);
    end; // with
  end; // if <> nil
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ReplaceTagsExtras(var Page: string; const AMovie: TMovie;
  const ExportPic, OnlyNewPic, IncPicExtras: Boolean; const PicDirWithBackslash: string;
  const LineBreak: string);
var
  Output, Part, Category, Checked, tmp: string;
  ExtraRecNr, NrStart, NrEnd: Integer;
  EndPos, p, i: Integer;
  bChecked: Boolean;
begin
  while Length(Page) > 0 do
  begin
    if Pos(TAG_ITEMEXTRABEGIN, Page) = 1 then
    begin
      Delete(Page, 1, Length(TAG_ITEMEXTRABEGIN));

      Category := '';
      Checked := '';
      bChecked := False;
      NrStart := 1;
      NrEnd := AMovie.Extras.Count;
      if Page[1] = '(' then
      begin
        p := Pos(')', Page);
        if p > 0 then
        begin
          Category := Trim(Copy(Page, 2, p-2));
          Delete(Page, 1, p);
          i := Pos(',', Category);
          if i > 0 then
          begin
            Checked := Trim(Copy(Category, i+1, Length(Category)-i));
            Category := Trim(Copy(Category, 1, i-1));
            i := Pos(',', Checked);
            if i > 0 then
            begin
              tmp := Trim(Copy(Checked, i+1, Length(Checked)-i));
              Checked := Trim(Copy(Checked, 1, i-1));
              i := Pos(',', tmp);
              if i > 0 then
              begin
                NrStart := StrToIntDef(Trim(Copy(tmp, 1, i-1)), NrStart);
                NrEnd := StrToIntDef(Trim(Copy(tmp, i+1, Length(tmp)-i)), NrEnd);
              end else
                NrStart := StrToIntDef(tmp, NrStart);
            end;
            if (Checked <> '') then
              bChecked := not ((Checked[1] = '0') or (Checked[1] = 'f') or (Checked[1] = 'F'));
          end;
        end;
      end;
      
      EndPos := Pos(TAG_ITEMEXTRAEND, Page);
      if EndPos = 0 then
        EndPos := Length(Page) + 1;

      ExtraRecNr := 1;
      with AMovie.Extras do
      begin
        i := 0;
        while (i < Count) and (not FCancelExport) do
        begin
          if ((Category = '') or Items[i].InCategory(Category)) and
           ((Checked = '') or (Items[i].bChecked = bChecked)) then
          begin
            if (ExtraRecNr >= NrStart) and (ExtraRecNr <= NrEnd) then
            begin
              Part := Copy(Page, 1, EndPos-1);
              ReplaceTagsExtra(Part, AMovie, Items[i], ExportPic, OnlyNewPic,
                IncPicExtras, PicDirWithBackslash, LineBreak, ExtraRecNr);
              Output := Output + Part;
            end;
            Inc(ExtraRecNr);
          end;
          Inc(i);
        end;
      end;
      if EndPos <> (Length(Page) + 1) then
        Inc(EndPos, Length(TAG_ITEMEXTRAEND));
    end else
    begin
      EndPos := Pos(TAG_ITEMEXTRABEGIN, Page);
      if EndPos = 0 then
        EndPos := Length(Page) + 1;
      Part := Copy(Page, 1, EndPos-1);
      ReplaceTagsExtra(Part, AMovie, nil, ExportPic, OnlyNewPic,
        IncPicExtras, PicDirWithBackslash, LineBreak, 0);
      Output := Output + Part;
    end;
    Delete(Page, 1, EndPos-1);
  end;
  Page := Output;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.ReplaceTagsExtra(var Page: string; const AMovie: TMovie;
  const AExtra: TMovieExtra; const ExportPic, OnlyNewPic, IncPicExtras: Boolean;
  const PicDirWithBackslash: string; const LineBreak: string; const ExtraRecNr: Integer);

  function GetValue(tag: string; extra: TMovieExtra; var value: string): Boolean;
  var
    ImageFileName: string;
  begin
    Result := False;
    if extra = nil then
      exit;
    Result := True;
    with extra do
      if tag = TAG_ITEMEXTRARECNR then value := IntToStr(ExtraRecNr)
      else if tag = TAG_ITEMEXTRANUMBER then value := GetFieldValue(extraFieldNumber)
      else if tag = TAG_ITEMEXTRACHECKED then value := IfThen(bChecked, 'x', ' ')
      else if tag = TAG_ITEMEXTRATAG then value := strTag
      else if tag = TAG_ITEMEXTRATITLE then value := strTitle
      else if tag = TAG_ITEMEXTRACATEGORY then value := strCategory
      else if tag = TAG_ITEMEXTRAURL then value := strUrl
      else if tag = TAG_ITEMEXTRADESCRIPTION then value := IfThen(LineBreak <> '', StringReplace(strDescription, #13#10, LineBreak, [rfReplaceAll]), strDescription)
      else if tag = TAG_ITEMEXTRACOMMENTS then value := IfThen(LineBreak <> '', StringReplace(strComments, #13#10, LineBreak, [rfReplaceAll]), strComments)
      else if tag = TAG_ITEMEXTRACREATEDBY then value := strCreatedBy
      else if tag = TAG_ITEMEXTRAPICSTATUS then value := GetFieldValue(extraFieldPictureStatus)
      else if (tag = TAG_ITEMEXTRAPICTURENP) or (tag = TAG_ITEMEXTRAPICTURE) or
        (tag = TAG_ITEMEXTRAPICFILENAMENP) or (tag = TAG_ITEMEXTRAPICFILENAME) then
      begin
        ImageFileName := '';
        if Picture.PicPath <> '' then
        begin
          if Picture.PicStream <> nil then
          begin
            ImageFileName := GetExpFileName(AMovie, extra);
            if ImageFileName <> '' then
              ImageFileName := ChangeFileExt(ImageFileName, LowerCase(Picture.PicPath));
            if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
              ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
            if (ImageFileName <> '') and ExportPic and IncPicExtras then
              try
                if (not OnlyNewPic) or ((OnlyNewPic) and (not FileExists(ImageFileName))) then
                  Picture.PicStream.SaveToFile(ImageFileName);
              except
              end;
          end
          else if FileExists(ExpandFileName(Picture.PicPath)) then
          begin
            ImageFileName := GetExpFileName(AMovie, extra);
            if ImageFileName <> '' then
              ImageFileName := ChangeFileExt(ImageFileName, LowerCase(ExtractFileExt(Picture.PicPath)));
            if (ImageFileName <> '') and (PicDirWithBackslash <> '') then
              ImageFileName := ExtractFilePath(ImageFileName) + PicDirWithBackslash + ExtractFileName(ImageFileName);
            if (ImageFileName <> '') and ExportPic and IncPicExtras then
              CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(ImageFileName), OnlyNewPic);
          end;
        end;
        if ImageFileName <> '' then
        begin
          ImageFileName := PicDirWithBackslash + ExtractFileName(ImageFileName);
          ImageFileName := StringReplace(ImageFileName, '\', '/', [rfReplaceAll]);
        end;
        if (tag = TAG_ITEMEXTRAPICFILENAMENP) or (tag = TAG_ITEMEXTRAPICFILENAME) then
          value := ImageFileName
        else
          if ImageFileName <> '' then
            value := Format('<img src="%s" alt="pic_extra_%d_%d"%s />', [ImageFileName, AMovie.iNumber, iNumber, FHTMLExtraPicAttr])
          else
            value := '';
      end else
        Result := False;
  end;

var
  i, j, k, t, lastPos, idx: integer;
  ATag, Value, Output, tmp : string;
  Found, Found2 : Boolean;
begin
  i := 1;
  lastPos := 1;
  Output := '';
  if Page = '' then
    exit;
  while(Page[i] <> #0) do
  begin
    if (Page[i] = '$') and (Page[i+1] = '$') then
    begin
      // Fields
      Found := False;
      t := 0;
      while (not Found) and (t < strListExtraTags.Count) do
      begin
        ATag := strListExtraTags.Strings[t];
        j := 1;
        while (not Found) and (Page[i+j-1] <> #0) and (ATag[j] <> #0) do
        begin
          if (Page[i+j-1] <> ATag[j]) then
            break;
          if (ATag[j+1] = #0) then
          begin
            if (i <> lastPos) then
              Output := Output + Copy(Page, lastPos, i-lastPos);
            if Page[i+j] = '(' then
            begin
              k := 1;
              Found2 := False;
              while (not Found2) and (Page[i+j+k] <> #0) do
              begin
                if Page[i+j+k] = ')' then
                begin
                  tmp := Trim(Copy(Page, i+j+1, k-1));
                  if tmp <> '' then
                  begin
                    idx := AMovie.Extras.FindExtra(tmp);
                    if idx <> -1 then
                    begin
                      Value := ATag+'('+tmp+')';
                      GetValue(ATag, AMovie.Extras.Items[idx], Value);
                      Output := Output + Value;
                    end;
                  end else
                  begin
                    Value := ATag+'()';
                    GetValue(ATag, AExtra, Value);
                    Output := Output + Value;
                  end;
                  Found2 := True;
                end;
                Inc(k);
              end;
              if Found2 then
                lastPos := i+j+k
              else
              begin
                Value := ATag;
                GetValue(ATag, AExtra, Value);
                Output := Output + Value;
                lastPos := i+j;
              end;
            end else
            begin
              Value := ATag;
              GetValue(ATag, AExtra, Value);
              Output := Output + Value;
              lastPos := i+j;
            end;
            i := lastPos-1; // i is incremented by 1 after
            Found := True;
          end;
          Inc(j)
        end;
        Inc(t);
      end; // End while
    end;
    Inc(i);
  end;
  if (i <> lastPos) then
  begin
    Output := Output + Copy(Page, lastPos, i-lastPos);
  end;
  Page := Output;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExportWin.GetExpFileName(const AMovie: TMovie; const AExtra: TMovieExtra): string;
var
  OriginalName, Ext: string;
  c, i: Integer;
begin
  Ext := FExpFileExt;
  OriginalName := '';
  if AExtra = nil then
  begin
    if (AMovie.Picture.PicStream = nil) and (AMovie.Picture.PicPath <> '') then
      OriginalName := AMovie.Picture.PicPath;
    Result := FExpFileNaming.GetFileName(SourceFile, DestFile, OriginalName, Ext,
      AMovie, nil, AMovie.MovieList.MaxNumber(True));
    c := 1;
    i := FExpFileNames.IndexOf(Result);
    if (i <> -1) and (FExpFileNames.Objects[i] <> AMovie) then
    begin
      i := FExpFileNames.IndexOfObject(AMovie);
      if (i = -1) then
        repeat
          Inc(c);
          Result := ChangeFileExt(Result, Format(' (%d)%s', [c, Ext]));
        until FExpFileNames.IndexOf(Result) = -1
      else
        Result := FExpFileNames[i];
    end;
    FExpFileNames.AddObject(Result, AMovie);
  end
  else
  begin
    if (AExtra.Picture.PicStream = nil) and (AExtra.Picture.PicPath <> '') then
      OriginalName := AExtra.Picture.PicPath;
    Result := FExpFileNaming.GetFileName(SourceFile, DestFile, OriginalName, Ext,
      AMovie, AExtra, AMovie.MovieList.MaxNumber(True), AExtra.Extras.Count);
    c := 1;
    i := FExpFileNames.IndexOf(Result);
    if (i <> -1) and (FExpFileNames.Objects[i] <> AExtra) then
    begin
      i := FExpFileNames.IndexOfObject(AExtra);
      if (i = -1) then
        repeat
          Inc(c);
          Result := ChangeFileExt(Result, Format(' (%d)%s', [c, Ext]));
        until FExpFileNames.IndexOf(Result) = -1
      else
        Result := FExpFileNames[i];
    end;
    FExpFileNames.AddObject(Result, AExtra);
  end;
  Result := ExtractFilePath(DestFile) + Result;
end;


{-------------------------------------------------------------------------------
   Events
-------------------------------------------------------------------------------}

procedure TExportWin.OnCancelExport(Sender: TObject);
begin
  FCancelExport := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.LvFormatSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    PageControl1.ActivePageIndex := Item.Index + 1;
    Btn3.Enabled := True;
  end
  else
  begin
    pagecontrol1.ActivePageIndex := 0;
    Btn3.Enabled := False;
  end;
  Includemov.Visible := Selected and (Item.Index in [ToHTML, ToCSV, ToSQL, ToImages, ToXML, ToAMC]);
  Sortby.Visible := Selected and (Item.Index in [ToHTML, ToCSV, ToSQL]);
  grpImages.Visible := Selected and (Item.Index in [ToHTML, ToCSV, ToSQL]);
  CBCopyPicturesClick(CBCopyPictures);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.LinkLabelLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
begin
  LaunchProg('http://' + LinkText);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.btn1Click(Sender: TObject);
begin
  functions_files.LaunchHelp(HelpContext + LvFormat.ItemIndex + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.btn3Click(Sender: TObject);
var
  IncOpt: TMovieIncludeOption;
  NbIncMovies, i: Integer;
  Cancel: Boolean;
begin
  IncOpt := Includemov.ItemIndex;
  NbIncMovies := 0;
  Cancel := False;
  for i := 0 to MovieList.Count-1 do
    with MovieList.Items[i] do
      if CanInclude(IncOpt) then
        Inc(NbIncMovies);
  if LvFormat.Selected <> nil then
    with TSaveDialog.Create(Self) do
      try
        Options := DialogSaveOptions;
        case LvFormat.Selected.Index of
          ToHTML:
            begin
              Filter := DialogHTMLFilter;
              DefaultExt := strFilterExtHTML;
              Title := Messages.Strings[msgToHTML];
            end;
          ToCSV:
            begin
              Filter := DialogCSVFilter;
              DefaultExt := strFilterExtCSV;
              Title := Messages.Strings[msgToCSV];
            end;
          ToSQL:
            begin
              Filter := DialogSQLFilter;
              DefaultExt := strFilterExtSQL;
              Title := Messages.Strings[msgToSQL];
            end;
          ToImages:
            begin
              Filter := DialogImageFilter;
              DefaultExt := strFilterExtImages;
              Title := Messages.Strings[msgToImages];
            end;
          ToXML:
            begin
              Filter := DialogXmlFilter;
              DefaultExt := strFilterExtXML;
              Title := Messages.Strings[msgToXml];
            end;
          ToAMC:
            begin
              Filter := DialogAmcSaveFilter;
              DefaultExt := strFilterExtAMC;
              Title := Messages.Strings[msgToAmc];
            end;
        end;
        with Settings.rOptions do
        begin
          InitialDir := rFolders[fuExport].Value;
          if InitialDir <> '' then
            ClearLastVisitedMRU(Application.ExeName);
          if rExport.RememberLastFile then
            FileName := ChangeFileExt(ExtractFileName(rExport.LastFile), '.' + DefaultExt)
          else
            FileName := IfThen(SourceFile <> '', ChangeFileExt(ExtractFileName(SourceFile), '.' + DefaultExt), '');
        end;
        if Execute then
        begin
          DestFile := FileName;
          with Settings.rOptions do
          begin
            if rExport.RememberLastFile then
              rExport.LastFile := ExtractFileName(FileName);
            rFolders[fuExport].Value := ExtractFilePath(FileName);
          end;

          if LvFormat.Selected.Index in [ToXml, ToAmc] then
          begin
            if not SameFileName(SourceFile, DestFile) then
            begin
              if FileExists(DestFile) then
                if not MainWindow.DeleteOldCatalogCopiedPictures(DestFile) then
                  Cancel := True;
            end
            else
            begin
              MessageWin.Execute(Messages.Strings[msgCatalogSamePath],mtError,[mbOk]);
              Cancel := True;
            end;
          end;

          if not Cancel then
          begin
            FCancelExport := False;
            ProgressWin.Status := Messages.Strings[msgExportInit];
            ProgressWin.Maximum := NbIncMovies;
            ProgressWin.IntProgress := 0;
            ProgressWin.Execute(Self);
            try
              // Order the list
              FMaxMovieNumber := MovieList.MaxNumber(False); // Sort by fieldNumber
              if SortBy.Visible then
                SortBy.Sort(MovieList);
              // Export the data
              if SourceFile <> '' then
                SetCurrentDir(ExtractFilePath(SourceFile))
              else
                SetCurrentDir(strDirCatalogs);
              FExpFileNames.Clear;
              FExpFileExt := Settings.rOptions.rExport.ExpFileExt;
              if FExpFileExt = '' then
                FExpFileExt := ExtractFileExt(DestFile);
              case LvFormat.Selected.Index of
                ToHTML:
                  ExportToHTML;
                ToCSV:
                  ExportToCSV;
                ToSQL:
                  ExportToSQL;
                ToImages:
                  ExportToImages;
                ToXml:
                  ExportToXmlOrAmc(True, 99);
                ToAmc:
                  case FilterIndex of
                    DialogAmcSaveFilterAMC:
                      ExportToXmlOrAmc(False, 99);
                    DialogAmcSaveFilterAMC35:
                      ExportToXmlOrAmc(False, 35);
                  end;
              end;
              ProgressWin.IntProgress := ProgressWin.Maximum;
            finally
              ProgressWin.OnCancel := nil;
              ProgressWin.Close;
            end;
            Application.ProcessMessages;
            if Settings.rOptions.rExport.OpenExportedFile then
              LaunchProg(DestFile, ExtractFilePath(DestFile));
          end;
        end;
      finally
        Free;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.CBCopyPicturesClick(Sender: TObject);
begin
  CBCopyPicturesInPicDir.Enabled := CBCopyPictures.Checked;
  CBCopyPicturesNew.Enabled := CBCopyPictures.Checked;
  CBCopyPicturesIncExtras.Enabled := CBCopyPictures.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.CBSQLUpdateClick(Sender: TObject);
var
  UseUpdate: Boolean;
begin
  UseUpdate := CBSQLUpdate.Checked;
  CBSQLDrop.Enabled := not UseUpdate;
  CBSQLCreate.Enabled := not UseUpdate;
  if UseUpdate then
  begin
    CBSQLDrop.Checked := False;
    CBSQLCreate.Checked := False;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (LvFormat.Selected <> nil) and (LvFormat.Selected.Index = ToHTML) then
  begin
    if (ssCtrl in Shift) and (Key = VK_TAB) then
      with HTMLTemplateEdit1 do
      begin
        if ActionDisplayFull.Checked then
          ActionDisplayFullExecute(ActionDisplayIndividual)
        else
        if ActionDisplayIndividual.Checked then
          ActionDisplayFullExecute(ActionDisplayFull);
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.SortByBtnAdvSortClick(Sender: TObject);
begin
  SortBy.BtnAdvSortClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.SortByEOrderByChange(Sender: TObject);
begin
  SortBy.EOrderByChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.Translate;
begin
  Translator.Translate(HTMLTemplateEdit1);
  Translator.Translate(FieldsCSV);
  Translator.Translate(FieldsSQL);
  Translator.Translate(SortBy);
  Translator.Translate(Includemov);
  Translator.Translate(PictureNaming);
  Translator.Translate(Includepic);
  Translator.Translate(PictureOperationExportAMC);
  Translator.Translate(PictureOperationExportXML);
  Translator.Translate(ExtraPictureOperationExportAMC);
  Translator.Translate(ExtraPictureOperationExportXML);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExportWin.IncludemovClick(Sender: TObject);
begin
  Includepic.SetCount(MovieList, Includemov.ItemIndex);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

