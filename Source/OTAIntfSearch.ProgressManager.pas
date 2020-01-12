(**

  This module contains a class for managing progress in the application (showing, updating
  and hiding progres dialogues, etc).

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
Unit OTAIntfSearch.ProgressManager;

Interface

Uses
  Forms,
  Vcl.Taskbar,
  Generics.Collections,
  OTAIntfSearch.Interfaces,
  OTAIntfSearch.ProgressForm;

Type
  (** This class implements the IOISProgressManager interface to provide a central location
      to manage carious types of progress output (Taskbar, Form, etc.). **)
  TOISProgressManager = Class(TInterfacedObject, IOISProgressManager)
  Strict Private
    Type
      (** This record describes the information to be stored in a local list of stages. **)
      TStage = Record
        FPosition : Integer;
        FTotal    : Integer;
      End;
    Const
      (** This constant define the total length of the progress bar which gets divided into
          stages. **)
      iTotalLength = 1000000;
  Strict Private
    FStages       : Integer;
    FStageRecords : TList<TStage>;
    FProgressForm : TfrmProgress;
    FTaskBar      : TTaskbar;
  Strict Protected
    Procedure Hide;
    Procedure RegisterStages(Const iStages: Integer);
    Procedure Show(Const iStage, iTotal: Integer);
    Procedure Update(Const iStage, iPosition: Integer; Const strFileName : String);
  Public
    Constructor Create(Const MainForm : TForm; Const Taskbar : TTaskbar);
    Destructor Destroy; Override;
  End;

Implementation

Uses
  System.SysUtils,
  System.Win.TaskbarCore;

(**

  A constructor for the TOISProgressManager class.

  @precon  None.
  @postcon Initialises the class and creates a form for displaying progress.

  @param   MainForm as a TForm as a constant
  @param   Taskbar  as a TTaskbar as a constant

**)
Constructor TOISProgressManager.Create(Const MainForm : TForm; Const Taskbar : TTaskbar);

Begin
  FTaskBar := Taskbar;
  FStages := 0;
  FStageRecords := TList<TStage>.Create;
  FProgressForm := TfrmProgress.Create(MainForm);
End;

(**

  A destructor for the TOISProgressManager class.

  @precon  None.
  @postcon Frees the memory used by the class.
  @Note    The form is not freed here as its now owned by the main form.

**)
Destructor TOISProgressManager.Destroy;

Begin
  FStageRecords.Free;
  Inherited Destroy;
End;

(**

  This method hides the form.

  @precon  None.
  @postcon the progress form is hidden.

**)
Procedure TOISProgressManager.Hide;

Begin
  FTaskBar.ProgressState := TTaskBarProgressState.None;
  FProgressForm.HideProgress;
End;

(**

  This method registers the number of stages of progress to be displayed.

  @precon  This must be the first call before sowing and updating progress.
  @postcon The stages of progress are setup in the class.

  @param   iStages as an Integer as a constant

**)
Procedure TOISProgressManager.RegisterStages(Const iStages: Integer);

Var
  recStage : TStage;

Begin
  FStages := iStages;
  recStage.FPosition := 0;
  recStage.FTotal := 0;
  While (FStageRecords.Count - 1) < iStages Do
    FStageRecords.Add(recStage);
End;

(**

  This method show the progress for the first time ans sets the total number of units to be progressed.

  @precon  iStage must be a valid stage of progress.
  @postcon The progress stage is setup for progressing.

  @param   iStage as an Integer as a constant
  @param   iTotal as an Integer as a constant

**)
Procedure TOISProgressManager.Show(Const iStage, iTotal: Integer);

Var
  recStage: TStage;
  iPosition: Integer;
  iStageLength: Integer;

Begin
  recStage := FStageRecords[iStage];
  recStage.FTotal := iTotal;
  FStageRecords[iStage] := recStage;
  iStageLength := iTotalLength Div FStages;
  iPosition := iStageLength * (iStage - 1);
  FTaskBar.ProgressValue := iPosition;
  FTaskBar.ProgressMaxValue := iTotalLength;
  FTaskBar.ProgressState := TTaskBarProgressState.Normal;
  FProgressForm.UpdateProgress(iPosition, iTotalLength, '');
  FProgressForm.ShowProgress(iTotal);
End;

(**

  This updates the current stage progress.

  @precon  iStage must be a valid stage.
  @postcon The progress is updated.

  @param   iStage      as an Integer as a constant
  @param   iPosition   as an Integer as a constant
  @param   strFileName as a String as a constant

**)
Procedure TOISProgressManager.Update(Const iStage, iPosition: Integer; Const strFileName : String);

Var
  recStage: TStage;
  iStageLength: Integer;
  iProgressPosition: Integer;

Begin
  recStage := FStageRecords[iStage];
  recStage.FPosition := iPosition;
  FStageRecords[iStage] := recStage;
  iStageLength := iTotalLength Div FStages;
  iProgressPosition := iStageLength * (iStage - 1) +
    Trunc(iStageLength * Int(iPosition) / Int(recStage.FTotal));
  FTaskBar.ProgressValue := iProgressPosition;
  FTaskBar.ProgressMaxValue := iTotalLength;
  FProgressForm.UpdateProgress(iProgressPosition, iTotalLength, strFileName);
End;

End.
