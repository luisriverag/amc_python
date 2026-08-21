inherited StatsWin: TStatsWin
  Left = 484
  Top = 168
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Statistics'
  ClientHeight = 521
  ClientWidth = 624
  Constraints.MinHeight = 300
  Constraints.MinWidth = 450
  OldCreateOrder = True
  DesignSize = (
    624
    521)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 488
    Width = 618
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 505
    Width = 624
  end
  inherited btn1: TCorelButton
    Left = 546
    Top = 493
    Cancel = True
    Caption = 'Close'
    Default = True
    ModalResult = 2
    TabOrder = 5
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 468
    Top = 493
    TabOrder = 4
  end
  object Panel1: TPanel [4]
    Left = 154
    Top = 3
    Width = 468
    Height = 482
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      468
      482)
    object TheChart: TChart
      Left = 2
      Top = 26
      Width = 466
      Height = 456
      BackWall.Brush.Color = clWhite
      BackWall.Color = clWindow
      BottomWall.Brush.Color = clWhite
      BottomWall.Brush.Style = bsClear
      BottomWall.Color = clWindow
      LeftWall.Brush.Color = clWhite
      LeftWall.Brush.Style = bsClear
      LeftWall.Color = clWindow
      Title.Font.Charset = DEFAULT_CHARSET
      Title.Font.Color = clBtnText
      Title.Font.Height = -11
      Title.Font.Name = 'Arial'
      Title.Font.Style = []
      Title.Text.Strings = (
        'TChart')
      BackColor = clWindow
      BottomAxis.LabelsAngle = 90
      BottomAxis.LabelsMultiLine = True
      Legend.MaxNumRows = 0
      Legend.ShadowSize = 0
      View3DOptions.Elevation = 315
      View3DOptions.Orthogonal = False
      View3DOptions.Perspective = 0
      View3DOptions.Rotation = 360
      BevelOuter = bvNone
      BorderStyle = bsSingle
      Color = clWindow
      TabOrder = 0
      Anchors = [akLeft, akTop, akRight, akBottom]
      OnMouseMove = TheChartMouseMove
      OnMouseWheel = TheChartMouseWheel
      object Series2: TBarSeries
        Active = False
        ColorEachPoint = True
        Marks.Arrow.Visible = False
        Marks.ArrowLength = 8
        Marks.Transparent = True
        Marks.Visible = False
        PercentFormat = '##0.##,%'
        SeriesColor = clGreen
        ValueFormat = '(#,##0.###)'
        AfterDrawValues = Series2AfterDrawValues
        MultiBar = mbNone
        XValues.DateTime = False
        XValues.Name = 'X'
        XValues.Multiplier = 1.000000000000000000
        XValues.Order = loAscending
        YValues.DateTime = False
        YValues.Name = 'Bar'
        YValues.Multiplier = 1.000000000000000000
        YValues.Order = loNone
      end
      object Series1: TPieSeries
        Active = False
        Marks.Arrow.Color = clGray
        Marks.ArrowLength = 8
        Marks.Frame.Visible = False
        Marks.Style = smsLabelValue
        Marks.Transparent = True
        Marks.Visible = False
        PercentFormat = '##0.##,%'
        SeriesColor = clRed
        ValueFormat = '(#,##0.###)'
        AfterDrawValues = Series1AfterDrawValues
        Circled = True
        OtherSlice.Text = 'Other'
        OtherSlice.Value = 1.000000000000000000
        PieValues.DateTime = False
        PieValues.Name = 'Pie'
        PieValues.Multiplier = 1.000000000000000000
        PieValues.Order = loNone
      end
    end
    object TBDock1: TTBXDock
      Left = 0
      Top = 0
      Width = 468
      Height = 25
      object ToolbarGraphOptions: TTBXToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'Graphic options toolbar'
        CloseButton = False
        DefaultDock = TBDock1
        DockMode = dmCannotFloatOrChangeDocks
        TabOrder = 0
        object tbbSaveAs: TTBXItem
          Action = ActionSaveAs
        end
        object tbbCopy: TTBXSubmenuItem
          Action = ActionCopy
          Options = [tboDropdownArrow]
          object tbbCopyMetafile: TTBXItem
            Action = ActionCopyWMF
          end
          object tbbCopyBitmap: TTBXItem
            Action = ActionCopyBMP
          end
        end
        object tbs1: TTBXSeparatorItem
        end
        object tbbOptions: TTBXSubmenuItem
          Action = ActionOptions
          DisplayMode = nbdmImageAndText
          Options = [tboDropdownArrow]
          object tbbOptionsLegend: TTBXItem
            Action = ActionOptionsLegend
          end
          object tbbOptionsLabel: TTBXItem
            Action = ActionOptionsLabels
          end
          object tbbOptionsEmpty: TTBXItem
            Action = ActionOptionsEmpty
          end
          object tbbOptionsGroup: TTBXItem
            Action = ActionOptionsGroup
          end
        end
      end
    end
    object ScrollBar1: TScrollBar
      Left = 449
      Top = 28
      Width = 17
      Height = 452
      Anchors = [akTop, akRight, akBottom]
      DragKind = dkDock
      Kind = sbVertical
      PageSize = 0
      TabOrder = 3
      OnEnter = ScrollBar1Enter
      OnScroll = ScrollBar1Scroll
    end
    object lstGeneral: TListView
      Left = 2
      Top = 26
      Width = 466
      Height = 456
      Anchors = [akLeft, akTop, akRight, akBottom]
      Columns = <
        item
          AutoSize = True
        end
        item
          Width = 200
        end>
      ColumnClick = False
      Items.Data = {
        EF0000000500000000000000FFFFFFFFFFFFFFFF010000000000000016546F74
        616C206E756D626572206F66206D6F76696573013F00000000FFFFFFFFFFFFFF
        FF01000000000000001441766572616765206D6F766965206C656E677468013F
        00000000FFFFFFFFFFFFFFFF010000000000000012546F74616C206D6F766965
        206C656E677468013F00000000FFFFFFFFFFFFFFFF010000000000000019546F
        74616C2073697A65206F66206D6F7669652066696C6573013F00000000FFFFFF
        FFFFFFFFFF010000000000000015546F74616C206E756D626572206F66206469
        736373013FFFFFFFFFFFFFFFFFFFFF}
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 2
      ViewStyle = vsReport
    end
  end
  inherited btn3: TCorelButton
    Left = 390
    Top = 493
    TabOrder = 3
  end
  inherited btn4: TCorelButton
    Left = 312
    Top = 493
    TabOrder = 2
  end
  object Panel2: TPanel
    Left = 3
    Top = 3
    Width = 150
    Height = 482
    Anchors = [akLeft, akTop, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object lstCategories: TListBox
      Left = 0
      Top = 0
      Width = 150
      Height = 381
      Align = alClient
      ItemHeight = 13
      Items.Strings = (
        'General information')
      TabOrder = 0
      OnClick = lstCategoriesClick
      OnMouseMove = lstCategoriesMouseMove
    end
    inline IncMovies: TIncludemovFrame
      Left = 0
      Top = 381
      Width = 150
      Height = 101
      Align = alBottom
      TabOrder = 1
      inherited grp: TGroupBox
        Width = 150
        Height = 101
        inherited rbtAll: TRadioButton
          Width = 131
          OnClick = lstCategoriesClick
        end
        inherited rbtSelected: TRadioButton
          Width = 131
          OnClick = lstCategoriesClick
        end
        inherited rbtChecked: TRadioButton
          Width = 131
          OnClick = lstCategoriesClick
        end
        inherited rbtVisible: TRadioButton
          OnClick = lstCategoriesClick
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 56
    Top = 144
    object ActionSaveAs: TAction
      Category = 'Graph'
      Caption = 'Save as...'
      Hint = 'Save as...|Save picture to a file'
      ShortCut = 16467
      OnExecute = ActionSaveAsExecute
    end
    object ActionCopy: TAction
      Category = 'Graph'
      Caption = 'Copy'
      Hint = 'Copy|Copy picture to clipboard'
      OnExecute = ActionCopyExecute
    end
    object ActionOptions: TAction
      Category = 'Options'
      Caption = '&Options'
      Hint = 'Options|Change some options of the chart'
      OnExecute = ActionOptionsExecute
    end
    object ActionOptionsLegend: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Legend'
      Checked = True
      Hint = 'Display legend|Display the legend on the right of the chart'
      OnExecute = ActionOptionsLegendExecute
    end
    object ActionOptionsLabels: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Labels'
      Hint = 'Display labels|Display labels on the chart'
      OnExecute = ActionOptionsLabelsExecute
    end
    object ActionOptionsEmpty: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Empty months'
      Checked = True
      Hint = 
        'Display empty months|Display months where total is zero on the c' +
        'hart'
      OnExecute = lstCategoriesClick
    end
    object ActionCopyWMF: TAction
      Category = 'Graph'
      Caption = 'As Metafile'
      Hint = 
        'Copy as Metafile|Copy picture to clipboard as metafile (resizabl' +
        'e)'
      ShortCut = 16451
      OnExecute = ActionCopyWMFExecute
    end
    object ActionCopyBMP: TAction
      Category = 'Graph'
      Caption = 'As Bitmap'
      Hint = 'Copy as Bitmap|Copy picture to clipboard as bitmap'
      ShortCut = 24643
      OnExecute = ActionCopyBMPExecute
    end
    object ActionOptionsGroup: TAction
      Category = 'Options'
      AutoCheck = True
      Caption = 'Group values'
      Checked = True
      Hint = 
        'Group values|Chart: Group values using intervals; Pie: Group sma' +
        'ller values together'
      OnExecute = lstCategoriesClick
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      '%.1f minutes'
      '< none >'
      'Save chart'
      '%d days %d hours %d minutes'
      '< others >'
      'B')
    Left = 24
    Top = 152
  end
end
