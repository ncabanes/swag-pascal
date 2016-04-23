
UNIT Vector;
{$F+,O+}
{$DEFINE Englisch}             { language for error messages Englisch/Deutsch }

{ An example how to program variable sized arrays on the heap. Some of the 
  routines are programmed in 80x87 assembler for speed. (See R. Startz: 
  8087/80287/80387 for the IBM PC & Compatibles, 3rd ed., New York (Brady) 
  1988, ISBN 0-13-246604-X for an introduction to 80x87 assembler)
  
  Copyright (c) 1997 by Dr. Engelbert Buxbaum. This code may be freely 
  distributed and used for non-commercial purposes. All other rights reserved. 
  
  I have left in calls to some libraries I normally use for IO and error 
  handling (see USES-clause for details). It should not be difficult to 
  replace them with your own. } 

INTERFACE

USES CRT, 
     Windows,     { handle windows for I/O. Source: Chip-Spezial - Das 
                    Allerbeste, Wuerzburg (Vogel) 1989, ISBN 3-8023-1008-X
                    Used in WriteVector. Defines also 
                    FUNCTION Error (Msg : STRING) : CHAR; for error handling.
                    This function opens a window, prints Msg, waits for a key 
                    to be pressed, closes the window and returns the key }
     ReadExt,     { protected keyboard input. Defines functions ReadByte, 
                    ReadReal ect with their obvious meaning. Argument of 
                    these function is the number of significant places. Also 
                    from Chip Special } 
     MathFunc;    { simple math routines like logarithms ect. }

CONST MaxVector = 8000;                    { so as not to exceed 64 KB }

      VectorXPos  : WORD = 1;              { position for screen output }
      VectorYPos  : WORD = 1;

      VectorError : BOOLEAN = FALSE;       { flag for error handling, can be
                                             checked and reset by calling unit }

TYPE VectorStruc = RECORD 
                        Column : WORD; 
                        Data   : ARRAY [1..MaxVector] of DOUBLE;
                   END;

     VectorTyp = ^VectorStruc;

     MedString   = string[14];             { name of I/O device }


PROCEDURE ReadVector (MedStr : MedString; var Vector : VectorTyp);
{ read vector from device given by MedString. Can be a file, CON or PRN.
  Vector will be created inside this routine and should not exist when the
  function is entered. First line contains the number of Vector-elements (may 
  be preceeded by '#' for compatibility with GnuPlot), followed by each element 
  on a separate line }

PROCEDURE WriteVector (MedStr : MedString; Vector : VectorTyp; Places : BYTE);
{ Write vector to device. See comment above for details of file format }

PROCEDURE InitVector (VAR Vector : VectorTyp; len : WORD);
{ create vector, contents will be undefined }

PROCEDURE KillVector (VAR Vector : VectorTyp);
{ reclaim memory occupied by vector }

FUNCTION VectorLength (Vector : VectorTyp) : WORD;

FUNCTION GetVectorElement (Vector : VectorTyp; n : WORD) : DOUBLE;

PROCEDURE PutVectorElement (Vector : VectorTyp; n : WORD; c : DOUBLE);

PROCEDURE CopyVector (Source, Target : VectorTyp);
{ use instead of Target := Source to copy contents of vector  }

PROCEDURE LoadConstant (Vector : VectorTyp; C : DOUBLE);
{ load all vector elements with C }

PROCEDURE AddConstant (A, B : VectorTyp; C : DOUBLE);
{ add C to all elements in A and save result in B. A and B may be identical }

PROCEDURE SubConstant (A, B : VectorTyp; C : DOUBLE);

PROCEDURE MulConstant (A, B : VectorTyp; C : DOUBLE);

PROCEDURE DivConstant (A, B : VectorTyp; C : DOUBLE);

PROCEDURE VectorAdd (A, B, C : VectorTyp);
{ Add corresponding elements of A and B, save result in C. A, B and C may
  be identical. }

PROCEDURE VectorSub (A, B, C : VectorTyp);

