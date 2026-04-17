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
		#tag ViewProperty
			Name="outStream"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
