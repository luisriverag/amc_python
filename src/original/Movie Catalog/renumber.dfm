inherited RenumberWin: TRenumberWin
  Left = 616
  Top = 328
  BorderStyle = bsSingle
  Caption = 'Renumber movies'
  ClientHeight = 86
  ClientWidth = 384
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 53
    Width = 378
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 70
    Width = 384
  end
  inherited btn1: TCorelButton
    Left = 306
    Top = 58
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 228
    Top = 58
    Caption = 'OK'
    Default = True
    TabOrder = 3
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 150
    Top = 58
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 72
    Top = 58
    TabOrder = 1
  end
  inline SortBy: TSortByFrame
    Left = 3
    Top = 3
    Width = 378
    Height = 47
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
    inherited grp: TGroupBox
      Width = 378
      Height = 47
      Caption = 'Before renumbering, sort by'
      inherited EOrderBy: TComboBox
        Width = 200
      end
      inherited BtnAdvSort: TCorelButton
        Left = 215
      end
      inherited BtnSortDescend: TTBXButton
        Left = 344
        Top = 15
      end
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Renumbering movies ...')
    Left = 8
    Top = 56
  end
end
