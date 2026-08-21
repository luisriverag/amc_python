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

unit getscript;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ActnList, Menus,
  Tabs, ImgList, IniFiles,

  ifspas, ifs_var, ifpsclass, ifpsdate,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  SynEdit, SynEditHighlighter, SynEditMiscClasses, SynEditSearch, SynHighlighterPas,
  TB2Item, TBX, TB2MRU, TBXExtItems, TB2Toolbar, TBXStatusBars,
  AntStringList, AntJvLinkLabel, TBXDkPanels, TB2Dock, AntCorelButton, AntAutoHintLabel,

  base, MovieClass, FileManager, frameincludemov, getmedia, regexpr,
  getscript_readscripts, getscript_debug, memoform,

  IdIOHandlerStack, IdSSLOpenSSL, IdCookieManager, IdCompressorZLib;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type

  TIStatus = (iStopped, iRunning, iStepOver, iStepOverWaiting);
  TScriptWorkMode = (swmGetInfo, swmScripting);

const
  WM_CLOSEAFTERRUN = WM_USER + 1;

type
  TGetScriptWin = class(TBaseDlg)
    ActionDebugBreakpoint: TAction;
    ActionDebugBreakpointClear: TAction;
    ActionDebugEval: TAction;
    ActionDebugRun: TAction;
    ActionDebugRunToCursor: TAction;
    ActionDebugStep: TAction;
    ActionDebugStop: TAction;
    ActionDebugWatchAdd: TAction;
    ActionDebugWatchClear: TAction;
    ActionDebugWatchRemove: TAction;
    ActionDisplayEditor: TAction;
    ActionDisplayScripts: TAction;
    ActionEditCopy: TAction;
    ActionEditCut: TAction;
    ActionEditDelete: TAction;
    ActionEditFind: TAction;
    ActionEditFindNext: TAction;
    ActionEditPaste: TAction;
    ActionEditSelectAll: TAction;
    ActionEditUndo: TAction;
    ActionFileNew: TAction;
    ActionFileNoRecent: TAction;
    ActionFileOpen: TAction;
    ActionFileProperties: TAction;
    ActionFileSave: TAction;
    ActionFileSaveAs: TAction;
    ActionList1: TActionList;
    ActionListAll: TAction;
    ActionListNone: TAction;
    ActionOptionsDefault: TAction;
    ActionOptionsEdit: TAction;
    ActionViewDetailed: TAction;
    ActionViewFilter: TAction;
    ActionViewFilterChange: TAction;
    ActionViewList: TAction;
    CBCloseThis: TTBXCheckBox;
    CBShowResults: TTBXCheckBox;
    DockpanelExec: TTBXDockablePanel;
    DockpanelLimitations: TTBXDockablePanel;
    DockpanelOptions: TTBXDockablePanel;
    DockpanelWatch: TTBXDockablePanel;
    DockScriptLeft: TTBXMultiDock;
    DockScriptRight: TTBXMultiDock;
    EScript: TSynEdit;
    grpLimitFields: TGroupBox;
    grpScriptInfo: TGroupBox;
    http: TIdHTTP;
    lblScriptInfo: TAntJvLinkLabel;
    lstDebugImages: TImageList;
    lstLimitFields: TListView;
    lstLimitMovies: TIncludemovFrame;
    lstScriptOptions: TListView;
    lstScripts: TListView;
    lstWatch: TListBox;
    MenuPopupDebug: TTBXPopupMenu;
    MenuPopupEdit: TTBXPopupMenu;
    MenuPopupOptions: TTBXPopupMenu;
    Messages: TAntStringList;
    MnuDbp__1: TTBXSeparatorItem;
    MnuDbp__2: TTBXSeparatorItem;
    MnuDbpBrk: TTBXItem;
    MnuDbpEvl: TTBXItem;
    MnuDbpRtc: TTBXItem;
    MnuDbpSte: TTBXItem;
    MnuDbpWch: TTBXItem;
    MnuEdp__1: TTBXSeparatorItem;
    MnuEdp__2: TTBXSeparatorItem;
    MnuEdpAll: TTBXItem;
    MnuEdpCpy: TTBXItem;
    MnuEdpCut: TTBXItem;
    MnuEdpDel: TTBXItem;
    MnuEdpPst: TTBXItem;
    MnuEdpUnd: TTBXItem;
    MnuEdt__1: TTBXSeparatorItem;
    MnuEdt__2: TTBXSeparatorItem;
    MnuEdt__3: TTBXSeparatorItem;
    MnuEdt__4: TTBXSeparatorItem;
    MnuEdtBrc: TTBXItem;
    MnuEdtBrk: TTBXItem;
    MnuEdtEvl: TTBXItem;
    MnuEdtFnd: TTBXItem;
    MnuEdtFnx: TTBXItem;
    MnuEdtNew: TTBXItem;
    MnuEdtOpn: TTBXSubmenuItem;
    MnuEdtPro: TTBXItem;
    MnuEdtRec: TTBXItem;
    MnuEdtRtc: TTBXItem;
    MnuEdtRun: TTBXItem;
    MnuEdtSaa: TTBXItem;
    MnuEdtSav: TTBXItem;
    MnuEdtSte: TTBXItem;
    MnuEdtStp: TTBXItem;
    MnuEdtWch: TTBXItem;
    MnuFlt__1: TTBXSeparatorItem;
    MnuFltAll: TTBXItem;
    MnuFltNon: TTBXItem;
    MnuOpp__1: TTBXSeparatorItem;
    MnuOppDef: TTBXItem;
    MnuOppEdt: TTBXItem;
    MnuScrDet: TTBXItem;
    MnuScrFlt: TTBXSubmenuItem;
    MnuScrLst: TTBXItem;
    MnuScrRun: TTBXItem;
    MnuScrStp: TTBXItem;
    MnuTabEdt: TTBXItem;
    MnuTabScr: TTBXItem;
    PageControl1: TPageControl;
    Panel1: TPanel;
    pnlScriptInfo: TPanel;
    sbEditor: TTBXStatusBar;
    shtEditor: TTabSheet;
    shtScript: TTabSheet;
    Splitter1: TSplitter;
    SynEditSearch1: TSynEditSearch;
    SynPasSyn1: TSynPasSyn;
    tabScriptInfo: TTabSet;
    TBDock1: TTBXDock;
    TBMRUList1: TTBXMRUList;
    TBMRUListItem1: TTBXMRUListItem;
    TbsRun: TTBXSeparatorItem;
    DockEditRight: TTBXMultiDock;
    DockEditLeft: TTBXMultiDock;
    DockEditBottom: TTBXMultiDock;
    DockEditTop: TTBXMultiDock;
    TBXSeparatorItem1: TTBXSeparatorItem;
    ToolbarEditor: TTBXToolbar;
    ToolbarScript: TTBXToolbar;
    ToolbarTabs: TTBXToolbar;
    ToolbarWatch: TTBXToolbar;
    TBXItem5: TTBXItem;
    TBXItem4: TTBXItem;
    ToolbarWatchBevel: TBevel;
    ScrollBox1: TScrollBox;
    CBAllowClear: TTBXCheckBox;
    ActionFileCopy: TAction;
    ActionFilePaste: TAction;
    DockpanelParameters: TTBXDockablePanel;
    lstScriptParameters: TListView;
    ActionParametersEdit: TAction;
    ActionParametersDefault: TAction;
    MenuPopupParameters: TTBXPopupMenu;
    MnuParEdt: TTBXItem;
    MnuPar__1: TTBXSeparatorItem;
    MnuParDef: TTBXItem;
    MenuPopupList: TTBXPopupMenu;
    MnuLspAll: TTBXItem;
    MnuLspNone: TTBXItem;
    ActionListCheck: TAction;
    ActionListUncheck: TAction;
    MnuLspChk: TTBXItem;
    MnuLspUnc: TTBXItem;
    MnuLsp__1: TTBXSeparatorItem;
    procedure ActionDebugBreakpointClearExecute(Sender: TObject);
    procedure ActionDebugBreakpointExecute(Sender: TObject);
    procedure ActionDebugEvalExecute(Sender: TObject);
    procedure ActionDebugRunExecute(Sender: TObject);
    procedure ActionDebugStepExecute(Sender: TObject);
    procedure ActionDebugStopExecute(Sender: TObject);
    procedure ActionDebugWatchAddExecute(Sender: TObject);
    procedure ActionDebugWatchClearExecute(Sender: TObject);
    procedure ActionDebugWatchRemoveExecute(Sender: TObject);
    procedure ActionDisplayExecute(Sender: TObject);
    procedure ActionEditCopyExecute(Sender: TObject);
    procedure ActionEditCutExecute(Sender: TObject);
    procedure ActionEditDeleteExecute(Sender: TObject);
    procedure ActionEditFindExecute(Sender: TObject);
    procedure ActionEditFindNextExecute(Sender: TObject);
    procedure ActionEditPasteExecute(Sender: TObject);
    procedure ActionEditSelectAllExecute(Sender: TObject);
    procedure ActionEditUndoExecute(Sender: TObject);
    procedure ActionFileNewExecute(Sender: TObject);
    procedure ActionFileOpenExecute(Sender: TObject);
    procedure ActionFilePropertiesExecute(Sender: TObject);
    procedure ActionFileSaveAsExecute(Sender: TObject);
    procedure ActionFileSaveExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure ActionListCheckExecute(Sender: TObject);
    procedure ActionListAllExecute(Sender: TObject);
    procedure ActionOptionsDefaultExecute(Sender: TObject);
    procedure ActionOptionsEditExecute(Sender: TObject);
    procedure ActionParametersDefaultExecute(Sender: TObject);
    procedure ActionParametersEditExecute(Sender: TObject);
    procedure ActionViewFilterChangeExecute(Sender: TObject);
    procedure ActionViewFilterExecute(Sender: TObject);
    procedure ActionViewListExecute(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure EScriptGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: TSynEditMark);
    procedure EScriptGutterPaint(Sender: TObject; aLine, X, Y: Integer);
    procedure EScriptSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
    procedure EScriptStatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure lblScriptInfoLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
    procedure lstScriptOptionsInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
    procedure lstScriptOptionsKeyPress(Sender: TObject; var Key: Char);
    procedure lstScriptParametersInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
    procedure lstScriptParametersKeyPress(Sender: TObject; var Key: Char);
    procedure lstScriptsInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
    procedure lstScriptsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure lstWatchKeyPress(Sender: TObject; var Key: Char);
    procedure tabScriptInfoChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
    procedure TBMRUList1Click(Sender: TObject; const Filename: string);
    procedure lstScriptsKeyPress(Sender: TObject; var Key: Char);
    procedure lstScriptsCustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lstLimitFieldsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure DockpanelOptionsDockChanged(Sender: TObject);
    procedure DockpanelParametersDockChanged(Sender: TObject);
  private
    FCurrentFile: TFileManager;
    FCurrentScript: TScriptInfo;
    FCurrentCatalog: TFileManager;
    FScript: TIfPasScript;
    FMovieList: TMovieList;
    FMovieListFiltered: TList;
    FEmptyMovie: TMovie;
    FMaxNum: Integer;
    FIteration: Integer;
    FWorkMode: TScriptWorkMode;
    LastSearch: string;
    FScripts: TScriptList;
    FDebugPlugin: TDebugPlugin;
    FMedia: TMedia;
    FRegExpr: TRegExpr;
    FRegExprDebug: Boolean;
    FRaiseConnectionErrors: Boolean;
    MemoMsgWin: TMemoWin;
    FListScriptOptionsWndProc: TWndMethod;
    FListScriptParametersWndProc: TWndMethod;
    FListLimitFieldsWndProc: TWndMethod;
    SSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
    IOHandlerSocket: TIdIOHandlerStack;
    FCookieManager: TIdCookieManager;
    FCompressorZLib: TIdCompressorZLib;
    procedure OnFileChange(Sender: TObject; AFileName: TFileName);
    procedure OnNewFile(Sender: TObject; AFileName: TFileName);
    procedure OnOpenFile(Sender: TObject; AFileName: TFileName);
    procedure OnSaveFile(Sender: TObject; AFileName: TFileName);
    procedure OnModifFile(Sender: TObject; State: Boolean);
    procedure UpdateMRU(const FileName: string);
    procedure FillFields;
    procedure FillOptions;
    procedure UpdateOptions;
    procedure FillParameters;
    procedure UpdateParameters;
    procedure CheckProperties;
    procedure SaveScriptFields;
    procedure SaveCustomFields;
    function FindScript(const AFile: TFileName): Boolean;
    procedure OnThreadEnd(Sender: TObject);
    procedure OnCancelDownload(Sender: TObject);
    procedure ReadScripts;
    procedure FillScripts;
    procedure SetCurrentLine(const Value: Integer);
    function GetCurrentLine: Integer;
    function GetVariableValue(Sender: TObject; const VarName: string): string;
    procedure CloseAfterRun(var Msg: TMessage); message WM_CLOSEAFTERRUN;
    procedure ListScriptOptionsWndProc(var Msg: TMessage);
    procedure ListScriptParametersWndProc(var Msg: TMessage);
    procedure ListLimitFieldsWndProc(var Msg: TMessage);
  protected
    procedure LoadOptions; override;
    procedure SaveOptions; override;
  public
    constructor Create(AOwner: TComponent; AWorkMode: TScriptWorkMode); reintroduce;
    function Execute(const Catalog: TFileManager; AMovieList: TMovieList): TModalResult;
    property CurrentCatalog: TFileManager read FCurrentCatalog;
    property CurrentScript: TScriptInfo read FCurrentScript;
    function HasRemainingMovies: Boolean;
    property DebugPlugin: TDebugPlugin read FDebugPlugin;
    property CurrentLine: Integer read GetCurrentLine write SetCurrentLine;
    property MovieList: TMovieList read FMovieList;
    property MaxNum: Integer read FMaxNum write FMaxNum;
    procedure Translate; override;
  end;

  function OnScriptRunLine(id: Pointer; Sender: TIfPasScript; Position: Longint): TCs2Error;
  function OnScriptUses(id: Pointer; Sender: TIfPasScript; Name: string): TCs2Error;
  function OnScriptRegScriptProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegMsgProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegPickProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegMediaProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegCookieProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegHtmlProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegFieldProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegExtraFieldProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegStringProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegRegExprProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
  function OnScriptRegFileProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
//  function OnScriptRegXmlProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;

var
  GetScriptWin: TGetScriptWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  strUtils,

  IdHTTPHeaderInfo, IdURI, IdGlobal,
  stdimport, formsimport, stdctrlsimport, ifpslib, ifpstrans,
  ifpsdll, ifpsdll2, ifpsdelphi,
  JvSimpleXml, SynEditTypes,

  Global, ConstValues, fields, functions_html, functions_files, functions_str,
  functions_sys, functions_gui, functions_xml,
  getscript_picktree, getscript_picklist, getscript_results,
  getscript_properties, getscript_xml, getscript_stringlistex,
  ProgramSettings, listform, threaddownload;

{$R *.dfm}

var
  Cl: TIFPSClasses;
  FScriptStatus: TIStatus;
  DownloadThread: TDownloadThread;
  DownloadState: TDownloadState;
  DownloadResult: string;

const
  msgScriptError       =  0;
  msgUnsavedFile       =  1;
  msgUnknownLang       =  2;
  msgIAgree            =  3;
  msgNoMovieFound      =  4;
  msgAbortBatch        =  5;
  msgModified          =  6;
  msgValueForOption    =  7;
  msgValueForParameter =  8;
  msgFind              =  9;
  msgFindtext          = 10;
  msgNoMoreMatches     = 11;
  msgAddExtras         = 12;
  msgDeleteExtras      = 13;
  msgModifyExtras      = 14;

const
  pnlEditorFile        =  0;
  pnlEditorModified    =  1;
  pnlEditorPos         =  2;

const
  strDefaultProgram    = 'program NewScript;'#13#10'begin'#13#10'end.';

const
  imgGutterBREAK        = 0;
  imgGutterBREAKVALID   = 1;
  imgGutterBREAKINVAL   = 2;
  imgGutterCOMPLINE     = 3;
  imgGutterEXECLINECL   = 4;
  imgGutterEXECLINEBP   = 5;
  imgGutterEXECLINE     = 6;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

