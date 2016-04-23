{
>  I need to transfer decimal into binary using TURBO PASCAL.
>  One way to do this is to use the basic algorithm, dividing
>  by 2 over and over again. if the remainder is zero the
>  bit is a 0, else the bit is a 1.
>
>  However, I was wondering if there is another way to convert
>  from decimal to binary using PASCAL. Any ideas?

As an 8-bit (ie. upto 255) example...
}

  Function dec2bin(b:Byte) : String;
  Var bin : String[8];
      i,a : Byte;
  begin
   a:=2;
   For i:=8 downto 1 do
    begin
     if (b and a)=a then bin[i]:='1'
                    else bin[i]:='0';
     a:=a*2;
    end;
    dec2bin:=bin;
  end;

