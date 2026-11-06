library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity rom_memory is
    port(
        clk      : in std_logic;
        rom_addr : in std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
        rom_data : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity rom_memory;

architecture rtl of rom_memory is
    constant ROM_CONTENT : rom_array := (
        0 => x"1A2B", 1 => x"3C4D", 2 => x"5E6F", 3 => x"789A",
        4 => x"BCDE", 5 => x"F012", 6 => x"3456", 7 => x"7890",
        8 => x"A1B2", 9 => x"C3D4", 10=> x"E5F6", 11=> x"0987",
        12=> x"FACE", 13=> x"B00C", 14=> x"D00D", 15=> x"CAFE"
    );
begin
    process(clk)
    begin
        if rising_edge(clk) then
            rom_data <= ROM_CONTENT(to_integer(unsigned(rom_addr)));
        end if;
    end process;
end architecture rtl;