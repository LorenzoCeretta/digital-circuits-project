--Bloco de controle, tem a descrição de funcionamento da máquina de estados. Garante que tudo funciona como deve, saídas e transições de um estado para outro.

library ieee;
use ieee.std_logic_1164.all;

entity controle is
port
(
BTN1, BTN0, clock_50: in std_logic;
end_game, end_time, end_round: in std_logic;
R1, E1, E2, E3, E4, E5, E6: out std_logic
);
end entity;

architecture arc of controle is
	type State is (Start, Setup, Play_FPGA, Play_User, Next_Round, Check, Waits, Result); --Aqui temos os estados
	signal EA, PE: State := Start; 						-- PE: proximo estado, EA: estado atual 

begin

process (clock_50, BTN0) -- Processo para ínicio das transições de estados, e o botão start.
begin
	if BTN0 = '0' then
		EA <= Start;
	elsif (clock_50'event and clock_50='1') then
		EA <= PE;
	end if;
end process;

process (EA, BTN1, BTN0, end_game, end_time, end_round) 	--Aqui temos as transições de estado, com as saídas de cada estados e as condições para a transição. 
begin
	case (EA) is
		


-- a fazer pelo alun@
 
							
	end case;
end process;
end architecture;