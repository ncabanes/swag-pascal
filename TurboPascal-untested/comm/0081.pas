{
This is a Unit for chat doors written in JsDoor, I've written my
own chat door, and I Really missed my old IceChat Tunes, So i've
Come up with a Note-By-Note Playing Routine for Icechat .ICE files..

This can be used Multi-Node, because it loads the file into memory..
Instead of reading it from disk..



Usage is easy, it's just

GETBANK('FILENAME.ICE');
and then just
PLAYNEXTNOTE;
as long as you want, it will only play one note at a time so you
can use it in a LOOP,  I use it to Display the moving Status Bar
while playing the note and watching for local/remote keys....


CJ Cliffe  *  Shareware Overload BBS  (613)382-1924 & (613)382-8503
              Voice:  (613)382-4194

  Please feel free to use this anywhere you want...
     As long as someone gets good use out of it i'm happy..        }


Unit PlayIce;   (* 1995 by CJ Cliffe *)
Interface
Uses Jsdoor,Jsmisc,Crt;

Procedure Getbank(filename: String);
Procedure PlayNextNote;


Implementation
Var
Counter : Integer;
Cbank   : Integer;
Soundbnk: Array [1..1500] of String[20];     {Loads To Memory for faster}
                                             {  or Multinode Operation  }


Function Str2Num(Convertme: String): LongInt;  {Cheap Way Of Converting}
Var
  Counting: Longint;                         {a Numeric String to an }
Begin
{        Integer        }
For Counting := 1 to 1000000 do
begin          { 1 Mil is High, But It }
If Convertme = Strfunc(Counting) then
begin    { Will Stop Long before }
  Str2Num := Counting;  {   It Gets that far,   }
Exit;                                          { Because of this
Exit; }
End;
End;
End;



Procedure Getbank(filename: String);

var fil  : Text;

Begin
Counter := 0;
{ Reset All Old Tones and Counter }
For Cbank := 1 to 1500 do begin
{            If Any               }
Soundbnk[cbank] := '';
end;
cbank := 0;
Assign(fil,filename);                  { Get Filname }
Reset(Fil);
Repeat
inc(cbank);
Readln(fil,soundbnk[cbank]);           { Load File Into Memory }
Until (cbank = 1500) or (EOF(fil));Close(fil);
End;


Procedure PlayNextNote;

var func     : String[4];     {Function WAIT, TONE or Comment}
    tone     : String[5];     {Tone In String Form}
    dura     : String[4];     {String Form Of Duration / 10}
    Temptone : String;        {Temporary Storage String}

Label Top;

Begin

Nosound;                           {Stop Sound }

Top:                               {Label for Non-Notes}

Inc(Counter);                      {Update Note}

If counter = cbank then counter := 1;    {Song Has Ended, Restart!}

Temptone := SoundBnk[Counter];     {Make a Temporary Copy of the Note}

Func := Temptone;                  {Get All The Values}
Tone := Copy(Temptone,5,5);        {Note Tone}
Dura := Copy(Temptone,10,5);       {Note Duration}

Func := Ltrim(Rtrim(Func));        {Strip Spaces For Number Conversion}
Tone := Ltrim(Rtrim(Tone));
Dura := Ltrim(Rtrim(Dura));


If Copy(Func,1,2) = ';' then Goto Top;    {Comment Found, Skip Note}

If Func = 'WAIT' then begin
{WAIT found, Stop Sound and wait} Nosound;
{      Stop Sound For Wait      } Delay(Str2Num(Tone)*10);
Exit;
End;

If Func = 'TONE' then begin         {Tone Found, Play Note and Wait for}
Sound(Str2Num(Tone));               {            Dura(tion)            }
Delay(Str2Num(Dura)*10);            {Dura is in  / 10 format, * 10 for }
NoSound;                            {            Normal Play           }
Exit;
End;
End;


Begin
End.


{ I'm Working on a keyboard for recording .ICE files,  Watch for it in this
 Echo...                                                                    }



{ -------------------------------------------------------------------------}

{ Example Usage Of PLAYICE.PAS }


{

Program IcePlay;
Uses PlayIce,Crt;


Begin
Clrscr;
Writeln('Playing Song, Any key to Stop');
GetBank('LARRY.ICE');
Repeat
PlayNextNote;
Until Keypressed;
End.


}
