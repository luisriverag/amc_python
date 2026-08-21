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

unit threaddownload;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

interface

uses
  SysUtils, Classes, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, IdException;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TDownloadAction = (daGetPage, daGetFile, daPostPage);
  TDownloadState = (dsNone, dsBusy, dsFinished, dsFailed, dsCanceled);

  TDownloadThread = class(TThread)
  private
    FStatusText: string;
    procedure SetStatus;
    procedure httpStatus(axSender: TObject; const axStatus: TIdStatus; const asStatusText: String);
    procedure httpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
  protected
    procedure Execute; override;
  public
    FResult: string;
    FState: TDownloadState;
    FURL: string;
    FParams: string;
    FStream: TStream;
    FToDo: TDownloadAction;
    FHTTP: TIdHTTP;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Forms,
  IdGlobal, IdExceptionCore,
  Global, progress, functions_files;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDownloadThread.Execute;
var
  sl: TStringList;

begin
  FState := dsNone;
  FStatusText := 'Idle';
  Synchronize(SetStatus);
  FHTTP.OnWork := httpWork;
  FHTTP.OnStatus := httpStatus;
  try
    try
      case FToDo of
        daGetPage:
          begin
            FState := dsBusy;
            FResult := FHTTP.Get(FURL, IndyTextEncoding_UTF8);
            FState := dsFinished;
          end;
        daGetFile:
          begin
            FResult := '';
            FState := dsBusy;
            FHTTP.Get(FURL, FStream);
            FState := dsFinished;
          end;
        daPostPage:
          begin
            sl := TStringList.Create;
            try
              sl.Text := FParams;
              FState := dsBusy;
              FResult := FHTTP.Post(FURL, sl, IndyTextEncoding_UTF8, IndyTextEncoding_UTF8, IndyTextEncoding_UTF8);
              //sl.Text := FResult;
              //sl.SaveToFile('e:\data.txt');
              FState := dsFinished;
            finally
              sl.Free;
            end;
          end;
      end;
    finally
      try
        if (FHTTP.Connected) and (not Settings.rOptions.rScripting.KeepConnection) then
          FHTTP.Disconnect;
      except
      end;
    end;
  except
    on E: EIdClosedSocket do
    begin
      FState := dsCanceled;
      FResult := '';
    end;
    on E: Exception do
    begin
      FState := dsFailed;
      FResult := E.Message;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDownloadThread.httpStatus(axSender: TObject; const axStatus: TIdStatus; const asStatusText: String);
begin
  FStatusText := asStatusText;
  Synchronize(SetStatus);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDownloadThread.httpWork(ASender: TObject; AWorkMode: TWorkMode; AWorkCount: Int64);
begin
  if AWorkMode = wmRead then
  begin
    FStatusText := Format('Downloading: %d bytes', [AWorkCount]);
    Synchronize(SetStatus);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TDownloadThread.SetStatus;
begin
  with ProgressWin do
    if Visible then
      Progress := FStatusText;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
