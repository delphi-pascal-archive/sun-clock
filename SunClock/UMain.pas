{***************************************************************
 *                  _-.                       .-_
 *               _..-'(                       )`-.._
 *            ./'. '\\.         (\_/)       .//||` .`\.
 *         ./'.|'.'||||\\|..    )*.*(    ..|//||||`.`|.`\.
 *      ./'..|'.|| |||||\```````  "  '''''''/||||| ||.`|..`\.
 *    ./'.||'.|||| ||||||||||||.     .|||||||||||| ||||.`||.`\.
 *   /'|||'.|||||| ||||||||||||(     )|||||||||||| ||||||.`|||`\
 *  '.|||'.||||||| ||||||||||||(     )|||||||||||| |||||||.`|||.`
 * '.||| ||||||||| |/'   ``\||/`     '\||/''   `\| ||||||||| |||.`
 * |/' \./'     `\./          |/\   /\|          \./'     `\./ `\|
 * V    V         V          )' `\ /' `(          V         V    V
 * `    `         `               U               '         '
 *
 *
 *               Copyright (c) 2009 AO ABVER
 *                 Copyright (c) ABVERSOFT
 ****************************************************************}
unit UMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OverlayImage, MathImge, JvTimer, JclMath, Math, JclDateTime,
  JvJVCLUtils,
  GifImage, StdCtrls;

type
  TMainForm = class(TForm)
    MathImg: TMathImage;
    JvTimer1: TJvTimer;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure JvTimer1Timer(Sender: TObject);
  private
    { Private declarations }

    Mapsbmp: TBitmap; // Карта
    function computeDeclination(T, M, J: Integer; STD: double): Double;
    function computeGHA(T, M, J: Integer; STD: double): Double;
    function computeHeight: Double;
    function computeAzimut: Double;
    function computeLat(longitude: Integer; dec: Double): Integer;
    procedure init;
    procedure MImgPaint;
    procedure ViewMapsBmp(aMaps: TMathImage; aX, aY, aW, aH: Integer);
    //Отображение карты
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

  Dat: TDate; // Дата
  year, //Год
  month, //Месяц
  date2, //Дата
  day, //День
  hours, //Час
  minutes, // Мин
  seconds, // Сек
  Msec: Word;
  browserOffset, locOffset: Integer;
  latitude, longitude, dec, GHA: Double;
const
  xMouse: Integer = 0;
  yMouse: Integer = 0;
  xOben: Integer = 40;
  xL: Integer = 20;
  hoehe: Double = 0.0;
  K: Double = 0.017453292519943295;

implementation

{$R *.dfm}

{ TMainForm }

function GetLocalTZBias: LongInt;
var
  TZ: TTimeZoneInformation;
begin
  case GetTimeZoneInformation(TZ) of
    TIME_ZONE_ID_STANDARD: Result := TZ.Bias + TZ.StandardBias;
    TIME_ZONE_ID_DAYLIGHT: Result := TZ.Bias + TZ.DaylightBias;
  else
    Result := TZ.Bias;
  end;
end;

function put_in_360(x: extended): extended;
begin
  result := x - round(x / 360) * 360;
  while result < 0 do
    result := result + 360;
end;

{ Julian date }

function Julian_Date(ADate: TDateTime): extended;
var
  FirstJulian,
    FirstOf2k: TDateTime;
begin
  FirstJulian := EncodeDate(1582, 10, 15);
  if ADate >= FirstJulian then
    begin
      FirstOf2k := EncodeDate(2000, 1, 1);
      Result := 2451544.5 - FirstOf2k + ADate;
    end
  else
    Result := 0;
end;

function star_time(date: TDateTime): extended;
var
  jd, t: extended;
begin
  jd := julian_date(date);
  t := (jd - 2451545.0) / 36525;
  result := put_in_360(280.46061837 + 360.98564736629 * (jd - 2451545.0) +
    t * t * (0.000387933 - t / 38710000));
end;

function Jd(annee, mois, jour: INTEGER; Heure: double): double;
var
  u, u0, u1, u2: double;
  gregorian: boolean;
begin
  if annee * 10000 + mois * 100 + jour >= 15821015 then
    gregorian := true
  else
    gregorian := false;
  u := annee;
  if mois < 3 then
    u := u - 1;
  u0 := u + 4712;
  u1 := mois + 1;
  if u1 < 4 then
    u1 := u1 + 12;
  result := floor(u0 * 365.25) + floor(30.6 * u1 + 0.000001) + jour + heure / 24
    - 63.5;
  if gregorian then
    begin
      u2 := floor(abs(u) / 100) - floor(abs(u) / 400);
      if u < 0 then
        u2 := -u2;
      result := result - u2 + 2;
      if (u < 0) and ((u / 100) = floor(u / 100)) and ((u / 400) <> floor(u /
        400)) then
        result := result - 1;
    end;
end;

procedure DecDateTime(const AValue: TDateTime; out AYear, AMonth,
  ADay, AHour, AMinute, ASecond, AMilliSecond: Word);
begin
  DecodeDate(AValue, AYear, AMonth, ADay);
  DecodeTime(AValue, AHour, AMinute, ASecond, AMilliSecond);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(Mapsbmp);
end;

procedure TMainForm.JvTimer1Timer(Sender: TObject);
begin
  MImgPaint;
end;

function TMainForm.computeAzimut: Double;
var
  cosAz, Az: Double;
begin
  cosAz := (JclMath.sin(dec * K) - JclMath.sin(latitude * K) * JclMath.sin(hoehe
    * K)) / (JclMath.cos(hoehe * K) * JclMath.cos(K * latitude));
  Az := PI / 2 - JclMath.ArcSin(cosAz);
  Az := Az / K;
  if (JclMath.sin(K * (GHA + longitude)) < 0) then
    Az := Az;
  if (JclMath.sin(K * (GHA + longitude)) > 0) then
    Az := 360.0 - Az;
  result := Az;

end;

function TMainForm.computeDeclination(T, M, J: Integer;
  STD: double): Double;
var
  N: Integer;
  X, XX, P, NN: double;
  Ekliptik, J2000, JD2: double;
begin
  N := 365 * J + T + 31 * M - 46;
  if M < 3 then
    N := N + Trunc(((J - 1) / 4))
  else
    N := N - Trunc((0.4 * M + 2.3)) + Trunc((J / 4.0));

  X := (N - 693960) / 1461.0;
  X := (X - Trunc(X)) * 1440.02509 + Trunc(X) * 0.0307572;
  X := X + STD / 24.0 * 0.9856645 + 356.6498973;
  X := X + 1.91233 * JclMath.sin(0.9999825 * X * K);
  X := (X + JclMath.sin(1.999965 * X * K) / 50.0 + 282.55462) / 360.0;
  X := (X - Trunc(X)) * 360.0;

  J2000 := (J - 2000) / 100.0;
  //JD2 := star_time(Now) / 36525;
  //	Ekliptik := 23.43929111 - (46.8150 + (0.00059 - 0.001813 * JD2) * JD2) * JD2 / 3600.0;
  Ekliptik := 23.43929111 - (46.8150 + (0.00059 - 0.001813 * J2000) * J2000) *
    J2000 / 3600.0;
  X := JclMath.sin(X * K) * JclMath.sin(K * Ekliptik);

  result := JclMath.ArcTan(X / sqrt(1.0 - X * X)) / K + 0.00075;

end;

function TMainForm.computeGHA(T, M, J: Integer; STD: double): Double;
var
  N: Integer;
  X, XX, P, NN: Double;

begin
  N := 365 * J + T + 31 * M - 46;
  if (M < 3) then
    N := N + Trunc(((J - 1) / 4))
  else
    N := N - Trunc((0.4 * M + 2.3)) + Trunc((J / 4.0));

  P := STD / 24.0;
  X := (P + N - 7.22449E5) * 0.98564734 + 279.306;
  X := X * K;
  XX := -104.55 * JclMath.sin(X) - 429.266 * JclMath.cos(X) + 595.63 *
    JclMath.sin(2.0 * X) - 2.283 * JclMath.cos(2.0 * X);
  XX := XX + 4.6 * JclMath.sin(3.0 * X) + 18.7333 * JclMath.cos(3.0 * X);
  XX := XX - 13.2 * JclMath.sin(4.0 * X) - JclMath.cos(5.0 * X) - JclMath.sin(5.0
    * X) / 3.0 + 0.5 * JclMath.sin(6.0 * X) + 0.231;
  XX := XX / 240.0 + 360.0 * (P + 0.5);
  if (XX > 360) then
    XX := XX - 360.0;
  result := XX;

end;

function TMainForm.computeHeight: Double;
var
  sinHeight, height: double;
begin
  sinHeight := JclMath.sin(dec * K) * JclMath.sin(latitude * K) + JclMath.cos(dec
    * K) * JclMath.cos(K * latitude) * JclMath.cos(K * (GHA + longitude));
  height := JclMath.ArcSin(sinHeight);
  height := height / K;
  result := height;

end;

function TMainForm.computeLat(longitude: Integer; dec: Double): Integer;
var
  tan, itan: double;
begin

  tan := -JclMath.cos(longitude * K) / JclMath.tan(dec * K);
  itan := JclMath.ArcTan(tan);
  itan := itan / K;

  result := round(itan);

end;

procedure TMainForm.init;
begin
  browserOffset := GetLocalTZBias;
  browserOffset := Trunc(-browserOffset / 60); //*
  locOffset := browserOffset;
  //label1.Caption := IntToStr (browserOffset);
end;

procedure TMainForm.MImgPaint;
var
  STD, GHA12, equation, diff, azimuth, gnomon: Double;
  x, xx, y, yy, yy1, yy2, i, p, min, xGnomon, yGnomon, F: Integer;
  s: string;
const
  xL0 = 0;
  yL0 = 178;
  yL1 = yL0 / 2;
  xL1 = 360;
  xL2 = xL1 / 2;
  x0: Integer = 180;
  y0: Integer = (90);
  left: Integer = (370 + 20);
  Radius: Integer = 6; //солнышко

begin

  dat := Now; // дата и время

  DecDateTime(dat, year, month, day, hours, minutes, seconds, Msec);

  // вычысляем Наклон
  STD := 1 * (hours - locOffset) + minutes / 60 + seconds / 3600;
  dec := computeDeclination(day, month, year, STD);
  label1.Caption := 'Declin.= ' + FloatToStr(round(100.0 * dec) / 100.0) +
    ' degs';


  GHA := computeGHA(day, month, year, STD);
  label2.Caption := 'GHA =    ' + FloatToStr(round(10.0 * GHA) / 10.0) +
    ' degs';


  GHA12 := computeGHA(day, month, year, 12.0);
  if (GHA12 > 5.0) then
    GHA12 := GHA12 - 360.0;
  equation := GHA12 * 4.0;

  diff := abs(equation - Trunc(equation));
  min := round(diff * 60.0);

  hours := hours - locOffset;
  //timeString = locOffset + " h";

  if (hours < 0) then
    hours := hours + 24;
  if (hours >= 24) then
    hours := hours - 24;

  x := x0 - round(GHA);
  if (x < 0) then
    x := x + 360;
  if (x > 360) then
    x := x - 360;

   // линия экватора
  xx := xL0;

  with MathImg do
    begin

      LockUpdate; //
      try
        // задание координат для Map
        SetWorld(0, 0, 360, 178);
        Clear;
        //Загрузка рисунка карты
        ViewMapsBmp(MathImg, 0, 0, Mapsbmp.Width, Mapsbmp.Height);

        // рисование осей
        Pen.Color := clGray;
        pen.Mode := pmCopy;
        DrawLine(xL0, yL1, xL1, yL1);
        DrawLine(xL2, xL0, xL2, yL0);

        yy1 := round(y0 - 23.5);
        yy2 := round(y0 + 23.5);
        y := round(y0 - 90 + 23.5);
        yy := round(y0 + 90 - 23.5);

        //рисование  пунктирных линий
        xx := xL0;
        for i := 0 to 59 do

          begin
            DrawLine(xx, yy1, xx + 2, yy1);
            DrawLine(xx, yy2, xx + 2, yy2);
            DrawLine(xx, y, xx + 2, y);
            DrawLine(xx, yy, xx + 2, yy);
            xx := xx + 6;
          end; //end for

        // рисуем солнышко

        y := Height div 2 + round(dec);

        pen.Mode := pmCopy;
        Brush.Color := clYellow;
        Pen.Color := clRed;
        DrawEllipse(xL0 + x - Radius, y - Radius, xL0 + x + Radius, y + Radius);

        DrawEllipse(xL0 + x - Radius - 1, y - Radius - 1, xL0 + x + Radius + 2, y
          + Radius + 2);

        // рисуем дугу дня и ночи
        Pen.Color := $00FF0066; //$00FF6666

        Brush.Color := clRed;
        pen.Mode := pmMaskPenNot;
        if (dec > 0) then
          F := 1
        else
          F := -1;

        i := -x;
        while x + i < 2 * x0 do
          begin
            yy := computeLat(i, dec);
            yy1 := computeLat(i + 1, dec);
            DrawLine(xL0 + x + i, y0 + yy, xL0 + x + i + 1, y0 + yy1);
            //if (i mod 7) = 0 then
            DrawLine(xL0 + x + i, y0 + yy, xL0 + x + i, y0 - F * 90 - 2);

            inc(i);
          end; //end while

      finally
        UnlockUpdate;
      end; //end finally

    end; // end with

end;

procedure TMainForm.ViewMapsBmp(aMaps: TMathImage; aX, aY, aW,
  aH: Integer);
begin
  SetStretchBltMode(aMaps.Canvas.Handle, HALFTONE);
  StretchBlt(aMaps.Canvas.Handle,
    0,
    0,
    aMaps.Width,
    aMaps.Height,
    Mapsbmp.Canvas.Handle,
    aX,
    aY,
    aW,
    aH,
    SRCCOPY);
end;

procedure TMainForm.FormCreate(Sender: TObject);

var
  gif: TGIFImage;
begin
  Mapsbmp := TBitmap.Create;
  gif := TGIFImage.Create;
  gif.LoadFromFile('map.gif');

  Mapsbmp.Assign(gif.Bitmap);
  gif.Free;
   init;
end;

end.