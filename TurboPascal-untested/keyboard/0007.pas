{
>     I need help on reading the keyboard in a specific way, I need to
> read it as a whole not a key at a time. I need to do this for
> the games I make, I have to ba able to hold down one key to
> perform a Function and then hold down another key and scan both
> keys at the same time but to perform 2 different Functions. For
> instance, if I hold down the left arrow key to make a Character
> run I should be able to hold down the space bar to make him
> fire a gun at the same time.
>     I would Really appreciate any help anyone could give me With this.

Grab this (TWOKEYS.PAS) and the next 2 messages (KEYINTR.PAS and POLL.PAS).
}

Program TwoKeys;

Uses
  Crt, Poll ;  { polled keyboard handler }

{ ----- this Program will probably hang a debugger ----- }

Var
  X, Y : Byte ;

begin
  ClrScr ;
  X := 40 ;
  Y := 12 ;

  WriteLn( 'Hit keys A S  and  1 2 on the keypad' ) ;
  WriteLn( ' -- Esc to stop' ) ;

  While not KeyTable[ EscKey ] do
  begin
    GotoXY( X, Y ) ;
    Write( ' ' ) ;

    { poll the KeyTable }
    If KeyTable[ endKey ] and ( X > 1 ) then  Dec( X ) ;
    If KeyTable[ DownKey ] and ( X < 80 ) then  Inc( X ) ;
    If KeyTable[ aKey ] and ( Y > 4 ) then  Dec( Y ) ;
    If KeyTable[ sKey ] and ( Y < 24 ) then  Inc( Y ) ;

    GotoXY( X, Y ) ;
    Write( chr( 1 ) ) ;
    Delay( 10 ) ;
  end ;
end.




Unit KeyIntr ;  { support For INT 09 routines }

Interface

Procedure CLI ; Inline( $FA ) ; { disable interrupts }
Procedure STI ; Inline( $FB ) ; { enable interrupts }

{ cannot be used outside an interrupt Procedure }
Procedure JumpInterrupt( p : Pointer ) ;
Inline(
  $5B/$58/                         { POP  BX, AX   AX:BX = p }
  $89/$EC/                         { MOV  SP, BP             }
  $87/$46/$10/                     { XCHG AX, [BP+10H]       }
  $87/$5E/$0E/                     { XCHG BX, [BP+0EH]       }
  $5D/$07/$1F/$5F/$5E/             { POP  BP, ES, DS, DI, SI }
  $5A/$59/                         { POP  DX, CX             }
  $FA/                             { CLI                     }
  $CB ) ;                          { RETF          jmp far p }


Function Control_Pressed : Boolean ;

Procedure EOI ;
{ end of interrupt to 8259 }

Function ReadScanCode : Byte ;
{ read keyboard }

Procedure ResetKeyboard ;
{ prepare For next key }

Procedure StoreKey( Scan, Key : Byte );
{ put key in buffer For INT 16 }


Implementation

Uses
  Crt ;  { Sound, NoSound }

Type
  Address = Record                  { used in Pointer manipulation }
    Offset : Word ;
    Segment : Word ;
  end ;
Const
  BiosDataSegment = $40 ;

Var
  KeyState       : Word Absolute BiosDataSegment:$0017 ;
  KeyBufferHead  : Word Absolute BiosDataSegment:$001A ;
  KeyBufferTail  : Word Absolute BiosDataSegment:$001C ;
  KeyBufferStart : Word Absolute BiosDataSegment:$0080 ;
  KeyBufferend   : Word Absolute BiosDataSegment:$0082 ;


Function Control_Pressed : Boolean ;
begin
  Control_Pressed := ( KeyState and  4 ) = 4 ;
end;

Procedure EOI ;
{ end of interrupt to 8259 interrupt controller }
begin
  CLI ;
  Port[$20] := $20 ;
end ;

Function ReadScanCode : Byte ;
begin
  ReadScanCode := Port[$60] ;
end ;

Procedure ResetKeyboard ;
{ prepare For next key }
Var
  N : Byte ;
begin
  N := Port[$61] ;
  Port[$61] := ( N or $80 ) ;
  Port[$61] := N ;
end ;

Procedure StoreKey( Scan, Key : Byte ) ;
Var
{ put key in buffer that INT 16 reads }
  P : ^Word ;
  N : Word ;
begin
  address(P).segment := BiosDataSegment ;
  N := KeyBufferTail ;
  address(P).offset := N ;
  Inc( N, 2 ) ;                      { advance Pointer two Bytes }
  If( N = KeyBufferend ) then        { end of the circular buffer }
     N := KeyBufferStart ;
  If( N = KeyBufferHead ) then       { buffer full }
  begin
    EOI ;               { EOI must be done before Exit            }
    Sound( 2200 ) ;     {    but before anything that takes a lot }
    Delay( 80 ) ;       {     of time and can be interrupted      }
    NoSound ;
  end
  Else
  begin          { high Byte is scan code, low is ASCII }
    P^ := Scan * $100 + Key ;       { store key in circular buffer }
    KeyBufferTail := N ;            { advance tail Pointer }
    EOI ;
  end ;
end ;

end.




Unit POLL ;         { polled keyboard handler }
                    { does not support F11 or F12 keys } Interface

Const
  EscKey = 1 ;    { key codes }
  aKey = 30 ;
  sKey = 31 ;
  endKey = 79 ;
  DownKey = 80 ;

Var
  KeyTable : Array[ 1..127 ] of Boolean ;

{ KeyTable[ x ] is True when key x is pressed and stays True Until key
  x is released }


Implementation

Uses
  Dos, KeyIntr ;  { keyboard interrupt support }

Var
  OldInt09 : Pointer ;
  ExitSave : Pointer ;

Procedure RestoreInt09 ; Far;
begin
  ExitProc := ExitSave ;
  SetIntVec( $09, OldInt09 ) ;
end ;

Procedure NewInt09 ; interrupt ; Far;
Var
  ScanCode : Byte ;
  KeyCode : Byte ;
begin
  STI ;
  ScanCode := ReadScanCode ;
  KeyCode := ScanCode and $7F ;        { strip make/break bit }
  KeyTable[ KeyCode ] := ( ScanCode and $80 ) = 0 ;
  ResetKeyboard ;
  EOI ;
end ;

Var
  N : Byte ;

begin
  ExitSave := ExitProc ;
  ExitProc := addr( RestoreInt09 ) ;

  For N := 1 to 127 do   { no key pressed }
    KeyTable[ N ] := False ;

  GetIntVec( $09, OldInt09 ) ;
  SetIntVec( $09, addr( NewInt09 ) ) ;
end.
