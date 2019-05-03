library ieee ;
use ieee.std_logic_1164.all;

entity subtractor_16bit is
  port ( A : in std_logic_vector (15 downto 0);
         B : in std_logic_vector (15 downto 0);
         diff : out std_logic_vector (15 downto 0)) ;
end entity ;

architecture Equations of subtractor_16bit is

  signal B_minus: std_logic_vector(15 downto 0);
	signal C_trash: std_logic;

  component adder_16bit is
    port ( A : in std_logic_vector (15 downto 0);
           B : in std_logic_vector (15 downto 0);
           sum : out std_logic_vector (15 downto 0);
				   Cout: out std_logic
			   );
  end component;

  component TwosCompliment is
		port (
			X : in std_logic_vector (15 downto 0);
			Z : out std_logic_vector(15 downto 0)
		);
	end component;

begin

  tc : TwosCompliment
      port map( X => B, Z => B_minus);

  sub_add : adder_16bit
      port map( A => A, B => B_minus, sum => diff, Cout=> C_trash );

  end Equations;
