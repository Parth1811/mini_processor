library ieee ;
use ieee.std_logic_1164.all;

entity nand_16bit is
  port ( A : in std_logic_vector (15 downto 0);
         B : in std_logic_vector (15 downto 0);
         nand_out : out std_logic_vector (15 downto 0)) ;
end entity ;

architecture Equations of nand_16bit is

  begin

    genNand: for I in 0 to 15 generate
      nand_out(I) <= not (A(I) and B(I));
    end generate genNand;

  end Equations;
