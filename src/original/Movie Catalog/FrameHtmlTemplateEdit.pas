(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2012-2017 Antoine Potten, Mickaël Vanneufville                 *
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

unit FrameHtmlTemplateEdit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ShellAPI, ImgList, ComCtrls, Menus,
  ActnList,

  AntCorelButton, AntStringList, AntJvLabel, AntJvHotLink,
  TB2Item, TBX, TB2MRU, TBXExtItems,
  TB2Dock, TB2Toolbar, AntAutoHintLabel, AntJvLinkLabel,
  SynEdit, SynEditHighlighter, SynHighlighterHtml,

  framefields, MovieClass, FileManager, base, ConstValues;

type
  THTMLTemplateEdit = class(TFrame)
    ETemplate: TSynEdit;
    ActionList1: TActionList;
    ActionDisplayFull: TAction;
    ActionDisplayIndividual: TAction;
    ActionHTMLNew: TAction;
    ActionHTMLOpen: TAction;
    ActionHTMLSave: TAction;
    ActionHTMLSaveAs: TAction;
    ActionHTMLNoRecent: TAction;
    ActionInsertTag: TAction;
    ActionEditUndo: TAction;
    ActionEditCut: TAction;
    ActionEditCopy: TAction;
    ActionEditPaste: TAction;
    ActionEditDelete: TAction;
    ActionEditSelectAll: TAction;
    ActionExportBoth: TAction;
    ActionExportSelected: TAction;
    TBDock1: TTBXDock;
    ToolbarHTML: TTBXToolbar;
    BtnNewTemplate: TTBXItem;
    BtnLoadTemplate: TTBXSubmenuItem;
    BtnNoRecentTemplate: TTBXItem;
    TBMRUListItem1: TTBXMRUListItem;
    BtnSaveTemplate: TTBXItem;
    BtnSaveAsTemplate: TTBXItem;
    btnSeparator1: TTBXSeparatorItem;
    BtnInsertTag: TTBXSubmenuItem;
    MnuGen: TTBXSubmenuItem;
    MnuGenDte: TTBXItem;
    MnuGenTme: TTBXItem;
    MnuCat: TTBXSubmenuItem;
    MnuCatNme: TTBXItem;
    MnuCatPth: TTBXItem;
    MnuCatNbr: TTBXItem;
    MnuCatDsk: TTBXItem;
    MnuCat__1: TTBXSeparatorItem;
    MnuOwnNam: TTBXItem;
    MnuOwnEml: TTBXItem;
    MnuOwnWeb: TTBXItem;
    MnuCatDsc: TTBXItem;
    MnuCat__2: TTBXSeparatorItem;
    MnuMovBeg: TTBXItem;
    MnuMovEnd: TTBXItem;
    MnuMovRec: TTBXItem;
    MnuMovInd: TTBXItem;
    MnuMov: TTBXSubmenuItem;
    MnuMovNum: TTBXItem;
    MnuMovChk: TTBXItem;
    MnuMovMed: TTBXItem;
    MnuMovTyp: TTBXItem;
    MnuMovSrc: TTBXItem;
    MnuMovDte: TTBXItem;
    MnuMovBor: TTBXItem;
    MnuMovRat: TTBXItem;
    MnuMovR04: TTBXItem;
    MnuMovR10: TTBXItem;
    MnuMovApp: TTBXItem;
    MnuMovA10: TTBXItem;
    MnuMovOrT: TTBXItem;
    MnuMovTrT: TTBXItem;
    MnuMovFoT: TTBXItem;
    MnuMovFT1: TTBXItem;
    MnuMovFT2: TTBXItem;
    MnuMovDir: TTBXItem;
    MnuMovPro: TTBXItem;
    MnuMovCou: TTBXItem;
    MnuMovCat: TTBXItem;
    MnuMovYea: TTBXItem;
    MnuMovLen: TTBXItem;
    MnuMovAct: TTBXItem;
    MnuMovURL: TTBXItem;
    MnuMovDsc: TTBXItem;
    MnuMovCom: TTBXItem;
    MnuMovVfm: TTBXItem;
    MnuMovVbr: TTBXItem;
    MnuMovAfm: TTBXItem;
    MnuMovAbr: TTBXItem;
    MnuMovRes: TTBXItem;
    MnuMovFps: TTBXItem;
    MnuMovLng: TTBXItem;
    MnuMovSub: TTBXItem;
    MnuMovSiz: TTBXItem;
    MnuMovDsk: TTBXItem;
    MnuMovCol: TTBXItem;
    MnuMovHtm: TTBXItem;
    MnuMovPic: TTBXItem;
    MnuMovPfn: TTBXItem;
    MnuMovCF: TTBXSubmenuItem;
    MnuLab: TTBXSubmenuItem;
    MnuLabNum: TTBXItem;
    MnuLabChk: TTBXItem;
    MnuLabMed: TTBXItem;
    MnuLabTyp: TTBXItem;
    MnuLabSrc: TTBXItem;
    MnuLabDte: TTBXItem;
    MnuLabBor: TTBXItem;
    MnuLabRat: TTBXItem;
    MnuLabOrT: TTBXItem;
    MnuLabTrT: TTBXItem;
    MnuLabFoT: TTBXItem;
    MnuLabDir: TTBXItem;
    MnuLabPro: TTBXItem;
    MnuLabCou: TTBXItem;
    MnuLabCat: TTBXItem;
    MnuLabYea: TTBXItem;
    MnuLabLen: TTBXItem;
    MnuLabAct: TTBXItem;
    MnuLabURL: TTBXItem;
    MnuLabDsc: TTBXItem;
    MnuLabCom: TTBXItem;
    MnuLabVfm: TTBXItem;
    MnuLabVbr: TTBXItem;
    MnuLabAfm: TTBXItem;
    MnuLabAbr: TTBXItem;
    MnuLabRes: TTBXItem;
    MnuLabFps: TTBXItem;
    MnuLabLng: TTBXItem;
    MnuLabSub: TTBXItem;
    MnuLabSiz: TTBXItem;
    MnuLabDsk: TTBXItem;
    MnuLabCol: TTBXItem;
    MnuLabPic: TTBXItem;
    MnuLabUAF: TTBXItem;
    MnuLabUVF: TTBXItem;
    MnuLabUFS: TTBXItem;
    MnuLabUFP: TTBXItem;
    MnuLabCF: TTBXSubmenuItem;
    btnSeparator2: TTBXSeparatorItem;
    LHTMLTemplateFileName: TTBXLabelItem;
    TBToolbar1: TTBXToolbar;
    btnDisplayFull: TTBXItem;
    btnDisplayIndividual: TTBXItem;
    TBSeparatorItem4: TTBXSeparatorItem;
    btnHTMLExport: TTBXSubmenuItem;
    btnHTMLExportBoth: TTBXItem;
    btnHTMLExportSelected: TTBXItem;
    Messages: TAntStringList;
    TBMRUList1: TTBXMRUList;
    SynHTMLSyn1: TSynHTMLSyn;
    PopupHTML: TTBXPopupMenu;
    TBSubmenuItem1: TTBXSubmenuItem;
    TBSeparatorItem3: TTBXSeparatorItem;
    HtmEdtUnd: TTBXItem;
    TBSeparatorItem1: TTBXSeparatorItem;
    HtmEdtCut: TTBXItem;
    HtmEdtCpy: TTBXItem;
    HtmEdtPst: TTBXItem;
    TBSeparatorItem2: TTBXSeparatorItem;
    HtmEdtSel: TTBXItem;
    MnuMovURat: TTBXItem;
    MnuMovUR04: TTBXItem;
    MnuMovUR10: TTBXItem;
    MnuMovUA04: TTBXItem;
    MnuMovUA10: TTBXItem;
    MnuMovDtW: TTBXItem;
    MnuMovCmp: TTBXItem;
    MnuMovWrt: TTBXItem;
    MnuMovCer: TTBXItem;
    MnuMovFil: TTBXItem;
    MnuMovNbE: TTBXItem;
    MnuMovPst: TTBXItem;
    MnuLabDtW: TTBXItem;
    MnuLabURat: TTBXItem;
    MnuLabWrt: TTBXItem;
    MnuLabCmp: TTBXItem;
    MnuLabCer: TTBXItem;
    MnuLabFil: TTBXItem;
    MnuLabPst: TTBXItem;
    MnuLabNbE: TTBXItem;
    MnuMovExtras: TTBXSubmenuItem;
    MnuLabExtras: TTBXSubmenuItem;
    MnuMovENum: TTBXItem;
    MnuMovEChk: TTBXItem;
    MnuMovETag: TTBXItem;
    MnuMovETit: TTBXItem;
    MnuMovECat: TTBXItem;
    MnuMovEURL: TTBXItem;
    MnuMovEDsc: TTBXItem;
    MnuMovECom: TTBXItem;
    MnuMovECby: TTBXItem;
    MnuMovEPst: TTBXItem;
    MnuLabENum: TTBXItem;
    MnuLabEChk: TTBXItem;
    MnuLabETag: TTBXItem;
    MnuLabETit: TTBXItem;
    MnuLabECat: TTBXItem;
    MnuLabEURL: TTBXItem;
    MnuLabEDsc: TTBXItem;
    MnuLabECom: TTBXItem;
    MnuLabECby: TTBXItem;
    MnuLabEPst: TTBXItem;
    MnuMovEPic: TTBXItem;
    MnuMovEPfn: TTBXItem;
    MnuLabEPic: TTBXItem;
    MnuMovEBeg: TTBXItem;
    MnuMovEEnd: TTBXItem;
    MnuMovERec: TTBXItem;
    MnuMovPicNP: TTBXItem;
    MnuMovPfnNP: TTBXItem;
    MnuMovEPicNP: TTBXItem;
    MnuMovEPfnNP: TTBXItem;
    procedure ActionDisplayFullExecute(Sender: TObject);
    procedure ActionEditCopyExecute(Sender: TObject);
    procedure ActionEditCutExecute(Sender: TObject);
    procedure ActionEditDeleteExecute(Sender: TObject);
    procedure ActionEditPasteExecute(Sender: TObject);
    procedure ActionEditSelectAllExecute(Sender: TObject);
    procedure ActionEditUndoExecute(Sender: TObject);
    procedure ActionExportBothExecute(Sender: TObject);
    procedure ActionHTMLNewExecute(Sender: TObject);
    procedure ActionHTMLOpenExecute(Sender: TObject);
    procedure ActionHTMLSaveAsExecute(Sender: TObject);
    procedure ActionHTMLSaveExecute(Sender: TObject);
    procedure ActionInsertTagExecute(Sender: TObject);
    procedure ETemplateChange(Sender: TObject);
    procedure MnuCatDscClick(Sender: TObject);
    procedure MnuCatDskClick(Sender: TObject);
    procedure MnuCatNbrClick(Sender: TObject);
    procedure MnuCatNmeClick(Sender: TObject);
    procedure MnuCatPthClick(Sender: TObject);
    procedure MnuGenDteClick(Sender: TObject);
    procedure MnuGenTmeClick(Sender: TObject);
    procedure MnuMovAbrClick(Sender: TObject);
    procedure MnuMovActClick(Sender: TObject);
    procedure MnuMovAfmClick(Sender: TObject);
    procedure MnuMovAppClick(Sender: TObject);
    procedure MnuMovBegClick(Sender: TObject);
    procedure MnuMovBorClick(Sender: TObject);
    procedure MnuMovCatClick(Sender: TObject);
    procedure MnuMovChkClick(Sender: TObject);
    procedure MnuMovComClick(Sender: TObject);
    procedure MnuMovCouClick(Sender: TObject);
    procedure MnuMovDirClick(Sender: TObject);
    procedure MnuMovDscClick(Sender: TObject);
    procedure MnuMovDskClick(Sender: TObject);
    procedure MnuMovDteClick(Sender: TObject);
    procedure MnuMovEndClick(Sender: TObject);
    procedure MnuMovFoTClick(Sender: TObject);
    procedure MnuMovFpsClick(Sender: TObject);
    procedure MnuMovIndClick(Sender: TObject);
    procedure MnuMovLenClick(Sender: TObject);
    procedure MnuMovLngClick(Sender: TObject);
    procedure MnuMovMedClick(Sender: TObject);
    procedure MnuMovNumClick(Sender: TObject);
    procedure MnuMovOrTClick(Sender: TObject);
    procedure MnuMovPicClick(Sender: TObject);
    procedure MnuMovPicNPClick(Sender: TObject);
    procedure MnuMovPfnClick(Sender: TObject);
    procedure MnuMovPfnNPClick(Sender: TObject);
    procedure MnuMovProClick(Sender: TObject);
    procedure MnuMovRatClick(Sender: TObject);
    procedure MnuMovRecClick(Sender: TObject);
    procedure MnuMovResClick(Sender: TObject);
    procedure MnuMovSizClick(Sender: TObject);
    procedure MnuMovSrcClick(Sender: TObject);
    procedure MnuMovSubClick(Sender: TObject);
    procedure MnuMovTrTClick(Sender: TObject);
    procedure MnuMovTypClick(Sender: TObject);
    procedure MnuMovURLClick(Sender: TObject);
    procedure MnuMovVbrClick(Sender: TObject);
    procedure MnuMovVfmClick(Sender: TObject);
    procedure MnuMovYeaClick(Sender: TObject);
    procedure MnuMovA10Click(Sender: TObject);
    procedure MnuMovFT1Click(Sender: TObject);
    procedure MnuMovFT2Click(Sender: TObject);
    procedure MnuOwnEmlClick(Sender: TObject);
    procedure MnuOwnNamClick(Sender: TObject);
    procedure MnuOwnWebClick(Sender: TObject);
    procedure MnuLabNumClick(Sender: TObject);
    procedure MnuLabChkClick(Sender: TObject);
    procedure MnuLabBorClick(Sender: TObject);
    procedure MnuLabOrTClick(Sender: TObject);
    procedure MnuLabTrTClick(Sender: TObject);
    procedure MnuLabFoTClick(Sender: TObject);
    procedure MnuLabDirClick(Sender: TObject);
    procedure MnuLabProClick(Sender: TObject);
    procedure MnuLabCouClick(Sender: TObject);
    procedure MnuLabYeaClick(Sender: TObject);
    procedure MnuLabCatClick(Sender: TObject);
    procedure MnuLabLenClick(Sender: TObject);
    procedure MnuLabActClick(Sender: TObject);
    procedure MnuLabURLClick(Sender: TObject);
    procedure MnuLabDscClick(Sender: TObject);
    procedure MnuLabComClick(Sender: TObject);
    procedure MnuLabVfmClick(Sender: TObject);
    procedure MnuLabVbrClick(Sender: TObject);
    procedure MnuLabResClick(Sender: TObject);
    procedure MnuLabSizClick(Sender: TObject);
    procedure MnuLabLngClick(Sender: TObject);
    procedure MnuLabSubClick(Sender: TObject);
    procedure MnuLabRatClick(Sender: TObject);
    procedure MnuLabPicClick(Sender: TObject);
    procedure MnuLabDteClick(Sender: TObject);
    procedure MnuLabAfmClick(Sender: TObject);
    procedure MnuLabAbrClick(Sender: TObject);
    procedure MnuLabFpsClick(Sender: TObject);
    procedure MnuLabDskClick(Sender: TObject);
    procedure MnuLabMedClick(Sender: TObject);
    procedure MnuLabTypClick(Sender: TObject);
    procedure MnuLabSrcClick(Sender: TObject);
    procedure MnuLabUAFClick(Sender: TObject);
    procedure MnuLabUFPClick(Sender: TObject);
    procedure MnuLabUFSClick(Sender: TObject);
    procedure MnuLabUVFClick(Sender: TObject);

    procedure MnuMovCFClick(Sender: TObject);
    procedure MnuLabCFClick(Sender: TObject);

    procedure MnuMovR04Click(Sender: TObject);
    procedure MnuMovR10Click(Sender: TObject);
    procedure MnuMovColClick(Sender: TObject);
    procedure MnuMovHtmClick(Sender: TObject);
    procedure MnuLabColClick(Sender: TObject);

    procedure TBMRUList1Click(Sender: TObject; const Filename: String);
    procedure MnuMovDtWClick(Sender: TObject);
    procedure MnuMovURatClick(Sender: TObject);
    procedure MnuMovUR04Click(Sender: TObject);
    procedure MnuMovUR10Click(Sender: TObject);
    procedure MnuMovUA04Click(Sender: TObject);
    procedure MnuMovUA10Click(Sender: TObject);
    procedure MnuMovWrtClick(Sender: TObject);
    procedure MnuMovCmpClick(Sender: TObject);
    procedure MnuMovCerClick(Sender: TObject);
    procedure MnuMovFilClick(Sender: TObject);
    procedure MnuMovPstClick(Sender: TObject);
    procedure MnuMovNbEClick(Sender: TObject);
    procedure MnuLabDtWClick(Sender: TObject);
    procedure MnuLabURatClick(Sender: TObject);
    procedure MnuLabWrtClick(Sender: TObject);
    procedure MnuLabCmpClick(Sender: TObject);
    procedure MnuLabCerClick(Sender: TObject);
    procedure MnuLabFilClick(Sender: TObject);
    procedure MnuLabPstClick(Sender: TObject);
    procedure MnuLabNbEClick(Sender: TObject);
    procedure MnuMovENumClick(Sender: TObject);
    procedure MnuMovEChkClick(Sender: TObject);
    procedure MnuMovETagClick(Sender: TObject);
    procedure MnuMovETitClick(Sender: TObject);
    procedure MnuMovECatClick(Sender: TObject);
    procedure MnuMovEURLClick(Sender: TObject);
    procedure MnuMovEDscClick(Sender: TObject);
    procedure MnuMovEComClick(Sender: TObject);
    procedure MnuMovECbyClick(Sender: TObject);
    procedure MnuMovEPstClick(Sender: TObject);
    procedure MnuLabENumClick(Sender: TObject);
    procedure MnuLabEChkClick(Sender: TObject);
    procedure MnuLabETagClick(Sender: TObject);
    procedure MnuLabETitClick(Sender: TObject);
    procedure MnuLabECatClick(Sender: TObject);
    procedure MnuLabEURLClick(Sender: TObject);
    procedure MnuLabEDscClick(Sender: TObject);
    procedure MnuLabEComClick(Sender: TObject);
    procedure MnuLabECbyClick(Sender: TObject);
    procedure MnuLabEPstClick(Sender: TObject);
    procedure MnuMovEPicClick(Sender: TObject);
    procedure MnuMovEPicNPClick(Sender: TObject);
    procedure MnuMovEPfnClick(Sender: TObject);
    procedure MnuMovEPfnNPClick(Sender: TObject);
    procedure MnuLabEPicClick(Sender: TObject);
    procedure MnuMovEBegClick(Sender: TObject);
    procedure MnuMovEEndClick(Sender: TObject);
    procedure MnuMovERecClick(Sender: TObject);

  private
    FExportMode: Boolean;
    CFProperties: TCustomFieldsProperties;

    procedure OnFileChange(Sender: TObject; AFileName: TFileName);
    procedure OnNewFile(Sender: TObject; AFileName: TFileName);
    procedure OnOpenFile(Sender: TObject; AFileName: TFileName);
    procedure OnSaveFile(Sender: TObject; AFileName: TFileName);
    procedure UpdateMRU(const strFilePath: string);
    procedure InsertTag(const strTag: string);

  public
    FHTMLFullFile, FHTMLIndivFile: TFileManager;
    FHTMLFullDoc,  FHTMLIndivDoc:  TStringList;

    constructor Create(AOwner: TComponent); override;
    procedure SetMode(ExportMode: Boolean);
    destructor Destroy; override;
    procedure LoadOptions;
    procedure SaveOptions;
    procedure InitTags(const CustomFieldsProperties: TCustomFieldsProperties);
    function CloseQuery: Boolean;

    function  HTMLCurrFile: TFileManager;
    function  HTMLCurrDoc:  TStringList;
    function  HTMLRelDoc(AFile: TFileManager): TStringList;
    procedure HTMLLoadTemplate;
    procedure HTMLStoreTemplate;
  end;

implementation

uses
  StrUtils,

  fields, sort, Global, functions_files, functions_str, functions_sys,
  ProgramSettings, progress;

{$R *.dfm}

const
  strFilterExtHTML    = 'html';
  msgErrorSave        =  0;
  msgErrorOpen        =  1;
  msgHTMLUnsaved      =  2;
  msgHTMLFullUnsaved  =  3;
  msgHTMLIndivUnsaved =  4;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor THTMLTemplateEdit.Create(AOwner: TComponent);

  procedure InitFile(AFile: TFileManager);
  begin
    with AFile do
    begin
      OnNewFile := Self.OnNewFile;
      OnOpenFile := Self.OnOpenFile;
      OnSaveFile := Self.OnSaveFile;
      OnFileChange := Self.OnFileChange;
      with OpenDialog do
      begin
        Filter := DialogHTMLFilter;
        Options := DialogOpenOptions;
        DefaultExt := strFilterExtHTML;
      end;
      with SaveDialog do
      begin
        Filter := DialogHTMLFilter;
        Options := DialogSaveOptions;
        DefaultExt := strFilterExtHTML;
      end;
    end;
  end;
begin
  inherited;
  ActionHTMLNew.ImageIndex := Ord(ICON_TEMPLATENEW);
  ActionHTMLOpen.ImageIndex := Ord(ICON_TEMPLATELOAD);
  ActionHTMLSave.ImageIndex := Ord(ICON_TEMPLATESAVE);
  ActionHTMLSaveAs.ImageIndex := Ord(ICON_TEMPLATESAVEAS);

  FHTMLFullFile := TFileManager.Create(Self);
  InitFile(FHTMLFullFile);
  FHTMLFullDoc := TStringList.Create;

  FHTMLIndivFile := TFileManager.Create(Self);
  InitFile(FHTMLIndivFile);
  FHTMLIndivDoc := TStringList.Create;

  MnuMovAbr.Tag := fieldAudioBitrate;
  MnuMovAct.Tag := fieldActors;
  MnuMovAfm.Tag := fieldAudioFormat;
  MnuMovBor.Tag := fieldBorrower;
  MnuMovCat.Tag := fieldCategory;
  MnuMovChk.Tag := fieldChecked;
  MnuMovCol.Tag := fieldColorTag;
  MnuMovCom.Tag := fieldComments;
  MnuMovCou.Tag := fieldCountry;
  MnuMovDir.Tag := fieldDirector;
  MnuMovDsc.Tag := fieldDescription;
  MnuMovDsk.Tag := fieldDisks;
  MnuMovDte.Tag := fieldDate;
  MnuMovFot.Tag := fieldFormattedTitle;
  MnuMovFps.Tag := fieldFrameRate;
  MnuMovLen.Tag := fieldLength;
  MnuMovLng.Tag := fieldLanguages;
  MnuMovMed.Tag := fieldMedia;
  MnuMovNum.Tag := fieldNumber;
  MnuMovOrT.Tag := fieldOriginalTitle;
  MnuMovPro.Tag := fieldProducer;
  MnuMovRat.Tag := fieldRating;
  MnuMovRes.Tag := fieldResolution;
  MnuMovSiz.Tag := fieldSize;
  MnuMovSrc.Tag := fieldSource;
  MnuMovSub.Tag := fieldSubtitles;
  MnuMovTrT.Tag := fieldTranslatedTitle;
  MnuMovTyp.Tag := fieldMediaType;
  MnuMovURL.Tag := fieldURL;
  MnuMovVbr.Tag := fieldVideoBitrate;
  MnuMovVfm.Tag := fieldVideoFormat;
  MnuMovYea.Tag := fieldYear;
  MnuMovDtW.Tag := fieldDateWatched;
  MnuMovURat.Tag := fieldUserRating;
  MnuMovWrt.Tag := fieldWriter;
  MnuMovCmp.Tag := fieldComposer;
  MnuMovCer.Tag := fieldCertification;
  MnuMovFil.Tag := fieldFilePath;
  MnuMovPst.Tag := fieldPictureStatus;
  MnuMovNbE.Tag := fieldNbExtras;

  MnuLabAbr.Tag := fieldAudioBitrate;
  MnuLabAct.Tag := fieldActors;
  MnuLabAfm.Tag := fieldAudioFormat;
  MnuLabBor.Tag := fieldBorrower;
  MnuLabCat.Tag := fieldCategory;
  MnuLabChk.Tag := fieldChecked;
  MnuLabCol.Tag := fieldColorTag;
  MnuLabCom.Tag := fieldComments;
  MnuLabCou.Tag := fieldCountry;
  MnuLabDir.Tag := fieldDirector;
  MnuLabDsc.Tag := fieldDescription;
  MnuLabDsk.Tag := fieldDisks;
  MnuLabDte.Tag := fieldDate;
  MnuLabFot.Tag := fieldFormattedTitle;
  MnuLabFps.Tag := fieldFrameRate;
  MnuLabLen.Tag := fieldLength;
  MnuLabLng.Tag := fieldLanguages;
  MnuLabMed.Tag := fieldMedia;
  MnuLabNum.Tag := fieldNumber;
  MnuLabOrT.Tag := fieldOriginalTitle;
  MnuLabPro.Tag := fieldProducer;
  MnuLabRat.Tag := fieldRating;
  MnuLabRes.Tag := fieldResolution;
  MnuLabSiz.Tag := fieldSize;
  MnuLabSrc.Tag := fieldSource;
  MnuLabSub.Tag := fieldSubtitles;
  MnuLabTrT.Tag := fieldTranslatedTitle;
  MnuLabTyp.Tag := fieldMediaType;
  MnuLabURL.Tag := fieldURL;
  MnuLabVbr.Tag := fieldVideoBitrate;
  MnuLabVfm.Tag := fieldVideoFormat;
  MnuLabYea.Tag := fieldYear;
  MnuLabDtW.Tag := fieldDateWatched;
  MnuLabURat.Tag := fieldUserRating;
  MnuLabWrt.Tag := fieldWriter;
  MnuLabCmp.Tag := fieldComposer;
  MnuLabCer.Tag := fieldCertification;
  MnuLabFil.Tag := fieldFilePath;
  MnuLabPst.Tag := fieldPictureStatus;
  MnuLabNbE.Tag := fieldNbExtras;

  MnuMovENum.Tag := extraFieldNumber;
  MnuMovEChk.Tag := extraFieldChecked;
  MnuMovETag.Tag := extraFieldTag;
  MnuMovETit.Tag := extraFieldTitle;
  MnuMovECat.Tag := extraFieldCategory;
  MnuMovEURL.Tag := extraFieldURL;
  MnuMovEDsc.Tag := extraFieldDescription;
  MnuMovECom.Tag := extraFieldComments;
  MnuMovECby.Tag := extraFieldCreatedBy;
  MnuMovEPst.Tag := extraFieldPictureStatus;

  MnuLabENum.Tag := extraFieldNumber;
  MnuLabEChk.Tag := extraFieldChecked;
  MnuLabETag.Tag := extraFieldTag;
  MnuLabETit.Tag := extraFieldTitle;
  MnuLabECat.Tag := extraFieldCategory;
  MnuLabEURL.Tag := extraFieldURL;
  MnuLabEDsc.Tag := extraFieldDescription;
  MnuLabECom.Tag := extraFieldComments;
  MnuLabECby.Tag := extraFieldCreatedBy;
  MnuLabEPst.Tag := extraFieldPictureStatus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

destructor THTMLTemplateEdit.Destroy;
begin
  FHTMLFullFile.Free;
  FHTMLFullDoc.Free;
  FHTMLIndivFile.Free;
  FHTMLIndivDoc.Free;

  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.SetMode(ExportMode: Boolean);
begin
  FExportMode := ExportMode;

  if FExportMode then
  begin
    FHTMLFullFile.MessageSaveQuery := Messages.Strings[msgHTMLFullUnsaved];
    FHTMLIndivFile.MessageSaveQuery := Messages.Strings[msgHTMLIndivUnsaved];
    TBToolbar1.Enabled := True;
    TBToolbar1.Visible := TBToolbar1.Enabled;
  end
  else
  begin
    FHTMLFullFile.MessageSaveQuery := Messages.Strings[msgHTMLUnsaved];
    FHTMLIndivFile.MessageSaveQuery := Messages.Strings[msgHTMLUnsaved];
    TBToolbar1.Enabled := False;
    TBToolbar1.Visible := TBToolbar1.Enabled;
    ToolbarHTML.DockPos := -1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.LoadOptions;
begin
  if FExportMode then
  begin
    with Settings do
      with rExport do
      begin
        if ExportBoth then
          ActionExportBothExecute(ActionExportBoth)
        else
          ActionExportBothExecute(ActionExportSelected);

        with rOptions.rExport do
        begin
          if LoadTemplate and (HTMLLastTemplate <> '') and FileExists(HTMLLastTemplate) then
            FHTMLFullFile.Open(HTMLLastTemplate)
          else
            FHTMLFullFile.New;
          if LoadTemplate and (HTMLLastTemplate2 <> '') and FileExists(HTMLLastTemplate2) then
            FHTMLIndivFile.Open(HTMLLastTemplate2)
          else
            FHTMLIndivFile.New;
        end; // with rOptions.rExport

        TBMRUList1.Items.Assign(HTMLMRU);
        TBMRUList1.MaxItems := rOptions.rFiles.RecentFiles
      end; // with rExport
  end
  else
  begin
    with Settings.rHTMLEditor do
    begin
      if (HTMLLastTemplate <> '') and FileExists(HTMLLastTemplate) then
        FHTMLFullFile.Open(HTMLLastTemplate)
      else
        FHTMLFullFile.New;

      TBMRUList1.Items.Assign(HTMLMRU);
      TBMRUList1.MaxItems := Settings.rOptions.rFiles.RecentFiles;
    end; // with rHTMLEditor
  end;

  ToolbarHTML.Images := ToolbarImages;

  UpdateMRU('');
  ActionDisplayFullExecute(ActionDisplayFull);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.SaveOptions;
begin
  if FExportMode then
  begin
    with Settings.rExport do
    begin
      HTMLMRU.Assign(TBMRUList1.Items);
      ExportBoth := btnHTMLExport.Action = ActionExportBoth;
    end;
  end
  else
  begin
    with Settings.rHTMLEditor do
    begin
      HTMLMRU.Assign(TBMRUList1.Items);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.InitTags(const CustomFieldsProperties: TCustomFieldsProperties);
var
  i: Integer;
  newMenuItem : TTBXItem;
begin
  CFProperties := CustomFieldsProperties;

  with MnuMov do
    for i := 0 to Count-1 do
      with Items[i] do
        if Tag > -1 then
          Caption := strFields.Strings[Tag];

  with MnuLab do
    for i := 0 to Count-1 do
      with Items[i] do
        if Tag > -1 then
          Caption := strFields.Strings[Tag];

  MnuMovCF.Clear;
  for i := 0 to CFProperties.Count-1 do
  begin
    newMenuItem := TTBXItem.Create(MnuMovCF);
    MnuMovCF.Add(newMenuItem);
    with newMenuItem, CFProperties.Objects[i] do
    begin
      Name := UpperCase(FieldTag);
      Caption := FieldName;
      OnClick := MnuMovCFClick;
    end;
  end;

  MnuLabCF.Clear;
  for i := 0 to CFProperties.Count-1 do
  begin
    newMenuItem := TTBXItem.Create(MnuLabCF);
    MnuLabCF.Add(newMenuItem);
    with newMenuItem, CFProperties.Objects[i] do
    begin
      Name := UpperCase(FieldTag);
      Caption := FieldName;
      OnClick := MnuLabCFClick;
    end;
  end;

  with MnuMovExtras do
    for i := 0 to Count-1 do
      with Items[i] do
        if Tag > -1 then
          Caption := strExtraFields.Strings[Tag - extraFieldLow];

  with MnuLabExtras do
    for i := 0 to Count-1 do
      with Items[i] do
        if Tag > -1 then
          Caption := strExtraFields.Strings[Tag - extraFieldLow];
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function THTMLTemplateEdit.CloseQuery: Boolean;
begin
  //Settings.rExport.HTMLLastTemplate := FHTMLFullFile.CurrentFile; // Done in OnNewFile/OnOpenFile/OnSaveFile
  //Settings.rExport.HTMLLastTemplate2 := FHTMLIndivFile.CurrentFile; // Done in OnNewFile/OnOpenFile/OnSaveFile

  with FHTMLFullFile do
  begin
    OpenDialog.InitialDir := Settings.rOptions.rFolders[fuTemplates].Value;
    if OpenDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
  end;

  with FHTMLIndivFile do
  begin
    OpenDialog.InitialDir := Settings.rOptions.rFolders[fuTemplates].Value;
    if OpenDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
  end;

  Result := FHTMLFullFile.Close and FHTMLIndivFile.Close;
end;

{-------------------------------------------------------------------------------
  HTML toolbar
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionInsertTagExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionHTMLNewExecute(Sender: TObject);
begin
  HTMLCurrFile.New;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionHTMLOpenExecute(Sender: TObject);
begin
  with HTMLCurrFile do
  begin
    OpenDialog.InitialDir := Settings.rOptions.rFolders[fuTemplates].Value;
    if OpenDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Open;
    //if Open then // Do in OnOpenFile
    //  Settings.rOptions.rFolders[fuTemplates].Value := ExtractFilePath(CurrentFile);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionHTMLSaveExecute(Sender: TObject);
begin
  with HTMLCurrFile do
  begin
    SaveDialog.InitialDir := Settings.rOptions.rFolders[fuTemplates].Value;
    if SaveDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Save;
    //if Save then // Do in OnSaveFile
    //  Settings.rOptions.rFolders[fuTemplates].Value := ExtractFilePath(CurrentFile);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionHTMLSaveAsExecute(Sender: TObject);
begin
  with HTMLCurrFile do
  begin
    SaveDialog.InitialDir := Settings.rOptions.rFolders[fuTemplates].Value;
    if SaveDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    SaveAs;
    //if SaveAs then // Do in OnSaveFile
    //  Settings.rOptions.rFolders[fuTemplates].Value := ExtractFilePath(CurrentFile);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionDisplayFullExecute(Sender: TObject);
begin
  HTMLStoreTemplate;
  (Sender as TAction).Checked := True;
  HTMLLoadTemplate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.TBMRUList1Click(Sender: TObject;
  const Filename: String);
begin
  HTMLCurrFile.Open(FileName);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.UpdateMRU(const strFilePath: string);
begin
  if strFilePath <> '' then
    TBMRUList1.Add(strFilePath);
  ActionHTMLNoRecent.Visible := TBMRUList1.Items.Count = 0;
end;


{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ETemplateChange(Sender: TObject);
begin
  HTMLCurrFile.Modified := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.OnFileChange(Sender: TObject; AFileName: TFileName);
begin
  with LHTMLTemplateFileName do
  begin
    Caption := ExtractFileName(AFileName);
    Hint := AFileName;
  end;
  UpdateMRU(AFileName);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.OnNewFile(Sender: TObject; AFileName: TFileName);
begin
  if Sender = FHTMLFullFile then
  begin
    FHTMLFullDoc.Clear;
    if FExportMode then
      Settings.rExport.HTMLLastTemplate := ''
    else
      Settings.rHTMLEditor.HTMLLastTemplate := '';
  end
  else if Sender = FHTMLIndivFile then
  begin
    FHTMLIndivDoc.Clear;
    if FExportMode then
      Settings.rExport.HTMLLastTemplate2 := ''
    else
      Settings.rHTMLEditor.HTMLLastTemplate := '';
  end;
  HTMLLoadTemplate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.OnOpenFile(Sender: TObject; AFileName: TFileName);
begin
  try
    HTMLRelDoc(Sender as TFileManager).LoadFromFile(AFileName);
    Settings.rOptions.rFolders[fuTemplates].Value := ExtractFilePath(AFileName);
    if Sender = FHTMLFullFile then
      if FExportMode then
        Settings.rExport.HTMLLastTemplate := FHTMLFullFile.CurrentFile
      else
        Settings.rHTMLEditor.HTMLLastTemplate := FHTMLFullFile.CurrentFile
    else if Sender = FHTMLIndivFile then
      if FExportMode then
        Settings.rExport.HTMLLastTemplate2 := FHTMLIndivFile.CurrentFile
      else
        Settings.rHTMLEditor.HTMLLastTemplate := FHTMLFullFile.CurrentFile;
    HTMLLoadTemplate;
  except
    on e: Exception do
      if Visible then
        MessageWin.Execute(Format(Messages.Strings[msgErrorOpen],[AFilename, e.Message]),mtError,[mbOk])
      else
        TFileManager(Sender).New;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.OnSaveFile(Sender: TObject; AFileName: TFileName);
begin
  try
    HTMLStoreTemplate;
    HTMLRelDoc(Sender as TFileManager).SaveToFile(AFileName);
    Settings.rOptions.rFolders[fuTemplates].Value := ExtractFilePath(AFileName);
    if Sender = FHTMLFullFile then
      if FExportMode then
        Settings.rExport.HTMLLastTemplate := FHTMLFullFile.CurrentFile
      else
        Settings.rHTMLEditor.HTMLLastTemplate := FHTMLFullFile.CurrentFile
    else if Sender = FHTMLIndivFile then
      if FExportMode then
        Settings.rExport.HTMLLastTemplate2 := FHTMLIndivFile.CurrentFile
      else
        Settings.rHTMLEditor.HTMLLastTemplate := FHTMLFullFile.CurrentFile
  except
    on e: Exception do
      MessageWin.Execute(Format(Messages.Strings[msgErrorSave], [AFileName, e.Message]),mtError,[mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function THTMLTemplateEdit.HTMLCurrFile: TFileManager;
begin
  if ActionDisplayIndividual.Checked then
    Result := FHTMLIndivFile
  else
    Result := FHTMLFullFile;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function THTMLTemplateEdit.HTMLCurrDoc: TStringList;
begin
  if ActionDisplayIndividual.Checked then
    Result := FHTMLIndivDoc
  else
    Result := FHTMLFullDoc;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function THTMLTemplateEdit.HTMLRelDoc(AFile: TFileManager): TStringList;
begin
  if AFile = FHTMLIndivFile then
    Result := FHTMLIndivDoc
  else
    Result := FHTMLFullDoc;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.HTMLLoadTemplate;
begin
  ETemplate.Lines.Assign(HTMLCurrDoc);
  with LHTMLTemplateFileName, HTMLCurrFile do
  begin
    Caption := ExtractFileName(CurrentFile);
    Hint := '|' + CurrentFile;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.HTMLStoreTemplate;
begin
  HTMLCurrDoc.Assign(ETemplate.Lines);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditUndoExecute(Sender: TObject);
begin
  ETemplate.Undo;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditCutExecute(Sender: TObject);
begin
  ETemplate.CutToClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditCopyExecute(Sender: TObject);
begin
  ETemplate.CopyToClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditPasteExecute(Sender: TObject);
begin
  ETemplate.PasteFromClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditDeleteExecute(Sender: TObject);
begin
  ETemplate.SelText := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionEditSelectAllExecute(Sender: TObject);
begin
  ETemplate.SelectAll;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.ActionExportBothExecute(Sender: TObject);
begin
  if(Sender is TAction) then
    btnHTMLExport.Action := Sender as TAction
  else
    btnHTMLExport.Action := ActionExportBoth;
  btnHTMLExport.OnClick := nil;
end;

{-------------------------------------------------------------------------------
    HTML tag menu
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.InsertTag(const strTag: string);
begin
  ETemplate.SelText := strTag;
end;

procedure THTMLTemplateEdit.MnuCatNmeClick(Sender: TObject);
begin
  InsertTag(TAG_FILENAME);
end;

procedure THTMLTemplateEdit.MnuLabNumClick(Sender: TObject);
begin
  InsertTag(TAG_LABELNUMBER);
end;

procedure THTMLTemplateEdit.MnuLabChkClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCHECKED);
end;

procedure THTMLTemplateEdit.MnuLabBorClick(Sender: TObject);
begin
  InsertTag(TAG_LABELBORROWER);
end;

procedure THTMLTemplateEdit.MnuLabOrTClick(Sender: TObject);
begin
  InsertTag(TAG_LABELORIGINALTITLE);
end;

procedure THTMLTemplateEdit.MnuLabTrTClick(Sender: TObject);
begin
  InsertTag(TAG_LABELTRANSLATEDTITLE);
end;

procedure THTMLTemplateEdit.MnuLabFoTClick(Sender: TObject);
begin
  InsertTag(TAG_LABELFORMATTEDTITLE);
end;

procedure THTMLTemplateEdit.MnuLabDirClick(Sender: TObject);
begin
  InsertTag(TAG_LABELDIRECTOR);
end;

procedure THTMLTemplateEdit.MnuLabProClick(Sender: TObject);
begin
  InsertTag(TAG_LABELPRODUCER);
end;

procedure THTMLTemplateEdit.MnuLabCouClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCOUNTRY);
end;

procedure THTMLTemplateEdit.MnuLabYeaClick(Sender: TObject);
begin
  InsertTag(TAG_LABELYEAR);
end;

procedure THTMLTemplateEdit.MnuLabCatClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCATEGORY);
end;

procedure THTMLTemplateEdit.MnuLabLenClick(Sender: TObject);
begin
  InsertTag(TAG_LABELLENGTH);
end;

procedure THTMLTemplateEdit.MnuLabActClick(Sender: TObject);
begin
  InsertTag(TAG_LABELACTORS);
end;

procedure THTMLTemplateEdit.MnuLabURLClick(Sender: TObject);
begin
  InsertTag(TAG_LABELURL);
end;

procedure THTMLTemplateEdit.MnuLabDscClick(Sender: TObject);
begin
  InsertTag(TAG_LABELDESCRIPTION);
end;

procedure THTMLTemplateEdit.MnuLabComClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCOMMENTS);
end;

procedure THTMLTemplateEdit.MnuLabVfmClick(Sender: TObject);
begin
  InsertTag(TAG_LABELVIDEOFORMAT);
end;

procedure THTMLTemplateEdit.MnuLabVbrClick(Sender: TObject);
begin
  InsertTag(TAG_LABELVIDEOBITRATE);
end;

procedure THTMLTemplateEdit.MnuLabResClick(Sender: TObject);
begin
  InsertTag(TAG_LABELRESOLUTION);
end;

procedure THTMLTemplateEdit.MnuLabSizClick(Sender: TObject);
begin
  InsertTag(TAG_LABELSIZE);
end;

procedure THTMLTemplateEdit.MnuLabLngClick(Sender: TObject);
begin
  InsertTag(TAG_LABELLANGUAGES);
end;

procedure THTMLTemplateEdit.MnuLabSubClick(Sender: TObject);
begin
  InsertTag(TAG_LABELSUBTITLES);
end;

procedure THTMLTemplateEdit.MnuLabRatClick(Sender: TObject);
begin
  InsertTag(TAG_LABELRATING);
end;

procedure THTMLTemplateEdit.MnuLabPicClick(Sender: TObject);
begin
  InsertTag(TAG_LABELPICTURE);
end;

procedure THTMLTemplateEdit.MnuLabDteClick(Sender: TObject);
begin
  InsertTag(TAG_LABELDATEADD);
end;

procedure THTMLTemplateEdit.MnuLabAfmClick(Sender: TObject);
begin
  InsertTag(TAG_LABELAUDIOFORMAT);
end;

procedure THTMLTemplateEdit.MnuLabAbrClick(Sender: TObject);
begin
  InsertTag(TAG_LABELAUDIOBITRATE);
end;

procedure THTMLTemplateEdit.MnuLabFpsClick(Sender: TObject);
begin
  InsertTag(TAG_LABELFRAMERATE);
end;

procedure THTMLTemplateEdit.MnuLabDskClick(Sender: TObject);
begin
  InsertTag(TAG_LABELDISKS);
end;

procedure THTMLTemplateEdit.MnuLabMedClick(Sender: TObject);
begin
  InsertTag(TAG_LABELMEDIA);
end;

procedure THTMLTemplateEdit.MnuLabTypClick(Sender: TObject);
begin
  InsertTag(TAG_LABELTYPE);
end;

procedure THTMLTemplateEdit.MnuLabSrcClick(Sender: TObject);
begin
  InsertTag(TAG_LABELSOURCE);
end;

procedure THTMLTemplateEdit.MnuLabColClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCOLORTAG);
end;

procedure THTMLTemplateEdit.MnuLabUAFClick(Sender: TObject);
begin
  InsertTag(TAG_LABELAUDIOKBPS);
end;

procedure THTMLTemplateEdit.MnuLabUFPClick(Sender: TObject);
begin
  InsertTag(TAG_LABELVIDEOKBPS);
end;

procedure THTMLTemplateEdit.MnuLabUFSClick(Sender: TObject);
begin
  InsertTag(TAG_LABELUNIT);
end;

procedure THTMLTemplateEdit.MnuLabUVFClick(Sender: TObject);
begin
  InsertTag(TAG_LABELFPS);
end;

procedure THTMLTemplateEdit.MnuLabDtWClick(Sender: TObject);
begin
  InsertTag(TAG_LABELDATEWATCHED);
end;

procedure THTMLTemplateEdit.MnuLabURatClick(Sender: TObject);
begin
  InsertTag(TAG_LABELUSERRATING);
end;

procedure THTMLTemplateEdit.MnuLabWrtClick(Sender: TObject);
begin
  InsertTag(TAG_LABELWRITER);
end;

procedure THTMLTemplateEdit.MnuLabCmpClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCOMPOSER);
end;

