library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity MemGen_tb is
--  Port ( );
end MemGen_tb;

architecture Behavioral of MemGen_tb is
component MemGen is
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
end component;

signal i_clk :        std_logic;
signal i_rst:         std_logic;
signal i_load :       std_logic; -- should be asserted for one clock cycle aka newInst
signal i_mask :       std_logic_vector (VLEN-1 downto 0);
signal i_memwidth :   std_logic_vector (2 downto 0); -- vtype CSR [4:2]
signal i_mew:         std_logic;
signal i_vlmul :      std_logic_vector (2 downto 0); -- vtype CSR [5,1:0]
signal i_vl :         std_logic_vector (XLEN-1 downto 0); -- number of vector elements to be processed.
signal i_vstart:      std_logic_vector (lgVLEN-1 downto 0); -- vstart CSR [log2VLEN-1:0]
signal i_vm:          STD_LOGIC; -- vector instruction vm mask field (inst[25]). Masking disabled = 1. Masking enabled = 0.
signal i_mop:         STD_LOGIC_VECTOR(1 downto 0);      -- 00 : unit stride for both load and store                                              
signal i_rs1_data:    STD_LOGIC_VECTOR(XLEN-1 downto 0); -- contains base effective address
signal i_rs2_data:    STD_LOGIC_VECTOR(XLEN-1 downto 0); -- contains stride offset incase of strided operation
signal i_vs2_data:    STD_LOGIC_VECTOR(63 downto 0); --   
signal i_lumop:       STD_LOGIC_VECTOR(4 downto 0); --additional addressing field
signal i_sumop:       STD_LOGIC_VECTOR(4 downto 0);  --additional addressing field
signal o_mem_address: STD_LOGIC_VECTOR(XLEN-1 downto 0);
signal o_offset :     std_logic_vector (lgVLEN-1 downto 0); -- index of next vector element to be processed.
signal WriteEnMemSel: std_logic_vector(7 downto 0); --WriteEnable Select going to the registerfile in case it is a masked load
signal o_done :       std_logic;

begin


    UUT:MemGen PORT MAP (
       i_clk        =>i_clk        ,
       i_rst        =>i_rst        ,
       i_load       =>i_load       ,
       i_mask       =>i_mask       ,
       i_memwidth   =>i_memwidth   ,
       i_mew        =>i_mew        ,
       i_vlmul      =>i_vlmul      ,
       i_vl         =>i_vl         ,
       i_vstart     =>i_vstart     ,
       i_vm         =>i_vm         ,
       i_mop        =>i_mop        ,
       i_rs1_data   =>i_rs1_data   ,
       i_rs2_data   =>i_rs2_data   ,
       i_vs2_data   =>i_vs2_data   ,
       i_lumop      =>i_lumop      ,
       i_sumop      =>i_sumop      ,
       o_mem_address=>o_mem_address,
       o_offset     =>o_offset     ,
       WriteEnMemSel=>WriteEnMemSel,
       o_done       =>o_done          
    );
    clk_proc: process begin
        i_clk<='0';
        wait for 5ns;
        i_clk<='1'; 
        wait for 5ns;
    end process;
    
    process begin
        i_load<='0';
        wait for 15ns;
        
        -- Vector strided operation of offset 2 and memwidth 32, expected result: 
        -- Cycle 1: 11001111
        -- Cycle 2: 11110011
        -- Cycle 3: 00111100

        i_memwidth<="010"; i_mew<='0';
        i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
        i_vstart<="00000000";i_vlmul<="000";i_vl<=x"00000004";  
        i_mop<="10";i_rs1_data<=x"00000000"; 
        i_rs2_data(XLEN-1 downto 3)<=(others=>'0');
        i_rs2_data(2 downto 0)<="010";
        wait for 10ns;
        
        i_load<='1';
        wait for 5 ns;
        i_load<='0';
        wait for 5 ns;
        
        wait for 50ns;
        -- Vector strided operation of offset 3 and memwidth 16, expected result: 
        -- Cycle 1: 01100011
        -- Cycle 2: 10001100
        -- Cycle 3: 00110001
        -- Cycle 4: 11000110
        -- Cycle 5: 00011000
        i_memwidth<="001"; i_mew<='0';
        i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
        i_vstart<="00000000";i_vlmul<="000";i_vl<=x"00000008";  
        i_mop<="10";i_rs1_data<=x"00000000"; 
        i_rs2_data(XLEN-1 downto 3)<=(others=>'0');
        i_rs2_data(2 downto 0)<="011";
        wait for 10ns;
        
        i_load<='1';
        wait for 5 ns;
        i_load<='0';
        wait for 5 ns;
        
        wait for 50ns;
        -- Masked Vector strided operation of offset 3 and memwidth 16, expected result: 
        -- Cycle 1: 00000000
        -- Cycle 2: 00000000
        -- Cycle 3: 00110000
        -- Cycle 4: 00000000
        -- Cycle 5: 00000000
        -- Cycle 6: 01100011
        i_memwidth<="001"; i_mew<='0';
        i_vm<='0';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
        i_vstart<="00000000";i_vlmul<="000";i_vl<=x"00000003";  
        i_mop<="10";i_rs1_data<=x"00000000"; 
        i_rs2_data(XLEN-1 downto 3)<=(others=>'0');
        i_rs2_data(2 downto 0)<="011";
        wait for 10ns;
        
        i_load<='1';
        wait for 5 ns;
        i_load<='0';
        wait for 5 ns;

        wait for 50ns;
        -- Vector indexed operation of memwidth 16, expected result: 
        -- Cycle 1: 10011011
        -- Cycle 2: 10001101
        -- Cycle 3: 11001101
        -- Cycle 4: 10011000
        -- Cycle 5: 00000011
               
        i_memwidth<="001"; i_mew<='0';
        i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
        i_vstart<="00000000";i_vlmul<="000";i_vl<=x"00000008";  
        i_mop<="11";i_rs1_data<=x"00000000";i_vs2_data<=x"0004000300020001"; 
        i_rs2_data(XLEN-1 downto 3)<=(others=>'0');
        i_rs2_data(2 downto 0)<="011";
        wait for 10ns;
        
        i_load<='1';
        wait for 5 ns;
        i_load<='0';
        wait for 5 ns;                        
        wait;
    end process;

end Behavioral;
