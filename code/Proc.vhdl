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
							nALU_B := "0000000000000001";
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
						next_state := S1;
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
						if(Instruction = "0000") then
							nALU_OP := "00";
						else
							nALU_OP := "10";
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
					   nstate_counter := "00";
					 end if;

					 if (state_counter = "00") then
						 next_state := S0;
					   nstate_counter := "10";
					 end if;



       -- when C1 =>
       --      s_var := not a xor b;
       --      if (a = '0' and b = '0') then
       --          nq_var := C0;
       --      else
       --          nq_var := C1;
       --      end if;

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
