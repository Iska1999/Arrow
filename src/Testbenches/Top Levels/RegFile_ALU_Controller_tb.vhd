library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegFile_ALU_Controller_tb is
end RegFile_ALU_Controller_tb;

architecture Behavioral of RegFile_ALU_Controller_tb is

component RegFile_ALU_Controller is
  Port ( 
    clk_in:in STD_LOGIC;
    rst: in STD_LOGIC;
    incoming_inst: in STD_LOGIC;   
    Xdata_in: in STD_LOGIC_VECTOR(XLEN-1 downto 0); --data coming from scalar register
    vect_inst : in STD_LOGIC_VECTOR (31 downto 0);
    
    CSR_Addr: in STD_LOGIC_VECTOR ( 11 downto 0);   -- reg address of the CSR                 -- 11 is based on spec sheet
    CSR_WD: in STD_LOGIC_VECTOR (XLEN-1 downto 0); 
    CSR_WEN: in STD_LOGIC;  
    rs1_data: in STD_LOGIC_VECTOR( XLEN-1 downto 0);  
    rs2_data: in STD_LOGIC_VECTOR(XLEN-1 downto 0); 
    rd_data: out STD_LOGIC_VECTOR (XLEN-1 downto 0);  --to scalar slave register            
    
    MemWrite : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                -- enables write to memory
    MemRead: out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                  -- enables read from memory
    WBSrc : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                    -- selects if wrbsc is from ALU or mem 
                                                -- 0 = ALU
                                                -- 1 = Mem    
    CSR_out: out STD_LOGIC_VECTOR (XLEN-1 downto 0); 
    vill: out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    vma:out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    vta:out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    vlmul: out STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);
    sew: out STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);      
    nf : out STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
    mop: out STD_LOGIC_VECTOR (2*NB_LANES-1 downto 0);-- goes to memory lane
                                                          -- 00 if unit stride    
                                                          -- 01 reserved
                                                          -- 10 if strided 
                                                          -- 11 if indexed 
    vm : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    vs2_rs2 : out STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); -- 2nd vector operand
    rs1 : out STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); --1st vector operand
    funct3_width : out STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
    vd_vs3 : out STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); --vector write destination  
    extension: out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);        -- goes to memory
                                                                 -- 0 if zero extended
                                                                 -- 1 if sign extended    
    memwidth: out STD_LOGIC_VECTOR(4*NB_LANES-1 downto 0);   -- goes to memory,FOLLOWS CUSTOM ENCODING: represents the exponent of the memory element width 
                                                          -- number of bits/transfer     
    o_done : out STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
    reg_out_1: out STD_LOGIC_VECTOR(VLEN-1 downto 0);  --for testing in software 
    reg_out_2: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software                                                           
  );
end component;

signal    clk_in: STD_LOGIC;
signal    rst: STD_LOGIC;
signal    incoming_inst:  STD_LOGIC;   
signal    Xdata_in: STD_LOGIC_VECTOR(XLEN-1 downto 0); --data coming from scalar register
signal    CSR_Addr:  STD_LOGIC_VECTOR ( 11 downto 0);   -- reg address of the CSR                 -- 11 is based on spec sheet
signal    CSR_WD:  STD_LOGIC_VECTOR (XLEN-1 downto 0); 
signal    CSR_WEN:  STD_LOGIC; 
signal    rs1_data:  STD_LOGIC_VECTOR( XLEN-1 downto 0);  
signal    rs2_data: STD_LOGIC_VECTOR(XLEN-1 downto 0); 
signal    rd_data:  STD_LOGIC_VECTOR (XLEN-1 downto 0);  --to scalar slave register            
signal    MemWrite :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                -- enables write to memory
signal    MemRead:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                  -- enables read from memory
signal    WBSrc :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);                    -- selects if wrbsc is from ALU or mem 
signal    CSR_out:  STD_LOGIC_VECTOR (XLEN-1 downto 0); 
signal    vill:  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal    vma:STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal    vta: STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal    vlmul: STD_LOGIC_VECTOR(3*NB_LANES-1 downto 0);  
signal    sew_t:  STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);    
signal    nf :  STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
signal    mop:  STD_LOGIC_VECTOR (2*NB_LANES-1 downto 0);-- goes to memory lane
signal    vm :  STD_LOGIC_VECTOR(NB_LANES-1 downto 0);
signal    vs2_rs2 :  STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); -- 2nd vector operand
signal    rs1 :  STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); --1st vector operand
signal    funct3_width :  STD_LOGIC_VECTOR (3*NB_LANES-1 downto 0);
signal    vd_vs3 :  STD_LOGIC_VECTOR (4*NB_LANES-1 downto 0); --vector write destination  
signal    extension: STD_LOGIC_VECTOR(NB_LANES-1 downto 0);        -- goes to memory
signal    memwidth: STD_LOGIC_VECTOR(4*NB_LANES-1 downto 0);   -- goes to memory,FOLLOWS CUSTOM ENCODING: represents the exponent of the memory element width  
signal    o_done : STD_LOGIC_VECTOR(NB_LANES-1 downto 0);

