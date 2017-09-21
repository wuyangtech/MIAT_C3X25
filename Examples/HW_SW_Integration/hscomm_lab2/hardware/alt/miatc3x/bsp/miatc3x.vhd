-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity miatc3x is
port 
(
    c3x_clock50m    : in  std_logic;
    -- c3x_clock24m    : in  std_logic;
    
-- DIP SWITCH
    c3x_dipsw0      : in    std_logic;
    -- c3x_dipsw1      : in    std_logic;
    -- c3x_dipsw2      : in    std_logic;
    -- c3x_dipsw3      : in    std_logic;
    
-- GPIO
    c3x_gpio_b1     : inout std_logic_vector(33 downto 0) -- all free
    -- c3x_gpio_b1_16     : out std_logic;
    -- c3x_gpio_b1_17     : in  std_logic;
    
-- Dummy Pad
);

end entity;

architecture rtl of miatc3x is

    signal w_fsmc_clock : std_logic;
    signal w_fsmc_enable_n : std_logic;
    signal w_fsmc_read_n : std_logic;
    signal w_fsmc_write_n : std_logic;
    signal w_fsmc_bank : std_logic_vector(1 downto 0);
    signal w_fsmc_readdata : std_logic_vector(15 downto 0);
    signal w_fsmc_writedata : std_logic_vector(15 downto 0);
    signal w_fsmc_address : std_logic_vector(11 downto 0);
    
    component pll100
    port(
        inclk0  : in  std_logic  := '0';
        c0      : out std_logic 
    );
    end component;
    
    component reset_delay is
    port(
        rstd_i_clock            : in  std_logic;
        rstd_i_reset_n          : in  std_logic;
        rstd_o_reset10u_n       : out std_logic
    );
    end component reset_delay;
    
    component fsmc_swrapper is
    generic(
        fsmcsw_p_data_width : integer := 16;
        fsmcsw_p_addr_width : integer := 12;
        fsmcsw_p_cnt_width : integer := 32
    );
    port(
        fsmcsw_i_clock          : in  std_logic;
        fsmcsw_i_reset_n        : in  std_logic;
        
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
    end component;
    
    component counter is
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
    end component;
    
    signal w_pll100m : std_logic;
    signal w_dreset_n : std_logic;
    
    signal w_cnten  : std_logic;
    signal w_cntclr  : std_logic;
    signal w_cntvalue : std_logic_vector(31 downto 0);
    
begin
    
    -- PLL 100Mhz
    pll100_0: pll100
    port map(
        inclk0 => c3x_clock50m,
        c0 => w_pll100m
    );
    
    -- Reset Delay
    reset_delay_0: reset_delay
    port map(
        rstd_i_clock => w_pll100m,
        rstd_i_reset_n => c3x_dipsw0,
        rstd_o_reset10u_n => w_dreset_n
    );
    
    w_fsmc_clock <= c3x_gpio_b1(0);
    w_fsmc_enable_n <= c3x_gpio_b1(1);
    w_fsmc_read_n <= c3x_gpio_b1(2);
    w_fsmc_write_n <= c3x_gpio_b1(3);
    w_fsmc_bank <= c3x_gpio_b1(15 downto 14);
    w_fsmc_writedata <= c3x_gpio_b1(21 downto 6);
    c3x_gpio_b1(21 downto 6) <= w_fsmc_readdata when w_fsmc_read_n = '0' else (others => 'Z');
    w_fsmc_address <= c3x_gpio_b1(33 downto 22);
    
    -- FSMC Slave Wrapper
    fsmc_swrapper_0: fsmc_swrapper
    generic map(
        fsmcsw_p_data_width => 16,
        fsmcsw_p_addr_width => 12
    )
    port map(
        fsmcsw_i_clock => w_pll100m,
        fsmcsw_i_reset_n => w_dreset_n,        
        fsmcsw_i_enable_n => w_fsmc_enable_n,
        fsmcsw_i_address => w_fsmc_address,
        fsmcsw_i_read_n => w_fsmc_read_n,
        fsmcsw_o_readdata => w_fsmc_readdata,
        fsmcsw_i_write_n => w_fsmc_write_n,
        fsmcsw_i_writedata => w_fsmc_writedata,
        fsmcsw_o_cnten => w_cnten,
        fsmcsw_o_cntclr => w_cntclr,
        fsmcsw_i_cntvalue => w_cntvalue
    );
    
    -- Counter
    counter_0: counter
    generic map(
        cnt_p_data_width => 32
    )
    port map(
        cnt_i_clock => w_pll100m,
        cnt_i_reset_n => w_dreset_n,
        
        -- FSMC Part
        cnt_i_enable => w_cnten,
        cnt_i_clear => w_cntclr,
        cnt_o_cntvalue => w_cntvalue
    );
    
end rtl;
