library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Register_File is
	port (
				A1, A2       : in std_logic_vector(2 downto 0);
				Din1, Din2 	 : in std_logic_vector(15 downto 0);
	 			clk, W1, W2  : in std_logic;
				Dout1, Dout2 : out std_logic_vector(15 downto 0)
			 );
end entity;

architecture Form of Register_File is
	type regarray is array(7 downto 0) of std_logic_vector(15 downto 0);   -- defining a new type
	signal REG_file:
		regarray:=(
					0 => x"7874",
					1 => x"f020",
					2 => x"a457",
					3 => x"4472",
					4 => x"0458",
					5 => x"2460",
					6 => x"2921",
					7 => x"0000");
begin

  Dout1 <= REG_file(conv_integer(A1));
	Dout2 <= REG_file(conv_integer(A2));
	REG_Write: process (W1 , W2, A1, A2, clk)
		begin
      if(rising_edge(clk)) then
			  if(W1 = '1') then
					REG_file(conv_integer(A1)) <= Din1;
				end if;
        if(W2 = '1') then
          REG_file(conv_integer(A2)) <= Din2;
        end if;
			end if;
	end process;

end Form;
