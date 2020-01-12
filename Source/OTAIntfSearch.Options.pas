(**
  
  This module contains a class which implements the IOISOTAOptions interfaces for managing applicatiom
  options.

  @Author  David Hoyle
  @Version 1.0
  @Date    12 Jan 2020
  
**)
Unit OTAIntfSearch.Options;

Interface

Uses
  VCL.Graphics,
  OTAIntfSearch.Interfaces;

Type
  (** A class to implement the options interface. **)
  TOISOTAOptions = Class(TInterfacedObject, IOISOTAOptions)
  Strict Private
    FVCLTheme       : String;
    FColours        : Array[TOISOTAColour] Of TColor;
    FIniFile        : IOISINIFile;
    FTreeFontName   : String;
    FTreeFontSize   : Integer;
    FEditorFontName : String;
    FEditorFontSize : Integer;
  Strict Protected
    // IOISOTAOptions
    Function GetColour(Const eColour: TOISOTAColour): TColor;
    Function GetVCLTheme: String;
    Procedure SetColour(Const eColour: TOISOTAColour; Const iValue: TColor);
    Procedure SetVCLTheme(Const strVCLTheme: String);
    Function  GetTreeFontName : String;
    Procedure SetTreeFontName(Const strValue : String);
    Function  GetTreeFontSize : Integer;
    Procedure SetTreeFontSize(Const iValue : Integer);
    Function  GetEditorFontName : String;
    Procedure SetEditorFontName(Const strValue : String);
    Function  GetEditorFontSize : Integer;
    Procedure SetEditorFontSize(Const iValue : Integer);
    // General Methods
    Procedure LoadSettings;
    Procedure SaveSettings;
  Public
    Constructor Create(Const IniFile : IOISINIFile);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  System.TypInfo;

Const
  (** A constant for the Setup INI Section. **)
  strSetupINISection = 'Setup';
  (** A constant for the VCL Theme Name INI Key. **)
  strVCLThemeINIKey = 'VCLTheme';
  (** A constant for the Colcours INI Section. **)
  strColoursINISection = 'Colours';
  (** A constant for the treeview font name INI Key **)
  strTreeFontNameIniKey = 'TreeFontName';
  (** A constant for the treeview font size INI Key **)
  strTreeFontSizeINIKey = 'TreeFontSize';
  (** A constant for the code editor font name INI Key **)
  strEditorFontNameINIKey = 'EditorFontName';
  (** A constant for the code editor font size INI Key **)
  strEditorFontSizeINIKey = 'EditorFontSize';

(**

  A constructor for the TOISOTAOptions class.

  @precon  None.
  @postcon Saves a reference to the INI file and loads the settings.

  @param   IniFile as an IOISINIFile as a constant

**)
Constructor TOISOTAOptions.Create(Const IniFile : IOISINIFile);

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Create', tmoTiming);{$ENDIF}
  FIniFile := IniFile;
  LoadSettings;
End;

(**

  A destructor for the TOISOTAOptions class.

  @precon  None.
  @postcon Saves the settings.

**)
Destructor TOISOTAOptions.Destroy;

Begin
  {$IFDEF CODESITE}CodeSite.TraceMethod(Self, 'Destroy', tmoTiming);{$ENDIF}
  SaveSettings;
  Inherited Destroy;
End;

(**

  This is a getter method for the Colour property.

  @precon  None.
  @postcon Returns the enumerated colour.

  @param   eColour as a TOISOTAColour as a constant
  @return  a TColor

**)
Function TOISOTAOptions.GetColour(Const eColour: TOISOTAColour): TColor;

Begin
  Result := FColours[eColour];
End;

(**

  This is a getter method for the EditorFontName property.

  @precon  None.
  @postcon Returns the font name for the code editor.

  @return  a String

**)
Function TOISOTAOptions.GetEditorFontName: String;

Begin
  Result := FEditorFontName;
End;

(**

  This is a getter method for the EditorFontSize property.

  @precon  None.
  @postcon Returns the Font Size for the editor.

  @return  an Integer

**)
Function TOISOTAOptions.GetEditorFontSize: Integer;

Begin
  Result := FEditorFontSize;
End;

(**

  This is a getter method for the TreeFontName property.

  @precon  None.
  @postcon Returns the font name for the treeviews.

  @return  a String

**)
Function TOISOTAOptions.GetTreeFontName: String;

Begin
  Result := FTreeFontName;
End;

(**

  This is a getter method for the TreeFontSize property.

  @precon  None.
  @postcon returns the Font Size for the Treeviews.

  @return  an Integer

**)
Function TOISOTAOptions.GetTreeFontSize: Integer;

Begin
  Result := FTreeFontSize;
End;

(**

  This is a getter method for the VCLTheme property.

  @precon  None.
  @postcon Returns the name of thr VCL Theme.

  @return  a String

**)
Function TOISOTAOptions.GetVCLTheme: String;

Begin
  Result := FVCLTheme;
End;

(**

  This method loads the settings from the INI file.

  @precon  None.
  @postcon The setting are loaded from the INI File.

**)
Procedure TOISOTAOptions.LoadSettings;

