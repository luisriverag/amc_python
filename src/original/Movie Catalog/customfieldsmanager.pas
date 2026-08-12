(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2011-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit customfieldsmanager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, shellAPI, ComCtrls,

  ConstValues, AntCorelButton, AntJvExControls, AntJvToolEdit, AntAutoHintLabel,

  base, movieclass, AntStringList, TBX, TBXDkPanels, Menus, TB2Item;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TCustomFieldsManagerWin = class(TBaseDlg)
    LName: TLabel;
    EName: TEdit;
    EListValues: TMemo;
    LListValues: TLabel;
    EField: TComboBox;
    LField: TLabel;
    EType: TComboBox;
    LType: TLabel;
    Bevel2: TBevel;
    LDefaultValue: TLabel;
    LMultiValues: TLabel;
    EMultiValues: TCheckBox;
    ETag: TEdit;
    LTag: TLabel;
    Messages: TAntStringList;
    LExt: TLabel;
    EExt: TEdit;
    LMediaInfo: TLabel;
    EMediaInfo: TComboBox;
    EMultiValuesSep: TComboBox;
    LMultiValuesSep: TLabel;
    LMultiValuesRmP: TLabel;
    EMultiValuesRmP: TCheckBox;
    LMultiValuesPatch: TLabel;
    EMultiValuesPatch: TCheckBox;
    btnImport: TTBXButton;
    btnExport: TTBXButton;
    btnClearAll: TTBXButton;
    btnApply: TTBXButton;
    btnDel: TTBXButton;
    EListCatalogValues: TCheckBox;
    EListSort: TCheckBox;
    EListAutoAdd: TCheckBox;
    EListAutoComplete: TCheckBox;
    EDefaultValue: TComboBox;
    LTemplate: TLabel;
    ETemplate: TEdit;
    btnInsertFieldTag: TTBXButton;
    PopupFields: TTBXPopupMenu;
    procedure btnApplyClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure ETagChange(Sender: TObject);
    procedure EFieldChange(Sender: TObject);
    procedure ENameChange(Sender: TObject);
    procedure ETypeChange(Sender: TObject);
    procedure EDefaultValueChange(Sender: TObject);
    procedure EMultiValuesClick(Sender: TObject);
    procedure EListValuesChange(Sender: TObject);
    procedure btnClearAllClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure EExtChange(Sender: TObject);
    procedure EMediaInfoChange(Sender: TObject);
    procedure EMultiValuesSepChange(Sender: TObject);
    procedure EMultiValuesRmPClick(Sender: TObject);
    procedure EMultiValuesPatchClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure EListSortClick(Sender: TObject);
    procedure EListAutoCompleteClick(Sender: TObject);
    procedure EListCatalogValuesClick(Sender: TObject);
    procedure EListAutoAddClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure InsertTagClick(Sender: TObject);
    procedure ETemplateChange(Sender: TObject);
    procedure PopupFieldsPopup(Sender: TObject);
  private
  protected
    Properties: TCustomFieldsProperties;
    PropertiesCopy: TCustomFieldsProperties;
    Selected: TCustomFieldProperties;
    procedure LoadOptions; override;
    procedure SaveOptions; override;
    procedure RefreshFieldList;
    procedure LoadSelectedField;
    procedure FillDefaultValues;
    procedure InitFieldTags;
  public
    function Execute(CustomFieldsProperties: TCustomFieldsProperties;
      SelectedCustomField: TCustomFieldProperties = nil): Boolean;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  CustomFieldsManagerWin: TCustomFieldsManagerWin;

implementation

uses
  Global, fields, ProgramSettings, functions_str, functions_tbx, functions_sys,
  getmedia;

const
  // Messages
  msgImportFields     = 0;
  msgExportFields     = 1;
  msgAddField         = 2;
  msgChangeFieldTag   = 3;
  msgNewField         = 4;
  msgTypeString       = 5;
  msgTypeInteger      = 6;
  msgTypeReal1        = 7;
  msgTypeReal2        = 8;
  msgTypeReal         = 9;
  msgTypeBoolean      = 10;
  msgTypeList         = 11;
  msgTypeDate         = 12;
  msgTypeText         = 13;
  msgTypeUrl          = 14;
  msgTypeVirtual      = 15;
  TypeIndex : array[0..10] of TFieldType = (ftString, ftInteger, ftReal1, ftReal2, ftReal, ftBoolean, ftList, ftDate, ftText, ftUrl, ftVirtual);

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.FormCreate(Sender: TObject);
begin
  LoadButtonIcon(btnApply, ICON_FIELDADD);
  btnApply.Tag := Ord(ICON_FIELDADD);
  btnApply.Hint := Messages.Strings[msgAddField];
  LoadButtonIcon(btnDel, ICON_FIELDDEL);
  LoadButtonIcon(btnClearAll, ICON_FILENEW);
  LoadButtonIcon(btnImport, ICON_FILEIMPORT);
  LoadButtonIcon(btnExport, ICON_FILEEXPORT);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.LoadOptions;
var
  i: Integer;
begin
  with Settings do
  begin
    with rCustomFieldsManager do
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
      end; // case
    end; // with rCustomFieldsManager
  end; // with settings
  EType.Items.Clear;
  for i:=0 to Length(TypeIndex)-1 do
  begin
    EType.Items.Add(Messages.Strings[i + msgTypeString]);
  end;
  EMediaInfo.Items.Clear;
  EMediaInfo.Items.Add('');
  for i:=0 to strMedia.Count-1 do
  begin
    EMediaInfo.Items.Add(strMedia.Strings[i]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.SaveOptions;
begin
  with Settings do
  begin
    with rCustomFieldsManager do
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
      end; // case
    end; // with rCustomFieldsManager
  end; // with settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsManagerWin.Execute(CustomFieldsProperties: TCustomFieldsProperties;
  SelectedCustomField: TCustomFieldProperties): Boolean;
var
  i: Integer;
begin
  Properties := CustomFieldsProperties;
  PropertiesCopy := TCustomFieldsProperties.Create(Properties.MovieList);
  PropertiesCopy.Assign(Properties);
  Selected := nil;
  i := Properties.IndexOfObject(SelectedCustomField);
  if (SelectedCustomField <> nil) and (i <> -1) then
    Selected := PropertiesCopy.Objects[i];
  RefreshFieldList;
  LoadSelectedField;
  InitFieldTags;
  Result := ShowModal = mrOk;
  PropertiesCopy.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.RefreshFieldList;
var
  i: Integer;
begin
  EField.OnChange := nil;
  EField.Items.Clear;
  EField.Items.Add(Messages.Strings[msgNewField]);
  EField.ItemIndex := 0;
  for i:=0 to PropertiesCopy.Count-1 do
  begin
    EField.Items.Add(PropertiesCopy.Objects[i].FieldName + ' (' + PropertiesCopy.Strings[i] + ')');
    if Selected = PropertiesCopy.Objects[i] then
      EField.ItemIndex := i+1;
  end;
  if EField.ItemIndex <= 0 then
    Selected := nil;
  EField.OnChange := EFieldChange;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.LoadSelectedField;
var
  i: Integer;
begin
  if Selected = nil then
  begin
    btnDel.Enabled := False;
    btnApply.Enabled := False;
    if (btnApply.Tag <> Ord(ICON_FIELDADD)) then
    begin
      LoadButtonIcon(btnApply, ICON_FIELDADD);
      btnApply.Tag := Ord(ICON_FIELDADD);
      btnApply.Hint := Messages.Strings[msgAddField];
    end;
    EName.Enabled := False;
    LName.Enabled := EName.Enabled;
    EExt.Enabled := False;
    LExt.Enabled := EExt.Enabled;
    EType.Enabled := False;
    LType.Enabled := EType.Enabled;

    EDefaultValue.Visible := True;
    LDefaultValue.Visible := EDefaultValue.Visible;
    EDefaultValue.Enabled := False;
    LDefaultValue.Enabled := EDefaultValue.Enabled;

    ETemplate.Visible := False;
    LTemplate.Visible := ETemplate.Visible;
    BtnInsertFieldTag.Visible := ETemplate.Visible;
    ETemplate.Enabled := False;
    LTemplate.Enabled := ETemplate.Enabled;
    BtnInsertFieldTag.Enabled := ETemplate.Enabled;

    EMediaInfo.Enabled := False;
    LMediaInfo.Enabled := EMediaInfo.Enabled;
    EMultiValues.Enabled := False;
    LMultiValues.Enabled := EMultiValues.Enabled;
    EListValues.Enabled := False;
    LListValues.Enabled := EListValues.Enabled;
    EListSort.Enabled := EListValues.Enabled;
    EListAutoComplete.Enabled := EListValues.Enabled;
    EListCatalogValues.Enabled := EListValues.Enabled;
    EListAutoAdd.Enabled := EListValues.Enabled;

    ETag.Text := '';
    EName.Text := '';
    EExt.Text := '';
    EType.ItemIndex := 0;
    EDefaultValue.Text := '';
    EMediaInfo.ItemIndex := 0;
    EMultiValues.Checked := False;
    EMultiValuesClick(nil);
    EMultiValuesSep.Text := defaultSep;
    EMultiValuesRmP.Checked := False;
    EMultiValuesPatch.Checked := False;
    EListValues.Text := '';
    EListSort.Checked := False;
    EListAutoComplete.Checked := False;
    EListCatalogValues.Checked := False;
    EListCatalogValuesClick(nil);
    EListAutoAdd.Checked := False;
  end
  else
  begin
    btnDel.Enabled := True;
    btnApply.Enabled := False;
    if (btnApply.Tag <> Ord(ICON_FIELDEDIT)) then
    begin
      LoadButtonIcon(btnApply, ICON_FIELDEDIT);
      btnApply.Tag := Ord(ICON_FIELDEDIT);
      btnApply.Hint := Messages.Strings[msgChangeFieldTag];
    end;
    EName.Enabled := True;
    LName.Enabled := EName.Enabled;
    EExt.Enabled := True;
    LExt.Enabled := EExt.Enabled;
    EType.Enabled := True;
    LType.Enabled := EType.Enabled;

    EDefaultValue.Visible := (Selected.FieldType <> ftVirtual);
    LDefaultValue.Visible := EDefaultValue.Visible;
    EDefaultValue.Enabled := EDefaultValue.Visible;
    LDefaultValue.Enabled := EDefaultValue.Enabled;

    ETemplate.Visible := (Selected.FieldType = ftVirtual);
    LTemplate.Visible := ETemplate.Visible;
    BtnInsertFieldTag.Visible := ETemplate.Visible;
    ETemplate.Enabled := ETemplate.Visible;
    LTemplate.Enabled := ETemplate.Enabled;
    BtnInsertFieldTag.Enabled := ETemplate.Enabled;

    EMediaInfo.Enabled := (Selected.FieldType <> ftVirtual);
    LMediaInfo.Enabled := EMediaInfo.Enabled;
    EMultiValues.Enabled := (Selected.FieldType = ftString) or (Selected.FieldType = ftList) or
      (Selected.FieldType = ftText) or (Selected.FieldType = ftVirtual);
    LMultiValues.Enabled := EMultiValues.Enabled;
    EListValues.Enabled := Selected.FieldType = ftList;
    LListValues.Enabled := EListValues.Enabled;
    EListSort.Enabled := EListValues.Enabled;
    EListAutoComplete.Enabled := EListValues.Enabled;
    EListCatalogValues.Enabled := EListValues.Enabled;
    EListAutoAdd.Enabled := EListValues.Enabled;

    ETag.Text := Selected.FieldTag;
    EName.Text := Selected.FieldName;
    EExt.Text := Selected.FieldExt;

    EType.ItemIndex := 0;
    for i:=0 to Length(TypeIndex)-1 do
      if Selected.FieldType = TypeIndex[i] then
        EType.ItemIndex := i;

    if (Selected.FieldType <> ftVirtual) then
      EDefaultValue.Text := ConvertFieldValue(Selected.DefaultValue, Selected.FieldType, True, True, False)
    else
      ETemplate.Text := Selected.DefaultValue;

    EMediaInfo.ItemIndex := IndexText(Selected.MediaInfo, strTagMedia) + 1;
    EMultiValues.Checked := Selected.MultiValues;
    EMultiValuesClick(nil);
    EMultiValuesSep.Text := Selected.MultiValuesSep;
    EMultiValuesRmP.Checked := Selected.MultiValuesRmP;
    EMultiValuesPatch.Checked := Selected.MultiValuesPatch;
    EListValues.Text := Selected.ListValues.Text;
    EListSort.Checked := Selected.ListSort;
    EListAutoComplete.Checked := Selected.ListAutoComplete;
    EListCatalogValues.Checked := Selected.ListUseCatalogValues;
    EListCatalogValuesClick(nil);
    EListAutoAdd.Checked := Selected.ListAutoAdd;
  end;
  FillDefaultValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.FillDefaultValues;
var
  str, str2: string;
begin
  EDefaultValue.Items.Clear;
  if Selected <> nil then
  begin
    if Selected.FieldType = ftBoolean then
    begin
      EDefaultValue.Items.Add('True');
      EDefaultValue.Items.Add('False');
    end else
    if Selected.FieldType = ftDate then
    begin
      EDefaultValue.Items.Add('');
      str2 := DateToStr(Now);
      str := ConvertFieldValue(str2, ftDate, False);
      EDefaultValue.Items.Add(str);
      if str <> str2 then
        EDefaultValue.Items.Add(str2);
      //str := '2012-12-21';
      //str2 := ConvertFieldValue('2012-12-21', ftDate, True);
      //EDefaultValue.Items.Add(str);
      //if str <> str2 then
      //  EDefaultValue.Items.Add(str2);
      EDefaultValue.Items.Add('Today');
    end else
    if Selected.FieldType = ftInteger then
    begin
      EDefaultValue.Items.Add('');
      EDefaultValue.Items.Add('0');
    end else
    if Selected.FieldType = ftReal1 then
    begin
      EDefaultValue.Items.Add('');
      EDefaultValue.Items.Add('0.0');
      EDefaultValue.Items.Add('0,0');
      //EDefaultValue.Items.Add('8.5');
      //EDefaultValue.Items.Add('8,5');
    end else
    if Selected.FieldType = ftReal2 then
    begin
      EDefaultValue.Items.Add('');
      EDefaultValue.Items.Add('0.00');
      EDefaultValue.Items.Add('0,00');
      //EDefaultValue.Items.Add('10.94');
      //EDefaultValue.Items.Add('10,94');
    end else
    if Selected.FieldType = ftReal then
    begin
      EDefaultValue.Items.Add('');
      EDefaultValue.Items.Add('0.000');
      EDefaultValue.Items.Add('0,000');
      //EDefaultValue.Items.Add('23.976');
      //EDefaultValue.Items.Add('23,976');
    end else
      EDefaultValue.Items.Add('');
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btnApplyClick(Sender: TObject);
begin
  inherited;
  if (Selected = nil) then
    Selected := PropertiesCopy.AddField(ETag.Text, True) // True = SpecialAdd
  else
    PropertiesCopy.ChangeFieldTag(Selected.FieldTag, ETag.Text);
  RefreshFieldList;
  LoadSelectedField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btnDelClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
  begin
    PropertiesCopy.DeleteField(Selected.FieldTag);
    RefreshFieldList;
    LoadSelectedField;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btn2Click(Sender: TObject);
begin
  inherited;
  Properties.Assign(PropertiesCopy);
  Properties.CheckFieldTags;
  Properties.CheckFieldValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.ETagChange(Sender: TObject);
var
  s: string;
begin
  inherited;
  s := ETag.Text;
  if ((Selected <> nil) and (s = Selected.FieldTag)) or (not IsValidTag(s)) then
  begin
    btnApply.Enabled := False;
    Exit;
  end;

  if (PropertiesCopy.IndexOf(s) <> -1) and
    ((Selected = nil) or (UpperCase(s) <> UpperCase(Selected.FieldTag))) then
  begin
    btnApply.Enabled := False;
    Exit;
  end;

  btnApply.Enabled := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EFieldChange(Sender: TObject);
begin
  inherited;
  if EField.ItemIndex = 0 then
    Selected := nil
  else
    Selected := PropertiesCopy.Objects[EField.ItemIndex-1];
  LoadSelectedField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.ENameChange(Sender: TObject);
var
  i: Integer;
begin
  inherited;
  if (Selected <> nil) then
  begin
    Selected.FieldName := EName.Text;
    EField.OnChange := nil;
    i := EField.ItemIndex;
    EField.Items.Delete(i);
    EField.Items.Insert(i, Selected.FieldName + ' (' + Selected.FieldTag + ')');
    EField.ItemIndex := i;
    EField.OnChange := EFieldChange;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EExtChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.FieldExt := EExt.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.ETypeChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) and (EType.ItemIndex >= 0) then
  begin
    if PropertiesCopy.ChangeFieldType(Selected.FieldTag, TypeIndex[EType.ItemIndex]) then
    begin
      if TypeIndex[EType.ItemIndex] <> ftVirtual then
        EDefaultValue.Text := ConvertFieldValue(Selected.DefaultValue, Selected.FieldType, True, True, False)
      else
        ETemplate.Text := Selected.DefaultValue;

      EDefaultValue.Visible := (Selected.FieldType <> ftVirtual);
      LDefaultValue.Visible := EDefaultValue.Visible;
      EDefaultValue.Enabled := EDefaultValue.Visible;
      LDefaultValue.Enabled := EDefaultValue.Enabled;

      ETemplate.Visible := (Selected.FieldType = ftVirtual);
      LTemplate.Visible := ETemplate.Visible;
      BtnInsertFieldTag.Visible := ETemplate.Visible;
      ETemplate.Enabled := ETemplate.Visible;
      LTemplate.Enabled := ETemplate.Enabled;
      BtnInsertFieldTag.Enabled := ETemplate.Enabled;

      EMediaInfo.ItemIndex := IndexText(Selected.MediaInfo, strTagMedia) + 1;
      EMediaInfo.Enabled := (Selected.FieldType <> ftVirtual);
      LMediaInfo.Enabled := EMediaInfo.Enabled;

      EMultiValues.Enabled := (Selected.FieldType = ftString) or (Selected.FieldType = ftList) or
        (Selected.FieldType = ftText) or (Selected.FieldType = ftVirtual);
      LMultiValues.Enabled := EMultiValues.Enabled;
      EMultiValues.Checked := Selected.MultiValues;
      EMultiValuesClick(nil);
      EMultiValuesSep.Text := Selected.MultiValuesSep;
      EMultiValuesRmP.Checked := Selected.MultiValuesRmP;
      EMultiValuesPatch.Checked := Selected.MultiValuesPatch;

      EListValues.Enabled := Selected.FieldType = ftList;
      LListValues.Enabled := EListValues.Enabled;
      EListSort.Enabled := EListValues.Enabled;
      EListAutoComplete.Enabled := EListValues.Enabled;
      EListCatalogValues.Enabled := EListValues.Enabled;
      EListAutoAdd.Enabled := EListValues.Enabled;
      EListValues.Text := Selected.ListValues.Text;
      EListSort.Checked := Selected.ListSort;
      EListAutoComplete.Checked := Selected.ListAutoComplete;
      EListCatalogValues.Checked := Selected.ListUseCatalogValues;
      EListCatalogValuesClick(nil);
      EListAutoAdd.Checked := Selected.ListAutoAdd;
    end;
    FillDefaultValues;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EDefaultValueChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.DefaultValue := EDefaultValue.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.ETemplateChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.DefaultValue := ETemplate.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EMediaInfoChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    if (EMediaInfo.ItemIndex > 0) then
      Selected.MediaInfo := strTagMedia[EMediaInfo.ItemIndex-1]
    else
      Selected.MediaInfo := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EMultiValuesClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) and (Sender <> nil) then
    Selected.MultiValues := EMultiValues.Checked;
  EMultiValuesSep.Enabled := EMultiValues.Enabled and EMultiValues.Checked;
  EMultiValuesRmP.Enabled := EMultiValuesSep.Enabled;
  EMultiValuesPatch.Enabled := EMultiValuesSep.Enabled;
  LMultiValuesSep.Enabled := EMultiValuesSep.Enabled;
  LMultiValuesRmP.Enabled := EMultiValuesRmP.Enabled;
  LMultiValuesPatch.Enabled := EMultiValuesPatch.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EMultiValuesSepChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
  if (EMultiValuesSep.Text <> '') then
    Selected.MultiValuesSep := EMultiValuesSep.Text[1]
  else
    Selected.MultiValuesSep := defaultSep;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EMultiValuesRmPClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.MultiValuesRmp := EMultiValuesRmP.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EMultiValuesPatchClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.MultiValuesPatch := EMultiValuesPatch.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EListValuesChange(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.ListValues.Text := EListValues.Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EListSortClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.ListSort := EListSort.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EListAutoCompleteClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.ListAutoComplete := EListAutoComplete.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EListCatalogValuesClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) and (Sender <> nil) then
    Selected.ListUseCatalogValues := EListCatalogValues.Checked;
  EListValues.Enabled := EListCatalogValues.Enabled and (not EListCatalogValues.Checked);
  EListAutoAdd.Enabled := EListValues.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.EListAutoAddClick(Sender: TObject);
