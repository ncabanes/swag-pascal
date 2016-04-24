(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0173.PAS
  Description: Inbound scanning utility
  Author: JONAS MAEBE
  Date: 05-31-96  09:16
*)

{
(BTW: it requires a 386 or up to run). It should be
(almost) bug free, since my boss has been running it for about a month by now
and all problems he has found have been fixed.
------------- BBSCAN.PAS -------------------
}
Program bbscan;

{$g+,a+,q-,r-,i-,q-,s-,n-,e-,x+,f-}

Uses crt, dos;

Const l = 20; {maxlength of areanames, limit of Squish statistics tools}
      maxareas = (65504-2) div (l+1); {around 3000}

Type areaarray = Record
                         nofareas: Word;
                         area: Array[0..maxareas] of String[l]
                   End;

Const ProgName = 'BackboneScan v1.14, Copyright (c) Gamefreak 1996';
      fs = $64;
      pop_fs = $a10f;
      Fidoexists: Boolean = true;

VAR fido, bb, newfido: TEXT;
    areas: ^areaarray;
    c1, c2: Word;
    tempstr: String;
    Asort: Array[0..maxareas] of Word;

PROCEDURE Init;
VAR iocheck: Integer;
    f: file;
BEGIN
     ClrScr;
     WRITELN(ProgName);
     WRITELN;
     Assign(f, 'backbone.in');
    {$i-}
     Reset(f);
    {$i+}
     iocheck := ioresult;
     IF iocheck <> 0 THEN
     CASE iocheck OF
          2,3: BEGIN
               WRITELN('File "backbone.in" not found. Please move this program into the right dir');
               WRITELN('and run it again.');
               WRITELN;
               HALT(iocheck)
               END
             ELSE
               BEGIN
               WRITELN('An error (',iocheck,') occurred while opening the file "fidonet.na".');                    WRITELN;
               HALT(iocheck)
               END
     END;
     IF FileSize(f) = 0 THEN
     BEGIN
          WRITELN('Size of file "backbone.in" = 0 bytes. Nothing to do.');
          WRITELN;
          HALT(1)
     END;
     close(f);
     assign(f, 'fidonet.na');
    {$i-}
     reset(f);
    {$i+}
     If ioresult <> 0 Then
        Begin
             rewrite(f);
             fidoexists := false
        End
      Else if filesize(f) = 0 Then fidoexists := false;
     close(f);
     Assign(fido, 'fidonet.na');
     reset(fido);
     Assign(bb, 'backbone.in');
     Reset(bb)
END;

PROCEDURE ReadAreaNames;
Var tempstr2: String[12+30];

Function Duplicate: Boolean;
Assembler;
        Asm
           cld
           les di, areas
           mov dx, [es:di]      {dx = nofareas}
           xor al, al
           test dx, dx
           jz @end
           add di, 2            {es:di = 1st string}
           xor cx, cx
           mov si, offset tempstr {ds:si points to tempstr}
           mov bl, [si]         {bx = length(tempstr)}
           mov bh, bl
           and bh, 11b          {bh = length(tempstr) mod 4}
           shr bl, 2            {bl = length(tempstr) div 4}
           mov ax, di           {save di in ax}
          @loop:
           mov cl, bl           {cl = length(tempstr) div 4}
           xor ch, ch
           db $66; repe cmpsw   {compare}
           jne @ok              {not equal? -> ok}
           mov cl, bh           {otherwise check remaining bytes}
           repe cmpsb
           je @equal
          @ok:
           mov si, offset tempstr {ds:si points to tempstr}
           add ax, l + 1           {let ax point to next string}
           mov di, ax           {and move it into si}
           dec dx               {decrease the number of areas}
           jnz @loop            {if not zero -> loop}
           xor al, al           {no equal string -> false}
           jmp @end
          @equal:
           mov al, 1            {equal -> true}
          @end:
END;

