(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2023 Antoine Potten, Mickaël Vanneufville                 *
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

unit ConstValues;

interface

uses
  Classes, Dialogs, Graphics, SysUtils, Fields;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  strDate = '2023-05-19';
  strErrorParenthesis = '< ?()? >';
  defaultSep = ',';
  defaultExtraSepImport = '<+>';
  defaultExtraSepExport = '<+>';

const
  ddlMediaType        = 0;
  ddlSources          = 1;
  ddlBorrowers        = 2;
  ddlCountry          = 3;
  ddlCategory         = 4;
  ddlVideo            = 5;
  ddlAudio            = 6;
  ddlFramerate        = 7;
  ddlLanguages        = 8;
  ddlSubtitles        = 9;
  ddlCertification    = 10;
  ddlExtrasTag        = 11;
  ddlExtrasCategory   = 12;
  ddlExtrasCreatedBy  = 13;
  ddlCount            = 14;

const
  strFieldsDdl: array [0..ddlCount-1] of Integer =
    ( fieldMediaType, fieldSource, fieldBorrower, fieldCountry,
      fieldCategory, fieldVideoFormat, fieldAudioFormat, fieldFrameRate,
      fieldLanguages, fieldSubtitles, fieldCertification,
      extraFieldTag, extraFieldCategory, extraFieldCreatedBy);
  strXMLDdl: array [0..ddlCount-1] of string =
    ( 'Media', 'Sources', 'Borrowers', 'Country', 'Category',
      'Video', 'Audio', 'Framerate', 'Languages', 'Subtitles', 'Certification',
      'ETag', 'ECategory', 'ECreatedBy' );

const
  // Dialogs
  DialogImageFilter         = 'JPEG, PNG, GIF, BMP (*.jpg, *.jpe, *.jpeg, *.png, *.gif, *.bmp)|*.jpg;*.jpe;*.jpeg;*.png;*.gif;*.bmp';
  DialogScriptFilter        = 'Innerfuse Pascal Scripts (*.ifs, *.pas)|*.ifs;*.pas|Text Files|*.txt|All Files (*.*)|*.*';
  DialogGetInfoFilter       = 'All Supported Files|%0:s;*.film;*.jpg;*.png;*.gif;*.bmp|Video Files|%0:s|Image files|*.jpg;*.jpe;*.jpeg;*.png;*.gif;*.bmp|MovieCovers'' .film Files|*.film|All Files|*.*';
  DialogImportExtrasFilter  = 'All Supported Files|%0:s;*.film;*.jpg;*.png;*.gif;*.bmp|Video Files|%0:s|Image files|*.jpg;*.jpe;*.jpeg;*.png;*.gif;*.bmp|All Files|*.*';
  DialogCatalogFilter       = 'Ant Movie Catalog Files (*.amc, *.xml)|*.amc;*.xml';
  DialogCatalogSaveFilter   = 'Ant Movie Catalog 4.2 (*.amc)|*.amc|Ant Movie Catalog 4.1 (*.amc)|*.amc|Ant Movie Catalog 3.5 (*.amc)|*.amc|XML (*.xml)|*.xml';
  DialogAmcSaveFilter       = 'Ant Movie Catalog 4.2 (*.amc)|*.amc|Ant Movie Catalog 4.1 (*.amc)|*.amc|Ant Movie Catalog 3.5 (*.amc)|*.amc';
  DialogXmlFilter           = 'XML (*.xml)|*.xml';
  DialogCSVFilter           = 'CSV & tab-delimited text|*.csv;*.txt';
  DialogHTMLFilter          = 'HTML Files (*.html, *.htm)|*.html;*.htm';
  DialogSQLFilter           = 'SQL Commands (*.sql, *.txt)|*.sql;*.txt';
  DialogReportFilter        = 'FreeReport Files (*.frf)|*.frf';
  DialogChartFilter         = 'Metafile (*.wmf)|*.wmf|PNG (*.png)|*.png|Bitmap (*.bmp)|*.bmp';
  DialogAnyFileFilter       = 'All Files (*.*)|*.*';
  DialogDivxMgrFilter       = 'eXtreme Movie Manager / Divx Manager (*.mdb)|*.mdb';
  DialogMDBFilter           = 'Microsoft Access Database (*.mdb)|*.mdb';
  DialogGCstarFilter        = 'GCstar Movie Database File (*.gcs)|*.gcs';
  DialogTextFilter          = 'Text Files (*.txt)|*.txt';
  DialogDirFilter           = 'DIR';

  DialogCatalogSaveFilterAMC  = 1;
  DialogCatalogSaveFilterAMC41 = 2;
  DialogCatalogSaveFilterAMC35 = 3;
  DialogCatalogSaveFilterXML  = 4;

  DialogAmcSaveFilterAMC  = 1;
  DialogAmcSaveFilterAMC41 = 2;
  DialogAmcSaveFilterAMC35 = 3;

  DialogChartFilterWMF    = 1;
  DialogChartFilterPNG    = 2;
  DialogChartFilterBMP    = 3;

  DialogOpenOptions = [ofHideReadOnly,ofPathMustExist,ofFileMustExist,ofEnableSizing];
  DialogSaveOptions = [ofOverwritePrompt,ofHideReadOnly,ofPathMustExist,ofNoReadOnlyReturn,ofEnableSizing];

  // Toolbar Icons
type
  TIconIndex = (
  ICON_FILENEW,
  ICON_FILEOPEN,
  ICON_FILESAVE,
  ICON_FILESAVEAS,
  ICON_FILEIMPORT,
  ICON_FILEEXPORT,
  ICON_FILEPRINT,
  ICON_FILEPROPERTIES,
  ICON_MOVIEADD,
  ICON_MOVIENUMBER,
  ICON_MOVIEDELETE,
  ICON_MOVIEFIND,
  ICON_MOVIECOPY,
  ICON_MOVIEPASTE,
  ICON_MOVIEUNDO,
  ICON_MOVIEPICTURE,
  ICON_PICTUREOPEN,
  ICON_PICTURESAVE,
  ICON_PICTURECOPY,
  ICON_PICTUREDELETE,
  ICON_PICTUREUNDOCK,
  ICON_MOVIEIMPORT,
  ICON_MOVIEIMPORTFILES,
  ICON_MOVIEIMPORTSCRIPT,
  ICON_MOVIEIMPORTCD,
  ICON_MOVIESEARCH,
  ICON_SCRIPTING,
  ICON_GRIDMODE,
  ICON_RENUMBER,
  ICON_STATISTICS,
  ICON_LOANS,
  ICON_OPTIONS,
  ICON_LANGUAGES,
  ICON_GROUP,
  ICON_REFRESH,
  ICON_HELP,
  ICON_ABOUT,
  ICON_EXIT,
  ICON_LOANBORROWADD,
  ICON_LOANBORROWDEL,
  ICON_LOANBORROWGET,
  ICON_LOANCHECKIN,
  ICON_LOANCHECKOUT,
  ICON_LOANOPTIONS,
  ICON_LOANFIND,
  ICON_TEMPLATENEW,
  ICON_TEMPLATELOAD,
  ICON_TEMPLATESAVE,
  ICON_TEMPLATESAVEAS,
  ICON_STATSSAVE,
  ICON_STATSCOPY,
  ICON_STATSOPTIONS,
  ICON_SCRIPTNEW,
  ICON_SCRIPTOPEN,
  ICON_SCRIPTSAVE,
  ICON_SCRIPTSAVEAS,
  ICON_SCRIPTSPROPERTIES,
  ICON_SCRIPTFIND,
  ICON_SCRIPTFINDNEXT,
  ICON_DEBUGRUN,
  ICON_DEBUGSTOP,
  ICON_DEBUGBREAKPOINT,
  ICON_DEBUGBREAKCLEAR,
  ICON_DEBUGSTEPOVER,
  ICON_DEBUGRUNTOCURSOR,
  ICON_DEBUGEVALUATE,
  ICON_DEBUGWATCHADD,
  ICON_DEBUGWATCHREMOVE,
  ICON_DEBUGWATCHCLEAR,
  ICON_VIEWFILTER,
  ICON_VIEWLIST,
  ICON_VIEWDETAIL,
  ICON_PRINTREFRESH,
  ICON_PRINTPAGEFIRST,
  ICON_PRINTPAGEPREVIOUS,
  ICON_PRINTPAGENEXT,
  ICON_PRINTPAGELAST,
  ICON_PRINTPAGEFULL,
  ICON_PRINTPAGETWO,
  ICON_PRINTPAGEWIDTH,
  ICON_PRINTLOAD,
  ICON_PRINTZOOMOUT,
  ICON_PRINTZOOMIN,
  ICON_PRINT,
  ICON_PRINTDESIGNER,
  ICON_BROWSE,
  ICON_ROWINSERT,
  ICON_ROWDELETE,
  ICON_MOVEUP,
  ICON_MOVEDOWN,
  ICON_MOVELEFT,
  ICON_MOVERIGHT,
  ICON_MOVELEFTALL,
  ICON_MOVERIGHTALL,
  ICON_RANDOM,
  ICON_HTML,
  ICON_FIELDEDIT,
  ICON_FIELDADD,
  ICON_FIELDDEL,
  ICON_FIELDMOVE,
  ICON_FIELD,
  ICON_MOVIEURL,
  ICON_STRETCHLIST,
  ICON_SORTASCEND,
  ICON_VIEWTHUMBNAILS,
  ICON_INPUT,
  ICON_GROUPSFORMAT,
  ICON_SORTDESCEND,
  ICON_MOVIEEXTRAS,
  ICON_EXTRASADD,
  ICON_EXTRASDEL,
  ICON_EXTRASEDIT,
  ICON_EXTRASIMPORTFILES
  );

const
  ftDefault = 0;
  ftLast    = 1;
  ftUser    = 2;

  fuCatalogs      = 0;
  fuPicture       = 1;
  fuExport        = 2;
  fuTemplates     = 3;
  fuImport        = 4;
  fuGetFromFiles  = 5;
  fuGraphic       = 6;
  fuScripts       = 7;
  fuCustomFields  = 8;
  fuStringFilter  = 9;

const
  extImage: array [0..5] of string =
    ('.png', '.gif', '.jpg', '.jpe', '.jpeg', '.bmp');
  typeImage: array [0..5] of string =
    ('PNG', 'GIF', 'JPEG', 'JPEG', 'JPEG', 'BMP');
  extVideo: array [0..24] of string =
    ('.avi', '.divx', '.xvid', '.mkv', '.ts', '.m2ts', '.m4v',
     '.mpg', '.mpe', '.mpeg', '.mpeg2', '.m2p', '.vob',
     '.mp4', '.3gp', '.wmv',  '.asf',
     '.mov',  '.rm', '.rmvb', '.rv9',
     '.flv', '.evo', '.ogm', '.ifo'); {'.dat', '.ogg',} //???
  extScript: array[0..1] of string =
    ('.ifs', '.pas');
  extCatalog: array[0..1] of string =
    ('.amc', '.xml');
  extChart: array[0..2] of string =
    ('.wmf', '.png', '.bmp');

const
  extAMC = 0;
  extXML = 1;
  extPNG = 0;
  extGIF = 1;
  extJPG = 2;
  extJPE = 3;
  extJPEG = 4;
  extBMP = 5;
  extChWMF = 0;
  extChPNG = 1;
  extchBMP = 2;
  extIFS = 0;
  extPAS = 1;
  extAVI = 0;
  extDIVX = 1;
  extTS = 4;

const
  TAG_FILENAME               ='$$FILENAME';
  TAG_FILEPATH               ='$$FILEPATH';
  TAG_TOTALMOVIES            ='$$TOTALMOVIES';
  TAG_TOTALDISKS             ='$$TOTALDISKS';

  TAG_DATE                   ='$$DATE';
  TAG_TIME                   ='$$TIME';

  TAG_OWNERNAME              ='$$OWNER_NAME';
  TAG_OWNERMAIL              ='$$OWNER_MAIL';
  TAG_OWNERSITE              ='$$OWNER_SITE';
  TAG_DESCRIPTION            ='$$DESCRIPTION';

  TAG_ITEMBEGIN              ='$$ITEM_BEGIN';
  TAG_ITEMEND                ='$$ITEM_END';
  TAG_RECNR                  ='$$ITEM_RECNR';
  TAG_ITEMFILEINDIV          ='$$ITEM_FILEINDIV';
  TAG_ITEMNUMBER             ='$$ITEM_NUMBER';
  TAG_ITEMCHECKED            ='$$ITEM_CHECKED';
  TAG_ITEMMEDIA              ='$$ITEM_MEDIA';
  TAG_ITEMTYPE               ='$$ITEM_TYPE';
  TAG_ITEMSOURCE             ='$$ITEM_SOURCE';
  TAG_ITEMDATEADD            ='$$ITEM_DATEADD';
  TAG_ITEMBORROWER           ='$$ITEM_BORROWER';
  TAG_ITEMAPPRECIATION       ='$$ITEM_APPRECIATION';
  TAG_ITEMAPPR10             ='$$ITEM_APPR10';
  TAG_ITEMRATING4            ='$$ITEM_RATING4';
  TAG_ITEMRATING10           ='$$ITEM_RATING10';
  TAG_ITEMRATING             ='$$ITEM_RATING';
  TAG_ITEMORIGINALTITLE      ='$$ITEM_ORIGINALTITLE';
  TAG_ITEMTRANSLATEDTITLE    ='$$ITEM_TRANSLATEDTITLE';
  TAG_ITEMFORMATTEDTITLE1    ='$$ITEM_FORMATTEDTITLE1';
  TAG_ITEMFORMATTEDTITLE2    ='$$ITEM_FORMATTEDTITLE2';
  TAG_ITEMFORMATTEDTITLE     ='$$ITEM_FORMATTEDTITLE';
  TAG_ITEMDIRECTOR           ='$$ITEM_DIRECTOR';
  TAG_ITEMPRODUCER           ='$$ITEM_PRODUCER';
  TAG_ITEMCOUNTRY            ='$$ITEM_COUNTRY';
  TAG_ITEMCATEGORY           ='$$ITEM_CATEGORY';
  TAG_ITEMYEAR               ='$$ITEM_YEAR';
  TAG_ITEMLENGTH             ='$$ITEM_LENGTH';
  TAG_ITEMACTORS             ='$$ITEM_ACTORS';
  TAG_ITEMURL                ='$$ITEM_URL';
  TAG_ITEMDESCRIPTION        ='$$ITEM_DESCRIPTION';
  TAG_ITEMCOMMENTS           ='$$ITEM_COMMENTS';
  TAG_ITEMFORMAT             ='$$ITEM_FORMAT';
  TAG_ITEMVIDEOFORMAT        ='$$ITEM_VIDEOFORMAT';
  TAG_ITEMVIDEOBITRATE       ='$$ITEM_VIDEOBITRATE';
  TAG_ITEMAUDIOFORMAT        ='$$ITEM_AUDIOFORMAT';
  TAG_ITEMAUDIOBITRATE       ='$$ITEM_AUDIOBITRATE';
  TAG_ITEMRESOLUTION         ='$$ITEM_RESOLUTION';
  TAG_ITEMFRAMERATE          ='$$ITEM_FRAMERATE';
  TAG_ITEMLANGUAGES          ='$$ITEM_LANGUAGES';
  TAG_ITEMSUBTITLES          ='$$ITEM_SUBTITLES';
  TAG_ITEMSIZE               ='$$ITEM_SIZE';
  TAG_ITEMDISKS              ='$$ITEM_DISKS';
  TAG_ITEMCOLORTAG           ='$$ITEM_COLORTAG';
  TAG_ITEMCOLORHTML          ='$$ITEM_COLORHTML';
  TAG_ITEMPICTURE            ='$$ITEM_PICTURE';
  TAG_ITEMPICTURENP          ='$$ITEM_PICTURE_NP';
  TAG_ITEMPICTUREFILENAME    ='$$ITEM_PICTUREFILENAME';
  TAG_ITEMPICTUREFILENAMENP  ='$$ITEM_PICTUREFILENAME_NP';

  TAG_ITEMDATEWATCHED        ='$$ITEM_DATEWATCHED';
  TAG_ITEMUSERAPPR4          ='$$ITEM_USERAPPR4';
  TAG_ITEMUSERAPPR10         ='$$ITEM_USERAPPR10';
  TAG_ITEMUSERRATING4        ='$$ITEM_USERRATING4';
  TAG_ITEMUSERRATING10       ='$$ITEM_USERRATING10';
  TAG_ITEMUSERRATING         ='$$ITEM_USERRATING';
  TAG_ITEMWRITER             ='$$ITEM_WRITER';
  TAG_ITEMCOMPOSER           ='$$ITEM_COMPOSER';
  TAG_ITEMCERTIFICATION      ='$$ITEM_CERTIFICATION';
  TAG_ITEMFILEPATH           ='$$ITEM_FILEPATH';
  TAG_ITEMPICTURESTATUS      ='$$ITEM_PICTURESTATUS';
  TAG_ITEMNBEXTRAS           ='$$ITEM_NBEXTRAS';

  TAG_LABELNUMBER            ='$$LABEL_NUMBER';
  TAG_LABELCHECKED           ='$$LABEL_CHECKED';
  TAG_LABELMEDIA             ='$$LABEL_MEDIA';
  TAG_LABELTYPE              ='$$LABEL_TYPE';
  TAG_LABELSOURCE            ='$$LABEL_SOURCE';
  TAG_LABELDATEADD           ='$$LABEL_DATEADD';
  TAG_LABELBORROWER          ='$$LABEL_BORROWER';
  TAG_LABELRATING            ='$$LABEL_RATING';
  TAG_LABELORIGINALTITLE     ='$$LABEL_ORIGINALTITLE';
  TAG_LABELTRANSLATEDTITLE   ='$$LABEL_TRANSLATEDTITLE';
  TAG_LABELFORMATTEDTITLE    ='$$LABEL_FORMATTEDTITLE';
  TAG_LABELDIRECTOR          ='$$LABEL_DIRECTOR';
  TAG_LABELPRODUCER          ='$$LABEL_PRODUCER';
  TAG_LABELCOUNTRY           ='$$LABEL_COUNTRY';
  TAG_LABELCATEGORY          ='$$LABEL_CATEGORY';
  TAG_LABELYEAR              ='$$LABEL_YEAR';
  TAG_LABELLENGTH            ='$$LABEL_LENGTH';
  TAG_LABELACTORS            ='$$LABEL_ACTORS';
  TAG_LABELURL               ='$$LABEL_URL';
  TAG_LABELDESCRIPTION       ='$$LABEL_DESCRIPTION';
  TAG_LABELCOMMENTS          ='$$LABEL_COMMENTS';
  TAG_LABELVIDEOFORMAT       ='$$LABEL_VIDEOFORMAT';
  TAG_LABELVIDEOBITRATE      ='$$LABEL_VIDEOBITRATE';
  TAG_LABELAUDIOFORMAT       ='$$LABEL_AUDIOFORMAT';
  TAG_LABELAUDIOBITRATE      ='$$LABEL_AUDIOBITRATE';
  TAG_LABELRESOLUTION        ='$$LABEL_RESOLUTION';
  TAG_LABELFRAMERATE         ='$$LABEL_FRAMERATE';
  TAG_LABELLANGUAGES         ='$$LABEL_LANGUAGES';
  TAG_LABELSUBTITLES         ='$$LABEL_SUBTITLES';
  TAG_LABELSIZE              ='$$LABEL_SIZE';
  TAG_LABELDISKS             ='$$LABEL_DISKS';
  TAG_LABELCOLORTAG          ='$$LABEL_COLORTAG';
  TAG_LABELPICTURE           ='$$LABEL_PICTURE';
  TAG_LABELAUDIOKBPS         ='$$LABEL_AUDIOKBPS';
  TAG_LABELVIDEOKBPS         ='$$LABEL_VIDEOKBPS';
  TAG_LABELUNIT              ='$$LABEL_UNIT';
  TAG_LABELFPS               ='$$LABEL_FPS';
  
  TAG_LABELDATEWATCHED       ='$$LABEL_DATEWATCHED';
  TAG_LABELUSERRATING        ='$$LABEL_USERRATING';
  TAG_LABELWRITER            ='$$LABEL_WRITER';
  TAG_LABELCOMPOSER          ='$$LABEL_COMPOSER';
  TAG_LABELCERTIFICATION     ='$$LABEL_CERTIFICATION';
  TAG_LABELFILEPATH          ='$$LABEL_FILEPATH';
  TAG_LABELPICTURESTATUS     ='$$LABEL_PICTURESTATUS';
  TAG_LABELNBEXTRAS          ='$$LABEL_NBEXTRAS';

  // Do not add to strListTags !
  // This is just the start model for custom fields tag.
  TAG_ITEM_CF                ='$$ITEM_CF_';
  TAG_LABEL_CF               ='$$LABEL_CF_';
  
  TAG_ITEMEXTRABEGIN         ='$$ITEM_EXTRA_BEGIN';
  TAG_ITEMEXTRAEND           ='$$ITEM_EXTRA_END';
  TAG_ITEMEXTRARECNR         ='$$ITEM_EXTRA_RECNR';
  TAG_ITEMEXTRANUMBER        ='$$ITEM_EXTRA_NUMBER';
  TAG_ITEMEXTRACHECKED       ='$$ITEM_EXTRA_CHECKED';
  TAG_ITEMEXTRATAG           ='$$ITEM_EXTRA_TAG';
  TAG_ITEMEXTRATITLE         ='$$ITEM_EXTRA_TITLE';
  TAG_ITEMEXTRACATEGORY      ='$$ITEM_EXTRA_CATEGORY';
  TAG_ITEMEXTRAURL           ='$$ITEM_EXTRA_URL';
  TAG_ITEMEXTRADESCRIPTION   ='$$ITEM_EXTRA_DESCRIPTION';
  TAG_ITEMEXTRACOMMENTS      ='$$ITEM_EXTRA_COMMENTS';
  TAG_ITEMEXTRACREATEDBY     ='$$ITEM_EXTRA_CREATEDBY';
  TAG_ITEMEXTRAPICSTATUS     ='$$ITEM_EXTRA_PICSTATUS';
  TAG_ITEMEXTRAPICTURE       ='$$ITEM_EXTRA_PICTURE';
  TAG_ITEMEXTRAPICTURENP     ='$$ITEM_EXTRA_PICTURE_NP';
  TAG_ITEMEXTRAPICFILENAME   ='$$ITEM_EXTRA_PICFILENAME';
  TAG_ITEMEXTRAPICFILENAMENP ='$$ITEM_EXTRA_PICFILENAME_NP';

  TAG_LABELEXTRANUMBER       ='$$LABEL_EXTRA_NUMBER';
  TAG_LABELEXTRACHECKED      ='$$LABEL_EXTRA_CHECKED';
  TAG_LABELEXTRATAG          ='$$LABEL_EXTRA_TAG';
  TAG_LABELEXTRATITLE        ='$$LABEL_EXTRA_TITLE';
  TAG_LABELEXTRACATEGORY     ='$$LABEL_EXTRA_CATEGORY';
  TAG_LABELEXTRAURL          ='$$LABEL_EXTRA_URL';
  TAG_LABELEXTRADESCRIPTION  ='$$LABEL_EXTRA_DESCRIPTION';
  TAG_LABELEXTRACOMMENTS     ='$$LABEL_EXTRA_COMMENTS';
  TAG_LABELEXTRACREATEDBY    ='$$LABEL_EXTRA_CREATEDBY';
  TAG_LABELEXTRAPICSTATUS    ='$$LABEL_EXTRA_PICSTATUS';
  TAG_LABELEXTRAPICTURE      ='$$LABEL_EXTRA_PICTURE';
  
var
  isPortableVersion: Boolean;
  strAppExe: TFileName;
  strVersion: TFileName;
  strFullVersion: TFileName;

  strDirApp: TFileName;
  strDirData: TFileName;
  strDirDocs: TFileName;
  strDirToolbars: TFileName;
  strDirLanguages: TFileName;
  strDirTemplates: TFileName;
  strDirScripts: TFileName;
  strDirCatalogs: TFileName;
  
  strFileDesigner: TFileName;
  strFileDesignerConfig: TFileName;
  strFileExchangeDLL: TFileName;
  strFileMediaInfoDLL: TFileName;
  strFileSettings: TFileName;
  strFileDefault: TFileName;
  strFileCodecs: TFileName;
  strFileScriptsCache: TFileName;
  strFileHelp: TFileName;
  strFileNoPicture: TFileName;
  strFileNoPicture2: TFileName;
  strFileNotFound: TFileName;
  strFileNotFound2: TFileName;
  strFileHtmlDisplayExcludedTemplates: TFileName;

  strListTags: TStringList;
  strListExtraTags: TStringList;
  strPosterNames: TStringList;
  strFilterFileName: TStringList;

function GetExtVideo: String;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  functions_files, functions_str, functions_sys, Shfolder;

function GetExtVideo: String;
var
  i: Integer;
begin
  Result := '';
  if Length(extVideo) > 0 then
    Result := extVideo[0];
  for i := 1 to Length(extVideo)-1 do
    Result := Result + ' ' + extVideo[i];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

initialization
  strAppExe := ParamStr(0);
  strDirApp := ExtractFilePath(strAppExe);
  strFullVersion := GetBuild4(strAppExe);
  strVersion := Copy(strFullVersion, 1, LastPos('.', strFullVersion) - 1);
  isPortableVersion := FileExists(strDirApp + 'default.xml') or FileExists(strDirApp + 'prefs.xml');
  if (isPortableVersion) or (Win32MajorVersion < 5) or
    (not DirectoryExists(GetFolderPath(CSIDL_COMMON_APPDATA) + 'Ant Movie Catalog\')) then
  begin     // Portable version or Installed version without data folder
    strDirData := strDirApp;
    strDirDocs := strDirApp;
  end else  // Installed version
  begin
    strDirDocs := GetFolderPath(CSIDL_PERSONAL);
    strDirData := GetFolderPath(CSIDL_COMMON_APPDATA) + 'Ant Movie Catalog\'
  end;

  strDirToolbars := strDirApp + 'Toolbars\';
  strDirLanguages := strDirApp + 'Languages\';
  strDirTemplates := strDirData + 'Templates\';
  strDirScripts := strDirData + 'Scripts\';
  strDirCatalogs := strDirDocs + 'Catalogs\';
  if not DirectoryExists(strDirCatalogs) then
    strDirCatalogs := strDirDocs;

  strFileDesigner := strDirApp + 'AMCReport.exe';
  strFileExchangeDLL := strDirApp + 'AMCExchange.dll';
  strFileMediaInfoDLL := strDirApp + 'MediaInfo.dll';

  strFileSettings := strDirData + 'prefs.xml';
  strFileDefault := strDirData + 'default.xml';
  strFileCodecs := strDirData + 'Codecs.ini';
  strFileScriptsCache := strDirData + 'scripts.ini';
  strFileDesignerConfig := strDirData + 'AMCReport.ini';

  strFileHelp := strDirLanguages + 'English.chm';

  strFileNoPicture  := strDirTemplates + 'nopicture.png';
  strFileNoPicture2 := strDirTemplates + 'nopicture2.png';
  strFileNotFound   := strDirTemplates + 'filenotfound.png';
  strFileNotFound2  := strDirTemplates + 'filenotfound2.png';

  strFileHtmlDisplayExcludedTemplates := strDirTemplates + 'HtmlDisplayExcludedTemplates.txt';

  strListTags := TStringList.Create;
  strListTags.CaseSensitive := False;
  strListTags.Add(TAG_FILENAME);
  strListTags.Add(TAG_FILEPATH);
  strListTags.Add(TAG_TOTALMOVIES);        
  strListTags.Add(TAG_TOTALDISKS);         
  strListTags.Add(TAG_DATE);               
  strListTags.Add(TAG_TIME);               
  strListTags.Add(TAG_OWNERNAME);          
  strListTags.Add(TAG_OWNERMAIL);          
  strListTags.Add(TAG_OWNERSITE);          
  strListTags.Add(TAG_DESCRIPTION);        
  strListTags.Add(TAG_ITEMBEGIN);          
  strListTags.Add(TAG_ITEMEND);            
  strListTags.Add(TAG_RECNR);              
  strListTags.Add(TAG_ITEMFILEINDIV);      
  strListTags.Add(TAG_ITEMNUMBER);         
  strListTags.Add(TAG_ITEMCHECKED);
  strListTags.Add(TAG_ITEMCOLORTAG);
  strListTags.Add(TAG_ITEMCOLORHTML);
  strListTags.Add(TAG_ITEMMEDIA);          
  strListTags.Add(TAG_ITEMTYPE);           
  strListTags.Add(TAG_ITEMSOURCE);         
  strListTags.Add(TAG_ITEMDATEADD);        
  strListTags.Add(TAG_ITEMBORROWER);
  strListTags.Add(TAG_ITEMDATEWATCHED);
  strListTags.Add(TAG_ITEMUSERAPPR4);
  strListTags.Add(TAG_ITEMUSERAPPR10);
  strListTags.Add(TAG_ITEMUSERRATING4);
  strListTags.Add(TAG_ITEMUSERRATING10);  
  strListTags.Add(TAG_ITEMUSERRATING);  
  strListTags.Add(TAG_ITEMAPPRECIATION);
  strListTags.Add(TAG_ITEMAPPR10);
  strListTags.Add(TAG_ITEMRATING4);
  strListTags.Add(TAG_ITEMRATING10);
  strListTags.Add(TAG_ITEMRATING);
  strListTags.Add(TAG_ITEMORIGINALTITLE);
  strListTags.Add(TAG_ITEMTRANSLATEDTITLE);
  strListTags.Add(TAG_ITEMFORMATTEDTITLE1);
  strListTags.Add(TAG_ITEMFORMATTEDTITLE2);
  strListTags.Add(TAG_ITEMFORMATTEDTITLE); 
  strListTags.Add(TAG_ITEMDIRECTOR);       
  strListTags.Add(TAG_ITEMPRODUCER);
  strListTags.Add(TAG_ITEMWRITER);       
  strListTags.Add(TAG_ITEMCOMPOSER);
  strListTags.Add(TAG_ITEMACTORS);
  strListTags.Add(TAG_ITEMCOUNTRY);      
  strListTags.Add(TAG_ITEMYEAR);           
  strListTags.Add(TAG_ITEMLENGTH);
  strListTags.Add(TAG_ITEMCATEGORY);
  strListTags.Add(TAG_ITEMCERTIFICATION);   
  strListTags.Add(TAG_ITEMURL);            
  strListTags.Add(TAG_ITEMDESCRIPTION);    
  strListTags.Add(TAG_ITEMCOMMENTS);
  strListTags.Add(TAG_ITEMFILEPATH);  
  strListTags.Add(TAG_ITEMFORMAT);         
  strListTags.Add(TAG_ITEMVIDEOFORMAT);    
  strListTags.Add(TAG_ITEMVIDEOBITRATE);   
  strListTags.Add(TAG_ITEMAUDIOFORMAT);    
  strListTags.Add(TAG_ITEMAUDIOBITRATE);   
  strListTags.Add(TAG_ITEMRESOLUTION);     
  strListTags.Add(TAG_ITEMFRAMERATE);      
  strListTags.Add(TAG_ITEMLANGUAGES);      
  strListTags.Add(TAG_ITEMSUBTITLES);      
  strListTags.Add(TAG_ITEMSIZE);
  strListTags.Add(TAG_ITEMDISKS);
  strListTags.Add(TAG_ITEMPICTURESTATUS);
  strListTags.Add(TAG_ITEMNBEXTRAS);
  strListTags.Add(TAG_ITEMPICTUREFILENAMENP); // Warning put before TAG_ITEMPICTUREFILENAME !
  strListTags.Add(TAG_ITEMPICTUREFILENAME);   // Warning put before TAG_ITEMPICTURE2 !
  strListTags.Add(TAG_ITEMPICTURENP);         // Warning put before TAG_ITEMPICTURE !
  strListTags.Add(TAG_ITEMPICTURE);

  strListTags.Add(TAG_LABELNUMBER);          
  strListTags.Add(TAG_LABELCHECKED);
  strListTags.Add(TAG_LABELCOLORTAG);
  strListTags.Add(TAG_LABELMEDIA);           
  strListTags.Add(TAG_LABELTYPE);            
  strListTags.Add(TAG_LABELSOURCE);          
  strListTags.Add(TAG_LABELDATEADD);         
  strListTags.Add(TAG_LABELBORROWER);
  strListTags.Add(TAG_LABELDATEWATCHED);
  strListTags.Add(TAG_LABELUSERRATING);   
  strListTags.Add(TAG_LABELRATING);          
  strListTags.Add(TAG_LABELORIGINALTITLE);
  strListTags.Add(TAG_LABELTRANSLATEDTITLE);
  strListTags.Add(TAG_LABELFORMATTEDTITLE);
  strListTags.Add(TAG_LABELDIRECTOR);        
  strListTags.Add(TAG_LABELPRODUCER);
  strListTags.Add(TAG_LABELWRITER);        
  strListTags.Add(TAG_LABELCOMPOSER);
  strListTags.Add(TAG_LABELACTORS);
  strListTags.Add(TAG_LABELCOUNTRY);         
  strListTags.Add(TAG_LABELYEAR);            
  strListTags.Add(TAG_LABELLENGTH);
  strListTags.Add(TAG_LABELCATEGORY);
  strListTags.Add(TAG_LABELCERTIFICATION);  
  strListTags.Add(TAG_LABELURL);             
  strListTags.Add(TAG_LABELDESCRIPTION);     
  strListTags.Add(TAG_LABELCOMMENTS);
  strListTags.Add(TAG_LABELFILEPATH);  
  strListTags.Add(TAG_LABELVIDEOFORMAT);     
  strListTags.Add(TAG_LABELVIDEOBITRATE);    
  strListTags.Add(TAG_LABELAUDIOFORMAT);     
  strListTags.Add(TAG_LABELAUDIOBITRATE);    
  strListTags.Add(TAG_LABELRESOLUTION);      
  strListTags.Add(TAG_LABELFRAMERATE);       
  strListTags.Add(TAG_LABELLANGUAGES);       
  strListTags.Add(TAG_LABELSUBTITLES);       
  strListTags.Add(TAG_LABELSIZE);            
  strListTags.Add(TAG_LABELDISKS);
  strListTags.Add(TAG_LABELPICTURESTATUS);
  strListTags.Add(TAG_LABELNBEXTRAS);
  strListTags.Add(TAG_LABELPICTURE);         
  strListTags.Add(TAG_LABELAUDIOKBPS);       
  strListTags.Add(TAG_LABELVIDEOKBPS);       
  strListTags.Add(TAG_LABELUNIT);            
  strListTags.Add(TAG_LABELFPS);
  
  strListExtraTags := TStringList.Create;
  strListExtraTags.CaseSensitive := False;
  strListExtraTags.Add(TAG_ITEMEXTRABEGIN);
  strListExtraTags.Add(TAG_ITEMEXTRAEND);
  strListExtraTags.Add(TAG_ITEMEXTRARECNR);
  strListExtraTags.Add(TAG_ITEMEXTRANUMBER);
  strListExtraTags.Add(TAG_ITEMEXTRACHECKED);
  strListExtraTags.Add(TAG_ITEMEXTRATAG);
  strListExtraTags.Add(TAG_ITEMEXTRATITLE);
  strListExtraTags.Add(TAG_ITEMEXTRACATEGORY);
  strListExtraTags.Add(TAG_ITEMEXTRAURL);
  strListExtraTags.Add(TAG_ITEMEXTRADESCRIPTION);
  strListExtraTags.Add(TAG_ITEMEXTRACOMMENTS);
  strListExtraTags.Add(TAG_ITEMEXTRACREATEDBY);
  strListExtraTags.Add(TAG_ITEMEXTRAPICSTATUS);
  strListExtraTags.Add(TAG_ITEMEXTRAPICFILENAMENP); // Warning put before TAG_ITEMEXTRAPICFILENAME !
  strListExtraTags.Add(TAG_ITEMEXTRAPICFILENAME);
  strListExtraTags.Add(TAG_ITEMEXTRAPICTURENP);     // Warning put before TAG_ITEMEXTRAPICTURE !
  strListExtraTags.Add(TAG_ITEMEXTRAPICTURE);

  strListExtraTags.Add(TAG_LABELEXTRANUMBER);
  strListExtraTags.Add(TAG_LABELEXTRACHECKED);
  strListExtraTags.Add(TAG_LABELEXTRATAG);
  strListExtraTags.Add(TAG_LABELEXTRATITLE);
  strListExtraTags.Add(TAG_LABELEXTRACATEGORY);
  strListExtraTags.Add(TAG_LABELEXTRAURL);
  strListExtraTags.Add(TAG_LABELEXTRADESCRIPTION);
  strListExtraTags.Add(TAG_LABELEXTRACOMMENTS);
  strListExtraTags.Add(TAG_LABELEXTRACREATEDBY);
  strListExtraTags.Add(TAG_LABELEXTRAPICSTATUS);
  strListExtraTags.Add(TAG_LABELEXTRAPICTURE);

  strPosterNames := TStringList.Create;
  strPosterNames.Add('Poster');
  strPosterNames.Add('Picture');
  strPosterNames.Add('Cover');
  strPosterNames.Add('Folder');
  strPosterNames.Add('Movie');
  strPosterNames.Add('Film');

  strFilterFileName := TStringList.Create;
  strFilterFileName.Add('::>^(.*)$ # Add begin/end space to string=::> $1 ');
  strFilterFileName.Add('::>www\.([a-z0-9]*)(-[a-z0-9]+)?(\.[a-z]+)?[ ]+ # Remove URL=');
  strFilterFileName.Add('::>([a-z0-9]*)(-[a-z0-9]+)?\.(com|net|org)[ ]+ # Remove URL=');
  strFilterFileName.Add('::>\[.*\] # Remove content in brakets= ');
  strFilterFileName.Add('::>\(.*\).* # Remove content in parentheses and right part= ');
  strFilterFileName.Add('::>[-_.,()\[\]&+] # Replace special chars by spaces= ');
  strFilterFileName.Add('::>(cd|dvd|xvid|divx)[0-9]{1,3} # Remove disk tag= ');
  strFilterFileName.Add('::>\s([1-2][0-9]{3})\s.* # Remove year and right part= ');
  strFilterFileName.Add('::> dvd.* # Remove dvd and right part= ');
  strFilterFileName.Add('::> hd.*= ');
  strFilterFileName.Add('::> bd.*= ');
  strFilterFileName.Add('::> bluray.*= ');
  strFilterFileName.Add('::> brrip.*= ');
  strFilterFileName.Add('::> webrip.*= ');
  strFilterFileName.Add('::> divx.*= ');
  strFilterFileName.Add('::> xvid.*= ');
  strFilterFileName.Add('::> x264.*= ');
  strFilterFileName.Add('::> h264.*= ');
  strFilterFileName.Add('::> avc .*= ');
  strFilterFileName.Add('::> r5.*= ');
  strFilterFileName.Add('::> r6.*= ');
  strFilterFileName.Add('::> 720p.*= ');
  strFilterFileName.Add('::> 1080p.* = ');
  strFilterFileName.Add('::> 3d .*= ');
  strFilterFileName.Add('::> mp3.*= ');
  strFilterFileName.Add('::> aac.*= ');
  strFilterFileName.Add('::> ac3.*= ');
  strFilterFileName.Add('::> ac3d.*= ');
  strFilterFileName.Add('::> dts.*= ');
  strFilterFileName.Add(' multi = ');
  strFilterFileName.Add(' vost = ');
  strFilterFileName.Add(' vo = ');
  strFilterFileName.Add(' subbed = ');
  strFilterFileName.Add(' subforced = ');
  strFilterFileName.Add(' vff = ');
  strFilterFileName.Add(' vfq = ');
  strFilterFileName.Add(' fr = ');
  strFilterFileName.Add(' french = ');
  strFilterFileName.Add(' truefrench = ');
  strFilterFileName.Add(' tf = ');
  strFilterFileName.Add(' vostfr = ');
  strFilterFileName.Add(' vost = ');
  strFilterFileName.Add(' english = ');
  strFilterFileName.Add(' spanich = ');
  strFilterFileName.Add(' german = ');
  strFilterFileName.Add(' swedish = ');
  strFilterFileName.Add(' extended = ');
  strFilterFileName.Add(' edition = ');
  strFilterFileName.Add(' uncut = ');
  strFilterFileName.Add(' director''s = ');
  strFilterFileName.Add(' director = ');
  strFilterFileName.Add(' cut = ');
  strFilterFileName.Add(' dc = ');
  strFilterFileName.Add(' remastered = ');
  strFilterFileName.Add(' unrated = ');
  strFilterFileName.Add(' limited = ');
  strFilterFileName.Add(' festival = ');
  strFilterFileName.Add(' int = ');
  strFilterFileName.Add(' internal = ');
  strFilterFileName.Add(' dubbed = ');
  strFilterFileName.Add(' repack = ');
  strFilterFileName.Add(' rerip = ');
  strFilterFileName.Add(' real = ');
  strFilterFileName.Add(' proper = ');
  strFilterFileName.Add(' fixed = ');
  strFilterFileName.Add(' stv = ');
  strFilterFileName.Add(' ws = ');
  strFilterFileName.Add(' 1cd = ');
  strFilterFileName.Add('::>(?-i)([a-z])([A-Z]) # Insert space between lower/UPPER char=::>$1 $2');
  strFilterFileName.Add('::>(^|\S)([ ]{2,})($|\S) # Replace multi spaces by 1 space=::>$1 $3');
  strFilterFileName.Add('::>^([ ]*)(\S.*\S)([ ]*)$ # Remove begin/end spaces from string=::>$2');

finalization
  strListTags.Free;
  strListExtraTags.Free;
  strFilterFileName.Free;
end.
