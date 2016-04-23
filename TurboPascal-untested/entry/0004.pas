(****************************************************************)
(*                         N_EditLn                             *)
(*                                                              *)
(*    General Purpose line editor, based on EDITLN by Borland   *)
(*          Modified for use with multiple lines by             *)
(*                 Bob Gibson of BGShareWare                    *)
(*                                                              *)
(****************************************************************)

unit N_EditLn;
{$D-,I-,S-}
interface
uses Scrn;

const
  NULL = #0;
  BS = #8;
  LF = #10;
  CR = #13;
  ESC = #27;
  Space = #32;
  Tab = ^I;

  { The following constants are based on the scheme used by the scan key
    function to convert a two key scan code sequence into one character
    by adding 128 to the ordinal value of the second character.
  }
  F1 = #187;
  F2 = #188;
  F3 = #189;
  F4 = #190;
  F5 = #191;
  F6 = #192;
  F7 = #193;
  F8 = #194;
  F9 = #195;
  F10 = #196;
  UpKey = #200;
  DownKey = #208;
  LeftKey = #203;
  RightKey = #205;
  PgUpKey = #201;
  PgDnKey = #209;
  HomeKey = #199;
  EndKey = #207;
  InsKey = #210;
  DelKey = #211;
  M : Word = 0;
var
  O, N, R, P : byte;
  Ch : Char;
  T : String;

type
  CharSet = set of char;

procedure EditLine(var S     : String;
                       Len, X, Y : byte;
                       LegalChars,
                       Term  : CharSet;
                   var TC    : Char    );
{  EditLn implements a line editor that supports WordStar commands
   as well as left-right arrow keys , Home, End, back space, etc.
   Paramaters:
     S : String to be edited
     Len : Maximum characters allowed to be edited
     X, Y : Starting x an y cordinates
     LegalChars : Set of characters that will be accepted
     Term : Set of characters that will cause EditLine to Exit
            (Note LegalChars need not contain Term)
     TC : Character that caused EditLn to exit
}

function ScanKey : char;
{ Reads a key from the keyboard and converts 2 scan code escape
  sequences into 1 character. }

implementation
{$L keys}
Function KeyPressed : Boolean ; External;
Function ReadKey : Char ; External;

function ScanKey : char;
{ Reads a key from the keyboard and converts 2 scan code escape
  sequences into 1 character. }

var
  Ch : Char;
begin
  Ch := ReadKey;
  if (Ch = #0) {and KeyPressed} then
  begin
    Ch := ReadKey;
    if ord(Ch) < 128 then
      Ch := Chr(Ord(Ch) + 128);
  end;
  ScanKey := Ch;
end; { ScanKey }

procedure EditLine(var S : String;
                   Len, X, Y : byte;
                   LegalChars, Term  : CharSet;
                   var TC    : Char);
{  EditLn implements a line editor that supports WordStar commands
   as well as left-right arrow keys , Home, End, back space, etc.
   Paramaters:
     S : String to be edited
     Len : Maximum characters allowed to be edited
     X, Y : Starting x an y cordinates
     LegalChars : Set of characters that will be accepted
     Term : Set of characters that will cause EditLine to Exit
            (Note LegalChars need not contain Term)
     TC : Character that caused EditLn to exit
}
{$V-}

begin
  PXY(X,Y);
  PWrite(S);
  P := Y - 1;
  N := Y;
  O := X;
  Y := 1;
  M := 0;
  Mem[$40:$17] := (Mem[$40:$17] AND $7F);
  repeat
    If ((Mem[$40:$17] AND $80) = $80) Then SetCursor(0,7) Else SetCursor(6,7);
    If (Y+P) > 80 Then Begin
       Inc(X);
       P := 0;
       End;
    PXY(X,Y+P);
    Ch := ScanKey;
    if not (Upcase(Ch) in Term) then
      case Ch of
        #32..#126 : if (M < Len) and
                       (ch in LegalChars) then
                    begin
                      P := succ(P);
                      M := succ(M);
                      If ((Mem[$40:$17] AND $80) = $80) Then
                        Delete(S,M,1);
                      If ((Mem[$40:$17] AND $80) <> $80) Then
                         If Length(S) = Len Then Delete(S,Len,1);
                      Insert(Ch,S,M);
                      T := Copy(S,M,Len);
                      PWrite(T);
                    end
                    Else Writeln(^G);
        ^S, LeftKey : if M > 0 then Begin
                        If P < 1 Then Begin
                           P := 80;
                           Dec(X);
                           End;
                        P := pred(P);
                        M := pred(M);
                        End;
        ^D, RightKey : if M < Length(S) then Begin
                         P := succ(P);
                         M := succ(M);
                         End;
         HomeKey : Begin
                        M := M - P;
                        P := 0;
                        End;
         EndKey : Begin
                        M := M + (79 - P);
                        P := 79;
                        If M > Length(S) Then Begin
                           P := P - (M - Length(S));
                           M := Length(S);
                           End;
                        End;
         UpKey : If X > O Then Begin
                        Dec(X);
                        M := M - 80;
                        End;
         DownKey : If (M+80) < Length(S) Then Begin
                        Inc(X);
                        M := M + 80;
                        If M > Length(S) Then Begin
                           P := P - (M - Length(S));
                           M := Length(S);
                           End;
                        End;
         DelKey  : if M < Length(S) then
                       begin
                         Delete(S,M + 1,1);
                         T := Copy(S,M+1,Len);
                         T := T + ' ';
                         PWrite(T);
                       end;
         BS : if M > 0 then
                 begin
                   Delete(S,M,1);
                   T := Copy(S,M,Len);
                   If (Y+P-1) < 1 Then Begin
                      Dec(X);
                      P := (81-Y);
                      PXY(X,P);
                      End
                   Else PXY(X,Y+P-1);
                   T := T + ' ';
                   PWrite(T);
                   P := pred(P);
                   M := pred(M);
                 end;
         F9 : Begin
                  X := O;
                  Y := 1;
                  For R := 1 To Len Do PWrite(' ');
                  P := 0;
                  S := '';
                  M := 0;
                  End;
      else;
    end;  {of case}
  until UpCase(Ch) in Term;
  SetCursor(6,7);
  PXY(X,Y+P);
  M := Length(S);
  For R := 1 To (Len-M) Do PWrite('');
  TC := Upcase(Ch);
end; { EditLine }

end.

USE XX34 to decode this object code.  You MUST Have it to use this unit
Also, you will need the SCRN.PAS from the SCREEN.SWG packet.


*XX3401-000092-070293--68--85-59342--------KEYS.OBJ--1-OF--1
U+M+-2h3KJAuZUQ+++F1HoF3F7U5+0UI++6-+G4E5++++Ed9FJZEIYJHIoJ2++++-p73
EIF9FJY7+++pc-U++E++h+5B3bHug+51JMjgh+TB6MjZLQD6WU6++5E+
***** END OF XX-BLOCK *****


