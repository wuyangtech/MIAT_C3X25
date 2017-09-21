-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity fsmc_swrapper is
generic(
    fsmcsw_p_data_width : integer := 16;
    fsmcsw_p_addr_width : integer := 12;
    fsmcsw_p_cnt_width : integer := 32
);
port(
    fsmcsw_i_clock          : in  std_logic;
    fsmcsw_i_reset_n        : in  std_logic;
    
    -- FSMC Part
    fsmcsw_i_enable_n       : in  std_logic;
    fsmcsw_i_address        : in  std_logic_vector((fsmcsw_p_addr_width-1) downto 0);
    fsmcsw_i_read_n         : in  std_logic;
    fsmcsw_o_readdata       : out std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    fsmcsw_i_write_n        : in  std_logic;
    fsmcsw_i_writedata      : in  std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    
    -- Counter
    fsmcsw_o_cnten          : out std_logic;
    fsmcsw_o_cntclr         : out std_logic;
    fsmcsw_i_cntvalue       : in  std_logic_vector((fsmcsw_p_cnt_width-1) downto 0)
);
end entity;

architecture rtl of fsmc_swrapper is
    
    signal w_sw_read : std_logic;
    signal w_sw_write : std_logic;
    
    signal r_sw_readdata : std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    
    signal r_swreg_0 : std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    signal r_swreg_1 : std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    signal r_swreg_2 : std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    signal r_swreg_3 : std_logic_vector((fsmcsw_p_data_width-1) downto 0);
    
begin
    
    w_sw_read <= '1' when (fsmcsw_i_enable_n = '0') and (fsmcsw_i_read_n = '0') else '0';
    w_sw_write <= '1' when (fsmcsw_i_enable_n = '0') and (fsmcsw_i_write_n = '0') else '0';
    
    -- write phase
    process(fsmcsw_i_clock, fsmcsw_i_reset_n)
    begin
        if fsmcsw_i_reset_n = '0' then
            r_swreg_0 <= (others => '0');
            r_swreg_1 <= (others => '0');
            r_swreg_2 <= (others => '0');
            r_swreg_3 <= (others => '0');
        elsif rising_edge(fsmcsw_i_clock) then
            if w_sw_write = '1' then
                case fsmcsw_i_address is
                    when "000000000000" =>
                        r_swreg_0 <= fsmcsw_i_writedata;
                    
                    when "000000000001" =>
                        r_swreg_1 <= fsmcsw_i_writedata;
                    
                    -- when "000000000010" =>
                        -- r_swreg_2 <= fsmcsw_i_writedata;
                        
                    -- when "000000000011" =>
                        -- r_swreg_3 <= fsmcsw_i_writedata;
                        
                    when others =>                    
                    
                end case;
            else
                
            end if;
        end if;        
    end process;
    
    -- read phase
    process(fsmcsw_i_clock, fsmcsw_i_reset_n)
    begin
        if fsmcsw_i_reset_n = '0' then
            r_sw_readdata <= (others => '0');

        elsif rising_edge(fsmcsw_i_clock) then
            if w_sw_read = '1' then
                case fsmcsw_i_address is
                    when "000000000000" =>
                        r_sw_readdata <= r_swreg_0;
                    
                    when "000000000001" =>
                        r_sw_readdata <= r_swreg_1;
                    
                    when "000000000010" =>
                        r_sw_readdata <= fsmcsw_i_cntvalue(15 downto 0);
                        
                    when "000000000011" =>
                        r_sw_readdata <= fsmcsw_i_cntvalue(31 downto 16);
                        
                        
                    when others =>                    
                    
                end case;
            else
                
            end if;
        end if;        
    end process;
    
    fsmcsw_o_readdata <= r_sw_readdata;
    
    fsmcsw_o_cnten <= r_swreg_0(15);
    fsmcsw_o_cntclr <= r_swreg_0(0);
    
end rtl;