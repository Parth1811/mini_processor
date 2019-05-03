library ieee;
use ieee.std_logic_1164.all;
use work.16_bit_adder.all;
use work.1616_bit_subtractor.all;
use work.16_bit_nand.all;
use work.MUX4.all;

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
	signal P, Q, R  : std_logic_vector(15 downto 0);

begin
	add: adder_16bit
		port map (A => A, B => B, sum => P, Cout => C);

	subtractor: subtractor_16bit
		port map (A => A, B => B, diff => Q);

	nand1: nand_16bit
		port map (A => A, Y => A, nand_out => R);

	mux_alu: MUX_4
		port map (A0 => P, A1 => Q ,A2 => R, A3 => Z16, S0 => OP(0), S1 => OP(1), Z => O);

	Z <= 	'1' when (O = Z16) else
				'0';

end architecture ; -- arch
