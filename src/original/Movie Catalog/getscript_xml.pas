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

unit getscript_xml;

interface

uses
  Classes, SysUtils,

  ifs_var, ifspas, ifpsclass, stdimport,
  JvSimpleXml;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure SIRegister_Xml(Cl: TIFPSClasses);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
  TJvSimpleXml
-------------------------------------------------------------------------------}

function Read_TJvSimpleXml_Root(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXml, Caller, Obj) then begin Result := False; Exit; end;
  Dest^.CV_ExternalObject := TJvSimpleXml(Obj).Root;
  Result := True;
end;

function TJvSimpleXml_LoadFromString(Self: TJvsimpleXml; Value: string): string;
begin
  try
    Self.LoadFromString(Value);
    Result := '';
  except
    on e: Exception do
      Result := e.Message;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TJvSimpleXml_LoadFromFile(Self: TJvSimpleXml; FileName: string): string;
begin
  try
    Self.LoadFromFile(FileName);
    Result := '';
  except
    on e: Exception do
      Result := e.Message;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TJvSimpleXml_SaveToFile(Self: TJvSimpleXml; FileName: string): string;
begin
  try
    Self.SaveToFile(FileName);
    Result := '';
  except
    on e: Exception do
      Result := e.Message;
  end;
end;

{-------------------------------------------------------------------------------
  TJvSimpleXmlProp
-------------------------------------------------------------------------------}

function Read_TJvSimpleXmlProp_Name(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlProp, Caller, Obj) then begin Result := False; Exit; end;
  SetString(Dest, TJvSimpleXmlProp(Obj).Name);
  Result := True;
end;

function Write_TJvSimpleXmlProp_Name(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlProp, Caller, Obj) then begin Result := False; Exit; end;
  TJvSimpleXmlProp(Obj).Name := GetString(Dest);
  Result := True;
end;

function Read_TJvSimpleXmlProp_Value(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlProp, Caller, Obj) then begin Result := False; Exit; end;
  SetString(Dest, TJvSimpleXmlProp(Obj).Value);
  Result := True;
end;

function Write_TJvSimpleXmlProp_Value(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlProp, Caller, Obj) then begin Result := False; Exit; end;
  TJvSimpleXmlProp(Obj).Value := GetString(Dest);
  Result := True;
end;

{-------------------------------------------------------------------------------
  TJvSimpleXmlProps
-------------------------------------------------------------------------------}

function Read_TJvSimpleXmlProps_Count(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlProps, Caller, Obj) then begin Result := False; Exit; end;
  SetInteger(Dest, TJvSimpleXmlProps(Obj).Count);
  Result := True;
end;

function TJvSimpleXmlProps_GetItem(Obj: TJvSimpleXmlProps; Index: Integer): TJvSimpleXmlProp;
begin
  Result := Obj.Item[Index];
end;

function TJvSimpleXmlProps_GetItemNamed(Obj: TJvSimpleXmlProps; Name: string): TJvSimpleXmlProp;
begin
  Result := Obj.ItemNamed[Name];
end;

procedure TJvSimpleXmlProps_Delete(Obj: TJvSimpleXmlProps; Index: Integer);
begin
  Obj.Delete(Index);
end;

procedure TJvSimpleXmlProps_DeleteNamed(Obj: TJvSimpleXmlProps; Name: string);
begin
  Obj.Delete(Name);
end;

function TJvSimpleXmlProps_Add(Obj: TJvSimpleXmlProps; Name: string; Value: string): TJvSimpleXmlProp;
begin
  Result := Obj.Add(Name, Value);
end;

{-------------------------------------------------------------------------------
  TJvSimpleXmlElem
-------------------------------------------------------------------------------}

