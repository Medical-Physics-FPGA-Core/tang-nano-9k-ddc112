module ddc_uart_reporter (
    input  wire        clk_48m,
    input  wire        rst_n,

    input  wire [39:0] ddc_data,
    input  wire        ddc_data_ready,

    output wire        uart_tx
);

    // ------------------------------------------------------------
    // 0.5秒に1回だけ送信するための間引き
    // ------------------------------------------------------------
    reg [25:0] sample_cnt;
    reg        sample_req;

    reg [39:0] data_latched;
    reg        send_start;

    always @(posedge clk_48m or negedge rst_n) begin
        if (!rst_n) begin
            sample_cnt   <= 26'd0;
            sample_req   <= 1'b0;
            data_latched <= 40'd0;
            send_start   <= 1'b0;
        end else begin
            send_start <= 1'b0;

            if (sample_cnt == 26'd23_999_999) begin
                sample_cnt <= 26'd0;
                sample_req <= 1'b1;
            end else begin
                sample_cnt <= sample_cnt + 26'd1;
            end

            if (sample_req && ddc_data_ready) begin
                data_latched <= ddc_data;
                sample_req   <= 1'b0;
                send_start   <= 1'b1;
            end
        end
    end

    // ------------------------------------------------------------
    // 16進1桁をASCIIへ
    // ------------------------------------------------------------
    function [7:0] hex_ascii;
        input [3:0] v;
        begin
            if (v < 4'd10)
                hex_ascii = "0" + v;
            else
                hex_ascii = "A" + (v - 4'd10);
        end
    endfunction

    wire [19:0] in2 = data_latched[39:20];
    wire [19:0] in1 = data_latched[19:0];

    // ------------------------------------------------------------
    // UART送信FSM
    // 文字列: IN2=xxxxx IN1=xxxxx\r\n
    // ------------------------------------------------------------
    localparam S_IDLE = 2'd0;
    localparam S_SEND = 2'd1;
    localparam S_WAIT = 2'd2;

    reg [1:0] state;
    reg [4:0] char_idx;

    reg [7:0] tx_data;
    reg       tx_start;
    wire      tx_busy;

    uart_tx_byte u_uart_tx_byte (
        .clk   (clk_48m),
        .rst_n (rst_n),
        .data  (tx_data),
        .start (tx_start),
        .tx    (uart_tx),
        .busy  (tx_busy)
    );

    always @(posedge clk_48m or negedge rst_n) begin
        if (!rst_n) begin
            state    <= S_IDLE;
            char_idx <= 5'd0;
            tx_data  <= 8'h00;
            tx_start <= 1'b0;
        end else begin
            tx_start <= 1'b0;

            case (state)

                S_IDLE: begin
                    char_idx <= 5'd0;
                    if (send_start) begin
                        state <= S_SEND;
                    end
                end

                S_SEND: begin
                    if (!tx_busy) begin
                        case (char_idx)
                            5'd0:  tx_data <= "I";
                            5'd1:  tx_data <= "N";
                            5'd2:  tx_data <= "2";
                            5'd3:  tx_data <= "=";
                            5'd4:  tx_data <= hex_ascii(in2[19:16]);
                            5'd5:  tx_data <= hex_ascii(in2[15:12]);
                            5'd6:  tx_data <= hex_ascii(in2[11:8]);
                            5'd7:  tx_data <= hex_ascii(in2[7:4]);
                            5'd8:  tx_data <= hex_ascii(in2[3:0]);
                            5'd9:  tx_data <= " ";
                            5'd10: tx_data <= "I";
                            5'd11: tx_data <= "N";
                            5'd12: tx_data <= "1";
                            5'd13: tx_data <= "=";
                            5'd14: tx_data <= hex_ascii(in1[19:16]);
                            5'd15: tx_data <= hex_ascii(in1[15:12]);
                            5'd16: tx_data <= hex_ascii(in1[11:8]);
                            5'd17: tx_data <= hex_ascii(in1[7:4]);
                            5'd18: tx_data <= hex_ascii(in1[3:0]);
                            5'd19: tx_data <= 8'h0D; // CR
                            5'd20: tx_data <= 8'h0A; // LF
                            default: tx_data <= 8'h0A;
                        endcase

                        tx_start <= 1'b1;
                        state    <= S_WAIT;
                    end
                end

                S_WAIT: begin
                    if (tx_busy) begin
                        // UARTが送信開始したら次へ
                        if (char_idx == 5'd20) begin
                            state <= S_IDLE;
                        end else begin
                            char_idx <= char_idx + 5'd1;
                            state    <= S_SEND;
                        end
                    end
                end

                default: begin
                    state <= S_IDLE;
                end

            endcase
        end
    end

endmodule
