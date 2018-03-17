(**

  This module contains a form for dislpaying progress.

  @Author  David Hoyle
  @Version 1.0
  @Date    17 Mar 2018

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
  Vcl.StdCtrls;

Type
  (** This is a class to represent a simple form for displaying progress. **)
  TfrmProgress = Class(TForm)
    pnlProgress: TPanel;
    pbrProgressBar: TProgressBar;
    lblFiles: TLabel;
  Strict Private
    Const
      (** this is the interval in milliseconds between form updates. **)
      iUpdateInterval = 25;
  Strict Private
    { Private declarations }
    FLastupdate : Int64;
  Strict Protected
  Public
    { Public declarations }
    Procedure ShowProgress(Const iTotal : Integer);
    Procedure UpdateProgress(Const iPosition, iTotal : Integer; Const strFileName : String);
    Procedure HideProgress;
  End;

Implementation

{$R *.dfm}

(**

  This method hids the progress form.

  @precon  None.
  @postcon the form is hidden.

**)
Procedure TfrmProgress.HideProgress;

Begin
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
  If GetTickCount > FLastUpdate + iUpdateInterval Then
    Begin
      pbrProgressBar.Max := iTotal;
      If iPosition = 0 Then
        pbrProgressBar.Style := pbstMarquee
      Else
        pbrProgressBar.Style := pbstNormal;
      pbrProgressBar.Position := iPosition;
      pbrProgressBar.Position := iPosition - 1;
      pbrProgressBar.Position := iPosition;
      lblFiles.Caption := strFileName;
      FLastUpdate := GetTickCount;
      Application.ProcessMessages;
    End;
End;

End.
