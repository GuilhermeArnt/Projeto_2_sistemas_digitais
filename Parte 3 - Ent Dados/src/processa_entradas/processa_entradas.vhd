library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processa_entradas is
  port (
    btn            : in std_logic_vector(3 downto 0);  --! sinais das chaves mecânicas
    btn_processado : out std_logic_vector(3 downto 0); --! sinais das chaves processadas
    clk            : in std_logic;                     --! sinal de relógio
    rst            : in std_logic                      --! sinal de reset assíncrono ativo em '1´'
  );
end entity;
architecture processa_entradas of processa_entradas is
  constant counter_size  : integer := 24;                --! tamanho do contador para contar o intervalo de tempo estável
  constant tempo_estavel : integer := 10_000_000;        --! tempo sem variações na chave deve ser 0,1 s para f_clk = 100 MHz
  signal btn_debounce    : std_logic_vector(3 downto 0); --! Sinal processado, sem o repique das chaves e gerando um pulso ou pulsos quando a chave é pressionada
begin

  pulso_e_pulsos : for i in 0 to 1 generate
    gera_pulso_e_pulsos_inc : entity work.gera_pulso_e_pulsos
      port map
      (
        x   => btn_debounce(i),
        z   => btn_processado(i),
        clk => clk,
        rst => rst
      );
  end generate;

  somente_pulso : for i in 2 to 3 generate
    gera_pulso_sel : entity work.gera_pulso
      port map
      (
        x   => btn_debounce(i),
        z   => btn_processado(i),
        clk => clk,
        rst => rst
      );
  end generate;

  -- realiza o debounce cas chaves mecânicas
  gera_debounce :
  for i in 0 to 3 generate
    debounce_inc : entity work.debounce
      generic map(
        counter_size  => counter_size,
        tempo_estavel => tempo_estavel
      )
      port map
      (
        ch     => btn(i),
        ch_deb => btn_debounce(i),
        rst    => rst,
        clk    => clk
      );
  end generate;

end architecture;