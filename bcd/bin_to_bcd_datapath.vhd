library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd_datapath is
    generic (
        N_BITS : integer := 16
    );
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        bits_in        : in  std_logic_vector(N_BITS - 1 downto 0);
        ctrl_init      : in  std_logic;
        ctrl_check_add : in  std_logic;
        ctrl_shift     : in  std_logic;
        done_counting  : out std_logic;
        minus          : out std_logic;
        digits_out     : out std_logic_vector(19 downto 0)
    );
end entity bin_to_bcd_datapath;

architecture rtl of bin_to_bcd_datapath is
    signal bin_reg        : unsigned(N_BITS - 1 downto 0);
    signal bcd_reg        : unsigned(19 downto 0);
    signal bit_count      : unsigned(4 downto 0);
    signal sign_reg       : std_logic;
    signal minus_reg      : std_logic;
    signal digits_out_reg : std_logic_vector(19 downto 0);
    signal done_cnt_int   : std_logic;
begin

    -- Sinaliza o fim das iterações quando bit_count atinge N_BITS - 1 (15)
    done_cnt_int  <= '1' when bit_count = to_unsigned(N_BITS - 1, bit_count'length) else '0';
    done_counting <= done_cnt_int;

    minus      <= minus_reg;
    digits_out <= digits_out_reg;

    process(clk, rst)
        variable bcd_shifted : unsigned(19 downto 0);
    begin
        if rst = '1' then
            bin_reg        <= (others => '0');
            bcd_reg        <= (others => '0');
            bit_count      <= (others => '0');
            sign_reg       <= '0';
            minus_reg      <= '0';
            digits_out_reg <= (others => '0');
        elsif rising_edge(clk) then
            if ctrl_init = '1' then
                -- Captura o sinal e converte complemento de 2 para magnitude
                sign_reg <= bits_in(N_BITS - 1);
                if bits_in(N_BITS - 1) = '1' then
                    bin_reg <= unsigned(-signed(bits_in));
                else
                    bin_reg <= unsigned(bits_in);
                end if;
                bcd_reg   <= (others => '0');
                bit_count <= (others => '0');

            elsif ctrl_check_add = '1' then
                -- Verifica cada dígito BCD (4 bits); se >= 5, soma 3
                for i in 0 to 4 loop
                    if bcd_reg(4*i + 3 downto 4*i) >= 5 then
                        bcd_reg(4*i + 3 downto 4*i) <= bcd_reg(4*i + 3 downto 4*i) + 3;
                    end if;
                end loop;

            elsif ctrl_shift = '1' then
                -- Desloca [bcd_reg, bin_reg] 1 bit à esquerda
                bcd_shifted := bcd_reg(18 downto 0) & bin_reg(N_BITS - 1);
                bcd_reg     <= bcd_shifted;
                bin_reg     <= bin_reg(N_BITS - 2 downto 0) & '0';
                bit_count   <= bit_count + 1;

                -- Atualiza as saídas registradas na última iteração (bit_count = 15 -> 16)
                if done_cnt_int = '1' then
                    digits_out_reg <= std_logic_vector(bcd_shifted);
                    minus_reg      <= sign_reg;
                end if;
            end if;
        end if;
    end process;

end architecture rtl;
