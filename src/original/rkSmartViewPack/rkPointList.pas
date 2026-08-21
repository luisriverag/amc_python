unit rkPointList;

interface

uses
  Classes, SysUtils, Windows;

type
  { TPtList class }
  TPtList = class;

  PPtItemList = ^TPtItemList;
  TPtItemList = array[0..0] of TPoint;
  TPtListSortCompare = function(List: TPtList; Index1, Index2: Integer):
    Integer;

  TPtList = class(TPersistent)
  private
    FList: PPtItemList;
    FCount: Integer;
    FCapacity: Integer;
    FSorted: Boolean;
    FDuplicates: TDuplicates;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    procedure ExchangeItems(Index1, Index2: Integer);
    procedure Grow;
    procedure QuickSort(L, R: Integer; SCompare: TPtListSortCompare);
    procedure InsertItem(Index: Integer; const S: TPoint);
    procedure SetSorted(Value: Boolean);
  protected
    procedure Error(const Msg: string; Data: Integer);
    function Get(Index: Integer): TPoint;
    function GetCapacity: Integer;
    function GetCount: Integer;
    procedure Put(Index: Integer; const S: TPoint);
    procedure SetCapacity(NewCapacity: Integer);
  public
    destructor Destroy; override;
    function Add(const S: TPoint): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Find(const S: TPoint; var Index: Integer): Boolean; virtual;
    function IndexOf(const S: TPoint): Integer;
    procedure Insert(Index: Integer; const S: TPoint);
    procedure Sort; virtual;
    procedure CustomSort(Compare: TPtListSortCompare); virtual;

    procedure LoadFromFile(const FileName: string); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToFile(const FileName: string); virtual;
    procedure SaveToStream(Stream: TStream);

    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
    property Sorted: Boolean read FSorted write SetSorted;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property Points[Index: Integer]: TPoint read Get write Put; default;
    property Count: Integer read GetCount;
  end;

implementation

{ TPtList }

destructor TPtList.Destroy;
begin
  inherited destroy;
  FCount := 0;
  SetCapacity(0);
end;

procedure TPtList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EStringListError.CreateFmt(Msg, [Data])at ReturnAddr;
end;

const
  sDuplicatePoint: string = 'Cannot add point because it already exists';
  sListIndexError = 'List index Error';
  SSortedListError = 'Cannont insert to sorted list';

function TPtList.Add(const S: TPoint): Integer;
begin
  if not Sorted then
    Result := FCount
  else if Find(S, Result) then
    case Duplicates of
      dupIgnore: Exit;
      dupError: Error(SDuplicatePoint, 0);
    end;
  InsertItem(Result, S);
end;

procedure TPtList.Clear;
begin
  if FCount <> 0 then begin
    FCount := 0;
    SetCapacity(0);
  end;
end;

procedure TPtList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index], (FCount - Index) * SizeOf(TPoint));
end;

procedure TPtList.Exchange(Index1, Index2: Integer);
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  ExchangeItems(Index1, Index2);
end;

procedure TPtList.ExchangeItems(Index1, Index2: Integer);
var
  Temp: TPoint;
  Item1, Item2: ^TPoint;
begin
  Item1 := @FList^[Index1];
  Item2 := @FList^[Index2];
  Temp := TPoint(Item1^);
  Item1^ := Item2^;
  Item2^ := Temp;
end;

function TPtList.Find(const S: TPoint; var Index: Integer): Boolean;
var
  L, H, I: Integer;
begin
  Result := False;
  L := 0;
  H := FCount - 1;
  while L <= H do begin
    I := (L + H) shr 1;
    if (Flist^[I].X < S.X) or ((Flist^[I].X = S.X) and (Flist^[I].Y < S.Y)) then
      L := L + 1
    else
    begin
      H := I - 1;
      if (FList^[I].X = S.X) and (FList^[I].Y = S.Y) then
      begin
        Result := True;
        if Duplicates <> dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

function TPtList.Get(Index: Integer): TPoint;
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Result := FList^[Index];
end;

function TPtList.GetCapacity: Integer;
begin
  Result := FCapacity;
end;

function TPtList.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TPtList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4
  else if FCapacity > 8 then  Delta := 16
  else Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TPtList.IndexOf(const S: TPoint): Integer;
begin
  if not Sorted then begin
    for Result := 0 to GetCount - 1 do
      if (FList^[Result].X = S.X) and (FList^[Result].Y = S.Y) then Exit;
    Result := -1;
  end
  else if not Find(S, Result) then
    Result := -1;
end;

procedure TPtList.Insert(Index: Integer; const S: TPoint);
begin
  if Sorted then Error(SSortedListError, 0);
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  InsertItem(Index, S);
end;

procedure TPtList.InsertItem(Index: Integer; const S: TPoint);
begin
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1], (FCount - Index) * SizeOf(TPoint));
  FList^[Index] := s;
  Inc(FCount);
end;

procedure TPtList.Put(Index: Integer; const S: TPoint);
begin
  if Sorted then Error(SSortedListError, 0);
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  FList^[Index] := S;
end;

procedure TPtList.QuickSort(L, R: Integer; SCompare: TPtListSortCompare);
var
  I, J, P: Integer;
begin
  repeat
    I := L;
    J := R;
    P := (L + R) shr 1;
    repeat
      while SCompare(Self, I, P) < 0 do Inc(I);
      while SCompare(Self, J, P) > 0 do Dec(J);
      if I <= J then begin
        ExchangeItems(I, J);
        if P = I then P := J
        else if P = J then P := I;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSort(L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TPtList.SetCapacity(NewCapacity: Integer);
begin
  ReallocMem(FList, NewCapacity * SizeOf(TPoint));
  FCapacity := NewCapacity;
end;

procedure TPtList.SetSorted(Value: Boolean);
begin
  if FSorted <> Value then begin
    if Value then Sort;
    FSorted := Value;
  end;
end;

function PtListCompare(List: TPtList; Index1, Index2: Integer): Integer;
begin
  if List.FList^[Index1].X > List.FList^[Index2].X then result := +1
  else if List.FList^[Index1].X < List.FList^[Index2].X then result := -1
  else if List.FList^[Index1].Y > List.FList^[Index2].Y then result := +1
  else if List.FList^[Index1].Y < List.FList^[Index2].Y then result := -1
  else result := 0;
end;

procedure TPtList.Sort;
begin
  CustomSort(PtListCompare);
end;

procedure TPtList.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TPtList.SaveToStream(Stream: TStream);
var
  i: integer;
  N: integer;
  Val: TPoint;
begin
  N := count;
  Stream.WriteBuffer(N, sizeof(N));
  for i := 0 to count - 1 do begin
    val := Points[i];
    stream.writebuffer(val, sizeof(val));
  end;
end;

procedure TPtList.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TPtList.LoadFromStream(Stream: TStream);
var
  Size: Integer;
  i: integer;
  N: TPoint;
begin
  try
    clear;
    Stream.readbuffer(size, sizeof(size));
    for i := 0 to size - 1 do begin
      Stream.Read(N, sizeof(N));
      add(N);
    end;
  finally
  end;
end;

procedure TPtList.CustomSort(Compare: TPtListSortCompare);
begin
  if not Sorted and (FCount > 1) then QuickSort(0, FCount - 1, Compare);
end;

end.

