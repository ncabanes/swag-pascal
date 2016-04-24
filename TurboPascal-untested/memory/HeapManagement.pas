(*
  Category: SWAG Title: MEMORY/DPMI MANAGEMENT ROUTINES
  Original name: 0085.PAS
  Description: Heap Management
  Author: ANDY COOPER
  Date: 09-04-95  10:51
*)


Unit HeapChk;
{$R-,S-}

(************************************************************************
 *                                                                      *
 *                             HeapChk.pas                              *
 *                                                                      *
 *                     Copyright (c) Andy Cooper 1991                   *
 *                                                                      *
 *     May be used and distributed for non commercial use without       *
 *     restriction.  All commercial rights reserved.                    *
 *                                                                      *
 *                                                                      *
 *   WARNING:  This code may be version specific and has been tested    *
 *             with Turbo Pascal version 6.0 only.  Must be compiled    *
 *             with range and stack checking off.                       *
 *                                                                      *
 *                                                                      *
 *   The unit HeapChk MUST be the first unit in the uses statement of   *
 *   the primary file.  It does not (and in fact should not) have to be *
 *   included in any other units.                                       *
 *                                                                      *
 *   On exit from the program the file HEAPCHK.TXT will contain         *
 *   information about the run.                                         *
 *                                                                      *
 *   HeapChk error triggers                                             *
 *                                                                      *
 *      If an attempt is made to return a heap area that does not       *
 *      match the original allocation an error is flagged and the       *
 *      contents of the heap structure is written to the file.          *
 *                                                                      *
 *      If an attempt is made to return a non existing heap area the    *
 *      contents of the heap structure is written to the file.          *
 *                                                                      *
 *      If RELEASE is called with free heap areas below the MARK,       *
 *      turbo pascal discards the memory instead of returning it.       *
 *      HeapChk flags this condition, sums the areas lost and           *
 *      optionally lists the areas to be discarded                      *
 *                                                                      *
 *      If HeapChk determines that the freelist is corrupted an error   *
 *      is flagged.                                                     *
 *                                                                      *
 *   Content of HEAPCHK.TXT                                             *
 *                                                                      *
 *      Heapchk.txt contains an entry for every error condition         *
 *      encountered.  If level is > 2 then the program will be          *
 *      terminated otherwise a warning is recorded.                     *
 *                                                                      *
 *      The error or warning printout will contain one line for each    *
 *      active heap area consisting of the pointer value returned,      *
 *      requested length, address of instruction AFTER the call to      *
 *      NEW / GETMEM and a best guess at the caller to the procedure    *
 *      that issued the getmem.  This is useful for turbovision etc     *
 *      as you can find where you were in your code, ie where were      *
 *      you when you called the tv procedure.  To use these addresses   *
 *      run the program under turbo debugger, obtain the printout, then *
 *      use the GO <ctrl-g> function to find the calling code.  NOTE    *
 *      the IDE find error function does not work.                      *
 *                                                                      *
 *      There will be an entry for each call to MARK and if the free    *
 *      list is corrupted it will be dumped.                            *
 *                                                                      *
 *                                                                      *
 ************************************************************************)

interface
  procedure displaystats;

const
  level           = 2;              {> 2 causes error halt, <= 2 warning}
  prtreleaseon    = false;          {if true dumps heap areas discarded }
                                    {when release is called             }

  hex : array[0..15] of char = '0123456789abcdef';

  precsize        = 500;            {maximum number of pointer entries}
  Heaprec         = 1;
  Markrec         = 2;

  ptrofl          = 1;
  ptrnotfound     = 2;
  ptrbadlength    = 3;
  getmembusyerr   = 4;
  freemembusyerr  = 5;
  BadFreeList     = 6;
  markrecnotfound = 7;
  CannotMark      = 8;
  CannotRelease   = 9;

  errorcodes : array[1..9] of string[60] =
    ('Internal Error - Heap structure overflow',
     'Program Error - Attempting to return non-allocated memory',
     'Program Error - FreeMem length does not match area allocated',
     'Internal Error - Recursive call to getmem',
     'Internal Error - Recursive call to freemem',
     'Heap Failure - Free List Corrupted',
     'Release failed - No matching mark pointer',
     'Mark Failed - Free list not empty',
     'Release Failed - Free list not empty'
     );