--for software testing
signal    reg_out_1: STD_LOGIC_VECTOR(VLEN-1 downto 0);
signal    reg_out_2: STD_LOGIC_VECTOR(VLEN-1 downto 0);

-- The following signals are used to make testing each instruction easier
signal    t_vect_inst: STD_LOGIC_VECTOR(31 downto 0); 
signal    t_vs1: STD_LOGIC_VECTOR(4 downto 0);
signal    t_vs2: STD_LOGIC_VECTOR(4 downto 0);
signal    t_vd: STD_LOGIC_VECTOR(4 downto 0);
signal    t_opcode: STD_LOGIC_VECTOR(6 downto 0);
signal    t_funct3: STD_LOGIC_VECTOR(2 downto 0);
signal    t_funct6: STD_LOGIC_VECTOR(5 downto 0);
signal    t_vm: STD_LOGIC;

begin

t_vect_inst<= t_funct6 & t_vm & t_vs2 & t_vs1 & t_funct3 & t_vd & t_opcode;

UUT:RegFile_ALU_Controller 
    PORT MAP (
        clk_in=>clk_in,
        rst=>rst,
        incoming_inst=>incoming_inst, 
        Xdata_in=>Xdata_in,
        vect_inst=>t_vect_inst,
        CSR_Addr=>CSR_Addr,
        CSR_WD=>CSR_WD,
        CSR_WEN=>CSR_WEN,
        rs1_data=>rs1_data,
        rs2_data=>rs2_data, 
        rd_data=>rd_data,          
        MemWrite=>MemWrite,
        MemRead=>MemRead,
        WBSrc=>WBSrc, 
        CSR_out=>CSR_out,
        vill=>vill,
        vma=>vma,
        vta=>vta,
        vlmul=>vlmul,
        sew=>sew_t,  
        nf=>nf,
        mop=>mop,
        vm=>vm,
        vs2_rs2=>vs2_rs2,
        rs1=>rs1,
        funct3_width=>funct3_width,
        vd_vs3=>vd_vs3,
        extension=>extension,
        memwidth=>memwidth,
        o_done=>o_done,
        reg_out_1=>reg_out_1,
        reg_out_2=>reg_out_2                                                                                                                                                                                 
    );
                            
    clk_proc: process begin
        clk_in<='0';
        wait for 5ns;
        clk_in<='1'; 
        wait for 5ns;
    end process;
    
    process begin   
        --FOR SIMPLICITY, CHANGE ELEN TO 32, VLEN TO 32, lgELEN to 5, lgVLEN to 5                         
        incoming_inst<='0';rst<='1'; wait for 5 ns; rst<='0'; wait for 5ns;rst<='1';wait for 5 ns;
        --set vstart as 0
        CSR_Addr<=x"008"; CSR_WD<=x"00000000"; CSR_WEN<='1'; wait for 10ns;
        CSR_WEN<='0';
        --vsetvli configuration instruction to set SEW to 8 and vl to VLEN/SEW = 32 elements
        incoming_inst<='1';
        t_funct6<="000000";t_vm<='0';t_vs2<="00000";t_vs1<="00000";t_funct3<="111";t_vd<="00001";t_opcode<="1010111";
        wait for 10 ns;
        incoming_inst<='0';
        wait for 10ns;
        
        
--        -- move instruction to fill v0 register
          -- Expected result: 0000000004030201000000000102030400000000040302010000000001020304 in v0
        incoming_inst<='1';        
        t_funct6<="010111";t_vm<='1';t_vs2<="00000";t_vs1<="00000";t_funct3<="100";t_vd<="00000";t_opcode<="1010111";
                
        Xdata_in<=x"01020304"; wait for 10 ns; incoming_inst<='0';
        Xdata_in<=x"04030201"; wait for 10 ns;
        Xdata_in<=x"01020304"; wait for 10 ns; 
        Xdata_in<=x"04030201"; wait for 10 ns;     
        --move instruction to fill v16 register
