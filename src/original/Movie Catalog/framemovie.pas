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

unit framemovie;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,

  AntJvEdit, AntJvSpin, AntJvExControls, AntJvToolEdit,

  movieclass, ComCtrls;

type
  TMovieFrame = class(TFrame)
    EVideoFormat: TComboBox;
    ETranslatedTitle: TEdit;
    ESubtitles: TComboBox;
    ESource: TComboBox;
    ESize: TEdit;
    EResolution: TEdit;
    EProducer: TEdit;
    EOriginalTitle: TEdit;
    EMediaType: TComboBox;
    EMedia: TEdit;
    ELanguages: TComboBox;
    EFramerate: TComboBox;
    EDirector: TEdit;
    EDescription: TMemo;
    EDate: TDateTimePicker;
    ECountry: TComboBox;
    EComments: TMemo;
    ECategory: TComboBox;
    EBorrower: TComboBox;
    EAudioFormat: TComboBox;
    EActors: TMemo;
    ERating: TAntJvSpinEdit;
    EYear: TAntJvSpinEdit;
    EVideoBitrate: TAntJvSpinEdit;
    ELength: TAntJvSpinEdit;
    EDisks: TAntJvSpinEdit;
    EAudioBitrate: TAntJvSpinEdit;
    EURL: TAntJvComboEditXP;
    EUserRating: TAntJvSpinEdit;
    EDateWatched: TDateTimePicker;
    EFilePath: TAntJvComboEditXP;
    EWriter: TEdit;
    EComposer: TEdit;
    ECertification: TComboBox;
    MoviePanel: TPanel;
    ImgCollapse2: TImage;
    ImgExpand2: TImage;
    ImgExpand1: TImage;
    LActors: TLabel;
    LAudioFormat: TLabel;
    LAudioKbps: TLabel;
    LBorrower: TLabel;
    LCategory: TLabel;
    LCertification: TLabel;
    LComments: TLabel;
    LComposer: TLabel;
    LCountry: TLabel;
    LDate: TLabel;
    LDateWatched: TLabel;
    LDescription: TLabel;
    LDirector: TLabel;
    LDisks: TLabel;
    LFilePath: TLabel;
    LFramerate: TLabel;
    LFramerateFPS: TLabel;
    LLanguages: TLabel;
    LLength: TLabel;
    LLengthMin: TLabel;
    LMedia: TLabel;
    LMediaType: TLabel;
    LUserRating: TLabel;
    LUserRating10: TLabel;
    LOriginalTitle: TLabel;
    LProducer: TLabel;
    LRating10: TLabel;
    LResolution: TLabel;
    LSize: TLabel;
    LSizeUnit: TLabel;
    LSource: TLabel;
    LSubtitles: TLabel;
    LTranslatedTitle: TLabel;
    LURL: TLabel;
    LVideoFormat: TLabel;
    LVideoKbps: TLabel;
    LWriter: TLabel;
    LYear: TLabel;
    LRating: TLabel;
    PanelMedia: TPanel;
    PanelMain: TPanel;
    PanelVideo: TPanel;
    ImgCollapse1: TImage;
    ImgCollapseEnd1: TImage;
    ImgCollapseEnd2: TImage;

    procedure FrameResize(Sender: TObject);
    procedure PanelMainResize(Sender: TObject);
    procedure FieldChange(Sender: TObject);
    procedure FieldExit(Sender: TObject);
    procedure FieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FieldURLButtonClick(Sender: TObject);
    procedure ImgExpand1Click(Sender: TObject);
    procedure ImgExpand2Click(Sender: TObject);
    procedure ImgCollapse1Click(Sender: TObject);
    procedure ImgCollapse2Click(Sender: TObject);
  private
    FAllowEdit: Boolean;
    FModified: Boolean;
    FUpdateCount: Integer;
    FOnFieldChange: TNotifyEvent;
    FOnFieldValidate: TNotifyEvent;
    FOnURLButtonClick: TNotifyEvent;
    FOnURLEnter: TNotifyEvent;

    procedure SetAllowEdit(Value: Boolean);

  public
    constructor Create(AOwner: TComponent); override;
    procedure SaveToObject(AMovie: TMovie; const ForceSave: Boolean = False);
    procedure LoadFromObject(AMovie: TMovie);

    procedure BeginUpdate;
    procedure EndUpdate;
    function IsUpdating: Boolean;

    property AllowEdit: Boolean read FAllowEdit write SetAllowEdit;
    property Modified: Boolean read FModified write FModified;
    property OnFieldChange: TNotifyEvent read FOnFieldChange write FOnFieldChange;
    property OnFieldValidate: TNotifyEvent read FOnFieldValidate write FOnFieldValidate;
    property OnURLButtonClick: TNotifyEvent read FOnURLButtonClick write FOnURLButtonClick;
    property OnURLEnter: TNotifyEvent read FOnURLEnter write FOnURLEnter;
  end;

