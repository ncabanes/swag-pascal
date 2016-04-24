(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0022.PAS
  Description: cursor hiding
  Author: LOU DUCHEZ
  Date: 05-25-94  08:10
*)


var crstyp: word;

procedure cursoff;

{ Turns the cursor off.  Stores its format for later redisplaying. }

begin
  asm
    mov ah, 03h
    mov bh, 00h
    int 10h
    mov crstyp, cx
    mov ah, 01h
    mov cx, 65535
    int 10h
    end;
  end;

procedure curson;

{ Turns the cursor back on, using the cursor display previously stored. }

begin
  asm
    mov ah, 01h
    mov cx, crstyp
    int 10h
    end;
  end;


