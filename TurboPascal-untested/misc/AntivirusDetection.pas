(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0161.PAS
  Description: ANTI-Virus detection
  Author: R. LOERAKKER
  Date: 09-04-95  11:02
*)

(*
>        I have a big problem here. It's just, I want to make a simple
>anti-virus, but I don't know how to locate, remove a virus. Anybody know
>how to can you please teach me...or a source code would be better
>Thankx...Bye!
Here's a small program to find & eradicate the Taipan virus, but first the DOC file:




                  Written on 26-11-94 by R. Loerakker



                        (C) 1994 by R. Loerakker
                                and the
                     Virus Research Centre Holland




DISCLAIMER
==========

        Warning. This product comes as is. The author, nor the VRCH can
        be held responsible for any damage done to your system,
        accidental or implied. However, this program should be safe and
        worked correct on our systems.


PURPOSE
=======

        These source codes are provided to the public to show how a
        scanner engine could work. I provided them in two different
        languages to show that it doesn't really matter which one you
        use. The programs will, if compiled, search for the Tai-Pan
        (Whisper) virus on the current drive. They will not repair the
        file, they only report the infections.


LANGUAGE
========

        The languages I used to create these programs are both from
        Borland, named Borland Pascal 7.0 and Borland C++ 3.1 (with
        Application Frameworks). I used the normal Pascal syntax,
        without any object oriented code in it. The C version is also
        made without any object oriented code (C++ extensions). The
        object oriented programming style can be adapted if your scanner
        has to cope with more viruses. You can make a OOP database of
        the viruses.


DRAWBACKS
=========

        These programs have some drawbacks and I will give them here :
        * they don't scan in archives
        * they don't scan inside packed executables
        * they won't disinfect an infected file
        * they don't use anti-stealth techniques (not needed for
          Tai-Pan)
        * Some other (dumb) scanners can give a false alarm, identifying
          the compiled source as Tai-Pan. These scanners do scan the
          whole file, not just the entrypoint (as I do). They can find
          a piece of Tai-Pan (the signature) in the data segment of the
          program.


LEGAL RIGHTS
============

        You may use these sourcecodes to make your own scanner for a
        certain virus, without any restrictions. I would like it if you
        leave my name in it, because I also spent some time in it,
        escpecially learning C, which is not my best language (yet). The
        source code may be copied freely, as long as the three files are
        included (FINDTAI.CPP, FINDTAI.PAS and this FINDTAI.DOC). There
        are no objections for adding BBS advertisements in the archive
        and the archive may be converted to another type. Publishing on
        a CD-ROM is also no problem. If you make your own scanner for a
        virus with these source codes, I would like a copy of the
        program (also the sourcecode if you want to).


VRCH (Virus Research Centre Holland)
====================================

        The VRCH is an independed organisation that helps people and
        companies with getting rid of viruses. We also hope to give a
        certain education and making people more virus-aware. We produce
        a wide range of antivirus software, from individual cleaners to
        source code like this. Most of these programs are freeware,
        unless otherwise stated, but money is always welcome to cover
        the expenses. If you have any problems with viruses, please
        contact us and we might be able to help you.


THE AUTHOR
==========

        Richard Loerakker
        Albert Schweitzerstraat 3
        2851 CC  HAASTRECHT
        Tel. 01821-3050

        Note :  This address will be invalid from 17th of December,
                because I am moving. I will give the new address when I
                am settled at my new place. Meanwhile, you still can
                send to the above address and I will receive it anyway.


GREETINGS
=========

        First I want to thank Rob Vlaardingerbroek, former president of
        the Virus Research Centre Holland, for helping me with these
        projects. Also thanks for the other members for supporting me
        with keeping VRCH alive after Rob has thanked for his position
        in VRCH. Also thanks to Righard Zwienenberg (CSE) for pointing
        out a flaw in the C code. Further thanks go to :

        My parents (ofcourse)
        Industrial Man of Intertia
                Thanks for putting up a seperate VRCH area on your BBS
                for uploading my newest programs.
        Rob Greuter (F-PROT Nederland)
                The professional version is very good, indeed. I hope to
                see it in the "SLB diensten" soon.
        Fernando Cassia
                The cards were beautiful, and would love to see a video
                of your country (and maybe you?)
        Hans-Göran Andersson
                Thanks for the letter, I appreciate it.
        Hans Janson
                Thanks for mentioning the bug in K-JUNKIE (1.0)
        Jan Hekking
                Also thanks for pointing out the bug in K-JUNKIE (1.0)

        Also greetings to all other authors of antivirus software!


