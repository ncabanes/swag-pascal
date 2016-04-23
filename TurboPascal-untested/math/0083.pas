{
I wrote the following program for an introductory computer science course.
It was written in Turbo Pascal, but I believe everything in it is standard,
so it should work fine with Think Pascal.
pgriswold@delphi.com
}

type
    ComplexType = record          {Complex number ADT}
        RealPart      : real;     {Real portion of complex number}
        ImaginaryPart : real;     {Imaginary part of complex number}
    end;

var
    Complex1,                     {First complex number}
    Complex2,                     {Second complex number}
    Result : ComplexType;         {Result of current operation}


procedure OutputNumber(ComplexNumber : ComplexType);
{  Displays complex number in a+bi format.

    Pre Condition:  ComplexNumber is defined;
   Post Condition:  Complex number is written to the screen in a+bi format
}
begin {OutputNumber}
    writeln(ComplexNumber.RealPart:0:4,' + ',ComplexNumber.ImaginaryPart:0:4,
'i');
end;  {OutputNumber}
 
 
 
function Magnitude(ComplexNumber : ComplexType) : real;
{  Determines the magnitude of a complex number.
 
    Pre Condition:  ComplexNumber is defined;
   Post Condition:  Magnitude of complex number is returned.
}
begin  {Magnitude}
    Magnitude :=
sqrt(sqr(ComplexNumber.RealPart)+sqr(ComplexNumber.ImaginaryPar
t));
end;   {Magnitude}
 
 
 
procedure AddComplex(Complex1,Complex2 : ComplexType;
                     var Result : ComplexType);
{   Adds two complex numbers.
 
     Pre Condition:  Complex1 and Complex2 are defined;
    Post Condition:  Result contains the sum of Complex1 and Complex2
}
begin  {AddComplex}
    Result.RealPart := Complex1.RealPart + Complex2.RealPart;
    Result.ImaginaryPart := Complex1.ImaginaryPart + Complex2.ImaginaryPart;
end;   {AddComplex}
 
 
 
procedure MultiplyComplex(Complex1,Complex2 : ComplexType;
                          var Result : ComplexType);
{   Multiplies two complex numbers.
 
     Pre Condition:  Complex1 and Complex2 are defined;
    Post Condition:  Result contains the product of Complex1 and Complex2
}
begin  {MultiplyComplex}
    Result.RealPart := Complex1.RealPart * Complex2.RealPart -
        Complex1.ImaginaryPart * Complex2.ImaginaryPart;
    Result.ImaginaryPart := Complex1.Realpart * Complex2.ImaginaryPart +
        Complex2.RealPart * Complex1.ImaginaryPart;
end;   {MultiplyComplex}
 
 
 
procedure DivideComplex(Complex1, Complex2 : ComplexType;
                        var Result : ComplexType);
{   Divides two complex numbers.
 
     Pre Condition:  Complex1 and Complex2 are defined;
    Post Condition:  Result contains the quotient of Complex1 and Complex2
}
 
var tmp1, tmp2 : real;  {temporary variables}
 
begin   {DivideComplex}
 
    Tmp1 := sqr(Complex2.RealPart) + sqr(Complex2.ImaginaryPart);
    Tmp2 := (Complex1.RealPart * Complex2.RealPart +
        Complex1.ImaginaryPart * Complex2.ImaginaryPart)/Tmp1;
    Result.ImaginaryPart := (Complex1.ImaginaryPart * Complex2.RealPart +
        Complex1.RealPart * Complex2.ImaginaryPart)/Tmp1;
    Result.RealPart := tmp2;
end;   {DivideComplex}
 
 
 
begin  {driver}
    write('Enter Real Part of a:      ');
    readln(Complex1.RealPart);
    write('Enter Imaginary Part of a: ');
    readln(Complex1.ImaginaryPart);
    writeln;
 
    write('Enter Real Part of b:      ');
    readln(Complex2.RealPart);
    write('Enter Imaginary Part of b: ');
    readln(Complex2.ImaginaryPart);
    writeln;
 
    AddComplex(Complex1,Complex2,Result);
    write('Sum is ');
    OutputNumber(Result);
 
    MultiplyComplex(Complex1,Complex2,Result);
    write('Product is ');
    OutputNumber(Result);
 
    DivideComplex(Complex1,Complex2,Result);
    write('Quotient is ');
    OutputNumber(Result);
 
    writeln('Magnitude of a is ',Magnitude(Complex1):0:4);
    writeln('Magnitude of b is ',Magnitude(Complex2):0:4);
end.  {driver}
