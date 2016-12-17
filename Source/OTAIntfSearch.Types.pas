(**

  This module contains simply types for use throughout the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Dec 2016

**)
Unit OTAIntfSearch.Types;

Interface

Type
  (** This is an enumerate to define the types of tree branches based on their content. **)
  TLeafType = (
    ltFile,
    ltType,
    ltFunction,
    ltBorlandIDEServices,
    ltLoop,
    ltNotifier,
    ltQueryInterface
  );

  (** This is an enumerate to define the purpose of the applications statusbar panels along
      with their indexes. **)
  TStatusPanelPositions = (
    sppSearchPaths = 0,
    sppFiles       = 1,
    sppMatches     = 2,
    sppRegExMsg    = 3
  );

  (** An enumerate to define whether the target search has found a matching result in a node or
      the nodes path. **)
  TTargetSearchResult = (
    tsrNotFound,
    tsrFound
  );

  (** This record describes the daat held in the interfces virtual treeview nodes. **)
  TTreeData = Record
    FLeafType              : TLeafType;
    FFileIndex             : Integer;
    FInterfaceObjectIndex  : Integer;
    FMethodIndex           : Integer;
    FTargetSearch          : TTargetSearchResult;
  End;

  (** A pointer to the TTreeData record so it can be passed as parameter. **)
  PTreeData = ^TTreeData;

Implementation

End.
