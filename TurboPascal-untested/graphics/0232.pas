
procedure load_icon(xx,yy :integer;iconname :string);

var
  r,rr :byte;
  f    :text;

begin
  x :=xx;y :=yy;
  assign(f,iconname +'.ico');
  {$I-} reset(f); {$I+}
  if ioresult =0 then begin
    for p :=1 to 766 do begin
      read(f,ch);q :=ord(ch);
      if (p >126) and (p <639) then begin
        r :=q shr 4;rr :=q-r div 16;
        putpixel(x,y,r);putpixel(x+1,y,rr);
        inc(x,2);
        if x =xx+32 then begin
          x :=xx;dec(y);
        end;
      end;
    end;
    close(f);
  end;
end;
