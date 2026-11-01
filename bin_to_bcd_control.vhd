library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd_control is
  generic (
    N_BITS   : positive := 16; -- Número de bits do número binário de entrada.
    N_DIGITS : positive := 4 -- Número de dígitos BCD
  );
  port (
    start          : in std_logic; -- Sinal para iniciar a conversão.
    ready          : out std_logic; -- Indica que a FSM está pronta para um novo início.
    ctrl_init      : out std_logic; -- Inicializa os registradores.
    ctrl_check_add : out std_logic; -- Executar a verificação e soma de +3.
    ctrl_shift     : out std_logic; -- Efetua o deslocamento (shift).
    done_counting  : in std_logic; -- Indica que o número de iterações do algorítimo terminou.
    done           : out std_logic; -- Pulso que indica a conclusão da conversão.
    clk            : in std_logic; -- Sinal de relógio (clock).
    rst            : in std_logic -- Sinal de reset assíncrono.
  );
end entity;

architecture behavior of bin_to_bcd_control is
  type estado is (ST_IDLE, ST_INIT, ST_CHECK_ADD, ST_SHIFT, ST_DONE);

  signal estado_atual, proximo_estado : estado;
  
begin

  memoria_estado : process (clk, rst)
  -- lista de sensibilidade deve ter o sinal de relógio e o sinal de reset
    begin
      if (rst = '1') then -- reset ativo coloca a máquina no estado inicial
        estado_atual <= ST_IDLE;
      elsif (rising_edge(clk)) then -- senão, atualiza o estado na borda de subida
        estado_atual <= proximo_estado;
      end if;
  end process memoria_estado;


-- Controle do proximo estado
  gera_proximo_estado : process (estado_atual, start, iter)
    begin 
      case estado_atual is 
        when ST_IDLE =>
          if start = '1' then
            proximo_estado <= ST_INIT;
          else
            proximo_estado <= ST_IDLE;
          end if;

        when ST_INIT =>
          proximo_estado <= ST_CHECK_ADD;

        when ST_CHECK_ADD =>
          proximo_estado <= ST_SHIFT;

        when ST_SHIFT =>
          if done_counting = '1' then
            proximo_estado <= ST_DONE;
          else
            proximo_estado <= ST_CHECK_ADD;
          end if;

        when ST_DONE =>
          proximo_estado <= ST_IDLE;

      end case;
  end process;

-- Controle das saídas de cada estado

  gera_saida : process (estado_atual)
    begin 
      ready <= '0';
      done <= '0';
      ctrl_init <= '0';
      ctrl_check_add <= '0';
      ctrl_shift <= '0';
      
      case estado_atual is 
        when ST_IDLE =>
          ready <= '1';

        when ST_INIT =>
          ctrl_init <= '1';

        when ST_CHECK_ADD =>
          ctrl_check_add <= '1';

        when ST_SHIFT =>
          ctrl_shift <= '1';

        when ST_DONE =>
          done <= '1';

      end case;
  end process;

end architecture behavior;
