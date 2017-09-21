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

    -- order 0
    signal r_rd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_gd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_bd : std_logic_vector((yuvc_datawidth-1) downto 0);
        
    -- order 1
    signal w_ymp1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ymp2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ymp3 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ump1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ump2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ump3 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vmp1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vmp2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vmp3 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    
    -- order 2
    signal w_yop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_yop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_uop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_uop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vop1 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vop2 : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    
    -- order 3
    signal w_yd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_ud : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal w_vd : std_logic_vector(((yuvc_datawidth*2)-1) downto 0);
    signal r_yd : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_ud : std_logic_vector((yuvc_datawidth-1) downto 0);
    signal r_vd : std_logic_vector((yuvc_datawidth-1) downto 0);

begin
    
    -- order 0
    process(yuvc_i_clock, yuvc_i_reset_n)
    begin
        if yuvc_i_reset_n = '0' then
            r_rd <= (others => '0');
            r_gd <= (others => '0');
            r_bd <= (others => '0');
        elsif rising_edge(yuvc_i_clock) then
            r_rd <= yuvc_i_rdata;
            r_gd <= yuvc_i_gdata;
            r_bd <= yuvc_i_bdata;
        end if;
    end process;
    
    -- w_yd <= (X"1000" + (X"42"*r_rd)) + ((X"82"*r_gd) + (X"1A"*r_bd));
    -- w_ud <= (X"8000" + (X"71"*r_rd)) - ((X"5F"*r_gd) + (X"13"*r_bd));
    -- w_vd <= (X"8000" + (X"71"*r_bd)) - ((X"26"*r_rd) + (X"4B"*r_gd));
    
    -- order 1
    w_ymp1 <= ("00"&r_rd&"000000") + ("0000000"&r_rd&"0");
    w_ymp2 <= ("0"&r_gd&"0000000") + ("0000000"&r_gd&"0");
    w_ymp3 <= ("0000"&r_bd&"0000") + ("00000"&r_bd&"000") + ("0000000"&r_bd&"0");
    
    w_ump1 <= ("00"&r_rd&"000000") + ("000"&r_rd&"00000") + ("0000"&r_rd&"0000") + ("00000000"&r_rd);
    w_ump2 <= ("00"&r_gd&"000000") + ("0000"&r_gd&"0000") + ("00000"&r_gd&"000") + ("000000"&r_gd&"00") + ("0000000"&r_gd&"0") + ("00000000"&r_gd);
    w_ump3 <= ("0000"&r_bd&"0000") + ("0000000"&r_bd&"0") + ("00000000"&r_bd);
    
    w_vmp1 <= ("000"&r_rd&"00000") + ("000000"&r_rd&"00") + ("0000000"&r_rd&"0");
    w_vmp2 <= ("00"&r_gd&"000000") + ("00000"&r_gd&"000") + ("0000000"&r_gd&"0") + ("00000000"&r_gd);
    w_vmp3 <= ("00"&r_bd&"000000") + ("000"&r_bd&"00000") + ("0000"&r_bd&"0000") + ("00000000"&r_bd);
    
    -- order 2   
    w_yop1 <= X"1000" + w_ymp1;
    w_yop2 <= w_ymp2 + w_ymp3;
    w_uop1 <= X"8000" + w_ump1;
    w_uop2 <= w_ump2 + w_ump3;
    w_vop1 <= X"8000" + w_vmp3;
    w_vop2 <= w_vmp1 + w_vmp2;
    
    -- order 3
    w_yd <= w_yop1 + w_yop2;
    w_ud <= w_uop1 - w_uop2;
    w_vd <= w_vop1 - w_vop2;
    
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
    
    -- output buffer
    yuvc_o_ydata <= r_yd;
    yuvc_o_udata <= r_ud;
    yuvc_o_vdata <= r_vd;
    
end rtl;