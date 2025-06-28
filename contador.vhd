library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity contador is 
    port(
        R: in std_logic;                          
        clock: in std_logic;                        
        E: in std_logic;                           
        count: out std_logic_vector(3 downto 0);   
        flag: out std_logic                        
    );
end contador;

architecture behavioral of contador is
    signal count_value: std_logic_vector(3 downto 0);
begin
    process(clock, R)
    begin
        if R = '1' then
            count_value <= "0000";
            flag <= '0';
        elsif (clock'event and clock = '1') then
            if E = '1' then
                if count_value = "1111" then  -- (15)
                    flag <= '1';
                    count_value <= count_value;  
                else
                    count_value <= count_value + 1;
                    flag <= '0';
                end if;
            end if;
        end if;
    end process;
    
    count <= count_value; 
end behavioral; 