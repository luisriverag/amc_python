inherited ScriptResultsWin: TScriptResultsWin
  Left = 668
  Top = 240
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Script execution results'
  ClientHeight = 521
  ClientWidth = 682
  Constraints.MinHeight = 400
  Constraints.MinWidth = 400
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 488
    Width = 676
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 505
    Width = 682
  end
  inherited btn1: TCorelButton
    Left = 604
    Top = 493
    Hint = '|Abort scripting process'
    Cancel = True
    Caption = '&Abort'
    ModalResult = 9
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 526
    Top = 493
    Hint = '|Skip this movie only'
    Caption = 'S&kip'
    ModalResult = 7
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 448
    Top = 493
    Hint = '|Save this movie and all the following ones'
    Caption = 'Save a&ll'
    Visible = True
    OnClick = btn3Click
  end
  inherited btn4: TCorelButton
    Left = 370
    Top = 493
    Hint = '|Save information for this movie'
    Caption = '&Save'
    Default = True
    ModalResult = 6
    Visible = True
  end
  object listValues: TElTree
    Left = 3
    Top = 3
    Width = 676
    Height = 482
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
      F6FFFFFF03000000F04E260A002B0000FFFFFFFF000001010100000096000000
      0000000010270000000100002CBCE611000000000000D2000000000000000100
      000000000000000000010000060000004669656C640001000000000000000000
      000000F04E260A002B0000FFFFFFFF0000010101000000FA0000000000000010
      270000000100006CF7820D010000000000D20000000000000001000000000000
      000000000100000F00000050726576696F75732076616C756500010000000000
      00000000000000F04E260A002B0000FFFFFFFF0000010101000000FA00000000
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
    TabOrder = 4
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
      'Results for script "%s" for movie %d'
      'Size: %.0n KB, click here to view'
      
        'Do you want to remember which fields to keep for next movies of ' +
        'this script execution? (if you answer No, all the fields modifie' +
        'd by the script will be used)'
      '*Add extras*'
      '*Delete extras*'
      '*Modify extras*'
      'Added extras: %d, click here to view '
      'Deleted extras: %d, click here to view '
      'Modified extras: %d, click here to view '
      'Changed values: %d, click here to view '
      'File "%s" doesn'#39't exist.')
    Left = 8
    Top = 16
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
