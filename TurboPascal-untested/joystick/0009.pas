{
The basic approach to reading a joystick is to monitor port 201h.  The eight
bits at that port correspond to:

01h - Joystick A, "X" position
02h - Joystick A, "Y" position
04h - Joystick B, "X" position
08h - Joystick B, "Y" position
10h - Joystick A, button 1
20h - Joystick A, button 2
40h - Joystick B, button 1
80h - Joystick B, button 2

The buttons are easy: a bit of "0" means "pressed" and "1" means "not
pressed".  But a single bit to read a joystick position?!?  Here's what
you do:

1)  Write a value -- any value -- to port 201h.  The four lowest bits
    will then all assume a value of "1".

2)  Start a counter, and see how many iterations it takes for your
    desired bit to go to zero.  The number of iterations = the joystick
    position, with lower values corresponding to "left" or "up" and
    higher values corresponding to "right" or "down".

Like any joystick code, thess routines return the button statuses and the
joystick positions.  They also return boolean indicators of whether the
stick is left or right, up or down, based on a sensitivity you define.

The routines you call are:

procedure calibrate(r: real) -- Call this at the beginning of your program.
                                Determines presence of joysticks and how
                                far the stick has to be moved to constitute
                                L/R/U/D.  "r" is a real value from 0 to 1;
                                a value of 0.25 means that the stick has to
                                move 25% from center to count as L/R/U/D.
procedure readsticks         -- Reads sticks and buttons.  Call this once
                                every round of play or whatever.

THE CODE:
{--------------------------------------------------------------------------}
unit joystick;

interface

var jax, jay, jbx, jby: word;                 { Joystick positions }
    ja1, ja2, jaleft, jaright, jaup, jadown,  { JA1, JA2, JB1, JB2 = buttons }
    jb1, jb2, jbleft, jbright, jbup, jbdown,  { GotJoystickA/B record which }
    gotjoysticka, gotjoystickb: boolean;      {   joysticks are present }

   { lefts, rights, ups, downs are determined when the joysticks are read:
       if the stick is sufficiently off-center, L, R, U, and/or D will be
       flagged appropriately }

procedure readsticks;                         { reads joysticks }
procedure calibrate(offcenterthresh: real);   { determines what stick values
                                                  constitute L/R/U/D }
{--------------------------------------------------------------------------}
implementation

var jal, jar, jau, jad, jbl, jbr, jbu, jbd: word;   { thresholds for L/R/U/D }
{--------------------------------------------------------------------------}
procedure calibrate(offcenterthresh: real);   { get base figures for sticks }
begin
  gotjoysticka := true;                       { initially assume both sticks }
  gotjoystickb := true;                       {   are present }
  readsticks;                                 { get stick positions }
  gotjoysticka := (jax > 0) or (jay > 0);     { if joystick reads as position }
  gotjoystickb := (jbx > 0) or (jby > 0);     {   (0,0), it doesn't exist }
  jal := round(jax*(1 - offcenterthresh));    { OFFCENTERTHRESH is a real }
  jar := round(jax*(1 + offcenterthresh));    {   from 0 to 1 that tells the }
  jau := round(jay*(1 - offcenterthresh));    {   system how far off-center }
  jad := round(jay*(1 + offcenterthresh));    {   the stick has to be to get }
  jbl := round(jbx*(1 - offcenterthresh));    {   counted as L/R/U/D.  For }
  jbr := round(jbx*(1 + offcenterthresh));    {   example, a value of "0.25" }
  jbu := round(jby*(1 - offcenterthresh));    {   means the stick has to be }
  jbd := round(jby*(1 + offcenterthresh));    {   25% below base to be L / U, }
  end;                                        {   or 25% above to be R / D. }

procedure readsticks;                       { Reads sticks & buttons. }
var gotax, gotay, gotbx, gotby: boolean;    { whether we have a stick value }
    cnter: word;                            { just a counter }
begin
  if gotjoysticka or gotjoystickb then begin  { if no sticks, skip reading them }
    ja1 := (port[$201] and $10) = 0;          { read the buttons }
    ja2 := (port[$201] and $20) = 0;
    jb1 := (port[$201] and $40) = 0;
    jb2 := (port[$201] and $80) = 0;
    gotax := not gotjoysticka;              { Flags: do we have values yet? }
    gotay := not gotjoysticka;              { Set to "true" for nonexistent }
    gotbx := not gotjoystickb;              {   stick -- no need to give    }
    gotby := not gotjoystickb;              {   them a second thought }
    jax := 0;                               { set actual stick positions to }
    jay := 0;                               {   zero -- on "existing" sticks }
    jbx := 0;                               {   the number will increase }
    jby := 0;
    asm
      mov  cx, 0000h   { set counter to zero }
      mov  al, 0fh     { AL contains "new" port value (initialized to 0fh) }
      mov  ah, al      { AH contains "old" port value (initialized to 0fh) }
      mov  dx, 0201h   { load up joystick port }
      out  dx, al      { "prime" joystick port by writing 0fh to it }
      @beginloop:      { the stick-reading loop }

      in   al, dx      { read joystick port }
      and  al, 0fh     { "and" it with 0fh to "eliminate" the button bits }
      cmp  al, ah      { compare to the "old" port value }
      je   @endloop    { if no change, skip past position checking }

      @chkax:          { checking "X" value on joystick "A" }
      cmp  gotax, 01h  { see if "gotax" equals 1: if so, we've already got }
      je   @chkay      {   a reading on it, and skip to "ay" readings }
      test al, 01h     { if first bit of BL is a 1: if so, we don't have a }
      jnz  @chkay      {   value for "ax", so jump over to "ay" }
      mov  gotax, 01h  { set boolean "gotax" to "true" }
      mov  jax, cx     { record counter value }

      @chkay:          { checking "Y" value on joystick "A" }
      cmp  gotay, 01h
      je   @chkbx
      test al, 02h
      jnz  @chkbx
      mov  gotay, 01h
      mov  jay, cx

      @chkbx:          { checking "X" value on joystick "B" }
      cmp  gotbx, 01h
      je   @chkby
      test al, 04h
      jnz  @chkby
      mov  gotbx, 01h
      mov  jbx, cx

      @chkby:          { checking "Y" value on joystick "B" }
      cmp  gotby, 01h
      je   @endloop
      test al, 08h
      jnz  @endloop
      mov  gotby, 01h
      mov  jby, cx

      @endloop:        { counter increments and data-evaluating }
      mov  ah, al      { store "new" port value as "old" value for next pass }
      inc  cx          { increment counter }
      cmp  cx, 65535   { compare counter to 65535 }
      je   @ending     { if counter = 65535, get out of loop }
      cmp  gotax, 01h  { see if we have a value for "ax"; }
      jne  @beginloop  {   if not, jump to top of loop for another pass }
      cmp  gotay, 01h  { check "ay" }
      jne  @beginloop
      cmp  gotbx, 01h  { check "bx" }
      jne  @beginloop
      cmp  gotby, 01h  { check "by" }
      jne  @beginloop
      @ending:         { we're past the end of the loop }
      mov  cnter,cx    { store counter value into "Pascal" variable }
      end;
    end;
  jaleft := (jax < jal);  jaright := (jax > jar);  { determine L/R/U/D }
  jaup   := (jay < jau);  jadown  := (jay > jad);
  jbleft := (jbx < jbl);  jbright := (jbx > jbr);
  jbup   := (jby < jbu);  jbdown  := (jby > jbd);
  end;
{--------------------------------------------------------------------------}
  end.
