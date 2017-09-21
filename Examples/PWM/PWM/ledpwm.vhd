library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ledpwm is 
generic(T:std_logic_vector(19 downto 0):="11110100001001000000" 
);
--1,000,000="11110100001001000000"
--  900,000="11011011101110100000"   
port(
	clk,rst:in std_logic;
	key0   :in std_logic;
	cnt_out: out std_logic_vector(19 downto 0);
--	cnt_out2: out std_logic_vector(19 downto 0);
	pwm_out: out std_logic;
	key0_out: out std_logic
	);
end ledpwm;

ARCHITECTURE a OF ledpwm IS

	signal clk2: std_logic;
	signal X0,X1,X2,X3: std_logic;	
	signal OFFT_I_REG:std_logic_vector(19 downto 0);
	
	signal pwm_out_reg: std_logic;

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

	process(clk2,rst)
	begin 
    	if rst='0' then
        X0<='1';
	    X1<='0';
	    X2<='0';
	    X3<='0';
	elsif clk2'event and clk2='1' then
	
           if X0='1' and not(key0='1')       then X0<='0'; X1<='1';
    	elsif X1='1' and key0='1'            then X1<='0'; X2<='1';
	   elsif X2='1' and not(key0='1')       then X2<='0'; X3<='1';
	   elsif X3='1' and OFFT_I_REG>=T       then X3<='0'; X0<='1';
	   elsif X3='1' and not(OFFT_I_REG>=T)  then X3<='0'; X1<='1';
	   end if;
	
           if X0='1' then OFFT_I_REG<=(others=>'0');
	    elsif X1='1' then OFFT_I_REG<=OFFT_I_REG+10000;
	    end if;
	  
	end if;	
	
	end process;
	
  clk2<=pwm_out_reg;
  pwm_out<=pwm_out_reg;
  key0_out<=key0;

  U0:pwm generic map(19) port map(clk,rst,OFFT_I_REG,T,cnt_out,pwm_out_reg);

end a;