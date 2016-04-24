(*
  Category: SWAG Title: DATA TYPE & COMPARE ROUTINES
  Original name: 0024.PAS
  Description: Secure Encryption
  Author: ANDREW EIGUS
  Date: 11-26-94  05:01
*)

{
The following is result of my work to make simple, fast, and enough
acceptable routine that will encrypt/decrypt any data with the given Key
string. It really works, it's far from RSA and DES, but it encrypts/decrypts
just as it will be _quite_ (impossibel? hard?) to restore the original data
without knowing a Key. BTW, i would recommend as long Key as possibel. ;)

This Eigus Encryption released to Public Domain, and no charge is required
for the author. Alsow, if you would have reccomendations, suggestions, ideas,
or stories to optimise my code, please do not hestitate to ask/tell/post.

Eigus Encryption may be included in SWAG. Thank you.
}

Unit Crypto;
{
  Copyright (c) 1994 by Andrew Eigus    Fidonet: 2:5100/33
  Eigus Encryption Routine source code for Borland Pascal 7.0
  Platforms: DOS, DPMI, Windows
}

interface

const
  { use these above as values for ecCommand parameter for Encrypt procedure }
  ecEncode  = True;
  ecExtract = False;

procedure Encrypt(var Buffer; Count : word; Key : string; ecCommand : boolean);

implementation

Procedure Encrypt; assembler;
var
  SaveDS, SaveSI : word;
  N : byte;
Asm
  push ds
  lds si,Key
  cld
  xor ah,ah
  lodsb
  mov N,al
  mov bx,ax
  cmp bx,0
  je  @@5
  mov SaveDS,ds
  mov SaveSI,si
  lds si,Buffer
  les di,Buffer
  mov cx,Count
  jcxz @@5
@@1:
  lodsb
  mov dl,al
  push ds
  push si
  mov ds,SaveDS
  mov si,SaveSI
  lodsb
  dec bx
  cmp bx,0
  jz  @@2
  lds si,Key
  lodsb
  mov bl,al
@@2:
  add N,al
  or  ecCommand,ecExtract
  jz  @@3
  add dl,al
  sub dl,N
  not dl
  jmp @@4
@@3:
  not dl
  add dl,N
  sub dl,al
@@4:
  mov al,dl
  mov SaveDS,ds
  mov SaveSI,si
  pop si
  pop ds
  stosb
  loop @@1
@@5:
  pop ds
End; { Encrypt }

End.



{ CRYPDEMO.PAS }

Program CryptoDemo;
{
Copyright (c) 1994 by Andrew Eigus  Fidonet: 2:5100/33
Demonstrates the use of unit CRYPTO.PAS
}

uses Crypto;

var
  Str, Key : string;

Begin
  Str := 'This is text to encrypt with Encrypt procedure'; { text to encrypt }
  Key := 'ExCaLiBeR'; { key string to use; longer -> safer ;I }
  WriteLn(#13#10'Original string: ''', Str, '''');
  Encrypt(Str[1], Length(Str), Key, ecEncode);
  WriteLn('Encrypted string: ''', Str, '''');
  Encrypt(Str[1], Length(Str), Key, ecExtract);
  WriteLn('Decrypted string: ''', Str, '''')
End.

{
I hope that my CRYPTO unit might be useful for all of you. You may change my
code as you want.
}

