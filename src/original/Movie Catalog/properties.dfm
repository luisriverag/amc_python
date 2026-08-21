inherited PropertiesWin: TPropertiesWin
  Left = 272
  Top = 242
  Caption = 'Catalog properties'
  ClientHeight = 371
  ClientWidth = 434
  Constraints.MinHeight = 400
  Constraints.MinWidth = 450
  OldCreateOrder = True
  DesignSize = (
    434
    371)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 338
    Width = 428
  end
  object Bevel2: TBevel [1]
    Left = 16
    Top = 144
    Width = 415
    Height = 10
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object LFileName: TLabel [2]
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Name:'
    FocusControl = EFileName
  end
  object LFileSize: TLabel [3]
    Left = 8
    Top = 32
    Width = 23
    Height = 13
    Caption = 'Size:'
    FocusControl = EFileSize
  end
  object LFileVersion: TLabel [4]
    Left = 8
    Top = 56
    Width = 35
    Height = 13
    Caption = 'Format:'
    FocusControl = EFileVersion
  end
  object LHOwnerInfo: TLabel [5]
    Left = 8
    Top = 144
    Width = 86
    Height = 13
    Caption = 'Owner Information'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = False
  end
  object LOwnerName: TLabel [6]
    Left = 8
    Top = 170
    Width = 31
    Height = 13
    Caption = 'Name:'
    FocusControl = EOwnerName
  end
  object LOwnerMail: TLabel [7]
    Left = 8
    Top = 194
    Width = 31
    Height = 13
    Caption = 'E-mail:'
    FocusControl = EOwnerMail
  end
  object LOwnerSite: TLabel [8]
    Left = 8
    Top = 218
    Width = 42
    Height = 13
    Caption = 'Website:'
    FocusControl = EOwnerSite
  end
  object LDescription: TLabel [9]
    Left = 8
    Top = 242
    Width = 56
    Height = 13
    Caption = 'Description:'
    FocusControl = EDescription
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 355
    Width = 434
  end
  object Bevel3: TBevel [11]
    Left = 16
    Top = 88
    Width = 415
    Height = 10
    Anchors = [akLeft, akTop, akRight]
    Shape = bsBottomLine
  end
  object LHXMLHeader: TLabel [12]
    Left = 8
    Top = 88
    Width = 58
    Height = 13
    Caption = 'XML header'
    Enabled = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Transparent = False
  end
  object LEncoding: TLabel [13]
    Left = 8
    Top = 114
    Width = 48
    Height = 13
    Caption = 'Encoding:'
    FocusControl = EEncoding
  end
  inherited btn1: TCorelButton
    Left = 356
    Top = 343
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 11
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 278
    Top = 343
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 10
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 200
    Top = 343
    TabOrder = 9
  end
  inherited btn4: TCorelButton
    Left = 122
    Top = 343
    TabOrder = 8
  end
  object EFileName: TEdit
    Left = 75
    Top = 8
    Width = 356
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Color = clBtnFace
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 0
  end
  object EFileSize: TEdit
    Left = 75
    Top = 32
    Width = 356
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Color = clBtnFace
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 1
  end
  object EFileVersion: TEdit
    Left = 75
    Top = 56
    Width = 356
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    BorderStyle = bsNone
    Color = clBtnFace
    Ctl3D = False
    ParentCtl3D = False
    ReadOnly = True
    TabOrder = 2
  end
  object EOwnerName: TEdit
    Left = 75
    Top = 166
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 4
  end
  object EDescription: TMemo
    Left = 75
    Top = 238
    Width = 356
    Height = 97
    Anchors = [akLeft, akTop, akRight, akBottom]
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object EEncoding: TComboBox
    Left = 75
    Top = 110
    Width = 357
    Height = 21
    AutoComplete = False
    Anchors = [akLeft, akTop, akRight]
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      'us-ascii'
      'windows-1250'
      'windows-1251'
      'windows-1252'
      'windows-1255'
      'windows-1256'
      'iso-8859-1'
      'iso-8859-2'
      'iso-8859-6'
      'iso-8859-8'
      'iso-8859-9'
      'koi8-r'
      'koi8-u'
      'shift_jis'
      'big5'
      'gb2312'
      'tis-620')
  end
  object EOwnerMail: TAntJvComboEditXP
    Left = 75
    Top = 190
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonFlat = False
    ButtonHint = 'Send a mail'
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 5
    OnButtonClick = EOwnerMailButtonClick
  end
  object EOwnerSite: TAntJvComboEditXP
    Left = 75
    Top = 214
    Width = 356
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    ButtonFlat = False
    ButtonHint = 'Go to URL'
    ButtonWidth = 17
    ImageKind = ikEllipsis
    TabOrder = 6
    OnButtonClick = EOwnerSiteButtonClick
  end
end
