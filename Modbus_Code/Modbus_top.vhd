----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jagrut Jadhav
-- 
-- Create Date:
-- Design Name: 
-- Module Name:    Top_level_modbus_master - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Top_level_modbus_master is
  GENERIC(
		clk_freq		:	INTEGER  	:= 24_000_000;	-- frequency of system clock in Hertz
		baud_rate		:	INTEGER		:= 9600;		   -- data link baud rate in bits/second
		os_rate			:	INTEGER		:= 16;			-- oversampling rate to find center of receive bits (in samples per baud period)
		--d_width		:	INTEGER		:= 8; 			-- data bus width
		stop_bit		:  INTEGER   := 1;					-- 1 for 2 stop bit, 0 for 1 stop bit
		parity			:	INTEGER		:= 0;				-- 0 for no parity, 1 for parity
		parity_eo		:	STD_LOGIC	:= '0');			-- '0' for even, '1' for odd parity
  port(		
    clk					:	in		std_logic;										-- system clock
		reset_n			:	in		std_logic;										-- reset
		
--		slave_address 	: 	in 	std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Slave address
--		function_code		:  in    std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Function code
--		
--		add_hi       		:  in    std_logic_vector(d_width-1 downto 0) := x"00"; 	-- Starting address hi 
--		add_lo       		:  in    std_logic_vector(d_width-1 downto 0) := x"FF"; 	-- Starting address lo
--		
--		tx_data_hi			:	in		std_logic_vector(d_width-1 downto 0);  -- data to transmit
--		tx_data_lo			:	in		std_logic_vector(d_width-1 downto 0);  -- data to transmit
--		
--		crc_low        :  out   std_logic_vector(d_width-1 downto 0);	-- CRC lo
--		crc_high       :  out   std_logic_vector(d_width-1 downto 0);	-- CRC hi
		
		--crc_en 					: 	in 	std_logic;										-- CRC enable
		--tx_ena					:	in		std_logic;										-- initiate transmission
	--		tx_modbus_ena	: in std_logic;
--		tx_modbus_end 	: out std_logic;
--		
		
--		rx_data			:	out	std_logic_vector(d_width-1 downto 0);	-- data received
		
		rx					:	in		std_logic;										-- receive pin
		tx					:	out	std_logic										--	transmit pin
		
		--tx_busy			:	out	std_logic;  									-- transmission in progress
		--rx_busy			:	out	std_logic;										-- data reception in progress
		--rx_error			:	out	std_logic										-- start, parity, or stop bit error detected
      );		  

end Top_level_modbus_master;

