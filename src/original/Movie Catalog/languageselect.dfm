inherited LanguageWin: TLanguageWin
  Left = 477
  Top = 314
  BorderStyle = bsSingle
  Caption = 'Select a language'
  ClientHeight = 463
  ClientWidth = 396
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 430
    Width = 390
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 447
    Width = 396
  end
  inherited btn1: TCorelButton
    Left = 318
    Top = 435
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 240
    Top = 435
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 162
    Top = 435
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 84
    Top = 435
    TabOrder = 1
  end
  inline LanguageFrame: TLanguageFrame
    Left = 3
    Top = 3
    Width = 390
    Height = 422
    Anchors = [akLeft, akTop, akRight, akBottom]
    ParentBackground = False
    TabOrder = 0
    inherited PanelForXpThemeBug: TPanel
      Width = 390
      Height = 422
      inherited lblVersionText: TLabel
        Top = 249
      end
      inherited lblVersion: TLabel
        Top = 249
      end
      inherited lblMadeby: TLabel
        Top = 273
      end
      inherited lblComments: TLabel
        Top = 353
      end
      inherited lblMadebyText: TAntJvLinkLabel
        Top = 273
        Height = 78
      end
      inherited lblCommentsText: TAntJvLinkLabel
        Top = 353
        Height = 65
      end
      inherited lstLanguages: TListView
        Width = 390
        Height = 240
        OnDblClick = LanguageFramelstLanguagesDblClick
      end
    end
  end
end