procedure THTMLTemplateEdit.MnuLabCerClick(Sender: TObject);
begin
  InsertTag(TAG_LABELCERTIFICATION);
end;

procedure THTMLTemplateEdit.MnuLabFilClick(Sender: TObject);
begin
  InsertTag(TAG_LABELFILEPATH);
end;

procedure THTMLTemplateEdit.MnuLabPstClick(Sender: TObject);
begin
  InsertTag(TAG_LABELPICTURESTATUS);
end;

procedure THTMLTemplateEdit.MnuLabNbEClick(Sender: TObject);
begin
  InsertTag(TAG_LABELNBEXTRAS);
end;

procedure THTMLTemplateEdit.MnuMovBegClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMBEGIN);
end;

procedure THTMLTemplateEdit.MnuMovEndClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEND);
end;

procedure THTMLTemplateEdit.MnuMovIndClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMFILEINDIV);
end;

procedure THTMLTemplateEdit.MnuMovRecClick(Sender: TObject);
begin
  InsertTag(TAG_RECNR);
end;
procedure THTMLTemplateEdit.MnuMovNumClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMNUMBER);
end;

procedure THTMLTemplateEdit.MnuMovChkClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCHECKED);
end;

procedure THTMLTemplateEdit.MnuMovBorClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMBORROWER);
end;

