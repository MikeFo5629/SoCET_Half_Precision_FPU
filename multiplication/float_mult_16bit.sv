module half_FP_mult (
  input clk, rst, 
  input [15:0] float1, float2,
  output[15:0] product
);
  
  logic sign1, sign2, sign_p; 
  logic hidden_lead1, hidden_lead2;
  logic [4:0] exp1, exp2, exp_p;
  logic [5:0] exp_comb;
  logic [9:0] mant1, mant2, mant_p;
  
  logic [21:0] mant_multiplied;
  logic guard, round_bit, sticky, dummy;
  
  typedef enum logic [2:0] { 
    initializing,
    special_case,
    multiply,
    normalize_mant,
    assemble
  } state_t;
  
  state_t state;
  state_t next_state;
  
  always_ff @(posedge clk) begin
    case(state)
      // Currently goes
      // initializing ->
      // special_case ->
      // multiplying ->
      // normalize_mant ->
      // assemble
      initializing: begin
        sign1 =       float1[15];
        sign2 =       float2[15];
    
        exp1 =        float1[14:10];
        exp2 =        float2[14:10];
        
        hidden_lead1 = 1'b0;
        hidden_lead2 = 1'b0;
        mant1 =       float1[9:0];
        mant2 =       float2[9:0];
        next_state =  special_case;
      end
      
      special_case: begin
        // if either number is infinity, output is infinity
        if((exp1 == 5'b11111 & mant1 == 0) | (exp2 == 5'b11111 & mant2 == 0)) begin
          sign_p =    sign1 ^ sign2; // Accounts for +/- infinity
          exp_p =     5'b11111;
          mant_p =    10'b0000000000;
          next_state = assemble;
        end
        
        // if either number is quiet NaN, return quiet Nan
        else if((exp1 == 5'd31 & mant1[9] == 1'b0) | (exp2 == 5'd31 & mant2[9] == 1'b0)) begin
          sign_p =    1'b1;
          exp_p =     5'b11111;
          mant_p =    10'b0111111111;
          next_state = assemble;
        end
        
        // if either number is signalling NaN, return signalling Nan
        else if((exp1 == 5'd31 & mant1[9] == 1'b1) | (exp2 == 5'd31 & mant2[9] == 1'b1)) begin
          sign_p =    1'b1;
          exp_p =     5'b11111;
          mant_p =    10'b1111111111;
          next_state = assemble;
        end
        
        // if either number is zero, return zero
        else if((exp1 == 0 & mant1 == 0) | (exp2 == 0 & mant2 == 0)) begin
          sign_p =    sign1 ^ sign2; // IEE754 mandates signed zero
          exp_p =     5'b00000;
          mant_p =    10'b0000000000;
          next_state = assemble;
        end
        
        else begin
          next_state = multiply;
        end
      end
      
      multiply: begin
        sign_p = sign1 ^ sign2;
        exp_p = exp1 + exp2 - 5'd15;
        mant_multiplied = {hidden_lead1, mant1} * {hidden_lead2, mant2};
        
        next_state = normalize_mant;
      end
      
      normalize_mant: begin
        if(mant_multiplied[21] == 1'b1) begin
          exp_p = exp_p + 1;
          mant_multiplied = mant_multiplied >> 1;
        end
        
        mant_p = mant_multiplied[19:10];
        
        guard = mant_multiplied[9];
        round_bit = product[8];
        
        if(guard) begin
          round_bit = guard;
          guard = mant_p[0];
          mant_p = mant_p + 1;
        end
        // sticky = (product[7:0] != 0);
        
        next_state = assemble;
      end
      
      assemble: begin
        product[15] = sign_p;
        product[14:10] = exp_p;
        product[9:0] = mant_p;
      end
      
      default: begin
        sign_p = 0;
        sign1 = 0;
        sign2 = 0;
        
        exp_p = 0;
        exp1 = 0;
        exp2 = 0;
        
        mant_p = 0;
        mant1 = 0;
        mant2 = 0;
        
        guard = 0;
        round_bit = 0;
        sticky = 0;
        mant_multiplied = 0;
      end
    endcase
  end
  
  always_ff @(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
      state <= initializing;
    end
    else state <= next_state;
  end
endmodule
