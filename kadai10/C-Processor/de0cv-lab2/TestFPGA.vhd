--------------------------------
--  Testbench for All Circuit
--
--  RAM �� 8000-8004�܂Ŏg����
--
--  2011/11/11 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity TestFPGA is
  port (
    LEDR        : out std_logic_vector(9 downto 0);   -- LED
    HEX0        : out std_logic_vector(6 downto 0);
    HEX1        : out std_logic_vector(6 downto 0);
    HEX2        : out std_logic_vector(6 downto 0);
    HEX3        : out std_logic_vector(6 downto 0);
    HEX4        : out std_logic_vector(6 downto 0);
    HEX5        : out std_logic_vector(6 downto 0)
  );
end TestFPGA;

architecture behavior of TestFPGA is

  component CPUCircuit
  port (
    -- MemData    : inout std_logic_vector (7 downto 0);  -- Memory (data)
    -- MemWrite   : out   std_logic;                      -- Memory (write)
    -- MemAddr    : out   std_logic_vector (15 downto 0); -- Memory (address)
    -- MemRead    : out   std_logic;                      -- Memory (read)
    -- MemCS      : out   std_logic;                      -- Memory (cs)
    -- ROMData    : in    std_logic_vector(7 downto 0);   -- ROM (data)
    -- ROMAddr    : out   std_logic_vector(15 downto 0);  -- ROM (address)
    -- ROMCS      : out   std_logic;                      -- ROM (cs)
    -- ROMRead    : out   std_logic;                      -- ROM (read)
    -- ROMReset   : out   std_logic;                      -- ROM (reset)
    HEX0        : out std_logic_vector(6 downto 0);
    HEX1        : out std_logic_vector(6 downto 0);
    HEX2        : out std_logic_vector(6 downto 0);
    HEX3        : out std_logic_vector(6 downto 0);
    HEX4        : out std_logic_vector(6 downto 0);
    HEX5        : out std_logic_vector(6 downto 0);
    KEY         : in std_logic_vector(3 downto 0);
    LEDR        : out std_logic_vector(9 downto 0);
    SW          : in std_logic_Vector(9 downto 0);
    RESET_N     : in std_logic;
    CLOCK_50    : in std_logic;
    CLOCK2_50   : in std_logic;
    CLOCK3_50   : in std_logic;
    CLOCK4_50   : in std_logic
  );
  end component;

  -- constant
  constant clk_cycle : time := 10 ns;   -- frequency 100 MHz

  -- signal
  signal clock    : std_logic;
  signal reset    : std_logic;
  signal sig_key  : std_logic_vector(3 downto 0);
  signal sig_sw   : std_logic_vector(9 downto 0);
  signal memdata  : std_logic_vector(7 downto 0);
  signal memaddr  : std_logic_vector(15 downto 0);
  signal memread  : std_logic;
  signal memwrite : std_logic;
  signal memcs    : std_logic;
  signal romdata  : std_logic_vector(7 downto 0);
  signal romaddr  : std_logic_vector(15 downto 0);
  signal romread  : std_logic;
  signal romcs    : std_logic;
  signal romreset : std_logic;

begin

  FPGA_CPUCircuit : CPUCircuit
  port map (
    -- MemData  => memdata,
    -- MemAddr  => memaddr,
    -- MemRead  => memread,
    -- MemWrite => memwrite,
    -- MemCS    => memcs,
    -- RomData  => romdata,
    -- RomAddr  => romaddr,
    -- RomRead  => romread,
    -- RomCS    => romcs,
    -- RomReset => romreset,
    LEDR      => LEDR,
    HEX0 => HEX0,
    HEX1 => HEX1,
    HEX2 => HEX2,
    HEX3 => HEX3,
    HEX4 => HEX4,
    HEX5 => HEX5,
    KEY  => sig_key,
    SW   => sig_sw,
    RESET_N => reset,
    CLOCK_50 => clock,
    CLOCK2_50 => clock,
    CLOCK3_50 => clock,
    CLOCK4_50 => clock
  );


  -- clock and reset

  process
  begin
    clock <= '1';
    wait for clk_cycle/2;
    clock <= '0';
    wait for clk_cycle/2;
  end process;

  -- reset <= '1',
  --          '0' after clk_cycle * 2;

  process
  begin
    reset <= '0';-- depressing the reset botton
    sig_key <= "0000";
    sig_sw <= "0000000011";
    wait for clk_cycle * 10;
    reset <= '1';-- release the reset botton
    -- wait for clk_cycle*100;
    -- reset <= '1';

    -- scenario begin

    wait for clk_cycle * 100;
    -- dip_a <= x"AB";
    sig_key <= "0001"; -- KEY0 is pushed

    wait for clk_cycle * 100;
    sig_key <= "0010"; -- KEY1 is pushed

    wait for clk_cycle * 500;
    -- scenario end

  end process;

end behavior;
