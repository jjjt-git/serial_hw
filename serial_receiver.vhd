library ieee;

-- will receive 8-bit words with parity (can be ignored)
-- effectivly, we read 9 bits from serial before falling back to idle, but only output 8 of these directly
-- any parity related logic must be implemented higher up the chain

entity serial_receiver is
port (
	rx: in bit;

	clk16: in bit;
	reset: in bit;

	idle: out bit;

	data: out bit_vector(7 downto 0);
	parity: out bit;

	DEBUG_INTERNAL_SHIFTREG: out bit_vector(8 downto 0)
);
end;

architecture def of serial_receiver is
	signal edge_det_bits: bit_vector(1 downto 0);
	signal edge_det: bit;
	signal clk: bit;
	signal active: bit;
	signal activate: bit;
	signal inactivate: bit;
	signal activate_counter: bit_vector(6 downto 0);
	signal clk_counter, clk_counter_next: bit_vector(3 downto 0);
	signal clk_counter_carry: bit_vector(4 downto 0);

	signal data_counter: bit_vector(7 downto 0);
	signal data_shift: bit_vector(7 downto 0);
	signal data_cur_parity: bit;
	signal start, reset_start: bit;
begin
	DEBUG_INTERNAL_SHIFTREG <= data_shift & data_cur_parity;
	idle <= not active;
	-- edge detector
	edge_det_bits(0) <= rx;
	edge_det <= edge_det_bits(1) and not edge_det_bits(0);
	EDGE_DETECTOR_SHIFT: process(clk16)
	begin
	if clk16'event and clk16 = '1' then
		edge_det_bits(1) <= edge_det_bits(0);
	end if;
	end process;
	-- clk gen
	clk <= clk_counter_carry(4);
	clk_counter_carry(0) <= active;
	clk_counter_carry(4 downto 1) <= clk_counter and clk_counter_carry(3 downto 0);
	clk_counter_next <= clk_counter xor clk_counter_carry(3 downto 0);
	-- main
	RECEIVER: process(clk16)
	begin
	if clk16'event and clk16 = '1' then
		if reset = '1' then
			active <= '0';
			activate <= '0';
			clk_counter <= "0000";
			activate_counter <= "0000000";
		else
			activate_counter(6 downto 1) <= activate_counter(5 downto 0);
			clk_counter <= clk_counter_next;
			if activate = '1' then
				activate_counter(0) <= '0';
				if activate_counter(6) = '1' then
					activate <= '0';
					active <= '1';
					start <= '1';
				end if;
			elsif active = '1' then
				activate_counter(0) <= '0';
				-- actual receiving
				if clk = '1' then
					data_counter(7 downto 1) <= data_counter(6 downto 0);
					data_shift(6 downto 0) <= data_shift(7 downto 1);
					data_shift(7) <= rx;
					if start = '1' then
						start <= '0';
						data_counter(0) <= '1';
						data_cur_parity <= rx;
					else
						data_counter(0) <= '0';
						data_cur_parity <= rx xor data_cur_parity;
					end if;
					if data_counter(7) = '1' then -- finalize
						parity <= rx xor data_cur_parity;
						data <= data_shift;
						active <= '0';
					end if;
				end if;
			elsif edge_det = '1' then
				activate <= '1';
				activate_counter(0) <= '1';
			else -- idle
				activate_counter(0) <= '0';
			end if;
		end if;
	end if;
	end process;
end;
