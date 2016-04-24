(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0055.PAS
  Description: Adlib Programming
  Author: FLAVIO RABELLO
  Date: 11-26-94  04:55
*)

{
> Hello, I'm an amateur-programmer and I've got an Adlib Music Card in
> my system (soon to be on a SoundBlaster compatible in my system too).
> The problem is, how can I programm my Adlib in Turbo Pascal ? I don't
> know. I need information sources, units or anything else that can put
> me on the right way. Please help me !!! Everything is welkom !

        I think this source will help you.
        Any questions, please, send me a reply.
}

unit MusicIO;
 {Contains procedures and function to call to Ad-Lib sound Driver.
 if Sound Driver is not Loaded the system WILL Crash.
 Parameters must be passed backwards since the sound driver is made
 for a C parameter passing sequence.}

interface

  uses
    DOS;

  type
    Instrument = array[1..26] of integer;

  var
    GActVoice :word; {Active Voice}
    GT        :array[0..10] of Instrument; {use global variable to keep array
valid}

  procedure InitDriver;
  procedure RelTimeStart(TimeNum,TimeDen :integer);
  procedure SetState(State :integer);
  function GetState :boolean;
  procedure SetMode(PercussionMode :integer);
  function SetVolume(VolNum,VolDen,TimeNum,TimeDen :integer) :boolean;
  function SetTempo(Tempo,TimeNum,TimeDen :integer) :boolean;
  procedure SetActVoice(Voice :word);
  function PlayNote(Pitch :integer; LengthNum,LengthDen :word) :boolean;
  function SetTimbre(TimeNum,TimeDen :word) :boolean;
  procedure SetTickBeat(TickBeat :integer);
  procedure DirectNoteOn(Voice :word; Pitch :integer);
  procedure DirectNoteOff(Voice :word);
  procedure DirectTimbre;
  procedure LoadInstrument(FileSpec :string);
  function LoadSong(FileSpec :string) :boolean;


