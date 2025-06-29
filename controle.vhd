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
		
		when Start =>
			-- Estado inicial - Reset do sistema
			R1 <= '1'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			PE <= Setup;
			
		when Setup =>
			-- Estado de configuração - usuário escolhe nível (SW1..0)
			-- Mostra 'L' no HEX5 e nível no HEX4
			R1 <= '0'; E1 <= '1'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			if BTN1 = '1' then  -- Enter pressionado
				PE <= Play_FPGA;
			else
				PE <= Setup;
			end if;
			
		when Play_FPGA =>
			-- Mostra tempo da FPGA em BCD nos displays HEX1/HEX0
			R1 <= '0'; E1 <= '0'; E2 <= '1'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			if BTN1 = '1' then  -- Enter pressionado
				PE <= Play_User;
			else
				PE <= Play_FPGA;
			end if;
			
		when Play_User =>
			-- Usuário estima o tempo - contador ativo quando SW(17)=1
			-- Timeout de 15 segundos
			R1 <= '0'; E1 <= '0'; E2 <= '0'; E3 <= '1'; E4 <= '0'; E5 <= '1'; E6 <= '0';
			if BTN1 = '1' then  -- Enter pressionado antes do timeout
				PE <= Next_Round;
			elsif end_time = '1' then  -- Timeout de 15 segundos
				PE <= Result;
			else
				PE <= Play_User;
			end if;
			
		when Next_Round =>
			-- Incrementa contador de rodada
			-- Mostra 'r' no HEX3 e rodada no HEX2
			R1 <= '0'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '1'; E5 <= '0'; E6 <= '0';
			PE <= Check;
			
		when Check =>
			-- Calcula COMP = time_FPGA - timer
			-- Calcula penalização e atualiza pontos
			-- Verifica condições de fim de jogo
			R1 <= '0'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			if end_game = '1' or end_round = '1' then
				PE <= Result;
			else
				PE <= Waits;
			end if;
			
		when Waits =>
			-- Mostra estimação do usuário
			-- Aguarda enter para próxima rodada
			R1 <= '0'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			if BTN1 = '1' then  -- Enter pressionado
				PE <= Play_FPGA;
			else
				PE <= Waits;
			end if;
			
		when Result =>
			-- Mostra resultado final nos displays HEX7/HEX6
			-- Fórmula: 32 × L + (end_time ∧ end_game ∧ P)
			R1 <= '0'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '1';
			if BTN1 = '1' then  -- Enter pressionado para reiniciar
				PE <= Start;
			else
				PE <= Result;
			end if;
			
		when others =>
			-- Estado de segurança
			R1 <= '1'; E1 <= '0'; E2 <= '0'; E3 <= '0'; E4 <= '0'; E5 <= '0'; E6 <= '0';
			PE <= Start;
							
	end case;
end process;
end architecture;