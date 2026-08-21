object HTMLTemplateEdit: THTMLTemplateEdit
  Left = 0
  Top = 0
  Width = 630
  Height = 473
  TabOrder = 0
  object ETemplate: TSynEdit
    Left = 0
    Top = 25
    Width = 630
    Height = 448
    Align = alClient
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    PopupMenu = PopupHTML
    TabOrder = 0
    BookMarkOptions.DrawBookmarksFirst = False
    BookMarkOptions.EnableKeys = False
    BookMarkOptions.GlyphsVisible = False
    Gutter.AutoSize = True
    Gutter.Font.Charset = DEFAULT_CHARSET
    Gutter.Font.Color = clWindowText
    Gutter.Font.Height = -11
    Gutter.Font.Name = 'Terminal'
    Gutter.Font.Style = []
    Gutter.LeftOffset = 0
    Gutter.ShowLineNumbers = True
    Gutter.Width = 0
    Highlighter = SynHTMLSyn1
    Options = [eoAutoIndent, eoDragDropEditing, eoGroupUndo, eoScrollPastEol, eoShowScrollHint, eoSmartTabDelete, eoTabsToSpaces, eoTrimTrailingSpaces]
    TabWidth = 2
    WantTabs = True
    OnChange = ETemplateChange
    RemovedKeystrokes = <
      item
        Command = ecContextHelp
        ShortCut = 112
      end>
    AddedKeystrokes = <
      item
        Command = ecContextHelp
        ShortCut = 16496
      end>
  end
  object TBDock1: TTBXDock
    Left = 0
    Top = 0
    Width = 630
    Height = 25
    object ToolbarHTML: TTBXToolbar
      Left = 188
      Top = 0
      AutoResize = False
      BorderStyle = bsNone
      Caption = 'ToolbarHTML'
      DefaultDock = TBDock1
      DockMode = dmCannotFloatOrChangeDocks
      DockPos = 159
      Resizable = False
      ShrinkMode = tbsmNone
      TabOrder = 1
      object BtnNewTemplate: TTBXItem
        Action = ActionHTMLNew
      end
      object BtnLoadTemplate: TTBXSubmenuItem
        Action = ActionHTMLOpen
        DropdownCombo = True
        object BtnNoRecentTemplate: TTBXItem
          Action = ActionHTMLNoRecent
        end
        object TBMRUListItem1: TTBXMRUListItem
          MRUList = TBMRUList1
        end
      end
      object BtnSaveTemplate: TTBXItem
        Action = ActionHTMLSave
      end
      object BtnSaveAsTemplate: TTBXItem
        Action = ActionHTMLSaveAs
      end
      object btnSeparator1: TTBXSeparatorItem
      end
      object BtnInsertTag: TTBXSubmenuItem
        Action = ActionInsertTag
        Options = [tboDropdownArrow]
        object MnuGen: TTBXSubmenuItem
          Caption = '&General'
          object MnuGenDte: TTBXItem
            Caption = 'Current Date'
            OnClick = MnuGenDteClick
          end
          object MnuGenTme: TTBXItem
            Caption = 'Current Time'
            OnClick = MnuGenTmeClick
          end
        end
        object MnuCat: TTBXSubmenuItem
          Caption = '&Catalog'
          object MnuCatNme: TTBXItem
            Caption = 'File Name'
            OnClick = MnuCatNmeClick
          end
          object MnuCatPth: TTBXItem
            Caption = 'File Name with full path'
            OnClick = MnuCatPthClick
          end
          object MnuCatNbr: TTBXItem
            Caption = 'Number of movies'
            OnClick = MnuCatNbrClick
          end
          object MnuCatDsk: TTBXItem
            Caption = 'Number of disks'
            OnClick = MnuCatDskClick
          end
          object MnuCat__1: TTBXSeparatorItem
          end
          object MnuOwnNam: TTBXItem
            Caption = 'Owner Name'
            OnClick = MnuOwnNamClick
          end
          object MnuOwnEml: TTBXItem
            Caption = 'Owner E-mail'
            OnClick = MnuOwnEmlClick
          end
          object MnuOwnWeb: TTBXItem
            Caption = 'Owner website address'
            OnClick = MnuOwnWebClick
          end
          object MnuCatDsc: TTBXItem
            Caption = 'Description'
            OnClick = MnuCatDscClick
          end
          object MnuCat__2: TTBXSeparatorItem
            Tag = -1
          end
          object MnuMovBeg: TTBXItem
            Tag = -1
            Caption = 'Begin List'
            OnClick = MnuMovBegClick
          end
          object MnuMovEnd: TTBXItem
            Tag = -1
            Caption = 'End List'
            OnClick = MnuMovEndClick
          end
          object MnuMovRec: TTBXItem
            Tag = -1
            Caption = 'Record number'
            OnClick = MnuMovRecClick
          end
          object MnuMovInd: TTBXItem
            Tag = -1
            Caption = 'Filename of individual movie page'
            OnClick = MnuMovIndClick
          end
        end
        object MnuLab: TTBXSubmenuItem
          Caption = '&Labels movie fields'
          object MnuLabNum: TTBXItem
            Tag = -1
            Caption = 'Number'
            OnClick = MnuLabNumClick
          end
          object MnuLabChk: TTBXItem
            Tag = -1
            Caption = 'Checked'
            OnClick = MnuLabChkClick
          end
          object MnuLabCol: TTBXItem
            Tag = -1
            Caption = 'Color Tag'
            OnClick = MnuLabColClick
          end
          object MnuLabMed: TTBXItem
            Tag = -1
            Caption = 'Media Label'
            OnClick = MnuLabMedClick
          end
          object MnuLabTyp: TTBXItem
            Tag = -1
            Caption = 'Media Type'
            OnClick = MnuLabTypClick
          end
          object MnuLabSrc: TTBXItem
            Tag = -1
            Caption = 'Source'
            OnClick = MnuLabSrcClick
          end
          object MnuLabDte: TTBXItem
            Tag = -1
            Caption = 'Date added'
            OnClick = MnuLabDteClick
          end
          object MnuLabBor: TTBXItem
            Tag = -1
            Caption = 'Borrower'
            OnClick = MnuLabBorClick
          end
          object MnuLabDtW: TTBXItem
            Caption = 'Date Watched'
            OnClick = MnuLabDtWClick
          end
          object MnuLabURat: TTBXItem
            Tag = -1
            Caption = 'My Rating'
            OnClick = MnuLabURatClick
          end
          object MnuLabRat: TTBXItem
            Tag = -1
            Caption = 'Rating'
            OnClick = MnuLabRatClick
          end
          object MnuLabOrT: TTBXItem
            Tag = -1
            Caption = 'Original Title'
            OnClick = MnuLabOrTClick
          end
          object MnuLabTrT: TTBXItem
            Tag = -1
            Caption = 'Translated Title'
            OnClick = MnuLabTrTClick
          end
          object MnuLabFoT: TTBXItem
            Tag = -1
            Caption = 'Formatted Title'
            OnClick = MnuLabFoTClick
          end
          object MnuLabDir: TTBXItem
            Tag = -1
            Caption = 'Director'
            OnClick = MnuLabDirClick
          end
          object MnuLabPro: TTBXItem
            Tag = -1
            Caption = 'Producer'
            OnClick = MnuLabProClick
          end
          object MnuLabWrt: TTBXItem
            Tag = -1
            Caption = 'Writer'
            OnClick = MnuLabWrtClick
          end
          object MnuLabCmp: TTBXItem
            Tag = -1
            Caption = 'Composer'
            OnClick = MnuLabCmpClick
          end
          object MnuLabAct: TTBXItem
            Tag = -1
            Caption = 'Actors'
            OnClick = MnuLabActClick
          end
          object MnuLabCou: TTBXItem
            Tag = -1
            Caption = 'Country'
            OnClick = MnuLabCouClick
          end
          object MnuLabYea: TTBXItem
            Tag = -1
            Caption = 'Year'
            OnClick = MnuLabYeaClick
          end
          object MnuLabLen: TTBXItem
            Tag = -1
            Caption = 'Length'
            OnClick = MnuLabLenClick
          end
          object MnuLabCat: TTBXItem
            Tag = -1
            Caption = 'Category'
            OnClick = MnuLabCatClick
          end
          object MnuLabCer: TTBXItem
            Tag = -1
            Caption = 'Certification'
            OnClick = MnuLabCerClick
          end
          object MnuLabURL: TTBXItem
            Tag = -1
            Caption = 'URL'
            OnClick = MnuLabURLClick
          end
          object MnuLabDsc: TTBXItem
            Tag = -1
            Caption = 'Description'
            OnClick = MnuLabDscClick
          end
          object MnuLabCom: TTBXItem
            Tag = -1
            Caption = 'Comments'
            OnClick = MnuLabComClick
          end
          object MnuLabFil: TTBXItem
            Tag = -1
            Caption = 'File Path'
            OnClick = MnuLabFilClick
          end
          object MnuLabVfm: TTBXItem
            Tag = -1
            Caption = 'Video Format'
            OnClick = MnuLabVfmClick
          end
          object MnuLabVbr: TTBXItem
            Tag = -1
            Caption = 'Video Bitrate'
            OnClick = MnuLabVbrClick
          end
          object MnuLabAfm: TTBXItem
            Tag = -1
            Caption = 'Audio Format'
            OnClick = MnuLabAfmClick
          end
          object MnuLabAbr: TTBXItem
            Tag = -1
            Caption = 'Audio Bitrate'
            OnClick = MnuLabAbrClick
          end
          object MnuLabRes: TTBXItem
            Tag = -1
            Caption = 'Resolution'
            OnClick = MnuLabResClick
          end
          object MnuLabFps: TTBXItem
            Tag = -1
            Caption = 'Framerate'
            OnClick = MnuLabFpsClick
          end
          object MnuLabLng: TTBXItem
            Tag = -1
            Caption = 'Languages'
            OnClick = MnuLabLngClick
          end
          object MnuLabSub: TTBXItem
            Tag = -1
            Caption = 'Subtitles'
            OnClick = MnuLabSubClick
          end
          object MnuLabSiz: TTBXItem
            Tag = -1
            Caption = 'Size'
            OnClick = MnuLabSizClick
          end
          object MnuLabDsk: TTBXItem
            Tag = -1
            Caption = 'Disks'
            OnClick = MnuLabDskClick
          end
          object MnuLabPst: TTBXItem
            Tag = -1
            Caption = 'Picture Status'
            OnClick = MnuLabPstClick
          end
          object MnuLabNbE: TTBXItem
            Tag = -1
            Caption = 'Nb Extras'
            OnClick = MnuLabNbEClick
          end
          object MnuLabPic: TTBXItem
            Tag = -1
            Caption = 'Picture'
            OnClick = MnuLabPicClick
          end
          object MnuLabUAF: TTBXItem
            Tag = -1
            Caption = 'Unit audio bitrate'
            OnClick = MnuLabUAFClick
          end
          object MnuLabUVF: TTBXItem
            Tag = -1
            Caption = 'Unit video bitrate'
            OnClick = MnuLabUVFClick
          end
          object MnuLabUFS: TTBXItem
            Tag = -1
            Caption = 'Unit file size'
            OnClick = MnuLabUFSClick
          end
          object MnuLabUFP: TTBXItem
            Tag = -1
            Caption = 'Unit frame rate'
            OnClick = MnuLabUFPClick
          end
        end
        object MnuLabCF: TTBXSubmenuItem
          Caption = '&Labels custom fields'
        end
        object MnuLabExtras: TTBXSubmenuItem
          Caption = '&Labels extra fields'
          object MnuLabENum: TTBXItem
            Tag = -1
            Caption = 'Number'
            OnClick = MnuLabENumClick
          end
          object MnuLabEChk: TTBXItem
            Tag = -1
            Caption = 'Checked'
            OnClick = MnuLabEChkClick
          end
          object MnuLabETag: TTBXItem
            Tag = -1
            Caption = 'Tag'
            OnClick = MnuLabETagClick
          end
          object MnuLabETit: TTBXItem
            Tag = -1
            Caption = 'Title'
            OnClick = MnuLabETitClick
          end
          object MnuLabECat: TTBXItem
            Tag = -1
            Caption = 'Category'
            OnClick = MnuLabECatClick
          end
          object MnuLabEURL: TTBXItem
            Tag = -1
            Caption = 'URL'
            OnClick = MnuLabEURLClick
          end
          object MnuLabEDsc: TTBXItem
            Tag = -1
            Caption = 'Description'
            OnClick = MnuLabEDscClick
          end
          object MnuLabECom: TTBXItem
            Tag = -1
            Caption = 'Comments'
            OnClick = MnuLabEComClick
          end
          object MnuLabECby: TTBXItem
            Tag = -1
            Caption = 'Created by'
            OnClick = MnuLabECbyClick
          end
          object MnuLabEPst: TTBXItem
            Tag = -1
            Caption = 'Picture Status'
            OnClick = MnuLabEPstClick
          end
          object MnuLabEPic: TTBXItem
            Tag = -1
            Caption = 'Picture'
            OnClick = MnuLabEPicClick
          end
        end
        object MnuMov: TTBXSubmenuItem
          Caption = '&Movie fields'
          object MnuMovNum: TTBXItem
            Tag = -1
            Caption = 'Number'
            OnClick = MnuMovNumClick
          end
          object MnuMovChk: TTBXItem
            Tag = -1
            Caption = 'Checked'
            OnClick = MnuMovChkClick
          end
          object MnuMovCol: TTBXItem
            Tag = -1
            Caption = 'Color Tag'
            OnClick = MnuMovColClick
          end
          object MnuMovHtm: TTBXItem
            Tag = -1
            Caption = 'Color Tag (HTML)'
            OnClick = MnuMovHtmClick
          end
          object MnuMovMed: TTBXItem
            Tag = -1
            Caption = 'Media Label'
            OnClick = MnuMovMedClick
          end
          object MnuMovTyp: TTBXItem
            Tag = -1
            Caption = 'Media Type'
            OnClick = MnuMovTypClick
          end
          object MnuMovSrc: TTBXItem
            Tag = -1
            Caption = 'Source'
            OnClick = MnuMovSrcClick
          end
          object MnuMovDte: TTBXItem
            Tag = -1
            Caption = 'Date added'
            OnClick = MnuMovDteClick
          end
          object MnuMovBor: TTBXItem
            Tag = -1
            Caption = 'Borrower'
            OnClick = MnuMovBorClick
          end
          object MnuMovDtW: TTBXItem
            Caption = 'Date Watched'
            OnClick = MnuMovDtWClick
          end
          object MnuMovURat: TTBXItem
            Tag = -1
            Caption = 'My Rating'
            OnClick = MnuMovURatClick
          end
          object MnuMovUR04: TTBXItem
            Tag = -1
            Caption = 'My Rating (0 to 4 without decimal)'
            OnClick = MnuMovUR04Click
          end
          object MnuMovUR10: TTBXItem
            Tag = -1
            Caption = 'My Rating (0 to 10 without decimal)'
            OnClick = MnuMovUR10Click
          end
          object MnuMovUA04: TTBXItem
            Tag = -1
            Caption = 'My Appreciation (0 to 4 stars)'
            OnClick = MnuMovUA04Click
          end
          object MnuMovUA10: TTBXItem
            Tag = -1
            Caption = 'My Appreciation (0 to 10 stars)'
            OnClick = MnuMovUA10Click
          end
          object MnuMovRat: TTBXItem
            Tag = -1
            Caption = 'Rating'
            OnClick = MnuMovRatClick
          end
          object MnuMovR04: TTBXItem
            Tag = -1
            Caption = 'Rating (0 to 4 without decimal)'
            OnClick = MnuMovR04Click
          end
          object MnuMovR10: TTBXItem
            Tag = -1
            Caption = 'Rating (0 to 10 without decimal)'
            OnClick = MnuMovR10Click
          end
          object MnuMovApp: TTBXItem
            Tag = -1
            Caption = 'Appreciation (0 to 4 stars)'
            OnClick = MnuMovAppClick
          end
          object MnuMovA10: TTBXItem
            Tag = -1
            Caption = 'Appreciation (0 to 10 stars)'
            OnClick = MnuMovA10Click
          end
          object MnuMovOrT: TTBXItem
            Tag = -1
            Caption = 'Original Title'
            OnClick = MnuMovOrTClick
          end
          object MnuMovTrT: TTBXItem
            Tag = -1
            Caption = 'Translated Title'
            OnClick = MnuMovTrTClick
          end
          object MnuMovFoT: TTBXItem
            Tag = -1
            Caption = 'Formatted Title'
            OnClick = MnuMovFoTClick
          end
          object MnuMovFT1: TTBXItem
            Tag = -1
            Caption = 'Formatted Title: Original (Translated)'
            OnClick = MnuMovFT1Click
          end
          object MnuMovFT2: TTBXItem
            Tag = -1
            Caption = 'Formatted Title: Translated (Original)'
            OnClick = MnuMovFT2Click
          end
          object MnuMovDir: TTBXItem
            Tag = -1
            Caption = 'Director'
            OnClick = MnuMovDirClick
          end
          object MnuMovPro: TTBXItem
            Tag = -1
            Caption = 'Producer'
            OnClick = MnuMovProClick
          end
          object MnuMovWrt: TTBXItem
            Tag = -1
            Caption = 'Writer'
            OnClick = MnuMovWrtClick
          end
          object MnuMovCmp: TTBXItem
            Tag = -1
            Caption = 'Composer'
            OnClick = MnuMovCmpClick
          end
          object MnuMovAct: TTBXItem
            Tag = -1
            Caption = 'Actors'
            OnClick = MnuMovActClick
          end
          object MnuMovCou: TTBXItem
            Tag = -1
            Caption = 'Country'
            OnClick = MnuMovCouClick
          end
          object MnuMovYea: TTBXItem
            Tag = -1
            Caption = 'Year'
            OnClick = MnuMovYeaClick
          end
          object MnuMovLen: TTBXItem
            Tag = -1
            Caption = 'Length'
            OnClick = MnuMovLenClick
          end
          object MnuMovCat: TTBXItem
            Tag = -1
            Caption = 'Category'
            OnClick = MnuMovCatClick
          end
          object MnuMovCer: TTBXItem
            Tag = -1
            Caption = 'Certification'
            OnClick = MnuMovCerClick
          end
          object MnuMovURL: TTBXItem
            Tag = -1
            Caption = 'URL'
            OnClick = MnuMovURLClick
          end
          object MnuMovDsc: TTBXItem
            Tag = -1
            Caption = 'Description'
            OnClick = MnuMovDscClick
          end
          object MnuMovCom: TTBXItem
            Tag = -1
            Caption = 'Comments'
            OnClick = MnuMovComClick
          end
          object MnuMovFil: TTBXItem
            Tag = -1
            Caption = 'File Path'
            OnClick = MnuMovFilClick
          end
          object MnuMovVfm: TTBXItem
            Tag = -1
            Caption = 'Video Format'
            OnClick = MnuMovVfmClick
          end
          object MnuMovVbr: TTBXItem
            Tag = -1
            Caption = 'Video Bitrate'
            OnClick = MnuMovVbrClick
          end
          object MnuMovAfm: TTBXItem
            Tag = -1
            Caption = 'Audio Format'
            OnClick = MnuMovAfmClick
          end
          object MnuMovAbr: TTBXItem
            Tag = -1
            Caption = 'Audio Bitrate'
            OnClick = MnuMovAbrClick
          end
          object MnuMovRes: TTBXItem
            Tag = -1
            Caption = 'Resolution'
            OnClick = MnuMovResClick
          end
          object MnuMovFps: TTBXItem
            Tag = -1
            Caption = 'Framerate'
            OnClick = MnuMovFpsClick
          end
          object MnuMovLng: TTBXItem
            Tag = -1
            Caption = 'Languages'
            OnClick = MnuMovLngClick
          end
          object MnuMovSub: TTBXItem
            Tag = -1
            Caption = 'Subtitles'
            OnClick = MnuMovSubClick
          end
          object MnuMovSiz: TTBXItem
            Tag = -1
            Caption = 'Size'
            OnClick = MnuMovSizClick
          end
          object MnuMovDsk: TTBXItem
            Tag = -1
            Caption = 'Disks'
            OnClick = MnuMovDskClick
          end
          object MnuMovPst: TTBXItem
            Tag = -1
            Caption = 'Picture Status'
            OnClick = MnuMovPstClick
          end
          object MnuMovNbE: TTBXItem
            Tag = -1
            Caption = 'Nb Extras'
            OnClick = MnuMovNbEClick
          end
          object MnuMovPic: TTBXItem
            Tag = -1
            Caption = 'Picture'
            OnClick = MnuMovPicClick
          end
          object MnuMovPicNP: TTBXItem
            Tag = -1
            Caption = 'Picture (No popup)'
            OnClick = MnuMovPicNPClick
          end
          object MnuMovPfn: TTBXItem
            Tag = -1
            Caption = 'Picture filename'
            OnClick = MnuMovPfnClick
          end
          object MnuMovPfnNP: TTBXItem
            Tag = -1
            Caption = 'Picture filename (No popup)'
            OnClick = MnuMovPfnNPClick
          end
        end
        object MnuMovCF: TTBXSubmenuItem
          Caption = '&Custom fields'
        end
        object MnuMovExtras: TTBXSubmenuItem
          Caption = '&Extra fields'
          object MnuMovEBeg: TTBXItem
            Tag = -1
            Caption = 'Begin List'
            OnClick = MnuMovEBegClick
          end
          object MnuMovEEnd: TTBXItem
            Tag = -1
            Caption = 'End List'
            OnClick = MnuMovEEndClick
          end
          object MnuMovERec: TTBXItem
            Tag = -1
            Caption = 'Record number'
            OnClick = MnuMovERecClick
          end
          object MnuMovENum: TTBXItem
            Tag = -1
            Caption = 'Number'
            OnClick = MnuMovENumClick
          end
          object MnuMovEChk: TTBXItem
            Tag = -1
            Caption = 'Checked'
            OnClick = MnuMovEChkClick
          end
          object MnuMovETag: TTBXItem
            Tag = -1
            Caption = 'Tag'
            OnClick = MnuMovETagClick
          end
          object MnuMovETit: TTBXItem
            Tag = -1
            Caption = 'Title'
            OnClick = MnuMovETitClick
          end
          object MnuMovECat: TTBXItem
            Tag = -1
            Caption = 'Category'
            OnClick = MnuMovECatClick
          end
          object MnuMovEURL: TTBXItem
            Tag = -1
            Caption = 'URL'
            OnClick = MnuMovEURLClick
          end
          object MnuMovEDsc: TTBXItem
            Tag = -1
            Caption = 'Description'
            OnClick = MnuMovEDscClick
          end
          object MnuMovECom: TTBXItem
            Tag = -1
            Caption = 'Comments'
            OnClick = MnuMovEComClick
          end
          object MnuMovECby: TTBXItem
            Tag = -1
            Caption = 'Created by'
            OnClick = MnuMovECbyClick
          end
          object MnuMovEPst: TTBXItem
            Tag = -1
            Caption = 'Picture Status'
            OnClick = MnuMovEPstClick
          end
          object MnuMovEPic: TTBXItem
            Tag = -1
            Caption = 'Picture'
            OnClick = MnuMovEPicClick
          end
          object MnuMovEPicNP: TTBXItem
            Tag = -1
            Caption = 'Picture (No popup)'
            OnClick = MnuMovEPicNPClick
          end
          object MnuMovEPfn: TTBXItem
            Tag = -1
            Caption = 'Picture filename'
            OnClick = MnuMovEPfnClick
          end
          object MnuMovEPfnNP: TTBXItem
            Tag = -1
            Caption = 'Picture filename (No popup)'
            OnClick = MnuMovEPfnNPClick
          end
        end
      end
      object btnSeparator2: TTBXSeparatorItem
      end
      object LHTMLTemplateFileName: TTBXLabelItem
        Caption = 'template.html'
        Enabled = False
        ShowAccelChar = False
      end
    end
    object TBToolbar1: TTBXToolbar
      Left = 0
      Top = 0
      AutoResize = False
      BorderStyle = bsNone
      Caption = 'TBToolbar1'
      DefaultDock = TBDock1
      DockMode = dmCannotFloatOrChangeDocks
      Resizable = False
      ShrinkMode = tbsmNone
      TabOrder = 0
      object btnDisplayFull: TTBXItem
        Action = ActionDisplayFull
        Checked = True
        FontSettings.Bold = tsTrue
        GroupIndex = 1
      end
      object btnDisplayIndividual: TTBXItem
        Action = ActionDisplayIndividual
        FontSettings.Bold = tsTrue
        GroupIndex = 1
      end
      object TBSeparatorItem4: TTBXSeparatorItem
      end
      object btnHTMLExport: TTBXSubmenuItem
        Action = ActionExportBoth
        Options = [tboDropdownArrow]
        object btnHTMLExportBoth: TTBXItem
          Action = ActionExportBoth
        end
        object btnHTMLExportSelected: TTBXItem
          Action = ActionExportSelected
        end
      end
    end
  end
  object ActionList1: TActionList
    Left = 120
    Top = 296
    object ActionDisplayFull: TAction
      Category = 'TemplateType'
      Caption = 'Full'
      GroupIndex = 1
      Hint = 
        'Display full list template|Display HTML page that will be used f' +
        'or full movie list'
      OnExecute = ActionDisplayFullExecute
    end
    object ActionDisplayIndividual: TAction
      Category = 'TemplateType'
      Caption = 'Individual'
      GroupIndex = 1
      Hint = 
        'Display individual list template|Display HTML page that will be ' +
        'used for individual movie pages'
      OnExecute = ActionDisplayFullExecute
    end
    object ActionHTMLNew: TAction
      Category = 'HTMLFile'
      Caption = 'New'
      Hint = 'New|Create a new template'
      ShortCut = 16462
      OnExecute = ActionHTMLNewExecute
    end
    object ActionHTMLOpen: TAction
      Category = 'HTMLFile'
      Caption = 'Open...'
      Hint = 'Open...|Open a template'
      ShortCut = 16463
      OnExecute = ActionHTMLOpenExecute
    end
    object ActionHTMLSave: TAction
      Category = 'HTMLFile'
      Caption = 'Save'
      Hint = 'Save|Save current template'
      ShortCut = 16467
      OnExecute = ActionHTMLSaveExecute
    end
    object ActionHTMLSaveAs: TAction
      Category = 'HTMLFile'
      Caption = 'Save as...'
      Hint = 'Save as...|Save current template under a new name'
      ShortCut = 24659
      OnExecute = ActionHTMLSaveAsExecute
    end
    object ActionHTMLNoRecent: TAction
      Category = 'HTMLFile'
      Caption = 'No recent file'
      Enabled = False
      Visible = False
    end
    object ActionInsertTag: TAction
      Category = 'HTMLEdit'
      Caption = '&Insert Tag'
      Hint = 
        '|Insert a special value that will be replaced by information fro' +
        'm catalog or movie'
      OnExecute = ActionInsertTagExecute
    end
    object ActionEditUndo: TAction
      Category = 'HTMLEdit'
      Caption = '&Undo'
      OnExecute = ActionEditUndoExecute
    end
    object ActionEditCut: TAction
      Category = 'HTMLEdit'
      Caption = 'Cu&t'
      OnExecute = ActionEditCutExecute
    end
    object ActionEditCopy: TAction
      Category = 'HTMLEdit'
      Caption = '&Copy'
      OnExecute = ActionEditCopyExecute
    end
    object ActionEditPaste: TAction
      Category = 'HTMLEdit'
      Caption = '&Paste'
      OnExecute = ActionEditPasteExecute
    end
    object ActionEditDelete: TAction
      Category = 'HTMLEdit'
      Caption = '&Delete'
      OnExecute = ActionEditDeleteExecute
    end
    object ActionEditSelectAll: TAction
      Category = 'HTMLEdit'
      Caption = 'Select &All'
      OnExecute = ActionEditSelectAllExecute
    end
    object ActionExportBoth: TAction
      Category = 'TemplateType'
      Caption = 'Export both'
      Hint = '|Export both "full" and "individual" templates'
      OnExecute = ActionExportBothExecute
    end
    object ActionExportSelected: TAction
      Category = 'TemplateType'
      Caption = 'Export selected'
      Hint = '|Export only the selected template'
      OnExecute = ActionExportBothExecute
    end
  end
  object Messages: TAntStringList
    Strings.Strings = (
      'Unable to save file "%s": %s'
      'Unable to load file "%s": %s'
      'HTML template has been modified. Do you want to save it?'
      
        'HTML template for Full listing has been modified. Do you want to' +
        ' save it?'
      
        'HTML template for Individual listing has been modified. Do you w' +
        'ant to save it?')
    Left = 120
    Top = 248
  end
  object TBMRUList1: TTBXMRUList
    HidePathExtension = False
    MaxItems = 9
    OnClick = TBMRUList1Click
    Prefix = 'MRU'
    Left = 376
    Top = 288
  end
  object SynHTMLSyn1: TSynHTMLSyn
    DefaultFilter = 'HTML Document (*.htm,*.html)|*.htm;*.html'
    AndAttri.Foreground = clNavy
    CommentAttri.Foreground = clGreen
    IdentifierAttri.Foreground = clMaroon
    KeyAttri.Foreground = clBlue
    SymbolAttri.Foreground = clGray
    ValueAttri.Foreground = clTeal
    Left = 232
    Top = 288
  end
  object PopupHTML: TTBXPopupMenu
    Left = 312
    Top = 288
    object TBSubmenuItem1: TTBXSubmenuItem
      Action = ActionInsertTag
      LinkSubitems = BtnInsertTag
    end
    object TBSeparatorItem3: TTBXSeparatorItem
    end
    object HtmEdtUnd: TTBXItem
      Action = ActionEditUndo
    end
    object TBSeparatorItem1: TTBXSeparatorItem
    end
    object HtmEdtCut: TTBXItem
      Action = ActionEditCut
    end
    object HtmEdtCpy: TTBXItem
      Action = ActionEditCopy
    end
    object HtmEdtPst: TTBXItem
      Action = ActionEditPaste
    end
    object TBSeparatorItem2: TTBXSeparatorItem
    end
    object HtmEdtSel: TTBXItem
      Action = ActionEditSelectAll
    end
  end
end
