with Ada.Text_IO;

package body Hash_Maps_G is

	procedure Get (M : in out Map;
					Key : in Key_Type;
					Value : out Value_Type;
					Success : out Boolean) is
		Index: Hash_Range;
		Index_Delete: Hash_Range := 0;
		Delete_mark : Boolean := False;
	begin
		Success := False;
		Index := Hash(Key);
		if M.P_Array(Index).Key = Key then
			Value := M.P_Array(Index).Value;
			Success := True;
		else
			while Index < Hash_Range'Last and not Success loop
				if M.P_Array(Index).Condition = Delete and not Delete_Mark then
					Index_Delete := Index;
					Delete_Mark := True;
				end if;
				Index := Index + 1;
				if M.P_Array(Index).Key = Key then
					Value := M.P_Array(Index).Value;
					Success := True;
					if Delete_Mark then
						M.P_Array(Index).Condition := Delete;
						M.P_Array(Index_Delete).Key := M.P_Array(Index).Key;
						M.P_Array(Index_Delete).Value := M.P_Array(Index).Value;
						M.P_Array(Index_Delete).Condition := Full;
						Success := True;
					end if;
				else	
					if M.P_Array(Index).Condition = Delete and not Delete_Mark then
						Index_Delete := Index;
						Delete_Mark := True;
					end if;
				end if;
			end loop;
		end if;
	
	end Get;

	procedure Delete (M : in out Map;
						Key : in Key_Type;
						Success : out Boolean) is
		Index : Hash_Range;
	begin
		Index := Hash(Key);
		Success := False;
		if M.P_Array(Index).Key = Key then
			M.P_Array(Index).Condition := Delete;
			M.Length := M.Length - 1;
			Success := True;	
		else
			while Index < Hash_Range'Last and not Success loop
				Index := Index + 1;
				if M.P_Array(Index).Key = Key then
					M.P_Array(Index).Condition := Delete;
					M.Length := M.Length - 1;
					Success := True;
				end if;
			end loop;
		end if;
	end Delete;

	procedure Put (M : in out Map;
					Key : Key_Type;
					Value : Value_Type) is
		Index: Hash_Range;
		Found: Boolean := False;
		Delete_Mark : Boolean := False;
		Index_Delete: Hash_Range := 0;

	begin
		Index := Hash(Key);
		if M.P_Array(Index).Key = Key then
			M.P_Array(Index).Value := Value;
			Found := True;
		end if;
		if M.P_Array(Index).Condition /= Full then
			M.P_Array(Index).Key := Key;
			M.P_Array(Index).Value := Value;
			M.P_Array(Index).Condition := Full;
			M.Length := M.Length + 1;
			Found := True;
		else
			while Index < Hash_Range'Last and not Found loop
				Index := Index + 1;
				if M.P_Array(Index).Key = Key then
					M.P_Array(Index).Value := Value;
					Found := True;
				else
					if M.P_Array(Index).Condition = Delete and not Delete_Mark then
						Index_Delete := Index;
						Delete_Mark := True;
					elsif Delete_Mark and M.P_Array(Index).Condition /= Full then
						M.P_Array(Index_Delete).Key := Key;
						M.P_Array(Index_Delete).Value := Value;
						M.P_Array(Index_Delete).Condition := Full;
						M.Length := M.Length + 1;
						Found := True;
					end if;
					if M.P_Array(Index).Condition /= Full and not Delete_Mark then
						M.P_Array(Index).Key := Key;
						M.P_Array(Index).Value := Value;
						M.P_Array(Index).Condition := Full;
						M.Length := M.Length + 1;
						Found := True;
					end if;
				end if;
			end loop;
		end if;
	end Put;

function Map_Length (M:Map) return Natural is   
    begin
        return M.Length;
    end Map_Length; 

	function First(M:Map) return Cursor is
		C: Cursor;
		Found: Boolean := False;
	begin
		C.M := M;
		--C.Index := 0;
		while Hash_Range(C.Index) < Hash_Range'Last and not Found loop
			if C.M.P_Array(Hash_Range(C.Index)).Condition /= Full then
				C.Index := C.Index + 1;
			else
				Found := True;
			end if;
		end loop;
		return C;
	end First;


    procedure Next (C: in out Cursor) is
		Index : Hash_Range := Hash_Range(C.Index) + 1;
		Found : Boolean := False;
    begin
		while Index < (Hash_Range'Last) and not Found loop
			if C.M.P_Array(Index).Condition /= Full then --and C.M.P_Array(Index).Condition /= Full loop
				Index := Index + 1;
			else
				Found := True;
			end if;
		end loop;
		if (Index > 0 and Index <= Hash_Range'Last) and C.M.P_Array(Index).Condition = Full then 
			C.Index := Integer(Index);
		else
			C.Index := -1;
		end if;
	end Next;
    function Has_Element (C:Cursor) return Boolean is
		Bool: Boolean := False;
    begin

		if C.Index /= -1 then
			Bool := True;
		end if;
		return Bool;
    end Has_Element;

    function Element (C:Cursor) return Element_Type is
        Elem: Element_Type;
    begin
        if not Has_Element(C) then
            raise No_Element;
        end if;
        Elem.Key := C.M.P_Array(Hash_Range(C.Index)).Key;
        Elem.Value := C.M.P_Array(Hash_Range(C.Index)).Value;
        return Elem;
    end Element;

end Hash_Maps_G;
