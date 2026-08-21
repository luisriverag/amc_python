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

unit framemoviecustom;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Contnrs,

  AntJvEdit, AntJvSpin, AntJvExControls, AntJvToolEdit,

  movieclass, ConstValues, ComCtrls, ActnList, TB2Item, TBX, Menus;

const
  CF_FrameMarginLeft = 6;
  CF_FrameMarginRight = 1;
  CF_FrameMarginTop = 0;
  CF_FrameMarginBottom = 0;
  CF_PanelMarginLeft =  2;
  CF_PanelMarginRight = 2;
  CF_PanelMarginTop = 2;
  CF_PanelMarginBottom = 2;
  CF_PanelBorderSize = 2;
  CF_PanelHeight = 25;
  CF_PanelHeightText = 55;
  CF_PanelWidth = 200;
  CF_PanelMinWidth = 32;
  CF_PanelMaxWidth = 0; //infinite
  CF_PanelMinHeight = 25;
  CF_PanelMaxHeight = 0; //infinite
  CF_LabelWidth = 94;
  CF_LabelMinWidth = 12;
  CF_LabelMaxWidth = 0; //infinite
  CF_PanelMarginBetween = 4; //margin between label and control

var
  CF_FrameWidthRef: Integer = 533;
  CF_FrameHeightRef: Integer = 449;
  CF_TabOrderSeq: Integer;

