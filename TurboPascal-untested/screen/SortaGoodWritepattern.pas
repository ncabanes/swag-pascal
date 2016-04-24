(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0081.PAS
  Description: Sorta good WritePattern
  Author: STERLING BATES
  Date: 02-28-95  10:12
*)


Procedure WriteP (DispStr : String; X,Y,Colr : Byte; FChar : Char;
                  Patrn : String);

               (* DispStr   = non-formatted string to be output to the screen.
                              ie: pass '4031234567', not '(403) 123-4567'.
                  X,Y       = location to begin writing string to screen.  If
                              the pattern begins with an 'X', this WILL be
                              taken into account and will advance one space.
                  Colr      = attribute of DispStr.
                  FChar     = Filler character for strings that don't complete
                              the pattern.
                  Patrn     = Template for writing string to screen.
                              Essentially, the only character required in this
                              template is the 'X', to show where a character
                              is NOT displayed.
               *)

  (* This procedure will write DispStr to the screen, following the guidelines
     given in Patrn.  For example, calling

           WriteP ('40312345',10,11,7,'_','X###XX###X####');

     will display:

            403  123 45__
           ^advancing space

     on the screen.  Of course, the '(   )    -' would make it complete, but
     that's just an example.
  *)

  (* Standard disclaimer: I'm not liable for anything this procedure does
                          outside the original purpose of the procedure.  If
                          something bad happens, let me know, but that's all
                          I can do.
  *)

Var
   Loc, PX                              : Integer;

Begin
     Colr := CheckColor (Colr);
     Loc := ((X-1)*2)+((Y-1)*160);
     Loop := 1;
     PX := 1;
     While PX <= Length (Patrn) Do
     Begin
          If Patrn[PX] = 'X' Then
             While Patrn[PX] = 'X' Do
             Begin
                  Inc (Loc,2);
                  Inc (PX);
             End
          Else
          Begin
               If Loop <= Length (DispStr) Then
               Begin
                    Mem[VidSeg:Loc] := Ord (DispStr[Loop]);
                    Mem[VidSeg:Loc+1] := Colr;
               End
               Else
               Begin
                    Mem[VidSeg:Loc] := Ord (FChar);
                    Mem[VidSeg:Loc+1] := HiColr;
               End;
               Inc (Loop);
               Inc (Loc,2);
               Inc (PX);
          End;
     End;
End;

