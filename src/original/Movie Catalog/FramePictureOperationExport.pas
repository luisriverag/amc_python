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

unit FramePictureOperationExport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MovieClass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TPictureOperationExportFrame = class(TFrame)
    grp: TGroupBox;
    rbtNoChangeAMC: TRadioButton;
    rbtNoChangeXML: TRadioButton;
    rbtStore: TRadioButton;
    rbtStoreIfCopied: TRadioButton;
    rbtCopyInCatDir: TRadioButton;
    rbtCopyInCatDirIfStored: TRadioButton;
    rbtCopyInPicDir: TRadioButton;
    rbtCopyInPicDirIfStored: TRadioButton;
    rbtDelete: TRadioButton;
  private
    FExportXML: Boolean;
    function GetSelected: TMoviePictureOperation;
    procedure SetSelected(const Value: TMoviePictureOperation);
  public
    procedure SetExportFormat(ExportXML: Boolean);
    property Selected: TMoviePictureOperation read GetSelected write SetSelected;
    function OperationEnabled(Operation: TMoviePictureOperation): Boolean;
    procedure EnableOperation(Operation: TMoviePictureOperation; Value: Boolean);
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
  TPictureOperationExportFrame
-------------------------------------------------------------------------------}

procedure TPictureOperationExportFrame.SetExportFormat(ExportXML: Boolean);
begin
  FExportXML := ExportXML;
  if ExportXML then
  begin
    rbtNoChangeAMC.Visible := False;
    rbtNoChangeXML.Visible := True;
    rbtStore.Enabled := False;
    rbtStoreIfCopied.Enabled := False;
  end
  else
  begin
    rbtNoChangeXML.Visible := False;
    rbtNoChangeAMC.Visible := True;
    rbtStore.Enabled := True;
    rbtStoreIfCopied.Enabled := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureOperationExportFrame.GetSelected: TMoviePictureOperation;
begin
  if rbtStore.Checked then
    result := mpoStore
  else if rbtStoreIfCopied.Checked then
    result := mpoStoreIfCopied
  else if rbtCopyInCatDir.Checked then
    result := mpoCopyInCatDir
  else if rbtCopyInCatDirIfStored.Checked then
    result := mpoCopyInCatDirIfStored
  else if rbtCopyInPicDir.Checked then
    result := mpoCopyInPicDir
  else if rbtCopyInPicDirIfStored.Checked then
    result := mpoCopyInPicDirIfStored
  else if rbtDelete.Checked then
    result := mpoDelete
  else
    result := mpoUndefined;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureOperationExportFrame.SetSelected(const Value: TMoviePictureOperation);
begin
  case Value of
    mpoStore:                 rbtStore.Checked := True;
    mpoStoreIfCopied:         rbtStoreIfCopied.Checked := True;
    mpoCopyInCatDir:          rbtCopyInCatDir.Checked := True;
    mpoCopyInCatDirIfStored:  rbtCopyInCatDirIfStored.Checked := True;
    mpoCopyInPicDir:          rbtCopyInPicDir.Checked := True;
    mpoCopyInPicDirIfStored:  rbtCopyInPicDirIfStored.Checked := True;
    mpoDelete:                rbtDelete.Checked := True;
    else
      if FExportXML then
        rbtNoChangeXML.Checked := True
      else
        rbtNoChangeAMC.Checked := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TPictureOperationExportFrame.OperationEnabled(Operation: TMoviePictureOperation): Boolean;
begin
  case Operation of
    mpoStore:                 result := rbtStore.Enabled;
    mpoStoreIfCopied:         result := rbtStoreIfCopied.Enabled;
    mpoCopyInCatDir:          result := rbtCopyInCatDir.Enabled;
    mpoCopyInCatDirIfStored:  result := rbtCopyInCatDirIfStored.Enabled;
    mpoCopyInPicDir:          result := rbtCopyInPicDir.Enabled;
    mpoCopyInPicDirIfStored:  result := rbtCopyInPicDirIfStored.Enabled;
    mpoDelete:                result := rbtDelete.Enabled;
    mpoUndefined:             result := (rbtNoChangeAMC.Enabled and not FExportXML) or (rbtNoChangeXML.Enabled and FExportXML);
  else
    result := False;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureOperationExportFrame.EnableOperation(Operation: TMoviePictureOperation; Value: Boolean);
begin
  case Operation of
    mpoStore:                 rbtStore.Enabled := Value;
    mpoStoreIfCopied:         rbtStoreIfCopied.Enabled := Value;
    mpoCopyInCatDir:          rbtCopyInCatDir.Enabled := Value;
    mpoCopyInCatDirIfStored:  rbtCopyInCatDirIfStored.Enabled := Value;
    mpoCopyInPicDir:          rbtCopyInPicDir.Enabled := Value;
    mpoCopyInPicDirIfStored:  rbtCopyInPicDirIfStored.Enabled := Value;
    mpoDelete:                rbtDelete.Enabled := Value;
    else
      if FExportXML then
        rbtNoChangeXML.Enabled := Value
      else
        rbtNoChangeAMC.Enabled := Value;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
