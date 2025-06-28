library IEEE;
use IEEE.Std_Logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity subtracao is
port (
    A: in std_logic_vector(4 downto 0);
    B: in std_logic_vector(4 downto 0);
    resultado: out std_logic_vector(4 downto 0);
    flag: out std_logic
);
end subtracao;

architecture circuito of subtracao is
signal temp: std_logic_vector(4 downto 0);
begin
    temp <= A - B;
    resultado <= temp;
    flag <= '1' when A < B else '0';  -- neg_flag é '1' quando A < B (resultado seria negativo)
end circuito; 