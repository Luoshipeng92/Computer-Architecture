module ALU(
    clk,
    rst_n,
    valid,
    ready,
    mode,
    in_A,
    in_B,
    out
);

    // Definition of ports
    input         clk, rst_n;
    input         valid;
    input  [1:0]  mode; // mode: 0: mulu, 1: divu, 2: shift, 3: avg
    output        ready;
    input  [31:0] in_A, in_B;
    output [63:0] out;

    // Definition of states
    parameter IDLE  = 3'd0;
    parameter MUL   = 3'd1;
    parameter DIV   = 3'd2;
    parameter SHIFT = 3'd3;
    parameter AVG   = 3'd4;
    parameter OUT   = 3'd5;
    // states for multiple

    // Todo: Wire and reg if needed
    reg  [ 2:0] state, state_nxt;
    reg  [ 4:0] counter, counter_nxt;
    reg  [63:0] shreg, shreg_nxt;
    reg  [31:0] alu_in, alu_in_nxt;
    reg  [32:0] alu_out;
    reg         ready;
    reg  [63:0] tempA, tempB; // for division


    // Todo: Instatiate any primitives if needed
    // Todo 5: Wire assignments
    assign out = (ready)? shreg: 0;
    
    // Combinational always block
    // Todo 1: Next-state logic of state machine
    always @(*) begin
        case(state) 
            IDLE: begin
                if(valid) begin
                    case(mode)
                        2'd0 : state_nxt = MUL;
                        2'd1 : state_nxt = DIV;
                        2'd2 : state_nxt = SHIFT;
                        2'd3 : state_nxt = AVG;
                        default: state_nxt = IDLE;
                    endcase
                end
                else state_nxt = IDLE;
                ready = 1'b0;
            end
            MUL : begin
                if(counter == 5'd31) state_nxt = OUT;
                else state_nxt = MUL;
                ready = 1'b0;
            end
            DIV : begin
                if(counter == 5'd31) state_nxt = OUT;
                else state_nxt = DIV;
                ready = 1'b0;
            end
            SHIFT : begin
                state_nxt = OUT;
                ready = 1'b0;
            end
            AVG : begin
                state_nxt = OUT;
                ready = 1'b0;
            end
            OUT : begin
                state_nxt = IDLE;
                ready = 1'b1;
            end
            default : begin
                state_nxt = IDLE;
                ready = 1'b0;
            end
        endcase
    end
    // Todo 2: Counter
    always @(*) begin
        case(state)
            MUL : counter_nxt = counter + 1;
            DIV : counter_nxt = counter + 1;
            default : counter_nxt = 0;
        endcase
    end
    // ALU input
    always @(*) begin
        case(state)
            IDLE: begin
                if (valid) alu_in_nxt = in_B;
                else       alu_in_nxt = 0;
            end
            OUT : alu_in_nxt = 0;
            default: alu_in_nxt = alu_in;
        endcase
    end

    // Todo 3: ALU output
    always @(*) begin
        case(state)
            MUL : begin
                if(shreg[0] == 1) alu_out = alu_in + shreg[63:32];
                else alu_out = {1'b0, shreg[63:32]};
                tempA = 64'b0;
                tempB = 64'b0;
            end
            DIV : begin
                tempA = {tempA[62:0], 1'b0};
                if(tempA >= tempB) begin
                    if (counter == 5'd31) tempA = tempA;
                    else begin
                        tempA = tempA - tempB + 1'b1;
                    end 
                end
                else tempA = tempA;
                tempB = {alu_in, 32'b0};
                alu_out = 0;
            end
            SHIFT : begin
                alu_out = {1'b0, shreg[31:0] >> alu_in[2:0]};
                tempA = 64'b0;
                tempB = 64'b0;
            end
            AVG : begin
                alu_out = (shreg[31:0] + alu_in) >> 1;
                tempA = 64'b0;
                tempB = 64'b0;
            end
            default : begin
                alu_out = 0;
                tempA = {32'b0, in_A};
                tempB = {alu_in, 32'b0};
            end
        endcase
    end
    // Todo 4: Shift register
    always @(*) begin
        case(state)
            IDLE : begin
                if(valid) shreg_nxt = {32'b0, in_A};
                else      shreg_nxt = 0;
            end
            MUL : shreg_nxt = {alu_out, shreg[31:1]};
            DIV : shreg_nxt = {tempA[63:32] >> 1, tempA[31:0] >> 1};
            SHIFT : shreg_nxt = {32'b0, alu_out[31:0]};
            AVG : shreg_nxt = {32'b0, alu_out[31:0]};
            default : shreg_nxt = 0;
        endcase
    end
    // Todo: Sequential always block
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            counter <= 0;
            alu_in <= 0;
            shreg <= 0;
        end
        else begin
            state <= state_nxt;
            counter <= counter_nxt;
            alu_in <= alu_in_nxt;
            shreg <= shreg_nxt;
        end
    end

endmodule