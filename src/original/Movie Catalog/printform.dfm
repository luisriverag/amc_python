inherited PrintWin: TPrintWin
  Left = 495
  Top = 194
  HelpContext = 1090
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Print'
  ClientHeight = 462
  ClientWidth = 764
  Constraints.MinHeight = 500
  Constraints.MinWidth = 780
  KeyPreview = True
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 429
    Width = 758
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 446
    Width = 764
  end
  inherited btn1: TCorelButton
    Left = 686
    Top = 434
    Caption = '&Help'
    TabOrder = 4
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 608
    Top = 434
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 530
    Top = 434
    Action = ActionPrint
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 452
    Top = 434
    TabOrder = 1
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 764
    Height = 426
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 175
      Top = 25
      Height = 401
      AutoSnap = False
      MinSize = 100
      ResizeStyle = rsUpdate
    end
    object TBDock1: TTBXDock
      Left = 0
      Top = 0
      Width = 764
      Height = 25
      object ToolbarPreview: TTBXToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'Preview Toolbar'
        CloseButton = False
        DockMode = dmCannotFloatOrChangeDocks
        DockPos = 1
        TabOrder = 0
        object TBItem2: TTBXItem
          Action = ActionPreviewRefresh
          DisplayMode = nbdmImageAndText
        end
        object TBItem10: TTBXItem
          Action = ActionFileLoad
        end
        object TBItem30: TTBXItem
          Action = ActionFileDesigner
          DisplayMode = nbdmImageAndText
        end
        object TBSeparatorItem7: TTBXSeparatorItem
        end
        object TBItem29: TTBXItem
          Action = ActionPrint
          DisplayMode = nbdmImageAndText
        end
        object TBSeparatorItem1: TTBXSeparatorItem
        end
        object TBItem6: TTBXItem
          Action = ActionPreviewPageFirst
        end
        object TBItem5: TTBXItem
          Action = ActionPreviewPagePrevious
        end
        object TBItem4: TTBXItem
          Action = ActionPreviewPageNext
        end
        object TBItem3: TTBXItem
          Action = ActionPreviewPageLast
        end
        object TBSeparatorItem2: TTBXSeparatorItem
        end
        object TBItem7: TTBXItem
          Action = ActionPreviewPageFull
        end
        object TBItem9: TTBXItem
          Action = ActionPreviewPageTwo
        end
        object TBItem8: TTBXItem
          Action = ActionPreviewPageWidth
          DisplayMode = nbdmImageAndText
        end
        object TBSeparatorItem3: TTBXSeparatorItem
        end
        object TBItem14: TTBXItem
          Action = ActionPreviewZoomOut
        end
        object EZoom: TTBXEditItem
          EditWidth = 50
          OnAcceptText = EZoomAcceptText
          ExtendedAccept = True
        end
        object TBItem16: TTBXItem
          Action = ActionPreviewZoomIn
        end
      end
    end
    object frPreview1: TfrPreview
      Left = 178
      Top = 25
      Width = 586
      Height = 401
      Align = alClient
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = clAppWorkSpace
      PopupMenu = popupPreview
      TabOrder = 2
      ScrollBars = ssBoth
      OnMouseWheel = frPreview1MouseWheel
    end
    object Panel1: TPanel
      Left = 0
      Top = 25
      Width = 175
      Height = 401
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object LvScripts: TListView
        Left = 0
        Top = 0
        Width = 175
        Height = 227
        Align = alClient
        Columns = <
          item
            AutoSize = True
            Caption = 'Available templates'
          end>
        ColumnClick = False
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = popupReports
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = LvScriptsSelectItem
      end
      inline SortBy: TSortByFrame
        Left = 0
        Top = 328
        Width = 175
        Height = 73
        Hint = '|Sort in descending order'
        Align = alBottom
        TabOrder = 2
        inherited grp: TGroupBox
          Width = 175
          Height = 73
          inherited EOrderBy: TComboBox
            Width = 155
            OnChange = IncludeMovClick
          end
          inherited BtnAdvSort: TCorelButton
            Left = 10
            Top = 44
            Width = 122
            Anchors = [akLeft, akTop, akRight]
            OnClick = SortByBtnAdvSortClick
          end
          inherited BtnSortDescend: TTBXButton
            Left = 142
            Top = 42
            OnClick = IncludeMovClick
          end
        end
      end
      inline Includemov: TIncludemovFrame
        Left = 0
        Top = 227
        Width = 175
        Height = 101
        Align = alBottom
        TabOrder = 1
        inherited grp: TGroupBox
          Width = 175
          Height = 101
          inherited rbtAll: TRadioButton
            Width = 156
            OnClick = IncludeMovClick
          end
          inherited rbtSelected: TRadioButton
            Width = 156
            OnClick = IncludeMovClick
          end
          inherited rbtChecked: TRadioButton
            Width = 156
            OnClick = IncludeMovClick
          end
          inherited rbtVisible: TRadioButton
            Width = 156
            OnClick = IncludeMovClick
          end
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 88
    Top = 88
    object ActionFileLoad: TAction
      Category = 'File'
      Caption = 'Load template...'
      Hint = 'Load template|Load another template'
      ShortCut = 16463
      OnExecute = ActionFileLoadExecute
    end
    object ActionFileDesigner: TAction
      Category = 'File'
      Caption = '&Designer...'
      Hint = 'Open designer|Open report designer'
      ShortCut = 115
      OnExecute = ActionFileDesignerExecute
    end
    object ActionPrint: TAction
      Category = 'File'
      Caption = '&Print...'
      Hint = 'Print|Print current report'
      ShortCut = 16464
      OnExecute = ActionPrintExecute
    end
    object ActionPreviewRefresh: TAction
      Category = 'Preview'
      Caption = '&Refresh'
      Hint = 'Refresh preview|Refresh preview'
      ShortCut = 116
      OnExecute = ActionPreviewRefreshExecute
    end
    object ActionPreviewPageFirst: TAction
      Category = 'Preview'
      Caption = 'First page'
      Hint = 'First page|Go to first page'
      ShortCut = 16420
      OnExecute = ActionPreviewPageFirstExecute
    end
    object ActionPreviewPagePrevious: TAction
      Category = 'Preview'
      Caption = 'Previous page'
      Hint = 'Previous page|Go to previous page'
      ShortCut = 33
      OnExecute = ActionPreviewPagePreviousExecute
    end
    object ActionPreviewPageNext: TAction
      Category = 'Preview'
      Caption = 'Next page'
      Hint = 'Next page|Go to next page'
      ShortCut = 34
      OnExecute = ActionPreviewPageNextExecute
    end
    object ActionPreviewPageLast: TAction
      Category = 'Preview'
      Caption = 'Last page'
      Hint = 'Last page|Go to last page'
      ShortCut = 16419
      OnExecute = ActionPreviewPageLastExecute
    end
    object ActionPreviewPageFull: TAction
      Category = 'Preview'
      Caption = 'Full page'
      Hint = 'Full page|Zoom to full page'
      OnExecute = ActionPreviewPageFullExecute
    end
    object ActionPreviewPageTwo: TAction
      Category = 'Preview'
      Caption = 'Two pages'
      Hint = 'Two pages|Zoom to two pages'
      OnExecute = ActionPreviewPageTwoExecute
    end
    object ActionPreviewPageWidth: TAction
      Category = 'Preview'
      Caption = 'Page width'
      Hint = 'Fit page width|Zoom to page width'
      OnExecute = ActionPreviewPageWidthExecute
    end
    object ActionPreviewZoomOut: TAction
      Category = 'Preview'
      Caption = 'Zoom out'
      Hint = 'Zoom out|Decrease zoom factor'
      ShortCut = 16418
      OnExecute = ActionPreviewZoomOutExecute
    end
    object ActionPreviewZoomIn: TAction
      Category = 'Preview'
      Caption = 'Zoom in'
      Hint = 'Zoom in|Increase zoom factor'
      ShortCut = 16417
      OnExecute = ActionPreviewZoomInExecute
    end
    object ActionExportRTF: TAction
      Category = 'File'
      Caption = 'Export to RTF'
      Hint = 'Export to RTF|Export current report to a RTF file'
      OnExecute = ActionExportExecute
    end
    object ActionExportHTML: TAction
      Category = 'File'
      Caption = 'Export to HTML'
      Hint = 'Export to HTML|Export current report to a HTML file'
      OnExecute = ActionExportExecute
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Print - %s'
      '<no file selected>'
      'Unable to load template for preview: %s'
      
        'Cannot find Report Designer. %s must be in the same folder than ' +
        'Ant Movie Catalog.')
    Left = 56
    Top = 104
  end
  object frReport1: TfrReport
    Dataset = frUserDataset1
    InitialZoom = pzDefault
    ModifyPrepared = False
    Preview = frPreview1
    PreviewButtons = [pbZoom, pbLoad, pbSave, pbPrint, pbFind, pbHelp, pbExit]
    StoreInDFM = True
    OnGetValue = frReport1GetValue
    OnEnterRect = frReport1EnterRect
    OnUserFunction = frReport1UserFunction
    Left = 136
    Top = 152
    ReportForm = {
      17000000500000001700000000160053616D73756E67204D4C2D313636302053
      657269657300FF0900000034080000990B000000000000000000000000000000
      000000000000FFFF0000000000000000FE00000000000000}
  end
  object frUserDataset1: TfrUserDataset
    RangeEnd = reCount
    OnCheckEOF = frUserDataset1CheckEOF
    Left = 88
    Top = 184
  end
  object popupReports: TTBXPopupMenu
    Left = 120
    Top = 80
    object TBItem13: TTBXItem
      Action = ActionPreviewRefresh
    end
    object TBItem12: TTBXItem
      Action = ActionFileLoad
    end
  end
  object popupPreview: TTBXPopupMenu
    Left = 160
    Top = 88
    object TBItem24: TTBXItem
      Action = ActionPreviewRefresh
    end
    object TBSeparatorItem6: TTBXSeparatorItem
    end
    object TBItem25: TTBXItem
      Action = ActionPreviewPageFull
    end
    object TBItem22: TTBXItem
      Action = ActionPreviewPageTwo
    end
    object TBItem21: TTBXItem
      Action = ActionPreviewPageWidth
    end
    object TBItem28: TTBXItem
      Action = ActionPreviewZoomIn
    end
    object TBItem23: TTBXItem
      Action = ActionPreviewZoomOut
    end
    object TBSeparatorItem4: TTBXSeparatorItem
    end
    object TBItem27: TTBXItem
      Action = ActionPreviewPageFirst
    end
    object TBItem26: TTBXItem
      Action = ActionPreviewPageLast
    end
  end
end
