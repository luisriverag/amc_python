
{====================================================}
{                                                    }
{   EldoS Visual Components                          }
{                                                    }
{   Copyright (c) 1998-2001, EldoS                   }
{                                                    }
{====================================================}

{$I ElPack.inc}

unit ElHintWnd;  { TElHintWindow component. }

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
{$IFDEF HAS_HTML_RENDER}
  HTMLRender,
{$ENDIF}
  Controls;

type
  TElHintWindow = class(THintWindow)
  private
    FFont : TFont;
{$IFDEF HAS_HTML_RENDER}
    FRender : TElHTMLRender;
    FIsHTML : boolean;
{$ENDIF}
    procedure SetFont(newValue : TFont);
  public
    constructor Create(AOwner : TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    function CalcHintRect(MaxWidth: Integer; const AHint: string; AData: Pointer): TRect; override;
  published
    property Font : TFont read FFont write SetFont;  { Published }
{$IFDEF HAS_HTML_RENDER}
    property IsHTML : boolean read FIsHTML write FIsHTML;
{$ENDIF}
  end;  { TElHintWindow }

implementation

function TElHintWindow.CalcHintRect;
begin
{$IFDEF HAS_HTML_RENDER}
  if IsHTML then
  begin
    FRender.Data.DefaultColor := Font.Color;
    FRender.Data.DefaultBgColor := Color;

    FRender.Data.DefaultStyle := Font.Style;
    FRender.Data.DefaultSize := Font.Size;
    FRender.Data.DefaultFont := Font.Name;
    FRender.PrepareText(AHint, 0, false);
    Result := Rect(0, 0, FRender.Data.TextSize.cx, FRender.Data.TextSize.cy + 2);
    Inc(Result.Right, 6);
    Inc(Result.Bottom, 2);
  end else
{$ENDIF}
  begin
    Canvas.Font.Assign(Font);
    result := inherited CalcHintRect(MaxWidth, AHint, AData);
  end;
end;

procedure TElHintWindow.Paint;  { public }
var R: TRect;
begin
  R := ClientRect;
  Inc(R.Left, 2);
  Inc(R.Top, 2);
  Canvas.Font.Assign(Font);

{$IFDEF HAS_HTML_RENDER}
  if IsHTML then
  begin

    FRender.Data.DefaultColor := Font.Color;
    FRender.Data.DefaultBgColor := Color;

    FRender.Data.DefaultStyle := Font.Style;
    FRender.Data.DefaultSize := Font.Size;
    FRender.Data.DefaultFont := Font.Name;
    FRender.PrepareText(Caption, 0, false);
    FRender.DrawText(Canvas, Point(0, 0), R);
  end else
{$ENDIF}
    DrawText(Canvas.Handle, PChar(Caption), -1, R, DT_LEFT or DT_NOPREFIX or DT_WORDBREAK);
end; { Paint }

procedure TElHintWindow.SetFont(newValue : TFont);
{ Sets data member FFont to newValue. }
begin
  FFont.Assign(newValue);
end;  { SetFont }

destructor TElHintWindow.Destroy;
begin
  FFont.Free;
{$IFDEF HAS_HTML_RENDER}
   FRender.Free;
{$ENDIF}
  inherited Destroy;
end;  { Destroy }

constructor TElHintWindow.Create(AOwner : TComponent);
{ Creates an object of type TElHintWindow, and initializes properties. }
begin
  inherited Create(AOwner);
  FFont := TFont.Create;
{$IFDEF HAS_HTML_RENDER}
   FRender := TElHTMLRender.Create;
{$ENDIF}
end;  { Create }

end.

