(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x Tools                                        *
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

unit datamodule;

interface

uses
  SysUtils, Classes, DB, ADODB,

  functions_str, MovieClass;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TDLLDataModule = class(TDataModule)
    ADOQuery: TADOQuery;
    ADOConn: TADOConnection;
  private
  public
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$R *.dfm}

const
  ConnectStringAccess = 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=%s;Mode=Read;Persist Security Info=False';

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
