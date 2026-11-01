library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bin_to_bcd_datapath is
  generic (
    N_BITS   : positive := 8; -- Número de bits da entrada binária.
    N_DIGITS : positive := 3 -- Número de dígitos BCD na saída.
  );
  port (
    bits_in        : in std_logic_vector(N_BITS - 1 downto 0); -- Entrada binária com sinal.
    digits_out     : out std_logic_vector((N_DIGITS * 4) - 1 downto 0); -- Saída com os dígitos BCD.
    ctrl_init      : in std_logic; -- Sinal de controle:inicialização.
    ctrl_check_add : in std_logic; -- Sinal de controle:checagem e soma.
    ctrl_shift     : in std_logic; -- Sinal de controle:deslocamento.
    done_counting  : out std_logic; -- Sinaliza que a contagem das iterações do algoritmo terminou.
    minus          : out std_logic; -- Indica se o número de entrada é negativo.
    done           : in std_logic; -- Sinal de controle:atualiza saídas no término.
    clk            : in std_logic; -- Entrada de relógio.
    rst            : in std_logic -- Entrada de reset assíncrono.
  );
end entity;

architecture behavior of bin_to_bcd_datapath is
  constant TOTAL_BITS : integer := (N_DIGITS * 4) + N_BITS;


begin



end architecture;
