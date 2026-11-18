library ieee;
use ieee.std_logic_1164.all;

entity parametros_inicia_computacao is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    ch_up    : in  std_logic;
    ch_down  : in  std_logic;
    ch_sel   : in  std_logic;
    ch_start : in  std_logic;
    ready    : in  std_logic;
    done     : in  std_logic;
    mcando   : out std_logic_vector(7 downto 0);
    mcador   : out std_logic_vector(7 downto 0);
    selecao  : out std_logic_vector(1 downto 0);
    start    : out std_logic
  );
end entity;

architecture estrutural of parametros_inicia_computacao is
  signal en_mcando : std_logic;
  signal en_mcador : std_logic;
  signal clr       : std_logic;
begin

  inst_caminho_dados : entity work.caminho_dados
    port map (
      clk       => clk,
      rst       => rst,
      clr       => clr,
      en_mcando => en_mcando,
      en_mcador => en_mcador,
      ch_up     => ch_up,
      ch_down   => ch_down,
      mcando    => mcando,
      mcador    => mcador
    );

  inst_caminho_controle : entity work.caminho_controle
    port map (
      clk       => clk,
      rst       => rst,
      ch_sel    => ch_sel,
      ch_start  => ch_start,
      ready     => ready,
      done      => done,
      en_mcando => en_mcando,
      en_mcador => en_mcador,
      start     => start,
      clr       => clr
    );

  selecao <= en_mcador & en_mcando;

end architecture;