procedure THTMLTemplateEdit.MnuMovOrTClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMORIGINALTITLE);
end;

procedure THTMLTemplateEdit.MnuMovTrTClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMTRANSLATEDTITLE);
end;

procedure THTMLTemplateEdit.MnuMovFoTClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMFORMATTEDTITLE);
end;

procedure THTMLTemplateEdit.MnuGenDteClick(Sender: TObject);
begin
  InsertTag(TAG_DATE);
end;

procedure THTMLTemplateEdit.MnuGenTmeClick(Sender: TObject);
begin
  InsertTag(TAG_TIME);
end;

procedure THTMLTemplateEdit.MnuCatPthClick(Sender: TObject);
begin
  InsertTag(TAG_FILEPATH);
end;

procedure THTMLTemplateEdit.MnuMovDirClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMDIRECTOR);
end;

procedure THTMLTemplateEdit.MnuMovProClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPRODUCER);
end;

procedure THTMLTemplateEdit.MnuMovCouClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCOUNTRY);
end;

procedure THTMLTemplateEdit.MnuMovYeaClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMYEAR);
end;

procedure THTMLTemplateEdit.MnuMovCatClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCATEGORY);
end;

procedure THTMLTemplateEdit.MnuMovLenClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMLENGTH);
end;

