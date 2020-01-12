(**

  This module contains the main form interface for the application which is design to allow a user
  tp search for Open Tools API (OTA) classes and interfaces / methods and properties across multiple
  search directories.

  @Author  David Hoyle
  @Version 1.0
  @Date    12 Jan 2020

  @license

    OTA Interface Search is a RAD Studio application for searching the RAD Studio
    Open Tools API source (not included) for properties and methods to expose the
    required interfaces / methods / properties and provide (if possible) the path
    through the OTA in order to use the interface / method / property.
    
    Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/OTA-Interface-Search)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

**)
Unit OTAIntfSearch.MainForm;

Interface

Uses
  System.Classes,
  System.ImageList,
  System.RegularExpressions,
  System.Win.TaskbarCore,
  System.UITypes,
  System.Generics.Collections,
  VCL.Forms,
  VCL.Dialogs,
  VCL.StdCtrls,
  VCL.ComCtrls,
  VCL.ExtCtrls,
  VCL.Buttons,
  VCL.Controls,
  VCL.Graphics,
  Vcl.Taskbar,
  Vcl.ImgList, 
  WinAPI.Windows,
  WinAPI.Messages,
  VirtualTrees,
  SynEdit,
  SynEditCodeFolding,
  SynEditHighlighter,
  SynHighlighterPas,
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.Types,
  OTAIntfSearch.UIUpdater,
  OTAIntfSearch.CustomVirtualStringTree,
  OTAIntfSearch.OptionsForm, System.Actions, Vcl.ActnList;

