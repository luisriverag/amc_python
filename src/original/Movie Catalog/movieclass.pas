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

unit movieclass;

interface

uses
  Classes, Contnrs, SysUtils

  {$IFDEF MSWINDOWS}, Windows{$ENDIF}, Graphics{$IFNDEF DLLMode},

  JvSimpleXml, Dialogs, ExpressionParser,

  movieclass_old{$ENDIF}, Fields, Interfaces;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  intFileVersion           = 42;
  strClipboardMovieHeader  = 'MOVIE_AMC42';
  strClipboardExtrasHeader = 'EXTRAS_AMC42';

const
  DefaultColorsTag: array [0..12] of TColor =
    ( $FFFFFF, $241ced, $277fff, $00f2ff, $1de6b5, $4cb122, $eeee1c, $ffb040,
      $ff80a0, $e060ff, $e00ed0, $5786B9, $999999 );

type
  TMovieIncludeOption = (mioAll, mioSelected, mioChecked, mioVisible);
  TMovieDuplicateNumbers = (mdnIgnore, mdnSwap, mdnShift);
  TPictureIncludeOption = (pioAll, pioMovie, pioExtras);
  TFieldType = (ftString, ftInteger, ftReal1, ftReal2, ftReal, ftBoolean,
    ftDate, ftList, ftText, ftUrl, ftVirtual);

  TFormatValueFunction = function(const s: string): string;

  TCustomFieldProperties = class;
  TCustomFieldsProperties = class;
  TCustomFields = class;
  TMoviePicture = class;
  TMovieExtra = class;
  TMovieExtras = class;
  TMovie = class;
  TMovieList = class;

  TString = class(TObject)
  private
   Fstr: String;
  public
   constructor Create(const Astr: String);
   property str: String read Fstr write Fstr;
  end;

  TCustomFieldProperties = class(TObject)
  public
    CustomFieldsProperties: TCustomFieldsProperties; // ref
    FieldTag:               string;
    OldFieldTag:            string;
    FieldName:              string;
    FieldExt:               string;
    FieldType:              TFieldType;
    ListValues:             TStrings; // used for ftList type
    ListAutoAdd:            Boolean;
    ListSort:               Boolean;
    ListAutoComplete:       Boolean;
    ListUseCatalogValues:   Boolean;
    DefaultValue:           string;
    MediaInfo:              string;
    MultiValues:            Boolean;
    MultiValuesSep:         Char;
    MultiValuesRmP:         Boolean;
    MultiValuesPatch:       Boolean;
    ExcludedInScripts:      Boolean;
{$IFNDEF DLLMode}
    FieldObject: TObject; // ref on Component Field in FrameMovieCustom
{$ENDIF}
    GUIProperties: string;
    OtherProperties: string;

    constructor Create(Tag: string; CustomFieldsProperties: TCustomFieldsProperties); reintroduce;
    destructor Destroy; override;
    procedure InitValues;
    procedure Assign(CustomFieldProperties: TCustomFieldProperties;
      IncludeOldFieldTag: Boolean = True; IncludeFieldObject: Boolean = True;
      IncludeGUIProperties: Boolean = True);

    procedure WriteData(const OutputFile: TStream; const Version: Integer = 99);
    procedure ReadData(const InputFile: TStream; const Version: Integer = 99);
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string = ''; const Version: Integer = 99);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);
{$ENDIF}
  end;

  TCustomFieldsProperties = class(TStringList)
  private
    procedure SetItem(const idx: Integer; Value: TCustomFieldProperties);
    function GetItem(const idx: Integer): TCustomFieldProperties;
  public
    MovieList: TMovieList; // ref
    ColumnSettings: string;
    GUIProperties: string;
    OtherProperties: string;

    constructor Create(MovieList: TMovieList); reintroduce;
    destructor Destroy; override;

    property Objects[const idx: Integer]: TCustomFieldProperties read GetItem write SetItem; default;

    procedure Clear; override;
    procedure Assign(CustomFieldsProperties: TCustomFieldsProperties); reintroduce; overload;
    function GetField(Tag: string): TCustomFieldProperties;

    // SpecialAdd: Used to make difference between old field tag
    // and new field tag (even if old tag and new tag are same)
    // If SpecialAdd = True, CheckFieldTags and CheckFieldValues need to be call after all changes!
    function AddField(Tag: string; SpecialAdd: Boolean = False): TCustomFieldProperties;

    // Don't delete field value : call CheckFieldValues after all changes !
    function DeleteField(Tag: string): Boolean;

    // Don't change tag of fields value : call CheckFieldTags after all changes !
    function ChangeFieldTag(Tag: string; NewTag: string): Boolean;

    // Don't change fields value : call CheckFieldValues after all changes !
    function ChangeFieldType(Tag: string; NewType: TFieldType): Boolean;

    // Change tag of fields value according to properties : call it after all changes (BEFORE CheckFieldValues !) !
    procedure CheckFieldTags;

    // Convert/Delete old fields value : call it after all changes (AFTER CheckFieldTags) !
    procedure CheckFieldValues;

    // Rename no valid tags (already used by movie/extra fields or bad syntax)
    // to valid ones ('__' + current tag or '__' + a number)
    procedure RenameNoValidTags;

    procedure WriteData(const OutputFile: TStream; const Version: Integer = 99);
    procedure ReadData(const InputFile: TStream; const Version: Integer = 99);
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string; const Version: Integer = 99);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);

    procedure ExportToXML(const strFileName: string; const Version: Integer = 99);
    // CheckFieldTag and CheckFieldValue need to be call after imports if SpecialAdd = True!
    procedure Import(Properties: TCustomFieldsProperties; SpecialAdd: Boolean = False);
    procedure ImportFromXML(const strFileName: string; SpecialAdd: Boolean = False);
    procedure ImportFromAMC(const strFileName: string; SpecialAdd: Boolean = False);
{$ENDIF}
  end;

  TCustomFields = class(TStringList)
  private
    procedure SetItem(const idx: Integer; Value: TString);
    function GetItem(const idx: Integer): TString;
  public
    Properties: TCustomFieldsProperties; // ref
    Movie: TMovie; // ref
    constructor Create(Properties: TCustomFieldsProperties; Movie: TMovie); reintroduce;
    destructor Destroy; override;

    property Objects[const idx: Integer]: TString read GetItem write SetItem; default;

    procedure Clear; override;
    procedure Assign(CustomFields: TCustomFields); reintroduce; overload;

    procedure CheckFieldValues; // Check fields value according to fields properties
    procedure SetDefaultValues; // Set default field value according to fields properties

    function SetFieldValue(Tag, Value: string;
      AddMissingField: Boolean = True): Boolean;
    function GetFieldValue(Tag: string;
      const LocalFormatSettings: Boolean = False;
      const ReturnEmptyIfFalse : Boolean = False;
      const ReturnEmptyIfVirtual: Boolean = False): string;
    function GetIntFieldValue(Tag: string): Integer;
    function GetFloatFieldValue(Tag: string): Double;
    function DeleteFieldValue(Tag: string): Boolean;
    function GetFieldProperties(Tag: string): TCustomFieldProperties;
    function ChangeTag(Tag: string; NewTag: string): Boolean;

    procedure WriteData(const OutputFile: TStream; const Version: Integer = 99;
      const Standalone: Boolean = False);
    procedure ReadData(const InputFile: TStream; const Version: Integer = 99;
      const Standalone: Boolean = False);
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string = ''; const Version: Integer = 99);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);
{$ENDIF}
  end;

  TMoviePictureStatus = (mpsUndefined = 0, mpsStored = 1, mpsCopiedInCatDir = 2,
    mpsCopiedInPicDir = 3, mpsLinkRel = 4, mpsLinkAbs = 5, mpsNone = 6);
  TMoviePictureOperation = (mpoUndefined = 0, mpoStore = 1, mpoStoreIfCopied = 2,
    mpoCopyInCatDir = 3, mpoCopyInCatDirIfStored = 4, mpoCopyInCatDirIfCopied = 5,
    mpoCopyInPicDir = 6, mpoCopyInPicDirIfStored = 7, mpoCopyInPicDirIfCopied = 8,
    mpoRenameIfCopied = 9, mpoAbsToRelLink = 10, mpoRelToAbsLink = 11,
    mpoDelete = 12, mpoDeleteWithLinkedFile = 13, mpoDeleteIfStored = 14,
    mpoDeleteIfCopied = 15, mpoConvertIfStoredOrCopied = 16, mpoConvert = 17);
  // If you change this, don't forget to change TPictureSelectOption in FramePictureSelectionOptions!
  TMoviePictureImport = (mpiUndefined = 0, mpiStore = 1, mpiCopyInCatDir = 2,
    mpiLinkRel = 3, mpiLinkAbs = 4, mpiCopyInPicDir = 5);

  TMoviePicture = class(TObject)
  private
{$IFNDEF DLLMode}
    mutex: Cardinal;
{$ENDIF}
  public
    Movie: TMovie; // ref
    Extra: TMovieExtra; //ref
    PicPath: string;
    PicStream: TMemoryStream;
{$IFNDEF DLLMode}
    _thumb: TMemoryStream;
    _thumbError: Word;
    _thumbWidth: Word;
    _thumbHeight: Word;
{$ENDIF}

    constructor Create(Movie: TMovie; Extra: TMovieExtra); reintroduce;
    destructor Destroy; override;

    procedure Init;
    procedure Assign(APicture: TMoviePicture);

{$IFNDEF DLLMode}
    procedure Lock();
    function LockWait(msTime: Integer): boolean;
    procedure Unlock();
{$ENDIF}

    function GetPictureStatus(CatalogFile: TFileName): TMoviePictureStatus;
    procedure PictureOperation(const CatalogFile: TFileName;
      const Operation: TMoviePictureOperation;
      const OriginalPictureName: TFileName = ''; {for copy from stream}
      const MaxWidth: Integer = -1; const MaxHeight: Integer = -1 {for conversion and resizing});
    function ImportPicture(const AFileName: TFileName;
      const CatalogFile: TFileName; const ImportMethod: TMoviePictureImport): Boolean;
    function ImportPictureFromStream(const AStream: TStream; const DefaultExt: string;
      const CatalogFile: TFileName; const ImportMethod: TMoviePictureImport;
      const OriginalPictureName: TFileName = '' {for copy from stream}): Boolean;
    function GeneratePictureName(const CatalogFile: TFileName;
      const PictureExt: string; const OriginalPictureName: string;
      const PicDirWithSlash: string = '';
      const MakeAUniqueFilename: Boolean = True): string;
    function GetPictureCaption: string;
    function GetPictureSize(const CatalogFile: TFileName): Int64;
{$IFNDEF DLLMode}
    procedure GetPictureDimensions(const CatalogFile: TFileName;
      var Width: Integer; var Height: Integer);
    function GetPictureWidth(const CatalogFile: TFileName): Integer;
    function GetPictureHeight(const CatalogFile: TFileName): Integer;
    function ConvertPicture(const CatalogFile: TFileName;
      MaxWidth: Integer = -1; MaxHeight: Integer = -1;
      OnlyIfStoredOrCopied: Boolean = True): Boolean;
{$ENDIF}

    procedure SavePicture(const CatalogFileSrc: TFileName;
      const CatalogFileDst: TFileName; PicOperation: TMoviePictureOperation);
    procedure WriteData(const OutputFile: TStream;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure ReadData(const InputFile: TStream;
      const Version: Integer = 99;
      const LoadStoredPicture: Boolean = True);
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);
{$ENDIF}
  end;

