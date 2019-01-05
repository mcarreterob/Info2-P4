with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Hash_Maps_G;

procedure Hash_Maps_Test5 is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;

   HASH_SIZE: constant := 257;
   MAGIC_PRIME: constant := 31;

   type Hash_Range is mod HASH_SIZE;

   function String_Hash (S: ASU.Unbounded_String) return Hash_Range is
      R: Hash_Range := 0;
   begin
      for I in 1..ASU.Length(S) loop
         R := R + Character'Pos(ASU.To_String(S)(I)) * MAGIC_PRIME * Hash_Range(I);
      end loop;
      return R;
   end String_Hash;


   package Maps is new Hash_Maps_G (Key_Type   => ASU.Unbounded_String,
                                    Value_Type => ASU.Unbounded_String,
                                    "="        => ASU."=",
                                    Max_Length_M        => 20,
                                    Hash_Range => Hash_Range,
                                    Hash => String_Hash);


   procedure Print_Map (M : Maps.Map) is
      C: Maps.Cursor := Maps.First(M);
   begin
      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");

      while Maps.Has_Element(C) loop
         Ada.Text_IO.Put_Line (ASU.To_String(Maps.Element(C).Key) & " " &
                                 ASU.To_String(Maps.Element(C).Value));
         Maps.Next(C);
      end loop;
   end Print_Map;


   Value   : ASU.Unbounded_String;
   Success : Boolean;

   A_Map : Maps.Map;

begin

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   --Print_Map (A_Map);

   Maps.Put (A_Map,
             ASU.To_Unbounded_String ("facebook.com"),
             ASU.To_Unbounded_String ("69.63.189.16"));

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map(A_Map);


   ATIO.New_Line;
   Maps.Get (A_Map, ASU.To_Unbounded_String ("www.urjc.es"), Value, Success);
   if Success then
      ATIO.Put_Line ("Get: Dirección IP de www.urjc.es: " &
                       ASU.To_String(Value));
   else
      ATIO.Put_Line ("Get: NO hay una entrada para la clave www.urjc.es");
   end if;

   Maps.Put (A_Map, ASU.To_Unbounded_String ("google.com"),
              ASU.To_Unbounded_String ("66.249.92.104"));

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map(A_Map);

   Maps.Put (A_Map,
              ASU.To_Unbounded_String ("www.urjc.es"),
              ASU.To_Unbounded_String ("212.128.240.25"));

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map(A_Map);

   Maps.Put (A_Map,
              ASU.To_Unbounded_String ("facebook.com"),
              ASU.To_Unbounded_String ("69.63.189.11"));

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map(A_Map);

   ATIO.New_Line;
   Maps.Get (A_Map, ASU.To_Unbounded_String ("www.urjc.es"), Value, Success);
   if Success then
      ATIO.Put_Line ("Get: Dirección IP de www.urjc.es: " &
                       ASU.To_String(Value));
   else
      ATIO.Put_Line ("Get: NO hay una entrada para la clave www.urjc.es");
   end if;

   ATIO.New_Line;
   Maps.Delete (A_Map, ASU.To_Unbounded_String("google.com"), Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO google.com");
   else
      ATIO.Put_Line ("Delete: google.com no encontrado");
   end if;

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map(A_Map);

   ATIO.New_Line;
   Maps.Delete (A_Map, ASU.To_Unbounded_String("www.urjc.es"), Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO www.urjc.es");
   else
      ATIO.Put_Line ("Delete: www.urjc.es no encontrado");
   end if;

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map (A_Map);

   ATIO.New_Line;
   Maps.Delete (A_Map, ASU.To_Unbounded_String("bbb.bbb.bbb"), Success);
   if Success then
      ATIO.Put_Line ("Delete: BORRADO bbb.bbb.bbb");
   else
      ATIO.Put_Line ("Delete: bbb.bbb.bbb no encontrado");
   end if;

   ATIO.New_Line;
   ATIO.Put_Line ("Longitud de la tabla de símbolos: " &
                    Integer'Image(Maps.Map_Length(A_Map)));
   Print_Map (A_Map);



end Hash_Maps_Test5;
