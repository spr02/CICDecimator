library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;

entity cic_decimator_tb is
end cic_decimator_tb;


architecture behav of cic_decimator_tb is
	--------------------------------------------------------------------------------------
	-- Components to be tested
	--------------------------------------------------------------------------------------
	
	--------------------------------------------------------------------------------------
	-- Functions
	--------------------------------------------------------------------------------------	
	function param_slv_to_matlab_log (name : string; x : std_logic_vector) return line is
		variable LogLine : line;
	begin
		write(LogLine, string'("params."));
		write(LogLine, name);
		write(LogLine, string'(" = "));
		write(LogLine, integer'image(to_integer(unsigned(x))));
		write(LogLine, string'(";"));
		return LogLine;
	end function;
	
	function param_sgn_to_matlab_log (name : string; x : std_logic_vector) return line is
		variable LogLine : line;
	begin
		write(LogLine, string'("params."));
		write(LogLine, name);
		write(LogLine, string'(" = "));
		write(LogLine, integer'image(to_integer(signed(x))));
		write(LogLine, string'(";"));
		return LogLine;
	end function;
	
	function param_int_to_matlab_log (name : string; x : integer) return line is
		variable LogLine : line;
	begin
		write(LogLine, string'("params."));
		write(LogLine, name);
		write(LogLine, string'(" = "));
		write(LogLine, integer'image(x));
		write(LogLine, string'(";"));
		return LogLine;
	end function;
	
	function param_sl_to_matlab_log (name : string; x : std_logic) return line is
		variable LogLine : line;
	begin
		write(LogLine, string'("params."));
		write(LogLine, name);
		write(LogLine, string'(" = "));
		if x = '1' then
			write(LogLine, string'("true"));
		else
			write(LogLine, string'("false"));
		end if;
		write(LogLine, string'(";"));
		return LogLine;
	end function;
	
	--------------------------------------------------------------------------------------
	-- Signals
	--------------------------------------------------------------------------------------
-- 	file LOG_FILE					: text is out "./hdl_out_log.m";
	
	constant N			: integer := 4;
	constant M			: integer := 1;
	constant R			: integer := 64;
	
	constant B			: integer := 16;
	
	
	signal s_cnt					: unsigned((B - 1) downto 0) := to_unsigned(1, B);
	
	
	signal ClkxC					: std_logic;
	signal RstxRB					: std_logic;
	
	
	signal s_valid_i, s_valid_o		: std_logic;
	signal s_ready_i, s_ready_o		: std_logic;
	signal s_data_i, s_data_o			: std_logic_vector((B - 1) downto 0);
	
begin

	------------------------------------------------
	--	  INSTANTIATE Component
	------------------------------------------------
	
-- 	I0 : entity work.downsampler
-- 	generic map(
-- 		R	=> R,
-- 		B	=> B
-- 	)
-- 	port map(
-- 		ClkxCI		=> ClkxC,
-- 		RstxRBI		=> RstxRB,
-- 		ClkEnxSI	=> '1',
-- 		ValidxSI	=> s_valid_i,
-- 		ReadyxSO	=> s_ready_o,
-- -- 		DataxDI		=> s_data_i,
-- 		DataxDI		=> std_logic_vector(s_cnt),
-- 		ValidxSO	=> s_valid_o,
-- 		ReadyxSI	=> s_ready_i,
-- 		DataxDO		=> s_data_o
-- 	);
	
	
-- 	I0 : entity work.integrator
-- 	generic map(
-- 		B	=> B
-- 	)
-- 	port map(
-- 		ClkxCI		=> ClkxC,
-- 		RstxRBI		=> RstxRB,
-- 		ClkEnxSI	=> '1',
-- 		ValidxSI	=> s_valid_i,
-- 		ReadyxSO	=> s_ready_o,
-- 		DataxDI		=> s_data_i,
-- -- 		DataxDI		=> std_logic_vector(s_cnt),
-- 		ValidxSO	=> s_valid_o,
-- 		ReadyxSI	=> s_ready_i,
-- 		DataxDO		=> s_data_o
-- 	);
	
-- 	I0 : entity work.differentiator
-- 	generic map(
-- 		M	=> 1,
-- 		B	=> B
-- 	)
-- 	port map(
-- 		ClkxCI		=> ClkxC,
-- 		RstxRBI		=> RstxRB,
-- 		ClkEnxSI	=> '1',
-- 		ValidxSI	=> s_valid_i,
-- 		ReadyxSO	=> s_ready_o,
-- -- 		DataxDI		=> s_data_i,
-- 		DataxDI		=> std_logic_vector(s_cnt),
-- 		ValidxSO	=> s_valid_o,
-- 		ReadyxSI	=> s_ready_i,
-- 		DataxDO		=> s_data_o
-- 	);

	
	I0 : entity work.cic_decim
	generic map(
		N	=> N,
		M	=> M,
		R	=> R,
		B	=> B
	)
	port map(
		ClkxCI		=> ClkxC,
		RstxRBI		=> RstxRB,
		ClkEnxSI	=> '1',
		ValidxSI	=> s_valid_i,
		ReadyxSO	=> s_ready_o,
		DataxDI		=> s_data_i,
-- 		DataxDI		=> std_logic_vector(s_cnt),
		ValidxSO	=> s_valid_o,
		ReadyxSI	=> s_ready_i,
		DataxDO		=> s_data_o
	);
	
	------------------------------------------------
	--	  Generate Clock Signal
	------------------------------------------------
	p_clock: process
	begin
		ClkxC <= '0';
		wait for 50 ns;
		ClkxC <= '1';
		wait for 50 ns;
	end process p_clock;
	
	------------------------------------------------
	--	  Generate Reset Signal
	------------------------------------------------
	p_reset: process
	begin
		RstxRB <= '0';
		wait for 10 ns;
		RstxRB <= '1';
		wait;
	end process p_reset;

	
	p_cnt : process(ClkxC)
	begin
		if rising_edge(ClkxC) then
			if s_valid_i = '1' and s_ready_o = '1' then
				s_cnt <= s_cnt + 1;
			end if;
		end if;
	end process;
	
-- 	p_sync_enable_signal : process(RstxRB, ClkxC)
-- 	begin
-- 		if RstxRB = '0' then
-- 			EnablexS <= '0';
-- 		elsif ClkxC'event and ClkxC = '1' then
-- 			EnablexS <= not EnablexS;
-- 		end if;
-- 	end process;

	
	------------------------------------------------
	--	  Generate Stimuli
	------------------------------------------------
	p_gen_stimuli: process
		variable LogLine : line;
	begin
		s_valid_i	<= '1';
		s_ready_i	<= '1';
-- 		s_data_i	<= std_logic_vector(to_signed(1, B));
		s_data_i	<= x"7FFF";
		wait until rising_edge(RstxRB);
		
		wait until rising_edge(ClkxC);
-- 		s_data_i	<= (others => '0');
		
-- 		for I in 1 to 64 loop
-- 			wait until rising_edge(ClkxC);
-- 		end loop;

		wait;
		

	end process p_gen_stimuli;
	
end behav;
