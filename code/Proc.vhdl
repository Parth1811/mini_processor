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

  type StateSymbol is (S0, S0_set, Decode,S1);
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
	signal C0, Z0, Cn, Zn : std_logic;

	alias rRA is IR(11 downto 9);
	alias rRB is IR(8 downto 6);
	alias rRC is IR(5 downto 3);


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
     variable s_var  : std_logic;

		 variable nIP, nIR, nT1, nT2, nT3 : std_logic_vector(15 downto 0);

  begin
     next_state := fsm_state_symbol;

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

     -- compute next-state, output
		 -- add wave clk RST IP IR MEM_Dout
     case fsm_state_symbol is
       when S0 =>
			 		nMEM_A := IP;
					nALU_OP := "00";
					nALU_A := IP;
					nALU_B := "0000000000000001";
					next_state := S0_set;

		   when S0_set =>
					nIP := ALU_O;
					nIR := MEM_Dout;
					next_state := Decode;

  		 when Decode =>
			 		if (IR(15 downto 12) = "0000") then
						next_state := S1;
					else
						next_state := S0;
					end if;

 			 when S1 =>
					nREG_A1 := rRA;
					nREG_A2 := rRB;
					next_state := S0;
					nT1 := REG_Dout1;
					nT2 := REG_Dout2;


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

             fsm_state_symbol <= next_state;
          end if;
     end if;

  end process;




end architecture ; -- arch
