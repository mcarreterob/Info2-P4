with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Chat_Messages;
with Ada.Command_Line;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Server_Handler;
with Ada.Strings.Maps;

procedure Chat_Server_2 is
   package LLU renames Lower_Layer_UDP;
	package ATIO renames Ada.Text_IO;
   package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
   package ASM renames Ada.Strings.Maps;
   package Actives_C renames Server_Handler.Actives_Clients;
   package Inactives_C renames Server_Handler.Inactives_Clients;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;

   function Time_Image (T: Ada.Calendar.Time) return String is
   begin
      return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
   end Time_Image;

   function Extraer_IP (EP: LLU.End_Point_Type) return ASU.Unbounded_String is
      Client_EP: LLU.End_Point_Type;
		Client_Nick: ASU.Unbounded_String;
		Client_IP: ASU.Unbounded_String;
		Client_Port: ASU.Unbounded_String;
		Image_Line: ASU.Unbounded_String;
      Position: Integer;
   begin
      LLU.Bind_Any(Client_EP);
		Image_Line := ASU.To_Unbounded_String(LLU.Image(Client_EP));
		Position := ASU.Index(Image_Line, ASM.To_Set(":")) + 1;
		Image_Line := ASU.Tail(Image_Line, ASU.Length(Image_Line) - Position);
		Position := ASU.Index(Image_Line, ASM.To_Set(","));
		Client_IP := ASU.Head(Image_Line, Position - 1);
		Image_Line := ASU.Tail(Image_Line, ASU.Length(Image_Line) - Position);
		Position := ASU.Index(Image_Line, ASM.To_Set(":")) + 1;
      Client_Port := ASU.Tail(Image_Line, Position - 1);
      return Client_IP;
   end Extraer_IP;

   procedure Print_ActiveClients_Map (Map: Actives_C.Map) is
      Cursor: Actives_C.Cursor := Actives_C.First(Map);
   begin
      ATIO.Put_Line("===========");
      while Actives_C.Has_Element(Cursor) loop
         ATIO.Put(ASU.To_String(Actives_C.Element(Cursor).Key) & " ");
         ATIO.Put(ASU.To_String(Extraer_IP(Actives_C.Element(Cursor).Value.EP)));
         ATIO.Put_Line(" " & Time_Image(Actives_C.Element(Cursor).Value.Time));
         Actives_C.Next(Cursor);
      end loop;
   end Print_ActiveClients_Map;

   procedure Print_InactiveClients_Map (Map: Inactives_C.Map) is
      Cursor: Inactives_C.Cursor := Inactives_C.First(Map);
   begin
      ATIO.Put_Line("===========");
      while Inactives_C.Has_Element(Cursor) loop
         ATIO.Put(ASU.To_String(Inactives_C.Element(Cursor).Key) & " ");
         ATIO.Put_Line(Time_Image(Inactives_C.Element(Cursor).Value));
         Inactives_C.Next(Cursor);
      end loop;
   end Print_InactiveClients_Map;

   Server_EP: LLU.End_Point_Type;
	Maquina: ASU.Unbounded_String := ASU.To_Unbounded_String(LLU.Get_Host_Name);
	IP: String := LLU.To_IP(ASU.To_String(Maquina));
   Option: Character;
	Max_Clients: Integer;

	Arguments_Error: exception;

begin

	Max_Clients:= Integer'Value(ACL.Argument(2));
	if Max_Clients < 2 or Max_Clients > 50 then
	   raise Arguments_Error;
	end if;

   -- construye un End_Point en una dirección y puerto concretos:
	--IP: la de la maquina en la que se ejecute el programa
	--Puerto: el que se le pasa por la linea de comandos
   Server_EP := LLU.Build (IP, Integer'Value(ACL.Argument(1)));

   LLU.Bind (Server_EP, Server_Handler.Handler'Access);

   loop
      ATIO.Get_Immediate(Option);
      if Option = 'L' or Option = 'l' then
         ATIO.New_Line;
         ATIO.Put_Line("ACTIVE CLIENTS");
         Print_ActiveClients_Map(Server_Handler.Actives_C);
         ATIO.New_Line;
      elsif Option = 'O' or Option = 'o' then
         ATIO.New_Line;
         ATIO.Put_Line("OLD CLIENTS");
         Print_InactiveClients_Map(Server_Handler.Inactives_C);
         ATIO.New_Line;
      else
         ATIO.New_Line;
         ATIO.Put("Incorrect option: ");
         ATIO.Put("l or L to show ACTIVE CLIENTS");
         ATIO.Put_Line("o or O to show INACTIVE CLIENTS");
         ATIO.New_Line;
      end if;
   end loop;

exception
	When CONSTRAINT_ERROR =>
      ATIO.New_Line;
	   ATIO.Put_Line("Please, only positive numbers between 2 and 50. Both included");
      ATIO.New_Line;
		LLU.Finalize;
   when Arguments_Error =>
      ATIO.New_Line;
		ATIO.Put_Line("2 < Number of clients < 50. Both included");
      ATIO.New_Line;
		LLU.Finalize;
   when Ex:others =>
      ATIO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;
