{  Ok here it is..   I have disasembled the following TP Program to
show you the inner workings of TP (well at least 6.0).  The
Folloing Program was Compiled in the IDE With RANGE, I/O, STACK
checking turned off.  Look at the code close and see if you can
find a nasty little bug in it beFore I show you the Asm that TP
Created on disk.
}

Program TstFiles;

Type MyRec = Record
               LInt : LongInt;
               Hi   : Word;
               Lo   : Word;
               B1   : Byte;
               B2   : Byte;
               B3   : Byte;
               B4   : Byte;
             end;            {Record Size 12 Bytes}

Const MaxRecs = 100;


Var MyTypedFile   : File of MyRec;
    MyUnTypedFile : File;

    Rec           : MyRec;
    RecCnt        : Word;


Procedure FillRec (RecSeed : LongInt);

  begin
  Rec.Lint := RecSeed;
  Rec.Hi   := Hi (Rec.Lint);
  Rec.Lo   := Lo (Rec.Lint);
  Rec.B1   := Lo (Rec.Lo);
  Rec.B2   := Hi (Rec.Lo);
  Rec.B3   := Lo (Rec.Hi);
  Rec.B4   := Hi (Rec.Hi);
  end;




begin
Assign  (MyTypedFile,   'Type.Dat');
Assign  (MyUnTypedFile, 'UnTyped.Dat');
ReWrite (MyTypedFile);
ReWrite (MyUnTypedFile);

