(**

  This module contains common code that is required to be available throughout the application.

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
Unit OTAIntfSearch.Functions;

Interface

Uses
  OTAIntfSearch.Types;

Type
  (** A record to describe the applications build information. **)
  TOISBuildInfo = Record
    FMajor, FMinor, FBugFix, FBuild: Word;
  End;

Const  
  (** A constant string for the bug fix letter. **)
  strBugFix = ' abcdefghijklmnopqrstuvwxyz';
  
  Procedure GetBuildData(Var recBuildData : TOISBuildInfo);
  Function GetCodeIdentifier(Const strCode : String; Const LeafType : TLeafType) : String;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF}
  System.SysUtils,
  System.RegularExpressions,
  WinAPI.Windows,
  OTAIntfSearch.Constants;

(**

  This method rerturns the build information for the application.

  @precon  None.
  @postcon The applications build information is returned.

  @param   recBuildData as a TOISBuildInfo as a reference

**)
Procedure GetBuildData(Var recBuildData : TOISBuildInfo);

Const
  iRightShift = 16;
  iMask = $FFFF;
  
ResourceString
  strVerInfo = 'The application does not contain any version information!';

Var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;

Begin
  VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)), Dummy);
  If VerInfoSize <> 0 Then
    Begin
      GetMem(VerInfo, VerInfoSize);
      Try
        GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize, VerInfo);
        VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);
        recBuildData.FMajor := VerValue^.dwFileVersionMS Shr iRightShift;
        recBuildData.FMinor := VerValue^.dwFileVersionMS And iMask;
        recBuildData.FBugFix := VerValue^.dwFileVersionLS Shr iRightShift;
        recBuildData.FBuild := VerValue^.dwFileVersionLS And iMask;
      Finally
        FreeMem(VerInfo, VerInfoSize);
      End;
    End Else
      Raise Exception.Create(strVerInfo);
End;

(**

  This function returns the identifier from the inferface, class, method or property.

  @precon  None.
  @postcon The identifier of the interface, class, method or property is returned.

  @param   strCode  as a String as a constant
  @param   LeafType as a TLeafType as a constant
  @return  a String

**)
Function GetCodeIdentifier(Const strCode : String; Const LeafType : TLeafType) : String;

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
