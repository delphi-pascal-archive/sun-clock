unit Plane;
{Demonstrates 2-d-graphing with TMathImage. I've set all the real types
here to double to demonstrate that TMathImage can be used with any float
type. Parts that make use of TMathImage are marked ***********}

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
  Forms, Dialogs, StdCtrls, ExtCtrls, Mathimge, Menus,Clipbrd;

type
  TPlaneGraphs = class(TForm)
    Panel2: TPanel;
    xshow: TLabel;
    yshow: TLabel;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Periods: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Button1: TButton;
    F1line: TEdit;
    F2line: TEdit;
    Meshline: TEdit;
    Pline: TEdit;
    CheckBox1: TCheckBox;
    Button3: TButton;
    Label8: TLabel;
    Button4: TButton;
    x1label: TLabel;
    x2label: TLabel;
    y1label: TLabel;
    y2label: TLabel;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    GraphImage: TMathImage;
    SaveasMetafile1: TMenuItem;
    SaveDialog1: TSaveDialog;
    CheckBox2: TCheckBox;
    procedure Button1Click(Sender: TObject);
    procedure GraphImageResize(Sender: TObject);
    procedure GraphImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormCreate(Sender: TObject);
    procedure F1lineChange(Sender: TObject);
    procedure F2lineChange(Sender: TObject);
    procedure PlineChange(Sender: TObject);
    procedure MeshlineChange(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure GraphImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GraphImageMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure SaveasMetafile1Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
  private
    f1,f2,p:double;
    mesh:integer;
    xorg,yorg,xmov,ymov:extended;
    beginBox, Boxing:boolean;
    savebrushcolor:TColor;
    procedure CreateParams(var Params: TCreateParams); override;
    function getf1:double;
    function getf2:double;
    function getp:double;
    function getmesh:integer;
    function r(o:double):double;
    procedure upd;
    { Private declarations }
  public
    { Public declarations }
  end;

  var PlaneGraphs:TPlaneGraphs;

implementation

uses MDemo1;

{$R *.DFM}

procedure TPlaneGraphs.CreateParams(var Params: TCreateParams);
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

function TPlaneGraphs.getf1;
var x:double; c:integer;
begin
  val(f1line.text,x,c);
  if c=0 then getf1:=x else getf1:=f1;
end;

function TPlaneGraphs.getf2;
var x:double; c:integer;
begin
  val(f2line.text,x,c);
  if c=0 then getf2:=x else getf2:=f2;
end;

function TPlaneGraphs.getp;
var x:double; c:integer;
begin
  val(pline.text,x,c);
  if c=0 then getp:=x else getp:=p;
end;

function TPlaneGraphs.getmesh;
var i,c:integer;
begin
  val(meshline.text,i,c);
  if c=0 then getmesh:=i else getmesh:=mesh;
end;

function TPlaneGraphs.r;
begin
  r:=sin(o*f1)+cos(o*f2);
end;


{**************************************}
procedure TPlaneGraphs.Button1Click(Sender: TObject);
var i:integer; o:double;
begin
  Screen.Cursor:=CrHourGlass;
  with graphimage do
  begin
    {setworld(strtofloat(x1edit.text),strtofloat(y1edit.text),
             strtofloat(x2edit.text),strtofloat(y2edit.text)); }
    LockUpdate;
    clear;
    d2axes:=checkbox1.checked;
    movetopoint(r(0),0);
    for i:=1 to mesh do
    begin
      o:=i*2*p*Pi/mesh;
      drawlineto(r(o)*cos(o),r(o)*sin(o));
    end;
    if d2axes then
    drawaxes('x','y',true,font.color,clred);
    UnlockUpdate;
  end;
  
  Screen.Cursor:=CrDefault;

end;

{************************************}
procedure TPlaneGraphs.GraphImageResize(Sender: TObject);
begin
  button1click(self);
end;


{************************}
procedure TPlaneGraphs.FormCreate(Sender: TObject);
begin
  f1:=1; f2:=1.4426395219; p:=50; mesh:=4000;
  f1:=getf1; f2:=getf2; p:=getp; mesh:=getmesh;
  upd;
  BeginBox:=false; Boxing:=False;
  controlstyle:=controlstyle+[csOpaque];
  savebrushcolor:=graphimage.brush.color;
end;

procedure TPlaneGraphs.upd;
begin
  with graphimage do
  begin
    x1label.caption:=FloatToStrF(d2worldx1,ffgeneral,6,6);
    x2label.caption:=FloatToStrF(d2worldx2,ffgeneral,6,6);
    y1label.caption:=FloatToStrF(d2worldy1,ffgeneral,6,6);
    y2label.caption:=FloatToStrF(d2worldy2,ffgeneral,6,6);
  end;
end;

procedure TPlaneGraphs.F1lineChange(Sender: TObject);
begin
  f1:=getf1;
end;

procedure TPlaneGraphs.F2lineChange(Sender: TObject);
begin
  f2:=getf2;
end;

procedure TPlaneGraphs.PlineChange(Sender: TObject);
begin
  p:=getp;
end;

procedure TPlaneGraphs.MeshlineChange(Sender: TObject);
begin
  mesh:=getmesh;
end;


 {***********************************}
procedure TPlaneGraphs.Button3Click(Sender: TObject);
var w,h,x,y:extended;
begin
  with graphimage do
  begin
    w:=(d2worldx2-d2worldx1)*4/3;
    h:=(d2worldy2-d2worldy1)*4/3;
    x:=(d2worldx1+d2worldx2-w)/2;
    y:=(d2worldy1+d2worldy2-h)/2;
    setworld(x,y,x+w,y+h);
  end;
  upd;
  button1click(self);
end;

{**************************************}
procedure TPlaneGraphs.Button4Click(Sender: TObject);
begin
  Screen.Cursor:=crCross;
  BeginBox:=true;
end;

{********************************}
procedure TPlaneGraphs.GraphImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  If shift=[ssleft] then if beginbox then
  with graphimage do begin
    boxing:=true;
    canvas.brush.style:=bsclear;
    xorg:=worldx(x); yorg:=worldy(y);
    xmov:=xorg; ymov:=yorg;
  end;
end;

{****************************************}
procedure TPlaneGraphs.GraphImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  with GraphImage do
  begin
    xshow.caption:=floattostrf(worldx(x),ffgeneral,5,5);
    yshow.caption:=floattostrf(worldy(y),ffgeneral,5,5);
    if boxing then
    begin
      canvas.pen.mode:=pmNotXor;
      drawrectangle(xorg,yorg,xmov,ymov);
      xmov:=worldx(x); ymov:=worldy(y);
      drawrectangle(xorg,yorg,xmov,ymov);
    end;
  end;
end;


{***************************************}
procedure TPlaneGraphs.GraphImageMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var s:extended;
begin
  If boxing then
  with graphimage do
  begin
    boxing:=false;
    beginbox:=false;
    drawrectangle(xorg,yorg,xmov,ymov);
    pen.mode:=pmcopy;
    brush.style:=bssolid;
    brush.color:=savebrushcolor;
    {whenever the brush style changes, the brush has
    forgotten its color}
    if xorg>xmov then
    begin
      s:=xorg;
      xorg:=xmov;
      xmov:=s;
    end;
    if ymov>yorg then
    begin
      s:=yorg;
      yorg:=ymov;
      ymov:=s;
    end;
    try
      setworld(xorg,ymov,xmov,yorg);
    except
      On EMathImageError do
      MessageDlg('Zoom box too small',mtError,[mbOK],0);
    end;
    button1click(self);
    upd;
    Screen.Cursor:=crDefault;
  end;
end;


procedure TPlaneGraphs.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  saveasmetafile1.enabled:=false;
  checkbox2.enabled:=false;
  {$ENDIF}
  Button1Click(self);
end;


procedure TPlaneGraphs.Copy1Click(Sender: TObject);
begin
 clipboard.assign(GraphImage.bitmap);
end;

procedure TPlaneGraphs.SaveasMetafile1Click(Sender: TObject);
begin
 {$IFDEF WIN32}
  with savedialog1 do
  if execute then graphimage.saveasmetafile(filename);
  {$ENDIF}
end;

procedure TPlaneGraphs.CheckBox2Click(Sender: TObject);
begin
{$IFDEF WIN32}
  with graphimage do
  begin
    recordmetafile:=checkbox2.checked;
    saveasmetafile1.enabled:=recordmetafile;
  end;
  {$ENDIF}
end;

end.
