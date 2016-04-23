{
*****************************************************************************

				  COLOR.PAS

 By Tobin Fricke

 This should solve everyone's problems with Ascii, ANSI, WWIV, Avatar, LVI,
 Pipe, Direct, and RIP.


*****************************************************************************
}
{$IFDEF DEBUG}
{$D+,L+}
{$ENDIF}

Unit Color;

{$S-}

(* BBS Color Unit by Tobin Fricke                                          *)
(* TobinTech Software Research and Development                             *)
(* Copyright (c) 1994 Tobin Fricke, All Rights Reserved                    *)

(* This is a unit to allow the use of color on bbs systems.  It will send  *)
(* the color codes to the screen using BIOS.  These can easily be trapped  *)
(* and sent to the modem by most BBS systems.                              *)


(* -=- If you use this in any of your programs, you must give credit to the
       author of this toolkit, Tobin Fricke.  You must register this and 
       receive permission to use it in any commercial product or shareware
       product.  It may be used without consent from the author (as long as
       credit is given) in any "freeware" or "public domain" programs. This
       may not be bought or sold, and contains no warrantee.  Use it at your
       own risk.  Please send the author a copy of anything you create using
       this toolkit.  Thanks.  For information on registration, contact the
       author. *)

(* -=- Reaching The Author                                                 
     
       Internet:        dr261@cleveland.freenet.edu


       Postal:          25271 Arion Way, Mission Viejo, Ca, 92691-3702

	
       Phone:           (714) 586-4906

       
       BBS:             (714) 586-6142 The Digital Forest Information system


       DFIN:            13:714/100

	*)
	
	

Interface

uses DOS;

Type ProcType=Procedure(S:String);

Const NoColor=0;              { Ignores Color commands, no color         }
      ASCIIColor=0;           { Same as NoColor                          }
      ANSIColor=1;            { Uses ANSI Escape Codes                   }
      WWIVColor=2;            { Uses WWIV Heart  Codes                   }
      AVATARColor=3;          { Uses AVATAR codes                        }
      LVIColor=4;             { Uses LVI (Last Video Interface)  codes   }
      DirectColor=7;
      PipeSystemColor=5;      { The Renegade Pipe System for Color       }
      RipColor=6;

      WWIVEscape:Char=#3;     { These are escape codes for the different }
      ANSIEscape:Char=#27;    { modes.                                   }
      AVATEscape:Char=#22;

      Black=0;                { These are color constants.               }
      Blue=1;
      Green=2;
      Cyan=3;
      Red=4;
      Magenta=5;
      Brown=6;
      Gray=7;
      Bright=8;

      EmuNum=6;
      EmuMenu:Array[0..EmuNum] of String=
       ('ASCII ',
	'ANSI  ',
	'WWIV  ',
	'AVATAR',
	'LVI   ',
	'PIPE System',
	'RIPScrip');
      EmuComment:Array[0..EmuNum] of String=
      ('No Color or Screen Control',
       'ANSI Color and Screen Control',
       'WWIV BBS Software "Heart Codes"',
       'This isn''t used much anymore',
       'The Last Video Interface, Faster than ANSI',
       'Renegade Style Color Codes',
       'Remote Imaging Protocol Script');

var WriteMode:Byte;           { Prior to use, you must set WriteMode equal }
    Output:ProcType;          { to NoColor, ANSIcolor, AVATARColor, or LVI-}
			      { color }

Var T:Text;                   {Assigned to StdOutput }


Procedure Default;                  { Change colors to default (7 on 0) }
Procedure BackgroundColor(I:Byte);  { Set Background color to I         }
Procedure ForgroundColor(I:Byte);   { Set Foreground Color to I         }
Procedure GotoXY(X,Y:Byte);         { Go to specific location on screen }
Procedure CLRSCR;                   { Clear the screen                  }
function readkey:char;              { Not Implemented Yet               }
Procedure D;                        { Same as Default;                  }
Procedure WWIVParse(S:String);      { See the end of this file...       }
Procedure GetEmu;                   { See the end of this file...       }
Procedure FColor(B:Byte);           { Same as ForegroundColor           }
Procedure BColor(B:Byte);           { Same as BackgroundColor           }

Implementation

Uses CRT;




Procedure DefOutput(S:StrinG);
Begin
 Write(T,S);
End;

{function readkey:char;
var B:Byte;
begin
 ASM;
  Mov AH, 01h
  Int 21
  Mov [B], AL
 End;
 readkey:=chr(B);
end; }
function readkey:char;
var it:string;
    Regs:Registers;
