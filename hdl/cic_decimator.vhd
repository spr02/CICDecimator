library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cic_decim is
	generic(
		N		: integer := 4;
		M		: integer := 1;
		R		: integer := 16;
		Bin		: integer := 16;
		Bout	: integer := 16
	);
	port(
		ClkxCI		: in  std_logic;
		RstxRBI		: in  std_logic;
		ClkEnxSI	: in  std_logic;
		
		ValidxSI	: in  std_logic;
		ReadyxSO	: out std_logic;
		DataxDI		: in  std_logic_vector((Bin - 1) downto 0);
		
		ValidxSO	: out std_logic;
		ReadyxSI	: in  std_logic;
		DataxDO		: out std_logic_vector((Bout - 1) downto 0)
	);
end cic_decim;

architecture arch of cic_decim is
	
	function ceil_log2 (x: in integer) return integer is
		variable tmp    : integer := x;
		variable ret    : integer := 0;
	begin
		while tmp > 1 loop
			ret := ret + 1;
			tmp := tmp / 2;
		end loop;
		return ret;
	end function ceil_log2;
	
	constant REG_GROWTH		: integer := N * ceil_log2(R*M);
	constant REG_WIDTH		: integer := Bin + REG_GROWTH; -- TODO: change to maximum reg width
	
	
	subtype t_data is std_logic_vector((REG_WIDTH - 1) downto 0);
	
	type t_axis_iface is record
		valid	: std_logic;
		ready	: std_logic;
		data	: t_data; -- std_logic_vector -> unconstrained is possible but does not work if t_asis_iface is instantiated as array
	end record;
	
	type t_sig_con is array (0 to N) of t_axis_iface;-- (data((REG_WIDTH-1) downto 0));
	
	
	signal IntConxD			: t_sig_con;
	signal DiffConxD		: t_sig_con;
	
begin
	
	-- connect input axis interface
	IntConxD(0).valid	<= ValidxSI;
	ReadyxSO			<= IntConxD(0).ready;
	IntConxD(0).data	<= std_logic_vector(resize(signed(DataxDI), REG_WIDTH));
	
	-- Int stages
	GEN_INT : for I in 1 to N generate
		CICIntegrator : entity work.integrator
		generic map(
			B => REG_WIDTH
		)
		port map(
			ClkxCI		=> ClkxCI,
			RstxRBI		=> RstxRBI,
			ClkEnxSI	=> ClkEnxSI,
			
			ValidxSI	=> IntConxD(I-1).valid,
			ReadyxSO	=> IntConxD(I-1).ready,
			DataxDI		=> IntConxD(I-1).data,
			
			ValidxSO	=> IntConxD(I).valid,
			ReadyxSI	=> IntConxD(I).ready,
			DataxDO		=> IntConxD(I).data
		);
	end generate;
	
	
	-- Downsamling by R
	CICDownsampler : entity work.downsampler
	generic map(
		R	=> R,
		B	=> REG_WIDTH
	)
	port map(
		ClkxCI		=> ClkxCI,
		RstxRBI		=> RstxRBI,
		ClkEnxSI	=> ClkEnxSI,
		
		ValidxSI	=> IntConxD(IntConxD'high).valid,
		ReadyxSO	=> IntConxD(IntConxD'high).ready,
		DataxDI		=> IntConxD(IntConxD'high).data,
		
		ValidxSO	=> DiffConxD(0).valid,
		ReadyxSI	=> DiffConxD(0).ready,
		DataxDO		=> DiffConxD(0).data
	);
	
	
	-- Comb stages
	GEN_DIFF : for I in 1 to N generate
		CICDifferentiator : entity work.differentiator
		generic map(
			M	=> 1,
			B 	=> REG_WIDTH
		)
		port map(
			ClkxCI		=> ClkxCI,
			RstxRBI		=> RstxRBI,
			ClkEnxSI	=> ClkEnxSI,
			
			ValidxSI	=> DiffConxD(I-1).valid,
			ReadyxSO	=> DiffConxD(I-1).ready,
			DataxDI		=> DiffConxD(I-1).data,
			
			ValidxSO	=> DiffConxD(I).valid,
			ReadyxSI	=> DiffConxD(I).ready,
			DataxDO		=> DiffConxD(I).data
		);
	end generate;
	
	
	-- connect output axis interface
	DiffConxD(DiffConxD'high).ready		<= ReadyxSI;
	DataxDO								<= std_logic_vector(signed(DiffConxD(DiffConxD'high).data((REG_WIDTH - 1) downto (REG_WIDTH - Bout))));
	ValidxSO							<= DiffConxD(DiffConxD'high).valid;
	
end architecture arch;
