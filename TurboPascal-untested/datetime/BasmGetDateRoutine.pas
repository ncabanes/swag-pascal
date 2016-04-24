(*
  Category: SWAG Title: DATE & TIME ROUTINES
  Original name: 0031.PAS
  Description: BASM Get Date Routine
  Author: LIAM STITT
  Date: 11-26-93  17:01
*)

{
From: LIAM STITT
Subj: BASM Get Date
}

  type
    DateInfo = record
      Year: Word;
      Month: Byte;
      Day: Byte;
      DOW: Byte;
   end;

  var
    DI: DateInfo;

  procedure GetDate; assembler;
  asm
    mov ah,2Ah
    int 21h
    mov DI.Year,cx
    mov DI.Month,dh
    mov DI.Day,dl
    mov DI.DOW,al
  end;


