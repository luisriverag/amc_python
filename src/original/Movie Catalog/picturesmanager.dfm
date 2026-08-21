inherited PicturesManagerWin: TPicturesManagerWin
  Left = 403
  Top = 352
  BorderStyle = bsSingle
  Caption = 'Pictures manager'
  ClientHeight = 364
  ClientWidth = 683
  OldCreateOrder = True
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 331
    Width = 677
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 348
    Width = 683
  end
  inherited btn1: TCorelButton
    Left = 605
    Top = 336
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 527
    Top = 336
    Caption = 'OK'
    Default = True
    TabOrder = 5
    Visible = True
    OnClick = btn2Click
  end
  inherited btn3: TCorelButton
    Left = 449
    Top = 336
    TabOrder = 4
  end
  inherited btn4: TCorelButton
    Left = 371
    Top = 336
    TabOrder = 3
  end
  inline Includemov: TIncludemovFrame
    Left = 551
    Top = 2
    Width = 128
    Height = 169
    TabOrder = 1
    inherited grp: TGroupBox
      Height = 169
      DesignSize = (
        128
        169)
      inherited rbtAll: TRadioButton
        OnClick = IncludemovClick
      end
      inherited rbtSelected: TRadioButton
        OnClick = IncludemovClick
      end
      inherited rbtChecked: TRadioButton
        OnClick = IncludemovClick
      end
      inherited rbtVisible: TRadioButton
        OnClick = IncludemovClick
      end
    end
  end
  inline PictureOperation: TPictureOperationFrame
    Left = 1
    Top = 3
    Width = 550
    Height = 326
    Ctl3D = True
    ParentCtl3D = False
    TabOrder = 0
  end
  inline Includepic: TIncludepicFrame
    Left = 551
    Top = 174
    Width = 128
    Height = 152
    TabOrder = 2
    inherited grp: TGroupBox
      Height = 152
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Applying changes on movie pictures...'
      'Unable to apply changes on picture of movie "%s": %s'
      
        'After applying this changes, the current catalog must be saved t' +
        'o remain consistent! Do you want to save catalog automatically a' +
        'fter applying this changes?'
      'Unable to apply changes on picture of extra "%s": %s'
      
        'Warning, deleting is irreversible! Are you really sure you want ' +
        'to delete pictures?'
      
        'Warning, resizing is irreversible! Are you really sure you want ' +
        'to resize pictures?'
      
        'Warning, resizing is irreversible! Are you really sure you want ' +
        'to resize pictures and linked pictures too?')
    Left = 8
    Top = 272
  end
end
