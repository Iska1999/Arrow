library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_Bank is

  Port ( clk: in STD_LOGIC;
         MemRead: in STD_LOGIC; -- coming from controller
         MemWrite: in STD_LOGIC; -- coming from controller
         MemAddr: in STD_LOGIC_VECTOR(9 downto 0);
         ReadPort: out STD_LOGIC_VECTOR(63 downto 0);
         WritePort: in STD_LOGIC_VECTOR(63 downto 0);
         WriteEnMemSel: in STD_LOGIC_VECTOR(7 downto 0);
         extension: in STD_LOGIC
                 
         );
end MEM_Bank;

architecture Behavioral of MEM_Bank is
   type Mem is array(0 to 15) of std_logic_vector(VLEN-1 downto 0);   
   signal data : Mem;
begin
    process(clk, MemAddr,MemRead,MemWrite,data)
    begin
        if rising_edge(clk) then
            if (MemWrite = '1') then
                    if (WriteEnMemSel(0)='1') then                        
                        data(to_integer(unsigned(MemAddr)))( 7 downto 0 )<=WritePort( 7 downto 0);                        
                    end if;
                    if (WriteEnMemSel(1)='1') then
                        data(to_integer(unsigned(MemAddr)))( 15 downto 8 )<=WritePort( 15 downto 8);   
                    end if;
                    if (WriteEnMemSel(2)='1') then
                        data(to_integer(unsigned(MemAddr)))( 23 downto 16 )<=WritePort( 23 downto 16);
                    end if;
                    if (WriteEnMemSel(3)='1') then
                        data(to_integer(unsigned(MemAddr)))( 31 downto 24 )<=WritePort( 31 downto 24);                                           
                    end if;
                    if (WriteEnMemSel(4)='1') then
                        data(to_integer(unsigned(MemAddr)))( 39 downto 32 )<=WritePort( 39 downto 32);                     
                    end if;
                    if (WriteEnMemSel(5)='1') then
                        data(to_integer(unsigned(MemAddr)))( 47 downto 40 )<=WritePort( 47 downto 40);                    
                    end if;
                    if (WriteEnMemSel(6)='1') then
                        data(to_integer(unsigned(MemAddr)))( 55 downto 48 )<=WritePort( 55 downto 48);                  
                    end if;
                    if (WriteEnMemSel(7)='1') then
                        data(to_integer(unsigned(MemAddr)))( 63 downto 56 )<=WritePort( 63 downto 56);                      
                    end if;
            end if; 
            if (MemRead = '1') then
                if (extension='1') then -- sign extend
                ReadPort<= std_logic_vector(resize( signed((data(to_integer(unsigned(MemAddr))) (63 downto 0)) ), ReadPort'length));
                else -- zero extend
                ReadPort<= std_logic_vector(resize( unsigned((data(to_integer(unsigned(MemAddr))) (63 downto 0)) ), ReadPort'length));                
                end if;       
            end if;
        end if;
    end process;

end Behavioral;