begin
  inherited;
  if (Selected <> nil) then
    Selected.ListAutoAdd := EListAutoAdd.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btnClearAllClick(Sender: TObject);
begin
  inherited;
  PropertiesCopy.Clear;
  RefreshFieldList;
  LoadSelectedField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btnImportClick(Sender: TObject);
begin
inherited;
  with TOpenDialog.Create(Self) do
  try
    InitialDir := Settings.rOptions.rFolders[fuCustomFields].Value;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Options := DialogOpenOptions;
    Title := Messages.Strings[msgImportFields];
    Filter := DialogCatalogFilter;
    FileName := '';
    if Execute then
    begin
      Settings.rOptions.rFolders[fuCustomFields].Value := ExtractFilePath(FileName);
      SetCurrentDir(strDirCatalogs);
      if FileExists(ExpandFileName(FileName)) then
      begin
        if SameText(ExtractFileExt(FileName), '.xml') then
          PropertiesCopy.ImportFromXML(ExpandFileName(FileName), True)
        else if SameText(ExtractFileExt(FileName), '.amc') then
          PropertiesCopy.ImportFromAMC(ExpandFileName(FileName), True);
      end;
      RefreshFieldList;
      LoadSelectedField;
    end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.btnExportClick(Sender: TObject);
begin
  inherited;
  with TSaveDialog.Create(Self) do
  try
    InitialDir := Settings.rOptions.rFolders[fuCustomFields].Value;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Options := DialogSaveOptions;
    Title := Messages.Strings[msgExportFields];
    Filter := DialogXmlFilter;
    FileName := 'CustomFields';
    DefaultExt := 'xml';
    if Execute then
    begin
      Settings.rOptions.rFolders[fuCustomFields].Value := ExtractFilePath(FileName);
      PropertiesCopy.ExportToXML(FileName);
    end;
  finally
    Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.FormResize(Sender: TObject);
