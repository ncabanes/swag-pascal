(*
  Category: SWAG Title: SCREEN SAVING ROUTINES
  Original name: 0017.PAS
  Description: Screen Saving + Frames
  Author: LUKASZ GRABUN
  Date: 02-21-96  21:04
*)

{
Hi All!

I've been reading SWAG sources concerning text windows and screen saving many
times. Text windows from SWAG library are quite good and fast. And, what is
much more important, they pushed the screen behind them to the stack - and
when they're disposed they pop it. Quite simple, isn't it?

Well, what if you'd like push the screen before you simply _write_ sth to
screen... There's no simple screen saving procedures :((

Since now - I've got something quite simple, fast and safe:
}

{***************************************************}
{    REWRITTEN FROM ENTER POLISH COMP. MAGAZINE     }
{            BY LUKASZ GRABUN - POLAND              }
{                FIDO: 2:480/49.22                  }
{***************************************************}

unit OScreen;

interface

const pom : Pointer = nil;

type  Scrtype = array[1..11352] of byte;
      ScreenType = record
                     scr : scrtype;
                     prev : pointer
                   end;

var   SS : ScrType absolute $b800:0;
      Screen : ^ScreenType;

procedure PopScreen;
procedure PushScreen;

implementation

procedure PushScreen;
begin
  new(Screen);
  Screen^.Prev:=Pom;
  Pom:=Screen;
  Screen^.Scr:=SS
end;

procedure PopScreen;
begin
  screen:=pom;
  pom:=screen^.prev;
  SS:=Screen^.Scr;
  dispose(screen)
end;

end.

When you want save screen - simply write PushScreen, and when you want to
restore it - PopScreen. And just one thing: number of used PushScreen
procedures _must be_ equal to number of used PopScreen procs. 
Enjoy!!!
                                           CU L8R! - Wookasz