FUNCTION VectorInnerProduct (A, B : VectorTyp) : DOUBLE;
{ Inner product of 2 vectors (sum of the product of corresponding elements) }

FUNCTION GSum (Vector : VectorTyp) : DOUBLE;
{ GSum := a[1] + a[2] + ... + a[n]. Divide this sum by Vector.Len to get the
  arithmetic mean. }

FUNCTION HarmonicAverage (Vector : VectorTyp) : DOUBLE;
{ n-th root of the product of all elements, implemented by dividing the sums 
  of the logarithms of all elements by n. The elements must be > 0 }

FUNCTION VectorAbsolute (Vector : VectorTyp) : DOUBLE;
{ Euclidian vector length, sqrt of the sum of the squares of all elements }

FUNCTION Angle (A, B : VectorTyp) : DOUBLE;
{ arccos(InnerProduct(A, B) / (len(A)*len(B))) }

IMPLEMENTATION

TYPE PtrParts = RECORD
                     Ofs, Seg : WORD;       { Address to which Vector points }
                END;

VAR ch : CHAR;                              { dummy variable for error handling }


PROCEDURE InitVector (VAR Vector : VectorTyp; len : WORD);

{$IFDEF Deutsch}  
CONST Text = ' nicht genuegend (zusammenhaengender) Speicher'; 
{$ENDIF}
{$IFDEF Englisch} 
CONST Text = ' not enough (continuous) memory';               
{$ENDIF}

BEGIN
    IF (len > MaxVector) OR (len*SizeOf(DOUBLE)+4 > MaxAvail)
      THEN
         BEGIN
             ch := Windows.Error(Text);
             VectorError := TRUE;
             EXIT;
         END;
    GetMem(Vector, len*SizeOf(DOUBLE)+4);
    Vector^.Column := len;
END;


PROCEDURE KillVector (VAR Vector : VectorTyp);

BEGIN
    FreeMem(Vector, Vector^.Column*SizeOf(DOUBLE)+4);
    Vector := nil;                         { so it may not be used by mistake }
END;


FUNCTION VectorLength (Vector : VectorTyp) : WORD;

BEGIN
    VectorLength := Vector^.Column;
END;


FUNCTION GetVectorElement (Vector : VectorTyp; n : WORD) : DOUBLE;

{$IFDEF Deutsch}  
CONST Text = ' Lesender Zugriff auf nicht existierendes Vektor-Element'; 
{$ENDIF}
{$IFDEF Englisch} 
CONST Text = ' Attempt to read non-existend vector element';             
{$ENDIF}

BEGIN
    IF (n <= Vector^.Column)
      THEN
         GetVectorElement := Vector^.Data[n]
      ELSE
         BEGIN
             ch := Windows.Error(Text);
             VectorError := TRUE;
         END;
END;


PROCEDURE PutVectorElement (Vector : VectorTyp; n : WORD; C : DOUBLE);

{$IFDEF Deutsch}  
CONST Text = ' Schreibender Zugriff auf nicht existierendes Vektor-Element'; 
{$ENDIF}
{$IFDEF Englisch} 
CONST Text = ' Attempt to Write to non-existing vector element';             
{$ENDIF}

BEGIN
    IF (n <= Vector^.Column)
      THEN
         Vector^.Data[n] := C
      ELSE
         BEGIN
             ch := Windows.Error(Text);
             VectorError := TRUE;
         END;
END;


PROCEDURE CopyVector (Source, Target : VectorTyp);

VAR i, j, k, l, m : WORD;
    p             : PtrParts ABSOLUTE Source;
    q             : PtrParts ABSOLUTE Target;

