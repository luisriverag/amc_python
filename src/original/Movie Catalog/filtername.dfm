inherited FilterNameWin: TFilterNameWin
  Left = 547
  Top = 288
  Caption = 'Filter name'
  ClientHeight = 362
  ClientWidth = 484
  Constraints.MinHeight = 400
  Constraints.MinWidth = 500
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 329
    Width = 478
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 346
    Width = 484
  end
  object LSearchEdit: TLabel [2]
    Left = 8
    Top = 21
    Width = 83
    Height = 13
    Caption = 'Edit selected line:'
    FocusControl = ESearchName
  end
  inherited btn1: TCorelButton
    Left = 406
    Top = 334
    Caption = 'Cancel'
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 328
    Top = 334
    Caption = 'OK'
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 250
    Top = 334
  end
  inherited btn4: TCorelButton
    Left = 172
    Top = 334
  end
  object ESearchName: TEdit
    Left = 8
    Top = 40
    Width = 150
    Height = 21
    TabOrder = 4
  end
  object ESearchAddress: TEdit
    Left = 159
    Top = 40
    Width = 314
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object LvSearch: TListView
    Left = 8
    Top = 64
    Width = 465
    Height = 259
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Name'
        Width = 146
      end
      item
        AutoSize = True
        Caption = 'Address'
      end>
    ColumnClick = False
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    ShowColumnHeaders = False
    TabOrder = 6
    ViewStyle = vsReport
  end
  object btnSearchAdd: TTBXButton
    Left = 352
    Top = 16
    Width = 23
    Height = 22
    Hint = 'Add|Add a new item above selected item'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'ad'
    TabOrder = 7
  end
  object btnSearchDel: TTBXButton
    Left = 376
    Top = 16
    Width = 23
    Height = 22
    Hint = 'Delete|Delete selected item'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'del'
    TabOrder = 8
  end
  object btnSearchUp: TTBXButton
    Left = 400
    Top = 16
    Width = 23
    Height = 22
    Hint = 'Move up|Move up selected item'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'up'
    TabOrder = 9
  end
  object btnSearchDown: TTBXButton
    Left = 424
    Top = 16
    Width = 23
    Height = 22
    Hint = 'Move down|Move down selected item'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'dn'
    TabOrder = 10
  end
end
