(**
  
  This module contains a class which represents a form for displaying information about the application.

  @Author  David Hoyle
  @Version 1.0
  @Date    12 Jan 2020
  
**)
Unit OTAIntfSearch.AboutDlg;

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
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls;

Type
  (** A class to represent the about form. **)
  TfrmOISAbout = Class(TForm)
    pnlButtons: TPanel;
    btnOK: TBitBtn;
    lblInformation: TMemo;
    lblBuildDate: TLabel;
    lblAuthor: TLabel;
    lblBuild: TLabel;
    lblExpertMgr: TLabel;
    procedure FormCreate(Sender: TObject);
  Strict Private
  Strict Protected
  Public
    Class Procedure Execute;
  End;

Implementation

uses
  OTAIntfSearch.Functions;

{$R *.dfm}

(**

  This method is the intended way to display this dialogue.

  @precon  None.
  @postcon The dialogue is displayed in a modal state.

**)
Class Procedure TfrmOISAbout.Execute;

Var
  F: TfrmOISAbout;

Begin
  F := TfrmOISAbout.Create(Application.MainForm);
  Try
    F.ShowModal;
  Finally
    F.Free;
  End;
End;

(**

  This is an OnFormCreate Event Handler for the TfrmOISAbout class.

  @precon  None.
  @postcon Updates the captions to the build of the application.

  @param   Sender as a TObject

**)
Procedure TfrmOISAbout.FormCreate(Sender: TObject);

ResourceString
  strBuildDate = 'Build Date: %s';
  {$IFDEF DEBUG}
  strOTAIntfSearchCaption = 'Open Tools API Interface Search %d.%d%s (DEBUG Build %d.%d.%d.%d)';
  {$ELSE}
  strOTAIntfSearchCaption = 'Open Tools API Interface Search %d.%d%s (Build %d.%d.%d.%d)';
  {$ENDIF}

Const
  strDateFmt = 'ddd dd mmm yyyy @ hh:nn';

Var
  dtDateTime : TDateTime;
  recBuidlInfo: TOISBuildInfo;
  
Begin
  FileAge(ParamStr(0), dtDateTime);
  lblBuildDate.Caption := Format(
    strBuildDate, [
      FormatDateTime(strDateFmt, dtDateTime)
    ]
  );
  GetBuildData(recBuidlInfo);
  lblBuild.Caption := Format(strOTAIntfSearchCaption,
    [
      recBuidlInfo.FMajor,
      recBuidlInfo.FMinor,
      strBugFix[recBuidlInfo.FBugFix + 1],
      recBuidlInfo.FMajor,
      recBuidlInfo.FMinor,
      recBuidlInfo.FBugFix,
      recBuidlInfo.FBuild
    ]
  );
End;

End.
