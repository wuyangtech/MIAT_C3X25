-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.std_logic_unsigned.all;

entity ps_converter is
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
end entity;

architecture beh of ps_converter is
    
    type STATE_TYPE is (X0, X1, X2, X3);
    -- attribute ENUM_ENCODING: string;
    -- attribute ENUM_ENCODING of STATE_TYPE : type is "000 001 010 011";
    signal m_state : STATE_TYPE;
    
    
    signal r_payload    : std_logic_vector(((writedata_width-1)+2) downto 0);
    signal r_cnt        : std_logic_vector(3 downto 0);
    signal r_done       : std_logic;
    
    signal w_shiftline  : std_logic_vector(((writedata_width-1)+2) downto 0);

begin
    
    control_path: process(psc_i_clock, psc_i_reset_n)
    begin
        if psc_i_reset_n = '0' then
            m_state <= X0;
        elsif rising_edge(psc_i_clock) then
            case m_state is
                when X0 =>
                    if psc_i_enable = '1' then
                        m_state <= X1;
                    else
                        m_state <= X0;
                    end if;
                
                when X1 =>
                    m_state <= X2;
                
                when X2 =>
                    if r_cnt = "1011" then
                        m_state <= X3;
                    else
                        m_state <= X2;
                    end if;
                
                when X3 =>
                    if psc_i_enable = '0' then
                        m_state <= X0;
                    else
                        m_state <= X3;
                    end if;
                
                when others =>
                    m_state <= X0;
                
            end case;
        end if;
    end process control_path;

    
    w_shiftline <= '1' & r_payload(((writedata_width-1)+2) downto 1);
    
    data_path: process(psc_i_clock, psc_i_reset_n)
    begin
        if psc_i_reset_n = '0' then
            r_cnt <= (others => '0');
            r_payload <= (others => '1');
            r_done <= '0';
        elsif rising_edge(psc_i_clock) then
            case m_state is
                when X0 =>
                    r_cnt <= (others => '0');
                    r_payload <= (others => '1');
                    r_done <= '0';
                
                when X1 =>
                    r_payload <= psc_i_writedata & "01";
                    
                when X2 =>
                    if psc_i_refbuadrate = '1' then
                        r_payload <= w_shiftline;
                        r_cnt <= r_cnt + '1';
                    else
                        
                    end if;
                    -- r_payload <= w_shiftline;
                    -- r_cnt <= r_cnt + '1';
                    
                when X3 =>
                    r_done <= '1';
                    
                when others =>
                    
            end case;
        end if;
    end process data_path;
    
    
    -- output buffer
    psc_o_tx <= r_payload(0);
    psc_o_done <= r_done;
    
end beh;