procedure THTMLTemplateEdit.MnuMovActClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMACTORS);
end;

procedure THTMLTemplateEdit.MnuMovURLClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMURL);
end;

procedure THTMLTemplateEdit.MnuMovDscClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMDESCRIPTION);
end;

procedure THTMLTemplateEdit.MnuMovComClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCOMMENTS);
end;

procedure THTMLTemplateEdit.MnuMovVfmClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMVIDEOFORMAT);
end;

procedure THTMLTemplateEdit.MnuMovVbrClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMVIDEOBITRATE);
end;

procedure THTMLTemplateEdit.MnuMovResClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMRESOLUTION);
end;

procedure THTMLTemplateEdit.MnuMovSizClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMSIZE);
end;

procedure THTMLTemplateEdit.MnuMovLngClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMLANGUAGES);
end;

procedure THTMLTemplateEdit.MnuMovSubClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMSUBTITLES);
end;

procedure THTMLTemplateEdit.MnuCatNbrClick(Sender: TObject);
begin
  InsertTag(TAG_TOTALMOVIES);
end;

procedure THTMLTemplateEdit.MnuCatDskClick(Sender: TObject);
begin
  InsertTag(TAG_TOTALDISKS);
end;

procedure THTMLTemplateEdit.MnuMovAppClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMAPPRECIATION);
end;

