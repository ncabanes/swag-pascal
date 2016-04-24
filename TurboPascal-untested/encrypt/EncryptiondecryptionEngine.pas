(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0034.PAS
  Description: Encryption/Decryption Engine
  Author: SALVATORE MESCHINI
  Date: 08-30-97  10:08
*)


Hi Gayle, I have this contribution for SWAG Archives. 
This source is an easy-to-use (I hope) encoding/decoding engine (it
includes a demo).

Unit EncDec;

{EncDec is copyrighted by Salvatore Meschini - FREEWARE -
Salvatore Meschini - smeschini@ermes.it - http://www.ermes.it/pws/mesk
Please report: bugs,suggestions,comments to the address above}

{Use this code at your own risk! I'm not responsible if it cause any
damages!!!}

{Usage: The procedure ENCODE will encrypt with PASSWORD the BUFFERIN (that is
        long BYTESTOENCODE bytes) in BUFFEROUT.
        The procedure DECODE will decrypt with PASSWORD the BUFFERIN (blah
blah)
        in BUFFEROUT.}

{Tips : I suggest you to encode the PASSWORD too! (if you don't know how to do
       it, feel free to contact me). In the encoding process, BUFFERIN is
       plain data that will be encrypted in BUFFEROUT. In the decoding
process,
       BUFFERIN is the encrypted data that will be decrypted in BUFFEROUT.}


{I included a DEMO, check it...}

interface

type BufType=array[1..8192] of char;

Procedure Encode(password:string;var bytestoencode:integer;var
bufferIN,BufferOUT:bufType);
Procedure Decode(password:string;var bytestodecode:integer;var
bufferIN,BufferOUT:bufType);

(*--------------------------------------------------------------------------
--*)
IMPLEMENTATION

(*--------------------------------------------------------------------------
--*)
PROCEDURE ENCODE(PASSWORD: STRING; var BYTESTOENCODE: INTEGER; VAR BUFFERIN,
                 BUFFEROUT: BUFTYPE);

  VAR
    INB, OUTB, LP: BYTE;
    K:Integer;

  BEGIN
    K := 0;
    LP := 1;
    WHILE K < BYTESTOENCODE DO
      BEGIN
        INC(K);
        INB := ORD(BUFFERIN[K]);
        OUTB := INB + K;
        OUTB := OUTB XOR ORD(PASSWORD[LP]);
        BUFFEROUT[K] := CHR(OUTB);
        INC(LP);

        IF LP > LENGTH(PASSWORD)
          THEN
            LP := 1;
      END;
  END;

(*--------------------------------------------------------------------------
--*)
PROCEDURE DECODE(PASSWORD: STRING; var BYTESTODECODE: INTEGER; VAR BUFFERIN,
                 BUFFEROUT: BUFTYPE);

  VAR
    INB, OUTB,LP: BYTE;
    K:Integer;

  BEGIN
    K := 0;
    LP := 1;
    WHILE K < BYTESTODECODE DO
      BEGIN
        INC(K);
        INB := ORD(BUFFERIN[K]);
        OUTB := INB XOR ORD(PASSWORD[LP]);
        OUTB := OUTB - K;
        BUFFEROUT[K] := CHR(OUTB);
        INC(LP);

        IF LP > LENGTH(PASSWORD)
          THEN
            LP := 1;
      END;
  END;

(*--------------------------------------------------------------------------
--*)
BEGIN
END.

ses EncDec;

var inf,outf,testf:file; {Files used for this DEMO}
    bufferIN,BufferOUT:BufType;
    count,result:integer;

begin
assign(inf,'encdec.pas'); {Source File}
reset(inf,1);
assign(outf,'encdec.enc'); {Target File}
rewrite(outf,1);
while not eof(inf) do      {Encoding cycle}
 begin
   blockread(inf,bufferin,8192,count);
   encode('Hello World!',count,bufferin,bufferout);
   blockwrite(outf,bufferout,count,result);
 end;
close(inf);close(outf);
assign(outf,'encdec.enc'); {I will try to decode what I encoded...}
reset(outf,1);
assign(testf,'encdec.bak'); {...so encdec.bak should be equal to encdec.pas}
rewrite(testf,1);
 while not eof(outf) do       {Decoding cycle}
   begin
   blockread(outf,bufferin,8192,count);
   decode('Hello World!',count,bufferin,bufferout);
   blockwrite(testf,bufferOUT,count,result);
   end;
close(testf);close(outf);
end.




