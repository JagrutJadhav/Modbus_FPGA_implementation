--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:22:53 12/10/2020
-- Design Name:   
-- Module Name:   C:/Users/Admin/Desktop/SQM Technoloies/Project_work/PLC/Modbus/modbustop/modbus_tb.vhd
-- Project Name:  modbustop
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Top_level_modbus_master
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY modbus_tb IS
END modbus_tb;
 
ARCHITECTURE behavior OF modbus_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Top_level_modbus_master
	 
    PORT(
         clk : IN  std_logic;
         reset_n : IN  std_logic;
         rx : IN  std_logic;
         tx : OUT  std_logic
        );
    END COMPONENT;
    
	 component uart
	GENERIC(
		clk_freq		:	INTEGER;	   -- frequency of system clock in Hertz
		baud_rate	:	INTEGER;		-- data link baud rate in bits/second
		os_rate		:	INTEGER;		-- oversampling rate to find center of receive bits (in samples per baud period)
		d_width		:	INTEGER;    -- data bus width
		stop_bit		:  INTEGER;	   -- 1 for 2 stop bit, 0 for 1 stop bit
		parity		:	INTEGER;		-- 0 for no parity, 1 for parity
		parity_eo	:	STD_LOGIC); -- '0' for even, '1' for odd parity
	port(
		clk : in std_logic;
		reset_n : in std_logic;
		tx_ena : in std_logic;
		tx_data : in std_logic_vector(7 downto 0);
		rx : in std_logic;          
		rx_busy : out std_logic;
		rx_error : out std_logic;
		rx_data : out std_logic_vector(7 downto 0);
		tx_busy : out std_logic;
		tx : out std_logic
		);
	END COMPONENT;	
   signal tx_ena   : std_logic;                      -- transmit enable
	signal tx_data  : std_logic_vector(7 downto 0);   -- transmit data
	signal rx_busy  : std_logic;                      -- receive busy
	signal rx_error : std_logic;                      -- error signal
	signal rx_data  : std_logic_vector(7 downto 0);   -- receive data
	signal tx_busy  : std_logic;                      -- transmit busy
	

	signal	clk_freq		:	INTEGER		:= 24_000_000;	-- frequency of system clock in Hertz
	signal	baud_rate	:	INTEGER		:= 9600;		   -- data link baud rate in bits/second
	signal	os_rate		:	INTEGER		:= 16;			-- oversampling rate to find center of receive bits (in samples per baud period)
	--signal d_width		:	INTEGER		:= 8; 			-- data bus width
	signal	stop_bit		:  INTEGER     := 1;					-- 1 for 2 stop bit, 0 for 1 stop bit
	signal	parity		:	INTEGER		:= 0;				-- 0 for no parity, 1 for parity
	signal	parity_eo	:	STD_LOGIC	:= '0';		-- '0' for even, '1' for odd parity

