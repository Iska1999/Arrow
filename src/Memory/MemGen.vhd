library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MemGen is
Port (
    i_clk : in std_logic;
    i_rst: in std_logic;
    i_load : in std_logic; -- should be asserted for one clock cycle aka newInst
    i_mask : in std_logic_vector (VLEN-1 downto 0);
    i_memwidth : in std_logic_vector (2 downto 0); -- vtype CSR [4:2]
    i_mew: in std_logic;
    i_vlmul : in std_logic_vector (2 downto 0); -- vtype CSR [5,1:0]
    i_vl : in std_logic_vector (XLEN-1 downto 0); -- number of vector elements to be processed.
    i_vstart: in std_logic_vector (lgVLEN-1 downto 0); -- vstart CSR [log2VLEN-1:0]
    i_vm: in STD_LOGIC; -- vector instruction vm mask field (inst[25]). Masking disabled = 1. Masking enabled = 0.
    i_mop: in STD_LOGIC_VECTOR(1 downto 0);      -- 00 : unit stride for both load and store  
                                                 -- 01 : reserved for loads and indexed-unordered for store
                                                 -- 10 : strided for both load and store
                                                 -- 11 : indexed (ordered in case of a store)                                             
    i_rs1_data: in STD_LOGIC_VECTOR(XLEN-1 downto 0); -- contains base effective address
    i_rs2_data: in STD_LOGIC_VECTOR(XLEN-1 downto 0); -- contains stride offset incase of strided operation
    i_vs2_data: in STD_LOGIC_VECTOR(63 downto 0); --   
    i_lumop: in STD_LOGIC_VECTOR(4 downto 0); --additional addressing field
    -- 00000: unit stride
    -- 01000: unit stride, whole registers
    -- 10000: unit stride fault only first
    i_sumop: in STD_LOGIC_VECTOR(4 downto 0);  --additional addressing field
    -- 00000: unit stride
    -- 01000: unit stride, whole registers
    o_mem_address: out STD_LOGIC_VECTOR(XLEN-1 downto 0);
    o_offset : out std_logic_vector (lgVLEN-1 downto 0); -- index of next vector element to be processed.
    WriteEnMemSel: out std_logic_vector(7 downto 0); --WriteEnable Select going to the registerfile in case it is a masked load
    o_done : out std_logic
 );
end MemGen;

architecture Behavioral of MemGen is

--  signal address: STD_LOGIC_VECTOR(XLEN-1 downto 0); -- stores the address reached so far
  signal current_mask : std_logic_vector (VLEN-1 downto 0);
  signal MEMWIDTH : integer range 8 to 1024;
  signal VLMAX : natural range 1 to 8192; -- maximum number of vector elements that can be processed for a given SEW and LMUL.
  signal MLEN : natural range 1 to 8192; -- mask element length, in bits.
  signal FIRST_ELEMENT : natural range 0 to VLEN-1; -- index of first element to be processed.
  signal NUM_ELEMENTS : natural range 0 to VLEN; -- number of elements to be processed.
  signal counter:integer:=0;


begin

  -- Set MEMWIDTH
    MEMWIDTH<= 16 when i_memwidth="001" and i_mew='0'  else
               32 when i_memwidth="010" and i_mew='0' else
               64 when i_memwidth="011" and i_mew='0' else
               128 when i_memwidth="100" and i_mew='0' else
               16 when i_memwidth="001" and i_mew='1' else
               32 when i_memwidth="010" and i_mew='1' else
               64 when i_memwidth="011" and i_mew='1' else
               128 when i_memwidth="100" and i_mew='1' else
               8 when i_memwidth="000" and i_mew='0' else    
               16 when i_memwidth="101" and i_mew='0' else
               32 when i_memwidth="110" and i_mew='0' else
               64 when i_memwidth="111" and i_mew='0' else
               128 when i_memwidth="000" and i_mew='1' else
               256 when i_memwidth="101" and i_mew='1' else
               512 when i_memwidth="110" and i_mew='1' else
               1024 when i_memwidth="111" and i_mew='1'; 

  -- Set VLMAX
  with i_vlmul select
    VLMAX <= VLEN/MEMWIDTH when "000", -- LMUL = 1
             2*VLEN/MEMWIDTH when "001", -- LMUL = 2
             4*VLEN/MEMWIDTH when "010", -- LMUL = 4
             8*VLEN/MEMWIDTH when "011", -- LMUL = 8
             VLEN/(MEMWIDTH*8) when "101", -- LMUL = 1/8
             VLEN/(MEMWIDTH*4) when "110", -- LMUL = 1/4
             VLEN/(MEMWIDTH*2) when "111", -- LMUL = 1/2
             VLEN/MEMWIDTH when others;

  -- Set MLEN, in the newest spec it is set to 1
  process(i_vlmul) begin