type
  {ExtrasViewer}
  PCacheItem = ^TCacheItem;
  TCacheItem = record
    Picture: TMoviePicture;
    Size: Integer;
    Age: TDateTime;
    Scale: Integer;
    Bmp: TBitmap;
  end;
  
  TPanelCustomField = class(TPanel)
    procedure FieldChange(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldURLButtonClick(Sender: TObject);

  private
    FEnabled: Boolean;
    FBorder: Boolean;
    FType: TFieldType;
    FName: string;
    FLabel: TLabel;
    FExt: string;
    FLabelExt: TLabel;
    FControl: TControl;

    FOnFieldChange: TNotifyEvent;
    FOnFieldValidate: TNotifyEvent;
    FOnURLButtonClick: TNotifyEvent;
    FOnURLEnter: TNotifyEvent;

    procedure FSetEnabled(Value: Boolean);
    procedure FSetBorder(Value: Boolean);
    procedure FSetName(Value: string);
    procedure FSetExt(Value: string); // PanelResize need to be call after FSetExt
    procedure FSetType(Value: TFieldType); // Create labels/controls and call PanelResize
    function FGetValue(): string; // Value using AMC FormatSettings
    procedure FSetValue(Value: string); // Value using AMC FormatSettings
    function FGetLabelWidth(): Integer;
    procedure FSetLabelWidth(Value: Integer);

  public
    Properties: TCustomFieldProperties; // ref on FieldProperties in movieclass

    // Custom Field GUI Properties
    AutoStretchWidth: Boolean;
    AutoStretchHeight: Boolean;
    PosXRef: Integer; // according to const value CF_FrameWidthRef
    PosYRef: Integer; // according to const value CF_FrameHeightRef
    WidthRef: Integer; // according to const value CF_FrameWidthRef
    HeightRef: Integer; // according to const value CF_FrameHeightRef

    // Temporary values
    CTag: Integer;

    constructor Create(AOwner: TComponent); override;
    procedure Init(FieldProperties: TCustomFieldProperties);
    procedure LoadGUIProperties;
    procedure SaveGUIProperties;
    procedure PanelResize(Sender: TObject);

    property OnFieldChange: TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property OnFieldValidate: TNotifyEvent read FOnFieldValidate write FOnFieldValidate;
    property OnURLButtonClick: TNotifyEvent read FOnURLButtonClick write FOnURLButtonClick;
    property OnURLEnter: TNotifyEvent read FOnURLEnter write FOnURLEnter;
  end;

  TAutoLayoutBox = class(TObject)
  private
    FVertical: Boolean; // Vertical or horizontal boxes
    FBoxes: TObjectList; // List of TAutoLayoutBox
    FPanel: TPanelCustomField; // Associated panel alone in box
    FBadPanels: TObjectList; // List of TPanelCustomField that can not be dissociated in box
    procedure AddPanels(Panels: TObjectList; LastNbLines: Integer = 0; LastNbColumns: Integer = 0); // List of TPanelCustomField
  protected
    // Calculated values used for positioning and resize
    LeftRef: Integer;
    TopRef: Integer;
    RightRef: Integer;
    BottomRef: Integer;
    MinStretchWidth: Integer;
    MaxStretchWidth: Integer;
    MinStretchHeight: Integer;
    MaxStretchHeight: Integer;
    // Temporary values used for positioning and resize
    StretchWidth: Integer;
    StretchHeight: Integer;
    MoveX: Integer;
    MoveY: Integer;
  public
    constructor Create(Panels: TObjectList; Vertical: Boolean = False; LastNbLines: Integer = 0; LastNbColumns: Integer = 0);
    destructor Destroy; override;
    procedure SetRelativeBounds(x, y, w, h: Integer);
  end;

  TMovieFrameCustom = class(TFrame)
    ActionList1: TActionList;
    ActionAddCustomField: TAction;
    ActionDeleteCustomField: TAction;
    ActionMoveResizeCustomFields: TAction;
    ActionModifyCustomField: TAction;
    PopupCustomField: TTBPopupMenu;
    TBModifyCustomField: TTBXItem;
    TBDeleteCustomField: TTBXItem;
    ActionDefaultPositioning: TAction;
    ActionAutoStretchWidth: TAction;
    ActionAutoStretchHeight: TAction;
    TBSep1: TTBXSeparatorItem;
    TBAutoStretchWidth: TTBXItem;
    TBAutoStretchHeight: TTBXItem;
    TBAddCustomField: TTBXItem;
    TBMoveResizeCustomField: TTBXItem;
    TBSep2: TTBXSeparatorItem;
    TBDefaultPositioning: TTBXItem;

    procedure FieldChange(Sender: TObject);
    procedure FieldPropertiesChange(Sender: TObject);
    procedure FieldValidate(Sender: TObject);
    procedure FieldURLEnter(Sender: TObject);
    procedure FieldURLButtonClick(Sender: TObject);

    procedure FrameResize(Sender: TObject);

    procedure ActionMoveResizeCustomFieldsExecute(Sender: TObject);
    procedure ActionAddCustomFieldExecute(Sender: TObject);
    procedure ActionDeleteCustomFieldExecute(Sender: TObject);

    procedure ControlMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ControlMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FrameMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ActionModifyCustomFieldExecute(Sender: TObject);
    procedure ActionDefaultPositioningExecute(Sender: TObject);
    procedure ActionAutoStretchWidthExecute(Sender: TObject);
    procedure ActionAutoStretchHeightExecute(Sender: TObject);

  private
    FModified: Boolean;
    FPropertiesModified: Boolean;
    FUpdateCount: Integer;
    FGeneratedFields: Boolean;
    FAllowEdit: Boolean;
    FSelectedPanel: TPanelCustomField;
    FMovingPanel: TPanelCustomField;
    FResizing: Integer;
    FSubVertScrollBar: Boolean;
    FSubHorizScrollBar: Boolean;
    FOldPos: TPoint;
    FAutoLayoutBox: TAutoLayoutBox;

    FOnFieldChange: TNotifyEvent;
    FOnFieldPropertiesChange: TNotifyEvent;
    FOnFieldAdd: TNotifyEvent;
    FOnFieldDelete: TNotifyEvent;
    FOnFieldModify: TNotifyEvent;
    FOnFieldValidate: TNotifyEvent;
    FOnURLButtonClick: TNotifyEvent;
    FOnURLEnter: TNotifyEvent;

    procedure SetAllowEdit(Value: Boolean);
    procedure SetFieldsEnabled(Value: Boolean);
    procedure SetFieldsBorder(Value: Boolean);

    procedure CheckFieldsPosition;
    procedure GenerateAutoLayoutBox;
    procedure UpdateFieldsProperties;
    function AddField(FieldProperties: TCustomFieldProperties; Visible: Boolean = True): TPanelCustomField; overload;

  public
    Properties: TCustomFieldsProperties; //ref on FieldsProperties in movieclass

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Init;
    procedure Translate;

    procedure ClearFields;
    procedure GenerateFields;
    procedure LoadFieldsProperties;
    procedure SaveFieldsProperties;

    procedure SetDefaultValues;
    procedure LoadFromObject(AMovie: TMovie);
    procedure SaveToObject(AMovie: TMovie; const ForceSave: Boolean = False);

    procedure LoadLists;
    procedure SaveLists;
    procedure UpdateLists;

    function GetCurrentValue(FieldProperties: TCustomFieldProperties; LocalFormatSettings: Boolean = False; ReturnEmptyIfFalse: Boolean = True): string; overload;
    function GetCurrentValue(FieldTag: string; LocalFormatSettings: Boolean = False; ReturnEmptyIfFalse: Boolean = True): string; overload;
    procedure SetCurrentValue(FieldProperties: TCustomFieldProperties; FieldValue: string); overload;
    procedure SetCurrentValue(FieldTag: string; FieldValue: string); overload;

    function FindURLControl(str: string): TAntJvComboEditXP;

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: Boolean;

    property AllowEdit: Boolean read FAllowEdit write SetAllowEdit;
    property Modified: Boolean read FModified write FModified;
    property PropertiesModified: Boolean read FPropertiesModified write FPropertiesModified;
    property OnFieldChange: TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property OnFieldPropertiesChange: TNotifyEvent read FOnFieldPropertiesChange write FOnFieldPropertiesChange;
    property OnFieldAdd: TNotifyEvent read FOnFieldAdd write FOnFieldAdd;
    property OnFieldDelete: TNotifyEvent read FOnFieldDelete write FOnFieldDelete;
    property OnFieldModify: TNotifyEvent read FOnFieldModify write FOnFieldModify;
    property OnFieldValidate: TNotifyEvent read FOnFieldValidate write FOnFieldValidate;
    property OnURLButtonClick: TNotifyEvent read FOnURLButtonClick write FOnURLButtonClick;
    property OnURLEnter: TNotifyEvent read FOnURLEnter write FOnURLEnter;
  end;

implementation

uses
  Global, StrUtils, Math, functions_str, functions_files, fields;

{$R *.dfm}

{-------------------------------------------------------------------------------
  TPanelCustomField
-------------------------------------------------------------------------------}

constructor TPanelCustomField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Top := CF_FrameMarginTop;
  Left := CF_FrameMarginLeft;
  Height := CF_PanelHeight;
  Width := CF_PanelWidth;
  Constraints.MinHeight := Height;
  Constraints.MaxHeight := Height;
  Constraints.MinWidth := CF_PanelMinWidth;
  Constraints.MaxWidth := CF_PanelMaxWidth;
  ParentColor := True;
  ParentBackground := True;
  BevelOuter := bvNone;
  //Ctl3D := False;
  //ParentCtl3D := False;
  OnResize := PanelResize;

  FLabel := nil;
  FLabelExt := nil;
  FControl := nil;

  FName := '';
  FExt := '';
  FType := ftString;
  Properties := nil;

  FSetEnabled(False);
  FSetBorder(False);

  PosXRef := -1;
  PosYRef := -1;
  WidthRef := -1;
  HeightRef := -1;
  AutoStretchWidth := True;
  AutoStretchHeight := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.Init(FieldProperties: TCustomFieldProperties);
begin
  Properties := FieldProperties;
  if(Properties = nil) then
    Exit;
  Name := 'P' + Properties.FieldTag;
  Caption := '';
  FSetName(FieldProperties.FieldName);
  FSetExt(FieldProperties.FieldExt); // PanelResize call in FSetType
  FSetType(FieldProperties.FieldType);
  FSetValue('');
  FieldProperties.FieldObject := Self; //ref
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.SaveGUIProperties;
begin
  if(Properties = nil) then
    Exit;
  Properties.GUIProperties := 'rx' + FloatToStr(PosXRef, FormatSettings) +
    ':ry' + FloatToStr(PosYRef, FormatSettings) +
    ':rw' + FloatToStr(WidthRef, FormatSettings) +
    ':rh' + FloatToStr(HeightRef, FormatSettings) +
    ':aw' + IfThen(AutoStretchWidth, '1', '0') +
    ':ah' + IfThen(AutoStretchHeight, '1', '0') +
    ':lw' + IntToStr(FGetLabelWidth);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.LoadGUIProperties;
var
  s, tag, value: string;
  p, LabelWidth: Integer;
begin
  if(Properties = nil) then
    Exit;
  PosYRef := -1;
  PosXRef := -1;
  WidthRef := -1;
  HeightRef := -1;
  AutoStretchWidth := True;
  AutoStretchHeight := False;
  LabelWidth := -1;
  s := Properties.GUIProperties;
  while s <> '' do
  begin
    tag := copy(s, 1, 2);
    p := pos(':', s);
    if p = 0 then
    begin
      p := Length(s);
      value := copy(s, 3, p - 2);
    end else
      value := copy(s, 3, p - 3);
    delete(s, 1, p);
    if tag = 'ry' then PosYRef := StrToIntDef(value, -1)
    else if tag = 'rx' then PosXRef := StrToIntDef(value, -1)
    else if tag ='rw' then WidthRef := StrToIntDef(value, -1)
    else if tag = 'rh' then HeightRef := StrToIntDef(value, -1)
    else if tag = 'aw' then AutoStretchWidth := (value = '1')
    else if tag = 'ah' then AutoStretchHeight := ((value = '1') and (FType = ftText))
    else if tag = 'lw' then LabelWidth := StrToIntDef(value, -1);
  end;
  if PosXRef < -1 then PosXRef := -1;
  if PosYRef < -1 then PosYRef := -1;
  if WidthRef = -1 then WidthRef := CF_PanelWidth
  else if WidthRef < CF_PanelMinWidth then WidthRef := CF_PanelMinWidth;
  if (FType <> ftText) then HeightRef := CF_PanelHeight
  else if HeightRef = -1 then HeightRef := CF_PanelHeightText
  else if HeightRef < CF_PanelMinHeight then HeightRef := CF_PanelMinHeight;
  if LabelWidth = -1 then LabelWidth := CF_LabelWidth
  else if LabelWidth < CF_LabelMinWidth then LabelWidth := CF_LabelMinWidth;
  FSetLabelWidth(LabelWidth);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetEnabled(Value: Boolean);
begin
  FEnabled := Value;
  if(FLabel <> nil) then
    FLabel.Enabled := FEnabled;
  if(FLabelExt <> nil) then
    FLabelExt.Enabled := FEnabled;
  if(FControl <> nil) then
    FControl.Enabled := FEnabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetBorder(Value: Boolean);
begin
  FBorder := Value;
  if FBorder then
    BorderStyle := bsSingle
  else
    BorderStyle := bsNone;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetName(Value: String);
begin
  FName := Value;
  if FLabel <> nil then
  begin
    if(Settings.rOptions.rLanguage.Language = 'French') then
      FLabel.Caption := FName + ' :'
    else
      FLabel.Caption := FName + ':';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetExt(Value: String);
begin
  FExt := Value;
  if FLabelExt <> nil then
  begin
    if FExt <> '' then
    begin
      FLabelExt.AutoSize := True;
      FLabelExt.Caption := FExt;
      FLabelExt.AutoSize := False;
    end else
    begin
      FLabelExt.Caption := '';
      FLabelExt.Width := 0;
    end;
    FLabelExt.Visible := FLabelExt.Width > 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetType(Value: TFieldType);
//var
//  i: Integer;
begin
  if (Value <> FType) or (FControl = nil) or (FLabel = nil) then
  begin
    if FControl <> nil then
    begin
      FControl.Hide;
      FControl.Free;
    end;
    if FLabel = nil then
    begin
      FLabel := TLabel.Create(Self);
      FLabel.Parent := Self;
      if Properties <> nil then
        FLabel.Name := 'L'+Properties.FieldTag;
      FLabel.AutoSize := False;
      FLabel.Visible := True;
      FLabel.Caption := '';
      FLabel.Width := CF_LabelWidth;
      FLabel.Constraints.MinWidth := CF_LabelMinWidth;
      FLabel.Constraints.MaxWidth := CF_LabelMaxWidth;
      FLabel.Layout := tlCenter;
      FSetName(FName); // Generate label name (for ':' and ' :' according to language)
    end;
    if FLabelExt = nil then
    begin
      FLabelExt := TLabel.Create(Self);
      FLabelExt.Parent := Self;
      if Properties <> nil then
        FLabel.Name := 'U'+Properties.FieldTag;
      FLabelExt.AutoSize := False;
      FLabelExt.Visible := False;
      FLabelExt.Caption := '';
      FLabelExt.Width := 0;
      FLabelExt.Layout := tlCenter;
      FSetExt(FExt);
    end;
    Height := CF_PanelHeight;
    Constraints.MinHeight := Height;
    Constraints.MaxHeight := Height;
    case Value of
      ftInteger: //TAntJvSpinEdit
      begin
        FControl := TAntJvSpinEdit.Create(Self);
        FControl.Parent := Self;
        with TAntJvSpinEdit(FControl) do
        begin
          Ctl3D := True;
          ValueType := AntJvSpin.vtInteger;
          MinValue := 0;
          MaxValue := 999999999;
          Thousands := False;
          AllowEmpty := True;
          Text := '';
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
        end;
      end;
      ftReal, ftReal1, ftReal2: //TAntJvSpinEdit
      begin
        FControl := TAntJvSpinEdit.Create(Self);
        FControl.Parent := Self;
        with TAntJvSpinEdit(FControl) do
        begin
          Ctl3D := True;
          ValueType := AntJvSpin.vtFloat;
          MinValue := 0;
          MaxValue := 999999999;
          Thousands := False;
          AllowEmpty := True;
          Text := '';
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
        end;
        if Value = ftReal1 then
          TAntJvSpinEdit(FControl).Decimal := 1
        else if Value = ftReal2 then
          TAntJvSpinEdit(FControl).Decimal := 2
        else
          TAntJvSpinEdit(FControl).Decimal := 3;
      end;
      ftBoolean: //TCheckBox
      begin
        FControl := TCheckBox.Create(Self);
        FControl.Parent := Self;
        with TCheckBox(FControl) do
        begin
          Ctl3D := True;
          Checked := False;
          OnExit := FieldExit;
          OnClick := FieldChange;
          OnKeyDown := FieldKeyDown;
          Width := 15;
          //OnKeyUp := FieldKeyUp;
        end;
      end;
      ftDate: //TDateTimePicker
      begin
        FControl := TDateTimePicker.Create(Self);
        FControl.Parent := Self;
        with TDateTimePicker(FControl) do
        begin
          Ctl3D := True;
          ShowCheckbox := True;
          DateTime := SysUtils.Date;
          Checked := False;
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          //OnKeyUp := FieldKeyUp;
        end;
      end;
      ftList: //TComboBox
      begin
        FControl := TComboBox.Create(Self);
        FControl.Parent := Self;
        with TComboBox(FControl) do
        begin
          Ctl3D := True;
          Text := '';
          // Done in LoadLists
          //if (Properties <> nil) then
          //  for i:=0 to Properties.ListValues.Count-1 do
          //    Items.Add(Properties.ListValues.Strings[i]);
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
        end;
      end;
      ftText: //TMemo
      begin
        Height := CF_PanelHeight + 30;
        Constraints.MinHeight := CF_PanelMinHeight;
        Constraints.MaxHeight := CF_PanelMaxHeight;
        FControl := TMemo.Create(Self);
        FControl.Parent := Self;
        with TMemo(FControl) do
        begin
          Ctl3D := True;
          Text := '';
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
          ScrollBars := ssVertical;
        end;
      end;
      ftUrl: //TAntJvComboEditXP
      begin
        FControl := TAntJvComboEditXP.Create(Self);
        FControl.Parent := Self;
        with TAntJvComboEditXP(FControl) do
        begin
          ImageKind := ikDropDown;
          Ctl3D := True;
          Text := '';
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
          OnButtonClick := FieldURLButtonClick;
        end;
      end;
      else //TEdit
      begin
        FControl := TEdit.Create(Self);
        FControl.Parent := Self;
        with TEdit(FControl) do
        begin
          Ctl3D := True;
          Text := '';
          OnChange := FieldChange;
          OnExit := FieldExit;
          OnKeyDown := FieldKeyDown;
          OnKeyUp := FieldKeyUp;
        end;
      end;
    end;
    FType := Value;
    if Properties <> nil then
    begin
      FControl.Name := 'E'+Properties.FieldTag;
      if FControl is TCheckBox then
        TCheckBox(FControl).Caption := '';
    end;
    FControl.Visible := False;
    FSetEnabled(FEnabled);
    PanelResize(Self);
    FControl.Visible := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPanelCustomField.FGetValue: String;
begin
  Result := '';
  if FControl <> nil then
  begin
    try
      case FType of
      ftInteger, ftReal, ftReal1, ftReal2:
        Result := CharReplace(TAntJvSpinEdit(FControl).Text, DecimalSeparator, FormatSettings.DecimalSeparator);
      ftBoolean:
        if TCheckBox(FControl).Checked then
          Result := 'True'
        else
          Result := '';
      ftDate:
        with TDateTimePicker(FControl) do
          if Checked then
            Result := DateToStr(DateTime, FormatSettings);
      ftList:
        Result := TComboBox(FControl).Text;
      ftText:
        Result := TMemo(FControl).Text;
      ftUrl:
        Result := TAntJvComboEditXP(FControl).Text;
      else
        Result := TEdit(FControl).Text;
      end;
    except
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetValue(Value: String);
begin
  if FControl <> nil then
  begin
    try
      case FType of
      ftInteger, ftReal, ftReal1, ftReal2:
        TAntJvSpinEdit(FControl).Text := CharReplace(Value, FormatSettings.DecimalSeparator, DecimalSeparator);
      ftBoolean:
        TCheckBox(FControl).Checked := (Value = 'True');
      ftDate:
        with TDateTimePicker(FControl) do
        begin
          try
            if Value = '' then
            begin
              DateTime := SysUtils.Date;
              Checked := False;
            end else
            begin
              DateTime := StrToDate(Value, FormatSettings);
              Checked := True;
            end;
          except
            DateTime := SysUtils.Date;
            Checked := False;
          end;
        end;
      ftList:
        TComboBox(FControl).Text := Value;
      ftText:
        TMemo(FControl).Text := Value;
      ftUrl:
        TAntJvComboEditXP(FControl).Text := Value;
      else
        TEdit(FControl).Text := Value;
      end;
    except
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPanelCustomField.FGetLabelWidth: Integer;
begin
  Result := 0;
  if FLabel <> nil then
    Result := FLabel.Width;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FSetLabelWidth(Value: Integer);
begin
  if FLabel <> nil then
  begin
    FLabel.Width := Value;
    PanelResize(Self);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.PanelResize(Sender: TObject);
var
  n: Integer;
begin
  if (FLabel <> nil) and (FControl <> nil) and (FLabelExt <> nil) then
  begin
    if FBorder then n := CF_PanelBorderSize else n := 0;

    FLabel.Top := CF_PanelMarginTop - n;
    FLabel.Height := CF_PanelHeight - CF_PanelMarginTop - CF_PanelMarginBottom;
    FLabel.Left := CF_PanelMarginLeft - n;

    FControl.Top := CF_PanelMarginTop - n;
    FControl.Height :=  Height - CF_PanelMarginTop - CF_PanelMarginBottom;
    FControl.Left :=  FLabel.Width + CF_PanelMarginBetween - n;
    if FType <> ftBoolean then
      if FLabelExt.Visible then
        FControl.Width :=  Width - FLabel.Width - FLabelExt.Width - CF_PanelMarginBetween*2 - CF_PanelMarginRight
      else
        FControl.Width :=  Width - FLabel.Width - CF_PanelMarginBetween - CF_PanelMarginRight;
    if (FControl is TComboBox) then TComboBox(FControl).SelLength := 0;

    FLabelExt.Top := CF_PanelMarginTop - n;
    FLabelExt.Height := CF_PanelHeight - CF_PanelMarginTop - CF_PanelMarginBottom;
    FLabelExt.Left :=  FLabel.Width + FControl.Width + CF_PanelMarginBetween*2 - n;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FieldChange(Sender: TObject);
begin
  if Assigned(FOnFieldChange) then
      FOnFieldChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FieldExit(Sender: TObject);
begin
  if Assigned(FOnFieldValidate) then
    FOnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or ((Key = VK_RETURN) and (FType <> ftText) and (FType <> ftURL)) then
    if Assigned(FOnFieldValidate) then
      FOnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FieldKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = Ord('A')) and (Shift = [ssCtrl]) then
  begin
    if Sender is TAntJvSpinEdit then
      TAntJvSpinEdit(Sender).SelectAll
    else if Sender is TEdit then
      TEdit(Sender).SelectAll
    else if Sender is TMemo then
      TMemo(Sender).SelectAll
    else if Sender is TComboBox then
      TComboBox(Sender).SelectAll
    else if Sender is TAntJvComboEditXP then
      TAntJvComboEditXP(Sender).SelectAll;
  end
  else if (Key = VK_RETURN) and (Sender is TAntJvComboEditXP) and Assigned(OnURLEnter) then
    OnURLEnter(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPanelCustomField.FieldURLButtonClick(Sender: TObject);
begin
  if Assigned(OnURLButtonClick) then
    OnURLButtonClick(Sender);
end;

{-------------------------------------------------------------------------------
  TAutoLayoutBox
-------------------------------------------------------------------------------}

constructor TAutoLayoutBox.Create(Panels: TObjectList; Vertical: Boolean = False;
  LastNbLines: Integer = 0; LastNbColumns: Integer = 0);
begin
  inherited Create;
  FVertical := Vertical;
  FBoxes := nil;
  FPanel := nil;
  FBadPanels := nil;
  LeftRef := -1;
  TopRef := -1;
  RightRef := -1;
  BottomRef := -1;
  MinStretchWidth := 0;
  MaxStretchWidth := 0;
  MinStretchHeight := 0;
  MaxStretchHeight := 0;
  StretchWidth := 0;
  StretchHeight := 0;
  MoveX := 0;
  MoveY := 0;
  AddPanels(Panels, LastNbLines, LastNbColumns);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TAutoLayoutBox.Destroy;
begin
  inherited Destroy;
  FBoxes.Free;
  FBadPanels.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAutoLayoutBox.AddPanels(Panels: TObjectList; LastNbLines: Integer = 0; LastNbColumns: Integer = 0);
var
  i, j, minX, maxX, minY, maxY, extraSpace: Integer;
  CurrentPanel, APanel: TPanelCustomField;
  ListGroups: TStringList;
  ListPanels: TObjectList;
  Box: TAutoLayoutBox;
begin
  // No custom fields so we do nothing
  if (Panels.Count = 0) then
  begin
    Exit;
  end;

  // Only one panel in box and the two special parent boxes have been created
  if (Panels.Count = 1) and (LastNbLines <> 0) and (LastNbColumns <> 0) then
  begin
    FPanel := TPanelCustomField(Panels.Items[0]);
    FPanel.TabOrder := CF_TabOrderSeq;
    Inc(CF_TabOrderSeq);
    //FPanel.Hint := 'A:' + IntToStr(FPanel.TabOrder);

    // Compute box values
    LeftRef := FPanel.PosXRef;
    TopRef := FPanel.PosYRef;
    RightRef := FPanel.PosXRef + FPanel.WidthRef;
    BottomRef := FPanel.PosYRef + FPanel.HeightRef;
    if FPanel.AutoStretchWidth then
    begin
      MinStretchWidth := CF_PanelMinWidth - FPanel.WidthRef;
      if CF_PanelMaxWidth = 0 then //Infinite
        MaxStretchWidth := MaxInt
      else
        MaxStretchWidth := CF_PanelMaxWidth - FPanel.WidthRef;
      if MinStretchWidth > 0 then
        MinStretchWidth := 0;
      if MaxStretchWidth < 0 then
        MaxStretchWidth := 0;
    end;
    if FPanel.AutoStretchHeight then
    begin
      MinStretchHeight := CF_PanelMinHeight - FPanel.HeightRef;
      if CF_PanelMaxHeight = 0 then //Infinite
        MaxStretchHeight := MaxInt
      else
        MaxStretchHeight := CF_PanelMaxHeight - FPanel.HeightRef;
      if MinStretchHeight > 0 then
        MinStretchHeight := 0;
      if MaxStretchHeight < 0 then
        MaxStretchHeight := 0;
    end;
    Exit;
  end;

  // Panels in box can not be dissociated
  if (LastNbLines = 1) and (LastNbColumns = 1) then
  begin
    FBadPanels := TObjectList.Create(False);
    for i := 0 to Panels.Count-1 do
      FBadPanels.Add(Panels.Items[i]);

    // Compute box values
    LeftRef := MaxInt;
    TopRef := MaxInt;
    RightRef := -MaxInt;
    BottomRef := -MaxInt;
    for i := 0 to Panels.Count-1 do
    begin
      CurrentPanel := TPanelCustomField(Panels.Items[i]);
      CurrentPanel.TabOrder := CF_TabOrderSeq;
      Inc(CF_TabOrderSeq);
      //CurrentPanel.Hint := 'B:' + IntToStr(i)  + ':' + IntToStr(CurrentPanel.TabOrder);
      LeftRef := Min(LeftRef, CurrentPanel.PosXRef);
      TopRef := Min(TopRef, CurrentPanel.PosYRef);
      RightRef := Max(RightRef, CurrentPanel.PosXRef + CurrentPanel.WidthRef);
      BottomRef := Max(BottomRef, CurrentPanel.PosYRef + CurrentPanel.HeightRef);
    end;
    Exit;
  end;

  // If LastNbLines = 0 or LastNbColumns = 0 then we generate special boxes
  // (1 vertical and 1 horizontal) with all panels to auto remove extra space
  // on top/bottom and left/right
  if (LastNbLines = 0) or (LastNbColumns = 0) then
  begin
    // Add sub-box
    FBoxes := TObjectList.Create(True);
    if FVertical then
      FBoxes.Add(TAutoLayoutBox.Create(Panels, False, -1, LastNbColumns))
    else
      FBoxes.Add(TAutoLayoutBox.Create(Panels, True, LastNbLines, -1));

    // Compute box values (1)
    LeftRef := CF_FrameMarginLeft;
    TopRef := CF_FrameMarginTop;
    RightRef := CF_FrameWidthRef - CF_FrameMarginRight;
    BottomRef := CF_FrameHeightRef - CF_FrameMarginBottom;
    if (LastNbLines <> 0) or (LastNbColumns <> 0) then
    begin
      if FVertical then
      begin
        TopRef := MaxInt;
        BottomRef := -MaxInt;
      end else
      begin
        LeftRef := MaxInt;
        RightRef := -MaxInt;
      end;
    end;
  end
  else
  begin
    // Init indicative lines and columns
    for i := 0 to Panels.Count-1 do
    begin
      CurrentPanel := TPanelCustomField(Panels.Items[i]);
      CurrentPanel.CTag := -1; // Used temporarily to store column or line
    end;

    ListGroups := TStringList.Create;
    ListGroups.Sorted := True;

    // Try to dissociate panels in groups (lines or columns)
    if FVertical then
    begin
      // Generate indicative lines for each panel in box
      for i := 0 to Panels.Count-1 do
        if (TPanelCustomField(Panels.Items[i]).CTag = -1) then
        begin
          CurrentPanel := TPanelCustomField(Panels.Items[i]);
          CurrentPanel.CTag := i;
          minY := CurrentPanel.PosYRef;
          maxY := minY + CurrentPanel.HeightRef - 1;
          j := 0;
          while (j < Panels.Count) do
          begin
            if (Panels.Items[j] <> Panels.Items[i]) then
            begin
              APanel := TPanelCustomField(Panels.Items[j]);
              if (APanel.CTag = -1) and
                not ( (minY >= APanel.PosYRef + APanel.HeightRef - 1) or // Line after APanel
                      (APanel.PosYRef >= maxY) ) then // Line before APanel
              begin
                APanel.CTag := i;
                if APanel.PosYRef < minY then
                  minY := APanel.PosYRef;
                if APanel.PosYRef + APanel.HeightRef - 1 > maxY then
                  maxY := APanel.PosYRef + APanel.HeightRef - 1;
                j := -1;
              end;
            end;
            Inc(j);
          end;
          ListPanels := TObjectList.Create(False);
          for j := 0 to Panels.Count-1 do
            if (TPanelCustomField(Panels.Items[j]).CTag = i) then
              ListPanels.Add(Panels.Items[j]);
          ListGroups.AddObject(Format('%.*d', [10, minY]), ListPanels);
        end;
    end else
    begin
      // Generate indicative columns for each panel in box
      for i := 0 to Panels.Count-1 do
        if (TPanelCustomField(Panels.Items[i]).CTag = -1) then
        begin
          CurrentPanel := TPanelCustomField(Panels.Items[i]);
          CurrentPanel.CTag := i;
          minX := CurrentPanel.PosXRef;
          maxX := minX + CurrentPanel.WidthRef - 1;
          j := 0;
          while (j < Panels.Count) do
          begin
            if (Panels.Items[j] <> Panels.Items[i]) then
            begin
              APanel := TPanelCustomField(Panels.Items[j]);
              if (APanel.CTag = -1) and
                not ( (minX >= APanel.PosXRef + APanel.WidthRef - 1) or // Column after APanel
                (APanel.PosXRef >= maxX) ) then // Column before APanel
              begin
                APanel.CTag := i;
                if APanel.PosXRef < minX then
                  minX := APanel.PosXRef;
                if APanel.PosXRef + APanel.WidthRef - 1 > maxX then
                  maxX := APanel.PosXRef + APanel.WidthRef - 1;
                j := -1;
              end;
            end;
            Inc(j);
          end;
          ListPanels := TObjectList.Create(False);
          for j := 0 to Panels.Count-1 do
            if (TPanelCustomField(Panels.Items[j]).CTag = i) then
              ListPanels.Add(Panels.Items[j]);
          ListGroups.AddObject(Format('%.*d', [10, minX]), ListPanels);
        end;
    end;

    // Add sub-boxes according to groups found
    FBoxes := TObjectList.Create(True);
    for i := 0 to ListGroups.Count-1 do
    begin
      if FVertical then
        FBoxes.Add(TAutoLayoutBox.Create(TObjectList(ListGroups.Objects[i]), False, ListGroups.Count, LastNbColumns))
      else
        FBoxes.Add(TAutoLayoutBox.Create(TObjectList(ListGroups.Objects[i]), True, LastNbLines, ListGroups.Count));
    end;

    FreeObjects(ListGroups);
    ListGroups.Free;

    // Compute box values (1)
    LeftRef := MaxInt;
    TopRef := MaxInt;
    RightRef := -MaxInt;
    BottomRef := -MaxInt;
  end;

  // Compute box values (2)
  for i := 0 to FBoxes.Count-1 do
  begin
    Box := TAutoLayoutBox(FBoxes.Items[i]);
    LeftRef := Min(LeftRef, Box.LeftRef);
    TopRef := Min(TopRef, Box.TopRef);
    RightRef := Max(RightRef, Box.RightRef);
    BottomRef := Max(BottomRef, Box.BottomRef);
  end;

  MaxStretchWidth := 0;
  MaxStretchHeight := 0;
  
  if FVertical then
  begin
    MinStretchWidth := -MaxInt;
    MinStretchHeight := 0;
    for i := 0 to FBoxes.Count-1 do
    begin
      Box := TAutoLayoutBox(FBoxes.Items[i]);
      ExtraSpace := (RightRef - Box.RightRef) + (Box.LeftRef - LeftRef);
      MinStretchWidth := Max(MinStretchWidth, Box.MinStretchWidth - ExtraSpace);
      MaxStretchWidth := Max(MaxStretchWidth, Box.MaxStretchWidth);
      MinStretchHeight := MinStretchHeight + Box.MinStretchHeight;
      if (MaxStretchHeight < MaxInt) and (Box.MaxStretchHeight < MaxInt) then
        MaxStretchHeight := MaxStretchHeight + Box.MaxStretchHeight
      else
        MaxStretchHeight := MaxInt;
    end;
  end else
  begin
    MinStretchWidth := 0;
    MinStretchHeight := -MaxInt;
    for i := 0 to FBoxes.Count-1 do
    begin
      Box := TAutoLayoutBox(FBoxes.Items[i]);
      ExtraSpace := (BottomRef - Box.BottomRef) + (Box.TopRef - TopRef);
      MinStretchWidth := MinStretchWidth + Box.MinStretchWidth;
      if (MaxStretchWidth < MaxInt) and (Box.MaxStretchWidth < MaxInt) then
        MaxStretchWidth := MaxStretchWidth + Box.MaxStretchWidth
      else
        MaxStretchWidth := MaxInt;
      MinStretchHeight := Max(MinStretchHeight, Box.MinStretchHeight - ExtraSpace);
      MaxStretchHeight := Max(MaxStretchHeight, Box.MaxStretchHeight);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAutoLayoutBox.SetRelativeBounds(x, y, w, h: Integer);
var
  i, rest, sumInit, sum, sumTmp, stretch: Integer;
  neg: Boolean;
  Box: TAutoLayoutBox;
  Panel: TPanelCustomField;
begin
  if w < MinStretchWidth then
    w := MinStretchWidth;
  if w > MaxStretchWidth then
    w := MaxStretchWidth;
  if h < MinStretchHeight then
    h := MinStretchHeight;
  if h > MaxStretchHeight then
    h := MaxStretchHeight;

  if FPanel <> nil then
  begin
    FPanel.Width := FPanel.WidthRef + w;
    FPanel.Height := FPanel.HeightRef + h;
    FPanel.Left := FPanel.PosXRef + x;
    FPanel.Top := FPanel.PosYRef + y;
  end
  else if FBadPanels <> nil then
  begin
    for i := 0 to FBadPanels.Count-1 do
    begin
      Panel := TPanelCustomField(FBadPanels.Items[i]);
      Panel.Width := Panel.WidthRef + w;
      Panel.Height := Panel.HeightRef + h;
      Panel.Left := Panel.PosXRef + x;
      Panel.Top := Panel.PosYRef + y;
    end;
  end
  else if FBoxes <> nil then
  begin
    if FVertical then
    begin
      for i := 0 to FBoxes.Count-1 do
      begin
        Box := TAutoLayoutBox(FBoxes.Items[i]);
        Box.StretchWidth := w;
        Box.StretchHeight := 0;
        Box.MoveX := 0;
        Box.MoveY := 0;
      end;
      if h <> 0 then
      begin
        neg := h < 0;
        rest := h;
        sumInit := 0;
        for i := 0 to FBoxes.Count-1 do
        begin
          Box := TAutoLayoutBox(FBoxes.Items[i]);
          sumTmp := 0;
          if (neg) and (Box.MinStretchHeight < 0) then
            sumTmp := -Box.MinStretchHeight
          else if (not neg) and (Box.MaxStretchHeight > 0) then
            sumTmp := (Box.BottomRef - Box.TopRef);
          sumInit := sumInit + sumTmp;
        end;
        while h <> 0 do
        begin
          sum := sumInit;
          for i := 0 to FBoxes.Count-1 do
          begin
            Box := TAutoLayoutBox(FBoxes.Items[i]);
            if ((neg) and (Box.StretchHeight > Box.MinStretchHeight)) or
               ((not neg) and (Box.StretchHeight < Box.MaxStretchHeight)) then
            begin
              if neg then
                sumTmp := -Box.MinStretchHeight
              else
                sumTmp := (Box.BottomRef - Box.TopRef);
              if sum = sumTmp then
                stretch := h
              else
                stretch := Trunc(h / sum * sumTmp);
              sum := sum - sumTmp;
              h := h - stretch;
              if neg then
              begin
                if (Box.StretchHeight + stretch <= Box.MinStretchHeight) then
                begin
                  sumInit := sumInit - sumTmp;
                  stretch := Box.MinStretchHeight - Box.StretchHeight;
                end;
              end
              else
              begin
                if (Box.StretchHeight + stretch >= Box.MaxStretchHeight) then
                begin
                  sumInit := sumInit - sumTmp;
                  stretch := Box.MaxStretchHeight - Box.StretchHeight;
                end;
              end;
              Box.StretchHeight := Box.StretchHeight + stretch;
              rest := rest - stretch;
            end;
          end;
          h := rest;
        end;
      end;
      if w < 0 then
      begin
        for i := 0 to FBoxes.Count-1 do
        begin
          Box := TAutoLayoutBox(FBoxes.Items[i]);
          Box.StretchWidth := Box.StretchWidth + (RightRef - Box.RightRef);
          if Box.StretchWidth > 0 then
            Box.StretchWidth := 0;
          if Box.StretchWidth < 0 then
          begin
            if (LeftRef - Box.LeftRef) <= Box.StretchWidth then
              Box.MoveX := Box.StretchWidth
            else
              Box.MoveX := (LeftRef - Box.LeftRef);
            Box.StretchWidth := Box.StretchWidth - Box.MoveX;
          end;
        end;
      end;
      for i := 0 to FBoxes.Count-1 do
      begin
        Box := TAutoLayoutBox(FBoxes.Items[i]);
        Box.SetRelativeBounds(x + Box.MoveX, y + Box.MoveY, Box.StretchWidth, Box.StretchHeight);
        y := y + Box.StretchHeight;
      end;
    end else
    begin
      for i := 0 to FBoxes.Count-1 do
      begin
        Box := TAutoLayoutBox(FBoxes.Items[i]);
        Box.StretchWidth := 0;
        Box.StretchHeight := h;
        Box.MoveX := 0;
        Box.MoveY := 0;
      end;
      if w <> 0 then
      begin
        neg := w < 0;
        rest := w;
        sumInit := 0;
        for i := 0 to FBoxes.Count-1 do
        begin
          Box := TAutoLayoutBox(FBoxes.Items[i]);
          sumTmp := 0;
          if (neg) and (Box.MinStretchWidth < 0) then
            sumTmp := -Box.MinStretchWidth
          else if (not neg) and (Box.MaxStretchWidth > 0) then
            sumTmp := (Box.RightRef - Box.LeftRef);
          sumInit := sumInit + sumTmp;
        end;
        while w <> 0 do
        begin
          sum := sumInit;
          for i := 0 to FBoxes.Count-1 do
          begin
            Box := TAutoLayoutBox(FBoxes.Items[i]);
            if ((neg) and (Box.StretchWidth > Box.MinStretchWidth)) or
               ((not neg) and (Box.StretchWidth < Box.MaxStretchWidth)) then
            begin
              if neg then
                sumTmp := -Box.MinStretchWidth
              else
                sumTmp := (Box.RightRef - Box.LeftRef);
              if sum = sumTmp then
                stretch := w
              else
                stretch := Trunc(w / sum * sumTmp);
              sum := sum - sumTmp;
              w := w - stretch;
              if neg then
              begin
                if (Box.StretchWidth + stretch <= Box.MinStretchWidth) then
                begin
                  sumInit := sumInit - sumTmp;
                  stretch := Box.MinStretchWidth - Box.StretchWidth;
                end;
              end
              else
              begin
                if (Box.StretchWidth + stretch >= Box.MaxStretchWidth) then
                begin
                  sumInit := sumInit - sumTmp;
                  stretch := Box.MaxStretchWidth - Box.StretchWidth;
                end;
              end;
              Box.StretchWidth := Box.StretchWidth + stretch;
              rest := rest - stretch;
            end;
          end;
          w := rest;
        end;
      end;
      if h < 0 then
      begin
        for i := 0 to FBoxes.Count-1 do
        begin
          Box := TAutoLayoutBox(FBoxes.Items[i]);
          Box.StretchHeight := Box.StretchHeight + (BottomRef - Box.BottomRef);
          if Box.StretchHeight > 0 then
            Box.StretchHeight := 0;
          if Box.StretchHeight < 0 then
          begin
            if (TopRef - Box.TopRef) <= Box.StretchHeight then
              Box.MoveY := Box.StretchHeight
            else
              Box.MoveY := (TopRef - Box.TopRef);
            Box.StretchHeight := Box.StretchHeight - Box.MoveY;
          end;
        end;
      end;
      for i := 0 to FBoxes.Count-1 do
      begin
        Box := TAutoLayoutBox(FBoxes.Items[i]);
        Box.SetRelativeBounds(x + Box.MoveX, y + Box.MoveY, Box.StretchWidth, Box.StretchHeight);
        x := x + Box.StretchWidth;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
  TMovieFrameCustom
-------------------------------------------------------------------------------}

