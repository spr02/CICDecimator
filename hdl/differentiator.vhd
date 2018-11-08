library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity differentiator is
	generic(
		M	: integer := 1;
		B	: integer := 34
	);
	port(
		ClkxCI		: in  std_logic;
		RstxRBI		: in  std_logic;
		ClkEnxSI	: in  std_logic;
		
		ValidxSI	: in  std_logic;
		ReadyxSO	: out std_logic;
		DataxDI		: in  std_logic_vector((B - 1) downto 0);
		
		ValidxSO	: out std_logic;
		ReadyxSI	: in  std_logic;
		DataxDO		: out std_logic_vector((B - 1) downto 0)
	);
end differentiator;

architecture behav of differentiator is
	type t_dly is array (0 to M-1) of signed((B - 1) downto 0);
	signal DlyxDP			: t_dly;
	signal DiffxDP			: signed((B - 1) downto 0);
	
	signal InRdxS			: std_logic;
	signal OutRdxS			: std_logic;
	signal OutEnxS			: std_logic;
	
	signal ValidxSP			: std_logic;
	signal ReadyxSP			: std_logic;
begin
	
	InRdxS		<= ValidxSI and ReadyxSP;
	OutRdxS		<= ValidxSP and ReadyxSI;
	
	OutEnxS		<= InRdxS;
	
	p_sync_sub_ctl : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			ReadyxSP <= '1';
			ValidxSP <= '0';
		elsif (ClkxCI = '1' and ClkxCI'event) then
			ReadyxSP <= (OutRdxS or not ValidxSP) or (ReadyxSP and not InRdxS);
			ValidxSP <= OutEnxS or (ValidxSP and not OutRdxS);
		end if;
	end process;
	
	p_sync_sub_data : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			DiffxDP <= (others => '0');
			DlyxDP	<= (others => (others => '0'));
		elsif (ClkxCI = '1' and ClkxCI'event) then
			if InRdxS = '1' then
				-- delay line
				DlyxDP(0) <= signed(DataxDI);
				for i in 1 to M-1 loop
					DlyxDP(i) <= DlyxDP(i-1);
				end loop;
				
				-- difference
				DiffxDP <= signed(DataxDI) - DlyxDP(DlyxDP'high);
			end if;
		end if;
	end process;
	
	-- ready (input/slave axis)
	ReadyxSO	<= ReadyxSP;
	
	-- data and valid (output/master axis)
	ValidxSO	<= ValidxSP;
	DataxDO		<= std_logic_vector(DiffxDP);
	
end architecture behav;
