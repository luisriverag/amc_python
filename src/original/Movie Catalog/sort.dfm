object SortWin: TSortWin
  Left = 495
  Top = 214
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsToolWindow
  Caption = 'Advanced sort options'
  ClientHeight = 393
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  inline Fields: TFieldsFrame
    Left = 0
    Top = 0
    Width = 389
    Height = 393
    Align = alClient
    AutoScroll = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    inherited LAvailable: TLabel
      Width = 177
      AutoSize = False
    end
    inherited LSelected: TLabel
      Left = 214
      Width = 175
      Anchors = [akTop, akRight]
      AutoSize = False
      Caption = 'Fields to include in sort:'
    end
    inherited LbSelected: TListBox
      Left = 214
      Width = 175
      Height = 377
      Anchors = [akTop, akRight, akBottom]
      OnMouseDown = FieldsLbSelectedMouseDown
    end
    inherited LbAvailable: TListBox
      Width = 175
      Height = 377
      Anchors = [akLeft, akTop, akRight, akBottom]
    end
    inherited BtnAdd: TTBXButton
      Left = 181
      Top = 152
    end
    inherited BtnRem: TTBXButton
      Left = 181
      Top = 184
    end
    inherited BtnAddAll: TTBXButton
      Left = 181
      Top = 232
    end
    inherited BtnRemAll: TTBXButton
      Left = 181
      Top = 264
    end
    inherited BtnUp: TTBXButton
      Left = 181
      Top = 72
    end
    inherited BtnDown: TTBXButton
      Left = 181
      Top = 104
    end
  end
  object BtnSortOrder: TTBXButton
    Left = 181
    Top = 24
    Width = 27
    Height = 26
    Hint = 'Invert sort order|Invert sort order of selected field'
    AutoSize = False
    Caption = 'Ord'
    TabOrder = 1
    OnClick = BtnSortOrderClick
  end
end
