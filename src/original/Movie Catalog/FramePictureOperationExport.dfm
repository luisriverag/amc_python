object PictureOperationExportFrame: TPictureOperationExportFrame
  Left = 0
  Top = 0
  Width = 550
  Height = 186
  Ctl3D = True
  ParentCtl3D = False
  TabOrder = 0
  DesignSize = (
    550
    186)
  object grp: TGroupBox
    Left = 4
    Top = -1
    Width = 542
    Height = 184
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Pictures exportation method'
    TabOrder = 0
    DesignSize = (
      542
      184)
    object rbtNoChangeXML: TRadioButton
      Left = 8
      Top = 18
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Same as current catalog (stored pictures will be lost)'
      TabOrder = 1
      Visible = False
    end
    object rbtStore: TRadioButton
      Left = 8
      Top = 40
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Store picture into catalog'
      TabOrder = 2
    end
    object rbtCopyInCatDir: TRadioButton
      Left = 8
      Top = 80
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Copy picture to catalog folder, and link it to catalog'
      TabOrder = 4
    end
    object rbtStoreIfCopied: TRadioButton
      Left = 8
      Top = 58
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Store picture into catalog only if picture is copied in catalog ' +
        'or pictures folder'
      TabOrder = 3
    end
    object rbtCopyInCatDirIfStored: TRadioButton
      Left = 8
      Top = 98
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to catalog folder only if picture is stored in cata' +
        'log'
      TabOrder = 5
    end
    object rbtDelete: TRadioButton
      Left = 8
      Top = 160
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Delete picture'
      TabOrder = 8
    end
    object rbtCopyInPicDir: TRadioButton
      Left = 8
      Top = 120
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to pictures folder of catalog, and link it to catal' +
        'og'
      TabOrder = 6
    end
    object rbtCopyInPicDirIfStored: TRadioButton
      Left = 8
      Top = 138
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to pictures folder only if picture is stored in cat' +
        'alog'
      TabOrder = 7
    end
    object rbtNoChangeAMC: TRadioButton
      Left = 8
      Top = 18
      Width = 526
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Same as current catalog'
      TabOrder = 0
    end
  end
end
