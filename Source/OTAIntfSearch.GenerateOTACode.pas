(**

  This module contains code to attempt to generate information (creation path) and possibly code
  that will help other access the Open Tools API.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Mar 2018

**)
Unit OTAIntfSearch.GenerateOTACode;

Interface

Uses
  Classes,
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.Types,
  VirtualTrees,
  RegularExpressions;

Type
  (** A class which implements the IOISgenerateOTACode interface for generating OTA code. **)
  TOISGenerateOTACode = Class(TInterfacedObject, IOISGenerateOTACode)
  Strict Private
    FOISToolsAPIFiles     : IOISToolsAPIFiles;
    FFileIndex            : Integer;
    FToolsAPIFile         : IOISToolsAPIFile;
    FOTACodeTree          : TVirtualStringTree;
    FOISProgressManager   : IOISProgressManager;
    FOISInterfaceIndex    : IOISInterfaceIndex;
    FOISTargetSearchPaths : IOISOTATargetSearchPaths;
    FNodeCount            : Integer;
    FTargetSearchRegEx    : TRegEx;
    FTargeting            : Boolean;
  Strict Protected
    Procedure GenerateCode(Const iInterfaceObjectIndex, iMethodIndex : Integer;
      Const LeafType : TLeafType; Const strTargetSearch : String);
    Function GetIdentifier(Const iInterfaceObjectIndex, iMethodIndex : Integer;
      Const LeafType : TLeafType) : String;
    Function AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
      iMethodIndex : Integer; Const LeafType: TLeafType): Pointer;
    Function AddInterface(Const ParentNode: Pointer; Const iInterfaceObjectIndex : Integer) : Pointer;
    Function AddMethod(Const ParentNode: Pointer; Const iInterfaceObjectIndex,
      iMethodIndex : Integer) : Pointer;
    Procedure FindInterfaceRef(Const ParentNode : PVirtualNode; Const strIdent : String;
      Const iParentInterface : Integer);
    Function  IsService(Const ParentNode : PVirtualNode; Const strIdent : String;
      Const iParentInterface : Integer) : Boolean;
    Function  IsDuplicate(Const ParentNode : PVirtualNode; Const strIdent : String;
      Const iInterfaceObjectIndex : Integer) : Boolean;
    Function IsNotifier(Const ParentNode : PVirtualNode; Const strIdent, strMethod : String;
      Const iParentInterface, iInterface, iMethod : Integer) : Boolean;
    Function  IsQueryInterface(Const ParentNode : PVirtualNode; Const strIdent : String;
      Const iParentInterface : Integer) : Boolean;
    Procedure BuildIndex;
    Procedure HideNonTargettedNodes(Const StartingNode : PVirtualNode);
    Function  IsTarget(Const Node : PVirtualNode) : Boolean;
  Public
    Constructor Create(Const OISToolsAPIFiles : IOISToolsAPIFiles; Const iFileIndex : Integer;
      Const vstOTACodeTree : TVirtualStringTree; Const OISProgressManager : IOISProgressManager);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils,
  OTAIntfSearch.Constants,
  OTAIntfSearch.Functions,
  OTAIntfSearch.InterfaceIndex,
  OTAIntfSearch.OTAServicePaths;


