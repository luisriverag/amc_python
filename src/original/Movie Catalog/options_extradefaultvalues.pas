unit options_extradefaultvalues;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, AntCorelButton, AntAutoHintLabel, ExtCtrls,
  frameextra;

type
  TExtraDefaultValuesWin = class(TBaseDlg)
    FrmExtra: TExtraFrame;
    PanelExtra: TPanel;
    procedure btn3Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
  end;

var
  ExtraDefaultValuesWin: TExtraDefaultValuesWin;

implementation

uses
  Global, movieclass;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.btn3Click(Sender: TObject);
var
  bChecked: Boolean;
begin
  with Settings.rOptions.rMovieInformation.rDefaultExtra do
  begin
    bChecked := Values.bChecked;
    Values.InitFields;
    Values.bChecked := bChecked;
    FrmExtra.LoadFromObject(Values);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.LoadOptions;
begin
  with Settings.rOptions.rMovieInformation.rDefaultExtra do
  begin
    Self.Width := WindowWidth;
    Self.Height := WindowHeight;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.SaveOptions;
begin
  with Settings.rOptions.rMovieInformation.rDefaultExtra do
  begin
    WindowWidth := Self.Width;
    WindowHeight := Self.Height;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.btn2Click(Sender: TObject);
begin
  with Settings.rOptions.rMovieInformation.rDefaultExtra do
  begin
    FrmExtra.SaveToObject(Values);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.FormShow(Sender: TObject);
begin
  inherited;
  FrmExtra.ETitle.SetFocus;
  FrmExtra.LoadFromObject(Settings.rOptions.rMovieInformation.rDefaultExtra.Values);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TExtraDefaultValuesWin.Translate;
begin
  inherited;
  Translator.Translate(FrmExtra);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
