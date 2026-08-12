object ImportFrame: TImportFrame
  Left = 0
  Top = 0
  Width = 550
  Height = 360
  ParentShowHint = False
  ShowHint = False
  TabOrder = 0
  Visible = False
  object grpSettings: TGroupBox
    Left = 0
    Top = 21
    Width = 550
    Height = 78
    Align = alTop
    Caption = 'Settings'
    TabOrder = 1
    DesignSize = (
      550
      78)
    object lblPictures: TLabel
      Left = 349
      Top = 9
      Width = 133
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Pictures importation method:'
    end
    object LMovie: TLabel
      Left = 349
      Top = 30
      Width = 32
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Movie:'
    end
    object LExtras: TLabel
      Left = 349
      Top = 54
      Width = 32
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Extras:'
    end
    object chkAllowDup: TCheckBox
      Left = 8
      Top = 16
      Width = 334
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Allow duplicate numbers'
      TabOrder = 0
    end
    object chkAutoAssign: TCheckBox
      Left = 8
      Top = 56
      Width = 334
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Try to assign fields to columns automatically'
      TabOrder = 2
    end
    object cmbPictures: TComboBox
      Left = 407
      Top = 27
      Width = 135
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = '1 - Store into catalog'
      Items.Strings = (
        '1 - Store into catalog'
        '2 - Copy to catalog folder and make relative link'
        '3 - Copy to catalog folder only if it was not stored'
        '4 - Copy to pictures folder and make relative link'
        '5 - Copy to pictures folder only if it was not stored'
        '6 - Make absolute links to current pictures'
        '7 - Make relative links to current pictures')
    end
    object chkAllowClear: TCheckBox
      Left = 8
      Top = 36
      Width = 334
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Allow to clear fields when new value is empty'
      TabOrder = 1
    end
    object cmbExtraPictures: TComboBox
      Left = 407
      Top = 51
      Width = 135
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '1 - Store into catalog'
      Items.Strings = (
        '1 - Store into catalog'
        '2 - Copy to catalog folder and make relative link'
        '3 - Copy to catalog folder only if it was not stored'
        '4 - Copy to pictures folder and make relative link'
        '5 - Copy to pictures folder only if it was not stored'
        '6 - Make absolute links to current pictures'
        '7 - Make relative links to current pictures')
    end
  end
  object grpPreview: TGroupBox
    Left = 0
    Top = 143
    Width = 550
    Height = 217
    Align = alClient
    Caption = 'Preview'
    TabOrder = 3
    DesignSize = (
      550
      217)
    object lblPreview: TLabel
      Left = 8
      Top = 16
      Width = 226
      Height = 13
      Caption = 'Click on column headers to assign fields to them'
    end
    object listPreview: TElTree
      Left = 5
      Top = 33
      Width = 540
      Height = 179
      Cursor = crDefault
      LeftPosition = 0
      ActiveBorderType = fbtEtched
      AlwaysKeepSelection = False
      AutoResizeColumns = False
      Anchors = [akLeft, akTop, akRight, akBottom]
      DockOrientation = doNoOrient
      ChangeDelay = 100
      DoInplaceEdit = False
      DragCursor = crDrag
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      HeaderHeight = 19
      HeaderHotTrack = False
      HeaderInvertSortArrows = True
      HeaderSections.Data = {F6FFFFFF00000000}
      HeaderFlat = True
      HorzScrollBarStyles.Width = 17
      HorzScrollBarStyles.ButtonSize = 17
      InactiveBorderType = fbtEtched
      IncrementalSearch = False
      LineHeight = 17
      OwnerDrawMask = '~~@~~'
      PopupMenu = MenuPopupList
      RightClickSelect = False
      RowHotTrack = True
      ScrollbarOpposite = False
      ScrollTracking = True
      ShowButtons = False
      ShowCheckboxes = True
      ShowImages = False
      ShowRootButtons = True
      SortType = stCustom
      TabOrder = 0
      TabStop = True
      TrackColor = clNone
      UnderlineTracked = False
      UseCustomScrollBars = False
      VertScrollBarStyles.ShowTrackHint = True
      VertScrollBarStyles.Width = 17
      VertScrollBarStyles.ButtonSize = 17
      OnHeaderColumnClick = listPreviewHeaderColumnClick
      OnShowLineHint = listPreviewShowLineHint
      OnCompareItems = listPreviewCompareItems
      OnHotTrack = listPreviewHotTrack
      OnMouseMove = listPreviewMouseMove
      OnKeyUp = listPreviewKeyUp
    end
    object btnFieldsLoad: TTBXButton
      Left = 449
      Top = 11
      Width = 23
      Height = 21
      Hint = 'Load fields|Load field-column links that was previously saved'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ld'
      TabOrder = 1
      OnClick = btnFieldsLoadClick
    end
    object btnFieldsSave: TTBXButton
      Left = 473
      Top = 11
      Width = 23
      Height = 21
      Hint = 'Save fields|Save current field-column links'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'sav'
      TabOrder = 2
      OnClick = btnFieldsSaveClick
    end
    object btnFieldsAutoLoad: TTBXButton
      Left = 497
      Top = 11
      Width = 23
      Height = 21
      Hint = 
        'Reload fields automatically|Reload automatically field-column li' +
        'nks that was previously saved'
      GroupIndex = 1
      AllowAllUnchecked = True
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ald'
      TabOrder = 3
      OnClick = btnFieldsAutoLoadClick
    end
    object btnColumnsAutoResize: TTBXButton
      Left = 521
      Top = 11
      Width = 23
      Height = 21
      Hint = 'Resize columns automatically|Resize columns automatically'
      GroupIndex = 2
      AllowAllUnchecked = True
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'ars'
      TabOrder = 4
      OnClick = btnColumnsAutoResizeClick
    end
  end
  object grpSourceFile: TGroupBox
    Left = 0
    Top = 99
    Width = 550
    Height = 44
    Align = alTop
    Caption = 'Source file'
    TabOrder = 2
    DesignSize = (
      550
      44)
    object btnReload: TTBXButton
      Left = 405
      Top = 16
      Width = 137
      Height = 21
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '&Reload file'
      TabOrder = 2
      OnClick = btnReloadClick
    end
    object btnBrowse: TTBXButton
      Left = 373
      Top = 16
      Width = 29
      Height = 21
      Hint = 'Browse...|Browse for a file to import'
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = '...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
    object edtSourceFile: TEdit
      Left = 8
      Top = 16
      Width = 362
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
      OnKeyDown = edtSourceFileKeyDown
    end
  end
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 550
    Height = 21
    Align = alTop
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 0
    object lblLink: TAntJvLinkLabel
      Left = 4
      Top = 4
      Width = 542
      Height = 13
      Caption = 'This allows to import movies from %s'
      Text.Strings = (
        'This allows to import movies from %s')
      Transparent = False
      LinkColor = clBlue
      LinkColorClicked = clRed
      LinkColorHot = clPurple
      LinkStyle = [fsUnderline]
      HotLinks = False
      AutoHeight = False
      MarginWidth = 0
      MarginHeight = 0
      OnLinkClick = lblLinkLinkClick
      Align = alClient
    end
  end
  object ActionList1: TActionList
    Left = 72
    Top = 192
    object ActionListCheck: TAction
      Category = 'ListView'
      Caption = '&Check selected'
      Hint = 'Check selected|Check selected items'
      OnExecute = ActionListCheckExecute
    end
    object ActionListUncheck: TAction
      Category = 'ListView'
      Caption = '&Uncheck selected'
      Hint = 'Uncheck selected|Uncheck selected items'
      OnExecute = ActionListCheckExecute
    end
    object ActionListAll: TAction
      Category = 'ListView'
      Caption = 'Check &all'
      Hint = 'Check all|Check all items'
      OnExecute = ActionListCheckExecute
    end
    object ActionListNone: TAction
      Category = 'ListView'
      Caption = 'Check &none'
      Hint = 'Uncheck all|Uncheck all items'
      OnExecute = ActionListCheckExecute
    end
    object ActionHeaderNoImport: TAction
      Caption = 'Do not import this field'
      OnExecute = ActionHeaderClick
    end
    object ActionDefineKeyField: TAction
      Caption = 'Define as key field'
      Hint = '|Use this key field to compare movies'
      OnExecute = ActionDefineKeyFieldExecute
    end
    object ActionListCheckExists: TAction
      Category = 'ListView'
      Caption = 'Check existing movies'
      Hint = 'Check existing movies|Check existing movies in current catalog'
      OnExecute = ActionListCheckExistsExecute
    end
    object ActionListUncheckExists: TAction
      Category = 'ListView'
      Caption = 'Uncheck existing movies'
      Hint = 
        'Uncheck existing movies|Uncheck existing movies in current catal' +
        'og'
      OnExecute = ActionListCheckExistsExecute
    end
    object ActionSortAscend: TAction
      Caption = 'Sort ascending'
      Hint = 'Sort ascending|Sort the column values into ascending order'
      OnExecute = ActionSortExecute
    end
    object ActionSortDescend: TAction
      Caption = 'Sort descending'
      Hint = 'Sort descending|Sort the column values into descending order'
      OnExecute = ActionSortExecute
    end
  end
  object MenuPopupList: TTBXPopupMenu
    Left = 80
    Top = 232
    object MnuLspChk: TTBXItem
      Action = ActionListCheck
    end
    object MnuLspUnc: TTBXItem
      Action = ActionListUncheck
    end
    object MnuLsp__1: TTBXSeparatorItem
    end
    object MnuLstChkExits: TTBXItem
      Action = ActionListCheckExists
    end
    object MnuLstUncExits: TTBXItem
      Action = ActionListUncheckExists
    end
    object MnuLsp__2: TTBXSeparatorItem
    end
    object MnuLspAll: TTBXItem
      Action = ActionListAll
    end
    object MnuLspNon: TTBXItem
      Action = ActionListNone
    end
  end
  object MenuPopupHeader: TTBXPopupMenu
    Left = 120
    Top = 232
    object MnuHdpNot: TTBXItem
      Tag = -1
      Action = ActionHeaderNoImport
      GroupIndex = 1
    end
    object MnuMov: TTBXSubmenuItem
      Caption = 'Movie Fields'
    end
    object MnuMovCF: TTBXSubmenuItem
      Caption = 'Custom Fields'
    end
    object MnuMovExtras: TTBXSubmenuItem
      Caption = 'Extra Fields'
    end
    object MnuDefKeyField: TTBXItem
      Action = ActionDefineKeyField
    end
    object MnuHdr__1: TTBXSeparatorItem
    end
    object MnuSortAscend: TTBXItem
      Action = ActionSortAscend
    end
    object MnuSortDescend: TTBXItem
      Action = ActionSortDescend
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'No movie to import'
      
        'You did not assign a field to any column. Click on column header' +
        's for this.'
      
        'For this picture importation method, the catalog must have a nam' +
        'e; please save it somewhere and try again'
      'Select a folder:'
      '%s movie(s) found!'
      '%s movie(s) added!'
      '%s movie(s) updated!'
      
        'The values of key field are not unique in current catalog.|A mov' +
        'ie in the list could match with several movies in current catalo' +
        'g.'
      
        'To do this action, you must first select a key field to compare ' +
        'movies (click on a column header of the list).'
      'Importing movies into current catalog...')
    Left = 112
    Top = 192
  end
end
