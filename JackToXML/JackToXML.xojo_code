#tag Module
Module JackToXML
	#tag Method, Flags = &h21
		Private Sub BuildArguments()
		  StartBlock("parameterList")
		  If LookAheadLexeme() <> ")" Then
		    ParseDataType()
		    WriteNext("identifier")
		    While LookAheadLexeme() = ","
		      WriteNext("symbol")
		      ParseDataType()
		      WriteNext("identifier")
		    Wend
		  End If
		  EndBlock("parameterList")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildAssignmentNode()
		  StartBlock("letStatement")
		  WriteNext("keyword")    // let
		  WriteNext("identifier") // var
		  If LookAheadLexeme() = "[" Then
		    WriteNext("symbol") // [
		    BuildMathExpr()
		    WriteNext("symbol") // ]
		  End If
		  WriteNext("symbol")     // =
		  BuildMathExpr()
		  WriteNext("symbol")     // ;
		  EndBlock("letStatement")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildClassNode()
		  
		  StartBlock("class")
		  WriteNext("keyword")    // class
		  WriteNext("identifier") // className
		  WriteNext("symbol")     // {
		  
		  While LookAheadLexeme() = "static" Or LookAheadLexeme() = "field"
		    BuildClassVariables()
		  Wend
		  
		  While LookAheadLexeme() = "constructor" Or LookAheadLexeme() = "function" Or LookAheadLexeme() = "method"
		    BuildRoutineNode()
		  Wend
		  
		  WriteNext("symbol")     // }
		  EndBlock("class")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildClassVariables()
		  StartBlock("classVarDec")
		  WriteNext("keyword")    // static or field
		  ParseDataType()         // type
		  WriteNext("identifier") // varName
		  
		  While LookAheadLexeme() = ","
		    WriteNext("symbol")
		    WriteNext("identifier")
		  Wend
		  WriteNext("symbol")     // ;
		  EndBlock("classVarDec")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildCommandBlock()
		  StartBlock("statements")
		  Var looping As Boolean = True
		  While looping
		    Select Case LookAheadLexeme()
		    Case "let"
		      BuildAssignmentNode()
		    Case "if"
		      BuildIfLogic()
		    Case "while"
		      BuildWhileLoop()
		    Case "do"
		      BuildDoCall()
		    Case "return"
		      BuildReturnCmd()
		    Else
		      looping = False
		    End Select
		  Wend
		  EndBlock("statements")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildDoCall()
		  StartBlock("doStatement")
		  WriteNext("keyword")    // do
		  ParseRoutineCall()
		  WriteNext("symbol")     // ;
		  EndBlock("doStatement")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildExprList()
		  StartBlock("expressionList")
		  If LookAheadLexeme() <> ")" Then
		    BuildMathExpr()
		    While LookAheadLexeme() = ","
		      WriteNext("symbol")
		      BuildMathExpr()
		    Wend
		  End If
		  EndBlock("expressionList")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildIfLogic()
		  StartBlock("ifStatement")
		  WriteNext("keyword")    // if
		  WriteNext("symbol")     // (
		  BuildMathExpr()
		  WriteNext("symbol")     // )
		  WriteNext("symbol")     // {
		  BuildCommandBlock()
		  WriteNext("symbol")     // }
		  If LookAheadLexeme() = "else" Then
		    WriteNext("keyword") // else
		    WriteNext("symbol")  // {
		    BuildCommandBlock()
		    WriteNext("symbol")  // }
		  End If
		  EndBlock("ifStatement")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildLocalVariables()
		  StartBlock("varDec")
		  WriteNext("keyword")    // var
		  ParseDataType()
		  WriteNext("identifier")
		  While LookAheadLexeme() = ","
		    WriteNext("symbol")
		    WriteNext("identifier")
		  Wend
		  WriteNext("symbol")     // ;
		  EndBlock("varDec")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildMathExpr()
		  StartBlock("expression")
		  BuildOperand()
		  Var opSet As String = "+-*/&|<>="
		  While LookAheadType() = "symbol" And InStr(opSet, LookAheadLexeme()) > 0
		    WriteNext("symbol")
		    BuildOperand()
		  Wend
		  EndBlock("expression")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildOperand()
		  StartBlock("term")
		  
		  Var typ As String = LookAheadType()
		  Var lex As String = LookAheadLexeme()
		  
		  If typ = "integerConstant" Or typ = "stringConstant" Or typ = "keyword" Then
		    WriteNext(typ)
		  ElseIf typ = "symbol" Then
		    If lex = "(" Then
		      WriteNext("symbol")
		      BuildMathExpr()
		      WriteNext("symbol")
		    ElseIf lex = "-" Or lex = "~" Then
		      WriteNext("symbol")
		      BuildOperand()
		    End If
		  ElseIf typ = "identifier" Then
		    Var nextLex As String = LookAheadLexeme(1)
		    If nextLex = "[" Then
		      WriteNext("identifier")
		      WriteNext("symbol")
		      BuildMathExpr()
		      WriteNext("symbol")
		    ElseIf nextLex = "(" Or nextLex = "." Then
		      ParseRoutineCall()
		    Else
		      WriteNext("identifier")
		    End If
		  End If
		  
		  EndBlock("term")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildReturnCmd()
		  StartBlock("returnStatement")
		  WriteNext("keyword")    // return
		  If LookAheadLexeme() <> ";" Then
		    BuildMathExpr()
		  End If
		  WriteNext("symbol")     // ;
		  EndBlock("returnStatement")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildRoutineBody()
		  StartBlock("subroutineBody")
		  WriteNext("symbol")     // {
		  While LookAheadLexeme() = "var"
		    BuildLocalVariables()
		  Wend
		  BuildCommandBlock()
		  WriteNext("symbol")     // }
		  EndBlock("subroutineBody")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildRoutineNode()
		  StartBlock("subroutineDec")
		  WriteNext("keyword")    // constructor/function/method
		  
		  If LookAheadLexeme() = "void" Then
		    WriteNext("keyword")
		  Else
		    ParseDataType()
		  End If
		  
		  WriteNext("identifier") // routine name
		  WriteNext("symbol")     // (
		  BuildArguments()
		  WriteNext("symbol")     // )
		  
		  BuildRoutineBody()
		  EndBlock("subroutineDec")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BuildWhileLoop()
		  StartBlock("whileStatement")
		  WriteNext("keyword")    // while
		  WriteNext("symbol")     // (
		  BuildMathExpr()
		  WriteNext("symbol")     // )
		  WriteNext("symbol")     // {
		  BuildCommandBlock()
		  WriteNext("symbol")     // }
		  EndBlock("whileStatement")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CleanXml(rawStr As String) As String
		  Var sanitized As String = rawStr
		  sanitized = sanitized.ReplaceAll("&", "&amp;")
		  sanitized = sanitized.ReplaceAll("<", "&lt;")
		  sanitized = sanitized.ReplaceAll(">", "&gt;")
		  Return sanitized
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EndBlock(nodeName As String)
		  CurrentIndent = CurrentIndent - 1
		  XmlBuffer.Add(GetIndent() + "</" + nodeName + ">")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ExecuteAnalyzer() As Integer
		  Stdout.Write("Enter path to .jack file or directory: ")
		  Stdout.Flush
		  
		  Var targetPath As String = Input.Trim
		  
		  // Fix: Strip surrounding quotes added by Windows Drag & Drop
		  If targetPath.Left(1) = Chr(34) And targetPath.Right(1) = Chr(34) Then
		    targetPath = targetPath.Middle(1, targetPath.Length - 2)
		  End If
		  
		  If targetPath = "" Then
		    Print("Error: Empty path provided.")
		    PauseBeforeExit()
		    Return 1
		  End If
		  
		  Var targetItem As FolderItem = LocateTarget(targetPath)
		  If targetItem Is Nil Or Not targetItem.Exists Then
		    Print("Error: Could not locate " + targetPath)
		    PauseBeforeExit()
		    Return 1
		  End If
		  
		  Var processedFiles As Integer = 0
		  If targetItem.IsFolder Then
		    ProcessDirectory(targetItem, processedFiles)
		  Else
		    If targetItem.Name.Right(5).Lowercase = ".jack" Then
		      ProcessSingleFile(targetItem)
		      processedFiles = processedFiles + 1
		    Else
		      Print("Error: Target is not a .jack file.")
		      PauseBeforeExit()
		      Return 1
		    End If
		  End If
		  
		  Print("Success! Processed " + processedFiles.ToString + " files.")
		  PauseBeforeExit()
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExportTokens(outFile As FolderItem)
		  Var out As TextOutputStream = TextOutputStream.Create(outFile)
		  out.WriteLine("<tokens>")
		  For i As Integer = 0 To TokenTypes.LastIndex
		    out.WriteLine("<" + TokenTypes(i) + "> " + CleanXml(TokenLexemes(i)) + " </" + TokenTypes(i) + ">")
		  Next
		  out.WriteLine("</tokens>")
		  out.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function GetIndent() As String
		  Var spaces As String = ""
		  For i As Integer = 1 To CurrentIndent
		    spaces = spaces + "  "
		  Next
		  Return spaces
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LocateTarget(pathStr As String) As FolderItem
		  Var directNode As FolderItem = GetFolderItem(pathStr)
		  If directNode <> Nil And directNode.Exists Then Return directNode
		  
		  Var searchRoots() As FolderItem
		  searchRoots.Add(SpecialFolder.CurrentWorkingDirectory)
		  searchRoots.Add(App.ExecutableFile.Parent)
		  
		  For Each root As FolderItem In searchRoots
		    Var currentDir As FolderItem = root
		    For i As Integer = 0 To 10
		      If currentDir Is Nil Then Exit
		      Var testNode As FolderItem = currentDir.Child(pathStr)
		      If testNode <> Nil And testNode.Exists Then Return testNode
		      currentDir = currentDir.Parent
		    Next
		  Next
		  
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LookAheadLexeme(offset As Integer = 0) As String
		  If CurrentIndex + offset > TokenLexemes.LastIndex Then Return ""
		  Return TokenLexemes(CurrentIndex + offset)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LookAheadType(offset As Integer = 0) As String
		  If CurrentIndex + offset > TokenTypes.LastIndex Then Return ""
		  Return TokenTypes(CurrentIndex + offset)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchKeyword(val As String) As Boolean
		  Var keys As String = ",class,constructor,function,method,field,static,var,int,char,boolean,void,true,false,null,this,let,do,if,else,while,return,"
		  Return InStr(keys, "," + val + ",") > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseDataType()
		  If LookAheadType() = "keyword" Then
		    WriteNext("keyword")
		  Else
		    WriteNext("identifier")
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ParseRoutineCall()
		  WriteNext("identifier")
		  If LookAheadLexeme() = "." Then
		    WriteNext("symbol")
		    WriteNext("identifier")
		  End If
		  WriteNext("symbol")
		  BuildExprList()
		  WriteNext("symbol")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PauseBeforeExit()
		  // Fix: Keeps the console window open so you can see the result
		  Stdout.Write("Press Enter to close...")
		  Stdout.Flush
		  Var dummy As String = Input
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessDirectory(dir As FolderItem, ByRef count As Integer)
		  Var filesToParse() As FolderItem
		  For Each child As FolderItem In dir.Children
		    If child <> Nil And Not child.IsFolder And child.Name.Right(5).Lowercase = ".jack" Then
		      filesToParse.Add(child)
		    End If
		  Next
		  
		  // Fix: Reverted to manual sorting. Xojo's SortWith crashes on FolderItem arrays.
		  If filesToParse.Count > 1 Then
		    For i As Integer = 0 To filesToParse.LastIndex - 1
		      For j As Integer = i + 1 To filesToParse.LastIndex
		        If filesToParse(j).Name.Lowercase < filesToParse(i).Name.Lowercase Then
		          Var temp As FolderItem = filesToParse(i)
		          filesToParse(i) = filesToParse(j)
		          filesToParse(j) = temp
		        End If
		      Next
		    Next
		  End If
		  
		  For Each file As FolderItem In filesToParse
		    ProcessSingleFile(file)
		    count = count + 1
		    Print("Compiled: " + file.Name)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ProcessSingleFile(jackFile As FolderItem)
		  Var stream As TextInputStream = TextInputStream.Open(jackFile)
		  Var rawText As String = stream.ReadAll
		  stream.Close
		  
		  RunLexer(rawText)
		  
		  Var nameBase As String = jackFile.Name.Left(jackFile.Name.Length - 5)
		  
		  // 1. Export Tokens
		  Var tokenFile As FolderItem = jackFile.Parent.Child(nameBase + "T.xml")
		  ExportTokens(tokenFile)
		  
		  // 2. Build Syntax Tree
		  Var astFile As FolderItem = jackFile.Parent.Child(nameBase + ".xml")
		  XmlBuffer.RemoveAll()
		  CurrentIndex = 0
		  CurrentIndent = 0
		  
		  BuildClassNode()
		  
		  Var outStream As TextOutputStream = TextOutputStream.Create(astFile)
		  For Each line As String In XmlBuffer
		    outStream.WriteLine(line)
		  Next
		  outStream.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RunLexer(source As String)
		  TokenTypes.RemoveAll()
		  TokenLexemes.RemoveAll()
		  
		  Var cursor As Integer = 0
		  Var length As Integer = source.Length
		  
		  While cursor < length
		    Var c As String = source.Middle(cursor, 1)
		    
		    // Handle whitespace
		    If Asc(c) <= 32 Then
		      cursor = cursor + 1
		      Continue
		    End If
		    
		    // Handle Comments
		    If c = "/" And cursor + 1 < length Then
		      Var nextC As String = source.Middle(cursor + 1, 1)
		      If nextC = "/" Then
		        cursor = cursor + 2
		        While cursor < length And source.Middle(cursor, 1) <> Chr(10) And source.Middle(cursor, 1) <> Chr(13)
		          cursor = cursor + 1
		        Wend
		        Continue
		      ElseIf nextC = "*" Then
		        cursor = cursor + 2
		        While cursor < length - 1
		          If source.Middle(cursor, 2) = "*/" Then
		            cursor = cursor + 2
		            Exit
		          End If
		          cursor = cursor + 1
		        Wend
		        Continue
		      End If
		    End If
		    
		    // Symbols
		    If InStr("{}()[].,;+-*/&|<>=~", c) > 0 Then
		      StoreToken("symbol", c)
		      cursor = cursor + 1
		      Continue
		    End If
		    
		    // Strings
		    If c = Chr(34) Then
		      cursor = cursor + 1
		      Var startIdx As Integer = cursor
		      While cursor < length And source.Middle(cursor, 1) <> Chr(34)
		        cursor = cursor + 1
		      Wend
		      StoreToken("stringConstant", source.Middle(startIdx, cursor - startIdx))
		      cursor = cursor + 1
		      Continue
		    End If
		    
		    // Integers
		    If Asc(c) >= 48 And Asc(c) <= 57 Then
		      Var startIdx As Integer = cursor
		      While cursor < length And Asc(source.Middle(cursor, 1)) >= 48 And Asc(source.Middle(cursor, 1)) <= 57
		        cursor = cursor + 1
		      Wend
		      StoreToken("integerConstant", source.Middle(startIdx, cursor - startIdx))
		      Continue
		    End If
		    
		    // Identifiers & Keywords
		    Var asciiVal As Integer = Asc(c)
		    If (asciiVal >= 65 And asciiVal <= 90) Or (asciiVal >= 97 And asciiVal <= 122) Or c = "_" Then
		      Var startIdx As Integer = cursor
		      While cursor < length
		        Var testChar As String = source.Middle(cursor, 1)
		        Var testAsc As Integer = Asc(testChar)
		        If (testAsc >= 65 And testAsc <= 90) Or (testAsc >= 97 And testAsc <= 122) Or (testAsc >= 48 And testAsc <= 57) Or testChar = "_" Then
		          cursor = cursor + 1
		        Else
		          Exit
		        End If
		      Wend
		      Var word As String = source.Middle(startIdx, cursor - startIdx)
		      If MatchKeyword(word) Then
		        StoreToken("keyword", word)
		      Else
		        StoreToken("identifier", word)
		      End If
		      Continue
		    End If
		    
		    // Failsafe increment
		    cursor = cursor + 1
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StartBlock(nodeName As String)
		  XmlBuffer.Add(GetIndent() + "<" + nodeName + ">")
		  CurrentIndent = CurrentIndent + 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StoreToken(tType As String, lexeme As String)
		  TokenTypes.Add(tType)
		  TokenLexemes.Add(lexeme)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WriteNext(expectedType As String)
		  If CurrentIndex <= TokenTypes.LastIndex Then
		    Var tag As String = TokenTypes(CurrentIndex)
		    Var val As String = CleanXml(TokenLexemes(CurrentIndex))
		    XmlBuffer.Add(GetIndent() + "<" + tag + "> " + val + " </" + tag + ">")
		    CurrentIndex = CurrentIndex + 1
		  End If
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private CurrentIndent As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private CurrentIndex As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TokenLexemes() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private TokenTypes() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private XmlBuffer() As String
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