(**

  This method adds an interface or class reference to the OTA Code tree with the given node as a parent.

  @precon  ParentNode must either be a valid node or Nil.
  @postcon The interface / class is added to the OTA Code Tree and if its identifier has been found 
           before then the recursive search is stopped. Returns the pointer to the new node created in
           the tree.

  @param   ParentNode            as a Pointer as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddInterface(Const ParentNode: Pointer;
  Const iInterfaceObjectIndex : Integer): Pointer;

Var
  strIdent : String;

Begin
  strIdent := GetIdentifier(iInterfaceObjectIndex, 0, ltType);
  Result := AddNode(ParentNode, FFileIndex, iInterfaceObjectIndex, 0, ltType);
  If IsTarget(Result) Then
    Exit;
  If IsDuplicate(Result, strIdent, iInterfaceObjectIndex) Then
    Exit;
  FindInterfaceRef(Result, strIdent, iInterfaceObjectIndex);
  IsService(Result, strIdent, iInterfaceObjectIndex);
  IsQueryInterface(Result, strIdent, iInterfaceObjectIndex);
End;

(**

  This method adds a method to the OTA Code Tree with ParentNode as the parent of the new node.

  @precon  ParentNode must either be a valid node or Nil.
  @postcon The function / procedure / property is added to the OTA Code Tree and if its identifier has 
           been found before then the recursive search is stopped. Returns the pointer to the new node
           created in the tree.

  @param   ParentNode            as a Pointer as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddMethod(Const ParentNode: Pointer; Const iInterfaceObjectIndex,
  iMethodIndex: Integer): Pointer;

Var
  strIdent : String;

Begin
  strIdent := GetIdentifier(iInterfaceObjectIndex, iMethodIndex, ltFunction);
  Result := AddNode(ParentNode, FFileIndex, iInterfaceObjectIndex, iMethodIndex, ltFunction);
  If IsTarget(Result) Then
    Exit;
  Result := AddInterface(Result, iInterfaceObjectIndex);
End;

(**

  This method adds a node to the OTA Code Tree using ParentNode as its parent.

  @precon  ParentNode must either be a valid node or Nil.
  @postcon A new node is added to the OTA Code tree view.

  @param   ParentNode            as a Pointer as a constant
  @param   iFileIndex            as an Integer as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant
  @param   LeafType              as a TLeafType as a constant
  @return  a Pointer

**)
Function TOISGenerateOTACode.AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
  iMethodIndex: Integer; Const LeafType: TLeafType) : Pointer;

Var
  NodeData : PTreeData;
  P : PVirtualNode;

Begin
  Result := FOTACodeTree.AddChild(ParentNode);
  NodeData := FOTACodeTree.GetNodeData(Result);
  NodeData.FLeafType := LeafType;
  NodeData.FFileIndex := FFileIndex;
  NodeData.FInterfaceObjectIndex := iInterfaceObjectIndex;
  NodeData.FMethodIndex := iMethodIndex;
  NodeData.FTargetSearch := tsrNotFound;
  If FTargeting Then
    If FTargetSearchRegEx.IsMatch(FOTACodeTree.Text[Result, 0]) Then
      Begin
        NodeData.FTargetSearch := tsrFound;
        // Mark path to node as found
        P := FOTACodeTree.NodeParent[Result];
        While P <> Nil Do
          Begin
            NodeData := FOTACodeTree.GetNodeData(P);
            NodeData.FTargetSearch := tsrFound;
            P := FOTACodeTree.NodeParent[P];
          End;
      End;
  Inc(FNodeCount);
End;

(**

  This method build an index of the interface identifiers returned from the properties and
  functions.

  @precon  None.
  @postcon A sorted index of the returned IOTA interfaces is created.

**)
Procedure TOISGenerateOTACode.BuildIndex;

Const
  strNOTAPattern = 'I[NO]TA[a-z0-9]+';

Var
  iInterface : Integer;
  iMethod: Integer;
  MethodRegEx: TRegEx;
  OTAInterfaceRegEx : TRegEx;
  M: TMatch;
  strMatch: String;

Begin
  MethodRegEx := TRegEx.Create(strMethodInterfaceSearch, [roCompiled, roIgnoreCase, roSingleLine]);
  OTAInterfaceRegEx := TRegEx.Create(strNOTAPattern, [roCompiled, roIgnoreCase, roSingleLine]);
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
  @postcon Stores a reference the the OISToolsAPIFiles interface along with a file index for the current
           file to used to generate the code.

  @param   OISToolsAPIFiles   as an IOISToolsAPIFiles as a constant
  @param   iFileIndex         as an Integer as a constant
  @param   vstOTACodeTree     as a TVirtualStringTree as a constant
  @param   OISProgressManager as an IOISProgressManager as a constant

**)
Constructor TOISGenerateOTACode.Create(Const OISToolsAPIFiles : IOISToolsAPIFiles;
  Const iFileIndex : Integer; Const vstOTACodeTree : TVirtualStringTree;
  Const OISProgressManager : IOISProgressManager);

