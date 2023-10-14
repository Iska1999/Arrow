library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ShiftRegister is
  Port (
    clk:in STD_LOGIC;
    rst: in STD_LOGIC;
    i_WriteEn: in STD_LOGIC;
    i_offset: in STD_LOGIC_VECTOR(lgVLEN-1 downto 0); 
    o_WriteEn: out STD_LOGIC;
    o_offset: out STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
    i_WriteEnMemSel: in STD_LOGIC_VECTOR(7 downto 0);
    o_WriteEnMemSel: out STD_LOGIC_VECTOR(7 downto 0)
   );
end ShiftRegister;

architecture Behavioral of ShiftRegister is

-- For testing purposes we will use 4 delay cycles
-- The widths of the shift registers are for testing purposes as well
signal WriteEn_sr:STD_LOGIC_VECTOR (3 downto 0); 
signal offset_sr: STD_LOGIC_VECTOR (4*lgVLEN-1 downto 0);
signal WriteEnMemSel_sr: STD_LOGIC_VECTOR (4*8-1 downto 0);
signal i: integer:=1; -- This will later be the value of the formula applied
begin
 
  process(clk)
  begin
    if rst='0' then
        WriteEn_sr<=(others=>'0');
        offset_sr<=(others=>'0');
    
    elsif rising_edge(clk) then
       
      WriteEn_sr <= std_logic_vector(shift_left(unsigned(WriteEn_sr),i*1));      
      WriteEn_sr(0) <= i_WriteEn;
      o_WriteEn <= WriteEn_sr(3);
      
      offset_sr <= std_logic_vector(shift_left(unsigned(offset_sr),i*lgVLEN));
      offset_sr(lgVLEN-1 downto 0) <= i_offset;
      o_offset <= offset_sr(4*lgVLEN-1 downto 3*lgVLEN);
      
      WriteEnMemSel_sr <= std_logic_vector(shift_left(unsigned(WriteEnMemSel_sr),i*1));
      WriteEnMemSel_sr(7 downto 0) <= i_WriteEnMemSel;
      o_WriteEnMemSel <= WriteEnMemSel_sr(4*8-1 downto 3*8);
    end if;
  end process;

end Behavioral;
