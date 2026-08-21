inherited PickTreeWin: TPickTreeWin
  Left = 796
  Top = 252
  Caption = 'Movie selection'
  ClientHeight = 411
  ClientWidth = 442
  Constraints.MinHeight = 400
  Constraints.MinWidth = 350
  OldCreateOrder = True
  Position = poOwnerFormCenter
  Scaled = False
  OnDestroy = FormDestroy
  DesignSize = (
    442
    411)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 378
    Width = 436
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 395
    Width = 442
  end
  object Label1: TLabel [2]
    Left = 6
    Top = 4
    Width = 430
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 'Message if it is not empty'
    Layout = tlCenter
    WordWrap = True
  end
  inherited btn1: TCorelButton
    Left = 364
    Top = 383
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 286
    Top = 383
    Caption = 'Find &more'
    ModalResult = 4
    TabOrder = 4
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 208
    Top = 383
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn4: TCorelButton
    Left = 130
    Top = 383
    TabOrder = 2
  end
  object TreeView1: TTreeView
    Left = 3
    Top = 36
    Width = 436
    Height = 339
    Anchors = [akLeft, akTop, akRight, akBottom]
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 0
    OnChange = TreeView1Change
    OnDblClick = TreeView1DblClick
  end
  object btnView: TCorelButton
    Left = 3
    Top = 383
    Width = 75
    Height = 25
    Hint = 'Launch web browser|'
    Anchors = [akLeft, akBottom]
    Caption = '&View Page'
    TabOrder = 1
    OnClick = btnViewClick
  end
end
