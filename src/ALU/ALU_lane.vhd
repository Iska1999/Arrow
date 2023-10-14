library IEEE;
library work;
use work.custom_types.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ALU_lane is
    Port (  
            operand1: in STD_LOGIC_VECTOR(63 downto 0);
            operand2: in STD_LOGIC_VECTOR(63 downto 0);
            funct6: in STD_LOGIC_VECTOR (5 downto 0); --to know which operation
            funct3: in STD_LOGIC_VECTOR (2 downto 0); 
            sew: in STD_LOGIC_VECTOR(2 downto 0);
            result: out STD_LOGIC_VECTOR(63 downto 0) 
            );
end ALU_lane;

architecture ALU_lane_arch of ALU_lane is
  signal sew_int : natural range 8 to 1024;


function signed_minimum(X: in std_logic_vector; Y: in std_logic_vector) return std_logic_vector is
begin
    if (signed(X)>signed(Y)) then
        return Y;
    else return X;
    end if;
end signed_minimum;

function unsigned_minimum(X: in std_logic_vector; Y: in std_logic_vector) return std_logic_vector is
begin
    if (unsigned(X)>unsigned(Y)) then
        return Y;
    else return X;
    end if;
end unsigned_minimum;

function signed_maximum(X: in std_logic_vector; Y: in std_logic_vector) return std_logic_vector is
begin
    if (signed(X)<signed(Y)) then
        return Y;
    else return X;
    end if;
end signed_maximum;

function unsigned_maximum(X: in std_logic_vector; Y: in std_logic_vector) return std_logic_vector is
begin
    if (unsigned(X)<unsigned(Y)) then
        return Y;
    else return X;
    end if;
end unsigned_maximum;

