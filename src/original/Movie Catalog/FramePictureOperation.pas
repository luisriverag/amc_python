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

unit FramePictureOperation;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MovieClass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPictureOperationFrame = class(TFrame)
    grp: TGroupBox;
    rbtStore: TRadioButton;
    rbtStoreIfCopied: TRadioButton;
    rbtCopyInCatDir: TRadioButton;
    rbtCopyInCatDirIfStored: TRadioButton;
    rbtCopyInCatDirIfCopied: TRadioButton;
    rbtCopyInPicDir: TRadioButton;
    rbtCopyInPicDirIfStored: TRadioButton;
    rbtCopyInPicDirIfCopied: TRadioButton;
    rbtRenameIfCopied: TRadioButton;
    rbtAbsToRelLink: TRadioButton;
    rbtRelToAbsLink: TRadioButton;
    rbtDelete: TRadioButton;
    rbtConvertIfStoredOrCopied: TRadioButton;
    rbtConvert: TRadioButton;
    LMaxPicSizeW: TLabel;
    EMaxPicSizeW: TEdit;
    LMaxPicSizeH: TLabel;
    EMaxPicSizeH: TEdit;
    LMaxPicSizeUnit: TLabel;
    procedure rbtClick(Sender: TObject);
  private
    function GetSelected: TMoviePictureOperation;
    procedure SetSelected(const Value: TMoviePictureOperation);
  public
    property Selected: TMoviePictureOperation read GetSelected write SetSelected;
    function OperationEnabled(Operation: TMoviePictureOperation): Boolean;
    procedure EnableOperation(Operation: TMoviePictureOperation; Value: Boolean);
    function MaxPicSizeW: Integer;
    function MaxPicSizeH: Integer;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
  TPictureOperationFrame
-------------------------------------------------------------------------------}

function TPictureOperationFrame.GetSelected: TMoviePictureOperation;
begin
  if rbtStore.Checked then
    result := mpoStore
  else if rbtStoreIfCopied.Checked then
    result := mpoStoreIfCopied
  else if rbtCopyInCatDir.Checked then
    result := mpoCopyInCatDir
  else if rbtCopyInCatDirIfStored.Checked then
    result := mpoCopyInCatDirIfStored
  else if rbtCopyInCatDirIfCopied.Checked then
    result := mpoCopyInCatDirIfCopied
  else if rbtCopyInPicDir.Checked then
    result := mpoCopyInPicDir
  else if rbtCopyInPicDirIfStored.Checked then
    result := mpoCopyInPicDirIfStored
  else if rbtCopyInPicDirIfCopied.Checked then
    result := mpoCopyInPicDirIfCopied
  else if rbtRenameIfCopied.Checked then
    result := mpoRenameIfCopied
  else if rbtAbsToRelLink.Checked then
    result := mpoAbsToRelLink
  else if rbtRelToAbsLink.Checked then
    result := mpoRelToAbsLink
  else if rbtDelete.Checked then
    result := mpoDelete
  else if rbtConvertIfStoredOrCopied.Checked then
    result := mpoConvertIfStoredOrCopied
  else if rbtConvert.Checked then
    result := mpoConvert
  else
    result := mpoUndefined;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureOperationFrame.SetSelected(const Value: TMoviePictureOperation);
