(**

  This module contains a class the implements the IOISToolsAPIFiles interfaces for managing multiple
  IOISToolsAPIFile instances.

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
Unit OTAIntfSearch.ToolsAPIFiles;

Interface

Uses
  Generics.Collections,
  OTAIntfSearch.Interfaces;

Type
  (** A class which implements the IOISToolsAPIFiles interface for managing multiple
      IOISToolsAPIFile instances. **)
  TOISToolsAPIFiles = Class(TInterfacedObject, IOISToolsAPIFiles)
  Strict Private
    Type
      (** A record to describe the data for each file. **)
      TFileRecord = Record
        FToolsAPIFile : IOISToolsAPIFile;
      End;
  Strict Private
    FFiles : TList<TFileRecord>;
  Strict Protected
    // IOTAIntfSearchToolsAPIFile
    Function  GetFileCount: Integer;
    Function  GetToolsAPIFile(Const iFileIndex : integer) : IOISToolsAPIFile;
    Function  AddFile(Const strFileName: String): Integer;
    Procedure Clear;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  OTAIntfSearch.ToolsAPIFile;

(**

  This method adds a file to the collection. Returns the index of the added item in the collection.

  @precon  strFileName must be a valid pascal file.
  @postcon The file is added to the collection.

  @param   strFileName as a String as a constant
  @return  an Integer

**)
Function TOISToolsAPIFiles.AddFile(Const strFileName: String): Integer;

Var
  recFileRecord : TFileRecord;

Begin
  recFileRecord.FToolsAPIFile := TOISToolsAPIFile.Create(strFileName);
  Result := FFiles.Add(recFileRecord);
End;

(**

  This method clears the collection of all records.

  @precon  None.
  @postcon The collection of files is empty.

**)
Procedure TOISToolsAPIFiles.Clear;

Begin
  FFiles.Clear;
End;

(**

  This is a constructor for the TToolsAPIFiles class.

  @precon  None.
  @postcon Initialises an internal list to empty.

**)
Constructor TOISToolsAPIFiles.Create;

Begin
  FFiles := TList<TFileRecord>.Create;
End;

(**

  This is a destructor for the TToolsAPIFiles class.

  @precon  None.
  @postcon Frees the memory used by the internal list.

**)
Destructor TOISToolsAPIFiles.Destroy;

Begin
  FFiles.Free;
  Inherited Destroy;
End;

(**

  This is a getter method for the FileCount property of the IOISToolsAPIFiles interface.

  @precon  None.
  @postcon Returns the number of files in the collection.

  @return  an Integer

**)
Function TOISToolsAPIFiles.GetFileCount: Integer;

Begin
  Result := FFiles.Count;
End;

(**

  This is a getter method for the ToolsAPIFile property of the IOISToolsAPIFiles interface.

  @precon  iFileIndex must be a valid index between zero and FileCount - 1.
  @postcon Returns an IOISToolsAPIFile reference for the indexed item.

  @param   iFileIndex as an integer as a constant
  @return  an IOISToolsAPIFile

**)
Function TOISToolsAPIFiles.GetToolsAPIFile(Const iFileIndex : integer): IOISToolsAPIFile;

Begin
  Result := FFiles[iFileIndex].FToolsAPIFile;
End;

End.