constructor TGetScriptWin.Create(AOwner: TComponent; AWorkMode: TScriptWorkMode);
begin
  FWorkMode := AWorkMode;
  inherited Create(AOwner);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  LastSearch := '';
  FCurrentFile := TFileManager.Create(Self);
  ActionFileNew.ImageIndex := Ord(ICON_SCRIPTNEW);
  ActionFileOpen.ImageIndex := Ord(ICON_SCRIPTOPEN);
  ActionFileSave.ImageIndex := Ord(ICON_SCRIPTSAVE);
  ActionFileSaveAs.ImageIndex := Ord(ICON_SCRIPTSAVEAS);
  ActionFileProperties.ImageIndex := Ord(ICON_SCRIPTSPROPERTIES);
  ActionEditFind.ImageIndex := Ord(ICON_SCRIPTFIND);
  ActionEditFindNext.ImageIndex := Ord(ICON_SCRIPTFINDNEXT);
  ActionDebugRun.ImageIndex := Ord(ICON_DEBUGRUN);
  ActionDebugStop.ImageIndex := Ord(ICON_DEBUGSTOP);
  ActionDebugBreakpoint.ImageIndex := Ord(ICON_DEBUGBREAKPOINT);
  ActionDebugBreakpointClear.ImageIndex := Ord(ICON_DEBUGBREAKCLEAR);
  ActionDebugStep.ImageIndex := Ord(ICON_DEBUGSTEPOVER);
  ActionDebugRunToCursor.ImageIndex := Ord(ICON_DEBUGRUNTOCURSOR);
  ActionDebugEval.ImageIndex := Ord(ICON_DEBUGEVALUATE);
  ActionDebugWatchAdd.ImageIndex := Ord(ICON_DEBUGWATCHADD);
  ActionDebugWatchRemove.ImageIndex := Ord(ICON_DEBUGWATCHREMOVE);
  ActionDebugWatchClear.ImageIndex := Ord(ICON_DEBUGWATCHCLEAR);
  ActionViewFilter.ImageIndex := Ord(ICON_VIEWFILTER);
  ActionViewList.ImageIndex := Ord(ICON_VIEWLIST);
  ActionViewDetailed.ImageIndex := Ord(ICON_VIEWDETAIL);
  lstScripts.SmallImages := ToolbarImages;
  MemoMsgWin := TMemoWin.Create(Self);
  PickTreeWin := TPickTreeWin.Create(Self);
  PickListWin := TPickListWin.Create(Self);
  ScriptResultsWin := TScriptResultsWin.Create(Self);
  ListWin := TListWin.Create(Self);
  ScriptPropertiesWin := TScriptPropertiesWin.Create(Self);
  with PageControl1 do
    for i := 0 to PageCount-1 do
      Pages[i].TabVisible := False;

  ReadScripts; // before inherited, since in inherited it will loadoptions, and check which languages have to be displayed
  inherited;

  with FCurrentFile do
  begin
    with OpenDialog do
    begin
      Filter := DialogScriptFilter;
      Options := DialogOpenOptions;
      DefaultExt := 'ifs';
    end;
    with SaveDialog do
    begin
      Filter := DialogScriptFilter;
      Options := DialogSaveOptions;
      DefaultExt := 'ifs';
    end;
    MessageSaveQuery := Messages.Strings[msgUnsavedFile];
    OnNewFile := Self.OnNewFile;
    OnOpenFile := Self.OnOpenFile;
    OnSaveFile := Self.OnSaveFile;
    OnFileModified := Self.OnModifFile;
    OnFileChange := Self.OnFileChange;
  end;

  PageControl1.Top := ToolbarTabs.Height - 5;
  PageControl1.Height := ClientHeight - 28 - ToolbarTabs.Height;
  PageControl1.Width := ClientWidth + 3;

  FDebugPlugin := TDebugPlugin.Create(EScript);
  FDebugPlugin.WatchList := lstWatch;
  FDebugPlugin.WatchPanel := DockpanelWatch;
  FDebugPlugin.OnGetVariable := GetVariableValue;

  // ifs
  FScript := TIfPasScript.Create(nil);
  with FScript do
  begin
    OnRunLine := OnScriptRunLine;
    OnUses := OnScriptUses;
  end;
  FScriptStatus := iStopped;
  Cl := TIFPSClasses.Create;
  SIRegister_std(Cl);
  SIRegister_stdctrls(Cl);
  SIRegister_Forms(Cl);
  SIRegister_Xml(Cl);
  SIRegister_StringListEx(Cl);

  // Movie list filtered and empty movie
  FMovieListFiltered := TList.Create;
  FEmptyMovie := nil; // Created in Execute function
  // Media
  FMedia := TMedia.Create;
  // Regular expression
  FRegExpr := TRegExpr.Create;
  FRegExprDebug := False;
  // Connection
  FRaiseConnectionErrors := True;

  // To remove horizontal scrollbar
  FListScriptOptionsWndProc := lstScriptOptions.WindowProc; // save window proc
  FListScriptParametersWndProc := lstScriptParameters.WindowProc; // save window proc
  FListLimitFieldsWndProc := lstLimitFields.WindowProc; // save window proc
  lstScriptOptions.WindowProc := ListScriptOptionsWndProc; // subclass
  lstScriptParameters.WindowProc := ListScriptParametersWndProc; // subclass
  lstLimitFields.WindowProc := ListLimitFieldsWndProc; // subclass

  // Init IOHandler for http and https support
  try
    IOHandlerSocket := TIdIOHandlerStack.Create(Self);
  except
    FreeAndNil(IOHandlerSocket);
  end;
  try
    SSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
    SSLIOHandlerSocket.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
  except
    FreeAndNil(SSLIOHandlerSocket);
  end;

  // Cookie Manager
  FCookieManager := TIdCookieManager.Create(Self);
  http.CookieManager := FCookieManager;
  //Init ZLib for deflate and gzip compressed content
  FCompressorZLib := TIdCompressorZLib.Create;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ListScriptOptionsWndProc(var Msg: TMessage);
begin
  ShowScrollBar(lstScriptOptions.Handle, SB_HORZ, False);
  //ShowScrollBar(lstScriptOptions.Handle, SB_VERT, True);
  FListScriptOptionsWndProc(Msg); // process message
end;

procedure TGetScriptWin.ListScriptParametersWndProc(var Msg: TMessage);
begin
  ShowScrollBar(lstScriptParameters.Handle, SB_HORZ, False);
  //ShowScrollBar(lstScriptParameters.Handle, SB_VERT, True);
  FListScriptParametersWndProc(Msg); // process message
end;

procedure TGetScriptWin.ListLimitFieldsWndProc(var Msg: TMessage);
begin
  ShowScrollBar(lstLimitFields.Handle, SB_HORZ, False);
  //ShowScrollBar(lstLimitFields.Handle, SB_VERT, True);
  FListLimitFieldsWndProc(Msg); // process message
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.Translate;
begin
  Translator.Translate(lstLimitMovies);
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormShow(Sender: TObject);
begin
  MemoMsgWin.Icon.Assign(Icon);
  PickTreeWin.Icon.Assign(Icon);
  PickListWin.Icon.Assign(Icon);
  ScriptResultsWin.Icon.Assign(Icon);
  ToolbarImages.GetIcon(Ord(ICON_SCRIPTSPROPERTIES), ListWin.Icon);
  ToolbarImages.GetIcon(Ord(ICON_SCRIPTSPROPERTIES), ScriptPropertiesWin.Icon);
  inherited;
  lstScripts.SetFocus;
  with ScriptPropertiesWin do
  begin
    Self.lstScripts.Columns[0].Caption := Trim(CopyExceptLastChars(Messages.Strings[msgInfoTitle], 1));
    Self.lstScripts.Columns[1].Caption := Trim(CopyExceptLastChars(Messages.Strings[msgInfoDescr], 1));
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormActivate(Sender: TObject);
begin
  OnActivate := nil;
  lstScripts.Width := 123;
  lstScriptOptions.Width := 123;
  lstScriptParameters.Width := 123;

  // Fix DPI problem on execution options
  DockpanelExec.MaxClientHeight := Trunc(53 * Self.PixelsPerInch / 96);
  DockpanelExec.MinClientHeight := DockpanelExec.MaxClientHeight;
  DockpanelExec.ClientHeight := DockpanelExec.MinClientHeight;

  if FCurrentFile.CurrentFile <> '' then
    with Settings.rOptions.rScripting do
      if (FWorkMode = swmGetInfo) and (ScriptAutorun)  then
        ActionDebugRun.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  with Settings.rOptions do
    case FWorkMode of
      swmGetInfo:   Settings.rScripts.ScriptRemember1 := FCurrentFile.CurrentFile;
      swmScripting: Settings.rScripts.ScriptRemember2 := FCurrentFile.CurrentFile;
    end;
  with FCurrentFile do
  begin
    SaveDialog.InitialDir := Settings.rOptions.rFolders[fuScripts].Value;
    if SaveDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    CanClose := Close;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  ModalResult := btn2.ModalResult;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormDestroy(Sender: TObject);
begin
  lstScripts.OnSelectItem := nil;
  FreeAndNil(MemoMsgWin);
  FreeAndNil(PickTreeWin);
  FreeAndNil(PickListWin);
  FreeAndNil(ScriptResultsWin);
  FreeAndNil(ScriptPropertiesWin);
  FreeAndNil(ListWin);
  FreeAndNil(FCurrentFile);
  FreeAndNil(FScripts);
  FreeAndNil(FDebugPlugin);
  // ifps
  FScript.Free;
  Cl.Free;
  // Movie list filtered and empty movie
  FMovieListFiltered.Free;
  FEmptyMovie.Free;
  // Media
  FMedia.Free;
  // Regular expression
  FRegExpr.Free;

  lstScriptOptions.WindowProc := FListScriptOptionsWndProc; // restore window proc
  lstScriptParameters.WindowProc := FListScriptParametersWndProc; // restore window proc
  lstLimitFields.WindowProc := FListLimitFieldsWndProc; // restore window proc
  FListScriptOptionsWndProc := nil;
  FListScriptParametersWndProc := nil;
  FListLimitFieldsWndProc := nil;

  // Free IOHandler for http and https support
  FreeAndNil(IOHandlerSocket);
  FreeAndNil(SSLIOHandlerSocket);

  // Cookie Manager
  FreeAndNil(FCookieManager);
  // ZLib Compressor
  FreeAndNil(FCompressorZLib);

  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.LoadOptions;
var
  i, idx: Integer;
  L: TStringList;
begin
  TBCustomLoadPositions(Self, XmlReadInt, XmlReadString, Settings.rScripts.Toolbars);
  DockpanelWatch.Visible := False;
  with Settings.rScripts do
  begin
    case WindowState of
      1:
        begin
          self.WindowState := wsNormal;
          self.Width := WindowWidth;
          self.Height := WindowHeight;
        end;
      2:
        begin
          self.WindowState := wsMaximized;
        end;
      else
        begin
          self.WindowState := wsNormal;
        end;
    end; // case
    if FWorkMode = swmScripting then
    begin
      lstLimitMovies.ItemIndex := TMovieIncludeOption(Includemov);
      CBShowResults.Checked := ShowResScripting;
      CBCloseThis.Checked := CloseWinScripting;
      CBAllowClear.Checked := AllowClearScripting;
    end
    else
    begin
      lstLimitMovies.ItemIndex := mioSelected;
      CBShowResults.Checked := ShowResGetInfo;
      CBCloseThis.Checked := CloseWinGetInfo;
      CBAllowClear.Checked := AllowClearGetInfo;
    end;
    L := TStringList.Create;
    try
      L.Delimiter := '|';
      L.DelimitedText := LangFilterExcl;
      for i := 0 to L.Count-1 do
      begin
        idx := FScripts.Languages.IndexOf(L[i]);
        if idx <> -1 then
          (FScripts.Languages.Objects[idx] as TTBXItem).Checked := False; 
      end;
    finally
      L.Free;
    end;
    if TViewStyle(ListViewStyle) = vsReport then
      ActionViewDetailed.Execute
    else
      ActionViewList.Execute;
    TBMRUList1.Items.Assign(ScriptMRU);
  end; // with
  with Settings.rOptions do
  begin
    TBMRUList1.MaxItems := rFiles.RecentFiles;
    ToolbarScript.Images := ToolbarImages;
    ToolbarEditor.Images := ToolbarImages;
    ToolbarTabs.Images := ToolbarImages;
    ToolbarWatch.Images := ToolbarImages;
    if Settings.rOptions.rDisplay.ImagesInMenu then
      MenuPopupDebug.Images := ToolbarImages;
    with rScripting, http do
    begin
      if Proxy then
      begin
        ProxyParams.BasicAuthentication := True;
        Request.BasicAuthentication := True;
        ProxyParams.ProxyServer := ProxyServer;
        ProxyParams.ProxyPort := ProxyPort;
        ProxyParams.ProxyUsername := ProxyUsername;
        ProxyParams.ProxyPassword := ProxyPassword;
      end else
      begin
        ProxyParams.BasicAuthentication := False;
        Request.BasicAuthentication := False;
      end;
      if HTTP10 then
        ProtocolVersion := pv1_0
      else
        ProtocolVersion := pv1_1;
    end; // with
  end; // with
  UpdateMRU('');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.SaveOptions;
var
  i: Integer;
begin
  with Settings.rScripts do
  begin
    case self.WindowState of
      wsNormal:
        begin
          WindowState := 1;
          WindowWidth := Width;
          WindowHeight := Height;
        end;
      wsMaximized:
        begin
          WindowState := 2;
        end;
    end; // case
    if FWorkMode = swmScripting then
    begin
      Includemov := Integer(lstLimitMovies.ItemIndex);
      ShowResScripting := CBShowResults.Checked;
      CloseWinScripting := CBCloseThis.Checked;
      AllowClearScripting := CBAllowClear.Checked;
    end
    else
    begin
      ShowResGetInfo := CBShowResults.Checked;
      CloseWinGetInfo := CBCloseThis.Checked;
      AllowClearGetInfo := CBAllowClear.Checked;
    end;
    LangFilterExcl := '';
    for i := 0 to FScripts.Languages.Count-1 do
      if not (FScripts.Languages.Objects[i] as TTBXItem).Checked then
      begin
        if LangFilterExcl <> '' then
          LangFilterExcl := LangFilterExcl + '|';
        LangFilterExcl := LangFilterExcl + FScripts.Languages[i];
      end;
    ListViewStyle := Ord(lstScripts.ViewStyle);
    ScriptMRU.Assign(TBMRUList1.Items);
  end; // with
  FScripts.Save;  
  Settings.rScripts.Toolbars.Clear;
  TBCustomSavePositions(Self, XmlWriteInt, XmlWriteString, Settings.rScripts.Toolbars);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDisplayExecute(Sender: TObject);
begin
  with (Sender as TAction) do
  begin
    Checked := True;
    PageControl1.ActivePageIndex := Tag;
  end;
  ToolbarScript.Visible := Sender = ActionDisplayScripts;
  ToolbarEditor.Visible := Sender = ActionDisplayEditor;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditUndoExecute(Sender: TObject);
begin
  EScript.Undo;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditCutExecute(Sender: TObject);
begin
  EScript.CutToClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditCopyExecute(Sender: TObject);
begin
  EScript.CopyToClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditPasteExecute(Sender: TObject);
begin
  EScript.PasteFromClipboard;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditDeleteExecute(Sender: TObject);
begin
  EScript.SelText := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditSelectAllExecute(Sender: TObject);
begin
  EScript.SelectAll;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnFileChange(Sender: TObject; AFileName: TFileName);
