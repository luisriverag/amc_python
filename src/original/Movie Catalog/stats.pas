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

unit stats;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, MovieClass,
  TeeProcs, TeEngine, Chart, ActnList, ImgList, Menus, Series, Contnrs,

  AntCorelButton, AntStringList, TB2Item, TBX, TB2Dock, TB2Toolbar,

  base, AntAutoHintLabel, frameincludemov, AppEvnts;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type

  TStatsWin = class(TBaseDlg)
    Panel1: TPanel;
    ActionList1: TActionList;
    ActionCopy: TAction;
    ActionSaveAs: TAction;
    ActionOptions: TAction;
    ActionOptionsLegend: TAction;
    ActionOptionsLabels: TAction;
    lstGeneral: TListView;
    TheChart: TChart;
    Series1: TPieSeries;
    Series2: TBarSeries;
    ActionOptionsEmpty: TAction;
    TBDock1: TTBXDock;
    ToolbarGraphOptions: TTBXToolbar;
    tbbSaveAs: TTBXItem;
    tbs1: TTBXSeparatorItem;
    tbbOptions: TTBXSubmenuItem;
    tbbOptionsEmpty: TTBXItem;
    tbbOptionsLabel: TTBXItem;
    tbbOptionsLegend: TTBXItem;
    ActionCopyWMF: TAction;
    ActionCopyBMP: TAction;
    tbbCopy: TTBXSubmenuItem;
    tbbCopyMetafile: TTBXItem;
    tbbCopyBitmap: TTBXItem;
    Messages: TAntStringList;
    ActionOptionsGroup: TAction;
    tbbOptionsGroup: TTBXItem;
    Panel2: TPanel;
    lstCategories: TListBox;
    IncMovies: TIncludemovFrame;
    ScrollBar1: TScrollBar;
    procedure FormShow(Sender: TObject);
    procedure ActionOptionsExecute(Sender: TObject);
    procedure lstCategoriesClick(Sender: TObject);
    procedure ActionSaveAsExecute(Sender: TObject);
    procedure ActionOptionsLegendExecute(Sender: TObject);
    procedure ActionOptionsLabelsExecute(Sender: TObject);
    procedure ActionCopyWMFExecute(Sender: TObject);
    procedure ActionCopyBMPExecute(Sender: TObject);
    procedure ActionCopyExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ScrollBar1Scroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure TheChartMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure TheChartMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lstCategoriesMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure ScrollBar1Enter(Sender: TObject);
    procedure Series1AfterDrawValues(Sender: TObject);
    procedure Series2AfterDrawValues(Sender: TObject);
  private
    MovieList: TMovieList;
    CatalogPath: TFileName;
    procedure OnDialogTypeChange(Sender: TObject);
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
    procedure FillCategories;
  public
    procedure Execute(const MovieList: TMovieList; const CatalogPath: TFileName);
    procedure Translate; override;
  end;

  TStatItems = set of byte;
  TStatFieldType = set of TFieldType;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  StatsWin: TStatsWin;

  statFieldTypeChart: TStatFieldType = [ftDate, ftInteger, ftReal1, ftReal2, ftReal];
  statFieldTypePie: TStatFieldType = [ftString, ftList, ftBoolean, ftUrl, ftText, ftVirtual];

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  CommDlg, DateUtils,

  PNGImage,
  
  fields, ConstValues, Global, ProgramSettings, functions_files, functions_sys;

{$R *.dfm}

const
  msgMinutes    =  0;
  msgNone       =  1;
  msgSave       =  2;
  msgDayHourMin =  3;
  msgOthers     =  4;
  msgUnit       =  5;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.LoadOptions;
begin
  inherited;
  with Settings do
  begin
    with rStatistics do
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
      ActionOptionsEmpty.Checked := EmptyMonths;
      ActionOptionsLegend.Checked := Legend;
      ActionOptionsLabels.Checked := Labels;
      ActionOptionsGroup.Checked := Group;
      IncMovies.ItemIndex := TMovieIncludeOption(Includemov);
    end;
    ToolbarGraphOptions.Images := ToolbarImages;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.SaveOptions;
