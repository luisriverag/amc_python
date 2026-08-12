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

unit options;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Buttons, ExtCtrls, shellapi, ComCtrls, dialogs, ImgList,
  inifiles,

  TBX, TBXDkPanels,

  AntCorelButton, AntJvToolEdit, AntJvExControls, AntJvEdit,
  AntJvSpin, AntAutoHintLabel, AntJvLinkLabel,

  base, ConstValues, ProgramSettings, FramePictureSelectionOptions, Menus,
  TB2Item, movieclass, framefilenaming;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TOptionsWin = class(TBaseDlg)
    Bevel10: TBevel;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Bevel15: TBevel;
    Bevel16: TBevel;
    Bevel17: TBevel;
    Bevel18: TBevel;
    Bevel19: TBevel;
    Bevel2: TBevel;
    Bevel20: TBevel;
    Bevel21: TBevel;
    Bevel22: TBevel;
    Bevel23: TBevel;
    Bevel24: TBevel;
    Bevel26: TBevel;
    Bevel27: TBevel;
    Bevel28: TBevel;
    Bevel29: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    Bevel8: TBevel;
    BtnDefaultValues: TCorelButton;
    BtnRepairAssoc: TCorelButton;
    btnSearchAdd: TTBXButton;
    btnSearchDel: TTBXButton;
    btnSearchDown: TTBXButton;
    btnSearchUp: TTBXButton;
    CBAddOpenFiles: TCheckBox;
    CBAddOpenScript: TCheckBox;
    CBAskNumber: TCheckBox;
    CBAutoLoad: TCheckBox;
    CBAutoLoadLast: TCheckBox;
    CBAutorunScript: TCheckBox;
    CBBackup: TCheckBox;
    CBCheckboxes: TCheckBox;
    CBComboAutoAdd: TCheckBox;
    CBComboAutoComplete: TCheckBox;
    CBComboCatalogValues: TCheckBox;
    CBComboSameForAll: TCheckBox;
    CBComboSort: TCheckBox;
    CBCopyPictures: TCheckBox;
    CBCopyPicturesInPicDir: TCheckBox;
    CBCopyPicturesNew: TCheckBox;
    CBDelete: TCheckBox;
    CBDNDAudioBitrate: TCheckBox;
    CBDNDAudioCodec: TCheckBox;
    CBDNDFileName: TCheckBox;
    CBDNDFileNameFilePath: TCheckBox;
    CBDNDFileNameURL: TCheckBox;
    CBDNDFramerate: TCheckBox;
    CBDNDInternalAVI: TCheckBox;
    CBDNDLanguages: TCheckBox;
    CBDNDLength: TCheckBox;
    CBDNDMediaLabel: TCheckBox;
    CBDNDResolution: TCheckBox;
    CBDNDSize: TCheckBox;
    CBDNDSubtitles: TCheckBox;
    CBDNDVideoBitrate: TCheckBox;
    CBDNDVideoCodec: TCheckBox;
    CBEnhScrollbars: TCheckBox;
    CBFirstAvailable: TCheckBox;
    CBFitPicture: TCheckBox;
    CBHistory: TCheckBox;
    CBHotTrack: TCheckBox;
    CBKeepConnection: TCheckBox;
    CBLastFileName: TCheckBox;
    CBLoadTemplate: TCheckBox;
    CBLogo: TCheckBox;
    CBMenuImages: TCheckBox;
    CBMovieNumColumn: TCheckBox;
    CBOfficeXP: TCheckBox;
    CBOpenExportedFile: TCheckBox;
    CBPicImportGetInfoNoAsk: TCheckBox;
    CBPrefixes: TCheckBox;
    CBProxy: TCheckBox;
    CBRatingTrunc: TCheckBox;
    CBSameForAll: TCheckBox;
    CBSoftBorders: TCheckBox;
    CBUndo: TCheckBox;
    cbxColorType: TComboBox;
    cbxComboSelect: TComboBox;
    cbxDNDSizeUnit: TComboBox;
    cbxIconSet: TComboBox;
    cbxPictureBackground: TColorBox;
    cbxTitle: TComboBox;
    cbxWindow: TComboBox;
    EAutoLoad: TAntJvComboEditXP;
    EHTMLTemplate: TAntJvComboEditXP;
    EComboEdit: TMemo;
    EExpFileExt: TComboBox;
    EFolderSpecified: TAntJvComboEditXP;
    EForcePicSizeH: TEdit;
    EForcePicSizeW: TEdit;
    EHistoryFile: TAntJvComboEditXP;
    ELineBreaks: TComboBox;
    EPrefixes: TMemo;
    EProxyPassword: TEdit;
    EProxyPort: TAntJvSpinEdit;
    EProxyServer: TEdit;
    EProxyUsername: TEdit;
    ERecentFiles: TAntJvSpinEdit;
    ESearchAddress: TEdit;
    ESearchName: TEdit;
    ESQLDate: TComboBox;
    LColorType: TLabel;
    LDefaultValues: TLabel;
    LDNDSizeUnit: TLabel;
    LExpFileExt: TLabel;
    LFolderToUse: TGroupBox;
    LForcePicSize: TLabel;
    LForcePicSizeH: TLabel;
    LForcePicSizeW: TLabel;
    LHAddMovie: TLabel;
    LHComboBoxItems: TLabel;
    LHConnection: TLabel;
    LHCustomizeToolbar: TLabel;
    LHDisplay: TLabel;
    LHExportFileNames: TLabel;
    LHFoldersDialogs: TLabel;
    LHFormatting: TLabel;
    LHGetInfoAudio: TLabel;
    LHGetInfoVideo: TLabel;
    LHHistory: TLabel;
    LHHTMLTemplate: TLabel;
    LHHTML: TLabel;
    LHImportPic: TLabel;
    LHMainWindow: TLabel;
    LHOperations: TLabel;
    LHPictures: TLabel;
    LHPictureWindow: TLabel;
    LHRating: TLabel;
    LHSaving: TLabel;
    LHScript: TLabel;
    LHSearch: TLabel;
    LHShortcut: TLabel;
    LHSQL: TLabel;
    LHStartup: TLabel;
    LHToolbar: TLabel;
    LHVideoDragDrop: TLabel;
    LIconSet: TLabel;
    LLineBreaks: TLabel;
    LListEdit: TLabel;
    LListOptions: TGroupBox;
    LPicCopyNote: TLabel;
    LPicNamingNote: TLabel;
    LPictureBackground: TLabel;
    LPrefixes1: TLabel;
    LPrefixes2: TLabel;
    LProxyPassword: TLabel;
    LProxyPort: TLabel;
    LProxyServer: TLabel;
    LProxyUsername: TLabel;
    LRecentFiles: TLabel;
    LRepairAssociations: TLabel;
    LScriptPicImport: TAntJvLinkLabel;
    LSearchEdit: TLabel;
    LSearchNote1: TLabel;
    LSearchNote2: TLabel;
    LSearchNote3: TLabel;
    LSearchNotes: TLabel;
    LShortcutNext: TLabel;
    LShortcutPrev: TLabel;
    LSQLDate: TLabel;
    LTitleColumn: TLabel;
    LvCat: TTreeView;
    LvCustomizeToolbar: TListView;
    LvSearch: TListView;
    PageControl1: TPageControl;
    PicImportGetInfo: TPictureSelectOptionsFrame;
    PicImportScripting: TPictureSelectOptionsFrame;
    RBDNDString: TRadioButton;
    RBDNDSum: TRadioButton;
    RBFolderDefault: TRadioButton;
    RBFolderRemember: TRadioButton;
    RBFolderSpecified: TRadioButton;
    ShortcutNext: THotKey;
    ShortcutPrev: THotKey;
    TabSheetComboBox: TTabSheet;
    TabSheetDisplay: TTabSheet;
    TabSheetExport: TTabSheet;
    TabSheetFiles: TTabSheet;
    TabSheetFolders: TTabSheet;
    TabSheetGetInfo: TTabSheet;
    TabSheetMovieInformation: TTabSheet;
    TabSheetMoviesList: TTabSheet;
    TabSheetPictureImport: TTabSheet;
    TabSheetScripting: TTabSheet;
    TabSheetSearch: TTabSheet;
    TabSheetTitleFormatting: TTabSheet;
    TabSheetToolbar: TTabSheet;
    CBShowPicInfo: TCheckBox;
    TabSheetGroupinh: TTabSheet;
    LHGrouping: TLabel;
    Bevel9: TBevel;
    CBGroupUnique: TCheckBox;
    CBGroupCount: TCheckBox;
    CBGroupExpand: TCheckBox;
    LHCommonGroups: TLabel;
    Bevel30: TBevel;
    lblGroupLocation: TLabel;
    RBGroupsAbove: TRadioButton;
    RBGroupsBelow: TRadioButton;
    CBHTTP10: TCheckBox;
    LGridTextSize: TLabel;
    EGridTextSize: TAntJvSpinEdit;
    CBGroupMulti: TCheckBox;
    CBGroupMultiRmAllP: TCheckBox;
    EGroupMultiSep: TComboBox;
    CBGroupMultiAddPatch: TCheckBox;
    CBSortGroupsByCount: TCheckBox;
    Bevel32: TBevel;
    EAutoLoadCF: TAntJvComboEditXP;
    CBAutoloadCF: TCheckBox;
    CBSetCurrentDate: TCheckBox;
    CBCheckboxesColor: TCheckBox;
    CBLinesColor: TCheckBox;
    Bevel31: TBevel;
    LHMovieFrame: TLabel;
    LMovieFrameBackground: TLabel;
    cbxMovieFrameBackground: TColorBox;
    CBAutoStretchListGrid: TCheckBox;
    CBAutoStretchListThumbs: TCheckBox;
    EExtVideo: TEdit;
    LExtVideo: TLabel;
    btnDefaultExtVideo: TCorelButton;
    CBChecked: TCheckBox;
    EColorTag: TComboBox;
    LColorTag: TLabel;
    btnFilterFileName: TCorelButton;
    CBDNDAllowClear: TCheckBox;
    CBCheckboxesInThumbs: TCheckBox;
    CBNatCmp: TCheckBox;
    CBScrollUnderPointer: TCheckBox;
    CBAutoFocus: TCheckBox;
    CBForceRefresh: TCheckBox;
    ETitleTemplate: TEdit;
    BtnInsertFieldTag: TTBXButton;
    LTitleTemplate: TLabel;
    CBDNDAudioChannels: TCheckBox;
    LHAddExtra: TLabel;
    Bevel33: TBevel;
    BtnExtraDefaultValues: TCorelButton;
    CBExtraChecked: TCheckBox;
    EDefaultPicture: TAntJvComboEditXP;
    EExtraDefaultPicture: TAntJvComboEditXP;
    LExtraDefaultPicture: TLabel;
    LDefaultPicture: TLabel;
    LPicNamingPlus: TLabel;
    RBPicImport: TRadioButton;
    RBExtraPicImport: TRadioButton;
    PanelPicImport: TPanel;
    PanelExtraPicImport: TPanel;
    ExtraPicImportGetInfo: TPictureSelectOptionsFrame;
    ExtraPicImportScripting: TPictureSelectOptionsFrame;
    CBExtraPicImportGetInfoNoAsk: TCheckBox;
    PopupFields: TTBXPopupMenu;
    TabSheet1: TTabSheet;
    LHExtraDisplay: TLabel;
    Bevel34: TBevel;
    CBExtraCheckboxes: TCheckBox;
    CBExtraNumWithTitle: TCheckBox;
    Label2: TLabel;
    Bevel35: TBevel;
    CBExtraDelete: TCheckBox;
    LHExtraGrouping: TLabel;
    Bevel36: TBevel;
    CBExtraGroupCount: TCheckBox;
    CBExtraGroupExpand: TCheckBox;
    CBExtraGroupMulti: TCheckBox;
    EExtraGroupMultiSep: TComboBox;
    CBExtraGroupMultiRmAllP: TCheckBox;
    CBExtraSortGroupsByCount: TCheckBox;
    LHExtraCommonGroups: TLabel;
    Bevel37: TBevel;
    lblExtraGroupLocation: TLabel;
    RBExtraGroupsAbove: TRadioButton;
    RBExtraGroupsBelow: TRadioButton;
    CBCopyPicturesIncExtras: TCheckBox;
    ExpFileNamingFrame: TFileNamingFrame;
    PicNamingFrame: TFileNamingFrame;
    LForceExtraPicSize: TLabel;
    LForceExtraPicSizeW: TLabel;
    EForceExtraPicSizeW: TEdit;
    LForceExtraPicSizeH: TLabel;
    EForceExtraPicSizeH: TEdit;
    LExtraMaxPicSizeW: TLabel;
    EExtraMaxPicSizeW: TEdit;
    LExtraMaxPicSizeH: TLabel;
    EExtraMaxPicSizeH: TEdit;
    LExtraMaxPicSizeUnit: TLabel;
    CBExtraPicConvert: TCheckBox;
    CBPicConvert: TCheckBox;
    LMaxPicSizeUnit: TLabel;
    EMaxPicSizeH: TEdit;
    LMaxPicSizeH: TLabel;
    EMaxPicSizeW: TEdit;
    LMaxPicSizeW: TLabel;
    CBDNDPicture: TCheckBox;
    CBExtraInfoWhenNoPic: TCheckBox;
    CBExtraCellBorders: TCheckBox;
    btnInsertFieldTagURL: TTBXButton;
    procedure btn1Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure BtnDefaultValuesClick(Sender: TObject);
    procedure BtnExtraDefaultValuesClick(Sender: TObject);
    procedure BtnRepairAssocClick(Sender: TObject);
    procedure btnSearchAddClick(Sender: TObject);
    procedure btnSearchDelClick(Sender: TObject);
    procedure btnSearchDownClick(Sender: TObject);
    procedure btnSearchUpClick(Sender: TObject);
    procedure CBAutoLoadClick(Sender: TObject);
    procedure CBAutoLoadCFClick(Sender: TObject);
    procedure CBComboCatalogValuesClick(Sender: TObject);
    procedure CBCopyPicturesClick(Sender: TObject);
    procedure CBDNDSizeClick(Sender: TObject);
    procedure CBHistoryClick(Sender: TObject);
    procedure CBPrefixesClick(Sender: TObject);
    procedure CBProxyClick(Sender: TObject);
    procedure CBSameForAllClick(Sender: TObject);
    procedure cbxComboSelectChange(Sender: TObject);
    procedure cbxWindowChange(Sender: TObject);
    procedure EAutoLoadButtonClick(Sender: TObject);
    procedure EAutoLoadCFButtonClick(Sender: TObject);
    procedure EHTMLTemplateButtonClick(Sender: TObject);
    procedure EFolderSpecifiedButtonClick(Sender: TObject);
    procedure EHistoryFileButtonClick(Sender: TObject);
    procedure EDefaultPictureButtonClick(Sender: TObject);
    procedure EExtraDefaultPictureButtonClick(Sender: TObject);
    procedure ESearchAddressChange(Sender: TObject);
    procedure ESearchNameChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure LvCatChange(Sender: TObject; Node: TTreeNode);
    procedure LvSearchSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure PicImportLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
    procedure RBFolderDefaultClick(Sender: TObject);
    procedure RBFolderRememberClick(Sender: TObject);
    procedure RBFolderSpecifiedClick(Sender: TObject);
    procedure CBGroupMultiClick(Sender: TObject);
    procedure CBCheckboxesClick(Sender: TObject);
    procedure btnDefaultExtVideoClick(Sender: TObject);
    procedure EColorTagDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure CBDNDFileNameClick(Sender: TObject);
    procedure btnFilterFileNameClick(Sender: TObject);
    procedure CBCheckboxesInThumbsClick(Sender: TObject);
    procedure cbxTitleSelect(Sender: TObject);
    procedure InsertTagClick(Sender: TObject);
    procedure RBPicImportClick(Sender: TObject);
    procedure CBPicConvertClick(Sender: TObject);
    procedure CBExtraPicConvertClick(Sender: TObject);
  private
    Folders: array[0..9] of TFolder;
    oldFolder: Integer;
    Combos: array[0..ddlCount-1] of TComboOptions;
    oldList: Integer;
    procedure EnableFolderSpecified(state: Boolean);
    procedure StoreOptions;
  protected
    procedure SaveOptions; override;
    procedure LoadOptions; override;
  public
    procedure InitFieldTags(const CustomFieldsProperties: TCustomFieldsProperties);
    function Execute(const CustomFieldsProperties: TCustomFieldsProperties;
      const Toolbar: TTBXToolbar; const Images: TImageList; PageNumber: Integer = 0): TModalResult;
    procedure Translate; override;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

