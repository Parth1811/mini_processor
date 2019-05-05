library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.MUX4.all;
use work.all;

entity Proc is
	port (
		clk, RST	: in std_logic
	);
end entity Proc;

architecture arch of Proc is

	function sign_extender(slv : in std_logic_vector) return std_logic_vector is
	  --extend a 6 bit vector to 16 bit vector
	  variable res_v : std_logic_vector(15 downto 0);
		begin
			res_v(5 downto 0) := slv;
		  for i in 0 to 9 loop
		    res_v(i + 6) := slv(5);
		  end loop;
	  return res_v;
	end function;

	function sign_extender9(slv : in std_logic_vector) return std_logic_vector is
	  --extend a 9 bit vector to 16 bit vector
	  variable res_v : std_logic_vector(15 downto 0);
		begin
			res_v(8 downto 0) := slv;
		  for i in 0 to 6 loop
		    res_v(i + 9) := slv(8);
		  end loop;
	  return res_v;
	end function;



	function zero_extender(slv : in std_logic_vector) return std_logic_vector is
	  --extend a 9 bit vector to 16 bit vector by adding zeros to starting
	  variable res_v : std_logic_vector(15 downto 0);
		begin
			res_v(15 downto 7) := slv;
			res_v(6 downto 0) := "0000000";
	  return res_v;
	end function;


	component ALU is
		port (
			A, B	: in std_logic_vector(15 downto 0);
			OP 		: in std_logic_vector(1 downto 0);
			O 		: out std_logic_vector(15 downto 0);
			C, Z	: out std_logic
		);
	end component;

	component Register_File is
		port (
			A1, A2       : in std_logic_vector(2 downto 0);
			Din1, Din2 	 : in std_logic_vector(15 downto 0);
			clk, W1, W2 			 : in std_logic;
			Dout1, Dout2       : out std_logic_vector(15 downto 0)
		);
	end component;

	component Memory_asyncread_syncwrite is
		port (
					A, Din : in std_logic_vector(15 downto 0);
		 			clk, W : in std_logic;
					Dout   : out std_logic_vector(15 downto 0)
				 );
	end component;

	constant Z16 : std_logic_vector(15 downto 0):= (others  => '0');
	constant ONE : std_logic_vector(15 downto 0):= "0000000000000001";
	constant ALL_ONE : std_logic_vector(15 downto 0):= (others  => '1');
	constant SEVEN : std_logic_vector(15 downto 0):= "0000000000000111";

  type StateSymbol is (S0, Decode, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, S17, S18, S19, S20, S21, S22, S23, S24, S25, S26, S27, S28, S29 );
  signal fsm_state_symbol: StateSymbol;

	signal ALU_A, ALU_B, ALU_O : std_logic_vector(15 downto 0);
	signal ALU_OP : std_logic_vector(1 downto 0);
	signal ALU_C, ALU_Z : std_logic;

	signal MEM_A, MEM_Din, MEM_Dout: std_logic_vector(15 downto 0);
	signal MEM_W: std_logic;

	signal REG_Din1, REG_Dout1, REG_Din2, REG_Dout2: std_logic_vector(15 downto 0);
	signal REG_A1, REG_A2: std_logic_vector(2 downto 0);
	signal REG_W1, REG_W2: std_logic;

	signal IP, IR, T1, T2, T3 : std_logic_vector(15 downto 0);
	signal C0, Z0 : std_logic;

	signal state_counter: std_logic_vector(1 downto 0);

	alias Instruction is IR(15 downto 12);

	alias rRA is IR(11 downto 9);
	alias rRB is IR(8 downto 6);
	alias rRC is IR(5 downto 3);
	alias rC is IR(1);
	alias rZ is IR(0);
	alias iIm is IR(5 downto 0);
	alias jIm is IR(8 downto 0);

