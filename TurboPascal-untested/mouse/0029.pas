{
From: se1tc@dmu.ac.uk (TC)

>> I use TP7 and  I am learning about graphics in pascal
>> ?1 How can I change a mouse pointer ??
>> ?2 How can I find a source code of pascal in FTP ??
>
> Do you have a mouse unit that implements Int 33h subfunction 9?
> You pass it the segment and offset of an array[0..31] of word;
>
> Best TP-specific suggestion I have is to locate the Sept. '85
> issue of BYTE magazine.  It has an article (p. 161) showing how to
> program the mouse functions.
>
> As for creating new mouse cursors, I found a neat little utility
> called IGME.ZIP.  It's a graphical mouse cursor editor that
> allows you to set individual pixels in a mouse cursor, like a drawing
> program. It lets you test your creation by setting the mouse cursor
> to use the one you just designed!
>
> The best part is that it has the option to produce CODE of the new
> cursor mask, that you can pull into your program as a CONSTant.
> It produces C code, but 5 minutes work changing 0x's to $ signs
> gives you the pascal code.
>
> I can't remember exactly where I found it, but I think it was one
> of the following:
> x2ftp.oulu.fi
> garbo.uwasa.fi
> oak.oakland.edu
>

Better still (well at least it's some code to get your
teeth into!):
}

procedure ChangeMousePointer; assembler;
asm 
        mov     AX,09h 
        mov     BX,seg @Point 
        mov     ES,BX 
        mov     BX,4 
        mov     CX,2 
        mov     DX,offset @Point 
        int     33h 
        jmp     @Exit 
@Point: db  255, 255, 255, 207 { screen mask, I think }
        db  255, 135, 255, 135 
        db  159, 192,  15, 192 
        db   15, 224,   7, 224 
        db    7, 192,   7, 128 
        db    7, 128,   7, 224 
        db    7, 240,  15, 248 
        db   15, 252,  15, 255 
 
        db    0,   0,   0,   0 { Cursor mask }
        db    0,  48,   0,  48 { If it goes a bit funny }
        db    0,  24,  96,  27 { swap the two around    }
        db   96,  13, 176,  13 
        db  240,   6, 240,  55 
        db  240,  27, 240,  15 
        db  240,   7, 224,   3 
        db  224,   0,  96,   0 
@Exit: 
end; 

