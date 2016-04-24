(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0084.PAS
  Description: Multi-color Strings
  Author: ORLANDO LLANES
  Date: 05-26-95  23:07
*)

UNIT FWColor;
{ This unit prints a string using John O'Harrow's FWrite and  }
{ has the ability to change color from within the string. The }
{ demo program is at the end of this unit.                    }

{ If you have any questions, improvements, or comments, etc., }
{ E-Mail me (Orlando Llanes) either via NetMail at 1:369/68   }
{ or via the Internet at a010111t@bcfreenet.seflin.lib.fl.us  }

{ Thanks go to -> John O'Harrow <- for his "Universal FastWrite"   }
{ routine! Compilation of this unit requires his FWrite unit       }
{ found in SWAG9411 in SCREEN.SWG (Love the new format SWAG Team!) }

{ Possible enhancements:                             }
{  - Use a different character for the color marker. }
{  - Optimizations.                                  }
{  - Use character equivalent of FastWrite(?)        }

{ Notes:                                                    }
{  - Coordinates are *not* zero based as in the FWrite,     }
{    unit, the upper left corner is (1,1).                  }
{  - The marker character is ASCII character 0, hopefully,  }
{    this will not interfere with anything.                 }
{  - Sorry for the Boolean and type-casting in the demo,    }
{    I didn't feel like doing the math for the attributes,  }
{    and type-casting makes things faster when converting   }
{    between similar types, i.e. Char <--> Byte.            }

INTERFACE
USES FWrite;

PROCEDURE FastWriteColor( X, Y : Byte; Str : String );

IMPLEMENTATION

PROCEDURE FastWriteColor( X, Y : Byte; Str : String );
VAR
  _X, Index, FWCAttr : Byte;

BEGIN
  _X := X;  Index := 1;
  WHILE Index <= Byte( Str[ 0 ] ) DO
  { ^^ Loop from 1 to length of string }
    BEGIN
      IF Str[ Index ] = #0 THEN
      { ^^ Is the current character the marker? }
        BEGIN
          FWCAttr := Byte( Str[ Index + 1 ] );
          { ^^ Set Text Attributes }
          Inc( Index, 2 );
          { ^^ Point past marker and the color }
        END { of Str[ Index ] = marker }
      ELSE
        BEGIN
          FastWrite( _X - 1, Y - 1, FWCAttr, Str[ Index ] );
          { ^^ Zero based, so decrement _X and Y }
          Inc( _X );
          { ^^ Increment reference to next screen position }
          Inc( Index );
          { ^^ Increment reference to next character }
        END; { of ELSE }
    END; { of WHILE..DO }
END; { of FastWriteColor }
END. { of UNIT FWColor }

PROGRAM FWCDemo;
USES Crt, FWColor;
BEGIN { Main program }
  ClrScr;
  FastWriteColor( 1, 1,
    #0#$4F'This '#0#9'is'#0#$3F' so'#0#15' cool!' );
  FastWriteColor( 1, 2,
    #0 + Char((NOT 15) AND NOT 128) + 'You '#0#4'can '#0 +
      Char(33 OR 128) + 'change' );
  FastWriteColor( 1, 3,
    #0#14'colors '#0#10'on '#0#13'the '#0#$FF'fly!' );
  FastWriteColor( 1, 4,
    #0#$25'And you can even write control characters! ' +
      #12#4#7#2#1#0#14#14#13#27#26 );
  GoToXY( 1, 5 );
END. { of demo }