var
  OptionsWin: TOptionsWin;

implementation

uses
  FileCtrl,

  functions_gui, Global, options_defaultvalues, functions_sys, functions_files,
  fields, functions_tbx, stringfilter, options_extradefaultvalues;

{$R *.DFM}

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.LoadOptions;
var
  i: integer;
begin
  with Settings.rOptions do
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
    with rMovieList do
    begin
      cbxTitle.ItemIndex := TitleColumn;
      CBPrefixes.Checked := UsePrefixes;
      EPrefixes.Lines.Assign(Prefixes);
      ETitleTemplate.Text := TitleTemplate;
      cbxTitleSelect(nil);
      cbdelete.Checked := ConfirmDelete;
      cbundo.checked := ConfirmUndo;
      cbcheckboxes.checked := Checkboxes;
      CBCheckboxesInThumbs.Checked := CheckboxesInThumbs;
      CBCheckboxesColor.Checked := CheckboxesColor;
      CBLinesColor.Checked := LinesColor;
      cbHotTrack.Checked := HotTrack;
      CBEnhScrollbars.Checked := EnhancedScrollbars;
      CBMovieNumColumn.Checked := MovieNumColumn;
      EGridTextSize.Text := IntToStr(GridTextSize);
      CBAutoStretchListGrid.Checked := AutoStretchListGrid;
      CBAutoStretchListThumbs.Checked := AutoStretchListThumbs;
      Self.ShortcutPrev.HotKey := ShortcutPrev;
      Self.ShortcutNext.HotKey := ShortcutNext;
      CBGroupCount.Checked := GroupCount;
      CBGroupExpand.Checked := GroupExpand;
      if GroupsAbove then
        RBGroupsAbove.Checked := True
      else
        RBGroupsBelow.Checked := True;
      CBGroupUnique.Checked := GroupUnique;
      CBGroupMulti.Checked := GroupMulti;
      EGroupMultiSep.Text := GroupMultiSep;
      CBGroupMultiRmAllP.Checked := GroupMultiRmAllP;
      CBGroupMultiAddPatch.Checked := GroupMultiAddPatch;
      CBSortGroupsByCount.Checked := SortGroupsByCount;
    end;
    with rExtraList do
    begin
      CBExtraCheckboxes.checked := Checkboxes;
      CBExtraNumWithTitle.Checked := NumWithTitle;
      CBExtraInfoWhenNoPic.Checked := InfoWhenNoPic;
      CBExtraCellBorders.Checked := CellBorders;
      CBExtraDelete.Checked := ConfirmDelete;
      CBExtraGroupCount.Checked := GroupCount;
      CBExtraGroupExpand.Checked := GroupExpand;
      if GroupsAbove then
        RBExtraGroupsAbove.Checked := True
      else
        RBExtraGroupsBelow.Checked := True;
      CBExtraGroupMulti.Checked := GroupMulti;
      EExtraGroupMultiSep.Text := GroupMultiSep;
      CBExtraGroupMultiRmAllP.Checked := GroupMultiRmAllP;
      CBExtraSortGroupsByCount.Checked := SortGroupsByCount;
    end;
    with rMovieInformation do
    begin
      CBAskNumber.checked := AskNumber;
      CBFirstAvailable.Checked := FirstAvailable;
      CBAddOpenScript.Checked := AddScript;
      CBAddOpenFiles.Checked := AddFiles;
      CBRatingTrunc.Checked := RatingTrunc;
      CBSetCurrentDate.Checked := SetCurrentDate;
      CBChecked.Checked := rDefaultMovie.Values.bChecked;
      EColorTag.ItemIndex := rDefaultMovie.Values.iColorTag;
      EDefaultPicture.Text := rDefaultMovie.Values.Picture.PicPath;
      CBExtraChecked.Checked := rDefaultExtra.Values.bChecked;
      EExtraDefaultPicture.Text := rDefaultExtra.Values.Picture.PicPath;
      cbxPictureBackground.Selected := PictureBackground;
      CBFitPicture.Checked := PictureFitWindow;
      CBShowPicInfo.Checked := PictureInfo;
      cbxMovieFrameBackground.Selected := MovieFrameBackground;
      CBComboSameForAll.Checked := ComboSameForAll;
      for i := 0 to Length(Combos)-1 do
      begin
        Combos[i].AutoAdd := rCombo[i].AutoAdd;
        Combos[i].Sort := rCombo[i].Sort;
        Combos[i].AutoComplete := rCombo[i].AutoComplete;
        Combos[i].UseCatalogValues := rCombo[i].UseCatalogValues;
        Combos[i].Contents.Assign(rCombo[i].Contents);
      end;
      CBDNDMediaLabel.Checked := ImportMediaLabel;
      CBDNDFileName.Checked := ImportFileName;
      CBDNDFileNameFilePath.Checked := ImportFileInFilePath;
      CBDNDFileNameURL.Checked := ImportFileInURL;
      cbxDNDSizeUnit.ItemIndex := Integer(ImportSizeUnit);
      CBDNDSize.Checked := ImportSize;
      if ImportSizeString then
        RBDNDString.Checked := true
      else
        RBDNDSum.Checked := true;
      CBDNDPicture.Checked := ImportPicture;
      CBDNDAllowClear.Checked := ImportAllowClear;
      CBDNDInternalAVI.Checked := ImportInternalAVI;
      EExtVideo.Text := ImportExt;
      CBDNDLength.Checked := ImportLength;
      CBDNDResolution.Checked := ImportResolution;
      CBDNDFramerate.Checked := ImportFramerate;
      CBDNDVideoCodec.Checked := ImportVideoCodec;
      CBDNDVideoBitrate.Checked := ImportVideoBitrate;
      CBDNDAudioCodec.Checked := ImportAudioCodec;
      CBDNDAudioChannels.Checked := ImportAudioChannels;
      CBDNDAudioBitrate.Checked := ImportAudioBitrate;
      CBDNDLanguages.Checked := ImportLanguages;
      CBDNDSubtitles.Checked := ImportSubtitles;

      PicImportGetInfo.Selected := TPictureSelectOption(Abs(rPicImport.GetInfoMethod));
      CBPicImportGetInfoNoAsk.Checked := rPicImport.GetInfoMethod > 0;
      PicImportScripting.Selected := TPictureSelectOption(rPicImport.ScriptingMethod);
      CBPicConvert.Checked := rPicImport.PicConvertJPG;
      if rPicImport.MaxPicSizeW > 0 then
        EMaxPicSizeW.Text := IntToStr(rPicImport.MaxPicSizeW)
      else
        EMaxPicSizeW.Text := '';
      if rPicImport.MaxPicSizeH > 0 then
        EMaxPicSizeH.Text := IntToStr(rPicImport.MaxPicSizeH)
      else
        EMaxPicSizeH.Text := '';
      CBPicConvertClick(Self);

      ExtraPicImportGetInfo.Selected := TPictureSelectOption(Abs(rExtraPicImport.GetInfoMethod));
      CBExtraPicImportGetInfoNoAsk.Checked := rExtraPicImport.GetInfoMethod > 0;
      ExtraPicImportScripting.Selected := TPictureSelectOption(rExtraPicImport.ScriptingMethod);
      CBExtraPicConvert.Checked := rExtraPicImport.PicConvertJPG;
      if rExtraPicImport.MaxPicSizeW > 0 then
        EExtraMaxPicSizeW.Text := IntToStr(rExtraPicImport.MaxPicSizeW)
      else
        EExtraMaxPicSizeW.Text := '';
      if rExtraPicImport.MaxPicSizeH > 0 then
        EExtraMaxPicSizeH.Text := IntToStr(rExtraPicImport.MaxPicSizeH)
      else
        EExtraMaxPicSizeH.Text := '';
      CBExtraPicConvertClick(Self);

      //PicNamingFrame.LoadFromObject(PictureNaming, CustomFieldsProperties); // Done in Execute
      LvSearch.Clear;
      for i := 0 to SearchSites.Count-1 do
      begin
        with LvSearch.Items.Add do
        begin
          Caption := SearchSites.Names[i];
          SubItems.Add(SearchSites.Values[Caption]);
        end;
      end;
    end;
    with rDisplay do
    begin
      CBOfficeXP.Checked := OfficeXP;
      cbxIconSet.ItemIndex := cbxIconSet.Items.IndexOf(IconSet);
      if cbxIconSet.ItemIndex = -1 then
        cbxIconSet.ItemIndex := 0;
      cbxColorType.ItemIndex := ColorType;
      cbMenuImages.checked := ImagesInMenu;
      cbLogo.Checked := Logo;
      CBSoftBorders.Checked := SoftBorders;
      CBNatCmp.Checked := NaturalCompare;
      CBScrollUnderPointer.Checked := ScrollUnderPointer;
      CBAutoFocus.Checked := AutoFocus;
      CBForceRefresh.Checked := ForceRefresh;
    end;
    with rExport do
    begin
      ELineBreaks.Text := Linebreak;
      ESQLDate.Text := SQLDate;
      cbloadtemplate.Checked := LoadTemplate;
      if ForcePicSizeW < 0 then
        EForcePicSizeW.Text := ''
      else
        EForcePicSizeW.Text := IntToStr(ForcePicSizeW);
      if ForcePicSizeH < 0 then
        EForcePicSizeH.Text := ''
      else
        EForcePicSizeH.Text := IntToStr(ForcePicSizeH);
      if ForceExtraPicSizeW < 0 then
        EForceExtraPicSizeW.Text := ''
      else
        EForceExtraPicSizeW.Text := IntToStr(ForceExtraPicSizeW);
      if ForceExtraPicSizeH < 0 then
        EForceExtraPicSizeH.Text := ''
      else
        EForceExtraPicSizeH.Text := IntToStr(ForceExtraPicSizeH);
      CBLastFileName.Checked := RememberLastFile;
      CBOpenExportedFile.Checked := OpenExportedFile;
      EExpFileExt.Text := ExpFileExt;
      //ExpFileNamingFrame.LoadFromObject(ExpFileNaming, CustomFieldsProperties); // Done in Execute
      CBCopyPictures.Checked := CopyPictures;
      CBCopyPicturesInPicDir.Checked := CopyPicturesInPicDir;
      CBCopyPicturesNew.Checked := CopyPicturesNew;
      CBCopyPicturesIncExtras.Checked := CopyPicturesIncExtras;
    end;
    with rFiles do
    begin
