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

unit getscript_results;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ExtCtrls, Contnrs,

  ComCtrls, AntStringList, AntCorelButton, AntAutoHintLabel,

  movieclass, FileManager, fields, ActnList, TB2Item, TBX, Menus, ElTree;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TScriptResult = (srSave, srSaveAll, srSkip, srAbort);

  TScriptExtraInfo = class(TObject)
  public
    Extra: TMovieExtra;
    ModifiedFields: TMovieFields;
    SelectedFields: TMovieFields;
    ModifiedPicture: Boolean;
    SelectedPicture: Boolean;
    PictureImportMethod: TMoviePictureImport;
    PictureURL: string;
    procedure Init;
  end;

  TScriptResultsWin = class(TBaseDlg)
    Messages: TAntStringList;
    ActionList1: TActionList;
    ActionListCheck: TAction;
    ActionListUncheck: TAction;
    ActionListAll: TAction;
    ActionListNone: TAction;
    MenuPopupList: TTBXPopupMenu;
    MnuLspChk: TTBXItem;
    MnuLspUnc: TTBXItem;
    MnuLsp__1: TTBXSeparatorItem;
    MnuLspAll: TTBXItem;
    MnuLspNon: TTBXItem;
    listValues: TElTree;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure listValuesMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure listValuesDblClick(Sender: TObject);
    procedure listValuesHotTrack(Sender: TObject; OldItem: TElTreeItem;
      OldSection: TElHeaderSection; NewItem: TElTreeItem;
      NewSection: TElHeaderSection);
    procedure listValuesMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure listValuesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure listValuesResize(Sender: TObject);
    procedure ActionListCheckExecute(Sender: TObject);
  private
    FCurrentCatalog: TFileManager;
    FCustomFieldsProperties: TCustomFieldsProperties;
    FScriptName: string;
    FCustomCaption: string;

    FMovieOrig: TMovie;
    FMovieCopy: TMovie;
    FKeepSelectedFields: Boolean;
    FAlwaysKeepSelectedFields: Boolean;
    
    FAllowedFields: TMovieFields;
    FModifiedFields: TMovieFields;
    FSelectedFields: TMovieFields;

    FAllowPicture: Boolean;
    FModifiedPicture: Boolean;
    FSelectedPicture: Boolean;
    FPictureImportMethod: TMoviePictureImport;
    FPictureURL: string;
    
    FAllowedCustomFields: TMovieFields;
    FModifiedCustomFields: TMovieFields;
    FSelectedCustomFields: TMovieFields;

    FAllowAddExtras: Boolean;
    FSelectedAddExtras: Boolean;
    FAllowDeleteExtras: Boolean;
    FSelectedDeleteExtras: Boolean;
    FAllowModifyExtras: Boolean;
    FSelectedModifyExtras: Boolean;
    FAllowedExtraFields: TMovieFields;
    FSelectedExtraFields: TMovieFields;
    FAllowExtraPicture: Boolean;
    FSelectedExtraPicture: Boolean;

    FAddedExtras: TStringList;
    FModifiedExtras: TStringList;

    FHeaderSectionValuesOver: Integer;

  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure GenerateFields(CustomFieldsProperties: TCustomFieldsProperties); // Call it after create!
    procedure Init(const AllowedFields: TMovieFields;
      const AllowedCustomFields: TMovieFields;
      const AllowPicture: Boolean;
      const AllowAddExtras: Boolean;
      const AllowDeleteExtras: Boolean;
      const AllowModifyExtras: Boolean;
      const AllowedExtraFields: TMovieFields;
      const AllowExtraPicture: Boolean;
      const CurrentCatalog: TFileManager;
      const AlwaysKeepSelectedFields: Boolean = False);
    procedure CopyFrom(const AMovie: TMovie);
    procedure CopyTo(AMovie: TMovie; const AllowClear: Boolean);
    function Execute(const ShowWindow: Boolean; const ScriptName: string;
      const CustomCaption: string = '';
      const DefaultSelectedFields: TMovieFields = [fieldLow..fieldCount-1];
      const DefaultSelectedCustomFields: TMovieFields = [customFieldLow..customFieldMax];
      const DefaultSelectedPicture: Boolean = True;
      const DefaultSelectedAddExtras: Boolean = True;
      const DefaultSelectedDeleteExtras: Boolean = True;
      const DefaultSelectedModifyExtras: Boolean = True;
      const DefaultSelectedExtraFields: TMovieFields = [extraFieldLow..extraFieldCount-1];
      const DefaultSelectedExtraPicture: Boolean = True
      ): TScriptResult;
    function GetExtraInfo(Extra: TMovieExtra; AddIfNotExists: Boolean = False): TScriptExtraInfo;
    
    function IsSelected: Boolean;
    procedure SetSelected(selected: Boolean);
    procedure SetAllFieldsAndCustomFields(AMovie: TMovie);
    function CanSetField(const AField: TMovieField): Boolean;
    procedure SetField(const AField: TMovieField; const AValue: string);
    function CanSetCustomField(const AField: string): Boolean;
    procedure SetCustomField(const AField: string; const AValue: string);
    function GetField(const AField: TMovieField): string;
    function GetFieldLS(const AField: TMovieField): string;
    function GetCustomField(const AField: string): string;
    function GetCustomFieldLS(const AField: string): string;
    function SetPicture(AStream: TStream; const PicURL: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
    function ImportPicture(FileName: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
    function ExportPicture(FileName: string): Boolean;
    function RemovePicture: Boolean;
    function PictureExists: Boolean;
    function GetPictureStatus: TMoviePictureStatus;
    function GetPictureExt: string;
    function GetPicturePath: string;
    function GetPictureFullPath: string;
    function GetPictureSize: Int64;
    function GetPictureWidth: Integer;
    function GetPictureHeight: Integer;
    function ConvertPicture(maxWidth: Integer; maxHeight: Integer): Boolean;

    function GetExtraCount: Integer;
    function FindExtra(extraTag: string): Integer;
    function AddExtra: Integer;
    function CanAddExtras: Boolean;
    function DeleteExtra(extraIndex: Integer): Boolean;
    function DeleteExtraCreatedBy(extraIndex: Integer; createdBy: string): Boolean;
    procedure ClearExtras;
    procedure ClearExtrasCreatedBy(createdBy: string);
    function CanDeleteExtras: Boolean;
    function IsExtraSelected(extraIndex: Integer): Boolean;
    procedure SetExtraSelected(extraIndex: Integer; selected: Boolean);
    procedure ClearAndAddAllExtras(AMovie: TMovie; picImportMethod: TMoviePictureImport = mpiUndefined);
    procedure SetExtraField(extraIndex: Integer; extraField: Integer; value: string);
    function GetExtraField(extraIndex: Integer; extraField: Integer): string;
    function CanModifyExtras: Boolean;
    function CanSetExtraField(extraField: Integer): Boolean;
    function SetExtraPicture(extraIndex: Integer; AStream: TStream; const PicURL: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
    function ImportExtraPicture(extraIndex: Integer; filename: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
    function ExportExtraPicture(extraIndex: Integer; filename: string): Boolean;
    function RemoveExtraPicture(extraIndex: Integer): Boolean;
    function CanSetExtraPicture: Boolean;
    function ExtraPictureExists(extraIndex: Integer): Boolean;
    function GetExtraPictureStatus(extraIndex: Integer): TMoviePictureStatus;
    function GetExtraPictureExt(extraIndex: Integer): string;
    function GetExtraPicturePath(extraIndex: Integer): string;
    function GetExtraPictureFullPath(extraIndex: Integer): string;
    function GetExtraPictureSize(extraIndex: Integer): Int64;
    function GetExtraPictureWidth(extraIndex: Integer): Integer;
    function GetExtraPictureHeight(extraIndex: Integer): Integer;
    function ConvertExtraPicture(extraIndex: Integer; maxWidth: Integer; maxHeight: Integer): Boolean;

    property SelectedFields: TMovieFields read FSelectedFields write FSelectedFields;
    property SelectedCustomFields: TMovieFields read FSelectedCustomFields write FSelectedCustomFields;
    property SelectedPicture: Boolean read FSelectedPicture write FSelectedPicture;
    property SelectedAddExtras: Boolean read FSelectedAddExtras write FSelectedAddExtras;
    property SelectedDeleteExtras: Boolean read FSelectedDeleteExtras write FSelectedDeleteExtras;
    property SelectedModifyExtras: Boolean read FSelectedDeleteExtras write FSelectedDeleteExtras;
    property SelectedExtraFields: TMovieFields read FSelectedExtraFields write FSelectedExtraFields;
    property SelectedExtraPicture: Boolean read FSelectedExtraPicture write FSelectedExtraPicture;
  end;

var
  ScriptResultsWin: TScriptResultsWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

uses
  CommCtrl,

  Global, functions_files, functions_str, constValues, pictureform,
  getscript_extrasresults;

const
  msgResultsCaption       = 0;
  msgClickPicture         = 1;
  msgRememberFields       = 2;
  msgAddExtras            = 3;
  msgDeleteExtras         = 4;
  msgModifyExtras         = 5;
  msgClickExtrasAdded     = 6;
  msgClickExtrasDeleted   = 7;
  msgClickExtrasModified  = 8;
  msgClickExtrasChanged   = 9;
  msgFileNotExists        = 10;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptExtraInfo.Init;
begin
  Extra := nil;
  ModifiedFields := [];
  ModifiedPicture := False;
  SelectedFields := AllExtraFields;
  SelectedPicture := True;
  PictureURL := '';
  PictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rExtraPicImport.ScriptingMethod);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.FormCreate(Sender: TObject);
begin
  FMovieOrig := nil;
  FMovieCopy := nil;
  FSelectedFields := AllFields;
  FSelectedCustomFields := AllCustomFields;
  FSelectedPicture := True;

  FSelectedAddExtras := True;
  FSelectedDeleteExtras := True;
  FSelectedModifyExtras := True;
  FSelectedExtraFields := AllExtraFields;
  FSelectedExtraPicture := True;

  FAddedExtras := TStringList.Create;
  FAddedExtras.Sorted := True;
  FModifiedExtras := TStringList.Create;
  FModifiedExtras.Sorted := True;

  ScriptExtrasResultsWin := TScriptExtrasResultsWin.Create(Self);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.FormShow(Sender: TObject);
begin
  ScriptExtrasResultsWin.Icon.Assign(Icon);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  if FMovieOrig <> nil then
  begin
    for i := 0 to FMovieOrig.Extras.Count-1 do
    begin
      FMovieOrig.Extras.Items[i]._linkedExtra := nil;
      FMovieOrig.Extras.Items[i]._iStatus := mesNormal;
    end;
  end;
  FMovieCopy.Free;
  FreeObjects(FAddedExtras);
  FAddedExtras.Free;
  FreeObjects(FModifiedExtras);
  FModifiedExtras.Free;
  FreeAndNil(ScriptExtrasResultsWin);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.GenerateFields(CustomFieldsProperties: TCustomFieldsProperties);
var
  NewItem: TElTreeItem;
  f: Integer;
begin
  FMovieCopy := TMovie.Create(CustomFieldsProperties.MovieList);
  FCustomFieldsProperties := CustomFieldsProperties;
  listValues.Items.Clear;
  with listValues.Items do
  begin
    BeginUpdate;
    try
      for f := fieldLow to fieldCount-1 do
        if not (f in VirtualFields) then
        begin
          NewItem := AddChild(nil, strFields[f]);
          NewItem.ShowCheckBox := True;
          NewItem.Data := Pointer(f);
        end;
      NewItem := AddChild(nil, strFieldPicture);
      NewItem.ShowCheckBox := True;
      NewItem.Data := Pointer(fieldPicture);
      // Add CustomFields
      with FCustomFieldsProperties do
        for f := 0 to Count-1 do
          if Objects[f].FieldType <> ftVirtual then
          begin
            NewItem := AddChild(nil, Objects[f].FieldName + ' (' + Objects[f].FieldTag + ')');
            NewItem.ShowCheckBox := True;
            NewItem.Data := Pointer(customFieldLow+f);
          end;
      // Add ExtraFields
      NewItem := AddChild(nil, Messages.Strings[msgAddExtras]);
      NewItem.ShowCheckBox := True;
      NewItem.Data := Pointer(customFieldMax+1);
      NewItem := AddChild(nil, Messages.Strings[msgDeleteExtras]);
      NewItem.ShowCheckBox := True;
      NewItem.Data := Pointer(customFieldMax+2);
      NewItem := AddChild(nil, Messages.Strings[msgModifyExtras]);
      NewItem.ShowCheckBox := True;
      NewItem.Data := Pointer(customFieldMax+3);
      for f := extraFieldLow to extraFieldCount-1 do
        if not (f in VirtualFields) then
        begin
          NewItem := AddChild(nil, strExtraFields[f - extraFieldLow] + ' (' + strExtras + ')');
          NewItem.ShowCheckBox := True;
          NewItem.Data := Pointer(f);
        end;
      NewItem := AddChild(nil, strExtraFieldPicture + ' (' + strExtras + ')');
      NewItem.ShowCheckBox := True;
      NewItem.Data := Pointer(extraFieldPicture);
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.Init(const AllowedFields: TMovieFields;
      const AllowedCustomFields: TMovieFields;
      const AllowPicture: Boolean;
      const AllowAddExtras: Boolean;
      const AllowDeleteExtras: Boolean;
      const AllowModifyExtras: Boolean;
      const AllowedExtraFields: TMovieFields;
      const AllowExtraPicture: Boolean;
      const CurrentCatalog: TFileManager;
      const AlwaysKeepSelectedFields: Boolean);
begin
  FAllowedFields := AllowedFields;
  FAllowedCustomFields := AllowedCustomFields;
  FAllowPicture := AllowPicture;

  FAllowAddExtras := AllowAddExtras;
  FAllowDeleteExtras := AllowDeleteExtras;
  FAllowModifyExtras := AllowModifyExtras;
  FAllowedExtraFields := AllowedExtraFields;
  FAllowExtraPicture := AllowExtraPicture;

  FCurrentCatalog := CurrentCatalog;
  FKeepSelectedFields := False;
  FAlwaysKeepSelectedFields := AlwaysKeepSelectedFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.CopyFrom(const AMovie: TMovie);
var
  i: Integer;
begin
  if FMovieOrig <> nil then
  begin
    for i := 0 to FMovieOrig.Extras.Count-1 do
    begin
      FMovieOrig.Extras.Items[i]._linkedExtra := nil;
      FMovieOrig.Extras.Items[i]._iStatus := mesNormal;
    end;
    FreeObjects(FModifiedExtras);
    FModifiedExtras.Clear;
    FreeObjects(FAddedExtras);
    FAddedExtras.Clear;
  end;
  FMovieOrig := AMovie;
  FModifiedFields := [];
  FModifiedCustomFields := [];
  FModifiedPicture := False;
  FMovieCopy.Assign(FMovieOrig, True, True, True, True, True);
  FMovieCopy._bSelected := FMovieOrig._bSelected;
  FPictureURL := '';
  FPictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rPicImport.ScriptingMethod);
  for i := 0 to FMovieCopy.Extras.Count-1 do
  begin
    FMovieCopy.Extras.Items[i]._bSelected := FMovieOrig.Extras.Items[i]._bSelected;
    FMovieCopy.Extras.Items[i]._linkedExtra := FMovieOrig.Extras.Items[i];
    FMovieOrig.Extras.Items[i]._linkedExtra := FMovieCopy.Extras.Items[i];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.CopyTo(AMovie: TMovie; const AllowClear: Boolean);
var
  f, i, idx: Integer;
  s: string;
  CustomFieldProperties: TCustomFieldProperties;
  AExtra: TMovieExtra;
  ExtraCopyInfo: TScriptExtraInfo;
begin
  for f := fieldLow to fieldCount-1 do
    if f in FSelectedFields then
    begin
      if f in FModifiedFields then
      begin
        s := FMovieCopy.GetFieldValue(f);
        if (s <> '') or AllowClear then
        begin
          AMovie.SetFieldValue(f, s);
          FCurrentCatalog.Modified := True;
        end;
      end;
    end;
  with FCustomFieldsProperties do
    for f := 0 to Count-1 do
      if (f+customFieldLow) in FSelectedCustomFields then
      begin
        CustomFieldProperties := FCustomFieldsProperties.Objects[f];
        if (f+customFieldLow) in FModifiedCustomFields then
        begin
          s := FMovieCopy.CustomFields.GetFieldValue(CustomFieldProperties.FieldTag);
          if (s <> '') or AllowClear then
          begin
            AMovie.CustomFields.SetFieldValue(CustomFieldProperties.FieldTag, s);
            FCurrentCatalog.Modified := True;
          end;
        end
      end;
  if FSelectedPicture then
  begin
    if FModifiedPicture then
    begin
      try
        if FMovieCopy.Picture.PicPath <> '' then
        begin
          if (FPictureURL <> '') and (FileExists(FPictureURL)) then
            AMovie.Picture.ImportPicture(FPictureURL, FCurrentCatalog.CurrentFile,
              FPictureImportMethod)
          else
            AMovie.Picture.ImportPictureFromStream(FMovieCopy.Picture.PicStream, FMovieCopy.Picture.PicPath,
              FCurrentCatalog.CurrentFile, TMoviePictureImport(FPictureImportMethod),
              ValidateFileName(Lowercase(Copy(FPictureURL, LastDelimiter('/\', FPictureURL) + 1, Length(FPictureURL)))));
          FCurrentCatalog.Modified := True;
        end
        else if AllowClear then
        begin
          AMovie.Picture.PictureOperation(FCurrentCatalog.CurrentFile, mpoDelete);
          FCurrentCatalog.Modified := True;
        end;
      except
      end;
    end
  end;
  // If we can delete extras, we delete all extras with status deleted in
  // extra list of dest movie
  if FSelectedDeleteExtras then
  begin
    for i := AMovie.Extras.Count-1 downto 0 do
    begin
      if (AMovie <> FMovieOrig) or (AMovie.Extras.Items[i]._iStatus = mesDeleted) then
      begin
        AMovie.Extras.Items[i].Picture.PictureOperation(FCurrentCatalog.CurrentFile, mpoDelete);
        AMovie.Extras.Delete(i);
        FCurrentCatalog.Modified := True;
      end;
    end;
  end;
  // If some extras have been modified or added...
  if (FSelectedModifyExtras and (FModifiedExtras.Count > 0)) or
    (FSelectedAddExtras and (FAddedExtras.Count > 0)) then
  begin
    // If we can modify extras, we delete all extras in extra list of
    // dest movie (except extras with status delete or cancel deleted)
    // to re-add them later in the good order
    // using link _linkedExtra in extras of extra list of copied movie
    if FSelectedModifyExtras and (AMovie = FMovieOrig) then
    begin
      AMovie.Extras.OwnsObjects := False;
      for i := AMovie.Extras.Count-1 downto 0 do
        if (AMovie.Extras.Items[i]._iStatus <> mesDeleted) and
          (AMovie.Extras.Items[i]._iStatus <> mesCancelDeleted) then
          AMovie.Extras.Delete(i);
      AMovie.Extras.OwnsObjects := True;
    end;
    // For all extras in extra list of copied movie...
    for i := 0 to FMovieCopy.Extras.Count-1 do
    begin
      with FMovieCopy.Extras.Items[i] do
      begin
        AExtra := nil;
        // If extra has a linked extra, this means current extra is a copy
        // of an extra in extra list of dest movie
        if (_linkedExtra <> nil) and (AMovie = FMovieOrig) then
        begin
          // If we can modify extras, we re-add the original extra in the good order
          // in extra list of dest movie (we have deleted it before for this purpose)
          if FSelectedModifyExtras then
            AMovie.Extras.Add(_linkedExtra);
          // If we can modify extras and the current extra has been modified
          // and not canceled, we take it
          if FSelectedModifyExtras and (_iStatus = mesModified) then
            AExtra := _linkedExtra;
        end
        // Else if we can add extras and the current extra has been added or
        // modified (if AMovie <> FMovieOrig) and not canceled, we add it
        else if FSelectedAddExtras and ((_iStatus = mesAdded) or
          (_iStatus = mesModified)) then
        begin
          idx := AMovie.Extras.AddExtra;
          if idx <> -1 then
          begin
            AExtra := AMovie.Extras.Items[idx];
            AExtra.bChecked := True;
            AExtra.Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
            // We import default picture later to have the good filename according to field values
            FCurrentCatalog.Modified := True;
          end;
        end;
        // If we have taken/added an extra in the extra list of dest movie...
        if (AExtra <> nil) then
        begin
          // We take info of added or modified extra to know fields to modify
          ExtraCopyInfo := GetExtraInfo(FMovieCopy.Extras.Items[i], False);
          if (ExtraCopyInfo <> nil) then
          begin
            for f := extraFieldLow to extraFieldCount-1 do
            begin
              // If we can modify the field for all extras and the current extra
              if (f in FSelectedExtraFields) and (f in ExtraCopyInfo.SelectedFields) then
              begin
                if f in ExtraCopyInfo.ModifiedFields then
                begin
                  s := GetFieldValue(f);
                  if (s <> '') or AllowClear then
                  begin
                    AExtra.SetFieldValue(f, s);
                    FCurrentCatalog.Modified := True;
                  end;
                end;
              end;
            end;
            if (_iStatus = mesAdded) then
            begin
              // We import default picture here to have the good filename according to field values
              if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
              try
                AExtra.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
                  FCurrentCatalog.CurrentFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
              except
              end;
            end;
            // If we can modify the picture for all extras and the current extra
            if FSelectedExtraPicture and ExtraCopyInfo.SelectedPicture then
            begin
              if ExtraCopyInfo.ModifiedPicture then
              begin
                try
                  if Picture.PicPath <> '' then
                  begin
                    if (ExtraCopyInfo.PictureURL <> '') and (FileExists(ExtraCopyInfo.PictureURL)) then
                      AExtra.Picture.ImportPicture(ExtraCopyInfo.PictureURL, FCurrentCatalog.CurrentFile,
                        ExtraCopyInfo.PictureImportMethod)
                    else
                      AExtra.Picture.ImportPictureFromStream(Picture.PicStream, Picture.PicPath,
                        FCurrentCatalog.CurrentFile, TMoviePictureImport(ExtraCopyInfo.PictureImportMethod),
                        ValidateFileName(Lowercase(Copy(ExtraCopyInfo.PictureURL,
                        LastDelimiter('/\', ExtraCopyInfo.PictureURL) + 1, Length(ExtraCopyInfo.PictureURL)))));
                    FCurrentCatalog.Modified := True;
                  end
                  else if AllowClear then
                  begin
                    AExtra.Picture.PictureOperation(FCurrentCatalog.CurrentFile, mpoDelete);
                    FCurrentCatalog.Modified := True;
                  end;
                except
                end;
              end
            end;
          end;
          AExtra._bSelected := _bSelected;
        end;
      end;
    end;
  end;
  if (AMovie = FMovieOrig) then
    for i := 0 to FMovieCopy.Extras.Count-1 do
      with FMovieCopy.Extras.Items[i] do
        if _linkedExtra <> nil then
          _linkedExtra._bSelected := _bSelected;
  AMovie._bSelected := FMovieCopy._bSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.Execute(const ShowWindow: Boolean; const ScriptName: string;
      const CustomCaption: string;
      const DefaultSelectedFields: TMovieFields;
      const DefaultSelectedCustomFields: TMovieFields;
      const DefaultSelectedPicture: Boolean;
      const DefaultSelectedAddExtras: Boolean;
      const DefaultSelectedDeleteExtras: Boolean;
      const DefaultSelectedModifyExtras: Boolean;
      const DefaultSelectedExtraFields: TMovieFields;
      const DefaultSelectedExtraPicture: Boolean): TScriptResult;
var
  i, f: Integer;
  j, nb: Integer;
  s: string;
  CurItem: TElTreeItem;
  DoubleSize: Double;
  CustomFieldProperties: TCustomFieldProperties;
begin
  if ShowWindow then
  begin
    FScriptName := ScriptName;
    FCustomCaption := CustomCaption;
    if CustomCaption = '' then
    begin
      Caption := Format(Messages.Strings[msgResultsCaption], [ScriptName, FMovieOrig.iNumber]);
      s := FMovieOrig.GetFormattedTitle;
      if s = '' then
        s := FMovieCopy.GetFormattedTitle;
      if s <> '' then
        Caption := Format('%s "%s"', [Caption, s]);
    end
    else
      Caption := CustomCaption;
    for i := 0 to listValues.Items.Count-1 do
    begin
      CurItem := listValues.Items[i];
      f := Integer(CurItem.Data);
      if f in AllFields then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add(FMovieOrig.GetFieldValue(f, True));
        if (f in FModifiedFields) then
        begin
          CurItem.SubItems.Add(FMovieCopy.GetFieldValue(f, True));
          CurItem.Checked := (f in DefaultSelectedFields);
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.Checked := False;
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
      end
      else if f in AllCustomFields then
      begin
        CustomFieldProperties := FCustomFieldsProperties.Objects[f-customFieldLow];
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add(FMovieOrig.CustomFields.GetFieldValue(CustomFieldProperties.FieldTag, True));
        if (f in FModifiedCustomFields) then
        begin
          CurItem.SubItems.Add(FMovieCopy.CustomFields.GetFieldValue(CustomFieldProperties.FieldTag, True));
          CurItem.Checked := (f in DefaultSelectedCustomFields);
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.Checked := False;
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
      end
      else if f = fieldPicture then
      begin
        CurItem.SubItems.Clear;
        if FMovieOrig.Picture.PicPath <> '' then
        begin
          DoubleSize := FMovieOrig.Picture.GetPictureSize(FCurrentCatalog.CurrentFile) / 1024.0;
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
        end
        else
          CurItem.SubItems.Add('');
        if FModifiedPicture then
        begin
          if (FMovieCopy.Picture.PicPath <> '') then
          begin
            DoubleSize := FMovieCopy.Picture.GetPictureSize(FCurrentCatalog.CurrentFile) / 1024.0;
            CurItem.SubItems.Add(Format(Messages.Strings[msgClickPicture], [DoubleSize]));
          end
          else
            CurItem.SubItems.Add('');
          CurItem.Checked := DefaultSelectedPicture;
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.Checked := False;
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
      end
      else if f = customFieldMax+1 then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add('');
        nb := FAddedExtras.Count;
        if nb > 0 then
        begin
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickExtrasAdded], [nb]));
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
        CurItem.Checked := (nb > 0) and DefaultSelectedAddExtras;
      end
      else if f = customFieldMax+2 then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add('');
        nb := 0;
        for j := 0 to FMovieOrig.Extras.Count-1 do
          if FMovieOrig.Extras.Items[j]._iStatus = mesDeleted then
            Inc(nb);
        if nb > 0 then
        begin
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickExtrasDeleted], [nb]));
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
        CurItem.Checked := (nb > 0) and DefaultSelectedDeleteExtras;
      end
      else if f = customFieldMax+3 then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add('');
        nb := FModifiedExtras.Count;
        if nb > 0 then
        begin
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickExtrasModified], [nb]));
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
        CurItem.Checked := (nb > 0) and DefaultSelectedModifyExtras;
      end
      else if f in AllExtraFields then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add('');
        nb := 0;
        for j := 0 to FAddedExtras.Count-1 do
          with TScriptExtraInfo(FAddedExtras.Objects[j]) do
            if f in ModifiedFields then
              Inc(nb);
        for j := 0 to FModifiedExtras.Count-1 do
          with TScriptExtraInfo(FModifiedExtras.Objects[j]) do
            if f in ModifiedFields then
              Inc(nb);
        if nb > 0 then
        begin
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickExtrasChanged], [nb]));
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
        CurItem.Checked := (nb > 0) and (f in DefaultSelectedExtraFields);
      end
      else if f = extraFieldPicture then
      begin
        CurItem.SubItems.Clear;
        CurItem.SubItems.Add('');
        nb := 0;
        for j := 0 to FAddedExtras.Count-1 do
          with TScriptExtraInfo(FAddedExtras.Objects[j]) do
            if ModifiedPicture then
              Inc(nb);
        for j := 0 to FModifiedExtras.Count-1 do
          with TScriptExtraInfo(FModifiedExtras.Objects[j]) do
            if ModifiedPicture then
              Inc(nb);
        if nb > 0 then
        begin
          CurItem.SubItems.Add(Format(Messages.Strings[msgClickExtrasChanged], [nb]));
          CurItem.UseStyles := False;
        end
        else
        begin
          CurItem.SubItems.Add('');
          CurItem.UseStyles := True;
          CurItem.MainStyle.OwnerProps := False;
          CurItem.MainStyle.FontSize := listValues.Font.Size;
          CurItem.MainStyle.FontStyles := listValues.Font.Style;
          CurItem.MainStyle.FontName := listValues.Font.Name;
          CurItem.MainStyle.TextColor := clGrayText;
        end;
        CurItem.Checked := (nb > 0) and (DefaultSelectedExtraPicture);
      end;
    end;
    case ShowModal of
      mrYes:
        Result := srSave;
      mrYesToAll:
        Result := srSaveAll;
      mrNo:
        Result := srSkip;
      mrNoToAll,
      mrCancel:
        Result := srAbort;
    else
      raise Exception.Create('Unexpected result in TScriptResultsWin.Execute');
    end;
    if Result in [srSave, srSaveAll] then
    begin
      FSelectedFields := [];
      FSelectedCustomFields := [];
      FSelectedPicture := False;
      FSelectedAddExtras := False;
      FSelectedDeleteExtras := False;
      FSelectedModifyExtras := False;
      FSelectedExtraFields := [];
      FSelectedExtraPicture := False;
      for i := 0 to listValues.Items.Count-1 do
      begin
        CurItem := listValues.Items[i];
        if CurItem.Checked then
        begin
          f := Integer(CurItem.Data);
          if f in AllFields then
            Include(FSelectedFields, f)
          else if f in AllCustomFields then
            Include(FSelectedCustomFields, f)
          else if f = fieldPicture then
            FSelectedPicture := True
          else if f = customFieldMax+1 then
            FSelectedAddExtras := True
          else if f = customFieldMax+2 then
            FSelectedDeleteExtras := True
          else if f = customFieldMax+3 then
            FSelectedModifyExtras := True
          else if f in AllExtraFields then
            Include(FSelectedExtraFields, f)
          else if f = extraFieldPicture then
            FSelectedExtraPicture := True
        end;
      end;
    end;
  end
  else
  begin
    if not FKeepSelectedFields then
    begin
      FSelectedFields := FModifiedFields;
      FSelectedCustomFields := FModifiedCustomFields;
      FSelectedPicture := FModifiedPicture;
      FSelectedAddExtras := FAllowAddExtras;
      FSelectedDeleteExtras := FAllowDeleteExtras;
      FSelectedModifyExtras := FAllowModifyExtras;
      FSelectedExtraFields := FAllowedExtraFields;
      FSelectedExtraPicture := FAllowExtraPicture;
    end;
    Result := srSaveAll;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.LoadOptions;
