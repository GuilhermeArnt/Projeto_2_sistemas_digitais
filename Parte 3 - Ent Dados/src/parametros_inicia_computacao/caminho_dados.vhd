library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity caminho_dados is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    clr       : in  std_logic;
    en_mcando : in  std_logic;
    en_mcador : in  std_logic;
    ch_up     : in  std_logic;
    ch_down   : in  std_logic;
    mcando    : out std_logic_vector(7 downto 0);
    mcador    : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of caminho_dados is
  signal cnt_mcando : unsigned(7 downto 0);
  signal cnt_mcador : unsigned(7 downto 0);
begin

  -- Contador do multiplicando (mcando)
  process (clk, rst)
  begin
    if rst = '1' then
      cnt_mcando <= (others => '0');
    elsif rising_edge(clk) then
      if clr = '1' then
        cnt_mcando <= (others => '0');
      elsif en_mcando = '1' then
        if ch_up = '1' then
          cnt_mcando <= cnt_mcando + 1;
        elsif ch_down = '1' then
          cnt_mcando <= cnt_mcando - 1;
        end if;
      end if;
    end if;
  end process;

  -- Contador do multiplicador (mcador)
  process (clk, rst)
  begin
    if rst = '1' then
      cnt_mcador <= (others => '0');
    elsif rising_edge(clk) then
      if clr = '1' then
        cnt_mcador <= (others => '0');
      elsif en_mcador = '1' then
        if ch_up = '1' then
          cnt_mcador <= cnt_mcador + 1;
        elsif ch_down = '1' then
          cnt_mcador <= cnt_mcador - 1;
        end if;
      end if;
    end if;
  end process;

  mcando <= std_logic_vector(cnt_mcando);
  mcador <= std_logic_vector(cnt_mcador);

end architecture;