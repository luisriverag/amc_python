inherited ImportFrameQuery: TImportFrameQuery
  inherited grpPreview: TGroupBox
    Top = 187
    Height = 173
    TabOrder = 4
    DesignSize = (
      550
      173)
    inherited listPreview: TElTree
      Height = 135
      HeaderSections.Data = {F6FFFFFF00000000}
    end
  end
  object grpQuery: TGroupBox
    Left = 0
    Top = 143
    Width = 550
    Height = 44
    Align = alTop
    Caption = 'Query to execute'
    TabOrder = 3
    DesignSize = (
      550
      44)
    object lblQuerySelect: TLabel
      Left = 8
      Top = 20
      Width = 82
      Height = 13
      Caption = 'SELECT * FROM'
    end
    object lblQueryWhere: TLabel
      Left = 216
      Top = 20
      Width = 41
      Height = 13
      Caption = 'WHERE'
    end
    object edtQueryWhere: TEdit
      Left = 264
      Top = 16
      Width = 225
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object btnQueryExec: TTBXButton
      Left = 492
      Top = 16
      Width = 29
      Height = 21
      Hint = 'Execute|Execute query'
      Anchors = [akTop, akRight]
      AutoSize = False
      TabOrder = 2
      OnClick = btnReloadClick
    end
    object edtQueryFrom: TComboBox
      Left = 96
      Top = 16
      Width = 113
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      Text = 'edtQueryFrom'
    end
  end
  inherited ActionList1: TActionList
    Left = 176
    Top = 224
  end
  inherited Messages: TAntStringList
    Left = 208
    Top = 224
  end
end
