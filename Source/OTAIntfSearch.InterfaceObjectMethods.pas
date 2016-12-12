(**

  This module contains an implementation of the IOISInterfaceObjectMethods interface. This object
  is a contained for an interface or class`s methods and properties.

  @Author  David Hoyle
  @Version 1.0
  @Date    18 Nov 2016

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
    Function  AddLine(strLine: String; strComment: String; iLineNo: Integer): Integer;
    Function  GetComment(iIndex: Integer): String;
    Function  GetLineNo(iIndex: Integer): Integer;
    Function  GetMethodProperty(iIndex: Integer): String;
    Function  GetMethodPropertyCount: Integer;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

{ TOISInterfaceObjectMethods }

(**

  This method adds the line of code also with its comment and line number to the collection.

  @precon  None.
  @postcon The information is added to the end of the collection.

  @param   strLine    as a String
  @param   strComment as a String
  @param   iLineNo    as an Integer
  @return  an Integer

**)
Function TOISInterfaceObjectMethods.AddLine(strLine, strComment: String; iLineNo: Integer): Integer;

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

  @param   iIndex as an Integer
  @return  a String

**)
Function TOISInterfaceObjectMethods.GetComment(iIndex: Integer): String;

Begin
  Result := FMethods[iIndex].FComment;
End;

(**

  This is a getter method for the LineNo property.

  @precon  iIndex must be a valid index.
  @postcon Returns the line number corresponding to the code in the source file.

  @param   iIndex as an Integer
  @return  an Integer

**)
Function TOISInterfaceObjectMethods.GetLineNo(iIndex: Integer): Integer;

Begin
  Result := FMethods[iIndex].FLineNo;
End;

(**

  This is a getter method for the MethodProperty property.

  @precon  iIndex must be a valid index.
  @postcon Returns the code associated with the indexed method.

  @param   iIndex as an Integer
  @return  a String

**)
Function TOISInterfaceObjectMethods.GetMethodProperty(iIndex: Integer): String;

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