{$IFNDEF DLLMode}
  TMovieExtraStatus = (mesNormal = 0, mesAdded = 1, mesDeleted = 2, mesModified = 3,
                       mesCancelAdded = 4, mesCancelDeleted = 5, mesCancelModified = 6);
{$ENDIF}
  TMovieExtra = class(TObject)
  public
    Extras:           TMovieExtras; // ref
    iNumber:          Integer; // Index of extra in extras list (Virtual field)
    bChecked:         Boolean;
    strTag:           string;
    strTitle:         string;
    strCategory:      string;
    strURL:           string;
    strDescription:   string;
    strComments:      string;
    strCreatedBy:     string; // Used by scripts to know who created the extra
    Picture:          TMoviePicture;
    {$IFNDEF DLLMode}
    _bSelected:       Boolean; // Extra selected or not
    _linkedExtra:     TMovieExtra; // Ref to another extra (e.g. copy of this extra)
    _iStatus:         TMovieExtraStatus; // 0 -> Normal, 1 -> Added, 2 -> Modified, 3 -> Deleted
    {$ENDIF}

    constructor Create(Extras: TMovieExtras); reintroduce;
    destructor Destroy; override;
    procedure InitFields;
    procedure Assign(Extra: TMovieExtra; IncludeTag: Boolean = True;
      IncludePicture: Boolean = True; IncludeListValues: Boolean = True); reintroduce; overload;

    function  GetFieldValue(const FieldID: TMovieField;
      const LocalFormatSettings: Boolean = False;
      const ReturnEmptyIfFalse : Boolean = False;
      const ReturnEmptyIfVirtual: Boolean = False): string;
    function GetIntFieldValue(const FieldID: TMovieField): Integer;
    procedure SetFieldValue(const FieldID: TMovieField; const Value: string);

    function InCategory(Category: string
      {$IFDEF DLLMode}; const CategorySep: Char = ',';
      const CategoryRemoveParenthesis: Boolean = False{$ENDIF}): Boolean;

    procedure WriteData(const OutputFile: TStream;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure ReadData(const InputFile: TStream;
      const Version: Integer = 99;
      const LoadStoredPicture: Boolean = True);

{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);
{$ENDIF}
  end;

  TMovieExtras = class(TObjectList)
  private
    procedure SetExtra(const idx: Integer; Value: TMovieExtra);
    function GetExtra(const idx: Integer): TMovieExtra;
  public
    Movie: TMovie; // ref

    constructor Create(Movie: TMovie); reintroduce;
    destructor Destroy; override;

    property Items[const idx: Integer]: TMovieExtra read GetExtra write SetExtra; default;

    procedure RenumberExtras(StartIndex: Integer = 0);
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
    procedure Move(CurIndex, NewIndex: Integer);
    procedure Sort(Compare: TListSortCompare); overload;

    procedure Assign(Extras: TMovieExtras); reintroduce; overload;
    function AddExtra: Integer;
    function DeleteExtras(const Category: string): Boolean;
    function FindExtra(Tag: string): Integer;
    function FindExtraAdv(Position: Integer;
      Category: string = ''; Checked: string = ''
      {$IFDEF DLLMode}; const CategorySep: Char = ',';
      const CategoryRemoveParenthesis: Boolean = False{$ENDIF}): Integer;
    procedure DeletePictures(const CatalogFile: string);

    function GetFieldValues(const FieldID: TMovieField;
      const Separator: string = '<+>';
      const LocalFormatSettings: Boolean = False;
      const ReturnEmptyIfFalse : Boolean = False;
      const ReturnEmptyIfVirtual: Boolean = False): string;
    function GetPictureValues(const Separator: string = '<+>';
      const StoredPictureText: string = '<Picture>';
      const OnlyFileName: Boolean = False): string;
    procedure SetFieldValues(const FieldID: TMovieField; Values: string;
      const Separator: string = '<+>'; Start: Integer = 0;
      const AllowClears: Boolean = True;
      const AddMissingExtra: Boolean = True
      {$IFNDEF DLLMode};
      const SetStatusAdded: Boolean = False;
      const ImportDefaultPicture: Boolean = True
      {$ENDIF});

    procedure WriteData(const OutputFile: TStream;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure ReadData(const InputFile: TStream;
      const Version: Integer = 99;
      const LoadStoredPicture: Boolean = True);

{$IFDEF MSWINDOWS}
    function SaveToMemory: THandle;
    class procedure FreeMemory(DataHandle: THandle; OnlyUnlock: Boolean = False);
    procedure LoadFromMemory(DataHandle: THandle);
{$ENDIF}
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);

    function GetExtrasByGroups(Field: Integer; OnlyGroups: Boolean = False): TStringList;
    procedure Sort(const FieldsList: TStrings; Force: Boolean = False); overload;
    procedure SortReverse(const FieldsList: TStrings; Force: Boolean = False); overload;
{$ENDIF}
    procedure Sort(const Field: Integer; Force: Boolean = False); overload;
    procedure SortReverse(const Field: Integer; Force : Boolean = False); overload;
  end;

  TMovie = class(TInterfacedObject, IMovie)
  public
    MovieList: TMovieList; // Ref
    iNumber: Integer;
    bChecked: Boolean;
    iColorTag: Integer;
    strMedia: string;
    strMediaType: string;
    strSource: string;
    iDate: integer;
    strBorrower: string;
    iDateWatched: integer;
    iUserRating: Integer;
    iRating: Integer;
    strOriginalTitle: string;
    strTranslatedTitle: string;
    strDirector: string;
    strProducer: string;
    strWriter: string;
    strComposer: string;
    strActors: string;
    strCountry: string;
    iYear: Integer;
    iLength: Integer;
    strCategory: string;
    strCertification: string;
    strURL: string;
    strDescription: string;
    strComments: string;
    strFilePath: string;
    strVideoFormat: string;
    iVideoBitrate: Integer;
    strAudioFormat: string;
    iAudioBitrate: Integer;
    strResolution: string;
    strFramerate: string;
    strLanguages: string;
    strSubtitles: string;
    strSize: string;
    iDisks: Integer;
    Picture: TMoviePicture;
    Extras: TMovieExtras;
    CustomFields: TCustomFields;
{$IFNDEF DLLMode}
    _listItems: TObjectList; // List of TElTreeItem associated to the movie (Updated in RefreshMovieList)
    _bSelected: Boolean; // Movie selected or not (Updated in StoreStates/LoadStates)
    _bVisible: Boolean; // Movie visible or not(Updated in StoreStates/LoadStates)
    _selectedGroup: string; // Group where movie is selected (Updated in StoreStates/LoadStates)
    _selectedItem: TObject; // TElTreeItem selected (Updated in StoreStates/LoadStates and MovieList events)
{$ENDIF}

    constructor Create(MovieList: TMovieList);
    destructor  Destroy; override;

    procedure InitFields;
    procedure Assign(AMovie: TMovie; IncludeNumber: Boolean = True;
      IncludePicture: Boolean = True; IncludeExtras: Boolean = True;
      IncludeCustomFields: Boolean = True; IncludeListValues: Boolean = True);
    function  GetFieldValue(const FieldID: TMovieField;
      const LocalFormatSettings: Boolean = False;
      const ReturnEmptyIfFalse : Boolean = False;
      const ReturnEmptyIfVirtual: Boolean = False): string;
    function  GetIntFieldValue(const FieldID: TMovieField): Integer;
    function  GetFloatFieldValue(const FieldID: TMovieField): Double;
    procedure SetFieldValue(const FieldID: TMovieField; const Value: string);
    function  GetFormattedTitle: string; overload;
{$IFNDEF DLLMode}
    function  GetFormattedTitle(DisplayType: Integer; const UsePrefixes: Boolean;
      const TitleTemplate: string = ''): string; overload;
    procedure GetFields(MovieFields: PMovie30);
    procedure SetFields(MovieFields: PMovie30);
{$ENDIF}
    function GetValueFromTemplate(const Template: string;
      const TitlePrefixes: TStringList = nil;
      const LocalFormatSettings: Boolean = False;
      const FormatValueFunction: TFormatValueFunction = nil): string;
    function CalcTotalSize: Int64;
    function ContainsText(const Value: string; const Field: Integer;
      const WholeField: Boolean): Boolean;

    function CanInclude(const IncOpt: TMovieIncludeOption): Boolean;
    procedure CheckURLFields(const CatalogFileSrc: TFileName;
      const CatalogFileDst: TFileName) ;
    procedure WriteData(const OutputFile: TStream;
      const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const Standalone: Boolean = False;
      const PicOperation: TMoviePictureOperation = mpoUndefined;
      const ExtraPicOperation: TMoviePictureOperation = mpoUndefined);
    procedure ReadData(const InputFile: TStream;
      const Version: Integer = 99;
      const Standalone: Boolean = False;
      const LoadStoredPicture: Boolean = True);
{$IFDEF MSWINDOWS}
    function  SaveToMemory: THandle;
    class procedure FreeMemory(DataHandle: THandle; OnlyUnlock: Boolean = False);
    procedure LoadFromMemory(DataHandle: THandle);
{$ENDIF}
{$IFNDEF DLLMode}
    procedure SaveToXML(Root: TJvSimpleXmlElem;
      const CatalogFileSrc: string; const CatalogFileDst: string; const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined;
      const ExtraPicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer = 99);
{$ENDIF}
  end;

  TMovieProperties = class(TObject)
  public
    strEncoding: string;
    strName: string;
    strMail: string;
    strSite: string;
    strDescription: string;
    constructor Create;
    procedure InitFields;
    procedure Assign(MovieProperties: TMovieProperties);
  end;

  TRoundType = (rtDown = 0, rtNearest = 1, rtUp = 2);

{$IFNDEF DLLMode}
  TMovieFilter = class(TObject)
  public
    Field: Integer; // -1 = AllFields ; Not used if SearchExpression <> NULL
    Value: string; // Not used if SearchExpression <> NULL
    WholeField: Boolean; // Not used if SearchExpression <> NULL
    Reverse: Boolean;
    SearchExpression: TExpression; // SearchExpression <> NULL = Advanced
    constructor Create; reintroduce;
    destructor Destroy; override;
    function Match(Movie: TMovie): Boolean;
  end;

  TExprVarMovieParser = class(TExprVarParser)
  private
    MovieList: TMovieList;
  public
    constructor Create(MovieList: TMovieList); reintroduce;
    destructor Destroy; override;
    function IsVar(Expression: string): Boolean; override;
    function GetVarId(Expression: string): string; override;
    function GetVarValue(VarId: string; VarObject: TObject): string; override;
    function GetVarType(VarId: string; VarObject: TObject): TExprType; override;
  end;

  TGroupFormatOption = (gfoUndefined = 0, gfoGetFirstLetter = 1,
    gfoGetTwoFirstLetters = 2, gfoGetThreeFirstLetters = 3,
    gfoGetFourFirstLetters = 4, gfoGetFiveFirstLetters = 5,
    gfoGetDateYear = 6, gfoGetDateYearAndMonth = 7,
    gfoRoundNumberToThousandth = 8, gfoRoundNumberToHundredth = 9,
    gfoRoundNumberToTenth = 10, gfoRoundNumberToUnit = 11,
    gfoRoundNumberToTen = 12, gfoRoundNumberToHundred = 13,
    gfoRoundNumberToThousand = 14);
  TGroupFormat = class(TObject)
  public
    option: TGroupFormatOption;
    roundType: TRoundType;
    function Format(GroupName: string): string;
  end;
{$ENDIF}

  TMovieList = class(TInterfacedObjectList, IMovieList)
  private
    procedure ReadData(InputFile: TFileStream; const Version: integer;
      OnlyReadProperties: Boolean = False; LoadStoredPictures: Boolean = True);
{$IFNDEF DLLMode}
    procedure ReadRecords(InputFile: TFileStream; const RecordSize: longint;
      const Version: integer; OnlyReadProperties: Boolean = False; LoadStoredPictures: Boolean = True);
    procedure ReadPictures(const strFilename: string);
    procedure ReadBorrowers(const strFilename: string);
{$ENDIF}
    function GetItem(const idx: Integer): TMovie;
    function GetItem2(const idx: Integer): IMovie;
    procedure SetItem(const idx: Integer; const Value: TMovie);
  public
    CurrentCatalogFile: string;
    SavingCatalog: Boolean; // Used to know if we are saving movies to catalog
    MovieProperties: TMovieProperties;
    CustomFieldsProperties: TCustomFieldsProperties;

{$IFNDEF DLLMode}
    _extraGroups: TStringList; // Store in list if extra group names are expanded (1) or collapsed (0)
{$ENDIF}

    constructor Create(AOwnsObjects: Boolean = True); reintroduce; overload;
    destructor Destroy; override;
    function Find(const MovieNumber: Integer): TMovie;
    procedure SaveToFile(const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const PicOperation: TMoviePictureOperation = mpoUndefined;
      const ExtraPicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromFile(const AFileName: string;
      OnlyReadProperties: Boolean = False; LoadStoredPictures: Boolean = True);
    class function ReadHeader(const AFileName: TFileName; out TheHeader: string): Int64;
{$IFNDEF DLLMode}
    procedure SaveToXML(const CatalogFileSrc: string; const CatalogFileDst: string;
      const Version: Integer = 99;
      const OnlyWriteProperties: Boolean = False;
      const PicOperation: TMoviePictureOperation = mpoUndefined;
      const ExtraPicOperation: TMoviePictureOperation = mpoUndefined);
    procedure LoadFromXML(const AFileName: string; OnlyReadProperties: Boolean = False);
    function GetMoviesByGroups(Field: Integer; const IncOpt: TMovieIncludeOption = mioALL;
      const MovieFilter : TMovieFilter = nil; const GroupFormat : TGroupFormat = nil): TStringList;
    procedure Sort(const FieldsList: TStrings; Force: Boolean = False); overload;
    procedure SortReverse(const FieldsList: TStrings; Force: Boolean = False); overload;
{$ENDIF}
    procedure Sort(const Field: Integer; Force: Boolean = False); overload;
    procedure SortReverse(const Field: Integer; Force: Boolean = False); overload;
    procedure Add(const AMovieList: TMovieList; const AllowDuplicateNumbers: Boolean); overload;
    function Add: TMovie; overload;
    function Add2: IMovie; overload;
    function MaxNumber(ListIsSorted: Boolean = False): Integer;
    function FirstFreeNumber(ListIsSorted: Boolean = False): Integer;
    function HasImages(IncludeStored, IncludeLinksRel, IncludeLinksAbs: Boolean): Boolean;
    function HasExtras: Boolean;
    procedure GetValues(AList: TStrings; Field: Integer);
    procedure GetCustomValues(AList: TStrings; Field: string);
    procedure GetExtrasValues(AList: TStrings; Field: Integer);
    function Count: Integer; overload;
    function Count(const IncOpt: TMovieIncludeOption): Integer; overload;
    procedure Count(out cAll, cSelected, cChecked, cVisible: Integer); overload;
    function Count(const MovieNumber: Integer): Integer; overload;
    procedure MakeFilteredList(AList: TList; const IncOpt: TMovieIncludeOption);
    procedure ShiftNumbers(const StartAt: Integer; const Exclude: TMovie);
    property Items[const idx: Integer]: TMovie read GetItem write SetItem; default;

    function CountPictures(const IncPicOpt: TPictureIncludeOption;
      const IncMovieOpt: TMovieIncludeOption = mioAll): Integer; overload;
    procedure CountPictures(out cAll, cMovie, cExtras: Integer;
      const IncMovieOpt: TMovieIncludeOption = mioAll); overload;
    function CountPictures(const MoviePicture: string): Integer; overload;
    procedure RenamePictures(const OldPath: string; const NewPath: string;
      AfterPicture: TMoviePicture = nil);
  end;

procedure FreeObjects(const strings: TStrings);
function GetMultiValues(const MultiValues: string; const Sep: Char = ',';
  const RemoveParenthesis: Boolean = False;
  const ErrorParenthesisValue: string = '< ?()? >';
  const UsePatch: Boolean = False): TStringList;
function GetMultiValuesSimple(MultiValues: string; const Separator: string): TStringList;
// GetFieldType return the real field type, it does not return ftVirtual
// for virtual fields as fieldNbExtras, use set of VirtualFields to know this!
function GetFieldType(field: Integer): TFieldType;
function ConvertFieldValue(Value: string; FieldType: TFieldType;
  const LocalFormatSettings: Boolean = False;
  const ExtraDateValue: Boolean = False;
  const ReturnEmptyIfFalse : Boolean = True): string;
function ConvertFieldTypeFromString(Value: string): TFieldType;
function ConvertFieldTypeToString(Value: TFieldType): string;
{$IFNDEF DLLMode}
function ConvertFieldTypeFromSQL(Value: string): TFieldType;
function ConvertFieldTypeToSQL(Value: TFieldType): string;
function ConvertColorToHTML(Color: TColor): string;
function ConvertColorFromHTML(Color: string; DefaultColor: TColor = $000000): TColor;
{$ENDIF}
function PrefixValue(const AValue: string; const Prefixes: TStringList): string;
function RoundUpTo(AValue: Double; ADigit: Integer = 0): Double;
function RoundDownTo(AValue: Double; ADigit: Integer = 0): Double;
function RoundNearestTo(AValue: Double; ADigit: Integer = 0): Double;
function RoundTo(AValue: Double; ADigit: Integer = 0; RoundType: TRoundType = rtNearest): Double;
function IsValidTag(const s: string): Boolean;
function GetCatalogPicDir(CatalogFile: TFileName; CreateIfNotExists: Boolean = False): string;
procedure RemoveCatalogPicDirIfEmpty(CatalogFile: TFileName);
procedure CompareStdInit(Field: Integer; Force: Boolean = False);
function CompareStd(Item1, Item2: Pointer): Integer;
function CompareStdReverse(Item1, Item2: Pointer): Integer;
procedure CompareExtrasStdInit(Field: Integer; Force: Boolean = False);
function CompareExtrasStd(Item1, Item2: Pointer): Integer;
function CompareExtrasStdReverse(Item1, Item2: Pointer): Integer;
{$IFNDEF DLLMode}
procedure CompareAdvInit(FieldsList: TStrings; Force: Boolean = False);
function CompareAdv(Item1, Item2: Pointer): Integer;
function CompareAdvReverse(Item1, Item2: Pointer): Integer;
procedure CompareExtrasAdvInit(FieldsList: TStrings; Force: Boolean = False);
function CompareExtrasAdv(Item1, Item2: Pointer): Integer;
function CompareExtrasAdvReverse(Item1, Item2: Pointer): Integer;
{$ENDIF}

procedure WriteString(const str: string; OutputFile: TStream);
function ReadString(InputFile: TStream): string;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  ClipboardMovieFormat: WORD;
  ClipboardExtrasFormat: WORD;
  FormatSettings: TFormatSettings;
{$IFDEF DLLMode}
  NaturalCompare: Boolean;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  IniFiles, DateUtils, Math, StrUtils, functions_str, functions_files
  {$IFNDEF DLLMode}, ConstValues, Global, functions_xml, ProgramSettings,
  JPEG, functions_img{$ENDIF};

{$IFDEF DLLMode}
const
  defaultSep = ',';
{$ENDIF}

const
  IntSize = SizeOf(Integer);
  BoolSize = SizeOf(Boolean);

const
  strErrorSave = 'Unable to save file "%s": ';
  strErrorLoad = 'Unable to load file "%s": ';
  strErrorHeader = 'Bad header';
  strUnableToIdentify = 'Cannot identify file type from header';
  strNoMovieFound = 'No catalog found in this file';

  strFileHeader   = ' AMC_?.? Ant Movie Catalog         www.buypin.com  www.ant.be.tf ';
  strFileHeader31 = ' AMC_3.1 Ant Movie Catalog 3.1.x   www.buypin.com  www.ant.be.tf ';
  strFileHeader33 = ' AMC_3.3 Ant Movie Catalog 3.3.x   www.buypin.com  www.ant.be.tf ';
  strFileHeader35 = ' AMC_3.5 Ant Movie Catalog 3.5.x   www.buypin.com    www.antp.be ';
  strFileHeader40 = ' AMC_4.0 Ant Movie Catalog 4.0.x   antp/soulsnake    www.antp.be ';
  strFileHeader41 = ' AMC_4.1 Ant Movie Catalog 4.1.x   antp/soulsnake    www.antp.be ';
  strFileHeader42 = ' AMC_4.2 Ant Movie Catalog 4.2.x   antp/soulsnake    www.antp.be ';

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
{$IFNDEF DLLMode}
  SortFieldsList: TStringList;
  SortFieldsIndex: Integer;
  SortExtraFieldsList: TStringList;
  SortExtraFieldsIndex: Integer;
{$ENDIF}
  SortField: Integer;
  SortForce: Boolean;
  SortExtraField: Integer;
  SortExtraForce: Boolean;

{-------------------------------------------------------------------------------
  TString
-------------------------------------------------------------------------------}

constructor TString.Create(const Astr: string) ;
begin
   inherited Create;
   Fstr := Astr;
end;

{-------------------------------------------------------------------------------
  TCustomFieldProperties
-------------------------------------------------------------------------------}

constructor TCustomFieldProperties.Create(Tag: string; CustomFieldsProperties: TCustomFieldsProperties);
begin
  inherited Create;
  Self.CustomFieldsProperties := CustomFieldsProperties;
  ListValues := TStringList.Create;
  FieldTag := Tag;
  OldFieldTag := '';
  InitValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TCustomFieldProperties.Destroy;
begin
  ListValues.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldProperties.InitValues;
begin
  FieldName := FieldTag;
  FieldExt := '';
  FieldType := ftString;
  DefaultValue := '';
  MediaInfo := '';
  ListValues.Clear;
  ListAutoAdd := False;
  ListSort  := False;
  ListAutoComplete := False;
  ListUseCatalogValues := False;
  MultiValues := False;
  MultiValuesSep := defaultSep;
  MultiValuesRmP := False;
  MultiValuesPatch := False;
  ExcludedInScripts := False;
{$IFNDEF DLLMode}
  FieldObject := nil;
{$ENDIF}
  GUIProperties := '';
  OtherProperties := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldProperties.Assign(CustomFieldProperties: TCustomFieldProperties;
  IncludeOldFieldTag: Boolean; IncludeFieldObject: Boolean; IncludeGUIProperties: Boolean);
begin
  FieldTag := CustomFieldProperties.FieldTag;
  if IncludeOldFieldTag then
    OldFieldTag := CustomFieldProperties.OldFieldTag;
  FieldName := CustomFieldProperties.FieldName;
  FieldExt := CustomFieldProperties.FieldExt;
  FieldType := CustomFieldProperties.FieldType;
  ListValues.Assign(CustomFieldProperties.ListValues);
  ListAutoAdd := CustomFieldProperties.ListAutoAdd;
  ListSort := CustomFieldProperties.ListSort;
  ListAutoComplete := CustomFieldProperties.ListAutoComplete;
  ListUseCatalogValues := CustomFieldProperties.ListUseCatalogValues;
  DefaultValue := CustomFieldProperties.DefaultValue;
  MediaInfo := CustomFieldProperties.MediaInfo;
  MultiValues := CustomFieldProperties.MultiValues;
  MultiValuesSep := CustomFieldProperties.MultiValuesSep;
  MultiValuesRmP := CustomFieldProperties.MultiValuesRmP;
  MultiValuesPatch := CustomFieldProperties.MultiValuesPatch;
  ExcludedInScripts := CustomFieldProperties.ExcludedInScripts;
{$IFNDEF DLLMode}
  if IncludeFieldObject then
    FieldObject := CustomFieldProperties.FieldObject;
{$ENDIF}
  if IncludeGUIProperties then
    GUIProperties := CustomFieldProperties.GUIProperties;
  OtherProperties := CustomFieldProperties.OtherProperties;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldProperties.WriteData(const OutputFile: TStream;
  const Version: Integer);
var
  i,j: Integer;
begin
  WriteString(FieldName, OutputFile);
  if Version >= 41 then
    WriteString(FieldExt, OutputFile);
  WriteString(ConvertFieldTypeToString(FieldType), OutputFile);
  WriteString(ConvertFieldValue(DefaultValue, FieldType, False, True), OutputFile);
  if Version >= 41 then
    WriteString(MediaInfo, OutputFile);
  OutputFile.WriteBuffer(MultiValues, boolsize);
  if Version >= 41 then
  begin
    OutputFile.WriteBuffer(MultiValuesSep, intsize);
    OutputFile.WriteBuffer(MultiValuesRmp, boolsize);
    OutputFile.WriteBuffer(MultiValuesPatch, boolsize);
  end;
  OutputFile.WriteBuffer(ExcludedInScripts, boolsize);
  WriteString(GUIProperties, OutputFile);
  //WriteString(OtherProperties, OutputFile);

  // ListValues
  if FieldType = ftList then
  begin
    j := ListValues.Count;
    OutputFile.WriteBuffer(j, intsize);
    for i := 0 to ListValues.Count-1 do
      WriteString(ListValues.Strings[i], OutputFile);
    if Version >= 41 then
    begin
      OutputFile.WriteBuffer(ListAutoAdd, boolsize);
      OutputFile.WriteBuffer(ListSort, boolsize);
      OutputFile.WriteBuffer(ListAutoComplete, boolsize);
      OutputFile.WriteBuffer(ListUseCatalogValues, boolsize);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldProperties.ReadData(const InputFile: TStream;
  const Version: Integer);
var
  i,j: Integer;
begin
  FieldName := ReadString(InputFile);
  if Version >= 41 then
    FieldExt := ReadString(InputFile);
  FieldType := ConvertFieldTypeFromString(ReadString(InputFile));
  DefaultValue := ConvertFieldValue(ReadString(InputFile), FieldType, False, True);
  if Version >= 41 then
    MediaInfo := ReadString(InputFile);
  InputFile.ReadBuffer(MultiValues, boolsize);
  if Version >= 41 then
  begin
    InputFile.ReadBuffer(MultiValuesSep, intsize);
    InputFile.ReadBuffer(MultiValuesRmp, boolsize);
    InputFile.ReadBuffer(MultiValuesPatch, boolsize);
  end;
  if MultiValuesSep = #0 then MultiValuesSep := defaultSep;
  InputFile.ReadBuffer(ExcludedInScripts, boolsize);
  GUIProperties := ReadString(InputFile);
  //OtherProperties := ReadString(InputFile);

  // ListValues
  if FieldType = ftList then
  begin
    InputFile.ReadBuffer(j, intsize);
    for i := 0 to j-1 do
      ListValues.Add(ReadString(InputFile));
    if Version >= 41 then
    begin
      InputFile.ReadBuffer(ListAutoAdd, boolsize);
      InputFile.ReadBuffer(ListSort, boolsize);
      InputFile.ReadBuffer(ListAutoComplete, boolsize);
      InputFile.ReadBuffer(ListUseCatalogValues, boolsize);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{$IFNDEF DLLMode}
procedure TCustomFieldProperties.SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string; const Version: Integer);
var
  i: Integer;
  Elem: TJvSimpleXmlElem;
begin
  if (Root = nil) then
    Exit;

  AddNotEmpty(Root.Properties, 'Name', FieldName);
  AddNotEmpty(Root.Properties, 'Ext', FieldExt);
  AddNotEmpty(Root.Properties, 'Type', ConvertFieldTypeToString(FieldType));
  AddNotEmpty(Root.Properties, 'DefaultValue', ConvertFieldValue(DefaultValue, FieldType, False, True));
  AddNotEmpty(Root.Properties, 'MediaInfo', MediaInfo);
  AddNotEmpty(Root.Properties, 'MultiValues', IfThen(MultiValues, 'True', ''));
  AddNotEmpty(Root.Properties, 'MultiValuesSep', IfThen((MultiValuesSep = defaultSep) or (MultiValuesSep = '#0'), '', MultiValuesSep));
  AddNotEmpty(Root.Properties, 'MultiValuesRmP', IfThen(MultiValuesRmP, 'True', ''));
  AddNotEmpty(Root.Properties, 'MultiValuesPatch', IfThen(MultiValuesPatch, 'True', ''));
  AddNotEmpty(Root.Properties, 'ExcludedInScripts', IfThen(ExcludedInScripts, 'True', ''));
  AddNotEmpty(Root.Properties, 'GUIProperties', GUIProperties);
  AddNotEmpty(Root.Properties, 'OtherProperties', OtherProperties);

  if FieldType = ftList then
  begin
    for i := 0 to ListValues.Count-1 do
    begin
      Elem := Root.Items.Add('ListValue');
      Elem.Properties.Add('Text', ListValues.Strings[i]);
    end;
    AddNotEmpty(Root.Properties, 'ListAutoAdd', IfThen(ListAutoAdd, 'True', ''));
    AddNotEmpty(Root.Properties, 'ListSort', IfThen(ListSort, 'True', ''));
    AddNotEmpty(Root.Properties, 'ListAutoComplete', IfThen(ListAutoComplete, 'True', ''));
    AddNotEmpty(Root.Properties, 'ListUseCatalogValues', IfThen(ListUseCatalogValues, 'True', ''));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldProperties.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
var
  str: string;
  i: Integer;
begin
  if (Root = nil) then
    Exit;

  FieldName := ReadTag(Root.Properties, 'Name', FieldName);
  FieldExt := ReadTag(Root.Properties, 'Ext', FieldExt);
  FieldType := ConvertFieldTypeFromString(ReadTag(Root.Properties, 'Type',
     ConvertFieldTypeToString(FieldType)));
  DefaultValue := ConvertFieldValue(ReadTag(Root.Properties, 'DefaultValue', DefaultValue), FieldType, False, True);
  MediaInfo := ReadTag(Root.Properties, 'MediaInfo', MediaInfo);
  str := ReadTag(Root.Properties, 'MultiValues', IfThen(MultiValues, 'True', ''));
  MultiValues := ConvertFieldValue(str, ftBoolean) = 'True';
  MultiValuesSep := ReadTag(Root.Properties, 'MultiValuesSep', MultiValuesSep)[1];
  if MultiValuesSep = #0 then MultiValuesSep := defaultSep;
  str := ReadTag(Root.Properties, 'MultiValuesRmP', IfThen(MultiValuesRmp, 'True', ''));
  MultiValuesRmP := ConvertFieldValue(str, ftBoolean) = 'True';
  str := ReadTag(Root.Properties, 'MultiValuesPatch', IfThen(MultiValuesPatch, 'True', ''));
  MultiValuesPatch := ConvertFieldValue(str, ftBoolean) = 'True';
  str := ReadTag(Root.Properties, 'ExcludedInScripts', IfThen(ExcludedInScripts, 'True', ''));
  ExcludedInScripts := ConvertFieldValue(str, ftBoolean) = 'True';
  GUIProperties := ReadTag(Root.Properties, 'GUIProperties', GUIProperties);
  OtherProperties := ReadTag(Root.Properties, 'OtherProperties', OtherProperties);
  
  ListValues.Clear;
  if FieldType = ftList then
  begin
    with Root.Items do
      for i := 0 to Count-1 do
        if (Item[i].Name = 'ListValue') and (Item[i].Properties.ItemNamed['Text'] <> nil) then
          ListValues.Add(Item[i].Properties.ItemNamed['Text'].Value);
    str := ReadTag(Root.Properties, 'ListAutoAdd', IfThen(ListAutoAdd, 'True', ''));
    ListAutoAdd := ConvertFieldValue(str, ftBoolean) = 'True';
    str := ReadTag(Root.Properties, 'ListSort', IfThen(ListSort, 'True', ''));
    ListSort := ConvertFieldValue(str, ftBoolean) = 'True';
    str := ReadTag(Root.Properties, 'ListAutoComplete', IfThen(ListAutoComplete, 'True', ''));
    ListAutoComplete := ConvertFieldValue(str, ftBoolean) = 'True';
    str := ReadTag(Root.Properties, 'ListUseCatalogValues', IfThen(ListUseCatalogValues, 'True', ''));
    ListUseCatalogValues := ConvertFieldValue(str, ftBoolean) = 'True';
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TCustomFieldsProperties
-------------------------------------------------------------------------------}

constructor TCustomFieldsProperties.Create(MovieList: TMovieList);
begin
  inherited Create;
  Self.MovieList := MovieList;
  Sorted := True;
  CaseSensitive := False;
  Duplicates := dupIgnore;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TCustomFieldsProperties.Destroy;
begin
  FreeObjects(Self);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.SetItem(const idx: Integer; Value: TCustomFieldProperties);
begin
  inherited Objects[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.GetItem(const idx: Integer): TCustomFieldProperties;
begin
  Result := TCustomFieldProperties(inherited Objects[idx]);
end;
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.Clear;
begin
  FreeObjects(Self);
  inherited Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.Assign(CustomFieldsProperties: TCustomFieldsProperties);
var
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  // Free and clear objects
  Clear();

  inherited Assign(CustomFieldsProperties);

  ColumnSettings := CustomFieldsProperties.ColumnSettings;
  GUIProperties := CustomFieldsProperties.GUIProperties;
  OtherProperties := CustomFieldsProperties.OtherProperties;

  // Make a copy of objects!
  for i:=0 to Count-1 do
  begin
    FieldProperties := TCustomFieldProperties.Create(Objects[i].FieldTag, Self);
    FieldProperties.Assign(Objects[i]);
    Objects[i] := FieldProperties;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.GetField(Tag: string): TCustomFieldProperties;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := IndexOf(Tag);
  if Idx = -1 then
    Exit;
  Result := Objects[idx];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.AddField(Tag: string; SpecialAdd: Boolean = False): TCustomFieldProperties;
var
  Idx: Integer;
begin
  Result := nil;
  Idx := Add(Tag);
  if(Idx <> -1) then
  begin
    if (not Assigned(Objects[Idx])) then
    begin
      Objects[Idx] := TCustomFieldProperties.Create(Tag, Self);
      if SpecialAdd then
        Objects[Idx].OldFieldTag := '#';
    end;
    Result := Objects[Idx];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.DeleteField(Tag: string): Boolean;
var
  Idx: Integer;
begin
  Result := Find(Tag, Idx);
  if Result = False then
    Exit;
  Objects[Idx].Free;
  Objects[Idx] := nil;
  Delete(Idx);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.ChangeFieldTag(Tag, NewTag: string): Boolean;
var
  Idx: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  Result := False;
  Idx := IndexOf(Tag);
  if (Idx = -1) then
    Exit;
  if (IndexOf(NewTag) <> -1) and (AnsiCompareText(Tag, NewTag) <> 0) then
    Exit;
  FieldProperties := nil;
  if (Objects[Idx] <> nil) then
  begin
    FieldProperties := Objects[Idx];
    if FieldProperties.OldFieldTag = '' then
      FieldProperties.OldFieldTag := FieldProperties.FieldTag;
    FieldProperties.FieldTag := NewTag;
  end;
  Delete(Idx);
  Idx := Add(NewTag);
  Objects[Idx] := FieldProperties;
  Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFieldsProperties.ChangeFieldType(Tag: string;
  NewType: TFieldType): Boolean;
var
  FieldProperties: TCustomFieldProperties;
begin
  Result := False;
  FieldProperties := GetField(Tag);
  if (FieldProperties = nil) then
    Exit;
  if (NewType <> FieldProperties.FieldType) then
  begin
    FieldProperties.DefaultValue := ConvertFieldValue(FieldProperties.DefaultValue, NewType, False, True);
    if (NewType = ftVirtual) then
      FieldProperties.MediaInfo := '';
    if (NewType <> ftString) and (NewType <> ftList) and (NewType <> ftText) and (NewType <> ftVirtual) then
    begin
      FieldProperties.MultiValues := False;
      FieldProperties.MultiValuesSep := defaultSep;
      FieldProperties.MultiValuesRmP := False;
      FieldProperties.MultiValuesPatch := False;
    end;
    FieldProperties.ListValues.Clear;
    FieldProperties.ListAutoAdd := False;
    FieldProperties.ListSort := False;
    FieldProperties.ListAutoComplete := False;
    FieldProperties.ListUseCatalogValues := False;
    FieldProperties.FieldType := NewType;
  end;
  Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.CheckFieldTags;
var
  i, n: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  if (MovieList = nil) then
    Exit;
  // First pass: Rename old field tags with new field tags + '*' before to avoid conflics
  for i:=0 to Count-1 do
  begin
    FieldProperties := Objects[i];
    if (FieldProperties.OldFieldTag <> '') and (FieldProperties.OldFieldTag <> '#') then
    begin
      for n:=0 to MovieList.Count-1 do
        MovieList.GetItem(n).CustomFields.ChangeTag(FieldProperties.OldFieldTag, '*'+FieldProperties.FieldTag);
      FieldProperties.OldFieldTag := '*'+FieldProperties.FieldTag;
    end
  end;
  // Second pass: Delete field values for new field tags if exits (same field tag deleted before)
  for i:=0 to Count-1 do
  begin
    FieldProperties := Objects[i];
    if (FieldProperties.OldFieldTag = '#') then
    begin // SpecialAdd (delete old values if exists)
      for n:=0 to MovieList.Count-1 do
        MovieList.GetItem(n).CustomFields.DeleteFieldValue(FieldProperties.FieldTag);
      FieldProperties.OldFieldTag := '';
    end;
  end;
  // Third pass: Remove * before new field tags
  for i:=0 to Count-1 do
  begin
    FieldProperties := Objects[i];
    if (FieldProperties.OldFieldTag <> '') then
    begin
      for n:=0 to MovieList.Count-1 do
        MovieList.GetItem(n).CustomFields.ChangeTag(FieldProperties.OldFieldTag, FieldProperties.FieldTag);
      FieldProperties.OldFieldTag := '';
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.CheckFieldValues;
var
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  if (MovieList = nil) then
    Exit;
  for i:=0 to Count-1 do
  begin
    FieldProperties := Objects[i];
    FieldProperties.DefaultValue := ConvertFieldValue(
      FieldProperties.DefaultValue, FieldProperties.FieldType, False, True);
  end;
  for i:=0 to MovieList.Count-1 do
    MovieList.GetItem(i).CustomFields.CheckFieldValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.RenameNoValidTags;
var
  i, n: Integer;
  Tag: string;
  AllValidTags: Boolean;
begin
  if (MovieList = nil) then
    Exit;
  n := 1;
  AllValidTags := True;
  for i:=0 to Count-1 do
  begin
    Tag := Strings[i];
    if not IsValidTag(Tag) then
    begin
      Tag := '__' + Tag;
      while (not IsValidTag(Tag)) or (IndexOf(Tag) > -1) do
      begin
        Tag := '__' + IntToStr(n);
        Inc(n);
      end;
      ChangeFieldTag(Strings[i], Tag);
      AllValidTags := False;
    end;
  end;
  if not AllValidTags then
    CheckFieldTags;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.WriteData(const OutputFile: TStream;
  const Version: Integer);
var
  i,j: Integer;
  Tag: string;
begin
  WriteString(ColumnSettings, OutputFile);
  WriteString(GUIProperties, OutputFile);
  //WriteString(OtherProperties, OutputFile);
  j := Count;
  OutputFile.WriteBuffer(j, intsize);
  for i := 0 to j-1 do
  begin
    Tag := Strings[i];
    WriteString(Tag, OutputFile);
    Objects[i].WriteData(OutputFile, Version);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.ReadData(const InputFile: TStream;
  const Version: Integer);
var
  i,j: Integer;
  Tag: string;
begin
  Clear;
  ColumnSettings := ReadString(InputFile);
  GUIProperties := ReadString(InputFile);
  //OtherProperties := ReadString(InputFile);
  InputFile.ReadBuffer(j, intsize);
  for i := 0 to j-1 do
  begin
    Tag := ReadString(InputFile);
    AddField(Tag).ReadData(InputFile, Version);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
{$IFNDEF DLLMode}
procedure TCustomFieldsProperties.SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string; const Version: Integer);
var
  i: Integer;
  Elem: TJvSimpleXmlElem;
begin
  if (Root = nil) then
    Exit;
  AddNotEmpty(Root.Properties, 'ColumnSettings', ColumnSettings);
  AddNotEmpty(Root.Properties, 'GUIProperties', GUIProperties);
  AddNotEmpty(Root.Properties, 'OtherProperties', OtherProperties);
  for i := 0 to Count-1 do
  begin
    Elem := Root.Items.Add('CustomField');
    AddNotEmpty(Elem.Properties, 'Tag', Strings[i]);
    Objects[i].SaveToXML(Elem, strFileName, Version);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.LoadFromXML(Root: TJvSimpleXmlElem;
  const Version: Integer);
var
  i: Integer;
  Tag: string;
  CustomFieldProperties: TCustomFieldProperties;
begin
  Clear;
  if (Root = nil) then
    Exit;
  ColumnSettings := ReadTag(Root.Properties, 'ColumnSettings', '');
  GUIProperties := ReadTag(Root.Properties, 'GUIProperties', '');
  OtherProperties := ReadTag(Root.Properties, 'OtherProperties', '');
  with Root.Items do
    for i := 0 to Count-1 do
      if(Item[i].Name = 'CustomField') then
      begin
        Tag := ReadTag(Item[i].Properties, 'Tag', '');
        // Note: Field tags are checked and renamed to the end if needed
        CustomFieldProperties := GetField(Tag);
        if CustomFieldProperties = nil then
          CustomFieldProperties := AddField(Tag);
        // else Replace It
        if (CustomFieldProperties <> nil) then
          CustomFieldProperties.LoadFromXML(Item[i], Version);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.ExportToXML(const strFileName: string; const Version: Integer);