AT LAST
=======

        You hope that you can use these sourcecodes and that you might
        have learned more about fighting viral infections.

        Regards,

        Richard Loerakker
        Technical President of the Virus Research Centre Holland

***

*** C:\T\T\FINDTAI.PAS
(*=========================================================================

Source      : FINDTAI.PAS
Version     : 1.0
Compiler    : Borland Turbo Pascal 7.0
Date        : 26-11-1994
Author      : R. W. Loerakker
Purpose     : Short course on scanning viruses
Description : This program is just made as a demonstration program on how
              you can make a program to scan for a certain virus. This
              doesn't mean this is perfect. It's just an example of how
              a scanner engine might work. This detects the TAI-PAN virus
              in infected files on the current drive.

=========================================================================*)
Uses Crt, DOS;

Const
  Sig : Array[0..9] of Byte = ($e8,$00,$00,$5e,$83,$ee,$03,$b8,$ce,$7b);

Var F : File;
  Buf1 : Array [0..$1C] Of Byte;
  Buf2 : Array [0..30] Of Byte;
  Nr, Hp, Cs, Ip : Word;
  Ep: LongInt;
  Infected : Integer;
  Attrib : Word;

Function Up (S : String) : String;
Var I : Integer;
Begin
  For I := 1 To Length (S) Do
    S [I] := UpCase (S [I] );
  Up := S;
End;

Function Rep (Times : Integer; What : String) : String;
Var Tmp : String;
  I : Integer;
Begin
  Tmp := '';
  For I := 1 To Times Do
    Tmp := Tmp + What;
  Rep := Tmp;
End;

Function Compare ( B : Array Of Byte) : Boolean;
Var
  C : Byte;
  IsIt : Boolean;
Begin
  IsIt := True;
  C := 0;
  While (C <= 9) And (IsIt) Do
  Begin
    If B[C] <> Sig[C] Then IsIt := False;
    Inc(C);
  End;
  Compare := IsIt;
End;

Procedure FExe (N : String);
Begin
  FileMode := 0;
  If Pos ('.EXE', N) <> 0 Then Begin
  Assign (F, N);
  GetFAttr (F, Attrib);
  SetFAttr (F, 0);
  FileMode := 2;
  Reset (F, 1);
  BlockRead (F, Buf1, SizeOf (Buf1), Nr);
  Ep := 0;
    If Buf1[0]+(Buf1[1] * 256) = $5a4d Then Begin
      Hp := Buf1 [8] + Buf1 [9] * 256;
      Ip := Buf1 [$14] + Buf1 [$15] * 256;
      Cs := Buf1 [$16] + Buf1 [$17] * 256;
      Ep := Cs + Hp;
      Ep := (Ep * 16 + Ip) And $FFFFF;
    End;
    Seek (F, Ep);
    BlockRead (F, Buf2, SizeOf (Buf2), Nr);
    Write (N);
    If Compare ( Buf2) Then Begin
      WriteLn (Rep (60 - Length (N), ' '), 'Infected. ');
      Inc (Infected);
    End
    Else Write (Rep (60 - Length (N), ' '), 'Clean.'#13);
  Close (F);
  SetFAttr (F, Attrib);
  End;
End;

Procedure SDir ( SPath : String);
Var S : SearchRec;
Begin
  FindFirst (SPath + '*.*', AnyFile Xor VolumeID, S);
  If S. Name = '.' Then
  Begin
    FindNext (S);
    FindNext (S);
  End;
  If (DosError = 0) And (S. Attr And Directory <> Directory) Then
  Begin
    FExe (SPath + S. Name);
    FindNext (S);
  End;
  While DosError = 0 Do
  Begin
    If (S. Attr And Directory = Directory) Then
    Begin
      SDir (SPath + S. Name + '\');
    End
    Else
      FExe (SPath + S. Name);
    FindNext (S);
  End;
End;

Begin
  WriteLn ('F-TAIPAN V1.0 (C) 1994 by R. Loerakker');
  WriteLn;
  WriteLn ('Searching for TAI-PAN...');
  WriteLn;
  Infected := 0;
  SDir (Copy (Up (ParamStr (0) ) , 0, 2) + '\');
  ClrEol;
  WriteLn (Infected, ' infected files found.');
End.
***