//      cbxXMLEncoding.Text := XMLHeader;
      cbbackup.checked := Backup;
      ERecentFiles.AsInteger := RecentFiles;
      CBAutoLoad.Checked := AutoLoad;
      if AutoLoadLast then
        EAutoLoad.Text := ''
      else
        EAutoLoad.Text := AutoLoadFile;
      CBAutoLoadLast.Checked := AutoLoadLast;
      CBAutoLoadCF.Checked := AutoLoadCF;
      EAutoLoadCF.Text := AutoLoadCFFile;
      CBHistory.Checked := History;
      EHistoryFile.Text := HistoryFile;
      EHTMLTemplate.Text := HTMLTemplateFile;
    end;
    with rScripting do
    begin
      CBAutorunScript.Checked := ScriptAutorun;
      CBProxy.Checked := Proxy;
      EProxyServer.Text := ProxyServer;
      EProxyPort.AsInteger := ProxyPort;
      EProxyUsername.Text := ProxyUsername;
      EProxyPassword.Text := ProxyPassword;
      CBKeepConnection.Checked := KeepConnection;
      CBHTTP10.Checked := HTTP10;
    end;
    for i := 0 to Length(Folders)-1 do
    begin
      Folders[i].DefaultPath := rFolders[i].DefaultPath;
      Folders[i].SetFolder(rFolders[i].ValueRaw, rFolders[i].FolderType);
      Folders[i].Value := rFolders[i].ValueRaw;
    end;
    CBSameForAll.Checked := SameFolderForAll;
  end; // with Settings.rOptions
  cbxWindow.ItemIndex := 0;
  oldFolder := -1;
  cbxComboSelect.ItemIndex := 0;
  oldList := -1;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.SaveOptions;
