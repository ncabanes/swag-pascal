USES CRT,DOS;

(*   Here is a procedure I made that does ABOUT the same thing as the 'C'
   Printf Does. Could someone help me add a few more features? *)

PROCEDURE Printf(Str : String);
Var
   X : Integer;
   y : integer;
   ky: char;
   d : boolean;

begin
     d:=false;
     x:=0;
     ky:=' ';
     for x:=1 to length(str) do
         begin
              ky:=str[x];
              if (ky='\') and (not d) then
                 d:=true
              Else
              If (Ky='\') and (d) then
                 begin
                      write('\');
                      d:=false;
                 end
              Else
              if (ky='n') and (D) or (ky='N') And (D) then
                 begin
                      writeln;
                      d:=false;
                 end
              else
              if (Upcase(ky)='T') and (D) then
                 begin
                      write('        ');
                      d:=false;
                 end
              else
              if (Upcase(ky)='B') and (D) then
                 begin
                      write(#8);
                      d:=false;
                 end
              else
              if (Upcase(ky)='R') and (D) then
                 begin
                      write(#13);
                      d:=false;
                 end
              else
              if (Upcase(ky)='F') and (D) then
                 begin
                      write(#12);
                      d:=false;
                 end

              else
              if (Upcase(ky)='G') and (D) then
                 begin
                      write(#7);
                      d:=false;
                 end

              else

              if (not d) and (ky<>'\') then
                 begin
                      write(ky);
                      d:=false;
                 end;

         End;
End;

Begin
     ClrScr;
     Printf('This is a Printf() procedure. a \\n will make a new line.\nSee??');
     Printf(' Making a \\\\ will display a \\. Try it! Make a \\\\n to make a');
     printf('\nAlso, a \\b will back space. \\r will carriage return. \\f is f');
     printf('.\n\\t is tab.\\gIs Beep Eg\tI just tabed.\n\rI just carriage ret');
     printf('1234567890\b. There was a 0 after the 9. I backspased over it and');
     Printf('\g\gI beeped twice by: \\g\\g\n\n\n\n');
End.



