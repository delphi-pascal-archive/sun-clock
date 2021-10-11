unit Dataplot;
{How to draw a list of D3-curves, for example to show a time evolution of
a spatial distribution of values. Also demonstrates scaling of axes.
As an example I've picked two waves that move in opposite directions in time.
It's just one example how to fill a D3FloatPointListList with data to be
plotted.}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, mathimge, StdCtrls,
   Menus, Clipbrd;

type
  TDataPlotForm = class(TForm)
    Panel1: TPanel;
    xminEdit: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    xmaxEdit: TEdit;
    Label3: TLabel;
    tmaxEdit: TEdit;
    Button1: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    XscaleEdit: TEdit;
    TscaleEdit: TEdit;
    UscaleEdit: TEdit;
    Button2: TButton;
    Label8: TLabel;
    tminEdit: TEdit;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    WaveImage: TMathImage;
    SaveDialog1: TSaveDialog;
    PopupMenu1: TPopupMenu;
    CopytoClipboard1: TMenuItem;
    SaveasMetafile1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure WaveImageResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WaveImageMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure WaveImageMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CopytoClipboard1Click(Sender: TObject);
    procedure SaveasMetafile1Click(Sender: TObject);
  private
    wavelist:TD3FloatPointListList;
    xmin,xmax,tmin,tmax:extended;
    t,x,xold,yold,zold:extended;
    zoomingIn, zoomingOut:boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    function u0(x:extended):extended;
    procedure MakeWaveList;
    procedure DrawWaves;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataPlotForm: TDataPlotForm;

implementation

uses mdemo1;

{$R *.DFM}

procedure TDataPlotForm.CreateParams(var Params: TCreateParams);
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

function TDataPlotForm.u0(x:extended):extended;
{wave shape}
begin
  try
    result:=exp(-sqr(x/10));
  except
    on EMatherror do result:=0;
  end;
end;

procedure TDataPlotForm.MakeWavelist;
var i,j:integer; u:extended;

  function max(x,y:extended):extended;
  begin
    result:=x; if y>x then result:=y;
  end;

begin
  if wavelist<>nil then wavelist.free;
  wavelist:=TD3FloatPointListList.create;
  for j:=0 to 70 do
  begin
    t:=tmin+j*(tmax-tmin)/70;
    wavelist.add; {add a new time snapshot list}
    for i:=0 to 300 do
    begin
      x:=xmin+i*(xmax-xmin)/300; {space mesh point}
      u:=max(u0(x+50-0.9*t),max(u0(x-50+0.6*t),u0(x-100+2*t))); {take the max of 3 displaced waves}
      wavelist.AddtoCurrent(x,t,u);
    end;
  end;
end;



procedure TDataPlotForm.FormCreate(Sender: TObject);
begin
  xmin:=-50; xmax:=70; tmin:=0; tmax:=100;
  wavelist:=nil;
  zoomingIn:=false;
  zoomingOut:=false;
  makeWaveList;
  xold:=1.e12; yold:=1.e12; zold:=1.e12;
end;

procedure TDataPlotForm.DrawWaves;
begin
  With WaveImage do
  begin
    brush.style:=bssolid;
    brush.color:=clwhite;
    clear;
    pen.mode:=pmcopy;
    pen.color:=clgray;
    D3DrawFullWorldBox;
    pen.color:=clblack;
    D3PolyPolyLine(wavelist);
    pen.color:=clgray;
    D3Drawaxes('x','t','u',4,5,2,MinMin,MaxMin,MinMin);
    {Note number of ticks and placement of axes}
  end;
end;

procedure TDataPlotForm.WaveImageResize(Sender: TObject);
begin
  DrawWaves;
end;



procedure TDataPlotForm.FormShow(Sender: TObject);
begin
  {$IFDEF WINDOWS}
  saveasmetafile1.enabled:=false;
  {$ENDIF}
  DrawWaves;
end;

procedure TDataPlotForm.Button1Click(Sender: TObject);
var x1,x2,t1,t2:extended;
begin
  x1:=xmin; x2:=xmax; t2:=tmax;  t1:=tmin;
  try
    xmin:=StrToFloat(xminedit.text);
    xmax:=StrToFloat(xmaxedit.text);
    tmin:=StrToFloat(tminedit.text);
    tmax:=StrToFloat(tmaxedit.text);
  except
    on EConvertError do
    begin
      xmin:=x1; xmax:=x2; tmax:=t2; tmin:=t1;
      messagebeep(0);
      xminedit.text:=FloatToStrF(xmin,ffgeneral,4,4);
      xmaxedit.text:=FloatToStrF(xmax,ffgeneral,4,4);
      tmaxedit.text:=FloatToStrF(tmax,ffgeneral,4,4);
      tminedit.text:=FloatToStrF(tmin,ffgeneral,4,4);
    end;
  end;
  WaveImage.d3setworld(xmin,tmin,0,xmax,tmax,1);
  makeWaveList;
  DrawWaves;
