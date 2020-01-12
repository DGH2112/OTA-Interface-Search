(**

  This project is an applications to provide the ability to search Open Tools API files (OTA)
  for insterfaces and class, search using regular expressions for matches in the class / interface
  declarations and thei methods and properties. The objective is to allow a user to quickly find
  the interfaces the want to implement and provide information one how they can be accessed.

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

  @nocheck HardCodedString

**)
Program OTAIntfSearch;

{$R 'OTAIntfSearchITHVerInfo.res' 'OTAIntfSearchITHVerInfo.RC'}

{$WARN SYMBOL_PLATFORM OFF}
{$WARN UNIT_PLATFORM OFF}

uses
  {$IFDEF EurekaLog}
  EMemLeaks,
  EResLeaks,
  ESendMailMAPI,
  ESendMailSMAPI,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EFixSafeCallException,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  {$ENDIF EurekaLog}
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
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
  OTAIntfSearch.OTAServicePaths in 'Source\OTAIntfSearch.OTAServicePaths.pas',
  OTAIntfSearch.OptionsForm in 'Source\OTAIntfSearch.OptionsForm.pas' {frmOTAOptions},
  OTAIntfSearch.Options in 'Source\OTAIntfSearch.Options.pas';

{$R *.RES}

Begin
  ReportMemoryLeaksOnShutdown := DebugHook <> 0;
  Application.Initialize;
  Application.Title := 'OTA Interface Search';
  Application.CreateForm(TfrmOTAIntfSearch, frmOTAIntfSearch);
  Application.Run;
End.


