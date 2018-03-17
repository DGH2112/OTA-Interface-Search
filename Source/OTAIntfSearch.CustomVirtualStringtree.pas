(**

  This module contains a descendant of a TVirtualStringTree for the sole purpose of allow me to
  override the GetHintWindowClass method to define my own Hint Window.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Mar 2018

**)
Unit OTAIntfSearch.CustomVirtualStringTree;

Interface

Uses
  Classes,
  Controls,
  VirtualTrees;

Type
  (** A descendant class for a virtual strign tree. **)
  TOISVirtualStringtree = Class(TVirtualStringTree)
  Strict Private
  Strict Protected
  Public
    Function GetHintWindowClass: THintWindowClass; Override;
    Constructor Create(AOwner : TComponent); Override;
  End;

Implementation

Uses
  Windows,
  Graphics,
  OTAIntfSearch.CustomHintWindow;

(**

  This is an overridden constructor for this virtual string tree class.

  @precon  AOwner needs to be a valid instance.
  @postcon Sets up the string tree as required for the application.

  @nocheck HardCodedInteger HardCodedString MissingCONSTInParam

  @param   AOwner as a TComponent

**)
Constructor TOISVirtualStringTree.Create(AOwner : TComponent);

Var
  C : TVirtualTreeColumn;

Begin
  Inherited Create(AOwner);
  Left := 0;
  Top := 24;
  Width := 604;
  Height := 154;
  Font.Charset := DEFAULT_CHARSET;
  Font.Color := clWindowText;
  Font.Height := -13;
  Font.Name := 'Tahoma';
  Font.Style := [];
  Header.AutoSizeIndex := 0;
  Header.DefaultHeight := 17;
  Header.Font.Charset := DEFAULT_CHARSET;
  Header.Font.Color := clWindowText;
  Header.Font.Height := -13;
  Header.Font.Name := 'Tahoma';
  Header.Font.Style := [];
  Header.Height := 20;
  Header.Options := [hoAutoResize, hoColumnResize, hoDblClickResize, hoVisible, hoAutoSpring];
  Header.Style := hsFlatButtons;
  HintAnimation := hatNone;
  HintMode := hmHint;
  LineStyle := lsSolid;
  ParentFont := False;
  ParentShowHint := False;
  ShowHint := True;
  TabOrder := 1;
  TreeOptions.MiscOptions := [toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning];
  TreeOptions.PaintOptions := [toShowButtons, toShowDropmark, toShowHorzGridLines, toShowRoot, toShowTreeLines, toShowVertGridLines, toThemeAware, toUseBlendedImages];
  TreeOptions.SelectionOptions := [toFullRowSelect, toRightClickSelect];
  C := Header.Columns.Add;
  C.Options := [coEnabled, coParentBidiMode, coParentColor, coResizable, coVisible, coAutoSpring];
  C.Position := 0;
  C.Width := 550;
  C.Text := 'File / Type / Function';
  C := Header.Columns.Add;
  C.Alignment := taRightJustify;
  C.Options := [coEnabled, coParentBidiMode, coParentColor, coResizable, coVisible];
  C.Position := 1;
  C.Text := 'Line#';
End;

(**

  This is an overrridden GetHintWindowClass method to provide the tree view with a custom hint
  window.

  @precon  None.
  @postcon Returns a class reference for the new hint window.

  @return  a THintWindowClass

**)
Function TOISVirtualStringTree.GetHintWindowClass: THintWindowClass;

Begin
  Result := TOISHintWindow;
End;

End.