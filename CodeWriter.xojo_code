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
		Private Sub Untitled()
		  
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