begin
  with Settings.rScripts.rResults do
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
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SaveOptions;
begin
  with Settings.rScripts.rResults do
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
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraInfo(Extra: TMovieExtra; AddIfNotExists: Boolean): TScriptExtraInfo;
var
  idx: Integer;
begin
  Result := nil;
  if Extra._iStatus = mesAdded then
  begin
    idx := FAddedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
      Result := TScriptExtraInfo(FAddedExtras.Objects[idx]);
  end
  else if Extra._iStatus = mesModified then
  begin
    idx := FModifiedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
      Result := TScriptExtraInfo(FModifiedExtras.Objects[idx]);
  end
  else if AddIfNotExists then
  begin
    Result := TScriptExtraInfo.Create;
    Result.Init;
    Result.Extra := Extra;
    idx := FModifiedExtras.AddObject(Format('%p', [Pointer(Extra)]), Result);
    if idx <> -1 then
      Extra._iStatus := mesModified
    else
      FreeAndNil(Result);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.IsSelected: Boolean;
begin
  Result := FMovieCopy._bSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SetSelected(selected: Boolean);
begin
  FMovieCopy._bSelected := selected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SetAllFieldsAndCustomFields(AMovie: TMovie);
begin
  FMovieCopy.Assign(AMovie, True, False, False, True, True);
  FModifiedFields := AllFields - VirtualFields;
  FModifiedCustomFields := AllCustomFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanSetField(const AField: TMovieField): Boolean;