begin
  inherited;
  with Settings.rStatistics do
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
    EmptyMonths := ActionOptionsEmpty.Checked;
    Legend := ActionOptionsLegend.Checked;
    Labels := ActionOptionsLabels.Checked;
    Group := ActionOptionsGroup.Checked;
    Includemov := Integer(IncMovies.ItemIndex);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.FillCategories;
var
  i: Integer;
begin
  // Delete old field items
  while lstCategories.Count > 1 do
    lstCategories.Items.Delete(lstCategories.Count-1);
  // Add movie field items
  for i := fieldLow to fieldCount-1 do
  begin
    if not (i in [fieldNumber, fieldComments, fieldDescription{, fieldOriginalTitle,
      fieldTranslatedTitle, fieldFormattedTitle, fieldURL, fieldSize}]) then
    lstCategories.AddItem(strFields.Strings[i], Pointer(i));
  end;
  if (MovieList <> nil) and (MovieList.CustomFieldsProperties <> nil) then
  begin
    // Add custom field items
    for i := 0 to MovieList.CustomFieldsProperties.Count-1 do
    begin
      //if not (TCustomFieldProperties(MovieList.CustomFieldsProperties.Objects[i]).FieldType in [ftURL]) then
        lstCategories.AddItem(MovieList.CustomFieldsProperties.Objects[i].FieldName, Pointer(customFieldLow+i));
    end;
  end;
  // Add extra field items
  for i := extraFieldLow to extraFieldCount-1 do
  begin
    if not (i in [extraFieldNumber, extraFieldComments, extraFieldDescription{,
      extraFieldTitle, extraFieldURL}]) then
    lstCategories.AddItem(strExtraFields.Strings[i - extraFieldLow] + ' (' + strExtras + ')', Pointer(i));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.FormShow(Sender: TObject);
