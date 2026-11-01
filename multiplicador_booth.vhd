library ieee;
use ieee.std_logic_1164.all;

entity multiplicador_booth is
  generic (
    n : integer := 8; -- número de bits do multiplicando e do multiplicador
    m : integer := 4 -- número de bits do contador de iterações
  );
  port (
    start : in std_logic; -- Pulso que inicia o processo de multiplicação (largura de 1 Tclk ou maior)
    ready : out std_logic; -- Se 1, o dispositivo está livre para uma nova computação
    done  : out std_logic; -- Gera um pulso de 1 Tclk indicando que a computação da multiplicação terminou
    A     : in std_logic_vector(n - 1 downto 0); -- multiplicando (com n bits)
    B     : in std_logic_vector(n - 1 downto 0); -- multiplicador (com n bits)
    P     : out std_logic_vector(2 * n - 1 downto 0); -- produto (com 2*n bits)
    clk   : in std_logic; -- sinal de relógio
    rst   : in std_logic -- sinal de reset assíncrono
  );
end entity;

architecture rtl of multiplicador_booth is
  -- Sinais internos para interconexão dos componentess
  signal s_clr_ld         : std_logic;
  signal s_ld_ph          : std_logic;
  signal s_des_en_counter : std_logic;
  signal s_done           : std_logic;
  signal s_iter           : std_logic_vector(m - 1 downto 0);

begin

-- Atribuição da saída done do sistema
  done <= s_done;

  -- Instância do Caminho de Controle
  dut_controle : entity work.multiplicador_booth_controle
    generic map(
      n => n,
      m => m
    )
    port map(
      start          => start,
      ready          => ready,
      done           => s_done,
      clr_ld         => s_clr_ld,
      iter           => s_iter,
      ld_ph          => s_ld_ph,
      des_en_counter => s_des_en_counter,
      clk            => clk,
      rst            => rst
    );

  -- Instância do Caminho de Dados (Datapath)
  dut_datapath : entity work.multiplicador_booth_datapath
    generic map(
      n => n,
      m => m
    )
    port map(
      A              => A,
      B              => B,
      P              => P,
      clr_ld         => s_clr_ld,
      iter           => s_iter,
      ld_ph          => s_ld_ph,
      des_en_counter => s_des_en_counter,
      done           => s_done,
      clk            => clk,
      rst            => rst
    );

end architecture;



















