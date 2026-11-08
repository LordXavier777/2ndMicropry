library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity ram_memory is
    port(
        clk      : in std_logic; --reloj de sincronizacion
        rst      : in std_logic; --boton de reinicio
        we       : in std_logic; --habilidator de escritura (write enable)
        ram_addr : in std_logic_vector(RAM_ADDR_WIDTH-1 downto 0); -- bus de direcciones de 5 bits (Para las 32 posiciones)
        data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0); -- Bus de datos para la recibir la palabra de 16 bits
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0) --bus de datos para enviar el dato de 16 bits
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
                data_out <= RAM_CONTENT(to_integer(unsigned(ram_addr))); -- WRITE-FIRST (implicito) ya que al estar después de la escritura y dentro del 
            end if;                                                      -- mismo proceso síncrono, esto garantiza que si entra un nuevo dato, se refleje 
        end if;                                                          -- instantáneamente en los display sin ciclos de retardo
    end process;
end architecture;