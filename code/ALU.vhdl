library ieee;
use ieee.std_logic_1164.all;
--use work.MUX4.all;
use work.all;

entity ALU is
	port (
		A, B	: in std_logic_vector(15 downto 0);
		OP 		: in std_logic_vector(1 downto 0);
		O 		: out std_logic_vector(15 downto 0);
		C, Z	: out std_logic
	);
end entity ALU;

architecture arch of ALU is
	constant Z16 : std_logic_vector(15 downto 0)  := (others  => '0');
	signal P, Q, R, Out_signal  : std_logic_vector(15 downto 0);

	component adder_16bit is
    port ( A : in std_logic_vector (15 downto 0);
           B : in std_logic_vector (15 downto 0);
           sum : out std_logic_vector (15 downto 0);
			  Cout: out std_logic
			 ) ;
  end component;

	component subtractor_16bit is
	  port ( A : in std_logic_vector (15 downto 0);
	         B : in std_logic_vector (15 downto 0);
	         diff : out std_logic_vector (15 downto 0)) ;
	end component ;

	component nand_16bit is
	  port ( A : in std_logic_vector (15 downto 0);
	         B : in std_logic_vector (15 downto 0);
	         nand_out : out std_logic_vector (15 downto 0)) ;
	end component;

	component MUX_4 is
		port (
	      S1, S0  : in std_logic;
	      X1, X2, X3, X4 : in std_logic_vector(15 downto 0) ;
	      Z : out std_logic_vector(15 downto 0)
		);
	end component;

begin
	add: adder_16bit
		port map (A => A, B => B, sum => P, Cout => C);

	subtractor: subtractor_16bit
		port map (A => A, B => B, diff => Q);

	nand1: nand_16bit
		port map (A => A, B => A, nand_out => R);

	mux_alu: MUX_4
		port map (X1 => P, X2 => Q ,X3 => R, X4 => Z16, S0 => OP(0), S1 => OP(1), Z => Out_signal);

	Z <= 	'1' when (Out_signal = Z16) else
				'0';

	O <= Out_signal;

end architecture ; -- arch
