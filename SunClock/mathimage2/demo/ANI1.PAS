unit Ani1;
{Demo on how to use DrawPolyline, DrawPolyPolyline to display curves
 (relatively) fast, and how to make the lists which these routines
 take as parameters.}

interface

uses
  {$IFDEF WINDOWS}
  Winprocs, WinTypes,
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  {$ENDIF} Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Menus, Clipbrd,MathImge;

type
  TAniForm = class(TForm)
    ColorDialog1: TColorDialog;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Button3: TButton;
    Button7: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Panel2: TPanel;
    ScrollBox1: TScrollBox;
    NoAlignButton: TRadioButton;
    AlignClientButton: TRadioButton;
    CheckBox1: TCheckBox;
    Mathimage1: TMathImage;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    SaveasMetafile1: TMenuItem;
    CheckBox2: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NoAlignButtonClick(Sender: TObject);
    procedure MathImage1Resize(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure SaveasMetafile1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;  
  public
    points:TFloatPointList;
    pointslist:TFloatPointListList;
    wait:boolean;
    drawcolor,backcolor,axiscolor:TColor;
    procedure makespiral(a:extended;var p:TFloatPointList);
    procedure makespirals;
    { Public declarations }
  end;

implementation

uses MDemo1;

{$R *.DFM}

procedure TAniForm.CreateParams(var Params: TCreateParams);
begin
  inherited  CreateParams(Params);
  with Params do
  begin
    WndParent := Demoform.Handle;
    Parent := Demoform;
    Style := WS_CHILD OR WS_CLIPSIBLINGS OR WS_CLIPCHILDREN;
    Align := alClient;
  end;
end;

function dist(x:extended):extended;
begin
  result:=2-0.1*x;
end;

{Make pointlist to draw one spiral}
procedure TAniForm.makespiral(a:extended;var p:TFloatpointlist);
var theta,dtheta,r:extended;
begin
  p:=TFloatpointlist.create;
  dtheta:=2*pi/150;
  theta:=0;
  repeat
    r:=dist(a*theta);
    p.add(r*cos(theta),r*sin(theta));
    theta:=theta+dtheta;
  until r<0.02;
end;

{Make a listlist for all spirals in the animation}
procedure TAniForm.makespirals;
var theta,dtheta,a,r:extended; i:integer;
begin
  if pointslist<>nil then pointslist.free;
  pointslist:=TFloatpointlistlist.create;
  dtheta:=2*pi/150;
  for i:=0 to 178 do  {178 frames}
  begin
    pointslist.add;
    a:=1-i/200;
    theta:=0;
    repeat
      r:=dist(a*theta);
      pointslist.addToCurrent(r*cos(theta),r*sin(theta));
      theta:=theta+dtheta;
    until r<0.02;
  end;
end;


procedure TAniForm.FormCreate(Sender: TObject);
begin
  Points:=nil;
  Pointslist:=nil;
  drawcolor:=clyellow; backcolor:=clteal;
  axiscolor:=clnavy;
  mathimage1.d2axes:=true;
  controlstyle:=controlstyle+[csOpaque];
end;

procedure TAniForm.Button1Click(Sender: TObject);
var i:integer; pointsloc:TFloatPointList;
begin
  Screen.cursor:=crhourglass;
  with mathimage1 do
  begin
    canvas.pen.mode:=pmXOR;
    makespiral(1,pointsloc);
    drawpolyline(pointsloc);
    application.processmessages;
    for i:=1 to 178 do
    begin
      points:=pointsloc;
      makespiral(1-i/200,pointsloc);
      drawpolyline(points);
      drawpolyline(pointsloc);
      application.processmessages;
      points.free;
    end;
    pointsloc.free;
    canvas.pen.mode:=pmcopy;
  end;
  screen.cursor:=crDefault;
end;

procedure TAniForm.Button2Click(Sender: TObject);
begin
  with mathimage1 do
  begin
    brush.color:=backcolor;
    font.color:=axiscolor;
    pen.color:=drawcolor;
    clear;
    drawaxes('','',false,axiscolor,axiscolor);
  end;
end;

procedure TAniForm.Button3Click(Sender: TObject);
var i:integer; 
begin
  Screen.Cursor:=crHourGlass;
  with mathimage1 do
  begin
    for i:=0 to 177 do
    begin
      makespiral(1-i/200,points);
      ClearClipped;
      {Drawing axes slows down the animation}
      drawpolyline(points);
      application.processmessages;
      points.free;
    end;
    makespiral(1-178/200,points);
    clear;
    drawaxes('','',false,axiscolor,axiscolor);
    drawpolyline(points);
    application.processmessages;
    points.free;
  end;
  Screen.Cursor:=crDefault;
end;

procedure TAniForm.Button4Click(Sender: TObject);
begin
  with colordialog1 do
  if execute then
  begin
    backcolor:=color;
    button2click(self);
  end;
end;



procedure TAniForm.Button5Click(Sender: TObject);
begin
  with colordialog1 do
  if execute then
  begin
    drawcolor:=color;
    button2click(self);
  end;
end;

procedure TAniForm.Button6Click(Sender: TObject);
begin
  with colordialog1 do
  if execute then
  begin
    axiscolor:=color;
    button2click(self);
  end;
end;

procedure TAniForm.Button7Click(Sender: TObject);
var p:TFloatPointlist; i:longint;
begin
  Screen.cursor:=crHourGlass;
  with mathimage1 do
  begin
    clear;
    drawaxes('','',false,axiscolor,axiscolor);
    if pointslist=nil then makespirals;
    p:=PointsList.firstlist;
    for i:=1 to PointsList.count-1 do
    begin
      clearClipped;
      DrawPolyline(p);
      application.processmessages;
      p:=p.next;
    end;
    clear;
    drawaxes('','',false,axiscolor,axiscolor);
    DrawPolyline(p);
  end;
  Screen.cursor:=crDefault;
end;

procedure TAniForm.FormDestroy(Sender: TObject);
begin
  if pointslist<>nil then pointslist.free;
end;

procedure TAniForm.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  saveasmetafile1.enabled:=false;
  checkbox2.enabled:=false;
  {$ENDIF}
  button2click(self);
end;

procedure TAniForm.NoAlignButtonClick(Sender: TObject);
begin
  with Mathimage1 do
  if NoAlignButton.Checked then
  begin
      align:=alnone;
      hint:='This picture does not change size';
  end
  else
  begin
      align:=alclient;
      hint:='This picture changes size with the form';
  end;
end;

procedure TAniForm.MathImage1Resize(Sender: TObject);
begin
  If checkbox1.checked then
    Button7Click(self)
  else Formshow(self);
end;

procedure TAniForm.CopytoClipboard1Click(Sender: TObject);
begin
  clipboard.assign(mathimage1.bitmap);
end;

procedure TAniForm.SaveasMetafile1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with savedialog1 do
    if execute then
    mathimage1.saveasmetafile(filename);
  {$ENDIF}
end;

procedure TAniForm.CheckBox2Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with  mathimage1 do
  begin
    recordmetafile:=checkbox1.checked;
    saveasmetafile1.enabled:=recordmetafile;
  end;
  {$ENDIF}
end;

end.


