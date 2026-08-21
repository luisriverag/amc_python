(************************************************************************
 *                                                                      *
 *   (C) 2000-2006 Antoine Potten                                       *
 *   Thanks to Sebastien Buysse for help and tips                       *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   You can use this file for free, as long as you do not remove the   *
 *   names and addresses from the source.                               *
 *   It would be nice if you could include in the credits, about box    *
 *   or in the documentation names and/or web addresses.                *
 *                                                                      *
 *   This program is distributed in the hope that it will be useful,    *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of     *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.               *
 *                                                                      *
 ************************************************************************)

{$DEFINE ANTTRANSLATOR_USEELTREE}

unit AntTranslator;

interface

uses
  Classes, TypInfo, Forms;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TAntTranslator = class(TComponent)
  private
    FLanguageFile: TStringList;
    function FindProperties(Compo: TComponent; Text: string; var Obj: TObject; const value: string): PPropInfo; overload;
    function FindProperties(Compo: TObject; Text: string; var Obj: TObject; const value: string): PPropInfo; overload;
    procedure Analyse(Line: string); overload;
    procedure Analyse(Line: string; AFrame: TFrame); overload;
    procedure Analyse(Line: string; AForm: TForm); overload;
    procedure AssignValue(Obj: TObject; Prop: PPropInfo; const Value: string);
  protected
  public
    ShowErrors: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetLanguageFile(const newFile: string);
    procedure Translate(const FileName: string); overload;
    procedure Translate(const FileName: string; const Forms: array of string); overload;
    procedure Translate(const Forms: array of string); overload;
    procedure Translate(const AFrame: TFrame); overload;
    procedure Translate(const AForm: TForm); overload;
  end;

function ExtractIndex(const text: string): integer;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  SysUtils, comctrls, Controls, Dialogs,
  IniFiles{$IFDEF ANTTRANSLATOR_USEELTREE}, Eltree, ElHeader{$ENDIF};

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TAntTranslator.FindProperties(Compo: TObject; Text: string; var Obj: TObject; const value: string): PPropInfo;
var
  st: string;
  Obj2: TObject;
begin
  //Text = Property Name?
  if pos('.',Text)=0 then
{Original}
    //result := GetPropInfo(Compo,Text,[tkInteger, tkEnumeration,tkClass, tkString, tkLString])
{End Original}
{Soulsnake Mod}
    result := GetPropInfo(Compo, Text, [tkInteger, tkEnumeration, tkClass,
      tkString, tkLString, tkSet])
{End Soulsnake Mod}
  else
  begin
    st := Copy(Text,1,pos('.',Text)-1);
    Text := Copy(Text,pos('.',Text)+1,Length(Text));

    //Find if this is a component
    Obj2 := GetObjectProp(Compo,st);
    if Obj2 is TComponent then
    begin
      Obj := Obj2;
      result := FindProperties(Obj2 as TComponent, Text, Obj, value);
    end else
    begin
      if Obj2<>nil then
      begin
        Obj := Obj2;
        result := FindProperties(Obj2,Text,Obj, value);
      end
      else
        result := nil;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TAntTranslator.FindProperties(Compo: TComponent; Text: string; var Obj: TObject; const value: string): PPropInfo;
var
  st: string;
  Comp2: TComponent;
  Obj2: TObject;
  colIndex: integer;
