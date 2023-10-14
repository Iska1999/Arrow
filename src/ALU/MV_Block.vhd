library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity MV_Block is
    Port (  vs1_data: in STD_LOGIC_VECTOR(63 downto 0); -- data from VS1 vector register
            vs2_data: in STD_LOGIC_VECTOR(63 downto 0); -- data from VS2 vector register
            mask_reg: in STD_LOGIC_VECTOR(VLEN-1 downto 0); --mask register
            vm: in STD_LOGIC;
            data_out: out STD_LOGIC_VECTOR(ELEN-1 downto 0)
     );
end MV_Block;

architecture Behavioral of MV_Block is

begin
    process (vs1_data,vs2_data,mask_reg,vm)
    begin
        if(vm='0') then
--            if (mask_in = '1') then -- decide on which data to write based on mask bit
--                data_out<=vs1_data; -- write vs1 data if mask bit is 1
--            else
--                data_out<=vs2_data; -- write vs2 data if mask bit is 0
--            end if;
        else
            data_out<= vs1_data;
        end if;
    end process;

end Behavioral;