constructor TMovieFrameCustom.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FModified := False;
  FPropertiesModified := False;
  FUpdateCount := 0;
  FGeneratedFields := False;
  FAllowEdit := True;
  FSelectedPanel := nil;
  FMovingPanel := nil;
  FResizing := 0;
  FSubVertScrollBar := False;
  FSubHorizScrollBar := False;
  FAutoLayoutBox := nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieFrameCustom.Destroy;
begin
  inherited Destroy;
  FAutoLayoutBox.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.Init;
begin
  PopupCustomField.Images := ToolbarImages;
  ActionAddCustomField.ImageIndex := Ord(ICON_FIELDADD);
  ActionDeleteCustomField.ImageIndex := Ord(ICON_FIELDDEL);
  ActionModifyCustomField.ImageIndex := Ord(ICON_FIELDEDIT);
  ActionMoveResizeCustomFields.ImageIndex := Ord(ICON_FIELDMOVE);
  ActionDefaultPositioning.ImageIndex := Ord(ICON_FIELD);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameCustom.AddField(FieldProperties: TCustomFieldProperties; Visible: Boolean): TPanelCustomField;
var
  PanelCF : TPanelCustomField;
begin
  Result := nil;

  if(FieldProperties = nil) then
    Exit;

  PanelCF := TPanelCustomField.Create(Self);
  PanelCF.Visible := Visible;
  PanelCF.Parent := Self;
  PanelCF.Init(FieldProperties);

  PanelCF.FSetEnabled((not ActionMoveResizeCustomFields.Checked) and FAllowEdit);
  PanelCF.FSetBorder(ActionMoveResizeCustomFields.Checked);

  PanelCF.OnMouseDown := ControlMouseDown;
  PanelCF.OnMouseMove := ControlMouseMove;
  PanelCF.OnMouseUp := ControlMouseUp;
  PanelCF.OnFieldChange := FieldChange;
  PanelCF.OnFieldValidate := FieldValidate;
  PanelCF.OnURLButtonClick := FieldURLButtonClick;
  PanelCF.OnURLEnter := FieldURLEnter;
  PanelCF.FLabel.OnMouseUp := ControlMouseUp;
  PanelCF.FLabelExt.OnMouseUp := ControlMouseUp;

  Result := PanelCF;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ClearFields;
