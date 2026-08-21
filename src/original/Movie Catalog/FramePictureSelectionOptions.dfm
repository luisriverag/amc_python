object PictureSelectOptionsFrame: TPictureSelectOptionsFrame
  Left = 0
  Top = 0
  Width = 408
  Height = 88
  Ctl3D = True
  ParentCtl3D = False
  TabOrder = 0
  object grp: TGroupBox
    Left = 8
    Top = 0
    Width = 393
    Height = 84
    Caption = 'Picture importation method'
    TabOrder = 0
    DesignSize = (
      393
      84)
    object rbtStorePic: TRadioButton
      Left = 8
      Top = 14
      Width = 377
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = '&Store picture into catalog'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object rbtCopyPicInCatDir: TRadioButton
      Left = 8
      Top = 30
      Width = 377
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Copy picture to &catalog folder, and link it to catalog'
      TabOrder = 1
    end
    object rbtLinkPic: TRadioButton
      Left = 8
      Top = 62
      Width = 161
      Height = 17
      Caption = 'Only &link picture'
      TabOrder = 3
    end
    object chkLinkRelative: TCheckBox
      Left = 176
      Top = 62
      Width = 209
      Height = 17
      Caption = 'Make &relative path if possible'
      TabOrder = 4
    end
    object rbtCopyPicInPicDir: TRadioButton
      Left = 8
      Top = 46
      Width = 377
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 
        'Copy picture to &pictures folder of catalog, and link it to cata' +
        'log'
      TabOrder = 2
    end
  end
end
