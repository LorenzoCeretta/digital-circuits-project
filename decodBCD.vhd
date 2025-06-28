library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity decodBCD is
port (
    y: in std_logic_vector(3 downto 0);
    z: out std_logic_vector(7 downto 0)
);
end decodBCD;

architecture arch of decodBCD is
begin
    process(y)
    begin
        case y is
            when "0000" => z <= "00000000"; -- 0
            when "0001" => z <= "00000001"; -- 1
            when "0010" => z <= "00000010"; -- 2
            when "0011" => z <= "00000011"; -- 3
            when "0100" => z <= "00000100"; -- 4
            when "0101" => z <= "00000101"; -- 5
            when "0110" => z <= "00000110"; -- 6
            when "0111" => z <= "00000111"; -- 7
            when "1000" => z <= "00001000"; -- 8
            when "1001" => z <= "00001001"; -- 9
            when "1010" => z <= "00010000"; -- 10
            when "1011" => z <= "00010001"; -- 11
            when "1100" => z <= "00010010"; -- 12
            when "1101" => z <= "00010011"; -- 13
            when "1110" => z <= "00010100"; -- 14
            when "1111" => z <= "00010101"  -- 15
        end case;
    end process;
end arch; 