signal tx_data_tx : std_logic;

   --Inputs
   signal clk : std_logic := '0';
   signal reset_n : std_logic := '1';
   signal rx : std_logic := '0';

 	--Outputs
   signal tx : std_logic;
	
		signal tx_count1 : integer := 0;
	
	signal state : std_logic_vector(1 downto 0) := "00";
	signal rst_test : std_logic := '0';
	signal test_count : integer := 0;
	
		   signal d_width : integer := 8;
		 signal slave_address 	:std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Slave address
		signal function_code	:   std_logic_vector(d_width-1 downto 0) := x"06"; 	-- Function code
		
		signal add_hi       :  std_logic_vector(d_width-1 downto 0) := x"00"; 	-- Starting address hi 
		signal add_lo       :  std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Starting address lo
		
		signal tx_data_hi			:	std_logic_vector(d_width-1 downto 0) := x"00";  -- data to transmit
		signal tx_data_lo			:  std_logic_vector(d_width-1 downto 0) := x"FF";  -- data to transmit
		
		 signal crc_lo       : std_logic_vector(d_width-1 downto 0) :=x"98";	-- CRC lo
		signal crc_hi      : std_logic_vector(d_width-1 downto 0) := x"4A";	-- CRC hi
		
		signal tx_modbus_ena : std_logic := '0';
		signal tx_modbus_end : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Top_level_modbus_master PORT MAP (
          clk => clk,
          reset_n => reset_n,
          rx => rx,
          tx => tx
        );
		  
  Inst_Uart: Uart 
	generic map
	(
		clk_freq	   => clk_freq, 
		baud_rate	=> baud_rate,
		os_rate		=> os_rate,
		d_width		=> d_width,
		stop_bit		=> stop_bit,
		parity		=> parity,
		parity_eo   => parity_eo
	)
	
	port map
	(
		clk      => clk,
		reset_n  => reset_n,
		tx_ena   => tx_ena,
		tx_data  => tx_data,
		rx       => rx,
		rx_busy  => rx_busy,
		rx_error => rx_error,
		rx_data  => rx_data,
		tx_busy  => tx_busy,
		tx       => tx
	);

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;
 process(clk, 
	          reset_n
				 )
	    begin
		   if(reset_n = '0') then              
				tx_modbus_end <= '1';
			  rst_test <= '1';
			  state <= "00";
			  tx_modbus_ena <= '0';
			  tx_count1 <= 0;
         elsif(clk'event and clk = '1') then
			    tx_modbus_ena <= '1';
			    rst_test <= '0';
        
case (state) is
					
						  when "00" =>                     		
								if(tx_modbus_ena = '1') then
								  state <= "01";
								  tx_modbus_end <= '0';
								else
								  state <= "00";
								  tx_modbus_end <= '1';
								end if;
						
						
		                when "01" =>                        						
		
								  if(tx_busy = '0' and tx_count1 = 0) then
								    tx_ena <= '1';
									 tx_data  <= x"3A";         -- start bit
									 tx_count1 <= 1;
								  elsif(tx_busy = '1' and tx_count1 = 1) then
									 tx_ena <= '1';
									 tx_data  <= slave_address;
									 tx_count1 <= 2;
								  elsif(tx_busy = '1' and tx_count1 = 2) then
									 tx_ena <= '1';
									 tx_data  <= function_code;
									 tx_count1 <= 3;
								  elsif(tx_busy = '1' and tx_count1 = 3) then
									 tx_ena <= '1';
									 tx_data  <= add_hi;
									 tx_count1 <= 4;
								  elsif(tx_busy = '1' and tx_count1 = 4) then	
									 tx_ena <= '1';
									 tx_data  <= add_lo;
									 tx_count1 <= 5;
								  elsif(tx_busy = '1' and tx_count1 = 5) then	
									 tx_ena <= '1';
									 tx_data  <= tx_data_hi;
									 tx_count1 <= 6;
								  elsif(tx_busy = '1' and tx_count1 = 6) then	
									 tx_ena <= '1';
									 tx_data  <= tx_data_lo;
									 tx_count1 <= 7;
									elsif(tx_busy = '1' and tx_count1 = 7) then	
									 tx_ena <= '1';
									 tx_data  <= crc_hi;
									 tx_count1 <= 8;
									 elsif(tx_busy = '1' and tx_count1 = 8) then	
								    tx_ena <= '1';
									 tx_data  <= crc_lo;
									 tx_count1 <= 9;
									 elsif(tx_busy = '1' and tx_count1 = 9) then	
								    tx_ena <= '1';
									tx_data  <= x"0D"; -- stop bit 1
									 tx_count1 <= 10;
									 elsif(tx_busy = '1' and tx_count1 = 10) then	
								   tx_ena <= '1';
									tx_data  <= x"0A"; -- stop bit 2
									 tx_count1 <= 11;
									 elsif(tx_busy = '1' and tx_count1 = 11) then	
								   tx_modbus_end <= '1';
									state <= "00";
									tx_ena <= '0';
									tx_modbus_end <= '1';
									 tx_count1 <= 0;
								  else
									tx_ena <= '0';
								  end if;
						   
							
			              when others  => 
								 tx_modbus_end <= '1';
								state <= "00";
								tx_ena <= '0';
								tx_count1 <= 0;
                    end case;
         end if;
rx <= tx;
     end process;

END;
