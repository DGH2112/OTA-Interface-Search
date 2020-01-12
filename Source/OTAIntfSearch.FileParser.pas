(**

  This module contaisn a class which implements the IOISFileParser interface.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Mar 2018

**)
Unit OTAIntfSearch.FileParser;

Interface

Uses
  Classes,
  RegularExpressions,
  OTAIntfSearch.Constants,
  OTAIntfSearch.Interfaces;

Type
  (** A class to implement the IOISFileParser interface. **)
  TOISFileParser = Class(TInterfacedObject, IOISFileParser)
  Strict Private
    Type
        (** This enumerate defines all the regular expression available to the parser. **)
      TParserRegExpr = (
        preTypes,
        preMethods,
        preEnd,
        preSingleLineComment,
        preMultiLineCommentEnd,
        preMultiLineCommentStart,
        preMethodStart,
        prePropertyStart,
        preOpenParenthesis,
        preCloseParenthesis,
        prePropertyFull
      );
    Const
        (** This is a constant array to define the regular expressions corresponding to the above
            enumerates. **)
      strParserRegExpr: Array [Low(TParserRegExpr) .. High(TParserRegExpr)] Of String = (
        strInterfaceObjectStartRegEx,
        strMethodPropertyStartRegEx,
        strEndRegEx,
        strSingleLineCommentRegEx,
        strMultiLineCommentEndRegEx,
        strMultiLineCommentStartRegEx,
        strMethodStartRegEx,
        strPropertyStartRegEx,
        strOpenParenthesisRegEx,
        strCloseParenthesisRegEx,
        strEndingSemiColonRegEx
      );
  Strict Private
    FOISToolsAPIFiles: IOISToolsAPIFiles;
    FOISUIUpdater: IOISInterfacesUIUpdater;
    FOISProgressManager: IOISProgressManager;
    FParserRegExpr: Array [Low(TParserRegExpr) .. High(TParserRegExpr)] Of TRegEx;
    FFileCounter: Integer;
    FStage: Integer;
  Strict Protected
    Procedure ParseFiles(Const slSearchPaths: TStrings);
    Function  RecurseFiles(Const strSearchPath, strSearchPattern: String): Integer;
    Procedure ParseInterfaces(Const iFileIndex: Integer; Const ParentNode: Pointer;
      Const strFileName: String);
    Procedure ParseMethodsAndProperties(Const ParentNode: Pointer; Const iFileIndex,
      iInterfaceObjectIndex: Integer; Const sl: TStringList; Var iLine: Integer);
    Function  GetComment(Const slText: TStrings; Const iLine: Integer): String;
    Function  GetMethodOrProperty(Const sl: TStrings; Var iLine: Integer): String;
    Function  GetMethod(Const sl: TStrings; Var iLine: Integer): String;
    Function  GetProperty(Const sl: TStrings; Var iLine: Integer): String;
    Function  CountFilesInPath(Const strSearchPath, strSearchPattern: String): Integer;
  Public
    Constructor Create(Const ToolsAPIFiles: IOISToolsAPIFiles; Const UIUpdater: IOISInterfacesUIUpdater;
      Const ProgressManager: IOISProgressManager);
  End;

Implementation

Uses
  {$IFDEF DEBUG}
  CodeSiteLogging,
  {$ENDIF DEBUG}
  SysUtils,
  OTAIntfSearch.Types;

(**

  This method counts the number of files (recursively) that match the file pattern provided.

  @precon  None.
  @postcon Returns the number of files found.

  @param   strSearchPath    as a String as a constant
  @param   strSearchPattern as a String as a constant
  @return  an Integer

**)
Function TOISFileParser.CountFilesInPath(Const strSearchPath, strSearchPattern: String): Integer;

Var
  iResult: Integer;
  recSearch: TSearchRec;

