library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pkg_system is
    constant DATA_WIDTH : integer := 16; -- centraliza la geometria de las memorias para que en caso de que se modifique algo, estos cambios se propaguen
    constant ROM_ADDR_WIDTH : integer := 4; -- automaticamente a cada uno de los modulos sin necesidad de aplicar los cambios archivo por archivo
    constant RAM_ADDR_WIDTH : integer := 5; 
    
    type rom_array is array (0 to (2**ROM_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    type ram_array is array (0 to (2**RAM_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- vector de acceso aleatorio para la RAM (32 posiciones desordenadas, valores de 0 a 31), también conocido como Look Up Table (LUT)
    type random_map_array is array (0 to 31) of std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
    constant RAM_RANDOM_MAP : random_map_array := (
        "10101", "01100", "00011", "11010", "11111", "00001", "11001", "01110", -- 21, 12, 3, 26, 31, 1, 25, 14,
        "10000", "01000", "10010", "10111", "11011", "00100", "11101", "00110", -- 16, 8, 18, 23, 27, 4, 29, 6,
        "00101", "11100", "10011", "01010", "01111", "10001", "01001", "11110", -- 5, 28, 19, 10, 15, 17, 9, 30,
        "00000", "11000", "00010", "00111", "01011", "10100", "01101", "10110"  -- 0, 24, 2, 7, 11, 20, 13, 22
    );

    function hex_to_7seg(hex : std_logic_vector(3 downto 0)) return std_logic_vector;
end package pkg_system;

package body pkg_system is
    function hex_to_7seg(hex : std_logic_vector(3 downto 0)) return std_logic_vector is  --Funcion que convierte hexadecimal 7 segmentos (De 4 bits a 7 bits)
        variable seg : std_logic_vector(6 downto 0);
    begin
        case hex is
            when x"0" => seg := "1000000";  
            when x"1" => seg := "1111001";
            when x"2" => seg := "0100100";
            when x"3" => seg := "0110000";
            when x"4" => seg := "0011001";
            when x"5" => seg := "0010010";
            when x"6" => seg := "0000010";
            when x"7" => seg := "1111000";
            when x"8" => seg := "0000000";
            when x"9" => seg := "0010000";
            when x"A" => seg := "0001000";
            when x"B" => seg := "0000011";
            when x"C" => seg := "1000110";
            when x"D" => seg := "0100001";
            when x"E" => seg := "0000110";
            when x"F" => seg := "0001110";
            when others => seg := "1111111";
        end case;
        return seg;
    end function;
end package body pkg_system;

