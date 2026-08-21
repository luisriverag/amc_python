object IncludepicFrame: TIncludepicFrame
  Left = 0
  Top = 0
  Width = 128
  Height = 88
  TabOrder = 0
  object grp: TGroupBox
    Left = 0
    Top = 0
    Width = 128
    Height = 88
    Align = alClient
    Caption = 'Pictures to include'
    TabOrder = 0
    DesignSize = (
      128
      88)
    object rbtAll: TRadioButton
      Left = 8
      Top = 18
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'All'
      TabOrder = 0
    end
    object rbtMovie: TRadioButton
      Left = 8
      Top = 38
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Movie'
      TabOrder = 1
    end
    object rbtExtras: TRadioButton
      Left = 8
      Top = 58
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Extras'
      TabOrder = 2
    end
  end
end
