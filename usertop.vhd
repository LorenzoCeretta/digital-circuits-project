-- faz a conexão entre o controle e o datapath.

library IEEE;
use IEEE.Std_Logic_1164.all;

entity usertop is
port (
--CLOCK_50:in std_logic; -- usar na placa
CLK_500Hz, CLK_1Hz:in std_logic; -- usar no emulador
--RKEY:in std_logic_vector(3 downto 0);
KEY:in std_logic_vector(3 downto 0);
--RSW:in std_logic_vector(17 downto 0);
SW:in std_logic_vector(17 downto 0);
LEDR:out std_logic_vector(17 downto 0);
HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7: out std_logic_vector(6 downto 0)
);
end entity;

architecture arc of usertop is

component datapath is
port (
SW: in std_logic_vector(17 downto 0);
--CLOCK_50: in std_logic; -- usar na placa
CLOCK_50, CLK_1Hz: in std_logic; -- usar no emulador
R1, E1, E2, E3, E4, E5, E6: in std_logic;
end_game, end_time, end_round: out std_logic;
HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: out std_logic_vector(6 downto 0);
LEDR: out std_logic_vector(17 downto 0)
);
end component;

component controle is
port (
BTN1, BTN0, clock_50: in std_logic;
end_game, end_time, end_round: in std_logic;
R1, E1, E2, E3, E4, E5, E6: out std_logic
);
end component;

component ButtonSync is
port (
KEY0, KEY1, CLK: in std_logic;
BTN0, BTN1: out std_logic
);
end component;

	signal R1, E1, E2, E3, E4, E5, E6: std_logic;   -- sinais de controle
	signal end_game, end_time, end_round: std_logic;   -- sinais de status
	signal btn0, btn1: std_logic;   -- botões sincronizados

begin

PM_datapath: datapath port map(
											SW => SW(17 downto 0),
											--CLOCK_50 => CLOCK_50, -- NA PLACA
											CLOCK_50 => CLK_500Hz, -- NO EMULADOR
											CLK_1Hz => CLK_1Hz,  -- NO EMULADOR
											R1 => R1,
											E1 => E1,
											E2 => E2,
											E3 => E3,
											E4 => E4,
											E5 => E5,
                      E6 => E6,
											end_game => end_game,
											end_time => end_time,
											end_round => end_round,
											HEX0 => HEX0,
											HEX1 => HEX1,
											HEX2 => HEX2,
											HEX3 => HEX3,
											HEX4 => HEX4,
											HEX5 => HEX5,
											HEX6 => HEX6,
											HEX7 => HEX7,
											LEDR => LEDR(17 downto 0)
);

PM_controle: controle port map(
											BTN1 => btn1,
											BTN0 => btn0,
											--clock_50 => clock_50, -- NA PLACA
											clock_50 => CLK_500Hz, -- NO EMULADOR
											end_game => end_game,
											end_time => end_time,
											end_round => end_round,
											R1 => R1,
											E1 => E1,
											E2 => E2,
											E3 => E3,
											E4 => E4,
											E5 => E5,
                      E6 => E6
);

PM_ButtonSync: ButtonSync port map(
												KEY0 => KEY(0), 
												KEY1 => KEY(1), 
												--CLK => CLOCK_50, -- NA PLACA
												CLK => CLK_500Hz, -- NO EMULADOR
												BTN0 => btn0,
												BTN1 => btn1
);

end arc;