function Read_TJvSimpleXmlElem_Name(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  SetString(Dest, TJvSimpleXmlElem(Obj).Name);
  Result := True;
end;

function Write_TJvSimpleXmlElem_Name(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  TJvSimpleXmlElem(Obj).Name := GetString(Dest);
  Result := True;
end;

function Read_TJvSimpleXmlElem_Value(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  SetString(Dest, TJvSimpleXmlElem(Obj).Value);
  Result := True;
end;

function Write_TJvSimpleXmlElem_Value(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  TJvSimpleXmlElem(Obj).Value := GetString(Dest);
  Result := True;
end;

function Read_TJvSimpleXmlElem_Items(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  Dest^.CV_ExternalObject := TJvSimpleXmlElem(Obj).Items;
  Result := True;
end;

function Read_TJvSimpleXmlElem_Properties(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  Dest^.CV_ExternalObject := TJvSimpleXmlElem(Obj).Properties;
  Result := True;
end;

function Read_TJvSimpleXmlElem_Parent(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElem, Caller, Obj) then begin Result := False; Exit; end;
  Dest^.CV_ExternalObject := TJvSimpleXmlElem(Obj).Parent;
  Result := True;
end;

{-------------------------------------------------------------------------------
  TJvSimpleXmlElems
-------------------------------------------------------------------------------}

function Read_TJvSimpleXmlElems_Count(Caller: TIfPasScript; Obj: TObject; dest: PIfVariant): Boolean;
begin
  if RCheck(TJvSimpleXmlElems, Caller, Obj) then begin Result := False; Exit; end;
  SetInteger(Dest, TJvSimpleXmlElems(Obj).Count);
  Result := True;
end;

function TJvSimpleXmlElems_GetItem(Obj: TJvSimpleXmlElems; Index: Integer): TJvSimpleXmlElem;
begin
  Result := Obj.Item[Index];
end;

function TJvSimpleXmlElems_GetItemNamed(Obj: TJvSimpleXmlElems; Name: string): TJvSimpleXmlElem;
begin
  Result := Obj.ItemNamed[Name];
end;

procedure TJvSimpleXmlElems_Delete(Obj: TJvSimpleXmlElems; Index: Integer);
begin
  Obj.Delete(Index);
end;

procedure TJvSimpleXmlElems_DeleteNamed(Obj: TJvSimpleXmlElems; Name: string);
begin
  Obj.Delete(Name);
end;

function TJvSimpleXmlElems_Add(Obj: TJvSimpleXmlElems; Name: string): TJvSimpleXmlElemClassic;
begin
  Result := Obj.Add(Name);
end;

{-------------------------------------------------------------------------------
  Register
-------------------------------------------------------------------------------}

procedure SIRegister_Xml(Cl: TIFPSClasses);
var
  ClProp, ClProps, clElems, ClElem: TIFPSClassWrapper;
begin
  clProp :=   Cl.AddClass(TJvSimpleXmlProp, Cl.FindClass('TObject'));
  clProps :=  Cl.AddClass(TJvSimpleXmlProps, Cl.FindClass('TObject'));
  clElem :=   Cl.AddClass(TJvSimpleXmlElem, Cl.FindClass('TObject'));
              Cl.AddClass(TJvSimpleXmlElemClassic, Cl.FindClass('TJvSimpleXmlElem'));
  clElems :=  Cl.AddClass(TJvSimpleXmlElems, Cl.FindClass('TObject'));
  with ClProp do
  begin
    AddPropertyHelper('Name', 'string', Read_TJvSimpleXmlProp_Name, Write_TJvSimpleXmlProp_Name);
    AddPropertyHelper('Value', 'string', Read_TJvSimpleXmlProp_Value, Write_TJvSimpleXmlProp_Value);
  end;
  with clProps do
  begin
    AddPropertyHelper('Count', 'Integer', Read_TJvSimpleXmlProps_Count, nil);
    AddFunction(@TJvSimpleXmlProps_GetItem, 'function GetItem(Index: Integer): TJvSimpleXmlProp;');
    AddFunction(@TJvSimpleXmlProps_GetItemNamed, 'function GetItemNamed(Name: string): TJvSimpleXmlProp;');
    AddFunction(@TJvSimpleXmlProps.Clear, 'procedure Clear;');
    AddFunction(@TJvSimpleXmlProps_Delete, 'procedure Delete(Index: Integer);');
    AddFunction(@TJvSimpleXmlProps_DeleteNamed, 'procedure DeleteNamed(Name: string);');
    AddFunction(@TJvSimpleXmlProps_Add, 'function Add(Name: string; Value: string): TJvSimpleXmlProp;');
  end;
  with clElem do
  begin
    AddPropertyHelper('Name', 'string', Read_TJvSimpleXmlElem_Name, Write_TJvSimpleXmlElem_Name);
    AddPropertyHelper('Value', 'string', Read_TJvSimpleXmlElem_Value, Write_TJvSimpleXmlElem_Value);
    AddPropertyHelper('Items', 'TJvSimpleXmlElems', Read_TJvSimpleXmlElem_Items, nil);
    AddPropertyHelper('Properties', 'TJvSimpleXmlProps', Read_TJvSimpleXmlElem_Properties, nil);
    AddPropertyHelper('Parent', 'TJvSimpleXmlElem', Read_TJvSimpleXmlElem_Parent, nil);
    AddFunction(@TJvSimpleXmlElem.GetChildIndex, 'function GetChildIndex(AChild: TJvSimpleXmlElem): Integer;');
    AddFunction(@TJvSimpleXmlElem.Clear, 'procedure Clear;');
  end;
  with clElems do
  begin
    AddPropertyHelper('Count', 'Integer', Read_TJvSimpleXmlElems_Count, nil);
    AddFunction(@TJvSimpleXmlElems_GetItem, 'function GetItem(Index: Integer): TJvSimpleXmlElem;');
    AddFunction(@TJvSimpleXmlElems_GetItemNamed, 'function GetItemNamed(Name: string): TJvSimpleXmlElem;');
    AddFunction(@TJvSimpleXmlElems.Clear, 'procedure Clear;');
    AddFunction(@TJvSimpleXmlElems_Delete, 'procedure Delete(Index: Integer);');
    AddFunction(@TJvSimpleXmlElems_DeleteNamed, 'procedure DeleteNamed(Name: string);');
    AddFunction(@TJvSimpleXmlElems_Add, 'function Add(Name: string): TJvSimpleXmlElemClassic;');
  end;
  with Cl.AddClass(TJvSimpleXml, Cl.FindClass('TComponent')) do
  begin
    AddFunction(@TJvSimpleXml_LoadFromString, 'function LoadFromString(Value: string): string;');
    AddFunction(@TJvSimpleXml_LoadFromFile, 'function LoadFromFile(FileName: string): string;');
    AddFunction(@TJvSimpleXml.SaveToString, 'function SaveToString: string;');
    AddFunction(@TJvSimpleXml_SaveToFile, 'function SaveToFile(FileName: string): string;');
    AddPropertyHelper('Root', 'TJvSimpleXmlElemClassic', Read_TJvSimpleXml_Root, nil);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
