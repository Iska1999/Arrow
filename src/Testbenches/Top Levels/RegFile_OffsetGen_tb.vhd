library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile_OffsetGen_tb is
--  Port ( );
end RegFile_OffsetGen_tb;

architecture Behavioral of RegFile_OffsetGen_tb is
component RegFile_OffsetGen is
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
end component;

signal  i_clk :  std_logic;
signal  i_rst:  std_logic;
signal  newInst:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  sew:  std_logic_vector (3*NB_LANES-1 downto 0);
signal  vm:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  vstart:  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
signal  vlmul:  STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);             
signal  o_done :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0); 
signal  mask_bit:  STD_LOGIC;
signal  OutPort:  STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*64)-1 downto 0);
signal  RegSel:  STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
signal  WriteEn :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  WriteEnSel_in: STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
signal  WriteEnSel_out: STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
signal  WriteData :  STD_LOGIC_VECTOR (NB_LANES*64-1 downto 0);
signal  WriteDest_in :  STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
signal  WriteDest :  STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
signal  WriteDest_pip :  STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
signal  w_offset_in :  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);--offset coming from the pipeline
signal  w_offset_out :  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); --offset going to pipeline
signal  vl:  STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
signal  reg_out_1:  STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
signal  reg_out_2:  STD_LOGIC_VECTOR(VLEN-1 downto 0);


signal  WriteEn_in :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  WriteEn_pip :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);

signal  WriteData_in :  STD_LOGIC_VECTOR (NB_LANES*64-1 downto 0);
signal  WriteData_pip :  STD_LOGIC_VECTOR (NB_LANES*64-1 downto 0);
begin

UUT: RegFile_OffsetGen 
                        PORT MAP (
                        i_clk       =>i_clk           ,
                        i_rst       =>i_rst           ,
                        newInst     =>newInst         ,
                        sew         =>sew             ,
                        vm          =>vm              ,
                        vstart      =>vstart          ,
                        vlmul       =>vlmul           ,
                        o_done      =>o_done          ,
                        mask_bit    =>mask_bit        ,
                        OutPort     =>OutPort         ,
                        RegSel      =>RegSel          ,
                        WriteEn     =>WriteEn         ,
                        WriteEnSel_in=>WriteEnSel_in  ,
                        WriteEnSel_out=>WriteEnSel_out,
                        WriteData   =>WriteData       ,
                        WriteDest   =>WriteDest       ,
                        w_offset_in =>w_offset_in     ,
                        w_offset_out=>w_offset_out    ,
                        vl          =>vl              ,
                        reg_out_1   =>reg_out_1       ,
                        reg_out_2   =>reg_out_2    

                        );
    clk_proc: process begin
        i_clk<='0';
        wait for 5ns;
        i_clk<='1'; 
        wait for 5ns;
        end process;
        
        process begin
        
        WriteData_in<=(others=>'0');
        i_rst<='1'; wait for 5 ns;
        i_rst<='0'; wait for 5 ns;
        i_rst<='1'; 

        wait for 5ns;
--      Writing to v0 with sew=64 bits
--      Expected result: V1: x0a0908070605040302020202020202020a090807060504030202020202020202 
        RegSel<="0001000000010000";WriteDest_in<="00000000";  
        sew <= "000011"; 
        vl <= x"0000000400000004"; 
        vstart <= "0000000000000000"; 
        vlmul<="000000";
        vm<="11";        
        
              
        wait for 10ns;        
        newInst<="01"; 
        WriteEn_in<="01";       
        WriteData_in<=x"00000000000000040a09080706050403";       
        wait for 10ns; 
        newInst<="00"; 
        WriteData_in<=x"00000000000000040202020202020202"; 
        wait for 10ns;
        WriteData_in<=x"00000000000000040a09080706050403";
        wait for 10ns;
        WriteData_in<=x"00000000000000040202020202020202";
        wait for 10ns;
        
        WriteEn_in<="00";    
        
        wait;
        end process;
       
       --Only for testbenching purposes
       process(i_clk) begin
       
       if rising_edge(i_clk) then
--        w_offset_pipeline<=w_offset_out;
--        w_offset_in<=w_offset_pipeline;
        w_offset_in<=w_offset_out;
        WriteEnSel_in<=WriteEnSel_out;
        WriteEn_pip<=WriteEn_in;
        WriteEn<=WriteEn_pip;
        WriteData_pip<=WriteData_in;
        WriteData<=WriteData_pip;
        WriteDest_pip<=WriteDest_in;
        WriteDest<=WriteDest_pip;
       end if;
       end process;
--        w_offset_in<=w_offset_out;
--        WriteEnSel_in<=WriteEnSel_out;
--        WriteEn<=WriteEn_in;
        --WriteData<=WriteData_in;
 
end Behavioral;
