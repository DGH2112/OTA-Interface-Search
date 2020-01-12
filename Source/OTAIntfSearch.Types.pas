(**

  This module contains simply types for use throughout the application.

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
    sppSearchPaths,
    sppFiles,
    sppMatches,
    sppRegExMsg
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
