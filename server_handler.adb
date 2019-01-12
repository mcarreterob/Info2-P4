with Ada.Text_IO;

package body Server_Handler is

    function EP_Image (EP: LLU.End_Point_Type) return String is
        Salida: ASU.Unbounded_String;
        Port: ASU.Unbounded_String;
        IP_Port: ASU.Unbounded_String;
        New_String: ASU.Unbounded_String;
        Ip: ASU.Unbounded_String;
    begin
        Salida := ASU.To_Unbounded_String(LLU.Image(EP));
        Port := ASU.Tail(Salida, 5);
        IP_Port := ASU.Tail(Salida, 23);   
        IP := ASU.Head(IP_Port, 9);
        return ASU.To_String(IP) & ":" & ASU.To_String(Port);

    
    end EP_Image;

	function Hash(K: ASU.Unbounded_String) return Hash_Range is
		R: Integer := 0;
		H: Hash_Range := 0;
	begin
		for I in 1..ASU.Length(K) loop
			R := R + Character'Pos(ASU.Element(K,I));
		end loop;
		H := Hash_Range'mod(R);
		return H;
	end Hash;

    function Time_Image (T: Ada.Calendar.Time) return String is
    begin
        return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
    end Time_Image;

   procedure Send_To_All (EP: LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
      Cursor: Actives_Clients.Cursor := Actives_Clients.First(Actives_C);
      Elem: Actives_Clients.Element_Type;
   begin
        while Actives_Clients.Has_Element(Cursor) loop
            Elem := Actives_Clients.Element(Cursor);   
            if LLU.Image(EP) /= LLU.Image(Elem.Value.EP) then
                LLU.Send(Elem.Value.EP, P_Buffer);
            end if;
            Actives_Clients.Next(Cursor); 
        end loop; 

   end Send_To_All;

    procedure Delete_Old is
        Cursor: Actives_Clients.Cursor := Actives_Clients.First(Actives_C);
        Elem: Actives_Clients.Element_Type;
        Older_Time: Ada.Calendar.Time := Ada.Calendar.clock;
        Older_Key: ASU.Unbounded_String;
        Success: Boolean := False;
        Content: ASU.Unbounded_String;
        Client_EP_Handler: LLU.End_Point_Type;
        Buffer: aliased LLU.Buffer_Type(1024);
   
         
    begin
       while Actives_Clients.Has_Element(Cursor) loop
            Elem := Actives_Clients.Element(Cursor);   
            if Elem.Value.Time < Older_Time then
                Older_Time := Elem.Value.Time;
                Older_Key := Elem.Key;
                Client_EP_Handler := Elem.Value.EP;
            end if;
            Actives_Clients.Next(Cursor); 
        end loop;  
        Content := ASU.To_Unbounded_String(ASU.To_String(Older_Key) 
                     & " banned for being idle too long.");
        Actives_Clients.Delete(Actives_C, Older_Key, Success);
        Inactives_Clients.Put(Inactives_C, Older_Key, Ada.Calendar.Clock);
        LLU.Reset(Buffer);
        CM.Message_Type'Output(Buffer'Access, CM.Server);
        ASU.Unbounded_String'Output(Buffer'Access, ASU.To_Unbounded_String("server"));
        ASU.Unbounded_String'Output(Buffer'Access, Content);
        Send_To_All(Client_EP_Handler, Buffer'Access);
    end Delete_Old;

                    
            

    procedure Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type) is
        Mess_Type: CM.Message_Type;
        Nick: ASU.Unbounded_String;
        Content: ASU.Unbounded_String;
        Client_EP_Receive: LLU.End_Point_Type;
        Client_EP_Handler: LLU.End_Point_Type;
        Acogido: Boolean := False;
        Error_Messages: exception;
        Success: Boolean;
        Value: Value_EP_Time;
    begin
        Mess_Type := CM.Message_Type'Input(P_Buffer);

        if Mess_Type = CM.Init then
            Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
            Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
            Nick := ASU.Unbounded_String'Input(P_Buffer);
            LLU.Reset(P_Buffer.all);
            Actives_Clients.Get(Actives_C, Nick, Value, Success);

            if Max_Clients = Actives_Clients.Map_Length(Actives_C) and not Success then

                Delete_Old;        
                Actives_Clients.Put(Actives_C, Nick, (Client_EP_Handler, Ada.Calendar.clock));
                Acogido := True;
                Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick) & ": ACCEPTED");
                CM.Message_Type'Output(P_Buffer, CM.Welcome);
                Boolean'Output(P_Buffer, Acogido);
                LLU.Send(Client_EP_Receive, P_Buffer);
                LLU.Reset(P_Buffer.all);
                CM.Message_Type'Output(P_Buffer, CM.Server);
                ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
                ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String(ASU.To_String(Nick) & " joins the chat"));
                Send_To_All(Client_EP_Handler, P_Buffer);
  
                
            else
                if ASU.To_String(Nick) /= "server" then
  

                    if not  Success then
                        Actives_Clients.Put(Actives_C, Nick, (Client_EP_Handler, Ada.Calendar.clock));
                        Acogido := True;
                        Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick) & ": ACCEPTED");
                        CM.Message_Type'Output(P_Buffer, CM.Welcome);
                        Boolean'Output(P_Buffer, Acogido);
                        LLU.Send(Client_EP_Receive, P_Buffer);
                        LLU.Reset(P_Buffer.all);
                        Inactives_Clients.Delete(Inactives_C, Nick, Success);
                        if Success then
                           Content := ASU.To_Unbounded_String(ASU.To_String(Nick)
                                                            & " rejoins the chat.");
                        else
                           Content := ASU.To_Unbounded_String(ASU.To_String(Nick)
                                                            & " joins the chat.");
                        end if;
                        CM.Message_Type'Output(P_Buffer, CM.Server);
                        ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
                        ASU.Unbounded_String'Output(P_Buffer, Content);

                        Send_To_All(Client_EP_Handler, P_Buffer);

                    else
                        Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick) & ": IGNORED. nick already used"); 
                    end if;      
                        
                end if;
                                     
            end if;
        elsif Mess_Type = CM.Writer then
            Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
            Nick := ASU.Unbounded_String'Input(P_Buffer);
            Content := ASU.Unbounded_String'Input(P_Buffer);
            LLU.Reset(P_Buffer.all);
            Ada.Text_IO.Put_Line("WRITER received from " & ASU.To_String(Nick) & ": " & ASU.To_String(Content));
            Actives_Clients.Get(Actives_C, Nick, Value, Success);
            if Success and LLU.Image(Value.EP) = LLU.Image(Client_EP_Handler) then
                CM.Message_Type'Output(P_Buffer, CM.Server);
                ASU.Unbounded_String'Output(P_Buffer, Nick);
                ASU.Unbounded_String'Output(P_Buffer, Content);
                Send_To_All(Client_EP_Handler, P_Buffer);
            end if;
    
   
        elsif Mess_Type = CM.Logout then
            Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
            Nick := ASU.Unbounded_String'Input(P_Buffer);
            Content := ASU.To_Unbounded_String(ASU.To_String(Nick) & " leaves the chat");
            LLU.Reset(P_Buffer.all);
            Ada.Text_IO.Put_Line("LOGOUT received from " & ASU.To_String(Nick));
            Actives_Clients.Get(Actives_C, Nick, Value, Success);
            if Success and LLU.Image(Value.EP) = LLU.Image(Client_EP_Handler) then
                Actives_Clients.Delete(Actives_C, Nick, Success);
                Inactives_Clients.Put(Inactives_C, Nick, Ada.Calendar.clock);
                LLU.Reset(P_Buffer.all);
                CM.Message_Type'Output(P_Buffer, CM.Server);
                ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
                ASU.Unbounded_String'Output(P_Buffer, Content);
                Send_To_All(Client_EP_Handler, P_Buffer);
            end if;

        else
            raise Error_Messages;
        end if;
        LLU.Reset(P_Buffer.all);

exception
    when Error_Messages =>
        Ada.Text_IO.Put_Line("Wrong message type");  
    end Handler;  
      

end Server_Handler;
