--------------------------------
--  Interface between FPGA and CPU
--
--  2011/11/11 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity CPUCircuit is
  port (
    -- MemData    : inout std_logic_vector (7 downto 0);  -- Memory (data)
    -- MemWrite   : out   std_logic;                      -- Memory (write)
    -- MemAddr    : out   std_logic_vector (15 downto 0); -- Memory (address)
    -- MemRead    : out   std_logic;                      -- Memory (read)
    -- MemCS      : out   std_logic;                      -- Memory (cs)
    -- ROMData    : in    std_logic_vector(7 downto 0);   -- ROM (data)
    -- ROMAddr    : out   std_logic_vector(15 downto 0);  -- ROM (address)
    -- ROMRead    : out   std_logic;                      -- ROM (read)
    -- ROMCS      : out   std_logic;                      -- ROM (cs)
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
end CPUCircuit;

architecture logic of CPUCircuit is

  component CProcessor
    port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    DataIn    : in  std_logic_vector (7 downto 0);
    DataOut   : out std_logic_vector (7 downto 0);
    Address   : out std_logic_vector (15 downto 0);
    read      : out std_logic;
    write     : out std_logic;
    dbgIRout  : out std_logic_vector (7 downto 0);
    dbgZeroF  : out std_logic;
    dbgCarryF : out std_logic;
    dbgAout   : out std_logic_vector (7 downto 0);
    dbgBout   : out std_logic_vector (7 downto 0)
    );
  end component;
  component ccmux4x08 is
    port (
      sel : in  std_logic_vector(1 downto 0);
      a   : in  std_logic_vector(7 downto 0);
      b   : in  std_logic_vector(7 downto 0);
      c   : in  std_logic_vector(7 downto 0);
      d   : in  std_logic_vector(7 downto 0);
      q   : out std_logic_vector(7 downto 0)
      );
  end component;

  component ccmux4x16
    port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
    );
  end component;

  component DecSeg is
    port (
      data  : in  std_logic_vector(3 downto 0);
      seg   : out std_logic_vector(6 downto 0)
    );
  end component;

  component InCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
  end component;

  component KEYEnc4 is
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    keyin   : in std_logic_vector(3 downto 0);
    keyout  : out std_logic_vector(3 downto 0)
  );
  end component;

  component rom1p is
    port(
  		address		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
  		clock		: IN STD_LOGIC;
  		rden		: IN STD_LOGIC;
  		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
  end component;

  component ram1p is
    port(
      address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
  		clock		: IN STD_LOGIC;
  		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
  		rden		: IN STD_LOGIC;
  		wren		: IN STD_LOGIC;
  		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
  end component;

  component MCtrl is
  port (
    address  : in    std_logic_vector(15 downto 0);
    dataout  : in    std_logic_vector(7 downto 0);
    datain   : out   std_logic_vector(7 downto 0);
    read     : in    std_logic;
    write    : in    std_logic;
    RAMAddr  : out   std_logic_vector(15 downto 0);
    RAMDataTo  : out std_logic_vector(7 downto 0);
    RAMDataFrom  : in std_logic_vector(7 downto 0);
    RAMRead  : out   std_logic;
    RAMWrite : out   std_logic;
    RAMCS    : out   std_logic;
    ROMAddr  : out   std_logic_vector(15 downto 0);
    ROMData  : in    std_logic_vector(7 downto 0);
    ROMRead  : out   std_logic;
    ROMCS    : out   std_logic
  );
  end component;

  component Clock50 is
    port(
  		clock	: in 	std_logic;
  		c50	: out	std_logic;
  		reset	: in	std_logic
      );
  end component;

  component ClockDelay is
    port(
  		clock	: in 	std_logic;
  		clkout: out	std_logic;
  		rate	: in	std_logic_vector(31 downto 0);
  		reset	: in	std_logic
      );
  end component;

signal    sigDataIn       : std_logic_vector(7 downto 0);
signal    sigDataOut      : std_logic_vector(7 downto 0);
signal    sigAddress      : std_logic_vector(15 downto 0);
signal    sigread         : std_logic;
signal    sigwrite        : std_logic;
signal    cpu_reset    : std_logic;
signal    sigdbgIRout     : std_logic_vector(7 downto 0);
signal    sigdbgAout      : std_logic_vector(7 downto 0);
signal    sigdbgBout      : std_logic_vector(7 downto 0);
signal    qInputCtrl   : std_logic_vector(1 downto 0);
signal    MemCtrlDIn   : std_logic_vector(7 downto 0);
signal    zero16       : std_logic_vector(15 downto 0);
signal    zero         : std_logic;

signal    sig_key : std_logic_vector(3 downto 0);
signal    sig_segout : std_logic_vector(15 downto 0);
signal    clkdelayout : std_logic;
signal    clkdelayrate : std_logic_vector(31 downto 0);
signal    clkdelayreset : std_logic;
signal    dc	: std_logic;
signal    dcreset: std_logic;

signal    sigRAMAddr : std_logic_vector(15 downto 0);
signal    sigRAMData : std_logic_vector(7 downto 0);
signal    sigRAMInData : std_logic_vector(7 downto 0);
signal    sigRAMOutData : std_logic_vector(7 downto 0);
signal    sigRAMRead : std_logic;
signal    sigRAMWrite: std_logic;
signal    sigRAMCS   : std_logic;
signal    sigROMAddr : std_logic_vector(15 downto 0);
signal    sigROMData : std_logic_vector(7 downto 0);
signal    sigROMRead : std_logic;
signal    sigROMCS   : std_logic;


begin    -- logic

zero <= '0';
zero16 <= x"0000";
-- sig_key(7 downto 4) <=x"0000";

cpu_reset <=  not RESET_N;

Processor : CProcessor
  port map(
    clock     => clkdelayout,
    reset     => cpu_reset,
    DataIn    => sigDataIn,
    DataOut   => sigDataOut,
    Address   => sigAddress,
    read      => sigread,
    write     => sigwrite,
    dbgIRout  => sigdbgIRout,
    dbgZeroF  => LEDR(0),
    dbgCarryF => LEDR(1),
    dbgAout   => sigdbgAout,
    dbgBout   => sigdbgBout
  );

  SelInput : ccmux4x08
  port map (
    sel => qInputCtrl,
    a   => MemCtrlDIn,
    b(7 downto 4)   => "0000",
    b(3 downto 0)   => sig_key(3 downto 0),
    c   => SW(7 downto 0),
    d   => "00000000",
    q   => sigDataIn
  );

  SelOutput : ccmux4x16
  port map (
    sel            => SW(9 downto 8),
    a              => sigAddress,
    b(7 downto 0)  => sigDataOut,
    b(15 downto 8) => sigdbgIRout,
    c(7 downto 0)  => sigdbgBout,
    c(15 downto 8) => sigdbgAout,
    d              => zero16,   -- not used
    q              => sig_segout
  );

  DecHEX0 : DecSeg
    port map (
      data => sig_segout(3 downto 0),
      seg  => HEX0
    );
  DecHEX1 : DecSeg
    port map (
      data => sig_segout(7 downto 4),
      seg  => HEX1
    );
  DecHEX2 : DecSeg
    port map (
      data => sig_segout(11 downto 8),
      seg  => HEX2
    );
  DecHEX3 : DecSeg
    port map (
      data => sig_segout(15 downto 12),
      seg  => HEX3
    );
  DecHEX4 : DecSeg
    port map (
      data => sigAddress(3 downto 0),
      seg  => HEX4
    );
  DecHEX5 : DecSeg
    port map (
      data => sigAddress(7 downto 4),
      seg  => HEX5
    );

InputCtrl : InCtrl
  port map (
    address => sigAddress,
    sel     => qInputCtrl
  );

keyenc : KEYEnc4
  port map (
    clock => CLOCK_50,
    reset => RESET_N,
    keyin => KEY,
    keyout => sig_key
  );
rom : rom1p
  port map(
    address => sigROMAddr(9 downto 0),
    clock => CLOCK_50,
    rden => sigROMRead,
    q => sigROMData
  );
ram : ram1p
  port map(
    address => sigRAMAddr(7 downto 0),
    clock => CLOCK_50,
    data => sigRAMInData,
    rden => sigRAMRead,
    wren => sigRAMWrite,
    q => sigRAMOutData
  );
MemCtrl : MCtrl
  port map (
    address  => sigAddress,
    dataout  => sigDataOut,
    datain   => MemCtrlDIn,
    read     => sigread,
    write    => sigwrite,
    RAMAddr  => sigRAMAddr,
    RAMDataTo  => sigRAMInData,
    RAMDataFrom  => sigRAMOutData,
    RAMRead  => sigRAMRead,
    RAMWrite => sigRAMWrite,
    RAMCS    => sigRAMCS,
    ROMAddr  => sigROMAddr,
    ROMData  => sigROMData,
    ROMRead  => sigROMRead,
    ROMCS    => sigROMCS
  );
  CLK50 : Clock50
  	port map (
  		clock => CLOCK_50,
  		c50 => dc,
  		reset => RESET_N
  	);

  CLKD : ClockDelay
  	port map (
  		clock => CLOCK_50,
  		clkout => clkdelayout,
  		reset => RESET_N,
  		rate => clkdelayrate
  	);

-- ROMReset <= not RESET_N;
-- clkdelayrate <= x"017D7840";
clkdelayrate <= x"00000002";
LEDR(9) <= dc;
end logic;

--------------------------------
-- 4 bit KEYS Encorder (for chattering)
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity KEYEnc4 is
  port (
    clock  : in std_logic;
    reset  : in std_logic;
    keyin   : in std_logic_vector(3 downto 0);
    keyout  : out std_logic_vector(3 downto 0)
  );
end KEYEnc4;

architecture rtl of KEYEnc4 is

signal clock_count  : std_logic_vector(3 downto 0);
signal keyin_buf     : std_logic_vector(3 downto 0);
signal keyout_buf    : std_logic_vector(3 downto 0);

begin
  process (clock, reset)
  begin
    if (reset = '0') then
      clock_count <= "0000";
      keyin_buf <= "0000";
      keyout_buf <= "0000";

    elsif (clock'event and clock = '1') then

      if (clock_count = "1111") then
        keyout_buf <= keyin_buf;
        keyin_buf <= keyin;
      elsif (keyin_buf = keyin) then
        keyout_buf <= keyout_buf;
        keyin_buf <= keyin;
        clock_count <= clock_count + 1;
      else
        keyout_buf <= keyout_buf;
        keyin_buf <= keyin;
        clock_count <= "0000";
      end if;
    end if;
  end process;

  keyout <= not keyout_buf;  -- changing it positive. keys are low when depressed

end rtl;

--------------------------------
-- 8bit Multiplexer in 4
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ccmux4x08 is
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(7 downto 0);
    b   : in  std_logic_vector(7 downto 0);
    c   : in  std_logic_vector(7 downto 0);
    d   : in  std_logic_vector(7 downto 0);
    q   : out std_logic_vector(7 downto 0)
  );
end ccmux4x08;

architecture logic of ccmux4x08 is
begin
  q <= a when sel = "00" else
       b when sel = "01" else
       c when sel = "10" else
       d;
end logic;
--------------------------------
-- 16bit Multiplexer in 4
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity ccmux4x16 is
  port (
    sel : in  std_logic_vector(1 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    c   : in  std_logic_vector(15 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end ccmux4x16;

architecture logic of ccmux4x16 is
begin
  q <= a when sel = "00" else
       b when sel = "01" else
       c when sel = "10" else
       d;
end logic;
--------------------------------
-- 4bit 6Seg Decoder
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity DecSeg is
  port (
    data  : in  std_logic_vector(3 downto 0);
    seg   : out std_logic_vector(6 downto 0)
  );
end DecSeg;

architecture rtl of DecSeg is

begin
  process(data)
  begin
    case data is
      when "0000" =>seg<= "1000000"  ;--0
      when "0001" =>seg<= "1111001"  ;--1
      when "0010" =>seg<= "0100100"  ;--2
      when "0011" =>seg<= "0110000"  ;--3
      when "0100" =>seg<= "0011001"  ;--4
      when "0101" =>seg<= "0010010"  ;--5
      when "0110" =>seg<= "0000010"  ;--6
      when "0111" =>seg<= "1011000"  ;--7
      when "1000" =>seg<= "0000000"  ;--8
      when "1001" =>seg<= "0010000"  ;--9
      when "1010" =>seg<= "0001000"  ;--A
      when "1011" =>seg<= "0000011"  ;--b
      when "1100" =>seg<= "0100111"  ;--c
      when "1101" =>seg<= "0100001"  ;--d
      when "1110" =>seg<= "0000110"  ;--e
      when "1111" =>seg<= "0001110"  ;--f
      when others =>seg<= "1111111"  ;--off
    end case;
  end process;
end rtl;
--------------------------------
-- Inuput Control
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity InCtrl is
  port (
    address : in  std_logic_vector(15 downto 0);
    sel     : out std_logic_vector(1 downto 0)
  );
end InCtrl;

architecture logic of InCtrl is
begin
  sel <= "01" when address = x"FFFE" else -- KEY FFFE
         "10" when address = x"FFFF" else -- SW  FFFF
         "00";
end logic;


--------------------------------
-- Memory Control
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity MCtrl is
  port (
    address  : in    std_logic_vector(15 downto 0);
    dataout  : in    std_logic_vector(7 downto 0);
    datain   : out   std_logic_vector(7 downto 0);
    read     : in    std_logic;
    write    : in    std_logic;
    RAMAddr  : out   std_logic_vector(15 downto 0);
    RAMDataTo  : out std_logic_vector(7 downto 0);
    RAMDataFrom  : in std_logic_vector(7 downto 0);
    RAMRead  : out   std_logic;
    RAMWrite : out   std_logic;
    RAMCS    : out   std_logic;
    ROMAddr  : out   std_logic_vector(15 downto 0);
    ROMData  : in    std_logic_vector(7 downto 0);
    ROMRead  : out   std_logic;
    ROMCS    : out   std_logic
  );
end MCtrl;

architecture rtl of MCtrl is
begin
  ROMAddr <= address;
  ROMRead <= not read;
  ROMCS <= '1' when address(15) = '0' else
           '0';
  RAMAddr <= address;
  RAMRead <= not read;
  RAMWrite <= not write;
  RAMCS <= '1' when address(15 downto 14) = "10" else
           '0';

  RAMDataTo <= dataout when (address(15 downto 14) = "10" and write = '0') else "ZZZZZZZZ";

  datain <= ROMData when address(15) = '0' else
            RAMDataFrom when (address(15 downto 14) = "10" and read = '0') else
            "ZZZZZZZZ";
end rtl;
--------------------------------
-- clock 50MHz / 1000000
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Clock50 is
  port(
    clock  :in   std_logic;
    reset  :in   std_logic;
    c50  :out  std_logic
    );
end Clock50;

architecture rtl of Clock50 is
signal count: integer:=1;
signal tmp : std_logic := '0';

begin
  process(clock,reset)
  begin
    if(clock'event and clock='1') then
      count <=count+1;
      if (count = 999999) then
        tmp <= NOT tmp;
        count <= 1;
      end if;
    end if;
    c50 <= tmp;
  end process;
end rtl;

--------------------------------
-- clock 50MHz / rate
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity ClockDelay is
  port(
    clock  :in   std_logic;
    reset  :in   std_logic;
    rate  :in  std_logic_vector(31 downto 0);
    clkout:out  std_logic
    );
end ClockDelay;

architecture rtl of ClockDelay is
signal count: integer range 0 to 50000000:=1;
signal tmp : std_logic := '0';

begin
  process(clock,reset)
  begin
    if(clock'event and clock='1') then
      count <=count+1;
      if (count = rate) then
        tmp <= NOT tmp;
        count <= 1;
      end if;
    end if;
  end process;

  clkout <= tmp;
end rtl;
