(**

  this module contains code to attempt to generate information (creation path) and possibly code
  that will help other access the Open Tools API.

  @Author  David Hoyle
  @Version 1.0
  @Date    10 Dec 2016

**)
Unit OTAIntfSearch.GenerateOTACode;

Interface

Uses
  Classes,
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.Types,
  VirtualTrees;

Type
  (** A class which implements the IOISgenerateOTACode interface for generating OTA code. **)
  TOISGenerateOTACode = Class(TInterfacedObject, IOISGenerateOTACode)
  Strict Private
    FOISToolsAPIFiles   : IOISToolsAPIFiles;
    FFileIndex          : Integer;
    FToolsAPIFile       : IOISToolsAPIFile;
    FOTACodeTree        : TVirtualStringTree;
    FOISProgressManager : IOISProgressManager;
    FOISInterfaceIndex  : IOISInterfaceIndex;
    FOISServicePaths    : IOISOTAServicePaths;
    FNodeCount          : Integer;
  Strict Protected
    Procedure GenerateCode(iInterfaceObjectIndex, iMethodIndex : Integer; LeafType : TLeafType);
    Function GetIdentifier(iInterfaceObjectIndex, iMethodIndex : Integer;
      LeafType : TLeafType) : String;
    Function AddNode(ParentNode: Pointer; iFileIndex, iInterfaceObjectIndex, iMethodIndex : Integer;
      LeafType: TLeafType): Pointer;
    Function AddInterface(ParentNode: Pointer; iInterfaceObjectIndex : Integer) : Pointer;
    Function AddMethod(ParentNode: Pointer; iInterfaceObjectIndex,
      iMethodIndex : Integer) : Pointer;
    Procedure FindInterfaceRef(ParentNode : PVirtualNode; strIdent : String;
      iParentInterface : Integer);
    Function  IsService(ParentNode : PVirtualNode; strIdent : String;
      iParentInterface : Integer) : Boolean;
    Function  IsDuplicate(ParentNode : PVirtualNode; strIdent : String;
      iInterfaceObjectIndex : Integer) : Boolean;
    Function IsNotifier(ParentNode : PVirtualNode; strIdent, strMethod : String;
      iParentInterface, iInterface, iMethod : Integer) : Boolean;
    Function  IsQueryInterface(ParentNode : PVirtualNode; strIdent : String;
      iParentInterface : Integer) : Boolean;
    Procedure BuildIndex;
  Public
    Constructor Create(OISToolsAPIFiles : IOISToolsAPIFiles; iFileIndex : Integer;
      vstOTACodeTree : TVirtualStringTree; OISProgressManager : IOISProgressManager);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  //CodeSiteLogging,
  SysUtils,
  RegularExpressions,
  OTAIntfSearch.Constants,
  OTAIntfSearch.Functions,
  OTAIntfSearch.InterfaceIndex, OTAIntfSearch.OTAServicePaths;


