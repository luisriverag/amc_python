object IncludemovFrame: TIncludemovFrame
  Left = 0
  Top = 0
  Width = 128
  Height = 108
  TabOrder = 0
  object grp: TGroupBox
    Left = 0
    Top = 0
    Width = 128
    Height = 108
    Align = alClient
    Caption = 'Movies to include'
    TabOrder = 0
    DesignSize = (
      128
      108)
    object rbtAll: TRadioButton
      Left = 8
      Top = 18
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'All'
      TabOrder = 0
    end
    object rbtSelected: TRadioButton
      Left = 8
      Top = 38
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Selected'
      TabOrder = 1
    end
    object rbtChecked: TRadioButton
      Left = 8
      Top = 58
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Checked'
      TabOrder = 2
    end
    object rbtVisible: TRadioButton
      Left = 8
      Top = 78
      Width = 109
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Visible'
      TabOrder = 3
    end
  end
end
