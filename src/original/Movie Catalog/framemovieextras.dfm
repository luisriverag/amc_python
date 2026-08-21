object MovieFrameExtras: TMovieFrameExtras
  Left = 0
  Top = 0
  Width = 200
  Height = 500
  TabOrder = 0
  object MinusPicture: TImage
    Left = 8
    Top = 5
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D6170CE000000424DCE0000000000000076000000280000001000
      000010000000010004000200000058000000230B0000230B0000100000001000
      0000202020005469D6007485DE0092A0E600FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000104400001044000010440000104400001044000010440000104400000010
      4444000000044444000000104444022123044444000000104444000000044444
      0000104400001044000010440000104400001044000010440001}
    Transparent = True
    Visible = False
  end
  object PlusPicture: TImage
    Left = 26
    Top = 5
    Width = 16
    Height = 16
    Picture.Data = {
      07544269746D6170EE000000424DEE0000000000000076000000280000001000
      000010000000010004000200000078000000230B0000230B0000100000001000
      0000202020003B3B3B00268718004CCE3A0064D6540080DD74009BE59200FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000107700001077000010770000107700001077000000107777770007777777
      0000001077777706077777770000001077770025200777770000001077770554
      5607777700000010777700232007777700000010777777051777777700000010
      7777770007777777000010770000107700001077000010770001}
    Transparent = True
    Visible = False
  end
  object PanelMovieExtras: TPanel
    Left = 0
    Top = 0
    Width = 200
    Height = 500
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object PanelThumbs: TPanel
      Left = 0
      Top = 25
      Width = 200
      Height = 475
      Align = alClient
      BevelOuter = bvNone
      Color = clWindow
      TabOrder = 0
      object PanelThumbsBottom: TPanel
        Left = 0
        Top = 453
        Width = 200
        Height = 22
        Align = alBottom
        BevelOuter = bvNone
        Color = clWindow
        Ctl3D = True
        ParentCtl3D = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 0
        DesignSize = (
          200
          22)
        object ThumbsProgress: TProgressBar
          Left = 111
          Top = 3
          Width = 86
          Height = 17
          Anchors = [akRight, akBottom]
          Max = 10
          ParentShowHint = False
          Step = 1
          ShowHint = False
          TabOrder = 1
          Visible = False
        end
        object ThumbsSizer: TTrackBar
          Left = -4
          Top = -3
          Width = 93
          Height = 25
          Hint = '|Change size of pictures'
          Anchors = [akLeft, akBottom]
          DragKind = dkDock
          Max = 16
          Min = 3
          ParentShowHint = False
          PageSize = 1
          Frequency = 16
          Position = 3
          ShowHint = False
          TabOrder = 0
          TabStop = False
          ThumbLength = 25
          TickMarks = tmTopLeft
          TickStyle = tsNone
          OnChange = ThumbsSizerChange
        end
        object ThumbsDisplayTitle: TCheckBox
          Left = 86
          Top = 3
          Width = 56
          Height = 17
          Hint = '|Display extra title'
          TabStop = False
          Caption = 'Title'
          TabOrder = 2
          OnClick = ThumbsDisplayTitleClick
        end
        object ThumbsDisplayInfo: TCheckBox
          Left = 142
          Top = 3
          Width = 56
          Height = 17
          Hint = '|Display extra info'
          TabStop = False
          Caption = 'Info'
          TabOrder = 3
          OnClick = ThumbsDisplayInfoClick
        end
      end
      object ThumbsViewer: TrkSmartView
        Left = 0
        Top = 0
        Width = 200
        Height = 453
        Align = alClient
        BorderStyle = bsNone
        HotTracking = True
        ShowHint = False
        TabOrder = 1
        TabStop = True
        OnResize = ThumbsViewerResize
        OnMouseUp = ThumbsViewerMouseUp
        OnMouseMove = ThumbsViewerMouseMove
        OnDblClick = ThumbsViewerDblClick
        OnKeyDown = ThumbsViewerKeyDown
        OnKeyUp = ThumbsViewerKeyUp
        OnSelecting = ThumbsViewerSelecting
        OnCellSelectedChange = ThumbsViewerCellSelectedChange
        OnCellFocusedChange = ThumbsViewerCellFocusedChange
        OnCellHit = ThumbsViewerCellHit
        OnHeaderPaint = ThumbsViewerHeaderPaint
        OnHeaderClick = ThumbsViewerHeaderClick
        OnCellPaint = ThumbsViewerCellPaint
        OnDividerExpandedChange = ThumbsViewerDividerExpandedChange
        OnDividerHit = ThumbsViewerDividerHit
        OnDividerPaint = ThumbsViewerDividerPaint
        CellOffset = 4
        CellSpace = 4
        DividerHeight = 20
        MultipleSelection = True
        ColorSel = 16750899
        ColorLines = clWindow
      end
    end
    object DockExtrasTop: TTBXDock
      Left = 0
      Top = 0
      Width = 200
      Height = 25
      OnRequestDock = DockExtrasTopRequestDock
      object ToolbarExtras: TTBXToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'Extras Toolbar'
        DefaultDock = DockExtrasTop
        DockMode = dmCannotFloatOrChangeDocks
        HideWhenInactive = False
        TabOrder = 0
        object TBItemExtrasImportFiles: TTBXItem
          Action = ActionExtrasImportFiles
        end
        object TBItemExtrasAdd: TTBXItem
          Action = ActionExtrasAdd
        end
        object TBItemExtrasEdit: TTBXItem
          Action = ActionExtrasEdit
        end
        object TBItemExtrasDelete: TTBXItem
          Action = ActionExtrasDelete
        end
        object TBSeparatorExtra: TTBXSeparatorItem
        end
        object TBItemExtraShowPic: TTBXItem
          Action = ActionExtraShowPic
        end
        object TBItemExtraURL: TTBXSubmenuItem
          Action = ActionExtraURL
          Options = [tboDropdownArrow]
          object TBItemURLOpen: TTBXItem
            Action = ActionURLOpen
          end
          object TBItemURLExplore: TTBXItem
            Action = ActionURLExplore
          end
          object TBItemURLCopy: TTBXItem
            Action = ActionURLCopy
          end
          object TBItemURLBrowse: TTBXItem
            Action = ActionURLBrowse
          end
        end
        object TBSeparatorCopy: TTBXSeparatorItem
        end
        object TBItemExtraCopy: TTBXItem
          Action = ActionExtrasCopy
        end
        object TBItemExtraPaste: TTBXItem
          Action = ActionExtrasPaste
        end
        object TBSeparatorTools: TTBSeparatorItem
        end
        object TBItemExtrasRenumber: TTBXItem
          Action = ActionExtrasRenumber
        end
      end
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Are you sure you want to delete selected extras ?'
      'Do not ask confirmation again'
      '|Sort by %s'
      '|Group by %s'
      '< none >'
      'File "%s" doesn'#39't exist.'
      'Get information from files...'
      'Select a file to reference in the URL field'
      'Unable to use this picture: %s'
      'Select files to get information from'
      'Number / Tag:'
      'Title:'
      'Category:'
      'URL:'
      'Description:'
      'Comments:'
      'Created by:'
      'Nu:'
      'Ti:'
      'Ca:'
      'UR:'
      'De:'
      'Co:'
      'Cr:')
    Left = 24
    Top = 64
  end
  object ActionList1: TActionList
    Left = 24
    Top = 128
    object ActionExtrasImportFiles: TAction
      Category = 'Extras'
      Caption = '&Import...'
      Hint = 'Import...|Import new extras from files'
      ShortCut = 24694
      OnExecute = ActionExtrasImportFilesExecute
    end
    object ActionExtrasAdd: TAction
      Category = 'Extras'
      Caption = '&Add...'
      Hint = 'Add...|Add a new extra'
      OnExecute = ActionExtrasAddExecute
    end
    object ActionExtrasDelete: TAction
      Category = 'Extras'
      Caption = '&Delete'
      Hint = 'Delete|Delete selected extras'
      OnExecute = ActionExtrasDeleteExecute
    end
    object ActionExtrasEdit: TAction
      Category = 'Extras'
      Caption = '&Edit...'
      Hint = 'Edit...|Edit selected extras'
      OnExecute = ActionExtrasEditExecute
    end
    object ActionExtraShowPic: TAction
      Category = 'Extras'
      Caption = '&Show picture'
      Hint = 'Show picture|Show selected extra picture'
      OnExecute = ActionExtraShowPicExecute
    end
    object ActionExtraURL: TAction
      Category = 'Extras'
      Caption = '&URL'
      Hint = 'URL|Extra URL'
      OnExecute = ActionExtraURLExecute
    end
    object ActionURLOpen: TAction
      Category = 'URL'
      Caption = 'Open URL'
      Hint = '|Open the URL or file specified in the field'
      OnExecute = ActionURLOpenExecute
    end
    object ActionURLBrowse: TAction
      Category = 'URL'
      Caption = 'Browse...'
      Hint = '|Browse for a file name to put in the field'
      OnExecute = ActionURLBrowseExecute
    end
    object ActionURLCopy: TAction
      Category = 'URL'
      Caption = 'Copy URL'
      Hint = '|Copy the URL or file specified in the field'
      OnExecute = ActionURLCopyExecute
    end
    object ActionURLExplore: TAction
      Category = 'URL'
      Caption = 'Explore URL'
      Hint = '|Open the folder containing the file specified in the field'
      OnExecute = ActionURLExploreExecute
    end
    object ActionExtrasCopy: TAction
      Category = 'Extras'
      Caption = '&Copy'
      Hint = 'Copy|Copy selected extras'
      OnExecute = ActionExtrasCopyExecute
    end
    object ActionExtrasPaste: TAction
      Category = 'Extras'
      Caption = '&Paste'
      Hint = 'Paste|Paste extras'
      OnExecute = ActionExtrasPasteExecute
    end
    object ActionExtrasCheck: TAction
      Category = 'Extras'
      Caption = 'Check'
      Hint = 'Check extras|Check selected extras'
      OnExecute = ActionExtrasCheckExecute
    end
    object ActionExtrasUncheck: TAction
      Category = 'Extras'
      Caption = 'Uncheck'
      Hint = 'Uncheck extras|Uncheck selected extras'
      OnExecute = ActionExtrasUncheckExecute
    end
    object ActionExtrasSelCheck: TAction
      Category = 'Extras'
      Caption = 'Checked'
      Hint = 'Select checked|Select only extras that are checked'
      OnExecute = ActionExtrasSelCheckExecute
    end
    object ActionExtrasSelUncheck: TAction
      Category = 'Extras'
      Caption = 'Unchecked'
      Hint = 'Select unchecked|Select only extras that are unchecked'
      OnExecute = ActionExtrasSelUncheckExecute
    end
    object ActionExtrasSelGroup: TAction
      Category = 'Extras'
      Caption = 'Whole group'
      Hint = 'Select group|Select all extras of this group'
      OnExecute = ActionExtrasSelGroupExecute
    end
    object ActionExtrasSort: TAction
      Category = 'Extras'
      Caption = '&Sort by'
      Hint = 'Sort extras|Sort by a specified field the extras'
      OnExecute = ActionExtrasSortExecute
    end
    object ActionExtrasGroup: TAction
      Category = 'Extras'
      Caption = '&Group by'
      Hint = 'Group extras|Group by a specified field the extras'
      OnExecute = ActionExtrasGroupExecute
    end
    object ActionExtrasSortAscend: TAction
      Category = 'Extras'
      Caption = 'Ascending'
      Hint = '|Sort in ascending order'
      OnExecute = ActionSortExecute
    end
    object ActionExtrasSortDescend: TAction
      Category = 'Extras'
      Caption = 'Descending'
      Hint = '|Sort in descending order'
      OnExecute = ActionSortExecute
    end
    object ActionExtrasSortAdvanced: TAction
      Tag = 100
      Category = 'Extras'
      Caption = 'Advanced...'
      Hint = '|Advanced sort'
      OnExecute = ActionSortExecute
    end
    object ActionExtrasGroupNone: TAction
      Tag = -1
      Category = 'Extras'
      Caption = '< &none >'
      Hint = '|Do not group extras'
      OnExecute = ActionGroupExecute
    end
    object ActionExtrasRenumber: TAction
      Category = 'Extras'
      Caption = '&Renumber...'
      Hint = 'Renumber...|Renumber extras...'
      OnExecute = ActionExtrasRenumberExecute
    end
  end
  object PopupMovieExtras: TTBXPopupMenu
    OnPopup = PopupMovieExtrasPopup
    Left = 112
    Top = 128
    object MnuMepImportFiles: TTBXItem
      Action = ActionExtrasImportFiles
    end
    object MnuMepAdd: TTBXItem
      Action = ActionExtrasAdd
    end
    object MnuMepEdit: TTBXItem
      Action = ActionExtrasEdit
    end
    object MnuMepDel: TTBXItem
      Action = ActionExtrasDelete
    end
    object MnuMep__1: TTBXSeparatorItem
    end
    object MnuMepShowPic: TTBXItem
      Action = ActionExtraShowPic
    end
    object MnuMepURL: TTBXSubmenuItem
      Action = ActionExtraURL
      LinkSubitems = TBItemExtraURL
    end
    object MnuMep__2: TTBXSeparatorItem
    end
    object MnuMepCopy: TTBXItem
      Action = ActionExtrasCopy
    end
    object MnuMepPaste: TTBXItem
      Action = ActionExtrasPaste
    end
    object MnuMep_3: TTBXSeparatorItem
    end
    object MnuSelected: TTBXSubmenuItem
      Caption = 'Selected extras'
      object MnuMepCheck: TTBXItem
        Action = ActionExtrasCheck
      end
      object MnuMepUncheck: TTBXItem
        Action = ActionExtrasUncheck
      end
    end
    object MnuSelect: TTBXSubmenuItem
      Caption = 'Select'
      object MnuMepSelGroup: TTBXItem
        Action = ActionExtrasSelGroup
      end
      object MnuMep__5: TTBXSeparatorItem
      end
      object MnuMepSelChecked: TTBXItem
        Action = ActionExtrasSelCheck
      end
      object MnuMepSelUnchecked: TTBXItem
        Action = ActionExtrasSelUncheck
      end
    end
    object Mnu_Mep_4: TTBXSeparatorItem
    end
    object MnuMepSort: TTBXSubmenuItem
      Action = ActionExtrasSort
      object MnuMepSortAscend: TTBXItem
        Tag = -1
        Action = ActionExtrasSortAscend
        GroupIndex = 1
      end
      object MnuMepSortDescend: TTBXItem
        Tag = -1
        Action = ActionExtrasSortDescend
        GroupIndex = 1
      end
      object MnuMepSort__1: TTBXSeparatorItem
        Tag = -1
      end
      object MnuMepSortAdvanced: TTBXItem
        Tag = 100
        Action = ActionExtrasSortAdvanced
        GroupIndex = 2
      end
    end
    object MnuMepGrp: TTBXSubmenuItem
      Action = ActionExtrasGroup
      object MnuMepGrpNone: TTBXItem
        Tag = -1
        Action = ActionExtrasGroupNone
        GroupIndex = 3
      end
      object MnuMepGrp__1: TTBXSeparatorItem
        Tag = -1
      end
    end
    object MnuMep_5: TTBSeparatorItem
    end
    object MnuMepRenumber: TTBXItem
      Action = ActionExtrasRenumber
    end
  end
  object ImageListCheckboxes: TImageList
    Left = 112
    Top = 64
  end
end
