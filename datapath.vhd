-- Datapath, fazendo a conexÃƒÂ£o entre cada componente

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
port (
-- Entradas de dados
SW: in std_logic_vector(17 downto 0);
CLOCK_50: in std_logic; --NA PLACA
--CLOCK_50, CLK_1Hz: in std_logic; --NO EMULADOR
-- Sinais de controle
R1, E1, E2, E3, E4, E5, E6: in std_logic;
-- Sinais de status
end_game, end_time, end_round: out std_logic;
-- Saidas de dados
HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7: out std_logic_vector(6 downto 0);
LEDR: out std_logic_vector(17 downto 0)
);
end datapath;

architecture arc of datapath is
--============================================================--
--                      COMPONENTS                            --
--============================================================--
-------------------DIVISOR DE FREQUENCIA------------------------

component Div_Freq is
	port (	    clk: in std_logic;
				reset: in std_logic;
				CLK_1Hz: out std_logic
			);
end component;

------------------------CONTADORES------------------------------

component counter is port( 
         R: in std_logic;
         clock: in std_logic;
         E: in std_logic;
			count: out std_logic_vector(3 downto 0);
			flag: out std_logic);
end component;

-------------------ELEMENTOS DE MEMORIA-------------------------

component reg2bits is 
port(
    CLK, RST, enable: in std_logic;
    D: in std_logic_vector(1 downto 0);
    Q: out std_logic_vector(1 downto 0)
    );
end component;

component reg5bits is 
port(
    CLK, RST, enable: in std_logic;
    D: in std_logic_vector(4 downto 0);
    Q: out std_logic_vector(4 downto 0)
    );
end component;

component reg5bits_points is 
port (
	CLK, RST, enable: in std_logic;
	D: in std_logic_vector(5 downto 0);
	Q: out std_logic_vector(5 downto 0)
	);
end component;

component reg6bits_points is 
port(
    CLK, RST, enable: in std_logic;
	D: in std_logic_vector(5 downto 0);
	Q: out std_logic_vector(5 downto 0)
	);
end component;

component ROM0 is
  port ( address : in std_logic_vector(3 downto 0);
         data : out std_logic_vector(4 downto 0) );
end component;

component ROM1 is
  port ( address : in std_logic_vector(3 downto 0);
         data : out std_logic_vector(4 downto 0) );
end component;

component ROM2 is
  port ( address : in std_logic_vector(3 downto 0);
         data : out std_logic_vector(4 downto 0) );
end component;

component ROM3 is
  port ( address : in std_logic_vector(3 downto 0);
         data : out std_logic_vector(4 downto 0) );
end component;

---------------------MULTIPLEXADORES----------------------------


component mux2pra1_4bits is
port(
    sel: in std_logic;
	x, y: in std_logic_vector(3 downto 0);
	saida: out std_logic_vector(3 downto 0)
    );
end component;

component mux2pra1_7bits is
port (sel: in std_logic;
		x, y: in std_logic_vector(6 downto 0);
		saida: out std_logic_vector(6 downto 0)
);
end component;

component mux2pra1_5bits is
port (sel: in std_logic;
		x, y: in std_logic_vector(4 downto 0);
		saida: out std_logic_vector(4 downto 0)
);
end component;

component mux4pra1_5bits is	
port (F1: in  std_logic_vector(4 downto 0);
 F2: in  std_logic_vector(4 downto 0);
 F3: in  std_logic_vector(4 downto 0);
 F4: in  std_logic_vector(4 downto 0);
 sel: in  std_logic_vector(1 downto 0);
 F: out  std_logic_vector(4 downto 0));
end component;


----------------------DECODIFICADOR-----------------------------

component decod7seg is
port(
    X: in std_logic_vector(3 downto 0);
    Y: out std_logic_vector(6 downto 0)
    );
end component;

component decodtermo is
    port (
        X : in  std_logic_vector(4 downto 0);
        S : out std_logic_vector(17 downto 0)
    );
end component;

component decodBCD is port (
	input  : in  std_logic_vector(3 downto 0);
	output : out std_logic_vector(7 downto 0)
	);
end component;

-------------------COMPARADORES E SOMA--------------------------

component subtracao is port(
	A       : in  std_logic_vector(4 downto 0);
   B       : in  std_logic_vector(4 downto 0);
   resultado       : out std_logic_vector(4 downto 0);
	flag: out std_logic
    );
end component;

component somador is port (
    A: in  std_logic_vector(4 downto 0);
    B: in  std_logic_vector(5 downto 0);
    F: out  std_logic_vector(5 downto 0);
	 flag: out std_logic);
end component;

component comp2 is
    port (
        A       : in  std_logic_vector(4 downto 0);
        F       : out std_logic_vector(4 downto 0)
    );
end component;

--============================================================--
--                      SIGNALS                               --
--============================================================--

signal COMP_msb, CLK_1, SW17_and_E3, end_game_aux_or_end_time_aux, end_game_aux, end_time_aux, COMP_5, flag1, flag2, SW0orE5: std_logic; -- 1 bit
signal SEL: std_logic_vector (1 downto 0); -- 2 bits
signal final_point_msb, final_point_lsb, round, timer, time_fpga_3_downto_0, FPGA_BCD_7_downto_4, FPGA_BCD_3_downto_0, time_BCD_7_downto_4, time_BCD_3_downto_0, mux_hex0, mux_hex1, end_game_aux_or_end_time_aux_extended, mux_hex0aux, mux_hex1aux: std_logic_vector (3 downto 0); -- 4 bits
signal t5bits, COMP, time_FPGA, double_neg_COMP, neg_COMP, penalty, ROM_out, ROM0_out, ROM1_out, ROM2_out, ROM3_out: std_logic_vector (4 downto 0); -- 5 bits
signal points, points_reg: std_logic_vector(5 downto 0);
signal dec_hex6, dec_hex7: std_logic_vector (6 downto 0);
signal time_BCD, FPGA_BCD: std_logic_vector (7 downto 0);

begin


--DIV: Div_Freq port map (CLOCK_50, R2, clk_1); -- para uso na placa

-- a fazer pelo alun@


end arc;
