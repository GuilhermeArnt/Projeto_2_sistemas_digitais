library ieee;
use ieee.std_logic_1164.all; -- Definições de sinais
use ieee.numeric_std.all; -- Conversões numéricas para testes

entity bin_to_bcd_tb is -- Entidade do Testbench (sem portas de E/S).
end entity bin_to_bcd_tb;

architecture behavioral of bin_to_bcd_tb is
  constant PERIOD         : time := 10 ns; -- Define o período do relógio (100 MHz).
  constant RESET_INTERVAL : time := PERIOD * 3; -- Define o tempo de aplicação do reset inicial.

  -- Configuração dos genéricos (16 bits de entrada -> 5 dígitos BCD)
  constant N_BITS   : integer := 16;
  constant N_DIGITS : integer := 5;

  -- Declaração dos sinais
  signal start      : std_logic; -- Sinal de start
  signal ready      : std_logic; -- Sinal para monitorizar se está pronto
  signal bits_in    : std_logic_vector(N_BITS - 1 downto 0) := (others => '0'); -- Entrada binária
  signal digits_out : std_logic_vector((N_DIGITS * 4) - 1 downto 0); -- Saída BCD gerada
  signal minus      : std_logic; -- Saída do sinal do número
  signal clk        : std_logic; -- Sinal do clock 
  signal rst        : std_logic; -- Sinal de reset 

begin

  -- Instancia a entidade a ser testada (UUT)
  UUT : entity work.bin_to_bcd
    generic map(
      N_BITS   => N_BITS,
      N_DIGITS => N_DIGITS
    )
    port map
    (
      bits_in    => bits_in,
      digits_out => digits_out,
      start      => start,
      ready      => ready,
      minus      => minus,
      clk        => clk,
      rst        => rst
    );

  -- Processo gerador da onda de relógio contínua (Oscilador)
  process
  begin
    clk <= '1'; -- Relógio em nível alto
    wait for PERIOD / 2; -- Espera metade do período
    clk <= '0'; -- Relógio em nível baixo
    wait for PERIOD / 2; -- Espera a outra metade do período
  end process;

  -- Geramos o pulso de reset
  rst <= '1', '0' after RESET_INTERVAL;
  -- Processo de aplicação dos vetores de teste (Estímulos)
  process
  begin
    start <= '0'; -- start está desabilitado inicialmente
    wait until rst = '0'; -- esperamos o reset ficar desabilitado
    wait for PERIOD * 3; -- aguarda mais 3 ciclos de relógio

    -- ===== Teste 1: Número negativo (-30000) =====
    wait until rising_edge(clk) and ready = '1'; -- Aguarda o circuito ficar pronto
    bits_in <= std_logic_vector(to_signed(-30000, N_BITS)); -- Atribui o valor -30000 em complemento para 2
    start   <= '1'; -- Pulsa o sinal de start
    wait until rising_edge(clk); -- Mantém o pulso por 1 ciclo de relógio
    start <= '0'; -- Abaixa o sinal de start

    -- Aguarda o término da conversão do Teste 1
    wait until rising_edge(clk) and ready = '1';

    -- ===== Teste 2: Número positivo (+12345) =====
    bits_in <= std_logic_vector(to_signed(12345, N_BITS)); -- Atribui o valor +12345 em complemento para 2
    start   <= '1'; -- Pulsa o sinal de start
    wait until rising_edge(clk); -- Aguarda a borda de subida do relógio
    start <= '0'; -- Finaliza o pulso do start

    -- Aguarda o término da conversão do Teste 2
    wait until rising_edge(clk) and ready = '1';

    wait; -- Finaliza a simulação
  end process;

end architecture behavioral;
