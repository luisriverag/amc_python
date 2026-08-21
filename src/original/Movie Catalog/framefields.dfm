object FieldsFrame: TFieldsFrame
  Left = 0
  Top = 0
  Width = 297
  Height = 250
  ParentShowHint = False
  ShowHint = True
  TabOrder = 0
  DesignSize = (
    297
    250)
  object LAvailable: TLabel
    Left = 0
    Top = 0
    Width = 73
    Height = 13
    Caption = 'Available fields:'
    FocusControl = LbAvailable
  end
  object LSelected: TLabel
    Left = 168
    Top = 0
    Width = 72
    Height = 13
    Caption = 'Selected fields:'
    FocusControl = LbSelected
  end
  object LbSelected: TListBox
    Left = 168
    Top = 16
    Width = 129
    Height = 233
    Anchors = [akLeft, akTop, akBottom]
    ExtendedSelect = False
    ItemHeight = 13
    TabOrder = 7
    OnDblClick = LbDblClick
    OnKeyUp = LbKeyUp
  end
  object LbAvailable: TListBox
    Left = 0
    Top = 16
    Width = 129
    Height = 233
    Anchors = [akLeft, akTop, akBottom]
    ExtendedSelect = False
    ItemHeight = 13
    TabOrder = 0
    OnDblClick = LbDblClick
    OnKeyUp = LbKeyUp
  end
  object BtnAdd: TTBXButton
    Left = 135
    Top = 105
    Width = 27
    Height = 26
    Hint = 'Add|Add selected field'
    AutoSize = False
    Caption = 'add'
    TabOrder = 3
    OnClick = BtnAddClick
  end
  object BtnRem: TTBXButton
    Left = 135
    Top = 137
    Width = 27
    Height = 26
    Hint = 'Remove|Remove selected field'
    AutoSize = False
    Caption = 'rem'
    TabOrder = 4
    OnClick = BtnRemClick
  end
  object BtnAddAll: TTBXButton
    Left = 135
    Top = 185
    Width = 27
    Height = 26
    Hint = 'Add All|Add all fields'
    AutoSize = False
    Caption = '+all'
    TabOrder = 5
    OnClick = BtnAddAllClick
  end
  object BtnRemAll: TTBXButton
    Left = 135
    Top = 217
    Width = 27
    Height = 26
    Hint = 'Remove All|Remove all fields'
    AutoSize = False
    Caption = '-all'
    TabOrder = 6
    OnClick = BtnRemAllClick
  end
  object BtnUp: TTBXButton
    Left = 135
    Top = 24
    Width = 27
    Height = 26
    Hint = 'Move Up|Move selected item up'
    AutoSize = False
    Caption = 'up'
    TabOrder = 1
    OnClick = BtnUpClick
  end
  object BtnDown: TTBXButton
    Left = 135
    Top = 56
    Width = 27
    Height = 26
    Hint = 'Move Down|Move selected item down'
    AutoSize = False
    Caption = 'dn'
    TabOrder = 2
    OnClick = BtnDownClick
  end
end
