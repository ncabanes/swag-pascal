(*
  Category: SWAG Title: OOP/TURBO VISION ROUTINES
  Original name: 0089.PAS
  Description: A Movie view object for TurboVision
  Author: TOM WELLIGE
  Date: 08-30-97  10:08
*)

{************************************************}
{                                                }
{   UNIT TVMovie  A "Movie" view object          }
{   Copyright (c) 1993-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

unit TVMovie;

{$O+,F+,P+}


interface

uses Dos, Drivers, Objects, App, Views, Dialogs;

type
  { holding each line of the Movie }
  PMovieCollection = ^TMovieCollection;
  TMovieCollection = object(TCollection)
    procedure FreeItem(Item: Pointer); virtual;
    procedure AddLine(s: string);
  end;


  { Movie - Object }
  PMovie = ^TMovie;
  TMovie = object(TView)
      List: PMovieCollection;
      Pos, Ticks: integer;
      OldS, OldM: word;
    constructor Init(var Bounds: TRect; AList: PMovieCollection);
    procedure Draw; virtual;
    procedure AddTick;
  private
    function  GetLine(Line: integer): string;
  end;

  { About-Dialog which starts movie by user's pressing "ALT-I" }
  PMovieAbout = ^TMovieAbout;
  TMovieAbout = object(TDialog)
      MovieList: PMovieCollection;
      MovieR: TRect;
    constructor Init(var Bounds: TRect; ATitle: string;
                     AList: PMovieCollection; AMovieR: TRect);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const
  cmInfo         = 2000;
  cmMovieReady   = 2001;
  Movie : PMovie = nil;

implementation

(***********************************************************************)
(*                          TMovieAbout                                 *)
(***********************************************************************)

constructor TMovieAbout.Init(var Bounds: TRect; ATitle: string;
                 AList: PMovieCollection; AMovieR: TRect);
begin
  inherited Init(Bounds, ATitle);
  Options := Options or ofCentered;
  MovieList:= AList;
  MovieR   := AMovieR;
  Movie    := nil;
end;

destructor TMovieAbout.Done;
begin
  if Assigned(Movie) then
  begin
    Delete(Movie);
    Dispose(Movie, Done);
    Movie:= nil;
  end;
  inherited Done;
end;

procedure TMovieAbout.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  { switch Movie on }
  if ((Event.What = evKeyDown) and (Event.KeyCode = kbAltI)) or
     ((Event.What = evCommand) and (Event.Command = cmInfo)) then
  begin
    if Movie <> nil then
    begin
      ClearEvent(Event);
      Delete(Movie);
      Dispose(Movie, Done);
      Movie:= New(PMovie, Init(MovieR, MovieList));
      Insert(Movie);
    end else
    begin
      ClearEvent(Event);
      Movie:= New(PMovie, Init(MovieR, MovieList));
      Insert(Movie);
    end;
  end;
  { Movie ready, relaese view }
  if (Event.What = evBroadcast) and (Event.Command = cmMovieReady) then
  begin
    ClearEvent(Event);
    Delete(Movie);
    Dispose(Movie, Done);
    Movie:= nil;
  end;
end;


(***********************************************************************)
(*                                 TMovie                               *)
(***********************************************************************)

constructor TMovie.Init(var Bounds: TRect; AList: PMovieCollection);
var h, m: word;
begin
  inherited Init(Bounds);
  Ticks:= 0;
  Pos  := 1;
  List := AList;
  GetTime(h, m, OldM, OldS);
end;

procedure TMovie.AddTick;
var
  i, e: integer;
  h, m, s, hs: word;
begin
  GetTime(h, m, s, hs);
  if s <> OldM then hs:= hs + 100;
  if hs > OldS + 50 then
  begin
    if s <> OldM then hs:= hs - 100;
    OldM:= s;
    OldS:= hs;
    inc(Pos);
    Draw;
  end;
  if Pos = List^.Count-1 then
    Message(Owner, evBroadCast, cmMovieReady, nil);
end;


procedure TMovie.Draw;
var
  R: TRect;
  i: integer;
  Buf: TDrawBuffer;
  Color: word;
begin
  GetExtent(R);
  Color:= GetColor(1);
  for i:= 0 to R.B.Y-1 do
  begin
    MoveChar(Buf, ' ', Color, Size.X);
    MoveCStr(Buf, GetLine(Pos+i), $7271);
    WriteLine(0, i, Size.X, 1, Buf);
  end;
end;


function TMovie.GetLine(Line: integer): string;
var
  s: string;
  i, e: integer;
begin
  if Line >= List^.Count then GetLine:= '' else
    GetLine:= PString(List^.At(Line))^;
end;



procedure TMovieCollection.FreeItem(Item: Pointer);
begin
  if assigned(Item) then DisposeStr(Item);
end;

procedure TMovieCollection.AddLine(s: string);
begin
  Insert(NewStr(s));
end;


end.

{ ----------------  DEMO -------------  CUT HERE ----------- }
{************************************************}
{                                                }
{   PROGRAM MOVIETST  Usage of TVMOVIE Unit      }
{   Copyright (c) 1993-97 by Tom Wellige         }
{   Donated as FREEWARE                          }
{                                                }
{   Ortsmuehle 4, 44227 Dortmund, GERMANY        }
{   E-Mail: wellige@itk.de                       }
{                                                }
{************************************************}

program MovieTst;

uses dos, drivers, objects, app, views, dialogs, menus, tvmovie;


type
  TApp = object(TApplication)
    procedure About;
    procedure Idle; virtual;
    procedure InitMenuBar; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const
  cmAbout = 1000;


procedure TApp.About;
var
  R, F: TRect;
  D   : PMovieAbout;
  C   : PMovieCollection;
begin

  C:= New(PMovieCollection, Init(50, 5));
  with C^ do
  begin
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('                                        '  );
    AddLine('┌─┬──────────────────────────────────┬─┐'  );
    AddLine('│ │                                  │ │'  );
    AddLine('│■│                                  │■│'  );
    AddLine('│ │     █▄ ▄█ █▀▀█ █   █ █ █▀▀▀      │ │');
    AddLine('│■│     █ ▀ █ █  █ ▀▄ ▄▀ █ █▄▄       │■│');
    AddLine('│ │     █   █ █  █  █ █  █ █         │ │');
    AddLine('│■│     █   █ █▄▄█  ▀▄▀  █ █▄▄▄      │■│');
    AddLine('│ │                                  │ │'  );
    AddLine('│■│                                  │■│'  );
    AddLine('│ │          ~by Tom Wellige~          │ │');
    AddLine('│■│                                  │■│'  );
    AddLine('│ │                                  │ │'  );
    AddLine('│■│  Well, this is a pretty good     │■│'  );
    AddLine('│ │  place to make some statements   │ │'  );
    AddLine('│■│  about your program.             │■│'  );
    AddLine('│ │                                  │ │'  );
    AddLine('│■│  I always use this Movie to tell │■│'  );
    AddLine('│ │  the user about the beta-        │ │'  );
    AddLine('│■│  testers, the translators or     │■│'  );
    AddLine('│ │  things like that. You want to   │ │'  );
    AddLine('│■│  take a look on my Turbo Vision  │■│'  );
    AddLine('│ │  programs ? No problem. Check    │ │'  );
    AddLine('│■│                                  │■│'  );
    AddLine('│ │      ~www.kst.dit.ie/people/~      │ │'  );
    AddLine('│■│        ~twellige/hps.html~         │■│'  );
    AddLine('│ │                                  │ │'  );
    AddLine('│■│                                  │■│'  );
    AddLine('│ │  And just to make this film a    │ │'  );
    AddLine('│■│  little bit longer:              │■│'  );
    AddLine('│ │                                  │ │'  );
    AddLine('│■│  1                               │■│'  );
    AddLine('│ │   2                              │ │'  );
    AddLine('│■│    3                             │■│'  );
    AddLine('│ │     4                            │ │'  );
    AddLine('│■│      5                           │■│'  );
    AddLine('│ │       6                          │ │'  );
    AddLine('│■│        7                         │■│'  );
    AddLine('│ │         8                        │ │'  );
    AddLine('│■│          9                       │■│'  );
    AddLine('│ │           0                      │ │'  );
    AddLine('│■│            1                     │■│'  );
    AddLine('│ │             2                    │ │'  );
    AddLine('│■│              3                   │■│'  );
    AddLine('│ │               4                  │ │'  );
    AddLine('│■│                5                 │■│'  );
    AddLine('│ │                 6                │ │'  );
    AddLine('│■│                  7               │■│'  );
    AddLine('│ │                   8              │ │'  );
    AddLine('│■│                    9             │■│'  );
    AddLine('│ │                     0            │ │'  );
    AddLine('│■│                      1           │■│'  );
    AddLine('│ │                       2          │ │'  );
    AddLine('│■│                        3         │■│'  );
    AddLine('│ │                         4        │ │'  );
    AddLine('│■│                          5       │■│'  );
    AddLine('│ │                           6      │ │'  );
    AddLine('│■│                            7     │■│'  );
    AddLine('│ │                             8    │ │'  );
    AddLine('│■│                              9   │■│'  );
    AddLine('│ │                               0  │ │'  );
    AddLine('│■│                                  │■│'  );
    AddLine('└─┴──────────────────────────────────┴─┘'  );
    AddLine('                                        '  );
    AddLine('                                        '  );
  end;

  R.Assign(0,0,48,21);
  F.Assign(4,2,44,15);
  D := New(PMovieAbout, Init(R, 'About' , C, F));
  with D^ do
  begin
    R.Assign(5,2,43,12);
    Insert(New(PStaticText, Init(R,
        #3'MovieTst v1.0'+#13+
        #13+
        #3'Copyright (c) 1993-97 by Tom Wellige'+#13+
        #13+
        #3'Donated as Freeware'+#13+
        #13+
        #13+
        #13+
        #3'This is not only a simple'+#13+
        #3'about box !')));

    R.Assign(24, 18, 34, 20);
    Insert(New(PButton, Init(R, '~O~k',   cmCancel, bfDefault)));

    dec(R.A.X, 11); dec(R.B.X, 11);
    Insert(New(PButton, Init(R, '~I~nfo', cmInfo,   bfNormal)));

    SelectNext(false);
  end;

  if Assigned(D) then Application^.ExecuteDialog(D, nil);

  Dispose(C, Done);
end;

procedure TApp.Idle;
begin
  inherited Idle;
  if assigned(Movie) then Movie^.AddTick;
end;

procedure TApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y:= R.A.Y + 1;
  MenuBar := New(PMenuBar, Init(R, NewMenu(
    NewSubMenu('~'#240'~', 0, NewMenu(
      NewItem('~A~bout', 'Shift-F1', kbShiftF1, cmAbout, 0,
      NewLine(
      NewItem('E~x~it',  'Alt-X',    kbAltX,    cmQuit,  0,
    nil)))),
  nil))));
end;

procedure TApp.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
    if Event.Command = cmAbout then About;
end;

var
  A: TApp;

begin
  A.Init;
  A.Run;
  A.Done;
end.

