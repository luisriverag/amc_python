inherited ExtrasEditWin: TExtrasEditWin
  Left = 353
  Top = 118
  HelpContext = 1052
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Edit extras'
  ClientHeight = 302
  ClientWidth = 634
  Constraints.MinHeight = 340
  Constraints.MinWidth = 650
  OldCreateOrder = True
  DesignSize = (
    634
    302)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 269
    Width = 628
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 286
    Width = 634
  end
  object LPicture: TLabel [2]
    Left = 418
    Top = 9
    Width = 36
    Height = 13
    Caption = 'Picture:'
  end
  inherited btn1: TCorelButton
    Left = 556
    Top = 274
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 478
    Top = 274
    Caption = 'OK'
    ModalResult = 2
    TabOrder = 5
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 400
    Top = 274
    TabOrder = 7
  end
  inherited btn4: TCorelButton
    Left = 322
    Top = 274
    TabOrder = 8
  end
  object PanelExtraPicture: TPanel
    Left = 416
    Top = 29
    Width = 210
    Height = 236
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    DragKind = dkDock
    DragMode = dmAutomatic
    TabOrder = 2
    object ScrollBox1: TScrollBox
      Left = 0
      Top = 25
      Width = 210
      Height = 211
      HorzScrollBar.Tracking = True
      VertScrollBar.Tracking = True
      Align = alClient
      BevelInner = bvNone
      Color = clBtnFace
      ParentColor = False
      TabOrder = 1
      object PreviewPicture: TImage
        Left = 0
        Top = 0
        Width = 10
        Height = 10
        Hint = '|Click to display picture at fullsize'
        AutoSize = True
        Proportional = True
        OnMouseDown = PreviewPictureMouseDown
        OnMouseUp = PreviewPictureMouseUp
      end
    end
    object DockExtraPictureTop: TTBXDock
      Left = 0
      Top = 0
      Width = 210
      Height = 25
      object ToolbarExtraPicture: TTBXToolbar
        Left = 0
        Top = 0
        BorderStyle = bsNone
        Caption = 'Picture Toolbar'
        DefaultDock = DockExtraPictureTop
        DockMode = dmCannotFloatOrChangeDocks
        FullSize = True
        HideWhenInactive = False
        TabOrder = 0
        object MnuPicLoa: TTBXItem
          Action = ActionPicSelect
        end
        object MnuPicSav: TTBXItem
          Action = ActionPicSaveAs
        end
        object MnuPicCpy: TTBXItem
          Action = ActionPicCopy
        end
        object MnuPicPst: TTBXItem
          Action = ActionPicPaste
        end
        object MnuPicDel: TTBXItem
          Action = ActionPicDelete
        end
      end
    end
  end
  object chkPicture: TCheckBox
    Left = 418
    Top = 7
    Width = 17
    Height = 17
    Hint = '|Modify picture'
    TabOrder = 1
    Visible = False
  end
  inline FrmExtra: TExtraFrame
    Left = 0
    Top = 0
    Width = 416
    Height = 268
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
  end
  object BtnNextExtra: TTBXButton
    Left = 601
    Top = 3
    Width = 24
    Height = 24
    Action = ActionNextExtra
    Anchors = [akTop, akRight]
    AutoSize = False
    TabOrder = 4
  end
  object BtnPreviousExtra: TTBXButton
    Left = 575
    Top = 3
    Width = 24
    Height = 24
    Action = ActionPreviousExtra
    Anchors = [akTop, akRight]
    AutoSize = False
    TabOrder = 3
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Save a copy of the picture to a new file'
      'Select a picture'
      'Unable to use this picture: %s'
      'Stored in catalog as %s'
      'External file: %s'
      '%.0n bytes'
      'File "%s" doesn'#39't exist.'
      'Get information from files...'
      'Select a file to reference in the URL field'
      'Extra have been modified, do you want to save changes ?')
    Left = 32
    Top = 146
  end
  object ActionList1: TActionList
    Left = 32
    Top = 204
    object ActionPicSelect: TAction
      Category = 'Picture'
      Caption = '&Select...'
      Hint = 
        'Select a picture...|Select a picture to import or link for curre' +
        'nt movie'
      ShortCut = 24655
      OnExecute = ActionPicSelectExecute
    end
    object ActionPicDelete: TAction
      Category = 'Picture'
      Caption = '&Delete'
      Hint = 'Delete|Delete current picture'
      ShortCut = 24622
      OnExecute = ActionPicDeleteExecute
    end
    object ActionPicSaveAs: TAction
      Category = 'Picture'
      Caption = 'Save &as...'
      Hint = 'Save picture as...|Save a copy of the picture to a new file'
      ShortCut = 24659
      OnExecute = ActionPicSaveAsExecute
    end
    object ActionPicCopy: TAction
      Category = 'Picture'
      Caption = '&Copy'
      Hint = 'Copy to clipboard|Copy picture to clipboard'
      ShortCut = 24643
      OnExecute = ActionPicCopyExecute
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
      Caption = 'Open Folder'
      Hint = '|Open the folder containing the file specified in the field'
      OnExecute = ActionURLExploreExecute
    end
    object ActionPicPaste: TAction
      Category = 'Picture'
      Caption = '&Paste'
      Hint = 'Paste from clipboard|Paste picture from clipboard'
      ShortCut = 24662
      OnExecute = ActionPicPasteExecute
    end
    object ActionPreviousExtra: TAction
      Category = 'Extra'
      Caption = 'Previous extra'
      Hint = 'Previous extra|Show previous extra'
      ShortCut = 32805
      OnExecute = ActionPreviousExtraExecute
    end
    object ActionNextExtra: TAction
      Category = 'Extra'
      Caption = 'Next extra'
      Hint = 'Next extra|Show next extra'
      ShortCut = 32807
      OnExecute = ActionNextExtraExecute
    end
  end
  object PopupEURL: TTBXPopupMenu
    Alignment = paRight
    ItemsPopupMenu = PopupEURL
    Left = 705
    Top = 279
    object MnuPopupUrpOpen: TTBXItem
      Action = ActionURLOpen
    end
    object MnuPopupUrlExp: TTBXItem
      Action = ActionURLExplore
    end
    object MnuPopupUrlCopy: TTBXItem
      Action = ActionURLCopy
    end
    object MnuPopupUrlBrw: TTBXItem
      Action = ActionURLBrowse
    end
  end
  object PopupImage: TTBXPopupMenu
    Left = 112
    Top = 204
    object TBXMnuPicSelect: TTBXItem
      Action = ActionPicSelect
    end
    object TBXMnuPicSaveAs: TTBXItem
      Action = ActionPicSaveAs
    end
    object TBXMnuPicCopy: TTBXItem
      Action = ActionPicCopy
    end
    object TBXMnuPicPaste: TTBXItem
      Action = ActionPicPaste
    end
    object TBXMnuPicDelete: TTBXItem
      Action = ActionPicDelete
    end
  end
end
