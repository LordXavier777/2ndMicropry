-- CONDICION DE SIMULACION (ESCALAMIENTO TEMPORAL):
-- Dado que el reloj opera a 50 MHz (periodo de 20 ns), simular 2.02 
-- segundos de tiempo real requeriría procesar >101,000,000 de ciclos de reloj, 
-- excediendo la capacidad de trazado de ondas en ModelSim.
-- Por lo tanto, los tiempos de espera (wait for) de este Testbench están 
-- dimensionados a escala reducida. Para ejecutar esta prueba, se deben 
-- ajustar temporalmente los topes en 'pir_controller.vhd' a:
--   1) Filtro antirrebote (count)     = 4 ciclos
--   2) Presencia continua (count_2s)  = 15 ciclos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_system.all;

entity tb_top_system is
end entity tb_top_system;

architecture sim of tb_top_system is

    
    signal tb_clk     : std_logic := '0';
    signal tb_rst     : std_logic := '1'; 
    signal tb_pir_det : std_logic := '0';
                                                      -- señales para conectar el top_system
    signal tb_disp0   : std_logic_vector(6 downto 0);
    signal tb_disp1   : std_logic_vector(6 downto 0);
    signal tb_disp2   : std_logic_vector(6 downto 0);
    signal tb_disp3   : std_logic_vector(6 downto 0);

    -- Periodo de 20 ns para simular el reloj de 50 MHz de la FPGA
    constant clk_period : time := 20 ns;

begin

    
    DUT: entity work.top_system
        port map (
            clk     => tb_clk,
            rst     => tb_rst,
            pir_det => tb_pir_det,
            disp0   => tb_disp0,
            disp1   => tb_disp1,
            disp2   => tb_disp2,
            disp3   => tb_disp3
        );

    -- Proceso generador de reloj
    clk_process: process
    begin
        tb_clk <= '0';
        wait for clk_period / 2;
        tb_clk <= '1';
        wait for clk_period / 2;
    end process;

    -- Proceso de inyección de estímulos 
    stimulus: process
    begin
        
        -- CASO 1: Reinicio inicial del sistema
        tb_rst     <= '0';
        tb_pir_det <= '0';
        wait for clk_period * 3; -- Esperamos 60 ns
        
        tb_rst <= '1'; 
        wait for clk_period * 2;

        -- CASO 2: Prueba del Filtro Antirrebote (inyección de ruido falso)
        -- Como el filtro exige 4 ciclos estables (+ 2 de sincronización), 
        -- inyectamos un pulso corto de solo 2 ciclos para comprobar que lo ignora
        
        tb_pir_det <= '1';
        wait for clk_period * 2; 
        tb_pir_det <= '0';
        wait for clk_period * 4;
        

      
        -- CASO 3: Primera Detección Real (Lectura de ROM[0] = x"1A2B")
        tb_pir_det <= '1';
        wait for clk_period * 10; 
        tb_pir_det <= '0'; 
        wait for clk_period * 5;
                                -- Se guarda en RAM_RANDOM_MAP(0) = "10101" (posición física # 21)
                                -- y los displays muestran inmediatamente x"1A2B".

        
        -- CASO 4: Presencia Continua 
        
        tb_pir_det <= '1';
        
        -- 1) Tras pasar el filtro (6 ciclos), dispara el flanco inicial
        -- Lee ROM[1] = x"3C4D" y lo guarda en RAM_RANDOM_MAP(1) = "01100" (posición física 12)
        -- 2) Si dejamos la señal en '1' por otros 35 ciclos más, el contador count_2s
        --  llegará a 15 dos veces, disparando dos pulsos automáticos extra:
        --  Pulso extra 1: Lee ROM[2] = x"5E6F" -> RAM_RANDOM_MAP(2) = "00011"
        --  Pulso extra 2: Lee ROM[3] = x"777A" -> RAM_RANDOM_MAP(3) = "11010"
        
        wait for clk_period * 45;

        -- La persona finalmente se retira
        tb_pir_det <= '0';
        wait for clk_period * 10;

      
        -- CASO 5: Prueba de borrado (reset)
        tb_rst <= '0';
        wait for clk_period * 3;
        tb_rst <= '1';
        wait for clk_period * 5;

        -- Detenemos la simulación
        wait;
    end process;

end architecture;
