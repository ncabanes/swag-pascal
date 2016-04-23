{This is an equivalent to the Delay procedure in Borland Pascal. You may
find it of interest. It is not mine. It was given to me by someone else
who did not cite the source. Hope it helps your important WWW page. Take
care.
}

procedure TForm1.Delay(msecs:integer);
var
   FirstTickCount:longint;
begin
     FirstTickCount:=GetTickCount;
     repeat    
           Application.ProcessMessages; {allowing access to other 
                                         controls, etc.}
     until ((GetTickCount-FirstTickCount) >= Longint(msecs));
end;


