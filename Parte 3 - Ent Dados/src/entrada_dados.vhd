library ieee;
use ieee.std_logic_1164.all;

entity entrada_dados is
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    btn     : in  std_logic_vector(3 downto 0);
    ready   : in  std_logic;
    done    : in  std_logic;
    mcando  : out std_logic_vector(7 downto 0);
    mcador  : out std_logic_vector(7 downto 0);
    selecao : out std_logic_vector(1 downto 0);
    start   : out std_logic
  );
end entity;

architecture estrutural of entrada_dados is
  signal btn_processado : std_logic_vector(3 downto 0);
begin

  inst_processa_entradas : entity work.processa_entradas
    port map (
      btn            => btn,
      btn_processado => btn_processado,
      clk            => clk,
      rst            => rst
    );

  inst_parametros_inicia_computacao : entity work.parametros_inicia_computacao
    port map (
      clk      => clk,
      rst      => rst,
      ch_up    => btn_processado(0), -- btn_inc
      ch_down  => btn_processado(1), -- btn_dec
      ch_sel   => btn_processado(2), -- btn_sel
      ch_start => btn_processado(3), -- btn_start
      ready    => ready,
      done     => done,
      mcando   => mcando,
      mcador   => mcador,
      selecao  => selecao,
      start    => start
    );

end architecture;