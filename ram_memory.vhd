library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity ram_memory is
    port(
        clk      : in std_logic;
        rst      : in std_logic; 
        we       : in std_logic;
        ram_addr : in std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
        data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity ram_memory;

architecture rtl of ram_memory is
    signal RAM_CONTENT : ram_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                
                RAM_CONTENT <= (others => (others => '0'));
                data_out <= (others => '0');
            else
                if we = '1' then
                    RAM_CONTENT(to_integer(unsigned(ram_addr))) <= data_in;
                end if;
                data_out <= RAM_CONTENT(to_integer(unsigned(ram_addr)));
            end if;
        end if;
    end process;
end architecture rtl;