begin
  Result := AField in FAllowedFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SetField(const AField: TMovieField; const AValue: string);
begin
  if AField in FAllowedFields then
  begin
    FMovieCopy.SetFieldValue(AField, AValue);
    Include(FModifiedFields, AField);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanSetCustomField(const AField: string): Boolean;
var
  Idx: Integer;
begin
  Idx := FCustomFieldsProperties.IndexOf(AField);
  Result := (Idx <> -1) and ((Idx + customFieldLow) in FAllowedCustomFields);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SetCustomField(const AField: string; const AValue: string);
var
  Idx: Integer;
begin
  Idx := FCustomFieldsProperties.IndexOf(AField);
  if (Idx <> -1) and ((Idx + customFieldLow) in FAllowedCustomFields) then
  begin
    FMovieCopy.CustomFields.SetFieldValue(AField, AValue, False);
    Include(FModifiedCustomFields, Idx+customFieldLow);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetField(const AField: TMovieField): string;
begin
  Result := FMovieCopy.GetFieldValue(AField, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetFieldLS(const AField: TMovieField): string;
begin
  Result := FMovieCopy.GetFieldValue(AField, True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetCustomField(const AField: string): string;
begin
  Result := FMovieCopy.CustomFields.GetFieldValue(AField, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetCustomFieldLS(const AField: string): string;
begin
  Result := FMovieCopy.CustomFields.GetFieldValue(AField, True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.SetPicture(AStream: TStream; const PicURL: string; picImportMethod: TMoviePictureImport): Boolean;
var
  OldPicPath: string;
  Picture: TMoviePicture;
begin
  Result := False;
  if not FAllowPicture then
    exit;
  Picture := FMovieCopy.Picture;
  OldPicPath := '';
  // If extra has a linked or copied picture, with remove its link to not delete old picture file during import !
  // Old picture file will be deleted during CopyTo if needed
  if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
  begin
    OldPicPath := Picture.PicPath;
    Picture.PicPath := '';
  end;
  try
    Result := Picture.ImportPictureFromStream(AStream, ExtractFileExt(PicURL), FCurrentCatalog.CurrentFile, mpiStore);
    if Result then
    begin
      FModifiedPicture := True;
      FPictureURL := ExpandFileName(PicURL);
      if picImportMethod <> mpiUndefined then
        FPictureImportMethod := picImportMethod
      else
        FPictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rPicImport.ScriptingMethod);
    end
    else if OldPicPath <> '' then
      Picture.PicPath := OldPicPath;
  except
    if OldPicPath <> '' then
      Picture.PicPath := OldPicPath;
    //on e: Exception do
    //  MessageWin.Execute(PicURL + ' : ' + e.Message, mtError, [mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ImportPicture(FileName: string; picImportMethod: TMoviePictureImport): Boolean;
var
  OldPicPath: string;
  Picture: TMoviePicture;
begin
  Result := False;
  if not FAllowPicture then
    exit;
  Picture := FMovieCopy.Picture;
  OldPicPath := '';
  // If movie has a linked or copied picture, with remove its link to not delete old picture file during import !
  // Old picture file will be deleted during CopyTo if needed
  if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
  begin
    OldPicPath := Picture.PicPath;
    Picture.PicPath := '';
  end;
  if (FCurrentCatalog.CurrentFile <> '') then
    SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  try
    Result := Picture.ImportPicture(ExpandFileName(FileName), FCurrentCatalog.CurrentFile, mpiStore);
    if Result then
    begin
      FModifiedPicture := True;
      FPictureURL := ExpandFileName(FileName);
      if picImportMethod <> mpiUndefined then
        FPictureImportMethod := picImportMethod
      else
        FPictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rPicImport.ScriptingMethod);
    end
    else if OldPicPath <> '' then
      Picture.PicPath := OldPicPath;
  except
    if OldPicPath <> '' then
      Picture.PicPath := OldPicPath;
    //on e: Exception do
    //  MessageWin.Execute(FileName + ' : ' + e.Message, mtError, [mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ExportPicture(FileName: string): Boolean;
var
  PicPath, PicName: string;
  Picture: TMoviePicture;
begin
  Result := False;
  Picture := FMovieCopy.Picture;
  if (Picture.PicPath <> '') then
  begin
    if (FCurrentCatalog.CurrentFile <> '') then
      SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    FileName := ExpandFileName(FileName);
    PicPath := ExtractFilePath(FileName);
    PicName := ValidateFileName(ExtractFileName(FileName));
    if Picture.PicStream <> nil then
    begin
      if DirectoryExists(PicPath) then
        try
          Picture.PicStream.SaveToFile(PicPath + PicName);
          Result := FileExists(PicPath + PicName);
        except
        end;
    end else
    begin
      if FileExists(ExpandFileName(Picture.PicPath)) and DirectoryExists(PicPath) then
        try
          CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(PicPath + PicName), false);
          Result := FileExists(ExpandFileName(PicPath + PicName));
        except
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.RemovePicture: Boolean;
begin
  Result := False;
  if FAllowPicture then
  begin
    FMovieCopy.Picture.Init;
    FModifiedPicture := True;
    Result := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.PictureExists: Boolean;
begin
  Result := False;
  if (FCurrentCatalog.CurrentFile <> '') then
    SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  if (FMovieCopy.Picture.PicPath <> '') and ((FMovieCopy.Picture.PicStream <> nil) or
    FileExists(ExpandFileName(FMovieCopy.Picture.PicPath))) then
    Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureStatus: TMoviePictureStatus;
begin
  result := FMovieCopy.Picture.GetPictureStatus(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureExt: string;
begin
  Result := '';
  if (FMovieCopy.Picture.PicPath <> '') then
    Result := ExtractFileExt(FMovieCopy.Picture.PicPath);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPicturePath: string;
begin
  Result := '';
  if (FMovieCopy.Picture.PicPath <> '') and (FMovieCopy.Picture.PicStream = nil) then
    Result := FMovieCopy.Picture.PicPath;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureFullPath: string;
begin
  Result := '';
  if (FCurrentCatalog.CurrentFile <> '') then
    SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  if (FMovieCopy.Picture.PicPath <> '') and (FMovieCopy.Picture.PicStream = nil) then
    Result := ExpandFileName(FMovieCopy.Picture.PicPath);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureSize: Int64;
begin
  Result := FMovieCopy.Picture.GetPictureSize(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureWidth: Integer;
begin
  Result := FMovieCopy.Picture.GetPictureWidth(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetPictureHeight: Integer;
begin
  Result := FMovieCopy.Picture.GetPictureHeight(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ConvertPicture(maxWidth: Integer; maxHeight: Integer): Boolean;
var
  Picture: TMoviePicture;
  picImportMethod: TMoviePictureImport;
begin
  Result := False;
  if not FAllowPicture then
    exit;
  Picture := FMovieCopy.Picture;
  if (Picture.PicPath <> '') then
  begin
    case Picture.GetPictureStatus(FCurrentCatalog.CurrentFile) of
      mpsStored:
        picImportMethod := mpiStore;
      mpsCopiedInCatDir:
        picImportMethod := mpiCopyInCatDir;
      mpsCopiedInPicDir:
        picImportMethod := mpiCopyInPicDir;
      mpsLinkAbs, mpsLinkRel:
        picImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rPicImport.ScriptingMethod);
      else
        exit;
    end;
    if (Picture.PicStream = nil) then
    begin
      // We expand filename to not delete copied picture now
      // (it will be deleted later if needed) and we store picture in memory
      // to convert it
      if (FCurrentCatalog.CurrentFile <> '') then
        SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      if not FileExists(ExpandFileName(Picture.PicPath)) then
        exit;
      Picture.PicPath := ExpandFileName(Picture.PicPath);
      Picture.PictureOperation(FCurrentCatalog.CurrentFile, mpoStore);
    end;
    try
      Result := Picture.ConvertPicture(FCurrentCatalog.CurrentFile, maxWidth, maxHeight);
      if Result then
        FModifiedPicture := True;
        FPictureURL := '';
        FPictureImportMethod := picImportMethod;
    except
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraCount: Integer;
begin
  Result := FMovieCopy.Extras.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.FindExtra(extraTag: string): Integer;
begin
  Result := FMovieCopy.Extras.FindExtra(extraTag);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.AddExtra: Integer;
var
  idx: Integer;
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
begin
  Result := -1;
  if not FAllowAddExtras then
    exit;
  idx := FMovieCopy.Extras.AddExtra;
  Result := idx;
  if idx = -1 then
    exit;
  Extra := FMovieCopy.Extras.Items[idx];
  Extra.bChecked := True;
  Extra._bSelected := True;
  Extra.Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
  if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
    try
      Extra.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
        FCurrentCatalog.CurrentFile, mpiStore);
    except
    end;
  Extra._iStatus := mesAdded;
  ExtraInfo := TScriptExtraInfo.Create;
  ExtraInfo.Init;
  ExtraInfo.Extra := Extra;
  FAddedExtras.AddObject(Format('%p', [Pointer(Extra)]), ExtraInfo);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanAddExtras: Boolean;
begin
  Result := FAllowAddExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.DeleteExtra(extraIndex: Integer): Boolean;
var
  idx: Integer;
  Extra: TMovieExtra;
begin
  Result := False;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowDeleteExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  if Extra._iStatus = mesAdded then
  begin
    idx := FAddedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
    begin
      FAddedExtras.Objects[idx].Free;
      FAddedExtras.Objects[idx] := nil;
      FAddedExtras.Delete(idx);
    end;
  end
  else if Extra._iStatus = mesModified then
  begin
    idx := FModifiedExtras.IndexOf(Format('%p', [Pointer(Extra)]));
    if idx <> -1 then
    begin
      FModifiedExtras.Objects[idx].Free;
      FModifiedExtras.Objects[idx] := nil;
      FModifiedExtras.Delete(idx);
    end;
  end;
  if Extra._linkedExtra <> nil then
    Extra._linkedExtra._iStatus := mesDeleted;
  FMovieCopy.Extras.Delete(extraIndex);
  Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.DeleteExtraCreatedBy(extraIndex: Integer; createdBy: string): Boolean;
var
  Extra: TMovieExtra;
begin
  Result := False;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if Extra.strCreatedBy = createdBy then
    Result := DeleteExtra(extraIndex);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.ClearExtras;
var
  i: Integer;
begin
  for i := FMovieCopy.Extras.Count-1 downto 0 do
    DeleteExtra(i);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.ClearExtrasCreatedBy(createdBy: string);
var
  i: Integer;
begin
  for i := FMovieCopy.Extras.Count-1 downto 0 do
    DeleteExtraCreatedBy(i, createdBy);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanDeleteExtras: Boolean;
begin
  Result := FAllowDeleteExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}


function TScriptResultsWin.IsExtraSelected(extraIndex: Integer): Boolean;
begin
  Result := False;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex]._bSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.SetExtraSelected(extraIndex: Integer; selected: Boolean);
begin
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  FMovieCopy.Extras.Items[extraIndex]._bSelected := selected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.ClearAndAddAllExtras(AMovie: TMovie; picImportMethod: TMoviePictureImport);
var
  i, f, idx: Integer;
  MovieExtra: TMovieExtra;
begin
  ClearExtras;
  for i := 0 to AMovie.Extras.Count-1 do
  begin
    MovieExtra := AMovie.Extras.Items[i];
    idx := AddExtra;
    if idx <> -1 then
    begin 
      for f := extraFieldLow to extraFieldCount-1 do
        SetExtraField(idx, f, MovieExtra.GetFieldValue(f));
      if MovieExtra.Picture.PicPath <> '' then
        if MovieExtra.Picture.PicStream <> nil then
          ScriptResultsWin.SetExtraPicture(idx, MovieExtra.Picture.PicStream, MovieExtra.Picture.PicPath, picImportMethod)
        else
          ScriptResultsWin.ImportExtraPicture(idx, MovieExtra.Picture.PicPath, picImportMethod)
      else
        ScriptResultsWin.RemoveExtraPicture(idx);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}


