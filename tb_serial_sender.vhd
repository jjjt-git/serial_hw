library ieee;

entity tb_serial_sender is
port()
end;

architecture DEF of tb_serial_sender is
	signal tx, clk, reset, parity, idle: bit;
	signal data, test_data: bit_vector(7 downto 0);
	signal test_parity: bit;
	signal start: bit;

	constant dt: time := 10 ns;
begin
	TU: entity work.serial_sender is port map (
		tx => tx,
		clk => clk,
		reset => reset,
		parity => parity,
		idle => idle,
		data => data,
		start => start
	);
	parity <= '1';
	test_data <= "10101010";
	test_parity <= '0';

	TB: process
	begin
		reset <= '1';
		start <= '0';
		wait for dt;
		wait for dt/2;
		reset <= '0';
		data <= test_data;
		wait for dt;
		assert tx = '1' report "Should be idle!";
		assert idle = '1' report "Should be idle!";
		start <= '1';
		wait for dt;
		start <= '0';
		data <= "11111111";
		assert tx = '0' report "Should start transmission!";
		assert idle = '0' report "Should not be idle!";
		wait for dt;
		for i in 0 to 7 loop
			assert tx = data(i) report "Wrong bit send!";
			assert idle = '0' report "Should not be idle!";
			wait for dt;
		end loop;
		if parity = '1' then
			assert idle = '0' report "Should not be idle!";
			assert tx = test_parity report "Should send parity!";
		else
			assert tx = '1' report "Should send stopbit!";
		end if;
		wait for dt;
		assert tx = '1' report "Should send stopbi!";
	end process;

	CLK_GEN: process
	begin
		clk <= '0';
		wait for dt/2;
		clk <= '1';
		wait for dt/2;
	end process;
end;
