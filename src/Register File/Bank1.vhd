library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bank1 is
    Port ( clk : in STD_LOGIC;
           out1 : out STD_LOGIC_VECTOR (63 downto 0);
           out2 : out STD_LOGIC_VECTOR (63 downto 0);
           mask_bit: out STD_LOGIC;
           RegSel1 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           RegSel2 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           WriteEn: in STD_LOGIC;
           WriteEnSel : in STD_LOGIC_VECTOR(7 downto 0); -- 8 bits since this is the maximum number of elements in 64 bits
           WriteData : in STD_LOGIC_VECTOR (63 downto 0);
           WriteDest : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           sew: in STD_LOGIC_VECTOR (2 downto 0);
           vlmul: in STD_LOGIC_VECTOR(2 downto 0);
           vl: in STD_LOGIC_VECTOR(XLEN-1 downto 0);
           vstart: in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           mask_reg: out STD_LOGIC_VECTOR(VLEN-1 downto 0);
           r_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           w_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           reg_out: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software
           );
end Bank1;

architecture Bank1_arch of Bank1 is
    type registerFile is array(0 to 32/NB_LANES-1) of std_logic_vector(VLEN-1 downto 0);   
    signal registers : registerFile;
    signal w_offset_int:integer;
    signal r_offset_int:integer;
    signal sew_int: natural;
    
begin

    mask_reg<=registers(0);
    reg_out<= registers(0);
    
    with sew select 
    sew_int <= 8 when "000",
           16 when "001",
           32 when "010",
           64 when "011",
           128 when "100",
           256 when "101",
           512 when "110",
           1024 when "111",
           XLEN when others; 
                       
    w_offset_int<=to_integer(unsigned(w_offset));
    r_offset_int<=to_integer(unsigned(r_offset));  
     
    p1: process(clk, RegSel1, RegSel2, WriteDest, WriteData, WriteEn,WriteEnSel, registers,sew,w_offset,r_offset) is
    begin
        
        if rising_edge(clk) then -- Write on the rising edge
        -- VLEN = 256 bits, meaning the vector register is 256 bits. 
        -- Supporting higher VLEN entails supporting higher offset numbers
            if(WriteEn='1') then
--                case sew_int is 
--                    when 8=>
                    if (WriteEnSel(0)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 7 downto 0 )<=WriteData( 7 downto 0);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 8+64-1 downto 64 )<=WriteData( 7 downto 0);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 8+64*2-1 downto 64*2 )<=WriteData( 7 downto 0);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 8+64*3-1 downto 64*3 )<=WriteData( 7 downto 0);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;
                    end if;
                    if (WriteEnSel(1)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 15 downto 8 )<=WriteData( 15 downto 8);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 16+64-1 downto 8+64 )<=WriteData( 15 downto 8);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 16+64*2-1 downto 8+64*2 )<=WriteData( 15 downto 8);                       
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 16+64*3-1 downto 8+64*3)<=WriteData( 15 downto 8);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;    
                    end if;
                    if (WriteEnSel(2)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 23 downto 16 )<=WriteData( 23 downto 16);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 24+64-1 downto 16+64 )<=WriteData( 23 downto 16);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 24+64*2-1 downto 16+64*2 )<=WriteData( 23 downto 16);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 24+64*3-1 downto 16+64*3 )<=WriteData( 23 downto 16);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');

                        end case;
                    end if;
                    if (WriteEnSel(3)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 31 downto 24 )<=WriteData( 31 downto 24);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 32+64-1 downto   24+64  ) <=WriteData( 31 downto 24);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*2-1 downto 24+64*2 )<=WriteData( 31 downto 24);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*3-1 downto 24+64*3 )<=WriteData( 31 downto 24);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');

                        end case;                                            
                    end if;
                    if (WriteEnSel(4)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 39 downto 32 )<=WriteData( 39 downto 32);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 40+64-1 downto   32+64  ) <=WriteData( 39 downto 32);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 40+64*2-1 downto 32+64*2 )<=WriteData( 39 downto 32);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 40+64*3-1 downto 32+64*3 )<=WriteData( 39 downto 32);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;                      
                    end if;
                    if (WriteEnSel(5)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 47 downto 40 )<=WriteData( 47 downto 40);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 48+64-1 downto   40+64  ) <=WriteData( 47 downto 40);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 48+64*2-1 downto 40+64*2 )<=WriteData( 47 downto 40);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 48+64*3-1 downto 40+64*3 )<=WriteData( 47 downto 40);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;                     
                    end if;
                    if (WriteEnSel(6)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 55 downto 48 )<=WriteData( 55 downto 48);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 56+64-1 downto   48+64  ) <=WriteData( 55 downto 48);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 56+64*2-1 downto 48+64*2 )<=WriteData( 55 downto 48);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 56+64*3-1 downto 48+64*3 )<=WriteData( 55 downto 48);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;                   
                    end if;
                    if (WriteEnSel(7)='1') then
                        case(w_offset_int) is
                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 63 downto 56 )<=WriteData( 63 downto 56);
                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 64+64-1 downto   56+64  ) <=WriteData( 63 downto 56);
                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*2-1 downto 56+64*2 )<=WriteData( 63 downto 56);
                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*3-1 downto 56+64*3 )<=WriteData( 63 downto 56);
                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
                        end case;                      
                    end if;             
                    --when 16=>
