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

unit framefields;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, TBXDkPanels, movieclass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TFieldsFrame = class(TFrame)
    LAvailable: TLabel;
    LSelected: TLabel;
    LbSelected: TListBox;
    LbAvailable: TListBox;
    BtnAdd: TTBXButton;
    BtnRem: TTBXButton;
    BtnAddAll: TTBXButton;
    BtnRemAll: TTBXButton;
    BtnUp: TTBXButton;
    BtnDown: TTBXButton;
    procedure BtnAddClick(Sender: TObject);
    procedure BtnRemClick(Sender: TObject);
    procedure BtnAddAllClick(Sender: TObject);
    procedure BtnRemAllClick(Sender: TObject);
    procedure BtnUpClick(Sender: TObject);
    procedure BtnDownClick(Sender: TObject);
    procedure LbDblClick(Sender: TObject);
    procedure LbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    FIncludeExtrasFields: Boolean;
    FOnlyExtraFields: Boolean;
    function GetIdxOfObjectValue(const Value: string; const List: TStrings): Integer;
    function GetSelectedCount: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure LoadFromStrings(FieldsList: TStrings; Properties: TCustomFieldsProperties;
      IncludeExtrasFields: Boolean = False; OnlyExtraFields: Boolean = False);
    // Call this function when custom fields properties (Name, Tag) change to update this frame !
    procedure CheckCustomFieldsProperties(Properties: TCustomFieldsProperties);
    procedure SaveToStrings(FieldsList: TStrings; Properties: TCustomFieldsProperties);
    procedure DeleteField(const field: Integer);
    procedure DeleteCustomField(const fieldTag: string);
    property SelectedCount: Integer read GetSelectedCount;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  fields, Global, ConstValues, functions_tbx;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TFieldsFrame.Create(AOwner: TComponent);
begin
  inherited;
  LoadButtonIcon(BtnAdd, ICON_MOVERIGHT);
  LoadButtonIcon(BtnRem, ICON_MOVELEFT);
  LoadButtonIcon(BtnAddAll, ICON_MOVERIGHTALL);
  LoadButtonIcon(BtnRemAll, ICON_MOVELEFTALL);
  LoadButtonIcon(BtnUp, ICON_MOVEUP);
  LoadButtonIcon(BtnDown, ICON_MOVEDOWN);
  FOnlyExtraFields := False;
  FIncludeExtrasFields := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TFieldsFrame.Destroy;
begin
  FreeObjects(LbSelected.Items);
  FreeObjects(LbAvailable.Items);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnAddClick(Sender: TObject);
var
  idx: integer;
begin
  idx := LbAvailable.ItemIndex;
  if idx <> -1 then
  begin
    LbSelected.Items.AddObject(LbAvailable.Items.Strings[idx], LbAvailable.Items.Objects[idx]);
    LbAvailable.Items.Delete(idx);
    if idx < LbAvailable.Items.Count then
      LbAvailable.ItemIndex := idx
    else
      LbAvailable.ItemIndex := idx-1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnRemClick(Sender: TObject);
var
  idx: integer;
begin
  idx := LbSelected.ItemIndex;
  if idx <> -1 then
  begin
    LbAvailable.Items.AddObject(LbSelected.Items.Strings[idx], LbSelected.Items.Objects[idx]);
    LbSelected.Items.Delete(idx);
    if idx < LbSelected.Items.Count then
      LbSelected.ItemIndex := idx
    else
      LbSelected.ItemIndex:=idx-1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnAddAllClick(Sender: TObject);
begin
  while LbAvailable.Items.Count > 0 do
  begin
    LbSelected.Items.AddObject(LbAvailable.Items.Strings[0], LbAvailable.Items.Objects[0]);
    LbAvailable.Items.Delete(0);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnRemAllClick(Sender: TObject);
begin
  while LbSelected.Items.Count > 0 do
  begin
    LbAvailable.Items.AddObject(LbSelected.Items.Strings[0], LbSelected.Items.Objects[0]);
    LbSelected.Items.Delete(0);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnUpClick(Sender: TObject);
var
  idx: integer;
begin
  idx := LbSelected.ItemIndex;
  if idx > 0 then
  begin
    LbSelected.Items.Move(idx,idx-1);
    LbSelected.ItemIndex:=idx-1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.BtnDownClick(Sender: TObject);
var
  idx: integer;
begin
  idx := LbSelected.ItemIndex;
  if idx < LbSelected.Items.Count-1 then
  begin
    LbSelected.Items.Move(idx,idx+1);
    LbSelected.ItemIndex:=idx+1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.LbDblClick(Sender: TObject);