Type
  (** A class to represent the form interface. **)
  TfrmOTAIntfSearch = Class(TForm)
    pgcPageControl: TPageControl;
    tabInterfaces: TTabSheet;
    edtFilter: TEdit;
    tabToolsAPIFiles: TTabSheet;
    pnlButtons: TPanel;
    btnAdd: TBitBtn;
    btnDelete: TBitBtn;
    ilInterfaces: TImageList;
    stbrStatusBar: TStatusBar;
    btnEdit: TBitBtn;
    tbrTaskbar: TTaskbar;
    pagViews: TPageControl;
    splViews: TSplitter;
    tabCodeView: TTabSheet;
    synPascal: TSynPasSyn;
    tabCreationPaths: TTabSheet;
    tmTimer: TTimer;
    pnlPath: TPanel;
    lblPath: TLabel;
    splPaths: TSplitter;
    grdPanel: TGridPanel;
    edtTargetSearch: TEdit;
    lblInterfaceMethodFilter: TLabel;
    lblTargetSearchFilter: TLabel;
    btnDown: TBitBtn;
    btnUp: TBitBtn;
    vstFilePaths: TVirtualStringTree;
    CodeView: TSynEdit;
    alAppActions: TActionList;
    actFileExit: TAction;
    actToolsTestEurekalog: TAction;
    procedure actFileExitExecute(Sender: TObject);
    procedure actToolsTestEurekalogExecute(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure btnAddClick(Sender: TObject);
    Procedure btnDeleteClick(Sender: TObject);
    Procedure edtFilterChange(Sender: TObject);
    Procedure vstInterfacesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);
    Procedure vstInterfacesAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    Procedure vstInterfacesPaintText(Sender: TBaseVirtualTree; Const TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    Procedure vstInterfacesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);
    Procedure vstInterfacesGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; Var LineBreakStyle: TVTTooltipLineBreakStyle; Var HintText: String);
    Procedure vstInterfacesKeyPress(Sender: TObject; Var Key: Char);
    Procedure OTACodeTreeKeyPress(Sender: TObject; Var Key: Char);
    Procedure btnEditClick(Sender: TObject);
    Procedure stbrStatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; Const Rect: TRect);
    Procedure vstInterfacesClick(Sender: TObject);
    Procedure OTACodeTreeClick(Sender: TObject);
    Procedure tmTimerEvent(Sender: TObject);
    Procedure pagViewsChange(Sender: TObject);
    procedure edtTargetSearchChange(Sender: TObject);
    procedure vstFilePathsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode; Column: TColumnIndex;
      TextType: TVSTTextType; var CellText: string);
    procedure vstFilePathsNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure btnDownClick(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure vstFilePathsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  Strict Private
    Type
      (** A record to describe the information in the File Path List collection. **)
      TOISFilePathListRec = Record
        FFilePath : String;
        FChecked : Boolean;
        Constructor Create(Const strFilePath : String; Const boolChecked : Boolean);
      End;
      (** A record to describe the information stored in the File path List treeview. @nohints **)
      TOISFilePathTreeNode = Record
        FFilePathListIndex : Integer;
      End;
      (** A pointer to the above record. **)
      POISFilePathTreeNode = ^TOISFilePathTreeNode;
    Const
      (** Menu index for the Options menu in the System Menu. **)
      iOptionsMenuID = 170;
      (** Menu index for the About menu in the System Menu. **)
      iAboutMenuID = 171;
  Strict Private
    Const
      (** a constant to define the time period after typing a reg ex search before the treeview is
          filtered. **)
      iUpdateDelayInterval = 500;
  Strict Private
    FIniFile                     : IOISINIFile;
    FToolsAPIFiles               : IOISToolsAPIFiles;
    FUIUpdater                   : IOISInterfacesUIUpdater;
    FFileParser                  : IOISFileParser;
    FProgressManager             : IOISProgressManager;
    FInterfacesTree              : TVirtualStringTree;
    FOTACodeTree                 : TVirtualStringTree;
    FFiltering                   : Boolean;
    FTargeting                   : Boolean;
    FSearchRegEx                 : TRegEx;
    FTargetSearchRegEx           : TRegEx;
    FInterfaceRegEx              : TRegEx;
    FProcedureRegEx              : TRegEx;
    FFunctionRegEx               : TRegEx;
    FPropertyRegEx               : TRegEx;
    FSearchLastEdited            : Int64;
    FTargetLastEdited            : Int64;
    FHasDoneInitialParseAndFilter: Boolean;
    FFilePathList                : TList<TOISFilePathListRec>;  
    FPopulating                  : Boolean;
    FSearching                   : Boolean;
    FGenOTACode                  : IOISGenerateOTACode;
    FSysOptionsMenuInstalled     : Boolean;
    FOptions                     : IOISOTAOptions;
  Strict Protected
    Procedure CreateCustomInterfaceStringTree;
    Procedure CreateCustomOTACodeStringTree;
    Procedure CreateDependencies;
    Procedure CreateCachedRegExs;
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure FilterChanged;
    Procedure GenerateOTACode(Const NodeData: PTreeData);
    Procedure UpdateFormTitle;
    Procedure ParseFilesAndFilter;
    Function  FilterInterfaceTreeView(Const N : PVirtualNode) : Integer;
    Procedure ValidRegEx(Const RegExControl: TEdit);
    Procedure PopulateFilePathList;
    Procedure ParseTargetSearch;
    Procedure AddSystemMenu;
    Procedure WMSysCommand(Var Message : TWMSysCommand); Message WM_SYSCOMMAND;
    Procedure ApplyTheming;
  Public
  End;

Var
  (** A global variable managed by Delphi for the main form to be created at startup. **)
  frmOTAIntfSearch: TfrmOTAIntfSearch;

Implementation

{$R *.DFM}


Uses
  CodeSiteLogging,
  {$IFDEF EurekaLog}
  EBase,
  {$ENDIF}
  System.SysUtils,
  System.RegularExpressionsCore,
  System.Types,
  VCL.Themes,
  OTAIntfSearch.MemIniFile,
  OTAIntfSearch.ToolsAPIFiles,
  OTAIntfSearch.BrowseFolderForm,
  OTAIntfSearch.FileParser,
  OTAIntfSearch.ProgressManager,
  OTAIntfSearch.GenerateOTACode,
  OTAIntfSearch.Constants,
  OTAIntfSearch.Functions,
  OTAIntfSearch.Options,
  OTAIntfSearch.AboutDlg;

Const
  (** A constant for the ini section for storing general settings. **)
  strSetupINISection = 'Setup';
  (** An ini key for the top of the main window. **)
  strTopKey = 'Top';
  (** An ini key for the left of the main window. **)
  strLeftKey = 'Left';
  (** An ini key for the height of the main window. **)
  strHeightKey = 'Height';
  (** An ini key for the width of the main window. **)
  strWidthKey = 'Width';
  (** An ini key for FilterText **)
  strFilterTextKey = 'FilterText';
  (** An ini key for TargetText **)
  strTargetSearchKey = 'TargetSearch';
  (** An ini key for Active View Index **)
  strActiveViewIndexKey = 'ActiveViewIndex';
  (** An ini key for Code height **)
  strCodeHeightKey = 'CodeHeight';
  (** An ini key for Path Height **)
  strPathsHeightKey = 'PathsHeight';
  (** An ini section for the file/fodlers to search **)
  strToolsAPIFilesINISection = 'ToolsAPI Files';
  (** A INI Section name for the check status of the TOols API files / paths **)
  strToolsAPIFilesCheckINISection = 'ToolsAPI Files Check Status';

(**

  A constructor for the TOISFilePathListRec record.

  @precon  None.
  @postcon Initialises the record.

  @param   strFilePath as a String as a constant
  @param   boolChecked as a Boolean as a constant

**)
Constructor TfrmOTAIntfSearch.TOISFilePathListRec.Create(Const strFilePath: String;
  Const boolChecked: Boolean);
  
Begin
  FFilePath := strFilePath;
  FChecked := boolChecked;
End;

(**

  This is an on execute event handler for the File Exit action.

  @precon  None.
  @postcon Closes the application.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.actFileExitExecute(Sender: TObject);

Begin
  Close;
End;

(**

  This is an on execute event handler for the Test Eurekalog action.

  @precon  None.
  @postcon Displays the status of Eurekalog and optionsal raises a test exception.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.actToolsTestEurekalogExecute(Sender: TObject);

ResourceString
  strMsg =
    'EurekaLog Installed: %s'#13#10 +
    'EurekaLog Activated: %s'#13#10 +
    #13#10 +
    'Are you sure you want to generate a test exception?';
  strThisTestException = 'This is a test Exception which should be intercepted by EurekaLog!';

Const
  astrYesNo : Array[False..True] Of String = ('No', 'Yes');
  
Begin
  {$IFDEF EurekaLog}
  If MessageDlg(
    Format(strMsg, [
      astrYesNo[IsEurekaLogInstalled],
      astrYesNo[IsEurekaLogActive]
    ]), mtConfirmation, [mbYes, mbNo], 0) = mrYes Then
    Raise Exception.Create(strThisTestException);
  {$ENDIF EurekaLog}
End;

(**

  This method adds the custom menus to the system menu.

  @precon  None.
  @postcon The custom menu items are added to the system menu.

**)
Procedure TfrmOTAIntfSearch.AddSystemMenu;

ResourceString
  strOptionsMenuCaption = '&Options...';
  strAboutMenuCaption = '&About...';

Var
  SysMenu : HMENU;

Begin
  SysMenu := GetSystemMenu(Handle, False);
  AppendMenu(SysMenu, MF_SEPARATOR, 0, '');
  AppendMenu(SysMenu, MF_STRING, iOptionsMenuID, PChar(strOptionsMenuCaption));
  AppendMenu(SysMenu, MF_STRING, iAboutMenuID, PChar(strAboutMenuCaption));
  FSysOptionsMenuInstalled := True;
End;

(**

  This method apply the theming and application options to the application, treeviews, code editor and
  syntax highlighter.

  @precon  None.
  @postcon The application and the custom controls are themed.

**)
Procedure TfrmOTAIntfSearch.ApplyTheming;

Const
  iPadding = 1;
  strTextHeightTest = 'Wg';

Begin
  If FOptions.VCLTheme <> StyleServices.Name Then
    Begin
      TStyleManager.TrySetStyle(FOptions.VCLTheme);
      FSysOptionsMenuInstalled := False;
    End;
  FInterfacesTree.Font.Name := FOptions.TreeFontName;
  FInterfacesTree.Font.Size := FOptions.TreeFontSize;
  FInterfacesTree.Canvas.Font.Name := FOptions.TreeFontName;
  FInterfacesTree.Canvas.Font.Size := FOptions.TreeFontSize;
  FInterfacesTree.DefaultNodeHeight := iPadding + FInterfacesTree.Canvas.TextHeight(strTextHeightTest) +
    iPadding;
  FInterfacesTree.Invalidate;
  FOTACodeTree.Font.Name := FOptions.TreeFontName;
  FOTACodeTree.Font.Size := FOptions.TreeFontSize;
  FOTACodeTree.Canvas.Font.Name := FOptions.TreeFontName;
  FOTACodeTree.Canvas.Font.Size := FOptions.TreeFontSize;
  FOTACodeTree.DefaultNodeHeight := iPadding + FOTACodeTree.Canvas.TextHeight(strTextHeightTest) +
    iPadding;
  FOTACodeTree.Invalidate;
  CodeView.Color := StyleServices.GetSystemColor(clWindow);
  CodeView.Font.Color := StyleServices.GetSystemColor(clWindowText);
  CodeView.ActiveLineColor := StyleServices.GetSystemColor(FOptions.Colour[ocCurrentLineHighlight]);
  CodeView.Gutter.BorderColor := StyleServices.GetSystemColor(clWindow);
  CodeView.Gutter.Color := StyleServices.GetSystemColor(clBtnFace);
  CodeView.Gutter.Font.Color := StyleServices.GetSystemColor(clWindowText);
  CodeView.Gutter.GradientStartColor := StyleServices.GetSystemColor(clBtnFace);
  CodeView.Gutter.GradientEndColor := StyleServices.GetSystemColor(clWindow);
  CodeView.Font.Name := FOptions.EditorFontName;
  CodeView.Font.Size := FOptions.EditorFontSize;
  synPascal.AsmAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocAssembler]);
  synPascal.CharAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocCharacter]);
  synPascal.CommentAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocComment]);
  synPascal.DirectiveAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocDirective]);
  synPascal.FloatAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocNumber]);
  synPascal.HexAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocNumber]);
  synPascal.IdentifierAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocIdentifier]);
  synPascal.KeyAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocReservedWord]);
  synPascal.NumberAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocNumber]);
  synPascal.StringAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocString]);
  synPascal.SymbolAttri.Foreground := StyleServices.GetSystemColor(FOptions.Colour[ocSymbol]);
