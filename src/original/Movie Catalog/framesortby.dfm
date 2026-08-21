object SortByFrame: TSortByFrame
  Left = 0
  Top = 0
  Width = 350
  Height = 46
  TabOrder = 0
  object grp: TGroupBox
    Left = 0
    Top = 0
    Width = 350
    Height = 46
    Align = alClient
    Caption = 'Sort by'
    TabOrder = 0
    DesignSize = (
      350
      46)
    object EOrderBy: TComboBox
      Left = 10
      Top = 16
      Width = 171
      Height = 21
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      OnChange = EOrderByChange
      Items.Strings = (
        'Number'
        'Original Title'
        'Translated Title'
        'Formatted Title'
        'Advanced sort options...')
    end
    object BtnAdvSort: TCorelButton
      Left = 186
      Top = 16
      Width = 124
      Height = 21
      Anchors = [akTop, akRight]
      Caption = 'Advanced...'
      TabOrder = 1
      OnClick = BtnAdvSortClick
    end
    object BtnSortDescend: TTBXButton
      Left = 317
      Top = 14
      Width = 23
      Height = 23
      Hint = '|Sort in descending order'
      GroupIndex = 1
      AllowAllUnchecked = True
      AutoSize = False
      Caption = 'Desc'
      TabOrder = 2
    end
  end
end