begin
  if (MovieList <> nil) then
    MovieList.SaveToXML('', strFileName, Version, True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.Import(Properties: TCustomFieldsProperties;
  SpecialAdd: Boolean);
var
  i: Integer;
  CustomFieldProperties: TCustomFieldProperties;
  KeepGUIProperties: Boolean;
begin
  KeepGUIProperties := False;
  if Count = 0 then
  begin
    ColumnSettings := Properties.ColumnSettings;
    GUIProperties := Properties.GUIProperties;
    OtherProperties := Properties.OtherProperties;
    KeepGUIProperties := True;
  end;
  for i := 0 to Properties.Count-1 do
  begin
    CustomFieldProperties := GetField(Properties.Strings[i]);
    if CustomFieldProperties = nil then
      CustomFieldProperties := AddField(Properties.Strings[i], SpecialAdd);
    // else Replace It
    CustomFieldProperties.Assign(Properties.Objects[i], False, False, KeepGUIProperties);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.ImportFromXML(const strFileName: string;
  SpecialAdd: Boolean);
var
  MovieListTmp: TMovieList;
begin
  MovieListTmp := TMovieList.Create;
  try
    MovieListTmp.LoadFromXml(strFileName, True);
    Import(MovieListTmp.CustomFieldsProperties, SpecialAdd);
  finally
    MovieListTmp.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFieldsProperties.ImportFromAMC(const strFileName: string;
  SpecialAdd: Boolean);
var
  MovieListTmp: TMovieList;
begin
  MovieListTmp := TMovieList.Create;
  try
    MovieListTmp.LoadFromFile(strFileName, True);
    Import(MovieListTmp.CustomFieldsProperties, SpecialAdd);
  finally
    MovieListTmp.Free;
  end;
end;

{$ENDIF}
{-------------------------------------------------------------------------------
  TCustomFields
-------------------------------------------------------------------------------}

constructor TCustomFields.Create(Properties: TCustomFieldsProperties; Movie: TMovie);
begin
  inherited Create;
  Self.Properties := Properties;
  Self.Movie := Movie;
  Sorted := True;
  CaseSensitive := False;
  Duplicates := dupIgnore;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TCustomFields.Destroy;
begin
  FreeObjects(Self);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.SetItem(const idx: Integer; Value: TString);
begin
  inherited Objects[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.GetItem(const idx: Integer): TString;
begin
  Result := TString(inherited Objects[idx]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.Clear;
begin
  FreeObjects(Self);
  inherited Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.Assign(CustomFields: TCustomFields);
var
  i: Integer;
begin
  // Free and clear objects
  Clear();

  inherited Assign(CustomFields);

  // Make a copy of objects!
  for i:=0 to Count-1 do
    Objects[i] := TString.Create(Objects[i].str);

  CheckFieldValues;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.CheckFieldValues;
var
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  if Properties = nil then
    Exit;

  for i:=Count-1 downto 0 do
  begin
    FieldProperties := Properties.GetField(Strings[i]);
    if (FieldProperties = nil) or (FieldProperties.FieldType = ftVirtual) then
      DeleteFieldValue(Strings[i])
    else
      with Objects[i] do
      begin
        str := ConvertFieldValue(str, FieldProperties.FieldType);
        if str = '' then
          DeleteFieldValue(Strings[i])
        else if FieldProperties.FieldType = ftText then
          str := InsertLineBreaks(str)
        else
          str := ReplaceLineBreaks(str);
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.SetDefaultValues;
var
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  if Properties = nil then
    Exit;

  for i:=0 to Properties.Count-1 do
  begin
    if (Properties.Objects[i] <> nil) then
    begin
      FieldProperties := Properties.Objects[i];
      if (FieldProperties.FieldType = ftDate) and (SameText(FieldProperties.DefaultValue, 'Today')) then
        SetFieldValue(Properties.Strings[i], DateToStr(Date, FormatSettings))
      else
        SetFieldValue(Properties.Strings[i], FieldProperties.DefaultValue);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.SetFieldValue(Tag, Value: string;
  AddMissingField: Boolean): Boolean;
var
  Idx: Integer;
  Prop: TCustomFieldProperties;
begin
  Result := False;
  if Properties = nil then
    Exit;

  Prop := Properties.GetField(Tag);
  if Prop = nil then
    if AddMissingField then // Auto insert missing custom field properties
      Prop := Properties.AddField(Tag)
    else
      Exit;

  if (Prop = nil) or (Prop.FieldType = ftVirtual) then
    Exit;

  Value := ConvertFieldValue(Value, Prop.FieldType);

  if Value = '' then
  begin
    DeleteFieldValue(Tag);
  end else
  begin
    Idx := Add(Tag);
    if Idx <> -1 then
    begin
      if(not Assigned(Objects[Idx])) then
        Objects[Idx] := TString.Create('');
      with Objects[Idx] do
        str := Value;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.GetFieldValue(Tag: string;
  const LocalFormatSettings: Boolean;
  const ReturnEmptyIfFalse : Boolean;
  const ReturnEmptyIfVirtual: Boolean): string;
var
  Idx: Integer;
  Prop: TCustomFieldProperties;
begin
  Result := '';
  if Properties = nil then
    Exit;

  Prop := Properties.GetField(Tag);
  if Prop = nil then
    Exit;

  if Prop.FieldType <> ftVirtual then
  begin
    Idx := IndexOf(Tag);
    if Idx <> -1 then
      Result := Objects[idx].str;
    Result := ConvertFieldValue(Result, Prop.FieldType, LocalFormatSettings, False, ReturnEmptyIfFalse);
  end
  else if (not ReturnEmptyIfVirtual) and (Movie <> nil) then
  begin
    Result := Movie.GetValueFromTemplate(Prop.DefaultValue, nil, True);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.GetIntFieldValue(Tag: string): Integer;
var
  Idx: Integer;
  f: Double;
  Value: string;
  Prop: TCustomFieldProperties;
begin
  Result := -1;
  if Properties = nil then
    Exit;

  Prop := Properties.GetField(Tag);
  if Prop = nil then
    Exit;

  Idx := IndexOf(Tag);
  if Idx <> -1 then
    Value := Objects[idx].str
  else
    Exit;
  try
    if (Prop.FieldType = ftInteger) then
      Result := StrToIntDef(Value, -1)
    else if (Prop.FieldType = ftReal) or (Prop.FieldType = ftReal1) or (Prop.FieldType = ftReal2) then
    begin
      f := StrToFloatDef(Value, -1, FormatSettings);
      try
        if f = -1 then
          Result := -1
        else if (Prop.FieldType = ftReal1) then
          Result := Round(f * 10)
        else if (Prop.FieldType = ftReal2) then
          Result := Round(f * 100)
        else if (Prop.FieldType = ftReal) then
          Result := Round(f * 1000)
      except
        Result := -1;
      end;
    end
    else if (Prop.FieldType = ftDate) then
      Result := Trunc(StrToDateDef(Value, 0, FormatSettings));
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.GetFloatFieldValue(Tag: string): Double;
var
  Idx: Integer;
  Value: string;
  Prop: TCustomFieldProperties;
begin
  Result := -1;
  if Properties = nil then
    Exit;

  Prop := Properties.GetField(Tag);
  if Prop = nil then
    Exit;

  Idx := IndexOf(Tag);
  if Idx <> -1 then
    Value := Objects[idx].str
  else
    Exit;
  try
    if (Prop.FieldType = ftInteger) then
      Result := StrToIntDef(Value, -1)
    else if (Prop.FieldType = ftReal) or (Prop.FieldType = ftReal1) or (Prop.FieldType = ftReal2) then
      Result := StrToFloatDef(Value, -1, FormatSettings)
    else if (Prop.FieldType = ftDate) then
      Result := Trunc(StrToDateDef(Value, 0, FormatSettings));
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.ChangeTag(Tag: string; NewTag: string): Boolean;
var
  Obj: TString;
  Idx: Integer;
begin
  Result := False;
  if (IndexOf(NewTag) <> -1) then // Need to be done here to delete old value !
    DeleteFieldValue(NewTag);
  Idx := IndexOf(Tag);
  if (Idx = -1) then
    Exit;
  Obj := Objects[Idx];
  Delete(Idx);
  Idx := Add(NewTag);
  Objects[Idx] := Obj;
  Result := True;
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.DeleteFieldValue(Tag: string): Boolean;
var
  Idx: Integer;
begin
  Result := False;
  if Properties = nil then
    Exit;

  Result := Find(Tag, Idx);
  if Result = False then
    Exit;
  Objects[idx].Free;
  Objects[idx] := nil;
  Delete(Idx);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TCustomFields.GetFieldProperties(Tag: string): TCustomFieldProperties;
begin
  Result := nil;
  if Properties <> nil then
    Result := Properties.GetField(Tag);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.WriteData(const OutputFile: TStream;
  const Version: Integer; const Standalone: Boolean);
var
  i, NbCustomFields: Integer;
begin
  if not Standalone then
  begin
    for i := 0 to Properties.Count-1 do
      WriteString(GetFieldValue(Properties.Strings[i], False, True, True), OutputFile)
  end else
  begin
    NbCustomFields := Count;
    OutputFile.WriteBuffer(NbCustomFields, intsize);
    for i := 0 to NbCustomFields-1 do
    begin
      WriteString(Strings[i], OutputFile);
      WriteString(GetFieldValue(Strings[i], False, True, True), OutputFile);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.ReadData(const InputFile: TStream;
  const Version: Integer; const Standalone: Boolean);
var
  i, NbCustomFields: Integer;
  Tag: string;
begin
  Clear;
  if not Standalone then
  begin
    for i := 0 to Properties.Count-1 do
    begin
      Tag := Properties.Strings[i];
      SetFieldValue(Tag, ReadString(InputFile))
    end;
  end else
  begin
    InputFile.ReadBuffer(NbCustomFields, intsize);
    for i := 0 to NbCustomFields-1 do
    begin
      Tag := ReadString(InputFile);
      SetFieldValue(Tag, ReadString(InputFile), False);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TCustomFields.SaveToXML(Root: TJvSimpleXmlElem; const strFileName: string; const Version: Integer);
var
  i: Integer;
begin
  if (Root = nil) then
    Exit;
  for i := 0 to Count-1 do
    AddNotEmpty(Root.Properties, Strings[i], GetFieldValue(Strings[i], False, True, True));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TCustomFields.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
var
  i: Integer;
  FieldTag: string;
  Prop: TCustomFieldProperties;
begin
  Clear;
  if (Root = nil) then
    Exit;
  with Root.Properties do
    for i := 0 to Count-1 do
    begin
      FieldTag := Item[i].Name;
      // Note: Field tags are checked and renamed to the end if needed
      Prop := Properties.GetField(FieldTag);
      SetFieldValue(FieldTag, ReadTag(Root.Properties, FieldTag, '',
        (Prop <> nil) and (Prop.FieldType = ftText) {MultiLines}));
    end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TMoviePicture
-------------------------------------------------------------------------------}

constructor TMoviePicture.Create(Movie: TMovie; Extra: TMovieExtra);
begin
  inherited create;
{$IFNDEF DLLMode}
  mutex := CreateMutex(nil, False, Pchar('TMoviePictureMutex'+IntToStr(Integer(Self))));
{$ENDIF}
  Self.Movie := Movie;
  Self.Extra := Extra;
  PicPath := '';
  PicStream := nil;
{$IFNDEF DLLMode}
  _thumb := nil;
  _thumbError := 0;
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMoviePicture.Destroy;
begin
  if (PicStream <> nil) then
    PicStream.Free;
{$IFNDEF DLLMode}
  if (_thumb <> nil) then
    _thumb.Free;
  CloseHandle(mutex);
{$ENDIF}
  inherited destroy;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.Init;
begin
  PicPath := '';
  if (PicStream <> nil) then
    PicStream.Free;
  PicStream := nil;
{$IFNDEF DLLMode}
  if (_thumb <> nil) then
    _thumb.Free;
  _thumb := nil;
  _thumbError := 0;
  _thumbWidth := 0;
  _thumbHeight := 0;
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.Assign(APicture: TMoviePicture);
begin
  PicPath := APicture.PicPath;
  if (PicStream <> nil) then
    FreeAndNil(PicStream);
  if APicture.PicStream <> nil then
  begin
    PicStream := TMemoryStream.Create;
    APicture.PicStream.Seek(0, soFromBeginning);
    PicStream.CopyFrom(APicture.PicStream, APicture.PicStream.Size);
  end;
{$IFNDEF DLLMode}
  FreeAndNil(_thumb);
  _thumbError := 0;
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMoviePicture.Lock();
begin
  if WaitForSingleObject(mutex, INFINITE) <> WAIT_OBJECT_0 then
    RaiseLastOSError;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.LockWait(msTime: Integer): boolean;
begin
  if WaitForSingleObject(mutex, msTime) <> WAIT_OBJECT_0 then
    Result := false
  else
    Result := true;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.Unlock();
begin
  ReleaseMutex(Mutex);
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GetPictureStatus(CatalogFile: TFileName): TMoviePictureStatus;
begin
  if PicPath = '' then
    result := mpsNone
  else if PicStream <> nil then
    result := mpsStored
  else if (Pos('\', PicPath) = 0) // Picture is a copied picture in catalog folder
    and (Pos('/', PicPath) = 0) {for UNIX} then
    result := mpsCopiedInCatDir
  else if (CatalogFile <> '') and // Picture is a copied picture in pictures folder
    (StartsText(GetCatalogPicDir(CatalogFile) + '\', PicPath) or
     StartsText(GetCatalogPicDir(CatalogFile) + '/', PicPath)) {for UNIX} then
    result := mpsCopiedInPicDir
  else if (PicPath[2] <> ':') and (PicPath[1] <> '\')
    and (PicPath[1] <> '/') {for UNIX} then
    result := mpsLinkRel
  else
    result := mpsLinkAbs;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.PictureOperation(const CatalogFile: TFileName;
  const Operation: TMoviePictureOperation;
  const OriginalPictureName: TFileName; {for copy from stream}
  const MaxWidth: Integer; const MaxHeight: Integer {for conversion and resizing});
var
  Stream: TFileStream;
  RawName, FullName: TFileName;
  Ext: string;
  Status: TMoviePictureStatus;
  CopyInPicDir: Boolean;
  PicDir, PicName: string;
begin
  if (Operation = mpoUndefined) then
    Exit;
  Status := GetPictureStatus(CatalogFile);
  if (Operation = mpoStore) or (Operation = mpoStoreIfCopied) or
    (Operation = mpoCopyInCatDir) or (Operation = mpoCopyInCatDirIfStored) or (Operation = mpoCopyInCatDirIfCopied) or
    (Operation = mpoCopyInPicDir) or (Operation = mpoCopyInPicDirIfStored) or (Operation = mpoCopyInPicDirIfCopied) then
  begin
    if (Status = mpsUndefined) or (Status = mpsNone) or
      ((Operation = mpoStore) and (Status = mpsStored)) or
      ((Operation = mpoStoreIfCopied) and (Status <> mpsCopiedInCatDir) and (Status <> mpsCopiedInPicDir)) or
      ((Operation = mpoCopyInCatDir) and (Status = mpsCopiedInCatDir)) or
      ((Operation = mpoCopyInCatDirIfStored) and (Status <> mpsStored)) or
      ((Operation = mpoCopyInCatDirIfCopied) and (Status <> mpsCopiedInPicDir)) or
      ((Operation = mpoCopyInPicDir) and (Status = mpsCopiedInPicDir)) or
      ((Operation = mpoCopyInPicDirIfStored) and (Status <> mpsStored)) or
      ((Operation = mpoCopyInPicDirIfCopied) and (Status <> mpsCopiedInCatDir)) then
      Exit;
    FullName := '';
    RawName := '';
    if PicStream = nil then
    begin
      try
        if (CatalogFile = '') then
        begin
          if (Status <> mpsLinkAbs) then
            Exit;
          RawName := PicPath;
          FullName := PicPath;
        end else
        begin
          SetCurrentDir(ExtractFilePath(CatalogFile));
          RawName := PicPath;
          FullName := ExpandFileName(PicPath);
        end;
        if FileExists(FullName) then
        begin
          Stream := TFileStream.Create(FullName, fmOpenRead);
{$IFNDEF DLLMode}
          Ext := GetRealPictureExt(Stream, extImage[extPNG], extImage[extJPG], extImage[extGIF], extImage[extBMP], ExtractFileExt(FullName));
          Stream.Free;
          if IndexText(Ext, extImage) = -1 then
            raise Exception.Create('Unrecognized picture format');
{$ELSE}
          Ext := GetRealPictureExt(Stream, '.png', '.gif', '.jpg', '.bmp', ExtractFileExt(FullName));
          Stream.Free;
          if IndexText(Ext, ['.png', '.gif', '.jpg', '.jpe', '.jpeg', '.bmp']) = -1 then
            raise Exception.Create('Unrecognized picture format');
{$ENDIF}
          PicStream := TMemoryStream.Create;
          try
            PicStream.LoadFromFile(FullName);
            PicPath := Ext;
          except
            on e: Exception do
            begin
              FreeAndNil(PicStream);
              raise Exception.Create(e.Message);
            end;
          end;
          if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) then
          begin
            if (Operation <> mpoStore) and (Operation <> mpoStoreIfCopied) then
              SysUtils.DeleteFile(FullName) // If others movies use this picture,
              // then they will be redirect to the new copied picture later
            else
              // We check the number of movies using this picture and we delete it
              // only if it is used by one movie ( = current movie)
              if (Movie = nil) or (Movie.MovieList = nil) or
                (Movie.MovieList.CountPictures(RawName) <= 1) then
                SysUtils.DeleteFile(FullName);
          end;
          if (Status = mpsCopiedInPicDir) then
            RemoveCatalogPicDirIfEmpty(CatalogFile);
        end;
      except
        on e: Exception do
          raise Exception.Create(e.Message);
      end;
    end;
    if PicStream = nil then
      Exit;
{$IFNDEF DLLMode}
    // In case picture had a bad file extension, we try to reload thumb
    if _thumbError > 0 then
    begin
      FreeAndNil(_thumb);
      _thumbError := 0;
    end;
{$ENDIF}
    if (Operation = mpoStore) or (Operation = mpoStoreIfCopied) or (CatalogFile = '') then
      Exit;
    try
      SetCurrentDir(ExtractFilePath(CatalogFile));
      CopyInPicDir := (Operation = mpoCopyInPicDir) or (Operation = mpoCopyInPicDirIfStored) or (Operation = mpoCopyInPicDirIfCopied);
      PicDir := '';
      if CopyInPicDir then
        PicDir := GetCatalogPicDir(CatalogFile, True) + '\';
      Ext := PicPath;
      if OriginalPictureName <> '' then
        PicName := GeneratePictureName(CatalogFile, Ext, OriginalPictureName, PicDir)
      else if FullName <> '' then
        PicName := GeneratePictureName(CatalogFile, Ext, ExtractFileName(FullName), PicDir)
      else
        if Movie <> nil then
          PicName := GeneratePictureName(CatalogFile, Ext, ValidateFileName(Movie.GetFormattedTitle) + Ext, PicDir)
        else
          PicName := GeneratePictureName(CatalogFile, Ext, '', PicDir);

      PicStream.SaveToFile(ExtractFilePath(CatalogFile) + PicDir + PicName);
      FreeAndNil(PicStream);
      PicPath := PicDir + PicName;
      if (Movie <> nil) and (Movie.MovieList <> nil) and
        ((Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir)) then
        Movie.MovieList.RenamePictures(RawName, PicPath);
    except
      on e: Exception do
        raise Exception.Create(e.Message);
    end;
  end
  else if (Operation = mpoRenameIfCopied) then
  begin
    if (CatalogFile = '') or ((Status <> mpsCopiedInCatDir) and (Status <> mpsCopiedInPicDir)) then
      Exit;
    SetCurrentDir(ExtractFilePath(CatalogFile));
    if not FileExists(ExpandFileName(PicPath)) then
      Exit;
    if OriginalPictureName <> '' then
      PicName := GeneratePictureName(CatalogFile, ExtractFileExt(PicPath),
        OriginalPictureName, '', False)
    else
      PicName := GeneratePictureName(CatalogFile, ExtractFileExt(PicPath),
        ExtractFileName(PicPath), '', False);
    if PicName <> ExtractFileName(PicPath) then
    begin
      PicDir := '';
      if Status = mpsCopiedInPicDir then
        PicDir := ExtractFilePath(PicPath);
      PicName := ExtractFileName(MakeUniqueFileName(ExtractFilePath(CatalogFile) + PicDir + PicName, '_'));
      MoveFile(PChar(ExpandFileName(PicPath)), PChar(ExpandFileName(PicDir + PicName)));
      RawName := PicPath;
      PicPath := PicDir + PicName;
      if (Movie <> nil) and (Movie.MovieList <> nil) then
        Movie.MovieList.RenamePictures(RawName, PicPath);
    end;
  end
  else if (Operation = mpoAbsToRelLink) or (Operation = mpoRelToAbsLink) then
  begin
    if (CatalogFile = '') or (Status = mpsUndefined) or (Status = mpsNone) then
      Exit;
    SetCurrentDir(ExtractFilePath(CatalogFile));
    if (Status = mpsLinkAbs) and (Operation = mpoAbsToRelLink) then
      PicPath := ExtractRelativePath(ExtractFilePath(CatalogFile),
        ExtractFilePath(PicPath)) + ExtractFileName(PicPath)
    else if (Status = mpsLinkRel) and (Operation = mpoRelToAbsLink) then
      PicPath := ExpandFilename(PicPath);
  end
  else if (Operation = mpoDelete) or (Operation = mpoDeleteWithLinkedFile) or
    (Operation = mpoDeleteIfStored) or (Operation = mpoDeleteIfCopied) then
  begin
    if ((Operation = mpoDeleteIfStored) and (Status <> mpsStored)) or
       ((Operation = mpoDeleteIfCopied) and (Status <> mpsCopiedInCatDir) and
        (Status <> mpsCopiedInPicDir)) then
      Exit;
    if Status = mpsStored then
    begin
      FreeAndNil(PicStream);
      PicPath := '';
    end
    else if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) then
    begin
      if (CatalogFile = '') then
        Exit;
      SetCurrentDir(ExtractFilePath(CatalogFile));
      // We check the number of movies using this picture and we delete it
      // only if it is used by one movie ( = current movie)
      if (Movie = nil) or (Movie.MovieList = nil) or
        (Movie.MovieList.CountPictures(PicPath) <= 1) then
        SysUtils.DeleteFile(ExpandFilename(PicPath));
      PicPath := '';
      if (Status = mpsCopiedInPicDir) then
        RemoveCatalogPicDirIfEmpty(CatalogFile);
    end
    else if (Status = mpsLinkRel) or (Status = mpsLinkAbs) then
    begin
      if Operation = mpoDeleteWithLinkedFile then
      begin
        if (CatalogFile = '') then
        begin
          if Status = mpsLinkAbs then
             SysUtils.DeleteFile(PicPath);
        end else
        begin
          SetCurrentDir(ExtractFilePath(CatalogFile));
          SysUtils.DeleteFile(ExpandFilename(PicPath));
        end;
      end;
      PicPath := '';
    end;
{$IFNDEF DLLMode}
    FreeAndNil(_thumb);
    _thumbError := 0;
{$ENDIF}
  end
  else if (Operation = mpoConvertIfStoredOrCopied) or (Operation = mpoConvert) then
  begin
{$IFNDEF DLLMode}
    ConvertPicture(CatalogFile, MaxWidth, MaxHeight, (Operation = mpoConvertIfStoredOrCopied));
{$ENDIF}
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.ImportPicture(const AFileName: TFileName;
  const CatalogFile: TFileName; const ImportMethod: TMoviePictureImport): Boolean;
var
  Status: TMoviePictureStatus;
  IsFile, IsFileToDelete, IsSameFile: Boolean;
  FullFileName: TFileName;
  MoviePicSave: TMoviePicture;
begin
  Result := False;
  if (AFileName = '') or (ImportMethod = mpiUndefined) then
    Exit;
  if CatalogFile <> '' then
    SetCurrentDir(ExtractFilePath(CatalogFile))
{$IFNDEF DLLMode}
  else
    SetCurrentDir(strDirCatalogs)
{$ENDIF};
  FullFileName := ExpandFileName(AFileName);
  if not FileExists(FullFileName) then
    Exit;

  MoviePicSave := TMoviePicture.Create(Movie, Extra);
  MoviePicSave.Assign(Self);
  Status := GetPictureStatus(CatalogFile);
  IsFile := (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) or
    (Status = mpsLinkAbs) or (Status = mpsLinkRel);
  IsFileToDelete := ((Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir))
    and ((Movie = nil) or (Movie.Movielist = nil) or (Movie.MovieList.CountPictures(PicPath) <= 1));
  IsSameFile := False;
  try
    if IsFile then
      IsSameFile := SameFileName(FullFileName, ExpandFileName(PicPath));

    if not IsSameFile then
    begin
      if IsFileToDelete then
      begin
        // We rename old picture file to not delete it now and enable import of new picture file with same name
        if FileExists(ExpandFileName(PicPath)+'.old') then
          SysUtils.DeleteFile(ExpandFileName(PicPath)+'.old');
        RenameFile(ExpandFileName(PicPath), ExpandFileName(PicPath)+'.old');
      end;

      // We delete old picture (not file)
      FreeAndNil(PicStream);
      PicPath := FullFileName;
    end
    else
    begin
      if not IsFileToDelete then
      begin
        // We delete old picture (not file)
        FreeAndNil(PicStream);
        PicPath := FullFileName;
      end;
    end;

    if (ImportMethod = mpiLinkAbs) or (ImportMethod = mpiLinkRel) then
{$IFNDEF DLLMode}
      if IndexText(ExtractFileExt(AFileName), extImage) = -1 then
        raise Exception.Create('Unrecognized picture format');
{$ELSE}
      if IndexText(ExtractFileExt(AFileName), ['.png', '.gif', '.jpg', '.jpe', '.jpeg', '.bmp']) = -1 then
        raise Exception.Create('Unrecognized picture format');
{$ENDIF}

    if ImportMethod = mpiStore then
      PictureOperation(CatalogFile, mpoStore)
    else if ImportMethod = mpiCopyInCatDir then
      if (Status = mpsCopiedInCatDir) and IsSameFile and IsFileToDelete then
        PictureOperation(CatalogFile, mpoRenameIfCopied)
      else
        PictureOperation(CatalogFile, mpoCopyInCatDir)
    else if ImportMethod = mpiCopyInPicDir then
      if (Status = mpsCopiedInPicDir) and IsSameFile and IsFileToDelete then
        PictureOperation(CatalogFile, mpoRenameIfCopied)
      else
        PictureOperation(CatalogFile, mpoCopyInPicDir)
    else if ImportMethod = mpiLinkRel then
      PictureOperation(CatalogFile, mpoAbsToRelLink)
    else if ImportMethod = mpiLinkAbs then
      PictureOperation(CatalogFile, mpoRelToAbsLink);

    // Import is OK now so we can delete old picture file if needed
    if not IsSameFile then
    begin
      if IsFileToDelete then
      begin
        SysUtils.DeleteFile(ExpandFilename(MoviePicSave.PicPath + '.old'));
        if (Status = mpsCopiedInPicDir) then
          RemoveCatalogPicDirIfEmpty(CatalogFile);
      end;
    end;
    FreeAndNil(MoviePicSave);

{$IFNDEF DLLMode}
    // We delete thumb (it will be regenerate later) !
    FreeAndNil(_thumb);
    _thumbError := 0;
{$ENDIF}

    Result := True;
  except
    on e: Exception do
    begin
      // Import is KO so we restore old picture
      if not IsSameFile then
      begin
        if IsFileToDelete then
          RenameFile(ExpandFileName(MoviePicSave.PicPath)+'.old', ExpandFileName(MoviePicSave.PicPath));
        Assign(MoviePicSave);
      end
      else
      begin
        if not IsFileToDelete then
          Assign(MoviePicSave);
      end;
      FreeAndNil(MoviePicSave);
      raise Exception.Create(e.Message);
    end;
  end;

{$IFNDEF DLLMode}
  // We convert picture to JPG and we resize it if needed
  if (Movie <> nil) then
    if (Extra = nil) and Settings.rOptions.rMovieInformation.rPicImport.PicConvertJPG then
      with Settings.rOptions.rMovieInformation.rPicImport do
        PictureOperation(CatalogFile, mpoConvertIfStoredOrCopied, '', MaxPicSizeW, MaxPicSizeH)
    else if (Extra <> nil) and Settings.rOptions.rMovieInformation.rExtraPicImport.PicConvertJPG then
      with Settings.rOptions.rMovieInformation.rExtraPicImport do
        PictureOperation(CatalogFile, mpoConvertIfStoredOrCopied, '', MaxPicSizeW, MaxPicSizeH);
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.ImportPictureFromStream(const AStream: TStream; const DefaultExt: string;
  const CatalogFile: TFileName; const ImportMethod: TMoviePictureImport;
  const OriginalPictureName: TFileName {for copy from stream}): Boolean;
var
  Status: TMoviePictureStatus;
  IsFileToDelete: Boolean;
  Ext: string;
  MoviePicSave: TMoviePicture;
begin
  Result := False;
  if (AStream = nil) or (ImportMethod = mpiUndefined) then
    Exit;
  if CatalogFile <> '' then
    SetCurrentDir(ExtractFilePath(CatalogFile))
{$IFNDEF DLLMode}
  else
    SetCurrentDir(strDirCatalogs)
{$ENDIF};

  MoviePicSave := TMoviePicture.Create(Movie, Extra);
  MoviePicSave.Assign(Self);
  Status := GetPictureStatus(CatalogFile);
  IsFileToDelete := ((Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir))
    and ((Movie = nil) or (Movie.Movielist = nil) or (Movie.MovieList.CountPictures(PicPath) <= 1));
  try
    // We rename old picture file to not delete it now and enable import of new picture file with same name
    if IsFileToDelete then
    begin
      if FileExists(ExpandFileName(PicPath)+'.old') then
        SysUtils.DeleteFile(ExpandFileName(PicPath)+'.old');
      RenameFile(ExpandFileName(PicPath), ExpandFileName(PicPath)+'.old');
    end;

    // We delete old picture (not file)
    FreeAndNil(PicStream);
    PicPath := '';

{$IFNDEF DLLMode}
    Ext := GetRealPictureExt(AStream, extImage[extPNG], extImage[extJPG], extImage[extGIF], extImage[extBMP], DefaultExt);
    if IndexText(Ext, extImage) = -1 then
      raise Exception.Create('Unrecognized picture format');
{$ELSE}
    Ext := GetRealPictureExt(AStream, '.png', '.gif', '.jpg', '.bmp', DefaultExt);
    if IndexText(Ext, ['.png', '.gif', '.jpg', '.jpe', '.jpeg', '.bmp']) = -1 then
      raise Exception.Create('Unrecognized picture format');
{$ENDIF}

    PicStream := TMemoryStream.Create;
    AStream.Seek(0, soFromBeginning);
    PicStream.CopyFrom(AStream, AStream.Size);
    PicPath := Ext;

    if ImportMethod = mpiCopyInCatDir then
      PictureOperation(CatalogFile, mpoCopyInCatDir, OriginalPictureName)
    else if ImportMethod = mpiCopyInPicDir then
      PictureOperation(CatalogFile, mpoCopyInPicDir, OriginalPictureName);

    // Import is OK now so we can delete old picture file if needed
    if IsFileToDelete then
    begin
      SysUtils.DeleteFile(ExpandFilename(MoviePicSave.PicPath + '.old'));
      if (Status = mpsCopiedInPicDir) then
        RemoveCatalogPicDirIfEmpty(CatalogFile);
    end;
    FreeAndNil(MoviePicSave);

{$IFNDEF DLLMode}
    // We delete thumb (it will be regenerate later) !
    FreeAndNil(_thumb);
    _thumbError := 0;
{$ENDIF}

    Result := True;
  except
    on e: Exception do
    begin
      // Import is KO so we restore old picture
      if IsFileToDelete then
        RenameFile(ExpandFileName(MoviePicSave.PicPath)+'.old', ExpandFileName(MoviePicSave.PicPath));
      Assign(MoviePicSave);
      FreeAndNil(MoviePicSave);
      raise Exception.Create(e.Message);
    end;
  end;

{$IFNDEF DLLMode}
  // We convert picture to JPG and we resize it if needed
  if (Movie <> nil) then
    if (Extra = nil) and Settings.rOptions.rMovieInformation.rPicImport.PicConvertJPG then
      with Settings.rOptions.rMovieInformation.rPicImport do
        PictureOperation(CatalogFile, mpoConvertIfStoredOrCopied, '', MaxPicSizeW, MaxPicSizeH)
    else if (Extra <> nil) and Settings.rOptions.rMovieInformation.rExtraPicImport.PicConvertJPG then
      with Settings.rOptions.rMovieInformation.rExtraPicImport do
        PictureOperation(CatalogFile, mpoConvertIfStoredOrCopied, '', MaxPicSizeW, MaxPicSizeH);
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GeneratePictureName(const CatalogFile: TFileName;
  const PictureExt: string; const OriginalPictureName: string;
  const PicDirWithSlash: string; const MakeAUniqueFilename: Boolean): string;
{$IFDEF DLLMode}
var
  CatalogPrefix: string;
  ExtraName: string;
{$ENDIF}
begin
  Result := '';
{$IFNDEF DLLMode}
  Result := Settings.rOptions.rMovieInformation.PictureNaming.GetFileName(CatalogFile, '',
    OriginalPictureName, PictureExt, Movie, Extra);
{$ELSE}
  if Movie <> nil then
    Result := IntToStr(Movie.iNumber);
  if Extra <> nil then
  begin
    ExtraName := IntToStr(Extra.iNumber);
    if (Result <> '') and (ExtraName <> '') then
      Result := Result + '_' + ExtraName
    else
      Result := Result + ExtraName;
  end;
  if Result = '' then
    Result := 'untitled';
  Result := Result + lowercase(PictureExt);
  CatalogPrefix := ChangeFileExt(ExtractFileName(CatalogFile), '');
  if (CatalogPrefix <> '') and (not StartsStr(CatalogPrefix + '_', Result)) then
    Result := Format('%s_%s', [CatalogPrefix, Result]);
  Result := ValidateFileName(Result);
  // Limit filename length
  if Length(Result) > 160 then
    System.Delete(Result, 160 - Length(PictureExt) + 1, Length(Result) - 160);
{$ENDIF}
  if MakeAUniqueFilename Then
    Result := ExtractFileName(MakeUniqueFileName(ExtractFilePath(CatalogFile) + PicDirWithSlash + Result, '_'));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GetPictureCaption: string;
begin
  Result := '';
  if Movie <> nil then
    Result := Movie.GetFormattedTitle;
  if Extra <> nil then
  begin
    if (Extra.strTitle <> '') and (Result <> '') then
      Result := ' - ' + Result;
    Result := Extra.strTitle + Result;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GetPictureSize(const CatalogFile: TFileName): Int64;
begin
  Result := -1;
  if PicPath <> '' then
  begin
    if PicStream <> nil then
      Result := PicStream.Size
    else
    begin
      if CatalogFile <> '' then
        SetCurrentDir(ExtractFilePath(CatalogFile))
{$IFNDEF DLLMode}
      else
        SetCurrentDir(strDirCatalogs)
{$ENDIF};
      Result := GetFileSize(ExpandFileName(PicPath));
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMoviePicture.GetPictureDimensions(const CatalogFile: TFileName;
  var Width: Integer; var Height: Integer);
begin
  Width := 0;
  Height := 0;
  try
    if PicPath <> '' then
    begin
      if PicStream = nil then
      begin
        if CatalogFile <> '' then
          SetCurrentDir(ExtractFilePath(CatalogFile))
        else
          SetCurrentDir(strDirCatalogs);
        if FileExists(ExpandFileName(PicPath)) then
          GetImageSizeFromFile(ExpandFileName(PicPath), Width, Height);
      end else
        GetImageSize(PicStream, PicPath, Width, Height);
    end;
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GetPictureWidth(const CatalogFile: TFileName): Integer;
var
  Width, Height: Integer;
begin
  GetPictureDimensions(CatalogFile, Width, Height);
  Result := Width;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.GetPictureHeight(const CatalogFile: TFileName): Integer;
var
  Width, Height: Integer;
begin
  GetPictureDimensions(CatalogFile, Width, Height);
  Result := Height;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMoviePicture.ConvertPicture(const CatalogFile: TFileName;
  MaxWidth: Integer = -1; MaxHeight: Integer = -1;
  OnlyIfStoredOrCopied: Boolean = True): Boolean;
var
  PicFullPath: TFileName;
  NewImg: TJPEGImage;
begin
  Result := False;
  PicFullPath := '';

  if CatalogFile <> '' then
    SetCurrentDir(ExtractFilePath(CatalogFile))
  else
    SetCurrentDir(strDirCatalogs);

  if OnlyIfStoredOrCopied and (GetPictureStatus(CatalogFile) in [mpsLinkAbs, mpsLinkRel]) then
    exit;

  if (PicPath <> '') then
  begin
    try
      if PicStream = nil then
      begin
        PicFullPath := ExpandFileName(PicPath);
        NewImg := ConvertImageFromFile(PicFullPath, MaxWidth, MaxHeight);
      end else
      begin
        NewImg := ConvertImage(PicStream, PicPath, MaxWidth, MaxHeight);
      end
    except
    end;

    if NewImg <> nil then
      try
        if (PicStream = nil) then
        begin
          SysUtils.DeleteFile(PicFullPath);
          PicFullPath := ChangeFileExt(PicFullPath, '.jpg');
          PicFullPath := MakeUniqueFileName(PicFullPath, '_');
          NewImg.SaveToFile(PicFullPath);
          PicPath := ExtractFilePath(PicPath) + ExtractFileName(PicFullPath);
        end else
        begin
          PicStream.Clear;
          NewImg.SaveToStream(PicStream);
          PicPath := '.jpg';
        end;
        // We delete thumb (it will be regenerate later) !
        FreeAndNil(_thumb);
        _thumbError := 0;
        Result := True;
      finally
        FreeAndNil(NewImg);
      end;
    end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.SavePicture(const CatalogFileSrc: TFileName;
  const CatalogFileDst: TFileName;
  PicOperation: TMoviePictureOperation);
var
  RawName, FullName: TFileName;
  Status: TMoviePictureStatus;
  OriginalPicName, CatalogPrefix: string;
begin
  // If PicPath[1] contains tag ' ' to indicate picture
  // has already been saved, we remove only tag ' '
  if (PicPath <> '') and (PicPath[1] = ' ') then
  begin
    System.Delete(PicPath, 1, 1);
    Exit;
  end;

  if (CatalogFileSrc <> '') and (CatalogFileDst <> '') and
    not SameFileName(CatalogFileSrc, CatalogFileDst) then
  begin
    if (PicPath <> '') and (PicStream = nil) then
    begin
      try
        SetCurrentDir(ExtractFilePath(CatalogFileSrc));
        RawName := PicPath;
        FullName := ExpandFileName(PicPath);
        OriginalPicName := ExtractFileName(PicPath);
{$IFNDEF DLLMode}
        CatalogPrefix := ChangeFileExt(ExtractFileName(CatalogFileSrc), '') +
          Settings.rOptions.rMovieInformation.PictureNaming.Separator1;
{$ELSE}
        CatalogPrefix := ChangeFileExt(ExtractFileName(CatalogFileSrc), '') + '_';
{$ENDIF}
        if StartsStr(CatalogPrefix, OriginalPicName) then
          OriginalPicName := Copy(OriginalPicName, Length(CatalogPrefix) + 1,
            Length(OriginalPicName) - Length(CatalogPrefix));

        if FileExists(FullName) then
        begin
          Status := GetPictureStatus(CatalogFileSrc);
          if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) then
          begin
            PicPath := FullName;
            if (PicOperation = mpoStoreIfCopied) then
              PicOperation := mpoStore
            else if (PicOperation = mpoCopyInCatDirIfCopied) then
              PicOperation := mpoCopyInCatDir
            else if (PicOperation = mpoCopyInPicDirIfCopied) then
              PicOperation := mpoCopyInPicDir
            else if (PicOperation = mpoDeleteIfCopied) or (PicOperation = mpoDeleteWithLinkedFile) then
              PicOperation := mpoDelete;
            if not ((PicOperation = mpoStore) or (PicOperation = mpoDelete) or
              (PicOperation = mpoAbsToRelLink) or (PicOperation = mpoRelToAbsLink)) then
            begin
              if ((Status = mpsCopiedInCatDir) and not (PicOperation = mpoCopyInPicDir)) or
                 (PicOperation = mpoCopyInCatDir) then
                PictureOperation(CatalogFileDst, mpoCopyInCatDir, OriginalPicName)
              else
                PictureOperation(CatalogFileDst, mpoCopyInPicDir, OriginalPicName);
              if (Movie <> nil) and (Movie.MovieList <> nil) and Movie.MovieList.SavingCatalog then
                Movie.MovieList.RenamePictures(RawName, ' ' + PicPath, Self);
              Exit;
            end;
          end
          else if Status = mpsLinkRel then
          begin
            PicPath := ExtractRelativePath(ExtractFilePath(CatalogFileDst),
              ExtractFilePath(FullName)) + ExtractFileName(FullName);
          end;
        end;
      except
      end;
    end;
  end;
  PictureOperation(CatalogFileDst, PicOperation, OriginalPicName);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.WriteData(const OutputFile: TStream;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer;
  const PicOperation: TMoviePictureOperation);
var
  recsize: integer;
begin
  with OutputFile do
  begin
    try
      SavePicture(CatalogFileSrc, CatalogFileDst, PicOperation);
    except
    end;
    WriteString(PicPath, OutputFile);
    if (PicStream = nil) then
      recsize := 0
    else
      recsize := PicStream.Size;
    WriteBuffer(recsize, intsize);
    if recsize > 0 then
    begin
      PicStream.Seek(0, soFromBeginning);
      CopyFrom(PicStream, recsize)
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.ReadData(const InputFile: TStream; const Version: Integer;
  const LoadStoredPicture: Boolean);
var
  recsize: integer;
begin
  with InputFile do
  begin
    PicPath := ReadString(InputFile);
    ReadBuffer(recsize, intsize);
    if recsize > 0 then
    begin
      if LoadStoredPicture then
      begin
        PicStream := TMemoryStream.Create;
        PicStream.CopyFrom(InputFile, recsize);
      end
      else
      begin
        PicStream := nil;
        PicPath := '';
        InputFile.Seek(recsize, soFromCurrent);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMoviePicture.SaveToXML(Root: TJvSimpleXmlElem;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer;
  const PicOperation: TMoviePictureOperation);
begin
  if Root = nil then
    Exit;
  try
    SavePicture(CatalogFileSrc, CatalogFileDst, PicOperation);
    PictureOperation(CatalogFileDst, mpoDeleteIfStored);
  except
  end;
  if Extra = nil then
    AddNotEmpty(Root.Properties, strTagFieldPicture, PicPath)
  else
    AddNotEmpty(Root.Properties, strTagExtraFieldPicture, PicPath);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMoviePicture.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
begin
  if Root = nil then
    Exit;
  if Extra = nil then
    PicPath := ReadTag(Root.Properties, strTagFieldPicture, '')
  else
    PicPath := ReadTag(Root.Properties, strTagExtraFieldPicture, '');
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TMovieExtra
-------------------------------------------------------------------------------}

constructor TMovieExtra.Create(Extras: TMovieExtras);
begin
  inherited Create;
  Self.Extras := Extras;
  if Extras <> nil then
    Picture := TMoviePicture.Create(Extras.Movie, Self)
  else
    Picture := TMoviePicture.Create(nil, Self);
  InitFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieExtra.Destroy;
begin
  Picture.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.InitFields;
begin
  iNumber := 0;
  bChecked := False;
  strTag := '';
  strTitle := '';
  strCategory := '';
  strURL := '';
  strDescription := '';
  strComments := '';
  strCreatedBy := '';
  {$IFNDEF DLLMode}
  _bSelected := False;
  _linkedExtra := nil;
  _iStatus := mesNormal;
  {$ENDIF}
  Picture.Init;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.Assign(Extra: TMovieExtra; IncludeTag: Boolean;
  IncludePicture: Boolean; IncludeListValues: Boolean);
begin
  if IncludeListValues then
  begin
    bChecked := Extra.bChecked;
  end;
  if IncludeTag then
    strTag := Extra.strTag;
  strTitle := Extra.strTitle;
  strCategory := Extra.strCategory;
  strURL := Extra.strURL;
  strDescription := Extra.strDescription;
  strComments := Extra.strComments;
  strCreatedBy := Extra.strCreatedBy;
  if IncludePicture then
    Picture.Assign(Extra.Picture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtra.GetFieldValue(const FieldID: TMovieField;
    const LocalFormatSettings: Boolean;
    const ReturnEmptyIfFalse : Boolean;
    const ReturnEmptyIfVirtual: Boolean): string;
begin
  Result := '';
  if ReturnEmptyIfVirtual and (FieldID in VirtualFields) then
    exit;
  case FieldID of
    extraFieldNumber:
      Result := IntToStr(iNumber);
    extraFieldChecked:
    begin
      Result := BoolToStr(bChecked, True);
      if ReturnEmptyIfFalse and not bChecked then
        Result := '';
    end;
    extraFieldTag:          Result := strTag;
    extraFieldTitle:        Result := strTitle;
    extraFieldCategory:     Result := strCategory;
    extraFieldURL:          Result := strURL;
    extraFieldDescription:  Result := strDescription;
    extraFieldComments:     Result := strComments;
    extraFieldCreatedBy:    Result := strCreatedBy;
    extraFieldPictureStatus:
      if (Extras <> nil) and (Extras.Movie <> nil) and (Extras.Movie.MovieList <> nil) then
      {$IFNDEF DLLMode}
        Result := strPictureStatus[Integer(Picture.GetPictureStatus(Extras.Movie.MovieList.CurrentCatalogFile))]
      {$ELSE}
        Result := IntToStr(Integer(Picture.GetPictureStatus(Extras.Movie.MovieList.CurrentCatalogFile)))
      {$ENDIF}
      else
        Result := '';
    else
      Result := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtra.GetIntFieldValue(const FieldID: TMovieField): Integer;
begin
  case FieldID of
    extraFieldNumber:
      Result := iNumber;
    else
      Result := -1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.SetFieldValue(const FieldID: TMovieField; const Value: string);
begin
  case FieldID of
    extraFieldChecked:      bChecked := ConvertFieldValue(Value, ftBoolean) = 'True';
    extraFieldTag:          strTag := Value;
    extraFieldTitle:        strTitle := Value;
    extraFieldCategory:     strCategory := Value;
    extraFieldURL:          strURL := Value;
    extraFieldDescription:  strDescription := Value;
    extraFieldComments:     strComments := Value;
    extraFieldCreatedBy:    strCreatedBy := Value;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtra.InCategory(Category: string
  {$IFDEF DLLMode}; const CategorySep: Char;
  const CategoryRemoveParenthesis: Boolean{$ENDIF}): Boolean;
var
  MultiValues: TStringList;
  i: Integer;
begin
  Result := False;
  Category := Trim(Category);
  if Category = '' then
    exit;
{$IFNDEF DLLMode}
  MultiValues := GetMultiValues(strCategory,
    Settings.rOptions.rExtraList.GroupMultiSep,
    Settings.rOptions.rExtraList.GroupMultiRmAllP, '', False);
{$ELSE}
  MultiValues := GetMultiValues(strCategory, CategorySep,
    CategoryRemoveParenthesis, '', False);
{$ENDIF}
  for i := 0 to MultiValues.Count-1 do
    if AnsiSameTextEx(Category, MultiValues.Strings[i], True) then
    begin
      Result := true;
      break;
    end;
  MultiValues.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.WriteData(const OutputFile: TStream;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer; const PicOperation: TMoviePictureOperation);
begin
  OutputFile.WriteBuffer(bChecked, boolsize);
  WriteString(strTag, OutputFile);
  WriteString(strTitle, OutputFile);
  WriteString(strCategory, OutputFile);
  WriteString(strURL, OutputFile);
  WriteString(strDescription, OutputFile);
  WriteString(strComments, OutputFile);
  WriteString(strCreatedBy, OutputFile);
  Picture.WriteData(OutputFile, CatalogFileSrc, CatalogFileDst, Version, PicOperation);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.ReadData(const InputFile: TStream;
  const Version: Integer; const LoadStoredPicture: Boolean);
begin
  InputFile.ReadBuffer(bChecked, boolsize);
  strTag := ReadString(InputFile);
  strTitle := ReadString(InputFile);
  strCategory := ReadString(InputFile);
  strURL := ReadString(InputFile);
  strDescription := ReadString(InputFile);
  strComments := ReadString(InputFile);
  strCreatedBy := ReadString(InputFile);
  Picture.ReadData(InputFile, Version, LoadStoredPicture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieExtra.SaveToXML(Root: TJvSimpleXmlElem;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer; const PicOperation: TMoviePictureOperation);
var
  i: Integer;
begin
  if (Root = nil) then
    Exit;
  for i := extraFieldLow to extraFieldCount-1 do
    AddNotEmpty(Root.Properties, strTagExtraFields[i - extraFieldLow],
    GetFieldValue(i, False, False, True));
  Picture.SaveToXML(Root, CatalogFileSrc, CatalogFileDst, Version, PicOperation);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtra.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
var
  i: Integer;
begin
  if (Root = nil) then
    Exit;
  for i := extraFieldLow to extraFieldCount-1 do
    if not (i in VirtualFields) then
      SetFieldValue(i, ReadTag(Root.Properties, strTagExtraFields[i - extraFieldLow],
        GetFieldValue(i), GetFieldType(i) = ftText {MultiLines}));
  Picture.LoadFromXML(Root, Version);
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TMovieExtras
-------------------------------------------------------------------------------}

constructor TMovieExtras.Create(Movie: TMovie);
begin
  inherited Create(True);
  Self.Movie := Movie;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieExtras.Destroy;
begin
  //
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.RenumberExtras(StartIndex: Integer);
var
  i: Integer;
begin
  for i := StartIndex to Count-1 do
    Items[i].iNumber := i+1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Notify(Ptr: Pointer; Action: TListNotification);
begin
  if (Action = lnAdded) then
    if TMovieExtra(Ptr) = Items[Count-1] then
      TMovieExtra(Ptr).iNumber := Count
    else
      RenumberExtras(0)
  else if (Action = lnDeleted) then
    RenumberExtras(TMovieExtra(Ptr).iNumber-1);
  inherited Notify(Ptr, Action);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Move(CurIndex, NewIndex: Integer);
begin
  inherited Move(CurIndex, NewIndex);
  RenumberExtras(Min(CurIndex, NewIndex));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Sort(Compare: TListSortCompare);
begin
  inherited Sort(Compare);
  RenumberExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.SetExtra(const idx: Integer; Value: TMovieExtra);
begin
  inherited Items[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.GetExtra(const idx: Integer): TMovieExtra;
begin
  Result := TMovieExtra(inherited Items[idx]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Assign(Extras: TMovieExtras);
var
  i: Integer;
  Extra: TMovieExtra;
begin
  // Free and clear objects
  Clear;
  // Make a copy and add objects!
  Capacity := Extras.Capacity;
  for i := 0 to Extras.Count - 1 do
  begin
    Extra := TMovieExtra.Create(Self);
    Extra.Assign(Extras.Items[i]);
    Add(Extra);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.AddExtra: Integer;
var
  Extra: TMovieExtra;
begin
  Extra := TMovieExtra.Create(Self);
  Result := Add(Extra);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.DeleteExtras(const Category: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := Count-1 downto 0 do
    if AnsiSameText(Items[i].strCategory, Category) then
    begin
      Delete(i);
      Result := True;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.FindExtra(Tag: string): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Count-1 do
    if AnsiSameText(Items[i].strTag, Tag) then
    begin
      Result := i;
      break;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.FindExtraAdv(Position: Integer; Category: string; Checked: string
  {$IFDEF DLLMode}; const CategorySep: Char;
  const CategoryRemoveParenthesis: Boolean{$ENDIF}): Integer;
var
  i, n: Integer;
  bChecked: Boolean;
begin
  Result := -1;
  if (Position < 1) or (Position > Count) then
    exit;
  if (Category = '') and (Checked = '') then
  begin
    Result := Position-1;
    exit;
  end;
  bChecked := not ((Checked = '') or (Checked = '0') or SameText(Checked, 'False'));
  n := 0;
  for i := 0 to Count-1 do
  begin
{$IFNDEF DLLMode}
    if ((Category = '') or (Items[i].InCategory(Category)))
{$ELSE}
    if ((Category = '') or (Items[i].InCategory(Category, CategorySep,
      CategoryRemoveParenthesis)))
{$ENDIF}
      and ((Checked = '') or (Items[i].bChecked = bChecked)) then
    begin
      Inc(n);
      if (n = Position) then
      begin
        Result := i;
        break;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.DeletePictures(const CatalogFile: string);
var
  i: Integer;
begin
  for i := 0 to Count-1 do
    Items[i].Picture.PictureOperation(CatalogFile, mpoDelete);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.GetFieldValues(const FieldID: TMovieField;
  const Separator: string;
  const LocalFormatSettings: Boolean;
  const ReturnEmptyIfFalse : Boolean;
  const ReturnEmptyIfVirtual: Boolean): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
  begin 
    if i > 0 then
      Result := Result + Separator;
    Result := Result + Items[i].GetFieldValue(FieldID, LocalFormatSettings,
      ReturnEmptyIfFalse, ReturnEmptyIfVirtual);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.GetPictureValues(const Separator: string;
  const StoredPictureText: string; const OnlyFileName: Boolean): string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Count-1 do
  begin 
    if i > 0 then
      Result := Result + Separator;
    if (Items[i].Picture.PicPath <> '') then
      if (Items[i].Picture.PicStream = nil) then
        if OnlyFilename then
          Result := Result + ExtractFileName(Items[i].Picture.PicPath)
        else
          Result := Result + Items[i].Picture.PicPath
      else
        Result := Result + StoredPictureText;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.SetFieldValues(const FieldID: TMovieField; Values: string;
  const Separator: string; Start: Integer;
  const AllowClears: Boolean;
  const AddMissingExtra: Boolean
{$IFNDEF DLLMode};
  const SetStatusAdded: Boolean;
  const ImportDefaultPicture: Boolean
{$ENDIF});
var
  list: TStringList;
  i: Integer;
begin
  if Start > Count then
    Start := Count;
  list := GetMultiValuesSimple(Values, Separator);
  for i := 0 to list.Count-1 do
  begin
    if (Start + i) = Count then
    begin
      if not AddMissingExtra then
        break;
      if AddExtra = -1 then
        break;
{$IFNDEF DLLMode}
      Items[Start + i]._bSelected := True;
      Items[Start + i].bChecked := True;
      Items[Start + i].Assign(Settings.rOptions.rMovieInformation.rDefaultExtra.Values, True, False, True);
      if ImportDefaultPicture then
        if Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath <> '' then
          try
            if (Movie <> nil) and (Movie.MovieList <> nil) then
              Items[Start + i].Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultExtra.Values.Picture.PicPath,
                Movie.MovieList.CurrentCatalogFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rExtraPicImport.GetInfoMethod)));
          except
          end;
      if SetStatusAdded then
        Items[Start + i]._iStatus := mesAdded;
{$ENDIF}
    end;
    if (list.Strings[i] <> '') or AllowClears then
      Items[Start + i].SetFieldValue(FieldID, list.Strings[i]);
  end;
  list.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.WriteData(const OutputFile: TStream;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer = 99;
  const PicOperation: TMoviePictureOperation = mpoUndefined);
var
  i,j: Integer;
begin
  j := Count;
  OutputFile.WriteBuffer(j, intsize);
  for i := 0 to j-1 do
  begin
    Items[i].WriteData(OutputFile, CatalogFileSrc, CatalogFileDst, Version, PicOperation);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.ReadData(const InputFile: TStream;
  const Version: Integer = 99;
  const LoadStoredPicture: Boolean = True);
var
  i, j, idx: Integer;
begin
  Clear;
  InputFile.ReadBuffer(j, intsize);
  for i := 0 to j-1 do
  begin
    idx := AddExtra;
    if idx <> -1 then
      Items[idx].ReadData(InputFile, Version, LoadStoredPicture);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFDEF MSWINDOWS}
function TMovieExtras.SaveToMemory: THandle;
var
  Stream: TMemoryStream;
  DataPtr: Pointer;
begin
  Stream := TMemoryStream.Create;
  try
    WriteData(Stream, '', '', 99);
    Stream.Seek(0, soFromBeginning);
    Result := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
    if Result <> 0 then
    begin
      DataPtr := GlobalLock(Result);
      if DataPtr <> nil then
      begin
        System.Move(Stream.Memory^, DataPtr^, Stream.Size);
      end;
    end;
  finally
    Stream.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

class procedure TMovieExtras.FreeMemory(DataHandle: THandle; OnlyUnlock: Boolean = False);
begin
  if DataHandle <> 0 then
  begin
    GlobalUnlock(DataHandle);
    if not OnlyUnlock then
      GlobalFree(DataHandle);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.LoadFromMemory(DataHandle: THandle);
var
  DataPtr: Pointer;
  DataSize: Integer;
  Stream: TMemoryStream;
begin
  if DataHandle <> 0 then
  begin
    DataPtr := GlobalLock(DataHandle);
    if DataPtr <> nil then
    begin
      Stream := TMemoryStream.Create;
      try
        DataSize := GlobalSize(DataHandle);
        Stream.SetSize(DataSize);
        System.Move(DataPtr^, stream.Memory^, DataSize);
        Stream.Seek(0, soFromBeginning);
        ReadData(Stream, 99, True);
      finally
        Stream.Free;
        GlobalUnlock(DataHandle);
      end;
    end;
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieExtras.SaveToXML(Root: TJvSimpleXmlElem;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer; const PicOperation: TMoviePictureOperation);
var
  i: Integer;
  Elem: TJvSimpleXmlElem;
begin
  if (Root = nil) then
    Exit;
  for i := 0 to Count-1 do
  begin
    Elem := Root.Items.Add('Extra');
    Items[i].SaveToXML(Elem, CatalogFileSrc, CatalogFileDst, Version, PicOperation);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
var
  i, idx: Integer;
begin
  Clear;
  if (Root = nil) then
    Exit;
  with Root.Items do
    for i := 0 to Count-1 do
      if(Item[i].Name = 'Extra') then
      begin
        idx := AddExtra;
        if idx <> -1 then
          Items[idx].LoadFromXML(Item[i], Version);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieExtras.GetExtrasByGroups(Field: Integer; OnlyGroups: Boolean): TStringList;
var
  Groups: TStringList;
  GroupExtras: TObjectList;
  MultiValues: TStringList;
  Extra: TMovieExtra;
  FieldValue, GroupName: string;
  Sep : Char;
  i, j, idx: Integer;
  bGroupMulti, bRmp : Boolean;
  // Args: IN [GroupName, Movie]
  procedure AddExtraToMap;
  begin
    if Length(GroupName) > 128 then
      GroupName := Copy(GroupName, 1, 128);
    GroupName := Trim(GroupName);
    if GroupName <> '' then
    begin
      idx := Groups.IndexOf(GroupName);
      if idx = -1 then
      begin
        if not OnlyGroups then
        begin
          GroupExtras := TObjectList.Create(False);
          GroupExtras.Add(Extra);
          Groups.AddObject(GroupName, GroupExtras);
        end else
          Groups.Add(GroupName);
      end else
      begin
        if not OnlyGroups then
        begin
          GroupExtras := TObjectList(Groups.Objects[idx]);
          if (not bGroupMulti) or (GroupExtras.IndexOf(Extra) = -1) then
            GroupExtras.Add(Extra);
        end;
      end;
    end;
  end;
begin
  with Settings.rOptions.rExtraList do
  begin
    bGroupMulti := GroupMulti and (Field in [extraFieldCategory]);
    Sep := GroupMultiSep;
    bRmP := GroupMultiRmAllP;
  end;
  Groups := TStringList.Create;
  Groups.Sorted := True;
  Groups.CaseSensitive := False;

  for i := 0 to Count-1 do
  begin
    Extra := TMovieExtra(Items[i]);
    with Extra do
    begin
      if Field <> -1 then // Extra Field
      begin
        FieldValue := GetFieldValue(Field);
        if (FieldValue = '') then
          FieldValue := '$$$EMPTY$$$';
      end else // No Field
      begin
        FieldValue := '$$$NOGROUP$$$';
      end;
      if (not bGroupMulti) then
      begin
        GroupName := FieldValue;
        AddExtraToMap;
      end else
      begin
        MultiValues := GetMultiValues(FieldValue, Sep, bRmP, strErrorParenthesis, False);
        for j := 0 to MultiValues.Count-1 do
        begin
          GroupName := MultiValues.Strings[j];
          AddExtraToMap;
        end;
        MultiValues.Free;
      end; // else bGroupMulti
    end; // end with Extra
  end; // end for
  Result := Groups;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Sort(const FieldsList: TStrings; Force: Boolean);
begin
  CompareExtrasAdvInit(FieldsList, Force);
  Sort(CompareExtrasAdv);
end;

procedure TMovieExtras.SortReverse(const FieldsList: TStrings; Force: Boolean);
begin
  CompareExtrasAdvInit(FieldsList, Force);
  Sort(CompareExtrasAdvReverse);
end;

{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieExtras.Sort(const Field: Integer; Force: Boolean);
begin
  CompareExtrasStdInit(Field, Force);
  Sort(CompareExtrasStd);
end;

procedure TMovieExtras.SortReverse(const Field: Integer; Force: Boolean);
begin
  CompareExtrasStdInit(Field, Force);
  Sort(CompareExtrasStdReverse);
end;

{-------------------------------------------------------------------------------
  TMovie
-------------------------------------------------------------------------------}

constructor TMovie.Create(MovieList: TMovieList);
begin
  inherited create;
  Self.MovieList := MovieList;
  Picture := TMoviePicture.Create(Self, nil);
  Extras := TMovieExtras.Create(Self);
  if MovieList <> nil then
    CustomFields := TCustomFields.Create(MovieList.CustomFieldsProperties, Self)
  else
    CustomFields := TCustomFields.Create(nil, Self);
{$IFNDEF DLLMode}
  _listItems := TObjectList.Create(False);
{$ENDIF}
  InitFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovie.Destroy;
begin
  Picture.Free;
  Extras.Free;
  CustomFields.Free;
{$IFNDEF DLLMode}
  _listItems.Free;
{$ENDIF}
  inherited destroy;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.InitFields;
begin
  iNumber := 0;
  bChecked := False;
  iColorTag := 0;
  strMedia := '';
  strMediaType := '';
  strSource := '';
  iDate := 0;
  strBorrower := '';
  iDateWatched := 0;
  iUserRating := -1;
  iRating := -1;
  strOriginalTitle := '';
  strTranslatedTitle := '';
  strDirector := '';
  strProducer := '';
  strWriter := '';
  strComposer := '';
  strActors := '';
  strCountry := '';
  iYear := -1;
  iLength := -1;
  strCategory := '';
  strCertification := '';
  strURL := '';
  strDescription := '';
  strComments := '';
  strFilePath := '';
  strVideoFormat := '';
  iVideoBitrate := -1;
  strAudioFormat := '';
  iAudioBitrate := -1;
  strResolution := '';
  strFramerate := '';
  strLanguages := '';
  strSubtitles := '';
  strSize := '';
  iDisks := -1;
  Picture.Init;
{$IFNDEF DLLMode}
  _bSelected := False;
  _bVisible := True;
{$ENDIF}
  Extras.Clear;
  CustomFields.Clear;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.Assign(AMovie: TMovie; IncludeNumber: Boolean; IncludePicture: Boolean;
      IncludeExtras: Boolean; IncludeCustomFields: Boolean; IncludeListValues: Boolean);
begin
  if IncludeNumber then
    iNumber := AMovie.iNumber;
  if IncludeListValues then
  begin
    bChecked := AMovie.bChecked;
    iColorTag := AMovie.iColorTag mod Length(DefaultColorsTag);
  end;
  strMedia := AMovie.strMedia;
  strMediaType := AMovie.strMediaType;
  strSource := AMovie.strSource;
  iDate := AMovie.iDate;
  strBorrower := AMovie.strBorrower;
  iDateWatched := AMovie.iDateWatched;
  iUserRating := AMovie.iUserRating;
  iRating := AMovie.iRating;
  strOriginalTitle := AMovie.strOriginalTitle;
  strTranslatedTitle := AMovie.strTranslatedTitle;
  strDirector := AMovie.strDirector;
  strProducer := AMovie.strProducer;
  strWriter := AMovie.strWriter;
  strComposer := AMovie.strComposer;
  strActors := AMovie.strActors;
  strCountry := AMovie.strCountry;
  iYear := AMovie.iYear;
  iLength := AMovie.iLength;
  strCategory := AMovie.strCategory;
  strCertification := AMovie.strCertification;
  strURL := AMovie.strURL;
  strDescription := AMovie.strDescription;
  strComments := AMovie.strComments;
  strFilePath := AMovie.strFilePath;
  strVideoFormat := AMovie.strVideoFormat;
  iVideoBitrate := AMovie.iVideoBitrate;
  strAudioFormat := AMovie.strAudioFormat;
  iAudioBitrate := AMovie.iAudioBitrate;
  strResolution := AMovie.strResolution;
  strFramerate := AMovie.strFramerate;
  strLanguages := AMovie.strLanguages;
  strSubtitles := AMovie.strSubtitles;
  strSize := AMovie.strSize;
  iDisks := AMovie.iDisks;

  if IncludePicture then
    Picture.Assign(AMovie.Picture);

  if IncludeExtras then
    Extras.Assign(AMovie.Extras);

  if IncludeCustomFields then
    CustomFields.Assign(AMovie.CustomFields);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.GetFieldValue(const FieldID: TMovieField;
  const LocalFormatSettings: Boolean;
  const ReturnEmptyIfFalse : Boolean;
  const ReturnEmptyIfVirtual: Boolean): string;
begin
  Result := '';
  if ReturnEmptyIfVirtual and (FieldID in VirtualFields) then
    exit;
  case FieldID of
    fieldNumber:          Result := IntToStr(iNumber);
    fieldChecked:
      begin
        Result := BoolToStr(bChecked, True);
        if ReturnEmptyIfFalse and not bChecked then
          Result := '';
      end;
    fieldColorTag:        Result := IntToStr(iColorTag);
    fieldMedia:           Result := strMedia;
    fieldMediaType:       Result := strMediaType;
    fieldSource:          Result := strSource;
    fieldDate:
      if iDate > 0 then
      begin
        if not LocalFormatSettings then
          Result := DateToStr(iDate, FormatSettings)
        else
          Result := DateToStr(iDate);
      end else
        Result := '';
    fieldBorrower:        Result := strBorrower;
    fieldDateWatched:
      if iDateWatched > 0 then
      begin
        if not LocalFormatSettings then
          Result := DateToStr(iDateWatched, FormatSettings)
        else
          Result := DateToStr(iDateWatched);
      end else
        Result := '';
    fieldUserRating:
      if iUserRating = -1 then
        Result := ''
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := IntToStr(iUserRating div 10)
        else
        {$ENDIF}
          if not LocalFormatSettings then
            Result := FormatFloat('#0.0', iUserRating / 10, FormatSettings)
          else
            Result := FormatFloat('#0.0', iUserRating / 10);
      end;
    fieldRating:
      if iRating = -1 then
        Result := ''
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := IntToStr(iRating div 10)
        else
        {$ENDIF}
          if not LocalFormatSettings then
            Result := FormatFloat('#0.0', iRating / 10, FormatSettings)
          else
            Result := FormatFloat('#0.0', iRating / 10);
      end;
    fieldOriginalTitle:   Result := strOriginalTitle;
    fieldTranslatedTitle: Result := strTranslatedTitle;
    fieldFormattedTitle:  Result := GetFormattedTitle;
    fieldDirector:        Result := strDirector;
    fieldProducer:        Result := strProducer;
    fieldWriter:          Result := strWriter;
    fieldComposer:        Result := strComposer;
    fieldActors:          Result := strActors;
    fieldCountry:         Result := strCountry;
    fieldYear:
      if iYear = -1 then
        Result := ''
      else
        Result := IntToStr(iYear);
    fieldLength:
      if iLength = -1 then
        Result := ''
      else
        Result := IntToStr(iLength);
    fieldCategory:        Result := strCategory;
    fieldCertification:   Result := strCertification;
    fieldURL:             Result := strURL;
    fieldDescription:     Result := strDescription;
    fieldComments:        Result := strComments;
    fieldFilePath:        Result := strFilePath;
    fieldVideoFormat:     Result := strVideoFormat;
    fieldAudioFormat:     Result := strAudioFormat;
    fieldVideoBitrate:
      if iVideoBitrate = -1 then
        Result := ''
      else
        Result := IntToStr(iVideoBitrate);
    fieldAudioBitrate:
      if iAudioBitrate = -1 then
        Result := ''
      else
        Result := IntToStr(iAudioBitrate);
    fieldResolution:      Result := strResolution;
    fieldFramerate:       Result := strFramerate;
    fieldLanguages:       Result := strLanguages;
    fieldSubtitles:       Result := strSubtitles;
    fieldSize:            Result := strSize;
    fieldDisks:
      if iDisks = -1 then
        Result := ''
      else
        Result := IntToStr(iDisks);
    fieldPictureStatus:
      if (MovieList <> nil) then
      {$IFNDEF DLLMode}
        Result := strPictureStatus[Integer(Picture.GetPictureStatus(MovieList.CurrentCatalogFile))]
      {$ELSE}
        Result := IntToStr(Integer(Picture.GetPictureStatus(MovieList.CurrentCatalogFile)))
      {$ENDIF}
      else
        Result := '';
    fieldNbExtras:
      Result := IntToStr(Extras.Count);
    else
      Result := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.GetIntFieldValue(const FieldID: TMovieField): Integer;
begin
  case FieldID of
    fieldNumber:          Result := iNumber;
    fieldColorTag:        Result := iColorTag;
    fieldDate:            Result := iDate;
    fieldDateWatched:     Result := iDateWatched;
    fieldUserRating:
      if iUserRating = -1 then
        Result := -1
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := iUserRating div 10
        else
        {$ENDIF}
          Result := iUserRating;
      end;
    fieldRating:
      if iRating = -1 then
        Result := -1
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := iRating div 10
        else
        {$ENDIF}
          Result := iRating;
      end;
    fieldYear:            Result := iYear;
    fieldLength:          Result := iLength;
    fieldVideoBitrate:    Result := iVideoBitrate;
    fieldAudioBitrate:    Result := iAudioBitrate;
    fieldDisks:           Result := iDisks;
    fieldNbExtras:        Result := Extras.Count;
    else
      Result := -1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.GetFloatFieldValue(const FieldID: TMovieField): Double;
begin
  case FieldID of
    fieldNumber:          Result := iNumber;
    fieldColorTag:        Result := iColorTag;
    fieldDate:            Result := iDate;
    fieldDateWatched:     Result := iDateWatched;
    fieldUserRating:
      if iUserRating = -1 then
        Result := -1
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := iUserRating div 10
        else
        {$ENDIF}
          Result := iUserRating;
      end;
    fieldRating:
      if iRating = -1 then
        Result := -1
      else
      begin
        {$IFNDEF DLLMode}
        if Settings.rOptions.rMovieInformation.RatingTrunc then
          Result := iRating div 10
        else
        {$ENDIF}
          Result := iRating / 10;
      end;
    fieldYear:            Result := iYear;
    fieldLength:          Result := iLength;
    fieldVideoBitrate:    Result := iVideoBitrate;
    fieldAudioBitrate:    Result := iAudioBitrate;
    fieldDisks:           Result := iDisks;
    fieldNbExtras:        Result := Extras.Count;
    else
      Result := -1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.SetFieldValue(const FieldID: TMovieField; const Value: string);
var
  f: Double;
begin
  case FieldID of
    fieldNumber:          iNumber := StrToIntDef(Value, 0);
    fieldChecked:         bChecked := ConvertFieldValue(Value, ftBoolean) = 'True';
    fieldColorTag:        iColorTag := StrToIntDef(Value, 0) mod Length(DefaultColorsTag);
    fieldMedia:           strMedia := Value;
    fieldMediaType:       strMediaType := Value;
    fieldSource:          strSource := Value;
    fieldDate:            iDate := Trunc(StrToDateDef(ConvertFieldValue(Value, ftDate), 0, FormatSettings));
    fieldBorrower:        strBorrower := value;
    fieldDateWatched:     iDateWatched := Trunc(StrToDateDef(ConvertFieldValue(Value, ftDate), 0, FormatSettings));
    fieldUserRating:
    begin
      f := StrToFloatDef(ConvertFieldValue(Value, ftReal1), -1, FormatSettings);
      if f = -1 then
        iUserRating := -1
      else
        iUserRating := Round(f * 10);
    end;
    fieldRating:
    begin
      f := StrToFloatDef(ConvertFieldValue(Value, ftReal1), -1, FormatSettings);
      if f = -1 then
        iRating := -1
      else
        iRating := Round(f * 10);
    end;
    fieldOriginalTitle:   strOriginalTitle := Value;
    fieldTranslatedTitle: strTranslatedTitle := Value;
    fieldDirector:        strDirector := Value;
    fieldProducer:        strProducer := Value;
    fieldWriter:          strWriter := Value;
    fieldComposer:        strComposer := Value;
    fieldActors:          strActors := Value;
    fieldCountry:         strCountry := Value;
    fieldYear:            iYear := StrToIntDef(Value, -1);
    fieldLength:          iLength := StrToIntDef(Value, -1);
    fieldCategory:        strCategory := Value;
    fieldCertification:   strCertification := Value;
    fieldURL:             strURL := Value;
    fieldDescription:     strDescription := Value;
    fieldComments:        strComments := Value;
    fieldFilePath:        strFilePath := Value;
    fieldVideoFormat:     strVideoFormat := Value;
    fieldAudioFormat:     strAudioFormat := Value;
    fieldVideoBitrate:    iVideoBitrate := StrToIntDef(Value, -1);
    fieldAudioBitrate:    iAudioBitrate := StrToIntDef(Value, -1);
    fieldResolution:      strResolution := Value;
    fieldFrameRate:       strFramerate := Value;
    fieldLanguages:       strLanguages := Value;
    fieldSubtitles:       strSubtitles := Value;
    fieldSize:            strSize := Value;
    fieldDisks:           iDisks := StrToIntDef(Value, -1);
  end; // case
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.GetFormattedTitle: string;
begin
  {$IFNDEF DLLMode}
  with Settings.rOptions.rMovieList do
    Result := GetFormattedTitle(TitleColumn, UsePrefixes, TitleTemplate);
  {$ELSE}
  if strOriginalTitle = '' then
    Result := strTranslatedTitle
  else
  if strTranslatedTitle = '' then
    Result := strOriginalTitle
  else
    Result := strOriginalTitle + ' (' + strTranslatedTitle + ')';
  {$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
function TMovie.GetFormattedTitle(DisplayType: Integer;
  const UsePrefixes: Boolean; const TitleTemplate: string): string;
var
  OriginalTitle, TranslatedTitle: string;
begin
  Result := '';
  if not (DisplayType in [0..5]) then
    DisplayType := Settings.rOptions.rMovieList.TitleColumn;
  OriginalTitle := strOriginalTitle;
  TranslatedTitle := strTranslatedTitle;
  if UsePrefixes and (DisplayType <> 5) then
  begin
    OriginalTitle := PrefixValue(OriginalTitle, Settings.rOptions.rMovieList.Prefixes);
    TranslatedTitle := PrefixValue(TranslatedTitle, Settings.rOptions.rMovieList.Prefixes);
  end;

  case DisplayType of
    0:
      begin // Original title only
        Result := OriginalTitle;
      end;
    1:
      begin // Translated title if available
        if TranslatedTitle <> '' then
          Result := TranslatedTitle
        else
          Result := OriginalTitle;
      end;
    2:
      begin // "Original title (translated title)"
          if TranslatedTitle = '' then
            Result := OriginalTitle
          else
          if OriginalTitle = '' then
            Result := TranslatedTitle
          else
            Result := OriginalTitle + ' (' + TranslatedTitle + ')';
      end;
    3:
      begin // "Translated title (original title)"
          if OriginalTitle = '' then
            Result := TranslatedTitle
          else
          if TranslatedTitle = '' then
            Result := OriginalTitle
          else
            Result := TranslatedTitle + ' (' + OriginalTitle + ')';
      end;
    4:
      begin
        Result := strMedia;
      end;
    5:
      begin
        if UsePrefixes then
          Result := GetValueFromTemplate(TitleTemplate, Settings.rOptions.rMovieList.Prefixes, True)
        else
          Result := GetValueFromTemplate(TitleTemplate, nil, True);
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.GetFields(MovieFields: PMovie30);
begin
  if MovieFields <> nil then
  begin
    FillChar(MovieFields^,sizeof(MovieFields^),' ');
    with MovieFields^ do
    begin
      iNumber := self.iNumber;
      strOriginalTitle := self.strOriginalTitle;
      strTranslatedTitle := self.strTranslatedTitle;
      strDirector := self.strDirector;
      strProducer := self.strProducer;
      strCountry := self.strCountry;
      iYear := self.iYear;
      strCategory := self.strCategory;
      iLength := self.iLength;
      strActors := self.strActors;
      strURL := self.strURL;
      StrLCopy(@(strDescription)[1],PChar(self.strDescription),sizeof(strDescription));
      strComments := self.strComments;
      strVideoFormat := self.strVideoFormat;
      strSize := self.strSize;
      strResolution := self.strResolution;
      strLanguages := self.strLanguages;
      strSubtitles := self.strSubtitles;
      iRating := self.iRating;
      bChecked := self.bChecked;
      iDate := self.iDate;
      strPicture := Picture.PicPath;
      if Picture.PicStream = nil then
        iPictureSize := 0
      else
        iPictureSize := Picture.PicStream.Size;
      strBorrower := self.strBorrower;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.SetFields(MovieFields: PMovie30);
begin
  if MovieFields <> nil then
  begin
    with MovieFields^ do
    begin
      self.iNumber := iNumber;
      self.strOriginalTitle := strOriginalTitle;
      self.strTranslatedTitle := strTranslatedTitle;
      self.strDirector := strDirector;
      self.strProducer := strProducer;
      self.strCountry := strCountry;
      if iYear = 1 then
        self.iYear := -1
      else
        self.iYear := iYear;
      self.strCategory := strCategory;
      if iLength = 1 then
        self.iLength := -1
      else
        self.iLength := iLength;
      self.strActors := strActors;
      if strURL = 'http://' then
        self.strURL := ''
      else
        self.strURL := strURL;
      self.strDescription := strDescription;
      self.strComments := strComments;
      self.strVideoFormat := strVideoFormat;
      self.strSize := strSize;
      self.strResolution := strResolution;
      self.strLanguages := strLanguages;
      self.strSubtitles := strSubtitles;
      self.iRating := iRating;
      self.bChecked := bChecked;
      self.iDate := iDate;
      self.Picture.PicPath := strPicture;
      self.strBorrower := strBorrower;
    end;
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.GetValueFromTemplate(const Template: string;
  const TitlePrefixes: TStringList;
  const LocalFormatSettings: Boolean;
  const FormatValueFunction: TFormatValueFunction): string;
var
  Properties: TCustomFieldProperties;
  OriginalTitle, TranslatedTitle: string;
  i, len, p, pfound, idx: Integer;
  tag, value: string;
begin
  len := Length(Template);
  if (len = 0) then
  begin
    Result := '';
    Exit;
  end;
  OriginalTitle := strOriginalTitle;
  TranslatedTitle := strTranslatedTitle;
  if TitlePrefixes <> nil then
  begin
    OriginalTitle := PrefixValue(OriginalTitle, TitlePrefixes);
    TranslatedTitle := PrefixValue(TranslatedTitle, TitlePrefixes);
  end;
  i := 1;
  p := 1;
  pfound := 0;
  Result := '';
  while i <= len do
  begin
    if Template[i] = '[' then
      pfound := i;
    if (Template[i] = ']') and (pfound > 0) then
    begin
      tag := copy(Template, pfound + 1, i - pfound - 1);
      idx := IndexText(tag, strTagFields);
      if idx >= 0 then
      begin
        if not (idx = fieldFormattedTitle) then
        begin
          Result := Result + copy(Template, p, pfound - p);
          if idx = fieldOriginalTitle then
            value := OriginalTitle
          else if idx = fieldTranslatedTitle then
            value := TranslatedTitle
          else
            value := GetFieldValue(idx, LocalFormatSettings);
          if Assigned(FormatValueFunction) then
            value := FormatValueFunction(value);
          Result := Result + value;
          p := i + 1;
        end;
      end
      else if CustomFields.Properties <> nil then
      begin
        Properties := CustomFields.Properties.GetField(tag);
        if Properties <> nil then
        begin
          if Properties.FieldType <> ftVirtual then
          begin
            Result := Result + copy(Template, p, pfound - p);
            value := CustomFields.GetFieldValue(tag, LocalFormatSettings);
            if Assigned(FormatValueFunction) then
              value := FormatValueFunction(value);
            Result := Result + value;
            p := i + 1;
          end;
        end;
      end;
      pfound := 0;
    end;
    i := i + 1;
  end;
  if p <= len then
    Result := Result + copy(Template, p, len - p + 1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.CalcTotalSize: Int64;
var
  i: Integer;
  s: string;
begin
  i := 1;
  Result := 0;
  s := strSize;
  while i <= Length(s) do
  begin
    if s[i] in ['0'..'9'] then
      Inc(i)
    else
    begin
      if i > 1 then
        Inc(Result, StrToIntDef(Copy(s, 1, i - 1), 0));
      Delete(s, 1, i);
      i := 1;
    end;
  end;
  if i > 1 then
    Inc(Result, StrToIntDef(Copy(s, 1, i - 1), 0));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.ContainsText(const Value: string; const Field: Integer;
  const WholeField: Boolean): Boolean;
var
  i: Integer;
  FieldProperties: TCustomFieldProperties;
begin
  Result := False;
  if Field in AllFields then
  begin
    Result := ((WholeField) and AnsiSameTextEx(GetFieldValue(Field, True), Value, True))
      or ((not WholeField) and ((Value = '') or AnsiContainsTextEx(GetFieldValue(Field, True), Value, True)));
  end
  else
  if Field in AllCustomFields then
  begin
    if (CustomFields.Properties <> nil) and
      ((Field - customFieldLow) < CustomFields.Properties.Count) then
    begin
      FieldProperties := CustomFields.Properties.Objects[Field - customFieldLow];
      Result := ((WholeField) and AnsiSameTextEx(CustomFields.GetFieldValue(FieldProperties.FieldTag, True), Value, True))
        or ((not WholeField) and ((Value = '') or AnsiContainsTextEx(CustomFields.GetFieldValue(FieldProperties.FieldTag, True), Value, True)))
    end;
  end
  else
  if Field in AllExtraFields then
  begin
    for i := 0 to Extras.Count-1 do
    begin
      Result := ((WholeField) and AnsiSameTextEx(Extras.Items[i].GetFieldValue(Field, True), Value, True))
        or ((not WholeField) and ((Value = '') or AnsiContainsTextEx(Extras.Items[i].GetFieldValue(Field, True), Value, True)));
      if Result then
        break;
    end;
  end
  else
  if Field = -1 then
  begin
    for i := fieldLow to fieldCount-1 do
      //if not (i in VirtualFields) then
        if ContainsText(Value, i, WholeField) then
        begin
          Result := True;
          Exit;
        end;
    if (CustomFields.Properties <> nil) then
      with CustomFields.Properties do
        for i := 0 to Count-1 do
          //if Objects[i].FieldType <> ftVirtual then
            if ContainsText(Value, customFieldLow+i, WholeField) then
            begin
              Result := True;
              Exit;
            end;
    for i := extraFieldLow to extraFieldCount-1 do
      //if not (i in VirtualFields) then
        if ContainsText(Value, i, WholeField) then
        begin
          Result := True;
          Exit;
        end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovie.CanInclude(const IncOpt: TMovieIncludeOption): Boolean;
begin
  case IncOpt of
    mioChecked:     Result := Self.bChecked;
{$IFNDEF DLLMode}
    mioSelected:    Result := Self._bSelected;
    mioVisible:     Result := Self._bVisible;
{$ENDIF}
  else
    Result := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.CheckURLFields(const CatalogFileSrc: TFileName;
  const CatalogFileDst: TFileName);
var
  i: Integer;
  NewRelativeLink: string;

  function GetNewRelativeLink(const FileName: string): string;
  var
    FullName: string;
  begin
    Result := '';
    // Check if it is a relative link
    if (FileName <> '') and (ExtractFileDrive(FileName) = '') and
      not StartsText('http://', FileName) then
    begin
      FullName := ExpandFileName(FileName);
      if FileExists(FullName) then
        Result := ExtractRelativePath(ExtractFilePath(CatalogFileDst),
          ExtractFilePath(FullName)) + ExtractFileName(FullName);
    end;
  end;
begin
  if (CatalogFileSrc <> '') and (CatalogFileDst <> '') and
    not SameFileName(ExtractFilePath(CatalogFileSrc), ExtractFilePath(CatalogFileDst)) then
  begin
    SetCurrentDir(ExtractFilePath(CatalogFileSrc));

    NewRelativeLink := GetNewRelativeLink(GetFieldValue(fieldUrl));
    if NewRelativeLink <> '' then
      SetFieldValue(fieldUrl, NewRelativeLink);

    NewRelativeLink := GetNewRelativeLink(GetFieldValue(fieldFilePath));
    if NewRelativeLink <> '' then
      SetFieldValue(fieldFilePath, NewRelativeLink);

    if CustomFields.Properties <> nil then
      for i := 0 to CustomFields.Properties.Count-1 do
      begin
        if CustomFields.Properties[i].FieldType = ftURL then
        begin
          NewRelativeLink := GetNewRelativeLink(CustomFields.GetFieldValue(CustomFields.Properties[i].FieldTag));
          if NewRelativeLink <> '' then
            SetFieldValue(fieldUrl, NewRelativeLink);
        end;
      end;

    for i := 0 to Extras.Count-1 do
    begin
      NewRelativeLink := GetNewRelativeLink(Extras.Items[i].strURL);
      if NewRelativeLink <> '' then
        SetFieldValue(fieldUrl, NewRelativeLink);
    end;

  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.WriteData(const OutputFile: TStream;
  const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer;
  const Standalone: Boolean;
  const PicOperation: TMoviePictureOperation;
  const ExtraPicOperation: TMoviePictureOperation);
begin
  with OutputFile do
  begin
    CheckURLFields(CatalogFileSrc, CatalogFileDst);

    WriteBuffer(iNumber, intsize);
    WriteBuffer(iDate, intsize);
    if (Version >= 42) then
      WriteBuffer(iDateWatched, intsize);
    if (Version >= 42) then
      WriteBuffer(iUserRating, intsize);
    WriteBuffer(iRating, intsize);
    WriteBuffer(iYear, intsize);
    WriteBuffer(iLength, intsize);
    WriteBuffer(iVideoBitrate, intsize);
    WriteBuffer(iAudioBitrate, intsize);
    WriteBuffer(iDisks, intsize);
    if (Version >= 41) then
      WriteBuffer(iColorTag, intsize);
    WriteBuffer(bChecked, boolsize);
    WriteString(strMedia, OutputFile);
    WriteString(strMediaType, OutputFile);
    WriteString(strSource, OutputFile);
    WriteString(strBorrower, OutputFile);
    WriteString(strOriginalTitle, OutputFile);
    WriteString(strTranslatedTitle, OutputFile);
    WriteString(strDirector, OutputFile);
    WriteString(strProducer, OutputFile);
    if (Version >= 42) then
      WriteString(strWriter, OutputFile);
    if (Version >= 42) then
      WriteString(strComposer, OutputFile);
    WriteString(strCountry, OutputFile);
    WriteString(strCategory, OutputFile);
    if (Version >= 42) then
      WriteString(strCertification, OutputFile);
    WriteString(strActors, OutputFile);
    WriteString(strURL, OutputFile);
    WriteString(strDescription, OutputFile);
    WriteString(strComments, OutputFile);
    if (Version >= 42) then
      WriteString(strFilePath, OutputFile);
    WriteString(strVideoFormat, OutputFile);
    WriteString(strAudioFormat, OutputFile);
    WriteString(strResolution, OutputFile);
    WriteString(strFramerate, OutputFile);
    WriteString(strLanguages, OutputFile);
    WriteString(strSubtitles, OutputFile);
    WriteString(strSize, OutputFile);

    Picture.WriteData(OutputFile, CatalogFileSrc, CatalogFileDst, Version, PicOperation);

    if (Version >= 40) then
      CustomFields.WriteData(OutputFile, Version, Standalone);

    if (Version >= 42) then
      Extras.WriteData(OutputFile, CatalogFileSrc, CatalogFileDst, Version, ExtraPicOperation);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.ReadData(const InputFile: TStream; const Version: Integer;
  const Standalone: Boolean; const LoadStoredPicture: Boolean);
begin
  with InputFile do
  begin
    ReadBuffer(iNumber, intsize);
    ReadBuffer(iDate, intsize);
    if (Version >= 42) then
      ReadBuffer(iDateWatched, intsize);
    if (Version >= 42) then
      ReadBuffer(iUserRating, intsize);
    ReadBuffer(iRating, intsize);
    if (Version < 35) and (iRating <> -1) then
      iRating := iRating * 10;
    ReadBuffer(iYear, intsize);
    ReadBuffer(iLength, intsize);
    ReadBuffer(iVideoBitrate, intsize);
    ReadBuffer(iAudioBitrate, intsize);
    ReadBuffer(iDisks, intsize);
    if (Version >= 41) then
    begin
      ReadBuffer(iColorTag, intsize);
      iColorTag := iColorTag mod Length(DefaultColorsTag);
    end;
    ReadBuffer(bChecked, boolsize);
    strMedia := ReadString(InputFile);
    if Version >= 33 then
    begin
      strMediaType := ReadString(InputFile);
      strSource := ReadString(InputFile);
    end else
    begin
      strMediaType := '';
      strSource := '';
    end;
    strBorrower := ReadString(InputFile);
    strOriginalTitle := ReadString(InputFile);
    strTranslatedTitle := ReadString(InputFile);
    strDirector := ReadString(InputFile);
    strProducer := ReadString(InputFile);
    if (Version >= 42) then
      strWriter := ReadString(InputFile);
    if (Version >= 42) then
      strComposer := ReadString(InputFile);
    strCountry := ReadString(InputFile);
    strCategory := ReadString(InputFile);
    if (Version >= 42) then
      strCertification := ReadString(InputFile);
    strActors := ReadString(InputFile);
    strURL := ReadString(InputFile);
    strDescription := ReadString(InputFile);
    strComments := ReadString(InputFile);
    if (Version >= 42) then
      strFilePath := ReadString(InputFile);
    strVideoFormat := ReadString(InputFile);
    strAudioFormat := ReadString(InputFile);
    strResolution := ReadString(InputFile);
    strFramerate := ReadString(InputFile);
    strLanguages := ReadString(InputFile);
    strSubtitles := ReadString(InputFile);
    strSize := ReadString(InputFile);

    Picture.ReadData(InputFile, Version, LoadStoredPicture);

    if (Version >= 40) then
      CustomFields.ReadData(InputFile, Version, Standalone);

    if (Version >= 42) then
      Extras.ReadData(InputFile, Version, LoadStoredPicture);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFDEF MSWINDOWS}
function TMovie.SaveToMemory: THandle;
var
  Stream: TMemoryStream;
  DataPtr: Pointer;
begin
  Stream := TMemoryStream.Create;
  try
    WriteData(Stream, '', '', 99, True);
    Stream.Seek(0, soFromBeginning);
    Result := GlobalAlloc(GMEM_MOVEABLE, Stream.Size);
    if Result <> 0 then
    begin
      DataPtr := GlobalLock(Result);
      if DataPtr <> nil then
      begin
        Move(Stream.Memory^, DataPtr^, Stream.Size);
      end;
    end;
  finally
    Stream.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

class procedure TMovie.FreeMemory(DataHandle: THandle; OnlyUnlock: Boolean = False);
begin
  if DataHandle <> 0 then
  begin
    GlobalUnlock(DataHandle);
    if not OnlyUnlock then
      GlobalFree(DataHandle);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.LoadFromMemory(DataHandle: THandle);
var
  DataPtr: Pointer;
  DataSize: Integer;
  Stream: TMemoryStream;
begin
  if DataHandle <> 0 then
  begin
    DataPtr := GlobalLock(DataHandle);
    if DataPtr <> nil then
    begin
      Stream := TMemoryStream.Create;
      try
        DataSize := GlobalSize(DataHandle);
        Stream.SetSize(DataSize);
        Move(DataPtr^, stream.Memory^, DataSize);
        Stream.Seek(0, soFromBeginning);
        ReadData(Stream, 99, True);
      finally
        Stream.Free;
        GlobalUnlock(DataHandle);
      end;
    end;
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
{We export virtual field FormattedTitle for backward compatibilty
 of others applications but it is not used by AMC.
 If Version = 100 then we don't export virtual field FormattedTitle (used to save default values)}
procedure TMovie.SaveToXML(Root: TJvSimpleXmlElem;
  const CatalogFileSrc: string; const CatalogFileDst: string; const Version: Integer;
  const PicOperation: TMoviePictureOperation;
  const ExtraPicOperation: TMoviePictureOperation);
var
  i: Integer;
begin
  if Root = nil then
    raise Exception.Create('TMovie.SaveToXML : nil element');

  CheckURLFields(CatalogFileSrc, CatalogFileDst);

  for i := 0 to fieldCount-1 do
    AddNotEmpty(Root.Properties, strTagFields[i], GetFieldValue(i, False, False,
      (Version = 100) or (i <> fieldFormattedTitle)));

  Picture.SaveToXML(Root, CatalogFileSrc, CatalogFileDst, Version, PicOperation);

  if CustomFields.Count > 0 then
    CustomFields.SaveToXML(Root.Items.Add('CustomFields'), CatalogFileDst, Version);

  if Extras.Count > 0 then
    Extras.SaveToXML(Root.Items.Add('Extras'), CatalogFileSrc, CatalogFileDst, Version, ExtraPicOperation);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovie.LoadFromXML(Root: TJvSimpleXmlElem; const Version: Integer);
var
  i: Integer;
begin
  if Root = nil then
    raise Exception.Create('TMovie.LoadFromXML : nil element');
  for i := 0 to fieldCount-1 do
    if not (i in VirtualFields) then
      SetFieldValue(i, ReadTag(Root.Properties, strTagFields[i], GetFieldValue(i), GetFieldType(i) = ftText {MultiLines}));
  Picture.LoadFromXML(Root, Version);
//  if (Version < 35) and (iRating <> -1) then
//    iRating := iRating * 10;
  with Root.Items do
    for i := 0 to Count-1 do
      if Item[i].Name = 'CustomFields' then
        CustomFields.LoadFromXML(Item[i], Version)
      else if Item[i].Name = 'Extras' then
        Extras.LoadFromXML(Item[i], Version);
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TMovieFilter
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
constructor TMovieFilter.Create;
begin
  Field := -1;
  Value := '';
  WholeField := False;
  Reverse := False;
  SearchExpression := nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieFilter.Destroy;
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieFilter.Match(Movie: TMovie): Boolean;
begin
  Result := False;
  if Movie = nil then
    Exit;
  if SearchExpression <> nil then
    Result := (Value = '') or (SearchExpression.EvalAsBoolean(Movie))
  else
    Result := Movie.ContainsText(Value, Field, WholeField);
  Result := (Result and not Reverse) or (not Result and Reverse);
end;
{$ENDIF}

{------------------------------------------------------------------------------
  TExprVarMovieParser
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}

constructor TExprVarMovieParser.Create(MovieList: TMovieList);
begin
  Self.MovieList := MovieList;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TExprVarMovieParser.Destroy;
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprVarMovieParser.IsVar(Expression: string): Boolean;
begin
  Result := GetVarId(Expression) <> '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprVarMovieParser.GetVarId(Expression: string): string;
var
  len, Idx: Integer;
  Tag: string;
begin
  Result := '';
  if Expression = '' then
    exit;
  len := Length(Expression);
  if (Expression[1] <> '[') or (Expression[len] <> ']') then
    exit;
  Tag := Copy(Expression, 2, len-2);
  Idx := IndexText(Tag, strTagFields);
  if Idx in AllFields then
    Result := IntToStr(Idx)
  else if (MovieList <> nil) then
  begin
    Idx := MovieList.CustomFieldsProperties.IndexOf(Tag);
    if (Idx <> -1) then
      Result := Tag;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprVarMovieParser.GetVarValue(VarId: string; VarObject: TObject): string;
var
  Idx: Integer;
  Movie: TMovie;
begin
  Result := '';
  Movie := TMovie(VarObject);
  if (VarId = '') or (Movie = nil) then
    exit;
  if VarId[1] in ['0'..'9'] then
  begin
    Idx := StrToIntDef(VarId, -1);
    Result := Movie.GetFieldValue(Idx, True, False, False);
  end
  else if (MovieList <> nil) then
  begin
    Result := Movie.CustomFields.GetFieldValue(VarId, True, False, False);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TExprVarMovieParser.GetVarType(VarId: string; VarObject: TObject): TExprType;
var
  Idx: Integer;
  FieldType: Integer;
begin
  Result := etyNone;
  FieldType := -1;
  if (VarId = '') then
    exit;
  if VarId[1] in ['0'..'9'] then
  begin
    Idx := StrToIntDef(VarId, -1);
    FieldType := Integer(GetFieldType(Idx));
  end
  else if (MovieList <> nil) then
  begin
    Idx := MovieList.CustomFieldsProperties.IndexOf(VarId);
    if (Idx <> -1) then
    begin
      FieldType := Integer(MovieList.CustomFieldsProperties.Objects[Idx].FieldType);
    end;
  end;
  if FieldType <> -1 then
    case TFieldType(FieldType) of
      ftDate:
        Result := etyDate;
      ftReal1, ftReal2, ftReal:
        Result := etyFloat;
      ftInteger:
        Result := etyInteger;
      ftBoolean:
        Result := etyBoolean;
      else
        Result := etyString;
    end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TGroupFormat
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
function TGroupFormat.Format(GroupName: string): string;
var
  f: Extended;
  d: TDateTime;
begin
  case option of
    gfoUndefined:
      Result := GroupName;
    gfoGetFirstLetter:
      Result := copy(GroupName, 1, 1);
    gfoGetTwoFirstLetters:
      Result := copy(GroupName, 1, 2);
    gfoGetThreeFirstLetters:
      Result := copy(GroupName, 1, 3);
    gfoGetFourFirstLetters:
      Result := copy(GroupName, 1, 4);
    gfoGetFiveFirstLetters:
      Result := copy(GroupName, 1, 5);
    gfoGetDateYear:
    begin
      d := StrToDateDef(GroupName, 0);
      if d = 0 then
        d := StrToDateDef(GroupName, 0, FormatSettings);
      if d = 0 then
        Result := GroupName
      else
      begin
        Result := DateToStr(d, FormatSettings);
        Result := copy(Result, 1, 4);
      end
    end;
    gfoGetDateYearAndMonth:
    begin
      d := StrToDateDef(GroupName, 0);
      if d = 0 then
        d := StrToDateDef(GroupName, 0, FormatSettings);
      if d = 0 then
        Result := GroupName
      else
      begin
        Result := DateToStr(d, FormatSettings);
        Result := copy(Result, 1, 7);
      end
    end;
    gfoRoundNumberToThousandth:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := FormatFloat('#0.000', RoundTo(f, -3, roundType));
    end;
    gfoRoundNumberToHundredth:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := FormatFloat('#0.00', RoundTo(f, -2, roundType));
    end;
    gfoRoundNumberToTenth:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := FormatFloat('#0.0', RoundTo(f, -1, roundType));
    end;
    gfoRoundNumberToUnit:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := IntToStr(Trunc(RoundTo(f, 0, roundType)));
    end;
    gfoRoundNumberToTen:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := IntToStr(Trunc(RoundTo(f, 1, roundType)));
    end;
    gfoRoundNumberToHundred:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := IntToStr(Trunc(RoundTo(f, 2, roundType)));
    end;
    gfoRoundNumberToThousand:
    begin
      f := StrToFloatDef(CharReplace(GroupName, ',', '.'), MinDouble, FormatSettings);
      if f = MinDouble then
        Result := GroupName
      else
        Result := IntToStr(Trunc(RoundTo(f, 3, roundType)));
    end;
  else
    Result := GroupName;
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
  TMovieProperties
-------------------------------------------------------------------------------}

constructor TMovieProperties.Create;
begin
  inherited Create;
  InitFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieProperties.InitFields;
begin
  //strEncoding := 'iso-8859-1';
  strEncoding := CharsetToEncoding(CodepageToCharset(GetDefaultAnsiCodepage));
  strName := '';
  strMail := '';
  strSite := '';
  strDescription := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieProperties.Assign(MovieProperties: TMovieProperties);
begin
  strEncoding := MovieProperties.strEncoding;
  strName := MovieProperties.strName;
  strMail := MovieProperties.strMail;
  strSite := MovieProperties.strSite;
  strDescription := MovieProperties.strDescription;
end;

{-------------------------------------------------------------------------------
  TMovieList
-------------------------------------------------------------------------------}

constructor TMovieList.Create(AOwnsObjects: Boolean);
begin
  inherited Create(AOwnsObjects);
  CurrentCatalogFile := '';
  SavingCatalog := False;
  MovieProperties := TMovieProperties.Create;
  CustomFieldsProperties := TCustomFieldsProperties.Create(Self);

{$IFNDEF DLLMode}
  _extraGroups := TStringList.Create;
  _extraGroups.Sorted := True;
  _extraGroups.CaseSensitive := False;
  _extraGroups.Duplicates := dupIgnore;
{$ENDIF}
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor TMovieList.Destroy;
begin
  MovieProperties.Free;
  CustomFieldsProperties.Free;

{$IFNDEF DLLMode}
  _extraGroups.Free;
{$ENDIF}
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.LoadFromFile(const AFileName: string;
  OnlyReadProperties: Boolean; LoadStoredPictures: Boolean);
var
  InputFile: TFileStream;
  Header: array[0..Length(strFileHeader)] of Char;
  iHeader{$IFNDEF DLLMode}, iRecSize{$ENDIF}: integer;
begin
  Header := '';
  iHeader := 0;
{$IFNDEF DLLMode}
  iRecSize := 0;
{$ENDIF}
  try
    InputFile := TFileStream.Create(AFileName,fmOpenRead);
    try
      Inputfile.Seek(0,soFrombeginning);
      InputFile.Read(Header,Length(strFileHeader));
      if Header = strFileHeader42 then
      begin
        iHeader := 42;
      end else
      if Header = strFileHeader41 then
      begin
        iHeader := 41;
      end else
      if Header = strFileHeader40 then
      begin
        iHeader := 40;
      end else
      if Header = strFileHeader35 then
      begin
        iHeader := 35;
      end else
      if Header = strFileHeader33 then
      begin
        iHeader := 33;
      end else
      if Header = strFileHeader31 then
      begin
        iHeader := 31;
{$IFNDEF DLLMode}
      end else
      if Header = strFileHeader30 then
      begin
        iHeader := 30;
        iRecSize := sizeof(RMovie30);
      end else
      if Header = strFileHeader21 then
      begin
        iHeader := 21;
        iRecSize := sizeof(RMovie21);
      end else
      if Header = strFileHeader11 then
      begin
        iHeader := 11;
        iRecSize := sizeof(RMovie11);
      end else
      if Header = strFileHeader10 then
      begin
        iHeader := 10;
        iRecSize := sizeof(RMovie10);
{$ENDIF}
      end;
      Clear;
      case iHeader of
{$IFNDEF DLLMode}
        10,11,21,30:
          begin
            ReadRecords(InputFile, iRecSize, iHeader, OnlyReadProperties, LoadStoredPictures);
            if (not OnlyReadProperties) and (iHeader < 30) then
            begin
              ReadPictures(ChangeFileExt(AFileName, ''));
              ReadBorrowers(ChangeFileExt(AFileName, '.amcl'));
            end;
          end;
{$ENDIF}
        31,33,35,40,41,42:
          begin
            ReadData(InputFile, iHeader, OnlyReadProperties, LoadStoredPictures);
          end;
      else
        raise Exception.Create(strUnableToIdentify);
      end; // case
    finally
      InputFile.Free;
      CurrentCatalogFile := AFileName;
    end; // try
  except
    on E: Exception do
      raise Exception.Create(Format(strErrorLoad,[AFileName])+E.Message);
  end; // try
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

class function TMovieList.ReadHeader(const AFileName: TFileName; out TheHeader: string): Int64;
var
  i: Integer;
begin
  with TFileStream.Create(AFileName, fmOpenRead) do
    try
      Seek(0, soFrombeginning);
      SetLength(TheHeader, Length(strFileHeader));
      Read(TheHeader[1], Length(strFileHeader));
      i := Pos(sLineBreak, TheHeader);
      if i > 0 then
        SetLength(TheHeader, i - 1);
      Result := Size;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieList.LoadFromXML(const AFileName: string; OnlyReadProperties: Boolean);
var
  i, iHeader: Integer;
  CurElem: TJvSimpleXmlElem;
  NewMovie: TMovie;
  HeaderItem: TJvSimpleXmlElemHeader;
begin
  Clear;
  with TJvSimpleXml.Create(nil) do
    try
      if Assigned(ProgressWin) then
        ProgressWin.Update;
      LoadFromFile(AFilename);
      if Root.Name <> 'AntMovieCatalog' then
        raise Exception.Create(Format(strErrorLoad + strUnableToIdentify, [AFileName]));
      with Prolog do
      begin
        HeaderItem := nil;
        for i := 0 to Count-1 do
          if Item[i] is TJvSimpleXmlElemHeader then
          begin
            HeaderItem := TJvSimpleXmlElemHeader(Item[i]);
            Break;
          end;
        if HeaderItem <> nil then
          MovieProperties.strEncoding := HeaderItem.Encoding;
      end;
      iHeader := Root.Properties.IntValue('Format', intFileVersion);
      CurElem := Root.Items.ItemNamed['Catalog'];
      if CurElem = nil then
        raise Exception.Create(Format(strErrorLoad + strNoMovieFound, [AFileName]));
      CurElem := CurElem.Items.ItemNamed['Properties'];
      if CurElem <> nil then
      begin
        with CurElem, MovieProperties do
        begin
          strName := ReadTag(Properties, 'Owner', strName);
          strMail := ReadTag(Properties, 'Mail', strMail);
          strSite := ReadTag(Properties, 'Site', strSite);
          strDescription := ReadTag(Properties, 'Description', strDescription, True {MultiLines});
        end;
      end;
      CurElem := Root.Items.ItemNamed['Catalog'].Items.ItemNamed['CustomFieldsProperties'];
      if CurElem <> nil then
        CustomFieldsProperties.LoadFromXml(CurElem)
      else
        CustomFieldsProperties.Clear;
      if not OnlyReadProperties then
      begin
        CurElem := Root.Items.ItemNamed['Catalog'].Items.ItemNamed['Contents'];
        if CurElem <> nil then
          with CurElem do
          begin
            if Assigned(ProgressWin) then
            begin
              ProgressWin.Maximum := ProgressWin.Maximum + Ceil(Items.Count / 50) + 1;
              ProgressWin.StepIt;
            end;
            for i := 0 to Items.Count-1 do
            begin
              if (i mod 50 = 0) and Assigned(ProgressWin) then
                ProgressWin.StepIt;
              if Items.Item[i].Name = 'Movie' then
              begin
                NewMovie := TMovie.Create(Self);
                with NewMovie do
                  NewMovie.LoadFromXML(Items.Item[i], iHeader);
                Self.Add(NewMovie);
              end;
            end;
          end;
      end;
    finally
      Free;
      CurrentCatalogFile := AFileName;
    end;
    // If a custom field has the same tag of a new movie/extra field tag
    // or the syntax is bad, we try to rename it
    CustomFieldsProperties.RenameNoValidTags;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.ReadData(InputFile: TFileStream; const Version: Integer;
  OnlyReadProperties: Boolean; LoadStoredPictures: Boolean);
var
  newMovie: TMovie;
  {$IFNDEF DLLMode}
  c: Integer;
  {$ENDIF}
begin
  {$IFNDEF DLLMode}
  c := 0;
  if Assigned(ProgressWin) then
  begin
    ProgressWin.Maximum := Ceil(InputFile.Size / 1024) + 2;
    ProgressWin.IntProgress := 1;
  end;
  {$ENDIF}
  InputFile.Seek(Length(strFileHeader), soFromBeginning);
  with MovieProperties do
  begin
    strName := ReadString(InputFile);
    strMail := ReadString(InputFile);
    if Version < 35 then
      ReadString(InputFile); // ICQ field that was deleted
    strSite := ReadString(InputFile);
    strDescription := ReadString(InputFile);
  end;
  if Version >= 40 then
    CustomFieldsProperties.ReadData(InputFile, Version)
  else
    CustomFieldsProperties.Clear;
  if not OnlyReadProperties then
  begin
    newMovie := nil;
    while InputFile.Position < InputFile.Size do
    begin
      {$IFNDEF DLLMode}
      Inc(c);
      if (c mod 50 = 0) and Assigned(ProgressWin) then
        ProgressWin.IntProgress := InputFile.Position div 1024;
      {$ENDIF}
      try
        newMovie := TMovie.Create(Self);
        newMovie.ReadData(InputFile, Version, False, LoadStoredPictures);
        Add(newMovie);
      except
        if IndexOf(NewMovie) = -1 then
          newMovie.Free;
        Break;
      end;
    end;
  end;
  // If a custom field has the same tag of a new movie/extra field tag
  // or the syntax is bad, we try to rename it
  CustomFieldsProperties.RenameNoValidTags;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieList.ReadRecords(InputFile: TFileStream; const RecordSize: longint;
  const Version: integer; OnlyReadProperties: Boolean; LoadStoredPictures: Boolean);
var
  CurrentMovie: PMovie30;
  addedMovie: TMovie;
  ReadBytes: Longint;
  Header: array[0..Length(strFileHeader)] of Char;
  MovieProperties: RMovieProperties;
  ts: TTimeStamp;
begin
  Header := '';
  Inputfile.Seek(0,soFrombeginning);
  ReadBytes := InputFile.Read(Header,Length(strFileHeader));
  if (version >= 21) and (ReadBytes>0) then
  begin
    ReadBytes := InputFile.Read(MovieProperties,sizeof(RMovieProperties));
  end else
  begin
    with MovieProperties do
    begin
      strOwnerName := '';
      strOwnerMail := '';
      strOwnerICQ := '';
      strOwnerSite := '';
    end;
  end;
  with MovieProperties do
  begin
    Self.MovieProperties.strName := strOwnerName;
    Self.MovieProperties.strMail := strOwnerMail;
    Self.MovieProperties.strSite := strOwnerSite;
    Self.MovieProperties.strDescription := '';
  end;
  if not OnlyReadProperties then
  begin
    CurrentMovie := new(PMovie30);
    while(ReadBytes>0) do
    begin
      FillChar(CurrentMovie^,sizeof(CurrentMovie^),' ');
      ReadBytes := InputFile.Read(CurrentMovie^,RecordSize);
      with CurrentMovie^ do
      begin
        if(ReadBytes>0) then
        begin
          if version < 11 then
          begin
            iRating := 0;
          end;
          if version < 21 then
          begin
            bChecked := true;
            iDate := 0;
          end;
          if version < 30 then
          begin
            strPicture := '';
            iPictureSize := 0;
            strBorrower := '';
            if iDate = DefaultDate then
              iDate := 0;
          end;
          if version < 31 then
          begin
            case iRating of
              0: iRating := -1;
              1: iRating := 2;
              2: iRating := 4;
              3: iRating := 6;
              4: iRating := 8;
              5: iRating := 9;
            else
              iRating := -1;
            end;
            if iDate <> 0 then
            begin
              ts.Time := 0;
              ts.Date := iDate;
              iDate := trunc(TimeStampToDateTime(ts));
            end;
          end;
          addedMovie := TMovie.Create(Self);
          addedMovie.SetFields(CurrentMovie);
          if iPictureSize > 0 then
          begin
            if LoadStoredPictures then
            begin
              addedMovie.Picture.PicStream := TMemoryStream.Create;
              addedMovie.Picture.PicStream.CopyFrom(InputFile, iPictureSize);
              addedMovie.Picture.PicPath := GetRealPictureExt(addedMovie.Picture.PicStream,
                extImage[extPNG], extImage[extJPG], extImage[extGIF], extImage[extBMP], '.jpg');
            end
            else
            begin
              addedMovie.Picture.PicStream := nil;
              InputFile.Seek(iPictureSize, soFromCurrent)
            end;
          end;
          Add(addedMovie);
        end else
        begin
        end;
      end;
    end;
    Dispose(CurrentMovie);
  end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieList.ReadPictures(const strFilename: string);
var
  i: integer;
  currentFile, ext: string;
begin
  for i := 0 to Count-1 do
  begin
    if Items[i] <> nil then
    begin
      with TMovie(Items[i]) do
      begin
        currentFile := Format('%s_%d', [strFileName, iNumber]);
        ext := '.jpg';
        if not FileExists(currentFile + ext) then
        begin
          ext := '.gif';
          if not FileExists(currentFile + ext) then
          begin
            ext := '.png';
            if not FileExists(currentFile + ext) then
            begin
              Picture.PicPath := '';
              continue;
            end; // not png
          end; // not gif
        end; // not jpg
        Picture.PicPath := ExtractFileName(currentFile) + ext;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.ReadBorrowers(const strFilename: string);
var
  Names: TStringList;
  Movies: TStringList;
  i,j: integer;
  Movie: TMovie;
begin
  with TMemIniFile.Create(strFileName) do
    try
      Names := TStringList.Create;
      Movies := TStringList.Create;
      try
        ReadSections(Names);
        for i := 0 to Names.Count-1 do
        begin
          ReadSection(Names.Strings[i], Movies);
          for j := 0 to Movies.Count-1 do
          begin
            Movie := Find(StrToInt(Movies.Strings[j]));
            if Movie <> nil then
            begin
              Movie.strBorrower := Names.Strings[i];
            end;
          end;
        end;
      finally
        Movies.Free;
        Names.Free;
      end;
    finally
      Free;
    end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.SaveToFile(const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer;
  const PicOperation: TMoviePictureOperation;
  const ExtraPicOperation: TMoviePictureOperation);
var
  OutputFile: TFileStream;
  i: integer;
begin
  SavingCatalog := True;
  {$IFNDEF DLLMode}
  if Assigned(ProgressWin) then
  begin
    ProgressWin.Maximum := ProgressWin.Maximum + Ceil(Count / 25) + 1;
    ProgressWin.StepIt;
  end;
  {$ENDIF}
  OutputFile := TFileStream.Create(CatalogFileDst, fmCreate);
  try
    OutputFile.Size := 0;
    try
      if Version >= 42 then
        OutputFile.Write(strFileHeader42, Length(strFileHeader))
      else if Version >= 41 then
        OutputFile.Write(strFileHeader41, Length(strFileHeader))
      else if Version >= 40 then
        OutputFile.Write(strFileHeader40, Length(strFileHeader))
      else
        OutputFile.Write(strFileHeader35, Length(strFileHeader));

      with MovieProperties do
      begin
        WriteString(strName, OutputFile);
        WriteString(strMail, OutputFile);
        WriteString(strSite, OutputFile);
        WriteString(strDescription, OutputFile);
      end;
      if Version >= 40 then
        CustomFieldsProperties.WriteData(OutputFile, Version);
      for i := 0 to Count-1 do
      begin
        {$IFNDEF DLLMode}
        if (i mod 25 = 0) and Assigned(ProgressWin) then
          ProgressWin.StepIt;
        {$ENDIF}
        TMovie(Items[i]).WriteData(OutputFile,
          CatalogFileSrc, CatalogFileDst, Version, False,
          PicOperation, ExtraPicOperation);
      end;
    except
      on E: Exception do
        raise Exception.Create(Format(strErrorSave,[CatalogFileDst])+E.Message);
    end;
  finally
    OutputFile.Free;
    SavingCatalog := False;
    CurrentCatalogFile := CatalogFileDst;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieList.SaveToXML(const CatalogFileSrc: string; const CatalogFileDst: string;
  const Version: Integer; const OnlyWriteProperties: Boolean;
  const PicOperation: TMoviePictureOperation;
  const ExtraPicOperation: TMoviePictureOperation);
var
  i: Integer;
  HeaderItem: TJvSimpleXmlElemHeader;
begin
  SavingCatalog := True;
  if Assigned(ProgressWin) then
  begin
    ProgressWin.Maximum := ProgressWin.Maximum + Ceil(Count / 25);
    ProgressWin.StepIt;
  end;
  with TJvSimpleXml.Create(nil) do
    try
      WriteXMLHeader(Root, intFileVersion, 'AntMovieCatalog', strVersion, strDate);
      with Prolog do
      begin
        HeaderItem := nil;
        for i := 0 to Count-1 do
          if Item[i] is TJvSimpleXmlElemHeader then
          begin
            HeaderItem := TJvSimpleXmlElemHeader(Item[i]);
            Break;
          end;
        if HeaderItem = nil then
        begin
          HeaderItem := TJvSimpleXmlElemHeader.Create;
          Add(HeaderItem);
        end;
        HeaderItem.Encoding := MovieProperties.strEncoding;
      end;
      Root.Items.Delete('Catalog');
      with Root.Items.Add('Catalog') do
      begin
        with Items.Add('Properties'), MovieProperties do
        begin
          AddNotEmpty(Properties, 'Owner', strName);
          AddNotEmpty(Properties, 'Mail', strMail);
          AddNotEmpty(Properties, 'Site', strSite);
          AddNotEmpty(Properties, 'Description', strDescription);
        end;
        if CustomFieldsProperties.Count > 0 then
          CustomFieldsProperties.SaveToXml(Items.Add('CustomFieldsProperties'), CatalogFileDst);
        if not OnlyWriteProperties then
        begin
          with Items.Add('Contents') do
          begin
            for i := 0 to Count-1 do
            begin
              if (i mod 25 = 0) and Assigned(ProgressWin) then
                ProgressWin.StepIt;
              TMovie(Self.Items[i]).SaveToXML(Items.Add('Movie'),
                CatalogFileSrc, CatalogFileDst, Version,
                PicOperation, ExtraPicOperation);
            end;
          end;
        end;
      end;
      SaveToFile(CatalogFileDst);
      if Assigned(ProgressWin) then
        ProgressWin.StepIt;
    finally
      Free;
      SavingCatalog := False;
      CurrentCatalogFile := CatalogFileDst;
    end;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.Sort(const Field: Integer; Force: Boolean);
begin
  CompareStdInit(Field, Force);
  inherited Sort(CompareStd);
end;

procedure TMovieList.SortReverse(const Field: Integer; Force: Boolean);
begin
  CompareStdInit(Field, Force);
  inherited Sort(CompareStdReverse);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
procedure TMovieList.Sort(const FieldsList: TStrings; Force: Boolean);
begin
  CompareAdvInit(FieldsList, Force);
  inherited Sort(CompareAdv);
end;

procedure TMovieList.SortReverse(const FieldsList: TStrings; Force: Boolean);
begin
  CompareAdvInit(FieldsList, Force);
  inherited Sort(CompareAdvReverse);
end;
{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Find(const MovieNumber: Integer): TMovie;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to Count-1 do
  begin
    if TMovie(Items[i]).iNumber = MovieNumber then
    begin
      Result := Items[i];
      Break;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.Add(const AMovieList: TMovieList; const AllowDuplicateNumbers: Boolean);
var
  i: Integer;
  NewMovie, CurrentMovie: TMovie;
begin
  if (AMovieList <> nil) and (AMovieList.Count > 0) then
  begin
    AMovieList.Sort(fieldNumber);
    for i := 0 to AMovieList.Count-1 do
    begin
      CurrentMovie := TMovie(AMovieList.Items[i]);
      NewMovie := TMovie.Create(Self);
      if (CurrentMovie.iNumber < 1) or ((not AllowDuplicateNumbers) and (Find(CurrentMovie.iNumber) <> nil)) then
        NewMovie.iNumber := MaxNumber(False) + 1
      else
        NewMovie.iNumber := CurrentMovie.iNumber;
      NewMovie.Assign(CurrentMovie, False, True, True, True, True);
      inherited Add(NewMovie);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Add: TMovie;
begin
  Result := TMovie.Create(Self);
  inherited Add(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Add2: IMovie;
begin
  Result := Add;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.MaxNumber(ListIsSorted: Boolean): Integer;
begin
  if not ListIsSorted then
    Sort(fieldNumber);
  if Count = 0 then
    Result := 0
  else
    Result := TMovie(Items[Count-1]).iNumber;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.FirstFreeNumber(ListIsSorted: Boolean): Integer;
var
  i, Prev: Integer;
begin
  if not ListIsSorted then
    Sort(fieldNumber);
  Prev := 0;
  for i := 0 to Count-1 do
  begin
    if TMovie(Items[i]).iNumber > (Prev + 1) then
      Break
    else
      Prev := TMovie(Items[i]).iNumber;
  end;
  Result := Prev + 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.HasImages(IncludeStored, IncludeLinksRel, IncludeLinksAbs: Boolean): Boolean;
var
  i, j: Integer;
  PicStr, PicDrive: Boolean;
begin
  Result := False;
  for i := 0 to Count-1 do
  begin
    with Items[i] do
    begin
      PicStr := Picture.PicPath <> '';
      PicDrive := ExtractFileDrive(Picture.PicPath) <> '';
      Result := (IncludeStored and (Picture.PicStream <> nil) and PicStr) or
                ((Picture.PicStream = nil)
                         and PicStr
                         and ((IncludeLinksRel and not PicDrive) or
                              (IncludeLinksAbs and PicDrive)));
      for j := 0 to Extras.Count-1 do
      begin
        with Extras.Items[j] do
        begin
          PicStr := Picture.PicPath <> '';
          PicDrive := ExtractFileDrive(Picture.PicPath) <> '';
          Result := (IncludeStored and (Picture.PicStream <> nil) and PicStr) or
                    ((Picture.PicStream = nil)
                             and PicStr
                             and ((IncludeLinksRel and not PicDrive) or
                                  (IncludeLinksAbs and PicDrive)));
        end;
      end;
    end;
    if Result then
      Break;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.HasExtras: Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to Count-1 do
    if Items[i].Extras.Count > 0 then
    begin
      Result := True;
      Break;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

// POOR PERFORMANCE
{procedure TMovieList.GetValues(AList: TStrings; Field: Integer);
var
  i: Integer;
  value: string;
begin
  AList.BeginUpdate;
  AList.Clear;
  try
    for i := 0 to Count-1 do
    begin
      value := TMovie(Items[i]).GetFieldValue(Field);
      if (value <> '') and (AList.IndexOf(value) = -1) then
        AList.Add(value);
    end;
  finally
    AList.EndUpdate;
  end;
end;}

procedure TMovieList.GetValues(AList: TStrings; Field: Integer);
var
  i: Integer;
  Value: string;
  Contents: TStringList;
begin
  Contents := TStringList.Create;
  Contents.Sorted := True;
  Contents.Duplicates := dupIgnore;
  for i := 0 to Count-1 do
  begin
    Value := TMovie(Items[i]).GetFieldValue(Field);
    if (Value <> '') then
      Contents.Add(Value);
  end;
  AList.Assign(Contents);
  Contents.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.GetCustomValues(AList: TStrings; Field: string);
var
  i: Integer;
  value: string;
begin
  AList.BeginUpdate;
  AList.Clear;
  try
    for i := 0 to Count-1 do
    begin
      value := TMovie(Items[i]).CustomFields.GetFieldValue(Field);
      if (value <> '') and (AList.IndexOf(value) = -1) then
        AList.Add(value);
    end;
  finally
    AList.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.GetExtrasValues(AList: TStrings; Field: Integer);
var
  i,j: Integer;
  Value: string;
  Contents: TStringList;
  Extras: TMovieExtras;
begin
  Contents := TStringList.Create;
  Contents.Sorted := True;
  Contents.Duplicates := dupIgnore;
  for i := 0 to Count-1 do
  begin
    Extras := TMovie(Items[i]).Extras;
    for j := 0 to Extras.Count-1 do
    begin
      Value := Extras.Items[j].GetFieldValue(Field);
      if (Value <> '') then
        Contents.Add(Value);
    end;
  end;
  AList.Assign(Contents);
  Contents.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Count: Integer;
begin
  Result := inherited Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Count(const IncOpt: TMovieIncludeOption): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    if TMovie(Items[i]).CanInclude(IncOpt) then
      Inc(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.Count(out cAll, cSelected, cChecked, cVisible: Integer);
var
  i: Integer;
begin
  cAll := 0;
  cSelected := 0;
  cChecked := 0;
  cVisible := 0;
  for i := 0 to Count-1 do
    with TMovie(Items[i]) do
    begin
      Inc(cAll);
      if bChecked then
        Inc(cChecked);
{$IFNDEF DLLMode}
      if _bSelected then
        Inc(cSelected);
      if _bVisible then
        Inc(cVisible);
{$ENDIF}
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.Count(const MovieNumber: Integer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    with TMovie(Items[i]) do
      if iNumber = MovieNumber then
        Inc(Result);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.MakeFilteredList(AList: TList; const IncOpt: TMovieIncludeOption);
var
  i: Integer;
begin
  AList.Clear;
  for i := 0 to Count-1 do
    if TMovie(Items[i]).CanInclude(IncOpt) then
      AList.Add(Items[i]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.ShiftNumbers(const StartAt: Integer; const Exclude: TMovie);
var
  i: Integer;
begin
  Sort(fieldNumber);
  for i := 0 to Count-1 do
    if Exclude <> Items[i] then
      with TMovie(Items[i]) do
        if iNumber >= StartAt then
        begin
          Inc(iNumber);
          if (i < Count-1) and ((TMovie(Items[i+1]).iNumber > iNumber) or (TMovie(Items[i+1]) = Exclude)) then
            Exit;
        end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.GetItem(const idx: Integer): TMovie;
begin
  Result := TMovie(inherited Items[idx]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.GetItem2(const idx: Integer): IMovie;
begin
  Result := GetItem(idx);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.SetItem(const idx: Integer; const Value: TMovie);
begin
  inherited Items[idx] := Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.CountPictures(const IncPicOpt: TPictureIncludeOption;
  const IncMovieOpt: TMovieIncludeOption): Integer;
var
  i, j: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    with TMovie(Items[i]) do
      if CanInclude(IncMovieOpt) then
      begin
        if (IncPicOpt = pioAll) or (IncPicOpt = pioMovie) then
          if (Picture.PicPath <> '') then
            Inc(Result);
        if (IncPicOpt = pioAll) or (IncPicOpt = pioExtras) then
          for j := 0 to Extras.Count-1 do
            with Extras.Items[j] do
              if (Picture.PicPath <> '') then
                Inc(Result);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.CountPictures(out cAll, cMovie, cExtras: Integer;
  const IncMovieOpt: TMovieIncludeOption);
var
  i, j: Integer;
begin
  cMovie := 0;
  cExtras := 0;
  for i := 0 to Count-1 do
    with TMovie(Items[i]) do
      if CanInclude(IncMovieOpt) then
      begin
        if (Picture.PicPath <> '') then
          Inc(cMovie);
        for j := 0 to Extras.Count-1 do
          with Extras.Items[j] do
            if (Picture.PicPath <> '') then
              Inc(cExtras);
      end;
  cAll := cMovie + cExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMovieList.CountPictures(const MoviePicture: string): Integer;
var
  i, j: Integer;
begin
  Result := 0;
  for i := 0 to Count-1 do
    with TMovie(Items[i]) do
    begin
      if (Picture.PicStream = nil) and AnsiSameText(Picture.PicPath, MoviePicture) then
        Inc(Result);
      for j := 0 to Extras.Count-1 do
        with Extras.Items[j] do
          if (Picture.PicStream = nil) and AnsiSameText(Picture.PicPath, MoviePicture) then
            Inc(Result);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMovieList.RenamePictures(const OldPath: string; const NewPath: string;
  AfterPicture: TMoviePicture);
var
  i, j: Integer;
  AfterPictureFound: Boolean;
begin
  AfterPictureFound := (AfterPicture = nil);
  for i := 0 to Count-1 do
  begin
    with TMovie(Items[i]) do
    begin
      if AfterPictureFound then
      begin
        if (Picture.PicStream = nil) and AnsiSameText(Picture.PicPath, OldPath) then
          Picture.PicPath := NewPath;
      end else
        AfterPictureFound := (Picture = AfterPicture);
      for j := 0 to Extras.Count-1 do
      begin
        with Extras.Items[j] do
        begin
          if AfterPictureFound then
          begin
            if (Picture.PicStream = nil) and AnsiSameText(Picture.PicPath, OldPath) then
              Picture.PicPath := NewPath;
          end else
            AfterPictureFound := (Picture = AfterPicture);
        end;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}
function TMovieList.GetMoviesByGroups(Field: Integer; const IncOpt: TMovieIncludeOption;
  const MovieFilter : TMovieFilter; const GroupFormat : TGroupFormat): TStringList;
var
  Groups: TStringList;
  GroupMovies: TObjectList;
  MultiValues: TStringList;
  Movie: TMovie;
  FieldValue, GroupName: string;
  Sep : Char;
  i, j, len, idx: Integer;
  bGroupMulti, bPatch, bRmp, bExtraField : Boolean;
  Prop : TCustomFieldProperties;
  // Args: IN [GroupName, Movie]
  procedure AddMovieToMap;
  begin
    if Length(GroupName) > 128 then
      GroupName := Copy(GroupName, 1, 128);
    GroupName := Trim(GroupName);
    if (GroupFormat <> nil) and
      (GroupName <> '$$$NOGROUP$$$') and
      (GroupName <> '$$$EMPTY$$$') and
      (GroupName <> strErrorParenthesis) then
      GroupName := GroupFormat.Format(GroupName);
    if GroupName <> '' then
    begin
      idx := Groups.IndexOf(GroupName);
      if idx = -1 then
      begin
        GroupMovies := TObjectList.Create(False);
        GroupMovies.Add(Movie);
        Groups.AddObject(GroupName, GroupMovies);
      end else
      begin
        GroupMovies := TObjectList(Groups.Objects[idx]);
        if (not bGroupMulti) or (GroupMovies.IndexOf(Movie) = -1) then
          GroupMovies.Add(Movie);
      end;
    end;
  end;
begin
  Prop := nil;
  bExtraField := False;
  if (Field in AllCustomFields) and (Field - customFieldLow < CustomFieldsProperties.Count) then
    Prop := CustomFieldsProperties.Objects[Field - customFieldLow] // Custom Field
  else if (Field in AllExtraFields) then
    bExtraField := True; // Extra field
  if (Prop = nil) and (not bExtraField) and (not (Field in AllFields)) then Field := -1; // Not a good Field
  with Settings.rOptions.rMovieList do
  begin
    if (Prop <> nil) then bGroupMulti := Prop.MultiValues
    else bGroupMulti := GroupMulti and (Field in GroupByFieldsMulti);
    if (Prop <> nil) then Sep := Prop.MultiValuesSep
    else Sep := GroupMultiSep;
    if Sep = #0 then Sep := defaultSep;
    if (Prop <> nil) then bRmP := Prop.MultiValuesRmP
    else bRmP := GroupMultiRmAllP or (Field in GroupByFieldsMultiDefaultRmP);
    if (Prop <> nil) then bPatch := Prop.MultiValuesPatch
    else bPatch := GroupMultiAddPatch;
  end;
  Groups := TStringList.Create;
  Groups.Sorted := True;
  Groups.CaseSensitive := False;
  
  for i := 0 to Count-1 do
  begin
    Movie := TMovie(Items[i]);
    if not Movie.CanInclude(IncOpt) then
      continue;
    if MovieFilter <> nil then
      if not MovieFilter.Match(Movie) then
        continue;
    with Movie do
    begin
      if not bExtraField then
      begin
        if Prop <> nil then // Custom Field
        begin
          FieldValue := CustomFields.GetFieldValue(Prop.FieldTag, True);
          len := Length(FieldValue);
          if (len > 0) and (FieldValue[len] = '.') then
            FieldValue := Copy(FieldValue, 1, len-1);
          if (FieldValue = '') then
            FieldValue := '$$$EMPTY$$$';
        end else if (Field <> -1) then // Movie Field
        begin
          FieldValue := GetFieldValue(Field, True);
          len := Length(FieldValue);
          if (len > 0) and (FieldValue[len] = '.') then
            FieldValue := Copy(FieldValue, 1, len-1);
          if (FieldValue = '') then
            FieldValue := '$$$EMPTY$$$';
        end else // No Field
        begin
          FieldValue := '$$$NOGROUP$$$';
        end;
        if (not bGroupMulti) then
        begin
          GroupName := FieldValue;
          AddMovieToMap;
        end else
        begin
          MultiValues := GetMultiValues(FieldValue, Sep, bRmP, strErrorParenthesis, bPatch);
          for j := 0 to MultiValues.Count-1 do
          begin
            GroupName := MultiValues.Strings[j];
            AddMovieToMap;
          end;
          MultiValues.Free;
        end; // else bGroupMulti
      end else // Extra field
      begin
        MultiValues := Extras.GetExtrasByGroups(Field, True);
        if MultiValues.Count > 0 then
        begin
          for j := 0 to MultiValues.Count-1 do
          begin
            GroupName := MultiValues.Strings[j];
            AddMovieToMap;
          end
        end else
        begin
          GroupName := '$$$EMPTY$$$';
          AddMovieToMap;
        end;

        MultiValues.Free;
      end;
    end; // end with Movie
  end; // end for
  Result := Groups;
end;
{$ENDIF}

{-------------------------------------------------------------------------------
    External functions
-------------------------------------------------------------------------------}

procedure FreeObjects(const strings: TStrings);
var
  idx : integer;
begin
  for idx := 0 to strings.Count-1 do
  begin
    strings.Objects[idx].Free;
    strings.Objects[idx] := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetMultiValues(const MultiValues: string; const Sep: Char;
  const RemoveParenthesis: Boolean; const ErrorParenthesisValue: string;
  const UsePatch: Boolean): TStringList;
var
  n, initPos: Integer;
  nbPOpen, firstPOpen, lastPClose: Integer;
  Value: string;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.CaseSensitive := False;
  Result.Duplicates := dupIgnore;
  n := 1;
  initPos := 1;
  nbPOpen := 0;
  firstPOpen := 0;
  lastPClose := 0;
  if MultiValues = '' then
    exit;
  while True do
  begin
    if (MultiValues[n] = ')') then
    begin
      Dec(nbPOpen);
      if nbPOpen = 0 then
        lastPClose := n;
    end else if (MultiValues[n] = '(') then
    begin
      if (not UsePatch) or (not
        (((MultiValues[n+1] = 'I') or (MultiValues[n+1] = 'V') or (MultiValues[n+1] = 'X')) and
         ((MultiValues[n+2] = 'I') or (MultiValues[n+2] = 'V') or (MultiValues[n+2] = 'X') or
          (MultiValues[n+2] = Sep) or (MultiValues[n+2] = #10) or
          ((MultiValues[n+2] = ' ') and (MultiValues[n+3] = '('))) and
         ((MultiValues[n+2] = Sep) or (MultiValues[n+2] = #10) or
          ((MultiValues[n+2] = ' ') and (MultiValues[n+3] = '(')) or
          (MultiValues[n+3] = 'I') or (MultiValues[n+3] = 'V') or (MultiValues[n+3] = 'X') or
          (MultiValues[n+3] = Sep) or (MultiValues[n+3] = #10) or
          ((MultiValues[n+3] = ' ') and (MultiValues[n+4] = '('))) and
         ((MultiValues[n+2] = Sep) or (MultiValues[n+2] = #10) or
          ((MultiValues[n+2] = ' ') and (MultiValues[n+3] = '(')) or (MultiValues[n+3] = Sep) or
          (MultiValues[n+3] = #10) or ((MultiValues[n+3] = ' ') and (MultiValues[n+4] = '(')) or
          (MultiValues[n+4] = Sep) or (MultiValues[n+4] = #10) or
          ((MultiValues[n+4] = ' ') and (MultiValues[n+5] = '('))))) then
      begin
        if (nbPOpen = 0) then
          firstPOpen := n;
        Inc(nbPOpen);
      end;
    end else if (MultiValues[n] = Sep) or (MultiValues[n] = #0) then
    begin
      if nbPOpen = 0 then // Good parentheses
      begin
        if(firstPOpen > 0) and (RemoveParenthesis) then // There are Parentheses
        begin
          Value := Trim(Copy(MultiValues, initPos, firstPOpen - initPos)) +' '+
                   Trim(Copy(MultiValues, lastPClose + 1, n - lastPClose - 1));
        end else
        begin
          Value := Copy(MultiValues, initPos, n - initPos);
        end;
        Value := Trim(Value);
        if Value <> '' then
          Result.Add(Value);
        initPos := n + 1;
        firstPOpen := 0;
        lastPClose := 0;
      end else if(MultiValues[n] = #0) then // Bad parentheses !
      begin
        Value := ErrorParenthesisValue; // Copy(MultiValues, initPos, n - initPos);
        Value := Trim(Value);
        if Value <> '' then
          Result.Add(Value);
      end;
      if(MultiValues[n] = #0) then // Finish
        break;
    end;
    Inc(n);
  end; // while True
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetMultiValuesSimple(MultiValues: string; const Separator: string): TStringList;
var
  p: Integer;
  value: string;
begin
  Result := TStringList.Create;
  if MultiValues = '' then
    exit;
  repeat
    p := Pos(Separator, MultiValues);
    if p > 0 then
    begin
      value := Copy(MultiValues, 1, p - 1);
      Result.Add(value);
      System.Delete(MultiValues, 1, p - 1 + Length(Separator));
    end
    else
    begin
      value := MultiValues;
      Result.Add(value);
      MultiValues := '';
    end;
  until (MultiValues = '');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetFieldType(field: Integer): TFieldType;
begin
  case field of
    fieldNumber,          fieldColorTag,        fieldYear,
    fieldLength,          fieldVideoBitrate,    fieldAudioBitrate,
    fieldDisks,           fieldNbExtras,        extraFieldNumber:
      Result := ftInteger;
    fieldRating,          fieldUserRating:
      {$IFNDEF DLLMode}
      if Settings.rOptions.rMovieInformation.RatingTrunc then
        Result := ftInteger
      else
      {$ENDIF}
        Result := ftReal1;
    fieldDate,            fieldDateWatched:
      Result := ftDate;
    fieldChecked,         extraFieldChecked:
      Result := ftBoolean;
    fieldURL,             fieldFilePath,        extraFieldURL:
      Result := ftUrl;
    fieldActors,          fieldDescription,     fieldComments,
    extraFieldDescription, extraFieldComments:
      Result := ftText;
    fieldMediaType,       fieldSource,          fieldBorrower,
    fieldCountry,         fieldCategory,        fieldCertification,
    fieldVideoFormat,     fieldAudioFormat,     fieldFrameRate,
    fieldLanguages,       fieldSubtitles,
    extraFieldTag,        extraFieldCategory,   extraFieldCreatedBy:
      Result := ftList;
    fieldMedia,           fieldOriginalTitle,   fieldTranslatedTitle,
    fieldFormattedTitle,  fieldDirector,        fieldProducer,
    fieldWriter,          fieldComposer,        fieldResolution,
    fieldSize,            fieldPictureStatus,
    extraFieldTitle,      extraFieldPictureStatus:
      Result := ftString;
  else
    Result := ftString;
  end; // case
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertFieldValue(Value: string; FieldType: TFieldType; const LocalFormatSettings: Boolean;
  const ExtraDateValue: Boolean; const ReturnEmptyIfFalse : Boolean): string;
var
  RealFormat: string;
  f: Double;
  d: TDateTime;
begin
  Result := '';
  if (Value = '') and (FieldType <> ftBoolean) then
    Exit;
  case FieldType of
    ftInteger:
      begin
        f := StrToFloatDef(CharReplace(Value, ',', '.'), MinDouble, FormatSettings);
        if f <> MinDouble then
          Result := IntToStr(Round(f))
        else
          Result := '';
      end;
    ftReal, ftReal1, ftReal2:
      begin
        RealFormat := '#0.000';
        if FieldType = ftReal1 then
          RealFormat := '#0.0'
        else if FieldType = ftReal2 then
          RealFormat := '#0.00';
        f := StrToFloatDef(CharReplace(Value, ',', '.'), MinDouble, FormatSettings);
        if f <> MinDouble then
          if not LocalFormatSettings then
            Result := FormatFloat(RealFormat, f, FormatSettings)
          else
            Result := FormatFloat(RealFormat, f)
        else
          Result := '';
      end;
    ftBoolean:
      begin
        if (Value = '') or (Value = '0') or SameText(Value, 'False') then
          if ReturnEmptyIfFalse then
            Result := ''
          else
            Result := 'False'
        else
          Result := 'True';
      end;
    ftDate:
      begin
        if ExtraDateValue and (SameText(Value, 'Today')) then
          Result := 'Today'
        else
        begin
          d := StrToDateDef(Value, 0, FormatSettings);
          if d = 0 then
            d := StrToDateDef(Value, 0);
          if d <> 0 then
            if not LocalFormatSettings then
              Result := DateToStr(d, FormatSettings)
            else
              Result := DateToStr(d)
          else
            Result := '';
        end;
      end;
    else
      Result := Value;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertFieldTypeFromString(Value: string): TFieldType;
begin
  Result := ftString;
  Value := UpperCase(Value);
  if Value = 'FTINTEGER' then
    Result := ftInteger
  else if Value = 'FTREAL' then
    Result := ftReal
  else if Value = 'FTREAL1' then
    Result := ftReal1
  else if Value = 'FTREAL2' then
    Result := ftReal2
  else if Value = 'FTBOOLEAN' then
    Result := ftBoolean
  else if Value = 'FTDATE' then
    Result := ftDate
  else if Value = 'FTLIST' then
    Result := ftList
  else if Value = 'FTTEXT' then
    Result := ftText
  else if Value = 'FTURL' then
    Result := ftUrl
  else if Value = 'FTVIRTUAL' then
    Result := ftVirtual;

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertFieldTypeToString(Value: TFieldType): string;
begin
  Result := 'ftString';
  case Value of
    ftInteger:
      Result := 'ftInteger';
    ftReal:
      Result := 'ftReal';
    ftReal1:
      Result := 'ftReal1';
    ftReal2:
      Result := 'ftReal2';
    ftBoolean:
      Result := 'ftBoolean';
    ftDate:
      Result := 'ftDate';
    ftList:
      Result := 'ftList';
    ftText:
      Result := 'ftText';
    ftUrl:
      Result := 'ftUrl';
    ftVirtual:
      Result := 'ftVirtual';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}

function ConvertFieldTypeFromSQL(Value: string): TFieldType;
begin
  Result := ftString;
  Value := UpperCase(Value);
  if Value = 'INT' then
    Result := ftInteger
  else if Value = 'FLOAT' then
    Result := ftReal
  else if Value = 'DATE' then
    Result := ftDate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertFieldTypeToSQL(Value: TFieldType): string;
begin
  Result := 'TEXT';
  case Value of
    ftInteger:
      Result := 'INT';
    ftReal, ftReal1, ftReal2:
      Result := 'FLOAT';
    ftDate:
      Result := 'DATE';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertColorToHTML(Color: TColor): string;
var
  tmpRGB : TColorRef;
begin
  tmpRGB := ColorToRGB(color) ;
  Result := Format('#%.2x%.2x%.2x',[GetRValue(tmpRGB), GetGValue(tmpRGB), GetBValue(tmpRGB)]) ;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ConvertColorFromHTML(Color: string; DefaultColor: TColor): TColor;
var
  i: Integer;
  Bad: Boolean;
begin
  Result := DefaultColor;
  if (Length(Color) = 7) and (Color[1] = '#') then
  begin
    Bad := False;
    for i := 2 to 7 do
      if not ((Color[i] in ['0'..'9']) or (Color[i] in ['a'..'f']) or (Color[i] in ['A'..'F'])) then
      begin
        Bad := true;
        Break;
      end;
    if not Bad then
      Result := StringToColor('$' + Copy(Color, 6, 2) + Copy(Color, 4, 2) + Copy(Color, 2, 2));
  end;
end;

{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function PrefixValue(const AValue: string; const Prefixes: TStringList): string;
var
  StartPos, Idx: Integer;
  Prefix: string;
begin
  Result := AValue;
  if Prefixes = nil then Exit;
  StartPos := 1;
  while StartPos <= Length(AValue) do
  begin
    if AValue[StartPos] in ['''', ' '] then
      Break;
    inc(StartPos);
  end;
  if (StartPos > 0) and (StartPos <= Length(AValue)) then
  begin
    Prefix := Copy(AValue, 1, StartPos - 1);
    if Prefix <> '' then
    begin
      Idx := Prefixes.IndexOf(Prefix);
      if Idx > -1 then
      begin
        Result := TrimRight(UpperCase(AValue[StartPos + 1]) + Copy(AValue, StartPos + 2, Length(AValue)) + ', ' + Prefix + AValue[StartPos]);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function RoundUpTo(AValue: Double; ADigit: Integer): Double;
var
  LFactor: Double;
  X: Double;
begin
  LFactor := IntPower(10, ADigit);
  X := AValue / LFactor;
  Result := Trunc(X);
  if Frac(X) > 0 then
    Result := Result + 1;
  Result := Result * LFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function RoundDownTo(AValue: Double; ADigit: Integer): Double;
var
  LFactor: Double;
  X: Double;
begin
  LFactor := IntPower(10, ADigit);
  X := AValue / LFactor;
  Result := Trunc(X);
  if Frac(X) < 0 then
    Result := Result - 1;
  Result := Result * LFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function RoundNearestTo(AValue: Double; ADigit: Integer): Double;
var
  LFactor: Double;
  X: Double;
begin
  LFactor := IntPower(10, ADigit);
  X := AValue / LFactor;
  Result := Trunc(X);
  if X >= 0 then
  begin
    if Frac(X) >= 0.5 then
      Result := Result + 1;
  end
  else
  begin
    if Frac(X) <= -0.5 then
      Result := Result - 1;
  end;
  Result := Result * LFactor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function RoundTo(AValue: Double; ADigit: Integer; RoundType: TRoundType): Double;
begin
  case RoundType of
    rtDown:
      Result := RoundDownTo(AValue, ADigit);
    rtNearest:
      Result := RoundNearestTo(AValue, ADigit);
    rtUp:
      Result := RoundUpTo(AValue, ADigit);
    else
      Result := RoundNearestTo(AValue, ADigit);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function IsValidTag(const s: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if (s = '') or ( not((s[1] in ['a'..'z']) or (s[1] in ['A'..'Z']) or (s[1] = '_')) ) then
    Exit;
  for i:=1 to Length(s) do
    if not( (s[i] in ['a'..'z']) or (s[i] in ['A'..'Z']) or (s[i] in ['0'..'9']) or (s[i] = '_') ) then
      Exit;
  if (IndexText(s, strTagFields) = -1) and (AnsiCompareText(s, strTagFieldPicture) <> 0) and
     (IndexText(s, strTagExtraFields) = -1) and (AnsiCompareText(s, strTagExtraFieldPicture) <> 0) then
    Result := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetCatalogPicDir(CatalogFile: TFileName; CreateIfNotExists: Boolean): string;
begin
  Result := ExtractFileName(CatalogFile) + '_pics';
  if CreateIfNotExists then
  begin
    SetCurrentDir(ExtractFilePath(CatalogFile));
    if not DirectoryExists(ExpandFileName(Result)) then
      CreateDir(Result);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure RemoveCatalogPicDirIfEmpty(CatalogFile: TFileName);
var
  PicDir, PicDirPath: string;
begin
  SetCurrentDir(ExtractFilePath(CatalogFile));
  PicDir := GetCatalogPicDir(CatalogFile, False);
  PicDirPath := ExpandFileName(PicDir) + '\';
  if DirectoryExists(PicDirPath) and DirectoryIsEmpty(PicDirPath) then
    RemoveDir(PicDir);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure CompareStdInit(Field: Integer; Force: Boolean);
begin
  SortField := Field;
  SortForce := Force;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareStd(Item1, Item2: Pointer): Integer;
var
  Movie1, Movie2: TMovie;
  FieldsProperties: TCustomFieldsProperties;
  FieldProperties: TCustomFieldProperties;
begin
  Result := 0;
  Movie1 := Item1;
  Movie2 := Item2;
  FieldsProperties := Movie1.CustomFields.Properties;
  if SortField < fieldCount then // movie field
  begin
    case GetFieldType(SortField) of
      ftInteger, ftReal, ftReal1, ftReal2, ftDate:
        Result := CompareValue(Movie1.GetIntFieldValue(SortField), Movie2.GetIntFieldValue(SortField));
      else
{$IFNDEF DLLMode}
        if Settings.rOptions.rDisplay.NaturalCompare then
{$ELSE}
        if NaturalCompare then
{$ENDIF}
          Result := AnsiNatCompareText(Movie1.GetFieldValue(SortField), Movie2.GetFieldValue(SortField))
        else
          Result := AnsiCompareText(Movie1.GetFieldValue(SortField), Movie2.GetFieldValue(SortField));
    end; // case
  end else if (FieldsProperties <> nil) and (SortField - customFieldLow < FieldsProperties.Count) then // custom field
  begin
    FieldProperties := FieldsProperties.Objects[SortField - customFieldLow];
    case FieldProperties.FieldType of
      ftInteger, ftDate:
        Result := CompareValue(Movie1.CustomFields.GetIntFieldValue(FieldProperties.FieldTag),
          Movie2.CustomFields.GetIntFieldValue(FieldProperties.FieldTag));
      ftReal, ftReal1, ftReal2:
        Result := CompareValue(Movie1.CustomFields.GetFloatFieldValue(FieldProperties.FieldTag),
          Movie2.CustomFields.GetFloatFieldValue(FieldProperties.FieldTag));
      else
{$IFNDEF DLLMode}
        if Settings.rOptions.rDisplay.NaturalCompare then
{$ELSE}
        if NaturalCompare then
{$ENDIF}
          Result := AnsiNatCompareText(Movie1.CustomFields.GetFieldValue(FieldProperties.FieldTag),
            Movie2.CustomFields.GetFieldValue(FieldProperties.FieldTag))
        else
          Result := AnsiCompareText(Movie1.CustomFields.GetFieldValue(FieldProperties.FieldTag),
            Movie2.CustomFields.GetFieldValue(FieldProperties.FieldTag));
    end; // case
  end;
  if SortForce then
  begin
    if Result = 0 then
{$IFNDEF DLLMode}
      if Settings.rOptions.rDisplay.NaturalCompare then
{$ELSE}
      if NaturalCompare then
{$ENDIF}
        Result := AnsiNatCompareText(Movie1.GetFormattedTitle, Movie2.GetFormattedTitle)
      else
        Result := AnsiCompareText(Movie1.GetFormattedTitle, Movie2.GetFormattedTitle);
    if Result = 0 then
      Result := Movie1.iNumber - Movie2.iNumber;
    if Result = 0 then
      Result := AnsiCompareStr(Format('%p', [Item1]), Format('%p', [Item2]));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareStdReverse(Item1, Item2: Pointer): Integer;
begin
  Result := CompareStd(Item2, Item1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure CompareExtrasStdInit(Field: Integer; Force: Boolean);
begin
  SortExtraField := Field;
  SortExtraForce := Force;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareExtrasStd(Item1, Item2: Pointer): Integer;
var
  Extra1, Extra2: TMovieExtra;
begin
  Result := 0;
  Extra1 := Item1;
  Extra2 := Item2;
  if (SortExtraField >= extraFieldLow) and (SortExtraField < extraFieldCount) then
  begin
    case GetFieldType(SortExtraField) of
      ftInteger, ftReal, ftReal1, ftReal2, ftDate:
        Result := CompareValue(Extra1.GetIntFieldValue(SortExtraField), Extra2.GetIntFieldValue(SortExtraField));
      else
{$IFNDEF DLLMode}
        if Settings.rOptions.rDisplay.NaturalCompare then
{$ELSE}
        if NaturalCompare then
{$ENDIF}
          Result := AnsiNatCompareText(Extra1.GetFieldValue(SortExtraField), Extra2.GetFieldValue(SortExtraField))
        else
          Result := AnsiCompareText(Extra1.GetFieldValue(SortExtraField), Extra2.GetFieldValue(SortExtraField));
      end // case
  end;
  if SortExtraForce then
  begin
    if Result = 0 then
{$IFNDEF DLLMode}
      if Settings.rOptions.rDisplay.NaturalCompare then
{$ELSE}
      if NaturalCompare then
{$ENDIF}
        Result := AnsiNatCompareText(Extra1.strTitle, Extra2.strTitle)
      else
        Result := AnsiCompareText(Extra1.strTitle, Extra2.strTitle);
      if Result = 0 then
        Result := CompareValue(Extra1.iNumber, Extra2.iNumber);
      if Result = 0 then
        Result := CompareStr(Format('%p', [Item1]), Format('%p', [Item2]));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareExtrasStdReverse(Item1, Item2: Pointer): Integer;
begin
  Result := CompareExtrasStd(Item2, Item1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{$IFNDEF DLLMode}

procedure CompareAdvInit(FieldsList: TStrings; Force: Boolean);
begin
  SortFieldsIndex := -1;
  SortFieldsList.Assign(FieldsList);
  SortForce := Force;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareAdv(Item1, Item2: Pointer): Integer;
var
  Movie1, Movie2: TMovie;
  field: Integer;
  FieldsProperties: TCustomFieldsProperties;
  FieldProperties: TCustomFieldProperties;
  str: string;
begin
  Result := 0;
  try
    Inc(SortFieldsIndex);
    if SortFieldsIndex < SortFieldsList.Count then
    begin
      str := SortFieldsList[SortFieldsIndex];
      if Length(str) > 0 then
      begin
        if str[1] = '-' then
        begin
          Movie1 := Item2;
          Movie2 := Item1;
          Delete(str, 1, 1);
        end else
        begin
          Movie1 := Item1;
          Movie2 := Item2;
        end;
        if Length(str) > 0 then
        begin
          FieldsProperties := Movie1.CustomFields.Properties;
          if (str[1] in ['0'..'9']) then // movie field (Field Id)
          begin
            field := StrToIntDef(str, -1);
            if (field >= fieldLow) and (field < fieldCount) then
            begin
              case GetFieldType(field) of
                ftInteger, ftReal, ftReal1, ftReal2, ftDate:
                  Result := CompareValue(Movie1.GetIntFieldValue(field), Movie2.GetIntFieldValue(field));
                else
                  if Settings.rOptions.rDisplay.NaturalCompare then
                    Result := AnsiNatCompareText(Movie1.GetFieldValue(field), Movie2.GetFieldValue(field))
                  else
                    Result := AnsiCompareText(Movie1.GetFieldValue(field), Movie2.GetFieldValue(field));
                end // case
            end;
          end
          else if FieldsProperties <> nil then // custom field (Custom Field Tag)
          begin
            field := FieldsProperties.IndexOf(str);
            if field <> -1 then
            begin
              FieldProperties := FieldsProperties.Objects[field];
              case FieldProperties.FieldType of
              ftInteger, ftDate:
                Result := CompareValue(Movie1.CustomFields.GetIntFieldValue(FieldProperties.FieldTag),
                  Movie2.CustomFields.GetIntFieldValue(FieldProperties.FieldTag));
              ftReal, ftReal1, ftReal2:
                Result := CompareValue(Movie1.CustomFields.GetFloatFieldValue(FieldProperties.FieldTag),
                  Movie2.CustomFields.GetFloatFieldValue(FieldProperties.FieldTag));
              else
                if Settings.rOptions.rDisplay.NaturalCompare then
                  Result := AnsiNatCompareText(Movie1.CustomFields.GetFieldValue(FieldProperties.FieldTag),
                    Movie2.CustomFields.GetFieldValue(FieldProperties.FieldTag))
                else
                  Result := AnsiCompareText(Movie1.CustomFields.GetFieldValue(FieldProperties.FieldTag),
                    Movie2.CustomFields.GetFieldValue(FieldProperties.FieldTag));
              end; // case
            end;
          end;
        end;
      end;
      if Result = 0 then
        Result := CompareAdv(Item1, Item2);
    end
    else if SortForce then
    begin
      Movie1 := Item1;
      Movie2 := Item2;
      if Result = 0 then
        if Settings.rOptions.rDisplay.NaturalCompare then
          Result := AnsiNatCompareText(Movie1.GetFormattedTitle, Movie2.GetFormattedTitle)
        else
          Result := AnsiCompareText(Movie1.GetFormattedTitle, Movie2.GetFormattedTitle);
      if Result = 0 then
        Result := Movie1.iNumber - Movie2.iNumber;
      if Result = 0 then
        Result := CompareStr(Format('%p', [Item1]), Format('%p', [Item2]));
    end;
  finally
    SortFieldsIndex := -1;
  end; // try
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareAdvReverse(Item1, Item2: Pointer): Integer;
begin
  Result := CompareAdv(Item2, Item1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure CompareExtrasAdvInit(FieldsList: TStrings; Force: Boolean);
begin
  SortExtraFieldsIndex := -1;
  SortExtraFieldsList.Assign(FieldsList);
  SortExtraForce := Force;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareExtrasAdv(Item1, Item2: Pointer): Integer;
var
  Extra1, Extra2: TMovieExtra;
  field: Integer;
  str: string;
begin
  Result := 0;
  try
    Inc(SortExtraFieldsIndex);
    if SortExtraFieldsIndex < SortExtraFieldsList.Count then
    begin
      str := SortExtraFieldsList[SortExtraFieldsIndex];
      if Length(str) > 0 then
      begin
        if str[1] = '-' then
        begin
          Extra1 := Item2;
          Extra2 := Item1;
          Delete(str, 1, 1);
        end else
        begin
          Extra1 := Item1;
          Extra2 := Item2;
        end;
        if Length(str) > 0 then
        begin
          field := StrToIntDef(str, -1);
          if (field >= extraFieldLow) and (field < extraFieldCount) then
          begin
            case GetFieldType(field) of
              ftInteger, ftReal, ftReal1, ftReal2, ftDate:
                Result := CompareValue(Extra1.GetIntFieldValue(field), Extra2.GetIntFieldValue(field));
              else
                if Settings.rOptions.rDisplay.NaturalCompare then
                  Result := AnsiNatCompareText(Extra1.GetFieldValue(field), Extra2.GetFieldValue(field))
                else
                  Result := AnsiCompareText(Extra1.GetFieldValue(field), Extra2.GetFieldValue(field));
              end // case
          end;
        end;
      end;
      if Result = 0 then
        Result := CompareExtrasAdv(Item1, Item2);
    end
    else if SortExtraForce then
    begin
      Extra1 := Item1;
      Extra2 := Item2;
      if Result = 0 then
        if Settings.rOptions.rDisplay.NaturalCompare then
          Result := AnsiNatCompareText(Extra1.strTitle, Extra2.strTitle)
        else
          Result := AnsiCompareText(Extra1.strTitle, Extra2.strTitle);
      if Result = 0 then
        Result := CompareValue(Extra1.iNumber, Extra2.iNumber);
      if Result = 0 then
        Result := CompareStr(Format('%p', [Item1]), Format('%p', [Item2]));
    end;
  finally
    SortExtraFieldsIndex := -1;
  end; // try
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function CompareExtrasAdvReverse(Item1, Item2: Pointer): Integer;
begin
  Result := CompareExtrasAdv(Item2, Item1);
end;

{$ENDIF}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure WriteString(const str: string; OutputFile: TStream);
var
  recsize: Integer;
begin
  with OutputFile do
  begin
    recsize := Length(str);
    WriteBuffer(recsize, intsize);
    if recsize > 0 then
      WriteBuffer(str[1], recsize);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function ReadString(InputFile: TStream): string;
var
  recsize: Integer;
begin
  with InputFile do
  begin
    ReadBuffer(recsize, intsize);
    if recsize > 0 then
    begin
      SetLength(Result, recsize);
      ReadBuffer(Result[1], recsize);
    end else
      Result := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

initialization
{$IFDEF MSWINDOWS}
  ClipboardMovieFormat := RegisterClipBoardFormat(strClipboardMovieHeader);
  ClipboardExtrasFormat := RegisterClipBoardFormat(strClipboardExtrasHeader);
{$ENDIF}
  GetLocaleFormatSettings(GetThreadLocale, FormatSettings);
  with FormatSettings do
  begin
    ThousandSeparator := #0;
    DecimalSeparator := '.';
    DateSeparator := '-';
    ShortDateFormat := 'yyyy-mm-dd';
    TimeSeparator := ':';
    ShortTimeFormat := 'HH:nn';
    LongTimeFormat := 'HH:nn:ss';
  end;
{$IFDEF DLLMode}
  NaturalCompare := True;
{$ENDIF}
{$IFNDEF DLLMode}
  SortFieldsList := TStringList.Create;
  SortFieldsIndex := -1;
  SortExtraFieldsList := TStringList.Create;
  SortExtraFieldsIndex := -1;
{$ENDIF}
  SortField := -1;
  SortForce := False;
  SortExtraField := -1;
  SortExtraForce := False;
finalization
{$IFNDEF DLLMode}
  SortFieldsList.Free;
  SortExtraFieldsList.Free;
{$ENDIF}
end.

