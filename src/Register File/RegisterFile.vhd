library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
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
end RegisterFile;

architecture RegFile_arch of RegisterFile is
    
component Bank1 is
    Port ( clk : in STD_LOGIC;
           out1 : out STD_LOGIC_VECTOR (63 downto 0);
           out2 : out STD_LOGIC_VECTOR (63 downto 0);
           mask_bit: out STD_LOGIC;
           RegSel1 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           RegSel2 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           WriteEn: in STD_LOGIC;
           WriteEnSel : in STD_LOGIC_VECTOR(7 downto 0); -- 8 bits since this is the maximum number of elements in 64 bits
           WriteData : in STD_LOGIC_VECTOR (63 downto 0);
           WriteDest : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           sew: in STD_LOGIC_VECTOR (2 downto 0);
           vlmul: in STD_LOGIC_VECTOR(2 downto 0);
           vl: in STD_LOGIC_VECTOR(XLEN-1 downto 0);
           vstart: in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           mask_reg: out STD_LOGIC_VECTOR(VLEN-1 downto 0);
           r_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           w_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           reg_out: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software
           );
end component;

component Bank is
    Port ( clk : in STD_LOGIC;
           out1 : out STD_LOGIC_VECTOR (63 downto 0);
           out2 : out STD_LOGIC_VECTOR (63 downto 0);
           RegSel1 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           RegSel2 : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           WriteEn: in STD_LOGIC;
           WriteEnSel : in STD_LOGIC_VECTOR(7 downto 0); -- 8 bits since this is the maximum number of elements in 64 bits
           WriteData : in STD_LOGIC_VECTOR (63 downto 0);
           WriteDest : in STD_LOGIC_VECTOR (REGNUM-2 downto 0);
           sew: in STD_LOGIC_VECTOR (2 downto 0);
           vlmul: in STD_LOGIC_VECTOR(2 downto 0);
           vl: in STD_LOGIC_VECTOR(XLEN-1 downto 0);
           vstart: in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           r_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           w_offset : in STD_LOGIC_VECTOR(lgVLEN-1 downto 0);
           reg_out: out STD_LOGIC_VECTOR(VLEN-1 downto 0) --for testing in software
           );
end component;   
begin
     BankA: Bank1 
                  PORT MAP(
                  clk=>clk, 
                  out1=>OutPort(63 downto 0), 
                  out2=>OutPort(2*64-1 downto 64),
                  mask_bit=>mask_bit, 
                  RegSel1=>RegSel(REGS_PER_BANK-1 downto 0),
                  RegSel2=>RegSel(2*REGS_PER_BANK-1 downto REGS_PER_BANK), 
                  WriteEn=>WriteEn(0), 
                  WriteEnSel=>WriteEnSel(7 downto 0),
                  WriteData=>WriteData(63 downto 0), 
                  WriteDest=>WriteDest(REGS_PER_BANK-1 downto 0), 
                  sew=>sew(2 downto 0), 
                  vlmul=>vlmul(2 downto 0),
                  vl=>vl(XLEN-1 downto 0), 
                  vstart=>vstart(lgVLEN-1 downto 0),
                  mask_reg=>mask_reg,
                  r_offset=>r_offset(lgVLEN-1 downto 0),
                  w_offset=>w_offset(lgVLEN-1 downto 0),
                  reg_out=>reg_out_1
                  );  
    
    BANK_GEN:for i in 1 to NB_LANES-1 generate
        Banks: Bank 
                    PORT MAP(
                    clk=>clk, 
                    out1=>OutPort((READ_PORTS_PER_LANE*i+1)*64 -1 downto READ_PORTS_PER_LANE*i*64),
                    out2=>OutPort((READ_PORTS_PER_LANE*i+2)*64 -1 downto (READ_PORTS_PER_LANE*i+1)*64),
                    RegSel1=>RegSel((READ_PORTS_PER_LANE*i+1)*REGS_PER_BANK-1 downto READ_PORTS_PER_LANE*i*REGS_PER_BANK), 
                    RegSel2=>RegSel((READ_PORTS_PER_LANE*i+2)*REGS_PER_BANK-1 downto (READ_PORTS_PER_LANE*i+1)*REGS_PER_BANK),
                    WriteEn=>WriteEn(i),
                    WriteEnSel=>WriteEnSel(8*(i+1)-1 downto 8*i), 
                    WriteData=>WriteData((i+1)*ELEN-1 downto i*ELEN),
                    WriteDest=>WriteDest((i+1)*REGS_PER_BANK-1 downto i*REGS_PER_BANK), 
                    sew=>sew((i+1)*3-1 downto i*3),
                    vlmul=>vlmul((i+1)*3-1 downto i*3),
                    vl=>vl((i+1)*XLEN-1 downto i*XLEN), 
                    vstart=>vstart((i+1)*lgVLEN-1 downto i*lgVLEN),
                    r_offset=>r_offset((i+1)*lgVLEN-1 downto i*lgVLEN),
                    w_offset=>w_offset((i+1)*lgVLEN-1 downto i*lgVLEN),
                    reg_out=>reg_out_2
                    );   
    
    end generate BANK_GEN;

