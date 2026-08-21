(************************************************************************
 *                                                                      *
 *   Ant Movie Catalog 4.x                                              *
 *   (C) 2000-2018 Antoine Potten, Mickaël Vanneufville                 *
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

unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ActnList, ImgList, Menus, StdCtrls, Buttons, Clipbrd, ComCtrls,
  StdActns, Contnrs,

  ElTree, ElList, ElHeader, TB2Common, TB2Item, TB2MRU, TB2Toolbar, TB2Dock,
  TB2ToolWindow, TBX, TBXExtItems, TBXSwitcher, TBXStatusBars,

  AntJvDragDrop, AntStringList, AntCorelButton,
  AntJvSpin, AntJvEdit, AntJvExControls, AntJvToolEdit,

  framemovie, fields, MovieClass, FileManager, ConstValues,
  FramePictureSelectionOptions,

  HTMLSubs, HtmlView, MetaFilePrinter, PrintStatusForm, PreviewForm,

  JPEG, PNGImage, AntJvGIF, rkIntegerList, rkSmartView, framemoviecustom,
  framemovieextras, TBXDkPanels, AppEvnts;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

const
  strDefaultCaption = 'Ant Movie Catalog %s - %s'; // Final release
  //strDefaultCaption = 'Ant Movie Catalog %s [BETA] - %s'; // Beta release
  //strDefaultCaption = 'Ant Movie Catalog %s [TEST] - %s'; // Test release
  strDefaultTask = '%s - Ant Movie Catalog';
  CM_UpdateView = WM_USER + 2102; // Custom Message...
  SortAdvancedField = fieldPicture;
  SortAdvancedFieldName = '*Advanced*';
  GroupNoneField = -1;
  GroupNoneFieldName = '*None*';
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  {ThumbsViewer}
  PCacheItem = ^TCacheItem;
  TCacheItem = record
    Picture: TMoviePicture;
    Size: Integer;
    Age: TDateTime;
    Scale: Integer;
    Bmp: TBitmap;
  end;

  ThumbThread = class(TThread)
  private
    { Private declarations }
    MsgHandle: THandle;
    ThumbsViewer: TrkSmartView;
    ListView1: TElTree;
    MovieList: TMovieList;
  protected
    procedure Execute; override;
  public
    constructor Create(Thumbs: TrkSmartView; Items: TElTree; Movies: TMovieList);
  end;
  {End ThumbsViewer}
  
  TMainWindow = class(TForm)
    ActionDisplayMainToolbar: TAction;
    ActionDisplayPictureToolbar: TAction;
    ActionDisplayStatusBar: TAction;
    ActionExit: TAction;
    ActionFileExport: TAction;
    ActionFileImport: TAction;
    ActionFileNew: TAction;
    ActionFileOpen: TAction;
    ActionFileOpenNoRecent: TAction;
    ActionFilePrint: TAction;
    ActionFileProperties: TAction;
    ActionFileSave: TAction;
    ActionFileSaveAs: TAction;
    ActionFindDisplay: TAction;
    ActionFindFindnext: TAction;
    ActionFindWholefield: TAction;
    ActionFindReverse: TAction;
    ActionGroupNone: TAction;
    ActionHelpAbout: TAction;
    ActionHelpIndex: TAction;
    ActionLanguage: TAction;
    ActionList1: TActionList;
    ActionLoan: TAction;
    ActionMenuFile: TAction;
    ActionMenuGet: TAction;
    ActionMenuGroup: TAction;
    ActionMenuSort: TAction;
    ActionMenuHelp: TAction;
    ActionMenuMovie: TAction;
    ActionMenuPicture: TAction;
    ActionMenuTools: TAction;
    ActionMovieAdd: TAction;
    ActionMovieCheck: TAction;
    ActionMovieCopy: TAction;
    ActionMovieDelete: TAction;
    ActionMovieFind: TAction;
    ActionMovieImportCD: TAction;
    ActionMovieImportFiles: TAction;
    ActionMovieImportScript: TAction;
    ActionMovieNext: TAction;
    ActionMovieNumber: TAction;
    ActionMoviePaste: TAction;
    ActionMoviePictureShow: TAction;
    ActionMoviePrevious: TAction;
    ActionMovieRenumber: TAction;
    ActionMovieSearch: TAction;
    ActionMovieSelCheck: TAction;
    ActionMovieSelGroup: TAction;
    ActionMovieSelUncheck: TAction;
    ActionMovieStats: TAction;
    ActionMovieUncheck: TAction;
    ActionMovieUndo: TAction;
    ActionOptions: TAction;
    ActionPicCopy: TAction;
    ActionPicPaste: TAction;
    ActionPicDelete: TAction;
    ActionPicSaveAs: TAction;
    ActionPicSelect: TAction;
    ActionPicUndock: TAction;
    ActionRefresh: TAction;
    ActionToolsGrid: TAction;
    ActionToolsScripting: TAction;
    ActionURLBrowse: TAction;
    ActionURLOpen: TAction;
    ActionURLCopy: TAction;
    BtnFindNext: TCorelButton;
    CBDisplayResults: TCheckBox;
    CBWholefield: TCheckBox;
    CBReverseResults: TCheckBox;
    cbxField: TComboBox;
    DockBottomList: TTBXDock;
    DockImageLeft: TTBXDock;
    DockImageTop: TTBXDock;
    DockMainBottom: TTBXDock;
    DockMainLeft: TTBXDock;
    DockMainTop: TTBXDock;
    DockRightExtras: TTBXDock;
    EValue: TEdit;
    Fields: TAntStringList;
    ExtraFields: TAntStringList;
    FrmMovie: TMovieFrame;
    FrmMovieCustom: TMovieFrameCustom;
    FrmMovieExtras: TMovieFrameExtras;
    ImageListHot: TImageList;
    ImageListNormal: TTBImageList;
    ImageListColorsTag: TImageList;
    LField: TLabel;
    ListView1: TElTree;
    LValue: TLabel;
    Messages: TAntStringList;
    MnuFil__1: TTBXSeparatorItem;
    MnuFil__2: TTBXSeparatorItem;
    MnuFil__3: TTBXSeparatorItem;
    MnuFilExp: TTBXItem;
    MnuFilImp: TTBXItem;
    MnuFilNew: TTBXItem;
    MnuFilOpn: TTBXItem;
    MnuFilPrn: TTBXItem;
    MnuFilPrp: TTBXItem;
    MnuFilSaa: TTBXItem;
    MnuFilSav: TTBXItem;
    MnuFilXit: TTBXItem;
    MnuGetFil: TTBXItem;
    MnuGetScr: TTBXItem;
    MnuTlsGrp__1: TTBXSeparatorItem;
    MnuTlsGrpNon: TTBXItem;
    MnuHlpAbt: TTBXItem;
    MnuHlpIdx: TTBXItem;
    MnuMlp__1: TTBXSeparatorItem;
    MnuMlp__2: TTBXSeparatorItem;
    MnuMlp__3: TTBXSeparatorItem;
    MnuMlpAdd: TTBXItem;
    MnuMlpChk: TTBXItem;
    MnuMlpCpy: TTBXItem;
    MnuMlpDel: TTBXItem;
    MnuMlpGet: TTBXSubmenuItem;
    MnuMlpGrp: TTBXSubmenuItem;
    MnuMlpNum: TTBXItem;
    MnuMlpPst: TTBXItem;
    MnuMlpSlc: TTBXItem;
    MnuMlpSlg: TTBXItem;
    MnuMlpSlu: TTBXItem;
    MnuMlpUch: TTBXItem;
    MnuMnuFil: TTBXSubmenuItem;
    MnuMnuHlp: TTBXSubmenuItem;
    MnuMnuMov: TTBXSubmenuItem;
    MnuMnuTls: TTBXSubmenuItem;
    MnuMov__1: TTBXSeparatorItem;
    MnuMov__2: TTBXSeparatorItem;
    MnuMovAdd: TTBXItem;
    MnuMovCpy: TTBXItem;
    MnuMovDel: TTBXItem;
    MnuMovFnd: TTBXItem;
    MnuMovGet: TTBXSubmenuItem;
    MnuMovNum: TTBXItem;
    MnuMovPic: TTBXSubmenuItem;
    MnuMovPst: TTBXItem;
    MnuMovSch: TTBXSubmenuItem;
    MnuMovUnd: TTBXItem;
    MnuMpi__1: TTBXSeparatorItem;
    MnuMpiCpy: TTBXItem;
    MnuMpiDck: TTBXItem;
    MnuMpiDel: TTBXItem;
    MnuMpiDis: TTBXItem;
    MnuMpiLoa: TTBXItem;
    MnuMpiSav: TTBXItem;
    MnuPicCpy: TTBXItem;
    MnuPicDck: TTBXItem;
    MnuPicDel: TTBXItem;
    MnuPicLoa: TTBXItem;
    MnuPicSav: TTBXItem;
    MnuTbp__1: TTBXSeparatorItem;
    MnuTbpMtb: TTBXItem;
    MnuTbpOpt: TTBXItem;
    MnuTbpPtb: TTBXItem;
    MnuTbpStb: TTBXItem;
    MnuTls__1: TTBXSeparatorItem;
    MnuTls__2: TTBXSeparatorItem;
    MnuTlsGrd: TTBXItem;
    MnuTlsGrp: TTBXSubmenuItem;
    MnuTlsSort: TTBXSubmenuItem;
    MnuTlsLng: TTBXItem;
    MnuTlsLoa: TTBXItem;
    MnuTlsOpt: TTBXItem;
    MnuTlsRen: TTBXItem;
    MnuTlsScr: TTBXItem;
    MnuTlsSta: TTBXItem;
    MnuPopupUrlBrw: TTBXItem;
    MnuPopupUrpOpen: TTBXItem;
    MoviePicture: TImage;
    PanelLeft: TPanel;
    PanelMovieInfos: TPanel;
    PanelPicture: TPanel;
    PopupEURL: TTBXPopupMenu;
    PopupMovieList: TTBXPopupMenu;
    PopupToolbar: TTBXPopupMenu;
    ScrollBox1: TScrollBox;
    SplitterBottomList: TSplitter;
    SplitterMovieInfos: TSplitter;
    SplitterRightExtras: TSplitter;
    StatusBar1: TTBXStatusBar;
    TBItemAbout: TTBXItem;
    TBItemExit: TTBXItem;
    TBItemFileExport: TTBXItem;
    TBItemFileImport: TTBXItem;
    TBItemFileNew: TTBXItem;
    TBItemFileOpen: TTBXItem;
    TBItemFileOpenMRU: TTBXSubmenuItem;
    TBItemFileOpenNone: TTBXItem;
    TBItemFilePrint: TTBXItem;
    TBItemFileProperties: TTBXItem;
    TBItemFileSave: TTBXItem;
    TBItemFileSaveAs: TTBXItem;
    TBItemGetInfo: TTBXSubmenuItem;
    TBItemGetInfoFiles: TTBXItem;
    TBItemGetInfoScript: TTBXItem;
    TBItemGroup: TTBXSubmenuItem;
    TBItemHelp: TTBXItem;
    TBItemLoans: TTBXItem;
    TBItemMovieAdd: TTBXItem;
    TBItemMovieCopy: TTBXItem;
    TBItemMovieDelete: TTBXItem;
    TBItemMovieFind: TTBXItem;
    TBItemMovieNumber: TTBXItem;
    TBItemMoviePaste: TTBXItem;
    TBItemMoviePicture: TTBXItem;
    TBItemMoviePictureMenu: TTBXSubmenuItem;
    TBItemMovieUndo: TTBXItem;
    TBItemPreferences: TTBXItem;
    TBItemRenumber: TTBXItem;
    TBItemScripting: TTBXItem;
    TBItemSearch: TTBXSubmenuItem;
    TBItemStats: TTBXItem;
    TBMRUList1: TTBXMRUList;
    TBMRUListItem1: TTBXMRUListItem;
    TBMRUListItem2: TTBXMRUListItem;
    TBSeparatorFile: TTBXSeparatorItem;
    TBSeparatorGet: TTBXSeparatorItem;
    TBSeparatorHelp: TTBXSeparatorItem;
    TBSeparatorMisc: TTBXSeparatorItem;
    TBSeparatorMovie: TTBXSeparatorItem;
    TBSeparatorMovieEdit: TTBXSeparatorItem;
    TBXSwitcher1: TTBXSwitcher;
    ToolbarFind: TTBXToolWindow;
    ToolbarMain: TTBXToolbar;
    ToolbarMenu: TTBXToolbar;
    ToolbarPicture: TTBXToolbar;
    ToolbarPictureWindow: TTBXToolWindow;
    ActionHelpVersion: TAction;
    MnuHlpVer: TTBXItem;
    TBItemLanguage: TTBXItem;
    TBItemRandom: TTBXItem;
    ActionMovieRandom: TAction;
    TBItemStretchList: TTBXItem;
    ActionStretchList: TAction;
    MnuTlsStr: TTBXItem;
    MnuMovRan: TTBXItem;
    HTMLViewer: THTMLViewer;
    ActionDisplayHTML: TAction;
    MnuTlsHTM: TTBXItem;
    PanelThumbs: TPanel;
    PanelThumbsBottom: TPanel;
    ThumbsSizer: TTrackBar;
    ThumbsProgress: TProgressBar;
    ThumbsViewer: TrkSmartView;
    ActionDisplayThumbnails: TAction;
    MnuTlsThu: TTBXItem;
    TBItemDisplayThumbnails: TTBXItem;
    TBItemSort: TTBXSubmenuItem;
    MnuMlpSort: TTBXSubmenuItem;
    MnuTlsSortAscend: TTBXItem;
    MnuTlsSortDescend: TTBXItem;
    MnuTlsSort__1: TTBXSeparatorItem;
    ActionSortAscend: TAction;
    ActionSortDescend: TAction;
    PopupImage: TTBXPopupMenu;
    TBXMnuPicSelect: TTBXItem;
    TBXMnuPicDelete: TTBXItem;
    TBXMnuPicSaveAs: TTBXItem;
    TBXMnuPicCopy: TTBXItem;
    MnuPopupUrlCopy: TTBXItem;
    PopupHTMLViewer: TTBXPopupMenu;
    MnuHtmlCopy: TTBXItem;
    TabMovieInfos: TTabControl;
    ActionManageFields: TAction;
    MnuTlsMan: TTBXItem;
    TBItemFieldsManager: TTBXItem;
    MnuTlsGrf: TTBXSubmenuItem;
    ActionMenuGridFields: TAction;
    TBItemGridFields: TTBXSubmenuItem;
    ActionURLExplore: TAction;
    MnuPopupUrlExp: TTBXItem;
    MnuMlpSch: TTBXSubmenuItem;
    MnuSelect: TTBXSubmenuItem;
    MnuSelected: TTBXSubmenuItem;
    MnuMlp__4: TTBXSeparatorItem;
    MnuMlp__5: TTBXSeparatorItem;
    MnuMlp__6: TTBXSeparatorItem;
    ActionMenuDisplay: TAction;
    MnuMnuDsp: TTBXSubmenuItem;
    MnuTls__3: TTBXSeparatorItem;
    TBSeparatorDisplay: TTBXSeparatorItem;
    Media: TAntStringList;
    ActionSelectHTML: TAction;
    MnuTlsSelHTML: TTBXSubmenuItem;
    TBItemSelHTML: TTBXSubmenuItem;
    MnuTlsBrowseHTML: TTBXItem;
    MnuTls__4: TTBXSeparatorItem;
    TBItemMovieUrl: TTBXSubmenuItem;
    ActionMovieUrl: TAction;
    MnuMovUrl: TTBXSubmenuItem;
    MnuUrlOpen: TTBXItem;
    MnuUrlExp: TTBXItem;
    MnuUrlCopy: TTBXItem;
    MnuUrlBrw: TTBXItem;
    ThumbsDisplayTitle: TCheckBox;
    FrmBoth: TPanel;
    Panel1FrmBoth: TPanel;
    Panel2FrmBoth: TPanel;
    SplitterFrmBoth: TSplitter;
    MnuTlsPic: TTBXItem;
    ActionManagePictures: TAction;
    TBItemPicManager: TTBXItem;
    MnuPicPst: TTBXItem;
    MnuMpiPst: TTBXItem;
    ActionHTMLEditor: TAction;
    MnuTlsHed: TTBXItem;
    TBItemHTMLEdit: TTBXItem;
    MnuHtmlEdit: TTBXItem;
    MnuHtml__1: TTBXSeparatorItem;
    TBXMnuPicPaste: TTBXItem;
    ActionMenuGroupsFormat: TAction;
    MnuTlsGpf: TTBXSubmenuItem;
    MnuGpfNone: TTBXItem;
    MnuGpf__1: TTBXSeparatorItem;
    ActionGroupsFormatNone: TAction;
    MnuGpf5L: TTBXItem;
    MnuGpf4L: TTBXItem;
    MnuGpf3L: TTBXItem;
    MnuGpf2L: TTBXItem;
    MnuGpf1L: TTBXItem;
    MnuGpf__2: TTBXSeparatorItem;
    MnuGpfRound1000: TTBXItem;
    MnuGpfRound100: TTBXItem;
    MnuGpfRound10: TTBXItem;
    MnuGpfRound1: TTBXItem;
    MnuGpfRound01: TTBXItem;
    MnuGpfRound0001: TTBXItem;
    MnuGpf__3: TTBXSeparatorItem;
    MnuGpfDateYM: TTBXItem;
    MnuGpfDateY: TTBXItem;
    MnuGpfRound001: TTBXItem;
    MnuGpfRoundType: TTBXSubmenuItem;
    MnuGpfRoundDown: TTBXItem;
    MnuGpfRoundNearest: TTBXItem;
    MnuGpfRoundUp: TTBXItem;
    MnuMlpGpf: TTBXSubmenuItem;
    TBItemGroupsFormat: TTBXSubmenuItem;
    TimerSearch: TTimer;
    TimerAfterSelect: TTimer;
    MnuTlsSortAdvanced: TTBXItem;
    ActionSortAdvanced: TAction;
    ToolbarExtrasWindow: TTBXToolWindow;
    ActionMovieExtrasShow: TAction;
    TBItemMovieExtras: TTBXItem;
    ActionDisplayExtrasToolbar: TAction;
    MnuTbpExt: TTBXItem;
    PictureStatus: TAntStringList;
    ActionMovieFilePath: TAction;
    TBItemMovieFilePath: TTBXSubmenuItem;
    MnuMovFPh: TTBXSubmenuItem;
    MnuFPhOpen: TTBXItem;
    MnuFPhExp: TTBXItem;
    MnuFPhCopy: TTBXItem;
    MnuFPhBrw: TTBXItem;
    MnuMovExt: TTBXItem;
    PopupFields: TTBXPopupMenu;
    BtnInsertFieldTag: TTBXButton;
    BtnInsertOperator: TTBXButton;
    PopupOperators: TTBXPopupMenu;
    Operators: TAntStringList;
    OperatorsToken: TAntStringList;
    ApplicationEvents1: TApplicationEvents;
    procedure ActionDisplayMainToolbarExecute(Sender: TObject);
    procedure ActionDisplayPictureToolbarExecute(Sender: TObject);
    procedure ActionDisplayExtrasToolbarExecute(Sender: TObject);
    procedure ActionDisplayStatusBarExecute(Sender: TObject);
    procedure ActionExitExecute(Sender: TObject);
    procedure ActionFileExportExecute(Sender: TObject);
    procedure ActionFileImportExecute(Sender: TObject);
    procedure ActionFileNewExecute(Sender: TObject);
    procedure ActionFileOpenExecute(Sender: TObject);
    procedure ActionFilePrintExecute(Sender: TObject);
    procedure ActionFilePropertiesExecute(Sender: TObject);
    procedure ActionFileSaveAsExecute(Sender: TObject);
    procedure ActionFileSaveExecute(Sender: TObject);
    procedure ActionFindDisplayExecute(Sender: TObject);
    procedure ActionFindFindnextExecute(Sender: TObject);
    procedure ActionFindWholefieldExecute(Sender: TObject);
    procedure ActionFindReverseExecute(Sender: TObject);
    procedure ActionGroupExecute(Sender: TObject);
    procedure ActionGroupsFormatExecute(Sender: TObject);
    procedure MnuGrpsFormatRTClick(Sender: TObject);
    procedure ActionSortExecute(Sender: TObject);
    procedure ActionGridFieldsExecute(Sender: TObject);
    procedure ActionHelpAboutExecute(Sender: TObject);
    procedure ActionHelpIndexExecute(Sender: TObject);
    procedure ActionLanguageExecute(Sender: TObject);
    procedure ActionLoanExecute(Sender: TObject);
    procedure ActionMenuFileExecute(Sender: TObject);
    procedure ActionMenuGetExecute(Sender: TObject);
    procedure ActionMenuGroupExecute(Sender: TObject);
    procedure ActionMenuSortExecute(Sender: TObject);
    procedure ActionMenuHelpExecute(Sender: TObject);
    procedure ActionMenuMovieExecute(Sender: TObject);
    procedure ActionMenuDisplayExecute(Sender: TObject);
    procedure ActionMenuPictureExecute(Sender: TObject);
    procedure ActionMenuToolsExecute(Sender: TObject);
    procedure ActionMovieAddExecute(Sender: TObject);
    procedure ActionMovieCopyExecute(Sender: TObject);
    procedure ActionMovieDeleteExecute(Sender: TObject);
    procedure ActionMovieFindExecute(Sender: TObject);
    procedure ActionMovieImportCDExecute(Sender: TObject);
    procedure ActionMovieImportFilesExecute(Sender: TObject);
    procedure ActionMovieImportScriptExecute(Sender: TObject);
    procedure ActionMovieNextExecute(Sender: TObject);
    procedure ActionMovieNumberExecute(Sender: TObject);
    procedure ActionMoviePasteExecute(Sender: TObject);
    procedure ActionMoviePictureShowExecute(Sender: TObject);
    procedure ActionMovieExtrasShowExecute(Sender: TObject);
    procedure ActionMoviePreviousExecute(Sender: TObject);
    procedure ActionMovieRenumberExecute(Sender: TObject);
    procedure ActionMovieSearchExecute(Sender: TObject);
    procedure ActionMovieSelGroupExecute(Sender: TObject);
    procedure ActionMovieSelCheckExecute(Sender: TObject);
    procedure ActionMovieSelUncheckExecute(Sender: TObject);
    procedure ActionMovieCheckExecute(Sender: TObject);
    procedure ActionMovieUncheckExecute(Sender: TObject);
    procedure ActionMovieSelTaggedExecute(Sender: TObject);
    procedure ActionMovieTagSelectedExecute(Sender: TObject);
    procedure ActionMovieStatsExecute(Sender: TObject);
    procedure ActionMovieUndoExecute(Sender: TObject);
    procedure ActionMovieRandomExecute(Sender: TObject);
    procedure ActionOptionsExecute(Sender: TObject);
    procedure ActionPicCopyExecute(Sender: TObject);
    procedure ActionPicPasteExecute(Sender: TObject);
    procedure ActionPicDeleteExecute(Sender: TObject);
    procedure ActionPicSaveAsExecute(Sender: TObject);
    procedure ActionPicSelectExecute(Sender: TObject);
    procedure ActionPicUndockExecute(Sender: TObject);
    procedure ActionRefreshExecute(Sender: TObject);
    procedure ActionToolsGridExecute(Sender: TObject);
    procedure ActionManagePicturesExecute(Sender: TObject);
    procedure ActionToolsScriptingExecute(Sender: TObject);
    procedure ActionURLBrowseExecute(Sender: TObject);
    procedure ActionURLOpenExecute(Sender: TObject);
    procedure ActionURLCopyExecute(Sender: TObject);
    procedure ActionURLExploreExecute(Sender: TObject);
    procedure ActionHelpVersionExecute(Sender: TObject);
    procedure ActionStretchListExecute(Sender: TObject);
    procedure ActionDisplayHTMLExecute(Sender: TObject);
    procedure ActionDisplayThumbnailsExecute(Sender: TObject);
    procedure ActionMenuGridFieldsExecute(Sender: TObject);
    procedure ActionHTMLEditorExecute(Sender: TObject);
    procedure cbxFieldChange(Sender: TObject);
    procedure cbxFieldClick(Sender: TObject);
    procedure DockBottomListRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DockImageLeftRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DockMainBottomRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DockMainLeftRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DockMainTopRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DockRightExtrasRequestDock(Sender: TObject; Bar: TTBCustomDockableWindow; var Accept: Boolean);
    procedure DragDropFilesDropApp(Sender: TObject; Pos: TPoint; Value: TStringList);
    procedure DragDropFilesDrop(Sender: TObject; Pos: TPoint; Value: TStringList);
    procedure EValueChange(Sender: TObject);
    procedure TimerSearchEvent(Sender: TObject);
    procedure EValueKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1AfterSelectionChange(Sender: TObject);
    procedure TimerAfterSelectEvent(Sender: TObject);
    procedure ListView1ItemSelectedChange(Sender: TObject; Item: TElTreeItem);
    procedure ListView1ItemFocused(Sender: TObject);
    procedure ListView1ItemCollapse(Sender: TObject; Item: TElTreeItem);
    procedure ListView1ItemExpand(Sender: TObject; Item: TElTreeItem);
    procedure ListView1CompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
    procedure ListView1ItemChecked(Sender: TObject; Item: TElTreeItem);
    procedure ListView1ItemColorPick(Sender: TObject; Item: TElTreeItem);
    procedure ListView1ItemColorChange(newColorTag: Integer; Item: TElTreeItem);
    procedure ListView1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListView1HeaderColumnClick(Sender: TObject; SectionIndex: Integer);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ListView1Resize(Sender: TObject);
    procedure ListView1HeaderColumnResize(Sender: TObject;
      SectionIndex: Integer);
    procedure MoviePictureMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PopupMovieListPopup(Sender: TObject);
    procedure SplitterBottomListCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure SplitterRightExtrasCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure TBMRUList1Click(Sender: TObject; const Filename: String);
    procedure ToolbarFindVisibleChanged(Sender: TObject);
    procedure ToolbarMainClose(Sender: TObject);
    procedure ToolbarPictureClose(Sender: TObject);
    procedure FrmMovieExtrasToolbarExtrasClose(Sender: TObject);
    procedure ToolbarPictureWindowClose(Sender: TObject);
    procedure ToolbarPictureWindowDockChanged(Sender: TObject);
    procedure ToolbarExtrasWindowClose(Sender: TObject);
    procedure ToolbarExtrasWindowDockChanged(Sender: TObject);
    procedure TabMovieInfosChange(Sender: TObject);
    procedure TabMovieInfosResize(Sender: TObject);
    procedure FrmMovieMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure SplitterFrmBothMoved(Sender: TObject);

    procedure InitFieldTags;
    procedure InitOperators;
    procedure PopupFieldsPopup(Sender: TObject);
    procedure PopupOperatorsPopup(Sender: TObject);
    procedure InsertFieldTagClick(Sender: TObject);
    procedure InsertOperatorClick(Sender: TObject);

    {FrameMovie}
    procedure OnURLButtonClick(Sender: TObject);
    procedure OnURLEnter(Sender: TObject);
    procedure OnFieldChange(Sender: TObject);
    procedure OnFieldPropertiesChange(Sender: TObject);
    procedure OnCustomFieldAdd(Sender: TObject);
    procedure OnCustomFieldModify(Sender: TObject);
    procedure OnCustomFieldDelete(Sender: TObject);
    procedure OnFieldValidate(Sender: TObject);
    procedure OnExtrasBeforeChange(Sender: TObject);
    procedure OnExtrasChange(Sender: TObject);
    {End FrameMovie}

    {HTMLViewer}
    procedure HTMLViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure HTMLViewerImageRequest(Sender: TObject; const SRC: String; var Stream: TMemoryStream);
    procedure HTMLViewerImageClick(Sender, Obj: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure HTMLViewerKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure HTMLViewerHotSpotClick(Sender: TObject; const SRC: String; var Handled: Boolean);
    procedure HTMLViewerRightClick(Sender: TObject; Parameters: TRightClickParameters);
    procedure HTMLPopupClickBrowse(Sender: TObject);
    procedure HTMLPopupClickSelect(Sender: TObject);
    procedure MnuHtmlCopyClick(Sender: TObject);
    procedure MnuHtmlEditClick(Sender: TObject);
    procedure MnuTlsSelHTMLPopup(Sender: TTBCustomItem; FromLink: Boolean);
    procedure ActionSelectHTMLExecute(Sender: TObject);
    procedure ActionMovieUrlExecute(Sender: TObject);
    procedure ActionMovieFilePathExecute(Sender: TObject);
    {End HTMLViewer}

    {ThumbsViewer}
    procedure CMUpdateView(var message: TMessage); message CM_UpdateView;
    procedure ItemPaintBasic(Canvas: TCanvas; R: TRect; State: TsvItemState; Focused: Boolean);
    procedure ThumbsViewerCellPaint(Sender: TObject; Canvas: TCanvas; Cell: TRect;
      IdxGrp, IdxItem: Integer; Data: Int64; State: TsvItemState);
    procedure ThumbsViewerDividerPaint(Sender: TObject; Canvas: TCanvas;
      Cell: TRect; IdxGrp: Integer; Group: PSmartGroup; State: TsvItemState);
    procedure ThumbsViewerHeaderPaint(Sender: TObject; Canvas: TCanvas;
      Header: TRect; Offset, Active: Integer; State: TsvItemState; Columns: array of Integer);
    procedure ThumbsViewerSelecting(Sender: TObject; Count: Integer);
    procedure ThumbsViewerCellSelectedChange(Sender: TObject; IdxGrp,
      IdxItem: Integer; Data: Int64; Selected: Boolean);
    procedure ThumbsViewerCellHit(Sender: TObject; Canvas: TCanvas;
      IdxGrp, IdxItem: Integer; Data: Int64; x, y: Integer; Shift: TShiftState;
      Clicked: Boolean; Button: TMouseButton; var Selected: Boolean);
    procedure ThumbsViewerDividerHit(Sender: TObject; Canvas: TCanvas;
      IdxGrp: Integer; Group: PSmartGroup; x: Integer; Shift: TShiftState;
      Clicked: Boolean; Button: TMouseButton; var Selected: Boolean;
      var Expanded: Boolean);
    procedure ThumbsViewerDividerExpandedChange(Sender: TObject;
      IdxGrp: Integer; Group: PSmartGroup; Expanded: Boolean);
    procedure ThumbsViewerHeaderClick(Sender: TObject; Column: Integer);
    procedure ThumbsViewerDblClick(Sender: TObject);
    procedure ThumbsViewerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ThumbsViewerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ThumbsViewerKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ThumbsViewerResize(Sender: TObject);
    procedure ThumbsSizerChange(Sender: TObject);
    procedure ThumbsDisplayTitleClick(Sender: TObject);
    procedure ThumbsViewerCellFocusedChange(Sender: TObject; IdxGrp,
      IdxItem: Integer; Data: Int64);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    {End ThumbsViewer}

  private
    MovieList:          TMovieList;
    MovieSave:          TMovie;
    PanelLeftOldWidth:  Integer;
    SelectedItem:       TElTreeItem;
    CurrentItem:        TElTreeItem;
    FCatalogFile:       TFileManager;
    FCurrentVersion:    Integer;
    FGroupField:        Integer;
    FSortField:         Integer;
    DragDropFiles:      TJvDragDrop;
    NbMoviesVisible:    Integer;
    NbMoviesChecked:    Integer;
    NbMoviesSelected:   Integer;
    NbGroupsSelected:   Integer;
    GroupItemEmpty:     TElTreeItem;
    FSelectedURL:       TAntJvComboEditXP;
    FURL:               string;
    FCancelDragDrop:    Boolean;
    FMouseMovieListX:   Integer;
    FMouseMovieListY:   Integer;
    FMouseHTMLViewerX:  Integer;
    FMouseHTMLViewerY:  Integer;
    FPrevFocused:       TWinControl;
    FPreviousNbExtras:  Integer;

    {HTMLViewer}
    MStream:            TMemoryStream;
    MStreamAppr:        array[0..4] of TMemoryStream;
    MStreamAppr10:      array[0..10] of TMemoryStream;
    HTMLTemplatePreGenerated: TStringList;
    HTMLTemplateFileRef: string;
    HTMLTemplateContainsChecked: Boolean;
    HTMLTemplateContainsColorTag: Boolean;
    HTMLTemplateContainsExtras: Boolean;
    HTMLDisplayExcludedTemplates: TStringList;
    HTMLDisplayExcludedTemplatesModifiedDate: TDateTime;
    {End HTMLViewer}

    {ThumbsViewer}
    ThumbSizeW, ThumbSizeH: Integer;
    ThumbJPEG: TJpegImage;
    ThumbGIF: TJvGIFImage;
    ThumbPNG: TPNGObject;
    ThumbBMP: TBitmap;
    ThumbLoading: TBitmap;
    WI, HI: Integer;
    CellJpeg : TJpegImage;
    CellScale: Integer;
    CellStyle: Integer;
    ThumbsPool: TList;
    PoolSize, MaxPool: Integer;
    FullExpandOrCollapse: Boolean;
    TimeUpdateView: TDateTime;
    ThumbCheckboxOver: Int64;
    ThumbCheckboxClick: Boolean;
    {End ThumbsViewer}

    procedure EnsureVisibleListView1(Item: TElTreeItem);
    procedure ListView1EnsureVisiblePlus;

    function OpenItem(const Item: TElTreeItem): integer;
    procedure UpdateCurrentItem;
    procedure UpdateCurrentItemIfNeeded;
    function SaveCurrentItem(const FreeMovieSave: Boolean = True): integer;

    procedure ClearItem;
    procedure NewItem;
    function AddItem(Movie: TMovie; GroupItem: TElTreeItem): TElTreeItem;
    function DeleteItem(Movie: TMovie; const CanShowWindow, ShowAllButtons: Boolean): Integer;
    function AddGroupItem(GroupName: string) : TElTreeItem;
    function GetGroupNameWithoutCount(GroupName: string) : string;
    procedure UpdateGroupName(GroupItem: TElTreeItem; GroupNameWithoutCount: string);

    procedure RemoveMoviePicture;
    procedure LoadMoviePicture(const ForceLoad: Boolean = False);
    procedure ImportMoviePicture(Movie: TMovie; const AFileName: TFileName;
      const ImportMethod: TPictureSelectOption);
    procedure ImportMoviePictureFromStream(Movie: TMovie; Stream: TMemoryStream; DefaultExt: string;
      const ImportMethod: TPictureSelectOption);

    procedure MovieSelected;
    procedure MakeMovieSave(Movie: TMovie; LockPicture: Boolean = True);

    procedure OnFileModified(Sender: TObject; State: Boolean);
    procedure OnFileChange(Sender: TObject; AFileName: TFileName);
    procedure OnNewFile(Sender: TObject; AFileName: TFileName);
    procedure OnOpenFile(Sender: TObject; AFileName: TFileName);
    procedure OnBeforeSaveFile(Sender: TObject; OldFileName: TFileName;
      NewFileName: TFileName; var Result: Boolean);
    procedure OnSaveFile(Sender: TObject; AFileName: TFileName);
    procedure OnDialogTypeChange(Sender: TObject);
    procedure SetSaveFilter;
    procedure SetTitle;
    procedure SetStatus;
    procedure UpdateMRU(const strFilePath: string);

    procedure RefreshMovieList(const KeepSelection: Boolean = True; const SaveColumnSettingsCF: Boolean = True);
    procedure SaveColumnSettings(const SaveCustomFields: Boolean = True);
    procedure RestoreColumnSettings;
    procedure SetGroupField(Field: Integer);
    procedure SetSortField(Field: Integer; Descend: Boolean; SortList: Boolean = True);

    procedure LoadSelectedState;
    procedure AutoStretchList;

    procedure LoadOptions;
    procedure ApplyOptions;
    procedure ApplyLanguage;
    procedure SearchInternetClick(Sender: TObject);
    procedure RebuildSearchMenu;
    procedure FillFieldsSortBy;
    procedure FillFieldsGroupBy;
    procedure FillImageListColorsTag;
    procedure FillColorTagSelect;
    procedure FillColorTagSelected;
    procedure FillFieldsGrid;
    procedure FillFieldsCBFind(SelectedItem: Integer = 0);
    procedure LoadSortField;
    procedure SaveSortField;
    procedure LoadGroupField;
    procedure LoadGroupsFormat;
    procedure SaveGroupField;
    procedure LoadFindField;
    procedure SaveFindField;
    procedure SaveOptions;
    procedure LoadLists;
    procedure SaveLists;
    procedure UpdateLists;

    function OnAppHelp(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;
    procedure OnCancelDragDrop(Sender: TObject);

    {HTMLViewer}
    procedure HTMLViewerUpdate;
    procedure PreGenerateHTMLTemplate;
    function GenerateHTMLCurrentMovie : string;
    procedure ReplaceTagsExtras(var Page: string; const AMovie: TMovie;
      const LineBreak: string; const HTMLExtraPicAttr: string);
    procedure ReplaceTagsExtra(var Page: string; const AMovie: TMovie;
      const AExtra: TMovieExtra; const LineBreak: string; const HTMLExtraPicAttr: string;
      const ExtraRecNr: Integer);
    {End HTMLViewer}

    {ThumbsViewer}
    procedure ThumbsGetThumbnail(Sender: TObject; Picture: TMoviePicture);
    function GetThumbBmp(Picture: TMoviePicture): TBitmap;
    procedure SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
    procedure ClearThumbsPool;
    procedure EnsureVisibleThumbsViewer(IdxGrp: Integer; IdxItem: Integer); overload;
    procedure EnsureVisibleThumbsViewer(Item: TElTreeItem); overload;
    procedure ThumbsViewerEnsureVisiblePlus;
    {End ThumbsViewer}

    procedure CheckAnchorMovieExtras;

  protected
    {ThumbsViewer}
    ThumbThr: ThumbThread;
    ThreadDone: Boolean;
    {End ThumbsViewer}

  public
    {ThumbsViewer}
    // Colors
    cGSelectedStart,
    cGSelectedEnd,
    cGSelectedFocusedStart,
    cGSelectedFocusedEnd,
    cGHotStart,
    cGHotEnd,
    cGDisabledStart,
    cGDisabledEnd,
    cGDisabledFocusedStart,
    cGDisabledFocusedEnd,
    cGHeaderStart,
    cGHeaderEnd,
    cGHeaderHotStart,
    cGHeaderHotEnd,
    cGHeaderSelStart,
    cGHeaderSelEnd,
    cHot,
    cSelected,
    cSelectedFocused,
    cDisabled,
    cDisabledFocused,
    cBackground,
    cLineHighLight,
    cShadeHot,
    cShadeSelect,
    cShadeSelectFocused,
    cShadeDisabled,
    cShadeDisabledFocused: TColor;

    CellShade0: TColor;
    CellShade1: TColor;
    CellShade2: TColor;
    CellShade3: TColor;
    CellShade4: TColor;
    CellBkgColor: TColor;
    CellBrdColor: array[Boolean, Boolean] of TColor;

    procedure GenCellColors;

    procedure StartThumbThread;
    procedure StopThumbThread;
    procedure ThumbsViewerStop;
    procedure ThumbsViewerStart;
    {End ThumbsViewer}

    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function DeleteOldCatalogCopiedPictures(AFileName: TFileName): Boolean;

    procedure StoreSelectedState;
    property CurrentMovieList: TMovieList read MovieList;
  end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  MainWindow: TMainWindow;

implementation

uses
  CommDlg, ExtDlgs, Math, DateUtils, StrUtils,

  IdURI,

  rmkGradient, rmkFunctions,

  {$IFNDEF DISABLETHEMES}
  TBXOfficeXPTheme,
  {$ENDIF}

  functions_str, functions_sys, functions_video, functions_files, functions_gui,
  functions_xml, functions_img,

  Global, options, about, export, number, loan, splash, stats, customfieldsmanager,
  renumber, properties, loanhistory, getscript, Languageselect,
  ProgramSettings, printform, PictureSelection, PictureDragDrop, pictureform,
  progress, getmedia, import2, Variants, SyncObjs, Types, stringfilter,
  picturesmanager, getscript_results, HTMLEditor, sort, ExpressionParser;

{$R *.DFM}

const
  // Messages
  msgDeleteMovie          = 0;
  msgUndo                 = 1;
  msgStatusCount          = 2;
  msgStatusVisible        = 3;
  msgUnsavedFile          = 4;
  msgDoNotConfirm         = 5;
  msgUnsavedStatus        = 6;
  msgPicture              = 7;
  msgPicSaveAs            = 8;
  msgImporting            = 9;
  msgSaving               = 10;
  msgLoading              = 11;
  msgPicOpen              = 12;
  msgPicDelete            = 13;
  msgPicLoadFailed        = 14;
  msgByteString           = 15;
  msgSelectFilesInfo      = 16;
  msgSearchInfo           = 17;
  msgNoRecentFile         = 18;
  msgXmlConvertImages     = 19;
  msgGroupBy              = 20;
  msgGroupEmpty           = 21;
  msgPicDeleteLink        = 22;
  msgPicReplaceLink       = 23; // Not used
  msgPicCopyNoCatPath     = 24; // Not used
  msgPicHintStored        = 25;
  msgPicHintLinked        = 26;
  msgPicHintInfo          = 27;
  msgPrintLoading         = 28;
  msgPrintSearching       = 29;
  msgSelectFileURL        = 30;
  msgGroupUnique          = 31;
  msgFindFieldAll         = 32;
  msgSortBy               = 33;
  msgMovieFields          = 34;
  msgCustomFields         = 35;
  msgFileNotExists        = 36;
  msgSaveAMC35Warning     = 37;
  msgDragDropFiles        = 38;
  msgColorTagSelect       = 39;
  msgColorTagSelected     = 40;
  msgMovieAndCustomFields = 41;
  msgCatalogExists        = 42;
  msgCopyPasteMovie       = 43;
  msgDeleteCopiedPics     = 44;
  msgSaveInPicDir         = 45;
  msgExtras               = 46;
  msgSaveAMC41Warning     = 47;
  msgFindAdvanced         = 48;

  panelHint     = 0;
  panelModified = 1;
  panelCount    = 2;
  
const
  HTMLPicMovieTag = '*PicMovie:';
  HTMLPicExtraTag = '*PicExtra:';
  HTMLPicApprTag  = '*PicAppr:';
  HTMLNoPopupTag  = '*NoPopup:';

{-------------------------------------------------------------------------------
  Ensure Visible (Plus for groups) on item
-------------------------------------------------------------------------------}

procedure TMainWindow.EnsureVisibleListView1(Item: TElTreeItem);
begin
  if (Item <> nil) then
    if (Item.Parent <> nil) then
    begin
      if Item.Parent.Expanded then
      begin
        ListView1.EnsureVisible(Item.Parent);
        ListView1.EnsureVisibleBottom(Item);
      end
      else
        ListView1.EnsureVisible(Item.Parent);
    end
    else
      ListView1.EnsureVisible(Item);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1EnsureVisiblePlus;
begin
  {if (NbMoviesSelected = 1) then
  begin
    EnsureVisibleListView1(SelectedItem);
  end;}
  EnsureVisibleListView1(ListView1.ItemFocused);
end;

{-------------------------------------------------------------------------------
   Item management
-------------------------------------------------------------------------------}

function TMainWindow.OpenItem(const Item: TElTreeItem): Integer;
var
  AMovie: TMovie;
begin
  Result := -1;
  if (Item <> nil) and (Item.Data <> nil) then
  begin
    CurrentItem := Item;
    AMovie := TMovie(CurrentItem.Data);
    FrmMovie.LoadFromObject(AMovie);
    FrmMovieCustom.LoadFromObject(AMovie);
    LoadMoviePicture;
    FrmMovieExtras.CurrentMovie := AMovie;
    HTMLViewerUpdate;
    Result := 0;
  end else
  begin
    CurrentItem := nil;
    HTMLViewerUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

// Update current item (save movie and update list item)
procedure TMainWindow.UpdateCurrentItem;
var
  Modifs: Boolean;
  i, j: Integer;
  List: TObjectList;
  SameItem: TElTreeItem;
  FieldValue: string;
  Movie: TMovie;
  SortField: Integer;
  OldSortFieldValue, SortFieldValue: string;

  procedure UpdateI(Field: Integer; Text: string);
  var
    ListField: Integer;
  begin
    ListField := Field;
    if ListField >= customFieldLow then
      ListField := ListField - customFieldLow + fieldCount;
    if ListField >= fieldFormattedTitle then
      Dec(ListField);
    ListField := ListField + 2;
    if (Settings.rOptions.rMovieList.GridTextSize > 0) and (Field <> fieldFormattedTitle) and
       (Field <> fieldTranslatedTitle) and (Field <> fieldOriginalTitle) then
      FieldValue := Copy(Text, 1, Settings.rOptions.rMovieList.GridTextSize)
    else
      FieldValue := Text;
    if not AnsiSameStr(FieldValue, CurrentItem.SubItems.Strings[ListField]) then
    begin
      if not Modifs then
      begin
        Modifs := True;
        ListView1.Items.BeginUpdate;
      end;
      CurrentItem.SubItems.Strings[ListField] := FieldValue;
    end;
  end;

  function SortAdvancedFieldValue: string;
  var
    f: Integer;
    str: string;
  begin
    Result := '';
    with Settings.rMain.SortAdvancedFields do
      for f := 0 to Count-1 do
      begin
        str := Strings[f];
        if str[1] = '-' then
          System.Delete(str, 1, 1);
        if (str[1] in ['0'..'9']) then // movie field (Field Id)
          Result := Result + Movie.GetFieldValue(StrToIntDef(str, -1))
        else // custom field (Custom Field Tag)
          Result := Result + Movie.CustomFields.GetFieldValue(str);
      end;
  end;

begin
  if (CurrentItem <> nil) then
  begin
    Modifs := False;
    Movie := TMovie(CurrentItem.Data);
    OldSortFieldValue := '';
    SortFieldValue := '';
    SortField := Abs(FSortField) - 1;

    if ActionToolsGrid.Checked then
    begin
      if SortField = SortAdvancedField then
        OldSortFieldValue := SortAdvancedFieldValue;
      FrmMovie.SaveToObject(Movie);
      FrmMovieCustom.SaveToObject(Movie);
      FrmMovieExtras.Modified := False;
      if SortField = SortAdvancedField then
        SortFieldValue := SortAdvancedFieldValue;
      for i := fieldLow to fieldCount-1 do
        if i <> fieldFormattedTitle then
          UpdateI(i, Movie.GetFieldValue(i, True));
      with MovieList.CustomFieldsProperties do
        for i := 0 to Count-1 do
          UpdateI(customFieldLow+i, Movie.CustomFields.GetFieldValue(Objects[i].FieldTag, True));
      if Modifs or (not AnsiSameStr(OldSortFieldValue, SortFieldValue)) then
      begin
        if not Modifs then
        begin
          Modifs := True;
          ListView1.Items.BeginUpdate;
        end;
        CurrentItem.Text := Movie.GetFormattedTitle;
        CurrentItem.SubItems.Strings[1] := ''; // Hidden column; Needed to force automatic sort on item
      end;
    end else
    begin
      if SortField = SortAdvancedField then
        OldSortFieldValue := SortAdvancedFieldValue
      else if SortField < fieldCount then
        OldSortFieldValue := Movie.GetFieldValue(SortField)
      else if (SortField >= customFieldLow) and (SortField - customFieldLow < MovieList.CustomFieldsProperties.Count) then
        OldSortFieldValue := Movie.CustomFields.GetFieldValue(MovieList.CustomFieldsProperties.Strings[SortField - customFieldLow]);
      FrmMovie.SaveToObject(Movie);
      FrmMovieCustom.SaveToObject(Movie);
      FrmMovieExtras.Modified := False;
      if SortField = SortAdvancedField then
        SortFieldValue := SortAdvancedFieldValue
      else if SortField < fieldCount then
        SortFieldValue := Movie.GetFieldValue(SortField)
      else if (SortField >= customFieldLow) and (SortField - customFieldLow < MovieList.CustomFieldsProperties.Count) then
        SortFieldValue := Movie.CustomFields.GetFieldValue(MovieList.CustomFieldsProperties.Strings[SortField - customFieldLow]);
      FieldValue := Movie.GetFormattedTitle;
      if (not AnsiSameStr(OldSortFieldValue, SortFieldValue)) or
        (not AnsiSameStr(FieldValue, CurrentItem.Text)) or
        (not AnsiSameStr(Movie.GetFieldValue(fieldNumber), CurrentItem.SubItems.Strings[0])) then
      begin
        Modifs := True;
        ListView1.Items.BeginUpdate;
        CurrentItem.Text := FieldValue;
        CurrentItem.SubItems.Strings[0] := Movie.GetFieldValue(fieldNumber);
        CurrentItem.SubItems.Strings[1] := ''; // Hidden column for other field sort; Needed to force automatic sort on item
      end;
    end;

    with Settings.rOptions.rMovieList do
      if (CurrentItem.Checked <> Movie.bChecked) or
        (CheckboxesColor and (CurrentItem.CheckBoxColor <> ColorsTag[Movie.iColorTag])) or
        (LinesColor and (CurrentItem.RowBkColor <> ColorsTag[Movie.iColorTag])) then
      begin
        List := TObjectList(Movie._listItems);
        for i := 0 to List.Count-1 do
        begin
          SameItem := TElTreeItem(List.Items[i]);
          SameItem.Checked := Movie.bChecked;
          if CheckboxesColor then // CheckBoxColor
            SameItem.CheckBoxColor := ColorsTag[Movie.iColorTag];
          if LinesColor then // LineColor
          begin
            SameItem.RowBkColor := ColorsTag[Movie.iColorTag];
            SameItem.BkColor := CurrentItem.RowBkColor;
          end;
        end;
      end;

    if Modifs then
    begin
      List := TObjectList(Movie._listItems);
      for i := 0 to List.Count-1 do
      begin
        SameItem := TElTreeItem(List.Items[i]);
        if SameItem <> CurrentItem then
        begin
          for j := 0 to SameItem.SubItems.Count-1 do
          begin
            SameItem.SubItems.Strings[j] := CurrentItem.SubItems.Strings[j];
          end;
          SameItem.Text := CurrentItem.Text;
        end;
      end;
      i := CurrentItem.AbsoluteIndex;
      ListView1.Items.EndUpdate;
      j := CurrentItem.AbsoluteIndex;
      if(i <> j) then
      begin
        ListView1EnsureVisiblePlus;
        ThumbsViewerStart;
      end
      else //if(ActionDisplayThumbnails.Checked) then
        ThumbsViewer.Invalidate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

// Update current item if FrmMovie or FrmMovieCustom has been modified
procedure TMainWindow.UpdateCurrentItemIfNeeded;
begin
  if FrmMovie.Modified or FrmMovieCustom.Modified or FrmMovieExtras.Modified then
    UpdateCurrentItem;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

// Save current item (save movie, update list item, save borrower, update list values)
function TMainWindow.SaveCurrentItem(const FreeMovieSave: Boolean): Integer;
var
  AMovie: TMovie;
begin
  Result := -1;
  if (CurrentItem = nil) then
    Exit;

  // Save borrower
  AMovie := TMovie(CurrentItem.Data);
  with FrmMovie, AMovie, Settings.rOptions.rFiles do
    if History and (strBorrower <> EBorrower.Text) then
    begin
      SetCurrentDir(strDirData);
      with TLoanHistory.Create(ExpandFileName(HistoryFile), ExtractFileName(FCatalogFile.CurrentFile)) do
      try
        if strBorrower <> '' then
          Add(strBorrower, iNumber, strMedia, GetFormattedTitle, lhIn);
        if EBorrower.Text <> '' then
          Add(EBorrower.Text, iNumber, strMedia, GetFormattedTitle, lhOut);
      finally
        Free;
      end;
    end;

  // Save movie and update list item if needed
  UpdateCurrentItemIfNeeded;

  if FreeMovieSave then
    FreeAndNil(MovieSave);

  // Update list values
  UpdateLists;
  Result := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ClearItem;
begin
  FrmMovie.LoadFromObject(Settings.rOptions.rMovieInformation.rDefaultMovie.Values);
  FrmMovieCustom.SetDefaultValues;
  FrmMovieExtras.CurrentMovie := nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.NewItem;
var
  Item: TElTreeItem;
  NewMovie, Existing: TMovie;
begin
  SaveCurrentItem;

  ThumbsViewerStop;
  FrmMovieExtras.ThumbsViewerStop;

  ListView1.DeselectAll;
  NewMovie := MovieList.Add;
  NewMovie.bChecked := True;
  NewMovie._bSelected := True;
  NewMovie.Assign(Settings.rOptions.rMovieInformation.rDefaultMovie.Values, False, False, False, False, True);
  if Settings.rOptions.rMovieInformation.SetCurrentDate then
    NewMovie.iDate := Trunc(Date);
  NewMovie.CustomFields.SetDefaultValues;
  NewMovie.iNumber := NumberWin.ENumber.AsInteger;
  if Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath <> '' then
    try
      NewMovie.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath,
        FCatalogFile.CurrentFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rPicImport.GetInfoMethod)));
    except
    end;

  case NumberWin.grpNotUnique.ItemIndex of
    1:
      begin
        Existing := MovieList.Find(NumberWin.ENumber.AsInteger);
        if Existing <> nil then
        begin
          if Settings.rOptions.rMovieInformation.FirstAvailable then
            Existing.iNumber := MovieList.FirstFreeNumber
          else
            Existing.iNumber := MovieList.MaxNumber + 1; // + 1 !
        end;
        StoreSelectedState;
        NewMovie._bSelected := True;
        RefreshMovieList(False);
        LoadSelectedState;
        ListView1EnsureVisiblePlus;
        ThumbsViewerEnsureVisiblePlus;
      end;
    2:
      begin
        MovieList.ShiftNumbers(NumberWin.ENumber.AsInteger, NewMovie);
        StoreSelectedState;
        NewMovie._bSelected := True;
        RefreshMovieList(False);
        LoadSelectedState;
        ListView1EnsureVisiblePlus;
        ThumbsViewerEnsureVisiblePlus;
      end;
    else
      begin
        ListView1.Items.BeginUpdate;
        if (FGroupField <> GroupNoneField) then
        begin
          if GroupItemEmpty = nil then
          begin
            GroupItemEmpty := AddGroupItem(Messages.Strings[msgGroupEmpty]);
            Item := AddItem(NewMovie, GroupItemEmpty);
            UpdateGroupName(GroupItemEmpty, GroupItemEmpty.Text);
          end else
          begin
            Item := AddItem(NewMovie, GroupItemEmpty);
            UpdateGroupName(GroupItemEmpty, GetGroupNameWithoutCount(GroupItemEmpty.Text));
          end;
          GroupItemEmpty.Expanded := True;
        end else
          Item := AddItem(NewMovie, nil);
        ListView1.ItemFocused := Item;
        ListView1.Items.EndUpdate;
        ListView1EnsureVisiblePlus;
        ThumbsViewerStart;
        ListView1AfterSelectionChange(nil);
        SetStatus;
      end;
  end;

  FCatalogFile.Modified := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.AddItem(Movie: TMovie; GroupItem: TElTreeItem) : TElTreeItem;
var
  j: Integer;
  Prop: TCustomFieldProperties;
begin
  if Movie._listItems.Count = 0 then
  begin
    Inc(NbMoviesVisible);
    if Movie.bChecked then
      Inc(NbMoviesChecked);
  end;

  Result := ListView1.Items.AddChild(GroupItem, Movie.GetFormattedTitle);
  Movie._listItems.Add(Result);
  // *** Adding each item to the list ***
  with Result do
  begin
    if ActionToolsGrid.Checked then
    begin
      SubItems.Add(''); // Invisible column Number
      SubItems.Add(''); // Invisible column FormattedTitle, also used for advanced sort
      SubItems.Add(IntToStr(Movie.iNumber)); 
      for j := 0 to fieldCount-1 do
        if not (j in [fieldNumber, fieldFormattedTitle]) then
        begin
          if (Settings.rOptions.rMovieList.GridTextSize > 0) and
            not (j in [fieldFormattedTitle, fieldOriginalTitle, fieldTranslatedTitle]) then
          begin
            SubItems.Add(Copy(Movie.GetFieldValue(j, True), 1, Settings.rOptions.rMovieList.GridTextSize));
          end else
          begin
            SubItems.Add(Movie.GetFieldValue(j, True));
          end;
        end;
      with MovieList.CustomFieldsProperties do
        for j := 0 to Count-1 do
        begin
          Prop := Objects[j];
          if (Settings.rOptions.rMovieList.GridTextSize > 0) then
          begin
            SubItems.Add(Copy(Movie.CustomFields.GetFieldValue(Prop.FieldTag, True), 1, Settings.rOptions.rMovieList.GridTextSize));
          end else
          begin
            SubItems.Add(Movie.CustomFields.GetFieldValue(Prop.FieldTag, True));
          end;
        end;
    end else
    begin
      SubItems.Add(IntToStr(Movie.iNumber));
      SubItems.Add(''); // Invisible column used for other sorts
    end;
    Checked := Movie.bChecked;
    Data := Movie;
    ShowCheckBox := True;
    Tag := 0;

    with Settings.rOptions.rMovieList do
    begin
      if CheckboxesColor then // CheckBoxColor
      begin
        UseCheckBoxColor := True;
        CheckBoxColor := ColorsTag[Movie.iColorTag];
      end;
      if LinesColor then // LineColor
      begin
        UseBkColor := True;
        ParentColors := False;
        RowBkColor := ColorsTag[Movie.iColorTag];
        BkColor := RowBkColor;
      end;
      //ShowHint := False;
      //Hint := 'Tag '+ Movie.iColorTag;
    end;
  end; // with Item
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.DeleteItem(Movie: TMovie; const CanShowWindow, ShowAllButtons: Boolean): Integer;
var
  DoNotAsk: Boolean;
  Buttons: array of Variant;
  Res, i: Integer;
  Item, ItemParent: TElTreeItem;
begin
  if ShowAllButtons then
    Buttons := VarArrayOf([mbYes,mbYesToAll,mbNo,mbNoToAll])
  else
    Buttons := VarArrayOf([mbYes,mbNo]);
  Result := -1;
  if Movie <> nil then
  begin
    if Settings.rOptions.rMovieList.ConfirmDelete and CanShowWindow then
    begin
      DoNotAsk := false;
      Res := MessageWin.Execute(Format(Messages.Strings[msgDeleteMovie],
        [Movie.GetFieldValue(fieldNumber), Movie.GetFormattedTitle]),
        mtConfirmation, DoNotAsk, Messages.Strings[msgDoNotConfirm], Buttons);
      if (not ShowAllButtons) and (Res = 2) then
        Res := 3;
      case Res of
        1:
          begin
            Settings.rOptions.rMovieList.ConfirmDelete := not DoNotAsk;
            Result := 1;
          end;
        2:
          begin
            Settings.rOptions.rMovieList.ConfirmDelete := not DoNotAsk;
            Result := 2;
          end;
        3:
          begin
            Result := 3;
            Exit;
          end;
        4,0:
          begin
            Result := 4;
            Exit;
          end;
      end;
    end;
    ThumbsViewerStop;
    if (CurrentItem <> nil) and (CurrentItem.Data = Movie) then
    begin
      CurrentItem := nil;
      ClearItem;
    end;
    // Delete movie in ListView
    ListView1.Items.BeginUpdate;
    for i := 0 to Movie._listItems.Count-1 do
    begin
      Item := TElTreeItem(Movie._listItems.Items[i]);
      ItemParent := Item.Parent;
      //if Item = ListView1.ItemFocused then
      //  ListView1.ItemFocused := nil;
      Listview1.Items.Delete(Item);
      if (ItemParent <> nil) then
      begin
        if ItemParent.Count = 0  then
        begin
          if ItemParent = GroupItemEmpty then
            GroupItemEmpty := nil;
          //if ItemParent = ListView1.ItemFocused then
          //  ListView1.ItemFocused := nil;
          Listview1.Items.Delete(ItemParent)
        end else
          UpdateGroupName(ItemParent, GetGroupNameWithoutCount(ItemParent.Text));
      end;
    end;
    ListView1.Items.EndUpdate;
    // Delete movie picture file
    Movie.Picture.PictureOperation(FCatalogFile.CurrentFile, mpoDelete);
    Movie.Extras.DeletePictures(FCatalogFile.CurrentFile);
    Dec(NbMoviesVisible);
    if Movie.bChecked then
      Dec(NbMoviesChecked);
    // Delete movie in MovieList
    MovieList.Remove(Movie);
    if Result = -1 then
      Result := 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.AddGroupItem(GroupName: string) : TElTreeItem;
begin
  Result := ListView1.Items.AddChild(nil, GroupName);
  with Result do
  begin
    Data := nil;
    Tag := 0;
    Expanded := Settings.rOptions.rMovieList.GroupExpand;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.GetGroupNameWithoutCount(GroupName: string) : string;
var
  lastPosGroupName: Integer;
begin
  if Settings.rOptions.rMovieList.GroupCount then
  begin
     lastPosGroupName := LastPos(' (', GroupName) - 1;
     Result := Copy(GroupName, 1, lastPosGroupName)
  end else
    Result := GroupName;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.UpdateGroupName(GroupItem: TElTreeItem; GroupNameWithoutCount: string);
begin
  if Settings.rOptions.rMovieList.GroupCount and (GroupItem <> nil) and (GroupItem.Data = nil) then
    GroupItem.Text := Format('%s (%d)', [GroupNameWithoutCount, GroupItem.Count])
  else
    GroupItem.Text := GroupNameWithoutCount;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.RemoveMoviePicture;
begin
  with MoviePicture do
  begin
    Hint := '|' + GetLongHint(Hint);
    Picture.Assign(nil);
    Width := 0;
    Height := 0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadMoviePicture(const ForceLoad: Boolean = False);
var
  loadedPic: TGraphic;
  PicSizeDouble: Double;
begin
  RemoveMoviePicture;
  if (CurrentItem <> nil) and (ToolbarPictureWindow.Visible or ForceLoad) then
  begin
    with TMovie(CurrentItem.Data) do
    begin
      Picture.Lock;
      try
        if Picture.PicStream = nil then
        begin
          if Picture.PicPath = '' then
          begin
            if FileExists(strFileNoPicture) then
              MoviePicture.Picture.LoadFromFile(strFileNoPicture);
          end else
          begin
            if FCatalogFile.CurrentFile <> '' then
              SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
            else
              SetCurrentDir(strDirCatalogs);
            if FileExists(ExpandFileName(Picture.PicPath)) then
            begin
              MoviePicture.Picture.LoadFromFile(Picture.PicPath);
              PicSizeDouble := GetFileSize(Picture.PicPath);
              MoviePicture.Hint := Format('%s%s%s%s', [
                Format(Messages.Strings[msgPicHintLinked], [Picture.PicPath]),
                sLineBreak,
                Format(Messages.Strings[msgPicHintInfo], [PicSizeDouble]),
                MoviePicture.Hint]);
            end else
            begin
              if FileExists(strFileNotFound) then
                MoviePicture.Picture.LoadFromFile(strFileNotFound);
              MoviePicture.Hint := Format(Messages.Strings[msgFileNotExists] + MoviePicture.Hint, [Picture.PicPath]);
            end;
          end;
          // Force stretching of external pictures when window is floating (bug with JPG pictures)
          if (MoviePicture.Align = alClient) and (ToolbarPictureWindow.Floating) then
            MoviePicture.Align := alClient;
        end else
        begin
          case IndexText(Picture.PicPath, extImage) of
            extPNG:
              loadedPic := TPNGObject.Create;
            extJPG, extJPE, extJPEG:
              loadedPic := TJpegImage.Create;
            extGIF:
              loadedPic := TJvGIFImage.Create;
            extBMP:
              loadedPic := TBitmap.Create;
          else
            loadedPic := nil;
            Abort;
          end;
          PicSizeDouble := Picture.PicStream.Size;
          MoviePicture.Hint := Format('%s%s%s%s', [
            Format(Messages.Strings[msgPicHintStored], [
              typeImage[IndexText(Picture.PicPath, extImage)]
            ]),
            sLineBreak,
            Format(Messages.Strings[msgPicHintInfo], [
              PicSizeDouble
            ]),
            MoviePicture.Hint
          ]);
          Picture.PicStream.Seek(0, soFromBeginning);
          loadedPic.LoadFromStream(Picture.PicStream);
          MoviePicture.Picture.Assign(loadedPic);
          loadedPic.Free;
        end;
      except
        with MoviePicture do
        begin
          Width:=0;
          Height:=0;
        end;
      end;
      Picture.UnLock;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ImportMoviePicture(Movie: TMovie; const AFileName: TFileName;
  const ImportMethod: TPictureSelectOption);
begin
  with Movie do
  begin
    try
      Picture.ImportPicture(AFileName, FCatalogFile.CurrentFile,
        TMoviePictureImport(ImportMethod));
    except
      on e: Exception do
        MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
    end;
    FCatalogFile.Modified := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ImportMoviePictureFromStream(Movie: TMovie; Stream: TMemoryStream; DefaultExt: string;
  const ImportMethod: TPictureSelectOption);
begin
  if Stream = nil then
    Exit;
  with Movie do
  begin
    try
      Picture.ImportPictureFromStream(Stream, DefaultExt, FCatalogFile.CurrentFile,
        TMoviePictureImport(ImportMethod));
    except
      on e: Exception do
        MessageWin.Execute(Format(Messages.Strings[msgPicLoadFailed], [e.Message]), mtError, [mbOk]);
    end;
    FCatalogFile.Modified := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MovieSelected;
var
  bPic, isGroup: Boolean;
  SelCount: Integer;
begin
  SelCount := NbMoviesSelected;
  isGroup := (ListView1.ItemFocused <> nil) and (ListView1.ItemFocused.Data = nil);
  FrmMovie.AllowEdit := SelCount = 1;
  FrmMovieCustom.AllowEdit := SelCount = 1;
  if SelCount <> 1 then
  begin
    RemoveMoviePicture;
    FrmMovieExtras.CurrentMovie := nil;
  end;

  ActionMovieDelete.Enabled := (SelCount > 0);
  ActionMovieSelGroup.Enabled := isGroup;

  MnuSelect.Enabled := ListView1.Items.Count > 0;
  ActionMovieSelCheck.Enabled := MnuSelect.Enabled;
  ActionMovieSelUncheck.Enabled := MnuSelect.Enabled;

  MnuSelected.Enabled := (SelCount > 0);
  ActionMovieCheck.Enabled := MnuSelected.Enabled;
  ActionMovieUncheck.Enabled := MnuSelected.Enabled;

  ActionMovieSearch.Enabled := SelCount = 1;
  ActionMovieNumber.Enabled := SelCount = 1;
  ActionMovieUndo.Enabled := SelCount = 1;
  ActionMovieCopy.Enabled := SelCount = 1;
  ActionMoviePaste.Enabled := SelCount > 0;
  ActionPicSelect.Enabled := SelCount = 1;
  ActionPicPaste.Enabled := SelCount = 1;

  ActionURLOpen.Enabled := (SelCount = 1);
  ActionURLCopy.Enabled := (SelCount = 1);
  ActionURLExplore.Enabled := (SelCount = 1);
  ActionURLBrowse.Enabled := (SelCount = 1);

  if (SelCount = 1) then
    with SelectedItem do
    begin
      bPic := TMovie(Data).Picture.PicPath <> '';
      ActionPicDelete.Enabled := bPic;
      if FCatalogFile.CurrentFile <> '' then
        SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      bPic := bPic and ((TMovie(Data).Picture.PicStream <> nil) or FileExists(ExpandFileName(TMovie(Data).Picture.PicPath)));
      ActionPicCopy.Enabled := bPic;
      ActionPicSaveAs.Enabled := bPic;
    end
  else
  begin
    ActionPicSaveAs.Enabled := False;
    ActionPicDelete.Enabled := False;
    ActionPicCopy.Enabled := False;
  end;
  SetStatus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MakeMovieSave(Movie: TMovie; LockPicture: Boolean = True);
var
  Status: TMoviePictureStatus;
begin
  if(MovieSave = nil) then
  begin
    MovieSave := TMovie.Create(MovieList);
    if LockPicture then
      Movie.Picture.Lock;
    try
      //TODO: Add Extras ?
      // Movie extras are not saved
      MovieSave.Assign(Movie, True, True, False, True, True);
      if FCatalogFile.CurrentFile <> '' then
        SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      Status := Movie.Picture.GetPictureStatus(FCatalogFile.CurrentFile);
      if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) then
      begin // Store copied picture in memory
        if FileExists(ExpandFileName(MovieSave.Picture.PicPath)) then
        begin
          MovieSave.Picture.PicStream := TMemoryStream.Create;
          MovieSave.Picture.PicStream.LoadFromFile(MovieSave.Picture.PicPath);
          MovieSave.Picture.PicPath := '*' + MovieSave.Picture.PicPath; // '*' to distinct copied picture easier during restore
        end;
        // else
        //  MovieSave.Picture.PicPath := '';
      end;
    finally
      if LockPicture then
        Movie.Picture.UnLock;
    end;
  end
end;

{-------------------------------------------------------------------------------
  File Management
-------------------------------------------------------------------------------}

procedure TMainWindow.OnFileChange(Sender: TObject; AFileName: TFileName);
begin
  SetTitle;
  SetStatus;
  MovieSelected;
  //SaveLists; //Dont put here since there are custom fields !
  //LoadLists; //Dont put here since there are custom fields !
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnFileModified(Sender: TObject; State: Boolean);
begin
  with StatusBar1.Panels.Items[panelModified] do
    if State then
      Caption := Messages.Strings[msgUnsavedStatus]
    else
      Caption := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnNewFile(Sender: TObject; AFileName: TFileName);
begin
  ThumbsViewerStop;
  ListView1.DeselectAll;
  CurrentItem := nil;
  ClearItem;
  ListView1AfterSelectionChange(nil);

  FrmMovieCustom.Properties := nil;
  FrmMovieCustom.ClearFields;
  FrmMovieExtras.CatalogFile := FCatalogFile.CurrentFile;
  MovieList.Free;
  MovieList := TMovieList.Create;
  with Settings.rOptions.rFiles do
    if AutoLoadCF and (AutoLoadCFFile <> '') then
    begin
      SetCurrentDir(strDirCatalogs);
      if FileExists(ExpandFileName(AutoLoadCFFile)) then
        try
          if SameText(ExtractFileExt(AutoLoadCFFile), '.xml') then
            MovieList.CustomFieldsProperties.ImportFromXML(ExpandFileName(AutoLoadCFFile), True)
          else if SameText(ExtractFileExt(AutoLoadCFFile), '.amc') then
            MovieList.CustomFieldsProperties.ImportFromAMC(ExpandFileName(AutoLoadCFFile), True);
        finally
        end
      else
         MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [AutoLoadCFFile]), mtError, [mbOk]);
    end;
  FrmMovieCustom.Properties := MovieList.CustomFieldsProperties;
  FrmMovieCustom.GenerateFields;
  LoadLists; // Load drop-down lists
  FillFieldsCBFind(0);
  LoadFindField;
  FillFieldsSortBy;
  LoadSortField;
  FillFieldsGroupBy;
  LoadGroupField;
  FillFieldsGrid;
  PreGenerateHTMLTemplate;
  FCatalogFile.Modified := False;
  FCurrentVersion := 99;
  UpdateMRU(AFileName);
  RefreshMovieList(False, False); //ThumbsViewerStart; -> Done in RefreshMovieList
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnOpenFile(Sender: TObject; AFileName: TFileName);
begin
  ThumbsViewerStop;
  ListView1.DeselectAll;
  CurrentItem := nil;
  ClearItem;
  ListView1AfterSelectionChange(nil);

  try
    Application.ProcessMessages;
    with ProgressWin do
    begin
      Maximum := 2;
      Status := Format(Messages.Strings[msgLoading],[ExtractFileName(AFileName)]);
      IntProgress := 0;
      Execute(Self);
      try
        FrmMovieCustom.Properties := nil;
        FrmMovieCustom.ClearFields;
        FrmMovieExtras.CatalogFile := FCatalogFile.CurrentFile;
        MovieList.Free;

        MovieList := TMovieList.Create;
        if LowerCase(ExtractFileExt(AFileName)) = extCatalog[extXML] then
          MovieList.LoadFromXML(AFileName)
        else
          MovieList.LoadFromFile(AFileName);
        IntProgress := Maximum-1;
        FrmMovieCustom.Properties := MovieList.CustomFieldsProperties;
        FrmMovieCustom.GenerateFields;
        LoadLists; // Load drop-down lists
        FillFieldsCBFind(0);
        LoadFindField;
        FillFieldsSortBy;
        LoadSortField;
        FillFieldsGroupBy;
        LoadGroupField;
        FillFieldsGrid;
        PreGenerateHTMLTemplate;
        //ThumbsViewerStart; -> Done in RefreshMovieList
        FCatalogFile.Modified := False;
        FCurrentVersion := 99;
        UpdateMRU(AFileName);
        IntProgress := Maximum;
      finally
        Close;
      end;
    end;
  except
    on E: Exception do
    begin
      FCatalogFile.New;
      MessageWin.Execute(E.Message, mtError, [mbOk]);
    end;
  end;
  RefreshMovieList(False, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.DeleteOldCatalogCopiedPictures(AFileName: TFileName): Boolean;
var
  AList: TMovieList;
  Res, i, j: Integer;
begin
  Result := False;
  AList := nil;

  if (LowerCase(ExtractFileExt(AFileName)) <> extCatalog[extXML]) and
    (LowerCase(ExtractFileExt(AFileName)) <> extCatalog[extAMC]) then
    Exit;

  Res := MessageWin.Execute(Messages.Strings[msgCatalogExists], mtWarning, [mbYes, mbNo, mbCancel]);
  if Res = 2 then
  begin
    Result := True;
    Exit;
  end
  else if Res <> 1 then
    Exit;

  try
    Application.ProcessMessages;
    with ProgressWin do
    begin
      Maximum := 2;
      Status := Format(Messages.Strings[msgDeleteCopiedPics],[ExtractFileName(AFileName)]);
      IntProgress := 0;
      Execute(Self);
      try
        AList := TMovieList.Create;
        if LowerCase(ExtractFileExt(AFileName)) = extCatalog[extXML] then
          AList.LoadFromXML(AFileName, False)
        else
          AList.LoadFromFile(AFileName, False, False);
        IntProgress := Maximum-1;
        with AList do
          for i := 0 to Count-1 do
          begin
            with AList.Items[i] do
            begin
              Picture.PictureOperation(AFileName, mpoDeleteIfCopied);
              for j := 0 to Extras.Count-1 do
                Extras.Items[j].Picture.PictureOperation(AFileName, mpoDeleteIfCopied);
            end;
          end;
        IntProgress := Maximum;
        AList.Free;
        Result := True;
      finally
        Close;
      end;
    end;
  except
    on E: Exception do
    begin
      AList.Free;
      MessageWin.Execute(E.Message, mtError, [mbOk]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnBeforeSaveFile(Sender: TObject; OldFileName: TFileName;
  NewFileName: TFileName; var Result: Boolean);
var
  ResXML, SaveFormat: Integer;
  Cancel, InPicDir: Boolean;
begin
  Result := False;
  SaveCurrentItem; // To be sure that the current item is also saved

  SaveFormat := -1;
  Cancel := False;
  ResXML := 2;
  InPicDir := Settings.rOptions.rExport.PicturesSaveXMLInPicDir;

  with FCatalogFile.SaveDialog do
    case FilterIndex of
      DialogCatalogSaveFilterAMC:
        SaveFormat := extAMC;
      DialogCatalogSaveFilterAMC41:
      begin
        SaveFormat := extAMC;
        if MovieList.HasExtras then
        begin
          case MessageWin.Execute(Messages.Strings[msgSaveAMC41Warning],
            mtConfirmation, [mbYes, mbNo, mbCancel]) of
            1: FCurrentVersion := 41;
            2: FCurrentVersion := 99;
            else Cancel := True;
          end;
        end else
          FCurrentVersion := 41;
      end;
      DialogCatalogSaveFilterAMC35:
      begin
        SaveFormat := extAMC;
        if (MovieList.CustomFieldsProperties.Count > 0) or MovieList.HasExtras then
        begin
          case MessageWin.Execute(Messages.Strings[msgSaveAMC35Warning],
            mtConfirmation, [mbYes, mbNo, mbCancel]) of
            1: FCurrentVersion := 35;
            2: FCurrentVersion := 99;
            else Cancel := True;
          end;
        end else
          FCurrentVersion := 35;
      end;
      DialogCatalogSaveFilterXML:
      begin
        SaveFormat := extXML;
        if MovieList.HasImages(True, False, False) then
          ResXML := MessageWin.Execute(InsertLineBreaks(Messages.Strings[msgXmlConvertImages]),
            mtConfirmation, InPicDir, Messages.Strings[msgSaveInPicDir], [mbOk, mbIgnore, mbCancel]);
        if (ResXML in [0, 3]) then
          Cancel := True
        else if ResXML = 1 then
          Settings.rOptions.rExport.PicturesSaveXMLInPicDir := InPicDir;
      end;
      else Cancel := True;
    end;

  if not Cancel then
    if (not SameFileName(OldFileName, NewFileName)) and FileExists(NewFileName) then
      if not DeleteOldCatalogCopiedPictures(NewFileName) then
        Cancel := True;

  if not Cancel then
    with ProgressWin do
    begin
      Application.ProcessMessages;
      Maximum := 2;
      Status := Format(Messages.Strings[msgSaving],[ExtractFileName(NewFileName)]);
      IntProgress := 0;
      Execute(Self);
      try
        try
          StopThumbThread;
          FrmMovieExtras.StopThumbThread;
          MovieList.Sort(fieldNumber);
          FrmMovieCustom.SaveFieldsProperties;
          DeleteFile(ChangeFileExt(NewFileName,'.bak'));
          RenameFile(NewFileName, ChangeFileExt(NewFileName,'.bak'));
          case SaveFormat of
            extAMC: MovieList.SaveToFile(OldFileName, NewFileName, FCurrentVersion);
            extXML:
              if ResXML = 1 then
                if InPicDir then
                  MovieList.SaveToXML(OldFileName, NewFileName, FCurrentVersion, False, mpoCopyInPicDirIfStored)
                else
                  MovieList.SaveToXML(OldFileName, NewFileName, FCurrentVersion, False, mpoCopyInCatDirIfStored)
              else
                MovieList.SaveToXML(OldFileName, NewFileName, FCurrentVersion, False);
          end;
          UpdateMRU(NewFileName);
          if not Settings.rOptions.rFiles.Backup then
          begin
            DeleteFile(ChangeFileExt(NewFileName,'.bak'));
          end;
          //ThumbsViewerStart; --> Done in OnSaveFile
          //FrmMovieExtras.ThumbsViewerStart; --> Done in OnSaveFile on ListView1AfterSelectionChange

          Result := True;
          IntProgress := Maximum;
        finally
          Close;
        end;
        Application.ProcessMessages;
      except
        on E: Exception do
          MessageWin.Execute(E.Message, mtError, [mbOk]);
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnSaveFile(Sender: TObject; AFileName: TFileName);
begin
  FrmMovieExtras.CatalogFile := FCatalogFile.CurrentFile;
  ThumbsViewerStart;
  ListView1AfterSelectionChange(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnDialogTypeChange(Sender: TObject);
var
  NewName, NewExt: string;
begin
  if Sender is TSaveDialog then
    with Sender as TSaveDialog do
    begin
      if not DirectoryExists(FileName) then
      begin
        case FilterIndex of
          DialogCatalogSaveFilterAMC, DialogCatalogSaveFilterAMC41, DialogCatalogSaveFilterAMC35:
            begin
              NewName := ChangeFileExt(ExtractFileName(FileName), extCatalog[extAMC]);
              NewExt := extCatalog[extAMC];
            end;
          DialogCatalogSaveFilterXML:
            begin
              NewName := ChangeFileExt(ExtractFileName(FileName), extCatalog[extXML]);
              NewExt := extCatalog[extXML];
            end;
        end;
        Delete(NewExt, 1, 1);
        SendMessage(Windows.GetParent(Handle), CDM_SETCONTROLTEXT, 1152, Integer(PChar(NewName)));
        SendMessage(Windows.GetParent(Handle), CDM_SETDEFEXT, 1152, Integer(PChar(NewExt)));
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetSaveFilter;
var
  ext: string;
begin
  if FCatalogFile.CurrentFile <> '' then
    ext := ExtractFileExt(FCatalogFile.CurrentFile)
  else
    ext := extCatalog[extAMC];
  if ext = extCatalog[extAMC] then
    if FCurrentVersion = 35 then
      FCatalogFile.SaveDialog.FilterIndex := DialogCatalogSaveFilterAMC35
    else if FCurrentVersion = 41 then
      FCatalogFile.SaveDialog.FilterIndex := DialogCatalogSaveFilterAMC41
    else
      FCatalogFile.SaveDialog.FilterIndex := DialogCatalogSaveFilterAMC
  else
  if ext = extCatalog[extXML] then
    FCatalogFile.SaveDialog.FilterIndex := DialogCatalogSaveFilterXML;
  Delete(ext, 1, 1);
  with FCatalogFile.SaveDialog do
  begin
    DefaultExt := ext;
    InitialDir := Settings.rOptions.rFolders[fuCatalogs].Value;
    if InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetTitle;
var
  FileName: string;
begin
  if FCatalogFile.CurrentFile = '' then
    FileName := '<untitled>'
  else
    FileName := FCatalogFile.CurrentFile;
  Caption := Format(strDefaultCaption,[strVersion, FileName]);
  {$IFDEF DISABLETHEMES}
  Caption := Format('%s [themes support disabled]', [Caption]);
  {$ENDIF}
  {$IFDEF ANTDEBUG}
  Caption := Format('%s [BETA/DEBUG]', [Caption]);
  {$ENDIF}
  Application.Title := Format(strDefaultTask, [ExtractFileName(FileName)]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetStatus;
var
  MoviesCount: Integer;
begin
  if MovieList <> nil then
    MoviesCount := MovieList.Count
  else
    MoviesCount := 0;
  with StatusBar1.Panels.Items[panelCount] do
  begin
    Caption := Format(Messages.Strings[msgStatusCount], [MoviesCount]) + ' ' +
      Format(Messages.Strings[msgStatusVisible], [NbMoviesSelected, NbMoviesChecked, NbMoviesVisible]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.UpdateMRU(const strFilePath: string);
begin
  if strFilePath <> '' then
    TBMRUList1.Add(strFilePath);
  ActionFileOpenNoRecent.Visible := TBMRUList1.Items.Count = 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.TBMRUList1Click(Sender: TObject;
  const Filename: String);
begin
  if FileExists(FileName) then
    FCatalogFile.Open(FileName)
  else
    MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [FileName]), mtError, [mbOk]);
end;

{-------------------------------------------------------------------------------
   Misc.
-------------------------------------------------------------------------------}

procedure TMainWindow.RefreshMovieList(const KeepSelection,SaveColumnSettingsCF: Boolean);
var
  i, k: Integer;
  GroupItem, GroupItemUnique, Item: TElTreeItem;
  MovieFilter: TMovieFilter;
  VarMovieParser: TExprVarMovieParser;
  GroupFormat: TGroupFormat;
  GridMode, ItemInList: Boolean;
  GroupUnique, GroupCount, GroupExpand: Boolean;

  Groups : TStringList;
  GroupMovies: TObjectList;
  GroupName: string;
  iGroup, iMovie: Integer;
  Movie: TMovie;
  Prop: TCustomFieldProperties;

  // Args: IN [GroupName] OUT [GroupItem]
  procedure AddGroupI;
  begin
    GroupItem := ListView1.Items.AddChild(nil, GroupName);
    with GroupItem do
    begin
      Data := nil;
      Tag := 0;
      Expanded := GroupExpand;
    end;
  end;

  // Args: IN [GroupItem]
  procedure AddGroupCount;
  begin
    if GroupCount and (GroupItem <> nil) and (GroupItem <> GroupItemUnique) then
      GroupItem.Text := Format('%s (%d)', [GroupItem.Text, GroupItem.Count]);
  end;

begin
  if MovieList = nil then
    Exit;
  TimerAfterSelect.Enabled := False;
  ThumbsViewerStop;
  if KeepSelection then
    StoreSelectedState;
  ListView1.DeselectAll;
  ListView1AfterSelectionChange(nil);
  try
    with Settings.rOptions do
    begin
      GroupUnique := rMovieList.GroupUnique;
      GroupCount := rMovieList.GroupCount;
      GroupExpand := rMovieList.GroupExpand;
    end;
    GroupItem := nil;
    GroupItemUnique := nil;
    MovieFilter := nil;
    VarMovieParser := nil;
    GroupFormat := nil;
    NbMoviesChecked := 0;
    NbMoviesVisible := 0;
    GroupItemEmpty := nil;
    if ActionFindDisplay.Checked then
    begin
      MovieFilter := TMovieFilter.Create;
      MovieFilter.Value := EValue.Text;
      MovieFilter.Field := Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1;
      MovieFilter.WholeField := ActionFindWholefield.Checked;
      MovieFilter.Reverse := ActionFindReverse.Checked;
      MovieFilter.SearchExpression := nil;
      if MovieFilter.Field = customFieldMax + 1 then
      begin
        VarMovieParser := TExprVarMovieParser.Create(MovieList);
        MovieFilter.SearchExpression := TExpression.Create(EValue.Text, VarMovieParser);
      end;
    end;

    with Settings.rMain do
    if GroupsFormatOption > 0 then
    begin
      GroupFormat := TGroupFormat.Create;
      GroupFormat.option := TGroupFormatOption(GroupsFormatOption);
      GroupFormat.roundType := TRoundType(GroupsFormatRoundType);
    end;

    GridMode := ActionToolsGrid.Checked;

    with ListView1 do
    begin
      Items.BeginUpdate;
      try
        Items.Clear;

        // *** Building headers ***
        SaveColumnSettings(SaveColumnSettingsCF);
        with HeaderSections do
        begin
          i := Count-1;
          while i > 1 do
          begin
            DeleteSection(Item[i]);
            Dec(i);
          end;

          if GridMode then
          begin
            ListView1.OnCompareItems := ListView1CompareItems;
            Item[0].Visible := False;
            Item[1].Visible := False;
            with AddSection do
            begin
              Text := strFields.Strings[fieldNumber];
              FieldName := IntToStr(fieldNumber);
              FieldType := sftCustom;//sftNumber;
              Alignment := hsaRight;
            end;
            with AddSection do
            begin
              Text := strFields.Strings[fieldFormattedTitle];
              FieldName := IntToStr(fieldFormattedTitle);
              FieldType := sftCustom;//sftText;
            end;
            for i := 0 to fieldCount-1 do
            begin
              if not (i in [fieldNumber, fieldFormattedTitle]) then
              begin
                with AddSection do
                begin
                  Text := strFields.Strings[i];
                  FieldName := IntToStr(i);
                  case GetFieldType(i) of
                    ftInteger:
                      begin
                        FieldType := sftCustom;//sftNumber;
                        Alignment := hsaRight;
                      end;
                    ftReal, ftReal1, ftReal2:
                      begin
                        FieldType := sftCustom;//sftFloating;
                        Alignment := hsaRight;
                      end;
                    ftDate:
                      begin
                        FieldType := sftCustom;//sftDate;
                      end;
                  else
                    FieldType := sftCustom;//sftText;
                  end;
                end;
              end;
            end;
            with MovieList.CustomFieldsProperties do
              for i := 0 to Count-1 do
              begin
                Prop := Objects[i];
                with AddSection do
                begin
                  Text := Prop.FieldName;
                  FieldName := IntToStr(customFieldLow + i);
                  case Prop.FieldType of
                    ftInteger:
                      begin
                        FieldType := sftCustom;//sftNumber;
                        Alignment := hsaRight;
                      end;
                    ftReal, ftReal1, ftReal2:
                      begin
                        FieldType := sftCustom;//sftFloating;
                        Alignment := hsaRight;
                      end;
                    ftDate:
                      begin
                        FieldType := sftCustom;//sftDate;
                      end;
                  else
                    FieldType := sftCustom;//sftText;
                  end;
                end;
              end;
            MainTreeColumn := 3;
            HideHorzScrollBar := False;
            MoveColumnOnDrag := True;
            DraggableSections := True;
            // Set column order, visible and grid fields menu (checked or not)
            RestoreColumnSettings;
          end else
          begin
            ListView1.OnCompareItems := ListView1CompareItems;
            with HeaderSections do
            with AddSection do
            begin
              Text := 'Invisible';
              FieldType := sftCustom;
              Visible := False;
            end;
            Item[0].Visible := Settings.rOptions.rMovieList.MovieNumColumn;
            Item[0].FieldName  := IntToStr(fieldNumber);
            Item[1].Visible := True;
            Item[1].FieldName  := IntToStr(fieldFormattedTitle);
            MainTreeColumn := 1;
            HideHorzScrollBar := True;
            MoveColumnOnDrag := False;
            DraggableSections := False;
            // Just set grid fields menu (checked or not) and size of first "number" column
            RestoreColumnSettings;
          end; // if gridmode
          SetSortField(Abs(FSortField) - 1, FSortField < 0, False); // Update header columns
        end; // with headers

        // *** Filling the list ***
        if (MovieList <> nil) then
        begin
          // *** Remove all associated items for a movie ***
          for k := 0 to MovieList.Count-1 do
            MovieList.Items[k]._listItems.Clear;

          // *** Group movies by selected field ***
          Groups := MovieList.GetMoviesByGroups(FGroupField, mioAll, MovieFilter, GroupFormat);

          // *** For all groups ***
          for iGroup := 0 to Groups.Count-1 do
          begin
            AddGroupCount;
            GroupName := Groups.Strings[iGroup];
            GroupMovies := TObjectList(Groups.Objects[iGroup]);

            // ** If group wanted ***
            if FGroupField <> GroupNoneField then
              if GroupUnique and (GroupMovies.Count = 1) and
                (GroupName <> '$$$EMPTY$$$') and
                (GroupName <> strErrorParenthesis) then
                if GroupItemUnique = nil then
                begin
                  GroupName := Messages.Strings[msgGroupUnique];
                  AddGroupI;
                  GroupItemUnique := GroupItem;
                end else
                  GroupItem := GroupItemUnique
              else if GroupName = '$$$EMPTY$$$' then
              begin
                GroupName := Messages.Strings[msgGroupEmpty];
                AddGroupI;
                GroupItemEmpty := GroupItem; // We keep group empty for next add !
              end
              else
                AddGroupI;

            // *** For all movies in group ***
            for iMovie := 0 to GroupMovies.Count-1 do
            begin
              Movie := TMovie(GroupMovies.Items[iMovie]);
              with Movie do
              begin
                // *** Check if movie is already in group ***
                ItemInList := False;
                for k := 0 to Movie._listItems.Count-1 do
                begin
                  Item := TElTreeItem(Movie._listItems.Items[k]);
                  if Item.Parent = GroupItem then
                  begin
                    ItemInList := True;
                    break;
                  end;
                end;
                // *** If movie is not already in group ***
                if not ItemInList then
                begin
                  AddItem(Movie, GroupItem);
                end; // Check if movie is already in group !
              end; // with Movie
            end; // if movie is not already in group
          end; // for all groups
          AddGroupCount; // add last group count
          GroupItem := GroupItemUnique;
          GroupItemUnique := nil;
          AddGroupCount; // add group count for unique group
          FreeObjects(Groups);
          Groups.Free;
        end; // if movielist <> nil
      finally
      end;
    end;
    if MovieFilter <> nil then
      MovieFilter.SearchExpression.Free;
    VarMovieParser.Free;
    MovieFilter.Free;
    GroupFormat.Free;
    SetStatus;
  finally
    ListView1Resize(Self);
    ListView1.Items.EndUpdate;
    if KeepSelection then
      LoadSelectedState;
    ListView1EnsureVisiblePlus;
    ThumbsViewerStart;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveColumnSettings(const SaveCustomFields: Boolean);
var
  i, idx, Field, posError : Integer;
  s, s2, tmp, newValue : string;
  Section : TElHeaderSection;
  Prop : TCustomFieldProperties;
begin
  if MovieList = nil then
    Exit;
  if (ListView1.HeaderSections.Item[1].Visible) then // in ListMode
  begin
    if SaveCustomFields then
    begin
      // Movie fields
      if Settings.rMain.ColumnSettings = '' then
      begin
        Settings.rMain.ColumnSettings := 'i0:w' + IntToStr(ListView1.HeaderSections.Item[0].Width) + ':vf,' +
          'i1:w' + IntToStr(ListView1.HeaderSections.Item[1].Width) + ':vf,';
        for i := 0 to fieldCount-1 do
          Settings.rMain.ColumnSettings := Settings.rMain.ColumnSettings + 'i' + IntToStr((i+2))+ ':w120:vt,';
      end;
      newValue := Settings.rMain.ColumnSettings;
      s2 := '';
      with ListView1 do
      with HeaderSections do
        while newValue <> '' do
        begin
          s := copy(newValue, 2, pos(':', newValue) - 2);
          delete(newValue, 1, pos(':', newValue));
          idx := StrToInt(s);
          s2 := s2 + 'i' + s + ':';
          s := copy(newValue, 2, pos(':', newValue) - 2);
          delete(newValue, 1, pos(':', newValue));
          if idx >= 2 then // Columns in GridMode
            s2 := s2 + 'w' + s + ':'
          else
            s2 := s2 + 'w' + IntToStr(Item[idx].Width) + ':';
          delete(newValue, 1, 3);
          if idx >= 2 then // Columns in GridMode
          begin
            idx := idx - 2;
            if idx = 1 then
              idx := fieldFormattedTitle
            else if (idx <> 0) and (idx <= fieldFormattedTitle) then
              Dec(idx);
            if (idx < MnuTlsGrf.Count) and (not MnuTlsGrf.Items[idx].Checked) then
              s2 := s2 + 'vf,'
            else
              s2 := s2 + 'vt,';
          end else
            s2 := s2 + 'vf,';
        end;
      Settings.rMain.ColumnSettings := s2;

      // Custom fields
      with MovieList.CustomFieldsProperties do
        if ColumnSettings = '' then
          for i := 0 to Count-1 do
            ColumnSettings := ColumnSettings + Strings[i] + ':'+'p'+IntToStr(fieldCount+2) + ':w120:vt,';
      posError := 0;
      newValue := MovieList.CustomFieldsProperties.ColumnSettings;
      s2 := '';
      while newValue <> '' do
      begin
        s := copy(newValue, 1, pos(':', newValue) - 1);
        delete(newValue, 1, pos(':', newValue));
        idx := MovieList.CustomFieldsProperties.IndexOf(s);
        if idx = -1 then
        begin
          inc(posError);
          delete(newValue, 1, pos(',', newValue));
        end
        else
        begin
          s2 := s2 + s + ':';
          s := copy(newValue, 2, pos(':', newValue) - 2);
          delete(newValue, 1, pos(':', newValue));
          i := StrToInt(s) - posError;
          s2 := s2 + 'p' + IntToStr(i) + ':';
          s := copy(newValue, 2, pos(':', newValue) - 2);
          delete(newValue, 1, pos(':', newValue));
          s2 := s2 + 'w' + s + ':';
          delete(newValue, 1, 3);
          if ((fieldCount+idx) < MnuTlsGrf.Count) and (not MnuTlsGrf.Items[fieldCount+idx].Checked) then
            s2 := s2 + 'vf,'
          else
            s2 := s2 + 'vt,';
        end;
      end;
      if MovieList.CustomFieldsProperties.ColumnSettings <> s2 then
      begin
        MovieList.CustomFieldsProperties.ColumnSettings := s2;
        FCatalogFile.Modified := True;
      end;
    end;
  end else  // in GridMode
  begin
    s := '';
    s2 := '';
    with ListView1 do
    with HeaderSections do
      for i := 0 to Count-1 do
      begin
        Section := ItemByPos[i];
        Field := StrToIntDef(Section.FieldName, 0);
        if Field < fieldCount then
        begin
          tmp := 'i' + IntToStr(Section.Index) + ':w' + IntToStr(Section.Width) + ':v';
          if Section.Visible then
            tmp := tmp + 't,'
          else
            tmp := tmp + 'f,';
          s := s + tmp;
        end else if SaveCustomFields and (Field >= customFieldLow) and
          (Field - customFieldLow < MovieList.CustomFieldsProperties.Count) then
        begin
          Prop := MovieList.CustomFieldsProperties.Objects[Field - customFieldLow];
          tmp := Prop.FieldTag + ':p' + IntToStr(i) + ':w' + IntToStr(Section.Width) + ':v';
          if Section.Visible then
            tmp := tmp + 't,'
          else
            tmp := tmp + 'f,';
          s2 := s2 + tmp;
        end;
       end;
      Settings.rMain.ColumnSettings := s;
      if SaveCustomFields then
      begin
        if MovieList.CustomFieldsProperties.ColumnSettings <> s2 then
        begin
          MovieList.CustomFieldsProperties.ColumnSettings := s2;
          FCatalogFile.Modified := True;
        end;
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.RestoreColumnSettings;
var
  i, idx, posError : integer;
  Section : TElHeaderSection;
  newValue, s : string;
  GridMode : Boolean;
begin
  if MovieList = nil then
    Exit;
  GridMode := not ListView1.HeaderSections.Item[1].Visible;
  // Set grid fields visible by default (menu)
  with MnuTlsGrf do
    for i := 0 to Count-1 do
      MnuTlsGrf.Items[i].Checked := True;
    MnuTlsGrf.Items[fieldFormattedTitle].Enabled := False;

  i := 0;
  newValue := Settings.rMain.ColumnSettings;
  with ListView1 do
  with HeaderSections do
    while newValue <> '' do
    begin
      Section := nil;
      s := copy(newValue, 2, pos(':', newValue) - 2);
      delete(newValue, 1, pos(':', newValue));
      idx := StrToInt(s);
      if GridMode then Section := Item[idx];
      if GridMode then MoveSection(Section, i);
      s := copy(newValue, 2, pos(':', newValue) - 2);
      delete(newValue, 1, pos(':', newValue));
      if GridMode then Section.Width := StrToInt(s);
      if idx >= 2 then // Columns in GridMode
      begin
        if (pos('vf,', newValue) = 1) and (idx <> 3) {FormattedTitle / MainColumn} then
        begin
          if GridMode then Section.Visible := False;
          idx := idx - 2; // idx >= 2 (first if)
          if idx = 1 then
            idx := fieldFormattedTitle
          else if (idx <> 0) and (idx <= fieldFormattedTitle) then
            Dec(idx);
          if idx < MnuTlsGrf.Count then
            MnuTlsGrf.Items[idx].Checked := False;
        end
        else
          if GridMode then Section.Visible := True;
      end
      else if idx = 0 then // set size of first number column
        Item[idx].Width := StrToInt(s);
      delete(newValue, 1, 3);
      inc(i);
    end;

  posError := 0;
  newValue := MovieList.CustomFieldsProperties.ColumnSettings;
  with ListView1 do
  with HeaderSections do
    while newValue <> '' do
    begin
      Section := nil;
      s := copy(newValue, 1, pos(':', newValue) - 1);
      delete(newValue, 1, pos(':', newValue));
      idx := MovieList.CustomFieldsProperties.IndexOf(s);
      if idx = -1 then
      begin
        inc(posError);
        delete(newValue, 1, pos(',', newValue));
      end
      else
      begin
        if GridMode then Section := Item[fieldCount + 2 + idx];
        //if StrToInt(Section.FieldName) <> (idx + customFieldLow) then
        //  showmessage('Error: FieldName='+Section.FieldName+'|Value='+ IntToStr(idx + customFieldLow));
        s := copy(newValue, 2, pos(':', newValue) - 2);
        delete(newValue, 1, pos(':', newValue));
        i := StrToInt(s) - posError;
        if GridMode then MoveSection(Section, i);
        s := copy(newValue, 2, pos(':', newValue) - 2);
        delete(newValue, 1, pos(':', newValue));
        if GridMode then Section.Width := StrToInt(s);
        if (pos('vf,', newValue) = 1) then
        begin
          if GridMode then Section.Visible := False;
          if (fieldCount+idx) < MnuTlsGrf.Count then
            MnuTlsGrf.Items[fieldCount+idx].Checked := False;
        end
        else
          if GridMode then Section.Visible := True;
        delete(newValue, 1, 3);
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetSortField(Field: Integer; Descend: Boolean; SortList: Boolean);
var
  i: Integer;
  section: TElHeaderSection;
begin
  if not ( (Field = SortAdvancedField) or (Field in SortByFields) or
           ((MovieList <> nil) and (Field >= customFieldLow) and
            (Field - customFieldLow < MovieList.CustomFieldsProperties.Count)) ) then
    Field := fieldNumber;
  FSortField := Field + 1;
  if Descend then
   FSortField := FSortField * -1;

  if Descend then
    MnuTlsSortDescend.Checked := True
  else
    MnuTlsSortAscend.Checked := True;

  with MnuTlsSort do
    for i := 3 to Count-1 do
      with Items[i] do
        if (Tag = Field) then
        begin
          Checked := True;
          Break;
        end;

  section := nil;
  with ListView1 do
  with HeaderSections do
  begin
    if ActionToolsGrid.Checked then
    begin
      if Field = SortAdvancedField then
        section := Item[1] // Invisible column used for advanced sort
      else
        for i:=2 to Count-1 do
          if StrToInt(Item[i].FieldName) = Field then
          begin
            section := Item[i];
            break;
          end;
    end else if (HeaderSections.Count > 0) then
    begin
      if Field = fieldNumber then
        section := Item[0]
      else if Field = fieldFormattedTitle then
        section := Item[1]
      else
        section := Item[2]; // Invisible column used for other sorts
    end;

    if section <> nil then
    begin
      ListView1.SortSection := section.Index;
      if Descend then
        Item[SortSection].SortMode := hsmDescend
      else
        Item[SortSection].SortMode := hsmAscend;
      if SortList then
        ListView1.Sort(True);
    end;
  end;
  ListView1EnsureVisiblePlus;
  ThumbsViewerStart;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetGroupField(Field: Integer);
var
  i: Integer;
begin
  if not ( (Field in GroupByFields) or (Field in GroupByExtraFields) or
           ((MovieList <> nil) and (Field >= customFieldLow) and
            (Field - customFieldLow < MovieList.CustomFieldsProperties.Count)) ) then
    Field := GroupNoneField;
  FGroupField := Field;

  if FGroupField = GroupNoneField then
    MnuTlsGrpNon.Checked := True
  else
  begin
    with MnuTlsGrp do
      for i := 2 to Count-1 do
        with Items[i] do
          if (Tag = Field) then
          begin
            Checked := True;
            Break;
          end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.StoreSelectedState;
var
//  DefCheck: Boolean;
  i: Integer;
//  PrevItem: TElTreeItem;
begin
  if MovieList <> nil then
    with MovieList do
      for i := 0 to Count-1 do
        with Items[i] do
        begin
          _bSelected := False;
          _bVisible := False;
          _selectedGroup := '';
        end;
  with ListView1 do
    for i := 0 to Items.Count-1 do
      if (Items[i].Data <> nil) then
        with TMovie(Items[i].Data) do
        begin
          _bVisible := True;
          if Items[i].Selected and (not _bSelected) and (Items[i] = _selectedItem) then
          begin
            _bSelected := True;
            if Items[i].Parent <> nil then
              _selectedGroup := GetGroupNameWithoutCount(Items[i].Parent.Text);
          end;
        end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadSelectedState;
var
  i: Integer;
begin
  if MovieList <> nil then
    with MovieList do
      for i := 0 to Count-1 do
        with Items[i] do
        begin
          _selectedItem := nil;
        end;
  with ListView1 do
  begin
    Items.BeginUpdate;
    DeselectAll;
    for i := 0 to Items.Count-1 do
      if Items[i].Data <> nil then
        with TMovie(Items[i].Data) do
        begin
          if _bSelected and ((_selectedItem = nil) or
            ((Items[i].Parent <> nil) and
            (AnsiCompareText(GetGroupNameWithoutCount(Items[i].Parent.Text), _selectedGroup) = 0))) then
          begin
            if(_selectedItem <> nil) then
            begin
              TElTreeItem(_selectedItem).Selected := False;
              if (TElTreeItem(_selectedItem).Parent <> nil) and
                (not Settings.rOptions.rMovieList.GroupExpand) then
                TElTreeItem(_selectedItem).Parent.Expanded := False;
            end;
            _selectedItem := Items[i];
            if SelectedCount = 0 then
              ItemFocused := Items[i]
            else
              Items[i].Selected := True;
            if (TElTreeItem(_selectedItem).Parent <> nil) then
              Items[i].Parent.Expanded := True;
          end;
        end;
    Items.EndUpdate;
  end;
  ListView1AfterSelectionChange(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadLists;
  procedure LoadList(const ACombo: TComboBox; ddlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[ddlIndex] do
    begin
      if UseCatalogValues then
      begin
        if MovieList <> nil then
          MovieList.GetValues(ACombo.Items, strFieldsDdl[ddlIndex])
        else
          ACombo.Items.Clear;
      end else
        ACombo.Items.Assign(Contents);
      ACombo.Sorted := Sort;
      ACombo.AutoComplete := AutoComplete;
    end;
  end;
begin
  with FrmMovie do
  begin
    LoadList(ECountry, ddlCountry);
    LoadList(ECategory, ddlCategory);
    LoadList(ECertification, ddlCertification);
    LoadList(EVideoFormat, ddlVideo);
    LoadList(EAudioFormat, ddlAudio);
    LoadList(ELanguages, ddlLanguages);
    LoadList(ESubtitles, ddlSubtitles);
    LoadList(EBorrower, ddlBorrowers);
    LoadList(EFramerate, ddlFramerate);
    LoadList(EMediaType, ddlMediaType);
    LoadList(ESource, ddlSources);
  end;
  if MovieList <> nil then
    FrmMovieCustom.LoadLists;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadOptions;
var
  ButtonName: string;
  TheButton: TTBCustomItem;
  i: Integer;
begin
  ToolbarFind.Floating := True;
  //TBCustomLoadPositions(Application, XmlReadInt, XmlReadString, Settings.rMain.Toolbars);
  TBCustomLoadPositionsAllComponents(Self, XmlReadInt, XmlReadString, Settings.rMain.Toolbars);

  // Fix DPI problem on ToolbarFind
  ToolbarFind.MaxClientHeight := Trunc(53 * Self.PixelsPerInch / 96 + (Self.PixelsPerInch - 96) * 0.15);
  ToolbarFind.MinClientHeight := ToolbarFind.MaxClientHeight;
  ToolbarFind.MinClientWidth := Trunc(751 * Self.PixelsPerInch / 96 + (Self.PixelsPerInch - 96) * 1.3);
  ToolbarFind.ClientAreaHeight := ToolbarFind.MinClientHeight;
  if ToolbarFind.ClientAreaWidth < ToolbarFind.MinClientWidth then
    ToolbarFind.ClientAreaWidth := ToolbarFind.MinClientWidth;

  try
    if Settings.rMain.Toolbars.Items.ItemNamed[ToolbarMain.Name] <> nil then
      with Settings.rMain.Toolbars.Items.ItemNamed[ToolbarMain.Name].Items do
        for i := 0 to Count-1 do
        begin
          ButtonName := Item[i].Properties.Value('Name');
          if ButtonName <> '' then
          begin
            TheButton := TTBCustomItem(Self.FindComponent(ButtonName));
            if TheButton <> nil then
              TheButton.Visible := Item[i].Properties.BoolValue('Visible', TheButton.Visible);
          end;
        end;
  except
  end;
  ActionDisplayMainToolbar.Checked := ToolbarMain.Visible;
  ActionDisplayPictureToolbar.Checked := ToolbarPicture.Visible;
  ActionDisplayExtrasToolbar.Checked := FrmMovieExtras.ToolbarExtras.Visible;
  with Settings do
  begin
    case rMain.WindowState of
      0:
        begin
          WindowState := wsMinimized;
        end;
      1:
        begin
          WindowState := wsNormal;
          Width := rMain.WindowWidth;
          Height := rMain.WindowHeight;
          Left := rMain.WindowLeft;
          Top := rMain.WindowTop;
        end;
      2:
        begin
          WindowState := wsMaximized;
        end;
      else
        WindowState := wsNormal;
    end;

    with rMain do
    begin
      ActionDisplayStatusBar.Checked := Statusbar;
      ActionDisplayStatusBarExecute(Self);
      PanelLeft.Width := ListWidth;
      if MovieInfosBothWidth < Panel1FrmBoth.Constraints.MinWidth then
        Panel1FrmBoth.Width := Panel1FrmBoth.Constraints.MinWidth
      else
        Panel1FrmBoth.Width := MovieInfosBothWidth;
      if (MovieInfosTabIndex < 0) or (MovieInfosTabIndex > 3) then
        TabMovieInfos.TabIndex := 0
      else
        TabMovieInfos.TabIndex := MovieInfosTabIndex;
      TabMovieInfosChange(nil);
      if MovieInfosHideMediaFields then
        FrmMovie.ImgCollapse1Click(Self);
      if MovieInfosHideVideoFields then
        FrmMovie.ImgCollapse2Click(Self);
      ToolbarPictureWindow.Height := 32; // Force Resize (Display Bug)
      ToolbarPictureWindow.Height := PictureDockedHeight;
      ToolbarExtrasWindow.Width := 32; // Force Resize (Display Bug)
      ToolbarExtrasWindow.Width := ExtrasDockedWidth;
      TBMRUList1.Items.Assign(MRU);
      UpdateMRU('');

      // Do not load here to keep custom field sort/group/find
      // Just called here to init default value ;)
      LoadSortField;
      LoadGroupField;
      LoadGroupsFormat;
      LoadFindField;
      ActionFindWholefield.Checked := FindWholeField;
      ActionFindReverse.Checked := FindReverse;

      ThumbsSizer.Position := ThumbnailsSize;
      ThumbsDisplayTitle.Checked := ThumbnailsDisplayTitle;

      FrmMovieExtras.ThumbsSizer.Position := ExtrasThumbsSize;
      FrmMovieExtras.ThumbsDisplayTitle.Checked := ExtrasThumbsDisplayTitle;
      FrmMovieExtras.ThumbsDisplayInfo.Checked := ExtrasThumbsDisplayInfo;

      if GridMode then
        ActionToolsGridExecute(nil);
      if ListAlClient then
        ActionStretchListExecute(nil);
      if DisplayHTML then
        ActionDisplayHTMLExecute(nil);
      if DisplayThumbnails then
        ActionDisplayThumbnailsExecute(nil);
    end;
  end; // with Settings do
  ActionMovieFind.Checked := ToolbarFind.Visible;
  ActionMoviePictureShow.Checked := ToolbarPictureWindow.Visible;
  ActionMovieExtrasShow.Checked := ToolbarExtrasWindow.Visible;
  SplitterBottomList.Visible := ToolbarPictureWindow.Visible and not ToolbarPictureWindow.Floating;
  SplitterRightExtras.Visible := ToolbarExtrasWindow.Visible and not ToolbarExtrasWindow.Floating;
  ApplyOptions;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveLists;
  procedure SaveList(const ACombo: TComboBox; ddlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[ddlIndex] do
      if (not UseCatalogValues) and (AutoAdd) and (ACombo.Items.Count > 0) then
        Contents.Assign(ACombo.Items);
  end;
begin
  if (CurrentItem <> nil) then
  begin
    UpdateLists;
    FrmMovieCustom.UpdateLists;
  end;
  with FrmMovie do
  begin
    SaveList(ECountry, ddlCountry);
    SaveList(ECategory, ddlCategory);
    SaveList(ECertification, ddlCertification);
    SaveList(EVideoFormat, ddlVideo);
    SaveList(EAudioFormat, ddlAudio);
    SaveList(ELanguages, ddlLanguages);
    SaveList(ESubtitles, ddlSubtitles);
    SaveList(EBorrower, ddlBorrowers);
    SaveList(EFramerate, ddlFramerate);
    SaveList(EMediaType, ddlMediaType);
    SaveList(ESource, ddlSources);
  end;
  FrmMovieCustom.SaveLists;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.UpdateLists;
  procedure UpdateList(const Combo: TComboBox; DdlIndex: Integer);
  begin
    with Settings.rOptions.rMovieInformation.rCombo[DdlIndex] do
      if (AutoAdd or UseCatalogValues) and (Combo.Text <> '') and (Combo.Items.IndexOf(Combo.Text) = -1) then
        Combo.Items.Add(Combo.Text);
  end;
begin
  with FrmMovie do
  begin
    UpdateList(ECountry, ddlCountry);
    UpdateList(ECategory, ddlCategory);
    UpdateList(ECertification, ddlCertification);
    UpdateList(EVideoFormat, ddlVideo);
    UpdateList(EAudioFormat, ddlAudio);
    UpdateList(ELanguages, ddlLanguages);
    UpdateList(ESubtitles, ddlSubtitles);
    UpdateList(EBorrower, ddlBorrowers);
    UpdateList(EFramerate, ddlFramerate);
    UpdateList(EMediaType, ddlMediaType);
    UpdateList(ESource, ddlSources);
  end;
  FrmMovieCustom.UpdateLists;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveOptions;
var
  i: Integer;
begin
  with Settings do
  begin
    case WindowState of
      wsMinimized:
        rMain.WindowState := 0;
      wsNormal:
        begin
          rMain.WindowState := 1;
          rMain.WindowWidth := Width;
          rMain.WindowHeight := Height;
          rMain.WindowLeft := Left;
          rMain.WindowTop := Top;
        end;
      wsMaximized:
        rMain.WindowState := 2;
    end;
    with rMain do
    begin
      Statusbar := ActionDisplayStatusBar.Checked;
      if ActionStretchList.Checked then
        ListWidth := PanelLeftOldWidth
      else
        ListWidth := PanelLeft.Width;
      MovieInfosTabIndex := TabMovieInfos.TabIndex;
      MovieInfosHideMediaFields := not FrmMovie.PanelMedia.Visible;
      MovieInfosHideVideoFields := not FrmMovie.PanelVideo.Visible;
      PictureDockedHeight := ToolbarPictureWindow.Height;
      ExtrasDockedWidth := ToolbarExtrasWindow.Width;
      MRU.Assign(TBMRUList1.Items);
      GridMode := ActionToolsGrid.Checked;
      ListAlClient := ActionStretchList.Checked;
      DisplayHTML := ActionDisplayHTML.Checked;
      DisplayThumbnails := ActionDisplayThumbnails.Checked;
      ThumbnailsSize := ThumbsSizer.Position;
      ThumbnailsDisplayTitle := ThumbsDisplayTitle.Checked;
      ExtrasThumbsSize := FrmMovieExtras.ThumbsSizer.Position;
      ExtrasThumbsDisplayTitle := FrmMovieExtras.ThumbsDisplayTitle.Checked;
      ExtrasThumbsDisplayInfo := FrmMovieExtras.ThumbsDisplayInfo.Checked;
      //SaveColumnSettings; //--> Not needed here, done before during catalog closing

      // Do not save SortField, GroupField, FindField here.
      // They have been saved before during user selection to keep custom field sort/group/find
      FindWholeField := ActionFindWholefield.Checked;
      FindReverse := ActionFindReverse.Checked;
    end;
    intVersion := intFileVersion;
    version := strVersion;

    // Save Toolbars
    Settings.rMain.Toolbars.Clear;
    //TBCustomSavePositions(Self, XmlWriteInt, XmlWriteString, Settings.rMain.Toolbars);
    TBCustomSavePositionsAllComponents(Self, XmlWriteInt, XmlWriteString, Settings.rMain.Toolbars);
    with Settings.rMain.Toolbars.Items.ItemNamed[ToolbarMain.Name].Items do
      for i := 0 to ToolbarMain.Items.Count-1 do
        with Add('Button') do
        begin
          Properties.Add('Name', ToolbarMain.Items.Items[i].Name);
          Properties.Add('Visible', ToolbarMain.Items.Items[i].Visible);
        end;

    // Save drop-down lists
    // SaveLists; --> Not needed here, done before during catalog closing

    // Write to file
    Save;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ApplyOptions;
var
  bState:  Boolean;
  tb_color, tb_grey: TBitmap;
  ToolbarColorType: Integer;
  s: string;
  ClassicIconTheme: Boolean;
  procedure SetToolbarImages(const AImageList: TCustomImageList);
  begin
    if Settings.rOptions.rDisplay.ImagesInMenu then
    begin
      ToolbarMenu.Images := AImageList;
      PopupMovieList.Images := AImageList;
      PopupToolbar.Images := AImageList;
      PopupImage.Images := AImageList;
      PopupEURL.Images := AImageList;
      PopupHTMLViewer.Images := AImageList;
    end;
    ToolbarMain.Images := AImageList;
    ToolbarPicture.Images := AImageList;
    ToolbarImages := AImageList;
  end;
begin
  with Settings.rOptions do
  begin
    { --- Toolbar icons, skin & colors --- }

    tb_color := TBitmap.Create;
    tb_grey := TBitmap.Create;
    try
      ClassicIconTheme := True;
      s := strDirToolbars + rDisplay.IconSet + '.bmp';
      if FileExists(s) then
        try
          tb_color.LoadFromFile(s);
          ClassicIconTheme := False;
        except
        end;
      if ClassicIconTheme then
        tb_color.LoadFromResourceName(HInstance, 'TOOLBARCLASSIC');
      tb_color.PixelFormat := pf24bit;
      ToolbarColorType := rDisplay.ColorType;
      if ToolbarColorType = 0 then
        SetToolbarImages(ImageListHot)
      else
      begin
        SetToolbarImages(ImageListNormal);
        tb_grey.Assign(tb_color);
        case ToolbarColorType of
          1: GrayScale(tb_grey);
          2: Blend(tb_grey, clWhite);
          3: Blend(tb_grey, clDkGray);
        end;
        ImageListNormal.Clear;
        ImageListNormal.Height := tb_grey.Height;
        ImageListNormal.Width := ImageListNormal.Height;
        ImageListNormal.AddMasked(tb_grey, tb_grey.Canvas.Pixels[0, 0]);
      end;
      ImageListHot.Clear;
      ImageListHot.Height := tb_color.Height;
      ImageListHot.Width := ImageListHot.Height;
      ImageListHot.AddMasked(tb_color, tb_color.Canvas.Pixels[0, 0]);
    finally
      tb_color.Free;
      tb_grey.Free
    end;
    with ImageListHot do
    begin
      GetIcon(Ord(ICON_MOVIENUMBER), NumberWin.Icon);
      GetIcon(Ord(ICON_INPUT), InputWin.Icon);
    end;

    FrmMovieCustom.Init;
    FrmMovieExtras.Init;

    {$IFNDEF DISABLETHEMES}
    if rDisplay.OfficeXP then
      TBXSwitcher1.Theme := 'OfficeXP'
    else
      TBXSwitcher1.Theme := 'Default';
    {$ENDIF}


    { --- Comboboxes --- }

    //SaveLists; //Why here ? -> added in ActionOptionsExecute
    LoadLists;

    { -- Other options --- }

    TBMRUList1.MaxItems := rFiles.RecentFiles;

    bState := rMovieList.Checkboxes;
    listview1.ShowCheckboxes := bState;
    //ActionMovieCheck.Enabled := bState;
    //ActionMovieUncheck.Enabled := bState;
    //ActionMovieSelCheck.Enabled := bState;
    //ActionMovieSelUncheck.Enabled := bState;

    with ListView1 do
    begin
      Tracking := rMovieList.HotTrack;
      UseCustomScrollBars := rMovieList.EnhancedScrollbars;
    end;

    ActionMoviePrevious.ShortCut := rMovieList.ShortcutPrev;
    ActionMovieNext.ShortCut := rMovieList.ShortcutNext;

    s := FrmMovie.ERating.Hint;
    FrmMovie.BeginUpdate;
    if rMovieInformation.RatingTrunc then
    begin
      FrmMovie.EUserRating.Decimal := 0;
      FrmMovie.ERating.Decimal := 0;
    end
    else
    begin
      FrmMovie.EUserRating.Decimal := 1;
      FrmMovie.ERating.Decimal := 1;
    end;
    FrmMovie.EndUpdate;

    if rMovieInformation.PictureBackground = clDefault then
      ScrollBox1.Color := clBtnFace
    else
      ScrollBox1.Color := rMovieInformation.PictureBackground;

    if rMovieInformation.PictureFitWindow then
    begin
      MoviePicture.Align := alClient;
      MoviePicture.Stretch := true;
    end else
    begin
      MoviePicture.Align := alNone;
      MoviePicture.Stretch := false;
    end;

    if rMovieInformation.MovieFrameBackground = clDefault then
    begin
      if IsThemedXP then
      begin
        FrmMovie.Color := clWindow;
        FrmMovieCustom.Color := clWindow;
        FrmMovieExtras.Color := clWindow;
      end
      else
      begin
        FrmMovie.Color := clBtnFace;
        FrmMovieCustom.Color := clBtnFace;
        FrmMovieExtras.Color := clBtnFace;
      end;
    end
    else
    begin
      FrmMovie.Color := rMovieInformation.MovieFrameBackground;
      FrmMovieCustom.Color := rMovieInformation.MovieFrameBackground;
      FrmMovieExtras.Color := rMovieInformation.MovieFrameBackground;
    end;

    if rDisplay.SoftBorders then
    begin
      with ListView1 do
      begin
        Flat := True;
        HeaderFlat := True;
        VertScrollBarStyles.ActiveFlat := True;
        VertScrollBarStyles.Flat := True;
      end;
      ScrollBox1.BorderStyle := bsNone;
      ScrollBox1.BevelKind := bkTile;
      PanelMovieInfos.BorderStyle := bsNone;
      PanelMovieInfos.BevelOuter := bvLowered;
    end else
    begin
      with ListView1 do
      begin
        Flat := False;
        HeaderFlat := IsThemedXP;
        VertScrollBarStyles.ActiveFlat := False;
        VertScrollBarStyles.Flat := False;
      end;
      ScrollBox1.BorderStyle := bsSingle;
      ScrollBox1.BevelKind := bkNone;
      PanelMovieInfos.BorderStyle := bsSingle;
      PanelMovieInfos.BevelOuter := bvNone;
    end;

    RebuildSearchMenu;

  end; // with Settings.rOptions

  FrmMovie.LSizeUnit.Caption := Settings.GetFilesSizeUnit(Messages.Strings[msgByteString]);

  FillImageListColorsTag;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ApplyLanguage;
var
  LangFile: TFileName;
begin
  with Settings.rOptions do
  begin
    if rLanguage.Language = '?' then
      ActionLanguage.Execute;
    LangFile := Settings.GetLanguageFile;
    if (LangFile <> '') and (rLanguage.Language <> Settings.Language) and FileExists(LangFile) then
    begin
      Translator.SetLanguageFile(LangFile);
      Self.Font.Name := Graphics.DefFontData.Name;
      Self.Font.Charset := Graphics.DefFontData.Charset;
      Translator.Translate(MainWindow);
      Translator.Translate(FrmMovie);
      FrmMovieCustom.Translate;
      FrmMovieExtras.Translate;
      NumberWin.Translate;
      InputWin.Translate;
      MessageWin.Translate;
    end;
    Settings.Language := rLanguage.Language;
    strHelpFile := ChangeFileExt(LangFile, '.chm');
    if not FileExists(strHelpFile) then
      strHelpFile := strFileHelp;
    FCatalogFile.MessageSaveQuery := Messages.Strings[msgUnsavedFile];
    FrmMovie.LSizeUnit.Caption := Settings.GetFilesSizeUnit(Messages.Strings[msgByteString]);
  end;
  strFieldPicture := Messages.Strings[msgPicture];
  strExtraFieldPicture := Messages.Strings[msgPicture];
  strExtras := Messages.Strings[msgExtras];
  TabMovieInfos.Tabs.Strings[0] := Messages.Strings[msgMovieFields];
  TabMovieInfos.Tabs.Strings[1] := Messages.Strings[msgCustomFields];
  TabMovieInfos.Tabs.Strings[2] := Messages.Strings[msgMovieAndCustomFields];
  TabMovieInfos.Tabs.Strings[3] := Messages.Strings[msgExtras];
  RebuildSearchMenu;
  { --- Sort by --- }
  FillFieldsSortBy;
  LoadSortField;
  { --- Group by --- }
  FillFieldsGroupBy;
  LoadGroupField;
  { --- Color tag select --- }
  FillColorTagSelect;
  { --- Color tag selected --- }
  FillColorTagSelected;
  { --- Grid Fields --- }
  SaveColumnSettings;
  FillFieldsGrid;
  { --- Find --- }
  FillFieldsCBFind(0);
  LoadFindField;
  { --- HTMLViewer --- }
  PreGenerateHTMLTemplate;
  { --- ListView1 --- }
  RefreshMovieList(True, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadSortField;
var
  FieldName: string;
  SortOrder, Idx: Integer;
begin
  with Settings.rMain do
  begin
    FSortField := fieldNumber + 1;
    FieldName := SortFieldName;
    SortOrder := 1;
    if (Length(FieldName) > 0) and (FieldName[1] = '-') then
    begin
      Delete(FieldName, 1, 1);
      SortOrder := -1;
    end;

    if SameText(FieldName, SortAdvancedFieldName) then
      FSortField := (SortAdvancedField + 1) * SortOrder
    else
    begin
      Idx := IndexText(FieldName, strTagFields);
      if Idx in AllFields then
      begin
        if Idx in SortByFields then
          FSortField := (Idx + 1) * SortOrder;
      end
      else if (MovieList <> nil) then
      begin
        Idx := MovieList.CustomFieldsProperties.IndexOf(FieldName);
        if (Idx <> -1) then
          FSortField := (customFieldLow + Idx + 1) * SortOrder;
      end;
    end;
  end;
  // Do not add SetSortField here!
  // SetSortField is called in RefreshMovieList to update header column!
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveSortField;
var
  Field: Integer;
  Descend: string;
begin
  with Settings.rMain do
  begin
    SortFieldName := strTagFields[fieldNumber];
    Field := FSortField;
    Descend := '';
    if Field < 0 then
    begin
      Field := -Field;
      Descend := '-';
    end;
    Field := Field - 1;
    if Field = SortAdvancedField then
      SortFieldName := Descend + SortAdvancedFieldName
    else if Field in AllFields then
      SortFieldName := Descend + strTagFields[Field]
    else if (MovieList <> nil) and
      (Field - customFieldLow < MovieList.CustomFieldsProperties.Count) then
      SortFieldName := Descend + MovieList.CustomFieldsProperties.Strings[Field - customFieldLow];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadGroupField;
var
  Idx: Integer;
begin
  with Settings.rMain do
  begin
    FGroupField := GroupNoneField;
    Idx := IndexText(GroupFieldName, strTagFields);
    if (Idx <> -1) then
    begin
      if (Idx in GroupByFields) then
        FGroupField := Idx
    end else
    begin
      Idx := IndexText(GroupFieldName, strTagExtraFields);
      if (Idx <> -1) then
      begin
        if ((extraFieldLow + Idx) in GroupByExtraFields) then
          FGroupField := extraFieldLow + Idx;
      end
      else if (MovieList <> nil) then
      begin
        Idx := MovieList.CustomFieldsProperties.IndexOf(GroupFieldName);
        if (Idx <> -1) then
          FGroupField := customFieldLow + Idx;
      end;
    end;
  end;
  SetGroupField(FGroupField); // Update GUI
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadGroupsFormat;
var
  i: Integer;
begin
  with Settings.rMain do
  begin
    if (GroupsFormatOption < Integer(gfoUndefined)) or
      (GroupsFormatOption > Integer(gfoRoundNumberToThousand)) then
      GroupsFormatOption := 0;
    for i := 0 to MnuTlsGpf.Count-1 do
      if MnuTlsGpf.Items[i].Tag = GroupsFormatOption then
      begin
        MnuTlsGpf.Items[i].Checked := True;
        break;
      end;
    if (GroupsFormatRoundType < Integer(rtDown)) or
      (GroupsFormatRoundType > Integer(rtUp)) then
      GroupsFormatRoundType := Integer(rtNearest);
    for i := 0 to MnuGpfRoundType.Count-1 do
      if MnuGpfRoundType.Items[i].Tag = GroupsFormatRoundType then
        MnuGpfRoundType.Items[i].Checked := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveGroupField;
begin
  with Settings.rMain do
  begin
    GroupFieldName := GroupNoneFieldName;
    if (FGroupField <> GroupNoneField) then
      if FGroupField in AllFields then
        GroupFieldName := strTagFields[FGroupField]
      else if FGroupField in AllExtraFields then
        GroupFieldName := strTagExtraFields[FGroupField - extraFieldLow]
      else if (MovieList <> nil) and (FGroupField - customFieldLow >= 0) and
        (FGroupField - customFieldLow < MovieList.CustomFieldsProperties.Count) then
        GroupFieldName := MovieList.CustomFieldsProperties.Strings[FGroupField - customFieldLow];
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.LoadFindField;
var
  Idx, Field: Integer;
begin
  with Settings.rMain do
  begin
    if FindFieldName = '*Advanced*' then
      Field := customFieldMax + 1
    else
    begin
      Field := -1;
      Idx := IndexText(FindFieldName, strTagFields);
      if Idx <> -1 then // movie field
        Field := Idx
      else
      begin
        Idx := IndexText(FindFieldName, strTagExtraFields);
        if Idx <> -1 then // extra field
          Field := extraFieldLow + Idx
        else if (MovieList <> nil) then
        begin
          Idx := MovieList.CustomFieldsProperties.IndexOf(FindFieldName);
          if Idx <> -1 then // custom field
            Field := customFieldLow + Idx
        end;
      end;
    end;
  end;
  // Update GUI
  cbxField.ItemIndex := cbxField.Items.IndexOfObject(Pointer(Field + 1));
  cbxFieldChange(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SaveFindField;
var
  Field: Integer;
begin
  Field := Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1;
  with Settings.rMain do
  begin
    if (Field = customFieldMax + 1) then
      FindFieldName := '*Advanced*'
    else
    begin
      FindFieldName := '*All*';
      if (Field > -1) then
        if Field in AllFields then // movie field
          FindFieldName := strTagFields[Field]
        else if Field in AllExtraFields then // extra field
          FindFieldName := strTagExtraFields[Field - extraFieldLow]
        else if (MovieList <> nil) then
          if (Field in AllCustomFields) and
            (Field - customFieldLow  < MovieList.CustomFieldsProperties.Count) then // custom field
            FindFieldName := MovieList.CustomFieldsProperties.Strings[Field - customFieldLow];
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function UTF8EncodeAndURLEncode(const s: string): string;
begin
  Result := TIdURI.ParamsEncode(UTF8Encode(s));
end;

procedure TMainWindow.SearchInternetClick(Sender: TObject);
var
  idx: Integer;
  url: String;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  if Sender is TTBXItem then
  begin
    idx := (Sender as TTBXItem).Tag;
    with Settings.rOptions.rMovieInformation.SearchSites do
      if idx in [0..Count-1] then
      begin
        UpdateCurrentItemIfNeeded;
        url := Values[Names[idx]];
        url := Format(url, [UTF8EncodeAndURLEncode(FrmMovie.EOriginalTitle.Text)]);
        url := TMovie(CurrentItem.Data).GetValueFromTemplate(url, nil, False,
          UTF8EncodeAndURLEncode);
        LaunchProg(url);
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.RebuildSearchMenu;
var
  newMenuItem: TTBXItem;
  i: Integer;
begin
  MnuMovSch.Clear;
  with Settings.rOptions.rMovieInformation.SearchSites do
    for i := 0 to Count-1 do
    begin
      if Pos('-', Strings[i]) = 1 then
        MnuMovSch.Add(TTBXSeparatorItem.Create(MnuMovSch))
      else
      begin
        newMenuItem := TTBXItem.Create(MnuMovSch);
        MnuMovSch.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Names[i];
          Hint := Format(Messages.Strings[msgSearchInfo], [Names[i]]);
          Tag := i;
          OnClick := SearchInternetClick;
        end;
      end; // if-else
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillFieldsSortBy;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuTlsSort do
    while Count > 4 do
      Delete(4);
  with strFields do
  begin
    for i := 0 to fieldCount-1 do
    begin
      if (i in SortByFields) then
      begin
        newMenuItem := TTBXItem.Create(MnuTlsSort);
        MnuTlsSort.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Strings[i];
          Hint := Format(Messages.Strings[msgSortBy], [Strings[i]]);
          Tag := i;
          OnClick := ActionSortExecute;
          GroupIndex := 2;
        end;
      end;
    end;
  end;
  if (MovieList <> nil) then
    with MovieList.CustomFieldsProperties do
    begin
      for i := 0 to Count-1 do
      begin
        newMenuItem := TTBXItem.Create(MnuTlsSort);
        MnuTlsSort.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Objects[i].FieldName;
          Hint := Format(Messages.Strings[msgSortBy], [Caption]);
          Tag := customFieldLow + i;
          OnClick := ActionSortExecute;
          GroupIndex := 2;
        end;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillFieldsGroupBy;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuTlsGrp do
    while Count > 2 do
      Delete(2);
  with strFields do
  begin
    for i := fieldLow to fieldCount-1 do
      if (i in GroupByFields) then
      begin
        newMenuItem := TTBXItem.Create(MnuTlsGrp);
        MnuTlsGrp.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Strings[i];
          Hint := Format(Messages.Strings[msgGroupBy], [Strings[i]]);
          Tag := i;
          OnClick := ActionGroupExecute;
          GroupIndex := 3;
        end;
      end;
  end;
  if (MovieList <> nil) then
    with MovieList.CustomFieldsProperties do
    begin
      for i := 0 to Count-1 do
      begin
        newMenuItem := TTBXItem.Create(MnuTlsGrp);
        MnuTlsGrp.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Objects[i].FieldName;
          Hint := Format(Messages.Strings[msgGroupBy], [Caption]);
          Tag := customFieldLow + i;
          OnClick := ActionGroupExecute;
          GroupIndex := 3;
        end;
      end;
    end;
  with strExtraFields do
  begin
    for i := extraFieldLow to extraFieldCount-1 do
      if (i in GroupByExtraFields) then
      begin
        newMenuItem := TTBXItem.Create(MnuTlsGrp);
        MnuTlsGrp.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Strings[i - extraFieldLow] + ' (' + strExtras + ')';
          Hint := Format(Messages.Strings[msgGroupBy],
            [(Strings[i - extraFieldLow] + ' (' + strExtras + ')')]);
          Tag := i;
          OnClick := ActionGroupExecute;
          GroupIndex := 3;
        end;
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillImageListColorsTag;
var
  bmp: TBitmap;
  i: Integer;
  Rect: TRect;
begin
  bmp := TBitmap.Create;
  bmp.Height := 16;
  bmp.Width := 16;
  with ImageListColorsTag, Settings.rOptions.rMovieList do
  begin
    Clear;
    AllocBy := 1;
    for i := 0 to Length(ColorsTag)-1 do
    begin
      bmp.Canvas.Pen.Color := clBtnFace;
      bmp.Canvas.Brush.Color := clBtnFace;
      bmp.Canvas.Rectangle(0, 0, 16, 16);
      bmp.Canvas.Pen.Color := $000000;
      bmp.Canvas.Brush.Color := ColorsTag[i];
      bmp.Canvas.Rectangle(2, 2, 14, 14);
      AddMasked(bmp, clBtnFace);
    end;

    if Settings.rOptions.rMovieList.CheckboxesColor then
    begin
      // Uncheck picture
      bmp.Canvas.Pen.Color := clBtnFace;
      bmp.Canvas.Brush.Color := clBtnFace;
      bmp.Canvas.Rectangle(0, 0, 16, 16);
      bmp.Canvas.Pen.Color := $000000;
      bmp.Canvas.Brush.Color := $FFFFFF;
      bmp.Canvas.Rectangle(2, 2, 14, 14);
      AddMasked(bmp, clBtnFace);
      // Check picture
      bmp.Canvas.Pen.Color := clBtnFace;
      bmp.Canvas.Brush.Color := clBtnFace;
      bmp.Canvas.Rectangle(0, 0, 16, 16);
      bmp.Canvas.Pen.Color := $000000;
      bmp.Canvas.Brush.Color := $FFFFFF;
      bmp.Canvas.Rectangle(2, 2, 14, 14);
      bmp.Canvas.Brush.Color := $000000;
      bmp.Canvas.Rectangle(6, 6, 10, 10);
      AddMasked(bmp, clBtnFace);
    end else
    begin
      Rect.Left := 2;
      Rect.Right := 14;
      Rect.Top := 2;
      Rect.Bottom := 14;
      bmp.Canvas.Pen.Color := clBtnFace;
      bmp.Canvas.Brush.Color := clBtnFace;
      bmp.Canvas.Rectangle(0, 0, 16, 16);
      // Uncheck picture
      DrawFrameControl(bmp.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK);
      AddMasked(bmp, clBtnFace);
      // Check picture
      DrawFrameControl(bmp.Canvas.Handle, Rect, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED);
      AddMasked(bmp, clBtnFace);
    end;
  end;
  bmp.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillColorTagSelect;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuSelect do
    while Count > 5 do
      Delete(5);
  with Settings.rOptions.rMovieList do
  begin
    for i := 0 to Length(ColorsTag)-1 do
    begin
      newMenuItem := TTBXItem.Create(MnuSelect);
      MnuSelect.Add(newMenuItem);
      with newMenuItem do
      begin
        Caption := strFields.Strings[fieldColorTag] + ' ' + IntToStr(i);
        Hint := Messages.Strings[msgColorTagSelect];
        Images := ImageListColorsTag;
        ImageIndex := i;
        Tag := i;
        OnClick := ActionMovieSelTaggedExecute;
      end;
    end;

    // Uncheck picture
    with MnuMlpSlu do
    begin
      Images := ImageListColorsTag;
      ImageIndex := Length(ColorsTag);
    end;

    // Check picture
    with MnuMlpSlc do
    begin
      Images := ImageListColorsTag;
      ImageIndex := Length(ColorsTag)+1;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillColorTagSelected;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuSelected do
    while Count > 3 do
      Delete(3);
  with Settings.rOptions.rMovieList do
  begin
    for i := 0 to Length(ColorsTag)-1 do
    begin
      newMenuItem := TTBXItem.Create(MnuSelected);
      MnuSelected.Add(newMenuItem);
      with newMenuItem do
      begin
        Caption := strFields.Strings[fieldColorTag] + ' ' + IntToStr(i);
        Hint := Messages.Strings[msgColorTagSelected];
        Images := ImageListColorsTag;
        ImageIndex := i;
        Tag := i;
        OnClick := ActionMovieTagSelectedExecute;
      end;
    end;

    // Uncheck picture
    with MnuMlpUch do
    begin
      Images := ImageListColorsTag;
      ImageIndex := Length(ColorsTag);
    end;

    // Check picture
    with MnuMlpChk do
    begin
      Images := ImageListColorsTag;
      ImageIndex := Length(ColorsTag)+1;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillFieldsGrid;
var
  i: Integer;
  newMenuItem: TTBXItem;
begin
  with MnuTlsGrf do
    while Count > 0 do
      Delete(0);
  with strFields do
    for i := 0 to fieldCount-1 do
    begin
      newMenuItem := TTBXItem.Create(MnuTlsGrf);
      MnuTlsGrf.Add(newMenuItem);
      with newMenuItem do
      begin
        Caption := Strings[i];
        Hint := '';
        Tag := i;
        OnClick := ActionGridFieldsExecute;
        GroupIndex := 0;
      end;
    end;
  if (MovieList <> nil) then
    with MovieList.CustomFieldsProperties do
      for i := 0 to Count-1 do
      begin
        newMenuItem := TTBXItem.Create(MnuTlsGrf);
        MnuTlsGrf.Add(newMenuItem);
        with newMenuItem do
        begin
          Caption := Objects[i].FieldName;
          Hint := '';
          Tag := customFieldLow + i;
          OnClick := ActionGridFieldsExecute;
          GroupIndex := 0;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FillFieldsCBFind(SelectedItem: Integer);
var
  i: Integer;
begin
  cbxField.Items.BeginUpdate;
  try
    cbxField.Items.Clear;
    cbxField.Items.AddObject(Messages.Strings[msgFindFieldAll], Pointer(0));
    for i := fieldLow to fieldCount-1 do
      cbxField.Items.AddObject(strFields[i], Pointer(i + 1));
    if MovieList <> nil then
      with MovieList.CustomFieldsProperties do
        for i := 0 to Count-1 do
          cbxField.Items.AddObject(Objects[i].FieldName, Pointer(i + customFieldLow + 1));
    for i := extraFieldLow to extraFieldCount-1 do
      cbxField.Items.AddObject(strExtraFields[i - extraFieldLow] + ' (' + strExtras + ')',
        Pointer(i + 1));
    cbxField.Items.AddObject(Messages.Strings[msgFindAdvanced], Pointer(customFieldMax + 2));
    cbxField.ItemIndex := SelectedItem;
  finally
    cbxField.Items.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
   Actions
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileNewExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveLists; // Save drop-down lists
  SetSaveFilter;
  FCatalogFile.New;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileOpenExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveLists; // Save drop-down lists
  SetSaveFilter;
  with FCatalogFile do
  begin
    OpenDialog.InitialDir := Settings.rOptions.rFolders[fuCatalogs].Value;
    if OpenDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    if Open then
    begin
      Settings.rOptions.rFolders[fuCatalogs].Value := ExtractFilePath(CurrentFile);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileSaveExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveLists; // Save drop-down lists
  SetSaveFilter;
  FCatalogFile.Save;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileSaveAsExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveLists; // Save drop-down lists
  SetSaveFilter;
  with FCatalogFile do
  begin
    if SaveAs then
    begin
      Settings.rOptions.rFolders[fuCatalogs].Value := ExtractFilePath(CurrentFile);
      RefreshMovieList;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileExportExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveCurrentItem;
  SaveLists; // Save drop-down lists
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TExportWin, ExportWin);
    try
      ImageListHot.GetIcon(Ord(ICON_FILEEXPORT), ExportWin.Icon);
      StoreSelectedState;
      ExportWin.Execute(FCatalogFile.CurrentFile, MovieList);
    finally
      ExportWin.Release;
      ExportWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    StartThumbThread;
    FrmMovieExtras.StartThumbThread;
    // Reload HTMLTemplate (if file is modified in export window)
    PreGenerateHTMLTemplate;
    // Refresh HTML display
    HTMLViewerUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFilePrintExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveCurrentItem;
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  try
    with ProgressWin do
    begin
      Maximum := 1;
      Status := Messages.Strings[msgPrintLoading];
      IntProgress := 0;
      Progress := Messages.Strings[msgPrintSearching];
      Execute(Self);
      try
        Application.ProcessMessages;
        printform.Init_FR;
        IntProgress := 1;
      finally
        Close;
      end;
    end;
    try
      Application.CreateForm(TPrintWin, PrintWin);
      try
        ImageListHot.GetIcon(Ord(ICON_FILEPRINT), PrintWin.Icon);
        StoreSelectedState;
        PrintWin.Execute(FCatalogFile.CurrentFile, MovieList);
      finally
        PrintWin.Release;
        PrintWin := nil;
      end;
    finally
      printform.Final_FR;
    end;
  finally
    StartThumbThread;
    FrmMovieExtras.StartThumbThread;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieAddExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
    with Settings.rOptions.rMovieInformation do
      if(NumberWin.Execute(MovieList, true, not AskNumber, AskNumber) = mrOk) then
      begin
        if NumberWin.CBDoNotAsk.checked then
        begin
          AskNumber := false;
        end;
        //ThumbsViewerStop; //Done in NewItem function
        NewItem;
        //ThumbsViewerStart; //Done in NewItem function
        with FrmMovie.EOriginalTitle do
          if CanFocus and Self.Enabled then
            SetFocus;
        if Sender <> nil then
        begin
          if AddFiles then
            ActionMovieImportFiles.Execute;
          if AddScript then
            ActionMovieImportScript.Execute;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieNumberExecute(Sender: TObject);
var
  CurMovie: TMovie;
  Existing: TMovie;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  CurMovie := TMovie(CurrentItem.Data);
  if NumberWin.Execute(MovieList, False, False, True, CurMovie.iNumber) = mrOk then
  begin
    case NumberWin.grpNotUnique.ItemIndex of
      1:
        begin
          Existing := MovieList.Find(NumberWin.ENumber.AsInteger);
          if Existing <> nil then
          begin
            if Settings.rOptions.rMovieInformation.FirstAvailable then
              Existing.iNumber := MovieList.FirstFreeNumber
            else
              Existing.iNumber := MovieList.MaxNumber + 1; // + 1 !
          end;
        end;
      2:
        begin
          MovieList.ShiftNumbers(NumberWin.ENumber.AsInteger, CurMovie);
        end;
    end;
    CurMovie.iNumber := NumberWin.ENumber.AsInteger;
    FCatalogFile.Modified := True;
    RefreshMovieList;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieUndoExecute(Sender: TObject);
var
  DoNotAsk: boolean;
  Movie: TMovie;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem <> nil) and (MovieSave <> nil) then
  begin
    if Settings.rOptions.rMovieList.ConfirmUndo then
    begin
      DoNotAsk := false;
      if MessageWin.Execute(Messages.Strings[msgUndo], mtConfirmation, DoNotAsk,
                            Messages.Strings[msgDoNotConfirm], [mbYes,mbNo]) = 1 then
        Settings.rOptions.rMovieList.ConfirmUndo := not DoNotAsk
      else
        exit;
    end;
    StopThumbThread;
    //FrmMovieExtras.StopThumbThread; // Not needed because movie extras are not restored
    try
      Movie := TMovie(CurrentItem.Data);
      if FCatalogFile.CurrentFile <> '' then
        SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);

      Movie.Picture.PictureOperation(FCatalogFile.CurrentFile, mpoDelete); // delete old picture
      //TODO: Add Extras ?
      // Movie extras are not restored
      Movie.Assign(MovieSave, True, True, False, True, True);
      if (Movie.Picture.PicStream <> nil) and (StartsStr('*', Movie.Picture.PicPath)) then // copied picture temporaly stored in memory to restore
      begin
        System.Delete(Movie.Picture.PicPath, 1, 1);
        Movie.Picture.PicStream.SaveToFile(ExpandFileName(Movie.Picture.PicPath));
        FreeAndNil(Movie.Picture.PicStream);
        FreeAndNil(Movie.Picture._thumb);
        Movie.Picture._thumbError := 0;
      end;
      OpenItem(CurrentItem);
      UpdateCurrentItem;
      FreeAndNil(MovieSave);
      MovieSelected;
    finally
      ThumbsViewerStart;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieDeleteExecute(Sender: TObject);
var
  i: Integer;
  AllClicked, OneDeleted: Boolean;
  ListDelete: TStringList;
  KeyMovie: string;
  TreeItem: TElTreeItem;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if NbMoviesSelected = 0 then Exit;
  AllClicked := False;
  OneDeleted := False;
  with ListView1.Items do
  begin
    try
      ListDelete := TStringList.Create;
      ListDelete.Sorted := True;
      for i := 0 to Count-1 do
      begin
        with Item[i] do
          if (Selected) and (Data <> nil) then
            begin
              KeyMovie := Format('%p', [Data]);
              if ListDelete.IndexOf(KeyMovie) = -1 then
                ListDelete.AddObject(KeyMovie, Data);
            end;
      end;
      //ThumbsViewerStop; //Done in DeleteItem function
      BeginUpdate;
      for i := 0 to ListDelete.Count-1 do
      begin
        if not AllClicked then
        begin
          TreeItem := TElTreeItem(TMovie(ListDelete.Objects[i])._selectedItem);
          if (TreeItem <> nil) then
          begin
            EndUpdate;
            if (TreeItem.Parent <> nil) and (TreeItem.Parent.Expanded = False) then
              TreeItem.Parent.Expanded := True;
            EnsureVisibleListView1(TreeItem);
            EnsureVisibleThumbsViewer(TreeItem);
            BeginUpdate;
          end;
        end;

        case Self.DeleteItem(TMovie(ListDelete.Objects[i]), not AllClicked, True) of
          1:  OneDeleted := True;
          2,0:  begin AllClicked := True; OneDeleted := True; end;
          4:  break;
        end;

        if not AllClicked then
        begin
          EndUpdate;
          if (OneDeleted) and (i+1 < ListDelete.Count) then
            ThumbsViewerStart;
          SetStatus;
          BeginUpdate;
        end;
      end;
      ListDelete.Free;
    finally
      EndUpdate;
      if(OneDeleted) then
        ThumbsViewerStart;
    end;
  end; // with ListView1, Items
  if(OneDeleted) then
  begin
    CurrentItem := nil;
    ClearItem;
    if (NbMoviesSelected = 0) and (ListView1.ItemFocused <> nil) then
      ListView1.ItemFocused := ListView1.ItemFocused;
    ListView1AfterSelectionChange(nil);
    ListView1EnsureVisiblePlus;
    SetStatus;
    FCatalogFile.Modified := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionHelpAboutExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TAboutWin, AboutWin);
    try
      ImageListHot.GetIcon(Ord(ICON_ABOUT), AboutWin.Icon);
      AboutWin.ShowModal;
    finally
      AboutWin.Release;
      AboutWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionHelpVersionExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TAboutWin, AboutWin);
    try
      AboutWin.ShowVersions;
    finally
      AboutWin.Release;
      AboutWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionExitExecute(Sender: TObject);
begin
  Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieImportFilesExecute(Sender: TObject);
var
  s: string;
begin
  //StopThumbThread; // Done in DragDropFilesDrop
  with TOpenDialog.Create(Self) do
    try
      InitialDir := Settings.rOptions.rFolders[fuGetFromFiles].Value;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      FileName := '';
      Title := Messages.Strings[msgSelectFilesInfo];
      Options := DialogOpenOptions + [ofAllowMultiSelect];
      s := Trim(Settings.rOptions.rMovieInformation.ImportExt);
      if (s <> '') then
      begin
        s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
        s := StringReplace(s, '  ', ' ', [rfReplaceAll]);
        s := '*' + StringReplace(s, ' ', ';*', [rfReplaceAll]);
      end else
      begin
        //for i := Low(extVideo) to High(extVideo) do
        //begin
        //  if s <> '' then
        //    s := s + ';';
        //  s := Format('%s*%s', [s, extVideo[i]]);
        //end;
        s := '*.novideoext';
      end;

      Filter := Format(DialogGetInfoFilter, [s]);
      if Execute then
      begin
        Settings.rOptions.rFolders[fuGetFromFiles].Value := ExtractFilePath(FileName);
        DragDropFilesDrop(sender, point(0, 0), TStringList(Files));
      end;
  finally
    Free;
  end;
  //ThumbsViewerStart; // Done in DragDropFilesDrop
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieImportCDExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieImportScriptExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if NbMoviesSelected = 0 then
    ActionMovieAddExecute(nil);
  if NbMoviesSelected > 0 then
    ActionToolsScriptingExecute(ActionMovieImportScript);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionManagePicturesExecute(Sender: TObject);
var
  Refreshed: Boolean;
begin
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Refreshed := False;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TPicturesManagerWin, PicturesManagerWin);
    try
      ImageListHot.GetIcon(Ord(ICON_MOVIEPICTURE), PicturesManagerWin.Icon);
      StoreSelectedState;
      if PicturesManagerWin.Execute(MovieList, FCatalogFile.CurrentFile) = mrOk then
      begin
        FCatalogFile.Modified := True;
        ListView1AfterSelectionChange(nil);
        ThumbsViewerStart;
        Refreshed := True;
      end;
    finally
      PicturesManagerWin.Release;
      PicturesManagerWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    if not Refreshed then
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionToolsScriptingExecute(Sender: TObject);
var
  WorkMode: TScriptWorkMode;
  Refreshed: Boolean;
begin
  if Sender = ActionMovieImportScript then
    WorkMode := swmGetInfo
  else
    WorkMode := swmScripting;
  StoreSelectedState;
  SaveCurrentItem;
  SaveLists;
  Screen.Cursor := crHourGlass;
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Refreshed := False;
  try
    GetScriptWin := TGetScriptWin.Create(Self, WorkMode);
    with GetScriptWin do
      try
        ImageListHot.GetIcon(Ord(ICON_MOVIEIMPORTSCRIPT), Icon);
        if GetScriptWin.Execute(FCatalogFile, Self.MovieList) = mrOk then
        begin
          // Done in GetScriptWin/ScriptResultsWin only if catalog is modified
          //FCatalogFile.Modified := True;
          LoadLists;
          RefreshMovieList(False);
          Refreshed := True;
          LoadSelectedState;
          ListView1EnsureVisiblePlus;
          ThumbsViewerEnsureVisiblePlus;
        end;
      finally
        Release;
        GetScriptWin := nil;
      end;
  finally
    Screen.Cursor := crDefault;
    if not Refreshed then
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieFindExecute(Sender: TObject);
begin
  ToolbarFind.Visible := ActionMovieFind.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieCopyExecute(Sender: TObject);
var
  Movie: TMovie;
  TempMovie: TMovie;
  Status: TMoviePictureStatus;
  DataHandle: THandle;
  i: Integer;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  with CurrentItem do
  begin
    Movie := TMovie(Data);
    Movie.Picture.Lock;
    FrmMovieExtras.StopThumbThread;
    TempMovie := TMovie.Create(MovieList);
    try
      UpdateCurrentItemIfNeeded;
      TempMovie.Assign(Movie, True, True, True, True, True);
      if FCatalogFile.CurrentFile <> '' then
        SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
      else
        SetCurrentDir(strDirCatalogs);
      Status := TempMovie.Picture.GetPictureStatus(FCatalogFile.CurrentFile);
      if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) or (Status = mpsLinkRel) then
        TempMovie.Picture.PicPath := ExpandFileName(TempMovie.Picture.PicPath);
      with TempMovie.Extras do
        for i := 0 to Count-1 do
        begin
          Status := Items[i].Picture.GetPictureStatus(FCatalogFile.CurrentFile);
          if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) or (Status = mpsLinkRel) then
            Items[i].Picture.PicPath := ExpandFileName(Items[i].Picture.PicPath);
        end;
      try
        DataHandle := TempMovie.SaveToMemory;
        try
          ClipBoard.SetAsHandle(ClipboardMovieFormat, DataHandle);
        finally
          TempMovie.FreeMemory(DataHandle, True);
        end;
      except
        on e:Exception do
        begin
          MessageWin.Execute('Copy to clipboard - Error: '+e.Message, mtError, [mbOk]);
        end;
      end;
    finally
      TempMovie.Free;
      Movie.Picture.Unlock;
      FrmMovieExtras.StartThumbThread;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMoviePasteExecute(Sender: TObject);
var
  TempMovie, Movie: TMovie;
  TreeItem: TElTreeItem;
  DataHandle: THandle;
  sCaption, KeyMovie: string;
  picImportMethod: TMoviePictureImport;
  ListPaste: TStringList;
  i, idx: Integer;
  LastResult: TScriptResult;
  OnePaste : Boolean;
  AllowedCustomFields: TMovieFields;

  procedure PasteMovie;
  begin
    ScriptResultsWin.CopyFrom(Movie);

    ScriptResultsWin.SetAllFieldsAndCustomFields(TempMovie);
    if TempMovie.Picture.PicPath <> '' then
      if TempMovie.Picture.PicStream <> nil then
        ScriptResultsWin.SetPicture(TempMovie.Picture.PicStream, TempMovie.Picture.PicPath, picImportMethod)
      else
        ScriptResultsWin.ImportPicture(TempMovie.Picture.PicPath, picImportMethod)
    else
      ScriptResultsWin.RemovePicture;
    ScriptResultsWin.ClearAndAddAllExtras(TempMovie, picImportMethod);

    sCaption := Format(Messages.Strings[msgCopyPasteMovie], [Movie.GetFormattedTitle]);

    LastResult := ScriptResultsWin.Execute(LastResult <> srSaveAll, '', sCaption,
      ScriptResultsWin.SelectedFields, ScriptResultsWin.SelectedCustomFields,
      ScriptResultsWin.SelectedPicture, ScriptResultsWin.SelectedAddExtras,
      ScriptResultsWin.SelectedDeleteExtras, ScriptResultsWin.SelectedModifyExtras,
      ScriptResultsWin.SelectedExtraFields, ScriptResultsWin.SelectedExtraPicture);

    case LastResult of
      srSave,
      srSaveAll:
      begin
        ScriptResultsWin.CopyTo(Movie, True);
        OnePaste := True;
        // Done in ScriptResultsWin only if catalog is modified
        //FCatalogFile.Modified := True;
      end;
    end;
  end;

begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if NbMoviesSelected = 0 then Exit;

  TempMovie := nil;
  try
    DataHandle := ClipBoard.GetAsHandle(ClipboardMovieFormat);
    if DataHandle <> 0 then
    begin
      TempMovie := TMovie.Create(MovieList);
      TempMovie.LoadFromMemory(DataHandle)
    end;
  except
    FreeAndNil(TempMovie);
  end;
  if TempMovie = nil then Exit;

  if FCatalogFile.CurrentFile <> '' then
    SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
  else
    SetCurrentDir(strDirCatalogs);
  picImportMethod := TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rPicImport.GetInfoMethod));

  LastResult := srSave;
  OnePaste := False;

  ScriptResultsWin := TScriptResultsWin.Create(Self);
  ScriptResultsWin.btn1.Hint := '';
  ScriptResultsWin.btn2.Hint := '';
  ScriptResultsWin.btn3.Hint := '';
  ScriptResultsWin.btn4.Hint := '';
  ImageListHot.GetIcon(Ord(ICON_MOVIEPASTE), ScriptResultsWin.Icon);
  ScriptResultsWin.GenerateFields(MovieList.CustomFieldsProperties);
  AllowedCustomFields := [];
  with MovieList.CustomFieldsProperties do
    for i := 0 to Count-1 do
      if (Objects[i].FieldType <> ftVirtual) then
        Include(AllowedCustomFields, i+customFieldLow);
  ScriptResultsWin.Init(AllFields - VirtualFields, AllowedCustomFields, True,
    True, True, True, AllExtraFields - VirtualFields, True, FCatalogFile, True);

  // Load deselected fields
  with ScriptResultsWin, Settings.rMain do
  begin
    SelectedFields := AllFields;
    SelectedCustomFields := AllCustomFields;
    SelectedPicture := True;
    SelectedAddExtras := True;
    SelectedDeleteExtras := True;
    SelectedModifyExtras := True;
    SelectedExtraFields := AllExtraFields;
    SelectedExtraPicture := True;
    for i := 0 to PasteDeselectedFields.Count-1 do
    begin
      if SameText(PasteDeselectedFields.Strings[i], strTagFieldPicture) then
        SelectedPicture := False
      else
      if SameText(PasteDeselectedFields.Strings[i], strTagExtraFieldPicture) then
        SelectedExtraPicture := False
      else
      if SameText(PasteDeselectedFields.Strings[i], '*AddExtras*') then
        SelectedAddExtras := False
      else
      if SameText(PasteDeselectedFields.Strings[i], '*DeleteExtras*') then
        SelectedDeleteExtras := False
      else
      if SameText(PasteDeselectedFields.Strings[i], '*ModifyExtras*') then
        SelectedModifyExtras := False
      else
      begin
        idx := IndexText(PasteDeselectedFields.Strings[i], strTagFields);
        if idx <> -1 then
          SelectedFields := SelectedFields - [idx]
        else
        begin
          idx := MovieList.CustomFieldsProperties.IndexOf(PasteDeselectedFields.Strings[i]);
          if idx <> -1 then
            SelectedCustomFields := SelectedCustomFields - [idx + customFieldLow]
          else
          begin
            idx := IndexText(PasteDeselectedFields.Strings[i], strTagExtraFields);
            if idx <> -1 then
              SelectedExtraFields := SelectedExtraFields - [idx + extraFieldLow]
          end;
        end;
      end;
    end;
  end;

  if (CurrentItem <> nil) then
  begin
    StopThumbThread;
    FrmMovieExtras.StopThumbThread;
    Movie := TMovie(CurrentItem.Data);
    MakeMovieSave(Movie, False);
    UpdateCurrentItemIfNeeded;
    PasteMovie;
    if OnePaste then
    begin
      ThumbsViewerStart;
      OpenItem(CurrentItem);
      UpdateCurrentItem;
      MovieSelected;
    end else
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end;
  end
  else
  begin
    with ListView1.Items do
    begin
      StopThumbThread;
      try
        ListPaste := TStringList.Create;
        ListPaste.Sorted := True;
        for i := 0 to Count-1 do
        begin
          with Item[i] do
            if (Selected) and (Data <> nil) then
              begin
                KeyMovie := Format('%p', [Data]);
                if ListPaste.IndexOf(KeyMovie) = -1 then
                  ListPaste.AddObject(KeyMovie, Data);
              end;
        end;
        for i := 0 to ListPaste.Count-1 do
        begin
          if LastResult <> srSaveAll then
          begin
            TreeItem := TElTreeItem(TMovie(ListPaste.Objects[i])._selectedItem);
            if (TreeItem <> nil) then
            begin
              if (TreeItem.Parent <> nil) and (TreeItem.Parent.Expanded = False) then
                TreeItem.Parent.Expanded := True;
              EnsureVisibleListView1(TreeItem);
              EnsureVisibleThumbsViewer(TreeItem);
            end;
          end;
          Movie := TMovie(ListPaste.Objects[i]);
          PasteMovie;
          if LastResult = srAbort then Break;
        end;
        ListPaste.Free;
      finally
        if OnePaste then
          RefreshMovieList
        else
          StartThumbThread;
      end;
    end; // with ListView1, Items
  end;

  // Save deselected fields
  if OnePaste then
    with ScriptResultsWin, Settings.rMain do
    begin
      PasteDeselectedFields.Clear;
      if not SelectedPicture then
        PasteDeselectedFields.Add(strTagFieldPicture);
      for i := fieldLow to fieldCount-1 do
        if not (i in VirtualFields) then
        begin
          if not (i in SelectedFields) then
            PasteDeselectedFields.Add(strTagFields[i]);
        end;
      for i := 0 to MovieList.CustomFieldsProperties.Count-1 do
        if (customFieldLow + i) in AllowedCustomFields then
        begin
          if not ((customFieldLow + i) in SelectedCustomFields) then
            PasteDeselectedFields.Add(MovieList.CustomFieldsProperties.Strings[i]);
        end;
      if not SelectedAddExtras then
        PasteDeselectedFields.Add('*AddExtras*');
      if not SelectedDeleteExtras then
        PasteDeselectedFields.Add('*DeleteExtras*');
      if not SelectedModifyExtras then
        PasteDeselectedFields.Add('*ModifyExtras*');
      for i := extraFieldLow to extraFieldCount-1 do
        if not (i in VirtualFields) then
        begin
          if not (i in SelectedExtraFields) then
            PasteDeselectedFields.Add(strTagExtraFields[i - extraFieldLow]);
        end;
      if not SelectedExtraPicture then
        PasteDeselectedFields.Add(strTagExtraFieldPicture);
    end;

  FreeAndNil(ScriptResultsWin);
  TempMovie.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieRenumberExecute(Sender: TObject);
var
  Refreshed: Boolean;
begin
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Refreshed := False;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TRenumberWin, RenumberWin);
    try
      ImageListHot.GetIcon(Ord(ICON_RENUMBER), RenumberWin.Icon);
      if RenumberWin.Execute(MovieList) = mrOk then
      begin
        FCatalogFile.Modified := True;
        RefreshMovieList;
        Refreshed := True;
      end;
    finally
      RenumberWin.Release;
      RenumberWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    if not Refreshed then
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFileImportExecute(Sender: TObject);
var
  Refreshed: Boolean;
begin
  StoreSelectedState;
  SaveCurrentItem;
  SaveLists;
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Refreshed := False;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TImportWin2, ImportWin);
    try
      ImageListHot.GetIcon(Ord(ICON_FILEIMPORT), ImportWin.Icon);
      if ImportWin.Execute(FCatalogFile.CurrentFile, MovieList) then
      begin
        FCatalogFile.Modified := True;
        LoadLists;
        RefreshMovieList(False);
        Refreshed := True;
        LoadSelectedState;
        ListView1EnsureVisiblePlus;
        ThumbsViewerEnsureVisiblePlus;
      end;
    finally
      ImportWin.Release;
      ImportWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    if not Refreshed then
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionHelpIndexExecute(Sender: TObject);
begin
  LaunchHelp(self);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionLoanExecute(Sender: TObject);
var
  FileModified: Boolean;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveCurrentItem;
  ActionLoan.Enabled := False;
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TLoanWin, LoanWin);
    try
      ImageListHot.GetIcon(Ord(ICON_LOANS), LoanWin.Icon);
      LoanWin.Execute(MovieList, ExtractFileName(FCatalogFile.CurrentFile), FrmMovie.EBorrower.Items, FileModified);
      with Settings.rOptions.rMovieInformation.rCombo[ddlBorrowers] do
        if not UseCatalogValues then
          Contents.Assign(FrmMovie.EBorrower.Items);
    finally
      LoanWin.Release;
      LoanWin := nil;
    end;
    FCatalogFile.Modified := FileModified or FCatalogFile.Modified;
  finally
    Screen.Cursor := crDefault;
    ActionLoan.Enabled := True;
    if FileModified then
      RefreshMovieList
    else
    begin
      StartThumbThread;
      FrmMovieExtras.StartThumbThread;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionGroupExecute(Sender: TObject);
begin
  if Sender = ActionGroupNone then
    SetGroupField(GroupNoneField)
  else if Sender is TTBXItem then
    SetGroupField(TTBXItem(Sender).Tag);
  SaveGroupField;
  RefreshMovieList;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionGroupsFormatExecute(Sender: TObject);
begin
  with Settings.rMain do
  begin
    if Sender = ActionGroupsFormatNone then
      GroupsFormatOption := Integer(gfoUndefined)
    else if (Sender is TTBXItem) and (TTBXItem(Sender).Tag > -1) then
      GroupsFormatOption := TTBXItem(Sender).Tag;
    if FGroupField <> GroupNoneField then
      RefreshMovieList;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MnuGrpsFormatRTClick(Sender: TObject);
begin
  with Settings.rMain do
  begin
    GroupsFormatRoundType := TTBXItem(Sender).Tag;
    if (FGroupField <> GroupNoneField) and
      (GroupsFormatOption >= Integer(gfoRoundNumberToThousandth)) and
      (GroupsFormatOption <= Integer(gfoRoundNumberToThousand)) then
      RefreshMovieList;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionSortExecute(Sender: TObject);
begin
  if (Sender = ActionSortAscend) or (Sender = ActionSortDescend) then
    SetSortField(Abs(FSortField) - 1, Sender = ActionSortDescend)
  else if (Sender = ActionSortAdvanced) then
  begin
    with Settings.rMain do
    begin
      SortWin := TSortWin.Create(Self);
      try
        SortWin.Fields.LoadFromStrings(SortAdvancedFields, MovieList.CustomFieldsProperties);
        SortWin.ShowModal;
        SortWin.Fields.SaveToStrings(SortAdvancedFields, MovieList.CustomFieldsProperties);
      finally
        SortWin.Free;
      end;
      SetSortField(SortAdvancedField, MnuTlsSortDescend.Checked);
    end;
  end
  else if Sender is TTBXItem then
    SetSortField(TTBXItem(Sender).Tag, MnuTlsSortDescend.Checked);
  SaveSortField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionGridFieldsExecute(Sender: TObject);
var
  ListField: Integer;
begin
  if Sender is TTBXItem then
    with TTBXItem(Sender) do
    begin
      ListField := Tag;
      if ListField >= customFieldLow then
      begin
        ListField := ListField - customFieldLow + fieldCount;
        MnuTlsGrf.Items[ListField].Checked :=
          not MnuTlsGrf.Items[ListField].Checked;
      end else
        MnuTlsGrf.Items[Tag].Checked := not MnuTlsGrf.Items[Tag].Checked;
      if ListField = fieldFormattedTitle then ListField := 3 //(1 + 2)
      else if ListField = fieldNumber then ListField := 2 //(0 + 2)
      else if (ListField > fieldFormattedTitle) then ListField := ListField + 2 // (x + 2)
      else ListField := ListField + 3; // (x + 2 + 1)
      if (not ListView1.HeaderSections.Item[1].Visible) then // Grid mode
        ListView1.HeaderSections.Item[ListField].Visible :=
          not ListView1.HeaderSections.Item[ListField].Visible
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionToolsGridExecute(Sender: TObject);
begin
  SaveCurrentItem;
  ActionToolsGrid.Checked := not ActionToolsGrid.Checked;
  if (Sender <> nil) and Settings.rOptions.rMovieList.AutoStretchListGrid then
    AutoStretchList;
  RefreshMovieList;
end;
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionRefreshExecute(Sender: TObject);
begin
  RefreshMovieList;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionOptionsExecute(Sender: TObject);
begin
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Screen.Cursor := crHourGlass;
  try
    SaveLists; // Save drop-down lists
    Application.CreateForm(TOptionsWin, OptionsWin);
    try
      ImageListHot.GetIcon(Ord(ICON_OPTIONS), OptionsWin.Icon);
      StoreSelectedState; // Need to be done here !
      if OptionsWin.Execute(MovieList.CustomFieldsProperties,
        ToolbarMain, ImageListHot) = mrOk then
      begin
        ApplyOptions;
        // Reload HTMLTemplate
        PreGenerateHTMLTemplate;
        // Reload ListView1
        RefreshMovieList(False);
        LoadSelectedState;
        ListView1EnsureVisiblePlus;
        ThumbsViewerEnsureVisiblePlus;
      end;
    finally
      OptionsWin.Release;
      OptionsWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    StartThumbThread;
    FrmMovieExtras.StartThumbThread;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionLanguageExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  with TLanguageWin.Create(Self) do
    try
      ImageListHot.GetIcon(Ord(ICON_LANGUAGES), Icon);
      if Execute then
        ApplyLanguage;
    finally
      Screen.Cursor := crDefault;
      Release;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayMainToolbarExecute(Sender: TObject);
begin
  ToolbarMain.Visible := ActionDisplayMainToolbar.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayPictureToolbarExecute(Sender: TObject);
begin
  ToolbarPicture.Visible := ActionDisplayPictureToolbar.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayExtrasToolbarExecute(Sender: TObject);
begin
  FrmMovieExtras.ToolbarExtras.Visible := ActionDisplayExtrasToolbar.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayStatusBarExecute(Sender: TObject);
begin
  StatusBar1.Visible := ActionDisplayStatusBar.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieStatsExecute(Sender: TObject);
begin
  StopThumbThread;
  FrmMovieExtras.StopThumbThread;
  Screen.Cursor := crHourGlass;
  try
    SaveCurrentItem;
    StoreSelectedState;
    Application.CreateForm(TStatsWin, StatsWin);
    try
      ImageListHot.GetIcon(Ord(ICON_STATISTICS), StatsWin.Icon);
      StatsWin.Execute(MovieList, FCatalogFile.CurrentFile);
    finally
      FreeAndNil(StatsWin);
    end;
  finally
    Screen.Cursor := crDefault;
    StartThumbThread;
    FrmMovieExtras.StartThumbThread;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuFileExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuMovieExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuDisplayExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuToolsExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuHelpExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuPictureExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuGetExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuGroupExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuSortExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMenuGridFieldsExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieSearchExecute(Sender: TObject);
begin
//
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionSelectHTMLExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieUrlExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  FSelectedURL := FrmMovie.EURL;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieFilePathExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  FSelectedURL := FrmMovie.EFilePath;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionHTMLEditorExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  SaveColumnSettings;
  SaveCurrentItem;
  SaveLists; // Save drop-down lists
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(THTMLEditorWin, HTMLEditorWin);
    try
      ImageListHot.GetIcon(Ord(ICON_HTML), HTMLEditorWin.Icon);
      HTMLEditorWin.Execute(MovieList.CustomFieldsProperties);
    finally
      HTMLEditorWin.Release;
      HTMLEditorWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
    // Reload HTMLTemplate (if file is modified in html editor)
    PreGenerateHTMLTemplate;
    // Refresh HTML display
    HTMLViewerUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MnuTlsSelHTMLPopup(Sender: TTBCustomItem; FromLink: Boolean);
var
  Item: TTBXItem;
  CurrentFile, Ext, Value: string;
  Res: TSearchRec;
  EOFound, CurrentFileFound: Boolean;
  DirList: TStringList;
  i: Integer;
  ModifiedDate: TDateTime;
begin
  SetCurrentDir(strDirTemplates);
  while MnuTlsSelHTML.Count > 2 do
    MnuTlsSelHTML.Delete(MnuTlsSelHTML.Count-1);

  ModifiedDate := GetFileModifiedDate(strFileHtmlDisplayExcludedTemplates);
  if HTMLDisplayExcludedTemplatesModifiedDate <> ModifiedDate then
  begin
    HTMLDisplayExcludedTemplates.Clear;
    if FileExists(strFileHtmlDisplayExcludedTemplates) then
      HTMLDisplayExcludedTemplates.LoadFromFile(strFileHtmlDisplayExcludedTemplates);
    HTMLDisplayExcludedTemplatesModifiedDate := ModifiedDate;
  end;

  with Settings.rOptions.rFiles do
  begin
    DirList := TStringList.Create;
    DirList.CaseSensitive := False;
    if DirectoryExists(strDirTemplates) then
    begin
      // Add directory to explore
      DirList.Add(strDirTemplates);
      // Add sub-directories to explore
      EOFound := False;
      if FindFirst(strDirTemplates + '*', faDirectory, Res) >= 0 then
        while (not EOFound) do
        begin
          if ((Res.Attr and faDirectory) <> 0) and (Res.Name <> '.') and (Res.Name <> '..') then
          begin
            if Pos('?', Res.Name) = 0 then
            begin
              DirList.Add(strDirTemplates + Res.Name + '\');
            end;
          end;
          EOFound := FindNext(Res) <> 0;
        end;
      FindClose(Res);
    end;
    // Add template files
    CurrentFile := ExpandFileName(HTMLTemplateFile);
    if not FileExists(CurrentFile) then
      CurrentFile := '';
    CurrentFileFound := False;
    for i := 0 to DirList.Count-1 do
    begin
      EOFound := False;
      if FindFirst(DirList.Strings[i] + '*.*', faAnyFile, Res) >= 0 then
        while not EOFound do
        begin
          Ext := LowerCase(ExtractFileExt(Res.Name));
          if (Ext = '.html') or (Ext = '.htm') then
          begin
            Value := ExtractRelativePath(strDirTemplates, DirList.Strings[i]) + Res.Name;
            if HTMLDisplayExcludedTemplates.IndexOf(Value) = -1 then
            begin
              Item := TTBXItem.Create(MnuTlsSelHTML);
              MnuTlsSelHTML.Add(Item);
              Item.Caption := Value;
              Item.OnClick := HTMLPopupClickSelect;
              if SameFileName(CurrentFile, DirList.Strings[i] + Res.Name) then
              begin
                CurrentFileFound := True;
                Item.Checked := True;
              end;
            end;
          end;
          EOFound := FindNext(Res) <> 0;
        end;
      FindClose(Res);
    end;
    if (CurrentFile <> '') and (not CurrentFileFound) then
    begin
      Item := TTBXItem.Create(MnuTlsSelHTML);
      MnuTlsSelHTML.Insert(2, Item);
      Item.Caption := CurrentFile;
      Item.OnClick := HTMLPopupClickSelect;
      Item.Checked := True;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLPopupClickBrowse(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  with TOpenDialog.Create(Self), Settings.rOptions.rFiles do
    try
      SetCurrentDir(strDirTemplates);
      InitialDir := strDirTemplates;
      Filter := DialogHTMLFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(HTMLTemplateFile);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
      begin
        HTMLTemplateFile := FileName;
        PreGenerateHTMLTemplate;
        HTMLViewerUpdate;
      end;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLPopupClickSelect(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if Sender is TTBXItem then
    with Settings.rOptions.rFiles do
    begin
      SetCurrentDir(strDirTemplates);
      HTMLTemplateFile := ExpandFileName(TTBXItem(Sender).Caption);
      PreGenerateHTMLTemplate;
      HTMLViewerUpdate;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFilePropertiesExecute(Sender: TObject);
begin
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TPropertiesWin, PropertiesWin);
    with PropertiesWin do
      try
        ImageListHot.GetIcon(Ord(ICON_FILEPROPERTIES), Icon);
        if Execute(FCatalogFile.CurrentFile, MovieList) then
          FCatalogFile.Modified := True;
      finally
        Release;
        PropertiesWin := nil;
      end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieSelGroupExecute(Sender: TObject);
var
  i: Integer;
  GroupItem: TElTreeItem;
begin
  with ListView1 do
    if (ItemFocused <> nil) and (ItemFocused.Data = nil) then
    begin
      GroupItem := ItemFocused;
      Items.BeginUpdate;
      if (not IsKeyDown(VK_CONTROL)) then
        DeselectAll;
      if not GroupItem.Expanded then
        GroupItem.Expanded := True;
      with GroupItem do
        for i := 0 to Count-1 do
        begin
          if SelectedCount = 0 then
            ListView1.ItemFocused := Item[i]
          else
            Item[i].Selected := True;
        end;
      Items.EndUpdate;
      ListView1EnsureVisiblePlus;
      ListView1AfterSelectionChange(nil);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieSelCheckExecute(Sender: TObject);
var
  i: Integer;
begin
  with ListView1 do
  begin
    FullExpandOrCollapse := True;
    Items.BeginUpdate;
    if (not IsKeyDown(VK_CONTROL)) then
      DeselectAll;
    with Items do
      for i := 0 to Count-1 do
        if (Item[i].Data <> nil) and (Item[i].Checked) and
          (not Item[i].Selected) then
        begin
          if (Items[i].Parent <> nil) and (not Items[i].Parent.Expanded) then
            Items[i].Parent.Expanded := True;
          if SelectedCount = 0 then
            ItemFocused := Items[i]
          else
            Items[i].Selected := True;
        end;
    Items.EndUpdate;
    FullExpandOrCollapse := False;
    ThumbsViewer.CalcView(True);
    ThumbsViewer.Invalidate;
    ListView1EnsureVisiblePlus;
    ListView1AfterSelectionChange(nil);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieSelUncheckExecute(Sender: TObject);
var
  i: Integer;
begin
  with ListView1 do
  begin
    FullExpandOrCollapse := True;
    Items.BeginUpdate;
    if (not IsKeyDown(VK_CONTROL)) then
      DeselectAll;
    with Items do
      for i := 0 to Count-1 do
        if (Item[i].Data <> nil) and (not Item[i].Checked) and
          (not Item[i].Selected) then
        begin
          if (Items[i].Parent <> nil) and (not Items[i].Parent.Expanded) then
            Items[i].Parent.Expanded := True;
          if SelectedCount = 0 then
            ItemFocused := Items[i]
          else
            Items[i].Selected := True;
        end;
    Items.EndUpdate;
    FullExpandOrCollapse := False;
    ThumbsViewer.CalcView(True);
    ThumbsViewer.Invalidate;
    ListView1EnsureVisiblePlus;
    ListView1AfterSelectionChange(nil);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieCheckExecute(Sender: TObject);
var
  i:integer;
begin
  ListView1.Items.BeginUpdate;
  with ListView1 do
    with Items do
      for i := 0 to Count-1 do
      begin
        if Item[i].Selected and not Item[i].Checked then
        begin
          Item[i].Checked := True;
          ListView1ItemChecked(nil, Item[i]);
        end;
      end;
  ListView1.Items.EndUpdate;
  SetStatus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieUncheckExecute(Sender: TObject);
var
  i:integer;
begin
  ListView1.Items.BeginUpdate;
  with ListView1 do
    with Items do
      for i := 0 to Count-1 do
      begin
        if Item[i].Selected and Item[i].Checked then
        begin
          Item[i].Checked := False;
          ListView1ItemChecked(nil, Item[i]);
        end;
      end;
  ListView1.Items.EndUpdate;
  SetStatus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieSelTaggedExecute(Sender: TObject);
var
  i: Integer;
  MnuItem: TTBXItem;
begin
  if Sender is TTBXItem then
    with ListView1 do
    begin
      MnuItem := TTBXItem(Sender);
      FullExpandOrCollapse := True;
      Items.BeginUpdate;
      if (not IsKeyDown(VK_CONTROL)) then
        DeselectAll;
      with Items do
        for i := 0 to Count-1 do
          if (Item[i].Data <> nil) and (TMovie(Item[i].Data).iColorTag = MnuItem.Tag) and
            (not Item[i].Selected) then
          begin
            if (Items[i].Parent <> nil) and (not Items[i].Parent.Expanded) then
              Items[i].Parent.Expanded := True;
            if SelectedCount = 0 then
              ItemFocused := Items[i]
            else
              Items[i].Selected := True;
          end;
      Items.EndUpdate;
      FullExpandOrCollapse := False;
      ThumbsViewer.CalcView(True);
      ThumbsViewer.Invalidate;
      ListView1EnsureVisiblePlus;
      ListView1AfterSelectionChange(nil);
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieTagSelectedExecute(Sender: TObject);
var
  i: Integer;
  MnuItem: TTBXItem;
begin
  if Sender is TTBXItem then
    with ListView1 do
    begin
      MnuItem := TTBXItem(Sender);
      Items.BeginUpdate;
      with Items do
        for i := 0 to Count-1 do
        begin
          if Item[i].Selected then
          begin
            ListView1ItemColorChange(MnuItem.Tag, Item[i]);
          end;
        end;
      Items.EndUpdate;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieNextExecute(Sender: TObject);
var
  NextItem: TElTreeItem;
begin
  with ListView1 do
  begin
    if Items.Count > 0 then
    begin
      FPrevFocused := ActiveControl;
      DeselectAll;
      if ItemFocused = nil then
        NextItem := Items.Item[0]
      else
        NextItem := ItemFocused.GetNext;
      if (NextItem <> nil) and (NextItem.Data = nil) then
        NextItem := NextItem.GetNext;
      if (NextItem <> nil) and (NextItem.Parent <> nil) and
        (not NextItem.Parent.Expanded) then
        NextItem.Parent.Expanded := True;
      ItemFocused := NextItem;
      ListView1EnsureVisiblePlus;
      ListView1AfterSelectionChange(ListView1);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMoviePreviousExecute(Sender: TObject);
var
  PrevItem: TElTreeItem;
begin
  with ListView1 do
  begin
    if Items.Count > 0 then
    begin
      FPrevFocused := ActiveControl;
      DeselectAll;
      if ItemFocused = nil then
        PrevItem := Items.Item[Items.Count-1]
      else
        PrevItem := ItemFocused.GetPrev;
      if (PrevItem <> nil) and (PrevItem.Data = nil) then
        PrevItem := PrevItem.GetPrev;
      if (PrevItem <> nil) and (PrevItem.Parent <> nil) and
        (not PrevItem.Parent.Expanded) then
        PrevItem.Parent.Expanded := True;
      ItemFocused := PrevItem;
      ListView1EnsureVisiblePlus;
      ListView1AfterSelectionChange(ListView1);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionURLOpenExecute(Sender: TObject);
var
  url: string;
begin
  url := '';
  if FSelectedURL <> nil then
    url := FSelectedURL.Text
  else
    url := FURL;
  if url <> '' then
  begin
    //SetCurrentDir(strDirApp);
    if FCatalogFile.CurrentFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    if FileExists(ExpandFileName(url)) then
      LaunchProg(ExpandFileName(url))
    else
      LaunchProg(url);
  end

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionURLBrowseExecute(Sender: TObject);
begin
  if FSelectedURL <> nil then
    with TOpenDialog.Create(Self) do
      try
        InitialDir := Settings.rOptions.rFolders[fuGetFromFiles].Value;
        if InitialDir <> '' then
          ClearLastVisitedMRU(Application.ExeName);
        FileName := '';
        Title := Messages.Strings[msgSelectFileURL];
        Options := DialogOpenOptions;
        Filter := DialogAnyFileFilter;
        if Execute then
        begin
          Settings.rOptions.rFolders[fuGetFromFiles].Value := ExtractFilePath(FileName);
          FSelectedURL.Text := FileName;
          HTMLViewerUpdate;
        end;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionURLCopyExecute(Sender: TObject);
begin
  if FSelectedURL <> nil then
    Clipboard.AsText := FSelectedURL.Text
  else if FURL <> '' then
    Clipboard.AsText := FURL;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionURLExploreExecute(Sender: TObject);
var
  url: string;
begin
  if FSelectedURL <> nil then
    url := FSelectedURL.Text
  else
    url := FURL;
  if url <> '' then
  begin
    //SetCurrentDir(strDirApp);
    if FCatalogFile.CurrentFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    LaunchExplorer(ExpandFileName(url));
  end
end;

{-------------------------------------------------------------------------------
   Events
-------------------------------------------------------------------------------}

procedure TMainWindow.OnFieldChange(Sender: TObject);
begin
  FCatalogFile.Modified := True;
  if (CurrentItem <> nil) then
    MakeMovieSave(CurrentItem.Data, True);
{ We don't update tree item here because is too slow when there are many items in tree.
  The item is updated later in this cases (call UpdateCurrentItemIfNeeded procedure) :
  - The user move the mouse on the tree
  - The user move the mouse on the left side of FrmMovie (X < 90).
  - The user press ENTER or ESCAPE in a field to force update.
    - ENTER is not take account for fields Description and Comments
  - The user press a header column of tree to sort items.
  - The user press stretch list button
  - The user paste a movie on the selected movie
  - The user cancel modifications
  - Others : Check in SaveCurrentItem function
  Edit: After some optimisations, we can now refresh item here without slowdown
  during input in most cases if this is wanted by user}
  if Settings.rOptions.rDisplay.ForceRefresh then
    UpdateCurrentItemIfNeeded;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnFieldPropertiesChange(Sender: TObject);
begin
  FCatalogFile.Modified := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnCustomFieldAdd(Sender: TObject);
begin
  OnCustomFieldModify(nil);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnCustomFieldModify(Sender: TObject);
var
  CustomFieldProperties: TCustomFieldProperties;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  CustomFieldProperties := nil;
  if (Sender <> nil) and (Sender is TPanelCustomField) then
    CustomFieldProperties := TPanelCustomField(Sender).Properties;
  Screen.Cursor := crHourGlass;
  try
    FrmMovieCustom.SaveFieldsProperties; // Save fields position, size, etc...
    SaveCurrentItem(False);
    SaveColumnSettings;
    FrmMovieCustom.SaveLists; // Save drop-down lists

    Application.CreateForm(TCustomFieldsManagerWin, CustomFieldsManagerWin);
    try
      ImageListHot.GetIcon(Ord(ICON_FIELDEDIT), CustomFieldsManagerWin.Icon);
      if CustomFieldsManagerWin.Execute(MovieList.CustomFieldsProperties,
        CustomFieldProperties) then
      begin
        PreGenerateHTMLTemplate;
        FrmMovieCustom.GenerateFields; // Regenerate fields after changes
        FrmMovieCustom.LoadLists; // Load drop-down lists
        if (CurrentItem <> nil) then
        begin
          FrmMovieCustom.LoadFromObject(TMovie(CurrentItem.Data));
          HTMLViewerUpdate;
        end;

        // Restore selected find field (check for deleted/added custom fields)
        FillFieldsCBFind(0);
        LoadFindField;
        // Restore field sort (check for deleted custom fields)
        FillFieldsSortBy;
        LoadSortField;
        // Restore field group (check for deleted custom fields)
        FillFieldsGroupBy;
        LoadGroupField;
        // Regenerate Grid Fields (check for deleted/added custom fields)
        FillFieldsGrid;

        FCatalogFile.Modified := True;
        RefreshMovieList(True, False);
      end;
    finally
      CustomFieldsManagerWin.Release;
      CustomFieldsManagerWin := nil;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnCustomFieldDelete(Sender: TObject);
begin
  OnCustomFieldModify(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnFieldValidate(Sender: TObject);
begin
  UpdateCurrentItemIfNeeded;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnExtrasBeforeChange(Sender: TObject);
begin
  //TODO: Add Extras ?
  //if (CurrentItem <> nil) then
  //  MakeMovieSave(CurrentItem.Data, True);
  if (CurrentItem <> nil) and (CurrentItem.Data <> nil) then
    FPreviousNbExtras := TMovie(CurrentItem.Data).Extras.Count;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnExtrasChange(Sender: TObject);
begin
  FCatalogFile.Modified := True;
  if (CurrentItem <> nil) and (CurrentItem.Data <> nil) then
  begin
    if (FPreviousNbExtras <> TMovie(CurrentItem.Data).Extras.Count) then
      UpdateCurrentItemIfNeeded;
    if HTMLTemplateContainsExtras then
      HTMLViewerUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (X <> FMouseMovieListX) or (Y <> FMouseMovieListY) then
  begin
    if (Settings.rOptions.rDisplay.AutoFocus) and
      (not ListView1.Focused) and ListView1.CanFocus then
      ListView1.SetFocus;
    UpdateCurrentItemIfNeeded;
    FMouseMovieListX := X;
    FMouseMovieListY := Y;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FrmMovieMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (X < 90) then
    UpdateCurrentItemIfNeeded;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FormShow(Sender: TObject);
var
  s, FileToOpen: string;
begin
  SplashWin.ProgressBar1.Position := 51;
  SplashWin.ProgressBar1.Position := 50;
  Application.ProcessMessages;
  LoadOptions;
  SplashWin.ProgressBar1.Position := 61;
  SplashWin.ProgressBar1.Position := 60;
  Application.ProcessMessages;
  ApplyLanguage;
  SplashWin.ProgressBar1.Position := 70;
  Application.ProcessMessages;
  SplashWin.Release;
  SplashWin := nil;
  FCatalogFile.Modified := False;
  with Settings.rOptions.rFiles do
    if (AutoLoad) and (AutoLoadFile <> '') then
      FileToOpen := AutoLoadFile
    else
      FileToOpen := '';
  if ParamCount > 0 then
  begin
    s := ParamStr(1);
    if (s <> '') and (s[1] <> '/') then
      FileToOpen := s;
  end;
  SetCurrentDir(strDirCatalogs);
  if (FileToOpen <> '') then
    if FileExists(ExpandFileName(FileToOpen)) then
      FCatalogFile.Open(ExpandFileName(FileToOpen))
    else
    begin
      FCatalogFile.New;
      MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [FileToOpen]), mtError, [mbOk]);
    end
  else
    FCatalogFile.New;
  CheckAnchorMovieExtras;
  if not ActionDisplayHTML.Checked then
    TabMovieInfos.Visible := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FormCreate(Sender: TObject);
var
  i : integer;
  RStream : TResourceStream;
begin
  Font.Name := Graphics.DefFontData.Name;
  Font.Charset := Graphics.DefFontData.Charset;
  {$IFDEF DISABLETHEMES}
  TBXSwitcher1.EnableXPStyles := False;
  TBXSwitcher1.FlatMenuStyle := fmsDisable;
  ToolbarFind.Color := clBtnFace;
  ToolbarMain.Color := clBtnFace;
  ToolbarMenu.Color := clBtnFace;
  ToolbarPicture.Color := clBtnFace;
  ToolbarPictureWindow.Color := clBtnFace;
  FrmMovieExtras.ToolbarExtras.Color := clBtnFace;
  ToolbarExtrasWindow.Color = clBtnFace;
  DockBottomList.Color := clBtnFace;
  DockImageLeft.Color := clBtnFace;
  DockImageTop.Color := clBtnFace;
  DockMainBottom.Color := clBtnFace;
  DockMainLeft.Color := clBtnFace;
  DockMainTop.Color := clBtnFace;
  DockRightInfo.Color := clBtnFace;
  FrmMovieExtras.DockExtrasTop.Color := clBtnFace;
  {$ENDIF}

  DragDropFiles := TJvDragDrop.Create(Self);
  DragDropFiles.OnDrop := DragDropFilesDropApp;
  DragDropFiles.AcceptDrag := True;

  CurrentItem := nil;
  MovieList := nil;
  MovieSave := nil;
  FGroupField := GroupNoneField;
  FSortField := fieldNumber + 1;
  GroupItemEmpty := nil;
  NbMoviesVisible := 0;
  NbMoviesChecked := 0;
  NbMoviesSelected := 0;
  NbGroupsSelected := 0;
  FSelectedURL := nil;
  FURL := '';
  FMouseMovieListX := 0;
  FMouseMovieListY := 0;
  FMouseHTMLViewerX := 0;
  FMouseHTMLViewerY := 0;
  FPrevFocused := nil;
  FPreviousNbExtras := 0;

  FCatalogFile := TFileManager.Create(Self);
  FCatalogFile.OnFileChange := OnFileChange;
  FCatalogFile.OnFileModified := OnFileModified;
  FCatalogFile.OnNewFile := OnNewFile;
  FCatalogFile.OnOpenFile := OnOpenFile;
  FCatalogFile.OnBeforeSaveFile := OnBeforeSaveFile;
  FCatalogFile.OnSaveFile := OnSaveFile;
  with FCatalogFile do
  begin
    with OpenDialog do
    begin
      Filter := DialogCatalogFilter;
      Options := DialogOpenOptions;
    end;
    with SaveDialog do
    begin
      Filter := DialogCatalogSaveFilter;
      Options := DialogSaveOptions;
      OnTypeChange := Self.OnDialogTypeChange;
    end;
  end;
  FCurrentVersion := 99;

  ActionFileNew.ImageIndex := Ord(ICON_FILENEW);
  ActionFileOpen.ImageIndex := Ord(ICON_FILEOPEN);
  ActionFileSave.ImageIndex := Ord(ICON_FILESAVE);
  ActionFileSaveAs.ImageIndex := Ord(ICON_FILESAVEAS);
  ActionFileImport.ImageIndex := Ord(ICON_FILEIMPORT);
  ActionFileExport.ImageIndex := Ord(ICON_FILEEXPORT);
  ActionFilePrint.ImageIndex := Ord(ICON_FILEPRINT);
  ActionFileProperties.ImageIndex := Ord(ICON_FILEPROPERTIES);
  ActionExit.ImageIndex := Ord(ICON_EXIT);
  ActionMovieAdd.ImageIndex := Ord(ICON_MOVIEADD);
  ActionMovieNumber.ImageIndex := Ord(ICON_MOVIENUMBER);
  ActionMovieCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  ActionMoviePaste.ImageIndex := Ord(ICON_MOVIEPASTE);
  ActionMovieDelete.ImageIndex := Ord(ICON_MOVIEDELETE);
  ActionMovieFind.ImageIndex := Ord(ICON_MOVIEFIND);
  ActionMovieUndo.ImageIndex := Ord(ICON_MOVIEUNDO);
  ActionMoviePictureShow.ImageIndex := Ord(ICON_MOVIEPICTURE);
  ActionMovieExtrasShow.ImageIndex := Ord(ICON_MOVIEEXTRAS);
  ActionMovieURL.ImageIndex := Ord(ICON_MOVIEURL);
  ActionMovieFilePath.ImageIndex := Ord(ICON_MOVIEURL);
  ActionMenuPicture.ImageIndex := Ord(ICON_MOVIEPICTURE);
  ActionMenuGet.ImageIndex := Ord(ICON_MOVIEIMPORT);
  ActionMenuGroup.ImageIndex := Ord(ICON_GROUP);
  ActionMenuGroupsFormat.ImageIndex := Ord(ICON_GROUPSFORMAT); 
  ActionMenuSort.ImageIndex := Ord(ICON_SORTASCEND);
  ActionMenuGridFields.ImageIndex := Ord(ICON_GRIDMODE);
  ActionMovieImportFiles.ImageIndex := Ord(ICON_MOVIEIMPORTFILES);
  ActionMovieImportCD.ImageIndex := Ord(ICON_MOVIEIMPORTCD);
  ActionMovieImportScript.ImageIndex := Ord(ICON_MOVIEIMPORTSCRIPT);
  ActionMovieSearch.ImageIndex := Ord(ICON_MOVIESEARCH);
  ActionMovieStats.ImageIndex := Ord(ICON_STATISTICS);
  ActionHelpAbout.ImageIndex := Ord(ICON_ABOUT);
  ActionHelpIndex.ImageIndex := Ord(ICON_HELP);
  ActionLoan.ImageIndex := Ord(ICON_LOANS);
  ActionToolsScripting.ImageIndex := Ord(ICON_SCRIPTING);
  ActionToolsGrid.ImageIndex := Ord(ICON_GRIDMODE);
  ActionMovieRenumber.ImageIndex := Ord(ICON_RENUMBER);
  ActionOptions.ImageIndex := Ord(ICON_OPTIONS);
  ActionLanguage.ImageIndex := Ord(ICON_LANGUAGES);
  ActionRefresh.ImageIndex := Ord(ICON_REFRESH);
  ActionPicSelect.ImageIndex := Ord(ICON_PICTUREOPEN);
  ActionPicDelete.ImageIndex := Ord(ICON_PICTUREDELETE);
  ActionPicUndock.ImageIndex := Ord(ICON_PICTUREUNDOCK);
  ActionPicSaveAs.ImageIndex := Ord(ICON_PICTURESAVE);
  ActionPicCopy.ImageIndex := Ord(ICON_PICTURECOPY);
  ActionPicPaste.ImageIndex := Ord(ICON_MOVIEPASTE);
  ActionMovieRandom.ImageIndex := Ord(ICON_RANDOM);
  ActionStretchList.ImageIndex := Ord(ICON_STRETCHLIST);
  ActionDisplayHTML.ImageIndex := Ord(ICON_HTML);
  ActionSelectHTML.ImageIndex := Ord(ICON_HTML);
  ActionDisplayThumbnails.ImageIndex := Ord(ICON_VIEWTHUMBNAILS);
  ActionManageFields.ImageIndex := Ord(ICON_FIELDEDIT);
  ActionManagePictures.ImageIndex := Ord(ICON_MOVIEPICTURE);
  ActionHTMLEditor.ImageIndex := Ord(ICON_HTML);

  ActionURLOpen.ImageIndex := Ord(ICON_MOVIEURL);
  ActionURLExplore.ImageIndex := Ord(ICON_BROWSE);
  ActionURLCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  ActionURLBrowse.ImageIndex := Ord(ICON_FILEOPEN);

  MnuHtmlCopy.ImageIndex := Ord(ICON_MOVIECOPY);
  MnuHtmlEdit.ImageIndex := Ord(ICON_HTML);
  MnuTlsBrowseHTML.ImageIndex := Ord(ICON_FILEOPEN);

  FillImageListColorsTag;

  Settings.version := StrVersion;
  Application.OnHelp := OnAppHelp;
  FrmMovie.OnFieldChange := Self.OnFieldChange;
  FrmMovie.OnFieldValidate := Self.OnFieldValidate;
  FrmMovie.OnURLButtonClick := Self.OnURLButtonClick;
  FrmMovie.OnURLEnter := Self.OnURLEnter;
  FrmMovieCustom.OnFieldChange := Self.OnFieldChange;
  FrmMovieCustom.OnFieldPropertiesChange := Self.OnFieldPropertiesChange;
  FrmMovieCustom.OnFieldAdd := Self.OnCustomFieldAdd;
  FrmMovieCustom.OnFieldModify := Self.OnCustomFieldModify;
  FrmMovieCustom.OnFieldDelete := Self.OnCustomFieldDelete;
  FrmMovieCustom.OnFieldValidate := Self.OnFieldValidate;
  FrmMovieCustom.OnURLButtonClick := Self.OnURLButtonClick;
  FrmMovieCustom.OnURLEnter := Self.OnURLEnter;
  FrmMovieExtras.OnExtrasBeforeChange := Self.OnExtrasBeforeChange;
  FrmMovieExtras.OnExtrasChange := Self.OnExtrasChange;
  MStream := TMemoryStream.Create;
  HTMLTemplatePreGenerated := TStringList.Create;
  HTMLTemplateFileRef := '';
  HTMLTemplateContainsChecked := False;
  HTMLTemplateContainsColorTag := False;
  HTMLTemplateContainsExtras := False;
  HTMLDisplayExcludedTemplates := TStringList.Create;
  HTMLDisplayExcludedTemplates.Sorted := True;
  HTMLDisplayExcludedTemplates.CaseSensitive := False;
  HTMLDisplayExcludedTemplatesModifiedDate := 0;

  for i := 0 to High(MStreamAppr) do
    MStreamAppr[i] := nil;

  for i := 0 to High(MStreamAppr10) do
    MStreamAppr10[i] := nil;

  {ThumbsViewer}
  ThumbJPEG := TJpegImage.Create;
  ThumbJPEG.CompressionQuality := 80;
  ThumbJPEG.Performance := jpBestSpeed;
  ThumbGIF := TJvGIFImage.Create;
  ThumbPNG := TPNGObject.Create;
  ThumbBMP := TBitmap.Create;
  ThumbLoading := TBitmap.Create;
  ThumbLoading.TransparentColor := clWhite;
  ThumbLoading.Transparent := True;
  try
    RStream := TResourceStream.Create( HInstance, 'Loading', 'BMP' );
    try
      ThumbLoading.LoadFromStream(RStream);
    finally
      RStream.Free;
    end;
  except
    FreeAndNil(ThumbLoading);
  end;
  // Max thumbnail size...
  ThumbSizeW := Trunc(255*0.75);
  ThumbSizeH := 255;
  ThumbsViewer.CellWidth := ThumbSizeW + 10;
  ThumbsViewer.CellHeight := ThumbSizeH + 30;
  CellJpeg := TJpegImage.Create;
  CellJPEG.Performance := jpBestSpeed;
  GenCellColors;
  CellStyle := 1;
  PoolSize := 0;
  MaxPool := Round((Screen.Width * Screen.Height) * 1.5);
  ThumbsPool := TList.Create;
  FullExpandOrCollapse := False;
  TimeUpdateView := Now;
  ThumbCheckboxOver := -1;
  ThumbCheckboxClick := False;
  {End ThumbsViewer}

  // Register TPNGObject to read PNG in TPicture...
  TPicture.RegisterFileFormat('PNG', 'Portable Network Graphics', TPNGObject);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  {ThumbsViewer}
  ThumbsViewerStop;
  ThumbJPEG.Free;
  ThumbGIF.Free;
  ThumbPNG.Free;
  ThumbBMP.Free;
  ThumbLoading.Free;
  CellJpeg.Free;
  ThumbsPool.Free;
  {End ThumbsViewer}

  MovieList.Free;
  MovieSave.Free;
  FCatalogFile.Free;
  DragDropFiles.Free;
  MStream.Free;
  for i := 0 to High(MStreamAppr) do
    MStreamAppr[i].Free;
  for i := 0 to High(MStreamAppr10) do
    MStreamAppr10[i].Free;
  HTMLTemplatePreGenerated.Free;
  HTMLDisplayExcludedTemplates.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveOptions;
  ListView1.DeselectAll;
  CurrentItem := nil;
  ListView1AfterSelectionChange(nil);
  ThumbsViewerStop;
  Application.ProcessMessages;
  if FrmMovieExtras.PanelMovieExtras.Parent = ToolbarExtrasWindow then
  begin
    ToolbarExtrasWindow.RemoveControl(FrmMovieExtras.PanelMovieExtras);
    FrmMovieExtras.InsertControl(FrmMovieExtras.PanelMovieExtras);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  SaveColumnSettings;
  SaveLists; // Save drop-down lists
  SetSaveFilter;
  with Settings.rOptions.rFiles do
    if AutoLoadLast then
      AutoLoadFile := FCatalogFile.CurrentFile;
  CanClose := FCatalogFile.Close;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1CompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
var
  Field, i1, i2: Integer;
  FieldType: TFieldType;
  Movie1, Movie2: TMovie;
  ItemTmp: TElTreeItem;
begin
  if (ListView1.SortSection > -1) and (ListView1.SortSection < ListView1.HeaderSections.Count)
    and (ListView1.HeaderSections.Item[ListView1.SortSection].SortMode = hsmDescend) then
  begin
    ItemTmp := Item1;
    Item1 := Item2;
    Item2 := ItemTmp;
  end;
  if Item1 = Item2 then
    res := 0
  else
  if ((Item1.Data = nil) or (Item2.Data = nil)) then
  begin
    with Settings.rOptions.rMovieList do
    begin
      if (Item1.Data = nil) and (Item2.Data <> nil) then
        if GroupsAbove then res := -1 else res := 1
      else
      if (Item1.Data <> nil) and (Item2.Data = nil) then
        if GroupsAbove then res := 1 else res := -1
      else
      if StartsStr(strErrorParenthesis, Item1.Text) then
        if GroupsAbove then res := 1 else res := -1
      else
      if StartsStr(strErrorParenthesis, Item2.Text) then
        if GroupsAbove then res := -1 else res := 1
      else
      if StartsStr(Messages.Strings[msgGroupEmpty], Item1.Text) then
        if GroupsAbove then res := 1 else res := -1
      else
      if StartsStr(Messages.Strings[msgGroupEmpty], Item2.Text) then
        if GroupsAbove then res := -1 else res := 1
      else
      if StartsStr(Messages.Strings[msgGroupUnique], Item1.Text) then
        if GroupsAbove then res := 1 else res := -1
      else
      if StartsStr(Messages.Strings[msgGroupUnique], Item2.Text) then
        if GroupsAbove then res := -1 else res := 1
      else
      begin
        res := 0;
        if SortGroupsByCount then
        begin
          res := CompareValue(Item2.Count, Item1.Count);
        end;
        if res = 0 then
        begin
          if (FGroupField < fieldCount) or ((FGroupField >= customFieldLow) and
            (FGroupField - customFieldLow < MovieList.CustomFieldsProperties.Count)) or
            (FGroupField in AllExtraFields) then
          begin
            if (FGroupField < fieldCount) or (FGroupField in AllExtraFields) then
              FieldType := GetFieldType(FGroupField)
            else
              FieldType := MovieList.CustomFieldsProperties.Objects[FGroupField - customFieldLow].FieldType;
            // Group names can have been formatted to another datatype so we have to take this into account.
            case FieldType of
              //ftInteger: res := StrToIntTrunc(Item1.Text, 0) - StrToIntTrunc(Item2.Text, 0);
              ftInteger, ftReal, ftReal1, ftReal2: res := CompareValue(StrToFloatTrunc(Item1.Text, 0), StrToFloatTrunc(Item2.Text, 0));
              //ftDate: res := Trunc(StrToDateDef(TextBefore(Item1.Text, ' ('), 0)) - Trunc(StrToDateDef(TextBefore(Item2.Text, ' ('), 0));
              ftDate:
              begin
                i1 := Trunc(StrToDateDef(TextBefore(Item1.Text, ' ('), 0));
                i2 := Trunc(StrToDateDef(TextBefore(Item2.Text, ' ('), 0));
                if (i1 <> 0) and (i2 <> 0) then
                  res := CompareValue(i1, i2);
              end;
            end;
            if res = 0 then
              if Settings.rOptions.rDisplay.NaturalCompare then
                res := AnsiNatCompareText(Item1.Text, Item2.Text)
              else
                res := AnsiCompareText(Item1.Text, Item2.Text);
          end;
        end;
      end;
    end;
  end else
  begin
    if(FSortField < 0) then
    begin
      ItemTmp := Item1;
      Item1 := Item2;
      Item2 := ItemTmp;
    end;
    with ListView1 do
    begin
      Field := Abs(FSortField) - 1;
      Movie1 := Item1.Data;
      Movie2 := Item2.Data;
      res := 0;
      if Field = SortAdvancedField then
      begin
        CompareAdvInit(Settings.rMain.SortAdvancedFields);
        res := CompareAdv(Movie1, Movie2);
      end
      else if Field <> fieldFormattedTitle then
      begin
        CompareStdInit(Field);
        res := CompareStd(Movie1, Movie2);
      end;
      if res = 0 then
        if Settings.rOptions.rDisplay.NaturalCompare then
          res := AnsiNatCompareText(Item1.Text, Item2.Text)
        else
          res := AnsiCompareText(Item1.Text, Item2.Text);
      if res = 0 then
        res := CompareValue(Movie1.iNumber, Movie2.iNumber);
      if res = 0 then
        res := CompareStr(Format('%p', [Item1.Data]), Format('%p', [Item2.Data]));
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1Resize(Sender: TObject);
begin
  with ListView1 do
    if HeaderSections.Item[1].Visible then
      HeaderSections.Item[1].Width := ClientWidth - IfThen(HeaderSections.Item[0].Visible, HeaderSections.Item[0].Width) - IfThen(VertScrollBarVisible and Settings.rOptions.rMovieList.EnhancedScrollbars, VertScrollBarStyles.Width);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1HeaderColumnResize(Sender: TObject;
  SectionIndex: Integer);
begin
  ListView1Resize(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemChecked(Sender: TObject;
  Item: TElTreeItem);
var
  i: Integer;
  _listItems: TObjectList;
  oldSortMode: TSortModes;
begin
  if (Item <> nil) and (Item.Data <> nil) then
  begin
    if (SelectedItem <> CurrentItem) then // Force synchronize
      ListView1AfterSelectionChange(nil);
    if (CurrentItem <> nil) and (CurrentItem = Item) then
      MakeMovieSave(Item.Data, True);
    if Item.Checked then
      Inc(NbMoviesChecked)
    else
      Dec(NbMoviesChecked);
    TMovie(Item.Data).bChecked := Item.Checked;
    FCatalogFile.Modified := True;
    oldSortMode := ListView1.SortMode; // Remove automatic sort because is uncomfortable for user
    ListView1.SortMode := smNone;

    ListView1.Items.BeginUpdate;
    _listItems := TMovie(Item.Data)._listItems;
    for i := 0 to _listItems.Count-1 do
    begin
      if ActionToolsGrid.Checked then
        TElTreeItem(_listItems.Items[i]).SubItems.Strings[fieldChecked+2] := BoolToStr(Item.Checked, True);
      //else
        //TElTreeItem(_listItems.Items[i]).SubItems.Strings[1] := ''; // Hidden column for other field sort; Needed to force automatic sort on item
      TElTreeItem(_listItems.Items[i]).Checked := Item.Checked;
    end;
    ListView1.Items.EndUpdate;
    ThumbsViewer.Invalidate; // If ThumbsViewer show checked movies

    ListView1.SortMode := oldSortMode; // Restore old sort mode
    if (CurrentItem <> nil) and (CurrentItem = Item) and
      (HTMLTemplateContainsChecked) then
      HTMLViewerUpdate;
    if Sender <> nil then
      SetStatus;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemColorPick(Sender: TObject; Item: TElTreeItem);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (Item <> nil) and (Item.Data <> nil) then
    with TMovie(Item.Data), Settings.rOptions.rMovieList do
      if CheckboxesColor then
        ListView1ItemColorChange(iColorTag + 1, Item);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemColorChange(newColorTag: Integer; Item: TElTreeItem);
var
  i: Integer;
  oldSortMode: TSortModes;
begin
  if (Item <> nil) and (Item.Data <> nil) then
  begin
    if (SelectedItem <> CurrentItem) then // Force synchronize
      ListView1AfterSelectionChange(nil);
    if (CurrentItem <> nil) and (CurrentItem = Item) then
      MakeMovieSave(Item.Data, True);
    with TMovie(Item.Data), Settings.rOptions.rMovieList do
    begin
      iColorTag := (newColorTag) mod Length(DefaultColorsTag);
      oldSortMode := ListView1.SortMode;
      ListView1.SortMode := smNone; // Remove automatic sort because is uncomfortable for user

      FCatalogFile.Modified := True;
      if CheckboxesColor then // CheckBoxColor
        Item.CheckBoxColor := ColorsTag[iColorTag];
      if LinesColor then // LineColor
      begin
        Item.RowBkColor := ColorsTag[iColorTag];
        Item.BkColor := Item.RowBkColor;
      end;

      ListView1.Items.BeginUpdate;
      for i := 0 to _listItems.Count-1 do
      begin
        if ActionToolsGrid.Checked then
          TElTreeItem(_listItems.Items[i]).SubItems.Strings[fieldColorTag+1] := IntToStr(iColorTag);
        //else
          //TElTreeItem(_listItems.Items[i]).SubItems.Strings[1] := ''; // Hidden column for other field sort; Needed to force automatic sort on item
        if CheckboxesColor then
          TElTreeItem(_listItems.Items[i]).CheckBoxColor := Item.CheckBoxColor;
        if LinesColor then
        begin
          TElTreeItem(_listItems.Items[i]).RowBkColor := Item.RowBkColor;
          TElTreeItem(_listItems.Items[i]).BkColor := Item.BkColor;
        end;
      end;
      ListView1.Items.EndUpdate;
      ThumbsViewer.Invalidate; // If ThumbsViewer show tags color of movies

      //Item.Hint := 'Tag ' + IntToStr(iColorTag);
      //SetCapture(Self.Handle); ReleaseCapture; // Update Hint value
      ListView1.SortMode := oldSortMode; // Restore old sort mode
      if (CurrentItem <> nil) and (CurrentItem = Item) and
        (HTMLTemplateContainsColorTag) then
        HTMLViewerUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1AfterSelectionChange(Sender: TObject);
begin
  if Sender = nil then
  begin
    TimerAfterSelectEvent(nil);
  end else
  begin
    TimerAfterSelect.Enabled := False;
    TimerAfterSelect.Enabled := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.TimerAfterSelectEvent(Sender: TObject);
begin
  TimerAfterSelect.Enabled := False;
  SaveCurrentItem;
  OpenItem(SelectedItem);
  MovieSelected;
  if (FPrevFocused <> nil) and FPrevFocused.Enabled and FPrevFocused.Visible then
  begin
    FocusControl(FPrevFocused);
    if (FPrevFocused is TEdit) then
      TEdit(FPrevFocused).SelectAll
    else if (FPrevFocused is TComboBox) then
      TComboBox(FPrevFocused).SelectAll
    else if (FPrevFocused is TAntJvSpinEdit) then
      TAntJvSpinEdit(FPrevFocused).SelectAll
    else if (FPrevFocused is TAntJvComboEditXP) then
      TAntJvComboEditXP(FPrevFocused).SelectAll;
    //else if (prevFocused is TMemo) then
    //  TMemo(prevFocused).SelectAll;
    FPrevFocused := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemSelectedChange(Sender: TObject;
  Item: TElTreeItem);
var
  selected: Boolean;
  movie: TMovie;
  j: Integer;
  iData: Int64;
begin
  ListView1.OnAfterSelectionChange := nil;
  ListView1.OnItemSelectedChange := nil;
  ThumbsViewer.OnCellSelectedChange := nil;
  ThumbsViewer.OnSelecting := nil;
  selected := Item.Selected;
  if (Item.Data <> nil) then
  begin
    movie := TMovie(Item.Data);
    if selected then
      Inc(NbMoviesSelected)
    else
      Dec(NbMoviesSelected);
    if (Sender <> ThumbsViewer) and
      ((ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0)) then
    begin
      iData := ULong(Pointer(movie));
      if selected then
      begin
        if ThumbsViewer.IndexOfSelection(iData) = -1 then
          if Item.Parent <> nil then
            ThumbsViewer.AddSelection(iData, Item.Parent.Index, Item.Index)
          else
            ThumbsViewer.AddSelection(iData, -1, Item.Index);
      end
      else
      begin
        j := ThumbsViewer.IndexOfSelection(iData);
        if j <> -1 then
          ThumbsViewer.DeleteSelection(j);
      end;
    end;
    if selected then // Keep the good selected item selected by user
      movie._selectedItem := Item;
    for j := 0 to movie._listItems.Count-1 do
    begin
      if TElTreeItem(movie._listItems.Items[j]).Selected <> selected Then
        TElTreeItem(movie._listItems.Items[j]).Selected := selected;
    end;
    if (NbMoviesSelected = 0) and (not selected) and (movie._listItems.Count > 1) then
    begin // Put the good last selected item selected by user (= ListView1.Selected)
      Item.Selected := True;
      Item.Selected := False;
    end;
  end else
  begin
    if selected then
      Inc(NbGroupsSelected)
    else
      Dec(NbGroupsSelected);
    if (Sender <> ThumbsViewer) and
      ((ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0)) then
    begin
      iData := (-1-Item.Index);
      if selected then
      begin
        if ThumbsViewer.IndexOfSelection(iData) = -1 then
          ThumbsViewer.AddSelection(iData, Item.Index, -1);
      end
      else
      begin
        j := ThumbsViewer.IndexOfSelection(iData);
        if j <> -1 then
          ThumbsViewer.DeleteSelection(j);
      end;
    end;
  end;

  if NbMoviesSelected = 1 then
  begin // Take the good selected item selected by user
    SelectedItem := ListView1.Selected;
    if (SelectedItem = nil) or (SelectedItem.Data = nil) then
    begin
      SelectedItem := nil;
      repeat
        SelectedItem := ListView1.GetNextSelected(SelectedItem)
      until (SelectedItem = nil) or (SelectedItem.Data <> nil);
    end;
    SelectedItem := TElTreeItem(TMovie(SelectedItem.Data)._selectedItem);
  end
  else
    SelectedItem := nil;

  //Self.Caption := IntToStr(NbMoviesSelected)+':'+IntToStr(NbGroupsSelected);
  ListView1.OnAfterSelectionChange := ListView1AfterSelectionChange;
  ListView1.OnItemSelectedChange := ListView1ItemSelectedChange;
  ThumbsViewer.OnCellSelectedChange := ThumbsViewerCellSelectedChange;
  ThumbsViewer.OnSelecting := ThumbsViewerSelecting;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemFocused(Sender: TObject);
var
  Item: TElTreeItem;
begin
  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
  begin
    Item := ListView1.ItemFocused;
    if (Item = nil) then
    begin
      ThumbsViewer.IdxGrp := -1;
      ThumbsViewer.IdxItem := -1;
    end
    else if (Item.Data <> nil) then
    begin
      if Item.Parent <> nil then
      begin
        ThumbsViewer.IdxGrp := Item.Parent.Index;
        ThumbsViewer.IdxItem := Item.Index;
      end
      else
      begin
        ThumbsViewer.IdxGrp := -1;
        ThumbsViewer.IdxItem := Item.Index;
      end;
    end
    else
    begin
        ThumbsViewer.IdxGrp := Item.Index;
        ThumbsViewer.IdxItem := -1;
    end;
    ThumbsViewerEnsureVisiblePlus;
    ThumbsViewer.Invalidate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemCollapse(Sender: TObject;
  Item: TElTreeItem);
begin
  if (Item.Index < ThumbsViewer.SmartGroups.Count) and
    (PSmartGroup(ThumbsViewer.SmartGroups.Items[Item.Index]).Expanded) then
  begin
    PSmartGroup(ThumbsViewer.SmartGroups.Items[Item.Index]).Expanded := False;
    if (not FullExpandOrCollapse) then
    begin
      ThumbsViewer.CalcView(True);
      ThumbsViewer.Invalidate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1ItemExpand(Sender: TObject;
  Item: TElTreeItem);
begin
  if (Item.Index < ThumbsViewer.SmartGroups.Count) and
    (not PSmartGroup(ThumbsViewer.SmartGroups.Items[Item.Index]).Expanded) then
  begin
    PSmartGroup(ThumbsViewer.SmartGroups.Items[Item.Index]).Expanded := True;
    if (not FullExpandOrCollapse) then
    begin
      ThumbsViewer.CalcView(True);
      ThumbsViewer.Invalidate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Key = Ord('A')) and (Shift = [ssCtrl]) then
  begin
    ListView1.SelectAll;
    ListView1AfterSelectionChange(nil);
    ThumbsViewer.Invalidate;
  end
  else
  if (Key = VK_DELETE) and (Shift = []) then
    ActionMovieDelete.Execute
  else if (Key = VK_INSERT) and (Shift = []) then
    ActionMovieAdd.Execute
  else if (Key = Ord('C')) and (Shift = [ssCtrl]) then
    ActionMovieCopy.Execute
  else if (Key = Ord('V')) and (Shift = [ssCtrl]) then
    ActionMoviePaste.Execute
  else
  if ((Key = Ord('T')) and (Shift = [ssCtrl])) or
    ((Key = VK_MULTIPLY) and (Shift = [])) or ((Key = VK_ADD) and (Shift = [ssCtrl])) then
  begin
    FullExpandOrCollapse := True;
    ListView1.FullExpand;
    FullExpandOrCollapse := False;
    ListView1EnsureVisiblePlus;
    ThumbsViewer.CalcView(True);
    ThumbsViewer.Invalidate;
    ThumbsViewerEnsureVisiblePlus;
  end else
  if ((Key = Ord('T')) and (Shift = [ssCtrl, ssShift])) or
    ((Key = VK_SUBTRACT) and (Shift = [ssCtrl])) then
  begin
    FullExpandOrCollapse := True;
    ListView1.FullCollapse;
    FullExpandOrCollapse := False;
    ListView1EnsureVisiblePlus;
    ThumbsViewer.CalcView(True);
    ThumbsViewer.Invalidate;
    ThumbsViewerEnsureVisiblePlus;
  end else
  if (Key = VK_SPACE) and ((Shift = []) or (Shift = [ssCtrl])) then
    with ListView1 do
      if ItemFocused <> nil then
      begin
        ItemFocused.Checked := not ItemFocused.Checked;
        ListView1ItemChecked(Sender, ItemFocused);
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnCancelDragDrop;
begin
  FCancelDragDrop := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DragDropFilesDropApp(Sender: TObject; Pos: TPoint;
  Value: TStringList);
var
  pt, pt1, pt2: TPoint;
  //pt3, pt4: TPoint;

begin
  pt := Self.ClientToScreen(Pos);
  pt1.X := 0;
  pt1.Y := 0;
  pt2.X := FrmMovieExtras.PanelMovieExtras.Width;
  pt2.Y := FrmMovieExtras.PanelMovieExtras.Height;
  pt1 := FrmMovieExtras.PanelMovieExtras.ClientToScreen(pt1);
  pt2 := FrmMovieExtras.PanelMovieExtras.ClientToScreen(pt2);
  //pt3.X := 0;
  //pt3.Y := 0;
  //pt4.X := PanelLeft.Width;
  //pt4.Y := PanelLeft.Height;
  //pt3 := PanelLeft.ClientToScreen(pt3);
  //pt4 := PanelLeft.ClientToScreen(pt4);

  if (pt.X >= pt1.X) and (pt.X < pt2.X) and (pt.Y >= pt1.Y) and (pt.Y < pt2.Y) and
     ((TabMovieInfos.Visible and (TabMovieInfos.TabIndex = 3)) or
      (ToolbarExtrasWindow.Visible)) then
  begin
    FrmMovieExtras.DragDropFilesDrop(Sender, Pos, Value);
  end
  else //if (pt.X >= pt3.X) and (pt.X < pt4.X) and (pt.Y >= pt3.Y) and (pt.Y < pt4.Y) then
  begin
    DragDropFilesDrop(Sender, Pos, Value);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DragDropFilesDrop(Sender: TObject; Pos: TPoint;
  Value: TStringList);
var
  FileName, Ext, PicPath: string;
  i: Integer;
  DoNotAsk, Multiple: Boolean;
  PicImportMethod: TPictureSelectOption;
  AddedMovies: TObjectList;
  Media: TMedia;
  MediaFilter: TMediaFilter;
  OpenCatalog: Boolean;

  function AddNewMovie: Boolean;
  var
    OldCurrentItem: TElTreeItem;
  begin
    Result := False;
    OldCurrentItem := CurrentItem;
    ActionMovieAddExecute(nil);
    if (OldCurrentItem = CurrentItem) or (CurrentItem = nil) then
      FCancelDragDrop := True
    else
      AddedMovies.Add(CurrentItem);
  end;

begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);

  if Value.Count = 0 then
    Exit;

  OpenCatalog := False;
  if (CurrentItem = nil) then
    Multiple := True
  else
  begin
    MakeMovieSave(CurrentItem.Data, True);
    Multiple := False;
  end;
  Media := TMedia.Create;
  MediaFilter := TMediaFilter.Create;
  AddedMovies := TObjectList.Create(False);

  Application.ProcessMessages;
  ProgressWin.Status := Messages.Strings[msgDragDropFiles] + ' (' + IntToStr(Value.Count) + ')';
  ProgressWin.Maximum := Value.Count;
  ProgressWin.AutoUpdateTextProgress := False;
  ProgressWin.IntProgress := 0;
  ProgressWin.Progress := '';
  ProgressWin.Execute(Self);
  ProgressWin.OnCancel := OnCancelDragDrop;
  FCancelDragDrop := False;
  try
    with Settings.rOptions.rMovieInformation do
    begin
      PicImportMethod := TPictureSelectOption(Abs(rPicImport.GetInfoMethod));
      if rPicImport.GetInfoMethod <= 0 then
        for i := 0 to Value.Count-1 do
        begin
          FileName := Value.Strings[i];
          Ext := LowerCase(ExtractFileExt(FileName));
          if (IndexText(Ext, extImage) <> -1) or
             ( (ImportPicture or SameText(ext, '.film')) and
               (FileExists(ChangeFileExt(FileName, '.jpg')) or
                FileExists(ChangeFileExt(FileName, '.jpeg')) or
                FileExists(ChangeFileExt(FileName, '.jpe')) or
                FileExists(ChangeFileExt(FileName, '.png')) or
                FileExists(ChangeFileExt(FileName, '.gif')) or
                FileExists(ChangeFileExt(FileName, '.bmp'))) ) then
          begin
            with TPictureDragDropWin.Create(Application) do
              try
                ImageListHot.GetIcon(Ord(ICON_PICTUREOPEN), Icon);
                if not Execute(PicImportMethod, DoNotAsk) then
                  FCancelDragDrop := True
                else
                begin
                  rPicImport.GetInfoMethod := Integer(PicImportMethod);
                  if not DoNotAsk then
                    rPicImport.GetInfoMethod := - rPicImport.GetInfoMethod;
                end;
              finally
                Release;
              end;
            break;
          end;
        end;
    end;
    i := 0;
    while (i < Value.Count) and (not FCancelDragDrop) do
    begin
      //ProgressWin.Status := Messages.Strings[msgDragDropFiles] + '(' + IntToStr(i+1) + '/' + IntToStr(Value.Count) + ')';
      ProgressWin.IntProgress := i;
      ProgressWin.Progress := ExtractFileName(Value.Strings[i]);

      FileName := Value.Strings[i];
      ext := LowerCase(ExtractFileExt(FileName));

      // **** Catalog ****
      if IndexText(ext, extCatalog) <> -1 then
      begin
        if Value.Count = 1 then
          OpenCatalog := True;
      end else

      // **** Import something ****
      begin

        // **** Picture ***
        if IndexText(ext, extImage) <> -1 then
        begin
          if Multiple then
            AddNewMovie;
          if (not FCancelDragDrop) and (CurrentItem <> nil) then
          begin
            if ActionPicSelect.Enabled then
              if not FCancelDragDrop then
              begin
                StopThumbThread;
                ImportMoviePicture(CurrentItem.Data, FileName, PicImportMethod);
                LoadMoviePicture;
                ThumbsViewerStart;
                HTMLViewerUpdate;
                MovieSelected;
              end;
          end;
        end else

        // **** Video ****
        if (IndexText(Ext, extVideo) <> -1) or
          ((Ext <> '') and (AnsiPos(Ext+' ', Settings.rOptions.rMovieInformation.ImportExt+' ') > 0)) then
        begin
          if Multiple then
            AddNewMovie;
          if (not FCancelDragDrop) and (CurrentItem <> nil) then
          begin
            try
              Media.InitValues;
              with Settings.rOptions.rMovieInformation do
              begin
                GetDefaultMediaFilter(MediaFilter, MovieList.CustomFieldsProperties);
                try
                  StartGetMediaThread(FileName, Media, ImportInternalAVI, ImportSizeUnit, MediaFilter, False);
                  while (FCancelDragDrop = False) and (GetMediaThrDone = False) do
                    Application.ProcessMessages;
                finally
                  StopGetMediaThread;
                  Application.ProcessMessages;
                end;
                if not FCancelDragDrop then
                begin
                  SetInfoFromMediaToFrame(Media, FrmMovie, FrmMovieCustom);
                  if ImportPicture then
                  begin
                    PicPath := '';
                    if FileExists(ChangeFileExt(FileName, '.jpg')) then
                      PicPath := ChangeFileExt(FileName, '.jpg')
                    else if FileExists(ChangeFileExt(FileName, '.jpeg')) then
                      PicPath := ChangeFileExt(FileName, '.jpeg')
                    else if FileExists(ChangeFileExt(FileName, '.jpe')) then
                      PicPath := ChangeFileExt(FileName, '.jpe')
                    else if FileExists(ChangeFileExt(FileName, '.png')) then
                      PicPath := ChangeFileExt(FileName, '.png')
                    else if FileExists(ChangeFileExt(FileName, '.gif')) then
                      PicPath := ChangeFileExt(FileName, '.gif')
                    else if FileExists(ChangeFileExt(FileName, '.bmp')) then
                      PicPath := ChangeFileExt(FileName, '.bmp');
                    if PicPath <> '' then
                    begin
                      StopThumbThread;
                      ImportMoviePicture(CurrentItem.Data, PicPath, PicImportMethod);
                      LoadMoviePicture;
                      ThumbsViewerStart;
                    end;
                  end;
                  FrmMovie.Modified := True;
                  FCatalogFile.Modified := True;
                  UpdateCurrentItem;
                  HTMLViewerUpdate;
                  if PicPath <> '' then
                    MovieSelected;
                end;
              end;
            except
              on e: Exception do
                MessageWin.Execute(GetShortHint(ActionMovieImportFiles.Hint) + sLineBreak + sLineBreak + e.Message, mtError, [mbOk]);
            end;
          end;
        end  // if extVideo
        else

        // **** MovieCovers.com description files ****
        if SameText(ext, '.film') then
        begin
          if Multiple then
            AddNewMovie;
          if (not FCancelDragDrop) and (CurrentItem <> nil) then
          begin
            with TStringList.Create do
              try
                FrmMovie.BeginUpdate;
                PicPath := '';
                try
                  LoadFromFile(FileName);
                  try
                    FrmMovie.ETranslatedTitle.Text := Strings[0];
                    FrmMovie.EDirector.Text := Strings[1];
                    FrmMovie.EYear.Text := Strings[2];
                    FrmMovie.ECountry.Text := Strings[3];
                    FrmMovie.ECategory.Text := Strings[4];
                    FrmMovie.ELength.Value := StrToIntDef(TextBefore(UpperCase(Strings[5]), 'H'), 0) * 60 + StrToIntDef(TextAfter(UpperCase(Strings[5]), 'H'), 0);
                    FrmMovie.EActors.Text := Strings[6];
                    FrmMovie.EDescription.Text := Strings[7];
                    FrmMovie.EProducer.Text := Strings[8];
                    FrmMovie.EOriginalTitle.Text := Strings[9];
                  except
                  end;
                  if FrmMovie.EOriginalTitle.Text = '' then
                  begin
                    FrmMovie.EOriginalTitle.Text := FrmMovie.ETranslatedTitle.Text;
                    FrmMovie.ETranslatedTitle.Text := '';
                  end;
                  if FileExists(ChangeFileExt(FileName, '.jpg')) then
                    PicPath := ChangeFileExt(FileName, '.jpg')
                  else if FileExists(ChangeFileExt(FileName, '.jpeg')) then
                    PicPath := ChangeFileExt(FileName, '.jpeg')
                  else if FileExists(ChangeFileExt(FileName, '.jpe')) then
                    PicPath := ChangeFileExt(FileName, '.jpe')
                  else if FileExists(ChangeFileExt(FileName, '.png')) then
                    PicPath := ChangeFileExt(FileName, '.png')
                  else if FileExists(ChangeFileExt(FileName, '.gif')) then
                    PicPath := ChangeFileExt(FileName, '.gif')
                  else if FileExists(ChangeFileExt(FileName, '.bmp')) then
                    PicPath := ChangeFileExt(FileName, '.bmp');
                  if PicPath <> '' then
                  begin
                    StopThumbThread;
                    ImportMoviePicture(CurrentItem.Data, PicPath, PicImportMethod);
                    LoadMoviePicture;
                    ThumbsViewerStart;
                  end;
                finally
                  FrmMovie.EndUpdate;
                end;
                FrmMovie.Modified := True;
                FCatalogFile.Modified := True;
                UpdateCurrentItem;
                HTMLViewerUpdate;
                if PicPath <> '' then
                  MovieSelected;
              finally
                Free;
              end;
          end;
        end;
      end;
      Inc(i);
    end;
    ProgressWin.IntProgress := ProgressWin.Maximum;
  finally
    ProgressWin.OnCancel := nil;
    ProgressWin.Close;
    ProgressWin.AutoUpdateTextProgress := True;
  end;
  Application.ProcessMessages;

  if OpenCatalog then
    FCatalogFile.Open(FileName)
  else if Multiple and (AddedMovies.Count > 1) then
  begin
    ListView1.DeselectAll;
    for i := 0 to AddedMovies.Count-1 do
    begin
      if i = 0 then
        ListView1.ItemFocused := TElTreeItem(AddedMovies.Items[i])
      else
        TElTreeItem(AddedMovies.Items[i]).Selected := True;
    end;
    ListView1AfterSelectionChange(nil);
  end;

  AddedMovies.Free;
  Media.Free;
  MediaFilter.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.PopupMovieListPopup(Sender: TObject);
var
  i: Integer;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  with PopupMovieList.Items do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
  with MnuSelect do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
  with MnuSelected do
    for i := 0 to Count-1 do
      with Items[i] do
        Visible := Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnURLButtonClick(Sender: TObject);
var
  FieldPos: TPoint;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if Sender is TAntJvComboEditXP then
  begin
    FSelectedURL := TAntJvComboEditXP(Sender);
    FURL := '';
    with FSelectedURL do
      FieldPos := ClientToScreen(Point(Width-1, Height-1));
    PopupEURL.Popup(FieldPos.X, FieldPos.Y);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.OnURLEnter(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if Sender is TAntJvComboEditXP then
  begin
    FSelectedURL := TAntJvComboEditXP(Sender);
    FURL := '';
    ActionURLOpen.Execute;
  end;
end;

{-------------------------------------------------------------------------------
   Picture panel
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMoviePictureShowExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if ToolbarPictureWindow.Visible then
  begin
    ActionMoviePictureShow.Checked := False;
    ToolbarPictureWindow.Visible := False;
    SplitterBottomList.Visible := False;
  end else
  begin
    ActionMoviePictureShow.Checked := True;
    ToolbarPictureWindow.Visible := True;
    SplitterBottomList.Visible := not ToolbarPictureWindow.Floating;
    if(MoviePicture.Picture.Graphic = nil) then
      LoadMoviePicture;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieExtrasShowExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if ToolbarExtrasWindow.Visible then
  begin
    ActionMovieExtrasShow.Checked := False;
    ToolbarExtrasWindow.Visible := False;
    SplitterRightExtras.Visible := False;
  end else
  begin
    ActionMovieExtrasShow.Checked := True;
    ToolbarExtrasWindow.Visible := True;
    SplitterRightExtras.Visible := not ToolbarExtrasWindow.Floating;
  end;
  if Sender <> nil then
    CheckAnchorMovieExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MoviePictureMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Picture: TMoviePicture;
  Pt: TPoint;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem <> nil) then
  begin
    if (Button = mbLeft) then
    begin
      Picture := TMovie(CurrentItem.Data).Picture;
      Picture.Lock;
      try
        if (Picture.PicPath <> '') then
        begin
          if (Picture.PicStream <> nil) then
          begin
            PictureWin := TPictureWin.Create(Self);
            try
              PictureWin.Execute(Picture.GetPictureCaption, Picture.PicStream, Picture.PicPath)
            finally
              FreeAndNil(PictureWin);
            end;
          end else
          begin
            if FCatalogFile.CurrentFile <> '' then
              SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
            else
              SetCurrentDir(strDirCatalogs);
            if FileExists(ExpandFileName(Picture.PicPath)) then
            begin
              PictureWin := TPictureWin.Create(Self);
              try
                PictureWin.Execute(Picture.GetPictureCaption, ExpandFileName(Picture.PicPath));
              finally
                FreeAndNil(PictureWin);
              end;
            end else
              MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [Picture.PicPath]), mtError, [mbOk]);
          end;
        end;
      finally
        Picture.Unlock;
      end;
    end
    else if (Button = mbRight) then
    begin
      GetCursorPos(Pt);
      PopupImage.Popup(Pt.X, Pt.Y);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarPictureWindowClose(Sender: TObject);
begin
  ActionMoviePictureShow.Checked := False;
  SplitterBottomList.Visible := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarPictureWindowDockChanged(Sender: TObject);
begin
  SplitterBottomList.Visible := ToolbarPictureWindow.Visible and not ToolbarPictureWindow.Floating;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarExtrasWindowClose(Sender: TObject);
begin
  ActionMovieExtrasShow.Checked := False;
  SplitterRightExtras.Visible := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarExtrasWindowDockChanged(Sender: TObject);
begin
  SplitterRightExtras.Visible := ToolbarExtrasWindow.Visible and not ToolbarExtrasWindow.Floating;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicSelectExecute(Sender: TObject);
var
  ImportMethod: TPictureSelectOption;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  with TPictureSelectionWin.Create(Self) do
    try
      InitialDir := Settings.rOptions.rFolders[fuPicture].Value;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      FileName := '';
      HelpContext := 1062;
      Options := DialogOpenOptions + [ofShowHelp];
      Title := Messages.Strings[msgPicOpen];
      Filter := DialogImageFilter;
      ImportMethod := TPictureSelectOption(Abs(Settings.rOptions.rMovieInformation.rPicImport.GetInfoMethod));
      if Execute(ImportMethod) then
      begin
        Settings.rOptions.rFolders[fuPicture].Value := ExtractFilePath(FileName);
        with Settings.rOptions.rMovieInformation do
          if rPicImport.GetInfoMethod > 0 then
            rPicImport.GetInfoMethod := Integer(ImportMethod)
          else
            rPicImport.GetInfoMethod := - Integer(ImportMethod);
        StopThumbThread;
        MakeMovieSave(CurrentItem.Data, False);
        ImportMoviePicture(CurrentItem.Data, FileName, ImportMethod);
        LoadMoviePicture;
        UpdateCurrentItem;
        HTMLViewerUpdate;
        MovieSelected;
        ThumbsViewerStart;
      end;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicSaveAsExecute(Sender: TObject);
var
  Ext: string;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  with TMovie(CurrentItem.Data) do
    if Picture.PicPath <> '' then
      with TSaveDialog.Create(Self) do
        try
          InitialDir := Settings.rOptions.rFolders[fuPicture].Value;
          if InitialDir <> '' then
            ClearLastVisitedMRU(Application.ExeName);
          Options := DialogSaveOptions;
          Title := Messages.Strings[msgPicSaveAs];
          Ext := ExtractFileExt(Picture.PicPath);
          case IndexText(ext, extImage) of
            extPNG:
              Filter := 'PNG (*.png)|*.png';
            extJPG, extJPE, extJPEG:
              Filter := 'JPEG (*.jpg, *.jpe, *.jpeg)|*.jpg;*.jpe;*.jpeg';
            extGIF:
              Filter := 'GIF (*.gif)|*.gif';
          else
            Filter := 'All files (*.*)|*.*';
          end;
          FileName := ValidateFileName(GetFormattedTitle);
          if FileName = '' then
            FileName := IntToStr(iNumber);
          System.Delete(Ext, 1, 1);
          DefaultExt := Ext;
          if Execute then
          begin
            Settings.rOptions.rFolders[fuPicture].Value := ExtractFilePath(FileName);
            if Picture.PicStream <> nil then
              Picture.PicStream.SaveToFile(FileName)
            else
            begin
              if FCatalogFile.CurrentFile <> '' then
                SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
              else
                SetCurrentDir(strDirCatalogs);
              CopyFile(PChar(Picture.PicPath), PChar(FileName), False);
            end;
          end;
        finally
          Free;
        end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicCopyExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if(MoviePicture.Picture.Graphic = nil) then
  begin
    LoadMoviePicture(True);
  end;
  Clipboard.Assign(MoviePicture.Picture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicPasteExecute(Sender: TObject);
var
  PicImportMethod: TPictureSelectOption;
  DoNotAsk, ImportPic: Boolean;
  Jpeg: TJPEGImage;
  Bitmap: TBitmap;
  Movie: TMovie;
  Stream: TMemoryStream;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  Movie := TMovie(CurrentItem.Data);
  Clipboard.Open;
  try
    if (Clipboard.HasFormat(CF_BITMAP)) or
      (Clipboard.HasFormat(CF_PICTURE)) or
      (Clipboard.HasFormat(CF_METAFILEPICT)) then
    begin
      with Settings.rOptions.rMovieInformation do
      begin
        ImportPic := True;
        PicImportMethod := TPictureSelectOption(Abs(rPicImport.GetInfoMethod));
        if (rPicImport.GetInfoMethod <= 0) then
        begin
          with TPictureDragDropWin.Create(Application) do
            try
              ImageListHot.GetIcon(Ord(ICON_PICTUREOPEN), Icon);
              if not Execute(PicImportMethod, DoNotAsk) then
                ImportPic := False
              else
              begin
                rPicImport.GetInfoMethod := Integer(PicImportMethod);
                if not DoNotAsk then
                  rPicImport.GetInfoMethod := - rPicImport.GetInfoMethod;
              end;
            finally
              Release;
            end;
        end;
      end;

      if ImportPic then
      begin
        Bitmap := TBitmap.Create;
        try
          Bitmap.LoadFromClipboardFormat(CF_BITMAP, ClipBoard.GetAsHandle(CF_BITMAP), 0);
          Jpeg := TJPEGImage.Create;
          Jpeg.CompressionQuality := 90;
          Jpeg.Performance := jpBestQuality;
          try
            Jpeg.Assign(Bitmap);
          except
            FreeAndNil(Jpeg);
          end;
        finally
          Bitmap.Free;
        end;
        if Jpeg = nil then
          Exit;
        try
          Stream := TMemoryStream.Create;
          try
            Jpeg.SaveToStream(Stream);
          except
            FreeAndNil(Stream);
          end;
        finally
          Jpeg.Free;
        end;
        if Stream = nil then
          Exit;

        StopThumbThread;
        MakeMovieSave(CurrentItem.Data, False);
        ImportMoviePictureFromStream(Movie, Stream, '.jpg', PicImportMethod);
        LoadMoviePicture;
        UpdateCurrentItem;
        HTMLViewerUpdate;
        MovieSelected;
        ThumbsViewerStart;
        Stream.Free;
      end;
    end;
  finally
    Clipboard.Close;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicDeleteExecute(Sender: TObject);
var
  res: TModalResult;
  Status: TMoviePictureStatus;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  if (CurrentItem = nil) then
    Exit;
  with TMovie(CurrentItem.Data) do
  begin
    if FCatalogFile.CurrentFile <> '' then
      SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
    else
      SetCurrentDir(strDirCatalogs);
    res := 0;
    Status := Picture.GetPictureStatus(FCatalogFile.CurrentFile);
    if Status = mpsStored then
    begin
      res := MessageWin.Execute(Messages.Strings[msgPicDelete], mtConfirmation, [mbOk, mbCancel]);
      if res = 1 then
        res := 2
      else if res = 2 then
        res := 3;
    end
    else
    if (Status = mpsCopiedInCatDir) or (Status = mpsCopiedInPicDir) then
    begin
      if not FileExists(ExpandFileName(Picture.PicPath)) then
        res := 2
      else
      begin
        res := MessageWin.Execute(Messages.Strings[msgPicDelete], mtConfirmation, [mbOk, mbCancel]);
        if res = 2 then
          res := 3;
      end;
    end
    else
    if (Status = mpsLinkRel) or (Status = mpsLinkAbs) then
    begin
      if not FileExists(ExpandFileName(Picture.PicPath)) then
        res := 2
      else
        res := MessageWin.Execute(Format(Messages.Strings[msgPicDeleteLink], [ExpandFileName(Picture.PicPath)]), mtConfirmation, [mbYes, mbNo, mbCancel], 2);
    end;

    if res in [1, 2] then
    begin
      StopThumbThread;
      MakeMovieSave(CurrentItem.Data, False);
      if res = 1 then
        Picture.PictureOperation(FCatalogFile.CurrentFile, mpoDeleteWithLinkedFile)
      else
        Picture.PictureOperation(FCatalogFile.CurrentFile, mpoDelete);
      FCatalogFile.Modified := True;
      LoadMoviePicture;
      UpdateCurrentItem;
      HTMLViewerUpdate;
      MovieSelected;
      ThumbsViewerStart;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionPicUndockExecute(Sender: TObject);
begin
  with ToolbarPictureWindow do
  begin
    Floating := not Floating;
    if not Floating then
    begin
      CurrentDock := DockBottomList;
      SplitterBottomList.Visible := True;
    end else
    begin
      SplitterBottomList.Visible := False;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SplitterBottomListCanResize(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
var
  d: TTBXDock;
  i: Integer;
begin
  d := ToolbarPictureWindow.CurrentDock as TTBXDock;
  if d = DockBottomList then
  begin
    i := d.ClientHeight - ToolbarPictureWindow.Height;
    (Sender as TSplitter).MinSize := i + 75;
    ToolbarPictureWindow.Height := NewSize - i;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SplitterRightExtrasCanResize(Sender: TObject;
  var NewSize: Integer; var Accept: Boolean);
var
  d: TTBXDock;
  i: Integer;
begin
  d := ToolbarExtrasWindow.CurrentDock as TTBXDock;
  if d = DockRightExtras then
  begin
    i := d.ClientWidth - ToolbarExtrasWindow.Width;
    (Sender as TSplitter).MinSize := i + 75;
    ToolbarExtrasWindow.Width := NewSize - i;
  end;
  //Accept := PanelMovieInfos.ClientWidth - (NewSize - ToolbarExtrasWindow.Width) > PanelMovieInfos.Constraints.MinWidth;
  //if Accept = False then
  //  NewSize := ToolbarExtrasWindow.Width;
end;

{-------------------------------------------------------------------------------
  Find Window
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFindFindnextExecute(Sender: TObject);
var
  Idx, StartIdx, SelectedField: Integer;
  WholeField, Reverse, Match, Finished: Boolean;
  Value: string;
  VarMovieParser: TExprVarMovieParser;
  SearchExpression: TExpression;
begin
  if MovieList = nil then
    exit;
  with ListView1 do
    if Items.Count > 0 then
    begin
      VarMovieParser := nil;
      SearchExpression := nil;
      Value := EValue.Text;
      WholeField := ActionFindWholefield.Checked;
      Reverse := ActionFindReverse.Checked;
      SelectedField := Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1;
      if SelectedField = customFieldMax + 1 then
      begin
        VarMovieParser := TExprVarMovieParser.Create(MovieList);
        SearchExpression := TExpression.Create(EValue.Text, VarMovieParser);
      end;
      if ItemFocused = nil then
      begin
        StartIdx := 0;
        Idx := 0;
      end else
      begin
        StartIdx := ItemFocused.AbsoluteIndex;
        Idx := StartIdx + 1;
        if Idx >= Items.Count then
          Idx := 0;
      end;
      Finished := False;
      with Items do
        repeat
          if (Item[Idx] <> nil) and (Item[Idx].Data <> nil) then
          begin
            if SearchExpression <> nil then
              Match := SearchExpression.EvalAsBoolean(Item[Idx].Data)
            else
              Match := TMovie(Item[Idx].Data).ContainsText(Value, SelectedField, WholeField);
            if (Match and not Reverse) or (not Match and Reverse) then
            begin
              Finished := True;
              DeselectAll;
              if (Item[Idx].Parent <> nil) and (not Item[Idx].Parent.Expanded) then
                Item[Idx].Parent.Expanded := True;
              ItemFocused := Item[Idx];
              ListView1EnsureVisiblePlus;
              ListView1AfterSelectionChange(ListView1);
            end;
          end;
          inc(Idx);
          if Idx >= Count then
            Idx := 0;
        until (StartIdx = Idx) or (Finished);
      SearchExpression.Free;
      VarMovieParser.Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFindDisplayExecute(Sender: TObject);
begin
  ActionFindFindnext.Enabled := not ActionFindDisplay.Checked;
  RefreshMovieList;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFindWholefieldExecute(Sender: TObject);
begin
  if ActionFindDisplay.Checked then
    ActionFindDisplayExecute(ActionFindWholefield);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionFindReverseExecute(Sender: TObject);
begin
  if ActionFindDisplay.Checked then
    ActionFindDisplayExecute(ActionFindReverse);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.EValueKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
    ActionFindFindnext.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.cbxFieldChange(Sender: TObject);
var
  AdvancedSearch: Boolean;
begin
  TimerSearch.Enabled := False;
  TimerSearch.Interval := 300;
  TimerSearch.Enabled := True;
  AdvancedSearch := (cbxField.ItemIndex = cbxField.Items.Count-1);
  BtnInsertFieldTag.Enabled := AdvancedSearch;
  BtnInsertOperator.Enabled := AdvancedSearch;
  CBWholefield.Enabled := not AdvancedSearch;
  BtnInsertFieldTag.Visible := BtnInsertFieldTag.Enabled;
  BtnInsertOperator.Visible := BtnInsertOperator.Enabled;
  CBWholefield.Visible := CBWholefield.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.cbxFieldClick(Sender: TObject);
begin
  SaveFindField; //Saved just when user specify field!
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.EValueChange(Sender: TObject);
begin
  TimerSearch.Enabled := False;
  TimerSearch.Interval := 500;
  TimerSearch.Enabled := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.TimerSearchEvent(Sender: TObject);
begin
  TimerSearch.Enabled := False;
  if ActionFindDisplay.Checked then
    RefreshMovieList;
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  HTMLViewerUpdate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.InitFieldTags;
var
  i: Integer;
  newMenuItem : TTBXItem;
begin
  PopupFields.Items.Clear;

  for i := 0 to strFields.Count-1 do
  begin
    newMenuItem := TTBXItem.Create(PopupFields);
    PopupFields.Items.Add(newMenuItem);
    with newMenuItem do
    begin
      Name := strTagFields[i];
      Caption := strFields.Strings[i] + ' (' + strTagFields[i] + ')';
      OnClick := InsertFieldTagClick;
    end;
  end;

  with MovieList.CustomFieldsProperties do
    for i := 0 to Count-1 do
    begin
      newMenuItem := TTBXItem.Create(PopupFields);
      PopupFields.Items.Add(newMenuItem);
      with newMenuItem, Objects[i] do
      begin
        Name := FieldTag;
        Caption := FieldName + ' (' + FieldTag + ')';
        OnClick := InsertFieldTagClick;
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.InitOperators;
var
  i: Integer;
  newMenuItem : TTBXItem;
begin
  PopupOperators.Items.Clear;

  for i := 0 to OperatorsToken.Strings.Count-1 do
  begin
    if OperatorsToken.Strings[i] <> '' then
    begin
      newMenuItem := TTBXItem.Create(PopupOperators);
      PopupOperators.Items.Add(newMenuItem);
      with newMenuItem do
      begin
        Name := 'operator' + IntToStr(i);
        Caption := Operators.Strings[i] + ' (' + OperatorsToken.Strings[i] + ')';
        OnClick := InsertOperatorClick;
      end;
    end else
      PopupOperators.Items.Add(TTBXSeparatorItem.Create(PopupOperators));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.PopupFieldsPopup(Sender: TObject);
begin
  InitFieldTags;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.PopupOperatorsPopup(Sender: TObject);
begin
  InitOperators;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.InsertFieldTagClick(Sender: TObject);
var
  pos: Integer;
begin
  pos := EValue.SelStart;
  if EValue.CanFocus then
    EValue.SetFocus;
  EValue.SelLength := 0;
  EValue.SelStart := pos;
  EValue.SelText := '[' + TTBXItem(Sender).Name + ']';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.InsertOperatorClick(Sender: TObject);
var
  pos, i: Integer;
  tmp: string;
begin
  tmp := TTBXItem(Sender).Name;
  System.Delete(tmp, 1, 8);
  i := StrToIntDef(tmp, 0);
  pos := EValue.SelStart;
  if EValue.CanFocus then
    EValue.SetFocus;
  EValue.SelLength := 0;
  EValue.SelStart := pos;
  EValue.SelText := OperatorsToken.Strings[i];
end;

{-------------------------------------------------------------------------------
  Toolbars
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarMainClose(Sender: TObject);
begin
  ActionDisplayMainToolbar.Checked := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarPictureClose(Sender: TObject);
begin
  ActionDisplayPictureToolbar.Checked := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.FrmMovieExtrasToolbarExtrasClose(Sender: TObject);
begin
  ActionDisplayExtrasToolbar.Checked := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ToolbarFindVisibleChanged(Sender: TObject);
begin
  if ToolbarFind.Visible then
  begin
    ActionMovieFind.Checked := True;
    ActionFindDisplay.Checked := False;
    EValue.SetFocus;
  end else
  begin
    ActionMovieFind.Checked := False;
    with ActionFindDisplay do
      if Checked then
        Execute;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockMainTopRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarMain) or (Bar = ToolbarMenu) or (Bar = ToolbarPicture)
    or (Bar = FrmMovieExtras.ToolbarExtras) or (Bar = ToolbarFind);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockMainLeftRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarMain) or (Bar = ToolbarMenu) or (Bar = ToolbarPicture)
    or (Bar = FrmMovieExtras.ToolbarExtras);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockMainBottomRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarFind);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockImageLeftRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarPicture);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockBottomListRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarPictureWindow);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.DockRightExtrasRequestDock(Sender: TObject;
  Bar: TTBCustomDockableWindow; var Accept: Boolean);
begin
  Accept := (Bar = ToolbarExtrasWindow) or (Bar = ToolbarPictureWindow);
end;

{-------------------------------------------------------------------------------
  Others
-------------------------------------------------------------------------------}

function TMainWindow.ExecuteAction(Action: TBasicAction): Boolean;
begin
  if (Action is THintAction) then
  begin
    StatusBar1.Panels[panelHint].Caption := THintAction(Action).Hint;
    Result := True;
  end
  else
    Result := inherited ExecuteAction(Action);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.OnAppHelp(Command: Word; Data: Integer; var CallHelp: Boolean): Boolean;
begin
  if Data <> Self.HelpContext then
    LaunchHelp(Data);
  CallHelp := False;
  Result := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionMovieRandomExecute(Sender: TObject);
var
  i, nb : Integer;
  Item: TElTreeItem;
begin
  with ListView1 do
  begin
    if Items.Count > 0 then
    begin
      nb := 100;
      repeat
        i := Random(ListView1.Items.Count);
        nb := nb - 1;
      until (ListView1.Items.Item[i].Data <> nil) or (nb < 0);
      if (nb >= 0) then
      begin
        //UpdateCurrentItemIfNeeded; <-- Check in SaveCurrentItem
        {if not Settings.rOptions.rMovieList.GroupExpand then
        begin
          FullExpandOrCollapse := True;
          FullCollapse;
          FullExpandOrCollapse := False;
          ThumbsViewer.CalcView(True);
          ThumbsViewer.Invalidate;
        end;}
        DeselectAll;
        Item := Items.Item[i];
        if (Item.Parent <> nil) and (not Item.Parent.Expanded) then
          Item.Parent.Expanded := True;
        ItemFocused := Item;
        ListView1EnsureVisiblePlus;
        ListView1AfterSelectionChange(ListView1);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1HeaderColumnClick(Sender: TObject;
  SectionIndex: Integer);
var
  Field: Integer;
  Descend: Boolean;
begin
  UpdateCurrentItemIfNeeded;
  Field := StrToInt(ListView1.HeaderSections.Item[SectionIndex].FieldName);
  Descend := FSortField < 0;
  if (Abs(FSortField) - 1) = Field then
    Descend := not Descend;
  SetSortField(Field, Descend);
  SaveSortField;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ListView1DblClick(Sender: TObject);
begin
  if (ActionStretchList.Checked = True) and (SelectedItem <> nil) then
  begin
    ActionStretchListExecute(ListView1);
  end
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionStretchListExecute(Sender: TObject);
begin
  ActionStretchList.Checked := not ActionStretchList.Checked;
  if ActionStretchList.Checked then
  begin
    PanelLeftOldWidth := PanelLeft.Width;
    PanelMovieInfos.Visible := False;
    SplitterMovieInfos.Visible := False;
    PanelLeft.Align := alClient;
    UpdateCurrentItemIfNeeded;
  end else
  begin
    PanelLeft.Align := alLeft;
    PanelLeft.Width := PanelLeftOldWidth;
    SplitterMovieInfos.Visible := True;
    PanelMovieInfos.Visible := True;
  end;
  if Sender <> nil then
    CheckAnchorMovieExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayHTMLExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  ActionDisplayHTML.Checked := not ActionDisplayHTML.Checked;
  HTMLViewer.Visible := ActionDisplayHTML.Checked;
  TabMovieInfos.Visible := not ActionDisplayHTML.Checked;
  HTMLViewerUpdate;
  if Sender <> nil then
    CheckAnchorMovieExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ActionDisplayThumbnailsExecute(Sender: TObject);
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  ActionDisplayThumbnails.Checked := not ActionDisplayThumbnails.Checked;
  PanelThumbs.Visible := ActionDisplayThumbnails.Checked;
  ListView1.Visible := not ActionDisplayThumbnails.Checked;
  if (Sender <> nil) and Settings.rOptions.rMovieList.AutoStretchListThumbs then
    AutoStretchList;
  MovieSelected;
  if (ActionDisplayThumbnails.Checked) and (ThumbsViewer.Items.Count = 0) and
    (ThumbsViewer.SmartGroups.Count = 0) and (ListView1.Items.Count > 0) then
    ThumbsViewerStart;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.CheckAnchorMovieExtras;
begin
  if FrmMovieExtras.Visible and (not ActionStretchList.Checked) and
    (not ActionDisplayHTML.Checked) then
  begin
    if FrmMovieExtras.PanelMovieExtras.Parent = ToolbarExtrasWindow then
    begin
      ToolbarExtrasWindow.RemoveControl(FrmMovieExtras.PanelMovieExtras);
      FrmMovieExtras.InsertControl(FrmMovieExtras.PanelMovieExtras);
    end;
  end else if (ActionMovieExtrasShow.Checked) then
  begin
    if FrmMovieExtras.PanelMovieExtras.Parent = FrmMovieExtras then
    begin
      FrmMovieExtras.RemoveControl(FrmMovieExtras.PanelMovieExtras);
      ToolbarExtrasWindow.InsertControl(FrmMovieExtras.PanelMovieExtras);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.TabMovieInfosChange(Sender: TObject);
begin
  FrmBoth.Visible := False;
  FrmMovie.Visible := False;
  FrmMovieCustom.Visible := False;
  FrmMovieExtras.Visible := False;
  if TabMovieInfos.TabIndex = 2 then
  begin
    if FrmMovie.Parent = TabMovieInfos then
    begin
      TabMovieInfos.RemoveControl(FrmMovie);
      TabMovieInfos.RemoveControl(FrmMovieCustom);
      Panel1FrmBoth.InsertControl(FrmMovie);
      FrmMovieCustom.Constraints.MinWidth := 233;
      Panel2FrmBoth.InsertControl(FrmMovieCustom);
    end;
    FrmMovie.Visible := True;
    FrmMovieCustom.Visible := True;
    FrmBoth.Visible := True;
    TabMovieInfosResize(nil);
  end else
  begin
    if FrmMovie.Parent = Panel1FrmBoth then
    begin
      Panel1FrmBoth.RemoveControl(FrmMovie);
      Panel2FrmBoth.RemoveControl(FrmMovieCustom);
      FrmMovie.Align := alClient;
      FrmMovieCustom.Align := alClient;
      TabMovieInfos.InsertControl(FrmMovie);
      FrmMovieCustom.Constraints.MinWidth := 533;
      TabMovieInfos.InsertControl(FrmMovieCustom);
    end;
    FrmMovie.Visible := TabMovieInfos.TabIndex = 0;
    FrmMovieCustom.Visible := TabMovieInfos.TabIndex = 1;
    FrmMovieExtras.Visible := TabMovieInfos.TabIndex = 3;
  end;
  if Sender <> nil then
    CheckAnchorMovieExtras;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.TabMovieInfosResize(Sender: TObject);
begin
  if TabMovieInfos.Visible and FrmBoth.Visible then
  begin
    if FrmBoth.Width < (Panel1FrmBoth.Width + Panel2FrmBoth.Constraints.MinWidth + SplitterFrmBoth.Width) then
      Panel1FrmBoth.Width := FrmBoth.Width - (Panel2FrmBoth.Constraints.MinWidth + SplitterFrmBoth.Width);
    Settings.rMain.MovieInfosBothWidth := Panel1FrmBoth.Width;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SplitterFrmBothMoved(Sender: TObject);
begin
  Settings.rMain.MovieInfosBothWidth := Panel1FrmBoth.Width;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (X <> FMouseHTMLViewerX) or (Y <> FMouseHTMLViewerY) then
  begin
    if (Settings.rOptions.rDisplay.AutoFocus) and
      (not HTMLViewer.Focused) and HTMLViewer.CanFocus then
      HTMLViewer.SetFocus;
    UpdateCurrentItemIfNeeded;
    FMouseHTMLViewerX := X;
    FMouseHTMLViewerY := Y;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.AutoStretchList;
var
  Stretch: Boolean;
begin
  with Settings.rOptions.rMovieList do
  begin
    Stretch := ActionStretchList.Checked;
    if AutoStretchListGrid and AutoStretchListThumbs then
      Stretch := ActionToolsGrid.Checked or ActionDisplayThumbnails.Checked
    else if AutoStretchListGrid then
      Stretch := ActionToolsGrid.Checked
    else if AutoStretchListThumbs then
      Stretch := ActionDisplayThumbnails.Checked;
    if Stretch <> ActionStretchList.Checked then
      ActionStretchList.Execute;
  end;
end;

{-------------------------------------------------------------------------------
  HTML Viewer
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerUpdate;
begin
  if ActionDisplayHTML.Checked then
  begin
    HTMLViewer.VScrollBarPosition := 0;
    HTMLViewer.LoadFromString(GenerateHTMLCurrentMovie, HTMLTemplateFileRef);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.PreGenerateHTMLTemplate;
var
  i, j, t, lastPos: integer;
  ATag : string;
  Found : Boolean;
  HTMLTemplate, HTMLTemplatePathRef : string;
  RStream: TResourceStream;
begin
  HTMLTemplatePreGenerated.Clear;
  HTMLTemplateContainsChecked := False;
  HTMLTemplateContainsColorTag := False;
  HTMLTemplateContainsExtras := False;
  HTMLTemplateFileRef := '';
  HTMLTemplatePathRef := '';

  with Settings.rOptions.rFiles do
  begin
    SetCurrentDir(strDirTemplates);

    if FileExists(ExpandFileName(HTMLTemplateFile)) then
    begin
      HTMLTemplateFileRef := ExpandFileName(HTMLTemplateFile);
      HTMLTemplatePathRef := ExtractFilePath(HTMLTemplateFileRef);
    end;

    if HTMLTemplateFileRef = '' then
    begin
      if HTMLTemplateFile = '' then
        HTMLTemplatePreGenerated.Add('No file template !')
      else
        HTMLTemplatePreGenerated.Add(Format(Messages.Strings[msgFileNotExists], [HTMLTemplateFile]));
      Exit;
    end;

    HTMLTemplatePreGenerated.LoadFromFile(HTMLTemplateFileRef);
    HTMLTemplate := HTMLTemplatePreGenerated.Text;
    HTMLTemplatePreGenerated.Clear;
  end;

  for i := 0 to High(MStreamAppr) do
    if FileExists(HTMLTemplatePathRef + 'appr' + IntToStr(i) + '.gif') then
    begin
      FreeAndNil(MStreamAppr[i]);
      MStreamAppr[i] := TMemoryStream.Create;
      MStreamAppr[i].LoadFromFile(HTMLTemplatePathRef + 'appr' + IntToStr(i) + '.gif');
    end else
    begin
      FreeAndNil(MStreamAppr[i]);
      MStreamAppr[i] := TMemoryStream.Create;
      try
        RStream := TResourceStream.Create( HInstance, 'appr' + IntToStr(i), 'GIF' );
        try
          MStreamAppr[i].LoadFromStream(RStream);
        finally
          RStream.Free;
        end;
      except
        FreeAndNil(MStreamAppr[i]);
      end;
    end;
  for i := 0 to High(MStreamAppr10) do
  begin
    if FileExists(HTMLTemplatePathRef + 'appr10_' + IntToStr(i) + '.gif') then
    begin
      FreeAndNil(MStreamAppr10[i]);
      MStreamAppr10[i] := TMemoryStream.Create;
      MStreamAppr10[i].LoadFromFile(HTMLTemplatePathRef + 'appr10_' + IntToStr(i) + '.gif');
    end else
    begin
      FreeAndNil(MStreamAppr10[i]);
      MStreamAppr10[i] := TMemoryStream.Create;
      try
        RStream := TResourceStream.Create( HInstance, 'appr10_' + IntToStr(i), 'GIF' );
        try
          MStreamAppr10[i].LoadFromStream(RStream);
        finally
          RStream.Free;
        end;
      except
        FreeAndNil(MStreamAppr10[i]);
      end;
    end;
  end;

  if HTMLTemplate = '' then
    exit;
  i := 1;
  lastPos := 1;
  while(HTMLTemplate[i] <> #0) do
  begin
    if (HTMLTemplate[i] = '$') and (HTMLTemplate[i+1] = '$') then
    begin

      // Fields
      Found := False;
      t := 0;
      while (t < strListTags.Count) and (not Found) do
      begin
        ATag := strListTags.Strings[t];
        j := 1;
        while (HTMLTemplate[i+j-1] <> #0) and (ATag[j] <> #0) do
        begin
          if (HTMLTemplate[i+j-1] <> ATag[j]) then
            break;
          if (ATag[j+1] = #0) then
          begin
            if (i <> lastPos) then
              HTMLTemplatePreGenerated.Add(Copy(HTMLTemplate, lastPos, i-lastPos));
            // Replace Labels
            if ATag = TAG_LABELNUMBER then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldNumber])
            else if ATag = TAG_LABELCHECKED then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldChecked])
            else if ATag = TAG_LABELCOLORTAG then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldColorTag])
            else if ATag = TAG_LABELMEDIA then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldMedia])
            else if ATag = TAG_LABELTYPE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldMediaType])
            else if ATag = TAG_LABELSOURCE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldSource])
            else if ATag = TAG_LABELDATEADD then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldDate])
            else if ATag = TAG_LABELBORROWER then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldBorrower])
            else if ATag = TAG_LABELDATEWATCHED then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldDateWatched])
            else if ATag = TAG_LABELUSERRATING then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldUserRating])
            else if ATag = TAG_LABELRATING then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldRating])
            else if ATag = TAG_LABELORIGINALTITLE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldOriginalTitle])
            else if ATag = TAG_LABELTRANSLATEDTITLE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldTranslatedTitle])
            else if ATag = TAG_LABELFORMATTEDTITLE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldFormattedTitle])
            else if ATag = TAG_LABELDIRECTOR then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldDirector])
            else if ATag = TAG_LABELPRODUCER then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldProducer])
            else if ATag = TAG_LABELWRITER then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldWriter])
            else if ATag = TAG_LABELCOMPOSER then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldComposer])
            else if ATag = TAG_LABELACTORS then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldActors])
            else if ATag = TAG_LABELCOUNTRY then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldCountry])
            else if ATag = TAG_LABELYEAR then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldYear])
            else if ATag = TAG_LABELLENGTH then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldLength])
            else if ATag = TAG_LABELCATEGORY then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldCategory])
            else if ATag = TAG_LABELCERTIFICATION then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldCertification])
            else if ATag = TAG_LABELURL then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldURL])
            else if ATag = TAG_LABELDESCRIPTION then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldDescription])
            else if ATag = TAG_LABELCOMMENTS then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldComments])
            else if ATag = TAG_LABELFILEPATH then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldFilePath])
            else if ATag = TAG_LABELVIDEOFORMAT then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldVideoFormat])
            else if ATag = TAG_LABELVIDEOBITRATE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldVideoBitrate])
            else if ATag = TAG_LABELAUDIOFORMAT then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldAudioFormat])
            else if ATag = TAG_LABELAUDIOBITRATE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldAudioBitrate])
            else if ATag = TAG_LABELRESOLUTION then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldResolution])
            else if ATag = TAG_LABELFRAMERATE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldFramerate])
            else if ATag = TAG_LABELLANGUAGES then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldLanguages])
            else if ATag = TAG_LABELSUBTITLES then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldSubtitles])
            else if ATag = TAG_LABELSIZE then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldSize])
            else if ATag = TAG_LABELDISKS then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldDisks])
            else if ATag = TAG_LABELPICTURESTATUS then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldPictureStatus])
            else if ATag = TAG_LABELNBEXTRAS then HTMLTemplatePreGenerated.Add(strFields.Strings[fieldNbExtras])
            else if ATag = TAG_LABELPICTURE then HTMLTemplatePreGenerated.Add(Messages.Strings[msgPicture])
            else if ATag = TAG_LABELAUDIOKBPS then HTMLTemplatePreGenerated.Add(FrmMovie.LAudioKbps.Caption)
            else if ATag = TAG_LABELVIDEOKBPS then HTMLTemplatePreGenerated.Add(FrmMovie.LVideoKbps.Caption)
            else if ATag = TAG_LABELFPS then HTMLTemplatePreGenerated.Add(FrmMovie.LFramerateFPS.Caption)
            else if ATag = TAG_LABELUNIT then HTMLTemplatePreGenerated.Add(FrmMovie.LSizeUnit.Caption)
            else
            begin
              HTMLTemplatePreGenerated.Add(ATag);
              if (ATag = TAG_ITEMCHECKED) then
                HTMLTemplateContainsChecked := True;
              if (ATag = TAG_ITEMCOLORTAG) or (ATag = TAG_ITEMCOLORHTML) then
                HTMLTemplateContainsColorTag := True;
            end;
            lastPos := i+j;
            i := lastPos;
            Found := True;
          end;
          Inc(j)
        end;
        Inc(t);
      end; // End while

      // Custom Fields
      if (Found = False) and (MovieList <> nil) then
      begin
        // Replace long tag before short tag (alphabetic order)
        // Ex: $$LABEL_CF_TEST1 replaced before $$LABEL_CF_TEST
        with MovieList.CustomFieldsProperties do
        begin
          t := (Count*2) - 1;
          while (t >= 0) and (not Found) do
          begin
            if (t < Count) then
              ATag := TAG_LABEL_CF + UpperCase(Strings[t])
            else
              ATag := TAG_ITEM_CF + UpperCase(Strings[t-Count]);
            j := 1;
            while (HTMLTemplate[i+j-1] <> #0) and (ATag[j] <> #0) do
            begin
              if (HTMLTemplate[i+j-1] <> ATag[j]) then
                break;
              if (ATag[j+1] = #0) then
              begin
                if (i <> lastPos) then
                  HTMLTemplatePreGenerated.Add(Copy(HTMLTemplate, lastPos, i-lastPos));
                if (t < Count) then
                  HTMLTemplatePreGenerated.Add(Objects[t].FieldName)
                else
                  HTMLTemplatePreGenerated.Add(ATag);
                lastPos := i+j;
                i := lastPos;
                Found := True;
              end;
              Inc(j)
            end;
            Dec(t);
          end; // End while
        end; // End with
      end; // End if Found = False

      // Extra fields
      if (Found = False) then
      begin
        t := 0;
        while (t < strListExtraTags.Count) and (not Found) do
        begin
          ATag := strListExtraTags.Strings[t];
          j := 1;
          while (HTMLTemplate[i+j-1] <> #0) and (ATag[j] <> #0) do
          begin
            if (HTMLTemplate[i+j-1] <> ATag[j]) then
              break;
            if (ATag[j+1] = #0) then
            begin
              if (i <> lastPos) then
                HTMLTemplatePreGenerated.Add(Copy(HTMLTemplate, lastPos, i-lastPos));
              // Replace Labels
              if ATag = TAG_LABELEXTRANUMBER then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldNumber - extraFieldLow])
              else if ATag = TAG_LABELEXTRACHECKED then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldChecked - extraFieldLow])
              else if ATag = TAG_LABELEXTRATAG then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldTag - extraFieldLow])
              else if ATag = TAG_LABELEXTRATITLE then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldTitle - extraFieldLow])
              else if ATag = TAG_LABELEXTRACATEGORY then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldCategory - extraFieldLow])
              else if ATag = TAG_LABELEXTRAURL then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldURL - extraFieldLow])
              else if ATag = TAG_LABELEXTRADESCRIPTION then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldDescription - extraFieldLow])
              else if ATag = TAG_LABELEXTRACOMMENTS then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldComments - extraFieldLow])
              else if ATag = TAG_LABELEXTRACREATEDBY then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldCreatedBy - extraFieldLow])
              else if ATag = TAG_LABELEXTRAPICSTATUS then HTMLTemplatePreGenerated.Add(strExtraFields.Strings[extraFieldPictureStatus - extraFieldLow])
              else if ATag = TAG_LABELEXTRAPICTURE then HTMLTemplatePreGenerated.Add(Messages.Strings[msgPicture])
              else
              begin
                HTMLTemplatePreGenerated.Add(ATag);
                HTMLTemplateContainsExtras := True;
              end;
              lastPos := i+j;
              i := lastPos;
              Found := True;
            end;
            Inc(j)
          end;
          Inc(t);
        end; // End while
      end;
    end;
    Inc(i);
  end;
  if (i <> lastPos) then
  begin
    HTMLTemplatePreGenerated.Add(Copy(HTMLTemplate, lastPos, i-lastPos));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.GenerateHTMLCurrentMovie : string;
var
  LineBreak: string;
  i, n, c: integer;
  HTMLPicAttr, HTMLExtraPicAttr, ATag: string;
  Found: Boolean;

  function Highlight(Text: string) : string;
  var
    p1, p: Integer;
  begin
    with Settings.rOptions.rMovieInformation do
      if (HTMLSearchFontTextColor = '') and (HTMLSearchBackTextColor = '') then
        Result := Text
      else
      begin
        Result := '';
        p1 := 1;
        p := AnsiPosEx(EValue.Text, Text, True, True, p1);
        while p > 0 do
        begin
          Result := Result + copy(Text, p1, p - p1) + '<font';
          if HTMLSearchFontTextColor <> '' then
            Result := Result + ' color=' + HTMLSearchFontTextColor;
          if HTMLSearchBackTextColor <> '' then
            Result := Result + ' style="background-color: ' + HTMLSearchBackTextColor + ';"';
          Result := Result + '>' + copy(Text, p, Length(EValue.Text)) + '</font>';
          p1 := p + Length(EValue.Text);
          p := AnsiPosEx(EValue.Text, Text, True, True, p1);
        end;
        Result := Result + copy(Text, p1, MaxInt);
      end;
  end;

  function GetV(Field: Integer; Text: string; Multilines: Boolean = False) : string;
  begin
    if (Length(EValue.Text) > 1) and ((cbxField.ItemIndex = 0) or
        (Field = Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1)) and
        (GetFieldType(Field) <> ftUrl) then
      Text := Highlight(Text);
      //Text := StringReplace(Text, EValue.Text, '<b><font color=#FF0000>'+EValue.Text+'</font></b>', [rfReplaceAll, rfIgnoreCase]);
    if Multilines and (LineBreak <> '') then
      Text := StringReplace(Text, #13#10, LineBreak, [rfReplaceAll]);
    Result := Text;
  end;

  function GetCFV(FieldTag: string; Idx: Integer) : string;
  var
    Text: string;
  begin
    if MovieList.CustomFieldsProperties.Objects[Idx].FieldType <> ftVirtual then
      Text := FrmMovieCustom.GetCurrentValue(FieldTag, True, False)
    else
      Text := TMovie(CurrentItem.Data).CustomFields.GetFieldValue(FieldTag, True);
    if (Length(EValue.Text) > 1) and ((cbxField.ItemIndex = 0) or
        (idx + customFieldLow = Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1)) and
        (MovieList.CustomFieldsProperties.Objects[Idx].FieldType <> ftUrl) then
      Text := Highlight(Text);
    //Text := StringReplace(Text, EValue.Text, '<b><font color=#FF0000>'+EValue.Text+'</font></b>', [rfReplaceAll, rfIgnoreCase]);
    if (MovieList.CustomFieldsProperties.Objects[Idx].FieldType = ftText) and (LineBreak <> '') then
      Text := StringReplace(Text, #13#10, LineBreak, [rfReplaceAll]);
    Result := Text;
  end;


begin
  Result := '';
  if (CurrentItem <> nil) then
  begin
    LineBreak := Settings.rOptions.rExport.Linebreak;
    HTMLPicAttr := '';
    with Settings.rOptions.rExport do
    begin
      if ForcePicSizeW >= 0 then
        HTMLPicAttr := Format(' width="%d"', [ForcePicSizeW]);
      if ForcePicSizeH >= 0 then
        HTMLPicAttr := Format('%s height="%d"', [HTMLPicAttr, ForcePicSizeH]);
    end;
    HTMLExtraPicAttr := '';
    with Settings.rOptions.rExport do
    begin
      if ForceExtraPicSizeW >= 0 then
        HTMLExtraPicAttr := Format(' width="%d"', [ForceExtraPicSizeW]);
      if ForceExtraPicSizeH >= 0 then
        HTMLExtraPicAttr := Format('%s height="%d"', [HTMLExtraPicAttr, ForceExtraPicSizeH]);
    end;

    for n := 0 to HTMLTemplatePreGenerated.Count-1 do
    begin
      if (HTMLTemplatePreGenerated.Strings[n][1] <> '$') or (HTMLTemplatePreGenerated.Strings[n][2] <> '$') then
      begin
        Result := Result + HTMLTemplatePreGenerated.Strings[n];
        continue;
      end;
      with TMovie(CurrentItem.Data) do
      with FrmMovie do
      begin
        ATag := HTMLTemplatePreGenerated.Strings[n];
        // Replace Items
        if ATag = TAG_ITEMNUMBER then Result := Result + GetV(fieldNumber, GetFieldValue(fieldNumber))
        else if ATag = TAG_ITEMCHECKED then Result := Result + IfThen(bChecked, 'x', ' ')
        else if ATag = TAG_ITEMCOLORTAG then Result := Result + IntToStr(iColorTag)
        else if ATag = TAG_ITEMCOLORHTML then Result := Result + ConvertColorToHTML(Settings.rOptions.rMovieList.ColorsTag[iColorTag])
        else if ATag = TAG_ITEMTYPE then Result := Result + GetV(fieldMediaType, EMediaType.Text)
        else if ATag = TAG_ITEMMEDIA then Result := Result + GetV(fieldMedia, EMedia.Text)
        else if ATag = TAG_ITEMSOURCE then Result := Result + GetV(fieldSource, ESource.Text)
        else if ATag = TAG_ITEMDATEADD then
        begin
          if EDate.Checked then
            Result := Result + GetV(fieldDate, DateToStr(Trunc(EDate.DateTime)))
        end
        else if ATag = TAG_ITEMBORROWER then Result := Result + GetV(fieldBorrower, EBorrower.Text)
        else if ATag = TAG_ITEMDATEWATCHED then
        begin
          if EDateWatched.Checked then
            Result := Result + GetV(fieldDateWatched, DateToStr(Trunc(EDateWatched.DateTime)))
        end
        else if ATag = TAG_ITEMORIGINALTITLE then Result := Result + GetV(fieldOriginalTitle, EOriginalTitle.Text)
        else if ATag = TAG_ITEMTRANSLATEDTITLE then Result := Result + GetV(fieldTranslatedTitle, ETranslatedTitle.Text)
        else if (ATag = TAG_ITEMFORMATTEDTITLE) or (ATag = TAG_ITEMFORMATTEDTITLE1) or (ATag = TAG_ITEMFORMATTEDTITLE2) then
          Result := Result + GetV(fieldFormattedTitle, GetFormattedTitle)
        else if ATag = TAG_ITEMDIRECTOR then Result := Result + GetV(fieldDirector, EDirector.Text)
        else if ATag = TAG_ITEMPRODUCER then Result := Result + GetV(fieldProducer, EProducer.Text)
        else if ATag = TAG_ITEMWRITER then Result := Result + GetV(fieldWriter, EWriter.Text)
        else if ATag = TAG_ITEMCOMPOSER then Result := Result + GetV(fieldComposer, EComposer.Text)
        else if ATag = TAG_ITEMACTORS then Result := Result + GetV(fieldActors, EActors.Text, True)
        else if ATag = TAG_ITEMCOUNTRY then Result := Result + GetV(fieldCountry, ECountry.Text)
        else if ATag = TAG_ITEMYEAR then Result := Result + GetV(fieldYear, EYear.Text)
        else if ATag = TAG_ITEMLENGTH then Result := Result + GetV(fieldLength, ELength.Text)
        else if ATag = TAG_ITEMCATEGORY then Result := Result + GetV(fieldCategory, ECategory.Text)
        else if ATag = TAG_ITEMCERTIFICATION then Result := Result + GetV(fieldCertification, ECertification.Text)
        else if ATag = TAG_ITEMURL then Result := Result + GetV(fieldURL, EURL.Text)
        else if ATag = TAG_ITEMCOMMENTS then Result := Result + GetV(fieldComments, EComments.Text, True)
        else if ATag = TAG_ITEMDESCRIPTION then Result := Result + GetV(fieldDescription, EDescription.Text, True)
        else if ATag = TAG_ITEMFILEPATH then Result := Result + GetV(fieldFilePath, EFilePath.Text, True)
        else if ATag = TAG_ITEMFORMAT then Result := Result + GetV(fieldVideoFormat, EVideoFormat.Text)
        else if ATag = TAG_ITEMVIDEOFORMAT then Result := Result + GetV(fieldVideoFormat, EVideoFormat.Text)
        else if ATag = TAG_ITEMAUDIOFORMAT then Result := Result + GetV(fieldAudioFormat, EAudioFormat.Text)
        else if ATag = TAG_ITEMVIDEOBITRATE then Result := Result + GetV(fieldVideoBitrate, EVideoBitrate.Text)
        else if ATag = TAG_ITEMAUDIOBITRATE then Result := Result + GetV(fieldAudioBitrate, EAudioBitrate.Text)
        else if ATag = TAG_ITEMRESOLUTION then Result := Result + GetV(fieldResolution, EResolution.Text)
        else if ATag = TAG_ITEMFRAMERATE then Result := Result + GetV(fieldFrameRate, EFramerate.Text)
        else if ATag = TAG_ITEMSIZE then Result := Result + GetV(fieldSize, ESize.Text)
        else if ATag = TAG_ITEMLANGUAGES then Result := Result + GetV(fieldLanguages, ELanguages.Text)
        else if ATag = TAG_ITEMSUBTITLES then Result := Result + GetV(fieldSubtitles, ESubtitles.Text)
        else if ATag = TAG_ITEMDISKS then Result := Result + GetV(fieldDisks, EDisks.Text)
        else if ATag = TAG_ITEMPICTURESTATUS then Result := Result + GetV(fieldDisks, GetFieldValue(fieldPictureStatus))
        else if ATag = TAG_ITEMNBEXTRAS then Result := Result + GetV(fieldNbExtras, GetFieldValue(fieldNbExtras))
        else if (ATag = TAG_ITEMPICTUREFILENAMENP) or (ATag = TAG_ITEMPICTUREFILENAME) then // Warning put before TAG_ITEMPICTURE !
        begin
          Result := Result + HTMLPicMovieTag;
          if ATag = TAG_ITEMPICTUREFILENAMENP then
            Result := Result + HTMLNoPopupTag;
          Result := Result + IntToStr(Integer(Pointer(CurrentItem.Data)));
        end
        else if (ATag = TAG_ITEMPICTURENP) or (ATag = TAG_ITEMPICTURE) then
          if ATag = TAG_ITEMPICTURENP then
            Result := Result + Format('<img src="%s" alt="pic_movie_%d"%s />',
              [HTMLPicMovieTag + HTMLNoPopupTag + IntToStr(Integer(Pointer(CurrentItem.Data))), iNumber, HTMLPicAttr])
          else
            Result := Result + Format('<img src="%s" alt="pic_movie_%d"%s />',
              [HTMLPicMovieTag + IntToStr(Integer(Pointer(CurrentItem.Data))), iNumber, HTMLPicAttr])
        else if (ATag = TAG_ITEMUSERAPPR10) or (ATag = TAG_ITEMUSERRATING10) then
        begin
          if EUserRating.Text <> '' then
          begin
            i := Round(StrToFloat(EUserRating.Text));
            if (ATag = TAG_ITEMUSERAPPR10) then
              Result := Result + Format('<img src="%s" alt="%d/10" />',
                [HTMLPicApprTag + IntToStr(Integer(Pointer(MStreamAppr10[i]))), i])
            else
              Result := Result + IntToStr(i);
          end;
        end else if (ATag = TAG_ITEMUSERAPPR4) or (ATag = TAG_ITEMUSERRATING4) then
        begin
          if EUserRating.Text <> '' then
          begin
            i := 0;
            case Trunc(StrToFloatTrunc(EUserRating.Text)*10) of
               0..29:  begin i := 0; end;
              30..49:  begin i := 1; end;
              50..69:  begin i := 2; end;
              70..89:  begin i := 3; end;
              90..100: begin i := 4; end;
            end;
            if (ATag = TAG_ITEMUSERAPPR4) then
              Result := Result + Format('<img src="%s" alt="%d/4" />',
                [HTMLPicApprTag + IntToStr(Integer(Pointer(MStreamAppr[i]))), i])
            else
              Result := Result + IntToStr(i);
          end;
        end else if ATag = TAG_ITEMUSERRATING then Result := Result + GetV(fieldUserRating, EUserRating.Text)
        else if (ATag = TAG_ITEMAPPR10) or (ATag = TAG_ITEMRATING10) then
        begin
          if ERating.Text <> '' then
          begin
            i := Round(StrToFloat(ERating.Text));
            if (ATag = TAG_ITEMAPPR10) then
              Result := Result + Format('<img src="%s" alt="%d/10" />',
                [HTMLPicApprTag + IntToStr(Integer(Pointer(MStreamAppr10[i]))), i])
            else
              Result := Result + IntToStr(i);
          end;
        end else if (ATag = TAG_ITEMAPPRECIATION) or (ATag = TAG_ITEMRATING4) then
        begin
          if ERating.Text <> '' then
          begin
            i := 0;
            case Trunc(StrToFloatTrunc(ERating.Text)*10) of
               0..29:  begin i := 0; end;
              30..49:  begin i := 1; end;
              50..69:  begin i := 2; end;
              70..89:  begin i := 3; end;
              90..100: begin i := 4; end;
            end;
            if (ATag = TAG_ITEMAPPRECIATION) then
              Result := Result + Format('<img src="%s" alt="%d/4" />',
                [HTMLPicApprTag + IntToStr(Integer(Pointer(MStreamAppr[i]))), i])
            else
              Result := Result + IntToStr(i);
          end;
        end else if ATag = TAG_ITEMRATING then Result := Result + GetV(fieldRating, ERating.Text)
        // Custom fields value
        else
        begin
          Found := False;
          if MovieList <> nil then
          begin
            with MovieList.CustomFieldsProperties do
              // Replace long tag before short tag (alphabetic order)
              // Ex: $$LABEL_CF_TEST1 replaced before $$LABEL_CF_TEST
              for i := Count-1 downto 0 do
                if ATag = TAG_ITEM_CF + UpperCase(Strings[i]) then
                begin
                  Result := Result + GetCFV(Strings[i], i);
                  Found := True;
                  break;
                end;
            if (not Found) then
            begin
              if ATag = TAG_FILENAME then Result := Result + ExtractFileName(HTMLTemplateFileRef)
              else if ATag = TAG_FILEPATH then Result := Result + ExtractFileName(HTMLTemplateFileRef)
              else if ATag = TAG_TOTALMOVIES then Result := Result + IntToStr(NbMoviesVisible)
              else if ATag = TAG_TOTALDISKS then
              begin
                c := 0;
                StoreSelectedState;
                for i := 0 to MovieList.Count-1 do
                  if TMovie(MovieList.Items[i]).CanInclude(mioVisible) then
                    Inc(c, TMovie(MovieList.Items[i]).iDisks);
                Result := Result + IntToStr(c);
              end
              else if ATag = TAG_DATE then Result := Result + DateToStr(Date)
              else if ATag = TAG_TIME then Result := Result + TimeToStr(Time)
              else if ATag = TAG_OWNERNAME then Result := Result + MovieList.MovieProperties.strName
              else if ATag = TAG_OWNERMAIL then Result := Result + MovieList.MovieProperties.strMail
              else if ATag = TAG_OWNERSITE then Result := Result + MovieList.MovieProperties.strSite
              else if HTMLTemplateContainsExtras and (strListExtraTags.IndexOf(ATag) <> -1) then
                Result := Result + ATag
              else if strListTags.IndexOf(ATag) = -1 then
                Result := Result + ATag;
            end;
          end;
        end;
      end; // with
    end; // for
    if HTMLTemplateContainsExtras then
      ReplaceTagsExtras(Result, TMovie(CurrentItem.Data), LineBreak, HTMLExtraPicAttr);
  end
  else
  begin
    Result := Settings.rOptions.rMovieInformation.HTMLNoMoviePage;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ReplaceTagsExtras(var Page: string; const AMovie: TMovie;
  const LineBreak: string; const HTMLExtraPicAttr: string);
var
  Output, Part, Category, Checked, tmp: string;
  ExtraRecNr, NrStart, NrEnd: Integer;
  EndPos, p, i: Integer;
  bChecked: Boolean;
begin
  while Length(Page) > 0 do
  begin
    if Pos(TAG_ITEMEXTRABEGIN, Page) = 1 then
    begin
      Delete(Page, 1, Length(TAG_ITEMEXTRABEGIN));

      Category := '';
      Checked := '';
      bChecked := False;
      NrStart := 1;
      NrEnd := AMovie.Extras.Count;
      if Page[1] = '(' then
      begin
        p := Pos(')', Page);
        if p > 0 then
        begin
          Category := Trim(Copy(Page, 2, p-2));
          Delete(Page, 1, p);
          i := Pos(',', Category);
          if i > 0 then
          begin
            Checked := Trim(Copy(Category, i+1, Length(Category)-i));
            Category := Trim(Copy(Category, 1, i-1));
            i := Pos(',', Checked);
            if i > 0 then
            begin
              tmp := Trim(Copy(Checked, i+1, Length(Checked)-i));
              Checked := Trim(Copy(Checked, 1, i-1));
              i := Pos(',', tmp);
              if i > 0 then
              begin
                NrStart := StrToIntDef(Trim(Copy(tmp, 1, i-1)), NrStart);
                NrEnd := StrToIntDef(Trim(Copy(tmp, i+1, Length(tmp)-i)), NrEnd);
              end else
                NrStart := StrToIntDef(tmp, NrStart);
            end;
            if (Checked <> '') then
              bChecked := not ((Checked[1] = '0') or (Checked[1] = 'f') or (Checked[1] = 'F'));
          end;
        end;
      end;
      
      EndPos := Pos(TAG_ITEMEXTRAEND, Page);
      if EndPos = 0 then
        EndPos := Length(Page) + 1;

      ExtraRecNr := 1;
      with AMovie.Extras do
      begin
        i := 0;
        while (i < Count) do
        begin
          if ((Category = '') or Items[i].InCategory(Category)) and
           ((Checked = '') or (Items[i].bChecked = bChecked)) then
          begin
            if (ExtraRecNr >= NrStart) and (ExtraRecNr <= NrEnd) then
            begin
              Part := Copy(Page, 1, EndPos-1);
              ReplaceTagsExtra(Part, AMovie, Items[i], LineBreak, HTMLExtraPicAttr, ExtraRecNr);
              Output := Output + Part;
            end;
            Inc(ExtraRecNr);
          end;
          Inc(i);
        end;
      end;
      if EndPos <> (Length(Page) + 1) then
        Inc(EndPos, Length(TAG_ITEMEXTRAEND));
    end else
    begin
      EndPos := Pos(TAG_ITEMEXTRABEGIN, Page);
      if EndPos = 0 then
        EndPos := Length(Page) + 1;
      Part := Copy(Page, 1, EndPos-1);
      ReplaceTagsExtra(Part, AMovie, nil, LineBreak, HTMLExtraPicAttr, 0);
      Output := Output + Part;
    end;
    Delete(Page, 1, EndPos-1);
  end;
  Page := Output;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ReplaceTagsExtra(var Page: string; const AMovie: TMovie;
  const AExtra: TMovieExtra; const LineBreak: string; const HTMLExtraPicAttr: string;
  const ExtraRecNr: Integer);

  function Highlight(Text: string) : string;
  var
    p1, p: Integer;
  begin
    with Settings.rOptions.rMovieInformation do
      if (HTMLSearchFontTextColor = '') and (HTMLSearchBackTextColor = '') then
        Result := Text
      else
      begin
        Result := '';
        p1 := 1;
        p := AnsiPosEx(EValue.Text, Text, True, True, p1);
        while p > 0 do
        begin
          Result := Result + copy(Text, p1, p - p1) + '<font';
          if HTMLSearchFontTextColor <> '' then
            Result := Result + ' color=' + HTMLSearchFontTextColor;
          if HTMLSearchBackTextColor <> '' then
            Result := Result + ' style="background-color: ' + HTMLSearchBackTextColor + ';"';
          Result := Result + '>' + copy(Text, p, Length(EValue.Text)) + '</font>';
          p1 := p + Length(EValue.Text);
          p := AnsiPosEx(EValue.Text, Text, True, True, p1);
        end;
        Result := Result + copy(Text, p1, MaxInt);
      end;
  end;

  function GetV(Field: Integer; Text: string; Multilines: Boolean = False) : string;
  begin
    if (Length(EValue.Text) > 1) and ((cbxField.ItemIndex = 0) or
      (Field = Integer(cbxField.Items.Objects[cbxField.ItemIndex]) - 1)) and
      (GetFieldType(Field) <> ftUrl) then
      Text := Highlight(Text);
      //Text := StringReplace(Text, EValue.Text, '<b><font color=#FF0000>'+EValue.Text+'</font></b>', [rfReplaceAll, rfIgnoreCase]);
    if Multilines and (LineBreak <> '') then
      Text := StringReplace(Text, #13#10, LineBreak, [rfReplaceAll]);
    Result := Text;
  end;

  function GetValue(tag: string; extra: TMovieExtra; var value: string): Boolean;
  begin
    Result := False;
    if extra = nil then
      exit;
    Result := True;
    with extra do
      if tag = TAG_ITEMEXTRARECNR then value := IntToStr(ExtraRecNr)
      else if tag = TAG_ITEMEXTRANUMBER then value := GetV(extraFieldNumber, GetFieldValue(extraFieldNumber))
      else if tag = TAG_ITEMEXTRACHECKED then value := IfThen(bChecked, 'x', ' ')
      else if tag = TAG_ITEMEXTRATAG then value := GetV(extraFieldTag, strTag)
      else if tag = TAG_ITEMEXTRATITLE then value := GetV(extraFieldTitle, strTitle)
      else if tag = TAG_ITEMEXTRACATEGORY then value := GetV(extraFieldCategory, strCategory)
      else if tag = TAG_ITEMEXTRAURL then value := GetV(extraFieldUrl, strUrl)
      else if tag = TAG_ITEMEXTRADESCRIPTION then value := GetV(extraFieldDescription, strDescription, True)
      else if tag = TAG_ITEMEXTRACOMMENTS then value := GetV(extraFieldComments, strComments, True)
      else if tag = TAG_ITEMEXTRACREATEDBY then value := GetV(extraFieldCreatedBy, strCreatedBy)
      else if tag = TAG_ITEMEXTRAPICSTATUS then value := GetV(extraFieldPictureStatus, GetFieldValue(extraFieldPictureStatus))
      else if (tag = TAG_ITEMEXTRAPICFILENAMENP) or (tag = TAG_ITEMEXTRAPICFILENAME) then
      begin
        value := HTMLPicExtraTag;
        if (tag = TAG_ITEMEXTRAPICFILENAMENP) then
          value := value + HTMLNoPopupTag;
        value := value + IntToStr(Integer(Pointer(extra)));
      end
      else if (tag = TAG_ITEMEXTRAPICTURENP) or (tag = TAG_ITEMEXTRAPICTURE) then
        if (tag = TAG_ITEMEXTRAPICTURENP) then
          value := Format('<img src="%s" alt="pic_extra_%d_%d"%s />',
            [HTMLPicExtraTag + HTMLNoPopupTag + IntToStr(Integer(Pointer(extra))), AMovie.iNumber, iNumber, HTMLExtraPicAttr])
        else
          value := Format('<img src="%s" alt="pic_extra_%d_%d"%s />',
            [HTMLPicExtraTag + IntToStr(Integer(Pointer(extra))), AMovie.iNumber, iNumber, HTMLExtraPicAttr])
      else
        Result := False;
  end;

var
  i, j, k, t, lastPos, idx: integer;
  ATag, Value, Output, tmp : string;
  Found, Found2 : Boolean;
  ExtraTmp: TMovieExtra;
begin
  i := 1;
  lastPos := 1;
  Output := '';
  if Page = '' then
    exit;
  while (Page[i] <> #0) do
  begin
    if (Page[i] = '$') and (Page[i+1] = '$') then
    begin
      // Fields
      Found := False;
      t := 0;
      while (not Found) and (t < strListExtraTags.Count) do
      begin
        ATag := strListExtraTags.Strings[t];
        j := 1;
        while (not Found) and (Page[i+j-1] <> #0) and (ATag[j] <> #0) do
        begin
          if (Page[i+j-1] <> ATag[j]) then
            break;
          if (ATag[j+1] = #0) then
          begin
            if (i <> lastPos) then
              Output := Output + Copy(Page, lastPos, i-lastPos);
            if Page[i+j] = '(' then
            begin
              k := 1;
              Found2 := False;
              while (not Found2) and (Page[i+j+k] <> #0) do
              begin
                if Page[i+j+k] = ')' then
                begin
                  tmp := Trim(Copy(Page, i+j+1, k-1));
                  if tmp <> '' then
                  begin
                    idx := AMovie.Extras.FindExtra(tmp);
                    if idx <> -1 then
                    begin
                      ExtraTmp := AMovie.Extras.Items[idx];
                      Value := ATag+'('+tmp+')';
                      GetValue(ATag, ExtraTmp, Value);
                      Output := Output + Value;
                    end;
                  end else
                  begin
                    Value := ATag+'()';
                    GetValue(ATag, AExtra, Value);
                    Output := Output + Value;
                  end;
                  Found2 := True;
                end;
                Inc(k);
              end;
              if Found2 then
                lastPos := i+j+k
              else
              begin
                Value := ATag;
                GetValue(ATag, AExtra, Value);
                Output := Output + Value;
                lastPos := i+j;
              end;
            end else
            begin
              Value := ATag;
              GetValue(ATag, AExtra, Value);
              Output := Output + Value;
              lastPos := i+j;
            end;
            i := lastPos-1; // i is incremented by 1 after
            Found := True;
          end;
          Inc(j)
        end;
        Inc(t);
      end; // End while
    end;
    Inc(i);
  end;
  if (i <> lastPos) then
  begin
    Output := Output + Copy(Page, lastPos, i-lastPos);
  end;
  Page := Output;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerImageRequest(Sender: TObject;
  const SRC: String; var Stream: TMemoryStream);
var
  Movie: TMovie;
  Extra: TMovieExtra;
  Picture: TMoviePicture;
  RStream: TResourceStream;
  ImageFileName: string;
begin
  if StartsStr(HTMLPicMovieTag, SRC) or StartsStr(HTMLPicExtraTag, SRC) then
  begin
    if StartsStr(HTMLPicMovieTag, SRC) then
    begin
      Movie := TMovie(Pointer(StrToInt(StringReplace(StringReplace(
        SRC, HTMLPicMovieTag, '', []), HTMLNoPopupTag, '', []))));
      Picture := Movie.Picture;
    end else
    begin
      Extra := TMovieExtra(Pointer(StrToInt(StringReplace(StringReplace(
        SRC, HTMLPicExtraTag, '', []), HTMLNoPopupTag, '', []))));
      Picture := Extra.Picture;
      Movie := nil;
    end;
    Picture.Lock;
    try
      if Picture.PicStream <> nil then
      begin
        Picture.PicStream.Seek(0, soBeginning);
        MStream.LoadFromStream(Picture.PicStream);
        Stream := MStream;
      end else
      begin
        if Picture.PicPath = '' then
        begin
          if Movie <> nil then
            ImageFileName := strFileNoPicture
          else
            ImageFileName := strFileNoPicture2;
          if FileExists(ImageFileName) then
          begin
            try
              MStream.LoadFromFile(ImageFileName);
              Stream := MStream;
            finally
            end;
          end else
          begin
            if Movie <> nil then
              RStream := TResourceStream.Create(HInstance, 'nopicture', 'PNG')
            else
              RStream := TResourceStream.Create(HInstance, 'nopicture2', 'PNG');
            try
              MStream.LoadFromStream(RStream);
              Stream := MStream;
            finally
              RStream.Free;
            end;
          end;
        end
        else
        begin
          if FCatalogFile.CurrentFile <> '' then
            SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
          else
            SetCurrentDir(strDirCatalogs);
          ImageFileName := ExpandFileName(Picture.PicPath);
          if not FileExists(ImageFileName) then
            if Movie <> nil then
              ImageFileName := strFileNotFound
            else
              ImageFileName := strFileNotFound2;
          if FileExists(ImageFileName) then
          begin
            MStream.LoadFromFile(ImageFileName);
            Stream := MStream;
          end else
          begin
            if Movie <> nil then
              RStream := TResourceStream.Create(HInstance, 'filenotfound', 'PNG')
            else
              RStream := TResourceStream.Create(HInstance, 'filenotfound2', 'PNG');
            try
              MStream.LoadFromStream(RStream);
              Stream := MStream;
            finally
              RStream.Free;
            end;
          end;
        end;
      end;
    finally
      Picture.UnLock;
    end;
  end else if StartsStr(HTMLPicApprTag, SRC) then
  begin
    Stream := TMemoryStream(Pointer(StrToInt(StringReplace(SRC, HTMLPicApprTag, '', []))));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerImageClick(Sender, Obj: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Movie: TMovie;
  Extra: TMovieExtra;
  Picture: TMoviePicture;
  Pt: TPoint;
begin
  if (SelectedItem <> CurrentItem) then // Not synchronized
    Exit;
  if (Obj is TImageObj) then
  begin
    if AnsiContainsStr(TImageObj(Obj).Source, HTMLNoPopupTag) then
      exit;
    if (Button = mbLeft) then
    begin
      if StartsStr(HTMLPicMovieTag, TImageObj(Obj).Source) or StartsStr(HTMLPicExtraTag, TImageObj(Obj).Source) then
      begin
        if StartsStr(HTMLPicMovieTag, TImageObj(Obj).Source) then
        begin
          Movie := TMovie(Pointer(StrToInt(StringReplace(TImageObj(Obj).Source, HTMLPicMovieTag, '', []))));
          Picture := Movie.Picture;
        end else
        begin
          Extra := TMovieExtra(Pointer(StrToInt(StringReplace(TImageObj(Obj).Source, HTMLPicExtraTag, '', []))));
          Picture := Extra.Picture;
        end;
        Picture.Lock;
        try
          if (Picture.PicPath <> '') then
            if (Picture.PicStream <> nil) then
            begin
              PictureWin := TPictureWin.Create(Self);
              try
                PictureWin.Execute(Picture.GetPictureCaption, Picture.PicStream, Picture.PicPath)
              finally
                FreeAndNil(PictureWin);
              end;
            end else
            begin
              if FCatalogFile.CurrentFile <> '' then
                SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
              else
                SetCurrentDir(strDirCatalogs);
              if FileExists(ExpandFileName(Picture.PicPath)) then
              begin
                PictureWin := TPictureWin.Create(Self);
                try
                  PictureWin.Execute(Picture.GetPictureCaption, ExpandFileName(Picture.PicPath))
                finally
                  FreeAndNil(PictureWin);
                end;
              end else
                MessageWin.Execute(Format(Messages.Strings[msgFileNotExists], [Picture.PicPath]), mtError, [mbOk]);
            end;
        finally
          Picture.Unlock;
        end;
      end;
    end
    else if (Button = mbRight) then
    begin
      if StartsStr(HTMLPicMovieTag, TImageObj(Obj).Source) then
      begin
        GetCursorPos(Pt);
        PopupImage.Popup(Pt.X, Pt.Y);
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(Shift = [ssCtrl]) and (Key = Ord('C')) then
  begin
    HTMLViewer.CopyToClipboard;
  end
  else if(Shift = [ssCtrl]) and (Key = Ord('A')) then
  begin
    HTMLViewer.SelectAll;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerHotSpotClick(Sender: TObject;
  const SRC: String; var Handled: Boolean);
begin
  Handled := True;
  LaunchProg(SRC);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.HTMLViewerRightClick(Sender: TObject;
  Parameters: TRightClickParameters);
var
  Pt: TPoint;
  SavedURLBrowse: Boolean;
begin
  if (SelectedItem <> CurrentItem) then // Force synchronize
    ListView1AfterSelectionChange(nil);
  FSelectedURL := nil;
  FURL := '';
  if (Parameters.URL <> '') then
  begin
    FURL := Parameters.URL;
    GetCursorPos(Pt);
    SavedURLBrowse := ActionURLBrowse.Enabled;
    ActionURLBrowse.Enabled := False;
    ActionURLBrowse.Visible := ActionURLBrowse.Enabled;
    PopupEURL.Alignment := paLeft;
    PopupEURL.Popup(Pt.X, Pt.Y);
    PopupEURL.Alignment := paRight;
    ActionURLBrowse.Enabled := SavedURLBrowse;
    ActionURLBrowse.Visible := ActionURLBrowse.Enabled;
  end
  else if (Parameters.Image = nil) then
  begin
    GetCursorPos(Pt);
    if HTMLViewer.SelText <> '' then
      MnuHtmlCopy.Enabled := True
    else
      MnuHtmlCopy.Enabled := False;
    PopupHTMLViewer.Popup(Pt.X, Pt.Y);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MnuHtmlCopyClick(Sender: TObject);
begin
  HTMLViewer.CopyToClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.MnuHtmlEditClick(Sender: TObject);
var
  Idx: Integer;
begin
  SetCurrentDir(strDirTemplates);
  with Settings do
    if FileExists(ExpandFileName(rOptions.rFiles.HTMLTemplateFile)) then
    begin
      rHTMLEditor.HTMLLastTemplate := ExpandFileName(rOptions.rFiles.HTMLTemplateFile);
      rOptions.rFolders[fuTemplates].Value := ExtractFilePath(rHTMLEditor.HTMLLastTemplate);
      Idx := rHTMLEditor.HTMLMRU.IndexOf(rHTMLEditor.HTMLLastTemplate);
      if Idx <> -1 then
         rHTMLEditor.HTMLMRU.Delete(Idx);
      rHTMLEditor.HTMLMRU.Insert(0, rHTMLEditor.HTMLLastTemplate);
      if rHTMLEditor.HTMLMRU.Count > rOptions.rFiles.RecentFiles then
        rHTMLEditor.HTMLMRU.Delete(rHTMLEditor.HTMLMRU.Count-1);
    end;
  ActionHTMLEditorExecute(MnuHtmlEdit);
end;

{-------------------------------------------------------------------------------
  ThumbThread
-------------------------------------------------------------------------------}

constructor ThumbThread.Create(Thumbs: TrkSmartView; Items: TElTree; Movies: TMovieList);
begin
  MsgHandle := MainWindow.Handle;
  ThumbsViewer := Thumbs;
  ListView1 := Items;
  MovieList := Movies;
  FreeOnTerminate := False;
  inherited Create(False);
  Priority := tpLower;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure ThumbThread.Execute;
var
  id, nb, nb10, i: Integer;
  Movie: TMovie;
  InView: Boolean;
  PtTmp: TPoint;
  List: TIntList;
  InViewComplete: Boolean;
  PreviousInView: Boolean;
begin
  inherited;

  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
  begin
    id := 0;
    nb := 0;
    i := 0;
    PreviousInView := False;
    
    while (i < MovieList.Count) and (not Terminated) do
    begin
      if(MovieList.Items[i].Picture._thumb <> nil) or
        (MovieList.Items[i].Picture._thumbError > 0) then
        Inc(nb);
      Inc(i);
    end;

    if (nb < MovieList.Count) and (not Terminated) then
    begin
      nb10 := Trunc(10*nb/MovieList.Count);
      PostMessage(MsgHandle, CM_UpdateView, 0, nb10);
      PostMessage(MsgHandle, CM_UpdateView, 3, 1); // Show progress bar

      while (nb < MovieList.Count) and (not Terminated) do
      begin
        i := 0;
        InView := True;
        Movie := nil;
        ThumbsViewer.LockInView();
        while (i < ThumbsViewer.InView.Count) and
          ((Movie = nil) or (Movie.Picture._thumb <> nil) or (Movie.Picture._thumbError > 0)) do
        begin
          PtTmp := ThumbsViewer.InView.Points[i];
          if(PtTmp.X <> -1) then
            List := PSmartGroup(ThumbsViewer.SmartGroups.Items[PtTmp.X]).Items
          else
            List := ThumbsViewer.Items;
          Movie := TMovie(Pointer(List.Integers[PtTmp.Y]));
          Inc(i);
        end;
        InViewComplete := ThumbsViewer.InViewComplete;
        ThumbsViewer.UnlockInView();

        if (Movie = nil) or (Movie.Picture._thumb <> nil) or (Movie.Picture._thumbError > 0) then
        begin
          InView := False;
          while (MovieList.Items[id].Picture._thumb <> nil) or (MovieList.Items[id].Picture._thumbError > 0) do
          begin
            Inc(id);
            if (id > MovieList.Count) then
              id := 0;
          end;
          Movie := MovieList.Items[id];
        end;

        Movie.Picture.Lock;
        MainWindow.ThumbsGetThumbnail(ThumbsViewer, Movie.Picture);
        Movie.Picture.Unlock;
        Inc(nb);

        if InView or not InViewComplete then
        begin
          nb10 := Trunc(10*nb/MovieList.Count);
          PostMessage(MsgHandle, CM_UpdateView, 1, nb10);
          PreviousInView := True;
        end
        else if(Trunc(10*nb/MovieList.Count) > nb10) then
        begin
          nb10 := Trunc(10*nb/MovieList.Count);
          PostMessage(MsgHandle, CM_UpdateView, 0, nb10);
        end;
        if (not InView) and PreviousInView and InViewComplete then // Force to update view
        begin
          PostMessage(MsgHandle, CM_UpdateView, 2, nb10);
          PreviousInView := False
        end;
      end;

      if (not Terminated) then
        PostMessage(MsgHandle, CM_UpdateView, 2, 10) // Force to update view
      else
      begin
        nb10 := Trunc(10*nb/MovieList.Count);
        PostMessage(MsgHandle, CM_UpdateView, 2, nb10); // Force to update view
      end;
      PostMessage(MsgHandle, CM_UpdateView, 3, 0); // Hide progress bar
    end;
  end;
  MainWindow.ThreadDone := True;
end;

{-------------------------------------------------------------------------------
  ThumbsViewer
-------------------------------------------------------------------------------}

procedure TMainWindow.CMUpdateView(var message: TMessage);
begin
  if (message.WParam = 3) then
  begin
    if message.LParam = 0 then
      ThumbsProgress.Visible := False
    else
      ThumbsProgress.Visible := True;
  end else
  begin
    if (message.WParam = 2) or ((message.WParam = 1) and (Now > TimeUpdateView)) then
    begin
      ThumbsViewer.Invalidate;
      TimeUpdateView := IncMilliSecond(Now, 300);
    end;
    if (message.LParam >= 0) then
    begin
      if (message.LParam <> ThumbsProgress.Position) then
        ThumbsProgress.Position := message.LParam;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsGetThumbnail(Sender: TObject; Picture: TMoviePicture);
var
  ThumbBitmap, bmp: TBitmap;
  MS: TMemoryStream;
  RStream: TResourceStream;
  ThumbSize: TPoint;
  newW, newH: Integer;
  sf: Integer;
  Ext: String;
  Path: String;
  ThumbGraphic: TGraphic;
  isLock: Boolean;

begin
  ThumbBitmap := nil;
  bmp := nil;
  ThumbGraphic := nil;
  Path := '';
  isLock := False;
  MS := nil;

  if Picture.PicStream = nil then
  begin
    if Picture.PicPath = '' then
    begin
      Path := strFileNoPicture;
      if not FileExists(Path) then
      begin
        MS := TMemoryStream.Create;
        try
          RStream := TResourceStream.Create( HInstance, 'nopicture', 'PNG' );
          Path := '.png';
          try
            MS.LoadFromStream(RStream);
          finally
            RStream.Free;
          end;
        except
          FreeAndNil(MS);
        end;
      end;
    end
    else
    begin
      //Not good for multi-threading (SetCurrentDir share in same process) !!!
      //if FCatalogFile.CurrentFile <> '' then
      //  SetCurrentDir(ExtractFilePath(FCatalogFile.CurrentFile))
      //else
      //  SetCurrentDir(strDirCatalogs);
      //Path := ExpandFileName(Picture.PicPath);
      if (FCatalogFile.CurrentFile <> '') then
        Path := ExtractFilePath(FCatalogFile.CurrentFile) + Picture.PicPath;
      if not FileExists(Path) then
        Path := Picture.PicPath;
      if not FileExists(Path) then
        Path := strFileNotFound;
      if not FileExists(Path) then
      begin
        MS := TMemoryStream.Create;
        try
          RStream := TResourceStream.Create( HInstance, 'filenotfound', 'PNG' );
          Path := '.png';
          try
            MS.LoadFromStream(RStream);
          finally
            RStream.Free;
          end;
        except
          FreeAndNil(MS);
        end;
      end;
    end;
    Ext := LowerCase(ExtractFileExt(ExtractFileName(Path)))
  end else
  begin
    Ext := Picture.PicPath;
  end;

  case IndexText(Ext, extImage) of
    extPNG:
      ThumbGraphic := ThumbPNG;
    extJPG, extJPE, extJPEG:
      ThumbGraphic := ThumbJPEG;
    extGIF:
      ThumbGraphic := ThumbGIF;
    extBMP:
      ThumbGraphic := ThumbBMP;
  else
    Picture._thumbError := 1;
  end;

  if Picture._thumbError = 0 then
  begin
    if ThumbGraphic = ThumbJPEG then
    begin
      if (MS <> nil) then
        GetJPGSize(MS, WI, HI)
      else if (Picture.PicStream <> nil) then
        GetJPGSize(Picture.PicStream, WI, HI)
      else
        GetJPGSizeFromFile(Path, WI, HI);

      if WI < 1 then
        WI := 1;
      if HI < 1 then
        HI := 1;
      sf := Trunc(Min(HI / 255, WI / 255));
      if sf < 0 then
        sf := 0;
      case sf of
        0..1: ThumbJPEG.Scale := jsFullSize;
        2..3: ThumbJPEG.Scale := jsHalf;
        4..7: ThumbJPEG.Scale := jsQuarter;
      else
        ThumbJPEG.Scale := jsEighth;
      end;
    end;

    try
      if (MS <> nil) then
      begin
        MS.Seek(0, soBeginning);
        ThumbGraphic.LoadFromStream(MS);
        FreeAndNil(MS);
      end else if (Picture.PicStream <> nil) then
      begin
        Picture.PicStream.Seek(0, soBeginning);
        ThumbGraphic.LoadFromStream(Picture.PicStream);
      end else
        ThumbGraphic.LoadFromFile(Path);

      bmp := TBitmap.Create;
      bmp.PixelFormat := pf24Bit;
      bmp.Width := ThumbGraphic.Width;
      bmp.Height := ThumbGraphic.Height;
      bmp.Canvas.Lock;
      isLock := True;
      ThumbBMP.Canvas.Lock;
      bmp.Canvas.Draw(0, 0, ThumbGraphic);
      ThumbBMP.Canvas.Unlock;

      try
        ThumbBitmap := TBitmap.Create;
        ThumbBitmap.Canvas.Lock;
        ThumbSize := CalcImageSize(bmp.Width, bmp.Height,
          ThumbSizeW, ThumbSizeH);
        newW := ThumbSize.X;
        newH := ThumbSize.Y;
        if newW <= 0 then
          newW := 1;
        if newH <= 0 then
          newH := 1;
        ThumbBitmap.PixelFormat := pf24Bit;
        ThumbBitmap.Width := newW;
        ThumbBitmap.Height := newH;
        MakeThumbNail(bmp, ThumbBitmap);
      except
        ThumbBitmap.Canvas.UnLock;
        FreeAndNil(ThumbBitmap);
        Picture._thumbError := 3;
      end;

      bmp.Canvas.UnLock;
      bmp.Free;
    except
      Picture._thumbError := 2;
      FreeAndNil(MS);
      if (bmp <> nil) then
      begin
        if (isLock) then
          bmp.Canvas.Unlock;
        bmp.Free;
      end;
    end;

    if ThumbBitmap <> nil then
    begin
      MS := TMemoryStream.Create;
      MS.Seek(0, soBeginning);
      try
        ThumbJPEG.Assign(ThumbBitmap);
        ThumbJPEG.Compress;
        ThumbJPEG.SaveToStream(MS);
        Picture._thumb := MS;
        Picture._thumbWidth := ThumbBitmap.Width;
        Picture._thumbHeight := ThumbBitmap.Height;
      except
        MS.Free;
        Picture._thumbError := 4;
      end;
      ThumbBitmap.Canvas.UnLock;
      ThumbBitmap.Free;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.StartThumbThread;
begin
  if (ListView1.Items.Count > 0) then
  begin
    if ThumbThr = nil then
    begin
      ThreadDone := False;
      ThumbThr := ThumbThread.Create(ThumbsViewer, ListView1, MovieList);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.StopThumbThread;
begin
  if ThumbThr <> nil then
  begin
    ThumbThr.Terminate;
    ThumbThr.WaitFor;
    ThumbThr.Free;
    ThumbThr := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ClearThumbsPool;
var
  i: Integer;
  Thumb: PCacheItem;
begin
  for i := ThumbsPool.Count - 1 downto 0 do
  begin
    Thumb := ThumbsPool[i];
    if Thumb.Bmp <> nil then
      Thumb.Bmp.Free;
    Dispose(Thumb);
  end;
  ThumbsPool.Clear;
  PoolSize := 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerStop;
begin
  StopThumbThread;
  ThumbsViewer.Clear;
  ClearThumbsPool;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerStart;
var
  Grp, Idx: Integer;
  iData: Int64;
  Item: TElTreeItem;
  Group: PSmartGroup;
begin
  ThumbsViewerStop;
  ThumbsViewer.OnCellSelectedChange := nil;
  if ActionDisplayThumbnails.Checked then
  begin
    Group := nil;
    if (FGroupField <> -1) then
    begin
      Grp := -1;
      ThumbsViewer.Grouped := True;
      Item := ListView1.Items.GetFirstNode;
      while (Item <> nil) do
      begin
        if(Item.Data = nil) then
        begin
          Grp := ThumbsViewer.AddSmartGroup(Item.Text);
          Group := PSmartGroup(ThumbsViewer.SmartGroups.Items[Grp]);
          Group.Expanded := Item.Expanded;
          if (Item.Selected) then
            ThumbsViewer.AddSelection(-1-Item.Index, Grp, -1);
        end else
        begin
          iData := ULong(Pointer(Item.Data));
          Idx := Group.Items.Add(iData);
          if (Item.Selected and (Item = TMovie(Item.Data)._selectedItem)) then
            ThumbsViewer.AddSelection(iData, Grp, Idx);
        end;
        Item := Item.GetNext;
      end;
    end
    else
    begin
      ThumbsViewer.Grouped := False;
      Item := ListView1.Items.GetFirstNode;
      while (Item <> nil) do
      begin
        if Item.Data <> nil then
        begin
          iData := ULong(Pointer(Item.Data));
          Idx := ThumbsViewer.Items.Add(iData);
          if (Item.Selected and (Item = TMovie(Item.Data)._selectedItem)) then
            ThumbsViewer.AddSelection(iData, -1, Idx);
        end;
        Item := Item.GetNext;
      end;
    end;

    ThumbsViewer.CalcView(True);
    SetThumbSize((ThumbsSizer.Position shl 4) - 1, False);
    if ListView1.ItemFocused <> nil then
    begin
      if ListView1.ItemFocused.Data = nil then
      begin
        ThumbsViewer.IdxGrp := ListView1.ItemFocused.Index;
        ThumbsViewer.IdxItem := -1;
      end else
      begin
        if ListView1.ItemFocused.Parent <> nil then
          ThumbsViewer.IdxGrp := ListView1.ItemFocused.Parent.Index
        else
          ThumbsViewer.IdxGrp := -1;
        ThumbsViewer.IdxItem := ListView1.ItemFocused.Index;
      end;
    end;
    ThumbsViewerEnsureVisiblePlus;
    ThumbsViewer.Invalidate;
    TimeUpdateView := IncMilliSecond(Now, 300);
    StartThumbThread;
  end;
  ThumbsViewer.OnCellSelectedChange := ThumbsViewerCellSelectedChange;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.GenCellColors;
begin
  cHot := $00FFFFFF;
  cGHotStart := $00FFFFFF;
  cGHotEnd := $00FFFFFF;
  cShadeHot := $00FFFFFF;
  cSelected := $00FF9000;
  cGSelectedStart := $00FFA93A;
  cGSelectedEnd := $00FFC775;
  cShadeSelect := $00FFD59A;
  cSelectedFocused := $00FF7000;
  cGSelectedFocusedStart := $00FF8F19;
  cGSelectedFocusedEnd := $00FFAD55;
  cShadeSelectFocused := $00FFC78C;

  cDisabled := cSelected;
  cGDisabledStart := cGSelectedStart;
  cGDisabledEnd := cGSelectedEnd;
  cShadeDisabled := cShadeSelect;
  cDisabledFocused := cSelectedFocused;
  cGDisabledFocusedStart := cGSelectedFocusedStart;
  cGDisabledFocusedEnd := cGSelectedFocusedEnd;
  cShadeDisabledFocused := cShadeSelectFocused;
  cGHeaderStart := $00F9F9F9;
  cGHeaderEnd := $00FEFEFE;
  cGHeaderHotStart := $00FFEDBD;
  cGHeaderHotEnd := $00FFF7E3;
  cGHeaderSelStart := $00FCEABA;
  cGHeaderSelEnd := $00FCF4E0;
  cBackground := clWindow;
  cLineHighLight := $00FEFBF6;
  CellBkgColor := clWindow;
  CellBrdColor[False, False] := $00B5B5B5;
  CellBrdColor[False, True] := cSelected;
  CellBrdColor[True, False] := $00B5B5B5;
  CellBrdColor[True, True] := cSelected;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ItemPaintBasic(Canvas: TCanvas; R: TRect; State: TsvItemState; Focused: Boolean);
var
  C: TColor;
  R1: TRect;
begin
  R1 := R;
  if R1.Right < 48 then
    R1.Right := 48;
  Canvas.Brush.Style := bsClear;

  if (State = svSelected) or (State = svHot) or (State = svHotSelected) then
  begin
    if (ThumbsViewer.Focused) and ((State = svSelected) or (State = svHotSelected)) then
    begin
      if not Focused then
      begin
        Canvas.Pen.Color:= cSelected;
        GradientFill(Canvas, R1, cGSelectedStart, cGSelectedEnd, tgTopBottom);
        C:= cShadeSelect
      end
      else
      begin
        Canvas.Pen.Color:= cSelectedFocused;
        GradientFill(Canvas, R1, cGSelectedFocusedStart, cGSelectedFocusedEnd, tgTopBottom);
        C:= cShadeSelectFocused
      end;
    end
    else if (State = svHot) then
    begin
      Canvas.Pen.Color:= cHot;
      GradientFill(Canvas, R1, cGHotStart, cGHotEnd, tgTopBottom);
      C:= cShadeHot;
    end else
    begin
      Canvas.Pen.Color:= cDisabled;
      if not Focused then
      begin
        Canvas.Pen.Color:= cDisabled;
        GradientFill(Canvas, R1, cGDisabledStart, cGDisabledEnd, tgTopBottom);
        C:= cShadeDisabled;
      end
      else
      begin
        Canvas.Pen.Color:= cDisabledFocused;
        GradientFill(Canvas, R1, cGDisabledFocusedStart, cGDisabledFocusedEnd, tgTopBottom);
        C:= cShadeDisabledFocused;
      end;
    end;
    Canvas.Rectangle(R1);

    Canvas.Pen.Color:= C;
    Canvas.MoveTo(R1.Left + 1, R1.Top + 2);
    Canvas.LineTo(R1.Left + 1, R1.Bottom - 2);
    Canvas.LineTo(R1.Right - 2, R1.Bottom - 2);
    Canvas.LineTo(R1.Right - 2, R1.Top + 1);

    Canvas.Pen.Style:= psSolid;
    Canvas.Pixels[R1.Left, R1.Top]:= C;
    Canvas.Pixels[R1.Left, R1.Bottom - 1]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Top]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Bottom - 1]:= C;
  end;

  if Focused and not ((State = svSelected) or (State = svHotSelected)) then
  begin
    if (ThumbsViewer.Focused) then
    begin
      Canvas.Pen.Color := cSelectedFocused;
      C:= cShadeSelectFocused;
    end
    else
    begin
      Canvas.Pen.Color := cDisabledFocused;
      C:= cShadeDisabledFocused;
    end;
    Canvas.Rectangle(R1);

    Canvas.Pen.Style:= psSolid;
    Canvas.Pixels[R1.Left, R1.Top]:= C;
    Canvas.Pixels[R1.Left, R1.Bottom - 1]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Top]:= C;
    Canvas.Pixels[R1.Right - 1, R1.Bottom - 1]:= C;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.SetThumbSize(Value: Integer; UpdateTrackbar: Boolean);
var
  w, h: Integer;
begin
  case Value of
    31..63: CellJpeg.Scale := jsQuarter;
    64..127: CellJpeg.Scale := jsHalf;
    128..255: CellJpeg.Scale := jsFullSize;
  else
    CellJpeg.Scale := jsEighth;
  end;
  w := Trunc(Value*0.75);
  h := Value;
  w := w + 10;
  if ThumbsDisplayTitle.Checked then
  begin
    CellStyle := 1;
    h := h + 30;
  end else
  begin
    CellStyle := 0;
    h := h + 10;
  end;
  ThumbsViewer.CellWidth := w;
  ThumbsViewer.CellHeight := h;
  CellScale := Value;
  if UpdateTrackbar then
  begin
    ThumbsSizer.OnChange := nil;
    ThumbsSizer.Position := Trunc((CellScale + 1) shr 4);
    ThumbsSizer.OnChange := ThumbsSizerChange;
  end;
  ThumbsViewer.CalcView(False);
  ThumbsViewer.Invalidate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TMainWindow.GetThumbBmp(Picture: TMoviePicture): TBitmap;
var
  i, n, sf: Integer;
  p: PCacheItem;
  Bmp, tmp: TBitmap;
  pt: TPoint;
  Oldest: TDateTime;
begin
  Result := nil;
  // if we have thumbs, see if we can find it...
  if ThumbsPool.Count > 0 then
  begin
    i := ThumbsPool.Count - 1;
    while (i >= 0) and (PCacheItem(ThumbsPool[i]).Picture <> Picture) do
      i := i - 1;
    if i <> -1 then
    begin
      p := ThumbsPool[i];
      if (p.Picture = Picture) then
      begin
        if (p.Scale = CellScale) then
        begin
          p.Age := Now;
          Result := p.Bmp
        end
        else
        begin
          PoolSize := PoolSize - p.Size;
          p.Bmp.Free;
          Dispose(p);
          ThumbsPool.Delete(i);
        end;
      end;
    end;
  end;
  // if we dont have a thumb, make one...
  if Result = nil then
  begin
    if Picture._thumb <> nil then
    begin
      sf := Trunc(Min(Picture._thumbWidth / Trunc(CellScale*0.75), Picture._thumbHeight / CellScale));
      if sf < 0 then
        sf := 0;
      case sf of
        0..1: CellJPEG.Scale := jsFullSize;
        2..3: CellJPEG.Scale := jsHalf;
        4..7: CellJPEG.Scale := jsQuarter;
      else
        CellJPEG.Scale := jsEighth;
      end;
      Picture._thumb.Seek(0, soBeginning);
      CellJPEG.LoadFromStream(Picture._thumb);

      Bmp := TBitmap.Create;
      Bmp.PixelFormat := pf24bit;
      pt := CalcImageSize(CellJPEG.Width, CellJPEG.Height, Trunc(CellScale*0.75),
        CellScale);
      if pt.X <> CellJPEG.Width then
      begin
        tmp := TBitmap.Create;
        tmp.PixelFormat := pf24bit;
        tmp.Width := CellJPEG.Width;
        tmp.Height := CellJPEG.Height;
        tmp.Canvas.Draw(0, 0, CellJPEG);
        Bmp.Width := pt.X + 1;
        Bmp.Height := pt.Y + 1;
        if (Bmp.Width > 4) and (Bmp.Height > 4) then
          BiReSample(tmp, Bmp, False)
        else
          Bmp.Canvas.StretchDraw(Bmp.Canvas.ClipRect, tmp);
        tmp.Free;
      end
      else
      begin
        Bmp.Width := CellJPEG.Width;
        Bmp.Height := CellJPEG.Height;
        Bmp.Canvas.Draw(0, 0, CellJPEG);
      end;

      // Purge thumbs if needed
      while (PoolSize > MaxPool) and (ThumbsPool.Count > 0) do
      begin
        Oldest := Now;
        n := 0;
        for i := 0 to ThumbsPool.Count - 1 do
        begin
          p := ThumbsPool[i];
          if p.Age <= Oldest then
          begin
            Oldest := p.Age;
            n := i;
          end;
        end;
        Assert(n >= 0);
        p := ThumbsPool[n];
        PoolSize := PoolSize - p.Size;
        p.Bmp.Free;
        Dispose(p);
        ThumbsPool.Delete(n);
      end;

      New(p);
      p.Picture := Picture;
      p.Size := Bmp.Width * Bmp.Height;
      p.Age := Now;
      p.Scale := CellScale;
      p.Bmp := Bmp;
      ThumbsPool.Add(p);
      PoolSize := PoolSize + p.Size;
      Result := p.Bmp;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerCellPaint(Sender: TObject; Canvas: TCanvas;
  Cell: TRect; IdxGrp, IdxItem: Integer; Data: Int64; State: TsvItemState);
var
  X, Y: Integer;
  F, S: Boolean;
  R: TRect;
  TW, TH: Integer;
  Txt: string;
  Movie: TMovie;
  pt: TPoint;
  LockOk, ThumbOk: Boolean;
begin
  Movie := TMovie(Pointer(Data));
  LockOk := Movie.Picture.LockWait(0);
  if (LockOk) then
    ThumbOk := (Movie.Picture._thumb <> nil) and (Movie.Picture._thumbError = 0)
  else
    ThumbOk := False;

  ItemPaintBasic(Canvas, Cell, State,
    (ThumbsViewer.IdxGrp = IdxGrp) and (ThumbsViewer.IdxItem = IdxItem));

  F := ThumbsViewer.Focused;
  S := (State = svSelected) or (State = svHotSelected);

  if ThumbOk then
    pt := CalcImageSize(Movie.Picture._thumbWidth, Movie.Picture._thumbHeight, Trunc(CellScale*0.75),
      CellScale)
  else if (Movie.Picture._thumbError = 0) and (ThumbLoading <> nil) then
    pt := CalcImageSize(ThumbLoading.Width, ThumbLoading.Height, Trunc(CellScale*0.75),
      CellScale)
  else
    pt := CalcImageSize(Trunc(CellScale*0.75), CellScale, Trunc(CellScale*0.75),
      CellScale);

  TW := pt.X;
  TH := pt.Y;
  X := Cell.Left + ((Cell.Right - (Cell.Left + TW)) shr 1);
  Y := Cell.Top + ((Cell.Bottom - (Cell.Top + TH)) shr 1);
  if CellStyle <> 0 then
    Y := Y - 10;
  R.Left := X;
  R.Top := Y;
  R.Right := X + TW;
  R.Bottom := Y + TH;

  if ThumbOk then
  begin
    Canvas.Draw(X, Y, GetThumbBmp(Movie.Picture));
    Canvas.Pen.Color := CellBrdColor[F, S];
    InflateRect(R, 2, 2);
    Canvas.Rectangle(R);
    Canvas.Pen.Color := clWhite;
    InflateRect(R, -1, -1);
    Canvas.Rectangle(R);
  end
  else if (Movie.Picture._thumbError = 0) then
  begin
    if ThumbLoading <> nil then
    begin
      Canvas.Draw(X, Y, ThumbLoading);
    end else
    begin
      txt := 'Loading...';
      DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
      DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);
    end;
  end
  else
  begin
    R.Top := R.Top - 10;
    R.Bottom := R.Bottom - 10;

    txt := 'No Picture';
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
    DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);

    R.Top := R.Top + 20;
    R.Bottom := R.Bottom + 20;

    txt := 'Error '+ IntToStr(Movie.Picture._thumbError);
    DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
    DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);

    R.Top := R.Top - 10;
    R.Bottom := R.Bottom - 10;

    Canvas.Pen.Color := CellBrdColor[F, S];
    InflateRect(R, 2, 2);
    Canvas.Rectangle(R);
    Canvas.Pen.Color := clWhite;
    InflateRect(R, -1, -1);
    Canvas.Rectangle(R);
  end;

  if CellStyle <> 0 then
  begin
    with Settings.rOptions.rMovieList do
    begin
      if LinesColor then
      begin
        R := Cell;
        R.Top := R.Bottom - 18;
        R.Bottom := R.Bottom - 2;
        R.Left := R.Left + 2;
        R.Right := R.Right - 2;

        if ((State = svSelected) or (State = svHotSelected)) then
          if (ThumbsViewer.IdxGrp = IdxGrp) and (ThumbsViewer.IdxItem = IdxItem) then
            Canvas.Pen.Color := cSelectedFocused
          else
            Canvas.Pen.Color := cSelected
        else
          Canvas.Pen.Color := ColorsTag[Movie.iColorTag];
        Canvas.Brush.Color := ColorsTag[Movie.iColorTag];
        Canvas.Rectangle(R);
        Canvas.Pen.Color := clBlack;
      end;

      if CheckboxesInThumbs then // Futur option to show checkboxes in ThumbsViewer (add in preferences)
      begin
        R := Cell;
        R.Top := R.Bottom - 16;
        R.Left := R.Left + 4;
        R.Right := R.Left + 12;
        R.Bottom := R.Bottom - 4;
        if CheckboxesColor then
        begin
          Canvas.Pen.Color := clBlack;
          Canvas.Brush.Color := ColorsTag[Movie.iColorTag];
          Canvas.Rectangle(R);
          if Movie.bChecked then
          begin
            InflateRect(R, -4, -4);
            Canvas.Brush.Color := clBlack;
            Canvas.Rectangle(R);
          end;
        end else
        begin
          if Movie.bChecked then
            DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DFCS_BUTTONCHECK or DFCS_CHECKED)
          else
            DrawFrameControl(Canvas.Handle, R, DFC_BUTTON, DFCS_BUTTONCHECK);
        end;
        Canvas.Brush.Style := bsClear;

        R := Cell;
        R.Top := R.Bottom - 20;
        R.Left := R.Left + 4 + 16;
        R.Right := R.Right - 4;
      end
      else
      begin
        R := Cell;
        R.Top := R.Bottom - 20;
        R.Left := R.Left + 4;
        R.Right := R.Right - 4;
      end;
      txt := Movie.GetFormattedTitle;

      if not LinesColor and ((State = svSelected) or (State = svHotSelected)) then
        SetTextColor(Canvas.Handle, clWhite);
      if CheckboxesInThumbs then
        DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
          DT_SINGLELINE or DT_NOPREFIX or DT_LEFT or DT_VCENTER)
      else
        DrawText(Canvas.Handle, PChar(txt), Length(txt), R, DT_END_ELLIPSIS or
          DT_SINGLELINE or DT_NOPREFIX or DT_CENTER or DT_VCENTER);
      SetTextColor(Canvas.Handle, clBlack);
    end;
  end;
  if (LockOk) then
    Movie.Picture.Unlock
  else
    PostMessage(Self.Handle, CM_UpdateView, 1, -1) // Need to be refresh again later !
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerDividerPaint(Sender: TObject;
  Canvas: TCanvas; Cell: TRect; IdxGrp: Integer; Group: PSmartGroup;
  State: TsvItemState);
var
  R: TRect;
  txt: string;
  x: Integer;
  cFontColorSave: TColor;
begin
  cFontColorSave := Canvas.Font.Color;
  R := Cell;
  ItemPaintBasic(Canvas, Cell, State,
    (ThumbsViewer.IdxGrp = IdxGrp) and (ThumbsViewer.IdxItem = -1));
  if (Group.Expanded) then
  begin
    ListView1.MinusPicture.Transparent := True;
    Canvas.Draw(R.Left + 1, R.Top+2, ListView1.MinusPicture);
  end else
  begin
    ListView1.PlusPicture.Transparent := True;
    Canvas.Draw(R.Left + 1, R.Top+2, ListView1.PlusPicture);
  end;
  Canvas.Pen.Width := 1;
  Canvas.Brush.Style := bsClear;
  //Canvas.Font.Color := $00905422;
  R.Left := R.Left + 22;
  txt := Group.Caption;
  if (State = svSelected) or (State = svHotSelected) then
    SetTextColor(Canvas.Handle, clWhite);
  DrawText(Canvas.Handle, PChar(txt), Length(txt), R,
    DT_END_ELLIPSIS or DT_SINGLELINE or DT_NOPREFIX or DT_VCENTER);
  SetTextColor(Canvas.Handle, clBlack);
  x := Canvas.TextWidth(txt) + R.Left + 8;
  if x < R.Right - 8 then
  begin
    Canvas.Pen.Color := $00F0F0F0;
    Canvas.MoveTo(x, R.Top + 10);
    Canvas.LineTo(R.Right - 8, R.Top + 10);
    Canvas.Font.Color := cFontColorSave;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerHeaderPaint(Sender: TObject;
  Canvas: TCanvas; Header: TRect; Offset, Active: Integer;
  State: TsvItemState; Columns: array of Integer);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.EnsureVisibleThumbsViewer(IdxGrp: Integer; IdxItem: Integer);
begin
  if (ThumbsViewer.SmartGroups.Count > 0) or (ThumbsViewer.Items.Count > 0) then
  begin
    if (IdxGrp > -1) and (IdxItem > -1) then
    begin
      if PSmartGroup(ThumbsViewer.SmartGroups.Items[IdxGrp]).Expanded then
      begin
        ThumbsViewer.SetAtTop(IdxGrp, -1);
        ThumbsViewer.SetInView(IdxGrp, IdxItem);
      end else
        ThumbsViewer.SetAtTop(IdxGrp, -1);
    end else
    begin
      ThumbsViewer.SetAtTop(IdxGrp, IdxItem);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.EnsureVisibleThumbsViewer(Item: TElTreeItem);
begin
  if Item <> nil then
    if (Item.Parent <> nil) then
      EnsureVisibleThumbsViewer(Item.Parent.Index, Item.Index)
    else if (Item.Data <> nil) then
      EnsureVisibleThumbsViewer(-1, Item.Index)
    else
      EnsureVisibleThumbsViewer(Item.Index, -1);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerEnsureVisiblePlus;
begin
  if (ThumbsViewer.Items.Count > 0) or (ThumbsViewer.SmartGroups.Count > 0) then
    //if (NbMoviesSelected = 1) then
      //EnsureVisibleThumbsViewer(SelectedItem);
    EnsureVisibleThumbsViewer(ListView1.ItemFocused);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerSelecting(Sender: TObject; Count: Integer);
begin
  ListView1AfterSelectionChange(ThumbsViewer);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerCellFocusedChange(Sender: TObject;
  IdxGrp, IdxItem: Integer; Data: Int64);
var
  TreeItem: TElTreeItem;
begin
  ListView1.OnItemFocused := nil;
  ListView1.OnItemSelectedChange := nil;
  if (IdxGrp <> -1) or (IdxItem <> -1) then
  begin
    TreeItem := ListView1.Items[ThumbsViewer.GetAbsoluteIdx(IdxGrp, IdxItem) + IdxGrp + 1];
    if (TreeItem <> nil) and (ListView1.ItemFocused <> TreeItem) then
    begin
      ListView1.SetItemFocused(TreeItem, False);
    end;
  end
  else if (ListView1.ItemFocused <> nil) then
  begin
    ListView1.ItemFocused := nil;
  end;
  ListView1.OnItemFocused := ListView1ItemFocused;
  ListView1.OnItemSelectedChange := ListView1ItemSelectedChange;
  ListView1EnsureVisiblePlus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerCellSelectedChange(Sender: TObject;
  IdxGrp, IdxItem: Integer; Data: Int64; Selected: Boolean);
var
  TreeItem : TElTreeItem;
begin
  ListView1.OnAfterSelectionChange := nil;
  ListView1.OnItemSelectedChange := nil;
  ListView1.OnItemFocused := nil;
  if IdxItem <> -1 then
  begin
    TreeItem := ListView1.Items[ThumbsViewer.GetAbsoluteIdx(IdxGrp, IdxItem) + IdxGrp + 1];
    if (TreeItem <> nil) then
    begin
      if TreeItem.Selected <> Selected then
      begin
        TreeItem.Selected := selected;
        ListView1ItemSelectedChange(ThumbsViewer, TreeItem);
      end;
    end;
  end
  else if IdxGrp <> -1 then
  begin
    TreeItem := ListView1.Items[ThumbsViewer.GetAbsoluteIdx(IdxGrp, IdxItem) + IdxGrp + 1];
    if (TreeItem <> nil) then
    begin
      if TreeItem.Selected <> Selected then
      begin
        TreeItem.Selected := selected;
        ListView1ItemSelectedChange(ThumbsViewer, TreeItem);
      end;
    end;
  end;
  ListView1.OnAfterSelectionChange := ListView1AfterSelectionChange;
  ListView1.OnItemSelectedChange := ListView1ItemSelectedChange;
  ListView1.OnItemFocused := ListView1ItemFocused;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerCellHit(Sender: TObject; Canvas: TCanvas;
  IdxGrp, IdxItem: Integer; Data: Int64; x, y: Integer; Shift: TShiftState; Clicked: Boolean;
  Button: TMouseButton; var Selected: Boolean);
begin
  with Settings.rOptions.rMovieList do
    Selected := not CheckboxesInThumbs or (CellStyle = 0) or
      not ((x >= 4) and (x <= 16) and (y >= 4) and (y <= 16));
  if Selected then
    ThumbCheckboxOver := -1
  else
    ThumbCheckboxOver := Data;
  if Clicked then
    if Selected then
      Selected := (Button = mbLeft)
    else
      ThumbCheckboxClick := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerDividerHit(Sender: TObject; Canvas: TCanvas;
  IdxGrp: Integer; Group: PSmartGroup; x: Integer; Shift: TShiftState;
  Clicked: Boolean; Button: TMouseButton; var Selected: Boolean;
  var Expanded: Boolean);
begin
  Selected := (x > 20);
  if Clicked then
  begin
    Selected := False;
    Expanded := Group.Expanded;
    if Button = mbLeft then
    begin
      if (x <= 20) then
        Expanded := not Group.Expanded
      else
        Selected := True;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerDividerExpandedChange(Sender: TObject;
  IdxGrp: Integer; Group: PSmartGroup; Expanded: Boolean);
begin
  ListView1.OnItemExpand := nil;
  ListView1.OnItemCollapse := nil;
  ListView1.Items[ThumbsViewer.GetAbsoluteIdx(IdxGrp, 0) + IdxGrp].Expanded := Group.Expanded;
  ListView1.OnItemExpand := ListView1ItemExpand;
  ListView1.OnItemCollapse := ListView1ItemCollapse;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerHeaderClick(Sender: TObject;
  Column: Integer);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerDblClick(Sender: TObject);
begin
  if (ActionStretchList.Checked = True) and (ThumbsViewer.IdxItem > -1) then
  begin
    ActionStretchListExecute(ThumbsViewer);
  end
  else if (ThumbsViewer.IdxGrp <> -1) and (ThumbsViewer.IdxItem = -1) then
    with ThumbsViewer do
    begin
      ExpandSmartGroup(IdxGrp, not PSmartGroup(SmartGroups.Items[IdxGrp]).Expanded, False);
      CalcViewGroups;
      SetInView(IdxGrp, 0);
      Invalidate;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if (X <> FMouseMovieListX) or (Y <> FMouseMovieListY) then
  begin
    if (Settings.rOptions.rDisplay.AutoFocus) and
      (not ThumbsViewer.Focused) and ThumbsViewer.CanFocus then
      ThumbsViewer.SetFocus;
    UpdateCurrentItemIfNeeded;
    FMouseMovieListX := X;
    FMouseMovieListY := Y;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item: TElTreeItem;
begin
  if (ThumbCheckboxClick) then
  begin
    if (ThumbCheckboxOver > -1) and (ThumbsViewer.HotIdx = -2) then
    begin
      if (Button = mbLeft) then
      begin
        Item := TElTreeItem(TMovie(Pointer(ThumbCheckboxOver))._listItems.First);
        Item.Checked := not Item.Checked;
        ListView1ItemChecked(ThumbsViewer, Item);
      end else if(Button = mbRight) then
      begin
        Item := TElTreeItem(TMovie(Pointer(ThumbCheckboxOver))._listItems.First);
        ListView1ItemColorPick(ThumbsViewer, Item);
      end;
    end;
  end else
  begin
    if (Button = mbRight) then
    begin
      PopupMovieListPopup(ThumbsViewer);
      PopupMovieList.Popup(ThumbsViewer.ClientOrigin.X + X, ThumbsViewer.ClientOrigin.Y + Y);
    end;
  end;
  ThumbCheckboxClick := False;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  ListView1KeyUp(ThumbsViewer, Key, Shift);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsViewerResize(Sender: TObject);
begin
  ThumbsViewerEnsureVisiblePlus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsSizerChange(Sender: TObject);
begin
  SetThumbSize((ThumbsSizer.Position shl 4) - 1, False);
  ThumbsViewerEnsureVisiblePlus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ThumbsDisplayTitleClick(Sender: TObject);
begin
  ThumbsSizerChange(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TMainWindow.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
var
  mousePos: TPoint;
  wc: TWinControl;
begin
  if (Settings.rOptions.rDisplay.ScrollUnderPointer) then
  begin
    //mouse wheel scrolling for the control under the mouse
    if Msg.message = WM_MOUSEWHEEL then
    begin
      mousePos.X := Word(Msg.lParam);
      mousePos.Y := HiWord(Msg.lParam);
      wc := FindVCLWindow(mousePos);
      if wc = nil then
        Handled := True
      else
      if wc.Handle <> Msg.hwnd then
      begin
        SendMessage(wc.Handle, WM_MOUSEWHEEL, Msg.wParam, Msg.lParam);
        Handled := True;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
