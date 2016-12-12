(**

  this module contains the main form interface for the application which is design to allow a user
  tp search for Open Tools API (OTA) classes and interfaces / methods and properties across multiple
  search directories.

  @Author  David Hoyle
  @Version 1.0
  @Date    10 Dec 2016

**)
Unit OTAIntfSearch.MainForm;

Interface

Uses
  Classes,
  Forms,
  Dialogs,
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  Buttons,
  Controls,
  Graphics,
  Windows,
  VirtualTrees,
  RegularExpressions,
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.Types,
  System.ImageList,
  Vcl.ImgList,
  OTAIntfSearch.UIUpdater,
  System.Win.TaskbarCore,
  Vcl.Taskbar,
  SynEdit,
  SynEditHighlighter,
  SynHighlighterPas,
  OTAIntfSearch.CustomVirtualStringTree;

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
    lbxFiles: TListBox;
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
    Procedure FormCreate(Sender: TObject);
    Procedure FormDestroy(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure btnAddClick(Sender: TObject);
    Procedure btnDeleteClick(Sender: TObject);
    Procedure lbxFilesDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState;
      Var Accept: Boolean);
    Procedure lbxFilesDragDrop(Sender, Source: TObject; X, Y: Integer);
    Procedure lvFilesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    Procedure edtFilterChange(Sender: TObject);
    Procedure vstInterfacesGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; Var CellText: String);
    Procedure vstInterfacesAfterCellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
    Procedure vstInterfacesPaintText(Sender: TBaseVirtualTree; Const TargetCanvas: TCanvas;
      Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType);
    Procedure vstInterfacesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: Integer);
    Procedure vstInterfacesGetHint(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; Var LineBreakStyle: TVTTooltipLineBreakStyle; Var HintText: String);
    Procedure vstInterfacesKeyPress(Sender : TObject; var Key : Char);
    Procedure OTACodeTreeKeyPress(Sender : TObject; var Key : Char);
    Procedure btnEditClick(Sender: TObject);
    Procedure stbrStatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; Const Rect: TRect);
    procedure vstInterfacesClick(Sender: TObject);
    procedure OTACodeTreeClick(Sender: TObject);
    Procedure tmTimerEvent(Sender : TObject);
    procedure pagViewsChange(Sender: TObject);
  Strict Private
    Const
      (** a constant to define the time period after typing a reg ex search before the treeview is
          filtered. **)
      iUpdateDelayInterval = 500;
  Strict Private
    FIniFile: IOISINIFile;
    FToolsAPIFiles: IOISToolsAPIFiles;
    FUIUpdater: IOISInterfacesUIUpdater;
    FFileParser: IOISFileParser;
    FProgressManager : IOISProgressManager;
    FInterfacesTree: TVirtualStringTree;
    FOTACodeTree: TVirtualStringTree;
    FFiltering: Boolean;
    FSearchRegEx: TRegEx;
    FInterfaceRegEx: TRegEx;
    FProcedureRegEx: TRegEx;
    FFunctionRegEx: TRegEx;
    FPropertyRegEx: TRegEx;
    FCodeView : TSynEdit;
    FLastEdited : Int64;
  Strict Protected
    Procedure CreateCustomInterfaceStringTree;
    Procedure CreateCustomOTACodeStringTree;
    Procedure CreateDependencies;
    Procedure CreateCodeViewer;
    Procedure CreateCachedRegExs;
    Procedure LoadSettings;
    Procedure SaveSettings;
    Procedure FilterChanged;
    Procedure GenerateOTACode(NodeData : PTreeData);
    Procedure UpdateFormTitle;
    Procedure ParseFilesAndFilter;
  Public
  End;

Var
  (** A global variable managed by Delphi for the main form to be created at startup. **)
  frmOTAIntfSearch: TfrmOTAIntfSearch;

Implementation

{$R *.DFM}


Uses
  CodeSiteLogging,
  SysUtils,
  RegularExpressionsCore,
  Types,
  OTAIntfSearch.MemIniFile,
  OTAIntfSearch.ToolsAPIFiles,
  OTAIntfSearch.BrowseFolderForm,
  OTAIntfSearch.FileParser,
  OTAIntfSearch.ProgressManager,
  OTAIntfSearch.GenerateOTACode,
  OTAIntfSearch.Constants,
  OTAIntfSearch.Functions;

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
      lbxFiles.Items.Add(strSearchPath);
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

Begin
  If lbxFiles.ItemIndex > - 1 Then
    Begin
      lbxFiles.Items.Delete(lbxFiles.ItemIndex);
      ParseFilesAndFilter;
    End;
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
  strSearchPath: String;