begin
  if Sender = LbAvailable then
    BtnAdd.Click
  else
  if Sender = LbSelected then
    BtnRem.Click
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.LbKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Sender is TListBox then
  begin
    if (Key = VK_DELETE) and (Sender = LbSelected) then
      BtnRem.Click
    else
    if (Key = VK_ADD) and (Sender = LbAvailable) then
      BtnAdd.Click
    else
    if (Key = VK_ADD) and (Sender = LbSelected) then
      BtnUp.Click
    else
    if (Key = VK_SUBTRACT) and (Sender = LbSelected) then
      BtnDown.Click
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TFieldsFrame.GetIdxOfObjectValue(const Value: string; const List: TStrings): Integer;
var
 i: Integer;
 str1, str2: string;
begin
  Result := -1;
  for i := 0 to List.Count-1 do
  begin
    str1 := Value;
    str2 := TString(List.Objects[i]).Str;
    if (Length(str1) > 0) and (str1[1] = '-') then
      Delete(str1, 1, 1);
    if (Length(str2) > 0) and (str2[1] = '-') then
      Delete(str2, 1, 1);
    if SameText(str1, str2) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TFieldsFrame.GetSelectedCount : Integer;
begin
  Result := LbSelected.Items.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.LoadFromStrings(FieldsList: TStrings;
  Properties: TCustomFieldsProperties;
  IncludeExtrasFields: Boolean; OnlyExtraFields: Boolean);
var
  i, field: Integer;
  FieldProperties: TCustomFieldProperties;
  str, order: string;
begin
  FIncludeExtrasFields := IncludeExtrasFields;
  FOnlyExtraFields := OnlyExtraFields;

  FreeObjects(LbSelected.Items);
  LbSelected.Items.Clear;
  FreeObjects(LbAvailable.Items);
  LbAvailable.Items.Clear;

  LbSelected.Items.BeginUpdate;
  LbAvailable.Items.BeginUpdate;

  for i := 0 to FieldsList.Count-1 do
  begin
    order := '';
    str := FieldsList.Strings[i];
    if Length(str) > 0 then
    begin
      if str[1] = '-' then
      begin
        order := ' - ';
        Delete(str, 1, 1);
      end;
      if Length(str) > 0 then
      begin
        if not FOnlyExtraFields then
        begin
          if (str[1] in ['0'..'9']) then // movie field or extra field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= fieldLow) and (field < fieldCount) and
              (GetIdxOfObjectValue(str, LbSelected.Items) = -1)  then
              LbSelected.Items.AddObject(order + strFields[field], TString.Create(FieldsList.Strings[i]))
            else if FIncludeExtrasFields and (field >= extraFieldLow) and (field < extraFieldCount) and
              (GetIdxOfObjectValue(str, LbSelected.Items) = -1) then
              LbSelected.Items.AddObject(order + strExtraFields[field - extraFieldLow] +
              ' (' + strExtras + ')', TString.Create(FieldsList.Strings[i]));
          end else if Properties <> nil then // custom field (Custom Field Tag)
          begin
            FieldProperties := Properties.GetField(str);
            if (FieldProperties <> nil) and (GetIdxOfObjectValue(str, LbSelected.Items) = -1) then
              LbSelected.Items.AddObject(order + FieldProperties.FieldName, TString.Create(FieldsList.Strings[i]));
          end;
        end else
        begin
          if (str[1] in ['0'..'9']) then // extra field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= extraFieldLow) and (field < extraFieldCount) and
              (GetIdxOfObjectValue(str, LbSelected.Items) = -1)  then
              LbSelected.Items.AddObject(order + strExtraFields[field - extraFieldLow], TString.Create(FieldsList.Strings[i])) ;
          end;
        end;
      end;
    end;
  end;

  if not FOnlyExtraFields then
  begin
    for i := fieldLow to fieldCount-1 do
      if (GetIdxOfObjectValue(IntToStr(i), LbSelected.Items) = -1) then
        LbAvailable.Items.AddObject(strFields[i], TString.Create(IntToStr(i)));

    if Properties <> nil then
      for i := 0 to Properties.Count-1 do
      begin
        FieldProperties := Properties.Objects[i];
        if (GetIdxOfObjectValue(FieldProperties.FieldTag, LbSelected.Items) = -1) then
          LbAvailable.Items.AddObject(FieldProperties.FieldName, TString.Create(FieldProperties.FieldTag));
      end;

    if FIncludeExtrasFields then
      for i := extraFieldLow to extraFieldCount-1 do
        if (GetIdxOfObjectValue(IntToStr(i), LbSelected.Items) = -1) then
          LbAvailable.Items.AddObject(strExtraFields[i - extraFieldLow] +
          ' (' + strExtras + ')', TString.Create(IntToStr(i)));
  end else
  begin
    for i := extraFieldLow to extraFieldCount-1 do
      if (GetIdxOfObjectValue(IntToStr(i), LbSelected.Items) = -1) then
        LbAvailable.Items.AddObject(strExtraFields[i - extraFieldLow], TString.Create(IntToStr(i)));
  end;

  LbAvailable.Items.EndUpdate;
  LbSelected.Items.EndUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.CheckCustomFieldsProperties(Properties: TCustomFieldsProperties);