Begin
  Result := 0;
  iResult := FindFirst(strSearchPath + strSearchPattern, faAnyFile, recSearch);
  Try
    While iResult = 0 Do
      Begin
        iResult := FindNext(recSearch);
        Inc(Result);
      End;
  Finally
    FindClose(recSearch);
  End;
  iResult := FindFirst(strSearchPath + '*.*', faDirectory, recSearch);
  Try
    While iResult = 0 Do
      Begin
        If (recSearch.Attr And faDirectory <> 0) And (recSearch.Name <> '.') And
          (recSearch.Name <> '..') Then
          Inc(Result, CountFilesInPath(strSearchPath + recSearch.Name + '\', strSearchPattern));
        iResult := FindNext(recSearch);
      End;
  Finally
    FindClose(recSearch);
  End;
End;

(**

  This is a constructor for the TOISFileParser class.

  @precon  ToolsAPIFiles, UIUpdater and ProgressManager must be valid instances.
  @postcon Initialises the class for parsing the files.

  @param   ToolsAPIFiles   as an IOISToolsAPIFiles as a constant
  @param   UIUpdater       as an IOISInterfacesUIUpdater as a constant
  @param   ProgressManager as an IOISProgressManager as a constant

**)
Constructor TOISFileParser.Create(Const ToolsAPIFiles: IOISToolsAPIFiles;
  Const UIUpdater: IOISInterfacesUIUpdater; Const ProgressManager: IOISProgressManager);

Var
  iRegEx: TParserRegExpr;

Begin
  FOISToolsAPIFiles := ToolsAPIFiles;
  FOISUIUpdater := UIUpdater;
  FOISProgressManager := ProgressManager;
  For iRegEx := Low(TParserRegExpr) To High(TParserRegExpr) Do
    FParserRegExpr[iRegEx] := TRegEx.Create(strParserRegExpr[iRegEx],
      [roIgnoreCase, roCompiled, roSingleLine]);
End;

(**

  This method retreives the comment above the given line of the parcal code (in slText).

  @precon  slText must be a valid instance.
  @postcon If there is a comment on or above the given line it is returned.

  @param   slText as a TStrings as a constant
  @param   iLine  as an Integer as a constant
  @return  a String

**)
Function TOISFileParser.GetComment(Const slText: TStrings; Const iLine: Integer): String;

Const
  iBraceCmtChars = 2;

ResourceString
  strNoCommentFound = '(No comment found!)';

Var
  strText: String;
  iCurrentLine: Integer;
  M: TMatch;
  boolEndFound: Boolean;

Begin
  Result := strNoCommentFound;
  iCurrentLine := iLine;
  Repeat
    Dec(iCurrentLine);
    If iCurrentLine < 0 Then
      Exit;
    strText := Trim(slText[iCurrentLine]);
  Until strText <> '';
  M := FParserRegExpr[preSingleLineComment].Match(strText);
  If M.Success Then
    Begin
      Result := Trim(Copy(strText, M.Index + 1, M.Length - iBraceCmtChars));
      Exit;
    End;
  M := FParserRegExpr[preMultiLineCommentEnd].Match(strText);
  If M.Success Then
    Begin
      Result := Trim(Copy(strText, M.Index, M.Length - 1));
      Repeat
        Dec(iCurrentLine);
        If iCurrentLine < 0 Then
          Break;
        strText := Trim(slText[iCurrentLine]);
        M := FParserRegExpr[preMultiLineCommentStart].Match(strText);
        boolEndFound := M.Success;
        If Not boolEndFound Then
          Result := Trim(strText) + #32 + Result
        Else
          Result := Trim(Trim(Copy(strText, M.Index + 1, M.Length - 1)) + #32 + Result);
      Until (boolEndFound);
    End;
End;

(**

  This method parses a method declarations ensure that if it is split across multiple lines it is all 
  picked up.

  @precon  sl must be a valid string list and iLine must be a valid index into sl.
  @postcon The method is parsed and returned.

  @param   sl    as a TStrings as a constant
  @param   iLine as an Integer as a reference
  @return  a String

**)
Function TOISFileParser.GetMethod(Const sl: TStrings; Var iLine: Integer): String;

Begin
  Result := Trim(sl[iLine]);
  While FParserRegExpr[preOpenParenthesis].IsMatch(Result) And
    Not FParserRegExpr[preCloseParenthesis].IsMatch(Result) Do
    Begin
      Inc(iLine);
      If Result <> '' Then
        Result := Result + #32;
      Result := Result + Trim(sl[iLine]);
    End;
End;

(**

  This method dispatches the parsing of the methods and properties to separate methods to ensure we get 
  the whole method or property if split across multiple lines.

  @precon  sl must be a valid string list and iLine a valid index into the string list.
  @postcon The method or properties that was found is returned.

  @param   sl    as a TStrings as a constant
  @param   iLine as an Integer as a reference
  @return  a String

**)
Function TOISFileParser.GetMethodOrProperty(Const sl: TStrings; Var iLine: Integer): String;

Begin
  If FParserRegExpr[preMethodStart].IsMatch(sl[iLine]) Then
    Result := GetMethod(sl, iLine)
  Else If FParserRegExpr[prePropertyStart].IsMatch(sl[iLine]) Then
    Result := GetProperty(sl, iLine)
  Else
    Result := sl[iLine];
End;

(**

  This method returns the declaration of the properties from the given strings list using the provided 
  line number.

  @precon  sl must be a valid instance and iLine must be a valid index.
  @postcon The property declaration is returned.

  @param   sl    as a TStrings as a constant
  @param   iLine as an Integer as a reference
  @return  a String

**)
Function TOISFileParser.GetProperty(Const sl: TStrings; Var iLine: Integer): String;

Begin
  Result := Trim(sl[iLine]);
End;

(**

  This method parses the files found in the search paths provided.

  @precon  slSearchPaths must be a valid instance.
  @postcon The files found in the search paths are parsed for types and methods / properties.

  @param   slSearchPaths as a TStrings as a constant

**)
Procedure TOISFileParser.ParseFiles(Const slSearchPaths: TStrings);

ResourceString
  strSearchPaths = '%d Search Paths';
  strFiles = '%d Files';

Var
  iFile: Integer;
  iFiles: Integer;

Begin
  FOISUIUpdater.UpdateStatusPanel(Format(strSearchPaths, [slSearchPaths.Count]),
    sppSearchPaths);
  FOISToolsAPIFiles.Clear;
  FOISUIUpdater.BeginUpdate;
  Try
    FOISUIUpdater.Clear;
    iFiles := 0;
    FOISProgressManager.RegisterStages(slSearchPaths.Count);
    Try
      FStage := 1;
      For iFile := 0 To slSearchPaths.Count - 1 Do
        Begin
          FFileCounter := 0;
          FOISProgressManager.Show(Succ(iFile), CountFilesInPath(
            ExtractFilePath(slSearchPaths[iFile]),
            ExtractFileName(slSearchPaths[iFile])));
          Inc(iFiles, RecurseFiles(ExtractFilePath(slSearchPaths[iFile]),
            ExtractFileName(slSearchPaths[iFile])));
          Inc(FStage);
        End;
    Finally
      FOISProgressManager.Hide;
    End;
  Finally
    FOISUIUpdater.EndUpdate;
  End;
  FOISUIUpdater.UpdateStatusPanel(Format(strFiles, [iFiles]), sppFiles);
End;

(**

  This method parses the file for classes and interfaces.

  @precon  iFileIndex must be a valid index and ParentNode must either be valid or Nil.
  @postcon The given file is opened and parsed for lines containing interfaces or class definitions.

  @param   iFileIndex  as an Integer as a constant
  @param   ParentNode  as a Pointer as a constant
  @param   strFileName as a String as a constant

**)
Procedure TOISFileParser.ParseInterfaces(Const iFileIndex: Integer; Const ParentNode: Pointer;
  Const strFileName: String);

Var
  sl: TStringList;
  iLine: Integer;
  T: Pointer;
  iIndex: Integer;
  ToolsAPIFile: IOISToolsAPIFile;

Begin
  sl := TStringList.Create;
  Try
    If FileExists(strFileName) Then
      sl.LoadFromFile(strFileName);
    iLine := 0;
    While (iLine < sl.Count) Do
      Begin
        If FParserRegExpr[preTypes].IsMatch(sl[iLine]) Then
          Begin
            ToolsAPIFile := FOISToolsAPIFiles.ToolsAPIFile[iFileIndex];
            iIndex := ToolsAPIFile.AddLine(sl[iLine], GetComment(sl, iLine), Succ(iLine));
            T := FOISUIUpdater.AddNode(ParentNode, iFileIndex, iIndex, 0, ltType);
            ParseMethodsAndProperties(T, iFileIndex, iIndex, sl, iLine);
            FOISUIUpdater.Expand(T);
          End;
        Inc(iLine);
      End;
  Finally
    sl.Free;
  End;
  FOISUIUpdater.Expand(ParentNode);
End;

(**

  This method parses the methods and properties of a class or interface.

  @precon  ParentNode must be valid or Nil, iFileIndex must be valid and sl must be valid.
  @postcon Any method or property found is parsed and added to the file collection.

  @param   ParentNode            as a Pointer as a constant
  @param   iFileIndex            as an Integer as a constant
  @param   iInterfaceObjectIndex as an Integer as a constant
  @param   sl                    as a TStringList as a constant
  @param   iLine                 as an Integer as a reference

**)
Procedure TOISFileParser.ParseMethodsAndProperties(Const ParentNode: Pointer; Const iFileIndex,
  iInterfaceObjectIndex: Integer; Const sl: TStringList; Var iLine: Integer);

Var
  ToolsAPIFile: IOISToolsAPIFile;
  Methods: IOISInterfaceObjectMethods;
  iMethodIndex: Integer;

Begin
  While (iLine < sl.Count) And Not FParserRegExpr[preEnd].IsMatch(sl[iLine]) Do
    Begin
      If FParserRegExpr[preMethods].IsMatch(sl[iLine]) Then
        Begin
          ToolsAPIFile := FOISToolsAPIFiles.ToolsAPIFile[iFileIndex];
          Methods := ToolsAPIFile.InterfaceObjectMethods[iInterfaceObjectIndex];
          iMethodIndex := Methods.AddLine(GetMethodOrProperty(sl, iLine), GetComment(sl, iLine),
            Succ(iLine));
          FOISUIUpdater.AddNode(ParentNode, iFileIndex, iInterfaceObjectIndex, iMethodIndex,
            ltFunction);
        End;
      Inc(iLine);
    End;
End;

(**

  This method recurses the files in the search paths and passes each of them that matches to the 
  interface parser. Returns the number of files found.

  @precon  None.
  @postcon Files are recursed and processed.

  @param   strSearchPath    as a String as a constant
  @param   strSearchPattern as a String as a constant
  @return  an Integer

**)
Function TOISFileParser.RecurseFiles(Const strSearchPath, strSearchPattern: String): Integer;

Var
  N: Pointer;
  recSearch: TSearchRec;
  iResult: Integer;
  strFileName: String;
  iFileIndex: Integer;

Begin
  Result := 0;
  iResult := FindFirst(strSearchPath + strSearchPattern, faAnyFile, recSearch);
  Try
    While iResult = 0 Do
      Begin
        strFileName := strSearchPath + recSearch.Name;
        iFileIndex := FOISToolsAPIFiles.AddFile(strFileName);
        N := FOISUIUpdater.AddNode(Nil, iFileIndex, 0, 0, ltFile);
        ParseInterfaces(iFileIndex, N, strFileName);
        iResult := FindNext(recSearch);
        Inc(Result);
        Inc(FFileCounter);
        FOISProgressManager.Update(FStage, FFileCounter, ExtractFileName(strFileName));
      End;
  Finally
    FindClose(recSearch);
  End;
  iResult := FindFirst(strSearchPath + '*.*', faDirectory, recSearch);
  Try
    While iResult = 0 Do
      Begin
        If (recSearch.Attr And faDirectory <> 0) And (recSearch.Name <> '.') And
          (recSearch.Name <> '..') Then
          RecurseFiles(strSearchPath + recSearch.Name + '\', strSearchPattern);
        iResult := FindNext(recSearch);
      End;
  Finally
    FindClose(recSearch);
  End;
End;

End.