Const
  aiDefaultColours : Array[TOISOTAColour] Of TColor = (
    clWindowText,     // ocWindowText
    clNavy,           // ocType
    clRed,            // ocBorlandIDEServices
    clOlive,          // ocNotifier
    clMaroon,         // ocInterface
    clFuchsia,        // ocLoop
    $D0FFFF,          // ocFilterHighlight
    clLime,           // ocTargetHighlight
    clBlack,          // ocHighlightText
    clNone,           // ocAssemlber
    clNone,           // ocCharacter
    clNone,           // ocComment
    clNone,           // ocDirective
    clNone,           // ocNumber
    clNone,           // ocIdentifier
    clNone,           // ocReservedWord
    clNone,           // ocSymbol
    clNone,           // ocString
    clNone,           // ocCurrentLineHighlight
    clGreen,          // ocVaildRegEx
    clRed             // ocInvalidRegEx
  );
  strDefaultVCLTheme = 'Windows';
  iDefaultFontSize = 10;
  strDefaultTreeFontName = 'Tahoma';
  strDefaultEditorFontName = 'Courier New';

Var
  eColour : TOISOTAColour;
  
Begin
  FVCLTheme := FIniFile.ReadString(strSetupINISection, strVCLThemeINIKey, strDefaultVCLTheme);
  For eColour := Low(TOISOTAColour) To High(TOISOTAColour) Do
    FColours[eColour] := StringToColor(
      FIniFile.ReadString(
        strColoursINISection,
        GetEnumName(TypeInfo(TOISOTAColour), Ord(eColour)),
        ColorToString(aiDefaultColours[eColour])
      )
    );
  FTreeFontName := FINIfile.ReadString(strSetupINISection, strTreeFontNameIniKey,
    strDefaultTreeFontName);
  FTreeFontSize := FINIfile.ReadInteger(strSetupINISection, strTreeFontSizeINIKey, iDefaultFontSize);
  FEditorFontName := FINIfile.ReadString(strSetupINISection, strEditorFontNameINIKey,
    strDefaultEditorFontName);
  FEditorFontSize := FINIfile.ReadInteger(strSetupINISection, strEditorFontSizeINIKey, iDefaultFontSize);
End;

(**

  This method saves the settings.

  @precon  None.
  @postcon The settings are saved.

**)
Procedure TOISOTAOptions.SaveSettings;

Var
  eColour : TOISOTAColour;
  
Begin
  FIniFile.WriteString(strSetupINISection, strVCLThemeINIKey, FVCLTheme);
  For eColour := Low(TOISOTAColour) To High(TOISOTAColour) Do
    FIniFile.WriteString(
      strColoursINISection,
      GetEnumName(TypeInfo(TOISOTAColour), Ord(eColour)),
      ColorToString(FColours[eColour])
    );
  FINIfile.WriteString(strSetupINISection, strTreeFontNameIniKey, FTreeFontName);
  FINIfile.WriteInteger(strSetupINISection, strTreeFontSizeINIKey, FTreeFontSize);
  FINIfile.WriteString(strSetupINISection, strEditorFontNameINIKey, FEditorFontName);
  FINIfile.WriteInteger(strSetupINISection, strEditorFontSizeINIKey, FEditorFontSize);
End;

(**

  This is a setter method for the Colour property.

  @precon  None.
  @postcon Sets the enumerated colour.

  @param   eColour as a TOISOTAColour as a constant
  @param   iValue  as a TColor as a constant

**)
Procedure TOISOTAOptions.SetColour(Const eColour: TOISOTAColour; Const iValue: TColor);

Begin
  FColours[eColour] := iValue;
End;

(**

  This is a setter method for the EditorFontName property.

  @precon  None.
  @postcon Sets the font name for the code editor.

  @param   strValue as a String as a constant

**)
Procedure TOISOTAOptions.SetEditorFontName(Const strValue: String);

Begin
  FEditorFontName := strValue;
End;

(**

  This is a setter method for the EditorFontSize property.

  @precon  None.
  @postcon Sets the font size for the code editor.

  @param   iValue as an Integer as a constant

**)
Procedure TOISOTAOptions.SetEditorFontSize(Const iValue: Integer);

Begin
  FEditorFontSize := iValue;
End;

(**

  This is a setter method for the TreeFontName property.

  @precon  None.
  @postcon Sets the font name for the treeview.

  @param   strValue as a String as a constant

**)
Procedure TOISOTAOptions.SetTreeFontName(Const strValue: String);

Begin
  FTreeFontName := strValue;
End;

(**

  This is a setter method for the TreeFontSize property.

  @precon  None.
  @postcon Sets the font size for the treeviews.

  @param   iValue as an Integer as a constant

**)
Procedure TOISOTAOptions.SetTreeFontSize(Const iValue: Integer);

Begin
  FTreeFontSize := iValue;
End;

(**

  This is a setter method for the VCLTheme property.

  @precon  None.
  @postcon Sets the VCL Theme.

  @param   strVCLTheme as a String as a constant

**)
Procedure TOISOTAOptions.SetVCLTheme(Const strVCLTheme: String);

Begin
  FVCLTheme := strVCLTheme;
End;

End.
