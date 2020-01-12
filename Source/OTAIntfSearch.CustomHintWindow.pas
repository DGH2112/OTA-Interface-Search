(**

  This module contains a custom THintWindow for the virtual treeview.

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
Unit OTAIntfSearch.CustomHintWindow;

Interface

Uses
  Classes,
  Controls,
  Windows;

Type
  (**
    This class defines a custom hint window to tart up the display of hints over the code.

    The layout of the hint is as follows:

    +-------------------------------------------------------------------+
    |   (padding)                                                       |
    | p Hint Title...                                                 p |
    | a (padding)                                                     a |
    | d ------------------------------------------------------------- d |
    | d (padding)                                                     d |
    | i Multi-line...                                                 i |
    | n   ...comments                                                 n |
    | g (padding)                                                     g |
    +-------------------------------------------------------------------+

  **)
  TOISHintWindow = Class(THintWindow)
  Strict Private
    Const
      (** A constant to describe the padding in and around the hint window. **)
      iPadding = 5;
      (** A constant to define the maximum width of a hint window. **)
      iMaxWidth = 800;
      (** A constant to define the minimum width of a hint window. **)
      iMinWidth = 400;
      (** A set of DrawText drawing options for consistent usage. **)
      iDrawingOptions = DT_LEFT Or DT_WORDBREAK Or DT_NOPREFIX;
  Strict Private
    FHintTitle   : String;
    FHintComment : String;
    FRect        : TRect;
  Strict Protected
  Public
    Constructor Create(AOwner : TComponent); Override;
    Function CalcHintRect(MaxWidth: Integer; const AHint: string;  AData: TCustomData): TRect; Override;
    Procedure Paint; Override;
  End;

Implementation

Uses
  CodeSiteLogging,
  SysUtils,
  Graphics,
  Types;

(**

  This method is an overridden CalcHintRect method to calculate the size of the hint window.

  @precon  None.
  @postcon The returned value is the size of the hin required (also stored in FRect along with the
           hint title and comment in FHintTitle and FHintComment.

  @nocheck MissingCONSTInParam
  @nohint  MaxWidth
  
  @param   MaxWidth as an Integer
  @param   AHint    as a String as a Constant
  @param   AData    as a TCustomData
  @return  a TRect

**)
Function TOISHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string;  AData: TCustomData): TRect;

Const
  iMultiplier = 2;

Var
  iHeight : Integer;
  astrHint : TArray<String>;

Begin
  Result := Inherited CalcHintRect(iMaxWidth, AHint, AData);
  FHintTitle := '';
  FHintComment := '';
  If AHint.CountChar('|') > 0Then
    Begin
      astrHint := AHint.Split(['|']);
      FHintTitle := astrHint[0];
      FHintComment := astrHint[1];
    End;
  Canvas.Font.Style := [fsBold];
  Result.Right := Result.Left + Canvas.TextWidth(FHintTitle) + iPadding * iMultiplier;
  If Result.Right - Result.Left > iMaxWidth Then
    Result.Right := Result.Left + iMaxWidth;
  If Result.Right - Result.Left < iMinWidth Then
    Result.Right := Result.Left + iMinWidth;
  Result.Bottom := Result.Top + iPadding;
  FRect := Result;
  iHeight := DrawText(Canvas.Handle, FHintTitle, Length(FHintTitle), FRect, DT_CALCRECT Or iDrawingOptions);
  Result.Bottom := Result.Bottom + iHeight + iPadding * iMultiplier;
  Canvas.Font.Style := [];
  FRect := Result;
  iHeight := DrawText(Canvas.Handle, FHintComment, Length(FHintComment), FRect, DT_CALCRECT Or iDrawingOptions);
  Result.Bottom := Result.Bottom + iHeight + iPadding;
  FRect := Result;
End;

(**

  This is a constructor for the TOISHintWindow class.

  @precon  None.
  @postcon Sets the font name and size for the hint window.

  @nocheck MissingCONSTInParam
  
  @param   AOwner as a TComponent

**)
Constructor TOISHintWindow.Create(AOwner : TComponent);

Const
  iFontSize = 10;
  strFontName = 'Tahoma';

Begin
  Inherited Create(AOwner);
  Canvas.Font.Name := strFontName;
  Canvas.Font.Size := iFontSize;
End;

(**

  This is an overridden Paint method to draw the new style hint.

  @precon  None.
  @postcon The hint is drawn with the code value in bold at the top, separated from the commment
           by a horizontal line and the comment below.

**)
Procedure TOISHintWindow.Paint;

Var
  iHeight : Integer;
  R : TRect;

Begin
  R := FRect;
  Canvas.Font.Style := [fsBold];
  Canvas.Font.Color := clMaroon;
  Inc(R.Top, iPadding);
  Inc(R.Left, iPadding);
  Dec(R.Right, iPadding);
  iHeight := DrawText(Canvas.Handle, FHintTitle, Length(FHintTitle), R, iDrawingOptions);
  Inc(R.Top, iHeight + iPadding);
  Canvas.Pen.Color := clBlack;
  Canvas.MoveTo(R.Left, R.Top);
  Canvas.LineTo(R.Right, R.Top);
  Inc(R.Top, iPadding);
  Canvas.Font.Style := [];
  Canvas.Font.Color := clNavy;
  DrawText(Canvas.Handle, FHintComment, Length(FHintComment), R, iDrawingOptions);
End;

End.