var
  i: integer;
  FieldProperties: TCustomFieldProperties;
  str: string;
begin
  FieldProperties := nil;
  if not FOnlyExtraFields then
  begin
    for i := LbSelected.Items.Count-1 downto 0 do
    begin
      str := TString(LbSelected.Items.Objects[i]).Str;
      if (Length(str) > 0) and (str[1] = '-') then
        Delete(str, 1, 1);
      if (Length(str) = 0) or (not (str[1] in ['0'..'9'])) then // custom field (Custom Field Tag)
      begin
        if Properties <> nil then
          FieldProperties := Properties.GetField(str);
        if (FieldProperties = nil) then
        begin
          LbSelected.Items.Objects[i].Free;
          LbSelected.Items.Delete(i);
        end;
      end;
    end;

    for i := LbAvailable.Items.Count-1 downto 0 do
    begin
      str := TString(LbAvailable.Items.Objects[i]).Str;
      if (Length(str) > 0) and (str[1] = '-') then
        Delete(str, 1, 1);
      if (Length(str) = 0) or (not (str[1] in ['0'..'9'])) then // custom field (Custom Field Tag)
      begin
        if Properties <> nil then
          FieldProperties := Properties.GetField(str);
        if (FieldProperties = nil) then
        begin
          LbAvailable.Items.Objects[i].Free;
          LbAvailable.Items.Delete(i);
        end;
      end;
    end;

    if Properties <> nil then
      for i := 0 to Properties.Count-1 do
      begin
        FieldProperties := Properties.Objects[i];
        if (GetIdxOfObjectValue(FieldProperties.FieldTag, LbSelected.Items) = -1) and
           (GetIdxOfObjectValue(FieldProperties.FieldTag, LbAvailable.Items) = -1) then
          LbAvailable.Items.AddObject(FieldProperties.FieldName, TString.Create(FieldProperties.FieldTag));
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.SaveToStrings(FieldsList: TStrings; Properties: TCustomFieldsProperties);
var
  i, field: Integer;
  FieldProperties: TCustomFieldProperties;
  str: string;
begin
  FieldsList.Clear;
  for i := 0 to LbSelected.Items.Count-1 do
  begin
    str := TString(LbSelected.Items.Objects[i]).Str;
    if Length(str) > 0 then
    begin
      if str[1] = '-' then
        Delete(str, 1, 1);
      if Length(str) > 0 then
      begin
        if not FOnlyExtraFields then
        begin
          if (str[1] in ['0'..'9']) then // movie field or extra field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= fieldLow) and (field < fieldCount) then
              FieldsList.Add(TString(LbSelected.Items.Objects[i]).Str)
            else if FIncludeExtrasFields and (field >= extraFieldLow) and (field < extraFieldCount) then
              FieldsList.Add(TString(LbSelected.Items.Objects[i]).Str)
          end
          else if Properties <> nil then // custom field (Custom Field Tag)
          begin
            FieldProperties := Properties.GetField(str);
            if (FieldProperties <> nil) then
              FieldsList.Add(TString(LbSelected.Items.Objects[i]).Str);
          end;
        end else
        begin
          if (str[1] in ['0'..'9']) then // extra field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= extraFieldLow) and (field < extraFieldCount) then
              FieldsList.Add(TString(LbSelected.Items.Objects[i]).Str)
          end
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.DeleteField(const field: Integer);
var
  idx: integer;
begin
  idx := GetIdxOfObjectValue(IntToStr(field), LbSelected.Items);
  if idx <> -1 then
  begin
    LbSelected.Items.Objects[idx].Free;
    LbSelected.Items.Delete(idx);
  end;
  idx := GetIdxOfObjectValue(IntToStr(field), LbAvailable.Items);
  if idx <> -1 then
  begin
    LbAvailable.Items.Objects[idx].Free;
    LbAvailable.Items.Delete(idx);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TFieldsFrame.DeleteCustomField(const fieldTag: string);
var
  idx: integer;
begin
  idx := GetIdxOfObjectValue(fieldTag, LbSelected.Items);
  if idx <> -1 then
  begin
    LbSelected.Items.Objects[idx].Free;
    LbSelected.Items.Delete(idx);
  end;
  idx := GetIdxOfObjectValue(fieldTag, LbAvailable.Items);
  if idx <> -1 then
  begin
    LbAvailable.Items.Objects[idx].Free;
    LbAvailable.Items.Delete(idx);
  end;
end;

end.