var
  i: Integer;
begin
  FGeneratedFields := False;
  for i := ControlCount-1 downto 0 do
    if Controls[i] is TPanelCustomField then
      Controls[i].Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.GenerateFields;
var
  i: Integer;
begin
  ClearFields;
  if Properties = nil then
    Exit;
  for i := 0 to Properties.Count-1 do
    Properties.Objects[i].FieldObject := nil;
  for i := 0 to Properties.Count-1 do
    if Properties.Objects[i].FieldType <> ftVirtual then
      AddField(Properties.Objects[i], False);
  LoadFieldsProperties;
  FGeneratedFields := True;
  FrameResize(Self);
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
      TPanelCustomField(Controls[i]).Visible := True;
  FSelectedPanel := nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SaveFieldsProperties;
var
  i: Integer;
begin
  if(Properties = nil) then
    Exit;
  Properties.GUIProperties := 'fw' + IntToStr(CF_FrameWidthRef) + ':fh' + IntToStr(CF_FrameHeightRef);
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      TPanelCustomField(Controls[i]).SaveGUIProperties;
    end;
  FPropertiesModified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.LoadFieldsProperties;
var
  s, tag, value: string;
  p, i: Integer;
begin
  if(Properties = nil) then
    Exit;
  CF_FrameWidthRef := -1;
  CF_FrameHeightRef := -1;
  s := Properties.GUIProperties;
  while s <> '' do
  begin
    tag := copy(s, 1, 2);
    p := pos(':', s);
    if p = 0 then
    begin
      p := Length(s);
      value := copy(s, 3, p - 2);
    end else
      value := copy(s, 3, p - 3);
    delete(s, 1, p);
    if tag ='fw' then CF_FrameWidthRef := StrToIntDef(value, -1)
    else if tag = 'fh' then CF_FrameHeightRef := StrToIntDef(value, -1);
  end;
  if CF_FrameWidthRef < 0 then CF_FrameWidthRef := 533;
  if CF_FrameHeightRef < 0 then CF_FrameHeightRef := 449;
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
      TPanelCustomField(Controls[i]).LoadGUIProperties;
  CheckFieldsPosition;
  GenerateAutoLayoutBox;
  FPropertiesModified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.CheckFieldsPosition;  
