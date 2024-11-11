-------------------------------------------
-- Testbench for DataPath of C-Processor --
--                                       --
--                   (c) Yosuke Kakiuchi --
--                            2010/10/01 --
-------------------------------------------
-- [Caution!!]
-- * Replace the following signal names with your signal names 
-- 1) loadRegC - "load" + the name of register which you added
-- 2) selMuxDOut - "sel" + the name of MUX4x08's which you added
-- 3) CarryF, loadFC - the output and the load signal of the carry flag which you added


library IEEE;
use IEEE.std_logic_1164.all;

entity TestDataPath is
end TestDataPath;

architecture behavior of TestDataPath is
	signal    DataIn    : std_logic_vector (7 downto 0);
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
	signal    Address   : std_logic_vector (15 downto 0);
	signal    ZeroF     : std_logic;
	signal    CarryF    : std_logic;
	signal    DataOut   : std_logic_vector (7 downto 0);

	signal    loadRegC  : std_logic;
	signal    loadRegB  : std_logic;
	signal    loadRegA  : std_logic;

	signal    modeALU   : std_logic_vector (3 downto 0);
	signal    loadFZ    : std_logic;
	signal    loadFC    : std_logic;

	signal    selMuxDOut: std_logic_vector (1 downto 0);

	signal    clock     : std_logic;
	signal    reset     : std_logic;



	component DataPath is
	  port (
	    DataIn    : in  std_logic_vector (7 downto 0);
	    selMuxDIn : in  std_logic;

	    loadhMB   : in  std_logic;
	    loadlMB   : in  std_logic;
	    loadhIX   : in  std_logic;
	    loadlIX   : in  std_logic;

	    loadIR    : in  std_logic;
	    IRout     : out std_logic_vector (7 downto 0);

	    loadIP    : in  std_logic;
	    incIP     : in  std_logic;
	    inc2IP    : in  std_logic;
	    clearIP   : in  std_logic;

	    selMuxAddr: in  std_logic;
	    Address   : out std_logic_vector (15 downto 0);
	    ZeroF     : out std_logic;
	    CarryF    : out std_logic;
	    DataOut   : out std_logic_vector (7 downto 0);

	    loadRegC  : in  std_logic;
	    loadRegB  : in  std_logic;
	    loadRegA  : in  std_logic;

	    modeALU   : in  std_logic_vector (3 downto 0);
	    loadFZ    : in  std_logic;
	    loadFC    : in  std_logic;

	    selMuxDOut: in  std_logic_vector (1 downto 0);

	    clock     : in  std_logic;
	    reset     : in  std_logic
	  );
	end component;

	constant clk_cycle : time := 10 ns;   -- frequency 100 MHz

begin

	path: DataPath
		port map(
		    DataIn     =>    DataIn     ,
		    selMuxDIn  =>    selMuxDIn  ,

		    loadhMB    =>    loadhMB    ,
		    loadlMB    =>    loadlMB    ,
		    loadhIX    =>    loadhIX    ,
		    loadlIX    =>    loadlIX    ,

		    loadIR     =>    loadIR     ,
		    IRout      =>    IRout      ,

		    loadIP     =>    loadIP     ,
		    incIP      =>    incIP      ,
		    inc2IP     =>    inc2IP     ,
		    clearIP    =>    clearIP    ,

		    selMuxAddr =>    selMuxAddr ,
		    Address    =>    Address    ,
		    ZeroF      =>    ZeroF      ,
		    CarryF     =>    CarryF     ,
		    DataOut    =>    DataOut    ,

		    loadRegC   =>    loadRegC   ,
		    loadRegB   =>    loadRegB   ,
		    loadRegA   =>    loadRegA   ,

		    modeALU    =>    modeALU    ,
		    loadFZ     =>    loadFZ     ,
		    loadFC     =>    loadFC     ,

		    selMuxDOut =>    selMuxDOut ,

		    clock      =>    clock      ,
		    reset      =>    reset      
		);


process begin
	  clock <= '1';
	  wait for clk_cycle/2;
	  clock <= '0';
	  wait for clk_cycle/2;
end process;


process begin
	reset <= '1';
	DataIn <= X"00";  
	selMuxDIn <= '0'; selMuxAddr <= '0'; selMuxDOut <= "00";
	loadhMB <= '0'; loadlMB <= '0'; loadhIX <= '0'; loadlIX<= '0';   
	loadIR <= '0'; loadIP <= '0'; loadFZ <= '0'; loadFC <= '0';    
	loadRegA <= '0'; loadRegB <= '0'; loadRegC <= '0';  
	clearIP <= '0'; incIP <= '0'; inc2IP <= '0';   
	modeALU <= "0000";  
wait for clk_cycle*2;  -- Default Value
  reset <= '0';
wait for clk_cycle; -- RegA <= 0x11
	DataIn <= X"11";  
	selMuxDIn <= '1'; selMuxAddr <= '0'; selMuxDOut <= "00";
	loadRegA <= '1'; loadRegB <= '0'; loadRegC <= '0';  
	modeALU <= "0000";  
wait for clk_cycle; -- RegB <= 0x22
	DataIn <= X"22";  
	selMuxDIn <= '1'; selMuxAddr <= '0'; selMuxDOut <= "00";
	loadRegA <= '0'; loadRegB <= '1'; loadRegC <= '0';  
	modeALU <= "0000";  
wait for clk_cycle; -- RegC <= 0x33
	DataIn <= X"33";  
	selMuxDIn <= '1'; selMuxAddr <= '0'; selMuxDOut <= "01";
	loadRegA <= '0'; loadRegB <= '0'; loadRegC <= '1';  
	modeALU <= "0000";  
wait for clk_cycle; -- RegA(33) <= RegA(11) or RegB(22)
	DataIn <= X"44";  
	selMuxDIn <= '0'; selMuxAddr <= '0'; selMuxDOut <= "10";
	loadRegA <= '1'; loadRegB <= '0'; loadRegC <= '0';  
	modeALU <= "0011";  
wait for clk_cycle; -- RegB(11) <= RegA(11) and RegB(22)
	DataIn <= X"55";  
	selMuxDIn <= '0'; selMuxAddr <= '0'; selMuxDOut <= "00";
	loadRegA <= '0'; loadRegB <= '1'; loadRegC <= '0';  
	modeALU <= "0010";  
wait for clk_cycle; -- wait for DataOut
	DataIn <= X"66";  
	selMuxDIn <= '0'; selMuxAddr <= '0'; selMuxDOut <= "01";
	loadRegA <= '0'; loadRegB <= '0'; loadRegC <= '0';  
	modeALU <= "0000";  
wait;
end process;

end behavior;

