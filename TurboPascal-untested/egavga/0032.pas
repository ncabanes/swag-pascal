{
 Hi..  I am trying to do animation by flipping the two images between
 the video pages, but I keep getting lines at the bottom of my screen,
 and my screen color changes..  What's up here?
 Did you synchronize to the {vertical|horizontal retrace beFore
 flipping? I don't know how to do this, so any helpfull code from you will
 be appreciated. I took this out of my ANIVGA-Unit:

At the very beginning of your Program, detect the address of the proper port
(StatusReg is a global Word Variable):
}

 Asm  {check whether we are running on a monochrome or color monitor}
   MOV DX,3CCh  {ask Output-register:}
   in AL,DX
   TEST AL,1    {is it a color monitor?}
   MOV DX,3D4h
   JNZ @L1      {yes}
   MOV DX,3B4h  {no }
  @L1:          {DX=3B4h/3D4h = CrtAddress-register For monochrome/color}
{ MOV CrtAddress,DX  not needed For this purpose}
   ADD DX,6     {DX=3BAh/3DAh = Status-register For monochrome/color}
   MOV StatusReg,DX
 end; {of Asm}

{
Later on, when you want to switch pages:

   CLI {time critical routine: do not disturb!}
    mov dx,StatusReg
  @WaitnotVSyncLoop:
    in   al,dx
    and  al,8
    jnz  @WaitnotVSyncLoop
  @WaitVSyncLoop:
    in   al,dx
    and  al,8
    jz   @WaitVSyncLoop
{
    HERE! SWITCH PAGES NOW!!! IMMEDIATELY! do not USE BIOS-inTS or OTHER
    TIME-WASTERS!
}
   STI
{
Well, that's all there is... if you replace the 2 "and al,8" against "and al,1"
and exchange jnz<->jz, you are syncronizing at the horizontal retrace. But this
signal is extremely short (at least Compared With the vertical retr.).
}
