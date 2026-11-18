library ieee;
use ieee.std_logic_1164.all;

entity gera_pulso is
  port (
    x   : in std_logic;
    z   : out std_logic;
    clk : in std_logic;
    rst : in std_logic
  );
end entity;

architecture gera_pulso of gera_pulso is
  type estado is (S0, S1, S2);
  signal estado_atual   : estado;
  signal proximo_estado : estado;
begin

  process (clk, rst)
  begin
    if rst = '1' then
      estado_atual <= S0;
    elsif rising_edge(clk) then
      estado_atual <= proximo_estado;
    end if;
  end process;
  process (estado_atual, x)
  begin
    z              <= '0';
    proximo_estado <= estado_atual;
    case estado_atual is
      when S0 =>
        if x = '1' then
          proximo_estado <= S1;
        end if;
      when S1 =>
        z <= '1';
        if x = '1' then
          proximo_estado <= S2;
        else
          proximo_estado <= S0;
        end if;
      when S2 =>
        if x = '0' then
          proximo_estado <= S0;
        end if;
    end case;
  end process;
end architecture;