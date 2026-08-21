(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2003-2006 Antoine Potten                                       *
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

unit FramePictureSelectionOptions;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, MovieClass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  // If you change this, don't forget to change TMoviePictureImport in movieclass!
  TPictureSelectOption = (psoUndefined = 0, psoStore = 1, psoCopyInCatDir = 2, psoLinkRel = 3, psoLinkAbs = 4, psoCopyInPicDir = 5);

  TPictureSelectOptionsFrame = class(TFrame)
    grp: TGroupBox;
    rbtStorePic: TRadioButton;
    rbtCopyPicInCatDir: TRadioButton;
    rbtLinkPic: TRadioButton;
    chkLinkRelative: TCheckBox;
    rbtCopyPicInPicDir: TRadioButton;
  private
    function GetSelected: TPictureSelectOption;
    procedure SetSelected(const Value: TPictureSelectOption);
  public
    property Selected: TPictureSelectOption read GetSelected write SetSelected;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

{-------------------------------------------------------------------------------
  TPictureSelectOptionsFrame
-------------------------------------------------------------------------------}

function TPictureSelectOptionsFrame.GetSelected: TPictureSelectOption;
begin
  if rbtCopyPicInCatDir.Checked then
    Result := psoCopyInCatDir
  else if rbtCopyPicInPicDir.Checked then
    Result := psoCopyInPicDir
  else if rbtLinkPic.Checked then
  begin
    if chkLinkRelative.Checked then
      Result := psoLinkRel
    else
      Result := psoLinkAbs
  end
  else
    Result := psoStore;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TPictureSelectOptionsFrame.SetSelected(const Value: TPictureSelectOption);
begin
  case Value of
    psoCopyInCatDir:  rbtCopyPicInCatDir.Checked := True;
    psoCopyInPicDir:  rbtCopyPicInPicDir.Checked := True;
    psoLinkRel,
    psoLinkAbs:       rbtLinkPic.Checked := True;
  else
    rbtStorePic.Checked := True;
  end;
  chkLinkRelative.Checked := Value <> psoLinkAbs;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
