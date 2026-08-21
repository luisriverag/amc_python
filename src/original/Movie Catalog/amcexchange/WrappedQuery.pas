(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2006 Antoine Potten                                       *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   This program is free software; you can redistribute it and/or      *
 *   modify it under the terms of the GNU General Public License        *
 *   as published by the Free Software Foundation; either version 2     *
 *   of the License, or (at your option) any later version.             *
 *                                                                      *
 *   This program is distributed in the hope that it will be useful,    *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the      *
 *   GNU General Public License for more details.                       *
 *                                                                      *
 ************************************************************************)

unit WrappedQuery;

interface

uses
  Classes, SysUtils,

  datamodule, interfaces;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TWrappedQuery = class(TInterfacedObject, IWrappedQuery)
  private
    function GetLastError: WideString; 
  protected
    FDatamod: TDLLDataModule;
    FLastError: WideString;
  public
    constructor Create;
    destructor Destroy; override;
    function Connect(const ConnectionString: WideString): Boolean; virtual;
    procedure Disconnect; virtual;
    procedure SetSQL(const Text: WideString); virtual;
    function Open: Boolean; virtual;
    procedure Next; virtual;
    procedure Close; virtual;
    function Eof: Boolean; virtual;
    function FieldExists(const FieldName: WideString): Boolean; virtual;
    function FieldName(const FieldNum: Integer): WideString; virtual;
    function FieldCount: Integer; virtual;
    function ValueByName(const FieldName: WideString): WideString; virtual;
    function Value(const FieldNum: Integer): WideString; virtual;
    function IntValueByName(const FieldName: WideString): Integer; virtual;
    function IntValue(const FieldNum: Integer): Integer; virtual;
    function ListTables: WideString; virtual;
  end;

  TWrappedAdoQuery = class(TWrappedQuery)
  private
  protected
  public
    function Connect(const ConnectionString: WideString): Boolean; override;
    procedure Disconnect; override;
    procedure SetSQL(const Text: WideString); override;
    function Open: Boolean; override;
    procedure Next; override;
    procedure Close; override;
    function Eof: Boolean; override;
    function FieldExists(const FieldName: WideString): Boolean; override;
    function FieldName(const FieldNum: Integer): WideString; override;
    function FieldCount: Integer; override;
    function ValueByName(const FieldName: WideString): WideString; override;
    function Value(const FieldNum: Integer): WideString; override;
    function IntValueByName(const FieldName: WideString): Integer; override;
    function IntValue(const FieldNum: Integer): Integer; override;
    function ListTables: WideString; override;
  end;

  {
  TWrappedMlbQuery = class(TWrappedQuery)
  private
    FMlb: TMlb2;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function Connect(const ConnectionString: WideString): Boolean; override;
    procedure Disconnect; override;
    function Open: Boolean; override;
    procedure Next; override;
    function Eof: Boolean; override;
    function FieldExists(const FieldName: WideString): Boolean; override;
    function FieldName(const FieldNum: Integer): WideString; override;
    function FieldCount: Integer; override;
    function ValueByName(const FieldName: WideString): WideString; override;
    function Value(const FieldNum: Integer): WideString; override;
//    function ListTables: WideString; override;
  end;
  }

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
  TWrappedQuery
-------------------------------------------------------------------------------}