--                    if (WriteEnSel(0)='1') then
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 15 downto 0 )<=WriteData( 15 downto 0);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 16+64-1 downto   64  ) <=WriteData( 15 downto 0);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 16+64*2-1 downto 64*2 )<=WriteData( 15 downto 0);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 16+64*3-1 downto 64*3 )<=WriteData( 15 downto 0);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;  
--                    end if;
--                    if (WriteEnSel(2)='1') then
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 31 downto 16 )<=WriteData( 31 downto 16);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 32+64-1 downto   16+64  ) <=WriteData( 31 downto 16);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*2-1 downto 16+64*2 )<=WriteData( 31 downto 16);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*3-1 downto 16+64*3 )<=WriteData( 31 downto 16);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;  
--                    end if;    
--                    if (WriteEnSel(4)='1') then
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 47 downto 32 )<=WriteData( 47 downto 32);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 48+64-1 downto   32+64  ) <=WriteData( 47 downto 32);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 48+64*2-1 downto 32+64*2 )<=WriteData( 47 downto 32);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 48+64*3-1 downto 32+64*3 )<=WriteData( 47 downto 32);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;  
--                    end if;    
--                    if (WriteEnSel(6)='1') then   
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 63 downto 48 )<=WriteData( 63 downto 48);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 64+64-1 downto   48+64  ) <=WriteData( 63 downto 48);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*2-1 downto 48+64*2 )<=WriteData( 63 downto 48);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*3-1 downto 48+64*3 )<=WriteData( 63 downto 48);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;   
--                    end if;                                     
--                    --when 32=>
--                    if (WriteEnSel(0)='1') then
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 31 downto 0 )<=WriteData( 31 downto 0);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 32+64-1 downto   64  ) <=WriteData( 31 downto 0);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*2-1 downto 64*2 )<=WriteData( 31 downto 0);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 32+64*3-1 downto 64*3 )<=WriteData( 31 downto 0);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;  
--                    end if;  
--                    if (WriteEnSel(3)='1') then
--                         case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 63 downto 32 )<=WriteData( 63 downto 32);
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 64+64-1 downto   32+64  ) <=WriteData( 63 downto 32);
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*2-1 downto 32+64*2 )<=WriteData( 63 downto 32);
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*3-1 downto 32+64*3 )<=WriteData( 63 downto 32);
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case; 
--                    end if; 
--                    when 64=>
--                    if (WriteEnSel(0)='1') then
--                        case(w_offset_int) is
--                            when 0 =>     registers(to_integer(unsigned(WriteDest)))( 63 downto 0 )<=WriteData;
--                            when 1 =>     registers(to_integer(unsigned(WriteDest)))( 64+64-1 downto   64  ) <=WriteData;
--                            when 2 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*2-1 downto 64*2 )<=WriteData;
--                            when 3 =>     registers(to_integer(unsigned(WriteDest)))( 64+64*3-1 downto 64*3 )<=WriteData;
--                            when others=> registers(to_integer(unsigned(WriteDest)))<= (others=>'0');
--                        end case;                                         
--                    end if;
--                    when others=>
--                        registers(to_integer(unsigned(WriteDest)))<=(others=>'0'); 
--               end case;                                           
            end if; 
        end if;                                              
    end process;
    
process(r_offset_int)
begin

                case(r_offset_int) is
                when 0=>
                    out1 <= registers(to_integer(unsigned(RegSel1)))(63 downto 0);
                    out2 <= registers(to_integer(unsigned(RegSel2)))(63 downto 0);
                when 1=>
                    out1 <= registers(to_integer(unsigned(RegSel1)))(64+64-1 downto 64);
                    out2 <= registers(to_integer(unsigned(RegSel2)))(64+64-1 downto 64);
                when 2=>
                    out1 <= registers(to_integer(unsigned(RegSel1)))(64+64*2-1 downto 64*2);
                    out2 <= registers(to_integer(unsigned(RegSel2)))(64+64*2-1 downto 64*2);
                when 3=>
                    out1 <= registers(to_integer(unsigned(RegSel1)))(64+64*3-1 downto 64*3);
                    out2 <= registers(to_integer(unsigned(RegSel2)))(64+64*3-1 downto 64*3);
                when others=>
                    out1 <= (others=>'0');
                    out2 <= (others=>'0');         
            end case;  

end process;
end Bank1_arch;
