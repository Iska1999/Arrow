library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU_lane_tb is
end ALU_lane_tb;

architecture ALU_lane_tb_arch of ALU_lane_tb is

component ALU_lane is
    Port (  
            operand1: in STD_LOGIC_VECTOR(63 downto 0);
            operand2: in STD_LOGIC_VECTOR(63 downto 0);
            funct6: in STD_LOGIC_VECTOR (5 downto 0); --to know which operation
            funct3: in STD_LOGIC_VECTOR (2 downto 0); 
            sew: in STD_LOGIC_VECTOR(2 downto 0);
            result: out STD_LOGIC_VECTOR(63 downto 0) 
            );
end component;

--constant ELEN: integer:=32; --max element width in bits
--constant lgSEW_MAX: integer:=5;

signal operand1: STD_LOGIC_VECTOR(63 downto 0);
signal operand2: STD_LOGIC_VECTOR(63 downto 0);
signal funct6: STD_LOGIC_VECTOR (5 downto 0); --to know which operation
signal funct3:STD_LOGIC_VECTOR(2 downto 0);
signal sew: STD_LOGIC_VECTOR(2 downto 0);
signal result: STD_LOGIC_VECTOR(63 downto 0);

begin
    UUT: ALU_lane --generic map(ELEN,lgSEW_MAX)
    port map(
            operand1=>operand1 , 
            operand2=>operand2 , 
            funct6  =>funct6   , 
            funct3  =>funct3   , 
            sew => sew         ,
            result  =>result
            
            );
    
--    clk_proc: process begin
--        clk<='1';
--        wait for 5ns;
--        clk<='0'; 
--        wait for 5ns;
--    end process;
    
    process begin
-------------------------------------------------------------------------------------------------------------------------------------

        -- testing add with 8 bit elements  
        -- Expected result: 0c0b0a0908070605
        operand1<= x"0202020202020202"; operand2 <= x"0a09080706050403"; funct6 <= "000000";funct3<="000"; sew<="000";wait for 10ns; 

        -- testing add with 16 bit elements  
        -- Expected result: 0008000700060005
        operand1<= x"0002000200020002"; operand2 <= x"0006000500040003"; funct6 <= "000000";funct3<="000"; sew<="001";wait for 10ns;  
        
        -- testing add with 32 bit elements  
        -- Expected result: 0000000600000005
        operand1<= x"0000000200000002"; operand2 <= x"0000000400000003"; funct6 <= "000000";funct3<="000"; sew<="010";wait for 10ns; 
        
        -- testing add with 64 bit elements  
        -- Expected result: 0000000000000005
        operand1<= x"0000000000000002"; operand2 <= x"0000000000000003"; funct6 <= "000000";funct3<="000"; sew<="011";wait for 10ns;   

-------------------------------------------------------------------------------------------------------------------------------------

        -- testing signed subtract with 8 bit elements  
        -- Expected result: 0807060504030201
        operand1<= x"0202020202020202"; operand2 <= x"0a09080706050403"; funct6 <= "000010";funct3<="000"; sew<="000";wait for 10ns; 
        
        -- testing signed subtract with 64 bit elements  
        -- Expected result: 0000000000000003
        operand1<= x"0000000000000003"; operand2 <= x"0000000000000006"; funct6 <= "000010";funct3<="000"; sew<="011";wait for 10ns;        

-------------------------------------------------------------------------------------------------------------------------------------

       -- testing unsigned min with 8 bit elements  
        -- Expected result: 0202020202020202
        operand1<= x"0202020202020202"; operand2 <= x"0a09080706050403"; funct6 <= "000100";funct3<="000"; sew<="000";wait for 10ns; 

-------------------------------------------------------------------------------------------------------------------------------------


--        operand1<=x"FFFFFFFE"; operand2<= x"FFFFFFFD"; wait for 10ns; --testing add with negative numbers
--        funct6<= "000011"; operand1<=x"FFFFFFFE"; operand2<= x"FFFFFFFD"; wait for 10ns; --signed reverse subtract
--        funct6<= "000100"; operand1<=x"00000005"; operand2<= x"00000008"; wait for 10ns; --unsigned min
--        funct6<= "000101"; operand1<=x"FFFFFFFE"; operand2<= x"FFFFFFFD"; wait for 10ns; --signed min
--        funct6<= "000110"; operand1<=x"00000005"; operand2<= x"00000008"; wait for 10ns; --unsigned max
--        funct6<= "000111"; operand1<=x"FFFFFFFE"; operand2<= x"FFFFFFFD"; wait for 10ns; --signed max
--        funct6<= "001001"; operand1<=x"000000AF"; operand2<= x"00000084"; wait for 10ns; --and
        
--        funct6<= "011000"; operand1<=x"000000AF"; operand2<= x"000000AF"; wait for 10ns; --seq
         
--        funct6<= "100101"; operand1<=x"00000002"; operand2<= x"00000001"; wait for 10ns; --sll        
--        funct6<= "101000"; operand1<=x"FFFFFFFE"; operand2<= x"00000004"; wait for 10ns; --srl          
--        funct6<= "101001"; operand1<=x"FFFFFFFE"; operand2<= x"00000004"; wait for 10ns; --sra  
               
--        funct3<="010";funct6<= "100000"; operand1<=x"00000004"; operand2<= x"00000002"; wait for 10ns; --divu         
--        funct6<= "100001"; operand1<=x"FFFFFFFC"; operand2<= x"FFFFFFFE"; wait for 10ns; --vdiv  
--        funct6<= "100010"; operand1<=x"00000003"; operand2<= x"00000002"; wait for 10ns; --remu   
--        funct6<= "100011"; operand1<=x"FFFFFFFD"; operand2<= x"FFFFFFFE"; wait for 10ns; --rem   
--        funct6<= "100100"; operand1<=x"00000002"; operand2<= x"00000001"; wait for 10ns; --mulhu  
--        funct6<= "100101"; operand1<=x"FFFFFFFD"; operand2<= x"00000001"; wait for 10ns; --mul  
--        funct6<= "100111"; operand1<=x"FFFFFFFD"; operand2<= x"00000001"; wait for 10ns; --mulh                                
        wait; 
    end process;

end ALU_lane_tb_arch;
