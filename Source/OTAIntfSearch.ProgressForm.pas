(**

  This module contains a form for dislpaying progress.

  @Author  David Hoyle
  @Version 1.0
  @Date    27 Oct 2018

**)
Unit OTAIntfSearch.ProgressForm;

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
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  System.Win.TaskbarCore,
  Vcl.Taskbar,
  Vcl.StdCtrls, Vcl.Buttons;

Type
  (** This is a class to represent a simple form for displaying progress. **)
  TfrmProgress = Class(TForm)
    pnlProgress: TPanel;
    pbrProgressBar: TProgressBar;
    lblFiles: TLabel;
    pnlButtons: TPanel;
    btnCancel: TBitBtn;
    procedure btnCancelClick(Sender: TObject);
  Strict Private
    Const
      (** this is the interval in milliseconds between form updates. **)
      iUpdateInterval = 25;
  Strict Private
    FLastupdate : Int64;
    FCancel     : Boolean;
  Strict Protected
    Procedure CheckForCancel;
  Public
    Procedure ShowProgress(Const iTotal : Integer);
    Procedure UpdateProgress(Const iPosition, iTotal : Integer; Const strFileName : String);
    Procedure HideProgress;
  End;

Implementation

{$R *.dfm}

(**

  This is an on click event handler for the Cancel button.

  @precon  None.
  @postcon This button notifies the form that the progress should be aborted.

  @param   Sender as a TObject

**)
Procedure TfrmProgress.btnCancelClick(Sender: TObject);

Begin
  FCancel := True;
End;

(**

  This method checks whether the user has pressed the Cancel button and prompt them to confirm.
  If confirmed the progres is aborted by raising an EAbort exception.

  @precon  None.
  @postcon Prompts the user to abort the progress and raises an EAbort exception is confirmed.

**)
Procedure TfrmProgress.CheckForCancel;

ResourceString
  strMsg = 'Are you sure you want to abort the current search operation?';

Begin
  If FCancel Then
    Case MessageDlg(strMsg, mtConfirmation, [mbYes, mbNo, mbCancel], 0) Of
      mrYes:    Abort; 
      mrNo:     FCancel := False;
      mrCancel: FCancel := False;
    End;
End;

(**

  This method hids the progress form.

  @precon  None.
  @postcon the form is hidden.

**)
Procedure TfrmProgress.HideProgress;

Begin
  FCancel := False;
  Hide;
End;

(**

  This method shows the form.

  @precon  None.
  @postcon The form is initialised.

  @param   iTotal as an Integer as a constant

**)
Procedure TfrmProgress.ShowProgress(Const iTotal: Integer);

Begin
  FCancel := False;
  If Not Visible Then
    Show;
  pbrProgressBar.Position := 0;
  pbrProgressBar.Max := iTotal;
  pbrProgressBar.Style := pbstMarquee;
End;

(**

  This method updates the forms progress.

  @precon  None.
  @postcon The forms progress is updated.

  @param   iPosition   as an Integer as a constant
  @param   iTotal      as an Integer as a constant
  @param   strFileName as a String as a constant

**)
Procedure TfrmProgress.UpdateProgress(Const iPosition, iTotal: Integer; Const strFileName : String);

Begin
  CheckForCancel;
  If GetTickCount > FLastUpdate + iUpdateInterval Then
    Begin
      pbrProgressBar.Max := iTotal;
      If iPosition = 0 Then
        pbrProgressBar.Style := pbstMarquee
      Else
        pbrProgressBar.Style := pbstNormal;
      pbrProgressBar.Position := iPosition;     // Workaround for stupid progress animation
      pbrProgressBar.Position := iPosition - 1; //FI:W508
      pbrProgressBar.Position := iPosition;     //FI:W508
      lblFiles.Caption := strFileName;
      FLastUpdate := GetTickCount;
      Application.ProcessMessages;
    End;
End;

End.
