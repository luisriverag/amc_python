object FileNamingFrame: TFileNamingFrame
  Left = 0
  Top = 0
  Width = 422
  Height = 97
  TabOrder = 0
  DesignSize = (
    422
    97)
  object grp: TGroupBox
    Left = 0
    Top = 0
    Width = 422
    Height = 97
    Anchors = [akLeft, akTop, akRight]
    Caption = 'File naming'
    TabOrder = 0
    object LExtraInfo: TLabel
      Left = 312
      Top = 18
      Width = 78
      Height = 13
      Caption = 'Extra information'
    end
    object LPrefix: TLabel
      Left = 8
      Top = 17
      Width = 26
      Height = 13
      Caption = 'Prefix'
    end
    object LPlus4: TLabel
      Left = 302
      Top = 35
      Width = 6
      Height = 13
      Caption = '+'
    end
    object LPlus3: TLabel
      Left = 264
      Top = 35
      Width = 6
      Height = 13
      Caption = '+'
    end
    object LPlus2: TLabel
      Left = 150
      Top = 35
      Width = 6
      Height = 13
      Caption = '+'
    end
    object LPlus1: TLabel
      Left = 112
      Top = 35
      Width = 6
      Height = 13
      Caption = '+'
    end
    object LMovieInfo: TLabel
      Left = 160
      Top = 18
      Width = 83
      Height = 13
      Caption = 'Movie information'
    end
    object ESep2: TEdit
      Left = 274
      Top = 32
      Width = 24
      Height = 21
      AutoSize = False
      TabOrder = 3
    end
    object ESep1: TEdit
      Left = 122
      Top = 32
      Width = 24
      Height = 21
      AutoSize = False
      TabOrder = 1
    end
    object EPrefix: TComboBox
      Left = 8
      Top = 32
      Width = 100
      Height = 21
      AutoComplete = False
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 0
      Text = 'None'
      OnClick = EPrefixClick
      Items.Strings = (
        'None'
        'Catalog name'
        'Exported filename')
    end
    object EMovieInfo: TComboBox
      Left = 160
      Top = 32
      Width = 100
      Height = 21
      AutoComplete = False
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      TabOrder = 2
      OnClick = EMovieInfoClick
      Items.Strings = (
        'None'
        'Original filename')
    end
    object EExtraInfo: TComboBox
      Left = 312
      Top = 32
      Width = 100
      Height = 21
      AutoComplete = False
      Style = csDropDownList
      DropDownCount = 16
      ItemHeight = 13
      TabOrder = 4
      OnClick = EExtraInfoClick
      Items.Strings = (
        'None')
    end
    object CBMovieNumberAddZeroes: TCheckBox
      Left = 8
      Top = 57
      Width = 404
      Height = 17
      Caption = 'Add zeroes in front of the movie number for low numbers'
      TabOrder = 5
    end
    object CBExtraNumberAddZeroes: TCheckBox
      Left = 8
      Top = 75
      Width = 404
      Height = 17
      Caption = 'Add zeroes in front of the extra number for low numbers'
      TabOrder = 6
    end
  end
end