For RecCnt := 1 to MaxRecs do
  begin
  FillRec (RecCnt);

  Write (MyTypedFile  , Rec);
{ Write (MyUnTypedFile, Rec);} {Illegal can't do this}

  FillRec (RecCnt + $FFFF);

{ BlockWrite (MyTypedFile, Rec, 1);} {Illegal Can't do this eather}

  BlockWrite (MyUnTypedFile, Rec, Sizeof (MyRec));
  end;


end.


The Asm Break down is in the next two messages...

TSTFileS.38: begin
  cs:0051 9A0000262D     call   2D26:0000 <-------TP Start Up Code
  cs:0056 55             push   bp
  cs:0057 89E5           mov    bp,sp
TSTFileS.39: Assign (MyTypedFile, 'Type.Dat');
  cs:0059 BF4400         mov    di,0044
  cs:005C 1E             push   ds
  cs:005D 57             push   di
  cs:005E BF3C00         mov    di,003C
  cs:0061 0E             push   cs
  cs:0062 57             push   di
  cs:0063 9AC004262D     call   2D26:04C0 <-------TP's Routine to set
                                                  up File Records.
TSTFileS.40: Assign (MyUnTypedFile, 'UnTyped.Dat');
  cs:0068 BFC400         mov    di,00C4
  cs:006B 1E             push   ds
  cs:006C 57             push   di
  cs:006D BF4500         mov    di,0045
  cs:0070 0E             push   cs
  cs:0071 57             push   di
  cs:0072 9AC004262D     call   2D26:04C0 <-------TP's Routine to set
                                                  up File Records.
TSTFileS.41: ReWrite (MyTypedFile);
  cs:0077 BF4400         mov    di,0044
  cs:007A 1E             push   ds
  cs:007B 57             push   di
  cs:007C B80C00         mov    ax,000C
  cs:007F 50             push   ax
  cs:0080 9AF704262D     call   2D26:04F7 <-------TP's Routine to
                                                  Create File.
TSTFileS.42: ReWrite (MyUnTypedFile);
  cs:0085 BFC400         mov    di,00C4
  cs:0088 1E             push   ds
  cs:0089 57             push   di
  cs:008A B88000         mov    ax,0080
  cs:008D 50             push   ax
  cs:008E 9AF704262D     call   2D26:04F7 <-------TP's Routine to
                                                  Create File.
TSTFileS.44: For RecCnt := 1 to MaxRecs do
  cs:0093 C70650010100   mov    Word ptr [TSTFileS.RECCNT],00
    ***  Clear the loop counter For first loop
  cs:0099 EB04           jmp    TSTFileS.46 (009F)
    ***  Jump to the start of the Loop
  cs:009B FF065001       inc    Word ptr [TSTFileS.RECCNT]
    ***  The Loop returns to here to inC the loop counter
TSTFileS.46:  FillRec (RecCnt);
  cs:009F A15001         mov    ax,[TSTFileS.RECCNT]
    ***  Move our RecCnt Var into AX register
  cs:00A2 31D2           xor    dx,dx
    ***  Clear the DX Register
  cs:00A4 52             push   dx
  cs:00A5 50             push   ax
    ***  Push the DX and AX Registers on the stack.  Remember our
         FillRec Routine expects a LongInt to be passed and RecCnt
         is only a Word.  So it Pushes the DX as the 0 Upper Word
         of the LongInt.
  cs:00A6 0E             push   cs
    ***  Push the code segment For some reasion.
  cs:00A7 E856FF         call   TSTFileS.FILLREC
    ***  Call our FillRec Routine
TSTFileS.48:  Write (MyTypedFile , Rec);
  cs:00AA BF4400         mov    di,0044
  cs:00AD 1E             push   ds
  cs:00AE 57             push   di
    ***  These instructions push the address of MyTypedFile Record
         on the stack.  The first paramiter
  cs:00AF BF4401         mov    di,0144
  cs:00B2 1E             push   ds
  cs:00B3 57             push   di
    ***  These instructions push the address of Rec Record
         on the stack.  The second paramiter
  cs:00B4 9AAA05262D     call   2D26:05AA
    ***  Call the System Function to Write a Typed File.  (In next msg)
  cs:00B9 83C404         add    sp,0004
    ***  Remove our passed parameters from the stack
TSTFileS.51:  FillRec (RecCnt + $FFFF);
  cs:00BC A15001         mov    ax,[TSTFileS.RECCNT]
  cs:00BF 05FFFF         add    ax,FFFF
  cs:00C2 31D2           xor    dx,dx
  cs:00C4 52             push   dx
  cs:00C5 50             push   ax
  cs:00C6 0E             push   cs
  cs:00C7 E836FF         call   TSTFileS.FILLREC
    ***  Now heres a NASTY littel bug With the code!!!  Look at the
         above routine.  We wanted to pass a LongInt $FFFF + rec cnt
         But we wound up adding the $FFFF to a Word then passing a
         LongInt.  if you Compile the sample pas File you'll be able
         to see this bug in action..  Good reasion to use a Debugger.
TSTFileS.55:  BlockWrite (MyUnTypedFile, Rec, Sizeof (MyRec))
  cs:00CA BFC400         mov    di,00C4
  cs:00CD 1E             push   ds
  cs:00CE 57             push   di
    ***  These instructions push the address of MyUnTypeFile Record
         on the stack.  The First paramiter
  cs:00CF BF4401         mov    di,0144
  cs:00D2 1E             push   ds
  cs:00D3 57             push   di
  cs:0594 26817D02B3D7   cmp    es:Word ptr [di+02],D7B3
    *** Armed With the address of the File Record in ES:DI
        Check the File mode For a In/Out operation.  See Dos
        Unit Constant definitions.
  cs:059A 7406           je     05A2
    *** if that Compare was equal then jump to return
  cs:059C C7063C006700   mov    Word ptr [SYSTEM.inOUTRES],0069
    *** if we didn't jump then put File not oopen For output in
        Ioresult.
  cs:05A2 C3             ret
    *** Go back to where we were called
  cs:05A3 B43F           mov    ah,3F
  cs:05A5 BA6400         mov    dx,0064
  cs:05A8 EB05           jmp    05AF

    *** The Write instruction entered the system Unit here
  cs:05AA B440           mov    ah,40
    *** Load Dos Function in AH
  cs:05AC BA6500         mov    dx,0065
    *** Default error code 101 disk Write error load in DX
  cs:05AF 55             push   bp
    ***  Save the BP register
  cs:05B0 8BEC           mov    bp,sp
    *** Load the BP Register With the stack Pointer
  cs:05B2 C47E0A         les    di,[bp+0A]
    *** Load Address of MyTypeFile Rec in ES:SI
  cs:05B5 E8DCFF         call   0594
    *** Call check For File mode.  See top of message
  cs:05B8 751B           jne    05D5
    *** if error jump out of this
  cs:05BA 1E             push   ds
  cs:05BB 52             push   dx
    *** Save These Registers as we'er going to use them
  cs:05BC C55606         lds    dx,[bp+06]
    *** Load the address of our Rec in DS:DX Registers
  cs:05BF 268B4D04       mov    cx,es:[di+04]
    *** Look up Record structure For a File Rec and you'll see
        that RecSize is Byte # 4.  Move that value to CX
  cs:05C3 268B1D         mov    bx,es:[di]
    *** First Byte of a File Rec is the Handel.  Move into BX
  cs:05C6 CD21           int    21
    *** Make the Dos CALL to Write.  AH = 40
                                     BX = File Handel
                                     CX = # of Bytes to Write.
                                     DS:DX = Address of Buffer
        Returns Error In AX if Carry flag set or
        if good CF = 0 number of Bytes written in AX
  cs:05C8 5A             pop    dx
  cs:05C9 1F             pop    ds
    *** Restore the Registers
  cs:05CA 7206           jb     05D2
    *** Jump if there was an error (if Carry flag Set)
  cs:05CC 3BC1           cmp    ax,cx
    *** Comp Bytes requested to what was written
  cs:05CE 7405           je     05D5
    *** if equal then jump out we'r just about done
  cs:05D0 8BC2           mov    ax,dx
    *** Move default errorcode 101 to AX
  cs:05D2 A33C00         mov    [SYSTEM.inOUTRES],ax <--Set Ioresult
    *** Store 101 to Ioresult
  cs:05D5 5D             pop    bp
    *** Restore BP register
  cs:05D6 CA0400         retf   0004
    *** We'r out of here

  cs:05D9 B33F           mov    bl,3F
  cs:05DB B96400         mov    cx,0064
  cs:05DE EB05           jmp    05E5


    *** The BlockWrite instruction entered the system Unit here
  cs:05E0 B340           mov    bl,40
    *** Move Dos Function in BL
  cs:05E2 B96500         mov    cx,0065
    *** Default error 101 Write error in CX
  cs:05E5 55             push   bp
    *** Save BP Register
  cs:05E6 8BEC           mov    bp,sp
    *** Move Stack Pointer to BP
  cs:05E8 C47E10         les    di,[bp+10]
    *** Load Address of MyUnTypedFile Record in ES:DI
  cs:05EB E8A6FF         call   0594
    *** Check For Open in Write Mode See top of message
  cs:05EE 753F           jne    062F
    *** Jump if not in Write mode
  cs:05F0 8B460A         mov    ax,[bp+0A] ]
    *** Move File Record cnt in to ax
  cs:05F3 0BC0           or     ax,ax
    *** Check For 0 Record request
  cs:05F5 741C           je     0613
    *** Jump if 0 rec requested
  cs:05F7 1E             push   ds
  cs:05F8 51             push   cx
    *** Save them we'er going to use them
  cs:05F9 26F76504       mul    es:Word ptr [di+04]
    *** Multiply Record size With RecCnt in AX result in DX & AX
  cs:05FD 8BC8           mov    cx,ax
