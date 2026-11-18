------------------------------------------------------------------------------------------------------------------------
-- Description: Circuito para eliminar o repique de chaves mecânicas. Foi realizada uma descrição usando o circuito 
-- apresentado no site www.digikey.com: https://www.digikey.com/eewiki/pages/viewpage.action?pageId=4980758. O tempo de 
-- repique da chave deve ser menor do que P, dado pela seguinte equação: P = (2^N+2)/fclk, onde N é o número de bits 
-- (flip-flops) do contador do circuito de debounce e fclk a frequência de relógio clk.
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity debounce is
  generic (
    counter_size  : integer := 20; -- número de bits do contador. Contagem de 0 até 1.048.575
    tempo_estavel : integer := 1_000_000 -- tempo em ciclos de relógio que o sinal é considerado estável: f_clk * T_bounce
  );
  port (
    ch     : in std_logic; -- sinal de entrada da chave mecânica
    ch_deb : out std_logic; -- sinal de saída sem o repique da chave
    rst    : in std_logic; -- reset assíncrono
    clk    : in std_logic -- sinal de relógio do sistema
  );
end entity;

architecture simples of debounce is
  signal reg_des           : std_logic_vector(1 downto 0); -- registrador de deslocamento
  signal contador          : unsigned(counter_size - 1 downto 0); -- contador binário 
  signal sinais_diferentes : std_logic;
  signal comparador        : std_logic;
begin

  -- porta xor
  sinais_diferentes <= reg_des(0) xor reg_des(1); -- '1' se freg_des(0) é diferente de reg_des(1)
  -- circuito comparador
  comparador <= '1' when contador = (tempo_estavel-3) else
    '0';
  process (clk, rst)

  begin
    if rst = '1' then -- se o sinal de reset está ativo
      reg_des  <= (others => '0'); -- colocamos a saída de todos os flip-flops em 0
      contador <= (others => '0'); --
      ch_deb   <= '0'; --
    elsif rising_edge(clk) then -- na borda de subida de clk
      reg_des <= reg_des(0) & ch; -- desloca o sinal de entrada
      if sinais_diferentes = '1' then -- se uma transição do sinal
        contador <= (others => '0'); -- zera o contador. Começa novamente a verificação em um intervalo de tempo
      else -- se o sinal está estável
        if comparador = '0' then -- se nào chegamos no final de um intervalo de tempo
          contador <= contador + 1; -- incrementamos o contador
        else -- se chegamos em um intervalo de tempo com o sinal estável
          ch_deb <= reg_des(1); -- guarda o sinal da saída 
        end if;
      end if;
    end if;
  end process;
end architecture;