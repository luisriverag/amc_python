inherited ImportFrameCSV: TImportFrameCSV
  inherited grpSettings: TGroupBox
    Height = 128
    object lblDelim: TLabel [3]
      Left = 8
      Top = 104
      Width = 66
      Height = 13
      Caption = 'Field delimiter:'
    end
    object lblQuote: TLabel [4]
      Left = 177
      Top = 104
      Width = 94
      Height = 13
      Caption = 'Text block delimiter:'
    end
    object lblLinebreaks: TLabel [5]
      Left = 376
      Top = 104
      Width = 55
      Height = 13
      Caption = 'Linebreaks:'
    end
    object lblDelimExtras: TLabel [6]
      Left = 375
      Top = 79
      Width = 68
      Height = 13
      Caption = 'Extra delimiter:'
    end
    inherited chkAutoAssign: TCheckBox
      Left = 25
      Top = 76
      Width = 341
    end
    inherited cmbPictures: TComboBox
      TabOrder = 7
    end
    inherited chkAllowClear: TCheckBox
      TabOrder = 3
    end
    object edtQuote: TComboBox
      Left = 300
      Top = 100
      Width = 65
      Height = 22
      Hint = '|Character around text strings (leave empty if none is used)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 5
      Items.Strings = (
        '"'
        #39
        '`')
    end
    object edtDelim: TComboBox
      Left = 101
      Top = 100
      Width = 65
      Height = 22
      Hint = '|Character delimiting fields values'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 8
      Items.Strings = (
        ';'
        ','
        '[tab]')
    end
    object chkFirstLineHeaders: TCheckBox
      Left = 8
      Top = 56
      Width = 313
      Height = 17
      Caption = 'First line contains headers'
      TabOrder = 1
      OnClick = chkFirstLineHeadersClick
    end
    object edtLinebreaks: TComboBox
      Left = 477
      Top = 100
      Width = 65
      Height = 22
      Hint = '|Character to convert to linebreak in descriptions and comments'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 6
      Items.Strings = (
        '|'
        '\n'
        '<br>'
        '<br />')
    end
    object edtDelimExtras: TComboBox
      Left = 477
      Top = 75
      Width = 65
      Height = 22
      Hint = '|Character delimiting extras values for a field'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Courier New'
      Font.Style = []
      ItemHeight = 14
      ParentFont = False
      TabOrder = 9
      Items.Strings = (
        '<+>'
        '<&>')
    end
  end
  inherited grpPreview: TGroupBox
    Top = 193
    Height = 167
    inherited listPreview: TElTree
      Height = 129
      HeaderSections.Data = {F6FFFFFF00000000}
    end
  end
  inherited grpSourceFile: TGroupBox
    Top = 149
  end
end
