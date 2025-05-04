module Multiplier #(
    parameter N = 4
) (
    input wire clk,
    input wire rst_n,

    input wire start,
    output reg ready,

    input wire   [N-1:0] multiplier,
    input wire   [N-1:0] multiplicand,
    output reg [2*N-1:0] product
);
    localparam [1:0]IDLE  = 2'b00;
    localparam [1:0]LOAD  = 2'b01;
    localparam [1:0]EXEC  = 2'b10;
    localparam [1:0]DONE  = 2'b11;

    reg [1:0] estado, proximo_estado;

    reg [N-1:0] reg_multiplier;
    reg [2*N-1:0] reg_multiplicand;
    reg [2*N-1:0] reg_product;
    reg [2*N-1:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            reg_multiplier = 0;
            reg_multiplicand = 0;
            reg_product = 0;
            count = 0;
            ready = 0;
            product = 0;
            estado = IDLE;
        end else begin
            estado = proximo_estado;
        end
    end

    always @(estado or start or count) begin
        case (estado)
            IDLE:    proximo_estado   = start ? LOAD : IDLE;
            LOAD:    proximo_estado   = EXEC;
            EXEC:    proximo_estado   = (count == 0) ? DONE : EXEC;
            DONE:    proximo_estado   = IDLE;
            default: proximo_estado   = IDLE;
        endcase
    end

    always @(posedge clk) begin
        case (estado)
            IDLE: begin
                ready = 0;
            end
            LOAD: begin
                reg_multiplier = multiplier;
                reg_multiplicand = { {(N){1'b0}}, multiplicand }; // concatena N bits zero a esquerda
                reg_product = 0;
                count = N;
            end
            EXEC: begin
                if (reg_multiplier[0]) begin
                    reg_product = reg_product + reg_multiplicand;
                end
                reg_multiplier = reg_multiplier >> 1;
                reg_multiplicand = reg_multiplicand << 1;
                count = count - 1;
            end
            DONE: begin
                product = reg_product;
                ready = 1;
            end
        endcase
    end

endmodule
