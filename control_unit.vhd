library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity control_unit is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        pir_pls  : in std_logic;
        we_ram   : out std_logic;
        rom_addr : out std_logic_vector(ROM_ADDR_WIDTH-1 downto 0);
        ram_addr : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0)
    );
end entity control_unit;

architecture rtl of control_unit is
    type fsm_state is (S_IDLE, S_READ_ROM, S_WRITE_RAM);
    signal current_state, next_state : fsm_state;
    
    signal ptr_reg, ptr_next : unsigned(RAM_ADDR_WIDTH-1 downto 0);
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                current_state <= S_IDLE;
               
                ptr_reg <= (others => '1'); 
            else
                current_state <= next_state;
                ptr_reg <= ptr_next;
            end if;
        end if;
    end process;

    process(current_state, pir_pls, ptr_reg)
    begin
        next_state <= current_state;
        ptr_next <= ptr_reg;
        we_ram <= '0';

        case current_state is
            when S_IDLE =>
                if pir_pls = '1' then
                    ptr_next <= ptr_reg + 1; 
                    next_state <= S_READ_ROM;
                end if;
                
            when S_READ_ROM =>
                next_state <= S_WRITE_RAM;
                
            when S_WRITE_RAM =>
                we_ram <= '1';
                next_state <= S_IDLE; 
                
            when others =>
                next_state <= S_IDLE;
        end case;
    end process;
    
    rom_addr <= std_logic_vector(ptr_reg(ROM_ADDR_WIDTH-1 downto 0));
    ram_addr <= RAM_RANDOM_MAP(to_integer(ptr_reg));
    
end architecture;