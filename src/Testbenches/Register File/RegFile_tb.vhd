library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile_tb is
--  Port ( );
end RegFile_tb;

architecture Behavioral of RegFile_tb is

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

signal  clk : STD_LOGIC;
signal newInst:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  mask_bit:  STD_LOGIC;
signal  OutPort:  STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*ELEN)-1 downto 0);
signal  RegSel:  STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
signal  WriteEn :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  WriteData :  STD_LOGIC_VECTOR (NB_LANES*ELEN-1 downto 0);
signal  WriteDest :  STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
signal  WriteEnSel: STD_LOGIC_VECTOR(NB_LANES*8-1 downto 0);
signal  sew:  STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
signal  vlmul:  STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);
signal  vl:  STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
signal  vstart:  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
signal  r_offset :  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); 
signal  w_offset :  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0); 
signal  mask_reg:  STD_LOGIC_VECTOR(VLEN-1 downto 0);
signal  reg_out_1:  STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
signal  reg_out_2:  STD_LOGIC_VECTOR(VLEN-1 downto 0);

begin

    UUT: RegisterFile 
        PORT MAP(
            clk      =>clk         ,
            mask_bit =>mask_bit    ,
            OutPort  =>OutPort     ,
            RegSel   =>RegSel      ,
            WriteEn  =>WriteEn     ,
            WriteData=>WriteData   ,
            WriteDest=>WriteDest   ,
            sew      =>sew         ,
            vlmul    =>vlmul       ,
            vl       =>vl          ,
            vstart   =>vstart      ,
            r_offset =>r_offset    ,
            w_offset =>w_offset    ,
            WriteEnSel =>WriteEnSel,
            mask_reg =>mask_reg    ,
            reg_out_1=>reg_out_1   ,
            reg_out_2=>reg_out_2 
            );

     clk_proc: process begin
        clk<='0';
        wait for 5ns;
        clk<='1'; 
        wait for 5ns;
    end process;


    process begin
        wait for 5ns;


--      Writing to v0 with sew=64 bits
--      Expected result: V1: x0a0908070605040302020202020202020a090807060504030202020202020202        
        RegSel<="0001000000010000"; 
        WriteDest<="00000000";
        sew<="000011";
        vl <= x"0000000400000004"; 
        vstart <= "0000000000000000";
        vlmul<="000000";        
        WriteEn<="01";
        WriteEnSel<="0000000011111111";
        WriteData<=x"00000000000000040202020202020202";
        r_offset<="0000000000000000";
        w_offset<="0000000000000000";       
        wait for 10ns;
        WriteData<=x"00000000000000040a09080706050403";
        r_offset<="0000000000000001";
        w_offset<="0000000000000001";
        wait for 10ns;
        WriteData<=x"00000000000000040202020202020202";
        r_offset<="0000000000000010";
        w_offset<="0000000000000010";
        wait for 10ns;
        WriteData<=x"00000000000000040a09080706050403";
        r_offset<="0000000000000011";
        w_offset<="0000000000000011";
        wait for 10ns;
        WriteEnSel<=(others=>'0');
        WriteEn<="00";
        

        wait;
    end process;
end Behavioral;
