
  type
    long = array[0..3] of byte;   {defines the fake-longint type}
    string8 = string[8];

  {translate the significant portion of a real into a long var}
  procedure real2long(r:real; var l:long; var e:boolean);
  type
    string8   = string[8];
    string32  = string[32];
  var
    s : string32;

    function power(b:real; x:integer; var e:boolean): real;
    begin
      if b > 0 then 
        power:= exp(x * ln(b))
      else halt;
    end;

    {translate the significant portion of a real into a binary string32}
    procedure intreal2binstr(r:real; var s:string32; var e:boolean);
    var
      i : integer;
      m : real;
      p : real;
    begin
      e:= false;
      if (r > power(2,32,e)-1) then begin
        e:= true;
        exit;
      end;
      s:= '';
      for i:= 31 downto 1 do begin
        p:= power(2,i,e);
        m:= int(r/p);
        r:= r - (m * p);
        if (int(m) = 0)  then s:= s + '0'
                         else s:= s + '1';
      end;
      m:= int(r);
      r:= r - m;
      if (int(m) = 0) then s:= s + '0'
                      else s:= s + '1';
    end; 

    {translate a binary string32 into a long variable}
    procedure binstr2long(s: string32; var l:long; var e:boolean);
    var
      i : integer;
      w : string[8];
      b : byte;
  
      {translate a binary string8 into a byte}
      procedure binstr2byte(s:string8; var y:byte; var e:boolean);
      var
        i   : integer;
        v   : integer;
        c   : integer;
        b   : byte;
      begin
        y:= 0;
        for i:= 1 to 8 do begin
          val(s[i],v,c);
          e:= not(c = 0);
          if e then exit;
          b:= v * trunc(power(2,(8-i),e));
          y:= y or b;
        end;
      end;

    begin  {binstr2long}
      for i:= 0 to 3 do begin
        w:= copy(s,(i*8)+1,8);
        binstr2byte(w,b,e);
        l[3 - i]:= b;
      end;
    end;

  begin {real2long}
    intreal2binstr(r,s,e);
    if e then exit;
    binstr2long(s,l,e);
    if e then exit;
 end;

  {translate a string8 (a number in hex notation) into a long variable} 
  procedure str2long(s:string8; var l:long; var e: boolean);
  var
    i : integer;
    c : integer;
    v : integer;
    sb : array[0..3] of string[3];
  begin
    for i:= 0 to 3 do begin
      sb[i]:= '$' + copy(s,(7-(i*2)),2);
      val(sb[i],v,c);
      e:= not(c = 0);
      if e then exit;
      l[i]:= v;
    end;
  end;

  {translate an integer into a long variable}
  procedure int2long(i:integer; var l: long);
  begin
    fillchar(l,sizeof(l),0);
    move(i,l,2);
  end;

  {"shr 8" for long variables}
  procedure shr8(var a,b: long);
  var
    i : integer;
  begin
    for i:= 0 to 2 do
      b[i]:= a[(i+1)];
    b[3]:= 0;
  end;

  {"xor" for long variables}
  procedure xorl(var a,b,c : long);
  var
    i : integer;
  begin
    for i:= 0 to 3 do
      c[i]:= a[i] xor b[i];
  end;

  {"and" for long variables}
  procedure andl(var a,b,c : long);
  var
    i : integer;
  begin
    for i:= 0 to 3 do
      c[i]:= a[i] and b[i];
  end;

BEGIN
END.