begin
  with Settings.rOptions do
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
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.StoreOptions;
var
  i, rbid: Integer;
begin
  with Settings.rOptions do
  begin
    with rMovieList do
    begin
      TitleColumn := cbxTitle.ItemIndex;
      UsePrefixes := CBPrefixes.Checked;
      Prefixes.Assign(EPrefixes.Lines);
      TitleTemplate := ETitleTemplate.Text;
      ConfirmDelete := cbdelete.Checked;
      ConfirmUndo := cbundo.checked;
      Checkboxes := cbcheckboxes.checked;
      CheckboxesInThumbs := CBCheckboxesInThumbs.Checked;
      CheckboxesColor := CBCheckboxesColor.Checked;
      LinesColor := CBLinesColor.Checked;
      HotTrack := cbHotTrack.Checked;
      EnhancedScrollbars := CBEnhScrollbars.Checked;
      MovieNumColumn := CBMovieNumColumn.Checked;
      GridTextSize := StrToInt(EGridTextSize.Text);
      AutoStretchListGrid := CBAutoStretchListGrid.Checked;
      AutoStretchListThumbs := CBAutoStretchListThumbs.Checked;
      ShortcutPrev := Self.ShortcutPrev.HotKey;
      ShortcutNext := Self.ShortcutNext.HotKey;
      GroupCount := CBGroupCount.Checked;
      GroupExpand := CBGroupExpand.Checked;
      GroupsAbove := RBGroupsAbove.Checked;
      GroupUnique := CBGroupUnique.Checked;
      if (Length(EGroupMultiSep.Text) > 0) then
      begin
        GroupMultiSep := (EGroupMultiSep.Text)[1];
      end else
      begin
        CBGroupMulti.Checked := False;
        GroupMultiSep := defaultSep;
      end;
      GroupMulti := CBGroupMulti.Checked;
      GroupMultiRmAllP := CBGroupMultiRmAllP.Checked;
      GroupMultiAddPatch := CBGroupMultiAddPatch.Checked;
      SortGroupsByCount := CBSortGroupsByCount.Checked;
    end; // with rMovieList
    with rExtraList do
    begin
      Checkboxes := CBExtraCheckboxes.Checked;
      NumWithTitle := CBExtraNumWithTitle.Checked;
      InfoWhenNoPic := CBExtraInfoWhenNoPic.Checked;
      CellBorders := CBExtraCellBorders.Checked;
      ConfirmDelete := CBExtraDelete.Checked;
      GroupCount := CBExtraGroupCount.Checked;
      GroupExpand := CBExtraGroupExpand.Checked;
      GroupsAbove := RBExtraGroupsAbove.Checked;
      if (Length(EExtraGroupMultiSep.Text) > 0) then
      begin
        GroupMultiSep := (EExtraGroupMultiSep.Text)[1];
      end else
      begin
        CBExtraGroupMulti.Checked := False;
        GroupMultiSep := defaultSep;
      end;
      GroupMulti := CBExtraGroupMulti.Checked;
      GroupMultiRmAllP := CBExtraGroupMultiRmAllP.Checked;
      SortGroupsByCount := CBExtraSortGroupsByCount.Checked;
    end; // with rExtraList
    with rMovieInformation do
    begin
      AskNumber := CBAskNumber.checked;
      FirstAvailable := CBFirstAvailable.Checked;
      AddScript := CBAddOpenScript.Checked;
      AddFiles := CBAddOpenFiles.Checked;
      RatingTrunc := CBRatingTrunc.Checked;
      SetCurrentDate := CBSetCurrentDate.Checked;
      rDefaultMovie.Values.bChecked := CBChecked.Checked;
      rDefaultMovie.Values.iColorTag := EColorTag.ItemIndex;
      rDefaultMovie.Values.Picture.PicPath := EDefaultPicture.Text;
      rDefaultExtra.Values.bChecked := CBExtraChecked.Checked;
      rDefaultExtra.Values.Picture.PicPath := EExtraDefaultPicture.Text;
      PictureBackground := cbxPictureBackground.Selected;
      PictureFitWindow := CBFitPicture.Checked;
      PictureInfo := CBShowPicInfo.Checked;
      MovieFrameBackground := cbxMovieFrameBackground.Selected;
      ImportMediaLabel := CBDNDMediaLabel.Checked;
      ImportFileName := CBDNDFileName.Checked;
      ImportFileInFilePath := CBDNDFileNameFilePath.Checked;
      ImportFileInURL := CBDNDFileNameURL.Checked;
      ImportSize := CBDNDSize.Checked;
      ImportSizeString := RBDNDString.Checked;
      ImportSizeUnit := TFileSizeUnit(cbxDNDSizeUnit.ItemIndex);
      ImportPicture := CBDNDPicture.Checked;
      ImportAllowClear := CBDNDAllowClear.Checked;
      ImportInternalAVI := CBDNDInternalAVI.Checked;
      ImportExt := EExtVideo.Text;
      ImportLength := CBDNDLength.Checked;
      ImportResolution := CBDNDResolution.Checked;
      ImportFramerate := CBDNDFramerate.Checked;
      ImportVideoCodec := CBDNDVideoCodec.Checked;
      ImportVideoBitrate := CBDNDVideoBitrate.Checked;
      ImportAudioCodec := CBDNDAudioCodec.Checked;
      ImportAudioChannels := CBDNDAudioChannels.Checked;
      ImportAudioBitrate := CBDNDAudioBitrate.Checked;
      ImportLanguages := CBDNDLanguages.Checked;
      ImportSubtitles := CBDNDSubtitles.Checked;

      rPicImport.GetInfoMethod := Integer(PicImportGetInfo.Selected);
      if not CBPicImportGetInfoNoAsk.Checked then
        rPicImport.GetInfoMethod := - rPicImport.GetInfoMethod;
      rPicImport.ScriptingMethod := Integer(PicImportScripting.Selected);
      rPicImport.PicConvertJPG := CBPicConvert.Checked;
      rPicImport.MaxPicSizeW := StrToIntDef(EMaxPicSizeW.Text, -1);
      rPicImport.MaxPicSizeH := StrToIntDef(EMaxPicSizeH.Text, -1);

      rExtraPicImport.GetInfoMethod := Integer(ExtraPicImportGetInfo.Selected);
      if not CBExtraPicImportGetInfoNoAsk.Checked then
        rExtraPicImport.GetInfoMethod := - rExtraPicImport.GetInfoMethod;
      rExtraPicImport.ScriptingMethod := Integer(ExtraPicImportScripting.Selected);
      rExtraPicImport.PicConvertJPG := CBExtraPicConvert.Checked;
      rExtraPicImport.MaxPicSizeW := StrToIntDef(EExtraMaxPicSizeW.Text, -1);
      rExtraPicImport.MaxPicSizeH := StrToIntDef(EExtraMaxPicSizeH.Text, -1);

      PicNamingFrame.SaveToObject(PictureNaming);
      SearchSites.Clear;
      with LvSearch.Items do
        for i := 0 to Count-1 do
          SearchSites.Add(Item[i].Caption + '=' + Item[i].SubItems.Strings[0]);
      ComboSameForAll := CBComboSameForAll.Checked;
      for i := 0 to Length(Combos)-1 do
      begin
        rCombo[i].Contents.Assign(Combos[i].Contents);
        if ComboSameForAll then
        begin
          rCombo[i].AutoAdd := CBComboAutoAdd.Checked;
          rCombo[i].Sort := CBComboSort.Checked;
          rCombo[i].AutoComplete := CBComboAutoComplete.Checked;
          rCombo[i].UseCatalogValues := CBComboCatalogValues.Checked;
        end else
        begin
          rCombo[i].AutoAdd := Combos[i].AutoAdd;
          rCombo[i].Sort := Combos[i].Sort;
          rCombo[i].AutoComplete := Combos[i].AutoComplete;
          rCombo[i].UseCatalogValues := Combos[i].UseCatalogValues;
        end;
      end;
    end; // with rMovieInformation
    with rDisplay do
    begin
      ImagesInMenu := cbMenuImages.checked;
      OfficeXP := CBOfficeXP.Checked;
      IconSet := cbxIconSet.Text;
      ColorType := cbxColorType.ItemIndex;
      Logo := cbLogo.Checked;
      SoftBorders := CBSoftBorders.Checked;
      NaturalCompare := CBNatCmp.Checked;
      ScrollUnderPointer := CBScrollUnderPointer.Checked;
      AutoFocus := CBAutoFocus.Checked;
      ForceRefresh := CBForceRefresh.Checked;
    end; // with rDisplay
    with rExport do
    begin
      LoadTemplate := cbloadtemplate.Checked;
      Linebreak := ELineBreaks.Text;
      ForcePicSizeW := StrToIntDef(EForcePicSizeW.Text, -1);
      ForcePicSizeH := StrToIntDef(EForcePicSizeH.Text, -1);
      ForceExtraPicSizeW := StrToIntDef(EForceExtraPicSizeW.Text, -1);
      ForceExtraPicSizeH := StrToIntDef(EForceExtraPicSizeH.Text, -1);
      SQLDate := ESQLDate.Text;
      RememberLastFile := CBLastFileName.Checked;
      OpenExportedFile := CBOpenExportedFile.Checked;
      ExpFileExt := EExpFileExt.Text;
      ExpFileNamingFrame.SaveToObject(ExpFileNaming);
      CopyPictures := CBCopyPictures.Checked;
      CopyPicturesInPicDir := CBCopyPicturesInPicDir.Checked;
      CopyPicturesNew := CBCopyPicturesNew.Checked;
      CopyPicturesIncExtras := CBCopyPicturesIncExtras.Checked;
    end; // with rExport
    with rFiles do
    begin
