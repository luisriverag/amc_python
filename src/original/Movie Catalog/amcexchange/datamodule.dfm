object DLLDataModule: TDLLDataModule
  OldCreateOrder = False
  Left = 439
  Top = 316
  Height = 111
  Width = 186
  object ADOQuery: TADOQuery
    Connection = ADOConn
    CursorType = ctOpenForwardOnly
    LockType = ltReadOnly
    Parameters = <>
    Left = 24
    Top = 8
  end
  object ADOConn: TADOConnection
    LoginPrompt = False
    Left = 104
    Top = 8
  end
end
