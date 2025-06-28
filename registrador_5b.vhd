library ieee;
use ieee.std_logic_1164.all;

entity registrador_5b is
port(
    CLK, RST, enable: in std_logic;
    D: in std_logic_vector(4 downto 0);
    Q: out std_logic_vector(4 downto 0)
);
end registrador_5b;

architecture arch of registrador_5b is
begin
    process(CLK, RST)
    begin
        if RST = '1' then
            Q <= "00000";
        elsif CLK'event and CLK = '1' then
            if enable = '1' then
                Q <= D;
            end if;
        end if;
    end process;
end arch; 