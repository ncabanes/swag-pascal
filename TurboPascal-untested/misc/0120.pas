{
> Does anyone know how TP returns a string from a function?  Does it
> return a  pointer to the string in AX:DX?  I'm writing a data

BP (and probably TP) return a string at the memory location pointed
to by @Result .  @Result is a pointer type, and it's location can
be loaded into registers like    LES DI,@Result
}
