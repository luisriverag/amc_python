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

unit pictureform;

interface

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls;

type
  TPictureWin = class(TForm)
    Image1: TImage;
    edtPicInfo: TMemo;
    procedure Image1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormActivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    FCenterWindow: Boolean;
    procedure SaveOptions;
    function GetInfoPanelHeight: Integer;
  public
    property CenterWindow: Boolean read FCenterWindow write FCenterwindow;
    procedure Execute(const WindowCaption: string; MoviePicture: TGraphic); overload;
    procedure Execute(const WindowCaption: string; PictureStream: TStream; const PictureExt: string); overload;
    procedure Execute(const WindowCaption: string; PictureFile: TFileName); overload;
  end;

var
  PictureWin: TPictureWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Math,

  AntJvGIF, JPEG, PNGImage,

  ConstValues, Global, functions_str, functions_files;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.FormCreate(Sender: TObject);
begin
  edtPicInfo.Visible := Settings.rOptions.rMovieInformation.PictureInfo;
  Image1.Top := GetInfoPanelHeight;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.Image1Click(Sender: TObject);
begin
  Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.Execute(const WindowCaption: string; MoviePicture: TGraphic);
begin
  Caption := WindowCaption;
  Image1.AutoSize := True;
  Image1.Picture.Assign(MoviePicture);
  Image1.AutoSize := False;
  if Image1.Width < 128 then
    Image1.Width := 128;
  if Image1.Height < 128 then
    Image1.Height := 128;
  if edtPicInfo.Visible then
    edtPicInfo.Text := sLineBreak + sLineBreak + sLineBreak;
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.Execute(const WindowCaption: string; PictureStream: TStream; const PictureExt: string);
var
  loadedPic: TGraphic;
  PicSizeDouble: Double;
begin
  Caption := WindowCaption;
  Image1.AutoSize := True;
  case IndexText(PictureExt, extImage) of
    extPNG:
      loadedPic := TPNGObject.Create;
    extJPG, extJPE, extJPEG:
      loadedPic := TJPEGImage.Create;
    extGIF:
      loadedPic := TJvGIFImage.Create;
    extBMP:
      loadedPic := TBitmap.Create;
  else
    loadedPic := nil;
    Abort;
  end;
  PictureStream.Seek(0, soFromBeginning);
  loadedPic.LoadFromStream(PictureStream);
  Image1.Picture.Assign(loadedPic);
  loadedPic.Free;
  Image1.AutoSize := False;
  if Image1.Width < 128 then
    Image1.Width := 128;
  if Image1.Height < 128 then
    Image1.Height := 128;
  if edtPicInfo.Visible then
  begin
    PicSizeDouble := PictureStream.Size;
    edtPicInfo.Lines.Text := Format('%1:s%0:s%2:.0n%0:s%3:s', [
      sLineBreak,
      typeImage[IndexText(PictureExt, extImage)],
      PicSizeDouble,
      ''
    ]);
  end;
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.Execute(const WindowCaption: string; PictureFile: TFileName);
var
  PicSizeDouble: Double;
begin
  Caption := WindowCaption;
  Image1.AutoSize := True;
  Image1.Picture.LoadFromFile(PictureFile);
  Image1.AutoSize := False;
  if Image1.Width < 128 then
    Image1.Width := 128;
  if Image1.Height < 128 then
    Image1.Height := 128;
  if edtPicInfo.Visible then
  begin
    PicSizeDouble := GetFileSize(PictureFile);
    edtPicInfo.Lines.Text := Format('%1:s%0:s%2:s%0:s%3:.0n', [
      sLineBreak,
      ExtractFilePath(PictureFile),
      ExtractFileName(PictureFile),
      PicSizeDouble
    ]);
  end;
  ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.FormActivate(Sender: TObject);
var
  Ratio: Double;
  InfoHeight: Integer;
begin
  Ratio := Image1.Width / Image1.Height;
  InfoHeight := GetInfoPanelHeight;
  ClientWidth := Image1.Width;
  ClientHeight := Image1.Height + InfoHeight;
  if Width >= Screen.WorkAreaWidth then
  begin
    Image1.AutoSize := False;
    Image1.Stretch := True;
    Image1.Width := Trunc(Screen.WorkAreaWidth * 0.9);
    Image1.Height := Trunc(Image1.Width / Ratio);
  end;
  ClientWidth := Image1.Width;
  ClientHeight := Image1.Height + InfoHeight;
  if Height >= Screen.WorkAreaHeight then
  begin
    Image1.AutoSize := False;
    Image1.Stretch := True;
    Image1.Height := Trunc(Screen.WorkAreaHeight * 0.9) - InfoHeight;
    Image1.Width := Trunc(Image1.Height * Ratio);
  end;
  ClientWidth := Image1.Width;
  ClientHeight := Image1.Height + InfoHeight;
  {
  if edtPicInfo.Visible then
  begin
    Width := Max(Width, Trunc(Canvas.TextWidth(edtPicInfo.Lines[0]) * 1.1));
    Width := Max(Width, Trunc(Canvas.TextWidth(edtPicInfo.Lines[1]) * 1.1));
  end;
  ClientWidth := Image1.Width;
  ClientHeight := Image1.Height + InfoHeight;
  }
   edtPicInfo.Width := ClientWidth;
  if FCenterWindow then
  begin
    Left := Left - 1; // width does not seem to be updated until left is modified; i'm fed up with search why
    Left := (Screen.WorkAreaWidth - Width) div 2;
    Top := (Screen.WorkAreaHeight - Height) div 2;
  end
  else
  begin
    Left := Settings.rMain.PictureWinLeft;
    Top := Settings.rMain.PictureWinTop;
  end;
  ClientWidth := Image1.Width;
  ClientHeight := Image1.Height + InfoHeight;
  FocusControl(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.SaveOptions;
begin
  if not FCenterWindow then
  begin
    Settings.rMain.PictureWinLeft := Left;
    Settings.rMain.PictureWinTop := Top;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveOptions;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureWin.GetInfoPanelHeight: Integer;
begin
  if edtPicInfo.Visible then
    Result := edtPicInfo.Height
  else
    Result := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