implementation

uses
  Global, functions_files;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TMovieFrame.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAllowEdit := True;
  FModified := False;
  FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.LoadFromObject(AMovie: TMovie);
begin
  BeginUpdate;
  try
    with AMovie do
    begin
      EMedia.Text := strMedia;
      EMediaType.Text := strMediaType;
      ESource.Text := strSource;
      try
        if iDate = 0 then
          EDate.DateTime := Date
        else
          EDate.DateTime := iDate;
        EDate.Checked := iDate <> 0;
      except
        EDate.DateTime := Date;
        EDate.Checked := False;
      end;
      EBorrower.Text := strBorrower;
      try
        if iDateWatched = 0 then
          EDateWatched.DateTime := Date
        else
          EDateWatched.DateTime := iDateWatched;
        EDateWatched.Checked := iDateWatched <> 0;
      except
        EDateWatched.DateTime := Date;
        EDateWatched.Checked := False;
      end;
      if iUserRating = -1 then
        EUserRating.Text := ''
      else
        EUserRating.Value := iUserRating / 10;
      if iRating = -1 then
        ERating.Text := ''
      else
        ERating.Value := iRating / 10;
      EOriginalTitle.Text := strOriginalTitle;
      ETranslatedTitle.Text := strTranslatedTitle;
      EDirector.Text := strDirector;
      EProducer.Text := strProducer;
      EWriter.Text := strWriter;
      EComposer.Text := strComposer;
      EActors.Text := strActors;
      ECountry.Text := strCountry;
      EYear.Value := iYear;
      ELength.Value := iLength;
      ECategory.Text := strCategory;
      ECertification.Text := strCertification;
      EURL.Text := strURL;
      EDescription.Text := strDescription;
      EComments.Text := strComments;
      EFilePath.Text := strFilePath;
      EVideoFormat.Text := strVideoFormat;
      EVideoBitrate.Value := iVideoBitrate;
      EAudioFormat.Text := strAudioFormat;
      EAudioBitrate.Value := iAudioBitrate;
      EResolution.Text := strResolution;
      EFramerate.Text := strFramerate;
      ELanguages.Text := strLanguages;
      ESubtitles.Text := strSubtitles;
      ESize.Text := strSize;
      EDisks.Value := iDisks;
    end;
  finally
    EndUpdate;
  end;
  Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.SaveToObject(AMovie: TMovie; const ForceSave: Boolean = False);
begin
  if Modified or ForceSave then
    with AMovie do
    begin
      strMedia := EMedia.Text;
      strMediaType := EMediaType.Text;
      strSource := ESource.Text;
      if EDate.Checked then
        iDate := Trunc(EDate.DateTime)
      else
        iDate := 0;
      strBorrower := EBorrower.Text;
      if EDateWatched.Checked then
        iDateWatched := Trunc(EDateWatched.DateTime)
      else
        iDateWatched := 0;
      if EUserRating.Text = '' then
        iUserRating := -1
      else
        iUserRating := Trunc(EUserRating.Value * 10);
      if ERating.Text = '' then
        iRating := -1
      else
        iRating := Trunc(ERating.Value * 10);
      strOriginalTitle := EOriginalTitle.Text;
      strTranslatedTitle := ETranslatedTitle.Text;
      strDirector := EDirector.Text;
      strProducer := EProducer.Text;
      strWriter := EWriter.Text;
      strComposer := EComposer.Text;
      strActors := EActors.Text;
      strCountry := ECountry.Text;
      iYear := EYear.AsInteger;
      iLength := ELength.AsInteger;
      strCategory := ECategory.Text;
      strCertification := ECertification.Text;
      strURL := EURL.Text;
      strDescription := EDescription.Text;
      strComments := EComments.Text;
      strFilePath := EFilePath.Text;
      strVideoFormat := EVideoFormat.Text;
      iVideoBitrate := EVideoBitrate.AsInteger;
      strAudioFormat := EAudioFormat.Text;
      iAudioBitrate := EAudioBitrate.AsInteger;
      strResolution := EResolution.Text;
      strFramerate := EFramerate.Text;
      strLanguages := ELanguages.Text;
      strSubtitles := ESubtitles.Text;
      strSize := ESize.Text;
      iDisks := EDisks.AsInteger;
    end;
  if not ForceSave then
    Modified := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.SetAllowEdit(Value: Boolean);
