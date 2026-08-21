inherited LoanWin: TLoanWin
  Left = 523
  Top = 262
  HelpContext = 1040
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Loans'
  ClientHeight = 484
  ClientWidth = 663
  Constraints.MinHeight = 400
  Constraints.MinWidth = 550
  OldCreateOrder = True
  OnDestroy = FormDestroy
  DesignSize = (
    663
    484)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 451
    Width = 657
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 468
    Width = 663
  end
  inherited btn1: TCorelButton
    Left = 585
    Top = 456
    Caption = '&Help'
    TabOrder = 5
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 507
    Top = 456
    Cancel = True
    Caption = 'Close'
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 429
    Top = 456
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 351
    Top = 456
    TabOrder = 1
  end
  object PanelMain: TPanel
    Left = 0
    Top = 26
    Width = 663
    Height = 422
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter2: TSplitter
      Left = 0
      Top = 284
      Width = 663
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      AutoSnap = False
      ResizeStyle = rsUpdate
    end
    object Panel3: TPanel
      Left = 0
      Top = 287
      Width = 663
      Height = 135
      Align = alBottom
      BevelOuter = bvNone
      Constraints.MinHeight = 50
      TabOrder = 1
      object Splitter1: TSplitter
        Left = 236
        Top = 0
        Height = 135
        AutoSnap = False
        ResizeStyle = rsUpdate
      end
      object LvNames: TElTree
        Left = 0
        Top = 0
        Width = 236
        Height = 135
        Cursor = crDefault
        LeftPosition = 0
        Align = alLeft
        AlwaysKeepSelection = False
        AutoResizeColumns = False
        Constraints.MinWidth = 150
        DockOrientation = doNoOrient
        ChangeDelay = 0
        DragCursor = crDrag
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Shell Dlg'
        Font.Style = []
        HeaderHeight = 19
        HeaderHotTrack = False
        HeaderInvertSortArrows = True
        HeaderSections.Data = {
          F6FFFFFF020000006174610000006C6CFFFFFFFF0000010100000000AA000000
          00000000102700000101000A60CCEB0600000000000073200000000000000143
          000000000000000000010000050000004E616D65000100000000000000000000
          00006174610000006C6CFFFFFFFF000001010000000041000000000000001027
          00000001020A9CBA180701000000020073200000000000000143000000000000
          000000010000090000005175616E746974790001000000000000000000000000}
        HeaderFlat = True
        HorzScrollBarStyles.Flat = False
        HorzScrollBarStyles.Width = 17
        HorzScrollBarStyles.ButtonSize = 17
        IncrementalSearch = False
        ItemIndent = 12
        LineHeight = 15
        MultiSelect = False
        OwnerDrawMask = '~~@~~'
        PopupMenu = TBPopupMenu2
        RowHotTrack = True
        ScrollbarOpposite = False
        ScrollTracking = True
        ShowColumns = True
        ShowRootButtons = True
        SortMode = smAddClick
        SortType = stCustom
        TabOrder = 0
        TabStop = True
        TrackColor = clWindowText
        VertScrollBarStyles.Flat = False
        VertScrollBarStyles.ShowTrackHint = True
        VertScrollBarStyles.Width = 17
        VertScrollBarStyles.ButtonSize = 17
        OnResize = LvNamesResize
        OnCompareItems = LvNamesCompareItems
        OnItemSelectedChange = LvNamesItemSelectedChange
      end
      object LvLent: TElTree
        Left = 239
        Top = 0
        Width = 424
        Height = 135
        Cursor = crDefault
        LeftPosition = 0
        Align = alClient
        AlwaysKeepSelection = False
        AutoResizeColumns = False
        Constraints.MinWidth = 150
        DockOrientation = doNoOrient
        ChangeDelay = 0
        DragCursor = crDrag
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Shell Dlg'
        Font.Style = []
        HeaderHeight = 19
        HeaderHotTrack = False
        HeaderInvertSortArrows = True
        HeaderSections.Data = {
          F6FFFFFF030000006174610000006C6CFFFFFFFF000001010000000028000000
          00000000102700000101020B68291807000000000200410B000000000000010B
          000000000000000000010000030000004E720001000000000000000000000000
          6174610000006C6CFFFFFFFF0000010100000000640000000000000010270000
          0001000BB429F806010000000000410B000000000000010B0000000000000000
          00010000060000004C6162656C00010000000000000000000000006174610000
          006C6CFFFFFFFF0000010101000000C800000000000000102700000001000B6C
          352006020000000000410B000000000000010B00000000000000000001000006
          0000005469746C650001000000000000000000000000}
        HeaderFlat = True
        HorzScrollBarStyles.Flat = False
        HorzScrollBarStyles.Width = 17
        HorzScrollBarStyles.ButtonSize = 17
        IncrementalSearch = False
        ItemIndent = 12
        LineHeight = 15
        MainTreeColumn = 1
        OwnerDrawMask = '~~@~~'
        PopupMenu = TBPopupMenu3
        RowHotTrack = True
        ScrollbarOpposite = False
        ScrollTracking = True
        ShowColumns = True
        ShowRootButtons = True
        SortMode = smAddClick
        SortType = stCustom
        TabOrder = 1
        TabStop = True
        TrackColor = clWindowText
        VertScrollBarStyles.Flat = False
        VertScrollBarStyles.ShowTrackHint = True
        VertScrollBarStyles.Width = 17
        VertScrollBarStyles.ButtonSize = 17
        OnResize = LvLentResize
        OnCompareItems = LvLentCompareItems
        OnDblClick = ActionCheckInExecute
      end
    end
    object LvMovies: TElTree
      Left = 0
      Top = 0
      Width = 663
      Height = 284
      Cursor = crDefault
      LeftPosition = 0
      Align = alClient
      AlwaysKeepSelection = False
      AutoResizeColumns = False
      Constraints.MinHeight = 150
      DockOrientation = doNoOrient
      ChangeDelay = 0
      DragCursor = crDrag
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Shell Dlg'
      Font.Style = []
      HeaderHeight = 19
      HeaderHotTrack = False
      HeaderInvertSortArrows = True
      HeaderSections.Data = {
        F6FFFFFF040000006174610000006C6CFFFFFFFF000001010000000028000000
        00000000102700000101020B3403CE06000000000200410B000000000000010B
        000000000000000000010000030000004E720001000000000000000000000000
        6174610000006C6CFFFFFFFF0000010101000000640000000000000010270000
        0001000B90C34F04010000000000410B000000000000010B0000000000000000
        00010000060000004C6162656C00010000000000000000000000006174610000
        006C6CFFFFFFFF0000010100000000FA00000000000000102700000001000B20
        F5D506020000000000410B000000000000010B00000000000000000001000006
        0000005469746C6500010000000000000000000000006174610000006C6CFFFF
        FFFF00000101000000009600000000000000102700000001000BD4DE1E060300
        00000000410B000000000000010B0000000000000000000100000A0000004C6F
        616E656420746F0001000000000000000000000000}
      HeaderFlat = True
      HorzScrollBarStyles.Flat = False
      HorzScrollBarStyles.Width = 17
      HorzScrollBarStyles.ButtonSize = 17
      IncrementalSearch = False
      ItemIndent = 12
      LineHeight = 15
      MainTreeColumn = 1
      OwnerDrawMask = '~~@~~'
      PopupMenu = TBPopupMenu1
      RowHotTrack = True
      ScrollbarOpposite = False
      ScrollTracking = True
      ShowColumns = True
      ShowRootButtons = True
      SortMode = smAddClick
      SortType = stCustom
      TabOrder = 0
      TabStop = True
      TrackColor = clWindowText
      VertScrollBarStyles.Flat = False
      VertScrollBarStyles.SecondaryButtons = True
      VertScrollBarStyles.SecondBtnKind = sbkPage
      VertScrollBarStyles.ShowTrackHint = True
      VertScrollBarStyles.Width = 17
      VertScrollBarStyles.ButtonSize = 17
      OnHeaderColumnResize = LvMoviesHeaderColumnResize
      OnResize = LvMoviesResize
      OnCompareItems = LvMoviesCompareItems
      OnDblClick = ActionCheckOutExecute
    end
  end
  object TBDock1: TTBXDock
    Left = 0
    Top = 0
    Width = 663
    Height = 25
    FixAlign = True
    object ToolbarLoans: TTBXToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'Loans Toolbar'
      DefaultDock = TBDock1
      DockMode = dmCannotFloatOrChangeDocks
      ProcessShortCuts = True
      TabOrder = 0
      object TBItem2: TTBXItem
        Action = ActionBorrowerAdd
      end
      object TBItem1: TTBXItem
        Action = ActionBorrowerDel
      end
      object TBSeparatorItem1: TTBXSeparatorItem
      end
      object TBXItem6: TTBXItem
        Action = ActionCheckIn
        DisplayMode = nbdmImageAndText
      end
      object TBXItem5: TTBXItem
        Action = ActionCheckOut
        DisplayMode = nbdmImageAndText
      end
      object TBXSubmenuItem1: TTBXSubmenuItem
        Action = ActionOptions
        DisplayMode = nbdmImageAndText
        Options = [tboDropdownArrow]
        object TBXItem2: TTBXItem
          Action = ActionOptionsIncNum
        end
        object TBXItem1: TTBXItem
          Action = ActionOptionsIncLab
        end
      end
      object TBSeparatorItem2: TTBXSeparatorItem
      end
      object TBControlItem1: TTBControlItem
        Control = EFindValue
      end
      object TBItem5: TTBXItem
        Action = ActionMovieFindNext
      end
      object TBItem7: TTBXItem
        Action = ActionMovieGetBorrower
      end
      object EFindValue: TEdit
        Left = 276
        Top = 0
        Width = 121
        Height = 21
        BevelInner = bvLowered
        BevelKind = bkTile
        BevelOuter = bvSpace
        BorderStyle = bsNone
        TabOrder = 0
        OnKeyPress = EFindValueKeyPress
      end
    end
  end
  object ActionList1: TActionList
    OnUpdate = ActionList1Update
    Left = 72
    Top = 352
    object ActionBorrowerAdd: TAction
      Category = 'Borrower'
      Caption = 'Add...'
      Hint = 'Add borrower|Add a new borrower to the list'
      ShortCut = 32813
      OnExecute = ActionBorrowerAddExecute
    end
    object ActionBorrowerDel: TAction
      Category = 'Borrower'
      Caption = 'Delete'
      Enabled = False
      Hint = 'Delete borrower|Delete selected borrower from the list'
      ShortCut = 32814
      OnExecute = ActionBorrowerDelExecute
    end
    object ActionCheckOut: TAction
      Category = 'Movie'
      Caption = 'Check &out'
      Enabled = False
      Hint = 'Check out|Add selected movie to borrower'#39's list'
      ShortCut = 16463
      OnExecute = ActionCheckOutExecute
    end
    object ActionCheckIn: TAction
      Category = 'Movie'
      Caption = 'Check &in'
      Enabled = False
      Hint = 'Check in|Remove selected movie from borrower'#39's list'
      ShortCut = 16457
      OnExecute = ActionCheckInExecute
    end
    object ActionMovieGetBorrower: TAction
      Category = 'Movie'
      Caption = 'Get borrower'
      Enabled = False
      Hint = 
        'Get borrower|Find, in the borrowers list, the borrower or select' +
        'ed movie'
      ShortCut = 16455
      OnExecute = ActionMovieGetBorrowerExecute
    end
    object ActionMovieFindNext: TAction
      Category = 'Movie'
      Caption = 'Find next'
      Hint = 
        'Find next|Find the next movie with a title containing specified ' +
        'text'
      ShortCut = 114
      OnExecute = ActionMovieFindNextExecute
    end
    object ActionMovieFind: TAction
      Category = 'Movie'
      Caption = 'Find'
      ShortCut = 16454
      OnExecute = ActionMovieFindExecute
    end
    object ActionOptions: TAction
      Category = 'Options'
      Caption = '&Options'
      Hint = 'Options|Options for check in and check out'
      OnExecute = ActionOptionsExecute
    end
    object ActionOptionsIncNum: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Include movies with same &number'
      Hint = 
        'Include movies with same number|Include in check in and check ou' +
        't other movies that have the same number than the selected one'
      OnExecute = ActionOptionsExecute
    end
    object ActionOptionsIncLab: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Include movies with same &label'
      Hint = 
        'Include movies with same label|Include in check in and check out' +
        ' other movies that have the same media label than the selected o' +
        'ne'
      OnExecute = ActionOptionsExecute
    end
  end
  object TBPopupMenu1: TTBXPopupMenu
    Left = 128
    Top = 88
    object Findborrower1: TTBXItem
      Action = ActionMovieGetBorrower
    end
    object N1: TTBXSeparatorItem
    end
    object Checkout1: TTBXItem
      Action = ActionCheckOut
    end
  end
  object TBPopupMenu2: TTBXPopupMenu
    Left = 136
    Top = 264
    object Addborrower1: TTBXItem
      Action = ActionBorrowerAdd
    end
    object Deleteborrower1: TTBXItem
      Action = ActionBorrowerDel
    end
  end
  object TBPopupMenu3: TTBXPopupMenu
    Left = 304
    Top = 256
    object Checkin1: TTBXItem
      Action = ActionCheckIn
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      
        'This will delete "%s" from the borrowers list, and check in all ' +
        'the movies lent to this person.'
      'Loading list...'
      'This movie is already lent to somebody else'
      'Please enter a name'
      'The following movies are already lent to somebody else:'
      ''
      'Enter a name'
      'New borrower')
    Left = 104
    Top = 352
  end
end
