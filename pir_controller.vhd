library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pir_controller is
    port(
        clk     : in std_logic;
        rst     : in std_logic;     
        pir_in  : in std_logic;   
        pir_pulse : out std_logic
    );
end entity pir_controller;

architecture rtl of pir_controller is
    signal sync1, sync2 : std_logic;
    signal btn_stable   : std_logic;
    signal btn_prev     : std_logic;
    
    
    signal count        : unsigned(19 downto 0); 
    signal count_2s     : unsigned(26 downto 0); 
	 
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '0' then
                
                sync1 <= '0';
                sync2 <= '0';
                btn_stable <= '0';
                btn_prev <= '0';
                pir_pls <= '0';
                count <= (others => '0');
                count_2s <= (others => '0');
            else
               
                sync1 <= pir_in;
                sync2 <= sync1;
                
                
                if sync2 = btn_stable then
                    count <= (others => '0');
                else
                    count <= count + 1;
                    if count = 1000000 then 
                        btn_stable <= sync2;
                        count <= (others => '0');
                    end if;
                end if;
                
              
                btn_prev <= btn_stable;
                
              
                pir_pls <= '0';

                if (btn_prev = '0' and btn_stable = '1') then
                    -
                    pir_pls <= '1';
                    count_2s <= (others => '0'); 
                    
                elsif btn_stable = '1' then
                    
                    count_2s <= count_2s + 1;
                    
                    if count_2s = 100000000 then
                        pir_pls <= '1';              
                        count_2s <= (others => '0'); 
                    end if;
                    
                else
                    
                    count_2s <= (others => '0');
                end if;
                
            end if;
        end if;
    end process;
end architecture;