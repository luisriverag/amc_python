inherited ListWin: TListWin
  Left = 630
  Caption = 'ListWin'
  ClientHeight = 232
  ClientWidth = 223
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 199
    Width = 217
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 216
    Width = 223
  end
  inherited btn1: TCorelButton
    Left = 145
    Top = 204
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 67
    Top = 204
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = -11
    Top = 204
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = -89
    Top = 204
    TabOrder = 1
  end
  object lst: TListBox
    Left = 3
    Top = 3
    Width = 217
    Height = 193
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    TabOrder = 0
    OnClick = lstClick
    OnDblClick = lstDblClick
  end
end
