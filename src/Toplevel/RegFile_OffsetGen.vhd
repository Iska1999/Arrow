library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile_OffsetGen is
    Port (
            i_clk : in std_logic;
            i_rst: in std_logic;
            newInst: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
            sew: in std_logic_vector (3*NB_LANES-1 downto 0);
            vm: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
            vstart: in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
            vlmul: in STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);             
            o_done : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0); 
            mask_bit: out STD_LOGIC;
            OutPort: out STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*64)-1 downto 0);
            RegSel: in STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
            WriteEn : in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
            WriteEnSel_in: in STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
            WriteEnSel_out: out STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
            WriteData : in STD_LOGIC_VECTOR (NB_LANES*64-1 downto 0);
            WriteDest : in STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
            w_offset_in : in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);--offset coming from the pipeline
            w_offset_out : out STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); --offset going to pipeline
            vl: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
            reg_out_1: out STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
            reg_out_2: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software   
  );
end RegFile_OffsetGen;

architecture Behavioral of RegFile_OffsetGen is

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

component RegisterFile is
    Port ( clk : in STD_LOGIC;
           mask_bit: out STD_LOGIC;
           OutPort: out STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*64)-1 downto 0);
           RegSel: in STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
           WriteEn : in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
           WriteData : in STD_LOGIC_VECTOR (NB_LANES*64-1 downto 0);
           WriteDest : in STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
           sew: in STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
           vlmul: in STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);
           vl: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
           vstart: in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
           r_offset : in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); 
           w_offset : in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); 
           WriteEnSel: in STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
           mask_reg: out STD_LOGIC_VECTOR(VLEN-1 downto 0);
           reg_out_1: out STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
           reg_out_2: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software                        
           );
end component;

signal r_offset_sig: STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
--signal w_offset_sig: STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
signal mask_reg_sig: STD_LOGIC_VECTOR(VLEN-1 downto 0);
signal WriteEnSel_sig: STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
begin
RegFile: RegisterFile 
                      PORT MAP(
                      clk=>i_clk,
                      mask_bit=>mask_bit,
                      OutPort=>OutPort,
                      RegSel=>RegSel,
                      WriteEn=>WriteEn,
                      WriteData=>WriteData,
                      WriteDest=>WriteDest,
                      sew=>sew,
                      vlmul=>vlmul,
                      vl=>vl,
                      vstart=>vstart,
                      r_offset=>r_offset_sig,
                      w_offset=>w_offset_in,
                      WriteEnSel=>WriteEnSel_in,
                      mask_reg=>mask_reg_sig,
                      reg_out_1=>reg_out_1,
                      reg_out_2=>reg_out_2
                      );


OffsetGen_GEN:for i in 0 to NB_LANES-1 generate
    OffsetGens: OffsetGen 
                        PORT MAP(
                        i_clk=>i_clk,
                        i_rst=>i_rst,
                        i_load=>newInst(i),
                        i_mask=>mask_reg_sig,
                        i_vsew=>sew((i+1)*3-1 downto i*3),
                        i_vlmul=>vlmul((i+1)*3-1 downto i*3),
                        i_vl=>vl((i+1)*XLEN-1 downto i*XLEN),
                        i_vstart=>vstart((i+1)*lgVLEN-1 downto i*lgVLEN),
                        i_vm=>vm(i),
                        o_offset=>r_offset_sig((i+1)*lgVLEN-1 downto i*lgVLEN),
                        WriteEnSel=>WriteEnSel_sig(8*(i+1)-1 downto 8*i),
                        o_done=>o_done(i));                 
end generate OffsetGen_GEN;

w_offset_out<=r_offset_sig; --offset going to pipeline takes the same value as the read offset
WriteEnSel_out<=WriteEnSel_sig;
end Behavioral;
