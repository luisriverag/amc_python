inherited HTMLEditorWin: THTMLEditorWin
  Left = 480
  Top = 112
  HelpContext = 1021
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'HTML templates editor'
  ClientHeight = 462
  ClientWidth = 764
  Constraints.MinHeight = 400
  Constraints.MinWidth = 600
  OnCloseQuery = FormCloseQuery
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 429
    Width = 758
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 446
    Width = 764
  end
  inherited btn1: TCorelButton
    Left = 686
    Top = 434
    Caption = '&Help'
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 608
    Top = 434
    Caption = '&Close'
    Default = True
    ModalResult = 2
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 530
    Top = 434
  end
  inherited btn4: TCorelButton
    Left = 452
    Top = 434
  end
  inline HTMLTemplateEdit1: THTMLTemplateEdit
    Tag = 1
    Left = 0
    Top = 0
    Width = 764
    Height = 426
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 4
    inherited ETemplate: TSynEdit
      Width = 764
      Height = 401
    end
    inherited TBDock1: TTBXDock
      Width = 764
    end
  end
end