begin
  //Text = Property Name?
  if pos('.',Text)=0 then
  begin
    Obj := Compo;
{Original}
    //result := GetPropInfo(Compo,Text,[tkInteger, tkEnumeration,tkClass, tkString, tkLString])
{End Original}
{Soulsnake Mod}
    result := GetPropInfo(Compo, Text, [tkInteger, tkEnumeration, tkClass,
      tkString, tkLString, tkSet])
{End Soulsnake Mod}
  end
  else
  begin
    st := Copy(Text,1,pos('.',Text)-1);
    Text := Copy(Text,pos('.',Text)+1,Length(Text));

    //Find if this is a component
    Comp2 := Compo.FindComponent(st);
    if Comp2<>nil then
    begin
      Obj := Comp2;
      result := FindProperties(Comp2, Text, Obj, value);
    end
    else
    begin
      //This is not a  component
      Obj2 := GetObjectProp(Compo,st);
      if Obj2<>nil then
      begin
        Obj := Obj2;
        if Obj2 is TCollection then
        begin
          st := Copy(Text,1,pos('.',Text)-1);
          Text := Copy(Text,pos('.',Text)+1,Length(Text));
          colIndex := ExtractIndex(st);
          if colIndex = -1 then
            result := nil
          else
          begin
            obj := (Obj2 as TCollection).Items[colIndex];
            result := FindProperties(obj, Text, obj, value);
          end;
        end else
        if Obj2 is TTreeNodes then
        begin
          st := Copy(Text,1,pos('.',Text)-1);
          colIndex := ExtractIndex(st);
          if colIndex = -1 then
            result := nil
          else
          begin
            (Obj2 as TTreeNodes).Item[colIndex].Text := value;
            result := nil
          end;
        end else
        if Obj2 is TListItems then
        begin
          st := Copy(Text,1,pos('.',Text)-1);
          colIndex := ExtractIndex(st);
          if colIndex = -1 then
            result := nil
          else
          begin
            TListItems(Obj2).Owner.HandleNeeded;
            TListItems(Obj2).Item[colIndex].Caption := value;
            result := nil
          end;
        end else
        if Obj2 is TStrings then
        begin
          colIndex := ExtractIndex(Text);
          if colIndex = -1 then
            result := nil
          else
          begin
            (Obj2 as TStrings).Strings[colIndex] := value;
            result := nil;
          end;
        end else
        {$IFDEF ANTTRANSLATOR_USEELTREE}
        if Obj2 is TElHeaderSections then
        begin
          st := Copy(Text,1,pos('.',Text)-1);
          Text := Copy(Text,pos('.',Text)+1,Length(Text));
          colIndex := ExtractIndex(st);
          if colIndex = -1 then
            result := nil
          else
          begin
            obj := (Obj2 as TElHeaderSections).Item[colIndex];
            result := FindProperties(obj, Text, obj, value);
          end;
        end else
        {$ENDIF}
          result := FindProperties(Obj2, Text, Obj, value);
      end else
        result := nil;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Analyse(Line: string);
var
  value: string;
  prop: PPropInfo;
  obj: TObject;
begin
  if pos('=',Line)=0 then
    Exit;

  //Separate compo and value
  value := Trim(Copy(Line, pos('=',Line)+1, Length(Line)));
  Line := Trim(Copy(Line, 1, pos('=',Line)-1));

  //Find property
  try
    prop := FindProperties(Application as TComponent, Line, obj, value);
    AssignValue(obj, prop, value);
  except
    on e: Exception do
    begin
      if ShowErrors then
        ShowMessage(Format('Unable to assign value for %s = %s', [line, value]));
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Analyse(Line: string; AFrame: TFrame);
var
  value: string;
  prop: PPropInfo;
  obj: TObject;
begin
  if pos('=',Line)=0 then
    Exit;

  //Separate compo and value
  value := Trim(Copy(Line, pos('=',Line)+1, Length(Line)));
  Line := Trim(Copy(Line, 1, pos('=',Line)-1));

  //Find property
  try
    prop := FindProperties(AFrame, Line, obj, value);
    AssignValue(obj, prop, value);
  except
    on e:exception do
    begin
      if ShowErrors then
        ShowMessage(Format('Unable to assign value for %s = %s', [line, value]));
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Analyse(Line: string; AForm: TForm);
var
  value: string;
  prop: PPropInfo;
  obj: TObject;
begin
  if pos('=',Line)=0 then
    Exit;

  //Separate compo and value
  value := Trim(Copy(Line, pos('=',Line)+1, Length(Line)));
  Line := Trim(Copy(Line, 1, pos('=',Line)-1));

  //Find property
  try
    prop := FindProperties(AForm, Line, obj, value);
    AssignValue(obj, prop, value);
  except
    on e:exception do
    begin
      if ShowErrors then
        ShowMessage(Format('Unable to assign value for %s = %s', [line, value]));
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.AssignValue(Obj: TObject; Prop: PPropInfo; const Value: string);
begin
  if (Obj = nil) or (Prop = nil) then
    Exit;
  case Prop^.PropType^.Kind of
    tkString, tkLString:
      SetStrProp(obj, Prop, Value);
    tkInteger, tkEnumeration:
      SetOrdProp(obj, Prop, StrToInt(Value));
{Soulsnake Mod}
    tkSet:
      SetSetProp(obj, Prop, Value);
{End Soulsnake Mod}
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Translate(const FileName: string);
var
 fich: TextFile;
 st: string;
