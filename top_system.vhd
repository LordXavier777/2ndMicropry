library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity top_system is
    port(
        clk      : in std_logic;
        rst      : in std_logic; 
        pir_det  : in std_logic; 
        disp0    : out std_logic_vector(6 downto 0);
        disp1    : out std_logic_vector(6 downto 0);
        disp2    : out std_logic_vector(6 downto 0);
        disp3    : out std_logic_vector(6 downto 0)
    );
end entity top_system;

architecture structural of top_system is
    signal sig_pir_pls  : std_logic;
    signal sig_we_ram   : std_logic;
    signal sig_rom_addr : std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
    signal sig_ram_addr : std_logic_vector(RAM_ADDR_WIDTH-1 downto 0);
    signal sig_rom_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sig_ram_data : std_logic_vector(DATA_WIDTH-1 downto 0);
begin

    U_PIR: entity work.pir_controller
        port map (
            clk     => clk,
            rst     => rst,
            pir_in  => pir_det,
            pir_pulse => sig_pir_pls
        );

    U_FSM: entity work.control_unit
        port map (
            clk      => clk,
            rst      => rst,
            pir_pls  => sig_pir_pls,
            we_ram   => sig_we_ram,
            rom_addr => sig_rom_addr,
            ram_addr => sig_ram_addr
        );

    U_ROM: entity work.rom_memory
        port map (
            clk      => clk,
            rom_addr => sig_rom_addr,
            rom_data => sig_rom_data
        );

    U_RAM: entity work.ram_memory
        port map (
            clk      => clk,
            rst      => rst, 
            we       => sig_we_ram,
            ram_addr => sig_ram_addr,
            data_in  => sig_rom_data,
            data_out => sig_ram_data
        );
        
    disp0 <= hex_to_7seg(sig_ram_data(3 downto 0));
    disp1 <= hex_to_7seg(sig_ram_data(7 downto 4));
    disp2 <= hex_to_7seg(sig_ram_data(11 downto 8));
    disp3 <= hex_to_7seg(sig_ram_data(15 downto 12));

end architecture structural;