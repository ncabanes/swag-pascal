(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0020.PAS
  Description: Lightbar Menu - Update
  Author: RODRIGO M. SILVEIRA
  Date: 01-02-98  07:35
*)

(*
  Some people asked me about a new version of light_bar Here it is, enjoy it!

  This is a simple LIGHTBAR example.
  You can change and distribute it freely.
  Any doubt, bug or suggestion
  please, E-Mail me at:

  arlindo@solar.com.br

  Or write me:

  SQS 113 Bl "G" Apto 102
  Brazil - Brasília - DF
  Cep: 70.376-070

  Written By ZεU$ - Rodrigo M. Silveira - Brazil -  Brasilia
*)

Program Light_bar;

uses crt;

const { Constants }
  colort = 1; { Bacground color of tagged entries }
  sc = 'CoDeD By G0D ZEU$'; { The Little Scrooler }

var { Variables }
  Local    : Array[1..4] of String; { The Option variable }
  Desc     : Array[1..4] of String; { The Descriptions }
  by       : Byte; { Needed to to a for loop }

Function LightBar(n:Byte;var lo,De:Array of String):Byte;
{ n = Number of options, Lo = Option string, De = Description String }
{ It will return the Number of option selected                       }
var
  k      : char;
  b,c,i  : byte;
  ii     : Boolean;

  Procedure scr; { The little scrooler procedure }
  begin
    inc(i);
    TextAttr:=$0F; { Set Background to 0 and TextColor to 15 = $F }
    if i = 80-length(sc) then ii := true;
    if ii Then i := i-2;
    if i = 1 then ii := false;
    gotoxy(i,1);
    write(sc);
    while (port[$3da] and 8)<>0 do; { retrace, better than a delay ! }
    while (port[$3da] and 8)=0 do;  { We can Read the Scrool easily  }
    Fillchar(MEM[$B800:0],160,0);
  end;

  Procedure start; { Writes all the options with 1 tagged }
  begin
    TextAttr:=$0F;
    for by := 1 to n-1 do
    begin
      gotoxy((80-Length(lo[by])) div 2,((25-n) div 2)+by+1);
      {      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Centralize}
      write(lo[by]);
    end;
    TextAttr:=$1F;
    gotoxy((80-Length(lo[0])) div 2,((25-n) div 2)+1);
    write(lo[0]);
    gotoxy(1,25); clreol;
    gotoxy((80-length(De[0])) div 2,25);
    write(de[0]);
  end;

  Procedure St; { tag new option and untag the old }
  begin
    if b<254 Then Begin
      { var c = Old Tagged; b = New tagged }
      gotoxy((80-Length(lo[c-1])) div 2,((25-n) div 2)+c);
      textbackground(0);
      write(lo[c-1]);
      gotoxy((80-Length(lo[b-1])) div 2,((25-n) div 2)+b);
      textbackground(colort);
      write(lo[b-1]);
      gotoxy(1,25); clreol;
      gotoxy((80-length(De[b-1])) div 2,25);
      write(de[b-1]);
    end;
  end;

  procedure re; { Procedure to get the key and explore it... }
  begin
    b := 1;
    i := 1;
    ii := false;
    repeat
      repeat
        repeat
          scr; { No key pressed? let's Scrool until keypressed }
        until keypressed;
        k := upcase(readkey);
      until k in [#72,#75,#80,#77,#27,#13,'A','Z','Q']; { Bad key? BACK! }
      c := b; { Save old option }
      case k of
        #72,#75,'A' : dec(b); { UP }
        #80,#77,'Z' : inc(b); { DOWN }
        #27,'Q' : b := 255;   { ESC }
        #13 : b := 254;       { ENTER }
      end;
      if b = n+1 then b := 1; { it's beyond the limit, go back to 1 }
      if b = 0 then b := n;   { Got an zero, go to the end }
      if b = 254 Then         { HEI! WE GOT THE OPTION! }
      Begin
        Lightbar:=c;          { Tell the function that we found it }
        b:=255;               { Exit code }
      end;
      st;
    until b = 255;
  end;

{Main par of function lightbar }
begin
  start;
  re;
end;

var ab:byte;

Begin { Start of the program }
  Asm mov ax,$3;int $10;mov ax,$0100;mov cx,$2607;int $10;end;
  { Start text mode 80x40 and Hide cursor }
  TextAttr:=$0F; { set Background=0 Textcolor=15=($F) }
  { The Option Strings definition }
  Local[1]:='CoDeD By Rodrigo Silveira';
  Local[2]:='Sound';
  Local[3]:='About the function';
  Local[4]:='The Description of this option is written Down Here';
  { The Description Strings definition }
  Desc[1]:='arlindo@solar.com.br';
  Desc[2]:='This Text Describes what option sound will do';
  Desc[3]:='This function returns the number of the tagged line';
  Desc[4]:='Done 4U';
  ab := Lightbar(4,local,desc);
  TEXTATTR:=$07;
  Asm mov ax,$3;int $10;end;
  Write('Option ',ab,' Selected');
end.
{ Written By ZεU$ - Rodrigo M. Silveira - Brasil - Brasilia }
