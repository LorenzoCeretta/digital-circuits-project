library ieee;
use ieee.std_logic_1164.all;

entity mux_41_5b is
port(
    w, x, y, z: in std_logic_vector(4 downto 0);
    sel: in std_logic_vector(1 downto 0);
    saida: out std_logic_vector(4 downto 0)
);
end mux_41_5b;

architecture arch of mux_41_5b is
begin
    with sel select
        saida <= w when "00",
                 x when "01",
                 y when "10",
                 z when others;
end arch;