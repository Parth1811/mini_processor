library ieee;
use ieee.std_logic_1164.all;
library work;
package Compliment is
	component TwosCompliment is
		port (
			X : in std_logic_vector (15 downto 0);
			Z : out std_logic_vector(15 downto 0)
		);
	end component TwosCompliment;
end package ; -- Compliment

library ieee;
use ieee.std_logic_1164.all;
entity TwosCompliment is
	port (
      X : in std_logic_vector(15 downto 0);
      Z : out std_logic_vector(15 downto 0)
	);
end entity TwosCompliment;
architecture arch of TwosCompliment is
	component adder_16bit  is
		port ( a : in std_logic_vector (15 downto 0);
	         b : in std_logic_vector (15 downto 0);
	         sum : out std_logic_vector (15 downto 0)) ;
	end component;

  signal T : std_logic_vector(15 downto 0);
begin

	gentcs: for i in 0 to 15 generate
			T(i) <= not X(i);
	end generate gentcs;

	fa: adder_16bit
	port map (
			a => T,
			b => "0000000000000001",
			sum => Z
	);

end architecture ; -- arch
