{
   Here are two routines: one - encrypts, other - decrypts any data passed.
   They are very simple so if a real hacker will debug your program, he will
   the way the password is encrypted. However, for eye-protection it's really
}
USES Crt;

Procedure EncodeBuf(var Buffer; Count : word); assembler;
   { Encrypts Count bytes of data in a Buffer variable }
   Asm
     PUSH DS
     LDS SI,Buffer
     LES DI,Buffer
     CLD
     MOV CX,Count
     OR  CX,0
     JZ  @@2
   @@1:
     LODSB
     XOR AL,2
     ROR AL,1
     NOT AL
     STOSB
     LOOP @@1
   @@2:
     POP DS
   End; { EncodeBuf }

Procedure DecodeBuf(var Buffer; Count : word); assembler;
   { Decrypts Count bytes of data from a Buffer variable }
   Asm
     PUSH DS
     LDS SI,Buffer
     LES DI,Buffer
     CLD
     MOV CX,Count
     OR  CX,0
     JZ  @@2
   @@1:
     LODSB
     NOT AL
     ROL AL,1
     XOR AL,2
     STOSB
     LOOP @@1
   @@2:
     POP DS
   End; { DecodeBuf }

var Password : string;

 Begin
     Write('Enter your password to be encrypted: ');
     ReadLn(Password);
     EncodeBuf(Password[1], Length(Password));
     WriteLn;
     WriteLn('Encrypted password: ', Password);
     DecodeBuf(Password[1], Length(Password));
     WriteLn('Decrypted password: ', Password)
   End.

