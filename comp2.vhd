library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity comp2 is
    port (
        A: in std_logic_vector(4 downto 0);  
        F: out std_logic_vector(5 downto 0)  
    );
end comp2;

architecture behavioral of comp2 is
begin
    -- Estende para 6 bits e depois faz o complemento de 2
    F <= (not('0' & A) + 1);
end behavioral; 