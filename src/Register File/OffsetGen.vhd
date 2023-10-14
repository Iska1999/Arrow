library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;
entity OffsetGen is
  port (
    i_clk : in std_logic;
    i_rst: in std_logic;
    i_load : in std_logic; -- should be asserted for one clock cycle aka newInst
    i_mask : in std_logic_vector (VLEN-1 downto 0);
    i_vsew : in std_logic_vector (2 downto 0); -- vtype CSR [4:2]
    i_vlmul : in std_logic_vector (2 downto 0); -- vtype CSR [5,1:0]
    i_vl : in std_logic_vector (XLEN-1 downto 0); -- number of vector elements to be processed.
    i_vstart: in std_logic_vector (lgVLEN-1 downto 0); -- vstart CSR [log2VLEN-1:0]
    i_vm: in STD_LOGIC; -- vector instruction vm mask field (inst[25]). Masking disabled = 1. Masking enabled = 0.
    o_offset : out std_logic_vector (lgVLEN-1 downto 0); -- index of next vector element to be processed.
    WriteEnSel: out std_logic_vector (7 downto 0);
    o_done : out std_logic
  );
end OffsetGen;

architecture Behavioral of OffsetGen is

 signal SEW : natural range 8 to 1024;
 signal VLMAX : natural range 1 to 8192; -- maximum number of vector elements that can be processed for a given SEW and LMUL.
 signal MLEN : natural range 1 to 8192; -- mask element length, in bits. 
 
begin
 
  process(i_clk,i_vl,i_load,i_vsew,i_vm,SEW)
    variable NB_ELEMENTS_PER_TRANSFER:integer;
    variable FIRST_ELEMENT:natural range 0 to VLEN-1;
    variable NUM_ELEMENTS:natural range 0 to VLEN;
    variable ELEMENTS_LEFT:integer:=0;
    variable CURRENT_ELEMENT:integer;
    variable INITIATION:boolean:=FALSE; -- This is to subsitute the need for a FSM
    variable COUNTER:integer;
    variable MASK:STD_LOGIC_VECTOR(VLEN-1 downto 0);
    variable UPPER_BOUND:integer;
    variable LOWER_BOUND:integer;
    --variable SEW:natural range 8 to 1024;
    begin
   ------------------------------------------------------------------------------------------------------ 
        
     FIRST_ELEMENT:=to_integer(unsigned(i_vstart));   
     -- Setting NUM_ELEMENTS
     if (to_integer(unsigned(i_vl)) > VLMAX) then
        NUM_ELEMENTS:=VLMAX;
     else
        NUM_ELEMENTS:=to_integer(unsigned(i_vl));
     end if;
        
     NB_ELEMENTS_PER_TRANSFER:=64/SEW; -- This is the number of elements per transfer if the transfer is full
     
    -----------------------------------------------------------------------------------------------------     
     if (rising_edge(i_clk)) then 
     o_offset<=(others=>'1'); 
     WriteEnSel<=(others=>'0');     
       if (INITIATION=FALSE) then -- No instruction has arrived yet, keep done set to zero
            o_done<='0'; 
       end if;
       
       if (i_load = '1') then
           INITIATION:=TRUE;
           o_done<='0';
           ELEMENTS_LEFT:=NUM_ELEMENTS;
           CURRENT_ELEMENT:=FIRST_ELEMENT;
           COUNTER:=0;
           
           if(i_vm='1') then --Masking disabled
                MASK:=(others=>'1');
           else 
                MASK:=i_mask;
           end if;
     end if; 
                               
     if (ELEMENTS_LEFT/=0)   then    
     
            if (ELEMENTS_LEFT=NUM_ELEMENTS) then --The first transfer requires special treatment since we must account for vstart
                LOWER_BOUND:=FIRST_ELEMENT;
            else 
                LOWER_BOUND:=0;
            end if;

            if (ELEMENTS_LEFT>=NB_ELEMENTS_PER_TRANSFER) then --One or more transfer left
                UPPER_BOUND:=NB_ELEMENTS_PER_TRANSFER;
            else --Last transfer, or first and last transfer
                UPPER_BOUND:=ELEMENTS_LEFT; 
            end if;       
            
                            for i in 0 to 7 loop --7 since we can have a maximum of 8 elements per 64 bit transfer
                                if (i>=LOWER_BOUND and i<UPPER_BOUND and MASK(CURRENT_ELEMENT)='1') then
                                    if (SEW=8) then
                                        WriteEnSel(i*(SEW/8))<='1';
                                    elsif (SEW=16) then
                                        WriteEnSel(i*(SEW/8))<='1';
                                        WriteEnSel(i*(SEW/8)+1)<='1';
                                    elsif (SEW=32) then
                                        WriteEnSel(i*(SEW/8))<='1';
                                        WriteEnSel(i*(SEW/8)+1)<='1';
                                        WriteEnSel(i*(SEW/8)+2)<='1';
                                        WriteEnSel(i*(SEW/8)+3)<='1';
                                    elsif (SEW>=64) then
                                        WriteEnSel(i*(SEW/8))<='1';
                                        WriteEnSel(i*(SEW/8)+1)<='1';
                                        WriteEnSel(i*(SEW/8)+2)<='1';
                                        WriteEnSel(i*(SEW/8)+3)<='1';
                                        WriteEnSel(i*(SEW/8)+4)<='1';
                                        WriteEnSel(i*(SEW/8)+5)<='1';
                                        WriteEnSel(i*(SEW/8)+6)<='1';
                                        WriteEnSel(i*(SEW/8)+7)<='1';
                                    else 
                                        WriteEnSel<=(others=>'0');
                                    end if;
                                    ELEMENTS_LEFT:=ELEMENTS_LEFT-1;                        
                                end if;
                                CURRENT_ELEMENT:=CURRENT_ELEMENT+1; 
                                 
                            end loop;                                         
                    
                    o_offset<=std_logic_vector(to_unsigned(COUNTER, o_offset'length));
                    COUNTER:=COUNTER+1;                       
                    if (ELEMENTS_LEFT=0) then -- This is the case when the last transfer is a full one
                        o_done<='1'; 
                        COUNTER:=0;
                    end if; 
            else -- if ELEMENTS_LEFT=0, this is to indicate an idle state
                o_offset<=(others=>'1'); 
                WriteEnSel<=(others=>'0');           
       end if;                                        
    end if;   
    
    end process;

   --Set SEW
  with i_vsew select 
    SEW <= 8 when "000",
           16 when "001",
           32 when "010",
           64 when "011",
           128 when "100",
           256 when "101",
           512 when "110",
           1024 when "111",
           XLEN when others;

  -- Set VLMAX
  with i_vlmul select
    VLMAX <= VLEN/SEW when "000", -- LMUL = 1
             2*VLEN/SEW when "001", -- LMUL = 2
             4*VLEN/SEW when "010", -- LMUL = 4
             8*VLEN/SEW when "011", -- LMUL = 8
             VLEN/(SEW*8) when "101", -- LMUL = 1/8
             VLEN/(SEW*4) when "110", -- LMUL = 1/4
             VLEN/(SEW*2) when "111", -- LMUL = 1/2
             VLEN/SEW when others;

        MLEN<=1;   
end Behavioral;