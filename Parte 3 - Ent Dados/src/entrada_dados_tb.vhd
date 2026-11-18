library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_entrada_dados is
end entity;

architecture sim of tb_entrada_dados is
  constant T_CLK : time := 10 ns; -- 100 MHz

  signal clk     : std_logic := '0';
  signal rst     : std_logic := '1';
  signal btn     : std_logic_vector(3 downto 0) := (others => '0');
  signal ready   : std_logic := '1';
  signal done    : std_logic := '0';
  signal mcando  : std_logic_vector(7 downto 0);
  signal mcador  : std_logic_vector(7 downto 0);
  signal selecao : std_logic_vector(1 downto 0);
  signal start   : std_logic;
  signal fim_sim : boolean := false;

  -- Procedimento auxiliar para pressionar e soltar um botão (com tempo de debounce)
  procedure pressiona_botao(
    signal s_btn  : out std_logic_vector(3 downto 0);
    constant idx  : in integer;
    constant dur  : in time
  ) is
  begin
    s_btn(idx) <= '1';
    wait for dur;
    s_btn(idx) <= '0';
    wait for 20 * T_CLK;
  end procedure;

begin

  dut : entity work.entrada_dados
    port map (
      clk     => clk,
      rst     => rst,
      btn     => btn,
      ready   => ready,
      done    => done,
      mcando  => mcando,
      mcador  => mcador,
      selecao => selecao,
      start   => start
    );

  -- Gerador de clock
  clk <= not clk after T_CLK / 2 when not fim_sim else '0';

  -- Estímulos
  process
  begin
    -- Reset inicial
    rst <= '1';
    wait for 5 * T_CLK;
    rst <= '0';
    wait for 5 * T_CLK;

    -- 1. Incrementa mcando (selecao = "01") duas vezes (esperado: mcando = 2)
    pressiona_botao(btn, 0, 25 * T_CLK);
    pressiona_botao(btn, 0, 25 * T_CLK);

    -- 2. Alterna seleção para mcador (selecao = "10")
    pressiona_botao(btn, 2, 25 * T_CLK);

    -- 3. Decrementa mcador uma vez (esperado: mcador = -1)
    pressiona_botao(btn, 1, 25 * T_CLK);

    -- 4. Inicia multiplicação (btn_start = btn(3))
    pressiona_botao(btn, 3, 25 * T_CLK);

    -- Simula multiplicador de Booth ocupado após receber start
    wait until start = '1';
    wait for T_CLK;
    ready <= '0';
    wait for 15 * T_CLK;
    done  <= '1';
    ready <= '1';
    wait for T_CLK;
    done  <= '0';

    -- 5. Em S_PROD (selecao = "00"), pressiona btn_sel para voltar a S_SEL_A
    wait for 10 * T_CLK;
    pressiona_botao(btn, 2, 25 * T_CLK);

    wait for 20 * T_CLK;
    fim_sim <= true;
    wait;
  end process;

end architecture;