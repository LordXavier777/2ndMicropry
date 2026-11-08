library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pir_controller is
    port(
        clk     : in std_logic; -- Reloj (FPGA)
        rst     : in std_logic;  -- Botón de reinicio   
        pir_in  : in std_logic;  -- señal asincrónica que recibe del sensor con posible ruido
        pir_pulse : out std_logic -- salida síncrona / pulso estable
    );
end entity pir_controller;

architecture rtl of pir_controller is
    signal sync1, sync2 : std_logic; -- señales para el sincronizador de etapas (dos flip-flop), evita que la metaestabilidad colapse la FSM
	 
    signal btn_stable, btn_prev  : std_logic; -- señales para el etapa de filtrado, detección de flancos y pulsos
   
    
    signal count        : unsigned(19 downto 0); --Señal para contabilizar que el pulso sea estable, al menos por 20 ms (por ende necesitamos 20 bits, 2^20 es
																-- suficiente para contar hasta un millón)

	 Signal count_2s     : unsigned(26 downto 0); -- Señal para el temporizador de presencia continua, evita que el sistema se estanque en caso de que la persona no
											                -- se mueva, se requieren 27 bits para poder contar hasta 100 millones		 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                
                sync1 <= '0';
                sync2 <= '0';
                btn_stable <= '0';
                btn_prev <= '0';
                pir_pulse <= '0';
                count <= (others => '0');
                count_2s <= (others => '0');
            else
               
                sync1 <= pir_in;   -- Etapa de sincronización
                sync2 <= sync1;
                
                
                if sync2 = btn_stable then -- Etapa de filtrado
                    count <= (others => '0');
                else
                    count <= count + 1;
                    if count = 1000000 then 
                        btn_stable <= sync2;
                        count <= (others => '0');
                    end if;
                end if;
                
              
                btn_prev <= btn_stable; -- Etapa de detección de flancos y pulsos
                
              
                pir_pulse <= '0'; -- fuerza a que el pulso caiga a '0' en el siguiente ciclo

                if (btn_prev = '0' and btn_stable = '1') then -- flanco de subida: el sensor acaba de pasar de vacío a detectar una presencia
                    
                    pir_pulse <= '1';
                    count_2s <= (others => '0');   -- dispara el pulso y reinicia el cronómetro de los dos segundos
                    
                elsif btn_stable = '1' then        -- para el caso de presencia continua
                    
                    count_2s <= count_2s + 1;
                    
                    if count_2s = 100000000 then    -- para que la unit_control siga rotando la memoria ram, se cuentan dos segundos
                        pir_pulse <= '1';              
                        count_2s <= (others => '0'); 
                    end if;
                    
                else
                    
                    count_2s <= (others => '0'); -- si no hay una presencia se reinicia el cronómetro para evitar tiempos fantasma que llevarían a un pulso erróneo
                end if;
                
            end if;
        end if;
    end process;
end architecture;