architecture Behavioral of Top_level_modbus_master is
	
	component uart
	GENERIC(
		clk_freq		:	INTEGER;	   -- frequency of system clock in Hertz
		baud_rate		:	INTEGER;		-- data link baud rate in bits/second
		os_rate			:	INTEGER;		-- oversampling rate to find center of receive bits (in samples per baud period)
		d_width			:	INTEGER;    -- data bus width
		stop_bit		:  INTEGER;	   -- 1 for 2 stop bit, 0 for 1 stop bit
		parity			:	INTEGER;		-- 0 for no parity, 1 for parity
		parity_eo		:	STD_LOGIC); -- '0' for even, '1' for odd parity
	port(
		clk				 : in std_logic;
		reset_n 	: in std_logic;
		tx_ena 		: in std_logic;
		tx_data 	: in std_logic_vector(7 downto 0);
		rx 				: in std_logic;          
		rx_busy 	: out std_logic;
		rx_error 	: out std_logic;
		rx_data 	: out std_logic_vector(7 downto 0);
		tx_busy 	: out std_logic;
		tx 				: out std_logic
		);
	end component;
	
	constant max571hz	: integer := 24000000/142; --time =5.98 ms for 9600 baud
	signal r_reg2 		: integer range 0 to max571hz;
	
	constant max400hz	: integer := 24000000/2000; --time =5.98 ms for 9600 baud
	signal r_reg1 		: integer range 0 to max400hz;
	
	signal tx_ena   	: std_logic;                      -- transmit enable
	signal tx_data  	: std_logic_vector(7 downto 0);   -- transmit data
	signal rx_busy  	: std_logic;                      -- receive busy
	signal rx_error 	: std_logic;                      -- error signal
	--signal rx_data  : std_logic_vector(7 downto 0);   -- receive data
	signal tx_busy  	: std_logic;                      -- transmit busy
	
	signal tx_count1 	: integer := 0;
	
	signal state 			: std_logic_vector(1 downto 0) := "00";
	signal rst_test	 	: std_logic := '0';
	signal test_count : integer := 0;
	
	signal data_value1 	: std_logic_vector (7 downto 0);
	signal data_value2 	: std_logic_vector (7 downto 0);
	signal data_value3 	: std_logic_vector (7 downto 0);
	signal data_value4 	: std_logic_vector (7 downto 0);
	signal data_value5 	: std_logic_vector (7 downto 0);
	signal data_value6 	: std_logic_vector (7 downto 0);
	signal data_value7 	: std_logic_vector (7 downto 0);
	signal data_value8 	: std_logic_vector (7 downto 0);
	signal data_value9 	: std_logic_vector (7 downto 0);
	signal data_value10 : std_logic_vector (7 downto 0);
	signal data_value11 : std_logic_vector (7 downto 0);
	
	--------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	   signal d_width : integer := 8;
		 signal slave_address 	:std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Slave address
		signal function_code	:   std_logic_vector(d_width-1 downto 0) := x"06"; 	-- Function code
		
		signal add_hi       :  std_logic_vector(d_width-1 downto 0) := x"00"; 	-- Starting address hi 
		signal add_lo       :  std_logic_vector(d_width-1 downto 0) := x"01"; 	-- Starting address lo
		
		signal tx_data_hi			:	std_logic_vector(d_width-1 downto 0) := x"00";  -- data to transmit
		signal tx_data_lo			:  std_logic_vector(d_width-1 downto 0) := x"FF";  -- data to transmit
		
		 signal crc_lo       : std_logic_vector(d_width-1 downto 0) :=x"98";	-- CRC lo
		signal crc_hi      : std_logic_vector(d_width-1 downto 0) := x"4A";	-- CRC hi
		
		signal tx_modbus_ena : std_logic;
		signal tx_modbus_end : std_logic;
		
		signal rx_data  : std_logic_vector(7 downto 0);   -- receive data
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------

	
begin
	
	--re_n <= '0';                                             -- enabling receive enable pin from Rs232 to Rs485 driver  
	--de   <= '1';                                             -- enabling transmit enable pin from Rs232 to Rs485 driver
	
	--tx_ena <= '1' when rx_busy1 = '1' else                   -- Make transmit enable high when receive busy goes high
			   -- '0';
			 
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
	
process (rx_busy,reset_n)
begin
     if(reset_n = '0') then
		 test_count <= 0;
	end if;
	  if(rising_edge(rx_busy)) then
		 test_count <= test_count + 1;
		  if (test_count = 10) then
		     test_count <= 0;
		  end if;
	 end if;		
end process;

process(clk, reset_n)	
    begin	
      if(reset_n = '0') then
		   --test_count <= 0;
		  data_value1  <= x"00";   -- reset data_value1 register to 00
		  data_value2  <= x"00";   -- reset data_value2 register to 00
		  data_value3  <= x"00";   -- reset data_value3 register to 00
		  data_value4  <= x"00";   -- reset data_value4 register to 00
		  data_value5  <= x"00";   -- reset data_value5 register to 00
		  data_value6  <= x"00";   -- reset data_value6 register to 00
		  data_value7  <= x"00";   -- reset data_value7 register to 00
		  data_value8  <= x"00";   -- reset data_value8 register to 00
		  data_value9  <= x"00";   -- reset data_value9 register to 00
		  data_value10 <= x"00";   -- reset data_value9 register to 00
		  data_value11 <= x"00";   -- reset data_value9 register to 00
		elsif(clk'event and clk = '1') then
       
		  case(test_count) is		
	       when 1 =>
            data_value1 <= rx_data;   -- start					
          when 2 =>
            data_value2 <= rx_data;   -- slave_address			
          when 3 =>
            data_value3 <= rx_data;   -- funtion address
          when 4 => 
            data_value4 <= rx_data;   -- add_hi
          when 5 => 
            data_value5 <= rx_data;   -- add_lo
          when 6 => 
            data_value6 <= rx_data;  -- data_hi
          when 7 => 
            data_value7 <= rx_data;  -- data_lo
          when 8 => 
            data_value8 <= rx_data;  -- crc_hi
			 when 9 =>
			   data_value9 <= rx_data;  -- crc_lo
			 when 10 =>
			   data_value10 <= rx_data; --stop1
			 when 11 => 
			   data_value11 <= rx_data; -- stop 2
          when others => null;
        end case;
      end if;
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

     end process;


end Behavioral;

