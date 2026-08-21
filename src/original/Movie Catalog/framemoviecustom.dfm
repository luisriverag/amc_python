object MovieFrameCustom: TMovieFrameCustom
  Left = 0
  Top = 0
  Width = 533
  Height = 449
  Constraints.MinHeight = 449
  Constraints.MinWidth = 533
  TabOrder = 0
  OnMouseUp = FrameMouseUp
  OnResize = FrameResize
  object ActionList1: TActionList
    Left = 152
    Top = 112
    object ActionAddCustomField: TAction
      Caption = 'Add a custom field'
      Hint = '|Add a custom field'
      OnExecute = ActionAddCustomFieldExecute
    end
    object ActionDeleteCustomField: TAction
      Caption = 'Delete custom field'
      Hint = '|Delete custom field'
      OnExecute = ActionDeleteCustomFieldExecute
    end
    object ActionMoveResizeCustomFields: TAction
      Caption = 'Move custom fields'
      Hint = '|Move and resize custom fields'
      OnExecute = ActionMoveResizeCustomFieldsExecute
    end
    object ActionModifyCustomField: TAction
      Caption = 'Modify custom field'
      Hint = '|Modify custom field'
      OnExecute = ActionModifyCustomFieldExecute
    end
    object ActionDefaultPositioning: TAction
      Caption = 'Default positioning'
      Hint = '|Restore default positioning on custom fields'
      OnExecute = ActionDefaultPositioningExecute
    end
    object ActionAutoStretchWidth: TAction
      Caption = 'Auto stretch width'
      Hint = 'Auto stretch field width on resize'
      OnExecute = ActionAutoStretchWidthExecute
    end
    object ActionAutoStretchHeight: TAction
      Caption = 'Auto stretch height'
      Hint = 'Auto stretch field height on resize'
      OnExecute = ActionAutoStretchHeightExecute
    end
  end
  object PopupCustomField: TTBPopupMenu
    Left = 144
    Top = 104
    object TBAddCustomField: TTBXItem
      Action = ActionAddCustomField
    end
    object TBModifyCustomField: TTBXItem
      Action = ActionModifyCustomField
    end
    object TBDeleteCustomField: TTBXItem
      Action = ActionDeleteCustomField
    end
    object TBSep1: TTBXSeparatorItem
    end
    object TBAutoStretchWidth: TTBXItem
      Action = ActionAutoStretchWidth
    end
    object TBAutoStretchHeight: TTBXItem
      Action = ActionAutoStretchHeight
    end
    object TBSep2: TTBXSeparatorItem
    end
    object TBMoveResizeCustomField: TTBXItem
      Action = ActionMoveResizeCustomFields
    end
    object TBDefaultPositioning: TTBXItem
      Action = ActionDefaultPositioning
    end
  end
end
