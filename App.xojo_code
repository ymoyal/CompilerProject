#tag Class
Protected Class App
Inherits ConsoleApplication
	#tag Event
		Function Run(args() as String) As Integer
		  // Yisca Sananes - 214164923
		  // Yael Moyal - 214770430
		  
		  
		  // Get the folder path from command line arguments or user input
		  Var folderPath As String
		  If args.Count > 1 Then
		    folderPath = args(1)
		  Else
		    Print("Please enter the path:")
		    folderPath = stdin.ReadLine
		  End If
		  
		  // Create a FolderItem for the directory
		  Var mainDir As New FolderItem(folderPath, FolderItem.PathModes.Native)
		  
		  // Verify the directory exists
		  If mainDir = Nil Or Not mainDir.Exists Then
		    Print("Error: Invalid path.")
		    Return 1
		  End If
		  
		  if mainDir.IsFolder
		    Var outputFile As FolderItem = mainDir.Child(mainDir.Name + ".asm")
		    Var outStream As TextOutputStream = TextOutputStream.Create(outputFile)
		    
		    // Iterate through all files in the directory
		    For i As Integer = 0 To mainDir.Count -1
		      Var f As FolderItem = mainDir.ChildAt(i)
		      
		      // Check if it's a .vm file
		      If f <> Nil And Not f.IsFolder And f.Name.Right(3) = ".vm" Then
		        Print("Processing file: " + f.Name)
		        
		        // b. Process the content of the VM file
		        // We open the file and read it line by line
		        Var inputStream As TextInputStream = TextInputStream.Open(f)
		        readFile(inputStream, outStream,  f.Name.Left(f.Name.Length - 3))
		        inputStream.Close
		      End If
		    Next
		    outStream.Close
		    
		  elseIf mainDir.Name.Right(3) = ".vm"
		    var outputName As String = mainDir.Name.Replace(".vm", ".asm")
		    var outputFile As FolderItem = mainDir.Parent.Child(outputName)
		    Var outStream As TextOutputStream = TextOutputStream.Create(outputFile)
		    Var inputStream As TextInputStream = TextInputStream.Open(mainDir)
		    readFile(inputStream, outStream, mainDir.Name.Left(Name.Length - 3)) 
		    outStream.Close
		    inputStream.Close
		  else
		    Print("There is no file to compile.")
		    return 0
		  end if
		  
		  
		  return 0
		  
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Function readFile(inputStream As TextInputStream, outStream As TextOutputStream, fileName As string) As void
		  // Create the translator instance once
		  Var writer As New CodeWriter(outStream)
		  writer.setFileName(fileName)
		  
		  While Not inputStream.EndOfFile
		    Var line As String = inputStream.ReadLine.Trim
		    
		    // 1. Handle Comments, Ignore everything after "//"
		    If line.Contains("//") Then
		      line = line.Left(line.IndexOf("//")).Trim
		    End If
		    
		    // 2. Process Command
		    If line <> "" Then
		      Var words() As String = line.Split(" ")
		      Var command As String = words(0)  // The first word is the VM command
		      
		      Select Case command
		        
		        // --- Arithmetic and Logical Commands ---      
		        
		      Case "add", "sub", "neg", "eq", "gt", "lt", "and", "or", "not"
		        // Call a helper method to write the assembly code for arithmetic operations
		        writer.writeArithmetic(command)
		        
		        
		        // --- Memory Access Commands ---
		        
		      Case "push", "pop"
		        // Ensure there are enough arguments for push/pop (segment and index)
		        If words.LastIndex >= 2 Then
		          Var segment As String = words(1)
		          Var index As Integer = words(2).ToInteger
		          // Call a helper method to write the assembly code for memory access
		          writer.writePushPop(command, segment, index)
		        End If
		        
		      Else
		        // Default: If the command is not recognized, skip it
		      End Select
		    End If
		  Wend
		End Function
	#tag EndMethod


	#tag ViewBehavior
	#tag EndViewBehavior
End Class
#tag EndClass
