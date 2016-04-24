(*
  Category: SWAG Title: STRING HANDLING ROUTINES
  Original name: 0127.PAS
  Description: Fast String Add Functions
  Author: JOEL LICHTENWALNER
  Date: 05-31-96  09:17
*)

{
    The below listed program tests representives of the various methods
available.  The third method does not check for overflow, but is about 3.0
times faster than those presented so far by my bench mark test.
                           Joel Lichtenwalner in Ogden Utah.

RESULTS (TURBO7 USING [Don't laugh] 386DX 25):
  Test concatenation functions
  Testing Pascal's "+" function Performance = 131.100000 Loops per tick
  Testing STRCONT function Performance = 129.466667 Loops per tick
  Testing ATTACH procedure  Performance = 394.900000 Loops per tick
}
{$A+,N+,R-,S+,V-,X+,Y+}
{$M 16384,0,655360}
PROGRAM TEST_CONCAT;  { TESTS VARIOUS METHODS OF CONCATENATING STRINGS }
  USES
    CRT;
  CONST
    ADD_STR     : STRING[22] = 'Test string 1234567890';
    TICKS       = 90;           { LOOP FOR APPROX 5 SECONDS }
  VAR
    CLOCK_TICKS : WORD ABSOLUTE $40:$6C;  { Updated every 58 ms by system }
    TIME_SAVE   : WORD;         { Variable used to keep track of time     }
    LOOPS       : LONGINT;      { Loop control counter                    }
    TARG        : STRING[255];  { Target string, to be added too          }
    COMPUTE     : EXTENDED;

  function strcont(s1,s2:string):string; assembler;
    asm
      push ds
      cld
      lds si,s1         {Load addresses of s1}
      les di,s2         {Load addresses of s2}
      xor ah,ah         {Clear ah & bh}
      xor bh,bh         {     ""      }
      mov al,ds:[si]    {Get the length of first string, copy into al}
      mov bl,es:[di]    {Get the length of second string, copy into bl}
      add ax,bx         {Add length of s1 to length s2}
      cmp ax,255        {Compare}
      ja @toolarge      {Jump to @toolarge if length(s1)+length(s2)>255}
      les di,@result    {Copy location of @result into es:di}
      mov cl,1          {Make sure at least one byte of beginning string}
      xor ch,ch         {is transferred to @result.}
      add cl,ds:[si]    {Add length of string to cl.}
      rep movsb         {Copy first string into @result}
      lds si,s2         {Get address of second string}
      mov cl,ds:[si]    {Get length of second string, copy into cl}
      cmp cl,0          {If second string is blank, skip adding it.}
      je @end           {Jump to end if length of second string is zero.}
      inc si            {Move pointer (si) to start of second string}
      mov al,cl         {Save length of second string in al}
      rep movsb         {Copy second string into @result}
      lds si,@result    {Get location of @result}
      add ds:[si],al    {Add lengths together}
      jmp @end          {Skip to end}
     @toolarge:         {If added strings total larger than 255, this sub}
      les di,@result    {is called.}
      xor al,al         {Make sure al is a zero.}
      mov es:[di],al    {Move a "0" into the beginning of @result, making it}
     @end:              {a null string.}
      pop ds            {Return DS to normal so Pascal doesn't screw up.}
      end;
  PROCEDURE ATTACH(VAR DEST,SOURCE:STRING);
    VAR
      DESTL   : BYTE ABSOLUTE DEST;
      SOURCEL : BYTE ABSOLUTE SOURCE;
    BEGIN
      MOVE(SOURCE[1],DEST[SUCC(DESTL)],SOURCEL);
      INC(DESTL,SOURCEL);
      END;
  BEGIN
    CLRSCR;  WRITELN('Test concatenation functions');
    { -------- FIRST TEST -------- }
    WRITE('Testing Pascal''s "+" function');
    LOOPS := 0;
    TIME_SAVE := CLOCK_TICKS;    { WAIT UNTIL THE CLOCK TURNS OVER }
    REPEAT UNTIL CLOCK_TICKS <> TIME_SAVE;
    TIME_SAVE := CLOCK_TICKS + TICKS;  { Set loop time }
      REPEAT
      TARG := '';
      TARG := TARG + ADD_STR;  {  22 }
      TARG := TARG + ADD_STR;  {  44 }
      TARG := TARG + ADD_STR;  {  66 }
      TARG := TARG + ADD_STR;  {  88 }
      TARG := TARG + ADD_STR;  { 110 }
      TARG := TARG + TARG;     { 220 }
      TARG := TARG + ADD_STR;  { 242 }
      INC(LOOPS);
      UNTIL CLOCK_TICKS = TIME_SAVE;
    COMPUTE := LOOPS;
    COMPUTE := COMPUTE / TICKS;
    WRITELN(' Performance = ',COMPUTE:0:6,' Loops per tick');
    { -------- SECOND TEST -------- }
    WRITE('Testing STRCONT function');
    LOOPS := 0;
    TIME_SAVE := CLOCK_TICKS;    { WAIT UNTIL THE CLOCK TURNS OVER }
    REPEAT UNTIL CLOCK_TICKS <> TIME_SAVE;
    TIME_SAVE := CLOCK_TICKS + TICKS;  { Set loop time }
      REPEAT
      TARG := '';
      TARG := strcont(TARG,ADD_STR);  {  22 }
      TARG := strcont(TARG,ADD_STR);  {  44 }
      TARG := strcont(TARG,ADD_STR);  {  66 }
      TARG := strcont(TARG,ADD_STR);  {  88 }
      TARG := strcont(TARG,ADD_STR);  { 110 }
      TARG := strcont(TARG,TARG);     { 220 }
      TARG := strcont(TARG,ADD_STR);  { 242 }
      INC(LOOPS);
      UNTIL CLOCK_TICKS = TIME_SAVE;
    COMPUTE := LOOPS; COMPUTE := COMPUTE / TICKS;
    WRITELN(' Performance = ',COMPUTE:0:6,' Loops per tick');
    { -------- THIRD TEST -------- }
    WRITE('Testing ATTACH procedure ');
    LOOPS := 0;
    TIME_SAVE := CLOCK_TICKS;    { WAIT UNTIL THE CLOCK TURNS OVER }
    REPEAT UNTIL CLOCK_TICKS <> TIME_SAVE;
    TIME_SAVE := CLOCK_TICKS + TICKS;  { Set loop time }
      REPEAT
      TARG := '';
      ATTACH(TARG,ADD_STR);  {  22 }
      ATTACH(TARG,ADD_STR);  {  44 }
      ATTACH(TARG,ADD_STR);  {  66 }
      ATTACH(TARG,ADD_STR);  {  88 }
      ATTACH(TARG,ADD_STR);  { 110 }
      ATTACH(TARG,TARG);     { 220 }
      ATTACH(TARG,ADD_STR);  { 242 }
      INC(LOOPS);
      UNTIL CLOCK_TICKS = TIME_SAVE;
    COMPUTE := LOOPS; COMPUTE := COMPUTE / TICKS;
    WRITELN(' Performance = ',COMPUTE:0:6,' Loops per tick');
    READLN;
    END.


