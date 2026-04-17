#tag Class
Protected Class CodeWriter
	#tag Method, Flags = &h0
		Sub Constructor(stream As TextOutputStream)
		  outStream = stream
		  labelCounter = 0
		  
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub popToD()
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("D=M")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub pushDToStack()
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=D")
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub setFileName(name As String)
		  fileName = name
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21

		Private Sub writeAdd()
		  // Get the second number (y) from the stack into D
		  popToD()
		  
		  // Point to the first number (x) in the stack
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  
		  // Perform x + y (Note: D holds y, M holds x)
		  outStream.WriteLine("M=M+D")
		  
		  // Move SP back to the next empty slot
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeAnd()
		  // writeAnd: Bitwise AND (x & y)
		  Private Sub writeAnd()
		    popToD()
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M-1")
		    outStream.WriteLine("A=M")
		    outStream.WriteLine("M=M&D") // The bitwise AND operation
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M+1")
		  End Sub
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeArithmetic(command As String)
		  // writeArithmetic: The main dispatcher for all arithmetic and logical operations.
		  // This method is called by the Parser (readFile).
		  Public Sub writeArithmetic(command As String)
		  // Add a comment to the assembly file for easier debugging
		  outStream.WriteLine("// arithmetic command: " + command)
		  
		  Select Case command
		    
		  Case "add"
		    writeAdd()
		    
		  Case "sub"
		    writeSub()
		    
		  Case "neg"
		    writeNeg()
		    
		  Case "eq", "gt", "lt"
		    // These three share a very similar logic involving jumps, 
		    // so we send them to one specialized method.
		    writeComparison(command)
		    
		  Case "and"
		    writeAnd()
		    
		  Case "or"
		    writeOr()
		    
		  Case "not"
		    writeNot()
		    
		  Else
		    // Optional: handle unknown commands if needed
		  End Select
		  
		  End Sub
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeComparison(command as string)
		  // writeComparison: Handles eq, gt, and lt using jumps and unique labels
		  Private Sub writeComparison(command As String)
		    Var jumpType As String
		    
		    // Determine which jump condition to use
		    Select Case command
		    Case "eq"
		      jumpType = "JEQ" // Jump if x - y == 0
		    Case "gt"
		      jumpType = "JGT" // Jump if x - y > 0
		    Case "lt"
		      jumpType = "JLT" // Jump if x - y < 0
		    End Select
		    
		    // 1. Get y in D, then point to x
		    popToD()
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M-1")
		    outStream.WriteLine("A=M")
		    
		    // 2. Calculate D = x - y
		    outStream.WriteLine("D=M-D")
		    
		    // 3. Define unique labels for this specific comparison
		    Var trueLabel As String = "IF_TRUE" + labelCounter.ToString
		    Var nextLabel As String = "IF_NEXT" + labelCounter.ToString
		    labelCounter = labelCounter + 1 // Increment for the next comparison
		    
		    // 4. If condition is met, jump to TRUE case
		    outStream.WriteLine("@" + trueLabel)
		    outStream.WriteLine("D;" + jumpType)
		    
		    // --- FALSE CASE ---
		    outStream.WriteLine("D=0")      // Set D to False
		    outStream.WriteLine("@" + nextLabel)
		    outStream.WriteLine("0;JMP")    // Skip the true case
		    
		    // --- TRUE CASE ---
		    outStream.WriteLine("(" + trueLabel + ")")
		    outStream.WriteLine("D=-1")     // Set D to True (-1 in 16-bit is all 1s)
		    
		    // --- FINALIZE ---
		    outStream.WriteLine("(" + nextLabel + ")")
		    pushDToStack() // Push the result (0 or -1) back to the stack
		  End Sub
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeNeg()
		  // Perform Negation: x = -x
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1") // Point to the top value on the stack
		  outStream.WriteLine("A=M")   // Go to that address
		  outStream.WriteLine("M=-M")  // Reverse the sign of the value at that address
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1") // Move SP back to the next empty slot
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeNot()
		  // writeNot: Bitwise NOT (!x)
		  Private Sub writeNot()
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M-1")
		    outStream.WriteLine("A=M")
		    outStream.WriteLine("M=!M") // The bitwise NOT operation
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M+1")
		  End Sub
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeOr()
		  // writeOr: Bitwise OR (x | y)
		  Private Sub writeOr()
		    popToD()
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M-1")
		    outStream.WriteLine("A=M")
		    outStream.WriteLine("M=M|D") // The bitwise OR operation
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M+1")
		  End Sub
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeSub()
		  // Get the second number (y) from the stack into D
		  popToD()
		  
		  // Point to the first number (x) in the stack
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  
		  // Perform x - y (Note: D holds y, M holds x)
		  outStream.WriteLine("M=M-D")
		  
		  // Move SP back to the next empty slot
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePopDynamic(segment As String, index As Integer) As sub
		  Var baseSymbol As String
		  Select Case segment
		  Case "local": baseSymbol = "LCL"
		  Case "argument": baseSymbol = "ARG"
		  Case "this": baseSymbol = "THIS"
		  Case "that": baseSymbol = "THAT"
		  End Select
		  
		  // Step 1: Calculate target address (Base + Index)
		  outStream.WriteLine("@" + index.ToString)
		  outStream.WriteLine("D=A")
		  outStream.WriteLine("@" + baseSymbol)
		  outStream.WriteLine("D=M+D") // D = target address
		  
		  // Step 2: Store target address in R13
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("M=D")
		  
		  // Step 3: Get value from stack
		  popToD() // Now D contains the value
		  
		  // Step 4: Store value in the address saved in R13
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=D")
		  End Sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePopFixed(segment As String, index As Integer) As sub
		  Var baseAddress As Integer
		  If segment = "temp" Then
		    baseAddress = 5
		  Else // pointer
		    baseAddress = 3
		  End If
		  
		  popToD() // Value is now in D
		  outStream.WriteLine("@" + Str(baseAddress + index))
		  outStream.WriteLine("M=D")
		  End Sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePopStatic(index As Integer) As sub
		  popToD() // Value is now in D
		  outStream.WriteLine("@" + mFileName + "." + index.ToString)
		  outStream.WriteLine("M=D")
		  End Sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePushConstant(index As Integer) As Sub
		  // Stage 1: Load the constant value into the D register
		  outStream.WriteLine("@" + index.ToString)
		  outStream.WriteLine("D=A")
		  
		  // Stage 2: Push the value in D onto the stack
		  pushDToStack()
		  End Sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePushDynamic(segment As String, index As Integer) As sub
		  // Determine which base pointer to use
		  Var baseSymbol As String
		  Select Case segment
		  Case "local": baseSymbol = "LCL"
		  Case "argument": baseSymbol = "ARG"
		  Case "this": baseSymbol = "THIS"
		  Case "that": baseSymbol = "THAT"
		  End Select
		  
		  // Calculate address: RAM[baseSymbol] + index
		  outStream.WriteLine("@" + index.ToString)
		  outStream.WriteLine("D=A")
		  outStream.WriteLine("@" + baseSymbol)
		  outStream.WriteLine("A=M+D") // Address = Base + Index
		  outStream.WriteLine("D=M")   // D = Value at address
		  
		  pushDToStack()
		  End sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePushFixed(segment As String, index As Integer) As sub
		  Var baseAddress As Integer
		  If segment = "temp" Then
		    baseAddress = 5
		  Else // pointer
		    baseAddress = 3
		  End If
		  
		  outStream.WriteLine("@" + Str(baseAddress + index))
		  outStream.WriteLine("D=M")
		  
		  pushDToStack()
		  End Sub
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function writePushPop(command As String, segment As String, index As Integer) As sub
		  // Add a comment to the output assembly file for debugging purposes
		  outStream.WriteLine("// " + command + " " + segment + " " + index.ToString)
		  
		  If command = "push" Then
		    Select Case segment
		    Case "constant"
		      writePushConstant(index)
		    Case "local", "argument", "this", "that"
		      writePushDynamic(segment, index)
		    Case "static"
		      writePushStatic(index)
		    Case "temp", "pointer"
		      writePushFixed(segment, index)
		    End Select
		    
		  ElseIf command = "pop" Then
		    Select Case segment
		    Case "local", "argument", "this", "that"
		      writePopDynamic(segment, index)
		    Case "static"
		      writePopStatic(index)
		    Case "temp", "pointer"
		      writePopFixed(segment, index)
		    End Select
		  End If
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function writePushStatic(index As Integer) As sub
		  // Static segment uses the naming convention: FileName.Index
		  outStream.WriteLine("@" + mFileName + "." + index.ToString)
		  outStream.WriteLine("D=M")
		  
		  pushDToStack()
		  End Sub
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private fileName As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private labelCounter As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private outStream As TextOutputStream
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
End Class
#tag EndClass