begin
  inherited;
  EDefaultValue.SelLength := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.InitFieldTags;
var
  i: Integer;
  newMenuItem : TTBXItem;
begin
  PopupFields.Items.Clear;

  for i := 0 to strFields.Count-1 do
    if not (i in VirtualFields) then
    begin
      newMenuItem := TTBXItem.Create(PopupFields);
      PopupFields.Items.Add(newMenuItem);
      with newMenuItem do
      begin
        Name := strTagFields[i];
        Caption := strFields.Strings[i] + ' (' + strTagFields[i] + ')';
        OnClick := InsertTagClick;
      end;
    end;

  with PropertiesCopy do
    for i := 0 to Count-1 do
      if Objects[i].FieldType <> ftVirtual then
      begin
        newMenuItem := TTBXItem.Create(PopupFields);
        PopupFields.Items.Add(newMenuItem);
        with newMenuItem, Objects[i] do
        begin
          Name := FieldTag;
          Caption := FieldName + ' (' + FieldTag + ')';
          OnClick := InsertTagClick;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.PopupFieldsPopup(Sender: TObject);
begin
  InitFieldTags; // Need to be refreshed if custom fields have been modified
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsManagerWin.InsertTagClick(Sender: TObject);
var
  pos: Integer;
begin
  pos := ETemplate.SelStart;
  if ETemplate.CanFocus then
    ETemplate.SetFocus;
  ETemplate.SelLength := 0;
  ETemplate.SelStart := pos;
  ETemplate.SelText := '[' + TTBXItem(Sender).Name + ']';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
