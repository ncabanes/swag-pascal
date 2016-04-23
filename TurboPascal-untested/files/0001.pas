{> How does one go about changing a File attribute
> from hidden to unhidden using SetFAttr ?

Try these two Procedures on For size:
}
GetFAttr(FName:String;Var RdOnly,Hid,Sys,Arch:Boolean);
Var R:Registers;
begin
  FillChar(R,Sizeof(R),0);
  FName := FName+#0; { set up as a null-terminated String For Dos }
  With R Do begin
    AH := $43;
    DS := Seg(FName); DX := ofs(FName)+1; { skip pascal length Byte }
    MsDos(R);
    RdOnly := (CL and $01) > 0;
    Hid := (CL and $02) > 0;
    Sys := (CL and $04) > 0;
    Arch := (CL and $20) > 0;
    end; { With }
end; { GetFAttr }

PutFAttr(FName:String;RdOnly,Hid,Sys,Arch:Boolean);
Var R:Registers;
begin
  FillChar(R,Sizeof(R),0);
  FName := FName+#0; { set up as a null-terminated String For Dos }
  With R Do begin
    AH := $43; AL := 1;
    DS := Seg(FName); DX := ofs(FName)+1; { skip pascal length Byte }
    if RdOnly then CL := CL or $01;
    if Hid then CL := CL or $02;
    if Sys then CL := CL or $04;
    if Arch then CL := CL or $20;
    MsDos(R);
    end; { With }
end; { PutFAttr }

{The File FName does not have to be opened For this to work.  In fact, it
would probably be better if it were not.
}
