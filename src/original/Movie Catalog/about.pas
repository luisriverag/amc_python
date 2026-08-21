(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2023 Antoine Potten, Mickaël Vanneufville                 *
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

unit about;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Dialogs, Forms, StdCtrls, ExtCtrls, Buttons, ComCtrls, ShellApi,

  AntJvScrollText,
  AntStringList, AntJvLinkLabel,
  AntCorelButton, AntAutoHintLabel,

  base;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TAboutWin = class(TBaseDlg)
    Panel1: TPanel;
    Shape1: TShape;
    Image1: TImage;
    LTitle: TLabel;
    LVersion: TLabel;
    PanelScroll: TPanel;
    Scroll: TAntJvScrollText;
    Messages: TAntStringList;
    LLinks: TAntJvLinkLabel;
    AntJvLinkLabel1: TAntJvLinkLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LLinksLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
  protected
  public
    procedure ShowVersions;
  end;

var
  AboutWin: TAboutWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  functions_files, ConstValues, Global, MediaInfo, functions_gui;

const
  msgVersionStr   = 0;
  msgPressCtrlC   = 1;
  msgUnableToRead = 2;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Scroll.Active:=false;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.btn1Click(Sender: TObject);
begin
  LaunchHelp;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.btn2Click(Sender: TObject);
begin
  ShowVersions;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.FormCreate(Sender: TObject);
begin
  inherited;
  PanelScroll.Font.Name := 'MS Shell Dlg'; // the scrolling text reverts to black MS Sans Serif if its parent has 'MS Shell Dlg 2' 
  Scroll.Active := True;
  Sleep(100); // to avoid a bad-looking effect of the scrolltext before it really starts scrolling
  Application.ProcessMessages;
//  DoubleBuffered := True;
  LVersion.Caption := Format('Version %s (%s)', [strFullVersion, strDate]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.FormShow(Sender: TObject);
begin
  inherited;
  Btn3.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.LLinksLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
begin
  case LinkNumber of
    0:  LaunchProg('mailto:' + LinkText);
    1:  LaunchProg('http://' + LinkText);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TAboutWin.ShowVersions;
  var
    mi: TMediaInfo;
  function GetFileInfo(const AFileName: TFileName): string;
  begin
    try
      Result := Format(Messages.Strings[msgVersionStr], [ExtractFileName(AFileName), GetBuild4(AFileName), DateTimeToStr(FileDateToDateTime(FileAge(AFileName)))]);
    except
      Result := Format('%s - %s', [AFileName, Messages.Strings[msgUnableToRead]]);
    end;
  end;
begin
  SetWaitCursor;
  try
    with TStringList.Create do
      try
        Add(GetFileInfo(strAppExe));
        Add(GetFileInfo(strFileExchangeDLL));
        Add(GetFileInfo(strFileDesigner));
        try
          mi := TMediaInfo.Create(strFileMediaInfoDLL, False);
          try
            Add(Format(Messages.Strings[msgVersionStr], [ExtractFileName(strFileMediaInfoDLL), mi.Version, DateTimeToStr(FileDateToDateTime(FileAge(strFileMediaInfoDLL)))]));
          finally
            mi.Free;
          end;
        except
          Format('%s - %s', [strFileMediaInfoDLL, Messages.Strings[msgUnableToRead]]);
        end;
        Add('');
        Add(Messages.Strings[msgPressCtrlC]);
        MessageWin.Execute(Text, mtInformation, [mbOk]);
      finally
        Free;
      end;
  finally
    RestoreCursor;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.

