(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 3.x                                              *
 *   (C) 2006 Antoine Potten                                            *
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

unit functions_tbx;

interface

uses
  SysUtils,

  TBXDkPanels,

  ConstValues, Global;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure LoadButtonIcon(AButton: TTBXButton; const AIndex: TIconIndex; const ClearCaption: Boolean = True);

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure LoadButtonIcon(AButton: TTBXButton; const AIndex: TIconIndex; const ClearCaption: Boolean = True);
begin
  if ClearCaption then
    AButton.Caption := '';
  AButton.ButtonStyle := bsFlat;
  AButton.Images := ToolbarImages;
  AButton.ImageIndex := Ord(AIndex);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