var
  i: Integer;
  MaxPosYRef: Integer;
  CurrentPanel: TPanelCustomField;
begin
  if(Properties = nil) then
    Exit;
  MaxPosYRef := CF_FrameMarginTop;
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      CurrentPanel := TPanelCustomField(Controls[i]);
      if (CurrentPanel.PosYRef >= 0) and (CurrentPanel.PosYRef + CurrentPanel.HeightRef - 1 > MaxPosYRef) then
        MaxPosYRef := CurrentPanel.PosYRef + CurrentPanel.HeightRef - 1;
    end;

  for i := 0 to Properties.Count-1 do
    if (Properties.Objects[i].FieldObject <> nil) then
    begin
      CurrentPanel := TPanelCustomField(Properties.Objects[i].FieldObject);
      if CurrentPanel.PosXRef < 0 then
      begin
        CurrentPanel.PosXRef := CF_FrameMarginLeft;
        if CurrentPanel.AutoStretchWidth then
           CurrentPanel.WidthRef := CF_FrameWidthRef - CF_FrameMarginRight - CurrentPanel.PosXRef;
      end;
      if CurrentPanel.PosYRef < 0 then
      begin
        CurrentPanel.PosYRef := MaxPosYRef;
        MaxPosYRef := CurrentPanel.PosYRef + CurrentPanel.HeightRef - 1;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.UpdateFieldsProperties;
