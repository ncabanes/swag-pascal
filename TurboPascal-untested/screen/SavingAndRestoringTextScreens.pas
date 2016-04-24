(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0101.PAS
  Description: Saving and Restoring Text Screens
  Author: ANDREAS SCHLECHTE
  Date: 02-21-96  21:04
*)

{
In artice <DE6swr.6CK@postoffice.ptd.net>, NUKE@postoffice.ptd.net wrote:
 > How do I read text from the screen (ascii/ansi) so that I can put it back up
 > later (ex...to display a help menu then replace area where menu was with
 > original text)???    Thanks in advance.

Here it is:

TYPE TScreenBuffer = Array[1..20004] of Byte;
     PScreenBuffer = ^TScreenBuffer;
}

FUNCTION SBASE;
BEGIN
     Sbase:=SegB800;
     IF ScrMode  = 7 THEN sbase:=Segb000;
END;

FUNCTION StoreScrPart(X1,Y1,X2,Y2:Byte):PScreenBuffer;
VAR Hlp  : Word;
    I,J  : Integer;
    Sb   : Word;
    Buff : PScreenBuffer;
BEGIN
     hlp:=4+(((Y2-Y1)+1)*((X2-X1)+1))*2;
     IF ( MaxAvail> hlp ) THEN
     BEGIN
          Getmem(Buff,Hlp);
          Buff^[1]:=X1;
          Buff^[2]:=X2;
          Buff^[3]:=Y1;
          Buff^[4]:=Y2;
          Sb:=Sbase;
          For I := X1 to X2 do
              For J := Y1 to Y2 Do
                  Move(ptr(sb,(I-1)*2+(J-1)*160)^,Buff^[5+((I-X1)+(J-Y1)*(X2-X1+1))*2],2);
          StoreScrPart:=Buff;
     END
     ELSE StoreScrPart:=NIL;
END;

PROCEDURE RestoreScrPart(P:PScreenBuffer);
VAR Hlp         : Word;
    I,J         : Integer;
    x1,y1,x2,y2 : Byte;
    Sb          : Word;
BEGIN
     IF P = NIL THEN EXIT;
     x1:=P^[1];
     X2:=P^[2];
     Y1:=P^[3];
     Y2:=P^[4];
     Hlp:=4+(((Y2-Y1)+1)*((X2-X1)+1))*2;
     Sb:=SBase;
     For I := X1 to X2 do
         For J := Y1 to Y2 Do
             Move(P^[5+((I-X1)+(J-Y1)*(X2-X1+1))*2],Ptr(sb,(I-1)*2+(J-1)*160)^,2);
     FreeMem(P,hlp);
END;

FUNCTION ReadScr:PScreenBuffer;
BEGIN
     ReadScr:=StoreScrPart (1,1,AnzSpalten,AnzZeilen);
END;

PROCEDURE WriteScr(P:PScreenBuffer);
BEGIN
     RestoreScrPart(P);
END;


Now just use
  VAR P: PScreenBuffer;
  BEGIN
       P:=ReadScr;
       ....
       { write back : }
       WriteScr(P);
  END;

