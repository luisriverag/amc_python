inherited ScriptExtrasResultsWin: TScriptExtrasResultsWin
  Left = 658
  Top = 211
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Script execution results on extras'
  ClientHeight = 421
  ClientWidth = 682
  Constraints.MinHeight = 400
  Constraints.MinWidth = 400
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 388
    Width = 676
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 405
    Width = 682
  end
  inherited btn1: TCorelButton
    Left = 604
    Top = 393
    Hint = '|Close the window'
    Caption = '&Close'
    Default = True
    TabOrder = 1
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 526
    Top = 393
  end
  inherited btn3: TCorelButton
    Left = 448
    Top = 393
    TabOrder = 3
  end
  inherited btn4: TCorelButton
    Left = 370
    Top = 393
    TabOrder = 4
  end
  object listExtras: TElTree
    Left = 3
    Top = 3
    Width = 676
    Height = 201
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
    Font.Name = 'MS Shell Dlg'
    Font.Style = []
    HeaderHeight = 19
    HeaderHotTrack = False
    HeaderInvertSortArrows = True
    HeaderSections.Data = {
      F6FFFFFF01000000FC48020C004F0000FFFFFFFF000001010100000064000000
      00000000102700000001000050DD060B000000000000D2000000000000000100
      0000000000000000000100000600000045787472610001000000000000000000
      000000}
    HeaderFlat = True
    HorzScrollBarStyles.Width = 17
    HorzScrollBarStyles.ButtonSize = 17
    InactiveBorderType = fbtEtched
    IncrementalSearch = False
    LineHeight = 17
    MultiSelect = False
    OwnerDrawMask = '~~@~~'
    ParentShowHint = False
    PopupMenu = MenuPopupList
    RightClickSelect = False
    ScrollbarOpposite = False
    ScrollTracking = True
    ShowButtons = False
    ShowColumns = True
    ShowCheckboxes = True
    ShowHint = True
    ShowImages = False
    ShowRootButtons = True
    SortSection = -1
    SortType = stCustom
    TabOrder = 0
    TabStop = True
    TrackColor = clNone
    UnderlineTracked = False
    UseCustomScrollBars = False
    VertScrollBarStyles.ShowTrackHint = True
    VertScrollBarStyles.Width = 17
    VertScrollBarStyles.ButtonSize = 17
    OnAfterSelectionChange = listExtrasAfterSelectionChange
    OnItemChecked = listExtrasItemChecked
    OnMouseMove = listExtrasMouseMove
    OnDblClick = listExtrasDblClick
    OnKeyUp = listExtrasKeyUp
  end
  object listValues: TElTree
    Left = 3
    Top = 206
    Width = 676
    Height = 179
    Cursor = crDefault
    LeftPosition = 0
    ActiveBorderType = fbtEtched
    AlwaysKeepSelection = False
    AutoResizeColumns = False
    Anchors = [akLeft, akRight, akBottom]
    DockOrientation = doNoOrient
    ChangeDelay = 100
    DoInplaceEdit = False
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
      F6FFFFFF03000000FC48020C004F0000FFFFFFFF000001010100000096000000
      0000000010270000000100002CBCE611000000000000D2000000000000000100
      000000000000000000010000060000004669656C640001000000000000000000
      000000FC48020C004F0000FFFFFFFF0000010101000000FA0000000000000010
      270000000100006CF7820D010000000000D20000000000000001000000000000
      000000000100000F00000050726576696F75732076616C756500010000000000
      00000000000000FC48020C004F0000FFFFFFFF0000010101000000FA00000000
      00000010270000000100004CEE8E12020000000000D200000000000000010000
      00000000000000000100000A0000004E65772076616C75650001000000000000
      000000000000}
    HeaderFlat = True
    HorzScrollBarStyles.Width = 17
    HorzScrollBarStyles.ButtonSize = 17
    InactiveBorderType = fbtEtched
    IncrementalSearch = False
    LineHeight = 17
    MultiSelect = False
    OwnerDrawMask = '~~@~~'
    ParentShowHint = False
    PopupMenu = MenuPopupList
    RightClickSelect = False
    ScrollbarOpposite = False
    ScrollTracking = True
    ShowButtons = False
    ShowColumns = True
    ShowCheckboxes = True
    ShowHint = True
    ShowImages = False
    ShowRootButtons = True
    SortSection = -1
    SortType = stCustom
    TabOrder = 5
    TabStop = True
    TrackColor = clNone
    UnderlineTracked = False
    UseCustomScrollBars = False
    VertScrollBarStyles.ShowTrackHint = True
    VertScrollBarStyles.Width = 17
    VertScrollBarStyles.ButtonSize = 17
    OnResize = listValuesResize
    OnHotTrack = listValuesHotTrack
    OnMouseMove = listValuesMouseMove
    OnMouseUp = listValuesMouseUp
    OnDblClick = listValuesDblClick
    OnKeyUp = listValuesKeyUp
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Results for script "%s" for extras on movie %d'
      'Size: %.0n KB, click here to view'
      'Extra'
      'Added'
      'Deleted'
      'Modified'
      'File "%s" doesn'#39't exist.')
    Left = 440
    Top = 248
  end
  object ActionList1: TActionList
    Left = 336
    Top = 264
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
  end
  object MenuPopupList: TTBXPopupMenu
    Left = 344
    Top = 272
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
    object MnuLspNon: TTBXItem
      Action = ActionListNone
    end
  end
end