begin
  sbEditor.Panels[pnlEditorFile].Caption := AFileName;
  FDebugPlugin.ClearBreakpoints;
  DebugPlugin.ErrorLine := -1;
  EScriptStatusChange(EScript, [scCaretX, scCaretY, scInsertMode]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnNewFile(Sender: TObject; AFileName: TFileName);
begin
  EScript.Lines.Text := strDefaultProgram;
  EScript.Modified := False;
  FindScript(AFileName);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnOpenFile(Sender: TObject; AFileName: TFileName);
var
  f: TFileStream;
  s: string;
  EndPos: Integer;
begin
  try
    f := TFileStream.Create(AFileName, fmOpenRead);
    try
      SetLength(s, f.Size);
      f.Read(s[1], f.Size);
      if StartsStr('(*', s) then
      begin
        EndPos := Pos('*)', s);
        if EndPos > 0 then
        begin
          Delete(s, 1, EndPos + 1);
          while StartsStr(sLineBreak, s) do
            Delete(s, 1, Length(sLineBreak));
        end;
      end;
      EScript.Lines.Text := s;
      UpdateMRU(AFileName);
    finally
      f.Free;
    end;
  except
    on e: Exception do
      MessageWin.Execute(e.Message, mtError, [mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnSaveFile(Sender: TObject; AFileName: TFileName);
var
  f: TFileStream;
begin
  try
    f := TFileStream.Create(AFileName, fmCreate);
    try
      f.Size := 0;
      f.Seek(0, soFromBeginning);
      FCurrentScript.SaveToStream(f);
      EScript.Lines.SaveToStream(f);
    finally
      f.Free;
    end;
    FCurrentScript.Save(AFileName);
    FindScript(AFileName);
    UpdateMRU(AFileName);
  except on e: Exception do
    MessageWin.Execute(e.Message, mtError, [mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnModifFile(Sender: TObject; State: Boolean);
begin
  EScript.Modified := State;
  if State then
    sbEditor.Panels[pnlEditorModified].Caption := Messages.Strings[msgModified]
  else
    sbEditor.Panels[pnlEditorModified].Caption := '';
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionFileNewExecute(Sender: TObject);
begin
  lstScripts.Selected := nil;
  FCurrentFile.New;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionFileSaveExecute(Sender: TObject);
begin
  with FCurrentFile do
  begin
    SaveDialog.InitialDir := Settings.rOptions.rFolders[fuScripts].Value;
    if SaveDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    Save;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionFileSaveAsExecute(Sender: TObject);
begin
  with FCurrentFile do
  begin
    SaveDialog.InitialDir := Settings.rOptions.rFolders[fuScripts].Value;
    if SaveDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    if SaveAs then
    begin
      Settings.rOptions.rFolders[fuScripts].Value := ExtractFilePath(SaveDialog.FileName);
      lstScripts.OnSelectItem := nil;
      lstScripts.Selected := nil;
      lstScripts.OnSelectItem := lstScriptsSelectItem;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionFileOpenExecute(Sender: TObject);
begin
  with FCurrentFile do
  begin
    OpenDialog.InitialDir := Settings.rOptions.rFolders[fuScripts].Value;
    if OpenDialog.InitialDir <> '' then
      ClearLastVisitedMRU(Application.ExeName);
    if Open then
    begin
      FindScript(CurrentFile);
      Settings.rOptions.rFolders[fuScripts].Value := ExtractFilePath(OpenDialog.FileName);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionFilePropertiesExecute(Sender: TObject);
var
  CanChange: Boolean;
begin
  if Assigned(FCurrentScript) then
  begin
    if ScriptPropertiesWin.Execute(FCurrentScript, FScripts.Languages) then
    begin
      FCurrentFile.Modified := True;
      CanChange := True;
      tabScriptInfoChange(tabScriptInfo, tabScriptInfo.TabIndex, CanChange); // re-read script info
    end;
    CheckProperties; // even if not really modified, properties are checker when closing the properties window
    FillOptions; // even if not really modified, options are rebuild when closing the properties window
    FillParameters; // even if not really modified, parameters are rebuild when closing the properties window
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptsSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
var
  CanChange: Boolean;
begin
  CanChange := False;
  if (Selected) and (Item <> nil) then
    with Item do
      if Selected then
        if Data <> nil then
        begin
          FCurrentFile.Open(TScriptInfo(Data).FullPath);
          FCurrentScript := TScriptInfo(Data);
          CanChange := True;
        end;
  if not CanChange then
    FCurrentFile.New;
  CanChange := True;
  tabScriptInfoChange(tabScriptInfo, tabScriptInfo.TabIndex, CanChange);
  CheckProperties;
  FillOptions;
  FillParameters;
  FillFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptsKeyPress(Sender: TObject; var Key: Char);
begin
  if Word(Key) = VK_RETURN then
    ActionDebugRun.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.UpdateMRU(const FileName: string);
begin
  if FileName <> '' then
    TBMRUList1.Add(FileName);
  ActionFileNoRecent.Visible := TBMRUList1.Items.Count = 0;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.TBMRUList1Click(Sender: TObject; const Filename: string);
begin
  if FCurrentFile.Open(FileName) then
    FindScript(FCurrentFile.CurrentFile);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  if Action = ActionDebugStop then
  begin
    Handled := True;
    ActionDebugStop.Enabled := FScriptStatus <> iStopped;
  end
  else
  if (Action = ActionDebugRun) or (Action = ActionDebugRunToCursor) then
  begin
    Handled := True;
    TAction(Action).Enabled := FScriptStatus <> iRunning;
  end
  else
  if (Action = ActionDebugStep) or (Action = ActionDebugEval) then
  begin
    Handled := True;
    TAction(Action).Enabled := FScriptStatus = iStepoverWaiting;
  end
  else
  if Action = ActionDebugWatchRemove then
  begin
    Handled := True;
    ActionDebugWatchRemove.Enabled := lstWatch.ItemIndex <> -1;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugRunExecute(Sender: TObject);
var
  f: Integer;
  IncOpt: TMovieIncludeOption;
  CurMovie: TMovie;
  LastResult: TScriptResult;
  ShowResultsWindow: Boolean;
  AllowedCustomFields: TMovieFields;
  WinCaption: string;
begin
  if Sender = ActionDebugRunToCursor then
    FDebugPlugin.CursorLine := EScript.CaretY
  else
    FDebugPlugin.CursorLine := -1;
  if FScriptStatus = iStepOverWaiting then
  begin
    FScriptStatus := iRunning;
    ActionDebugRun.Update;
    ActionDebugStop.Update;
    EScript.InvalidateGutterLine(DebugPlugin.CurrentLine);
    EScript.InvalidateLine(DebugPlugin.CurrentLine);
    Exit;
  end
  else
  if FScriptStatus = iRunning then
  begin
    Exit;
  end;
  FScriptStatus := iRunning;
  ActionDebugRun.Update;
  ActionDebugStop.Update;
  EScript.PopupMenu := MenuPopupDebug;
  try
    if FCurrentScript = nil then
      Exit;
    SaveScriptFields;
    ShowResultsWindow := CBShowResults.Checked;
    LastResult := srSave;
    try
      FScript.SetText(EScript.Lines.Text);
      if FScript.ErrorCode = ENoError then
      begin
        EScript.ReadOnly := True;
        try
          WinCaption := Caption;
          IncOpt := lstLimitMovies.ItemIndex;
          try
            // Initialization
            if FCurrentScript.Properties.RequiresMovies then
            begin
              FMovieList.MakeFilteredList(FMovieListFiltered, IncOpt);
              if FMovieListFiltered.Count = 0 then
              begin
                MessageWin.Execute(Format(Messages.Strings[msgNoMovieFound], [lstLimitMovies.grp.Caption, lstLimitMovies.ItemIndexCaption]), mtWarning, [mbOk]);
                Abort;
              end;
            end else
            begin
              FMovieListFiltered.Clear;
              FMovieListFiltered.Add(FEmptyMovie);
            end;
            AllowedCustomFields := [];
            with FMovieList.CustomFieldsProperties do
              for f := 0 to Count-1 do
                if (not Objects[f].ExcludedInScripts) and (Objects[f].FieldType <> ftVirtual) then
                  Include(AllowedCustomFields, f+customFieldLow);
            ScriptResultsWin.Init(AllFields - VirtualFields - FCurrentScript.Fields.FieldsExcluded,
              AllowedCustomFields, FCurrentScript.Fields.Picture,
              FCurrentScript.Fields.AddExtras,
              FCurrentScript.Fields.DeleteExtras,
              FCurrentScript.Fields.ModifyExtras,
              AllExtraFields - VirtualFields - FCurrentScript.Fields.ExtraFieldsExcluded,
              FCurrentScript.Fields.ExtraPicture,
              FCurrentCatalog);
            btn2.ModalResult := mrOk;
            // Picktree and Picklist
            PickTreeWin.SetDefaultTitle;
            PickTreeWin.Clear;
            PickListWin.SetDefaultTitle;
            PickListWin.Clear;
            // Media
            FMedia.InitValues;
            // Regular expression
            FreeAndNil(FRegExpr);
            FRegExpr := TRegExpr.Create;
            FRegExprDebug := False;
            // Connection
            FRaiseConnectionErrors := True;

            // Set current catalog path
            if FCurrentCatalog.CurrentFile <> '' then
              SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
            else
              SetCurrentDir(strDirCatalogs);

            FIteration := 0;
            while FIteration < FMovieListFiltered.Count do
            begin
              Caption := WinCaption + ' (' + IntToStr(FIteration+1) + '/' + IntToStr(FMovieListFiltered.Count) + ')';
              CurMovie := TMovie(FMovieListFiltered[FIteration]);
              ScriptResultsWin.CopyFrom(CurMovie);
              FScript.RunScript;
              if FScriptStatus = iStopped then // stopped by user
              begin
                LastResult := srAbort;
                Break;
              end;
              if FScript.ErrorCode <> ENoError then
                Break;
              LastResult := ScriptResultsWin.Execute(ShowResultsWindow and
                (LastResult <> srSaveAll) and (CurMovie <> FEmptyMovie),
                FCurrentScript.Properties.Title);
              case LastResult of
                srSave,
                srSaveAll:
                  if CurMovie <> FEmptyMovie then
                    ScriptResultsWin.CopyTo(CurMovie, CBAllowClear.Checked)
                  else
                    LastResult := srSave;
                srAbort:
                  Break;
              end;
              Inc(FIteration);
            end;
          finally
            Caption := WinCaption;
            // Restore current catalog path in case it has been changed during script execution
            if FCurrentCatalog.CurrentFile <> '' then
              SetCurrentDir(ExtractFilePath(FCurrentCatalog.CurrentFile))
            else
              SetCurrentDir(strDirCatalogs);
          end;
        finally
          EScript.ReadOnly := False;
        end;
      end;
      if (FScript.ErrorCode <> ENoError) then
      begin
        LastResult := srAbort;
        ActionDisplayExecute(ActionDisplayEditor);
        with EScript.CharIndexToRowCol(FScript.ErrorPos) do
        begin
          EScript.CaretX := Char;
          EScript.CaretY := Line;
          DebugPlugin.ErrorLine := Line;
          EScript.InvalidateGutterLine(Line);
          EScript.InvalidateLine(Line);
        end;
        EScript.Perform(EM_SCROLLCARET, 0, 0);
        EScript.SetFocus;
        with FScript do
          MessageWin.Execute(Format(Messages.Strings[msgScriptError], [ErrorModule, ErrorToString(ErrorCode, ErrorString), EScript.CaretY]), mtError, [mbOk]);
      end;
    finally
      Application.ProcessMessages;
      FScript.Cleanup;
      EScript.Invalidate;
      FCurrentScript.Save;
    end; // try
  finally
    FScriptStatus := iStopped;
    EScript.PopupMenu := MenuPopupEdit;
  end;
  if (LastResult <> srAbort) and (CBCloseThis.Checked) then
    PostMessage(Self.Handle, WM_CLOSEAFTERRUN, 0, 0);
  ActionDebugRun.Update;
  ActionDebugStop.Update;
  // Reload the number of movies if new movies are added to list
  lstLimitMovies.SetCount(FMovieList);
  // Reload Options and Parameters values if they have been modified during script execution
  UpdateOptions;
  UpdateParameters;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.CloseAfterRun(var Msg: TMessage);
begin
  btn2.Click;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugStopExecute(Sender: TObject);
begin
  FScriptStatus := iStopped;
  ActionDebugRun.Update;
  ActionDebugStop.Update;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugBreakpointExecute(Sender: TObject);
begin
  // F5 key
  case PageControl1.ActivePageIndex of
    0:  FillScripts;
    1:  FDebugPlugin.ToggleBreakpoint(EScript.CaretY);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugStepExecute(Sender: TObject);
begin
  FScriptStatus := iStepOver;
  ActionDebugRun.Update;
  ActionDebugStop.Update;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugEvalExecute(Sender: TObject);
var
  VarName: string;
  Value: string;
begin
  VarName := EScript.WordAtCursor;
  Value := GetVariableValue(Self, VarName);
  //MessageWin.Execute(GetVariableValue(Self, VarName), VarName, [mbOk]);
  MemoMsgWin.Execute(VarName, Value);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugBreakpointClearExecute(Sender: TObject);
begin
  FDebugPlugin.ClearBreakpoints;
  EScript.Invalidate;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugWatchAddExecute(Sender: TObject);
begin
  FDebugPlugin.AddWatch(EScript.WordAtCursor);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugWatchRemoveExecute(Sender: TObject);
begin
  FDebugPlugin.DeleteWatch;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionDebugWatchClearExecute(Sender: TObject);
begin
  FDebugPlugin.ClearWatches;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TGetScriptWin.FindScript(const AFile: TFileName): Boolean;
var
  i: Integer;
  CanChange: Boolean;
begin
  lstScripts.OnSelectItem := nil;
  try
    lstScripts.Selected := nil;
    Result := False;
    if AFile <> '' then
      with lstScripts.Items do
        for i := 0 to Count-1 do
          with Item[i] do
            if (Data <> nil) and (AnsiSameText(TScriptInfo(Data).FullPath, AFile)) then
            begin
              FCurrentScript := TScriptInfo(Data);
              lstScripts.Selected := Item[i];
              Focused := True;
              MakeVisible(False);
              Result := True;
              Break;
            end;
    if not Result then
    begin
      FCurrentScript := FScripts.Find(AFile);
      if FCurrentScript = nil then
      begin
        FCurrentScript := FScripts.Add(AFile);
      end;
    end;
    CanChange := True;
    tabScriptInfoChange(tabScriptInfo, tabScriptInfo.TabIndex, CanChange);
    CheckProperties;
    FillOptions;
    FillParameters;
    FillFields;
  finally
    lstScripts.OnSelectItem := lstScriptsSelectItem;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TGetScriptWin.Execute(const Catalog: TFileManager; AMovieList: TMovieList): TModalResult;
var
  ToLoad: TFileName;
begin
  FCurrentCatalog := Catalog;
  FMovieList := AMovieList;
  if FEmptyMovie <> nil then // if movie has been created in a previous execution
    FEmptyMovie.Free;
  FEmptyMovie := TMovie.Create(FMovieList);
  if Settings.rOptions.rMovieInformation.FirstAvailable then
    FMaxNum := MaxInt
  else
    FMaxNum := FMovieList.MaxNumber;
  FillScripts;
  CheckProperties;
  FillOptions;
  FillParameters;
  FillFields;
  lstLimitMovies.SetCount(aMovieList);
  ActionDisplayExecute(ActionDisplayScripts);
  ScriptResultsWin.GenerateFields(FMovieList.CustomFieldsProperties);
  with Settings do
    case FWorkMode of
      swmGetInfo:   ToLoad := rScripts.ScriptRemember1;
      swmScripting: ToLoad := rScripts.ScriptRemember2;
    else
      ToLoad := ''
    end;
  if (ToLoad <> '') and FileExists(ToLoad) and FCurrentFile.Open(ToLoad) then
  begin
    FindScript(ToLoad)
  end
  else
    FCurrentFile.New;
  Result := ShowModal();
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.btn1Click(Sender: TObject);
begin
  if (ActionDisplayEditor.Checked) then
    functions_files.LaunchHelp(1073) // tech info
  else
    functions_files.LaunchHelp(1080); // general info
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionListCheckExecute(Sender: TObject);
var
  i: Integer;
  bState: Boolean;
begin
  if Sender is TAction then
    if TAction(Sender).ActionComponent is TTBXItem then
      if MenuPopupList.Items.ContainsItem(TTBXItem(TAction(Sender).ActionComponent)) then
      begin
        bState := (Sender = ActionListCheck);
        if MenuPopupList.PopupComponent is TListView then
        begin
          with TListView(MenuPopupList.PopupComponent) do
            for i := 0 to Items.Count-1 do
              if Items[i].Selected then
                Items[i].Checked := bState;
          SaveCustomFields;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionListAllExecute(Sender: TObject);
var
  i: Integer;
  bState: Boolean;
begin
  bState := (Sender = ActionListAll);
  if Sender is TAction then
    if TAction(Sender).ActionComponent is TTBXItem then
      if MenuPopupList.Items.ContainsItem(TTBXItem(TAction(Sender).ActionComponent)) then
      begin
        if MenuPopupList.PopupComponent is TListView then
        begin
          with TListView(MenuPopupList.PopupComponent) do
            for i := 0 to Items.Count-1 do
              Items[i].Checked := bState;
          SaveCustomFields;
        end;
      end
      else
      if MnuScrFlt.ContainsItem(TTBXItem(TAction(Sender).ActionComponent)) then
      begin
        for i := 0 to MnuScrFlt.Count-1 do
          if MnuScrFlt.Items[i].Tag > 0 then
            MnuScrFlt.Items[i].Checked := bState;
        ActionViewFilterChange.Execute;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditFindExecute(Sender: TObject);
begin
  if EScript.SelAvail and (EScript.BlockBegin.Line = EScript.BlockEnd.Line)
  then
    LastSearch := EScript.SelText
  else
    LastSearch := EScript.WordAtCursor;
  if InputWin.Execute(Messages.Strings[msgFind], Messages.Strings[msgFindtext], LastSearch) then
    if LastSearch <> '' then
      ActionEditFindNextExecute(ActionEditFindNext);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionEditFindNextExecute(Sender: TObject);
begin
  if LastSearch = '' then
  begin
    ActionEditFindExecute(ActionEditFind);
    Exit;
  end else
  begin
    if EScript.SearchReplace(LastSearch, '', []) = 0 then
      MessageWin.Execute(Format(Messages.Strings[msgNoMoreMatches], [LastSearch]), mtInformation, [mbOk]);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if ((Shift = [ssCtrl]) or (Shift = [ssCtrl, ssShift])) and (Key = VK_TAB) then
    case PageControl1.ActivePageIndex of
      0:  ActionDisplayExecute(ActionDisplayEditor);
      1:  ActionDisplayExecute(ActionDisplayScripts);
    end
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.DockpanelOptionsDockChanged(Sender: TObject);
begin
  DockpanelOptions.Height := DockpanelOptions.Height + 1;
  DockpanelOptions.Height := DockpanelOptions.Height - 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.DockpanelParametersDockChanged(Sender: TObject);
begin
  DockpanelParameters.Height := DockpanelParameters.Height + 1;
  DockpanelParameters.Height := DockpanelParameters.Height - 1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FillFields;
var
  NewItem: TListItem;
  f: Integer;
begin
  with lstLimitFields.Items do
  begin
    BeginUpdate;
    lstLimitFields.ViewStyle := vsIcon;
    try
      Clear;
      if FCurrentScript <> nil then
      begin
        NewItem := Add;
        NewItem.Caption := strFieldPicture;
        NewItem.Data := Pointer(fieldPicture);
        NewItem.Checked := FCurrentScript.Fields.Picture;
        for f := fieldLow to fieldCount-1 do
          if not (f in VirtualFields) then
          begin
            NewItem := Add;
            NewItem.Caption := strFields[f];
            NewItem.Data := Pointer(f);
            NewItem.Checked := not (f in FCurrentScript.Fields.FieldsExcluded);
          end;
        with FMovieList.CustomFieldsProperties do
          for f := 0 to Count-1 do
            if Objects[f].FieldType <> ftVirtual then
            begin
              NewItem := lstLimitFields.Items.Add;
              NewItem.Caption := Objects[f].FieldName + ' (' + Objects[f].FieldTag + ')';
              NewItem.Data := Pointer(customFieldLow+f);
              NewItem.Checked := not Objects[f].ExcludedInScripts;
            end;
        NewItem := Add;
        NewItem.Caption := Messages.Strings.Strings[msgAddExtras];
        NewItem.Data := Pointer(customFieldMax+1);
        NewItem.Checked := FCurrentScript.Fields.AddExtras;
        NewItem := Add;
        NewItem.Caption := Messages.Strings.Strings[msgDeleteExtras];
        NewItem.Data := Pointer(customFieldMax+2);
        NewItem.Checked := FCurrentScript.Fields.DeleteExtras;
        NewItem := Add;
        NewItem.Caption := Messages.Strings.Strings[msgModifyExtras];
        NewItem.Data := Pointer(customFieldMax+3);
        NewItem.Checked := FCurrentScript.Fields.ModifyExtras;
        for f := extraFieldLow to extraFieldCount-1 do
          if not (f in VirtualFields) then
          begin
            NewItem := Add;
            NewItem.Caption := strExtraFields[f - extraFieldLow] + ' (' + strExtras + ')';
            NewItem.Data := Pointer(f);
            NewItem.Checked := not (f in FCurrentScript.Fields.ExtraFieldsExcluded);
          end;
        NewItem := Add;
        NewItem.Caption := strExtraFieldPicture + ' (' + strExtras + ')';
        NewItem.Data := Pointer(extraFieldPicture);
        NewItem.Checked := FCurrentScript.Fields.ExtraPicture;
      end;
      lstLimitFields.ViewStyle := vsSmallIcon;
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.CheckProperties;
begin
  if FCurrentScript <> nil then
  begin
    lstLimitMovies.Visible := FCurrentScript.Properties.RequiresMovies;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FillOptions;
var
  NewItem: TListItem;
  i: Integer;
begin
  lstScriptOptions.Visible := False;
  lstScriptOptions.Items.BeginUpdate;
  try
    lstScriptOptions.Clear;
    if FCurrentScript <> nil then
      for i := 0 to FCurrentScript.Options.Count-1 do
      begin
        NewItem := lstScriptOptions.Items.Add;
        NewItem.Caption := FCurrentScript.Options[i].Name;
        NewItem.SubItems.Add(IntToStr(FCurrentScript.Options[i].Value));
        NewItem.Data := FCurrentScript.Options[i];
      end;
  finally
    lstScriptOptions.Items.EndUpdate;
    lstScriptOptions.Width := 123;
    lstScriptOptions.Visible := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.UpdateOptions;
var
  i: Integer;
begin
  for i := 0 to FCurrentScript.Options.Count-1 do
    lstScriptOptions.Items[i].SubItems[0] := IntToStr(FCurrentScript.Options[i].Value);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FillParameters;
var
  NewItem: TListItem;
  i: Integer;
begin
  lstScriptParameters.Visible := False;
  lstScriptParameters.Items.BeginUpdate;
  try
    lstScriptParameters.Clear;
    if FCurrentScript <> nil then
      for i := 0 to FCurrentScript.Parameters.Count-1 do
      begin
        NewItem := lstScriptParameters.Items.Add;
        NewItem.Caption := FCurrentScript.Parameters[i].Name;
        NewItem.SubItems.Add(FCurrentScript.Parameters[i].Value);
        NewItem.Data := FCurrentScript.Parameters[i];
      end;
  finally
    lstScriptParameters.Items.EndUpdate;
    lstScriptParameters.Width := 123;
    lstScriptParameters.Visible := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.UpdateParameters;
var
  i: Integer;
begin
  for i := 0 to FCurrentScript.Parameters.Count-1 do
    lstScriptParameters.Items[i].SubItems[0] := FCurrentScript.Parameters[i].Value;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.SaveScriptFields;
var
  i, f: Integer;
  UncheckedFields: TMovieFields;
  UncheckedExtraFields: TMovieFields;
begin
  if FCurrentScript = nil then
    Exit;
  SaveCustomFields;
  UncheckedFields := [];
  UncheckedExtraFields := [];

  for i := 0 to lstLimitFields.Items.Count-1 do
  begin
    f := Integer(lstLimitFields.Items[i].Data);
    if f = fieldPicture then
      FCurrentScript.Fields.Picture := lstLimitFields.Items[i].Checked
    else if f in AllFields then
    begin
      if not lstLimitFields.Items[i].Checked then
        Include(UncheckedFields, f);
    end
    else if f = customFieldMax+1 then
      FCurrentScript.Fields.AddExtras := lstLimitFields.Items[i].Checked
    else if f = customFieldMax+2 then
      FCurrentScript.Fields.DeleteExtras := lstLimitFields.Items[i].Checked
    else if f = customFieldMax+3 then
      FCurrentScript.Fields.ModifyExtras := lstLimitFields.Items[i].Checked
    else if f in AllExtraFields then
    begin
      if not lstLimitFields.Items[i].Checked then
        Include(UncheckedExtraFields, f);
    end
    else if f = extraFieldPicture then
      FCurrentScript.Fields.ExtraPicture := lstLimitFields.Items[i].Checked;
  end;

  FCurrentScript.Fields.FieldsExcluded := UncheckedFields;
  FCurrentScript.Fields.ExtraFieldsExcluded := UncheckedExtraFields;
  FCurrentScript.Save;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.SaveCustomFields;
var
  i, f: Integer;
begin
  for i := 0 to lstLimitFields.Items.Count-1 do
  begin
    f := Integer(lstLimitFields.Items[i].Data);
    if f in AllCustomFields then
      if FMovieList.CustomFieldsProperties.Objects[f-customFieldLow].
        ExcludedInScripts <> not lstLimitFields.Items[i].Checked then
      begin
        FMovieList.CustomFieldsProperties.Objects[f-customFieldLow].
          ExcludedInScripts := not lstLimitFields.Items[i].Checked;
        FCurrentCatalog.Modified := True;
      end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstLimitFieldsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  SaveCustomFields;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionViewFilterExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionViewFilterChangeExecute(Sender: TObject);
begin
  FillScripts;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionViewListExecute(Sender: TObject);
begin
  if ActionViewList.Checked then
  begin
    lstScripts.ViewStyle := vsList;
    lstScripts.OnInfoTip := lstScriptsInfoTip;
  end
  else
  begin
    lstScripts.ViewStyle := vsReport;
    lstScripts.OnInfoTip := nil;
  end;
  lstScripts.Width := 123;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ReadScripts;
var
  NewItem: TTBXItem;
  i: Integer;
begin
  FScripts := TScriptList.Create(strDirScripts);
  for i := 0 to FScripts.Languages.Count-1 do
  begin
    NewItem := TTBXItem.Create(MnuScrFlt);
    NewItem.Caption := FScripts.Languages[i];
    NewItem.OnClick := ActionViewFilterChangeExecute;
    NewItem.Checked := True;
    NewItem.AutoCheck := True;
    NewItem.Tag := i + 1;
    FScripts.Languages.Objects[i] := NewItem;
    MnuScrFlt.Add(NewItem);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.FillScripts;
var
  NewItem: TListItem;
  CurScript: TScriptInfo;
  i, idx: Integer;
begin
  with lstScripts.Items do
  begin
    BeginUpdate;
    lstScripts.ViewStyle := vsSmallIcon;
    try
      Clear;
      for i := 0 to FScripts.Count-1 do
      begin
        CurScript := FScripts[i] as TScriptInfo;
        if CurScript.FileName = '' then
          Continue;
        if (FWorkMode = swmGetInfo) and (not CurScript.Properties.GetInfo) then
          Continue;
        idx := FScripts.Languages.IndexOf(CurScript.Properties.Language);
        if (CurScript.Properties.Language <> '') and (idx <> -1) and not (FScripts.Languages.Objects[idx] as TTBXItem).Checked then
          Continue;
        NewItem := Add;
        NewItem.Caption := CurScript.Properties.Title;
        if NewItem.Caption = '' then
          NewItem.Caption := CurScript.FileName;
        NewItem.SubItems.Text := CurScript.Properties.Description;
        NewItem.Data := CurScript;
        if CurScript.Properties.GetInfo then
          NewItem.ImageIndex := Ord(ICON_MOVIEIMPORTSCRIPT)
        else
          NewItem.ImageIndex := Ord(ICON_SCRIPTING);
      end;
      if ActionViewDetailed.Checked then
        lstScripts.ViewStyle := vsReport
      else
        lstScripts.ViewStyle := vsList;
    finally
      EndUpdate;
    end;
  end;
  lstScripts.AlphaSort;
  lstScripts.Width := 123;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.tabScriptInfoChange(Sender: TObject; NewTab: Integer; var AllowChange: Boolean);
begin
  AllowChange := True;
  lblScriptInfo.Caption := '';
  if {(lstScripts.Selected <> nil) and} (FCurrentScript <> nil) then
  begin
    case NewTab of
      0:
        with FCurrentScript.Properties, ScriptPropertiesWin.Messages do
        begin
          lblScriptInfo.Caption :=
            Format('%s %s<br>', [Strings[msgInfoAuthors], Authors]) +
            Format('%s <link>%s</link><br>', [Strings[msgInfoSite], Site]) +
            Format('%s %s<br>', [Strings[msgInfoLanguage], Language]) +
            Format('%s %s<br>', [Strings[msgInfoVersion], Version]) +
            Format('%s Ant Movie Catalog %s', [Strings[msgInfoRequires], Requires]);
        end;
      1:
        lblScriptInfo.Caption := StringReplace(FCurrentScript.Properties.Comments, '|', '<br>', [rfReplaceAll]);
      2:
        lblScriptInfo.Caption := StringReplace(FCurrentScript.Properties.License, '|', '<br>', [rfReplaceAll]);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lblScriptInfoLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
begin
  if Pos('://', LinkText) > 0 then
    LaunchProg(LinkText)
  else
  if Pos('@', LinkText) > 0 then
    LaunchProg('mailto:' + LinkText)
  else
    LaunchProg('http://' + LinkText)
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionOptionsEditExecute(Sender: TObject);
var
  CurOption: TScriptOption;
  i, idx, res: Integer;
begin
  if lstScriptOptions.Selected <> nil then
  begin
    CurOption := TScriptOption(lstScriptOptions.Selected.Data);
    ListWin.Caption := Format(Messages.Strings[msgValueForOption], [CurOption.Name]);
    with ListWin.lst.Items do
    begin
      idx := -1;
      BeginUpdate;
      try
        Clear;
        for i := 0 to Length(CurOption.Values)-1 do
        begin
          res := AddObject(Format('%d -> %s', [CurOption.Values[i].Value, CurOption.Values[i].Description]), Pointer(CurOption.Values[i].Value));
          if CurOption.Values[i].Value = CurOption.Value then
            idx := res;
        end;
      finally
        EndUpdate;
      end;
      ListWin.lst.ItemIndex := idx;
    end;
    ListWin.FitToContents;
    if ListWin.Execute then
    begin
      idx := ListWin.lst.ItemIndex;
      if idx = -1 then
        Exit;
      CurOption.Value := Integer(ListWin.lst.Items.Objects[idx]);
      lstScriptOptions.Selected.SubItems[0] := IntToStr(CurOption.Value);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionOptionsDefaultExecute(Sender: TObject);
var
  i: Integer;
begin
  if FCurrentScript <> nil then
  begin
    for i := 0 to FCurrentScript.Options.Count-1 do
      FCurrentScript.Options[i].Value := FCurrentScript.Options[i].DefValue;
    UpdateOptions;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptOptionsKeyPress(Sender: TObject; var Key: Char);
begin
  if Word(Key) in [VK_RETURN, VK_SPACE] then
    ActionOptionsEdit.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptOptionsInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
var
  CurOption: TScriptOption;
  i: Integer;
begin
  CurOption := TScriptOption(Item.Data);
  InfoTip := Format('%s = %d', [CurOption.Name, CurOption.Value]);
  for i := 0 to Length(CurOption.Values)-1 do
  begin
    if CurOption.Values[i].Value = CurOption.Value then
    begin
      InfoTip := Format('%s%s%s', [InfoTip, sLineBreak, CurOption.Values[i].Description]);
      Break;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionParametersEditExecute(Sender: TObject);
var
  CurParameter: TScriptParameter;
begin
  if lstScriptParameters.Selected <> nil then
  begin
    CurParameter := TScriptParameter(lstScriptParameters.Selected.Data);
    if InputWin.Execute(
      Format(Messages.Strings[msgValueForParameter], [CurParameter.Name]),
      CurParameter.Description,
      CurParameter.Value) then
    begin
      lstScriptParameters.Selected.SubItems[0] := CurParameter.Value;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.ActionParametersDefaultExecute(Sender: TObject);
var
  i: Integer;
begin
  if FCurrentScript <> nil then
  begin
    for i := 0 to FCurrentScript.Parameters.Count-1 do
      FCurrentScript.Parameters[i].Value := FCurrentScript.Parameters[i].DefValue;
    UpdateParameters;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptParametersKeyPress(Sender: TObject; var Key: Char);
begin
  if Word(Key) in [VK_RETURN, VK_SPACE] then
    ActionParametersEdit.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptParametersInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
var
  CurParameter: TScriptParameter;
begin
  CurParameter := TScriptParameter(Item.Data);
  InfoTip := Format('%s = %s', [CurParameter.Name, CurParameter.Value]);
  InfoTip := Format('%s%s%s', [InfoTip, sLineBreak, CurParameter.Description]);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptsInfoTip(Sender: TObject; Item: TListItem; var InfoTip: String);
var
  CurScript: TScriptInfo;
begin
  CurScript := TScriptInfo(Item.Data);
  InfoTip := CurScript.Properties.Description;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstWatchKeyPress(Sender: TObject; var Key: Char);
begin
  if Word(Key) = VK_DELETE then
    ActionDebugWatchRemove.Execute;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.EScriptGutterClick(Sender: TObject; Button: TMouseButton; X, Y, Line: Integer; Mark: TSynEditMark);
begin
  if X <= EScript.Gutter.LeftOffset then
    FDebugPlugin.ToggleBreakpoint(Line);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.EScriptSpecialLineColors(Sender: TObject; Line: Integer; var Special: Boolean; var FG, BG: TColor);
begin
  if (FScriptStatus in [iStepOver, iStepOverWaiting]) and (Line = DebugPlugin.CurrentLine) then
  begin
    Special := True;
    FG := clWhite;
    BG := clNavy;
  end
  else
  if FDebugPlugin.IsBreakpoint(Line) then
  begin
    Special := True;
    FG := clWhite;
    BG := clRed;
  end
  else
  if (DebugPlugin.ErrorLine <> -1) and (Line = DebugPlugin.ErrorLine) then
  begin
    Special := True;
    FG := clWhite;
    BG := clMaroon;
  end
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.EScriptGutterPaint(Sender: TObject; aLine, X, Y: Integer);
var
  IconIndex: Integer;
begin
  IconIndex := -1;
  if DebugPlugin.IsBreakpoint(ALine) then
  begin
    if FScriptStatus = iStopped then
      IconIndex := imgGutterBREAK
    else
    begin
      if DebugPlugin.CurrentLine = ALine then
        IconIndex := imgGutterEXECLINEBP
      else
        IconIndex := imgGutterBREAKVALID
    end;
  end
  else
  begin
    if (FScriptStatus = iStepoverWaiting) and (DebugPlugin.CurrentLine = ALine) then
      IconIndex := imgGutterEXECLINE;
  end;
  if IconIndex <> -1 then
    lstDebugImages.Draw(EScript.Canvas, X, Y, IconIndex);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.EScriptStatusChange(Sender: TObject; Changes: TSynStatusChanges);
var
  i: Integer;
begin
  if (scCaretX in Changes) or (scCaretY in Changes) then
  begin
    sbEditor.Panels[pnlEditorPos].Caption := Format('%d:%d', [EScript.CaretX, EScript.CaretY]);
    if DebugPlugin.ErrorLine <> -1 then
    begin
      i := DebugPlugin.ErrorLine;
      DebugPlugin.ErrorLine := -1;
      EScript.InvalidateGutterLine(i);
      EScript.InvalidateLine(i);
    end;
  end;
  if (scModified in Changes) then
  begin
    FCurrentFile.Modified := EScript.Modified;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnCancelDownload(Sender: TObject);
begin
  if (http.IOHandler <> nil) and (http.IOHandler.ClassType = TIdSSLIOHandlerSocketOpenSSL) then
    exit;
  if Assigned(DownloadThread) then
  begin
    http.Disconnect;
  end;
  if Assigned(ProgressWin) then
  begin
    ProgressWin.OnCancel := nil;
    ProgressWin.Close;
  end;
  Application.ProcessMessages;
  DownloadState := dsCanceled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.OnThreadEnd(Sender: TObject);
begin
  if Assigned(DownloadThread) then // if nil then it has been canceled before
    with DownloadThread do
    begin
      DownloadState := FState;
      DownloadResult := '';
      case FState of
        dsFinished:
          begin
            DownloadResult := FResult;
          end;
        dsFailed:
          begin
            if FRaiseConnectionErrors then
              MessageWin.Execute(FResult, mtError, [mbOk]);
          end;
      end;
    end;
  DownloadThread := nil;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.lstScriptsCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  Sender.Canvas.Font.Color := clWindowText;
  if (Item <> nil) then
  begin
    if TScriptInfo(Item.Data).Properties.OldFormat then
    begin
      Sender.Canvas.Font.Color := clGrayText;
    end;
  end;
  DefaultDraw := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TGetScriptWin.GetVariableValue(Sender: TObject; const VarName: string): string;
var
  v: PIfVariant;
begin
  Result := '?';
  v := FScript.GetVariable(VarName);
  if v <> nil then
  begin
    if IsIntegerType(v) then
      Result := IntToStr(GetInteger(v))
    else
    if IsStringType(v) then
      Result := QuotedStr(GetString(v))
    else
    if IsRealType(v) then
      Result := Format('%g', [GetReal(v)])
    else
    if IsBooleanType(v) then
      Result := BoolToStr(GetBoolean(v), True)
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TGetScriptWin.HasRemainingMovies: Boolean;
begin
  Result := FIteration < FMovieListFiltered.Count-1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TGetScriptWin.GetCurrentLine: Integer;
begin
  Result := DebugPlugin.CurrentLine;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TGetScriptWin.SetCurrentLine(const Value: Integer);
begin
  if FScriptStatus <> iRunning then
  begin
    EScript.InvalidateGutterLine(FDebugPlugin.CurrentLine);
    EScript.InvalidateLine(FDebugPlugin.CurrentLine);
  end;
  FDebugPlugin.CurrentLine := EScript.CharIndexToRowCol(Value).Line;
  if ((FDebugPlugin.CursorLine <> -1) and (FDebugPlugin.CursorLine = FDebugPlugin.CurrentLine))
    or (FDebugPlugin.IsBreakpoint(FDebugPlugin.CurrentLine))
    or (FScriptStatus = iStepOver) then
  begin
    FScriptStatus := iStepOverWaiting;
    ActionDebugRun.Update;
    ActionDebugStop.Update;
    EScript.InvalidateGutterLine(FDebugPlugin.CurrentLine);
    EScript.InvalidateLine(FDebugPlugin.CurrentLine);
    EScript.CaretX := 0;
    EScript.CaretY := FDebugPlugin.CurrentLine;
    FDebugPlugin.UpdateWatches;
    while FScriptStatus = iStepOverWaiting do
    begin
      Application.HandleMessage;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{
function GetCookies(url: string; secure: boolean = true): string;
var
  URI : TIdURI;
begin
  Result := '';
  URI := TIdURI.Create(url);
  try
    Result := GetScriptWin.http.CookieManager.GenerateCookieList(URI, secure);
  except
  end;
  FreeAndNil(URI);
end;
}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{
function GetCookiesWithProperties(url: string; secure: boolean = true): string;
var
  URI : TIdURI;
begin
  Result := '';
  URI := TIdURI.Create(url);
  try
    Result := GetScriptWin.http.CookieManager.GenerateCookieListWithProperties(URI, secure);
  except
  end;
  FreeAndNil(URI);
end;
}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure AddCookie(cookie: string; hostOrUrl: string);
var
  Uri: TIdURI;
begin
  cookie := Trim(cookie);
  hostOrUrl := StringReplace(hostOrUrl, 'http://', '', [rfIgnoreCase]);
  hostOrUrl := StringReplace(hostOrUrl, 'https://', '', [rfIgnoreCase]);
  hostOrUrl := Fetch(hostOrUrl, '/');
  hostOrUrl := Trim(hostOrUrl);
  try
    if (Length(cookie) > 0) and (Length(hostOrUrl) > 0) then
    begin
      Uri := TIdURI.Create(hostOrUrl);
      try
        GetScriptWin.http.CookieManager.AddServerCookie(cookie, Uri);
      finally
        Uri.Free;
      end;
    end;
  except
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure SetCookies(cookies: string; hostOrUrl: string);
begin
  while Pos(';', cookies) > 0 do
    AddCookie(Fetch(cookies, ';'), hostOrUrl);
  if (Pos(';', cookies) = 0) then
    AddCookie(cookies, hostOrUrl);
end;
{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{
procedure DeleteCookies(url: string);
var
  URI : TIdURI;
begin
  URI := TIdURI.Create(url);
  try
    GetScriptWin.http.CookieManager.DestroyCookieListByDomain(URI);
  except
  end;
  FreeAndNil(URI);
end;
}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

{
procedure DeleteAllCookies();
begin
  try
     GetScriptWin.http.CookieManager.DestroyCookieList;
  except
  end;
end;
}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetPage(const address, referer, cookies, content, headers: string): string;
var
  UseSSL: Boolean;
  headerStrings: TStrings;
begin
  UseSSL := StartsText('HTTPS://', address);
  if UseSSL then
    GetScriptWin.http.IOHandler := GetScriptWin.SSLIOHandlerSocket
  else
    GetScriptWin.http.IOHandler := GetScriptWin.IOHandlerSocket;
  GetScriptWin.http.Compressor := GetScriptWin.FCompressorZLib;
  GetScriptWin.http.Request.ContentType := content;
  GetScriptWin.http.Request.Referer := referer;
  GetScriptWin.http.Request.CustomHeaders.Clear;
  if headers <> '' then
  begin
    headerStrings := TStringList.Create();
    try
      headerStrings.Text := headers;
      GetScriptWin.http.Request.CustomHeaders.AddStrings(headerStrings);
    finally
      headerStrings.Free;
    end;
  end;
  if cookies <> '' then
    SetCookies(cookies, address);
  GetScriptWin.http.HTTPOptions := GetScriptWin.http.HTTPOptions - [hoKeepOrigProtocol];
  Result := '';
  with ProgressWin do
  begin
    Maximum := 1;
    AutoUpdateTextProgress := False;
    IntProgress := 0;
    Progress := '';
    Status := 'Importing data from internet...';
    Execute(GetScriptWin);
    try
      Application.ProcessMessages;
      DownloadThread := TDownloadThread.Create(True);
      with DownloadThread do
      begin
        FState := dsNone;
        FURL := address;
        FToDo := daGetPage;
        FHTTP := GetScriptWin.http;
        OnTerminate := GetScriptWin.OnThreadEnd;
        if not UseSSL then
          ProgressWin.OnCancel := GetScriptWin.OnCancelDownload
        else
          ProgressWin.OnCancel := nil;
        DownloadState := dsBusy;
        Resume;
      end;
      IntProgress := 1;
      while DownloadState = dsBusy do
        Application.HandleMessage;
      if DownloadState = dsFinished then
        Result := AdjustLineBreaks(DownloadResult);
    finally
      OnCancel := nil;
      Close;
      AutoUpdateTextProgress := True;
      Application.ProcessMessages;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function PostPage(const address, params, content, referer: string; forceHTTP11: Boolean; forceEncodeParams: Boolean; headers: string): string;
var
  UseSSL: Boolean;
  headerStrings: TStrings;
begin
  UseSSL := StartsText('HTTPS://', address);
  if UseSSL then
    GetScriptWin.http.IOHandler := GetScriptWin.SSLIOHandlerSocket
  else
    GetScriptWin.http.IOHandler := GetScriptWin.IOHandlerSocket;
  GetScriptWin.http.Compressor := GetScriptWin.FCompressorZLib;
  GetScriptWin.http.Request.ContentType := content;
  GetScriptWin.http.Request.Referer := referer;
  if forceHTTP11 then
    GetScriptWin.http.HTTPOptions := GetScriptWin.http.HTTPOptions + [hoKeepOrigProtocol]
  else
    GetScriptWin.http.HTTPOptions := GetScriptWin.http.HTTPOptions - [hoKeepOrigProtocol];
  if forceEncodeParams then
    GetScriptWin.http.HTTPOptions := GetScriptWin.http.HTTPOptions + [hoForceEncodeParams]
  else
    GetScriptWin.http.HTTPOptions := GetScriptWin.http.HTTPOptions - [hoForceEncodeParams];
  GetScriptWin.http.Request.CustomHeaders.Clear;
  if headers <> '' then
  begin
    headerStrings := TStringList.Create();
    try
      headerStrings.Text := headers;
      GetScriptWin.http.Request.CustomHeaders.AddStrings(headerStrings);
    finally
      headerStrings.Free;
    end;
  end;
  Result := '';
  with ProgressWin do
  begin
    Maximum := 1;
    AutoUpdateTextProgress := False;
    IntProgress := 0;
    Progress := '';
    Status := 'Importing data from internet...';
    Execute(GetScriptWin);
    try
      Application.ProcessMessages;
      DownloadThread := TDownloadThread.Create(True);
      with DownloadThread do
      begin
        FState := dsNone;
        FURL := address;
        FParams := params;
        FToDo := daPostPage;
        FHTTP := GetScriptWin.http;
        OnTerminate := GetScriptWin.OnThreadEnd;
        if not UseSSL then
          ProgressWin.OnCancel := GetScriptWin.OnCancelDownload
        else
          ProgressWin.OnCancel := nil;
        DownloadState := dsBusy;
        Resume;
      end;
      IntProgress := 1;
      while DownloadState = dsBusy do
        Application.HandleMessage;
      if DownloadState = dsFinished then
        Result := AdjustLineBreaks(DownloadResult);
    finally
      OnCancel := nil;
      Close;
      AutoUpdateTextProgress := True;
      Application.ProcessMessages;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function GetPicture(const extraIndex: Integer; const address, referer, content: string): Boolean;
var
  Stream: TMemoryStream;
  UseSSL: Boolean;
begin
  Result := False;
  UseSSL := StartsText('HTTPS://', address);
  if UseSSL then
    GetScriptWin.http.IOHandler := GetScriptWin.SSLIOHandlerSocket
  else
    GetScriptWin.http.IOHandler := GetScriptWin.IOHandlerSocket;
  GetScriptWin.http.Compressor := GetScriptWin.FCompressorZLib;
  GetScriptWin.http.Request.Referer := referer;
  GetScriptWin.http.Request.ContentType := content;
  with ProgressWin do
  begin
    Maximum := 1;
    AutoUpdateTextProgress := False;
    IntProgress := 0;
    Progress := '';
    Status := 'Importing picture from internet...';
    Stream := TMemoryStream.Create;
    Execute(GetScriptWin);
    try
      Application.ProcessMessages;
      DownloadThread := TDownloadThread.Create(True);
      with DownloadThread do
      begin
        FState := dsNone;
        FURL := address;
        FToDo := daGetFile;
        FHTTP := GetScriptWin.http;
        FStream := Stream;
        OnTerminate := GetScriptWin.OnThreadEnd;
        if not UseSSL then
          ProgressWin.OnCancel := GetScriptWin.OnCancelDownload
        else
          ProgressWin.OnCancel := nil;
        DownloadState := dsBusy;
        Resume;
      end;
      IntProgress := 1;
      while DownloadState = dsBusy do
        Application.HandleMessage;
      if DownloadState = dsFinished then
      begin
        if extraIndex <> -MaxInt then
          Result := ScriptResultsWin.SetExtraPicture(extraIndex, Stream, address)
        else
          Result := ScriptResultsWin.SetPicture(Stream, address);
      end;
    finally
      Close;
      AutoUpdateTextProgress := True;
      Stream.Free;
      Application.ProcessMessages;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRunLine(id: Pointer; Sender: TIfPasScript; Position: Longint): TCs2Error;
begin
  Result := Sender.ErrorCode;
  Application.ProcessMessages;
  GetScriptWin.CurrentLine := Position;
  if FScriptStatus = iStopped then
    Result := EExitCommand
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptUses(id: Pointer; Sender: TIfPasScript; Name: string): TCs2Error;
var
  SecondEngine: TIfPasScript;
  f: TFileStream;
  s: string;
begin
  if Name = 'SYSTEM' then
  begin
    RegisterStdLib(Sender, False);
    RegisterDateTimeLib(Sender);
    RegisterEClasses(Sender, Cl);
    RegisterDelphiFunction(Sender, 'function AnsiUpperCase(Value: string): string;', @AnsiUpperCase);
    RegisterDelphiFunction(Sender, 'function AnsiLowerCase(Value: string): string;', @AnsiLowerCase);
    RegisterDelphiFunction(Sender, 'function AnsiCompareStr(S1, S2: string): Integer;', @AnsiCompareStr);
    RegisterDelphiFunction(Sender, 'function AnsiCompareText(S1, S2: string): Integer;', @AnsiCompareText);

    RegisterDelphiFunction(Sender, 'function GetCurrentDir: string;', @GetCurrentDir);
    RegisterDelphiFunction(Sender, 'function SetCurrentDir(DirName: string): boolean;', @SetCurrentDir);
    RegisterDelphiFunction(Sender, 'function ExpandFileName(FileName: string): string;', @ExpandFileName);
    RegisterDelphiFunction(Sender, 'function ExtractRelativePath(BaseName: string; DestName: string): string;', @ExtractRelativePath);
    RegisterDelphiFunction(Sender, 'function ExtractFileName(AFileName: string): string;', @ExtractFileName);
    RegisterDelphiFunction(Sender, 'function ExtractFileExt(AFileName: string): string;', @ExtractFileExt);
    RegisterDelphiFunction(Sender, 'function ExtractFilePath(AFileName: string): string;', @ExtractFilePath);
    RegisterDelphiFunction(Sender, 'function ChangeFileExt(AFileName: string; AExt: string): string;', @ChangeFileExt);
    RegisterDelphiFunction(Sender, 'function IncludeTrailingPathDelimiter(AFileName: string): string;', @IncludeTrailingPathDelimiter);
    RegisterDelphiFunction(Sender, 'function ExcludeTrailingPathDelimiter(AFileName: string): string;', @ExcludeTrailingPathDelimiter);
    RegisterDelphiFunction(Sender, 'function FileExists(FileName: string): Boolean;', @FileExists);
    RegisterDelphiFunction(Sender, 'function DirectoryExists(DirName: string): Boolean;', @DirectoryExists);

    with Sender do
    begin
      AddFunction(@OnScriptRegScriptProc, 'function CheckVersion(Major, Minor, Revision: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function AcceptLicense(LicenseVersion: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptFilename: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptFullPath: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptAuthors: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptTitle: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptDescription: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptSite: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptVersion: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptComments: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetScriptLicense: string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetOption(OptName: string): Integer;', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure SetOption(OptName: string; Value: Integer);', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetParam(PrmName: string): string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure SetParam(PrmName: string; Value: String);', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure SetStatic(AName: string; AValue: string);', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetStatic(AName: string): string;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetIteration: Integer;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function GetIterationCount: Integer;', nil);
      AddFunction(@OnScriptRegScriptProc, 'function AddNewMovieToQueue: Integer;', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure Sleep(ATime: Integer);', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure Launch(command: string; parameters: string);', nil);
      AddFunction(@OnScriptRegScriptProc, 'procedure Error;', nil);

      AddFunction(@OnScriptRegMsgProc, 'procedure ShowMessage(message: string);', nil);
      AddFunction(@OnScriptRegMsgProc, 'procedure ShowError(message: string);', nil);
      AddFunction(@OnScriptRegMsgProc, 'procedure ShowInformation(message: string);', nil);
      AddFunction(@OnScriptRegMsgProc, 'function ShowWarning(message: string): Boolean;', nil);
      AddFunction(@OnScriptRegMsgProc, 'function ShowConfirmation(message: string): Boolean;', nil);
      AddFunction(@OnScriptRegMsgProc, 'procedure ShowMemo(message: string);', nil);
      AddFunction(@OnScriptRegMsgProc, 'function Input(caption, prompt: string; var value: string): Boolean;', nil);

      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeTitle(Title: string);', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeDefaultTitle;', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeClear;', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeAdd(Caption, Address: string);', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeCount: Integer;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeCountAddresses: Integer;', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeMoreLink(Address: string);', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickTreeSort;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeExec(var Address: string): Boolean;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeExec2(var Address: string; var AddressId: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeExec3(Message: string; var Address: string): Boolean;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickTreeExec4(Message: string; var Address: string; var AddressId: Integer): Boolean;', nil);

      AddFunction(@OnScriptRegPickProc, 'procedure PickListTitle(Title: string);', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickListDefaultTitle;', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickListClear;', nil);
      AddFunction(@OnScriptRegPickProc, 'procedure PickListAdd(Text: string);', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickListCount: Integer;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickListExec(WelcomeText: string; var Selected: string): Boolean;', nil);
      AddFunction(@OnScriptRegPickProc, 'function PickListExec2(WelcomeText: string; var Selected: string; var SelectedId: Integer): Boolean;', nil);

      AddFunction(@OnScriptRegMediaProc, 'function LoadMedia(filename: string): Boolean;', nil);
      AddFunction(@OnScriptRegMediaProc, 'function GetMediaInfo(media: Integer): String;', nil);
      AddFunction(@OnScriptRegMediaProc, 'function GetMediaInfoLS(media: Integer): String;', nil);

      AddFunction(@OnScriptRegCookieProc, 'function GetCookies(url: string): string;', nil);
      AddFunction(@OnScriptRegCookieProc, 'function GetCookiesWithProperties(url: string): string;', nil);
      AddFunction(@OnScriptRegCookieProc, 'procedure SetCookies(cookies: string; hostOrUrl: string);', nil);
      AddFunction(@OnScriptRegCookieProc, 'procedure AddCookie(cookie: string; hostOrUrl: string);', nil);
      AddFunction(@OnScriptRegCookieProc, 'procedure DeleteCookies(url: string);', nil);
      AddFunction(@OnScriptRegCookieProc, 'procedure DeleteAllCookies;', nil);

      AddFunction(@OnScriptRegHtmlProc, 'function GetPage(address: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPage2(address: string; referer: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPage3(address: string; referer: string; cookies: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPage4(address: string; referer: string; cookies: string; contentType: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPage5(address: string; referer: string; cookies: string; contentType: string; headers: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function PostPage(address: string; params: string): string', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function PostPage2(address: string; params: string; content: string; referer: string; forceHTTP11: Boolean; forceEncodeParams: Boolean): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function PostPage3(address: string; params: string; content: string; referer: string; forceHTTP11: Boolean; forceEncodeParams: Boolean; headers: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'procedure HTMLDecode(var Value: string);', nil);
      AddFunction(@OnScriptRegHtmlProc, 'procedure HTMLRemoveTags(var Value: string);', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function URLEncode(source: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function URLDecode(source: string): string;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPicture(address: string): Boolean;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPicture2(address: string; referer: string): Boolean;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetPicture3(address: string; referer: string; content: string): Boolean;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetExtraPicture(extraIndex: Integer; address: string): Boolean;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'function GetExtraPicture2(extraIndex: Integer; address: string; referer: string): Boolean;', nil);
      AddFunction(@OnScriptRegHtmlProc, 'procedure RaiseConnectionErrors(raise: Boolean);', nil);

      AddFunction(@OnScriptRegFieldProc, 'function IsSelected: Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'procedure SetSelected(selected: Boolean);', nil);

      AddFunction(@OnScriptRegFieldProc, 'procedure SetField(field: Integer; value: string);', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetField(field: Integer): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetFieldLS(field: Integer): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function CanSetField(field: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetFieldName(field: Integer): String;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetFieldType(field: Integer): String;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetFieldTag(field: Integer): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetFieldCount: Integer;', nil);

      AddFunction(@OnScriptRegFieldProc, 'procedure SetCustomField(fieldTag: string; value: string);', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomField(fieldTag: string): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomFieldLS(fieldTag: string): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function CanSetCustomField(fieldTag: String): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function CustomFieldExists(fieldTag: String): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomFieldName(fieldTag: string): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomFieldType(fieldTag: string): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomFieldTag(customfield: Integer): string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetCustomFieldCount: Integer;', nil);

      AddFunction(@OnScriptRegFieldProc, 'function ImportPicture(filename: string): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function ImportPicture2(filename: string; picImportMethod: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function ExportPicture(filename: string): Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function RemovePicture: Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function CanSetPicture: Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function PictureExists: Boolean;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureStatus: Integer;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureExt: string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPicturePath: string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureFullPath: string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureSize: Double;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureWidth: Integer;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function GetPictureHeight: Integer;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function ConvertPicture(maxWidth: Integer; maxHeight: Integer): Boolean;', nil);
      // To keep compatibility with AMC 4.1 scripts (same as GetPictureExt, ...)
      AddFunction(@OnScriptRegFieldProc, 'function PictureExt: string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function PicturePath: string;', nil);
      AddFunction(@OnScriptRegFieldProc, 'function PictureFullPath: string;', nil);

      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraCount: Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function FindExtra(extraTag: string): Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function AddExtra: Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function CanAddExtras: Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function DeleteExtra(extraIndex: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function DeleteExtraCreatedBy(extraIndex: Integer; createdBy: string): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function DeleteExtraOfScript(extraIndex: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'procedure ClearExtras;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'procedure ClearExtrasCreatedBy(createdBy: string);', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'procedure ClearExtrasOfScript;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function CanDeleteExtras: Boolean;', nil);

      AddFunction(@OnScriptRegExtraFieldProc, 'function IsExtraSelected(extraIndex: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'procedure SetExtraSelected(extraIndex: Integer; selected: Boolean);', nil);

      AddFunction(@OnScriptRegExtraFieldProc, 'procedure SetExtraField(extraIndex: Integer; extraField: Integer; value: string);', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraField(extraIndex: Integer; extraField: Integer): string;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function CanModifyExtras: Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function CanSetExtraField(extraField: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraFieldName(extraField: Integer): String;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraFieldType(extraField: Integer): String;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraFieldTag(extraField: Integer): String;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraFieldCount: Integer;', nil);

      AddFunction(@OnScriptRegExtraFieldProc, 'function ImportExtraPicture(extraIndex: Integer; filename: string): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function ImportExtraPicture2(extraIndex: Integer; filename: string; picImportMethod: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function ExportExtraPicture(extraIndex: Integer; filename: string): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function RemoveExtraPicture(extraIndex: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function CanSetExtraPicture: Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function ExtraPictureExists(extraIndex: Integer): Boolean;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureStatus(extraIndex: Integer): Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureExt(extraIndex: Integer): string;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPicturePath(extraIndex: Integer): string;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureFullPath(extraIndex: Integer): string;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureSize(extraIndex: Integer): Double;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureWidth(extraIndex: Integer): Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function GetExtraPictureHeight(extraIndex: Integer): Integer;', nil);
      AddFunction(@OnScriptRegExtraFieldProc, 'function ConvertExtraPicture(extraIndex: Integer; maxWidth: Integer; maxHeight: Integer): Boolean;', nil);


      AddFunction(@OnScriptRegStringProc, 'function UTF8Encode(Value: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function UTF8Decode(Value: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiBestFitUS(S: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiUpFirstLetter(Value: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiMixedCase(Value: string; Delimiters: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function StringReplace(S, Old, New: string): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function StringReplace2(S, Old, New: string; IgnoreCase, ReplaceAll: Boolean): string;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiCompare(S1, S2: string; IgnoreCase, IgnoreAccents: Boolean): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiNatCompareStr(S1, S2: string): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiNatCompareText(S1, S2: string): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiNatCompare(S1, S2: string; IgnoreCase, IgnoreAccents: Boolean): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiPosEx(SubStr, S: string; IgnoreCase, IgnoreAccents: Boolean): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiPosEx2(SubStr, S: string; IgnoreCase, IgnoreAccents: Boolean; StartPos: Integer): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiLastPosEx(SubStr, S: string; IgnoreCase, IgnoreAccents: Boolean): Integer;', nil);
      AddFunction(@OnScriptRegStringProc, 'function AnsiLastPosEx2(SubStr, S: string; IgnoreCase, IgnoreAccents: Boolean; StartPos: Integer): Integer;', nil);

      AddFunction(@OnScriptRegRegExprProc, 'function RegExprModifiers(Modifiers: string): Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprSet(ExprStr: string): Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprExec(ExprStr: string): Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprSetExec(ExprStr, InputStr: string): Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprExecNext: Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprExecPos(Pos: integer): Boolean;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprSubstitute(TemlateStr: string): string;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprSetSubstitute(ExprStr, InputStr, TemlateStr: string): string;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprReplace(InputStr, ReplaceStr: string; useSubstitution: boolean): string;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprSetReplace(ExprStr, InputStr, ReplaceStr: string; useSubstitution: boolean): string;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function SubExprMatchCount: Integer;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprMatch(Idx: Integer): string;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprMatchPos(Idx: Integer): Integer;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'function RegExprMatchLen(Idx: Integer): Integer;', nil);
      AddFunction(@OnScriptRegRegExprProc, 'procedure RegExprDebug(Debug: Boolean);', nil);

      AddFunction(@OnScriptRegFileProc, 'function DeleteFile(AFileName: string): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function CopyFile(ASourceFileName: string; ATargetFileName: string; SkipIfExists: Boolean): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function MoveFile(ASourceFileName: string; ATargetFileName: string): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function GetFileSize(AFileName: string): Double;', nil);

      AddFunction(@OnScriptRegFileProc, 'function DirectoryIsEmpty(ADir: string): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function ListDirectory(ADir: string; AMask: string): string;', nil);
      AddFunction(@OnScriptRegFileProc, 'function CreateFolder(ADir: string): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function DeleteFolder(ADir: string; OnlyIfEmpty: Boolean): Boolean;', nil);
      AddFunction(@OnScriptRegFileProc, 'function CopyFolder(ASourceDir: string; ATargetDir: string): Boolean;', nil);

      SetInteger(AddVariable('fieldNumber', 'Integer', True), fieldNumber);
      SetInteger(AddVariable('fNumber', 'Integer', True), fieldNumber);
      SetInteger(AddVariable('fieldChecked', 'Integer', True), fieldChecked);
      SetInteger(AddVariable('fChecked', 'Integer', True), fieldChecked);
      SetInteger(AddVariable('fieldColorTag', 'Integer', True), fieldColorTag);
      SetInteger(AddVariable('fColorTag', 'Integer', True), fieldColorTag);
      SetInteger(AddVariable('fieldMedia', 'Integer', True), fieldMedia);
      SetInteger(AddVariable('fMedia', 'Integer', True), fieldMedia);
      SetInteger(AddVariable('fieldMediaType', 'Integer', True), fieldMediaType);
      SetInteger(AddVariable('fMediaType', 'Integer', True), fieldMediaType);
      SetInteger(AddVariable('fieldSource', 'Integer', True), fieldSource);
      SetInteger(AddVariable('fSource', 'Integer', True), fieldSource);
      SetInteger(AddVariable('fieldDate', 'Integer', True), fieldDate);
      SetInteger(AddVariable('fDate', 'Integer', True), fieldDate);
      SetInteger(AddVariable('fieldBorrower', 'Integer', True), fieldBorrower);
      SetInteger(AddVariable('fBorrower', 'Integer', True), fieldBorrower);
      SetInteger(AddVariable('fieldDateWatched', 'Integer', True), fieldDateWatched);
      SetInteger(AddVariable('fDateWatched', 'Integer', True), fieldDateWatched);
      SetInteger(AddVariable('fieldUserRating', 'Integer', True), fieldUserRating);
      SetInteger(AddVariable('fUserRating', 'Integer', True), fieldUserRating);
      SetInteger(AddVariable('fieldRating', 'Integer', True), fieldRating);
      SetInteger(AddVariable('fRating', 'Integer', True), fieldRating);
      SetInteger(AddVariable('fieldOriginalTitle', 'Integer', True), fieldOriginalTitle);
      SetInteger(AddVariable('fOriginalTitle', 'Integer', True), fieldOriginalTitle);
      SetInteger(AddVariable('fieldTranslatedTitle', 'Integer', True), fieldTranslatedTitle);
      SetInteger(AddVariable('fTranslatedTitle', 'Integer', True), fieldTranslatedTitle);
      SetInteger(AddVariable('fieldFormattedTitle', 'Integer', True), fieldFormattedTitle);
      SetInteger(AddVariable('fFormattedTitle', 'Integer', True), fieldFormattedTitle);
      SetInteger(AddVariable('fieldDirector', 'Integer', True), fieldDirector);
      SetInteger(AddVariable('fDirector', 'Integer', True), fieldDirector);
      SetInteger(AddVariable('fieldProducer', 'Integer', True), fieldProducer);
      SetInteger(AddVariable('fProducer', 'Integer', True), fieldProducer);
      SetInteger(AddVariable('fieldWriter', 'Integer', True), fieldWriter);
      SetInteger(AddVariable('fWriter', 'Integer', True), fieldWriter);
      SetInteger(AddVariable('fieldComposer', 'Integer', True), fieldComposer);
      SetInteger(AddVariable('fComposer', 'Integer', True), fieldComposer);
      SetInteger(AddVariable('fieldActors', 'Integer', True), fieldActors);
      SetInteger(AddVariable('fActors', 'Integer', True), fieldActors);
      SetInteger(AddVariable('fieldCountry', 'Integer', True), fieldCountry);
      SetInteger(AddVariable('fCountry', 'Integer', True), fieldCountry);
      SetInteger(AddVariable('fieldYear', 'Integer', True), fieldYear);
      SetInteger(AddVariable('fYear', 'Integer', True), fieldYear);
      SetInteger(AddVariable('fieldLength', 'Integer', True), fieldLength);
      SetInteger(AddVariable('fLength', 'Integer', True), fieldLength);
      SetInteger(AddVariable('fieldCategory', 'Integer', True), fieldCategory);
      SetInteger(AddVariable('fCategory', 'Integer', True), fieldCategory);
      SetInteger(AddVariable('fieldCertification', 'Integer', True), fieldCertification);
      SetInteger(AddVariable('fCertification', 'Integer', True), fieldCertification);
      SetInteger(AddVariable('fieldURL', 'Integer', True), fieldURL);
      SetInteger(AddVariable('fURL', 'Integer', True), fieldURL);
      SetInteger(AddVariable('fieldDescription', 'Integer', True), fieldDescription);
      SetInteger(AddVariable('fDescription', 'Integer', True), fieldDescription);
      SetInteger(AddVariable('fieldComments', 'Integer', True), fieldComments);
      SetInteger(AddVariable('fComments', 'Integer', True), fieldComments);
      SetInteger(AddVariable('fieldFilePath', 'Integer', True), fieldFilePath);
      SetInteger(AddVariable('fFilePath', 'Integer', True), fieldFilePath);
      SetInteger(AddVariable('fieldVideoFormat', 'Integer', True), fieldVideoFormat);
      SetInteger(AddVariable('fVideoFormat', 'Integer', True), fieldVideoFormat);
      SetInteger(AddVariable('fieldVideoBitrate', 'Integer', True), fieldVideoBitrate);
      SetInteger(AddVariable('fVideoBitrate', 'Integer', True), fieldVideoBitrate);
      SetInteger(AddVariable('fieldAudioFormat', 'Integer', True), fieldAudioFormat);
      SetInteger(AddVariable('fAudioFormat', 'Integer', True), fieldAudioFormat);
      SetInteger(AddVariable('fieldAudioBitrate', 'Integer', True), fieldAudioBitrate);
      SetInteger(AddVariable('fAudioBitrate', 'Integer', True), fieldAudioBitrate);
      SetInteger(AddVariable('fieldResolution', 'Integer', True), fieldResolution);
      SetInteger(AddVariable('fResolution', 'Integer', True), fieldResolution);
      SetInteger(AddVariable('fieldFrameRate', 'Integer', True), fieldFrameRate);
      SetInteger(AddVariable('fFrameRate', 'Integer', True), fieldFrameRate);
      SetInteger(AddVariable('fieldLanguages', 'Integer', True), fieldLanguages);
      SetInteger(AddVariable('fLanguages', 'Integer', True), fieldLanguages);
      SetInteger(AddVariable('fieldSubtitles', 'Integer', True), fieldSubtitles);
      SetInteger(AddVariable('fSubtitles', 'Integer', True), fieldSubtitles);
      SetInteger(AddVariable('fieldSize', 'Integer', True), fieldSize);
      SetInteger(AddVariable('fSize', 'Integer', True), fieldSize);
      SetInteger(AddVariable('fieldDisks', 'Integer', True), fieldDisks);
      SetInteger(AddVariable('fDisks', 'Integer', True), fieldDisks);
      SetInteger(AddVariable('fieldPictureStatus', 'Integer', True), fieldPictureStatus);
      SetInteger(AddVariable('fPictureStatus', 'Integer', True), fieldPictureStatus);
      SetInteger(AddVariable('fieldNbExtras', 'Integer', True), fieldNbExtras);
      SetInteger(AddVariable('fNbExtras', 'Integer', True), fieldNbExtras);
      
      SetInteger(AddVariable('extraFieldNumber', 'Integer', True), extraFieldNumber - extraFieldLow);
      SetInteger(AddVariable('eNumber', 'Integer', True), extraFieldNumber - extraFieldLow);
      SetInteger(AddVariable('extraFieldChecked', 'Integer', True), extraFieldChecked - extraFieldLow);
      SetInteger(AddVariable('eChecked', 'Integer', True), extraFieldChecked - extraFieldLow);
      SetInteger(AddVariable('extraFieldTag', 'Integer', True), extraFieldTag - extraFieldLow);
      SetInteger(AddVariable('eTag', 'Integer', True), extraFieldTag - extraFieldLow);
      SetInteger(AddVariable('extraFieldTitle', 'Integer', True), extraFieldTitle - extraFieldLow);
      SetInteger(AddVariable('eTitle', 'Integer', True), extraFieldTitle - extraFieldLow);
      SetInteger(AddVariable('extraFieldCategory', 'Integer', True), extraFieldCategory - extraFieldLow);
      SetInteger(AddVariable('eCategory', 'Integer', True), extraFieldCategory - extraFieldLow);
      SetInteger(AddVariable('extraFieldURL', 'Integer', True), extraFieldURL - extraFieldLow);
      SetInteger(AddVariable('eURL', 'Integer', True), extraFieldURL - extraFieldLow);
      SetInteger(AddVariable('extraFieldDescription', 'Integer', True), extraFieldDescription - extraFieldLow);
      SetInteger(AddVariable('eDescription', 'Integer', True), extraFieldDescription - extraFieldLow);
      SetInteger(AddVariable('extraFieldComments', 'Integer', True), extraFieldComments - extraFieldLow);
      SetInteger(AddVariable('eComments', 'Integer', True), extraFieldComments - extraFieldLow);
      SetInteger(AddVariable('extraFieldCreatedBy', 'Integer', True), extraFieldCreatedBy - extraFieldLow);
      SetInteger(AddVariable('eCreatedBy', 'Integer', True), extraFieldCreatedBy - extraFieldLow);
      SetInteger(AddVariable('extraFieldPictureStatus', 'Integer', True), extraFieldPictureStatus - extraFieldLow);
      SetInteger(AddVariable('ePictureStatus', 'Integer', True), extraFieldPictureStatus - extraFieldLow);

      SetInteger(AddVariable('mediaPath', 'Integer', True), mediaPath);
      SetInteger(AddVariable('mediaPathName', 'Integer', True), mediaPathName);
      SetInteger(AddVariable('mediaPathNameExt', 'Integer', True), mediaPathNameExt);
      SetInteger(AddVariable('mediaName', 'Integer', True), mediaName);
      SetInteger(AddVariable('mediaNameFiltered', 'Integer', True), mediaNameFiltered);
      SetInteger(AddVariable('mediaNameExt', 'Integer', True), mediaNameExt);
      SetInteger(AddVariable('mediaFolder', 'Integer', True), mediaFolder);
      SetInteger(AddVariable('mediaFolderFiltered', 'Integer', True), mediaFolderFiltered);
      SetInteger(AddVariable('mediaExt', 'Integer', True), mediaExt);
      SetInteger(AddVariable('mediaExtWithoutDot', 'Integer', True), mediaExtWithoutDot);
      SetInteger(AddVariable('mediaVolumeLabel', 'Integer', True), mediaVolumeLabel);
      SetInteger(AddVariable('mediaSize', 'Integer', True), mediaSize);
      SetInteger(AddVariable('mediaDisks', 'Integer', True), mediaDisks);
      SetInteger(AddVariable('mediaPicture', 'Integer', True), mediaPicture);
      SetInteger(AddVariable('mediaLength', 'Integer', True), mediaLength);
      SetInteger(AddVariable('mediaResolution', 'Integer', True), mediaResolution);
      SetInteger(AddVariable('mediaResHeight', 'Integer', True), mediaResHeight);
      SetInteger(AddVariable('mediaResWidth', 'Integer', True), mediaResWidth);
      SetInteger(AddVariable('mediaFramerate', 'Integer', True), mediaFramerate);
      SetInteger(AddVariable('mediaVideoCodec', 'Integer', True), mediaVideoCodec);
      SetInteger(AddVariable('mediaVideoBitrate', 'Integer', True), mediaVideoBitrate);
      SetInteger(AddVariable('mediaAudioCodec', 'Integer', True), mediaAudioCodec);
      SetInteger(AddVariable('mediaAudioChannels', 'Integer', True), mediaAudioChannels);
      SetInteger(AddVariable('mediaAudioCodecAndChannels', 'Integer', True), mediaAudioCodecAndChannels);
      SetInteger(AddVariable('mediaAudioBitrate', 'Integer', True), mediaAudioBitrate);
      SetInteger(AddVariable('mediaLanguages', 'Integer', True), mediaLanguages);
      SetInteger(AddVariable('mediaSubtitles', 'Integer', True), mediaSubtitles);

      SetInteger(AddVariable('picStatusUndefine', 'Integer', True), Integer(mpsUndefined));
      SetInteger(AddVariable('picStatusNone', 'Integer', True), Integer(mpsNone));
      SetInteger(AddVariable('picStatusStored', 'Integer', True), Integer(mpsStored));
      SetInteger(AddVariable('picStatusCopiedInCatDir', 'Integer', True), Integer(mpsCopiedInCatDir));
      SetInteger(AddVariable('picStatusCopiedInPicDir', 'Integer', True), Integer(mpsCopiedInPicDir));
      SetInteger(AddVariable('picStatusLinkAbs', 'Integer', True), Integer(mpsLinkAbs));
      SetInteger(AddVariable('picStatusLinkRel', 'Integer', True), Integer(mpsLinkRel));

      SetInteger(AddVariable('picImportStore', 'Integer', True), Integer(mpiStore));
      SetInteger(AddVariable('picImportCopyInCatDir', 'Integer', True), Integer(mpiCopyInCatDir));
      SetInteger(AddVariable('picImportCopyInPicDir', 'Integer', True), Integer(mpiCopyInPicDir));
      SetInteger(AddVariable('picImportLinkAbs', 'Integer', True), Integer(mpiLinkAbs));
      SetInteger(AddVariable('picImportLinkRel', 'Integer', True), Integer(mpiLinkRel));

      SetString(AddVariable('dirApp', 'string', True), strDirApp);
      SetString(AddVariable('dirData', 'string', True), strDirData);
      SetString(AddVariable('dirDocs', 'string', True), strDirDocs);
      SetString(AddVariable('dirTemplates', 'string', True), strDirTemplates);
      SetString(AddVariable('dirScripts', 'string', True), strDirScripts);
      SetString(AddVariable('dirCatalogs', 'string', True), strDirCatalogs);
      if (GetScriptWin.FCurrentCatalog.CurrentFile <> '') then
        SetString(AddVariable('dirCurrentCatalog', 'string', True), ExtractFilePath(GetScriptWin.FCurrentCatalog.CurrentFile))
      else
        SetString(AddVariable('dirCurrentCatalog', 'string', True), '');
      SetString(AddVariable('fileCurrentCatalog', 'string', True), GetScriptWin.FCurrentCatalog.CurrentFile);
    end;
    Result := ENoError;
  end
  else
  begin
    SecondEngine := TIFPasScript.Create(nil);
    try
      f := TFileStream.Create(strDirScripts + Name + '.pas', fmOpenRead);
      SetLength(s, f.Size);
      f.Read(s[1], Length(S));
      f.Free;
    except
      SecondEngine.Free;
      Result := EUnitNotFound;
      Exit;
    end;
    SecondEngine.OnUses := OnScriptUses;
    SecondEngine.SetText(s);
    if SecondEngine.ErrorCode <> ENoError then
    begin
      Sender.RunError2(SecondEngine, SecondEngine.ErrorCode, SecondEngine.ErrorString);
      SecondEngine.Free;
      Result := EUnitNotFound;
    end
    else
    begin
      if not Sender.Attach(SecondEngine) then
      begin
        SecondEngine.Free;
        Result := ECustomError;
      end
      else
      begin
        Result := ENoError;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegScriptProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  resbool: Boolean;
  NewMovie: TMovie;
  opt: TScriptOption;
  prm: TScriptParameter;
begin
  result := ENoError;
  if proc^.Name = 'CHECKVERSION' then
    SetBoolean(res, CheckVersion(
        GetInteger(Vm_Get(Params, 0)),
        GetInteger(Vm_Get(Params, 1)),
        GetInteger(Vm_Get(Params, 2))))
  else
  if proc^.Name = 'ACCEPTLICENSE' then
  begin
    if GetInteger(Vm_Get(Params, 0)) > GetScriptWin.CurrentScript.Properties.LicenseAccepted then
    begin
      resbool := MessageWin.Execute(InsertLineBreaks(GetScriptWin.CurrentScript.Properties.License), mtWarning, [GetScriptWin.Messages.Strings[msgIAgree], mbCancel]) = 1;
      if resbool then
        GetScriptWin.CurrentScript.AcceptLicense(GetInteger(Vm_Get(Params, 0)));
    end
    else
      resbool := True;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'GESCRIPTFILENAME' then
  begin
    SetString(res, GetScriptWin.CurrentScript.FileName)
  end else
  if proc^.Name = 'GESCRIPTFULLPATH' then
  begin
    SetString(res, GetScriptWin.CurrentScript.FullPath)
  end else
  if proc^.Name = 'GESCRIPTAUTHORS' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Authors)
  end else
  if proc^.Name = 'GESCRIPTTITLE' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Title)
  end else
  if proc^.Name = 'GESCRIPTDESCRIPTION' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Description)
  end else
  if proc^.Name = 'GESCRIPTSITE' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Site)
  end else
  if proc^.Name = 'GESCRIPTVERSION' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Version)
  end else
  if proc^.Name = 'GESCRIPTCOMMENTS' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.Comments)
  end else
  if proc^.Name = 'GESCRIPTLICENSE' then
  begin
    SetString(res, GetScriptWin.CurrentScript.Properties.License)
  end else
  if proc^.Name = 'GETOPTION' then
  begin
    opt := GetScriptWin.CurrentScript.Options.Find(GetString(VM_Get(Params, 0)));
    if opt <> nil then
      SetInteger(res, opt.Value)
    else
      SetInteger(res, -1);
  end else
  if proc^.Name = 'SETOPTION' then
  begin
    opt := GetScriptWin.CurrentScript.Options.Find(GetString(VM_Get(Params, 0)));
    if (opt <> nil) and (GetInteger(VM_Get(Params, 1)) >= 0) and
      (GetInteger(VM_Get(Params, 1)) < Length(opt.Values)) then
         opt.Value := GetInteger(VM_Get(Params, 1));
  end else
  if proc^.Name = 'GETPARAM' then
  begin
    prm := GetScriptWin.CurrentScript.Parameters.Find(GetString(VM_Get(Params, 0)));
    if prm <> nil then
      SetString(res, prm.Value)
    else
      SetString(res, '');
  end else
  if proc^.Name = 'SETPARAM' then
  begin
    prm := GetScriptWin.CurrentScript.Parameters.Find(GetString(VM_Get(Params, 0)));
    if prm <> nil then
      prm.Value := GetString(Vm_Get(Params, 1));
  end else
  if proc^.Name = 'SETSTATIC' then
    GetScriptWin.CurrentScript.Static.Values[GetString(Vm_Get(Params, 0))] := GetString(Vm_Get(Params, 1))
  else
  if proc^.Name = 'GETSTATIC' then
    SetString(res, GetScriptWin.CurrentScript.Static.Values[GetString(Vm_Get(Params, 0))])
  else
  if proc^.Name = 'GETITERATION' then
    SetInteger(res, GetScriptWin.FIteration)
  else
  if proc^.Name = 'GETITERATIONCOUNT' then
    SetInteger(res, GetScriptWin.FMovieListFiltered.Count)
  else
  if proc^.Name = 'ADDNEWMOVIETOQUEUE' then
  begin
    NewMovie := GetScriptWin.MovieList.Add;
    NewMovie.bChecked := True;
    NewMovie._bSelected := True;
    NewMovie.Assign(Settings.rOptions.rMovieInformation.rDefaultMovie.Values, False, False, False, False, True);
    if Settings.rOptions.rMovieInformation.SetCurrentDate then
      NewMovie.iDate := Trunc(Date);
    NewMovie.CustomFields.SetDefaultValues;
    if GetScriptWin.MaxNum < MaxInt then
    begin
      GetScriptWin.MaxNum := GetScriptWin.MaxNum + 1;
      NewMovie.iNumber := GetScriptWin.MaxNum;
    end else
      NewMovie.iNumber := GetScriptWin.MovieList.FirstFreeNumber;
    if Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath <> '' then
      try   
        NewMovie.Picture.ImportPicture(Settings.rOptions.rMovieInformation.rDefaultMovie.Values.Picture.PicPath,
          GetScriptWin.FCurrentCatalog.CurrentFile, TMoviePictureImport(Abs(Settings.rOptions.rMovieInformation.rPicImport.GetInfoMethod)));
      except
      end;
    GetScriptWin.FMovieListFiltered.Add(NewMovie);
    GetScriptWin.FCurrentCatalog.Modified := True;
    SetInteger(res, NewMovie.iNumber);
  end
  else
  if proc^.Name = 'SLEEP' then
  begin
    SetWaitCursor;
    try
      Sleep(GetInteger(Vm_Get(Params, 0)))
    finally
      RestoreCursor;
    end;
  end else
  if proc^.Name = 'LAUNCH' then
  begin
    if GetString(Vm_Get(Params, 1)) = '' then
      LaunchProg(GetString(Vm_Get(Params, 0)), strDirApp)
    else
      LaunchProg(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), strDirApp);
  end else
  if proc^.Name = 'ERROR' then
    result := ECustomError;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegMsgProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  value: string;
  resint: Integer;
  resbool: Boolean;
begin
  result := ENoError;
  if proc^.Name = 'SHOWMESSAGE' then
  begin
    resint := MessageWin.Execute(GetString(Vm_Get(Params, 0)), '', [mbOk, mbAbort]);
    if resint = 2 then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end
  else
  if proc^.Name = 'SHOWERROR' then
  begin
    resint := MessageWin.Execute(GetString(Vm_Get(Params, 0)), mtError, [mbOk, mbAbort]);
    if resint = 2 then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end
  else
  if proc^.Name = 'SHOWINFORMATION' then
  begin
    resint := MessageWin.Execute(GetString(Vm_Get(Params, 0)), mtInformation, [mbOk, mbAbort]);
    if resint = 2 then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end
  else
  if proc^.Name = 'SHOWWARNING' then
  begin
    resint := MessageWin.Execute(GetString(Vm_Get(Params, 0)), mtWarning, [mbOk, mbCancel, mbAbort]);
    if resint = 3 then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
    SetBoolean(res, resint = 1)
  end
  else
  if proc^.Name = 'SHOWCONFIRMATION' then
  begin
    resint := MessageWin.Execute(GetString(Vm_Get(Params, 0)), mtConfirmation, [mbYes, mbNo, mbAbort]);
    if resint = 3 then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
    SetBoolean(res, resint = 1)
  end
  else
  if proc^.Name = 'SHOWMEMO' then
  begin
    value := GetString(Vm_Get(Params, 0));
    resbool := GetScriptWin.MemoMsgWin.Execute('', value);
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end
  else
  if proc^.Name = 'INPUT' then
  begin
    value := GetString(Vm_Get(Params, 2));
    resbool := InputWin.Execute(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), value);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 2))^.Cv_Str := value;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegPickProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  value: string;
  resbool: Boolean;
  idx: Integer;
begin
  result := ENoError;
  if proc^.Name = 'PICKTREETITLE' then
    PickTreeWin.SetTitle(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'PICKTREEDEFAULTTITLE' then
    PickTreeWin.SetDefaultTitle
  else
  if proc^.Name = 'PICKTREECLEAR' then
    PickTreeWin.Clear
  else
  if proc^.Name = 'PICKTREEADD' then
    PickTreeWin.Add(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)))
  else
  if proc^.Name = 'PICKTREECOUNT' then
    SetInteger(res, PickTreeWin.Count)
  else
  if proc^.Name = 'PICKTREECOUNTADDRESSES' then
    SetInteger(res, PickTreeWin.CountAddresses)
  else
  if proc^.Name = 'PICKTREEMORELINK' then
    PickTreeWin.SetMoreLink(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'PICKTREESORT' then
    PickTreeWin.Sort
  else
  if proc^.Name = 'PICKTREEEXEC' then
  begin
    resbool := PickTreeWin.Execute('', value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 0))^.CV_Str := value;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end else
  if proc^.Name = 'PICKTREEEXEC2' then
  begin
    resbool := PickTreeWin.Execute('', value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 0))^.CV_Str := value;
    GetVarLink(Vm_Get(Params, 1))^.CV_SInt32 := idx;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end else
  if proc^.Name = 'PICKTREEEXEC3' then
  begin
    resbool := PickTreeWin.Execute(GetString(Vm_Get(Params, 0)), value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 1))^.CV_Str := value;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end else
  if proc^.Name = 'PICKTREEEXEC4' then
  begin
    resbool := PickTreeWin.Execute(GetString(Vm_Get(Params, 0)), value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 1))^.CV_Str := value;
    GetVarLink(Vm_Get(Params, 2))^.CV_SInt32 := idx;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end else

  if proc^.Name = 'PICKLISTTITLE' then
    PickListWin.SetTitle(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'PICKLISTDEFAULTTITLE' then
    PickListWin.SetDefaultTitle
  else
  if proc^.Name = 'PICKLISTCLEAR' then
    PickListWin.Clear
  else
  if proc^.Name = 'PICKLISTADD' then
    PickListWin.Add(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'PICKLISTCOUNT' then
    SetInteger(res, PickListWin.Count)
  else
  if proc^.Name = 'PICKLISTEXEC' then
  begin
    resbool := PickListWin.Execute(GetString(Vm_Get(Params, 0)), value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 1))^.CV_Str := value;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end
  else
  if proc^.Name = 'PICKLISTEXEC2' then
  begin
    resbool := PickListWin.Execute(GetString(Vm_Get(Params, 0)), value, idx);
    SetBoolean(res, resbool);
    GetVarLink(Vm_Get(Params, 1))^.CV_Str := value;
    GetVarLink(Vm_Get(Params, 2))^.CV_SInt32 := idx;
    if not resbool then
      if MessageWin.Execute(GetScriptWin.Messages.Strings[msgAbortBatch], mtConfirmation, [mbYes, mbNo]) = 1 then
        GetScriptWin.ActionDebugStop.Execute;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegMediaProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  i: Integer;
begin
  result := ENoError;
  with GetScriptWin do
  if proc^.Name = 'LOADMEDIA' then
  begin
    FMedia.InitValues();
    with Settings.rOptions.rMovieInformation do
      SetBoolean(res, GetInfoFromMedia(GetString(Vm_Get(Params, 0)),
        FMedia, ImportInternalAVI, ImportSizeUnit));
  end
  else
  if proc^.Name = 'GETMEDIAINFO' then
  begin
    i := GetInteger(Vm_Get(Params, 0));
    if (i >= 0) and (i < mediaCount) then
      if i <> mediaFramerate then
        SetString(res, FMedia.Value[i])
      else
        SetString(res, CharReplace(FMedia.Value[i], DecimalSeparator, FormatSettings.DecimalSeparator))
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETMEDIAINFOLS' then
  begin
    i := GetInteger(Vm_Get(Params, 0));
    if (i >= 0) and (i < mediaCount) then
      SetString(res, FMedia.Value[i])
    else
      SetString(res, '');
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegCookieProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  result := ENoError;
  {
  if proc^.Name = 'GETCOOKIES' then
    SetString(res, GetCookies(GetString(Vm_Get(Params, 0)), true))
  else
  if proc^.Name = 'GETCOOKIESWITHPROPERTIES' then
    SetString(res, GetCookiesWithProperties(GetString(Vm_Get(Params, 0)), true))
  else
  }
  if proc^.Name = 'SETCOOKIES' then
    SetCookies(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)))
  else
  if proc^.Name = 'ADDCOOKIE' then
    AddCookie(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)))
  {
  else
  if proc^.Name = 'DELETECOOKIES' then
    DeleteCookies(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'DELETEALLCOOKIES' then
    DeleteAllCookies();
  }
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegHtmlProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
begin
  result := ENoError;
  if proc^.Name = 'GETPAGE' then
    SetString(res, GetPage(GetString(Vm_Get(Params, 0)), '', '', '*/*', ''))
  else
  if proc^.Name = 'GETPAGE2' then
    SetString(res, GetPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), '', '*/*', ''))
  else
  if proc^.Name = 'GETPAGE3' then
    SetString(res, GetPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), '*/*', ''))
  else
  if proc^.Name = 'GETPAGE4' then
    SetString(res, GetPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), GetString(Vm_Get(Params, 3)), ''))
  else
  if proc^.Name = 'GETPAGE5' then
    SetString(res, GetPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), GetString(Vm_Get(Params, 3)), GetString(Vm_Get(Params, 4))))
  else
  if proc^.Name = 'POSTPAGE' then
    SetString(res, PostPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), 'application/x-www-form-urlencoded', '', False, False, ''))
  else
  if proc^.Name = 'POSTPAGE2' then
    SetString(res, PostPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), GetString(Vm_Get(Params, 3)), GetBoolean(Vm_Get(Params, 4)), GetBoolean(Vm_Get(Params, 5)), ''))
  else
  if proc^.Name = 'POSTPAGE3' then
    SetString(res, PostPage(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), GetString(Vm_Get(Params, 3)), GetBoolean(Vm_Get(Params, 4)), GetBoolean(Vm_Get(Params, 5)), GetString(Vm_Get(Params, 6))))
  else
  if proc^.Name = 'HTMLDECODE' then
    GetVarLink(Vm_Get(Params, 0))^.CV_Str := HTMLDecode(GetString(VM_Get(Params, 0)))
  else
  if proc^.Name = 'HTMLREMOVETAGS' then
    GetVarLink(Vm_Get(Params, 0))^.CV_Str := HTMLRemoveTags(GetString(VM_Get(Params, 0)))
  else
  if proc^.Name = 'URLENCODE' then
    SetString(res, TIdURI.ParamsEncode(GetString(VM_Get(Params, 0))))
  else
  if proc^.Name = 'URLDECODE' then
    SetString(res, TIdURI.URLDecode(GetString(VM_Get(Params, 0))))
  else
  if proc^.Name = 'GETPICTURE' then
    SetBoolean(res, GetPicture(-MaxInt, GetString(VM_Get(Params, 0)), '', '*/*'))
  else
  if proc^.Name = 'GETPICTURE2' then
    SetBoolean(res, GetPicture(-MaxInt, GetString(VM_Get(Params, 0)), GetString(VM_Get(Params, 1)), '*/*'))
  else
  if proc^.Name = 'GETPICTURE3' then
    SetBoolean(res, GetPicture(-MaxInt, GetString(VM_Get(Params, 0)), GetString(VM_Get(Params, 1)), GetString(VM_Get(Params, 2))))
  else
  if proc^.Name = 'GETEXTRAPICTURE' then
    SetBoolean(res, GetPicture(GetInteger(Vm_Get(Params, 0)), GetString(VM_Get(Params, 1)), '', '*/*'))
  else
  if proc^.Name = 'GETEXTRAPICTURE2' then
    SetBoolean(res, GetPicture(GetInteger(Vm_Get(Params, 0)), GetString(VM_Get(Params, 1)), GetString(VM_Get(Params, 2)), '*/*'))
  else
  if proc^.Name = 'RAISECONNECTIONERRORS' then
    GetScriptWin.FRaiseConnectionErrors := GetBoolean(Vm_Get(Params, 0));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegFieldProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  fieldProperties: TCustomFieldProperties;
  idx: Integer;
  d: Double;
