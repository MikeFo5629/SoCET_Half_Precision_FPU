module half_FP_add (
  input clk, rst, 
  input [15:0] float1, float2,
  output[15:0] sum
);
  
  logic sign1, sign2, sign_p;
  logic [4:0] exp1, exp2, exp_p;
  logic [9:0] mant1, mant2, mant_p;
  
  typedef enum logic [2:0] { 
    initializing,
    special_case,
    add,
    normalize,
    assemble
  } state_t;
  
  state_t state;
  state_t next_state;
  
  
  always_ff @(posedge clk) begin
    case(state)
      
    endcase
  end
  
  always_ff @(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
      state <= initializing;
    end
    else state <= next_state;
  end
endmodule