procedure THTMLTemplateEdit.MnuMovRatClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMRATING);
end;

procedure THTMLTemplateEdit.MnuMovPicClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPICTURE);
end;

procedure THTMLTemplateEdit.MnuMovPicNPClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPICTURENP);
end;

procedure THTMLTemplateEdit.MnuMovPfnClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPICTUREFILENAME);
end;

procedure THTMLTemplateEdit.MnuMovPfnNPClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPICTUREFILENAMENP);
end;

procedure THTMLTemplateEdit.MnuOwnNamClick(Sender: TObject);
begin
  InsertTag(TAG_OWNERNAME);
end;

procedure THTMLTemplateEdit.MnuOwnEmlClick(Sender: TObject);
begin
  InsertTag(TAG_OWNERMAIL);
end;

procedure THTMLTemplateEdit.MnuOwnWebClick(Sender: TObject);
begin
  InsertTag(TAG_OWNERSITE);
end;

procedure THTMLTemplateEdit.MnuCatDscClick(Sender: TObject);
begin
  InsertTag(TAG_DESCRIPTION);
end;

procedure THTMLTemplateEdit.MnuMovDteClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMDATEADD);
end;

procedure THTMLTemplateEdit.MnuMovAfmClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMAUDIOFORMAT);
end;

