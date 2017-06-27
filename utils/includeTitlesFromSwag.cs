// Include title & author in Swag snippets
// Nacho, 2016

using System;
using System.IO;
using System.Text;
using System.Collections.Generic;

public class Snippets1
{
    public static void Main(string[] args)
    {
        StreamReader listFile = File.OpenText("dir.txt");
        List<string> details = new List<string>();
        string category = listFile.ReadLine();
        string line = listFile.ReadLine();
        while (line != null)
        {
            details.Add(line);
            line = listFile.ReadLine();
        }
        listFile.Close();
        
        
        foreach (string fileDetails in details)
        {
            //if (fileDetails.Length > 5)
            {
                Console.WriteLine(fileDetails);
                int spacePos = fileDetails.IndexOf(' ');
                int quotesPos = fileDetails.IndexOf('\"');
                int secondQuotesPos = fileDetails.IndexOf('\"', quotesPos+1);
                int authorPos = fileDetails.IndexOf("by ", secondQuotesPos)+3;
                
                Console.WriteLine(spacePos+"-"+quotesPos+"-"+
                    "-"+secondQuotesPos+"-"+authorPos);
                
                string fileName = fileDetails.Substring(0, spacePos);
                string description = fileDetails.Substring(quotesPos+1, 
                    secondQuotesPos-quotesPos-1);
                string author = fileDetails.Substring(authorPos);
                string date = fileDetails.Substring(spacePos+1, 
                    quotesPos-spacePos-1).Trim();
                    
                Console.WriteLine(fileName+"-"+description+"-"+author);
                
                string newName = description.Substring(0,1);
                for (int i=1; i<description.Length; i++)
                {
                    if ((description[i-1] == ' ') || 
                            (description[i-1] == '.'))
                        newName += description.ToUpper().Substring(i,1);
                    else
                        newName += description.ToLower().Substring(i,1);
                }                
                newName = newName.Replace(" ", "");
                newName = newName.Replace("Re:", "");
                newName = newName.Replace("-", "");
                if (newName.ToUpper().EndsWith(".PAS"))
                    newName = newName.Substring(0, newName.Length-4);
                newName = newName.Replace(".", "");
                newName = newName.Replace("/", "");
                newName = newName.Replace(":", "");
                newName = newName.Replace("?", "");
                newName = newName.Replace("&", "");
                newName = newName.Replace("*", "");
                newName = newName.Replace("#", "");
                newName = newName.Replace("!", "");
                newName = newName.Replace(">", "");
                newName = newName.Replace("<", "");
                while (File.Exists(newName+".pas"))
                    newName += "Bis";
                newName += ".pas";
                Console.WriteLine(newName);
                
                StreamReader inputFile = File.OpenText(fileName);
                StreamWriter outputFile = File.CreateText(newName);
                
                outputFile.WriteLine("(*");
                outputFile.WriteLine("  Category: "+category);
                outputFile.WriteLine("  Original name: "+fileName);
                outputFile.WriteLine("  Description: "+description);
                outputFile.WriteLine("  Author: "+author);
                outputFile.WriteLine("  Date: "+date);
                outputFile.WriteLine("*)");
                outputFile.WriteLine();
                
                line = inputFile.ReadLine();
                while (line != null)
                {
                    outputFile.WriteLine(line);
                    line = inputFile.ReadLine();
                }
                inputFile.Close();
                outputFile.Close();
            }
        }
    }
}
