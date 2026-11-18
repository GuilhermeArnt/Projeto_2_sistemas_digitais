library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity selecao_fonte is
  port (
    mcando  : in  std_logic_vector(7 downto 0);
    mcador  : in  std_logic_vector(7 downto 0);
    prod    : in  std_logic_vector(15 downto 0);
    selecao : in  std_logic_vector(1 downto 0);
    saida   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture comb of selecao_fonte is
  signal mcando_ext, mcador_ext : std_logic_vector(15 downto 0);
begin
  mcando_ext <= std_logic_vector(resize(signed(mcando), 16));
  mcador_ext <= std_logic_vector(resize(signed(mcador), 16));

  with selecao select
    saida <= mcando_ext when "10",
             mcador_ext when "01",
             prod       when others; -- "00" ou "11"
end architecture;