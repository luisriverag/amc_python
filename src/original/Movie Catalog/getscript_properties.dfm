inherited ScriptPropertiesWin: TScriptPropertiesWin
  Left = 642
  Top = 193
  HelpContext = 1073
  Caption = 'Script properties, options and parameters'
  ClientHeight = 462
  ClientWidth = 584
  Constraints.MinHeight = 500
  Constraints.MinWidth = 600
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    584
    462)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 429
    Width = 578
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 446
    Width = 584
  end
  object lstProperties: TValueListEditor [2]
    Left = 3
    Top = 3
    Width = 578
    Height = 176
    Anchors = [akLeft, akTop, akRight]
    Options = [goVertLine, goHorzLine, goColSizing, goEditing, goAlwaysShowEditor, goThumbTracking]
    Strings.Strings = (
      'Authors='
      'Title='
      'Description='
      'Site='
      'Language='
      'Version='
      'Requires='
      'Comments='
      'License='
      'GetInfo='
      'IterateOnMovies=')
    TabOrder = 0
    TitleCaptions.Strings = (
      'Property'
      'Value')
    OnEditButtonClick = lstPropertiesEditButtonClick
    ColWidths = (
      128
      427)
  end
  inherited btn1: TCorelButton
    Left = 506
    Top = 434
    Caption = '&Help'
    TabOrder = 7
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 428
    Top = 434
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 6
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 350
    Top = 434
    Caption = '&Save'
    ModalResult = 1
    TabOrder = 5
    Visible = True
  end
  inherited btn4: TCorelButton
    Left = 272
    Top = 434
    TabOrder = 4
  end
  object grpOptions: TGroupBox
    Left = 3
    Top = 182
    Width = 174
    Height = 131
    Caption = 'Options'
    TabOrder = 1
    DesignSize = (
      174
      131)
    object lstOptions: TListBox
      Left = 4
      Top = 37
      Width = 166
      Height = 90
      Anchors = [akLeft, akTop, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 2
      OnClick = lstOptionsClick
      OnDblClick = lstOptionsDblClick
    end
    object btnOptionAdd: TTBXButton
      Left = 75
      Top = 11
      Width = 23
      Height = 22
      Hint = 'Add|Add a new option'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ad'
      TabOrder = 0
      OnClick = btnOptionAddClick
    end
    object btnOptionDel: TTBXButton
      Left = 99
      Top = 11
      Width = 23
      Height = 22
      Hint = 'Delete|Delete selected option'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'del'
      TabOrder = 1
      OnClick = btnOptionDelClick
    end
    object btnOptionDown: TTBXButton
      Left = 147
      Top = 11
      Width = 23
      Height = 22
      Hint = 'Move down|Move down selected option'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'dn'
      TabOrder = 3
      OnClick = btnOptionDownClick
    end
    object btnOptionUp: TTBXButton
      Left = 123
      Top = 11
      Width = 23
      Height = 22
      Hint = 'Move up|Move up selected option'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'up'
      TabOrder = 4
      OnClick = btnOptionUpClick
    end
  end
  object grpValues: TGroupBox
    Left = 180
    Top = 182
    Width = 401
    Height = 131
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Available values for the selected option'
    TabOrder = 2
    DesignSize = (
      401
      131)
    object lblValueDefault: TLabel
      Left = 267
      Top = 16
      Width = 37
      Height = 13
      Alignment = taRightJustify
      Anchors = [akTop, akRight]
      Caption = 'Default:'
    end
    object lstValues: TStringGrid
      Left = 4
      Top = 37
      Width = 367
      Height = 90
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 2
      DefaultColWidth = 40
      DefaultRowHeight = 18
      FixedCols = 0
      RowCount = 2
      Options = [goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking]
      ScrollBars = ssVertical
      TabOrder = 1
      OnSetEditText = lstValuesSetEditText
      ColWidths = (
        40
        223)
    end
    object cbxValueDefault: TComboBox
      Left = 315
      Top = 12
      Width = 56
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbxValueDefaultChange
    end
    object btnValueAdd: TTBXButton
      Left = 374
      Top = 37
      Width = 23
      Height = 22
      Hint = 'Add|Add a new value'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ad'
      TabOrder = 2
      OnClick = btnValueAddClick
    end
    object btnValueDel: TTBXButton
      Left = 374
      Top = 60
      Width = 23
      Height = 22
      Hint = 'Delete|Delete selected value'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'del'
      TabOrder = 3
      OnClick = btnValueDelClick
    end
    object btnValueUp: TTBXButton
      Left = 374
      Top = 83
      Width = 23
      Height = 22
      Hint = 'Move up|Move up selected value'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'up'
      TabOrder = 4
      OnClick = btnValueUpClick
    end
    object btnValueDown: TTBXButton
      Left = 374
      Top = 106
      Width = 23
      Height = 22
      Hint = 'Move down|Move down selected value'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'dn'
      TabOrder = 5
      OnClick = btnValueDownClick
    end
  end
  object grpParameters: TGroupBox
    Left = 3
    Top = 316
    Width = 578
    Height = 110
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Parameters'
    TabOrder = 3
    DesignSize = (
      578
      110)
    object lstParameters: TStringGrid
      Left = 4
      Top = 16
      Width = 544
      Height = 90
      Anchors = [akLeft, akTop, akRight, akBottom]
      ColCount = 3
      DefaultColWidth = 40
      DefaultRowHeight = 18
      FixedCols = 0
      RowCount = 2
      Options = [goVertLine, goHorzLine, goRangeSelect, goEditing, goAlwaysShowEditor, goThumbTracking]
      ScrollBars = ssVertical
      TabOrder = 0
      OnSetEditText = lstParametersSetEditText
      ColWidths = (
        108
        108
        223)
    end
    object btnParameterAdd: TTBXButton
      Left = 551
      Top = 16
      Width = 23
      Height = 22
      Hint = 'Add|Add a new parameter'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ad'
      TabOrder = 1
      OnClick = btnParameterAddClick
    end
    object btnParameterDel: TTBXButton
      Left = 551
      Top = 39
      Width = 23
      Height = 22
      Hint = 'Delete|Delete selected parameter'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'del'
      TabOrder = 2
      OnClick = btnParameterDelClick
    end
    object btnParameterUp: TTBXButton
      Left = 551
      Top = 62
      Width = 23
      Height = 22
      Hint = 'Move up|Move up selected parameter'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'up'
      TabOrder = 3
      OnClick = btnParameterUpClick
    end
    object btnParameterDown: TTBXButton
      Left = 551
      Top = 85
      Width = 23
      Height = 22
      Hint = 'Move down|Move down selected parameter'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'dn'
      TabOrder = 4
      OnClick = btnParameterDownClick
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Script authors:'
      'Script title:'
      'Description:'
      'Site address:'
      'Site language:'
      'Script version:'
      'Requires at least:'
      'Comments:'
      'Script license:'
      'Get info from web:'
      'Requires movies:'
      'Value'
      'Description'
      'This will delete the option "%s"'
      'Option name:'
      'Rename the option "%s"'
      'An option with the name "%s" already exist!'
      'Name'
      'Default value'
      'Description')
    Left = 80
    Top = 56
  end
end
