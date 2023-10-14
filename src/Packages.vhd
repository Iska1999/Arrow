library IEEE;
package custom_types is
    use ieee.std_logic_1164.all;
    constant NB_LANES:integer:=2;
    constant lgNB_LANES:integer:=1;
    constant READ_PORTS_PER_LANE: integer :=2; --Number of read ports per lane
    constant REGS_PER_BANK: integer:= 4; --log(number of registers in each bank) It is REG_NUM-1 in our case since we have 2 banks          
    constant XLEN:integer:=32; --Register width    
    constant VLEN:integer:=256;
    constant ELEN: integer:=64;
    constant lgELEN: integer:=6;
    constant lgVLEN:integer:=8;      
--    constant VLEN:integer:=4096;
--    constant ELEN: integer:=1024;
--    constant lgELEN: integer:=10;
--    constant lgVLEN:integer:=12;
    constant REGNUM:integer:=5;
    constant SLEN: natural :=ELEN; 
    constant lgXLEN: integer:=5;
end package;