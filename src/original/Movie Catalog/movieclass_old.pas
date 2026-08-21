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

unit movieclass_old;

interface

const
  DefaultDate = 693961; // 01/01/1901  used for "no date" in AMC_21

type
RMovie10 = record
  iNumber: integer;
  strOriginalTitle: string[64];
  strTranslatedTitle: string[64];
  strDirector: string[32];
  strProducer: string[32];
  strCountry: string[32];
  iYear: integer;
  strCategory: string[32];
  iLength: integer;
  strActors: string[128];
  strURL: string[128];
  strDescription: array[1..1024] of Char;
  strComments: string[128];
  strVideoFormat: string[32];
  strSize: string[32];
  strResolution: string[16];
  strLanguages: string[32];
  strSubtitles: string[32];
end;
RMovie11 = record
  iNumber: integer;
  strOriginalTitle: string[64];
  strTranslatedTitle: string[64];
  strDirector: string[32];
  strProducer: string[32];
  strCountry: string[32];
  iYear: integer;
  strCategory: string[32];
  iLength: integer;
  strActors: string[128];
  strURL: string[128];
  strDescription: array[1..1024] of Char;
  strComments: string[128];
  strVideoFormat: string[32];
  strSize: string[32];
  strResolution: string[16];
  strLanguages: string[32];
  strSubtitles: string[32];
  iRating: Integer;
end;
RMovie21 = record
  iNumber: integer;
  strOriginalTitle: string[64];
  strTranslatedTitle: string[64];
  strDirector: string[32];
  strProducer: string[32];
  strCountry: string[32];
  iYear: integer;
  strCategory: string[32];
  iLength: integer;
  strActors: string[128];
  strURL: string[128];
  strDescription: array[1..1024] of Char;
  strComments: string[128];
  strVideoFormat: string[32];
  strSize: string[32];
  strResolution: string[16];
  strLanguages: string[32];
  strSubtitles: string[32];
  iRating: Integer;
  bChecked: boolean;
  iDate: integer;
end;
RMovie30 = record
  iNumber: integer;
  strOriginalTitle: string[64];
  strTranslatedTitle: string[64];
  strDirector: string[32];
  strProducer: string[32];
  strCountry: string[32];
  iYear: integer;
  strCategory: string[32];
  iLength: integer;
  strActors: string[128];
  strURL: string[128];
  strDescription: array[1..1024] of Char;
  strComments: string[128];
  strVideoFormat: string[32];
  strSize: string[32];
  strResolution: string[16];
  strLanguages: string[32];
  strSubtitles: string[32];
  iRating: Integer;
  bChecked: boolean;
  iDate: integer;
  strPicture: string[4];
  iPictureSize: integer;
  strBorrower: string[32];
end;
RMovieProperties = record
  strOwnerName: string[64];
  strOwnerICQ: string[16];
  strOwnerSite: string[128];
  strOwnerMail: string[128];
end;

PMovie30 = ^RMovie30;
PMovie21 = ^RMovie21;
PMovie11 = ^RMovie11;
PMovie10 = ^RMovie10;

const
  strFileHeader10 = ' AMC_1.0 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ';
  strFileHeader11 = ' AMC_1.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ';
  strFileHeader21 = ' AMC_2.1 ANSYsoft Movie Catalog http://moviecatalog.ansysoft.com ';
  strFileHeader30 = ' AMC_3.0 Ant Movie Catalog www.buypin.com www.ant.be.tf/software ';

implementation

end.
