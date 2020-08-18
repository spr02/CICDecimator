library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.math_pkg.all;

entity downsampler is
	generic(
		ENCODING : string := "onehot";
		R	: integer := 2;
		B	: integer := 34
	);
	port(
		ClkxCI		: in  std_logic;
		RstxRBI		: in  std_logic;
		ClkEnxSI	: in  std_logic;
		
		RatexSI		: in  std_logic_vector((ceil_log2(R) - 1) downto 0);
		
		ValidxSI	: in  std_logic;
		ReadyxSO	: out std_logic;
		DataxDI		: in  std_logic_vector((B - 1) downto 0);
		
		ValidxSO	: out std_logic;
		ReadyxSI	: in  std_logic;
		DataxDO		: out std_logic_vector((B - 1) downto 0)
	);
end downsampler;

architecture arch of downsampler is
	
	signal DsValidxS	: std_logic;
	signal DsReadyxS	: std_logic;
	signal InRdxS		: std_logic;
	signal OutEnxS		: std_logic;
	signal OutRdxS		: std_logic;
	signal ReadyxSP		: std_logic;
	signal ValidxSP		: std_logic;
	signal DataxDP		: std_logic_vector((B - 1) downto 0);
begin

	assert R > 1 report "Decimation factor must be larger than 1 (R = " & integer'image(R) & ")." severity error;


	InRdxS	<= ValidxSI	and ReadyxSP;
	OutRdxS	<= ValidxSP and ReadyxSI;
	
	OutEnxS <= InRdxS and DsValidxS;
	
	g_onehot : if ENCODING = "onehot" generate
		signal OneHotCntxDP : std_logic_vector((R - 1) downto 0);
	begin
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
		DsValidxS	<= OneHotCntxDP(OneHotCntxDP'high);
		DsReadyxS	<= OneHotCntxDP(OneHotCntxDP'high - 1);
-- 		DsValidxS	<= OneHotCntxDP(OneHotCntxDP'high)		when rising_edge(ClkxCI);
-- 		DsReadyxS	<= OneHotCntxDP(OneHotCntxDP'high - 1)	when rising_edge(ClkxCI);
	end generate g_onehot;
	
	g_counter : if ENCODING = "binary" generate
		signal CounterxS		: unsigned((ceil_log2(R) - 1) downto 0);
	begin
		p_sync_one_hot : process(ClkxCI, RstxRBI)
		begin
			if (RstxRBI = '0') then
				CounterxS <= unsigned(RatexSI) - 1;
				DsValidxS <= '0';
				DsReadyxS <= '0';
			elsif (ClkxCI = '1' and ClkxCI'event) then
				if InRdxS = '1' then
					if CounterxS = (CounterxS'range => '0') then
						CounterxS	<= unsigned(RatexSI) - 1;
						DsReadyxS	<= '1';
					else
						CounterxS	<= CounterxS - 1;
						DsReadyxS	<= '0';
					end if;
				end if;
				DsValidxS	<= DsReadyxS;
			end if;
		end process;
	end generate g_counter;
	
	p_sync_ds_ctl : process(ClkxCI, RstxRBI)
	begin
		if (RstxRBI = '0') then
			ReadyxSP <= '1';
			ValidxSP <= '0';
		elsif (ClkxCI = '1' and ClkxCI'event) then
			ReadyxSP <= (OutRdxS or not ValidxSP) or (ReadyxSP and (not DsReadyxS or not InRdxS));
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
