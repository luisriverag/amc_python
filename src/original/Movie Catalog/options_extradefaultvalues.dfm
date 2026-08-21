inherited ExtraDefaultValuesWin: TExtraDefaultValuesWin
  Left = 609
  Top = 313
  Caption = 'Edit default extra values'
  ClientHeight = 303
  ClientWidth = 416
  Constraints.MinHeight = 341
  Constraints.MinWidth = 432
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 270
    Width = 410
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 287
    Width = 416
  end
  inherited btn1: TCorelButton
    Left = 338
    Top = 275
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 260
    Top = 275
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 182
    Top = 275
    Hint = '|Restore default values'
    Caption = 'Default'
    TabOrder = 2
    Visible = True
    OnClick = btn3Click
  end
  inherited btn4: TCorelButton
    Left = 104
    Top = 275
    TabOrder = 1
  end
  object PanelExtra: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 268
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    Constraints.MinHeight = 268
    Constraints.MinWidth = 416
    TabOrder = 0
    inline FrmExtra: TExtraFrame
      Left = 0
      Top = 0
      Width = 416
      Height = 268
      Align = alClient
      TabOrder = 0
    end
  end
end