procedure TScriptResultsWin.SetExtraField(extraIndex: Integer; extraField: Integer; value: string);
var
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
  i: Integer;
begin
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  if extraField = extraFieldNumber then
  begin
    i := StrToIntDef(value, 0) - 1;
    if (i >= 0) and (i < FMovieCopy.Extras.Count) then
      FMovieCopy.Extras.Move(FMovieCopy.Extras.Items[extraIndex].iNumber-1, i);
    exit;
  end;
  if not (extraField in FAllowedExtraFields) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowModifyExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  ExtraInfo := GetExtraInfo(Extra, True);
  if ExtraInfo <> nil then
  begin
    Extra.SetFieldValue(extraField, value);
    Include(ExtraInfo.ModifiedFields, extraField);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraField(extraIndex: Integer; extraField: Integer): string;
begin
  Result := '';
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex].GetFieldValue(extraField);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanModifyExtras: Boolean;
begin
  Result := FAllowModifyExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanSetExtraField(extraField: Integer): Boolean;
begin
  Result := extraField in FAllowedExtraFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.SetExtraPicture(extraIndex: Integer; AStream: TStream; const PicURL: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
var
  OldPicPath: string;
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
  Picture: TMoviePicture;
begin
  Result := False;
  if not FAllowExtraPicture then
    exit;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowModifyExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  ExtraInfo := GetExtraInfo(Extra, True);
  if ExtraInfo <> nil then
  begin
    Picture := Extra.Picture;
    OldPicPath := '';
    // If extra has a linked or copied picture, with remove its link to not delete old picture file during import !
    // Old picture file will be deleted during CopyTo if needed
    if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
    begin
      OldPicPath := Picture.PicPath;
      Picture.PicPath := '';
    end;
    try
      Result := Picture.ImportPictureFromStream(AStream, ExtractFileExt(PicURL), FCurrentCatalog.CurrentFile, mpiStore);
      if Result then
      begin
        ExtraInfo.ModifiedPicture := True;
        ExtraInfo.PictureURL := ExpandFileName(PicURL);
        if picImportMethod <> mpiUndefined then
          ExtraInfo.PictureImportMethod := picImportMethod
        else
          ExtraInfo.PictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rExtraPicImport.ScriptingMethod);
      end
      else if OldPicPath <> '' then
        Picture.PicPath := OldPicPath;
    except
      if OldPicPath <> '' then
        Picture.PicPath := OldPicPath;
      //on e: Exception do
      //  MessageWin.Execute(PicURL + ' : ' + e.Message, mtError, [mbOk]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ImportExtraPicture(extraIndex: Integer; filename: string; picImportMethod: TMoviePictureImport = mpiUndefined): Boolean;
