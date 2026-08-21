inherited ImportFrameDir: TImportFrameDir
  OnResize = FrameResize
  inherited grpSettings: TGroupBox
    Height = 172
    DesignSize = (
      550
      172)
    object lblBrowseDepth: TLabel
      Left = 8
      Top = 79
      Width = 153
      Height = 13
      Caption = 'Browse subfolders with depth of:'
      FocusControl = edtBrowseDepth
    end
    object lblExtVideo: TLabel
      Left = 8
      Top = 148
      Width = 54
      Height = 13
      Caption = 'Extensions:'
      FocusControl = edtExtVideo
    end
    object lblDiskTag: TLabel
      Left = 349
      Top = 122
      Width = 42
      Height = 13
      Caption = 'Disk tag:'
      FocusControl = edtDiskTag
    end
    object lblExtractProcess: TLabel
      Left = 349
      Top = 75
      Width = 76
      Height = 13
      Anchors = [akTop, akRight]
      Caption = 'Extract process:'
    end
    object edtBrowseDepth: TComboBox
      Left = 273
      Top = 75
      Width = 65
      Height = 22
      Hint = 
        '|0 = none, * = browse all, 1 = browse only subdirectory of selec' +
        'ted directory'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 10
      Items.Strings = (
        '0'
        '1'
        '2'
        '3'
        '*')
    end
    inherited cmbExtraPictures: TComboBox
      TabOrder = 12
    end
    object chkMultiDisks: TCheckBox
      Left = 8
      Top = 120
      Width = 329
      Height = 17
      Caption = 'Merge info of media in multi parts/disks'
      TabOrder = 5
      OnClick = chkMultiDisksClick
    end
    object edtDiskTag: TComboBox
      Left = 421
      Top = 118
      Width = 124
      Height = 22
      Hint = 
        '|E.g. choose tag ''cd'' for name like moviename.cd1, moviename.cd2' +
        ', ...'
      AutoComplete = False
      Anchors = [akLeft, akTop, akRight]
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 6
      Items.Strings = (
        '(cd)[0-9]{1,3}'
        '(cd|dvd)[0-9]{1,3}'
        '(cd|dvd|xvid|divx)[0-9]{1,3}'
        '.* #all parts in same folder')
    end
    object chkInternalAVI: TCheckBox
      Left = 8
      Top = 100
      Width = 329
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Use internal engine for AVI importation (faster)'
      TabOrder = 4
    end
    object edtExtVideo: TEdit
      Left = 80
      Top = 144
      Width = 232
      Height = 21
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 7
    end
    object btnDefaultExtVideo: TCorelButton
      Left = 316
      Top = 143
      Width = 75
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Default'
      TabOrder = 8
      OnClick = btnDefaultExtVideoClick
    end
    object btnFilterFileName: TCorelButton
      Left = 395
      Top = 143
      Width = 150
      Height = 23
      Anchors = [akTop, akRight]
      Caption = 'Filter the file name'
      TabOrder = 9
      OnClick = btnFilterFileNameClick
    end
    object cmbExtractProcess: TComboBox
      Left = 349
      Top = 92
      Width = 196
      Height = 21
      Style = csDropDownList
      Anchors = [akTop, akRight]
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 11
      Text = '1 - Extract advanced media info during scanning'
      Items.Strings = (
        '1 - Extract advanced media info during scanning'
        '2 - Only extract advanced media info during final import'
        '3 - Do not extract advanced media info')
    end
  end
  inherited grpPreview: TGroupBox
    Top = 237
    Height = 123
    DesignSize = (
      550
      123)
    inherited listPreview: TElTree
      Height = 85
      HeaderSections.Data = {F6FFFFFF00000000}
    end
  end
  inherited grpSourceFile: TGroupBox
    Top = 193
    Caption = 'Source folder'
    inherited btnReload: TTBXButton
      Caption = '&Scan folder'
    end
    inherited btnBrowse: TTBXButton
      Hint = 'Browse...|Browse for a directory to scan'
    end
  end
  inherited Messages: TAntStringList
    Strings.Strings = (
      'No movie to import'
      
        'You did not assign a field to any column. Click on column header' +
        's for this.'
      
        'For this picture importation methode, the catalog must have a na' +
        'me; please save it somewhere and try again'
      'Select a folder:'
      '%s movie(s) found!'
      '%s movie(s) added!'
      '%s movie(s) updated!'
      
        'The values of key field are not unique in database.|A movie in t' +
        'he list could match with several movies in database.'
      
        'To do this action, you must first select a key field to compare ' +
        'movies (click on column header).'
      '#empty'
      'Source folder'
      'Browse...|Browse for a folder to scan'
      '&Scan folder')
    Left = 304
    Top = 256
  end
end
