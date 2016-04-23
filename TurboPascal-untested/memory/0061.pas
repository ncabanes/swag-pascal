{
Here is some code I use to find out how many stack space is used after a
run. I guess it won't work in protected mode. Be aware
it isn't byte-resolution ! I'd like to hear about enhancements.
}

unit Stack;
interface
  procedure InitStack;
  procedure TestStack;
implementation

(*
Routinen zum Pruefen des Stackbedarfs
Wilfried F?rber, Isar Software GmbH
Ringeisstr. 2a, 8000 Muenchen 2
August 1991

Routinen zum Pruefen, wieviel Stack wirklich benoetigt wird.
Willfried F?rber, Isar Software GmbH, August 1991
Port von C nach Pascal: Jacques NOMSSI NZALI,
email: nomssi@physikus.physik.tu-chemnitz.de
*)
Var STKHQQ : word;

const
  stacktext : packed array[1..4] of char = 'STAC';
  MAXSTACK = (1024 div 4)*64;

function atopsp : Word; assembler;
asm
  mov ax, sp
end;

procedure InitStack;
var
  AktStack,
  Anzahl : Word;
begin
  STKHQQ := StackLimit;
  asm
    mov AktStack, bp
  end;
  Anzahl := (AktStack - STKHQQ) div 4;
  asm
    mov cx, [Anzahl]
    mov di, [STKHQQ]
    mov ax, ss

    mov es, ax
    mov ax, Offset StackText
    @L1:
    mov si, ax
    movsw
    movsw
    loop @L1
  end;
end;

function StackSize : Word;
begin
  StackSize := - STKHQQ + atopsp;
end;

function StackUsed : Word;
var
  StackFrei,
  StackMax : Word;
Begin
  StackMax := StackSize;
  asm
    mov cx, MAXSTACK
    mov di, [STKHQQ]
    mov ax, ss

    mov es, ax
    mov ax, Offset Stacktext
  @L1:
    mov si, ax
    cmpsw
    jnz @L2
    cmpsw
    loope @L1
  @L2:
    sub cx, MAXSTACK
    not cx
    mov [StackFrei], cx
  end;
  StackFrei := StackFrei*4;
  StackUsed := StackMax - StackFrei;
end;

procedure TestStack;
var
  StackVerb, _MaxStack : Word;
begin
  _MaxStack := StackSize;
  StackVerb := StackUsed;
  WriteLn('STACK-VERBRAUCHSTEST ---------------------- ');
  WriteLn('Programmstack :', _MaxStack);
  WriteLn('Es wurden ca. ',StackVerb,' Bytes benoetigt.');
  WriteLn('Stack-Reserve :',MaxStack-StackVerb,' Bytes.');
  ReadLn;
end;

begin
  InitStack;
end.
