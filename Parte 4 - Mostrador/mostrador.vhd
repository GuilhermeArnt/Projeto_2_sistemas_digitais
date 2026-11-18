library ieee;
use ieee.std_logic_1164.all;

entity mostrador is
  generic (
    MAX_TEMPO : natural := 100000
  );
  port (
    clk                : in  std_logic;
    rst                : in  std_logic;
    mcando             : in  std_logic_vector(7 downto 0);
    prod               : in  std_logic_vector(15 downto 0);
    mcador             : in  std_logic_vector(7 downto 0);
    selecao            : in  std_logic_vector(1 downto 0);
    mostrador_an       : out std_logic_vector(3 downto 0);
    mostrador_ca       : out std_logic_vector(6 downto 0);
    leds_selecao_sinal : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of mostrador is
  signal dado_bin          : std_logic_vector(15 downto 0);
  signal bcd_20            : std_logic_vector(19 downto 0);
  signal minus_s           : std_logic;
  signal ready_s, start_s, done_s : std_logic;

  signal en_dig, en_tmp, init_dig, init_tmp : std_logic;
  signal done_dig, done_tmp                 : std_logic;
begin

  -- 1. Seleção da fonte de dados
  U_SELECAO: entity work.selecao_fonte
    port map (
      mcando  => mcando,
      mcador  => mcador,
      prod    => prod,
      selecao => selecao,
      saida   => dado_bin
    );

  -- 2. Conversor Binário (16 bits com sinal) para BCD (4 dígitos)
  U_CONV_BCD: entity work.conversor_bin_to_BCD
    port map (
      clk   => clk,
      rst   => rst,
      start => start_s,
      bin   => dado_bin,
      ready => ready_s,
      done  => done_s,
      bcd   => bcd_20,
      minus => minus_s
    );

  -- 3. Controle do display (FSM + Datapath)
  U_CTRL: entity work.controle_display_leds_controle
    port map (
      clk                  => clk,
      rst                  => rst,
      ready                => ready_s,
      done                 => done_s,
      done_contador_digito => done_dig,
      done_contador_tempo  => done_tmp,
      en_contador_digito   => en_dig,
      en_contador_tempo    => en_tmp,
      init_contador_digito => init_dig,
      init_contador_tempo  => init_tmp,
      start                => start_s
    );

  U_DATAPATH: entity work.controle_display_leds_datapath
    generic map (
      MAX_TEMPO => MAX_TEMPO
    )
    port map (
      clk                  => clk,
      rst                  => rst,
      digitos              => bcd_20(15 downto 0), -- descarta os 4 bits mais significativos
      en_contador_tempo    => en_tmp,
      init_contador_tempo  => init_tmp,
      en_contador_digito   => en_dig,
      init_contador_digito => init_dig,
      mostrador_an         => mostrador_an,
      mostrador_ca         => mostrador_ca,
      done_contador_digito => done_dig,
      done_contador_tempo  => done_tmp
    );

  -- 4. LEDs de sinalização
  leds_selecao_sinal <= minus_s & selecao;

end architecture;