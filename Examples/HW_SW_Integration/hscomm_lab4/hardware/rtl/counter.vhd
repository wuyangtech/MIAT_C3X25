-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity counter is
generic(
    cnt_p_data_width : integer := 32
);
port(
    cnt_i_clock         : in  std_logic;
    cnt_i_reset_n       : in  std_logic;
    
    -- FSMC Part
    cnt_i_enable        : in  std_logic;
    cnt_i_clear         : in  std_logic;
    cnt_o_cntvalue      : out std_logic_vector((cnt_p_data_width-1) downto 0)
);
end entity;

architecture rtl of counter is

    signal r_cnt : std_logic_vector((cnt_p_data_width-1) downto 0);

begin

    process(cnt_i_clock, cnt_i_reset_n)
    begin
        if cnt_i_reset_n = '0' then
            r_cnt <= (others => '0');
        elsif rising_edge(cnt_i_clock) then
            if cnt_i_clear = '1' then
                r_cnt <= (others => '0');
            elsif cnt_i_enable = '1' then
                r_cnt <= r_cnt + '1';
            else
                r_cnt <= r_cnt;
            end if;
        end if;
    end process;
    
    cnt_o_cntvalue <= r_cnt;

end rtl;