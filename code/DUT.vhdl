-- A DUT entity is used to wrap your design.
--  This example shows how you can do this for the
--  Full-adder.

library ieee;
use ieee.std_logic_1164.all;
entity DUT is
   port(input_vector: in std_logic_vector(33 downto 0);
       	output_vector: out std_logic_vector(17 downto 0));
end entity;

architecture DutWrap of DUT is
   component ALU is
     port (
   		A, B	: in std_logic_vector(15 downto 0);
   		OP 		: in std_logic_vector(1 downto 0);
   		O 		: out std_logic_vector(15 downto 0);
   		C, Z	: out std_logic
   	);
   end component;
begin

   -- input/output vector element ordering is critical,
   -- and must match the ordering in the trace file!
   add_instance: ALU
			port map (
					-- order of inputs Cin B A
          A => input_vector(33 downto 18),
          B => input_vector(17 downto 2),
          OP => input_vector(1 downto 0),
          O => output_vector(15 downto 0),
          C => output_vector(17),
					Z => output_vector(16)
        );

end DutWrap;
