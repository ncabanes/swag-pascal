(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0016.PAS
  Description: Get/Put Image functions
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{Here is a small Program that illustrates the features of GetImage/PutImage that
you would like to use:
}
 {$A+,B-,D+,E-,F-,G+,I-,L+,N-,O-,R-,S+,V-,X+}
 {$M 16384,0,655360}
 Uses Graph;
 (* Turbo Pascal, Width= 20 Height= 23 Colors= 16 *)
 Const
   Pac: Array[1..282] of Byte = (
          $13,$00,$16,$00,$00,$FE,$00,$00,$FE,$00,
          $00,$FE,$00,$FF,$01,$FF,$03,$FF,$80,$03,
          $FF,$80,$03,$FF,$80,$FC,$00,$7F,$07,$8F,
          $C0,$07,$8F,$C0,$07,$8F,$C0,$F8,$00,$3F,
          $1F,$77,$F0,$1F,$17,$F0,$1F,$17,$E0,$E0,
          $70,$0F,$1F,$77,$E0,$1F,$37,$E0,$1F,$37,
          $C0,$E0,$70,$1F,$3F,$77,$C0,$3F,$17,$C0,
          $3F,$17,$80,$C0,$70,$3F,$7F,$8F,$80,$7F,
          $8F,$80,$7F,$8F,$00,$80,$00,$7F,$7F,$FF,
          $00,$7F,$FF,$00,$7F,$FE,$00,$80,$00,$FF,
          $FF,$FE,$00,$FF,$FE,$00,$FF,$FC,$00,$00,
          $01,$FF,$FF,$FC,$00,$FF,$FC,$00,$FF,$F8,
          $00,$00,$03,$FF,$FF,$F8,$00,$FF,$F8,$00,
          $FF,$F0,$00,$00,$07,$FF,$FF,$F0,$00,$FF,
          $F0,$00,$FF,$E0,$00,$00,$0F,$FF,$FF,$F8,
          $00,$FF,$F8,$00,$FF,$F0,$00,$00,$07,$FF,
          $FF,$FC,$00,$FF,$FC,$00,$FF,$F8,$00,$00,
          $03,$FF,$FF,$FE,$00,$FF,$FE,$00,$FF,$FC,
          $00,$00,$01,$FF,$7F,$FF,$00,$7F,$FF,$00,
          $7F,$FE,$00,$80,$00,$FF,$7F,$FF,$80,$7F,
          $FF,$80,$7F,$FF,$00,$80,$00,$7F,$3F,$FF,
          $C0,$3F,$FF,$C0,$3F,$FF,$80,$C0,$00,$3F,
          $1F,$FF,$E0,$1F,$FF,$E0,$1F,$FF,$C0,$E0,
          $00,$1F,$1F,$FF,$F0,$1F,$FF,$F0,$1F,$FF,
          $E0,$E0,$00,$0F,$07,$FF,$C0,$07,$FF,$C0,
          $07,$FF,$C0,$F8,$00,$3F,$03,$FF,$80,$03,
          $FF,$80,$03,$FF,$80,$FC,$00,$7F,$00,$FE,
          $00,$00,$FE,$00,$00,$FE,$00,$FF,$01,$FF,
          $00,$00);
 Var Size,Result: Word;
     Gd, Gm: Integer;
     P: Pointer;
     F: File;
 begin
 { Find correct display/card-Type and initiallize stuff }
   Gd := Detect;
   InitGraph(Gd, Gm, 'd:\bp\bgi');
   if GraphResult <> grOk then Halt(1); { Error initialize }
   ClearDevice;

   SetFillStyle(SolidFill,Blue);
   Bar(0,0,639,479);
   P := @Pac;                                (* Pass the address of the   *)
                                             (* Pac Constant to a Pointer *)
   PutImage(1,1,P^,NormalPut);               (* Display image             *)

   Size := ImageSize(1,1,20,23) { Get size of your picture };
   GetMem(P, Size); { Get memory from heap }
   GetImage(1,1,20,23,P^) { Capture picture itself in P^ };

   ClearDevice;

   Assign(F,'IMAGE');
   reWrite(F,1);
   BlockWrite(F,P^,Size,Result) { Put picture (from P^) in File F };
   if Ioresult <> 0 then Halt(2) { Error during BlockWrite I/O };
   if Result <> Size then Halt(3) { not enough data written to F };
   close(F);
   if Ioresult <> 0 then Halt(4) { Error during Close of F };

   PutImage(1,1,P^,NormalPut);
   FreeMem(P,Size) { Free memory. This is GPP. };
   ReadLn { Hit any key to continue };
   ClearDevice;
   CloseGraph;
 end.

