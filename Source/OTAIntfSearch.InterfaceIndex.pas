(**

  This module contains a class which implements the IOISInterfaceSearch interface to provide a quick
  ways to search the OTA for interface referenced returned from functions and properties.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Mar 2018

**)
Unit OTAIntfSearch.InterfaceIndex;

Interface

Uses
  Generics.Defaults,
  Generics.Collections,
  OTAIntfSearch.Interfaces;

Type
  (** A class to implement the interface index interface. **)
  TOISInterfaceIndex = Class(TInterfacedObject, IOISInterfaceIndex)
  Strict Private
  Type
    (** A record to describe the information to be stored in the index. **)
    TIndexInfo = Record
      FInterfaceID: String;
      FInterfaceIndex: Integer;
      FMethodIndex: Integer;
    End;
    (** An IComparer class to allow for custom sorting of the TList<T> collection. **)
    TInterfaceComparer = Class(TComparer<TIndexInfo>)
    Strict Private
    Strict Protected
    Public
      Function Compare(Const Left, Right : TIndexInfo) : Integer; Override;
    End;
  Strict Private
    FIndex: TList<TIndexInfo>;
    FInterfaceComparer : TInterfaceComparer;
  Strict Protected
    Procedure AddInterfaceRef(Const strInterfaceIdent: String; Const iInterfaceObjectIndex,
      iMethodIndex: Integer);
    Procedure SortIndex;
    Function FindInterface(Const strInterfaceIdent: String; Var iStartIndex,
      iEndIndex: Integer): Boolean;
    Function InterfaceIndex(Const iIndex : Integer) : Integer;
    Function MethodIndex(Const iIndex : Integer) : Integer;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  SysUtils;

(**

  This method is an ICompare.Comparer method to allow custom sortng of the generic TList<>
  collection.

  @precon   None.
  @postcon  Sorts the TList<> collection by Interface ID first, Interface Index and then Method
            Index.

  @param   Left  as a TIndexInfo as a constant
  @param   Right as a TIndexInfo as a constant
  @return  an Integer

**)
Function TOISInterfaceIndex.TInterfaceComparer.Compare(Const Left, Right: TIndexInfo): Integer;

Begin
  Result := CompareText(Left.FInterfaceID, Right.FInterfaceID);
  If Result = 0 Then
    Result := Left.FInterfaceIndex - Right.FInterfaceIndex;
  If Result = 0 Then
    Result := Left.FMethodIndex - Right.FMethodIndex;
End;

(**

  This methods adds an item to the end of the collection.

  @precon  None.
  @postcon An item is added to the end of the collection.

  @param   strInterfaceIdent     as a String as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant

**)
Procedure TOISInterfaceIndex.AddInterfaceRef(Const strInterfaceIdent: String;
  Const iInterfaceObjectIndex, iMethodIndex: Integer);

Var
  recItem : TIndexInfo;

Begin
  recItem.FInterfaceID := strInterfaceIdent;
  recItem.FInterfaceIndex := iInterfaceObjectIndex;
  recItem.FMethodIndex := iMethodIndex;
  FIndex.Add(recItem);
End;

(**

  A constructor for the TOISInterfaceIndex class.

  @precon  None.
  @postcon Creates an empty collection and a comparer class.

**)
Constructor TOISInterfaceIndex.Create;

Begin
  FInterfaceComparer := TInterfaceComparer.Create;
  FIndex := TList<TIndexInfo>.Create(FInterfaceComparer);
End;

(**

  A destructor for the TOISInterfaceIndex class.

  @precon  None.
  @postcon Frees the collection.

**)
Destructor TOISInterfaceIndex.Destroy;

Begin
  FIndex.Free;
  Inherited Destroy;
End;

(**

  This method attempts to find the first occurance of the interface name in the collection. If found the 
  methods returns true and ensure that iStartIndex is the first occurance of the interface reference and 
  iEndIndex is the last.

  @precon  None.
  @postcon If found returns true and the start and end index for all the occurances.

  @param   strInterfaceIdent as a String as a constant
  @param   iStartIndex       as an Integer as a reference
  @param   iEndIndex         as an Integer as a reference
  @return  a Boolean

**)
Function TOISInterfaceIndex.FindInterface(Const strInterfaceIdent: String; Var iStartIndex,
  iEndIndex: Integer): Boolean;

Var
  iFirst, iMid, iLast : Integer;
  iCompare: Integer;

Begin
  Result := False;
  iFirst := 0;
  iLast := FIndex.Count - 1;
  While iFirst <= iLast Do
    Begin
      iMid := (iFirst + iLast) Div 2;
      iCompare := CompareText(FIndex[iMid].FInterfaceID, strInterfaceIdent);
      If iCompare = 0 Then
        Begin
          Result := True;
          iStartIndex := iMid;
          While (iStartIndex > 0) And
            (CompareText(FIndex[iStartIndex - 1].FInterfaceID, strInterfaceIdent) = 0) Do
            Dec(iStartIndex);
          iEndIndex := iMid;
          While (iEndIndex < FIndex.Count - 1) And
            (CompareText(FIndex[iEndIndex + 1].FInterfaceID, strInterfaceIdent) = 0) Do
            Inc(iEndIndex);
          Break;
        End Else
      If iCompare > 0 Then
        iLast := iMid - 1
      Else
        iFirst := iMid + 1;
    End;
End;

(**

  This method returns the interface index for the indexed collection item.

  @precon  iIndex must be a valid index.
  @postcon The interface index is returned.

  @param   iIndex as an Integer as a constant
  @return  an Integer

**)
Function TOISInterfaceIndex.InterfaceIndex(Const iIndex: Integer): Integer;

Begin
  Result := FIndex[iIndex].FInterfaceIndex;
End;

(**

  This method returns the method index for the indexed collection item.

  @precon  iIndex must be a valid index.
  @postcon The method index is returned.

  @param   iIndex as an Integer as a constant
  @return  an Integer

**)
Function TOISInterfaceIndex.MethodIndex(Const iIndex: Integer): Integer;

Begin
  Result := FIndex[iIndex].FMethodIndex;
End;

(**

  This method sorts the collection.

  @precon  None.
  @postcon The collection is sorted.

**)
Procedure TOISInterfaceIndex.SortIndex;

Begin
  FIndex.Sort;
End;

End.
