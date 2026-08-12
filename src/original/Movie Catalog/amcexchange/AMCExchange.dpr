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

library amcexchange;

uses
  SysUtils,
  Classes,
  MovieClass in '..\movieclass.pas',
  ConstValues in '..\constvalues.pas',
  fields in '..\fields.pas',
  datamodule in 'datamodule.pas' {DLLDataModule: TDataModule},
  interfaces in '..\interfaces.pas',
  WrappedQuery in 'WrappedQuery.pas',
  ExpressionParser in '..\ExpressionParser.pas',
  movieclass_old in '..\movieclass_old.pas';

{$R *.res}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CreateAdoQuery: IWrappedQuery;
begin
  Result := TWrappedAdoQuery.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

function CreateMlbQuery: IWrappedQuery;
begin
  Result := TWrappedMlbQuery.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

exports
  CreateAdoQuery;
//  CreateMlbQuery,
//  ImportBDV,
//  ImportDivxMgr,
//  GetNextMovie;
begin
end.