BEGIN
     WRITELN('Reading areanames from "Backbone.in" and removing duplicates...');
     WRITELN;
     IF maxavail < 65535 THEN
        BEGIN
             WRITELN('Not enough memory available.');
             WRITELN;
             close(bb);
             close(fido);
             HALT(8)
        END
         ELSE new(areas);
     fillchar(areas^, sizeof(areas^), 0);
     While (areas^.nofareas < maxareas) and not(eof(bb)) Do
           BEGIN
                Readln(bb, tempstr);
                ASM
                   cld                       {this part copies the areaname}
                   push ds                   {to the front of the string}
                   mov di, offset tempstr    {and removes the "xxx messages}
                   mov dx, di                {scanned/tossed" part.}
                   mov si, di
                   add si, 12
                   pop es                    {es:di = sortstr[0]}
                   xor cx, cx
                   mov al, ' '               {used to check length of areaname}
                   mov cl, byte[di]          {cl = length total string}
                   add di, 12                {es:di = sortstr[12]}
                   sub cl, 12
                   mov bx, cx                {save original length - 12}
                   dec bx
                   repne scasb                {scan until a space is encouterd-> eof areaname}
                   sub bx, cx                {calc length of areaname}
                   mov cx, bx                {move length(areaname in cx)}
                   mov di, dx
                   mov [di], cl              {move length of areaname in lengthbyte}
                   inc di                    {points to first char of string}
                   shr cx, 1
                   jnc @even
                   movsb
                  @even:
                   rep movsw                 {move the areaname to the front}
                END;
                If not(duplicate) Then
                   With areas^ Do
                        BEGIN
                             area[nofareas] := tempstr;
                             inc(nofareas)
                        END
           END;
           Dec(areas^.nofareas);
           close(bb)
END;

Procedure Sort;
Var areasofs: Word;
Begin
     Writeln('Sorting areanames...');
     Writeln;
     Asm
        push ds
        push ds
        dw pop_fs
        cld
        les di, areas
        mov dx, word[es:di]
        mov bx, dx
        add bx, bx
        add bx, offset asort
       @asortinit:
        mov [bx], dx
        sub bx, 2
        dec dx
        jnz @asortinit
        mov dx, [es:di]
        dec dx
        jl @end
        mov ax, dx        {ax = pred(areas^.nofareas)}
        xor dx, dx       
        lds si, areas
        add si, 3
        mov areasofs, si
        xor bx, bx        {bx = c2}
       @outloop:
        mov di, areasofs
        db fs; mov cx, [bx+offset asort+2]
        add di, cx
        shl cx, 2
        add di, cx
        shl cx, 2
        add di, cx
       @loop:
        mov si, areasofs
        db fs; mov cx, [bx+offset asort]
        add si, cx
        shl cx, 2
        add si, cx
        shl cx, 2
        add si, cx
        xor cx, cx
        mov cl, [si-1]
        cmp cl, [di-1]
        jbe @length_ok
        mov cl, [di-1]
       @length_ok:        {cl = length of shortest string}
        push si
        push di
        rep cmpsb         {compare the strings}
        pop si            {si = pushed di and di = pushed si, used so I}
        pop di            {have to recalculate di in the next loop}
        jb @noswitch      {if first < second, don't switch}
        ja @switch        {if first > second, switch}
                          {if the prog gets here, the compared part was equal}
                          {so the longest string is the greatest}
        mov cl, [di-1]    {get length of first string (di has been switched}
                          {with si)}
        cmp cl, [si-1]    {compare with length of second string}
        jbe @noswitch     {length(string 1) < length(string 2) -> no switch}
       @switch:
        mov di, si
        db fs; db $66; ror word[bx+offset asort], 16
       @noswitch:
        sub bx,2          {decrease c2}
        jns @loop         {if above or equal 0 then loop}
        inc dx            {increase c1}
        mov bx, dx        {c2 = c1}
        add bx, bx
        cmp dx, ax        {compare c1 with pred(areas^.nofareas)}
        jbe @outloop      {if below or equal, loop}
       @end:
        pop ds
     End
End;

Procedure Update;
Const days : array [0..6] of String[9] =
           ('Sunday','Monday','Tuesday',
            'Wednesday','Thursday','Friday',
            'Saturday');
            areasstillactive: Word = 0;
            areasactivated: Word = 0;
            areasstillnoflow: Word = 0;
            areasnoflow: Word = 0;
            newareascount: Word = 0;

Var tempstr2: String;
    logfile: Text;
    dofw, d, m, y: Word;
    h,min,s: String[2];
    Newareas: Array[0..maxareas] of Word;
Begin
     Writeln('Writing new "Fidonet.na"...');
     Writeln;
     Assign(newfido, 'Newfido.na');
     Rewrite(NewFido);
     Assign(logfile, 'bbscan.log');
    {$i-}
     Append(logfile);
    {$i+}
     IF ioresult <> 0 Then Rewrite(logfile);
     If fidoexists Then
       Begin
         Readln(fido,tempstr);
         For c1 := 0 to areas^.nofareas Do
           Begin
              While ((tempstr < areas^.area[asort[c1]]) and not(eof(fido))) Do
                    Begin
                         If length(tempstr) <= l Then
                            Begin
                            Fillchar(tempstr[succ(length(tempstr))], l-length(tempstr), #$20);
                            tempstr[0] :=char(l);
                            tempstr := concat(tempstr, '[FiDo] No description available yet.')
                            End;
                         If tempstr[l+7] = ' ' Then
                            Begin
                                 inc(areasstillnoflow)
                            end
                          Else
                           Begin
                                inc(areasnoflow);
                                tempstr[l+7] := ' '
                           End;
                         Writeln(NewFido, tempstr);
                         ReadLn(fido, tempstr)
                    End;
              ASM
                 cld               {This part copies the areaname out of}
                 push ds           {tempstr to tempstr2.}
                 lea di, tempstr
                 pop es
                 mov al, ' '
                 xor bx, bx
                 mov bl, [es:di]
                 cmp bl, l+1
                 ja @length_ok
                 inc bl
                 mov [es:di+bx], al
                @length_ok:
                 inc di
                 mov cx, l+1
                 mov bx, l
                 repne scasb
                 sub bx, cx
                 push ss
                 mov cx, bx
                 lea si, tempstr+1
                 pop es
                 lea di, tempstr2
                 mov [es:di], cl
                 inc di
                 shr cx, 1
                 jnc @even
                 movsb
                @even:
                 rep movsw
              END;
              If tempstr2 = areas^.area[asort[c1]] Then
                 Begin
                      If length(tempstr) <= l Then
                         Begin
                              Fillchar(tempstr[succ(length(tempstr))],l-length(tempstr), #$20);
                              tempstr[0] := char(l);
                              tempstr := concat(tempstr, '[FiDo]*No description available yet.')
                              End;
                      If tempstr[l+7] = '*' Then inc(areasstillactive)
                         Else
                             Begin
                               tempstr[l+7] := '*';
                               inc(areasactivated)
                             End;
                      Writeln(NewFido, tempstr);
                      Readln(fido,tempstr)
                 End
               Else
                   Begin
                        newareas[newareascount] := c1;
                        inc(newareascount);
                        tempstr2 := areas^.area[asort[c1]];
                        For c2 := 1 to (l-length(areas^.area[asort[c1]])) Do
                            tempstr2 := concat(tempstr2,' ');
                        tempstr2 := concat(tempstr2, '[FiDo]*New added area. No description available yet.');
                        WriteLn(newfido,tempstr2)
                        End
           End
       End
      Else
         With areas^ Do
          Begin
              For c1 := 0 to nofareas Do
                  Begin
                       tempstr2 := area[asort[c1]];
                       For c2 := 1 to (l-length(area[asort[c1]])) Do
                            tempstr2 := concat(tempstr2,' ');
                        tempstr2 := concat(tempstr2, '[FiDo]*New added area. No description available yet.');
                        WriteLn(newfido,tempstr2)
                        End
       End;
     If fidoexists Then Writeln('"Fidonet.na" has been successfully updated!')
                    Else Writeln('"Fidonet.na" has been successfully created!');
                    Writeln;
     Writeln('Updating logfile (bbscan.log)...');
     Writeln;
     Getdate(y, m, d, dofw);
     Write(logfile,'---------- ',days[dofw],', ', d:0,'/',m:0,'/',y:0,', ');
     Gettime(y, m, d, dofw);
     str(y,h);
     str(m,min);
     str(d,s);
     If length(h) = 1 Then h := concat('0',h);
     If length(min) = 1 Then min := concat('0',min);
     If length(s) = 1 Then s := concat('0',s);
     Writeln(logfile, h,':',min,':',s,'.');
     If (newareascount > 0) Then
             Begin
                  Writeln(logfile, 'New Areas:');
                  For c1 := 0 to pred(newareascount) Do
                      Begin
                           Write(logfile, areas^.area[asort[newareas[c1]]]:38);
                           If (succ(c1) mod 2 = 0) Then Writeln(logfile)
                           End
             End;
     If (succ(c1) mod 2 <> 0) Then Writeln(logfile);
     Writeln(logfile);
     If not(fidoexists) Then newareascount := areas^.nofareas;
     Writeln(logfile, 'Amount of new areas:   ',newareascount);
     Writeln(logfile, 'Areas still active:    ',areasstillactive,'.');
     Writeln(logfile, 'Areas activated:       ',areasactivated,'.');
     Writeln(logfile, 'Areas still down:      ',areasstillnoflow,'.');
     Writeln(logfile, 'Areas deactivated:     ',areasnoflow,'.');
     Writeln(logfile, 'Total number of areas:',newareascount+areasstillactive+areasactivated+areasstillnoflow+areasnoflow,'.');
     Writeln(logfile);
     close(logfile);
     close(newfido);
     close(fido);
    {$i-}
     assign(logfile, 'fidonet.bak');
     Erase(logfile);
     rename(fido, 'fidonet.bak');
     rename(newfido, 'fidonet.na')
    {$i+}
End;

Begin
     Init;
     ReadareaNames;
     sort;
     update
END.


