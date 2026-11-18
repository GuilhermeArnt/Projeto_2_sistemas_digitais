library ieee;
use ieee.std_logic_1164.all;

entity gera_pulso_e_pulsos is
  port (
    x   : in std_logic;
    z   : out std_logic;
    clk : in std_logic;
    rst : in std_logic
  );
end entity;

architecture gera_pulso_e_pulsos of gera_pulso_e_pulsos is
  constant tempo_para_pulsos  : integer := 150_000_000;
  constant tempo_entre_pulsos : integer := 8_000_000;

  -- Define o range para evitar estouro em simuladores rigorosos como o GHDL
  signal count_tempo : integer range 0 to tempo_para_pulsos;
  signal clr         : std_logic;
  type estado is (S0, S1, S2, S3, S4);
  signal estado_atual, proximo_estado : estado;
begin

  -- Processo 1 (Síncrono): Transição de Estados e Contador
  process (clk, rst)
  begin
    if rst = '1' then
      estado_atual <= S0;
    elsif rising_edge(clk) then
      estado_atual <= proximo_estado;
    end if;
  end process;

  -- contador externo
  process (clk, rst)
  begin
    if rst = '1' then
      count_tempo <= 0;
    elsif rising_edge(clk) then
      if clr = '1' then
        count_tempo <= 0;
      else
        if count_tempo < tempo_para_pulsos then
          count_tempo <= count_tempo + 1;
        end if;
      end if;
    end if;
  end process;

  -- Processo 2 (Combinacional): Próximo Estado e Saída
  process (x, estado_atual, count_tempo)
  begin
    z              <= '0';
    clr            <= '0';
    proximo_estado <= estado_atual;

    case estado_atual is
      when S0 =>
        if x = '1' then
          proximo_estado <= S1;
        end if;

      when S1 =>
        z              <= '1';
        clr            <= '1';
        proximo_estado <= S2;

      when S2 =>
        if x = '0' then
          proximo_estado <= S0;
        elsif count_tempo >= tempo_para_pulsos - 2 then
          proximo_estado <= s3;
        end if;

      when S3 =>
        z              <= '1';
        clr            <= '1';
        proximo_estado <= S4;

      when S4 =>
        if x = '0' then
          proximo_estado <= S0;
        elsif count_tempo >= tempo_entre_pulsos - 2 then
          proximo_estado <= s3;
        end if;

      when others =>
        proximo_estado <= S0;
    end case;
  end process;

end architecture;