begin
  AssignFile(fich, FileName);
  Reset(fich);
  while not(eof(fich)) do
  begin
    ReadLn(fich,st);
    st := trim(st);
    if (st<>'') and (st[1]<>';') then
      Analyse(st);
  end;
  CloseFile(fich);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.SetLanguageFile(const newFile: string);
begin
  if FLanguageFile = nil then
    FLanguageFile := TStringList.Create;
  try
    FLanguageFile.LoadFromFile(newFile);
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Translate(const FileName: string; const Forms: array of string);
var
  i,j: integer;
  values: TStringList;
begin
  values := nil;
  with TMemIniFile.Create(FileName) do
  begin
    try
      values := TStringList.Create;
      for i := 0 to length(Forms)-1 do
      begin
        values.Clear;
        ReadSectionValues(Forms[i], values);
        for j := 0 to values.Count-1 do
        begin
          Analyse(values.Strings[j]);
        end;
      end;
    finally
      values.Free;
      Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Translate(const Forms: array of string);
var
  i,j: integer;
  line: string;
begin
  if (FLanguageFile <> nil) and (FLanguageFile.Count > 0) then
    for i := 0 to length(Forms)-1 do
      with FLanguageFile do
      begin
        j := IndexOf('[' + Forms[i] + ']');
        inc(j);
        if j > 0 then
          while (j < Count) do
          begin
            line := Strings[j];
            if (Length(line) > 0) and (line[1] <> ';') then
              if (line[1] = '[') then
                j := Count
              else
                Analyse(line);
            inc(j);
          end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Translate(const AFrame: TFrame);
var
  ClassRef: TClass;
  procedure LocalTranslate(const AFrame: TFrame; const AClassName: string);
  var
    i: Integer;
    line: string;
  begin
    with FLanguageFile do
    begin
      i := IndexOf('[' + AClassName + ']');
      Inc(i);
      if i > 0 then
        while (i < Count) do
        begin
          line := Strings[i];
          if (Length(line) > 0) and (line[1] <> ';') then
            if (line[1] = '[') then
              i := Count
            else
              Analyse(line, AFrame);
          Inc(i);
        end;
    end;
  end;
begin
  if (FLanguageFile <> nil) and (FLanguageFile.Count > 0) then
  begin
    ClassRef := AFrame.ClassType;
    while (ClassRef <> nil) and (ClassRef <> TFrame) do
    begin
      LocalTranslate(AFrame, ClassRef.ClassName);
      ClassRef := ClassRef.ClassParent;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAntTranslator.Translate(const AForm: TForm);
var
  i: Integer;
  line: string;
begin
  if (FLanguageFile <> nil) and (FLanguageFile.Count > 0) then
    with FLanguageFile do
    begin
      i := IndexOf('[' + AForm.Name + ']');
      Inc(i);
      if i > 0 then
        while (i < Count) do
        begin
          line := Strings[i];
          if (Length(line) > 0) and (line[1] <> ';') then
            if (line[1] = '[') then
              i := Count
            else
              Analyse(line, AForm);
          Inc(i);
        end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ExtractIndex(const text: string): integer;
var
  beginPos, endPos: integer;
  index: string;
begin
  beginPos := pos('[', text);
  endPos := pos(']', text);
  if (beginPos <> 0) and (endPos <> 0) then
  begin
    index := copy(text, beginPos+1, endPos-BeginPos-1);
    result := strToInt(index);
  end else
    result := -1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TAntTranslator.Create(AOwner: TComponent);
begin
  inherited;
  FLanguageFile := nil;
  ShowErrors := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TAntTranslator.Destroy;
begin
  FLanguageFile.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
