(** 

  This module contains a class which implements an optiosn form for the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    11 Jan 2020

**)
Unit OTAIntfSearch.OptionsForm;

Interface

Uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ComCtrls,
  OTAIntfSearch.Interfaces;

Type
  (** A class which implements a form interfaces for the options dialogue. **)
  TfrmOTAOptions = Class(TForm)
    pnlFudge: TPanel;
    lblVCLTheme: TLabel;
    lblColourName: TLabel;
    lblColour: TLabel;
    cbxVCLTheme: TComboBox;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    cbxColour: TColorBox;
    cbxColourName: TComboBox;
    lblTreeFontName: TLabel;
    cbxTreeFontName: TComboBox;
    edtTreeFontSize: TEdit;
    lblTreeFontSize: TLabel;
    udTreeFontSize: TUpDown;
    edtEditorFontSize: TEdit;
    udEditorFontSize: TUpDown;
    lblEditorFontSize: TLabel;
    cbxEditorFontName: TComboBox;
    lblEditorFontName: TLabel;
    procedure cbxColourNameSelect(Sender: TObject);
    procedure cbxColourSelect(Sender: TObject);
  Strict Private
    FColours : Array[TOISOTAColour] Of TColor;
  Strict Protected
    Procedure InitialiseDlg(Const Options : IOISOTAOptions);
    Procedure FinaliseDlg(Const Options : IOISOTAOptions);
  Public
    Class Function Execute(Const Options : IOISOTAOptions) : Boolean;
  End;

Implementation

{$R *.dfm}

Uses
  VCL.Themes;

(**

  This is an on select event handler for the Colour Name Combo Control.

  @precon  None.
  @postcon Updates the selected colour to the selected named colour.

  @param   Sender as a TObject

**)
Procedure TfrmOTAOptions.cbxColourNameSelect(Sender: TObject);

Begin
  cbxColour.Selected := FColours[TOISOTAColour(cbxColourName.ItemIndex)];
End;

(**

  This is an on select event handler for the Colour Combo Control.

  @precon  None.
  @postcon Updates the internal colour to the selected colour.

  @param   Sender as a TObject

**)
Procedure TfrmOTAOptions.cbxColourSelect(Sender: TObject);

Begin
  FColours[TOISOTAColour(cbxColourName.ItemIndex)] := cbxColour.Selected;
End;

(**

  This is the main method for invoking the dialogue.

  @precon  Options must be a valid instance.
  @postcon Creates an instance of the dialogue and initialise it. If confirmed the options are updated.

  @param   Options as an IOISOTAOptions as a constant
  @return  a Boolean

**)
Class Function TfrmOTAOptions.Execute(Const Options: IOISOTAOptions): Boolean;

Var
  F : TfrmOTAOptions;
  
Begin
  Result := False;
  F := TfrmOTAOptions.Create(Application.MainForm);
  Try
    F.InitialiseDlg(Options);
    If F.ShowModal = mrOK Then
      Begin
        F.FinaliseDlg(Options);
        Result := True;
      End;
  Finally
    F.Free;
  End;
End;

(**

  This method saves the dialogues settigns back to the options.

  @precon  Options must be a valid instance.
  @postcon The options are updated to the settings configured in the dialogue.

  @param   Options as an IOISOTAOptions as a constant

**)
Procedure TfrmOTAOptions.FinaliseDlg(Const Options: IOISOTAOptions);

Var
  eColour : TOISOTAColour;

Begin
  Options.VCLTheme := cbxVCLTheme.Text;
  Options.TreeFontName := cbxTreeFontName.Text;
  Options.TreeFontSize := udTreeFontSize.Position;
  Options.EditorFontName := cbxEditorFontName.Text;
  Options.EditorFontSize := udEditorFontSize.Position;
  For eColour := Low(TOISOTAColour) To High(TOISOTAColour) Do
    Options.Colour[eColour] := FColours[eColour];
End;

(**

  This method intialises the user interface.

  @precon  Options must be a valid instance.
  @postcon The dialogue is intialised.

  @param   Options as an IOISOTAOptions as a constant

**)
Procedure TfrmOTAOptions.InitialiseDlg(Const Options: IOISOTAOptions);

Const
  astrColourNames : Array[TOISOTAColour] Of String = (
    'Window Text',             // ocWindowText
    'Type',                    // ocType
    'Borland IDE Services',    // ocBorlandIDEServices
    'Notifier',                // ocNotifier
    'Interface',               // ocInterface
    'Loop',                    // ocLoop
    'Filter Highlight',        // ocFilterHighlight
    'Target Highlight',        // ocTargetHighlight
    'Highlight Text',          // ocHighlightText
    'Assembler',               // ocAssemlber
    'Character',               // ocCharacter
    'Comment',                 // ocComment
    'Directive',               // ocDirective
    'Number',                  // ocNumber
    'Identifier',              // ocIdentifier
    'Reserved Word',           // ocReservedWord
    'Symbol',                  // ocSymbol
    'String',                  // ocString
    'Current Line Highlight',
    'Valid RegEx',
    'Invalid RegEx'
  );

Var
  astrThemeNames : TArray<String>;
  strThemeName : String;
  eColour : TOISOTAColour;

Begin
  astrThemeNames := TStyleManager.StyleNames;
  For strThemeName In astrThemeNames Do
    cbxVCLTheme.Items.Add(strThemeName);
  cbxTreeFontName.Items.AddStrings(Screen.Fonts);
  cbxTreeFontName.ItemIndex := cbxTreeFontName.Items.IndexOf(Options.TreeFontName);
  udTreeFontSize.Position := Options.TreeFontSize;
  cbxEditorFontName.Items.AddStrings(Screen.Fonts);
  cbxEditorFontName.ItemIndex := cbxEditorFontName.Items.IndexOf(Options.EditorFontName);
  udEditorFontSize.Position := Options.EditorFontSize;
  cbxVCLTheme.ItemIndex := cbxVCLTheme.Items.IndexOf(Options.VCLTheme);
  For eColour := Low(TOISOTAColour) To High(TOISOTAColour) Do
    Begin
      FColours[eColour] := Options.Colour[eColour];
      cbxColourName.Items.Add(astrColourNames[eColour]);
    End;
  cbxColourName.ItemIndex := 0;
  cbxColourNameSelect(Nil);
End;

End.
