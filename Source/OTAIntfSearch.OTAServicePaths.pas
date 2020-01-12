(**

  This module implements the IOISOTATargetSearchPath interface for storing a list of service
  interfaces with the depth of the associated tree so that the shortest path can be found.

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
Unit OTAIntfSearch.OTAServicePaths;

Interface

Uses
  OTAIntfSearch.Interfaces,
  Generics.Collections,
  Generics.Defaults,
  VirtualTrees, 
  OTAIntfSearch.Types;

Type
  (** A concrete implementation of the IOISOTAServicePath interface, **)
  TOISOTATargetSearchPaths = Class(TInterfacedObject, IOISOTATargetSearchPaths)
  Strict Private
    Type
      (** A record to describe the elements contained in the collection. **)
      TTargetSearchPath = Record
        FServicePath : PVirtualNode;
        FPathLength  : Integer;
      End;
    (** An IComparer class to allow for custom sorting of the TList<T> collection. **)
    TTargetSearchPathComparer = Class(TComparer<TTargetSearchPath>)
    Strict Private
    Strict Protected
    Public
      Function Compare(Const Left, Right : TTargetSearchPath) : Integer; Override;
    End;
  Strict Private
    FServicePaths : TList<TTargetSearchPath>;
    FOTACodeTree  : TVirtualStringTree;
    FComparer     : TTargetSearchPathComparer;
  Strict Protected
    Procedure AddServicePath(Const TreeNode: Pointer);
    Function  ShortestServicePath: Pointer;
    Procedure SortServicePaths;
  Public
    Constructor Create(Const vstOTACodeTree : TVirtualStringTree);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  SysUtils;

(**

  This is a ICompare.Comparer method to sort the TList<> collection.

  @precon  None.
  @postcon Sorts the TList<> by the path length.

  @param   Left  as a TTargetSearchPath as a constant
  @param   Right as a TTargetSearchPath as a constant
  @return  an Integer

**)
Function TOISOTATargetSearchPaths.TTargetSearchPathComparer.Compare(Const Left, Right: TTargetSearchPath): Integer;

Begin
  Result := Left.FPathLength - Right.FPathLength;
End;

(**

  This mehod adds a service path pointer and path length to the collection.

  @precon  TreeNode must be a valid PVirtualNode pointer.
  @postcon Adds a service path and length to the end of the collection.

  @param   TreeNode as a Pointer as a constant

**)
Procedure TOISOTATargetSearchPaths.AddServicePath(Const TreeNode: Pointer);

Var
  P : PVirtualNode;
  recServicePath: TTargetSearchPath;

Begin
  recServicePath.FServicePath := TreeNode;
  recServicePath.FPathLength := 0;
  P := TreeNode;
  While Assigned(P) Do
    Begin
      Inc(recServicePath.FPathLength);
      P := FOTACodeTree.NodeParent[P];
    End;
  FServicePaths.Add(recServicePath);
End;

(**

  A constructor for the TOISOTAServicePaths class.

  @precon  vstOTACodeTree must be a valid instance.
  @postcon Creates an empty collection.

  @param   vstOTACodeTree as a TVirtualStringTree as a constant

**)
Constructor TOISOTATargetSearchPaths.Create(Const vstOTACodeTree: TVirtualStringTree);

Begin
  FComparer := TTargetSearchPathComparer.Create;
  FServicePaths := TList<TTargetSearchPath>.Create(FComparer);
  FOTACodeTree := vstOTACodeTree;
End;

(**

  A destructor for the TOISOTAServicePaths class.

  @precon  None.
  @postcon Frees the collection.

**)
Destructor TOISOTATargetSearchPaths.Destroy;

Begin
  FServicePaths.Free;
  Inherited Destroy;
End;

(**

  This method returns the service path PVitrualTree pointer for the shortest path if there are
  service paths in the collection.

  @precon  None.
  @postcon The shortest service path is returned.

  @return  a Pointer

**)
Function TOISOTATargetSearchPaths.ShortestServicePath: Pointer;

Begin
  Result := Nil;
  If FServicePaths.Count > 0 Then
    Result := FServicePaths[0].FServicePath;
End;

(**

  This method sorts the collection.

  @precon  None.
  @postcon The collection is sorted.

**)
Procedure TOISOTATargetSearchPaths.SortServicePaths;

Begin
  FServicePaths.Sort;
End;

End.
