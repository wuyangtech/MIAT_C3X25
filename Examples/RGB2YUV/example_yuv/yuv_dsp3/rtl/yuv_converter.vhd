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

    signal r_rd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_gd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_bd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_yd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_ud : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_vd : std_logic_vector((yuvc_datawidth-1) downto 0);
    
    signal r_yop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_yop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_uop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_uop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_vop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_vop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    
    signal w_yop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_yop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_uop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_uop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    
    signal w_yd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ud : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);

begin
    
    process(yuvc_i_clock, yuvc_i_reset_n)
    begin
        if yuvc_i_reset_n = '0' then
            r_rd <= (others => '0');
            r_gd <= (others => '0');
            r_bd <= (others => '0');
            r_yd <= (others => '0');
            r_ud <= (others => '0');
            r_vd <= (others => '0');
        elsif rising_edge(yuvc_i_clock) then
            r_rd <= yuvc_i_rdata;
            r_gd <= yuvc_i_gdata;
            r_bd <= yuvc_i_bdata;
            
            r_yd <= w_yd(15 downto 8);
            r_ud <= w_ud(15 downto 8);
            r_vd <= w_vd(15 downto 8);
        end if;
    end process;
    
    process(yuvc_i_clock, yuvc_i_reset_n)
    begin
        if yuvc_i_reset_n = '0' then
            r_yop1 <= (others => '0');
            r_yop2 <= (others => '0');
            r_uop1 <= (others => '0');
            r_uop2 <= (others => '0');
            r_vop1 <= (others => '0');
            r_vop2 <= (others => '0');
        elsif rising_edge(yuvc_i_clock) then
            r_yop1 <= w_yop1;
            r_yop2 <= w_yop2;
            r_uop1 <= w_uop1;
            r_uop2 <= w_uop2;
            r_vop1 <= w_vop1;
            r_vop2 <= w_vop2;
        end if;
    end process;
    
    w_yop1 <= (X"1000" + (X"42"*r_rd));
    w_yop2 <= ((X"82"*r_gd) + (X"1A"*r_bd));
    w_uop1 <= (X"8000" + (X"71"*r_rd));
    w_uop2 <= ((X"5F"*r_gd) + (X"13"*r_bd));
    w_vop1 <= (X"8000" + (X"71"*r_bd));
    w_vop2 <= ((X"26"*r_rd) + (X"4B"*r_gd));
    
    w_yd <= r_yop1 + r_yop2;
    w_ud <= r_uop1 - r_uop2;
    w_vd <= r_vop1 - r_vop2;
    
    yuvc_o_ydata <= r_yd;
    yuvc_o_udata <= r_ud;
    yuvc_o_vdata <= r_vd;
    
end rtl;