inherited PickListWin: TPickListWin
  Left = 197
  Top = 113
  Caption = 'Description selection'
  ClientHeight = 411
  ClientWidth = 492
  Constraints.MinHeight = 400
  Constraints.MinWidth = 450
  OldCreateOrder = True
  Position = poOwnerFormCenter
  Scaled = False
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    492
    411)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 378
    Width = 486
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 395
    Width = 492
  end
  inherited btn1: TCorelButton
    Left = 414
    Top = 383
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 336
    Top = 383
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 258
    Top = 383
    TabOrder = 3
  end
  inherited btn4: TCorelButton
    Left = 180
    Top = 383
    TabOrder = 2
  end
  object ListBox1: TListBox
    Left = 3
    Top = 4
    Width = 486
    Height = 183
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnClick = ListBox1Click
    OnDblClick = ListBox1DblClick
  end
  object Memo1: TMemo
    Left = 3
    Top = 190
    Width = 486
    Height = 185
    Anchors = [akLeft, akTop, akRight]
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    WantReturns = False
  end
end
