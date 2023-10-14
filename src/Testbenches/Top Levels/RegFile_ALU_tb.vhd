library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile_ALU_tb is
end RegFile_ALU_tb;

architecture RegFile_ALU_tb_arch of RegFile_ALU_tb is

component RegFile_ALU is
    Port(   clk: in STD_LOGIC; 
            rst: in STD_LOGIC;
            Xdata: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); --data from scalar register
            Idata: in STD_LOGIC_VECTOR(NB_LANES*5-1 downto 0); --data coming from immediate field of size 5 bits
            op1_src: in STD_LOGIC_VECTOR(2*NB_LANES-1 downto 0); -- selects between scalar/vector reg or immediate from operand 2 
                                                -- 00 = vector reg
                                                -- 01 = scalar reg
                                                -- 10 = immediate
                                                -- 11 = RESERVED (unbound)
            funct6: in STD_LOGIC_VECTOR(NB_LANES*6-1 downto 0); --to know which operation
            funct3: in STD_LOGIC_VECTOR (NB_LANES*3-1 downto 0); --to know which operation
            WriteEn_i: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0); --WriteEn from controller
            ------Register File            
            sew: in STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
            vlmul: in STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);
            vm: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);            
            vl: in STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
            vstart: in STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
            newInst: in STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
            RegSel: in STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
            WriteDest : in STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
            o_done : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0); --going to controller
            reg_out_1: out STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
            reg_out_2: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software 
);
end component;

signal  clk:  STD_LOGIC; 
signal  rst:  STD_LOGIC;
signal  Xdata:  STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0); --data from scalar register
signal  Idata:  STD_LOGIC_VECTOR(NB_LANES*5-1 downto 0); --data coming from immediate field of size 5 bits
signal  op1_src:  STD_LOGIC_VECTOR(2*NB_LANES-1 downto 0); -- selects between scalar/vector reg or immediate from operand 2 
signal  funct6:  STD_LOGIC_VECTOR(NB_LANES*6-1 downto 0); --to know which operation
signal  funct3:  STD_LOGIC_VECTOR (NB_LANES*3-1 downto 0); --to know which operation
signal  WriteEn_i:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0); --WriteEn from controller           
signal  sew:  STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
signal  vlmul:  STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);
signal  vm:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);            
signal  vl:  STD_LOGIC_VECTOR(NB_LANES*XLEN-1 downto 0);
signal  vstart:  STD_LOGIC_VECTOR(NB_LANES*lgVLEN-1 downto 0);
signal  newInst:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal  RegSel:  STD_LOGIC_VECTOR((READ_PORTS_PER_LANE*NB_LANES*REGS_PER_BANK)-1 downto 0); 
signal  WriteDest :  STD_LOGIC_VECTOR (NB_LANES*REGS_PER_BANK-1 downto 0);
signal  o_done :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0); --going to controller
signal  reg_out_1:  STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
signal  reg_out_2:  STD_LOGIC_VECTOR(VLEN-1 downto 0); 

begin
    UUT: RegFile_ALU --GENERIC MAP(READ_PORTS_PER_LANE,REG_NUM,REGS_PER_BANK,NB_LANES,VLMAX,ELEN,lgSEW_MAX,XLEN,VLEN)
                    PORT MAP(
                          clk       =>clk       ,
                          rst       =>rst       ,
                          Xdata     =>Xdata     ,
                          Idata     =>Idata     ,
                          op1_src   =>op1_src   ,
                          funct6    =>funct6    ,
                          funct3    =>funct3    ,
                          WriteEn_i =>WriteEn_i ,
                          sew       =>sew       ,
                          vm        =>vm        ,
                          vstart    =>vstart    ,
                          vlmul     =>vlmul     ,
                          vl        =>vl        ,
                          newInst   =>newInst   ,
                          RegSel    =>RegSel    ,
                          WriteDest =>WriteDest ,
                          o_done    =>o_done    ,
                          reg_out_1 =>reg_out_1 ,
                          reg_out_2 =>reg_out_2
                            );
    
    clk_proc: process begin
        clk<='0';
        wait for 5ns;
        clk<='1'; 
        wait for 5ns;
    end process;
    
    process begin
        -- Initial conditions
        newInst<="00";WriteEn_i<="00";
        rst<='1'; wait for 5ns; rst<= '0'; wait for 5ns;rst<='1';wait for 5ns;

        sew<= "000000"; vl<= x"0000000400000004"; vstart<= "0000000000000000";
        Idata<= "0000100001";
        Xdata<= x"0000000000000002"; 
        WriteDest<="00010000";
        RegSel<="0001000000010000";        
        wait for 10ns;
        --
        newInst<="01";WriteEn_i<="01";
        vm<="11";

        -- Move instruction on lane 0
        -- Expected result: 02's in register v0

        op1_src<= "0101";funct6<= "010111010111"; funct3<="000000";  
        wait for 5ns; newInst<="00";wait for 5ns;
 
        wait for 30ns;
        -- Move instruction on lane 0
        -- Expected result: 03's in register v1
        newInst<="01";WriteEn_i<="01";
        WriteDest<="00010001";
        Xdata<= x"0000000000000003"; 
        wait for 5ns; newInst<="00";wait for 5ns;
 
--        -- Move instruction on lane 1
--        -- Expected result: 07's in register v16       
--        newInst<="10";WriteEn_i(1)<='1';
--        vm(1)<='1';
--        sew(1)<= "000"; vl(1) <= x"00000004"; vstart(1) <= "0000000000";
--        Idata(1)<= "00001";
--        Xdata(1)<= x"00000007"; 
--        WriteDest(1)<="0000";
--        RegSel(1)<="00010000";
--        op1_src(1)<= "01";funct6(1)<= "010111"; funct3(1)<="000";  
--        wait for 5ns; newInst<="00";wait for 5ns;
                 
--        newInst<='1'; wait for 2ns; WriteEn_i<="11"; Xdata<= x"0000000300000004"; wait for 3 ns;
--        newInst<= '0'; wait for 7ns; Xdata<= x"0000000400000005";wait for 8ns;
--        wait for 2ns; Xdata<= x"0000000500000006";wait for 8ns;
--        wait for 2ns; Xdata<= x"0000000600000007";
--        wait for 13ns; WriteEn_i<="00"; wait for 30ns; funct6<="000000000000"; wait for 10ns; funct6<="000000000000"; Xdata<= x"0000000600000005";
--        wait for 15ns; newInst<='1'; wait for 2ns;WriteEn_i<="11";wait for 3ns;newInst<= '0'; wait for 5ns;
        wait;
    end process;

end RegFile_ALU_tb_arch;
