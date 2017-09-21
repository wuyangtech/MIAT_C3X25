
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
entity MIATC3XTOP is
port(
	-- Push Button 1~4
	iTOP_BUTTON			: in  std_logic_vector(3 downto 0);	-- Push Button  

	-- LED 1~4
	oTOP_LED			: out std_logic_vector(3 downto 0)		-- LED 4 Bits

);
end MIATC3XTOP;
architecture RTL of MIATC3XTOP is
begin

     oTOP_LED <= iTOP_BUTTON;
--   oTOP_LED(3) <= iTOP_BUTTON(3);
--   oTOP_LED(2 downto 0) <= iTOP_BUTTON(2 downto 0);

end RTL;
