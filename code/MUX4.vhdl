library ieee;
use ieee.std_logic_1164.all;
library work;
package MUX is
	component MUX_8 is
		port (
			S  : in std_logic_vector (2 downto 0);
			MD1, MD2, MD_1, MD_2 : in std_logic_vector(15 downto 0) ;
			Z : out std_logic_vector(15 downto 0)
		);
	end component MUX_8;

	component MUX_4 is
		port (
			S1, S0  : in std_logic;
			X1, X2, X3, X4 : in std_logic_vector(15 downto 0) ;
			Z : out std_logic_vector(15 downto 0)
		);
	end component MUX_4;
end package ; -- MUX

library ieee;
use ieee.std_logic_1164.all;
entity MUX_8 is
	port (
      S  : in std_logic_vector (2 downto 0);
      MD1, MD2, MD_1, MD_2 : in std_logic_vector(15 downto 0) ;
      Z : out std_logic_vector(15 downto 0)
	);
end entity MUX_8;
architecture arch of MUX_8 is

	begin
		genmux: for i in 0 to 15 generate
				Z(i) <= (MD1(i) and ((not S(2)) and (S(1) xor S(0)))) or (MD2(i) and ((not S(2)) and (S(1) and S(0)))) or (MD_1(i) and (S(2) and (S(1) xor S(0)))) or (MD_2(i) and (S(2) and (not (S(1) or S(0)))));
		end generate genmux;
end architecture ; -- arch


library ieee;
use ieee.std_logic_1164.all;
entity MUX_4 is
	port (
      S1, S0  : in std_logic;
      X1, X2, X3, X4 : in std_logic_vector(15 downto 0) ;
      Z : out std_logic_vector(15 downto 0)
	);
end entity MUX_4;
architecture arch of MUX_4 is

begin
	genmux: for i in 0 to 15 generate
			Z(i) <= (X1(i) and ((not S0) and (not S1))) or (X2(i) and ((not S1) and S0)) or (X3(i) and (S1 and (not S0))) or (X4(i) and (S0 and S1));
	end generate genmux;

end architecture ; -- arch
