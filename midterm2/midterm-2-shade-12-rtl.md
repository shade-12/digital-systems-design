# Testing statistics for midterm-2-shade-12

* **task1 : task1 : 100.0%**
	* Fails if LEDR[0] does not change from 0 to 1. : PASSED
	* Fails if drawline() instance not created or LEDR[1] does not change from 0 to 1. : PASSED
	* Fails if drawline() inputs are not set up correctly. : PASSED
	* Fails if vga_adapter() outputs are not set up correctly. : PASSED
	* Fails if vga_adapter() RED pixel outputs are incorrect. : PASSED
* **task-drawline : drawline : 100.0%**
	* Mark 1 fails if code fails to compile or simulates with errors. : PASSED
	* Mark 2: fails if reset is asynchronous or vga_plot is not initialized to 0 after reset : PASSED
	* Mark 3: fails if done is not asserted within 1 to 19201 cycles after start has been asserted : PASSED
	* Mark 4: fails if start/done handshake not working : PASSED
	* Mark 5: plotting the first pixel at (59,25) : PASSED
	* Mark 6: drawing a straight line (using any algorithm) from (x0,y0) to (x1,y1) : PASSED
	* Mark 7: plotting the first pixel at (59,25) : PASSED
	* Mark 8: correctly writing only the precise pixels described by the above algorithm : PASSED
	* Mark 9: drawing the line within twice the target time budget : PASSED
	* Mark 10: drawing the line within the target time budget : PASSED
