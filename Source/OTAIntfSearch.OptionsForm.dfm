object frmOTAOptions: TfrmOTAOptions
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Options'
  ClientHeight = 253
  ClientWidth = 381
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 16
  object pnlFudge: TPanel
    Left = 0
    Top = 0
    Width = 381
    Height = 253
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitHeight = 132
    DesignSize = (
      381
      253)
    object lblVCLTheme: TLabel
      Left = 8
      Top = 11
      Width = 66
      Height = 16
      Caption = '&VCL Theme'
    end
    object lblColourName: TLabel
      Left = 7
      Top = 161
      Width = 74
      Height = 16
      Caption = 'Colour &Name'
    end
    object lblColour: TLabel
      Left = 7
      Top = 189
      Width = 37
      Height = 16
      Caption = '&Colour'
    end
    object lblTreeFontName: TLabel
      Left = 8
      Top = 41
      Width = 93
      Height = 16
      Caption = 'Tree Font &Name'
    end
    object lblTreeFontSize: TLabel
      Left = 8
      Top = 71
      Width = 84
      Height = 16
      Caption = 'Tree Font &Size'
    end
    object lblEditorFontSize: TLabel
      Left = 7
      Top = 131
      Width = 90
      Height = 16
      Caption = 'Editor Font &Size'
    end
    object lblEditorFontName: TLabel
      Left = 7
      Top = 101
      Width = 93
      Height = 16
      Caption = 'Tree Font &Name'
    end
    object cbxVCLTheme: TComboBox
      Left = 136
      Top = 8
      Width = 237
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
    object btnOK: TBitBtn
      Left = 217
      Top = 220
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 9
      ExplicitTop = 99
    end
    object btnCancel: TBitBtn
      Left = 298
      Top = 220
      Width = 75
      Height = 25
      Anchors = [akRight, akBottom]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 10
      ExplicitTop = 99
    end
    object cbxColour: TColorBox
      Left = 135
      Top = 186
      Width = 237
      Height = 22
      Style = [cbStandardColors, cbExtendedColors, cbSystemColors, cbIncludeNone, cbCustomColor, cbPrettyNames, cbCustomColors]
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 8
      OnSelect = cbxColourSelect
    end
    object cbxColourName: TComboBox
      Left = 135
      Top = 158
      Width = 237
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 7
      OnSelect = cbxColourNameSelect
    end
    object cbxTreeFontName: TComboBox
      Left = 136
      Top = 38
      Width = 237
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 1
    end
    object edtTreeFontSize: TEdit
      Left = 136
      Top = 68
      Width = 214
      Height = 24
      Alignment = taRightJustify
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 2
      Text = '0'
    end
    object udTreeFontSize: TUpDown
      Left = 356
      Top = 68
      Width = 16
      Height = 24
      Anchors = [akTop, akRight]
      Associate = edtTreeFontSize
      Min = 8
      Max = 18
      TabOrder = 3
    end
    object edtEditorFontSize: TEdit
      Left = 135
      Top = 128
      Width = 214
      Height = 24
      Alignment = taRightJustify
      Anchors = [akLeft, akTop, akRight]
      ReadOnly = True
      TabOrder = 5
    end
    object udEditorFontSize: TUpDown
      Left = 349
      Top = 128
      Width = 16
      Height = 24
      Anchors = [akTop, akRight]
      Associate = edtEditorFontSize
      Min = 8
      Max = 18
      TabOrder = 6
    end
    object cbxEditorFontName: TComboBox
      Left = 135
      Top = 98
      Width = 237
      Height = 24
      Style = csDropDownList
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 4
    end
  end
end
