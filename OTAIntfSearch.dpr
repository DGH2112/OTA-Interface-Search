(**

  This project is an applications to provide the ability to search Open Tools API files (OTA)
  for insterfaces and class, search using regular expressions for matches in the class / interface
  declarations and thei methods and properties. The objective is to allow a user to quickly find
  the interfaces the want to implement and provide information one how they can be accessed.

  @Author  David Hoyle
  @Version 1.0
  @Date    16 Dec 2016

**)
Program OTAIntfSearch;

{$R 'OTAIntfSearchITHVerInfo.res' 'OTAIntfSearchITHVerInfo.RC'}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}

uses
  Forms,
  OTAIntfSearch.Interfaces in 'Source\OTAIntfSearch.Interfaces.pas',
  OTAIntfSearch.MemIniFile in 'Source\OTAIntfSearch.MemIniFile.pas',
  OTAIntfSearch.ToolsAPIFile in 'Source\OTAIntfSearch.ToolsAPIFile.pas',
  OTAIntfSearch.ToolsAPIFiles in 'Source\OTAIntfSearch.ToolsAPIFiles.pas',
  OTAIntfSearch.FileParser in 'Source\OTAIntfSearch.FileParser.pas',
  OTAIntfSearch.Types in 'Source\OTAIntfSearch.Types.pas',
  OTAIntfSearch.UIUpdater in 'Source\OTAIntfSearch.UIUpdater.pas',
  OTAIntfSearch.ProgressManager in 'Source\OTAIntfSearch.ProgressManager.pas',
  OTAIntfSearch.GenerateOTACode in 'Source\OTAIntfSearch.GenerateOTACode.pas',
  OTAIntfSearch.CustomVirtualStringTree in 'Source\OTAIntfSearch.CustomVirtualStringTree.pas',
  OTAIntfSearch.CustomHintWindow in 'Source\OTAIntfSearch.CustomHintWindow.pas',
  OTAIntfSearch.BrowseFolderForm in 'Source\OTAIntfSearch.BrowseFolderForm.pas' {frmBrowseFolder},
  OTAIntfSearch.MainForm in 'Source\OTAIntfSearch.MainForm.pas' {frmOTAIntfSearch},
  OTAIntfSearch.ProgressForm in 'Source\OTAIntfSearch.ProgressForm.pas' {frmProgress},
  OTAIntfSearch.InterfaceObjectMethods in 'Source\OTAIntfSearch.InterfaceObjectMethods.pas',
  OTAIntfSearch.Constants in 'Source\OTAIntfSearch.Constants.pas',
  OTAIntfSearch.Functions in 'Source\OTAIntfSearch.Functions.pas',
  OTAIntfSearch.InterfaceIndex in 'Source\OTAIntfSearch.InterfaceIndex.pas',
  OTAIntfSearch.OTAServicePaths in 'Source\OTAIntfSearch.OTAServicePaths.pas';

{$R *.RES}

Begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.Title := 'OTA Interface Search';
  Application.CreateForm(TfrmOTAIntfSearch, frmOTAIntfSearch);
  Application.Run;
End.