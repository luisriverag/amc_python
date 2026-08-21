inherited GetScriptWin: TGetScriptWin
  Left = 605
  Top = 204
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Scripting'
  ClientHeight = 471
  ClientWidth = 762
  Constraints.MinHeight = 500
  Constraints.MinWidth = 770
  KeyPreview = True
  OldCreateOrder = True
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 438
    Width = 756
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 455
    Width = 762
  end
  object PageControl1: TPageControl [2]
    Left = -1
    Top = 25
    Width = 764
    Height = 413
    ActivePage = shtScript
    Anchors = [akLeft, akTop, akRight, akBottom]
    Style = tsButtons
    TabOrder = 0
    object shtScript: TTabSheet
      Caption = 'Script'
      object DockScriptRight: TTBXMultiDock
        Left = 587
        Top = 0
        Width = 169
        Height = 382
        BoundLines = [blTop, blBottom, blLeft, blRight]
        Position = dpRight
        object DockpanelLimitations: TTBXDockablePanel
          Left = 0
          Top = 205
          MinClientHeight = 132
          MinClientWidth = 60
          Caption = 'Script limitations'
          CloseButton = False
          CloseButtonWhenDocked = False
          DockedWidth = 163
          DockPos = 205
          FloatingWidth = 128
          FloatingHeight = 128
          HideWhenInactive = False
          SplitHeight = 164
          SupportedDocks = [dkMultiDock]
          TabOrder = 3
          object grpLimitFields: TGroupBox
            Left = 0
            Top = 82
            Width = 163
            Height = 50
            Align = alClient
            Caption = 'Modifiable fields'
            TabOrder = 0
            object lstLimitFields: TListView
              Left = 2
              Top = 15
              Width = 159
              Height = 33
              Hint = '|Note: fields selection is saved only when executing the script.'
              Align = alClient
              BorderStyle = bsNone
              Checkboxes = True
              Columns = <>
              ReadOnly = True
              ParentColor = True
              PopupMenu = MenuPopupList
              TabOrder = 0
              ViewStyle = vsSmallIcon
              OnMouseDown = lstLimitFieldsMouseDown
            end
          end
          inline lstLimitMovies: TIncludemovFrame
            Left = 0
            Top = 0
            Width = 163
            Height = 82
            Align = alTop
            TabOrder = 1
            inherited grp: TGroupBox
              Width = 163
              Height = 82
              inherited rbtAll: TRadioButton
                Top = 14
                Width = 144
              end
              inherited rbtSelected: TRadioButton
                Top = 30
                Width = 144
              end
              inherited rbtChecked: TRadioButton
                Top = 46
                Width = 144
              end
              inherited rbtVisible: TRadioButton
                Top = 62
                Width = 121
              end
            end
          end
        end
        object DockpanelOptions: TTBXDockablePanel
          Left = 0
          Top = 80
          Hint = 
            '|Double-click on an option to change it. Note: options are saved' +
            ' only when executing the script.'
          MinClientHeight = 24
          MinClientWidth = 60
          Caption = 'Script options'
          CloseButton = False
          CloseButtonWhenDocked = False
          DockedWidth = 163
          DockPos = 80
          FloatingWidth = 128
          FloatingHeight = 128
          HideWhenInactive = False
          SplitHeight = 79
          SupportedDocks = [dkMultiDock]
          TabOrder = 1
          OnDockChanged = DockpanelOptionsDockChanged
          object lstScriptOptions: TListView
            Left = 0
            Top = 0
            Width = 163
            Height = 47
            Align = alClient
            BorderStyle = bsNone
            Columns = <
              item
                AutoSize = True
              end
              item
                Alignment = taCenter
                Width = 25
              end>
            Items.Data = {
              680000000300000000000000FFFFFFFFFFFFFFFF0100000000000000076F7074
              696F6E31013100000000FFFFFFFFFFFFFFFF0100000000000000076F7074696F
              6E32013200000000FFFFFFFFFFFFFFFF0100000000000000076F7074696F6E33
              0133FFFFFFFFFFFF}
            ReadOnly = True
            RowSelect = True
            ParentColor = True
            PopupMenu = MenuPopupOptions
            ShowColumnHeaders = False
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = ActionOptionsEditExecute
            OnInfoTip = lstScriptOptionsInfoTip
            OnKeyPress = lstScriptOptionsKeyPress
          end
        end
        object DockpanelExec: TTBXDockablePanel
          Left = 0
          Top = 0
          MaxClientHeight = 53
          MinClientHeight = 53
          MinClientWidth = 60
          Caption = 'Execution options'
          CloseButton = False
          CloseButtonWhenDocked = False
          DockedWidth = 163
          DockPos = 1
          HideWhenInactive = False
          SplitHeight = 75
          SupportedDocks = [dkMultiDock]
          TabOrder = 0
          DesignSize = (
            163
            53)
          object CBShowResults: TTBXCheckBox
            Left = 4
            Top = 18
            Width = 155
            Height = 17
            Hint = 
              'Displays old and new field values of each movie for manual selec' +
              'tion of which field has to be kept'
            Anchors = [akLeft, akTop, akRight]
            Caption = 'Show &results window'
            TabOrder = 0
            Wrapping = twEndEllipsis
          end
          object CBCloseThis: TTBXCheckBox
            Left = 4
            Top = 35
            Width = 155
            Height = 17
            Hint = 'Close this window when script execution is successfully finished'
            Anchors = [akLeft, akTop, akRight]
            Caption = 'Close this window at &end'
            TabOrder = 1
            Wrapping = twEndEllipsis
          end
          object CBAllowClear: TTBXCheckBox
            Left = 4
            Top = 1
            Width = 155
            Height = 17
            Hint = 
              'Allow the script to replace values by empty ones if the script s' +
              'pecifies it'
            Anchors = [akLeft, akTop, akRight]
            Caption = '&Allow to clear fields'
            TabOrder = 2
            Wrapping = twEndEllipsis
          end
        end
        object DockpanelParameters: TTBXDockablePanel
          Left = 0
          Top = 154
          Hint = 
            '|Double-click on an parameter to change it. Note: parameters are' +
            ' saved only when executing the script.'
          MinClientHeight = 24
          MinClientWidth = 60
          Caption = 'Script parameters'
          CloseButton = False
          CloseButtonWhenDocked = False
          DockedWidth = 163
          DockPos = 154
          FloatingWidth = 128
          FloatingHeight = 128
          HideWhenInactive = False
          SplitHeight = 46
          SupportedDocks = [dkMultiDock]
          TabOrder = 2
          OnDockChanged = DockpanelParametersDockChanged
          object lstScriptParameters: TListView
            Left = 0
            Top = 0
            Width = 163
            Height = 24
            Align = alClient
            BorderStyle = bsNone
            Columns = <
              item
                AutoSize = True
              end
              item
                AutoSize = True
              end>
            Items.Data = {
              740000000300000000000000FFFFFFFFFFFFFFFF010000000000000006706172
              616D310676616C75653100000000FFFFFFFFFFFFFFFF01000000000000000670
              6172616D320676616C75653200000000FFFFFFFFFFFFFFFF0100000000000000
              06706172616D330676616C756533FFFFFFFFFFFF}
            ReadOnly = True
            RowSelect = True
            ParentColor = True
            PopupMenu = MenuPopupParameters
            ShowColumnHeaders = False
            TabOrder = 0
            ViewStyle = vsReport
            OnDblClick = ActionParametersEditExecute
            OnInfoTip = lstScriptParametersInfoTip
            OnKeyPress = lstScriptParametersKeyPress
          end
        end
      end
      object Panel1: TPanel
        Left = 7
        Top = 0
        Width = 580
        Height = 382
        Align = alClient
        BevelOuter = bvNone
        ParentBackground = False
        TabOrder = 0
        object Splitter1: TSplitter
          Left = 0
          Top = 274
          Width = 580
          Height = 3
          Cursor = crVSplit
          Align = alBottom
          ResizeStyle = rsUpdate
        end
        object lstScripts: TListView
          Left = 0
          Top = 0
          Width = 580
          Height = 274
          Hint = 
            '|Select a script then click "Run", or double-click on the script' +
            ' name, or press F9 or Enter.'
          Align = alClient
          Columns = <
            item
              Caption = 'Title'
              Width = 175
            end
            item
              AutoSize = True
              Caption = 'Description'
            end>
          ColumnClick = False
          HideSelection = False
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnCustomDrawItem = lstScriptsCustomDrawItem
          OnDblClick = ActionDebugRunExecute
          OnInfoTip = lstScriptsInfoTip
          OnKeyPress = lstScriptsKeyPress
          OnSelectItem = lstScriptsSelectItem
        end
        object pnlScriptInfo: TPanel
          Left = 0
          Top = 277
          Width = 580
          Height = 105
          Align = alBottom
          BevelOuter = bvNone
          TabOrder = 1
          DesignSize = (
            580
            105)
          object tabScriptInfo: TTabSet
            Left = 0
            Top = 87
            Width = 573
            Height = 21
            Anchors = [akLeft, akRight, akBottom]
            DitherBackground = False
            EndMargin = 15
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Shell Dlg 2'
            Font.Style = []
            StartMargin = 15
            SoftTop = True
            Tabs.Strings = (
              'General'
              'Comments'
              'License')
            TabIndex = 0
            OnChange = tabScriptInfoChange
          end
          object grpScriptInfo: TGroupBox
            Left = 0
            Top = 0
            Width = 573
            Height = 89
            Anchors = [akLeft, akTop, akRight, akBottom]
            Caption = 'Information'
            TabOrder = 0
            object ScrollBox1: TScrollBox
              Left = 2
              Top = 15
              Width = 569
              Height = 72
              HorzScrollBar.Visible = False
              VertScrollBar.Smooth = True
              VertScrollBar.Style = ssHotTrack
              VertScrollBar.Tracking = True
              Align = alClient
              BorderStyle = bsNone
              TabOrder = 0
              object lblScriptInfo: TAntJvLinkLabel
                Left = 4
                Top = -1
                Width = 554
                Height = 91
                Caption = '1<br>'#13#10'2<br>'#13#10'3<br>'#13#10'4<br>'#13#10'5<br>'#13#10'6<br>'#13#10
                Text.Strings = (
                  '1<br>'#13#10'2<br>'#13#10'3<br>'#13#10'4<br>'#13#10'5<br>'#13#10'6<br>'#13#10)
                Transparent = False
                LinkColor = clBlue
                LinkColorClicked = clBlue
                LinkColorHot = clBlue
                LinkStyle = [fsUnderline]
                HotLinks = False
                AutoHeight = True
                MarginWidth = 0
                MarginHeight = 0
                OnLinkClick = lblScriptInfoLinkClick
              end
            end
          end
        end
      end
      object DockScriptLeft: TTBXMultiDock
        Left = 0
        Top = 0
        Width = 7
        Height = 382
        BoundLines = [blTop, blBottom, blLeft, blRight]
        Position = dpLeft
      end
    end
    object shtEditor: TTabSheet
      Caption = 'Editor'
      ImageIndex = 2
      object sbEditor: TTBXStatusBar
        Left = 0
        Top = 360
        Width = 756
        Panels = <
          item
            StretchPriority = 1
            Tag = 0
            TextTruncation = twPathEllipsis
          end
          item
            Alignment = taCenter
            Size = 70
            Tag = 0
          end
          item
            Alignment = taCenter
            Size = 100
            Tag = 0
          end>
        UseSystemFont = False
      end
      object DockEditRight: TTBXMultiDock
        Left = 582
        Top = 7
        Width = 174
        Height = 346
        BoundLines = [blTop, blBottom, blLeft, blRight]
        Position = dpRight
        object DockpanelWatch: TTBXDockablePanel
          Left = 0
          Top = 0
          Caption = 'Watch list'
          CloseButton = False
          CloseButtonWhenDocked = False
          DockedWidth = 168
          DockPos = 0
          HideWhenInactive = False
          SupportedDocks = [dkMultiDock]
          TabOrder = 0
          Visible = False
          object ToolbarWatchBevel: TBevel
            Left = 0
            Top = 21
            Width = 168
            Height = 3
            Align = alTop
            Shape = bsBottomLine
          end
          object lstWatch: TListBox
            Left = 0
            Top = 24
            Width = 168
            Height = 277
            Align = alClient
            BorderStyle = bsNone
            ItemHeight = 13
            ParentColor = True
            Sorted = True
            TabOrder = 1
            OnKeyPress = lstWatchKeyPress
          end
          object ToolbarWatch: TTBXToolbar
            Left = 0
            Top = 0
            Width = 168
            Height = 21
            Align = alTop
            BorderStyle = bsNone
            DockMode = dmCannotFloatOrChangeDocks
            DragHandleStyle = dhNone
            ItemTransparency = itEnable
            TabOrder = 0
            object TBXItem5: TTBXItem
              Action = ActionDebugWatchRemove
              DisplayMode = nbdmImageAndText
            end
            object TBXItem4: TTBXItem
              Action = ActionDebugWatchClear
              DisplayMode = nbdmImageAndText
            end
          end
        end
      end
      object DockEditLeft: TTBXMultiDock
        Left = 0
        Top = 7
        Width = 7
        Height = 346
        BoundLines = [blTop, blBottom, blLeft, blRight]
        Position = dpLeft
      end
      object DockEditBottom: TTBXMultiDock
        Left = 0
        Top = 353
        Width = 756
        Height = 7
        BoundLines = [blTop, blBottom, blLeft, blRight]
        Position = dpBottom
      end
      object DockEditTop: TTBXMultiDock
        Left = 0
        Top = 0
        Width = 756
        Height = 7
        BoundLines = [blTop, blBottom, blLeft, blRight]
      end
      object EScript: TSynEdit
        Left = 7
        Top = 7
        Width = 575
        Height = 346
        Align = alClient
        Color = clWhite
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = MenuPopupEdit
        TabOrder = 0
        BookMarkOptions.DrawBookmarksFirst = False
        BookMarkOptions.EnableKeys = False
        BookMarkOptions.GlyphsVisible = False
        Gutter.AutoSize = True
        Gutter.DigitCount = 3
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -8
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Gutter.LeftOffset = 27
        Gutter.ShowLineNumbers = True
        Gutter.Width = 0
        Highlighter = SynPasSyn1
        Options = [eoAutoIndent, eoAutoSizeMaxScrollWidth, eoDragDropEditing, eoGroupUndo, eoRightMouseMovesCursor, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoTabIndent, eoTabsToSpaces, eoTrimTrailingSpaces]
        SearchEngine = SynEditSearch1
        TabWidth = 2
        WantTabs = True
        OnGutterClick = EScriptGutterClick
        OnGutterPaint = EScriptGutterPaint
        OnSpecialLineColors = EScriptSpecialLineColors
        OnStatusChange = EScriptStatusChange
        RemovedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <
          item
            Command = ecContextHelp
            ShortCut = 16496
          end>
      end
    end
  end
  inherited btn1: TCorelButton
    Left = 684
    Top = 443
    Caption = '&Help'
    TabOrder = 5
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 606
    Top = 443
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 528
    Top = 443
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 450
    Top = 443
    TabOrder = 1
  end
  object TBDock1: TTBXDock
    Left = 0
    Top = 0
    Width = 762
    Height = 25
    LimitToOneRow = True
    object ToolbarEditor: TTBXToolbar
      Left = 123
      Top = 0
      BorderStyle = bsNone
      Caption = 'Editor Toolbar'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      HideWhenInactive = False
      TabOrder = 2
      object MnuEdtRun: TTBXItem
        Action = ActionDebugRun
        DisplayMode = nbdmImageAndText
      end
      object MnuEdtStp: TTBXItem
        Action = ActionDebugStop
        DisplayMode = nbdmImageAndText
      end
      object MnuEdt__1: TTBXSeparatorItem
      end
      object MnuEdtBrk: TTBXItem
        Action = ActionDebugBreakpoint
      end
      object MnuEdtBrc: TTBXItem
        Action = ActionDebugBreakpointClear
      end
      object MnuEdtSte: TTBXItem
        Action = ActionDebugStep
      end
      object MnuEdtRtc: TTBXItem
        Action = ActionDebugRunToCursor
      end
      object MnuEdtEvl: TTBXItem
        Action = ActionDebugEval
      end
      object MnuEdtWch: TTBXItem
        Action = ActionDebugWatchAdd
      end
      object MnuEdt__2: TTBXSeparatorItem
      end
      object MnuEdtNew: TTBXItem
        Action = ActionFileNew
      end
      object MnuEdtOpn: TTBXSubmenuItem
        Action = ActionFileOpen
        DropdownCombo = True
        object MnuEdtRec: TTBXItem
          Action = ActionFileNoRecent
        end
        object TBMRUListItem1: TTBXMRUListItem
          MRUList = TBMRUList1
        end
      end
      object MnuEdtSav: TTBXItem
        Action = ActionFileSave
      end
      object MnuEdtSaa: TTBXItem
        Action = ActionFileSaveAs
      end
      object MnuEdt__3: TTBXSeparatorItem
      end
      object MnuEdtPro: TTBXItem
        Action = ActionFileProperties
        DisplayMode = nbdmImageAndText
      end
      object MnuEdt__4: TTBXSeparatorItem
      end
      object MnuEdtFnd: TTBXItem
        Action = ActionEditFind
      end
      object MnuEdtFnx: TTBXItem
        Action = ActionEditFindNext
      end
    end
    object ToolbarTabs: TTBXToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'Tabs Toolbar'
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = -2
      HideWhenInactive = False
      TabOrder = 0
      object MnuTabScr: TTBXItem
        Action = ActionDisplayScripts
        DisplayMode = nbdmImageAndText
        FontSettings.Bold = tsTrue
      end
      object MnuTabEdt: TTBXItem
        Action = ActionDisplayEditor
        DisplayMode = nbdmImageAndText
        FontSettings.Bold = tsTrue
      end
    end
    object ToolbarScript: TTBXToolbar
      Left = 70
      Top = 0
      BorderStyle = bsNone
      Caption = 'Script Toolbar'
      DockMode = dmCannotFloatOrChangeDocks
      HideWhenInactive = False
      TabOrder = 1
      object MnuScrRun: TTBXItem
        Action = ActionDebugRun
        DisplayMode = nbdmImageAndText
      end
      object MnuScrStp: TTBXItem
        Action = ActionDebugStop
        DisplayMode = nbdmImageAndText
      end
      object TbsRun: TTBXSeparatorItem
      end
      object MnuScrFlt: TTBXSubmenuItem
        Action = ActionViewFilter
        DisplayMode = nbdmImageAndText
        Options = [tboDropdownArrow]
        object MnuFltAll: TTBXItem
          Action = ActionListAll
        end
        object MnuFltNon: TTBXItem
          Action = ActionListNone
        end
        object MnuFlt__1: TTBXSeparatorItem
        end
      end
      object TBXSeparatorItem1: TTBXSeparatorItem
      end
      object MnuScrLst: TTBXItem
        Action = ActionViewList
      end
      object MnuScrDet: TTBXItem
        Action = ActionViewDetailed
      end
    end
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 16
    Top = 64
    object ActionOptionsEdit: TAction
      Category = 'Options'
      Caption = 'Change...'
      Hint = 'Change value...|Change the value of selected option'
      OnExecute = ActionOptionsEditExecute
    end
    object ActionFileNew: TAction
      Category = 'File'
      Caption = 'New'
      Hint = 'New|Create a new script'
      ShortCut = 16462
      OnExecute = ActionFileNewExecute
    end
    object ActionFileOpen: TAction
      Category = 'File'
      Caption = 'Open...'
      Hint = 'Open...|Open a script file'
      ShortCut = 16463
      OnExecute = ActionFileOpenExecute
    end
    object ActionFileSave: TAction
      Category = 'File'
      Caption = 'Save'
      Hint = 'Save|Save current script'
      ShortCut = 16467
      OnExecute = ActionFileSaveExecute
    end
    object ActionFileSaveAs: TAction
      Category = 'File'
      Caption = 'Save as...'
      Hint = 'Save as...|Save current script under a new name'
      ShortCut = 24659
      OnExecute = ActionFileSaveAsExecute
    end
    object ActionDebugRun: TAction
      Category = 'Debug'
      Caption = 'Run'
      Hint = 'Run script|Run script'
      ShortCut = 120
      OnExecute = ActionDebugRunExecute
    end
    object ActionDebugStop: TAction
      Category = 'Debug'
      Caption = 'Stop'
      Enabled = False
      Hint = 'Stop execution|Stop script execution'
      ShortCut = 16497
      OnExecute = ActionDebugStopExecute
    end
    object ActionDisplayScripts: TAction
      Category = 'Display'
      Caption = 'Scripts'
      Checked = True
      GroupIndex = 1
      Hint = 'Select script|Display available scripts'
      OnExecute = ActionDisplayExecute
    end
    object ActionDisplayEditor: TAction
      Tag = 1
      Category = 'Display'
      Caption = 'Editor'
      GroupIndex = 1
      Hint = 'Script editor|Display script editor'
      OnExecute = ActionDisplayExecute
    end
    object ActionFileNoRecent: TAction
      Category = 'File'
      Caption = 'No recent file'
      Enabled = False
      Visible = False
    end
    object ActionEditUndo: TAction
      Category = 'Edit'
      Caption = '&Undo'
      OnExecute = ActionEditUndoExecute
    end
    object ActionEditCut: TAction
      Category = 'Edit'
      Caption = 'Cu&t'
      OnExecute = ActionEditCutExecute
    end
    object ActionEditCopy: TAction
      Category = 'Edit'
      Caption = '&Copy'
      OnExecute = ActionEditCopyExecute
    end
    object ActionEditPaste: TAction
      Category = 'Edit'
      Caption = '&Paste'
      OnExecute = ActionEditPasteExecute
    end
    object ActionEditDelete: TAction
      Category = 'Edit'
      Caption = '&Delete'
      OnExecute = ActionEditDeleteExecute
    end
    object ActionEditSelectAll: TAction
      Category = 'Edit'
      Caption = 'Select &All'
      OnExecute = ActionEditSelectAllExecute
    end
    object ActionListCheck: TAction
      Category = 'Filter'
      Caption = '&Check selected'
      Hint = 'Check selected|Check selected items'
      OnExecute = ActionListCheckExecute
    end
    object ActionListUncheck: TAction
      Category = 'Filter'
      Caption = '&Uncheck selected'
      Hint = 'Uncheck selected|Uncheck selected items'
      OnExecute = ActionListCheckExecute
    end
    object ActionListAll: TAction
      Category = 'Filter'
      Caption = 'Check &all'
      Hint = 'Check all|Check all items'
      OnExecute = ActionListAllExecute
    end
    object ActionListNone: TAction
      Category = 'Filter'
      Caption = 'Check &none'
      Hint = 'Uncheck all|Uncheck all items'
      OnExecute = ActionListAllExecute
    end
    object ActionEditFind: TAction
      Category = 'Edit'
      Caption = 'Find...'
      Hint = 'Find...|Find a string in the text'
      ShortCut = 16454
      OnExecute = ActionEditFindExecute
    end
    object ActionEditFindNext: TAction
      Category = 'Edit'
      Caption = 'Find next'
      Hint = 'Find next|Find next matching string in the text'
      ShortCut = 114
      OnExecute = ActionEditFindNextExecute
    end
    object ActionViewFilter: TAction
      Category = 'Display'
      Caption = '&Language filter'
      Hint = 
        'Language filter|Filter that allows you to hide scripts getting i' +
        'nfo in specified languages'
      OnExecute = ActionViewFilterExecute
    end
    object ActionViewFilterChange: TAction
      Category = 'Display'
      OnExecute = ActionViewFilterChangeExecute
    end
    object ActionFileProperties: TAction
      Category = 'File'
      Caption = 'Properties...'
      Hint = 'Properties and options...|Edit script properties and options'
      OnExecute = ActionFilePropertiesExecute
    end
    object ActionViewList: TAction
      Category = 'Display'
      AutoCheck = True
      Caption = 'List'
      GroupIndex = 2
      Hint = 'List view|Display the scripts as a list'
      OnExecute = ActionViewListExecute
    end
    object ActionViewDetailed: TAction
      Category = 'Display'
      AutoCheck = True
      Caption = 'Detailed'
      GroupIndex = 2
      Hint = 
        'Detailed view|Display the scripts in two columns (with their des' +
        'cription)'
      OnExecute = ActionViewListExecute
    end
    object ActionOptionsDefault: TAction
      Category = 'Options'
      Caption = 'Default values'
      Hint = 'Default values|Revert options to their default values'
      OnExecute = ActionOptionsDefaultExecute
    end
    object ActionDebugBreakpoint: TAction
      Category = 'Debug'
      Caption = 'Breakpoint'
      Hint = 'Toggle breakpoint|Enable or disable breakpoint at current line'
      ShortCut = 116
      OnExecute = ActionDebugBreakpointExecute
    end
    object ActionDebugBreakpointClear: TAction
      Category = 'Debug'
      Caption = 'Clear breakpoints'
      Hint = 'Clear breakpoints|Remove all breakpoints'
      OnExecute = ActionDebugBreakpointClearExecute
    end
    object ActionDebugStep: TAction
      Category = 'Debug'
      Caption = 'Step over'
      Hint = 'Step over|Run next line of source code'
      ShortCut = 119
      OnExecute = ActionDebugStepExecute
    end
    object ActionDebugRunToCursor: TAction
      Category = 'Debug'
      Caption = 'Run to cursor'
      Hint = 
        'Run to cursor|Run the program until it reaches the current carre' +
        't position'
      ShortCut = 115
      OnExecute = ActionDebugRunExecute
    end
    object ActionDebugEval: TAction
      Category = 'Debug'
      Caption = 'Evaluate...'
      Hint = 'Evaluate variable...|Show the content of the selected variable'
      ShortCut = 16502
      OnExecute = ActionDebugEvalExecute
    end
    object ActionDebugWatchAdd: TAction
      Category = 'Debug'
      Caption = 'Add watch'
      Hint = 'Add variable watch|Add selected variable to watch list'
      ShortCut = 16500
      OnExecute = ActionDebugWatchAddExecute
    end
    object ActionDebugWatchRemove: TAction
      Category = 'Debug'
      Caption = 'Remove'
      Hint = 'Remove variable watch|Remove selected variable from watch list'
      OnExecute = ActionDebugWatchRemoveExecute
    end
    object ActionDebugWatchClear: TAction
      Category = 'Debug'
      Caption = 'Clear list'
      Hint = 'Clear variable watch list|Remove all variables from watch list'
      OnExecute = ActionDebugWatchClearExecute
    end
    object ActionFileCopy: TAction
      Category = 'File'
      Caption = 'Export'
      Hint = 
        'Export/copy to clipboard|Export the whole script (including prop' +
        'erties) to the clipboard'
    end
    object ActionFilePaste: TAction
      Category = 'File'
      Caption = 'Import'
      Hint = 
        'Import/paste from clipboard|Import the whole script (including p' +
        'roperties) from the clipboard'
    end
    object ActionParametersEdit: TAction
      Category = 'Parameters'
      Caption = 'Change...'
      Hint = 'Change value...|Change the value of selected parameter'
      OnExecute = ActionParametersEditExecute
    end
    object ActionParametersDefault: TAction
      Category = 'Parameters'
      Caption = 'Default values'
      Hint = 'Default values|Revert parameters to their default values'
      OnExecute = ActionParametersDefaultExecute
    end
  end
  object TBMRUList1: TTBXMRUList
    HidePathExtension = False
    MaxItems = 9
    OnClick = TBMRUList1Click
    Prefix = 'MRU'
    Left = 16
    Top = 96
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Script error in "%s": %s at line %d'
      'Current script has been modified. Do you want to save it?'
      'unknown'
      'I agree'
      'No movie found for current script limitation settings (%s: %s)'
      'Do you want to abort script batch process?'
      'Modified'
      'Value for option "%s"'
      'Value for parameter "%s"'
      'Find'
      'Enter the text to find:'
      'No more matches for "%s"'
      '*Add extras*'
      '*Delete extras*'
      '*Modify extras*')
    Left = 16
    Top = 128
  end
  object http: TIdHTTP
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.ContentType = '*/*'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/5.0 (compatible; Ant Movie Catalog)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = []
    Left = 16
    Top = 176
  end
  object SynPasSyn1: TSynPasSyn
    CommentAttri.Foreground = clGreen
    NumberAttri.Foreground = clBlue
    FloatAttri.Foreground = clTeal
    HexAttri.Foreground = clPurple
    StringAttri.Foreground = clNavy
    StringAttri.Style = [fsItalic]
    Left = 16
    Top = 232
  end
  object MenuPopupEdit: TTBXPopupMenu
    Left = 48
    Top = 232
    object MnuEdpUnd: TTBXItem
      Action = ActionEditUndo
    end
    object MnuEdp__1: TTBXSeparatorItem
    end
    object MnuEdpCut: TTBXItem
      Action = ActionEditCut
    end
    object MnuEdpCpy: TTBXItem
      Action = ActionEditCopy
    end
    object MnuEdpPst: TTBXItem
      Action = ActionEditPaste
    end
    object MnuEdpDel: TTBXItem
      Action = ActionEditDelete
    end
    object MnuEdp__2: TTBXSeparatorItem
    end
    object MnuEdpAll: TTBXItem
      Action = ActionEditSelectAll
    end
  end
  object MenuPopupOptions: TTBXPopupMenu
    Left = 114
    Top = 236
    object MnuOppEdt: TTBXItem
      Action = ActionOptionsEdit
    end
    object MnuOpp__1: TTBXSeparatorItem
    end
    object MnuOppDef: TTBXItem
      Action = ActionOptionsDefault
    end
  end
  object SynEditSearch1: TSynEditSearch
    Left = 19
    Top = 260
  end
  object lstDebugImages: TImageList
    Height = 17
    Width = 27
    Left = 51
    Top = 276
    Bitmap = {
      494C01010700090004001B001100FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      00000000000036000000280000006C0000003300000001002000000000001056
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF0000FF00000000
      FF000000FF000000FF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF0000FF000000FF000000FF00000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FF000000FF000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000008400000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF0000FF
      000000FF000000FF000000FF000000FF00000000000000000000000000000000
      00000000000000000000000000000000000000FF000000FF00000000FF0000FF
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000FFFF0000FF000000FF000000FF000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FF000000FF000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000084000000FF00
      0000FF0000008400000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FF000000FF000000FF000000FF000000FF
      000000FFFF000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF0000FF000000FF00000000FF000000FF000000
      0000000000000000000000000000000000000000000000FFFF0000FF000000FF
      000000FF000000FF000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FF000000FF000000FF000000FF000000FF000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFF0000FF000000FF00000084000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000FF00000000FF000000FF00000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FF
      FF0000FF000000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF0000FF000000FF00000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF0000FF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF000000FF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF0000FF00000000FF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF0000FF000000FF000000FF
      00000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF0000FFFF000000FF000000FF000000FF0000FFFF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF000000FF00000000FF0000FF00000000FF000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF0000FFFF0000FFFF000000FF0000FF
      FF0000FFFF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF0000FF
      000000FF00000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF0000FFFF0000FFFF0000FFFF000000FF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000084000000FF000000FF000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF000000FF0000FF00000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF0000FFFF0000FFFF000000FF0000FF
      FF0000FFFF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FF000000FF00000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF000000FF000000FF000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000FF000000FF00000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF0000FFFF000000FF000000FF000000FF0000FFFF000000FF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600FFFF000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF000000FF000000FF0000FF0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000424D3E000000000000003E000000280000006C0000003300000001000100
      00000000300300000000000000000000000000000000000000000000FFFFFF00
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFF800000000000
      FFFFFFFFFFFFFFFFFFFF800000000000FFFFFFFFFFFFFFFFFFFF800000000000
      FFFFF7FFFFFEFFFFFFDF800000000000FFFFF3FF83FE7FFFFFCF800000000000
      FFFFF1FF01FE3FFFFFC7800000000000FFFF80FE00F01FFFFE03800000000000
      FE7F807E00F00FFFFE01800000000000FC3F803E00F007FFFE00800000000000
      FC3F807E00F00FFFFE01800000000000FC7F80FE00F01FFFFE03800000000000
      FFFFF1FF01FE3FFFFFC7800000000000FFFFF3FF80FE7FFFFFCF800000000000
      FFFFF7FFF9FEFFFFFFDF800000000000FFFFFFFFFFFFFFFFFFFF800000000000
      FFFFFFFFFFFFFFFFFFFF800000000000FFFFFFFFFFFFFFFFFFFF800000000000
      FFFFFFFFFFFFFFFFFFFFFFFFFFF00000FFFFFFFFFFFFFFFFFFFFFFFFFFF00000
      FFFFFFFFFFFFFFFFFFFFFFFFFFF00000FFFFFFFFFFFFFFFFFFFFFFFFFFF00000
      FC1FFFFF83FFFFF07FFFFFFFFFF00000F80FFFFF01FFFFE03FFFFFFFFFF00000
      F007FFFE00FFFFC01FFFFFFFFFF00000F007FFFE00FFFFC01FFFFF3FFFF00000
      F007FFFE00FFFFC01FFFFE1FFFF00000F007FFFE00FFFFC01FFFFE1FFFF00000
      F007FFFE00FFFFC01FFFFE3FFFF00000F80FFFFF01FFFFE03FFFFFFFFFF00000
      FC1FFFFF80FFFFF07FFFFFFFFFF00000FFFFFFFFF9FFFFFFFFFFFFFFFFF00000
      FFFFFFFFFFFFFFFFFFFFFFFFFFF00000FFFFFFFFFFFFFFFFFFFFFFFFFFF00000
      FFFFFFFFFFFFFFFFFFFFFFFFFFF0000000000000000000000000000000000000
      000000000000}
  end
  object MenuPopupDebug: TTBXPopupMenu
    Left = 91
    Top = 268
    object MnuDbpEvl: TTBXItem
      Action = ActionDebugEval
    end
    object MnuDbpWch: TTBXItem
      Action = ActionDebugWatchAdd
    end
    object MnuDbp__1: TTBXSeparatorItem
    end
    object MnuDbpSte: TTBXItem
      Action = ActionDebugStep
    end
    object MnuDbpRtc: TTBXItem
      Action = ActionDebugRunToCursor
    end
    object MnuDbp__2: TTBXSeparatorItem
    end
    object MnuDbpBrk: TTBXItem
      Action = ActionDebugBreakpoint
    end
  end
  object MenuPopupParameters: TTBXPopupMenu
    Left = 114
    Top = 236
    object MnuParEdt: TTBXItem
      Action = ActionParametersEdit
    end
    object MnuPar__1: TTBXSeparatorItem
    end
    object MnuParDef: TTBXItem
      Action = ActionParametersDefault
    end
  end
  object MenuPopupList: TTBXPopupMenu
    Left = 376
    Top = 240
    object MnuLspChk: TTBXItem
      Action = ActionListCheck
    end
    object MnuLspUnc: TTBXItem
      Action = ActionListUncheck
    end
    object MnuLsp__1: TTBXSeparatorItem
    end
    object MnuLspAll: TTBXItem
      Action = ActionListAll
    end
    object MnuLspNone: TTBXItem
      Action = ActionListNone
    end
  end
end
