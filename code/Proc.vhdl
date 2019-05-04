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
			A1, A2, Din1, Din2 : in std_logic_vector(15 downto 0);
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

  type StateSymbol is (S0, S1);
  signal fsm_state_symbol: StateSymbol;

	signal ALU_A, ALU_B, ALU_O : std_logic_vector(15 downto 0);
	signal ALU_OP : std_logic_vector(1 downto 0);
	signal ALU_C, ALU_Z : std_logic;

	signal MEM_A, MEM_Din, MEM_Dout: std_logic_vector(15 downto 0);
	signal MEM_W: std_logic;

	signal REG_A1, REG_Din1, REG_Dout1, REG_A2, REG_Din2, REG_Dout2: std_logic_vector(15 downto 0);
	signal REG_W1, REG_W2: std_logic;

	signal IP, IR, T1, T2, T3 : std_logic_vector(15 downto 0);
	signal C0, Z0, Cn, Zn : std_logic;

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


  process(clk, RST)
		 variable nALU_A, nALU_B, nALU_O : std_logic_vector(15 downto 0);
		 variable nALU_OP : std_logic_vector(1 downto 0);
		 variable nALU_C, nALU_Z : std_logic;

		 variable nMEM_A, nMEM_Din, nMEM_Dout: std_logic_vector(15 downto 0);
		 variable nMEM_W: std_logic;

		 variable nREG_A1, nREG_Din1, nREG_Dout1, nREG_A2, nREG_Din2, nREG_Dout2: std_logic_vector(15 downto 0);
		 variable nREG_W1, nREG_W2: std_logic;

		 variable next_state : StateSymbol;
     variable s_var  : std_logic;

		 variable nIP, nIR, nT1, nT2, nT3 : std_logic_vector(15 downto 0);

  begin
     next_state := fsm_state_symbol;

		 nALU_A := ALU_A;
		 nALU_B := ALU_B;
		 nALU_O := ALU_O;
		 nALU_OP := ALU_OP;
		 nALU_C := ALU_C;

		 nMEM_A := MEM_A;
		 nMEM_Din := MEM_Din;
		 nMEM_Dout := MEM_Dout;
		 nMEM_W := MEM_W;

		 nREG_A1 := REG_A1;
		 nREG_Din1 := REG_Din1;
		 nREG_Dout1 := REG_Dout1;
		 nREG_A2 := REG_A2;
		 nREG_Din2 := REG_Din2;
		 nREG_Dout2 := REG_Dout2;
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
			 		nIP := "0000000000000001";
			 		nMEM_A := nIP;
					nIR := nMEM_Dout;
					nALU_A := nIP;
					nALU_B := "0000000000000001";
					nIP := nALU_O;
					next_state := S1;

		   when S1 =>
					 nMEM_A := nIP;
					 nIR := nMEM_Dout;
					 nALU_A := nIP;
					 nALU_B := "0000000000000001";
					 nIP := nALU_O;


       -- when C1 =>
       --      s_var := not a xor b;
       --      if (a = '0' and b = '0') then
       --          nq_var := C0;
       --      else
       --          nq_var := C1;
       --      end if;

			 when others => null;
     end case;


     if(clk'event and clk='1') then
          if (RST = '1') then
             fsm_state_symbol <= S0;
          else
							ALU_A <= nALU_A;
							ALU_B <= nALU_B;
							ALU_O <= nALU_O;
							ALU_OP <= nALU_OP;
							ALU_C <= nALU_C;

							MEM_A <= nMEM_A;
							MEM_Din <= nMEM_Din;
							MEM_Dout <= nMEM_Dout;
							MEM_W <= nMEM_W;

							REG_A1 <= nREG_A1;
							REG_Din1 <= nREG_Din1;
							REG_Dout1 <= nREG_Dout1;
							REG_A2 <= nREG_A2;
							REG_Din2 <= nREG_Din2;
							REG_Dout2 <= nREG_Dout2;
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
