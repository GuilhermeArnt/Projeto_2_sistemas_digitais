library ieee;
use ieee.std_logic_1164.all;

entity projeto_multiplicador is
  generic (
    MAX_TEMPO_DISPLAY : natural := 100_000 -- 1 ms por dígito @ 100 MHz
  );
  port (
    clk                : in  std_logic;
    rst                : in  std_logic;
    btn                : in  std_logic_vector(3 downto 0);
    mostrador_an       : out std_logic_vector(3 downto 0);
    mostrador_ca       : out std_logic_vector(6 downto 0);
    leds_selecao_sinal : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of projeto_multiplicador is

  -- Sinais de interconexão entre entrada_dados, multiplicador_booth e mostrador
  signal s_mcando  : std_logic_vector(7 downto 0);
  signal s_mcador  : std_logic_vector(7 downto 0);
  signal s_prod    : std_logic_vector(15 downto 0);
  signal s_selecao : std_logic_vector(1 downto 0);

  -- Sinais de handshaking entre entrada_dados e multiplicador_booth
  signal s_start   : std_logic;
  signal s_ready   : std_logic;
  signal s_done    : std_logic;

begin

  -- 1. Subsistema de Entrada de Dados (Debounce, Pulsos e Controle de Parâmetros)
  U_ENTRADA_DADOS : entity work.entrada_dados
    port map (
      clk     => clk,
      rst     => rst,
      btn     => btn,
      ready   => s_ready,
      done    => s_done,
      mcando  => s_mcando,
      mcador  => s_mcador,
      selecao => s_selecao,
      start   => s_start
    );

  -- 2. Subsistema Multiplicador de Booth (8 bits com sinal -> Produto 16 bits)
  U_MULTIPLICADOR_BOOTH : entity work.multiplicador_booth
    generic map (
      n => 8,
      m => 4
    )
    port map (
      clk   => clk,
      rst   => rst,
      start => s_start,
      ready => s_ready,
      done  => s_done,
      A     => s_mcando,
      B     => s_mcador,
      P     => s_prod
    );

  -- 3. Subsistema Mostrador (Seleção de Fonte, Bin->BCD e Multiplexação 7-Seg/LEDs)
  U_MOSTRADOR : entity work.mostrador
    generic map (
      MAX_TEMPO => MAX_TEMPO_DISPLAY
    )
    port map (
      clk                => clk,
      rst                => rst,
      mcando             => s_mcando,
      prod               => s_prod,
      mcador             => s_mcador,
      selecao            => s_selecao,
      mostrador_an       => mostrador_an,
      mostrador_ca       => mostrador_ca,
      leds_selecao_sinal => leds_selecao_sinal
    );

end architecture structural;