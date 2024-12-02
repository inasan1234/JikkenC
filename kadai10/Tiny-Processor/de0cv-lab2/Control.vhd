--------------------------------
--  Control of TinyProcessor
--
--  2004/08/23 Keishi SAKANUSHI
--  2011/11/09 Yoshiaki Taniguchi
--------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity Controler is
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
end Controler;

architecture logic of Controler is

component Johnson1L0
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson1L1
  port (
    cond1 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson1L01
  port (
    cond0 : in  std_logic;
    cond1 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic
  );
end component;

component Johnson2L0
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(1 downto 0)
  );
end component;

component Johnson3L0
  port (
    cond0 : in  std_logic;
    clock : in  std_logic;
    reset : in  std_logic;
    q     : out std_logic_vector(2 downto 0)
  );
end component;

--------------------------------
-- Signals from/ot Johnson Counters for External Signals
--------------------------------
signal qJCextA : std_logic;
signal qJCextB : std_logic;
signal qJCextC : std_logic_vector(1 downto 0);

signal cJCextA : std_logic;
signal cJCextB : std_logic;
signal cJCextC : std_logic;
signal cs1     : std_logic;
signal cs2     : std_logic;

--------------------------------
-- Signals from/ot Johnson Counters for internal Signals
--------------------------------
signal qJCintA : std_logic;
signal qJCintB : std_logic_vector(1 downto 0);
signal qJCintC : std_logic_vector(1 downto 0);
signal qJCintD : std_logic;
signal qJCintE : std_logic_vector(1 downto 0);
signal qJCintF : std_logic_vector(2 downto 0);

signal cact    : std_logic;
signal cJCintB : std_logic;
signal cJCintC : std_logic;
signal cJCintD : std_logic;
signal cJCintE : std_logic;
signal cJCintF : std_logic;
-- signal chalt   : std_logic;
-- signal one     : std_logic;

begin    -- logic
-- one <= '1';

--------------------------------
-- Johnson Counters for External Signals
--------------------------------

----------------
--   JCextA   --
----------------
JCextA : Johnson1L01
  port map(
    cond0 => cJCextA,
    cond1 => cs1,
    clock => clock,
    reset => reset,
    q     => qJCextA
  );

----------------
--   JCextB   --
----------------
JCextB : Johnson1L01
  port map(
    cond0 => cJCextB,
    cond1 => cs2,
    clock => clock,
    reset => reset,
    q     => qJCextB
  );

----------------
--   JCextC   --
----------------
JCextC : Johnson2L0
  port map(
    cond0  => cJCextC,
    clock => clock,
    reset => reset,
    q     => qJCextC
  );

--------------------------------
-- Decode logic for External Signals
--------------------------------
selMuxAddr <= '1' when qJCextB = '1'  else
              '1' when qJCextC = "01" else
              '1' when qJCextC = "11" else
              '1' when qJCextC = "10" else
              '0' ;

read  <= '0' when qJCextA = '1' else
         '0' when qJCextB = '1' else
         '1';

write <= '0' when qJCextC = "11" else
         '1';

--------------------------------
-- Johnson Counters for Internal Signals
--------------------------------

----------------
--   JCintA   --
----------------
JCintA : Johnson1L1
  port map(
    cond1 => cact,
    clock => clock,
    reset => reset,
    q     => qJCintA
  );

----------------
--   JCintB   --
----------------
JCintB : Johnson2L0
  port map(
    cond0 => cJCintB,
    clock => clock,
    reset => reset,
    q     => qJCintB
  );

----------------
--   JCintC   --
----------------
JCintC : Johnson2L0
  port map(
    cond0 => cJCintC,
    clock => clock,
    reset => reset,
    q     => qJCintC
  );

----------------
--   JCintD   --
----------------
JCintD : Johnson1L0
  port map(
    cond0 => cJCintD,
    clock => clock,
    reset => reset,
    q     => qJCintD
  );

----------------
--   JCintE   --
----------------
JCintE : Johnson2L0
  port map(
    cond0 => cJCintE,
    clock => clock,
    reset => reset,
    q     => qJCintE
  );

----------------
--   JCintF   --
----------------
JCintF : Johnson3L0
  port map(
    cond0  => cJCintF,
    clock => clock,
    reset => reset,
    q     => qJCintF
  );

--------------------------------
-- Decode Logic for Control Signals
--  of Johnson Counters for External
--------------------------------

