with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Maps_G;

procedure Maps_G_Test is
	package ASU renames Ada.Strings.Unbounded;
	


	package Maps is new Maps_G (Key_Type   => ASU.Unbounded_String,
                                    Value_Type => ASU.Unbounded_String,
                                    "="        => ASU."=",
									"<" => ASU."<",
									">" => ASU.">",
									Key_To_String => ASU.To_String,
									Value_To_String => ASU.To_String);
	M: Maps.Map;
	C: Maps.Cursor;
begin


	Maps.Put(M,ASU.To_Unbounded_String("5"),ASU.To_Unbounded_String("5"));
	Maps.Put(M,ASU.To_Unbounded_String("2"),ASU.To_Unbounded_String("2"));
	Maps.Put(M,ASU.To_Unbounded_String("6"),ASU.To_Unbounded_String("6"));
	Maps.Put(M,ASU.To_Unbounded_String("4"),ASU.To_Unbounded_String("4"));
	Maps.Put(M,ASU.To_Unbounded_String("1"),ASU.To_Unbounded_String("1"));
	Maps.Print_Map(M);


   Ada.Text_IO.Put("La profundidad máxima es: ");
   Ada.Text_IO.Put_Line(Natural'Image(Maps.Map_Depth_Max(M)));
	Ada.Text_IO.Put("La profundidad mínima es: ");
	Ada.Text_IO.Put_Line(Natural'Image(Maps.Map_Depth_Min(M)));

	Maps.Recorrido(M,C);
	Maps.Print_Map(M);

end Maps_G_Test;