begin
  case Value of
    mpoStore:                   rbtStore.Checked := True;
    mpoStoreIfCopied:           rbtStoreIfCopied.Checked := True;
    mpoCopyInCatDir:            rbtCopyInCatDir.Checked := True;
    mpoCopyInCatDirIfStored:    rbtCopyInCatDirIfStored.Checked := True;
    mpoCopyInCatDirIfCopied:    rbtCopyInCatDirIfCopied.Checked := True;
    mpoCopyInPicDir:            rbtCopyInPicDir.Checked := True;
    mpoCopyInPicDirIfStored:    rbtCopyInPicDirIfStored.Checked := True;
    mpoCopyInPicDirIfCopied:    rbtCopyInPicDirIfCopied.Checked := True;
    mpoRenameIfCopied:          rbtRenameIfCopied.Checked := True;
    mpoAbsToRelLink:            rbtAbsToRelLink.Checked := True;
    mpoRelToAbsLink:            rbtRelToAbsLink.Checked := True;
    mpoDelete:                  rbtDelete.Checked := True;
    mpoConvertIfStoredOrCopied: rbtConvertIfStoredOrCopied.Checked := True;
    mpoConvert:                 rbtConvert.Checked := True;
  end;
  rbtClick(Self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureOperationFrame.OperationEnabled(Operation: TMoviePictureOperation): Boolean;
begin
  case Operation of
    mpoStore:                   result := rbtStore.Enabled;
    mpoStoreIfCopied:           result := rbtStoreIfCopied.Enabled;
    mpoCopyInCatDir:            result := rbtCopyInCatDir.Enabled;
    mpoCopyInCatDirIfStored:    result := rbtCopyInCatDirIfStored.Enabled;
    mpoCopyInCatDirIfCopied:    result := rbtCopyInCatDirIfCopied.Enabled;
    mpoCopyInPicDir:            result := rbtCopyInPicDir.Enabled;
    mpoCopyInPicDirIfStored:    result := rbtCopyInPicDirIfStored.Enabled;
    mpoCopyInPicDirIfCopied:    result := rbtCopyInPicDirIfCopied.Enabled;
    mpoRenameIfCopied:          result := rbtRenameIfCopied.Enabled;
    mpoAbsToRelLink:            result := rbtAbsToRelLink.Enabled;
    mpoRelToAbsLink:            result := rbtRelToAbsLink.Enabled;
    mpoDelete:                  result := rbtDelete.Enabled;
    mpoConvertIfStoredOrCopied: result := rbtConvertIfStoredOrCopied.Enabled;
    mpoConvert:                 result := rbtConvert.Enabled;
  else
    result := False;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureOperationFrame.EnableOperation(Operation: TMoviePictureOperation; Value: Boolean);
begin
  case Operation of
    mpoStore:                   rbtStore.Enabled := Value;
    mpoStoreIfCopied:           rbtStoreIfCopied.Enabled := Value;
    mpoCopyInCatDir:            rbtCopyInCatDir.Enabled := Value;
    mpoCopyInCatDirIfStored:    rbtCopyInCatDirIfStored.Enabled := Value;
    mpoCopyInCatDirIfCopied:    rbtCopyInCatDirIfCopied.Enabled := Value;
    mpoCopyInPicDir:            rbtCopyInPicDir.Enabled := Value;
    mpoCopyInPicDirIfStored:    rbtCopyInPicDirIfStored.Enabled := Value;
    mpoCopyInPicDirIfCopied:    rbtCopyInPicDirIfCopied.Enabled := Value;
    mpoRenameIfCopied:          rbtRenameIfCopied.Enabled := Value;
    mpoAbsToRelLink:            rbtAbsToRelLink.Enabled := Value;
    mpoRelToAbsLink:            rbtRelToAbsLink.Enabled := Value;
    mpoDelete:                  rbtDelete.Enabled := Value;
    mpoConvertIfStoredOrCopied: rbtConvertIfStoredOrCopied.Enabled := Value;
    mpoConvert:                 rbtConvert.Enabled := Value;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureOperationFrame.MaxPicSizeW: Integer;
begin
  Result := 0;
  if rbtConvertIfStoredOrCopied.Checked or rbtConvert.Checked then
    Result := StrToIntDef(EMaxPicSizeW.Text, 0);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureOperationFrame.MaxPicSizeH: Integer;
begin
  Result := 0;
  if rbtConvertIfStoredOrCopied.Checked or rbtConvert.Checked then
    Result := StrToIntDef(EMaxPicSizeH.Text, 0);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureOperationFrame.rbtClick(Sender: TObject);
begin
  EMaxPicSizeW.Enabled := rbtConvertIfStoredOrCopied.Checked or rbtConvert.Checked;
  EMaxPicSizeH.Enabled := EMaxPicSizeW.Enabled;
  LMaxPicSizeW.Enabled := EMaxPicSizeW.Enabled;
  LMaxPicSizeH.Enabled := EMaxPicSizeH.Enabled;
  LMaxPicSizeUnit.Enabled := EMaxPicSizeH.Enabled;
end;

end.