Begin
  If lbxFiles.ItemIndex > - 1 Then
    Begin
      strSearchPath := lbxFiles.Items[lbxFiles.ItemIndex];
      If TfrmBrowseFolder.Execute(Self, strSearchPath) Then
        Begin
          lbxFiles.Items[lbxFiles.ItemIndex] := strSearchPath;
          ParseFilesAndFilter;
        End;
    End;
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
  FProcedureRegEx := TRegEx.Create(strProcedureStartRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
  FFunctionRegEx := TRegEx.Create(strFunctionStartRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
  FPropertyRegEx := TRegEx.Create(strPropertyStartRegEx, [roIgnoreCase, roCompiled, roSingleLine]);
End;

(**

  This method creates a synedit control for viewing the code when you select a line of code. I`ve
  done this as the current release of the synedit controls seems to have problem displaying in the
  IDE design (shows then vanishes) and has made the IDE unstable inthe past.

  @precon  None.
  @postcon The synedit control is created and installed into the interface.

**)
Procedure TfrmOTAIntfSearch.CreateCodeViewer;

Begin
  FCodeView := TSynEdit.Create(Self);
  FCodeView.Parent := tabCodeView;
  FCodeView.Align := alClient;
  FCodeView.ReadOnly := True;
  FCodeView.Highlighter := synPascal;
  FCodeView.Font.Name := 'Consolas';
  FCodeView.Font.Size := 11;
  FCodeView.ActiveLineColor := clSkyBlue;
  FCodeView.HideSelection := False;
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
  FinterfacesTree.OnKeyPress := vstInterfacesKeyPress;
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
  FLastEdited := GetTickCount;
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
      While N <> Nil Do
        Begin
          iVisible := 0;
          FInterfacesTree.IterateSubtree(
            N,
            Procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer;
              Var Abort: Boolean)
            Var
              NodeData: PTreeData;
              N: PVirtualNode;
              strText: String;
              ToolsAPIFile: IOISToolsAPIFile;
            Begin
              NodeData := Sender.GetNodeData(Node);
              If FFiltering And (NodeData.FLeafType In [ltType, ltFunction]) Then
                Begin
                  ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
                  If NodeData.FLeafType = ltType Then
                    strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex]
                  Else
                    strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
                      MethodProperty[NodeData.FMethodIndex];
                  Sender.IsVisible[Node] := Not FFiltering Or
                    FSearchRegEx.IsMatch(strText);
                  If Sender.IsVisible[Node] Then
                    Begin
                      Inc(iVisible);
                      N := Sender.NodeParent[Node];
                      While N <> Nil Do
                        Begin
                          Sender.IsVisible[N] := True;
                          N := Sender.NodeParent[N];
                        End;
                    End;
                End
              Else
                Sender.IsVisible[Node] := True;
            End,
            Nil
            );
          FInterfacesTree.IsVisible[N] := Not FFiltering Or (iVisible > 0);
          Inc(iVisibleTotal, iVisible);
          N := FInterfacesTree.GetNextSibling(N);
        End;
    Finally
      FInterfacesTree.EndUpdate;
    End;
    FUIUpdater.UpdateStatusPanel('RegExp Okay', sppRegExMsg);
  Except
    On E: ERegularExpressionError Do
      FUIUpdater.UpdateStatusPanel('RegExp Error: ' + E.Message, sppRegExMsg);
  End;
  If FFiltering Then
    FUIUpdater.UpdateStatusPanel(Format('%d Matches', [iVisibleTotal]), sppMatches)
  Else
    FUIUpdater.UpdateStatusPanel('Showing All.', sppMatches);
End;

(**

  This the forms on create event handler.

  @precon  None.
  @postcon Initialises the form with various sub-systems to be used by the application.

  @param   Sender as a TObject

**)
Procedure TfrmOTAIntfSearch.FormCreate(Sender: TObject);

Begin
  CreateCustomInterfaceStringTree;
  CreateCustomOTACodeStringTree;
  CreateDependencies;
  UpdateFormTitle;
  LoadSettings;
  lvFilesSelectItem(Nil, Nil, False);
  pgcPageControl.ActivePage := tabInterfaces;
  If lbxFiles.Items.Count = 0 Then
    pgcPageControl.ActivePage := tabToolsAPIFiles;
  CreateCachedRegExs;
  stbrStatusBar.Canvas.Font.Assign(Font);
  Application.HintColor := clWhite;
  Application.HintPause := 500;
  Application.HintHidePause := 30000;
  CreateCodeViewer;
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
  ParseFilesAndFilter;
  tmTimer.Enabled := True;
End;

(**

  This method starts the process of find paths through the OTA code to get to interfaces and
  methods.

  @precon  PNodeData must be a valid pointer to a TTreeData structure.
  @postcon Starts the process of find paths through the OTA code to get to interfaces and methods.

  @param   NodeData as a PTreeData

**)
Procedure TfrmOTAIntfSearch.GenerateOTACode(NodeData : PTreeData);

Var
  GenerateOTACode : IOISGenerateOTACode;
  C: Char;

Begin
  If pagViews.ActivePage = tabCreationPaths Then
    Begin
      GenerateOTACode := TOISGenerateOTACode.Create(FToolsAPIFiles, NodeData.FFileIndex,
        FOTACodeTree, FProgressManager);
      GenerateOTACode.GenerateCode(NodeData.FInterfaceObjectIndex, NodeData.FMethodIndex,
        NodeData.FLeafType);
      C := #13;
      OTACodeTreeKeyPress(FOTACodeTree, C);
    End;
End;

(**

  This method loads the applications settings from the INI File.

  @precon  None.
  @postcon The applications settings are loaded.

**)
Procedure TfrmOTAIntfSearch.LoadSettings;

Var
  iFile: Integer;
  slFiles: TStringList;

Begin
  Top := FIniFile.ReadInteger('Setup', 'Top', 10);
  Left := FIniFile.ReadInteger('Setup', 'Left', 10);
  Height := FIniFile.ReadInteger('Setup', 'Height', Height);
  Width := FIniFile.ReadInteger('Setup', 'Width', Width);
  edtFilter.Text := FIniFile.ReadString('Setup', 'FilterText', '');
  pagViews.ActivePageIndex := FIniFile.ReadInteger('Setup', 'ActiveViewIndex', 0);
  pagViews.Height := FIniFile.ReadInteger('Setup', 'CodeHeight', splViews.MinSize);
  pnlPath.Height := FIniFile.ReadInteger('Setup', 'PathsHeight', splPaths.MinSize);
  slFiles := TStringList.Create;
  Try
    FIniFile.ReadSection('ToolsAPI Files', slFiles);
    For iFile := 0 To slFiles.Count - 1 Do
      lbxFiles.Items.Add(FIniFile.ReadString('ToolsAPI Files', slFiles[iFile], ''));
  Finally
    slFiles.Free;
  End;
End;

(**

  This is an on drag drop event handler for the files list view.

  @precon  None.
  @postcon The drag files is moved to before the drop position.

  @param   Sender as a TObject
  @param   Source as a TObject
  @param   X      as an Integer
  @param   Y      as an Integer

**)
Procedure TfrmOTAIntfSearch.lbxFilesDragDrop(Sender, Source: TObject; X, Y: Integer);

Var
  iCurIndex, iDropIndex : Integer;
  P : TPoint;
  strFileName : String;

Begin
  iCurIndex := lbxFiles.ItemIndex;
  P := Point(X, Y);
  iDropIndex := lbxFiles.ItemAtPos(P, False);
  If (iCurIndex <> iDropIndex) And (iDropIndex > -1) Then
    Begin
      If iDropIndex > iCurIndex Then
        Begin
          strFileName := lbxFiles.Items[iCurIndex];
          lbxFiles.Items.Insert(iDropIndex, strFilename);
          lbxFiles.Items.Delete(iCurIndex);
        End
      Else If iDropIndex < iCurIndex Then
        Begin
          strFileName := lbxFiles.Items[iCurIndex];
          lbxFiles.Items.Delete(iCurIndex);
          lbxFiles.Items.Insert(iDropIndex, strFilename);
        End;
      ParseFilesAndFilter;
    End;
End;

(**

  This is an on drag over event handler for the files listbox.

  @precon  None.
  @postcon Accepts the drag if the source and sender are the same and are the file listbox.

  @param   Sender as a TObject
  @param   Source as a TObject
  @param   X      as an Integer
  @param   Y      as an Integer
  @param   State  as a TDragState
  @param   Accept as a Boolean as a Reference

**)
Procedure TfrmOTAIntfSearch.lbxFilesDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; Var Accept: Boolean);

Begin
  Accept := (Sender = Source) And (Source = lbxFiles);
End;

(**

  This is an on select item event handler for the files listbox.

  @precon  None.
  @postcon Updates the status of the Add, Edit and Delete buttons depending upon what is selected.

  @param   Sender   as a TObject
  @param   Item     as a TListItem
  @param   Selected as a Boolean

**)
Procedure TfrmOTAIntfSearch.lvFilesSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);

Begin
  btnAdd.Enabled := True;
  btnEdit.Enabled := lbxFiles.ItemIndex > - 1;
  btnDelete.Enabled := lbxFiles.ItemIndex > - 1;
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
  NodeData : PTreeData;

Begin
  lblPath.Caption := '';
  N := FOTACodeTree.FocusedNode;
  While N <> Nil Do
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
  If (FInterfacesTree.FocusedNode <> Nil) And (pagViews.ActivePage = tabCreationPaths) Then
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

Begin
  FOTACodeTree.Clear;
  FFileParser.ParseFiles(lbxFiles.Items);
  FilterChanged;
End;

(**

  This mehod saves the applications settings to the INI File.

  @precon  None.
  @postcon The applications settings are saved to the INI File.

**)
Procedure TfrmOTAIntfSearch.SaveSettings;

Var
  iFile: Integer;

Begin
  FIniFile.WriteInteger('Setup', 'Top', Top);
  FIniFile.WriteInteger('Setup', 'Left', Left);
  FIniFile.WriteInteger('Setup', 'Height', Height);
  FIniFile.WriteInteger('Setup', 'Width', Width);
  FIniFile.WriteString('Setup', 'FilterText', edtFilter.Text);
  FIniFile.WriteInteger('Setup', 'CodeHeight', pagViews.Height);
  FIniFile.WriteInteger('Setup', 'ActiveViewIndex', pagViews.ActivePageIndex);
  FIniFile.WriteInteger('Setup', 'PathsHeight', pnlPath.Height);
  FIniFile.EraseSection('ToolsAPI Files');
  For iFile := 0 To lbxFiles.Items.Count - 1 Do
    FIniFile.WriteString('ToolsAPI Files', Format('SearchPath%4.4d', [iFile]),
      lbxFiles.Items[iFile]);
  FIniFile.UpdateFile;
End;

(**

  This is an on Draw Panel event handler for the Statusbar.

  @precon  None.
  @postcon If the statuar bar panel is owner draw and contains the word "error" then the text is
  shown in red rather than green.

  @param   StatusBar as a TStatusBar
  @param   Panel     as a TStatusPanel
  @param   Rect      as a TRect as a Constant

**)
Procedure TfrmOTAIntfSearch.stbrStatusBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  Const Rect: TRect);

Var
  strText: String;
  R: TRect;

Begin
  strText := Panel.Text;
  If Pos('error', LowerCase(strText)) > 0 Then
    StatusBar.Canvas.Font.Color := clRed
  Else
    StatusBar.Canvas.Font.Color := clGreen;
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
Procedure TfrmOTAIntfSearch.tmTimerEvent(Sender : TObject);

Begin
  tmTimer.Enabled := False;
  Try
    If (FLastEdited <> 0) And (GetTickCount > FLastEdited + iUpdateDelayInterval) Then
      Begin
        FilterChanged;
        FLastEdited := 0;
      End;
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
  strBugFix = ' abcdefghijklmnopqrstuvwxyz';

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
  iMajor, iMinor, iBugFix, iBuild : Word;

Begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
      VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
      with VerValue^ do
      begin
        iMajor := dwFileVersionMS shr 16;
        iMinor := dwFileVersionMS and $FFFF;
        iBugfix := dwFileVersionLS shr 16;
        iBuild := dwFileVersionLS and $FFFF;
        Caption := Format(strBuild, [Application.Title, iMajor, iMinor, strBugFix[Succ(iBugFix)],
          iMajor, iMinor, iBugfix, iBuild]);
      end;
      FreeMem(VerInfo, VerInfoSize);
    End;
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

Var
  NodeData: PTreeData;
  strText: String;
  MC: TMatchCollection;
  M: TMatch;
  iMatch: Integer;
  iLeft: Integer;
  iStart: Integer;
  ToolsAPIFile: IOISToolsAPIFile;

Begin
  If FFiltering Then
    Begin
      NodeData := Sender.GetNodeData(Node);
      If (Column = 0) And (NodeData.FLeafType In [ltType, ltFunction]) Then
        Begin
          ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
          If NodeData.FLeafType = ltType Then
            strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex]
          Else
            strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
              MethodProperty[NodeData.FMethodIndex];
          MC := FSearchRegEx.Matches(strText);
          iStart := 18 + 26 + Sender.GetNodeLevel(Node) * (Sender As TVirtualStringTree).Indent;
          For iMatch := 0 To MC.Count - 1 Do
            Begin
              M := MC[iMatch];
              TargetCanvas.Brush.Color := $D0FFFF;
              TargetCanvas.Font.Color := clNavy;
              iLeft := TargetCanvas.TextWidth(Copy(strText, 1, M.Index - 1));
              TargetCanvas.TextOut(iStart + iLeft, CellRect.Top, Copy(strText,
                M.Index, M.Length));
            End;
        End;
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
  NodeData : PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;

Begin
  If FInterfacesTree.FocusedNode <> Nil Then
    Begin
      NodeData := FInterfacesTree.GetNodeData(FInterfacesTree.FocusedNode);
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      Case NodeData.FLeafType Of
        ltFile: FCodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
        ltType:
          Begin
            FCodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
            FCodeView.CaretX := 1;
            FCodeView.CaretY := ToolsAPIFile.LineNo[NodeData.FInterfaceObjectIndex];
            FCodeView.TopLine := FCodeView.CaretY - FCodeView.LinesInWindow Div 2;
          End;
        ltFunction:
          Begin
            FCodeView.Lines.LoadFromFile(ToolsAPIFile.FileName);
            FCodeView.CaretX := 1;
            FCodeView.CaretY := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
              LineNo[NodeData.FMethodIndex];
            FCodeView.TopLine := FCodeView.CaretY - FCodeView.LinesInWindow Div 2;
          End;
      End;
      GenerateOTACode(NodeData);
    End Else
    Begin
      FCodeView.Lines.Clear;
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

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;
  Methods : IOISInterfaceObjectMethods;

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
        ltBorlandIDEServices: HintText :=
          'BorlandIDEServices|Service := (BorlandIDEServices As IOTAXxxxxServices);';
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
  @param   ImageIndex as an Integer as a Reference

**)
Procedure TfrmOTAIntfSearch.vstInterfacesGetImageIndex(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Kind: TVTImageKind; Column: TColumnIndex; Var Ghosted: Boolean; Var ImageIndex: Integer);

Var
  NodeData: PTreeData;
  ToolsAPIFile : IOISToolsAPIFile;
  strText: String;

Begin
  Ghosted := False;
  NodeData := Sender.GetNodeData(Node);
  If (Column = 0) And (Kind In [ikNormal, ikSelected]) Then
    Begin
      ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
      Case NodeData.FLeafType Of
        ltFile: ImageIndex := 0;
        ltType:
          Begin
            strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex];
            If FInterfaceRegEx.IsMatch(strText) Then
              ImageIndex := 1
            Else
              ImageIndex := 2;
          End;
        ltFunction:
          Begin
            strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
              MethodProperty[NodeData.FMethodIndex];
            If FProcedureRegEx.IsMatch(strText) Then
              ImageIndex := 3
            Else If FFunctionRegEx.IsMatch(strText) Then
              ImageIndex := 4
            Else
              ImageIndex := 5;
          End;
        ltBorlandIDEServices: ImageIndex := 1;
      Else
        ImageIndex := - 1;
      End
    End Else
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

Var
  NodeData: PTreeData;
  ToolsAPIFile: IOISToolsAPIFile;
  strInterfaceIdent : String;
  i : Integer;

Begin
  NodeData := Sender.GetNodeData(Node);
  ToolsAPIFile := FToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
  Case NodeData.FLeafType Of
    ltType..High(TLeafType):
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
        ltBorlandIDEServices: CellText := Format('(BorlandIDEServices As %s)', [strInterfaceIdent]);
        ltLoop: CellText := Format('(looping reference %s)', [strInterfaceIdent]);
        ltNotifier: CellText := Format('Implement the Notifier: %s', [strInterfaceIdent]);
        ltQueryInterface:
          Begin
            For i := Low(strQueryInterfaces) To High(strQueryInterfaces) Do
              If CompareText(strQueryInterfaces[i, 1], strInterfaceIdent) = 0 Then
              CellText := Format('%s.QueryInterface(%s, OutVariable)', [strQueryInterfaces[i, 2],
                strInterfaceIdent]);
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
  TargetCanvas.Font.Color := clBlack;
  Case NodeData.FLeafType Of
    ltFile: TargetCanvas.Font.Style := [fsBold];
    ltType: TargetCanvas.Font.Color := clNavy;
    ltBorlandIDEServices, ltNotifier, ltQueryInterface:
      Begin
        TargetCanvas.Font.Style := [fsBold];
        TargetCanvas.Font.Color := clRed;
      End;
    ltLoop:
      Begin
        TargetCanvas.Font.Style := [fsItalic];
        TargetCanvas.Font.Color := clPurple;
      End;
  End;
End;

End.