//      XMLHeader := cbxXMLEncoding.Text;
      Backup := cbbackup.checked;
      RecentFiles := ERecentFiles.AsInteger;
      AutoLoad := CBAutoLoad.Checked;
      AutoLoadFile := EAutoLoad.Text;
      AutoLoadLast := CBAutoLoadLast.Checked;
      AutoLoadCF := CBAutoLoadCF.Checked;
      AutoLoadCFFile := EAutoLoadCF.Text;
      History := CBHistory.Checked;
      HistoryFile := EHistoryFile.Text;
      HTMLTemplateFile := EHTMLTemplate.Text;
    end; // with rFiles
    with rScripting do
    begin
      ScriptAutorun := CBAutorunScript.Checked;
      Proxy := CBProxy.Checked;
      ProxyServer := EProxyServer.Text;
      ProxyPort := EProxyPort.AsInteger;
      ProxyUsername := EProxyUsername.Text;
      ProxyPassword := EProxyPassword.Text;
      KeepConnection := CBKeepConnection.Checked;
      HTTP10 := CBHTTP10.Checked;
    end;
    SameFolderForAll := CBSameForAll.Checked;
    for i := 0 to Length(Folders)-1 do
    begin
      if SameFolderForAll then
      begin
        if RBFolderRemember.Checked then rbid := ftLast
        else if RBFolderSpecified.Checked then rbid := ftUser
        else rbid := ftDefault;
        rFolders[i].SetFolder(EFolderSpecified.Text, rbid);
      end else 
      begin
        rFolders[i].SetFolder(Folders[i].ValueRaw, Folders[i].FolderType);
      end; // if else
    end; // for
  end; // with Settings.rOptions
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.FormShow(Sender: TObject);
begin
  inherited;
  // some checkboxes have to be grayed :
  CBSameForAllClick(Self);
  CBHistoryClick(Self);
  CBProxyClick(Self);
  CBAutoLoadClick(Self);
  CBAutoLoadCFClick(Self);
  CBPrefixesClick(Self);
  CBDNDFileNameClick(Self);
  CBDNDSizeClick(Self);
  CBCopyPicturesClick(Self);
  CBGroupMultiClick(Self);
  CBCheckboxesClick(Self);

  if CBComboSameForAll.Checked then
    with Combos[0] do
    begin
      CBComboAutoAdd.Checked := AutoAdd;
      CBComboSort.Checked := Sort;
      CBComboAutoComplete.Checked := AutoComplete;
      CBComboCatalogValues.Checked := UseCatalogValues;
    end;
  cbxComboSelectChange(Self);
  cbxWindowChange(Self);

  LvSearch.Selected := nil;
  LvSearchSelectItem(Sender, nil, False);
  LvCat.FullExpand;
  Btn3.SetFocus;

