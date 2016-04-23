
Procedure WriteS (DispStr : String; X,Y,Colr : Byte);

               (* DispStr = String to display on screen
                  X,Y     = Coordinates to being writing
                  Colr    = Color attribute
               *)

  (* This is a simple procedure to directly write a string to the screen,
     accounting for imbedded color codes.  These color codes are identified
     by a \ followed by a two or three digit number representing the color
     desired.  All subsequent output of the string will be given the new
     color until otherwise declared.  The string '\M' is also recognized as
     a carriage return, where the string will be continued on the next line,
     aligned with the above line.  No values are returned.

     It's fairly fast, and it does the job, but I know that it could use a
     lot of tweaking, so if anybody does improve on it, please give me an
     updated copy.

     ** NOTE **  The screen address is kept in the variable VidSeg.  You can
                 either go through the procedure and replace it with a constant
                 screen address, or assign the variable VidSeg in your program.
  *)

  (* Standard disclaimer: I'm not liable for anything this procedure does
                          outside the original purpose of the procedure.  If
                          something bad happens, let me know, but that's all
                          I can do.
  *)

Var
   Loc, TmpInt, OldX                    : Integer;
   TmpStr                               : String[3];

Begin
     OldX := X;
     Loc := ((X-1)*2)+((Y-1)*160);
     Loop := 1;
     While Loop <= Length (DispStr) Do
     Begin
          TmpStr := '';
          If (DispStr[Loop] = '\') And (DispStr[Loop+1] <> '\') Then
          Begin
               Inc (Loop);
               If DispStr[Loop] In ['0'..'9'] Then
               Begin
                    While (DispStr[Loop] In ['0'..'9']) And
                          (Length (TmpStr) < 3) Do
                    Begin
                         TmpStr := TmpStr + DispStr[Loop];
                         Inc (Loop);
                    End;
                    Val (TmpStr,Colr,TmpInt);
                    Colr := CheckColor (Colr);
               End
               Else
               If UpCase (DispStr[Loop]) = 'M' Then
               Begin
                    Inc (Y);
                    X := OldX;
                    Loc := ((X-1)*2)+((Y-1)*160);
               End;
          End
          Else
          Begin
               If DispStr[Loop] = '\' Then
                  Delete (DispStr,Loop,1);
               Mem[VidSeg:Loc] := Ord (DispStr[Loop]);
               Mem[VidSeg:Loc+1] := Colr;
               Inc (Loc,2);
               Inc (Loop);
          End;
     End;
End;
