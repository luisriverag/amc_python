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

unit loan;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls,
  ImgList, ActnList, Menus, shellApi,
  
  AntStringList, ElTree, AntCorelButton, TB2Item,
  TBX, TB2Dock, TB2Toolbar,

  MovieClass, base, loanhistory, TB2ExtItems, AntAutoHintLabel, TBXExtItems;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

type
  TLoanWin = class(TBaseDlg)
    PanelMain: TPanel;
    Panel3: TPanel;
    Splitter2: TSplitter;
    Splitter1: TSplitter;
    ActionList1: TActionList;
    ActionBorrowerAdd: TAction;
    ActionBorrowerDel: TAction;
    ActionMovieGetBorrower: TAction;
    ActionCheckOut: TAction;
    ActionCheckIn: TAction;
    ActionMovieFindNext: TAction;
    TBDock1: TTBXDock;
    ToolbarLoans: TTBXToolbar;
    TBItem1: TTBXItem;
    TBItem2: TTBXItem;
    TBSeparatorItem1: TTBXSeparatorItem;
    TBSeparatorItem2: TTBXSeparatorItem;
    TBItem5: TTBXItem;
    TBPopupMenu1: TTBXPopupMenu;
    TBPopupMenu2: TTBXPopupMenu;
    TBPopupMenu3: TTBXPopupMenu;
    Findborrower1: TTBXItem;
    N1: TTBXSeparatorItem;
    Checkout1: TTBXItem;
    Addborrower1: TTBXItem;
    Deleteborrower1: TTBXItem;
    Checkin1: TTBXItem;
    Messages: TAntStringList;
    TBItem7: TTBXItem;
    LvNames: TElTree;
    LvLent: TElTree;
    LvMovies: TElTree;
    EFindValue: TEdit;
    TBControlItem1: TTBControlItem;
    ActionMovieFind: TAction;
    TBXItem5: TTBXItem;
    TBXItem6: TTBXItem;
    ActionOptions: TAction;
    ActionOptionsIncNum: TAction;
    ActionOptionsIncLab: TAction;
    TBXSubmenuItem1: TTBXSubmenuItem;
    TBXItem1: TTBXItem;
    TBXItem2: TTBXItem;
    procedure ActionBorrowerAddExecute(Sender: TObject);
    procedure ActionBorrowerDelExecute(Sender: TObject);
    procedure ActionMovieGetBorrowerExecute(Sender: TObject);
    procedure ActionCheckInExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionCheckOutExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ActionMovieFindNextExecute(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure LvMoviesResize(Sender: TObject);
    procedure LvNamesResize(Sender: TObject);
    procedure LvLentResize(Sender: TObject);
    procedure LvNamesItemSelectedChange(Sender: TObject; Item: TElTreeItem);
    procedure LvMoviesCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
    procedure LvNamesCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
    procedure LvLentCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
    procedure LvMoviesHeaderColumnResize(Sender: TObject; SectionIndex: Integer);
    procedure EFindValueKeyPress(Sender: TObject; var Key: Char);
    procedure ActionMovieFindExecute(Sender: TObject);
    procedure ActionList1Update(Action: TBasicAction; var Handled: Boolean);
    procedure ActionOptionsExecute(Sender: TObject);
    procedure EFindValueAcceptText(Sender: TObject; var NewText: String;
      var Accept: Boolean);
  private
     LastFind: string;
     MovieList: TMovieList;
     FLog: TLoanHistory;
     FFileModified: Boolean;
     procedure FillMoviesList;
     procedure FillNamesList(FixedList: TStrings);
     procedure SaveNameList(List: TStrings);
     procedure UpdateMovieItem(const AItem: TElTreeItem);
     procedure UpdateNameItem(const AItem: TElTreeItem; const Delta: Integer);
  protected
     procedure LoadOptions;override;
     procedure SaveOptions;override;
  public
    function Execute(Movies: TMovieList; const CatalogName: string; BorrowersList: TStrings; out IsFileModified: Boolean): TModalResult;
  end;

var
  LoanWin: TLoanWin;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

implementation

uses
  Math, StrUtils,

  ElHeader,

  fields, ConstValues, Global, functions_files, functions_sys,
  ProgramSettings;

{$R *.DFM}

const
  msgDelBorrower      =0;
  msgLoadingList      =1;
  msgAlreadyOut       =2;
  msgPleaseEnter      =3;
  msgAlreadyOut2      =4;
//  msg                 =5;
  msgNewText          =6;
  msgNewTitle         =7;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.FormCreate(Sender: TObject);
begin
  LastFind := '';
  ActionBorrowerAdd.ImageIndex := Ord(ICON_LOANBORROWADD);
  ActionBorrowerDel.ImageIndex := Ord(ICON_LOANBORROWDEL);
  ActionMovieGetBorrower.ImageIndex := Ord(ICON_LOANBORROWGET);
  ActionMovieFindNext.ImageIndex := Ord(ICON_LOANFIND);
  ActionCheckOut.ImageIndex := Ord(ICON_LOANCHECKOUT);
  ActionCheckIn.ImageIndex := Ord(ICON_LOANCHECKIN);
  ActionOptions.ImageIndex := Ord(ICON_LOANOPTIONS);
  inherited;
  PanelMain.Top := ToolbarLoans.Height + 1;
  PanelMain.Height := ClientHeight - 41 - ToolbarLoans.Height;
  PanelMain.Width := ClientWidth;
  LvMovies.HeaderFlat := IsThemedXP;
  LvLent.HeaderFlat := IsThemedXP;
  LvNames.HeaderFlat := IsThemedXP;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

function TLoanWin.Execute(Movies: TMovieList; const CatalogName: string; BorrowersList: TStrings; out IsFileModified: Boolean): TModalResult;
begin
  with Settings.rOptions.rFiles do
    if History then
    begin
      SetCurrentDir(strDirData);
      FLog := TLoanHistory.Create(ExpandFileName(HistoryFile), CatalogName);
    end
    else
      FLog := nil;
  FFileModified := False;
  LvLent.Items.BeginUpdate;
  try
    LvLent.Items.Clear;
  finally
    LvLent.Items.EndUpdate;
  end;
  MovieList := Movies;
  ProgressWin.Maximum := 1;
  ProgressWin.Status := Messages.Strings[msgLoadingList];
  ProgressWin.IntProgress := 0;
  ProgressWin.Execute(Self);
  try
    FillMoviesList;
    FillNamesList(BorrowersList);
    ProgressWin.IntProgress := 1;
  finally
    ProgressWin.Close;
  end;
  Result := ShowModal;
  if not Settings.rOptions.rMovieInformation.rCombo[ddlBorrowers].UseCatalogValues then
    SaveNameList(BorrowersList);
  IsFileModified := FFileModified;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.FillMoviesList;
var
  i: integer;
  NewItem: TElTreeItem;
begin
  LvMovies.Items.BeginUpdate;
  try
    LvMovies.Selected := nil;
    LvMovies.Items.Clear;
    for i := 0 to MovieList.Count-1 do
    begin
      NewItem := LvMovies.Items.Add(nil, '');
      NewItem.Data := MovieList.Items[i];
      UpdateMovieItem(NewItem);
    end;
  finally
    LvMovies.Items.EndUpdate;
  end;
  Application.ProcessMessages;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.UpdateMovieItem(const AItem: TElTreeItem);
begin
  with TMovie(AItem.Data) do
  begin
    AItem.Text := strMedia;
    AItem.SubItems.Clear;
    AItem.SubItems.Add(GetFieldValue(fieldNumber));
    AItem.SubItems.Add(GetFormattedTitle);
    AItem.SubItems.Add(strBorrower);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.FillNamesList(FixedList: TStrings);
var
  lst: TStringList;
  i, idx: Integer;
  NewItem: TElTreeItem;
begin
  lst := TStringList.Create;
  try
    lst.Sorted := True;
    LvNames.Items.BeginUpdate;
    try
      LvNames.Items.Clear;
      for i := 0 to MovieList.Count-1 do
        with TMovie(MovieList.Items[i]) do
        begin
          if (strBorrower <> '') then
          begin
            idx := lst.IndexOf(strBorrower);
            if idx = -1 then
            begin
              NewItem := LvNames.Items.Add(nil, strBorrower);
              NewItem.SubItems.Add('1');
              lst.AddObject(strBorrower, NewItem);
            end
            else
            begin
              NewItem := TElTreeItem(lst.Objects[idx]);
              UpdateNameItem(NewItem, +1);
            end;
          end;
        end;
      for i := 0 to FixedList.Count-1 do
        if lst.IndexOf(FixedList[i]) = -1 then
        begin
          LvNames.Items.Add(nil, FixedList[i]).SubItems.Add('0');
        end;
    finally
      LvNames.Items.EndUpdate;
    end;
  finally
    lst.Free;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.UpdateNameItem(const AItem: TElTreeItem; const Delta: Integer);
begin
  if Delta <> 0 then
    AItem.SubItems[0] := IntToStr(StrToIntDef(AItem.SubItems[0], 0) + Delta);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.SaveNameList(List: TStrings);
var
  i: integer;
begin
  List.Clear;
  for i := 0 to LvNames.Items.Count-1 do
  begin
    List.Add(LvNames.Items[i].Text);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LoadOptions;
  procedure SetListStyle(AList: TElTree; SortColumn: Integer);
  begin
    with AList do
    begin
      with Settings.rOptions.rMovieList do
      begin
        Tracking := HotTrack;
        UseCustomScrollBars := EnhancedScrollbars;
      end;
      if not (Abs(SortColumn) in [1..HeaderSections.Count]) then
        SortColumn := 1;
      SortSection := Abs(SortColumn) - 1;
      if SortColumn < 0 then
        HeaderSections.Item[SortSection].SortMode := hsmDescend
      else
        HeaderSections.Item[SortSection].SortMode := hsmAscend;
    end;
  end;
begin
  with Settings do
  begin
    with rLoan do
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
      LvMovies.HeaderSections.Item[1].Width := LvMoviesColWidth;
      LvMoviesHeaderColumnResize(LvMovies, 1);
      Panel3.height := LvMoviesHeight;
      LvNames.width := LvNamesWidth;
      SetListStyle(LvMovies, LvMoviesSort);
      SetListStyle(LvNames, LvNamesSort);
      SetListStyle(LvLent, LvLentSort);
      ActionOptionsIncNum.Checked := IncludeSameNum;
      ActionOptionsIncLab.Checked := IncludeSameLabel;
    end; // with rLoan
    ToolbarLoans.Images := ToolbarImages;
    if Settings.rOptions.rDisplay.ImagesInMenu then
    begin
      TBPopupMenu1.Images := ToolbarImages;
      TBPopupMenu2.Images := ToolbarImages;
      TBPopupMenu3.Images := ToolbarImages;
    end;
  end; // with Settings
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.SaveOptions;
begin
  with Settings do
  begin
    with rLoan do
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
      LvMoviesColWidth := LvMovies.HeaderSections.Item[1].Width;
      LvMoviesHeight := Panel3.height;
      LvNamesWidth := LvNames.width;
      with LvMovies do
        LvMoviesSort := (SortSection + 1) * IfThen(HeaderSections.Item[SortSection].SortMode = hsmDescend, -1, 1);
      with LvNames do
        LvNamesSort := (SortSection + 1) * IfThen(HeaderSections.Item[SortSection].SortMode = hsmDescend, -1, 1);
      with LvLent do
        LvLentSort := (SortSection + 1) * IfThen(HeaderSections.Item[SortSection].SortMode = hsmDescend, -1, 1);
      IncludeSameNum := ActionOptionsIncNum.Checked;
      IncludeSameLabel := ActionOptionsIncLab.Checked;
    end ; // with rLoan;
  end; // with Settings;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionBorrowerAddExecute(Sender: TObject);
var
  NewItem: TElTreeItem;
  NewName: string;
begin
  NewName := '';
  if InputWin.Execute(Messages.Strings[msgNewTitle], Messages.Strings[msgNewText], NewName) then
  begin
    if NewName = '' then
    begin
      MessageWin.Execute(Messages.Strings[msgPleaseEnter],mtWarning,[mbOk]);
      ActionBorrowerAdd.Execute;
    end else
    begin
      NewItem := LvNames.Items.LookForItem(nil, NewName, nil, 0, False, True, False, False, True);
      if NewItem = nil then
      begin
        NewItem := LvNames.Items.Add(nil, NewName);
        NewItem.SubItems.Add('0');
      end;
      LvNames.Selected := NewItem;
      LvNames.EnsureVisible(NewItem);
    end;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionBorrowerDelExecute(Sender: TObject);
var
  i: integer;
  deletedBorrower: string;
begin
  if LvNames.Selected <> nil then
  begin
    deletedBorrower := LvNames.Selected.Text;
    if MessageWin.Execute(Format(Messages.Strings[msgDelBorrower],[deletedBorrower]),
        mtWarning, [mbOk, mbCancel]) = 1 then
    begin
      LvNames.Selected.Delete;
      with LvMovies.Items do
      begin
        BeginUpdate;
        try
          for i := 0 to Count-1 do
            with TMovie(Item[i].Data) do
              if strBorrower = deletedBorrower then
              begin
                strBorrower := '';
                UpdateMovieItem(LvMovies.Items[i]);
              end;
        finally
          EndUpdate;
        end; // try
      end; // with lvmovies
    end; // message
  end; // if selected <> nil
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionMovieGetBorrowerExecute(Sender: TObject);
var
  Found: TElTreeItem;
begin
  if LvMovies.Selected <> nil then
  begin
    Found := LvNames.Items.LookForItem(nil, TMovie(LvMovies.Selected.Data).strBorrower, nil, 0, False, True, False, False, True);
    LvNames.Selected := Found;
    LvNames.EnsureVisible(Found);
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionCheckOutExecute(Sender: TObject);
var
  CurItem, NewItem: TElTreeItem;
  CurMovie, OtherMovie: TMovie;
  NewBorrower: string;
  AlreadyOut: TStringList;
  i, MoviesOut: Integer;
  procedure LoanMovie(AMovie: TMovie; AItem: TElTreeItem);
  begin
    AMovie.strBorrower := NewBorrower;
    UpdateMovieItem(AItem);
    Inc(MoviesOut);
    NewItem := LvLent.Items.Add(nil, AMovie.strMedia);
    NewItem.SubItems.Add(AMovie.GetFieldValue(fieldNumber));
    NewItem.SubItems.Add(AMovie.GetFormattedTitle);
    NewItem.Data := AMovie;
    if FLog <> nil then
      with AMovie do
        FLog.Add(NewBorrower, iNumber, strMedia, GetFormattedTitle, lhOut);
  end;
begin
  if (LvMovies.SelectedCount = 0) or (LvNames.Selected = nil) then
    Exit;
  NewBorrower := LvNames.selected.Text;
  with TMovie(LvMovies.Selected.Data) do
    if (strBorrower <> '') and (strBorrower <> NewBorrower) then
    begin
      MessageWin.Execute(Messages.Strings[msgAlreadyOut], mtError, [mbOk]);
      Exit;
    end;
  MoviesOut := 0;
  AlreadyOut := TStringList.Create;
  LvMovies.Items.BeginUpdate;
  LvLent.Items.BeginUpdate;
  try
    CurItem := LvMovies.GetNextSelected(nil);
    while CurItem <> nil do
    begin
      CurMovie := TMovie(CurItem.Data);
      if (CurMovie.strBorrower = '') or (CurMovie.strBorrower = NewBorrower) then
      begin
        if CurMovie.strBorrower = '' then
          LoanMovie(CurMovie, CurItem);
        if ActionOptionsIncNum.Checked or ActionOptionsIncLab.Checked then
        begin
          for i := 0 to LvMovies.Items.Count-1 do
            if not LvMovies.Items[i].Selected then
            begin
              OtherMovie := TMovie(LvMovies.Items[i].Data);
              if (ActionOptionsIncNum.Checked and (OtherMovie.iNumber = CurMovie.iNumber))
                or (ActionOptionsIncLab.Checked and (OtherMovie.strMedia = CurMovie.strMedia)) then
              begin
                if OtherMovie.strBorrower = '' then
                  LoanMovie(OtherMovie, LvMovies.Items[i])
                else
                  if OtherMovie.strBorrower <> NewBorrower then
                    AlreadyOut.Add(Format('%d. %s', [OtherMovie.iNumber, OtherMovie.GetFormattedTitle]));
              end;
            end;
        end;
      end
      else
        AlreadyOut.Add(Format('%d. %s', [CurMovie.iNumber, CurMovie.GetFormattedTitle]));
      CurItem := LvMovies.GetNextSelected(CurItem);
    end;
    if AlreadyOut.Count > 0 then
      MessageWin.Execute(Messages.Strings[msgAlreadyOut2] + sLineBreak + AlreadyOut.Text, mtWarning, [mbOk]);
  finally
    AlreadyOut.Free;
    LvMovies.Items.EndUpdate;
    LvLent.Items.EndUpdate;
  end;
  UpdateNameItem(LvNames.Selected, MoviesOut);
  if MoviesOut > 0 then
    FFileModified := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionCheckInExecute(Sender: TObject);
var
  CurItem: TElTreeItem;
  CurMovie, OtherMovie: TMovie;
  i, MoviesIn: Integer;
begin
  if (LvLent.SelectedCount = 0) or (LvNames.Selected = nil) then
    Exit;
  MoviesIn := 0;
  CurItem := LvLent.GetNextSelected(nil);
  while CurItem <> nil do
  begin
    CurMovie := TMovie(CurItem.Data);
    CurMovie.strBorrower := '';
    if FLog <> nil then
      with CurMovie do
        FLog.Add(LvNames.Selected.Text, iNumber, strMedia, GetFormattedTitle, lhIn);
    Inc(MoviesIn);
    if ActionOptionsIncNum.Checked or ActionOptionsIncLab.Checked then
    begin
      for i := 0 to LvLent.Items.Count-1 do
        if not LvLent.Items[i].Selected then
        begin
          OtherMovie := TMovie(LvLent.Items[i].Data);
          if (ActionOptionsIncNum.Checked and (OtherMovie.iNumber = CurMovie.iNumber))
            or (ActionOptionsIncLab.Checked and (OtherMovie.strMedia = CurMovie.strMedia)) then
          begin
            OtherMovie.strBorrower := '';
            if FLog <> nil then
              with OtherMovie do
                FLog.Add(LvNames.Selected.Text, iNumber, strMedia, GetFormattedTitle, lhIn);
            Inc(MoviesIn);
          end;
        end;
    end;
    CurItem := LvLent.GetNextSelected(CurItem);
  end;
  LvNamesItemSelectedChange(LvNames, LvNames.Selected);
  UpdateNameItem(LvNames.Selected, -MoviesIn);
  if MoviesIn > 0 then
  begin
    FillMoviesList;
    FFileModified := True;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionMovieFindExecute(Sender: TObject);
begin
  EFindValue.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionMovieFindNextExecute(Sender: TObject);
var
  Idx, StartIdx: Integer;
  Finished: Boolean;
  Value: string;
begin
  with LvMovies do
    if Items.Count > 1 then
    begin
      Value := EFindValue.Text;
      if Selected = nil then
      begin
        StartIdx := 0;
        Idx := 0;
      end else
      begin
        StartIdx := Selected.AbsoluteIndex;
        Idx := StartIdx + 1;
      end;
      Finished := False;
      with Items do
      begin
        if Idx = Count then
          Idx := 0;
        repeat
          if (Item[Idx] <> nil) then
            if AnsiContainsText(Item[Idx].SubItems[1], Value) then
            begin
              Finished := True;
              DeselectAll;
              ItemFocused := Item[Idx];
              Item[Idx].Selected := True;
              EnsureVisible(Item[Idx]);
            end;
          inc(Idx);
          if Idx = Count then
            Idx := 0;
        until (StartIdx = Idx) or (Finished);
      end;
    end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.FormShow(Sender: TObject);
begin
  inherited;
  btn2.SetFocus;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.btn1Click(Sender: TObject);
begin
  LaunchHelp;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.FormDestroy(Sender: TObject);
begin
  FLog.Free;
  inherited;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvMoviesResize(Sender: TObject);
begin
  with Sender as TElTree do
    HeaderSections.Item[2].Width := ClientWidth - (HeaderSections.Item[0].Width + HeaderSections.Item[1].Width + HeaderSections.Item[3].Width) - IfThen(VertScrollBarVisible and Settings.rOptions.rMovieList.EnhancedScrollbars, VertScrollBarStyles.Width);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvMoviesHeaderColumnResize(Sender: TObject; SectionIndex: Integer);
begin
  with Sender as TElTree do
    HeaderSections.Item[2].Width := ClientWidth - (HeaderSections.Item[0].Width + HeaderSections.Item[1].Width + HeaderSections.Item[3].Width) - IfThen(VertScrollBarVisible and Settings.rOptions.rMovieList.EnhancedScrollbars, VertScrollBarStyles.Width);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvNamesResize(Sender: TObject);
begin
  with Sender as TElTree do
    HeaderSections.Item[0].Width := ClientWidth - HeaderSections.Item[1].Width - IfThen(VertScrollBarVisible and Settings.rOptions.rMovieList.EnhancedScrollbars, VertScrollBarStyles.Width);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvLentResize(Sender: TObject);
begin
  with Sender as TElTree do
    HeaderSections.Item[2].Width := ClientWidth - HeaderSections.Item[0].Width - HeaderSections.Item[1].Width - IfThen(VertScrollBarVisible and Settings.rOptions.rMovieList.EnhancedScrollbars, VertScrollBarStyles.Width);
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvNamesItemSelectedChange(Sender: TObject; Item: TElTreeItem);
var
  CurrentName: string;
  i: integer;
  NewItem: TElTreeItem;
begin
  LvLent.Items.BeginUpdate;
  try
    LvLent.Items.Clear;
    if Item <> nil then
    begin
      if Item.Selected then
      begin
        CurrentName := Item.Text;
          for i := 0 to LvMovies.Items.Count-1 do
            with TMovie(LvMovies.Items[i].Data) do
              if AnsiCompareText(strBorrower, CurrentName) = 0 then
              begin
                NewItem := LvLent.Items.Add(nil, strMedia);
                NewItem.SubItems.Add(GetFieldValue(fieldNumber));
                NewItem.SubItems.Add(GetFormattedTitle);
                NewItem.Data := LvMovies.Items[i].Data;
              end;
      end;
    end;
  finally
    LvLent.Items.EndUpdate;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvMoviesCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
  procedure CompareOtherCols(const Col: Integer);
  begin
    if (res = 0) and (Col <> 0) then
      res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
    if (res = 0) and (Col <> 1) then
      res := AnsiCompareText(Item1.Text, Item2.Text);
    if (res = 0) and (Col <> 2) then
      res := AnsiCompareText(Item1.SubItems.Strings[1], Item2.SubItems.Strings[1]);
    if (res = 0) and (Col <> 3) then
      res := AnsiCompareText(Item1.SubItems.Strings[2], Item2.SubItems.Strings[2]);
  end;
begin
  case LvMovies.SortSection of
    0:  res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
    1:  res := AnsiCompareText(Item1.Text, Item2.Text);
    2:  res := AnsiCompareText(Item1.SubItems.Strings[1], Item2.SubItems.Strings[1]);
    3:  res := AnsiCompareText(Item1.SubItems.Strings[2], Item2.SubItems.Strings[2]);
  end;
  if res = 0 then
    CompareOtherCols(LvMovies.SortSection);
  if res = 0 then
    res := Item1.Index - Item2.Index;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvNamesCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
begin
  if LvNames.SortSection = 1 then
  begin
    res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
    if res = 0 then
      res := AnsiCompareText(Item1.Text, Item2.Text);
  end
  else
  begin
    res := AnsiCompareText(Item1.Text, Item2.Text);
    if res = 0 then
      res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
  end;
  if res = 0 then
    res := Item1.Index - Item2.Index;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.LvLentCompareItems(Sender: TObject; Item1, Item2: TElTreeItem; var res: Integer);
  procedure CompareOtherCols(const Col: Integer);
  begin
    if (res = 0) and (Col <> 0) then
      res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
    if (res = 0) and (Col <> 1) then
      res := AnsiCompareText(Item1.Text, Item2.Text);
    if (res = 0) and (Col <> 2) then
      res := AnsiCompareText(Item1.SubItems.Strings[1], Item2.SubItems.Strings[1]);
  end;
begin
  case LvLent.SortSection of
    0:  res := StrToInt(Item1.SubItems.Strings[0]) - StrToInt(Item2.SubItems.Strings[0]);
    1:  res := AnsiCompareText(Item1.Text, Item2.Text);
    2:  res := AnsiCompareText(Item1.SubItems.Strings[1], Item2.SubItems.Strings[1]);
  end;
  if res = 0 then
    CompareOtherCols(LvLent.SortSection);
  if res = 0 then
    res := Item1.Index - Item2.Index;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.EFindValueKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = Char(VK_RETURN) then
  begin
    ActionMovieFindNextExecute(Sender);
    Key := #0;
  end;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionList1Update(Action: TBasicAction; var Handled: Boolean);
begin
  if Action = ActionBorrowerDel then
  begin
    (Action as TAction).Enabled := LvNames.Selected <> nil;
    Handled := True;
  end
  else
  if Action = ActionMovieGetBorrower then
  begin
    (Action as TAction).Enabled := (LvMovies.Selected <> nil) and (TMovie(LvMovies.Selected.Data).strBorrower <> '');
    Handled := True;
  end
  else
  if Action = ActionCheckOut then
  begin
    (Action as TAction).Enabled := (LvMovies.SelectedCount > 0) and (LvNames.Selected <> nil) ; // and (TMovie(LvMovies.Selected.Data).strBorrower = '');
    Handled := True;
  end
  else
  if Action = ActionCheckIn then
  begin
    (Action as TAction).Enabled := (LvLent.SelectedCount > 0);
    Handled := True;
  end
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.ActionOptionsExecute(Sender: TObject);
begin
  //
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

procedure TLoanWin.EFindValueAcceptText(Sender: TObject; var NewText: String; var Accept: Boolean);
begin
  ActionMovieFindNext.Execute;
  Accept := True;
end;

{-------------------------------------------------------------------------------
-------------------------------------------------------------------------------}

end.
