(************************************************************************
 *                                                                      *
 *   (C) 2002-2013 Antoine Potten, Mickaël Vanneufville                 *
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

unit functions_html;

interface

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function HTMLDecode(const Value: string): string;
function HTMLRemoveTags(const Value: string): string;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  SysUtils,

  functions_str;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  Symbols: array [32..255] of string = (
                        'nbsp',   '',       'quot',   '',       '',       '',       'amp',    'apos',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    'lt',     '',       'gt',     '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       '',       '',
    '',       '',       '',       '',       '',       '',       '',       '',       'euro',   '',
    'sbquo',  'fnof',   'bdquo',  'hellip', 'dagger', 'Dagger', 'circ',   'permil', 'Scaron', 'lsaquo',
    'OElig',  '',       'Zcaron', '',       '',       'lsquo',  'rsquo',  'ldquo',  'rdquo',  'bull',
    'ndash',  'mdash',  'tilde',  'trade',  'scaron', 'rsaquo', 'oelig',  '',       'zcaron', 'Yuml',
    '',       'iexcl',  'cent',   'pound',  'curren', 'yen',    'brvbar', 'sect',   'uml',    'copy',
    'ordf',   'laquo',  'not',    'shy',    'reg',    'macr',   'deg',    'plusmn', 'sup2',   'sup3',
    'acute',  'micro',  'para',   'middot', 'cedil',  'sup1',   'ordm',   'raquo',  'frac14', 'frac12',
    'frac34', 'iquest', 'Agrave', 'Aacute', 'Acirc',  'Atilde', 'Auml',   'Aring',  'AElig',  'Ccedil',
    'Egrave', 'Eacute', 'Ecirc',  'Euml',   'Igrave', 'Iacute', 'Icirc',  'Iuml',   'ETH',    'Ntilde',
    'Ograve', 'Oacute', 'Ocirc',  'Otilde', 'Ouml',   'times',  'Oslash', 'Ugrave', 'Uacute', 'Ucirc',
    'Uuml',   'Yacute', 'THORN',  'szlig',  'agrave', 'aacute', 'acirc',  'atilde', 'auml',   'aring',
    'aelig',  'ccedil', 'egrave', 'eacute', 'ecirc',  'euml',   'igrave', 'iacute', 'icirc',  'iuml',
    'eth',    'ntilde', 'ograve', 'oacute', 'ocirc',  'otilde', 'ouml',   'divide', 'oslash', 'ugrave',
    'uacute', 'ucirc',  'uuml',   'yacute', 'thorn',  'yuml'
  );

  Unicodes: array [128..159] of string = (
                                                                                    '8364',   '',
    '8218',   '402',    '8222',   '8230',   '8224',   '8225',   '710',    '8240',   '352',    '8249',
    '338',    '',       '381',    '',       '',       '8216',   '8217',   '8220',   '8221',   '8226',
    '8211',   '8212',   '732',    '8482',   '353',    '8250',   '339',    '',       '382',    '376'
  );

function HTMLDecode(const Value: string): string;
var
  i, Max, p1, p2, idx: Integer;
  Code: Integer;
  Symbol: string;
  SymbolLength: Integer;
begin
  result := '';
  Max := Length(Value);
  i := 1;
  while i <= Max do
  begin
    if (Value[i] = '&') and (i + 1 < Max) then
    begin
      Symbol := copy(Value, i + 1, Max);
      p1 := Pos(' ', Symbol);
      p2 := Pos(';', Symbol);
      if (p2 > 0) and ((p2 < p1) xor (p1 = 0)) then
      begin
        Code := 0;
        Symbol := Copy(Symbol, 1, pos(';', Symbol) - 1);
        SymbolLength := Length(Symbol) + 1;
        if Symbol <> '' then
        begin
          if Symbol[1] <> '#' then
          begin
            idx := IndexStr(Symbol, Symbols);
            if idx <> -1 then
              Code := idx + 32;
          end else
          begin
            Delete(Symbol, 1, 1);
            Code := StrToIntDef(Symbol, 0);
            if Code > 255 then
            begin
              idx := IndexStr(Symbol, Unicodes);
              if idx <> -1 then
                Code := idx + 128
              else
                Code := 0;
            end;
          end;
        end;
        if Code <> 0 then
          result := result + char(Code);
        inc(i, SymbolLength);
      end else
        result := result + Value[i];
    end else
      result := result + Value[i];
    inc(i);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function HTMLRemoveTags(const Value: string): string;
var
  i, Max: Integer;
begin
  result := '';
  Max := Length(Value);
  i := 1;
  while i <= Max do
  begin
    if Value[i] = '<' then
    begin
      repeat
        inc(i);
      until (i > Max) or (Value[i-1] = '>');
    end else
    begin
      result := result + Value[i];
      inc(i);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