var
  OldPicPath: string;
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
  Picture: TMoviePicture;
begin
  Result := False;
  if not FAllowExtraPicture then
    exit;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowModifyExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  ExtraInfo := GetExtraInfo(Extra, True);
  if ExtraInfo <> nil then
  begin
    Picture := Extra.Picture;
    OldPicPath := '';
    // If movie has a linked or copied picture, with remove its link to not delete old picture file during import !
    // Old picture file will be deleted during CopyTo if needed
    if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
    begin
      OldPicPath := Picture.PicPath;
      Picture.PicPath := '';
    end;
    if (FCurrentCatalog.CurrentFile <> '') then
      SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    try
      Result := Picture.ImportPicture(ExpandFileName(FileName), FCurrentCatalog.CurrentFile, mpiStore);
      if Result then
      begin
        ExtraInfo.ModifiedPicture := True;
        ExtraInfo.PictureURL := ExpandFileName(FileName);
        if picImportMethod <> mpiUndefined then
          ExtraInfo.PictureImportMethod := picImportMethod
        else
          ExtraInfo.PictureImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rExtraPicImport.ScriptingMethod);
      end
      else if OldPicPath <> '' then
        Picture.PicPath := OldPicPath;
    except
      if OldPicPath <> '' then
        Picture.PicPath := OldPicPath;
      //on e: Exception do
      //  MessageWin.Execute(FileName + ' : ' + e.Message, mtError, [mbOk]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ExportExtraPicture(extraIndex: Integer; filename: string): Boolean;
