object PictureOperationFrame: TPictureOperationFrame
  Left = 0
  Top = 0
  Width = 550
  Height = 326
  Ctl3D = True
  ParentCtl3D = False
  TabOrder = 0
  DesignSize = (
    550
    326)
  object grp: TGroupBox
    Left = 4
    Top = -1
    Width = 542
    Height = 324
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Pictures operation'
    TabOrder = 0
    DesignSize = (
      542
      324)
    object LMaxPicSizeW: TLabel
      Left = 38
      Top = 301
      Width = 53
      Height = 13
      BiDiMode = bdLeftToRight
      Caption = 'max width='
      FocusControl = EMaxPicSizeW
      ParentBiDiMode = False
    end
    object LMaxPicSizeH: TLabel
      Left = 186
      Top = 301
      Width = 57
      Height = 13
      Caption = 'max height='
      FocusControl = EMaxPicSizeH
    end
    object LMaxPicSizeUnit: TLabel
      Left = 334
      Top = 301
      Width = 37
      Height = 13
      Caption = 'in pixels'
    end
    object rbtStore: TRadioButton
      Left = 8
      Top = 18
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Store picture into catalog'
      TabOrder = 0
      OnClick = rbtClick
    end
    object rbtCopyInCatDir: TRadioButton
      Left = 8
      Top = 58
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Copy picture to catalog folder, and link it to catalog'
      TabOrder = 2
      OnClick = rbtClick
    end
    object rbtAbsToRelLink: TRadioButton
      Left = 8
      Top = 198
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Transform absolute link to relative link if possible if picture ' +
        'is only linked'
      TabOrder = 9
      OnClick = rbtClick
    end
    object rbtStoreIfCopied: TRadioButton
      Left = 8
      Top = 36
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Store picture into catalog only if picture is copied in catalog ' +
        'or pictures folder'
      TabOrder = 1
      OnClick = rbtClick
    end
    object rbtCopyInCatDirIfStored: TRadioButton
      Left = 8
      Top = 76
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to catalog folder only if picture is stored in cata' +
        'log'
      TabOrder = 3
      OnClick = rbtClick
    end
    object rbtRelToAbsLink: TRadioButton
      Left = 8
      Top = 216
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Transform relative link to absolute link if picture is only link' +
        'ed'
      TabOrder = 10
      OnClick = rbtClick
    end
    object rbtDelete: TRadioButton
      Left = 8
      Top = 238
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Delete picture (and picture file if it is copied in catalog or p' +
        'ictures folder)'
      TabOrder = 11
      OnClick = rbtClick
    end
    object rbtRenameIfCopied: TRadioButton
      Left = 8
      Top = 176
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Rename picture if it is copied in catalog or pictures folder'
      TabOrder = 8
      OnClick = rbtClick
    end
    object rbtCopyInPicDir: TRadioButton
      Left = 8
      Top = 118
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to pictures folder of catalog, and link it to catal' +
        'og'
      TabOrder = 5
      OnClick = rbtClick
    end
    object rbtCopyInPicDirIfStored: TRadioButton
      Left = 8
      Top = 136
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to pictures folder only if picture is stored in cat' +
        'alog'
      TabOrder = 6
      OnClick = rbtClick
    end
    object rbtCopyInCatDirIfCopied: TRadioButton
      Left = 8
      Top = 94
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to catalog folder only if picture is copied in pict' +
        'ures folder'
      TabOrder = 4
      OnClick = rbtClick
    end
    object rbtCopyInPicDirIfCopied: TRadioButton
      Left = 8
      Top = 154
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to pictures folder only if picture is copied in cat' +
        'alog folder'
      TabOrder = 7
      OnClick = rbtClick
    end
    object rbtConvertIfStoredOrCopied: TRadioButton
      Left = 8
      Top = 260
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Convert picture to JPG and resize it if needed only if picture i' +
        's stored or copied'
      TabOrder = 12
      OnClick = rbtClick
    end
    object rbtConvert: TRadioButton
      Left = 8
      Top = 278
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Convert picture to JPG and resize it if needed even if picture i' +
        's only linked (warning)'
      TabOrder = 13
      OnClick = rbtClick
    end
    object EMaxPicSizeW: TEdit
      Left = 113
      Top = 297
      Width = 52
      Height = 21
      Hint = '|Leave empty if you do not want to define a max width'
      TabOrder = 14
    end
    object EMaxPicSizeH: TEdit
      Left = 261
      Top = 297
      Width = 52
      Height = 21
      Hint = '|Leave empty if you do not want to define a max height'
      TabOrder = 15
    end
  end
end