implementation

  {Returns True if file exists; otherwise, it returns False. Closes the file if
it ex  function Exist(fs :string) :boolean;
    var
      f: file;
    begin
      {$I-}
      Assign(f,fs);
      Reset(f);
      Close(f);
      {$I+}
      Exist:=(IOResult=0) and (fs<>'');
    end;


  procedure InitDriver;
    {Initialize Sound Driver}
    var
      r :registers;
    begin
      r.SI:=0;

      Intr(101,r);
    end;

  procedure RelTimeStart(TimeNum,TimeDen :integer);
    {Set Relative Time to Start}
    var
      TD,TN :integer;
      r :registers;
    begin
      TD:=TimeDen;
      TN:=TimeNum;

      r.SI:=2;
      r.ES:=Seg(TN);
      r.BX:=Ofs(TN);

      Intr(101,r);
    end;

  procedure SetState(State :integer);
    {Start or Stop a Song}
    var
      r :registers;
    begin
      r.SI:=3;
      r.ES:=Seg(State);
      r.BX:=Ofs(State);

      Intr(101,r);
    end;

  function GetState :boolean;
    var
      r :registers;
    begin
      r.SI:=4;
      r.ES:=Seg(GetState);
      r.BX:=Ofs(GetState);

      Intr(101,r);

      GetState:=(r.BP=1);
    end;

  procedure SetMode(PercussionMode :integer);
    {Percussion or Melodic Mode}
    var
      r :registers;
    begin
      r.SI:=6;
      r.ES:=Seg(PercussionMode);
      r.BX:=Ofs(PercussionMode);

      Intr(101,r);
    end;

  function SetVolume(VolNum,VolDen,TimeNum,TimeDen :integer) :boolean;
    var
      TD,TN,VD,VN :word; {To put variables values in proper order in memory}
      r           :registers;
    begin
      TD:=TimeDen;
      TN:=TimeNum;
      VD:=VolDen;
      VN:=VolNum;

      r.SI:=8;
      r.ES:=Seg(VN);
      r.BX:=Ofs(VN);

      Intr(101,r);

      SetVolume:=(r.BP=1);
    end;

  function SetTempo(Tempo,TimeNum,TimeDen :integer) :boolean;
    var
      TD,TN,TP :integer; {To put variables values in proper order in memory}
      r        :registers;
    begin
      TD:=TimeDen;
      TN:=TimeNum;
      TP:=Tempo;

      r.SI:=9;
      r.ES:=Seg(TP);
      r.BX:=Ofs(TP);

      Intr(101,r);

      SetTempo:=(r.BP=1);
    end;

  procedure SetActVoice(Voice :word);
    var
      r :registers;
    begin
      GActVoice:=Voice;

      r.SI:=12;
      r.ES:=Seg(Voice);
      r.BX:=Ofs(Voice);

      Intr(101,r);
    end;

  function PlayNoteDel(Pitch :integer; LengthNum,LengthDen,DelayNum,DelayDen
:word) :    var
      DD,DN,LD,LN :word;
      P           :integer;
      r           :registers;
    begin
      P:=Pitch;
      LD:=LengthDen;
      LN:=LengthNum;
      DN:=DelayNum;
      DD:=DelayDen;

      r.SI:=14;
      r.ES:=Seg(P);
      r.BX:=Ofs(P);

      Intr(101,r);

      PlayNoteDel:=(r.BP=1);
    end;

  function PlayNote(Pitch :integer; LengthNum,LengthDen :word) :boolean;
    var
      LD,LN :word;
      P     :integer;
      r     :registers;
    begin
      P:=Pitch;
      LD:=LengthDen;
      LN:=LengthNum;

      r.SI:=15;
      r.ES:=Seg(P);
      r.BX:=Ofs(P);

      Intr(101,r);

      PlayNote:=(r.BP=1);
    end;

  function SetTimbre(TimeNum,TimeDen :word) :boolean;
    var
      TD,TN :word;
      T     :^integer;
      c1,c2 :byte;
      r     :registers;
    begin
      T:=Addr(GT[GActVoice]);
      TN:=TimeNum;
      TD:=TimeDen;

      r.SI:=16;
      r.ES:=Seg(T);
      r.BX:=Ofs(T);

      Intr(101,r);

      SetTimbre:=(r.BP=1);
    end;

  function SetPitch(DeltaOctave,DeltaNum,DeltaDen :integer; TimeNum,TimeDen
:word) :b    var
      TD,TN   :word;
      DD,DN,D :integer;
      c1,c2   :byte;
      r       :registers;
    begin
      D:=DeltaOctave;
      DN:=DeltaNum;
      DD:=DeltaDen;
      TN:=TimeNum;
      TD:=TimeDen;

      r.SI:=16;
      r.ES:=Seg(D);
      r.BX:=Ofs(D);

      Intr(101,r);

      SetPitch:=(r.BP=1);
    end;

  procedure SetTickBeat(TickBeat :integer);
    var
      r :registers;
    begin
      r.SI:=18;
      r.ES:=Seg(TickBeat);
      r.BX:=Ofs(TickBeat);

      Intr(101,r);
    end;

  procedure DirectNoteOn(Voice :word; Pitch :integer);
    var
      P :integer;
      V :word;
      r :registers;
    begin
      P:=Pitch;
      V:=Voice;

      r.SI:=19;
      r.ES:=Seg(V);
      r.BX:=Ofs(V);

      Intr(101,r);
    end;

  procedure DirectNoteOff(Voice :word);
    var
      r :registers;
    begin
      r.SI:=20;
      r.ES:=Seg(Voice);
      r.BX:=Ofs(Voice);

      Intr(101,r);
    end;

  procedure DirectTimbre;
    var
      T     :^integer;
      V     :word;
      r     :registers;
    begin
      V:=GActVoice;
      T:=Addr(GT[V]);

      r.SI:=21;
      r.ES:=Seg(V);
      r.BX:=Ofs(V);

      Intr(101,r);
    end;

  procedure LoadInstrument(FileSpec :string);
    {Load an Instument from Disk and Place in Array}
    var
      c1 :byte;
      n  :integer;
      f  :file of integer;
    begin
      if not(Exist(FileSpec)) then FileSpec:='C:\MUSIC\PIANO1.INS';
      Assign(f,FileSpec);
      Reset(f);
      Read(f,n);
      for c1:=1 to 26 do
        Read(f,GT[GActVoice,c1]);
      Close(f);
    end;

  function LoadSong;
    {Read a .ROL file and place song in Buffer}
    var
      nb :byte;
      ns :string[255];
      ni,ni2,ni3,ni4,BPM :integer;
      c1,c2  :word;
      nr,nr2 :real;
      fl :boolean;
      f  :file;
    procedure StringRead(len :word); {uses f,ns}
      var
        nc :char;
        c1 :word;
      begin
        ns:='';
        for c1:=1 to len do
          begin
            BlockRead(f,nc,1);
            ns:=ConCat(ns,nc);
          end;
      end;
    procedure TempoRead; {uses f,nb}
      var
        b1,b2,b3,b4 :byte;
      begin
        BlockRead(f,b1,1);
        BlockRead(f,b2,1);
        BlockRead(f,b3,1);
        BlockRead(f,b4,1);
        nb:=(b3{ div 2});
      end;
    procedure VolumeRead;
      var
        b1,b2,b3,b4 :byte;
      begin
        BlockRead(f,b1,1);
        BlockRead(f,b2,1);
        BlockRead(f,b3,1);
        BlockRead(f,b4,1);
        nb:=51+Round(b3/2.5);
      end;
    begin
      LoadSong:=true;
      if not(Exist(FileSpec))
        then begin
               LoadSong:=false;
               Exit;
             end;

      InitDriver;
      RelTimeStart(0,1);
      Assign(f,FileSpec);
      Reset(f,1);
      StringRead(44);
      BlockRead(f,ni,2); SetTickBeat(ni); {Ticks per Beat}
      BlockRead(f,ni,2); BPM:=ni; {Beats per Measure}
      StringRead(5);
      BlockRead(f,nb,1); SetMode(1); {Mode}
      StringRead(143);
      TempoRead; fl:=SetTempo(nb,0,1); {Tempo}
      BlockRead(f,ni,2);
      for c1:=1 to ni do
        begin
          BlockRead(f,ni2,2);
          TempoRead; fl:=SetTempo(nb,ni2,1); {Tempo}
        end;
      for c1:=0 to 10 do {11 Voices}
        begin
          SetActVoice(c1);
          StringRead(15);
          BlockRead(f,ni2,2); {Time in ticks of last Note}
          c2:=0;
          while (c2<ni2) do
            begin
              BlockRead(f,ni3,2); {Note Pitch}
              BlockRead(f,ni4,2); {Note Duration}
              fl:=PlayNote(ni3-60,ni4,BPM); {Note}
              c2:=c2+ni4; {Summation of Durations}
            end;
          StringRead(15);
          BlockRead(f,ni2,2);
          for c2:=1 to ni2 do {Instuments}
            begin
              BlockRead(f,ni3,2);
              StringRead(9);
              nb:=Pos(#0,ns);
              Delete(ns,nb,Length(ns));
              LoadInstrument(ConCat('C:\MUSIC\',ns,'.INS'));
              fl:=SetTimbre(ni3,1);
              StringRead(1);
              BlockRead(f,ni4,2);
            end;
          StringRead(15);
          BlockRead(f,ni2,2);
          nb:=1;
          for c2:=1 to ni2 do {Volume}
            begin
              BlockRead(f,ni3,2);
              fl:=SetVolume(100,nb,ni3,1); {Use inverse to disable Relative}
              VolumeRead;
              fl:=SetVolume(nb,100,ni3,1);
            end;
          StringRead(15);
          BlockRead(f,ni2,2);
          for c2:=1 to ni2 do {Pitch -disabled}
            begin
              BlockRead(f,ni3,2);
              BlockRead(f,nr,4);
              if (nr=0) then nr2:=1 else nr2:=nr;
{             fl:=SetPitch(0,Abs(Trunc(nr*100)),Trunc((nr/nr2)*100),ni3,1);}
            end;
        end;
      Close(f);
    end;

end.

