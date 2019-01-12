with Lower_Layer_UDP;
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;
with Hash_Maps_G;
with Ordered_Maps_G;
with Ada.Command_Line;
with Arguments_Control;


package Server_Handler is
    package LLU renames Lower_Layer_UDP;
    package CM renames Chat_Messages;
    package ASU renames Ada.Strings.Unbounded;
    package ACL renames Ada.Command_Line;
    use type CM.Message_Type;
    use type Ada.Calendar.Time;
    type Value_EP_Time is record
        EP: LLU.End_Point_Type;
        Time: Ada.Calendar.Time;
    end record;

	type Hash_Range is mod 50;
	function Hash (K: ASU.Unbounded_String) return Hash_Range;
    Max_Clients : Integer := Arguments_Control.Max_Clients_Arg;

    package Actives_Clients is new Hash_Maps_G(Key_Type  => ASU.Unbounded_String,
                                         Value_Type => Value_EP_Time,
                                         "="        => ASU."=",
										 Hash_Range => Hash_Range,
										 Hash		=> Hash,
										 Max		=> Max_Clients);
    Actives_C: Actives_Clients.Map;
    package Inactives_Clients is new Ordered_Maps_G(Key_Type  => ASU.Unbounded_String,
											Value_Type => Ada.Calendar.Time,
                                         	"="        => ASU."=",
										 	"<"		   => ASU."<",
										 	Max		=> Max_Clients);
    Inactives_C: Inactives_Clients.Map;

    procedure Handler (From: in LLU.End_Point_Type; To: in LLU.End_Point_Type; P_Buffer: access LLU.Buffer_Type);


end Server_Handler;
