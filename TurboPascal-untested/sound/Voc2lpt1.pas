(*
  Category: SWAG Title: SOUNDBLASTER/ADLIB/SPEAKER ROUTINES
  Original name: 0012.PAS
  Description: VOC2LPT1.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:57
*)

{
    This is a Program to export a VOC or other Raw Sound File to a Parallel
port DAC.. (only For LPT1 now, but i think you can make it work on LPT2 by
changing the 'PORT[$0378]' to 'PORT[$0388]'...

 I know, This is a Real mess For figuring it out... I originally had no
intention of posting it, but I believe in free access to info, so here it is!
If you have any questions about it, just ask... and if you figure out where
that bug is (you'll know what I mean, it only plays PART of the VOC) I'd
appreciate input.
}

{This Program Assumes you have a DAC on LPT1}
{$M 65520,0,300000}          {only use memory that is needed}
Program Voc_Play;
Uses
  Crt;

Procedure Wait(N : Word);        {Very Crude wait routine}
Var
  counter : Word;
begin
  For Counter:= 1 to N do;
end;

Type Ra = Array[0..0] of Byte;

Var
  I2   : ^Ra;
  spd  : Integer;
  res  : Word;
  siz  : LongInt;
  B    : Word;
  s    : String;
  f1   : File of Byte;
  F    : File;

begin
  Write('Enter Voc Filename: ');
  readln(S);
                             {Get Size of File}
  Assign(f1,s);
  Reset(f1);
  spd:=30;                   {this is the play speed}
  siz := FileSize(f1);
  close(f1);
                              {Load up Voc File}
  Assign(f,s);
  Reset(f);
  getmem(I2,siz);               {Allocate Memory For VOC File}
  BlockRead(f,I2^,siz,res);     {Load VOC into Memory)
  Writeln('FileSize = ',siz);   {Testing Point, not needed}

  Repeat                      {This is the actual Play routine}      begin
    For b:=0 to siz do
    begin
      Wait(spd);            {Wait a bit}
      Port[$0378]:=I2^[b];  {Put Byte to DAC}
    end;
  end Until KeyPressed;

end.


