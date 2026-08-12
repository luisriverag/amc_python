(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2013 Antoine Potten, Mickaël Vanneufville                      *
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

unit framefilenaming;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ProgramSettings, fields, movieclass;

type
  TFileNamingFrame = class(TFrame)
    grp: TGroupBox;
    LPrefix: TLabel;
    EPrefix: TComboBox;
    LPlus1: TLabel;
    ESep1: TEdit;
    LPlus2: TLabel;
    LMovieInfo: TLabel;
    EMovieInfo: TComboBox;
    LPlus3: TLabel;
    ESep2: TEdit;
    LPlus4: TLabel;
    LExtraInfo: TLabel;
    EExtraInfo: TComboBox;
    CBMovieNumberAddZeroes: TCheckBox;
    CBExtraNumberAddZeroes: TCheckBox;
    procedure EPrefixClick(Sender: TObject);
    procedure EMovieInfoClick(Sender: TObject);
    procedure EExtraInfoClick(Sender: TObject);
  private
    Properties: TCustomFieldsProperties;
    procedure FillMovieCB;
    procedure FillExtraCB;
  public
    procedure LoadFromObject(FileNaming: TFileNaming;
      CustomFieldsProperties: TCustomFieldsProperties);
    procedure SaveToObject(FileNaming: TFileNaming);
  end;

implementation

uses
  functions_str;

{$R *.dfm}

{-------------------------------------------------------------------------------
  TFileNamingFrame
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.LoadFromObject(FileNaming: TFileNaming;
  CustomFieldsProperties: TCustomFieldsProperties);
var
  i, iField, select: Integer;
begin
  Properties := CustomFieldsProperties;
  FillMovieCB;
  FillExtraCB;
  with FileNaming do
  begin
    if (Prefix >= 0) and (Prefix < EPrefix.Items.Count) then
      EPrefix.ItemIndex := Prefix
    else
      EPrefix.ItemIndex := 0;

    if MovieFieldName = '' then
      EMovieInfo.ItemIndex := 0
    else if MovieFieldName = '*OriginalFileName*' then
      EMovieInfo.ItemIndex := 1
    else
    begin
      select := 0;
      iField := IndexText(MovieFieldName, strTagFields);
      if (iField = -1) and (Properties <> nil) then
      begin
        iField := Properties.IndexOf(MovieFieldName);
        if iField <> -1 then
          iField := iField + customFieldLow;
      end;
      if iField <> -1 then
      begin
        for i := 2 to EMovieInfo.Items.Count-1 do
          if Integer(EMovieInfo.Items.Objects[i]) = iField then
          begin
            select := i;
            break;
          end;
      end;
      EMovieInfo.ItemIndex := select;
    end;

    if ExtraFieldName = '' then
      EExtraInfo.ItemIndex := 0
    else
    begin
      select := 0;
      iField := IndexText(ExtraFieldName, strTagExtraFields);
      if iField <> -1 then
      begin
        iField := iField + extraFieldLow;
        for i := 1 to EExtraInfo.Items.Count-1 do
          if Integer(EExtraInfo.Items.Objects[i]) = iField then
          begin
            select := i;
            break;
          end;
      end;
      EExtraInfo.ItemIndex := select;
    end;

    ESep1.Text := Separator1;
    ESep2.Text := Separator2;
    CBMovieNumberAddZeroes.Checked := MovieNumberAddZeroes;
    CBExtraNumberAddZeroes.Checked := ExtraNumberAddZeroes;
    EPrefixClick(Self);
    EMovieInfoClick(Self);
    EExtraInfoClick(Self);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.SaveToObject(FileNaming: TFileNaming);
var
  iField: Integer;
begin
  with FileNaming do
  begin
    Prefix := EPrefix.ItemIndex;
    if (EMovieInfo.ItemIndex = -1) or (EMovieInfo.ItemIndex = 0) then
      MovieFieldName := ''
    else if EMovieInfo.ItemIndex = 1 then
      MovieFieldName := '*OriginalFileName*'
    else
    begin
      iField := Integer(EMovieInfo.Items.Objects[EMovieInfo.ItemIndex]);
      if (iField >= customFieldLow) then
        MovieFieldName := Properties.Strings[iField - customFieldLow]
      else
        MovieFieldName := strTagFields[iField];
    end;

    if (EExtraInfo.ItemIndex = -1) or (EExtraInfo.ItemIndex = 0) then
      ExtraFieldName := ''
    else
    begin
      iField := Integer(EExtraInfo.Items.Objects[EExtraInfo.ItemIndex]);
      ExtraFieldName := strTagExtraFields[iField - extraFieldLow];
    end;

    Separator1 := ESep1.Text;
    Separator2 := ESep2.Text;
    MovieNumberAddZeroes := CBMovieNumberAddZeroes.Checked;
    ExtraNumberAddZeroes := CBExtraNumberAddZeroes.Checked;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.FillMovieCB;
var
  i: Integer;
begin
  EMovieInfo.Items.BeginUpdate;
  while (EMovieInfo.Items.Count > 2) do
    EMovieInfo.Items.Delete(EMovieInfo.Items.Count-1);
  for i := fieldLow to fieldCount-1 do
  begin
    if i in [fieldNumber, fieldMedia, fieldOriginalTitle, fieldTranslatedTitle,
      fieldFormattedTitle] then
      EMovieInfo.Items.AddObject(strFields[i], Pointer(i));
  end;
  if Properties <> nil then
    for i := 0 to Properties.Count-1 do
    begin
      if Properties.Objects[i].FieldType <> ftText then
        EMovieInfo.Items.AddObject(Properties.Objects[i].FieldName, Pointer(customFieldLow + i));
    end;
  EMovieInfo.Items.EndUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.FillExtraCB;
var
  i: Integer;
begin
  EExtraInfo.Items.BeginUpdate;
  while (EExtraInfo.Items.Count > 1) do
    EExtraInfo.Items.Delete(EExtraInfo.Items.Count-1);
  for i := extraFieldLow to extraFieldCount-1 do
  begin
    if i in [extraFieldNumber, extraFieldTag, extraFieldTitle] then
      EExtraInfo.Items.AddObject(strExtraFields[i - extraFieldLow], Pointer(i));
  end;
  EExtraInfo.Items.EndUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.EPrefixClick(Sender: TObject);
begin
  ESep1.Enabled := (EPrefix.ItemIndex <> 0);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.EMovieInfoClick(Sender: TObject);
begin
  EExtraInfo.Enabled := (EMovieInfo.ItemIndex <> 1);
  ESep1.Enabled := (EPrefix.ItemIndex <> 0);
  ESep2.Enabled := (EMovieInfo.ItemIndex > 1) and (EExtraInfo.ItemIndex <> 0);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFileNamingFrame.EExtraInfoClick(Sender: TObject);
begin
  ESep2.Enabled := (EMovieInfo.ItemIndex > 1) and (EExtraInfo.ItemIndex <> 0);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
