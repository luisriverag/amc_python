(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2005-2006 Antoine Potten                                       *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   This file can be used freely in any program, even if it is not     *
 *   opensource or if it is commercial. It can be used only to provide  *
 *   compatibility with Ant Movie Catalog files, for importation for    *
 *   example. A mention to the origin of this code and eventually       *
 *   a link to Ant Movie Catalog website somewhere in the about box,    *
 *   help file or documentation would be appreciated.                   *
 *   Like for the GPL-licensed files, this file is distributed WITHOUT  *
 *   ANY WARRANTY.                                                      *
 *                                                                      *
 *   To compile fields.pas and movieclass.pas in any project,           *
 *   you have to define "DLLMode" either in project options or          *
 *   directly in these two files.                                       *
 *                                                                      *
 *   Alternatively, this can be used under GPL license:                 *
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

unit interfaces;

interface

uses
  Classes, SysUtils, Contnrs{$IFDEF MSWINDOWS}, Windows{$ENDIF},
  Fields;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  IMovie = interface(IInterface)
    function  GetFieldValue(const FieldID: TMovieField;
      const LocalFormatSettings: Boolean = False;
      const ReturnEmptyIfFalse : Boolean = False;
      const ReturnEmptyIfVirtual: Boolean = False): string; overload;
    function  GetIntFieldValue(const FieldID: TMovieField): Integer;
    procedure SetFieldValue(const FieldID: TMovieField; const Value: string); overload;
  end;

  IMovieList = interface(IInterface)
    function Add2: IMovie; overload;
    function GetItem2(const idx: Integer): IMovie;
    property Items2[const idx: Integer]: IMovie read GetItem2; default;
  end;

  TSourceType = (stAdo, stMlb);

  IWrappedQuery = interface(IInterface)
    function Connect(const ConnectionString: WideString): Boolean;
    procedure Disconnect;
    procedure SetSQL(const Text: WideString);
    function Open: Boolean;
    procedure Next;
    procedure Close;
    function Eof: Boolean;
    function FieldExists(const FieldName: WideString): Boolean;
    function FieldName(const FieldNum: Integer): WideString;
    function FieldCount: Integer;
    function ValueByName(const FieldName: WideString): WideString;
    function Value(const FieldNum: Integer): WideString;
    function IntValueByName(const FieldName: WideString): Integer;
    function IntValue(const FieldNum: Integer): Integer;
    function GetLastError: WideString;
    property LastError: WideString read GetLastError;
    function ListTables: WideString;
  end;

  TWrappedQueryCreator = function(): IWrappedQuery;

  TInterfacedObject = class(System.TInterfacedObject);

  TInterfacedObjectList = class(TObjectList, IInterface)
  protected
    FRefCount: Integer;
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    class function NewInstance: TObject; override;
    property RefCount: Integer read FRefCount;
    function Add(AObject: TObject): Integer;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TInterfacedObjectList._AddRef: Integer;
begin
  Result := InterlockedIncrement(FRefCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TInterfacedObjectList._Release: Integer;
begin
  Result := InterlockedDecrement(FRefCount);
  if Result = 0 then
    Destroy;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TInterfacedObjectList.AfterConstruction;
begin
  InterlockedDecrement(FRefCount);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TInterfacedObjectList.BeforeDestruction;
begin
  if RefCount <> 0 then
    System.Error(reInvalidPtr);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

class function TInterfacedObjectList.NewInstance: TObject;
begin
  Result := inherited NewInstance;
  TInterfacedObjectList(Result).FRefCount := 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TInterfacedObjectList.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TInterfacedObjectList.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if Action = lnDeleted then
    TInterfacedObject(Ptr)._Release
  else
    inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TInterfacedObjectList.Add(AObject: TObject): Integer;
begin
  TInterfacedObject(AObject)._AddRef;
  Result := inherited Add(AObject);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
