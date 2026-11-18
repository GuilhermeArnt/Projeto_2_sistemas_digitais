library ieee;
use ieee.std_logic_1164.all;

entity caminho_controle is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    ch_sel    : in  std_logic;
    ch_start  : in  std_logic;
    ready     : in  std_logic;
    done      : in  std_logic;
    en_mcando : out std_logic;
    en_mcador : out std_logic;
    start     : out std_logic;
    clr       : out std_logic
  );
end entity;

architecture fsm of caminho_controle is
  type estado is (S_INIT, S_SEL_A, S_SEL_B, S_ST_R, S_ST_S, S_ST_D, S_PROD);
  signal estado_atual, proximo_estado : estado;
begin

  -- Processo síncrono: registrador de estado
  process (clk, rst)
  begin
    if rst = '1' then
      estado_atual <= S_INIT;
    elsif rising_edge(clk) then
      estado_atual <= proximo_estado;
    end if;
  end process;

  -- Processo combinacional: próximo estado e saídas (Moore)
  process (estado_atual, ch_sel, ch_start, ready, done)
  begin
    en_mcando      <= '0';
    en_mcador      <= '0';
    start          <= '0';
    clr            <= '0';
    proximo_estado <= estado_atual;

    case estado_atual is
      when S_INIT =>
        clr            <= '1';
        proximo_estado <= S_SEL_A;

      when S_SEL_A =>
        en_mcando <= '1';
        if ch_start = '1' then
          proximo_estado <= S_ST_R;
        elsif ch_sel = '1' then
          proximo_estado <= S_SEL_B;
        end if;

      when S_SEL_B =>
        en_mcador <= '1';
        if ch_start = '1' then
          proximo_estado <= S_ST_R;
        elsif ch_sel = '1' then
          proximo_estado <= S_SEL_A;
        end if;

      when S_ST_R =>
        if ready = '1' then
          proximo_estado <= S_ST_S;
        end if;

      when S_ST_S =>
        start          <= '1';
        proximo_estado <= S_ST_D;

      when S_ST_D =>
        if done = '1' then
          proximo_estado <= S_PROD;
        end if;

      when S_PROD =>
        if ch_sel = '1' then
          proximo_estado <= S_SEL_A;
        end if;

      when others =>
        proximo_estado <= S_INIT;
    end case;
  end process;

end architecture;