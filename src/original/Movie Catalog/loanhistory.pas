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

unit loanhistory;

interface

uses
  Classes, SysUtils;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type

  TLoanHistoryAction = (lhIn, lhOut);

  TLoanHistory = class(TObject)
  private
    FFile: TextFile;
    FCatalog: string;
  public
    procedure Add(const Borrower: string; const Number: Integer; const MediaLabel: string; const Title: string; Action: TLoanHistoryAction);
    constructor Create(const FileName: TFileName; const Catalog: string);
    destructor Destroy; override;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanHistory.Add(const Borrower: string; const Number: Integer; const MediaLabel: string; const Title: string; Action: TLoanHistoryAction);
var
  InOut: string;
begin
  try
    if Action = lhIn then
      InOut := 'In'
    else
      InOut := 'Out';
    WriteLn(FFile, Format('%1:s%0:s%2:s%0:s%3:s%0:s%4:d%0:s%5:s%0:s%6:s%0:s%7:s', [#9, FormatDateTime('yyyy/mm/dd hh:nn:ss', now), FCatalog, InOut, Number, MediaLabel, Title, Borrower]));
    Flush(FFile);
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TLoanHistory.Create(const FileName: TFileName; const Catalog: string);
begin
  FCatalog := Catalog;
  try
    AssignFile(FFile, FileName);
    if not FileExists(FileName) then
    begin
      Rewrite(FFile);
      WriteLn(FFile, Format('%1:s%0:s%2:s%0:s%3:s%0:s%4:s%0:s%5:s%0:s%6:s%0:s%7:s', [#9, 'Date & Time', 'Catalog', 'In/Out', 'Movie Number', 'MovieLabel', 'Movie Title', 'Borrower Name']));
      Flush(FFile);
    end;
    Append(FFile);
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TLoanHistory.Destroy;
begin
  try
    CloseFile(FFile);
  except
  end;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
