`timescale 1ns/1ps

module anode_drive(state, current_msg, anodes, current_char);  

//module that appears in the counter and drives the anodes depending on the current state(count)
//It also drives the character that will appear, depending on the anodes

//Anodes are active at 0

parameter AN3_ACTIVATED = 4'b0111;
parameter AN2_ACTIVATED = 4'b1011;
parameter AN1_ACTIVATED = 4'b1101;
parameter AN0_ACTIVATED = 4'b1110;
parameter ANODES_OFF    = 4'b1111;

input [3:0] state;
input [15:0] current_msg;   //Basically 4 chars (4x4bit) in a single bus, as they would appear on the 4 7segment digits
output [3:0] anodes;
output [3:0] current_char;

reg [3:0] anodes;
reg [3:0] current_char;

always @ (state or current_msg) begin

    case(state)

        4'b1111: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [15:12];
        end

        4'b1110: begin  
            anodes = AN3_ACTIVATED;                       
            current_char = current_msg [15:12];     
        end

        4'b1101: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [15:12];
        end

        4'b1100: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [11:8];     //an2 char is driven earlier
        end

        4'b1011: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [11:8];
        end

        4'b1010: begin
            anodes = AN2_ACTIVATED;                       
            current_char = current_msg [11:8];     
        end

        4'b1001: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [11:8];
        end

        4'b1000: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [7:4];      //an1 char is driven earlier
        end

        4'b0111: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [7:4];
        end

        4'b0110: begin
            anodes = AN1_ACTIVATED;                       
            current_char = current_msg [7:4];    
        end

        4'b0101: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [7:4];
        end

        4'b0100: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [3:0];      //an0 char is driven earlier
        end

        4'b0011: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [3:0];
        end

        4'b0010: begin  
            anodes = AN0_ACTIVATED;                      
            current_char = current_msg [3:0];     
        end

        4'b0001: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [3:0];
        end

        4'b0000: begin
            anodes = ANODES_OFF; 
            current_char = current_msg [15:12];    //an3 char is driven earlier
        end

        //each anode needs to stay at 1 for at least 3 clock periods

    endcase
    
end  

endmodule

`timescale 1ns/1ps

module counter(clk, reset, count); //a simple 4bit counter, used to drive the anodes

input clk, reset;
output [3:0] count;

reg [3:0] count; 

