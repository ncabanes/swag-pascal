(*
  Category: SWAG Title: GRAPHICS ROUTINES
  Original name: 0052.PAS
  Description: Graphics Images
  Author: JORDAN PHILLIPS
  Date: 01-27-94  12:09
*)

{
  Well, here are some image routines, I made it to where the WIDTH is stored
 in the first two bytes and the HEIGHT is stored in the 3rd and 4th bytes...
 If you must really know... I guess it goes along with TP's get/put image
 convention... This is for mode $13 ONLY of coarse...
}

  Procedure GetImage ( X1, Y1, X2, Y2 : Integer; VAR DEST ) ;
   Var Width,S,O : Word ;

    BEGIN
     S := SEG (DEST);
     O := OFS (DEST);

     ASM
      PUSH DS

      MOV DX, Video_Seg
      MOV DS, DX
      MOV BX, 320
      MOV AX, Y1; MUL BX
      ADD AX, X1; MOV SI, AX

      MOV DX, S
      MOV ES, DX
      MOV DI, O

      MOV DX, Y2; SUB DX, Y1; INC DX
      MOV BX, X2; SUB BX, X1; INC BX
      MOV WIDTH, BX

      MOV AX, WIDTH
      STOSW
      MOV AX, DX
      STOSW

     @LOOP:
      MOV CX, WIDTH
      REP MOVSB
      ADD SI, 320; SUB SI, WIDTH
      DEC DX
      JNZ @LOOP

      POP DS
     End ;
   End ;

  Procedure PutImage ( X1, Y1 : Integer; VAR SOURCE ) ;
   Var Width, S, O : Word ;
    BEGIN
     S := SEG (SOURCE);
     O := OFS (SOURCE);

     ASM
      PUSH DS

      MOV DX, Video_Seg
      MOV ES, DX
      MOV BX, 320            { Setup Dest Addr }
      MOV AX, Y1; MUL BX
      ADD AX, X1; MOV DI, AX

      MOV DX, S { Setup Source Addr }
      MOV DS, DX
      MOV SI, O

      LODSW   { Get Width and Height }
      MOV WIDTH, AX
      LODSW
      MOV DX, AX

     @LOOP:
      MOV CX, WIDTH
      REP MOVSB
      ADD DI, 320; SUB DI, WIDTH
      DEC DX
      JNZ @LOOP

      POP DS
     End ;
   End ;

  Function SaveImage ( X1, Y1, X2, Y2 : Integer ; VAR Size : Word ) : Pointer ;
   Var Img : Pointer ;
    Begin
     FixInt ( X1, X2 ) ; { Put lesser in X1 }
     FixInt ( Y1, Y2 ) ; { Put lesser in Y1 }
     Size := WORD((X2-X1+1)*(Y2-Y1+1) +4);
     GetMem ( Img, Size ) ;
     GetImage ( X1, Y1, X2, Y2, Img^ ) ;
     SaveImage := Img ;
    End ;

 Procedure CopyImage ( X1, Y1, X2, Y2, Dx, DY : Integer ) ;
  Var Img : Pointer ;
      Size : Word ;
   Begin
    Img := SaveImage ( X1, Y1, X2, Y2, Size ) ;
    PutImage ( Dx, Dy, Img^) ;
    FreeMem ( Img, Size ) ;
   End ;

 Procedure LoadImage ( FileName : String ; VAR Img : Pointer ; Var Size : Word
   Var F : File ;
  Begin
   Img := NIL ;
   Size := 0 ;
   If Not Exist ( FileName ) Then Exit ;
   Assign ( F, Filename ) ;
   Reset ( F, 1 ) ;
   Size := FileSize ( F ) ;
   GetMem ( Img, Size ) ;
   BlockRead ( F, Img^, Size ) ;
   Close ( F ) ;
  End ;

