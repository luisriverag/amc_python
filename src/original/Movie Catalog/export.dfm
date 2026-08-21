inherited ExportWin: TExportWin
  Left = 506
  Top = 200
  HelpContext = 1020
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'Export to another file format'
  ClientHeight = 482
  ClientWidth = 764
  Constraints.MinHeight = 520
  Constraints.MinWidth = 780
  KeyPreview = True
  OldCreateOrder = True
  OnCloseQuery = FormCloseQuery
  OnDestroy = FormDestroy
  OnKeyUp = FormKeyUp
  DesignSize = (
    764
    482)
  PixelsPerInch = 96
  TextHeight = 13
  inherited Bevel1: TBevel
    Top = 449
    Width = 758
  end
  inherited AntAutoHintLabel1: TAntAutoHintLabel
    Top = 466
    Width = 764
  end
  inherited btn1: TCorelButton
    Left = 686
    Top = 454
    Caption = '&Help'
    TabOrder = 4
    Visible = True
    OnClick = btn1Click
  end
  inherited btn2: TCorelButton
    Left = 608
    Top = 454
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 3
    Visible = True
  end
  inherited btn3: TCorelButton
    Left = 530
    Top = 454
    Caption = '&Export...'
    TabOrder = 2
    Visible = True
    OnClick = btn3Click
  end
  inherited btn4: TCorelButton
    Left = 452
    Top = 454
    TabOrder = 1
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 768
    Height = 446
    Anchors = [akLeft, akTop, akRight, akBottom]
    BevelOuter = bvNone
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 177
      Top = 0
      Height = 446
    end
    object PageControl1: TPageControl
      Left = 180
      Top = 0
      Width = 588
      Height = 446
      ActivePage = tshEmpty
      Align = alClient
      Style = tsFlatButtons
      TabOrder = 1
      TabStop = False
      object tshEmpty: TTabSheet
        Caption = 'Empty'
        object LSelectFormat: TLabel
          Left = 8
          Top = 8
          Width = 113
          Height = 13
          Caption = 'Please select a format...'
        end
      end
      object tshHTML: TTabSheet
        Caption = 'HTML'
        DesignSize = (
          580
          415)
        inline HTMLTemplateEdit1: THTMLTemplateEdit
          Left = 0
          Top = 0
          Width = 580
          Height = 415
          Anchors = [akLeft, akTop, akRight, akBottom]
          TabOrder = 0
          inherited ETemplate: TSynEdit
            Width = 580
            Height = 390
          end
          inherited TBDock1: TTBXDock
            Width = 580
          end
        end
      end
      object tshCSV: TTabSheet
        Caption = 'CSV'
        ImageIndex = 1
        ParentShowHint = False
        ShowHint = True
        DesignSize = (
          580
          415)
        object LCSVDelimiter: TLabel
          Left = 400
          Top = 16
          Width = 66
          Height = 13
          Caption = 'Field delimiter:'
        end
        object LCSVBloc: TLabel
          Left = 400
          Top = 128
          Width = 88
          Height = 13
          Caption = 'Text bloc delimiter:'
        end
        object LCSVLinebreaks: TLabel
          Left = 400
          Top = 184
          Width = 108
          Height = 13
          Caption = 'Replace linebreaks by:'
        end
        object LCSVDelimExtras: TLabel
          Left = 400
          Top = 72
          Width = 68
          Height = 13
          Caption = 'Extra delimiter:'
        end
        object CBCSVColumnTitles: TCheckBox
          Left = 400
          Top = 240
          Width = 176
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Add column titles'
          TabOrder = 4
        end
        inline FieldsCSV: TFieldsFrame
          Left = 0
          Top = 0
          Width = 393
          Height = 414
          Anchors = [akLeft, akTop, akBottom]
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          DesignSize = (
            393
            414)
          inherited LSelected: TLabel
            Left = 216
            Width = 74
            Caption = 'Fields to export:'
          end
          inherited LbSelected: TListBox
            Left = 216
            Width = 177
            Height = 398
          end
          inherited LbAvailable: TListBox
            Width = 177
            Height = 398
          end
          inherited BtnAdd: TTBXButton
            Left = 183
          end
          inherited BtnRem: TTBXButton
            Left = 183
          end
          inherited BtnAddAll: TTBXButton
            Left = 183
          end
          inherited BtnRemAll: TTBXButton
            Left = 183
          end
          inherited BtnUp: TTBXButton
            Left = 183
          end
          inherited BtnDown: TTBXButton
            Left = 183
          end
        end
        object ECSVDelimiter: TComboBox
          Left = 416
          Top = 35
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
          TabOrder = 1
          Items.Strings = (
            ';'
            ','
            '[tab]')
        end
        object ECSVBloc: TComboBox
          Left = 416
          Top = 147
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
          TabOrder = 2
          Items.Strings = (
            '"'
            #39
            '`')
        end
        object ECSVLinebreaks: TComboBox
          Left = 416
          Top = 203
          Width = 65
          Height = 22
          Hint = 
            '|Character to use as representation of linebreaks in description' +
            's and comments'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ItemHeight = 14
          ParentFont = False
          TabOrder = 3
          Items.Strings = (
            ' '
            '|'
            '\n'
            '<br>'
            '<br />')
        end
        object ECSVDelimExtras: TComboBox
          Left = 416
          Top = 91
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
          TabOrder = 5
          Items.Strings = (
            '<+>'
            '<&>')
        end
      end
      object tshSQL: TTabSheet
        Caption = 'SQL'
        ImageIndex = 3
        DesignSize = (
          580
          415)
        object LSQLCommands: TLabel
          Left = 400
          Top = 140
          Width = 127
          Height = 13
          Caption = 'SQL commands to include:'
        end
        object LSQLTableName: TLabel
          Left = 400
          Top = 16
          Width = 59
          Height = 13
          Caption = 'Table name:'
          FocusControl = ESQLTableName
        end
        object LSQLLinebreaks: TLabel
          Left = 400
          Top = 212
          Width = 108
          Height = 13
          Caption = 'Replace linebreaks by:'
        end
        object LSQLTableNameExtras: TLabel
          Left = 402
          Top = 64
          Width = 102
          Height = 13
          Caption = 'Table name of extras:'
          FocusControl = ESQLTableNameExtras
        end
        object CBSQLDrop: TCheckBox
          Left = 416
          Top = 164
          Width = 160
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = '"Drop table if exists"'
          TabOrder = 3
        end
        object CBSQLCreate: TCheckBox
          Left = 416
          Top = 188
          Width = 160
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = '"Create table"'
          TabOrder = 4
        end
        inline FieldsSQL: TFieldsFrame
          Left = 0
          Top = 0
          Width = 393
          Height = 414
          Anchors = [akLeft, akTop, akBottom]
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
          DesignSize = (
            393
            414)
          inherited LSelected: TLabel
            Left = 216
            Width = 74
            Caption = 'Fields to export:'
          end
          inherited LbSelected: TListBox
            Left = 216
            Width = 177
            Height = 398
          end
          inherited LbAvailable: TListBox
            Width = 177
            Height = 398
          end
          inherited BtnAdd: TTBXButton
            Left = 183
          end
          inherited BtnRem: TTBXButton
            Left = 183
          end
          inherited BtnAddAll: TTBXButton
            Left = 183
          end
          inherited BtnRemAll: TTBXButton
            Left = 183
          end
          inherited BtnUp: TTBXButton
            Left = 183
          end
          inherited BtnDown: TTBXButton
            Left = 183
          end
        end
        object ESQLTableName: TEdit
          Left = 416
          Top = 36
          Width = 158
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 1
          Text = 'movies'
        end
        object CBSQLUpdate: TCheckBox
          Left = 400
          Top = 116
          Width = 176
          Height = 17
          Anchors = [akLeft, akTop, akRight]
          Caption = '"Update" instead of "Insert"'
          TabOrder = 2
          OnClick = CBSQLUpdateClick
        end
        object ESQLLinebreaks: TComboBox
          Left = 416
          Top = 231
          Width = 65
          Height = 22
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ItemHeight = 14
          ParentFont = False
          TabOrder = 5
          Items.Strings = (
            ' '
            '|'
            '\n'
            '<br>'
            '<br />')
        end
        object ESQLTableNameExtras: TEdit
          Left = 416
          Top = 84
          Width = 158
          Height = 21
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 6
          Text = 'extras'
        end
      end
      object tshPictures: TTabSheet
        Caption = 'Pictures'
        ImageIndex = 4
        DesignSize = (
          580
          415)
        inline PictureNaming: TFileNamingFrame
          Left = 8
          Top = 8
          Width = 428
          Height = 97
          Anchors = [akLeft, akTop, akRight]
          TabOrder = 0
          DesignSize = (
            428
            97)
          inherited grp: TGroupBox
            Width = 428
          end
        end
        inline Includepic: TIncludepicFrame
          Left = 440
          Top = 8
          Width = 128
          Height = 97
          Anchors = [akTop, akRight]
          TabOrder = 1
          inherited grp: TGroupBox
            Height = 97
          end
        end
      end
      object tshAMC: TTabSheet
        Caption = 'AMC'
        ImageIndex = 6
        DesignSize = (
          580
          415)
        object LAMCNote: TLabel
          Left = 8
          Top = 8
          Width = 561
          Height = 57
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            'You can also export to AMC from the main window using the File -' +
            '> Save As command, then select AMC as file format. This file can' +
            ' later be opened and used by Ant Movie Catalog like a normal cat' +
            'alog.'
          WordWrap = True
        end
        inline PictureOperationExportAMC: TPictureOperationExportFrame
          Left = 4
          Top = 56
          Width = 568
          Height = 186
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          DesignSize = (
            568
            186)
          inherited grp: TGroupBox
            Width = 560
            Caption = 'Pictures exportation method for movies'
            DesignSize = (
              560
              184)
            inherited rbtNoChangeXML: TRadioButton
              Width = 544
            end
            inherited rbtStore: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDir: TRadioButton
              Width = 544
            end
            inherited rbtStoreIfCopied: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtDelete: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDir: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtNoChangeAMC: TRadioButton
              Width = 544
            end
          end
        end
        inline ExtraPictureOperationExportAMC: TPictureOperationExportFrame
          Left = 4
          Top = 247
          Width = 568
          Height = 186
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 1
          DesignSize = (
            568
            186)
          inherited grp: TGroupBox
            Width = 560
            Caption = 'Pictures exportation method for extras'
            DesignSize = (
              560
              184)
            inherited rbtNoChangeXML: TRadioButton
              Width = 544
            end
            inherited rbtStore: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDir: TRadioButton
              Width = 544
            end
            inherited rbtStoreIfCopied: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtDelete: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDir: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtNoChangeAMC: TRadioButton
              Width = 544
            end
          end
        end
      end
      object tshXML: TTabSheet
        Caption = 'XML'
        ImageIndex = 7
        DesignSize = (
          580
          415)
        object LXMLNote: TLabel
          Left = 8
          Top = 8
          Width = 561
          Height = 57
          Anchors = [akLeft, akTop, akRight]
          AutoSize = False
          Caption = 
            'You can also export to XML from the main window using the File -' +
            '> Save As command, then select XML as file format. This file can' +
            ' later be opened and used by Ant Movie Catalog like a normal cat' +
            'alog.'
          WordWrap = True
        end
        inline PictureOperationExportXML: TPictureOperationExportFrame
          Left = 4
          Top = 56
          Width = 568
          Height = 186
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 0
          DesignSize = (
            568
            186)
          inherited grp: TGroupBox
            Width = 560
            Caption = 'Pictures exportation method for movies'
            DesignSize = (
              560
              184)
            inherited rbtNoChangeXML: TRadioButton
              Width = 544
            end
            inherited rbtStore: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDir: TRadioButton
              Width = 544
            end
            inherited rbtStoreIfCopied: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtDelete: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDir: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtNoChangeAMC: TRadioButton
              Width = 544
            end
          end
        end
        inline ExtraPictureOperationExportXML: TPictureOperationExportFrame
          Left = 4
          Top = 247
          Width = 568
          Height = 186
          Anchors = [akLeft, akTop, akRight]
          Ctl3D = True
          ParentCtl3D = False
          TabOrder = 1
          DesignSize = (
            568
            186)
          inherited grp: TGroupBox
            Width = 560
            Caption = 'Pictures exportation method for extras'
            DesignSize = (
              560
              184)
            inherited rbtNoChangeXML: TRadioButton
              Width = 544
            end
            inherited rbtStore: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDir: TRadioButton
              Width = 544
            end
            inherited rbtStoreIfCopied: TRadioButton
              Width = 544
            end
            inherited rbtCopyInCatDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtDelete: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDir: TRadioButton
              Width = 544
            end
            inherited rbtCopyInPicDirIfStored: TRadioButton
              Width = 544
            end
            inherited rbtNoChangeAMC: TRadioButton
              Width = 544
            end
          end
        end
      end
    end
    object pnlLeft: TPanel
      Left = 0
      Top = 0
      Width = 177
      Height = 446
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object LvFormat: TListView
        Left = 0
        Top = 0
        Width = 177
        Height = 167
        Align = alClient
        Columns = <
          item
            AutoSize = True
            Caption = 'Supported file formats'
          end>
        ColumnClick = False
        HideSelection = False
        Items.Data = {
          AB0000000600000000000000FFFFFFFFFFFFFFFF00000000000000000448544D
          4C01000000FFFFFFFFFFFFFFFF0000000000000000104353562054657874202F
          20457863656C02000000FFFFFFFFFFFFFFFF00000000000000000353514C0300
          0000FFFFFFFFFFFFFFFF000000000000000008506963747572657305000000FF
          FFFFFFFFFFFFFF000000000000000003414D4304000000FFFFFFFFFFFFFFFF00
          0000000000000003584D4C}
        ReadOnly = True
        RowSelect = True
        SmallImages = ImageListFormat
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = LvFormatSelectItem
      end
      inline SortBy: TSortByFrame
        Left = 0
        Top = 167
        Width = 177
        Height = 76
        Hint = '|Sort in descending order'
        Align = alBottom
        TabOrder = 1
        inherited grp: TGroupBox
          Width = 177
          Height = 76
          inherited EOrderBy: TComboBox
            Width = 157
            ItemIndex = 4
            Text = 'Advanced sort options...'
          end
          inherited BtnAdvSort: TCorelButton
            Left = 10
            Top = 46
            Anchors = [akLeft, akTop, akRight]
          end
          inherited BtnSortDescend: TTBXButton
            Left = 144
            Top = 44
          end
        end
      end
      inline Includemov: TIncludemovFrame
        Left = 0
        Top = 243
        Width = 177
        Height = 101
        Align = alBottom
        TabOrder = 2
        inherited grp: TGroupBox
          Width = 177
          Height = 101
          inherited rbtAll: TRadioButton
            Width = 158
            OnClick = IncludemovClick
          end
          inherited rbtSelected: TRadioButton
            Width = 158
            OnClick = IncludemovClick
          end
          inherited rbtChecked: TRadioButton
            Width = 158
            OnClick = IncludemovClick
          end
          inherited rbtVisible: TRadioButton
            Width = 158
            OnClick = IncludemovClick
          end
        end
      end
      object grpImages: TGroupBox
        Left = 0
        Top = 344
        Width = 177
        Height = 102
        Align = alBottom
        Caption = 'Pictures'
        TabOrder = 3
        DesignSize = (
          177
          102)
        object CBCopyPictures: TCheckBox
          Left = 10
          Top = 18
          Width = 162
          Height = 17
          Hint = 'Copy pictures to the same folder as the exported file'
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Copy with exported file'
          TabOrder = 0
          OnClick = CBCopyPicturesClick
        end
        object CBCopyPicturesNew: TCheckBox
          Left = 26
          Top = 58
          Width = 146
          Height = 17
          Hint = 
            'Copy only file pictures that do not exist yet (i.e. no overwrite' +
            ')'
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Only if it does not exist yet'
          TabOrder = 2
        end
        object CBCopyPicturesInPicDir: TCheckBox
          Left = 26
          Top = 38
          Width = 146
          Height = 17
          Hint = 'Copy pictures into a subfolder pictures'
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Into a subfolder'
          TabOrder = 1
        end
        object CBCopyPicturesIncExtras: TCheckBox
          Left = 26
          Top = 78
          Width = 146
          Height = 17
          Hint = 'Include extra pictures'
          Anchors = [akLeft, akTop, akRight]
          Caption = 'Include extras'
          TabOrder = 3
        end
      end
    end
  end
  object ImageListFormat: TImageList
    Left = 96
    Top = 120
    Bitmap = {
      494C010106000900040010001000FFFFFFFFFF00FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008080800000000000D46C
      6C00D46C6C00D46C6C00DC747400DC747400DC747400DC747400DC7C7C00E47C
      7C00E47C7C000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F1F1
      F10000000000F1F1F10000000000F1F1F10000000000F1F1F10000000000F1F1
      F10000000000F1F1F100000000000000000000000000FFFFFF0000000000CC64
      6400CC6C6C00D46C6C00D4747400DC747400DC747400DC747400DC7C7C00E47C
      7C00E47C7C0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      0000F1F1F10000000000F1F1F10000000000F1F1F10000000000F1F1F1000000
      0000F1F1F10000000000F1F1F100000000000000000080808000000000000404
      0400040404000404040004040400040404000404040004040400040404000404
      0400040404000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F1F1
      F100996633009966330099663300996633009966330099663300996633009966
      330099663300F1F1F100000000000000000000000000FFFFFF0000000000EC84
      8400F48C8C00F48C8C00F48C8C00F48C8C00F4949400FC949400FC949400FC94
      9400FC94940000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      0000F1F1F10000000000F1F1F10000000000F1F1F10000000000F1F1F1000000
      0000F1F1F10000000000F1F1F10000000000000000008080800000000000EC84
      8400EC848400EC848400EC8C8C00F48C8C00F48C8C00F4949400F4949400FC94
      9400FC9494000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F1F1
      F100996633009966330099663300996633009966330099663300996633009966
      330099663300F1F1F100000000000000000000000000FFFFFF0000000000E484
      8400EC848400EC848400EC8C8C00F48C8C00F48C8C00F4949400FC949400FC94
      9400FC94940000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      0000F1F1F10000000000F1F1F10000000000F1F1F10000000000F1F1F1000000
      0000F1F1F10000000000F1F1F10000000000000000008080800000000000E47C
      7C00EC848400EC848400EC848400EC8C8C00F48C8C00F48C8C00F4949400FC94
      9400FC9494000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F1F1
      F100F0CAA600F1F1F1000000000080000000800000008000000000000000F1F1
      F100F0CAA600F1F1F100000000000000000000000000FFFFFF0000000000E47C
      7C00E47C7C00EC848400EC848400EC848400EC8C8C00F48C8C00F48C8C00F48C
      8C00F48C8C0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F0CA
      A6009900000000000000FF663300FF99330000993300FF000000800000000000
      000099000000F0CAA600F1F1F10000000000000000008080800000000000DC7C
      7C00E47C7C00E4848400E4848400EC848400EC848400EC848400EC848400EC8C
      8C00EC8C8C000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600F0CAA6009900
      000000000000F1F1F10080800000FFFF3300FFCC33000099330080000000F1F1
      F1000000000099000000F0CAA6000000000000000000FFFFFF0000000000DC74
      7400E47C7C00E47C7C00E47C7C00E4848400E4848400EC848400EC848400EC84
      8400EC84840000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F0CA
      A60099000000000000008080000000000000FFFF3300FF993300800000000000
      000099000000F0CAA600F1F1F10000000000000000008080800000000000DC74
      7400DC747400DC747400E47C7C00E47C7C00E47C7C00E47C7C00EC848400EC84
      8400EC8484000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000008686860000000000F1F1
      F100F0CAA600F1F1F100000000008080000080800000FF66330000000000F1F1
      F100F0CAA600F1F1F100000000000000000000000000FFFFFF0000000000DC74
      7400DC747400DC747400DC7C7C00E47C7C00E47C7C00E47C7C00E47C7C00E484
      8400E484840000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      0000F1F1F10000000000F1F1F10000000000F1F1F10000000000F1F1F1000000
      000000000000000000000000000000000000000000008080800000000000D46C
      6C00D46C6C00D4747400DC747400DC747400E47C7C00E47C7C00E47C7C00EC84
      8400EC8484000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      00000000000000000000000000000000000000000000F1F1F10000000000F1F1
      F100C0C0C00000000000868686000000000000000000FFFFFF0000000000D46C
      6C00D46C6C00D46C6C00DC747400DC747400DC747400DC747400DC7C7C00E47C
      7C00E47C7C0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0008686860000000000000000000000000080808000000000000404
      0400040404000404040004040400040404000404040004040400040404000404
      0400040404000000000080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000086868600868686008686
      8600868686008686860086868600868686008686860086868600868686008686
      86008686860000000000000000000000000000000000FFFFFF0000000000CC64
      6400CC6C6C00D46C6C00D4747400DC747400DC747400DC747400DC7C7C00E47C
      7C00E47C7C0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D4CFCC00A0948E007E6F
      660075645B0074635A0074635A0074635A0074635A0074635A0074635A007564
      5B007E6F6600A0948E00D4CFCC00000000000000000000000000000000007777
      7700555555005555550055555500555555005555550055555500555555005555
      5500555555005555550055555500000000000000000000000000000000008080
      8000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0
      C000C0C0C00000000000C0C0C00000000000000000000000000080808000C0C0
      C00000FF0000C0C0C000C0C0C000C0C0C000C0C0C00000000000000000000000
      00000000000000000000000000000000000000000000AE7C6F00D9AD9D00D6A8
      9A00D3A69800D2A49700CCA19900C99E9700C69C9600C4999500C1969300B691
      8B00B88E8B007F706700C5BDBA00000000000000000000000000000000007777
      7700CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCCCC00CCCC
      CC00CCCCCC00CCCCCC0055555500000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C00000000000000000000000000080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000B5827300E6DBD100FFE8
      D100FFE6CC00FFE2C500FFE0C100FFDDBB00FFDAB600FFD8B100FFD4AA00FFD2
      A500EEBDA50075645B00C1B9B500000000000000000000000000CC3333007777
      7700FFFFFF00EAEAEA00EAEAEA00D6E7E700D6E7E700EAEAEA00D6E7E700D6E7
      E700D6E7E700CCCCCC0055555500000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BB887600E8DFD500FDE8
      D100F6D2AE00F6D0A900F6CDA400F6CBA000F6C99C00F6C79700F6C49300FDD1
      A500EFBFA80074635A00C0B8B4000000000000000000CC333300A4A0A0000404
      040004040400996600009966000099660000EAEAEA00D6E7E700EAEAEA00D6E7
      E700D6E7E700CCCCCC0055555500000000000080000000800000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      00000000000000000000C0C0C00000000000000000000000000080808000C0C0
      C000C0C0C000C0C0C000C0C0C000C0C0C000C0C0C00000000000C0C0C000C0C0
      C000C0C0C00080808000000000000000000000000000C28F7A00EAE2DB00C292
      9800B6818A00AF819000AC8293009B90AA0086BAD9007EC0E400A88C9D00E6A8
      7400F0C1AB0074635A00C0B8B4000000000000808000CC33330066333300CC33
      3300FF663300FF663300FF663300FF66330099660000EAEAEA00D6E7E700EAEA
      EA00D6E7E700CCCCCC0055555500000000000080000000000000000000000000
      0000000000000000000000000000000000000000000000800000000000000000
      00000000000000000000C0C0C00000000000000000000000000080808000FFFF
      FF0050320000B97A0000B97A000096620000C0C0C00000000000C0C0C0000000
      FF00C0C0C00080808000808080000000000000000000C8957D00ECE6DF00AC97
      AC00A57D8F00B8696C009486A60082C4E30086E7FA0080E6FF009397B500DEA5
      7500F0C3AF0074635A00C0B8B400000000005F5F5F006699990099330000FF66
      3300FF663300C0C0C000C0C0C000CC333300FF66330099660000EAEAEA00D6E7
      E700D6E7E700CCCCCC0055555500000000000080000000000000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      00000000000000000000C0C0C00000000000000000000000000080808000FFFF
      FF0050320000FFD48E00FFAA000096620000C0C0C00000000000C0C0C000C0C0
      C000C0C0C00080808000808080000000000000000000CF9C8100EEE9E400959C
      C2007A88BA00444158007083B700749FD30082C6E5007CCAED007D90C100DAA7
      7C00F1C5B10074635A00C0B8B40000000000777777006699CC00CC663300FF66
      3300CC660000F0FBFF00F0FBFF00F1F1F100F0FBFF00EAEAEA00D6E7E700EAEA
      EA00D6E7E700CCCCCC0055555500000000000080000000000000008000000080
      000000800000C0C0C00000800000008000000080000000800000000000000000
      00000000000000000000C0C0C00000000000000000000000000080808000FFFF
      FF0050320000503200005032000050320000C0C0C00000000000FFFFFF00FFFF
      FF00FFFFFF0080808000808080000000000000000000D5A28300F0ECE9007FA1
      D700537DB7002E4363005790DB005499E6007AD4F6007FDBF7006093D900D4A9
      8300F2C8B50074635A00C0B8B40000000000000000007777770099CCFF00FF66
      3300CC660000CC660000CC660000CC660000CC660000CC660000EAEAEA00D6E7
      E700D6E7E700CCCCCC0055555500000000000080000000000000000000000080
      0000C0C0C0000080000000800000008000000000000000800000000000000000
      00000000000000000000C0C0C00000000000808080008080800080808000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000808080008080
      80008080800000000000808080000000000000000000DCA98700F2F0EE005E91
      E000325B9A002C62A0003583EC00378CF30065BEF700378BF5003F87EA00CEA9
      8800F2C9B70074635A00C0B8B4000000000000000000800000006699990099FF
      FF00CC660000F0FBFF00F0FBFF00CC333300FFCC0000CC660000F1F1F100EAEA
      EA00D6E7E700CCCCCC005555550000000000008000000000000000800000C0C0
      C000008000000080000000800000000000000000000000800000000000000000
      00000000000000000000C0C0C0000000000080808000FFFFFF00808080008080
      80008080800080808000808080008080800080808000C0C0C000C0C0C000C0C0
      C000C0C0C00080808000000000000000000000000000DCA98700F4F3F300323A
      B70028346F001335B2001C3BC8001F42D5002A59EA002C5DEE002249DB00C79D
      8700F3CCBA0074635A00C0B8B400000000000000000000000000800000009999
      6600CCCC9900CC333300CC333300FFFF6600CC660000F1F1F100F0FBFF00EAEA
      EA00CCCCCC009999990055555500000000000080000000000000C0C0C0000080
      0000008000000080000000800000008000000000000000800000000000000000
      00000000000000000000C0C0C0000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000808080000000000000000000DCA98700F6F6F6005687
      FF003160B9003977FF004996FF005AB5FF0099DDFF0076CFFF0054AAFD00CEAD
      9100F3CDBD0079686000C3BBB700000000000000000000000000000000008000
      0000CC660000CC660000CC660000CC660000F0FBFF00FF663300F1F1F100CCCC
      CC00999999007777770055555500000000000080000000000000008000000080
      0000000000000000000000800000008000000000000000800000000000000000
      00000000000000000000C0C0C0000000000080808000FFFFFF00808080008080
      8000FFFFFF008080800080808000FFFFFF008080800080808000808080008080
      80008080800000000000808080000000000000000000DCA98700F8F8F800789F
      FF00356DF7003775FF00468FFF0055ACFF0061C1FF00FFF1E200FFEEDC00FFEB
      D600F4C9BA008A7A7100CDC6C200000000000000000000000000000000008686
      8600FFFFFF00F0FBFF00F0FBFF00CC660000CC660000F0FBFF00F0FBFF005555
      5500333333003333330033333300000000000080000000000000000000000000
      0000000000000000000000000000000000000000000000800000000000000000
      00000000000000000000000000000000000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0080808000C0C0C000C0C0C000C0C0
      C000C0C0C00080808000000000000000000000000000DCA98700FAFAFA00FFFF
      FF00FFFFFF00FFFEFE00FFFCF900FFFAF400FFF6ED00FFD5CC00FFD5CC00F5B3
      AA00B4897F00AA9E9700DFD9D700000000000000000000000000000000008686
      8600FFFFFF00F0FBFF00F0FBFF00F0FBFF00F0FBFF00F0FBFF00F0FBFF009999
      9900FFFFFF005555550000000000000000000080000000800000008000000080
      0000008000000080000000800000008000000080000000800000000000000000
      00008080800000000000000000000000000080808000FF8F6B00FF734800FF73
      4800FF572500FF572500DC490000B93D000080808000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0080808000808080000000000000000000DCA98700FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFEFE00FFFCF900FFFAF400F7A64400F7A64400E093
      420097877E00CEC5C100F1EEEC00000000000000000000000000000000008686
      8600FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF009999
      9900555555000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000808080000000000000000000000000008080800080808000808080008080
      8000808080008080800080808000808080008080800080808000C0C0C000C0C0
      C000C0C0C000C0C0C000808080000000000000000000DCA98700FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFEFE00FFFCF900DCA98700EAB477008D75
      6400BBB0AA00E7E3E000FAF9F800000000000000000000000000000000008686
      8600868686008686860086868600868686008686860086868600868686008686
      8600000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080008080
      80008080800080808000808080000000000000000000DCA98700DCA98700DCA9
      8700DCA98700DCA98700DCA98700DEAB8800D6A38400DCA98700F9F1EB000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000008000000000000000AAAA000000000000
      B554000000000000A002000000000000B554000000000000A002000000000000
      B554000000000000A222000000000000A4100000000000008808000000000000
      A510000000000000A222000000000000B550000000000000BFA5000000000000
      BFF30000000000008007000000000000FFFFE000E07F8001E001E000C03F8001
      E001EF08C03F8001C001EF6CE00380018001000CC001800100017FACC0008001
      0001400CC00080010001403C00008001800160BC00008001800141BC00008001
      C00140BC00008001E0014CBC00008001E0017FB000008001E003003500008001
      E007EFF300008001E00FE007FFC1801F}
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Initializing...'
      'Exporting to %s ...'
      'Copying files ...'
      'Export to HTML'
      'Export to CSV'
      'Export to SQL'
      'Export images'
      'Export to file for Origons.com'
      'Export to AMC'
      'Export to XML'
      
        'You can not export a catalog to the same location of current cat' +
        'alog!')
    Left = 120
    Top = 272
  end
end
