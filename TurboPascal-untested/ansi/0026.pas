{
From: ROBERT LONG
Subj: Ansi Graphics - TP 6.0
---------------------------------------------------------------------------
JP>If anyone knows how to do Ansi Graphics in Turbo Pascal 6.0 any help would b
JP>appreciated.  I'm writing a BBS Door a lot like Dungeons & Dragons and want
JP>add some Ansi Graphics to it.  Please Help

I assume you mean you want to send ansi graphics to the local screen. If
so this routine works very well.

You can use this routine with or without the CRT unit. All output will
be routed through the BIOS. You must have the ANSI.SYS driver loaded in
your config.sys file.

}
procedure  awrite(c : byte);

    begin
      asm
        mov ah,2;
        mov dl,c;
        int $21;
      end;
    end;