var
  PicPath, PicName: string;
  Picture: TMoviePicture;
begin
  Result := False;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
  if (Picture.PicPath <> '') then
  begin
    if (FCurrentCatalog.CurrentFile <> '') then
      SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    FileName := ExpandFileName(FileName);
    PicPath := ExtractFilePath(FileName);
    PicName := ValidateFileName(ExtractFileName(FileName));
    if Picture.PicStream <> nil then
    begin
      if DirectoryExists(PicPath) then
        try
          Picture.PicStream.SaveToFile(PicPath + PicName);
          Result := FileExists(PicPath + PicName);
        except
        end;
    end else
    begin
      if FileExists(ExpandFileName(Picture.PicPath)) and DirectoryExists(PicPath) then
        try
          CopyFile(PChar(ExpandFileName(Picture.PicPath)), PChar(PicPath + PicName), false);
          Result := FileExists(ExpandFileName(PicPath + PicName));
        except
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.RemoveExtraPicture(extraIndex: Integer): Boolean;
var
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
begin
  Result := False;
  if not FAllowExtraPicture then
    exit;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowModifyExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  ExtraInfo := GetExtraInfo(Extra, True);
  if ExtraInfo <> nil then
  begin
    FreeAndNil(Extra.Picture.PicStream);
    Extra.Picture.PicPath := '';
    ExtraInfo.ModifiedPicture := True;
    Result := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.CanSetExtraPicture: Boolean;
