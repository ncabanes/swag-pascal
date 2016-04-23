Program  Novell_API_Examples;

{ Misc. Novell Advanced Netware 2.1+ API examples to retrieve info on the
  user who is running this program
}

USES   DOS, CRT;

CONST
  HexDigit: array [0..15] of char = '0123456789ABCDEF';
  Days_Of_Week   : Array[0..6] of string = ('Sunday','Monday','Tuesday',
                                            'Wednesday','Thursday','Friday',
                                            'Saturday');


TYPE
  string2 = STRING[2];
  string4 = STRING[4];


VAR
  Reg          : DOS.Registers;
  RCode        : Integer;
  Connect      : Byte;
  Address      : String;


function HexByte(B: byte): string2;
  begin
    HexByte := HexDigit[B shr 4] + HexDigit[B and $F];
  end;


function Hex(I: integer): string4;
  begin
    Hex := HexByte(hi(I)) + HexByte(lo(I));
  end;


Function Get_Connection_Number : Integer;
  { |
    | Returns the connection number for the current session
    |
  }
  begin
    Reg.AH := $DC;
    intr($21,Reg);
    Get_Connection_Number := Reg.AL;
  end;


Function Get_Station_Address(var Address: String): Integer;
  { |
    |  Returns the Physical Station Address (NIC Number)
    |
  }
  var
    S1, S2, S3 : String;
  begin
    Reg.AH := $EE;
    intr($21,Reg);
    Address := Hex(Reg.CX) + Hex(Reg.BX) + Hex(Reg.AX);
    Get_Station_Address := $00;
  end;


Function Get_Login_Name : String;
  { |
    |  Who's calling?
    |
  }
  var
    Reg           : DOS.REGISTERS;
    Loop,
    Connection    : Byte;
    TmpStr        : String;
    Request_Buf   : Record
                      BufLen     : Integer;
                      SubFunc    : Byte;
                      Connection : Byte;
                    end;
    Reply_Buf     : Record
                      BufLen     : Integer;
                      Obj_ID     : LongInt;
                      Obj_Type   : Integer;
                      Obj_Name   : Array[1..48] of char;
                      Login_Time : Record
                                     Year   : Byte;
                                     Month  : Byte;
                                     Day    : Byte;
                                     Hour   : Byte;
                                     Minute : Byte;
                                     Second : Byte;
                                     Day_No : Byte;
                                   end;
                  end;

  begin
    TmpStr := '';
    RCode := 0;
    Connect := Get_Connection_Number;
    fillchar(Request_Buf,sizeof(Request_Buf),0);
    fillchar(Reply_Buf,sizeof(Reply_Buf),0);

    Request_Buf.SubFunc := $16;
    Request_Buf.Connection := Connect;
    Request_Buf.BufLen := sizeof(Request_Buf);
    Reply_Buf.BufLen := sizeof(Reply_Buf);
    Reg.AH := $E3;
    Reg.DS := seg(Request_Buf);
    Reg.SI := ofs(Request_Buf);
    Reg.ES := seg(Reply_Buf);
    Reg.DI := ofs(Reply_Buf);
    intr($21,Reg);
    Loop := 1;
    while ((Reply_Buf.Obj_Name[Loop] <> #0) and (Loop <= 48)) do
      begin
        TmpStr := TmpStr + Reply_Buf.Obj_Name[Loop];
        inc(loop);
      end;
    Get_Login_Name := TmpStr;
  end;


Procedure Pause;
  var
    ch : char;
  begin
    writeln;
    write('Press Any Key To Continue ');
    ch := readkey;
    writeln;
  end;


BEGIN
  clrscr;
  writeln('Get Novell Station Info  - (C) Rick Ryan, 1989');
  writeln;
  Connect := Get_Connection_Number;
  Writeln('  Connection ID: ', Connect);

  RCode := Get_Station_Address(Address);
  writeln('Station Address: ',Address,'  With ErrCode of ', RCode);

  writeln('Login Name = ',Get_Login_Name);

  Pause;

END.