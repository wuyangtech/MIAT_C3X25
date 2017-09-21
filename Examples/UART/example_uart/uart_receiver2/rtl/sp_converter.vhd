-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity sp_converter is
generic(
    readdata_width         : integer := 8
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
end entity;

architecture rtl of sp_converter is
    
    type STATE_TYPE is (X0, X1, X2, X3, X4, X5);
    signal m_state : STATE_TYPE;
    
    signal r_cnt_bit   : std_logic_vector(3 downto 0);
    signal r_cnt_osp   : std_logic_vector(3 downto 0);
    signal r_payload   : std_logic_vector(((readdata_width-1)+2) downto 0);
    signal r_readdata  : std_logic_vector((readdata_width-1) downto 0);
    signal r_enbuadrate: std_logic;
    signal r_done      : std_logic;
    
    signal w_shiftline : std_logic_vector(((readdata_width-1)+2) downto 0);

begin
    
    control_path: process(spc_i_clock, spc_i_reset_n)
    begin
        if spc_i_reset_n = '0' then
            m_state <= X0;
        
        elsif rising_edge(spc_i_clock) then
            case m_state is
                when X0 =>
                    if spc_i_enable = '1' then
                        m_state <= X1;
                    else
                        m_state <= X0;
                    end if;
                
                when X1 =>
                    if r_cnt_bit = "0000" then
                        if spc_i_rx = '0' then
                            m_state <= X2;
                        else
                            m_state <= X1;
                        end if;
                    else
                        m_state <= X2;
                    end if;
                
                when X2 =>
                    if r_cnt_osp = "1010" then
                        m_state <= X3;
                    else
                        m_state <= X2;
                    end if;
                
                when X3 =>
                    m_state <= X4;
                
                when X4 =>
                    if r_cnt_osp = "1111" then
                        if r_cnt_bit = "1010" then
                            m_state <= X5;
                        else
                            m_state <= X1;
                        end if;
                    else
                        m_state <= X4;
                    end if;
                
                when X5 =>
                    m_state <= X0;
                
                when others =>
                    m_state <= X0;
                
            end case;
        end if;
    
    end process control_path;
    
    w_shiftline <= spc_i_rx & r_payload(9 downto 1);
    
    data_path: process(spc_i_clock, spc_i_reset_n)
    begin
        if spc_i_reset_n = '0' then
            r_cnt_bit <= (others => '0');
            r_cnt_osp <= (others => '0');
            r_payload <= (others => '1');
            r_readdata <= (others => '0');
            r_enbuadrate <= '0';
            r_done <= '0';
        elsif rising_edge(spc_i_clock) then
            case m_state is
                when X0 =>
                    r_cnt_bit <= (others => '0');
                    r_cnt_osp <= (others => '0');
                    r_payload <= (others => '1');
                    r_enbuadrate <= '0';
                    r_done <= '0';
                
                when X1 =>
                    r_enbuadrate <= '0';
                    r_cnt_osp <= (others => '0');
                
                when X2 =>
                    r_enbuadrate <= '1';
                    if spc_i_refbuadrate = '1' then
                        r_cnt_osp <= r_cnt_osp + '1';
                    else
                        r_cnt_osp <= r_cnt_osp;
                    end if;
                
                when X3 =>
                    r_cnt_bit <= r_cnt_bit + '1';
                    r_payload <= w_shiftline;
                
                when X4 =>
                    if spc_i_refbuadrate = '1' then
                        r_cnt_osp <= r_cnt_osp + '1';
                    else
                        r_cnt_osp <= r_cnt_osp;
                    end if;
                
                when X5 =>
                    if r_payload((readdata_width-1)+2) = '1' then
                        r_done <= '1';
                        r_readdata <= r_payload(8 downto 1);
                    else
                        r_done <= '0';
                    end if;
                
                when others =>                    
                
            end case;
        end if;
    end process data_path;
    
    spc_o_readdate <= r_readdata;
    spc_o_enbuadrate <= r_enbuadrate;
    spc_o_done <= r_done;
    
end rtl;