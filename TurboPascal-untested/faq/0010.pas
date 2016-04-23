Top Ten Turbo Pascal Technical Support Questions


  1. How do you read and write a file inside a Turbo Pascal
     program?

     Answer: The following example demonstrates how to create,  
     write and read from a text file.

     Program FileDemo;
     Var FileVar : Text;
         InString,OutString : String;
     Begin
        OutString := 'Write this to a text file';
        Assign(FileVar,'TEST.TXT'); 
        Rewrite(FileVar);           {Creates a file for writing}
        Writeln(FileVar,OutString); 
        Close(FileVar);
        Assign(FileVar,'TEST.TXT'); 
        Reset(FileVar);      {Opens an existing file for reading}
        ReadLn(FileVar,InString);
        Close(FileVar);
     End.        
                 

  2. Where is the GRAPH.TPU file?

     Answer: The GRAPH.TPU is archived in the BGI.ARC file. Use
     the UNPACK.COM program to dearchive GRAPH.TPU from the
     BGI.ARC file. For example:  
     
         UNPACK BGI

  3. How do you send a program's output to the printer?

     Answer: Use the LST file variable declared in the PRINTER
     unit. For example:

         Program SendToPrinter;
         Uses Printer;
         Begin
           Writeln(LST,'This will go to the printer.');
         End.

  4. Why am I getting a "Unit file format error" when I compile
     my program with the new Turbo Pascal compiler?

     Answer: You are using a unit that has been compiled with a
     different Turbo Pascal version. From the main program, use 
     the BUILD option to recompile all dependent units.


  5. How do you dump graphics to a printer?

     Answer: Please see the enclosed Technical Information
     Handouts, #433 and #432, for examples of printing graphics
     on Epson compatible and HP Laser Jet printers.


  6. How do you communicate with the serial port?

     Answer: Modify the AuxInOut unit described in the Reference
     Guide as follows: To read incoming data, use the Reset
     procedure before reading. Also, you should read from a    
     buffer rather than directly from the serial port. 
     Furthermore, the AuxInOut is not an ideal example to use as
     input buffering is not supported;  you should use the    
     enclosed Technical Information Handout #407 routines for
     this purpose. 


  7. Why doesn't the Exec procedure execute my subprograms?

     Answer: Make certain that you use the {$M} directive to set
     the maximum heap size to the lowest possible value.  If this
     is done, check the value of the variable DosError to
     diagnose other problems. What is DosError Returning after
     the call: 
   
     8) Not enough Memory:  User needs to lower MAX Heap 
                            {$M Stack, Min, Max}    
     2) File not found:  User needs to specify the fill Path and
                         extension of the command.  If you're
                         trying to execute a DOS internal
                         command, you need to use COMMAND.COM
                         (see DIR example in manual).


  8. What do I do about running out of memory during compilation?

     Answer: There are a number of solutions to this problem:

      1. If Compiler/Destination is set to Memory, set it to Disk
         in the integrated environment.
      2. If Options/Compile/Link buffer in the integrated
         environment is set to Memory, set it to Disk. 
         Alternatively, if you're using 4.0, place a {$L-}
         directive at the beginning of your program.  Use the /L
         option to link to disk in the command-line compiler.
      3. If you are using any memory-resident utilities, such as
         Sidekick and Superkey, remove them from memory.
      4. If you are using TURBO.EXE, try using TPC.EXE instead -
         it takes up less memory.
      5. Turn off any compiler directives which are not
         necessarily needed.  By simply turning off range
         checking {$R-} and software emulation {$E-}, your code
         size will be reduced dramatically.
      6. Move all units, except PRINTER.TPU, out of the TURBO.TPL
         file and into the installed units directory.
      
    If none of these suggestions help, your program or unit may 
    simply be too large to compile in the amount of memory
    available,  and you may have to break in into two or more
    smaller units.  Alternatively, if you're using 5.0+, you
    should consider using overlays.


  9. How can my program be over-writing memory?

     Answer: The most common causes for memory overwrites are:

      1. Indexes out of range     (Turn range checking on {$R+}) 
      2. Uninitialized variables  (Write an initialization proc) 
      3. Pointers out of bounds   (Verify that pointers are not 
         pointing outside of the heap space)     
      4. Improper use of FillChar or Move (Be sure to use the
         SizeOf function)     
      5. Illogical operations on strings
   

 10. How come I don't get the results that I expect when I
     compare and print real numbers?

     Answer: The problem with real numbers in Turbo Pascal is a
     problem with how a real number is stored in binary form. A 
     binary number has no decimal point and thus a real number  
     cannot directly translate into a binary number easily.    
     Calculations must be performed to break a real number down
     into it's binary representation.  As with any calculation  
     that involves division or multiplication, small rounding   
     errors will occur. The problem you are experiencin g is a
     rounding error that occurs during translation from a real
     number into it's binary representation and back. I suggest
     that you round the results of your calculation to the number
     of decimal points that you require to alleviate the problem.
