(**

  This modulel contains a class that implements the IOISINIfile interface for providing INI
  file read / write mechanisms to the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    13 Nov 2016

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
    Function  ReadInteger(const strSection, strIdent: String; iDefault: Integer) : Integer;
    Procedure WriteInteger(const strSection, strIdent: String; iValue: Integer);
    Function  ReadString(const strSection, strIdent, strDefault: String) : String;
    Procedure WriteString(const strSection, strIdent, strValue: String);
    Procedure EraseSection(strSection : String);
    Procedure ReadSection(strSection : String; slIdents : TStringList);
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

Var
  strModuleName : String;
  iSize : Integer;

Begin
  SetLength(strModuleName, MAX_PATH);
  iSize := GetModuleFileName(hInstance, PChar(strModuleName), MAX_PATH);
  SetLength(strModuleName, iSize);
  FINIFileName := ChangeFileExt(ExtractFileName(strModuleName), '');
  FINIFileName :=  Format('%s Settings.INI', [FIniFileName]);
  SetLength(strModuleName, MAX_PATH);
  SHGetFolderPath(0, CSIDL_APPDATA Or CSIDL_FLAG_CREATE, 0, SHGFP_TYPE_CURRENT,
    PChar(strModuleName));
  strModuleName := StrPas(PChar(strModuleName));
  strModuleName := strModuleName + '\Season''s Fall\';
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

  @param   strSection as a String

**)
Procedure TOISMemIniFile.EraseSection(strSection : String);

Begin
  FMemIniFile.EraseSection(strSection);
End;

(**

  This method reads an integer from the inifile.

  @precon  None.
  @postcon The integer is read from the ini file if found else the default it returned.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   iDefault   as an Integer
  @return  an Integer

**)
Function TOISMemIniFile.ReadInteger(const strSection, strIdent: String; iDefault : Integer) : Integer;

Begin
  Result := FMemIniFile.ReadInteger(strSection, strIdent, iDefault);
End;

(**

  This method reads a list of Keys from a section into the given string list.

  @precon  None.
  @postcon The string list returns with a list of key values for the named section.

  @param   strSection as a String
  @param   slIdents   as a TStringList

**)
Procedure TOISMemIniFile.ReadSection(strSection : String; slIdents : TStringList);

Begin
  FMemIniFile.ReadSection(strSection, slIdents);
End;

(**

  This method reads a string from the inifile.

  @precon  None.
  @postcon The string is read from the ini file if found else the default it returned.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   strDefault as a String as a Constant
  @return  a String

**)
Function TOISMemIniFile.ReadString(const strSection, strIdent, strDefault: String) : String;

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

  This method writes an integer to the key and section given.

  @precon  None.
  @postcon The value is written to the ini file.

  @param   strSection as a String as a constant
  @param   strIdent   as a String as a constant
  @param   iValue     as an Integer

**)
Procedure TOISMemIniFile.WriteInteger(const strSection, strIdent: String; iValue: Integer);

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
Procedure TOISMemIniFile.WriteString(const strSection, strIdent, strValue: String);

Begin
  FMemIniFile.WriteString(strSection, strIdent, strValue);
End;

End.