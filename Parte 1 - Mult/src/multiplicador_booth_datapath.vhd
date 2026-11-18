library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplicador_booth_datapath is
  generic (
    n : integer := 8;
    m : integer := 4
  );
  port (
    A              : in std_logic_vector(n - 1 downto 0);
    B              : in std_logic_vector(n - 1 downto 0);
    P              : out std_logic_vector(2 * n - 1 downto 0);
    clr_ld         : in std_logic;
    iter           : out std_logic_vector(m - 1 downto 0);
    ld_ph          : in std_logic;
    des_en_counter : in std_logic;
    done           : in std_logic;
    clk            : in std_logic;
    rst            : in std_logic
  );
end entity;

architecture rtl of multiplicador_booth_datapath is
  -- Registrador Mcando (n bits)
  signal mcando_reg : std_logic_vector(n - 1 downto 0);
  
  -- Registrador P contendo [PH (n bits) | PL (n bits) | P[0] (1 bit)] => Total 2*n + 1 bits
  signal p_reg : std_logic_vector(2*n+1 downto 0);
  
  --sinal para armazenar os bits para definição da operação na ALU
  signal sel_booth : std_logic_vector(1 downto 0);  

  -- Extensões de Sinal para a ALU (n+1 bits)
  signal ext_mcando : signed(n downto 0); --vai receber mcando, mas tem um bit a mais
  signal ext_ph     : signed(n downto 0); --vai receber ph, mas tem um bit a mais
  signal alu_out    : std_logic_vector(n downto 0); --saida da ALU
  
  -- Contador de iterações
  signal counter : unsigned(m - 1 downto 0);

begin

  sel_booth <= p_reg(1 downto 0); --seletor da operação em P[1:0]

  -- sinal de Mcando em signed
  ext_mcando <= signed(mcando_reg(n - 1) & mcando_reg);
  
  -- sinal de PH em signed
  ext_ph <= signed(p_reg(2 * n) & p_reg(2 * n downto n + 1));

  -- ALU: soma, subtrai ou mantém com base em P[1:0]
  ALU_process : process (ext_ph, ext_mcando, sel_booth)
    begin
      case sel_booth is
        when "10" => -- Subtrai multiplicando de PH
          alu_out <= std_logic_vector(ext_ph - ext_mcando);
        when "01" => -- Soma multiplicando a PH
          alu_out <= std_logic_vector(ext_ph + ext_mcando);
        when others => -- Nenhuma operação
          alu_out <= std_logic_vector(ext_ph);
      end case;
  end process;

  -- Registrador de Mcando
  MCANDO_process : process (clk, rst)
    begin
      if rst = '1' then
        mcando_reg <= (others => '0');
      elsif rising_edge(clk) then
        if clr_ld = '1' then
          mcando_reg <= A;
        end if;
      end if;
  end process;

  -- Contador de iterações
  Cont_process : process (clk, rst)
   begin
    if rst = '1' then
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if clr_ld = '1' then
        counter <= (others => '0');
      elsif des_en_counter = '1' then
        counter <= counter + 1;
      end if;
    end if;
  end process;

  --Saída das iterações que vai pro controle
  iter <= std_logic_vector(counter);

  -- Registrador P
  process (clk, rst)
   begin
    if rst = '1' then
      p_reg <= (others => '0');
    elsif rising_edge(clk) then
      if clr_ld = '1' then
        -- valores iniciais: PH = 0, PL = B, P[0] = '0' (BA)
        p_reg(2*n+1 downto n+1) <= (others => '0');
        p_reg(n downto 1)        <= B;
        p_reg(0)                 <= '0';
      elsif ld_ph = '1' then
        -- Atualiza PH com o resultado da ALU
        p_reg(2*n+1 downto n+1) <= std_logic_vector(alu_out(n downto 0));
      elsif des_en_counter = '1' then
        -- Deslocamento aritmético à direita em 1 bit mantendo o bit de sinal em 2*n
        p_reg <= p_reg(2*n+1) & p_reg(2*n+1 downto 1);
      end if;
    end if;
  end process;


  -- Registrador de Saída do Produto (atualizado quando done = '1')
  process (clk, rst)
  begin
    if rst = '1' then
      P <= (others => '0');
    elsif rising_edge(clk) then
      if done = '1' then
        P <= p_reg(2 * n downto 1);
      end if;
    end if;
  end process;

end architecture;

























