library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador_booth_tb is
end entity;

architecture multiplicador_booth_tb of multiplicador_booth_tb is
  component multiplicador_booth
    generic (
      n : integer;
      m : integer
    );
    port (
      start : in std_logic;
      ready : out std_logic;
      done  : out std_logic;
      A     : in std_logic_vector(n - 1 downto 0);
      B     : in std_logic_vector(n - 1 downto 0);
      P     : out std_logic_vector(2 * n - 1 downto 0);
      clk   : in std_logic;
      rst   : in std_logic
    );
  end component;

  constant n       : integer := 8;
  constant m       : integer := 4;
  constant PERIODO : time    := 10 ns;

  signal start : std_logic := '0';
  signal ready : std_logic;
  signal done  : std_logic;
  signal A     : std_logic_vector(n - 1 downto 0) := (others => '0');
  signal B     : std_logic_vector(n - 1 downto 0) := (others => '0');
  signal P     : std_logic_vector(2 * n - 1 downto 0);
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '0';

begin
  multiplicador_booth_inst : multiplicador_booth
  generic map(
    n => n,
    m => m
  )
  port map
  (
    start => start,
    ready => ready,
    done  => done,
    A     => A,
    B     => B,
    P     => P,
    clk   => clk,
    rst   => rst
  );

  -- Gerador de Clock
  process
  begin
    loop
      clk <= '1';
      wait for PERIODO / 2;
      clk <= '0';
      wait for PERIODO / 2;
    end loop;
  end process;

  -- Reset inicial
  rst <= '1', '0' after 30 ns;

  -- Processo de Estímulos
  process
  begin
    start <= '0';
    wait for 50 ns;

    for i in -128 to 127 loop
      for j in -128 to 127 loop
        A <= std_logic_vector(to_signed(i, n));
        B <= std_logic_vector(to_signed(j, n));
        wait for 10 ns;

        start <= '1';
        wait for PERIODO;
        start <= '0';

        -- Aguarda o término detetado na porta done
        wait until done = '1';
        wait for PERIODO;
      end loop;
    end loop;

    -- Paragem do processo após concluir os testes
    wait;
  end process;

end architecture;