begin

  with sew select 
    sew_int <= 8 when "000",
           16 when "001",
           32 when "010",
           64 when "011",
           128 when "100",
           256 when "101",
           512 when "110",
           1024 when "111",
           XLEN when others;
           
    process(funct6, funct3, operand1, operand2,sew)
    variable tmp:std_logic_vector(2*64-1 downto 0);
    begin
        if(funct3 = "000" or funct3 = "011" or funct3="100") then
            case funct6 is
                when "000000" => --vadd
                
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(signed(operand1(63 downto 56))+signed(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(signed(operand1(55 downto 48))+signed(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(signed(operand1(47 downto 40))+signed(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(signed(operand1(39 downto 32))+signed(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(signed(operand1(31 downto 24))+signed(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(signed(operand1(23 downto 16))+signed(operand2(23 downto 16)));
                        result(15 downto 8)<= std_logic_vector(signed(operand1(15 downto 8))+signed(operand2(15 downto 8)));
                        result(7 downto 0)<= std_logic_vector(signed(operand1(7 downto 0))+signed(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(signed(operand1(63 downto 48))+signed(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(signed(operand1(47 downto 32))+signed(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(signed(operand1(31 downto 16))+signed(operand2(31 downto 16)));
                        result(15 downto 0)<= std_logic_vector(signed(operand1(15 downto 0))+signed(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(signed(operand1(63 downto 32))+signed(operand2(63 downto 32)));
                        result(31 downto 0)<= std_logic_vector(signed(operand1(31 downto 0))+signed(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(signed(operand1)+signed(operand2));
                    end if;
                    
                when "000010" => --vsub
                
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(signed(operand2(63 downto 56))-signed(operand1(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(signed(operand2(55 downto 48))-signed(operand1(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(signed(operand2(47 downto 40))-signed(operand1(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(signed(operand2(39 downto 32))-signed(operand1(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(signed(operand2(31 downto 24))-signed(operand1(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(signed(operand2(23 downto 16))-signed(operand1(23 downto 16)));
                        result(15 downto 8) <= std_logic_vector(signed(operand2(15 downto 8))-signed(operand1(15 downto 8)));
                        result(7 downto 0) <= std_logic_vector(signed(operand2(7 downto 0))-signed(operand1(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(signed(operand2(63 downto 48))-signed(operand1(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(signed(operand2(47 downto 32))-signed(operand1(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(signed(operand2(31 downto 16))-signed(operand1(31 downto 16)));
                        result(15 downto 0) <= std_logic_vector(signed(operand2(15 downto 0))-signed(operand1(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(signed(operand2(63 downto 32))-signed(operand1(63 downto 32)));
                        result(31 downto 0) <= std_logic_vector(signed(operand2(31 downto 0))-signed(operand1(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(signed(operand2)-signed(operand1));
                    end if;                   
                when "000011" => --vrsub (reverse sub)
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(signed(operand1(63 downto 56))-signed(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(signed(operand1(55 downto 48))-signed(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(signed(operand1(47 downto 40))-signed(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(signed(operand1(39 downto 32))-signed(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(signed(operand1(31 downto 24))-signed(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(signed(operand1(23 downto 16))-signed(operand2(23 downto 16)));
                        result(15 downto 8) <= std_logic_vector(signed(operand1(15 downto 8))-signed(operand2(15 downto 8)));
                        result(7 downto 0) <= std_logic_vector(signed(operand1(7 downto 0))-signed(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(signed(operand1(63 downto 48))-signed(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(signed(operand1(47 downto 32))-signed(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(signed(operand1(31 downto 16))-signed(operand2(31 downto 16)));
                        result(15 downto 0) <= std_logic_vector(signed(operand1(15 downto 0))-signed(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(signed(operand1(63 downto 32))-signed(operand2(63 downto 32)));
                        result(31 downto 0) <= std_logic_vector(signed(operand1(31 downto 0))-signed(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(signed(operand1)-signed(operand2));
                    end if;
                when "000100" => --vminu (minimum unsigned)
                    if (sew_int=8) then
                        result(63 downto 56)<= unsigned_minimum(operand1(63 downto 56),operand2(63 downto 56));
                        result(55 downto 48)<= unsigned_minimum(operand1(55 downto 48),operand2(55 downto 48));
                        result(47 downto 40)<= unsigned_minimum(operand1(47 downto 40),operand2(47 downto 40));
                        result(39 downto 32)<= unsigned_minimum(operand1(39 downto 32),operand2(39 downto 32));
                        result(31 downto 24)<= unsigned_minimum(operand1(31 downto 24),operand2(31 downto 24));
                        result(23 downto 16)<= unsigned_minimum(operand1(23 downto 16),operand2(23 downto 16));
                        result(15 downto 8)<= unsigned_minimum(operand1(15 downto 8),operand2(15 downto 8));
                        result(7 downto 0)<= unsigned_minimum(operand1(7 downto 0),operand2(7 downto 0));                        
                    elsif (sew_int=16) then
                        result(63 downto 48)<= unsigned_minimum(operand1(63 downto 48),operand2(63 downto 48));
                        result(47 downto 32)<= unsigned_minimum(operand1(47 downto 32),operand2(47 downto 32));
                        result(31 downto 16)<= unsigned_minimum(operand1(31 downto 16),operand2(31 downto 16));
                        result(15 downto 0)<= unsigned_minimum(operand1(15 downto 0),operand2(15 downto 0));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= unsigned_minimum(operand1(63 downto 32),operand2(63 downto 32));
                        result(31 downto 0)<= unsigned_minimum(operand1(31 downto 0),operand2(31 downto 0));
                    elsif (sew_int=64) then
                        result<= unsigned_minimum(operand1,operand2);
                    end if;
                when "000101" => --vmin (minimum signed)
                    if (sew_int=8) then
                        result(63 downto 56)<= signed_minimum(operand1(63 downto 56),operand2(63 downto 56));
                        result(55 downto 48)<= signed_minimum(operand1(55 downto 48),operand2(55 downto 48));
                        result(47 downto 40)<= signed_minimum(operand1(47 downto 40),operand2(47 downto 40));
                        result(39 downto 32)<= signed_minimum(operand1(39 downto 32),operand2(39 downto 32));
                        result(31 downto 24)<= signed_minimum(operand1(31 downto 24),operand2(31 downto 24));
                        result(23 downto 16)<= signed_minimum(operand1(23 downto 16),operand2(23 downto 16));
                        result(15 downto 8)<= signed_minimum(operand1(15 downto 8),operand2(15 downto 8));
                        result(7 downto 0)<= signed_minimum(operand1(7 downto 0),operand2(7 downto 0));                        
                    elsif (sew_int=16) then
                        result(63 downto 48)<= signed_minimum(operand1(63 downto 48),operand2(63 downto 48));
                        result(47 downto 32)<= signed_minimum(operand1(47 downto 32),operand2(47 downto 32));
                        result(31 downto 16)<= signed_minimum(operand1(31 downto 16),operand2(31 downto 16));
                        result(15 downto 0)<= signed_minimum(operand1(15 downto 0),operand2(15 downto 0));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= signed_minimum(operand1(63 downto 32),operand2(63 downto 32));
                        result(31 downto 0)<= signed_minimum(operand1(31 downto 0),operand2(31 downto 0));
                    elsif (sew_int=64) then
                        result<= signed_minimum(operand1,operand2);
                    end if;
                when "000110" => --vmaxu (maximum unsigned)
                     if (sew_int=8) then
                        result(63 downto 56)<=unsigned_maximum(operand1(63 downto 56),operand2(63 downto 56));
                        result(55 downto 48)<=unsigned_maximum(operand1(55 downto 48),operand2(55 downto 48));
                        result(47 downto 40)<=unsigned_maximum(operand1(47 downto 40),operand2(47 downto 40));
                        result(39 downto 32)<=unsigned_maximum(operand1(39 downto 32),operand2(39 downto 32));
                        result(31 downto 24)<=unsigned_maximum(operand1(31 downto 24),operand2(31 downto 24));
                        result(23 downto 16)<=unsigned_maximum(operand1(23 downto 16),operand2(23 downto 16));
                        result(15 downto 8)<= unsigned_maximum(operand1(15 downto 8),operand2(15 downto 8));
                        result(7 downto 0)<=  unsigned_maximum(operand1(7 downto 0), operand2(7 downto 0));                        
                    elsif (sew_int=16) then   
                        result(63 downto 48)<=unsigned_maximum(operand1(63 downto 48),operand2(63 downto 48));
                        result(47 downto 32)<=unsigned_maximum(operand1(47 downto 32),operand2(47 downto 32));
                        result(31 downto 16)<=unsigned_maximum(operand1(31 downto 16),operand2(31 downto 16));
                        result(15 downto 0)<= unsigned_maximum(operand1(15 downto 0), operand2(15 downto 0));
                    elsif (sew_int=32) then   
                        result(63 downto 32)<=unsigned_maximum(operand1(63 downto 32),operand2(63 downto 32));
                        result(31 downto 0)<= unsigned_maximum(operand1(31 downto 0),operand2(31 downto 0));
                    elsif (sew_int=64) then
                        result<= unsigned_maximum(operand1,operand2);
                    end if;
                when "000111" => --vmax (maximum signed)
                     if (sew_int=8) then
                        result(63 downto 56)<=  signed_maximum(operand1(63 downto 56),operand2(63 downto 56));
                        result(55 downto 48)<=  signed_maximum(operand1(55 downto 48),operand2(55 downto 48));
                        result(47 downto 40)<=  signed_maximum(operand1(47 downto 40),operand2(47 downto 40));
                        result(39 downto 32)<=  signed_maximum(operand1(39 downto 32),operand2(39 downto 32));
                        result(31 downto 24)<=  signed_maximum(operand1(31 downto 24),operand2(31 downto 24));
                        result(23 downto 16)<=  signed_maximum(operand1(23 downto 16),operand2(23 downto 16));
                        result(15 downto 8) <=  signed_maximum(operand1(15 downto 8),operand2(15 downto 8));
                        result(7 downto 0)  <=  signed_maximum(operand1(7 downto 0), operand2(7 downto 0));                        
                    elsif (sew_int=16) then  
                        result(63 downto 48)<= signed_maximum(operand1(63 downto 48),operand2(63 downto 48));
                        result(47 downto 32)<= signed_maximum(operand1(47 downto 32),operand2(47 downto 32));
                        result(31 downto 16)<= signed_maximum(operand1(31 downto 16),operand2(31 downto 16));
                        result(15 downto 0) <= signed_maximum(operand1(15 downto 0), operand2(15 downto 0));
                    elsif (sew_int=32) then  
                        result(63 downto 32)<= signed_maximum(operand1(63 downto 32),operand2(63 downto 32));
                        result(31 downto 0) <= signed_maximum(operand1(31 downto 0),operand2(31 downto 0));
                    elsif (sew_int=64) then
                        result              <= signed_maximum(operand1,operand2);
                    end if;                
                when "001001" => --vand
                    if (sew_int=8) then
                        result(63 downto 56)<=  operand1(63 downto 56) and operand2(63 downto 56);
                        result(55 downto 48)<=  operand1(55 downto 48) and operand2(55 downto 48);
                        result(47 downto 40)<=  operand1(47 downto 40) and operand2(47 downto 40);
                        result(39 downto 32)<=  operand1(39 downto 32) and operand2(39 downto 32);
                        result(31 downto 24)<=  operand1(31 downto 24) and operand2(31 downto 24);
                        result(23 downto 16)<=  operand1(23 downto 16) and operand2(23 downto 16);
                        result(15 downto 8) <=  operand1(15 downto 8)  and operand2(15 downto 8);
                        result(7 downto 0)  <=  operand1(7 downto 0)   and operand2(7 downto 0);                       
                    elsif (sew_int=16) then
                        result(63 downto 48)<=  operand1(63 downto 48) and operand2(63 downto 48);
                        result(47 downto 32)<=  operand1(47 downto 32) and operand2(47 downto 32);
                        result(31 downto 16)<=  operand1(31 downto 16) and operand2(31 downto 16);
                        result(15 downto 0) <=  operand1(15 downto 0)  and  operand2(15 downto 0);
                    elsif (sew_int=32) then
                        result(63 downto 32)<=  operand1(63 downto 32) and operand2(63 downto 32);
                        result(31 downto 0) <=  operand1(31 downto 0)  and operand2(31 downto 0);
                    elsif (sew_int=64) then
                        result              <=  operand1 and operand2;
                    end if; 
                when "001010" => --vor
                    if (sew_int=8) then
                        result(63 downto 56)<=  operand1(63 downto 56) or operand2(63 downto 56);
                        result(55 downto 48)<=  operand1(55 downto 48) or operand2(55 downto 48);
                        result(47 downto 40)<=  operand1(47 downto 40) or operand2(47 downto 40);
                        result(39 downto 32)<=  operand1(39 downto 32) or operand2(39 downto 32);
                        result(31 downto 24)<=  operand1(31 downto 24) or operand2(31 downto 24);
                        result(23 downto 16)<=  operand1(23 downto 16) or operand2(23 downto 16);
                        result(15 downto 8) <=  operand1(15 downto 8)  or operand2(15 downto 8);
                        result(7 downto 0)  <=  operand1(7 downto 0)   or operand2(7 downto 0);                       
                    elsif (sew_int=16) then                            
                        result(63 downto 48)<=  operand1(63 downto 48) or operand2(63 downto 48);
                        result(47 downto 32)<=  operand1(47 downto 32) or operand2(47 downto 32);
                        result(31 downto 16)<=  operand1(31 downto 16) or operand2(31 downto 16);
                        result(15 downto 0) <=  operand1(15 downto 0)  or  operand2(15 downto 0);
                    elsif (sew_int=32) then                            
                        result(63 downto 32)<=  operand1(63 downto 32) or operand2(63 downto 32);
                        result(31 downto 0) <=  operand1(31 downto 0)  or operand2(31 downto 0);
                    elsif (sew_int=64) then
                        result              <=  operand1 or operand2;
                    end if; 
                when "001011" => --vxor
                    if (sew_int=8) then
                        result(63 downto 56)<=  operand1(63 downto 56) xor operand2(63 downto 56);
                        result(55 downto 48)<=  operand1(55 downto 48) xor operand2(55 downto 48);
                        result(47 downto 40)<=  operand1(47 downto 40) xor operand2(47 downto 40);
                        result(39 downto 32)<=  operand1(39 downto 32) xor operand2(39 downto 32);
                        result(31 downto 24)<=  operand1(31 downto 24) xor operand2(31 downto 24);
                        result(23 downto 16)<=  operand1(23 downto 16) xor operand2(23 downto 16);
                        result(15 downto 8) <=  operand1(15 downto 8)  xor operand2(15 downto 8);
                        result(7 downto 0)  <=  operand1(7 downto 0)   xor operand2(7 downto 0);                       
                    elsif (sew_int=16) then                            
                        result(63 downto 48)<=  operand1(63 downto 48) xor operand2(63 downto 48);
                        result(47 downto 32)<=  operand1(47 downto 32) xor operand2(47 downto 32);
                        result(31 downto 16)<=  operand1(31 downto 16) xor operand2(31 downto 16);
                        result(15 downto 0) <=  operand1(15 downto 0)  xor  operand2(15 downto 0);
                    elsif (sew_int=32) then                            
                        result(63 downto 32)<=  operand1(63 downto 32) xor operand2(63 downto 32);
                        result(31 downto 0) <=  operand1(31 downto 0)  xor operand2(31 downto 0);
                    elsif (sew_int=64) then
                        result              <=  operand1 xor operand2;
                    end if; 
                when "011000" => --vmseq (set mask register element if equal)
                    if (sew_int=8) then
                        if (operand1(63 downto 56) = operand2(63 downto 56)) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (operand1(55 downto 48) = operand2(55 downto 48)) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (operand1(47 downto 40) = operand2(47 downto 40)) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (operand1(39 downto 32) = operand2(39 downto 32)) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (operand1(31 downto 24) = operand2(31 downto 24)) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (operand1(23 downto 16) = operand2(23 downto 16)) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (operand1(15 downto 8) = operand2(15 downto 8)) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (operand1(7 downto 0) = operand2(7 downto 0)) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (operand1(63 downto 48) = operand2(63 downto 48)) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (operand1(47 downto 32) = operand2(47 downto 32)) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (operand1(31 downto 16) = operand2(31 downto 16)) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (operand1(15 downto 0) = operand2(15 downto 0)) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (operand1(63 downto 32) = operand2(63 downto 32)) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (operand1(31 downto 0) = operand2(31 downto 0)) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (operand1 = operand2) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;
                when "011001" => --vmsne (set mask register element if not equal)
                    if (sew_int=8) then
                        if (operand1(63 downto 56) /= operand2(63 downto 56)) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (operand1(55 downto 48) /= operand2(55 downto 48)) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (operand1(47 downto 40) /= operand2(47 downto 40)) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (operand1(39 downto 32) /= operand2(39 downto 32)) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (operand1(31 downto 24) /= operand2(31 downto 24)) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (operand1(23 downto 16) /= operand2(23 downto 16)) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (operand1(15 downto 8) /= operand2(15 downto 8)) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (operand1(7 downto 0) /= operand2(7 downto 0)) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (operand1(63 downto 48) /= operand2(63 downto 48)) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (operand1(47 downto 32) /= operand2(47 downto 32)) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (operand1(31 downto 16) /= operand2(31 downto 16)) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (operand1(15 downto 0) /= operand2(15 downto 0)) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (operand1(63 downto 32) /= operand2(63 downto 32)) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (operand1(31 downto 0) /= operand2(31 downto 0)) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (operand1 /= operand2) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;
                when "011010" => --vmsltu (set mask register element if operand1 < operand2 unsigned)

                    if (sew_int=8) then
                        if (unsigned(operand1(63 downto 56)) < unsigned(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(55 downto 48)) < unsigned(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 40)) < unsigned(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(39 downto 32)) < unsigned(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (unsigned(operand1(31 downto 24)) < unsigned(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(23 downto 16)) < unsigned(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 8)) < unsigned(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(7 downto 0)) < unsigned(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (unsigned(operand1(63 downto 48)) < unsigned(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 32)) < unsigned(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 16)) < unsigned(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 0)) < unsigned(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (unsigned(operand1(63 downto 32)) < unsigned(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 0)) < unsigned(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (unsigned(operand1) < unsigned(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;                
                when "011011" => --vmsltu (set mask register element if operand1 < operand2 signed)
                
                    if (sew_int=8) then
                        if (signed(operand1(63 downto 56)) < signed(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (signed(operand1(55 downto 48)) < signed(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 40)) < signed(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (signed(operand1(39 downto 32)) < signed(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (signed(operand1(31 downto 24)) < signed(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (signed(operand1(23 downto 16)) < signed(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 8)) < signed(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (signed(operand1(7 downto 0)) < signed(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (signed(operand1(63 downto 48)) < signed(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 32)) < signed(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 16)) < signed(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 0)) < signed(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (signed(operand1(63 downto 32)) < signed(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 0)) < signed(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (signed(operand1) < signed(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;                                    
                when "011100" => --vmsleu (set mask register element if operand1 <= operand2 unsigned)
                    if (sew_int=8) then
                        if (unsigned(operand1(63 downto 56)) <= unsigned(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(55 downto 48)) <= unsigned(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 40)) <= unsigned(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(39 downto 32)) <= unsigned(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (unsigned(operand1(31 downto 24)) <= unsigned(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(23 downto 16)) <= unsigned(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 8)) <= unsigned(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(7 downto 0)) <= unsigned(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (unsigned(operand1(63 downto 48)) <= unsigned(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 32)) <= unsigned(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 16)) <= unsigned(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 0)) <= unsigned(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (unsigned(operand1(63 downto 32)) <= unsigned(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 0)) <= unsigned(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (unsigned(operand1) <= unsigned(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;                     
                when "011101" => --vmsleu (set mask register element if operand1 <= operand2 signed)
                
                    if (sew_int=8) then
                        if (signed(operand1(63 downto 56)) <= signed(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (signed(operand1(55 downto 48)) <= signed(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 40)) <= signed(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (signed(operand1(39 downto 32)) <= signed(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (signed(operand1(31 downto 24)) <= signed(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (signed(operand1(23 downto 16)) <= signed(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 8)) <= signed(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (signed(operand1(7 downto 0)) <= signed(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (signed(operand1(63 downto 48)) <= signed(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 32)) <= signed(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 16)) <= signed(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 0)) <= signed(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (signed(operand1(63 downto 32)) <= signed(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 0)) <= signed(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (signed(operand1) <= signed(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;
                when "011110" => --vmsgtu (set mask register element if operand1 > operand2 unsigned)
                    if (sew_int=8) then
                        if (unsigned(operand1(63 downto 56)) > unsigned(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(55 downto 48)) > unsigned(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 40)) > unsigned(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(39 downto 32)) > unsigned(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (unsigned(operand1(31 downto 24)) > unsigned(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(23 downto 16)) > unsigned(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 8)) > unsigned(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(7 downto 0)) > unsigned(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (unsigned(operand1(63 downto 48)) > unsigned(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(47 downto 32)) > unsigned(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 16)) > unsigned(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(15 downto 0)) > unsigned(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (unsigned(operand1(63 downto 32)) > unsigned(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (unsigned(operand1(31 downto 0))  > unsigned(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (unsigned(operand1) > unsigned(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;                
                when "011111" => --vmsgt (set mask register element if operand1 > operand2 signed)
                
                    if (sew_int=8) then
                        if (signed(operand1(63 downto 56)) > signed(operand2(63 downto 56))) then
                            result(63 downto 56)<= (others=>'0'); result(56)<= '1';
                        else
                            result(63 downto 56)<= (others=>'0');
                        end if;
                        if (signed(operand1(55 downto 48)) > signed(operand2(55 downto 48))) then
                            result(55 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(55 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 40)) > signed(operand2(47 downto 40))) then
                            result(47 downto 40)<= (others=>'0'); result(40)<= '1';
                        else
                            result(47 downto 40)<= (others=>'0');
                        end if;
                        if (signed(operand1(39 downto 32)) > signed(operand2(39 downto 32))) then
                            result(39 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(39 downto 32)<= (others=>'0');
                        end if; 
                        if (signed(operand1(31 downto 24)) > signed(operand2(31 downto 24))) then
                            result(31 downto 24)<= (others=>'0'); result(24)<= '1';
                        else
                            result(31 downto 24)<= (others=>'0');
                        end if;
                        if (signed(operand1(23 downto 16)) > signed(operand2(23 downto 16))) then
                            result(23 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(23 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 8)) > signed(operand2(15 downto 8))) then
                            result(15 downto 8)<= (others=>'0'); result(8)<= '1';
                        else
                            result(15 downto 8)<= (others=>'0');
                        end if;
                        if (signed(operand1(7 downto 0)) > signed(operand2(7 downto 0))) then
                            result(7 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(7 downto 0)<= (others=>'0');
                        end if; 
                                                                   
                    elsif (sew_int=16) then

                        if (signed(operand1(63 downto 48)) > signed(operand2(63 downto 48))) then
                            result(63 downto 48)<= (others=>'0'); result(48)<= '1';
                        else
                            result(63 downto 48)<= (others=>'0');
                        end if;
                        if (signed(operand1(47 downto 32)) > signed(operand2(47 downto 32))) then
                            result(47 downto 32)<= (others=>'0'); result(32)<= '1';
                        else
                            result(47 downto 32)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 16)) > signed(operand2(31 downto 16))) then
                            result(31 downto 16)<= (others=>'0'); result(16)<= '1';
                        else
                            result(31 downto 16)<= (others=>'0');
                        end if;
                        if (signed(operand1(15 downto 0)) > signed(operand2(15 downto 0))) then
                            result(15 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(15 downto 0)<= (others=>'0');
                        end if; 
                                                                  
                    elsif (sew_int=32) then
                    
                        if (signed(operand1(63 downto 32)) > signed(operand2(63 downto 32))) then
                            result(63 downto 33)<= (others=>'0'); result(32)<= '1';
                        else
                            result(63 downto 33)<= (others=>'0');
                        end if;
                        if (signed(operand1(31 downto 0)) > signed(operand2(31 downto 0))) then
                            result(31 downto 0)<= (others=>'0'); result(0)<= '1';
                        else
                            result(31 downto 0)<= (others=>'0');
                        end if;
                                            
                    elsif (sew_int=64) then
                        if (signed(operand1) > signed(operand2)) then
                            result(63 downto 1)<= (others=>'0'); result(0)<= '1';
                        else
                            result<= (others=>'0');
                        end if;                    
                    end if;
--                when "100101" => --vsll (shift left logical)
--					result<= std_logic_vector(shift_left(unsigned(operand1), to_integer(unsigned(operand2(lgELEN-1 downto 0))) ));
--				when "101000" => --vsrl (shift right logical (zero-extension) ) 
--					result<= std_logic_vector(shift_right(unsigned(operand1),to_integer( unsigned(operand2(lgELEN-1 downto 0))) ));
--				when "101001" => --vsra (shift right arithmetic (sign-extension) )
--					result<= std_logic_vector(shift_right(signed(operand1),to_integer( unsigned(operand2(lgELEN-1 downto 0)) )));
                when others => result<= (others=>'0'); 
            end case;
        elsif(funct3 = "010" or funct3 = "110") then
            case funct6 is
            
                when "100000" => --vdivu (division unsigned)
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(unsigned(operand1(63 downto 56))/unsigned(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(unsigned(operand1(55 downto 48))/unsigned(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(unsigned(operand1(47 downto 40))/unsigned(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(unsigned(operand1(39 downto 32))/unsigned(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(unsigned(operand1(31 downto 24))/unsigned(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(unsigned(operand1(23 downto 16))/unsigned(operand2(23 downto 16)));
                        result(15 downto 8)<= std_logic_vector( unsigned(operand1(15 downto 8)) /unsigned(operand2(15 downto 8)));
                        result(7 downto 0)<= std_logic_vector ( unsigned(operand1(7 downto 0))  /unsigned(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(unsigned(operand1(63 downto 48))/unsigned(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(unsigned(operand1(47 downto 32))/unsigned(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(unsigned(operand1(31 downto 16))/unsigned(operand2(31 downto 16)));
                        result(15 downto 0)<= std_logic_vector( unsigned(operand1(15 downto 0)) /unsigned(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(unsigned(operand1(63 downto 32))/unsigned(operand2(63 downto 32)));
                        result(31 downto 0)<= std_logic_vector( unsigned(operand1(31 downto 0)) /unsigned(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(unsigned(operand1)/unsigned(operand2));
                    end if;
                when "100001" => --vdiv (division signed)
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(signed(operand1(63 downto 56))/signed(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(signed(operand1(55 downto 48))/signed(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(signed(operand1(47 downto 40))/signed(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(signed(operand1(39 downto 32))/signed(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(signed(operand1(31 downto 24))/signed(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(signed(operand1(23 downto 16))/signed(operand2(23 downto 16)));
                        result(15 downto 8)<= std_logic_vector(signed(operand1(15 downto 8))  /signed(operand2(15 downto 8)));
                        result(7 downto 0)<= std_logic_vector(signed(operand1(7 downto 0))    /signed(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(signed(operand1(63 downto 48))/signed(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(signed(operand1(47 downto 32))/signed(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(signed(operand1(31 downto 16))/signed(operand2(31 downto 16)));
                        result(15 downto 0)<= std_logic_vector(signed(operand1(15 downto 0))  /signed(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(signed(operand1(63 downto 32))/signed(operand2(63 downto 32)));
                        result(31 downto 0)<= std_logic_vector(signed(operand1(31 downto 0))  /signed(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(signed(operand1)/signed(operand2));
                    end if;                    
                when "100010" => --vremu (remainder unsigned)
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(unsigned(operand1(63 downto 56))rem unsigned(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(unsigned(operand1(55 downto 48))rem unsigned(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(unsigned(operand1(47 downto 40))rem unsigned(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(unsigned(operand1(39 downto 32))rem unsigned(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(unsigned(operand1(31 downto 24))rem unsigned(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(unsigned(operand1(23 downto 16))rem unsigned(operand2(23 downto 16)));
                        result(15 downto 8)<= std_logic_vector( unsigned(operand1(15 downto 8)) rem unsigned(operand2(15 downto 8)));
                        result(7 downto 0)<= std_logic_vector ( unsigned(operand1(7 downto 0))  rem unsigned(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(unsigned(operand1(63 downto 48))rem unsigned(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(unsigned(operand1(47 downto 32))rem unsigned(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(unsigned(operand1(31 downto 16))rem unsigned(operand2(31 downto 16)));
                        result(15 downto 0)<= std_logic_vector( unsigned(operand1(15 downto 0)) rem unsigned(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(unsigned(operand1(63 downto 32))rem unsigned(operand2(63 downto 32)));
                        result(31 downto 0)<= std_logic_vector( unsigned(operand1(31 downto 0)) rem unsigned(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(unsigned(operand1)rem unsigned(operand2));
                    end if;
                when "100011" => --vrem (remainder signed)
                    if (sew_int=8) then
                        result(63 downto 56)<= std_logic_vector(signed(operand1(63 downto 56))rem signed(operand2(63 downto 56)));
                        result(55 downto 48)<= std_logic_vector(signed(operand1(55 downto 48))rem signed(operand2(55 downto 48)));
                        result(47 downto 40)<= std_logic_vector(signed(operand1(47 downto 40))rem signed(operand2(47 downto 40)));
                        result(39 downto 32)<= std_logic_vector(signed(operand1(39 downto 32))rem signed(operand2(39 downto 32)));
                        result(31 downto 24)<= std_logic_vector(signed(operand1(31 downto 24))rem signed(operand2(31 downto 24)));
                        result(23 downto 16)<= std_logic_vector(signed(operand1(23 downto 16))rem signed(operand2(23 downto 16)));
                        result(15 downto 8)<= std_logic_vector(signed(operand1(15 downto 8))  rem signed(operand2(15 downto 8)));
                        result(7 downto 0)<= std_logic_vector(signed(operand1(7 downto 0))    rem signed(operand2(7 downto 0)));
                         
                    elsif (sew_int=16) then
                        result(63 downto 48)<= std_logic_vector(signed(operand1(63 downto 48))rem signed(operand2(63 downto 48)));
                        result(47 downto 32)<= std_logic_vector(signed(operand1(47 downto 32))rem signed(operand2(47 downto 32)));
                        result(31 downto 16)<= std_logic_vector(signed(operand1(31 downto 16))rem signed(operand2(31 downto 16)));
                        result(15 downto 0)<= std_logic_vector(signed(operand1(15 downto 0))  rem signed(operand2(15 downto 0)));
                    elsif (sew_int=32) then
                        result(63 downto 32)<= std_logic_vector(signed(operand1(63 downto 32))rem signed(operand2(63 downto 32)));
                        result(31 downto 0)<= std_logic_vector(signed(operand1(31 downto 0))  rem signed(operand2(31 downto 0)));
                    elsif (sew_int=64) then
                        result<= std_logic_vector(signed(operand1)rem signed(operand2));
                    end if;
                    
                    
--                when "100100" => --vmulhu (multiplication unsigned, returning high bits of product)
--                	tmp:= std_logic_vector(unsigned(operand1)*unsigned(operand2));
--                	result<=tmp(2*ELEN-1 downto ELEN);
--                when "100101" => --vmul (multiplication signed, returning low bits of product)
--                	tmp:= std_logic_vector(signed(operand1)*signed(operand2));
--                	result<=tmp(ELEN-1 downto 0);	
----				when "100110" => --vmulhsu: Signed(vs2)-Unsigned multiply, returning high bits of product
----                	tmp:= std_logic_vector(unsigned(operand1)*unsigned(operand2));
----                	result<=tmp(2*ELEN-1 downto ELEN);	
--				when "100111" => --vmulh: Signed multiply, returning high bits of product
--                	tmp:= std_logic_vector(signed(operand1)*signed(operand2));
--                	result<=tmp(2*ELEN-1 downto ELEN);
                when others => result<= (others=>'0'); 
            end case;
        else
            result<= (others=>'0');
        end if;
    end process;

end ALU_lane_arch;