-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

    
entity stransmitter is
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

end entity;

architecture rtl of stransmitter is

    component buadrate is
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
    end component buadrate;

    component ps_converter is
    generic(
        writedata_width         : integer := 8
    );

    port(
        psc_i_clock             : in  std_logic;
        psc_i_reset_n           : in  std_logic;
        
        psc_i_enable            : in  std_logic;
        psc_i_refbuadrate       : in  std_logic;
        psc_i_writedata         : in  std_logic_vector((writedata_width-1) downto 0);
        psc_o_done              : out std_logic;
        psc_o_tx                : out std_logic
    );
    end component ps_converter;
    
    signal w_txb : std_logic;
    
begin
    
    brg_0: buadrate
    generic map(
        buadrate_width => buadrate_width
    )
    port map(
        brg_i_clock => stx_i_clock,
        brg_i_reset_n => stx_i_reset_n,
        brg_i_enable => '1',
        brg_i_buadrate_width => stx_i_buadrate_width,
        brg_o_buadrate_ref => w_txb
    );
    
    psc_0: ps_converter
    generic map(
        writedata_width => writedata_width
    )
    port map(
        psc_i_clock => stx_i_clock,
        psc_i_reset_n => stx_i_reset_n,
        psc_i_enable => stx_i_enable,
        psc_i_refbuadrate => w_txb,
        psc_i_writedata => stx_i_writedata,
        psc_o_done => stx_o_done,
        psc_o_tx => stx_o_tx
    );

    
end rtl;