begin
  inherited;
  lstCategoriesClick(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.Execute(const MovieList: TMovieList; const CatalogPath: TFileName);
begin
  Self.MovieList := MovieList;
  Self.CatalogPath := CatalogPath;
  FillCategories;
  IncMovies.SetCount(MovieList);
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionOptionsExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.lstCategoriesClick(Sender: TObject);
var
  idx, i, field, valueidx, increment: Integer;
  fieldType: TFieldType;
  cfp: TCustomFieldProperties;
  labels: TStringList;
  fieldValue: string;
  firstDate, lastDate: TDateTime;
  firstInt, lastInt: Integer;
  group: Boolean;
  statCount: Integer;
  statLength: Double;
  statTotalLength: Integer;
  statTotalSize: Int64;
  statTotalDiscs: Integer;
  IncOpt: TMovieIncludeOption;
  Groups: TStringList;
  GroupMovies: TObjectList;
  GroupName: string;
  sizeUnit: string;

  function GetValue(movie: TMovie): String;
  begin
    if (cfp <> nil) then
      result := movie.CustomFields.GetFieldValue(cfp.FieldTag, True)
    else
      result := movie.GetFieldValue(field, True);
  end;

  function GetIntValue(movie: TMovie): Integer;
  begin
    if (cfp <> nil) then
      result := movie.CustomFields.GetIntFieldValue(cfp.FieldTag)
    else
      result := movie.GetIntFieldValue(field);
  end;

  function GetFloatValue(movie: TMovie): Double;
  begin
    if (cfp <> nil) then
      result := movie.CustomFields.GetFloatFieldValue(cfp.FieldTag)
    else
      result := movie.GetFloatFieldValue(field);
  end;

begin
  if MovieList = nil then
    Exit;
  IncOpt := IncMovies.ItemIndex;
  idx := lstCategories.ItemIndex;
  if idx <= 0 then
    field := -1
  else
    field := Integer(lstCategories.Items.Objects[idx]);
  if (MovieList <> nil) and (MovieList.CustomFieldsProperties <> nil) and
    (field >= customFieldLow) and (field - customFieldLow < MovieList.CustomFieldsProperties.Count) then
    cfp := TCustomFieldProperties(MovieList.CustomFieldsProperties.Objects[field - customFieldLow])
  else
    cfp := nil;
  if cfp <> nil then
    fieldType := cfp.FieldType
  else
    fieldType := GetFieldType(field);
  if (field > -1) then
  begin
    TheChart.BringToFront;
    ScrollBar1.BringToFront;
    TheChart.Title.Text.Text := lstCategories.Items[idx] + sLineBreak + ExtractFileName(CatalogPath);
  end
  else
    lstGeneral.BringToFront;
  ActionCopy.Enabled := (field > -1);
  ActionSaveAs.Enabled := (field > -1);
  ActionOptions.Enabled := (field > -1);
  ActionOptionsLegend.Enabled := (field > -1);
  ActionOptionsLabels.Enabled := (field > -1) and (fieldType in statFieldTypePie);
  ActionOptionsEmpty.Enabled := (fieldType = ftDate);
  ActionOptionsGroup.Enabled := (field > -1) and (fieldType <> ftDate);
  TheChart.Series[0].Active := (field > -1) and (fieldType in statFieldTypeChart) and not (field in AllExtraFields);
  TheChart.Series[1].Active := (field > -1) and ((fieldType in statFieldTypePie) or (field in AllExtraFields));
  TheChart.Series[0].Clear;
  TheChart.Series[1].Clear;
  TheChart.Legend.FirstValue := 0;
  ScrollBar1.Visible := false;
  ScrollBar1.Enabled := false;
  ScrollBar1.Position := 0;
  ScrollBar1.Max := 0;
  ScrollBar1.LargeChange := 1;
  if TheChart.Series[0].Active then // Bar Series
  begin
    ActionOptionsLegendExecute(self);
    with TStringList.Create do
    try
      if (fieldType = ftDate) then
      begin
        MovieList.Sort(field, True);
        if ActionOptionsEmpty.Checked then
        begin
          firstDate := 0;
          for i := 0 to MovieList.Count-1 do
            with TMovie(MovieList.Items[i]) do
              if CanInclude(IncOpt) then
                if GetIntValue(MovieList.Items[i]) > 0 then
                begin
                  firstDate := GetIntValue(MovieList.Items[i]);
                  break;
                end; // if
          if firstDate > 0 then
          begin
            lastDate := recodeDay(GetIntValue(MovieList.Items[MovieList.Count-1]), 1);
            firstDate := recodeDay(firstDate, 1);
            while firstDate <= lastDate do
            begin
              AddObject(FormatDateTime('mmm yyyy', firstDate), pointer(0));
              firstDate := IncMonth(firstDate);
            end; // while
          end; // if > 0
        end; // if checked
        for i := 0 to MovieList.Count-1 do
          with TMovie(MovieList.Items[i]) do
            if CanInclude(IncOpt) then
              if GetIntValue(MovieList.Items[i]) > 0 then
              begin
                fieldValue := FormatDateTime('mmm yyyy', GetIntValue(MovieList.Items[i]));
                valueidx := IndexOf(fieldValue);
                if valueidx > -1 then
                  Objects[valueidx] := pointer(integer(Objects[valueidx]) + 1)
                else
                if not ActionOptionsEmpty.Checked then
                  AddObject(fieldValue, pointer(1));
              end; // if > 0
        for i := 0 to Count-1 do
          TheChart.Series[0].Add(integer(Objects[i]), Strings[i]);
      end // ftDate
      else // ftInteger or ftReal...
      begin
        group := ActionOptionsGroup.Checked;
        if cfp <> nil then
          if (fieldType = ftInteger) then
            increment := 5
          else
            increment := 1
        else
          case field of
            fieldYear:
              increment := 5;
            fieldLength:
              increment := 10;
            fieldRating, fieldUserRating:
              increment := 1;
            fieldVideoBitrate:
              increment := 50;
            fieldAudioBitrate:
              increment := 20;
            fieldDisks:
              increment := 1;
            fieldColorTag:
              increment := 1;
            else
              increment := 5;
          end; // case
        MovieList.Sort(field, True);
        if group then
        begin
          firstInt := -1;
          for i := 0 to MovieList.Count-1 do
            with TMovie(MovieList.Items[i]) do
              if CanInclude(IncOpt) then
                if GetFloatValue(MovieList.Items[i]) <> -1 then
                begin
                  firstInt := trunc(GetFloatValue(MovieList.Items[i]));
                  break;
                end;
          if firstInt <> -1 then
          begin
            firstInt := trunc(firstInt / increment) * increment;
            lastInt := firstInt;
            for i := MovieList.Count-1 downto 0 do
              with TMovie(MovieList.Items[i]) do
                if CanInclude(IncOpt) then
                begin
                  lastInt := trunc(GetFloatValue(MovieList.Items[i]));
                  Break;
                end;
            while firstInt <= lastInt do
            begin
              AddObject(IntToStr(firstInt), Pointer(0));
              inc(firstInt, increment);
            end; // while
          end; // if <> -1
        end; // if checked
        for i := 0 to MovieList.Count-1 do
          with TMovie(MovieList.Items[i]) do
            if CanInclude(IncOpt) then
              if GetFloatValue(MovieList.Items[i]) > -1 then
              begin
                if group then
                  fieldValue := IntToStr(trunc(GetFloatValue(MovieList.Items[i]) / increment) * increment)
                else
                  fieldValue := GetValue(MovieList.Items[i]);
                valueidx := IndexOf(fieldValue);
                if valueidx > -1 then
                  Objects[valueidx] := pointer(integer(Objects[valueidx]) + 1)
                else if not group then
                  AddObject(fieldValue, pointer(1));
              end; // if > -1
        for i := 0 to Count-1 do
        begin
          if group then
            if (fieldType = ftInteger) then
              fieldValue := Format('%s -> %d', [Strings[i], StrToInt(Strings[i]) + increment - 1])
            else
            begin
              if (fieldType = ftReal1) then
                fieldValue := Format('%s -> %s', [
                  FormatFloat('#0.0', StrToInt(Strings[i])),
                  FormatFloat('#0.0', StrToInt(Strings[i]) + increment - 0.1) ])
              else if (fieldType = ftReal2) then
                fieldValue := Format('%s -> %s', [
                  FormatFloat('#0.00', StrToInt(Strings[i])),
                  FormatFloat('#0.00', StrToInt(Strings[i]) + increment - 0.01) ])
              else
                fieldValue := Format('%s -> %s', [
                  FormatFloat('#0.000', StrToInt(Strings[i])),
                  FormatFloat('#0.000', StrToInt(Strings[i]) + increment - 0.001) ])
            end
          else
            fieldValue := Strings[i];
          TheChart.Series[0].Add(integer(Objects[i]), fieldValue);
        end; // for
      end; // ftInteger or ftReal...
      TheChart.View3DOptions.Orthogonal := true;
    finally
      Free;
    end; // with TStringList try
  end else
  if TheChart.Series[1].Active then // Pie Series
  begin
    ActionOptionsLabelsExecute(Self);
    ActionOptionsLegendExecute(Self);

    Groups := MovieList.GetMoviesByGroups(field, IncOpt);
    TheChart.Series[1].XValues.Order := loNone;
    TheChart.Series[1].YValues.Order := loNone;
    for i := 0 to Groups.Count-1 do
    begin
      GroupName := Groups.Strings[i];
      GroupMovies := TObjectList(Groups.Objects[i]);
      if GroupName = '$$$EMPTY$$$' then
        GroupName := Messages.Strings[msgNone];
      TheChart.Series[1].Add(GroupMovies.Count, GroupName);
    end;
    TheChart.Series[1].XValues.Order := loAscending;
    TheChart.Series[1].YValues.Order := loDescending;
    TheChart.Series[1].YValues.Sort;
    TheChart.Series[1].XValues.Order := loNone;
    TheChart.Series[1].YValues.Order := loNone;
    FreeObjects(Groups);
    Groups.Free;

    with (TheChart.Series[1] as TPieSeries).OtherSlice do
    begin
      if ActionOptionsGroup.Checked then
      begin
        Style := poBelowPercent;
        Value := 0.5;
        Text := Messages.Strings[msgOthers];
      end
      else
        Style := poNone
    end;
  end else // Catalog Info
  begin
    statLength := 0;
    statTotalLength := 0;
    statTotalSize := 0;
    statTotalDiscs := 0;
    with MovieList do
    begin
      statCount := Count(IncOpt);
      for i := 0 to Count-1 do
      begin
        with TMovie(Items[i]) do
          if CanInclude(IncOpt) then
          begin
            if iLength > 0 then
            begin
              statLength := statLength + iLength;
              Inc(statTotalLength, iLength);
            end
            else
              dec(statCount);
            statTotalSize := statTotalSize + CalcTotalSize;
            if iDisks > 0 then
              Inc(statTotalDiscs, iDisks);
          end;
      end;
      try
        if statCount = 0 then
          statLength := 0
        else
          statLength := statLength / statCount;
      except
        statLength := 0;
      end;
      statCount := Count(IncOpt);
    end;
    with Settings.rOptions.rMovieInformation do
      case GetFileSizeUnitId(ImportSizeUnit) of
        0: sizeUnit := Messages.Strings[msgUnit];
        1: sizeUnit := 'K'+Messages.Strings[msgUnit];
        2: sizeUnit := 'M'+Messages.Strings[msgUnit];
        3: sizeUnit := 'G'+Messages.Strings[msgUnit];
        else sizeUnit := '';
      end;
    lstGeneral.Items[0].SubItems[0] := IntToStr(statCount);
    lstGeneral.Items[1].SubItems[0] := Format(Messages.Strings[msgMinutes], [statLength]);
    lstGeneral.Items[2].SubItems[0] := Format(Messages.Strings[msgDayHourMin], [statTotalLength div (60*24), (statTotalLength mod (60*24)) div 60, statTotalLength mod 60]);
    lstGeneral.Items[3].SubItems[0] := IntToStr(statTotalSize) + ' ' + sizeUnit;
    lstGeneral.Items[4].SubItems[0] := IntToStr(statTotalDiscs);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionSaveAsExecute(Sender: TObject);
var
  png: TPNGObject;
  bmp: TBitmap;
begin
  with TSaveDialog.Create(Self) do
    try
      Filter := DialogChartFilter;
      DefaultExt := Copy(extChart[extChWMF], 2, 3);
      Options := DialogSaveOptions;
      InitialDir := Settings.rOptions.rFolders[fuGraphic].Value;
      FileName := '';
      Title := Messages.Strings[msgSave];
      OnTypeChange := Self.OnDialogTypeChange;
      if Execute then
      begin
        Settings.rOptions.rFolders[fuGraphic].Value := ExtractFilePath(FileName);
        case FilterIndex of
          DialogChartFilterWMF:
            TheChart.SaveToMetafile(FileName);
          DialogChartFilterPNG:
            begin
              png := TPNGObject.Create;
              bmp := TBitmap.Create;
              try
                TheChart.SaveToBitmapFile(FileName);
                bmp.LoadFromFile(FileName);
                png.Assign(bmp);
                png.SaveToFile(FileName);
              finally
                png.Free;
                bmp.Free;
              end;
            end;
          DialogChartFilterBMP:
            TheChart.SaveToBitmapFile(FileName);
        end; // case
      end; // if exec
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionOptionsLegendExecute(Sender: TObject);
begin
  TheChart.Legend.Visible := ActionOptionsLegend.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionOptionsLabelsExecute(Sender: TObject);
begin
  TheChart.Series[1].Marks.Visible := ActionOptionsLabels.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionCopyWMFExecute(Sender: TObject);
begin
  TheChart.CopyToClipboardMetafile(true);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionCopyBMPExecute(Sender: TObject);
begin
  TheChart.CopyToClipboardBitmap;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ActionCopyExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.FormCreate(Sender: TObject);
begin
  ActionCopy.ImageIndex := Ord(ICON_STATSCOPY);
  ActionSaveAs.ImageIndex := Ord(ICON_STATSSAVE);
  ActionOptions.ImageIndex := Ord(ICON_STATSOPTIONS);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.Translate;
begin
  Translator.Translate(IncMovies);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.OnDialogTypeChange(Sender: TObject);
var
  NewName, NewExt: string;
begin
  if Sender is TSaveDialog then
    with Sender as TSaveDialog do
    begin
      if not DirectoryExists(FileName) then
      begin
        case FilterIndex of
          DialogChartFilterWMF:
            begin
              NewName := ChangeFileExt(ExtractFileName(FileName), extChart[extChWMF]);
              NewExt := extChart[extChWMF];
            end;
          DialogChartFilterPNG:
            begin
              NewName := ChangeFileExt(ExtractFileName(FileName), extChart[extChPNG]);
              NewExt := extChart[extChPNG];
            end;
          DialogChartFilterBMP:
            begin
              NewName := ChangeFileExt(ExtractFileName(FileName), extChart[extChBMP]);
              NewExt := extChart[extChBMP];
            end;
        end;
        Delete(NewExt, 1, 1);
        SendMessage(Windows.GetParent(Handle), CDM_SETCONTROLTEXT, 1152, Integer(PChar(NewName)));
        SendMessage(Windows.GetParent(Handle), CDM_SETDEFEXT, 1152, Integer(PChar(NewExt)));
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ScrollBar1Scroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  TheChart.Legend.FirstValue := ScrollPos;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.TheChartMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  inherited;
  if WheelDelta > 0 then
  begin
    if ScrollBar1.Position > 0 then
    begin
      ScrollBar1.Position := ScrollBar1.Position - 1;
      TheChart.Legend.FirstValue := ScrollBar1.Position;
    end;
  end
  else
  begin
    if ScrollBar1.Position < ScrollBar1.Max then
    begin
      ScrollBar1.Position := ScrollBar1.Position + 1;
      TheChart.Legend.FirstValue := ScrollBar1.Position;
    end;
  end;
  Handled := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.TheChartMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (not TheChart.Focused) and TheChart.CanFocus then
    TheChart.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.ScrollBar1Enter(Sender: TObject);
begin
  inherited;
  if (not TheChart.Focused) and TheChart.CanFocus then
    TheChart.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.lstCategoriesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (not lstCategories.Focused) and lstCategories.CanFocus then
    lstCategories.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.Series1AfterDrawValues(Sender: TObject);
var
  nb: Integer;
begin
  inherited;
  nb := TheChart.Series[1].CountLegendItems - TheChart.Legend.NumRows;
  if nb < 0 then
    nb := 0;
  ScrollBar1.Max := nb;
  nb := TheChart.Legend.NumRows;
  if nb < 1 then
    nb := 1;
  ScrollBar1.LargeChange := nb;
  ScrollBar1.Enabled := (ScrollBar1.Max > 0);
  ScrollBar1.Visible := TheChart.Legend.Visible and ScrollBar1.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TStatsWin.Series2AfterDrawValues(Sender: TObject);
var
  nb: Integer;
begin
  inherited;
  nb := TheChart.Series[0].CountLegendItems - TheChart.Legend.NumRows;
  if nb < 0 then
    nb := 0;
  ScrollBar1.Max := nb;
  nb := TheChart.Legend.NumRows;
  if nb < 1 then
    nb := 1;
  ScrollBar1.LargeChange := nb;
  ScrollBar1.Enabled := (ScrollBar1.Max > 0);
  ScrollBar1.Visible := TheChart.Legend.Visible and ScrollBar1.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
