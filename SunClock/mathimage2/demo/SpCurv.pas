unit Spcurv;
{Demonstrates some 3-D-features of MathImage.
 The routines marked by *********** use
 MathImage methods.}

interface

uses
  SysUtils,
  {$IFDEF WINDOWS}
  WinTypes, WinProcs,
  {$ENDIF}
  {$IFDEF WIN32}
  Windows,
  {$ENDIF}
  Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Mathimge,
  Menus,  Clipbrd;

const tmin=0; tmax=6*Pi;  {double helix parameter bounds}
      tmesh=3000; {Number of plot points}
      a=3;b=5; r=2;{'radii'}
      rotinc=1; moveinc=0.005; zoominc=0.01;

type
  TSpaceCurveForm = class(TForm)
    Panel1: TPanel;
    CurveButton: TButton;
    UpButton: TButton;
    LeftButton: TButton;
    RightButton: TButton;
    DownButton: TButton;
    ColorDialog1: TColorDialog;
    InButton: TButton;
    OutButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    MoveInButton: TButton;
    MoveOutButton: TButton;
    Panel2: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    vdshow: TLabel;
    vashow: TLabel;
    zrshow: TLabel;
    yrshow: TLabel;
    Aspectcheck: TCheckBox;
    Axescheck: TCheckBox;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    Graphimage: TMathImage;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    SaveasMetafile1: TMenuItem;
    SaveDialog1: TSaveDialog;
    CheckBox1: TCheckBox;
    procedure InButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure InButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure OutButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LeftButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RightButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure DownButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GraphImageResize(Sender: TObject);
    procedure MoveOutButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MoveInButtonMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MoveInButtonMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure GraphimageRotating(Sender: TObject);
    procedure GraphimageRotateStop(Sender: TObject);
    procedure CurveButtonClick(Sender: TObject);
    procedure AspectcheckClick(Sender: TObject);
    procedure AxescheckClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure SaveasMetafile1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
  curvecolor:longint;
  HelixList:TD3FloatPointlist;
  orbiting:boolean;
  drawhelix:procedure of object;
  procedure CreateParams(var Params: TCreateParams); override;
  procedure helix(t:extended; var x,y,z:extended);
  procedure makehelix;
  procedure drawhelix1;
  procedure drawhelix2;
  procedure upd;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpaceCurveForm: TSpaceCurveForm;

implementation

uses Mdemo1;


{$R *.DFM}

procedure TSpaceCurveForm.CreateParams(var Params: TCreateParams);
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


{*************************************}
procedure TSpaceCurveForm.FormCreate(Sender: TObject);
begin
  curvecolor:=cllime;
  makehelix;
  drawhelix:=drawhelix1;
  upd;
  controlstyle:=controlstyle+[csOpaque];
  orbiting:=false;
  randomize;
end;

procedure TSpaceCurveForm.CurveButtonClick(Sender: TObject);
begin
  with colordialog1 do
  if execute then
  begin
    curvecolor:=color;
    drawhelix;
  end;
end;



procedure TSpaceCurveForm.helix; {Parametric double helix formula}
var s,r3,xc,yc,zc,x1,y1,z1,x2,y2,x3,y3,z3,x4,y4,z4,u,v:extended;
begin
  s:=34*t;
  r3:=r*4*t*(tmax-t)/tmax/tmax;
  xc:=a*cos(t); yc:=b*sin(t); zc:=t; {core curve}
  x1:=-a*sin(t); y1:=b*cos(t); z1:=1;
  x2:=-a*cos(t); y2:=-b*sin(t);
  u:=sqr(xc)+sqr(yc)+1;
  v:=x1*x2+y1*y2;
  x3:=x2*u-x1*v; {1st perp vector}
  y3:=y2*u-y1*v;
  z3:=-z1*v;
  x4:=y1*z3-z1*y3; {2nd perp vector}
  y4:=z1*x3-x1*z3;
  z4:=x1*y3-y1*x3;
  u:=sqrt(sqr(x3)+sqr(y3)+sqr(z3));
  v:=sqrt(sqr(x4)+sqr(y4)+sqr(z4));
  x3:=x3/u; y3:=y3/u; z3:=z3/u;  {1st normal}
  x4:=x4/v; y4:=y4/v; z4:=z4/v;   {2nd normal}
  x:=xc+r3*cos(s)*x3+r3*sin(s)*x4; {Core curve + spiral in normal direction}
  y:=yc+r3*cos(s)*y3+r3*sin(s)*y4;
  z:=zc+r3*cos(s)*z3+r3*sin(s)*z4;
end;

{************************************}
procedure TSpaceCurveForm.makeHelix;
var i:integer; t,x,y,z:extended;
begin
  Helixlist:=TD3FloatPointlist.create;
  for i:=0 to tmesh do
  begin
    t:=tmin+i*(tmax-tmin)/tmesh;
    helix(t,x,y,z);
    HelixList.add(x,y,z);
  end;