begin
  Result := FAllowExtraPicture;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ExtraPictureExists(extraIndex: Integer): Boolean;
var
  Picture: TMoviePicture;
begin
  Result := False;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
  if (FCurrentCatalog.CurrentFile <> '') then
    SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  if (Picture.PicPath <> '') and ((Picture.PicStream <> nil) or
    FileExists(ExpandFileName(Picture.PicPath))) then
    Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}


function TScriptResultsWin.GetExtraPictureStatus(extraIndex: Integer): TMoviePictureStatus;
begin
  Result := mpsUndefined;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex].Picture.GetPictureStatus(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPictureExt(extraIndex: Integer): string;
var
  Picture: TMoviePicture;
begin
  Result := '';
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
  if (Picture.PicPath <> '') then
    Result := ExtractFileExt(Picture.PicPath);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPicturePath(extraIndex: Integer): string;
var
  Picture: TMoviePicture;
begin
  Result := '';
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
  if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
    Result := Picture.PicPath;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPictureFullPath(extraIndex: Integer): string;
var
  Picture: TMoviePicture;
begin
  Result := '';
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
  if (FCurrentCatalog.CurrentFile <> '') then
    SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  if (Picture.PicPath <> '') and (Picture.PicStream = nil) then
    Result := ExpandFileName(Picture.PicPath);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPictureSize(extraIndex: Integer): Int64;
begin
  Result := -1;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex].Picture.GetPictureSize(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPictureWidth(extraIndex: Integer): Integer;
begin
  Result := 0;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex].Picture.GetPictureWidth(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.GetExtraPictureHeight(extraIndex: Integer): Integer;
begin
  Result := 0;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Result := FMovieCopy.Extras.Items[extraIndex].Picture.GetPictureHeight(FCurrentCatalog.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TScriptResultsWin.ConvertExtraPicture(extraIndex: Integer; maxWidth: Integer; maxHeight: Integer): Boolean;
var
  Extra: TMovieExtra;
  ExtraInfo: TScriptExtraInfo;
  Picture: TMoviePicture;
  picImportMethod: TMoviePictureImport;
begin
  Result := False;
  if not FAllowExtraPicture then
    exit;
  if (extraIndex < 0) or (extraIndex >= FMovieCopy.Extras.Count) then
    exit;
  Extra := FMovieCopy.Extras.Items[extraIndex];
  if (not FAllowModifyExtras) and (Extra._iStatus <> mesAdded) then
    exit;
  ExtraInfo := GetExtraInfo(Extra, True);
  if ExtraInfo <> nil then
  begin
    Picture := FMovieCopy.Extras.Items[extraIndex].Picture;
    if (Picture.PicPath <> '') then
    begin
      case Picture.GetPictureStatus(FCurrentCatalog.CurrentFile) of
        mpsStored:
          picImportMethod := mpiStore;
        mpsCopiedInCatDir:
          picImportMethod := mpiCopyInCatDir;
        mpsCopiedInPicDir:
          picImportMethod := mpiCopyInPicDir;
        mpsLinkAbs, mpsLinkRel:
          picImportMethod := TMoviePictureImport(Settings.rOptions.rMovieInformation.rExtraPicImport.ScriptingMethod);
        else
          exit;
      end;
      if (Picture.PicStream = nil) then
      begin
        // We expand filename to not delete copied picture now
        // (it will be deleted later if needed) and we store picture in memory
        // to convert it
        if (FCurrentCatalog.CurrentFile <> '') then
          SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
        else
          SetCurrentDir(strDirCatalogs);
        if not FileExists(ExpandFileName(Picture.PicPath)) then
          exit;
        Picture.PicPath := ExpandFileName(Picture.PicPath);
        Picture.PictureOperation(FCurrentCatalog.CurrentFile, mpoStore);
      end;
      try
        Result := Picture.ConvertPicture(FCurrentCatalog.CurrentFile, maxWidth, maxHeight);
        if Result then
        begin
          ExtraInfo.ModifiedPicture := True;
          ExtraInfo.PictureURL := '';
          ExtraInfo.PictureImportMethod := picImportMethod;
        end;
      except
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.btn3Click(Sender: TObject);
begin
  if FAlwaysKeepSelectedFields then
    FKeepSelectedFields := True
  else
    case MessageWin.Execute(Messages.Strings[msgRememberFields], mtConfirmation, [mbYes, mbNo, mbCancel]) of
      1:  FKeepSelectedFields := True;
      2:  FKeepSelectedFields := False;
    else
      Exit;
    end;
  ModalResult := mrYesToAll;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if (not listValues.Focused) and (listValues.CanFocus) then
    listValues.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesDblClick(Sender: TObject);
begin
  with (Sender as TElTree) do
    if (Selected <> nil) then
      Selected.Checked := not Selected.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesHotTrack(Sender: TObject;
  OldItem: TElTreeItem; OldSection: TElHeaderSection; NewItem: TElTreeItem;
  NewSection: TElHeaderSection);
begin
  inherited;
  if NewSection <> nil then
    FHeaderSectionValuesOver := NewSection.Index;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  CurItem: TElTreeItem;
  Mov: TMovie;
  value, statusFilter, fieldFilter: Integer;
begin
  if (Button <> mbLeft) then
    Exit;
  CurItem := listValues.Selected;
  if (CurItem = nil) then
    Exit;
  value := Integer(CurItem.Data);
  if value = fieldPicture then
  begin
    case FHeaderSectionValuesOver of
      1:  Mov := FMovieOrig;
      2:  Mov := FMovieCopy;
    else
      Mov := nil;
    end;
    if (Mov <> nil) and (Mov.Picture.PicPath <> '') then
    begin
      PictureWin := TPictureWin.Create(Self);
      try
        PictureWin.CenterWindow := True;
        if (FCurrentCatalog.CurrentFile <> '') then
          SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
        else
          SetCurrentDir(strDirCatalogs);
        if Mov.Picture.PicStream = nil then
          if FileExists(ExpandFileName(Mov.Picture.PicPath)) then
            PictureWin.Execute(Mov.Picture.GetPictureCaption, ExpandFileName(Mov.Picture.PicPath))
          else
            MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [Mov.Picture.PicPath]), mtError, [mbOk])
        else
          PictureWin.Execute(Mov.Picture.GetPictureCaption, Mov.Picture.PicStream, Mov.Picture.PicPath);
      finally
        FreeAndNil(PictureWin)
      end;
    end;
  end
  else if (value = customFieldMax+1) or (value = customFieldMax+2) or (value = customFieldMax+3) or
    (value in AllExtraFields) or (value = extraFieldPicture) then
  begin
    if (FHeaderSectionValuesOver = 2) and (CurItem.SubItems[1] <> '') then
    begin
      statusFilter := -1;
      fieldFilter := -1;
      case value of
        customFieldMax+1:
          statusFilter := Integer(mesAdded);
        customFieldMax+2:
          statusFilter := Integer(mesDeleted);
        customFieldMax+3:
          statusFilter := Integer(mesModified);
        extraFieldPicture:
          fieldFilter := value;
        else
          fieldFilter := value;
      end;
      ScriptExtrasResultsWin.Execute(FScriptName, FCurrentCatalog,
        FMovieOrig, FMovieCopy, FAddedExtras, FModifiedExtras,
        statusFilter, fieldFilter, FCustomCaption);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
    with listValues do
      if ItemFocused <> nil then
        ItemFocused.Checked := not ItemFocused.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.listValuesResize(Sender: TObject);
begin
  listValues.HeaderSections.Item[1].Width := Trunc((Width-listValues.HeaderSections.Item[0].Width-44)/2);
  listValues.HeaderSections.Item[2].Width := Trunc((Width-listValues.HeaderSections.Item[0].Width-44)/2);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TScriptResultsWin.ActionListCheckExecute(Sender: TObject);
var
  i: Integer;
  bState, bAll: Boolean;
begin
  bState := (Sender = ActionListCheck) or (Sender = ActionListAll);
  bAll := (Sender = ActionListAll) or (Sender = ActionListNone);
  if Sender is TAction then
    if TAction(Sender).ActionComponent is TTBXItem then
      if MenuPopupList.PopupComponent is TElTree then
      begin
        with TElTree(MenuPopupList.PopupComponent) do
        begin
          Items.BeginUpdate;
          for i := 0 to Items.Count-1 do
            if Items[i].ShowCheckBox and (bAll or Items[i].Selected) then
              Items[i].Checked := bState;
          Items.EndUpdate;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
