--------------------------------
-- DataPath of Tiny Processor
--
--  2004/08/23 Keishi SAKANUSHI 
--  2011/11/10 Yoshiaki TANIGUCHI
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity DataPath is
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
    Aout      : out std_logic_vector (7 downto 0);    -- added for debug on FPGA
    Bout      : out std_logic_vector (7 downto 0)     -- added for debug on FPGA
  );
end DataPath;

architecture logic of DataPath is
component Register01
  port (
    d     : in  std_logic;
    load  : in  std_logic;
    clock : in std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Register08
  port (
    d     : in  std_logic_vector(7 downto 0);
    load  : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(7 downto 0)
  );
end component; 

component Register16in2
  port (
    dH    : in  std_logic_vector(7 downto 0);
    dL    : in  std_logic_vector(7 downto 0);
    loadh : in  std_logic;
    loadl : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(15 downto 0)
  );
end component;
 
component ALU08
  port (
    a       : in  std_logic_vector(7 downto 0);
    b       : in  std_logic_vector(7 downto 0);
    cin     : in  std_logic;
    mode    : in  std_logic_vector(1 downto 0);
    fout    : out std_logic_vector(7 downto 0);
    cout    : out std_logic;
    zout    : out std_logic
  );
end component;

component Counter16
  port (
    clock : in  std_logic;
    load  : in  std_logic;
    d     : in  std_logic_vector(15 downto 0);
    inc   : in  std_logic;
    inc2  : in  std_logic;
    clear : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(15 downto 0)
  );
end component;

component mux2x08
   port (
    a   : in  std_logic_vector(7 downto 0);
    b   : in  std_logic_vector(7 downto 0);
    sel : in  std_logic;
    q   : out std_logic_vector(7 downto 0)
  );
end component;

component mux2x16
  port (
    a   : in  std_logic_vector(15 downto 0); 
    b   : in  std_logic_vector(15 downto 0);
    sel : in  std_logic;
    q   : out std_logic_vector(15 downto 0)
   );
end component;

signal qRegA      : std_logic_vector(7 downto 0);
signal qRegB      : std_logic_vector(7 downto 0);
signal qMB        : std_logic_vector(15 downto 0);
signal qIX        : std_logic_vector(15 downto 0);
signal qIP        : std_logic_vector(15 downto 0);
signal foutALU    : std_logic_vector(7 downto 0);
signal zoutALU    : std_logic;
signal DataInTmp  : std_logic_vector(7 downto 0);
signal zero       : std_logic;

begin
zero <= '0';

--------------------------------
-- Selector to Data Bus In
--------------------------------
MuxDIn : mux2x08
  port map (
    a   => foutALU,
    b   => DataIn,
    sel => selMuxDIn,
    q   => DataInTmp
  );


--------------------------------
-- Register A 
--------------------------------
RegA : Register08
  port map(
    d     => DataInTmp,
    load  => loadRegA,
    clock => clock,
    reset => reset,
    q     => qRegA
  );


--------------------------------
-- Register B
--------------------------------
RegB : Register08
  port map(
    d     => DataInTmp,
    load  => loadRegB,
    clock => clock,
    reset => reset,
    q     => qRegB
  );

--------------------------------
-- MB Register
--------------------------------
MB : Register16in2
  port map(
    dh    => DataIn,
    dl    => DataIn,
    loadh => loadhMB,
    loadl => loadlMB,
    clock => clock,
    reset => reset,
    q     => qMB
  );


--------------------------------
-- Index pointer
--------------------------------
IX : Register16in2 
  port map(
    dh    => DataIn,
    dl    => DataIn,
    loadh => loadhIX,
    loadl => loadlIX,
    clock => clock,
    reset => reset,
    q     => qIX
  );

--------------------------------
-- ALU
--------------------------------
ALU : ALU08
  port map(
    a       => qRegA,
    b       => qRegB,
    cin     => zero,
    mode    => modeALU,
    fout    => foutALU,
    cout    => CarryF,
    zout    => zoutALU
  );

--------------------------------
-- Instruction Pointer
--------------------------------
IP : Counter16
  port map(
    d     => qMB,
    inc   => incIP,
    inc2  => inc2IP,
    clear => clearIP,
    load  => loadIP,
    clock => clock,
    reset => reset,
    q     => qIP
  );

--------------------------------
-- Instruction Register
--------------------------------
IR : Register08
  port map(
    d     => DataIn,
    load  => loadIR,
    clock => clock,
    reset => reset,
    q     => IRout
  );

--------------------------------
-- Zero Flag
--------------------------------
FZ : Register01
  port map(
    d     => zoutALU,
    load  => loadFZ,
    clock => clock,
    reset => reset,
    q     => ZeroF
  );

--------------------------------
-- Selector to Address bus
--------------------------------
MuxAddr : Mux2x16 
  port map (
    a   => qIP,
    b   => qIX,
    sel => selMuxAddr,
    q   => Address
  );
  
DataOut <= qRegA;
Aout <= qRegA;  -- added for debug on FPGA
Bout <= qRegB;  -- added for debug on FPGA

end logic;
