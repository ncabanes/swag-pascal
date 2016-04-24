(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0020.PAS
  Description: 25/43/50 -no blank!
  Author: IAN HINSON
  Date: 02-05-94  07:56
*)


{
 Does anyone have a routine, or more, that will change video mode, 25
 to 43/50 lines, or back WITHOUT clearing the screen as TextMode does?
 I "hate" that <g>, I know OpCrt is supposed to do that, but I cannot
 use OpCrt in this program without doing MAJOR changes to about 20
 other units that use Tp.Crt. I will, but later, fix that, but for now
 could use a routine of this nature.... }


PROCEDURE SwitchTo43&50; ASSEMBLER;
ASM
   MOV AX,$1112
   INT $10
END;

PROCEDURE SwitchTo25; ASSEMBLER;
ASM
   MOV AX,$1114
   INT $10
END;

