(**

  This module contains a form class to allow the user to select a directory to search.

  @Author  David Hoyle
  @version 1.0
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