always@(posedge clk or posedge reset) begin

    if(reset == 1'b1) begin

        count <= 4'b1111;

    end
    
    else begin

        count <= count - 1'b1;  //counter is 4-bit, so at value 0000, it becomes 1111 due to 2s compliment

    end

end

endmodule

`timescale 1ns/1ps

module debouncer(clk, button, new_button);

input clk, button;
output new_button;


reg button_ff1, button_ff2, new_button;

wire clear;
wire enable;
reg [2:0] counter;

always@(posedge clk) begin

    //This emulates 2 serial flip flops (ff1, ff2)
    //Each button is the output for the respective ff
    //This acts as a synchronizer

    button_ff2 <= button_ff1;      
    button_ff1 <= button;       

end

assign clear = button_ff1 ^ button_ff2;

always@(posedge clk) begin

    //Counter is required to ensure that signal is clean
    //before it goes through
    //16-bit counter is used for the FPGA

    if(clear) begin
        counter <= 3'b0;
    end
    else if(~enable) begin
        counter <= counter + 1'b1;
    end
end

//If counter completes a cycle, the signal can go through

assign enable = (counter == 3'b111);

always@(posedge clk) begin

if(enable) begin
    new_button <= button_ff2;
end      

end

endmodule

    parameter LED_0 = 8'b00000011;      //char 0
    parameter LED_1 = 8'b10011111;      //char 1
    parameter LED_2 = 8'b00100101;      //char 2
    parameter LED_3 = 8'b00001101;      //char 3
    parameter LED_4 = 8'b10011001;      //char 4
    parameter LED_5 = 8'b01001001;      //char 5
    parameter LED_6 = 8'b01000001;      //char 6
    parameter LED_7 = 8'b00011101;      //char 8
    parameter LED_8 = 8'b00000001;      //char 8
    parameter LED_9 = 8'b00001001;      //char 9
    parameter LED_A = 8'b00010001;      //char A
    parameter LED_b = 8'b11000001;      //char b
    parameter LED_c = 8'b11100101;      //char c
    parameter LED_d = 8'b10000101;      //char d
    parameter LED_E = 8'b01100001;      //char E
    parameter LED_F = 8'b01110001;      //char F

`timescale 1ns/1ps

module LED_decoder(char, LED);   //activates each segment based on the input character.

input [3:0] char;               //4-bit, for each hexadecimal character (0-9, a-f).
output [7:0] LED;               //8-bit, for each segment of the LED (7 segments + dp). MSB is segment a, LSB is dp.

reg  [7:0] LED;

always@(char) begin

    case(char) 

        4'b0000:  LED = LED_0;  
        4'b0001:  LED = LED_1;  
        4'b0010:  LED = LED_2; 
        4'b0011:  LED = LED_3; 
        4'b0100:  LED = LED_4; 
        4'b0101:  LED = LED_5; 
        4'b0110:  LED = LED_6; 
        4'b0111:  LED = LED_7; 
        4'b1000:  LED = LED_8;
        4'b1001:  LED = LED_9;
        4'b1010:  LED = LED_A;
        4'b1011:  LED = LED_b;
        4'b1100:  LED = LED_c;
        4'b1101:  LED = LED_d;
        4'b1110:  LED = LED_E;
        4'b1111:  LED = LED_F;

    endcase

end

endmodule



module message_memory(clk, reset, button, current_msg);

//Not only serves as a memory for the message we want to show
//But it also contains a counter which shifts the message's digits every time the button is pressed

input clk, reset, button;
output [15:0] current_msg;    //Basically 4 chars (4x4bit) in a single bus, as they would appear on the 4 7segment digits

reg [15:0] current_msg; 
reg [3:0] message [15:0];      
reg [3:0] state;
reg msg_shift_sig, next_state_sig;
reg [3:0] an3_char, an2_char, an1_char, an0_char;

parameter INITIAL_STATE = 4'b1111;      //so that state begins at 0 on the first posedge
parameter INITIAL_MESSAGE = 16'b0;

always@(posedge clk or posedge reset) begin     //Initializing the memory (message)

    if(reset==1'b1) begin

       message[0]  <= 4'b0000;   //char 0        
       message[1]  <= 4'b0001;   //char 1
       message[2]  <= 4'b0010;   //char 2
       message[3]  <= 4'b0011;   //char 3
       message[4]  <= 4'b0100;   //char 4
       message[5]  <= 4'b0101;   //char 5
       message[6]  <= 4'b0110;   //char 6
       message[7]  <= 4'b0111;   //char 7
       message[8]  <= 4'b1000;   //char 8
       message[9]  <= 4'b1001;   //char 9
       message[10] <= 4'b1010;   //char A
       message[11] <= 4'b1011;   //char b
       message[12] <= 4'b1100;   //char C
       message[13] <= 4'b1101;   //char d
       message[14] <= 4'b1110;   //char E
       message[15] <= 4'b1111;   //char F

    end

end


always@(posedge clk or posedge reset) begin 

    if(reset == 1'b1) begin         //initializing

        state <= INITIAL_STATE;     
        current_msg <= INITIAL_MESSAGE;

        next_state_sig <= 1'b1;     //These two signals handle the state increment and the message shifting respectively
        msg_shift_sig <= 1'b0;      

    end

    else begin

        if(button == 1'b0 && next_state_sig == 1'b1) begin

            //When the button is not pressed, the state is incremented once.
            //The next_state_sig is set to 0, preventing further increments.
            //The msg_shift_sig is set to 1, allowing the message shifting on the next button press.

            state <= state + 1'b1;          
            next_state_sig <= 1'b0;         
            msg_shift_sig <= 1'b1;          

        end

        else begin

            if(button == 1'b1 && msg_shift_sig == 1'b1) begin

                //When the button is pressed, the message is shifted once.
                //The msg_shift_sig is set to 0, preventing further shiftings.
                //The next_state_sig is set to 1, allowing the state increment when the pressing ends.

                current_msg[15:12] <= an3_char;
                current_msg[11:8] <= an2_char;
                current_msg[7:4] <= an1_char;
                current_msg[3:0] <= an0_char;
                msg_shift_sig <= 1'b0;
                next_state_sig <= 1'b1;                     

            end

        end

    end 

end

//As the state increments, the characters shift

always@(state) begin
    if(reset == 1'b1) begin
        an3_char <= 4'b0;
        an2_char <= 4'b0;
        an1_char <= 4'b0;
        an0_char <= 4'b0;
    end
    else begin
        an3_char <= message[state + 4'b0000];
        an2_char <= message[state + 4'b0001];
        an1_char <= message[state + 4'b0010];
        an0_char <= message[state + 4'b0011];
    end
end


endmodule

`timescale 1ns/10ps

//Top Level Module

module LED_driver(reset, clk, button, an3, an2, an1, an0, a, b, c, d, e, f, g, dp); 

input clk, reset, button;
output an3, an2, an1, an0;  
output a, b, c, d, e, f, g, dp;

wire [7:0] LED;             //7 segments + dp in a single bus
wire [3:0] anodes;          //4 anodes in a single bus
wire new_clk;               //created from MMCM, period 20x larger, will be used instead of the input clock
wire [3:0] state;           //produced by counter
wire new_reset;             //debounced reset
wire new_button;            //debounced button
wire [15:0] current_msg;    //message that should appear on each state
wire [3:0] current_char;    //char that active anode drives 

wire clkout0, clkout0b, clkout1b, clkout2, clkout2b, clkout3, clkout3b, clkout4, clkout5, clkout6, clkfboutb, locked, clkfb; //MMCM parameters, not used.

assign {a, b, c, d, e, f, g, dp} = LED;
assign {an3, an2, an1, an0} = anodes; 


// MMCME2_BASE: Base Mixed Mode Clock Manager
//              Artix-7
// Xilinx HDL Language Template, version 2017.4

// CLKOUT1_DIVIDE (O), CLKFBOUT_MULT_F (M) and DIVCLK_DIVIDE (D) need to satisfy:
// Fvco = Fclk*M/D
// Fout = Fclk*M/D*O

// Fvco must between 600 and 2000 Mhz (600 in our case)
// Fclk is 100Mhz
// Fout must be 100Mhz/20 = 5Mhz
// So, M/D must be 6 (We choose M = 6, D = 1)
// and O must be 120

MMCME2_BASE #(
    .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
    .CLKFBOUT_MULT_F(6.000),     // Multiply value for all CLKOUT (2.000-64.000).
    .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
    .CLKIN1_PERIOD(10.000),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
    // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
    .CLKOUT1_DIVIDE(120),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT0_DIVIDE_F(1),    // Divide amount for CLKOUT0 (1.000-128.000).
    // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT6_DUTY_CYCLE(0.5),
    // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
    .CLKOUT0_PHASE(0.0),
    .CLKOUT1_PHASE(0.0),
    .CLKOUT2_PHASE(0.0),
    .CLKOUT3_PHASE(0.0),
    .CLKOUT4_PHASE(0.0),
    .CLKOUT5_PHASE(0.0),
    .CLKOUT6_PHASE(0.0),
    .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
    .DIVCLK_DIVIDE(1),         // Master division value (1-106)
    .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
    .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
)

MMCME2_BASE_inst (
    // Clock Outputs: 1-bit (each) output: User configurable clock outputs
    .CLKOUT0(clkout0),     // 1-bit output: CLKOUT0
    .CLKOUT0B(),   // 1-bit output: Inverted CLKOUT0
    .CLKOUT1(new_clk),     // 1-bit output: new_clk (our new clock)
    .CLKOUT1B(),   // 1-bit output: Inverted CLKOUT1
    .CLKOUT2(clkout2),     // 1-bit output: CLKOUT2
    .CLKOUT2B(),   // 1-bit output: Inverted CLKOUT2
    .CLKOUT3(clkout3),     // 1-bit output: CLKOUT3
    .CLKOUT3B(),   // 1-bit output: Inverted CLKOUT3
    .CLKOUT4(clkout4),     // 1-bit output: CLKOUT4
    .CLKOUT5(clkout5),     // 1-bit output: CLKOUT5
    .CLKOUT6(clkout6),     // 1-bit output: CLKOUT6
    // Feedback Clocks: 1-bit (each) output: Clock feedback ports
    .CLKFBOUT(clkfb),   // 1-bit output: Feedback clock
    .CLKFBOUTB(clkfboutb), // 1-bit output: Inverted CLKFBOUT
    // Status Ports: 1-bit (each) output: MMCM status ports
    .LOCKED(locked),       // 1-bit output: LOCK
    // Clock Inputs: 1-bit (each) input: Clock input
    .CLKIN1(clk),       // 1-bit input: Clock
    // Control Ports: 1-bit (each) input: MMCM control ports
    .PWRDWN(1'b0),       // 1-bit input: Power-down
    .RST(reset),             // 1-bit input: Reset (asynchronous)
    // Feedback Clocks: 1-bit (each) input: Clock feedback ports
    .CLKFBIN(clkfb)      // 1-bit input: Feedback clock
);
// End of MMCME2_BASE_inst instantiation


debouncer reset_debouncer (clk, reset, new_reset);  //reset debouncing

debouncer button_debouncer (clk, button, new_button);   //button debouncing

counter counter_inst (new_clk, new_reset, state);   //drives an anode every 4 cycles

message_memory message_memory_inst(new_clk, new_reset, new_button, current_msg); //initializes the message and shifts it

anode_drive anode_drive_inst(state, current_msg, anodes, current_char);  //drives the anodes and the respective character

LED_decoder LED_decoder_inst(current_char, LED);    //drives the LEDs according to the character




endmodule


