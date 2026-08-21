object ExtraFrame: TExtraFrame
  Left = 0
  Top = 0
  Width = 416
  Height = 268
  TabOrder = 0
  OnResize = FrameResize
  object ExtraPanel: TPanel
    Left = 0
    Top = 0
    Width = 416
    Height = 268
    Align = alClient
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      416
      268)
    object LURL: TLabel
      Left = 8
      Top = 81
      Width = 25
      Height = 13
      Caption = 'URL:'
      FocusControl = EURL
    end
    object LTitle: TLabel
      Left = 8
      Top = 33
      Width = 23
      Height = 13
      Caption = 'Title:'
      FocusControl = ETitle
    end
    object LTag: TLabel
      Left = 176
      Top = 9
      Width = 22
      Height = 13
      Caption = 'Tag:'
    end
    object LNumber: TLabel
      Left = 7
      Top = 9
      Width = 40
      Height = 13
      Caption = 'Number:'
    end
    object LDescription: TLabel
      Left = 8
      Top = 105
      Width = 56
      Height = 13
      Caption = 'Description:'
      FocusControl = EDescription
    end
    object LCreatedBy: TLabel
      Left = 8
      Top = 248
      Width = 54
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Created by:'
    end
    object LComments: TLabel
      Left = 8
      Top = 175
      Width = 52
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Comments:'
      FocusControl = EComments
    end
    object LCategory: TLabel
      Left = 8
      Top = 57
      Width = 45
      Height = 13
      Caption = 'Category:'
      FocusControl = ECategory
    end
    object chkCategory: TCheckBox
      Left = 8
      Top = 55
      Width = 17
      Height = 17
      Hint = '|Modify field category'
      TabOrder = 5
      Visible = False
    end
    object EURL: TAntJvComboEditXP
      Left = 104
      Top = 77
      Width = 306
      Height = 21
      Hint = '|Url'
      Anchors = [akLeft, akTop, akRight]
      ButtonFlat = False
      ImageKind = ikDropDown
      TabOrder = 8
      OnButtonClick = FieldURLButtonClick
      OnChange = EURLChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object ETitle: TEdit
      Left = 104
      Top = 29
      Width = 306
      Height = 21
      Hint = '|Title'
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
      OnChange = ETitleChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object ETag: TComboBox
      Left = 235
      Top = 5
      Width = 175
      Height = 21
      Hint = 
        '|Tag (used to access to extra directly for printing, html templa' +
        'tes, ...)'
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 2
      OnChange = ETagChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object ENumber: TAntJvSpinEdit
      Left = 104
      Top = 5
      Width = 60
      Height = 21
      Hint = 
        '|Change the number and renumber automatically extras after this ' +
        'number'
      MaxValue = 999999.000000000000000000
      MinValue = 1.000000000000000000
      Value = 999999.000000000000000000
      Enabled = False
      TabOrder = 0
      OnChange = FieldChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object EDescription: TMemo
      Left = 8
      Top = 122
      Width = 402
      Height = 48
      Hint = '|Description'
      Anchors = [akLeft, akTop, akRight]
      ScrollBars = ssVertical
      TabOrder = 10
      OnChange = EDescriptionChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object ECreatedBy: TComboBox
      Left = 104
      Top = 244
      Width = 306
      Height = 21
      Hint = '|Created by (used by scripts)'
      Anchors = [akLeft, akRight, akBottom]
      ItemHeight = 13
      TabOrder = 14
      OnChange = ECreatedByChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object EComments: TMemo
      Left = 8
      Top = 192
      Width = 402
      Height = 48
      Hint = '|Comments'
      Anchors = [akLeft, akRight, akBottom]
      ScrollBars = ssVertical
      TabOrder = 12
      OnChange = ECommentsChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
    end
    object ECategory: TComboBox
      Left = 104
      Top = 53
      Width = 306
      Height = 21
      Hint = '|Category'
      AutoComplete = False
      Anchors = [akLeft, akTop, akRight]
      ItemHeight = 13
      TabOrder = 6
      OnChange = ECategoryChange
      OnExit = FieldExit
      OnKeyDown = FieldKeyDown
      OnKeyUp = FieldKeyUp
      Items.Strings = (
        '')
    end
    object chkURL: TCheckBox
      Left = 8
      Top = 79
      Width = 17
      Height = 17
      Hint = '|Modify field URL'
      TabOrder = 7
      Visible = False
    end
    object chkTitle: TCheckBox
      Left = 8
      Top = 31
      Width = 17
      Height = 17
      Hint = '|Modify field title'
      TabOrder = 3
      Visible = False
    end
    object chkTag: TCheckBox
      Left = 176
      Top = 7
      Width = 17
      Height = 17
      Hint = '|Modify field tag'
      TabOrder = 1
      Visible = False
    end
    object chkDescription: TCheckBox
      Left = 8
      Top = 103
      Width = 17
      Height = 17
      Hint = '|Modify field description'
      TabOrder = 9
      Visible = False
    end
    object chkCreatedBy: TCheckBox
      Left = 8
      Top = 246
      Width = 17
      Height = 17
      Hint = '|Modify field created by'
      Anchors = [akLeft, akBottom]
      TabOrder = 13
      Visible = False
    end
    object chkComments: TCheckBox
      Left = 8
      Top = 173
      Width = 17
      Height = 17
      Hint = '|Modify field comments'
      Anchors = [akLeft, akBottom]
      TabOrder = 11
      Visible = False
    end
  end
end
