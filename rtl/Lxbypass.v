module Lxbypass (
  // --------------------------------------------------------------------------
  // Module Port Arguments
  //
  // Using Verilog 1995 style port declaration to utilize localparams instead
  // of parameters for IO declarations to prevent undesired parameter overrides
  //
  // Clocks and resets
  reset, // (I) Asynchronous reset, active high
  clock, // (I) Clock

  // L1 Cache Interface
  msg_in,  // (I) Messages from L1 caches
  address, // (I) Addresses from L1 caches
  data_in, // (I) Data from L1 caches

  msg_out,     // (O) Messages to L1 caches
  out_address, // (O) Addresses to L1 caches
  data_out,    // (O) Data to L1 caches

  // Main Memory Interface
  mm2lxb_msg,     // (I) Message from main memory
  mm2lxb_address, // (I) Address from main memory
  mm2lxb_data,    // (I) Data from main memory

  lxb2mm_msg,     // (O) Message to main memory
  lxb2mm_address, // (O) Address to main memory
  lxb2mm_data     // (O) Data to main memory
);
  // --------------------------------------------------------------------------
  // Parameters / Localparams
  //
  localparam ULC_DBW = 32'd128;         // Upper-Level Cache Data Bus Width
  parameter  ABW     = 32'd12;          // Adress Bus Width
  localparam MSGW    = 32'd3;           // Message width
  parameter  NUM_ULC = 32'd2;           // Number of Upper-Level Caches
  localparam MM_DBW  = 32'd32;          // Main Memory Data Bus Width
  localparam ULC_IDW = $clog2(NUM_ULC); // Number of Upper-Level Cache ID bits
  
  // Response Messages
  localparam [MSGW-1:0] MEM_NO_MSG = 3'd0;
  localparam [MSGW-1:0] MEM_READY  = 3'd1;
  localparam [MSGW-1:0] MEM_SENT   = 3'd2;

  // Request Messages
  localparam [MSGW-1:0] NO_REQ = 3'd0;
  localparam [MSGW-1:0] WB_REQ = 3'd1;
  localparam [MSGW-1:0] R_REQ  = 3'd2;

  // --------------------------------------------------------------------------
  // Module Port Declarations
  //
  // Clocks and resets
  input reset;
  input clock;

  // L1 Cache Interface
  input         [MSGW*NUM_ULC-1:0] msg_in;
  input          [ABW*NUM_ULC-1:0] address;
  input      [ULC_DBW*NUM_ULC-1:0] data_in;

  output reg    [MSGW*NUM_ULC-1:0] msg_out;
  output reg     [ABW*NUM_ULC-1:0] out_address;
  output reg [ULC_DBW*NUM_ULC-1:0] data_out;

  // Main Memory Interface
  input        [MSGW-1:0] mm2lxb_msg;
  input         [ABW-1:0] mm2lxb_address;
  input      [MM_DBW-1:0] mm2lxb_data;

  output reg   [MSGW-1:0] lxb2mm_msg;
  output reg    [ABW-1:0] lxb2mm_address;
  output reg [MM_DBW-1:0] lxb2mm_data;

  // --------------------------------------------------------------------------
  // Internal Signal Declarations
  //
  genvar ii;
  
  // Higher Level Caching Arbitration
  wire [NUM_ULC-1:0] ulc_requests;
  
  wire [ULC_IDW-1:0] chosen_ulc;
  reg  [ULC_IDW-1:0] chosen_ulc_d1;

  // L1 Cache Interface
  reg    [MSGW*NUM_ULC-1:0] nxt_msg_out;
  reg     [ABW*NUM_ULC-1:0] nxt_out_address;
  reg [ULC_DBW*NUM_ULC-1:0] nxt_data_out;

  // Chosen Cache Interface Signals
  wire    [MSGW-1:0] chosen_msg_in;
  reg     [MSGW-1:0] chosen_msg_in_d1;
  wire    [MSGW-1:0] nxt_chosen_msg_in_d1;

  wire     [ABW-1:0] chosen_address;
  wire [ULC_DBW-1:0] chosen_data_in;

  reg     [MSGW-1:0] chosen_msg_out;
  reg     [MSGW-1:0] nxt_chosen_msg_out;
  wire     [ABW-1:0] chosen_out_address;
  wire [ULC_DBW-1:0] chosen_data_out;

  // Encryption/Decryption Keying
  wire  [ULC_DBW-1:0] in_cipher_key;
  wire                cipher_key_valid;
  wire                out_encoder_ready;
  wire                out_decoder_ready;

  reg           [1:0] exp_key;

  // Decryption Channel
  wire  [ULC_DBW-1:0] out_plain_data;
  wire                out_plain_data_valid;
  wire  [ULC_DBW-1:0] in_cipher_data;
  wire                in_cipher_data_valid;
  
  // Encryption Channel
  wire  [ULC_DBW-1:0] in_plain_data;
  reg                 in_plain_data_valid;
  wire  [ULC_DBW-1:0] out_cipher_data;
  wire                out_cipher_data_valid;

  // Lower Level Cache Gasketing
  reg         [1:0] pk_state;
  reg         [1:0] pk_state_d1;
  reg         [1:0] nxt_pk_state;
  reg [ULC_DBW-1:0] packed_mm2lxb_data;
  reg [ULC_DBW-1:0] nxt_packed_mm2lxb_data;

  reg         [1:0] unpk_state;
  reg         [1:0] nxt_unpk_state;
  reg [ULC_DBW-1:0] packed_lxb2mm_data;
  reg [ULC_DBW-1:0] nxt_packed_lxb2mm_data;
  
  reg   [MSGW-1:0] nxt_lxb2mm_msg;
  reg    [ABW-1:0] nxt_lxb2mm_address;
  reg [MM_DBW-1:0] nxt_lxb2mm_data;

  // --------------------------------------------------------------------------
  // Higher Level Caching Arbitration
  //
  arbiter #(.WIDTH(NUM_ULC)) u_arbiter (
    .reset    (reset),        // (I) Asynchronous reset, active high
    .clock    (clock),        // (I) Clock
    .requests (ulc_requests), // (I) Requests
    .grant    (chosen_ulc)    // (O) Encoded grant ID
  );

  for (ii=0; ii<NUM_ULC; ii=ii+1) begin : ulc_req_gen
    assign ulc_requests[ii] = (msg_in[ii*MSGW+:MSGW] == R_REQ) | (msg_in[ii*MSGW+:MSGW] == WB_REQ);
  end

  // --------------------------------------------------------------------------
  // Higher Level Cache Gasketing
  //
  // MUX address, data, and message inputs from all cache channels
  assign chosen_address = address[chosen_ulc*ABW     +: ABW];
  assign chosen_data_in = data_in[chosen_ulc*ULC_DBW +: ULC_DBW];

  // Mask chosen message in until AES is ready
  assign chosen_msg_in  = (out_encoder_ready && out_decoder_ready) ?
                          msg_in [chosen_ulc*MSGW    +: MSGW]      :
                          NO_REQ;

  // DeMUX address, data, and message from lower main to appropriate
  // higher level cache
  always @(posedge clock or posedge reset) begin : ulc_out_seq
    if (reset) begin
      msg_out     <= {MSGW   *NUM_ULC{1'b0}};
      out_address <= {ABW    *NUM_ULC{1'b0}};
      data_out    <= {ULC_DBW*NUM_ULC{1'b0}};
    end else begin
      msg_out     <= nxt_msg_out;
      out_address <= nxt_out_address;
      data_out    <= nxt_data_out;
    end
  end

  for (ii=0; ii<NUM_ULC; ii=ii+1) begin : ulc_
    always @* begin : out_comb
      if (ii[ULC_IDW-1:0]==chosen_ulc) begin
        nxt_msg_out    [ii*MSGW    +: MSGW]    = chosen_msg_out;
        nxt_out_address[ii*ABW     +: ABW]     = chosen_out_address;
        nxt_data_out   [ii*ULC_DBW +: ULC_DBW] = chosen_data_out;
      end else begin
        nxt_msg_out    [ii*MSGW    +: MSGW]    = {MSGW{1'b0}};
        nxt_out_address[ii*ABW     +: ABW]     = {ABW{1'b0}};
        nxt_data_out   [ii*ULC_DBW +: ULC_DBW] = {ULC_DBW{1'b0}};
      end
    end
  end

  // Register message and address from main memory.
  always @(posedge clock or posedge reset) begin : chosen_msg_out_seq
    if (reset) begin
      chosen_msg_out <= MEM_NO_MSG;
    end else begin
      chosen_msg_out <= nxt_chosen_msg_out;
    end
  end

  always @* begin : chosen_msg_out_comb
    case (chosen_msg_in)
      WB_REQ : begin
        // L1 requested write-back
        if (chosen_msg_out == MEM_READY) begin
          // Already signaling ready
          nxt_chosen_msg_out = MEM_NO_MSG;
        end else begin
          // Have not signaled ready back to L1
          if (unpk_state == 2'd0 && mm2lxb_msg == MEM_READY) begin
            // Last unpacked data write has taken place
            nxt_chosen_msg_out = MEM_READY;
          end else begin
            // Last unpacked data write has not taken place
            nxt_chosen_msg_out = MEM_NO_MSG;
          end
        end
      end

      R_REQ : begin
        // L1 requested read
        if (chosen_msg_out == MEM_SENT) begin
          // Already signaling sent
          nxt_chosen_msg_out = MEM_NO_MSG;
        end else begin
          // Have not signaled sent back to L1
          if (out_plain_data_valid) begin
            // Data decryption done
            nxt_chosen_msg_out = MEM_SENT;
          end else begin
            // Data decryption not done
            nxt_chosen_msg_out = MEM_NO_MSG;
          end
        end
      end

      default : nxt_chosen_msg_out = MEM_NO_MSG;
    endcase
  end
  
  assign chosen_data_out    = out_plain_data;
  assign chosen_out_address = chosen_address;

  // --------------------------------------------------------------------------
  // Encryption/Decryption Keying:
  //
  // Generate Cipher Key
  assign in_cipher_key = 128'd0;

  // Key expansion triggering
  always @ (posedge clock or posedge reset) begin : key_exp_seq
    if (reset) begin
      exp_key <= 2'b00;
    end else begin
      exp_key[1:0] <= {exp_key[0], 1'b1};
    end
  end
  
  assign cipher_key_valid = (exp_key[0] & ~exp_key[1]);

  // --------------------------------------------------------------------------
  // Encryption Engine
  //
  aes_cipher_block_128 u_aes_cipher_block_128 (
    // Clocks and Resets
    .in_clk                         (clock),                 // (I) Clock
    .in_reset                       (~reset),                 // (I) Asynchronous reset, active high

    // Encryption/Decryption Keying
    .in_cipher_key                  (in_cipher_key),         // (I) Cipher key
    .in_cipher_key_valid_to_encoder (cipher_key_valid),      // (I) Encoder key valid
    .out_encoder_ready              (out_encoder_ready),     // (O) Encoder ready
    .in_cipher_key_valid_to_decoder (cipher_key_valid),      // (I) Decoder key valid
    .out_decoder_ready              (out_decoder_ready),     // (O) Decoder ready

    // Decryption Channel
    .out_plain_data                 (out_plain_data),        // (O) Plaintext out
    .out_plain_data_valid           (out_plain_data_valid),  // (O) Plaintext out valid
    .in_cipher_data                 (in_cipher_data),        // (I) Ciphertext in
    .in_cipher_data_valid           (in_cipher_data_valid),  // (I) Ciphertext in valid

    // Encryption Channel
    .in_plain_data                  (in_plain_data),         // (I) Plaintext in
    .in_plain_data_valid            (in_plain_data_valid),   // (I) Plaintext in valid
    .out_cipher_data                (out_cipher_data),       // (O) Ciphertext out
    .out_cipher_data_valid          (out_cipher_data_valid)  // (O) Ciphertext out valid
  );

  // Plain data input to AES is the data chosen amongst all L1 caches
  assign in_plain_data = chosen_data_in;

  // Cipher data input to AES is the data from the main memory after it's packed
  assign in_cipher_data = packed_mm2lxb_data;

  // Create delayed versions of chosen_msg_in and chosen_id for encryption triggering
  always @(posedge clock or posedge reset) begin : aes_trig_seq
    if (reset) begin
      chosen_msg_in_d1 <= MEM_NO_MSG;
      chosen_ulc_d1    <= {ULC_IDW{1'b0}};
    end else begin
      chosen_msg_in_d1 <= nxt_chosen_msg_in_d1;
      chosen_ulc_d1    <= chosen_ulc;
    end
  end

  // Only capture messages from L1 when encoder is ready
  assign nxt_chosen_msg_in_d1 = (out_encoder_ready && out_decoder_ready) ? chosen_msg_in : NO_REQ;

  // Encryption Trigger
  always @* begin : enc_trigger
    if ((chosen_msg_in_d1 == NO_REQ) && (chosen_msg_in == WB_REQ)) begin
      // Chosen message changed from NO_REQ to WB_REQ
      in_plain_data_valid = 1'b1;
    end else begin
      // Chosen message has not changed from NO_REQ to WB_REQ
      if ((chosen_msg_in_d1 == WB_REQ) && (chosen_msg_in == WB_REQ)) begin
        // Chosen request remained WB_REQ
        if (chosen_ulc_d1 != chosen_ulc) begin
          // Chosen ID has changed
          in_plain_data_valid = 1'b1;
        end else begin
          // Chosen ID has not changed -> request is not new
          in_plain_data_valid = 1'b0;
        end
      end else begin
        // Not a WB_REQ
        in_plain_data_valid = 1'b0;
      end
    end
  end
  
  // Trigger decryption when packing FSM has wrapped
  assign in_cipher_data_valid = (pk_state == 2'd0) & (pk_state_d1 == 2'd3);
    
  // Register valid encrypted output data
  always @(posedge clock or posedge reset) begin : capture_cipher_out_seq
    if (reset) begin
      packed_lxb2mm_data <= 128'd0;
    end else begin
      packed_lxb2mm_data <= nxt_packed_lxb2mm_data;
    end
  end

  // Only capture output data when it's valid
  always @* begin : capture_cipher_out_comb
    if (out_cipher_data_valid) begin
      nxt_packed_lxb2mm_data = out_cipher_data;
    end else begin
      nxt_packed_lxb2mm_data = packed_lxb2mm_data;
    end
  end

  // --------------------------------------------------------------------------
  // Lower Level Cache Gasketing: Write Unpacking FSM
  //
  always @(posedge clock or posedge reset) begin : unpk_fsm_seq
    if (reset) begin
      unpk_state <= 2'd0;
    end else begin
      unpk_state <= nxt_unpk_state;
    end
  end

  always @* begin : unpk_fsm_comb
    case (unpk_state)
      2'd0 : begin
        if (out_cipher_data_valid) begin
          nxt_unpk_state = 2'd1;
        end else begin
          nxt_unpk_state = 2'd0;
        end
      end
      2'd1 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_unpk_state = 2'd2;
        end else begin
          nxt_unpk_state = 2'd1;
        end
      end
      2'd2 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_unpk_state = 2'd3;
        end else begin
          nxt_unpk_state = 2'd2;
        end
      end
      2'd3 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_unpk_state = 2'd0;
        end else begin
          nxt_unpk_state = 2'd3;
        end
      end
    endcase
  end
  
  // --------------------------------------------------------------------------
  // Lower Level Cache Gasketing: Read packing FSM
  //
  always @(posedge clock or posedge reset) begin : pk_fsm_seq
    if (reset) begin
      pk_state    <= 2'd0;
      pk_state_d1 <= 2'd0;
    end else begin
      pk_state    <= nxt_pk_state;
      pk_state_d1 <= pk_state;
    end
  end

  always @* begin : pk_fsm_comb
    case (pk_state)
      2'd0 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_pk_state = 2'd1;
        end else begin
          nxt_pk_state = 2'd0;
        end
      end
      2'd1 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_pk_state = 2'd2;
        end else begin
          nxt_pk_state = 2'd1;
        end
      end
      2'd2 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_pk_state = 2'd3;
        end else begin
          nxt_pk_state = 2'd2;
        end
      end
      2'd3 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_pk_state = 2'd0;
        end else begin
          nxt_pk_state = 2'd3;
        end
      end
    endcase
  end

  // --------------------------------------------------------------------------
  // Lower Level Cache Gasketing: Address and Message Generation
  //
  always @(posedge clock or posedge reset) begin : lxb2mm_addr_seq
    if (reset) begin
      lxb2mm_address <= {ABW{1'b0}};
      lxb2mm_msg     <= NO_REQ;
    end else begin
      lxb2mm_address <= nxt_lxb2mm_address;
      lxb2mm_msg     <= nxt_lxb2mm_msg;
    end
  end

  always @* begin : lxb2mm_addr_comb
    case (chosen_msg_in)
      WB_REQ : begin
        case (unpk_state)
          2'd0 : begin
            if (out_cipher_data_valid) begin
              nxt_lxb2mm_address = chosen_address;
              nxt_lxb2mm_msg     = chosen_msg_in;
            end else begin
              if (mm2lxb_msg == MEM_READY) begin
                nxt_lxb2mm_address = lxb2mm_address;
                nxt_lxb2mm_msg     = NO_REQ;
              end else begin
                nxt_lxb2mm_address = lxb2mm_address;
                nxt_lxb2mm_msg     = lxb2mm_msg;
              end
            end
          end
          2'd1 : begin
            if (mm2lxb_msg == MEM_READY) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = lxb2mm_msg;
           end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
          2'd2 : begin
            if (mm2lxb_msg == MEM_READY) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
          2'd3 : begin
            if (mm2lxb_msg == MEM_READY) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
        endcase
      end
      
      R_REQ : begin
        case (pk_state)
          2'd0 : begin
            if ((chosen_msg_in_d1 == NO_REQ) && (chosen_msg_in == R_REQ)) begin
              // Chosen message changed from NO_REQ to R_REQ
              nxt_lxb2mm_address = chosen_address;
              nxt_lxb2mm_msg     = chosen_msg_in;
            end else begin
              // Chosen message has not changed from NO_REQ to R_REQ
              if ((chosen_msg_in_d1 == R_REQ) && (chosen_msg_in == R_REQ)) begin
                // Chosen request remained R_REQ
                if (chosen_ulc_d1 != chosen_ulc) begin
                  // Chosen ID has changed
                  nxt_lxb2mm_address = chosen_address;
                  nxt_lxb2mm_msg     = chosen_msg_in;
                end else begin
                  // Chosen ID has not changed -> request is not new
                  if (pk_state_d1 == 2'd3) begin
                    // Last data beat transmitted already
                    nxt_lxb2mm_address = lxb2mm_address;
                    nxt_lxb2mm_msg     = NO_REQ;
                  end else begin
                    // No data beat has been previously transmitted
                    if (mm2lxb_msg == MEM_SENT) begin
                      // Data beat being transmitted
                      nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
                      nxt_lxb2mm_msg     = lxb2mm_msg;
                    end else begin
                      nxt_lxb2mm_address = lxb2mm_address;
                      nxt_lxb2mm_msg     = lxb2mm_msg;
                    end
                  end
                end
              end else begin
                // Not a R_REQ
                nxt_lxb2mm_address = lxb2mm_address;
                nxt_lxb2mm_msg     = lxb2mm_msg;
              end
            end
          end
          2'd1 : begin
            if (mm2lxb_msg == MEM_SENT) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
          2'd2 : begin
            if (mm2lxb_msg == MEM_SENT) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
          2'd3 : begin
            if (mm2lxb_msg == MEM_SENT) begin
              nxt_lxb2mm_address = lxb2mm_address - {ABW{1'b1}};
              nxt_lxb2mm_msg     = NO_REQ;
            end else begin
              nxt_lxb2mm_address = lxb2mm_address;
              nxt_lxb2mm_msg     = lxb2mm_msg;
            end
          end
        endcase
      end
        
      default : begin
        nxt_lxb2mm_address = lxb2mm_address;
        nxt_lxb2mm_msg     = lxb2mm_msg;
      end
    endcase
  end
  
  // --------------------------------------------------------------------------
  // Lower Level Cache Gasketing: Write Data
  //
  always @ (posedge clock or posedge reset) begin : lxb2mm_seq
    if (reset) begin
      lxb2mm_data <= {MM_DBW{1'b0}};
    end else begin
      lxb2mm_data <= nxt_lxb2mm_data;
    end
  end

  always @* begin : lxb2mm_comb
    case (unpk_state)
      2'd0 : begin
        if (out_cipher_data_valid) begin
          nxt_lxb2mm_data = out_cipher_data[31:0];
        end else begin
          nxt_lxb2mm_data = lxb2mm_data;
        end
      end
      2'd1 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_lxb2mm_data = packed_lxb2mm_data[63:32];
        end else begin
          nxt_lxb2mm_data = lxb2mm_data;
        end
      end
      2'd2 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_lxb2mm_data = packed_lxb2mm_data[95:64];
        end else begin
          nxt_lxb2mm_data = lxb2mm_data;
        end
      end
      2'd3 : begin
        if (mm2lxb_msg == MEM_READY) begin
          nxt_lxb2mm_data = packed_lxb2mm_data[127:96];
        end else begin
          nxt_lxb2mm_data = lxb2mm_data;
        end
      end
    endcase
  end
  
  // --------------------------------------------------------------------------
  // Lower Level Cache Gasketing: Read data and messaging
  //
  // Register valid encrypted input data
  always @(posedge clock or posedge reset) begin : capture_cipher_in_seq
    if (reset) begin
      packed_mm2lxb_data <= 128'd0;
    end else begin
      packed_mm2lxb_data <= nxt_packed_mm2lxb_data;
    end
  end

  always @* begin : capture_cipher_in_comb
    case (pk_state)
      2'd0 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_packed_mm2lxb_data[127:96] = packed_mm2lxb_data[127:96];
          nxt_packed_mm2lxb_data[ 95:64] = packed_mm2lxb_data[ 95:64];
          nxt_packed_mm2lxb_data[ 63:32] = packed_mm2lxb_data[ 63:32];
          nxt_packed_mm2lxb_data[ 31: 0] = mm2lxb_data;
        end else begin
          nxt_packed_mm2lxb_data = packed_mm2lxb_data;
        end
      end
      2'd1 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_packed_mm2lxb_data[127:96] = packed_mm2lxb_data[127:96];
          nxt_packed_mm2lxb_data[ 95:64] = packed_mm2lxb_data[ 95:64];
          nxt_packed_mm2lxb_data[ 63:32] = mm2lxb_data;
          nxt_packed_mm2lxb_data[ 31: 0] = packed_mm2lxb_data[ 31: 0];
        end else begin
          nxt_packed_mm2lxb_data = packed_mm2lxb_data;
        end
      end
      2'd2 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_packed_mm2lxb_data[127:96] = packed_mm2lxb_data[127:96];
          nxt_packed_mm2lxb_data[ 95:64] = mm2lxb_data;
          nxt_packed_mm2lxb_data[ 63:32] = packed_mm2lxb_data[ 63:32];
          nxt_packed_mm2lxb_data[ 31: 0] = packed_mm2lxb_data[ 31: 0];
        end else begin
          nxt_packed_mm2lxb_data = packed_mm2lxb_data;
        end
      end
      2'd3 : begin
        if (mm2lxb_msg == MEM_SENT) begin
          nxt_packed_mm2lxb_data[127:96] = mm2lxb_data;
          nxt_packed_mm2lxb_data[ 95:64] = packed_mm2lxb_data[ 95:64];
          nxt_packed_mm2lxb_data[ 63:32] = packed_mm2lxb_data[ 63:32];
          nxt_packed_mm2lxb_data[ 31: 0] = packed_mm2lxb_data[ 31: 0];
        end else begin
          nxt_packed_mm2lxb_data = packed_mm2lxb_data;
        end
      end
    endcase
  end

  // --------------------------------------------------------------------------
  // Unused
  //
  wire unused_ok = |{mm2lxb_address, 1'b1};
  
endmodule