procedure THTMLTemplateEdit.MnuMovAbrClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMAUDIOBITRATE);
end;

procedure THTMLTemplateEdit.MnuMovFpsClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMFRAMERATE);
end;

procedure THTMLTemplateEdit.MnuMovDskClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMDISKS);
end;

procedure THTMLTemplateEdit.MnuMovMedClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMMEDIA);
end;

procedure THTMLTemplateEdit.MnuMovTypClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMTYPE);
end;

procedure THTMLTemplateEdit.MnuMovSrcClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMSOURCE);
end;

procedure THTMLTemplateEdit.MnuMovA10Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMAPPR10);
end;

procedure THTMLTemplateEdit.MnuMovFT1Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMFORMATTEDTITLE1);
end;

procedure THTMLTemplateEdit.MnuMovFT2Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMFORMATTEDTITLE2);
end;

procedure THTMLTemplateEdit.MnuMovR04Click(Sender: TObject);
begin
  inherited;
  InsertTag(TAG_ITEMRATING4);
end;

procedure THTMLTemplateEdit.MnuMovR10Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMRATING10);
end;

procedure THTMLTemplateEdit.MnuMovColClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCOLORTAG);
end;

procedure THTMLTemplateEdit.MnuMovHtmClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCOLORHTML);
end;