cJCextA <= '1' when qJCintA = '0' else
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0010") else -- SETIXH SETIXL LDIA LDIB
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1000") else -- JP
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1001" and ZeroF = '1') else -- JPZ(Z=1)
           '1' when (qJCintB = "10" and irout(7 downto 4) = "0000") else -- NOP
           '1' when (qJCintC = "11" and irout(7 downto 4) = "0001") else -- LDDA LDDB
           '1' when (qJCintD = '1')  else
           '1' when (qJCintE = "10") else
           '1' when (qJCintF = "100") else
           '0';

cJCextB <= '1' when (qJCintB = "10" and irout(7 downto 4) = "0001") else -- LDDA LDDB
           '0';

cJCextC <= '1' when (qJCintB = "10" and irout(7 downto 4) = "0100") else -- STDA
           '0';

cs1     <= '1' when qJCintB = "11"  else
           '1' when qJCintF = "110" else
           '0';

cs2     <= '1' when (qJCintC = "11" and irout(7 downto 4) = "0001") else -- LDDA LDDB
           '0';

--------------------------------
-- Decode Logic for Control Signals
--  of Johnson Counters for Inernal
--------------------------------
cact    <= '0';

cJCintB <= '1' when qJCintA = '0'   else
           '1' when qJCintC = "11"  else
           '1' when qJCintD = '1'   else
           '1' when qJCintE = "10"  else
           '1' when qJCintF = "100" else
           '0';

cJCintC <= '1' when (qJCintB = "10" and irout(7 downto 6) = "00") else -- SETIXH SETIXL LDIA LDIB LDDA LDDB
           '0';

cJCintD <= '1' when (qJCintB = "10" and irout(7 downto 5) = "110") else -- ADDA ADDB INCA DECA
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1001" and ZeroF = '0') else -- JPZ(Z=0)
           '0';

cJCintE <= '1' when (qJCintB = "10" and irout(7 downto 6) = "01") else -- STDA
           '0';

cJCintF <= '1' when (qJCintB = "10" and irout(7 downto 4) = "1000") else -- JP
           '1' when (qJCintB = "10" and irout(7 downto 4) = "1001" and ZeroF = '1') else -- JPZ(Z=1)
           '0';

--------------------------------
-- Decode logic for Internal Signals
--------------------------------
clearIP   <= '1' when qJCintA='0' else
             '0';

loadIR    <= '1' when qJCintB = "11" else
             '0';

modeALU   <= irout(1 downto 0) when (qJCintD = '1' and irout(7 downto 6) = "11") else -- ADDA ADDB INCA DECA
             "00";

loadFZ    <= '1' when ( qJCintD = '1' and irout(7 downto 6) = "11") else -- ADDA ADDB INCA DECA
             '0';

loadhMB   <= '1' when qJCintF = "011" else
             '0';

loadlMB   <= '1' when qJCintF = "110" else
             '0';

loadIP    <= '1' when qJCintF = "100" else
             '0';

loadhIX <= '1' when (qJCintC = "11" and irout(7 downto 0) = "00100010") else -- SERIXH
           '0';

loadlIX <= '1' when (qJCintC = "11" and irout(7 downto 0) = "00100001") else -- SETIXL
           '0';

loadRegA <= irout(3) when qJCintC = "11" else -- LDIA (LDIB) LDDA (LDDB) (SETIXH) (SETIXL)
            irout(3) when qJCintD = '1'  else -- ADDA (ADDB) INCA DECA
            '0';

loadRegB <= irout(2) when qJCintC = "11" else -- (LDIA) LDIB (LDDA) LDDB (SETIXH) (SETIXL)
            irout(2) when qJCintD = '1'  else -- (ADDA) ADDB (INCA) (DECA)
            '0';

incIP   <=  '1' when qJCintB = "10"  else
            '1' when (qJCintC = "11" and irout(7 downto 5) = "001") else -- SETIXH SETIXL LDIA LDIB
            '1' when qJCintF = "011" else
            '0';

inc2IP   <= '1' when (qJCintD = '1' and irout(7 downto 4) = "1001" and ZeroF = '0') else -- JPZ(Z=0)
            '0';

selMuxDIn<= '1' when qJCintC = "01" and irout(7 downto 4) = "0010" else -- LDIA LDIB (SETIXH) (SETIXL)
            '1' when qJCintC = "01" and irout(7 downto 4) = "0001" else -- LDDA LDDB
            '1' when qJCintC = "11" and irout(7 downto 4) = "0010" else -- LDIA LDIB (SETIXH) (SETIXL)
            '1' when qJCintC = "11" and irout(7 downto 4) = "0001" else -- LDDA LDDB
            '0' ;

end logic;