--    process(RegSel1, RegSel2, RegSel3, RegSel4, WriteDest1, WriteDest2)
--    --variable RegSelFlag: STD_LOGIC_VECTOR(RegNum-2 downto 0):=(others => '0'); --one-hot encoding (RegSelA1, RegSelA2, RegSelB1, RegSelB2) to know which bank ports are busy ('1') or free ('0').
--    --variable WriteDestFlag: STD_LOGIC_VECTOR(1 downto 0):= (others => '0'); --one-hot encoding (WriteDestA, WriteDestB) 
--    begin
--        --if instruction done, reset appropriate flags
        
--        --check the MSB to know to which bank to dispatch instruction.
--        if( RegSel1(RegNum-1) = '1' ) then  --Bank A
----            if ( RegSelFlag(RSA1) = '0' ) then RegSelA1 <= RegSel1(RegNum-2 downto 0); RegSelFlag(RSA1):='1'; --assign appropriate port and flag as busy
----            elsif( ( RegSelFlag(RSA2) = '0' ) ) then RegSelA2 <= RegSel1(RegNum-2 downto 0); RegSelFlag(RSA2):='1';
----            --else --stall
----            end if;
--            RegSelA1 <= RegSel1(RegNum-2 downto 0);
--            --RegSelA2 <= RegSel1(RegNum-2 downto 0);
--        else --Bank B
----            if ( RegSelFlag(RSB1) = '0' ) then RegSelB1 <= RegSel1(RegNum-2 downto 0); RegSelFlag(RSB1):='1'; 
----            elsif( ( RegSelFlag(RSB2) = '0' ) ) then RegSelB2 <= RegSel1(RegNum-2 downto 0); RegSelFlag(RSB2):='1';
----            --else --stall
----            end if;
--            RegSelB1 <= RegSel1(RegNum-2 downto 0);
--            --RegSelB2 <= RegSel1(RegNum-2 downto 0);
--        end if;
        
--        if( RegSel2(RegNum-1) = '1') then
----            if ( RegSelFlag(RSA1) = '0' ) then RegSelA1 <= RegSel2(RegNum-2 downto 0); RegSelFlag(RSA1):='1'; --assign appropriate port and flag as busy
----            elsif( ( RegSelFlag(RSA2) = '0' ) ) then RegSelA2 <= RegSel2(RegNum-2 downto 0); RegSelFlag(RSA2):='1';
----            --else --stall
----            end if; 
--            --RegSelA1 <= RegSel2(RegNum-2 downto 0);
--            RegSelA2 <= RegSel2(RegNum-2 downto 0);
--        else --Bank B
----            if ( RegSelFlag(RSB1) = '0' ) then RegSelB1 <= RegSel2(RegNum-2 downto 0); RegSelFlag(RSB1):='1'; 
----            elsif( ( RegSelFlag(RSB2) = '0' ) ) then RegSelB2 <= RegSel2(RegNum-2 downto 0); RegSelFlag(RSB2):='1';
----            --else --stall
----            end if;
--            --RegSelB1 <= RegSel2(RegNum-2 downto 0);
--            RegSelB2 <= RegSel2(RegNum-2 downto 0);
--        end if;
        