End;

(**

  This method is an on click event handler for the Add button.

  @precon  None.
  @postcon Displays a form for browsing / editing the search path and if confirmed adds the search
           path to the files listbox.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.btnAddClick(Sender: TObject);

Var
  strSearchPath: String;

Begin
  If TfrmBrowseFolder.Execute(Self, strSearchPath) Then
    Begin
      FFilePathList.Add(TOISFilePathListRec.Create(strSearchPath, True));
      PopulateFilePathList;
      ParseFilesAndFilter;
    End;
End;

(**

  This is an on click even handler for the Delete button.

  @precon  None.
  @postcon If an item in the file listbox is selected the item is deleted.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.btnDeleteClick(Sender: TObject);

Var
  NodeData : POISFilePathTreeNode;
  
Begin
  NodeData := vstFilePaths.GetNodeData(vstFilePaths.FocusedNode);
  FFilePathList.Delete(NodeData.FFilePathListIndex);
  PopulateFilePathList;
  ParseFilesAndFilter;
End;

(**

  This is an on click event handler for the Down button.

  @precon  None.
  @postcon Moves the selected file path down the list.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.btnDownClick(Sender: TObject);

Var
  NodeData : POISFilePathTreeNode;
  HitInfo: THitInfo;
  
Begin
  NodeData := vstFilePaths.GetNodeData(vstFilePaths.FocusedNode);
  FFilePathList.Exchange(NodeData.FFilePathListIndex, Succ(NodeData.FFilePathListIndex));
  vstFilePaths.FocusedNode := vstFilePaths.GetNext(vstFilePaths.FocusedNode);
  PopulateFilePathList;
  vstFilePathsNodeClick(Nil, HitInfo);
End;

(**

  This is an on click event handler for the Edit button.

  @precon  None.
  @postcon If an item is selected in the listbox a dialogue is displayed allowing the user to browse
           and edit the saerch path and if the dialogue is confirmed the selected item in the
           listbox is updated.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.btnEditClick(Sender: TObject);

Var
  R : TOISFilePathListRec;
  NodeData : POISFilePathTreeNode;

Begin
  NodeData := vstFilePaths.GetNodeData(vstFilePaths.FocusedNode);
  R := FFilePathList[NodeData.FFilePathListIndex];
  If TfrmBrowseFolder.Execute(Self, R.FFilePath) Then
    Begin
      FFilePathList[NodeData.FFilePathListIndex] := R;
      PopulateFilePathList;
      ParseFilesAndFilter;
    End;
End;

(**

  This is an on click event handler for the Up button.

  @precon  None.
  @postcon Moves the selected file path up the list.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.btnUpClick(Sender: TObject);

Var
  NodeData : POISFilePathTreeNode;
  HitInfo: THitInfo;
  
Begin
  NodeData := vstFilePaths.GetNodeData(vstFilePaths.FocusedNode);
  FFilePathList.Exchange(NodeData.FFilePathListIndex, Pred(NodeData.FFilePathListIndex));
  vstFilePaths.FocusedNode := vstFilePaths.GetPrevious(vstFilePaths.FocusedNode);
  PopulateFilePathList;
  vstFilePathsNodeClick(Nil, HitInfo);
End;

(**

  This method creates a number of cached regular expressions (they perform better this way as they
  are compiled) for use in the application.

  @precon  None.
  @postcon The cached regular expressions are created.

**)
Procedure TfrmOTAIntfSearch.CreateCachedRegExs;

Begin
  FInterfaceRegEx := TRegEx.Create(strInterfaceRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
  FProcedureRegEx := TRegEx.Create(strProcedureStartRegEx,
    [roIgnoreCase, roCompiled, roSingleLine]);
  FFunctionRegEx := TRegEx.Create(strFunctionStartRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
  FPropertyRegEx := TRegEx.Create(strPropertyStartRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
End;

(**

  This method creates the custom virtual treeview and adds it to the appropriate tab and hooks
  all the event handlers.

  @precon  None.
  @postcon This virtual treeview is created and added to the interface.

**)
Procedure TfrmOTAIntfSearch.CreateCustomInterfaceStringTree;

Begin
  FInterfacesTree := TOISVirtualStringTree.Create(Self);
  FInterfacesTree.Parent := tabInterfaces;
  FInterfacesTree.Align := alClient;
  FInterfacesTree.AlignWithMargins := True;
  FInterfacesTree.Images := ilInterfaces;
  FInterfacesTree.OnAfterCellPaint := vstInterfacesAfterCellPaint;
  FInterfacesTree.OnClick := vstInterfacesClick;
  FInterfacesTree.OnGetText := vstInterfacesGetText;
  FInterfacesTree.OnPaintText := vstInterfacesPaintText;
  FInterfacesTree.OnGetImageIndex := vstInterfacesGetImageIndex;
  FInterfacesTree.OnGetHint := vstInterfacesGetHint;
  FInterfacesTree.OnKeyPress := vstInterfacesKeyPress;
  FInterfacesTree.NodeDataSize := SizeOf(TTreeData);
  FInterfacesTree.TabOrder := 1;
End;

(**

  This method creates the OTACodeTree.

  @precon  None.
  @postcon The OTACodeTree is created and inserted into the interface.

**)
Procedure TfrmOTAIntfSearch.CreateCustomOTACodeStringTree;

Begin
  FOTACodeTree := TOISVirtualStringTree.Create(Self);
  FOTACodeTree.Parent := tabCreationPaths;
  FOTACodeTree.Align := alClient;
  FOTACodeTree.AlignWithMargins := True;
  FOTACodeTree.Images := ilInterfaces;
  FOTACodeTree.OnClick := OTACodeTreeClick;
  FOTACodeTree.OnAfterCellPaint := vstInterfacesAfterCellPaint;
  FOTACodeTree.OnGetText := vstInterfacesGetText;
  FOTACodeTree.OnPaintText := vstInterfacesPaintText;
  FOTACodeTree.OnGetImageIndex := vstInterfacesGetImageIndex;
  FOTACodeTree.OnGetHint := vstInterfacesGetHint;
  FOTACodeTree.OnKeyPress := OTACodeTreeKeyPress;
  FOTACodeTree.NodeDataSize := SizeOf(TTreeData);
End;

(**

  This method creates all the coding dependencies (interfaced objects).

  @precon  None.
  @postcon All the interfaced objects are constructed and available.

**)
Procedure TfrmOTAIntfSearch.CreateDependencies;

Begin
  FIniFile := TOISMemIniFile.Create;
  FToolsAPIFiles := TOISToolsAPIFiles.Create;
  FUIUpdater := TOISUIUpdater.Create(FInterfacesTree, stbrStatusBar);
  FProgressManager := TOISProgressManager.Create(Self, tbrTaskbar);
  FFileParser := TOISFileParser.Create(FToolsAPIFiles, FUIUpdater, FProgressManager);
End;

(**

  This is an on change event handler for the Filter edit control

  @precon  None.
  @postcon This method updates the last time the filter was edited with the current tick count.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.edtFilterChange(Sender: TObject);

Begin
  FSearchLastEdited := GetTickCount;
  ValidRegEx(edtFilter);
End;

(**

  This is an on change event handler for the Target Search edit control

  @precon  None.
  @postcon This method updates the last time the target search was edited with the current tick
           count.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.edtTargetSearchChange(Sender: TObject);

Begin
  FTargetLastEdited := GetTickCount;
  ValidRegEx(edtTargetSearch);
End;

(**

  This method filters the treeview (showing only those nodes that match the search or their parents)
  based on the regular expression found in the filter edit control and updates the statusbar with
  the results.

  @precon  None.
  @postcon The treeview is filtered is a valid regular expression is entered in the filter edit
           control.

**)
Procedure TfrmOTAIntfSearch.FilterChanged;

ResourceString
  strRegExOkay = 'RegEx Okay';
  strRegExErrorIn = 'RegEx Error in "%s": %s';
  strMatches = '%d Matches';
  strShowingAll = 'Showing All.';

Var
  N: PVirtualNode;
  iVisible: Integer;
  iVisibleTotal: Integer;

Begin
  iVisibleTotal := 0;
  FFiltering := edtFilter.Text <> '';
  Try
    If FFiltering Then
      FSearchRegEx := TRegEx.Create(edtFilter.Text, [roIgnoreCase, roCompiled,
        roSingleLine]);
    FInterfacesTree.BeginUpdate;
    Try
      N := FInterfacesTree.RootNode.FirstChild;
      While Assigned(N) Do
        Begin
          iVisible := FilterInterfaceTreeView(N);
          FInterfacesTree.IsVisible[N] := Not FFiltering Or (iVisible > 0);
          Inc(iVisibleTotal, iVisible);
          N := FInterfacesTree.GetNextSibling(N);
        End;
    Finally
      FInterfacesTree.EndUpdate;
    End;
    FUIUpdater.UpdateStatusPanel(strRegExOkay, sppRegExMsg);
  Except
    On E: ERegularExpressionError Do
      Begin
        FFiltering := False;
        FUIUpdater.UpdateStatusPanel(Format(strRegExErrorIn, [edtFilter.Text, E.Message]),
          sppRegExMsg);
      End;
  End;
  If FFiltering Then
    FUIUpdater.UpdateStatusPanel(Format(strMatches, [iVisibleTotal]), sppMatches)
  Else
    FUIUpdater.UpdateStatusPanel(strShowingAll, sppMatches);
End;

(**

  This method filter the interface tree view based on the filter regular expression but hiding
  the nodes that dont match (paths to visible nodes are kept).

  @precon  N must be a valid tree node.
  @postcon The nodes that dont match the filter are hidden.

  @param   N as a PVirtualNode as a Constant
  @return  an Integer

**)
Function TfrmOTAIntfSearch.FilterInterfaceTreeView(Const N : PVirtualNode) : Integer;

Var
  iVisible : Integer;

Begin
  iVisible := 0;
  FInterfacesTree.IterateSubtree(
    N,
    Procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer; Var Abort: Boolean)
    Var
      NodeData: PTreeData;
      ParentNode: PVirtualNode;
      strText, strComment: String;
      ToolsAPIFile: IOISToolsAPIFile;
    Begin
      NodeData := Sender.GetNodeData(Node);
      If FFiltering And (NodeData.FLeafType In [ltType, ltFunction]) Then
        Begin
          ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
          If NodeData.FLeafType = ltType Then
            Begin
              strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex];
              strComment := ToolsAPIFile.Comment[NodeData.FInterfaceObjectIndex];
            End Else
            Begin
              strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
                MethodProperty[NodeData.FMethodIndex];
              strComment := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex]
                .Comment[NodeData.FMethodIndex];
            End;
          Sender.IsVisible[Node] := Not FFiltering Or FSearchRegEx.IsMatch(strText) Or FSearchRegEx.IsMatch(strComment);
          If Sender.IsVisible[Node] Then
            Begin
              Inc(iVisible);
              ParentNode := Sender.NodeParent[Node];
              While Assigned(ParentNode) Do
                Begin
                  Sender.IsVisible[ParentNode] := True;
                  ParentNode := Sender.NodeParent[ParentNode];
                End;
            End;
        End
      Else
        Sender.IsVisible[Node] := True;
    End,
    Nil
    );
  Result := iVisible;
End;

(**

  This the forms on create event handler.

  @precon  None.
  @postcon Initialises the form with various sub-systems to be used by the application.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.FormCreate(Sender: TObject);

Const
  iHintPause = 500;
  iHintHidePause = 30000;
  
Var
  HitInfo: THitInfo;

Begin
  If Assigned(TStyleManager.Engine) Then
    TStyleManager.Engine.RegisterStyleHook(TSynEdit, TMemoStyleHook);
  FFilePathList := TList<TOISFilePathListRec>.Create;
  CreateCustomInterfaceStringTree;
  CreateCustomOTACodeStringTree;
  CreateDependencies;
  FOptions := TOISOTAOptions.Create(FINIFile);
  ApplyTheming;
  UpdateFormTitle;
  LoadSettings;
  PopulateFilePathList;
  vstFilePathsNodeClick(Nil, HitInfo);
  pgcPageControl.ActivePage := tabInterfaces;
  If FFilePathList.Count = 0 Then
    pgcPageControl.ActivePage := tabToolsAPIFiles;
  CreateCachedRegExs;
  stbrStatusBar.Canvas.Font.Assign(Font);
  Application.HintColor := clWhite;
  Application.HintPause := iHintPause;
  Application.HintHidePause := iHintHidePause;
End;

(**

  This is an on destroy event handler for the main form.

  @precon  None.
  @postcon Saves the applciations settings.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.FormDestroy(Sender: TObject);

Begin
  SaveSettings;
  FFilePathList.Free;
  {: @bug For some reason with EurekaLog enabled the below line raises an exception
  If Assigned(TStyleManager.Engine) Then
    TStyleManager.Engine.UnregisterStyleHook(TSynEdit, TMemoStyleHook);
  }
End;

(**

  This method is an on show event handler for the main form.

  @precon  None.
  @postcon Starts an initial parsing of the files found in the search paths and then filters them
           using the regular expression in the filter edit control.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.FormShow(Sender: TObject);

Begin
  FHasDoneInitialParseAndFilter := False;
  tmTimer.Enabled := True;
End;

(**

  This method starts the process of find paths through the OTA code to get to interfaces and methods.

  @precon  PNodeData must be a valid pointer to a TTreeData structure.
  @postcon Starts the process of find paths through the OTA code to get to interfaces and methods.

  @param   NodeData as a PTreeData as a constant

**)
Procedure TfrmOTAIntfSearch.GenerateOTACode(Const NodeData: PTreeData);

Const
  strMsg = 'Exception in regular expression "%s":'#13#10'%s';
  strWarningMsg = 'There is already a search in progress!';

Var
  C: Char;

Begin
  If pagViews.ActivePage = tabCreationPaths Then
    Begin
      If FSearching And Assigned(FGenOTACode) Then
        Begin
          MessageDlg(strWarningMsg, mtWarning, [mbOK], 0);
          Exit;
        End;
      FSearching := True;
      Try
        FGenOTACode := TOISGenerateOTACode.Create(FToolsAPIFiles, NodeData.FFileIndex, FOTACodeTree,
          FProgressManager);
        Try
          Try
            FGenOTACode.GenerateCode(
              NodeData.FInterfaceObjectIndex,
              NodeData.FMethodIndex,
              NodeData.FLeafType,
              edtTargetSearch.Text
            );
          Except
            On E: ERegularExpressionError Do
              MessageDlg(Format(strMsg, [edtTargetSearch.Text, E.Message]), mtError, [mbOK], 0);
          End;
        Finally
          FGenOTACode := Nil;
        End;
        C := #13;
        OTACodeTreeKeyPress(FOTACodeTree, C);
      Finally
        FSearching := False
      End;
    End;
End;

(**

  This method loads the applications settings from the INI File.

  @precon  None.
  @postcon The applications settings are loaded.

**)
Procedure TfrmOTAIntfSearch.LoadSettings;

Const
  iDefaultTop = 10;
  iDefaultLeft = 10;

Var
  iFile: Integer;
  slFiles: TStringList;

Begin
  Top := FIniFile.ReadInteger(strSetupINISection, strTopKey, iDefaultTop);
  Left := FIniFile.ReadInteger(strSetupINISection, strLeftKey, iDefaultLeft);
  Height := FIniFile.ReadInteger(strSetupINISection, strHeightKey, Height);
  Width := FIniFile.ReadInteger(strSetupINISection, strWidthKey, Width);
  edtFilter.Text := FIniFile.ReadString(strSetupINISection, strFilterTextKey, '');
  edtTargetSearch.Text := FIniFile.ReadString(strSetupINISection, strTargetSearchKey, '');
  pagViews.ActivePageIndex := FIniFile.ReadInteger(strSetupINISection, strActiveViewIndexKey, 0);
  pagViews.Height := FIniFile.ReadInteger(strSetupINISection, strCodeHeightKey, splViews.MinSize);
  pnlPath.Height := FIniFile.ReadInteger(strSetupINISection, strPathsHeightKey, splPaths.MinSize);
  slFiles := TStringList.Create;
  Try
    FIniFile.ReadSection(strToolsAPIFilesINISection, slFiles);
    For iFile := 0 To slFiles.Count - 1 Do
      FFilePathList.Add(TOISFilePathListRec.Create(
        FIniFile.ReadString(strToolsAPIFilesINISection, slFiles[iFile], ''),
        FIniFile.ReadBool(strToolsAPIFilesCheckINISection, slFiles[iFile], True)
      ));
  Finally
    slFiles.Free;
  End;
End;

(**

  This is an on click event handler for the OTA Code Tree.

  @precon  None.
  @postcon Outputs the path to the panel which shows the user how to get to the selected interface /
           method.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.OTACodeTreeClick(Sender: TObject);

Var
  N: PVirtualNode;
  NodeData: PTreeData;

Begin
  lblPath.Caption := '';
  N := FOTACodeTree.FocusedNode;
  While Assigned(N) Do
    Begin
      If lblPath.Caption <> '' Then
        lblPath.Caption := lblPath.Caption + ' > ';
      NodeData := FOTACodeTree.GetNodeData(N);
      lblPath.Caption := lblPath.Caption + GetCodeIdentifier(FOTACodeTree.Text[N, 0],
        NodeData.FLeafType);
      N := FOTACodeTree.NodeParent[N];
    End;
End;

(**

  This is an on key press event handler for the OTA Code tree view.

  @precon  None.
  @postcon Invokes the Click event handler for the selected tree node.

  @param   Sender as a TObject
  @param   Key    as a Char as a reference

**)
Procedure TfrmOTAIntfSearch.OTACodeTreeKeyPress(Sender: TObject; Var Key: Char);

Begin
  If Key = #13 Then
    OTACodeTreeClick(Sender);
End;

(**

  This is an on change event handler for the Views page control.

  @precon  None.
  @postcon Searches the interfaces for paths to the selected interface/property/method.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.pagViewsChange(Sender: TObject);

Var
  NodeData: PTreeData;

Begin
  If Assigned(FInterfacesTree.FocusedNode) And (pagViews.ActivePage = tabCreationPaths) Then
    Begin
      NodeData := FInterfacesTree.GetNodeData(FInterfacesTree.FocusedNode);
      GenerateOTACode(NodeData);
    End;
End;

(**

  This method starts the parsing of the files found in the search paths, ensure the Code Tree is
  cleared as the data will be invalid and then finally filters the interface tree.

  @precon  None.
  @postcon The search path is parsed and the list refiltered.

**)
Procedure TfrmOTAIntfSearch.ParseFilesAndFilter;

Var
  slFiles : TStringList;
  Node : PVirtualNode;
  NodeData : POISFilePathTreeNode;
  
Begin
  FOTACodeTree.Clear;
  slFiles := TstringList.Create;
  Try
    Node := vstFilePaths.GetFirst();
    While Assigned(Node) Do
      Begin
        NodeData := vstFilePaths.GetNodeData(Node);
        If FFilePathList[NodeData.FFilePathListIndex].FChecked Then
          slFiles.Add(FFilePathList[NodeData.FFilePathListIndex].FFilePath);
        Node := vstFilePaths.GetNext(Node);
      End;
    FFileParser.ParseFiles(slFiles);
  Finally
    slFiles.Free;
  End;
  FilterChanged;
End;

(**

  This method parses the target search regular expression for highlighting the text.

  @precon  None.
  @postcon The regular expression is parsed and the tree views highlighted.

**)
Procedure TfrmOTAIntfSearch.ParseTargetSearch;

ResourceString
  strRegExOkay = 'RegEx Okay';
  strRegExErrorIn = 'RegEx Error in "%s": %s';

Begin
  Try
    FTargeting := edtTargetSearch.Text <> '';
    If FTargeting Then
      FTargetSearchRegEx := TRegEx.Create(edtTargetSearch.Text,
        [roIgnoreCase, roCompiled, roSingleLine]);
    FUIUpdater.UpdateStatusPanel(strRegExOkay, sppRegExMsg);
    FInterfacesTree.Invalidate;
    FOTACodeTree.Invalidate;
  Except
    On E: ERegularExpressionError Do
      Begin
        FTargeting := False;
        FUIUpdater.UpdateStatusPanel(Format(strRegExErrorIn, [edtTargetSearch.Text,
          E.Message]), sppRegExMsg);
      End;
  End;
End;

(**

  This method renders the list of file paths in the treeview.

  @precon  None.
  @postcon The list of file paths are listed in teh treeview.

**)
Procedure TfrmOTAIntfSearch.PopulateFilePathList;

Var
  NodeData : POISFilePathTreeNode;
  iSelected: Integer;
  iFilePath: Integer;
  Node: PVirtualNode;
  
Begin
  FPopulating := True;
  Try
    vstFilePaths.BeginUpdate;
    Try
      iSelected := -1;
      If Assigned(vstFilePaths.FocusedNode) Then
        Begin
          NodeData := vstFilePaths.GetNodeData(vstFilePaths.FocusedNode);
          iSelected := NodeData.FFilePathListIndex;
        End;
      vstFilePaths.Clear;
      If iSelected > FFilePathList.Count - 1 Then
        iSelected := FFilePathList.Count - 1;
      For iFilePath := 0 To FFilePathList.Count - 1 Do
        Begin
          Node := vstFilePaths.AddChild(Nil);
          NodeData := vstFilePaths.GetNodeData(Node);
          NodeData.FFilePathListIndex := iFilePath;
          vstFilePaths.CheckType[Node] := ctCheckBox;
          Case FFilePathList[iFilePath].FChecked Of
            False: vstFilePaths.CheckState[Node] := csUncheckedNormal;
            True:  vstFilePaths.CheckState[Node] := csCheckedNormal;  
          End;
          If iFilePath = iSelected Then
            Begin
              vstFilePaths.FocusedNode := Node;
              vstFilePaths.Selected[Node] := True;
            End;
        End;
    Finally
      vstFilePaths.EndUpdate;
    End;
  Finally
    FPopulating := False;
  End;
End;

(**

  This mehod saves the applications settings to the INI File.

  @precon  None.
  @postcon The applications settings are saved to the INI File.

**)
Procedure TfrmOTAIntfSearch.SaveSettings;

Const
  strSearchPath = 'SearchPath%4.4d';

Var
  iFile: Integer;

Begin
  FIniFile.WriteInteger(strSetupINISection, strTopKey, Top);
  FIniFile.WriteInteger(strSetupINISection, strLeftKey, Left);
  FIniFile.WriteInteger(strSetupINISection, strHeightKey, Height);
  FIniFile.WriteInteger(strSetupINISection, strWidthKey, Width);
  FIniFile.WriteString(strSetupINISection, strFilterTextKey, edtFilter.Text);
  FIniFile.WriteString(strSetupINISection, strTargetSearchKey, edtTargetSearch.Text);
  FIniFile.WriteInteger(strSetupINISection, strCodeHeightKey, pagViews.Height);
  FIniFile.WriteInteger(strSetupINISection, strActiveViewIndexKey, pagViews.ActivePageIndex);
  FIniFile.WriteInteger(strSetupINISection, strPathsHeightKey, pnlPath.Height);
  FIniFile.EraseSection(strToolsAPIFilesINISection);
  For iFile := 0 To FFilePathList.Count - 1 Do
    Begin
      FIniFile.WriteString(strToolsAPIFilesINISection, Format(strSearchPath, [iFile]),
        FFilePathList[iFile].FFilePath);
      FIniFile.WriteBool(strToolsAPIFilesCheckINISection, Format(strSearchPath, [iFile]),
        FFilePathList[iFile].FChecked);
    End;
  FIniFile.UpdateFile;
End;

(**

  This is an on Draw Panel event handler for the Statusbar.

  @precon  None.
  @postcon If the statuar bar panel is owner draw and contains the word "error" then the text is
  shown in red rather than green.

  @nocheck MissingCONSTInParam

  @param   StatusBar as a TStatusBar
  @param   Panel     as a TStatusPanel
  @param   Rect      as a TRect as a Constant

**)
Procedure TfrmOTAIntfSearch.stbrStatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  Const Rect: TRect);

Const
  strError = 'error';

Var
  strText: String;
  R: TRect;

Begin
  strText := Panel.Text;
  If Pos(strError, LowerCase(strText)) > 0 Then
    StatusBar.Canvas.Font.Color := FOptions.Colour[ocInvalidRegEx]
  Else
    StatusBar.Canvas.Font.Color := FOptions.Colour[ocValidRegEx];
  R := Rect;
  StatusBar.Canvas.TextRect(R, strText, [tfLeft, tfBottom]);
End;

(**

  This is an on timer event handler for the application.

  @precon  None.
  @postcon The timer checks to see if the filter control had changed (which updates the FLastEdited
           variable and if so waits iUpdateDelayInterval before updated the tree filtering.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.tmTimerEvent(Sender: TObject);

Begin
  tmTimer.Enabled := False;
  Try
    If Not FHasDoneInitialParseAndFilter Then
      Begin
        ParseFilesAndFilter;
        FHasDoneInitialParseAndFilter := True;
      End;
    If (FSearchLastEdited <> 0) And (GetTickCount > FSearchLastEdited + iUpdateDelayInterval) Then
      Begin
        FilterChanged;
        FSearchLastEdited := 0;
      End;
    If (FTargetLastEdited <> 0) And (GetTickCount > FTargetLastEdited + iUpdateDelayInterval) Then
      Begin
        ParseTargetSearch;
        FTargetLastEdited := 0;
      End;
    If Not FSysOptionsMenuInstalled Then
      AddSystemMenu;
  Finally
    tmTimer.Enabled := True;
  End;
End;

(**

  This method updates the main fom caption with build information from the version info record in
  the executable.

  @precon  None.
  @postcon The forms caption is updated to include build information.

**)
Procedure TfrmOTAIntfSearch.UpdateFormTitle;

Const
  strBuild = '%s %d.%d%s (Build %d.%d.%d.%d)';

Var
  recBuildInfo : TOISBuildInfo;

Begin
  GetBuildData(recBuildInfo);
  Caption := Format(
    strBuild, [
      Application.Title,
      recBuildInfo.FMajor,
      recBuildInfo.FMinor,
      strBugFix[Succ(recBuildInfo.FBugFix)],
      recBuildInfo.FMajor,
      recBuildInfo.FMinor,
      recBuildInfo.FBugFix,
      recBuildInfo.FBuild
    ]
  );
End;

(**

  This method validate the regular expresssion in the edit control passed. If there is an exception the 
  controls text is highlighted as an error.

  @precon  The control passed needs to the a valid TEdit control.
  @postcon The controls regular expression text is validated.

  @param   RegExControl as a TEdit as a constant

**)
Procedure TfrmOTAIntfSearch.ValidRegEx(Const RegExControl: TEdit);

Var
  RE : TRegEx;

Begin
  Try
    If RegExControl.Text <> '' Then
      RE := TRegEx.Create(RegExControl.Text, [roIgnoreCase, roCompiled, roSingleLine]);
    RegExControl.Font.Color := clWindowText;
    RegExControl.Color := clWindow;
  Except
    On E : ERegularExpressionError Do
      Begin
        RegExControl.Font.Color := clRed;
        RegExControl.Color := clYellow;
      End;
  End;
End;

(**

  This is an on node checked event handler for the File Paths treeview.

  @precon  None.
  @postcon The generic collection item is updated with the check status.

  @param   Sender as a TBaseVirtualTree
  @param   Node   as a PVirtualNode

**)
Procedure TfrmOTAIntfSearch.vstFilePathsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);

Var
  NodeData : POISFilePathTreeNode;
  R: TOISFilePathListRec;
  
Begin
  If Not FPopulating Then
    Begin
      NodeData := vstFilePaths.GetNodeData(Node);
      R := FFilePathList[NodeData.FFilePathListIndex];
      Case vstFilePaths.CheckState[Node] Of
        csUncheckedNormal: R.FChecked := False;
        csCheckedNormal: R.FChecked := True;  
      End;
      FFilePathList[NodeData.FFilePathListIndex] := R;
      ParseFilesAndFilter;
    End;
End;

(**

  This is an on get text event handler for the File Path List treeview.

  @precon  None.
  @postcon Returns the text (file path) to display.

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a reference

**)
Procedure TfrmOTAIntfSearch.vstFilePathsGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);
  
Var
  NodeData : POISFilePathTreeNode;
  
Begin
  NodeData := vstFilePaths.GetNodeData(Node);
  CellText := FFilePathList[NodeData.FFilePathListIndex].FFilePath;
End;

(**

  This is an on node click event handler for the File Path List.

  @precon  None.
  @postcon Enables or disables the buttons associated with the file path list.

  @param   Sender  as a TBaseVirtualTree
  @param   HitInfo as a THitInfo as a constant

**)
Procedure TfrmOTAIntfSearch.vstFilePathsNodeClick(Sender: TBaseVirtualTree; Const HitInfo: THitInfo);

Begin
  btnDown.Enabled := Assigned(vstFilePaths.FocusedNode) And
    (vstFilePaths.FocusedNode <> vstFilePaths.GetLast);
  btnUp.Enabled := Assigned(vstFilePaths.FocusedNode) And
    (vstFilePaths.FocusedNode <> vstFilePaths.GetFirst);
  btnDelete.Enabled := Assigned(vstFilePaths.FocusedNode);
  btnEdit.Enabled := Assigned(vstFilePaths.FocusedNode);
End;

(**

  This is an on After Cell Paint event handler for the interfaces tree view.

  @precon  None.
  @postcon This method paints the highlighted text over the top of the tree text.

  @param   Sender       as a TBaseVirtualTree
  @param   TargetCanvas as a TCanvas
  @param   Node         as a PVirtualNode
  @param   Column       as a TcolumnIndex
  @param   CellRect     as a TRect

**)
Procedure TfrmOTAIntfSearch.vstInterfacesAfterCellPaint(Sender: TBaseVirtualTree;
  TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);

  (**

    This local method highlights the text matches passed in the given colour.

    @precon  None.
    @postcon If there are matches these are highlighed.

    @param   MC      as a TMatchCollection as a constant
    @param   strText as a String as a constant
    @param   iColor  as a TColor as a constant

  **)
  Procedure HighlightText(Const MC : TMatchCollection; Const strText : String; Const iColor : TColor);

  Const
    iPadding = 18 + 26 + 2;

  Var
    iStart: Integer;
    iMatch: Integer;
    M: TMatch;
    iLeft: Integer;

  Begin
    iStart := iPadding + Sender.GetNodeLevel(Node) * (Sender As TVirtualStringTree).Indent;
    For iMatch := 0 To MC.Count - 1 Do
      Begin
        M := MC[iMatch];
        TargetCanvas.Font.Color := FOptions.Colour[ocHighlightText];
        TargetCanvas.Brush.Color := iColor;
        iLeft := TargetCanvas.TextWidth(Copy(strText, 1, M.Index - 1));
        TargetCanvas.TextOut(iStart + iLeft, CellRect.Top, Copy(strText,
          M.Index, M.Length));
      End;
  End;

Var
  NodeData: PTreeData;
  strText: String;
  ToolsAPIFile: IOISToolsAPIFile;

Begin
  NodeData := Sender.GetNodeData(Node);
  If (Column = 0) And (NodeData.FLeafType In [ltType..ltQueryInterface]) Then
    Begin
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      strText := (Sender As TVirtualStringTree).Text[Node, 0];
      If FFiltering Then
        HighlightText(FSearchRegEx.Matches(strText), strText, FOptions.Colour[ocFilterHighlight]);
      If FTargeting Then
        HighlightText(FTargetSearchRegEx.Matches(strText), strText, FOptions.Colour[ocTargetHighlight]);
    End;
End;

(**

  This is an on click event handler for the Interfaces tree view.

  @precon  None.
  @postcon Displays the source code at the correct line fort any interface/object or method/property
           selected in the tree. Also generates an output providing guidance on how to get to an
           interface or method.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.vstInterfacesClick(Sender: TObject);

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;

Begin
  If Assigned(FInterfacesTree.FocusedNode) Then
    Begin
      NodeData := FInterfacesTree.GetNodeData(FInterfacesTree.FocusedNode);
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      Case NodeData.FLeafType Of
        ltFile: CodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
        ltType:
          Begin
            CodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
            CodeView.CaretX := 1;
            CodeView.CaretY := ToolsAPIFile.LineNo[NodeData.FInterfaceObjectIndex];
            CodeView.TopLine := CodeView.CaretY - CodeView.LinesInWindow Div 2;
          End;
        ltFunction:
          Begin
            CodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
            CodeView.CaretX := 1;
            CodeView.CaretY := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
              LineNo[NodeData.FMethodIndex];
            CodeView.TopLine := CodeView.CaretY - CodeView.LinesInWindow Div 2;
          End;
      End;
      CodeView.UseCodeFolding := True;
      GenerateOTACode(NodeData);
    End
  Else
    Begin
      CodeView.Lines.Clear;
      FOTACodeTree.Clear;
    End;
End;

(**

  This is an on get hit event handler for the interfaces tree view.

  @precon  None.
  @postcon Extracts the hint (code | comment) for the element under the cursor.

  @param   Sender         as a TbaseVirtualTree
  @param   Node           as a PVirtualNode
  @param   Column         as a TColumnIndex
  @param   LineBreakStyle as a TVTTooltipLineBreakStyle as a reference
  @param   HintText       as a String as a reference

**)
Procedure TfrmOTAIntfSearch.vstInterfacesGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
Column: TColumnIndex; Var LineBreakStyle: TVTTooltipLineBreakStyle; Var HintText: String);

Const
  strHint = 'BorlandIDEServices|Service := (BorlandIDEServices As IOTAXxxxxServices);';

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;
  Methods: IOISInterfaceObjectMethods;

Begin
  NodeData := Sender.GetNodeData(Node);
  If (Column = 0) Then
    Begin
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      Case NodeData.FLeafType Of
        ltType:
          HintText :=
            ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex] + '|' +
            ToolsAPIFile.Comment[NodeData.FInterfaceObjectIndex];
        ltFunction:
          Begin
            Methods := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex];
            HintText :=
              Methods.MethodProperty[NodeData.FMethodIndex] + '|' +
              Methods.Comment[NodeData.FMethodIndex];
          End;
        ltBorlandIDEServices: HintText := strHint;
      End;
    End;
End;

(**

  This is an o get image index event handler for the interfaces tree view.

  @precon  None.
  @postcon This method determines the correct image index based on the node being queried.

  @param   Sender     as a TBaseVirtualtree
  @param   Node       as a PVirtualNode
  @param   Kind       as a TVTImageKind
  @param   Column     as a TColumnIndex
  @param   Ghosted    as a Boolean as a Reference
  @param   ImageIndex as an TImageIndex as a Reference

**)
Procedure TfrmOTAIntfSearch.vstInterfacesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: TImageIndex);

Const
  iModuleIdx = 0;
  iInterfaceIdx = 1;
  iClassIdx = 2;
  iProcedureIdx = 3;
  iFunctionIdx = 4;
  iPropertyIdx = 5;

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;
  strText: String;

Begin
  Ghosted := False;
  NodeData := Sender.GetNodeData(Node);
  If (Column = 0) And (Kind In [ikNormal, ikSelected]) Then
    Begin
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      Case NodeData.FLeafType Of
        ltFile: ImageIndex := iModuleIdx;
        ltType:
          Begin
            strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex];
            If FInterfaceRegEx.IsMatch(strText) Then
              ImageIndex := iInterfaceIdx
            Else
              ImageIndex := iClassIdx;
          End;
        ltFunction:
          Begin
            strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
              MethodProperty[NodeData.FMethodIndex];
            If FProcedureRegEx.IsMatch(strText) Then
              ImageIndex := iProcedureIdx
            Else If FFunctionRegEx.IsMatch(strText) Then
              ImageIndex := iFunctionIdx
            Else
              ImageIndex := iPropertyIdx;
          End;
        ltBorlandIDEServices: ImageIndex := 1;
      Else
        ImageIndex := - 1;
      End
    End
  Else
    ImageIndex := - 1;
End;

(**

  This is an on get text event handler for the interfaces tree view.

  @precon  None.
  @postcon Returns the text for the required node (filename for files, interface / object for types,
           and methods / properties).

  @param   Sender   as a TBaseVirtualTree
  @param   Node     as a PVirtualNode
  @param   Column   as a TColumnIndex
  @param   TextType as a TVSTTextType
  @param   CellText as a String as a Reference

**)
Procedure TfrmOTAIntfSearch.vstInterfacesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);

Const
  iParentIdentifier = 2;
  strBorlandIDEServicesAs = '(BorlandIDEServices As %s)';
  strQueryInterfaceOutVariable = '%s.QueryInterface(%s, OutVariable)';

ResourceString
  strLoopingReference = '(looping reference %s)';
  strImplementNotifier = 'Implement the Notifier: %s';

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;
  strInterfaceIdent: String;
  i: Integer;

Begin
  NodeData := Sender.GetNodeData(Node);
  ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
  Case NodeData.FLeafType Of
    ltType .. High(TLeafType):
      strInterfaceIdent := GetCodeIdentifier(
        ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex], ltType);
  End;
  Case Column Of
    0:
      Case NodeData.FLeafType Of
        ltFile: CellText := ToolsAPIFile.FileName;
        ltType: CellText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex];
        ltFunction: CellText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex]
            .MethodProperty[NodeData.FMethodIndex];
        ltBorlandIDEServices: CellText := Format(strBorlandIDEServicesAs, [strInterfaceIdent]);
        ltLoop: CellText := Format(strLoopingReference, [strInterfaceIdent]);
        ltNotifier: CellText := Format(strImplementNotifier, [strInterfaceIdent]);
        ltQueryInterface:
          Begin
            For i := Low(strQueryInterfaces) To High(strQueryInterfaces) Do
              If CompareText(strQueryInterfaces[i, 1], strInterfaceIdent) = 0 Then
                CellText := Format(strQueryInterfaceOutVariable, [strQueryInterfaces[i,
                  iParentIdentifier], strInterfaceIdent]);
          End;
      End;
    1:
      Case NodeData.FLeafType Of
        ltType: CellText := Format('%d', [ToolsAPIFile.LineNo[NodeData.FInterfaceObjectIndex]]);
        ltFunction: CellText := Format('%d', [
            ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
            LineNo[NodeData.FMethodIndex]]);
      Else
        CellText := '';
      End;
  End;
End;

(**

  This is an on key press event handler for the interfaces tree view.

  @precon  None.
  @postcon Invokes the Click event handler for the selected tree node.

  @param   Sender as a TObject
  @param   Key    as a Char as a reference

**)
Procedure TfrmOTAIntfSearch.vstInterfacesKeyPress(Sender: TObject; Var Key: Char);

Begin
  If Key = #13 Then
    vstInterfacesClick(Sender);
End;

(**

  This method is an on paint text event handler for the interfaces tree view.

  @precon  None.
  @postcon This method makes filename bold and types navy.

  @param   Sender       as a TBaseVirtualTree
  @param   TargetCanvas as a TCanvas as a constant
  @param   Node         as a PVirtualNode
  @param   Column       as a TColumnIndex
  @param   TextType     as a TVSTTextType

**)
Procedure TfrmOTAIntfSearch.vstInterfacesPaintText(Sender: TBaseVirtualTree;
  Const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);

Var
  NodeData: PTreeData;

Begin
  NodeData := Sender.GetNodeData(Node);
  TargetCanvas.Font.Style := [];
  TargetCanvas.Font.Color := FOptions.Colour[ocWindowText];
  Case NodeData.FLeafType Of
    ltFile : TargetCanvas.Font.Style := [fsBold];
  End;
  If Not Sender.Selected[Node] Then
    Case NodeData.FLeafType Of
      ltType               : TargetCanvas.Font.Color := FOptions.Colour[ocType];
      ltBorlandIDEServices : TargetCanvas.Font.Color := FOptions.Colour[ocBorlandIDEServices];
      ltNotifier           : TargetCanvas.Font.Color := FOptions.Colour[ocNotifier];
      ltQueryInterface     : TargetCanvas.Font.Color := FOptions.Colour[ocInterface];
      ltLoop               : TargetCanvas.Font.Color := FOptions.Colour[ocLoop];
    End Else
      TargetCanvas.Font.Color := clHighlightText;
  TargetCanvas.Font.Color := StyleServices.GetSystemColor(TargetCanvas.Font.Color);
End;

(**

  This is a WMSysCommand window message handler for the applications main form.

  @precon  None.
  @postcon Contains a handler for the Options menu.

  @param   Message as a TWMSysCommand as a reference

**)
Procedure TfrmOTAIntfSearch.WMSysCommand(Var Message: TWMSysCommand);

Begin
  Inherited;
  Case Message.CmdType Of
    iOptionsMenuID:
      Begin
        FOptions.VCLTheme := StyleServices.Name;
        If TfrmOTAOptions.Execute(FOptions) Then
          ApplyTheming;
      End;
    iAboutMenuID: TfrmOISAbout.Execute;
  End;
End;

End.
