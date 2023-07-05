----------------------------------------------------------------------
-- File name   : SevenSegDisplayTest.vhd
--
-- Project     : SevenSegDisplayTest
--
-- Description : Top file implementing 32-bit hardware multiplier on
--               a Basys 3 board. 
--
-- Author(s)   : Zachary Becker
--               bitbytebitco@gmail.com
----------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity SevenSegDisplayTest is
    Port ( clock_100Mhz : in STD_LOGIC;
           sw      : in std_logic_vector(7 downto 0);
           reset : in std_logic;
           an      : out std_logic_vector(3 downto 0);
           an_conf : in std_logic_vector(1 downto 0);
           i_display : in std_logic_vector(1 downto 0);
           seg     : out std_logic_vector(6 downto 0));
end SevenSegDisplayTest;

architecture Behavioral of SevenSegDisplayTest is

    signal hex : std_logic_vector( 3 downto 0);
    signal refresh_counter: STD_LOGIC_VECTOR (19 downto 0);
    signal LED_activating_counter: std_logic_vector(1 downto 0);
    
    signal A, B, C, D, offset: integer := 0;

    constant n : integer := 32; -- # of Bits in Multiplier
    signal displayed_number: STD_LOGIC_VECTOR ((n-1) downto 0) := std_logic_vector(to_unsigned(0,n));
    signal w_A, w_B : std_logic_vector( (n-1) downto 0);
    signal w_P : std_logic_vector( ((n*2)-1) downto 0);
    
    component UnsignedNBitMultiplier
        generic (
            bits_wide : integer := 32
        );
        port(
            i_A : in std_logic_vector( (n-1) downto 0);
            i_B : in std_logic_vector( (n-1) downto 0);
            o_prod : out std_logic_vector( ((n*2)-1) downto 0)
        );
    end component;
    
begin

    MUL : UnsignedNBitMultiplier 
        generic map (
            bits_wide => n
        )
        port map(
            i_A => w_A, 
            i_B => w_B,
            o_prod => w_P); 

    --displayed_number <= x"0001" + x"0004";
    
    CNT : process(clock_100Mhz,reset)
        begin 
            if(reset='1') then
                refresh_counter <= (others => '0');
            elsif(rising_edge(clock_100Mhz)) then
                refresh_counter <= refresh_counter + 1;
            end if;
    end process;
         
    LED_activating_counter <= refresh_counter(19 downto 18);
    
    displayed_number <= x"FFFFFF" & sw;
    
    w_A <= displayed_number;
    w_B <= x"FFFFFFFF";
--    w_B <= std_logic_vector(to_unsigned(2,n));


    CHAR : process(hex)
        begin
        
            case i_display is
                when "00" =>
                    offset <= 0;
                when "01" => 
                    offset <= 16;
                when "10" => 
                    offset <= 32;
                when "11" => 
                    offset <= 48;
            end case;
        
            A <= 3 + offset;
            B <= A + 4;
            C <= B + 4;
            D <= C + 4;
        
            case an_conf is
                when "00" =>    -- Display SW number
                                      
                    case LED_activating_counter is
                        when "00" =>
                            an <= "0111"; 
                            -- activate LED1 and Deactivate LED2, LED3, LED4
                            hex <= displayed_number(D downto D-3);
                            -- the first hex digit of the 16-bit number
                        when "01" =>
                            an <= "1011"; 
                            -- activate LED2 and Deactivate LED1, LED3, LED4
                            hex <= displayed_number(C downto C-3);
                            -- the second hex digit of the 16-bit number
                        when "10" =>
                            an <= "1101"; 
                            -- activate LED3 and Deactivate LED2, LED1, LED4
                            hex <= displayed_number(B downto B-3);
                            -- the third hex digit of the 16-bit number
                        when "11" =>
                            an <= "1110"; 
                            -- activate LED4 and Deactivate LED2, LED3, LED1
                            hex <= displayed_number(A downto A-3);
                    end case;
                when "01" =>    -- Display --                    
                when "10" =>    -- Display Multiplication
                
                    -- 31 30 29 28 | 27 26 25 24 | 23 22 21 20 | 19 18 17 16 | 15 14 13 12 | 11 10 9 8 | 7 6 5 4 | 3 2 1 0 
                    
                    case LED_activating_counter is
                        when "00" =>
                            an <= "0111"; 
                            -- activate LED1 and Deactivate LED2, LED3, LED4                        
--                            hex <= w_P(15 downto 12);
                            hex <= w_P(D downto D-3);
                            -- the first hex digit of the 16-bit number
                        when "01" =>
                            an <= "1011"; 
                            -- activate LED2 and Deactivate LED1, LED3, LED4
--                            hex <= w_P(11 downto 8);
                            hex <= w_P(C downto C-3);
                            -- the second hex digit of the 16-bit number
                        when "10" =>
                            an <= "1101"; 
                            -- activate LED3 and Deactivate LED2, LED1, LED4
--                            hex <= w_P(7 downto 4);
                            hex <= w_P(B downto B-3);
                            -- the third hex digit of the 16-bit number
                        when "11" =>
                            an <= "1110"; 
                            -- activate LED4 and Deactivate LED2, LED3, LED1
--                            hex <= w_P(3 downto 0);
                            hex <= w_P(A downto A-3);
                    
                    end case;
                when others => 
                    case LED_activating_counter is
                        when "00" =>
                            an <= "0111"; 
                            hex <= x"0";
                        when "01" =>
                            an <= "1011"; 
                            hex <= x"0";
                        when "10" =>
                            an <= "1101"; 
                            hex <= x"0";
                        when "11" =>
                            an <= "1110"; 
                            hex <= x"0";
                    end case;
                end case;
end process;
        

    CHAR_DECODE : process (hex)
        begin
        --an <= an_conf
        case hex is
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1001111"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when "1010" => seg <= "0001000"; -- a
            when "1011" => seg <= "0000011"; -- b
            when "1100" => seg <= "1000110"; -- C
            when "1101" => seg <= "0100001"; -- d
            when "1110" => seg <= "0000110"; -- E
            when "1111" => seg <= "0001110"; -- F
            when others => seg <= "1111111"; 
        end case;
    end process;
end Behavioral;