Begin
  FOISTargetSearchPaths := TOISOTATargetSearchPaths.Create(vstOTACodeTree);
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

  This method attempts to find an interface / class declaration or a method / property declaration which 
  contains a specific identifier reference in its inheritance.

  @precon  ParentNode must be a valid reference or Nil.
  @postcon If an interface / class / method / property is found that matches then a node is added and 
           the search process recursively continued.

  @param   ParentNode       as a PVirtualNode as a constant
  @param   strIdent         as a String as a constant
  @param   iParentInterface as an Integer as a constant

**)
Procedure TOISGenerateOTACode.FindInterfaceRef(Const ParentNode: PVirtualNode; Const strIdent: String;
  Const iParentInterface : Integer);

Const
  iUpdateCount = 10;

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
          If FNodeCount Mod iUpdateCount = 0 Then
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

  This method starts the search process for routes through the OTA code to get to the selected interface 
  / class / method / property.

  @precon  None.
  @postcon Starts the search process for routes through the OTA code to get to the selected interface / 
           class / method / property.

  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant
  @param   LeafType              as a TLeafType as a constant
  @param   strTargetSearch       as a String as a constant

**)
Procedure TOISGenerateOTACode.GenerateCode(Const iInterfaceObjectIndex, iMethodIndex : Integer;
  Const LeafType : TLeafType; Const strTargetSearch : String);

Var
  N: PVirtualNode;

Begin
  FTargeting := strTargetSearch <> '';
  If FTargeting Then
    FTargetSearchRegEx := TRegEx.Create(strTargetSearch, [roIgnoreCase, roCompiled, roSingleLine]);
  FOTACodeTree.BeginUpdate;
  Try
    FOTACodeTree.Clear;
    FOISProgressManager.RegisterStages(1);
    FOISProgressManager.Show(1, 1);
    Try
      BuildIndex;
      Case LeafType Of
        ltType: N := AddInterface(Nil, iInterfaceObjectIndex);
        ltFunction: N := AddMethod(Nil, iInterfaceObjectIndex, iMethodIndex);
      Else
        N := Nil;
      End;
      If FTargeting Then
        HideNonTargettedNodes(N);
      FOISTargetSearchPaths.SortServicePaths;
      N := FOISTargetSearchPaths.ShortestServicePath;
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

  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant
  @param   LeafType              as a TLeafType as a constant
  @return  a String

**)
Function TOISGenerateOTACode.GetIdentifier(Const iInterfaceObjectIndex, iMethodIndex: Integer;
  Const LeafType: TLeafType): String;

Begin
  Case LeafType Of
    ltType:     Result := FToolsAPIFile.InterfaceObject[iInterfaceObjectIndex];
    ltFunction: Result := FToolsAPIFile.InterfaceObjectMethods[iInterfaceObjectIndex].
      MethodProperty[iMethodIndex];
  End;
  Result := GetCodeIdentifier(Result, LeafType);
End;

(**

  This method hides an nodes in the OTA Code Tree that have not matched the target search or on a path to
  a target search.

  @precon  StartingNode must be a valid node.
  @postcon Nodes no matching the target search are hidden.

  @param   StartingNode as a PVirtualNode as a constant

**)
Procedure TOISGenerateOTACode.HideNonTargettedNodes(Const StartingNode : PVirtualNode);

Begin
  If StartingNode <> Nil Then
    FOTACodeTree.IterateSubtree(
      StartingNode,
      Procedure(Sender: TBaseVirtualTree; Node: PVirtualNode; Data: Pointer;
        Var Abort: Boolean)
      Var
        NodeData: PTreeData;
        N: PVirtualNode;
        strText: String;
        ToolsAPIFile: IOISToolsAPIFile;
      Begin
        NodeData := Sender.GetNodeData(Node);
        ToolsAPIFile := FOISToolsAPIFiles.ToolsAPIFile[NodeData.FFileIndex];
        If NodeData.FLeafType = ltType Then
          strText := ToolsAPIFile.InterfaceObject[NodeData.FInterfaceObjectIndex]
        Else
          strText := ToolsAPIFile.InterfaceObjectMethods[NodeData.FInterfaceObjectIndex].
            MethodProperty[NodeData.FMethodIndex];
        Sender.IsVisible[Node] := NodeData.FTargetSearch = tsrFound;
        If Sender.IsVisible[Node] Then
          Begin
            N := Sender.NodeParent[Node];
            While N <> Nil Do
              Begin
                Sender.IsVisible[N] := True;
                N := Sender.NodeParent[N];
              End;
          End;
      End,
      Nil
      );
