(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2003-2006 Antoine Potten                                       *
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

unit PictureSelection;

interface

uses
  Forms, Messages, Classes, SysUtils, Dialogs, Controls, ExtCtrls, StdCtrls,

  AntJvGIF, JPEG, PNGImage,

  FramePictureSelectionOptions;

type
  TPictureSelectionWin = class(TOpenDialog)
  private
    FOptionsPanel: TPanel;
    FOptionsFrame: TPictureSelectOptionsFrame;
    FPicturePanel: TPanel;
    FPictureLabel: TLabel;
    FPaintPanel: TPanel;
    FImageCtrl: TImage;
    FSavedFilename: string;
  protected
    procedure DoSelectionChange; override;
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    function Execute(var ImportMethod: TPictureSelectOption): Boolean; reintroduce;
    property LinkOptions: TPictureSelectOptionsFrame read FOptionsFrame;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Windows, CommDlg, Consts,
  Global;

{$R PictureSelection.res}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TSilentPaintPanel = class(TPanel)
  protected
    procedure WMPaint(var Msg: TWMPaint); message WM_PAINT;
  end;

procedure TSilentPaintPanel.WMPaint(var Msg: TWMPaint);
begin
  try
    inherited;
  except
    Caption := SInvalidImage;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TPictureSelectionWin.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPicturePanel := TPanel.Create(Self);
  with FPicturePanel do
  begin
    Name := 'PicturePanel';
    Caption := '';
    SetBounds(204, 5, 169, 200);
    BevelOuter := bvNone;
    BorderWidth := 6;
    TabOrder := 1;
    FPictureLabel := TLabel.Create(Self);
    with FPictureLabel do
    begin
      Name := 'PictureLabel';
      Caption := '';
      SetBounds(6, 6, 157, 23);
      Align := alTop;
      AutoSize := False;
      Parent := FPicturePanel;
    end;
    FPaintPanel := TSilentPaintPanel.Create(Self);
    with FPaintPanel do
    begin
      Name := 'PaintPanel';
      Caption := '';
      SetBounds(6, 29, 157, 145);
      Align := alClient;
      BevelInner := bvRaised;
      BevelOuter := bvLowered;
      TabOrder := 0;
      FImageCtrl := TImage.Create(Self);
      Parent := FPicturePanel;
      with FImageCtrl do
      begin
        Name := 'PaintBox';
        Align := alClient;
        Parent := FPaintPanel;
        Proportional := True;
        Stretch := True;
        Center := True;
        IncrementalDisplay := True;
      end;
    end;
  end;
  FOptionsPanel := TPanel.Create(Self);
  with FOptionsPanel do
  begin
    Name := 'OptionsPanel';
    Caption := '';
    BevelOuter := bvNone;
    TabOrder := 2;
  end;
  FOptionsFrame := TPictureSelectOptionsFrame.Create(Self);
  with FOptionsFrame do
  begin
    Parent := FOptionsPanel;
    Align := alClient;
  end;
  Translator.Translate(FOptionsFrame);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureSelectionWin.DoSelectionChange;
var
  FullName: string;
  ValidPicture: Boolean;

  function ValidFile(const FileName: string): Boolean;
  begin
    Result := GetFileAttributes(PChar(FileName)) <> $FFFFFFFF;
  end;

begin
  FullName := FileName;
  if FullName <> FSavedFilename then
  begin
    FSavedFilename := FullName;
    ValidPicture := FileExists(FullName) and ValidFile(FullName);
    if ValidPicture then
    try
      FImageCtrl.Picture.LoadFromFile(FullName);
      FPictureLabel.Caption := Format(SPictureDesc,
        [FImageCtrl.Picture.Width, FImageCtrl.Picture.Height]);
      FPaintPanel.Caption := '';
    except
      ValidPicture := False;
    end;
    if not ValidPicture then
    begin
      FPictureLabel.Caption := SPictureLabel;
      FImageCtrl.Picture := nil;
      FPaintPanel.Caption := srNone;
    end;
  end;
  inherited DoSelectionChange;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureSelectionWin.DoShow;
var
  PreviewRect, StaticRect: TRect;
begin
  StaticRect := GetStaticRect;

  // preview panel
  GetClientRect(Handle, PreviewRect);
  PreviewRect.Left := StaticRect.Left + (StaticRect.Right - StaticRect.Left);
  Inc(PreviewRect.Top, 4);
  FPicturePanel.BoundsRect := PreviewRect;
  FImageCtrl.Picture := nil;
  FSavedFilename := '';
  FPaintPanel.Caption := srNone;
  FPicturePanel.ParentWindow := Handle;

  // options panel
  GetClientRect(Handle, PreviewRect);
  PreviewRect.Top := StaticRect.Top + (StaticRect.Bottom - StaticRect.Top);
  PreviewRect.Left := StaticRect.Left;
  PreviewRect.Right := StaticRect.Right;
  FOptionsPanel.BoundsRect := PreviewRect;
  FOptionsPanel.ParentWindow := Handle;
  FOptionsPanel.SendToBack;

  inherited DoShow;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureSelectionWin.Execute(var ImportMethod: TPictureSelectOption): Boolean;
begin
  if NewStyleControls and not (ofOldStyleDialog in Options) then
  begin
    Template := 'PICTURESELECT';
    FOptionsFrame.Selected := ImportMethod;
    Result := DoExecute(@GetOpenFileName);
    ImportMethod := FOptionsFrame.Selected;
  end
  else
    raise Exception.Create('TPictureSelectionWin must use new style controls');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
