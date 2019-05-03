library ieee ;
use ieee.std_logic_1164.all;

entity adder_16bit is
  port ( A : in std_logic_vector (15 downto 0);
         B : in std_logic_vector (15 downto 0);
         sum : out std_logic_vector (15 downto 0);
         Cout: out std_logic
       );
end entity ;

architecture Equations of adder_16bit is
  signal Carry : std_logic_vector( 16 downto 0 );

  begin
    Carry(0 downto 0) <= "0";

    genAdd: for I in 0 to 15 generate
      sum(I) <= a(I) xor b(I) xor Carry(I);
      Carry(I+1) <= ((a(I) or b(I)) and Carry(I)) or (a(I) and b(I));
    end generate genAdd;

    Cout <= Carry(16);

  end Equations;