var
  i: Integer;
begin
  FAllowEdit := Value;
  with PanelMedia do
    for i := 0 to ControlCount-1 do
      if not (Controls[i] is TImage) then
        Controls[i].Enabled := Value;
  with PanelMain do
    for i := 0 to ControlCount-1 do
      if not (Controls[i] is TImage) then
        Controls[i].Enabled := Value;
  with PanelVideo do
    for i := 0 to ControlCount-1 do
      if not (Controls[i] is TImage) then
        Controls[i].Enabled := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.FrameResize(Sender: TObject);
begin
  // Fix BUG : Remove auto SelectAll when ComboBox is resized
  EMediaType.SelLength := 0;
  ESource.SelLength := 0;
  EBorrower.SelLength := 0;
  ECountry.SelLength := 0;
  ECategory.SelLength := 0;
  ECertification.SelLength := 0;
  EVideoFormat.SelLength := 0;
  EAudioFormat.SelLength := 0;
  ELanguages.SelLength := 0;
  ESubtitles.SelLength := 0;
  EFramerate.SelLength := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.PanelMainResize(Sender: TObject);
var
  h, w, w1: Integer;
begin
  // Manage height for description and comments fields
  if (PanelMain.Tag = 0) or (PanelMain.Tag = 1) then
  begin
    h := PanelMain.Height - EDescription.Top - 4;
    EDescription.Height := h div 2;
    EComments.Top := EDescription.Top + EDescription.Height + 3;
    EComments.Height := EDescription.Height + (h mod 2);
    LComments.Top := EComments.Top + 4;
  end;

  // Manage width for category and certification fields
  if (PanelMain.Tag = 0) or (PanelMain.Tag = 2) then
  begin
    w := PanelMain.Width - 104 - 15 - 72 - 5;
    if w < 337 then w1 := w - 80
    else if w > 479 then w1 := w - 80 - 142
    else w1 := 257;
    ECategory.Width := w1;
    LCertification.Left := ECategory.Left + ECategory.Width + 15;
    ECertification.Left := LCertification.Left + 72;
    ECertification.Width := w - w1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount < 0 then
    FUpdateCount := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFrame.IsUpdating: Boolean;
begin
  Result := FUpdateCount > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.FieldChange(Sender: TObject);
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

procedure TMovieFrame.FieldExit(Sender: TObject);
begin
  if Assigned(OnFieldValidate) then
    OnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.FieldKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) or ((Key = VK_RETURN) and (Sender <> EDescription) and
    (Sender <> EComments)) then
    if Assigned(OnFieldValidate) then
      OnFieldValidate(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.FieldKeyUp(Sender: TObject; var Key: Word;
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

procedure TMovieFrame.FieldURLButtonClick(Sender: TObject);
begin
  if Assigned(OnURLButtonClick) then
    OnURLButtonClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.ImgExpand1Click(Sender: TObject);
begin
  PanelMedia.Visible := True;
  ImgExpand1.Visible := False;
  FrameResize(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.ImgExpand2Click(Sender: TObject);
begin
  PanelVideo.Visible := True;
  ImgExpand2.Visible := False;
  FrameResize(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.ImgCollapse1Click(Sender: TObject);
begin
  PanelMedia.Visible := False;
  ImgExpand1.Visible := True;
  FrameResize(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieFrame.ImgCollapse2Click(Sender: TObject);
begin
  PanelVideo.Visible := False;
  ImgExpand2.Visible := True;
  FrameResize(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
