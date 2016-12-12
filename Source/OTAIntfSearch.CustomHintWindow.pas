(**

  This module contains a custom THintWindow for the virtual treeview.

  @Author  David Hoyle
  @Version 1.0
  @Date    20 Nov 2016

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

  @param   MaxWidth as an Integer
  @param   AHint    as a String as a Constant
  @param   AData    as a TCustomData
  @return  a TRect

**)
Function TOISHintWindow.CalcHintRect(MaxWidth: Integer; const AHint: string;  AData: TCustomData): TRect;

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
  Result.Right := Result.Left + Canvas.TextWidth(FHintTitle) + iPadding * 2;
  If Result.Right - Result.Left > iMaxWidth Then
    Result.Right := Result.Left + iMaxWidth;
  If Result.Right - Result.Left < iMinWidth Then
    Result.Right := Result.Left + iMinWidth;
  Result.Bottom := Result.Top + iPadding;
  FRect := Result;
  iHeight := DrawText(Canvas.Handle, FHintTitle, Length(FHintTitle), FRect, DT_CALCRECT Or iDrawingOptions);
  Result.Bottom := Result.Bottom + iHeight + iPadding * 2;
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

  @param   AOwner as a TComponent

**)
Constructor TOISHintWindow.Create(AOwner : TComponent);

Begin
  Inherited Create(AOwner);
  Canvas.Font.Name := 'Tahoma';
  Canvas.Font.Size := 10;
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