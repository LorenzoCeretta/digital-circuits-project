library ieee;
use ieee.std_logic_1164.all;

entity mux_21_7b is
port(
    sel: in std_logic;
    x, y: in std_logic_vector(6 downto 0);
    saida: out std_logic_vector(6 downto 0)
);
end mux_21_7b;

architecture arch of mux_21_7b is
begin
    saida <= x when sel = '0' else y;
end arch;