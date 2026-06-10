module ddc_readout (
    input  wire        clk_48m,
    input  wire        rst_n,

    input  wire        dvalid_in,
    input  wire        dout_in,

    output reg         dxmit,
    output reg         dclk,

    output reg [39:0]  data_shift,
    output reg         data_ready,
    output reg         busy,
    output reg         dvalid_seen
);

    // ------------------------------------------------------------
    // DVALID同期化
    // ------------------------------------------------------------
    reg dvalid_ff1, dvalid_ff2, dvalid_ff3;

    always @(posedge clk_48m or negedge rst_n) begin
        if (!rst_n) begin
            dvalid_ff1 <= 1'b1;
            dvalid_ff2 <= 1'b1;
            dvalid_ff3 <= 1'b1;
        end else begin
            dvalid_ff1 <= dvalid_in;
            dvalid_ff2 <= dvalid_ff1;
            dvalid_ff3 <= dvalid_ff2;
        end
    end

    wire dvalid_fall = (dvalid_ff3 == 1'b1) && (dvalid_ff2 == 1'b0);

    // ------------------------------------------------------------
    // FSM
    // ------------------------------------------------------------
    localparam S_IDLE       = 3'd0;
    localparam S_DXMIT_LOW  = 3'd1;
    localparam S_DCLK_LOW   = 3'd2;
    localparam S_DCLK_HIGH  = 3'd3;
    localparam S_DONE       = 3'd4;

    reg [2:0] state;

    reg [5:0] half_cnt;   // 0..11 for 2 MHz half period
    reg [5:0] bit_cnt;    // 0..39

    always @(posedge clk_48m or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            dxmit       <= 1'b1;
            dclk        <= 1'b0;
            data_shift  <= 40'd0;
            data_ready  <= 1'b0;
            busy        <= 1'b0;
            dvalid_seen <= 1'b0;
            half_cnt    <= 6'd0;
            bit_cnt     <= 6'd0;
        end else begin
            data_ready <= 1'b0;

            case (state)

                S_IDLE: begin
                    dxmit    <= 1'b1;
                    dclk     <= 1'b0;
                    busy     <= 1'b0;
                    half_cnt <= 6'd0;
                    bit_cnt  <= 6'd0;

                    if (dvalid_fall) begin
                        dvalid_seen <= 1'b1;
                        dxmit       <= 1'b0;
                        busy        <= 1'b1;
                        state       <= S_DXMIT_LOW;
                    end
                end

                // DXMIT LOW後、少し待つ
                // データシート上はDXMIT LOWからDOUT有効まで最大30ns程度なので、
                // 48MHzで2クロック待てば十分余裕があります。
                S_DXMIT_LOW: begin
                    dclk <= 1'b0;

                    if (half_cnt == 6'd2) begin
                        half_cnt <= 6'd0;
                        state    <= S_DCLK_HIGH;
                    end else begin
                        half_cnt <= half_cnt + 6'd1;
                    end
                end

                // DCLK立上り
                // このタイミングでDOUTをサンプルする
                S_DCLK_HIGH: begin
                    dclk <= 1'b1;

                    if (half_cnt == 6'd0) begin
                        data_shift <= {data_shift[38:0], dout_in};
                    end

                    if (half_cnt == 6'd11) begin
                        half_cnt <= 6'd0;
                        state    <= S_DCLK_LOW;
                    end else begin
                        half_cnt <= half_cnt + 6'd1;
                    end
                end

                // DCLK立下り
                // DDC112側はこの後、次ビットを出す
                S_DCLK_LOW: begin
                    dclk <= 1'b0;

                    if (half_cnt == 6'd11) begin
                        half_cnt <= 6'd0;

                        if (bit_cnt == 6'd39) begin
                            state <= S_DONE;
                        end else begin
                            bit_cnt <= bit_cnt + 6'd1;
                            state   <= S_DCLK_HIGH;
                        end
                    end else begin
                        half_cnt <= half_cnt + 6'd1;
                    end
                end

                S_DONE: begin
                    dclk       <= 1'b0;
                    dxmit      <= 1'b1;
                    busy       <= 1'b0;
                    data_ready <= 1'b1;
                    state      <= S_IDLE;
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule
