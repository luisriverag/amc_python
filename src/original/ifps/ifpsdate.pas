unit ifpsdate;
{
  Innerfuse Pascal Script Library
  For license see Innerfuse Pascal Script license file

}
interface
uses
  ifspas, ifs_utl, ifs_var;

procedure RegisterDateTimeLib(ScriptEngine: TIFPasScript);
{
  Registers:

type
  TDateTime = double;

function EncodeDate(Year, Month, Day: Word): TDateTime;
function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);
procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);
function Date: TDateTime;
function Time: TDateTime;
function Now: TDateTime;
function DateToStr(DateTime: TDateTime): string;
function TimeToStr(DateTime: TDateTime): string;
function DateTimeToStr(DateTime: TDateTime): string;
function StrToDate(S: string): TDateTime;
function StrToDateDef(S: string; Default: TDateTime): TDateTime;
function StrToTime(S: string): TDateTime;
function StrToTimeDef(S: string; Default: TDateTime): TDateTime;
function StrToDateTime(S: string): TDateTime;
function StrToDateTimeDef(S: string; Default: TDateTime): TDateTime;
}
implementation
uses
  Sysutils;

function DProc(Sender, ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  Result := ENoError;
  if Proc^.Name = 'ENCODEDATE' then begin
    try
      TDateTime(res^.CV_Double) := EncodeDate(vm_get2(params, 0)^.CV_UInt16, vm_get2(params, 1)^.CV_UInt16, vm_get2(params, 2)^.CV_UInt16);
    except
      TIFPasScript(Sender).RunError2(Sender, ECustomError, 'Invalid date');
      Result := ECustomError;
    end;
  end else if Proc^.Name = 'ENCODETIME' then begin
    try
      TDateTime(res^.CV_Double) := EncodeTime(vm_get2(params, 0)^.CV_UInt16, vm_get2(params, 1)^.CV_UInt16, vm_get2(params, 2)^.CV_UInt16, vm_get2(params, 3)^.CV_UInt16);
    except
      TIFPasScript(Sender).RunError2(Sender, ECustomError, 'Invalid date');
      Result := ECustomError;
    end;
  end else if Proc^.Name = 'DECODEDATE' then begin
    DecodeDate(vm_get2(Params, 0)^.CV_Double, vm_get2(Params, 1)^.Cv_UInt16, vm_get2(Params, 2)^.Cv_UInt16, vm_get2(Params, 3)^.Cv_UInt16);
  end else if Proc^.Name = 'DECODETIME' then begin
    DecodeTime(vm_get2(Params, 0)^.CV_Double, vm_get2(Params, 1)^.Cv_UInt16, vm_get2(Params, 2)^.Cv_UInt16, vm_get2(Params, 3)^.Cv_UInt16, vm_get2(Params, 4)^.Cv_UInt16);
  end else if Proc^.Name = 'DATE' then begin
    Res^.CV_Double := Date;
  end else if Proc^.Name = 'TIME' then begin
    Res^.CV_Double := Time;
  end else if Proc^.Name = 'NOW' then begin
    Res^.CV_Double := Now;
  end else if Proc^.Name = 'DATETOSTR' then begin
    Res^.CV_Str := DateToStr(vm_get2(Params, 0)^.CV_Double);
  end else if Proc^.Name = 'TIMETOSTR' then begin
    Res^.CV_Str := TimeToStr(vm_get2(Params, 0)^.CV_Double);
  end else if Proc^.Name = 'DATETIMETOSTR' then begin
    Res^.CV_Str := DateTimeToStr(vm_get2(Params, 0)^.CV_Double);
  end else if Proc^.Name = 'STRTODATE' then begin
    try
      TDateTime(Res^.CV_Double) := StrToDate(vm_get2(Params, 0)^.CV_Str);
    except
      TIFPasScript(Sender).RunError2(Sender, ECustomError, 'Invalid date');
      Result := ECustomError;
    end;

  end else if Proc^.Name = 'STRTODATEDEF' then begin
    try
      Res^.cv_double := strToDate(vm_get2(Params, 0)^.CV_Str);
    except
      Res^.cv_double := vm_get2(Params, 1)^.CV_Double;
    end;
  end else if Proc^.Name = 'STRTOTIME' then begin
    try
      TDateTime(Res^.CV_Double) := STrToTime(vm_get2(Params, 0)^.CV_Str);
    except
      TIFPasScript(Sender).RunError2(Sender, ECustomError, 'Invalid date');
      Result := ECustomError;
    end;
  end else if Proc^.Name = 'STRTOTIMEDEF' then begin
    try
      Res^.cv_double := strToTime(vm_get2(Params, 0)^.CV_Str);
    except
      Res^.CV_Double := vm_get2(Params, 1)^.CV_Double;
    end;
  end else if Proc^.Name = 'STRTODATETIME' then begin
    try
      TDateTime(Res^.CV_Double) := StrToDateTime(vm_get2(Params, 0)^.CV_Str);
    except
      TIFPasScript(Sender).RunError2(Sender, ECustomError, 'Invalid date');
      Result := ECustomError;
    end;
  end else if Proc^.Name = 'STRTODATETIMEDEF' then begin
    try
      Res^.cv_double := strToDateTime(vm_get2(Params, 0)^.CV_Str);
    except
      res^.CV_Double := vm_get2(Params, 1)^.CV_Double;
    end;
  end else result := EUnknownIdentifier;
end;

procedure RegisterDateTimeLib(ScriptEngine: TIFPasScript);
begin
  ScriptEngine.AddType('TDateTime', 'Double');
  ScriptEngine.AddFunction(@dproc, 'function EncodeDate(Year, Month, Day: Word): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'procedure DecodeDate(DateTime: TDateTime; var Year, Month, Day: Word);', nil);
  ScriptEngine.AddFunction(@dproc, 'procedure DecodeTime(DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);', nil);
  ScriptEngine.AddFunction(@dproc, 'function Date: TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function Time: TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function Now: TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function DateToStr(DateTime: TDateTime): string;', nil);
  ScriptEngine.AddFunction(@dproc, 'function TimeToStr(DateTime: TDateTime): string;', nil);
  ScriptEngine.AddFunction(@dproc, 'function DateTimeToStr(DateTime: TDateTime): string;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToDate(S: string): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToDateDef(S: string; Default: TDateTime): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToTime(S: string): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToTimeDef(S: string; Default: TDateTime): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToDateTime(S: string): TDateTime;', nil);
  ScriptEngine.AddFunction(@dproc, 'function StrToDateTimeDef(S: string; Default: TDateTime): TDateTime;', nil);
end;


end.

