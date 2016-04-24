(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0100.PAS
  Description: Convert a COM file to an INLINE
  Author: AVONTURE CHRISTOPHE
  Date: 11-29-96  08:17
*)

{
                  =======================================

                         INLINE (c) AVC Software
                               Cardware

                   Convert  a  COM file  into  an INLINE
                   instruction -or into a  binary array-

                  =======================================

   Convert a COM file into a Pascal Inline() Instruction.

   Be  carefull, the  COM  file must  don't  have the  end of  program code
   (Mov Ax, 4C00h  followed by Int 21h)



               ╔════════════════════════════════════════╗
               ║                                        ║░
               ║          AVONTURE CHRISTOPHE           ║░
               ║              AVC SOFTWARE              ║░
               ║     BOULEVARD EDMOND MACHTENS 157/53   ║░
               ║           B-1080 BRUXELLES             ║░
               ║              BELGIQUE                  ║░
               ║                                        ║░
               ╚════════════════════════════════════════╝░
               ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

}

Program Com2Inline;

Uses Crt;

Const
   Hexa : Array [0..15] of Char =
       ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

Var
   Ch1 , Ch2 : Byte;
   Ch3 , Ch4 : Byte;
   Ch        : Char;

Function Word2Hex(Number: Word) : String;
Begin

  Ch1 := (Number SHR 8) SHR 4;
  Ch2 := (Number SHR 8) - (Ch1 SHL 4);
  Ch3 := (Number AND $FF) SHR 4;
  Ch4 := (Number AND $FF) - (Ch3 SHL 4);

  Word2Hex := Hexa[Ch1]+Hexa[Ch2]+Hexa[Ch3]+Hexa[Ch4];

End;

Function Byte2Hex(Number: Byte) : String;
Begin

    Ch1 := Number SHR 4;
    Ch2 := Number - (Ch1 SHL 4);

    Byte2Hex := Hexa[Ch1]+Hexa[Ch2];

End;
Procedure Traitement;

Type Buf   = Array[0..65534] of Byte;


Var InFile        : File;
    OutFile       : Text;
    Buffer        : ^Buf;
    Param1, NomF  : String;
    I, J          : Word;
    Extension     : Boolean;
    NLus          : Integer;

Begin

   I := 0; J := 0; Extension := False;
   For i := 1 to Length (Param1) do
       If (Param1[i] = '.') then Begin
           Extension := True;
           J := I;
       End;
   If Not Extension then Param1 := Param1+'.COM'
   Else J := Length(Param1)+1;
   NomF   := Copy (Param1,1,Length(Param1)-3)+'INL';

   Assign  (InFile,Param1);
   Assign  (OutFile,NomF);
   Reset   (InFile,1);
   Rewrite (OutFile);

   New (Buffer);

   BlockRead (InFile, Buffer^, 65535, NLus);
   Close (InFile);

   Writeln (OutFile,'{Inline source for ',Param1,' created by AVONTURE Christophe }');
   Writeln (OutFile,'');

   If ParamCount = 1 then Write (OutFile,'Inline(')
   Else Begin
       Writeln (OutFile, 'const ',Copy (NomF, 1, Length(NomF)-4),
                ' : Array [1..',NLus,'] of byte = (');
       Write (OutFile,'       ');
   End;

   For I := 0 to NLus-1 do Begin
       If (I mod 17 = 16) then Begin
           Writeln (OutFile,'');
           Write (OutFile,'       ');
       End;
       If ParamCount = 1 then
          If Not (I = NLus-1) then Write (OutFile, '$',Byte2Hex(Buffer^[i]),'/')
          Else Write (OutFile, '$',Byte2Hex(Buffer^[i]))
       Else If Not (I = NLus-1) then Write (OutFile, '$',Byte2Hex(Buffer^[i]),',')
          Else Write (OutFile, '$',Byte2Hex(Buffer^[i]));
   End;

   Write (OutFile,');');
   Close (OutFile);

End;

Begin

   If ((ParamCount = 1) or (ParamCount = 2)) then Traitement
   Else Begin
       ClrScr;
       GotoXy (0, 2);
       Writeln ('');
       Writeln ('Inline by AVONTURE Christophe');
       Writeln ('-----------------------------');
       Writeln ('');
       Writeln ('You must specify the name of the COM file as parameter.');
       Writeln ('');
       Writeln ('    Inline Scancode.com or Inline Scancode');
       Writeln ('');
       Writeln ('A .INL file will be created.');
       Writeln ('');
       Writeln ('If you type only one parameter, then the result will be like');
       Writeln ('');
       Writeln ('    Inline ($E9/$F2/$00/$20/$20/ ..... ');
       Writeln ('');
       Writeln ('If you type a second parameter (anything), then the result will be like');
       Writeln ('');
       Writeln ('    Const SCANCODE : Array [1..364] of byte =  ');
       Writeln ('                     ($E9,$F2,$00,$20, ..... );');
       Writeln ('');
       Writeln ('');
       TextAttr := 15;
       Ch := ReadKey; If Ch = #0 then Ch := ReadKey;
   End;

