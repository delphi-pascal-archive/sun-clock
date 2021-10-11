unit Light;
{Demonstrates some 3-D-features of MathImage, as well as the use
 of the TSurface object. The routines marked by *********** use
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
  Forms, Dialogs, StdCtrls, ExtCtrls,
  Mathimge, Menus,clipbrd;

const tmin=-Pi; tmax=Pi; smin=0; smax=2*Pi;
      tmesh=170; smesh=30; {knot parameter mesh}
      r=1.4; {radius of knot tube}
      kxmin=-6.1; kxmax=6.1; kymin=-6.1; kymax=6.1;
      kzmin=-3.1; kzmax=3.1; {knot world box}
      gxmin=-Pi; gxmax=Pi; gymin=-Pi; gymax=Pi; {graph domain}
      xmesh=70; ymesh=70; {graph mesh}
      gzmin=-2; gzmax=3.2; {graph range}
      RotInc=1.5; ZoomInc=0.015; MoveInc=0.008;{increments for rotation/zoom}

type
  TLitSurfaceForm = class(TForm)
    Panel1: TPanel;
    KnotButton: TButton;
    FillButton: TButton;
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
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GraphButton: TButton;
    Aspectcheck: TCheckBox;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    BackEdit: TEdit;
    FrontEdit: TEdit;
    Button1: TButton;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    graphimage: TMathImage;
    SaveasMetafile1: TMenuItem;
    SaveDialog1: TSaveDialog;
    CheckBox1: TCheckBox;
    procedure FillButtonClick(Sender: TObject);
    procedure KnotButtonClick(Sender: TObject);
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
    procedure GraphButtonClick(Sender: TObject);
    procedure GraphimageRotating(Sender: TObject);
    procedure GraphimageRotateStop(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure SaveasMetafile1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
  fillcolor:TColor;
  knotsurface,graphsurface,roughknotsurface,roughgraphsurface:Tsurface;
  currenttype:integer;
  function x0(t:extended):extended;
  function y0(t:extended):extended;
  function z0(t:extended):extended;
  function x1(t:extended):extended;
  function y1(t:extended):extended;
  function z1(t:extended):extended;
  function x2(t:extended):extended;
  function y2(t:extended):extended;
  function z2(t:extended):extended;
  procedure knot(t,s:extended; var x,y,z:extended);
  procedure graph(x,y:extended; var z:extended);
  procedure makeknotsurface;
  procedure makegraphsurface;
  procedure upd;
    { Private declarations }
  protected
    procedure CreateParams(var Params: TCreateParams); override;  
  public
    { Public declarations }
  end;

var
  LitSurfaceForm: TLitSurfaceForm;

implementation

uses Mdemo1;


{$R *.DFM}

procedure TLitSurfaceForm.CreateParams(var Params: TCreateParams);
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
procedure TLitSurfaceForm.FormCreate(Sender: TObject);
begin
  fillcolor:=clteal;
  makeknotsurface;
  makegraphsurface;
  upd;
  currenttype:=1;
  controlstyle:=controlstyle+[csOpaque];
end;


procedure TLitSurfaceForm.FillButtonClick(Sender: TObject);
begin
  with colordialog1 do
  if execute then fillcolor:=color;
  GraphImageRotateStop(self);
end;

function TLitSurfaceForm.x0; {Knot Core Curve}
begin
  result:=2*cos(2*t)+cos(t);
end;

function TLitSurfaceForm.x1; {1st Derivative}
begin
  result:=-4*sin(2*t)-sin(t);
end;

function TLitSurfaceForm.x2;  {2nd Derivative}
begin
  result:=-8*cos(2*t)-cos(t);
end;

function TLitSurfaceForm.y0;  {Knot Core Curve}
begin
  result:=2*sin(2*t)-sin(t);
end;

function TLitSurfaceForm.y1;
begin
  result:=4*cos(2*t)-cos(t);
end;

function TLitSurfaceForm.y2;
begin
  result:=-8*sin(2*t)+sin(t);
end;

function TLitSurfaceForm.z0;  {Knot Core Curve}
begin
  result:=sin(3*t);
end;

function TLitSurfaceForm.z1;
begin
  result:=3*cos(3*t);
end;

function TLitSurfaceForm.z2;
begin
  result:=-9*sin(3*t);
end;

procedure TLitSurfaceForm.knot; {Tube surface about core curve}
var u,v,x3,y3,z3,x4,y4,z4,x5,y5,z5,x6,y6,z6:extended;
begin
  u:=sqr(x1(t))+sqr(y1(t))+sqr(z1(t));
  v:=x1(t)*x2(t)+y1(t)*y2(t)+z1(t)*z2(t);
  x3:=x2(t)*u-x1(t)*v; {1st perp vector}
  y3:=y2(t)*u-y1(t)*v;
  z3:=z2(t)*u-z1(t)*v;
  x4:=y1(t)*z3-z1(t)*y3; {2nd perp vector}
  y4:=z1(t)*x3-x1(t)*z3;
  z4:=x1(t)*y3-y1(t)*x3;
  u:=sqrt(sqr(x3)+sqr(y3)+sqr(z3));
  v:=sqrt(sqr(x4)+sqr(y4)+sqr(z4));
  x5:=x3/u; y5:=y3/u; z5:=z3/u;  {1st normal}
  x6:=x4/v; y6:=y4/v; z6:=z4/v;   {2nd normal}
  x:=2*x0(t)+r*cos(s)*x5+r*sin(s)*x6; {Core curve + circle in normal plane}
  y:=2*y0(t)+r*cos(s)*y5+r*sin(s)*y6;
  z:=2*z0(t)+r*cos(s)*z5+r*sin(s)*z6;
end;

procedure TLitSurfaceForm.Graph(x,y:extended; var z:extended);
var r:extended;
{graph formula}
begin
  r:=sqrt(sqr(x)+sqr(y));
  z:=3*exp(-x*x/1.5)*sin(2*r);
end;

{**************************}
procedure TLitSurfaceForm.KnotButtonClick(Sender: TObject);
var back, front:extended;
savepen:tpen; savebrush:tbrush;
begin
  try
    back:=StrToFloat(BackEdit.text);
    front:=StrToFloat(FrontEdit.text);
  except
    on E:EConvertError do
    begin
      messagedlg(E.message,mtError,[mbOk],0);
      exit;
    end;
  end;
  screen.cursor:=crhourglass;
  currenttype:=1;
  with graphimage do
  begin
    d3SetWorld(kxmin,kymin,kzmin,kxmax,kymax,kzmax);
    d3aspectratio:=aspectcheck.checked;
    clear;
    {d3drawworldbox;}
    {d3drawaxes('x','y','z',2,2,2,0,0,0);}
    savebrush:=tbrush.create;
    savepen:=tpen.create;
    savebrush.assign(brush);
    savepen.assign(pen);
    brush.color:=fillcolor;
    brush.style:=bssolid;
    Try
      d3drawLitsurface(knotsurface,back,front,Radiobutton1.checked);
    except
      on E:ESurfaceError do
      begin
        screen.cursor:=crdefault;
        MessageDlg(E.message,mtError,[mbOk],0);
      end;
    end;
    brush.assign(savebrush);
    pen.assign(savepen);
    savebrush.free;
    savepen.free;
  end;
  screen.cursor:=crdefault;
end;

{******************************}
procedure TLitSurfaceForm.GraphButtonClick(Sender:TObject);
var back,front:extended;
    spen:tpen; sbrush:tbrush;
begin
  screen.cursor:=crhourglass;
  currenttype:=2;
  with graphimage do
  begin
    d3setworld(gxmin,gymin,gzmin,gxmax,gymax,gzmax);
    d3aspectratio:=aspectcheck.checked;
    clear;
    {d3drawworldbox;}
    {d3drawaxes('x','y','z',2,2,2,0,0,0);}
    sbrush:=tbrush.create;
    spen:=tpen.create;
    sbrush.assign(brush);
    spen.assign(pen);
    brush.color:=fillcolor;
    brush.style:=bssolid;
    try
      back:=StrToFloat(BackEdit.text);
      front:=StrToFloat(FrontEdit.text);
    except
      on E:EConvertError do
      begin
        messageDlg(E.message,mtError,[mbOK],0);
        exit;
      end;
    end;
    Try
      d3drawLitsurface(graphsurface,back,front,Radiobutton1.checked);
    except
      on E:ESurfaceError do
      begin
        screen.cursor:=crdefault;
        messagedlg(E.message,mtError,[mbOk],0);
      end;
    end;
    brush.assign(sbrush);
    pen.assign(spen);
    sbrush.free;
    spen.free;
  end;
  screen.cursor:=crdefault;
end;


{************************************}
procedure TLitSurfaceForm.makeKnotSurface;
var i,j:integer; t,s,x,y,z:extended;
begin
  try
    KnotSurface:=Tsurface.create(tmesh,smesh);
    roughKnotSurface:=TSurface.create(tmesh div 2, smesh div 2);
  except
    on E:ESurfaceError do
    begin
      MessageDLG(E.Message,mtError,[mbOK],0);
      exit;
    end;
  end;
  for i:=0 to tmesh do
  begin
    t:=tmin+i*(tmax-tmin)/tmesh;
    for j:=0 to smesh do
    begin
      s:=smin+j*(smax-smin)/smesh;
      knot(t,s,x,y,z);
      knotsurface.make(i,j,x,y,z);
      if i mod 2=0 then if j mod 2=0 then
      roughknotsurface.make(i div 2, j div 2,x,y,z);
    end;
  end;
end;

{*****************************************}
procedure TLitSurfaceForm.MakeGraphSurface;
var i,j:integer; x,y,z:extended;
begin
  Try
    GraphSurface:=Tsurface.create(xmesh,ymesh);
    roughgraphsurface:=Tsurface.create(xmesh div 2, ymesh div 2);
  except
    on E:ESurfaceError do
    begin
      MessageDlg(E.message,mtError,[mbOk],0);
      exit;
    end;
  end;
  for i:=0 to xmesh do
  begin
    x:=gxmin+i*(gxmax-gxmin)/xmesh;
    for j:=0 to ymesh do
    begin
      y:=gymin+j*(gymax-gymin)/ymesh;
      graph(x,y,z);
      graphsurface.make(i,j,x,y,z);
      if i mod 2=0 then if j mod 2=0 then
      roughgraphsurface.make(i div 2, j div 2, x,y,z);
    end;
  end;
end;

{*******************************}
procedure TLitSurfaceForm.InButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  with graphimage do
     D3StartZoomingin(ZoomInc);
end;

{**********************************************}
procedure TLitSurfaceForm.InButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StopZooming;
end;

{ETC...................}
procedure TLitSurfaceForm.OutButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartZoomingOut(ZoomInc);
end;


procedure TLitSurfaceForm.UpButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingup(RotInc);
end;

procedure TLitSurfaceForm.UpButtonMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  GraphImage.D3StopRotating;
end;

procedure TLitSurfaceForm.LeftButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingLeft(RotInc);
end;

procedure TLitSurfaceForm.RightButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingRight(RotInc);
end;


procedure TLitSurfaceForm.DownButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartRotatingDown(RotInc);
end;

{****************************}
procedure TLitSurfaceForm.GraphImageResize(Sender: TObject);
begin
  if currenttype=1 then
  knotbuttonclick(self)
  else graphbuttonclick(self);
  invalidate;
end;

procedure TLitSurfaceForm.MoveOutButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartMovingOut(MoveInc);
end;


procedure TLitSurfaceForm.MoveInButtonMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StartMovingIn(MoveInc);
end;

procedure TLitSurfaceForm.MoveInButtonMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  Graphimage.D3StopMoving;
end;


procedure tLitSurfaceForm.upd;
begin
  with graphImage do
  begin
    vdshow.caption:=floattostrf(d3viewdist,ffgeneral,4,4);
    vashow.caption:=FloattoStrF(d3viewangle,ffgeneral,4,4);
    zrshow.caption:=FloattoStrF(d3zrotation,ffgeneral,4,4);
    yrshow.caption:=FloattoStrF(d3yrotation,ffgeneral,4,4);
  end;
end;

procedure TLitSurfaceForm.FormDestroy(Sender: TObject);
begin
  knotsurface.free;
  graphsurface.free;
  roughknotsurface.free;
  roughgraphsurface.free;
end;



{while rotating, moving, zooming only the axes are drawn to
 save time}
procedure TLitSurfaceForm.GraphimageRotating(Sender: TObject);
var c:TColor;
begin
  with sender as TMathImage do
  begin
    clear;
    c:=brush.color;
    brush.color:=fillcolor;
    if currenttype=1 then
    d3drawsurface(roughknotsurface,true,true)
    else
    d3drawsurface(roughgraphsurface,true,true);
    upd;
    brush.color:=c;
  end;
end;

procedure TLitSurfaceForm.GraphimageRotateStop(Sender: TObject);
begin
  if currenttype=1 then knotbuttonclick(self) else graphbuttonclick(self);
end;

procedure TLitSurfaceForm.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  saveasmetafile1.enabled:=false;
  checkbox1.enabled:=false;
  {$ENDIF}
  knotbuttonclick(self);
end;

procedure TLitSurfaceForm.CopytoClipboard1Click(Sender: TObject);
begin
  clipboard.assign(graphimage.bitmap);
end;

procedure TLitSurfaceForm.SaveasMetafile1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with savedialog1 do
  if execute then graphimage.saveasmetafile(filename);
  {$ENDIF}
end;

procedure TLitSurfaceForm.CheckBox1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with graphimage do
  begin
    recordmetafile:=checkbox1.checked;
    saveasmetafile1.enabled:=recordmetafile;
  end;
  {$ENDIF}
end;

end.