BEGIN
    IF (Source^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    InitVector(Target, Source^.Column);
    if VectorError then exit;
    ASM
      PUSH  DS
      MOV   AX,i                   { SizeOf(DOUBLE) into AX    }
      MOV   ES,k
      MOV   BX,j                   { instead of LES Vector^ }
      MOV   CX,WORD PTR ES:[BX]    { vector length into CX }
      ADD   BX,2                   { ES:[BX] => Source.Data[1] }
      MOV   SI,l
      MOV   DS,m
      ADD   SI,2                   { DS:[SI] = Target.Data[1] }
@VecLoop:
      FLD   QWORD PTR ES:[BX]      { Copy Source.Data[j] into ST(0) }
      FSTP  QWORD PTR DS:[SI]      { Move ST(0) into Target.Data[j] }
      ADD   BX,AX                  { ES:[BX] to next element of Source }
      ADD   SI,AX                  { DS:[SI] to next element of Target }
      LOOP  @VecLoop
      POP   DS
    END;
END;
 

PROCEDURE ReadVector (MedStr : MedString; var Vector : VectorTyp);

{$IFDEF Deutsch}
CONST TitelStr  = ' Vektor einlesen ';
      Text1     = ' Datei mit Vektor nicht gefunden';
      Text2     = ' Vektor zu gross';
      Text3     = ' Unbekanntes Datei-Format';
      Namen     : array [1..2] of string[10] = ('Laenge: ', 'Element: ');
{$ENDIF}
{$IFDEF Englisch}
CONST TitelStr = ' Read vector ';
      Text1    = ' File with vector not found';
      Text2    = ' Vector too large';
      Text3    = ' Unknown file format';
      Namen    : array [1..2] of string[10] = ('Length: ', 'Element: ');
{$ENDIF}

VAR j, k, l : WORD;
    code    : integer;
    Medium  : text;
    Window  : WindowType;
    hst     : string[5];

BEGIN
    FOR k := 1 TO Length(MedStr) DO
       MedStr[k] := UpCase(MedStr[k]);
    IF MedStr = 'CON'
      THEN
         BEGIN 
             Window := Windows.NormWindow;
             Window.Titel := TitelStr;
             Windows.OpenWindowType(1, 1, 80, 25, Window);
             Write(Namen[1]);
             l := ReadExt.ReadByte(3);
             WriteLn;
         END
      ELSE
         BEGIN
             Assign(Medium, MedStr);
             Reset(Medium);
             IF IOResult <> 0
               THEN
                  BEGIN
                      ch := Windows.Error(Text1);
                      VectorError := TRUE;
                      EXIT;
                  END;
             ReadLn(Medium, hst);
             if hst[1] = '#' then hst := copy(hst, 2, length(hst)); { for compatibility with gnuplot }
             Val(hst, l, code);
             if code <> 0 
               then
                  begin
                      VectorError := True;
                      ch := Windows.Error(Text3);
                      exit;
                  end;
         END;
    InitVector(Vector, l);
    IF VectorError THEN EXIT;
    IF MedStr = 'CON'
      THEN
         WriteLn(' ----------------- ');
    IF (Vector^.Column > MaxVector)
      THEN
         BEGIN
             ch := Windows.Error(Text2);
             VectorError := TRUE;
             EXIT;
         END;
      IF MedStr = 'CON'
        THEN
           FOR j := 1 TO l DO
              BEGIN
                  Write(j, '. ', Namen[2]);
                  Vector^.Data[j] := ReadExt.ReadReal(12, 5);
                  WriteLn;
              END
        ELSE
           BEGIN
               FOR j := 1 TO l DO
                  BEGIN
                      IF EOF(Medium)
                        THEN
                           BEGIN
                               ch := Windows.Error(Text3);
                               VectorError := TRUE;
                               EXIT;
                           END;
                      ReadLn(Medium, Vector^.Data[j]);
                      IF IOResult <> 0
                        THEN
                           BEGIN
                               ch := Windows.Error(Text3);
                               VectorError := TRUE;
                               EXIT;
                           END;
                  END;
           END;
    IF MedStr = 'CON'
      THEN
         Windows.CloseWindow
      ELSE
         Close(Medium);
END;


PROCEDURE WriteVector (MedStr : MedString; Vector : VectorTyp; Places : BYTE);

VAR j, k    : WORD;
    Medium  : TEXT;
    Window  : WindowType;

BEGIN
    FOR k := 1 TO length(MedStr) DO
       MedStr[k] := UpCase(MedStr[k]);
    IF (MedStr = 'CON')
      THEN
         BEGIN
             Window.TextAtt := 23;
             Window.RahmenAtt := 23;
             Window.Rahmen := NoFrame;
             Window.Titel := '';
             OpenWindowType(VectorXPos, VectorYPos, VectorXPos+Places+1,
                            VectorYPos+Vector^.Column+2, Window);
         END
      ELSE
         assign(Medium, MedStr);
    IF NOT ((MedStr = 'LST') OR (MedStr = 'CON'))
      THEN
         BEGIN
             ReWrite(Medium);
             WriteLn(Medium, '#', Vector^.Column);
         END
      ELSE
         IF (MedStr = 'LST') THEN ReWrite(Medium);
    FOR j := 1 TO Vector^.Column DO
      IF (MedStr <> 'CON')
        THEN
           WriteLn(Medium, MathFunc.FloatStr(Vector^.Data[j], Places))
        ELSE
           Write(MathFunc.FloatStr(Vector^.Data[j], Places));
    IF MedStr <> 'CON' THEN close(Medium);
END;


PROCEDURE LoadConstant (Vector : VectorTyp; C : DOUBLE);

VAR i, j, k : WORD;
    p       : PtrParts ABSOLUTE Vector;

BEGIN
    IF (Vector^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    ASM
      mov   ax,i                   
      mov   es,k
      mov   bx,j                   
      mov   cx,WORD ptr es:[bx]    
      add   bx,2                   
      fld   qword ptr C            { put C into ST(0) }
@ConstLoop:
      fst   qword ptr ES:[BX]      { copy C from ST(0) into A[j] }
      add   bx,ax                  { ES:[BX] to next element }
      loop  @ConstLoop
      fstp  st(0)                  { clean up Coprocessor-Stack }
    END;
END;


PROCEDURE AddConstant (A, B : VectorTyp; C : DOUBLE);

VAR i, j, k, l, m : WORD;
    p             : PtrParts ABSOLUTE A;
    q             : PtrParts ABSOLUTE B;

BEGIN
    IF (A^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    B^.Column := A^.Column;
    ASM
      PUSH  DS
      MOV   AX,i                   
      MOV   ES,k
      MOV   BX,j                   
      MOV   CX,WORD PTR ES:[BX]    
      ADD   BX,2                   
      MOV   SI,l
      MOV   DS,m
      ADD   SI,2                   
      FLD   QWORD PTR C            { load constant C into ST(0) }
@AddLoop:
      FLD   QWORD PTR ES:[BX]      { A.Data[j] into ST(0) }
      FADD  ST,St(1)               { ST(0) = A.Data[j] + C }
      FSTP  QWORD PTR DS:[SI]      { move result into B.Data[j] }
      ADD   BX,AX                  
      ADD   SI,AX                  
      loop  @AddLoop
      FSTP  ST(0)                  
      POP   DS
    END;
END;


PROCEDURE SubConstant (A, B : VectorTyp; C : DOUBLE);

VAR i, j, k, l, m : WORD;
    p             : PtrParts ABSOLUTE A;
    q             : PtrParts ABSOLUTE B;

BEGIN
    IF (A^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    B^.Column := A^.Column;
    ASM
      PUSH  DS
      MOV   AX,i                   
      MOV   ES,k
      MOV   BX,j                   
      MOV   CX,WORD PTR ES:[BX]    
      ADD   BX,2                   
      MOV   SI,l
      MOV   DS,m
      ADD   SI,2                   
      FLD   QWORD PTR C                                                         
@SubLoop:                                             
      FLD   QWORD PTR ES:[BX]                                                   
      FSUB  ST,ST(1)                                                            
      FSTP  QWORD PTR DS:[SI]                                                   
      ADD   BX,AX                                                               
      ADD   SI,AX                                                               
      LOOP  @SubLoop                                             
      FSTP  ST(0)                                                               
      POP   DS
    END;
END;


PROCEDURE MulConstant (A, B : VectorTyp; C : DOUBLE);

VAR i, j, k, l, m : WORD;
    p             : PtrParts ABSOLUTE A;
    q             : PtrParts ABSOLUTE B;

BEGIN
    IF (A^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    B^.Column := A^.Column;
    ASM
      PUSH  DS
      MOV   AX,i                                                                
      MOV   ES,k                                             
      MOV   BX,j                                                                
      MOV   CX,WORD PTR ES:[BX]                                                 
      ADD   BX,2                                                                
      MOV   SI,l                                             
      MOV   DS,m                                             
      ADD   SI,2                                                                
      FLD   QWORD PTR C                                                         
@MulLoop:                                             
      FLD   QWORD PTR ES:[BX]                                                   
      FMUL  ST,ST(1)                                                            
      FSTP  QWORD PTR DS:[SI]                                                   
      ADD   BX,AX                                                               
      ADD   SI,AX                                                               
      LOOP  @MulLoop                                             
      FSTP  ST(0)                                                               
      POP   DS
    END;
END;


PROCEDURE DivConstant (A, B : VectorTyp; C : DOUBLE);

VAR i, j, k, l, m : WORD;
    p             : PtrParts ABSOLUTE A;
    q             : PtrParts ABSOLUTE B;

BEGIN
    IF (A^.Column = 0) THEN EXIT;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    B^.Column := A^.Column;
    ASM
      PUSH  DS                                                                  
      MOV   AX,i                                                                
      MOV   ES,k                                             
      MOV   BX,j                                                                
      MOV   CX,WORD PTR ES:[BX]                                                 
      ADD   BX,2                                                                
      MOV   SI,l                                             
      MOV   DS,m                                             
      ADD   SI,2                                                                
      FLD   QWORD PTR C                                                         
@DivLoop:                                             
      FLD   QWORD PTR ES:[BX]                                                   
      FDIV  ST,ST(1)                                                            
      FSTP  QWORD PTR DS:[SI]                                                   
      ADD   BX,AX                                                               
      ADD   SI,AX                                                               
      LOOP  @DivLoop                                             
      FSTP  ST(0)                                                               
      POP   DS                                                                  
    END;
END;


PROCEDURE VectorAdd (A, B, C : VectorTyp);

{$IFDEF Deutsch}  
CONST Text = ' Vektor-Addition: ungleiche Vektorlaenge';            
{$ENDIF}
{$IFDEF Englisch} 
CONST Text = ' Addition of vectors: vectors of different lengths'; 
{$ENDIF}

VAR i  : WORD;

BEGIN
    IF (A^.Column <= 0) OR (A^.Column <> B^.Column) or (C^.Column <> A^.Column)
      THEN
         BEGIN
             ch := Windows.Error(text);
             VectorError := TRUE;
             EXIT;
         END;
    FOR i := 1 TO A^.Column DO
       c^.Data[i] := a^.Data[i] + b^.Data[i];
END;


PROCEDURE VectorSub (A, B, C : VectorTyp);

{$IFDEF Deutsch}  
CONST Text = ' Vektor-Subtraktion: ungleiche Vektorlaenge';            
{$ENDIF}
{$IFDEF Englisch} 
CONST Text = ' Subtraction of vectors: vectors of different lengths'; 
{$ENDIF}

VAR i  : WORD;
BEGIN
    IF (A^.Column = 0) OR (B^.Column <> A^.Column) or (C^.Column <> A^.Column)
      THEN
         BEGIN
             ch := Windows.Error(text);
             VectorError := TRUE;
             EXIT;
         END;
    FOR i := 1 TO A^.Column DO
       c^.Data[i] := a^.Data[i] - b^.Data[i];
END;


FUNCTION GSum (Vector : VectorTyp) : DOUBLE;

VAR i, j, k  : WORD;
    p        : PtrParts ABSOLUTE Vector;

BEGIN
    IF (Vector^.Column = 0)
      THEN
         BEGIN
             GSum := 0;
             EXIT;
         END;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    ASM
       MOV   AX,i                                                                  
       MOV   ES,k                                                  
       MOV   BX,j                                                                  
       MOV   CX,WORD PTR ES:[BX]                                                   
       ADD   BX,2                                                                  
       FLDZ                      { 0 into ST(0), serves as accumulator  }
@AddLoop:
       FADD  QWORD PTR ES:[BX]   { add vector element to sum in ST(0) }
       ADD   BX,AX                                                                             
       LOOP  @AddLoop                                                                          
       FSTP  QWORD PTR @Result   { ST(0) is result of this function }
    END;
END;


FUNCTION HarmonicAverage (Vector : VectorTyp) : DOUBLE;

VAR i, j, k, l   : WORD;
    p            : PtrParts ABSOLUTE Vector;
    x            : DOUBLE;

BEGIN
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := Vector^.Column;
    ASM
       MOV   AX,i                                                                  
       MOV   ES,k                                                  
       MOV   BX,j                                                  
       MOV   CX,WORD PTR ES:[BX]                                                   
       ADD   BX,2                                                                  
       FLDZ                                                                        
@MulLoop:
       FLDLN2                    { ST(0) = ln(2) }
       FLD   QWORD PTR ES:[BX]   { Vector element in ST(0)  }
       FYL2X                     { ST(0) = ln(2) * ld(Element) = ln(Element) }
       FADDP ST(1),ST(0)         { add ln(Element) to sum in ST(1) and pop ST(0)}
       ADD   BX,AX                                                                             
       LOOP  @MulLoop                                                                          
       FIDIV l                   { divide by vector length }
       FSTP  x                   { ln(Average) into variable x }
    END;
   HarmonicAverage := exp(x);    { this would be lengthy in Assembler }
END;


FUNCTION VectorAbsolute (Vector : VectorTyp) : DOUBLE;

VAR i, j, k : WORD;
    p       : PtrParts ABSOLUTE Vector;

BEGIN
    IF (Vector^.Column = 0)
      THEN
         BEGIN
             VectorAbsolute := 0;
             EXIT;
         END;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    ASM
      MOV   AX,i                                                     
      MOV   ES,k                                  
      MOV   BX,j                                  
      MOV   CX,WORD PTR ES:[BX]                                      
      ADD   BX,2                                                     
      FLDZ                         { ST(0) = 0 (Sum of squares of elements) }
@MulLoop:
      FLD   QWORD PTR ES:[BX]      { A[j] into ST(0), => Summe into ST(1) }
      FMUL  ST,ST                  { ST(0) = A[j]^2 }
      FADDP ST(1),ST               { Sum into ST(0) }
      ADD   BX,AX                  
      LOOP  @MulLoop
      FSQRT                        { ST(0) := sqrt(ST(0)) }
      FSTP  QWORD PTR @Result      
    END;
END;


FUNCTION VectorInnerProduct (A, B : VectorTyp) : DOUBLE;

{$IFDEF Deutsch}
CONST Text1 = 'Vektor-Error: Inneres Produkt ungleich langer Vektoren';
{$ENDIF}
{$IFDEF Englisch}
CONST Text1 = 'Vector error: Inner Product of vectors of unequal length';
{$ENDIF}

VAR i, j, k, l, m  : WORD;
    p              : PtrParts ABSOLUTE A;
    q              : PtrParts ABSOLUTE B;

BEGIN
    IF (A^.Column = 0)
      THEN
         BEGIN
             VectorInnerProduct := 0;
             EXIT;
         END;
    IF (B^.Column <> A^.Column)
      THEN
         BEGIN
             ch := Windows.Error(Text1);
             VectorError := TRUE;
             EXIT;
         END;
    i := SizeOf(DOUBLE);
    j := p.Ofs;
    k := p.Seg;
    l := q.Ofs;
    m := q.Seg;
    ASM
      PUSH   DS
      MOV    ES,k
      MOV    SI,j
      MOV    CX,WORD PTR ES:[SI];
      ADD    SI,2
      MOV    DS,m
      MOV    DI,l
      ADD    DI,2
      MOV    BX,0
      FLDZ
@AddLoop:
      FLD    QWORD PTR ES:[BX][SI]
      FMUL   QWORD PTR DS:[BX][DI]
      FADDP  ST(1),ST
      ADD    BX,i
      LOOP   @AddLoop
      FSTP   QWORD PTR @Result
      POP    DS
    END;
END;


FUNCTION Angle (A, B : VectorTyp) : DOUBLE;

{$IFDEF Deutsch}
CONST Text1 = 'Vektor-Error: Winkel zwischen Vektoren ungleicher Dimension';
{$ENDIF}
{$IFDEF Englisch}
CONST Text1 = 'Vector error: Angle between vectors of unequal dimension';
{$ENDIF}

BEGIN
    IF (A^.Column = 0) AND (B^.Column = 0) 
      THEN
         BEGIN
             Angle := 0;
             EXIT;
         END;
    IF (A^.Column) <> (B^.Column)
      THEN
         BEGIN
             ch := Windows.Error(Text1);
             VectorError := TRUE;
             EXIT;
         END;
    Angle := MathFunc.ArcCos(VectorInnerProduct(A, B) /
             (VectorAbsolute(A) * VectorAbsolute(B)));
END;


END. { unit vector }


{ This program can be used to test the above units }

PROGRAM VectorTest;

uses crt, windows, mathfunc, vector;

CONST Kurz = 4;

VAR x         : DOUBLE;
    A, B, C   : VectorTyp;
    Fenster   : WindowType;
    Speicher1,
    Speicher2,
    Speicher3 : LONGINT;

BEGIN
    Speicher1 := MemAvail;
    Fenster.TextAtt := 23;
    Fenster.RahmenAtt := 23;
    Fenster.Rahmen := NoFrame;
    Fenster.Titel := '';
    ClrScr;
    InitVector(A, kurz);
    InitVector(B, kurz);
    InitVector(C, kurz);
    Speicher2 := MemAvail;
    LoadConstant(A, 3.0);
    AddConstant(A, B, 4.5);

    VectorAdd(A, B, C);
    VectorXPos := 1;
    WriteVector('CON', A, 9);
    VectorXPos := 15;
    OpenWindowType(VectorXPos, VectorYPos+1, vectorXPos+3, vectorYPos+3, Fenster);
    Write('+');
    VectorXPos := 20;
    WriteVector('CON', B, 9);
    VectorXPos := 34;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorXPos+3, vectorYPos+3, Fenster);
    Write('=');
    VectorXPos := 40;
    WriteVector('CON', C, 9);
    ReadLn;
    WHILE MaxScreen > 0 DO CloseWindow;

    x := VectorInnerProduct(A, B);
    vectorXPos := 1;
    WriteVector('CON', A, 9);
    VectorXPos := 15;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorXPos+3, vectorYPos+3, Fenster);
    Write('*');
    VectorXPos := 20;
    WriteVector('CON', B, 9);
    VectorXPos := 34;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorXPos+3, vectorYPos+3, Fenster);
    Write('=');
    VectorXPos := 40;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorxPos+10, vectoryPos+3, Fenster);
    Write(x:5:1);
    ReadLn;
    WHILE MaxScreen > 0 DO CloseWindow;

    x := GSum(A);
    VectorXPos := 1;
    x := VectorAbsolute(A);
    VectorXPos := 1;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorXPos+8, vectorYPos+3, Fenster);
    Write('Betrag');
    VectorXPos := 11;
    WriteVector('CON', A, 9);
    VectorXPos := 26;
    OpenWindowType(vectorXPos, vectorYPos+1, vectorxPos+15, vectoryPos+3, Fenster);
    Write(' = ', FloatStr(x, 9));
    ReadLn;
    WHILE MaxScreen > 0 DO CloseWindow;

    KillVector(A);
    KillVector(B);
    KillVector(C);
    Speicher3 := MemAvail;
    WriteLn('Original free memory                        ', Speicher1:10, ' Byte');
    WriteLn('Free memory after creation of vectors       ', Speicher2:10, ' Byte');
    WriteLn('Free memory after destruction of vectors:   ', Speicher3:10, ' Byte');
    ReadLn;
END.

