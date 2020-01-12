(**

  This module contains a class which implements the IOISUIUPdate interface for allowing
  a module to update the interface treeview.

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
Unit OTAIntfSearch.UIUpdater;

Interface

Uses
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.Types,
  VirtualTrees,
  ComCtrls;

Type
  (** This class implements the IOISUIUpdater interface for updating thr interface treeview. **)
  TOISUIUpdater = Class(TInterfacedObject, IOISInterfacesUIUpdater)
  Strict Private
    FInterfaces : TVirtualStringTree;
    FStatusBar  : TStatusBar;
  Strict Protected
    Function AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
      iMethodIndex: Integer; Const LeafType: TLeafType): Pointer;
    Procedure BeginUpdate;
    Procedure Clear;
    Procedure EndUpdate;
    Procedure Expand(Const Node: Pointer);
    Procedure UpdateStatusPanel(Const strText: String; Const StatusPanelPosition: TStatusPanelPositions);
  Public
    Constructor Create(Const vstInterfaces: TVirtualStringTree; Const stbrStatusBar: TStatusBar);
  End;

Implementation

(**

  This method adds a node to the interfaces treeview.

  @precon  ParentNode must be a valid not or Nil.
  @postcon A node is added to the interfaces treeview.

  @param   ParentNode            as a Pointer as a constant
  @param   iFileIndex            as an Integer as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   iMethodIndex          as an Integer as a constant
  @param   LeafType              as a TLeafType as a constant
  @return  a Pointer

**)
Function TOISUIUpdater.AddNode(Const ParentNode: Pointer; Const iFileIndex, iInterfaceObjectIndex,
  iMethodIndex: Integer; Const LeafType: TLeafType): Pointer;

Var
  NodeData: PTreeData;

Begin
  Result := FInterfaces.AddChild(ParentNode);
  NodeData := FInterfaces.GetNodeData(Result);
  NodeData.FLeafType := LeafType;
  NodeData.FFileIndex := iFileIndex;
  NodeData.FInterfaceObjectIndex := iInterfaceObjectIndex;
  NodeData.FMethodIndex := iMethodIndex;
End;

(**

  This method starts a update of the treeview by stopping UI updates.

  @precon  None.
  @postcon UI Updates are stopped.

**)
Procedure TOISUIUpdater.BeginUpdate;

Begin
  FInterfaces.BeginUpdate;
End;

(**

  This method clears the interfaces treeview of all Nodes.

  @precon  None.
  @postcon The interfaces treeview is empty.

**)
Procedure TOISUIUpdater.Clear;

Begin
  FInterfaces.Clear;
End;

(**

  This is a constructor for the TOISUIUpdater class.

  @precon  vstInterfaces and stbrStatusBar must be valid instances.
  @postcon The class is initialised with references to the treeview and status bar for updates.

  @param   vstInterfaces as a TVirtualStringTree as a constant
  @param   stbrStatusBar as a TStatusBar as a constant

**)
Constructor TOISUIUpdater.Create(Const vstInterfaces: TVirtualStringTree;
  Const stbrStatusBar: TStatusBar);

Begin
  FInterfaces := vstInterfaces;
  FStatusBar := stbrStatusBar;
End;


(**

  This method end the freezing of screen updates in the tree view.

  @precon  None.
  @postcon The tree view can now update its display.

**)
Procedure TOISUIUpdater.EndUpdate;

Begin
  FInterfaces.EndUpdate;
End;

(**

  This method expands the given node.

  @precon  Node must be a valid pointer to a PVirtualNode record.
  @postcon The given node is expanded.

  @param   Node as a Pointer as a constant

**)
Procedure TOISUIUpdater.Expand(Const Node: Pointer);

Begin
  FInterfaces.Expanded[Node] := True;
End;

(**

  This method updates the referenced status panel with the given text.

  @precon  None.
  @postcon the status bar panel is updated.

  @param   strText             as a String as a constant
  @param   StatusPanelPosition as a TStatusPanelPositions as a constant

**)
Procedure TOISUIUpdater.UpdateStatusPanel(Const strText: String;
  Const StatusPanelPosition: TStatusPanelPositions);

Const
  iPadding = 5;

Begin
  FStatusBar.Panels[Integer(StatusPanelPosition)].Text := strText;
  FStatusBar.Panels[Integer(StatusPanelPosition)].Width :=
    iPadding + FStatusBar.Canvas.TextWidth(strText) + iPadding;
End;

End.
