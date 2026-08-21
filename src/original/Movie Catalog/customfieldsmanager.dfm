inherited CustomFieldsManagerWin: TCustomFieldsManagerWin
  Left = 226
  Top = 106
  HelpContext = 1051
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Custom fields manager'
  ClientHeight = 462
  ClientWidth = 634
  Constraints.MinHeight = 500
  Constraints.MinWidth = 650
  OldCreateOrder = True
  OnResize = FormResize
  DesignSize = (
    634
    462)
  PixelsPerInch = 96
  TextHeight = 13
  object LTemplate: TLabel [0]
    Left = 8
    Top = 112
    Width = 47
    Height = 13
    Caption = 'Template:'
    Enabled = False
    FocusControl = ETemplate
    Visible = False
  end
  inherited Bevel1: TBevel
    Top = 429
    Width = 628
  end
  object LName: TLabel [2]
    Left = 8
    Top = 62
    Width = 31
    Height = 13
    Caption = 'Name:'
    Enabled = False
    FocusControl = EName
  end
  object LListValues: TLabel [3]
    Left = 8
    Top = 187
    Width = 53
    Height = 13
    Caption = 'List values:'
    Enabled = False
    FocusControl = EListValues
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 446
    Width = 634
  end
  object LField: TLabel [5]
    Left = 8
    Top = 8
    Width = 25
    Height = 13
    Caption = 'Field:'
    FocusControl = EField
  end
  object LType: TLabel [6]
    Left = 7
    Top = 87
    Width = 27
    Height = 13
    Caption = 'Type:'
    Enabled = False
    FocusControl = EType
  end
  object Bevel2: TBevel [7]
    Left = 3
    Top = 28
    Width = 628
    Height = 2
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object LDefaultValue: TLabel [8]
    Left = 8
    Top = 112
    Width = 66
    Height = 13
    Caption = 'Default value:'
    Enabled = False
    FocusControl = EDefaultValue
  end
  object LMultiValues: TLabel [9]
    Left = 8
    Top = 162
    Width = 73
    Height = 13
    Caption = 'Multiple values:'
    Enabled = False
    FocusControl = EMultiValues
  end
  object LTag: TLabel [10]
    Left = 8
    Top = 37
    Width = 22
    Height = 13
    Caption = 'Tag:'
    FocusControl = EField
  end
  object LExt: TLabel [11]
    Left = 450
    Top = 62
    Width = 49
    Height = 13
    Anchors = [akTop, akRight]
    Caption = 'Extension:'
    Enabled = False
    FocusControl = EExt
  end
  object LMediaInfo: TLabel [12]
    Left = 7
    Top = 137
    Width = 83
    Height = 13
    Caption = 'Import media info:'
    Enabled = False
    FocusControl = EMediaInfo
  end
  object LMultiValuesSep: TLabel [13]
    Left = 184
    Top = 162
    Width = 112
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Separator:'
    Enabled = False
    FocusControl = EMultiValuesSep
  end
  object LMultiValuesRmP: TLabel [14]
    Left = 352
    Top = 162
    Width = 146
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Del. Parentheses:'
    Enabled = False
    FocusControl = EMultiValuesRmP
  end
  object LMultiValuesPatch: TLabel [15]
    Left = 529
    Top = 162
    Width = 81
    Height = 13
    Alignment = taRightJustify
    AutoSize = False
    Caption = 'Patch:'
    Enabled = False
    FocusControl = EMultiValuesPatch
  end
  object btnInsertFieldTag: TTBXButton [16]
    Left = 615
    Top = 108
    Width = 17
    Height = 21
    Hint = '|Insert a special value that will be replaced by movie value'
    Anchors = [akTop, akRight]
    AutoSize = False
    BorderSize = 5
    Caption = ' '
    DropDownMenu = PopupFields
    TabOrder = 9
    Visible = False
  end
  object ETemplate: TEdit [17]
    Left = 165
    Top = 108
    Width = 448
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 8
    Visible = False
    OnChange = ETemplateChange
  end
  inherited btn1: TCorelButton
    Left = 556
    Top = 434
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 21
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 478
    Top = 434
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 20
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 400
    Top = 434
    TabOrder = 26
  end
  inherited btn4: TCorelButton
    Left = 322
    Top = 434
    TabOrder = 25
  end
  object EName: TEdit
    Left = 165
    Top = 58
    Width = 275
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    TabOrder = 4
    OnChange = ENameChange
  end
  object EListValues: TMemo
    Left = 165
    Top = 183
    Width = 467
    Height = 187
    Anchors = [akLeft, akTop, akRight, akBottom]
    Enabled = False
    ScrollBars = ssVertical
    TabOrder = 15
    OnChange = EListValuesChange
  end
  object EField: TComboBox
    Left = 165
    Top = 4
    Width = 355
    Height = 21
    AutoComplete = False
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 0
    OnChange = EFieldChange
  end
  object EType: TComboBox
    Left = 165
    Top = 83
    Width = 467
    Height = 21
    AutoComplete = False
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    ItemHeight = 13
    TabOrder = 6
    OnChange = ETypeChange
    Items.Strings = (
      '')
  end
  object EMultiValues: TCheckBox
    Left = 165
    Top = 160
    Width = 15
    Height = 17
    Hint = '|Make groups with multiple field values'
    Enabled = False
    TabOrder = 11
    OnClick = EMultiValuesClick
  end
  object ETag: TEdit
    Left = 165
    Top = 33
    Width = 442
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 2
    OnChange = ETagChange
  end
  object EExt: TEdit
    Left = 516
    Top = 58
    Width = 116
    Height = 21
    Anchors = [akTop, akRight]
    Enabled = False
    TabOrder = 5
    OnChange = EExtChange
  end
  object EMediaInfo: TComboBox
    Left = 165
    Top = 133
    Width = 467
    Height = 21
    AutoComplete = False
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    ItemHeight = 13
    TabOrder = 10
    OnChange = EMediaInfoChange
    Items.Strings = (
      '')
  end
  object EMultiValuesSep: TComboBox
    Left = 302
    Top = 158
    Width = 40
    Height = 21
    AutoComplete = False
    Enabled = False
    ItemHeight = 13
    MaxLength = 1
    TabOrder = 12
    OnChange = EMultiValuesSepChange
    Items.Strings = (
      ','
      ';'
      '|'
      '/'
      '\')
  end
  object EMultiValuesRmP: TCheckBox
    Left = 504
    Top = 160
    Width = 15
    Height = 17
    Hint = '|Delete values between parentheses'
    Enabled = False
    TabOrder = 13
    OnClick = EMultiValuesRmPClick
  end
  object EMultiValuesPatch: TCheckBox
    Left = 616
    Top = 160
    Width = 15
    Height = 17
    Hint = '|Apply path to ignore some parentheses'
    Enabled = False
    TabOrder = 14
    OnClick = EMultiValuesPatchClick
  end
  object btnImport: TTBXButton
    Left = 585
    Top = 3
    Width = 23
    Height = 22
    Hint = 'Import fields|Import custom fields'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'im'
    TabOrder = 23
    OnClick = btnImportClick
  end
  object btnExport: TTBXButton
    Left = 609
    Top = 3
    Width = 23
    Height = 22
    Hint = 'Export fields|Export custom fields'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'ex'
    TabOrder = 24
    OnClick = btnExportClick
  end
  object btnClearAll: TTBXButton
    Left = 561
    Top = 3
    Width = 23
    Height = 22
    Hint = 'Clear all fields|Clear all custom fields'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'cl'
    TabOrder = 22
    OnClick = btnClearAllClick
  end
  object btnApply: TTBXButton
    Left = 609
    Top = 32
    Width = 23
    Height = 22
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'ap'
    Enabled = False
    TabOrder = 3
    OnClick = btnApplyClick
  end
  object btnDel: TTBXButton
    Left = 522
    Top = 3
    Width = 23
    Height = 22
    Hint = 'Delete field|Delete custom field'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = 'del'
    Enabled = False
    TabOrder = 1
    OnClick = btnDelClick
  end
  object EListCatalogValues: TCheckBox
    Left = 165
    Top = 391
    Width = 482
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Use values of current catalog instead of predefined list'
    Enabled = False
    TabOrder = 18
    OnClick = EListCatalogValuesClick
  end
  object EListSort: TCheckBox
    Left = 165
    Top = 373
    Width = 191
    Height = 17
    Anchors = [akLeft, akBottom]
    Caption = 'Auto-sort items'
    Enabled = False
    TabOrder = 16
    OnClick = EListSortClick
  end
  object EListAutoAdd: TCheckBox
    Left = 165
    Top = 409
    Width = 482
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Automatically add values that are not in list'
    Enabled = False
    TabOrder = 19
    OnClick = EListAutoAddClick
  end
  object EListAutoComplete: TCheckBox
    Left = 361
    Top = 373
    Width = 306
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Auto-complete while typing'
    Enabled = False
    TabOrder = 17
    OnClick = EListAutoCompleteClick
  end
  object EDefaultValue: TComboBox
    Left = 165
    Top = 108
    Width = 467
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    Enabled = False
    ItemHeight = 13
    TabOrder = 7
    OnChange = EDefaultValueChange
    Items.Strings = (
      '')
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Import custom fields'
      'Export custom fields'
      'Add field|Add custom field'
      'Change tag|Change custom field tag'
      '--- New Field ---'
      'String'
      'Integer'
      'Real (1 decimal)'
      'Real (2 decimals)'
      'Real (3 decimals)'
      'Boolean'
      'List'
      'Date'
      'Text'
      'URL'
      'Virtual')
    Left = 24
    Top = 246
  end
  object PopupFields: TTBXPopupMenu
    OnPopup = PopupFieldsPopup
    Left = 312
    Top = 240
  end
end
