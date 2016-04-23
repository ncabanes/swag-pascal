{
    A fragment to save a help context to disk/printer, in Turbo
Vision 2.0:

In HelpFile.PAS:
}

Uses ... , ... , Print;

Type

  TSetup = Record
    HFIleName : String[80];
    OutTxt,
    Paper     : Word;
  end;

  PHelpViewer = ^THelpViewer;
  THelpViewer = object(TScroller)
    HFile: PHelpFile;
    Topic: PHelpTopic;
    Selected: Integer;
    constructor Init(var Bounds: TRect; AHScrollBar,
      AVScrollBar: PScrollBar; AHelpFile: PHelpFile; Context: Word);
    destructor Done; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    Procedure Print; {++++++ NEW +++++}
  end;

Var
  Setup       : TSetup;

{--------Procedure THelpViewer.Print--------}

procedure THelpViewer.Print;
var
  I      : Integer;
  F      : Text;
  Dialog : PDialog;
  R      : TRect;
  Control: PView;
  Ctrl,
  Modulo : Word;
begin
  R.Assign(00, 00, 35, 15);
  Dialog := New(PDialog,  Init(R, 'Save Help Context'));
  With Dialog^ do
    begin
      Options := Options or ofFramed or ofCentered;
      Setup.HFileName := 'HelpCtx.txt';
      R.Assign(3, 3, 32, 4);
      Control := New(PInputLine, Init(R, 80));
      Control^.Options := Control^.Options or ofFramed;
      Dialog^.Insert(Control);

        R.Assign(29, 3, 32, 4);
        Control := New(PHistory, Init(R, PInputline(Control), 3));
        Dialog^.Insert(Control);

        R.Assign(3, 2, 20, 3);
        Control := New(PLabel, Init(R, 'File Name:',Control));
        Dialog^.Insert(Control);

      Setup.OutTxt := $0;
      R.Assign(3, 6, 32, 7);
      Control := New(PRadioButtons, Init(R,
        NewSItem('Disk',
        NewSItem('Printer', Nil))));
      Control^.Options := Control^.Options or ofFramed;
      Dialog^.Insert(Control);

        R.Assign(3, 5, 13, 6);
        Control :=  New(PLabel, Init(R, 'Save to:', Control));
        Dialog^.Insert(Control);

      Setup.Paper := $00;
      R.Assign(3, 9, 32, 10);
      Control := New(PRadioButtons, Init(R,
        NewSItem('66 lines',
        NewSItem('72 lines', Nil))));
      Control^.Options := Control^.Options or ofFramed;
      Dialog^.Insert(Control);

        R.Assign(3, 8, 21, 9);
        Control := New(PLabel, Init(R, 'Paper:',Control));
        Dialog^.Insert(Control);

      R.Assign(3, 12, 13, 14);
      Control := New(PButton, Init(R, 'O~k~', cmOK, bfDefault));
      Dialog^.Insert(Control);
      R.Assign(21, 12, 31, 14);
      Control := New(PButton, Init(R, '~C~ancel', cmCancel, bfNormal));
      Dialog^.Insert(Control);

      Dialog^.SelectNext(False);
    end;
  Dialog^.SetData(Setup);
  Ctrl := Application^.ExecView(Dialog);
  If Ctrl <> cmCancel Then
  Begin
    Dialog^. GetData (Setup);
    Case Setup.OutTxt of
      $00 : Begin
              If Setup.HFileName = '' then Setup.HFileName := 'HlpCtx.txt';
              Assign(F, Setup.HFileName);
              Rewrite(F);
              For I := 1 to Topic^.NumLines do Writeln(F,Topic^.GetLine(I));
              Close(F);
            end;
      $01 : begin
              Case Setup.Paper of
                $00 : begin
                        Modulo := 60;
                        Write (Lst,Chr(27)+'C'+chr(66))
                      end;
                $01 : begin
                        Modulo := 66;
                        Write (Lst,Chr(27)+'C'+chr(72))
                      end;
              end;
              For I := 1 to Topic^.NumLines do
                begin
                  Writeln(Lst,Topic^.GetLine(I));
                  If I Mod Modulo = 0 then Write(Lst,#12);
                end;
              Write(Lst,#12);
            end
    end;
  end;
end;

{--------Procedure THelpViewer.HandleEvent---------}
........ fragment
          kbEnter:if Selected <= Topic^.GetNumCrossRefs then
            begin
              Topic^.GetCrossRef(Selected, KeyPoint, KeyLength, KeyRef);
              SwitchToTopic(KeyRef);
            end;
          kbAltSpace:   +++ New +++
            begin       +++ New +++
              Print;    +++ New +++
            end         +++ New +++
        else
          Exit;
        end;
        DrawView;
        ClearEvent(Event);
        .......... fragment
