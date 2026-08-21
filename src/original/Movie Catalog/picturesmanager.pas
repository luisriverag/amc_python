(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2012-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit picturesmanager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, base, StdCtrls, ComCtrls, ExtCtrls,

  AntStringList, AntCorelButton,

  MovieClass, AntAutoHintLabel, FramePictureOperation,
  frameincludemov, frameincludepic;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPicturesManagerWin = class(TBaseDlg)
    Messages: TAntStringList;
    Includemov: TIncludemovFrame;
    PictureOperation: TPictureOperationFrame;
    Includepic: TIncludepicFrame;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure IncludemovClick(Sender: TObject);
  private
    FMovieList: TMovieList;
    FCatalogFile: TFileName;
    FCancelOp: Boolean;
    procedure OnCancelOp(Sender: TObject);
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    procedure Translate; override;
    function Execute(MovieList: TMovieList; CatalogFile: TFileName): TModalResult;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  PicturesManagerWin: TPicturesManagerWin;

implementation

uses
  Global, Main;

const
  msgApplyingChanges        = 0;
  msgErrorOnMoviePic        = 1;
  msgCatalogWillBeSaved     = 2;
  msgErrorOnExtraPic        = 3;
  msgWarningDelete          = 4;
  msgWarningResize          = 5;
  msgWarningResizeLinked    = 6;

{$R *.dfm}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPicturesManagerWin.Execute(MovieList: TMovieList; CatalogFile: TFileName): TModalResult;
begin
  FMovieList := MovieList;
  FCatalogFile := CatalogFile;
  Includemov.SetCount(FMovieList);
  Includemov.ItemIndex := mioAll;
  Includepic.SetCount(FMovieList, Includemov.ItemIndex);
  Includepic.ItemIndex := pioAll;
  if CatalogFile = '' then
  begin
    PictureOperation.EnableOperation(mpoStoreIfCopied, False);
    PictureOperation.EnableOperation(mpoCopyInCatDir, False);
    PictureOperation.EnableOperation(mpoCopyInCatDirIfStored, False);
    PictureOperation.EnableOperation(mpoCopyInCatDirIfCopied, False);
    PictureOperation.EnableOperation(mpoCopyInPicDir, False);
    PictureOperation.EnableOperation(mpoCopyInPicDirIfStored, False);
    PictureOperation.EnableOperation(mpoCopyInPicDirIfCopied, False);
    PictureOperation.EnableOperation(mpoRenameIfCopied, False);
    PictureOperation.EnableOperation(mpoAbsToRelLink, False);
    PictureOperation.EnableOperation(mpoRelToAbsLink, False);
  end else if LowerCase(ExtractFileExt(CatalogFile)) = '.xml' then
  begin
    PictureOperation.EnableOperation(mpoStore, False);
    PictureOperation.EnableOperation(mpoStoreIfCopied, False);
  end;
  PictureOperation.rbtClick(Self);
  result := ShowModal;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.LoadOptions;
begin
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.SaveOptions;
begin
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.FormCreate(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.FormDestroy(Sender: TObject);
begin
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.btn2Click(Sender: TObject);
var
  IncMovieOpt: TMovieIncludeOption;
  IncPicOpt: TPictureIncludeOption;
  PicOperation: TMoviePictureOperation;
  NbIncMovies, NbLoop, i, j, n: Integer;
  MaxPicSizeW, MaxPicSizeH: Integer;
  SaveCatalog: Boolean;
  Movie: TMovie;
begin
  ModalResult := mrCancel;
  SaveCatalog := False;
  PicOperation := PictureOperation.Selected;
  MaxPicSizeW := PictureOperation.MaxPicSizeW;
  MaxPicSizeH := PictureOperation.MaxPicSizeH;
  if PicOperation = mpoRenameIfCopied then
    NbLoop := 2 // We have to make two pass to rename picture correctly
  else
    NbLoop := 1;
  if (FMovieList <> nil) and (PicOperation <> mpoUndefined) then
  begin
    if (PicOperation = mpoDelete) then
      case MessageWin.Execute(Messages.Strings[msgWarningDelete], mtWarning, [mbYes, mbCancel]) of
        0, 2:
          begin
            ModalResult := mrNone;
            Exit;
          end;
      end
    else if (PicOperation = mpoConvertIfStoredOrCopied) then
      case MessageWin.Execute(Messages.Strings[msgWarningResize], mtWarning, [mbYes, mbCancel]) of
        0, 2:
          begin
            ModalResult := mrNone;
            Exit;
          end;
      end
    else if (PicOperation = mpoConvert) then
      case MessageWin.Execute(Messages.Strings[msgWarningResizeLinked], mtWarning, [mbYes, mbCancel]) of
        0, 2:
          begin
            ModalResult := mrNone;
            Exit;
          end;
      end;

    if (FCatalogFile <> '') and (PicOperation <> mpoAbsToRelLink) and (PicOperation <> mpoRelToAbsLink) then
    begin
      case MessageWin.Execute(Messages.Strings[msgCatalogWillBeSaved], mtConfirmation, [mbYes, mbNo, mbCancel]) of
        1: SaveCatalog := True;
        0, 3:
          begin
            ModalResult := mrNone;
            Exit;
          end;
      end;
    end;
    IncMovieOpt := Includemov.ItemIndex;
    IncPicOpt := Includepic.ItemIndex;
    NbIncMovies := 0;
    for i := 0 to FMovieList.Count-1 do
      with TMovie(FMovieList.Items[i]) do
        if CanInclude(IncMovieOpt) then
          Inc(NbIncMovies);
    with ProgressWin do
    begin
      Maximum := NbIncMovies * NbLoop;
      Status := Messages.Strings[msgApplyingChanges];
      IntProgress := 0;
      Execute(Self);
      OnCancel := OnCancelOp;
      FCancelOp := False;
      try
        with FMovieList do
        begin
          n := 0;
          while (n < NbLoop) and (not FCancelOp) do
          begin
            i := 0;
            while (i < Count) and (not FCancelOp) do
            begin
              Movie := TMovie(Items[i]);
              if Movie.CanInclude(IncMovieOpt) then
              begin
                IntProgress := i + (n * NbIncMovies);
                try
                  if (IncPicOpt = pioAll) or (IncPicOpt = pioMovie) then
                    Movie.Picture.PictureOperation(FCatalogFile, PicOperation, '',
                      MaxPicSizeW, MaxPicSizeH);
                  if (IncPicOpt = pioAll) or (IncPicOpt = pioExtras) then
                  begin
                    j := 0;
                    while (j < Movie.Extras.Count) and (not FCancelOp) do
                    begin
                      try
                        Movie.Extras.Items[j].Picture.PictureOperation(FCatalogFile,
                          PicOperation, '', MaxPicSizeW, MaxPicSizeH);
                      except
                        on e: Exception do
                          if MessageWin.Execute(Format(messages.Strings[msgErrorOnExtraPic],
                            [Movie.Extras.Items[j].Picture.GetPictureCaption, e.Message]),
                            mtError, [mbOk, mbAbort]) = 2 then
                            FCancelOp := True;
                      end;
                      Inc(j);
                    end;
                  end;
                except
                  on e: Exception do
                    if MessageWin.Execute(Format(messages.Strings[msgErrorOnMoviePic],
                      [Movie.Picture.GetPictureCaption, e.Message]),
                      mtError, [mbOk, mbAbort]) = 2 then
                      FCancelOp := True;
                end;
              end;
              Inc(i);
            end;
            Inc(n);
          end;
        end;
        IntProgress := Maximum;
      finally
        Close;
      end;
    end;
    Application.ProcessMessages;
    if SaveCatalog and (not FCancelOp) then
    begin
      MainWindow.ActionFileSaveExecute(Self);
      MainWindow.ListView1AfterSelectionChange(nil);
      MainWindow.ThumbsViewerStart;
      ModalResult := mrCancel;
    end else
      ModalResult := mrOk;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.Translate;
begin
  Translator.Translate(PictureOperation);
  Translator.Translate(Includemov);
  Translator.Translate(Includepic);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.IncludemovClick(Sender: TObject);
begin
  Includepic.SetCount(FMovieList, Includemov.ItemIndex);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPicturesManagerWin.OnCancelOp;
begin
  FCancelOp := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