procedure THTMLTemplateEdit.MnuMovDtWClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMDATEWATCHED);
end;

procedure THTMLTemplateEdit.MnuMovURatClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMUSERRATING);
end;

procedure THTMLTemplateEdit.MnuMovUR04Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMUSERRATING4);
end;

procedure THTMLTemplateEdit.MnuMovUR10Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMUSERRATING10);
end;

procedure THTMLTemplateEdit.MnuMovUA04Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMUSERAPPR4);
end;

procedure THTMLTemplateEdit.MnuMovUA10Click(Sender: TObject);
begin
  InsertTag(TAG_ITEMUSERAPPR10);
end;

procedure THTMLTemplateEdit.MnuMovWrtClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMWRITER);
end;

procedure THTMLTemplateEdit.MnuMovCmpClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCOMPOSER);
end;

procedure THTMLTemplateEdit.MnuMovCerClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMCERTIFICATION);
end;

procedure THTMLTemplateEdit.MnuMovFilClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMFILEPATH);
end;

procedure THTMLTemplateEdit.MnuMovPstClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMPICTURESTATUS);
end;

procedure THTMLTemplateEdit.MnuMovNbEClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMNBEXTRAS);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure THTMLTemplateEdit.MnuLabCFClick(Sender: TObject);
begin
  InsertTag(TAG_LABEL_CF + TTBXItem(Sender).Name);
