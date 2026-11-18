library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_display_leds_controle is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    ready     : in  std_logic;
    done      : in  std_logic;
    done_contador_digito : in  std_logic;
    done_contador_tempo : in  std_logic;
    en_contador_digito : out  std_logic;
    en_contador_tempo : out  std_logic;
    init_contador_digito : out  std_logic;
    init_contador_tempo : out  std_logic;
    start : out std_logic
  );
end entity;

architecture fsm of controle_display_leds_controle is
  type estado is (S0, S1, S2, S3, S4, S5, S6);
  signal estado_atual, proximo_estado : estado;
begin

  -- Processo síncrono: registrador de estado
  process (clk, rst)
  begin
    if rst = '1' then
      estado_atual <= S0;
    elsif rising_edge(clk) then
      estado_atual <= proximo_estado;
    end if;
  end process;

  -- Processo combinacional: próximo estado e saídas (Moore)
  process (estado_atual, ready, done, done_contador_digito, done_contador_tempo)
  begin
    en_contador_digito <= '0';
    en_contador_tempo <= '0';
    init_contador_digito <= '0';
    init_contador_tempo <= '0';
    start <= '0';

    case estado_atual is
      when S0 =>
        if ready = '1' then proximo_estado <= S1;
        else proximo_estado <= S0;
	end if;

      when S1 =>
        start <= '1';
        proximo_estado <= S2;

      when S2 =>
        if done = '1' then  proximo_estado <= S3;
        else  proximo_estado <= S2;
        end if;

      when S3 =>
        proximo_estado <= S4;
        init_contador_digito <= '1';

      when S4 =>
        init_contador_tempo <= '1';
        en_contador_digito <= '1';
        proximo_estado <= S5;

      when S5 =>
	en_contador_tempo <= '1';
        if done_contador_tempo = '1' then proximo_estado <= S6;
        else proximo_estado <= S5;
        end if;

      when S6 =>
        if done_contador_digito = '1' then proximo_estado <= S0;
        else proximo_estado <= S4;
        end if;

      when others =>
        proximo_estado <= S0;
    end case;
  end process;

end architecture;
