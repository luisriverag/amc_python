(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2013-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit frameextra;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls,

  AntJvToolEdit, AntJvExControls, AntJvEdit, AntJvSpin,

  movieclass, ExtCtrls;

type
  TExtraFrame = class(TFrame)
    ETag: TComboBox;
    LTag: TLabel;
    chkTag: TCheckBox;
    ENumber: TAntJvSpinEdit;
    LNumber: TLabel;
    ETitle: TEdit;
    LTitle: TLabel;
    chkTitle: TCheckBox;
    ECategory: TComboBox;
    LCategory: TLabel;
    chkCategory: TCheckBox;
    ECreatedBy: TComboBox;
    LCreatedBy: TLabel;
    chkCreatedBy: TCheckBox;
    EURL: TAntJvComboEditXP;
    LURL: TLabel;
    chkURL: TCheckBox;
    LDescription: TLabel;
    chkDescription: TCheckBox;
    EDescription: TMemo;
    EComments: TMemo;
    LComments: TLabel;
    chkComments: TCheckBox;
    ExtraPanel: TPanel;
    procedure FrameResize(Sender: TObject);
    procedure ETagChange(Sender: TObject);
    procedure ETitleChange(Sender: TObject);
    procedure ECategoryChange(Sender: TObject);
    procedure EURLChange(Sender: TObject);
    procedure EDescriptionChange(Sender: TObject);
    procedure ECommentsChange(Sender: TObject);
    procedure ECreatedByChange(Sender: TObject);
    procedure FieldChange(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldURLButtonClick(Sender: TObject);
  private
    FAllowEdit: Boolean;
    FModified: Boolean;
    FCheckboxes: Boolean;
    FUpdateCount: Integer;
    FOnFieldChange: TNotifyEvent;
    FOnFieldValidate: TNotifyEvent;
    FOnURLButtonClick: TNotifyEvent;
    FOnURLEnter: TNotifyEvent;

    procedure SetAllowEdit(Value: Boolean);
    procedure SetModified(Value: Boolean);
    procedure SetCheckboxes(Value: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    procedure InitValues;
    procedure LoadFromObject(AExtra: TMovieExtra; const ChangeModified: Boolean = True);
    procedure SaveToObject(AExtra: TMovieExtra; const ChangeModified: Boolean = True;
      const ForceSave: Boolean = False);

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: Boolean;

    property AllowEdit: Boolean read FAllowEdit write SetAllowEdit;
    property Modified: Boolean read FModified write SetModified;
    property Checkboxes: Boolean read FCheckboxes write SetCheckboxes;
    property OnFieldChange: TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property OnFieldValidate: TNotifyEvent read FOnFieldValidate write FOnFieldValidate;
    property OnURLButtonClick: TNotifyEvent read FOnURLButtonClick write FOnURLButtonClick;
    property OnURLEnter: TNotifyEvent read FOnURLEnter write FOnURLEnter;
  end;

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TExtraFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAllowEdit := True;
  FModified := False;
  FCheckboxes := False;
  FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.InitValues;
begin
  ENumber.Text := '';
  ETag.Text := '';
  ETitle.Text := '';
  ECategory.Text := '';
  EURL.Text := '';
  EDescription.Text := '';
  EComments.Text := '';
  ECreatedBy.Text := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.LoadFromObject(AExtra: TMovieExtra; const ChangeModified: Boolean);
begin
  BeginUpdate;
  try
    with AExtra do
    begin
      ENumber.Value := iNumber;
      ETag.Text := strTag;
      ETitle.Text := strTitle;
      ECategory.Text := strCategory;
      EURL.Text := strURL;
      EDescription.Text := strDescription;
      EComments.Text := strComments;
      ECreatedBy.Text := strCreatedBy;
    end;
  finally
    EndUpdate;
  end;
  if ChangeModified then
    Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.SaveToObject(AExtra: TMovieExtra;
  const ChangeModified: Boolean; const ForceSave: Boolean);
begin
  if Modified or ForceSave then
    with AExtra do
    begin
      if chkTag.Checked or ForceSave then
        strTag := ETag.Text;
      if chkTitle.Checked or ForceSave then
        strTitle := ETitle.Text;
      if chkCategory.Checked or ForceSave then
        strCategory := ECategory.Text;
      if chkURL.Checked or ForceSave then
        strURL := EURL.Text;
      if chkDescription.Checked or ForceSave then
        strDescription := EDescription.Text;
      if chkComments.Checked or ForceSave then
        strComments := EComments.Text;
      if chkCreatedBy.Checked or ForceSave then
        strCreatedBy := ECreatedBy.Text;
    end;
  if ChangeModified then
    Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.SetAllowEdit(Value: Boolean);
var
  i: Integer;
begin
  FAllowEdit := Value;
  for i := 0 to ControlCount-1 do
    if (Controls[i] <> ENumber) then
      Controls[i].Enabled := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.SetModified(Value: Boolean);
begin
  FModified := Value;
  if not FModified then
  begin
    chkTag.Checked := False;
    chkTitle.Checked := False;
    chkCategory.Checked := False;
    chkURL.Checked := False;
    chkDescription.Checked := False;
    chkComments.Checked := False;
    chkCreatedBy.Checked := False;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.SetCheckboxes(Value: Boolean);
begin
  FCheckboxes := Value;
  chkTag.Visible := FCheckboxes;
  chkTitle.Visible := FCheckboxes;
  chkCategory.Visible := FCheckboxes;
  chkURL.Visible := FCheckboxes;
  chkDescription.Visible := FCheckboxes;
  chkComments.Visible := FCheckboxes;
  chkCreatedBy.Visible := FCheckboxes;

  if not FCheckboxes then
  begin
    LNumber.Left := chkTitle.Left;
    LTag.Left := chkTag.Left;
    LTitle.Left := chkTitle.Left;
    LCategory.Left := chkCategory.Left;
    LURL.Left := chkURL.Left;
    LDescription.Left := chkDescription.Left;
    LComments.Left := chkComments.Left;
    LCreatedBy.Left := chkCreatedBy.Left;
  end
  else
  begin
    LNumber.Left := chkTitle.Left + chkTitle.Width;
    LTag.Left := chkTag.Left + chkTag.Width;
    LTitle.Left := chkTitle.Left + chkTitle.Width;
    LCategory.Left := chkCategory.Left + chkCategory.Width;
    LURL.Left := chkURL.Left + chkURL.Width;
    LDescription.Left := chkDescription.Left + chkDescription.Width;
    LComments.Left := chkComments.Left + chkComments.Width;
    LCreatedBy.Left := chkCreatedBy.Left + chkCreatedBy.Width;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.FrameResize(Sender: TObject);
var
  h: Integer;
begin
  h := Height - EDescription.Top - 25 - 24;
  EDescription.Height := h div 2;
  EComments.Top := EDescription.Top + EDescription.Height + 22;
  EComments.Height := EDescription.Height + (h mod 2);
  chkComments.Top := EComments.Top - 19;
  LComments.Top := EComments.Top - 17;

  // Fix BUG : Remove auto SelectAll when ComboBox is resized
  ETag.SelLength := 0;
  ECategory.SelLength := 0;
  ECreatedBy.SelLength := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount < 0 then
    FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExtraFrame.IsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.ETagChange(Sender: TObject);
begin
  inherited;
  chkTag.Checked := True;
  FieldChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.ETitleChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkTitle.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.ECategoryChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkCategory.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.EURLChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkURL.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.EDescriptionChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkDescription.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.ECommentsChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkComments.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.ECreatedByChange(Sender: TObject);
begin
  if not IsUpdating then
  begin
    chkCreatedBy.Checked := True;
    FieldChange(Sender);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.FieldChange(Sender: TObject);
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

procedure TExtraFrame.FieldExit(Sender: TObject);
begin
  if Assigned(OnFieldValidate) then
    OnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.FieldKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or ((Key = VK_RETURN) and (Sender <> EDescription) and
    (Sender <> EComments)) then
    if Assigned(OnFieldValidate) then
      OnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraFrame.FieldKeyUp(Sender: TObject; var Key: Word;
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

procedure TExtraFrame.FieldURLButtonClick(Sender: TObject);
begin
  if Assigned(OnURLButtonClick) then
    OnURLButtonClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
