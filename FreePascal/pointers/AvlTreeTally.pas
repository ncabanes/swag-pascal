(*
  Category: SWAG Title: POINTERS, LINKING, LISTS, TREES
  Original name: 0025.PAS
  Description: Avl Tree Tally
  Author: MATT BOUSEK
  Date: 08-24-94  14:00
*)

(*
Here is TALLY.PAS, a program that Matt Bousek <MBOUSEK@intel9.intel.com> wrote
to do a word frequency analysis on a text file.  It uses an AVL tree.  It
should compile under TP 6.0 or BP 7.0
*)
program word_freq(input,output);

type
    short_str = string[32];

{************AVLtree routines*********}
type
    balance_set = (left_tilt,neutral,right_tilt);
    memptr      = ^memrec;
    memrec = record
        balance     : balance_set;
        left,right  : memptr;
        count       : longint;
        key         : short_str;
    end;

    {**************************************}
    procedure rotate_right(var root:memptr);
    var ptr2,ptr3 : memptr;
    begin
        ptr2:=root^.right;
        if ptr2^.balance=right_tilt then begin
            root^.right:=ptr2^.left;
            ptr2^.left:=root;
            root^.balance:=neutral;
            root:=ptr2;
        end else begin
            ptr3:=ptr2^.left;
            ptr2^.left:=ptr3^.right;
            ptr3^.right:=ptr2;
            root^.right:=ptr3^.left;
            ptr3^.left:=root;
            if ptr3^.balance=left_tilt
                then ptr2^.balance:=right_tilt
                else ptr2^.balance:=neutral;
            if ptr3^.balance=right_tilt
                then root^.balance:=left_tilt
                else root^.balance:=neutral;
            root:=ptr3;
        end;
        root^.balance:=neutral;
    end;

    {*************************************}
    procedure rotate_left(var root:memptr);
    var ptr2,ptr3 : memptr;
    begin
        ptr2:=root^.left;
        if ptr2^.balance=left_tilt then begin
            root^.left:=ptr2^.right;
            ptr2^.right:=root;
            root^.balance:=neutral;
            root:=ptr2;
        end else begin
            ptr3:=ptr2^.right;
            ptr2^.right:=ptr3^.left;
            ptr3^.left:=ptr2;
            root^.left:=ptr3^.right;
            ptr3^.right:=root;
            if ptr3^.balance=right_tilt
                then ptr2^.balance:=left_tilt
                else ptr2^.balance:=neutral;
            if ptr3^.balance=left_tilt
                then root^.balance:=right_tilt
                else root^.balance:=neutral;
            root:=ptr3;
        end;
        root^.balance:=neutral;
    end;

    {*****************************************************************}
    procedure insert_mem(var root:memptr; x:short_str; var ok:boolean);
    begin
        if root=nil then begin
            new(root);
            with root^ do begin
                key:=x;
                left:=nil;
                right:=nil;
                balance:=neutral;
                count:=1;
            end;
            ok:=true;
        end else begin
            if x=root^.key then begin
                ok:=false;
                inc(root^.count);
            end else begin
                if x<root^.key then begin
                    insert_mem(root^.left,x,ok);
                    if ok then case root^.balance of
                        left_tilt  : begin
                                rotate_left(root);
                                ok:=false;
                            end;
                        neutral    : root^.balance:=left_tilt;
                        right_tilt : begin
                                root^.balance:=neutral;
                                ok:=false;
                            end;
                    end;
                end else begin
                    insert_mem(root^.right,x,ok);
                    if ok then case root^.balance of
                        left_tilt  : begin
                                root^.balance:=neutral;
                                ok:=false;
                            end;
                        neutral    : root^.balance:=right_tilt;
                        right_tilt : begin
                                rotate_right(root);
                                ok:=false;
                            end;
                    end;
                end;
            end;
        end;
    end;

    {*****************************************************}
    procedure insert_memtree(var root:memptr; x:short_str);
    var ok:boolean;
    begin
        ok:=false;
        insert_mem(root,x,ok);
    end;

    {*********************************}
    procedure dump_mem(var root:memptr);
    begin
        if root<>nil then begin
            dump_mem(root^.left);
            writeln(root^.count:5,' ',root^.key);
            dump_mem(root^.right);
        end;
    end;


{MAIN***************************************************************}
{*** This program was written by Matt Bousek sometime in 1992.   ***}
{*** The act of this posting over Internet makes the code public ***}
{*** domain, but it would be nice to keep this header.           ***}
{*** The basic AVL routines came from a book called "Turbo Algo- ***}
{*** rythms",  Sorry, I don't have the book here and I can't     ***}
{*** remember the authors or publisher.  Enjoy.  And remember,   ***}
{*** there is no free lunch...                                   ***}

const
    wchars:set of char=['''','a'..'z'];

var
    i,j         : word;
    aword       : short_str;
    subject     : text;
    wstart,wend : word;
    inword      : boolean;
    linecount   : longint;
    wordcount   : longint;
    buffer      : array[1..10240] of char;
    line        : string;
    filename    : string;
    tree        : memptr;

BEGIN
    tree:=nil;

    filename:=paramstr(1);
    if filename='' then filename:='tally.pas';
    assign(subject,filename);
    settextbuf(subject,buffer);
    reset(subject);

    wordcount:=0;
    linecount:=0;
    while not eof(subject) do begin
        inc(linecount);
        readln(subject,line);
        wstart:=0; wend:=0;
        for i:=1 to byte(line[0]) do begin
            if line[i] in ['A'..'Z'] then line[i]:=chr(ord(line[i])+32);
            inword:=(line[i] in wchars);
            if inword and (wstart=0) then wstart:=i;
            if inword and (wstart>0) then wend:=i;
            if not(inword) or (i=byte(line[0])) then begin
                if wend>wstart then begin
                    aword:=copy(line,wstart,wend+1-wstart);
                    j:=byte(aword[0]);
                    if (aword[j]='''') and (j>2) then begin {lose trailing '}
                        aword:=copy(aword,1,j-1);
                        dec(wend);
                        dec(j);
                    end;
                    if (aword[1]='''') and (j>2) then begin {lose leading '}
                        aword:=copy(aword,2,j-1);
                        inc(wstart);
                        dec(j);
                    end;
                    if (j>2) and (aword[j-1]='''') and (aword[j]='s') then
begin {lose trailing 's}
                        aword:=copy(aword,1,j-2);
                        dec(wend,2);
                        dec(j,2);
                    end;
                    if (j>2) then begin
                        inc(wordcount);
                        insert_memtree(tree,aword);
                    end;
                end; { **if wend>wstart** }
                wstart:=0; wend:=0;
            end; { **if not(inword)** }
        end; { **for byte(line[0])** }
    end; { **while not eof** }

dump_mem(tree);
writeln(linecount,' lines, ',wordcount,' words.');
END.
