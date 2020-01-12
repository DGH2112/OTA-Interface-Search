(**

  This module contains a class for storing lines aof code from a pascal file along with their
  line number and any asociated comments.

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
Unit OTAIntfSearch.ToolsAPIFile;

Interface

Uses
  Generics.Collections,
  OTAIntfSearch.Types,
  OTAIntfSearch.Interfaces;

Type
  (** This class implements the interface IOISToolsAPIFile to provide storage capability for lines
      of code from a pascal file along with their line numbers and comments. **)
  TOISToolsAPIFile = Class(TInterfacedObject, IOISToolsAPIFile)
  Strict Private Type
    (** This record describes the information to be stored for each line of code. **)
    TLineRecord = Record
      FText     : String;
      FLineNo   : Integer;
      FComment  : String;
      FMethods  : IOISInterfaceObjectMethods;
    End;
  Strict Private
    FFileName : String;
    FLines    : TList<TLineRecord>;
  Strict Protected
    // IOTAIntfSearchToolsAPIFile
    Function  GetFileName : String;
    Function  GetInterfaceObjectCount : Integer;
    Function  GetInterfaceObject(Const iIndex : Integer) : String;
    Function  AddLine(Const strLine, strComment : String; Const iLineNo : Integer) : Integer;
    Function  GetComment(Const iIndex : Integer) : String;
    Function  GetLineNo(Const iIndex: Integer): Integer;
    Function  GetInterfaceObjectMethods(Const iIndex: Integer): IOISInterfaceObjectMethods;
  Public
    Constructor Create(Const strFileName : String);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  SysUtils,
  OTAIntfSearch.InterfaceObjectMethods;

(**

  This method adds the line of code along with its line number and comment to the list of items.

  @precon  None.
  @postcon The line of code, comment and line number are stored at the end of the collection.

  @param   strLine    as a String as a constant
  @param   strComment as a String as a constant
  @param   iLineNo    as an Integer as a constant
  @return  an Integer

**)
Function TOISToolsAPIFile.AddLine(Const strLine, strComment : String; Const iLineNo : Integer) : Integer;

Var
  recLineRecord : TLineRecord;

Begin
  recLineRecord.FText := Trim(strLine);
  recLineRecord.FComment :=  strComment;
  recLineRecord.FLineNo := iLineNo;
  recLineRecord.FMethods := TOISInterfaceObjectMethods.Create;
  Result := FLines.Add(recLineRecord);
End;

(**

  This is a constructor for the TToolsAPIFile class.

  @precon  None.
  @postcon Creates an empty internal collection for storing the lines or code and their information.

  @param   strFileName as a String as a constant

**)
Constructor TOISToolsAPIFile.Create(Const strFileName : String);

Begin
  FFileName := strFileName;
  FLines := TList<TLineRecord>.Create;
End;

(**

  This is a destructor for the TToolsAPIFile class.

  @precon  None.
  @postcon Frees the collection from memory.

**)
Destructor TOISToolsAPIFile.Destroy;

Begin
  FLines.Free;
  Inherited Destroy;
End;

(**

  This is a getter method for the LineComment property of the IOISToolsAPIFile interface.

  @precon  iIndex must be a valid index between zero and LineCount - 1.
  @postcon Returns the comment associated with the indexed line of code.

  @param   iIndex as an Integer as a constant
  @return  a String

**)
Function TOISToolsAPIFile.GetComment(Const iIndex: Integer): String;

Begin
  Result := FLines[iIndex].FComment;
End;

(**

  This is a getter method for the FileName property of the IOISToolsAPIFile interface.

  @precon  None.
  @postcon Returns the filename associated with the stored code.

  @return  a String

**)
Function TOISToolsAPIFile.GetFileName : String;

Begin
  Result := FFileName;
End;

(**

  This method is a getter method for the LineText property of the IOISToolsAPIFile interface.

  @precon  iIndex must be a valid index between zero and LineCount - 1.
  @postcon Returns the code for the indexed line in the collection.

  @param   iIndex as an Integer as a constant
  @return  a String

**)
Function TOISToolsAPIFile.GetInterfaceObject(Const iIndex: Integer): String;

Begin
  Result := FLines[iIndex].FText;
End;

(**

  This is a getter method for the LineCount property of the IOISToolsAPIFile interface.

  @precon  None.
  @postcon Returns the number of items in the collection.

  @return  an Integer

**)
Function TOISToolsAPIFile.GetInterfaceObjectCount: Integer;

Begin
  Result := FLines.Count;
End;

(**

  This is a getter method for the InterfaceObjectMethods property.

  @precon  iIndex must be a valid index.
  @postcon Returns reference to the indexed InterfaceObjectMethods implementation.

  @param   iIndex as an Integer as a constant
  @return  an IOISInterfaceObjectMethods

**)
Function TOISToolsAPIFile.GetInterfaceObjectMethods(Const iIndex: Integer): IOISInterfaceObjectMethods;

Begin
  Result := FLines[iIndex].FMethods;
End;

(**

  This is a getter method for the LineNo property of the IOISToolsAPIFile interface.

  @precon  iIndex must be a valid index between zero and LineCount - 1.
  @postcon Returns the line number of the code in the pascal file for the indexed item.

  @param   iIndex as an Integer as a constant
  @return  an Integer

**)
Function TOISToolsAPIFile.GetLineNo(Const iIndex: Integer): Integer;

Begin
  Result := FLines[iIndex].FLineNo;
End;

End.
