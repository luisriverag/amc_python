(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2006 Antoine Potten                                       *
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

unit progress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ComCtrls, StdCtrls, AntCorelButton;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TProgressWin = class(TForm)
    Panel1: TPanel;
    LStatus: TLabel;
    LPosition: TLabel;
    PPosition: TProgressBar;
    btnCancel: TCorelButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FMaximum: Integer;
    FCaller: TForm;
    FOnCancel: TNotifyEvent;
    FPrevCursor: TCursor;
    procedure SetStatus(const NewStatus: string);
    procedure SetMaximum(const NewMaximum: integer);
    procedure SetIntProgress(const NewPosition: Integer);
    procedure SetProgress(const NewText: string);
    procedure SetOnCancel(const Value: TNotifyEvent);
    function GetIntProgress: Integer;
  public
    AutoUpdateTextProgress: Boolean;
    procedure Execute(Sender: TForm);
    property Status: string write SetStatus;
    property IntProgress: Integer read GetIntProgress write SetIntProgress;
    property Maximum: Integer read FMaximum write SetMaximum;
    property Progress: string write SetProgress;
    property OnCancel: TNotifyEvent read FOnCancel write SetOnCancel;
    procedure StepIt;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.DFM}

uses
  Global, MessageForm;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.SetStatus(const NewStatus: string);
begin
  LStatus.Caption := NewStatus;
  Application.ProcessMessages;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.SetIntProgress(const NewPosition: Integer);
begin
  if (FMaximum > 0) and (NewPosition <= FMaximum) then
  begin
    if AutoUpdateTextProgress then
      LPosition.Caption := Format('%02d %%',[Round((NewPosition/FMaximum)*100)]);
    // Trick to force draw without delay on window 7
    if NewPosition < PPosition.Max then
      PPosition.Position := NewPosition + 1;
    PPosition.Position := NewPosition;
    Application.ProcessMessages;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.SetProgress(const NewText: string);
begin
  LPosition.Caption := NewText;
  Application.ProcessMessages;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.SetMaximum(const NewMaximum: Integer);
begin
  FMaximum := NewMaximum;
  PPosition.Max := NewMaximum;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.FormCreate(Sender: TObject);
begin
  FMaximum := 1;
  PPosition.Max := 1;
  AutoUpdateTextProgress := True;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.Execute(Sender: TForm);
begin
  FPrevCursor := Screen.Cursor;
  FCaller := Sender;
  Position := poMainFormCenter;
  Show;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.FormShow(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  FCaller.Enabled := False;
  Application.ProcessMessages;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Application.ProcessMessages;
  FCaller.Enabled := True;
  Screen.Cursor := FPrevCursor;
  Action := caHide;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.SetOnCancel(const Value: TNotifyEvent);
begin
  FOnCancel := Value;
  btnCancel.Visible := Assigned(Value);
  if Assigned(FOnCancel) and Assigned(MessageWin) then
  begin
    Screen.Cursor := crAppStart;
    btnCancel.Caption := MessageWin.Captions.Strings[Integer(mbCancel) + MessageForm.FirstBtn];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.btnCancelClick(Sender: TObject);
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TProgressWin.StepIt;
begin
  SetIntProgress(PPosition.Position + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TProgressWin.GetIntProgress: Integer;
begin
  Result := PPosition.Position;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
