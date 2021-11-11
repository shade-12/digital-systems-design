# Testing statistics for lab-1w1-shade-12

* **task1 : card7seg : 100.0%**
	* DUT: card7seg. Input:  0, Expected Output: b1111111, Actual Output: 1111111 : PASSED
	* DUT: card7seg. Input:  1, Expected Output: b0001000, Actual Output: 0001000 : PASSED
	* DUT: card7seg. Input:  2, Expected Output: b0100100, Actual Output: 0100100 : PASSED
	* DUT: card7seg. Input:  3, Expected Output: b0110000, Actual Output: 0110000 : PASSED
	* DUT: card7seg. Input:  4, Expected Output: b0011001, Actual Output: 0011001 : PASSED
	* DUT: card7seg. Input:  5, Expected Output: b0010010, Actual Output: 0010010 : PASSED
	* DUT: card7seg. Input:  6, Expected Output: b0000010, Actual Output: 0000010 : PASSED
	* DUT: card7seg. Input:  7, Expected Output: b1111000, Actual Output: 1111000 : PASSED
	* DUT: card7seg. Input:  8, Expected Output: b0000000, Actual Output: 0000000 : PASSED
	* DUT: card7seg. Input:  9, Expected Output: b0010000, Actual Output: 0010000 : PASSED
	* DUT: card7seg. Input: 10, Expected Output: b1000000, Actual Output: 1000000 : PASSED
	* DUT: card7seg. Input: 11 (J), Expected Output: b1100001, Actual Output: 1100001 : PASSED
	* DUT: card7seg. Input: 12 (Q), Expected Output: b0011000, Actual Output: 0011000 : PASSED
	* DUT: card7seg. Input: 13 (K), Expected Output: b0001001, Actual Output: 0001001 : PASSED
* **task4 : scorehand : 100.0%**
	* DUT: scorehand. Input: { 0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 2  0}, Expected Output:  2, Actual Output:  2 : PASSED
	* DUT: scorehand. Input: { 5  0}, Expected Output:  5, Actual Output:  5 : PASSED
	* DUT: scorehand. Input: { 6  0}, Expected Output:  6, Actual Output:  6 : PASSED
	* DUT: scorehand. Input: {10  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: {10  3}, Expected Output:  3, Actual Output:  3 : PASSED
	* DUT: scorehand. Input: {10  6}, Expected Output:  6, Actual Output:  6 : PASSED
	* DUT: scorehand. Input: {10  9}, Expected Output:  9, Actual Output:  9 : PASSED
	* DUT: scorehand. Input: {10 12}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 2  5}, Expected Output:  7, Actual Output:  7 : PASSED
	* DUT: scorehand. Input: {12  7}, Expected Output:  7, Actual Output:  7 : PASSED
* **task4 : statemachine : 100.0%**
	* Fails if load_pcard1 != 1 or not all other outputs are 0. : PASSED
	* Fails if load_pcard1 is not 1 after 0-1 clocks. : PASSED
	* Fails if load_dcard1 != 1 or not all other outputs are 0 after 1-2 clocks. : PASSED
	* Fails if load_dcard1 != 1 after 1-2 clocks. : PASSED
	* Fails if load_pcard2 != 1 or not all other outputs are 0, after 2-3 clocks. : PASSED
	* fails if load_pcard2 != 1 after 2-3 clocks. : PASSED
	* Fails if load_dcard2 != 1 or not all other outputs are 0, after 3-4 clocks. : PASSED
	* Fails if load_dcard2 != 1 after 3-4 clocks. : PASSED
