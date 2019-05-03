library ieee;
use ieee.std_logic_1164.all;
library work;
package MUX4 is
	component MUX_4 is
		port (
			S1 , S0  : in std_logic;
			A0, A1, A2, A3 : in std_logic_vector(15 downto 0) ;
			Z : out std_logic_vector(15 downto 0)
		);
	end component MUX_4;

end package ; -- MUX4
library ieee;
use ieee.std_logic_1164.all;
entity MUX_4 is
	port (
		S1 , S0        : in  std_logic;
		A0, A1, A2, A3 : in  std_logic_vector(15 downto 0);
		Z              : out std_logic_vector(15 downto 0)
	);
end entity MUX_4;
architecture arch of MUX_4 is
begin
	Z  <= 	A0 when (S1 = '0' AND S0 = '0') else
			A1 when (S1 = '0' AND S0 = '1') else
			A2 when (S1 = '1' AND S0 = '0') else
			A3 when (S1 = '1' AND S0 = '1') else
			"00000000";
end architecture ; -- arch
