library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_display_leds_datapath is
  generic (
    MAX_TEMPO : natural := 100000 -- 1 ms @ 100 MHz
  );
  port (
    clk                  : in  std_logic;
    rst                  : in  std_logic;
    digitos              : in  std_logic_vector(15 downto 0); -- M(15:12), C(11:8), D(7:4), U(3:0)
    en_contador_tempo    : in  std_logic;
    init_contador_tempo  : in  std_logic;
    en_contador_digito   : in  std_logic;
    init_contador_digito : in  std_logic;
    mostrador_an         : out std_logic_vector(3 downto 0);
    mostrador_ca         : out std_logic_vector(6 downto 0);
    done_contador_digito : out std_logic;
    done_contador_tempo  : out std_logic
  );
end entity;

architecture rtl of controle_display_leds_datapath is
  signal cnt_tempo  : unsigned(19 downto 0);
  signal cnt_digito : unsigned(1 downto 0);
  signal bcd_atual  : std_logic_vector(3 downto 0);
begin

  -- Contador de tempo
  process (clk, rst)
  begin
    if rst = '1' then
      cnt_tempo <= (others => '0');
    elsif rising_edge(clk) then
      if init_contador_tempo = '1' then
        cnt_tempo <= (others => '0');
      elsif en_contador_tempo = '1' then
        cnt_tempo <= cnt_tempo + 1;
      end if;
    end if;
  end process;

  done_contador_tempo <= '1' when cnt_tempo > to_unsigned(MAX_TEMPO, cnt_tempo'length) else '0';

  -- Contador de dígito (binário 0 a 3)
  process (clk, rst)
  begin
    if rst = '1' then
      cnt_digito <= (others => '0');
    elsif rising_edge(clk) then
      if init_contador_digito = '1' then
        cnt_digito <= (others => '0');
      elsif en_contador_digito = '1' then
        cnt_digito <= cnt_digito + 1;
      end if;
    end if;
  end process;

  done_contador_digito <= '1' when cnt_digito = "00" else '0';

  -- Decodificador de ânodos (ativo em '0') e MUX dos dígitos BCD
  with cnt_digito select
    mostrador_an <= "1110" when "01", -- U (dígito mais à direita)
                    "1101" when "10", -- D
                    "1011" when "11", -- C
                    "0111" when others; -- M ("00", dígito mais à esquerda)

  with cnt_digito select
    bcd_atual <= digitos(3 downto 0)   when "01",   -- U
                 digitos(7 downto 4)   when "10",   -- D
                 digitos(11 downto 8)  when "11",   -- C
                 digitos(15 downto 12) when others; -- M ("00")

  -- Transcodificador BCD para 7 segmentos (ativo em '0': ordem gfedcba)
  with bcd_atual select
    mostrador_ca <= "1000000" when "0000", -- 0
                    "1111001" when "0001", -- 1
                    "0100100" when "0010", -- 2
                    "0110000" when "0011", -- 3
                    "0011001" when "0100", -- 4
                    "0010010" when "0101", -- 5
                    "0000010" when "0110", -- 6
                    "1111000" when "0111", -- 7
                    "0000000" when "1000", -- 8
                    "0010000" when "1001", -- 9
                    "1111111" when others; -- apagado

end architecture;