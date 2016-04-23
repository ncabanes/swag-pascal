(*
Re:	Copy of: Submission for SWAG

Here is a unit I have developed for very fast direct screen writes.  
This unit is, unless you know better, the fastest direct direct write 
procedure available.  This is because it is optimised to use word 
size moves on word boundaries where possible. 

It also works in both real and protected modes. 
*)

{$S-}

UNIT FWrite;

INTERFACE

  PROCEDURE FastWrite(Col, Row, Attr : Byte; Str : String);
  {Fast Direct Screen Writes for Real/Protected Mode Programs.    }
  {Note: 'Col' and 'Row' are zero relative, ie:- 0,0 for Top-Left.}

IMPLEMENTATION

USES
  Crt;

  PROCEDURE FastWrite(Col, Row, Attr : Byte; Str : String); ASSEMBLER;
  ASM
    PUSH   DS           {Save DS}
    MOV    DL,CheckSnow {Save CheckSnow Setting}
    MOV    ES,SegB800   {ES = Colour Screen Segment}
    MOV    SI,SegB000   {SI = Mono Screen Segment}
    MOV    DS,Seg0040   {DS = ROM Bios Segment}
    MOV    BX,[49h]     {BL = CRT Mode, BH = ScreenWidth}
    MOV    AL,Row       {AL = Row No}
    MUL    BH           {AX = Row * ScreenWidth}
    XOR    CH,CH        {CH = 0}
    MOV    CL,Col       {CX = Column No}
    ADD    AX,CX        {(Row*ScreenWidth)+Column}
    ADD    AX,AX        {Multiply by 2 (2 Byte per Position)}
    MOV    DI,AX        {DI = Screen Offset}
    CMP    BL,7         {CRT Mode = Mono?}
    JNE    @@DestSet    {No  - Use Colour Screen Segment}
    MOV    ES,SI        {Yes - ES = Mono Screen Segment}
    XOR    DX,DX        {Force jump to FWrite}
  @@DestSet:            {ES:DI = Screen Destination Address}
    LDS    SI,Str       {DS:SI = Source String}
    CLD                 {Move Forward through String}
    LODSB               {Get Length Byte of String}
    MOV    CL,AL        {CX = Input String Length}
    JCXZ   @@Done       {Exit if Null String}
    MOV    AH,Attr      {AH = Attribute}
    OR     DL,DL        {Test Mono/CheckSnow Flag}
    JZ     @@FWrite     {Snow Checking Disabled or Mono - Use FWrite}
{Output during Screen Retrace's}
    MOV    DX,003DAh    {6845 Status Port}
  @@WaitLoop:           {Output during Retrace's}
    MOV    BL,[SI]      {Load Next Character into BL}
    INC    SI           {Update Source Pointer}
    CLI                 {Interrupts off}
  @@Wait1:              {Wait for End of Retrace}
    IN      AL,DX       {Get 6845 status}
    TEST    AL,8        {Vertical Retrace in Progress?}
    JNZ     @@Write     {Yes - Output Next Char}
    SHR     AL,1        {Horizontal Retrace in Progress?}
    JC      @@Wait1     {Yes - Wait until End of Retrace}
  @@Wait2:              {Wait for Start of Next Retrace}
    IN      AL,DX       {Get 6845 status}
    SHR     AL,1        {Horizontal Retrace in Progress?}
    JNC     @@Wait2     {No - Wait until Retrace Starts}
  @@Write:              {Output Char and Attribute}
    MOV     AL,BL       {Put Char to Write into AL}
    STOSW               {Store Character and Attribute}
    STI                 {Interrupts On}
    LOOP   @@WaitLoop   {Repeat for Each Character}
    JMP    @@Done       {Exit}
{Ignore Screen Retrace's}
  @@FWrite:             {Output Ignoring Retrace's}
    TEST   SI,1         {DS:SI an Even Offset?}
    JZ     @@Words      {Yes - Skip (On Even Boundary)}
    LODSB               {Get 1st Char}
    STOSW               {Write 1st Char and Attrib}
    DEC    CX           {Decrement Count}
    JCXZ   @@Done       {Finished if only 1 Char in Str}
  @@Words:              {DS:SI Now on Word Boundary}
    SHR    CX,1         {CX = Char Pairs, Set CF if Odd Byte Left}
    JZ     @@ChkOdd     {Skip if No Pairs to Store}
  @@Loop:               {Loop Outputing 2 Chars per Loop}
    MOV    BH,AH        {BH = Attrib}
    LODSW               {Load 2 Chars}
    XCHG   AH,BH        {AL = 1st Char, AH = Attrib, BH = 2nd Char}
    STOSW               {Store 1st Char and Attrib}
    MOV    AL,BH        {AL = 2nd Char}
    STOSW               {Store 2nd Char and Attrib}
    LOOP   @@Loop       {Repeat for Each Pair of Chars}
  @@ChkOdd:             {Check for Final Char}
    JNC    @@Done       {Skip if No Odd Char to Display}
    LODSB               {Get Last Char}
    STOSW               {Store Last Char and Attribute}
  @@Done:               {Finished}
    POP    DS           {Restore DS}
  END; {FastWrite}

END.