end;

procedure TDataPlotForm.Button2Click(Sender: TObject);
var xs,ts,us:extended;
begin
  with WaveImage do
  begin
    xs:=D3XScale;
    ts:=D3YScale;
    us:=D3ZScale;
    try
      D3XScale:=StrToFloat(XScaleEdit.text);
      D3YScale:=StrToFloat(TScaleEdit.text);
      D3ZScale:=StrToFloat(UScaleEdit.text);
    except
      on EConverterror do
      begin
        D3xscale:=xs; D3yscale:=ts; D3zscale:=us;
        messagebeep(0);
        XScaleEdit.text:=FloatToStrF(xs,ffgeneral,4,4);
        TScaleEdit.text:=FloatToStrF(ts,ffgeneral,4,4);
        UScaleEdit.text:=FloatToStrF(us,ffgeneral,4,4);
      end;
    end;
    drawwaves;
  end;
end;

procedure TDataPlotForm.FormDestroy(Sender: TObject);
begin
  if wavelist<>nil then wavelist.free;
end;

procedure TDataPlotForm.WaveImageMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  var xx,yy,zz,wx,wy,fact:extended;
begin
  if zoomingIn or zoomingOut then
  with WaveImage do
  begin
    PseudoD3World(x,y,xx,yy,zz);
    if zoomingIn then fact:=1/4 else fact:=1;
    wx:=(d3Worldx2-d3Worldx1)*fact;
    wy:=(d3Worldy2-d3Worldy1)*fact;
    xmin:=xx-wx; xmax:=xx+wx; tmin:=yy-wy; tmax:=yy+wy;
    xminedit.text:=FloatToStrF(xmin,ffgeneral,4,4);
    xmaxedit.text:=FloatToStrF(xmax,ffgeneral,4,4);
    tmaxedit.text:=FloatToStrF(tmax,ffgeneral,4,4);
    tminedit.text:=FloatToStrF(tmin,ffgeneral,4,4);
    d3SetWorld(xmin,tmin,0,xmax,tmax,1);
    makewavelist;
    drawwaves;
    zoomingIn:=false; zoomingOut:=false;
    screen.cursor:=crDefault;
    xold:=1.e12; yold:=1.e12; zold:=1.e12;
  end;
end;


procedure TDataPlotForm.Button3Click(Sender: TObject);
begin
  xminedit.text:='-50'; xmaxedit.text:='70';
  tminedit.text:='0'; tmaxedit.text:='100';
  Button1click(self);
end;

procedure TDataPlotForm.Button4Click(Sender: TObject);
begin
  ZoomingIn:=true;
  Screen.cursor:=
  {$IFDEF WIN32}
  crHandPoint;
  {$ELSE}
  crCross;
  {$ENDIF}
end;

procedure TDataPlotForm.Button5Click(Sender: TObject);
begin
  zoomingOut:=true;
  Screen.Cursor:=
  {$IFDEF Win32}
  crHandPoint;
  {$ELSE}
  crCross;
  {$ENDIF}
end;

procedure TDataPlotForm.WaveImageMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
  var xx,yy,zz,wx,wy,fact:extended; 
begin
  If ZoomingIn or ZoomingOut then
  with WaveImage do
  begin
    PseudoD3World(x,y,xx,yy,zz);
    if zoomingIn then fact:=1/4 else fact:=1;
    wx:=(d3Worldx2-d3Worldx1)*fact;
    wy:=(d3Worldy2-d3Worldy1)*fact;
    pen.color:=clred;
    pen.mode:=pmNotXor;
    brush.style:=bsClear;
    D3DrawBox(xold-wx,yold-wy,0,xold+wx,yold+wy,1);
    D3DrawBox(xx-wx,yy-wy,0,xx+wx,yy+wy,1);
    xold:=xx; yold:=yy; zold:=zz;
  end;
end;

procedure TDataPlotForm.CopytoClipboard1Click(Sender: TObject);
begin
  clipboard.assign(waveimage.bitmap);
end;

procedure TDataPlotForm.SaveasMetafile1Click(Sender: TObject);
begin
  {$IFDEF WIN32}
  with savedialog1 do
  if execute then
  waveimage.saveasmetafile(filename);
  {$ENDIF}
end;

end.
