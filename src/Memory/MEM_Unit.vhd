
-------------------------------------------------------------------
-------------------------------------------------------------------
-- THIS UNIT IS FOR TESTING PURPOSES ONLY, IT INCLUDES MEM BANKS --
-------------------------------------------------------------------
-------------------------------------------------------------------
library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MEM_Unit is
  Port (
    clk: in STD_LOGIC;
    rst: in STD_LOGIC;
    newInst: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    mask_reg : in std_logic_vector (NB_LANES*VLEN-1 downto 0);
    extension: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    vm: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0); --indicates if masked operation or not
    mop: in STD_LOGIC_VECTOR(NB_LANES*2-1 downto 0); -- 00 if unit stride    
                                               -- 01 if strided
                                               -- 10 if indexed (unordered in case of a store)
                                               -- 11 if indexed (ordered in case of a store)   
    memwidth: in STD_LOGIC_VECTOR(NB_LANES*3-1 downto 0); 
    mew: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0); -- used for width encoding
    vlmul : in std_logic_vector (NB_LANES*3-1  downto 0); -- vtype CSR [5,1:0]
    vl: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); -- used for counter  
    vstart: in std_logic_vector (NB_LANES*lgVLEN-1 downto 0); -- vstart CSR [log2VLEN-1:0]                                    
    rs1_data: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); -- contains base effective address 
    rs2_data: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); -- contains stride offset incase of strided operation 
    vs2_data: in STD_LOGIC_VECTOR(NB_LANES*64-1 downto 0); -- contains stride offset incase of indexed operation       
    lumop: in STD_LOGIC_VECTOR(NB_LANES*5-1 downto 0); --additional addressing field
    sumop: in STD_LOGIC_VECTOR(NB_LANES*5-1 downto 0); --additional addressing field
    MemRead: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0); -- coming from controller 
    MemWrite: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0); -- coming from controller 
    WritePort: in STD_LOGIC_VECTOR(NB_LANES*64-1 downto 0);
    ReadPort: out STD_LOGIC_VECTOR(NB_LANES*64-1 downto 0); -- ELEN since worst case is having to transfer ELEN bits  
    offset : out STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); -- index of next vector element to be processed.
    done : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0)
    );
end MEM_Unit;

architecture Behavioral of MEM_Unit is

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

component MEM_Bank is

  Port ( clk: in STD_LOGIC;
         MemRead: in STD_LOGIC; -- coming from controller
         MemWrite: in STD_LOGIC; -- coming from controller
         MemAddr: in STD_LOGIC_VECTOR(9 downto 0);
         ReadPort: out STD_LOGIC_VECTOR(63 downto 0);
         WritePort: in STD_LOGIC_VECTOR(63 downto 0);
         WriteEnMemSel: in STD_LOGIC_VECTOR(7 downto 0);
         extension: in STD_LOGIC
                 
         );
end component;


signal s_mem_address: STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); -- output from mem lanes
signal s_offset: STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); --output from MemGen
signal s_WriteEnMemSel: STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
begin

    
    MemGen_GEN:for i in 0 to NB_LANES-1 generate
        MemGens: MemGen PORT MAP(
                            i_clk=>clk,
                            i_rst=>rst,
                            i_load=>newInst(i),
                            i_mask=>mask_reg(VLEN*(i+1)-1 downto VLEN*i),
                            i_memwidth=>memwidth((i+1)*3-1 downto i*3),
                            i_mew=>mew(i),
                            i_vlmul=>vlmul((i+1)*3-1 downto i*3),
                            i_vl=>vl((i+1)*XLEN-1 downto i*XLEN),
                            i_vstart=>vstart((i+1)*lgVLEN-1 downto i*lgVLEN),
                            i_vm=>vm(i),
                            i_mop=>mop(2*(i+1)-1 downto 2*i),
                            i_rs1_data=>rs1_data(XLEN*(i+1)-1 downto XLEN*i),
                            i_rs2_data=>rs2_data(XLEN*(i+1)-1 downto XLEN*i),
                            i_vs2_data=>vs2_data(64*(i+1)-1 downto 64*i),
                            i_lumop=>lumop(5*(i+1)-1 downto 5*i),
                            i_sumop=>sumop(5*(i+1)-1 downto 5*i),
                            o_mem_address=>s_mem_address((i+1)*XLEN-1 downto i*XLEN),
                            o_offset=>s_offset((i+1)*lgVLEN-1 downto i*lgVLEN),
                            WriteEnMemSel=>s_WriteEnMemSel((i+1)*8-1 downto i*8),
                            o_done=>done(i)
                            );
    end generate MemGen_GEN;
                            
    BANK_GEN:for i in 0 to NB_LANES-1 generate
        Banks: MEM_Bank PORT MAP (
                        clk=>clk,
                        MemRead=>MemRead(i),
                        MemWrite=>MemWrite(i),
                        MemAddr=>s_mem_address(i*XLEN+10-1 downto i*XLEN),--We just want the first 10 bits of each XLEN chunk
                        ReadPort=>ReadPort(ELEN*(i+1)-1 downto ELEN*i),
                        WritePort=>WritePort(ELEN*(i+1)-1 downto ELEN*i),
                        WriteEnMemSel=>s_WriteEnMemSel((i+1)*8-1 downto i*8),
                        extension=>extension(i)
                        );
    end generate BANK_GEN;
     
     
                                                       
end Behavioral;