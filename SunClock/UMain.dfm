object MainForm: TMainForm
  Left = 577
  Top = 298
  Width = 384
  Height = 252
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'SunClock (AbverSoft)'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object MathImg: TMathImage
    Left = 4
    Top = 8
    Width = 360
    Height = 178
    Pen.Color = 4194368
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Version = '6.0(beta 5) May 2000'
    RecordMetafile = False
    d2WorldX1 = -1.000000000000000000
    d2WorldXW = 2.000000000000000000
    d2WorldY1 = -1.000000000000000000
    d2WorldYW = 2.000000000000000000
    d3WorldX1 = -1.000000000000000000
    d3WorldXW = 2.000000000000000000
    d3WorldY1 = -1.000000000000000000
    d3WorldYW = 2.000000000000000000
    d3WorldZ1 = -1.000000000000000000
    d3WorldZW = 2.000000000000000000
    d3Xscale = 1.000000000000000000
    d3Yscale = 1.000000000000000000
    d3Zscale = 1.000000000000000000
    d3Zrotation = 45.000000000000000000
    d3Yrotation = 45.000000000000000000
    d3ViewDist = 6.400000000000000000
    d3ViewAngle = 6.000000000000000000
    d3AspectRatio = True
  end
  object Label1: TLabel
    Left = 12
    Top = 196
    Width = 33
    Height = 13
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 204
    Top = 196
    Width = 33
    Height = 13
    Caption = 'Label2'
  end
  object JvTimer1: TJvTimer
    Interval = 100
    OnTimer = JvTimer1Timer
    Left = 48
    Top = 80
  end
end
