library ieee;

entity tb_serial is
end;

architecture def of tb_serial is
	signal clk, rst: bit;
	signal read0, send0, rdyI0, rdyO0, tx0, rx0, rts0, cts0, hasError0: bit;
	signal read1, send1, rdyI1, rdyO1, tx1, rx1, rts1, cts1, hasError1: bit;
	signal dataI: bit_vector(7 downto 0);
	signal dataO0, dataO1: bit_vector(7 downto 0);
	
	signal STOP: bit;
begin
	WO_PARITY : entity work.serial
	generic map (
		withParityBit => '0'
	)
	port map (
		clk => clk,
		rst => rst,
		dataTx => dataI,
		dataRx => dataO0,
		hasError => hasError0,
		tx => tx0,
		rx => rx0,
		rts => rts0,
		cts => cts0,
		rdyTx => rdyI0,
		rdyRx => rdyO0,
		send => send0,
		read => read0
	);
	
	W_PARITY : entity work.serial
	generic map (
		withParityBit => '1'
	)
	port map (
		clk => clk,
		rst => rst,
		dataRx => dataO1,
		dataTx => dataI,
		hasError => hasError1,
		tx => tx1,
		rx => rx1,
		rts => rts1,
		cts => cts1,
		rdyTx => rdyI1,
		rdyRx => rdyO1,
		send => send1,
		read => read1
	);
	
	TB : process
	begin
		rx0 <= '1';
		rx1 <= '1';
		rts0 <= '0';
		rts1 <= '0';
		rst <= '1';
		send0 <= '0';
		send1 <= '0';
		read0 <= '0';
		read1 <= '0';
		STOP <= '0';
		
		wait for 15 ns;
		rst <= '0';
		wait for 10 ns;
		assert tx0 = '1' report "Should be idle!";
		assert tx1 = '1' report "Should be idle!";
		assert rdyI0 = '1' report "Should accept input!";
		assert rdyI1 = '1' report "Should accept input!";
		assert rdyO0 = '0' report "Should not have output!";
		assert rdyO1 = '0' report "Should not have output!";
		assert cts0 = '0' report "Should not allow input!";
		assert cts1 = '0' report "Should not allow input!";
		wait for 20 ns;
		dataI <= "10101010";
		rts0 <= '1';
		rts1 <= '1';
		wait for 20 ns;
		send0 <= '1';
		send1 <= '1';
		assert cts0 = '1' report "Should allow input!";
		assert cts1 = '1' report "Should allow input!";
		wait for 20 ns;
		send0 <= '0';
		send1 <= '0';
		assert tx0 = '0' report "Should start transmission!";
		assert tx1 = '0' report "Should start transmission!";
		assert rdyI0 = '0' report "Should not accept input!";
		assert rdyI1 = '0' report "Should not accept input!";
		wait for 20 ns;
		assert tx0 = '1' report "Should transmit data!";
		assert tx1 = '1' report "Should transmit data!";
		rx0 <= '0';
		rx1 <= '0';
		wait for 20 ns;
		assert tx0 = '0' report "Should transmit data!";
		assert tx1 = '0' report "Should transmit data!";
		rx0 <= '1';
		rx1 <= '1';
		wait for 20 ns;
		assert tx0 = '1' report "Should transmit data!";
		assert tx1 = '1' report "Should transmit data!";
		rx0 <= '0';
		rx1 <= '0';
		wait for 20 ns;
		assert tx0 = '0' report "Should transmit data!";
		assert tx1 = '0' report "Should transmit data!";
		rx0 <= '1';
		rx1 <= '1';
		wait for 20 ns;
		assert tx0 = '1' report "Should transmit data!";
		assert tx1 = '1' report "Should transmit data!";
		rx0 <= '0';
		rx1 <= '0';
		wait for 20 ns;
		assert tx0 = '0' report "Should transmit data!";
		assert tx1 = '0' report "Should transmit data!";
		rx0 <= '1';
		rx1 <= '1';
		wait for 20 ns;
		assert tx0 = '1' report "Should transmit data!";
		assert tx1 = '1' report "Should transmit data!";
		rx0 <= '0';
		rx1 <= '0';
		wait for 20 ns;
		assert tx0 = '0' report "Should transmit data!";
		assert tx1 = '0' report "Should transmit data!";
		rx0 <= '1';
		rx1 <= '1';
		wait for 20 ns;
		assert tx0 = '1' report "Should send stop!";
		assert tx1 = '0' report "Should send parity!";
		rx0 <= '1';
		rx1 <= '0';
		assert rdyI0 = '1' report "Should allow input!";
		wait for 20 ns;
		assert rdyI1 = '1' report "Should allow input!";
		assert rdyO0 = '1' report "Should have output!";
		rx1 <= '1';
		read0 <= '1';
		wait for 20 ns;
		assert rdyO1 = '1' report "Should have output!";
		assert dataO0 = "10101010" report "Should contain output!";
		assert hasError0 = '0' report "Should not have error!";
		read0 <= '0';
		read1 <= '1';
		wait for 20 ns;
		assert dataO1 = "10101010" report "Should contain output!";
		assert hasError1 = '0' report "Should not have error!";
		read1 <= '0';
		wait for 20 ns;
		STOP <= '1';
		wait;
	end process;

	CLK_GEN : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
		if STOP = '1' then
			assert false report "End of test!";
			wait;
		end if;
	end process;
end;