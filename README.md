# UnsignedNBitMultiplier
Unsigned Hardware Multiplier of N-Bit length (specified in generic parameter), written in VHDL-2008. 

## Example Usage
***From [SevenSegDisplayTest.vhd](https://github.com/bitbytebitco/UnsignedNBitMultiplier/blob/master/SevenSegDisplayTest.vhd)***

```
...
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
...
```

### Vivado Simulation Waveform
![Simulation Waveform](https://github.com/bitbytebitco/UnsignedNBitMultiplier/blob/master/nbit_hardware_multiplier_simulation.png?raw=true)

### Verified Synthesis
* Basys 3 