--    if (SLEN< VLEN) then --TODO: double check this case
--        case(i_vlmul) is
--            when "000"=> MLEN<= MEMWIDTH; -- LMUL = 1  
--            when "001"=> MLEN<= MEMWIDTH/2; -- LMUL = 2  
--            when "010"=> MLEN<= MEMWIDTH/4; -- LMUL = 4  
--            when "011"=> MLEN<= MEMWIDTH/8; -- LMUL = 8  
--            when "101"=> MLEN<= MEMWIDTH*8; -- LMUL = 1/8
--            when "110"=> MLEN<= MEMWIDTH*4; -- LMUL = 1/4
--            when "111"=> MLEN<= MEMWIDTH*2; -- LMUL = 1/2
--            when others=>MLEN<= 1;
--        end case;
--     else
        MLEN<=1;
--    end if;
  end process;
 
   process(i_clk,i_vl,i_load,MEMWIDTH,i_vm,i_vs2_data,i_rs2_data)
    variable NB_ELEMENTS_PER_TRANSFER:integer;
    variable FIRST_ELEMENT:natural range 0 to VLEN-1;
    variable NUM_ELEMENTS:natural range 0 to VLEN;
    variable ELEMENTS_LEFT:integer:=0;
    variable CURRENT_ELEMENT:integer:=0;
    variable INITIATION:boolean:=FALSE; -- This is to subsitute the need for a FSM
    variable FRAGMENTS:boolean:=FALSE;
    variable INDEXED:boolean:=FALSE;
    variable STRIDED:boolean:=FALSE;
    variable COUNTER:integer;
    variable MASK:STD_LOGIC_VECTOR(VLEN-1 downto 0);
    variable vs2_extended : std_logic_vector (XLEN-1 downto 0);
    variable vs2_extended_int: integer; -- contains byte offset number as an integer
    variable rs2_int:integer;
    variable offset:integer;
    variable last_offset:integer; --to be used with indexed instructions
    variable UPPER_BOUND:integer;
    variable LOWER_BOUND:integer;
    variable ELEMENT_COUNTER:integer;
    variable remaining:integer:=0;
    variable j:integer:=0; -- a counter 
    begin
   ------------------------------------------------------------------------------------------------------ 
        
     FIRST_ELEMENT:=to_integer(unsigned(i_vstart));   
     -- Setting NUM_ELEMENTS
     if (to_integer(unsigned(i_vl)) > VLMAX) then
        NUM_ELEMENTS:=VLMAX;
     else
        NUM_ELEMENTS:=to_integer(unsigned(i_vl));
     end if;
        
     NB_ELEMENTS_PER_TRANSFER:=64/MEMWIDTH; -- This is the number of elements per transfer if the transfer is full
     
    -----------------------------------------------------------------------------------------------------     
     if (rising_edge(i_clk)) then 
     
     o_offset<=(others=>'1'); 
     WriteEnMemSel<=(others=>'0'); 
     o_mem_address<= (others=>'0');
         
       if (INITIATION=FALSE) then -- No instruction has arrived yet, keep done set to zero
            o_done<='0'; 
       end if;
       
       if (i_load = '1') then
           INITIATION:=TRUE;
           o_done<='0';
           ELEMENTS_LEFT:=NUM_ELEMENTS;
           CURRENT_ELEMENT:=FIRST_ELEMENT;
           COUNTER:=0;
           ELEMENT_COUNTER:=0;
           if(i_vm='1') then --Masking disabled
                MASK:=(others=>'1');
           else 
                MASK:=i_mask;
           end if;
     end if; 
    -----------------------------------------------------------------------------------------------------
     
     if (VLEN>XLEN) then --If vector data is larger than XLEN, only take XLEN least significant bits
         vs2_extended:=i_vs2_data(XLEN-1 downto 0);
     else
         vs2_extended:=i_vs2_data;
     end if; 
         vs2_extended_int:=to_integer(unsigned(vs2_extended));              
                  
    rs2_int:=to_integer(unsigned(i_rs2_data));
    -----------------------------------------------------------------------------------------------------

    if (ELEMENTS_LEFT/=0) then
            if (ELEMENTS_LEFT=NUM_ELEMENTS) then --The first transfer requires special treatment since we must account for vstart
                o_mem_address<=i_rs1_data; -- In the first transfer, address takes rs1_data
                LOWER_BOUND:=FIRST_ELEMENT;
            else 
                LOWER_BOUND:=0;
            end if;
            if (ELEMENTS_LEFT>=NB_ELEMENTS_PER_TRANSFER) then --One or more transfer left
                UPPER_BOUND:=NB_ELEMENTS_PER_TRANSFER;
            else --Last transfer, or first and last transfer
                UPPER_BOUND:=ELEMENTS_LEFT; 
            end if; 
        case i_mop is
            when "00"=>             
                    for i in 0 to 7 loop --7 since we can have a maximum of 8 elements per 64 bit transfer
                            if (i>=LOWER_BOUND and i<UPPER_BOUND and MASK(CURRENT_ELEMENT)='1') then
                                    if (MEMWIDTH=8) then
                                        WriteEnMemSel(i*(MEMWIDTH/8))  <='1';
                                    elsif (MEMWIDTH=16) then               
                                        WriteEnMemSel(i*(MEMWIDTH/8))  <='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+1)<='1';
                                    elsif (MEMWIDTH=32) then
                                        WriteEnMemSel(i*(MEMWIDTH/8))  <='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+1)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+2)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+3)<='1';
                                    elsif (MEMWIDTH>=64) then
                                        WriteEnMemSel(i*(MEMWIDTH/8))  <='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+1)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+2)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+3)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+4)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+5)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+6)<='1';
                                        WriteEnMemSel(i*(MEMWIDTH/8)+7)<='1';
                                     else 
                                        WriteEnMemSel<=(others=>'0');                                       
                                    end if;  
                                    ELEMENTS_LEFT:=ELEMENTS_LEFT - 1;                                                      
                            end if;
                            CURRENT_ELEMENT:=CURRENT_ELEMENT+1;                                         
                        end loop;

                    o_offset<=std_logic_vector(to_unsigned(COUNTER, o_offset'length));
                    COUNTER:=COUNTER+8; 
                                          
                    if (ELEMENTS_LEFT=0) then -- This is the case when the last transfer is a full one
                        o_done<='1'; 
                        COUNTER:=0;
                    end if;                                                                
                       
            when "01"=>  -- unordered is an optimization, won't be implemented now                                                 
            when "10"=>  -- Byte offset is stored in rs2_data 
                    offset:=rs2_int; 
                    STRIDED:=TRUE;         
            when "11"=>  -- Offset increments stored in vs2_extended
                    -- Vector indexed still not supported
                    INDEXED:=TRUE;
                    

            when others => o_mem_address<= (others=>'0');               
        end case;
        
        
        
        
             
            if (STRIDED=TRUE or INDEXED=TRUE) then        
                        for i in 0 to 7 loop --7 since we can have a maximum of 8 elements per 64 bit transfer
                            -- i is the element counter, and j is the offset counter
                            if (INDEXED=TRUE) then -- If fragments is false, we want to use the element of the previous cycle
                                if (MEMWIDTH*(ELEMENT_COUNTER+1)>64) then
                                    ELEMENT_COUNTER:=0;
                                end if;
                                if (MEMWIDTH=8) then
                                    offset:=to_integer(unsigned(i_vs2_data(8*(ELEMENT_COUNTER+1)-1 downto 8*ELEMENT_COUNTER)));
                                elsif (MEMWIDTH=16) then
                                    offset:=to_integer(unsigned(i_vs2_data(16*(ELEMENT_COUNTER+1)-1 downto 16*ELEMENT_COUNTER)));
                                elsif (MEMWIDTH=32) then
                                    offset:=to_integer(unsigned(i_vs2_data(32*(ELEMENT_COUNTER+1)-1 downto 32*ELEMENT_COUNTER)));
                                elsif (MEMWIDTH=64) then
                                    offset:=to_integer(unsigned(i_vs2_data));                                      
                                end if;
                                ELEMENT_COUNTER:=ELEMENT_COUNTER+1;
                            end if; 
                                                                                                                                      
                            if (i=0 and FRAGMENTS=TRUE) then -- This is the case where we still have fragments of an element from the previous cycle
                                WriteEnMemSel(j downto 0)<=(others=>'1');
                                FRAGMENTS:=FALSE;
                                if (STRIDED=TRUE) then                               
                                    j:=j+offset+1; --add offset after finishing the fragment
                                elsif (INDEXED = TRUE) then
                                    j:=j+last_offset+1; --add offset after finishing the fragment                                
                                end if;
                            end if;
                            
                            if (i>=LOWER_BOUND and i<UPPER_BOUND and MASK(CURRENT_ELEMENT)='1') then
                                    if (MEMWIDTH=8) then
                                        if (j>7) then
                                            FRAGMENTS:=TRUE; 
                                            remaining:=j;                                          
                                        else                                              
                                            WriteEnMemSel(j)  <='1'; 
                                            --j:=j*(MEMWIDTH/8);                                        
                                        end if;
                                    elsif (MEMWIDTH=16) then
                                    
                                        if (j>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j;
                                        else                                             
                                            WriteEnMemSel(j) <= '1';
                                            --j:=j*(MEMWIDTH/8);
                                        end if;
                                        if (j+1>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+1;
                                        else                                                                                          
                                            WriteEnMemSel(j+1)  <='1';
                                            j:=j+1; -- Last reached index during writing
                                        end if;                                                   
                                        
                                    elsif (MEMWIDTH=32) then
                                        if (j>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j;
                                        else                                              
                                            WriteEnMemSel(j)  <='1';
                                        end if;
                                        if (j+1>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+1;
                                        else                                               
                                            WriteEnMemSel(j+1)  <='1';
                                        end if;
                                        if (j+2>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+2;
                                        else                                             
                                            WriteEnMemSel(j+2)  <='1';
                                        end if;
                                        if (j+3>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+3; -- Last reached index during writing
                                        else                                               
                                            WriteEnMemSel(j+3)  <='1';
                                            j:=j+3;
                                        end if;
                                    elsif (MEMWIDTH>=64) then
                                        if (j>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j;
                                        else                                               
                                            WriteEnMemSel(j)  <='1';
                                        end if;
                                        if (j+1>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+1;
                                        else                                             
                                            WriteEnMemSel(j+1)  <='1';
                                        end if;
                                        if (j+2>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+2;
                                        else                                              
                                            WriteEnMemSel(j+2)  <='1';
                                        end if;
                                        if (j+3>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+3;
                                        else                                               
                                            WriteEnMemSel(j+3)  <='1';
                                        end if;
                                        if (j+4>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+4;
                                        else
                                            WriteEnMemSel(j+4)  <='1';
                                        end if;
                                        if (j+5>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+5;
                                        else                                               
                                            WriteEnMemSel(j+5)  <='1';
                                        end if;
                                        if (j+6>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+6;
                                        else                                               
                                            WriteEnMemSel(j+6)  <='1';                                           
                                        end if;
                                        if (j+7>7) then
                                            FRAGMENTS:=TRUE;
                                            remaining:=j+7;
                                        else
                                                                                           
                                            WriteEnMemSel(j+7)  <='1';
                                            j:=j+7; -- Last reached index during writing
                                            
                                        end if;
                                     else 
                                        WriteEnMemSel<=(others=>'0');
                                    end if;
                                  
                                ELEMENTS_LEFT:=ELEMENTS_LEFT-1;
                                    
                            end if;
                            CURRENT_ELEMENT:=CURRENT_ELEMENT+1;                                                       
                            if (FRAGMENTS=TRUE) then
                                j:=remaining-8; -- Now j represents the number of bytes left of the last element
                                exit;
                            else -- If no fragments are left, we can process the byte offset
                            if (MASK(CURRENT_ELEMENT-1)='1') then
                                j:=j+offset+1;
                            else
                                j:=j+MEMWIDTH/8+offset;
                            end if;
                            if (j>7) then -- If byte offset no longer fits in the current 64 bits of transfer
                                j:=j-8;   -- This is to keep the number of byte offsets left for the next cycle
                                last_offset:=offset;
                                exit;
                            end if;
                            end if;
                            
                             
                                   
                        end loop;                                                                                                                                               
                                                                               
                        o_offset<=std_logic_vector(to_unsigned(COUNTER, o_offset'length));
                        COUNTER:=COUNTER+1;                       
                    if (ELEMENTS_LEFT=0) then -- This is the case when the last transfer is a full one
                        o_done<='1';
                        ELEMENT_COUNTER:=0;
                        j:=0; 
                        COUNTER:=0;
                        INDEXED:=FALSE;
                        STRIDED:=FALSE;
                    end if;                 
        end if;
          
        end if;
     end if;
    end process;


end Behavioral;
