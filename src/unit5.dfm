object Form5: TForm5
  Left = 401
  Top = 243
  Caption = 'Form5: DXE2,  OTL PipeLine'
  ClientHeight = 449
  ClientWidth = 521
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    521
    449)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 10
    Top = 8
    Width = 69
    Height = 13
    Caption = 'Strings Length'
    Color = clBtnFace
    FocusControl = edLen
    ParentColor = False
  end
  object Label2: TLabel
    Left = 170
    Top = 8
    Width = 77
    Height = 13
    Caption = 'Quantity of "1"s'
    Color = clBtnFace
    FocusControl = edOnes
    ParentColor = False
  end
  object lblResults: TLabel
    Left = 8
    Top = 64
    Width = 344
    Height = 23
    Alignment = taCenter
    AutoSize = False
    Caption = 'lblResults'
    Color = clBtnFace
    ParentColor = False
    Layout = tlCenter
  end
  object edLen: TSpinEdit
    Left = 8
    Top = 32
    Width = 128
    Height = 22
    MaxValue = 1000
    MinValue = 1
    TabOrder = 0
    Value = 28
  end
  object Button1: TButton
    Left = 360
    Top = 16
    Width = 150
    Height = 72
    Caption = 'Find All'
    TabOrder = 2
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 9
    Top = 96
    Width = 501
    Height = 344
    Anchors = [akLeft, akTop, akRight, akBottom]
    Lines.Strings = (
      'Memo1')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object edOnes: TSpinEdit
    Left = 168
    Top = 32
    Width = 128
    Height = 22
    MaxValue = 1000
    MinValue = 1
    TabOrder = 1
    Value = 10
  end
end
