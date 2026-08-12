(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2006 Antoine Potten                                       *
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

unit getscript_debug;

interface

uses
  SysUtils, Classes, Graphics, Types, stdctrls,

  ifspas, SynEdit, TBXDkPanels, jvsimplexml;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TGetVariableEvent = function (Sender: TObject; const VarName: string): string of object;

  TBreakpointManager = class(TList)
  private
  protected
    function GetInt(Index: Integer): Integer;
    procedure PutInt(Index: Integer; const Value: Integer);
  public
    function IndexOf(const ALine: Integer): Integer;
    function Exists(const ALine: Integer): Boolean;
    function Add(const ALine: Integer): Integer;
    function Remove(const ALine: Integer): Integer;
    function Toggle(const ALine: Integer): Boolean;
    property Items[Index: Integer]: Integer read GetInt write PutInt; default;
  end;

  TDebugPlugin = class(TSynEditPlugin)
  private
    FBreakpoints: TBreakpointManager;
    FCurrentLine: Integer;
    FCursorLine: Integer;
    FErrorLine: Integer;
    FWatchList: TListBox;
    FWatchPanel: TTBXDockablePanel;
    FOnGetVariable: TGetVariableEvent;
    FXmlParser: TJvSimpleXml;
  protected
    procedure AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer); override;
    procedure LinesInserted(FirstLine, Count: integer); override;
    procedure LinesDeleted(FirstLine, Count: integer); override;
  public
    constructor Create(AOwner: TCustomSynEdit);
    destructor Destroy; override;
    property Breakpoints: TBreakpointManager read FBreakpoints;
    procedure ClearBreakpoints;
    function IsBreakpoint(const ALine: Integer): Boolean;
    function ToggleBreakpoint(const ALine: Integer): Boolean;
    property CurrentLine: Integer read FCurrentLine write FCurrentLine;
    property CursorLine: Integer read FCursorLine write FCursorLine;
    property ErrorLine: Integer read FErrorLine write FErrorLine;
    property WatchList: TListBox read FWatchList write FWatchList;
    procedure AddWatch(const VarName: string);
    procedure DeleteWatch;
    procedure ClearWatches;
    procedure UpdateWatches;
    property WatchPanel: TTBXDockablePanel read FWatchPanel write FWatchPanel;
    property OnGetVariable: TGetVariableEvent read FOnGetVariable write FOnGetVariable;
    property XmlParser: TJvSimpleXml read FXmlParser write FXmlParser;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
  TBreakpointManager
-------------------------------------------------------------------------------}

function TBreakpointManager.IndexOf(const ALine: Integer): Integer;
begin
  Result := Integer(inherited IndexOf(Pointer(ALine)));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TBreakpointManager.Exists(const ALine: Integer): Boolean;
begin
  Result := IndexOf(ALine) <> -1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TBreakpointManager.Add(const ALine: Integer): Integer;
begin
  Result := inherited Add(Pointer(ALine));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TBreakpointManager.GetInt(Index: Integer): Integer;
begin
  Result := Integer(Get(Index));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TBreakpointManager.PutInt(Index: Integer; const Value: Integer);
begin
  Put(Index, Pointer(Value));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TBreakpointManager.Remove(const ALine: Integer): Integer;
begin
  Result := inherited Remove(Pointer(ALine));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TBreakpointManager.Toggle(const ALine: Integer): Boolean;
var
  i: Integer;
begin
  i := IndexOf(ALine);
  if i = -1 then
  begin
    Add(ALine);
    Result := True;
  end
  else
  begin
    Delete(i);
    Result := False;
  end;
end;

{-------------------------------------------------------------------------------
  TDebugPlugin
-------------------------------------------------------------------------------}

constructor TDebugPlugin.Create(AOwner: TCustomSynEdit);
begin
  inherited Create(AOwner);
  FBreakpoints := TBreakpointManager.Create;
  FXmlParser := TJvSimpleXml.Create(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TDebugPlugin.Destroy;
begin
  FBreakpoints.Free;
  FXmlParser.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.AfterPaint(ACanvas: TCanvas; const AClip: TRect; FirstLine, LastLine: integer);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.LinesDeleted(FirstLine, Count: integer);
var
  i: Integer;
begin
  inherited;
  for i := 0 to FBreakpoints.Count-1 do
    if FBreakpoints[i] >= FirstLine then
      FBreakpoints[i] := FBreakpoints[i] - Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.LinesInserted(FirstLine, Count: integer);
var
  i: Integer;
begin
  inherited;
  for i := 0 to FBreakpoints.Count-1 do
    if FBreakpoints[i] >= FirstLine then
      FBreakpoints[i] := FBreakpoints[i] + Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.ClearBreakpoints;
begin
  FBreakpoints.Clear;
  Editor.Invalidate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TDebugPlugin.IsBreakpoint(const ALine: Integer): Boolean;
begin
  Result := FBreakpoints.Exists(ALine);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TDebugPlugin.ToggleBreakpoint(const ALine: Integer): Boolean;
begin
  Result := FBreakpoints.Toggle(ALine);
  Editor.InvalidateGutterLine(ALine);
  Editor.InvalidateLine(ALine);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.AddWatch(const VarName: string);
begin
  if VarName <> '' then
  begin
    FWatchList.Items.Values[VarName] := FOnGetVariable(Self, VarName);
    FWatchPanel.Visible := FWatchList.Count > 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.DeleteWatch;
begin
  FWatchList.DeleteSelected;
  FWatchPanel.Visible := FWatchList.Count > 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.ClearWatches;
begin
  FWatchList.Clear;
  FWatchPanel.Visible := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDebugPlugin.UpdateWatches;
var
  i: Integer;
begin
  if Assigned(FOnGetVariable) then
    with FWatchList.Items do
    begin
      BeginUpdate;
      try
        for i := 0 to Count-1 do
          ValueFromIndex[i] := FOnGetVariable(Self, Names[i]);
      finally
        EndUpdate;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