begin

	proc_alu : ALU
		port map(
			A => ALU_A,
			B => ALU_B,
			OP => ALU_OP,
			O => ALU_O,
			C => ALU_C,
			Z => ALU_Z
		);

	mem: Memory_asyncread_syncwrite
	port map(
			A => MEM_A,
			Din => MEM_Din,
			clk => clk,
			W => MEM_W,
			Dout => MEM_Dout
		);

	reg: Register_File
		port map(
				A1 => REG_A1,
				A2 => REG_A2,
				Din1 => REG_Din1,
				Din2 => REG_Din2,
				clk => clk,
				W1 => REG_W1,
				W2 => REG_W2,
				Dout1 => REG_Dout1,
				Dout2 => REG_Dout2
			);


  process(clk, RST, ALU_A, ALU_B, ALU_OP, MEM_A , MEM_Din, MEM_W , REG_A1, REG_Din1, REG_A2, REG_Din2, REG_W1, REG_W2, IP, IR, T1, T2, T3, fsm_state_symbol)

		 variable nALU_A, nALU_B, nALU_O : std_logic_vector(15 downto 0);
		 variable nALU_OP : std_logic_vector(1 downto 0);
		 variable nALU_C, nALU_Z : std_logic;

		 variable nMEM_A, nMEM_Din, nMEM_Dout: std_logic_vector(15 downto 0);
		 variable nMEM_W: std_logic;

		 variable nREG_Din1, nREG_Dout1, nREG_Din2, nREG_Dout2: std_logic_vector(15 downto 0);
		 variable nREG_A1, nREG_A2: std_logic_vector(2 downto 0);
		 variable nREG_W1, nREG_W2: std_logic;

		 variable next_state : StateSymbol;
		 variable nstate_counter : std_logic_vector(1 downto 0);

		 variable nIP, nIR, nT1, nT2, nT3 : std_logic_vector(15 downto 0);
		 variable nC, nZ, phi_c0, phi_z0 : std_logic;

  begin
     next_state := fsm_state_symbol;
		 nstate_counter := state_counter;

		 nALU_A := ALU_A;
		 nALU_B := ALU_B;
		 nALU_OP := ALU_OP;

		 nMEM_A := MEM_A;
		 nMEM_Din := MEM_Din;
		 nMEM_W := MEM_W;

		 nREG_A1 := REG_A1;
		 nREG_Din1 := REG_Din1;
		 nREG_A2 := REG_A2;
		 nREG_Din2 := REG_Din2;
		 nREG_W1 := REG_W1;
		 nREG_W2 := REG_W2;

		 nIP := IP;
		 nIR := IR;

		 nT1 := T1;
		 nT2 := T2;
		 nT3 := T3;

		 nZ := nZ;
		 nC := nC;


     -- compute next-state, output
		 -- add wave clk RST IP IR MEM_Dout
     case fsm_state_symbol is

       when S0 =>
					if (state_counter = "10") then
							nMEM_A := IP;
							nALU_OP := "00";
							nALU_A := IP;
							nALU_B := ONE;
							nstate_counter := "01";
							phi_c0 := '0';
							phi_z0 := '0';
					end if;
					if (state_counter = "01") then
							nIP := ALU_O;
							nIR := MEM_Dout;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := Decode;
							nstate_counter := "10";
					end if;



  		 when Decode =>
			 		if (Instruction = "0000" or Instruction = "0010") then
						next_state := S1;		 -- ADD and NAND
					elsif (Instruction = "0001" or Instruction = "0100") then
						next_state := S4;		 -- ADI and LW
					elsif (Instruction = "0011") then
						next_state := S8;		 -- LHI
					elsif (instruction = "0101") then
						next_state := S9;    -- SW
					elsif (Instruction = "1100") then
						next_state := S12;   -- BEQ
					elsif (Instruction = "1001") then
						next_state := S16;   -- JLR
					elsif (Instruction = "1000") then
						next_state := S18;   -- JAL
					elsif (Instruction = "0110") then
						next_state := S20;   -- LA
					else
						next_state := S0;
					end if;

 			 when S1 =>
			 		if (state_counter = "10") then
						nREG_A1 := rRA;
						nREG_A2 := rRB;
						nstate_counter := "01";
			 		end if;

					if (state_counter = "01") then
						nT1 := REG_Dout1;
						nT2 := REG_Dout2;
						nstate_counter := "00";
					end if;

					if (state_counter = "00") then
						next_state := S2;
						nstate_counter := "10";
					end if;

 			 when S2 =>
			 		if (state_counter = "10") then
							nALU_A := T1;
							nALU_B := T2;
						if(Instruction = "0010") then
							nALU_OP := "10";
						else
							nALU_OP := "00";
						end if;
						nstate_counter := "01";
			 		end if;

					if (state_counter = "01") then
						nT3 := ALU_O;
						nC := ALU_C;
						nZ := ALU_Z;
						nstate_counter := "00";
					end if;

					if (state_counter = "00") then
						next_state := S3;
						nstate_counter := "10";
					end if;

			 when S3 =>
					 if (state_counter = "10") then
						 nREG_A1 := rRC;
						 nREG_Din1 := T3;
						 nREG_W1 := ((not rC) and (not rZ)) or (rC and (not rZ) and C0) or (rZ and (not rC) and Z0)   ;
					   nstate_counter := "01";
					 end if;
					 if (state_counter = "01") then
						 phi_c0 := '1';
						 phi_z0 := '1';
						 nREG_W1 := '0';
					   nstate_counter := "00";
					 end if;

					 if (state_counter = "00") then
						 next_state := S0;
					   nstate_counter := "10";
					 end if;

		 	when S4 =>
					if (state_counter = "10") then
						nREG_A1 := rRA;
					  nstate_counter := "01";
					end if;
					if (state_counter = "01") then
						nT1 := REG_Dout1;
						nT2 := sign_extender(iIm);
					  nstate_counter := "00";
					end if;
					if (state_counter = "00") then
						next_state := S5;
					  nstate_counter := "10";
					end if;

			when S5 =>
			 		if (state_counter = "10") then
							nALU_A := T1;
							nALU_B := T2;
							nALU_OP := "00";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT3 := ALU_O;
							nC := ALU_C;
							nZ := ALU_Z;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							if (Instruction = "0001") then
								next_state := S6;
							else
								next_state := S7;
							end if;
							nstate_counter := "10";
					end if;

			when S6 =>
					 if (state_counter = "10") then
						 nREG_A1 := rRB;
						 nREG_Din1 := T3;
						 nREG_W1 := '1';
					   nstate_counter := "01";
					 end if;
					 if (state_counter = "01") then
						 phi_c0 := not IR(14);  -- Changin carry flag only for ADI and not for LW
						 phi_z0 := '1';
						 nREG_W1 := '0';
					   nstate_counter := "00";
					 end if;
					 if (state_counter = "00") then
						 next_state := S0;
					   nstate_counter := "10";
					 end if;

 		 when S7 =>
				 if (state_counter = "10") then
					 nMEM_A := T3;
				   nstate_counter := "01";
				 end if;
				 if (state_counter = "01") then
					 nT3 := MEM_Dout;
				   nstate_counter := "00";
				 end if;
				 if (state_counter = "00") then
					 next_state := S6;
				   nstate_counter := "10";
				 end if;

	   when S8 =>
				 if (state_counter = "10") then
					 nREG_A1 := rRA;
					 nREG_Din1 := zero_extender(jIm);
				   nREG_W1 := '1';
					 nstate_counter := "01";
				 end if;
				 if (state_counter = "01") then
					 nREG_W1 := '0';
				   nstate_counter := "00";
				 end if;
				 if (state_counter = "00") then
					 next_state := S0;
				   nstate_counter := "10";
				 end if;

		 when S9 =>
					if (state_counter = "10") then
						nREG_A1 := rRA;
					  nstate_counter := "01";
					end if;
					if (state_counter = "01") then
						nT1 := REG_Dout1;
						nT2 := sign_extender(iIm);
					  nstate_counter := "00";
					end if;
					if (state_counter = "00") then
						next_state := S10;
					  nstate_counter := "10";
					end if;

		 when S10 =>
					if (state_counter = "10") then
						nALU_A := T1;
						nALU_B := T2;
						nREG_A1 := rRA;
					  nstate_counter := "01";
					end if;
					if (state_counter = "01") then
						nT1 := ALU_O;
						nZ := ALU_C;
						nT2 := REG_Dout1;
						phi_z0 := '1';
					  nstate_counter := "00";
					end if;
					if (state_counter = "00") then
						next_state := S11;
					  nstate_counter := "10";
					end if;

			when S11 =>
 					if (state_counter = "10") then
 						nMEM_A := T1;
 						nMEM_Din := T2;
						nMEM_W := '1';
						nstate_counter := "01";
 					end if;
 					if (state_counter = "01") then
				  	nstate_counter := "00";
 					end if;
 					if (state_counter = "00") then
 						next_state := S0;
 					  nstate_counter := "10";
 					end if;

			when S12 =>
 					if (state_counter = "10") then
						nREG_A1 := rRA;
						nREG_A2 := rRB;
						nALU_A := IP;
						nALU_B := ONE;
						nALU_OP := "01";
						nstate_counter := "01";
 					end if;
 					if (state_counter = "01") then
						nT1 := REG_Dout1;
						nT2 := REG_Dout2;
						nT3 := nALU_O;
				  	nstate_counter := "00";
 					end if;
 					if (state_counter = "00") then
 						next_state := S13;
 					  nstate_counter := "10";
 					end if;

		when S13 =>
					if (state_counter = "10") then
						nALU_A := T3;
						nALU_B := sign_extender(iIm);
						nALU_OP := "00";
						nstate_counter := "01";
					end if;
					if (state_counter = "01") then
						nT3 := ALU_O;
						nstate_counter := "00";
					end if;
					if (state_counter = "00") then
						next_state := S14;
					  nstate_counter := "10";
					end if;

			when S14 =>
 					if (state_counter = "10") then
						nALU_A := T1;
						nALU_B := T2;
						nALU_OP := "01";
						nstate_counter := "01";
 					end if;
 					if (state_counter = "01") then
						nZ := ALU_Z;
						phi_z0 := '1';
						nstate_counter := "00";
 					end if;
 					if (state_counter = "00") then
 						next_state := S15;
 					  nstate_counter := "10";
 					end if;

			when S15 =>
 					if (nZ = '1') then
						nIP := T3;
 					end if;
					next_state := S0;

			when S16 =>
 					if (state_counter = "10") then
							nALU_A := IP;
							nALU_B := ONE;
							nALU_OP := "01";
							nstate_counter := "01";
 					end if;
 					if (state_counter = "01") then
							nT1 := ALU_O;
							nstate_counter := "00";
 					end if;
 					if (state_counter = "00") then
 							next_state := S17;
 					  	nstate_counter := "10";
 					end if;

		when S17 =>
					if (state_counter = "10") then
							nREG_A1 := rRA;
							nREG_A2 := rRB;
							nREG_Din1 := T1;
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nIP := REG_Dout2;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S0;
					  	nstate_counter := "10";
					end if;

			when S18 =>
					if (state_counter = "10") then
							nALU_A := IP;
							nALU_B := ONE;
							nALU_OP := "01";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT1 := ALU_O;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S19;
							nstate_counter := "10";
					end if;

			when S19 =>
					if (state_counter = "10") then
							nALU_A := T1;
							nALU_B := sign_extender9(jIm);
							nALU_OP := "00";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT2 := ALU_O;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S20;
							nstate_counter := "10";
					end if;

			when S20 =>
					if (state_counter = "10") then
							nIP := T2;
							nREG_A1 := rRA;
							nREG_Din1 := T1;
							nREG_W1 := '1';
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nREG_W1 := '0';
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S0;
							nstate_counter := "10";
					end if;

			when S21 =>
					if (state_counter = "10") then
							nREG_A1 := rRA;
							nT2 := ALL_ONE;
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT1 := REG_Dout1;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S22;
							nstate_counter := "10";
					end if;

			when S22 =>
					if (state_counter = "10") then
							nMEM_A := T1;
							nALU_A := T2;
							nALU_B := ONE;
							nALU_OP := "00";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT3 := MEM_Dout;
							nT2 := ALU_O;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S23;
							nstate_counter := "10";
					end if;

			when S23 =>
					if (state_counter = "10") then
							nALU_A := T1;
							nALU_B := ONE;
							nALU_OP := "00";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nT1 := ALU_O;
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							next_state := S24;
							nstate_counter := "10";
					end if;

			when S24 =>
					if (state_counter = "10") then
							nREG_A1 := T2(2 downto 0);
							nREG_Din1 := T3;
							nREG_W1 := '1';
							nALU_A := T2;
							nALU_B := SEVEN;
							nALU_OP := "01";
							nstate_counter := "01";
					end if;
					if (state_counter = "01") then
							nZ := ALU_Z;
							nREG_W1 := '0';
							nstate_counter := "00";
					end if;
					if (state_counter = "00") then
							if (nZ = '0') then
								next_state := S22;
							else
								next_state := S0;
							end if;
							nstate_counter := "10";
					end if;


			 when others => null;
     end case;


     if(rising_edge(clk)) then
          if (RST = '1') then
             	fsm_state_symbol <= S0;
						 	IP <= Z16;
							IR <= Z16;

							T1 <= Z16;
							T2 <= Z16;
							T3 <= Z16;

							C0 <= '0';
							Z0 <= '0';

							state_counter <= "10";
          else
							ALU_A <= nALU_A;
							ALU_B <= nALU_B;
							ALU_OP <= nALU_OP;

							MEM_A <= nMEM_A;
							MEM_Din <= nMEM_Din;
							MEM_W <= nMEM_W;

							REG_A1 <= nREG_A1;
							REG_Din1 <= nREG_Din1;
							REG_A2 <= nREG_A2;
							REG_Din2 <= nREG_Din2;
							REG_W1 <= nREG_W1;
							REG_W2 <= nREG_W2;

							IP <= nIP;
							IR <= nIR;

							T1 <= nT1;
							T2 <= nT2;
							T3 <= nT3;

							C0 <= (nC and phi_c0) or (C0 and (not phi_c0));
							Z0 <= (nZ and phi_z0) or (Z0 and (not phi_z0));
							state_counter <= nstate_counter;
              fsm_state_symbol <= next_state;
          end if;
     end if;

  end process;




end architecture ; -- arch