end;

procedure THTMLTemplateEdit.MnuMovCFClick(Sender: TObject);
begin
  InsertTag(TAG_ITEM_CF + TTBXItem(Sender).Name);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
procedure THTMLTemplateEdit.MnuLabENumClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRANUMBER);
end;

procedure THTMLTemplateEdit.MnuLabEChkClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRACHECKED);
end;

procedure THTMLTemplateEdit.MnuLabETagClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRATAG);
end;

procedure THTMLTemplateEdit.MnuLabETitClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRATITLE);
end;

procedure THTMLTemplateEdit.MnuLabECatClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRACATEGORY);
end;

procedure THTMLTemplateEdit.MnuLabEURLClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRAURL);
end;

procedure THTMLTemplateEdit.MnuLabEDscClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRADESCRIPTION);
end;

procedure THTMLTemplateEdit.MnuLabEComClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRACOMMENTS);
end;

procedure THTMLTemplateEdit.MnuLabECbyClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRACREATEDBY);
end;

procedure THTMLTemplateEdit.MnuLabEPstClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRAPICSTATUS);
end;

procedure THTMLTemplateEdit.MnuLabEPicClick(Sender: TObject);
begin
  InsertTag(TAG_LABELEXTRAPICTURE);
end;

procedure THTMLTemplateEdit.MnuMovEBegClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRABEGIN);
end;

procedure THTMLTemplateEdit.MnuMovEEndClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAEND);
end;

procedure THTMLTemplateEdit.MnuMovERecClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRARECNR);
end;

procedure THTMLTemplateEdit.MnuMovENumClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRANUMBER);
end;

procedure THTMLTemplateEdit.MnuMovEChkClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRACHECKED);
end;

procedure THTMLTemplateEdit.MnuMovETagClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRATAG);
end;

procedure THTMLTemplateEdit.MnuMovETitClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRATITLE);
end;

procedure THTMLTemplateEdit.MnuMovECatClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRACATEGORY);
end;

procedure THTMLTemplateEdit.MnuMovEURLClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAURL);
end;

procedure THTMLTemplateEdit.MnuMovEDscClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRADESCRIPTION);
end;

procedure THTMLTemplateEdit.MnuMovEComClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRACOMMENTS);
end;

procedure THTMLTemplateEdit.MnuMovECbyClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRACREATEDBY);
end;

procedure THTMLTemplateEdit.MnuMovEPstClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAPICSTATUS);
end;

procedure THTMLTemplateEdit.MnuMovEPicClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAPICTURE);
end;

procedure THTMLTemplateEdit.MnuMovEPicNPClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAPICTURENP);
end;

procedure THTMLTemplateEdit.MnuMovEPfnClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAPICFILENAME);
end;

procedure THTMLTemplateEdit.MnuMovEPfnNPClick(Sender: TObject);
begin
  InsertTag(TAG_ITEMEXTRAPICFILENAMENP);
end;

end.