begin
Regs.AH:=$01;
MSDOS(Regs);
STr(Regs.AL,it);
readkey:=it[1];
end;

Procedure PIPEBackground(B:Byte);
Var S:String;
Begin
 Case B Of
   0: S:='|16';
   1: S:='|17';
   2: S:='|18';
   3: S:='|19';
   4: S:='|20';
   5: S:='|21';
   6: S:='|22';
   7: S:='|23';
  End;
 Write(S);
End;

Procedure PIPEForground(B:Byte);
Var S:String;
Begin
 Case B Of
   0: S:='|00';
   1: S:='|01';
   2: S:='|02';
   3: S:='|03';
   4: S:='|04';
   5: S:='|05';
   6: S:='|06';
   7: S:='|07';
   8: S:='|08';
   9: S:='|09';
  10: S:='|10';
  11: S:='|11';
  12: S:='|12';
  13: S:='|13';
  14: S:='|14';
  15: S:='|15';
  End;
 Write(S);
End;


Procedure AVATARGotoXy(X,Y:Byte);
begin
 Write(#22+#8+Char(X)+Char(Y));
end;

Procedure AvatarForground(A:Byte);
begin
 Write(#22+#1+Char(A and $7F));
end;

Procedure AvatarClrScr;
begin
 Write(#12);
end;

Procedure WWIVForground(I:Byte);
var C:Byte;
    D:Char;
begin
 Repeat
  If I>8 then I:=I-8;
 Until I<9;
 C:=I;
 Case I of
    0:C:=0;
    1:C:=7;
    2:C:=5;
    3:C:=1;
    4:C:=6;
    5:C:=3;
    6:C:=2;
    7:C:=4;
    8:C:=4;
  end;
  Output(WWIVEscape+Char(48+C));
end;

Procedure WWIVBackground(I:Byte);
begin
 If I=1 then Output(WWIVEscape+'4');
end;

procedure ANSIDefault;
begin
 Output(ANSIEscape+'[0m');
end;

Procedure ANSIForground(I:Byte);
var z:string;
begin
{ANSIDefault;}
case I of
     0:z:='0;30';
     1:z:='0;34';
     2:z:='0;32';
     3:z:='0;36';
     4:z:='0;31';
     5:z:='0;35';
     6:z:='0;33';
     7:z:='0;37';
     8:z:='1;30';
     9:z:='1;34';
     10:z:='1;32';
     11:z:='1;36';
     12:z:='1;31';
     13:z:='1;35';
     14:z:='1;33';
     15:z:='1;37';
     end;
Output(ANSIescape+'['+z+'m');
end;

Procedure ANSIBackground(I:Byte);
var z:string;
    ansistr:string;
begin
{ ANSIDefault;}
 case I of
      0:z:='40';
      1:z:='44';
      2:z:='42';
      3:z:='46';
      4:z:='41';
      5:z:='45';
      6:z:='43';
      7:z:='47';
      end;
ansistr:=ANSIEscape+'['+z+'m';
Output(ansistr);
end;

Procedure GotoXY(X,Y:Byte);
var SX,SY:string;
begin
Str(X,SX);
Str(Y,SY);
Output(ANSIEscape+'['+SY+';'+SX+'H');
end;

Var F,B:Byte;

Procedure LVIForground(I:Byte);
Begin
 F:=I;
 Output(#29+Char(F+(B*16)));
end;

Procedure LVIBackground(I:Byte);
Begin
 B:=I;
 Output(#29+Char(F+(B*16)));
end;

Procedure Zero(Var X:Byte);
Begin
 X:=0;
end;

Procedure FColor(B:Byte);
Begin
 ForgroundColor(B);
end;

Procedure BColor(B:Byte);
Begin
 BackgroundColor(B);
End;

Procedure WWIVParse(S:String);
var I:Byte;
begin
 Zero(I);
 Repeat
  Inc(I);
  Case S[I] of
    #3:Begin            { #3 =  }
	Inc(I);
	Case S[I] of
	   '0':Begin BColor(0); FColor(7+0);  End;
	   '1':Begin BColor(0); FColor(3+8); End;
	   '2':Begin BColor(0); FColor(6+8); End;
	   '3':Begin BColor(0); FColor(5+0); End;
	   '4':Begin BColor(1); FColor(1+0); End;
	   '5':Begin BColor(0); FColor(2+0); End;
	   '6':Begin BColor(0); FColor(4+8); End;
	   '7':Begin BColor(0); FColor(1+8); End;
	   '8':Begin BColor(0); FColor(2+8); End;
	   '9':Begin BColor(0); FColor(3+8); End;
	  End;
	End;
    Else Output(S[I]);
  End;
 Until I>=Length(S);
End;

Procedure BackgroundColor(I:Byte);
begin
 Case WriteMode of
   ANSIColor:ANSIBackground(I);
   RIPColor:ANSIBackground(I);
   WWIVColor:WWIVBackground(I);
   LVIColor:LVIBackground(I);
   DirectColor:CRT.TextBackground(I);
   PipeSystemColor:PipeBackground(I);
   end;
end;

Procedure ForgroundColor(I:Byte);
begin
 Case WriteMode of
   ANSIColor:ANSIForground(I);
   RIPColor:ANSIForground(I);
   WWIVColor:WWIVForground(I);
   AVATARColor:AvatarForground(I);
   LVIColor:LVIForground(I);
   DirectColor:CRT.TextColor(I);
   PipeSystemColor:PipeForground(I);
   end;
end;

Procedure ANSIClrScr;
begin
Output(ANSIEscape+'[2J');
end;

Procedure WWIVClrScr;
var I:Byte;
begin
  For I:=1 to 25 do Writeln(T,'');
end;

Procedure ClrScr;
begin
 Case WriteMode of
    ANSIColor:ANSIClrScr;
    RIPColor:ANSIClrScr;
    WWIVColor:WWIVClrScr;
    AVATARColor:AvatarClrScr;
    LVIColor:ANSIClrScr;
    DirectColor:CRT.ClrScr;
    end;
end;

Procedure Default;
Begin
 Case Writemode of
  ANSIColor: ANSIDefault;
  RipColor:  ANSIDefault;
  end;
end;

Procedure D;
begin
 Default;
end;

Procedure GetEMu;
Var I,E:Integer;
    S:String;
    T:Integer;
Begin
Repeat
 Writeln(' Please choose a terminal type: ');
 Writeln;
 For I:=0 to Color.EmuNum do
     Writeln(' ',I,') ',Color.EmuMenu[I],#9,Color.EmuComment[I]);
 Writeln;
 Write(' TERM>');
 Readln(S);
 Val(S,T,E);
 If E<>0 then begin
    Writeln(' I can''t understand: ',S);
    Write('                    ');
    For I:=1 to E do Write(' ');
    Writeln('^');
    End;
 If ((T>Color.EmuNum) OR (T<0)) AND (E=0) then begin
    Writeln(' You must enter a number from 0 to ',EmuNum);
    E:=1;
    end;
Until E=0;
Writeln;
Writeln(' ',EmuMenu[T],' Emulation Selected ');
WriteMode:=T;
end;


begin
 Output:=DefOutput;
 Assign(System.Output,'');
 Assign(System.Input,'');
 Assign(T,'');
 Rewrite(T);
 Rewrite(System.Output);
 Reset(Input);
 DirectVideo:=False;
 WriteMode:=ANSIColor;
 F:=7;
 B:=0;
end.

(*  Information...



      Set WriteMode to one of the following before calling any color commands.


      NoColor=0;              { Ignores Color commands, no color         }
      ASCIIColor=0;           { Same as NoColor                          }
      ANSIColor=1;            { Uses ANSI Escape Codes                   }
      WWIVColor=2;            { Uses WWIV Heart  Codes                   }
      AVATARColor=3;          { Uses AVATAR codes                        }
      LVIColor=4;             { Uses LVI (Last Video Interface)  codes   }
      DirectColor=7;          { Not implemented yet  }
      PipeSystemColor=5;      { The Renegade Pipe System for Color       }
      RipColor=6;


      For TTY emulation, see TTY.PAS
      For LVI emulation, see LVI.PAS


      Output(S:String) Is called to output the ANSI/WWIV/AVATAR/LVI/PIPE/RIP
      codes.  It defaults to StdOutput, and It may be redefined like so:


      Procedure COMOutput(S:String);
      begin
       { send S to COMPort }

      end;


      begin
       Color.Output:=ComOutput;
      end.


      WWIVParse(S:String) will take a string containing WWIV (ASCII 3) color
      codes, parse it, and output it (through procedure output) with the 
      correct coloring.


      GetEmu will display a menu and ask the user for an emulation.
*)
