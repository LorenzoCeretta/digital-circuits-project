-- Datapath, fazendo a conexÃƒÂ£o entre cada componente

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
entity datapath is
port (
-- Entradas de dados
SW: in std_logic_vector(17 downto 0);

--CLOCK_50: in std_logic; --NA PLACA
CLOCK_50, CLK_1Hz: in std_logic; --NO EMULADOR

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

--component Div_Freq is
--port (    clk: in std_logic;
--reset: in std_logic;
--CLK_1Hz: out std_logic
--);
--end component;

component Div_Freq_emu is
port (    clk: in std_logic;
          reset: in std_logic;
          CLK_1Hz, sim_2hz: out std_logic
);
end component;

------------------------CONTADORES------------------------------

component contador is port(
         R: in std_logic;
         clock: in std_logic;
         E: in std_logic;
count: out std_logic_vector(3 downto 0);
flag: out std_logic);
end component;

-------------------ELEMENTOS DE MEMORIA-------------------------

component registrador_2b is
port(
    CLK, RST, enable: in std_logic;
    D: in std_logic_vector(1 downto 0);
    Q: out std_logic_vector(1 downto 0)
    );
end component;

component registrador_5b is
port(
    CLK, RST, enable: in std_logic;
    D: in std_logic_vector(4 downto 0);
    Q: out std_logic_vector(4 downto 0)
    );
end component;

component registrador_6b is
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
component mux_21_8b is
port(
    sel: in std_logic;
    x, y: in std_logic_vector(7 downto 0);
    saida: out std_logic_vector(7 downto 0)
    );
end component;

component mux_21_4b is
port(
    sel: in std_logic;
    x, y: in std_logic_vector(3 downto 0);
    saida: out std_logic_vector(3 downto 0)
    );
end component;

component mux_21_7b is
port (sel: in std_logic;
    x, y: in std_logic_vector(6 downto 0);
    saida: out std_logic_vector(6 downto 0)
);
end component;

component mux_21_6b is
port (sel: in std_logic;
    x, y: in std_logic_vector(5 downto 0);
    saida: out std_logic_vector(5 downto 0)
);
end component;

component mux_41_5b is
port (w: in  std_logic_vector(4 downto 0);
    x: in  std_logic_vector(4 downto 0);
    y: in  std_logic_vector(4 downto 0);
    z: in  std_logic_vector(4 downto 0);
    sel: in  std_logic_vector(1 downto 0);
    saida: out  std_logic_vector(4 downto 0)
);
end component;

----------------------DECODIFICADOR-----------------------------

component decod7seg is
port(
    C: in std_logic_vector(3 downto 0);
    saida: out std_logic_vector(6 downto 0)
    );
end component;

component decodtermo is
    port (
        X : in  std_logic_vector(4 downto 0);
        S : out std_logic_vector(17 downto 0)
    );
end component;

component decodBCD is port (
    y: in std_logic_vector(3 downto 0);
    z: out std_logic_vector(7 downto 0)
);
end component;

-------------------COMPARADORES E SOMA--------------------------

component subtracao is port(
    A: in std_logic_vector(4 downto 0);
    B: in std_logic_vector(4 downto 0);
    resultado: out std_logic_vector(4 downto 0);
    flag: out std_logic
);
end component;

component soma is port (
    A: in std_logic_vector(5 downto 0);
    B: in std_logic_vector(5 downto 0);
    F: out std_logic_vector(5 downto 0)
);
end component;

--============================================================--
--                      SIGNALS                               --
--============================================================--

signal COMP_msb, CLK_1, SW17_and_E3, end_game_aux_or_end_time_aux, end_game_aux, end_time_aux, COMP_5, flag1, flag2, SW0orE5, neg_flag: std_logic; -- 1 bit
signal SEL: std_logic_vector (1 downto 0); -- 2 bits
signal SEL00, selfin4, time_high_out, time_low_out, final_point_msb, final_point_lsb, round, timer, time_fpga_3_downto_0, FPGA_BCD_7_downto_4, FPGA_BCD_3_downto_0, time_BCD_out_7_downto_4, time_BCD_out_3_downto_0, mux_hex0, mux_hex1, end_game_aux_or_end_time_aux_extended, mux_hex0aux, mux_hex1aux: std_logic_vector (3 downto 0); -- 4 bits
signal t5bits, s, COMP, time_FPGA, ROM_out, ROM0_out, ROM1_out, ROM2_out, ROM3_out, final, end_game_aux_extended, end_time_aux_extended: std_logic_vector (4 downto 0); -- 5 bits
signal points, points_reg, double_neg_COMP, neg_COMP, penalty: std_logic_vector(5 downto 0); -- 6 bits para penalty e points
signal dec_hex6, dec_hex7: std_logic_vector (6 downto 0);
signal time_BCD, FPGA_BCD, time_BCD_out: std_logic_vector (7 downto 0);

-- Decodificação do nível (HEX4)
signal nivel: std_logic_vector(3 downto 0);
signal dec_hex4: std_logic_vector(6 downto 0);

-- Sinais de controle
signal nivel_reg: std_logic_vector(1 downto 0); -- Registrador para o nível

begin

-- Sinais de controle
SW17_and_E3 <= SW(17) and E3;
SW0orE5 <= SW(0) or E5;

-- Registrador para armazenar o nível
Reg_2bits: registrador_2b port map(CLOCK_50, R1, E1, SW(1 downto 0), SEL);

FPGA_BCD_7_downto_4 <= FPGA_BCD(7 downto 4);
FPGA_BCD_3_downto_0 <= FPGA_BCD(3 downto 0);
time_BCD_out_7_downto_4 <= time_BCD_out(7 downto 4);
time_BCD_out_3_downto_0 <= time_BCD_out(3 downto 0);
time_fpga_3_downto_0 <= time_FPGA(3 downto 0);
SEL00 <= "00" & SEL;
selfin4 <= '0' & SEL & final(4);
t5bits <= '0' & timer;

--- Letras fixas ---
HEX3 <= "0101111"; -- r
HEX5 <= "1000111"; -- L

--- Lógica do jogo ---
double_neg_COMP <= COMP & '0';  -- Penalidade 2x quando excede (COMP positivo)
neg_COMP <= (not('0' & COMP) + 1);  -- Penalidade 1x quando falta (COMP negativo)
end_game_aux <= (neg_flag or points(5));  -- Fim de jogo se pontos negativos
end_game <= end_game_aux;
end_time <= end_time_aux;

-- Extensão dos sinais de controle para 5 bits
end_game_aux_extended <= end_game_aux & end_game_aux & end_game_aux & end_game_aux & end_game_aux;
end_time_aux_extended <= end_time_aux & end_time_aux & end_time_aux & end_time_aux & end_time_aux;

-- Cálculo do resultado final
final <= ((not(end_game_aux_extended)) and (not(end_time_aux_extended)) and (points_reg(4 downto 0)));

--- Multiplexadores ---
Mux_penalty: mux_21_6b port map(neg_flag, double_neg_COMP, neg_COMP, penalty);
Mux_debug: mux_21_8b port map(SW(0), "00000000", time_BCD, time_BCD_out);
Mux_rom: mux_41_5b port map(ROM0_out, ROM1_out, ROM2_out, ROM3_out, SEL, ROM_out);
Mux_hex7: mux_21_7b port map(E6, "1111111", dec_hex7, HEX7);
Mux_hex6: mux_21_7b port map(E6, "1111111", dec_hex6, HEX6);
Mux_time_high: mux_21_4b port map(SW0orE5, "0000", time_BCD_out_7_downto_4, time_high_out);
Mux_time_low: mux_21_4b port map(SW0orE5, "0000", time_BCD_out_3_downto_0, time_low_out);
Mux_display_high: mux_21_4b port map(E2, time_high_out, FPGA_BCD_7_downto_4, mux_hex1);
Mux_display_low: mux_21_4b port map(E2, time_low_out, FPGA_BCD_3_downto_0, mux_hex0);

--- Registradores ---
Reg_5bits: registrador_5b port map(CLOCK_50, R1, E2, ROM_out, time_FPGA);
Reg_6bits: registrador_6b port map(CLOCK_50, R1, E4, points, points_reg);

--- ROMs ---
ROM0_comp: ROM0 port map(round, ROM0_out);
ROM1_comp: ROM1 port map(round, ROM1_out);
ROM2_comp: ROM2 port map(round, ROM2_out);
ROM3_comp: ROM3 port map(round, ROM3_out);

--- Somador ---
soma_points: soma port map(penalty, points_reg, points);

--- Subtrator ---
sub: subtracao port map(time_FPGA, t5bits, COMP, neg_flag);

--- Contadores ---
Counter_round: contador port map(R1, CLOCK_50, E4, round, end_round);
Counter_time: contador port map(E2, CLK_1Hz, SW17_and_E3, timer, end_time_aux);

--- Decodificadores ---
decod_HEX0: decod7seg port map(mux_hex0, HEX0);
decod_HEX1: decod7seg port map(mux_hex1, HEX1);
decod_HEX2: decod7seg port map(round, HEX2);
decod_HEX4: decod7seg port map(SEL00, HEX4);
decod_HEX6: decod7seg port map(final(3 downto 0), dec_hex6);
decod_HEX7: decod7seg port map(selfin4, dec_hex7);
decod_termo: decodtermo port map(points_reg(4 downto 0), LEDR);
decod_BCD1: decodBCD port map(timer, time_BCD);
decod_BCD2: decodBCD port map(time_fpga_3_downto_0, FPGA_BCD);

--- Divisores de Frequência ---
Div_Freq: Div_Freq_emu port map(CLOCK_50, R1, CLK_1, open); -- NO EMULADOR
--Div_Freq: Div_Freq port map(CLOCK_50, R1, CLK_1); -- NA PLACA

end arc;