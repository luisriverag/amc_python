inherited OptionsWin: TOptionsWin
  Left = 368
  Top = 165
  HelpContext = 1060
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Preferences'
  ClientHeight = 512
  ClientWidth = 634
  Constraints.MinHeight = 550
  Constraints.MinWidth = 650
  OldCreateOrder = True
  OnDestroy = FormDestroy
  DesignSize = (
    634
    512)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 479
    Width = 628
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 496
    Width = 634
  end
  inherited btn1: TCorelButton
    Left = 556
    Top = 484
    Caption = '&Help'
    TabOrder = 4
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 478
    Top = 484
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 400
    Top = 484
    Caption = '&Save'
    TabOrder = 2
    Visible = True
    OnClick = btn3Click
  end
  inherited btn4: TCorelButton
    Left = 322
    Top = 484
    TabOrder = 5
  end
  object LvCat: TTreeView
    Left = 0
    Top = 0
    Width = 172
    Height = 474
    Anchors = [akLeft, akTop, akBottom]
    HideSelection = False
    Indent = 19
    ReadOnly = True
    ShowButtons = False
    TabOrder = 0
    OnChange = LvCatChange
    Items.Data = {
      08000000280000000000000000000000FFFFFFFFFFFFFFFF0000000001000000
      0F47656E6572616C20646973706C61792A0000000000000000000000FFFFFFFF
      FFFFFFFF000000000000000011437573746F6D697A6520746F6F6C6261721E00
      00000000000000000000FFFFFFFFFFFFFFFF00000000000000000546696C6573
      230000000000000000000000FFFFFFFFFFFFFFFF00000000020000000A4D6F76
      6965206C697374290000000000000000000000FFFFFFFFFFFFFFFF0000000000
      000000105469746C6520666F726D617474696E67210000000000000000000000
      FFFFFFFFFFFFFFFF00000000000000000847726F7570696E6723000000000000
      0000000000FFFFFFFFFFFFFFFF00000000000000000A4578747261206C697374
      320000000000000000000000FFFFFFFFFFFFFFFF0000000004000000194D6F76
      6965202F20457874726120696E666F726D6174696F6E28000000000000000000
      0000FFFFFFFFFFFFFFFF00000000000000000F44726F702D646F776E206C6973
      7473300000000000000000000000FFFFFFFFFFFFFFFF0000000000000000174D
      656469612066696C657320696D706F72746174696F6E2C000000000000000000
      0000FFFFFFFFFFFFFFFF0000000000000000135069637475726520696D706F72
      746174696F6E2B0000000000000000000000FFFFFFFFFFFFFFFF000000000000
      000012536561726368206F6E20696E7465726E65742200000000000000000000
      00FFFFFFFFFFFFFFFF000000000000000009536372697074696E671F00000000
      00000000000000FFFFFFFFFFFFFFFF0000000000000000064578706F72742000
      00000000000000000000FFFFFFFFFFFFFFFF000000000000000007466F6C6465
      7273}
  end
  object PageControl1: TPageControl
    Left = 173
    Top = 0
    Width = 464
    Height = 478
    ActivePage = TabSheetDisplay
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    MultiLine = True
    Style = tsButtons
    TabOrder = 1
    TabStop = False
    object TabSheetDisplay: TTabSheet
      Caption = 'Display'
      ImageIndex = 1
      DesignSize = (
        456
        423)
      object Bevel5: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHToolbar: TLabel
        Left = 0
        Top = 0
        Width = 97
        Height = 13
        Caption = 'Toolbars and Menus'
        Enabled = False
        Transparent = False
      end
      object Bevel6: TBevel
        Left = 8
        Top = 280
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHStartup: TLabel
        Left = 0
        Top = 280
        Width = 34
        Height = 13
        Caption = 'Startup'
        Enabled = False
        Transparent = False
      end
      object Bevel16: TBevel
        Left = 8
        Top = 128
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHMainWindow: TLabel
        Left = 0
        Top = 128
        Width = 72
        Height = 13
        Caption = 'General display'
        Enabled = False
        Transparent = False
      end
      object LIconSet: TLabel
        Left = 8
        Top = 24
        Width = 41
        Height = 13
        Caption = 'Icon set:'
        FocusControl = cbxIconSet
      end
      object LColorType: TLabel
        Left = 8
        Top = 48
        Width = 50
        Height = 13
        Caption = 'Color type:'
        FocusControl = cbxColorType
      end
      object CBMenuImages: TCheckBox
        Left = 8
        Top = 96
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Images in menus'
        TabOrder = 3
      end
      object CBLogo: TCheckBox
        Left = 8
        Top = 304
        Width = 442
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Display logo'
        TabOrder = 5
      end
      object CBSoftBorders: TCheckBox
        Left = 8
        Top = 152
        Width = 442
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Soft borders for Movie List, Movie Information Panel and Picture' +
          ' Box'
        TabOrder = 4
      end
      object cbxIconSet: TComboBox
        Left = 144
        Top = 21
        Width = 303
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 0
        Items.Strings = (
          'Classic')
      end
      object cbxColorType: TComboBox
        Left = 144
        Top = 45
        Width = 303
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 1
        Items.Strings = (
          'Automatic'
          'Greyed when inactive'
          'Blended light when inactive'
          'Blended dark when inactive'
          'Always colored')
      end
      object CBOfficeXP: TCheckBox
        Left = 8
        Top = 72
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Office XP style'
        TabOrder = 2
      end
      object CBNatCmp: TCheckBox
        Left = 8
        Top = 176
        Width = 442
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Use natural comparison (detect numbers automatically) to sort st' +
          'rings'
        TabOrder = 6
      end
      object CBAutoFocus: TCheckBox
        Left = 8
        Top = 224
        Width = 442
        Height = 17
        Hint = '|Give focus to component when the mouse pointer moves over it'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Activate autofocus on movie list, extra list and html viewer'
        TabOrder = 7
      end
      object CBForceRefresh: TCheckBox
        Left = 8
        Top = 248
        Width = 442
        Height = 17
        Hint = 
          '|By default, press Enter or Escape in the field to refresh movie' +
          ' list'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Force refresh of movie list each time a field value change'
        TabOrder = 8
      end
      object CBScrollUnderPointer: TCheckBox
        Left = 8
        Top = 200
        Width = 442
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Activate scrolling of item under pointer instead of selected ite' +
          'm'
        TabOrder = 9
      end
    end
    object TabSheetToolbar: TTabSheet
      Caption = 'Toolbar'
      ImageIndex = 11
      DesignSize = (
        456
        423)
      object Bevel21: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHCustomizeToolbar: TLabel
        Left = 0
        Top = 0
        Width = 224
        Height = 13
        Caption = 'Select icons that should appear on main toolbar'
        Enabled = False
        FocusControl = LvCustomizeToolbar
        Transparent = False
      end
      object LvCustomizeToolbar: TListView
        Left = 8
        Top = 21
        Width = 439
        Height = 402
        Anchors = [akLeft, akTop, akRight, akBottom]
        Checkboxes = True
        Columns = <
          item
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        ShowColumnHeaders = False
        TabOrder = 0
        ViewStyle = vsReport
      end
    end
    object TabSheetFiles: TTabSheet
      Caption = 'Files'
      ImageIndex = 4
      DesignSize = (
        456
        423)
      object Bevel19: TBevel
        Left = 8
        Top = 257
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel7: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHSaving: TLabel
        Left = 0
        Top = 0
        Width = 41
        Height = 13
        Caption = 'Catalogs'
        Enabled = False
        Transparent = False
      end
      object LRepairAssociations: TLabel
        Left = 8
        Top = 152
        Width = 348
        Height = 13
        Caption = 
          'To associate .amc files with Ant Movie Catalog, click on the but' +
          'ton below:'
      end
      object LRecentFiles: TLabel
        Left = 8
        Top = 128
        Width = 212
        Height = 13
        Caption = 'Number of recent files to display in File menu:'
        FocusControl = ERecentFiles
      end
      object LHHistory: TLabel
        Left = 0
        Top = 257
        Width = 62
        Height = 13
        Caption = 'Loans history'
        Enabled = False
        Transparent = False
      end
      object Bevel32: TBevel
        Left = 8
        Top = 331
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHHTMLTemplate: TLabel
        Left = 0
        Top = 331
        Width = 77
        Height = 13
        Caption = 'HTML Template'
        Enabled = False
        Transparent = False
      end
      object CBBackup: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Always create a backup copy'
        TabOrder = 0
      end
      object BtnRepairAssoc: TCorelButton
        Left = 8
        Top = 176
        Width = 233
        Height = 22
        Caption = 'Repair files associations'
        TabOrder = 5
        OnClick = BtnRepairAssocClick
      end
      object CBHistory: TCheckBox
        Left = 8
        Top = 281
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Store loans history in the following file (using tab-delimited f' +
          'ormat):'
        TabOrder = 8
        OnClick = CBHistoryClick
      end
      object CBAutoLoad: TCheckBox
        Left = 8
        Top = 48
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'At startup, automatically open following file instead of creatin' +
          'g an empty one:'
        TabOrder = 1
        OnClick = CBAutoLoadClick
      end
      object CBAutoLoadLast: TCheckBox
        Left = 32
        Top = 96
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Re-open last used file'
        TabOrder = 3
        OnClick = CBAutoLoadClick
      end
      object ERecentFiles: TAntJvSpinEdit
        Left = 256
        Top = 125
        Width = 41
        Height = 21
        Alignment = taCenter
        MaxValue = 9.000000000000000000
        TabOrder = 4
      end
      object EAutoLoad: TAntJvComboEditXP
        Left = 32
        Top = 69
        Width = 415
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 2
        OnButtonClick = EAutoLoadButtonClick
      end
      object EHistoryFile: TAntJvComboEditXP
        Left = 32
        Top = 302
        Width = 415
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 9
        OnButtonClick = EHistoryFileButtonClick
      end
      object EHTMLTemplate: TAntJvComboEditXP
        Left = 32
        Top = 355
        Width = 415
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 10
        OnButtonClick = EHTMLTemplateButtonClick
      end
      object EAutoLoadCF: TAntJvComboEditXP
        Left = 32
        Top = 228
        Width = 415
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 7
        OnButtonClick = EAutoLoadCFButtonClick
      end
      object CBAutoloadCF: TCheckBox
        Left = 8
        Top = 207
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Automatically import custom fields from following file for new c' +
          'atalogs:'
        TabOrder = 6
        OnClick = CBAutoLoadCFClick
      end
    end
    object TabSheetMoviesList: TTabSheet
      Caption = 'Movie List'
      DesignSize = (
        456
        423)
      object Bevel3: TBevel
        Left = 8
        Top = 268
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel2: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHDisplay: TLabel
        Left = 0
        Top = 0
        Width = 34
        Height = 13
        Caption = 'Display'
        Enabled = False
        Transparent = False
      end
      object LHOperations: TLabel
        Left = 0
        Top = 268
        Width = 51
        Height = 13
        Caption = 'Operations'
        Enabled = False
        Transparent = False
      end
      object Bevel17: TBevel
        Left = 8
        Top = 345
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHShortcut: TLabel
        Left = 0
        Top = 344
        Width = 45
        Height = 13
        Caption = 'Shortcuts'
        Enabled = False
        Transparent = False
      end
      object LShortcutPrev: TLabel
        Left = 8
        Top = 368
        Width = 75
        Height = 13
        Caption = 'Previous movie:'
        FocusControl = ShortcutPrev
      end
      object LShortcutNext: TLabel
        Left = 8
        Top = 392
        Width = 56
        Height = 13
        Caption = 'Next movie:'
        FocusControl = ShortcutNext
      end
      object LGridTextSize: TLabel
        Left = 8
        Top = 195
        Width = 285
        Height = 13
        Hint = 
          '|The columns FormatedTitle, OriginalTitle and TranslatedTitle ar' +
          'e not affected'
        Caption = 'Number of characteres per column in grid mode (0 = no limit):'
      end
      object CBDelete: TCheckBox
        Left = 8
        Top = 292
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Confirm Delete'
        TabOrder = 10
      end
      object CBUndo: TCheckBox
        Left = 8
        Top = 316
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Confirm Undo'
        TabOrder = 11
      end
      object CBCheckboxes: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Checkboxes (right click to change movie color tag)'
        TabOrder = 0
        OnClick = CBCheckboxesClick
      end
      object CBHotTrack: TCheckBox
        Left = 8
        Top = 120
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Hot track'
        TabOrder = 4
      end
      object ShortcutPrev: THotKey
        Left = 144
        Top = 365
        Width = 303
        Height = 19
        Anchors = [akLeft, akTop, akRight]
        HotKey = 16417
        InvalidKeys = []
        Modifiers = [hkCtrl]
        TabOrder = 12
      end
      object ShortcutNext: THotKey
        Left = 144
        Top = 389
        Width = 303
        Height = 19
        Anchors = [akLeft, akTop, akRight]
        HotKey = 16418
        InvalidKeys = []
        Modifiers = [hkCtrl]
        TabOrder = 13
      end
      object CBEnhScrollbars: TCheckBox
        Left = 8
        Top = 144
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Enhanced scrollbars'
        TabOrder = 5
      end
      object CBMovieNumColumn: TCheckBox
        Left = 8
        Top = 168
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = '"Movie Number" column'
        TabOrder = 6
      end
      object EGridTextSize: TAntJvSpinEdit
        Left = 392
        Top = 191
        Width = 54
        Height = 21
        Alignment = taCenter
        MaxValue = 999.000000000000000000
        TabOrder = 7
      end
      object CBCheckboxesColor: TCheckBox
        Left = 33
        Top = 72
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Checkboxes with background color associated to movie color tag'
        TabOrder = 2
      end
      object CBLinesColor: TCheckBox
        Left = 8
        Top = 96
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Lines with background color associated to movie color tag'
        TabOrder = 3
      end
      object CBAutoStretchListGrid: TCheckBox
        Left = 9
        Top = 219
        Width = 443
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto stretch list in grid mode view'
        TabOrder = 8
      end
      object CBAutoStretchListThumbs: TCheckBox
        Left = 9
        Top = 242
        Width = 443
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto stretch list in thumbnails view'
        TabOrder = 9
      end
      object CBCheckboxesInThumbs: TCheckBox
        Left = 8
        Top = 48
        Width = 445
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Checkboxes in thumbnails display'
        TabOrder = 1
        OnClick = CBCheckboxesInThumbsClick
      end
    end
    object TabSheetTitleFormatting: TTabSheet
      Caption = 'Title'
      ImageIndex = 12
      DesignSize = (
        456
        423)
      object Bevel22: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LTitleColumn: TLabel
        Left = 8
        Top = 24
        Width = 70
        Height = 13
        Caption = 'Title to display:'
        FocusControl = cbxTitle
      end
      object LHFormatting: TLabel
        Left = 0
        Top = 0
        Width = 49
        Height = 13
        Caption = 'Formatting'
        Enabled = False
        Transparent = False
      end
      object LPrefixes2: TLabel
        Left = 184
        Top = 144
        Width = 263
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'Enter them in the list, each one on a separate line, without the' +
          ' trailing space or quote.'
        WordWrap = True
      end
      object LPrefixes1: TLabel
        Left = 184
        Top = 104
        Width = 263
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'Only words followed by a space or a quote in the title will be r' +
          'ecognized.'
        WordWrap = True
      end
      object LTitleTemplate: TLabel
        Left = 8
        Top = 48
        Width = 78
        Height = 13
        Caption = 'Template of title:'
        FocusControl = cbxTitle
      end
      object cbxTitle: TComboBox
        Left = 144
        Top = 21
        Width = 303
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 0
        OnSelect = cbxTitleSelect
        Items.Strings = (
          'Original title'
          'Translated title'
          'Original title (Translated title)'
          'Translated title (Original title)'
          'Media Label'
          'Custom title')
      end
      object CBPrefixes: TCheckBox
        Left = 8
        Top = 72
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Put following prefixes at the end of the title:'
        TabOrder = 3
        OnClick = CBPrefixesClick
      end
      object EPrefixes: TMemo
        Left = 8
        Top = 96
        Width = 169
        Height = 327
        Anchors = [akLeft, akTop, akBottom]
        ScrollBars = ssVertical
        TabOrder = 4
      end
      object ETitleTemplate: TEdit
        Left = 144
        Top = 45
        Width = 284
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
      end
      object BtnInsertFieldTag: TTBXButton
        Left = 430
        Top = 45
        Width = 17
        Height = 21
        Hint = '|Insert a special value that will be replaced by movie value'
        Anchors = [akTop, akRight]
        AutoSize = False
        BorderSize = 5
        Caption = ' '
        DropDownMenu = PopupFields
        TabOrder = 2
      end
    end
    object TabSheetGroupinh: TTabSheet
      Caption = 'Group'
      ImageIndex = 13
      DesignSize = (
        456
        423)
      object Bevel9: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHGrouping: TLabel
        Left = 0
        Top = 0
        Width = 34
        Height = 13
        Caption = 'Groups'
        Enabled = False
        Transparent = False
      end
      object Bevel30: TBevel
        Left = 8
        Top = 172
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHCommonGroups: TLabel
        Left = 0
        Top = 172
        Width = 76
        Height = 13
        Caption = 'Common groups'
        Enabled = False
        Transparent = False
      end
      object lblGroupLocation: TLabel
        Left = 8
        Top = 196
        Width = 44
        Height = 13
        Caption = 'Location:'
      end
      object CBGroupUnique: TCheckBox
        Left = 8
        Top = 270
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Put in a special common group items that would have been alone i' +
          'n their group'
        TabOrder = 9
      end
      object CBGroupCount: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Display groups count'
        TabOrder = 0
      end
      object CBGroupExpand: TCheckBox
        Left = 8
        Top = 48
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Full expand by default'
        TabOrder = 1
      end
      object RBGroupsAbove: TRadioButton
        Left = 32
        Top = 218
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Groups above common groups'
        TabOrder = 7
      end
      object RBGroupsBelow: TRadioButton
        Left = 32
        Top = 242
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Groups below common groups'
        TabOrder = 8
      end
      object CBGroupMulti: TCheckBox
        Left = 9
        Top = 72
        Width = 400
        Height = 17
        Hint = 
          '|For multi fields such as Category, Actors, Languages, Subtitles' +
          '...'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Make groups with values in multi field separated by:'
        TabOrder = 2
        OnClick = CBGroupMultiClick
      end
      object CBGroupMultiRmAllP: TCheckBox
        Left = 36
        Top = 96
        Width = 407
        Height = 17
        Hint = '|Field Actors by default + Others multi fields'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Remove values between parentheses for all multi fields'
        TabOrder = 4
      end
      object EGroupMultiSep: TComboBox
        Left = 398
        Top = 70
        Width = 48
        Height = 21
        Hint = '|Separator to delimit values in multi fields'
        AutoComplete = False
        ItemHeight = 13
        MaxLength = 1
        TabOrder = 3
        Items.Strings = (
          ','
          ';'
          '|'
          '/'
          '\')
      end
      object CBGroupMultiAddPatch: TCheckBox
        Left = 36
        Top = 120
        Width = 407
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Add patch to ignore parenthesis of (I, (II, (II, (IV... (XXX val' +
          'ues'
        TabOrder = 5
      end
      object CBSortGroupsByCount: TCheckBox
        Left = 10
        Top = 144
        Width = 400
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Sort groups by groups count'
        TabOrder = 6
        OnClick = CBGroupMultiClick
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Extra List'
      ImageIndex = 14
      DesignSize = (
        456
        423)
      object Bevel34: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel35: TBevel
        Left = 8
        Top = 124
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHExtraDisplay: TLabel
        Left = 0
        Top = 0
        Width = 34
        Height = 13
        Caption = 'Display'
        Enabled = False
        Transparent = False
      end
      object Label2: TLabel
        Left = 0
        Top = 124
        Width = 51
        Height = 13
        Caption = 'Operations'
        Enabled = False
        Transparent = False
      end
      object Bevel36: TBevel
        Left = 4
        Top = 176
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object lblExtraGroupLocation: TLabel
        Left = 8
        Top = 348
        Width = 44
        Height = 13
        Caption = 'Location:'
      end
      object LHExtraGrouping: TLabel
        Left = 0
        Top = 176
        Width = 34
        Height = 13
        Caption = 'Groups'
        Enabled = False
        Transparent = False
      end
      object Bevel37: TBevel
        Left = 0
        Top = 324
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHExtraCommonGroups: TLabel
        Left = 0
        Top = 324
        Width = 76
        Height = 13
        Caption = 'Common groups'
        Enabled = False
        Transparent = False
      end
      object CBExtraCheckboxes: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Checkboxes'
        TabOrder = 0
        OnClick = CBCheckboxesClick
      end
      object CBExtraNumWithTitle: TCheckBox
        Left = 8
        Top = 48
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show extra number with extra title'
        TabOrder = 1
      end
      object CBExtraDelete: TCheckBox
        Left = 8
        Top = 148
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Confirm Delete'
        TabOrder = 2
      end
      object CBExtraGroupCount: TCheckBox
        Left = 8
        Top = 200
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Display groups count'
        TabOrder = 3
      end
      object CBExtraGroupExpand: TCheckBox
        Left = 8
        Top = 224
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Full expand by default'
        TabOrder = 4
      end
      object CBExtraGroupMulti: TCheckBox
        Left = 8
        Top = 248
        Width = 400
        Height = 17
        Hint = '|For multi field Category'
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Make groups with values in multi field separated by:'
        TabOrder = 5
        OnClick = CBGroupMultiClick
      end
      object EExtraGroupMultiSep: TComboBox
        Left = 397
        Top = 246
        Width = 48
        Height = 21
        Hint = '|Separator to delimit values in multi fields'
        AutoComplete = False
        ItemHeight = 13
        MaxLength = 1
        TabOrder = 6
        Items.Strings = (
          ','
          ';'
          '|'
          '/'
          '\')
      end
      object CBExtraGroupMultiRmAllP: TCheckBox
        Left = 32
        Top = 272
        Width = 407
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Remove values between parentheses for multi fields'
        TabOrder = 7
      end
      object CBExtraSortGroupsByCount: TCheckBox
        Left = 6
        Top = 296
        Width = 400
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Sort groups by groups count'
        TabOrder = 8
        OnClick = CBGroupMultiClick
      end
      object RBExtraGroupsAbove: TRadioButton
        Left = 24
        Top = 370
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Groups above common groups'
        TabOrder = 9
      end
      object RBExtraGroupsBelow: TRadioButton
        Left = 24
        Top = 394
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Groups below common groups'
        TabOrder = 10
      end
      object CBExtraInfoWhenNoPic: TCheckBox
        Left = 8
        Top = 72
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show extra info instead of picture when there is no picture'
        TabOrder = 11
      end
      object CBExtraCellBorders: TCheckBox
        Left = 8
        Top = 96
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show borders around cells'
        TabOrder = 12
      end
    end
    object TabSheetMovieInformation: TTabSheet
      Caption = 'Movie Info'
      ImageIndex = 3
      DesignSize = (
        456
        423)
      object Bevel11: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel13: TBevel
        Left = 8
        Top = 326
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHPictureWindow: TLabel
        Left = 0
        Top = 326
        Width = 33
        Height = 13
        Caption = 'Picture'
        Enabled = False
        Transparent = False
      end
      object LPictureBackground: TLabel
        Left = 8
        Top = 348
        Width = 87
        Height = 13
        Caption = 'Background color:'
        FocusControl = cbxPictureBackground
      end
      object LHAddMovie: TLabel
        Left = 0
        Top = 0
        Width = 96
        Height = 13
        Caption = 'Adding a new movie'
        Enabled = False
        Transparent = False
      end
      object LDefaultValues: TLabel
        Left = 8
        Top = 106
        Width = 318
        Height = 13
        Caption = 
          'To modify default values of a new movie, click on the button bel' +
          'ow:'
      end
      object Bevel27: TBevel
        Left = 8
        Top = 280
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHRating: TLabel
        Left = 0
        Top = 280
        Width = 31
        Height = 13
        Caption = 'Rating'
        Enabled = False
        Transparent = False
      end
      object Bevel31: TBevel
        Left = 8
        Top = 416
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHMovieFrame: TLabel
        Left = 0
        Top = 416
        Width = 172
        Height = 13
        Caption = 'Frame movie fields and custom fields'
        Enabled = False
        Transparent = False
      end
      object LMovieFrameBackground: TLabel
        Left = 8
        Top = 440
        Width = 87
        Height = 13
        Caption = 'Background color:'
        FocusControl = cbxPictureBackground
      end
      object LColorTag: TLabel
        Left = 312
        Top = 130
        Width = 73
        Height = 13
        Alignment = taRightJustify
        AutoSize = False
        Caption = 'Color Tag:'
      end
      object Bevel33: TBevel
        Left = 8
        Top = 203
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHAddExtra: TLabel
        Left = 0
        Top = 203
        Width = 91
        Height = 13
        Caption = 'Adding a new extra'
        Enabled = False
        Transparent = False
      end
      object LExtraDefaultPicture: TLabel
        Left = 8
        Top = 257
        Width = 98
        Height = 13
        Caption = 'Default extra picture:'
        FocusControl = EExtraDefaultPicture
      end
      object LDefaultPicture: TLabel
        Left = 8
        Top = 179
        Width = 72
        Height = 13
        Caption = 'Default picture:'
        FocusControl = EDefaultPicture
      end
      object cbxPictureBackground: TColorBox
        Left = 144
        Top = 345
        Width = 307
        Height = 22
        AutoComplete = False
        DefaultColorColor = clBtnFace
        NoneColorColor = clBtnFace
        Selected = clDefault
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 15
        TabOrder = 13
      end
      object CBFitPicture: TCheckBox
        Left = 8
        Top = 370
        Width = 439
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Fit picture in window'
        TabOrder = 14
      end
      object CBAskNumber: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Ask for number'
        TabOrder = 0
      end
      object CBAddOpenScript: TCheckBox
        Left = 8
        Top = 84
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Open "Get information from script" window'
        TabOrder = 3
      end
      object CBAddOpenFiles: TCheckBox
        Left = 8
        Top = 64
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Open "Get information from files" window'
        TabOrder = 2
      end
      object CBFirstAvailable: TCheckBox
        Left = 8
        Top = 44
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use first available number instead of highest number + 1'
        TabOrder = 1
      end
      object BtnDefaultValues: TCorelButton
        Left = 8
        Top = 126
        Width = 220
        Height = 22
        Caption = 'Edit default movie values...'
        TabOrder = 4
        OnClick = BtnDefaultValuesClick
      end
      object CBRatingTrunc: TCheckBox
        Left = 8
        Top = 302
        Width = 439
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Do not display decimals in main view, export and printing'
        TabOrder = 12
      end
      object CBShowPicInfo: TCheckBox
        Left = 8
        Top = 390
        Width = 439
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Show picture size, format and path in fullsize picture window'
        TabOrder = 15
      end
      object CBSetCurrentDate: TCheckBox
        Left = 8
        Top = 153
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Fill field "Date Added" with current date instead of specified d' +
          'ate'
        TabOrder = 7
      end
      object cbxMovieFrameBackground: TColorBox
        Left = 144
        Top = 437
        Width = 307
        Height = 22
        AutoComplete = False
        DefaultColorColor = clBtnFace
        NoneColorColor = clBtnFace
        Selected = clDefault
        Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 15
        TabOrder = 16
      end
      object CBChecked: TCheckBox
        Left = 235
        Top = 128
        Width = 78
        Height = 17
        Caption = 'Checked'
        TabOrder = 5
      end
      object EColorTag: TComboBox
        Left = 390
        Top = 126
        Width = 61
        Height = 21
        AutoComplete = False
        Style = csOwnerDrawFixed
        ItemHeight = 15
        MaxLength = 2
        TabOrder = 6
        OnDrawItem = EColorTagDrawItem
      end
      object BtnExtraDefaultValues: TCorelButton
        Left = 8
        Top = 225
        Width = 298
        Height = 22
        Caption = 'Edit default extra values...'
        TabOrder = 9
        OnClick = BtnExtraDefaultValuesClick
      end
      object CBExtraChecked: TCheckBox
        Left = 312
        Top = 227
        Width = 78
        Height = 17
        Caption = 'Checked'
        TabOrder = 10
      end
      object EDefaultPicture: TAntJvComboEditXP
        Left = 143
        Top = 175
        Width = 308
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 8
        OnButtonClick = EDefaultPictureButtonClick
      end
      object EExtraDefaultPicture: TAntJvComboEditXP
        Left = 144
        Top = 254
        Width = 308
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select file'
        ButtonWidth = 22
        TabOrder = 11
        OnButtonClick = EExtraDefaultPictureButtonClick
      end
    end
    object TabSheetComboBox: TTabSheet
      Caption = 'Drop-down'
      ImageIndex = 8
      DesignSize = (
        456
        423)
      object Bevel4: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHComboBoxItems: TLabel
        Left = 0
        Top = 0
        Width = 25
        Height = 13
        Caption = 'Items'
        Enabled = False
        Transparent = False
      end
      object LListEdit: TLabel
        Left = 23
        Top = 176
        Width = 48
        Height = 13
        Caption = 'Edit items:'
      end
      object LListOptions: TGroupBox
        Left = 8
        Top = 52
        Width = 442
        Height = 371
        Anchors = [akLeft, akTop, akRight, akBottom]
        Caption = 'Options for list:'
        TabOrder = 2
      end
      object CBComboAutoAdd: TCheckBox
        Left = 23
        Top = 152
        Width = 410
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Automatically add values that are not in list'
        TabOrder = 6
      end
      object CBComboSort: TCheckBox
        Left = 23
        Top = 80
        Width = 410
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-sort items'
        TabOrder = 3
      end
      object EComboEdit: TMemo
        Left = 23
        Top = 176
        Width = 412
        Height = 232
        Anchors = [akLeft, akTop, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 7
        WordWrap = False
      end
      object CBComboAutoComplete: TCheckBox
        Left = 23
        Top = 104
        Width = 410
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-complete while typing'
        TabOrder = 4
      end
      object CBComboCatalogValues: TCheckBox
        Left = 23
        Top = 128
        Width = 410
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use values of current catalog instead of predefined list'
        TabOrder = 5
        OnClick = CBComboCatalogValuesClick
      end
      object CBComboSameForAll: TCheckBox
        Left = 8
        Top = 24
        Width = 427
        Height = 17
        Caption = 'Same options for all lists (does not affect list contents)'
        TabOrder = 0
      end
      object cbxComboSelect: TComboBox
        Left = 136
        Top = 47
        Width = 306
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbxComboSelectChange
        Items.Strings = (
          'Media Types'
          'Sources'
          'Borrowers'
          'Country'
          'Category'
          'Video Format'
          'Audio Format'
          'Framerate'
          'Languages'
          'Subtitles'
          'Certification'
          'Tag (Extras)'
          'Category (Extras)'
          'Created by (Extras)')
      end
    end
    object TabSheetGetInfo: TTabSheet
      Caption = 'Get info'
      ImageIndex = 9
      DesignSize = (
        456
        423)
      object Bevel28: TBevel
        Left = 4
        Top = 272
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel14: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHVideoDragDrop: TLabel
        Left = 0
        Top = 0
        Width = 184
        Height = 13
        Caption = 'Drag && Drop / Get information from files'
        Enabled = False
        Transparent = False
      end
      object LDNDSizeUnit: TLabel
        Left = 32
        Top = 152
        Width = 22
        Height = 13
        Caption = 'Unit:'
        FocusControl = cbxDNDSizeUnit
      end
      object LHGetInfoVideo: TLabel
        Left = 0
        Top = 272
        Width = 145
        Height = 13
        Caption = 'Info to take from video streams'
        Enabled = False
        Transparent = False
      end
      object Bevel29: TBevel
        Left = 4
        Top = 364
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHGetInfoAudio: TLabel
        Left = 0
        Top = 364
        Width = 145
        Height = 13
        Caption = 'Info to take from audio streams'
        Enabled = False
        Transparent = False
      end
      object LExtVideo: TLabel
        Left = 9
        Top = 242
        Width = 54
        Height = 13
        Caption = 'Extensions:'
      end
      object CBDNDAudioChannels: TCheckBox
        Left = 224
        Top = 388
        Width = 209
        Height = 17
        Caption = 'Import audio channels'
        TabOrder = 20
      end
      object CBDNDSize: TCheckBox
        Left = 8
        Top = 104
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import size:'
        TabOrder = 5
        OnClick = CBDNDSizeClick
      end
      object RBDNDString: TRadioButton
        Left = 32
        Top = 128
        Width = 185
        Height = 17
        Caption = 'Make a string, e.g. "650+530"'
        TabOrder = 6
      end
      object RBDNDSum: TRadioButton
        Left = 224
        Top = 128
        Width = 185
        Height = 17
        Caption = 'Make a sum, e.g. "1180"'
        TabOrder = 7
      end
      object CBDNDFileName: TCheckBox
        Left = 8
        Top = 44
        Width = 209
        Height = 17
        Caption = 'Import filename as title'
        TabOrder = 1
        OnClick = CBDNDFileNameClick
      end
      object CBDNDResolution: TCheckBox
        Left = 8
        Top = 316
        Width = 209
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import resolution'
        TabOrder = 15
      end
      object CBDNDLength: TCheckBox
        Left = 8
        Top = 296
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import length'
        TabOrder = 14
      end
      object CBDNDFramerate: TCheckBox
        Left = 224
        Top = 316
        Width = 225
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import frame rate'
        TabOrder = 16
      end
      object CBDNDVideoCodec: TCheckBox
        Left = 8
        Top = 336
        Width = 209
        Height = 17
        Caption = 'Import video codec'
        TabOrder = 17
      end
      object CBDNDAudioCodec: TCheckBox
        Left = 8
        Top = 388
        Width = 209
        Height = 17
        Caption = 'Import audio codec'
        TabOrder = 19
      end
      object cbxDNDSizeUnit: TComboBox
        Left = 80
        Top = 148
        Width = 238
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 8
        Items.Strings = (
          'Bytes (B)'
          'Kilobytes (KB)'
          'Megabytes (MB)'
          'Gigabytes (GB)')
      end
      object CBDNDVideoBitrate: TCheckBox
        Left = 224
        Top = 336
        Width = 226
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import video bitrate'
        TabOrder = 18
      end
      object CBDNDAudioBitrate: TCheckBox
        Left = 8
        Top = 408
        Width = 226
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import audio bitrate'
        TabOrder = 21
      end
      object CBDNDFileNameURL: TCheckBox
        Left = 8
        Top = 84
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import full path in URL field'
        TabOrder = 4
      end
      object CBDNDMediaLabel: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import media label'
        TabOrder = 0
      end
      object CBDNDLanguages: TCheckBox
        Left = 8
        Top = 428
        Width = 209
        Height = 17
        Caption = 'Import languages'
        TabOrder = 22
      end
      object CBDNDSubtitles: TCheckBox
        Left = 224
        Top = 428
        Width = 226
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import subtitles'
        TabOrder = 23
      end
      object CBDNDInternalAVI: TCheckBox
        Left = 8
        Top = 214
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 
          'Use internal engine rather than MediaInfo DLL for AVI importatio' +
          'n (faster)'
        TabOrder = 11
      end
      object EExtVideo: TEdit
        Left = 80
        Top = 238
        Width = 289
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 12
      end
      object btnDefaultExtVideo: TCorelButton
        Left = 375
        Top = 237
        Width = 75
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Default'
        TabOrder = 13
        OnClick = btnDefaultExtVideoClick
      end
      object btnFilterFileName: TCorelButton
        Left = 225
        Top = 41
        Width = 150
        Height = 23
        Anchors = [akTop, akRight]
        Caption = 'Filter the file name'
        TabOrder = 2
        OnClick = btnFilterFileNameClick
      end
      object CBDNDAllowClear: TCheckBox
        Left = 8
        Top = 194
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Allow to clear fields when new value is empty'
        TabOrder = 10
      end
      object CBDNDFileNameFilePath: TCheckBox
        Left = 8
        Top = 64
        Width = 441
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import full path in File Path field'
        TabOrder = 3
      end
      object CBDNDPicture: TCheckBox
        Left = 8
        Top = 174
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Import associated picture (same name of media file)'
        TabOrder = 9
      end
    end
    object TabSheetPictureImport: TTabSheet
      Caption = 'PicImport'
      ImageIndex = 13
      DesignSize = (
        456
        423)
      object Bevel24: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHImportPic: TLabel
        Left = 0
        Top = 0
        Width = 181
        Height = 13
        Caption = 'Importing picture from external sources'
        Enabled = False
        Transparent = False
      end
      object LPicNamingNote: TLabel
        Left = 8
        Top = 428
        Width = 444
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'Notes: if the picture name is already taken by another movie or ' +
          'extra, a random name will be generated. When there is no origina' +
          'l name (e.g. when converting from amc to xml file format), the m' +
          'ovie title is used.'
        WordWrap = True
      end
      object LPicCopyNote: TLabel
        Left = 8
        Top = 279
        Width = 444
        Height = 41
        Anchors = [akLeft, akTop, akRight]
        AutoSize = False
        Caption = 
          'Note: when picture is stored in the same folder than the catalog' +
          ' or in pictures folder of the catalog, it is deleted when it is ' +
          'not used anymore in the catalog'
        WordWrap = True
      end
      object LPicNamingPlus: TLabel
        Left = 233
        Top = 326
        Width = 9
        Height = 20
        Caption = '+'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'MS Shell Dlg'
        Font.Style = []
        ParentFont = False
      end
      object PanelExtraPicImport: TPanel
        Left = 2
        Top = 46
        Width = 454
        Height = 227
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        TabOrder = 3
        Visible = False
        DesignSize = (
          454
          227)
        object LExtraMaxPicSizeW: TLabel
          Left = 38
          Top = 209
          Width = 53
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'max width='
          ParentBiDiMode = False
        end
        object LExtraMaxPicSizeH: TLabel
          Left = 182
          Top = 209
          Width = 57
          Height = 13
          Caption = 'max height='
        end
        object LExtraMaxPicSizeUnit: TLabel
          Left = 330
          Top = 209
          Width = 37
          Height = 13
          Caption = 'in pixels'
        end
        inline ExtraPicImportGetInfo: TPictureSelectOptionsFrame
          Left = 4
          Top = 0
          Width = 444
          Height = 83
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          inherited grp: TGroupBox
            Left = 0
            Width = 444
            Height = 83
            Align = alClient
            Caption = 'For drag && drop / Get information from files'
            inherited rbtStorePic: TRadioButton
              Width = 428
            end
            inherited rbtCopyPicInCatDir: TRadioButton
              Width = 428
            end
            inherited rbtLinkPic: TRadioButton
              Width = 176
            end
            inherited chkLinkRelative: TCheckBox
              Left = 191
              Width = 248
            end
            inherited rbtCopyPicInPicDir: TRadioButton
              Width = 428
            end
          end
        end
        inline ExtraPicImportScripting: TPictureSelectOptionsFrame
          Left = 4
          Top = 113
          Width = 444
          Height = 66
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 2
          inherited grp: TGroupBox
            Left = 0
            Width = 444
            Height = 66
            Align = alClient
            Caption = 'For internet scripting'
            inherited rbtStorePic: TRadioButton
              Width = 428
            end
            inherited rbtCopyPicInCatDir: TRadioButton
              Width = 428
            end
            inherited rbtLinkPic: TRadioButton
              Enabled = False
              Visible = False
            end
            inherited chkLinkRelative: TCheckBox
              Enabled = False
              Visible = False
            end
            inherited rbtCopyPicInPicDir: TRadioButton
              Width = 428
            end
          end
        end
        object CBExtraPicImportGetInfoNoAsk: TCheckBox
          Left = 28
          Top = 89
          Width = 420
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 
            'Do not ask for picture import method; always use the above optio' +
            'n'
          TabOrder = 1
        end
        object EExtraMaxPicSizeW: TEdit
          Left = 109
          Top = 205
          Width = 52
          Height = 21
          Hint = '|Leave empty if you do not want to define a max width'
          TabOrder = 3
        end
        object EExtraMaxPicSizeH: TEdit
          Left = 257
          Top = 205
          Width = 52
          Height = 21
          Hint = '|Leave empty if you do not want to define a max height'
          TabOrder = 4
        end
        object CBExtraPicConvert: TCheckBox
          Left = 8
          Top = 187
          Width = 438
          Height = 17
          Caption = 
            'Convert picture to JPG and resize it when picture is stored or c' +
            'opied'
          TabOrder = 5
          OnClick = CBExtraPicConvertClick
        end
      end
      object PanelPicImport: TPanel
        Left = 2
        Top = 46
        Width = 454
        Height = 227
        Anchors = [akLeft, akTop, akRight]
        BevelOuter = bvNone
        TabOrder = 2
        DesignSize = (
          454
          227)
        object LMaxPicSizeUnit: TLabel
          Left = 334
          Top = 209
          Width = 37
          Height = 13
          Caption = 'in pixels'
        end
        object LMaxPicSizeH: TLabel
          Left = 186
          Top = 209
          Width = 57
          Height = 13
          Caption = 'max height='
        end
        object LMaxPicSizeW: TLabel
          Left = 38
          Top = 209
          Width = 53
          Height = 13
          BiDiMode = bdLeftToRight
          Caption = 'max width='
          ParentBiDiMode = False
        end
        inline PicImportGetInfo: TPictureSelectOptionsFrame
          Left = 4
          Top = 0
          Width = 444
          Height = 83
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          inherited grp: TGroupBox
            Left = 0
            Width = 444
            Height = 83
            Align = alClient
            Caption = 'For drag && drop / Get information from files'
            inherited rbtStorePic: TRadioButton
              Width = 428
            end
            inherited rbtCopyPicInCatDir: TRadioButton
              Width = 428
            end
            inherited rbtLinkPic: TRadioButton
              Width = 176
            end
            inherited chkLinkRelative: TCheckBox
              Left = 191
              Width = 248
            end
          end
        end
        inline PicImportScripting: TPictureSelectOptionsFrame
          Left = 4
          Top = 113
          Width = 444
          Height = 66
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 2
          inherited grp: TGroupBox
            Left = 0
            Width = 444
            Height = 66
            Align = alClient
            Caption = 'For internet scripting'
            inherited rbtStorePic: TRadioButton
              Width = 428
            end
            inherited rbtCopyPicInCatDir: TRadioButton
              Width = 428
            end
            inherited rbtLinkPic: TRadioButton
              Enabled = False
              Visible = False
            end
            inherited chkLinkRelative: TCheckBox
              Enabled = False
              Visible = False
            end
          end
        end
        object CBPicImportGetInfoNoAsk: TCheckBox
          Left = 28
          Top = 89
          Width = 420
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 
            'Do not ask for picture import method; always use the above optio' +
            'n'
          TabOrder = 1
        end
        object CBPicConvert: TCheckBox
          Left = 8
          Top = 187
          Width = 438
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 
            'Convert picture to JPG and resize it when picture is stored or c' +
            'opied'
          TabOrder = 3
          OnClick = CBPicConvertClick
        end
        object EMaxPicSizeH: TEdit
          Left = 261
          Top = 205
          Width = 52
          Height = 21
          Hint = '|Leave empty if you do not want to define a max height'
          TabOrder = 4
        end
        object EMaxPicSizeW: TEdit
          Left = 113
          Top = 205
          Width = 52
          Height = 21
          Hint = '|Leave empty if you do not want to define a max width'
          TabOrder = 5
        end
      end
      object RBPicImport: TRadioButton
        Left = 8
        Top = 23
        Width = 110
        Height = 17
        Caption = 'For movies'
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = RBPicImportClick
      end
      object RBExtraPicImport: TRadioButton
        Left = 121
        Top = 23
        Width = 120
        Height = 17
        Caption = 'For extras'
        TabOrder = 1
        OnClick = RBPicImportClick
      end
      inline PicNamingFrame: TFileNamingFrame
        Left = 8
        Top = 324
        Width = 442
        Height = 97
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
        inherited grp: TGroupBox
          Width = 442
          Caption = 'Picture naming'
        end
      end
    end
    object TabSheetSearch: TTabSheet
      Caption = 'Search inet'
      ImageIndex = 10
      DesignSize = (
        456
        423)
      object Bevel18: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHSearch: TLabel
        Left = 0
        Top = 0
        Width = 87
        Height = 13
        Caption = 'Search on internet'
        Enabled = False
        Transparent = False
      end
      object LSearchEdit: TLabel
        Left = 8
        Top = 96
        Width = 83
        Height = 13
        Caption = 'Edit selected line:'
        FocusControl = ESearchName
      end
      object LSearchNotes: TLabel
        Left = 8
        Top = 22
        Width = 31
        Height = 13
        Caption = 'Notes:'
      end
      object LSearchNote1: TLabel
        Left = 12
        Top = 38
        Width = 116
        Height = 13
        Caption = '- Name has to be unique'
      end
      object LSearchNote2: TLabel
        Left = 12
        Top = 54
        Width = 348
        Height = 13
        Caption = 
          '- In the address, enter %s to put the movie title or [FieldTag] ' +
          'for other fields'
      end
      object LSearchNote3: TLabel
        Left = 12
        Top = 70
        Width = 370
        Height = 13
        Caption = 
          '- To put a separator in the list, make a (unique) name beginning' +
          ' with a dash "-"'
      end
      object ESearchName: TEdit
        Left = 8
        Top = 115
        Width = 150
        Height = 21
        TabOrder = 4
        OnChange = ESearchNameChange
      end
      object ESearchAddress: TEdit
        Left = 159
        Top = 115
        Width = 270
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 5
        OnChange = ESearchAddressChange
      end
      object LvSearch: TListView
        Left = 8
        Top = 137
        Width = 439
        Height = 286
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
        OnSelectItem = LvSearchSelectItem
      end
      object btnSearchDown: TTBXButton
        Left = 424
        Top = 91
        Width = 23
        Height = 22
        Hint = 'Move down|Move down selected item'
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'dn'
        TabOrder = 3
        OnClick = btnSearchDownClick
      end
      object btnSearchUp: TTBXButton
        Left = 400
        Top = 91
        Width = 23
        Height = 22
        Hint = 'Move up|Move up selected item'
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'up'
        TabOrder = 2
        OnClick = btnSearchUpClick
      end
      object btnSearchDel: TTBXButton
        Left = 376
        Top = 91
        Width = 23
        Height = 22
        Hint = 'Delete|Delete selected item'
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'del'
        TabOrder = 1
        OnClick = btnSearchDelClick
      end
      object btnSearchAdd: TTBXButton
        Left = 352
        Top = 91
        Width = 23
        Height = 22
        Hint = 'Add|Add a new item above selected item'
        Anchors = [akTop, akRight]
        AutoSize = False
        Caption = 'ad'
        TabOrder = 0
        OnClick = btnSearchAddClick
      end
      object btnInsertFieldTagURL: TTBXButton
        Left = 430
        Top = 115
        Width = 17
        Height = 21
        Hint = '|Insert a special value that will be replaced by movie value'
        Anchors = [akTop, akRight]
        AutoSize = False
        BorderSize = 5
        Caption = ' '
        DropDownMenu = PopupFields
        TabOrder = 7
      end
    end
    object TabSheetScripting: TTabSheet
      Caption = 'Scripting'
      ImageIndex = 13
      DesignSize = (
        456
        423)
      object Bevel10: TBevel
        Left = 8
        Top = 72
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel20: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHScript: TLabel
        Left = 0
        Top = 0
        Width = 71
        Height = 13
        Caption = 'Scripts settings'
        Enabled = False
        Transparent = False
      end
      object LProxyServer: TLabel
        Left = 32
        Top = 122
        Width = 34
        Height = 13
        Caption = 'Server:'
        FocusControl = EProxyServer
      end
      object LProxyUsername: TLabel
        Left = 32
        Top = 146
        Width = 54
        Height = 13
        Caption = 'User name:'
        FocusControl = EProxyUsername
      end
      object LProxyPassword: TLabel
        Left = 32
        Top = 170
        Width = 49
        Height = 13
        Caption = 'Password:'
        FocusControl = EProxyPassword
      end
      object LProxyPort: TLabel
        Left = 353
        Top = 122
        Width = 22
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Port:'
        FocusControl = EProxyPort
      end
      object LScriptPicImport: TAntJvLinkLabel
        Left = 8
        Top = 48
        Width = 444
        Height = 13
        Caption = 
          'For picture importation preferences, see the <LINK>Picture Impor' +
          'tation</LINK> page'
        Text.Strings = (
          
            'For picture importation preferences, see the <LINK>Picture Impor' +
            'tation</LINK> page')
        Anchors = [akLeft, akTop, akRight]
        Transparent = False
        LinkColor = clBlue
        LinkColorClicked = clBlue
        LinkColorHot = clBlue
        LinkStyle = [fsUnderline]
        HotLinks = False
        AutoHeight = True
        MarginWidth = 0
        MarginHeight = 0
        OnLinkClick = PicImportLinkClick
      end
      object LHConnection: TLabel
        Left = 0
        Top = 72
        Width = 92
        Height = 13
        Caption = 'Internet connection'
        Enabled = False
        Transparent = False
      end
      object CBProxy: TCheckBox
        Left = 8
        Top = 96
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Use proxy when accessing to internet:'
        TabOrder = 1
        OnClick = CBProxyClick
      end
      object EProxyPassword: TEdit
        Left = 112
        Top = 166
        Width = 226
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        PasswordChar = '*'
        TabOrder = 5
      end
      object EProxyUsername: TEdit
        Left = 112
        Top = 142
        Width = 226
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 4
      end
      object EProxyServer: TEdit
        Left = 112
        Top = 118
        Width = 226
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 2
      end
      object CBAutorunScript: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Auto-run last script used with "Get information from script"'
        TabOrder = 0
      end
      object CBKeepConnection: TCheckBox
        Left = 8
        Top = 200
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Keep connection alive'
        TabOrder = 6
        OnClick = CBProxyClick
      end
      object EProxyPort: TAntJvSpinEdit
        Left = 390
        Top = 118
        Width = 57
        Height = 21
        Alignment = taRightJustify
        MaxValue = 65535.000000000000000000
        Value = 8080.000000000000000000
        Anchors = [akTop, akRight]
        TabOrder = 3
      end
      object CBHTTP10: TCheckBox
        Left = 8
        Top = 224
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Restrict to HTTP 1.0 (needed by some proxy servers)'
        TabOrder = 7
        OnClick = CBProxyClick
      end
    end
    object TabSheetExport: TTabSheet
      Caption = 'Export'
      ImageIndex = 2
      DesignSize = (
        456
        423)
      object Bevel26: TBevel
        Left = 4
        Top = 132
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel23: TBevel
        Left = 4
        Top = 180
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Bevel8: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHHTML: TLabel
        Left = 0
        Top = 0
        Width = 30
        Height = 13
        Caption = 'HTML'
        Enabled = False
        Transparent = False
      end
      object Bevel15: TBevel
        Left = 8
        Top = 362
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHPictures: TLabel
        Left = 0
        Top = 362
        Width = 38
        Height = 13
        Caption = 'Pictures'
        Enabled = False
        Transparent = False
      end
      object LLineBreaks: TLabel
        Left = 8
        Top = 48
        Width = 228
        Height = 13
        Caption = 'Line breaks will be replaced by the following tag:'
        FocusControl = ELineBreaks
      end
      object LHExportFileNames: TLabel
        Left = 0
        Top = 180
        Width = 47
        Height = 13
        Caption = 'Filenames'
        Enabled = False
        Transparent = False
      end
      object LHSQL: TLabel
        Left = 0
        Top = 132
        Width = 21
        Height = 13
        Caption = 'SQL'
        Enabled = False
        Transparent = False
      end
      object LSQLDate: TLabel
        Left = 8
        Top = 156
        Width = 250
        Height = 13
        Caption = 'Date format (put special characters between quotes):'
        FocusControl = ESQLDate
      end
      object LForcePicSize: TLabel
        Left = 8
        Top = 76
        Width = 117
        Height = 13
        Caption = 'Force movie picture size:'
      end
      object LForcePicSizeW: TLabel
        Left = 263
        Top = 76
        Width = 31
        Height = 13
        Caption = 'width='
        FocusControl = EForcePicSizeW
      end
      object LForcePicSizeH: TLabel
        Left = 357
        Top = 76
        Width = 35
        Height = 13
        Caption = 'height='
        FocusControl = EForcePicSizeH
      end
      object LExpFileExt: TLabel
        Left = 346
        Top = 204
        Width = 100
        Height = 13
        Alignment = taRightJustify
        Anchors = [akTop, akRight]
        Caption = 'Extension to append:'
        FocusControl = EExpFileExt
      end
      object LForceExtraPicSize: TLabel
        Left = 8
        Top = 104
        Width = 112
        Height = 13
        Caption = 'Force extra picture size:'
      end
      object LForceExtraPicSizeW: TLabel
        Left = 263
        Top = 104
        Width = 31
        Height = 13
        Caption = 'width='
        FocusControl = EForcePicSizeW
      end
      object LForceExtraPicSizeH: TLabel
        Left = 357
        Top = 104
        Width = 35
        Height = 13
        Caption = 'height='
        FocusControl = EForcePicSizeH
      end
      object CBLoadTemplate: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Automatically reload last used templates'
        TabOrder = 0
      end
      object CBCopyPicturesNew: TCheckBox
        Left = 32
        Top = 430
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Copy only if target file does not exist'
        TabOrder = 13
      end
      object CBCopyPictures: TCheckBox
        Left = 8
        Top = 388
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Copy images to the same folder than the exported file'
        TabOrder = 11
        OnClick = CBCopyPicturesClick
      end
      object CBLastFileName: TCheckBox
        Left = 8
        Top = 204
        Width = 325
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Remember filename of last exported file'
        TabOrder = 7
      end
      object CBOpenExportedFile: TCheckBox
        Left = 8
        Top = 228
        Width = 325
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Open exported file when export finished'
        TabOrder = 8
      end
      object ELineBreaks: TComboBox
        Left = 296
        Top = 44
        Width = 151
        Height = 22
        Hint = '|Leave this field empty if you do not want to replace linebreaks'
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ItemHeight = 14
        ParentFont = False
        TabOrder = 1
        Items.Strings = (
          '<br />'
          '<br>'
          '<p>')
      end
      object ESQLDate: TComboBox
        Left = 296
        Top = 152
        Width = 151
        Height = 22
        Hint = '|Leave empty for Windows default'
        AutoComplete = False
        Anchors = [akLeft, akTop, akRight]
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ItemHeight = 14
        ParentFont = False
        TabOrder = 6
        Items.Strings = (
          'yyyy'#39'/'#39'mm'#39'/'#39'dd'
          'yyyy'#39'-'#39'mm'#39'-'#39'dd'
          'dd'#39'/'#39'mm'#39'/'#39'yyyy'
          'mm'#39'/'#39'dd'#39'/'#39'yyyy')
      end
      object EForcePicSizeW: TEdit
        Left = 296
        Top = 72
        Width = 52
        Height = 21
        Hint = '|Leave empty if you do not want to force width value'
        TabOrder = 2
      end
      object EForcePicSizeH: TEdit
        Left = 394
        Top = 72
        Width = 52
        Height = 21
        Hint = '|Leave empty if you do not want to force height value'
        TabOrder = 3
      end
      object CBCopyPicturesInPicDir: TCheckBox
        Left = 32
        Top = 410
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Copy pictures into a subfolder pictures'
        TabOrder = 12
      end
      object CBCopyPicturesIncExtras: TCheckBox
        Left = 32
        Top = 450
        Width = 420
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Include extra pictures'
        TabOrder = 14
      end
      inline ExpFileNamingFrame: TFileNamingFrame
        Left = 8
        Top = 254
        Width = 438
        Height = 97
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 10
        inherited grp: TGroupBox
          Width = 438
          Caption = 'Individual pages and pictures filename style'
        end
      end
      object EExpFileExt: TComboBox
        Left = 344
        Top = 220
        Width = 102
        Height = 21
        Hint = '|Leave empty to use same extension as main exported filename'
        AutoComplete = False
        Anchors = [akTop, akRight]
        ItemHeight = 13
        TabOrder = 9
        Items.Strings = (
          '.html'
          '.htm'
          '.php'
          '.asp'
          '.shtml')
      end
      object EForceExtraPicSizeW: TEdit
        Left = 296
        Top = 100
        Width = 52
        Height = 21
        Hint = '|Leave empty if you do not want to force width value'
        TabOrder = 4
      end
      object EForceExtraPicSizeH: TEdit
        Left = 394
        Top = 100
        Width = 52
        Height = 21
        Hint = '|Leave empty if you do not want to force height value'
        TabOrder = 5
      end
    end
    object TabSheetFolders: TTabSheet
      Caption = 'Folders'
      ImageIndex = 8
      DesignSize = (
        456
        423)
      object Bevel12: TBevel
        Left = 8
        Top = 0
        Width = 444
        Height = 9
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object LHFoldersDialogs: TLabel
        Left = 0
        Top = 0
        Width = 61
        Height = 13
        Caption = 'Dialog boxes'
        Enabled = False
        Transparent = False
      end
      object LFolderToUse: TGroupBox
        Left = 8
        Top = 52
        Width = 442
        Height = 133
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Folder to use for:'
        TabOrder = 2
      end
      object RBFolderDefault: TRadioButton
        Left = 23
        Top = 80
        Width = 393
        Height = 17
        Caption = 'Windows'#39' default (result depends of Windows version)'
        Checked = True
        TabOrder = 3
        TabStop = True
        OnClick = RBFolderDefaultClick
      end
      object RBFolderRemember: TRadioButton
        Left = 23
        Top = 104
        Width = 393
        Height = 17
        Caption = 'Remember last used folder'
        TabOrder = 4
        OnClick = RBFolderRememberClick
      end
      object RBFolderSpecified: TRadioButton
        Left = 23
        Top = 128
        Width = 393
        Height = 17
        Caption = 'Use this folder:'
        TabOrder = 5
        OnClick = RBFolderSpecifiedClick
      end
      object cbxWindow: TComboBox
        Left = 136
        Top = 47
        Width = 306
        Height = 21
        AutoComplete = False
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 1
        OnChange = cbxWindowChange
        Items.Strings = (
          'Load/save catalogs'
          'Load movie picture'
          'Export'
          'Load/save templates'
          'Import'
          'Get information from files'
          'Save Graphic'
          'Load/save scripts'
          'Load/save custom fields'
          'Load/save filters')
      end
      object CBSameForAll: TCheckBox
        Left = 8
        Top = 24
        Width = 444
        Height = 17
        Anchors = [akLeft, akTop, akRight]
        Caption = 'Same options for all windows'
        TabOrder = 0
        OnClick = CBSameForAllClick
      end
      object EFolderSpecified: TAntJvComboEditXP
        Left = 46
        Top = 149
        Width = 389
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ButtonHint = 'Browse...|Select folder'
        ButtonWidth = 22
        TabOrder = 6
        OnButtonClick = EFolderSpecifiedButtonClick
      end
    end
  end
  object PopupFields: TTBXPopupMenu
    Left = 56
    Top = 424
  end
end
