library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_system is
    constant DATA_WIDTH : integer := 16;
    constant ROM_ADDR_WIDTH : integer := 4; 
    constant RAM_ADDR_WIDTH : integer := 5; 
    
    type rom_array is array (0 to (2**ROM_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type ram_array is array (0 to (2**RAM_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Vector de acceso aleatorio para la RAM (32 posiciones desordenadas, valores de 0 a 31)
    type random_map_array is array (0 to 31) of std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
    constant RAM_RANDOM_MAP : random_map_array := (
        "10101", "01100", "00011", "11010", "11111", "00001", "11001", "01110", -- 21, 12, 3, 26, 31, 1, 25, 14
        "10000", "01000", "10010", "10111", "11011", "00100", "11101", "00110", -- 16, 8, 18, 23, 27, 4, 29, 6
        "00101", "11100", "10011", "01010", "01111", "10001", "01001", "11110", -- 5, 28, 19, 10, 15, 17, 9, 30
        "00000", "11000", "00010", "00111", "01011", "10100", "01101", "10110"  -- 0, 24, 2, 7, 11, 20, 13, 22
    );

end package pkg_system;

