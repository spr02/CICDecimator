library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity downsampler is
	generic(
		R			: integer := 2;
		DATA_WIDTH	: integer := 34
	);
	port(
		ClkxCI		: in  std_logic;
		RstxRBI		: in  std_logic;
		ClkEnxSI	: in  std_logic;
		
		ValidxSI	: in  std_logic;
		ReadyxSO	: out std_logic;
		DataxDI		: in  std_logic_vector((DATA_WIDTH - 1) downto 0);
		
		ValidxSO	: out std_logic;
		ReadyxSI	: in  std_logic;
		DataxDO		: out std_logic_vector((DATA_WIDTH - 1) downto 0)
	);
end downsampler;

architecture arch of downsampler is
	signal OneHotCntxDP : std_logic_vector((R-1) downto 0);
	
	
	signal InRdxS		: std_logic;
	signal OutEnxS		: std_logic;
	signal OutRdxS		: std_logic;
	signal ReadyxSP		: std_logic;
	signal ValidxSP		: std_logic;
	signal DataxDP		: std_logic_vector((DATA_WIDTH - 1) downto 0);
begin

	assert R > 1 report "Decimation factor must be larger than 1 (R = " & integer'image(R) & ")." severity error;


	InRdxS	<= ValidxSI	and ReadyxSP;
	OutRdxS	<= ValidxSP and ReadyxSI;
	
	OutEnxS <= InRdxS and OneHotCntxDP(OneHotCntxDP'high);
	
	p_sync_one_hot : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			OneHotCntxDP <= std_logic_vector(to_unsigned(0, R-1)) & '1'; -- initialize zero element
		elsif (ClkxCI = '1' and ClkxCI'event) then
			if InRdxS = '1' then
				OneHotCntxDP <= OneHotCntxDP((R-2) downto 0) & OneHotCntxDP(R-1); --shift elements
			end if;
		end if;
	end process;
	
	
	p_sync_ds_ctl : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			ReadyxSP <= '1';
			ValidxSP <= '0';
		elsif (ClkxCI = '1' and ClkxCI'event) then
			ReadyxSP <= (OutRdxS or not ValidxSP) or (ReadyxSP and (not OneHotCntxDP(OneHotCntxDP'high-1) or not InRdxS));
			ValidxSP <= OutEnxS or (ValidxSP and not OutRdxS);
		end if;
	end process;
	
	p_sync_ds_data : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			DataxDP <= (others => '0');
		elsif (ClkxCI = '1' and ClkxCI'event) then
			if OutEnxS = '1' then
				DataxDP <= DataxDI;
			end if;
		end if;
	end process;

	-- ready (input/slave axis)
	ReadyxSO	<= ReadyxSP;
	
	-- data and valid (output/master axis)
	ValidxSO	<= ValidxSP;
	DataxDO		<= DataxDP;
	
	
	
end architecture arch;