unit ifpstrans;
{
  Innerfuse Pascal Script Trans library
  For license see Innerfuse Pascal Script license file

}

interface

uses
  ifspas, ifs_var, ifs_utl;

procedure RegisterTransLibrary(p: TIfPasScript);
{
function TransformExtendedToString(E: Extended): string;
function TransformDoubleToString(E: Double): string;
function TransformSingleToString(E: Single): string;
function TransformIntegertoString(E: Longint): string;
function TransformSmallInttoString(E: SmallInt): string;
function TransformBytetoString(E: Byte): string;
function TransformShortIntToString(E: ShortInt): string;
function TransformWordtoString(E: Word): string;

function TransformStringToExtended(E: String): Extended;
function TransformStringToDouble(E: String): Double;
function TransformStringToSingle(E: String): Single;
function TransformStringToInteger(E: String): Longint;
function TransformStringToSmallInt(E: String): SmallInt;
function TransformStringToByte(E: String): Byte;
function TransformStringToShortInt(E: String): ShortInt;
function TransformStringToWord(E: String): word;
}

implementation


function TransformFunc(Sender: TIfPasScript; ScriptID: Pointer; Proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  s: string;
begin
  TransformFunc := ENoError;
  if Proc^.Name = 'TRANSFORMEXTENDEDTOSTRING' then begin
    SetLength(s, sizeof(Extended));
    Move(VM_Get(Params, 0)^.CV_Extended, s[1], Sizeof(Extended));
    SetString(res, s);
  end else
    if Proc^.Name = 'TRANSFORMDOUBLETOSTRING' then begin
      SetLength(s, sizeof(Double));
      Move(VM_Get(Params, 0)^.CV_Double, s[1], Sizeof(Double));
      SetString(res, s);
    end else
      if Proc^.Name = 'TRANSFORMSINGLETOSTRING' then begin
        SetLength(s, sizeof(Single));
        Move(VM_Get(Params, 0)^.CV_Single, s[1], Sizeof(Single));
        SetString(res, s);
      end else
        if Proc^.Name = 'TRANSFORMINTEGERTOSTRING' then begin
          SetLength(s, sizeof(Longint));
          Move(VM_Get(Params, 0)^.CV_SInt32, s[1], Sizeof(Longint));
          SetString(res, s);
        end else
          if Proc^.Name = 'TRANSFORMSMALLINTTOSTRING' then begin
            SetLength(s, sizeof(SmallInt));
            Move(VM_Get(Params, 0)^.CV_SInt16, s[1], Sizeof(SmallInt));
            SetString(res, s);
          end else
            if Proc^.Name = 'TRANSFORMBYTETOSTRING' then begin
              SetLength(s, sizeof(Byte));
              Move(VM_Get(Params, 0)^.CV_UByte, s[1], Sizeof(Byte));
              SetString(res, s);
            end else
              if Proc^.Name = 'TRANSFORMSHORTINTTOSTRING' then begin
                SetLength(s, sizeof(ShortInt));
                Move(VM_Get(Params, 0)^.CV_SByte, s[1], Sizeof(ShortInt));
                SetString(res, s);
              end else
                if Proc^.Name = 'TRANSFORMWORDTOSTRING' then begin
                  SetLength(s, sizeof(Word));
                  Move(VM_Get(Params, 0)^.CV_Uint16, s[1], Sizeof(Word));
                  SetString(res, s);
                end else
                  if Proc^.Name = 'TRANSFORMSTRINGTOEXTENDED' then begin
                    if Length(S) <> Sizeof(Extended) then
                      TransformFunc := EOutOfRange
                    else
                      Move(S[1], Res^.CV_Extended, SizeoF(Extended));
                  end else
                    if Proc^.Name = 'TRANSFORMSTRINGTODOUBLE' then begin
                      if Length(S) <> Sizeof(Double) then
                        TransformFunc := EOutOfRange
                      else
                        Move(S[1], Res^.CV_Double, SizeOf(Double));
                    end else
                      if Proc^.Name = 'TRANSFORMSTRINGTOSINGLE' then begin
                        if Length(S) <> Sizeof(Single) then
                          TransformFunc := EOutOfRange
                        else
                          Move(S[1], Res^.CV_Single, SizeoF(Single));
                      end else
                        if Proc^.Name = 'TRANSFORMSTRINGTOINTEGER' then begin
                          S := GetString(VM_Get(Params, 0));
                          if Length(S) <> Sizeof(Longint) then
                            TransformFunc := EOutOfRange
                          else
                            Move(S[1], Res^.CV_SInt32, SizeOf(Longint));
                        end else
                          if Proc^.Name = 'TRANSFORMSTRINGTOSMALLINT' then begin
                            S := GetString(VM_Get(Params, 0));
                            if Length(S) <> Sizeof(SmallInt) then
                              TransformFunc := EOutOfRange
                            else
                              Move(S[1], Res^.CV_SInt16, SizeOf(SmallInt));
                          end else
                            if Proc^.Name = 'TRANSFORMSTRINGTOBYTE' then begin
                              S := GetString(VM_Get(Params, 0));
                              if Length(S) <> Sizeof(byte) then
                                TransformFunc := EOutOfRange
                              else
                                Move(S[1], Res^.CV_UByte, SizeOf(Byte));
                            end else
                              if Proc^.Name = 'TRANSFORMSTRINGTOSHORTINT' then begin
                                S := GetString(VM_Get(Params, 0));
                                if Length(S) <> Sizeof(ShortInt) then
                                  TransformFunc := EOutOfRange
                                else
                                  Move(S[1], Res^.CV_SByte, SizeOf(ShortInt));
                              end else
                                if Proc^.Name = 'TRANSFORMSTRINGTOWORD' then begin
                                  S := GetString(VM_Get(Params, 0));
                                  if Length(S) <> Sizeof(Word) then
                                    TransformFunc := EOutOfRange
                                  else
                                    Move(S[1], Res^.CV_UInt16, Sizeof(Word));
                                end;
end;

procedure RegisterTransLibrary(p: TIfPasScript);
begin
  P.AddFunction(@TransformFunc, 'function TransformExtendedToString(E: Extended): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformDoubleToString(E: Double): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformSingleToString(E: Single): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformIntegertoString(E: Longint): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformSmallInttoString(E: SmallInt): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformBytetoString(E: Byte): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformShortIntToString(E: ShortInt): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformWordtoString(E: Word): string;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToExtended(E: String): Extended;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToDouble(E: String): Double;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToSingle(E: String): Single;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToInteger(E: String): Longint;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToSmallInt(E: String): SmallInt;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToByte(E: String): Byte;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToShortInt(E: String): ShortInt;', nil);
  P.AddFunction(@TransformFunc, 'function TransformStringToWord(E: String): word;', nil);
end;

end.

