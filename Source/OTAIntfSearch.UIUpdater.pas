(**

  This module contains a class which implements the IOISUIUPdate interface for allowing
  a module to update the interface treeview.

  @Author  David Hoyle
  @Version 1.0
  @Date    22 Nov 2016

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
    Function AddNode(ParentNode: Pointer; iFileIndex, iInterfaceObjectIndex, iMethodIndex: Integer;
      LeafType: TLeafType): Pointer;
    Procedure BeginUpdate;
    Procedure Clear;
    Procedure EndUpdate;
    Procedure Expand(Node: Pointer);
    Procedure UpdateStatusPanel(strText: String;
      StatusPanelPosition: TStatusPanelPositions);
  Public
    Constructor Create(vstInterfaces: TVirtualStringTree; stbrStatusBar: TStatusBar);
  End;

Implementation

{ TOISUIUpdater }

(**

  This method adds a node to the interfaces treeview.

  @precon  ParentNode must be a valid not or Nil.
  @postcon A node is added to the interfaces treeview.

  @param   ParentNode            as a Pointer
  @param   iFileIndex            as an Integer
  @param   iInterfaceObjectIndex as an Integer
  @param   iMethodIndex          as an Integer
  @param   LeafType              as a TLeafType
  @return  a Pointer

**)
Function TOISUIUpdater.AddNode(ParentNode: Pointer; iFileIndex, iInterfaceObjectIndex,
  iMethodIndex: Integer; LeafType: TLeafType): Pointer;

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

  @param   vstInterfaces  as a TVirtualStringtree
  @param   stbrStatusBar  as a TStatusBar

**)
Constructor TOISUIUpdater.Create(vstInterfaces: TVirtualStringTree; stbrStatusBar: TStatusBar);

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

  @param   Node as a Pointer

**)
Procedure TOISUIUpdater.Expand(Node: Pointer);

Begin
  FInterfaces.Expanded[Node] := True;
End;

(**

  This method updates the referenced status panel with the given text.

  @precon  None.
  @postcon the status bar panel is updated.

  @param   strText             as a String
  @param   StatusPanelPosition as a TStatusPanelPositions

**)
Procedure TOISUIUpdater.UpdateStatusPanel(strText: String;
  StatusPanelPosition: TStatusPanelPositions);

Begin
  FStatusBar.Panels[Integer(StatusPanelPosition)].Text := strText;
  FStatusBar.Panels[Integer(StatusPanelPosition)].Width :=
    5 + FStatusBar.Canvas.TextWidth(strText) + 5;
End;

End.
