-- tkyao 2010 @ tunkai.yao@gmail.com

library ieee;
use ieee.std_logic_1164.all;

entity miatc3x is
port 
(
    c3x_clock       : in  std_logic;
    
-- DIP SWITCH
    c3x_dipsw0      : in    std_logic;
    -- c3x_dipsw1      : in    std_logic;
    -- c3x_dipsw2      : in    std_logic;
    -- c3x_dipsw3      : in    std_logic;
    
-- GPIO
    c3x_gpio0       : inout std_logic;
    
-- Dummy Pad
    c3x_dummypad    : out   std_logic
);

end entity;

architecture rtl of miatc3x is
begin
    
    
    
end rtl;
