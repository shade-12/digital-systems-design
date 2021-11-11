# Testing statistics for lab-3w1-shade-12

* **task1 : init : 100.0%**
	* Fails if rdy is not high 20 clock cycles after coming out of a 20-clock-cycle reset : PASSED
	* Fails if any mem writes occurred after reset but before en was set high : PASSED
	* Fails if rdy is combinationally dependent on en : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted : PASSED
	* Fails if rdy is not reasserted within 1024 clock cycles : PASSED
	* Fails if mem write count (256) is not exactly 256 : PASSED
	* Fails if mem write count (256) is off by over 50% : PASSED
	* Fails if not all written values were correct (256 matched of 256) : PASSED
	* Fails if rdy is deasserted without en within the next 1024 clock cycles : PASSED
	* Fails if any mem writes occurred after completion : PASSED
	* Fails if rdy is not reasserted within 1024 clock cycles of re-enable : PASSED
	* Fails if mem write count is not identical in the first (256) and second (256) runs : PASSED
	* Fails if mem correctly written value count is not identical in the first (256) and second (256) runs : PASSED
	* Fails if any mem writes occurred after completion of re-run : PASSED
	* Fails if rdy is not high 20 clock cycles after coming out of second reset : PASSED
	* Fails if any mem writes occurred after second reset but before en was set high : PASSED
	* Fails if rdy is not reasserted within 1024 clock cycles of enable after second reset : PASSED
	* Fails if mem write count is not identical in the first (256) and third (256) runs : PASSED
	* Fails if mem correctly written value count is not identical in the first (256) and third (256) runs : PASSED
	* Fails if any mem writes occurred after completion of post-reset re-run : PASSED
* **task1 : task1 : 100.0%**
	* DUT: task1.sv. Expectation: data initialized as expected. Actual:         256/256 matching : PASSED
* **task2 : ksa : 100.0%**
	* Fails if rdy is not high 20 clock cycles after coming out of a 20-clock-cycle reset : PASSED
	* Fails if any S mem writes occurred after reset but before en was set high : PASSED
	* Fails if rdy is combinationally dependent on en : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles : PASSED
	* Fails if mem write count (512) is not exactly 512 : PASSED
	* Fails if mem write count (512) is off by over 50% : PASSED
	* Fails if correct swap operations count (256) is 0 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 2 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 2 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 4 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 4 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 8 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 8 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 16 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 16 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 32 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 32 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 64 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 64 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (256) is less than 128 or over 256 : PASSED
	* Fails if fully correct swap operations count (256) is less than 128 or over 256 : PASSED
	* Fails if correct swap operations (256) is not 256 : PASSED
	* Fails if final S memory contents are incorrect : PASSED
	* Fails if any S mem writes occurred after completion : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles of re-enable : PASSED
	* Fails if rdy is not high 20 clock cycles after coming out of second reset : PASSED
	* Fails if any S mem writes occurred after second reset but before en was set high : PASSED
* **task2 : task2 : 100.0%**
	* DUT: task2.sv. Expectation: key scheduling algorithm result matches expected. Actual:         256/256 matching autograder : PASSED
* **task3 : prga : 81.63265306122449%**
	* Fails if rdy is not high 20 clock cycles after coming out of a 20-clock-cycle reset : PASSED
	* Fails if any S mem writes occurred after reset but before en was set high : PASSED
	* Fails if rdy is combinationally dependent on en : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles : PASSED
	* Fails if S mem write count (478) is not exactly twice the message length (478) : PASSED
	* Fails if S mem write count (478) is off by over 50% : PASSED
	* Fails if correct S swap operations count (239) is 0 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 2 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 2 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 4 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 4 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 8 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 8 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 16 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 16 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 32 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 32 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 64 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 64 or over 256 : PASSED
	* Fails if consistently addressed swap operations count (239) is less than 128 or over 256 : PASSED
	* Fails if fully correct swap operations count (239) is less than 128 or over 256 : PASSED
	* Fails if correct swap operations (239) is not equal to message length (239) : PASSED
	* Fails if final S memory contents are incorrect : FAILED
	* Fails if final PT message length (239) is not as expected (239) : PASSED
	* Fails if final PT message contents have any mismatches (0) : PASSED
	* Fails if final PT message contents have over 1 mismatches (0) : PASSED
	* Fails if final PT message contents have over 4 mismatches (0) : PASSED
	* Fails if final PT message contents have over 16 mismatches (0) : PASSED
	* Fails if final PT message contents have over 64 mismatches (0) : PASSED
	* Fails if any S mem writes occurred after completion : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (re-enable run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (re-enable run) : PASSED
	* Fails if final PT message length (239) is not as expected (23) : FAILED
	* Fails if rdy is not low at the posedge after en is deasserted (reset run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (reset run) : PASSED
	* Fails if final PT message length (23) is not as expected (179) : FAILED
	* Fails if final PT message contents have any mismatches (156) : FAILED
	* Fails if rdy is not reasserted within 4096 clock cycles (length 255 run) : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (length 0 run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (length 0 run) : PASSED
	* Fails if final PT message length (179) is not as expected (0) : FAILED
	* Fails if rdy is not low at the posedge after en is deasserted (length 255 run) : PASSED
* **task3 : arc4 : 92.85714285714286%**
	* Fails if rdy is not high 20 clock cycles after coming out of a 20-clock-cycle reset : PASSED
	* Fails if rdy is combinationally dependent on en : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted : PASSED
	* Fails if rdy is not reasserted within 16384 clock cycles : PASSED
	* Fails if final PT message length (239) is not as expected (239) : PASSED
	* Fails if final PT message contents have any mismatches (0) : PASSED
	* Fails if final PT message contents have over 1 mismatches (0) : PASSED
	* Fails if final PT message contents have over 2 mismatches (0) : PASSED
	* Fails if final PT message contents have over 4 mismatches (0) : PASSED
	* Fails if final PT message contents have over 8 mismatches (0) : PASSED
	* Fails if final PT message contents have over 16 mismatches (0) : PASSED
	* Fails if final PT message contents have over 32 mismatches (0) : PASSED
	* Fails if final PT message contents have over 64 mismatches (0) : PASSED
	* Fails if final PT message contents have over 128 mismatches (0) : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (re-enable run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (re-enable run) : PASSED
	* Fails if final PT message length (23) is not as expected (23) : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (reset run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (reset run) : PASSED
	* Fails if final PT message length (179) is not as expected (179) : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (length 0 run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (length 0 run) : PASSED
	* Fails if final PT message length (0) is not as expected (0) : PASSED
	* Fails if rdy is not low at the posedge after en is deasserted (length 255 run) : PASSED
	* Fails if rdy is not reasserted within 4096 clock cycles (length 255 run) : FAILED
	* Fails if final PT message length (0) is not as expected (255) : FAILED
* **task3 : task3 : 100.0%**
	* DUT: task3.sv. Expectation: prga results as expected. Actual:         53/ 53 matching : PASSED
* **task4 : crack : 100.0%**
	* DUT: task4.sv. Expectation: key_valid asserted. : PASSED
	* DUT: task4.sv. Expectation: expected key found. (Found in 5159 cycles) : PASSED
* **task5 : doublecrack : 100.0%**
	* DUT: task5.sv. Expectation: key_valid asserted. : PASSED
	* DUT: task5.sv. Expectation: expected key found 2x faster. (Found in 2783 cycles) : PASSED
