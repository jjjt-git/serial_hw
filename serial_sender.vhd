library ieee;

entity serial_sender is
port (
	tx: out bit;

	clk: in bit;
	reset: in bit;

	parity: in bit;
	idle: out bit;

	data: in bit_vector(7 downto 0);
	start: in bit
);
end;

architecture DEF of serial_sender is
	signal sending_data: bit_vector(7 downto 0);
	signal counter: bit_vector(9 downto 0);
	signal active: bit;
	signal send_bit: bit;
	signal parity_counter, send_parity: bit;
begin
	idle <= not active;
	with active select tx <=
		'1' when '0',
		send_bit when others;

	SEND: process(clk, reset)
	begin
	if clk'event and clk = '1' then
		counter(9 downto 1) <= counter(8 downto 0);

		if reset = '1' then
			active <= '0';
			counter(0) <= '0';
		elsif active = '1' then
			counter(0) <= '0';
			if counter(9) = '1' then
				active <= '0';
			elsif counter(8) = '1' then
				if send_parity = '0' then
					send_bit <= '1';
				else
					send_bit <= parity_counter;
				end if;
			else
				send_bit <=
					((counter(0) and sending_data(0)) or
					(counter(1) and sending_data(1)) or
					(counter(2) and sending_data(2)) or
					(counter(3) and sending_data(3)) or
					(counter(4) and sending_data(4)) or
					(counter(5) and sending_data(5)) or
					(counter(6) and sending_data(6)) or
					(counter(7) and sending_data(7)));
				parity_counter <= parity_counter xor
					((counter(0) and sending_data(0)) or
					(counter(1) and sending_data(1)) or
					(counter(2) and sending_data(2)) or
					(counter(3) and sending_data(3)) or
					(counter(4) and sending_data(4)) or
					(counter(5) and sending_data(5)) or
					(counter(6) and sending_data(6)) or
					(counter(7) and sending_data(7)));
			end if;
		elsif start = '1' then
			active <= '1';
			counter(0) <= '1';
			parity_counter <= '0';
			send_bit <= '0';
			sending_data <= data;
			send_parity <= parity;
		end if;
	end if;
	end process;
end;