End;

(**

  This method checks the passed identifier for being a duplicate, i.e. wev have already found this 
  identifier before. This method is here to prevent loops.

  @precon  ParentNode must be a valid node and iParentInterface must be a valid index into the 
           FToolsAPIFile interfaces.
  @postcon If a duplicate is found a loop node is added under the parent and the functin returns true.

  @param   ParentNode            as a PVirtualNode as a constant
  @param   strIdent              as a String as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsDuplicate(Const ParentNode: PVirtualNode; Const strIdent: String;
  Const iInterfaceObjectIndex : Integer): Boolean;

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

  @param   ParentNode       as a PVirtualNode as a constant
  @param   strIdent         as a String as a constant
  @param   strMethod        as a String as a constant
  @param   iParentInterface as an Integer as a constant
  @param   iInterface       as an Integer as a constant
  @param   iMethod          as an Integer as a constant
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsNotifier(Const ParentNode : PVirtualNode; Const strIdent,
  strMethod : String; Const iParentInterface, iInterface, iMethod : Integer) : Boolean;

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

  This method test the given identifier for being an interface that can be cast to something else. If so 
  a special node is created and the search continued.

  @precon  ParentNode must be a valid node or Nil and the parent index must be valid.
  @postcon If the identifier is a notifier a special node is created and the search continued.

  @param   ParentNode       as a PVirtualNode as a constant
  @param   strIdent         as a String as a constant
  @param   iParentInterface as an Integer as a constant
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsQueryInterface(Const ParentNode : PVirtualNode; Const strIdent : String;
  Const iParentInterface : Integer) : Boolean;

Const
  iIdentifier = 1;
  iParentIdentifier = 2;

Var
  i : Integer;
  P : PVirtualNode;

Begin
  Result := False;
  For i := Low(strQueryInterfaces) To High(strQueryInterfaces) Do
    Begin
      If CompareText(strQueryInterfaces[i, iIdentifier], strIdent) = 0 Then
        Begin
          Result := True;
          P := AddNode(ParentNode, FFileIndex, iParentInterface, 0, ltQueryInterface);
          FindInterfaceRef(P, strQueryInterfaces[i, iParentIdentifier], iParentInterface);
        End;
    End;
End;

(**

  This method test the given identifier to determines whether it is a service or not. If so, a servive 
  node is added to the tree under the given parent.

  @precon  ParentNode must be a valid node and iParentInterface must be a valid index into the 
           FToolsAPIFile interfaces.
  @postcon If a services is found a service node is added under the parent node and returns true else 
           returns false.

  @param   ParentNode       as a PVirtualNode as a constant
  @param   strIdent         as a String as a constant
  @param   iParentInterface as an Integer as a constant
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsService(Const ParentNode : PVirtualNode; Const strIdent: String;
  Const iParentInterface : Integer): Boolean;

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
      If Not FTargeting Then
        FOISTargetSearchPaths.AddServicePath(P);
    End;
End;

(**

  This method checks the given node as to whether its a target search node and if so returns true and 
  adds the node to the TargetSearchPaths collection.

  @precon  Node must be a valid node.
  @postcon Checks the given node as to whether its a target search node and if so returns true and adds 
           the node to the TargetSearchPaths collection.

  @param   Node as a PVirtualNode as a constant
  @return  a Boolean

**)
Function TOISGenerateOTACode.IsTarget(Const Node : PVirtualNode): Boolean;

Begin
  Result := False;
  If FTargeting Then
    If FTargetSearchRegEx.IsMatch(FOTACodeTree.Text[Node, 0]) Then
      Begin
        FOISTargetSearchPaths.AddServicePath(Node);
        Result := True;
      End;
End;

End.