type
  prec = record
           p           : pointer;
           l,
           f           : word;
           caller,                   {address of next instruction after }
                                     {the code that called getmem       }
           pcaller     : pointer;    {"best guess" at the previous caller}
         end;

  freelst = record
              next  : pointer;
              bytes,
              paras : word;
            end;

  fake = record
           case boolean of
             true  : (ptr : pointer);
             false : (pofs,
                      pseg  : word)
           end;

var
  getmembusyflag,
  freemembusyflag : word;
  pprev,
  pretto,
  pgetmem,
  pfreemem        : pointer;
  orphaned,
  lostheap,
  lg,lf,lm,lr     : longint;
  precarray       : array[1..precsize] of prec;
  pindx           : integer;
  savexit         : pointer;
  lfile           : text;
  progname        : string[80];

implementation
uses
  crt,printer;

procedure displaystats;
  begin
    writeln('There were ',lg,' calls to new/getmem');
    writeln('There were ',lf,' calls to dispose/freemem');
    writeln('There were ',lm,' calls to mark');
    writeln('There were ',lr,' calls to release');
    writeln('There were ',lostheap,' Bytes lost');
  end;

function hexptr(p:pointer):string;
  var
    f : fake;
    s : string;
  begin
    f.ptr := p;
    s[1] := hex[(hi(f.pseg) shr 4)];
    s[2] := hex[hi(f.pseg) and $f];
    s[3] := hex[(lo(f.pseg) shr 4)];
    s[4] := hex[lo(f.pseg) and $f];
    s[5] := ':';
    s[6] := hex[(hi(f.pofs) shr 4)];
    s[7] := hex[hi(f.pofs) and $f];
    s[8] := hex[(lo(f.pofs) shr 4)];
    s[9] := hex[lo(f.pofs) and $f];
    s[0] := chr(9);
    hexptr := s
  end;

procedure prtrec(i:integer);
  begin
    write(lfile,i:4,' Ptr = ',hexptr(precarray[i].p),
                            ' Len = ',precarray[i].l:5,
                            '  Caller = ',hexptr(precarray[i].caller),
                            '  PCaller = ',hexptr(precarray[i].pcaller));
    if precarray[i].f = markrec then
      writeln(lfile,' Mark Record')
    else
      writeln(lfile);
  end;

