library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pwm_4 is 
port(
	clk,rst:in std_logic;
	cnt_out: out std_logic_vector(3 downto 0);
	pwm_out: out std_logic
	);
end pwm_4;

ARCHITECTURE a OF pwm_4 IS

component pwm  
generic(CNT_WIDTH:integer);
port(
	clk,rst:in std_logic;
	offt_i: in std_logic_vector(CNT_WIDTH downto 0);
	period_i: in std_logic_vector(CNT_WIDTH downto 0);
	cnt_out: out std_logic_vector(CNT_WIDTH downto 0);
	pwm_out: out std_logic
	);
end component;

begin

  U0:pwm generic map(3) port map(clk,rst,"0011","1000",cnt_out,pwm_out);
  --3 ="0011"
  --8 ="10000"
end a;