begin
  result := ENoError;
  if proc^.Name = 'ISSELECTED' then
    SetBoolean(res, ScriptResultsWin.IsSelected)
  else if proc^.Name = 'SETSELECTED' then
    ScriptResultsWin.SetSelected(GetBoolean(VM_Get(Params, 0)))
  else

  if proc^.Name = 'SETFIELD' then
    ScriptResultsWin.SetField(GetInteger(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)))
  else
  if proc^.Name = 'GETFIELD' then
    SetString(res, ScriptResultsWin.GetField(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETFIELDLS' then
    SetString(res, ScriptResultsWin.GetFieldLS(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'CANSETFIELD' then
    SetBoolean(res, ScriptResultsWin.CanSetField(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETFIELDNAME' then
  begin
    idx := GetInteger(Vm_Get(Params, 0));
    if (idx >= fieldLow) and (idx < fieldCount) then
      SetString(res, strFields[idx])
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETFIELDTYPE' then
  begin
    idx := GetInteger(Vm_Get(Params, 0));
    if (idx >= fieldLow) and (idx < fieldCount) then
      SetString(res, ConvertFieldTypeToString(GetFieldType(idx)))
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETFIELDTAG' then
  begin
    idx := GetInteger(Vm_Get(Params, 0));
    if (idx >= fieldLow) and (idx < fieldCount) then
      SetString(res, strTagFields[idx])
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETFIELDCOUNT' then
    SetInteger(res, fieldCount)
  else

  if proc^.Name = 'SETCUSTOMFIELD' then
    ScriptResultsWin.SetCustomField(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)))
  else
  if proc^.Name = 'GETCUSTOMFIELD' then
    SetString(res, ScriptResultsWin.GetCustomField(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETCUSTOMFIELDLS' then
    SetString(res, ScriptResultsWin.GetCustomFieldLS(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'CANSETCUSTOMFIELD' then
  begin
    SetBoolean(res, ScriptResultsWin.CanSetCustomField(GetString(Vm_Get(Params, 0))))
  end else
  if proc^.Name = 'CUSTOMFIELDEXISTS' then
  begin
    fieldProperties := GetScriptWin.MovieList.CustomFieldsProperties.GetField(GetString(Vm_Get(Params, 0)));
    SetBoolean(res, (fieldProperties <> nil))
  end else
  if proc^.Name = 'GETCUSTOMFIELDNAME' then
  begin
    fieldProperties := GetScriptWin.MovieList.CustomFieldsProperties.GetField(GetString(Vm_Get(Params, 0)));
    if fieldProperties <> nil then
      SetString(res, fieldProperties.FieldName)
    else
      SetString(res, '');
  end else
  if proc^.Name = 'GETCUSTOMFIELDTYPE' then
  begin
    fieldProperties := GetScriptWin.MovieList.CustomFieldsProperties.GetField(GetString(Vm_Get(Params, 0)));
    if fieldProperties <> nil then
      SetString(res, ConvertFieldTypeToString(fieldProperties.FieldType))
    else
      SetString(res, '');
  end else
  if proc^.Name = 'GETCUSTOMFIELDTAG' then
  begin
    idx := GetInteger(Vm_Get(Params, 0));
    if (idx >= 0) and (idx < GetScriptWin.MovieList.CustomFieldsProperties.Count) then
      SetString(res, GetScriptWin.MovieList.CustomFieldsProperties.Strings[idx])
    else
      SetString(res, '');
  end else
  if proc^.Name = 'GETCUSTOMFIELDCOUNT' then
    SetInteger(res, GetScriptWin.MovieList.CustomFieldsProperties.Count)
  else


  if proc^.Name = 'IMPORTPICTURE' then
    SetBoolean(res, ScriptResultsWin.ImportPicture(GetString(VM_Get(Params, 0))))
  else
  if proc^.Name = 'IMPORTPICTURE2' then
    try
      SetBoolean(res, ScriptResultsWin.ImportPicture(GetString(VM_Get(Params, 0)), TMoviePictureImport(GetInteger(VM_Get(Params, 1)))));
    except
      SetBoolean(res, False);
    end
  else
  if proc^.Name = 'EXPORTPICTURE' then
    SetBoolean(res, ScriptResultsWin.ExportPicture(GetString(VM_Get(Params, 0))))
  else
  if proc^.Name = 'REMOVEPICTURE' then
    SetBoolean(res, ScriptResultsWin.RemovePicture)
  else
  if proc^.Name = 'CANSETPICTURE' then
    SetBoolean(res, GetScriptWin.CurrentScript.Fields.Picture)
  else
  if proc^.Name = 'PICTUREEXISTS' then
    SetBoolean(res, ScriptResultsWin.PictureExists)
  else
  if proc^.Name = 'GETPICTURESTATUS' then
    SetInteger(res, Integer(ScriptResultsWin.GetPictureStatus))
  else
  if (proc^.Name = 'GETPICTUREEXT') or (proc^.Name = 'PICTUREEXT') then
    SetString(res, ScriptResultsWin.GetPictureExt)
  else
  if (proc^.Name = 'GETPICTUREPATH') or (proc^.Name = 'PICTUREPATH') then
    SetString(res, ScriptResultsWin.GetPicturePath)
  else
  if (proc^.Name = 'GETPICTUREFULLPATH') or (proc^.Name = 'PICTUREFULLPATH') then
    SetString(res, ScriptResultsWin.GetPictureFullPath)
  else
  if proc^.Name = 'GETPICTURESIZE' then
  begin
    d := ScriptResultsWin.GetPictureSize;
    SetReal(res, d);
  end
  else
  if proc^.Name = 'GETPICTUREWIDTH' then
    SetInteger(res, ScriptResultsWin.GetPictureWidth)
  else
  if proc^.Name = 'GETPICTUREHEIGHT' then
    SetInteger(res, ScriptResultsWin.GetPictureHeight)
  else
  if proc^.Name = 'CONVERTPICTURE' then
    SetBoolean(res, ScriptResultsWin.ConvertPicture(GetInteger(Vm_Get(Params, 0)), GetInteger(Vm_Get(Params, 1))));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegExtraFieldProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  idx: Integer;
  d: Double;
begin
  result := ENoError;
  
  if proc^.Name = 'GETEXTRACOUNT' then
    SetInteger(res, ScriptResultsWin.GetExtraCount)
  else
  if proc^.Name = 'FINDEXTRA' then
    SetInteger(res, ScriptResultsWin.FindExtra(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'ADDEXTRA' then
  begin
    idx := ScriptResultsWin.AddExtra;
    ScriptResultsWin.SetExtraField(idx, extraFieldCreatedBy, GetScriptWin.CurrentScript.Properties.Title);
    SetInteger(res, idx)
  end
  else
  if proc^.Name = 'CANADDEXTRAS' then
    SetBoolean(res, ScriptResultsWin.CanAddExtras)
  else
  if proc^.Name = 'DELETEEXTRA' then
    SetBoolean(res, ScriptResultsWin.DeleteExtra(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'DELETEEXTRACREATEDBY' then
    SetBoolean(res, ScriptResultsWin.DeleteExtraCreatedBy(GetInteger(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1))))
  else
  if proc^.Name = 'DELETEEXTRAOFSCRIPT' then
    SetBoolean(res, ScriptResultsWin.DeleteExtraCreatedBy(GetInteger(Vm_Get(Params, 0)), GetScriptWin.CurrentScript.Properties.Title))
  else
  if proc^.Name = 'CLEAREXTRAS' then
    ScriptResultsWin.ClearExtras
  else
  if proc^.Name = 'CLEAREXTRASCREATEDBY' then
    ScriptResultsWin.ClearExtrasCreatedBy(GetString(Vm_Get(Params, 0)))
  else
  if proc^.Name = 'CLEAREXTRASOFSCRIPT' then
    ScriptResultsWin.ClearExtrasCreatedBy(GetScriptWin.CurrentScript.Properties.Title)
  else
  if proc^.Name = 'CANDELETEEXTRAS' then
    SetBoolean(res, ScriptResultsWin.CanDeleteExtras)
  else

  if proc^.Name = 'ISEXTRASELECTED' then
    SetBoolean(res, ScriptResultsWin.IsExtraSelected(GetInteger(Vm_Get(Params, 0))))
  else if proc^.Name = 'SETEXTRASELECTED' then
    ScriptResultsWin.SetExtraSelected(GetInteger(Vm_Get(Params, 0)), GetBoolean(VM_Get(Params, 1)))
  else

  if proc^.Name = 'SETEXTRAFIELD' then
    ScriptResultsWin.SetExtraField(GetInteger(Vm_Get(Params, 0)), GetInteger(Vm_Get(Params, 1)) + extraFieldLow, GetString(Vm_Get(Params, 2)))
  else
  if proc^.Name = 'GETEXTRAFIELD' then
    SetString(res, ScriptResultsWin.GetExtraField(GetInteger(Vm_Get(Params, 0)), GetInteger(Vm_Get(Params, 1)) + extraFieldLow))
  else
  if proc^.Name = 'CANMODIFYEXTRAS' then
    SetBoolean(res, ScriptResultsWin.CanModifyExtras)
  else
  if proc^.Name = 'CANSETEXTRAFIELD' then
    SetBoolean(res, ScriptResultsWin.CanSetExtraField(GetInteger(Vm_Get(Params, 0)) + extraFieldLow))
  else
  if proc^.Name = 'GETEXTRAFIELDNAME' then
  begin
    idx := GetInteger(Vm_Get(Params, 0)) + extraFieldLow;
    if (idx >= extraFieldLow) and (idx < extraFieldCount) then
      SetString(res, strExtraFields[idx - extraFieldLow])
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETEXTRAFIELDTYPE' then
  begin
    idx := GetInteger(Vm_Get(Params, 0)) + extraFieldLow;
    if (idx >= extraFieldLow) and (idx < extraFieldCount) then
      SetString(res, ConvertFieldTypeToString(GetFieldType(idx)))
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETEXTRAFIELDTAG' then
  begin
    idx := GetInteger(Vm_Get(Params, 0)) + extraFieldLow;
    if (idx >= extraFieldLow) and (idx < extraFieldCount) then
      SetString(res, strTagExtraFields[idx])
    else
      SetString(res, '');
  end
  else
  if proc^.Name = 'GETEXTRAFIELDCOUNT' then
    SetInteger(res, extraFieldCount - extraFieldLow)
  else

  if proc^.Name = 'IMPORTEXTRAPICTURE' then
    SetBoolean(res, ScriptResultsWin.ImportExtraPicture(GetInteger(Vm_Get(Params, 0)), GetString(VM_Get(Params, 1))))
  else
  if proc^.Name = 'IMPORTEXTRAPICTURE2' then
    try
      SetBoolean(res, ScriptResultsWin.ImportExtraPicture(GetInteger(Vm_Get(Params, 0)), GetString(VM_Get(Params, 1)), TMoviePictureImport(GetInteger(VM_Get(Params, 2)))));
    except
      SetBoolean(res, False);
    end
  else
  if proc^.Name = 'EXPORTEXTRAPICTURE' then
    SetBoolean(res, ScriptResultsWin.ExportExtraPicture(GetInteger(Vm_Get(Params, 0)), GetString(VM_Get(Params, 1))))
  else
  if proc^.Name = 'REMOVEEXTRAPICTURE' then
    SetBoolean(res, ScriptResultsWin.RemoveExtraPicture(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'CANSETEXTRAPICTURE' then
    SetBoolean(res, ScriptResultsWin.CanSetExtraPicture)
  else
  if proc^.Name = 'EXTRAPICTUREEXISTS' then
    SetBoolean(res, ScriptResultsWin.ExtraPictureExists(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETEXTRAPICTURESTATUS' then
    SetInteger(res, Integer(ScriptResultsWin.GetExtraPictureStatus(GetInteger(Vm_Get(Params, 0)))))
  else
  if proc^.Name = 'GETEXTRAPICTUREEXT' then
    SetString(res, ScriptResultsWin.GetExtraPictureExt(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETEXTRAPICTUREPATH' then
    SetString(res, ScriptResultsWin.GetExtraPicturePath(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETEXTRAPICTUREFULLPATH' then
    SetString(res, ScriptResultsWin.GetExtraPictureFullPath(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETEXTRAPICTURESIZE' then
  begin
    d := ScriptResultsWin.GetExtraPictureSize(GetInteger(Vm_Get(Params, 0)));
    SetReal(res, d);
  end
  else
  if proc^.Name = 'GETEXTRAPICTUREWIDTH' then
    SetInteger(res, ScriptResultsWin.GetExtraPictureWidth(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'GETEXTRAPICTUREHEIGHT' then
    SetInteger(res, ScriptResultsWin.GetExtraPictureHeight(GetInteger(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'CONVERTEXTRAPICTURE' then
    SetBoolean(res, ScriptResultsWin.ConvertExtraPicture(GetInteger(Vm_Get(Params, 0)), GetInteger(Vm_Get(Params, 1)), GetInteger(Vm_Get(Params, 2))));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegStringProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  value: string;
  value2: string;
  i: Integer;
begin
  result := ENoError;
  if proc^.Name = 'UTF8DECODE' then
    SetString(res, UTF8Decode(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'UTF8ENCODE' then
    SetString(res, UTF8Encode(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'ANSIBESTFITUS' then
    SetString(res, AnsiBestFitUS(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'ANSIUPFIRSTLETTER' then
  begin
    Value := GetString(Vm_Get(Params, 0));
    if Value <> '' then
      Value[1] := AnsiUpperCase(Copy(Value, 1, 1))[1];
    SetString(res, Value);
  end else
  if proc^.Name = 'ANSIMIXEDCASE' then
  begin
    Value := GetString(Vm_Get(Params, 0));
    Value2 := GetString(Vm_Get(Params, 1));
    for i := 1  to Length(Value) do
      if (i = 1) or (Pos(Copy(Value, i-1, 1), Value2) > 0) then
        Value[i] := AnsiUpperCase(Copy(Value, i, 1))[1];
    SetString(res, Value);
  end else
  if proc^.Name = 'STRINGREPLACE' then
    SetString(res, StringReplace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), [rfReplaceAll]))
  else
  if proc^.Name = 'STRINGREPLACE2' then
    if GetBoolean(Vm_Get(Params, 3)) then // ignoreCase
      if GetBoolean(Vm_Get(Params, 4)) then // replaceAll
        SetString(res, StringReplace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), [rfReplaceAll, rfIgnoreCase]))
      else
        SetString(res, StringReplace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), [rfIgnoreCase]))
    else
      if GetBoolean(Vm_Get(Params, 4)) then
        SetString(res, StringReplace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), [rfReplaceAll]))
      else
        SetString(res, StringReplace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), []))
  else
  if proc^.Name = 'ANSICOMPARE' then
    SetInteger(res, AnsiCompareEx(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3))))
  else
  if proc^.Name = 'ANSINATCOMPARESTR' then
    SetInteger(res, AnsiNatCompareStr(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1))))
  else
  if proc^.Name = 'ANSINATCOMPARETEXT' then
    SetInteger(res, AnsiNatCompareText(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1))))
  else
  if proc^.Name = 'ANSINATCOMPARE' then
    SetInteger(res, AnsiNatCompare(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3))))
  else
  if proc^.Name = 'ANSIPOSEX' then
    SetInteger(res, AnsiPosEx(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3))))
  else
  if proc^.Name = 'ANSIPOSEX2' then
    SetInteger(res, AnsiPosEx(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3)), GetInteger(Vm_Get(Params, 4))))
  else
  if proc^.Name = 'ANSILASTPOSEX' then
    SetInteger(res, AnsiLastPosEx(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3))))
  else
  if proc^.Name = 'ANSILASTPOSEX2' then
    SetInteger(res, AnsiLastPosEx(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)),
      GetBoolean(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3)), GetInteger(Vm_Get(Params, 4))));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegRegExprProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  resbool: Boolean;
  resint: Integer;
  resstr: string;
begin
  result := ENoError;
  resbool := False;
  resint := -1;
  resstr := '';

  with GetScriptWin do
  if proc^.Name = 'REGEXPRMODIFIERS' then
  begin
    try
      FRegExpr.ModifierStr := GetString(Vm_Get(Params, 0));
      resbool := True;
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPRSET' then
  begin
    try
      FRegExpr.Expression := GetString(Vm_Get(Params, 0));
      resbool := True;
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPREXEC' then
  begin
    try
      resbool := FRegExpr.Exec(GetString(Vm_Get(Params, 0)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPRSETEXEC' then
  begin
    try
      FRegExpr.Expression := GetString(Vm_Get(Params, 0));
      resbool := FRegExpr.Exec(GetString(Vm_Get(Params, 1)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPREXECNEXT' then
  begin
    try
      resbool := FRegExpr.ExecNext;
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPREXECPOS' then
  begin
    try
      resbool := FRegExpr.Exec(GetInteger(Vm_Get(Params, 0)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetBoolean(res, resbool);
  end else
  if proc^.Name = 'REGEXPRSUBSTITUTE' then
  begin
    try
      resstr := FRegExpr.Substitute(GetString(Vm_Get(Params, 0)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetString(res, resstr);
  end else
  if proc^.Name = 'REGEXPRSETSUBSTITUTE' then
  begin
    try
      FRegExpr.Expression := GetString(Vm_Get(Params, 0));
      resbool := FRegExpr.Exec(GetString(Vm_Get(Params, 1)));
      if resbool then
        resstr := FRegExpr.Substitute(GetString(Vm_Get(Params, 2)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetString(res, resstr);
  end else
  if proc^.Name = 'REGEXPRREPLACE' then
  begin
    try
      resstr := FRegExpr.Replace(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1)), GetBoolean(Vm_Get(Params, 2)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetString(res, resstr);
  end else
  if proc^.Name = 'REGEXPRSETREPLACE' then
  begin
    try
      FRegExpr.Expression := GetString(Vm_Get(Params, 0));
      resstr := FRegExpr.Replace(GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2)), GetBoolean(Vm_Get(Params, 3)));
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetString(res, resstr);
  end else
  if proc^.Name = 'SUBEXPRMATCHCOUNT' then
  begin
    try
      resint := FRegExpr.SubExprMatchCount;
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetInteger(res, resint);
  end else
  if proc^.Name = 'REGEXPRMATCH' then
  begin
    try
      //if GetInteger(Vm_Get(Params, 0)) < FRegExpr.SubExprMatchCount then
        resstr := FRegExpr.Match[GetInteger(Vm_Get(Params, 0))];
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetString(res, resstr);
  end else
  if proc^.Name = 'REGEXPRMATCHPOS' then
  begin
    try
      //if GetInteger(Vm_Get(Params, 0)) < FRegExpr.SubExprMatchCount then
        resint := FRegExpr.MatchPos[GetInteger(Vm_Get(Params, 0))];
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetInteger(res, resint);
  end else
  if proc^.Name = 'REGEXPRMATCHLEN' then
  begin
    try
      //if GetInteger(Vm_Get(Params, 0)) < FRegExpr.SubExprMatchCount then
        resint := FRegExpr.MatchLen[GetInteger(Vm_Get(Params, 0))];
    except on E : Exception do
      if FRegExprDebug then
        MessageWin.Execute(E.Message, mtError, [mbOk])
    end;
    SetInteger(res, resint);
  end else
  if proc^.Name = 'REGEXPRDEBUG' then
    FRegExprDebug := GetBoolean(Vm_Get(Params, 0));

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function OnScriptRegFileProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  value: string;
  d: Double;
begin
  result := ENoError;
  if proc^.Name = 'DELETEFILE' then
    SetBoolean(res, DeleteFile(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'COPYFILE' then
    SetBoolean(res, CopyFile(PChar(GetString(Vm_Get(Params, 0))), PChar(GetString(Vm_Get(Params, 1))), GetBoolean(Vm_Get(Params, 2))))
  else
  if proc^.Name = 'MOVEFILE' then
    SetBoolean(res, MoveFile(PChar(GetString(Vm_Get(Params, 0))), PChar(GetString(Vm_Get(Params, 1)))))
  else
  if proc^.Name = 'GETFILESIZE' then
  begin
    d := GetFileSize(PChar(GetString(Vm_Get(Params, 0))));
    SetReal(res, d);
  end
  else
  if proc^.Name = 'DIRECTORYISEMPTY' then
    SetBoolean(res, DirectoryIsEmpty(GetString(Vm_Get(Params, 0))))
  else
  if proc^.Name = 'LISTDIRECTORY' then
    SetString(res, ListDirectory(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1))))
  else
  if proc^.Name = 'CREATEFOLDER' then
  begin
    value := GetString(Vm_Get(Params, 0));
    if not DirectoryExists(ExpandFileName(value)) then
      SetBoolean(res, CreateDir(value))
    else
      SetBoolean(res, False);
  end
  else
  if proc^.Name = 'DELETEFOLDER' then
    SetBoolean(res, DeleteFolder(GetString(Vm_Get(Params, 0)), GetBoolean(Vm_Get(Params, 1))))
  else
  if proc^.Name = 'COPYFOLDER' then
    SetBoolean(res, CopyFolder(GetString(Vm_Get(Params, 0)), GetString(Vm_Get(Params, 1))));
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}
(*
function OnScriptRegXmlProc(Sender: TIfPasScript; ScriptID: Pointer; proc: PProcedure; Params: PVariableManager; res: PIfVariant): TIfPasScriptError;
var
  xml: TJvSimpleXml;
  Found: TJvSimpleXmlElem;
begin
  Result := ENoError;
  xml := GetScriptWin.DebugPlugin.XmlParser;
  SetString(Sender.GetVariable('XmlLastError'), '');
  if proc^.Name = 'XMLLOADFROMSTRING' then
    try
      xml.LoadFromString(GetString(Vm_Get(Params, 0)));
      SetBoolean(res, True);
    except
      on e: Exception do
      begin
        SetString(Sender.GetVariable('XmlLastError'), e.Message);
        SetBoolean(res, False);
      end;
    end
  else
  if proc^.Name = 'XMLLOADFROMFILE' then
    try
      xml.LoadFromFile(GetString(Vm_Get(Params, 0)));
      SetBoolean(res, True);
    except
      on e: Exception do
      begin
        SetString(Sender.GetVariable('XmlLastError'), e.Message);
        SetBoolean(res, False);
      end;
    end
  else
  if proc^.Name = 'XMLSAVETOSTRING' then
    SetString(res, xml.SaveToString)
  else
  if proc^.Name = 'XMLSAVETOFILE' then
    try
      xml.LoadFromFile(GetString(Vm_Get(Params, 0)));
      SetBoolean(res, True);
    except
      on e: Exception do
      begin
        SetString(Sender.GetVariable('XmlLastError'), e.Message);
        SetBoolean(res, False);
      end;
    end
  else
  if proc^.Name = 'XMLCLEAR' then
  begin
    xml.Root.Clear;
    xml.Root.Name := 'New';
    xml.Prolog.Clear;
  end
  else
  if proc^.Name = 'XMLITEMEXISTS' then
    SetBoolean(res, functions_xml.FindItem(xml, GetString(Vm_Get(Params, 0))) <> nil)
  else
  if proc^.Name = 'XMLITEMVALUE' then
  begin
    Found := functions_xml.FindItem(xml, GetString(Vm_Get(Params, 0)));
    if Found <> nil then
      SetString(res, Found.Value)
    else
      SetString(res, GetString(Vm_Get(Params, 1)));
  end
  else
  if proc^.Name = 'XMLPROPERTYEXISTS' then
  begin
    Found := functions_xml.FindItem(xml, GetString(Vm_Get(Params, 0)));
    if Found <> nil then
      SetBoolean(res, Found.Properties.ItemNamed[GetString(Vm_Get(Params, 1))] <> nil)
    else
      SetBoolean(res, False);
  end
  else
  if proc^.Name = 'XMLPROPERTYVALUE' then
  begin
    Found := functions_xml.FindItem(xml, GetString(Vm_Get(Params, 0)));
    if Found <> nil then
      SetString(res, Found.Properties.Value(GetString(Vm_Get(Params, 1)), GetString(Vm_Get(Params, 2))))
    else
      SetString(res, GetString(Vm_Get(Params, 2)));
  end
end;
*)

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
