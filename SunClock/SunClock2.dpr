program SunClock2;

uses
  Forms,
  UMain in 'UMain.pas' {MainForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'SunClock';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