End.

{ -------------------------------- cut here ------------------------------- }

{ Example program }

Uses Crt;

Begin

   Inline($EB/$01/$90/$B4/$01/$B5/$20/$CD/$10);           {Hide the cursor}

   Inline($B8/$03/$00/$CD/$10);                              {Clear screen}

   Writeln ('Demo of Inline code into a Pascal program :'#10#13#10#13);

   Writeln ('Press a key, the screen will be erased.');

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                      {ReadKey code}

   Inline($EB/$01/$90/$B4/$00/$B0/$03/$CD/$10);              {Clear screen}

   TextAttr := 158;

   Writeln ('These two function - ReadKey & ClrScr - has been coded Inline.'
      #10#13#10#13);

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                    {Wait for a key}

   Writeln ('This line is blinking.  You don't like that.  OK!'#10#13#10#13);

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                    {Wait for a key}


                       {Disable the text blinking; color attribut after 128}
   Inline($EB/$01/$90/$B4/$10/$B0/$03/$B3/$00/$CD/$10);

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                    {Wait for a key}

   Writeln ('Wow.  What a cool effect!  Isn''t it!'#10#13#10#13);

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                    {Wait for a key}

                                              {Restore the normal attribut}
   Inline($EB/$01/$90/$B4/$10/$B0/$03/$B3/$01/$CD/$10);

   Writeln ('Restore the normal attribut.'#10#13#10#13);

   Inline($EB/$01/$90/$B4/$07/$CD/$21);                    {Wait for a key}

End.

{ Severall Inline instruction based on some assembler program I have wrotte.

  When you want writte an assembler program for convert it into inline
  command, take the following model:

CSEG		Segment public
		Org	0100h

		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

Entry:		Jmp	Begin		; Entry Point

Begin:
                ; CODE HERE YOUR ASSEMBLER INSTRUCTION


; PLEASE READ: NEVER CODE A RET OR IRET INSTRUCTION!!!!!!

                Ret   <===  NO!!!!

CSeg	        Ends
	        End	 Entry


For example, the code for initialize the 80*25 video mode will be the
following:

CSEG		Segment public
		Org	0100h

		Assume	CS:CSEG, DS:CSEG, ES:CSEG, SS:CSEG

Entry:		Jmp	Begin		; Entry Point

Begin:          Mov  Ax, 0003h
                Int  10h

CSeg	        Ends
	        End	 Entry

You can compile this code into a COM file and then, launch the Inline program
for convert it into an Inline instruction. }

{Inline source for CEPARTI.COM created at 18:0:6 by AVC Software, Inc.}
{Make a sound with the speaker}

Inline($EB/$01/$90/$BA/$88/$13/$BB/$64/$00/$B0/$B6/$E6/$43/$8B/$C3/$E6/
       $42/$8A/$C4/$E6/$42/$E4/$61/$0C/$03/$E6/$61/$43/$B9/$90/$01/$E2/$FE/
       $4A/$75/$E9/$E4/$61/$24/$FC/$E6/$61/$BA/$88/$13/$BB/$EC/$13/$B0/$B6/
       $E6/$43/$8B/$C3/$E6/$42/$8A/$C4/$E6/$42/$E4/$61/$0C/$03/$E6/$61/$4B/
       $B9/$90/$01/$E2/$FE/$4A/$75/$E9/$E4/$61/$24/$FC/$E6/$61/$B8/$00/$4C/
       $CD/$21/$4D/$73/$44/$6F/$73);

{Inline source for CURSOFF.COM created at 14:34:48 by AVC Software, Inc.}
{Hide the cursor}

Inline($EB/$01/$90/$B4/$01/$B5/$20/$CD/$10);

{Inline source for CURSON.COM created at 14:34:54 by AVC Software, Inc.}
{Show the cursor}

Inline($EB/$01/$90/$B4/$01/$B1/$07/$B5/$06/$CD/$10);

{Inline source for INITMODE.COM created at 14:35:15 by AVC Software, Inc.}
{initialize a video mode}

Inline($B8/Mode/0/$CD/$10);

{Inline source for READKEY.COM created at 15:56:46 by AVC Software, Inc.}
{ReadKey}

Inline($EB/$01/$90/$B4/$07/$CD/$21);

{Inline source for RESETFON.COM created at 13:2:22 by AVC Software, Inc.}
{Restore the Ascii font}

Inline($EB/$01/$90/$B8/$04/$11/$B3/$00/$CD/$10/$B8/$04/$11/$B3/$01/$CD/
       $10);

{Inline source for TXTCLIF.COM created at 15:36:36 by AVC Software, Inc.}
{Disable the text blinking}

Inline($EB/$01/$90/$B4/$10/$B0/$03/$B3/$00/$CD/$10);

{Inline source for TXTCLIT.COM created at 15:36:44 by AVC Software, Inc.}
{Enable the text blinking}

Inline($EB/$01/$90/$B4/$10/$B0/$03/$B3/$01/$CD/$10);
