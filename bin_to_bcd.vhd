library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd is -- Entidade do Top-Level.
  generic (
    N_BITS   : positive := 8; -- Parâmetro genérico para o número de bits.
    N_DIGITS : positive := 3  -- Parâmetro genérico para o número de dígitos BCD.
  );
  port (
    bits_in    : in  std_logic_vector(N_BITS - 1 downto 0); -- Entrada do valor binário.
    digits_out : out std_logic_vector((N_DIGITS * 4) - 1 downto 0); -- Saída final dos dígitos BCD.
    minus      : out std_logic; -- Saída do indicador de sinal negativo.
    start      : in  std_logic; -- Entrada para disparar o processo.
    ready      : out std_logic; -- Pulso indicando que a computação terminou.
    clk        : in  std_logic; -- Sinal do relógio.
    rst        : in  std_logic  -- Sinal do reset assíncrono.
  );
end entity;

architecture structural of bin_to_bcd is

  signal ctrl_init      : std_logic;
  signal ctrl_check_add : std_logic;
  signal ctrl_shift     : std_logic;
  signal done_counting  : std_logic;
  signal done           : std_logic;

begin

  U1_bin_to_bcd_datapath : entity work.bin_to_bcd_datapath
    generic map (
      N_BITS   => N_BITS,
      N_DIGITS => N_DIGITS
    )
    port map (
      bits_in        => bits_in,
      digits_out     => digits_out,
      ctrl_init      => ctrl_init,
      ctrl_check_add => ctrl_check_add,
      ctrl_shift     => ctrl_shift,
      done_counting  => done_counting,
      minus          => minus,
      done           => done,
      clk            => clk,
      rst            => rst
    );

  bin_to_bcd_control_inst : entity work.bin_to_bcd_control
    generic map (
      N_BITS   => N_BITS,
      N_DIGITS => N_DIGITS
    )
    port map (
      start          => start,
      ready          => ready,
      ctrl_init      => ctrl_init,
      ctrl_check_add => ctrl_check_add,
      ctrl_shift     => ctrl_shift,
      done_counting  => done_counting,
      done           => done,
      clk            => clk,
      rst            => rst
    );

end architecture structural;