constructor TWrappedQuery.Create;
begin
  FDatamod := TDLLDataModule.Create(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TWrappedQuery.Destroy;
begin
  FDatamod.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.GetLastError: WideString;
begin
  Result := FLastError;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.Connect(const ConnectionString: WideString): Boolean;
begin
  Result := False;
  FLastError := 'not implemented';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.Eof: Boolean;
begin
  Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedQuery.Next;
begin

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedQuery.Close;
begin

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedQuery.Disconnect;
begin

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.Open: Boolean;
begin
  Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedQuery.SetSQL(const Text: WideString);
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.FieldCount: Integer;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.FieldExists(const FieldName: WideString): Boolean;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.FieldName(const FieldNum: Integer): WideString;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.IntValue(const FieldNum: Integer): Integer;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.IntValueByName(const FieldName: WideString): Integer;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.Value(const FieldNum: Integer): WideString;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.ValueByName(const FieldName: WideString): WideString;
begin
  raise Exception.Create('not implemented');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedQuery.ListTables: WideString;
begin
  Result := '';
end;

{-------------------------------------------------------------------------------
  TWrappedAdoQuery
-------------------------------------------------------------------------------}

procedure TWrappedAdoQuery.Close;
begin
  FDatamod.ADOQuery.Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.Connect(const ConnectionString: WideString): Boolean;
begin
  Result := False;
  FLastError := '';
  try
    Disconnect;
    FDatamod.ADOConn.ConnectionString := ConnectionString;
    FDatamod.ADOConn.Connected := True;
    Result := True;
  except
    on e: Exception do
      FLastError := e.Message;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedAdoQuery.Disconnect;
begin
  FDatamod.ADOConn.Connected := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.Eof: Boolean;
begin
  Result := FDatamod.ADOQuery.Eof;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedAdoQuery.Next;
begin
  FDatamod.ADOQuery.Next;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.Open: Boolean;
begin
  Result := False;
  FLastError := '';
  try
    FDatamod.ADOQuery.Open;
    Result := True;
  except
    on e: Exception do
      FLastError := e.Message;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedAdoQuery.SetSQL(const Text: WideString);
begin
  FDatamod.ADOQuery.SQL.Text := Text;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.FieldCount: Integer;
begin
  Result := FDatamod.ADOQuery.Fields.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.FieldExists(const FieldName: WideString): Boolean;
begin
  Result := FDatamod.ADOQuery.FindField(FieldName) <> nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.FieldName(const FieldNum: Integer): WideString;
begin
  Result := FDatamod.ADOQuery.Fields[FieldNum].FieldName;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.IntValue(const FieldNum: Integer): Integer;
begin
  Result := FDatamod.ADOQuery.Fields[FieldNum].AsInteger;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.IntValueByName(const FieldName: WideString): Integer;
begin
  Result := FDatamod.ADOQuery.FieldByName(FieldName).AsInteger;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.Value(const FieldNum: Integer): WideString;
begin
  Result := FDatamod.ADOQuery.Fields[FieldNum].AsString;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.ValueByName(const FieldName: WideString): WideString;
begin
  Result := FDatamod.ADOQuery.FieldByName(FieldName).AsString;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedAdoQuery.ListTables: WideString;
var
  L: TStringList;
begin
  L := TStringList.Create;
  try
    FDatamod.ADOConn.GetTableNames(L);
    Result := L.Text;
  finally
    L.Free;
  end;
end;

(*
{-------------------------------------------------------------------------------
  TWrappedMlbQuery
-------------------------------------------------------------------------------}

constructor TWrappedMlbQuery.Create;
begin
  inherited;
  FMlb := TMlb2.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TWrappedMlbQuery.Destroy;
begin
  FMlb.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.Connect(const ConnectionString: WideString): Boolean;
begin
  Result := FMlb.LoadFromMLBFile(ConnectionString);
  if not Result then
    FLastError := FMlb.MLBErrorComment
  else
    FLastError := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedMlbQuery.Disconnect;
begin
  FMlb.Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.Eof: Boolean;
begin
  Result := FMlb.EndOfFile;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TWrappedMlbQuery.Next;
begin
  FMlb.GoNext;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.Open: Boolean;
begin
  FMlb.GoFirst;
  Result := True;
  FLastError := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.FieldCount: Integer;
begin
  Result := FMlb.FieldCount;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.Value(const FieldNum: Integer): WideString;
begin
  Result := FMlb.GetDataByIndex(FieldNum + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.ValueByName(const FieldName: WideString): WideString;
begin
  Result := FMlb.GetData(FieldName);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.FieldExists(const FieldName: WideString): Boolean;
begin
  Result := FMlb.GetFieldIndex(FieldName) > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TWrappedMlbQuery.FieldName(const FieldNum: Integer): WideString;
begin
  Result := FMlb.GetFieldName(FieldNum + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function TWrappedMlbQuery.ListTables: WideString;
var
  L: TStringList;
  i: Integer;
begin
  L := TStringList.Create;
  try
    for i := 1 to FMlb.FieldCount do
      L.Add(FMlb.FieldName[i]);
    Result := L.Text;
  finally
    L.Free;
  end;
end;

*)
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