end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.BtnRepairAssocClick(Sender: TObject);
begin
  AssociateFileExtension(strAppExe + ',1','Ant Movie Catalog', strAppExe, 'amc');
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.BtnDefaultValuesClick(Sender: TObject);
begin
  DefaultValuesWin := TDefaultValuesWin.Create(Self);
  try
    DefaultValuesWin.Icon.Assign(Icon);
    DefaultValuesWin.ShowModal;
  finally
    DefaultValuesWin.Release;
    DefaultValuesWin := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.BtnExtraDefaultValuesClick(Sender: TObject);
begin
  ExtraDefaultValuesWin := TExtraDefaultValuesWin.Create(Self);
  try
    ExtraDefaultValuesWin.Icon.Assign(Icon);
    ExtraDefaultValuesWin.ShowModal;
  finally
    ExtraDefaultValuesWin.Release;
    ExtraDefaultValuesWin := nil;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.FormCreate(Sender: TObject);
var
  i: integer;
  SearchRecord: TSearchRec;
  RemaindFiles: integer;
  procedure LoadBrowseIcon(AEdit: TAntJvComboEdit);
  begin
    AEdit.Images := ToolbarImages;
    AEdit.ImageIndex := Ord(ICON_BROWSE);
  end;
begin
  with PageControl1 do
    for i := 0 to PageCount - 1 do
      Pages[i].TabVisible := false;

  CbxIconSet.ItemIndex := 0;
  SetCurrentDir(strDirToolbars);
  RemaindFiles := FindFirst('*.bmp', 0, SearchRecord);
  try
    while RemaindFiles = 0 do
    begin
      CbxIconSet.Items.Add(ChangeFileExt(SearchRecord.Name, ''));
      RemaindFiles := FindNext(SearchRecord);
    end;
  finally
    FindClose(SearchRecord);
  end;
  for i := 0 to Length(Folders) - 1 do
    Folders[i] := TFolder.Create;
  for i := 0 to Length(Combos) - 1 do
    Combos[i].Contents := TStringList.Create;
  oldFolder := -1;
  oldList := -1;
  LoadBrowseIcon(EAutoLoad);
  LoadBrowseIcon(EAutoLoadCF);
  LoadBrowseIcon(EHistoryFile);
  LoadBrowseIcon(EHTMLTemplate);
  LoadBrowseIcon(EFolderSpecified);
  LoadBrowseIcon(EDefaultPicture);
  LoadBrowseIcon(EExtraDefaultPicture);
  LoadButtonIcon(btnSearchAdd, ICON_ROWINSERT);
  LoadButtonIcon(btnSearchDel, ICON_ROWDELETE);
  LoadButtonIcon(btnSearchUp, ICON_MOVEUP);
  LoadButtonIcon(btnSearchDown, ICON_MOVEDOWN);
  EColorTag.Items.Clear;
  with Settings.rOptions.rMovieList do
    for i := 0 to Length(ColorsTag)-1 do
    begin
      EColorTag.Items.Add(IntToStr(i));
      EColorTag.ItemIndex := 0;
    end;
  inherited;
  if IsThemedXP then
    cbxMovieFrameBackground.DefaultColorColor := clWindow
  else
    cbxMovieFrameBackground.DefaultColorColor := clBtnFace;
  PicNamingFrame.EPrefix.Items.Delete(2);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  for i := 0 to Length(Folders) - 1 do
    Folders[i].Free;
  for i := 0 to Length(Combos) - 1 do
    Combos[i].Contents.Free;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.Translate;
begin
  Translator.Translate(PicImportGetInfo);
  Translator.Translate(PicImportScripting);
  Translator.Translate(ExtraPicImportGetInfo);
  Translator.Translate(ExtraPicImportScripting);
  Translator.Translate(PicNamingFrame);
  Translator.Translate(ExpFileNamingFrame);
  inherited;
  ExtraPicImportGetInfo.grp.Caption := PicImportGetInfo.grp.Caption;
  CBExtraPicImportGetInfoNoAsk.Caption := CBPicImportGetInfoNoAsk.Caption;
  ExtraPicImportScripting.grp.Caption := PicImportScripting.grp.Caption;
  CBExtraPicConvert.Caption := CBPicConvert.Caption;
  LExtraMaxPicSizeW.Caption := LMaxPicSizeW.Caption;
  EExtraMaxPicSizeW.Hint := EMaxPicSizeW.Hint;
  LExtraMaxPicSizeH.Caption := LMaxPicSizeH.Caption;
  EExtraMaxPicSizeH.Hint := EMaxPicSizeH.Hint;
  LExtraMaxPicSizeUnit.Caption := LMaxPicSizeUnit.Caption;
  btnInsertFieldTagURL.Hint := btnInsertFieldTag.Hint;
  with cbxComboSelect.Items do
  begin
    BeginUpdate;
    try
      Strings[ddlMediaType] := strFields[fieldMediaType];
      Strings[ddlSources] := strFields[fieldSource];
      Strings[ddlBorrowers] := strFields[fieldBorrower];
      Strings[ddlCountry] := strFields[fieldCountry];
      Strings[ddlCategory] := strFields[fieldCategory];
      Strings[ddlVideo] := strFields[fieldVideoFormat];
      Strings[ddlAudio] := strFields[fieldAudioFormat];
      Strings[ddlFramerate] := strFields[fieldFramerate];
      Strings[ddlLanguages] := strFields[fieldLanguages];
      Strings[ddlSubtitles] := strFields[fieldSubtitles];
      Strings[ddlCertification] := strFields[fieldCertification];
      Strings[ddlExtrasTag] := strExtraFields[extraFieldTag - extraFieldLow] + ' (' + strExtras + ')';
      Strings[ddlExtrasCategory] := strExtraFields[extraFieldCategory - extraFieldLow] + ' (' + strExtras + ')';
      Strings[ddlExtrasCreatedBy] := strExtraFields[extraFieldCreatedBy - extraFieldLow] + ' (' + strExtras + ')';
    finally
      EndUpdate;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBSameForAllClick(Sender: TObject);
begin
  cbxWindow.Enabled := not CBSameForAll.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.cbxWindowChange(Sender: TObject);
var
  idx, rbid: integer;
