-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity yuv_converter is
generic(
    yuvc_datawidth      : integer := 8
);
port(
    yuvc_i_clock        : in  std_logic;
    yuvc_i_reset_n      : in  std_logic;
    
    yuvc_i_rdata        : in  std_logic_vector((yuvc_datawidth-1) downto 0);
    yuvc_i_gdata        : in  std_logic_vector((yuvc_datawidth-1) downto 0);
    yuvc_i_bdata        : in  std_logic_vector((yuvc_datawidth-1) downto 0);
    
    yuvc_o_ydata        : out std_logic_vector((yuvc_datawidth-1) downto 0);
    yuvc_o_udata        : out std_logic_vector((yuvc_datawidth-1) downto 0);
    yuvc_o_vdata        : out std_logic_vector((yuvc_datawidth-1) downto 0)
);
end entity;

architecture rtl of yuv_converter is

    -- signal r_rd : std_logic_vector((yuvc_datawidth-1) downto 0);
    -- signal r_gd : std_logic_vector((yuvc_datawidth-1) downto 0);
    -- signal r_bd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_yd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_ud : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_vd : std_logic_vector((yuvc_datawidth-1) downto 0);    
    signal w_yd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ud : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);

begin
    
    -- process(yuvc_i_clock, yuvc_i_reset_n)
    -- begin
        -- if yuvc_i_reset_n = '0' then
            -- r_rd <= (others => '0');
            -- r_gd <= (others => '0');
            -- r_bd <= (others => '0');
        -- elsif rising_edge(yuvc_i_clock) then
            -- r_rd <= yuvc_i_rdata;
            -- r_gd <= yuvc_i_gdata;
            -- r_bd <= yuvc_i_bdata;
        -- end if;
    -- end process;
    
    -- w_yd <= X"1000" + (X"42"*r_rd) + (X"82"*r_gd) + (X"1A"*r_bd);
    -- w_ud <= X"8000" + (X"71"*r_rd) - (X"5F"*r_gd) - (X"13"*r_bd);
    -- w_vd <= X"8000" - (X"26"*r_rd) - (X"4B"*r_gd) + (X"71"*r_bd);
    w_yd <= X"1000" + (X"42"*yuvc_i_rdata) + (X"82"*yuvc_i_gdata) + (X"1A"*yuvc_i_bdata);
    w_ud <= X"8000" + (X"71"*yuvc_i_rdata) - (X"5F"*yuvc_i_gdata) - (X"13"*yuvc_i_bdata);
    w_vd <= X"8000" - (X"26"*yuvc_i_rdata) - (X"4B"*yuvc_i_gdata) + (X"71"*yuvc_i_bdata);
    
    process(yuvc_i_clock, yuvc_i_reset_n)
    begin
        if yuvc_i_reset_n = '0' then
            r_yd <= (others => '0');
            r_ud <= (others => '0');
            r_vd <= (others => '0');
        elsif rising_edge(yuvc_i_clock) then
            r_yd <= w_yd(15 downto 8);
            r_ud <= w_ud(15 downto 8);
            r_vd <= w_vd(15 downto 8);
        end if;
    end process;
    
    yuvc_o_ydata <= r_yd;
    yuvc_o_udata <= r_ud;
    yuvc_o_vdata <= r_vd;
    
end rtl;