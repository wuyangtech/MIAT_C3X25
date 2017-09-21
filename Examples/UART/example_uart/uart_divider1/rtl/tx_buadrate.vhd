-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity tx_buadrate is
generic(
    buadrate_width    : integer := 32
);

port(
    tbr_i_clock             : in  std_logic;
    tbr_i_reset_n           : in  std_logic;
    
    tbr_i_enable            : in  std_logic;
    tbr_i_buadrate_width    : in  std_logic_vector((buadrate_width-1) downto 0);
    tbr_o_buadrate_tx       : out std_logic
);

end entity;

architecture rtl of tx_buadrate is
    
    signal r_cnt : std_logic_vector((buadrate_width-1) downto 0);
    signal r_btx : std_logic; -- tbr_o_buadrate_tx : output buffer

begin
    
    process(tbr_i_clock, tbr_i_reset_n)
    begin
        if tbr_i_reset_n = '0' then
            r_cnt <= (others => '0');
            r_btx <= '0';
        elsif rising_edge(tbr_i_clock) then
            if tbr_i_enable = '1' then
                if r_cnt < tbr_i_buadrate_width then
                    r_cnt <= r_cnt + '1';
                    r_btx <= '0';
                else
                    r_cnt <= (others => '0');
                    r_btx <= '1';
                end if;
            else
                r_cnt <= (others => '0');
            end if;
        end if;
    end process;
    
    -- output buffer
    tbr_o_buadrate_tx <= r_btx;
    
end rtl;