begin
  if not CBSameForAll.Checked then
  begin
    idx := cbxWindow.ItemIndex;
    if oldFolder <> -1 then
    begin
      if RBFolderRemember.Checked then rbid := ftLast
      else if RBFolderSpecified.Checked then rbid := ftUser
      else rbid := ftDefault;
      Folders[oldFolder].SetFolder(EFolderSpecified.Text, rbid);
    end;
    oldFolder := idx;
    case Folders[idx].FolderType of
      ftDefault:
        begin
          RBFolderDefault.Checked := true;
          EnableFolderSpecified(false);
        end;
      ftLast:
        begin
          RBFolderRemember.Checked := true;
          EnableFolderSpecified(false);
        end;
      ftUser:
        begin
          RBFolderSpecified.Checked := true;
          EnableFolderSpecified(true);
        end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EnableFolderSpecified(state: Boolean);
begin
  EFolderSpecified.Enabled := state;
  if not state then
    EFolderSpecified.Text := ''
  else
    EFolderSpecified.Text := Folders[cbxWindow.ItemIndex].ValueRaw;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.RBFolderDefaultClick(Sender: TObject);
begin
  EnableFolderSpecified(false);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.RBFolderRememberClick(Sender: TObject);
begin
  EnableFolderSpecified(false);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.RBFolderSpecifiedClick(Sender: TObject);
begin
  EnableFolderSpecified(true);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EFolderSpecifiedButtonClick(Sender: TObject);
var
  selectedFolder: string;
  oldValue: string;
begin
  oldValue := Folders[cbxWindow.ItemIndex].ValueRaw;
  Folders[cbxWindow.ItemIndex].SetFolder(EFolderSpecified.Text, ftUser);
  selectedFolder := Folders[cbxWindow.ItemIndex].Value; // To have the good default value
  if SelectDirectory('', '', selectedFolder) then
    EFolderSpecified.Text := selectedFolder;
  Folders[cbxWindow.ItemIndex].SetFolder(oldValue, ftUser);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBComboCatalogValuesClick(Sender: TObject);
begin
  LListEdit.Enabled := not CBComboCatalogValues.Checked;
  EComboEdit.Enabled := not CBComboCatalogValues.Checked;
  CBComboAutoAdd.Enabled := not CBComboCatalogValues.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.cbxComboSelectChange(Sender: TObject);
var
  idx: Integer;
begin
  idx := cbxComboSelect.ItemIndex;
  if oldList <> -1 then
    with Combos[oldList] do
    begin
      Contents.Assign(EComboEdit.Lines);
      AutoAdd := CBComboAutoAdd.Checked;
      Sort := CBComboSort.Checked;
      AutoComplete := CBComboAutoComplete.Checked;
      UseCatalogValues := CBComboCatalogValues.Checked;
    end;
  oldList := idx;
  if idx <> -1 then
    with Combos[idx] do
    begin
      EComboEdit.Lines.Assign(Contents);
      if not CBComboSameForAll.Checked then
      begin
        CBComboAutoAdd.Checked := AutoAdd;
        CBComboSort.Checked := Sort;
        CBComboAutoComplete.Checked := AutoComplete;
        CBComboCatalogValues.Checked := UseCatalogValues;
      end;
    end
  else
  begin
    EComboEdit.Lines.Clear;
    CBComboAutoAdd.Checked := False;
    CBComboSort.Checked := False;
    CBComboAutoComplete.Checked := False;
    CBComboCatalogValues.Checked := False;
  end;
  CBComboCatalogValuesClick(Sender);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btn1Click(Sender: TObject);
begin
  LaunchHelp;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btn3Click(Sender: TObject);
begin
  cbxWindowChange(Self);
  cbxComboSelectChange(Self);
  StoreOptions;
  ModalResult:=mrOk;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.InitFieldTags(const CustomFieldsProperties: TCustomFieldsProperties);
var
  i: Integer;
  newMenuItem : TTBXItem;
begin
  PopupFields.Items.Clear;

  for i := 0 to strFields.Count-1 do
    if not (i = fieldFormattedTitle) then
    begin
      newMenuItem := TTBXItem.Create(PopupFields);
      PopupFields.Items.Add(newMenuItem);
      with newMenuItem do
      begin
        Name := strTagFields[i];
        Caption := strFields.Strings[i] + ' (' + strTagFields[i] + ')';
        OnClick := InsertTagClick;
      end;
    end;

  if CustomFieldsProperties = nil then
    Exit;

  with CustomFieldsProperties do
    for i := 0 to Count-1 do
      if Objects[i].FieldType <> ftVirtual then
      begin
        newMenuItem := TTBXItem.Create(PopupFields);
        PopupFields.Items.Add(newMenuItem);
        with newMenuItem, Objects[i] do
        begin
          Name := FieldTag;
          Caption := FieldName + ' (' + FieldTag + ')';
          OnClick := InsertTagClick;
        end;
      end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TOptionsWin.Execute(const CustomFieldsProperties: TCustomFieldsProperties;
  const Toolbar: TTBXToolbar; const Images: TImageList; PageNumber: Integer = 0): TModalResult;
var
  i: integer;
begin
  InitFieldTags(CustomFieldsProperties);
  PicNamingFrame.LoadFromObject(Settings.rOptions.rMovieInformation.PictureNaming, CustomFieldsProperties);
  ExpFileNamingFrame.LoadFromObject(Settings.rOptions.rExport.ExpFileNaming, CustomFieldsProperties);
  LvCustomizeToolbar.Clear;
  LvCustomizeToolbar.SmallImages := Images;
  with Toolbar.Items do
    for i := 0 to Count-1 do
      with LvCustomizeToolbar.Items.Add do
      begin
        Checked := Items[i].Visible;
        ImageIndex := Items[i].ImageIndex;
        if Items[i] is TTBXSeparatorItem then
          Caption := '  ---  '
        else
          Caption := GetShortHint(Items[i].Hint);
//        Data := Items[i];
      end;
  LvCustomizeToolbar.Column[0].Width := -2;
  PageControl1.ActivePageIndex := PageNumber;
  if PageNumber > -1 then
    LvCat.Selected := LvCat.Items.Item[PageNumber]
  else
    LvCat.Selected := nil;
  Result := ShowModal;
  if Result = mrOk then
    with Toolbar.Items do
      for i := 0 to Count-1 do
        Items[i].Visible := LvCustomizeToolbar.Items.Item[i].Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.LvSearchSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  btnSearchDel.Enabled := Selected;
  btnSearchDown.Enabled := Selected;
  btnSearchUp.Enabled := Selected;
  ESearchName.Enabled := Selected;
  ESearchAddress.Enabled := Selected;
  btnInsertFieldTagURL.Enabled := Selected;
  if Selected and (Item <> nil) then
  begin
    ESearchName.Text := Item.Caption;
    ESearchAddress.Text := Item.SubItems.Strings[0];
  end else
  begin
    ESearchName.Text := '';
    ESearchAddress.Text := '';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnSearchAddClick(Sender: TObject);
begin
  with LvSearch.Items.Insert(LvSearch.ItemIndex) do
  begin
    SubItems.Add('');
    Selected := true;
    Focused := true;
    MakeVisible(False);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnSearchDelClick(Sender: TObject);
var
  idx: Integer;
begin
  with LvSearch do
    if Selected <> nil then
    begin
      idx := Selected.Index;
      DeleteSelected;
      if idx >= Items.Count then
        dec(idx);
      if idx >= 0 then
        with Items.Item[idx] do
        begin
          Selected := True;
          Focused := True;
          MakeVisible(False);
        end; // with
    end; // if
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnSearchUpClick(Sender: TObject);
begin
  MoveItems(LvSearch, True);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnSearchDownClick(Sender: TObject);
begin
  MoveItems(LvSearch, False);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.ESearchNameChange(Sender: TObject);
begin
  with LvSearch do
  begin
    if Selected <> nil then
    begin
      Selected.Caption := ESearchName.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.ESearchAddressChange(Sender: TObject);
begin
  with LvSearch do
  begin
    if Selected <> nil then
    begin
      Selected.Subitems.Strings[0] := ESearchAddress.Text;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBHistoryClick(Sender: TObject);