end;


{**************************}
procedure TSpaceCurveForm.DrawHelix1;
var savecolor:tcolor;
begin
  with graphimage do
  begin
    clear;
    savecolor:=pen.color;
    pen.color:=curvecolor;
    d3polyline(Helixlist);
    pen.color:=savecolor;
  end;
end;

{*************************************}
procedure TSpaceCurveForm.DrawHelix2;
var savecolor:tcolor;
begin
  with graphimage do
  begin
    clear;
    d3drawworldbox;
    d3drawaxes('x','y','z',4,4,4,0,0,0);
    savecolor:=pen.color;
    pen.color:=curvecolor;
    d3polyline(Helixlist);
    pen.color:=savecolor;
  end;
end;

{***********************************}
procedure TSpaceCurveForm.InButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  graphimage.D3StartZoomingin(zoominc);
end;

{**********************************************}
procedure TSpaceCurveForm.InButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StopZooming;
end;

{****************************************}
procedure TSpaceCurveForm.OutButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartZoomingOut(zoominc);
end;

{*********************************}
procedure TSpaceCurveForm.UpButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingup(rotinc);
end;

{***************************}
procedure TSpaceCurveForm.UpButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GraphImage.D3StopRotating;
end;

{***************************}
procedure TSpaceCurveForm.LeftButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingLeft(rotinc);
end;

{*******************************}
procedure TSpaceCurveForm.RightButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingRight(rotinc);
end;


{*********************************}
procedure TSpaceCurveForm.DownButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingDown(rotinc);
end;

{****************************}
procedure TSpaceCurveForm.GraphImageResize(Sender: TObject);
begin
  drawhelix;
  invalidate;
end;


{*********************************}
procedure TSpaceCurveForm.MoveOutButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartMovingOut(moveinc);
end;

{****************************}
procedure TSpaceCurveForm.MoveInButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartMovingIn(moveinc);
end;

{*************************************}
procedure TSpaceCurveForm.MoveInButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StopMoving;
end;


procedure tSpaceCurveForm.upd;
begin
  with graphImage do
  begin
    vdshow.caption:=floattostrf(d3viewdist,ffgeneral,4,4);
    vashow.caption:=FloattoStrF(d3viewangle,ffgeneral,4,4);
    zrshow.caption:=FloattoStrF(d3zrotation,ffgeneral,4,4);
    yrshow.caption:=FloattoStrF(d3yrotation,ffgeneral,4,4);
  end;
end;

procedure TSpaceCurveForm.FormDestroy(Sender: TObject);
begin
  helixlist.free;
end;

{eventhandler while rotating, zooming or moving}
{compare to the one in SurfaceForm}
procedure TSpaceCurveForm.GraphimageRotating(Sender: TObject);
begin
  drawhelix;
  upd;
end;

procedure TSpaceCurveForm.GraphimageRotateStop(Sender: TObject);
begin
  drawhelix;
  upd;
end;


procedure TSpaceCurveForm.AspectcheckClick(Sender: TObject);
begin
  graphimage.d3aspectratio:=aspectcheck.checked;
  drawhelix;
end;

procedure TSpaceCurveForm.AxescheckClick(Sender: TObject);
begin
  if axescheck.checked then drawhelix:=drawhelix2 else
  drawhelix:=drawhelix1;
  drawhelix;
end;

procedure TSpaceCurveForm.Button1Click(Sender: TObject);
var  n,m:integer; a:extended;
begin
  n:=random(10)+1; m:=random(10)+1;
  a:=n*m/sqrt(sqr(n)+sqr(m));
  orbiting:=true;
  while orbiting do
  with graphimage do
  begin
    d3zrotation:=d3zrotation+a/n;
    d3yrotation:=d3yrotation+a/m;
    GraphimageRotateStop(self);
    application.processmessages;
  end;
end;

procedure TSpaceCurveForm.Button2Click(Sender: TObject);
begin
  orbiting:=false;
end;

procedure TSpaceCurveForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  canclose:=not orbiting;
end;

procedure TSpaceCurveForm.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  saveasmetafile1.enabled:=false;
  checkbox1.enabled:=false;
  {$ENDIF}
  drawhelix;
end;


procedure TSpaceCurveForm.CopytoClipboard1Click(Sender: TObject);
begin
  clipboard.assign(graphimage.bitmap);
end;

procedure TSpaceCurveForm.SaveasMetafile1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with savedialog1 do
  if execute then graphimage.saveasmetafile(filename);
  {$ENDIF}
end;

procedure TSpaceCurveForm.CheckBox1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  With graphimage do
  begin
    RecordMetafile:=checkbox1.checked;
    saveasmetafile1.enabled:=recordmetafile;
  end;
  {$ENDIF}
end;

end.
