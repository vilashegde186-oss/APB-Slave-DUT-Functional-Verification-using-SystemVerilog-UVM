
module apb_slave #(
    parameter ADDR_WIDTH   = 8,
    parameter DATA_WIDTH   = 32,
    parameter NUM_REGS     = 8,   
    parameter WAIT_REG_IDX = 2,   
    parameter WAIT_CYCLES  = 3,   
    parameter RO_REG_IDX   = 5,   
    parameter RDERR_REG_IDX= 6   
) (
    input  logic                  PCLK,
    input  logic                  PRESETn,

    input  logic [ADDR_WIDTH-1:0] PADDR,
    input  logic                  PSEL,
    input  logic                  PENABLE,
    input  logic                  PWRITE,
    input  logic [DATA_WIDTH-1:0] PWDATA,

    output logic [DATA_WIDTH-1:0] PRDATA,
    output logic                  PREADY,
    output logic                  PSLVERR
);


//   FSM   

typedef enum logic [1:0] {IDEAL,SETUP,ACCESS} opt_apb;
opt_apb state,next_state;

always_ff @(posedge PCLK or negedge PRESETn)
begin
    
    if(!PRESETn)
    state <= IDEAL;

    else
    state <= next_state;

end

always_comb 
begin 
         next_state = state;
        unique case(state)
    IDEAL:
    begin
        if(PSEL)
        next_state = SETUP;
        else
        next_state = IDEAL;
    end

    SETUP:
    begin
        if(PENABLE)
        next_state = ACCESS;
        else
        next_state = SETUP;
    end

    ACCESS:
    begin
        if(PREADY)
        begin
            if(PSEL)
            next_state = SETUP;
            else
            next_state = IDEAL;
        end

        else
        next_state = ACCESS;
    end
    
    default: next_state = IDEAL;
endcase
end


// Address Decode

logic [ADDR_WIDTH-1:0] word_addr;
logic addr_valid;

assign word_addr = PADDR;
assign addr_valid = (word_addr < NUM_REGS);

// wait state 

localparam int cnt_w = $clog2(WAIT_CYCLES + 1);
logic [cnt_w - 1 : 0] wait_cnt;

always_ff @(posedge PCLK or negedge PRESETn)
begin

    if(!PRESETn)
    wait_cnt <= '0;
    else if(state == SETUP && PENABLE )
    begin

        if(addr_valid && (word_addr == WAIT_REG_IDX))
        wait_cnt <= WAIT_CYCLES[cnt_w - 1 : 0];

    end
    else if (state == ACCESS && wait_cnt != 0) 
            wait_cnt <= wait_cnt - 1'b1;
end

// PREADY AND PSLVERR

logic read_err_acess ;
assign read_err_acess = addr_valid && !PWRITE && (word_addr == RDERR_REG_IDX );

assign PREADY = (state == ACCESS) && (wait_cnt == 0);
assign  PSLVERR = (state == ACCESS) && PREADY && (!addr_valid || read_err_acess);

//REGISTOR ARRY

logic [DATA_WIDTH-1:0] regs [0:NUM_REGS-1];

always_ff @(posedge PCLK or negedge PRESETn)
begin

    if(!PRESETn)
    begin
    for(int i=0; i<NUM_REGS; i++ )
    regs[i] <= 0;
    end
    else if(state == ACCESS && addr_valid  && PWRITE && PREADY && word_addr != RO_REG_IDX )
    regs[word_addr] <= PWDATA;

end

always_comb
begin

    if(PWRITE || !addr_valid || read_err_acess)
    PRDATA = '0;
    else
    PRDATA = regs[word_addr];

end

endmodule

