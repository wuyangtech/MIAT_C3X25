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
    c3x_gpio_b1     : inout std_logic_vector(33 downto 0); -- all free
    -- c3x_gpio_b1_16     : out std_logic;
    -- c3x_gpio_b1_17     : in  std_logic;
    
-- Dummy Pad
    c3x_dummypad    : out   std_logic
);

end entity;

architecture rtl of miatc3x is

    component reset_delay is
    port(
        rstd_i_clock            : in  std_logic;
        rstd_i_reset_n          : in  std_logic;
        rstd_o_reset10u_n       : out std_logic
    );
    end component reset_delay;
    
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
    end component stransmitter;
    
    component sreceiver is
    generic(
        srx_readdata_width      : integer := 8;
        srx_buadrate_width      : integer := 32
    );
    port(
        srx_i_clock             : in  std_logic;
        srx_i_reset_n           : in  std_logic;
        
        srx_i_enable            : in  std_logic;
        srx_i_buadrate_width    : in  std_logic_vector((srx_buadrate_width-1) downto 0);
        srx_i_rx                : in  std_logic;
        srx_o_readdata          : out std_logic_vector((srx_readdata_width-1) downto 0);
        srx_o_done              : out std_logic
    );
    end component sreceiver;

    signal w_delay_rst_n : std_logic;
    
    signal r_testen : std_logic;
    signal w_rxd_readdata : std_logic_vector(7 downto 0);
    signal w_rxd_done : std_logic;
    
begin
    
    delay_0: reset_delay
    port map(
        rstd_i_clock => c3x_clock50m,
        rstd_i_reset_n => c3x_dipsw0,
        rstd_o_reset10u_n => w_delay_rst_n
    );
    
    txd_0: stransmitter
    generic map(
        writedata_width => 8,
        buadrate_width => 32
    )
    port map(
        stx_i_clock => c3x_clock50m,
        stx_i_reset_n => w_delay_rst_n,
        stx_i_enable => w_rxd_done,
        stx_i_buadrate_width => "00000000000000000000000110110001",
        stx_i_writedata => (w_rxd_readdata + '1'),
        -- stx_o_done => ,
        stx_o_tx => c3x_gpio_b1(16)
        -- stx_o_tx => c3x_gpio_b1_16
    );
    
    rxd_0: sreceiver
    generic map(
        srx_readdata_width => 8,
        srx_buadrate_width => 32
    )
    port map(
        srx_i_clock => c3x_clock50m,
        srx_i_reset_n => w_delay_rst_n,
        srx_i_enable => r_testen,
        srx_i_buadrate_width => "00000000000000000000000000011011",
        srx_i_rx => c3x_gpio_b1(17),
        -- srx_i_rx => c3x_gpio_b1_17,
        srx_o_readdata => w_rxd_readdata,
        srx_o_done => w_rxd_done
    );
    
    -- test enable
    process(c3x_clock50m, w_delay_rst_n)
    begin
        if w_delay_rst_n = '0' then
            r_testen <= '0';
        elsif rising_edge(c3x_clock50m) then
            r_testen <= '1';
            
            
            
        end if;
    end process;
    
end rtl;
