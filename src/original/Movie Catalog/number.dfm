inherited NumberWin: TNumberWin
  Left = 555
  Top = 420
  BorderStyle = bsSingle
  Caption = 'Movie number selection'
  ClientHeight = 184
  ClientWidth = 384
  OldCreateOrder = True
  Position = poDesktopCenter
  OnActivate = FormActivate
  DesignSize = (
    384
    184)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 151
    Width = 378
  end
  object LEnterNumber: TLabel [1]
    Left = 8
    Top = 9
    Width = 139
    Height = 13
    Caption = 'Enter a &number for the movie:'
    FocusControl = ENumber
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 168
    Width = 384
  end
  inherited btn1: TCorelButton
    Left = 306
    Top = 156
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 228
    Top = 156
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 150
    Top = 156
    TabOrder = 5
  end
  inherited btn4: TCorelButton
    Left = 72
    Top = 156
    TabOrder = 4
  end
  object CBDoNotAsk: TCheckBox
    Left = 8
    Top = 128
    Width = 369
    Height = 17
    Anchors = [akLeft, akRight, akBottom]
    Caption = 'Do not ask again ; use automatic numbering'
    TabOrder = 3
  end
  object ENumber: TAntJvSpinEdit
    Left = 278
    Top = 6
    Width = 68
    Height = 21
    CheckMaxValue = False
    MinValue = 1.000000000000000000
    Value = 1.000000000000000000
    Anchors = [akTop, akRight]
    TabOrder = 0
    OnChange = ENumberChange
  end
  object grpNotUnique: TRadioGroup
    Left = 8
    Top = 36
    Width = 368
    Height = 84
    Anchors = [akLeft, akTop, akRight]
    Caption = 'There is already a movie with this number...'
    Items.Strings = (
      '&Accept duplicate'
      '&Give another number to the existing movie'
      '&Shift movie numbers until there is no more duplicate')
    TabOrder = 2
    OnClick = grpNotUniqueClick
  end
  object btnFindNum: TTBXButton
    Left = 352
    Top = 5
    Width = 23
    Height = 22
    Hint = 'Find an available number|'
    Anchors = [akTop, akRight]
    AutoSize = False
    Caption = '?'
    TabOrder = 1
    OnClick = btnFindNumClick
  end
end
