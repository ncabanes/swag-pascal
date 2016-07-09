(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0018.PAS
  Description: Three ways to Uppercase
  Author: SWAG SUPPORT TEAM
  Date: 05-31-93  07:16
*)

{
Three ways to convert a string to uppercase (without international support).
}

{$R-,S-,I- }

Procedure UpCaseStr0(Var s : String);

Var
  i : Integer;

Begin
  For i := 1 to Length(s) Do
    s[i] := UpCase(s[i]);
end;  { UpCaseStr0 }

Procedure UpCaseStr1(Var s : String);

Var
  i, len : Integer;

Begin
  i := 0;
  len := Ord(s[0]);
  Repeat
    Inc(i);
    If i > len Then
      Break;
    If s[i] in ['a'..'z'] Then
      Dec(s[i], 32);
  Until False;
end;  { UpCaseStr1 }

(*
* Note: this ASM syntax is not allowed in FreePascal
* 

Procedure UpCaseStr2(Var s : String); Assembler;

ASM
        PUSH   DS
        LDS    SI, s
        LES    DI, s
        CLD
        XOR    AH, AH
        LODSB
        STOSB
        XCHG   AX, CX
        JCXZ   @2
@1:     LODSB
        SUB    AL, 'a'
        CMP    AL, 'z'-'a'+1
        SBB    AH, AH
        AND    AH, 'a'-'A'
        SUB    AL, AH
        ADD    AL, 'a'
        STOSB
        LOOP   @1
@2:     POP    DS
end;  { UpCaseStr2 }
*)

(*
   Procedure     Size     Execution timing*
                 (bytes)  (seconds)

   UpCaseStr0    76       4.32      = 1.00
   UpCaseStr1    67       2.76      = 0.63
   UpCaseStr2    39       1.31      = 0.30

   *30,000 times on a 40 MHz 386

Wilbert
*)

var
    s1, s2: string;
begin
    s1 := 'HeLlo';
    UpCaseStr0(s1);
    WriteLn(s1);
    
    s2 := 'HeLlo';
    UpCaseStr1(s2); 
    WriteLn(s2);
end.