begin
  EHistoryFile.Enabled := CBHistory.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EHistoryFileButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirData);
  with TSaveDialog.Create(Self) do
    try
      InitialDir := strDirData;
      Filter := DialogCSVFilter;
      Options := DialogSaveOptions;
      DefaultExt := 'csv';
      FileName := ExpandFileName(EHistoryFile.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EHistoryFile.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EAutoLoadButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirCatalogs);
  with TOpenDialog.Create(Self) do
    try
      InitialDir := strDirCatalogs;
      Filter := DialogCatalogFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(EAutoLoad.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EAutoLoad.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EAutoLoadCFButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirCatalogs);
  with TOpenDialog.Create(Self) do
    try
      InitialDir := strDirCatalogs;
      Filter := DialogCatalogFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(EAutoLoadCF.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EAutoLoadCF.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EHTMLTemplateButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirTemplates);
  with TOpenDialog.Create(Self) do
    try
      InitialDir := strDirTemplates;
      Filter := DialogHTMLFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(EHTMLTemplate.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EHTMLTemplate.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EDefaultPictureButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirCatalogs);
  with TOpenDialog.Create(Self) do
    try
      InitialDir := strDirCatalogs;
      Filter := DialogImageFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(EDefaultPicture.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EDefaultPicture.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EExtraDefaultPictureButtonClick(Sender: TObject);
begin
  SetCurrentDir(strDirCatalogs);
  with TOpenDialog.Create(Self) do
    try
      InitialDir := strDirCatalogs;
      Filter := DialogImageFilter;
      Options := DialogOpenOptions;
      FileName := ExpandFileName(EExtraDefaultPicture.Text);
      if ExtractFileName(FileName) = '' then
      begin
        if DirectoryExists(FileName) then
          InitialDir := FileName;
        FileName := '';
      end;
      if InitialDir <> '' then
        ClearLastVisitedMRU(Application.ExeName);
      if Execute then
        EExtraDefaultPicture.Text := FileName;
    finally
      Free;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBProxyClick(Sender: TObject);
begin
  EProxyServer.Enabled := CBProxy.Checked;
  EProxyPort.Enabled := CBProxy.Checked;
  EProxyUsername.Enabled := CBProxy.Checked;
  EProxyPassword.Enabled := CBProxy.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBAutoLoadClick(Sender: TObject);
begin
  EAutoLoad.Enabled := CBAutoLoad.Checked and not CBAutoLoadLast.Checked;
  CBAutoLoadLast.Enabled := CBAutoLoad.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBAutoLoadCFClick(Sender: TObject);
begin
  EAutoLoadCF.Enabled := CBAutoLoadCF.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBPrefixesClick(Sender: TObject);
begin
  EPrefixes.Enabled := CBPrefixes.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBDNDSizeClick(Sender: TObject);
begin
  with CBDNDSize do
  begin
    RBDNDString.Enabled := Checked;
    RBDNDSum.Enabled := Checked;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBCopyPicturesClick(Sender: TObject);
begin
  CBCopyPicturesInPicDir.Enabled := CBCopyPictures.Checked;
  CBCopyPicturesNew.Enabled := CBCopyPictures.Checked;
  CBCopyPicturesIncExtras.Enabled := CBCopyPictures.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.LvCatChange(Sender: TObject; Node: TTreeNode);
begin
  with PageControl1 do
  begin
    if LvCat.Selected = nil then
      ActivePageIndex := 0
    else
    begin
      ActivePageIndex := LvCat.Selected.AbsoluteIndex;
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.PicImportLinkClick(Sender: TObject; LinkNumber: Integer; LinkText: String);
begin
  LvCat.Selected := LvCat.Items.Item[TabSheetPictureImport.PageIndex];
  LvCatChange(LvCat, LvCat.Selected);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBGroupMultiClick(Sender: TObject);
begin
  EGroupMultiSep.Enabled := CBGroupMulti.Checked;
  CBGroupMultiRmAllP.Enabled := CBGroupMulti.Checked;
  CBGroupMultiAddPatch.Enabled := CBGroupMulti.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBCheckboxesClick(Sender: TObject);
begin
  CBCheckboxesColor.Enabled := CBCheckboxes.Checked or CBCheckboxesInThumbs.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBCheckboxesInThumbsClick(Sender: TObject);
begin
  CBCheckboxesColor.Enabled := CBCheckboxes.Checked or CBCheckboxesInThumbs.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnDefaultExtVideoClick(Sender: TObject);
begin
  EExtVideo.Text := GetExtVideo;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.EColorTagDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  cName: string;
begin
 if odSelected in State then
   (Control as TComboBox).Canvas.Brush.Color := clHighlight
 else
   (Control as TComboBox).Canvas.Brush.Color := clWhite;

 (Control as TComboBox).Canvas.FillRect(Rect);

 cName:=IntToStr(Index);

 with (Control as TComboBox).Canvas do
 begin
  TextOut(Rect.Left + (Rect.Bottom - Rect.Top) + 4, Rect.Top + ((Rect.Bottom - Rect.Top - 13) shr 1), cname);
  Brush.Color := Settings.rOptions.rMovieList.ColorsTag[index];
  Rectangle(Rect.Left + 1, Rect.Top + 1, Rect.Left + (Rect.Bottom - Rect.Top - 1), Rect.Bottom - 1);
 end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBDNDFileNameClick(Sender: TObject);
begin
  btnFilterFileName.Enabled := CBDNDFileName.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.btnFilterFileNameClick(Sender: TObject);
var
  PrevCursor: TCursor;
begin
  PrevCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    Application.CreateForm(TStringFilterWin, StringFilterWin);
    try
      StringFilterWin.DefaultStringFilter(strFilterFileName);
      StringFilterWin.LoadStringFilter(Settings.rOptions.rMovieInformation.FilterFileName);
      if StringFilterWin.Execute then
        StringFilterWin.SaveStringFilter(Settings.rOptions.rMovieInformation.FilterFileName);
    finally
      StringFilterWin.Release;
      StringFilterWin := nil;
    end;
  finally
    Screen.Cursor := PrevCursor;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.cbxTitleSelect(Sender: TObject);
begin
  if cbxTitle.ItemIndex = 5 then
    ETitleTemplate.Enabled := True
  else
    ETitleTemplate.Enabled := False;
  LTitleTemplate.Enabled := ETitleTemplate.Enabled;
  BtnInsertFieldTag.Enabled := ETitleTemplate.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.InsertTagClick(Sender: TObject);
var
  pos: Integer;
  control: TEdit;
begin
  control := nil;
  if PageControl1.ActivePage = TabSheetTitleFormatting then
    control := ETitleTemplate
  else if PageControl1.ActivePage = TabSheetSearch then
    control := ESearchAddress;

  if control <> nil then
  begin
    pos := control.SelStart;
    if control.CanFocus then
      control.SetFocus;
    control.SelLength := 0;
    control.SelStart := pos;
    control.SelText := '[' + TTBXItem(Sender).Name + ']';
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.RBPicImportClick(Sender: TObject);
begin
  PanelPicImport.Visible := RBPicImport.Checked;
  PanelExtraPicImport.Visible := RBExtraPicImport.Checked;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBPicConvertClick(Sender: TObject);
begin
  EMaxPicSizeW.Enabled := CBPicConvert.Checked;
  EMaxPicSizeH.Enabled := EMaxPicSizeW.Enabled;
  LMaxPicSizeW.Enabled := EMaxPicSizeW.Enabled;
  LMaxPicSizeH.Enabled := EMaxPicSizeH.Enabled;
  LMaxPicSizeUnit.Enabled := EMaxPicSizeH.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TOptionsWin.CBExtraPicConvertClick(Sender: TObject);
begin
  EExtraMaxPicSizeW.Enabled := CBExtraPicConvert.Checked;
  EExtraMaxPicSizeH.Enabled := EExtraMaxPicSizeW.Enabled;
  LExtraMaxPicSizeW.Enabled := EExtraMaxPicSizeW.Enabled;
  LExtraMaxPicSizeH.Enabled := EExtraMaxPicSizeH.Enabled;
  LExtraMaxPicSizeUnit.Enabled := EExtraMaxPicSizeH.Enabled;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