var
  i: Integer;
  CurrentPanel: TPanelCustomField;
  X, Y: Integer;
begin
  CF_FrameWidthRef := Width;
  CF_FrameHeightRef := Height;
  if FSubVertScrollBar then
    CF_FrameWidthRef := Width - GetSystemMetrics(SM_CXVSCROLL);
  if FSubHorizScrollBar then
    CF_FrameHeightRef := Height - GetSystemMetrics(SM_CYHSCROLL);
  X := GetScrollPos(Self.Handle, SB_HORZ);
  Y := GetScrollPos(Self.Handle, SB_VERT);
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      CurrentPanel := TPanelCustomField(Controls[i]);
      CurrentPanel.PosXRef := CurrentPanel.Left + X;
      CurrentPanel.PosYRef := CurrentPanel.Top + Y;
      CurrentPanel.WidthRef := CurrentPanel.Width;
      CurrentPanel.HeightRef := CurrentPanel.Height;
    end;
  GenerateAutoLayoutBox;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.GenerateAutoLayoutBox;
var
  Panels: TObjectList;
  i: Integer;
begin
  FAutoLayoutBox.Free;
  CF_TabOrderSeq := 1;
  Panels := TObjectList.Create(False);
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
      Panels.Add(Controls[i]);
  FAutoLayoutBox := TAutoLayoutBox.Create(Panels);
  Panels.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetFieldsBorder(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount-1 do
  begin
    if (Self.Controls[i] is TPanelCustomField) then
      with TPanelCustomField(Self.Controls[i]) do
      begin
        FSetBorder(ActionMoveResizeCustomFields.Checked);
        if (not ActionMoveResizeCustomFields.Checked) then
          Cursor := crDefault;
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetFieldsEnabled(Value: Boolean);
var
  i: Integer;
begin
  for i := 0 to Self.ControlCount-1 do
  begin
    if (Self.Controls[i] is TPanelCustomField) then
    begin
      TPanelCustomField(Self.Controls[i]).FSetEnabled(Value);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FrameResize(Sender: TObject);
var
  X, Y, W, H, StretchWidth, StretchHeight: Integer;
  BoxV, BoxH: TAutoLayoutBox;
  VertScrollBarVisible, HorizScrollBarVisible: Boolean;

  procedure CheckVertScrollBarVisible;
  begin
    StretchHeight := H - CF_FrameHeightRef;
    if StretchHeight > FAutoLayoutBox.MaxStretchHeight then
      StretchHeight := FAutoLayoutBox.MaxStretchHeight
    else if StretchHeight < FAutoLayoutBox.MinStretchHeight +
      FAutoLayoutBox.BottomRef - BoxV.BottomRef then
      StretchHeight := FAutoLayoutBox.MinStretchHeight +
        FAutoLayoutBox.BottomRef - BoxV.BottomRef;
    VertScrollBarVisible := H < (BoxV.BottomRef + StretchHeight);
  end;

  procedure CheckHorizScrollBarVisible;
  begin
    StretchWidth := W - CF_FrameWidthRef;
    if StretchWidth > FAutoLayoutBox.MaxStretchWidth then
      StretchWidth := FAutoLayoutBox.MaxStretchWidth
    else if StretchWidth < FAutoLayoutBox.MinStretchWidth +
      FAutoLayoutBox.RightRef - BoxH.RightRef then
      StretchWidth := FAutoLayoutBox.MinStretchWidth +
        FAutoLayoutBox.RightRef - BoxH.RightRef;
    HorizScrollBarVisible := W < (BoxH.RightRef + StretchWidth);
  end;

begin
  if(FMovingPanel = nil) and (FGeneratedFields) then
  begin
    try
      X := HorzScrollBar.Position;
      Y := VertScrollBar.Position;
      W := Width;
      H := Height;
      FSubVertScrollBar := False;
      FSubHorizScrollBar := False;
      if (FAutoLayoutBox.FBoxes <> nil) and (FAutoLayoutBox.FBoxes.Count > 0) then
      begin
        BoxV := TAutoLayoutBox(FAutoLayoutBox.FBoxes.Items[0]);
        BoxH := TAutoLayoutBox(BoxV.FBoxes.Items[0]);

        { First check to know if HSB and VSB are visibles }
        CheckVertScrollBarVisible;
        CheckHorizScrollBarVisible;
        FSubVertScrollBar := VertScrollBarVisible and not HorizScrollBarVisible;
        FSubHorizScrollBar := HorizScrollBarVisible and not VertScrollBarVisible;
        { We subtract VSB to frame width if possible to avoid HSB }
        if FSubVertScrollBar then
          W := Width - GetSystemMetrics(SM_CXVSCROLL)
        else
          W := Width;
        { We subtract HSB to frame height if possible to avoid VSB }
        if FSubHorizScrollBar then
          H := Height - GetSystemMetrics(SM_CYHSCROLL)
        else
          H := Height;

        { Second check to know if HSB and VSB are visibles if we subtract HSB or VSB }
        if FSubVertScrollBar or FSubHorizScrollBar then
        begin
          CheckVertScrollBarVisible;
          CheckHorizScrollBarVisible;
          FSubVertScrollBar := VertScrollBarVisible and not HorizScrollBarVisible;
          FSubHorizScrollBar := HorizScrollBarVisible and not VertScrollBarVisible;
          { We subtract VSB to frame width if possible to avoid HSB }
          if FSubVertScrollBar then
            W := Width - GetSystemMetrics(SM_CXVSCROLL)
          else
            W := Width;
          { We subtract HSB to frame height if possible to avoid VSB }
          if FSubHorizScrollBar then
            H := Height - GetSystemMetrics(SM_CYHSCROLL)
          else
            H := Height;
        end;

        // DEBUG
        { if GetKeyState(VK_CONTROL) < 0 then
          ShowMessage(
            'MinStretchWidth=' + IntToStr(FAutoLayoutBox.MinStretchWidth) + #13#10 +
            'MinStretchHeight=' + IntToStr(FAutoLayoutBox.MinStretchHeight) + #13#10 +
            'StretchWidth=' + IntToStr(StretchWidth) + #13#10 +
            'StretchHeight=' + IntToStr(StretchHeight) + #13#10 +
            'LeftRef=' + IntToStr(FAutoLayoutBox.LeftRef) + #13#10+
            'LeftRef2=' + IntToStr(BoxV.LeftRef) + #13#10+
            'LeftRef3=' + IntToStr(BoxH.LeftRef) + #13#10 +
            'RightRef=' + IntToStr(FAutoLayoutBox.RightRef) + #13#10+
            'RightRef2=' + IntToStr(BoxV.RightRef) + #13#10+
            'RightRef3=' + IntToStr(BoxH.RightRef) + #13#10 +
            'TopRef=' + IntToStr(FAutoLayoutBox.TopRef) + #13#10 +
            'TopRef2=' + IntToStr(BoxV.TopRef) + #13#10 +
            'TopRef3=' + IntToStr(BoxH.TopRef) + #13#10 +
            'BottomRef=' + IntToStr(FAutoLayoutBox.BottomRef) + #13#10 +
            'BottomRef2=' + IntToStr(BoxV.BottomRef) + #13#10 +
            'BottomRef3=' + IntToStr(BoxH.BottomRef) + #13#10 +
            'CF_FrameWidthRef=' + IntToStr(CF_FrameWidthRef) + #13#10 +
            'CF_FrameHeightRef=' + IntToStr(CF_FrameHeightRef) + #13#10 +
            'Width=' + IntToStr(Width) + #13#10 +
            'Height=' + IntToStr(Height) + #13#10 +
            'VertScrollBarVisible=' + BoolToStr(VertScrollBarVisible, True) + #13#10 +
            'HorizScrollBarVisible=' + BoolToStr(HorizScrollBarVisible, True) + #13#10 +
            'FSubVertScrollBar=' + BoolToStr(FSubVertScrollBar, True) + #13#10 +
            'FSubHorizScrollBar=' + BoolToStr(FSubHorizScrollBar, True) + #13#10 +
            'W=' + IntToStr(W) + #13#10 +
            'H=' + IntToStr(H) + #13#10
          ); }
      end;
      FAutoLayoutBox.SetRelativeBounds(-X, -Y, W - CF_FrameWidthRef, H - CF_FrameHeightRef);
    except
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionAddCustomFieldExecute(Sender: TObject);
begin
  if Assigned(FOnFieldAdd) then
    FOnFieldAdd(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionModifyCustomFieldExecute(Sender: TObject);
begin
  if Assigned(FOnFieldModify) then
    FOnFieldModify(FSelectedPanel);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionDeleteCustomFieldExecute(Sender: TObject);
begin
  if Assigned(FOnFieldDelete) then
    FOnFieldDelete(FSelectedPanel);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionMoveResizeCustomFieldsExecute(Sender: TObject);
begin
  ActionMoveResizeCustomFields.Checked := not ActionMoveResizeCustomFields.Checked;
  SetFieldsBorder(ActionMoveResizeCustomFields.Checked);
  SetFieldsEnabled((not ActionMoveResizeCustomFields.Checked) and FAllowEdit);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionDefaultPositioningExecute(Sender: TObject);
var
  i: Integer;
begin
  VertScrollBar.Position := 0;
  HorzScrollBar.Position := 0;
  CF_FrameWidthRef := Width;
  CF_FrameHeightRef := Height;
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
      with TPanelCustomField(Controls[i]) do
      begin
        PosYRef := -1;
        PosXRef := -1;
        WidthRef := CF_PanelWidth;
        if (FType <> ftText) then HeightRef := CF_PanelHeight
        else HeightRef := CF_PanelHeightText;
        AutoStretchWidth := True;
        AutoStretchHeight := False;
        FSetLabelWidth(CF_LabelWidth);
      end;
  CheckFieldsPosition;
  GenerateAutoLayoutBox;
  FrameResize(Self);
  FieldPropertiesChange(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionAutoStretchWidthExecute(Sender: TObject);
begin
  FSelectedPanel.AutoStretchWidth := not FSelectedPanel.AutoStretchWidth;
  UpdateFieldsProperties;
  FieldPropertiesChange(FSelectedPanel);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ActionAutoStretchHeightExecute(Sender: TObject);
begin
  FSelectedPanel.AutoStretchHeight := not FSelectedPanel.AutoStretchHeight;
  UpdateFieldsProperties;
  FieldPropertiesChange(FSelectedPanel);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ControlMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  rec: TRect;
  pt: TPoint;
begin
  if (ActionMoveResizeCustomFields.Checked) and (Button = mbLeft) then
  begin
    if (Sender is TPanelCustomField) then
    begin
      FMovingPanel := TPanelCustomField(Sender);
      pt := ScreenToClient(Mouse.CursorPos);
      rec := FMovingPanel.BoundsRect;
      if (pt.X > rec.Right - 8) then
      begin //resize panel right
        FResizing := 1;
      end
      else if ((pt.X > rec.Left + FMovingPanel.FGetLabelWidth + CF_PanelMarginBetween - 3) and
        (pt.X < rec.Left + FMovingPanel.FGetLabelWidth + CF_PanelMarginBetween + 3)) then
      begin //resize label
        FResizing := 2;
      end
      else if (pt.X < rec.Left + 7) then
      begin //resize label left
        FResizing := 3;
      end
      else
      begin //move label
        FResizing := 0;
      end;
      SetCapture(FMovingPanel.Handle);
      GetCursorPos(FOldPos);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ControlMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  newPos: TPoint;
  frmPoint : TPoint;
  rec : TRect;
  i: Integer;
begin
  if FMovingPanel <> nil then
  begin
    with FMovingPanel do
    begin
      GetCursorPos(newPos);

      if FResizing = 1 then
      begin //resize panel right
        if FMovingPanel.FType <> ftText then
        begin
          if Width - FOldPos.X + newPos.X > CF_PanelMinWidth then
          begin
            Width := Width - FOldPos.X + newPos.X;
            FOldPos := newPos;
          end
        end
        else
        begin
          if (Width - FOldPos.X + newPos.X > CF_PanelMinWidth) then
          begin
            Width := Width - FOldPos.X + newPos.X;
            FOldPos.X := newPos.X;
          end;
          if (Height - FOldPos.Y + newPos.Y > CF_PanelMinHeight) then
          begin
            Height := Height - FOldPos.Y + newPos.Y;
            FOldPos.Y := newPos.Y;
          end;
        end
      end
      else if FResizing = 2 then
      begin //resize label
        if FGetLabelWidth - FOldPos.X + newPos.X > CF_LabelMinWidth then
        begin
          FSetLabelWidth(FGetLabelWidth - FOldPos.X + newPos.X);
          FOldPos := newPos;
        end;
      end
      else if FResizing = 3 then
      begin //resize panel left
        if Width + FOldPos.X - newPos.X > CF_PanelMinWidth then
        begin
          if newPos.X < FOldPos.X then
          begin
            Left := Left - FOldPos.X + newPos.X;
            Width := Width + FOldPos.X - newPos.X;
          end else
          begin
            Width := Width + FOldPos.X - newPos.X;
            Left := Left - FOldPos.X + newPos.X;
          end;
          FOldPos := newPos;
        end;
      end
      else
      begin //move panel
        if ssCtrl in Shift then
        begin
          //move all panels bellow this panel too
          for i := 0 to Self.ControlCount-1 do
            if (Self.Controls[i] is TPanelCustomField) and
              (Self.Controls[i] <> FMovingPanel) then
              with TPanelCustomField(Self.Controls[i]) do
                if Top >= FMovingPanel.Top then
                begin
                  Left := Left - FOldPos.X + newPos.X;
                  Top := Top - FOldPos.Y + newPos.Y;
                end;
        end;
        Left := Left - FOldPos.X + newPos.X;
        Top := Top - FOldPos.Y + newPos.Y;
        FOldPos := newPos;
      end;
    end;
  end
  else if (ActionMoveResizeCustomFields.Checked) then
  begin
    frmPoint := ScreenToClient(Mouse.CursorPos);
    if (Sender is TPanelCustomField) then
    begin
      FMovingPanel := TPanelCustomField(Sender);
      FMovingPanel.BringToFront;
      rec := FMovingPanel.BoundsRect;
      if (frmPoint.X > rec.Right - 8) then
        if FMovingPanel.FType <> ftText then
          FMovingPanel.Cursor := crSizeWE //resize panel cursor right
        else
          FMovingPanel.Cursor := crSizeNWSE //resize panel cursor right/bottom
      else if ((frmPoint.X > rec.Left + FMovingPanel.FGetLabelWidth + CF_PanelMarginBetween - 3) and
        (frmPoint.X < rec.Left + FMovingPanel.FGetLabelWidth + CF_PanelMarginBetween + 3)) then
        FMovingPanel.Cursor := crSizeWE //resize label cursor
      else if (frmPoint.X < rec.Left + 7) then
          FMovingPanel.Cursor := crSizeWE //resize panel cursor left
      else
        FMovingPanel.Cursor := crSize; //move panel cursor
      FMovingPanel := nil;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.ControlMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
  SX, SY: Integer;
begin
  if (FMovingPanel <> nil) and (Button = mbLeft) then
  begin
    with FMovingPanel do
    begin
      SX := GetScrollPos(Self.Handle, SB_HORZ);
      SY := GetScrollPos(Self.Handle, SB_VERT);
      if Left < -SX then
        Left := -SX;
      if Top < -SY then
        Top := -SY;
    end;
    ReleaseCapture;
    UpdateFieldsProperties;
    FieldPropertiesChange(FMovingPanel);
    FMovingPanel := nil;
    FrameResize(Self);
    FrameResize(Self);
  end
  else if (ActionMoveResizeCustomFields.Checked) and (Button = mbRight) and (FMovingPanel = nil) then
  begin
    if (Sender is TPanelCustomField) then
    begin
      FSelectedPanel := TPanelCustomField(Sender);
      ActionAutoStretchWidth.Enabled := True;
      ActionAutoStretchWidth.Visible := ActionAutoStretchWidth.Enabled;
      ActionAutoStretchHeight.Enabled := FSelectedPanel.FType = ftText;
      ActionAutoStretchHeight.Visible := ActionAutoStretchHeight.Enabled;
      ActionAutoStretchWidth.Checked := FSelectedPanel.AutoStretchWidth;
      ActionAutoStretchHeight.Checked := FSelectedPanel.AutoStretchHeight;
      ActionDeleteCustomField.Enabled := True;
      ActionDeleteCustomField.Visible := ActionDeleteCustomField.Enabled;
      ActionModifyCustomField.Enabled := True;
      ActionModifyCustomField.Visible := ActionDeleteCustomField.Enabled;
      TBSep2.Visible := True;
      GetCursorPos(pt);
      PopupCustomField.Popup(pt.X, pt.Y);
    end;
  end
  else if (not ActionMoveResizeCustomFields.Checked) and (FMovingPanel = nil) then
    FrameMouseUp(Sender, Button, Shift, X, Y);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FrameMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
  i: Integer;
begin
  if(Button = mbRight) then
  begin
    FSelectedPanel := nil;
    if (Sender is TLabel) and (TLabel(Sender).Parent is TPanelCustomField) then
      FSelectedPanel :=  TPanelCustomField(TLabel(Sender).Parent)
    else
    begin
      GetCursorPos(pt);
      pt := ScreenToClient(pt);
      for i := 0 to ControlCount-1 do
      begin
        if (Controls[i] is TPanelCustomField) and
          (pt.X > Controls[i].Left) and (pt.X < Controls[i].Left + Controls[i].Width) and
          (pt.Y > Controls[i].Top) and (pt.Y < Controls[i].Top + Controls[i].Height) then
        begin
          FSelectedPanel :=  TPanelCustomField(Controls[i]);
          break;
        end;
      end;
    end;
    ActionDeleteCustomField.Enabled := FSelectedPanel <> nil;
    ActionDeleteCustomField.Visible := ActionDeleteCustomField.Enabled;
    ActionModifyCustomField.Enabled := FSelectedPanel <> nil;
    ActionModifyCustomField.Visible := ActionModifyCustomField.Enabled;
    ActionAutoStretchWidth.Enabled := False;
    ActionAutoStretchWidth.Visible := ActionAutoStretchWidth.Enabled;
    ActionAutoStretchHeight.Enabled := False;
    ActionAutoStretchHeight.Visible := ActionAutoStretchHeight.Enabled;
    TBSep2.Visible := False;
    GetCursorPos(pt);
    PopupCustomField.Popup(pt.X, pt.Y);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount < 0 then
    FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameCustom.IsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.Translate;
var
  i: Integer;
begin
  Translator.Translate(Self);
  for i := 0 to Self.ControlCount-1 do
    if (Self.Controls[i] is TPanelCustomField) then
      with TPanelCustomField(Self.Controls[i]) do
        FSetName(FName); // Regenerate label name (for ':' and ' :' according to language)
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetDefaultValues;
var
  i: Integer;
begin
  if Properties = nil then
    Exit;
  BeginUpdate;
  try
    for i:= 0 to Properties.Count-1 do
    begin
      if Properties.Objects[i].FieldObject <> nil then
        with TPanelCustomField(Properties.Objects[i].FieldObject) do
        begin
          if (Self.Properties.Objects[i].FieldType = ftDate) and
            (SameText(Self.Properties.Objects[i].DefaultValue, 'Today')) then
            FSetValue(DateToStr(Date, FormatSettings))
          else
            FSetValue(Self.Properties.Objects[i].DefaultValue);
        end;
      //else
      //  showmessage('DEGUG: Regenerate fields after changes forgotten ! (1)');
    end;
  finally
    EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.LoadFromObject(AMovie: TMovie);
var
  i: Integer;
begin
  if Properties = nil then
    Exit;
  BeginUpdate;
  try
    for i:= 0 to Properties.Count-1 do
    begin
      if Properties.Objects[i].FieldObject <> nil then
        with TPanelCustomField(Properties.Objects[i].FieldObject) do
        begin
          FSetValue(AMovie.CustomFields.GetFieldValue(Self.Properties.Strings[i]));
        end;
      //else
      //  showmessage('DEBUG: Regenerate fields after changes forgotten ! (2)');
    end;
  finally
    EndUpdate;
  end;
  Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SaveToObject(AMovie: TMovie; const ForceSave: Boolean = False);
var
  i: Integer;
begin
  if Properties = nil then
    Exit;
  if Modified or ForceSave then
    for i:= 0 to Properties.Count-1 do
    begin
      if Properties.Objects[i].FieldObject <> nil then
        with TPanelCustomField(Properties.Objects[i].FieldObject) do
          AMovie.CustomFields.SetFieldValue(Self.Properties.Strings[i], FGetValue);
      //else
      //  showmessage('DEBUG: Regenerate fields after changes forgotten ! (3)');
    end;
  if not ForceSave then
    Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.LoadLists;
var
  i: Integer;
  PanelCF: TPanelCustomField;

  procedure LoadList(const ACombo: TComboBox; FieldProperties: TCustomFieldProperties);
  begin
    with FieldProperties do
    begin
      if ListUseCatalogValues then
      begin
        if (Properties <> nil) and (Properties.MovieList <> nil) then
            Properties.MovieList.GetCustomValues(ACombo.Items, FieldProperties.FieldTag)
          else
            ACombo.Items.Clear;
      end else
        ACombo.Items.Assign(FieldProperties.ListValues);
      ACombo.Sorted := ListSort;
      ACombo.AutoComplete := ListAutoComplete;
    end;
  end;
begin
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      PanelCF := TPanelCustomField(Controls[i]);
      if (PanelCF.FType = ftList) and (PanelCF.FControl <> nil) and (PanelCF.Properties <> nil) then
        LoadList(TComboBox(PanelCF.FControl), PanelCF.Properties);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SaveLists;
var
  i: Integer;
  PanelCF: TPanelCustomField;

  procedure SaveList(const ACombo: TComboBox; FieldProperties: TCustomFieldProperties);
  begin
    with FieldProperties do
      if (not ListUseCatalogValues) and (ListAutoAdd) and (ACombo.Items.Count > 0) then
        FieldProperties.ListValues.Assign(ACombo.Items);
  end;
begin
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      PanelCF := TPanelCustomField(Controls[i]);
      if (PanelCF.FType = ftList) and (PanelCF.FControl <> nil) and (PanelCF.Properties <> nil) then
        SaveList(TComboBox(PanelCF.FControl), PanelCF.Properties);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.UpdateLists;
var
  i: Integer;
  PanelCF: TPanelCustomField;

  procedure UpdateList(const Combo: TComboBox; FieldProperties: TCustomFieldProperties);
  begin
    with FieldProperties do
      if (ListAutoAdd or ListUseCatalogValues) and (Combo.Text <> '') and
        (Combo.Items.IndexOf(Combo.Text) = -1) then
        Combo.Items.Add(Combo.Text);
  end;
begin
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
    begin
      PanelCF := TPanelCustomField(Controls[i]);
      if (PanelCF.FType = ftList) and (PanelCF.FControl <> nil) and (PanelCF.Properties <> nil) then
        UpdateList(TComboBox(PanelCF.FControl), PanelCF.Properties);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameCustom.GetCurrentValue(FieldProperties: TCustomFieldProperties;
  LocalFormatSettings: Boolean = False; ReturnEmptyIfFalse: Boolean = True): string;
begin
  if (FieldProperties <> nil) and (FieldProperties.FieldObject <> nil) then
    with TPanelCustomField(FieldProperties.FieldObject) do
      Result := ConvertFieldValue(FGetValue, FType, LocalFormatSettings, False, ReturnEmptyIfFalse)
  else
    Result := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameCustom.GetCurrentValue(FieldTag: string;
  LocalFormatSettings: Boolean = False; ReturnEmptyIfFalse: Boolean = True): string;
begin
  if (Properties <> nil) then
    Result := GetCurrentValue(Properties.GetField(FieldTag), LocalFormatSettings, ReturnEmptyIfFalse)
  else
    Result := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetCurrentValue(FieldProperties: TCustomFieldProperties; FieldValue: string);
begin
  if (Properties <> nil) and (FieldProperties <> nil) and (FieldProperties.FieldObject <> nil) then
    with TPanelCustomField(FieldProperties.FieldObject) do
      FSetValue(ConvertFieldValue(FieldValue, FType, False, False, True));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetCurrentValue(FieldTag: string; FieldValue: string);
begin
  if (Properties <> nil) then
    SetCurrentValue(Properties.GetField(FieldTag), FieldValue);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrameCustom.FindURLControl(str: string): TAntJvComboEditXP;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to ControlCount-1 do
    if Controls[i] is TPanelCustomField then
      with TPanelCustomField(Controls[i]) do
        if (FType = ftURL) and (FControl is TAntJvComboEditXP) and
          SameText(TAntJvComboEditXP(FControl).Text, str) then
          begin
            Result := TAntJvComboEditXP(FControl);
            break;
          end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.SetAllowEdit(Value: Boolean);
begin
  FAllowEdit := Value;
  SetFieldsEnabled((not ActionMoveResizeCustomFields.Checked) and FAllowEdit);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FieldChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    FModified := True;
    if Assigned(FOnFieldChange) then
      FOnFieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FieldPropertiesChange(Sender: TObject);
begin
  FPropertiesModified := True;
  if Assigned(FOnFieldPropertiesChange) then
    FOnFieldPropertiesChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FieldValidate(Sender: TObject);
begin
  if Assigned(FOnFieldValidate) then
      FOnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FieldURLButtonClick(Sender: TObject);
begin
  if Assigned(OnURLButtonClick) then
    OnURLButtonClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrameCustom.FieldURLEnter(Sender: TObject);
begin
  if Assigned(OnURLEnter) then
    OnURLEnter(Sender);
end;

end.

