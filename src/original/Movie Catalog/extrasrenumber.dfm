inherited ExtrasRenumberWin: TExtrasRenumberWin
  Left = 467
  Top = 345
  BorderStyle = bsSingle
  Caption = 'Renumber extras'
  ClientHeight = 180
  ClientWidth = 384
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 147
    Width = 378
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 164
    Width = 384
  end
  inherited btn1: TCorelButton
    Left = 306
    Top = 152
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 228
    Top = 152
    Caption = 'OK'
    Default = True
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 150
    Top = 152
  end
  inherited btn4: TCorelButton
    Left = 72
    Top = 152
  end
  inline SortBy: TExtrasSortByFrame
    Left = 3
    Top = 3
    Width = 378
    Height = 141
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
    inherited grp: TGroupBox
      Width = 378
      Height = 141
      Caption = 'Before renumbering extras, sort by'
      inherited EOrderBy: TComboBox
        Width = 199
      end
      inherited BtnAdvSort: TCorelButton
        Left = 214
      end
      inherited BtnSortDescend: TTBXButton
        Left = 344
        Top = 15
      end
    end
  end
  object chkAllMovies: TCheckBox
    Left = 13
    Top = 51
    Width = 356
    Height = 17
    Caption = 'Sort and renumber extras on all movies'
    TabOrder = 5
    OnClick = chkAllMoviesClick
  end
  inline FrmIncludemov: TIncludemovFrame
    Left = 13
    Top = 72
    Width = 358
    Height = 67
    TabOrder = 6
    inherited grp: TGroupBox
      Width = 358
      Height = 67
      inherited rbtAll: TRadioButton
        Width = 160
      end
      inherited rbtSelected: TRadioButton
        Left = 184
        Top = 18
        Width = 160
      end
      inherited rbtChecked: TRadioButton
        Top = 40
        Width = 160
      end
      inherited rbtVisible: TRadioButton
        Left = 184
        Top = 40
        Width = 160
      end
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Renumbering extras ...')
    Left = 16
    Top = 184
  end
end
