(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0026.PAS
  Description: Encryption/Decryption
  Author: UNKNOWN
  Date: 05-31-96  09:16
*)

{
I give you a simple encrypting/decrypting algoritm (it's easy to decrypt

it with a descent program). }

Procedure Encrypt(Var Data; Length: Word; Key: Byte);

Var B: Byte;
    i: Word;

Begin

  For i := 0 to Length-1 do
    Begin
      B := Mem[Seg(Data):Ofs(Data)+i];
      B := 255 - (B + Key);
      Mem[Seg(Data):Ofs(Data)+i] := B;
     end; { For }

end;

If You like assembler:



Procedure Encrypt(Var Data; Length: Word; Key: Byte); ASSEMBLER;

ASM
  MOV  CX,Length
  DEC  CX
  MOV  BL,Key
  LES  DI,Data
@@Loop1:
  MOV  AL,BYTE PTR ES:[DI]
  MOV  BH,AL
  ADD  BH,BL
  MOV  AL,255
  SUB  AL,BH
  MOV  BYTE PTR ES:[DI],AL
  INC  DI
  LOOP @@Loop1
end;

Procedure Decrypt(Var Data; Length: Word; Key: Byte);

Var i: Word;
    B: Byte;

Begin

  For i := 0 to Length-1 do
    Begin
      B := Mem[Seg(Data):Ofs(Data)+i];
      B := 255 - B + Key;
      Mem[Seg(Data):Ofs(Data)+i];
    end;{ For }
end;

Or:

Procedure Decrypt(Var Data; Length: Word; Key: Byte); ASSEMBLER;
ASM
  MOV   CX,Length
  DEC   CX
  MOV   BL,Key
  LES   DI,Data
@@Loop1:
  MOV   AL,BYTE PTR ES:[DI]
  MOV   BH,AL
  ADD   BH,BL
  MOV   AL,255
  SUB   AL,BH
  MOV   BYTE PTR ES:[DI],AL
  INC   DI
  LOOP  @@Loop1
end;

{ Key in the procedure Encrypt and Decrypt should be the same. }


