library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador_booth_controle is
  generic (
    n : integer := 8;
    m : integer := 4
  );
  port (
    start          : in std_logic;
    ready          : out std_logic;
    done           : out std_logic;
    clr_ld         : out std_logic;
    iter           : in std_logic_vector(m - 1 downto 0);
    ld_ph          : out std_logic;
    des_en_counter : out std_logic;
    clk            : in std_logic;
    rst            : in std_logic
  );
end entity;

architecture rtl of multiplicador_booth_controle is
  type estado is (INIT, S_START, LOAD, S0, S1, S2, S_DONE);

  signal estado_atual, proximo_estado : estado;

begin --begin da architecture

  memoria_estado : process (clk, rst)
  -- lista de sensibilidade deve ter o sinal de relógio e o sinal de reset
    begin
      if (rst = '1') then -- reset ativo coloca a máquina no estado inicial
        estado_atual <= INIT;
      elsif (rising_edge(clk)) then -- senão, atualiza o estado na borda de subida
        estado_atual <= proximo_estado;
      end if;
  end process memoria_estado;

  gera_proximo_estado : process (estado_atual, start, iter)
    begin 
      case estado_atual is 
        when INIT =>
          proximo_estado <= S_START;

        when S_START =>
          if start = '1' then
            proximo_estado <= LOAD;
          else
            proximo_estado <= S_START;
          end if;

        when LOAD =>
          proximo_estado <= S0;

        when S0 =>
          if unsigned(iter) = n then
            proximo_estado <= S_DONE;
          else
            proximo_estado <= S1;
          end if;

        when S1 =>
          proximo_estado <= S2;

        when S2 =>
          proximo_estado <= S0;

        when S_DONE =>
          proximo_estado <= S_START;

        when others =>
          proximo_estado <= INIT;
      end case;
  end process;
        
  gera_saida : process (estado_atual)
    begin

      ready <= '0';
      done <= '0';
      clr_ld <= '0';
      ld_ph <= '0';
      des_en_counter <= '0';

      case estado_atual is 
        when INIT =>
          null;

        when S_START =>
          ready <= '1';

        when LOAD =>
          clr_ld <= '1';

        when S0 =>
          null;

        when S1 =>
          ld_ph <= '1';

        when S2 =>
          des_en_counter <= '1';

        when S_DONE =>
          done <= '1';
      end case;
  end process;

end architecture;
