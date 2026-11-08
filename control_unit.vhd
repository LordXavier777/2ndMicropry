library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity control_unit is -- Es la FSM que determina cuando se lee la ROM y es cuando es seguro escribir en la RAM (Orquesta el flujo de datos)
    port(
        clk      : in std_logic; --Reloj del sistema
        rst      : in std_logic; -- Reset del sistema
        pir_pls  : in std_logic; --Pulso que recibe del sensor PIR
        we_ram   : out std_logic; -- Habilitador de escritura
        rom_addr : out std_logic_vector(ROM_ADDR_WIDTH-1 downto 0); -- Direccion que envia a la ROM
        ram_addr : out std_logic_vector(RAM_ADDR_WIDTH-1 downto 0) -- Direccion que envia a la RAM
    );
end entity control_unit;

architecture rtl of control_unit is
    type fsm_state is (S_IDLE, S_READ_ROM, S_WRITE_RAM);
    signal current_state, next_state : fsm_state;
    
    signal ptr_reg, ptr_next : unsigned(RAM_ADDR_WIDTH-1 downto 0); --señal para los punteros de direcciones (5 bits ya que la RAM tiene 32 posiciones, como la
begin                                                               -- ROM solo tiene 16 posiciones, esta lee dos veces)
    process(clk) 
    begin
        if rising_edge(clk) then
            if rst = '0' then
                current_state <= S_IDLE;
               
                ptr_reg <= (others => '1'); -- cuando se reinicia se llena de unos para que cuando llegue el pulso del sensor, el puntero arranque en la posicion 0
            else
                current_state <= next_state;
                ptr_reg <= ptr_next;
            end if;
        end if;
    end process;

    process(current_state, pir_pls, ptr_reg)  -- Definicion de la transicion de estados
    begin
        next_state <= current_state;
        ptr_next <= ptr_reg;
        we_ram <= '0';

        case current_state is
            when S_IDLE =>  -- Estado de espera, solo transiciona una vez recibe el pulso limpio del PIR
                if pir_pls = '1' then
                    ptr_next <= ptr_reg + 1; 
                    next_state <= S_READ_ROM;
                end if;
                
            when S_READ_ROM =>
                next_state <= S_WRITE_RAM;  -- Estado para asegurar que el dato salga fisicamente de la ROM y viaje por el bus de datos antes de intentar escribirlo
                
            when S_WRITE_RAM => -- Levanta la bandera de escritura para la RAM
                we_ram <= '1';
                next_state <= S_IDLE; 
                
            when others =>
                next_state <= S_IDLE;
        end case;
    end process;
    
    rom_addr <= std_logic_vector(ptr_reg(ROM_ADDR_WIDTH-1 downto 0)); --Asignacion de la direccion para la ROM (estrictamente lineal)
    ram_addr <= RAM_RANDOM_MAP(to_integer(ptr_reg)); -- Asignacion de la direccion para la RAM mediante el "traductor" LUT
                                                     --Ambas asignaciones usan el puntero como direccion
end architecture;