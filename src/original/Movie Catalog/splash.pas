(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit splash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, jpeg, ExtCtrls;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TSplashWin = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    ProgressBar1: TProgressBar;
  private
  public
  end;

var
  SplashWin: TSplashWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
