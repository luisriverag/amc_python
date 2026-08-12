//  Filename: ifs_obj.pas
//  Author: Carlo Kok (ckok.1@hccnet.nl)
//
// Innerfuse Pascal Script Custom Objects
//
// When created properly, it will free itself.

unit ifs_obj;

interface
{$I ifs_def.inc}

uses
  ifs_var, ifs_utl;

type
  TIfsExtClass = class;
  PIFSExternalObject = Pointer;
  TIFSExternalObject = PIFSExternalObject;
  TIfsExtClass = class
  private
    FScriptEngine: Pointer;
  protected
    property ScriptEngine: Pointer read FScriptEngine;
  public
    constructor Create(ScriptEngine: Pointer);

    function GetPropertyType(FSelf: PIFSExternalObject; I: Longint): PTypeRec; virtual;
    function SetProperty(FSelf: PIFSExternalObject; I: Longint; P: PIfVariant): Boolean; virtual;
    function GetProperty(FSelf: PIFSExternalObject; I: Longint; Dest: PIfVariant): Boolean; virtual;
    function FindProperty(FSelf: PIFSExternalObject; const Name: string): Longint; virtual;

    function FindProc(FSelf: PIFSExternalObject; const Name: string): Longint; virtual;
    function GetProcHeader(FSelf: PIFSExternalObject; I: Longint): string; virtual;
    function CallProc(FSelf: PIFSExternalObject; I: Longint; Params: PVariableManager): PIFVariant; virtual;

    function FindClassProc(const Name: string): longint; virtual;
    function GetClassProcHeader(I: Longint): string; virtual;
    function CallClassProc(I: Longint; Params: PVariableManager): PIFVariant; virtual;

    function IsCompatibleWith(X: PTypeRec): Boolean; virtual;
  end;

implementation
uses
 ifspas;


{ TIfsExtClass }


function TIfsExtClass.CallClassProc(I: Integer;
  Params: PVariableManager): PIFVariant;
begin
  Result := nil;
end;

function TIfsExtClass.CallProc(FSelf: PIFSExternalObject; I: Integer;
  Params: PVariableManager): PIFVariant;
begin
  Result := nil;
end;

constructor TIfsExtClass.Create(ScriptEngine: Pointer);
begin
  inherited Create;
  FScriptEngine := ScriptEngine;
end;

function TIfsExtClass.FindClassProc(const Name: string): longint;
begin
  result := -1;
end;

function TIfsExtClass.FindProc(FSelf: PIFSExternalObject; const Name: string): Longint;
begin
  Result := -1;
end;

function TIfsExtClass.FindProperty(FSelf: PIFSExternalObject; const Name: string): Longint;
begin
  Result := -1;
end;



function TIfsExtClass.GetClassProcHeader(I: Integer): string;
begin
  result := '';
end;


function TIfsExtClass.GetProcHeader(FSelf: PIFSExternalObject;
  I: Integer): string;
begin
  Result := '';
end;

function TIfsExtClass.GetProperty(FSelf: PIFSExternalObject; I: Integer;
  Dest: PIfVariant): Boolean;
begin
  Result := False;
end;


function TIfsExtClass.GetPropertyType(FSelf: PIFSExternalObject;
  I: Integer): PTypeRec;
begin
  Result := nil;
end;

function TIfsExtClass.IsCompatibleWith(X: PTypeRec): Boolean;
begin
  Result := False;
end;

function TIfsExtClass.SetProperty(FSelf: PIFSExternalObject; I: Integer;
  P: PIfVariant): Boolean;
begin
  Result := False;
end;

end.
