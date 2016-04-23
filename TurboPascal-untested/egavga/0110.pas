{
   The solutions proposed so far to this problem have ignored
   the fact that there was a way to use high intensity back-
   ground in CGA screens by direct addressing the video port.
   The following procedure works with EGA/VGA as well as CGA
   (and possibly MDA?) videos:

   (I skipped function GetAdapterType that should return the
   AdapterType as indicated).

   -Jose-
 }
   procedure ToggleBlink(Blink: Boolean);
   var
     Adapter : AdapterType;
     regs    : registers;
     port_   : word;
   begin
     Adapter:= GetAdapterType;
     if Adapter in [CGA,MDA] then begin
       if Adapter = CGA then port_:= $03D8
                        else port_:= $03B8;
       if not Blink then PortW[port_]:= MemW[$0040:$0065] and $00DF
                    else PortW[port_]:= MemW[$0040:$0065]  or $0020;
     end else
     if (Adapter in [VGAColor,EGAColor,VGAMono,EGAMono]) then begin
       if not Blink then regs.bl:= $00
                    else regs.bl:= $01;
       regs.ah:= $10;
       regs.al:= $03;
       intr($10,regs);
     end;
   end;
