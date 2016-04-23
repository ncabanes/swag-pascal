{
> I think TP is fast enough for that, because your video card needs much
> time to display the screen. Perhaps this is a little bit faster on
> REALLY slow machines :

     Actually, that won't do what it's supposed to do...
     When you use the IN instruction the format is like this:

     IN op1,op2   That transfers a byte, word or dword from the in
                  op2 specified port into AL, AX or EAX.

> Asm
>   MOV DX,$03DA
> @@1:
>   IN  DX,AX     <-----  Therefore, change to: in al,dx
>   TEST AX,$08   <-----                        test al,8
>   JZ @@1
> @@2:
>   IN  DX,AX     <-----                        in al,dx
>   TEST AX,$08   <-----                        test al,8
>   JNZ @@2
> End;
}