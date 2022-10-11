-- Model name: datapathGenerator  
-- Description: Data generation component

-- Complete all sections marked >>
-- >> Authors: 
-- >> Date: 

-- Signal dictionary 
-- Inputs
--   selCtrl      deassert (l) to select ctrlA as DPMux select signal 
--                assert   (h) to select ctrlB as DPMux select signal 
--   ctrlA        2-bit control bus
--   ctrlB        2-bit control bus
--   sig0Dat      1-bit data  
--   sig1Dat      3-bit bus data
--   sig2Dat      8-bit bus data
--   sig3Dat      4-bit bus data
-- Outputs         
--   datA         8-bit data 
--   datB         8-bit data. 2s complement of datA 
--   datC         8-bit data. datA + datB

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
entity datapathGenerator is
    Port ( selCtrl     : in  std_logic;
           ctrlA       : in  STD_LOGIC_VECTOR(1 downto 0);
           ctrlB       : in  STD_LOGIC_VECTOR(1 downto 0);  
           sys0Dat     : in  STD_LOGIC;   
           sys1Dat     : in  STD_LOGIC_VECTOR(2 downto 0);   
           sys2Dat     : in  STD_LOGIC_VECTOR(7 downto 0);
           sys3Dat     : in  STD_LOGIC_VECTOR(3 downto 0);
           datA        : out STD_LOGIC_VECTOR(7 downto 0);
           datB        : out STD_LOGIC_VECTOR(7 downto 0);
           datC        : out STD_LOGIC_VECTOR(7 downto 0)
          );
end datapathGenerator;

architecture combinational of datapathGenerator is
-- >> declare internal signals  
signal ctrl : std_logic_vector(1 downto 0);
signal intDatA : std_logic_vector(7 downto 0);
signal intDatB : std_logic_vector(7 downto 0);
begin
    ctrl_mux : process (selCtrl, ctrlA, ctrlB)
    begin
        ctrl <= ctrlA;--default to ctrlA
        if selCtrl = '1' then
            ctrl <= ctrlB;
        end if;
    end process ctrl_mux;
    
    DP_mux : process (ctrl, sys0Dat, sys1Dat, sys2Dat, sys3Dat)
    begin
        case ctrl is
            when "00" => intDatA <= (sys0Dat & sys1Dat & sys2Dat(4 downto 1));
            when "01" => intDatA <= x"f4";
            when "10" => intDatA <= sys2Dat;
            when others => intDatA <= std_logic_vector(resize(unsigned(sys3Dat),intDatA'length));
        end case;           
    end process DP_mux;
    
    asgn_DatA : process (datA, intDatA)
    begin 
        datA <= intDatA;
    end process asgn_DatA;
    
    inv_incr1_asgnDatB: process (intDatB, intDatA, datB)
    begin 
        intDatB <= std_logic_vector( unsigned(not intDatA) + 1);
        datB <= intDatB;
    end process inv_incr1_asgnDatB;
    
    add: process(intDatB, intDatA, datC)
    begin 
        datC <= std_logic_vector( unsigned(intDatB) + unsigned(intDatA));
    end process add;
-- >> complete VHDL model, using signals exactly as defined in the datapathGenerator specification

end combinational;