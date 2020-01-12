object frmOISAbout: TfrmOISAbout
  Left = 0
  Top = 0
  Caption = 'About'
  ClientHeight = 450
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 16
  object lblBuildDate: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 82
    Width = 499
    Height = 16
    Align = alTop
    Caption = 'lblBuildDate'
    ExplicitWidth = 66
  end
  object lblAuthor: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 60
    Width = 499
    Height = 16
    Align = alTop
    Caption = 'Author: David Hoyle (c) 2020 GNU GPL 3'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitWidth = 229
  end
  object lblBuild: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 38
    Width = 499
    Height = 16
    Align = alTop
    Caption = 'lblBuild'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    ExplicitLeft = -31
    ExplicitWidth = 40
  end
  object lblExpertMgr: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 499
    Height = 29
    Align = alTop
    Caption = 'Open Tools API Interface Search'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    Transparent = True
    ExplicitWidth = 390
  end
  object pnlButtons: TPanel
    Left = 0
    Top = 413
    Width = 505
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = -37
    ExplicitTop = 287
    ExplicitWidth = 515
    object btnOK: TBitBtn
      Left = 216
      Top = 3
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'OK'
      Default = True
      Glyph.Data = {
        DE010000424DDE01000000000000760000002800000024000000120000000100
        0400000000006801000000000000000000001000000000000000000000000000
        80000080000000808000800000008000800080800000C0C0C000808080000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        3333333333333333333333330000333333333333333333333333F33333333333
        00003333344333333333333333388F3333333333000033334224333333333333
        338338F3333333330000333422224333333333333833338F3333333300003342
        222224333333333383333338F3333333000034222A22224333333338F338F333
        8F33333300003222A3A2224333333338F3838F338F33333300003A2A333A2224
        33333338F83338F338F33333000033A33333A222433333338333338F338F3333
        0000333333333A222433333333333338F338F33300003333333333A222433333
        333333338F338F33000033333333333A222433333333333338F338F300003333
        33333333A222433333333333338F338F00003333333333333A22433333333333
        3338F38F000033333333333333A223333333333333338F830000333333333333
        333A333333333333333338330000333333333333333333333333333333333333
        0000}
      ModalResult = 1
      NumGlyphs = 2
      TabOrder = 0
    end
  end
  object lblInformation: TMemo
    AlignWithMargins = True
    Left = 3
    Top = 104
    Width = 499
    Height = 306
    Align = alClient
    Lines.Strings = (
      'Open Tools API Interface Search'
      ''
      
        'Copyright (C) 2019  David Hoyle (https://github.com/DGH2112/OTA-' +
        'Interface-'
      'Search/)'
      ''
      
        'This program is free software: you can redistribute it and/or mo' +
        'dify it under the '
      
        'terms of the GNU General Public License as published by the Free' +
        ' Software '
      
        'Foundation, either version 3 of the License, or (at your option)' +
        ' any later version.'
      ''
      
        'This program is distributed in the hope that it will be useful, ' +
        'but WITHOUT ANY '
      
        'WARRANTY; without even the implied warranty of MERCHANTABILITY o' +
        'r FITNESS '
      
        'FOR A PARTICULAR PURPOSE.  See the GNU General Public License fo' +
        'r more '
      'details.'
      ''
      
        'You should have received a copy of the GNU General Public Licens' +
        'e along with this '
      'program. If not, see <https://www.gnu.org/licenses/>.')
    ParentColor = True
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitLeft = -31
    ExplicitTop = 55
    ExplicitWidth = 509
    ExplicitHeight = 269
  end
end