procedure error(errno:word;p:pointer;l:word);
  {called on error if level > 2}
  var
    i : integer;
  begin
    writeln(lfile,errorcodes[errno]);
    writeln(lfile,'Ptr = ',hexptr(p),' Len = ',l);
    if errno = cannotrelease then
      writeln(lfile,'Freelist = ',hexptr(freelist));
    writeln(lfile,'******* Dump of heap structure *******');
    for i := 1 to pindx do
      prtrec(i);
    writeln(lfile,'******* End of heap structure *******'#13#10);
    window(1,1,80,25);
    normvideo;
    clrscr;
    halt;
  end;

procedure warning(errno:word;p:pointer;l:word);
  {called on error if level <= 2}
  var
    i : integer;
  begin
    writeln(lfile,errorcodes[errno]);
    writeln(lfile,'Ptr = ',hexptr(p),' Len = ',l);
    if errno = cannotrelease then
      writeln(lfile,'Freelist = ',hexptr(freelist));
    writeln(lfile,'******* Dump of heap structure *******');
    for i := 1 to pindx do
      prtrec(i);
    writeln(lfile,'******* End of heap structure *******'#13#10);
  end;

function NormPtr(p:pointer):longint;
  {normalize pointer}
  var
    sp : fake;
    l  : longint;
  begin
    sp.ptr := p;
    l := sp.pseg;
    l := l*16;
    l := l + sp.pofs;
    NormPtr := l;
  end;

procedure CheckFreeList;
  var
    p    : pointer;
    lhp,
    lho,
    lhf  : longint;

  begin
    p := freelist;
    lhp := NormPtr(HeapPtr);
    lho := NormPtr(HeapOrg);
    while p <> heapptr do
      begin
        lhf := NormPtr(p);
        if (lhf > lhp) or (lhf < lho) then
          error(BadFreelist,p,0)
        else
          p := freelst(p^).next
      end;
  end;

procedure PrintFreeList;
  var
    p    : pointer;
    lhf,
    lhp,
    lho  : longint;

  begin
    p := freelist;
    lhp := NormPtr(HeapPtr);
    lho := NormPtr(HeapOrg);
    writeln(lfile,'********** Dump of Free List *********');
    while p <> heapptr do
      begin
        lhf := NormPtr(p);
        if (lhf > lhp) or (lhf < lho) then
          error(BadFreelist,p,0)
        else
          begin
            writeln(lfile,' Ptr = ',hexptr(p),' Len = ',freelst(p^).bytes+freelst(p^).paras shl 2);
            p := freelst(p^).next
          end;
      end;
    writeln(lfile,'********** End of Free List *********'#13#10);
  end;

procedure delrec(indx:integer);
  {delete record from array}
  begin
    if indx <> pindx then
      move(precarray[indx+1],precarray[indx],(pindx-indx) shl 4);
    dec(pindx)
  end;

procedure MyMark(var p:pointer);far;
  {Duplicate tp mark instead of hooking entry point}
  begin
    inc(lm);
    checkfreelist;
    if heapptr <> freelist then
      if level > 2 then
        error(CannotMark,p,0)
      else
        warning(CannotMark,p,0);
    p := heapptr;
    if pindx+1 > precsize then
      error(ptrofl,nil,pindx);
    inc(pindx);
    precarray[pindx].p := heapptr;
    precarray[pindx].f := Markrec;
    precarray[pindx].l := 0;
    precarray[pindx].caller := nil;
    precarray[pindx].pcaller := nil;
  end;

procedure MyRelease(var p:pointer);far;
  {duplicate tp release instead of hooking entry point}
  var
    i : integer;
    l,
    lhp,
    lhf  : longint;
  begin
    inc(lr);
    checkfreelist;
    if normptr(freelist) < normptr(p) then
      if level > 2 then
        error(CannotRelease,p,0)
      else
        warning(CannotRelease,p,0);
    i := pindx;
    while (i>0) and not ((precarray[i].p=p) and (precarray[i].f=MarkRec)) do
      dec(i);
    if i = 0 then
      error(MarkRecNotFound,p,0);
    if normptr(freelist) < normptr(p) then
      printfreelist;

    lhp := normptr(p);
    while freelist <> heapptr do
      begin
        lhf := NormPtr(freelist);
        if lhf < lhp then
          lostheap := lostheap + freelst(freelist^).bytes+freelst(freelist^).paras shl 2;
        freelist := freelst(freelist^).next
      end;

    delrec(i);                          {delete mark record}
    {******************************}
    {   This is waht tp does!!!    }
    heapptr := p;
    freelist := p;
    {******************************}
    i := 1;
    l := NormPtr(p);
    if prtreleaseon then
      writeln(lfile,'****** Discarding Pointers above ',hexptr(p),' ******');
    while i <= pindx do
      if l > NormPtr(Precarray[i].p) then
        inc(i)
      else
        begin
          if prtreleaseon then
            prtrec(i);
          DelRec(i);
        end;
    if prtreleaseon then
      writeln(lfile,'**************** End of Discard ****************');
  end;

procedure Getmem_Return;assembler;
    { this code intercepts the return from tp's heap allocation
      stuff and stores the actual pointer value into the array}
    asm
        add  [word ptr lg],1
        jnc  @@1
        inc  [word ptr lg+2]
        @@1:
        dec  getmembusyflag
        mov  bx,pindx
        inc  pindx
        shl  bx,1                   {pindx * 16}
        shl  bx,1
        shl  bx,1
        shl  bx,1
        add  bx,offset precarray    {heap record base}
        mov  [bx],ax                {store returned pointer}
        mov  [bx+2],dx
        mov  bx,offset pretto       {retrieve return to address}
        jmp  dword ptr [bx]         { and jump }
    end;

procedure Intercept_Getmem;assembler;
    asm
        mov  ax,[bp+2]                  {take a guess at the previous}
        mov  [word ptr pprev],ax        {procedure call return address}
        mov  ax,[bp+4]
        mov  [word ptr pprev+2],ax
        push bp                          {duplicate original code}
        mov  bp,sp
        cmp  getmembusyflag,0
        je   @@1
        mov  ax,getmembusyerr
        push ax
        xor  ax,ax
        push ax
        push ax
        push ax
        call error
        @@1:
        call CheckFreelist
        inc  getmembusyflag
        mov  ax,[bp+2]                   {intercept return address}
        mov  [word ptr pretto],ax        {from getmem and...}
        mov  ax,[bp+4]
        mov  [word ptr pretto+2],ax
        mov  ax,offset Getmem_Return     {replace it with ours}
        mov  [bp+2],ax
        mov  ax,seg Getmem_Return
        mov  [bp+4],ax

        mov  bx,pindx                    {get heap buffer indx}
        inc  bx
        cmp  bx,precsize                 {check it for overflow}
        jle  @@2
        mov  ax,ptrofl
        push ax
        xor  ax,ax
        push ax
        push ax
        push ax
        call error                      {display error and halt}

      @@2:
        dec  bx
        shl  bx,1                       {pindx * 16}
        shl  bx,1
        shl  bx,1
        shl  bx,1
        add  bx,offset precarray        {base of array}
        mov  ax,HeapRec
        mov  [bx+6],ax                  {flag Heaprec}
        mov  ax,[word ptr pretto]       {Callers address}
        mov  [bx+8],ax
        mov  ax,[word ptr pretto+2]
        mov  [bx+10],ax
        mov  ax,[word ptr pprev]       {Callers address}
        mov  [bx+12],ax
        mov  ax,[word ptr pprev+2]
        mov  [bx+14],ax
        {**********  This must be last as ax must contain length *********}
        mov  ax,[bp+6]                  {length of heap request}
        mov  [bx+4],ax                  {  to heap structure}
        mov  bx,offset pgetmem
        jmp  dword ptr [bx]             {jump back to execute getmem}
    end;

procedure Intercept_Freemem;assembler;
  { on entry the stack contains a pointer to the memory to be freed and
    it's length.  The operation is verified and then the heap freemem
    procedure is called.  Note that the ax register must be conditioned}

    asm push bp                          {duplicate existing code}
        mov  bp,sp
        cmp  FreememBusyFlag,0           {check for recursive call}
        je   @@1
        mov  ax,FreememBusyErr
        push ax
        xor  ax,ax
        push ax
        push ax
        push ax
        call error
      @@1:
        add  word ptr lf,1
        jnc  @@99
        inc  word ptr lf+2
      @@99:
        call CheckFreelist
        inc  FreememBusyFlag
        mov  bx,pindx
        mov  cx,bx
        shl  bx,1                       {pindx * 16}
        shl  bx,1
        shl  bx,1
        shl  bx,1
        add  bx,offset precarray        {base of array}
      @@2:
        jcxz @@3
        dec  cx
        sub  bx,16
        mov  ax,[bp+10]                 {check pointer segment}
        cmp  ax,[bx+2]                  { to stored values}
        jne  @@2
        mov  ax,[bp+8]                  {check pointer offset}
        cmp  ax,[bx]
        jne  @@2
        mov  ax,heaprec
        cmp  ax,[bx+6]
        jne  @@2                        {heap record}
        mov  ax,[bp+6]                  {check length of area}
        cmp  ax,[bx+4]
        je   @@4
        dec  freemembusyflag
        mov  ax,ptrbadlength            {pointer found but bad length}
        push ax
        mov  ax,[bp+10]
        push ax
        mov  ax,[bp+8]
        push ax
        mov  ax,[bp+6]
        push ax
        call error
      @@3:                              {attempting to return a non}
        dec  freemembusyflag
        mov  ax,ptrnotfound             { allocated area}
        push ax
        mov  ax,[bp+10]
        push ax
        mov  ax,[bp+8]
        push ax
        mov  ax,[bp+6]
        push ax
        call error
      @@4:                              {found a good area}
        inc  cx
        cmp  cx,pindx                   {if not last allocated then}
        je   @@5
        mov  ax,ds                      {  close up the hole}
        mov  es,ax
        mov  di,bx                      {addr of record to delete}
        mov  si,di
        add  si,16                      {addr of next record}
        mov  ax,pindx
        sub  ax,cx                      {number of records to move}
        mov  cx,ax
        shl  cx,1                       {  multiplied by 16}
        shl  cx,1
        shl  cx,1
        shl  cx,1
        cld
        rep  movsb
      @@5:
        dec  pindx                     {decrement heaparray ptr}
        dec  freemembusyflag
        mov  ax,[bp+6]
        mov  bx,offset pfreemem
        jmp  dword ptr [bx]
    end;

procedure Find_Procs;far;
  label
    lmark,
    lgetmem,
    lfreemem,
    lrelease;
  var
    tmp : pointer;
  begin
    asm
      {*********************************************
       retrieve the address of the getmem procedure
       and patch in the intercept code
       *********************************************}
        mov  bx,offset lgetmem
        add  bx,5
        mov  ax,word ptr [cs:bx]
        mov  [word ptr pgetmem],ax
        add  [word ptr pgetmem],6
        inc  bx
        inc  bx
        mov  dx,word ptr [cs:bx]
        mov  [word ptr pgetmem+2],dx
        mov  es,dx
        mov  bx,ax
        mov  byte ptr [es:bx],$EA  {jmp far}
        mov  ax,offset Intercept_Getmem
        inc  bx
        mov  word ptr [es:bx],ax
        mov  ax,seg Intercept_Getmem
        inc  bx
        inc  bx
        mov  word ptr [es:bx],ax
        mov  al,$90
        inc  bx
        inc  bx
        mov  byte ptr [es:bx],al

      {********************************************
       Now get the address of the freemem procedure
       and patch in the intercept code
       ********************************************}
        mov  bx,offset lfreemem
        add  bx,11
        mov  ax,word ptr [cs:bx]
        mov  [word ptr pfreemem],ax
        add  [word ptr pfreemem],6
        inc  bx
        inc  bx
        mov  dx,word ptr [cs:bx]
        mov  [word ptr pfreemem+2],dx
        mov  es,dx
        mov  bx,ax
        mov  byte ptr [es:bx],$EA  {jmp far}
        mov  ax,offset Intercept_Freemem
        inc  bx
        mov  word ptr [es:bx],ax
        mov  ax,seg Intercept_Freemem
        inc  bx
        inc  bx
        mov  word ptr [es:bx],ax
        mov  al,$90
        inc  bx
        inc  bx
        mov  byte ptr [es:bx],al
      {********************************************
       Now get the address of the Mark procedure
       and patch in the intercept code
       ********************************************}
        mov  bx,offset lmark
        add  bx,6
        mov  bx,word ptr [cs:bx]
        mov  byte ptr [es:bx],$EA  {jmp far}
        mov  ax,offset MyMark
        inc  bx
        mov  word ptr [es:bx],ax
        mov  ax,seg MyMark
        inc  bx
        inc  bx
        mov  word ptr [es:bx],ax
        mov  al,$90
        inc  bx
        inc  bx
        mov  byte ptr [es:bx],al
      {********************************************
       Now get the address of the Release procedure
       and patch in the intercept code
       ********************************************}
        mov  bx,offset lRelease
        add  bx,6
        mov  bx,word ptr [cs:bx]
        mov  byte ptr [es:bx],$EA  {jmp far}
        mov  ax,offset MyRelease
        inc  bx
        mov  word ptr [es:bx],ax
        mov  ax,seg MyRelease
        inc  bx
        inc  bx
        mov  word ptr [es:bx],ax
        mov  al,$90
        inc  bx
        inc  bx
        mov  byte ptr [es:bx],al
        mov  sp,bp
        pop  bp
        retf
    end;
    lgetmem:
    getmem(tmp,1);
    lfreemem:
    freemem(tmp,1);
    lmark:
    mark(tmp);
    lrelease:
    release(tmp);
  end;

procedure cleanup;far;
  var
    i        : integer;

  begin
    if pindx > 0 then
      begin
        orphaned := 0;
        writeln(lfile,'******* Unreleased Heap On Exit *******');
        for i := 1 to pindx do
          begin
            orphaned := orphaned+precarray[i].l;
            prtrec(i);
          end;
        writeln(lfile,'******* End of Unreleased Heap ********'#13#10);
      end;
    writeln(lfile,#13#10'        ******* Total heap operations *******');
    writeln(lfile,'   Gets      Frees      Marks     Releases  Lost Heap  Orphaned Heap');
    writeln(lfile,'---------- ---------- ---------- ---------- ---------- -------------');
    writeln(lfile,lg:10,' ',lf:10,' ',lm:10,' ',lr:10,' ',lostheap:10,' ',Orphaned:13);
    close(lfile);
    exitproc := savexit;
  end;

begin
  progname := paramstr(0);
  lg := 0;
  lf := 0;
  lm := 0;
  lr := 0;
  lostheap := 0;
  orphaned := 0;
  getmembusyflag := 0;
  freemembusyflag := 0;
  pindx := 0;
  assign(lfile,'heapchk.txt');
  rewrite(lfile);
  Writeln(lfile,'Heap Data for program ',progname,#13#10);
  savexit := exitproc;
  exitproc := @cleanup;
  Find_Procs;
end.