(**

  This method adds an interface or class reference to the OTA Code tree with the given node as a
  parent.

  @precon  ParentNode must either be a valid node or Nil.
  @postcon The interface / class is added to the OTA Code Tree and if its identifier has been found
           before then the recursive search is stopped. Returns the pointer to the new node created
           in the tree.

  @param   ParentNode            as a Pointer
  @param   iInterfaceObjectIndex as an Integer
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddInterface(ParentNode: Pointer;
  iInterfaceObjectIndex : Integer): Pointer;

Var
  strIdent : String;

Begin
  strIdent := GetIdentifier(iInterfaceObjectIndex, 0, ltType);
  Result := AddNode(ParentNode, FFileIndex, iInterfaceObjectIndex, 0, ltType);
  If IsDuplicate(Result, strIdent, iInterfaceObjectIndex) Then
    Exit;
  FindInterfaceRef(Result, strIdent, iInterfaceObjectIndex);
  IsService(Result, strIdent, iInterfaceObjectIndex);
  IsQueryInterface(Result, strIdent, iInterfaceObjectIndex);
End;

(**

  This method adds a method to the OTA Code Tree with ParentNode as the parent of the new node.

  @precon  ParentNode must either be a valid node or Nil.
  @postcon The function / procedure / property is added to the OTA Code Tree and if its identifier
           has been found before then the recursive search is stopped. Returns the pointer to the
           new node created in the tree.

  @param   ParentNode            as a Pointer
  @param   iInterfaceObjectIndex as an Integer
  @param   iMethodIndex          as an Integer
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddMethod(ParentNode: Pointer; iInterfaceObjectIndex,
  iMethodIndex: Integer): Pointer;

Var
  strIdent : String;

Begin
  strIdent := GetIdentifier(iInterfaceObjectIndex, iMethodIndex, ltFunction);
  Result := AddNode(ParentNode, FFileIndex, iInterfaceObjectIndex, iMethodIndex, ltFunction);
  Result := AddInterface(Result, iInterfaceObjectIndex);
End;

(**

  This method adds a node to the OTA Code Tree using ParentNode as its parent.

  @precon  ParentNode must either be a  valid node or Nil.
  @postcon A new node is added to the OTA Code tree view.

  @param   ParentNode            as a Pointer
  @param   iFileIndex            as an Integer
  @param   iInterfaceObjectIndex as an Integer
  @param   iMethodIndex          as an Integer
  @param   LeafType              as a TLeafType
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddNode(ParentNode: Pointer; iFileIndex, iInterfaceObjectIndex,
  iMethodIndex: Integer; LeafType: TLeafType) : Pointer;

Var
  NodeData : PTreeData;

Begin
  Result := FOTACodeTree.AddChild(ParentNode);
  NodeData := FOTACodeTree.GetNodeData(Result);
  NodeData.FLeafType := LeafType;
  NodeData.FFileIndex := FFileIndex;
  NodeData.FInterfaceObjectIndex := iInterfaceObjectIndex;
  NodeData.FMethodIndex := iMethodIndex;
  Inc(FNodeCount);
End;

(**

  This method build an index of the interface identifiers returned from the properties and
  functions.

  @precon  None.
  @postcon A sorted index of the returned IOTA interfaces is created.

**)
Procedure TOISGenerateOTACode.BuildIndex;

Var
  iInterface : Integer;
  iMethod: Integer;
  MethodRegEx: TRegEx;
  OTAInterfaceRegEx : TRegEx;
  M: TMatch;
  strMatch: String;

Begin
  MethodRegEx := TRegEx.Create(strMethodInterfaceSearch, [roCompiled, roIgnoreCase, roSingleLine]);
  OTAInterfaceRegEx := TRegEx.Create('I[NO]TA[a-z0-9]+', [roCompiled, roIgnoreCase, roSingleLine]);
  FOISInterfaceIndex := TOISInterfaceIndex.Create;
  For iInterface := 0 To FToolsAPIFile.InterfaceObjectCount - 1 Do
    For iMethod := 0 To FToolsAPIFile.InterfaceObjectMethods[iInterface].MethodPropertyCount - 1 Do
      Begin
        M := MethodRegEx.Match(FToolsAPIFile.InterfaceObjectMethods[iInterface].MethodProperty[iMethod]);
        If M.Success Then
          Begin
            strMatch := M.Value;
            M := OTAInterfaceRegEx.Match(strMatch);
            If M.Success Then
              FOISInterfaceIndex.AddInterfaceRef(M.Value, iInterface, iMethod);
          End;
      End;
  FOISInterfaceIndex.SortIndex;
End;

(**

  This is a constructor for the TOISGenerateOTACode class.

  @precon  None.
  @postcon Stores a reference the the OISToolsAPIFiles interface along with a file index for the
           current file to used to generate the code.

  @param   OISToolsAPIFiles   as an IOISToolsAPIFiles
  @param   iFileIndex         as an Integer
  @param   vstOTACodeTree     as a TVirtualStringTree
  @param   OISProgressManager as an IOISProgressManager

**)
Constructor TOISGenerateOTACode.Create(OISToolsAPIFiles : IOISToolsAPIFiles; iFileIndex : Integer;
  vstOTACodeTree : TVirtualStringTree; OISProgressManager : IOISProgressManager);

Begin
  FOISServicePaths := TOISOTAServicePaths.Create(vstOTACodeTree);
  FOISToolsAPIFiles := OISToolsAPIFiles;
  FFileIndex := iFileIndex;
  FToolsAPIFile := FOISToolsAPIFiles.ToolsAPIFile[iFileIndex];
  FOTACodeTree := vstOTACodeTree;
  FOISProgressManager := OISProgressManager;
  FNodeCount := 0;
End;

(**

  Frees an memory used by the class.

  @precon  None.
  @postcon The classes memory is freed.

**)
Destructor TOISGenerateOTACode.Destroy;

Begin
  Inherited Destroy;
End;

(**

  This method attempts to find an interface / class declaration or a method  / property declaration
  which contains a specific identifier reference in its inheritance.

  @precon  ParentNode must be a valid reference or Nil.
  @postcon If an interface / class  / method / property is found that matches then a node is added
           and the search process recursively continued.

  @param   ParentNode       as a PVirtualNode
  @param   strIdent         as a String
  @param   iParentInterface as an Integer

**)
Procedure TOISGenerateOTACode.FindInterfaceRef(ParentNode: PVirtualNode; strIdent: String;
  iParentInterface : Integer);

Var
  iInterface, iMethod : Integer;
  iFirst: Integer;
  iLast: Integer;
  iIndex: Integer;

Begin
  If FOISInterfaceIndex.FindInterface(strIdent, iFirst, iLast) Then
    Begin
      For iIndex := iFirst To iLast Do
        Begin
          iInterface := FOISInterfaceIndex.InterfaceIndex(iIndex);
          If FNodeCount Mod 10 = 0 Then
            FOISProgressManager.Update(1, 0, Format('(%1.0n) %s', [Int(FNodeCount),
              FToolsAPIFile.InterfaceObject[iInterface]]));
          iMethod := FOISInterfaceIndex.MethodIndex(iIndex);
          AddMethod(ParentNode, iInterface, iMethod);
          IsNotifier(ParentNode, strIdent,
            FToolsAPIFile.InterfaceObjectMethods[iInterface].MethodProperty[iMethod], iParentInterface,
            iInterface, iMethod);
        End;
    End;
End;

(**

  This method starts the search process for routes through the OTA code to get to the selected
  interface / class / method / property.

  @precon  None.
  @postcon Starts the search process for routes through the OTA code to get to the selected
           interface / class / method / property.

  @param   iInterfaceObjectIndex as an Integer
  @param   iMethodIndex          as an Integer
  @param   LeafType              as a TLeafType

**)
Procedure TOISGenerateOTACode.GenerateCode(iInterfaceObjectIndex, iMethodIndex : Integer;
  LeafType : TLeafType);

Var
  N: PVirtualNode;

Begin
  FOTACodeTree.BeginUpdate;
  Try
    FOTACodeTree.Clear;
    FOISProgressManager.RegisterStages(1);
    FOISProgressManager.Show(1, 1);
    Try
      BuildIndex;
      Case LeafType Of
        ltType: AddInterface(Nil, iInterfaceObjectIndex);
        ltFunction: AddMethod(Nil, iInterfaceObjectIndex, iMethodIndex);
      End;
      FOISServicePaths.SortServicePaths;
      N := FOISServicePaths.ShortestServicePath;
      If N <> Nil Then
        Begin
          FOTACodeTree.VisiblePath[N] := True;
          FOTACodeTree.FocusedNode := N;
          FOTACodeTree.Selected[N] := True;
        End
    Finally
      FOISProgressManager.Hide;
    End;
  Finally
    FOTACodeTree.EndUpdate;
  End;
End;

(**

  This method extracts the identifier from the specified line of code.

  @precon  the indexes must be valid indexes into the FToolsAPIFile.
  @postcon The identifier of the given line of code is returned.

  @param   iInterfaceObjectIndex as an Integer
  @param   iMethodIndex          as an Integer
  @param   LeafType              as a TLeafType
  @return  a String

**)
Function TOISGenerateOTACode.GetIdentifier(iInterfaceObjectIndex, iMethodIndex: Integer;
  LeafType: TLeafType): String;

Begin
  Case LeafType Of
    ltType:     Result := FToolsAPIFile.InterfaceObject[iInterfaceObjectIndex];
    ltFunction: Result := FToolsAPIFile.InterfaceObjectMethods[iInterfaceObjectIndex].
      MethodProperty[iMethodIndex];
  End;
  Result := GetCodeIdentifier(Result, LeafType);
End;

(**

  This method checks the passed identifier for being a duplicate, i.e. wev have already found this
  identifier before. This method is here to prevent loops.

  @precon  ParentNode must be a valid node and iParentInterface must be a valid index into the
           FToolsAPIFile interfaces.
  @postcon If a duplicate is found a loop node is added under the parent and the functin returns
           true.

  @param   ParentNode               as a PVirtualNode
  @param   strIdent                 as a String
  @param   iInterfaceObjectIndex as an Integer
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsDuplicate(ParentNode: PVirtualNode; strIdent: String;
  iInterfaceObjectIndex : Integer): Boolean;

Var
  P: PVirtualNode;
  NodeData : PTreeData;

Begin
  Result := False;
  P := FOTACodeTree.NodeParent[ParentNode];
  While P <> Nil Do
    Begin
      NodeData := FOTACodeTree.GetNodeData(P);
      If (iInterfaceObjectIndex = NodeData.FInterfaceObjectIndex) And
         (NodeData.FLeafType = ltType) Then
        Begin
          Result := True;
          Break;
        End;
      P := FOTACodeTree.NodeParent[P];
    End;
  If Result Then
    AddNode(ParentNode, FFileIndex, iInterfaceObjectIndex, 0, ltLoop);
End;

(**

  This method tests the given method for being an AddNotifier method.

  @precon  ParentNode must be a valid PVirtualNode or Nil and all the indexes must be valid.
  @postcon If the method is a notifier a special nodes is created.

  @param   ParentNode       as a PVirtualNode
  @param   strIdent         as a String
  @param   strMethod        as a String
  @param   iParentInterface as an Integer
  @param   iInterface       as an Integer
  @param   iMethod          as an Integer
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsNotifier(ParentNode : PVirtualNode; strIdent, strMethod : String;
  iParentInterface, iInterface, iMethod : Integer) : Boolean;

Var
  strSearch : String;
  RE : TRegEx;
  M : TMatch;
  P : PVirtualNode;

Begin
  Result := False;
  strSearch := Format(strNotifierSearchRegEx, [strIdent]);
  RE := TRegEx.Create(strSearch, [roIgnoreCase, roSingleLine]);
  M := RE.Match(strMethod);
  If M.Success Then
    Begin
      Result := True;
      P := AddNode(ParentNode, FFileIndex, iParentInterface, iMethod, ltNotifier);
      AddMethod(P, iInterface, iMethod);
    End;
End;

(**

  This method test the given identifier for being an interface that can be cast to something else.
  If so a special node is created and the search continued.

  @precon  ParentNode must be a valid node or Nil and the parent index must be valid.
  @postcon If the identifier is a notifier a special node is created and the search continued.

  @param   ParentNode       as a PVirtualNode
  @param   strIdent         as a String
  @param   iParentInterface as an Integer
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsQueryInterface(ParentNode : PVirtualNode; strIdent : String;
  iParentInterface : Integer) : Boolean;

Var
  i : Integer;
  P : PVirtualNode;

Begin
  Result := False;
  For i := Low(strQueryInterfaces) To High(strQueryInterfaces) Do
    Begin
      If CompareText(strQueryInterfaces[i, 1], strIdent) = 0 Then
        Begin
          Result := True;
          P := AddNode(ParentNode, FFileIndex, iParentInterface, 0, ltQueryInterface);
          FindInterfaceRef(P, strQueryInterfaces[i, 2], iParentInterface);
        End;
    End;
End;

(**

  This method test the given identifier to determines whether it is a service or not. If so, a
  servive node is added to the tree under the given parent.

  @precon  ParentNode must be a valid node and iParentInterface must be a valid index into the
           FToolsAPIFile interfaces.
  @postcon If a services is found a service node is added under the parent node and returns true
           else returns false.

  @param   ParentNode       as a PVirtualNode
  @param   strIdent         as a String
  @param   iParentInterface as an Integer
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsService(ParentNode : PVirtualNode; strIdent: String;
  iParentInterface : Integer): Boolean;

Var
  RegEx : TRegEx;
  M: TMatch;
  P: Pointer;

Begin
  RegEx := TRegEx.Create(strServiceRegEx, [roIgnoreCase, roSingleLine]);
  M := RegEx.Match(strIdent);
  Result := M.Success;
  If Result Then
    Begin
      P := AddNode(ParentNode, FFileIndex, iParentInterface, 0, ltBorlandIDEServices);
      FOISServicePaths.AddServicePath(P);
    End;
End;

End.
