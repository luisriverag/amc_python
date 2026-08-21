object ProgressWin: TProgressWin
  Left = 345
  Top = 272
  AutoSize = True
  BorderIcons = []
  BorderStyle = bsNone
  ClientHeight = 129
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 321
    Height = 129
    TabOrder = 0
    object LStatus: TLabel
      Left = 8
      Top = 8
      Width = 305
      Height = 25
      Alignment = taCenter
      AutoSize = False
    end
    object LPosition: TLabel
      Left = 8
      Top = 40
      Width = 305
      Height = 16
      Alignment = taCenter
      AutoSize = False
      Caption = 'LPosition'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object PPosition: TProgressBar
      Left = 8
      Top = 64
      Width = 305
      Height = 25
      Smooth = True
      TabOrder = 1
    end
    object btnCancel: TCorelButton
      Left = 123
      Top = 96
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'btnCancel'
      Default = True
      TabOrder = 0
      Visible = False
      OnClick = btnCancelClick
    end
  end
end
