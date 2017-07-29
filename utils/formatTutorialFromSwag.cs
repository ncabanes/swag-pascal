// Format Pascal tutorial from Swag snippets
// Nacho, 2017

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public class FormatPascalTut
{
    public static void Main(string[] args)
    {
        string dir = ".";
        string [] fileList = Directory.GetFiles(dir, "*.txt");
        Array.Sort(fileList);
        
        foreach (string fileName in fileList)
        {
            Console.WriteLine("Processing "+fileName);
            
            // First, let's read each file
            StreamReader inputFile = File.OpenText(fileName);
            List<string> lines = new List<string>();
            string line = inputFile.ReadLine();
            bool inScreenOutput = false;
            while (line != null)
            {
                lines.Add(line);
                line = inputFile.ReadLine();
            }
            inputFile.Close();
            
            // Then, let's process it and dump it
            string newName = fileName.Replace(".txt", ".md");
            StreamWriter outputFile = File.CreateText(newName);
            
            // Header
            outputFile.WriteLine("## "+lines[8].Trim());
            outputFile.WriteLine(lines[9].Trim());
            outputFile.WriteLine("### "+lines[10].Trim());
            outputFile.WriteLine(lines[11].Trim());
            
            outputFile.WriteLine();
            outputFile.WriteLine("```txt");
            outputFile.WriteLine(lines[1]);
            outputFile.WriteLine(lines[2]);
            outputFile.WriteLine(lines[3]);
            outputFile.WriteLine(lines[4]);
            outputFile.WriteLine(lines[5]);
            outputFile.WriteLine("```");
            outputFile.WriteLine();
            
            
            // Rest of the lines
            for (int i=13; i < lines.Count; i++)
            {
                // Start of example program
                if (lines[i].StartsWith("program "))
                {
                    outputFile.WriteLine("```pascal");
                    outputFile.WriteLine(lines[i]);
                }
                // End of example program
                else if (lines[i].StartsWith("  end."))
                {
                    outputFile.WriteLine(lines[i]);
                    outputFile.WriteLine("```");
                }
                // Section title
                else if ((i < lines.Count-1) && 
                    lines[i+1].StartsWith("====="))
                {
                    outputFile.WriteLine("#### "+lines[i]);
                    i++;
                }
                // Start of paragraph
                else if ((i < lines.Count-1) && 
                    lines[i].StartsWith("        ") && 
                    ! lines[i+1].StartsWith(" "))
                {
                    outputFile.WriteLine(lines[i].TrimStart());
                }
                // Screen output
                else if (lines[i].StartsWith("----------"))
                {
                    if (!inScreenOutput)
                        outputFile.WriteLine("```txt");
                    else
                        outputFile.WriteLine("```");
                    inScreenOutput = ! inScreenOutput;
                }
                // Rest of the lines
                else
                    outputFile.WriteLine(lines[i]
                        .TrimEnd()
                        .Replace( ""+(char) (0x1a), "")
                    );
            }
            outputFile.Close();
        }
    }
}
