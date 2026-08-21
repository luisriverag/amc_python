object MovieFrame: TMovieFrame
  Left = 0
  Top = 0
  Width = 533
  Height = 458
  AutoScroll = False
  Constraints.MinHeight = 458
  Constraints.MinWidth = 533
  ParentBackground = False
  TabOrder = 0
  OnResize = FrameResize
  object MoviePanel: TPanel
    Left = 0
    Top = 0
    Width = 533
    Height = 458
    Align = alClient
    BevelOuter = bvNone
    ParentBackground = False
    ParentColor = True
    TabOrder = 0
    object PanelMain: TPanel
      Left = 0
      Top = 72
      Width = 533
      Height = 266
      Align = alClient
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      OnResize = PanelMainResize
      DesignSize = (
        533
        266)
      object LYear: TLabel
        Left = 234
        Top = 152
        Width = 25
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Year:'
        FocusControl = EYear
        Transparent = True
      end
      object LWriter: TLabel
        Left = 8
        Top = 104
        Width = 31
        Height = 13
        Caption = 'Writer:'
        FocusControl = EWriter
        Transparent = True
      end
      object LURL: TLabel
        Left = 8
        Top = 199
        Width = 25
        Height = 13
        Caption = 'URL:'
        FocusControl = EURL
        Transparent = True
      end
      object LTranslatedTitle: TLabel
        Left = 8
        Top = 30
        Width = 76
        Height = 13
        Caption = 'T&ranslated Title:'
        FocusControl = ETranslatedTitle
        Transparent = True
      end
      object LProducer: TLabel
        Left = 8
        Top = 80
        Width = 46
        Height = 13
        Caption = 'Producer:'
        FocusControl = EProducer
        Transparent = True
      end
      object LLength: TLabel
        Left = 376
        Top = 152
        Width = 36
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Length:'
        FocusControl = ELength
        Transparent = True
      end
      object LLengthMin: TLabel
        Left = 508
        Top = 152
        Width = 19
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'min.'
        Transparent = True
      end
      object LOriginalTitle: TLabel
        Left = 8
        Top = 6
        Width = 61
        Height = 13
        Caption = '&Original Title:'
        FocusControl = EOriginalTitle
        Transparent = True
      end
      object LDirector: TLabel
        Left = 8
        Top = 56
        Width = 40
        Height = 13
        Caption = 'Director:'
        FocusControl = EDirector
        Transparent = True
      end
      object LDescription: TLabel
        Left = 8
        Top = 224
        Width = 56
        Height = 13
        Caption = 'Description:'
        FocusControl = EDescription
        Transparent = True
      end
      object LCountry: TLabel
        Left = 8
        Top = 152
        Width = 39
        Height = 13
        Caption = 'Country:'
        FocusControl = ECountry
        Transparent = True
      end
      object LComposer: TLabel
        Left = 8
        Top = 128
        Width = 50
        Height = 13
        Caption = 'Composer:'
        FocusControl = EComposer
        Transparent = True
      end
      object LComments: TLabel
        Left = 8
        Top = 247
        Width = 52
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Comments:'
        FocusControl = EComments
        Transparent = True
      end
      object LRating10: TLabel
        Left = 508
        Top = 30
        Width = 20
        Height = 13
        Anchors = [akTop, akRight]
        Caption = '/ 10'
        Transparent = True
      end
      object LRating: TLabel
        Left = 376
        Top = 30
        Width = 34
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Rating:'
        FocusControl = ERating
        Transparent = True
      end
      object LUserRating10: TLabel
        Left = 508
        Top = 6
        Width = 20
        Height = 13
        Anchors = [akTop, akRight]
        Caption = '/ 10'
        Transparent = True
      end
      object LUserRating: TLabel
        Left = 376
        Top = 6
        Width = 51
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'My Rating:'
        FocusControl = EUserRating
        Transparent = True
      end
      object LCertification: TLabel
        Left = 376
        Top = 177
        Width = 58
        Height = 13
        Caption = 'Certification:'
        FocusControl = ECertification
        Transparent = True
      end
      object LActors: TLabel
        Left = 376
        Top = 48
        Width = 33
        Height = 13
        Caption = 'Actors:'
        FocusControl = EActors
        Transparent = True
      end
      object LCategory: TLabel
        Left = 8
        Top = 177
        Width = 45
        Height = 13
        Caption = 'Category:'
        FocusControl = ECategory
        Transparent = True
      end
      object ImgExpand1: TImage
        Left = -1
        Top = -1
        Width = 16
        Height = 16
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFFFFFFFF000800FFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFF0008000008
          00000800FFFFFF000800FF00FF000000FF00FF000000FF00FF000000FF00FF00
          0000FF00FF000800FFFFFFFFFFFF000800FFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        Visible = False
        OnClick = ImgExpand1Click
      end
      object ImgExpand2: TImage
        Left = -1
        Top = 251
        Width = 16
        Height = 16
        Anchors = [akLeft, akBottom]
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0008000008000008000008
          00000800000800000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFF0008
          00FFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFF000800000800000800FFFFFF000800FF00FF000000
          FF00FF000000FF00FF000000FF00FF000000FF00FF000800FFFFFFFFFFFF0008
          00FFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0008000008000008000008
          00000800000800000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        Visible = False
        OnClick = ImgExpand2Click
      end
      object EDirector: TEdit
        Left = 104
        Top = 52
        Width = 257
        Height = 21
        TabOrder = 4
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EDescription: TMemo
        Left = 104
        Top = 220
        Width = 424
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ScrollBars = ssVertical
        TabOrder = 15
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ECountry: TComboBox
        Left = 104
        Top = 148
        Width = 115
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 9
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EComposer: TEdit
        Left = 104
        Top = 124
        Width = 257
        Height = 21
        TabOrder = 7
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EComments: TMemo
        Left = 104
        Top = 244
        Width = 424
        Height = 21
        Anchors = [akLeft, akRight, akBottom]
        ScrollBars = ssVertical
        TabOrder = 16
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ECertification: TComboBox
        Left = 448
        Top = 172
        Width = 80
        Height = 21
        AutoDropDown = True
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 13
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ECategory: TComboBox
        Left = 104
        Top = 172
        Width = 257
        Height = 21
        AutoDropDown = True
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 12
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EActors: TMemo
        Left = 376
        Top = 61
        Width = 152
        Height = 84
        Anchors = [akLeft, akTop, akRight]
        ScrollBars = ssVertical
        TabOrder = 8
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EYear: TAntJvSpinEdit
        Left = 306
        Top = 148
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 0
        MaxValue = 99999.000000000000000000
        Value = -1.000000000000000000
        Anchors = [akTop, akRight]
        TabOrder = 10
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EUserRating: TAntJvSpinEdit
        Left = 448
        Top = 2
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 1
        MaxValue = 10.000000000000000000
        ValueType = vtFloat
        Value = -1.000000000000000000
        Anchors = [akTop, akRight]
        TabOrder = 2
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ERating: TAntJvSpinEdit
        Left = 448
        Top = 26
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 1
        MaxValue = 10.000000000000000000
        ValueType = vtFloat
        Value = -1.000000000000000000
        Anchors = [akTop, akRight]
        TabOrder = 3
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EProducer: TEdit
        Left = 104
        Top = 76
        Width = 257
        Height = 21
        TabOrder = 5
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EOriginalTitle: TEdit
        Left = 104
        Top = 2
        Width = 257
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ELength: TAntJvSpinEdit
        Left = 448
        Top = 148
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 0
        MaxValue = 99999.000000000000000000
        Value = -1.000000000000000000
        Anchors = [akTop, akRight]
        TabOrder = 11
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EWriter: TEdit
        Left = 104
        Top = 100
        Width = 257
        Height = 21
        TabOrder = 6
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ETranslatedTitle: TEdit
        Left = 104
        Top = 26
        Width = 257
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 1
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EURL: TAntJvComboEditXP
        Left = 104
        Top = 196
        Width = 424
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        ButtonFlat = False
        ImageKind = ikDropDown
        TabOrder = 14
        OnButtonClick = FieldURLButtonClick
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
    end
    object PanelMedia: TPanel
      Left = 0
      Top = 0
      Width = 533
      Height = 72
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      DesignSize = (
        533
        72)
      object LMediaType: TLabel
        Left = 297
        Top = 4
        Width = 59
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Media Type:'
        FocusControl = EMediaType
        Transparent = True
      end
      object LBorrower: TLabel
        Left = 8
        Top = 54
        Width = 45
        Height = 13
        Caption = 'Borrower:'
        FocusControl = EBorrower
        Transparent = True
      end
      object LMedia: TLabel
        Left = 8
        Top = 6
        Width = 61
        Height = 13
        Caption = 'Media Label:'
        FocusControl = EMedia
        Transparent = True
      end
      object LDate: TLabel
        Left = 297
        Top = 30
        Width = 60
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Date Added:'
        FocusControl = EDate
        Transparent = True
      end
      object LDateWatched: TLabel
        Left = 297
        Top = 54
        Width = 73
        Height = 13
        Anchors = [akTop, akRight]
        Caption = 'Date Watched:'
        FocusControl = EDateWatched
        Transparent = True
      end
      object LSource: TLabel
        Left = 8
        Top = 30
        Width = 37
        Height = 13
        Caption = 'Source:'
        FocusControl = ESource
        Transparent = True
      end
      object ImgCollapse1: TImage
        Left = -1
        Top = -1
        Width = 16
        Height = 16
        Anchors = [akLeft, akBottom]
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFF0008000008
          00000800FFFFFF000800FF00FF000000FF00FF000000FF00FF000000FF00FF00
          0000FF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        OnClick = ImgCollapse1Click
      end
      object ImgCollapseEnd1: TImage
        Left = -1
        Top = 58
        Width = 16
        Height = 16
        Anchors = [akLeft, akBottom]
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000FF00FF000000
          FF00FF000000FF00FF000000FF00FF000000FF00FFFF00FFFF00FFFF00FFFF00
          FF000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        OnClick = ImgCollapse1Click
      end
      object EBorrower: TComboBox
        Left = 104
        Top = 50
        Width = 179
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 4
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EDateWatched: TDateTimePicker
        Left = 387
        Top = 50
        Width = 141
        Height = 21
        Anchors = [akTop, akRight]
        Date = 36892.000000000000000000
        Time = 36892.000000000000000000
        ShowCheckbox = True
        TabOrder = 5
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EDate: TDateTimePicker
        Left = 387
        Top = 26
        Width = 141
        Height = 21
        Anchors = [akTop, akRight]
        Date = 36892.000000000000000000
        Time = 36892.000000000000000000
        ShowCheckbox = True
        TabOrder = 3
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ESource: TComboBox
        Left = 104
        Top = 26
        Width = 179
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        TabOrder = 2
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EMediaType: TComboBox
        Left = 387
        Top = 2
        Width = 141
        Height = 21
        AutoDropDown = True
        Anchors = [akTop, akRight]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 1
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EMedia: TEdit
        Left = 104
        Top = 2
        Width = 179
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
    end
    object PanelVideo: TPanel
      Left = 0
      Top = 338
      Width = 533
      Height = 120
      Align = alBottom
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 2
      DesignSize = (
        533
        120)
      object LVideoKbps: TLabel
        Left = 258
        Top = 29
        Width = 23
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'kbps'
        Transparent = True
      end
      object LVideoFormat: TLabel
        Left = 8
        Top = 29
        Width = 65
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Video Format:'
        FocusControl = EVideoFormat
        Transparent = True
      end
      object LSubtitles: TLabel
        Left = 9
        Top = 101
        Width = 43
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Subtitles:'
        FocusControl = ESubtitles
        Transparent = True
      end
      object LSizeUnit: TLabel
        Left = 504
        Top = 79
        Width = 16
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'MB'
        Transparent = True
      end
      object LSize: TLabel
        Left = 297
        Top = 77
        Width = 52
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'Files Sizes:'
        FocusControl = ESize
        Transparent = True
      end
      object LResolution: TLabel
        Left = 297
        Top = 29
        Width = 53
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'Resolution:'
        FocusControl = EResolution
        Transparent = True
      end
      object LLanguages: TLabel
        Left = 8
        Top = 77
        Width = 56
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Languages:'
        FocusControl = ELanguages
        Transparent = True
      end
      object LFramerateFPS: TLabel
        Left = 504
        Top = 53
        Width = 14
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'fps'
        Transparent = True
      end
      object LFramerate: TLabel
        Left = 297
        Top = 53
        Width = 58
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'Frame Rate:'
        FocusControl = EFramerate
        Transparent = True
      end
      object LFilePath: TLabel
        Left = 8
        Top = 5
        Width = 44
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'File Path:'
        FocusControl = EFilePath
        Transparent = True
      end
      object LDisks: TLabel
        Left = 297
        Top = 101
        Width = 55
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'Discs/Files:'
        FocusControl = EDisks
        Transparent = True
      end
      object LAudioKbps: TLabel
        Left = 258
        Top = 53
        Width = 23
        Height = 13
        Anchors = [akRight, akBottom]
        Caption = 'kbps'
        Transparent = True
      end
      object LAudioFormat: TLabel
        Left = 8
        Top = 53
        Width = 65
        Height = 13
        Anchors = [akLeft, akBottom]
        Caption = 'Audio Format:'
        FocusControl = EAudioFormat
        Transparent = True
      end
      object ImgCollapse2: TImage
        Left = -1
        Top = -1
        Width = 16
        Height = 16
        Anchors = [akLeft, akBottom]
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FF000000FF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFF0008000008
          00000800FFFFFF000800FF00FF000000FF00FF000000FF00FF000000FF00FF00
          0000FF00FF000800FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000800FFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFF000800FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FF000800000800000800000800000800000800000800FF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        OnClick = ImgCollapse2Click
      end
      object ImgCollapseEnd2: TImage
        Left = -1
        Top = 105
        Width = 16
        Height = 16
        Anchors = [akLeft, akBottom]
        Picture.Data = {
          07544269746D617036030000424D360300000000000036000000280000001000
          000010000000010018000000000000030000C40E0000C40E0000000000000000
          0000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
          FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF000000FF00FF000000
          FF00FF000000FF00FF000000FF00FF000000FF00FFFF00FFFF00FFFF00FFFF00
          FF000000FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
          FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0000
          00FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
          00FF}
        Transparent = True
        OnClick = ImgCollapse2Click
      end
      object EVideoFormat: TComboBox
        Left = 104
        Top = 26
        Width = 91
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akRight, akBottom]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 1
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EVideoBitrate: TAntJvSpinEdit
        Left = 198
        Top = 26
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 0
        MaxValue = 99999.000000000000000000
        Value = -1.000000000000000000
        Anchors = [akRight, akBottom]
        TabOrder = 2
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ESubtitles: TComboBox
        Left = 104
        Top = 98
        Width = 179
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akRight, akBottom]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 8
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ESize: TEdit
        Left = 386
        Top = 74
        Width = 113
        Height = 21
        Anchors = [akRight, akBottom]
        TabOrder = 9
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EResolution: TEdit
        Left = 386
        Top = 26
        Width = 142
        Height = 21
        Anchors = [akRight, akBottom]
        TabOrder = 5
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EFramerate: TComboBox
        Left = 386
        Top = 50
        Width = 113
        Height = 21
        AutoDropDown = True
        Anchors = [akRight, akBottom]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 6
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object ELanguages: TComboBox
        Left = 104
        Top = 74
        Width = 179
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akRight, akBottom]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 7
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EFilePath: TAntJvComboEditXP
        Left = 104
        Top = 2
        Width = 424
        Height = 21
        Anchors = [akLeft, akRight, akBottom]
        ButtonFlat = False
        ImageKind = ikDropDown
        TabOrder = 0
        OnButtonClick = FieldURLButtonClick
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EDisks: TAntJvSpinEdit
        Left = 386
        Top = 98
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 0
        MaxValue = 99999.000000000000000000
        Value = -1.000000000000000000
        Anchors = [akRight, akBottom]
        TabOrder = 10
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EAudioFormat: TComboBox
        Left = 104
        Top = 50
        Width = 91
        Height = 21
        AutoDropDown = True
        Anchors = [akLeft, akRight, akBottom]
        DropDownCount = 16
        ItemHeight = 13
        Sorted = True
        TabOrder = 3
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
      object EAudioBitrate: TAntJvSpinEdit
        Left = 198
        Top = 50
        Width = 55
        Height = 21
        AllowEmpty = True
        Alignment = taRightJustify
        Decimal = 0
        MaxValue = 99999.000000000000000000
        Value = -1.000000000000000000
        Anchors = [akRight, akBottom]
        TabOrder = 4
        OnChange = FieldChange
        OnExit = FieldExit
        OnKeyDown = FieldKeyDown
        OnKeyUp = FieldKeyUp
      end
    end
  end
end
