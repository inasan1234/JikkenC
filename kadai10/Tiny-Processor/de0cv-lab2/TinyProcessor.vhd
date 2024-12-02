--------------------------------
--  TinyProcessor
--
--  2004/08/23 Keishi SAKANUSHI 
--  2011/11/10 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity TinyProcessor is
  port (
    clock     : in  std_logic;
    reset     : in  std_logic;
    DataIn    : in  std_logic_vector (7 downto 0);
    DataOut   : out std_logic_vector (7 downto 0);
    Address   : out std_logic_vector (15 downto 0);
    read      : out std_logic;
    write     : out std_logic;
    dbgIRout  : out std_logic_vector (7 downto 0);  -- added for debug on FPGA
    dbgZeroF  : out std_logic;                      -- added for debug on FPGA
    dbgCarryF : out std_logic;                      -- added for debug on FPGA
    dbgAout   : out std_logic_vector (7 downto 0);  -- added for debug on FPGA
    dbgBout   : out std_logic_vector (7 downto 0)   -- added for debug on FPGA
  );
end TinyProcessor;

architecture logic of TinyProcessor is
  component DataPath
    port (
    DataIn    : in  std_logic_vector (7 downto 0);
    selMuxDIn : in  std_logic;
    loadhMB   : in  std_logic;
    loadlMB   : in  std_logic;
    loadhIX   : in  std_logic;
    loadlIX   : in  std_logic;
    loadIR    : in  std_logic;
    loadIP    : in  std_logic;
    incIP     : in  std_logic;
    inc2IP    : in  std_logic;
    clearIP   : in  std_logic;
    selMuxAddr: in  std_logic;
    loadRegB  : in  std_logic;
    loadRegA  : in  std_logic;
    modeALU   : in  std_logic_vector (1 downto 0);
    loadFZ    : in  std_logic;
    clock     : in  std_logic;
    reset     : in  std_logic;
    IRout     : out std_logic_vector (7 downto 0);
    Address   : out std_logic_vector (15 downto 0);
    ZeroF     : out std_logic;
    CarryF    : out std_logic;
    DataOut   : out std_logic_vector (7 downto 0);
    Aout      : out std_logic_vector (7 downto 0); -- added for debug on FPGA
    Bout      : out std_logic_vector (7 downto 0)  -- added for debug on FPGA
    );
  end component;
  
  component Controler
    port (
    IRout     : in  std_logic_vector (7 downto 0);
    ZeroF     : in  std_logic;
    CarryF    : in  std_logic;
    clock     : in  std_logic;
    reset     : in  std_logic;
    selMuxDIn : out std_logic;
    loadhMB   : out std_logic;
    loadlMB   : out std_logic;
    loadhIX   : out std_logic;
    loadlIX   : out std_logic;
    loadIR    : out std_logic;
    loadIP    : out std_logic;
    incIP     : out std_logic;
    inc2IP    : out std_logic;
    clearIP   : out std_logic;
    selMuxAddr: out std_logic;
    loadRegB  : out std_logic;
    loadRegA  : out std_logic;
    modeALU   : out std_logic_vector (1 downto 0);
    loadFZ    : out std_logic;
    read      : out std_logic;
    write     : out std_logic
    );
  end component;

signal    selMuxDIn : std_logic;
signal    loadhMB   : std_logic;
signal    loadlMB   : std_logic;
signal    loadhIX   : std_logic;
signal    loadlIX   : std_logic;
signal    loadIR    : std_logic;
signal    IRout     : std_logic_vector (7 downto 0);
signal    loadIP    : std_logic;
signal    incIP     : std_logic;
signal    inc2IP    : std_logic;
signal    clearIP   : std_logic;
signal    selMuxAddr: std_logic;
signal    ZeroF     : std_logic;
signal    CarryF    : std_logic;
signal    loadRegB  : std_logic;
signal    loadRegA  : std_logic;
signal    modeALU   : std_logic_vector (1 downto 0);
signal    loadFZ    : std_logic;

begin    -- logic

path : DataPath
  port map(
    DataIn    => DataIn,
    selMuxDIn => selMuxDIn,
    loadhMB   => loadhMB,
    loadlMB   => loadlMB,
    loadhIX   => loadhIX,
    loadlIX   => loadlIX,
    loadIR    => loadIR,
    IRout     => IRout,
    loadIP    => loadIP,
    incIP     => incIP,
    inc2IP    => inc2IP,
    clearIP   => clearIP,
    selMuxAddr=> selMuxAddr,
    Address   => Address,
    ZeroF     => ZeroF,
    CarryF    => CarryF,
    DataOut   => DataOut,
    loadRegA  => loadRegA,
    loadRegB  => loadRegB,
    modeALU   => modeALU,
    loadFZ    => loadFZ,
    clock     => clock,
    reset     => reset,
    Aout      => dbgAout,   -- added for debug on FPGA
    Bout      => dbgBout    -- added for debug on FPGA
  );

ctrl : Controler
  port map(
    selMuxDIn => selMuxDIn,
    loadhMB   => loadhMB,
    loadlMB   => loadlMB,
    loadhIX   => loadhIX,
    loadlIX   => loadlIX,
    loadIR    => loadIR,
    IRout     => IRout,
    loadIP    => loadIP,
    incIP     => incIP,
    inc2IP    => inc2IP,
    clearIP   => clearIP,
    selMuxAddr=> selMuxAddr,
    ZeroF     => ZeroF,
    CarryF    => CarryF,
    loadRegA  => loadRegA,
    loadRegB  => loadRegB,
    modeALU   => modeALU,
    loadFZ    => loadFZ,
    clock     => clock,
    reset     => reset,
    read      => read,
    write     => write
  );

dbgIRout <= IRout;      -- added for debug on FPGA
dbgZeroF <= ZeroF;      -- added for debug on FPGA
dbgCarryF <= CarryF;    -- added for debug on FPGA

end logic;
