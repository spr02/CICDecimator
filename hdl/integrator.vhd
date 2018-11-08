library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity integrator is
	generic(
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
end integrator;

architecture behav of integrator is
	
	signal ValidxSP		: std_logic;
	signal ReadyxSP		: std_logic;
	signal InRdxS		: std_logic;
	signal OutRdxS		: std_logic;
	signal OutEnxS		: std_logic;
	signal SumxDP		: signed((B - 1) downto 0);
begin
	
	InRdxS	<= ValidxSI and ReadyxSP; -- input is read
	OutRdxS	<= ValidxSP and ReadyxSI; -- output is read
	
	OutEnxS	<= InRdxS;
	
	p_sync_add_ctl : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			ReadyxSP <= '1';
			ValidxSP <= '0';
		elsif (ClkxCI = '1' and ClkxCI'event) then
			ReadyxSP <= (OutRdxS or not ValidxSP) or (ReadyxSP and not InRdxS);
			ValidxSP <= OutEnxS or (ValidxSP and not OutRdxS);
		end if;
	end process;
	
	p_sync_add_data : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			SumxDP <= (others => '0');
		elsif (ClkxCI = '1' and ClkxCI'event) then
			if OutEnxS = '1' then
				SumxDP <= SumxDP + signed(DataxDI);
			end if;
		end if;
	end process;
	
	-- ready (input/slave axis)
	ReadyxSO	<= ReadyxSP;
	
	-- data and valid (output/master axis)
	ValidxSO	<= ValidxSP;
	DataxDO		<= std_logic_vector(SumxDP);
	
end architecture behav;
