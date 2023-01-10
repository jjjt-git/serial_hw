library ieee;

entity serial is
generic (
	withParityBit: bit := '0'
);
port (
	-- APPLICATION SIDE
	clk: in bit;
	dataTx: in bit_vector(7 downto 0);
	dataRx: out bit_vector(7 downto 0);
	hasError: out bit; -- only used with parity enabled
	send: in bit;
	read: in bit;
	rdyRx: out bit;
	rdyTx: out bit;
	rst: in bit;
	-- EXTERNAL SIDE
	tx: out bit;
	rx: in bit;
	rts: in bit;
	cts: out bit
);
end;

architecture def of serial is
	signal dOut, dIn: bit_vector(7 downto 0);
	
	signal txCnt: bit_vector(9 downto 0);
	signal txStart, txParity, txParityBit, txSpecial, txSpecialBit, txParityBitNext: bit;
	signal sending: bit;
	signal txShift: bit_vector(7 downto 0);
	signal outData: bit;
	
	signal receiving: bit;
	signal rxRead, useData, rxM, rxParity: bit;
	signal rxShift: bit_vector(8 downto 0);
	signal rxCnt: bit_vector(9 downto 0);
begin
	-- sending
	rdyTx <= not sending;
	txSpecial <= txStart or txParity;
	with sending select tx <=
		'1' when '0',
		outData when others;
	with txSpecial select outData <=
		not txShift(0) when '0',
		txSpecialBit when others;
	with txStart select txSpecialBit <=
		'0' when '1',
		txParityBit when others;
	txParityBitNext <= (txParityBit xor txShift(0)) or not withParityBit;
	SEND_DATA : process(clk, rst, sending, txShift, txCnt, txStart)
	begin
	if clk'event and clk = '1' then
		if rst = '1' then
			sending <= '0';
			txStart <= '0';
		else
			txCnt(9 downto 1) <= txCnt(8 downto 0);
			if sending = '0' then
				if send = '1' then
					dIn <= dataTx;
					sending <= '1';
					txStart <= '1';
					txParityBit <= '0';
					txCnt(0) <= '1';
				end if;
			else
				txCnt(0) <= '0';
				if txStart = '1' then
					txStart <= '0';
					txShift <= dIn;
				elsif txCnt(8) = '1' and withParityBit = '0' then
					sending <= '0';
				elsif txCnt(9) = '1' and withParityBit = '1' then
					sending <= '0';
				else
					txShift(6 downto 0) <= txShift(7 downto 1);
					txParityBit <= txParityBitNext;
				end if;
			end if;
		end if;
	end if;
	end process;
	
	-- receiving
	cts <= useData;
	useData <= rts and (rxRead or receiving);
	rxM <= not (useData and rx);
	
	rxShift(8) <= rxM;
	
	READ_DATA : process(clk, rst, receiving, read, rxShift, rxM, rxCnt)
	begin
	if clk'event and clk = '1' then
		if rst = '1' then
			receiving <= '0';
			rdyRx <= '0';
			rxRead <= '1';
			rxCnt(9 downto 0) <= "0000000000";
		else
			rxShift(7 downto 0) <= rxShift(8 downto 1);
			rxCnt(9 downto 1) <= rxCnt(8 downto 0);
			
			if receiving = '0' then
				if rxM = '0' then
					receiving <= '1';
					rxCnt(0) <= '1';
					rdyRx <= '0';
					rxParity <= '0';
				elsif read = '1' then
					dataRx <= dOut;
					rxRead <= '1';
					hasError <= rxParity and withParityBit;
				end if;
			else
				rxCnt(0) <= '0';
				rxParity <= rxParity xor rxM;
				
				if receiving = '1' and rxCnt(9) = '1' then
					receiving <= '0';
					dOut <= rxShift(7 downto 0);
					rdyRx <= '1';
					rxRead <= '0';
				end if;
			end if;
		end if;
	end if;
	end process;
end;