--        if( RegSel3(RegNum-1) = '1') then
----            if ( RegSelFlag(RSA1) = '0' ) then RegSelA1 <= RegSel3(RegNum-2 downto 0); RegSelFlag(RSA1):='1'; --assign appropriate port and flag as busy
----            elsif( ( RegSelFlag(RSA2) = '0' ) ) then RegSelA2 <= RegSel3(RegNum-2 downto 0); RegSelFlag(RSA2):='1';
----            --else --stall
----            end if; 
--            RegSelA1 <= RegSel3(RegNum-2 downto 0);
--            --RegSelA2 <= RegSel3(RegNum-2 downto 0);
--        else --Bank B
----            if ( RegSelFlag(RSB1) = '0' ) then RegSelB1 <= RegSel3(RegNum-2 downto 0); RegSelFlag(RSB1):='1'; 
----            elsif( ( RegSelFlag(RSB2) = '0' ) ) then RegSelB2 <= RegSel3(RegNum-2 downto 0); RegSelFlag(RSB2):='1';
----            --else --stall
----            end if;
--            RegSelB1 <= RegSel3(RegNum-2 downto 0);
--            --RegSelB2 <= RegSel3(RegNum-2 downto 0);
--        end if;
        
--        if( RegSel4(RegNum-1) = '1') then
----            if ( RegSelFlag(RSA1) = '0' ) then RegSelA1 <= RegSel4(RegNum-2 downto 0); RegSelFlag(RSA1):='1'; --assign appropriate port and flag as busy
----            elsif( ( RegSelFlag(RSA2) = '0' ) ) then RegSelA2 <= RegSel4(RegNum-2 downto 0); RegSelFlag(RSA2):='1';
----            --else --stall
----            end if; 
--            --RegSelA1 <= RegSel4(RegNum-2 downto 0);
--            RegSelA2 <= RegSel4(RegNum-2 downto 0);
--        else --Bank B
----            if ( RegSelFlag(RSB1) = '0' ) then RegSelB1 <= RegSel4(RegNum-2 downto 0); RegSelFlag(RSB1):='1'; 
----            elsif( ( RegSelFlag(RSB2) = '0' ) ) then RegSelB2 <= RegSel4(RegNum-2 downto 0); RegSelFlag(RSB2):='1';
----            --else --stall
----            end if;
--            --RegSelB1 <= RegSel4(RegNum-2 downto 0);
--            RegSelB2 <= RegSel4(RegNum-2 downto 0);
--        end if;
        
--        if( WriteDest1(RegNum-1) = '1' ) then
----            if(WriteDestFlag(WDA)='0') then WriteDestA<= WriteDest1(RegNum-2 downto 0); WriteDestFlag(WDA):='1';
----            --else -- stall
----            end if;
--            WriteDestA<= WriteDest1(RegNum-2 downto 0);
--        else
----            if(WriteDestFlag(WDB)='0') then WriteDestB<= WriteDest1(RegNum-2 downto 0); WriteDestFlag(WDB):='1';
----            --else -- stall
----            end if;
--            WriteDestB<= WriteDest1(RegNum-2 downto 0);
--        end if;
        
--        if( WriteDest2(RegNum-1) = '1' ) then
----            if(WriteDestFlag(WDA)='0') then WriteDestA<= WriteDest2(RegNum-2 downto 0); WriteDestFlag(WDA):='1';
----            --else -- stall
----            end if;
--            WriteDestA<= WriteDest2(RegNum-2 downto 0);
--        else
----            if(WriteDestFlag(WDB)='0') then WriteDestB<= WriteDest2(RegNum-2 downto 0); WriteDestFlag(WDB):='1';
----            --else -- stall
----            end if;
--            WriteDestB<= WriteDest2(RegNum-2 downto 0);
--        end if;
--    end process;
end RegFile_arch;