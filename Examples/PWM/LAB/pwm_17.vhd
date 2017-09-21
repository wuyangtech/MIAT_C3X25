library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity pwm_17 is 
port(
	clk,rst:in std_logic;
--	offt_i: in std_logic_vector(16 downto 0);
--	period_i: in std_logic_vector(16 downto 0);
	cnt_out: out std_logic_vector(16 downto 0);
	pwm_out: out std_logic
	);
end pwm_17;

ARCHITECTURE a OF pwm_17 IS

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

  U0:pwm generic map(16) port map(clk,rst,"01100001101010000","11000011010100000",cnt_out,pwm_out);
  --50,000 ="01100001101010000"
  --100,000="11000011010100000"
end a;