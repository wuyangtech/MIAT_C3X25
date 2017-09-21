-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity buadrate is
generic(
    buadrate_width    : integer := 32
);
port(
    brg_i_clock             : in  std_logic;
    brg_i_reset_n           : in  std_logic;
    
    brg_i_enable            : in  std_logic;
    brg_i_buadrate_width    : in  std_logic_vector((buadrate_width-1) downto 0);
    brg_o_buadrate_ref      : out std_logic
);
end entity;

architecture rtl of buadrate is
    
    signal r_cnt : std_logic_vector((buadrate_width-1) downto 0);
    signal r_ref : std_logic; -- brg_o_buadrate_ref : output buffer

begin
    
    process(brg_i_clock, brg_i_reset_n)
    begin
        if brg_i_reset_n = '0' then
            r_cnt <= (others => '0');
            r_ref <= '0';
        elsif rising_edge(brg_i_clock) then
            if brg_i_enable = '1' then
                if r_cnt < brg_i_buadrate_width then
                    r_cnt <= r_cnt + '1';
                    r_ref <= '0';
                else
                    r_cnt <= (others => '0');
                    r_ref <= '1';
                end if;
            else
                r_cnt <= (others => '0');
            end if;
        end if;
    end process;
    
    -- output buffer
    brg_o_buadrate_ref <= r_ref;
    
end rtl;