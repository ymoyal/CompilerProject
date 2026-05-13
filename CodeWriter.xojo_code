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
		Private Sub popToR(register As String)
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("AM=M-1")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@" + register)
		  outStream.WriteLine("M=D")
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

	#tag Method, Flags = &h21
		Private Sub pushFromR(register As String)
		  outStream.WriteLine("@" + register)
		  outStream.WriteLine("D=M")
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
		  popToD()
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=M&D") // The bitwise AND operation
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeArithmetic(command As String)
		  // writeArithmetic: The main dispatcher for all arithmetic and logical operations.
		  // This method is called by the Parser (readFile).
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
		    
		  Case "shl"
		    writeShl()
		    
		    
		  Else
		    // Optional: handle unknown commands if needed
		  End Select
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeCall(functionName As String, numArgs As Integer)
		  // Define a static variable that persists across calls
		  Static returnLabelIndex As Integer = 0
		  
		  // Generate a unique return label for this specific call instance
		  Var returnLabel As String = functionName + "$ret." + returnLabelIndex.ToString
		  returnLabelIndex = returnLabelIndex + 1
		  
		  // 1. Push return-address label onto the stack
		  outStream.WriteLine("@" + returnLabel)
		  outStream.WriteLine("D=A")
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=D")
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		  
		  // 2-5. Push LCL, ARG, THIS, and THAT registers onto the stack
		  Dim registers() As String = Array("LCL", "ARG", "THIS", "THAT")
		  
		  For Each reg As String In registers
		    outStream.WriteLine("@" + reg)
		    outStream.WriteLine("D=M")
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("A=M")
		    outStream.WriteLine("M=D")
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M+1")
		  Next
		  
		  // 6. Reposition ARG: ARG = SP - 5 - nArgs
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@5")
		  outStream.WriteLine("D=D-A")
		  outStream.WriteLine("@" + numArgs.ToString)
		  outStream.WriteLine("D=D-A")
		  outStream.WriteLine("@ARG")
		  outStream.WriteLine("M=D")
		  
		  // 7. Reposition LCL: LCL = SP
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@LCL")
		  outStream.WriteLine("M=M+1") // סליחה, כאן שמרנו את ה-LCL: צריך להיות M=D
		  outStream.WriteLine("M=D") // תיקון: LCL = SP (השורה הזו היא המעודכנת)
		  
		  // 8. Transfer control to the called function
		  outStream.WriteLine("@" + functionName)
		  outStream.WriteLine("0;JMP")
		  
		  // 9. Declare the return address label
		  outStream.WriteLine("(" + returnLabel + ")")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeComparison(command as string)
		  // writeComparison: Handles eq, gt, and lt using jumps and unique labels
		  
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
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeFunction(functionName As String, numVars As Integer)
		  // 1. Write the function label
		  outStream.WriteLine("(" + functionName + ")")
		  
		  // 2. Initialize the local variables to 0
		  For i As Integer = 1 To numVars
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("A=M")
		    outStream.WriteLine("M=0")
		    outStream.WriteLine("@SP")
		    outStream.WriteLine("M=M+1")
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeGoTo(label As String)
		  // Load the address of the label into the A register.
		  // We use the same 'fileName.label' format to match the declaration.
		  self.outStream.WriteLine("@" + self.fileName + "." + label)
		  
		  // Execute an unconditional jump (JMP).
		  // This tells the computer to continue execution from the label's address.
		  self.outStream.WriteLine("0;JMP")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeIfGoTo(label As String)
		  // 1. Pop the top element of the stack into the D register.
		  // We use the helper method you already have in your CodeWriter.
		  self.popToD()
		  
		  // 2. Load the target label address into the A register.
		  self.outStream.WriteLine("@" + self.fileName + "." + label)
		  
		  // 3. Conditional jump: Jump to the label if D is not zero (true).
		  // In VM, 0 is false and non-zero (usually -1) is true.
		  self.outStream.WriteLine("D;JNE")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeLabel(label As String)
		  // Construct the ASM label string in the format: (FileName.label)
		  Dim asmLine As String = "(" + self.fileName + "." + label + ")"      
		  
		  // Write the label declaration to the output assembly file.
		  self.outStream.WriteLine(asmLine)
		  
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
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=!M") // The bitwise NOT operation
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		  
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeOr()
		  // writeOr: Bitwise OR (x | y)
		  popToD()
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M-1")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=M|D") // The bitwise OR operation
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=M+1")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePopDynamic(segment As String, index As Integer)
		  Var baseSymbol As String
		  Select Case segment
		  Case "local"
		    baseSymbol = "LCL"
		  Case "argument"
		    baseSymbol = "ARG"
		  Case "this" 
		    baseSymbol = "THIS"
		  Case "that"
		    baseSymbol = "THAT"
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
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePopFixed(segment As String, index As Integer)
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
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePopStatic(index As Integer)
		  popToD() // Value is now in D
		  outStream.WriteLine("@" + fileName + "." + index.ToString)
		  outStream.WriteLine("M=D")
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePushConstant(index As Integer)
		  // Stage 1: Load the constant value into the D register
		  outStream.WriteLine("@" + index.ToString)
		  outStream.WriteLine("D=A")
		  
		  // Stage 2: Push the value in D onto the stack
		  pushDToStack()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePushDynamic(segment As String, index As Integer)
		  // Determine which base pointer to use
		  Var baseSymbol As String
		  Select Case segment
		  Case "local"
		    baseSymbol = "LCL"
		  Case "argument"
		    baseSymbol = "ARG"
		  Case "this"
		    baseSymbol = "THIS"
		  Case "that"
		    baseSymbol = "THAT"
		  End Select
		  
		  // Calculate address: RAM[baseSymbol] + index
		  outStream.WriteLine("@" + index.ToString)
		  outStream.WriteLine("D=A")
		  outStream.WriteLine("@" + baseSymbol)
		  outStream.WriteLine("A=M+D") // Address = Base + Index
		  outStream.WriteLine("D=M")   // D = Value at address
		  
		  pushDToStack()
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePushFixed(segment As String, index As Integer)
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
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writePushPop(command As String, segment As String, index As Integer)
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
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writePushStatic(index As Integer)
		  // Static segment uses the naming convention: FileName.Index
		  outStream.WriteLine("@" + fileName + "." + index.ToString)
		  outStream.WriteLine("D=M")
		  
		  pushDToStack()
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub writeReturn()
		  // 1. FRAME = LCL
		  outStream.WriteLine("@LCL")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("M=D")
		  
		  // 2. RET = *(FRAME - 5)
		  outStream.WriteLine("@5")
		  outStream.WriteLine("A=D-A")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@R14")
		  outStream.WriteLine("M=D")
		  
		  // 3. *ARG = pop()
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("A=M-1")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@ARG")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("M=D")
		  
		  // 4. SP = ARG + 1
		  outStream.WriteLine("@ARG")
		  outStream.WriteLine("D=M+1")
		  outStream.WriteLine("@SP")
		  outStream.WriteLine("M=D")
		  
		  // 5. THAT = *(FRAME - 1)
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("A=M-1")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@THAT")
		  outStream.WriteLine("M=D")
		  
		  // 6. THIS = *(FRAME - 2)
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@2")
		  outStream.WriteLine("A=D-A")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@THIS")
		  outStream.WriteLine("M=D")
		  
		  // 7. ARG = *(FRAME - 3)
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@3")
		  outStream.WriteLine("A=D-A")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@ARG")
		  outStream.WriteLine("M=D")
		  
		  // 8. LCL = *(FRAME - 4)
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@4")
		  outStream.WriteLine("A=D-A")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@LCL")
		  outStream.WriteLine("M=D")
		  
		  // 9. goto RET
		  outStream.WriteLine("@R14")
		  outStream.WriteLine("A=M")
		  outStream.WriteLine("0;JMP")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub writeShl()
		  Var labelId As String = labelCounter.ToString
		  labelCounter = labelCounter + 1
		  
		  // Pop parameters: x (steps) into R13, y (value) into R14 [cite: 106]
		  popToR("R13") 
		  popToR("R14") 
		  
		  // Start of the shift loop
		  outStream.WriteLine("(SHIFT_LEFT_LOOP_" + labelId + ")")
		  
		  // Check if all steps are completed (x == 0)
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("@SHIFT_LEFT_END_" + labelId)
		  outStream.WriteLine("D;JEQ")
		  
		  // Perform y = y * 2 (equivalent to shifting left by 1)
		  outStream.WriteLine("@R14")
		  outStream.WriteLine("D=M")
		  outStream.WriteLine("M=D+M")
		  
		  // Decrement step counter: x = x - 1
		  outStream.WriteLine("@R13")
		  outStream.WriteLine("M=M-1")
		  
		  // Repeat loop
		  outStream.WriteLine("@SHIFT_LEFT_LOOP_" + labelId)
		  outStream.WriteLine("0;JMP")
		  
		  // End of loop, push the result (y << x) back to the stack [cite: 107]
		  outStream.WriteLine("(SHIFT_LEFT_END_" + labelId + ")")
		  pushFromR("R14")
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
	#tag EndViewBehavior
End Class
#tag EndClass
