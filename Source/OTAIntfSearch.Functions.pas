(**

  This module contains common code that is required to be available throughout the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    22 Nov 2016

**)
Unit OTAIntfSearch.Functions;

Interface

Uses
  OTAIntfSearch.Types;

  Function GetCodeIdentifier(strCode : String; LeafType : TLeafType) : String;

Implementation

Uses
  //CodeSiteLogging,
  SysUtils,
  RegularExpressions,
  OTAIntfSearch.Constants;

(**

  This function returns the identifier from the inferface, class, method or property.

  @precon  None.
  @postcon The identifier of the interface, class, method or property is returned.

  @param   strCode  as a String
  @param   LeafType as a TLeafType
  @return  a String

**)
Function GetCodeIdentifier(strCode : String; LeafType : TLeafType) : String;

Var
  RegEx: TRegEx;
  M: TMatch;

Begin
  Case LeafType Of
    ltType:
      Begin
        Result := strCode;
        RegEx := TRegEx.Create(strInterfaceClassIdentifier, [roIgnoreCase, roSingleLine]);
        M := RegEx.Match(Result);
        Result := M.Value;
      End;
    ltFunction:
      Begin
        Result := strCode;
        RegEx := TRegEx.Create(strMethodPropertyStartRegEx, [roIgnoreCase, roSingleLine]);
        M := RegEx.Match(Result);
        Delete(Result, M.Index, M.Length);
        RegEx := TRegEx.Create(strGeneralIdentifier, [roIgnoreCase, roSingleLine]);
        M := RegEx.Match(Result);
        Result := M.Value;
      End;
  Else
    Result := strCode;
  End;
End;

End.
