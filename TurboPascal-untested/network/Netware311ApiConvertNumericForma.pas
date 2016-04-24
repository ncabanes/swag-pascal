(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0037.PAS
  Description: Netware 3.11 API - Convert Numeric forma
  Author: S.PEREVOZNIK
  Date: 11-29-96  08:17
*)

{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                 S.Perevoznik                     ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}
Unit NetConv;

{
 This is service unit.
 It's contains functions for convert numeric formats
}

Interface

Function Int2Long (B,C : word) : LongInt;

Procedure Long2Int(A: longint; var B,C : word);

Function GetWord(P: pointer): word;

Function GetLong(P: pointer): LongInt;

Implementation {-----------------------------------------------------------}

Procedure Long2Int(A: longint; var B,C: word); assembler;
asm
          PUSH ES
          PUSH SI
          LES  AX, A
          MOV  BX, ES
          LES  DI, B
          MOV  ES:[DI], BX
          LES  DI, C
          MOV  ES:[DI], AX
          POP  SI
          POP  ES
end;

Function Int2Long (B,C : word) : longint; assembler;
asm
          MOV AX, C
          MOV DX, B
end;


function GetWord(P: pointer): word; assembler;
asm
          PUSH ES
          LES  DI, P
          MOV  AX, word ptr ES:[DI]
          XCHG AH, AL
          POP  ES
end;

Function GetLong(p:Pointer) : LongInt; assembler;
asm
          PUSH ES
          LES  DI, P
          MOV  AX, word ptr ES:[DI+2]
          MOV  DX, word ptr ES:[DI]
          XCHG AH, AL
          XCHG DH, DL
          POP  ES
end;

end.

