inherited DefaultValuesWin: TDefaultValuesWin
  Left = 713
  Top = 137
  Caption = 'Edit default movie values'
  ClientHeight = 520
  ClientWidth = 533
  Constraints.MinHeight = 558
  Constraints.MinWidth = 549
  OldCreateOrder = True
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 487
    Width = 527
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 504
    Width = 533
  end
  inherited btn1: TCorelButton
    Left = 455
    Top = 492
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 377
    Top = 492
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 299
    Top = 492
    Hint = '|Restore default values'
    Caption = 'Defaults'
    TabOrder = 2
    Visible = True
    OnClick = btn3Click
  end
  inherited btn4: TCorelButton
    Left = 221
    Top = 492
    TabOrder = 1
  end
  object PanelMovie: TPanel
    Left = 0
    Top = 0
    Width = 533
    Height = 486
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    inline FrmMovie: TMovieFrame
      Left = 0
      Top = 0
      Width = 533
      Height = 486
      Align = alClient
      AutoScroll = False
      Constraints.MinHeight = 458
      Constraints.MinWidth = 533
      ParentBackground = False
      TabOrder = 0
      inherited MoviePanel: TPanel
        Height = 486
        inherited PanelMain: TPanel
          Height = 294
          inherited LCountry: TLabel
            Anchors = [akLeft, akTop, akRight]
          end
          inherited LComments: TLabel
            Top = 253
          end
          inherited ImgExpand2: TImage
            Top = 279
          end
          inherited EComments: TMemo
            Top = 250
          end
        end
        inherited PanelVideo: TPanel
          Top = 366
        end
      end
    end
  end
end
