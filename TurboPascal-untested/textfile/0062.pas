
 Program Viewer;
 (*$M $800,0,$A0000 *)

 Uses
    crt;

 Type    TextBlock = Array[1..6209] of ^String;

 Var     VText : TextBlock;
         Lines : integer;
         Last  : integer;

 Procedure Init(N:string);
 Var F: text;
     S: String;
 begin
   FillChar( VText, Sizeof(Vtext), 0 );
   Lines := 0;
   Assign( f, N );
(*$I-*)
   Reset( f );
(*$I+*)
   If IoResult <> 0 then exit;
   While ( not EOF( F ) )
     AND ( Maxavail > 80 )   do  { assume a 80-Char-String }
   begin
      Inc( Lines );
      ReadLn( F, S );
      If Length(S) > 80
        Then S[0] := #80;
      GetMem( Vtext[Lines], 1+Length(S) );
      VText[Lines]^ := S;
   end;
   Last := Lines;
   if not eof( F )
     then Write(' Sorry, only ')
     else Write(' All ');
   Writeln( Lines,' Lines of ', N , ' read. ');
   Close( F );
 end;

 Procedure Display(N:String);
 Var ch : Char;
     akt: integer;
     Procedure Update;
     Var y,i: integer;
     begin
       if akt > ( Last - 22 )
          then akt := last - 22;
       if akt < 1
          then akt := 1;
       y := 2;
       for  i := akt to akt + 22 do
       begin
         gotoxy( 1, y );
         ClrEol;
         inc( y );
         if i <= Last then write( VText[i]^ );
       end;
       TextAttr := $70;  (* Black on Gray *)
       Gotoxy(70,25);
       if akt+23 > Last
         then Write(akt,'..',Last)
         else Write(akt,'..',akt+22);
       ClrEol
     end;
 begin
   TextAttr := $70;  (* Black on Gray *)
   ClrScr;
   Gotoxy( 3, 25);
   Write('Page Up/Dn,Home,End,Arrow  keys,<ESC> Quits');
   Gotoxy( 2,1);
   while Pos('\',N) > 0 do delete(n,1,1);
   for akt := 1 to length(N) do N[akt] := upcase(n[akt]);
   Write('File: ',N,', ',Last,' Lines,  ');
   Write( MemAvail,' Bytes free.');
   Gotoxy(63,25); Write('Lines: ');
   akt := 1;
   repeat
     TextAttr := $1F;  { white on blue }
     Update;
     repeat
        ch := ReadKey;
        if ch = #0 then
        begin
          ch := readkey;
          case ch of
          'H' : ch := #1; { up }
          'P' : ch := #2; { down }
          'Q' : ch := #3; { pg-up }
          'I' : ch := #4; { pg-down }
          'G' : ch := #5; { home }
          'O' : ch := #6; { end }
          else ch := #0;  { discard }
        end
        end
     until Ch in [#27, #1..#6 ] ;
     case Ch of
       #1 : dec( akt );
       #2 : inc( akt );
       #3 : inc( akt, 22 );
       #4 : dec( akt, 22 );
       #5 : akt := 1;
       #6 : akt := last-22;
     end;
  until ch=#27;
 end;

 procedure CleanUp;
 Var I : Integer;
 begin
   for I := last downto 1 do
     FreeMem( Vtext[i], 1+Length(VText[i]^) );
   TextAttr := 7;
   ClrScr;
 end;

 begin
   if Paramcount <> 1 then
   begin
     writeln(' Usage :  VIEW [Drive:[\Path\]] FileName.Ext');
     halt
   end;
   Init(paramstr(1));
   if Lines > 0 then
   begin
     Display(paramstr(1));
     CleanUp;
   end;
 end.
