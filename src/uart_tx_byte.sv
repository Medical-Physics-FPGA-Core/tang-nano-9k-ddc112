module uart_tx_byte #(
    parameter CLK_HZ = 48_000_000,
    parameter BAUD   = 115_200
)(
    input  wire clk,
    input  wire rst_n,

    input  wire [7:0] data,
    input  wire       start,

    output reg        tx,
    output reg        busy
);

    localparam integer CLKS_PER_BIT = CLK_HZ / BAUD;

    reg [15:0] clk_cnt;
    reg [3:0]  bit_idx;
    reg [9:0]  shifter;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx       <= 1'b1;
            busy     <= 1'b0;
            clk_cnt  <= 16'd0;
            bit_idx  <= 4'd0;
            shifter  <= 10'b1111111111;
        end else begin
            if (!busy) begin
                tx <= 1'b1;

                if (start) begin
                    // start bit + 8 data bits + stop bit
                    shifter <= {1'b1, data, 1'b0};
                    busy    <= 1'b1;
                    clk_cnt <= 16'd0;
                    bit_idx <= 4'd0;
                    tx      <= 1'b0;
                end
            end else begin
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 16'd0;
                    bit_idx <= bit_idx + 4'd1;
                    shifter <= {1'b1, shifter[9:1]};

                    if (bit_idx == 4'd9) begin
                        busy <= 1'b0;
                        tx   <= 1'b1;
                    end else begin
                        tx <= shifter[1];
                    end
                end else begin
                    clk_cnt <= clk_cnt + 16'd1;
                end
            end
        end
    end

endmodule
