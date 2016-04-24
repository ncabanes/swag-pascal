(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0003.PAS
  Description: EGA/VGA Bitmap FONTS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
>I need to Write some Pascal code For a PC that will allow Text mode
>fonts to be changed (at least on PC's With VGA adapters).

>Prof. Salmi's FAQ lists a book by Porter and Floyd, "Stretching
>Turbo Pascal", as having the relevant information, but my local
>bookstore claims this is out of print.

You could try borrowing the book from the library.  For instance ours
will search For books; I rarely buy books.  STP:v5.5 was an exception.
Here is code (substantially based on Porter and Floyds' code) written
for version 5.x .  Actually, aside from this stuff, the book wasn't as
good as I thought it would be.  I believe Ken Porter died and parts of
the book seem missing.  This code, For instance, isn't well documented
in the book (althought I think its clear how to use it from these
Programs).

You know, after playing With this code I thought I knew it all :D
It turns out that there is a lot more you can do.  For instance, the
intensity bit can be used as an extra Character bit to allow
512-Character fonts.  I have an aging PC Magazine article (that I
haven't gotten around to playing with) that has some Asm code For the
EGA.  (I'm hoping the same code will work For the VGA).
}
{--[rounded.pas]--}

Program
  Rounded;
Uses
  Crt, BitFonts;

Type
  matrix = Array[0..15] of Byte;

Const
  URC : matrix = ($00,$00,$00,$00,$00,$00,$00,$C0,$70,$30,$18,$18,$18,$18,$18,$18);
  LLC : matrix = ($18,$18,$18,$18,$0C,$0E,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00);
  LRC : matrix = ($18,$18,$18,$18,$30,$70,$C0,$00,$00,$00,$00,$00,$00,$00,$00,$00);
  ULC : matrix = ($00,$00,$00,$00,$00,$00,$00,$03,$0E,$0C,$18,$18,$18,$18,$18,$18);
{  ULC : matrix = ($00,$00,$00,$00,$00,$03,$0E,$19,$33,$36,$36,$36,$36,$36,$36,$36);}
Var
  index,b      : Word;
  package      : fontPackagePtr;
  FontFile     : File of FontPackage;
  EntryFont    : ROMfont;

  Procedure TextBox( left, top, right, bottom, style : Integer );
    Const
      bord : Array[1..2,0..5] of Char = ( ( #196,#179,#218,#191,#217,#192 ),
                                          ( #205,#186,#201,#187,#188,#200 ));
    Var P:Integer;

    begin
      if Style = 0 then Exit; { what the fuck is this For ? }

      { verify coordinates are in ( NW,SE ) corner }
      if left > right then
        begin
          p := left; left := right; right := p;
        end;
      if bottom < top then
        begin
          p := top; top := bottom; bottom := p;
        end;

      { draw top }
      GotoXY( left,top );
      Write( bord[style,2] );
      For p := left+1 to right-1 do
        Write( bord[style,0]);
      Write( bord[style,3] );

      { draw bottomm }
      GotoXY( left,bottom );
      Write( bord[style,5]);
      For p := left+1 to right-1 do
        Write( bord[style,0]);
      Write( bord[style,4]);

      { draw sides }
      For p := top+1 to bottom-1 do
        begin
          GotoXY( left,p );
          Write( bord[style,1] );
          GotoXY( right,p );
          Write( bord[style,1] );
        end;
    end; { Procedure TextBox }

  Procedure replace( ASCII:Word; newChar:matrix );
    Var offset,b:Word;
    begin
      offset := ASCII * VDA.points;
      For b := 0 to VDA.points-1 do
        package^.ch[offset+b] := newChar[b];
    end;

begin
  if not isEGA then
    begin
      Writeln( 'You can only run this Program on EGA or VGA systems' );
      halt( 1 );
    end;
  {- fetch copy of entry font -}
  EntryFont := CurrentFont;
  Package := FetchHardwareFont( CurrentFont );

  {- replace the corner Characters -}
  replace( 191,URC );
  replace( 192,LLC );
  replace( 217,LRC );
  replace( 218,ULC );

  {- load and active user-modified font -}
  Sound( 1000 );
  LoadUserFont( package );
  NoSound;

  {- Draw a Text box -}
  ClrScr;
{  CursorOff; }
  TextBox( 20,5,60,20,1 );
  GotoXY( 33,12 ); Write( 'rounded corners' );
{  WaitForKey;}
  readln;

  {- save user-modified font to File -}
  assign( FontFile, 'HELLO' );
  reWrite( FontFile );
  Write( FontFile,Package^ );
  close( FontFile );

  {- clear and quit -}
  SetHardWareFont( EntryFont );
  ClrScr;
{  CursorOn;}

end.

{--[editfnt2.pas]--}

Program EditFont;

Uses Crt, Dos, BitFonts;

Const
  Block = #220;
  Esc = #27;
Var
  c,
  Choice : Char;
  EditDone,
  Done,
  Valid  : Boolean;
  Font   : ROMfont;
  package : FontPackagePtr;
  fout : File of FontPackage;
  foutfil : String;

Function UpperCase( s:String ): String;
  Var i:Byte;
  begin
    For i := 1 to length( s ) do
      s[i] := UpCase( s[i] );
    UpperCase := s;
  end;


Function HexByte( b:Byte ):String;
  Const DIGIT : Array[0..15] of Char = '0123456789ABCDEF';
  begin
    HexByte := Digit[b SHR 4] + Digit[b and $0F];
  end;


Function ByteBin( Var bs:String ):Byte;
  Const DIGIT : Array[0..15] of Char = '0123456789ABCDEF';
  Var i,b:Byte;
  begin
    b := 0;
    For i := 2 to length( bs ) do
      if bs[i] = '1' then
        b := b + 2 SHL (i-1);
    if bs[1] = '1' then
      b := b + 1;
    ByteBin := b;
  end;


Procedure Browse( Font:ROMfont );

{
    arrow keys to manuever
    Esc to accept
    Enter or space to toggle bit
    C or c to clear a row
    alt-C or ctl-C to clear whole Char

}
  Const
    MapRow = ' - - - - - - - - ';
    MapTop = 7;

  Var
    ASCII,
    row,
    col,
    index,
    bit   : Word;
    f     : Char_table;
    s     : String;
    error : Integer;

  Procedure putChar( value:Word );
    Var reg:Registers;
    begin
      reg.AH := $0A;
      reg.AL := Byte( value );
      reg.BH := 0;
      reg.BL := LightGray;
      reg.CX := 1;
      intr( $10,reg );
      GotoXY( WhereX+1, WhereY );
    end; { proc putChar }

  begin
    GetMem( Package, SizeOf( Package^ ));
    ClrScr;
    Package := FetchHardwareFont( Font );
    Repeat
      GotoXY( 1,1 );
      Write( 'FONT: ' );
      Case Font of
        ROM8x8  : Writeln( '8 x 8' );
        ROM8x14 : Writeln( '8 x 14' );
        ROM8x16 : Writeln( '8 x 16' );
      end;
      Writeln;
      clreol;
      Write( 'ASCII value to examine? (or QUIT to quit) ' );
      readln( s );
      Val( s,ASCII,error );
      if error <> 0 then
        if UpperCase( s ) = 'QUIT' then
          Done := True
        else
          ASCII := Byte( s[1] );

      { show the Character image }
      clreol;
      Write( '(Image For ASCII ',ASCII,' is ' );
      putChar( ASCII );
      Writeln( ')' );

      { display blank bitmap }
      GotoXY( 1,MapTop );
      For row := 1 to Package^.FontInfo.points do
        Writeln( maprow );

      { explode the image bitmap }
      index := Package^.FontInfo.points * ASCII;
      For row := 0 to Package^.FontInfo.points-1 do
        begin
          For bit := 0 to 7 do
            if (( Package^.Ch[index] SHR bit ) and 1 ) = 1 then
              begin
                col := ( 8 - bit ) * 2;
                GotoXY( col,row+MapTop );
                Write( block );
              end;
          GotoXY( 20,row+MapTop );
          Write( hexByte( Package^.Ch[index] )+ 'h' );
          inc( index );
        end;


      { edit font }
      col := 2;
      row := MapTop;
      EditDone := False;
      index := Package^.FontInfo.points * ASCII;

      While ( not Done ) and ( not EditDone ) do
        begin
          GotoXY( col,row );
          c := ReadKey;
          if c = #0 then
            c := ReadKey;

          Case c of

            #03,         { wipe entire letter }
            #46 : begin
                    index := Package^.FontInfo.points * ASCII;
                    For row := MapTop to MapTop+Package^.FontInfo.points-1 do
                      begin
                        Package^.Ch[index] := 0;
                        col := 2;
                        GotoXY( col,row );
                        Write( '- - - - - - -' );
                        GotoXY( 20,row );
                        Write( hexByte( Package^.Ch[index] )+ 'h' );
                        GotoXY( col,row );
                        inc( index );
                      end;
                  end;

            'C',         { wipe row }
            'c' : begin
                    Package^.Ch[index] := 0;
                    col := 2;
                    GotoXY( col,row );
                    Write( '- - - - - - -' );
                    GotoXY( 20,row );
                    Write( hexByte( Package^.Ch[index] )+ 'h' );
                    GotoXY( col,row );
                  end;


            #27 : EditDone := True;  { esc }

            #72 : begin  { up }
                    if row >  MapTop then
                      begin
                        dec( row );
                        dec( index );
                      end;
                  end;

            #80 : begin  { down }
                    if row < ( MapTop + Package^.FontInfo.points - 1 ) then
                      begin
                        inc( row );
                        inc( index );
                      end;
                  end;

            #77 : begin  { right }
                    if col < 16 then
                      inc( col,2 );
                  end;

            #75 : begin  { left }
                    if col > 3 then
                      dec( col,2 );
                  end;

            #13,
            #10,
            ' ' : begin
                    bit := 8 - ( col div 2 );
                    if (( Package^.Ch[index] SHR bit ) and 1 ) = 1 then
                      begin
                        Package^.Ch[index] := ( Package^.Ch[index] ) AND
                                               ($FF xor ( 1 SHL bit ));
                        Write( '-' )
                      end
                    else
                      begin
                        Package^.Ch[index] := Package^.Ch[index] XOR
                                              ( 1 SHL bit );
                        Write( block );
                      end;

                    GotoXY( 20,row );
                    Write( hexByte( Package^.Ch[index] )+ 'h' );
                    GotoXY( col,row );
                  end;

          end; { Case }

          LoadUserFont( Package );

        end; { While }

    Until Done;

    GotoXY( 40,7 );
    Write( 'Save to disk? (Y/n) ');
    Repeat
      c := UpCase( ReadKey );
    Until c in ['Y','N',#13];
    if c = #13 then
      c := 'Y';
    Write( c );

    if c = 'Y' then
      begin
        GotoXY( 40,9 );
        ClrEol;
        Write( 'Save as: ');
        readln( foutfil );

(*        if fexist( foutfil ) then
          begin
            GotoXY( 40,7 );
            Write( 'OverWrite File ''',foutfil,''' (y/N) ');
            Repeat
              c := UpCase( ReadKey );
            Until c in ['Y','N',#13];
            if c = #13 then
              c := 'N';
            Write( c );
          end;
*)
        {$I-}
        assign( fout,foutfil ); reWrite( fout );
        Write( fout,Package^ );
        close( fout );
        {$I+}
        GotoXY( 40,11 );
        if ioResult <> 0 then
          Writeln( 'Write failed!' )
        else
          Writeln( 'Wrote font to File ''',foutfil,'''.' );
      end;


  end; { proc Browse }


begin

  Done := False;
  { get font to view }
  Repeat
    Valid := False;
    Repeat
      ClrScr;
      Writeln( 'Fonts available For examination: ' );
      Writeln( '    1. 8 x 8' );
      if isEGA then

        Writeln( '    2. 8 x 14' );
      if isVGA then
        Writeln( '    3. 8 x 16' );
      Writeln;
      Write( '    Select by number (or Esc to quit) ' );
      choice := ReadKey;
      if Choice = Esc then
        begin
          ClrScr;
          Exit;
        end;
      if Choice = '1' then Valid := True;
      if ( choice = '2' ) and isEGA then Valid := True;
      if ( Choice = '3' ) and isVGA then Valid := True;
    Until Valid;

    { fetch and display selected font }
    Case choice of
      '1' : Font := ROM8x8;
      '2' : Font := ROM8x14;
      '3' : Font := ROM8x16;
    end;
    Browse( font );
  Until Done;
  GotoXY( 80,25 );
  Writeln;
  Writeln( 'Thanks you For using EditFont which is based on code from' );
  Writeln( '_Stretching Turbo Pascal_ by Kent Porter and Mike Floyd.' );
  Writeln;
  Writeln( 'This Program was developed 12 Apr 92 by Alan D. Mead.' );
end.

{--[bitfonts.pas]--}


Unit BitFonts;
  { support For bit-mapped Text fonts on EGA/VGA }

Interface

Type
              { enumeration of ROM hardware fonts }
  ROMfont = ( ROM8x14, ROM8x8, ROM8x16 );

              { Characetr definition table }
  CharDefTable = Array[0..4095] of Byte;
  CharDefPtr   = ^CharDefTable;

              { For geting Text Character generators }
  Char_table = Record
                 points : Byte;       { Char matrix height }
                 def    : CharDefPtr; { address of table }
               end;

              { font format }
  FontPackage = Record
                  FontInfo : Char_Table;
                  ch       : CharDefTable;
                end;
  FontPackagePtr = ^FontPackage;

              { table maintained by video ROM BIOS at 40h : 84h }
  VideoDataArea = Record
                    rows   : Byte;  { Text rows on screem - 1 }
                    points : Word;    { height of Char matrix }
                    info,               { EGA/VGA status info }
                    info_3,           { EGA/VGA configuration }
                    flags  : Word;               { misc flags }
                  end;           { remainder of table ignored }

              { globally visible }
Var
  VDA         : VideoDataArea Absolute $40:$84;   { equipment flags }
  isEGA,
  isVGA,
  isColor     : Boolean;
  CurrentFont : ROMfont; { default hardware font }

Procedure GetCharGenInfo( font:ROMfont; Var table:Char_table );
Procedure SetHardWareFont( font:ROMfont );
Function FetchHardwareFont( font:ROMfont ):FontPackagePtr;
Procedure LoadUserFont( pkg:FontPackagePtr );

{ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - }

Implementation

Uses Dos, Crt {, TextScrn} ;

Var reg:Registers;

Procedure GetCharGenInfo( font:ROMfont; Var table:Char_table );
  begin
    if isEGA then
      begin
        reg.AH := $11;
        reg.AL := $30;
        Case font of
          ROM8x8  : reg.BH := 3;
          ROM8x14 : reg.BH := 2;
          ROM8x16 : reg.BH := 6;
        end;
        intr( $10,reg );
        table.def := ptr( reg.ES,reg.BP ); { address of definition table }
        Case font of
          ROM8x8  : table.points :=  8;
          ROM8x14 : table.points := 14;
          ROM8x16 : table.points := 16;
        end;
      end;
  end; { proc GetCharGenInfo }


Procedure SetHardWareFont( font:ROMfont );
  begin
    if isEGA then
      begin
        Case Font of
          ROM8x14 : reg.AL := $11;
          ROM8x8  : reg.AL := $12;
          ROM8X16 : if isVGA then
                      reg.AL := $14
                    else
                      begin
                        reg.AL := $12;
                        font := ROM8x14;
                      end;
        end;
        reg.BL := 0;
        intr( $10,reg );
        CurrentFont := font;
      end;
  end; { proc SetHardwareFont }


Function FetchHardwareFont( font:ROMfont ):FontPackagePtr;
  { Get a hardware font and place it on heap For user modification }
  Var pkg : FontPackagePtr;
  begin
    new( pkg );
    GetCharGenInfo( font,pkg^.fontinfo );
    pkg^.ch := pkg^.fontinfo.def^;
    FetchHardwareFont := pkg;
  end; { func FetchHardwareFont }


Procedure LoadUserFont( pkg:FontPackagePtr );
  begin
    reg.AH := $11;
    Reg.AL := $10;
    reg.ES := seg( pkg^.ch );
    reg.BP := ofs( pkg^.ch );
    reg.BH := pkg^.FontInfo.points;
    reg.BL := 0;
    reg.CX := 256;
    reg.DX := 0;
    intr( $10,reg );
  end; { proc LoadUserFont }


begin  { initialize }

  { determine adapter Type }
  isEGA := False;
  isVGA := False;
  if VDA.info <> 0 then
    begin
      isEGA := True;
      if ( VDA.flags and 1 ) = 1 then
        isVGA := True;
    end;

  { determine monitor Type }
  if isEGA then
    begin
      reg.AH := $12;
      reg.BL := $10;
      intr( $10,reg );
      if reg.BH = 0 then
        isCOLOR := True
      else
        isCOLOR := False;
                                   { ADM: this seems Really shaky! }
      { determine current font }
      if isVGA and ( VDA.rows = 24 ) then
        CurrentFont := ROM8x16
      else
        if isEGA and ( VDA.rows = 24 ) then
          CurrentFont := ROM8x14
        else
          CurrentFont := ROM8x8;
    end
end.

