library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity OffsetGen_tb is
--  Port ( );
end OffsetGen_tb;

architecture Structural of OffsetGen_tb is

component OffsetGen is
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
end component;

signal    i_clk : std_logic;
signal    i_rst: std_logic;
signal    i_load : std_logic; -- should be asserted for one clock cycle.
signal    i_mask : std_logic_vector (VLEN-1 downto 0);
signal    i_vsew :  std_logic_vector (2 downto 0); -- vtype CSR [4:2]
signal    i_vlmul :  std_logic_vector (2 downto 0); -- vtype CSR [5,1:0]
signal    i_vl : std_logic_vector (XLEN-1 downto 0); -- number of vector elements to be processed.
signal    i_vstart: std_logic_vector (lgVLEN-1 downto 0); -- vstart CSR [log2VLEN-1:0]
signal    i_vm: STD_LOGIC; -- vector instruction vm mask field (inst[25]). Masking disabled = 1. Masking enabled = 0.
signal    o_offset : std_logic_vector (lgVLEN-1 downto 0); -- index of next vector element to be processed.
signal    WriteEnSel: std_logic_vector (7 downto 0);
signal    o_done : std_logic;


begin
UUT: OffsetGen 
              port map(
                i_clk=>i_clk,
                i_rst=>i_rst,
                i_load=>i_load,
                i_mask=>i_mask,
                i_vsew=>i_vsew,
                i_vlmul=>i_vlmul,
                i_vl=>i_vl,
                i_vstart=>i_vstart,
                i_vm=>i_vm,
                o_offset=>o_offset,
                WriteEnSel=>WriteEnSel,
                o_done=>o_done);
                
    clk_proc: process begin
        i_clk<='0';
        wait for 5ns;
        i_clk<='1'; 
        wait for 5ns;
    end process;    
              
    testing: process begin
--    i_vsew<=(others=>'0');
--    i_vm<='1';i_mask<=(others=>'0'); 
--    i_vstart<=(others=>'0');i_vlmul<=(others=>'0');i_vl<=(others=>'0');
    
    -- Testing for unmasked instruction, where sew is 64 bits and vl is 32 (256/8)
    -- Expected result: Offsets are 0,1,2,3 and WriteEnSel is 00000001 on all offsets
    i_load<='0';
    --wait for 15ns;
    wait for 10ns;  
    i_vsew<="000";
    i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
    i_vstart<="00000000";i_vlmul<="000";i_vl<=x"00000007";  
     
        
    wait for 5ns;    
    i_load<='1'; wait for 5ns; i_load<='0';
  
  
    wait for 20 ns;
    -- Testing for unmasked instruction, where sew is 64 bits and vl is 32 (256/8)
    -- Expected result: Offsets are 0,1,2,3 and WriteEnSel is 00000001 on all offsets
    i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
    i_vsew<="011";i_vlmul<="000";i_vl<=x"00000004";i_vstart<="00000000";
         
    wait for 5 ns; 
    i_load<='1'; wait for 5ns; i_load<='0';  
    
--    wait for 30 ns;
--    -- Testing for unmasked instruction, where sew is 32 bits 
--    -- Expected result: Offsets are 0,1,2  and WriteEnSel is 00010001, 00010001, 00000001 
--    i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
--    i_vsew<="010";i_vlmul<="000";i_vl<=x"00000005";i_vstart<="00000000";
         
--    wait for 5 ns; i_load<='1'; wait for 5ns; i_load<='0'; 
    
--     wait for 20 ns;
--    -- Testing for unmasked instruction, where sew is 8 bits and vl is 32 (256/8)
--    -- Expected result: Offsets are 0  and WriteEnSel is 11110000, 00001111
--    i_vm<='1';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10"; 
--    i_vsew<="000";i_vlmul<="000";i_vl<=x"00000008";i_vstart<="00000100";
         
--    wait for 5 ns; i_load<='1'; wait for 5ns; i_load<='0';    
    
    
--    wait for 20 ns;
--    -- Testing for masked instruction, where sew is 8 bits and vl is 32 (256/8)
--    -- Expected result: Offsets are 0,1,2,3  and WriteEnSel is 11111110, 11111010, 11111101, 11110000
--    i_vm<='0';i_mask<=x"ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10ABCDEF10F0FDFAFE"; 
--    i_vsew<="000";i_vlmul<="000";i_vl<=x"00000020";i_vstart<="00000000";
         
--    wait for 5 ns; i_load<='1'; wait for 5ns; i_load<='0';  
    wait;
    end process;              

end Structural;