* **task5 : scorehand : 100.0%**
	* DUT: scorehand. Input: { 0  0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 1  0  0}, Expected Output:  1, Actual Output:  1 : PASSED
	* DUT: scorehand. Input: { 2  0  0}, Expected Output:  2, Actual Output:  2 : PASSED
	* DUT: scorehand. Input: { 3  0  0}, Expected Output:  3, Actual Output:  3 : PASSED
	* DUT: scorehand. Input: { 4  0  0}, Expected Output:  4, Actual Output:  4 : PASSED
	* DUT: scorehand. Input: { 5  0  0}, Expected Output:  5, Actual Output:  5 : PASSED
	* DUT: scorehand. Input: { 6  0  0}, Expected Output:  6, Actual Output:  6 : PASSED
	* DUT: scorehand. Input: { 7  0  0}, Expected Output:  7, Actual Output:  7 : PASSED
	* DUT: scorehand. Input: { 8  0  0}, Expected Output:  8, Actual Output:  8 : PASSED
	* DUT: scorehand. Input: { 9  0  0}, Expected Output:  9, Actual Output:  9 : PASSED
	* DUT: scorehand. Input: {10  0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: {11  0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: {12  0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: {13  0  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  1  0}, Expected Output:  1, Actual Output:  1 : PASSED
	* DUT: scorehand. Input: { 0  2  0}, Expected Output:  2, Actual Output:  2 : PASSED
	* DUT: scorehand. Input: { 0  3  0}, Expected Output:  3, Actual Output:  3 : PASSED
	* DUT: scorehand. Input: { 0  4  0}, Expected Output:  4, Actual Output:  4 : PASSED
	* DUT: scorehand. Input: { 0  5  0}, Expected Output:  5, Actual Output:  5 : PASSED
	* DUT: scorehand. Input: { 0  6  0}, Expected Output:  6, Actual Output:  6 : PASSED
	* DUT: scorehand. Input: { 0  7  0}, Expected Output:  7, Actual Output:  7 : PASSED
	* DUT: scorehand. Input: { 0  8  0}, Expected Output:  8, Actual Output:  8 : PASSED
	* DUT: scorehand. Input: { 0  9  0}, Expected Output:  9, Actual Output:  9 : PASSED
	* DUT: scorehand. Input: { 0 10  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0 11  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0 12  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0 13  0}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  0  1}, Expected Output:  1, Actual Output:  1 : PASSED
	* DUT: scorehand. Input: { 0  0  2}, Expected Output:  2, Actual Output:  2 : PASSED
	* DUT: scorehand. Input: { 0  0  3}, Expected Output:  3, Actual Output:  3 : PASSED
	* DUT: scorehand. Input: { 0  0  4}, Expected Output:  4, Actual Output:  4 : PASSED
	* DUT: scorehand. Input: { 0  0  5}, Expected Output:  5, Actual Output:  5 : PASSED
	* DUT: scorehand. Input: { 0  0  6}, Expected Output:  6, Actual Output:  6 : PASSED
	* DUT: scorehand. Input: { 0  0  7}, Expected Output:  7, Actual Output:  7 : PASSED
	* DUT: scorehand. Input: { 0  0  8}, Expected Output:  8, Actual Output:  8 : PASSED
	* DUT: scorehand. Input: { 0  0  9}, Expected Output:  9, Actual Output:  9 : PASSED
	* DUT: scorehand. Input: { 0  0 10}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  0 11}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  0 12}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  0 13}, Expected Output:  0, Actual Output:  0 : PASSED
	* DUT: scorehand. Input: { 0  4  4}, Expected Output:  8, Actual Output:  8 : PASSED
	* DUT: scorehand. Input: { 0  4  8}, Expected Output:  2, Actual Output:  2 : PASSED
* **task5 : statemachine : 100.0%**
	* Fails if load_pcard1 not equal 1 and all other outputs are 0. : PASSED
	* Fails if load_pcard1 is not 1 after 0-1 clocks. : PASSED
	* Fails if load_dcard1 not equal 1 and all other outputs are 0 after 1-2 clocks. : PASSED
	* Fails if load_dcard1 is not 1 after 1-2 clocks. : PASSED
	* Fails if load_pcard2 not equal 1 and all other outputs are after 2-3 clocks. : PASSED
	* fails if load_pcard2 is not 1 after 2-3 clocks. : PASSED
	* Fails if load_dcard2 not equal 1 and all other outputs are 0, after 3-4 clocks. : PASSED
	* Fails if load_dcard2 is not 1 after 3-4 clocks. : PASSED
	* Fails if player_win_light is not 1 when pscore = 8 and dscore = 9, all other signals must be 0, after 4-6 clocks. : PASSED
	* Fails if player_win_light is not 1 when pscore = 8 and dscore = 9, after 4-6 clocks. : PASSED
	* Fails if player_win_light is not 1 when pscore = 9 and dscore = 8 after 4-6 clocks. : PASSED
	* Fails if both win lights are not 1 after 4-6 clocks and dscore = pscore = 8, after 4-5 clocks. : PASSED
	* Fails if load_pcard3 is not 1 when the clock has been toggled 4-6 times and the pscore is 5 and the dscore is 7 : PASSED
	* Fails if load_dcard3 is not 1 when the clock has been toggled 4-7 times and the pscore is 5 and the dscore is 4, and the player gets a 2. : PASSED
	* Fails if dealer_win_light is not 1 when the clock has been toggled 4-8 times and the pscore is 5 and the dscore is 4, and the player gets a 2, and dealer gets a 4. : PASSED
	* Fails if player_win_light is not 1 when the clock has been toggled 4-8 times and the pscore is 5 and the dscore is 4, and the player gets a 2, and dealer gets a 2. : PASSED
	* Fails if player_win_light is not 1 when the clock has been toggled 4-8 times and the pscore is 5 and the dscore is 5, and the player gets a 2.  : PASSED
	* Fails if load_dcard3 is not 1 when the clock has been toggled 4-6 times and the pscore is 6 and the dscore is 5 : PASSED
	* Fails if dealer_win_light is not 1 when the clock has been toggled 4-7 times and the pscore is 6 and the dscore is 7 after dcard3. : PASSED
	* Fails if player_win_light is not 1 when the clock has been toggled 4-5 times and the pscore is 6 and the dscore is 5 after dcard3. : PASSED
	* Fails if player_win_light and dealer_win_light is not 1 when the clock has been toggled 4-5 times and the pscore is 6 and the dscore is 6    after dcard3. : PASSED
