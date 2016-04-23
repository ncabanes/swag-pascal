{
RN > Howdy All!

RN > I "had" a small external program, that ran as a module for
RN > one of my larger products.  This module allowed formatting
RN > of floppy disks.

RN > Since WIN95 this program no longer works, returns errors.

RN > From my reading, is seems that DOS programs using IRQ ummmm,
RN > 25 and ?? conflict with WIN95 system, unless they LOCK the
RN > volume.

and Interrupt 13h, interrupt 26h and IOCTL functions

RN > Can anybody tell me how, in a DOS program, to LOCK the
RN > volume ID so that the floppy in that drive might be
RN > formatted, under WIN95 OS?

I use:


------------------------- Cut begin (TEMP.TMP) ---------------------------
}
Function Lock(DNum:Byte):Boolean;
Var
  fejl : Byte;
Begin
  {$ifdef Windows}
  Lock:=True;
  If ((GetWinFlags and $4000)>0) or (Hi(LoWord(GetVersion))<20) Then Exit;
  {$Endif}
  Asm
    Mov fejl,1      {Nothing is OK yet}
    Mov ax,440dh    {generic IOCTL}
    Mov bh,0        {Lock level, first lock on drive}
    Mov bl,DNum     {Number of drive}
    Mov ch,08h      {device catagory (Must be 08h)}
    Mov cl,4bh      {Lock physical volume}
    Mov dx,0b       {Permisions (First lock=0)}
    {$ifdef Windows}
    Call Dos3Call   {Do it}
    {$Else}
    Int 21h
    {$Endif}
    jc @@Error      {Error?}
    Mov ax,440dh    {generic IOCTL}
    Mov bh,0        {Lock level, second lock on drive}
    Mov bl,DNum     {Number of drive}
    Mov ch,08h      {Device catagory (Must be 08h)}
    Mov cl,4bh      {Lock physical volume}
    Mov dx,100b     {Lock for format}
    {$ifdef Windows}
    Call Dos3Call   {Do it}
    {$Else}
    Int 21h
    {$Endif}
    jc @@Error2     {Error?}
    Mov Fejl,0      {No, no error here}
    Jmp @@Error     {End this function}
    @@Error2:
    Mov ax,440dh    {Unlock first lock, if second failed}
    Mov bl,DNum     {Number of drive}
    Mov ch,08h      {Device catagory (Must be 08h)}
    Mov cl,6bh      {Unlock physical volume}
    {$ifdef Windows}
    Call Dos3Call   {Do it}
    {$Else}
    Int 21h
    {$Endif}
    @@Error:
  End;
  Lock:=(Fejl=0);
End;

Procedure UnLock(DNum:Byte);
Begin
  {$ifdef Windows}
  If ((GetWinFlags and $4000)>0) or (Hi(LoWord(GetVersion))<20) Then Exit;
  {$Endif}
  Asm
    Mov ax,440dh    {Generic IOCTL}
    Mov bl,DNum     {Drive number}
    Mov ch,08h      {Device catagory (Must be 08h)}
    Mov cl,6bh      {Unlock physical volume}
    {$ifdef Windows}
    Call Dos3Call   {Do it}
    {$Else}
    Int 21h
    {$Endif}
    Mov ax,440dh    {Generic IOCTL}
    Mov bl,DNum     {Drive number}
    Mov ch,08h      {Device catagory (Must be 08h)}
    Mov cl,6bh      {Unlock physical volume}
    {$ifdef Windows}
    Call Dos3Call   {Do it}
    {$Else}
    Int 21h
    {$Endif}
  End;
End;

-------------------------- Cut end (TEMP.TMP)-----------------------------

It is used in this way:

If Lock(Drive) then begin
  Format(Drive) {or whatever}
  UnLock(Drive);
End;


The drives are numbered: A=0 B=1
