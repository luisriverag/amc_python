(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2017 Antoine Potten, Mickaël Vanneufville                 *
 *   http://www.antp.be/software                                        *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 *   This file can be used freely in any program, even if it is not     *
 *   opensource or if it is commercial. It can be used only to provide  *
 *   compatibility with Ant Movie Catalog files, for importation for    *
 *   example. A mention to the origin of this code and eventually       *
 *   a link to Ant Movie Catalog website somewhere in the about box,    *
 *   help file or documentation would be appreciated.                   *
 *   Like for the GPL-licensed files, this file is distributed WITHOUT  *
 *   ANY WARRANTY.                                                      *
 *                                                                      *
 *   To compile fields.pas and movieclass.pas in any project,           *
 *   you have to define "DLLMode" either in project options or          *
 *   directly in these two files.                                       *
 *                                                                      *
 *   Alternatively, this can be used under GPL license:                 *
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

unit fields;

interface

uses
  Sysutils, Classes, Graphics;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  // Fields
  fieldLow                =  0;
  fieldNumber             =  0;
  fieldChecked            =  1;
  fieldColorTag           =  2;
  fieldMedia              =  3;
  fieldMediaType          =  4;
  fieldSource             =  5;
  fieldDate               =  6;
  fieldBorrower           =  7;
  fieldDateWatched        =  8;
  fieldUserRating         =  9;
  fieldRating             = 10;
  fieldOriginalTitle      = 11;
  fieldTranslatedTitle    = 12;
  fieldFormattedTitle     = 13;
  fieldDirector           = 14;
  fieldProducer           = 15;
  fieldWriter             = 16;
  fieldComposer           = 17;
  fieldActors             = 18;
  fieldCountry            = 19;
  fieldYear               = 20;
  fieldLength             = 21;
  fieldCategory           = 22;
  fieldCertification      = 23;
  fieldURL                = 24;
  fieldDescription        = 25;
  fieldComments           = 26;
  fieldFilePath           = 27;
  fieldVideoFormat        = 28;
  fieldVideoBitrate       = 29;
  fieldAudioFormat        = 30;
  fieldAudioBitrate       = 31;
  fieldResolution         = 32;
  fieldFrameRate          = 33;
  fieldLanguages          = 34;
  fieldSubtitles          = 35;
  fieldSize               = 36;
  fieldDisks              = 37;
  fieldPictureStatus      = 38;
  fieldNbExtras           = 39;
  fieldCount              = 40;

  // Extra fields
  extraFieldLow           = 80;
  extraFieldNumber        = 80;
  extraFieldChecked       = 81;
  extraFieldTag           = 82;
  extraFieldTitle         = 83;
  extraFieldCategory      = 84;
  extraFieldURL           = 85;
  extraFieldDescription   = 86;
  extraFieldComments      = 87;
  extraFieldCreatedBy     = 88;
  extraFieldPictureStatus = 89;
  extraFieldCount         = 90;

  // Picture
  fieldPicture            = 99;

  // Extra picture
  extraFieldPicture       = 100;

  // Custom fields
  customFieldLow          = 101;
  customFieldMax          = 255; // should be enough...

type
  // Fields, extra fields and custom fields
  TMovieField = fieldLow..customFieldMax;
  // Set of fields, extra fields and custom fields
  TMovieFields = set of TMovieField;

const
  AllFields: TMovieFields = [fieldLow..fieldCount-1];
  AllExtraFields: TMovieFields = [extraFieldLow..extraFieldCount-1];
  AllCustomFields: TMovieFields = [customFieldLow..customFieldMax];
  VirtualFields: TMovieFields = [fieldFormattedTitle, fieldPictureStatus,
    fieldNbExtras, extraFieldNumber, extraFieldPictureStatus];
  OrigonFields: TMovieFields = [fieldNumber, fieldMedia, fieldMediaType, fieldSource,
    fieldDate, fieldBorrower, fieldRating, fieldOriginalTitle, fieldTranslatedTitle,
    fieldDirector, fieldProducer, fieldCountry, fieldCategory, fieldYear, fieldLength,
    fieldActors, fieldURL, fieldDescription, fieldComments, fieldVideoFormat, fieldVideoBitrate,
    fieldAudioFormat, fieldAudioBitrate, fieldResolution, fieldFrameRate, fieldLanguages,
    fieldSubtitles, fieldSize, fieldDisks];

var
  GroupByFields: TMovieFields;
  GroupByFieldsMulti: TMovieFields;
  GroupByFieldsMultiDefaultRmP: TMovieFields;
  SortByFields: TMovieFields;

  GroupByExtraFields: TMovieFields;
  SortByExtraFields: TMovieFields;

const
  // Field and extra field tags used by application
  strTagFields: array [0..fieldCount-fieldLow-1] of string = (
    'Number',
    'Checked',
    'ColorTag',
    'MediaLabel',
    'MediaType',
    'Source',
    'Date',
    'Borrower',
    'DateWatched',
    'UserRating',
    'Rating',
    'OriginalTitle',
    'TranslatedTitle',
    'FormattedTitle',
    'Director',
    'Producer',
    'Writer',
    'Composer',
    'Actors',
    'Country',
    'Year',
    'Length',
    'Category',
    'Certification',
    'URL',
    'Description',
    'Comments',
    'FilePath',
    'VideoFormat',
    'VideoBitrate',
    'AudioFormat',
    'AudioBitrate',
    'Resolution',
    'Framerate',
    'Languages',
    'Subtitles',
    'Size',
    'Disks',
    'PictureStatus',
    'NbExtras'
  );
  strTagFieldPicture = 'Picture';

  strTagExtraFields: array [0..extraFieldCount-extraFieldLow-1] of string = (
    'ENumber',
    'EChecked',
    'ETag',
    'ETitle',
    'ECategory',
    'EURL',
    'EDescription',
    'EComments',
    'ECreatedBy',
    'EPictureStatus'
  );
  strTagExtraFieldPicture = 'EPicture';

{$IFNDEF DLLMode}
const
  // Field and extra field tags used to save SQL catalogs
  strTagSqlFields: array [0..fieldCount-fieldLow-1] of string = (
    'NUM',
    'CHECKED',
    'COLORTAG',
    'MEDIA',
    'MEDIATYPE',
    'SOURCE',
    'DATEADDED',
    'BORROWER',
    'DATEWATCHED',
    'USERRATING',
    'RATING',
    'ORIGINALTITLE',
    'TRANSLATEDTITLE',
    'FORMATTEDTITLE',
    'DIRECTOR',
    'PRODUCER',
    'WRITER',
    'COMPOSER',
    'ACTORS',
    'COUNTRY',
    'YEAR',
    'LENGTH',
    'CATEGORY',
    'CERTIFICATION',
    'URL',
    'DESCRIPTION',
    'COMMENTS',
    'FILEPATH',
    'VIDEOFORMAT',
    'VIDEOBITRATE',
    'AUDIOFORMAT',
    'AUDIOBITRATE',
    'RESOLUTION',
    'FRAMERATE',
    'LANGUAGES',
    'SUBTITLES',
    'FILESIZE',
    'DISKS',
    'PICTURESTATUS',
    'NBEXTRAS'
  );
  strTagSqlFieldPicture = 'PICTURENAME';

  strTagSqlExtraFields: array [0..extraFieldCount-extraFieldLow-1] of string = (
    'NUM',
    'CHECKED',
    'TAG',
    'TITLE',
    'CATEGORY',
    'URL',
    'DESCRIPTION',
    'COMMENTS',
    'CREATEDBY',
    'PICTURESTATUS'
  );
  strTagSqlExtraFieldPicture = 'PICTURENAME';
  strTagSqlExtraFieldRefMovieNumber = 'MOVIENUM';

var
  // Field names
  strFields: TStrings;
  strFieldPicture: string;
  // Extra field names
  strExtraFields: TStrings;
  strExtraFieldPicture: string;
  strExtras: string;
  // Picture status
  strPictureStatus: TStrings;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

{$IFNDEF DLLMode}
  uses Global;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

initialization
  GroupByFields := AllFields;// - [fieldURL, fieldDescription, fieldComments];
  GroupByFieldsMulti := [fieldMediaType, fieldSource,
    fieldDirector, fieldProducer, fieldWriter, fieldComposer, fieldActors,
    fieldCountry, fieldCategory, fieldCertification, fieldVideoFormat,
    fieldAudioFormat, fieldLanguages, fieldSubtitles];
  GroupByFieldsMultiDefaultRmP := [fieldActors];
  SortByFields := AllFields;

  GroupByExtraFields := AllExtraFields;
  SortByExtraFields := AllExtraFields;
end.






