(**

  This module contains an implementation of the IOISInterfaceObjectMethods interface. This object
  is a contained for an interface or class`s methods and properties.

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
Unit OTAIntfSearch.InterfaceObjectMethods;

Interface

Uses
  Generics.Collections,
  OTAIntfSearch.Types,
  OTAIntfSearch.Interfaces;

Type
  (** This class implements the interface IOISInterfaceObjectMethods. **)
  TOISInterfaceObjectMethods = Class(TInterfacedObject, IOISInterfaceObjectMethods)
  Strict Private
    Type
      (** This record describes the context of a single item in this collection. **)
      TMethodProperty = Record
        FText    : String;
        FComment : String;
        FLineNo  : Integer;
      End;
  Strict Private
    FMethods : TList<TMethodProperty>;
  Strict Protected
    Function  AddLine(Const strLine, strComment: String; Const iLineNo: Integer): Integer;
    Function  GetComment(Const iIndex: Integer): String;
    Function  GetLineNo(Const iIndex: Integer): Integer;
    Function  GetMethodProperty(Const iIndex: Integer): String;
    Function  GetMethodPropertyCount: Integer;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

(**

  This method adds the line of code also with its comment and line number to the collection.

  @precon  None.
  @postcon The information is added to the end of the collection.

  @param   strLine    as a String as a constant
  @param   strComment as a String as a constant
  @param   iLineNo    as an Integer as a constant
  @return  an Integer

**)
Function TOISInterfaceObjectMethods.AddLine(Const strLine, strComment: String;
  Const iLineNo: Integer): Integer;

Var
  recMethod : TMethodProperty;

Begin
  recMethod.FText := strLine;
  recMethod.FComment := strComment;
  recMethod.FLineNo := iLineNo;
  Result := FMethods.Add(recMethod);
End;

(**

  This is a constructor for the TOISInterfaceObjectMethods class.

  @precon  None.
  @postcon the collection is initialised to empty.

**)
Constructor TOISInterfaceObjectMethods.Create;

Begin
  FMethods := TList<TMethodProperty>.Create;
End;

(**

  This is a destructor for the IOISInterfaceObjectMethods class.

  @precon  None.
  @postcon Frees the memory used by the class.

**)
Destructor TOISInterfaceObjectMethods.Destroy;

Begin
  FMethods.Free;
  Inherited Destroy;
End;

(**

  This is a getter method for the Comment property.

  @precon  iIndex must be a valid index.
  @postcon Returns the comment associated with the indexed method.

  @param   iIndex as an Integer as a constant
  @return  a String

**)
Function TOISInterfaceObjectMethods.GetComment(Const iIndex: Integer): String;

Begin
  Result := FMethods[iIndex].FComment;
End;

(**

  This is a getter method for the LineNo property.

  @precon  iIndex must be a valid index.
  @postcon Returns the line number corresponding to the code in the source file.

  @param   iIndex as an Integer as a constant
  @return  an Integer

**)
Function TOISInterfaceObjectMethods.GetLineNo(Const iIndex: Integer): Integer;

Begin
  Result := FMethods[iIndex].FLineNo;
End;

(**

  This is a getter method for the MethodProperty property.

  @precon  iIndex must be a valid index.
  @postcon Returns the code associated with the indexed method.

  @param   iIndex as an Integer as a constant
  @return  a String

**)
Function TOISInterfaceObjectMethods.GetMethodProperty(Const iIndex: Integer): String;

Begin
  Result := FMethods[iIndex].FText;
End;

(**

  This is a getter method for the MethodPropertyCount property.

  @precon  None.
  @postcon Returns the number items in the collection.

  @return  an Integer

**)
Function TOISInterfaceObjectMethods.GetMethodPropertyCount: Integer;

Begin
  Result := FMethods.Count;
End;

End.
