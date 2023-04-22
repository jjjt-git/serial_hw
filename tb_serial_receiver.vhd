library ieee;

entity tb_serial_receiver is
end;

architecture def of tb_serial_receiver is
	constant period: time := 100 ns;
	constant dt: time := period / 32;

	signal clk, rst, rx, stop: bit;
	signal char, send: bit_vector(7 downto 0);

	procedure write_byte_no_parity (
		byte: in bit_vector(7 downto 0);
		signal d: out bit
	) is
	begin
		d <= '0';
		wait for period;

		for ii in 0 to 7 loop
			d <= byte(ii);
			wait for period;
		end loop;
	end;
begin
	RECEIVER: entity work.serial_receiver port map (
		rx => rx,
		clk16 => clk,
		reset => rst,
		data => char
	);

	TB: process
	begin
		send <= "11011100";

		rst <= '1';
		stop <= '0';
		rx <= '1';
		wait for dt;
		wait for dt * 2;
		rst <= '0';
		wait for dt * 2;

		write_byte_no_parity (send, rx);

		wait for 2 * period;
		assert char = send report "Incorrect data!";
		wait for dt;
		stop <= '1';
		wait;
	end process;

	CLK_GEN: process
	begin
		clk <= '0';
		wait for dt;
		clk <= '1';
		wait for dt;
		if stop = '1' then
			assert false report "End of test!";
			wait;
		end if;
	end process;
end;
