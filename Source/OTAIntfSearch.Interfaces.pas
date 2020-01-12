(**

  This module contains only interfaces that are used to reference most objects.

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
Unit OTAIntfSearch.Interfaces;

Interface

Uses
  System.Classes,
  VCL.Graphics,
  OTAIntfSearch.Types;

Type
  (** This interface provides methods for reading and writing information to the applications
      INI file. **)
  IOISINIFile = Interface
  ['{0EFC06E6-C585-4E33-A173-EAD71BFA3C3F}']
    Function  ReadInteger(Const strSection, strIdent: String; Const iDefault: Integer) : Integer;
    Procedure WriteInteger(Const strSection, strIdent: String; Const iValue: Integer);
    Function  ReadString(Const strSection, strIdent, strDefault: String) : String;
    Procedure WriteString(Const strSection, strIdent, strValue: String);
    Function  ReadBool(Const strSection, strIdent: String; Const boolDefault: Boolean) : Boolean;
    Procedure WriteBool(Const strSection, strIdent: String; Const boolValue: Boolean);
    Procedure EraseSection(Const strSection : String);
    Procedure ReadSection(Const strSection : String; Const slIdents : TStringList);
    Procedure UpdateFile;
  End;

  (** This interface provide access to an interface or objects collection of methods and
      properties. **)
  IOISInterfaceObjectMethods = Interface
  ['{F1D86A3A-2ADD-43EE-96E9-D1352E04C1B9}']
    Function  GetMethodPropertyCount : Integer;
    Function  GetMethodProperty(Const iIndex : Integer) : String;
    Function  GetLineNo(Const iIndex : Integer) : Integer;
    Function  GetComment(Const iIndex : Integer) : String;
    Function  AddLine(Const strLine, strComment : String; Const iLineNo : Integer) : Integer;
    (**
      This property returns the number of lines of code stored within the ToolsAPIFile.
      @precon  None.
      @postcon The number of lines of code in the file are returned.
      @return  an Integer
    **)
    Property  MethodPropertyCount : Integer Read GetMethodPropertyCount;
    (**
      This property returns the line text from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The line of text is returned.
      @param   iIndex as an Integer as a Constant
      @return  a String
    **)
    Property  MethodProperty[Const iIndex : Integer] : String Read GetMethodProperty;
    (**
      This property returns the line number from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The line number in the source file for the text is returned.
      @param   iIndex as an Integer as a Constant
      @return  an Integer
    **)
    Property  LineNo[Const iIndex : Integer] : Integer Read GetLineNo;
    (**
      This property returns the comment text from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The comment text is returned.
      @param   iIndex as an Integer as a Constant
      @return  a String
    **)
    Property  Comment[Const iIndex : Integer] : String Read GetComment;
  End;

  (** This interface provides methods and properties for adding lines of code (interfaces, classes
      methods and properties to an object for later retreival. **)
  IOISToolsAPIFile = Interface
  ['{D1DA4E11-BF3C-4FE4-B0B2-DDF7E58759BA}']
    Function  GetFileName : String;
    Function  GetInterfaceObjectCount : Integer;
    Function  GetInterfaceObject(Const iIndex : Integer) : String;
    Function  GetLineNo(Const iIndex : Integer) : Integer;
    Function  GetComment(Const iIndex : Integer) : String;
    Function  GetInterfaceObjectMethods(Const iIndex : Integer) : IOISInterfaceObjectMethods;
    Function  AddLine(Const strLine, strComment : String; Const iLineNo : Integer) : Integer;
    (**
      This property returns the filename corrsponding to the data held be the implementing object.
      @precon  None.
      @postcon Returns the filename corrsponding to the data held be the implementing object.
      @return  a String
    **)
    Property  FileName : String Read GetFileName;
    (**
      This property returns the number of lines of code stored within the ToolsAPIFile.
      @precon  None.
      @postcon The number of lines of code in the file are returned.
      @return  an Integer
    **)
    Property  InterfaceObjectCount : Integer Read GetInterfaceObjectCount;
    (**
      This property returns the line text from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The line of text is returned.
      @param   iIndex as an Integer as a Constant
      @return  a String
    **)
    Property  InterfaceObject[Const iIndex : Integer] : String Read GetInterfaceObject;
    (**
      This property returns the line number from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The line number in the source file for the text is returned.
      @param   iIndex as an Integer as a Constant
      @return  an Integer
    **)
    Property  LineNo[Const iIndex : Integer] : Integer Read GetLineNo;
    (**
      This property returns the comment text from the ToolsAPIFile for the given index.
      @precon  iIndex must be a valid index between 0 and LineCount - 1.
      @postcon The comment text is returned.
      @param   iIndex as an Integer as a Constant
      @return  a String
    **)
    Property  Comment[Const iIndex : Integer] : String Read GetComment;
    (**
      This method returns the instance reference of the indexed collection of
      InterfaceObjectMethods.
      @precon  iIndex must be a valid index between 0 and MethodPropertyCount - 1.
      @postcon Returns the instance reference of the indexed collection of InterfaceObjectMethods.
      @param   iIndex as an Integer as a Constant
      @return  an IOISInterfaceObjectMethods
    **)
    Property  InterfaceObjectMethods[Const iIndex : Integer] : IOISInterfaceObjectMethods
      Read GetInterfaceObjectMethods;
  End;

  (** This interface provides methods and properties for managing a collection of IOISToolsAPIFile
      interfaces. **)
  IOISToolsAPIFiles = Interface
  ['{B597E27B-A1EB-4DF4-AB4A-2951F9718EFE}']
    Function  GetFileCount : Integer;
    Function  GetToolsAPIFile(Const iFileIndex : integer) : IOISToolsAPIFile;
    Function  AddFile(Const strFileName : String) : Integer;
    Procedure Clear;
    (**
      This property returns the number of files stored in the ToolsAPIFiles collection.
      @precon  None.
      @postcon Returns the number of files stored in the ToolsAPIFiles collection.
      @return  an Integer
    **)
    Property  FileCount : Integer Read GetFileCount;
    (**
      This property returns the indexed ToolsAPIFile from the collection.
      @precon  iFileIndex must be a valid index between 0 and FileCount - 1.
      @postcon An instance of the indexed ToolsAIPFile is returned.
      @param   iFileIndex as an Integer as a Constant
      @return  an IOISToolsAPIFile
    **)
    Property  ToolsAPIFile[Const iFileIndex : Integer] : IOISToolsAPIFile Read GetToolsAPIFile;
  End;

  (** This interface is provided to allow the file parser interface to update the UI without
      knowing about item implementation. **)
  IOISInterfacesUIUpdater = Interface
  ['{A1FD8F97-6DE0-4B24-89A2-10CA83A53AE1}']
    Procedure UpdateStatusPanel(Const strText: String; Const StatusPanelPosition: TStatusPanelPositions);
    Procedure BeginUpdate;
    Procedure Clear;
    Function AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
      iMethodIndex : Integer; Const LeafType: TLeafType): Pointer;
    Procedure Expand(Const Node : Pointer);
    Procedure EndUpdate;
  End;

  (** This interface provides a method to allow an implementing class to parser a string list
      of search paths. **)
  IOISFileParser = Interface
  ['{8B7F1D02-EC30-44D2-A033-417F8EADE8D3}']
    Procedure ParseFiles(Const slSearchPaths : TStrings);
  End;

  (** This interface provides access to a progress maanger for displaying progress in numerous
      forms (a progress form and through a task bar progress). **)
  IOISProgressManager = Interface
  ['{CD1C7418-3694-44ED-AC82-B2D8CB79606E}']
    Procedure RegisterStages(Const iStages : Integer);
    Procedure Show(Const iStage, iTotal : Integer);
    Procedure Update(Const iStage, iPosition : Integer; Const strFileName : String);
    Procedure Hide;
  End;

  (** This interface provides functionality for generating OTA code from a selected item. **)
  IOISGenerateOTACode = Interface
  ['{3F5C931E-1B1C-4806-B547-0B8597B02A34}']
    Procedure GenerateCode(Const iInterfaceObjectIndex, iMethodIndex : Integer;
      Const LeafType : TLeafType; Const strTargetSearch : String);
    Function AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
      iMethodIndex : Integer; Const LeafType: TLeafType): Pointer;
  End;

  (** This interface provides for an index to search methods and properties that implement
      an interface identifier. **)
  IOISInterfaceIndex = Interface
  ['{DD22D91B-C040-4EAF-9C41-D4695BB8E441}']
    Procedure AddInterfaceRef(Const strInterfaceIdent : String; Const iInterfaceObjectIndex,
      iMethodIndex : Integer);
    Procedure SortIndex;
    Function FindInterface(Const strInterfaceIdent : String; Var iInterfaceObjectIndex,
      iMethodIndex : Integer) : Boolean;
    Function InterfaceIndex(Const iIndex : Integer) : Integer;
    Function MethodIndex(Const iIndex : Integer) : Integer;
  End;

  (** An interface to collection service paths to find the shortest. **)
  IOISOTATargetSearchPaths = Interface
  ['{C60B3C98-9FEC-4566-A0E2-95FD9D364223}']
    Procedure AddServicePath(Const TreeNode : Pointer);
    Procedure SortServicePaths;
    Function  ShortestServicePath : Pointer;
  End;

  (** An enumerate for the various colours that cannot be themed. **)
  TOISOTAColour = (
    ocWindowText,
    ocType,
    ocBorlandIDEServices,
    ocNotifier,
    ocInterface,
    ocLoop,
    ocFilterHighlight,
    ocTargetHighlight,
    ocHighlightText,
    ocAssembler,
    ocCharacter,
    ocComment,
    ocDirective,
    ocNumber,
    ocIdentifier,
    ocReservedWord,
    ocSymbol,
    ocString,
    ocCurrentLineHighlight,
    ocValidRegEx,
    ocInvalidRegEx
  );
  
  (** An interface for the applications configurable options. **)
  IOISOTAOptions = Interface
  ['{77C53E11-3C25-47FB-9643-55C99E953D57}']
    // Getters and Setters
    Function  GetVCLTheme : String;
    Procedure SetVCLTheme(Const strVCLTheme : String);
    Function  GetColour(Const eColour : TOISOTAColour) : TColor;
    Procedure SetColour(Const eColour : TOISOTAColour; Const iValue : TColor);
    Function  GetTreeFontName : String;
    Procedure SetTreeFontName(Const strValue : String);
    Function  GetTreeFontSize : Integer;
    Procedure SetTreeFontSize(Const iValue : Integer);
    Function  GetEditorFontName : String;
    Procedure SetEditorFontName(Const strValue : String);
    Function  GetEditorFontSize : Integer;
    Procedure SetEditorFontSize(Const iValue : Integer);
    // General Methods
    // Properties
    (**
      This property gets and sets the applications VCL Theme.
      @precon  None.
      @postcon Gets and sets the applications VCL Theme.
      @return  a String
    **)
    Property VCLTheme : String Read GetVCLTheme Write SetVCLTheme;
    (**
      This property gets and sets the enumerated option colour.
      @precon  None.
      @postcon Gets and sets the enumerated option colour.
      @param   eColour as a TOISOTAColour as a constant
      @return  a TColor
    **)
    Property Colour[Const eColour : TOISOTAColour] : TColor Read GetColour Write SetColour;
    (**
      This property determines the font name for the tree view.
      @precon  None.
      @postcon Gets and sets the tree font name.
      @return  a String
    **)
    Property TreeFontName : String Read GetTreeFontName Write SetTreeFontName;
    (**
      This property determines the font size for the tree view.
      @precon  None.
      @postcon Gets and sets the tree font size.
      @return  a Integer
    **)
    Property TreeFontSize : Integer Read GetTreeFontSize Write SetTreeFontSize;
    (**
      This property determines the font name for the code editor view.
      @precon  None.
      @postcon Gets and sets the code editor font name.
      @return  a String
    **)
    Property EditorFontName : String Read GetEditorFontName Write SetEditorFontName;
    (**
      This property determines the font size for the code edtior view.
      @precon  None.
      @postcon Gets and sets the code editor font size.
      @return  an Integer
    **)
    Property EditorFontSize : Integer Read GetEditorFontSize Write SetEditorFontSize;
  End;

Implementation

End.