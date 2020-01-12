(**

  This modulel contains a class that implements the IOISINIfile interface for providing INI
  file read / write mechanisms to the application.

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
Unit OTAIntfSearch.MemIniFile;

Interface

Uses
  IniFiles,
  Classes,
  OTAIntfSearch.Interfaces;

Type
  (** A class which implements the IOISINIfile interface for reading anf writing INI file
     information. **)
  TOISMemIniFile = Class(TInterfacedObject, IOISINIFile)
  Strict Private
    FIniFileName : String;
    FMemIniFile  : TMemIniFile;
  Strict Protected
    Procedure BuildIniFile;
    //IOTAIntfSearchIniFile
    Function  ReadInteger(Const strSection, strIdent: String; Const iDefault: Integer) : Integer;
    Procedure WriteInteger(Const strSection, strIdent: String; Const iValue: Integer);
    Function  ReadString(Const strSection, strIdent, strDefault: String) : String;
    Procedure WriteString(Const strSection, strIdent, strValue: String);
    Function  ReadBool(Const strSection, strIdent: String; Const boolDefault: Boolean) : Boolean;
    Procedure WriteBool(Const strSection, strIdent: String; Const boolValue: Boolean);
    Procedure EraseSection(Const strSection : String);
    Procedure ReadSection(Const strSection : String; Const slIdents : TStringList);
    Procedure UpdateFile;
  Public
    Constructor Create;
    Destructor Destroy; Override;
  End;

Implementation

Uses
  SysUtils,
  Windows,
  SHFolder;

(**

  This method builds an INI filename based on the applications name and the users profile.

  @precon  None.
  @postcon The FINIFileName field is set to the users ini file in their profile.

**)
Procedure TOISMemIniFile.BuildIniFile;

Const
  strSeasonFall = '\Season''s Fall\';
  strINIFilePattern = '%s Settings.INI';

Var
  strModuleName : String;
  iSize : Integer;

Begin
  SetLength(strModuleName, MAX_PATH);
  iSize := GetModuleFileName(hInstance, PChar(strModuleName), MAX_PATH);
  SetLength(strModuleName, iSize);
  FINIFileName := ChangeFileExt(ExtractFileName(strModuleName), '');
  FINIFileName :=  Format(strINIFilePattern, [FIniFileName]);
  SetLength(strModuleName, MAX_PATH);
  SHGetFolderPath(0, CSIDL_APPDATA Or CSIDL_FLAG_CREATE, 0, SHGFP_TYPE_CURRENT,
    PChar(strModuleName));
  strModuleName := StrPas(PChar(strModuleName));
  strModuleName := strModuleName + strSeasonFall;
  If Not DirectoryExists(strModuleName) Then
    ForceDirectories(strModuleName);
  FINIFileName := strModuleName + FINIFileName;
End;

(**

  A constructor for the TOISMemIniFile class.

  @precon  None.
  @postcon Sets the ini filename and creates an instance if a memoey ini file.

**)
Constructor TOISMemIniFile.Create;

Begin
  BuildIniFile;
  FMemIniFile := TMemIniFile.Create(FINIFileName);
End;

(**

  A destructor for the TOISMemIniFile class.

  @precon  None.
  @postcon Writes any unwritten data to the INI file and frees its memory.

**)
Destructor TOISMemIniFile.Destroy;

Begin
  FMemIniFile.UpdateFile;
  FMemIniFile.Free;
  Inherited Destroy;
End;

(**

  This method erases a named section from the INI File.

  @precon  None.
  @postcon The named section if found is erased.

  @param   strSection as a String as a constant

**)
Procedure TOISMemIniFile.EraseSection(Const strSection : String);

Begin
  FMemIniFile.EraseSection(strSection);
End;

(**

  This method reads a boolean from the inifile.

  @precon  None.
  @postcon The boolnea is read from the ini file if found else the default it returned.

  @param   strSection  as a String as a constant
  @param   strIdent    as a String as a constant
  @param   boolDefault as a Boolean as a constant
  @return  a Boolean

**)
Function TOISMemIniFile.ReadBool(Const strSection, strIdent: String;
  Const boolDefault: Boolean): Boolean;
  
Begin
  Result := FMemIniFile.ReadBool(strSection, strIdent, boolDefault);
End;

(**

  This method reads an integer from the inifile.

  @precon  None.
  @postcon The integer is read from the ini file if found else the default it returned.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   iDefault   as an Integer as a constant
  @return  an Integer

**)
Function TOISMemIniFile.ReadInteger(Const strSection, strIdent: String;
  Const iDefault : Integer) : Integer;

Begin
  Result := FMemIniFile.ReadInteger(strSection, strIdent, iDefault);
End;

(**

  This method reads a list of Keys from a section into the given string list.

  @precon  None.
  @postcon The string list returns with a list of key values for the named section.

  @param   strSection as a String as a constant
  @param   slIdents   as a TStringList as a constant

**)
Procedure TOISMemIniFile.ReadSection(Const strSection : String; Const slIdents : TStringList);

Begin
  FMemIniFile.ReadSection(strSection, slIdents);
End;

(**

  This method reads a string from the inifile.

  @precon  None.
  @postcon The string is read from the ini file if found else the default it returned.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   strDefault as a String as a constant
  @return  a String

**)
Function TOISMemIniFile.ReadString(Const strSection, strIdent, strDefault: String) : String;

Begin
  Result := FMemIniFile.ReadString(strSection, strIdent, strDefault);
End;

(**

  This method saves the changes to the INI File to disk.

  @precon  None.
  @postcon Changes to the INI File are saved to disk.

**)
Procedure TOISMemIniFile.UpdateFile;

Begin
  FMemIniFile.UpdateFile;
End;

(**

  This method writes a boolean to the key and section given.

  @precon  None.
  @postcon The value is written to the ini file.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   boolValue  as a Boolean as a constant

**)
Procedure TOISMemIniFile.WriteBool(Const strSection, strIdent: String; Const boolValue: Boolean);

Begin
  FMemIniFile.WriteBool(strSection, strIdent, boolValue);
End;

(**

  This method writes an integer to the key and section given.

  @precon  None.
  @postcon The value is written to the ini file.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   iValue     as an Integer as a constant

**)
Procedure TOISMemIniFile.WriteInteger(Const strSection, strIdent: String; Const iValue: Integer);

Begin
  FMemIniFile.WriteInteger(strSection, strIdent, iValue);
End;

(**

  This method writes a string to the key and section given.

  @precon  None.
  @postcon The value is written to the ini file.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   strValue   as a String as a Constant

**)
Procedure TOISMemIniFile.WriteString(Const strSection, strIdent, strValue: String);

Begin
  FMemIniFile.WriteString(strSection, strIdent, strValue);
End;

End.
