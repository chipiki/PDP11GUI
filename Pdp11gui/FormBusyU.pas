unit FormBusyU;
{
  Form mit progressbar und ABORT Button.
  Erscheint erst nach Verz�gerung auf, wenn lange Laufdauer zu erwarten ist
}

interface 

uses 
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, 
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls; 


type 
  TBusyForm = class(TForm) 
      ProgressBar1: TProgressBar; 
      InfoLabel: TLabel; 
      AbortButton: TButton; 
      procedure AbortButtonClick(Sender: TObject); 
    private 
      { Private-Deklarationen }
      fEnabled: boolean ; 
      fAborted: boolean ; 
      fSteps: integer ; 
      fStartticks: dword ; 

      function getRunningTime_ms: dword ; 
      function getExpectedEndTime_ms: dword ; 
    public 
      { Public-Deklarationen }
      procedure Start(info:string; total: integer; enabled: boolean) ; 
//      function Progress(current, total: integer): boolean ;
      procedure StepIt ; overload ;
      procedure StepIt(n: integer) ; overload ;
      function Aborted: boolean ;
      procedure Close ;
    end{ "TYPE TBusyForm = class(TForm)" } ; 

var 
  BusyForm: TBusyForm; 

implementation 

{$R *.dfm}


const 
  sampletime_ms = 1000 ; // sample tocks 1 sekunde, bevor �ber pop-up entschieden wird
  displayThreshold_ms = 5000 ; // pop up, wenn vorgang mindestens solange dauert




{
  enabled: false = keine functions, ist fuer caller bequemer so
}
procedure TBusyForm.Start(info:string; total: integer; enabled: boolean) ; 
  begin 
    fEnabled := enabled ; 
    fAborted := false ; 
    InfoLabel.Caption := info ; 
    ProgressBar1.Min := 0 ; 
    ProgressBar1.Max := total ; 
    ProgressBar1.Position := 0 ; 
    fSteps := 0 ; 
    fStartticks := GetTickCount ; 
    // show erst nach Anfangswartepause, wenn Vorgaang l�nger dauern wird
  end; 

function TBusyForm.Aborted: boolean ; 
  begin 
    if not fEnabled then 
      result := false // nie user abbruch
    else begin 
      Application.ProcessMessages ; 
      result := fAborted ; 
    end; 
  end; 

procedure TBusyForm.StepIt(n: integer) ;
  begin
    if not fEnabled then
      Exit ;
    fSteps := fSteps +n ;
    ProgressBar1.Position := fSteps ;
    ProgressBar1.Update ;
    Application.ProcessMessages ;
    if Visible then
      BringToFront
    else begin
      // show erst nach Anfangswartepause, wenn Vorgang l�nger dauern wird
      if (getRunningTime_ms > sampletime_ms)
//      and ( getExpectedEndTime_ms > (fStartticks + displayThreshold_ms)) then
        then
          inherited Show ;
    end ;

  end{ "procedure TBusyForm.StepIt" } ;

  procedure TBusyForm.StepIt ;
  begin
    StepIt(1) ;
  end;



procedure TBusyForm.AbortButtonClick(Sender: TObject);
  begin
    fAborted := true ; 
  end; 

procedure TBusyForm.Close ; 
  begin 
    inherited Close ; 
  end; 


function TBusyForm.getRunningTime_ms: dword ; 
  begin 
    result := GetTickCount - fStartticks ; 
  end; 

// Hochrechnung: wann werden 100% erriecht?
// 0: nicht m�glich
function TBusyForm.getExpectedEndTime_ms: dword ; 
  begin 
    if fSteps = 0 then 
      result := 0 
    else 
      result := round(ProgressBar1.Max * getRunningTime_ms / fSteps) ; 
  end; 


end{ "unit FormBusyU" } . 
