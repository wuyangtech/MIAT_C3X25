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
        fsmcsw_p_yuv_width : integer := 32;
        fsmcsw_p_cnt_width : integer := 32;
        fsmcsw_p_stx_bwidth : integer := 16;
        fsmcsw_p_stx_dwidth : integer := 8
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
        
        -- YCbCr
        fsmcsw_o_yuvdatain      : out std_logic_vector((fsmcsw_p_yuv_width-1) downto 0);
        fsmcsw_i_yuvdataout     : in  std_logic_vector((fsmcsw_p_yuv_width-1) downto 0);
        
        -- uart
        fsmcsw_o_stxen          : out std_logic;
        fsmcsw_o_stxperiod      : out std_logic_vector((fsmcsw_p_stx_bwidth-1) downto 0);
        fsmcsw_o_stxwritedata   : out std_logic_vector((fsmcsw_p_stx_dwidth-1) downto 0);
        fsmcsw_i_stxdone        : in  std_logic;
        
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
    
    component yuv_converter is
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
    end component;
    
    component stransmitter is
    generic(
        writedata_width         : integer := 8;
        buadrate_width          : integer := 32
    );
    port(
        stx_i_clock             : in  std_logic;
        stx_i_reset_n           : in  std_logic;
        
        stx_i_enable            : in  std_logic;
        stx_i_buadrate_width    : in  std_logic_vector((buadrate_width-1) downto 0);
        stx_i_writedata         : in  std_logic_vector((writedata_width-1) downto 0);
        stx_o_done              : out std_logic;
        stx_o_tx                : out std_logic
    );
    end component;
    
    signal w_pll100m : std_logic;
    signal w_dreset_n : std_logic;
    
    signal w_stxen : std_logic;
    signal w_stxperiod : std_logic_vector(15 downto 0);
    signal w_stxwritedata : std_logic_vector(7 downto 0);
    signal w_stxdone : std_logic;
    
    signal w_cnten  : std_logic;
    signal w_cntclr  : std_logic;
    signal w_cntvalue : std_logic_vector(31 downto 0);
    
    signal w_yuvdatain : std_logic_vector(31 downto 0);
    signal w_yuvdataout : std_logic_vector(31 downto 0);
    
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
    
    -- w_fsmc_clock <= c3x_gpio_b1(0);
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
        fsmcsw_o_yuvdatain => w_yuvdatain,
        fsmcsw_i_yuvdataout => w_yuvdataout,
        fsmcsw_o_stxen => w_stxen,
        fsmcsw_o_stxperiod => w_stxperiod,
        fsmcsw_o_stxwritedata => w_stxwritedata,
        fsmcsw_i_stxdone => w_stxdone,
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
    
    -- YCbCr
    yuv_converter_0: yuv_converter
    generic map(
        yuvc_datawidth => 8
    )
    port map(
        yuvc_i_clock => w_pll100m,
        yuvc_i_reset_n => w_dreset_n,        
        yuvc_i_rdata => w_yuvdatain(23 downto 16),
        yuvc_i_gdata => w_yuvdatain(15 downto 8),
        yuvc_i_bdata => w_yuvdatain(7 downto 0),        
        yuvc_o_ydata => w_yuvdataout(23 downto 16),
        yuvc_o_udata => w_yuvdataout(15 downto 8),
        yuvc_o_vdata => w_yuvdataout(7 downto 0)
    );
    
    -- tx
    stransmitter_0: stransmitter
    generic map(
        writedata_width => 8,
        buadrate_width => 16
    )
    port map(
        stx_i_clock => w_pll100m,
        stx_i_reset_n => w_dreset_n,        
        stx_i_enable => w_stxen,
        stx_i_buadrate_width => w_stxperiod,
        stx_i_writedata => w_stxwritedata,
        stx_o_done => w_stxdone,
        stx_o_tx => c3x_gpio_b1(0)
    );
    
    
end rtl;
