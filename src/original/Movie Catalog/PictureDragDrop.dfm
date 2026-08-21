inherited PictureDragDropWin: TPictureDragDropWin
  Left = 567
  Top = 446
  HelpContext = 1062
  BorderStyle = bsSingle
  Caption = 'Import a picture'
  ClientHeight = 143
  ClientWidth = 400
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 110
    Width = 394
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 127
    Width = 400
  end
  inherited btn1: TCorelButton
    Left = 322
    Top = 115
    Caption = 'Help'
    TabOrder = 5
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 244
    Top = 115
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 166
    Top = 115
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn4: TCorelButton
    Left = 88
    Top = 115
    TabOrder = 2
  end
  inline Options: TPictureSelectOptionsFrame
    Left = 4
    Top = 4
    Width = 391
    Height = 83
    Anchors = [akLeft, akTop, akRight]
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
    inherited grp: TGroupBox
      Left = 0
      Width = 391
      Height = 83
      Align = alClient
      inherited rbtStorePic: TRadioButton
        Width = 375
      end
      inherited rbtCopyPicInCatDir: TRadioButton
        Width = 375
      end
    end
  end
  object CBDoNotAsk: TCheckBox
    Left = 4
    Top = 90
    Width = 389
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Do not ask again, remember my selection for future importations'
    TabOrder = 1
  end
end
