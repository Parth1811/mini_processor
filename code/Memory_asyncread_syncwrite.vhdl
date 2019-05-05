library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- since The Memory is asynchronous read, there is no read signal, but you can use it based on your preference.
-- this memory gives 16 Bit data in one clock cycle, so edit the file to your requirement.

entity Memory_asyncread_syncwrite is
	port (
				A, Din : in std_logic_vector(15 downto 0);
	 			clk, W : in std_logic;
				Dout   : out std_logic_vector(15 downto 0)
			 );
end entity;

architecture Form of Memory_asyncread_syncwrite is
	type regarray is array(65535 downto 0) of std_logic_vector(15 downto 0);   -- defining a new type
	signal Memory:
		regarray:=(
				0 => "0000001010011000",
				1 => "0011011011011010",
				101 => "0010011011011010",
				2 => x"1057",
				3 => x"4442",
				4 => x"0458",
				5 => x"2460",
				6 => x"2921",
				7 => x"0000",
				8 => x"2921",
				9 => x"58c0",
				10 => x"7292",
				11 => x"6e60",
				12 => x"c040",
				13 => x"127f",
				14 => x"c241",
				16 => x"9440",
				22 => x"83f5",
				25 => x"ffed",
				others => "0000000000000000");
-- you can use the above mentioned way to initialise the memory with the instructions and the data as required to test your processor

begin

	Dout <= Memory(conv_integer(A));
	Mem_write:
	process (W,Din,A,clk)
		begin
			if(W = '0') then
				if(rising_edge(clk)) then
					Memory(conv_integer(A)) <= Din;
				end if;
			end if;
	end process;

end Form;
