--
--  TAD genérico de una tabla de símbolos (map) implementada como una lista
--  enlazada no ordenada.
--

generic
   type Key_Type is private;
   type Value_Type is private;
   with function "=" (K1, K2: Key_Type) return Boolean;
   with function "<" (K1, K2: Key_Type) return Boolean;
   with function ">" (K1, K2: Key_Type) return Boolean;
   with function Key_To_String (K: Key_Type) return String;
   with function Value_To_String (K: Value_Type) return String;
package Maps_G is

   type Map is limited private;
	type Cursor is limited private;

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean);


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type);

   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean);


   function Map_Length (M : Map) return Natural;

   procedure Print_Map (M : Map);

	function Map_Depth_Max (M: Map) return Natural;

	function Map_Depth_Min (M: Map) return Natural;

	function Min (M : Map) return Map;
	function Max (M : Map) return Map;

	procedure Recorrido(M: in out Map; C: out Cursor);
	function Delete_Min(M : Map) return Map;



private

   type Tree_Node;
   type Map is access Tree_Node;
   type Tree_Node is record
      Key   : Key_Type;
      Value : Value_Type;
      Left  : Map;
      Right : Map;
   end record;

	type Cursor is record
		M: Map;
		Salto: Natural := 0;
	end record;

end Maps_G;
