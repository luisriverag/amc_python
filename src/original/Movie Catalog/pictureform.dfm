object PictureWin: TPictureWin
  Left = 603
  Top = 393
  BorderStyle = bsToolWindow
  Caption = 'PictureWin'
  ClientHeight = 97
  ClientWidth = 116
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  object Image1: TImage
    Left = 0
    Top = 41
    Width = 113
    Height = 56
    AutoSize = True
    Center = True
    OnClick = Image1Click
  end
  object edtPicInfo: TMemo
    Left = 0
    Top = 0
    Width = 113
    Height = 41
    TabStop = False
    Alignment = taCenter
    BorderStyle = bsNone
    Lines.Strings = (
      'line1'
      'line2'
      'line3')
    ParentColor = True
    ReadOnly = True
    TabOrder = 0
    WordWrap = False
  end
end
