(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0012.PAS
  Description: PATCHEXE.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:40
*)

{ PD> This looks like something I would like to add to my Programs.  My
 PD> question is, how do you modify the .exe from the Program.  I can do the
 PD> encryption but don't know how to store the encrypted passWords in the
 PD> Program's own .exe.  Any help would be appreciated.
}

Procedure PatchExeFile(ItemAddr:Pointer;itemsize:LongInt);
Var
  FiletoPatch : File;
  HeaderSize  : Word;
  seeksize    : LongInt;
  offset      : Word;
  LDseg       : LongInt;
  ch          : Char;

begin
  assign(FiletoPatch, paramstr(0));
  reset(FiletoPatch, 1);
  seek(FiletoPatch, 8);
  blockread(Filetopatch, headersize, sizeof(headersize));
  offset := ofs(itemAddr^);
  Ldseg := LongInt(Dseg);
  seeksize := 16 * (LDseg - PrefixSeg + HeaderSize) + offset - 256
    seek(Filetopatch, seeksize);
  blockWrite(Filetopatch, ItemAddr^, ItemSize);
  close(Filetopatch);
end;

{Call it this way:
}
PatchExeFile(Addr(passWords), sizeof(passWords));

{note that For this to work, passWords must be a TypeD ConstANT.
So you declare it this way:
}
  PassWords : PassWord_Array =
  (
    (PassWord : #247#154#189#209#18#104#143#29; Protected : False),
    .
    .
    .
    (PassWord : #247#154#189#209#18#104#143#29; Protected : False)
  );

{  PassWord_Array is declard as an Array of PassWord_Record;

    The above declaration is from my Crypto.inC. I have a Crypto.PAS
Program that generates this File from my Make File so that on each
Compile the encryption is changed and the Array of passWords is stored
with valid encrypted passWords. I used #<AsciiValue> because the
encryption can generate values from Ascii 0 to Ascii 255 and some of
those cause troubles in Strings Constants using "'" as delimeters.

    As long as you use:

Const <ConstName> : <ConstType> = <ConstantValue>;

    You will be sure PatchExe can find it's correct adress in the EXE.
From there on you can read it in your TP Program as usual and store it
using the call to PatchExe I gave up there.

    BTW, do as I do and generate a new random encryption key on each
run, Re-encrypting everything and writting it back to the exe. This
drives Hackers mad when they try to decypher your encrypted passWords.

One last note:
    The above PatchExe was written when I used TP 6.0. I haven't checked
    yet if TP 7.0 Uses different mapping of his EXe and it will most
    probably not work on a Protected-mode Compiled EXE.
}

