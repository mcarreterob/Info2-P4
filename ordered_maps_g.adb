with Ada.Text_IO;
package body Ordered_Maps_G is

	function Find_Index(M: Map; Key: Key_Type) return Natural is
		Left: Integer;
		Right: Integer;
		Mid: Integer;
	begin
		if M.Length = 0 then
			return 1;
		end if;
		Left := 1;
		Right := M.Length;
		while Left <= Right loop
			Mid := (Left + Right) / 2;
			if M.P_Array(Mid).Key = Key then
				return Mid;
			elsif M.P_Array(Mid).Key < Key then
				Left := Mid + 1;
			else
				Right := Mid - 1;
			end if;
		end loop;
		return 1;
	end Find_Index;

	procedure Put(M: in out Map; Key: Key_Type; Value: Value_Type) is
		Left: Integer;
		Right: Integer;
		Mid: Integer;
	begin
		if M.Length = 0 then -- Lista Vacia
			M.P_Array(1).Key := Key;
			M.P_Array(1).Value := Value;
			M.Length := M.Length + 1;
		elsif Key < M.P_Array(1).Key then -- Key < que la primera posición
			M.P_Array(2..(M.Length + 1)) := M.P_Array(1..M.Length);
			M.P_Array(1).Key := Key;
			M.P_Array(1).Value := Value;
			M.Length := M.Length + 1;
		elsif not (Key < M.P_Array(M.Length).Key) then -- Key > ult. posicion
			M.P_Array(M.Length + 1).Key := Key;
			M.P_Array(M.Length + 1).Value := Value;
			M.Length := M.Length + 1;
		else
			Left := 1;
			Right:= M.Length;
			while Left <= Right loop
				Mid := (Left+Right) / 2;
				if (M.P_Array(Mid).Key < Key) and (Key < M.P_Array(Mid +1).Key) then
					M.P_Array((Mid + 2)..(M.Length + 1)) := M.P_Array((Mid + 1)..(M.Length));
					M.P_Array(Mid + 1).Key := Key;
					M.P_Array(Mid + 1).Value := Value;
					M.Length := M.Length + 1;
				elsif M.P_Array(Mid).Key < Key then
					Left := Mid + 1;
				else
					Right := Mid - 1;
				end if;
			end loop;
		end if;
	end Put;

	procedure Get(M: in out Map; Key: in Key_Type; Value: out Value_Type; Success: out Boolean) is
		Index: Integer;
	begin
		Success := False;
		Index := Find_Index(M, Key);
		if M.P_Array(Index).Key = Key then
			Value := M.P_Array(Index).Value;
			Success := True;
		end if;
	end Get;

	procedure Delete(M: in out Map; Key: Key_Type; Success: out Boolean) is
		Index: Integer;
	begin
		Index := Find_Index(M, Key);
		Success := False;
		if M.P_Array(Index).Key = Key then
			M.P_Array(Index..(M.Length -1))	:= M.P_Array((Index + 1)..M.Length);
			M.Length := M.Length - 1;
			Success := True;
		end if;
	end Delete;

	function Map_Length(M:Map) return Natural is
	begin
		return M.Length;
	end Map_Length;

	function First(M:Map) return Cursor is
		Index: Natural;
	begin
		Index := 1;
		return (M, Index);
	end First;

	function Has_Element(C: Cursor) return Boolean is
		Bool: Boolean;
	begin
		if C.Index /= 0 then
			Bool := True;
		else
			Bool := False;
		end if;
		return Bool;	
	end Has_Element;

	procedure Next(C: in out Cursor) is
		
	begin
		if C.Index = 0 or C.Index >= C.M.Length then
			C.Index := 0;
		else
			C.Index := C.Index + 1;
		end if;
	end Next;

	function Element(C: Cursor) return Element_Type is
		Elem: Element_Type;
	begin
		if not Has_Element(C) then
			raise No_Element;
		end if;
		Elem.Key := C.M.P_Array(C.Index).Key;
		Elem.Value := C.M.P_Array(C.Index).Value;
		return Elem;
	end Element;

end Ordered_Maps_G;
