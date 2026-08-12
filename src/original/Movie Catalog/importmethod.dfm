inherited ImportMethodWin: TImportMethodWin
  Left = 605
  Top = 313
  BorderStyle = bsSingle
  Caption = 'Movies importation method'
  ClientHeight = 266
  ClientWidth = 464
  OldCreateOrder = True
  Position = poDesktopCenter
  OnActivate = FormActivate
  DesignSize = (
    464
    266)
  PixelsPerInch = 96
  TextHeight = 13
  object LMsg1: TLabel [0]
    Left = 8
    Top = 8
    Width = 449
    Height = 28
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'You have selected a key field to compare checked movies of the l' +
      'ist with movies in current catalog.'
    Visible = False
    WordWrap = True
  end
  object LMsg2: TLabel [1]
    Left = 8
    Top = 8
    Width = 449
    Height = 41
    Anchors = [akLeft, akTop, akRight]
    AutoSize = False
    Caption = 
      'You will import all checked movies of the list in current catalo' +
      'g. To check if movies do not already exist, you can define a key' +
      ' field to compare them (click on a column header of the list).'
    Visible = False
    WordWrap = True
  end
  inherited Bevel1: TBevel
    Top = 233
    Width = 458
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 250
    Width = 464
  end
  inherited btn1: TCorelButton
    Left = 386
    Top = 238
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
    Visible = True
  end
  inherited btn2: TCorelButton
    Left = 308
    Top = 238
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 230
    Top = 238
    TabOrder = 2
  end
  inherited btn4: TCorelButton
    Left = 152
    Top = 238
    TabOrder = 1
  end
  object grpImportMethod: TRadioGroup
    Left = 8
    Top = 56
    Width = 448
    Height = 104
    Anchors = [akLeft, akTop, akRight]
    Caption = 'What do you want to do ?'
    Items.Strings = (
      '&Import all movies'
      '&Import only new movies'
      '&Update only existing movies'
      '&Import new movies and update existing movies')
    TabOrder = 0
    OnClick = grpImportMethodClick
  end
  object chkImportExtrasNew: TCheckBox
    Left = 18
    Top = 168
    Width = 438
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import all extras for new movies'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object chkDeleteExtras: TCheckBox
    Left = 18
    Top = 208
    Width = 438
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Delete all extras of existing movies before to add the new ones'
    TabOrder = 6
  end
  object chkImportExtras: TCheckBox
    Left = 18
    Top = 188
    Width = 438
    Height = 17
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Import all extras for existing movies'
    TabOrder = 7
  end
end
