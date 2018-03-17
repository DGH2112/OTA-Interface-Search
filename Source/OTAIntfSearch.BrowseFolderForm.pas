(**

  This module contains a form class to allow the user to select a directory to search.

  @Author  David Hoyle
  @version 1.0
  @Date    17 Mar 2018

**)
Unit OTAIntfSearch.BrowseFolderForm;

Interface

Uses
  Forms,
  OTAIntfSearch.Interfaces,
  Vcl.StdCtrls,
  Vcl.Buttons,
  Vcl.ExtCtrls,
  Vcl.Controls,
  System.Classes,
  System.ImageList,
  Vcl.ImgList;

Type
  (** A class to represent a form interface for selecting directories to search. **)
  TfrmBrowseFolder = Class(TForm)
    lblSearchPath: TLabel;
    edtSearchPath: TButtonedEdit;
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    ilButtons: TImageList;
    procedure edtSearchPathRightButtonClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  Strict Private
  Strict Protected
  Public
    Class Function Execute(Const AOwner : TComponent; var strSearchFolder : String) : Boolean;
  End;

Implementation

Uses
  SysUtils,
  Dialogs,
  FileCtrl,
  RegularExpressions,
  UITypes;

{$R *.DFM}

(**

  This is an on click event handler for the OK button.

  @precon  None.
  @postcon Checks that the directory is valid before alllowing the dialogue to close.

  @param   Sender as a TObject

**)
Procedure TfrmBrowseFolder.btnOKClick(Sender: TObject);

ResourceString
  strSearchPathDoesNotExist = 'The search path "%s" does not exist!';

Begin
  If Not SysUtils.DirectoryExists(ExtractFilePath(edtSearchPath.Text)) Then
    Begin
      MessageDlg(Format(strSearchPathDoesNotExist, [
        ExtractFilePath(edtSearchPath.Text)]), mtError, [mbOK], 0);
      ModalResult := mrNone;
      Exit;
    End;
End;

(**

  This is an on right button click event handler for the search path edit control.

  @precon  None.
  @postcon Displays a dialogue for the user to select a directory.

  @param   Sender as a TObject

**)
Procedure TfrmBrowseFolder.edtSearchPathRightButtonClick(Sender: TObject);

ResourceString
  strToolsAPIPas = '\ToolsAPI.pas';

Var
  strSearchPath : String;

Begin
  If SelectDirectory(strSearchPath, [], 0) Then
    edtSearchPath.Text := strSearchPath + strToolsAPIPas;
End;

(**

  This is the forms main interface method for invokking the dialogue.

  @precon  AOwner must be a valid instance
  @postcon A form is displayed to allow the user to select a directory.

  @param   AOwner          as a TComponent as a constant
  @param   strSearchFolder as a String as a reference
  @return  a Boolean

**)
Class Function TfrmBrowseFolder.Execute(Const AOwner : TComponent; var strSearchFolder : String) : Boolean;

Var
  frm: TfrmBrowseFolder;

Begin
  Result := False;
  frm := TfrmBrowseFolder.Create(AOwner);
  Try
    frm.edtSearchPath.Text := strSearchFolder;
    If frm.ShowModal = mrOk Then
      Begin
        strSearchFolder := frm.edtSearchPath.Text;
        Result := True;
      End;
  Finally
    frm.Free;
  End;
End;

End.
