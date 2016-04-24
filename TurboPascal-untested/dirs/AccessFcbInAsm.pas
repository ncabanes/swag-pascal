(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0052.PAS
  Description: Access FCB in ASM
  Author: MARK LEWIS
  Date: 11-22-95  15:49
*)

(*
reread it again and a bit closer this time... it says that DS:DX point
to a FCB (File Control Block) not a filename...

there are two types of FCBs... standard and extended... the sFCB is
37bytes long and the eFCB is 45bytes long... an unopened FCB has only
the drive number, the filename, and the file extension filled in... so
basically, we could start off like this for the sFCB...

  sFCBrec = record
              drivenum  : byte;                   { 0 }
              filename  : array[ 1..8 ] of char;  { 1 - 8 }
              fileext   : array[ 9..11] of char;  { 9 - 11}
              restofFCB : array[12..36] of byte;  {12 - 36}
            end;

and the eFCB looks like this...

  eFCBrec = record
              flagbyte  : byte;                   {-7 }
              reserved  : array[-6..-2] of byte;  {-6 - -2 }
              fattrib   : byte;                   {-1 }
              drivenum  : byte;                   { 0 }
              filename  : array[ 1..8 ] of char;  { 1 - 8 }
              fileext   : array[ 9..11] of char;  { 9 - 11}
              restofFCB : array[12..36] of byte;  {12 - 36}
            end;

sharp eyes will note the array[-6..-2] entry... i don't know (as i've
not tested it in actual compilation) if it'll work like that but the
point is to show that there is an additional 7byte block added to the
*beginning* of the sFCB...

the PSP offers location 5C as the start of a FCB but you can allocate
your own location(s) if you need to work with more than one file FCB at
a time. in any case, the address of the space you allocate for the FCB
is what you put in DS:DX ... maybe something like this...

===== START =====
*)

{ TESTED CODE - FULLY FUNCTIONAL }
{ this is the first FCB code i've done. you'll have to locate the
  structures of the standard FCB and the extended FCB. there's a
  bit much in the books i have on them to type it all in here. as
  this is only a test program, i've only set up for those fields
  i really needed.
}

Program FCB_Test;

type
  DateTime = record
               Year  : word;
               Month : word;
               Day   : word;
               Hour  : word;
               Min   : word;
               Sec   : word;
             end;
  TandD = record
            date : word;
            time : word;
          end;
  sFCBptr = ^sFCBrec;
  sFCBrec = record
              drivenum  : byte;                   { 0 }
              filename  : array[ 1..8 ] of char;  { 1 - 8 }
              fileext   : array[ 9..11] of char;  { 9 - 11}
              partofFCB : array[12..19] of byte;  {12 - 19}
              fDandT    : TandD;                  {20 - 23}
              moreofFCB : array[24..36] of byte;  {24 - 36}
            end;

var
  StdFCB    : sFCBrec; { used only for sizeof function to init fields }
  StdFCBptr : sFCBptr; { points to our Standard FCB on the heap }
  StdFCBseg : word;    { holds segment of our FCB on the heap }
  StdFCBofs : word;    { holds offset of our FCB on the heap }
  success   : boolean; { signals success or failure }
  fileDT    : DateTime;{ holds date and time information }

begin
  { init to failure response }
  success := false;
  { create FCB on the heap }
  new(StdFCBptr);
  { ensure that FCB record has no garbage in it }
  fillchar(StdFCBptr^,sizeof(StdFCB),#0);
  { get segment of our FCB on the heap }
  StdFCBseg := seg(StdFCBptr^);
  { get offset of our FCB on the heap }
  StdFCBofs := ofs(StdFCBptr^);
  { fill in filename. NOTE: use SPACES to fill to 8 chars }
  StdFCBptr^.filename := 'FCB_TEST'; {#84#69#88#84#32#32#32#32;  { 'TEXT    ' }
  { file in file extension. NOTE: use SPACES to fill to three chars }
  StdFCBptr^.fileext  := 'PAS';{#84#88#84;             { 'TXT' }
  { lets do some ASM }
  asm
    { save these regs! }
    push BP
    push SP
    push SS
    push DS
    push DX
    { load OFFSET first!! }
    mov  DX, [StdFCBofs]
    { load SEGMENT second! otherwise you'll loose access to the offset! }
    mov  DS, [StdFCBseg]
    { do something example code here }
      { first, try to open the file }
      mov  AH, $0f
      int  $21
      { check for success or failure }
      cmp  AL, $ff
      { is file opened? }
      jne  @opened
      { move failure signal into AL for later use }
      mov  AL, $00
      { get out of dodge }
      jmp  @notopened
      @opened:
      { move successful signal into AL for later use }
      mov  AL, $01
      @notopened:
      { check AL for success or failure signal }
      cmp  AL, $01
      { if failure, head towards the door }
      jne  @leave
      { close the file }
      mov  AH, $10
      int  $21
      { was close file successful? }
      cmp  AL, $00
      { no, leave AL with failure signal and go closer to door }
      jne  @leave
      @closed:
      { move successful signal into AL for later use }
      mov  al, $01
      { leave this do something example routine }
      @leave:
    { retrieve our regs from the stack }
    pop  DX
    pop  DS
    pop  SS
    pop  SP
    pop  BP
      { move AL success or failure signal into success boolean }
      mov  success, al
  end;
  { show and tell }
  if success then
    begin
      fileDT.year  := 1980 + (StdFCBptr^.fDandT.date AND $fe00) SHR 9;
      fileDT.month := (StdFCBptr^.fDandT.date AND $01e0) SHR 5;
      fileDT.day   := (StdFCBptr^.fDandT.date AND $001f);
      writeln('the file was opened and closed successfully');
      writeln('the file is located on drive ',
              chr(StdFCBptr^.drivenum + ord('@')),':');
      writeln('the date of creation or last update is ',
              fileDT.year,'-',fileDT.month,'-',fileDT.day);
    end
  else
    writeln('Sorry, the file was not located');
  { we're done with our FCB so we can now throw it away... }
  dispose(StdFCBptr);
  { bye bye! }
end.

===== STOP =====

the books i have on them have much more text on the FCBs. too much to
try to post to you... what exactly is it that you are trying to do???
there are much easier methods for most things in this day in time...
it's highly recommended to NOT mess around with FCBs manipulations if
one doesn't really _have_ to...


