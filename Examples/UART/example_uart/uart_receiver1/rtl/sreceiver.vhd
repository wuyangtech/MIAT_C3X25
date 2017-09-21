-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity sreceiver is
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

end entity;

architecture rtl of sreceiver is
    
    component buadrate is
    generic(
        buadrate_width          : integer := 32
    );
    port(
        brg_i_clock             : in  std_logic;
        brg_i_reset_n           : in  std_logic;
        
        brg_i_enable            : in  std_logic;
        brg_i_buadrate_width    : in  std_logic_vector((buadrate_width-1) downto 0);
        brg_o_buadrate_ref      : out std_logic
    );
    end component buadrate;

    component sp_converter is
    generic(
        readdata_width          : integer := 8
    );
    port(
        spc_i_clock             : in  std_logic;
        spc_i_reset_n           : in  std_logic;
        
        spc_i_enable            : in  std_logic;
        spc_i_refbuadrate       : in  std_logic;
        spc_i_rx                : in  std_logic;
        spc_o_readdate          : out std_logic_vector((readdata_width-1) downto 0);
        spc_o_enbuadrate        : out std_logic;
        spc_o_done              : out std_logic
    );
    end component sp_converter;
    
    signal w_enbuadrate : std_logic;
    signal w_refbuadrate : std_logic;
    
begin
    
    brg_0: buadrate
    generic map(
        buadrate_width => srx_buadrate_width
    )
    port map(
        brg_i_clock => srx_i_clock,
        brg_i_reset_n => srx_i_reset_n,
        brg_i_enable => w_enbuadrate,
        brg_i_buadrate_width => srx_i_buadrate_width,
        brg_o_buadrate_ref => w_refbuadrate
    );
    
    spc_0: sp_converter
    generic map(
        readdata_width => srx_readdata_width
    )
    port map(
        spc_i_clock => srx_i_clock,
        spc_i_reset_n => srx_i_reset_n,
        spc_i_enable => srx_i_enable,
        spc_i_refbuadrate => w_refbuadrate,
        spc_i_rx => srx_i_rx,
        spc_o_readdate => srx_o_readdata,
        spc_o_enbuadrate => w_enbuadrate,
        spc_o_done => srx_o_done
    );

    
end rtl;