--        incoming_inst<='1'; 
--        Xdata_in<=x"00000002";
--        t_funct6<="010111";t_vm<='1';t_vs2<="10100";t_vs1<="10000";t_funct3<="100";t_vd<="10000";t_opcode<="1010111";
--        wait for 10 ns; incoming_inst<='0'; 

--         add immediate instruction on lane 1; adds 4 to v0, and writes sum in v2
--         Expected result: 0000000004030205000000000102030800000000040302050000000001020308 in v2
        --wait for 10 ns;
        incoming_inst<='1';
        t_funct6<="000000";t_vm<='1';t_vs2<="00000";t_vs1<="00100";t_funct3<="011";t_vd<="00010";t_opcode<="1010111";
        wait for 10 ns; incoming_inst<='0';
         
        -- unmasked add instruction on lane 1; adds v0 to v2, and writes sum in v1
        -- Expected result: 000000000806040a000000000204060c000000000806040a000000000204060c in v1
        wait for 30 ns;
        incoming_inst<='1';
        t_funct6<="000000";t_vm<='1';t_vs2<="00010";t_vs1<="00000";t_funct3<="000";t_vd<="00001";t_opcode<="1010111";
        wait for 10 ns; incoming_inst<='0';     
        wait for 30 ns;
        -- vsetvli configuration instruction to set SEW to 8 and vl to 7 elements
        incoming_inst<='1';
        rs1_data<=x"00000007";
        t_funct6<="000000";t_vm<='0';t_vs2<="00000";t_vs1<="00001";t_funct3<="111";t_vd<="00001";t_opcode<="1010111";
        wait for 10 ns;
        incoming_inst<='0';
        wait for 10ns;
        
        -- unmasked add instruction on lane 1; adds v0 to v2, and writes sum in v3
        -- Expected result: U's followed by 0000000204060c in v3
        wait for 30 ns;
        incoming_inst<='1';
        t_funct6<="000000";t_vm<='1';t_vs2<="00010";t_vs1<="00000";t_funct3<="000";t_vd<="00011";t_opcode<="1010111";
        wait for 10 ns; incoming_inst<='0'; 
                 
--        -- unmasked unsigned subtract instruction on lane 1; subtracts v2 from v1, and writes sum in v3
--        -- Expected result: 01020304 in v1
--        wait for 30 ns;
--        incoming_inst<='1';
--        t_funct6<="000010";t_vm<='1';t_vs2<="00001";t_vs1<="00010";t_funct3<="000";t_vd<="00011";t_opcode<="1010111";
--        wait for 10 ns; incoming_inst<='0';       

--        -- unmasked max instruction on lane 1; finds max between v1 and v2, and writes sum in v4
--        -- Expected result: 06060606 in v4
--        wait for 50 ns;
--        incoming_inst<='1';
--        t_funct6<="000111";t_vm<='1';t_vs2<="00001";t_vs1<="00010";t_funct3<="000";t_vd<="00100";t_opcode<="1010111";
--        wait for 10 ns; incoming_inst<='0'; 

--        -- move instruction on lane 1; moves Xdata to each element in v5
--        -- Expected result: 01001011 in v5
--        wait for 30 ns;
--        incoming_inst<='1';
--        t_funct6<="010111";t_vm<='1';t_vs2<="00000";t_vs1<="00101";t_funct3<="100";t_vd<="00101";t_opcode<="1010111";
--        Xdata_in<=x"00000011"; wait for 10 ns; incoming_inst<='0'; 
--        Xdata_in<=x"00000010"; wait for 10 ns;
--        Xdata_in<=x"00000000"; wait for 10 ns;
--        Xdata_in<=x"00000001"; wait for 10 ns;
--        Xdata_in<=x"00000010";  -- This is just to make sure we aren't writing any additional data

--        -- masked add instruction on lane 1; adds v1 to v2, and writes sum in v1
--        -- Expected result: UU0eUUUU in v6
        --wait for 10 ns;
--        incoming_inst<='1';
--        t_funct6<="000000";t_vm<='0';t_vs2<="00010";t_vs1<="00001";t_funct3<="000";t_vd<="00110";t_opcode<="1010111";
--        wait for 10 ns; incoming_inst<='0';
        
--        -- merge instruction on lane 1; merges Xdata to each element in v5
--        -- Expected result: 05050505 in v0
--        wait for 30 ns;
--        incoming_inst<='1';
--        t_funct6<="000000";t_vm<='1';t_vs2<="00000";t_vs1<="00000";t_funct3<="100";t_vd<="00000";t_opcode<="1010111";
--        Xdata_in<=x"00000004"; wait for 10 ns; incoming_inst<='0';
--       -- I think merge and move should be reviewed
                            
        wait;
    end process;
end Behavioral;