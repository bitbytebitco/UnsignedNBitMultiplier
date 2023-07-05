----------------------------------------------------------------------
-- File name   : UnsignedNBitMultiplier.vhd
--
-- Project     : UnsignedNBitMultiplier
--
-- Description : An Unsigned Integer Multiplier of N-bit length, which
--               can be spec'd through the generic param. `bits_wide`
--
-- Author(s)   : Zachary Becker
--               bitbytebitco@gmail.com
----------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UnsignedNBitMultiplier is
    generic (
        bits_wide : integer := 32
    );
    port(
        i_A : in std_logic_vector( (bits_wide-1) downto 0);
        i_B : in std_logic_vector( (bits_wide-1) downto 0);
        o_prod : out std_logic_vector( ((bits_wide*2)-1) downto 0)
    );
end entity;

architecture UnsignedNBitMultiplier_arch of UnsignedNBitMultiplier is

        constant n : integer := bits_wide; -- # of Bits in Multiplier
        signal k : integer := 0;
        
       
        -- NBit
        signal c: std_logic_vector( (n*(n-1)-1) downto 0);           -- (8*7)-1 --> 55
        signal ands : std_logic_vector( ((n*n)-1) downto 0);
        signal sums : std_logic_vector( (n*(n-1)-1) downto 0);
       
        
        component full_adder is
            port(fa_A, fa_B, fa_Cin  : in std_logic;
                 fa_Sum, fa_Cout: out std_logic);
        end component;

    begin
         
        -- generate `ands` values    
        i_gen: for i in 0 to n-1 generate
            j_gen : for j in 0 to n-1 generate
                ands((n*i + j)) <= i_A(j) and i_B(i);
            end generate;
        end generate;
          
        -- generate `sums` and `c` (carry-outs)
        k_gen: for k in 0 to (n-2) generate
            in1: if (k = 0) generate -- first row
                l0a : for l in 0 to (n-1) generate
                    l0a0: if( l = 0 ) generate -- first column 
                        uu : full_adder port map (fa_A => ands(1), fa_B => ands(n), fa_Cin => '0', fa_Sum => sums(0), fa_Cout => c(0) );
                    end generate;
                    l0a1 : if (l>0 and l <= (n-2)) generate -- middle columns 
                        uu : full_adder port map (fa_A => ands(l+1), fa_B => ands(n+l), fa_Cin => c(l-1), fa_Sum => sums(l), fa_Cout => c(l) );       
                    end generate;
                    l0a2 : if (l = (n-1)) generate -- last column 
                        uu : full_adder port map (fa_A => '0', fa_B => ands((n*2)-1), fa_Cin => c(l-1), fa_Sum => sums(l), fa_Cout => c(l) );       
                    end generate;
                end generate l0a;
            end generate in1;
            
            in2: if (k > 0) generate -- all other rows
                l0b : for l in 0 to (n-1) generate
                    l0b0: if( l = 0 ) generate -- first column 
                        uu : full_adder port map (fa_A => sums(((k-1)*n)+(l+1)), fa_B => ands(n*(k+1)), fa_Cin => '0', fa_Sum => sums((n*k)), fa_Cout => c((n*k)) );
                    end generate;
                    l0b1 : if (l>0 and l <= (n-2)) generate -- middle columns 
                        uu : full_adder port map (fa_A => sums((n*(k-1))+(l+1)), fa_B => ands((n*(k+1))+l), fa_Cin => c((n*k)+l-1), fa_Sum => sums((n*(k))+l), fa_Cout => c((n*(k))+l) );       
                    end generate;
                    l0b2 : if (l = (n-1)) generate -- last column 
                        uu : full_adder port map (fa_A => c((n*k)-1), fa_B => ands((n*(k+1))+l), fa_Cin => c((n*k)+(l-1)), fa_Sum => sums((n*k)+l), fa_Cout => c((n*k)+l) );       
                    end generate;   
                end generate;
            end generate in2;
            
        end generate;
        
     
        
        -- LSB to MSB Binary Output   
        o_prod(0) <= ands(0); -- BIT0
        output1 : for o in 1 to (n-1) generate 
            o_prod(o) <= sums(n*(o-1));
        end generate;
        
        output2 : for p in 0 to (n-2) generate
            o_prod(n+p) <= sums(((n-2)*n)+(p+1));
        end generate;
        
        o_prod((n*2)-1) <= c(n*(n-1)-1); 
        
        
         
end architecture;
